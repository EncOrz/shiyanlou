BEGIN{ printf "%5s %-s\n","COUNT","USER"} 
	{if(NR>1) user[$1]++}     
END {for( u in user) printf "%5s %-s\n",user[u],u | "sort -r -n -k 1"}

