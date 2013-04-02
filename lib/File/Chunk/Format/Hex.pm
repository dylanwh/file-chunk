# ABSTRACT: Chunk files stored in $X.chunk where $X is an eight "digit" hex number.

package File::Chunk::Format::Hex;
use Moose;
use namespace::autoclean;

use MooseX::Params::Validate;
use MooseX::Types::Path::Class 'Dir';

use Path::Class::Rule;

with 'File::Chunk::Format';

sub find_chunk_files {
    my $self = shift;
    my ($dir) = pos_validated_list( \@_, { isa => Dir, coerce => 1 } );

    my $rules = Path::Class::Rule->new->skip_vcs->file->name(qr/^[[:xdigit:]]{8}\.chunk$/);

    return $rules->iter( $dir, { depthfirst => 1 } );
}

__PACKAGE__->meta->make_immutable;

1;
