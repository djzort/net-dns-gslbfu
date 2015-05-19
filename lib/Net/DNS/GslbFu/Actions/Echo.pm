#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Actions::Echo;

use parent qw/ Net::DNS::GslbFu::ActionsBase /;

sub run {

    my $self = shift;
    my %args = @_;
    print 'ECHO: ', $args{message}, "\n";
    return 1

}

1

