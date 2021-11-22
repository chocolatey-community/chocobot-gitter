# Description:
#   When enabled in a Gitter room, should remove all new messages
#
# Commands:
#   hubot lockdown - Adds the room to a list of rooms to lock down.
#   .+ - When a room is locked down, removes any messages it hears that aren't from a mod.
#
# Author:
#   jpruskin

module.exports = (robot) ->
  # Helpful, thanks to https://doatt.com/2015/02/19/the-hubot-msg-object/index.html
  # robot.respond /debug/, (msg) ->
  #   msg.finish()
  #   console.log Object(msg)

  moderators = [
    '562e08ce16b6c7089cb8459f'  # pauby
    '530cd1a05e986b0712efb4ce'  # gep13
    '6064213c6da037398478addf'  # jpruskin
  ]

  lockedRooms = [
      '53190d1b5e986b0712efd33c'  # chocolatey/chocolatey.org
      '54d1cb5fdb8155e6700f6c9c'  # chocolatey/chocolatey-oneget
      '531444a55e986b0712efc533'  # chocolatey/chocolatey
      '530cd0b45e986b0712efb4cb'  # chocolatey/ChocolateyGUI
      '54bc1bf1db8155e6700ecc71'  # chocolatey/choco
      '58b5ba05d73408ce4f4d818c'  # chocolatey/chocolatey-coreteampackages
      '54e9026715522ed4b3dc4cb6'  # chocolatey/puppet-chocolatey
      '58f69dc0d73408ce4f595206'  # chocolatey/cChoco
      '5e2f484fd73408ce4fd7ed4b'  # chocolatey-community/community
      '5af09c78d73408ce4f98708a'  # chocolatey/Boxstarter
    ]

  robot.respond /lockdown\W?(?<RoomId>[a-z0-9]{24})?$/i, (msg) ->
    msg.finish()

    if msg.match.groups.RoomId
      room = msg.match.groups.RoomId.trim()
      # Looking up a room is possible, if we wanted to take RoomName
    else
      room = msg.message.room

    if msg.message.user.id in moderators
      if "#{room}" in lockedRooms
        robot.logger.info "#{msg.message.user.name} requested #{room} be unlocked."
        lockedRooms = lockedRooms.filter (word) -> word isnt room
      else
        robot.logger.info "#{msg.message.user.name} requested #{room} be locked."
        lockedRooms.push("#{room}")
    else
      msg.reply "No. You're not allowed to initiate that, #{msg.message.user.name}."

  robot.hear /.+/i, (msg) ->
    if msg.message.room in lockedRooms
      msg.finish()

      if msg.message.user.id not in moderators
        robot.logger.info "[DELETING]#{msg.message.user.name}: #{msg.message.text}"
        robot.http("https://api.gitter.im/v1/rooms/#{msg.message.room}/chatMessages/#{msg.message.id}")
          .header('Authorization', "Bearer #{process.env.HUBOT_GITTER2_TOKEN}")
          .del() (err, res, body) ->
            if (body)
              robot.logger.info "Deleting '#{msg.message.room}/chatMessages/#{msg.message.id}': #{body}"
            if (err)
              robot.logger.error "Failed to delete '#{msg.message.room}/chatMessages/#{msg.message.id}': #{body}"

        # Respond to the user privately, if possible. May need to implement this as msg.send userid, message
        # msg.sendPrivate "The #{msg.message.room} room has been moved to Discord - please join us at https://ch0.co/community"