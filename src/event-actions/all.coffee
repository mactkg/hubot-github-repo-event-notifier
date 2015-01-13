#! /usr/bin/env coffee

enableColors = process.env['HUBOT_GITHUB_EVENT_NOTIFIER_IRC_COLORS']

if enableColors?
  IrcColors = require "irc-colors"

unique = (array) ->
  output = {}
  output[array[key]] = array[key] for key in [0...array.length]
  value for key, value of output

extractMentionsFromBody = (body) ->
  mentioned = body.match(/(^|\s)(@[\w\-\/]+)/g)

  if mentioned?
    mentioned = mentioned.filter (nick) ->
      slashes = nick.match(/\//g)
      slashes is null or slashes.length < 2

    mentioned = mentioned.map (nick) -> nick.trim()
    mentioned = unique mentioned

    "\nMentioned: #{mentioned.join(", ")}"
  else
    ""

formatUser = (message) ->
  if IrcColors?
    "#{IrcColors.pink(message)}"
  else
    "#{message}"

formatLink = (message) ->
  if IrcColors?
    "#{IrcColors.blue(message)}"
  else
    "#{message}"

formatProse = (message) ->
  if IrcColors?
    "#{IrcColors.gray(message)}"
  else
    "#{message}"

buildNewIssueOrPRMessage = (data, eventType, callback) ->
  pr_or_issue = data[eventType]
  if data.action == 'opened'
    mentioned_line = ''
    if pr_or_issue.body?
      mentioned_line = extractMentionsFromBody(pr_or_issue.body)
    callback "New #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" by #{formatUser(pr_or_issue.user.login)}: #{formatLink(pr_or_issue.html_url)}#{mentioned_line}"
  else if data.action == 'reopened'
    callback "Reopened #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" by #{formatUser(pr_or_issue.user.login)}: #{formatLink(pr_or_issue.html_url)}"
  else if data.action == 'closed'
    if pr_or_issue.merged
      callback "Merged: #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" by #{formatUser(pr_or_issue.user.login)} (#{formatLink(pr_or_issue.html_url)})"
    else
      callback "#{formatUser(pr_or_issue.user.login)} closed #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" without merge (#{FormatLink(pr_or_issue.html_url)})"


module.exports =
  issues: (data, callback) ->
    buildNewIssueOrPRMessage(data, 'issue', callback)

  pull_request: (data, callback) ->
    buildNewIssueOrPRMessage(data, 'pull_request', callback)

  page_build: (data, callback) ->
    build = data.build
    if build?
      if build.status is "built"
        callback "#{build.pusher.login} built #{data.repository.full_name} pages at #{build.commit} in #{build.duration}ms."
      if build.error.message?
        callback "Page build for #{data.repository.full_name} errored: #{build.error.message}."

# comments on pull requests are also considered issue comments
  issue_comment: (data, callback) ->
    callback "New comment on \"#{data.issue.title}\" (#{formatLink(data.comment.html_url)}) by #{formatUser(data.comment.user.login)}: \"#{formatProse(data.comment.body)}\""

  push: (data, callback) ->
    if data.ref == 'refs/heads/master'
      commit_count = data.commits.length
      callback "#{formatUser(data.sender.login)} pushed #{commit_count} commits to #{data.repository.name}"
    else
      console.log("No notifications for pushes to not-master branches")
