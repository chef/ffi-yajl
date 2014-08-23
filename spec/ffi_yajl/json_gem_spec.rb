# encoding: UTF-8

# This started life as yajl-ruby's json_gem_compatibility/compatibility_spec.rb file.
# Kinda looks like they stole it from the JSON gem.  I updated the syntax a lot.

require 'spec_helper'
require 'date'

class Dummy; end

describe "JSON Gem Compat API" do

  # Magic to make the before loading tests actually run before loading
  RSpec.configure do |config|
    config.register_ordering(:global) do |list|
      list.sort_by { |item| item.description }
    end
  end

  context "A: before loading the compat library" do
    it "should not mixin #to_json on random objects" do
      d = Dummy.new
      expect(d.respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json to a string" do
      expect("".respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json to a fixnum" do
      expect(1.respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json on a float" do
      expect("1.5".to_f.respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json on an array" do
      expect([].respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json on a hash" do
      expect({ :foo => "bar" }.respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json on a trueclass" do
      expect(true.respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json on a falseclass" do
      expect(false.respond_to?(:to_json)).to be false
    end

    it "should not mixin #to_json on a nilclass" do
      expect(nil.respond_to?(:to_json)).to be false
    end
  end

  context "B: when in compat mode" do

    before(:all) do
      require 'ffi_yajl/json_gem'
    end

    it "should define JSON class" do
      expect(defined?(JSON)).to be_truthy
    end

    it "should implement JSON#parse" do
      expect(JSON.respond_to?(:parse)).to be true
    end

    it "should implement JSON#generate" do
      expect(JSON.respond_to?(:generate)).to be true
    end

    it "should implement JSON#pretty_generate" do
      expect(JSON.respond_to?(:pretty_generate)).to be true
    end

    it "should implement JSON#load" do
      expect(JSON.respond_to?(:load)).to be true
    end

    it "should implement JSON#dump" do
      expect(JSON.respond_to?(:dump)).to be true
    end

    it "JSON#pretty_generate should work with an explicit nil for options" do
      expect(JSON.pretty_generate({'foo' => 1234}, nil)).to eql("{\n  \"foo\": 1234\n}")
    end

    it "JSON#pretty_generate should work without options" do
      expect(JSON.pretty_generate({'foo' => 1234})).to eql("{\n  \"foo\": 1234\n}")
    end

    it "JSON#pretty_generate should work with an empty options hash" do
      expect(JSON.pretty_generate({'foo' => 1234}, {})).to eql("{\n  \"foo\": 1234\n}")
    end

    class Foo
      def to_json(*a)
        {'foo' => 1234}.to_json(*a)
      end
    end

    it "JSON#pretty_generate should work with an Object that implements #to_json" do
      f = Foo.new
      expect(JSON.pretty_generate(f)).to eql("{\n  \"foo\": 1234\n}\n")
    end

    context "when setting symbolize_keys via JSON.default_options" do
      after(:each) { JSON.default_options[:symbolize_keys] = false }

      it "the default behavior should be to not symbolize keys" do
        expect(JSON.parse('{"foo": 1234}')).to eq( "foo" => 1234 )
      end

      it "changing the default_options should change the behavior to true" do
        JSON.default_options[:symbolize_keys] = true
        expect(JSON.parse('{"foo": 1234}')).to eq( :foo => 1234 )
      end
    end

    context "when setting symbolize_names via JSON.default_options" do
      after { JSON.default_options.delete(:symbolize_names)}

      it "the default behavior should be to not symbolize keys" do
        expect(JSON.parse('{"foo": 1234}')).to eq( "foo" => 1234 )
      end

      it "changing the default_options should change the behavior to true" do
        JSON.default_options[:symbolize_names] = true
        expect(JSON.parse('{"foo": 1234}')).to eq( :foo => 1234 )
      end
    end

    it "should support passing symbolize_names to JSON.parse" do
      expect(JSON.parse('{"foo": 1234}', :symbolize_names => true)).to eq( :foo => 1234 )
    end

    it "should support passing symbolize_keys to JSON.parse" do
      expect(JSON.parse('{"foo": 1234}', :symbolize_keys => true)).to eq( :foo => 1234 )
    end

    context "when encode arbitrary classes via their default to_json method" do
      it "encodes random classes correctly" do
        d = Dummy.new
        expect(d.to_json).to eq( %Q{"#{d.to_s}"} )
      end

      context "when encoding Time objects in UTC timezone" do
        before do
          @saved_tz = ENV['TZ']
          ENV['TZ'] = 'UTC'
        end

        after do
          ENV['TZ'] = @saved_tz
        end

        it "encodes Time values correctly" do
          t = Time.local(2001, 02, 02, 21, 05, 06)
          expect(t.to_json).to eq( %Q{"2001-02-02 21:05:06 +0000"} )
        end
      end

      it "encodes Date values correctly" do
        da = Date.parse('2001-02-03')
        expect(da.to_json).to eq( %Q{"2001-02-03"} )
      end

      it "encodes DateTime values correctly" do
        dt = DateTime.parse('2001-02-03T04:05:06.1+07:00')
        expect(dt.to_json).to eq( %Q{"2001-02-03T04:05:06+07:00"} )
      end
    end

    context "JSON exception classes" do
      it "should define JSON::JSONError as a StandardError" do
        expect(JSON::JSONError.new.is_a?(StandardError)).to be true
      end
      it "should define JSON::ParserError as a JSON::JSONError" do
        expect(JSON::ParserError.new.is_a?(JSON::JSONError)).to be true
      end
      it "should define JSON::GeneratorError as a JSON::JSONError" do
        expect(JSON::GeneratorError.new.is_a?(JSON::JSONError)).to be true
      end
      it "should raise JSON::ParserError on a bad parse" do
        expect{ JSON.parse("blah") }.to raise_error(JSON::ParserError)
      end
      it "should raise JSON::GeneratorError on encoding NaN" do
        expect{ JSON.generate(0.0/0.0) }.to raise_error(JSON::GeneratorError)
      end
      it "should raise JSON::GeneratorError on encoding -Infinity" do
        expect{ JSON.generate(-1.0/0.0) }.to raise_error(JSON::GeneratorError)
      end
      it "should raise JSON::GeneratorError on encoding Infinity" do
        expect{ JSON.generate(1.0/0.0) }.to raise_error(JSON::GeneratorError)
      end
      it "should raise JSON::GeneratorError on encoding a partial UTF-8 character" do
        expect{ JSON.generate(["\xea"]) }.to raise_error(JSON::GeneratorError)
      end
    end

    shared_examples_for "handles encoding and parsing correctly" do
      it "should encode the content correctly" do
        expect(ruby.to_json).to eq(json)
      end
      it "should parse the content correctly" do
        expect(JSON.parse(json)).to eq(ruby)
      end
    end

  context "when encoding strings" do
    it "should render empty string correctly" do
      expect(''.to_json).to eq( %q{""} )
    end
    it "should encode backspace character" do
      expect("\b".to_json).to eq( %q{"\\b"} )
    end
    it "should encode \u0001 correctly" do
      expect(0x1.chr.to_json).to eq( %q{"\u0001"} )
    end

    it "should encode \u001f correctly" do
      expect(0x1f.chr.to_json).to eq( %q{"\u001F"} )
    end

    it "should encode a string with a space correctly" do
      expect(' '.to_json).to eq( %q{" "} )
    end

    it "should encode 0x75 correctly" do
      expect(0x7f.chr.to_json).to eq( %Q{"#{0x7f.chr}"} )
    end

    context "when dealing with bignums" do
      let(:ruby) { [ 12345678901234567890 ] }
      let(:json) { "[12345678901234567890]" }

      it_behaves_like "handles encoding and parsing correctly"
    end

    context "when dealing with common UTF-8 symbols" do
      let(:ruby) { [ "© ≠ €! \01" ] }
      let(:json) { "[\"© ≠ €! \\u0001\"]" }

      it_behaves_like "handles encoding and parsing correctly"
    end

    context "when dealing with Hiragana UTF-8 characters" do
      let(:ruby) { ["\343\201\202\343\201\204\343\201\206\343\201\210\343\201\212"] }
      let(:json) { "[\"あいうえお\"]" }

      it_behaves_like "handles encoding and parsing correctly"
    end

    context "whatever this is" do
      let(:ruby) { ['საქართველო'] }
      let(:json) { "[\"საქართველო\"]" }

      it_behaves_like "handles encoding and parsing correctly"
    end

    context "accents" do
      let(:ruby) { ["Ã"] }
      let(:json) { '["Ã"]' }

      it_behaves_like "handles encoding and parsing correctly"
    end

    context "euro symbol" do
      let(:ruby) { ["€"] }
      let(:json) { '["\u20ac"]' }
      it "should parse the content correctly" do
        expect(JSON.parse(json)).to eq(ruby)
      end
    end

    context "and whatever this is" do

      utf8_str = "\xf0\xa0\x80\x81"
      let(:ruby) {  [utf8_str] }
      let(:json) { "[\"#{utf8_str}\"]" }

      it_behaves_like "handles encoding and parsing correctly"
    end
  end

    context "when encoding basic types with #to_json" do
      it "Array#to_json should work" do
        expect([ "a", "b", "c" ].to_json).to eq(%Q{["a","b","c"]})
      end

      it "Hash#to_json should work" do
        expect({ "a"=>"b" }.to_json).to eq(%Q{{"a":"b"}})
      end

      it "Fixnum#to_json should work" do
        expect(1.to_json).to eq("1")
      end

      it "Float#to_json should work" do
        expect(1.1.to_json).to eq("1.1")
      end

      it "String#to_json should work" do
        expect("foo".to_json).to eq(%Q{"foo"})
      end

      it "TrueClass#to_json should work" do
        expect(true.to_json).to eq("true")
      end

      it "FalseClass#to_json should work" do
        expect(false.to_json).to eq("false")
      end

      it "NilClass#to_json should work" do
        expect(nil.to_json).to eq("null")
      end
    end

    context "ported tests for generation" do
      before(:all) do
        @hash = {
          'a' => 2,
          'b' => 3.141,
          'c' => 'c',
          'd' => [ 1, "b", 3.14 ],
          'e' => { 'foo' => 'bar' },
          'g' => "blah",
          'h' => 1000.0,
          'i' => 0.001,
        }

        @json2 = '{"a":2,"b":3.141,"c":"c","d":[1,"b",3.14],"e":{"foo":"bar"},"g":"blah","h":1000.0,"i":0.001}'

        @json3 = %{
        {
          "a": 2,
          "b": 3.141,
          "c": "c",
          "d": [1, "b", 3.14],
          "e": {"foo": "bar"},
          "g": "blah",
          "h": 1000.0,
          "i": 0.001
        }
        }.chomp
      end

      it "should be able to unparse" do
        json = JSON.generate(@hash)
        expect(JSON.parse(@json2)).to eq(JSON.parse(json))
        parsed_json = JSON.parse(json)
        expect(@hash).to eq(parsed_json)
        json = JSON.generate( 1=>2 )
        expect('{"1":2}').to eql(json)
        parsed_json = JSON.parse(json)
        expect( "1"=>2 ).to eq(parsed_json)
      end

      it "should be able to unparse pretty" do
        json = JSON.pretty_generate(@hash)
        expect(JSON.parse(@json3)).to eq(JSON.parse(json))
        parsed_json = JSON.parse(json)
        expect(@hash).to eq(parsed_json)
        json = JSON.pretty_generate( 1=>2 )
        test = "{\n  \"1\": 2\n}".chomp
        expect(test).to eq(json)
        parsed_json = JSON.parse(json)
        expect( "1"=>2 ).to eq(parsed_json)
      end

      it "JSON.generate should handle nil second argument" do
        expect(JSON.generate(["foo"], nil)).to eql(%q{["foo"]})
      end
    end
  end
end
