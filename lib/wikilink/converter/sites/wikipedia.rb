require 'wikilink/converter/site'

module Wikilink
  class Converter
    module Sites
      class Wikipedia < Wikilink::Converter::Site
        def initialize(options = {})
          options[:lang] ||= 'en'
          if options[:name] == CURRENT_SITE
            options[:prefix] ||= '/wiki/'
          else
            options[:prefix] ||= "http://#{options[:lang]}.wikipedia.org/wiki/"
          end

          super(options)
        end
      end
    end
  end
end
