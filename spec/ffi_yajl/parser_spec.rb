# encoding: UTF-8
# Copyright (c) 2015 Lamont Granquist
# Copyright (c) 2015 Chef Software, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'spec_helper'

describe "FFI_Yajl::Parser" do
  shared_examples_for "correct json parsing" do
    context "when json has 23456789012E666" do
      let(:json) {  '{"key": 23456789012E666}' }

      it "should return infinity" do
        infinity = (1.0 / 0)
        expect(parser).to eq("key" => infinity)
      end
    end

    context "when parsing nil" do
      let(:json) { nil }
      it "should not coredump ruby" do
        expect { parser }.to raise_error(FFI_Yajl::ParseError)
      end
    end

    context "when parsing bare int" do
      let(:json) { "1" }
      it "should parse to the int value" do
        expect( parser ).to eq(1)
      end
    end

    context "when parsing bare string" do
      let(:json) { '"a"' }
      it "should parse to the string value" do
        expect( parser ).to eq("a")
      end
    end

    context "when parsing bare true" do
      let(:json) { "true" }
      it "should parse to the true value" do
        expect( parser ).to eq(true)
      end
    end

    context "when parsing bare false" do
      let(:json) { "false" }
      it "should parse to the false value" do
        expect( parser ).to eq(false)
      end
    end

    context "when parsing bare null" do
      let(:json) { "null" }
      it "should parse to the nil value" do
        expect( parser ).to eq(nil)
      end
    end

    context "when parsing bare float" do
      let(:json) { "1.1" }
      it "should parse to the a float" do
        expect( parser ).to eq(1.1)
      end
    end

    context "when json has comments" do
      let(:json) { '{"key": /* this is a comment */ "value"}' }

      context "when allow_comments is false" do
        let(:options) { { allow_comments: false } }

        it "should not parse" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end
      end

      context "when allow_comments is true" do
        let(:options) { { allow_comments: true } }

        it "should parse" do
          expect(parser).to eq("key" => "value")
        end
      end

      context "by default" do
        let(:options) {}

        it "should parse" do
          expect(parser).to eq("key" => "value")
        end
      end
    end

    context "when json has multiline comments" do
      let(:json) { %{{"key": \n/*\n this is a multiline comment \n*/\n "value"}} }

      context "when allow_comments is false" do
        let(:options) { { allow_comments: false } }

        it "should not parse" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end
      end

      context "when allow_comments is true" do
        let(:options) { { allow_comments: true } }

        it "should parse" do
          expect(parser).to eq("key" => "value")
        end
      end
    end

    context "when json has inline comments" do
      let(:json) { %{{"key": \n// this is an inline comment\n "value"}} }

      context "when allow_comments is false" do
        let(:options) { { allow_comments: false } }

        it "should not parse" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end
      end

      context "when allow_comments is true" do
        let(:options) { { allow_comments: true } }

        it "should parse" do
          expect(parser).to eq("key" => "value")
        end
      end
    end

    context "when json is invalid UTF8" do
      let(:json) { "[\"\201\203\"]" }

      it "should not parse by default" do
        expect { parser }.to raise_error(FFI_Yajl::ParseError)
      end

      context "when :dont_validate_strings is set to true" do
        let(:options) { { dont_validate_strings: true } }

        it "should parse" do
          expect(parser).to eq(["\x81\x83"])
        end
      end

      context "when :dont_validate_strings is set to false" do
        let(:options) { { dont_validate_strings: false } }

        it "should not parse" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end
      end

      context "when :check_utf8 is set to true" do
        let(:options) { { check_utf8: true } }

        it "should not parse" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end

        context "when :dont_validate_strings is set to true" do
          let(:options) { { check_utf8: true, dont_validate_strings: true } }

          it "should raise an ArgumentError" do
            expect { parser }.to raise_error(ArgumentError)
          end
        end

        context "when :dont_validate_strings is set to false" do
          let(:options) { { check_utf8: true, dont_validate_strings: false } }

          it "should not parse" do
            expect { parser }.to raise_error(FFI_Yajl::ParseError)
          end
        end
      end

      context "when :check_utf8 is set to false" do
        let(:options) { { check_utf8: false } }

        it "should parse" do
          expect(parser).to eq(["\x81\x83"])
        end

        context "when :dont_validate_strings is set to true" do
          let(:options) { { check_utf8: false, dont_validate_strings: true } }

          it "should parse" do
            expect(parser).to eq(["\x81\x83"])
          end
        end

        context "when :dont_validate_strings is set to false" do
          let(:options) { { check_utf8: false, dont_validate_strings: false } }

          it "should raise an ArgumentError" do
            expect { parser }.to raise_error(ArgumentError)
          end
        end
      end
    end

    context "when JSON is a StringIO" do
      let(:json) { StringIO.new('{"key": 1234}') }

      it "should parse" do
        expect(parser).to eq("key" => 1234)
      end
    end

    context "when parsing a JSON string" do
      let(:json) { '{"key": 1234}' }

      it "should parse correctly" do
        expect(parser).to eq("key" => 1234)
      end

      context "when symbolize_keys is true" do
        let(:options) { { symbolize_keys: true } }

        it "should symbolize keys correctly" do
          expect(parser).to eq(key: 1234)
        end
      end

      context "when passing a block" do
        it "should parse correctly" do
          skip "handle blocks"
          output = nil
          parser do |obj|
            output = obj
          end
          expect(output).to eq("key" => 1234)
        end
      end
    end

    context "when parsing a JSON hash with only strings" do
      let(:json) { '{"key": "value"}' }

      if RUBY_VERSION.to_f >= 1.9
        context "when Encoding.default_internal is nil" do
          before do
            @saved_encoding = Encoding.default_internal
            Encoding.default_internal = nil
          end
          after do
            Encoding.default_internal = @saved_encoding
          end
          it "encodes keys to UTF-8" do
            expect(parser.keys.first.encoding).to eql(Encoding.find('utf-8'))
          end
          it "encodes values to UTF-8" do
            expect(parser.values.first.encoding).to eql(Encoding.find('utf-8'))
          end
        end

        %w{utf-8 us-ascii}.each do |encoding|
          context "when Encoding.default_internal is #{encoding}" do
            before do
              @saved_encoding = Encoding.default_internal
              Encoding.default_internal = nil
            end
            after do
              Encoding.default_internal = @saved_encoding
            end
            it "encodes keys to #{encoding}" do
              skip "fix us-ascii" if encoding == "us-ascii"
              expect(parser.keys.first.encoding).to eql(Encoding.find(encoding))
            end
            it "encodes values to #{encoding}" do
              skip "fix us-ascii" if encoding == "us-ascii"
              expect(parser.values.first.encoding).to eql(Encoding.find(encoding))
            end
          end
        end
      end
    end

    context "when a parsed key has utf-8 multibyte characters" do
      let(:json) { '{"日本語": 1234}' }

      it "should parse correctly" do
        expect(parser).to eq("日本語" => 1234)
      end

      context "when symbolize_keys is true" do
        let(:options) { { symbolize_keys: true } }

        it "should symbolize keys correctly" do
          expect(parser).to eq(:"日本語" => 1234) # rubocop:disable Style/HashSyntax
        end

        if RUBY_VERSION.to_f >= 1.9
          it "should parse non-ascii symbols in UTF-8" do
            expect(parser.keys.fetch(0).encoding).to eq(Encoding::UTF_8)
          end
        end
      end
    end

    context "when parsing 2147483649" do
      let(:json) { "{\"id\": 2147483649}" }

      it "should parse corectly" do
        expect(parser).to eql("id" => 2_147_483_649)
      end
    end

    context "when parsing 5687389800" do
      let(:json) { "{\"id\": 5687389800}" }

      it "should parse corectly" do
        expect(parser).to eql("id" => 5_687_389_800)
      end
    end

    context "when parsing 1046289770033519442869495707521600000000" do
      let(:json) { "{\"id\": 1046289770033519442869495707521600000000}" }

      it "should parse corectly" do
        expect(parser).to eql("id" => 1_046_289_770_033_519_442_869_495_707_521_600_000_000)
      end
    end

    # NOTE: we are choosing to be compatible with yajl-ruby here vs. JSON
    # gem and libyajl C behavior (which is to throw an exception in this case)
    context "when the JSON is empty string" do
      let(:json) { '' }

      it "returns nil" do
        expect(parser).to be_nil
      end
    end

    # NOTE: this fixes yajl-ruby being too permissive
    context "when dealing with too much or too little input" do
      context "when trailing braces are missing" do
        let(:json) { '{"foo":{"foo": 1234}' }

        it "raises an exception" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end
      end

      context "when trailing brackets are missing" do
        let(:json) { '[["foo", "bar"]' }

        it "raises an exception" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end
      end

      context "when an extra brace is present" do
        let(:json) { '{"foo":{"foo": 1234}}}' }

        it "raises an exception" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end

        context "with allow_trailing_garbage" do
          let(:options) { { allow_trailing_garbage: true } }
          it "parses" do
            expect(parser).to eq("foo" => { "foo" => 1234 })
          end
        end
      end

      context "when an extra bracket is present" do
        let(:json) { '[["foo", "bar"]]]' }

        it "raises an exception" do
          expect { parser }.to raise_error(FFI_Yajl::ParseError)
        end
      end
    end

    context "when parsing heavy metal umlauts in keys" do
      let(:json) { '{"München": "Bayern"}' }

      it "correctly parses" do
        expect(parser).to eql( "München" => "Bayern" )
      end
    end

    context "when parsing floats" do
      context "parses simple floating point values" do
        let(:json) { '{"foo": 3.14159265358979}' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => 3.14159265358979 )
        end
      end

      context "parses simple negative floating point values" do
        let(:json) { '{"foo":-2.00231930436153}' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => -2.00231930436153 )
        end
      end

      context "parses floats with negative exponents and a large E" do
        let(:json) { '{"foo": 1.602176565E-19}' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => 1.602176565e-19 )
        end
      end

      context "parses floats with negative exponents and a small e" do
        let(:json) { '{"foo": 6.6260689633e-34 }' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => 6.6260689633e-34 )
        end
      end

      context "parses floats with positive exponents and a large E" do
        let(:json) { '{"foo": 6.0221413E+23}' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => 6.0221413e+23 )
        end
      end

      context "parses floats with positive exponents and a small e" do
        let(:json) { '{"foo": 8.9875517873681764e+9 }' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => 8.9875517873681764e+9 )
        end
      end

      context "parses floats with an exponent without a sign and a large E" do
        let(:json) { '{"foo": 2.99792458E8  }' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => 2.99792458e+8 )
        end
      end

      context "parses floats with an exponent without a sign and a small e" do
        let(:json) { '{"foo": 1.0973731568539e7 }' }

        it "correctly parses" do
          expect(parser).to eql( "foo" => 1.0973731568539e+7 )
        end
      end
    end

    # NOTE: parsing floats with 8 million digits on windows has some kind of huge
    #       perf issues likely in ruby and/or the underlying windows libs
    context "when parsing big floats", ruby_gte_193: true, unix_only: true do
      let(:json) { '[0.' + '1' * 2**23 + ']' }

      it "parses" do
        expect { parser }.not_to raise_error
      end
    end

    context "when parsing long hash keys with symbolize_keys option", ruby_gte_193: true do
      let(:json) { '{"' + 'a' * 2**23 + '": 0}' }
      let(:options) { { symbolize_keys: true } }

      it "parses" do
        expect { parser }.not_to raise_error
      end
    end

    context "should ignore repeated keys by default" do
      let(:json) { '{"foo":"bar","foo":"baz"}' }
      it "should replace the first hash key with the second" do
        expect(parser).to eql( "foo" => "baz" )
      end
    end

    context "should raise an exception for repeated keys" do
      let(:json) { '{"foo":"bar","foo":"baz"}' }
      let(:options) { { unique_key_checking: true } }
      it "should raise" do
        expect { parser }.to raise_error(FFI_Yajl::ParseError)
      end
    end
  end

  context "when options are set to empty hash" do
    let(:options) { {} }

    context "when using a parsing object" do
      let(:parser) { FFI_Yajl::Parser.new(options).parse(json) }

      it_behaves_like "correct json parsing"
    end

    context "when using the class method" do
      let(:parser) { FFI_Yajl::Parser.parse(json, options) }

      it_behaves_like "correct json parsing"
    end
  end

  context "when options are set to nil" do
    let(:options) { nil }

    context "when using a parsing object" do
      let(:parser) { FFI_Yajl::Parser.new(options).parse(json) }

      it_behaves_like "correct json parsing"
    end

    context "when using the class method" do
      let(:parser) { FFI_Yajl::Parser.parse(json, options) }

      it_behaves_like "correct json parsing"
    end
  end

  context "when options default to nothing" do
    let(:options) { nil }

    context "when using a parsing object" do
      let(:parser) do
        if options.nil?
          FFI_Yajl::Parser.new.parse(json)
        else
          FFI_Yajl::Parser.new(options).parse(json)
        end
      end

      it_behaves_like "correct json parsing"
    end

    context "when using the class method" do
      let(:parser) do
        if options.nil?
          FFI_Yajl::Parser.parse(json)
        else
          FFI_Yajl::Parser.parse(json, options)
        end
      end

      it_behaves_like "correct json parsing"
    end
  end
end
