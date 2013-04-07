# ABSTRACT: Role for findings (TODO: generating) chunk file names.

package File::Chunk::Format;
use Moose::Role;
use namespace::autoclean;


=method find_chunk_files($dir)

Return a callback iterator that successively returns chunk filenames in $dir as L<Path::Class::File> objects.

=cut

requires 'find_chunk_files', 'decode_chunk_filename', 'encode_chunk_filename';


1;
