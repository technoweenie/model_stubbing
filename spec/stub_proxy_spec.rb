require File.join(File.dirname(__FILE__), 'spec_helper')

module ModelStubbing
  describe StubProxy do
    before :all do
      @definition = ModelStubbing.definitions[:default]
      @model      = @definition.models[:model_stubbing_tags]
      @stub       = @model.stubs[:foo]
    end

    describe "with model name and stub name" do
      before :all do
        @stub_proxy = StubProxy.new(@definition, @model.name, @stub.name)
      end

      it "has no #method_name" do
        @stub_proxy.method_name.should be_nil
      end

      it "returns @stub.record for #record" do
        @stub_proxy.record.should == @stub.record
      end

      it "equals the stub" do
        @stub_proxy.should == @stub
      end
    end

    describe "with model name, stub name, and method name" do
      before :all do
        @stub_proxy = StubProxy.new(@definition, @model.name, @stub.name)
        @stub_proxy.name
      end

      it "has #method_name" do
        @stub_proxy.method_name.should == :name
      end

      it "returns @stub.record.name for #record" do
        @stub_proxy.record.should == @stub.record.name
      end

      it "does not equal the stub" do
        @stub_proxy.should_not == @stub
      end
    end

    describe "missing valid stub name" do
      before :all do
        @stub_proxy = StubProxy.new(@definition, @model.name, :abc)
      end

      it "raises exception with #record" do
        lambda { @stub_proxy.record }.should raise_error
      end
    end

    describe "missing valid model name" do
      before :all do
        @stub_proxy = StubProxy.new(@definition, :abc, @stub.name)
      end

      it "raises exception with #record" do
        lambda { @stub_proxy.record }.should raise_error
      end
    end
  end
end