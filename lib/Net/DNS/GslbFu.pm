#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu;

use Config::Any;
use Net::DNS::GslbFu::Actions;
use Net::DNS::GslbFu::Checks;

my $keeprunning = 1;
my $reload = 0;
my $actions;
my $checks;

$SIG{HUP}  = sub { $reload++; print "Will reload...\n" };
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

        print "Examining config for $name\n";

        for my $step (@$steps) {

            die "No Check defined for $name\n"
                unless $step->{Check};

            # smoosh scalars in to arrayrefs
            my $check = $step->{Check};
            $step->{Check} = $check = [$check]
                unless ref $check;
            die "Check for $name must be an array or string\n"
                unless ref $check eq 'ARRAY';

            if ($checks->has($check->[0])) {
                print "Check $check->[0] for $name is AOK\n";
            }
            else {
                die "Unknown Check $check->[0] for $name\n"
            }

            print "All Checks fine for $name\n";

            die "No Action defined for $name\n"
                unless $step->{Action};

            # smoosh scalars in to arrayrefs
            my $action = $step->{Action};
            die "Action for $name must be an array\n"
                unless ref $check eq 'ARRAY';

            # repack in to an array ref
            unless ( ref $action->[0] ) {
                @$action = ( [ @$action ] );
            }
            die "Action for $name must be an array or string\n"
                unless ref $action->[0] eq 'ARRAY';

            for my $c (@$action) {

                die "Action for $name must be a string\n"
                    if ref $c->[0];

                if ($actions->has($c->[0])) {
                    printf "Action %s for %s is AOK\n", $c->[0], $name;
                    next
                }
                die sprintf "Unknown Action %s for %s\n", $c->[0], $name;

            }

            print "All Actions fine for $name\n";

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
    use Data::Dumper; print Dumper $cfg;

    while ($keeprunning) {

        if ($reload) {
            print "re-loading config\n";
            eval {
                my $newcfg = loadconfig( $args->{configfile} );
                $cfg = $newcfg;
            };
            if ($@) {
                print "reload failed, continuing with old config\n";
                print "error was: " . $@;
            }
            $reload = 0
        }

        for my $name (sort keys %$cfg) {
            my $steps = $cfg->{$name};

            print "Running $name\n";

            STEPS:
            for my $step (@$steps) {
                my $check = $step->{Check};

                printf "Checking %s...", $check->[0];
                my $res;
                alarm(5);
                eval { $res = $checks->run(@$check) };
                alarm(0);

                if ( $res ) {
                    print "Pass\n";
                    print "Running Action...\n";

                    for my $action (@{$step->{Action}}) {
                        alarm(5);
                        eval {
                            $actions->run(@$action)
                        };
                        alarm(0);
                    }

                    print "Done with $name\n";
                    last STEPS
                }

                print "Fail\n";
                print "Running further Checks\n";

            }

            print "Completed $name... for now.\n";

        }

        my $pause = 5;
        print "Sleeping for $pause\n";
        sleep($pause) if $pause > 0;

    }

}


1
