package  Castella::Utils;
use strict;
use warnings;

use Exporter::Lite;

our @EXPORT = qw(
    export_method
    export_coderef
);

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

1;
__END__
=encoding utf8

=head1 NAME

Castella::Utils - Utilities for Castella

=head1 SYNOPSIS

  use Castella::Utils;

=head1 METHODS

=head2 export_method

Export method in current class.

  package  MyApp::Hoge;
  use MyApp -util;
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
  use MyApp -util;
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

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=cut
