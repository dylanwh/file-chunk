# ABSTRACT: Read/Write file handles that are stored as seperate, size-limited files on disk

package File::Chunk;
use Moose;
use Bread::Board::Declare;

use namespace::autoclean;


__PACKAGE__->meta->make_immutable;

1;
