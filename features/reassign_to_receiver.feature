Feature: Reassign a task to receiver
  In order to reassign a task I assigned someone to myself
  As a user
  I want to reassign a task I assigned someone to myself
  So that I Want to see the undo counter
  And notify the assignee that the task is reassigned to me
  And the task assignee becomes me
  
  Background:
    Given the following users exist
      | email    | password |
      | u1@d.com | 123456   |
      | u2@d.com | 123456   |
    And users are confirmed
    Then a user: "u1" should exist with email: "u1@d.com"
    And a user: "u2" should exist with email: "u2@d.com"
    And a task_status: "did" should exist with name: "did"
    And a task exists with description: "from me desc", assigner: user "u1", assignee: user "u2", status: "did"
    And I am on the sign in page
    And I am logged in as "u1@d.com" with password "123456"
  
  @javascript
  @firebug
  Scenario: Reassign to the same receiver
    Given I am in "from me" tab
    And I hold for "5" seconds
    And I am browsing "all" tasks
    And I hold for "5" seconds
    And I should see "from me desc"
    When I do admin action "reassign to assignee"
    And I "accept" confirmation
    And I hold for "5" seconds
    Then I should see "You reassigned this task to"
    And I hold for "10" seconds
    When I sign out
    And I am on the sign in page
    And I am logged in as "u2@d.com" with password "123456"
    And I hold for "5" seconds
    Then I should see "from me desc"
    When I am browsing "did" tasks
    And I hold for "5" seconds
    Then I should see "from me desc"
