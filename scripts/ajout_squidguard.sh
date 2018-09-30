#!/bin/sh
####################################################################
##
##	This script help cachemaster to add urls in database files
##
##	it can use also some local database to add or remove
##
##	Author
##		fabrice.prigent@univ-tlse1.fr
##
##	ChangeLog
##		25 Jan 2001	: delete content of "nouveaux_pornos" file
##		4 Jul 2000	: change of local_removing method
##		18 Nov 1999	: suppress reload line because we need to reduce
##					database before
##		25 Aug 1999	: verify correctness of local_removing files (non
##					empty lines
##		8  Jul 1999	: bug fixes
##		7  Jul 1999	: bug fixes
##				  relaunch squid process
##		9  Jun 1999	: bug fixes
##		8  Jun 1999	: adding local adding and removing
##		17 May 1999	: some bug fixes
##		4 January 1999	: creation
##
##
PATH="/bin:/usr/bin:/usr/sbin:/usr/local/sbin"


###################################################################
##
##	Location of database's additions
##		database can be retrieved (by ftp)
##				created (as by recherche_porno.sh)
##
##	it's a list of standard urls which will be "standardized"
##	in a squidguard form
##
fichier_liste_porno="/tmp/nouveaux_pornos"
echo >$fichier_liste_porno


###################################################
##
##	If you want to edit database
##
##	editeur="/bin/false"
editeur="/usr/X11R6/bin/nedit"


###################################################
##
##	Database locations
##
domains_porno="/usr/local/squidGuard/db/dest/adult/domains"
urls_porno="/usr/local/squidGuard/db/dest/adult/urls"

#########################################################
##
##	Local Removing is a list of regular expressions
##	which will be applied on a squidguard database
##
##	e.g.
##		^beseen.com$
##
local_removing="/usr/local/squidGuard/removing/adult"

#########################################################
##
##	Srip empty lines in local_removing file
##
egrep '\w\w' $local_removing>$local_removing.temp
mv $local_removing.temp $local_removing

#########################################################
##
##	Some temporary files
##
fichier_tampon="/tmp/ajout_squidguard$$"
urls_tampon="/tmp/ajout_squidguard_urls$$"
domains_tampon="/tmp/ajout_squidguard_domains$$"

######################################################################
##
##	Editing "maybe-porn" urls
##
$editeur $fichier_liste_porno

######################################################################
##
##	Processes to put urls in correct squidGuard Files (domains, url)
##
##	Downcase all
##	Stripping  http://www[0-9]
##	Stripping  http://web[0-9]
##	Stripping http:// (idem)
##	Normalizing line feed/carriage return
##	Sorting
##	Removing duplicate lines
##
cat $fichier_liste_porno|sed -e 's/^[0-9]* //'|tr A-Z a-z|sed -e 's@http://www[1-9]*\.@@'|sed -e 's@http://web[1-9]*\.@@'|sed -e 's@http://@@'|awk '{printf "%s\n",$1}'|sort|uniq> $fichier_tampon

grep "/" $fichier_tampon >> $urls_porno
grep -v "/" $fichier_tampon >> $domains_porno

cat $urls_porno|sort|uniq|grep . >$urls_tampon
cat $domains_porno|sort|uniq|grep . >$domains_tampon

#############################################################################
##
##	Removing local removed urls (the previous method with grep -v -f was
##	to slow and eat too much memory (140 Mo)
##		now we add TWICE local_removing file and discard any domains
##		which appear more than 1 time.
##
#cat $local_removing>>$domains_tampon
#cat $local_removing>>$domains_tampon
sort $domains_tampon|uniq -u>$domains_porno

#grep -v -f $local_removing $urls_tampon>$urls_porno
#grep -v -f $local_removing $domains_tampon>$domains_porno

url_added=`wc -l $fichier_tampon`
echo "URL added" $url_added

######################################################################
##
##	Temporary files destruction
##
rm $fichier_tampon
rm $urls_tampon
rm $domains_tampon
