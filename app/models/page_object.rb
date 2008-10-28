class PageObject < ActiveRecord::Base
  include ThriveSmartObjectMethods
  self.caching_default = 'interval[5]' #[in :forever, :page_update, :any_page_update, 'data_update[datetimes]', :never, 'interval[5]']

  has_many :groups, :order => :position
  attr_accessor :ungrouped_listings

  # Override caching information to be on data_update of the data path
  def caching
    @caching = "data_update[#{data_path}]"
  end
  
  def parse_data(data_array)
    arry = data_array.dup
    self.groups.each { |g| g.grab_listings(arry) }
    self.ungrouped_listings = arry
  end
end
