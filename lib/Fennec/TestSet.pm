package Fennec::TestSet;
use strict;
use warnings;

use base 'Fennec::Base::Method';

use Fennec::Util::Accessors;
use Exporter::Declare;
use Try::Tiny;
use Carp;
use B;

use Fennec::Util::Alias qw/
    Fennec::Runner
    Fennec::Output::Result
    Fennec::Workflow
/;

use Time::HiRes qw/time/;
use Benchmark qw/timeit :hireswallclock/;

Accessors qw/ workflow /;

export 'tests' => sub {
    my $name = shift;
    my %proto = @_ > 1 ? @_ : (method => shift( @_ ));
    my ( $caller, $file, $line ) = caller;
    Workflow->add_item( __PACKAGE__->new( $name, file => $file, line => $line, %proto ));
};

sub lines_for_filter {
    my $self = shift;
    B::svref_2object( $self->method )->START->line;
}

sub run {
    my $self = shift;
    return Result->skip_testset( $self, $self->skip )
        if $self->skip;

    try {
        my $benchmark = timeit( 1, sub {
            $self->run_on( $self->testfile );
        });
        Result->pass_testset( $self, $benchmark );
    }
    catch {
        Result->fail_testset( $self, $_ );
    };
}

sub part_of {
    my $self = shift;
    my ( $search ) = @_;
    return 1 if $self->name eq $search;
    return 0 unless my $workflow = $self->workflow;
    do {
        return 1 if $workflow->name eq $search;
        $workflow = $workflow->parent;
    } while( $workflow && $workflow->isa( 'Fennec::Workflow' ));
    return 0;
}

sub testfile {
    my $self = shift;
    return unless $self->workflow;
    return $self->workflow->testfile;
}

sub skip {
    my $self = shift;
    return $self->SUPER::skip( @_ )
        || $self->workflow->skip;
}

sub todo {
    my $self = shift;
    return $self->SUPER::todo()
        || $self->workflow->todo;
}

1;

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.