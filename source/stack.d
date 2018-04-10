import std.range.primitives : popBack;

class Stack(T)
{
	private T[] stack;

	auto pop()
	{
		auto last = this.stack[this.stack.length - 1];
		this.stack.popBack();
		return last;
	}

	auto push(T node)
	{
		stack ~= node;
	}

	ulong getLen()
	{
		return this.stack.length;
	}
}