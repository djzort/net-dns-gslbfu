#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu::Checks;

use Module::Pluggable::Object;
use Data::Dumper;
#use namespace::autoclean;

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

    # FIXME? this should probably go in to OIETS::ActionBase, so they magically register themselves
    $self->{plugins} = { map {
        +( do { my $p = __PACKAGE__; my $f = $_; $f =~ s/^${p}:://; $f } => $_->new() )
        } Module::Pluggable::Object->new(%opts)->plugins() };
#    register_plugin $_ for @plugins;
#    $_->register for @plugins;

    print Dumper $self->{plugins};

}

sub has { my $self = shift; return $_[0] && $self->{plugins}->{$_[0]} }

sub run {

    my $self = shift;
    my $plugin = shift;
    my @args = @_;

    die 'Cannot run an unnamed check plugin?' unless $plugin;
    die 'Unknown check plugin: ' , $plugin unless $self->has($plugin);

    return $self->{plugins}->{ $plugin }->run( @args )

}

1
