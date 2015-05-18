#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Actions::RFC2136;

use parent qw/ Net::DNS::GslbFu::ActionsBase /;

use Net::DNS;
use Data::Dumper;

=HEAD2 SEE ALSO

L<http://search.cpan.org/~nlnetlabs/Net-DNS-0.83/lib/Net/DNS/Update.pm>

L<and http://jpmens.net/2012/06/21/powerdns-with-support-for-rfc-2136-dynamic-dns/>

L<https://doc.powerdns.com/html/dnsupdate.html>

=cut

sub run {

    my $self = shift;
    my $opts = shift;

    $self->log->debug(Dumper $opts);

    $self->log->debug(sprintf 'Trying %s for %s',
        $opts->{nameserver},$opts->{domain});

    my $resolver = Net::DNS::Resolver->new;
    $resolver->nameservers($opts->{nameserver});
    my $update = Net::DNS::Update->new($opts->{domain});

    $update->push( update => rr_del($opts->{name}) );
    $update->push( update => rr_add(
        sprintf('%s %d %s %s', $opts->{name},
            $opts->{ttl},
            $opts->{type},
            $opts->{content})
            ));

    my $reply = $resolver->send($update);

    # Did it work?
    if ($reply) {
            if ( $reply->header->rcode eq 'NOERROR' ) {
                    $self->log->debug( 'Update succeeded');
                    return 1
            }
            else {
                    $self->log->debug( 'Update failed: ', $reply->header->rcode );
                    return 0
            }
    }

    $self->log->debug( 'Update failed: ', $resolver->errorstring );
    return 0

}

1

