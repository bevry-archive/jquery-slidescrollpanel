module.exports =

	templateData:
		package: packageData = require('./package.json')
		site:
			url: packageData.homepage
			services:
				twitterTweetButton: "balupton"
				twitterFollowButton: "balupton"
				githubFollowButton: "balupton"
				gauges: '51a70d55613f5d041c000012'
				googleAnalytics: 'UA-4446117-1'

	plugins:
		highlightjs:
			removeIndentation: true

	environments:
		development:
			templateData:
				site:
					services:
						gauges: false
						googleAnalytics: false
