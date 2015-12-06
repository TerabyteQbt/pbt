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
    my $copy_sub = delete $args{'copy'} || die;
    !%args || die;

    if(!$force)
    {
        if(@$ins == 0)
        {
            return;
        }

        if(@$ins == 1)
        {
            $copy_sub->($ins->[0], $out);
            return;
        }
    }

    my %ent_ins;
    for my $in (@$ins)
    {
        for my $ent (@{slurp_dir($in)})
        {
            my $in2 = "$in/$ent";
            push @{$ent_ins{$ent} ||= []}, $in2;
        }
    }

    mkdir $out;
    for my $ent (sort(keys(%ent_ins)))
    {
        unify(
            'ins' => $ent_ins{$ent},
            'out' => "$out/$ent",
            'copy' => $copy_sub,
        );
    }
}

1;
