require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/helpers/abstract_strategy_store'

module Merb
  def self.to_run
    @to_run || []
  end
  
  def self.run_later(&blk)
    (@to_run ||= []) << blk
  end
end  



describe Merb::Cache::MintStore do
  it_should_behave_like 'all strategy stores'

  before(:each) do
    @klass = Merb::Cache::MintStore
    Merb::Cache.register(:dummy, DummyStore)
    @store = Merb::Cache::MintStore[:dummy].new
    @dummy = Merb::Cache[:dummy]
  end
  
  

  describe "#writable?" do
    it "should be false if none of the context caches are writable" do
      @dummy.should_receive(:writable?).and_return false
      @store.writable?(:foo).should be_false
    end
  end
  
  describe "#read" do
    it "should return nil if if the key does not exist" do
      @dummy.should_receive(:read).and_return nil
      @store.read(:foo, :bar => :baz).should be_nil
    end
  
    it "when the cache become stale, should return nil and reset the cache refreshed to true" do
      @store.should_receive(:get_metadata_and_normalize!).with(:expire_in => 0, :refreshed => true).and_return([:refresh_time, :refreshed])
      @dummy.should_receive(:read).with(:key, {}).and_return [:data, Time.now, false]
      @dummy.should_receive(:write).with(:key, [:data, :refresh_time, :refreshed], {}, {:refreshed=>true, :expire_in=>0}).and_return true
      @store.read(:key).should == nil
    end 
    
    it "when the cache has been refreshed, should return the stale cache" do
      @dummy.should_receive(:read).and_return [:data, Time.now, true]
      @store.read(:key).should == :data
    end
  end
  
  
  describe "#write" do
    it "should add the [refresh_time, refreshed] metadata to the data" do
      current_time = Time.now
      Time.should_receive(:now).and_return(current_time)

     @dummy.should_receive(:write).with(:key, ['body', current_time + @store.options[:expire_in], nil], {}, {:expire_in =>  @store.options[:expire_in] + @store.options[:mint_delay]}).and_return true
    
      @store.write(:key, 'body').should be_true
    end
  end
  
  describe "#fetch" do
    before(:each) do
      Merb.to_run.clear
    end
    
    it "should call the block when there is no cache" do
      blk = Proc.new {:data}
      @store.fetch(:key,{}, {}, &blk).should == :data
      @dummy.data(:key)[0].should == :data
    end
    
    it "should just return the cache if it's not stale" do
      blk = Proc.new {:new_data}
      @dummy.should_receive(:read).and_return [:data, Time.now + 200, nil]
      @store.fetch(:key,{}, {}, &blk).should == :data
    end
    
    it "should return the stale data and repopulate the cache after the request" do
      blk = Proc.new {:new_data}
      @dummy.should_receive(:read).and_return [:data, Time.now, nil]
      @store.should_receive(:get_metadata_and_normalize!).with({}).and_return([:refresh_time, nil])
      @store.should_receive(:get_metadata_and_normalize!).with({:expire_in => 0, :refreshed => true}).and_return([:refresh_time, true])
      @store.fetch(:key,{}, {}, &blk).should == :data
      @dummy.should_receive(:write).with(:key, [:new_data, :refresh_time, nil], {}, {})
      Merb.to_run.first.call
    end
  end
  
  describe "#delete" do
    it "should make the cache stale by default" do
      @store.write(:key, 'body', {:bar => :baz})
      @dummy.data(:key, :bar => :baz)[1].should > Time.now
      @store.delete(:key, {:bar => :baz})
      @dummy.vault[:key][1][0][1].should < Time.now
    end
    
    it "should delete normaly if :force_delete is true" do
      @store.options[:force_delete] = true
      @dummy.should_receive(:delete).with(:key, {:bar => :baz})
      @store.delete(:key, {:bar => :baz})
    end
  end
  
  describe "protected methods" do
    describe "#get_metadata_and_normalize!" do
      it "should delete its options from the conditions hash" do
        hash = {:expire_in => 20, :refreshed => true, :mint_delay => 50, :refresh_delay => 30}
        @store.send(:get_metadata_and_normalize!, hash)
        hash.should == {:expire_in => 50}
      end
      
      it "should use add :mint_delay to :expire_in when :refreshed is not true" do
        hash = {:expire_in => 20, :mint_delay => 50, :refresh_delay => 30}
        @store.send(:get_metadata_and_normalize!, hash)
        hash.should == {:expire_in => 70}        
      end
      
      it "should use the defaults set at store creation" do
        current_time = Time.now
        Time.should_receive(:now).and_return(current_time)
        new_store = Merb::Cache::MintStore[:dummy].new(:mint_delay => 10, :expire_in => 500)
        hash = {}
        new_store.send(:get_metadata_and_normalize!, hash).should == [current_time + 500, nil]
        hash[:expire_in].should == 510
      end
    end
  end
end