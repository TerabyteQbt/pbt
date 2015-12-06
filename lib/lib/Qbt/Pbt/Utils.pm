package Qbt::Pbt::Utils;

use strict;
use warnings;

sub slurp_dir
{
    my $dir = shift;
    opendir(my $fh, $dir) || die "Could not openddir $dir: $!";
    my @ret;
    while(my $ent = readdir($fh))
    {
        next if($ent eq '.' || $ent eq '..');
        push @ret, $ent;
    }
    closedir($fh) || die "Could not openddir $dir: $!";
    @ret = sort @ret;
    return [@ret];
}

sub unify
{
    my %args = @_;
    my $ins = delete $args{'ins'} || die;
    my $out = delete $args{'out'} || die;
    my $force = delete $args{'force'} || 0;
    !%args || die;

    if(!$force)
    {
        if(@$ins == 0)
        {
            return;
        }

        if(@$ins == 1)
        {
            my ($dir, $copy_sub) = @{$ins->[0]};
            $copy_sub->($dir, $out);
            return;
        }
    }

    my %ent_ins;
    for my $in (@$ins)
    {
        my ($dir, $copy_sub) = @$in;
        for my $ent (@{slurp_dir($dir)})
        {
            my $dir2 = "$dir/$ent";
            push @{$ent_ins{$ent} ||= []}, [$dir2, $copy_sub];
        }
    }

    mkdir $out;
    for my $ent (sort(keys(%ent_ins)))
    {
        unify(
            'ins' => $ent_ins{$ent},
            'out' => "$out/$ent",
        );
    }
}

1;
