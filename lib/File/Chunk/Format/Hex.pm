# ABSTRACT: Chunk files stored in $X.chunk where $X is an eight "digit" hex number.

package File::Chunk::Format::Hex;
use Moose;
use namespace::autoclean;

use MooseX::Params::Validate;
use MooseX::Types::Path::Class 'File';

use Path::Class::Rule;

with 'File::Chunk::Format::Regexp';

sub chunk_regexp { qr/^[[:xdigit:]]{8}\.chunk$/ }

around decode_chunk_filename => sub {
    my ($method, $self, @args) = @_;
    hex($self->$method(@args));
};

sub encode_chunk_filename {
    my $self = shift;
    my ($i) = pos_validated_list(\@_, { isa => 'Int' });

    return sprintf "%.8x.chunk", $i; 
}


__PACKAGE__->meta->make_immutable;

1;
