# coding: utf-8

module ScheduleHelper
  def vimeo_url(event)
    event.vimeo_id ? "http://vimeo.com/#{event.vimeo_id}" : ''
  end
end
