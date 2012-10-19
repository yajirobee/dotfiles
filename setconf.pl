#! /usr/bin/env perl

use utf8;
use File::Copy;
use File::Spec;
use File::Basename;

$base = dirname(File::Spec->rel2abs($0));
$home = $ENV{"HOME"};

# setup scripts
@files = ("bashrc", "zshrc", "vimrc", "screenrc", "pythonstartup.py");
for (@files){
    $conffile = "$home/.$_";
    if ( -f $conffile){
	print "$conffile already exists\n";
    }
    else{
	symlink "$base/$_", $conffile;
    }
}

# setup my bin directory
$bin_dir = "$home/bin";
unless (-d $bin_dir){
    mkdir $bin_dir, 0777;
}
copy "$base/rm", "$bin_dir/rm"
    or die "Can't copy \"$base/rm\" to \"$bin_dir/rm\": $!";
chmod 0755, "$bin_dir/rm"
    or die "Cannot change permission $bin_dir/rm: $!";

# setup my common directory
$comm_dir = "$home/comm";
if ( -d "$comm_dir/"){
    print "$comm_dir/ already exists\n";
}
else{
    symlink "$base/comm/", "$comm_dir";
}

# setup emacs config
$emacs_dir = "$home/.emacs.d";
if ( -d "$emacs_dir/"){
    print "$emacs_dir/ already exists\n";
}
else{
    symlink "$base/emacs.d/", "$emacs_dir";
}
