package Log::ger::Format::Sprintfn;

# DATE
# VERSION

use strict;
use warnings;

use Text::sprintfn;

sub get_hooks {
    my %conf = @_;

    return {
        create_formatter => [
            __PACKAGE__, 50,
            sub {
                my %args = @_;

                my $formatter = sub {
                    return $_[0] if @_ < 2;
                    my $fmt = shift;
                    my @args;
                    for my $i (0..$#_) {
                        if ($i == 0 && ref $_[$i] eq 'HASH') {
                            my $orig = $_[$i];
                            my $dumped = {};
                            for my $k (keys %$orig) {
                                my $v = $orig->{$k};
                                # XXX code duplication'ish
                                if (!defined($v)) {
                                    $dumped->{$k} = '<undef>';
                                } elsif (ref $v) {
                                    require Log::ger::Util
                                        unless $Log::ger::_dumper;
                                    $dumped->{$k} = Log::ger::Util::_dump($v);
                                } else {
                                    $dumped->{$k} = $v;
                                }
                            }
                            push @args, $dumped;
                        } elsif (!defined($_[$i])) {
                            push @args, '<undef>';
                        } elsif (ref $_[$i]) {
                            require Log::ger::Util unless $Log::ger::_dumper;
                            push @args, Log::ger::Util::_dump($_[$i]);
                        } else {
                            push @args, $_[$i];
                        }
                    }
                    sprintfn $fmt, @args;
                };
                [$formatter];
            }],
    };
}

1;
# ABSTRACT: Use Text::sprintfn for formatting instead of sprintf

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Format 'Sprintfn';
 use Log::ger;

After that:

 log_debug 'user is %(username)s, details are %(detail)s',
     {username=>"Foo", detail=>{...}};

To install only for current package:

 use Log::ger::Format;
 Log::ger::Format->set_for_current_package('Sprintfn');
 use Log::ger;


=head1 DESCRIPTION


=head1 SEE ALSO

L<Log::ger>

L<Text::sprintfn>
