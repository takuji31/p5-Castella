package TestApp;
use Castella;

get '/' => run {
    my $self = shift;
    $self->stash->{message} = 'Hello Castella world!';
};

post '/' => run {
    my $self = shift;
    $self->stash->{message} = 'Hello Castella HogeHoge!';
};

1;
__DATA__
@@ /
<!DOCTYPE HTML>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title>index</title>
</head>
<body>
    <p>
        <: $message :>
    </p>
    <form action="/" method="POST">
        <button type="submit">POST</button>
    </form>
</body>
</html>
