
require 'plist4r/backend/test/data'
require 'benchmark'
require 'plist4r/mixin/ruby_stdlib'
require 'plist4r/mixin/haml4r/table'

module Plist4r

  class Backend
    module Test

      class Harness < Plist4r::Backend
        def initialize *args, &blk

          @backends = Dir.glob(File.dirname(__FILE__) + "/../../backend/*.rb").collect {|b| File.basename(b,".rb") }
          @backends.flatten!
          @backends.uniq!
          @backends = @backends - ["example"]

          @data_types = DataTypes.new
        end

        ReferenceBackends = {
          :from_xml => :libxml4r,
          :to_xml   => :haml,
          :from_binary => :c_f_property_list,
          :to_binary   => :c_f_property_list,
        }

        def reference_backend_for meth
          ReferenceBackends[meth]
        end

        def results
          @results
        end

        def run_tests

          ref_strings = {}
          ref_string_1024 = {}

          cols = [:from, :to].size + [:xml, :binary].size
          rows = @backends.size

          t = Haml4r::Table.new :size => [0..cols-1, 0..rows-1]
          t.col_header.size [0..cols-1, 0]
          t.row_header.size [0, 0..rows-1]

          bhi = 0
          @backends.each do |b_sym|
            t.row_header.cell(0, bhi).content = "#{b_sym}"
            bhi += 1
          end

          chi = 0
          [:xml, :binary].each do |fmt|
            [:from, :to].each do |op|
              t.col_header.cell(chi, 0).content = ":#{op}_#{fmt}"
              chi += 1
            end
          end
          # puts t.inspect

          cgi = 0
          [:xml, :binary].each do |fmt|
            
            # setup reference test data
            api_sym = "to_#{fmt}".to_sym
            ref_strings[fmt] = Plist4r::OrderedHash.new
            @data_types.plists.each_pair do |key,plist|
              plist.backends [reference_backend_for(api_sym)]
              ref_strings[fmt][key] = plist.send(api_sym)
            end

            @data_types.plist_1024.backends [reference_backend_for(api_sym)]
            ref_string_1024[fmt] = @data_types.plist_1024.send(api_sym)


            ri = 0
            @backends.each do |b_sym|
              ci = cgi

              # puts b_sym
              backend = eval "::Plist4r::Backend::#{b_sym.to_s.camelcase}"

              if backend.respond_to? "from_#{fmt}"
                ref_strings[fmt].each_pair do |sym,string|
                  begin
                    plist_result = Plist4r.new :backends => [b_sym], :from_string => string                
                    if @data_types.plists[sym].to_hash == plist_result.to_hash
                      # puts "match, #{b_sym}, #{sym}"
                    else
                      puts "fail, #{b_sym}, #{sym}"
                    end
                  rescue
                    puts "fail, #{b_sym}, #{sym} - exception"
                    # add fail sym to list of failed data tests
                  end
                end
                time = Benchmark.measure { plist_result = Plist4r.new :backends => [b_sym], :from_string => ref_string_1024[fmt] }.real
                tms = (time*1000).round(1).to_s
                # puts "  :from_#{fmt} - time for 1024 keys = " + (time*1000).round(1).to_s + " ms"
                t.cell(ci, ri).content = "#{tms} ms"
                
              else
                # puts "  not implemented, :from_#{fmt}"
                t.cell(ci, ri).content = "n/a"
              end
              ci += 1


              if backend.respond_to? "to_#{fmt}"
                @data_types.plists.each_pair do |sym,ref_plist|
                    begin
                      plist = Plist4r.new :backends => [b_sym]
                      plist.instance_eval "@hash = ref_plist.to_hash"

                      plist_gen_from = Plist4r.new :from_string => plist.send("to_#{fmt}"),
                                        :backends => [reference_backend_for("from_#{fmt}".to_sym)]

                      if plist_gen_from.to_hash == plist.to_hash
                          # puts "match, #{b_sym}, #{sym}"
                      else
                        puts "fail, #{b_sym}, #{sym}"
                      end
                    rescue
                      puts "fail, #{b_sym}, #{sym} - exception"
                      # add fail sym to list of failed data tests
                    end
                  end
                  plist = Plist4r.new :backends => [b_sym]
                  plist_1024 = @data_types.plist_1024
                  plist.instance_eval "@hash = plist_1024.to_hash"
                  time = Benchmark.measure { eval "plist.to_#{fmt}" }.real
                  tms = (time*1000).round(1).to_s
                  # puts "  :to_#{fmt}   - time for 1024 keys = " + (time*1000).round(1).to_s + " ms"
                  t.cell(ci, ri).content = "#{tms} ms"

              else
                # puts "  not implemented, :to_#{fmt}"
                t.cell(ci, ri).content = "n/a"
              end

              # puts ""
              ri += 1
            end

            cgi += 2
          end


          puts t.inspect
          @results = t
        end



      end
    end
  end
end
