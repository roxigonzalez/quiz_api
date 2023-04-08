require 'grape_logging'

module Grape
  module DSL
    module Parameters

      ##
      # Support defining parameters from an entity.
      def entity(cls)
        use_require = false
        if use_require
          docs = cls.documentation.clone
          docs[:param_type] = 'body'
          eval "requires :all, using: docs"
        else
          cls.documentation.each do |attribute_name, documentation|

            type = documentation[:type] # || 'Object'
            doc_type = "'#{type}'" if type
            exposure = cls.find_exposure(attribute_name)

            if exposure.respond_to?(:using_class) && exposure.using_class
              doc_type = exposure.using_class
              type = nil
            end

            decl_type = type

            type = "Object" if decl_type == 'Boolean'


            required = documentation[:required] || documentation[:presence] == true
            nullable = documentation[:nullable]

            defn = ''

            if type
              coercer = '->(c) { c }'
              validator = '->(v) { true }'

              if decl_type == 'Boolean'
                validator = '->(v) { v.is_a?(TrueClass) || v.is_a?(FalseClass) }'
                coercer = "->(c) { ({ 'true' => true, 'false' => false, 1 => true, 0 => false }.fetch(c) { c }) }"
                decl_type = 'Object'
              elsif decl_type == 'Integer'
                validator = '->(v) { v.is_a?(Integer) }'
                coercer = "->(c) { c.to_i }"
                decl_type = 'Object'
              elsif decl_type == 'DateTime' || decl_type == 'Date'
                validator = '->(v) { true }'
                coercer = "->(c) { DateTime.parse(c) }"
                decl_type = 'Object'
              elsif decl_type == 'String'
                validator = '->(v) { v.is_a?(String) }'
                coercer = "->(c) { (c.is_a?(Integer) || c.is_a?(Float)) ? c.to_s : c }"
                decl_type = 'String'
              end

              coercer = "->(c) { c.nil? ? nil : #{coercer}.call(c) }" if nullable

              type_ref = decl_type.is_a?(String) ? eval(decl_type) : decl_type

              if type_ref <= Grape::Entity
                type = 'Hash'
              end

              if documentation[:is_array]
                type = "Array[#{type}]"
              end
              defn = "#{required ? 'requires' : 'optional' } :#{attribute_name}, values: #{validator}, coerce_with: #{coercer}, type: #{type}, documentation: { type: #{doc_type}, param_type: 'body', is_array: #{documentation[:is_array] || false} }"
            else

              if doc_type
                defn = "#{required ? 'requires' : 'optional' } :#{attribute_name}, documentation: { type: #{doc_type}, param_type: 'body', is_array: #{documentation[:is_array] || false} }"
              else
                defn = "#{required ? 'requires' : 'optional' } :#{attribute_name}, documentation: { param_type: 'body', is_array: #{documentation[:is_array] || false} }"
              end
            end

            begin
              eval defn
            rescue StandardError => e
              puts "While declaring entity parameter #{cls.name}##{attribute_name} with definition '#{defn}': #{e.class}: #{e.message} -- #{e.backtrace}"
            end
          end

        end
      end
    end
  end
end

module Avanzo
class API < Grape::API

    logger Rails.logger
    use GrapeLogging::Middleware::RequestLogger,
      logger: logger,
      include: [
        GrapeLogging::Loggers::FilterParameters.new
    ]
    # API versions are mounted from here.
    mount Avanzo::V1::API => '/v1'
  end
end
