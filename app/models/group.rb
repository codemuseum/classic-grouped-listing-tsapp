class Group < ActiveRecord::Base
  belongs_to :page_object
  serialize :listings, Array
  
  attr_accessor :full_listings
  attr_protected :page_object_id
  
  def after_initialize
    self.full_listings = []
  end
  
  def piped_listings=(str)
    self.listings = str.blank? ? [] : str.split('|')
  end
  
  def piped_listings
    self.listings ? self.listings.join('|') : ''
  end
  
  def grab_listings(listing_data)
    self.full_listings = Array.new
    listing_data.each { |l| self.full_listings << l if self.listings.include?(l.urn) }
    listing_data.delete_if { |l| self.listings.include?(l.urn) }
  end
  
  
  ###### Association Specific Code

  # Used for other models that might need to mark a slide as *no longer* associated 
  attr_accessor :destroy_association

  # Used for other models (like an page_object) that might need to mark this slide as *no longer* associated
  def destroy_association?
    destroy_association.to_i == 1
  end
end
