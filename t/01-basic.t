use strict;
use warnings;
use utf8;

use Test2::V0;

use ValKey::Client;

subtest "ping" => sub {
    my $valkey = Valkey::Client->new(hostname => 'valkey', port => 6379);
    ok($valkey->ping, 'ping');
};

subtest "string value" => sub {
    my $valkey = Valkey::Client->new(hostname => 'valkey', port => 6379);

    ok($valkey->set(foo => 'bar'), 'set foo => bar');

    ok(!$valkey->setnx(foo => 'bar'), 'setnx foo => bar fails');

    is $valkey->get('foo'), 'bar', 'get foo = bar';

    ok($valkey->set(foo => ''), 'set foo => ""');

    is $valkey->get('foo'), '', 'get foo = ""';

    ok($valkey->set(foo => 'baz'), 'set foo => baz');

    is $valkey->get('foo'), 'baz', 'get foo = baz';
};


done_testing();
