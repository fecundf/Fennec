package Fennec::Manual::TODO;
use strict;
use warnings;

1;
__END__

=pod

=head1 NAME

Fennec::Manual::TODO - Things that need documentation

=head1 DESCRIPTION

This is a list of things to document gatherd by looking through the code.

=head1 DOCUMENTATION TODO LIST

=over 4

=item fennec.t options

    p_files => 2,
    p_tests => 2,
    cull_delay => .01,
    handlers => [qw/ TAP /],
    random => 1,
    Collector => 'Files',
    ignore => undef,
    filetypes => [qw/ Module /],
    default_asserts => [qw/Core Interceptor/],
    default_workflows => [],
    $ENV{ FENNEC_FILE } ? ( files => [ cwd() . '/' . $ENV{ FENNEC_FILE }]) : (),
    $ENV{ FENNEC_ITEM } ? ( search => $ENV{ FENNEC_ITEM }) : (),

=item passing options to standalone

=item automatic TestFile baseclass

=item specifying asserts and workflow

=item how benchmarks are done

=item Core assert libraries

=item testing fennec plugins with interceptor


=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.