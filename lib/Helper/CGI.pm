package Helper::CGI;
use strict;
use warnings;
use parent 'BaseObject';
use CGI qw[ :cgi ];
use Data::Dumper;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = $class->SUPER::new(
        logger => undef,
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
    my $self = shift;
    my $type = shift || 'text/html';

    my %headers = (
        -type          => $type,
        -cache_control => 'no-cache',
    );
    $headers{-charset} = 'utf-8' if $type =~ /^text\//;
    my $cookie = $self->_get('cookie');
    $headers{-cookie} = $cookie if $cookie;

    print $self->_cgi->header(%headers);
}

sub return_status {
    my $self   = shift;
    my $status = shift;

    return unless $status;

    print $self->_cgi->header(
        -type   => 'text/plain',
        -status => $status
    );

    exit;
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

Helper::CGI - Работа с CGI

=head1 SYNOPSIS

use Helper::CGI;
my $cgi = Helper::CGI->new( logger => object );
$cgi->is_method_get();
$cgi->is_method_post();
my $value = $cgi->value('param_name');
$cgi->print_header();
$cgi->return_status('status');

=head1 METHODS

=item my $cgi = Helper::CGI->new( %parameters );

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
