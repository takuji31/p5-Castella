package  Castella::Request;
use Castella;

use parent qw/Plack::Request/;


sub http_host      { $_[0]->env->{HTTP_HOST} }
sub is_post_method { $_[0]->env->{REQUEST_METHOD} eq 'POST' }

1;
