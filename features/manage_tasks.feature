Feature: Manage tasks
  In order to manage tasks
  As a user
  I want to assign tasks to users
  
  Background:
    Given the following users exist
      | email    | password |
      | u1@d.com | 123456   |
    And users are confirmed
    And I am on the sign in page
    And I am logged in as "u1@d.com" with password "123456"
  
  @javascript
  Scenario: Assign new task
    When I fill in "task[description]" with "description 1"
    And I fill in "task[to_user_name]" with "u1@d.com"
    And I press "task_submit"
    Then I should see "description 1"
    And I should see "Task was successfully created."
