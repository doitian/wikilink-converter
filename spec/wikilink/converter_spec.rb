require File.expand_path('../../spec_helper', __FILE__)

shared_examples 'singleton' do |klass|
  describe '.instance' do
    subject { klass }
    its(:instance) { should be_a_kind_of(klass) }
    it 'returns the same instances for all calls to #instance' do
      klass.instance.should equal(klass.instance)
    end
  end
end

describe Wikilink::Converter do
  CURRENT_SITE = Wikilink::Converter::CURRENT_SITE

  it_behaves_like 'singleton', Wikilink::Converter
  describe '.config' do
    it 'yields the singleton instance' do
      Wikilink::Converter.config do |arg|
        arg.should equal(Wikilink::Converter.instance)
      end
    end
  end

  %w{run execute}.each do |method|
    describe ".#{method}" do
      it "forwards method #{method} to #instance" do
        Wikilink::Converter.instance.should_receive(method.to_sym).with(:arg)
        Wikilink::Converter.send method.to_sym, :arg
      end
    end
  end

  let(:converter) { Wikilink::Converter.new }

  describe '#run' do
    subject { converter.method(:run) }
    it 'does nothing when text does not contain wikilink' do
      subject.should convert("Hello World").to('Hello World')
    end
    it 'converts wikilink to element A' do
      subject.should convert('[[Home]]').to('<a href="/Home">Home</a>')
    end
    it 'converts multiple wikilinks to elements A' do
      subject.should convert('[[Home]] [[Page]]').
        to('<a href="/Home">Home</a> <a href="/Page">Page</a>')
    end
    it 'converts escaped \\[[wikilink]] to [[wikilink]]' do
      subject.should convert('\\[[Hello]] World').to('[[Hello]] World')
    end
    it 'ignores [[ and ]] in different lines' do
      subject.should convert("[[Hel\nlo]]").to("[[Hel\nlo]]")
    end
    it 'ignores wikilink with last character is :' do
      subject.should convert("[[:digit:]]").to("[[:digit:]]")
    end
    it 'ignores wikilink with last character is :' do
      subject.should convert("[[:digit:]]").to("[[:digit:]]")
    end
    it 'ignores wikilink which path starts with [' do
      subject.should convert("[[[test]]").to("[[[test]]")
    end
    it 'ignores wikilink which path starts with ]' do
      subject.should convert("[[]test]]").to("[[]test]]")
    end
    it 'unescape &#47; in inner text' do
      subject.should convert("[[foo&#47;bar]]").to('<a href="/foo/bar">foo/bar</a>')
    end
    it 'ignores wikilink which path starts with ]' do
      subject.should convert("[[]test]]").to("[[]test]]")
    end

    context 'in namespace topics' do
      context 'with default handler' do
        before do
          converter.namespace('topics', Wikilink::Converter::Namespace::Default)
        end
        it { should convert('[[topics:World]]').to('<a href="/World">topics:World</a>') }
      end
    end

    context 'with site wiki' do
      let(:wiki) { double(:wiki) }
      before { converter.site('wiki', wiki) }
      subject { converter.method(:run) }

      it 'use link to external wiki' do
        wiki.should_receive(:run).with(any_args).and_return('<a>works</a>')
        subject.should convert('[[wiki:Ruby]]').to('<a>works</a>')
      end
    end

    describe 'pipe trick' do
      it { should convert('[[Hello|]]').to('<a href="/Hello">Hello</a>') }
      it { should convert('[[Hello/World|]]').to('<a href="/Hello/World">World</a>') }

      context 'in namespace topics' do
        context 'with default handler' do
          before do
            converter.namespace('topics', Wikilink::Converter::Namespace::Default)
          end
          it { should convert('[[topics:World|]]').to('<a href="/World">World</a>') }
          it { should convert('[[:topics:World|]]').to('<a href="/World">World</a>') }
        end
      end
    end
    it 'passes options to namespace converter' do
      Wikilink::Converter::Site.any_instance.should_receive(:run) { |*args|
        args.last[:hello].should eq('world')
        'result'
      }
      converter.run('[[Hello]]', hello: 'world')
    end
  end

  describe '#default_site' do
    it 'is a shortcut of #site' do
      converter.should_receive(:site).with(CURRENT_SITE, 'arg')
      converter.current_site 'arg'
    end
  end

  describe '#site' do
    let(:default_site) { double(:default_site).as_null_object }
    let(:site) { double(:site).as_null_object }
    before { Wikilink::Converter::Site.stub(:new) { default_site } }
    let(:converter) { Wikilink::Converter.new }
    
    context 'without any arguments' do
      it 'does not create new instance' do
        converter # call it to initialize first
        Wikilink::Converter::Site.should_not_receive :new
        converter.site
      end
      it 'yields the default site converter' do
        converter.site do |site_converter|
          site_converter.should eq(default_site)
        end
      end
    end

    context 'with site name' do
      it 'creates a new instance of Wikilink::Converter::Site as the site converter' do
        converter # call it to initialize first
        Wikilink::Converter::Site.should_receive(:new).once
        converter.site 'wikipedia'
      end
      it 'initializes the instance with option :name' do
        converter # call it to initialize first
        Wikilink::Converter::Site.should_receive(:new).with(hash_including(name: 'wikipedia')).once
        converter.site 'wikipedia'
      end
      it 'yields the new converter instance' do
        converter # call it to initialize first
        Wikilink::Converter::Site.should_receive(:new).once.and_return(site)
        converter.site('wikipedia') do |site_converter|
          site_converter.should eq(site)
        end
      end
      context 'and options' do
        let(:options) { { foo: :bar } }
        it 'initializes the instance with given options' do
          converter # call it to initialize first
          Wikilink::Converter::Site.should_receive(:new).with(hash_including(foo: :bar)).once
          converter.site 'wikipedia', options
        end
      end
    end

    context 'with object' do
      it 'does not create new instance' do
        converter # call it to initialize first
        Wikilink::Converter::Site.should_not_receive :new
        converter.site site
      end
      it 'yields the object' do
        converter.site(site) do |site_converter|
          site_converter.should eq(site)
        end
      end
    end
  end

  describe '#execute' do
    subject { converter.method(:execute) }

    it 'does nothing without any registered action handlers' do
      subject.should convert('{{toc}}').to('{{toc}}')
    end
    it 'converts escaped \\{{magicwords}} to {{magicwords}}' do
      subject.should convert('\\{{toc}}').to('{{toc}}')
    end

    context 'with handler registered on action toc' do
      before {
        converter.action('toc') do |arg|
          "Table of Contents#{arg}"
        end
      }

      it 'uses the handler to process {{toc}}' do
        subject.should convert('{{toc}}').to('Table of Contents')
      end
      it 'passes content after colon as argument to handler' do
        subject.should convert('{{toc: rocks}}').to('Table of Contents rocks')
      end
      it 'ignores {{ and }} in different lines' do
        subject.should convert("{{toc:\nrocks}}").to("{{toc:\nrocks}}")
      end
      it 'ignores magicwords which last character is colon' do
        subject.should convert("{{toc:}}").to("{{toc:}}")
      end
      it 'ignores other unregistered actions' do
        subject.should convert("{{delete:all:site}}").to("{{delete:all:site}}")
      end
    end
  end
end
