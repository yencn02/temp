class FriendshipsController < ApplicationController
	include Notifier
	layout false

	before_filter :authenticate_user!
	def accepted_friends
		# TODO: @next_page = (params[:page] || 1) + 1		
		if params[:page]
			@next_page = params[:page] + 1
		else
			@next_page = 2
		end

		@user = current_user
		@user_task_lists = current_user.task_lists
		@accepted_friends = current_user.accepted_friends

		respond_to :js
	end

	def search
		name = params[:friend][:name]
		@users = User.all(:conditions => ["CONCAT(first_name, last_name) like ?", '%' + name + '%'])
		render :layout => false
	end

	def import_people
		redirect_to "/oauth_consumers/google"
	end

	#  def people_import
	#    #raise Exception unless request.ssl?
	#    sites = {"gmail" => Contacts::Gmail, "yahoo"=> Contacts::Yahoo, "hotmail" => Contacts::Hotmail}
	#    email, password = params[:user][:email], params[:user][:password]
	#    @contacts = sites[params[:user][:from]].new(email, password).contacts
	#    d @contacts
	#    render :layout => false
	#  end

	def index
		@next_page = 2

		@user_task_lists = current_user.task_lists

		@user = current_user
		@accepted_friends = current_user.accepted_friends

		@cheevers = []

		if params[:finding_people]
			@contacts = current_user.contacts
			@cheevers_ids = params[:finding_people].split('-')
			@cheevers_ids.each do |cheever_id|
				@cheevers << User.find(cheever_id)
			end
		end

		respond_to do |format|
			format.html {render :layout => "home"}
		end
	end

	def invite
		@user = current_user
		@friend = User.find(params[:id])
		@accessible_task_lists = @user.task_lists.find_all_by_id(params[:permission_to_access])

		respond_to do |format|
			begin
        # TODO , remove debugging information   
				@friendship = Friendship.request(@user, @friend)
				@accessible_task_lists.each do |tl|
					tl.connections.create(:user_id => @friend.id)
				end
        # TODO , put the notifications names in constants file and refer to them
				send_notification({:type=>'NewConnectionNotification', :invitor=>@user, :invited=>@friend})
				format.js { render(:js => "colorboxClose('Requested friendship with #{@friend.name}.')") }
			rescue => e			  
				format.js { render( :js => "colorboxClose('Friendship request failed.')") }
			end
		end
	end

	def accept_all
		process_accepting

		format.js { render(:js => "alert('done');") }
	end

	def invite_all
		@user = current_user

		process_invitations

		respond_to :js
	end

	def invite_non_cheevers
		if params[:contacts_checked]
			params[:contacts_checked].each_key do |contact_id|
				Mailer.deliver_invitation_to_cheeve_it(current_user, Contact.find(contact_id.to_i).email)
			end
		end

		respond_to :js
	end

	def invited
		@user = current_user
		@friend = User.find(params[:id])
		@user_task_lists = @user.task_lists
	end

	def accepted
		@friendship = current_user.friendships_not_initiated_by_me.pending.find_by_friend_id(params[:id]) || raise(ActiveRecord::RecordNotFound)
		@friend = @friendship.friend
		@user_task_lists = current_user.task_lists
		@user = current_user

		respond_to :js
	end

	def accept
		@friendship = current_user.friendships_not_initiated_by_me.pending.find_by_friend_id(params[:id]) || raise(ActiveRecord::RecordNotFound)
		@accessible_task_lists = current_user.task_lists.find_all_by_id(params[:permission_to_access])
		@notification = Notification.find(:last, :conditions=>["user_id = ? and target_user_id = ? and resource_type = ?", @friendship.friend_id, @friendship.user_id, 'NewConnectionNotification'])
		respond_to do |format|
			begin
				@friendship.accept!

				@accessible_task_lists.each do |tl|
					tl.connections.create(:user_id => params[:id])
				end

				send_notification({:type=>'ConnectionResponseNotification', :user_id=>@friendship.user_id, :friend_id=>@friendship.friend_id, :action=>'accepted'})
				flash.now[:notice] = "The friendship was accepted."
			rescue
				flash.now[:error] = "Friendship cannot be accepted."
			end

			format.js
		end
	end

	def deny

		@friendship = current_user.friendships_not_initiated_by_me.pending.find_by_friend_id(params[:id])
		@friend = User.find(params[:id])

		begin
			@friendship.deny!
			
			send_notification({:type=>'ConnectionResponseNotification', :user_id=>@friendship.user_id, :friend_id=>@friendship.friend_id, :action=>'denied'})
			
			@message = "Friendship is denied."
		rescue
			@message = "Friendship cannot be denied."
		end
	end

	private

	def process_accepting
		if params[:checked]
			params[:checked].each_key do |friend_id|
				friend = User.find(friend_id.to_i)
				# TODO: use inject
				tasks = []
				params[:friend][friend_id.to_s].each_key do |task_list_id|
					tasks << TaskList.find(task_list_id.to_i)
				end
				friendship = current_user.friendships_not_initiated_by_me.pending.find_by_friend_id(friend.id) || raise(ActiveRecord::RecordNotFound)

				begin
					friendship.accept!

					tasks.each do |tl|
						tl.connections.create(:user_id => params[:id])
					end

					send_notification({:type=>'ConnectionResponseNotification', :user_id=>friendship.user_id, :friend_id=>friendship.friend_id, :action=>'accepted'})
					flash.now[:notice] = "The friendship was accepted."
				rescue
					flash.now[:error] = "Friendship cannot be accepted."
				end
			end
		end
	end

	def process_invitations
		if params[:checked]
			params[:checked].each_key do |friend_id|
				friend = User.find(friend_id.to_i)
				# TODO: use inject
				tasks = []
				params[:friend][friend_id.to_s].each_key do |task_list_id|
					tasks << TaskList.find(task_list_id.to_i)
				end

				@friendship = Friendship.request(@user, friend)

				tasks.each do |tl|
					tl.connections.create(:user_id => friend.id)
				end
				send_notification({:type=>'NewConnectionNotification', :invitor=>@user, :invited=>friend})
			end
		end
	end

# def destroy
#   respond_to do |format|
#     begin
#       @friend = current_user.friends.find(params[:friend_id])
#       Friendship.breakup(current_user, @friend)
#
#       flash[:notice] = "Friendship destroyed."
#       format.html { redirect_to friendships_path }
#     rescue
#       flash[:error] = "Friendship cannot be destroyed."
#       format.html { redirect_to friendships_path }
#     end
#   end
# end

end