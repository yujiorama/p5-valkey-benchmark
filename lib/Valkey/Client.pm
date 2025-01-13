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

    my $pong = $self->{ffi}->command("PING");

    if ($pong->str() eq "PONG") {
        return $pong->str();
    }

    return 0;
}

sub set {
    my ($self, $key, $value) = @_;

    my $ok = $self->{ffi}->command("SET", [$key, $value]);

    if ($ok->str() eq "OK") {
        return $ok->str();
    }

    return 0;
}

sub setnx {
    my ($self, $key, $value) = @_;

    my $ok = $self->{ffi}->command("SETNX", [$key, $value]);

    if ($ok->str() eq "OK") {
        return $ok->str();
    }

    return 0;
}

sub get {
    my ($self, $key) = @_;

    my $ok = $self->{ffi}->command("GET", [$key]);

    return $ok->str();
}

1;
