use strict;
use warnings;
use utf8;

use Test2::V0;

use ValKey::Client;

my $valkey = Valkey::Client->new(hostname => 'valkey', port => 6379);

ok($valkey->ping, 'ping');

ok($valkey->set(foo => 'bar'), 'set foo => bar');

ok(!$valkey->setnx(foo => 'bar'), 'setnx foo => bar fails');

is $valkey->get('foo'), 'bar', 'get foo = bar';

ok($valkey->set(foo => ''), 'set foo => ""');

is $valkey->get('foo'), '', 'get foo = ""';

ok($valkey->set(foo => 'baz'), 'set foo => baz');

is $valkey->get('foo'), 'baz', 'get foo = baz';

ok($valkey->set('test-undef' => 42), 'set test-undef');
ok($valkey->exists('test-undef'), 'exists undef');

# Big sized keys
for my $size ( 10_000, 100_000, 500_000, 1_000_000, 2_500_000 ) {
    my $v = 'a' x $size;
    ok($valkey->set('big_key', $v), "set with value size $size ok");
    is($valkey->get('big_key'), $v, "... and get was ok to");
}

$valkey->del('non-existant');
ok(!$valkey->exists('non-existant'), 'exists non-existant');
ok(!defined $valkey->get('non-existant'), 'get non-existant');

my $key_next = '3';
ok($valkey->set('key-next' => '0'), 'key-next = 0');
ok($valkey->set('key-left' => $key_next), 'key-left');

todo "not working" => sub {
    is $valkey->mget('foo'), array {
        item 'baz';
    }, 'mget 1';
    is $valkey->mget('key-next', 'key-left'), array {
        item '0';
        item '3';
    }, 'mget 2';
    is $valkey->mget('foo', 'key-next', 'key-left'), array {
        item 'baz';
        item '0';
        item '3';
    }, 'mget 3';
};

done_testing();
