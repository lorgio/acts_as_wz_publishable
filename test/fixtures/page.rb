class Page < ActiveRecord::Base
  acts_as_wz_publishable :uses_soft_delete => false, :revisioning => true
  
  before_publish :check_publishing
  
  def check_publishing
    # add callback code here
    true
  end
  
end