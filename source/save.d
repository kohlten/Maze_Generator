import std.stdio;
import std.file : read;
import cell;
import dsfml.system;
import std.conv : to;
import std.math : pow;
import std.digest.md;
import std.typecons;

int binStrToDec(string bin)
{
	int outnum;

	foreach_reverse (i; 0 .. bin.length)
	{
		if (bin[i] == '1')
			outnum += pow(2, i);
	}
	return outnum;
}

char[] decToBinStr(int num)
{
	char[] outstring;

	while (num > 0)
	{
		outstring ~= (num % 2) + 48;
		num /= 2;
	}
	while (outstring.length < 4)
		outstring ~= '0';
	/*foreach (i; 0 .. outstring.length / 2)
	{
		char tmp = outstring[i];
		outstring[i] = outstring[(outstring.length - 1) - i];
		outstring[(outstring.length - 1) - i] = tmp;
	}*/
	return outstring;
}

void saveMaze(Cell[][] cells, Vector2f size, int cellSize, string fileName, string name)
{
	string output;
	auto file = File(fileName, "wb");
	scope(exit) file.close();
	auto md5 = new MD5Digest();

	output ~= name ~
			 "\xff" ~ to!string(size.x) ~
			 "\xff" ~ to!string(size.y) ~
			 "\xff" ~ to!string(cellSize) ~
			 "\xff";
	
	foreach (i; 0 .. cells.length)
	{
		foreach (j; 0 .. cells[i].length)
		{
			int num = 0;
			string state;
			foreach (k; 0 .. 4)
				state ~= to!string(to!int(cells[i][j].shown[k]));
			num |= binStrToDec(state);
			output ~= to!string(to!char(num));
		}
	}
	string hash;
	foreach (c; md5.digest(output))
	{
		write(c);
		write(" ");
		hash ~= c;
	}
	file.rawWrite(hash ~ output);
	writeln("Saved to file " ~ fileName);
}

Tuple!(Cell[][], Vector2u, int, char[])* loadMaze(Cell[][] cells, string filename)
{
	char[] buffer;
	char[] tmp;
	Vector2u size;
	int cellSize;
	char[] name;
	ulong i;

	auto md5 = new MD5Digest();

	buffer = cast(char[])read(filename);
	foreach (c; md5.digest(buffer[16 .. buffer.length]))
		if (c != buffer[i++])
		{
			writeln("Invalid file!");
			return null;
		}
	while (buffer[i] != '\xff' && i < buffer.length)
		name ~= buffer[i++];
	i++;
	while (buffer[i] != '\xff' && i < buffer.length)
		tmp ~= buffer[i++];
	i++;
	size.x = to!int(tmp);
	tmp.length = 0;
	while (buffer[i] != '\xff' && i < buffer.length)
		tmp ~= buffer[i++];
	size.y = to!int(tmp);
	i++;
	tmp.length = 0;
	while (buffer[i] != '\xff' && i < buffer.length)
		tmp ~= buffer[i++];
	cellSize = to!int(tmp);
	i++;
	tmp.length = 0;
	//writeln(name, " ", size, " ", cellSize, " ", to!int(buffer[i]));
	foreach (j; 0 .. size.x / cellSize)
	{
		foreach (k; 0 .. size.y / cellSize)
		{
			char[] states = decToBinStr(to!int(buffer[i++]));
			if (states.length != 4)
			{
				writeln("Invalid file!");
				return null;
			}
			tmp.length = 0;
			foreach (l; 0 .. 4)
			{
				if (states[l] == '1')
					cells[j][k].shown[l] = true;
				else
					cells[j][k].shown[l] = false;
			}
		}
	}
	writeln("Successfuly loaded from file " ~ filename);
	return new Tuple!(Cell[][], Vector2u, int, char[])(cells, size, cellSize, name);
}