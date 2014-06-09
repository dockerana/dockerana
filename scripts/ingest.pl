#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use Data::Dumper;

use IO::Socket::INET;
use Python::Serialise::Pickle qw();
use Net::Statsd;

my $carbon_port;
my $carbon_server;
my $grabnext;
my $i;
my $line;
my $sock;
my %grabnext_h;
my @parts;

$| = 0;

$carbon_server     = $ENV{'GRAPHITE_PORT_2004_TCP_ADDR'};
$carbon_port       = $ENV{'GRAPHITE_PORT_2004_TCP_PORT'};

$Net::Statsd::HOST = $ENV{'STATSD_PORT_8125_UDP_ADDR'};
$Net::Statsd::PORT = $ENV{'STATSD_PORT_8125_UDP_PORT'};

$sock = IO::Socket::INET->new (
          PeerAddr => $carbon_server,
          PeerPort => $carbon_port,
          Proto => 'tcp'
        );
die "Unable to connect: $!\n" unless ($sock->connected);

$grabnext = \%grabnext_h;
$grabnext = {};

while($line = <>) {
  
  chomp $line;

  @parts = ();
  my $t  = time();

  Net::Statsd::increment('docker.event.recorded.int');
  Net::Statsd::increment('d1.event1.int');

  #my $data = [["docker.event.recorded", [$t, 1]]];
  my $data = [["docker.event.r1", [$t, 1]]];

  if($grabnext->{'cpu'} && '1' == $grabnext->{'cpu'}) {

    #print STDERR "found cpu, $line\n";
    $line =~ s/^docker.host.iostat\s+//;
    @parts = split(/\s+/, $line);

    for($i = 0; $i <= 5; $i++) {
      #print "before: |$parts[$i]|...";
      $parts[$i] =~ s/[^\d\.]+//g;
      $parts[$i] = $parts[$i] * 100;
      if($parts[$i] eq '0') {
        $parts[$i] = '1';
      }
      #print "after: |$parts[$i]|\n";
    }

    push @{$data}, ["docker.host.avg-cpu.user", [$t, $parts[0]]];
    push @{$data}, ["docker.host.avg-cpu.nice", [$t, $parts[1]]];
    push @{$data}, ["docker.host.avg-cpu.system", [$t, $parts[2]]];
    push @{$data}, ["docker.host.avg-cpu.iowait", [$t, $parts[3]]];
    push @{$data}, ["docker.host.avg-cpu.steal", [$t, $parts[4]]];
    push @{$data}, ["docker.host.avg-cpu.idle", [$t, $parts[5]]];

    delete($grabnext->{'cpu'});

  } elsif($line =~ / netstat: ([\w\d]+)\s+\d+\s+\d+\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+/) {

    Net::Statsd::update_stats("docker.net.interface.$1.rx-ok", $2);
    Net::Statsd::update_stats("docker.net.interface.$1.rx-err", $3);
    Net::Statsd::update_stats("docker.net.interface.$1.rx-drp", $4);
    Net::Statsd::update_stats("docker.net.interface.$1.rx-ovr", $5);

    Net::Statsd::update_stats("docker.net.interface.$1.tx-ok", $6);
    Net::Statsd::update_stats("docker.net.interface.$1.tx-err", $7);
    Net::Statsd::update_stats("docker.net.interface.$1.tx-drp", $8);
    Net::Statsd::update_stats("docker.net.interface.$1.tx-ovr", $9);

    Net::Statsd::gauge("docker.net2.interface.$1.rx-ok", $2);
    Net::Statsd::gauge("docker.net2.interface.$1.rx-err", $3);
    Net::Statsd::gauge("docker.net2.interface.$1.rx-drp", $4);
    Net::Statsd::gauge("docker.net2.interface.$1.rx-ovr", $5);

    Net::Statsd::gauge("docker.net2.interface.$1.tx-ok", $6);
    Net::Statsd::gauge("docker.net2.interface.$1.tx-err", $7);
    Net::Statsd::gauge("docker.net2.interface.$1.tx-drp", $8);
    Net::Statsd::gauge("docker.net2.interface.$1.tx-ovr", $9);

  } elsif($line =~ /\/sbin\/iptables/) {
    #print "sending iptables event...\n";
    Net::Statsd::increment('docker.iptables.adjustment.int');

  # FIXME (needs to pull starting values if there are pre-existing containers, and needs to know about other API versions)
  } elsif($line =~ /\/v1.12\//) {
    print "sending API event...\n";
    Net::Statsd::increment('docker.api.call.int');

    if($line =~ /POST \/v1.12\/containers\/create/) {
      Net::Statsd::increment('docker.containers.running');
    } elsif($line =~ /POST \/v1.12\/containers\/.*\/stop/) {
      Net::Statsd::decrement('docker.containers.running');
      Net::Statsd::increment('docker.containers.stopped');
    # FIXME
    } elsif($line =~ /DELETE \/v1.12\/containers\//) {
      Net::Statsd::decrement('docker.containers.stopped');
    }

  } elsif($line =~ /^docker.host.loadavg\s+([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)\s+(\d+)\/(\d+)\s/) {
    push @{$data}, ["docker.host.loadavg.1-min", [$t, $1]];
    push @{$data}, ["docker.host.loadavg.5-min", [$t, $2]];
    push @{$data}, ["docker.host.loadavg.10-min", [$t, $3]];
    push @{$data}, ["docker.host.processes.active", [$t, $4]];
    push @{$data}, ["docker.host.processes.total", [$t, $5]];

  } elsif($line =~ /^docker.host.iostat\s+(.*)/) {
    if($1 =~ /^avg-cpu:/) {
      $grabnext->{'cpu'} = 1;

    } elsif($1 !~ /^\s*$|Linux|Device:/) {
      @parts = split(/\s+/, $1);
      if($#parts eq '5') {
        push @{$data}, ["docker.host.io.$parts[0].tps", [$t, $parts[1]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_readspersec", [$t, $parts[2]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_writtenpersec", [$t, $parts[3]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_read", [$t, $parts[4]]];
        push @{$data}, ["docker.host.io.$parts[0].kb_written", [$t, $parts[5]]];
      } else {
        print STDERR "unknown disk output from iostat ($line)\n";
      }

      @parts = ();
    }

  } else {
    #print STDERR "unknown event ($line)\n";
  }

  #print "writing....\t", Dumper($data);
  #local *FD;
  #open(FD, "> /tmp/ingest-$$-$..txt");
  #print FD Dumper($data);
  #close(FD);

  my $message = pack("N/a*", pickle_dumps($data));
  $sock->send($message);

  undef $data;

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
