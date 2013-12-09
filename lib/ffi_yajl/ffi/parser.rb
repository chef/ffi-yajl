module FFI_Yajl
  module FFI
    module Parser
      class State
        attr_accessor :stack, :key_stack, :key

        def initialize
          @stack = Array.new
          @key_stack = Array.new
        end

        def save_key
          key_stack.push(key)
        end

        def restore_key
          @key = key_stack.pop()
        end

        def set_value(val)
          case stack.last
          when Hash
            raise if key.nil?
            stack.last[key] = val
          when Array
            stack.last.push(val)
          else
            raise
          end
        end
      end

      def setup_callbacks
        ctx_mapping = @ctx_mapping # get a local alias
        @null_callback = ::FFI::Function.new(:int, [:pointer]) do |ctx|
          ctx_mapping[ctx.get_ulong(0)].set_value(nil)
          1
        end
        @boolean_callback = ::FFI::Function.new(:int, [:pointer, :int]) do |ctx, boolval|
          ctx_mapping[ctx.get_ulong(0)].set_value(boolval == 1 ? true : false)
          1
        end
        @integer_callback = ::FFI::Function.new(:int, [:pointer, :long_long]) do |ctx, intval|
          ctx_mapping[ctx.get_ulong(0)].set_value(intval)
          1
        end
        @double_callback = ::FFI::Function.new(:int, [:pointer, :double]) do |ctx, doubleval|
          ctx_mapping[ctx.get_ulong(0)].set_value(doubleval)
          1
        end
        @number_callback = ::FFI::Function.new(:int, [:pointer, :pointer, :size_t]) do |ctx, numberval, numberlen|
          raise "NumberCallback: not implemented"
          1
        end
        @string_callback = ::FFI::Function.new(:int, [:pointer, :string, :size_t]) do |ctx, stringval, stringlen|
          s = stringval.slice(0,stringlen)
          s.force_encoding('UTF-8') if defined? Encoding
          ctx_mapping[ctx.get_ulong(0)].set_value(s)
          1
        end
        @start_map_callback = ::FFI::Function.new(:int, [:pointer]) do |ctx|
          state = ctx_mapping[ctx.get_ulong(0)]
          state.save_key
          state.stack.push(Hash.new)
          1
        end
        @map_key_callback = ::FFI::Function.new(:int, [:pointer, :string, :size_t]) do |ctx, key, keylen|
          ctx_mapping[ctx.get_ulong(0)].key = key.slice(0,keylen)
          1
        end
        @end_map_callback = ::FFI::Function.new(:int, [:pointer]) do |ctx|
          state = ctx_mapping[ctx.get_ulong(0)]
          state.restore_key
          state.set_value( state.stack.pop ) if state.stack.length > 1
          1
        end
        @start_array_callback = ::FFI::Function.new(:int, [:pointer]) do |ctx|
          state = ctx_mapping[ctx.get_ulong(0)]
          state.save_key
          state.stack.push(Array.new)
          1
        end
        @end_array_callback = ::FFI::Function.new(:int, [:pointer]) do |ctx|
          state = ctx_mapping[ctx.get_ulong(0)]
          state.restore_key
          ctx_mapping[ctx.get_ulong(0)].set_value( ctx_mapping[ctx.get_ulong(0)].stack.pop ) if ctx_mapping[ctx.get_ulong(0)].stack.length > 1
          1
        end
      end

      def do_yajl_parse(str, opts = {})
        @ctx_mapping ||= Hash.new
        setup_callbacks
        rb_ctx = ::FFI_Yajl::FFI::Parser::State.new()
        @ctx_mapping[rb_ctx.object_id] = rb_ctx
        ctx = ::FFI::MemoryPointer.new(:long)
        ctx.write_long( rb_ctx.object_id )
        callback_ptr = ::FFI::MemoryPointer.new(::FFI_Yajl::YajlCallbacks)
        callbacks = ::FFI_Yajl::YajlCallbacks.new(callback_ptr)
        callbacks[:yajl_null] = @null_callback
        callbacks[:yajl_boolean] = @boolean_callback
        callbacks[:yajl_integer] = @integer_callback
        callbacks[:yajl_double] = @double_callback
        callbacks[:yajl_number] = nil #NumberCallback
        callbacks[:yajl_string] = @string_callback
        callbacks[:yajl_start_map] = @start_map_callback
        callbacks[:yajl_map_key] = @map_key_callback
        callbacks[:yajl_end_map] = @end_map_callback
        callbacks[:yajl_start_array] = @start_array_callback
        callbacks[:yajl_end_array] = @end_array_callback
        yajl_handle = ::FFI_Yajl.yajl_alloc(callback_ptr, nil, ctx)
        if ( stat = ::FFI_Yajl.yajl_parse(yajl_handle, str, str.bytesize) != :yajl_status_ok )
          # FIXME: dup the error and call yajl_free_error?
          error = ::FFI_Yajl.yajl_get_error(yajl_handle, 1, str, str.length)
          raise ::FFI_Yajl::ParseError.new(error)
        end
        if ( stat = FFI_Yajl.yajl_complete_parse(yajl_handle) != :yajl_status_ok )
          # FIXME: dup the error and call yajl_free_error?
          error = ::FFI_Yajl.yajl_get_error(yajl_handle, 1, str, str.length)
          raise ::FFI_Yajl::ParseError.new(error)
        end
        rb_ctx.stack.pop
      ensure
        ::FFI_Yajl.yajl_free(yajl_handle) if yajl_handle
        @ctx_mapping.delete(rb_ctx.object_id) if rb_ctx && rb_ctx.object_id
      end
    end
  end
end

