#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use Benchmark qw/:all/;
use lib 'lib';

use Redis;
use Redis::Fast;
use Valkey::Client;

my $r = Redis->new(server => 'valkey:6379');
my $rf = Redis::Fast->new(server => 'valkey:6379');
my $vc_ffi = Valkey::Client->new(use_ffi => 1, hostname => 'valkey', port => 6379);
my $vc_xs = Valkey::Client->new(use_ffi => 0, hostname => 'valkey', port => 6379);

my $i = 0;
my $j = 0;
my $k = 0;
my $l = 0;

timethese(
    -3,
    {
        'r:00_ping'  => sub { $r->ping },
        'rf:00_ping' => sub { $rf->ping },
        'vc_ffi:00_ping' => sub { $vc_ffi->ping },
        'vc_xs:00_ping' => sub { $vc_xs->ping },
    }
);

timethese(
    -3,
    {
        'r:10_set'  => sub { $r->set('r', $i++) },
        'rf:10_set' => sub { $rf->set('rf', $j++) },
        'vc_ffi:10_set' => sub { $vc_ffi->set('vc_ffi', $k++) },
        'vc_xs:10_set' => sub { $vc_xs->set('vc_xs', $l++) },
    }
);

timethese(
    -3,
    {
        'r:11_set_r'  => sub { $r->set('bench-' . rand(), rand()) },
        'rf:11_set_r' => sub { $rf->set('bench-' . rand(), rand()) },
        'vc_ffi:11_set_r' => sub { $vc_ffi->set('bench-' . rand(), rand()) },
        'vc_xs:11_set_r' => sub { $vc_xs->set('bench-' . rand(), rand()) },
    }
);

timethese(
    -3,
    {
        'r:20_get'  => sub { $r->get('r') },
        'rf:20_get' => sub { $rf->get('rf') },
        'vc_ffi:20_get' => sub { $vc_ffi->get('vc_ffi') },
        'vc_xs:20_get' => sub { $vc_xs->get('vc_xs') },
    }
);

timethese(
    -3,
    {
        'r:21_get_r'  => sub { $r->get('bench-' . rand()) },
        'rf:21_get_r' => sub { $rf->get('bench-' . rand()) },
        'vc_ffi:21_get_r' => sub { $vc_ffi->get('bench-' . rand()) },
        'vc_xs:21_get_r' => sub { $vc_xs->get('bench-' . rand()) },
    }
);

# '30_incr'   => sub { $vc_ffi->incr('counter') },
# '30_incr_r' => sub { $vc_ffi->incr('bench-' . rand()) },
# '40_lpush'  => sub { $vc_ffi->lpush('mylist', 'bar') },
# '40_lpush'  => sub { $vc_ffi->lpush('mylist', 'bar') },
# '50_lpop'   => sub { $vc_ffi->lpop('mylist') },
# '90_h_set'  => sub { $hash{ 'test' . rand() } = rand() },
# '90_h_get'  => sub { my $a = $hash{ 'test' . rand() }; },
