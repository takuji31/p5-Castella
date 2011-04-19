use inc::Module::Install;
use Module::Install::ReadmeFromPod;
use Module::Install::Repository;
name 'Castella';
all_from 'lib/Castella.pm';
readme_from 'lib/Castella.pm';

# requires '';
requires 'Class::Accessor::Lite';
requires 'Class::Data::Inheritable';
requires 'Class::Load';
requires 'Data::Section::Simple';
requires 'parent';
requires 'Plack::Request';
requires 'Plack::Response';
requires 'Text::Xslate';
requires 'Try::Tiny';
requires 'UNIVERSAL::can';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
build_requires 'Test::LoadAllModules';
use_test_base;
auto_include;
auto_set_repository;
WriteAll;
