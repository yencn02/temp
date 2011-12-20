class AddComatoseSupport < ActiveRecord::Migration

  # Schema for Comatose version 0.7+
  def self.up
    create_table :comatose_pages do |t|
      t.integer   "parent_id"
      t.text      "full_path",   :default => ''
      t.string    "title",       :limit => 255
      t.string    "slug",        :limit => 255
      t.string    "keywords",    :limit => 255
      t.text      "body"
      t.string    "filter_type", :limit => 25, :default => "Textile"
      t.string    "author",      :limit => 255
      t.integer   "position",    :default => 0
      t.integer   "version"
      t.datetime  "updated_on"
      t.datetime  "created_on"
    end
  end

  def self.down
    ComatosePage.drop_versioned_table
    drop_table :comatose_pages
  end

end
