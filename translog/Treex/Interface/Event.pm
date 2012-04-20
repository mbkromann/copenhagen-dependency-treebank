package Translog::Event;

#use Treex::Core;
use Moose;
use MooseX::SemiAffordanceAccessor;

has 'time' => (is => 'rw');

sub preceeds {
  my ($self, $event) = @_;

  return ($self->time < $event->time);
}

1;
