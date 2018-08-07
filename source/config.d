import std.file;
import std.stdio;

enum : int
{
	OBJECT    = 1,
	PRIMITIVE = 2,
	UNKNOWN   = 3,
	ARRAY     = 4,
	STRING    = 5
}

struct Token(T)
{
	T data;
	int type;
	int start;
	int end;
}

class Parser
{
	string text;
	string filename;
	int current;

	this(string file)
	{
		if (exists(file))
			this.text = readText(file);
		else
			this.text = file;
	}

	this()
	{}

	void parse_string(string text)
	{
		
	}
}
