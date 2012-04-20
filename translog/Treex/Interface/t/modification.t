#!/usr/bin/perl -w

use Test::More;

sub BEGIN { use_ok ('Translog::Modification') }

my $event = Translog::Modification->new();
my $event2 = Translog::Modification->new();

$event->set_time(100);
$event2->set_time(200);
ok($event->preceeds($event2), 'preceeeds');

#$session->set_modification('test');
done_testing();


