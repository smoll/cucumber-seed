# cucumber-seed
Cucumber seed for browser-based acceptance testing, with [dockerized selenium](https://github.com/SeleniumHQ/docker-selenium) for headless

## Prerequisites

0. [Get Docker](https://docs.docker.com/installation/) for headless (boot2docker should also work out-of-the-box)

## Usage

0. Write a feature file `google.feature` and save it in the `features` directory

    ```
    Feature: Google
        In order to test google
        As a tester
        I need to visit google

    Scenario: Visit the site
        When I visit Google
        Then I should be on the Google site
    ```

0. Use the [PageObject pattern](https://github.com/cheezy/page-object/wiki/Get-me-started-right-now%21), as implemented by the [page-object gem](https://github.com/cheezy/page-object). Create a GooglePage that inherits from BasePage (both of these files created in the `lib/pages` directory)

    **base_page.rb:**

    ```
    class BasePage
      include PageObject
    end
    ```

    **google_page.rb:**

    ```
    class GooglePage < BasePage
      page_url 'google.com'
    end
    ```

0. Create step definitions (if you run `cucumber` it will generate some that you can copy & paste) in a file `google_steps.rb` in the `features/step_definitions` directory

    ```
    When(/^I visit Google$/) do
      visit GooglePage
    end

    Then(/^I should be on the Google site$/) do
      on(GooglePage) do |page|
        expect(page.current_url).to include 'google.com'
      end
    end
    ```

0. Run the entire suite headlessly (will spawn and kill docker containers on the fly) by doing

    ```
    $ cucumber HEADLESS=t
    ```

## TODOs

0. Generate the "sample feature" and step definitions in an Aruba test, instead of committing them directly

0. Parallelize this (using GNU parallel or the [parallel_tests gem](https://github.com/grosser/parallel_tests))

0. Convert this project from a "seed" to a generator similar to [testgen](https://github.com/cheezy/testgen)
