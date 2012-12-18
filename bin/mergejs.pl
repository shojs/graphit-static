#!/bin/perl -w

use strict;
use JavaScript::Minifier qw(minify);
use File::Basename;
use Cwd;

if (!$ARGV[0] || !(-e $ARGV[0])) {
    print "First argument must be a index file";
    exit 1;
}
my $base_dir = getcwd;
print "ARG: $ARGV[0]\n";;
my $htm = $ARGV[0];
my $dirname  = dirname($htm);
chdir $dirname;
print "DIR: $dirname\n";
$htm =~ /([\w\d._-]+\.htm(l)?)$/i or die "Invalid file! $htm";
my $fileName = "$1";
print "Filename: $fileName\n";
my $fout     = "$fileName.min.js";
my $OPTIMIZATION = 'SIMPLE_OPTIMIZATIONS'; 
#my $OPTIMIZATION = 'ADVANCED_OPTIMIZATIONS --debug --externs js/jquery-1.8.3.js js/main.js';
my $COPT = "--compilation_level $OPTIMIZATION --language_in ECMASCRIPT5 ";
my $bincomp = "java -jar $base_dir/google-compiler/closure-compiler.jar $COPT --js_output_file $fout";
my $ls = '-' x 80 . "\n";

print $ls;
print " Merging javascript sources\n";
print $ls;

my $fh;
open( $fh, $fileName )
  or die "Cannot open file $htm";
my $out = "";
my $bParse = 0;
my @jslist;
while (<$fh>) {
	next unless $_;
	#print "Line: $_\n";
	!$bParse && ( $_ !~ /MINIFYJS:START/ ) && do { next; };
	#print 'PARSE';
	$bParse = 1;
	( $_ =~ /MINIFYJS:STOP/ ) && do { $bParse = 0; next; };
	next unless $bParse;
	/('|")([\w\d_.\/-]+\.js)('|")/i and do {
		my $js = $2;
		#$js =~ /^(deprecated).*/ and next;
		print " [Append] $js\n";
		$bincomp .= " --js js/$js";
	};
}
print $bincomp;
print $ls;
print "Executing js compiler\n";
#$bincomp .= ' 2> bin/error.log <&1';
print $ls;
my $res =`$bincomp`;
print "[ Merged] into $fout:\n";
if ($res) {
	print "\tFailed\n";
} else {
	print "\tDone\n";
}
print $ls;
exit(0);