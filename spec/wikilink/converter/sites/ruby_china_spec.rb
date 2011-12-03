# -*- coding: utf-8 -*-
require File.expand_path('../../../../spec_helper', __FILE__)
require 'wikilink/converter/sites/ruby_china'

describe Wikilink::Converter::Sites::RubyChina do
  subject { converter.method(:run) }

  context 'ruby-china.org' do
    let(:rubychina) { Wikilink::Converter::Sites::RubyChina }
    let(:converter) {
      Wikilink::Converter.new { |on| on.current_site(rubychina) }
    }

    it { should convert('[[Ruby]]').to('<a href="/wiki/Ruby">Ruby</a>') }
    it { should convert('[[topic:1]]').to('<a href="/topics/1">topic:1</a>') }
    it { should convert('[[node:1]]').to('<a href="/topics/node1">node:1</a>') }
  end

  context 'external ruby-taiwan.org' do
    let(:rubytaiwan) { Wikilink::Converter::Sites::RubyTaiwan }
    let(:converter) {
      Wikilink::Converter.new { |on|
        on.site('rubytaiwan', rubytaiwan)
      }
    }

    it { should convert('[[rubytaiwan:Ruby]]').to('<a class="external" href="http://ruby-taiwan.org/wiki/Ruby">rubytaiwan:Ruby</a>') }
    it { should convert('[[rubytaiwan:topic:1]]').to('<a class="external" href="http://ruby-taiwan.org/topics/1">rubytaiwan:topic:1</a>') }
    it { should convert('[[rubytaiwan:node:1]]').to('<a class="external" href="http://ruby-taiwan.org/topics/node1">rubytaiwan:node:1</a>') }
  end
end
