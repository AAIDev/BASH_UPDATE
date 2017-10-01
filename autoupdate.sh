#!/bin/bash
#THANKS TO SNOWBALL7275 FOR PARTIAL CODE

#EDIT THESE THINGS:
UNTURNED_SESSIONS=(
"unturnedrp" #The names of your screen sessions
)

ROOT_DIR="/root" #the root directory of unturned (usually the root directory if you installed the server the usual way)
START_SCRIPT="/root/Scripts/script1.sh" #nope
UPDATE_SCRIPT="/root/Scripts/update.sh" #nope
STEAMCMD_DIR="/steamcmd" #where your steamcmd directory is
STEAM_USER=
STEAM_PASS=
UNTURNED_ACF_LOCATION="/root/steamapps/appmanifest_304930.acf" #This is the location of the appmanifest.acf file in the Unturned directory. This is probably in the steamapps folder in the Unturned root directory.

#DONT EDIT BELOW THIS LINE

shutdownserver()
(
	screen -S $1 -X stuff "say \"RESTARTING IN 5 SECONDS; UPDATING\"\n"
	read -t 1 </dev/tty10 3<&- 3<&0 <&3
	screen -S $1 -X stuff "say \"RESTARTING IN 4 SECONDS; UPDATING\"\n"
	read -t 1 </dev/tty10 3<&- 3<&0 <&3
	screen -S $1 -X stuff "say \"RESTARTING IN 3 SECONDS; UPDATING\"\n"
	read -t 1 </dev/tty10 3<&- 3<&0 <&3
	screen -S $1 -X stuff "say \"RESTARTING IN 2 SECONDS; UPDATING\"\n"
	read -t 1 </dev/tty10 3<&- 3<&0 <&3
	screen -S $1 -X stuff "say \"RESTARTING IN 1 SECOND; UPDATING\"\n"
	read -t 1 </dev/tty10 3<&- 3<&0 <&3
)

update()
{
rm -rf /root/bin/appcache #Remove appcache folder so app_info_print returns correct information
	cd $STEAMCMD_DIR
	
	./steamcmd.sh +login $STEAM_USER $STEAM_PASS +app_info_update 1 +app_info_print "304930" +app_info_print "304930" +quit | grep -EA 1000 "^\s+\"branches\"$" | grep -EA 5 "^\s+\"public\"$" | grep -m 1 -EB 10 "^\s+}$" | grep -E "^\s+\"buildid\"\s+" | tr '[:blank:]"' ' ' | tr -s ' ' | sed 's/buildid//g' | sed 's/ //g' > unturned_steam_version.txt
	#Credit to LGSM developer KnightLife for this line of code ^^^ (https://steamdb.info/forum/362/appinfoprint-not-returning-latest-version-of-info/)
	
	cat $UNTURNED_ACF_LOCATION | grep "buildid" | sed 's/"buildid"//g' | sed 's/"//g' | tr -d '\t' > unturned_server_version.txt
	
	a="$(cat unturned_steam_version.txt)"
	b="$(cat unturned_server_version.txt)"
	
	if [ "$a" -gt "$b" ]; then {
		echo "SERVER IS NOT UP TO DATE.  UPDATING!"
		bash $UPDATE_SCRIPT $STEAM_USER $STEAM_PASS
		
		count=0
		
		while [ "x${UNTURNED_SESSIONS[count]}" != "x" ]
		do
			echo "SERVER UPDATING"
			session=(${UNTURNED_SESSIONS[count]})
			shutdownserver $session
			count=$(( $count + 1))
		done
		
		}
	else {
		echo "STEAM VERSION $(cat unturned_steam_version.txt) = SERVER VERSION $(cat unturned_server_version.txt)"
		echo "SERVER IS UP TO DATE"
		
		count=0
		
		while [ "x${UNTURNED_SESSIONS[count]}" != "x" ]
		do
			session=(${UNTURNED_SESSIONS[count]})
			screen -S $session -X stuff "bash $START_SCRIPT $session \n"
			count=$(( $count + 1))
		done
		}
	fi
}

while true
do
	update
	read -t 300 </dev/tty10 3<&- 3<&0 <&3
done
