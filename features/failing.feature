Feature: Failing
    In order to test the browser restarts after a failure
    As a tester
    I need to test a failing scenario

Scenario: Incorrect assertion
    When I visit Google
    Then I should be on the Gooble site

Scenario: Correct assertion
    When I visit Google
    Then I should be on the Google site
