require 'wikilink/converter/utils'

module Wikilink
  class Converter
    # Namespace converter
    class Namespace
      include LinkHelper

      DEFAULT_NAME = ''

      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def config(&block)
        @block = block
        self
      end

      def run(colon, path, name, current_page)
        if @block
          instance_exec(colon, path, name, current_page, &@block)
        end
      end

      class Default < Namespace
        def run(colon, path, name, current_page)
          return super if @block

          path, fragment = path.split('#', 2)
          path, query = path.split('?', 2)

          fragment = '#' + fragment if fragment
          query = '?' + query if query

          url = to_url(path, fragment, query)

          link_to(name, url, :class => html_class)
        end

        def to_url(path, fragment, query)
          if path.nil? || path.empty?
            [query, fragment].join
          else
            [options[:prefix], path, options[:suffix], query, fragment].join
          end
        end
      end

      protected
      def html_class
        [options[:class], ('external' if options[:external])]
      end
    end
  end
end
