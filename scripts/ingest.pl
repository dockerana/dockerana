#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use Data::Dumper;

use Net::Statsd;

my $carbon_port;
my $carbon_server;
my $grabnext;
my %grabnext_h;
my $i;
my $line;
my @parts;
my $sock;

$| = 0;

$Net::Statsd::HOST = $ENV{'STATSD_PORT_8125_UDP_ADDR'};
$Net::Statsd::PORT = $ENV{'STATSD_PORT_8125_UDP_PORT'};

$grabnext = \%grabnext_h;
$grabnext = {};

while($line = <>) {
  
  chomp $line;

  @parts = ();

  Net::Statsd::increment('docker.event.recorded.int');
  Net::Statsd::increment('d1.event1.int');

  if($grabnext->{'cpu'} && '1' == $grabnext->{'cpu'}) {

    $line =~ s/^docker.host.iostat\s+//;
    @parts = split(/\s+/, $line);

    for($i = 0; $i <= 5; $i++) {
      $parts[$i] =~ s/[^\d\.]+//g;
      $parts[$i] = $parts[$i] * 100;
      if($parts[$i] eq '0') {
        $parts[$i] = '1';
      }
    }

    Net::Statsd::gauge('docker.host.avg-cpu.user' => $parts[0]);
    Net::Statsd::gauge('docker.host.avg-cpu.nice' => $parts[1]);
    Net::Statsd::gauge('docker.host.avg-cpu.system' => $parts[2]);
    Net::Statsd::gauge('docker.host.avg-cpu.iowait' => $parts[3]);
    Net::Statsd::gauge('docker.host.avg-cpu.steal' => $parts[4]);
    Net::Statsd::gauge('docker.host.avg-cpu.idle' => $parts[5]);

    delete($grabnext->{'cpu'});

  } elsif($line =~ / netstat: ([\w\d]+)\s+\d+\s+\d+\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+/) {

    #Net::Statsd::update_stats("docker.net.interface.$1.rx-ok", $2);
    #Net::Statsd::update_stats("docker.net.interface.$1.rx-err", $3);
    #Net::Statsd::update_stats("docker.net.interface.$1.rx-drp", $4);
    #Net::Statsd::update_stats("docker.net.interface.$1.rx-ovr", $5);

    #Net::Statsd::update_stats("docker.net.interface.$1.tx-ok", $6);
    #Net::Statsd::update_stats("docker.net.interface.$1.tx-err", $7);
    #Net::Statsd::update_stats("docker.net.interface.$1.tx-drp", $8);
    #Net::Statsd::update_stats("docker.net.interface.$1.tx-ovr", $9);

    Net::Statsd::gauge("docker.net.interface.$1.rx-ok", $2);
    Net::Statsd::gauge("docker.net.interface.$1.rx-err", $3);
    Net::Statsd::gauge("docker.net.interface.$1.rx-drp", $4);
    Net::Statsd::gauge("docker.net.interface.$1.rx-ovr", $5);

    Net::Statsd::gauge("docker.net.interface.$1.tx-ok", $6);
    Net::Statsd::gauge("docker.net.interface.$1.tx-err", $7);
    Net::Statsd::gauge("docker.net.interface.$1.tx-drp", $8);
    Net::Statsd::gauge("docker.net.interface.$1.tx-ovr", $9);

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
    Net::Statsd::gauge('docker.host.loadavg.1-min', $1);
    Net::Statsd::gauge('docker.host.loadavg.5-min', $1);
    Net::Statsd::gauge('docker.host.loadavg.10-min', $1);
    Net::Statsd::gauge('docker.host.processes.active', $1);
    Net::Statsd::gauge('docker.host.processes.total', $1);

  } elsif($line =~ /^docker.host.iostat\s+(.*)/) {
    if($1 =~ /^avg-cpu:/) {
      $grabnext->{'cpu'} = 1;

    } elsif($1 !~ /^\s*$|Linux|Device:/) {
      @parts = split(/\s+/, $1);
      if($#parts eq '5') {
        Net::Statsd::gauge("docker.host.io.$parts[0].tps", $parts[1]);
        Net::Statsd::gauge("docker.host.io.$parts[0].kb_readspersec", $parts[2]);
        Net::Statsd::gauge("docker.host.io.$parts[0].kb_writtenpersec", $parts[3]);
        Net::Statsd::gauge("docker.host.io.$parts[0].kb_read", $parts[4]);
        Net::Statsd::gauge("docker.host.io.$parts[0].kb_written", $parts[5]);
      } else {
        print STDERR "unknown disk output from iostat ($line)\n";
      }

      @parts = ();
    }

  } else {
    # FIXME
    #print STDERR "unknown event ($line)\n";
  }

}

exit(0);
