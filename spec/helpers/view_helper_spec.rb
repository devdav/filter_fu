require 'spec_helper'

describe FilterFu::ViewHelper do

  before(:each) do
    helper.controller = DummyController.new
  end

  it "should provide a filter_form_for method" do
    helper.should respond_to(:filter_form_for)
  end

  it "should prodive a filter_form method as an alias for filter_form" do
    helper.should respond_to(:filter_form)
  end

  it "should require a block" do
    expect { helper.filter_form_for }.to raise_error(ArgumentError, /Missing block/)
  end

  it "should accept options" do
    expect { helper.filter_form_for({}) {} }.to_not raise_error(ArgumentError)
  end

  it "should not require options" do
    expect { helper.filter_form_for() {} }.to_not raise_error(ArgumentError)
  end

  it "should accept a name together with options" do
    expect { helper.filter_form_for(:other, {}) {} }.to_not raise_error(ArgumentError)
  end

  it "should call the associated block" do
    expect {
      helper.filter_form_for() { throw :done }
    }.to throw_symbol(:done)
  end

  it "should pass a ActionView::Helpers::FormBuilder to the block" do
    helper.filter_form_for { |f| f.should be_kind_of(ActionView::Helpers::FormBuilder) }
  end

  it "should include the erb of the block" do
    html = helper.filter_form_for { "<div>Some random HTML</div>" }
    html.should contain('Some random HTML')
  end

  it "should include a form tag" do
    html = helper.filter_form_for { }
    html.should have_selector('form')
  end

  it "should set the form method attribute to GET" do
    html = helper.filter_form_for { }
    html.should have_selector('form', :method => 'get')
  end

  it "should set the form action attribute to the current url" do
    html = helper.filter_form_for { }
    html.should have_selector('form', :action => '/foo/bar')
  end

  it "should use :filter as the default namespace in form fields" do
    html = helper.filter_form_for { |f| f.text_field :name }
    html.should have_selector('input', :name => 'filter[name]')
  end

  it "should use another name as namespace if it's provided as the first argument" do
    html = helper.filter_form_for(:other) { |f| f.text_field :name }
    html.should have_selector('input', :name => 'other[name]')
  end

  it "should pass options to the form_for helper" do
    html = helper.filter_form_for(:html => { :class => 'filter' }) { }
    html.should have_selector('form', :class => 'filter')
  end

  it "should preserve the page's parameters with hidden fields" do
    helper.params.merge!({ :some_param => 'some value', :some_other_param => 'some other value' })
    html = helper.filter_form_for() { }
    html.should have_selector('input', :type => 'hidden', :name => 'some_param', :value => 'some value')
    html.should have_selector('input', :type => 'hidden', :name => 'some_other_param', :value => 'some other value')
  end

  it "should preserve the page's nested parameters with hidden fields" do
    helper.params.merge!({ :some_param => 'some value', :nested => { :some_other_param => 'some other value', :deeply_nested => { :down_here => 'yet another value' } } })
    html = helper.filter_form_for() { }
    html.should have_selector('input', :type => 'hidden', :name => 'some_param', :value => 'some value')
    html.should have_selector('input', :type => 'hidden', :name => 'nested[some_other_param]', :value => 'some other value')
    html.should have_selector('input', :type => 'hidden', :name => 'nested[deeply_nested][down_here]', :value => 'yet another value')
  end

  it "should not preserve the page's parameters for the current filter" do
    helper.params.merge!({ :other => { :name => 'some value' }})
    html = helper.filter_form_for(:other) { }
    html.should_not have_selector('input', :type => 'hidden', :name => 'other')
    html.should_not have_selector('input', :type => 'hidden', :name => 'other[name]', :value => 'some value')
  end

  it "should not preserve the controller and action params" do
    helper.params.merge!({ :controller => 'foo', :action => 'bar' })
    html = helper.filter_form_for() { }
    html.should_not have_selector('input', :type => 'hidden', :name => 'controller', :value => 'foo')
    html.should_not have_selector('input', :type => 'hidden', :name => 'action', :value => 'bar')
  end

  it "should not preserve params specified in :ignore_parameters" do
    helper.params.merge!({ :some_param => 'some value', :some_other_param => 'some other value' })
    html = helper.filter_form_for(:ignore_parameters => [:some_other_param]) { }
    html.should have_selector('input', :type => 'hidden', :name => 'some_param', :value => 'some value')
    html.should_not have_selector('input', :type => 'hidden', :name => 'some_other_param', :value => 'some other value')
  end

  it "should use the current filter params as defaults for the form" do
    helper.params.merge!({ :filter => { :some_param => 'some value' } })
    html = helper.filter_form_for() { |f| f.text_field :some_param }
    html.should have_selector('input', :type => 'text', :name => 'filter[some_param]', :value => 'some value')
  end
end
