package Castella;
use strict;
use warnings;
our $VERSION = '0.01';

use parent 'Class::Data::Inheritable';

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw(req res stash)],
);

use Carp ();
use Class::Load ':all';
use Data::Section::Simple;
use Text::Xslate;
use Try::Tiny;
use UNIVERSAL::can;

use Castella::Exception;
use Castella::Request;
use Castella::Response;
use Castella::Utils;

sub import {
    my $class  = shift;
    my $caller = caller;

    strict->import;
    warnings->import;

    #base class
    {
        no strict 'refs';
        unshift @{"$caller\::ISA"}, $class;
    }

    #make action_table
    $caller->mk_classdata(action_table => []);
    #make attributes
    $caller->mk_classdata(attr => {});

    my @functions = qw(post get action run);
    #Export DSL
    for my $function ( @functions ) {
        $class->export_method($caller, $function);
    }
}

sub app {
    my $class = shift;
    return sub {
        my $env = shift;
        try {
            my $path = $env->{PATH_INFO};
            my $code;
            for my $action ( @{$class->action_table} ) {
                if ( $path =~ $action->{regex} && ( !defined $action->{method} || $action->{method} eq $env->{REQUEST_METHOD} ) ) {
                    $code = $action->{code};
                    last;
                }

            }
            Castella::Exception::HTTP::NotFound->throw unless $code;
            my $c = $class->new(
                req   => Castella::Request->new($env),
                res   => Castella::Response->new,
                stash => {},
                env   => $env,
            );
            $code->($c);
            my $templates = Data::Section::Simple->new($class)->get_data_section;
            my $xslate = Text::Xslate->new(
                path => $templates,
            );
            my $body = $xslate->render($path,$c->stash);
            Castella::Exception::HTTP::Success->throw(
                res => [
                    200,
                    ['Content-Type' => 'text/html'],
                    [$body]
                ],
            );
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

sub run (&) { $_[0] }

sub add_action {
    my ($class, $regex, $options, $code, $method) = @_;
    push @{$class->action_table}, {regex => qr{^$regex$} , code =>  $code , options => $options, method => $method};
}
sub action ($$) {
    my ($regex, $code) = @_;
    my $class = caller;
    push @{$class->action_table}, {regex => qr{^$regex$} , code =>  $code , template => $regex};
}

sub post ($$) {
    my ($regex, $code) = @_;
    my $class = caller;
    push @{$class->action_table}, {regex => qr{^$regex$} , code =>  $code, template => $regex, method => 'POST'};
}

sub get ($$) {
    my ($regex, $code) = @_;
    my $class = caller;
    push @{$class->action_table}, {regex => qr{^$regex$} , code =>  $code, template => $regex, method => 'GET'};
}

1;
__END__
=encoding utf8

=head1 NAME

Castella - Sinatra like web application framework for PSGI/Plack

=head1 SYNOPSIS

  package  MyApp;
  use Castella;

  get '/' => run {
        my $self = shift;
        $self->stash->{message} = 'Hello Castella world!';
  };
  post '/' => run {
        my $self = shift;
        $self->stash->{message} = 'Castella is sweet!';
  };
  1;
  __DATA__
  @@ /
  <!DOCTYPE HTML>
  <html lang="ja">
  <head>
    <meta charset="UTF-8">
    <title>hogehoge</title>
  </head>
  <body>
    <: $message :>
    <form action="/" method="post">
        <button  type="submit">press me!</button>
    </form>
  </body>
  </html>

=head1 DESCRIPTION

Castella is oreore waf which like Sinatra on Ruby

Write code easily!

=head1 METHODS

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
