use strict;
use warnings;
use utf8;

use Test2::V0;

use Valkey::XS;

ok lives {
    Valkey::XS::hello_world();
};

done_testing();

