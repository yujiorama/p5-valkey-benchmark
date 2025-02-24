use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Valkey::XS',
    VERSION_FROM => 'lib/Valkey/XS.pm',                                    # finds $VERSION
    LIBS         => [ '-lvalkey' ],                                        # an example library
    INC          => "-I/usr/local/include/valkey -I$Config{archlib}/CORE", # include path
    OBJECT       => '$(O_FILES)',                                          # ensure object files are included
    XS           => { 'Valkey.xs' => 'Valkey.c' },
    PM           => { 'lib/Valkey/XS.pm' => '$(INST_LIBDIR)/Valkey/XS.pm' },
);
