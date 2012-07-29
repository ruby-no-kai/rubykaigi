# -*- coding: utf-8 -*-
class WelcomeController < LocaleBaseController
  def index
# latest_yearをイジるとPayPalまわりが壊れるので、決め打ち
#    redirect_to "/#{RubyKaigi.latest_year}"
    redirect_to "/2013"
  end
end
