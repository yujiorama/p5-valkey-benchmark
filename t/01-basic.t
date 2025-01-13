use strict;
use warnings;
use utf8;

use Test2::V0;

use ValKey::Client;

ok lives {
    my $valkey = Valkey::Client->new(hostname => 'valkey', port => 6379);
    ok($valkey->ping, 'ping');
} or die $@;

done_testing();
