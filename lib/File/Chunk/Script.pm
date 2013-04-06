package File::Chunk::Script;
use Moose::Role;
use namespace::autoclean;

with 'MooseX::Getopt::GLD' => { getopt_conf => [ 'gnu_getopt' ] };

around _get_cmd_flags_for_attr => sub {
    my $next = shift;
    my ( $class, $attr, @rest ) = @_;

    my ( $flag, @aliases ) = $class->$next($attr, @rest);
    $flag =~ tr/_/-/
        unless $attr->does('MooseX::Getopt::Meta::Attribute::Trait')
            && $attr->has_cmd_flag;

    return ( $flag, @aliases );
};

requires 'run';


1;
