# encoding: UTF-8

require 'spec_helper'

describe "FFI_Yajl::Encoder" do

  let(:encoder) { FFI_Yajl::Encoder.new }

  it "encodes fixnums in keys as strings" do
    ruby = {1 => 2}
    expect(encoder.encode(ruby)).to eq('{"1":2}')
  end

  it "encodes floats in keys as strings" do
    ruby = {1.1 => 2}
    expect(encoder.encode(ruby)).to eq('{"1.1":2}')
  end

  it "encodes bignums in keys as strings" do
    ruby = {12345678901234567890 => 2}
    expect(encoder.encode(ruby)).to eq('{"12345678901234567890":2}')
  end
end

