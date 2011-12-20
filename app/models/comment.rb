class Comment < ActiveRecord::Base
  include Notifier
  after_create :notify_comment_target
  include ActsAsCommentable::Comment
  belongs_to :commentable, :polymorphic => true
  default_scope :order => 'created_at ASC'
  # NOTE: Comments belong to a user
  belongs_to :user
  attr_accessor :dont_notify #virtual boolean attribute to prevent notification from being sent when reassigning task to yourself 

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  def notify_comment_target
    send_notification({:type=>'CommentNotification', :comment=>self}) unless dont_notify
  end

end
