package Net::Amazon::Auth::CredentialsProvider;

use Moose::Role 0.85;

requires 'get_credentials';

sub refresh { }

1;
