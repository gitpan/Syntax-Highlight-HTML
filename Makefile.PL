use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Syntax::Highlight::HTML',
    AUTHOR              => 'Sébastien Aperghis-Tramoni <sebastien@aperghis.net>',
    VERSION_FROM        => 'lib/Syntax/Highlight/HTML.pm',
    ABSTRACT_FROM       => 'lib/Syntax/Highlight/HTML.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'HTML::Parser' => 3.00,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Syntax-Highlight-HTML-*' },
);
