#!/usr/bin/perl -w
use strict;
use warnings;
use Web::Scraper;
use URI;

if(!$ARGV[0] && !$ARGV[0]){
    die("Usage\:weather.pl <year> <month>\n");
}

my $month = $ARGV[1];
my $this_year = $ARGV[0];
my $last_year = $this_year-1;
my $url = '
http://chart.apis.google.com/chart?
chs=600x300
&chd=t:';
my $scraper = scraper {
    process '/html/body/div[2]/div/div/div[2]/div/div/div/div/table[2]/tr/td/span[1]','list[]' => 'TEXT';
};

$url .= &gen_url($this_year,$month);
$url .= '|';

$url .= &gen_url($last_year,$month);
$url .= "
&cht=lc
&chco=ff0000,0000ff
&chtt=Tokyo+Temperature+Max|Month:$month
&chdl=$this_year|$last_year
&chts=003498,12
&chxt=x,y
&chxl=0:|1|10|20|31|1:|0|10|20|30|40
&chxr=0,1,31|1,0,40
";

print $url."\n";
exit;

sub gen_url{
    my $url;
    my $flag = 0;
    my $plot;
    my $j =0;
    my ($year,$month) = @_;
    my $uri = URI->new("http://weather.goo.ne.jp/past/$year/$month/662/index.html");
    my $result = $scraper->scrape($uri);
    for(my $i=0;$i<35;$i++){
	if($flag == 1 && $result->{list}[$i] =~ /\-/){
	    $plot = -1;
	    $url .= $plot.",";
	    $j++;
	}
	elsif($result->{list}[$i] !~ /\-/){
	    $plot = $result->{list}[$i];
	    $plot *= 2.5;
	    $url .= $plot.",";
	    $flag = 1;
	    $j++;
	}

	if($j >= 31){
	    last;
	}
	
    }
    chop($url);
    return $url;
}
