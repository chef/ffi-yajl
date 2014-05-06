# encoding: UTF-8

require 'spec_helper'

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

end

