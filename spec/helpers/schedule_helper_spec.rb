# -*- coding: utf-8 -*-
require 'spec_helper'

describe ScheduleHelper do
  describe '.vimeo_url' do
    context 'event with vimeo_id' do
      before { stub(@event = RubyKaigi2011::Event.new).vimeo_id { '123' } }
      it { helper.vimeo_url(@event).should == 'http://vimeo.com/123' }
    end
    context 'event without vimeo_id' do
      before { stub(@event = RubyKaigi2011::Event.new).vimeo_id { nil } }
      it { helper.vimeo_url(@event).should be_blank }
    end
  end
end
