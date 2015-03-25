GRAMMAR=table_formatter_1041571
GENERATED=*.java *.tokens *.class
TEST=grun $(GRAMMAR) r

build : $(GRAMMAR).g4
	antlr4 $(GRAMMAR).g4
	javac table*.java

test1 : build
	$(TEST) < ../tests/test1.html

test2 : build
	$(TEST) < ../tests/test2.html

test3 : build
	$(TEST) < ../tests/test3.html

test4 : build
	$(TEST) < ../tests/test4.html

test5 : build
	$(TEST) < ../tests/test5.html

test6 : build
	$(TEST) < ../tests/test6.html

.PHONY : clean
clean :
	rm $(GENERATED)
