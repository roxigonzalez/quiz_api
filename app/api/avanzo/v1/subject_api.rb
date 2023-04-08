module Avanzo
  module V1
    ##
    class SubjectAPI < Grape::API
      format :json

      resource 'subjects' do
        desc 'Return a public list of subjects.',
          entity: Avanzo::V1::Entities::Subject
        get do
          present Subject.limit(20), with: Avanzo::V1::Entities::Subject
        end
      end
    end
  end
end
