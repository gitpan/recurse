#! /usr/local/bin/perl


#################################################################################
#										#
#  										#
#   Recurse v.0.1							       	#
#   Copyright (C) 2004 - Steven Schubiger <steven@accognoscere.org>		#
#   Last changes: 14th November 2004						#
#										#
#   This program is free software; you can redistribute it and/or modify	#
#   it under the terms of the GNU General Public License as published by	#
#   the Free Software Foundation; either version 2 of the License, or		#
#   (at your option) any later version.						#
#										#
#   This program is distributed in the hope that it will be useful,		#
#   but WITHOUT ANY WARRANTY; without even the implied warranty of		#
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the		#
#   GNU General Public License for more details.				#
#										#
#   You should have received a copy of the GNU General Public License		#
#   along with this program; if not, write to the Free Software			#
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA	#
#										#
#										#
#################################################################################




use strict;

use File::Spec;
use Getopt::Long;

our (%Opts,
     $Dir,
     @Dirs,
     @Files,
);

get_args();
traverse(\@Dirs, \@Files);
output();

sub get_args {  
    $Dir = shift @ARGV;
    
    $Getopt::Long::autoabbrev = 0;
    $Getopt::Long::ignorecase = 0; 
    GetOptions (\%Opts, 'type=s');
    
    $Opts{'type'} ||= '';
    unless (-d $Dir && $Opts{'type'} =~ /^d|f$/) {
        die <<"";
usage: $0 <dir> [-type f|d]

    }
}

sub traverse {
    my ($dirs_ref, $files_ref) = @_;

    my ($count, @dirs, $eval, @eval, @files,
        $limit, @stack);
    $count = 0;

    dir_read($Dir, \@eval);
    @eval =
      map { File::Spec->catfile($Dir, $_) }
      @eval;

    RECURSE:
    while (@eval) {
        if (-d $eval[0]) {
            $eval = shift @eval;
            push @dirs, $eval;
        }
        elsif (-f $eval[0]) {
            my $file = shift @eval;
            push @files, $file;
            next;
        }
        else { die "Traversing failed: unknown type\n" }

        my @items;
        dir_read($eval, \@items);

        foreach (@items) {
            my $item = File::Spec->catfile($eval, $_);
            if (-d $item) { push @stack, $item }
            else { push @files, $item }
        }

        unless (@eval) {
            #if ($limit && ++$count == $limit) { last RECURSE }
            @eval = @stack;
            undef @stack;
        }
    }

    @$dirs_ref  = sort @dirs;
    @$files_ref = sort @files;
}

sub output {
    local $, = "\n";
    
    if ($Opts{'type'} =~ /d/) { print @Dirs }
    if ($Opts{'type'} =~ /f/) { print @Files }
}   

#
# dir_read (\$dir, \@files)
#
# Reads files of a directory.
#

sub dir_read {
    my ($dir, $files_ref) = @_;

    opendir D, $dir
      or die qq~Could not open dir $dir for read-access: $!\n~;
    @$files_ref = readdir D; 
    splice @$files_ref, 0, 2;
    closedir D or die qq~Could not close dir $dir: $!\n~;
}
