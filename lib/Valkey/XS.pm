package Valkey::XS;

BEGIN {
    use XSLoader;
    our $VERSION = '0.01';
    XSLoader::load __PACKAGE__, $VERSION;
}

use strict;
use warnings;
use utf8;

use Carp qw(croak);

package Valkey::XS::ValkeyReply {
    sub new {
        my ($class, $result) = @_;

        return bless +{
            str      => $result->{str},
            integer  => $result->{integer},
            type     => $result->{type},
            elements => $result->{elements},
            element  => $result->{element},
        }, $class;
    }

    sub value {
        my ($self) = @_;
        return $self->{str} // $self->{integer} // $self->{element};
    }
};

sub new {
    my ($class, %args) = @_;

    my $self = $class->_new;

    my $hostname = $args{hostname} // 'localhost';
    my $port = $args{port} // 6379;

    $self->_connect($hostname, $port);

    return $self;
}

sub command {
    my ($self, $command, $command_args) = @_;

    my $argv = [ $command, map { $_ . q() } @{ $command_args // [] } ];
    my ($result, $error) = $self->_command(@{ $argv });

    if ( defined $error ) {
        croak $error;
    }

    if (ref $result eq 'HASH') {
        return Valkey::XS::ValkeyReply->new($result);
    }

    if (ref $result eq 'ARRAY') {
        return Valkey::XS::ValkeyReply->new(+{
            element => [ map { Valkey::XS::ValkeyReply->new($_) } @{ $result } ],
        });
    }

    return undef;
}

sub errstr {
    my ($self) = @_;
    return $self->_errstr;
}

1;
