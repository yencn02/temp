Given /^the following tasks:$/ do |tasks|
  Task.create!(tasks.hashes)
end

And /^I am logged in as "(.*?)" with password "(.*?)"$/ do |email, password|
  fill_in "user_email", :with => email
  fill_in "user_password", :with => password
  click_button "user_submit"
end

When /^I delete the (\d+)(?:st|nd|rd|th) task$/ do |pos|
  visit tasks_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following tasks:$/ do |expected_tasks_table|
  expected_tasks_table.diff!(tableish('table tr', 'td,th'))
end

Given /^I am in "(.*?)" tab$/ do |tab|
  page.execute_script("jQuery('##{tab.gsub(/ /,"-")}-tab a').click()")
end

When /^I do admin action "(.*?)"$/ do |action|
  page.execute_script %Q"jQuery('.task-unit:first .#{action.gsub(/ /,"-")}').click();"
end

And /^I am browsing "(.*?)" tasks$/ do |filter|
  page.execute_script %Q"jQuery(\"div.show-me a[index='0']\").click();" if filter == "pending"
  page.execute_script %Q"jQuery(\"div.show-me a[index='1']\").click();" if filter == "all"
  page.execute_script %Q"jQuery(\"div.show-me a[index='2']\").click();" if filter == "waiting"
  page.execute_script %Q"jQuery(\"div.show-me a[index='3']\").click();" if filter == "will"
  page.execute_script %Q"jQuery(\"div.show-me a[index='4']\").click();" if filter == "did"
  page.execute_script %Q"jQuery(\"div.show-me a[index='5']\").click();" if filter == "cant"
  page.execute_script %Q"jQuery(\"div.show-me a[index='6']\").click();" if filter == "cancelled"
end
