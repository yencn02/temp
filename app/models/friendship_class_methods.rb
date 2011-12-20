module FriendshipClassMethods
  
  def friendship_exists?(user, friend) # Return true if the persons are (possibly pending) connections.
    not conn(user, friend).nil?
  end
  
  def friends?(user, friend)
    first(:conditions => ["user_id = ? AND friend_id = ? AND friendship_status_id = ?", user.id, friend.id, FriendshipStatus[:accepted].id ])
  end  
  
  def request(user, friend)
    side_one = new(:user_id => user.id, :friend_id => friend.id, :initiator => true)
    side_one.friendship_status_id = FriendshipStatus[:pending].id
    side_two = new(:user_id => friend.id, :friend_id => user.id)
    side_two.friendship_status_id = FriendshipStatus[:pending].id

    transaction do
      side_one.save!      
      side_two.save!
    end
    
    side_one
  end
  
  def accept(user, friend)
    transaction do
      accepted_at = Time.now
      accept_one_side(user, friend, accepted_at)
      accept_one_side(friend, user, accepted_at)
    end
  end
  
  def deny(user, friend)
    transaction do
      side_one = conn(user, friend)
      side_one.friendship_status_id = FriendshipStatus[:denied].id
      side_one.save!
      
      side_two = conn(friend, user)
      side_two.friendship_status_id = FriendshipStatus[:denied].id
      side_two.save!
    
    	
    
    end
  end
  
  def connect(user, friend)
    transaction do
      request(user, friend)
      accept(user, friend)
    end
    conn(user, friend)
  end
  
  def breakup(user, friend)
    transaction do
      destroy(conn(user, friend))
      destroy(conn(friend, user))
    end
  end
  
  def conn(user, friend)
    find_by_user_id_and_friend_id(user, friend)
  end
  
  def accepted?(user, friend)
    conn(user, friend).accepted?
  end
  
  def connected?(user, friend)
    friendship_exists?(user, friend) and accepted?(user, friend)
  end
  
  def pending?(user, friend)
    friendship_exists?(user, friend) and conn(friend, user).pending?
  end
  
  def accept_one_side(user, friend, accepted_at)
    conn = conn(user, friend)
    conn.friendship_status_id = FriendshipStatus[:accepted].id
    conn.accepted_at = accepted_at
    conn.save! 
  end

end