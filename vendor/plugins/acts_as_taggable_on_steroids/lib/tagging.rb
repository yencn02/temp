class Tagging < ActiveRecord::Base #:nodoc:
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true
  
  after_destroy :destroy_tag_if_unused

  #-BADR ADDITIONALS XTENSTIONS ------------------------------------
  scope :with_tags, lambda {|tags| {:select => :taggable_id, :conditions=>['tag_id in (?)', tags]}}
  scope :with_taggables, lambda {|taggable_ids| {:conditions=>['taggable_id in (?)', taggable_ids]}}

  # THANKS TO MOSTAFA BADAWY FOR THE SQL QUERY
  def self.with_tag_ids(tag_ids)
    in_condition = tag_ids.blank? ? "" : "and T1.tag_id in (#{tag_ids.join(',')})) = #{tag_ids.length}" 
    sql_string = <<-STR
                    select T.taggable_id 
                    from taggings T  
                    where (
                      select count(*) 
                      from taggings T1 
                      where T1.taggable_id = T.taggable_id 
                        #{in_condition}
                      group by T.taggable_id
                 STR
    Tagging.find_by_sql(sql_string)
  end
  
  private
  
  def destroy_tag_if_unused
    if Tag.destroy_unused
      if tag.taggings.count.zero?
        tag.destroy
      end
    end
  end
end
