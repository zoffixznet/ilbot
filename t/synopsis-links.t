use strict;
use warnings;
use Ilbot::Config qw/config/;
use Test::More tests => 9;

BEGIN { use_ok('IrcLog::WWW'); }

sub link_length {
    my $text = shift;
    my $c = 1;

	my $timezone = config(backend => 'timezone') || 'gmt';

    my $h = IrcLog::WWW::message_line({
            id          => 1,
            nick        => 'somebody',
            timestamp   => time(),
            message     => $text,
            line_number => 1,
            prev_nick   => '',
            colors      => [],
            self_url    => '/',
            channel     => 'perl6',
            },
            \$c
        );
    my $msg = $h->{MESSAGE};
    if ($msg =~ m{<a [^>]+>([^<]*)</a>}){
        return length $1;
    } else {
        return undef;
    }
}

is( link_length(qq{}), undef,        qq{Empty string doesn't linkifiy} );
is( link_length('foo bar'), undef,   qq{random strings don't linkify} );
is( link_length('foo S05 bar'), 3,   qq{'S05' in text is turned into a link} );
is( link_length('sdfS05'), undef,    qq{'S05' within a word in not linkified} );
is( link_length('S05:123'), 7,       qq{'S05:123' linkifies} );
is( link_length('S05:1-2'), 7,       qq{'S05:1-2' (ranges) linkify} );
is( link_length('S32/Containers'), 14,      qq{'S32/foo' (subsections) linkify} );
is( link_length('S32/Containers:1112'), 19, qq{'S32/foo:1-2' (subsections+ranges) linkify} );

# " is turned into &quot;
is( link_length('S05/"foo b"'), 21,  qq{'S05/"foo b" linkifies} );

TODO: {
    local $TODO = "NYI";
    is( link_length('S05/foo'), 7,   qq{'S05/foo' linkifies} );
}
