=begin
wz_publishable.rb
Copyright 2010 wollzelle GmbH (http://wollzelle.com). All rights reserved.
=end

module ActiveRecord
  module Acts 
    module WzPublishable
      CALLBACKS = [:before_publish, :before_unpublish]

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        
        # def exists_with_deleted?(id_or_conditions)
        #          con = id_or_conditions
        #          if con.is_a? Array
        #            con[0] << " and #{self.quoted_table_name}.deleted = ?"
        #            con << false
        #          else
        #            con = {:id => con} if !con.is_a? Hash
        #            con.merge!({:deleted => false})
        #          end
        #          
        #          find_initial(
        #            :select => "#{quoted_table_name}.#{primary_key}",
        #            :conditions => con) ? true : false
        #        end
            
        def acts_as_wz_publishable(options = {})

          return if self.included_modules.include?(ActiveRecord::Acts::WzPublishable::ActsMethods)
          send :include, ActiveRecord::Acts::WzPublishable::ActsMethods

          cattr_accessor :publish_id_column, :publish_state_column, :publish_state_at_column, 
          :publish_on_column, :revision_column, :archived_column, :publish_to_mainrecord,
          :auto_publishing, :revisioning

          self.publish_id_column       = options[:publish_id_column]    || "publish_id"
          self.publish_state_column    = options[:publish_state_column] || "publish_state"
          self.publish_state_at_column = options[:published_at_column]  || "publish_state_at"
          self.archived_column         = options[:archived_column]      || "archived"
          self.revision_column         = options[:revision_column]      || "revision"
          self.publish_on_column       = options[:publish_on_column]    || self.publish_state_at_column  # if not specified immediate publishing
          self.auto_publishing         = options[:auto_publishing]      || FALSE
          self.revisioning             = options[:revisioning]          || FALSE

          @publishing_columns = []
          @publishing_columns << self.publish_state_column
          @publishing_columns << self.publish_state_at_column
          @publishing_columns << self.publish_id_column
          @publishing_columns << self.archived_column
          @publishing_columns << self.revision_column
          @publishing_columns << self.publish_on_column

          if options[:uses_soft_delete] then
            @publishing_columns << 'deleted'
            uses_soft_delete
            soft_delete = {:condition =>" and #{self.table_name}.deleted = :deleted", :value => false}
          else
            soft_delete = {:condition => "", :value => nil}
          end
          
          if uses_soft_delete? then
            named_scope :without_deleted, :conditions => ["#{table_name}.deleted = ?", false]
            class << self
              alias_method :find_with_deleted, :find
              alias_method :count_with_deleted, :count
              alias_method :delete_all_with_deleted, :delete_all
              alias_method :exists_with_deleted?, :exists?
            end
          
            extend SoftDeleteMethods
          end
            
          named_scope :without_deleted, :conditions => {:deleted => false}
          named_scope :without_archive, :conditions => {self.archived_column => false}
          named_scope :latest, lambda {
            { :conditions => ["#{self.table_name}.#{self.archived_column}=:archived and not exists
                               (select 1 from #{self.table_name} chk where chk.#{self.publish_id_column}=#{self.table_name}.#{self.publish_id_column} and chk.#{self.revision_column} > #{self.table_name}.#{self.revision_column})
                               ",
                               {:archived => false, :deleted => soft_delete[:value]}]
            }
          }
          
          named_scope :live, lambda {
            { :conditions => ["#{self.table_name}.#{self.publish_state_column} = 'published' and 
                               #{self.table_name}.#{self.archived_column}=:archived and 
                               #{self.table_name}.#{self.publish_on_column} <= :now #{soft_delete[:condition]}", 
                               {:now => Time.now, :archived => false, :deleted => soft_delete[:value]}]
            }
          }

          belongs_to :main_publishing_record, :class_name => self.name, :foreign_key => self.publish_id_column
          has_many   :revisions, :class_name => self.name, :foreign_key => self.publish_id_column

          # define publishing workflow with aasm gem
          include AASM
          
          #preventing updates to published / unpublished entries has been deactivated!!
          #before_save :check_before_save
          before_validation_on_create :default_values
          after_save  :check_auto_publish
          
          define_callbacks :before_publish, :before_unpublish

          aasm_column self.publish_state_column
          aasm_initial_state :draft

          aasm_state :draft
          aasm_state :published, :enter => :do_publish
          aasm_state :unpublished, :enter => :do_unpublish

          aasm_event :publish do
            transitions :from => :draft, :to => :published
            transitions :from => :unpublished, :to => :published
          end

          aasm_event :unpublish do
            transitions :from => :published, :to => :unpublished
          end
        end

        # def latest_revisions
        #   self.with_exclusive_scope { self.find(:conditions => "not exists (select id from #{self.table_name} chk where #{self.table_name}.#{self.publish_id} = chk.#{self.publish_id})   )}
        # end
        
        def uses_soft_delete?
          !!@uses_soft_delete
        end

        def uses_soft_delete(options={})
          @uses_soft_delete = true

          named_scope :without_deleted, :conditions => ["#{table_name}.deleted = ?", false]        
        end 
      end
      
      module SoftDeleteMethods
        def find(*args)
          if uses_soft_delete?
            without_deleted.find_with_deleted(*args)
          else 
            find_with_deleted(*args)
          end
        end
        
        def count(*args)
          if uses_soft_delete?
            without_deleted.count_with_deleted(*args)
          else 
            count_with_deleted(*args)
          end
        end
        
        def delete_all(conditions=nil)
          if uses_soft_delete?
            update_all(["deleted = ?", true], conditions)
          else 
            delete_all_with_deleted(conditions)
          end
        end
        
        def exists?(id_or_conditions)
          if uses_soft_delete?
            if id_or_conditions.is_a?(Hash) || id_or_conditions.is_a?(Array)
              conditions = {:conditions => id_or_conditions}
            else
              conditions = {:conditions => {:id => id_or_conditions}}
            end
            count(conditions) > 0
          else 
            exists_with_deleted?(id_or_conditions)
          end
        end
        
       #Overrides original destroy method
        def destroy_without_callbacks
          if can_modify? and !self.class.uses_soft_delete? then
            super
          else
            if can_modify? or unpublished? then #make soft delete
              self.update_attributes({:deleted => true})
            else
              self.update_attributes(self.publish_state_column => 'unpublished',
              self.publish_state_at_column => Time.now)
            end
            true
          end
        end

        def destroy_with_callbacks!
          return false if callback(:before_destroy) == false
          result = destroy_without_callbacks!
          @destroyed = true
          callback(:after_destroy)
          result
        end

        def destroy!
          transaction { destroy_with_callbacks! }
        end

        def destroyed?
          @destroyed
        end        
      end

      module ActsMethods
        def self.included(base)
          base.extend(ClassMethods)
        end

        def initialize_draft_from(obj)
          self[self.publish_state_column] = 'draft'
          self[self.publish_state_at_column] = nil
          self[self.publish_id_column] ||= obj[self.publish_id_column] || obj.id
          self[self.archived_column] = false
          self[self.revision_column] = (self[self.revision_column] || 0) + 1
          self
        end

        def get_or_clone_for_update
          if draft? then
            self
          else
            new_draft = self.clone
            new_draft.initialize_draft_from(self)
          end
        end

        def can_modify?
          statechange = self.send "#{self.publish_state_column}_change"
          new_record? or draft? or (statechange and statechange[0] = 'draft') 
        end

        def content_changed?
          content_update = self.changes.detect {|key, value| self.class.publishing_columns.index(key).nil?}  
          !!content_update
        end

        def main_publishing_record?
          self.id == (self[self.publish_id_column] || self.id)        
        end        

        # def check_before_save
        #   if (published? or unpublished?) and (!self.class.publish_to_mainrecord) then
        #     !content_changed?
        #   else
        #     true
        #   end
        # end

        def default_values
          self.deleted ||= false
          true
        end
        
        def check_auto_publish
          if auto_publishing and (self.draft? and (!main_publishing_record.nil?) and (main_publishing_record.published?)) then
            self.publish!
          end
        end

        def set_publish_time
          self[self.publish_state_at_column] = Time.now 
        end
        
        def check_publishing
          check_callback(:before_publish)
        end
        
        def check_unpublishing
          check_callback(:before_unpublish)
        end

        def check_callback(cb_name)
          res = true
          run_callbacks(cb_name) { |result, object| res = (res and result)}
          res
        end
        
        def do_publish
          raise(ActiveRecord::RecordNotSaved, "Publishing was aborted due to an error.") if !self.check_publishing
          self.set_publish_time 

          self[self.revision_column] = (self[self.revision_column] || 1)
          self[self.publish_id_column] ||= self.id

          if self.revisioning then
            if (main_publishing_record?) then
              archive_initial_revision
            else
              copy_to_main_entry
              # this revision gets archived
              self[self.archived_column] = true
            end  
          end

          true
        end

        def do_unpublish
          raise(ActiveRecord::RecordNotSaved, "Unpublishing was aborted due to an error.") if !self.check_unpublishing
          self.set_publish_time 
        end

        def archive_initial_revision
          archive_entry = self.clone
          archive_entry[self.publish_state_column] = 'published'
          archive_entry[self.publish_id] = self.id
          archive_entry.archived = true
          archive_entry.save!
        end
        
        def copy_content_to(destination, state = nil)
          attrs = clone_attributes(:read_attribute_before_type_cast)
          attrs.delete(self.class.primary_key)            
          attrs.delete(self.publish_id_column)
          attrs.delete(self.publish_state_column)
          attrs.delete(self.class.locking_column)
          attrs[self.publish_state_column] = state if state

          destination.update_attributes!(attrs) rescue return false
          true
        end


        def copy_to_main_entry
          mainentry = self.class.find(self[self.publish_id_column]) rescue nil
          if mainentry and (mainentry!=self) then
            raise(ActiveRecord::RecordNotSaved, "Error during assigning copy!") if !self.copy_content_to(mainentry, 'published')
          else
            raise(ActiveRecord::RecordNotSaved, "Publishing id not found for #{self.id}")
          end   
        end

        module ClassMethods
          def publishing_columns
            @publishing_columns
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::WzPublishable
