bits = 12;

tableBitsMax = 20;
close all;
hold on;

xref = linspace(0,pi/2, 2**24);

prec = [];
tabLength = [];

for i=1:tableBitsMax
	i
	points = 2**i
	x = linspace(0,pi/2, points);
	plot(x,sin(x), 'b')
	err = sin(xref)-interp1(x, sin(x), xref);
	maxError = max(err);
	precBits = log2(1/maxError)
	if precBits > bits
		break;
	end;
	tabLength = [tabLength log2(points)];
	prec = [prec precBits];
	fflush(stdout)
	%plot(xref, err, 'r');
end;

figure
plot(tabLength, prec)
xlabel('table address bits');
ylabel('bits of precision');
diff(prec)
