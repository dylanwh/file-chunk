# ABSTRACT: Wrap a callback iterator to allow variable look-ahead.

package File::Chunk::Iter;
use Moose;
use namespace::autoclean;
use Carp;

has 'iter' => (
    traits   => ['Code'],
    is       => 'ro',
    isa      => 'CodeRef',
    required => 1,
    handles => { _next => 'execute' },
);

has 'look_ahead' => (
    is      => 'ro',
    isa     => 'Int',
    default => 2,
);

has '_queue' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
    handles => {
        next   => 'shift',
        at     => 'get',
        _size  => 'count',
        _push  => 'push',
    },
);

sub BUILD {
    my $self = shift;

    croak "look-ahead must be > 1!" unless $self->look_ahead > 1;

    while ($self->_size < $self->look_ahead) {
        $self->_look_ahead or last;
    }
}

after 'next' => sub {
    my $self = shift;
    $self->_look_ahead;
};

# true if ->next would be undef
sub is_done {
    my $self = shift;

    return 0 if $self->_size == 0;
    return not defined $self->at(0);
}

sub is_last {
    my $self = shift;

    return 0 if $self->_size == 0;
    return not defined $self->at(1);
}

sub _look_ahead {
    my $self = shift;

    unless ($self->is_done) {
        my $next = $self->_next;
        $self->_push( $next );
        unless (defined $next) {
            return 0
        }
    }
    else {
        $self->_push(undef);
    }

    if ($self->_size > $self->look_ahead) {
        croak "we traveled farther than look-ahead!";
    }
    return 1;
}


__PACKAGE__->meta->make_immutable;


1;
