#!/usr/bin/perl -w
# vim: et sts=4 sw=4 ts=4
# Copyright (c) 2012 Transitiv Technologies Ltd. <info@transitiv.co.uk>
 
use strict;
use Getopt::Long;
 
use constant {
    VMSTAT      => '/usr/bin/vmstat',
 
    OK          => 0,
    WARNING     => 1,
    CRITICAL    => 2,
    UNKNOWN     => 3,
 
    STATUS_STRINGS => [
        'OK',
        'WARNING',
        'CRITICAL',
        'UNKNOWN'
    ],
    HELP        => <<EOH
Usage: $0 -w <warning %> -c <critical %>
 
Checks the CPU utilisation of a Linux system
 
Options:
 
 -h, --help
   Print this message
-w, --warning=PERCENT
   Exit with WARNING status if user CPU time exceeds PERCENT%
-c, --critical=PERCENT
   Exit with CRITICAL status if user CPU time exceeds PERCENT%
EOH
};
 
sub format_perfdata {
    my $args = $_;
 
    return sprintf("'%s'=%s%s;%s;%s;%s;%s",
        $args->{label},
        $args->{value},
        $args->{uom} || '',
        $args->{warn} || '',
        $args->{crit} || '',
        $args->{min} || '',
        $args->{max} || ''
    );
}
 
sub nagios_exit {
    my ($code, $msg, $perfdata) = @_;
    printf("%s - %s",
        STATUS_STRINGS->[$code],
        $msg
    );
 
    if (defined($perfdata) && @$perfdata) {
        printf(" | %s\n", join(' ', map(format_perfdata, @$perfdata)));
    } else {
        printf("\n");
    }
 
    exit($code);
};
 
 
my ($warning, $critical, $name, $help);
my @perfdata;
 
my $result = GetOptions(
    'warning|w=i'   => \$warning,
    'critical|c=i'  => \$critical,
    'help|h'        => \$help
);
 
if ($help) {
    print HELP;
    exit(UNKNOWN);
}
 
my @missing;
 
unless (defined($warning)) { push(@missing, 'warning'); }
unless (defined($critical)) { push(@missing, 'critical'); }
 
if (@missing) {
    printf("Missing required arguments: %s\n", join(', ', @missing));
    exit(UNKNOWN);
}
 
unless (-x VMSTAT) {
    nagios_exit(UNKNOWN, sprintf(
        "`%s' does not exist or is not executable",
        VMSTAT
    ));
}
 
my $cmd = sprintf('%s 3 2', VMSTAT);
$result = qx($cmd);
 
if ($? == -1) {
    nagios_exit(CRITICAL, "Execution of vmstat failed: $!");
}
 
my @lines = split(/\n/, $result);
# Regexp for:
# r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
# 0  0      0 171288 181968 1146648    0    0     0     0    0    0  0  0 100  0  0
my $pattern = qr((\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*\Z)ix;
 
my ($us, $sy, $id, $wa, $st);
# We want the last output from vmstat so we iterate backwards
# through the lines
foreach my $line (reverse(@lines)) {
    if (($us, $sy, $id, $wa, $st) = ($line =~ $pattern)) {
        push(@perfdata, {
            label   => 'User',
            uom     => '%',
            value   => $us,
            min     => 0,
            max     => 100,
            warn    => $warning,
            crit    => $critical
        });
 
        push(@perfdata, {
            label   => 'System',
            uom     => '%',
            value   => $sy,
            min     => 0,
            max     => 100
        });
 
        push(@perfdata, {
            label   => 'Idle',
            uom     => '%',
            value   => $id,
            min     => 0,
            max     => 100
        });
 
        push(@perfdata, {
            label   => 'Wait',
            uom     => '%',
            value   => $wa,
            min     => 0,
            max     => 100
        });
 
        last;
    }
}
 
unless (defined($us)) {
    nagios_exit(CRITICAL, "Unable to parse output from vmstat");
}
 
my $code = OK;
my $msg = sprintf(
    'CPU Usage: %d%% user / %d%% system / %d%% idle / %d%% wait',
    $us, $sy, $id, $wa
);
 
if ($us > $critical) { $code = CRITICAL; }
elsif ($us > $warning) { $code = WARNING; }
 
nagios_exit($code, $msg, \@perfdata);
