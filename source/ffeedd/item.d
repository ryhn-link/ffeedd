module ffeedd.item;

import ffeedd.author;
import std.datetime;

/// Based on:
/// RSS:	https://www.rssboard.org/rss-specification
/// ATOM:	https://www.tutorialspoint.com/rss/entry.htm
class FeedItem
{
	/// Instance a new item
	this(string itemTitle, string itemLink, string itemDescription)
	{
		title = itemTitle;
		link = itemLink;
		description = itemDescription;
	}

	/// Title of the item
	string title;
	/// Pernament URL to the item
	string link;
	/// Description of the item
	string description;

	/// List of item authors
	Author[] authors;
	/// Date when this item was initially published
	DateTime published;
	/// Date when the item was last updated
	DateTime updated; 
}