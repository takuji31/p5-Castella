package  Castella::Exception::HTTP;
use strict;
use warnings;
use Castella::Utils;

use parent qw/Castella::Exception/;

use Class::Accessor::Lite (
    new => 1,
    rw => [qw/ res /],
);

sub response { croak("Please override response method!") }

package  Castella::Exception::HTTP::Success;
use parent qw/Castella::Exception::HTTP/;

sub response {
    my $self = shift;
    my $res  = $self->res;

    if( ref($res) eq 'ARRAY' ) {
        return $res;
    } elsif ( ref($res) eq 'HASH' ) {
        return [
            $res->{status},
            $res->{headers},
            [$res->{body}],
        ];
    } elsif ( ref($res) && $res->isa('Plack::Response') ) {
        return $res->finalize;
    } else {
        return [
            200,
            ['Content-Type' => 'text/html'],
            [$res],
        ];
    }
}



package  Castella::Exception::HTTP::NotFound;
use parent qw/Castella::Exception::HTTP/;

sub response {
    my $self = shift;
    my $res  = $self->res;
    my $headers;
    my $body;
    if (ref($res) eq 'HASH') {
        $headers = $res->{headers};
        $body    = $res->{body};
    } else {
        $body = $res;
    }
    $headers ||= [ 'Content-Type' => 'text/plain' ];
    $body    ||= '404 Not Found';

    return [
        404,
        $headers,
        [$body],
    ];
}


1;
