# net-dns-gslbfu
Net::DNS::GslbFu

This is a simple program/framework designed for Global Server Load Balancing,
but could be used for other tasks as its super generic.

Here is the basic logic.

 * Checks are run and their results are saved
 * Actions are run based on those results
 * Repeat

Going beyond that.

 * Checks and Actions are all plugins
 * Their behaviour is customized via config file
 * Checks can aggregate other Checks
 * Checks and Actions can be used over and over

Results of Checks are stored using CHI, so they can be stored in memory,
shared memory, Redis, Memcached, anything DBI or even files. If it's a
sensible choice is left to you the user.

Everything logs via Log4perl.

Config file is via Config::Any so pick your poison.
