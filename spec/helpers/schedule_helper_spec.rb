# -*- coding: utf-8 -*-
require 'spec_helper'

describe ScheduleHelper do
  before do
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end

  describe '.video_frame' do
    describe '(nil)' do
      it { helper.vimeo_frame(nil).should be_blank }
    end

    describe '(123)' do
      let(:res) { helper.vimeo_frame([123]) }
      let(:doc) { Nokogiri.HTML(res) }

      let(:iframe) { doc.xpath('//iframe').first }
      it 'should have embeded vimeo player frame' do
        iframe['src'].should match(%r{http://player.vimeo.com/video/[0-9]+})
      end

      let(:link) { doc.xpath('//a').first }
      it 'should have link to vimeo page' do
        link['href'].should match(%r{http://vimeo.com/[0-9]+})
      end
    end
  end
end
