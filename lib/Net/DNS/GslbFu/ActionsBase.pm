#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::ActionsBase;

use Log::Log4perl;

sub new {

    my ( $p, @a ) = @_;
    my $c = ref($p) || $p;
    my $self = bless {}, $c;

    $self->log->debug( 'I\'m here' );

    return $self

}

sub run { die 'Check didnt implement &run' }

sub log {

    my $self = shift;

    return Log::Log4perl->get_logger(ref $self);

}

sub checkcfg { die 'Check didnt implement &checkcfg' }

1;
