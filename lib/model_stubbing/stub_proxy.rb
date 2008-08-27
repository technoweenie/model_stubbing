module ModelStubbing
  # Used when attaching stubs to other stubs in definitions.  The stub doesn't
  # actually have to exist until the Definition is being inserted into the database.
  #
  #   model Post do
  #     stub :title => 'foo', :author => users(:default)
  #   end
  #
  # You can also call specific methods from the stub.
  #
  #   model Blog do
  #     stub :latest_post => posts(:default), :latest_post_title => posts(:default).title
  #   end
  #
  class StubProxy
    attr_reader :method_name, :proxy_definition, :proxy_model_name, :proxy_stub_name

    def initialize(definition, model_name, stub_name, method_name = nil)
      @proxy_definition  = definition
      @proxy_model_name  = model_name
      @proxy_stub_name   = stub_name
      @method_name       = method_name
      @model = @stub = nil
    end

    def record
      @stub ||= fetch_stub
      @method_name ? @stub.record_without_stubs.send(@method_name) : @stub.record_without_stubs
    end

    alias_method :record_without_stubs, :record

    def ==(other)
      if other.is_a?(StubProxy)
        other.proxy_definition == @proxy_definition && other.proxy_model_name == @proxy_model_name && other.proxy_stub_name == @proxy_stub_name && other.method_name == @method_name
      elsif !@method_name && other.is_a?(Stub)
        other.model.definition == @proxy_definition && other.model.name == @proxy_model_name && @proxy_stub_name == other.name
      else
        super
      end
    end

    def id
      method_missing(:id)
    end
    
    def inspect
      "(ModelStubbing::StubProxy[#{@proxy_model_name}(#{@proxy_stub_name.inspect})#{".#{@method_name}" if @method_name}]"
    end

  protected
    def fetch_stub
      @model = @proxy_definition.models[@proxy_model_name]
      if @model.nil?
        raise "No #{@proxy_model_name.inspect} model found when calling #{@proxy_model_name}(#{@proxy_stub_name.inspect})"
      end
      @stub = @model.stubs[@proxy_stub_name]
      if @stub.nil?
        raise "No #{@proxy_stub_name.inspect} stub found in the #{@proxy_model_name.inspect} model when calling #{@proxy_model_name}(#{@proxy_stub_name})"
      else
        @stub
      end
    end

    def method_missing(name, *args)
      if args.empty?
        @method_name = name.to_sym
        self
      else
        super
      end
    end
  end
end