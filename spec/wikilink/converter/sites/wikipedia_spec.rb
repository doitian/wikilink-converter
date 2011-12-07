# -*- coding: utf-8 -*-
require File.expand_path('../../../../spec_helper', __FILE__)
require 'wikilink/converter/sites/wikipedia'

describe Wikilink::Converter::Sites::Wikipedia do
  subject { converter.method(:run) }

  context 'en current site' do
    let(:wikipedia) { Wikilink::Converter::Sites::Wikipedia }
    let(:converter) {
      Wikilink::Converter.new { |on| on.current_site(wikipedia) }
    }
    it { should convert('[[Ruby]]').to('<a href="/wiki/Ruby">Ruby</a>')}
  end

  context 'zh external site' do
    let(:wikipedia) { Wikilink::Converter::Sites::Wikipedia }
    let(:converter) {
      Wikilink::Converter.new(lang: 'zh') do |on|
        on.site('wiki', wikipedia)
      end
    }
    it { should convert('[[wiki:红宝石]]').to('<a class="external" href="http://zh.wikipedia.org/wiki/%E7%BA%A2%E5%AE%9D%E7%9F%B3">wiki:红宝石</a>')}
  end
end
