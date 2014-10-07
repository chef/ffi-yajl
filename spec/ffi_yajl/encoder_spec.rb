# encoding: UTF-8

require 'spec_helper'
require 'date'

describe "FFI_Yajl::Encoder" do

  let(:encoder) { FFI_Yajl::Encoder.new }

  it "encodes fixnums in keys as strings" do
    ruby = { 1 => 2 }
    expect(encoder.encode(ruby)).to eq('{"1":2}')
  end

  it "encodes floats in keys as strings" do
    ruby = { 1.1 => 2 }
    expect(encoder.encode(ruby)).to eq('{"1.1":2}')
  end

  it "encodes bignums in keys as strings" do
    ruby = { 12345678901234567890 => 2 }
    expect(encoder.encode(ruby)).to eq('{"12345678901234567890":2}')
  end

  # XXX: 127 == YAJL_MAX_DEPTH hardcodedness, zero control for us, it isn't even a twiddleable #define
  it "raises an exception for deeply nested arrays" do
    root = []
    a = root
    127.times { |_| a << []; a = a[0] }
    expect{ encoder.encode(root) }.to raise_error(FFI_Yajl::EncodeError)
  end

  it "raises an exception for deeply nested hashes" do
    root = {}
    a = root
    127.times {|_| a["a"] = {}; a = a["a"] }
    expect{ encoder.encode(root) }.to raise_error(FFI_Yajl::EncodeError)
  end

  it "encodes symbols in keys as strings" do
    ruby = { :thing => 1 }
    expect(encoder.encode(ruby)).to eq('{"thing":1}')
  end

  it "encodes symbols in values as strings" do
    ruby = { "thing" => :one }
    expect(encoder.encode(ruby)).to eq('{"thing":"one"}')
  end

  it "can encode 32-bit unsigned ints" do
    ruby = { "gid"=>4294967294 }
    expect(encoder.encode(ruby)).to eq('{"gid":4294967294}')
  end

  context "when the encoder has nil passed in for options" do
    let(:encoder) { FFI_Yajl::Encoder.new(nil) }

    it "does not throw an exception" do
      ruby = { "foo" => "bar" }
      expect(encoder.encode(ruby)).to eq("{\"foo\":\"bar\"}")
    end
  end

  it "can encode Date objects" do
    ruby = Date.parse('2001-02-03')
    expect(encoder.encode(ruby)).to eq( %q{"2001-02-03"} )
  end

  context "when encoding Time objects in UTC timezone" do
    before do
      @saved_tz = ENV['TZ']
      ENV['TZ'] = 'UTC'
    end

    after do
      ENV['TZ'] = @saved_tz
    end

    it "encodes them correctly" do
      ruby = Time.local(2001, 02, 02, 21, 05, 06)
      expect(encoder.encode(ruby)).to eq( %q{"2001-02-02 21:05:06 +0000"} )
    end
  end

  it "can encode DateTime objects" do
    ruby = DateTime.parse('2001-02-03T04:05:06.1+07:00')
    expect(encoder.encode(ruby)).to eq( %q{"2001-02-03T04:05:06+07:00"} )
  end

  describe "testing .to_json for Objects" do
    class NoToJson; end
    class HasToJson
      def to_json(*args)
        "{}"
      end
    end

    it "calls .to_s for objects without .to_json" do
      expect(encoder.encode(NoToJson.new)).to match(/^"#<NoToJson:\w+>"$/)
    end

    it "calls .to_json for objects wit .to_json" do
      expect(encoder.encode(HasToJson.new)).to eq("{}")
    end
  end

end
