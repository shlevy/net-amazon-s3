package Net::Amazon::Auth::CredentialsProviderChain;

use Moose 0.85;
use MooseX::StrictConstructor 0.16;
use Net::Amazon::Auth::EnvironmentVariableCredentialsProvider;
use Net::Amazon::Auth::InstanceProfileCredentialsProvider;

with 'Net::Amazon::Auth::CredentialsProvider';

has 'providers' => ( is => 'ro', isa => 'ArrayRef[Net::Amazon::Auth::CredentialsProvider]', required => 1 );

sub refresh {
    my $self = shift;

    map { $_->refresh } @{$self->providers};
}

sub get_credentials {
    my $self = shift;

    foreach my $provider (@{$self->providers}) {
        my $res = $provider->get_credentials;
        if (defined $res->{access_key_id}) {
            return $res;
        }
    }

    return {};
}

sub default_chain {
    my $class = shift;
    return $class->new(providers => [
            Net::Amazon::Auth::EnvironmentVariableCredentialsProvider->new,
            Net::Amazon::Auth::InstanceProfileCredentialsProvider->new
        ]);
}

__PACKAGE__->meta->make_immutable;

1;
