module ffeedd.feed;

import std.datetime;
import ffeedd.author;
import ffeedd.item;
import vibe.textfilter.html;
import std.conv;

/// Based on:
/// RSS:	https://www.rssboard.org/rss-specification
/// ATOM:	https://www.tutorialspoint.com/rss/feed.htm
class Feed
{
	/// Instances a new channel only with the required elements
	this(string feedTitle, string feedLink, string feedDescription)
	{
		title = feedTitle;
		link = feedLink;
		description = feedDescription;
	}

	/// The name of the feed. It's how people refer to your service.
	/// e.g. "GoUpstate.com News Headlines"
	string title;
	/// The URL to the HTML website corresponding to the channel.
	/// eg. "http://www.goupstate.com/"
	string link;
	/// Phrase or sentence describing the channel.
	/// e.g. "The latest news from GoUpstate.com, a Spartanburg Herald-Journal Web site."
	string description;
	/// Items in this feed
	FeedItem[] items;

	// Optional elements
	/// Time when the feed was last updated
	DateTime updated;
	/// This contains the time of the initial creation or the first availability of the entry.
	DateTime published;
	/// List of authors
	Author[] authors;

	string createAtomFeed()
	{
		string s = "<feed xmlns=\"http://www.w3.org/2005/Atom\">\n";

		if (title)
			s ~= "\t<title>" ~ htmlAttribEscape(title) ~ "</title>\n";

		if (link)
			s ~= "\t<id>" ~ htmlAttribEscape(link) ~ "</id>\n";

		if (description)
			s ~= "\t<subtitle>" ~ htmlAttribEscape(link) ~ "</subtitle>\n";

		if (updated != DateTime())
			s ~= "\t<updated>" ~ toRFC3339String(updated) ~ "</updated>\n";

		// Stops w3.org checker from validating 
		// tutorialspoint.com probably made a mistake and included <published> in the feed

		// if (published != DateTime())
		// 	s ~= "\t<published>" ~ toRFC3339String(updated) ~ "</published>\n";

		foreach (author; authors)
		{
			s ~= "\t<author>\n";

			if (author.name)
				s ~= "\t\t<name>" ~ htmlAttribEscape(author.name) ~ "</name>\n";

			if (author.email)
				s ~= "\t\t<email>" ~ htmlAttribEscape(author.email) ~ "</email>\n";

			s ~= "\t</author>\n";
		}

		foreach (item; items)
		{
			s ~= "\t<entry>\n";

			if (item.title)
				s ~= "\t\t<title>" ~ htmlAttribEscape(item.title) ~ "</title>\n";

			if (item.link)
			{
				s ~= "\t\t<id>" ~ htmlAttribEscape(item.link) ~ "</id>\n";
				s ~= "\t\t<link rel=\"alternate\" href=\"" ~ htmlAttribEscape(item.link) ~ "\"/>\n";
			}

			if (item.description)
				s ~= "\t\t<summary>" ~ htmlAttribEscape(item.description) ~ "</summary>\n";

			if (item.content)
				s ~= "\t\t<content type=\"html\">" ~ htmlAttribEscape(item.content)  ~ "</content>\n";

			foreach (author; item.authors)
			{
				s ~= "\t\t<author>\n";

				if (author.name)
					s ~= "\t\t\t<name>" ~ htmlAttribEscape(author.name) ~ "</name>\n";

				if (author.email)
					s ~= "\t\t\t<email>" ~ htmlAttribEscape(author.email) ~ "</email>\n";

				s ~= "\t\t</author>\n";
			}

			if (item.updated != DateTime())
				s ~= "\t\t<updated>" ~ toRFC3339String(item.updated) ~ "</updated>\n";

			if (item.published != DateTime())
				s ~= "\t\t<published>" ~ toRFC3339String(item.published) ~ "</published>\n";


			s ~= "\t</entry>\n";
		}

		s ~= "</feed>";

		return s;
	}

	string createRSSFeed()
	{
		string s = "<rss xmlns:content=\"http://purl.org/rss/1.0/modules/content/\" version=\"2.0\">
	<channel>\n";

		if (title)
			s ~= "\t<title>" ~ htmlAttribEscape(title) ~ "</title>\n";

		if (link)
			s ~= "\t<link>" ~ htmlAttribEscape(link) ~ "</link>\n";

		if (description)
			s ~= "\t<description>" ~ htmlAttribEscape(link) ~ "</description>\n";

		if (updated != DateTime())
			s ~= "\t<lastBuildDate>" ~ toRFC822String(updated) ~ "</lastBuildDate>\n";

		if (published != DateTime())
			s ~= "\t<pubDate>" ~ toRFC822String(updated) ~ "</pubDate>\n";

		// RSS 2.0 feed doesn't have author tags
		// but it doesn't break anything so I'm keeping it
		foreach (author; authors)
			s ~= "\t<author>" ~ htmlAttribEscape(author.email) ~ " (" ~ htmlAttribEscape(author.name) ~ ")</author>\n";

		foreach (item; items)
		{
			s ~= "\t\t<item>\n";

			if (item.title)
				s ~= "\t\t\t<title>" ~ htmlAttribEscape(item.title) ~ "</title>\n";

			if (item.link)
		{
				s ~= "\t\t\t<link>" ~ htmlAttribEscape(item.link) ~ "</link>\n";
				s ~= "\t\t\t<guid isPermaLink=\"true\">" ~ htmlAttribEscape(item.link) ~ "</guid>\n";
		}

			if (item.description)
				s ~= "\t\t\t<description>" ~ htmlAttribEscape(item.description) ~ "</description>\n";

			if (item.content)
				s ~= "\t\t\t<content:encoded>" ~ htmlAttribEscape(item.content)  ~ "</content:encoded>\n";

			foreach (author; item.authors)
			s ~= "\t\t\t<author>" ~ htmlAttribEscape(author.email) ~ " (" ~ htmlAttribEscape(author.name) ~ ")</author>\n";

			if (item.published != DateTime())
				s ~= "\t\t\t<pubDate>" ~ toRFC822String(item.published) ~ "</pubDate>\n";


			s ~= "\t\t</item>\n";
		}

		s ~= "\t</channel>\n</rss>";

		return s;
	}
}

/// Convert DateTime to RFC 3339 date-time string
/// e.g. 2002-10-02T10:00:00Z
string toRFC3339String(DateTime date)
{
	return date.toISOExtString() ~ "Z";
}

/// Convert DateTime to RFC 822 date-time string
/// Sat, 07 Sep 2002 00:00:01 GMT
string toRFC822String(DateTime date)
{
	import std.range;
	import std.string;
	import std.format;

	string day =  date.dayOfWeek.to!string();
	//day[0] = day[0].toUpper();
	
	string month = date.month.to!string();
	//month[0].toUpper()[0];

	return day ~ ", " ~ date.day.to!string().padLeft('0', 2).text ~ " " ~ month ~ " " ~ date.year.to!string() ~ " " ~ 
			date.hour.to!string().padLeft('0', 2).text ~ ":" ~ 
			date.minute.to!string().padLeft('0', 2).text ~ ":" ~ 
			date.second.to!string().padLeft('0', 2).text ~ " +0000";
}
