module ModelStubbing
  # A Definition holds an array of models with their 
  class Definition
    attr_reader :current_time
    attr_reader :models
    attr_reader :stubs

    def time(*args)
      @current_time = Time.utc(*args)
    end
    
    def model(model_name, options = {}, &block)
      @models[model_name] = Model.new(self, model_name, options, &block)
    end
    
    def initialize(&block)
      @models = {}
      @stubs  = {}
      instance_eval &block if block
    end
    
    def setup_on(klass)
      klass.class_eval do
        def stubs(key, attributes = {})
          self.class.definition.retrieve_record(key, attributes)
        end
        
        def current_time
          self.class.definition.current_time
        end
      end
      klass.class_eval models.values.collect { |model| model.stub_method_definition }.join("\n")
      (class << klass ; self ; end).send :attr_accessor, :definition
      klass.definition = self
    end
    
    def retrieve_record(key, attributes = {})
      @stubs[key].record(attributes)
    end
    
    def inspect
      "ModelStubbing::Definition(:models => [#{@models.keys.collect { |k| k.to_s }.sort.join(", ")}])"
    end
  end
end