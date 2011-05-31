require './spec/spec_helper'
require 'tempfile'

describe FakeRiakClient do
  attr_accessor :riak

  shared_examples_for "a key-value store" do
    it "gets an empty list when a key has no value" do
      riak.get("missing_key").should == []
    end

    it "gets an empty list when there is data in riak but not for the given key" do
      riak.add("key", {'x' => 1})
      riak.get("missing_key").should == []
    end

    it "returns nil from add" do
      riak.add("key", {'x' => 1}).should == nil
    end

    it "stores multiple values" do
      value1 = {'x' => 1}
      value2 = {'x' => 2}
      riak.add("key", value1)
      riak.add("key", value2)
      riak.get("key").should =~ [value1, value2]
    end

    it "gives back the json-parsed version of the values" do
      riak.add("key", {:x => 1})
      riak.get("key").should == [{'x' => 1}]
    end
  end

  describe "in-memory storage" do
    before do
      @riak = FakeRiakClient::MemoryStorage.new
    end

    it_behaves_like "a key-value store"
  end

  describe "filesystem storage" do
    before do
      tmp_file = Tempfile.new("fake-riak")
      @tmp_file_path = tmp_file.path
      tmp_file.close
      tmp_file.unlink

      @riak = FakeRiakClient::FileStorage.new(@tmp_file_path)
    end

    after do
      File.unlink(@tmp_file_path) if File.exists?(@tmp_file_path)
    end

    it_behaves_like "a key-value store"

    it "persists the key-value pairs between instances of clients" do
      value = {'x' => 2}
      riak.add("key", value)
      riak.get("key").should =~ [value]

      riak2 = FakeRiakClient::FileStorage.new(@tmp_file_path)
      riak2.get("key").should =~ [value]
    end
  end
end
