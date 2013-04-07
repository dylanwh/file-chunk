# ABSTRACT: Chunk files stored as plain integers.

package File::Chunk::Format::IntBare;
use Moose;
use namespace::autoclean;

use MooseX::Params::Validate;
use MooseX::Types::Path::Class 'File';

use Path::Class::Rule;

with 'File::Chunk::Format::Regexp';

sub chunk_regexp { qr/^\d+$/ }

around decode_chunk_filename => sub {
    my ($method, $self, @args) = @_;
    int($self->$method(@args));
};

sub encode_chunk_filename {
    my $self = shift;
    my ($i) = pos_validated_list(\@_, { isa => 'Int' });

    sprintf "%d", $i;
}


__PACKAGE__->meta->make_immutable;

1;
