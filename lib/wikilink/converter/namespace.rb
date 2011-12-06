require 'wikilink/converter/utils'

module Wikilink
  class Converter
    # Namespace converter
    class Namespace
      include LinkHelper
      include HTMLAttributes

      DEFAULT_NAME = ''

      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def config(&block)
        @block = block
        self
      end

      def run(run_options)
        if @block
          instance_exec(run_options, &@block)
        end
      end

      class Default < Namespace
        def run(run_options)
          return super if @block

          path = run_options[:path].to_s
          path, fragment = path.split('#', 2)
          path, query = path.split('?', 2)

          fragment = '#' + fragment if fragment
          query = '?' + query if query

          url = to_url(path, fragment, query)

          link_to(run_options[:name], url, :class => html_class(run_options[:class]))
        end

        def to_url(path, fragment, query)
          if path.nil? || path.empty?
            [query, fragment].join
          else
            [options[:prefix], path, options[:suffix], query, fragment].join
          end
        end
      end
    end
  end
end
