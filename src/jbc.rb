#!/usr/bin/env ruby

require 'digest'
require 'bindata'

$CONSTANT_Class = 7;
$CONSTANT_Fieldref = 9;
$CONSTANT_Methodref = 10;
$CONSTANT_InterfaceMethodref = 11;
$CONSTANT_String = 8;
$CONSTANT_Integer = 3;
$CONSTANT_Float = 4;
$CONSTANT_Long = 5;
$CONSTANT_Double = 6;
$CONSTANT_NameAndType = 12;
$CONSTANT_Utf8 = 1;
$CONSTANT_MethodHandle = 15;
$CONSTANT_MethodType = 16;
$CONSTANT_InvokeDynamic = 18;

class CONSTANT_Class_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Class
  end
  attr_accessor :name_index
end

class CONSTANT_Fieldref_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Fieldref
  end
  attr_accessor :class_index
  attr_accessor :name_and_type_index
end

class CONSTANT_Methodref_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Methodref
  end

  attr_accessor :class_index
  attr_accessor :name_and_type_index
end

class CONSTANT_InterfaceMethodref_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_InterfaceMethodref
  end
  attr_accessor :class_index
  attr_accessor :name_and_type_index
end

class CONSTANT_String_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_String
  end
  attr_accessor :string_index
end

class CONSTANT_Integer_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Integer
  end
  attr_accessor :bytes
end

class CONSTANT_Float_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Float
  end
  attr_accessor :bytes
end

class CONSTANT_Long_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Long
  end
  attr_accessor :high_bytes
  attr_accessor :low_bytes
end

class CONSTANT_Double_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Double
  end
  attr_accessor :high_bytes
  attr_accessor :low_bytes
end

class CONSTANT_NameAndType_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_NameAndType
  end
  attr_accessor :name_index
  attr_accessor :descriptor_index
end

class CONSTANT_Utf8_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_Utf8
    bytes = []
  end
  attr_accessor :length
  attr_accessor :bytes
end

class CONSTANT_MethodHandle_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_MethodHandle
  end
  attr_accessor :reference_kind
  attr_accessor :reference_index
end

class CONSTANT_MethodType_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_MethodType
  end
  attr_accessor :descriptor_index
end

class CONSTANT_InvokeDynamic_info
  attr_accessor :tag
  def initialize
    @tag = $CONSTANT_InvokeDynamic
  end
  attr_accessor :bootstrap_method_attr_index
  attr_accessor :name_and_type_index
end

# END CONSTANT_*_info CLASSES

class ClassFile
  attr_accessor :magic
  attr_accessor :minor_version
  attr_accessor :major_version
  attr_accessor :constant_pool_count
  attr_accessor :constant_pool
  attr_accessor :access_flags
  attr_accessor :this_class
  attr_accessor :super_class
  attr_accessor :interfaces_count
  attr_accessor :interfaces
  attr_accessor :fields_count
  attr_accessor :fields
  attr_accessor :methods_count
  attr_accessor :methods
  attr_accessor :attributes_count
  attr_accessor :attributes

  def initialize(cf)
    @class_file = File.new(cf)
    @class_file_string = @class_file.read
    @class_file.rewind
    @cf_enum = @class_file.each_byte
    @constant_pool = []
    @interfaces = []
    @fields = []
    @methods = []
    @attributes = []
    @access_flags = []
  end
  
  def read_magic
    # cafebabe = Array.new(4) {@cf_enum.next}
    cafebabe = @class_file.read(4)
    @magic = cafebabe
    #@magic == [0xca, 0xfe, 0xba, 0xbe]
    true
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

  def read_constant_pool
    i = 1;
    while i < @constant_pool_count do # do optional?
      tag = @cf_enum.next
      case tag # read byte (tag)
      when $CONSTANT_Class
        temp = CONSTANT_Class_info.new
        temp.name_index = Array.new(2) { @cf_enum.next}
        @constant_pool << temp
      when $CONSTANT_Fieldref
        temp = CONSTANT_Fieldref_info.new
        temp.class_index = Array.new(2) { @cf_enum.next }
        temp.name_and_type_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_Methodref then
        temp = CONSTANT_Methodref_info.new
        temp.class_index = Array.new(2) { @cf_enum.next }
        temp.name_and_type_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_InterfaceMethodref
        temp = CONSTANT_InterfaceMethodref_info.new
        temp.class_index = Array.new(2) { @cf_enum.next }
        temp.name_and_type_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_String
        temp = CONSTANT_String_info.new
        temp.string_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_Integer
        temp = CONSTANT_Integer_info.new
        temp.bytes = Array.new(4) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_Float
        temp = CONSTANT_Float_info.new
        temp.bytes = Array.new(4) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_LONG
        temp = CONSTANT_Long_info.new
        temp.high_bytes = Array.new(4) { @cf_enum.next }
        temp.low_bytes = Array.new(4) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_Double
        temp = CONSTANT_Double_info.new
        temp.high_bytes = Array.new(4) { @cf_enum.next }
        temp.low_bytes = Array.new(4) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_NameAndType
        temp = CONSTANT_NameAndType_info.new
        temp.name_index = Array.new(2) { @cf_enum.next }
        temp.descriptor_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_Utf8
        temp = CONSTANT_Utf8_info.new
        temp.length = Array.new(2) { @cf_enum.next }
        temp.bytes = Array.new(temp.length[-1]) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_MethodHandle
        temp = CONSTANT_MethodHandle_info.new
        temp.reference_kind = Array.new(1) { @cf_enum.next }
        temp.reference_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_MethodType
        temp = CONSTANT_MethodType_info.new
        temp.descriptor_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      when $CONSTANT_InvokeDynamic
        temp = CONSTANT_InvokeDynamic_info.new
        temp.bootstrap_method_attr_index = Array.new(2) { @cf_enum.next }
        temp.name_and_type_index = Array.new(2) { @cf_enum.next }
        @constant_pool << temp
      else
        puts "UNKNOWN BYTECODE: #{tag}"
      end
      i += 1
    end
    true
  end

  def read_access_flags
    acc = Array.new(2) { @cf_enum.next }
    @access_flags = acc[-1]
    true
  end

  def read_this_class
    temp = Array.new(2) { @cf_enum.next }
    @this_class = temp[-1]
    true
  end

  def read_super_class
    temp = Array.new(2) { @cf_enum.next }
    @super_class = temp[-1]
    true
  end

  def read_interfaces_count
    temp = Array.new(2) { @cf_enum.next }
    @interfaces_count = temp[-1]
    true
  end

  def read_interfaces
    unless @interfaces_count == 0
      temp = Array.new(2) { @cf_enum.next }
    end
    @interfaces = []
    true
  end

  def read_file
    Enumerator.new do |foo|
      foo << read_magic
      foo << read_minor_version
      foo << read_major_version
      foo << read_constant_pool_count
      foo << read_constant_pool
      foo << get_access_flags
      foo << read_this_class
      foo << read_super_class
      foo << read_interfaces_count
      foo << read_interfaces
    end
  end

  def get_orig_file
    res_index = 0
    @constant_pool.each_with_index do
      |item, index|
      if item.tag == $CONSTANT_Utf8
        if item.bytes.pack("C*") == "SourceFile" # Does c vs C matter?
          res_index = index + 1
          break
        end
      end
    end
    @constant_pool[res_index].bytes.pack("C*")
  end

  def get_access_flags
    cf = Array.new(2) { @cf_enum.next }
    res = BinData::Int16be.read(cf.pack("C*"))
    # accessors = []
    unless res & 0x0001 == 0
      @access_flags << "ACC_PUBLIC"
    end
    unless res & 0x0010 == 0
      @access_flags << "ACC_FINAL"
    end
    unless res & 0x0020 == 0
      @access_flags << "ACC_SUPER"
    end
    unless res & 0x0200 == 0
      @access_flags << "ACC_INTERFACE"
    end
    unless res & 0x0400 == 0
      @access_flags << "ACC_ABSTRACT"
    end
    unless res & 0x1000 == 0
      @access_flags << "ACC_SYNTHETIC"
    end
    unless res & 0x2000 == 0
      @access_flags << "ACC_ANOTATION"
    end
    unless res & 0x4000 == 0
      @access_flags << "ACC_ENUM"
    end
    true
  end

  attr_reader :cf_enum
  attr_reader :class_file
  attr_reader :class_file_string
end

cf = ClassFile.new("../resources/Foo.class")

cf.class_file.rewind

cf.read_file.each_with_index {
  |f, i| 
  unless f
    puts "ERROR READING FILE~!~!~!!~ (#{i})"
  end
}

puts "Classfile #{File.absolute_path(cf.class_file)}"
puts "  Last modified #{cf.class_file.mtime}; size #{cf.class_file.size}"
puts "  MD5 checksum #{Digest::MD5.new << cf.class_file.read}"
puts "  Compiled from \"#{cf.get_orig_file}\""
puts "class #{cf.this_class}"
puts "  minor version: #{cf.minor_version}"
puts "  major version: #{cf.major_version}"
puts "  flags: #{cf.access_flags}"
puts "Constant pool:"

# puts "MAGIC: #{cf.magic}"
# puts "MINOR_VERSION: #{cf.minor_version}"
# puts "MAJOR_VERSION: #{cf.major_version}"
# puts "CONSTANT_POOL_COUNT: #{cf.constant_pool_count}"
# puts "CONSTANT_POOL:"
cf.constant_pool.each_with_index do
  |cp_info, index|
  puts "\tCP[#{index + 1}]: #{cp_info.tag}"
end
# puts "ACCESS_FLAGS: #{cf.access_flags}"
# puts "THIS_CLASS: #{cf.this_class}"
# puts "SUPER_CLASS: #{cf.super_class}"
# puts "INTERFACES_COUNT: #{cf.interfaces_count}"
# puts "INTERFACES: #{cf.interfaces}"
