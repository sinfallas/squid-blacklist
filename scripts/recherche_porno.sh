#!/bin/sh
#########################################################################################
##
##	recherche_porno.sh
##		Ce script recherche les nouvelles URLs pornographiques "trouvées" par
##		nos utilisateurs et non encore interdites.
##		Il a été prévu pour le redirecteur SquidGuard 
##
##	Auteur :	Fabrice Prigent
##	Date de creation :	2 Mars 1999
##	Date de modification:	3 mars 1999
##				12 Octobre 2000 : on nettoie nouveaux_pornos
##				à la fin. un "maj_page_cache.sh" impromptu
##				rajouterais des lignes non souhaitables
##
##################################
##
##	Il fournit un mail et un fichier des nouvelles URLs.
##	Ce dernier peut etre utilise par le scripts ajout_squidguard.sh
##
##################################
##
##	TODO :
##		permettre d'enlever les URLs "redondantes"
##

PATH="/bin:/usr/bin:/usr/sbin:/usr/local/sbin"
cachemaster="fabrice.prigent@univ-tlse1.fr"
redirecteur="/usr/local/squidGuard/bin/squidGuard"
logfile="/usr/local/squid/logs/access.log"
extraction="/usr/local/scripts/recherche_porno.pl"
fichier_liste_porno="/tmp/nouveaux_pornos"

#########################################################################################
##
##	Recherche des URLS pornos
##
##
cat $logfile|$extraction|sort -u> /tmp/porno.lst

##
##	On regarde les URLs déjà traitées
##
cat /tmp/porno.lst|$redirecteur|grep 'targetclass=adult'|/bin/awk -F '://' '{printf "http://%s\n",$3}'|/bin/awk '{printf "%s 127.0.0.1 - GET\n",$1}' > /tmp/porno_deja_traites

##
##	On regarde les URLs supplémentaires de la liste courante
##	sur les URLs déjà traitées
##
cp /tmp/porno.lst  /tmp/porno.total
cat /tmp/porno_deja_traites >> /tmp/porno.total


##
##	Transformation en minuscule, tri puis on ne prend que celles qui sont uniques
##	on met alors dans le fichier
##
cat /tmp/porno.total|tr A-Z a-z|sort|uniq -u|awk '{print $1}'>$fichier_liste_porno
cat $fichier_liste_porno|/bin/mail -s "Sites pornographiques reperes" $cachemaster

echo >$fichier_liste_porno
