module Admins
  class SessionsController < Devise::SessionsController
    layout "admin_auth"
  end
end
