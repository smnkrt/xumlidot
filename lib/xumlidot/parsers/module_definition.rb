# frozen_string_literal: true

require_relative '../parsers'
require_relative '../types'

module Xumlidot
  module Parsers
    # Parser for the KLASS DEFINITION ONLY and the name
    # probably should be changed to reflect that
    #
    # The main parser will handle method,
    # constants, etc
    #
    class ModuleDefinition < MethodBasedSexpProcessor

      attr_reader :definition

      def initialize(exp, namespace = nil)
        super()

        @definition = ::Xumlidot::Types::ModuleDefinition.new
        @namespace = namespace.dup

        process(exp)
      end

      def process_module(exp)
        exp.shift # remove :module
        definition = exp.shift

        # Processes the name of the module
        if Sexp === definition
          case definition.sexp_type
          when :colon2 then # Reached in the event that a name is a compound
            name = definition.flatten
            name.delete :const
            name.delete :colon2
            name.each do |v|
              @definition.name << ::Xumlidot::Types::Constant.new(v, @namespace)
            end
          when :colon3 then # Reached in the event that a name begins with ::
            @definition.name << ::Xumlidot::Types::Constant.new(definition.last, '::')
          else
            raise "unknown type #{exp.inspect}"
          end
        else Symbol === definition
          #if we have a symbol we have the actual module name
          # e.g. module Foo; end
          @definition.name << ::Xumlidot::Types::Constant.new(definition, @namespace)
        end
        s()
      end
    end
  end
end
