package MT::InlinePerl::Tags;

use strict;
use warnings;

sub hdlr_InlinePerl {
    my ( $ctx, $args, $cond ) = @_;
    my $tokens = $ctx->stash('tokens');
    my $builder = $ctx->stash('builder');

    # Build inside
    defined ( my $perl = $builder->build($ctx, $tokens) )
        or return $ctx->error($builder->errstr);

    # Fuzzy variables: my=""
    my %vars = map {
        $_ => ( defined( $ctx->var($_) )
            ? $ctx->var($_)
            : defined( $ctx->stash($_) )
                ? $ctx->stash($_)
                : undef )
    } ( split( /\s*,\s*/, $args->{my} || '' ) );

    # Stash and vars
    $vars{$_} = $ctx->stash($_) foreach (split( /\s*,\s*/, $args->{stash}));
    $vars{$_} = $ctx->var($_) foreach (split( /\s*,\s*/, $args->{var}));

    # Build perl script as instant subroutine
    # FIXME I intent to use return statement as result
    $perl = join( "\n", '(sub {',
        join( "\n", map { "my \$$_ = \$vars{$_};" } keys %vars ),
        $perl,
        '})->(@_)' );

    # Render source if has arg
    return $perl if $args->{source};

    # Execute script
    local $@;
    my $result = eval($perl);
    my $ex = $@;

    if ( my $catch = $args->{catch} || $args->{rescue} ) {
        if ( $ex ) {

            # If catch="" or rescue="" defined, catches exception
            my $script = join( "\n",
                '(sub {',
                $catch,
                '})->($ex)',
            );

            # Soft landing
            local $@;
            my $result = eval($script);
            $result = '' if !defined($result) or $@;

            return $result;
        }
    }

    # Treat exception as build error
    return $ctx->error($ex) if $ex;

    $result;
}

sub hdlr_perl_filter {
    my ( $text, $arg, $ctx ) = @_;

    # Execute as instant sub
    my $script = join( "\n",
        '(sub {',
        $arg,
        '})->($text)'
    );

    local $@;
    $_ = $text;
    my $result = eval($script);

    # Treat exception as build error
    return $ctx->error($@) if $@;

    # Undefined result to empty string
    $result = '' unless defined $result;

    return $result;
}

1;