# Original work Copyright (c) 2017 Lucas Chi
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Description:
#   Add notes to Pagerduty incidents
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot not actionable <incident_id> - Marks a Pagerduty incident as not actionable
#
# Author:
#   lchi

AUTH_TOKEN = process.env.PAGERDUTY_TOKEN
FROM_EMAIL = process.env.HUBOT_ACTIONABLE_FROM_EMAIL

module.exports = (robot) ->
  robot.respond /not actionable\s*(\w+)?/i, (response) ->
    not_actionable response

not_actionable = (response) ->
  incident_id = response.match[1]

  note_data = JSON.stringify({
    note: {
      content: 'This incident was marked as NOT actionable via Slack'
    }
  })

  response.http("https://api.pagerduty.com/incidents/#{incident_id}/notes")
    .header('Accept', 'application/vnd.pagerduty+json;version=2')
    .header('Content-Type', 'application/json')
    .header('Authorization', "Token token=#{AUTH_TOKEN}")
    .header('From', FROM_EMAIL)
    .post(note_data) (err, res, body) ->
      if err
        throw err
      else if res.statusCode not in [200, 201]
        response.send "ERROR: Response code from Pagerduty: #{res.statusCode}"
      else
        response.send "OK: Incident #{incident_id} was marked as not actionable"
