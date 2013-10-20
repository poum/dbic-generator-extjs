package ExtJS::Generator::DBIC::JsFile;

use Moose;
use namespace::autoclean;
use File::Basename;
use File::Path qw/make_path/;
use File::Copy;
use Regexp::Common;
use Carp;

# ABSTRACT: ExtJS::Generator::DBIC::JsFile - Javascript file object to handle ExtJS file

=head2 METHODS

The loaded file will be split in 3 parts:

=over 4

=item * the prefix: the text before the usefull part

=item * the template, ie the usefull part. All methods and comments in it are replaced by JSON containers

=item * the suffix: the text after the usefull part

=back

=head3 className

The defined class name

=cut

has 'className' => (
    is => 'rw',
    isa => 'Str'
);

=head3 file

File full path

=cut

has 'file' => (
    is => 'rw',
    isa => 'Str'
);

=head3 prefix

File part before the define part, to be keept as it is

=cut

has 'prefix' => (
    is => 'rw',
    isa => 'Str',
    default => sub { '' }
);

=head3 define

The define line 

=cut

has 'define' => (
    is => 'rw',
    isa => 'Str'
);

=head3 template

File usefull part

=cut

has 'template' => (
    is => 'rw',
    isa => 'Str',
    default => sub { '{}' }
);

=head3 funtions 

All method body found in template

=cut

has 'functions' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} }
);

=head3 comments

All comments found in template

=cut

has 'comments' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} }
);

=head3 suffix

File part after the usefull part, to be kept as it is

=cut

has 'suffix', => (
    is => 'rw',
    isa => 'Str',
    default => sub { '' }
);

=head3 parse

Parse file. The .js extension will be automatically added if omitted.
The following assertions are made:

=over 4

=item the file contains at least one Ext.define on which we have to work

=item this Ext.define class name ends like the file name does, by example: 'My.model.Basic' for Basic.js

=back

=over 4 

=item Parameters

=over 4

=item type : ExtJS class type to generate (model - default -, store, controller or view.Form, view.Tree, view.Grid)

=item file : the javascript class definition file to parse (mandatory). The .js extension will be automatically added if needed.

=item path : the javascript class definition file path where the file should be

=back

JsFile will attempt to retrieve file using the following strategies :

=over 4

=item if the file name is an absolute path (starting with /) or a relative path from the current dir or the upper dir, only try this location

=item <path>/<type>/<file> (will stay the location if no file is found). If <path> isn't absolute, './' is added.

=item <path>/<file>. If <path> isn't absolute, './' is added.

=item ./<type>/<file>

=item ./<file>

=back

=cut

sub parse {
  my $self = shift;
  my %param = (path => '.', type => 'model', @_);
    
  my @typeOk = qw/model store controller view.Form view.Grid view.Tree/;
  croak "Type parameter mandatory (" . join(', ', @typeOk) . ')' unless $param{type};
  grep /^$param{type}$/, @typeOk or croak 'Unknow type ' .$param{type} . ' : use ' . join(', ', @typeOk); 
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
      my $template = '';
      open(my $fh, "<", $self->file) or croak "Error while loading '$self->file' : $!";
      $template .= $_ while <$fh>;
      close $fh;

      $template =~ s/^(.*)(?=Ext.define\s*\(\s*'([^']+\.$name)'\s*,\s*\{)//s;

      # extract define class name and all Javacript before it
      $self->prefix($1) if $1;
      croak "No class name found" unless $2;
      $self->className($2);

      # extract the define part
      $template =~ s/^([^{]+)//s;
      $self->define($1) or croak "No define found";

      # extract all Javascript after the define body
      $template =~ s/($RE{balanced}{-parens => '{}'})(.*)$/$1/s;
      $self->suffix($2) if $2;

      # replace all methods by a String because this isn't JSON
      my $cpt = 1;
      while ($template =~ /(function\s*$RE{balanced}{-parens => '()'}\s*$RE{balanced}{-parens => '{}' })/s) {
        $self->functions()->{"FUNC_$cpt"} = $1;
        $template =~ s/function\s*$RE{balanced}{-parens => '()'}\s*$RE{balanced}{-parens => '{}' }/"FUNC_$cpt"/s;
        $cpt++;
      }

      # replace all inner comments by ',{comment_NNN:"comment_NNN"},' because this isn't JSON
      # we do this after extracting method to let method comments as they are
      $cpt = 1;
      while ($template =~ /($RE{comment}{JavaScript})/s) {
        $self->comments()->{"COMMENT_$cpt"} = $1;
        $template =~ s/$RE{comment}{JavaScript}/,{comment:"COMMENT_$cpt"},/s;
        $cpt++;
      }

      $self->template($template); 
  }
  # no file, just get className
  else {
    croak "Namespace mandatory for first generation" unless $param{namespace};
    $self->className(join '.', $param{namespace}, $param{type}, $name);
  }
 
  return $self; 
}

=head3 output

Assemble all parsed parts into one string

=cut
sub output {
    my $self = shift;

    my $template = $self->template;

    while ( my ($key, $comment) = each $self->comments() ) {
      $template =~ s/,{comment:"$key"},/$comment/s;
    }

    while (my ($key, $function) = each $self->functions() ) {
      $template =~ s/"$key"/$function/s;
    }

    return $self->prefix . "Ext.define('" . $self->className . "', $template);" . $self->suffix;
}

=head3 write

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

    open(my $fh, '>', $self->file) or croak "Unable to write " . $self->file . " : $!";
    print $fh $self->output();
    close $fh;
}

__PACKAGE__->meta->make_immutable;

1;
