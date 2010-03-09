package Fennec::Files;
use strict;
use warnings;

use Fennec::Runner::Root;
use File::Find qw/find/;
use Fennec::Util qw/add_accessors/;
use Try::Tiny;
use Carp;
use base 'Exporter';

add_accessors qw/bad_files types/;

our @EXPORT_OK = qw/add_to_wanted/;
our %WANTED;

sub add_to_wanted {
    my ( $name, $match, $loader ) = @_;
    croak( "Must provide a name to 'add_to_wanted()'" )
        unless $name;
    croak( "$name is already defined as a file type" )
        if $WANTED{ $name };
    croak( "Second argument to 'add_to_wanted()' must be a regex" )
        unless $match and ref $match eq 'Regexp';
    croak( "Third argument to 'add_to_wanted()' must be a coderef" )
        unless $loader and ref $loader eq 'CODE';

    $WANTED{ $name } = [ $match, $loader ];
}

sub new {
    my $class = shift;
    my @types = @_ ? @_ : keys %WANTED;
    my $self = bless({ types => \@types, bad_files => [] }, $class );
    return $self;
}

sub list {
    my $self = shift;
    $self->_find unless $self->{ list };
    return @{ $self->{ list } };
}

sub _find {
    my $self = shift;
    my $root = Fennec::Runner::Root->new->path;
    my @list;
    my $wanted = sub {
        no warnings 'once';
        my $file = $File::Find::name;
        return if grep { $file =~ $_ } @{ Fennec::Runner->get->ignore };
        return unless my ($type) = grep { $file =~ $WANTED{ $_ }->[0] } @{ $self->types };
        push @list => [ $type, $file ];
    };
    my @paths = ( "$root/t", "$root/lib" );
    find( $wanted, @paths ) if @paths;
    $self->{ list } = \@list;
}

sub load {
    my $self = shift;
    for my $item ( $self->list ) {
        try {
            $WANTED{ $item->[0] }->[1]->( $item->[1] ) || die( "Loader did not return true" );
        }
        catch {
            push @{ $self->bad_files } => [ $item->[1], $_ ];
        };
    }
}

1;