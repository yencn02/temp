Feature: Mark task as done
  In order to mark task as done
  As a user
  I want to mark the task i sent someone as done
  So that I Want to see the undo counter
  And move it to "did" category
  And notify the assignee that the task is marked done
  
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
  Scenario: Mark a task as done
    Given I am in "from me" tab
    And I hold for "3" seconds
    Then I should see "from me desc"
    When I do admin action "mark done"
    And I hold for "3" seconds
    Then I should see "You marked this task as done"
    And I hold for "10" seconds
    Then I should not see "You marked this task as done"
    When I am browsing "did" tasks
    And I hold for "3" seconds
    Then I should see "from me desc"
    
  @javascript
  @firebug
  Scenario: Mark a task as done then undo
    Given I am in "from me" tab
    And I hold for "3" seconds
    Then I should see "from me desc"
    #------------------------------------------------
    When I do admin action "mark done"
    And I hold for "3" seconds
    Then I should see "You marked this task as done"
    #------------------------------------------------
    When I click link with "title" "undo"
    Then I should not see "You marked this task as done"
    And I hold for "3" seconds
    #------------------------------------------------
    When I am browsing "did" tasks
    And I hold for "3" seconds
    Then I should not see "from me desc"
