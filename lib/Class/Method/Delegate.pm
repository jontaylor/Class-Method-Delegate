package Class::Method::Delegate; 

use 5.010000;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(blessed);

our $VERSION = '0.02';

sub import {
  my $class = shift;
  no strict 'refs';

  my $caller = caller;
  # Wants delegate
  *{"${caller}::delegate"} = sub { delegate($caller, @_) };

  strict->import;
}

sub delegate {
  my $class = shift;
  my $options = @_ ? @_ > 1 ? {@_} : {%{$_[0]}} : {};

  my $methods = $options->{'methods'};
  my $object = $options->{'to'};

  croak "Can't delegate without method" unless $methods;
  croak "Can't delegate without an object" unless $object;

  no strict 'refs';
  #Inject a method 
  foreach my $method_name(@$methods) {
    *{"${class}::$method_name"} = sub {
      my $self = shift;
      my $delegation_object = &$object($self);
      croak "You are trying to delegate to something that is not an object" unless blessed( $delegation_object );
      if($delegation_object->can('delegated_by')) {
        $delegation_object->delegated_by($self);
      }
      $delegation_object->$method_name(@_);
    }
  }
  strict->import;
}

1;
__END__

=head1 NAME

Class::Method::Delegate - Perl extension to help you add delegation to your classes

=head1 SYNOPSIS

  use Class::Method::Delegate;
  use Package::To::Delegate::To;
  delegate methods => [ 'hello', 'goodbye' ], to => sub { Package::To::Delegate::To->new() };
  delegate methods => [ 'wave' ], to => sub { shift->{gestures} };
  delegate methods => [ 'walk', 'run' ], to => sub { self->{movements} ||= Package::To::Delegate::To->new() };

=head1 DESCRIPTION

Creates methods on the current class which delegate to an object.

delegate takes a hash or hashref with the following keys.

methods

Takes an array ref of strings that represent the name of the method to be delegated.

to

a sub block that returns an object, which the method calls will be sent to.

=head2 Accessing the parent from inside the delegated class.

If the object you are delegating to has a method called delegated_by, then this will be called when delegating.
The $self of the package doing the delegating will be passed in, so you can then store it.

=head2 EXPORT

delegate

=head1 SEE ALSO

Check out Class:Delegator and Class::Delegation for alternatives.

=head1 AUTHOR

Jonathan Taylor, E<lt>jon@stackhaus.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jonathan Taylor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
