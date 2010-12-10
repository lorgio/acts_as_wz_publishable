class PageSoftDelete < ActiveRecord::Base
  acts_as_wz_publishable :uses_soft_delete => true
  
  validates_uniqueness_of :title
end