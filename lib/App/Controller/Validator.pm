package App::Controller::Validator;
use strict;
use warnings;
use parent 'App::Base';
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

    my $mode = $self->_web->value('mode');

    if ( $mode eq 'get' ) {
        # Return image with captcha
        my $code  = $self->_get_code();
        my $image = $self->_get_image($code);
        $self->_set_cookies($code);
        $self->_web->output_image($image);
    } elsif ( $mode eq 'check' ) {
        # Checking the captcha before submitting the form
        my $code = $self->_web->value('code');
        $self->_log("Check captcha: got code $code");
        my $cookie_hash = $self->_web->get_cookie( $self->_config->{captcha}{cookie} );
        $self->_log("Check captcha: hash from cookie $cookie_hash");
        my $res = $self->_captcha->is_valid( $code, $cookie_hash ) ? 1 : 0;
        $self->_log('Check captcha: captcha in not valid') unless $res;
        $self->_web->output_text($res);
    } else {
        # Unknown request
        $self->_web->return_status('400 Bad Request');
    }

    return 1;
}

sub _get_code {
    my $self = shift;

    my $length = $self->_config->{captcha}{code_lenght};
    $self->_web->return_status('500 Internal error') unless $length && $length =~ /^\d+$/;

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
    $self->_web->set_cookie(
        name  => $self->_config->{captcha}{cookie},
        value => $hash,
    );
}

1;

__END__

=head1 NAME

App::Controller::Validator - Контроллер вывода страницы в браузер

=head1 SYNOPSIS

use App::Controller::Validator;
my $web = App::Controller::Validator->new( config => hash, logger => object );
$web->process();

=head1 METHODS

=item my $web = App::Controller::Validator->new( %parameters );

Конструктор объекта. В качестве входным должен получить следующие параметры:
config  Хэш с конфигурацией приложения
logger  Объект логгера

=item $web->process();

Запуск процесса вывода страниц

=cut
