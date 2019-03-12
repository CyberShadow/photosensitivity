import ae.utils.graphics.color;
import ae.utils.graphics.draw;
import ae.utils.graphics.image;

import std.algorithm.mutation;
import std.conv;
import std.random;
import std.stdio;

void render(int minW, int maxW, int minH, int maxH, bool swap, bool gray, int alignment = 0)
{
	rndGen.seed(0);

	alias Color = RGB;
	auto i = Image!Color(800, 600);
	foreach (n; 0 .. 10_000)
	{
		auto w = uniform!"[]"(minW, maxW);
		auto h = uniform!"[]"(minH, maxH);
		if (swap && uniform(0, 2)) .swap(w, h);
		auto x = uniform!"[]"(0, i.w - w);
		auto y = uniform!"[]"(0, i.h - h);
		ubyte c;
		if (alignment)
			c = (x % alignment * 255 / alignment).to!ubyte;
		else
			c = uniform!ubyte;
		if (!gray)
			c = c < 128 ? 0 : 255;
		i.fillRect(x, y, x + w, y + h, Color.monochrome(c));
	}
	i.toPNG.toFile("../../pub/img/rects/rects-%d~%d%s%d~%d-%s%%%d.png".format(
		minW, maxW,
		swap ? "xx" : "x",
		minH, maxH,
		gray ? "gray" : "mono",
		alignment,
	));
}

void main()
{
	render(20, 50, 20, 50, false, false);
	render(0, 50, 0, 50, false, false);

	foreach (gray; [false, true])
		foreach (swap; [false, true])
			render(0, 20, 0, 200, swap, gray);

	foreach (minW; [0, 20])
		foreach (gray; [false, true])
			foreach (alignment; [0, 40])
				render(minW, 20, 600, 600, false, gray, alignment);
}
