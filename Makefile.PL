use inc::Module::Install;

name          ( 'Perl-Squish'                );
abstract      ( 'Reduce Perl code to the smallest number of characters' );
author        ( 'Adam Kennedy <cpan@ali.as>' );
version_from  ( 'lib/Perl/Squish.pm'         );
license       ( 'perl'                       );

requires      ( 'perl'            => '5.005' );
requires      ( 'PPI'             => '0.990' );

build_requires( 'Test::More'      => '0.47'  );
build_requires( 'File::Spec'      => '0.82'  );

# Our test data might contain valid-looking modules.
# Don't index anything in the test data directory.
no_index      ( directory         => 't.data' );

auto_install();

&WriteAll;
