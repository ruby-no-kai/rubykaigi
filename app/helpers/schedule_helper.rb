# coding: utf-8

module ScheduleHelper
  def vimeo_frame(vimeo_id)
    return '' if vimeo_id.blank?
    capture_haml do
      haml_tag :iframe, :frameborder => '0', :width => '400', :height => '300', :src => "http://player.vimeo.com/video/#{vimeo_id}"
      haml_tag :div do
        haml_tag :a, :href => "http://vimeo.com/#{vimeo_id}", :target => '_blank' do
          haml_concat "http://vimeo.com/#{vimeo_id}"
        end
      end
    end
  end
end
