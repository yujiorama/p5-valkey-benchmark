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

        if (defined $self->{element}) {
            return [ map { $_->value } @{$self->{element}} ];
        }

        return $self->{str} // $self->{integer};
    }
};

sub new {
    my ($class, %args) = @_;

    my $self = __PACKAGE__->_new($args{verbose} // 0);

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

    if (defined $result) {
        my $reftype = ref($result);

        if ($reftype eq 'ARRAY') {
            return Valkey::XS::ValkeyReply->new(+{
                element => [ map { Valkey::XS::ValkeyReply->new($_) } @{ $result } ],
            });
        } elsif ($reftype eq 'HASH') {
            return Valkey::XS::ValkeyReply->new($result);
        } else {
            return Valkey::XS::ValkeyReply->new(+{str => "$result"});
        }
    }

    return Valkey::XS::ValkeyReply->new(+{});
}

sub errstr {
    my ($self) = @_;
    return $self->_errstr;
}

1;
