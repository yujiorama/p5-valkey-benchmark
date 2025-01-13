package Valkey::Client;
use strict;
use warnings;
use utf8;

use Carp qw(croak);
use Valkey::FFI;

sub new {
    my ($class, %args) = @_;

    return bless +{
        ffi => Valkey::FFI->new(%args),
    }, $class;
}

sub ping {
    my ($self) = @_;

    my $pingReply = $self->{ffi}->command("PING");

    if ($pingReply->str() eq "PONG") {
        return 1;
    }

    return 0;
}

1;
