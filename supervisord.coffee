# Description:
#   Interact with supervisord
#
# Dependencies:
#   supervisord
#
# Commands:
#   hubot supervisorctl status <host> - get process info for specified host
#   hubot supervisorctl status <host> <name> - get process info of specified process
#
# Author:
#   Raymond Tong

supervisordapi = require "supervisord"
_ = require "lodash"

module.exports = (robot) ->
  robot.respond /supervisorctl status ([^ ]+)$/i, (res) ->
    host = res.match[1]
    supclient = supervisordapi.connect("http://" + host + ":5009")
    processinfo = supclient.getAllProcessInfo((err, result) -> 
      if err
        res.send "(ERROR) supervisord status #{host} #{err}"
      else
        apps = _.map(result, (obj) ->
          return obj.name + "\t" + obj.statename + "\t" + obj.description
        )
        res.send apps.join("\n")
    )

  robot.respond /supervisorctl status ([^ ]+) ([^ ]+)$/i, (res) ->
    host = res.match[1]
    name = res.match[2]
    supclient = supervisordapi.connect("http://" + host + ":5009")
    processinfo = supclient.getProcessInfo(name, (err, result) ->  
      if err 
        res.send "(ERROR) supervisord status #{host} #{name} #{err}"
      else
        app = result.name + "\t" + result.statename + "\t" + result.description
        res.send app
    )

