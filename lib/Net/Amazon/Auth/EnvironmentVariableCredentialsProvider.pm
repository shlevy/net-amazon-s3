package Net::Amazon::Auth::EnvironmentVariableCredentialsProvider;

use Moose 0.85;
use MooseX::StrictConstructor 0.16;

extends 'Net::Amazon::Auth::FixedCredentialsProvider';

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my %args = (
        access_key_id => $ENV{AWS_ACCESS_KEY_ID},
        secret_access_key => $ENV{AWS_SECRET_ACCESS_KEY}
    );

    if (exists $ENV{AWS_SESSION_TOKEN}) {
        $args{session_token} = $ENV{AWS_SESSION_TOKEN};
    }

    return $class->$orig(\%args);
};

__PACKAGE__->meta->make_immutable;

1;
