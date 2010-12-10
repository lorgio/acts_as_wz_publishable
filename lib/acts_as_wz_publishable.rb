require 'aasm'
require 'active_record'
require 'action_controller'
require 'active_record/acts/wz_publishable'

ActiveRecord::Base.send :include, ActiveRecord::Acts::WzPublishable