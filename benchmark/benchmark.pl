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
my $vc = Valkey::Client->new(hostname => 'valkey', port => 6379);

my $i = 0;
my $j = 0;
my $k = 0;

timethese(
    -3,
    {
        'r:00_ping'  => sub { $r->ping },
        'rf:00_ping' => sub { $rf->ping },
        'vc:00_ping' => sub { $vc->ping },
    }
);

timethese(
    -3,
    {
        'r:10_set'  => sub { $r->set('foo', $i++) },
        'rf:10_set' => sub { $rf->set('foo', $j++) },
        'vc:10_set' => sub { $vc->set('foo', $k++) },
    }
);

timethese(
    -3,
    {
        'r:11_set_r'  => sub { $r->set('bench-' . rand(), rand()) },
        'rf:11_set_r' => sub { $rf->set('bench-' . rand(), rand()) },
        'vc:11_set_r' => sub { $vc->set('bench-' . rand(), rand()) },
    }
);

timethese(
    -3,
    {
        'r:20_get'  => sub { $r->get('foo') },
        'rf:20_get' => sub { $rf->get('foo') },
        'vc:20_get' => sub { $vc->get('foo') },
    }
);

timethese(
    -3,
    {
        'r:21_get_r'  => sub { $r->get('bench-' . rand()) },
        'rf:21_get_r' => sub { $rf->get('bench-' . rand()) },
        'vc:21_get_r' => sub { $vc->get('bench-' . rand()) },
    }
);

# '30_incr'   => sub { $vc->incr('counter') },
# '30_incr_r' => sub { $vc->incr('bench-' . rand()) },
# '40_lpush'  => sub { $vc->lpush('mylist', 'bar') },
# '40_lpush'  => sub { $vc->lpush('mylist', 'bar') },
# '50_lpop'   => sub { $vc->lpop('mylist') },
# '90_h_set'  => sub { $hash{ 'test' . rand() } = rand() },
# '90_h_get'  => sub { my $a = $hash{ 'test' . rand() }; },
