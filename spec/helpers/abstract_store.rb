require File.dirname(__FILE__) + '/../spec_helper'

describe 'all stores', :shared => true do
  describe "#writable?" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.writable?(:foo) }.should_not raise_error(NotImplementedError)
    end

    it "should accept a conditions hash" do
      @store.writable?('key', :conditions => :hash)
    end
  end

  describe "#read" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.read('foo') }.should_not raise_error(NotImplementedError)
    end

    it "should accept a string key" do
      @store.read('foo')
    end

    it "should accept a symbol key" do
      @store.read(:foo)
    end

    it "should accept a parameters hash" do
      @store.read('foo', :params => :hash)
    end
  end

  describe "#write" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.write('foo', 'bar') }.should_not raise_error(NotImplementedError)
    end

    it "should accept a string key" do
      @store.write('foo', 'bar')
    end

    it "should accept a symbol as a key" do
      @store.write(:foo, :bar)
    end

    it "should accept parameters and conditions" do
      @store.write('foo', 'bar', {:params => :hash}, :conditions => :hash)
    end
  end

  describe "#fetch" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.fetch('foo') {'bar'} }.should_not raise_error(NotImplementedError)
    end

    it "should accept a string key" do
      @store.fetch('foo') { 'bar' }
    end

    it "should accept a symbol as a key" do
      @store.fetch(:foo) { :bar }
    end

    it "should accept parameters and conditions" do
      @store.fetch('foo', {:params => :hash}, :conditions => :hash) { 'bar' }
    end

    it "should accept a value generating block" do
      @store.fetch('foo') {'bar'}
    end

    it "should return the value of the block if it is called" do
      @store.fetch(:boo) { "bar" }.should == "bar" if @store.writable?(:boo)
    end
  end

  describe "#exists?" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.exists?('foo') }.should_not raise_error(NotImplementedError)
    end

    it "should accept a string key" do
      @store.exists?('foo')
    end

    it "should accept a symbol as a key" do
      @store.exists?(:foo)
    end

    it "should accept parameters" do
      @store.exists?('foo', :params => :hash)
    end
  end

  describe "#delete" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.delete('foo') }.should_not raise_error(NotImplementedError)
    end

    it "should accept a string key" do
      @store.delete('foo')
    end

    it "should accept a symbol as a key" do
      @store.delete(:foo)
    end

    it "should accept a parameters hash" do
      @store.delete('foo', :params => :hash)
    end
  end

  describe "#delete_all!" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.delete_all! }.should_not raise_error(NotImplementedError)
    end
  end
end