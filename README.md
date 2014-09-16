#Japanese dictionary

##Description

This application creates a web server on 127.0.0.1:1234 that you can
use to search for Japanese and English words and more, see below.

It's based on the KANJIDIC and KRADFILE projects, more
specifically on their xml versions and includes a sql version of these
projects, feel free to reuse them.
See [here](http://www.csse.monash.edu.au/~jwb/kradinf.html) for Kradfile and
[here](http://www.csse.monash.edu.au/~jwb/kanjidic_doc.html) for Kanjidic.

##License

See file COPYING for license information.

The dictionary files (iphone.db and its source iphone.sql) are on a
different Copyright regime :

    KANJIDIC, KANJD212 and KANJIDIC2 can be freely used provided
    satisfactory acknowledgement is made in any software product,
    server, etc. that uses them. There are a few other conditions
    relating to distributing copies of the files with or without
    modification. Copyright is vested in the EDRG (Electronic Dictionary
    Research Group, see http://www.edrdg.org/). You can see the specific
    licence statement at the Group's site :
    http://www.edrdg.org/edrdg/licence.html.
  
    The files are available from the Monash University ftp site
    http://ftp.monash.edu.au/pub/nihongo/kanjidic.gz and
    http://ftp.monash.edu.au/pub/nihongo/kanjd212.gz.
  
    The RADKFILE and KRADFILE files are copright and available under the
    EDRDG Licence. The copyright of the RADKFILE2 and KRADFILE2 files is
    held by Jim Rose.

##Search

This program features a new way of searching for kanjis : combine radicals
from whatever kanji you know, with vague skip codes (such as "it's a two part
vertical kanji" or "there's 4 strokes on the top part") and stroke counts, glue
these descriptions together with '&', add the possibility to look for more than
one kanji at a time with '+' and you have the ultimate kanji searching application.

Examples :
  - typing 帯&1-3-\_+在 in voyage, when you are looking for 滞在;
  - 特+残&1-\_-\_+医+病&小+研+究 for 特殊医療研究...

##Installation & Usage

You can use docker.

    # apt-or-something install docker
    $ docker build -t demo/kemuri github.com/boris-arzur/Kemuri
    $ KEMURI_ID=$(docker run -d -p 1234 demo/kemuri)
    $ KEMURI_IP=$(docker inspect $KEMURI_ID | grep IPAd | awk -F'"' '{print $4}')
    $ w3m http://${KEMURI_IP}:1234/yad/wow # or, you know, any browser ...
    $ docker logs ${KEMURI_ID}

On most modules, you will find a 'smart' input box, you can push
text (we call it $1 in what follows) in it, it will try to redirect you :
  - 'rad' and 'his' go to the modules /rad & /his;
  - *-*-* (more specifically /^\d-\d+-\d+$/ ) and /^\d+$/ to /sk/$1;
  - /^\d-\d+-\d++\d-\d+-\d+$/ to /biskip/$1 (bruteforce a pair of 
    skip-codes, a bit slow);
  - /^\d-\d+-\d+-\d-\d+-\d+$/ to /sk/$1;
  - numbers and hyphen separated pairs of numbers go to /sk/$1;
  - single kanjis to /kan/$1 or /yad/$1 (you have to choose);
  - multiple kanjis or kana to /yad/$1.
  - expression containing & or + to /slook/$1, then to
    /look/a_random_string, see the **Search** section.

This is the prefered way of interacting with Kemuri.

In some modules, you will find a blue button, try to drag it, it can be used
to navigate and will show in its center where it is going to send you.

In some modules, you will find a blue button, try to drag it, it can be used
to navigate and will show in its center where it is going to send you
For example, in /yav, it is used to answer : 'y' is 'yes, I know the kanji',
'n' is 'no', 'h' is 'hibernate' and 'yy' is 'double yes'. Different answers
have different effects on the learning algorithm, please refer to the code.

Please note this software uses ruby, sqlite3 and sqlite3-ruby, you
might need to get that installed before you can use Kemuri.

##Author

Brought to you by boris <d0t/> arzur <4t/> gmail.
