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
    
    def insert(attributes = {})
      object = record(attributes)
      connection.insert_fixture(object.stubbed_attributes, model.model_class.table_name)
    end
    
    def connection
      @connection ||= @model.connection
    end
  
  private
    def instantiate(attributes)
      default_record    = attributes.empty?
      stubs, attributes = stubbed_attributes(@attributes.merge(attributes))

      record = @model.model_class.new
      meta   = class << record
        def new_record?() false end
        self
      end
      
      meta.send :attr_accessor, :stubbed_attributes
      record.id = @model.model_class.mock_id
      record.stubbed_attributes = attributes.merge(:id => record.id)

      attributes.each do |key, value|
        
        record[key] = value
      end

      stubs.each do |key, value|
        meta.send :attr_accessor, key
        record.send("#{key}=", value.is_a?(Stub) ? value.record : value)
      end
   
      @model.records[self] = record if default_record
      record
    end
    
    def stubbed_attributes(attributes)
      stubs   = {}
      stubbed = FixtureHash.new(self)
      
      attributes.each do |key, value|
        stubbed[key] = value
        stubs[key]   = value if value.is_a? Stub
      end

      [stubs, stubbed]
    end
    
    def retrieve
      @model.records[self]
    end
  end
  
  class FixtureHash < Hash
    def initialize(stub)
      super()
      @stub = stub
    end

    def key_list
      keys.collect { |key| @stub.connection.quote_column_name(column_name_for(key)) } * ", "
    end

    def value_list
      list = inject([]) do |fixtures, (key, value)|
        column_name = column_name_for key
        column      = column_for column_name
        value       = value.record.id if value.is_a?(Stub)
        fixtures << @stub.connection.quote(value, column).gsub('[^\]\\n', "\n").gsub('[^\]\\r', "\r")
      end.join(", ")
    end
  
  private
    def model_class
      @stub.model.model_class
    end

    def column_name_for(key)
      (@keys ||= {})[key] ||= begin
        value = self[key]
        if value.is_a? Stub
          if defined?(ActiveRecord)
            reflection = model_class.reflect_on_association(key)
            reflection.primary_key_name
          else
            "#{key}_id"
          end
        else
          key
        end
      end
    end
  
    def column_for(name)
      model_class.columns_hash[name] if defined?(ActiveRecord) && model_class.ancestors.include?(ActiveRecord::Base)
    end
  end
end