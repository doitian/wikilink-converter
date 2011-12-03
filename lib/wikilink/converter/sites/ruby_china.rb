require 'wikilink/converter/site'
require 'wikilink/converter/utils'

module Wikilink
  class Converter
    module Sites
      class RubyChina < Wikilink::Converter::Site
        include Wikilink::Converter::LinkHelper

        def initialize(options = {})
          if options[:name] == CURRENT_SITE
            options[:domain] ||= '/'
          else
            options[:domain] ||= 'http://ruby-china.org/'
          end
          options[:prefix] = "#{options[:domain]}wiki/"

          super(options)
        end

        def on_namespace_topic(colon, path, name, current_page)
          path = "#{options[:domain]}topics/#{path}"
          link_to name, path, :class => html_class
        end

        def on_namespace_node(colon, path, name, current_page)
          path = "#{options[:domain]}topics/node#{path}"
          link_to name, path, :class => html_class
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
