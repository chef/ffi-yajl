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
require 'date'

describe "FFI_Yajl::Encoder" do
  let(:options) { {} }

  let(:encoder) { FFI_Yajl::Encoder.new(options) }

  it "encodes hashes in keys as strings", ruby_gte_193: true do
    ruby = { { 'a' => 'b' } => 2 }
    expect(encoder.encode(ruby)).to eq('{"{\"a\"=>\"b\"}":2}')
  end

  it "encodes arrays in keys as strings", ruby_gte_193: true do
    ruby = { [0, 1] => 2 }
    expect(encoder.encode(ruby)).to eq('{"[0, 1]":2}')
  end

  it "encodes nil in keys as strings" do
    ruby = { nil => 2 }
    expect(encoder.encode(ruby)).to eq('{"":2}')
  end

  it "encodes true in keys as strings" do
    ruby = { true => 2 }
    expect(encoder.encode(ruby)).to eq('{"true":2}')
  end

  it "encodes false in keys as strings" do
    ruby = { false => 2 }
    expect(encoder.encode(ruby)).to eq('{"false":2}')
  end

  it "encodes fixnums in keys as strings" do
    ruby = { 1 => 2 }
    expect(encoder.encode(ruby)).to eq('{"1":2}')
  end

  it "encodes floats in keys as strings" do
    ruby = { 1.1 => 2 }
    expect(encoder.encode(ruby)).to eq('{"1.1":2}')
  end

  it "encodes bignums in keys as strings" do
    ruby = { 12_345_678_901_234_567_890 => 2 }
    expect(encoder.encode(ruby)).to eq('{"12345678901234567890":2}')
  end

  it "encodes objects in keys as strings" do
    o = Object.new
    ruby = { o => 2 }
    expect(encoder.encode(ruby)).to eq(%{{"#{o}":2}})
  end

  it "encodes an object in a key which has a #to_json method as strings" do
    class Thing
      def to_json(*a)
        "{}"
      end
    end
    o = Thing.new
    ruby = { o => 2 }
    expect(encoder.encode(ruby)).to eq(%{{"#{o}":2}})
  end

  # XXX: 127 == YAJL_MAX_DEPTH hardcodedness, zero control for us, it isn't even a twiddleable #define
  it "raises an exception for deeply nested arrays" do
    root = []
    a = root
    127.times { |_| a << []; a = a[0] }
    expect { encoder.encode(root) }.to raise_error(FFI_Yajl::EncodeError)
  end

  it "raises an exception for deeply nested hashes" do
    root = {}
    a = root
    127.times { |_| a["a"] = {}; a = a["a"] }
    expect { encoder.encode(root) }.to raise_error(FFI_Yajl::EncodeError)
  end

  it "encodes symbols in keys as strings" do
    ruby = { thing: 1 }
    expect(encoder.encode(ruby)).to eq('{"thing":1}')
  end

  it "encodes symbols in values as strings" do
    ruby = { "thing" => :one }
    expect(encoder.encode(ruby)).to eq('{"thing":"one"}')
  end

  it "can encode 32-bit unsigned ints" do
    ruby = { "gid" => 4_294_967_294 }
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
    expect(encoder.encode(ruby)).to eq( '"2001-02-03"' )
  end

  it "can encode StringIOs" do
    ruby = { "foo" => StringIO.new('THING') }
    expect(encoder.encode(ruby)).to eq("{\"foo\":\"THING\"}")
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
      expect(encoder.encode(ruby)).to eq( '"2001-02-02 21:05:06 +0000"' )
    end
  end

  it "can encode DateTime objects" do
    ruby = DateTime.parse('2001-02-03T04:05:06.1+07:00')
    expect(encoder.encode(ruby)).to eq( '"2001-02-03T04:05:06+07:00"' )
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

  context "when encoding invalid utf-8" do
    ruby = {
      "automatic" => {
        "etc" => {
          "passwd" => {
            "root" => { "dir" => "/root", "gid" => 0, "uid" => 0, "shell" => "/bin/sh", "gecos" => "Elan Ruusam\xc3\xa4e" },
            "glen" => { "dir" => "/home/glen", "gid" => 500, "uid" => 500, "shell" => "/bin/bash", "gecos" => "Elan Ruusam\xE4e" },
            "helmüt" => { "dir" => "/home/helmüt", "gid" => 500, "uid" => 500, "shell" => "/bin/bash", "gecos" => "Hañs Helmüt" },
          },
        },
      },
    }

    it "raises an error on invalid json" do
      expect { encoder.encode(ruby) }.to raise_error(FFI_Yajl::EncodeError, /Invalid UTF-8 string 'Elan Ruusam.*': cannot encode to UTF-8/)
    end

    context "when validate_utf8 is off" do
      let(:options) {  { validate_utf8: false } }

      it "does not raise an error" do
        expect { encoder.encode(ruby) }.not_to raise_error
      end

      it "returns utf8" do
        expect( encoder.encode(ruby).encoding ).to eq(Encoding::UTF_8)
      end

      it "returns valid utf8" do
        expect( encoder.encode(ruby).valid_encoding? ).to be true
      end

      it "does not mangle valid utf8" do
        json = encoder.encode(ruby)
        expect(json).to match(/Hañs Helmüt/)
      end

      it "does not grow after a round trip" do
        json = encoder.encode(ruby)
        ruby2 = FFI_Yajl::Parser.parse(json)
        json2 = encoder.encode(ruby2)
        expect(json).to eql(json2)
      end
    end
  end
end
