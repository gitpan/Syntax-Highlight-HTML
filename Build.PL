use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Syntax::Highlight::HTML',
    license             => 'perl',
    dist_author         => 'S�bastien Aperghis-Tramoni <sebastien@aperghis.net>',
    dist_version_from   => 'lib/Syntax/Highlight/HTML.pm',
    requires => {
        'HTML::Parser' => 3.00,
    },
    add_to_cleanup      => [ 'Syntax-Highlight-HTML-*' ],
);

$builder->create_build_script();