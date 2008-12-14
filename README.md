Mint Store is...
----------------

It's basically a port of Disqus simple mint cache with two additionnal features:
 -  When you use fetch (and provide a block), if the cache is stale, Mint Store will return the stale cache and update the cache (with the result of executing the provided block) after the request has been served using `Merb.run_later`
 -  Deletion will just mark the cache as stale which will cause the next fetch to repopulate the cache.

Read and Fetch
--------------

Read returns nil the first time the cache becomes stale and then returns the stale cache for `:mint_delay` seconds. 

So on the contrary to using fetch where none of the clients will be penalized, if you use read, you will penalize one clients who will have to wait for the cache to be refreshed before his request is served.

Note: `fetch_fragment` and `fetch_partial` from merb-cache both use `fetch`


