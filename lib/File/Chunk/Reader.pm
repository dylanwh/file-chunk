package File::Chunk::Reader;
use Moose;

use File::Chunk::Iter;
use Carp;
use IO::Handle::Util 'io_to_glob';
use MooseX::Types::Moose 'ArrayRef';
use MooseX::Types::Path::Class 'Dir';
use MooseX::SetOnce;
use Path::Class::Rule;

use namespace::clean;

use overload ( '*{}' => \&io_to_glob, fallback => 1 );

has 'file_dir' => (
    is       => 'ro',
    isa      => Dir,
    required => 1,
);

has 'binmode' => (
    traits    => ['SetOnce'],
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_binmode',
);

has 'chunk_filename_regexp' => (
    is       => 'ro',
    isa      => 'RegexpRef',
    required => 1,
);

has '_chunk_iter' => (
    init_arg => undef,
    is       => 'ro',
    isa      => 'File::Chunk::Iter',
    lazy     => 1,
    builder  => '_build_chunk_iter',
    handles  => {
        _chunk         => [ at => 0 ],
        _next_chunk    => 'next',
        _is_last_chunk => 'is_last',
    },
);

sub _build_chunk_iter {
    my $self = shift;
    my $rules         = Path::Class::Rule->new->skip_vcs->file->name( $self->chunk_filename_regexp );
    my $filename_iter = $rules->iter( $self->file_dir, { depthfirst => 1 } );
    my $chunk_iter    = sub {
        my $fn = $filename_iter->();
        if ($fn) {
            my $fh = $fn->openr;
            $fh->binmode( $self->binmode ) if $self->has_binmode;
            return $fh;
        }
        else {
            return undef;
        }
    };

    return File::Chunk::Iter->new(iter => $chunk_iter, look_ahead => 2);
}

sub eof {
    my $self = shift;
    
    return 1 if $self->_chunk->eof && $self->_is_last_chunk;
    return '';
}

sub getline {
    my $self = shift;

    for (;;) {
        return undef unless defined $self->_chunk;
        my $line = $self->_chunk->getline;
        return $line if defined $line;
        return undef if $self->_is_last_chunk;
        $self->_next_chunk;
    }
}

sub print {
    croak "print not implemented";
}

__PACKAGE__->meta->make_immutable;

1;
