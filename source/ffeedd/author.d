module ffeedd.author;

import std.regex;

struct Author
{
	/// Create author from a string. ("Name <email@something.com>")
	this(string s)
	{
		auto authorReg = ctRegex!r"^(.*) <(.*@.*\..*)>$";
		auto m = match(s, authorReg);

		name = m.captures[1];
		email = m.captures[2];
	}

	string name;
	string email;
}