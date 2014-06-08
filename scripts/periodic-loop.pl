#!/usr/bin/perl

use warnings;
use strict;
use Time::HiRes qw(gettimeofday usleep);

my $cmd;
my $d1;
my $out;
my $t0;
my $t1;

# first setup persistent stuff
# FIXME this is going to need rotation/truncating
#$cmd = "iostat -y 1 > /tmp/iostat";
#$out = `$cmd &`;

while(1) {
  ($t0,$t1) = gettimeofday();
  $d1 = 1000000 - $t1;
  print "t: $t0, going to sleep for $d1 usecs\n";
  usleep($d1);
  $cmd = "./periodic-ingest.sh  | ./ingest.pl";
  $out = `$cmd`;
  print "out: $out\n";
}

exit(0);
