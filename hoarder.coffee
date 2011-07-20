http = require 'http'

host = 'www.google.com'
MAXIMUM_RESULTS_TO_CHECK = 404

# uses regular expressions on html document
# problem context-grammar-nazi?

# match the url on a page
urlRegex = '<div class="jd"><a class="p" href="(.*?)".*?</div>'

# figure out if there are more search results
navRegex = '<div class="kowpfb">.*?<a href=".*?" >Next page.*?</div>'

# check if the hyperlink is a redirect or plain url
# because the behaviour is not consistent, depends on server
redirectRegex = '^/m/url?(.*?&amp;)?q=(.*?)(&amp;.*)?$'

# collect the matching url for google search on query q
module.exports = (q, regex) ->
	# some callback will be supplied to hoard() to handle urls
	callback = () -> 0

	# the number of results already fetched
	skip = 0

	# stores urls (filter applied)
	results = []

	# should continue fetching?
	completed = false

	collectUrl = (s) ->
		# this will peel out and unescape url, in case of redirect
		u = if (m = new RegExp(redirectRegex).exec(s)) then unescape(m[2]) else s
		results.push(u) if (not regex or regex.test(u))

	fetchNext = () ->
		path = '/pda?q=' + escape(q) + '&start=' + skip
		client = http.createClient 80, host
		request = client.request 'GET', path, {
			'host': host,
			'connection': 'Close'
		}
		request.on 'response', (response) ->
			document = ''
			response.on 'data', (chunk) ->
				document += chunk.toString()
			response.on 'end', () ->
				r = new RegExp(urlRegex, 'g')
				while (m = r.exec(document))
					skip++
					completed = (skip > MAXIMUM_RESULTS_TO_CHECK)
					break if completed
					collectUrl(m[1])
				return if (completed or not (new RegExp(navRegex).test(document))) then callback(results) else fetchNext()
		request.end()

	# the trigger
	hoard = (cb) ->
		callback = cb
		fetchNext()

	# 1. expose them public method, for they are worth it
	# 2. avoid coffeescript from returning self as the last defined function
	return {hoard: hoard}

