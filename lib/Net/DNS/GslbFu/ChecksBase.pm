#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::ChecksBase;

use Log::Log4perl;
my $log = Log::Log4perl->get_logger(__PACKAGE__);

sub new {

    my ( $p, @a ) = @_;
    my $c = ref($p) || $p;
    my $self = bless {}, $c;

    $log->debug( sprintf 'Created new %s', $p );

    return $self

}

sub run { return }

1;
