#HOW TO USE THIS MAKEFILE
#Try to ONLY modify the variables that have been marked as
#	ok to modify. Be carefule of modifiying any fields
#	marked as rarely modified.
#To set the location of either the deps, objs, hdrs, or srcs
#	to the current directory DON'T USE ".", instead use
#	$(shell pwd). Else, any other directory name is fine
#In order to make a specific building target that has different
#	input for the makefile variables/fields, make a .PHONY target
#	that calls make (basically making a recursive vall to make)
#	with modified variables:
#	ex. make CFLAGS=-Ofast will make the changes everywhere that
#	CFLAGS appears in the Makefile, without having to permenetly
#	change the makefile! (If still confused, look at debug and release)
#	targets already made
#Please look at the release and debug targets, and modify them
#	as needed

#BE CAREFUL WITH UNINTENDED SPACES! YOU'VE BEEN WARNED

#FIELDS OK TO MODIFY
EXEC = a.out
DEPSDIR = deps
OBJSDIR = build
HDRSDIR = $(shell pwd)
CC = g++
CFLAGS = -ansi -std=c++11 -Wall -Wpedantic -I $(HDRSDIR)
LFLAGS = -ansi -std=c++11 -Wall -Wpedantic
#DONT USE ".", use $(shell pwd) to get an 
#absolute path to current directory
#else, just the name of the directory in
#the current directory, such as srcs
SRCSDIR = $(shell pwd)
#remember not to add extra space!!!!
#ex. = .cpp WRONG! =.cpp RIGHT!!
SRC_FILE_EXTENSION =.cpp


#FIELDS RARELY MODIFIED
SRCS = $(patsubst $(SRCSDIR)/%$(SRC_FILE_EXTENSION), %$(SRC_FILE_EXTENSION), $(wildcard $(SRCSDIR)/*$(SRC_FILE_EXTENSION)))
OBJS = $(patsubst %$(SRC_FILE_EXTENSION), $(OBJSDIR)/%.o, $(SRCS))
DEPS = $(patsubst %$(SRC_FILE_EXTENSION), $(DEPSDIR)/%.d, $(SRCS))


#DEPS BUILDING SPECIFIC FIELDS (RARELY MODIFIED)
TARGET = $(patsubst $(SRCSDIR)/%$(SRC_FILE_EXTENSION), $(OBJSDIR)/%.o, $<)
DEPFLAGS = -MM -MP -MF $@ -MT $(TARGET) -I $(HDRSDIR)
PY_DEPARGS = $@ "$(CC) $< $(CFLAGS) -c -o $(TARGET)"
PY_DEPMAKER_SCRIPT = make_depfiles.py


.PHONY: clean all release debug run

all: $(EXEC)

#this does the linking
$(EXEC): $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@

run: $(EXEC)
	./$(EXEC)

$(DEPSDIR)/%.d: $(SRCSDIR)/%$(SRC_FILE_EXTENSION) $(PY_DEPMAKER_SCRIPT)
	@mkdir -p $(DEPSDIR)
	@mkdir -p $(OBJSDIR)
	#making $@
	@$(CC) $(DEPFLAGS) $<
	@./$(PY_DEPMAKER_SCRIPT) $(PY_DEPARGS)

clean:
	rm -f -r *$(OBJSDIR)
	rm -f -r *$(DEPSDIR)
	rm -f *$(EXEC)

#I do a "recursive call" of make to get arround the issue of
#include $(DEPS) building the deps even before a target such
#as release changes for example the CFLAGS. Remember, include
#will always do its thang first, even before an explicitly
#called target such as release
release:
	make CFLAGS="$(CFLAGS) -O2" \
	LFLAGS="-$(LFLAGS) -O2" \
	DEPSDIR=$@_$(DEPSDIR) \
	OBJSDIR=$@_$(OBJSDIR) \
	EXEC=$@_$(EXEC)

debug:
	make CFLAGS="$(CFLAGS) -O0 -g" \
	LFLAGS="$(LFLAGS) -O0 -g" \
	DEPSDIR=$@_$(DEPSDIR) \
	OBJSDIR=$@_$(OBJSDIR) \
	EXEC=$@_$(EXEC)

include $(DEPS) #first "rule" to be run no matter what

#this writes out the whole python script if it doesn't
#already exist. ITS UGLY BUT IT WORKS! Just run the make
#command and see what is created, I swear it will make a
#lot more sense
$(PY_DEPMAKER_SCRIPT):
	#making $@ custom built by yours truly
	@echo "#!/usr/bin/python3" > $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "import sys" >> $(PY_DEPMAKER_SCRIPT)
	@echo "import os" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "def main(fname : str, recipe : str) -> None:" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    '''" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    Intended to be used with automatic dependency" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    building makefiles. The problem it seeks to solve" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    is choosing a directory into where to dump the object" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    files." >> $(PY_DEPMAKER_SCRIPT)
	@echo "    ex. gcc -M -MP -MF deps/main.d -MT build/main.o main.c" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    " >> $(PY_DEPMAKER_SCRIPT)
	@echo "    fname is the name of the file produced by the above" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    gcc -M (or -MM) -MP -MF <fname> -MT <target> combo" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    recipe defines, well, the recipe for the automatically" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    created rule." >> $(PY_DEPMAKER_SCRIPT)
	@echo "    '''" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    new_depfile_name = \".temp_dep_file.d\"" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    base_depfile = open(fname, \"r\")" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    new_depfile = open(new_depfile_name, \"w\")" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    for line in base_depfile:" >> $(PY_DEPMAKER_SCRIPT)
	@echo "        new_depfile.write(line)" >> $(PY_DEPMAKER_SCRIPT)
	@echo "        if line[-2] != '\\\\\\': #line[-1] is always '/n'" >> $(PY_DEPMAKER_SCRIPT)
	@echo "            new_depfile.write(\"\\\t\")" >> $(PY_DEPMAKER_SCRIPT)
	@echo "            new_depfile.write(recipe)" >> $(PY_DEPMAKER_SCRIPT)
	@echo "            new_depfile.write(\"\\\n\")" >> $(PY_DEPMAKER_SCRIPT)
	@echo "            break" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    #write the rest of the file" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    for line in base_depfile:" >> $(PY_DEPMAKER_SCRIPT)
	@echo "        new_depfile.write(line)" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    new_depfile.close()" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    base_depfile.close()" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    #overwrite base_depfile with new dep file" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    #that also includes the specific recipe" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    os.rename(new_depfile_name, fname)" >> $(PY_DEPMAKER_SCRIPT)
	@echo "" >> $(PY_DEPMAKER_SCRIPT)
	@echo "if __name__ == \"__main__\":" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    if len(sys.argv) > 2:" >> $(PY_DEPMAKER_SCRIPT)
	@echo "        main(sys.argv[1], sys.argv[2])" >> $(PY_DEPMAKER_SCRIPT)
	@echo "    else:" >> $(PY_DEPMAKER_SCRIPT)
	@echo "        print(sys.argv[0] + \" <dep fname> <recipe (eg gcc -c)>\")" >> $(PY_DEPMAKER_SCRIPT)
	@chmod 755 $(PY_DEPMAKER_SCRIPT)

#WHAT I LEARNED MAKING THIS MAKEFILE
#@ infront of a line a recipie, shuts up the output to the terminal
#mkdir -p ensures that no errors are thrown even if the file already exists
#.PHONY targets are used when the target is not a file
#-MM shows all the, non standard, dependencies that a c file has (gcc)
#	One thing to watch out for is that the rule will only keep the path
#	of the source file in the depenency/prerequiste list IF it is not "."
#	(not sure of ".."), but in those cases, it is just better to use an
#	absolute address. This is not a problem if for example its like srcs/main.c
#-MP adds a phony target for all the header files created by the -MM rule (gcc)
#-MF allows you to change the name of the output "sub makefile" made by the -MM option
#-MT allows you to change the target of the rule made by -MM (useful for organizing)
#I had some more experience with python3 -c and python3 - <<-EOF which are both useful
# 	for "one line" comand line python
#the include directive/keyword in make more or less works by opening an exisiting
#	makefile and reading it as if it where in this makefile. The extra cool thing
#	is, if the planned included makefile does not exists, assuming you have a
#	a rule to build that make file, make will go ahead and make the "sub makefile"
#	and then actually include it! Pretty darn cool
#	Also, I think that no matter what, this is also the first thing to be run
#	in the makefile. I mean just run make clean twice consecutively, and I think
#	you can start to piece it together
#rules with just <filename>.o:<filename>.c will run without any recipie
#	and will compile using what I would like to assume, core variables
#	such as $(CC) which choses compiler, and $(CFLAGS) which chooses aditional
#	flags for the compiling
#More on the previous, I also learned that this is finiky and changing the target
#	a little bit to forexample build/<filename>.o will cause it to NOT automatically
#	compile. That is why I ended making a custom python3 script to explicity insert
#	the compiling step
