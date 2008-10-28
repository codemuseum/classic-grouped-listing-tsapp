class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.references :page_object
      t.integer :position, :null => false, :default => 0
      t.string :name
      t.text :listings
    
      t.timestamps
    end
    add_index :groups, :page_object_id
    add_index :groups, :position
  end

  def self.down
    drop_table :groups
  end
end
