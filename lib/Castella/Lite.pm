package  Castella::Lite;
use Castella -base;

use parent qw/Class::Data::Inheritable/;

use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/ req res stash /],
);
use Data::Section::Simple;
use Text::Xslate;

use Castella::Exception;
use Castella::Request;
use Castella::Response;

sub import {
    my $class  = shift;
    my $caller = caller;

    strict->import;
    warnings->import;

    {
        no strict 'refs';
        unshift @{"$caller\::ISA"}, $class;
    }
    #make action_table
    $caller->mk_classdata(action_table => []);
    #make attributes
    $caller->mk_classdata(attr => {});
    #Export DSL
    my @functions = qw/
        run
        action
        post
        get
    /;
    for my $function ( @functions ) {
        $class->export_method($caller, $function);
    }
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

sub get_router {
    return sub {
        my ($class, $env) = @_;
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
    };
}

1;
__END__
=encoding utf8

=head1 NAME

Castella::Lite - Sinatra like implementation for Castella

=head1 SYNOPSIS

  package  MyApp;
  use Castella::Lite -base;

=head1 DESCRIPTION

Castella::Lite is Sinatra like implementation for Castella

Write code more easily!

=head1 AUTHOR

Nishibayashi Takuji E<lt>takuji {at} senchan.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
