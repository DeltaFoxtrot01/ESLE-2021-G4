set terminal pdf
set output 'net_no_quorum.pdf'
set xrange[0:31]
set yrange[0:10000]
plot 'net_no_quorum.dat' with linespoints
