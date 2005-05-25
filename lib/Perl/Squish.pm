package Perl::Squish;

=pod

=head1 NAME

Perl::Squish - Reduce Perl code to a few characters as possible

=head1 DESCRIPTION

Perl source code can often be quite large, with copious amounts of
comments, inline POD documentation, and inline tests and other padding.

The actual code can represent as little as 10-20% of the content of
well-written modules.

In situations where the Perl files need to be included, but do not need
to be readable, this module will "squish" them. That is, it will strip
out as many characters as it can from the source, while leaving the
function of the code identical to the original.

=head1 METHODS

=cut

use strict;
use Params::Util '_INSTANCE';
use PPI;

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.01';
}





#####################################################################
# Main Methods

=pod

=head2 file $filename [, $output ]

The C<file> method squishes a Perl document by filename. If passed a single
parameter, it modifies the file in-place. If provided a second parameter,
it will attempt to save the squished file to the alternative filename.

Returns true on success, or C<undef> on error.

=cut

sub file {
	my $squish   = shift;

	# Load the Document
	my $input    = defined $_[0] ? shift : return undef;
	my $Document = PPI::Document->new( "$input" ) or return undef;

	# Process
	$squish->document( $Document ) or return undef;

	# Save the document
	my $output = @_
		? defined $_[0] ? "$_[0]" : undef
		: $input;
	$output or return undef;
	$Document->save( $output );
}

=pod

=head2 document $Document

The C<document> method takes a L<PPI::Document> object, and modifies it
directly.

Returns the document object as a convenience, or C<undef> on error.

=cut

sub document {
	my $class    = shift;
	my $Document = _INSTANCE(shift, 'PPI::Document') or return undef;

	# Remove the easy things
	$Document->prune('Statement::End');
	$Document->prune('Token::Comment');
	$Document->prune('Token::Pod');

	# Remove redundant braces from ->method()
	$Document->prune( sub {
		my $Braces = $_[1];
		$Braces->isa('PPI::Structure::List')      or return '';
		$Braces->children == 0                    or return '';
		my $Method = $Braces->sprevious_sibling   or return '';
		$Method->isa('PPI::Token::Word')          or return '';
		$Method->content !~ /:/                   or return '';
		my $Operator = $Method->sprevious_sibling or return '';
		$Operator->isa('PPI::Token::Operator')    or return '';
		$Operator->content eq '->'                or return '';
		return 1;
		} );

	# Lets also do some whitespace cleanup
	$Document->index_locations or return undef;
	my $whitespace = $Document->find('Token::Whitespace');
	foreach ( @$whitespace ) {
		if ( $_->location->[1] == 1 and $_->{content} =~ /\n\z/s ) {
			$_->delete;
		} else {
			$_->{content} = $_->{content} =~ /\n/ ? "\n" : " ";
		}
	}
	$Document->flush_locations;

	$Document;
}

1;

=pod

=head1 SUPPORT

Bugs should always be submitted via the CPAN bug tracker, located at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl-Squish>

For general comments, contact the author.

=head1 AUTHOR

Adam Kennedy, L<http://ali.as/>, cpan@ali.as

=head1 SEE ALSO

L<PPI>

=head1 COPYRIGHT

Copyright (c) 2005 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
