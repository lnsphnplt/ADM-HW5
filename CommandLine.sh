#!/bin/bash

#The average number of heroes in comics.

#print the "comics" column to a separate file
cat data/edges.csv | awk -F',' '{{print $NF "\n"}}' > comics.txt
#count how many times does each comics appear, print the data to a separate file
sort comics.txt | uniq --count >> comics2.txt
sum=0
count=0

#count the number of separate comics, and sum their appearances
cat comics2.txt | sed 1d | while read line;
do
	freq=$(echo $line | awk -F' ' '{{print $1}}')
	count="$(($count+1))"
	sum="$(($sum+$freq))"
	echo $count >> data.txt
	echo $sum >> data.txt
	echo $count
done

sum=$(cat data.txt | tail -1)
count=$(tac data.txt | sed -n 2p)

echo "$(($sum/$count))"

#number of comics per hero-network

#print the "heroes" column to a separate file
cat data/edges.csv | awk -F',' '{{print $1 "\n"}}' > heroes.txt
#count how many times does each hero appears, print the data to a separate file
sort heroes.txt | uniq --count >> heroes2.txt
#sort, then print the hero with the most appearances
sort -r heroes2.txt | sed -n 2p

#Most popular pair of heroes

#count how many times does each pairing appears, then print the data to a separate file
sort data/hero-network.csv | uniq --count > output.txt

declare -A hero_dict

#iterate through the new file containing the unique lines
cat output.txt | while read line;
do
        #declare variables for hero1 and hero2, and the number of times the pairing appears
		freq=$(echo $line | awk -F' ' '{{print $1}}')
		hero1=$(echo $line | awk -F'","' '{{print $1}}')
		hero2=$(echo $line | awk -F'","' '{{print $2}}')
		
		#reverse the order of hero1 and hero2, and find the line where this reverse order appears
		substring=$hero1\",\"$hero2
		found_right_order=$(grep -F "${substring:2}" output.txt)
		substring_reverse=\"$hero2,"${hero1:2}"\"
		found_reverse=$(grep -F "${substring_reverse}" output.txt)
		
		#if there is a line with the reverse order, then sum the two lines
		if [ ! -z "$found_reverse" ]
		then
			echo $substring_reverse
			freq_rev=$(echo $found_reverse | awk -F' ' '{{print $1}}')
			sum="$(($freq + $freq_rev))"
			string=$hero1\"-\"$hero2
			if [ -v "hero_dict[$string]" ]; 
			then
				echo $substring_reverse
			else
				hero_dict[$string]=$sum
				newstring=$sum\;"${string:2}"
				echo $newstring>>result.txt
			fi
		else			
			string=$hero1\"-\"$hero2
			if [ -v "hero_dict[$string]" ]; 
			then
				echo $substring
			else
				hero_dict[$string]=$freq
				newstring=$freq\;"${string:2}"
				echo $newstring>>result.txt
			fi
		fi	
done

#print the three pairs that appear the most
sort --field-separator=';' -n -r result.txt | head -3