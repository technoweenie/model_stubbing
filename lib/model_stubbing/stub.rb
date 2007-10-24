module ModelStubbing
  # Stubs hold custom attributes that are applied to models when
  # instantiated.  By default, accessing the same stub twice
  # will return the exact same instance.  However, custom attributes
  # will create unique stub instances.
  class Stub
    attr_reader   :model
    attr_reader   :attributes
    attr_accessor :name
    
    # Creates a new stub.  If it's not the default, it inherits the default 
    # stub's attributes.
    def initialize(model, name, attributes)
      @model      = model
      @name       = name
      @attributes = 
        if default?
          attributes
        else
          model.default.attributes.merge(attributes)
        end
    end
    
    def default?
      @name == :default
    end
    
    # Retrieves or creates a record based on the stub's set attributes and the given custom attributes.
    def record(attributes = {})
      attributes.empty? && @model.records.key?(self) ? retrieve : instantiate(attributes)
    end
    
    def inspect
      "(ModelStubbing::Stub(#{@name.inspect} => #{attributes.inspect}))"
    end
    
    private
      def instantiate(attributes)
        stubs = {}
        default_record = attributes.empty?
        
        @attributes.each do |key, value|
          stubs[key] = value if value.is_a?(Stub)
        end
        
        attributes.each do |key, value|
          case value
            when Stub
              stubs[key] = attributes.delete(key)
            when Hash
              stubs[key] = stubs[key].record(value)
          end
        end

        attributes = @attributes.merge(attributes)

        record = @model.model_class.new(attributes)
        meta   = class << record ; self ; end
        
        meta.send :attr_accessor, :id
        record.id = @model.model_class.mock_id

        stubs.each do |key, value|
          meta.send :attr_accessor, key
          record.send("#{key}=", value.is_a?(Stub) ? value.record : value)
        end
        
        @model.records[self] = record if default_record
        record
      end
      
      def retrieve
        @model.records[self]
      end
  end
end