package Net::Amazon::Auth::FixedCredentialsProvider;

use Moose 0.85;
use MooseX::StrictConstructor 0.16;

with 'Net::Amazon::Auth::CredentialsProvider';

has 'access_key_id'     => ( is => 'ro', isa => 'Maybe[Str]', required => 1 );
has 'secret_access_key' => ( is => 'ro', isa => 'Maybe[Str]', required => 1 );
has 'session_token' => ( is => 'ro', isa => 'Maybe[Str]', required => 0 );

sub get_credentials {
    my $self = shift;
    return {
        access_key_id => $self->access_key_id,
        secret_access_key => $self->secret_access_key,
        session_token => $self->session_token
    };
}

__PACKAGE__->meta->make_immutable;

1;
