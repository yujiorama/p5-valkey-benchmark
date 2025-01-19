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

    my $ping = $self->{ffi}->command("PING");

    if ( !defined $ping ) {
        return $self->{ffi}->errstr;
    }

    return $ping->value;
}

sub set {
    my ($self, $key, $value) = @_;

    my $set = $self->{ffi}->command("SET", [ $key, $value ]);

    if ( !defined $set ) {
        return $self->{ffi}->errstr;
    }

    return $set->value;
}

sub setnx {
    my ($self, $key, $value) = @_;

    my $setnx = $self->{ffi}->command("SETNX", [ $key, $value ]);

    if ( !defined $setnx ) {
        return $self->{ffi}->errstr;
    }

    return $setnx->value;
}

sub get {
    my ($self, $key) = @_;

    my $get = $self->{ffi}->command("GET", [ $key ]);

    if ( !defined $get ) {
        return $self->{ffi}->errstr;
    }

    return $get->value;
}

sub exists {
    my ($self, @keys) = @_;

    if ( ref $keys[0] eq 'ARRAY' ) {
        @keys = @{ $keys[0] };
    }

    my $exists = $self->{ffi}->command("EXISTS", \@keys);

    if ( !defined $exists ) {
        return $self->{ffi}->errstr;
    }

    return $exists->value;
}

sub del {
    my ($self, @keys) = @_;

    if ( ref $keys[0] eq 'ARRAY' ) {
        @keys = @{ $keys[0] };
    }

    my $del = $self->{ffi}->command("DEL", \@keys);

    if ( !defined $del ) {
        return $self->{ffi}->errstr;
    }

    return $del->value;
}

sub mget {
    my ($self, @keys) = @_;

    if ( ref $keys[0] eq 'ARRAY' ) {
        @keys = @{ $keys[0] };
    }

    my $mget = $self->{ffi}->command("MGET", \@keys);

    if ( !defined $mget ) {
        return $self->{ffi}->errstr;
    }

    return $mget->value;
}

1;
