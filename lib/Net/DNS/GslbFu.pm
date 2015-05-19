#!/bin/false

use strict;
use warnings;

package Net::DNS::GslbFu;

use CHI;
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
my $chi;

$SIG{HUP}  = sub { $reload++; $log->info( "Got HUP. Will reload..." ) };
$SIG{ALRM} = sub { die 'Timeout executing plugin' };

sub loadconfig {

    my $file = shift;

    my $cfg = Config::Any->load_files({
        files   => [ $file ],
        use_ext => 1,
        flatten_to_hash => 1
    });

    # remove the file.name => {} outter
    $cfg = do { $cfg->{(keys %$cfg)[0]} };

    my %provide;
    my %trigger;

    my %stuff = (
        Actions => 'ARRAY', Checks => 'ARRAY', Store => 'HASH' );

    for my $name (sort keys %stuff) {
        $log->logdie( sprintf('No %s in config file', $name) )
            unless $cfg->{$name};
        $log->logdie( sprintf('Key %s not a hashref', $name) )
            unless ref $cfg->{$name} eq $stuff{$name};
    }

    for my $name (sort keys %$cfg) {
        $log->logdie( sprintf('Unknown key %s in config', $name) )
            unless $stuff{$name};
    }

    $log->logdie('No Checks defined?')
        unless @{$cfg->{Checks}};

    for my $foo (@{$cfg->{Checks}}) {

        $log->logdie('Everything in Actions has to be a hashref')
            unless ref $foo eq 'HASH';

        $log->logdie('Check name missing')
            unless $foo->{Check};

        $log->logdie('Check must be a string')
            if ref $foo->{Check};

        $log->logdie( sprintf 'Check %s not registered', $foo->{Check} )
            unless $checks->has($foo->{Check});

        $log->logdie('Provide name missing')
            unless $foo->{Provide};

        $log->logdie('Provide must be a string')
            if ref $foo->{Provide};

        $log->logdie( sprintf(
            'Provide %s is duplicate', $foo->{Provide}) )
            if $provide{$foo->{Provide}}++

        ## TODO have each plugin validate its own config

    }

    $log->debug( 'All Checks seem fine' );

    $log->logdie('No Actions defined?')
        unless @{$cfg->{Actions}};

    for my $foo (@{$cfg->{Actions}}) {
        $log->logdie('Everything in Actions has to be a hashref')
            unless ref $foo eq 'HASH';

        $log->logdie('Action name missing')
            unless $foo->{Action};

        $log->logdie('Action must be a string')
            if ref $foo->{Action};

        $log->logdie(sprintf 'Action %s not registered', $foo->{Action})
            unless $actions->has($foo->{Action});

        $log->logdie('Trigger name missing')
            unless $foo->{Trigger};

        $log->logdie('Trigger must be a string')
            if ref $foo->{Trigger};

        $log->logdie( sprintf(
            'Nothing Provide for Trigger %s', $foo->{Trigger}) )
            unless $provide{$foo->{Trigger}};

        $trigger{$foo->{Trigger}} = 1;

        ## TODO have each plugin validate its own config

    }

    $log->debug( 'All Actions seem fine' );

    for my $p (sort keys %provide) {
        next if $trigger{$p};
        $log->warn( sprintf 'Provider %s doesnt Trigger anything?', $p);
    }

    return $cfg

}

sub run {

    my $args = $_[1];

    # load up
    $checks  = Net::DNS::GslbFu::Checks->new();
    $actions = Net::DNS::GslbFu::Actions->new();

    # load config
    my $cfg = loadconfig( $args->{configfile} );

    $chi = CHI->new(%{$cfg->{Store}});

    while ($keeprunning) {

        if ($reload) {
            $log->info( 'Reloading config' );
            eval {
                my $newcfg = loadconfig( $args->{configfile} );
                $cfg = $newcfg;
            };
            if ($@) {
                $log->error( 'Reload failed, continuing with old config' );
                $log->error( 'Reload error was: ' . $@ );
            }
            else {
                $chi = CHI->new(%{$cfg->{Store}});
            }
            $reload = 0
        }

        $log->info( 'Running Checks' );

        CHECKS:
        for my $c (@{$cfg->{Checks}}) {

            $log->debug( sprintf 'Checking %s...', $c->{Provide} );
            my $res;
            alarm(5);
            eval {
                $res = $checks->run(
                    $c->{Check}, %$c, cache => $chi)
            };
            alarm(0);
            if ($@) {
                $log->warn(sprintf 'Eval failed for %s with: %s',
                    $c->{Provide}, $@)
            }

            if ( $res ) {
                $log->debug( sprintf '%s Pass', $c->{Provide} );
                $chi->set($c->{Provide} => 1);
            }
            else {
                $log->debug( sprintf '%s Fail', $c->{Provide} );
                $chi->set($c->{Provide} => 0);
            }
            $log->debug( sprintf 'Done with %s', $c->{Provide} );

        }

        $log->info( 'Finished Checks' );

        $log->debug( 'Values in cache: '
            . join( ', ',
                map { sprintf '%s=%s', $_, $chi->get($_) }
                    $chi->get_keys() ) );

        $log->info( 'Running Actions' );

        ACTIONS:
        for my $c (@{$cfg->{Actions}}) {

            $log->debug( sprintf 'Processing %s on Trigger %s...',
                            $c->{Action}, $c->{Trigger} );

            if ($chi->get($c->{Trigger})) {

                $log->debug( 'Taking Action' );

                my $res;
                alarm(5);
                eval {
                    $res = $actions->run( $c->{Action}, %$c )
                };
                alarm(0);
                if ($@) {
                    $log->warn(
                        sprintf 'Eval failed for %s on Trigger %s: %s',
                        $c->{Action}, $c->{Trigger}, $@)
                }

            }
            else {

                $log->debug( 'Action not taken' )

            }
            $log->debug( sprintf 'Done with %s on Trigger %s...',
                            $c->{Action}, $c->{Trigger} );

        }

        $log->info( 'Finished Actions' );

        #~ for my $name (sort keys %$cfg) {
            #~ my $steps = $cfg->{$name};

            #~ STEPS:
            #~ for my $step (@$steps) {
                #~ my $check = $step->{Check};
#~
                #~ $log->info( sprintf "Checking %s...", $check->[0] );
                #~ my $res;
                #~ alarm(5);
                #~ eval { $res = $checks->run(@$check) };
                #~ alarm(0);
                #~ if ($@) {
                    #~ $log->info('Eval failed with: ' . $@)
                #~ }
#~
                #~ if ( $res ) {
                    #~ $log->info( "Pass" );
                    #~ $log->info( "Running Action..." );
#~
                    #~ for my $action (@{$step->{Action}}) {
                        #~ alarm(5);
                        #~ eval {
                            #~ $actions->run(@$action)
                        #~ };
                        #~ alarm(0);
                        #~ if ($@) {
                            #~ $log->info('Eval failed with: ' . $@)
                        #~ }
                    #~ }
#~
                    #~ $log->info( "Done with $name" );
                    #~ last STEPS
                #~ }
#~
                #~ $log->info( "Fail" );
                #~ $log->info( "Running further Checks" );
#~
            #~ }
#~
            #~ $log->info( "Completed $name... for now." );
#~
        #~ }

        my $pause = 5;
        $log->info( "Sleeping for $pause" );
        sleep($pause) if $pause > 0;

    }

}


1
