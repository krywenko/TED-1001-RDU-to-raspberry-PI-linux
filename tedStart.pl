#!/usr/bin/perl -W -s

 for( ; ; )
 {
printf "killing ted process.\n";
system("pkill -f ted1a.pl");
printf "Starting Ted data collection.\n";
sleep(1);
system("ted1a.pl")
}