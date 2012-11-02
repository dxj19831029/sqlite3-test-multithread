class TestModel < ActiveRecord::Base
  # To change this template use File | Settings | File Templates.
  self.primary_key=:id
  attr_accessible :active, :cluster_name, :name

end