require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'fixtures/page')
require File.join(File.dirname(__FILE__), 'fixtures/page_soft_delete')

require 'helper'

class PagesTest < Test::Unit::TestCase
  def test_can_modify
    p = Page.create! :title => 'first title', :body => 'first body'
    assert p.can_modify?
    assert p.draft?
  end
  
  def test_publishing
    p = Page.create! :title => 'first title', :body => 'first body'
    assert p.publish!
    assert p.published?
  end
  
  def test_unpublishing
    p = Page.create! :title => 'first title', :body => 'first body'
    assert p.publish!
    assert p.unpublish!
    assert p.unpublished?
  end
  
  def test_delete_without_soft_delete
    p = Page.create! :title => 'first title', :body => 'first body'
    assert(p.destroy)
    assert(!Page.exists?(p.id))
  end
  
  def test_delete_with_soft_delete
    p1 = PageSoftDelete.create! :title => 'first title', :body => 'first body'
    p1.reload
    assert(p1.destroy)
    
    assert(!PageSoftDelete.exists?(p1.id))
    
    p = PageSoftDelete.new :title => 'first title', :body => 'first body'
    assert(p.save)

    p = PageSoftDelete.new :title => 'first title', :body => 'first body'
    assert(!p.save)
  end
  
  def test_live_scope
    old_draft =  Page.draft.count
    old_published = Page.live.count
  
    page = Page.create! :title => 'first title', :body => 'first body'
    assert((old_draft + 1) == Page.draft.count)
    
    page.publish!
    
    assert((old_published + 1) == Page.live.count)
    assert(Page.live.find(page.id))
  end
  
  def test_archive_scope
    old_archive =  Page.without_archive.count
    old_count =  Page.count
    
  
    page = Page.create! :title => 'first title', :body => 'first body'
    page.publish!
    
    assert((old_archive + 1) == Page.without_archive.count)
    assert((old_count + 2) == Page.count)
  end
  
  def test_lastest_scope
    old_count =  Page.latest.count
    # p Page.latest.map {|entry| [entry.id, entry.publish_id, entry.revision]}.inspect


    page = Page.create! :title => 'first title', :body => 'first body'
    # p Page.latest.map {|entry| [entry.id, entry.publish_id, entry.revision, entry.publish_state]}.inspect
    assert((old_count + 1) == Page.latest.count)


    # p Page.latest.map {|entry| [entry.id, entry.publish_id, entry.revision, entry.publish_state]}.inspect
    page.publish!
    # p Page.latest.map {|entry| [entry.id, entry.publish_id, entry.revision, entry.publish_state]}.inspect
    assert((old_count + 1) == Page.latest.count)    
    
    newpage = page.get_or_clone_for_update
    newpage.save!
    newpage.reload
    
    # p Page.latest.map {|entry| [entry.id, entry.publish_id, entry.revision, entry.publish_state]}.inspect
    assert((old_count + 1) == Page.latest.count) 
    newpage.publish!
    # p Page.latest.map {|entry| [entry.id, entry.publish_id, entry.revision, entry.publish_state]}.inspect
    assert((old_count + 1) == Page.latest.count) 
  end
  
end
