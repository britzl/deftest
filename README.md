# DefTest
Unit testing is a software development process in which the smallest testable parts of the code are individually and independently tested. The purpose is to verify an expected and defined behavior in one part of the code as another part of it is changed to guarantee that it still behaves as expected even after the change. Being able to catch unforeseen side effects (read bugs) early reduces the effort and cost involved in fixing them. Unit tests can be run manually but it is more common to automate the process, typically as a reaction to new code being added to a version control system such as Git.

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

## Running tests from a CI system
# Using Travis-CI
This project runs the example tests on [Travis-CI](https://travis-ci.org/britzl/deftest). The configuration can be seen in the [.travis.yml](https://github.com/britzl/deftest/blob/master/.travis.yml) file and the bulk of the work is done in the [run.sh](https://github.com/britzl/deftest/blob/master/.travis/run.sh) script. The run.sh script will download the latest headless version of the Defold engine and the command line build tool (bob.jar), build the project and run the tests.
