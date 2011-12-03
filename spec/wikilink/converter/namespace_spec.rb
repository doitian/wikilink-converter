require File.expand_path('../../../spec_helper', __FILE__)

shared_examples 'converter that can forward to given block' do |klass|
  klass ||= describes

  context 'given block through #config' do
    let(:converter) { klass.new.config { 'it works' } }

    describe '#run' do
      subject { converter.method(:run) }
      it 'forwards to the block' do
        subject.should convert(':', 'Home', 'Home', '/').to('it works')
      end
    end
  end

  context 'given block accessing options in constructor through #config' do
    let(:converter) {
      klass.new(fake_result: 'fake').config { options[:fake_result] }
    }

    describe '#run' do
      subject { converter.method(:run) }
      it 'forwards to the block and allows options access' do
        subject.should convert(':', 'Home', 'Home', '/').to('fake')
      end
    end
  end
end

describe Wikilink::Converter::Namespace do
  let(:converter) { Wikilink::Converter::Namespace.new }
  describe '#run' do
    subject { converter.method(:run) }
    it 'does nothing' do
      subject.should convert(':', 'Home', 'Home', '/').to(nil)
    end
  end

  it_behaves_like 'converter that can forward to given block'
end

describe Wikilink::Converter::Namespace::Default do
  shared_examples 'converter that keeps query fragment only path untouched' do
    it { should convert(':', '#toc-1', 'Header 1', '/').
      to('<a href="#toc-1">Header 1</a>')
    }
    it { should convert(':', '?q=keyword', 'Search keyword', '/').
      to('<a href="?q=keyword">Search keyword</a>')
    }
    it { should convert(':', '?q=keyword#page-10', 'Search keyword (page 10)', '/').
      to('<a href="?q=keyword#page-10">Search keyword (page 10)</a>')
    }
  end

  let(:converter) { self.class.describes.new }
  describe '#run' do
    subject { converter.method(:run) }
    it { should convert(':', 'Home', 'Name', '/').
      to('<a href="Home">Name</a>')
    }
    it_behaves_like 'converter that keeps query fragment only path untouched'
  end

  context 'given option :prefix "/wiki/"' do
    let(:converter) { self.class.describes.new prefix: '/wiki/' }
    describe '#run' do
      subject { converter.method(:run) }
      it_behaves_like 'converter that keeps query fragment only path untouched'
    end
  end

  context 'given option :suffix "/index.html"' do
    let(:converter) { self.class.describes.new suffix: '/index.html' }
    describe '#run' do
      subject { converter.method(:run) }
      it { should convert(':', 'Home', 'Name', '/').
        to('<a href="Home/index.html">Name</a>')
      }
      it_behaves_like 'converter that keeps query fragment only path untouched'
    end
  end

  context 'given option :external true' do
    let(:converter) { self.class.describes.new external: true }
    describe '#run' do
      subject { converter.method(:run) }
      it { should convert(':', 'Home', 'Name', '/').
        to('<a class="external" href="Home">Name</a>')
      }
    end
  end
  context 'given option :class "fancy"' do
    let(:converter) { self.class.describes.new class: 'fancy' }
    describe '#run' do
      subject { converter.method(:run) }
      it { should convert(':', 'Home', 'Name', '/').
        to('<a class="fancy" href="Home">Name</a>')
      }
    end
  end
  context 'given option :external true and :class "fancy"' do
    let(:converter) { self.class.describes.new external: true, class: 'fancy' }
    describe '#run' do
      subject { converter.method(:run) }
      it { should convert(':', 'Home', 'Name', '/').
        to('<a class="fancy external" href="Home">Name</a>')
      }
    end
  end

  it_behaves_like 'converter that can forward to given block'
end
