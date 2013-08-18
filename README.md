InlinePerl Movable Type Plugin
==============

Movable Type plugin to run Perl script in template easily.

## InlinePerl tag

You can write Perl script in template.

    <mt:InlinePerl>
      my $result = "Inline Perl";
      return $result;
    </mt:InlinePerl>

This section renders 'Inline Perl' as you have guessed.

### Returns last line

Plugin evaluates script as a subroutine.

    <!-- Same meaning -->
    <mt:InlinePerl>
      my $result = "Inline Perl";
      $result;
    </mt:InlinePerl>

### Predeclared variables

You can use these these variables tacitly.

**Chaging is not advisable.**

* @_ == ( $ctx, $args )
* $ctx == Context Object
* $args == Arguments(Attributes)
* %vars == ( Depends my, stash, args attributes )
* $perl == "Script You Write"

### Attribute: stash and var

Use stash and var attributes to add tacit variables from template variable and stash.

    <mt:Setvar name="v1" value="Value 1">
    <mt:Setvar name="v2" value="Value 2">
    <mt:InlinePerl stash="blog,entry" var="v1,v2">
      # $blog == $ctx->stash('blog') == $ctx->{__stash}{blog}
      # Blog name: $blog->name
      # $entry == $ctx->stash('entry') == $ctx->{__stash}{entry}
      # Entry title: $entry->title
      # Varialbe v1 and v2: $v1, $v2
      # $v1 == $ctx->var('v1') == $ctx->{__stash}{vars}{v1}
      # $v2 == $ctx->var('v2') == $ctx->{__stash}{vars}{v2}
    </mt:InlinePerl>

### Attribute: my

Attribute "my" declare tacit variables from stash then template variable.

    <!-- Almost same meaning -->
    <mt:Setvar name="v1" value="Value 1">
    <mt:Setvar name="v2" value="Value 2">
    <mt:InlinePerl my="blog,entry,v1,v2">
      # $blog == $ctx->stash('blog') == $ctx->{__stash}{blog}
      # Blog name: $blog->name
      # $entry == $ctx->stash('entry') == $ctx->{__stash}{entry}
      # Entry title: $entry->title
      # Varialbe v1 and v2: $v1, $v2
      # $v1 == $ctx->var('v1') == $ctx->{__stash}{vars}{v1}
      # $v2 == $ctx->var('v2') == $ctx->{__stash}{vars}{v2}
    </mt:InlinePerl>

### Exception handling

Write short Perl script as catch or rescue attribute to handle exception.

    <mt:InlinePerl catch="my $ex = shift; return 'something happened: ' . $ex;">
      # Zero division
      1 / 0;
    </mt:InlinePerl>

If catch and rescue attribute not defined, an Perl exception always raises template build error.

### How does it runs?

You can render raw script will be evaluated with source attribute.

    <mt:InlinePerl source="1">
      return "Raw Source";
    </mt:InlinePerl>

This fragment renders text as bellow.

      return "Raw Source";

## perl_filter

Global filter to modify result.

    <mt:Setvar name="v" value="abcde">
    <mt:Var name="v" perl_filter="uc(shift)">

This template will render text like bellow

    ABCDE

## License

Under MIT.
