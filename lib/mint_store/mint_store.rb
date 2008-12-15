module Merb::Cache
  class MintStore < AbstractStrategyStore
    attr_accessor :options
    
    def initialize(config = {})
      @options = {:refresh_delay => 30, :mint_delay => 30, :expire_in => 300}
      @options.merge!(config.only(:refresh_delay, :mint_delay, :expire_in, :force_delete, :need_expire_in))
      config.extract!(:refresh_delay, :mint_delay, :expire_in, :force_delete, :need_expire_in)
      super(config)
    end
    
    def writable?(key, parameters = {}, conditions = {})
      return false if options[:need_expire_in] && !conditions.has_key?(:expire_in)
      
      conditions = conditions.dup
      get_metadata_and_normalize!(conditions)
      @stores.any? {|c| c.writable?(key, parameters, conditions)}
    end

    def read(key, parameters = {})
      packed_data = store_read(key, parameters)
      return nil unless packed_data
      
      data, refresh_time, refreshed = *packed_data
      if !refreshed && (Time.now > refresh_time) 
        write(key, data, parameters, :expire_in => 0, :refreshed => true)
        return nil
      end
      data
    end

    def write(key, data = nil, parameters = {}, conditions = {})
      if writable?(key, parameters, conditions)
        metadata = get_metadata_and_normalize!(conditions)
        @stores.capture_first {|c| c.write(key, metadata.unshift(data), parameters, conditions)}
      end
    end

    def write_all(key, data = nil, parameters = {}, conditions = {})      
      if writable?(key, parameters, conditions)
        metadata = get_metadata_and_normalize!(conditions)
        @stores.map {|c| c.write_all(key, metadata.unshift(data), parameters, conditions)}.all?
      end
    end


    # This fetch is a bit different in that it returns directly the stale copy of the cache and the after the request is served, it updates the cache
    def fetch(key, parameters = {}, conditions = {}, &blk)
      return false unless writable?(key, parameters, conditions)
      
      packed_data = store_read(key, parameters)
      metadata = get_metadata_and_normalize!(conditions)
      
      insert_metadata = Proc.new do
        metadata.unshift(blk.call)
      end
      
      unless packed_data
        return (@stores.capture_first {|c| c.fetch(key, parameters, conditions, &insert_metadata)})[0]
      end
      
      data, refresh_time, refreshed = *packed_data
      if !refreshed && (Time.now > refresh_time)
        write(key, data, parameters, conditions.merge(:expire_in => 0, :refreshed => true))
        Merb.run_later do
          @stores.capture_first {|c| c.write(key, insert_metadata.call, parameters, conditions)}
        end
      end
      data
    end

    def exists?(key, parameters = {})
      @stores.capture_first {|c| c.exists?(key, parameters)}
    end

    # We do not delete the cache, we just make it stale so that it will be repopulated the next time fetch is called
    # I'm not completely sure this is a good idea though... in particular it's not going to play well with write_all
    # Anyhow if MintStore is inialized with :force_delete => true it behaves normally
    def delete(key, parameters = {})
      return delete!(key,parameters) if options[:force_delete]
      return false unless writable?(key, parameters, :expire_in => 0)
      
      packed_data = store_read(key, parameters)
      return nil unless packed_data      
      data = packed_data[0]

      write(key, data, parameters, :expire_in => 0)
    end

    def delete!(key, parameters = {})
      @stores.map {|c| c.delete(key, parameters)}.any?
    end

    def delete_all!
      @stores.map {|c| c.delete_all! }.all?
    end
    
 protected

    def get_metadata_and_normalize!(conditions = {})
      refresh_delay, mint_delay, expire_in, refreshed = conditions.extract!(:refresh_delay, :mint_delay, :expire_in, :refreshed)
      expire_in ||= options[:expire_in]
      
      if refreshed
        conditions[:expire_in] = expire_in + (refresh_delay || options[:refresh_delay])
      else
        conditions[:expire_in] = expire_in + (mint_delay || options[:mint_delay])
      end
      [Time.now +  expire_in, refreshed]
    end

    def store_read(key, parameters = {})
      @stores.capture_first {|c| c.read(key, parameters)}
    end
  end
end
