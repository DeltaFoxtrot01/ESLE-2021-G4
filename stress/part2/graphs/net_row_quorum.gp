set terminal pdf
set output 'net_row_quorum.pdf'
set xrange[0:201]
set yrange[0:16000]
plot 'net_row_quorum.dat' with linespoints
