#!/usr/bin/perl
######################################################################
##
##	Calcul de la proportion APPROXIMATIVE d'URLs nécessitant une
##	attention particulière :
##			- pornographiques
##			- de hacking
##			- de piratage
##			- de mp3
##	dans un log de squid
##
##	Usage:
##		cat /var/log/access.log|taille_porno.pl
##
##	ChangeLog :
##
##		08/03/1999	Généralisation de la recherche
##				Correction des URLs
##				Affichage des nombres de connexions
##
##		04/03/1999	Clarification, ajout de commentaires
##
##		15/02/1999	Creation
##			
##
##
##

######################################
##
##	Initialisations
##
$taille_totale=0;

$url_type{"porno"}="(xxx|erotic|lust|porno|hard|sex|teen|adult|lesb|pussy|gay)";
$url_type{"pirate"}="(warez|appz|gamez|filez)";
$url_type{"mp3"}="(mp3|mpeg3)";
$url_type{"hack"}="(hack|phreak)";

######################################
##
##	Affectation des catégories
##
@types_url=keys %url_type;

foreach (@types_url)
	{
	$taille_type{$_}=0;
	}

while (<STDIN>)
	{
	chop;
	($timestamp,$temps,$origine,$etat,$taille,$methode,$url,$qui,$acces,$mime)=split();
	$taille_totale+=$taille;
	$nb_total++;
#	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($timestamp);
#	$mon++;

##
##	Pour chaque catégorie
##
	foreach (@types_url)
		{
		if ($url =~ /$url_type{$_}/i)
			{
			$taille_type{$_}+=$taille;
			$nb_type{$_}++;
			}
		}
	}

##
##	On met la taille en Ko
##
$taille_totale/=1024;

foreach (@types_url)
	{
	$taille_type{$_}/=1024;
	}

##
##	Calcul des pourcentages et affichage des résultats
##
printf ("Taille totale : %d Ko\t\tNb total : %d \n\n",$taille_totale,$nb_total);
foreach (@types_url)
	{
	$pourcent_type{$_}=$taille_type{$_}*100/$taille_totale;
	$pourcent_nb_type{$_}=$nb_type{$_}*100/$nb_total;
	printf ("$_\t: %d Ko %d Urls\tPOURCENTAGE : %.1f%% en taille et %.1f%% en nombre\n",$taille_type{$_},$nb_type{$_},$pourcent_type{$_},$pourcent_nb_type{$_});
	}
