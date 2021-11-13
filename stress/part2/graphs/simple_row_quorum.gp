set terminal pdf
set output 'simple_row_quorum.pdf'
set xrange[0:201]
set yrange[0:13000]
plot 'simple_row_quorum.dat' with linespoints
