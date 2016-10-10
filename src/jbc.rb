#!/usr/bin/env ruby

require 'bindata'
require 'pp'

$_constant_class = 7
$_constant_fieldref = 9
$_constant_methodref = 10
$_constant_interfacemethodref = 11
$_constant_string = 8
$_constant_integer = 3
$_constant_float = 4
$_constant_long = 5
$_constant_double = 6
$_constant_nameandtype = 12
$_constant_utf8 = 1
$_constant_methodhandle = 15
$_constant_methodtype = 16
$_constant_invokedynamic = 18

class ConstantClassInfo < BinData::Record
  uint16be :name_index
end

class ConstantFieldrefInfo < BinData::Record
  uint16be :class_index
  uint16be :name_and_type_index
end

class ConstantMethodrefInfo < BinData::Record
  uint16be :class_index
  uint16be :name_and_type_index
end

class ConstantInterfaceMethodrefInfo < BinData::Record
  uint16be :class_index
  uint16be :name_and_type_index
end

class ConstantStringInfo < BinData::Record
  uint16be :string_index
end

class ConstantIntegerInfo < BinData::Record
  uint32be :bytes
end

class ConstantFloatInfo < BinData::Record
  uint32be :bytes
end

class ConstantLongInfo < BinData::Record
  uint32be :high_bytes
  uint32be :low_bytes
end

class ConstantDoubleInfo < BinData::Record
  uint32be :high_bytes
  uint32be :low_bytes
end

class ConstantNameAndTypeInfo < BinData::Record
  uint16be :name_index
  uint16be :descriptor_index
end

class ConstantUtf8Info < BinData::Record
  uint16be :len
  string :bytes, :read_length => :len
end

class ConstantMethodHandleInfo < BinData::Record
  uint8be :reference_kind
  uint16be :reference_index
end

class ConstantMethodTypeInfo < BinData::Record
  uint16be :descriptor_index
end

class ConstantInvokeDynamicInfo < BinData::Record
  uint16be :bootstrap_method_attr_index
  uint16be :name_and_type_index
end

class AttributeInfo < BinData::Array
  uint16be :attribute_name_index
  uint32be :attribute_length
  array :info, :type => :uint8, :initial_length => :attribute_length
end

class CPInfo < BinData::Array
  uint8 :tag
  choice :info, :selection => :tag do
   constant_class_info $_constant_class
   constant_fieldref_info $_constant_fieldref
   constant_methodref_info $_constant_methodref
   constant_interface_methodref_info $_constant_interfacemethodref
   constant_string_info $_constant_string
   constant_integer_info $_constant_integer
   constant_float_info $_constant_float
   constant_long_info $_constant_long
   constant_double_info $_constant_double
   constant_name_and_type_info $_constant_nameandtype
   constant_utf8_info $_constant_utf8
   constant_method_handle_info $_constant_methodhandle
   constant_method_type_info $_constant_methodtype
   constant_invoke_dynamic_info $_constant_invokedynamic
  end
end

class FieldInfo < BinData::Array
  endian :big
  uint16 :access_flags
  uint16 :name_index
  uint16 :descriptor_index
  uint16 :attributes_count
  attribute_info :attributes, :initial_length => :attributes_count
end

class MethodInfo < BinData::Array
  endian :big

  uint16 :access_flags
  uint16 :name_index
  uint16 :descriptor_index
  uint16 :attributes_count
  attribute_info :attributes, :initial_length => :attributes_count
end

class ClassFileEx < BinData::Record
  endian :big

  uint32 :magic
  uint16 :minor_version
  uint16 :major_version
  uint16 :constant_pool_count
  cp_info :constant_pool, :initial_length => lambda { constant_pool_count - 1 }
  uint16 :access_flags
  uint16 :this_class
  uint16 :super_class
  uint16 :interfaces_count
  array :interfaces, :type => :uint16, :initial_length => :interfaces_count
  uint16 :fields_count
  field_info :fields_, :initial_length => :fields_count
  uint16 :methods_count
  method_info :methods_, :initial_length => :methods_count
  uint16 :attributes_count
  attribute_info :attributes, :initial_length => :attributes_count
end

def get_name(cf)
    cf.constant_pool
end

io = File.open("../resources/Foo.class")
# BinData::trace_reading do
#   ClassFileEx.read(io)
# end
# io.rewind
cfex = ClassFileEx.read(io)
puts "Classfile #{File.absolute_path(io)}"
puts "  Last modified #{io.mtime}; size #{io.size}"
puts "  MD5 checksum " + `md5 -q #{File.absolute_path(io)}`
puts "  Compiled from XXX"
puts "class XXX"
puts "  minor version: #{cfex.minor_version}"
puts "  major version: #{cfex.major_version}"
puts "  flags: #{cfex.access_flags}"

puts "magic: 0x%X" % cfex.magic
puts "attributes: #{cfex.attributes}"
PP.pp(cfex.constant_pool)
