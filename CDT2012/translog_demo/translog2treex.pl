#!/usr/bin/env perl

use strict;
use warnings;

use XML::Twig;
use Treex::Core;



foreach my $alignment_file (glob "sample/*atag.utf8") {

    my $src_file = $alignment_file;
    $src_file =~ s/\.atag/.src/;

    my $tgt_file = $alignment_file;
    $tgt_file =~ s/\.atag/.tgt/;

    my ($atag_twig,$src_twig,$tgt_twig) =
        map { my $twig=XML::Twig->new; $twig->parsefile($_); $twig }
            ($alignment_file,$src_file,$tgt_file);

    my $doc = Treex::Core::Document->new;

    my $bundle = $doc->create_bundle;

    my ($en_zone,$da_zone) = map {$bundle->create_zone($_)} (qw(en da));
    my ($en_root,$da_root) = map {$_->create_atree;} ($en_zone,$da_zone);

    add_nodes('en',$en_root,$src_twig);
    add_nodes('da',$da_root,$tgt_twig);

    foreach my $align ($atag_twig->descendants('align')) {
        foreach my $old_id_in (map {s/b//;$_} grep {/^b/} split ' ',$align->{att}->{in}) {
            foreach my $old_id_out (map {s/a//;$_} grep {/^a/} split ' ',$align->{att}->{out}) {
                my $node_in = $doc->get_node_by_id(old_id_to_new_id($old_id_in,'da'));
                my $node_out = $doc->get_node_by_id(old_id_to_new_id($old_id_out,'en'));
                $node_in->add_aligned_node($node_out);
            }
        }
    }

    my $treex_file = $alignment_file;
    $treex_file =~ s/\.atag\.utf8/.treex.gz/;
    print "Saving to $treex_file\n";
    $doc->save($treex_file);

}


sub add_nodes {
    my ($language,$root,$twig) = @_;

    my $ord = 0;
    foreach my $w ($twig->descendants('W')) {
        $ord++;
        my $node = $root->create_child({ord => $ord,
                                        form => $w->text,
                                    }
                                   );
        $node->set_id(old_id_to_new_id($w->{'att'}->{id},$language));
    }
}

sub old_id_to_new_id {
    my ($old_id,$language) = @_;
    return "$language-$old_id";
}
