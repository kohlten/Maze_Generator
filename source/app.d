import dsfml.window;
import dsfml.graphics;
import dsfml.system;

import stack;

import std.conv : to;
import std.stdio : writeln;
import std.random : uniform, unpredictableSeed, Random;

immutable int cellHeight = 10;

Random rng;

int isNull(T)(T[] arr)
{
	foreach (i; 0 .. arr.length)
	{
		if (arr[i] !is null)
			return 0;
	}
	return 1;
}

class Cell
{
	Vector2f pos;
	//Top, left, bottom, right
	RectangleShape[4] sides;
	bool[4] shown = [true, true, true, true];
	bool visited = false;
	RectangleShape visitedRect;

	this(int x, int y)
	{
		this.pos.x = x;
		this.pos.y = y;
		foreach (i; 0 .. 4)
		{
			this.sides[i] = new RectangleShape();
			this.sides[i].fillColor(Color(255, 255, 255, 100));
		}
		this.setPositions();
		this.visitedRect = new RectangleShape();
		this.visitedRect.position = this.pos;
		this.visitedRect.size(Vector2f(cellHeight, cellHeight));
		this.visitedRect.fillColor(Color(255, 0, 0, 150));
	}

	void draw(RenderWindow window)
	{
		foreach(i; 0 .. this.sides.length)
			if (this.shown[i])
				window.draw(this.sides[i]);
	}

	void highlight(RenderWindow window)
	{
		this.visitedRect.position = this.pos;
		window.draw(this.visitedRect);
	}

	void setPositions()
	{
		this.sides[0].size(Vector2f(cellHeight, 1));
		this.sides[0].position = this.pos;
		this.sides[1].size(Vector2f(1, cellHeight));
		this.sides[1].position = this.pos;
		this.sides[2].size(Vector2f(cellHeight, 1));
		this.sides[2].position = Vector2f(this.pos.x, this.pos.y + cellHeight);
		this.sides[3].size(Vector2f(1, cellHeight));
		this.sides[3].position = Vector2f(this.pos.x + cellHeight, this.pos.y);
	}

	Cell checkNeighbors(int width, int height, Cell[][] cells)
	{
		auto index = Vector2i(cast(int) this.pos.y / cellHeight, cast(int) this.pos.x / cellHeight);

		Vector2i[] toCheck = [Vector2i(index.x - 1, index.y),
			Vector2i(index.x, index.y - 1), Vector2i(index.x + 1, index.y), Vector2i(index.x, index.y + 1)];
		
		Cell[] neighbors = [null, null, null, null];
		
		int i;
		
		foreach (pos; toCheck)
		{
			if (pos.x >= 0 && pos.y >= 0 && pos.y < cells.length && pos.x < cells[0].length)
				if (!cells[pos.y][pos.x].visited)
					neighbors[i] = cells[pos.y][pos.x];
			i++;
		}

		if (!isNull!Cell(neighbors))
		{

			auto r = uniform(0, neighbors.length, rng);
			while (neighbors[r] is null)
				r = uniform(0, neighbors.length, rng);
			auto next = neighbors[r];
			next = this.removeWalls(next, r);
			return next;
		}
		else
			return null;
	}

	Cell removeWalls(Cell next, ulong r)
	{
		if (r == 0)
		{
			this.shown[0] = false;
			next.shown[2] = false;
		}
		else if (r == 1)
		{
			this.shown[1] = false;
			next.shown[3] = false;
		}
		else if (r == 2)
		{
			this.shown[2] = false;
			next.shown[0] = false;
		}
		else if (r == 3)
		{
			this.shown[3] = false;
			next.shown[1] = false; 
		}
		return next;
	}
}

class Game
{
	int width;
	int height;
	Cell current;
	int wCells;
	int hCells;
	int iterations;

	bool updating = true;

	RenderWindow window;
	Cell[][] cells;

	Color color;

	Stack!Cell stack;

	this(int width, int height, int maxFPS)
	{
		this.width = width;
		this.height = height;
		this.window = new RenderWindow(VideoMode(width, height), "Maze Generator");
		this.window.setFramerateLimit(maxFPS);
		writeln("Width: " ~ to!string(width) ~ " Height: " ~ to!string(height));
		this.wCells = (width - 1) / cellHeight;
		this.hCells = (height - 1) / cellHeight;
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
	}

	void run()
	{
		while (this.window.isOpen())
		{
			Event event;
			while (this.window.pollEvent(event))
				if (event.type == Event.EventType.Closed)
					this.window.close();
			this.update();
			this.window.clear(this.color);
			this.drawCells();
			this.window.display();
		}
	}

	void drawCells()
	{
		foreach (i; 0 .. this.wCells)
			foreach (j; 0 .. this.hCells)
				cells[i][j].draw(this.window);
		this.current.highlight(this.window);
	}

	void update()
	{
		if (updating)
		{
			auto next = this.current.checkNeighbors(this.width, this.height, this.cells);
			if (next)
			{
				next.visited = true;
				this.stack.push(this.current);
				this.current = next;
			}
			else if (this.stack.getLen() > 0)
				this.current = this.stack.pop();
			this.iterations++;
		
			if (this.iterations > 0 && this.current.pos.x / cellHeight == 0 && this.current.pos.y / cellHeight == 0)
			{
				updating = false;
				writeln("Done");
				writeln("Took " ~ to!string(this.iterations) ~ " iterations!");
			}
		}
	}
}

void main()
{
	rng = Random(unpredictableSeed);
	auto main = new Game(1001, 1001, 300);
	main.run();
}
