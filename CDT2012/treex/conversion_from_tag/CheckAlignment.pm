package CheckAlignment;

use strict;
use open IN  => ":crlf";

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

my $Verbose = 1;

my @errors;

# usage: my ($good,$bad) CheckDtag::check($alignment_file,$bfile);
sub check {
    my ($atag_file,$bfile) = @_;

    my @b_line2sign;

    open my $B,$bfile or die $!;
    my $line_number = 0;
    while (<$B>) {
        if (/([^>]+)<\/W>/) {
            $b_line2sign[$line_number] = $1;
        }
        $line_number++;
    }

    my ($good_cnt,$bad_cnt) = (0,0);

    open my $ATAG,$atag_file;
    while (<$ATAG>) {

        if (/<align /) {
            my %attr;
            foreach my $attr_name (qw(in insign)) {
                if (/$attr_name="([^"]*)/) {
                    $attr{$attr_name} = $1;
                }
                else {
                    die "<align> element does not have attribute $attr_name in $atag_file";
                }
            }

            if ($attr{in} !~ /a/) {

                my $expected_sign = join ' ',
                    map {$b_line2sign[$_]} map {s/^b//;$_} split ' ',$attr{in};

                if ($expected_sign ne $attr{insign}) {
#                    print "$attr{in} dtag: $expected_sign  atag: $attr{insign}\n";
                    $bad_cnt++;
                }
                else {
#                    print ".";
                    $good_cnt++;
                }
            }
        }
    }

    return ($good_cnt, $bad_cnt);
}

1;
