module Avanzo
  class SwaggerDocGuard < Grape::Middleware::Base
    def before
      # authenticate
    end

    private

    def authenticate
      #fail ::Grape::Knock::ForbiddenError if Rails.env.production?
    end
  end
end
