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
my %grabnext;
my @parts;

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

  if(%grabnext && $grabnext{'cpu'} && '1' == $grabnext{'cpu'}) {

    @parts = split(/\s+/, $line);
    push @{$data}, ["docker.host.avg-cpu.user", [$t, $parts[0]]];
    push @{$data}, ["docker.host.avg-cpu.nice", [$t, $parts[1]]];
    push @{$data}, ["docker.host.avg-cpu.system", [$t, $parts[2]]];
    push @{$data}, ["docker.host.avg-cpu.iowait", [$t, $parts[3]]];
    push @{$data}, ["docker.host.avg-cpu.steal", [$t, $parts[4]]];
    push @{$data}, ["docker.host.avg-cpu.idle", [$t, $parts[5]]];
   
    delete($grabnext{'cpu'});
    @parts = ();

  } elsif($line =~ /\/sbin\/iptables/) {
    push @{$data}, ["docker.iptables.adjustment", [$t, 1]];

  } elsif($line =~ /^docker.host.loadavg\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)\/(\d+)\s/) {
    push @{$data}, ["docker.host.loadavg.1-min", [$t, $1]];
    push @{$data}, ["docker.host.loadavg.5-min", [$t, $2]];
    push @{$data}, ["docker.host.loadavg.10-min", [$t, $3]];
    push @{$data}, ["docker.host.processes.active", [$t, $4]];
    push @{$data}, ["docker.host.processes.total", [$t, $5]];

  } elsif($line =~ /^docker.host.iostat\s+(.*)/) {
    if($1 =~ /^avg-cpu:/) {
      $grabnext{'cpu'} = 1;

    } elsif($1 !~ /^\s*$|Linux|Device:/) {
      @parts = split(/\s+/, $1);
      if($#parts eq '5') {
        push @{$data}, ["docker.host.io.$parts[0].tps", [$t, $parts[1]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_readspersec", [$t, $parts[2]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_writtenpersec", [$t, $parts[3]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_read", [$t, $parts[4]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_written", [$t, $parts[5]]];
      } else {
        print "unknown disk output from iostat ($line)\n";
      }

      @parts = ();
    }

  } else {
    print "unknown event ($line)\n";
  }

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
