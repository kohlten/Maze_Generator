DC=ldc2
OUT=bin/maze_generator

$(OUT):
	#-git clone https://github.com/Jebbs/DSFMLC.git
	#-cd DSFMLC && cmake . && make
	#cp -rf DSFMLC/extlibs/libs-osx/Frameworks .
	#cp DSFMLC/lib/* Frameworks
	dub build --compiler=$(DC) --build=release --combined


clean:
	dub clean
	-rm dub.selections.json
	-rm -rf bin

fclean: clean
	-rm -rf .dub
	-rm -rf DSFMLC
	-rm -rf Frameworks

re: clean $(OUT)

.PHONY: clean fclean