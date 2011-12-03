require File.expand_path('../../../spec_helper', __FILE__)

describe Wikilink::Converter::Site do
  DEFAULT_NAMESPACE = Wikilink::Converter::Site::DEFAULT_NAMESPACE
  CURRENT_SITE_NAME = Wikilink::Converter::Site::CURRENT_SITE_NAME

  # { subject.foo }.should forward(:bar).to(handler).with(any_args)
  RSpec::Matchers.define :forward do |message|
    match do |block|
      block.call
      @handler.received_message?(message, *@arguments)
    end

    description do
      "forward to message #{message} to #{@handler.inspect}"
    end

    failure_message_for_should do |block|
      <<MESSAGE
expected forward #{message}
      to #{block}
    with #{@arguments.inspect}
MESSAGE
    end

    failure_message_for_should_not do |block|
      <<MESSAGE
expected not forward #{message}
      to #{block}
    with #{@arguments.inspect}
MESSAGE
    end

    chain :with do |*arguments|
      @arguments = arguments
    end

    chain :to do |handler|
      @handler = handler
    end
  end

  shared_examples 'configuring a new instance of class as namespace handler' do |namespace|
    # require setting converter to an instance of Site
    context 'with converter class' do
      class SpecNamespace; end
      define_method :call do |*args|
        if namespace.to_s.empty?
          converter.on_namespace SpecNamespace, *args
        else
          converter.on_namespace namespace, SpecNamespace, *args
        end
      end
      let(:namespace_converter) { double(:namespace_converter) }

      it 'creates a new instance of the specified class' do
        SpecNamespace.should_receive(:new).once
        call
      end

      it 'uses the instance of the class as new namespace converter' do
        SpecNamespace.should_receive(:new).once.and_return(namespace_converter)
        call
        namespace_converter.should_receive(:run).and_return('it works')
        converter.run(':', namespace, 'Home', 'Name', '/').should eq('it works')
      end

      context 'and options' do
        let(:options) { { foo: :bar} }
        it 'creates a new instance of the specified class and options' do
          SpecNamespace.should_receive(:new).once
          call options
        end

        it 'initializes the new instance of the specified class with options' do
          SpecNamespace.should_receive(:new).with(hash_including(foo: :bar)).once
          call options
        end
      end
    end
  end

  let(:default_namespace) { double(:default_namespace).as_null_object }
  let(:namespace) { double(:namespace).as_null_object }
  before { Wikilink::Converter::Namespace::Default.stub(:new) { default_namespace } }

  shared_examples ''
  
  context 'current site' do
    let(:site_name) { CURRENT_SITE_NAME }
    let(:converter) { Wikilink::Converter::Site.new name: site_name }

    describe '#initialize' do
      def initialize_site(&block)
        Wikilink::Converter::Site.new name: site_name, &block
      end

      it 'sets option :prefix to "/"' do
        converter.options[:prefix].should eq('/')
      end
      it 'sets option :external to false' do
        converter.options[:external].should be_false
      end
      it 'sets up default namespace with option :site_name' do
        klass = Wikilink::Converter::Namespace::Default
        klass.should_receive(:new).with(hash_including(site_name: site_name))
        initialize_site
      end
      it 'sets up default namespace with option :name' do
        klass = Wikilink::Converter::Namespace::Default
        klass.should_receive(:new).with(hash_including(name: DEFAULT_NAMESPACE))
        initialize_site
      end
      it 'yields self' do
        initialize_site do |arg|
          arg.should be_a_kind_of(Wikilink::Converter::Site)
        end
      end

      context 'with option :external true' do
        let(:converter) { Wikilink::Converter::Site.new name: site_name, external: true }
        it 'leaves option :external as true' do
          converter.options[:external].should be_true
        end
      end
      context 'with option :prefix "/wiki/"' do
        let(:converter) { Wikilink::Converter::Site.new name: site_name, prefix: '/wiki/' }
        it 'leaves option :prefix as "/wiki/"' do
          converter.options[:prefix].should eq('/wiki/')
        end
      end
    end

    describe '#run' do
      it 'delegates default namespace to Namespace::Default instance' do
        ->{ converter.run(':', DEFAULT_NAMESPACE, 'Home', 'Name', '/') }.
          should forward(:run).to(default_namespace).with(':', 'Home', 'Name', '/')
      end
    end

    describe '#on_default_namespace' do
      it 'is a shortcut of #on_namespace' do
        converter.should_receive(:on_namespace).with(DEFAULT_NAMESPACE, 'arg')
        converter.on_default_namespace 'arg'
      end
    end

    describe '#on_namespace' do
      context 'without any arguments nor block' do
        let(:default_namespace) { double(:default_namespace) }

        it 'does not change the default namespace handler' do
          Wikilink::Converter::Namespace::Default.should_receive(:new).
            once.and_return(default_namespace)
          converter.on_namespace
        end
      end

      context 'with block' do
        it 'configures default namespace with the block' do
          yielded = double('yielded')
          yielded.should_receive(:poke)
          default_namespace.should_receive(:config).and_yield
          converter.on_namespace do
            yielded.poke
          end
        end
      end

      context 'with options' do
        let(:default_namespace) { double(:default_namespace) }

        it 'does not change the default namespace handler' do
          Wikilink::Converter::Namespace::Default.should_receive(:new).
            once.and_return(default_namespace)
          converter.on_namespace foo: :bar
        end
      end

      context 'with default namespace name' do
        let(:default_namespace) { double(:default_namespace) }

        it 'does not change the default namespace handler' do
          Wikilink::Converter::Namespace::Default.should_receive(:new).
            once.and_return(default_namespace)
          converter.on_namespace(DEFAULT_NAMESPACE)
        end
      end
      context 'with other namespace name' do
        let(:name) { 'topics' }
        let(:klass) { Wikilink::Converter::Namespace }

        it 'creates a new Wikilink::Converter::Namespace instance' do
          klass.should_receive(:new)
          converter.on_namespace name
        end
        it 'initializes Wikilink::Converter::Namespace instance with option :site_name' do
          klass.should_receive(:new).with(hash_including(site_name: site_name))
          converter.on_namespace name
        end
        it 'initializes Wikilink::Converter::Namespace instance with option :name' do
          klass.should_receive(:new).with(hash_including(name: name))
          converter.on_namespace name
        end
        it 'uses the instance of Wikilink::Converter::Namespace as new namespace converter' do
          klass.should_receive(:new).and_return(namespace)
          converter.on_namespace name
          namespace.should_receive(:run).and_return('it works')
          converter.run(':', name, 'Home', 'Name', '/').should eq('it works')
        end

        context 'with object' do
          it 'uses that object as new namespace converter' do
            converter.on_namespace name, namespace
            namespace.should_receive(:run).and_return('it works')
            converter.run(':', name, 'Home', 'Name', '/').should eq('it works')
          end
        end

        it_behaves_like 'configuring a new instance of class as namespace handler', 'topics'
      end

      it_behaves_like 'configuring a new instance of class as namespace handler'
      
      context 'with object' do
        it 'uses that object as new namespace converter' do
          converter.on_namespace namespace
          namespace.should_receive(:run).and_return('it works')
          converter.run(':', DEFAULT_NAMESPACE, 'Home', 'Name', '/').should eq('it works')
        end
      end

      context 'with namespace, classname and options' do
      end
    end
  end

  context 'external site' do
    let(:name) { 'wikipedia' }
    let(:converter) { Wikilink::Converter::Site.new name: name }

    describe '#initialize' do
      alias_method :initialize_site, :converter

      it 'does not set option :prefix' do
        converter.options[:prefix].should be_nil
      end
      it 'sets option :external to true' do
        converter.options[:external].should be_true
      end

      it 'sets up default namespace with option :site_name' do
        klass = Wikilink::Converter::Namespace::Default
        klass.should_receive(:new).with(hash_including(site_name: name))
        initialize_site
      end
      it 'sets up default namespace with option :name' do
        klass = Wikilink::Converter::Namespace::Default
        klass.should_receive(:new).with(hash_including(name: DEFAULT_NAMESPACE))
        initialize_site
      end

      context 'with option :external false' do
        let(:converter) { Wikilink::Converter::Site.new name: name, external: false }
        it 'leaves option :external as false' do
          converter.options[:external].should be_false
        end
      end
      context 'with option :prefix "/wiki/"' do
        let(:converter) { Wikilink::Converter::Site.new name: name, prefix: '/wiki/' }
        it 'leaves option :prefix as "/wiki/"' do
          converter.options[:prefix].should eq('/wiki/')
        end
      end
    end

    describe '#run' do
      it 'delegates default namespace to Namespace::Default instance' do
        ->{ converter.run(':', DEFAULT_NAMESPACE, 'Home', 'Name', '/') }.
          should forward(:run).to(default_namespace).with(':', 'Home', 'Name', '/')
      end

      context 'with method #on_namespace_topics defined' do
        before { Wikilink::Converter::Namespace::Default.unstub(:new) }
        class SpecSite < Wikilink::Converter::Site
          def on_namespace_topics(colon, path, name, current_page)
            'it works'
          end
        end
        let(:converter) { SpecSite.new }
        it 'invokes #on_namespace_topics to handle namespace topics' do
          converter.run(':', 'topics', 'Home', 'Name', '/').should eq('it works')
        end

        context 'but user has override it' do
          before {
            converter.namespace('topics') do
              'use this version'
            end
          }

          it 'uses user version' do
            converter.run(':', 'topics', 'Home', 'Name', '/').should eq('use this version')
          end
        end
      end

      context 'with method #on_namespace_ defined' do
        before { Wikilink::Converter::Namespace::Default.unstub(:new) }
        class SpecSite < Wikilink::Converter::Site
          def on_namespace_(colon, path, name, current_page)
            'it works'
          end
        end
        let(:converter) { SpecSite.new }
        it 'invokes #on_namespace_ to handle default namespace' do
          converter.run(':', DEFAULT_NAMESPACE, 'Home', 'Name', '/').should eq('it works')
        end

        context 'but user has override it' do
          before {
            converter.namespace do
              'use this version'
            end
          }

          it 'uses user version' do
            converter.run(':', DEFAULT_NAMESPACE, 'Home', 'Name', '/').should eq('use this version')
          end
        end
      end
    end
  end
end
