module tmptopmod(clk, resetn, load, try, endinput, start, timeout, 
				ld, timecount, compare, wordcount, part, p2score, p1score)
	input clk, resetn, load, try, endinput, start, timecount
	output ld, timecount, compare, wordcount, 