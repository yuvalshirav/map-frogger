#= require "../../vendor/mocha/mocha.js"
#= require "../../vendor/chai/chai.js"
#= require "../../vendor/chai-jquery/chai-jquery.js"
#= require "../../vendor/sinon-chai/lib/sinon-chai.js"
#= require "../../vendor/sinonjs-built/lib/sinon.js"
#= require "config"
#= require_tree "specs/"

if navigator.userAgent.indexOf('PhantomJS') < 0
	mocha.run()
