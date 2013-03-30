#!/bin/bash

# Get list of urls by user and write those links to a temp file.
dialog --title "Download Manager" \
--inputbox "Enter url(s): \n(Separate urls by comma)" 10 50 2> /tmp/inputbox.tmp.$$
urls=$(cat /tmp/inputbox.tmp.$$)
rm -f /tmp/inputbox.tmp.$$

# Extensions of files that we want to download
declare -a extensions=('pdf' 'ods' 'ppt' 'doc')

# Number of urls is hold in total_urls variable.
total_urls=$(echo $urls | awk -F, "{print NF}")

# This keeps which url we are downloading files from.
current_url=0

# This loop will itarate over all urls entered by users.
for i in $(seq 1 $total_urls)
do
    # Url which we will download files from is hold in $url variable.
    url=$(echo $urls | awk -v n=$i -F, '{print $n}')
    
    # Convert all paths form relative to absolute and download page's source code. 
    wget -k -O /tmp/source.tmp.$$ $url -o /dev/null

    # This loop finds full path of files that we will download and output them to the links.tmp file.
    for ext in "${extensions[@]}"
    do
        cat /tmp/source.tmp.$$ | grep -o "href=[^>]*$ext\".*>" | cut -d'"' -f2 >> /tmp/links.tmp.$$
    done

    # Number of files that we will download from particular web site is kept in this variable. 
    total_number_of_files=$(cat /tmp/links.tmp.$$ | wc -l)

    # This variable is used to define how much units will download bar will get longer in each step. 
    increase_rate=$(echo "100/$total_number_of_files" | bc)

    # This variable is used to determine the last length of download bar after all files downloaded.
    upper_limit=$(echo "($total_number_of_files) * $increase_rate" | bc)

    # Since we are about to download from a site, we are updating this varialble.
    current_url=$(( $current_url + 1 ))

    # Percent holds the current length of download bar.
    percent=0
    while (( percent < $upper_limit ))
    do
        # Download bar is getting longer whenever a file is downloaded.
        percent=$(( percent + $increase_rate ))

        # This keeps which file is going to be downloaded next.
        current_file=$(( $current_file + 1 ))
        	
        # Absolute url of the files that is going to downloaded is kept file_url variable.
        file_url=$(awk -v n=$current_file '{ if(NR == n) print $0 }' /tmp/links.tmp.$$)
			
        echo "XXX"
        echo "Downloading from url $current_url of $total_urls... $file_url"
        echo "XXX"
		   
        # Download the file.
        wget -P Downloads/ $file_url -o /dev/null
			
        # This part handles the part which deals with keeping history of downloaded file.
        if (( $? == 0 ))
        then
            echo -e $(date +"%T") "\t" $(date +"%m %b, %Y") "\t" $file_url >> History
        else
            echo -e $(date +"%T") "\t" $(date +"%m %b, %Y") "\t" $file_url "\t" "Failed to download" >> History
        fi
						
        # Movement of download bar is determined here.
        if (( percent == $upper_limit )) && (( $i != $total_urls ))
        then
            percent=0; echo "100"; break
        elif (( percent == $upper_limit )) && (( $i == $total_urls ))
        then
            percent=100;
        fi
            
        # Print the length of updated value of download bar, Dialog will draw the bar according to this value.
        echo $percent
    done | 
    dialog --title "Download Manager" --gauge "If you're seeing this, something went wrong!" 20 70 0
	
    # Delete the files that we created earlier.
    rm -f /tmp/links.tmp.$$
    rm -f /tmp/source.tmp.$$
done
