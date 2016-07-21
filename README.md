# shinypancake
What started as an idea of writing a stack-based language turned into a Java
class file parser and `javap` clone.

# How to Use
Currently this just is a hard-coded test program, essentially. It reads in the
file at [resources/Foo.class]() and parses it, outputting some information about
the file. Currently the output isn't very useful, but it will eventually
(ideally) be nearly identical to the output of running `javap -c -verbose
*.class`.

# Why
I've never written more than about a dozen lines of Ruby and I thought it would
be neat. I also needed to become more familiar with Java bytecode and the
structure of Java class files for another ongoing project in relation to
intermediate representations of high level languages.

# Goals
Ideally the output will be (nearly) identically to the output of `javap -c
-verbose *.class`. If I write the code reasonably well enough, it would be a
potential alternative learning tool for understanding how Java class files are
structured. Reading through the current `javap` implementation can be difficult
due to the user being unfamiliar with Java, as well as the general cruftiness of
the implementation.

Another potential goal is to have the ability to write out the class file
information in different ways, potentially focusing on easy consumption for
other programs.

Along with the last potential goal, having the ability to read in the output of
`javap -c -verbose Foo.class` and recreate the original Foo.class file could be
nice. There are assemblers for the JVM instruction set, such as Jasmin and
Krakatau, but they have their own syntax that differs from the structure of the
output of `javap`. I don't know of any practical reason to, but this would allow
for you to write an "assembly" version of a class file in the same (or nearly
the same, I can't imagine requiring the user to build the constant pool or
declare the offsets by hand, but could allow it either way, I suppose). Again,
not that this has any real advantages over existing tools mentioned above, but
why not, right?
