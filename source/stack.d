..import linkedList;

class Stack(T)
{
private:
	LinkedList!T *arr;
	ulong length;

public:
	T pop()
	{
		LinkedList!T *node = this.arr;
		T data = node.data;

		this.arr = this.arr.next;
		freeNode(node);
		this.length--;
		return data;
	}

	T push(T data)
	{
		LinkedList!T *node = newNode(data, this.arr);
		this.length++;
		this.arr = node;
		return this.arr.data;
	}

	ulong getLen()
	{
		return this.length;
	}
}