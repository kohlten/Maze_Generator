import stack;
import cell;
import save;
import globals;

import std.conv : to;
import std.stdio : writeln;
import std.random : uniform;
import std.datetime.stopwatch;

class Game
{
	Cell current;
	int wCells;
	int hCells;
	int iterations;


	ulong count;
	bool updating = true;

	RenderWindow window;
	int maxFPS;
	Vector2i size;
	Cell[][] cells;

	Color color;

	Stack!Cell stack;

	StopWatch sw;

	this(int width, int height, int maxFPS)
	{
		this.size.x = width;
		this.size.y = height;
		this.maxFPS = maxFPS;
		this.window = new RenderWindow(VideoMode(this.size.x, this.size.y), "Maze Generator");
		this.window.setFramerateLimit(maxFPS);
		writeln("Width: " ~ to!string(width) ~ " Height: " ~ to!string(height));
		this.wCells = width / cellHeight;
		this.hCells = height / cellHeight;
		this.cells.length = this.wCells;
		foreach (i; 0 .. this.wCells)
		{
			this.cells[i].length = this.hCells;
			foreach (j; 0 .. this.hCells)
				this.cells[i][j] = new Cell(i * cellHeight, j * cellHeight);
		}
		this.current = cells[0][0];
		this.current.visited = true;
		this.color = Color.Black;
		this.stack = new Stack!Cell();
		sw.start();
	}

	void run()
	{
		while (this.window.isOpen())
		{
			Event event;
			while (this.window.pollEvent(event))
			{
				if (event.type == Event.EventType.Closed)
					this.window.close();
				if (event.type == Event.EventType.KeyPressed && event.key.code == Keyboard.Key.S) //&& !this.updating)
					saveMaze(this.cells, Vector2f(this.size.x, this.size.y), cellHeight, "save.bin", "basic");
				if (event.type == Event.EventType.KeyPressed && event.key.code == Keyboard.Key.L) //&& !this.updating)
				{
					auto output = loadMaze(this.cells, "save.bin");
					if (output)
					{
						this.updating = false;
						this.cells = (*output)[0];
						this.size = (*output)[1];
						cellHeight = (*output)[2];
						this.window.size = (*output)[1];
					}
				}
				if (event.type == Event.EventType.KeyPressed && event.key.code == Keyboard.Key.R)
				{
					this.wCells = this.size.x / cellHeight;
					this.hCells = this.size.y / cellHeight;
					this.cells.length = this.wCells;
					foreach (i; 0 .. this.wCells)
					{
						this.cells[i].length = this.hCells;
						foreach (j; 0 .. this.hCells)
						this.cells[i][j] = new Cell(i * cellHeight, j * cellHeight);
					}
					this.current = cells[0][0];
					this.current.visited = true;
					this.updating = true;
					cellHeight = 10;
				}
			}
			this.update();
			this.window.clear(this.color);
			this.drawCells();
			this.window.display();
		}
	}

	void drawCells()
	{
		if (!this.updating)
		{
			foreach (i; 0 .. this.wCells)
				foreach (j; 0 .. this.hCells)
					cells[i][j].draw(this.window);
		}
		this.current.highlight(this.window);
	}

	void update()
	{
		if (updating)
		{
			auto next = this.current.checkNeighbors(this.size.x, this.size.y, this.cells);
			if (next)
			{
				next.visited = true;
				this.stack.push(this.current);
				this.current = next;
				this.count++;
			}
			else if (this.stack.getLen() > 0)
			{
				this.current = this.stack.pop();
				this.count--;
			}
			this.iterations++;
			if (this.iterations > 0 && this.current.pos.x / cellHeight == 0 && this.current.pos.y / cellHeight == 0)
			{
				updating = false;
				writeln("Done");
				writeln("Took " ~ to!string(this.iterations) ~ " iterations!");
				writeln("Took ", this.sw.peek());
			}
		}
	}
}

void main()
{
	auto main = new Game(500, 500, 0);
	main.run();
}
