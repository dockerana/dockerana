#!/usr/bin/perl

use Carp;
use strict;
use warnings;

use IO::Socket::INET;
use Python::Serialise::Pickle qw();

my $sock;
my $carbon_server;
my $carbon_port;
my $line;

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
  
  my $data = [["event", [time(), 1]]];

#my($data) = [
#             ["path.mytest", [1332444075,27893687]],
#             ["path.mytest", [1332444076,938.435]],
#            ];

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
