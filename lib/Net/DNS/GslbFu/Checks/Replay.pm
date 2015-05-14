#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Checks::Replay;

use parent qw/ Net::DNS::GslbFu::ChecksBase /;

# give back what we get
sub run { return $_[1] }

1
