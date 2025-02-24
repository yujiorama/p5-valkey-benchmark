package Valkey::XS;
use strict;
use warnings;
use utf8;

require XSLoader;
our $VERSION = '0.1';
XSLoader::load('Valkey::XS', $VERSION);

1;
