#encoding: utf-8

# Copyright (c) 2013-2014, Sylvain LAPERCHE <sylvain.laperche@gmail.com>
# All rights reserved.
# License: BSD 3-Clause (http://opensource.org/licenses/BSD-3-Clause)

# This script plays a sound for each incoming message.
# This behavior can be enabled/disabled for each buffer.

require 'open3'
require 'set'
require 'shellwords'

# Information for script registration.
NAME        = 'psound'
AUTHOR      = 'grim7reaper'
VERSION     = '1.1.0'
LICENSE     = 'BSD 3-Clause'
DESC        = 'Play a soundfile for incoming messages'
SHUTDOWN_FN = ''
CHARSET     = '' # UTF-8 is default charset.

# Information about the script use.
ARGS = [ 'test',
         '                        on|off [buffer]',
         '                        list' ].join("\n")
ARGS_DESC = "Options:\n"                                                   \
            "player        software used to play a sound.\n"               \
            "sound_file    path to the sound file to play.\n"              \
            "\n"                                                           \
            "Commands:\n"                                                  \
            "test          Try to play `sound_file` with `player`\n"       \
            "on  [buffer]  Enable sound notification for `buffer`.\n"      \
            "off [buffer]  Disable sound notification for `buffer`.\n"     \
            "list          Print the list of muted buffers.\n"             \
            "\n"                                                           \
            "By default, sound notifications is enabled for all channel "  \
            "buffers.\n"
            "When you need to provide a buffer name, it is better to use " \
            "the completion (Tab key) to cycle through valid values.\n"    \
            "If you do not provide a buffer name, the command is applied " \
            "on the current buffer."

COMPLETION = 'test'                        \
             ' || on %(buffers_names)'     \
             ' || off %(buffers_names)'    \
             ' || list'

# Default settings.
SETTINGS = { 'player'     => 'aplay',
             'sound_file' => '' }

# Set of muted buffers.
# TODO: find a way to avoid the use of an ugly global variable.
$muted_buffers = Set.new

# Script initialization.
def weechat_init
  # Script registration
  Weechat.register(NAME, AUTHOR, VERSION, LICENSE, DESC, SHUTDOWN_FN, CHARSET)
  # If an option is unset or empty, use the default value.
  SETTINGS.each do |option_name, default_value|
    value = Weechat.config_get_plugin(option_name)
    if value.nil? || value.empty?
      Weechat.config_set_plugin(option_name, default_value)
    end
  end
  # Hook all incoming/outcoming messages only in IRC channels?
  Weechat.hook_print('', 'irc_privmsg', '', 1, 'print_cb', '')
  # Set the command help.
  Weechat.hook_command(NAME, DESC, ARGS, ARGS_DESC, COMPLETION, 'parse_cmd', '')
  return Weechat::WEECHAT_RC_OK
end

# Print an error message in the core buffer of Weechat.
#
# @param msg [String] error message.
def print_error(msg)
  Weechat.print('', "#{Weechat.prefix('error')}psound.rb: #{msg}")
end


# Play a sound.
def play_sound
  # Check player.
  player = Weechat.config_get_plugin('player')
  if player.nil? || player.empty?
    print_error('Cannot play sound: player was not set')
    return
  end
  # Check sound file.
  sound_file = Weechat.config_get_plugin('sound_file')
  if sound_file.nil? || sound_file.empty?
    print_error('Cannot play sound: sound file was not set')
    return
  end
  unless File.readable?(sound_file)
    print_error("Sound file (#{sound_file}) does not exist or is not readable.")
    return
  end
  # Play the sound.
  Open3.popen3(player, sound_file) do |stdin, stdout, stderr, waiting_thread|
    # We are not interested in stdin, stdout.
    exit_status = waiting_thread.value
    # Check the return value.
    unless exit_status.success?
      print_error('An error occurred when playing the sound.')
      print_error("#{stderr.read}")
    end
  end
end


# Print the list of muted buffers.
def print_muted_buffers
  if $muted_buffers.empty?
    Weechat.print('', 'No muted buffer.')
  else
    prefix = $muted_buffers.size == 1 ? 'Muted buffer' : 'Muted buffers'
    Weechat.print('', "#{prefix}: #{$muted_buffers.to_a.join(', ')}")
  end
end


# Callback called when a message is printed.
#
# @param data      [String] pointer.
# @param buffer    [String] buffer pointer.
# @param date      [String] date.
# @param tags      [String] array with tags for line.
# @param displayed [String] '1' if line is displayed, '0' if it is hidden.
# @param highlight [String] '1' if line has highlight, otherwise '0'.
# @param prefix    [String] prefix.
# @param message   [String] message.
# @return Weechat::WEECHAT_RC_OK or Weechat::WEECHAT_RC_ERROR
def print_cb(data, buffer, date, tags, displayed, highlight, prefix, message)
  # Do not react for invisible message.
  return Weechat::WEECHAT_RC_OK if displayed == '0'
  # Do not react on my own message.
  # Extract nick from `tags`. Its content look like that:
  # irc_privmsg,notify_none,no_highlight,prefix_nick_white,nick_grim7reaper,log1
  nick = $2 if tags =~ /(^|,)nick_([^,]+)(,|$)/
  my_nick = Weechat.buffer_get_string(buffer, 'localvar_nick')
  return Weechat::WEECHAT_RC_OK if nick == my_nick
  # Play a sound if the buffer is not muted.
  buffer_name = Weechat.buffer_get_string(buffer, 'name')
  play_sound() unless $muted_buffers.include? buffer_name
  return Weechat::WEECHAT_RC_OK
end


# Parse the command with its arguments.
#
# @param data   [String] pointer.
# @param buffer [String] buffer (pointer) where command is executed.
# @param args   [String] arguments given for command.
# @return Weechat::WEECHAT_RC_OK or Weechat::WEECHAT_RC_ERROR
def parse_cmd(data, buffer, args)
  args = args.shellsplit()
  current_buffer = Weechat.buffer_get_string(buffer, 'name')
  unless args.empty?
    case args.first
    when 'test'
      play_sound()
    when 'on'
      buffer = args.size > 1 ? args[1] : current_buffer
      $muted_buffers.delete?(buffer)
    when 'off'
      buffer = args.size > 1 ? args[1] : current_buffer
      $muted_buffers.add?(buffer)
    when 'list'
      print_muted_buffers()
    else
      print_error("Unknown command #{args.first}")
      return Weechat::WEECHAT_RC_ERROR
    end
    return Weechat::WEECHAT_RC_OK
  end
end
