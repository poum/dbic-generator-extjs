package ExtJS::Generator::DBIC::JsFile;

use Moose;
use namespace::autoclean;
use File::Basename;
use File::Path qw/make_path/;
use File::Copy;
use File::Slurp;
use Regexp::Common;
use Carp;

# ABSTRACT: Javascript file object to handle ExtJS file

=head1 METHODS

The loaded file will be split in 3 parts:

=over 4

=item * the prefix: the text before the usefull part

=item * the object, ie the usefull part. All methods and comments in it are replaced by JSON containers

=item * the suffix: the text after the usefull part

=back

=head2 className

The defined class name

=cut

has 'className' => (
    is => 'rw',
    isa => 'Str'
);

=head2 file

File full path

=cut

has 'file' => (
    is => 'rw',
    isa => 'Str'
);

=head2 prefix

File part before the define part, to be keept as it is

=cut

has 'prefix' => (
    is => 'rw',
    isa => 'Str',
    default => sub { '' }
);

=head2 define

The define line 

=cut

has 'define' => (
    is => 'rw',
    isa => 'Str'
);

=head2 object

File usefull part

=cut

has 'object' => (
    is => 'rw',
    isa => 'Str',
    default => sub { '{}' }
);

=head2 end_define

The ending of define

=cut

has 'end_define' => (
    is => 'rw',
    isa => 'Str',
    default => sub { ');' }
);

=head2 funtions 

All method body found in object

=cut

has 'methods' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} }
);

=head2 comments

All comments found in object

=cut

has 'comments' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} }
);

=head2 suffix

File part after the usefull part, to be kept as it is

=cut

has 'suffix', => (
    is => 'rw',
    isa => 'Str',
    default => sub { '' }
);

=head2 parse

Parse file. The .js extension will be automatically added if omitted.
The following assertions are made:

=over 4

=item the file contains at least one Ext.define on which we have to work

=item this Ext.define class name ends like the file name does, by example: 'My.model.Basic' for Basic.js

=back

=head3 parameters

=over 4

=item type : ExtJS class type to generate (model - default -, store, controller or view.Form, view.Tree, view.Grid)

=item file : the javascript class definition file to parse (B<mandatory>). The .js extension will be automatically added if needed.

=item path : the javascript class definition file path where the file should be

=back

JsFile will attempt to retrieve file using the following strategies :

=over 4

=item if the file name is an absolute path (starting with /) or a relative path from the current dir or the upper dir, only try this location

=item 'path'/'type'/'file' (will stay the location if no file is found). If 'path' isn't absolute, './' is added.

=item 'path'/'file'. If 'path' isn't absolute, './' is added.

=item ./'type'/'file'

=item ./'file'

=back

=head3 return

the JsParser object reference

=cut

sub parse {
  my $self = shift;
  my %param = (path => '.', type => 'model', @_);
    
  my @typeOk = qw/model store controller view.Form view.Grid view.Tree/;
  croak "Type parameter mandatory (" . join(', ', @typeOk) . ')' unless $param{type};
  grep /^$param{type}$/, @typeOk or croak 'Unknow type ' . $param{type} . ' : use ' . join(', ', @typeOk); 
  croak "File name parameter mandatory" unless $param{file};

  $param{file} .= '.js' unless $param{file} =~ /\.js$/;
  my $name = basename($param{file}, '.js');

  if ($param{file} =~ /^\.{0,2}\//) {
    $self->file($param{file});
  }
  else {
    $param{path} = './' . $param{path} unless $param{path} =~ /^\.{0,2}\//;

    $self->file(join '/', $param{path}, $param{type}, $param{file});
    unless (-e $self->file) {
        if (-e join '/', $param{path}, $param{file}) {
            $self->file(join '/', $param{path}, $param{file});
        } 
        elsif (-e join '/', './' . $param{type}, $param{file}) {
            $self->file(join '/', './', $param{type}, $param{file});
        }
        elsif (-e './' . $param{file}) {
            $self->file('./' . $param{file});
        }
    }
  }

  if (-e $self->file) {
      my $object = read_file($self->file) or croak "Error while loading '$self->file' : $!";

      $object =~ s/^(.*)(?=Ext.define\s*\(\s*'([^']+\.$name)'\s*,\s*\{)//s;

      # extract define class name and all Javacript before it
      $self->prefix($1) if $1;
      croak "No class name found" unless $2;
      $self->className($2);

      # extract the define part
      $object =~ s/^([^{]+)//s;
      $self->define($1) or croak "No define found";

      # extract all Javascript after the define body
      $object =~ s/($RE{balanced}{-parens => '{}'})(\s*\)\s*;)(.*)$/$1/ms;
      # yes, it should be $2 and $3 but $RE should add one behind the scene
      $self->end_define($3) if $3;
      $self->suffix($4) if $4;

      # replace all methods by a String because this isn't JSON
      my $cpt = 1;
      while ($object =~ /(function\s*$RE{balanced}{-parens => '()'}\s*$RE{balanced}{-parens => '{}' })/s) {
        $self->methods()->{"METHOD_$cpt"} = $1;
        $object =~ s/function\s*$RE{balanced}{-parens => '()'}\s*$RE{balanced}{-parens => '{}' }/"METHOD_$cpt"/s;
        $cpt++;
      }

      # replace all inner comments by ',{comment_NNN:"comment_NNN"},' because this isn't JSON
      # we do this after extracting method to let method comments as they are
      # n fonctionne pas
      $cpt = 1;
      my ($context, $virgule, $mask);
      while ($object =~ /(^.*?)($RE{comment}{JavaScript})/s) {
        $self->comments()->{"COMMENT_$cpt"} = $2;
        ($context, $virgule) = $self->findContext($1);
        $mask = 'comment:"COMMENT_' . $cpt . '"';
        $mask = '{' . $mask . '}' if $context eq '[';
        $mask = ',' . $mask if $virgule;
        $object =~ s/$RE{comment}{JavaScript}/$mask,/s;
        $cpt++;
      }

      # add num to each key to fix key order
      # remenber some keys in $self->keys to link with numbered
      $cpt = 1;
      while ($object =~ /("?)([A-Za-z0-9_]+)\1\s*:/s) {
        $mask = $1 . $2 . $1;
        $object =~ s/$mask:/sprintf('##%06d##%s##:', $cpt, $mask)/se;
        $cpt++;
      }

      # '##' was to avoid previous loop beeing infinite and beyond
      # but '##' is JSON invalid
      $object =~ s/##/__/gs;
      $self->object($object); 
  }
  # no file, just get className
  else {
    croak "Namespace mandatory for first generation" unless $param{namespace};
    $self->className(join '.', $param{namespace}, $param{type}, $name);
  }
 
  return $self; 
}

# Analyse le code 
# et retourne la parenthèse englobante [ ou {
# et un flag si une virgule est nécessaire
sub findContext {
  my $self = shift;
  my $text = shift;

  $text =~ s/[^\[\]\{\},]//gs;
  my $virgule = substr $text, -1, 1;
  $virgule = ($virgule =~ /,|\[|\{/) ? 0 : 1;

  $text =~ s/,//g;
  $text =~ s/(\[\]|\{\})//g while $text =~ /(\[\]|\{\})/;

  return (substr($text, -1, 1), $virgule);
}

=head2 output

Assemble all parsed parts into one string

=head3 return

A string with all parsed parts reassembled

=cut
sub output {
    my $self = shift;

    my $object = $self->object;

    $object =~ s/__\d+__([A-Za-z0-9_]+)__/$1/gs;

    while ( my ($key, $comment) = each $self->comments() ) {
      $object =~ s/,?\{?comment:"$key"\}?,/$comment/s;
    }

    while (my ($key, $method) = each $self->methods() ) {
      $object =~ s/"$key"/$method/s;
    }

    return $self->prefix . "Ext.define('" . $self->className . "', $object" . $self->end_define . $self->suffix;
}

=head2 write

Write the generated file.

=head3 Parameter

=over 4

=item B<backup> : flag to request backup (true by default)

=back

=cut
sub write {
    my $self = shift;
    my %param = (backup => 1, @_);

    if (-e $self->file) {
        # backup flag ?    
        if ($param{backup}) {
            copy($self->file, $self->file . '.bak') or croak "Abort, unable to make backup : $!";
        }
    }
    else {
        my $path = dirname($self->file);
        unless (-d $path) {
            make_path($path) or croak "Unable to create dir '$path' : $!";
        }
    }

    write_file($self->file, $self->output()) or croak "Unable to write " . $self->file . " : $!";
}

__PACKAGE__->meta->make_immutable;

1;
