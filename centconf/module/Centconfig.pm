package Centconfig;

# admin
my $fileconf="/home/centconf/centconf.conf";
my %CONF_VAR;

sub config_parse
{
	open(CONF,$fileconf);
	@file_string = <CONF>;
	close(CONF);
      
	foreach $pair (@file_string)
	{
	    if($pair =~ /=/)
            {
	 	#print "OK_VAR => $pair";	
		chomp($pair);
		my ($name,$value) = split(/=/,$pair);
		$value=~s/\"//g; $value=~s/\'//g;
		$CONF_VAR{$name} = $value; 
	    }
        }
	# return hash reference
	return(\%CONF_VAR);
}
# calling function
#my $hash_ref=config_parse;
#print ${$hash_ref}{arun_bagul};

#done
1;

