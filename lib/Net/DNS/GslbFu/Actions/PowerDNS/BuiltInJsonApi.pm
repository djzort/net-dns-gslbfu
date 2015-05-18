#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Actions::PowerDNS::BuiltInJsonApi;

use parent qw/ Net::DNS::GslbFu::ActionsBase /;

use HTTP::Tiny;
use Data::Dumper;

my $http = HTTP::Tiny->new();

sub run {

    my $self = shift;
    my $opts = shift;

    $self->log->debug(Dumper $opts);

    $self->log->debug(sprintf 'Trying %s', $opts->{url});

    my $response = $http->request( 'PATCH', $opts->{url},
                {
                    headers => { 'X-API-Key' => $opts->{key} },
                    content => sprintf(
'{ "rrsets":
  [
    {
      "name": "%1$s",
      "type": "%2$s",
      "changetype": "REPLACE",
      "records":
        [
          {
            "name": "%1$s",
            "type": "%2$s",
            "content": "%3$s",
            "ttl": %4$d,
            "disabled": false
          }
        ]
    }
  ]
}',
$opts->{name},
$opts->{type},
$opts->{content},
$opts->{ttl} )

                });

    $self->log->debug(sprintf 'Status %d', $response->{status});
    $self->log->debug(Dumper $response);

    return $response->{success} ? 1 : 0;

}


1
