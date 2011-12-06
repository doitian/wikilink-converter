require 'wikilink/converter/site'
require 'wikilink/converter/utils'

module Wikilink
  class Converter
    module Sites
      class RubyChina < Wikilink::Converter::Site
        include Wikilink::Converter::LinkHelper
        include Wikilink::Converter::HTMLAttributes

        def initialize(options = {})
          if options[:name] == CURRENT_SITE
            options[:domain] ||= '/'
          else
            options[:domain] ||= 'http://ruby-china.org/'
          end
          options[:prefix] = "#{options[:domain]}wiki/"

          super(options)
        end

        def run_namespace_topic(run_options)
          path = "#{options[:domain]}topics/#{run_options[:path]}"
          link_to run_options[:name], path, :class => html_class(run_options[:class])
        end

        def run_namespace_node(run_options)
          path = "#{options[:domain]}topics/node#{run_options[:path]}"
          link_to run_options[:name], path, :class => html_class(run_options[:class])
        end
      end

      class RubyTaiwan < RubyChina
        def initialize(options = {})
          if options[:name] != CURRENT_SITE
            options[:domain] ||= 'http://ruby-taiwan.org/'
          end

          super(options)
        end
      end
    end
  end
end
