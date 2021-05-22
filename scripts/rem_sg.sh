#!/bin/sh 
######################################################################
##
##      This script remove a domain or an url in squidGuard database
##
##      Author:
##              Fabrice.Prigent@univ-tlse1.fr
##
##      ChangeLog:
##              10/05/2000      :       Creation
##
##

#
#	Configuration zone
#
REP_SQUIDGUARD="/usr/local/squidGuard"
SQUIDGUARD="$REP_SQUIDGUARD/bin/squidGuard"
default_database="adult"
list_of_database="adult redirector publicite warez"

#################################################################################
#
#	Ask for parameters
#
if [ $# -eq 0 ]
then
        echo "Enter url or domains"
        read response
	echo
	echo "Enter database ($list_of_database)"
	read default_database
else
        response=$1
fi

if [ $# -eq 2 ]
then
	database=$2
else
	database=$default_database
fi


#
#	stripping url
#
url=`echo $response|tr A-Z a-z|sed -e 's@http://www[1-9]*\.@@'|sed -e 's@http://web[1-9]*\.@@'|sed -e 's@http://@@'|awk '{printf "%s\n",$1}'`
true_url=`echo $url|grep "/"`

if [ "X$true_url" = "X" ]
then
	type="domains"
else
	type="urls"
fi

##
##	Action 
##
cd $REP_SQUIDGUARD/db/dest/$database
true_url=`grep "^$url$" $type`

if [ "X$true_url" = "X" ]
then
	echo "This string doesn't exist in $type of $database"
	exit
fi

##
##	Ask confirmation
##
echo "Removing of $url in $type of $database [Y/n]?"
read response
if [ "x$response" = "xN" ] || [ "x$response" = "xn" ]
then
        echo "OK. I don't remove it."
        exit
fi

echo -$url>$type.diff
grep -v "^$url$" $type>$type.2
mv $type.2 $type


$SQUIDGUARD -u
rm $type.diff

echo "$url removed"
