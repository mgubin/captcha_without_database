package Controller::Captcha;
use strict;
use warnings;
use parent 'BaseObject';
use Data::Dumper;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = $class->SUPER::new(
        config => undef,
        logger => undef,

        %params,
    );

    $class = ref $class if ref $class;
    bless $self, $class;

    srand time;

    return $self;
}

sub process {
    my $self = shift;

    my $code  = $self->_get_code();
    my $image = $self->_get_image($code);
    $self->_set_cookies($code);
    $self->_render_image($image);

    return 1;
}

sub _get_code {
    my $self = shift;

    my $length = $self->_config->{captcha}{code_lenght};
    $self->_helper->return_status('500 Internal error') unless $length && $length =~ /^\d+$/;

    my @chars = ( '0' .. '9', 'a' .. 'z' );
    my $code;
    $code .= $chars[ rand @chars ] foreach 1 .. $length;
    $self->_log("Got code: $code");

    return $code;
}

sub _get_image {
    my $self = shift;
    my $code = shift;

    return $self->_captcha->draw($code);
}

sub _set_cookies {
    my $self = shift;
    my $code = shift;

    my $hash = $self->_captcha->get_hash($code);
    $self->_log("Got hash: $hash");
    $self->_helper->set_cookie(
        name  => $self->_config->{captcha}{cookie},
        value => $hash,
    );
}

sub _render_image {
    my $self  = shift;
    my $image = shift;

    $self->_helper->print_header('image/png');
    binmode STDOUT;
    print $image;
}

1;

__END__

=head1 NAME

Controller::Captcha - Контроллер вывода страницы в браузер

=head1 SYNOPSIS

use Controller::Captcha;
my $web = Controller::Captcha->new( config => hash, logger => object );
$web->process();

=head1 METHODS

=item my $web = Controller::Captcha->new( %parameters );

Конструктор объекта. В качестве входным должен получить следующие параметры:
config  Хэш с конфигурацией приложения
logger  Объект логгера

=item $web->process();

Запуск процесса вывода страниц

=cut
