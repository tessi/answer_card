module Admin
  class BaseController < ApplicationController
    http_basic_authenticate_with name: 'tessi', password: 'istnedickemaus'
  end
end
