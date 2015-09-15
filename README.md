This is obnova project. More info on http://obnova.bp.opf.slu.cz/. 

To create kernel and initramfs, needed to boot, please run

$ ./configure
$ make

For more options, see

$ ./configure --help

Result will be in directory bin/ . You can test boot by

$ make test

or extract contents of initramfs to /tmp/obnova/

$ make extract

Please see project home on web to get more informations.

Obnova team

