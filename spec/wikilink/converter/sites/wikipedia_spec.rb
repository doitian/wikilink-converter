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
    it { should convert('[[wiki:红宝石]]').to('<a class="external" href="http://zh.wikipedia.org/wiki/红宝石">wiki:红宝石</a>')}
  end
end
