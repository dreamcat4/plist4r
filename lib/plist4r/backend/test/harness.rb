
require 'plist4r/backend/test/data_types'
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
          # :from_binary => :ruby_cocoa,
          # :to_binary   => :ruby_cocoa,
          :from_binary => :osx_plist,
          :to_binary   => :osx_plist,
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

          # t.css_style = "border-spacing: 5px;"
          c2 = "#F5F5FF"
          c1 = "#FAFAFA"
          cpv = 5
          cph = 15
          t.cells.css_style            = "padding: #{cpv}px; padding-left: #{cph}px; padding-right: #{cph}px; background-color: #{c1}; text-align: center"
          t.col_header.cells.css_style = "padding: #{cpv}px; padding-left: #{cph}px; padding-right: #{cph}px; background-color: #{c2}; text-align: center"
          t.row_header.cells.css_style = "padding: #{cpv}px; padding-left: #{cph}px; padding-right: #{cph}px; background-color: #{c2}; text-align: right"

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

          cgi = 0
          [:xml, :binary].each do |fmt|
            puts ""
            puts fmt.inspect
            puts ""
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

              backend = eval "::Plist4r::Backend::#{b_sym.to_s.camelcase}"
              if backend.respond_to? "from_#{fmt}"
                failures = []
                ref_strings[fmt].each_pair do |sym,string|
                  begin
                    plist_result = Plist4r.new :backends => [b_sym], :from_string => string                
                    if @data_types.plists[sym].to_hash == plist_result.to_hash
                      puts "match, #{b_sym}, #{sym}" if sym == :data
                      # puts @data_types.plists[sym].hash.inspect
                      # puts plist_result.hash.inspect
                      # puts @data_types.plists[sym].to_hash["DataKeyW"].hash.inspect
                      # puts plist_result.to_hash["DataKeyW"].hash.inspect
                    else
                      puts "fail, #{b_sym}, #{sym}" if sym == :data

                      if sym == :data
                        puts "expected:"
                        puts @data_types.plists[sym].hash.inspect
                        puts @data_types.plists[sym].to_hash.inspect
                        # puts @data_types.plists[sym].to_hash["DataKeyW"].read.inspect
                        # @data_types.plists[sym].to_hash["DataKeyW"].rewind
                        # puts @data_types.plists[sym].to_hash["DataKeyW"].read.inspect
                        puts "got:"
                        puts plist_result.hash.inspect
                        puts plist_result.to_hash.inspect
                        # puts plist_result.to_xml if b_sym == "ruby_cocoa"
                      end
                    end
                  rescue
                    puts "fail, #{b_sym}, #{sym} - exception"
                    failures << sym
                  end
                end
                if failures.empty?
                  time = Benchmark.measure { plist_result = Plist4r.new :backends => [b_sym], :from_string => ref_string_1024[fmt] }.real
                  tms = (time*1000).round(1).to_s
                  # puts "  :from_#{fmt} - time for 1024 keys = " + (time*1000).round(1).to_s + " ms"
                  t.cell(ci, ri).content = "#{tms} ms"
                else
                  t.cell(ci, ri).content = "Failed #{failures.inspect}"
                end
                
              else
                # puts "  not implemented, :from_#{fmt}"
                t.cell(ci, ri).content = "n/a"
              end
              ci += 1


              if backend.respond_to? "to_#{fmt}"
                failures = []
                @data_types.plists.each_pair do |sym,ref_plist|
                    begin
                      plist = Plist4r.new :backends => [b_sym]
                      plist.instance_eval "@hash = ref_plist.to_hash"
                      
                      # puts "was: to_#{fmt}, #{b_sym} - #{sym.inspect}" if [:data, :bool].include?(sym)
                      # puts plist.to_binary.inspect if [:data, :bool].include?(sym)
                      # puts "should be:"
                      # 
                      # puts "sepr char: #{plist.to_binary[20].chr.inspect}, last int #{plist.to_binary[20].inspect}," if sym == :data
                      # puts "last char: #{plist.to_binary[plist.to_binary.length-1].chr.inspect}, last int #{plist.to_binary[plist.to_binary.length-1].inspect}," if sym == :data

                      plist_gen_from = Plist4r.new :from_string => plist.send("to_#{fmt}"),
                                        :backends => [reference_backend_for("from_#{fmt}".to_sym)]

                      if plist_gen_from.to_hash == plist.to_hash
                          puts "match, #{b_sym}, #{sym}" if sym == :data
                          # puts plist.hash.inspect
                          # puts plist_gen_from.hash.inspect
                          if sym == :data
                            if b_sym == "ruby_cocoa"
                              # plist_gen_from.to_hash.keys.each do |key|
                              # puts "point a"
                              # plist.to_hash.keys.each do |key|
                              #   puts "key hash mismatch: #{key.inspect}" unless plist.to_hash[key].hash == plist_gen_from.to_hash[key].hash
                              # end
                              # puts "key hash mismatch: keys differ" unless plist.to_hash.keys == plist_gen_from.to_hash.keys
                              # puts "point b"
                              # puts plist.to_hash["DataKeyW"].hash.inspect
                              # puts plist_gen_from.to_hash["DataKeyW"].hash.inspect


                              # puts "expected:"
                              # puts plist.to_hash.inspect
                              # puts "got:"
                              # puts plist_gen_from.to_hash.inspect
                            end
                          end
                      else
                        puts "fail, #{b_sym}, #{sym}" if sym == :data
                        if sym == :data
                          puts "expected:"
                          puts plist.to_hash.inspect
                          puts "got:"
                          puts plist_gen_from.to_hash.inspect
                        end
                      end
                    rescue
                      puts "fail, #{b_sym}, #{sym} - exception"

                      begin
                        # what went wrong?
                        if fmt == :binary
                          puts "to_#{fmt}, #{b_sym} - for #{sym.inspect}. (1)was, (2)should be:"
                          plist = Plist4r.new :backends => [b_sym]
                          plist.instance_eval "@hash = ref_plist.to_hash"
                          puts plist.to_binary.inspect
                        
                          plist = Plist4r.new :backends => [ReferenceBackends["to_#{fmt}".to_sym]]
                          plist.instance_eval "@hash = ref_plist.to_hash"
                          puts plist.to_binary.inspect
                        end
                      rescue
                      end
                      failures << sym
                    end
                  end
                  if failures.empty?
                    plist = Plist4r.new :backends => [b_sym]
                    plist_1024 = @data_types.plist_1024
                    plist.instance_eval "@hash = plist_1024.to_hash"
                    time = Benchmark.measure { eval "plist.to_#{fmt}" }.real
                    tms = (time*1000).round(1).to_s
                    # puts "  :to_#{fmt}   - time for 1024 keys = " + (time*1000).round(1).to_s + " ms"
                    t.cell(ci, ri).content = "#{tms} ms"
                  else
                    t.cell(ci, ri).content = "Failed #{failures.inspect}"
                  end
              else
                # puts "  not implemented, :to_#{fmt}"
                t.cell(ci, ri).content = "n/a"
              end

              # puts ""
              ri += 1
            end

            cgi += 2
          end
          puts ""
          puts "REFERENCE BACKENDS"
          puts "=================="
          ReferenceBackends.each do |sym,b_sym|
            puts "#{sym.inspect} generated by #{b_sym.inspect}"
          end
          puts ""
          puts t.inspect
          @results = t
        end



      end
    end
  end
end
