#!/usr/bin/perl -w

use Test::More;

sub BEGIN { use_ok ('Translog::Event') }

my $event = Translog::Event->new();
my $event2 = Translog::Event->new();

$event->set_time(100);
$event2->set_time(200);
ok($event->preceeds($event2), 'preceeeds');

#$session->set_modification('test');
done_testing();


