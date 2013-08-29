package Net::Amazon::Auth::InstanceProfileCredentialsProvider;

use Moose 0.85;
use MooseX::StrictConstructor 0.16;
use HTTP::Date;
use JSON;

with 'Net::Amazon::Auth::CredentialsProvider';

has '_ua' => ( is => 'rw', isa => 'LWP::UserAgent', required => 0 );
has '_access_key_id'     => ( is => 'rw', isa => 'Str', required => 0 );
has '_secret_access_key' => ( is => 'rw', isa => 'Str', required => 0 );
has '_session_token' => ( is => 'rw', isa => 'Str', required => 0 );
has '_expiration_date' => ( is => 'rw', isa => 'Int', required => 0, default => 0 );

sub BUILD {
    my $self = shift;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $self->_ua($ua);
}

sub refresh {
    my $self = shift;

    my $role_name_response =
        $self->_ua->get("http://169.254.169.254/latest/meta-data/iam/security-credentials/");
    if ($role_name_response->code == 200) {
        my $credentials_response = $self->_ua->get("http://169.254.169.254/latest/meta-data/iam/security-credentials/" . $role_name_response->content);

        if ($credentials_response->code == 200) {
            my $credentials = decode_json($credentials_response->content);
            $self->_expiration_date(str2time($credentials->{Expiration}));
            $self->_access_key_id($credentials->{AccessKeyId});
            $self->_secret_access_key($credentials->{SecretAccessKey});
            $self->_session_token($credentials->{Token});
        }
    }
}

sub get_credentials {
    my $self = shift;

    if (time() - $self->_expiration_date > -5 * 60) { #Credentials available 5 minutes before expiry
        $self->refresh;
    }

    return {
        access_key_id => $self->_access_key_id,
        secret_access_key => $self->_secret_access_key,
        session_token => $self->_session_token
    };
}

__PACKAGE__->meta->make_immutable;

1;
