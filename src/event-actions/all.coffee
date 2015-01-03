#! /usr/bin/env coffee

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

buildNewIssueOrPRMessage = (data, eventType, callback) ->
  pr_or_issue = data[eventType]
  if data.action == 'opened'
    mentioned_line = ''
    if pr_or_issue.body?
      mentioned_line = extractMentionsFromBody(pr_or_issue.body)
    callback "New #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" by #{pr_or_issue.user.login}: #{pr_or_issue.html_url}#{mentioned_line}"
  else if data.action == 'reopened'
    callback "Reopened #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" by #{pr_or_issue.user.login}: #{pr_or_issue.html_url}"
  else if data.action == 'closed'
    if pr_or_issue.merged
      callback "Merged: #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" by #{pr_or_issue.user.login} (#{pr_or_issue.html_url})"
    else
      callback "Closed #{eventType.replace('_', ' ')} \"#{pr_or_issue.title}\" without merge by #{pr_or_issue.user.login} (#{pr_or_issue.html_url})"


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
    callback "New comment on \"#{data.issue.title}\" (#{data.comment.html_url}) by #{data.comment.user.login}: \"#{data.comment.body}\""

  push: (data, callback) ->
    callback "#{data.sender.login} pushed #{data.size} commits to #{data.ref}"
