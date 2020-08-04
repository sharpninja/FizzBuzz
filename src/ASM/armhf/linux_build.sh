arm-linux-gnueabihf-as ./fizzbuzz.S -o ./fizzbuzz.o 
arm-linux-gnueabihf-gcc -no-pie -nostartfiles ./fizzbuzz.o -o ./fizzbuzz -lc
