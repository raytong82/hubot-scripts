# Description:
#   Interact with supervisord
#
# Dependencies:
#   mongodb
#
# Commands:
#   hubot vote list- display all voting
#   hubot vote <<name>> show - display content of vote named <<name>>
#   hubot create <<name>> - create vote named <<name>>
#   hubot vote <<name>> add <<choice>> - create a choice <<choice>> for vote named <<name>>
#   hubot vote <<name>> poll <<choice>> - poll for choice <<choice>> for vote named <<name>>
#
# Author:
#   Raymond Tong

_ = require "lodash"
mongodb = require "mongodb"
MongoClient = mongodb.MongoClient

module.exports = (robot) ->

  url = "mongodb://localhost:27017/hubot"

  numMap = {0:"zero", 1:"one", 2:"two", 3:"three", 4:"four", 5:"five", 6:"six", 7:"seven", 8:"eight", 9:"nine"}

  joinLines = (lines) ->
    return lines.join "\n"

  formatVote = (vote) ->
    return ":memo: Name: #{vote._id} \n" + joinLines _.map vote.choices, (choice, index) ->
      return "\t :#{numMap[index+1]}: Choice: #{choice.name}\n" + joinLines _.map choice.voters, (voter) ->
        return "\t\t :+1: #{voter}\n"


  robot.respond /vote list$/i, (res) ->
    MongoClient.connect url, (err, db) ->
      if err
        res.send "(ERROR) #{err}"
      else
        db.collection("vote").find().toArray (err, docs) ->
          if err != null
            res.send "(ERROR) #{err}"
          else
            votes = _.map docs, (vote) ->
              return formatVote vote
            res.send votes.join("\n")
            db.close

  robot.respond /vote ([^ ]+) show$/i, (res) ->
    votename = res.match[1]
    MongoClient.connect url, (err, db) ->
      if err
        res.send "(ERROR) #{err}"
      else
        criteria = {_id: votename}
        db.collection("vote").findOne criteria, (err, vote) ->
          res.send formatVote vote  
          db.close


  robot.respond /vote create ([^ ]+)$/i, (res) ->
    votename = res.match[1]
    MongoClient.connect url, (err, db) ->
      if err
        res.send "(ERROR) #{err}"
      else
        doc = {_id: votename}
        db.collection("vote").insertOne doc, (err, result) ->
          if err
            res.send "(ERROR) #{err}"
          else
            res.send "vote #{votename} created"
            db.close

  robot.respond /vote ([^ ]+) add ([^ ]+)$/i, (res) ->
    votename = res.match[1]
    choice = res.match[2]
    MongoClient.connect url, (err, db) ->
      if err
        res.send "(ERROR) #{err}"
      else
        criteria = {_id: votename}
        update = {$addToSet: {choices: {name: choice} } }
        db.collection("vote").updateOne criteria, update, (err, results) ->
          if err
            res.send "(ERROR) #{err}"
          else
            db.collection("vote").findOne criteria, (err, vote) ->
              res.send formatVote vote
              res.send "vote #{votename} added choice #{choice}"
            db.close

  robot.respond /vote ([^ ]+) poll ([^ ]+)$/i, (res) ->
        res.send "(ERROR) #{err}"
      else
        doc = {_id: votename}
        db.collection("vote").insertOne doc, (err, result) ->
          if err
            res.send "(ERROR) #{err}"
          else
            res.send "vote #{votename} created"
            db.close

  robot.respond /vote ([^ ]+) add ([^ ]+)$/i, (res) ->
    votename = res.match[1]
    choice = res.match[2]
    MongoClient.connect url, (err, db) ->
      if err
        res.send "(ERROR) #{err}"
      else
        criteria = {_id: votename}
        update = {$addToSet: {choices: {name: choice} } }
        db.collection("vote").updateOne criteria, update, (err, results) ->
          if err
            res.send "(ERROR) #{err}"
          else
            db.collection("vote").findOne criteria, (err, vote) ->
              res.send formatVote vote
              res.send "vote #{votename} added choice #{choice}"
            db.close

  robot.respond /vote ([^ ]+) poll ([^ ]+)$/i, (res) ->
    votename = res.match[1]
    choice = res.match[2]
    person = res.message.user.name
    MongoClient.connect url, (err, db) ->
      if err
        res.send "(ERROR) #{err}"
      else
        criteria = {_id: votename, "choices.name": choice}
        update = {$addToSet: {"choices.$.voters": person } }
        db.collection("vote").updateOne criteria, update, (err, results) ->
          if err
            res.send "(ERROR) #{err}"
          else
            db.collection("vote").findOne criteria, (err, vote) ->
              res.send formatVote vote
            res.send "vote #{votename} polled choice #{choice}"
            db.close

