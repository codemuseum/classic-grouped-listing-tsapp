class PageObject < ActiveRecord::Base
  include ThriveSmartObjectMethods
  self.caching_default = 'interval[5]' #[in :forever, :page_update, :any_page_update, 'data_update[datetimes]', :never, 'interval[5]']

  has_many :groups, :order => :position, :dependent => :destroy
  attr_accessor :ungrouped_listings, :added_groups
  
  validates_associated :groups
  
  after_save :save_groups

  # Override caching information to be on data_update of the data path
  def caching
    @caching = "data_update[#{data_path}]"
  end
  
  # TODO implement proper cloning
  
  def parse_data(data_array)
    arry = data_array.dup
    self.groups.each { |g| g.grab_listings(arry) }
    self.ungrouped_listings = arry
  end
  
  
  # Responsible for removing and adding all groups to this page_object. The general flow is:
  #  If the group isn't a part of the groups array already, save to added_groups for after_save
  #  If the group is missing from the array, mark it to be removed for after_save 
  def assigned_groups=(array_hash)
    # Find new groups (but no duplicates)
    self.added_groups = []
    array_hash.each do |h|
      unless groups.detect { |c| c.id.to_s == h[:id] } || self.added_groups.detect { |f| f.id.to_s == h[:id] }
        c = !h[:id].blank? ? Group.find(h[:id]) : Group.new({:page_object => self})
        c.attributes = h.reject { |k,v| k == :id } # input values, but don't try to overwrite the id
        self.added_groups << c unless c.nil?
      end
    end
    # Delete removed groups
    groups.each do |c|
      if h = array_hash.detect { |h| h[:id] == c.id.to_s }
        c.attributes = h.reject { |k,v| k == :id }
      else
        c.destroy_association = 1
      end
    end
  end
  
  protected

    # Destroy groups marked for deletion, and adds groups marked for addition.
    # Done this way to account for association auto-saves.
    def save_groups
      self.groups.each { |c| if c.destroy_association? then c.destroy else c.save end }
      self.added_groups.each { |c| c.save unless c.nil? } unless self.added_groups.nil?
    end
end
