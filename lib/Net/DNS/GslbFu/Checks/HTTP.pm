#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Checks::HTTP;

use parent qw/ Net::DNS::GslbFu::ChecksBase /;

use HTTP::Tiny;

my $http = HTTP::Tiny->new();

sub run {

    my $self = shift;
    my %args = @_;
    my $url = $args{url};

    $self->log->debug(sprintf 'Trying %s', $url);

    my $response = $http->get($url);

    $self->log->debug(sprintf 'Status %d', $response->{status});

    return $response->{success} ? 1 : 0;

}

1
