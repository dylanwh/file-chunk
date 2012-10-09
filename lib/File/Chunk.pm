# ABSTRACT: Highly configurable chunked file reading/writing

package File::Chunk;
use Moose;
use Bread::Board::Declare;

use namespace::autoclean;


__PACKAGE__->meta->make_immutable;

1;
