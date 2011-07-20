hoarder = require './hoarder'

callback = (urls) ->
	for url, i in urls
		console.log (i + 1) + '. ' + url

# search coffee on theoatmeal
new hoarder('coffee site:theoatmeal.com').hoard(callback)

# search coffee on theoatmeal, blog link only
new hoarder('coffee site:theoatmeal.com', /^http:\/\/theoatmeal.com\/blog/).hoard(callback)

