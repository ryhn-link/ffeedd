# ffeedd
ffeedd (Fun feed D) is a RSS 2.0 and Atom 1.0 generator. The RSS and Atom output from the example program has been validated by the [w3.org feed validator](https://validator.w3.org/feed) and passed the validations.

![valid rss](valid-rss-rogers.png) ![valid atom](valid-atom.png)

## How to use
Create a `Feed` class, fill in your data, add your `FeedItem`s to `Feed.items` and run `Feed.createAtomFeed()` or `Feed.createRSSFeed()`, these functions will return a string with the generated feed.  
Here's a snippet from the example program

```d
import ffeedd.feed;
import ffeedd.item;
import ffeedd.author;
import std.datetime;
...
// Feed name, link to the page, description of the feed
auto f = new Feed("ryhn.link", "https://ryhn.link/blog", "My very cool blog");
f.published = Clock.currTime().to!DateTime();
f.updated = Clock.currTime().to!DateTime() + 1.hours;
foreach (i; 0 .. 6)
{
	auto item = new FeedItem("Blog post " ~ i.to!string(),
		"https://ryhn.link/blog/" ~ i.to!string(), 
		"This is the " ~ i.to!string() ~ " post");
	item.content = item.content = `Example Content <a href="https://example.com">with html</a>.`;
	item.published = Clock.currTime().to!DateTime();
	item.updated = Clock.currTime().to!DateTime() + (i+2).hours;
	item.authors ~= Author("Writer " ~ i.to!string() ~ "<writer" ~ i.to!string()~ "@ryhn.link>");
	f.items ~= item;
}
writeln(f.createAtomFeed());
writeln(f.createRSSFeed());
```
