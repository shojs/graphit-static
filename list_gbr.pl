#!/usr/bin/perl -w

use strict;
use File::Find;
use JSON;
use Data::Dumper;

my $basePath = "http://shojs.github.com/graphit-static/";
##########
# GLOBAL #
##########
my $json = JSON->new->allow_nonref;
my %JSON;   
 
sub want_gbr {
	/^(.*)\.(gbr)$/i or return;
	if (not defined $JSON{$File::Find::dir}) {
		$JSON{$File::Find::dir} = ();
	}
    my $path = $File::Find::dir . $_;
    push @{$JSON{$File::Find::dir}}, $_;
}

########
# MAIN #
########
find(\&want_gbr, qw|brushes|);
print Dumper(%JSON);
print $json->encode(\%JSON);
1;
