# -*- coding: utf-8 -*-
require 'spec_helper'

describe ScheduleHelper do
  before do
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end

  context '.video_frame' do
    describe '(nil)' do
      it { helper.vimeo_frame(nil).should be_blank }
    end

    describe '(123)' do
      let(:res) { helper.vimeo_frame([123]) }
      it 'should have embeded vimeo player frame' do
        doc = Nokogiri.HTML(res)
        iframes = doc.xpath('//iframe')
        iframes.should have(1).iframe
        iframes.first['src'].should match(%r{http://player.vimeo.com/video/[0-9]+})
      end

      it 'should have link to vimeo page' do
        doc = Nokogiri.HTML(res)
        links = doc.xpath('//a')
        links.should have(1).link
        links.first['href'].should match(%r{http://vimeo.com/[0-9]+})
      end
    end
  end
end
