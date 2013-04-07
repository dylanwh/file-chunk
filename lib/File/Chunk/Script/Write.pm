# ABSTRACT: Write chunked files from the shell.
package File::Chunk::Script::Write;
use Moose;
use namespace::autoclean;

use MooseX::Types::Path::Class 'File';
use File::Chunk::Handle;

with 'File::Chunk::Script';

has 'output_file' => (
    traits    => ['Getopt'],
    is        => 'ro',
    isa       => File,
    coerce    => 1,
    required  => 1,
    cmd_aliases => 'o',
);

has 'key' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has 'limit' => (
    traits      => ['Getopt'],
    is          => 'ro',
    isa         => 'Int',
    cmd_aliases => 'l',
    predicate   => 'has_limit',
);

sub new_handle { 
    my ($self, $file) = @_;
    
    return File::Chunk::Handle->new(file => $file);
}


sub run {
    my $self = shift;
    my $h      = $self->new_handle($self->output_file);
    my $writer = $h->new_writer($self->key, $self->has_limit ? ( $self->limit ) : () );

    while (<STDIN>) {
        $writer->print($_);
    }
}

__PACKAGE__->meta->make_immutable;

1;
