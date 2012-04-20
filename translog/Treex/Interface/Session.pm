package Translog::Session;

#use Treex::Core;
use Moose;
use MooseX::SemiAffordanceAccessor;

has 'description' => (is => 'rw', isa => 'Str');
has 'fixations' => (is => 'rw', isa => 'ArrayRef', default=> sub {[ ]});
has 'modifications' => (is => 'rw', isa => 'ArrayRef', default=> sub {[ ]});
has 'treex_doc' => (is => 'rw');

sub get_events {
  my ($self) = @_;

  return (@{$self->modifications}, @{$self->fixations});
}

sub get_modifications_for_token {
}
1;
