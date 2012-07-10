package Translog::Modification;

#use Treex::Core;
use Moose;
use MooseX::SemiAffordanceAccessor;
use base 'Translog::Event';

has 'key' => (is => 'rw');
has 'cursor' => (is => 'rw');
has 'type' => (is => 'rw');
has 'token' => (is => 'rw', isa => 'Treex::Core::Node');

sub get_source_token {
  my ($self) = @_;

  return ($self->token->get_aligned_nodes);
}

1;
