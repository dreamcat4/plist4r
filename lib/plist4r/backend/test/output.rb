
require 'plist4r/backend/test/harness'

module Plist4r
  class Backend
    module Test
      class Output

        def haml
          @haml ||= <<-'EOC'
%h1 Backend Test Matrix
%div
  %h3 Performance Results
  %p A test performed 10 times each with non-flat (nested) plist structure of 1144 string keys.
  %p Real elapsed time is based on a 2GB, 2GHz Intel Core Duo Architecture
  %p Ruby Enterprise Edition (REE) 1.8.7 p248, Mac OS-X 10.6.3
  = @test_harness.results
  
%p
EOC
        end

        def to_s
          require 'haml'
          engine = ::Haml::Engine.new self.haml
          rendered_html_output = engine.render self
        end

        def initialize *args, &blk
          @test_harness = Plist4r::Backend::Test::Harness.new
          @test_harness.run_tests
        end

        def write_html_file
          docs_dir = File.dirname(__FILE__) + "/../../../../lib/plist4r/docs"
          File.open "#{docs_dir}/BackendTestMatrix.html","w" do |o|
            o << to_s
          end
        end

      end
    end
  end
end

