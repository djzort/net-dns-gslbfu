#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Checks::Sleep;

use parent qw/ Net::DNS::GslbFu::ChecksBase /;

# give back what we get
sub run {
    my $self = shift;
    my %args = @_;
    sleep $args{duration};
    return 1
}

1
