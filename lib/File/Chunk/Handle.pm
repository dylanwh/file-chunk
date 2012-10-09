package File::Chunk::Handle;
use Moose;
#use namespace::autoclean;

use Carp;
use MooseX::Types::Path::Class 'File', 'Dir';
use MooseX::Types::Moose 'Int', 'Str', 'RegexpRef';
use MooseX::Params::Validate;

use File::Chunk::Writer;
use File::Chunk::Reader;

use namespace::clean;

use overload ( q{""} => 'stringify', fallback => 1 );

has 'file' => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
    required => 1,
    handles  => ['stringify'],
);

has 'chunk_line_limit' => (
    is      => 'ro',
    isa     => Int,
    default => 1000,
);

has 'chunk_dirname_format' => (
    is      => 'ro',
    isa     => 'Str',
    default => '%s',
);

has 'chunk_filename_format' => (
    is       => 'ro',
    isa      => Str,
    default  => '%.8x.chunk',
);

has 'chunk_filename_regexp' => (
    is      => 'ro',
    isa     => RegexpRef,
    default => sub {qr/^[[:xdigit:]]{8}\.chunk$/},
);

has 'file_dir' => (
    is      => 'ro',
    isa     => Dir,
    lazy    => 1,
    builder => '_build_file_dir',
    #handles => { chunk_dir => 'subdir' },
);

sub chunk_dir {
    my ($self, $key) = @_;

    return $self->file_dir->subdir( sprintf $self->chunk_dirname_format, $key );
}

sub new_writer {
    my $self = shift;
    my ( $key, $limit ) = pos_validated_list(
        \@_,
        { isa => Str },
        {   
            isa     => Int,
            default => $self->chunk_line_limit
        }
    );

    my $writer = File::Chunk::Writer->new(
        chunk_dir             => $self->chunk_dir($key),
        chunk_line_limit      => $limit,
        chunk_filename_format => $self->chunk_filename_format,
    );

    if (-e $writer->chunk_dir) {
        croak "Unable to obtain writer for $self with key: $key";
    }

    $writer->chunk_dir->mkpath;
    return $writer;
}

sub new_reader {
    my $self = shift;
    my $reader = File::Chunk::Reader->new(
        file_dir              => $self->file_dir,
        chunk_filename_regexp => $self->chunk_filename_regexp,
    );
}

sub delete {
    my $self = shift;
    my ($key) = pos_validated_list(\@_, { isa => Str });

    $self->chunk_dir($key)->rmtree;
}

sub exists {
    my $self = shift;
    my ($key) = pos_validated_list(\@_, { isa => Str, optional => 1 });

    if (defined $key) {
        return -d $self->chunk_dir($key);
    }
    else {
        return -d $self->file_dir;
    }
}

sub _build_file_dir {
    my $self = shift;

    return $self->file->parent->subdir( $self->file->basename . ".d" );
}

__PACKAGE__->meta->make_immutable;

1;
