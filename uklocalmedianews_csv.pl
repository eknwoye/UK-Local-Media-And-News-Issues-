#!/usr/bin/env perl
#
#
# PROJECT CHALLENGE & OBJECTIVE: Local News plays an important role in shaping residents' perceptions. Can we scrape a database of local news from local websites and then create a database to search for key terms?
#
# REVISED SOLUTION (Perl):
#
# Here's a Perl 5.x script that does the following:
# Scrapes a list of UK regional news sites and associated Facebook pages.
# Uses LWP::UserAgent, Mojo::DOM, and Text::CSV for scraping and CSV generation.
# Extracts content matching political topics using regex key terms.

# Saves data to a searchable 'uklocalmedianews.csv' file.

# Includes:

# CLI Search Tool.
# A simple Mojolicious Web Viewer.
#
#
#
# ✅ Usage Instructions

# 1. Run the script for scraping + web app:
# perl uklocalmedianews_csv.pl
# Access at: http://localhost:3010

# 2. Run in CLI search mode:
# perl uklocalmedianews_csv.pl --cli
# You can search using any keyword or topic.


# ---

# ✅ Dependencies (Install with CPAN/cpanm)

# cpan install LWP::UserAgent Mojo::DOM Text::CSV Mojolicious


# ---

# ✅ Output

# uklocalmedianews.csv: Contains rows like:
# Source URL | Facebook Page | Topic | Snippet Matched

#
# CODE REVISION & AUTHOR: Ejimofor Nwoye, Campaign Lab, Newspeak House, London, England @ 11th August, 2025
#
#
#
#
use strict;
use warnings;
use utf8;
use LWP::UserAgent;
use Mojo::DOM;
use Text::CSV;
use Mojo::Base -strict;
use Mojolicious::Lite;

# -----------------------------
# Configuration
# -----------------------------
my @sources = (
    { site => 'https://www.cambridge-news.co.uk', fb => 'https://www.facebook.com/CambridgeshireLive' },
    { site => 'https://www.cambridgeindependent.co.uk', fb => 'https://www.facebook.com/CambridgeIndependent' },
    { site => 'https://www.peterboroughtoday.co.uk', fb => 'https://www.facebook.com/PeterboroughTelegraph' },
    { site => 'https://www.peterboroughmatters.co.uk', fb => 'https://www.facebook.com/PeterboroughMatters' },
    { site => 'https://www.huntspost.co.uk', fb => 'https://www.facebook.com/HuntsPost' },
    { site => 'https://www.cambstimes.co.uk', fb => 'https://www.facebook.com/CambsTimes' },
    { site => 'https://www.wisbechstandard.co.uk', fb => 'https://www.facebook.com/WisbechStandard' },
    { site => 'https://www.fenlandcitizen.co.uk', fb => 'https://www.facebook.com/fencitizen' },
    { site => 'https://www.cambsnews.co.uk', fb => '' },
    { site => 'https://www.derbytelegraph.co.uk', fb => 'https://www.facebook.com/derbyshirelive' },
    { site => 'https://www.derbyshiretimes.co.uk', fb => 'https://www.facebook.com/DerbyshireTimes' },
    { site => 'https://www.buxtonadvertiser.co.uk', fb => 'https://www.facebook.com/BuxtonAdvertiser' },
    { site => 'https://www.matlockmercury.co.uk', fb => 'https://www.facebook.com/MatlockMercury' },
    { site => 'https://www.devonlive.com', fb => 'https://www.facebook.com/DevonLive' },
    { site => 'https://www.plymouthherald.co.uk', fb => 'https://www.facebook.com/PlymouthLive' },
    { site => 'https://www.northdevongazette.co.uk', fb => 'https://www.facebook.com/NorthDevonGazette' },
    { site => 'https://www.middevonadvertiser.co.uk', fb => 'https://www.facebook.com/MidDevonAdvertiser' },
    { site => 'https://www.exeterobserver.org', fb => 'https://www.facebook.com/ExeterObserver' },
    { site => 'https://www.gloucestershirelive.co.uk', fb => 'https://www.facebook.com/GlosLive' },
    { site => 'https://www.stroudnewsandjournal.co.uk', fb => 'https://www.facebook.com/StroudNewsandJournal' },
    { site => 'https://www.theforester.co.uk', fb => 'https://www.facebook.com/TheForester' },
    { site => 'https://www.watfordobserver.co.uk', fb => 'https://www.facebook.com/WatfordObserver' },
    { site => 'https://www.hemeltoday.co.uk', fb => 'https://www.facebook.com/HemelGazette' },
    { site => 'https://www.thecomet.net', fb => 'https://www.facebook.com/StevenageComet' },
    { site => 'https://www.hertsad.co.uk', fb => 'https://www.facebook.com/hertsad' },
    { site => 'https://www.whtimes.co.uk', fb => 'https://www.facebook.com/whtimes' },
    { site => 'https://www.bishopsstortfordindependent.co.uk', fb => 'https://www.facebook.com/StortfordIndie' },
    { site => 'https://www.royston-crow.co.uk', fb => 'https://www.facebook.com/RoystonCrow' },
    { site => 'https://www.kentonline.co.uk', fb => 'https://www.facebook.com/KentOnline' },
    { site => 'https://www.kentlive.news', fb => 'https://www.facebook.com/KentLiveNews' },
    { site => 'https://theisleofthanetnews.com', fb => 'https://www.facebook.com/theisleofthanetnews' },
    { site => 'https://www.lancs.live', fb => 'https://www.facebook.com/LancsLive' },
    { site => 'https://www.lancashiretelegraph.co.uk', fb => 'https://www.facebook.com/lancashiretelegraph' },
    { site => 'https://www.lep.co.uk', fb => 'https://www.facebook.com/LancashireEveningPost' },
    { site => 'https://www.blackpoolgazette.co.uk', fb => 'https://www.facebook.com/BlackpoolGazette' },
    { site => 'https://www.burnleyexpress.net', fb => 'https://www.facebook.com/BurnleyExpress' },
    { site => 'https://www.lancasterguardian.co.uk', fb => 'https://www.facebook.com/LancasterGuardian' },
    { site => 'https://www.leicestermercury.co.uk', fb => 'https://www.facebook.com/LeicestershireLive' },
    { site => 'https://www.harboroughmail.co.uk', fb => 'https://www.facebook.com/harboroughmail' },
    { site => 'https://www.loughboroughecho.net', fb => 'https://www.facebook.com/LoughboroughEcho' },
    { site => 'https://www.meltontimes.co.uk', fb => 'https://www.facebook.com/GrimsbyLive' },
    { site => 'https://www.scunthorpetelegraph.co.uk', fb => 'https://www.facebook.com/ScunthorpeLive' },
    { site => 'https://www.spaldingtoday.co.uk', fb => 'https://www.facebook.com/SpaldingToday' },
    { site => 'https://www.granthamjournal.co.uk', fb => 'https://www.facebook.com/GranthamJournal' },
    { site => 'https://www.thelincolnite.co.uk', fb => 'https://www.facebook.com/thelincolnite' },
    { site => 'https://www.nottinghampost.com', fb => 'https://www.facebook.com/NottinghamshireLive' },
    { site => 'https://www.chad.co.uk', fb => 'https://www.facebook.com/MeltonTimes' },
    { site => 'https://www.lincolnshirelive.co.uk', fb => 'https://www.facebook.com/LincolnshireLive' },
    { site => 'https://www.grimsbytelegraph.co.uk', fb => 'https://www.facebook.com/MansfieldChad' },
    { site => 'https://www.newarkadvertiser.co.uk', fb => 'https://www.facebook.com/NewarkAdvertiser' },
    { site => 'https://westbridgfordwire.com', fb => 'https://www.facebook.com/WestBridgfordWire' },
    { site => 'https://www.worksopguardian.co.uk', fb => 'https://www.facebook.com/WorksopGuardian' },
    { site => 'https://www.oxfordmail.co.uk', fb => 'https://www.facebook.com/OxfordMail' },
    { site => 'https://www.banburyguardian.co.uk', fb => 'https://www.facebook.com/BanburyGuardian' },
    { site => 'https://www.witneygazette.co.uk', fb => 'https://www.facebook.com/WitneyGazette' },
    { site => 'https://www.henleystandard.co.uk', fb => 'https://www.facebook.com/henleystandard' },
    { site => 'https://www.stokesentinel.co.uk', fb => 'https://www.facebook.com/StokeonTrentLive' },
    { site => 'https://www.expressandstar.com', fb => 'https://www.facebook.com/ExpressandStar' },
    { site => 'https://www.burtonmail.co.uk', fb => 'https://www.facebook.com/BurtonMail' },
    { site => 'https://www.leamingtoncourier.co.uk', fb => 'https://www.facebook.com/LeamingtonCourier' },
    { site => 'https://www.stratford-herald.com', fb => 'https://www.facebook.com/stratford.herald' },
    { site => 'https://www.worcesternews.co.uk', fb => 'https://www.facebook.com/WorcesterNews' },
    { site => 'https://www.malverngazette.co.uk', fb => 'https://www.facebook.com/MalvernGazette' },
    { site => 'https://www.kidderminstershuttle.co.uk', fb => 'https://www.kidderminstershuttle.co.uk' },
    { site => 'https://www.bucksfreepress.co.uk', fb => 'https://www.facebook.com/bucksfreepress' },
    { site => 'https://www.bucksherald.co.uk', fb => 'https://www.facebook.com/BucksHerald' },
    { site => 'https://www.cornwalllive.com', fb => 'https://www.facebook.com/CornwallLive' },
    { site => 'https://www.falmouthpacket.co.uk', fb => 'https://www.facebook.com/FalmouthPacket' },
    { site => 'https://cornwallreports.co.uk', fb => 'https://www.facebook.com/cornwallreports' },
    { site => 'https://www.thenorthernecho.co.uk', fb => 'https://www.facebook.com/TheNorthernEcho' },
    { site => 'https://www.northantstelegraph.co.uk', fb => 'https://www.facebook.com/northantstelegraph' },
    { site => 'https://www.northumberlandgazette.co.uk', fb => 'https://www.facebook.com/NorthumberlandGazette' },
    { site => 'https://www.shropshirestar.com', fb => 'https://www.facebook.com/ShropshireStar' },
    { site => 'https://www.shropshirelive.com', fb => 'https://www.facebook.com/shropshirelive' },
    { sire => 'https://www.northamptonchron.co.uk', fb => 'https://www.facebook.com/northamptonchron' },
    { site => 'https://www.swindonadvertiser.co.uk', fb => 'https://www.facebook.com/SwindonAdvertiser' },
    { site => 'https://www.salisburyjournal.co.uk', fb => 'https://www.facebook.com/salisburyjournal' },
    { site => 'https://www.hulldailymail.co.uk', fb => 'https://www.facebook.com/HullLive' },
    { site => 'https://www.bridlingtonfreepress.co.uk', fb => 'https://www.facebook.com/bridfreepress' },
    { site => 'https://www.bristolpost.co.uk', fb => 'https://www.facebook.com/BristolLive' },
    { site => 'https://www.bathchronicle.co.uk', fb => 'https://www.facebook.com/BathChron' },
    { site => 'https://www.bristol247.com', fb => 'https://www.facebook.com/bristol247' },
    { site => 'https://www.bathecho.org', fb => 'https://www.facebook.com/BathEcho' },
    { site => 'https://www.chroniclelive.co.uk', fb => 'https://www.facebook.com/NewcastleChronicle' },
    { site => 'https://www.newsguardian.co.uk', fb => 'https://www.facebook.com/NewsGuardian' },
    { site => 'https://www.doncasterfreepress.co.uk', fb => 'https://www.facebook.com/DoncasterFreePress' },

    { site => 'https://www.localnewsfinder.uk/', fb => '' },
    # Add more from your list...
);

my @key_terms = (
    { topic => 'Asylum and Immigration', regex => qr/\b(asylum|immigration|migrant|border)\b/i },
    { topic => 'Crime and Policing', regex => qr/\b(police|crime|law and order|offender)\b/i },
    { topic => 'The Economy.*', regex => qr/\b(economy|cost of living|inflation|tax|council tax)\b/i },
    { topic => 'Regional Devolution.*', regex => qr/\b(devolution|independence|regional power)\b/i },
    { topic => 'Social Welfare.*', regex => qr/\b(NHS|healthcare|public health|benefits|universal credit)\b/i },
    { topic => 'Public Transportation', regex => qr/\b(train|bus|transport|commute|infrastructure)\b/i },
    { topic => 'Candidate Personality profile', regex => qr/\b(candidate|MP|personality|manifesto|background)\b/i },
);

my $output_file = "uklocalmedianews.csv";
my $ua = LWP::UserAgent->new(timeout => 10);

# -----------------------------
# Web Scraping
# -----------------------------
open my $fh, ">:encoding(utf8)", $output_file or die $!;
my $csv = Text::CSV->new({ binary => 1, eol => $/ });
$csv->print($fh, ['Source', 'Facebook', 'Topic', 'Matched Content']);

foreach my $entry (@sources) {
    my $response = $ua->get($entry->{site});
    next unless $response->is_success;

    my $dom = Mojo::DOM->new($response->decoded_content);
    my $text = $dom->all_text;

    foreach my $term (@key_terms) {
        if ($text =~ $term->{regex}) {
            $csv->print($fh, [ $entry->{site}, $entry->{fb}, $term->{topic}, substr($&, 0, 200) ]);
        }
    }
}

close $fh;

# -----------------------------
# CLI Search
# -----------------------------
if (@ARGV and $ARGV[0] eq '--cli') {
    print "Enter keyword to search: ";
    chomp(my $search = <STDIN>);
    open my $in, "<:encoding(utf8)", $output_file or die $!;
    my $csv_in = Text::CSV->new({ binary => 1 });
    while (my $row = $csv_in->getline($in)) {
        if (join(" ", @$row) =~ /\Q$search\E/i) {
            print join(" | ", @$row), "\n";
        }
    }
    close $in;
    exit;
}

# -----------------------------
# Mojolicious Web App
# -----------------------------
get '/' => sub {
    my $c = shift;
    open my $in, "<:encoding(utf8)", $output_file or die $!;
    my $csv_in = Text::CSV->new({ binary => 1 });
    my @rows;
    while (my $row = $csv_in->getline($in)) {
        push @rows, $row;
    }
    close $in;
    $c->stash(rows => \@rows);
    $c->render(template => 'index');
};

app->start('daemon', '-l', 'http://*:3010');

__DATA__

@@ index.html.ep
% layout 'default';
% title 'UK Local Media News Viewer';
<h1>UK Local Media News</h1>
<table border="1" style="width:100%">
  <tr><th>Source</th><th>Facebook</th><th>Topic</th><th>Matched Text</th></tr>
  % for my $row (@$rows) {
    <tr>
      % for my $col (@$row) {
        <td><%= $col %></td>
      % }
    </tr>
  % }
</table>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

