module Spree
  module RouteAccess
    delegate :url_helpers, to: 'Spree::Core::Engine.routes'
  end
end
