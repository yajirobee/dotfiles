#! /usr/bin/env perl

use utf8;
use File::Copy;
use File::Spec;
use File::Basename;

$base = dirname(File::Spec->rel2abs($0));
$home = $ENV{"HOME"};

# setup scripts
@files = ("bashrc", "zshrc", "vimrc", "screenrc", "pythonstartup.py", "sqliterc");
for (@files) {
    $conffile = "$home/.$_";
    if (-f $conffile) {
        print "$conffile already exists\n";
    } else {
        symlink "$base/$_", $conffile;
    }
}

# setup my bin directory
$bin_dir = "$home/bin";
unless (-d $bin_dir) {
    mkdir $bin_dir, 0777;
}
@files = ("rm");
for (@files) {
    $binfile = "$bin_dir/$_";
    if (-f $binfile) {
        print "$binfile already exists\n";
    } else {
        symlink "$base/$_", $binfile;
        chmod 0755, $binfile or die "Cannot change permission $binfile: $!";
    }
}

# setup my common directory
$comm_dir = "$home/common";
unless (-d $comm_dir) {
    mkdir $comm_dir, 0777;
}
@files = ("plotutil.py", "monotonic.py");
for (@files) {
    $commfile = "$comm_dir/$_";
    if (-f $commfile) {
        print "$commfile already exists\n";
    } else {
        symlink "$base/common/$_", $commfile;
    }
}

# setup emacs config
$emacs_dir = "$home/.emacs.d";
if (-d "$emacs_dir/"){
    print "$emacs_dir/ already exists\n";
}
else{
    symlink "$base/emacs.d/", "$emacs_dir";
}
