package Helper::Config;
use strict;
use warnings;
use parent 'BaseObject';
use Config::Simple;

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = $class->SUPER::new(
        config_file => undef,
        %params,
    );

    $class = ref $class if ref $class;
    bless $self, $class;

    return $self;
}

sub get {
    my $self = shift;

    my $config_file = $self->_get('config_file');
    unless ( $config_file && -e $config_file ) {
        $self->_log("Не найден файл конфигурации $config_file");
        return ();
    }

    my %config;
    Config::Simple->import_from( $config_file, \%config );
    # Превращаем ключи хеша вида some.key в древовидный хэш
    foreach my $key ( keys %config ) {
        my ( $fist_key, $second_key ) = $key =~ /^([^\.]+)\.(.+)$/ ? ( $1, $2 ) : ( $key, '' );
        next unless $second_key;
        $config{$fist_key}{$second_key} = $config{$key};
        delete $config{$key};
    }

    return %config;
}

1;

__END__

=head1 NAME

Helper::Config - Получение конфигурации приложения

=head1 SYNOPSIS

use Helper::Config;
my $cfg = Helper::Config->new( config_file => string, logger => object );
my %config = $cfg->get();

=head1 METHODS

=item my $cfg = Helper::Config->new( %parameters );

Конструктор объекта. В качестве входным должен получить следующие параметры:
config_file  Файл с конфигурацией
logger       Объект логгера

=item %config = $cfg->get();

Возвращает конфигурацию, полученную из файла

=cut
