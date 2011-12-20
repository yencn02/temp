User.blueprint do
  username    {|index| "user_#{index}"}
  email       {|index| "user_#{index}@domain.com"}
  password         {'123456'}
  mobile_number    {'0123456798'}
  first_name       {'u f n'}
  last_name        {'u l n'}
end

Task.blueprint do
  assignee    {User.make}
  assigner    {User.make}
  task_list   {assignee.task_lists.first}
  status      {TaskStatus[:waiting]}
end

TaskStatus.blueprint do
end