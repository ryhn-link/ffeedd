import std.stdio;

import ffeedd.feed;
import ffeedd.item;
import ffeedd.author;
import std.datetime;
import std.conv;

void main()
{
	auto f = new Feed("ryhn.link", "https://ryhn.link/blog", "My very cool blog");
	f.published = Clock.currTime().to!DateTime();
	f.updated = Clock.currTime().to!DateTime() + 1.hours;

	foreach (i; 0 .. 6)
	{
		auto item = new FeedItem("Blog post " ~ i.to!string(),
				"https://ryhn.link/blog/" ~ i.to!string(), "This is the " ~ i.to!string() ~ " post");
		item.published = Clock.currTime().to!DateTime();
		item.updated = Clock.currTime().to!DateTime() + (i+2).hours;

		item.authors ~= Author("Writer " ~ i.to!string(), "writer" ~ i.to!string() ~ "@ryhn.link");

		f.items ~= item;
	}

	writeln("ATOM 1.0:");
	writeln(f.createAtomFeed());

	writeln();

	writeln("RSS 2.0:");
	writeln(f.createRSSFeed());
}
