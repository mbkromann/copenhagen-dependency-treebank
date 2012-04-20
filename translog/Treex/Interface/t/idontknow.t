#!/usr/bin/perl -w

use Test::More;

sub BEGIN { use_ok ('Translog::Session') }

my $session = Translog::Session->new();

$session->set_description('test');
ok($session->description() eq 'test', 'redundant');
ok(scalar($session->get_events()) == 0, 'no events in object');

#$session->set_modification('test');
done_testing();


