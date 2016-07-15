#!/usr/bin/env ruby

class ClassFile
  @magic = 0;
  @minor_version = 0;
  @major_version = 0;
  @constant_pool_count = 0;
  def initialize(cf)
    @class_file = File.new(cf)
    @cf_enum = @class_file.each_byte
  end
  def read_magic
    cafebabe = Array.new(4) {@cf_enum.next}
    @magic = cafebabe
    @magic == [0xca, 0xfe, 0xba, 0xbe]
  end
  def read_minor_version
    minor = Array.new(2) {@cf_enum.next}
    # XXX: This is pretty awful, but I'm ignoring the first bits because I can't
    # imagine a minor version greater than 255.
    @minor_version = minor[-1]
    # I don't know the best way to deal with this, but for now it's nice for
    # debugging, I guess.
    true
  end
  def read_major_version
    major = Array.new(2) {@cf_enum.next}
    # XXX: Same issue as above with read_minor_version. A major version greater
    # than 255 seems more realistic though.
    @major_version = major[-1]
    # Again, with above.
    true
  end
  def read_constant_pool_count
    cpc = Array.new(2) {@cf_enum.next}
    # The issue with this is that any non-trivial program will be using more
    # than 255 items, I imagine. A simple hello world with no variables or
    # anything already uses 29. But concatenating the bits efficiently is
    # slightly confusing for me. My first approach will probably just convert
    # both octets to binary strings, smash them together, and then convert the
    # bit string to an integer.
    @constant_pool_count = cpc[-1]
    true
  end
end

cf = ClassFile.new("../resources/Foo.class")

if (cf.read_magic)
  puts "read_magic"
end
if (cf.read_minor_version)
  puts "read minor_version"
end
if (cf.read_major_version)
  puts "read major_version"
end
if (cf.read_constant_pool_count)
  puts "read constant_pool_count"
end
