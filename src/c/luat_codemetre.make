# Beginning of parallelizable section
gcc -pipe -O3 -fomit-frame-pointer -funroll-loops -ffast-math -c -x c luat_codemetre.c
# End of parallelizable section
gcc -pipe -O3 -fomit-frame-pointer -funroll-loops -ffast-math -o codemetre luat_codemetre.o -x none -lm 
strip codemetre
