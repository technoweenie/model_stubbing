# Attempts to work around rails fixture loading
module ModelStubbing
  module Extension
    def self.included(base)
      class << base
        attr_accessor :definition, :definition_inserted
      end
      base.extend ClassMethods
    end
    
    module ClassMethods
      def create_model_methods_for(models)
        class_eval models.collect { |model| model.stub_method_definition }.join("\n")
      end

      def self.method_added(method)
        case method.to_s
        when 'setup'
          unless method_defined?(:setup_without_model_stubs)
            alias_method :setup_without_model_stubs, :setup
            define_method(:setup) do
              setup_with_model_stubs
              setup_without_model_stubs
            end
          end
        when 'teardown'
          unless method_defined?(:teardown_without_model_stubs)
            alias_method :teardown_without_model_stubs, :teardown
            define_method(:teardown) do
              teardown_without_model_stubs
              teardown_with_model_stubs
            end
          end
        end
      end
    end

    def setup_with_model_stubs
      return unless self.class.definition
      unless self.class.definition_inserted
        self.class.definition.insert!
        self.class.definition_inserted = true
      end
      self.class.definition.setup_test_run
    end
    alias_method :setup, :setup_with_model_stubs

    def teardown_with_model_stubs
      self.class.definition && self.class.definition.teardown_test_run
    end
    alias_method :teardown, :teardown_with_model_stubs

    def stubs(key)
      self.class.definition && self.class.definition.stubs[key]
    end
    
    def current_time
      self.class.definition && self.class.definition.current_time
    end
  end
end