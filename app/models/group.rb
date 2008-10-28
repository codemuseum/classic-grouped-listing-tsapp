class Group < ActiveRecord::Base
  belongs_to :page_object
  serialize :listings, Array
  
  attr_accessor :full_listings
  
  def piped_listings=(str)
    self.listings = str.split('|')
  end
  
  def piped_listings
    "|#{self.listings ? self.listings.join('|') : ''}|"
  end
  
  def grab_listings(listing_data)
    self.full_listings = listing_data.reject! { |l| self.listings.include?(l.urn) } 
  end
end
