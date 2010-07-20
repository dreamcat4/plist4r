
require 'plist4r/backend/test/harness'

module Plist4r
  class Backend
    module Test
      class Output

        def haml
          @haml ||= <<-'EOC'
%h1 Backends
%div
  %p Documentation for the Plist4r backend modules - please see <tt><a href="Plist4r/Backend.html" target="_self" title="Plist4r::Backend (class)">Plist4r::Backend</a></tt>
  %h3 Performance
  %p Time elapsed for encoding / decoding a non-flat (nested) plist structure of 1024 keys
  %p Real elapsed time based on - 2GHz Intel Core Duo with 2GB Ram
  %p Ruby Enterprise Edition (REE) 1.8.7 p248, Mac OS-X 10.6.3
  = @test_harness.results
  %p To re-run the backend tests
  %pre{ :class => "code" } $ cd plist4r && rake backend:tests
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
          File.open "#{docs_dir}/Backends.html","w" do |o|
            o << to_s
          end
        end

      end
    end
  end
end

