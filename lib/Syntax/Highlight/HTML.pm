package Syntax::Highlight::HTML;
use strict;
use HTML::Parser;

{ no strict;
  $VERSION = '0.01';
  @ISA = qw(HTML::Parser);
}

=head1 NAME

Syntax::Highlight::HTML - Highlight HTML syntax

=head1 Version

Version 0.01

=cut

my %classes = (
    declaration   => 'h-decl',  # declaration <!DOCTYPE ...>
    process       => 'h-pi',    # process instruction <?xml ...?>
    comment       => 'h-com',   # comment <!-- ... -->
    angle_bracket => 'h-ab',    # the characters '<' and '>' as tag delimiters
    tag_name      => 'h-tag',   # the tag name of an element
    attr_name     => 'h-attr',  # the attribute name
    attr_value    => 'h-attv',  # the attribute value
    entity        => 'h-ent',   # any entities: &eacute; &#171;
);

my %defaults = (
    pre     => 1, # add <pre>...</pre> around the result? (default: yes)
    nnn     => 0, # add line numbers (default: no)
);

=head1 Synopsis

    use Syntax::Highlight::HTML;

    my $highlighter = new Syntax::Highlight::HTML;
    $colored = $highlighter->parse($html);

=head1 Description

This module is designed to take raw HTML input and highlight it (using a CSS 
stylesheet, see L<"Notes"> for the classes). The returned HTML code is ready 
for inclusion in a web page. 

It is intented to be used as an highlighting filter, and as such does not reformat 
or reindent the original HTML code. 

=head1 Methods

=over 4

=item new()

The constructor. Returns a C<Syntax::Highlight::HTML> object, which derives from 
C<HTML::Parser>. As such, any C<HTML::parser> method can be called on this object 
(that is, expect for C<parse()> which is overloaded here). 

B<Options>

=over 4

=item *

C<nnn> - Activate line numbering. Default value: 0 (disabled). 

=item *

C<pre> - Surround result by C<< <pre>...</pre> >> tags. Default value: 1 (enabled). 

=back

B<Example>

To avoid surrounding the result by the C<< <pre>...</pre> >> tags:

    my $highlighter = Syntax::Highlight::HTML->new(pre => 0);

=cut

sub new {
    my $self = Syntax::Highlight::HTML->SUPER::new(
        # API version
        api_version      => 3, 

        # Options
        case_sensitive   => 1, 
        attr_encoded     => 1, 

        # Handlers
        declaration_h    => [ \&_highlight_tag,  'self, event, tagname, attr, text' ], 
        process_h        => [ \&_highlight_tag,  'self, event, tagname, attr, text' ], 
        comment_h        => [ \&_highlight_tag,  'self, event, tagname, attr, text' ], 
        start_h          => [ \&_highlight_tag,  'self, event, tagname, attr, text' ], 
        end_h            => [ \&_highlight_tag,  'self, event, tagname, attr, text' ], 
        text_h           => [ \&_highlight_text, 'self, text' ], 
        default_h        => [ \&_highlight_text, 'self, text' ], 
    );
    
    my $class = ref $_[0] || $_[0]; shift;
    bless $self, $class;
    
    $self->{options} = { %defaults };
    
    my %args = @_;
    for my $arg (keys %defaults) {
        $self->{options}{$arg} = $args{$arg} if $args{$arg}
    }
    
    $self->{output} = '';
    
    return $self
}

=item parse()

Parse the HTML code given in argument and returns the highlighted HTML code, 
ready for inclusion in a web page. 

=cut

sub parse {
    my $self = shift;
    
    ## parse the HTML fragment
    $self->{output} = '';
    $self->SUPER::parse($_[0]);
    $self->eof;
    
    ## add line numbering?
    if($self->{options}{nnn}) {
        my $i = 1;
        $self->{output} =~ s/^/@{[sprintf '%3d', $i++]}: /gm;
    }
    
    ## add <pre>...</pre>?
    $self->{output} = "<pre>\n" . $self->{output} . "</pre>\n" if $self->{options}{pre};
    
    return $self->{output}
}

=item _highlight_tag()

I<Internal method: C<HTML::Parser> tags handler>

Highlights a tag. 

=cut

sub _highlight_tag {
    my $self = shift;
    my $event = shift;
    my $tagname = shift;
    my $attr = shift;
    
    $_[0] =~ s|&([^;]+;)|<span class="$classes{entity}">&amp;$1</span>|g;
    
    if($event eq 'declaration' or $event eq 'process' or $event eq 'comment') {
        $_[0] =~ s/</&lt;/g;
        $_[0] =~ s/>/&gt;/g;
        $self->{output} .= qq|<span class="$classes{$event}">| . $_[0] . '</span>'
    
    } else {
        $_[0] =~ s|^<$tagname|<<span class="$classes{tag_name}">$tagname</span>|;
        $_[0] =~ s|^</$tagname|</<span class="$classes{tag_name}">$tagname</span>|;
        $_[0] =~ s|^<(/?)|<span class="$classes{angle_bracket}">&lt;$1</span>|;
        $_[0] =~ s|(/?)>$|<span class="$classes{angle_bracket}">$1&gt;</span>|;
        
        for my $attr_name (keys %$attr) {
            next if $attr_name eq '/';
            $_[0] =~ s{$attr_name=(["'])\Q$$attr{$attr_name}\E\1}
            {<span class="$classes{attr_name}">$attr_name</span>=<span class="$classes{attr_value}">$1$$attr{$attr_name}</span>$1}
        }
        
        $self->{output} .= $_[0];
    }
}

=item _highlight_text()

I<Internal method: C<HTML::Parser> text handler>

Highlights text. 

=cut

sub _highlight_text {
    my $self = shift;
    $_[0] =~ s|&([^;]+;)|<span class="$classes{entity}">&amp;$1</span>|g;
    $self->{output} .= $_[0];
}

=back

=head1 Notes

The result HTML uses CSS to colourize the syntax. Here are the classes 
that you can define in your stylesheet. 

=over 4

=item *

C<.h-decl> - for a markup declaration; in a HTML document, the only 
markup declaration is the C<DOCTYPE>, like: 
C<< <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"> >>

=item *

C<.h-pi> - for a process instruction like C<< <?html ...> >>
or C<< <?xml ...?> >>

=item *

C<.h-com> - for a comment, C<< <!-- ... --> >>

=item *

C<h-ab> - for the characters C<<'<'>> and C<<'>'>> as tag delimiters

=item *

C<h-tag> - for the tag name of an element

=item *

C<h-attr> - for the attribute name


=item *

C<h-attv> - for the attribute value

=item *

C<.h-ent> - for any entities: C<&eacute;> C<&#171;>

=back

An example stylesheet can be found in F<examples/html-syntax.css>.

=head1 Author

Sébastien Aperghis-Tramoni, E<lt>sebastien@aperghis.netE<gt>

=head1 See Also

L<HTML::Parser>

=head1 Bugs

Please report any bugs or feature requests to
C<bug-syntax-highlight-html@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 Copyright & License

Copyright (C)2004 Sébastien Aperghis-Tramoni, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Syntax::Highlight::HTML
