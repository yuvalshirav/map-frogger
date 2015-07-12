url = 'http://localhost:3000/dist/'

casper.test.begin "Sample integration spec", (test) ->
	casper.start url, ->
		test.assertVisible "#content", "#content is visible"

	casper.run ->
		test.done()
