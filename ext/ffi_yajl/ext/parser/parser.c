#include <ruby.h>
#include <yajl/yajl_parse.h>

#ifdef HAVE_RUBY_ENCODING_H
#include <ruby/encoding.h>
static rb_encoding *utf8Encoding;
#endif

static VALUE mFFI_Yajl, mExt, mParser, cParseError;

typedef struct {
  VALUE finished;
  VALUE stack;
  VALUE key_stack;
  VALUE key;
} CTX;

void set_value(CTX *ctx, VALUE val) {
  long len = RARRAY_LEN(ctx->stack);
  VALUE last = rb_ary_entry(ctx->stack, len-1);
  switch (TYPE(last)) {
    case T_ARRAY:
      rb_ary_push(last, val);
      break;
    case T_HASH:
      rb_hash_aset(last, ctx->key, val);
      break;
    default:
      break;
  }
}

void set_key(CTX *ctx, VALUE key) {
  ctx->key = key;
}

void start_object(CTX *ctx, VALUE obj) {
  rb_ary_push(ctx->key_stack, ctx->key);
  rb_ary_push(ctx->stack, obj);
}

void end_object(CTX *ctx) {
  ctx->key = rb_ary_pop(ctx->key_stack);
  if ( RARRAY_LEN(ctx->stack) > 1 ) {
    set_value(ctx, rb_ary_pop(ctx->stack));
  } else {
    ctx->finished = rb_ary_pop(ctx->stack);
  }
}

int null_callback(void *ctx) {
  set_value(ctx, Qnil);
  return 1;
}

int boolean_callback(void *ctx, int boolean) {
  set_value(ctx, boolean ? Qtrue : Qfalse);
  return 1;
}

int integer_callback(void *ctx, long long intVal) {
  set_value(ctx, LONG2NUM(intVal));
  return 1;
}

int double_callback(void *ctx, double doubleVal) {
  set_value(ctx, rb_float_new(doubleVal));
  return 1;
}

int number_callback(void *ctx, const char *numberVal, size_t numberLen) {
  char buf[numberLen+1];
  buf[numberLen] = 0;
  memcpy(buf, numberVal, numberLen);
  if (memchr(buf, '.', numberLen) ||
    memchr(buf, 'e', numberLen) ||
    memchr(buf, 'E', numberLen)) {
    set_value(ctx, rb_float_new(strtod(buf, NULL)));
  } else {
    set_value(ctx, rb_cstr2inum(buf, 10));
  }
  return 1;
}

int string_callback(void *ctx, const unsigned char *stringVal, size_t stringLen) {
  char buf[stringLen+1];
  VALUE str;
#ifdef HAVE_RUBY_ENCODING_H
  rb_encoding *default_internal_enc;
#endif

  buf[stringLen] = 0;
  memcpy(buf, stringVal, stringLen);
  str = rb_str_new2(buf);
#ifdef HAVE_RUBY_ENCODING_H
  default_internal_enc = rb_default_internal_encoding();
  rb_enc_associate(str, utf8Encoding);
  if (default_internal_enc) {
    str = rb_str_export_to_enc(str, default_internal_enc);
  }
#endif
  set_value(ctx,str);
  return 1;
}

int start_map_callback(void *ctx) {
  start_object(ctx,rb_hash_new());
  return 1;
}

int map_key_callback(void *ctx, const unsigned char *stringVal, size_t stringLen) {
  char buf[stringLen+1];
  VALUE str;
#ifdef HAVE_RUBY_ENCODING_H
  rb_encoding *default_internal_enc;
#endif

  buf[stringLen] = 0;
  memcpy(buf, stringVal, stringLen);
  str = rb_str_new2(buf);
#ifdef HAVE_RUBY_ENCODING_H
  default_internal_enc = rb_default_internal_encoding();
  rb_enc_associate(str, utf8Encoding);
  if (default_internal_enc) {
    str = rb_str_export_to_enc(str, default_internal_enc);
  }
#endif
  set_key(ctx,str);
  return 1;
}

int end_map_callback(void *ctx) {
  end_object(ctx);
  return 1;
}

int start_array_callback(void *ctx) {
  start_object(ctx,rb_ary_new());
  return 1;
}

int end_array_callback(void *ctx) {
  end_object(ctx);
  return 1;
}

static yajl_callbacks callbacks = {
  null_callback,
  boolean_callback,
  integer_callback,
  double_callback,
  number_callback,
  string_callback,
  start_map_callback,
  map_key_callback,
  end_map_callback,
  start_array_callback,
  end_array_callback,
};

static VALUE mParser_do_yajl_parse(VALUE self, VALUE str, VALUE opts) {
  yajl_handle hand;
  yajl_status stat;
  unsigned char *err;
  CTX ctx;

  ctx.stack = rb_ary_new();
  ctx.key_stack = rb_ary_new();

  hand = yajl_alloc(&callbacks, NULL, &ctx);
  if ((stat = yajl_parse(hand, (unsigned char *)RSTRING_PTR(str), RSTRING_LEN(str))) != yajl_status_ok) {
    err = yajl_get_error(hand, 1, (unsigned char *)RSTRING_PTR(str), RSTRING_LEN(str));
    goto raise;
  }
  if ((stat = yajl_complete_parse(hand)) != yajl_status_ok) {
    err = yajl_get_error(hand, 1, (unsigned char *)RSTRING_PTR(str), RSTRING_LEN(str));
    goto raise;
  }
  yajl_free(hand);
  return ctx.finished;

raise:
  if (hand) {
    yajl_free(hand);
  }
  rb_raise(cParseError, "%s", err);
}

void Init_parser() {
  mFFI_Yajl = rb_define_module("FFI_Yajl");
  cParseError = rb_define_class_under(mFFI_Yajl, "ParseError", rb_eStandardError);
  mExt = rb_define_module_under(mFFI_Yajl, "Ext");
  mParser = rb_define_module_under(mExt, "Parser");
  rb_define_method(mParser, "do_yajl_parse", mParser_do_yajl_parse, 2);
#ifdef HAVE_RUBY_ENCODING_H
  utf8Encoding = rb_utf8_encoding();
#endif
}

