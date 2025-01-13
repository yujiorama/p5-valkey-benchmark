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

package Valkey::FFI::ValkeyReadTask {
    # typedef struct valkeyReadTask {
    #     int type;
    #     long long elements;            /* number of elements in multibulk container */
    #     int idx;                       /* index in parent (array) object */
    #     void *obj;                     /* holds user-generated value for a read task */
    #     struct valkeyReadTask *parent; /* parent task */
    #     void *privdata;                /* user-settable arbitrary field */
    # } valkeyReadTask;
    FFI::C->struct(
        valkey_read_task => [
            type     => 'int',
            elements => 'sint64',
            idx      => 'int',
            obj      => 'opaque',
            _parent  => 'opaque', # Pointer to parent task
            privdata => 'opaque', # User-settable arbitrary field
        ]
    );

    sub parent {
        my $self = shift;
        $ffi->cast('opaque' => 'valkey_read_task', $self->_parent);
    }
}

package Valkey::FFI::ValkeyReplyObjectFunctions {
    # typedef struct valkeyReplyObjectFunctions {
    #     void *(*createString)(const valkeyReadTask *, char *, size_t);
    #     void *(*createArray)(const valkeyReadTask *, size_t);
    #     void *(*createInteger)(const valkeyReadTask *, long long);
    #     void *(*createDouble)(const valkeyReadTask *, double, char *, size_t);
    #     void *(*createNil)(const valkeyReadTask *);
    #     void *(*createBool)(const valkeyReadTask *, int);
    #     void (*freeObject)(void *);
    # } valkeyReplyObjectFunctions;
    FFI::C->struct(
        valkey_reply_object_functions => [
            _create_string  => 'opaque', # Pointer to function
            _create_array   => 'opaque', # Pointer to function
            _create_integer => 'opaque', # Pointer to function
            _create_double  => 'opaque', # Pointer to function
            _create_nil     => 'opaque', # Pointer to function
            _create_bool    => 'opaque', # Pointer to function
            _free_object    => 'opaque', # Pointer to function
        ]
    );

    sub create_string {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_read_task*, string, size_t)->opaque', $self->_create_string);
    }

    sub create_array {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_read_task*, size_t)->opaque', $self->_create_array);
    }

    sub create_integer {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_read_task*, sint64)->opaque', $self->_create_integer);
    }

    sub create_double {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_read_task*, double, string, size_t)->opaque', $self->_create_double);
    }

    sub create_nil {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_read_task*)->opaque', $self->_create_nil);
    }

    sub create_bool {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_read_task*, int)->opaque', $self->_create_bool);
    }

    sub free_object {
        my $self = shift;
        $ffi->cast('opaque' => '(opaque)->void', $self->_free_object);
    }
}

package Valkey::FFI::ValkeyReader {
    # typedef struct valkeyReader {
    #     int err;          /* Error flags, 0 when there is no error */
    #     char errstr[128]; /* String representation of error when applicable */
    #
    #     char *buf;             /* Read buffer */
    #     size_t pos;            /* Buffer cursor */
    #     size_t len;            /* Buffer length */
    #     size_t maxbuf;         /* Max length of unused buffer */
    #     long long maxelements; /* Max multi-bulk elements */
    #
    #     valkeyReadTask **task;
    #     int tasks;
    #
    #     int ridx;    /* Index of current read task */
    #     void *reply; /* Temporary reply pointer */
    #
    #     valkeyReplyObjectFunctions *fn;
    #     void *privdata;
    # } valkeyReader;
    FFI::C->struct(
        valkey_reader => [
            err         => 'int',
            _errstr     => 'opaque',
            buf         => 'opaque',
            pos         => 'size_t',
            len         => 'size_t',
            maxbuf      => 'size_t',
            maxelements => 'sint64',
            _task       => 'opaque',
            tasks       => 'int',
            ridx        => 'int',
            reply       => 'opaque',
            _fn         => 'opaque',
            privdata    => 'opaque',
        ]
    );

    sub errstr {
        my $self = shift;
        $ffi->cast('opaque' => 'string', $self->_errstr);
    }

    sub task {
        my $self = shift;
        $ffi->cast('opaque' => 'valkey_read_task*', $self->_task);
    }

    sub fn {
        my $self = shift;
        $ffi->cast('opaque' => 'valkey_reply_object_functions', $self->_fn);
    }
}

package Valkey::FFI::ValkeyContextFuncs {
    # typedef struct valkeyContextFuncs {
    #     int (*connect)(struct valkeyContext *, const valkeyOptions *);
    #     void (*close)(struct valkeyContext *);
    #     void (*free_privctx)(void *);
    #     void (*async_read)(struct valkeyAsyncContext *);
    #     void (*async_write)(struct valkeyAsyncContext *);
    #
    #     /* Read/Write data to the underlying communication stream, returning the
    #      * number of bytes read/written.  In the event of an unrecoverable error
    #      * these functions shall return a value < 0.  In the event of a
    #      * recoverable error, they should return 0. */
    #     sint32 (*read)(struct valkeyContext *, char *, size_t);
    #     sint32 (*write)(struct valkeyContext *);
    #     int (*set_timeout)(struct valkeyContext *, const struct timeval);
    # } valkeyContextFuncs;
    FFI::C->struct(
        valkey_context_funcs => [
            _connect      => 'opaque', # Pointer to function
            _close        => 'opaque', # Pointer to function
            _free_privctx => 'opaque', # Pointer to function
            _async_read   => 'opaque', # Pointer to function
            _async_write  => 'opaque', # Pointer to function
            _read         => 'opaque', # Pointer to function
            _write        => 'opaque', # Pointer to function
            _set_timeout  => 'opaque', # Pointer to function
        ]
    );

    sub connect {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_context*, valkey_options*)->int', $self->_connect);
    }

    sub close {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_context*)->void', $self->_close);
    }

    sub free_privctx {
        my $self = shift;
        $ffi->cast('opaque' => '(opaque)->void', $self->_free_privctx);
    }

    sub async_read {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_async_context*)->void', $self->_async_read);
    }

    sub async_write {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_async_context*)->void', $self->_async_write);
    }

    sub read {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_context*, string, size_t)->sint32', $self->_read);
    }

    sub write {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_context*)->sint32', $self->_write);
    }

    sub set_timeout {
        my $self = shift;
        $ffi->cast('opaque' => '(valkey_context*, timeval)->int', $self->_set_timeout);
    }
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
    FFI::C->struct(valkey_reply => [
        type     => 'int',
        integer  => 'sint64',
        dval     => 'double',
        len      => 'size_t',
        _str     => 'opaque',
        _vtypes  => 'opaque',
        elements => 'size_t',
        _element => 'opaque',
    ]);

    sub str {
        my $self = shift;
        $ffi->cast('opaque' => 'string', $self->_str);
    }

    sub vtypes {
        my $self = shift;
        $ffi->cast('opaque' => 'string(4)', $self->_vtypes);
    }

    sub element {
        my $self = shift;
        $ffi->cast('opaque' => 'valkey_reply*', $self->_element);
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

# valkeyContext *valkeyConnectWithOptions(const valkeyOptions *options);
$ffi->attach(valkeyConnectWithOptions => [ 'valkey_options' ] => 'valkey_context');
# valkeyContext *valkeyConnect(const char *ip, int port);
$ffi->attach(valkeyConnect => [ 'string', 'int' ] => 'valkey_context');
# valkeyContext *valkeyConnectWithTimeout(const char *ip, int port, const struct timeval tv);
$ffi->attach(valkeyConnectWithTimeout => [ 'string', 'int', 'timeval' ] => 'valkey_context');
# valkeyContext *valkeyConnectNonBlock(const char *ip, int port);
$ffi->attach(valkeyConnectNonBlock => [ 'string', 'int' ] => 'valkey_context');
# valkeyContext *valkeyConnectBindNonBlock(const char *ip, int port,
#                                          const char *source_addr);
$ffi->attach(valkeyConnectBindNonBlock => [ 'string', 'int', 'string' ] => 'valkey_context');
# valkeyContext *valkeyConnectBindNonBlockWithReuse(const char *ip, int port,
#                                                   const char *source_addr);
$ffi->attach(valkeyConnectBindNonBlockWithReuse => [ 'string', 'int', 'string' ] => 'valkey_context');
# valkeyContext *valkeyConnectUnix(const char *path);
$ffi->attach(valkeyConnectUnix => [ 'string' ] => 'valkey_context');
# valkeyContext *valkeyConnectUnixWithTimeout(const char *path, const struct timeval tv);
$ffi->attach(valkeyConnectUnixWithTimeout => [ 'string', 'timeval' ] => 'valkey_context');
# valkeyContext *valkeyConnectUnixNonBlock(const char *path);
$ffi->attach(valkeyConnectUnixNonBlock => [ 'string' ] => 'valkey_context');
# valkeyContext *valkeyConnectFd(uint64 fd);
$ffi->attach(valkeyConnectFd => [ 'uint64' ] => 'valkey_context');
#
# /**
#  * Reconnect the given context using the saved information.
#  *
#  * This re-uses the exact same connect options as in the initial connection.
#  * host, ip (or path), timeout and bind address are reused,
#  * flags are used unmodified from the existing context.
#  *
#  * Returns VALKEY_OK on successful connect or VALKEY_ERR otherwise.
#  */
# int valkeyReconnect(valkeyContext *c);
$ffi->attach(valkeyReconnect => [ 'valkey_context' ] => 'int');
#
# valkeyPushFn *valkeySetPushCallback(valkeyContext *c, valkeyPushFn *fn);
$ffi->attach(valkeySetPushCallback => [ 'valkey_context', 'opaque' ] => 'opaque');
# int valkeySetTimeout(valkeyContext *c, const struct timeval tv);
$ffi->attach(valkeySetTimeout => [ 'valkey_context', 'timeval' ] => 'int');
#
# /* Configurations using socket options. Applied directly to the underlying
#  * socket and not automatically applied after a reconnect. */
# int valkeyEnableKeepAlive(valkeyContext *c);
$ffi->attach(valkeyEnableKeepAlive => [ 'valkey_context' ] => 'int');
# int valkeyEnableKeepAliveWithInterval(valkeyContext *c, int interval);
$ffi->attach(valkeyEnableKeepAliveWithInterval => [ 'valkey_context', 'int' ] => 'int');
# int valkeySetTcpUserTimeout(valkeyContext *c, unsigned int timeout);
$ffi->attach(valkeySetTcpUserTimeout => [ 'valkey_context', 'uint' ] => 'int');
#
# void valkeyFree(valkeyContext *c);
$ffi->attach(valkeyFree => [ 'valkey_context' ] => 'void');
# uint64 valkeyFreeKeepFd(valkeyContext *c);
$ffi->attach(valkeyFreeKeepFd => [ 'valkey_context' ] => 'uint64');
# int valkeyBufferRead(valkeyContext *c);
$ffi->attach(valkeyBufferRead => [ 'valkey_context' ] => 'int');
# int valkeyBufferWrite(valkeyContext *c, int *done);
$ffi->attach(valkeyBufferWrite => [ 'valkey_context', 'opaque' ] => 'int');
#
# /* In a blocking context, this function first checks if there are unconsumed
#  * replies to return and returns one if so. Otherwise, it flushes the output
#  * buffer to the socket and reads until it has a reply. In a non-blocking
#  * context, it will return unconsumed replies until there are no more. */
# int valkeyGetReply(valkeyContext *c, void **reply);
$ffi->attach(valkeyGetReply => [ 'valkey_context', 'opaque' ] => 'int');
# int valkeyGetReplyFromReader(valkeyContext *c, void **reply);
$ffi->attach(valkeyGetReplyFromReader => [ 'valkey_context', 'opaque' ] => 'int');
#
# /* Write a formatted command to the output buffer. Use these functions in blocking mode
#  * to get a pipeline of commands. */
# int valkeyAppendFormattedCommand(valkeyContext *c, const char *cmd, size_t len);
$ffi->attach(valkeyAppendFormattedCommand => [ 'valkey_context', 'string', 'size_t' ] => 'int');
#
# /* Write a command to the output buffer. Use these functions in blocking mode
#  * to get a pipeline of commands. */
# int valkeyvAppendCommand(valkeyContext *c, const char *format, va_list ap);
$ffi->attach(valkeyvAppendCommand => [ 'valkey_context', 'string', 'char*' ] => 'int');
# int valkeyAppendCommand(valkeyContext *c, const char *format, ...);
$ffi->attach(valkeyAppendCommand => [ 'valkey_context', 'string' ] => [ 'int' ] => 'int');
# int valkeyAppendCommandArgv(valkeyContext *c, int argc, const char **argv, const size_t *argvlen);
$ffi->attach(valkeyAppendCommandArgv => [ 'valkey_context', 'int', 'string*', 'size_t*' ] => 'int');
#
# /* Issue a command to Valkey. In a blocking context, it is identical to calling
#  * valkeyAppendCommand, followed by valkeyGetReply. The function will return
#  * NULL if there was an error in performing the request, otherwise it will
#  * return the reply. In a non-blocking context, it is identical to calling
#  * only valkeyAppendCommand and will always return NULL. */
# void *valkeyvCommand(valkeyContext *c, const char *format, va_list ap);
$ffi->attach(valkeyvCommand => [ 'valkey_context', 'string', 'char*' ] => 'opaque');
# void *valkeyCommand(valkeyContext *c, const char *format, ...);
$ffi->attach(valkeyCommand => [ 'valkey_context', 'string' ] => [ 'int' ] => 'opaque');
# void *valkeyCommandArgv(valkeyContext *c, int argc, const char **argv, const size_t *argvlen);
$ffi->attach(valkeyCommandArgv => [ 'valkey_context', 'int', 'string*', 'size_t*' ] => 'opaque');

sub new {
    my ($class, %args) = @_;

    my $hostname = $args{hostname} // 'localhost';
    my $port = $args{port} // 6379;

    my $packed_ip = gethostbyname($hostname);
    if (! defined $packed_ip) {
        croak "gethostbyname failed";
    }
    my $ip_address = inet_ntoa($packed_ip);

    my $valkey_context = valkeyConnect($ip_address, $port);
    if (! defined $valkey_context ) {
        croak "valkeyConnect failed";
    }
    if ($valkey_context->err) {
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
    my $opaque = valkeyCommandArgv($self->{valkey_context}, $argc, $argv, $argvlen);
    my $reply = $ffi->cast('opaque' => 'valkey_reply', $opaque);
    return $reply;
}

1;
