#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use Data::Dumper;

use IO::Socket::INET;
use Python::Serialise::Pickle qw();

my $carbon_port;
my $carbon_server;
my $line;
my $sock;

$| = 0;

$carbon_server = $ENV{'GRAPHITE_PORT_2004_TCP_ADDR'};
$carbon_port   = $ENV{'GRAPHITE_PORT_2004_TCP_PORT'};

$sock = IO::Socket::INET->new (
          PeerAddr => $carbon_server,
          PeerPort => $carbon_port,
          Proto => 'tcp'
        );
die "Unable to connect: $!\n" unless ($sock->connected);

while($line = <>) {
  
  chomp $line;

  my $t    = time();
  my $data = [["docker.event.recorded", [$t, 1]]];

  if($line =~ /\/sbin\/iptables/) {
    push @{$data}, ["docker.iptables.adjustment", [$t, 1]];
  #                  docker.host.loadavg 0.22 0.35 0.29 1/304 293
  } elsif($line =~ /^docker.host.loadavg\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)\/(\d+)\s/) {
    push @{$data}, ["docker.host.loadavg.1-min", [$t, $1]];
    push @{$data}, ["docker.host.loadavg.5-min", [$t, $2]];
    push @{$data}, ["docker.host.loadavg.10-min", [$t, $3]];
    push @{$data}, ["docker.host.processes.active", [$t, $4]];
    push @{$data}, ["docker.host.processes.total", [$t, $5]];
  } else {
    print "unknown event ($line)\n";
  }

#my($data) = [
#             ["path.mytest", [1332444075,27893687]],
#             ["path.mytest", [1332444076,938.435]],
#            ];

  print "writing....\t", Dumper($data);

  my $message = pack("N/a*", pickle_dumps($data));
  $sock->send($message);
}

$sock->shutdown(2);

# Work around P::S::Pickle 0.01's extremely limiting interface.
sub pickle_dumps {
   open(my $fh, '>', \my $s) or die $!;
   my $pickle = bless({ _fh => $fh }, 'Python::Serialise::Pickle');
   $pickle->dump($_[0]);
   $pickle->close();
   return $s;
}
