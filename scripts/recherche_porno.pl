#!/usr/bin/perl
######################################################################
##
##	Recherche des URLs particuli�res de types
##			- pornographiques
##			- de hacking
##			- de piratage
##			- de mp3
##	dans un log de squid
##
##	Usage:
##		cat /var/log/access.log|taille_porno.pl
##
##	Auteur:
##		Fabrice Prigent (fabrice.prigent@univ-tlse1.fr)
##
##	ChangeLog :
##
##		12/01/2001	On ne conserve que les 2 derniers r�pertoires
##		23/05/2000	Modification : d�poussi�rage.
##		12/05/1999	Modification (autres "tails" inutiles)
##		26/04/1999	Cr�ation 
##
##

######################################
##
##	Initialisations
##
$hier=time()-24*3600;

$url_porno="(anal|dick|chick|chix|xxx|hentai|babe|eroti|porn|hard|sex|slut|fetish|smut|teen|\D18\D|\D69\D|lust|thumb|preview|adult|lesb|puss|charme|girl|femme|fille|amateur|love|liberti|coqui|bust|breast|boob|voyeur|escort|pinup|nude|cum|hot|gay)";
$known_false_positive="(yahoo.com/|nfl.com/|photographie.com/|musexpo.com/|caramail.com/|\.hotmail.com/)";


######################################
##
##	Pour chaque ligne en entr�e
##

while (<STDIN>)
	{
	chop;
	($timestamp,$temps,$origine,$etat,$taille,$methode,$url,$qui,$acces,$mime)=split();
	
	##
	##	Si ce sont des urls qui datent d'hier
	##
	if ($timestamp >= $hier)
		{
		$taille_totale+=$taille;
		$nb_total++;
		
		##
		##	Si ce sont des jpegs ou des video dont l'url est potentiellement pornographique
		##
		if (($mime =~ /(jpeg|video)/i) && ($url =~ /$url_porno/i))
			{
			$domaine=$url;
			$domaine =~ s#^(.*)://([^/]*)(.*)$#\2#;

			#	On enl�ve les �l�ments les moins significatifs de l'URL :
			#	---------------------------------------------------------
			#	On enl�ve la derni�re partie c-a-d le nom du fichier s'il y a lieu
			#	On ne conserve que 2 r�pertoires au maximum
			#	On enl�ve la derni�re partie si elle est de type r�pertoire image

			$restreint=$url;
			$restreint =~ s#/[^/]*$##;
			$restreint =~ s#^(http://[^/]*/[^/]*/[^/]*).*$#$1#;
			$restreint =~ s#/(cgi-bin/image|picture|banner|graphic|photo|sample|thumb|thumbnail|img|anime|member|album|join|preview|misc|product)(s)*$##gi;
			
			##
			##	On enl�ve les �ventuels logins
			##
			$restreint =~ s#//[^/]*@#//#;
			
			##
			##	On transforme en ligne de log
			##
			$restreint = $restreint." 127.0.0.1 - GET";
			print "$restreint\n";
			}
		}
	}
