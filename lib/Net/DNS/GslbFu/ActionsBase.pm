#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::ActionsBase;

sub new {

    my ( $p, @a ) = @_;
    my $c = ref($p) || $p;
    my $self = bless {}, $c;

    return $self

}

sub run { return }

1;
