# ABSTRACT: Chunk file regex base role

package File::Chunk::Format::Regexp;
use Moose::Role;
use namespace::autoclean;

use MooseX::Params::Validate;
use MooseX::Types::Path::Class 'Dir', 'File';

use Path::Class::Rule;

with 'File::Chunk::Format';

requires 'chunk_regexp';

sub find_chunk_files {
    my $self = shift;
    my ($dir) = pos_validated_list( \@_, { isa => Dir, coerce => 1 } );

    my $rules = Path::Class::Rule->new->skip_vcs->file->name($self->chunk_regexp);

    return $rules->iter( $dir, { depthfirst => 1 } );
}

sub decode_chunk_filename {
    my $self = shift;
    my ($file) = pos_validated_list(\@_, { isa => File });

    my $re = $self->chunk_regexp;
    if ($file->basename =~ /^($re)$/) {
        return $1;
    }
    else {
        return undef;
    }
}


1;
