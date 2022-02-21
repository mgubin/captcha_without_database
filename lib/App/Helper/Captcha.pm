package App::Helper::Captcha;
use strict;
use warnings;
use parent 'App::Base';
use GD;
use Digest::MD5 qw(md5_hex);
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

    return $self;
}

sub draw {
    my $self = shift;
    my $code = shift;

    my $config = $self->_config;
    my $image  = new GD::Image( $config->{captcha}{width}, $config->{captcha}{height} );
    my $white  = $image->colorAllocate( 255, 255, 255 );
    my $gray   = $image->colorAllocate( 100, 100, 100 );
    # my $font   = GD::Font->load( $config->{captcha}{font_path} );
    $image->transparent($white);
    $image->interlaced('true');

    $image->rectangle( 0, 0, $config->{captcha}{width} - 1, $config->{captcha}{height} - 1, $gray );

    # Chars
    my @code_chars   = split //, $code;
    my $letter_field = int ( ( $config->{captcha}{width} - 12 ) / $config->{captcha}{code_lenght} );
    foreach my $char_id ( 0 .. $#code_chars ) {
        my $angle = ( int ( rand (7) ) - 3 ) / 10;
        $image->stringFT( $gray, $config->{captcha}{font_path}, $config->{captcha}{font_size}, $angle, 5 + $char_id * $letter_field, $config->{captcha}{shift_y}, $code_chars[$char_id] );
    }

    # Lines
    my $width_quarter  = $config->{captcha}{width} / 4;
    my $height_quarter = $config->{captcha}{height} / 4;

    my $x1 = int ( rand ($width_quarter) ) + 5;
    my $y1 = int ( rand ($height_quarter) ) + 5;
    my $x2 = int ( rand ($width_quarter) ) + $width_quarter * 3 - 5;
    my $y2 = int ( rand ($height_quarter) ) + $height_quarter * 3 - 5;
    $image->line( $x1, $y1, $x2, $y2, $gray );

    $x1 = int ( rand ($width_quarter) ) + 5;
    $y1 = int ( rand ($height_quarter) ) + $height_quarter * 3 - 5;
    $x2 = int ( rand ($width_quarter) ) + $width_quarter * 3 - 5;
    $y2 = int ( rand ($height_quarter) ) + 5;
    $image->line( $x1, $y1, $x2, $y2, $gray );

    # Dots
    foreach ( 1 .. $config->{captcha}{noise_pixels} ) {
        my $x1 = int ( rand ( $config->{captcha}{width} ) );
        my $y1 = int ( rand ( $config->{captcha}{height} ) );
        $image->setPixel( $x1, $y1, $gray );
    }

    return $image->png;
}

sub get_hash {
    my $self = shift;
    my $code = shift;

    my $salt = $self->_config->{app}{salt};
    $code .= ":$salt" if $salt;

    return md5_hex($code);
}

sub check {
    my ( $self, $captcha, $cookie_hash ) = @_;

    return unless $captcha && $cookie_hash;

    my $captcha_hash = $self->get_hash($captcha);

    return $cookie_hash eq $captcha_hash;
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
my $param = $cgi->param('param_name');
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

=item my $param = $cgi->param('param_name');

Возвращает значение переданного в запросе параметра с именем param_name

=item $cgi->print_header();

Выводит заголовок страницы

=item $cgi->return_status('status');

Возвращает в заголовке страницы статус документа

=cut
