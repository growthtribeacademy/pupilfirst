class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def flipper_id
    [self.class.name, self.id].join(":")
  end
end
