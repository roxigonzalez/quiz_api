module Avanzo
  module V1
    module Entities
      class Subject < Grape::Entity
        expose :name, documentation: { type: "String", desc: "Describes" }
        expose :description, documentation: { desc: "Description" }
      end
    end
  end
end
