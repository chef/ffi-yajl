
require 'spec_helper'
require 'ffi_yajl/json_gem'

class Dummy; end

describe "JSON Gem Compat API" do
#  it "shoud not mixin #to_json on base objects until compatability has been enabled" do
#    d = Dummy.new
#
#    expect(d.respond_to?(:to_json)).to_not be_true
#    expect("".respond_to?(:to_json)).to_not be_true
#    expect(1.respond_to?(:to_json)).to_not be_true
#    expect("1.5".to_f.respond_to?(:to_json)).to_not be_true
#    expect([].respond_to?(:to_json)).to_not be_true
#    expect({:foo => "bar"}.respond_to?(:to_json)).to_not be_true
#    expect(true.respond_to?(:to_json)).to_not be_true
#    expect(false.respond_to?(:to_json)).to_not be_true
#    expect(nil.respond_to?(:to_json)).to_not be_true
#  end

  it "should mixin #to_json on base objects after compatability has been enabled" do
    d = Dummy.new

    expect(d.respond_to?(:to_json)).to be_true
    expect("".respond_to?(:to_json)).to be_true
    expect(1.respond_to?(:to_json)).to be_true
    expect("1.5".to_f.respond_to?(:to_json)).to be_true
    expect([].respond_to?(:to_json)).to be_true
    expect({:foo => "bar"}.respond_to?(:to_json)).to be_true
    expect(true.respond_to?(:to_json)).to be_true
    expect(false.respond_to?(:to_json)).to be_true
    expect(nil.respond_to?(:to_json)).to be_true
  end

  it "should require yajl/json_gem to enable the compatability API" do
    expect(defined?(JSON)).to be_true

    expect(JSON.respond_to?(:parse)).to be_true
    expect(JSON.respond_to?(:generate)).to be_true
    expect(JSON.respond_to?(:pretty_generate)).to be_true
    expect(JSON.respond_to?(:load)).to be_true
    expect(JSON.respond_to?(:dump)).to be_true
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
        'i' => 0.001
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
      json = JSON.generate({1=>2})
      expect('{"1":2}').to eql(json)
      parsed_json = JSON.parse(json)
      expect({"1"=>2}).to eq(parsed_json)
    end

    it "should be able to unparse pretty" do
      json = JSON.pretty_generate(@hash)
      expect(JSON.parse(@json3)).to eq(JSON.parse(json))
      parsed_json = JSON.parse(json)
      expect(@hash).to eq(parsed_json)
      json = JSON.pretty_generate({1=>2})
      test = "{\n  \"1\": 2\n}".chomp
      expect(test).to eq(json)
      parsed_json = JSON.parse(json)
      expect({"1"=>2}).to eq(parsed_json)
    end
  end

end
