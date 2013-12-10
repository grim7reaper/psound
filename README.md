# psound

## LOADING

### MANUALLY

Type the following command in Weechat:

    /ruby load path/to/psound.rb

### AUTOLOADING

If you want autoload the script when WeeChat is starting, you can run the
following commands:

    cd ~/.weechat/ruby/autoload
    ln -s path/to/psound.rb

## SETTINGS

The script can be configured through two options:

* plugins.var.ruby.psound.player: software used to play a sound
  (default: aplay).
* plugins.var.ruby.psound.sound_file: path to the sound file to play
  (default: unset).

## ARGUMENTS

The script implements three actions:

* test: tests the current settings by trying to play `sound_file` with `player`.
* on [buffer]: Enable sound notifications for `buffer`.
* off [buffer]: Disable sound notifications for `buffer`.

## NOTES

* By default, sound notifications is enabled for all channel buffers.
* When you need to provide a buffer name, it is better to use the completion
  (Tab key) to cycle through valid values.
* If you do not provide a buffer name, the command is applied on the current
  buffer.

## REFERENCES

http://www.weechat.org/files/doc/stable/weechat_scripting.en.html
http://www.weechat.org/files/doc/stable/weechat_plugin_api.en.html
