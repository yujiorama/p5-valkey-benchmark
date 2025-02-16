package Valkey::FFI;

use strict;
use warnings;
use utf8;

use FFI::Platypus 2.00;
use FFI::CheckLib qw(find_lib_or_die);
use FFI::C;

use Carp qw(croak);
use Socket qw(inet_ntoa);

our $ffi = FFI::Platypus->new(api => 2);

$ffi->lib(find_lib_or_die(lib => 'valkey'));

FFI::C->ffi($ffi);

package Valkey::FFI::Timeval {
    FFI::C->struct(
        timeval => [
            tv_sec  => 'long',
            tv_usec => 'long',
        ]
    );
}

package Valkey::FFI::Tcp {
    FFI::C->struct(
        tcp => [
            source_addr => 'opaque', # Pointer to char
            ip          => 'opaque', # Pointer to char
            port        => 'int',
        ]
    );
}

package Valkey::FFI::UnixSock {
    FFI::C->struct(
        unix_sock => [
            path => 'opaque', # Pointer to char
        ]
    );
}

package Valkey::FFI::SockAddr {
    FFI::C->struct(
        sockaddr => [
            sa_family => 'uint32',
            sa_data   => 'opaque',
        ]
    );
}

package Valkey::FFI::ValkeyConnectionType {
    # enum valkeyConnectionType {
    #     VALKEY_CONN_TCP,
    #     VALKEY_CONN_UNIX,
    #     VALKEY_CONN_USERFD,
    #     VALKEY_CONN_RDMA, /* experimental, may be removed in any version */
    #
    #     VALKEY_CONN_MAX
    # };
    FFI::C->enum(
        valkey_connection_type => [ qw(
            VALKEY_CONN_TCP
            VALKEY_CONN_UNIX
            VALKEY_CONN_USERFD
            VALKEY_CONN_RDMA
            VALKEY_CONN_MAX
        ) ],
        { rev => 'int', package => 'Valkey::FFI::ValkeyConnectionType' }
    );
}

package Valkey::FFI::ValkeyContext {
    # /* Connection type can be blocking or non-blocking and is set in the
    #  * least significant bit of the flags field in valkeyContext. */
    # #define VALKEY_BLOCK 0x1
    use constant VALKEY_BLOCK => 0x1;
    #
    # /* Connection may be disconnected before being free'd. The second bit
    #  * in the flags field is set when the context is connected. */
    # #define VALKEY_CONNECTED 0x2
    use constant VALKEY_CONNECTED => 0x2;
    #
    # /* The async API might try to disconnect cleanly and flush the output
    #  * buffer and read all subsequent replies before disconnecting.
    #  * This flag means no new commands can come in and the connection
    #  * should be terminated once all replies have been read. */
    # #define VALKEY_DISCONNECTING 0x4
    use constant VALKEY_DISCONNECTING => 0x4;
    #
    # /* Flag specific to the async API which means that the context should be clean
    #  * up as soon as possible. */
    # #define VALKEY_FREEING 0x8
    use constant VALKEY_FREEING => 0x8;
    #
    # /* Flag that is set when an async callback is executed. */
    # #define VALKEY_IN_CALLBACK 0x10
    use constant VALKEY_IN_CALLBACK => 0x10;
    #
    # /* Flag that is set when the async context has one or more subscriptions. */
    # #define VALKEY_SUBSCRIBED 0x20
    use constant VALKEY_SUBSCRIBED => 0x20;
    #
    # /* Flag that is set when monitor mode is active */
    # #define VALKEY_MONITORING 0x40
    use constant VALKEY_MONITORING => 0x40;
    #
    # /* Flag that is set when we should set SO_REUSEADDR before calling bind() */
    # #define VALKEY_REUSEADDR 0x80
    use constant VALKEY_REUSEADDR => 0x80;
    #
    # /* Flag that is set when the async connection supports push replies. */
    # #define VALKEY_SUPPORTS_PUSH 0x100
    use constant VALKEY_SUPPORTS_PUSH => 0x100;
    #
    # /**
    #  * Flag that indicates the user does not want the context to
    #  * be automatically freed upon error
    #  */
    # #define VALKEY_NO_AUTO_FREE 0x200
    use constant VALKEY_NO_AUTO_FREE => 0x200;
    #
    # /* Flag that indicates the user does not want replies to be automatically freed */
    # #define VALKEY_NO_AUTO_FREE_REPLIES 0x400
    use constant VALKEY_NO_AUTO_FREE_REPLIES => 0x400;
    #
    # /* Flags to prefer IPv6 or IPv4 when doing DNS lookup. (If both are set,
    #  * AF_UNSPEC is used.) */
    # #define VALKEY_PREFER_IPV4 0x800
    # #define VALKEY_PREFER_IPV6 0x1000
    use constant VALKEY_PREFER_IPV4 => 0x800;
    use constant VALKEY_PREFER_IPV6 => 0x1000;

    # /* Context for a connection to Valkey */
    # typedef struct valkeyContext {
    #     const valkeyContextFuncs *funcs; /* Function table */
    #
    #     int err;          /* Error flags, 0 when there is no error */
    #     char errstr[128]; /* String representation of error when applicable */
    #     uint64 fd;
    #     int flags;
    #     char *obuf;           /* Write buffer */
    #     valkeyReader *reader; /* Protocol reader */
    #
    #     enum valkeyConnectionType connection_type;
    #     struct timeval *connect_timeout;
    #     struct timeval *command_timeout;
    #
    #     struct {
    #         char *host;
    #         char *source_addr;
    #         int port;
    #     } tcp;
    #
    #     struct {
    #         char *path;
    #     } unix_sock;
    #
    #     /* For non-blocking connect */
    #     struct sockaddr *saddr;
    #     size_t addrlen;
    #
    #     /* Optional data and corresponding destructor users can use to provide
    #      * context to a given valkeyContext.  Not used by libvalkey. */
    #     void *privdata;
    #     void (*free_privdata)(void *);
    #
    #     /* Internal context pointer presently used by libvalkey to manage
    #      * TLS connections. */
    #     void *privctx;
    #
    #     /* An optional RESP3 PUSH handler */
    #     valkeyPushFn *push_cb;
    # } valkeyContext;
    FFI::C->struct(
        valkey_context => [
            _funcs           => 'opaque', # Pointer to valkey_context_funcs
            err              => 'int',
            _errstr          => 'opaque',
            fd               => 'uint64',
            flags            => 'int',
            obuf             => 'opaque',
            _reader          => 'opaque', # Pointer to valkey_reader
            connection_type  => 'valkey_connection_type',
            _connect_timeout => 'opaque', # Pointer to timeval
            _command_timeout => 'opaque', # Pointer to timeval
            tcp              => 'tcp',
            unix_sock        => 'unix_sock',
            _saddr           => 'opaque', # Pointer to sockaddr
            addrlen          => 'size_t',
            privdata         => 'opaque', # Pointer to user-defined data
            _free_privdata   => 'opaque', # Pointer to function
            privctx          => 'opaque', # Pointer to internal context
            _push_cb         => 'opaque', # Pointer to function
        ]
    );

    sub funcs {
        my $self = shift;
        $ffi->cast('opaque' => 'valkey_context_funcs*', $self->_funcs);
    }

    sub errstr {
        my $self = shift;
        $ffi->cast('opaque' => 'string', $self->_errstr);
    }

    sub reader {
        my $self = shift;
        $ffi->cast('opaque' => 'valkey_reader*', $self->_reader);
    }

    sub connect_timeout {
        my $self = shift;
        $ffi->cast('opaque' => 'timeval', $self->_connect_timeout);
    }

    sub command_timeout {
        my $self = shift;
        $ffi->cast('opaque' => 'timeval', $self->_command_timeout);
    }

    sub saddr {
        my $self = shift;
        $ffi->cast('opaque' => 'sockaddr', $self->_saddr);
    }

    sub free_privdata {
        my $self = shift;
        $ffi->cast('opaque' => '(opaque)->void', $self->_free_privdata);
    }

    sub push_cb {
        my $self = shift;
        $ffi->cast('opaque' => '(opaque, opaque)->void', $self->_push_cb);
    }
}

package Valkey::FFI::ValkeyReply {
    # read.h
    # - `VALKEY_REPLY_STRING` - A string reply which will be in `reply->str`.
    # #define VALKEY_REPLY_STRING 1
    use constant VALKEY_REPLY_STRING => 1;
    # - `VALKEY_REPLY_ARRAY` - An array reply where each element is in `reply->element` with the number of elements in `reply->element`.
    # #define VALKEY_REPLY_ARRAY 2
    use constant VALKEY_REPLY_ARRAY => 2;
    # - `VALKEY_REPLY_INTEGER` - An integer reply, which will be in `reply->integer`.
    # #define VALKEY_REPLY_INTEGER 3
    use constant VALKEY_REPLY_INTEGER => 3;
    # - `VALKEY_REPLY_NIL` - a nil reply.
    # #define VALKEY_REPLY_NIL 4
    use constant VALKEY_REPLY_NIL => 4;
    # - `VALKEY_REPLY_STATUS` - A status reply which will be in `reply->str`.
    # #define VALKEY_REPLY_STATUS 5
    use constant VALKEY_REPLY_STATUS => 5;
    # - `VALKEY_REPLY_ERROR` - An error reply. The error string is in `reply->str`.
    # #define VALKEY_REPLY_ERROR 6
    use constant VALKEY_REPLY_ERROR => 6;
    # - `VALKEY_REPLY_DOUBLE` - A double reply which will be in `reply->dval` as well as `reply->str`.
    # #define VALKEY_REPLY_DOUBLE 7
    use constant VALKEY_REPLY_DOUBLE => 7;
    # - `VALKEY_REPLY_BOOL` - A boolean reply which will be in `reply->integer`.
    # #define VALKEY_REPLY_BOOL 8
    use constant VALKEY_REPLY_BOOL => 8;
    # - `VALKEY_REPLY_MAP` - A map reply, which structurally looks just like `VALKEY_REPLY_ARRAY` only is meant to represent keys and values. As with an array reply you can access the elements with `reply->element` and `reply->element`.
    # #define VALKEY_REPLY_MAP 9
    use constant VALKEY_REPLY_MAP => 9;
    # - `VALKEY_REPLY_SET` - Another array-like reply representing a set (e.g. a reply from `SMEMBERS`). Access via `reply->element` and `reply->element`.
    # #define VALKEY_REPLY_SET 10
    use constant VALKEY_REPLY_SET => 10;
    # - `VALKEY_REPLY_ATTR` - An attribute reply. As of yet unused by valkey-server.
    # #define VALKEY_REPLY_ATTR 11
    use constant VALKEY_REPLY_ATTR => 11;
    # - `VALKEY_REPLY_PUSH` - An out of band push reply. This is also array-like in nature.
    # #define VALKEY_REPLY_PUSH 12
    use constant VALKEY_REPLY_PUSH => 12;
    # - `VALKEY_REPLY_BIGNUM` - As of yet unused, but the string would be in `reply->str`.
    # #define VALKEY_REPLY_BIGNUM 13
    use constant VALKEY_REPLY_BIGNUM => 13;
    # - `VALKEY_REPLY_VERB` - A verbatim string reply which will be in `reply->str` and who's type will be in `reply->vtype`.
    # #define VALKEY_REPLY_VERB 14
    use constant VALKEY_REPLY_VERB => 14;
    # /* This is the reply object returned by valkeyCommand() */
    # typedef struct valkeyReply {
    #     int type;                     /* VALKEY_REPLY_* */
    #     long long integer;            /* The integer when type is VALKEY_REPLY_INTEGER */
    #     double dval;                  /* The double when type is VALKEY_REPLY_DOUBLE */
    #     size_t len;                   /* Length of string */
    #     char *str;                    /* Used for VALKEY_REPLY_ERROR, VALKEY_REPLY_STRING
    #                                    * VALKEY_REPLY_VERB,
    #                                    * VALKEY_REPLY_DOUBLE (in additional to dval),
    #                                    * and VALKEY_REPLY_BIGNUM. */
    #     char vtype[4];                /* Used for VALKEY_REPLY_VERB, contains the null
    #                                    * terminated 3 character content type,
    #                                    * such as "txt". */
    #     size_t elements;              /* number of elements, for VALKEY_REPLY_ARRAY */
    #     struct valkeyReply **element; /* elements vector for VALKEY_REPLY_ARRAY */
    # } valkeyReply;
    use FFI::Platypus::Record qw(record_layout_1);
    record_layout_1($ffi,
        sint32    => 'type',
        sint32    => ':',
        sint64    => 'integer',
        double    => 'dval',
        size_t    => 'len',
        opaque    => '_str',
        'char[4]' => 'vtype',
        sint32    => ':',
        size_t    => 'elements',
        opaque    => '_element',
    );

    sub str {
        my $self = shift;
        return $ffi->cast('opaque' => 'string', $self->_str);
    }

    sub element {
        my $self = shift;

        my $pointers = $ffi->cast('opaque' => "opaque[" . $self->elements . "]", $self->_element);

        my $elements = [ map {
            $ffi->cast('opaque' => 'valkeyReply', $_)
        } @{$pointers}];

        return $elements;
    }

    sub is_string {
        my $self = shift;
        $self->type == VALKEY_REPLY_STRING;
    };
    sub is_array {
        my $self = shift;
        $self->type == VALKEY_REPLY_ARRAY;
    };
    sub is_integer {
        my $self = shift;
        $self->type == VALKEY_REPLY_INTEGER;
    };
    sub is_nil {
        my $self = shift;
        $self->type == VALKEY_REPLY_NIL;
    };
    sub is_status {
        my $self = shift;
        $self->type == VALKEY_REPLY_STATUS;
    };
    sub is_error {
        my $self = shift;
        $self->type == VALKEY_REPLY_ERROR;
    };
    sub is_double {
        my $self = shift;
        $self->type == VALKEY_REPLY_DOUBLE;
    };
    sub is_bool {
        my $self = shift;
        $self->type == VALKEY_REPLY_BOOL;
    };
    sub is_map {
        my $self = shift;
        $self->type == VALKEY_REPLY_MAP;
    };
    sub is_set {
        my $self = shift;
        $self->type == VALKEY_REPLY_SET;
    };
    sub is_attr {
        my $self = shift;
        $self->type == VALKEY_REPLY_ATTR;
    };
    sub is_push {
        my $self = shift;
        $self->type == VALKEY_REPLY_PUSH;
    };
    sub is_bignum {
        my $self = shift;
        $self->type == VALKEY_REPLY_BIGNUM;
    };
    sub is_verb {
        my $self = shift;
        $self->type == VALKEY_REPLY_VERB;
    };

    sub error {
        my $self = shift;

        if ( $self->is_error ) {
            return $self->str;
        }
    }

    sub value {
        my $self = shift;

        if ( $self->is_error ) {
            return undef;
        }

        if ( $self->is_nil ) {
            return undef;
        }

        if ( $self->is_string || $self->is_status || $self->is_double || $self->is_bignum || $self->is_verb ) {
            return $self->str;
        }

        if ( $self->is_integer || $self->is_bool ) {
            return $self->integer;
        }

        if ( $self->is_array || $self->is_set ) {
            # value, value, value, ...
            return [ map { defined $_ ? $_->value : undef } $self->element->@* ];
        }

        if ( $self->is_map ) {
            # key, value, key, value, ...
            my $kvs = $self->element;
            return { map { $kvs->[$_]->value => $kvs->[$_ + 1]->value } grep { $_ % 2 == 0 } 0 .. $kvs->@* - 1 };
        }

        return undef;
    }
}

package Valkey::FFI::ValkeyOptions::Endpoint {
    FFI::C->union(
        valkey_options_endpoint => [
            tcp          => 'tcp',
            _unix_socket => 'opaque', # Pointer to char
            fd           => 'uint64', # uint64 type
        ]
    );

    sub unix_socket {
        my $self = shift;
        $ffi->cast('opaque' => 'string', $self->_unix_socket);
    }
}

package Valkey::FFI::ValkeyOptions {
    # typedef struct {
    #     /*
    #      * the type of connection to use. This also indicates which
    #      * `endpoint` member field to use
    #      */
    #     int type;
    #     /* bit field of VALKEY_OPT_xxx */
    #     int options;
    #     /* timeout value for connect operation. If NULL, no timeout is used */
    #     const struct timeval *connect_timeout;
    #     /* timeout value for commands. If NULL, no timeout is used.  This can be
    #      * updated at runtime with valkeySetTimeout/valkeyAsyncSetTimeout. */
    #     const struct timeval *command_timeout;
    #     union {
    #         /** use this field for tcp/ip connections */
    #         struct {
    #             const char *source_addr;
    #             const char *ip;
    #             int port;
    #         } tcp;
    #         /** use this field for unix domain sockets */
    #         const char *unix_socket;
    #         /**
    #          * use this field to have libvalkey operate an already-open
    #          * file descriptor */
    #         uint64 fd;
    #     } endpoint;
    #
    #     /* Optional user defined data/destructor */
    #     void *privdata;
    #     void (*free_privdata)(void *);
    #
    #     /* A user defined PUSH message callback */
    #     valkeyPushFn *push_cb;
    #     valkeyAsyncPushFn *async_push_cb;
    # } valkeyOptions;
    FFI::C->struct(
        valkey_options => [
            type             => 'int',
            options          => 'int',
            _connect_timeout => 'opaque', # Pointer to struct timeval
            _command_timeout => 'opaque', # Pointer to struct timeval
            endpoint         => 'valkey_options_endpoint',
            privdata         => 'opaque', # Pointer to user-defined data
            _free_privdata   => 'opaque', # Pointer to function
            _push_cb         => 'opaque', # Pointer to function
            _async_push_cb   => 'opaque', # Pointer to function
        ]
    );

    sub connect_timeout {
        my $self = shift;
        $ffi->cast('opaque' => 'timeval', $self->_connect_timeout);
    }

    sub command_timeout {
        my $self = shift;
        $ffi->cast('opaque' => 'timeval', $self->_command_timeout);
    }

    sub free_privdata {
        my $self = shift;
        $ffi->cast('opaque' => '(opaque)->void', $self->_free_privdata);
    }

    sub push_cb {
        my $self = shift;
        $ffi->cast('opaque' => '(opaque, opaque)->void', $self->_push_cb);
    }

    sub async_push_cb {
        my $self = shift;
        $ffi->cast('opaque' => '(opaque, opaque)->void', $self->_async_push_cb);
    }
}

$ffi->type('record(Valkey::FFI::ValkeyReply)' => 'valkeyReply');

# # valkeyContext *valkeyConnectWithOptions(const valkeyOptions *options);
# $ffi->attach(valkeyConnectWithOptions => [ 'valkey_options' ] => 'valkey_context');
# valkeyContext *valkeyConnect(const char *ip, int port);
$ffi->attach(valkeyConnect => [ 'string', 'int' ] => 'valkey_context');
# # valkeyContext *valkeyConnectWithTimeout(const char *ip, int port, const struct timeval tv);
# $ffi->attach(valkeyConnectWithTimeout => [ 'string', 'int', 'timeval' ] => 'valkey_context');
# # valkeyContext *valkeyConnectNonBlock(const char *ip, int port);
# $ffi->attach(valkeyConnectNonBlock => [ 'string', 'int' ] => 'valkey_context');
# # valkeyContext *valkeyConnectBindNonBlock(const char *ip, int port,
# #                                          const char *source_addr);
# $ffi->attach(valkeyConnectBindNonBlock => [ 'string', 'int', 'string' ] => 'valkey_context');
# # valkeyContext *valkeyConnectBindNonBlockWithReuse(const char *ip, int port,
# #                                                   const char *source_addr);
# $ffi->attach(valkeyConnectBindNonBlockWithReuse => [ 'string', 'int', 'string' ] => 'valkey_context');
# # valkeyContext *valkeyConnectUnix(const char *path);
# $ffi->attach(valkeyConnectUnix => [ 'string' ] => 'valkey_context');
# # valkeyContext *valkeyConnectUnixWithTimeout(const char *path, const struct timeval tv);
# $ffi->attach(valkeyConnectUnixWithTimeout => [ 'string', 'timeval' ] => 'valkey_context');
# # valkeyContext *valkeyConnectUnixNonBlock(const char *path);
# $ffi->attach(valkeyConnectUnixNonBlock => [ 'string' ] => 'valkey_context');
# # valkeyContext *valkeyConnectFd(uint64 fd);
# $ffi->attach(valkeyConnectFd => [ 'uint64' ] => 'valkey_context');
# #
# # /**
# #  * Reconnect the given context using the saved information.
# #  *
# #  * This re-uses the exact same connect options as in the initial connection.
# #  * host, ip (or path), timeout and bind address are reused,
# #  * flags are used unmodified from the existing context.
# #  *
# #  * Returns VALKEY_OK on successful connect or VALKEY_ERR otherwise.
# #  */
# # int valkeyReconnect(valkeyContext *c);
# $ffi->attach(valkeyReconnect => [ 'valkey_context' ] => 'int');

# /* Issue a command to Valkey. In a blocking context, it is identical to calling
#  * valkeyAppendCommand, followed by valkeyGetReply. The function will return
#  * NULL if there was an error in performing the request, otherwise it will
#  * return the reply. In a non-blocking context, it is identical to calling
#  * only valkeyAppendCommand and will always return NULL. */
# void *valkeyvCommand(valkeyContext *c, const char *format, va_list ap);
$ffi->attach(valkeyvCommand => [ 'valkey_context', 'string', 'char*' ] => 'valkeyReply*');
# void *valkeyCommand(valkeyContext *c, const char *format, ...);
$ffi->attach(valkeyCommand => [ 'valkey_context', 'string' ] => [ 'int' ] => 'valkeyReply*');
# void *valkeyCommandArgv(valkeyContext *c, int argc, const char **argv, const size_t *argvlen);
$ffi->attach(valkeyCommandArgv => [ 'valkey_context', 'int', 'string*', 'size_t*' ] => 'valkeyReply*');

sub new {
    my ($class, %args) = @_;

    my $hostname = $args{hostname} // 'localhost';
    my $port = $args{port} // 6379;

    my $packed_ip = gethostbyname($hostname);
    if ( !defined $packed_ip ) {
        croak "gethostbyname failed";
    }
    my $ip_address = inet_ntoa($packed_ip);

    my $valkey_context = valkeyConnect($ip_address, $port);
    if ( !defined $valkey_context ) {
        croak "valkeyConnect failed";
    }
    if ( $valkey_context->err ) {
        croak "valkeyConnect failed: " . $valkey_context->errstr;
    }

    return bless +{
        valkey_context => $valkey_context,
    }, $class;
}

sub command {
    my ($self, $command, $command_args) = @_;

    my $argc = 1 + scalar @{ $command_args // [] };
    my $argv = [ $command, @{ $command_args // [] } ];
    my $argvlen = [ map { length $_ } @{ $argv } ];
    my $reply = valkeyCommandArgv($self->{valkey_context}, $argc, $argv, $argvlen);
    return $reply;
}

sub errstr {
    my ($self) = @_;

    $self->{valkey_context}->errstr // "";
}

1;
