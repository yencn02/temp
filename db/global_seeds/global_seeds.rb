#---------------------------------------------------------------------------------------------
#-Task Statuses ------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------
TaskStatus.enumeration_model_updates_permitted = true    
TaskStatus.find_or_create_by_name :name => "will", :display_name => "Will"
TaskStatus.find_or_create_by_name :name => "did", :display_name => "Did"
TaskStatus.find_or_create_by_name :name => "cant", :display_name => "Can't"
TaskStatus.find_or_create_by_name :name => "waiting", :display_name => "Waiting"
TaskStatus.find_or_create_by_name :name => "cancelled", :display_name => "Cancelled"
TaskStatus.enumeration_model_updates_permitted = false
#---------------------------------------------------------------------------------------------
#-Friendship statuses ------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------
FriendshipStatus.enumeration_model_updates_permitted = true    
FriendshipStatus.find_or_create_by_name :name => "pending"
FriendshipStatus.find_or_create_by_name :name => "accepted"
FriendshipStatus.find_or_create_by_name :name => "denied"
FriendshipStatus.enumeration_model_updates_permitted = false
#---------------------------------------------------------------------------------------------
#-Standard task lists ------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------
StandardTaskList.find_or_create_by_title({:title => "General", :icon_name => "General.png"})
StandardTaskList.find_or_create_by_title({:title => "Work", :icon_name => "Work.png"})
StandardTaskList.find_or_create_by_title({:title => "Family", :icon_name => "Family.png"})
StandardTaskList.find_or_create_by_title({:title => "Personal", :icon_name => "Personal.png"})
StandardTaskList.find_or_create_by_title({:title => "Friends", :icon_name => "Friends.png"})
#---------------------------------------------------------------------------------------------

