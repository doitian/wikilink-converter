require 'wikilink/converter/namespace'
require 'wikilink/converter/utils'

module Wikilink
  class Converter
    # Site converter
    class Site
      include ArgumentExtractor
      CURRENT_SITE_NAME = ''
      DEFAULT_NAMESPACE = ::Wikilink::Converter::Namespace::DEFAULT_NAME

      attr_reader :options

      def initialize(options = {})
        @options = options
        is_current_site = @options[:name].to_s == CURRENT_SITE_NAME
        @options[:external] = !is_current_site unless @options.key?(:external)
        @options[:prefix] ||= '/' if is_current_site
        @namespace_converters = {}

        on_namespace(DEFAULT_NAMESPACE)
        
        yield self if block_given?
      end

      def on_namespace(*args, &block)
        namespace, converter, options = extract_arguments(*args)
        namespace = DEFAULT_NAMESPACE if namespace.to_s.empty?
        
        converter ||= namespace_converter(namespace)
        if converter.nil?
          # do not add new handler if there's a instance method can handle it,
          # except that user passes a block to override it
          if block || instance_method_converter(namespace).nil?
            converter = ::Wikilink::Converter::Namespace
            converter = ::Wikilink::Converter::Namespace::Default if !block && namespace == DEFAULT_NAMESPACE
          end
        end

        if converter.is_a?(Class)
          options = default_options_for_namespace.merge(options)
          options[:name] ||= namespace
          converter = converter.new(options)
        end

        if converter.respond_to?(:config) && block
          converter.config(&block)
        end

        set_namespace_converter namespace, converter if converter
        self
      end
      alias_method :on, :on_namespace
      alias_method :namespace, :on_namespace

      def on_default_namespace(*args, &block)
        on_namespace(DEFAULT_NAMESPACE, *args, &block)
      end
      alias_method :default_namespace, :on_default_namespace

      def run(colon, namespace, path, name, current_page)
        if converter = namespace_converter(namespace)
          converter.run(colon, path, name, current_page)
        elsif converter = instance_method_converter(namespace)
          converter.call(colon, path, name, current_page)
        end
      end

      protected
      def html_class
        [options[:class], ('external' if options[:external])]
      end

      private
      def namespace_converter(namespace)
        namespace = namespace.to_s.downcase
        @namespace_converters[namespace]
      end

      def instance_method_converter(namespace)
        namespace = namespace.to_s.downcase
        try_message = "on_namespace_#{namespace}".to_sym
        method(try_message) if respond_to?(try_message)
      end

      def set_namespace_converter(namespace, converter)
        @namespace_converters[namespace] = converter
      end
      
      def default_options_for_namespace
        opts = @options.dup
        opts.delete :name
        opts[:site_name] = @options[:name]

        opts
      end
    end
  end
end
