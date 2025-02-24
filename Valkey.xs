#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "valkey.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

typedef struct {
    valkeyContext *context;
} valkey_xs_t, *Valkey__XS;

typedef struct {
    SV* result;
    SV* error;
} valkey_xs_reply_t;

static valkey_xs_reply_t Valkey__XS_decode_reply(valkeyReply *reply) {
    valkey_xs_reply_t ret = {NULL, NULL};
    HV *hv;
    AV *av;

    switch (reply->type) {
    case VALKEY_REPLY_ERROR:
        ret.error = sv_2mortal(newSVpv(reply->str, reply->len));
        break;
    case VALKEY_REPLY_NIL:
        break;
    case VALKEY_REPLY_INTEGER:
    case VALKEY_REPLY_BOOL:
        hv = (HV *)sv_2mortal((SV *)newHV());
        hv_stores(hv, "type", SvREFCNT_inc(sv_2mortal(newSViv(reply->type))));
        hv_stores(hv, "integer", SvREFCNT_inc(sv_2mortal(newSViv(reply->integer))));
        ret.result = sv_2mortal(newRV_inc((SV*)hv));
        break;
    case VALKEY_REPLY_STRING:
    case VALKEY_REPLY_STATUS:
    case VALKEY_REPLY_BIGNUM:
    case VALKEY_REPLY_VERB:
        hv = (HV *)sv_2mortal((SV *)newHV());
        hv_stores(hv, "type", SvREFCNT_inc(sv_2mortal(newSViv(reply->type))));
        hv_stores(hv, "str", SvREFCNT_inc(sv_2mortal(newSVpv(reply->str, reply->len))));
        ret.result = sv_2mortal(newRV_inc((SV*)hv));
        break;
    case VALKEY_REPLY_ARRAY:
    case VALKEY_REPLY_MAP:
    case VALKEY_REPLY_SET:
        size_t i;
        av = (AV *)sv_2mortal((SV *)newAV());
        ret.result = sv_2mortal(newRV_inc((SV*)av));

        for (i = 0; i < reply->elements; i++) {
            valkey_xs_reply_t element = Valkey__XS_decode_reply(reply->element[i]);
            if (element.result) {
                av_push(av, SvREFCNT_inc(element.result));
            } else {
                av_push(av, &PL_sv_undef);
            }

            if (element.error) {
                ret.error = SvREFCNT_inc(element.error);
            }
        }
        break;
    }

    return ret;
}

MODULE = Valkey::XS    PACKAGE = Valkey::XS

PROTOTYPES: ENABLE

void
hello_world()
  CODE:
    printf("Hello, World from XS!\n");

Valkey::XS
_new(const char *cls);
CODE:
{
    fprintf(stderr, "new\n");
    PERL_UNUSED_VAR(cls);
    Newxz(RETVAL, sizeof(valkey_xs_t), valkey_xs_t);
    RETVAL->context = NULL;
}
OUTPUT:
    RETVAL

void
_connect(Valkey::XS self, const char *hostname, int port);
CODE:
{
    struct addrinfo hints, *res;
    struct in_addr addr;
    int err;
    char *ip;

    fprintf(stderr, "_connect\n");
    if (self->context) {
        valkeyFree(self->context);
        self->context = NULL;
    }

    memset(&hints, 0, sizeof(hints));
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_family = AF_INET;
    if ((err = getaddrinfo(hostname, NULL, &hints, &res)) != 0) {
        croak("getaddrinfo: %s", gai_strerror(err));
    }
    addr.s_addr = ((struct sockaddr_in *)res->ai_addr)->sin_addr.s_addr;
    ip = inet_ntoa(addr);

    self->context = valkeyConnect(ip, port);

    freeaddrinfo(res);
}

void
_command(Valkey::XS self, ...);
PREINIT:
    valkey_xs_reply_t ret;
    valkeyReply *reply;
    int argc, i;
    char **argv;
    size_t *argvlen;
    STRLEN len;
CODE:
{
    fprintf(stderr, "_command\n");
    if (!self->context) {
        croak("Not connected to valkey server");
    }

    argc = items - 1;
    Newx(argv, sizeof(char*) * argc, char*);
    Newx(argvlen, sizeof(size_t) * argc, size_t);

    for (i = 0; i < argc; i++) {
        if(!sv_utf8_downgrade(ST(i + 1), 1)) {
            croak("command sent is not an octet sequence in the native encoding (Latin-1). Consider using debug mode to see the command itself.");
        }
        argv[i] = SvPV(ST(i + 1), len);
        argvlen[i] = len;
    }
    fprintf(stderr, "command: %s\n", argv[0]);
    reply = (valkeyReply *)valkeyCommandArgv(self->context, argc, (const char**)argv, argvlen);
    ret = Valkey__XS_decode_reply(reply);
    freeReplyObject(reply);
    Safefree(argv);
    Safefree(argvlen);

    ST(0) = ret.result ? ret.result : &PL_sv_undef;
    ST(1) = ret.error ? ret.error : &PL_sv_undef;
    XSRETURN(2);
}

SV*
_errstr(Valkey::XS self);
CODE:
{
    if (self->context && self->context->errstr) {
        RETVAL = sv_2mortal(newSVpv(self->context->errstr, 0));
    } else {
        RETVAL = &PL_sv_undef;
    }
}
OUTPUT:
    RETVAL

void
DESTROY(Valkey::XS self);
CODE:
{
    fprintf(stderr, "destroy\n");
    if (self->context) {
        valkeyFree(self->context);
        self->context = NULL;
    }
    Safefree(self);
}
