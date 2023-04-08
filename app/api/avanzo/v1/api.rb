require 'grape-swagger'

module Avanzo
  module V1
    class API < Grape::API
      format :json
      cascade false

      rescue_from ActiveRecord::RecordNotFound do
        error! "not-found", 404
      end

      # rescue_from Grape::Knock::ForbiddenError do
      #   error! "unauthenticated", 401
      # end

      mount Avanzo::V1::SubjectAPI
      
      add_swagger_documentation \
        base_path: '/api/v1',
        security_definitions: {
          api_key: {
            type: "apiKey",
            name: "api_key",
            in: "header"
          }
        },
        security: {
          api_key: []
        },
        models: [
          Avanzo::V1::Entities::Subject,
        ],
        tags: [
          { name: 'users', description: 'API calls related to user accounts and authentication' }
        ],
        info: {
          title: "Avanzo API",
          version: "1.0.0",
          description: "This is the API. It is " +
            "used by serve info for apps",
          license_name: "(C) 2023 RG. All rights reserved.",
          contact_name: "RG Developer",
          contact_email: "roxana.gonzalez21@gmail.com",
          contact_url: "roxanagonzalez.tech",
          terms_of_service: "roxanagonzalez.tech/terms",
        }
    end
  end
end
