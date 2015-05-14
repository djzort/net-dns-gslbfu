#!/usr/bin/env perl

use Net::DNS::GslbFu;
use Getopt::Long;

sub version {
    print $0, ' ', $Net::DNS::GslbFu::VERSION, "\n";
    exit;
}

sub help { die "Stub!" }
sub usage { die "Stub!" }

unless (caller) {

    my $configfile;

    GetOptions(
        'configfile=s' => \$configfile,
        'help|?'       => \&help,
        'usage'        => \&usage,
        'version|V'    => \&version,
    )
    or die("Error in command line arguments\n");

    die "Config file required\n" unless $configfile;
    die "No file $configfile\n" unless -f $configfile;

    Net::DNS::GslbFu->run({ configfile => $configfile });

}


