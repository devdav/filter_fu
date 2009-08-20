require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FilterFu do
  
  it "should include FilterFu::ViewHelper into ActionView::Base" do
    ActionView::Base.ancestors.should include(FilterFu::ViewHelper)
  end
  
  it "should înclude FilterFu::ActiveRecord into ActiveRecord::Base" do
    ActiveRecord::Base.ancestors.should include(FilterFu::ActiveRecord)
  end
  
end
