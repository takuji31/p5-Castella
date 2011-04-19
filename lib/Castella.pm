package Castella;
use strict;
use warnings;
our $VERSION = '0.01';

use Carp ();
use Class::Load ':all';
use Try::Tiny;
use UNIVERSAL::can;

sub import {
    my $class  = shift;
    my $caller = caller;

    strict->import;
    warnings->import;

    if ( $_[0] && $_[0] eq '-base' ) {
        my $attr = {};
        export_coderef($caller, 'attr', sub { $attr });
        $class->export_method($caller, 'app');
        $class->export_method($caller, 'sub_class');
    } else {
        export_coderef($caller, 'sub_class', sub { shift; $class->sub_class(@_); });
    }
    my @functions = qw/
        export_method
        export_coderef
    /;
    for my $function ( @functions ) {
        $class->export_method($caller, $function);
    }
}

sub export_method {
    my ( $class, $target, $method_name ) = @_;
    if ( ref($target) ) {
        $target = ref($target);
    }
    my $code = $class->can($method_name);
    unless ($code) {
        Carp::croak("Method $class\::$method_name does not exists!");
    }
    export_coderef( $target, $method_name, $code );
}

sub export_coderef {
    my ( $target, $method_name, $code ) = @_;
    if ( ref($target) ) {
        $target = ref($target);
    }
    unless ( ref($code) eq 'CODE' ) {
        Carp::croak("This is not code reference! $code");
    }
    {
        no strict 'refs';    ## no critic
        *{"$target\::$method_name"} = $code;
    }
}

sub sub_class {
    my $sub_class =  join '::', @_;
    load_class($sub_class);
    return $sub_class;
}

sub app {
    my $class = shift;
    my $router = $class->get_router;
    return sub {
        my $env = shift;
        try {
            $router->($class, $env);
        } catch {
            my $e = shift;
            if( ref($e) && $e->isa('Castella::Exception::HTTP') ) {
                return $e->response;
            } else {
                #TODO Error handling
                Carp::confess($e);
            }

        }
    };
}

1;
__END__
=encoding utf8

=head1 NAME

Castella - A web application framework for PSGI/Plack

=head1 SYNOPSIS

  package  MyApp;
  use Castella -base;

  package  MyApp::SomeModule;
  use MyApp;

=head1 DESCRIPTION

Castella is oreore waf!

Write code easily!

=head1 METHODS

=head2 export_method

Export method in current class.

  package  MyApp::Hoge;
  use MyApp;
  sub import {
      my $class  = shift;
      my $caller = caller;
      $class->export_coderef($caller,'foo');
  }
  sub foo {
    #Do something!
  }

  package  MyApp::Fuga;
  use MyApp::Hoge;

  sub hoge {
    foo();
  }

=head2 export_coderef

Export code reference.

  package  MyApp::Hoge;
  use MyApp;
  sub import {
      my $class  = shift;
      my $caller = caller;
      $class->export_metod($caller,'byaa',sub { 'umai' });
  }

  package  MyApp::Fuga;
  use MyApp::Hoge;

  sub hoge {
    byaa();
  }

=head2 subclass

Load sub class for your application.

  package  MyApp::Hoge;
  use MyApp;
  sub foo {
    #Do something!
  }

  package  MyApp::Fuga;
  use MyApp;

  sub hoge {
    subclass('Hoge')->foo;
  }

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
