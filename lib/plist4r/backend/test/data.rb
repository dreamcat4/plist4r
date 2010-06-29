
module Plist4r
  class Backend
    module Test

      class DataTypes
        # PlistDataTypes = [:bool, :integer, :float, :string, :time, :date_time, :data, :array, :hash]
        # PlistDataTypes =  [:bool, :integer, :float, :string, :time, :date_time, :array, :hash]
        # PlistDataTypes =  [:bool, :integer, :float, :string, :time, :array, :hash, :hash_array_string_integer_bool]

        PlistDataTypes =  [:bool, :integer, :float, :string, :time, :array, :hash]
        # PlistDataTypes =  [:bool, :integer, :float, :string, :time, :array, :hash, :gen_mixed]
        # PlistDataTypes =  [:bool, :integer, :float, :string, :time, :data, :array, :hash]

        def initialize *args, &blk
          
          @plists = Plist4r::OrderedHash.new
          PlistDataTypes.each do |pdt|
            @plist = Plist4r.new
            self.send "gen_#{pdt}"
            @plists[pdt] = @plist
          end
          # puts @plists.keys.inspect
          
          @plist_1024 = gen_plist_1024
        end

        def method_missing meth, *args, &blk
          @plists[meth] if PlistDataTypes.include?(meth)
        end

        def plists
          @plists
        end

        def plist_1024
          @plist_1024
        end

        def gen_bool
          [true,false].each do |bool|
            @plist.set "BoolKey#{bool.to_s.capitalize}", bool
          end
        end
      
        def gen_integer
          (0..9).each do |i|
            @plist.set "IntegerKey#{(65+i).chr}", i
          end
        end
      
        def gen_float
          (0..100).each do |i|
            @plist.set "RealKey#{i}", i.to_f / 100
          end
        end
      
        def gen_string
          (0..25).each do |i|
            @plist.set "StringKey#{(65+i).chr}", "#{(97+i).chr}"*(i+1)
          end
        end
      
        def gen_time
          require 'date'
          (0..25).each do |i|
            @plist.set "DateKey#{(65+i).chr}", Time.parse("2010-04-#{sprintf("%.2i",i+1)}T19:50:01Z")
          end
        end
      
        # def gen_date_time
        #   require 'date'
        #   (0..25).each do |i|
        #     @plist.set "DateKey#{(65+i).chr}", DateTime.parse("2010-04-#{sprintf("%.2i",i+1)}T19:50:01Z")
        #   end
        # end
      
        def gen_data
          # Should be IO.new ... 
          Struct.new("Customer", :name, :id)
          (0..25).each do |i|
            @plist.set "DataKey#{(65+i).chr}", Struct::Customer.new("Dave", "#{(65+i).chr}")
          end
        end
      
        def gen_array
          (0..25).each do |i|
            a = []
            (0..i).each do |j|
              a << "String#{(65+j).chr}"
            end
            @plist.set "ArrayKey#{(65+i).chr}", a
          end
        end
      
        def gen_hash
          (0..25).each do |i|
            h = Plist4r::OrderedHash.new
            (0..i).each do |j|
              h["String#{(65+j).chr}"] = "#{(97+j).chr}"*(j+1)
            end
            @plist.set "HashKey#{(65+i).chr}", h
          end
        end
      
        def gen_mixed
          @plist.edit do
            [true,false].each do |bool|
              set "BoolKey#{bool.to_s.capitalize}", bool
            end
        
            (0..9).each do |i|
              set "IntegerKey#{(65+i).chr}", i
            end
        
            (0..25).each do |i|
              set "StringKey#{(65+i).chr}", "#{(97+i).chr}"*(i+1)
            end
        
            (0..25).each do |i|
              a = []
              (0..i).each do |j|
                a << "String#{(65+j).chr}"
              end
              set "ArrayKey#{(65+i).chr}", a
            end
        
            (0..25).each do |i|
              h = Plist4r::OrderedHash.new
              (0..i).each do |j|
                h["String#{(65+j).chr}"] = "#{(97+j).chr}"*(j+1)
              end
              set "HashKey#{(65+i).chr}", h
            end
          end
        end

        def gen_plist_1024
          @plist_1024 ||= Plist4r.new do
            coarse_multiplier = 18
            (0..coarse_multiplier).each do |i|

              a = []
              (0..25).each do |j|
                a << "String#{(65+j).chr}"
              end
              set "ArrayKey#{i}", a

              h = Plist4r::OrderedHash.new
              (0..25).each do |j|
                h["String#{(65+j).chr}"] = "#{(97+j).chr}"*(j+1)
              end
              set "HashKey#{i}", h
            end
            
            a = []
            (0..11).each do |j|
              a << "String#{(65+j).chr}"
            end
            set "ArrayKeyPad1", a
            
            a = []
            (0..23).each do |j|
              a << "String#{(65+j).chr}"
            end
            set "ArrayKeyPad2", a
          end
          @plist_1024
        end

      end
    end
  end
end
