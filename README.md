More Information
----------------

More detailed information is available at <http://gom-jabbar.org/articles/2008/12/15/introducing-mint-store-a-strategic-store-for-merb-cache>


Mint Store is...
----------------

It's basically a port of Disqus MintCache with two additionnal features:
 -  When you use fetch (and provide a block), if the cache is stale, Mint Store will return the stale cache and update the cache (with the result of executing the provided block) after the request has been served using `Merb.run_later`
 -  Deletion will just mark the cache as stale which will cause the next fetch to repopulate the cache.

Read and Fetch
--------------

Read returns nil the first time the cache becomes stale and then returns the stale cache for `:mint_delay` seconds. 

So on the contrary to using fetch where none of the clients will be penalized, if you use read, you will penalize one clients who will have to wait for the cache to be refreshed before his request is served.

Note: `fetch_fragment` and `fetch_partial` from merb-cache both use `fetch`

Initialization Options
----------------------

Mint Store accepts several initialization options:
 -  Behaviour options:
    -  `:force_delete` if set to true, delete will just delete the data from the cache
    -  `:need_expire_in` if set to true, writable? will return false if the `:expire_in` condition is not present. If you are going to use MintStore with the AdHocStore it makes sense to set it.
 -  Default values:
    - :mint_delay : the difference between the stale date (that you provide by `:expire_in`) and the real `:expire_in` given to memcached (default: 30s)
    - :refresh_delay : the `:expire_in` value given to memcached while regenerating the cache (can set to 0 if you want memcache to never expire the stale cache while waiting for it to be refreshed)
    - :expire_in  : default value for the stale date if not provided (default: 300s)
 
Example: setting the options

<code:ruby>
        register(:memcached_store, Merb::Cache::MemcachedStore)
        register(:mint_store, Merb::Cache::MintStore[:memcached_store], :need_expire_in => true, :refresh_delay => 0)
</code>

