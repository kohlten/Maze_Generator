import std.random;
import globals;

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

			auto r = uniform(0, neighbors.length);
			while (neighbors[r] is null)
				r = uniform(0, neighbors.length);
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
