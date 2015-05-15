#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::ChecksBase;

use Log::Log4perl;

sub new {

    my ( $p, @a ) = @_;
    my $c = ref($p) || $p;
    my $self = bless {}, $c;

    $self->log->debug( 'I\'m here' );

    return $self

}

sub run { return }

sub log {

    my $self = shift;

    return Log::Log4perl->get_logger(ref $self);

}

1;
