# PDF-Converter
This script is developed by need to convert emails with PDF attachment from quoted-printable to Base64 encoding.

## Broblem
This script solves problem from Outlook software sending PDF attachemnts to Courier MTA whitch relays mails to IBM Lotus Domino server. IBM Lotus Domino unable to decode Outlook quoted-printable PDF file corrctly so Courier MTA uses this script to encode PDF file to Base64.

## Algorithm
Algorithm is quit simple. Main point is that all mails for specific user must go thru this script. Scripts algorith in steps:

1. Script reads email from STDIN

2. Then analizes if email was send with Outlook softaware (X-Mailer header). True-> (3) False->(7)

3. Checks email parts if it contains PDF file. True-> (4) False->(7)

4. Checks if PDF encoded in quoted-printable. True-> (5) False->(7)

5. If so decodes PDF file

6. Encodes PDF file with Base64 encoding

7. Sends mail to receaver (internal mail address)

## Requared packages
This script requares some packages (tested on Debian):
* ibemail-mime-perl
* libemail-mime-encodings-perl
* libmime-base64-perl
* perl

## Setting up
For example jon. Jon's external email address- jon@comapny.com and internal lotus address is jon.internal@comany.com. To settup script to work for Jon we need to edit aliases file like follows:

***jon@comapny.com: | $PATH_TO_SCRIPT/pdf-convert.pl jon.internal@comany.com***

## Script usability
***pdf-convert.pl $to***

* $to- internal email address where to rellay emails
