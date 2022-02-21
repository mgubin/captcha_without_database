package App::Helper::Web;
use strict;
use warnings;
use parent 'App::Base';
use CGI qw[ :cgi ];
use Carp;
use App::Helper::Exception;
use Data::Dumper;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = $class->SUPER::new(
        logger          => undef,
        default_headers => {
            type   => 'text/html',
            status => '200 OK',
        },
        default_fauilt_status => '500 Internal error',

        %params,
    );

    $class = ref $class if ref $class;
    bless $self, $class;

    return $self;
}

sub is_method_get {
    return shift->_cgi->request_method() eq 'GET';
}

sub is_method_post {
    return shift->_cgi->request_method() eq 'POST';
}

sub value {
    my $self       = shift;
    my $param_name = shift;

    return $self->_cgi->param($param_name);
}

sub print_header {
    my $self   = shift;
    my %params = @_;

    my %headers = ( -cache_control => 'no-cache, no-store, must-revalidate', );

    my $default_headers = $self->_get('default_headers');
    $headers{"-$_"} = $params{$_} || $default_headers->{$_} foreach keys %$default_headers;

    $headers{-charset} = 'utf-8' if $headers{'-type'} =~ /^text\//;
    my $cookie = $self->_get('cookie');
    $headers{-cookie} = $cookie if $cookie;

    print $self->_cgi->header(%headers);
}

sub return_status {
    my $self    = shift;
    my $status  = shift || $self->_get('default_fauilt_status');
    my $message = shift;

    my $log_message = $status;
    $log_message .= ": $message" if $message;

    $self->print_header(
        type   => 'text/html',
        status => $status
    );

    croak( App::Helper::Exception->new( message => $log_message ) );
}

sub set_cookie {
    my $self   = shift;
    my %params = @_;

    $self->return_status('500 Internal error') unless $params{name} && defined $params{value};

    my $cookie = $self->_cgi->cookie(
        -name    => $params{name},
        -value   => $params{value},
        -expires => 0,
        -path    => '/cgi-bin',
        -domain  => $ENV{SERVER_NAME},
    );

    $self->_set( cookie => $cookie );
}

sub get_cookie {
    my $self        = shift;
    my $cookie_name = shift;

    return unless $cookie_name;

    my $cookie_value = $self->_cgi->cookie($cookie_name);

    return $cookie_value;
}

sub _cgi {
    my $self = shift;

    unless ( $self->{_cgi} ) {
        $self->{_cgi} = CGI->new();
    }

    return $self->{_cgi};
}

1;

__END__

=head1 NAME

App::Helper::Web - Работа с CGI

=head1 SYNOPSIS

use App::Helper::Web;
my $cgi = App::Helper::Web->new( logger => object );
$cgi->is_method_get();
$cgi->is_method_post();
my $value = $cgi->value('param_name');
$cgi->print_header();
$cgi->return_status('status');

=head1 METHODS

=item my $cgi = App::Helper::Web->new( %parameters );

Конструктор объекта. В качестве входным должен получить следующие параметры:
logger Объект логгера

=item $cgi->is_method_get();

Возвращает истину, если запрос был совершен методом GET

=item $cgi->is_method_post();

Возвращает истину, если запрос был совершен методом POST

=item my $value = $cgi->value('param_name');

Возвращает значение переданного в запросе параметра с именем param_name

=item $cgi->print_header();

Выводит заголовок страницы

=item $cgi->return_status('status');

Возвращает в заголовке страницы статус документа

=cut
