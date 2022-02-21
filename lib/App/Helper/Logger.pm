package App::Helper::Logger;
use strict;
use warnings;

sub new {
    return bless {}, shift;
}

sub info {
    my $self    = shift;
    my $message = shift;

    warn "$message\n";
}

1;

__END__

=head1 NAME

App::Helper::Logger - the simplest logger for unifying the log of messages

=head1 SYNOPSIS

use App::Helper::Logger;
$logger = App::Helper::Logger->new();
$logger->info('Some message');

=cut
 
