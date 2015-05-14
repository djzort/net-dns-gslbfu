#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Checks::LastResort;

use parent qw/ Net::DNS::GslbFu::ChecksBase /;

# always true
sub run { return 1 }

1
