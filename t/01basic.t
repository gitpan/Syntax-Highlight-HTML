use strict;
use Test;
BEGIN { plan tests => 9 }
use Syntax::Highlight::HTML;

# check that the following functions are available
ok( defined \&Syntax::Highlight::HTML::new             ); #01
ok( defined \&Syntax::Highlight::HTML::parse           ); #02
ok( defined \&Syntax::Highlight::HTML::_highlight_tag  ); #03
ok( defined \&Syntax::Highlight::HTML::_highlight_text ); #04

# create an object
my $highlighter = new Syntax::Highlight::HTML;
ok( defined $highlighter                               ); #05
ok( $highlighter->isa('Syntax::Highlight::HTML' )      ); #06

# check that the following object methods are available
ok( defined $highlighter->can('parse')                 ); #07
ok( defined $highlighter->can('_highlight_tag')        ); #08
ok( defined $highlighter->can('_highlight_text')       ); #09
