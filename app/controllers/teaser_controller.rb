# -*- coding: utf-8 -*-
class TeaserController < ApplicationController
  def _2012
    render :file => 'public/2012/404.html', :status => '404', :layout => false
  end
end
