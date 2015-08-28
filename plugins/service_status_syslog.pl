#!/usr/bin/perl
use strict;
use warnings;
use Sys::Syslog qw(:DEFAULT setlogsock);

if (@ARGV  != 4){
    print "usage syslogtest.pl [target_host] [facility] [priority] [msg]\n";
    print "priority is error|warning|debug|info\n";
    exit(1);
}

my $ident    = " ";

my ($sv, $facility, $priority, $msg ) = @ARGV;

setlogsock("udp");
$Sys::Syslog::host = $sv;

openlog($ident, 0, $facility);
syslog($priority, $msg);
closelog();
