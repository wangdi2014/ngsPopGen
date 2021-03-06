
TOOLS = ngs2dSFS ngsCovar ngsFST ngsStat

CCX ?= g++
CFLAGS = -lm -lz -O3 -Wall

all: $(TOOLS)

$(TOOLS):
	$(CXX) $(CFLAGS) $@.cpp -o $@

test:
	@cd examples/; bash test.sh 2> test.log; cd ../

clean:
	@rm -rf $(TOOLS) *.o examples/testA*
