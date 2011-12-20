Feature: Cancel a task
  In order to cancel a task
  As a user
  I want to cancel a task i sent someone
  So that I Want to see the undo counter
  And move it to "cancel" category
  And notify the assignee that the task is cancelled
  
  Background:
    Given the following users exist
      | email    | password |
      | u1@d.com | 123456   |
      | u2@d.com | 123456   |
    And users are confirmed
    And a user: "u1" should exist with email: "u1@d.com"
    And a user: "u2" should exist with email: "u2@d.com"
    And a task exists with description: "from me desc", assigner: user "u1", assignee: user "u2"
    And I am on the sign in page
    And I am logged in as "u1@d.com" with password "123456"
  
  @javascript
  @firebug
  Scenario: Cancel
    Given I am in "from me" tab
    And I hold for "3" seconds
    Then I should see "from me desc"
    When I do admin action "cancel"
    And I hold for "5" seconds
    Then I should see "You cancelled this task"
    And I hold for "10" seconds
    And I should not see "You cancelled this task"
    
  @javascript
  @firebug
  @focus
  Scenario: Cancel then undo
    Given I am in "from me" tab
    And I hold for "3" seconds
    Then I should see "from me desc"
    #------------------------------------------------
    When I do admin action "cancel"
    Then I should see "You cancelled this task"
    And I hold for "3" seconds
    #------------------------------------------------
    When I click link with "title" "undo"
    Then I should not see "You cancelled this task"
    And I hold for "3" seconds
    #------------------------------------------------
    When I am browsing "cancelled" tasks
    And I hold for "3" seconds
    Then I should not see "from me desc"
    