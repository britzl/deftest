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

It is recommended to run your unit tests from its own collection, set as the bootstrap collection in game.project. Add a game object and a script to the collection and use the script to set up your tests. An example:

	local deftest = require "deftest.deftest"
	local some_tests = require "test.some_tests"
	local other_tests = require "test.other_tests"

	function init(self)
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

More examples of the Telescope test syntax can be seen in [telescope_syntax.lua](https://github.com/britzl/deftest/blob/master/test/telescope_syntax.lua) and a full example of how to setup and run tests can be seen [in the test folder](https://github.com/britzl/deftest/tree/master/test).

## Running tests from a CI system
The real power of unit tests is as we have learned when the tests can be automated and run for every change made to the code. There are many CI systems available and this project will also show how to integrate with some of the more popular CI systems out there. The main idea is to configure a physical or virtual machine so that tests can be run frequently and with predictable results every time. Once the configuration of the machine is complete a script of some kind executes the tests and depending on the outcome different actions are taken. Failed tests could perhaps trigger e-mail notifications to team members or a dashboard display to light up while successful tests could trigger a build of binaries based on the tested code.

The tests for this project can either be executed from within Defold or through the [run.sh](https://github.com/britzl/deftest/blob/master/.test/run.sh) script from the command line. The script will download the latest headless version of the Defold engine and the command line build tool (bob.jar), build the project and run the tests.

### Using Travis-CI
The tests in this project are run on [Travis-CI](https://travis-ci.org/britzl/deftest). The configuration can be seen in the [.travis.yml](https://github.com/britzl/deftest/blob/master/.travis.yml) file while the bulk of the work is done in the run.sh script.

[![Travis-CI](https://travis-ci.org/britzl/deftest.svg?branch=master)]((https://travis-ci.org/britzl/deftest))

### Using Circle-CI
The tests in this project are run on [Circle-CI](https://circleci.com/gh/britzl/deftest). The configuration can be seen in the [circle.yml](https://github.com/britzl/deftest/blob/master/circle.yml) file while the bulk of the work is done in the run.sh script

[![CircleCI](https://circleci.com/gh/britzl/deftest.svg?style=svg)](https://circleci.com/gh/britzl/deftest)

## Limitations
Unit testing in Defold works best when testing Lua modules containing pure logic. Testing script and gui_script files is more related to integration tests as it not only involves your code, but also visual components and interaction between the different game objects and the systems provided by the engine. If your scripts contains complex code that you wish to test it is recommended to move the code to a Lua module and test just that module.
