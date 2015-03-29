# Hubot: hubot-github-repo-event-notifier

Notifies about any available GitHub repo event via webhook.

See [`src/github-repo-event-notifier.coffee`](src/github-repo-event-notifier.coffee) for full documentation.

## Installation

Add **hubot-github-repo-event-notifier** to your `package.json` file:

```json
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-scripts": ">= 2.4.2",
  "hubot-github-repo-event-notifier": ">= 0.0.0",
  "hubot-hipchat": "~2.5.1-5",
}
```

Add **hubot-github-repo-event-notifier** to your `external-scripts.json`:

```json
["hubot-github-repo-event-notifier"]
```

Run `npm install`

## Configuration

This plugin doesn't offer any commands for the hubot to listen to, it receives
webhooks from GitHub and lets you know in channel what happened.  To set up:

   1. Create a new webhook for your `myuser/myrepo` repository at:
      <https://github.com/myuser/myrepo/settings/hooks/new>

   2. Select the individual events to minimize the load on your Hubot.

   3. Add the url: `<HUBOT_URL>:<PORT>/hubot/gh-repo-events[?room=<room>]`
      (Don't forget to urlencode the room name, especially for IRC. Hint: # = %23)

With a deployed hubot, configure each repository to webhook to [hubot_url_and_port]/hubot/gh-repo-events.  You will also need to set an environment variable `HUBOT_GITHUB_EVENT_NOTIFIER_TYPES` which can contain a comma-separated list (NB: without spaces!) of the events you'd like to subscribe to.  The list of options is here: http://developer.github.com/webhooks/#events

## Development Testing

Ideally, you'd write tests and put them in our `test/` directory.

If you just want to mess around with some things, we've bundled a REPL for
you which has some fixture data and exposes the core functionality of the
processing of events. To boot up the reply, launch `script/console`.

* Sample payloads are available via the variable `eventPayloads`. It
  contains a key for each event type, e.g. `pull_request` or `page_build`.
* Each processing function is available via `actions`. This object contains
  a key for each event type, e.g. `pull_request` or `page_build`. It takes
  the payload object and the callback function as its parameters, in that
  order.

When testing webhooks, consider adding an additional IRC room to the list of rooms and then adding the additional parameter to your webhook, something like `?room=%23my-test-room` - this way you can deploy your bot but have it only make noise in a specific room.  I do this with a webhook on a test repository to work through the use cases.
