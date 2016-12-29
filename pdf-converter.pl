#!/usr/bin/perl
use Email::MIME;
use MIME::QuotedPrint;
use MIME::Base64;
 
my $to = $ARGV[0];
 
sub partR{
	my($subParts) = @_;
	$subParts->walk_parts( sub {
		my($part) = @_;
		if( $part->content_type =~ m[rfc822]i ){
			# Radau outlook'o laisko dali
			# Nagrinesiu ja kaip tevine dali su vaikais
			my($email) = Email::MIME->new($part->body_raw);
			partR($email);
			$part->{body_raw} = $email->as_string;
			$part->{body} = \{$part->{body_raw}};
		}
		# Else
		# Radau nedominincia dali
 
		if($part->subparts){
			# Radau tevine dali
			# Nagrinesiu vaikus
			partR($part->subparts);
		}
		# Else
		# Radau vaiko dali
 
		if( $part->content_type =~ m[application/pdf]i ){
			my %poros = $part->header_str_pairs;
			# Nuskaitau gauto encodingo reiksme ir veciu i mazasias raides
			my $encoding = lc $poros{'Content-Transfer-Encoding'};
			# Ieskomo enkodingo reiksme
			my $ieskomaE = "quoted-printable";
			# Tikrinu ar mane domina sis enkodingas
			if($encoding eq $ieskomaE){
				# Radau sekcija kuria keisiu
				##### 1 Dekodacija #####
				my $decoded = decode_qp($part->body_raw);
 
				# Konvertuotju turima turini i base64
				##### 2 Enkodingas i BASE64 #####	
				my $encoded = encode_base64("$decoded");
 
				# Nustatau enkodingo antraštę
				$part->header_raw_set('Content-Transfer-Encoding' => 'base64');			
 
                    # Nustatau PDF failą su nauja koduote
				my $body_ref;
				$body_ref = \$encoded;
				$part->{body_raw} = $encoded;
				$part->{body} = \{$part->{body_raw}};
			}
			# else
			# Nieko nekeiciu!
		}
		# else
		# Kitos dalys manes nedomina, tik application/pdf
	})
}
 
my $mail_text;
 
#Nuskaitau laisko turini
while (<STDIN>) {
        $mail_text.=$_;
};
# Kuriu laisko objekta tolimesniam tikrinimui
my $parsed = Email::MIME->new($mail_text);
#Tikrinu ar siusta is Outlook'o
if(index($parsed->as_string, "X-Mailer: Microsoft Office Outlook") != -1){
	# Siusta is Outlook'o, nagrinesiu toliau
	partR $parsed;
}
 
# Persiunciu laiska
open( sendmail,"| /usr/sbin/sendmail -f '" .$ENV{SENDER}. "' $to") or die "Nepavyko perduoti duomenu sendmail'ui";
print sendmail $parsed->as_string;
close sendmail;
