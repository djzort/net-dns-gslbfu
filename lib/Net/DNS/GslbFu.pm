#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu;

use Config::Any;
use Net::DNS::GslbFu::Actions;
use Net::DNS::GslbFu::Checks;
use Log::Log4perl;
Log::Log4perl->init('log4perl.conf');

my $log = Log::Log4perl->get_logger(__PACKAGE__);
my $keeprunning = 1;
my $reload = 0;
my $actions;
my $checks;

$SIG{HUP}  = sub { $reload++; $log->info( "Got HUP. Will reload..." ) };
$SIG{ALRM} = sub { die 'Timeout executing plugin' };

sub loadconfig {

    my $file = shift;

    my $cfg = Config::Any->load_files({
        files => [ $file ],
        use_ext => 1,
        flatten_to_hash => 1
    });

    # remove the file.name => {} outter
    $cfg = do { $cfg->{(keys %$cfg)[0]} };

    for my $name (sort keys %$cfg) {
        my $steps = $cfg->{$name};

        $log->debug( "Examining config for $name" );

        for my $step (@$steps) {

            $log->logdie( "No Check defined for $name" )
                unless $step->{Check};

            # smoosh scalars in to arrayrefs
            my $check = $step->{Check};
            $step->{Check} = $check = [$check]
                unless ref $check;
            die "Check for $name must be an array or string\n"
                unless ref $check eq 'ARRAY';

            if ($checks->has($check->[0])) {
                $log->debug( "Check $check->[0] for $name is AOK" );
            }
            else {
                $log->logdie( "Unknown Check $check->[0] for $name" )
            }

            $log->debug( "All Checks fine for $name" );

            $log->logdie( "No Action defined for $name" )
                unless $step->{Action};

            # smoosh scalars in to arrayrefs
            my $action = $step->{Action};
            $log->logdie( "Action for $name must be an array" )
                unless ref $check eq 'ARRAY';

            # repack in to an array ref
            unless ( ref $action->[0] ) {
                @$action = ( [ @$action ] );
            }
            $log->logdie( "Action for $name must be an array or string" )
                unless ref $action->[0] eq 'ARRAY';

            for my $c (@$action) {

                $log->logdie( "Action for $name must be a string" )
                    if ref $c->[0];

                if ($actions->has($c->[0])) {
                    $log->debug( sprintf "Action %s for %s is AOK", $c->[0], $name );
                    next
                }
                $log->logdie( sprintf "Unknown Action %s for %s", $c->[0], $name );

            }

            $log->info( "All Actions fine for $name" );

        }

    }

    return $cfg

}

sub run {

    my $args = $_[1];

    # load up
    $actions = Net::DNS::GslbFu::Actions->new();
    $checks  = Net::DNS::GslbFu::Checks->new();

    # load config
    my $cfg = loadconfig( $args->{configfile} );
    use Data::Dumper; $log->info( Dumper $cfg );

    while ($keeprunning) {

        if ($reload) {
            $log->info( "re-loading config\n" );
            eval {
                my $newcfg = loadconfig( $args->{configfile} );
                $cfg = $newcfg;
            };
            if ($@) {
                $log->error( "reload failed, continuing with old config" );
                $log->error( "error was: " . $@ );
            }
            $reload = 0
        }

        for my $name (sort keys %$cfg) {
            my $steps = $cfg->{$name};

            $log->info( "Running $name" );

            STEPS:
            for my $step (@$steps) {
                my $check = $step->{Check};

                $log->info( sprintf "Checking %s...", $check->[0] );
                my $res;
                alarm(5);
                eval { $res = $checks->run(@$check) };
                alarm(0);
                if ($@) {
                    $log->info('Eval failed with: ' . $@)
                }

                if ( $res ) {
                    $log->info( "Pass" );
                    $log->info( "Running Action..." );

                    for my $action (@{$step->{Action}}) {
                        alarm(5);
                        eval {
                            $actions->run(@$action)
                        };
                        alarm(0);
                        if ($@) {
                            $log->info('Eval failed with: ' . $@)
                        }
                    }

                    $log->info( "Done with $name" );
                    last STEPS
                }

                $log->info( "Fail" );
                $log->info( "Running further Checks" );

            }

            $log->info( "Completed $name... for now." );

        }

        my $pause = 5;
        $log->info( "Sleeping for $pause" );
        sleep($pause) if $pause > 0;

    }

}


1
