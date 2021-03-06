#!/usr/bin/perl

=head1 NAME

  multikulti.pl - Seudoparallel implementation of the multikulti algorithm with variants

=head1 SYNOPSIS

  prompt% ./multikulti.pl params.yaml conf.yaml


=head1 DESCRIPTION  

Implementation of the multikulti algorithm, submitted to PPSN (for the time being)

=cut

use warnings;
use strict;

use lib qw(../../lib ../lib);
use Algorithm::Evolutionary::Run;
use Algorithm::Evolutionary::Utils qw(entropy consensus);

use POE;
use YAML qw(Dump LoadFile);
use IO::YAML;
use DateTime;

my $spec = shift || die "Usage: $0 params.yaml conf.yaml\n";
my $params_file = shift || "conf.yaml";
my $conf = LoadFile( $params_file ) || die "Can't open $params_file: $@\n";
my $total_evals; # Number of guys evaluated by the other session
my %best;

my $migration_policy = $conf->{'migration_policy'} || 'multikulti';
my $match_policy = $conf->{'match_policy'} || 'best';

my $sessions = $conf->{'sessions'};
for my $s (1..$sessions) {
  POE::Session->create(inline_states => { _start => \&start,
					  generation => \&generation,
					  finish => \&finishing},
		       args  => [$s]
		       );
}

#Timer
my ($spec_name) = ( $spec =~ /([^.]+)\.yaml/);
my $io = IO::YAML->new("$spec_name-$migration_policy-$match_policy.yaml", ">");
$io->print( [ now(), 'Start' ]);
$poe_kernel->post( "Population 1", "generation", "Population 2"); #First, function and next generation

$poe_kernel->run();
$io->print( [ now(), "Exiting" ]);
$io->close() || die "Can't close: $@";
exit(0);

#----------------------------------------------------------#
sub now {
  my $now = DateTime->now();
  return $now->ymd."T".$now->hms;
}
#----------------------------------------------------------#

sub start {
  my ($kernel, $heap, $session ) = @_[KERNEL, HEAP, ARG0];
  $kernel->alias_set("Population $session");
  my $algorithm =  new Algorithm::Evolutionary::Run $spec;
  $heap->{'algorithm'} = $algorithm;
  $heap->{'counter'} = 0;
}

#------------------------------------------------------------#

sub generation {
  my ($kernel, $heap, $session, $next, $other_best ) = @_[KERNEL, HEAP, SESSION, ARG0, ARG1];
  my $alias =  $kernel->alias_list($session);
  my $algorithm = $heap->{'algorithm'};
  my @data = ( now(), $alias );
  $algorithm->run();
  my $population = $heap->{'algorithm'}->{'_population'};
  my $match;
  my $best = $algorithm->results()->{'best'};
  if ( $match_policy eq 'consensus' ) {
      $match = consensus( $population );
  } else {
      $match = $best;
  }
  $best{$alias} = $match;
  
  my $these_evals = $heap->{'algorithm'}->results()->{'evaluations'};
  if ( $alias eq 'Population 1' ) {
    $total_evals = $these_evals;
  } else {
    $total_evals += $these_evals;
  }
  my ($idx) = ($next =~ /Population (\d+)/);
  my $after_punk = "Population ".($idx+1) ;
  if ( $after_punk gt "Population $sessions" ) {
    $after_punk = "Population 1";
  }

  #Decide who to send
  my $somebody;
  if ( $migration_policy eq 'multikulti' ) {
      if ( $best{$next} ) {
	  $somebody = worst_match( $population, $best{$next});
      } else {
	  $somebody = $algorithm->random_member();
      }
  } elsif (  $migration_policy eq 'random' ) {
      $somebody = $algorithm->random_member();
  } elsif (  $migration_policy eq 'best' ) {
      $somebody = $best;
  } elsif (  $migration_policy eq 'multikulti-elite' ) {
    if ( $best{$next} ) {
      my @population = @$population;
      my @population_elite = @population[0..(@population/2)];
      $somebody = worst_match( \@population_elite, $best{$next});
    } else {
      $somebody = $algorithm->random_member();
    }
  }
  push @data, {'sending' => $somebody };
  push @data, {'best' => $best };
  push @data, {'entropy' => entropy( $population ) };
  if ( ( $best->Fitness() < $algorithm->{'max_fitness'} ) 
       && ( ($total_evals) < $conf->{'max_evals'} ) ) {
      $kernel->post($next, 'generation', $after_punk , $somebody );
  } else {
    for( my $s = 1; $s <= $sessions; $s ++ ) {
      $kernel->post("Population $s", 'finish');
    }
  }

  #Incorporate at the end, as if it were asynchronous
  if ( $other_best && $heap->{'counter'}) {
      push @data, { 'receiving' => $other_best };
      pop @{$algorithm->{'_population'}}; #take out last individual in the population
      push @{$algorithm->{'_population'}}, $other_best;
  }
  $heap->{'counter'}++;
  $io->print( \@data );
}

sub finishing {
  my $heap   = $_[ HEAP ];
  $io->print( [now(), { Finish => $heap->{'algorithm'}->results }] ) ;
}

=head2 hamming

Computes the number of positions that are different among two strings

=cut

sub hamming {
    my ($string_a, $string_b) = @_;
    return ( ( $string_a ^ $string_b ) =~ tr/\1//);
}


=head2 worst_match 

Computes the worst match of the population

=cut

sub worst_match {
    my $population = shift || die "No population\n";
    my $matchee = shift || die "No matchee";
    if ( !ref $matchee ) {
      $matchee = { _str => $matchee }
    }
    my $distance = 0;
    my $vive_la;
    for my $p (@$population) {
	my $this_distance = hamming( $p->{'_str'}, $matchee->{'_str'} );
	if ($this_distance > $distance ) {
	    $vive_la = $p;
	    $distance = $this_distance;
	}
    }
    return $vive_la;
}

=head1 AUTHOR

J. J. Merelo C<jj@merelo.net>

=cut

=head1 Copyright
  
  This file is released under the GPL. See the LICENSE file included in this distribution,
  or go to http://www.fsf.org/licenses/gpl.txt

  CVS Info: $Date: 2009/07/24 08:46:58 $ 
  $Header: /media/Backup/Repos/opeal/opeal/Algorithm-Evolutionary/examples/multikulti/multikulti.pl,v 3.0 2009/07/24 08:46:58 jmerelo Exp $ 
  $Author: jmerelo $ 
  $Revision: 3.0 $
  $Name $

=cut
