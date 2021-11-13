set terminal pdf
set output 'simple_row_1.pdf'
set xrange[0:30]
set yrange[0:12000]
plot 'simple_row_1.dat' with linespoints
