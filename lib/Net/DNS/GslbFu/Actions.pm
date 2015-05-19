#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Actions;

use Log::Log4perl;
use Module::Pluggable::Object;
#use namespace::autoclean;

my $log = Log::Log4perl->get_logger(__PACKAGE__);

sub new {

    my ( $p, @a ) = @_;
    my $c = ref($p) || $p;
    my $self = bless { plugins => [] }, $c;

    $self->reload();

    return $self

}

sub reload {

    my $self = shift;

    my %opts = (
        search_path => __PACKAGE__,
        # except => 'OIETS::Action::Base',
        require => 1,
    );

    $log->debug( 'Loading Actons...' );

    $self->{plugins} = { map {
        +( do { my $p = __PACKAGE__; my $f = $_; $f =~ s/^${p}:://; $f } => $_->new() )
        } Module::Pluggable::Object->new(%opts)->plugins() };

    $log->debug( 'Loaded Actions: '
                . join ', ', keys %{$self->{plugins}});

}

sub has { my $self = shift; return $_[0] && $self->{plugins}->{$_[0]} }

sub run {

    my $self = shift;
    my $plugin = shift;
    my @args = @_;

    die 'Cannot run an unnamed action plugin?' unless $plugin;
    die 'Unknown action plugin: ' , $plugin unless $self->has($plugin);

    return $self->{plugins}->{ $plugin }->run( @args )

}

1
