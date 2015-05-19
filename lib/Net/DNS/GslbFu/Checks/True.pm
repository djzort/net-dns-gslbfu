#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Checks::True;

use parent qw/ Net::DNS::GslbFu::ChecksBase /;

# give back what we get
sub run { return 1 }

1
