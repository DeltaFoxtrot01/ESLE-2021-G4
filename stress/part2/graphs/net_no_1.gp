set terminal pdf
set output 'net_no_1.pdf'
set xrange[0:31]
set yrange[0:18000]
plot 'net_no_1.dat' with linespoints
