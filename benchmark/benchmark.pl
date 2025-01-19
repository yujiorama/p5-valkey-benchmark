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

my $i = 0;

my $rlog = timethese(
    -5,
    { 'r:00_ping'    => sub { $r->ping },
        'r:10_set'   => sub { $r->set('foo', $i++) },
        'r:11_set_r' => sub { $r->set('bench-' . rand(), rand()) },
        'r:20_get'   => sub { $r->get('foo') },
        'r:21_get_r' => sub { $r->get('bench-' . rand()) },
        # '30_incr'   => sub { $r->incr('counter') },
        # '30_incr_r' => sub { $r->incr('bench-' . rand()) },
        # '40_lpush'  => sub { $r->lpush('mylist', 'bar') },
        # '40_lpush'  => sub { $r->lpush('mylist', 'bar') },
        # '50_lpop'   => sub { $r->lpop('mylist') },
        # '90_h_set'  => sub { $hash{ 'test' . rand() } = rand() },
        # '90_h_get'  => sub { my $a = $hash{ 'test' . rand() }; },
    },
    'none'
);

my $rf = Redis::Fast->new(server => 'valkey:6379');
my $j = 0;

my $rflog = timethese(
    -5,
    { 'rf:00_ping'    => sub { $rf->ping },
        'rf:10_set'   => sub { $rf->set('foo', $j++) },
        'rf:11_set_r' => sub { $rf->set('bench-' . rand(), rand()) },
        'rf:20_get'   => sub { $rf->get('foo') },
        'rf:21_get_r' => sub { $rf->get('bench-' . rand()) },
        # '30_incr'   => sub { $rf->incr('counter') },
        # '30_incr_r' => sub { $rf->incr('bench-' . rand()) },
        # '40_lpush'  => sub { $rf->lpush('mylist', 'bar') },
        # '40_lpush'  => sub { $rf->lpush('mylist', 'bar') },
        # '50_lpop'   => sub { $rf->lpop('mylist') },
        # '90_h_set'  => sub { $hash{ 'test' . rand() } = rand() },
        # '90_h_get'  => sub { my $a = $hash{ 'test' . rand() }; },
    },
    'none'
);

my $vc = Valkey::Client->new(hostname => 'valkey', port => 6379);
my $k = 0;

my $vclog = timethese(
    -5,
    { 'vc:00_ping'    => sub { $vc->ping },
        'vc:10_set'   => sub { $vc->set('foo', $k++) },
        'vc:11_set_r' => sub { $vc->set('bench-' . rand(), rand()) },
        'vc:20_get'   => sub { $vc->get('foo') },
        'vc:21_get_r' => sub { $vc->get('bench-' . rand()) },
        # '30_incr'   => sub { $vc->incr('counter') },
        # '30_incr_r' => sub { $vc->incr('bench-' . rand()) },
        # '40_lpush'  => sub { $vc->lpush('mylist', 'bar') },
        # '40_lpush'  => sub { $vc->lpush('mylist', 'bar') },
        # '50_lpop'   => sub { $vc->lpop('mylist') },
        # '90_h_set'  => sub { $hash{ 'test' . rand() } = rand() },
        # '90_h_get'  => sub { my $a = $hash{ 'test' . rand() }; },
    },
    'none'
);

cmpthese(%{$rlog}, %{$rflog}, %{$vclog});
