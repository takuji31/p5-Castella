package Castella::Exception;
use strict;
use warnings;
use overload '""' => \&inspect;

use Carp ();
use Class::Accessor::Lite (
    new => 1,
    rw  => [qw/ msg /],
);
use Class::Load qw/:all/;

use Castella::Utils;

sub import {
    my $class  = shift;
    my $caller = caller;
    load_class('Castella::Exception::HTTP');
}

sub inspect {
    my $self = shift;

    sprintf("%s < msg: %s > at %s line %s.", ref($self), $self->msg || 'undefined' , $self->{caller}, $self->{line_number})

}

sub throw {
    my ($class, %args) = @_;

    if ( $class eq __PACKAGE__ ) {
        Carp::croak("$class can't use directly!");
    }

    my ($caller, $call_path, $line_number) = caller(1);
    $args{caller} = $call_path;
    $args{line_number} = $line_number;

    my $e = $class->new(%args);
    Carp::croak($e);
}

1;
