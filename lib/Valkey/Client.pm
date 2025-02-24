package Valkey::Client;
use strict;
use warnings;
use utf8;

use Carp qw(croak);

sub new {
    my ($class, %args) = @_;

    my $use_ffi = $args{use_ffi} // 0;

    if ($use_ffi == 1) {
        my $self = eval {
            require Valkey::FFI;
            Valkey::FFI->import;

            return bless +{
                delegate => Valkey::FFI->new(%args),
            }, $class;
        };

        if ($@) {
            croak "Valkey::FFI not available: $@";
        }

        return $self;
    }

    my $self = eval {
        require Valkey::XS;
        Valkey::XS->import;

        return bless +{
            delegate => Valkey::XS->new(%args),
        }, $class;
    };

    if ($@) {
        croak "Valkey::XS not available: $@";
    }

    return $self;
}

sub ping {
    my ($self) = @_;

    my $ping = $self->{delegate}->command("PING");

    if ( !defined $ping ) {
        return undef;
    }

    return $ping->value;
}

sub set {
    my ($self, $key, $value) = @_;

    my $set = $self->{delegate}->command("SET", [ $key, $value ]);

    if ( !defined $set ) {
        return undef;
    }

    return $set->value;
}

sub setnx {
    my ($self, $key, $value) = @_;

    my $setnx = $self->{delegate}->command("SETNX", [ $key, $value ]);

    if ( !defined $setnx ) {
        return undef;
    }

    return $setnx->value;
}

sub get {
    my ($self, $key) = @_;

    my $get = $self->{delegate}->command("GET", [ $key ]);

    if ( !defined $get ) {
        return $self->{delegate}->errstr;
    }

    return $get->value;
}

sub exists {
    my ($self, @keys) = @_;

    if ( ref $keys[0] eq 'ARRAY' ) {
        @keys = @{ $keys[0] };
    }

    my $exists = $self->{delegate}->command("EXISTS", \@keys);

    if ( !defined $exists ) {
        return undef;
    }

    return $exists->value;
}

sub del {
    my ($self, @keys) = @_;

    if ( ref $keys[0] eq 'ARRAY' ) {
        @keys = @{ $keys[0] };
    }

    my $del = $self->{delegate}->command("DEL", \@keys);

    if ( !defined $del ) {
        return undef;
    }

    return $del->value;
}

sub mget {
    my ($self, @keys) = @_;

    if ( ref $keys[0] eq 'ARRAY' ) {
        @keys = @{ $keys[0] };
    }

    my $mget = $self->{delegate}->command("MGET", \@keys);

    if ( !defined $mget ) {
        return undef;
    }

    return $mget->value;
}

sub errstr {
    my ($self) = @_;
    return $self->{delegate}->errstr;
}

1;
