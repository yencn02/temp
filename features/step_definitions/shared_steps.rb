And /^users are confirmed$/ do
  User.all.each do |u|
    u.confirm!
  end
end

And /^I fill in the hidden field "(.*?)" with "(.*?)"$/ do |field, value|
  msg = "cannot set value"
  page.locate(:css, "##{field}", msg).set(value) 
end

Given /^I want to break$/ do
  require 'ruby-debug'
  debugger
end

And /^I want to do some debugging$/ do
  User.all.each do |u|
    puts "......u: #{u.email}"
  end
  
  Task.all.each do |t|
    puts "..t: #{t.description}..#{t.assigner.email}..#{t.status.name}"
  end
end

And /^I hold for "(.*?)" seconds$/ do |seconds|
  sleep seconds.to_i
end

And /^I "(.*?)" confirmation$/ do |action|
  page.driver.browser.switch_to.alert.accept    if action == "accept"
  page.driver.browser.switch_to.alert.dismiss   if action == "refuse"
  puts page.driver.browser.switch_to.alert.text if action == "read"
end

And /^I sign out$/ do
  visit destroy_user_session_path
end

And /^I blur from "(.*?)"$/ do |item| 
  page.execute_script("jQuery(\"[name='#{item}']\").blur();")
end

When /^I click link with "(.*?)" "(.*?)"$/ do |attr, val|
  if attr == "id"
    page.execute_script %Q"jQuery(\"a##{val}\").click();"
  elsif attr == "class"
    page.execute_script %Q"jQuery(\"a.#{val}\").click();"
  else
    page.execute_script %Q"jQuery(\"a[#{attr}='#{val}']\").click();"
  end
end