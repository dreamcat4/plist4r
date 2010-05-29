
module Plist4r
	module Haml
    module CssAttributes
      Attributes = %w[ css_class css_id css_style ]
    end

    module HamlObject
      def haml
        @haml ||= <<-'EOC'
= super
EOC
      end

      def to_s
        require 'haml'
        engine = ::Haml::Engine.new self.haml
        rendered_html_output = engine.render self
      end
    end

  end
end
