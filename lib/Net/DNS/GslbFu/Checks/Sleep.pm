#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Checks::Sleep;

use parent qw/ Net::DNS::GslbFu::ChecksBase /;

# give back what we get
sub run { sleep $_[1]; return 1 }

1
