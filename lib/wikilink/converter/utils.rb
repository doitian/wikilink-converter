require 'cgi'
require 'uri'

module Wikilink
  class Converter
    module ArgumentExtractor
      def extract_arguments(*args)
        options = {}
        options = args.pop if args.last.is_a?(Hash)
        name = args.shift

        if name.nil? || name.is_a?(String) || name.is_a?(Symbol)
          name = name.to_s
          converter = args.shift
        else
          converter = name
          name = nil
        end

        throw ArgumentError, "too many arguments" unless args.empty?

        [name, converter, options]
      end
    end

    module LinkHelper
      def link_to(name, url, attributes = {})
        attributes[:class] = Array(attributes[:class]).flatten.join(' ').split.uniq.join(' ')
        attributes.delete(:class) if attributes[:class].empty?
        attributes = attributes.inject('') do |memo, (key, value)|
          memo + key.to_s + '="' + CGI.escape_html(value) + '" '
        end
        url, fragment = url.split('#', 2)
        if fragment
          url << '#' + URI.encode(fragment, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        end

        %Q{<a #{attributes}href="#{url}">#{CGI.escape_html name}</a>}
      end
    end

    module HTMLAttributes
      def html_class(extra_classes = nil)
        classes = []
        if respond_to? :options
          classes << options[:class]
          classes << 'external' if options[:external]
        end

        classes << extra_classes if extra_classes

        classes.flatten.join(' ').split.uniq.join(' ')
      end
    end
  end
end
