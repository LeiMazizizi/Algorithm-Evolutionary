use strict;
use warnings;

=head1 NAME

    Algorithm::Evolutionary::Fitness::Base - Base class for Fitness functions

=head1 SYNOPSIS

Shouldn't be used directly, it's rather abstract

=head1 DESCRIPTION

Has functionality that should be common to all fitness. Or at least it
would be nice to have it in common

=head1 METHODS

=cut

package Algorithm::Evolutionary::Fitness::Base;

use Carp;

=head2 new

Initializes common variables, like the number of evaluations

=cut 

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  $self->initialize();
  return $self;
}

=head2 new

Initializes common variables, like the number of evaluations

=cut 

sub initialize {
  my $self = shift;
  $self->{_counter} = 0; 
}


=head2 apply( $individual )

Applies the instantiated problem to a chromosome. Actually it's a
wrapper around C<_apply>

=cut

sub apply {
    my $self = shift;
    my $individual = shift;
    $self->{'_counter'}++;
    return $self->_apply( $individual );
}

=head2 _apply

This is the one that really does the stuff. Should be overloaded by
derived clases

=cut

sub _apply {
  carp "You should have overloaded this\n";
}


=head2 evaluations 

Returns the number of evaluations made with this object

=cut

sub evaluations {
  my $self = shift;
  return $self->{_counter};
}

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2008/02/14 12:39:39 $ 
  $Header: /media/Backup/Repos/opeal/opeal/Algorithm-Evolutionary/lib/Algorithm/Evolutionary/Fitness/Base.pm,v 1.2 2008/02/14 12:39:39 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 1.2 $
  $Name $

=cut

"What???";