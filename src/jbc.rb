#!/usr/bin/env ruby

require 'bindata'
require 'pp'

CONSTANT_Class = 7
CONSTANT_Fieldref = 9
CONSTANT_Methodref = 10
CONSTANT_InterfaceMethodref = 11
CONSTANT_String = 8
CONSTANT_Integer = 3
CONSTANT_Float = 4
CONSTANT_Long = 5
CONSTANT_Double = 6
CONSTANT_NameAndType = 12
CONSTANT_Utf8 = 1
CONSTANT_MethodHandle = 15
CONSTANT_MethodType = 16
CONSTANT_InvokeDynamic = 18

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
   constant_class_info CONSTANT_Class
   constant_fieldref_info CONSTANT_Fieldref
   constant_Methodref_info CONSTANT_Methodref
   constant_interface_Methodref_info CONSTANT_InterfaceMethodref
   constant_string_info CONSTANT_String
   constant_integer_info CONSTANT_Integer
   constant_float_info CONSTANT_Float
   constant_long_info CONSTANT_Long
   constant_double_info CONSTANT_Double
   constant_name_and_type_info CONSTANT_NameAndType
   constant_utf8_info CONSTANT_Utf8
   constant_method_handle_info CONSTANT_MethodHandle
   constant_method_type_info CONSTANT_MethodType
   constant_invoke_dynamic_info CONSTANT_InvokeDynamic
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
# PP.pp(cfex.constant_pool)
PP.pp(cfex.constant_pool[12].info.bytes)
