set terminal pdf
set output 'simple_no_quorum.pdf'
set xrange[0:201]
set yrange[0:12000]
plot 'simple_no_quorum.dat' with linespoints
