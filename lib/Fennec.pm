package Fennec;
use strict;
use warnings;

use Carp;
use Fennec::Util::PackageFinder;

use Fennec::Util::Alias qw/
    Fennec::Runner
    Fennec::TestFile
    Fennec::Assert
/;

our $VERSION = "0.017";
our $TEST_CLASS;
our @TEST_CLASS_ARGS;

sub _clear_test_class { $TEST_CLASS = undef }
sub _test_class { $TEST_CLASS }
sub _test_class_args { @TEST_CLASS_ARGS }

sub import {
    my $class = shift;
    my %proto = @_;
    my ( $caller, $file, $line ) = $proto{ caller } ? (@{$proto{ caller }}) : caller;
    my ( $workflows, $asserts ) = @proto{qw/ workflows asserts /};
    my $standalone = delete $proto{ standalone };

    croak "Test runner not found"
        unless Runner;
    croak( "You must put your tests into a package, not main" )
        if $caller eq 'main';

    $TEST_CLASS = $caller;
    @TEST_CLASS_ARGS = @_;

    {
        no strict 'refs';
        push @{ $caller . '::ISA' } => TestFile;
    }

    _export_package_to( 'Fennec::TestSet', $caller );

    $workflows ||= Runner->default_workflows;
    _export_package_to( load_package( $_, 'Fennec::Workflow' ), $caller )
        for @$workflows;

    $asserts ||= Runner->default_asserts;
    _export_package_to( load_package( $_, 'Fennec::Assert' ), $caller )
        for @$asserts;

    no strict 'refs';
    no warnings 'redefine';
    *{ $caller . '::done_testing' } = sub {
        carp "calling done_testing() is only required for Fennec::Standalone tests"
    };

    *{ $caller . '::use_or_skip' } = sub(*;@) {
        my ( $package, @params ) = @_;
        my $eval = "package $caller; use $package"
        . (@params ? (
            @params > 1
                ? ' @params'
                : ($params[0] =~ m/^[0-9\-\.\e]+$/
                    ? " $params[0]"
                    : " '$params[0]'"
                  )
          ) : '')
        . "; 1";
        my $have = eval $eval;
        die "SKIP: $package is not installed or insufficient version: $@" unless $have;
    };
    *{ $caller . '::require_or_skip' } = sub(*) {
        my ( $package ) = @_;
        my $have = eval "require $package; 1";
        die "SKIP: $package is not installed\n" unless $have;
    };

    1;
}

sub _export_package_to {
    my ( $from, $to ) = @_;
    die( $@ ) unless eval "require $from; 1";
    $from->export_to( $to );
}

1;

=pod

=head1 NAME

Fennec - Framework upon which intercompatible testing solutions can be built.

=head1 DESCRIPTION

L<Fennec> provides a solid base that is highly extendable. It allows for the
writing of custom nestable workflows (like RSPEC), Custom Asserts (like
L<Test::Exception>), Custom output handlers (Alternatives to TAP), Custom file
types, and custom result passing (collectors). In L<Fennec> all test files are
objects. L<Fennec> also solves the forking problem, thats it, forking just
plain works.

=head1 EARLY VERSION WARNING

L<Fennec> is still under active development, many features are untested or even
unimplemented. Please give it a try and report any bugs or suggestions.

=head1 FEATURES

Fennec offers the following features, among others.

=over 4

=item No large dependancy chains

=item No method attributes

=item No use of END blocks

=item No Devel::Declare magic

=item No use of Sub::Uplevel

=item No source filters

=item Large library of core test functions

=item Plays nicely with L<Test::Builder> tools

=item Better diagnostics

=item Highly Extendable

=item Lite benchmarking for free

=item Works with prove

=item Full-Suite management

=item Standalone test support

=item Support for SPEC and other test workflows

=item Forking works

=item Run only specific test sets within test files (for development)

=item Intercept or hook into most steps or components by design

=back

=head1 DOCUMENTATION

=over 4

=item QUICK START

L<Fennec::Manual::Quickstart> - Drop Fennec standalone tests into an existing
suite.

=item FENNEC BASED TEST SUITE

L<Fennec::Manual::TestSuite> - How to create a Fennec based test suite.

=item MISSION

L<Fennec::Manual::Mission> - Why does Fennec exist?

=item MANUAL

L<Fennec::Manual> - Advanced usage and extending Fennec.

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
