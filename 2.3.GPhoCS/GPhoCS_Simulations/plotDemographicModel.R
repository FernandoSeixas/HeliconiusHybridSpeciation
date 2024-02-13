require(POPdemog)



msms.cmd <- "./ms 18 1 -T -I 3 8 8 2 -ej 0.25 2 1 -ej 1.0 1 3 -n 1 4.6 -n 2 6.5 -n 3 0.4 -en 0.26 1 1.0 -m 1 2 0.1 -m 2 1 0.1 -r 0.0 1000 -N 1000000"

msms.cmd <- "./ms 18 100 -T -I 3 8 8 2 -ej 0.25 2 1 -ej 1.0 1 3 -n 1 1.0 -n 2 1.0 -n 3 1.0 -m 1 2 10.0 -r 0 1000 -N 1000000"
PlotMS(input.cmd = msms.cmd, type = "ms", N4 = 4000000, col.pop = c("brown", "blue", "forestgreen", rainbow(10)[6:9]),
       col.arrow = "black", length.arrowtip = 0.1, lwd.arrow = 2);


PlotMS(input.cmd = test.1.ms.cmd, type = "ms", N4 = 10000,
       time.scale = "kyear", length.arrowtip = 0.1, inpos = c(1,2,5,4.5,5.5,6,3),
       col.pop = c("brown", "blue", "forestgreen", rainbow(10)[6:9]));


"./ms 15 100 -t 3.0 -I 6 0 7 0 0 8 0 -m 1 2 2.5 -m 2 1 2.5 -m 2 3 2.5
-m 3 2 2.5 -m 4 5 2.5 -m 5 4 2.5 -m 5 6 2.5 -m 6 5 2.5 -em 2.0 3 4 2.5
-em 2.0 4 3 2.5" -> test.2.ms.cmd
PlotMS(input.cmd = test.2.ms.cmd, type = "ms", N4 = 10000, col.pop = "gray",
       col.arrow = "black", length.arrowtip = 0.1, lwd.arrow = 2);
