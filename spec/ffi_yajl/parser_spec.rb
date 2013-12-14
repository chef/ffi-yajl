

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

end

