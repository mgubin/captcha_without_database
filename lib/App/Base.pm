package App::Base;
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use App::Helper::CGI;
use App::Helper::Captcha;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = { %params, };

    $class = ref $class if ref $class;
    bless $self, $class;

    return $self;
}

sub _set {
    my $self   = shift;
    my %params = @_;

    $self->{$_} = $params{$_} foreach keys %params;
}

sub _get {
    my $self  = shift;
    my $param = shift;

    return $self->{$param} if defined $param && exists $self->{$param};
    return;
}

sub _config {
    return shift->_get('config');
}

sub _helper {
    my $self = shift;

    unless ( $self->{_helper} ) {
        $self->{_helper} = App::Helper::CGI->new( logger => $self->_get('logger') );
    }

    return $self->{_helper};
}

sub _captcha {
    my $self = shift;

    unless ( $self->{_captcha} ) {
        $self->{_captcha} = App::Helper::Captcha->new(
            config => $self->_config,
            logger => $self->_get('logger'),
        );
    }

    return $self->{_captcha};
}

sub _error {
    my $self    = shift;
    my $message = shift;

    $self->_log($message) if $message;
    return;
}

sub _log {
    my $self    = shift;
    my $message = shift;

    my $logger = $self->_get('logger');
    return unless $logger;
    return $logger->info($message);
}

1;

__END__

=head1 NAME

App::Base - Базовый класс с общими для других модулей внутренними функциями

=head1 SYNOPSIS

use App::Base;
my $cfg = App::Base->new( );

=head1 METHODS

=item my $cfg = App::Base->new();

Конструктор объекта.

=cut
