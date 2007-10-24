module ModelStubbing
  class Model
    attr_reader   :definition
    attr_accessor :name
    attr_accessor :plural
    attr_accessor :singular
    attr_reader   :stubs
    attr_reader   :records

    def stub(name = nil, options = {})
      if name.is_a?(Hash)
        options = name
        name    = :default
      end

      global_key = (name == :default ? @singular : "#{name}_#{@singular}").to_sym
      all_stubs[global_key] = @stubs[name] = Stub.new(self, name, options)
    end

    def initialize(definition, name, options = {}, &block)
      @definition  = definition
      @name        = name
      @plural      = options[:plural]   || name
      @singular    = options[:singular] || name.to_s.singularize
      @model_class = options[:class]
      @stubs       = {}
      @records     = {}
      instance_eval &block if block
    end
    
    def model_class
      if @model_class.nil?
        @model_class = name.to_s.classify.constantize
        unless @model_class.respond_to?(:mock_id)
          class << @model_class
            define_method :mock_id do
              @mock_id ||= 999
              @mock_id  += 1
            end
          end
        end
      end
      @model_class
    end
    
    def default
      @stubs[:default]
    end
    
    def current_time
      @definition.current_time
    end
    
    def all_stubs(key = nil)
      key ? @definition.stubs[key] : @definition.stubs
    end

    def retrieve_record(key, attributes = {})
      @stubs[key].record(attributes)
    end
    
    def stub_method_definition
      "def #{@plural}(key, attributes = {}) self.class.definition.models[#{@plural.inspect}].retrieve_record(key, attributes) end"
    end

    def inspect
      "ModelStubbing::Model(#{@name.inspect} => [#{@stubs.keys.collect { |k| k.to_s }.sort.join(", ")}])"
    end
  end
end