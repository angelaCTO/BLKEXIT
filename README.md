gcc -lm -lrt -fPIC -m32 -shared -Bstatic BLKEXIT.c generator.c parser.c dictionary.c -o BLKEXIT

sshpass -p "Guest2345" scp BLKEXIT root@pit11:/var/opt/teradata/PIT11_BLKEXIT_2016
