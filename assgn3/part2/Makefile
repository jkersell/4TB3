COMPILE=fpc
BINARY=table_formatter_1041571
TEST_DIR=../tests/

build :
	fpc table_formatter_1041571.pas

test1 : build
	./$(BINARY) $(TEST_DIR)test1.html

test2 : build
	./$(BINARY) $(TEST_DIR)test2.html

test3 : build
	./$(BINARY) $(TEST_DIR)test3.html

test4 : build
	./$(BINARY) $(TEST_DIR)test4.html

test5 : build
	./$(BINARY) $(TEST_DIR)test5.html

test6 : build
	./$(BINARY) $(TEST_DIR)test6.html

.PHONY : clean
clean :
	rm $(BINARY) *.o *.ppu
