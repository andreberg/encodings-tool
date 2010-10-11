Introduction
------------

encodings is a command line tool that I created in my quest to
fully grasp string encodings. Since then I have come back to using
it whenever I get output that I know looks wrong because of a false
encoding but I can't quite pin down which encoding is the false one.

Even in this day and and age UTF-8 is not always the answer to 
everything and sometimes it helps me to have debugging tools like
this.

In closing, here's some example input and output:

    $ encodings -i 4 -o 30 André    
    
    ---------- Convert input to data -----------------

    input string as data using encoding Unicode (UTF-8) = <416e6472 c3a920>

    ---------- Convert data to output -----------------
    
    data as string using encoding Western (Mac OS Roman) = Andr√©
    
    $ encodings -l  # list available encodings
    
            30: Western (Mac OS Roman)
    2147483649: Japanese (Mac OS)
    ...skipped...
    2147486722: Western (EBCDIC Latin 1)

         total: 105
    

Usage
-----

    encodings -- string output converted to arbitrary encodings

    Created by André Berg on 2010-10-10.
    Copyright 2010 Berg Media. All rights reserved.

    USAGE: encodings [-V] [-h] [-v] [-l] [-i <SPEC>] [-o <SPEC>] string

        The string is first converted to NSData instances
        using all encodings specified by -i <SPEC>.
        Each NSData instance is then converted to all encodings
        specified by -o <SPEC>.

        <SPEC>      Following formats are valid as specifier:

                    n       a single number, e.g. 30 for Mac OS Roman Encoding
                    n-n     a range of encodings, e.g. 1-4
                    n,n,... a comma separated list of encodings, e.g. 1,2,5

        Note: a number may also be entered in 0xnnn... hex format
        Note 2: invalid encoding numbers in ranges will be overlooked

        For valid numbers look at NSStringEncoding and CFStringEncodingExt.h.

        If -i or -o is not specified a list will be populated by all
        encodings returned from [NSString availableStringEncodings].

        Warning: if both -i and -o are not specified the output can be
        huge, as each in encoding is converted to each out encoding!


    OPTIONS:
        -V, --version        Display version and exit

        -h, --help           Display this help and exit

        -v, -verbose         Output every conversion from data to string
                             even if the result is nil

        -l, -list            List all available encodings and exit

    ERROR CODES:

       -1   populating the in encodings list failed
       -2   populating the out encodings list failed
        1   input string missing
        2   invalid in encodings list
        3   invalid in encoding number
        4   invalid in encodings range
        5   invalid out encodings list
        6   invalid out encoding number
        7   invalid out encodings range

    DISCLAIMER:
        This program comes with ABSOLUTELY NO WARRANTY
        either express or implied. Use solely at your own risk!

    LICENSE:
        Licensed under the MIT license. 
        http://www.opensource.org/licenses/mit-license.html

    SEE ALSO:
        man iconv(1)
