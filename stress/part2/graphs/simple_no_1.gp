set terminal pdf
set output 'simple_no_1.pdf'
set xrange[0:31]
set yrange[0:24000]
plot 'simple_no_1.dat' with linespoints
