#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Actions::Echo;

use parent qw/ Net::DNS::GslbFu::ActionsBase /;

sub run {

    my $self = shift;
    print 'ECHO: ', @_, "\n";
    return 1

}

1

