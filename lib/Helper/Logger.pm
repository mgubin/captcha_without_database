package Helper::Logger;
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

Helper::Logger - the simplest logger for unifying the log of messages

=head1 SYNOPSIS

use Helper::Logger;
$logger = Helper::Logger->new();
$logger->info('Some message');

=cut
 
