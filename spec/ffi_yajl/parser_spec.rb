# encoding: UTF-8

require 'spec_helper'

describe "FFI_Yajl::Parser" do

  let(:parser) { FFI_Yajl::Parser.new }

  it "throws an exception when trailing braces are missing" do
     json = '{{"foo": 1234}'
     expect { parser.parse(json) }.to raise_error(FFI_Yajl::ParseError)
  end

  it "throws an exception when trailing brackets are missing" do
     json = '[["foo", "bar"]'
     expect { parser.parse(json) }.to raise_error(FFI_Yajl::ParseError)
  end

  it "throws an exception when it has an extra brace" do
     json = '{{"foo": 1234}}}'
     expect { parser.parse(json) }.to raise_error(FFI_Yajl::ParseError)
  end

  it "throws an exception when it has an extra bracket" do
     json = '[["foo", "bar"]]]'
     expect { parser.parse(json) }.to raise_error(FFI_Yajl::ParseError)
  end

  context "when parsing floats" do
    it "parses simple floating point values" do
      json = '{"foo": 3.14159265358979}'
      expect(parser.parse(json)).to eql({"foo" => 3.14159265358979})
    end

    it "parses simple negative floating point values" do
      json = '{"foo":-2.00231930436153}'
      expect(parser.parse(json)).to eql({"foo" => -2.00231930436153})
    end

    it "parses floats with negative exponents and a large E" do
      json = '{"foo": 1.602176565E-19}'
      expect(parser.parse(json)).to eql({"foo" => 1.602176565e-19})
    end

    it "parses floats with negative exponents and a small e" do
      json = '{"foo": 6.6260689633e-34 }'
      expect(parser.parse(json)).to eql({"foo" => 6.6260689633e-34 })
    end

    it "parses floats with positive exponents and a large E" do
      json = '{"foo": 6.0221413E+23}'
      expect(parser.parse(json)).to eql({"foo" => 6.0221413e+23})
    end

    it "parses floats with positive exponents and a small e" do
      json = '{"foo": 8.9875517873681764e+9 }'
      expect(parser.parse(json)).to eql({"foo" => 8.9875517873681764e+9 })
    end

    it "parses floats with an exponent without a sign and a large E" do
      json = '{"foo": 2.99792458E8  }'
      expect(parser.parse(json)).to eql({"foo" => 2.99792458e+8 })
    end

    it "parses floats with an exponent without a sign and a small e" do
      json = '{"foo": 1.0973731568539e7 }'
      expect(parser.parse(json)).to eql({"foo" => 1.0973731568539e+7 })
    end
  end

  context "when parsing unicode in hash keys" do
    it "handles heavy metal umlauts in keys" do
      json = '{"München": "Bayern"}'
      expect(parser.parse(json)).to eql({"München" => "Bayern"})
    end
  end
end

