import core.memory : GC;

struct LinkedList(T)
{
	T data;
	LinkedList!T *next = null;
}

LinkedList!T* newNode(T)(T data, LinkedList!T* next = null)
{
	LinkedList!T* list = cast(LinkedList!T*)GC.malloc(LinkedList!T.sizeof);
	assert(list, "Failed to allocate");
	list.data = data;
	list.next = next;
	return list;
}	

void freeNode(T)(LinkedList!T* list)
{
	GC.free(list);
	list = null;
}