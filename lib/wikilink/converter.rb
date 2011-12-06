require 'forwardable'
require 'wikilink/converter/site'
require 'wikilink/converter/utils'

module Wikilink
  # Convert `[[Wikilink]]` to HTML
  #
  # The real work is handed over to registered handlers through {#on}.
  #
  # The parsing rules
  # -----------------
  #
  # - `[[Wikilink]]` should be in one line, otherwise it is ignored.
  # - `\[[Wikilink]]` is escaped and converted to `[[Wikilink]]`.
  # - `[[action:arg]]` triggers handler registered on **action**. **arg** is passed as
  #   first argument to the handler. **arg** can contains colons.
  # - `[[:action:arg]]` is the same with `[[action:arg]]`, except that `true` is
  #   passed as the second argument to handler to indicate a prefix colon
  #   exists. It is useful for resources like image, where no colon version
  #   inserts the image and colon version inserts the link.
  # - `[[Wikilink]]` is identical with `[[page:Wikilink]]`, i.e., the default
  #   action is **page**.
  class Converter
    extend Forwardable
    include ArgumentExtractor
    CURRENT_SITE = ::Wikilink::Converter::Site::CURRENT_SITE_NAME

    # Setup a converter. Handlers can be registered in block directly. If no
    # handler is registered on **page**, a default handler
    # Wikilink::Converter::Page is created with the given `options`.
    #
    # @param [Hash] options options for Wikilink::Converter::Page
    def initialize(options = {})
      @site_converts = {}
      @action_handlers = {}
      @options = options

      site(CURRENT_SITE, @options)
      yield self if block_given?
    end

    def run(text, run_options = {})
      text.gsub(/(^|.)\[\[(.*?[^:])\]\]/) do |match|
        prefix, inner = $1, $2.strip
        if prefix == '\\'
          match[1..-1]
        else
          if inner.start_with?(':')
            colon = ':'
            inner = inner[1..-1]
          end
          link, name = inner.split('|', 2)
          path, namespace, site = link.split(':', 3).reverse

          if site.to_s.empty? && !namespace.to_s.empty?
            # if namespace is a valid site name, use it as site
            if site_converter(namespace)
              site = namespace
              namespace = nil
            end
          end
          
          if name.to_s.empty?
            name = resolve_name(inner, run_options)
          end

          # ignore malformed wikilink
          if valid?(site, namespace, path)
            run_options = run_options.merge(path: path, name: name, colon: colon)
            result = convert_link(site, namespace, run_options)
            result ? ($1 + result) : match
          else
            match
          end
        end
      end
    end

    def execute(text)
      text.gsub(/(^|.)\{\{(.*?[^:])\}\}/) do |match|
        prefix, inner = $1, $2.strip
        if prefix == '\\'
          match[1..-1]
        else
          action, arg = inner.split(':', 2)
          result = convert_action(action, arg)
          result ? ($1 + result) : match
        end
      end
    end

    def_delegator :@current_site_converter, :namespace
    def_delegator :@current_site_converter, :default_namespace

    def site(*args)
      site, converter, options = extract_arguments(*args)
      options = @options.merge(options)
      site = CURRENT_SITE if site.to_s.empty?

      converter ||= site_converter(site) || Wikilink::Converter::Site
      if converter.is_a?(Class)
        options[:name] ||= site
        converter = converter.new(options)
      end

      yield converter if block_given?

      set_site_converter site, converter
      self
    end

    def current_site(*args, &block)
      site(CURRENT_SITE, *args, &block)
    end

    def action(name, &block)
      @action_handlers[name.to_s.downcase] = block
      self
    end

    private
    def site_converter(site)
      site = site.to_s.downcase
      site == CURRENT_SITE ? @current_site_converter : @site_converts[site]
    end

    def set_site_converter(site, converter)
      site = site.to_s.downcase
      if site == CURRENT_SITE
        @current_site_converter = converter
      else
        @site_converts[site] = converter
      end
    end
    
    def convert_action(action, argument)
      handler = @action_handlers[action.to_s.downcase]
      handler.call(argument) if handler
    end

    def convert_link(site, namespace, run_options)
      converter = site_converter(site)
      converter.run(namespace, run_options) if converter
    end

    # TODO: relative
    # TODO: ruby (computer) -> ruby
    # TODO: Shanghai, China -> Shanghai
    def resolve_name(inner_text, run_options)
      if inner_text.end_with?('|')
        inner_text.chop.chomp('/').split(%r{[:/]}, 2).last
      else
        inner_text
      end
    end

    INVALID_NAME_REGEXP = /[^[[:alnum:]][[:blank]]_-]/
    INVALID_PATH_REGEXP = /^[\[\]]/
    def valid?(site, namespace, path)
      return false if site =~ INVALID_NAME_REGEXP
      return false if namespace =~ INVALID_NAME_REGEXP
      return false if path =~ INVALID_PATH_REGEXP
      return true
    end
  end
end
