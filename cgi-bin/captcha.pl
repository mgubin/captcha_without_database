#!/usr/bin/perl
BEGIN {
    use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
}
use strict;
use warnings;
use lib qw( ../lib );
use App::Controller::Captcha;
use Data::Dumper;
use App::Helper::Config;
use App::Helper::Logger;

my $logger = App::Helper::Logger->new();

# Получаем конфигурацию
my %config = App::Helper::Config->new(
    config_file => '../conf/capture.cfg',
    logger      => $logger
)->get();

my $web = App::Controller::Captcha->new(
    config => \%config,
    logger => $logger,
);

$web->process() if $web;

__END__

