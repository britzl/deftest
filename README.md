![](logo.jpg)

# DefTest
Unit testing is a software development process in which the smallest testable parts of the code are individually and independently tested. The purpose is to verify an expected and defined behavior in one part of the code as another part of it is changed to guarantee that it still behaves as expected even after the change. Being able to catch unforeseen side effects (read: bugs) early reduces the effort and cost involved in fixing them. Unit tests can be run manually but it is more common to automate the process, typically when new code is added to a version control system such as Git. This process is also known as [Continuous Integration, or CI](https://www.wikiwand.com/en/Continuous_integration) since the local changes are integrated into a shared repository, often several times a day.

This project shows one way of running unit tests in Defold using the [Telescope](https://github.com/norman/telescope) unit testing framework. Telescope was chosen thanks to it's simplicity and clean code. A couple of other popular unit testing frameworks are:

* [Busted](http://olivinelabs.com/busted/)
* [Lust](https://github.com/bjornbytes/lust)
* [lua-TestMore](https://github.com/fperrad/lua-TestMore)
* [Luaunit](https://github.com/bluebird75/luaunit)

## Usage
DefTest is provided as a Defold library project for easy integration in your own project. Add the following line to your project dependencies in game.project:

	https://github.com/britzl/deftest/archive/master.zip

```Lua
It is recommended to run your unit tests from its own collection, set as the bootstrap collection in game.project. Add a game object and a script to the collection and use the script to set up your tests. Add objects, which scripts you want to test.

For running integration tests, it is important to add integration_test_manager.go located in the /deftest/integration/ folder to the collection and link it to deftest with deftest.set_integration_test_manager(path_to_integration_manager_object).

deftest.add() adds unit tests, which test pure logic.
deftest.add_integration() adds tests, which can be used to test scripts.

An example:

	local deftest = require "deftest.deftest"
	local some_tests = require "test.some_tests"
	local other_tests = require "test.other_tests"
	local integration_tests = require "test.some_integration_tests"

	function init(self)
		deftest.set_integration_test_manager("/integration_test_manager#integration_test_manager")
		deftest.add_integration(some_integration_tests)
		deftest.add(some_tests)
		deftest.add(other_tests)
		deftest.run()
	end

And a Lua file containing some tests:

	return function()
		describe("Some tests", function()
			before(function()
				-- this function will be run before each test
			end)

			after(function()
				-- this function will be run after each test
			end)

			test("Basic arithmetic", function()
				assert(1 + 1 == 2)
			end)
		end)
	end
	
Another Lua file containing integration tests, which are used to test game objects:

	return function()
		describe("car", function()
			test("should move on input", 0.2, function()
				-- 0.2 seconds is the time limit for this test.
				before(function()
					msg.post("/car1", "right")
				end)

				on_wait(function() -- This function will be executed after 0.2 seconds after "before".
					msg.post("/car1", "stop")
					local pos = go.get_position("/car1")
					assert_less_than(pos.x, 142)
					assert_greater_than(pos.x, 138)
				end)
			end)

			test("should send 'game_over' message when colliding with obstacles", 5, function()
				-- 5 seconds is the time limit for this test.
				before(function()
					msg.post("/car2", "set_game_url", {game_url = msg.url()})
					factory.create("/obstacle_factory#obstacle_factory", vmath.vector3(400, 200, 0))
				end)

				on_message("game_over", "/car2#car", function()
					-- This function will be executed on receiving message with message_id "game_over"
					-- from script "/car2#car".
					-- If the message is not received after 5 seconds after "before", test fails.
					assert(true)
				end)
			end)
		end)
	end

```

Unit tests for pure logic and integration tests for scripts use different syntax.
More examples of the Telescope unit test syntax can be seen in [telescope_syntax.lua](https://github.com/britzl/deftest/blob/master/test/telescope_syntax.lua) and a full example of how to setup and run tests can be seen [in the test folder](https://github.com/britzl/deftest/tree/master/test).
Integration tests use different syntax, example of which can be seen in [test_integration_tests.lua](https://github.com/britzl/deftest/blob/master/test/test_integration_tests.lua).

### Custom asserts
Telescope provides a system for custom asserts with the following asserts available by default:

* assert_blank(a) - true if a is nil, or the empty string
* assert_empty(a) - true if a is an empty table
* assert_equal(a, b) - true if a == b
* assert_error(f) - true if function f produces an error
* assert_false(a) - true if a is false
* assert_greater_than(a, b) - true if a > b
* assert_gte(a, b) - true if a >= b
* assert_less_than(a, b) - true if a < b
* assert_lte(a, b) - true if a <= b
* assert_match(a, b) - true if b is a string that matches pattern a
* assert_nil(a) - true if a is nil
* assert_true(a) - true if a is true
* assert_type(a, b) - true if a is of type b
* assert_not_blank(a)  - true if a is not nil and a is not the empty string
* assert_not_empty(a) - true if a is a table, and a is not empty
* assert_not_equal(a, b) - true if a ~= b
* assert_not_error(f) - true if function f does not produce an error
* assert_not_false(a) - true if a is not false
* assert_not_greater_than(a, b) - true if not (a > b)
* assert_not_gte(a, b) - true if not (a >= b)
* assert_not_less_than(a, b) - true if not (a < b)
* assert_not_lte(a, b) - true if not (a <= b)
* assert_not_match(a, b) - true if the string b does not match the pattern a
* assert_not_nil(a) - true if a is not nil
* assert_not_true(a) - true if a is not true
* assert_not_type(a, b) - true if a is not of type b

DefTest adds these additional asserts:

* assert_same(...) - true if all values are the same (using deep compare of values)
* assert_unique(...) - true if all values are unique (using deep compare of values)
* assert_equal(...) - true if all values are equal (using equality operator, ==)

## Running tests from a CI system
The real power of unit tests is as we have learned when the tests can be automated and run for every change made to the code. There are many CI systems available and this project will also show how to integrate with some of the more popular CI systems out there. The main idea is to configure a physical or virtual machine so that tests can be run frequently and with predictable results every time. Once the configuration of the machine is complete a script of some kind executes the tests and depending on the outcome different actions are taken. Failed tests could perhaps trigger e-mail notifications to team members or a dashboard display to light up while successful tests could trigger a build of binaries based on the tested code.

The tests for this project can either be executed from within Defold or through the [run.sh](https://github.com/britzl/deftest/blob/master/.test/run.sh) script from the command line. The script will download the latest headless version of the Defold engine and the command line build tool (bob.jar), build the project and run the tests.

### Using Travis-CI
The tests in this project are run on [Travis-CI](https://travis-ci.org/britzl/deftest). The configuration can be seen in the [.travis.yml](https://github.com/britzl/deftest/blob/master/.travis.yml) file while the bulk of the work is done in the run.sh script.

[![Travis-CI](https://travis-ci.org/britzl/deftest.svg?branch=master)](https://travis-ci.org/britzl/deftest)

For an up-to-date version of the script and steps needed to run on Travis-CI please refer to the [defold-travis-ci](https://github.com/britzl/defold-travis-ci) project.

### Filtering tests to run
You can specify a string pattern (using normal Lua pattern matching) that will be matched against the test names to filter which tests to run:

```Lua
	-- only run tests containing 'foobar'
	deftest.run({ pattern = "foobar" })
```

### Code coverage
DefTest can collect code coverage stats to measure how much of your code that is tested. Code coverage data is collected using [LuaCov](https://github.com/keplerproject/luacov), specifically code [from a LuaCov fork](https://github.com/britzl/luacov) where the code has undergone some minor alterations to work well with Defold. Code coverage is not automatically collected. You can enable code coverage collection like this:

```Lua
    deftest.run({ coverage = { enabled = true } })
```

When the tests have completed a code coverage report will be generated to `luacov.report.out` and raw stats to `luacov.stats.out`. The report can be uploaded directly to a service such as [codecov.io](https://codecov.io) or the stats can be formatted into a report format accepted by other services such as [coveralls.io](http://coveralls.io/).

## Limitations
Unit testing in Defold works best when testing Lua modules containing pure logic. Testing script and gui_script files is more related to integration tests as it not only involves your code, but also visual components and interaction between the different game objects and the systems provided by the engine. If your scripts contains complex code that you wish to test it is recommended to move the code to a Lua module and test just that module.

Integration tests are run simultaneously, so it is recommended to make copies of objects for different tests, so they do not conflict with each other.
