# psound

A Weechat script that plays a soundfile for incoming messages.

## Loading

### Manually

Type the following command in Weechat:

    /ruby load path/to/psound.rb

### Autoloading

If you want autoload the script when WeeChat is starting, you can run the
following commands:

    cd ~/.weechat/ruby/autoload
    ln -s path/to/psound.rb

## Settings

The script can be configured through two options:

* plugins.var.ruby.psound.player: software used to play a sound
  (default: aplay).
* plugins.var.ruby.psound.sound\_file: path to the sound file to play
  (default: unset).

## Arguments

The script implements three actions:

* test: Test the current settings by trying to play `sound_file` with `player`.
* on [buffer]: Enable sound notifications for `buffer`.
* off [buffer]: Disable sound notifications for `buffer`.
* list: Print the list of muted buffers.

## Notes

* By default, sound notifications is enabled for all channel buffers.
* When you need to provide a buffer name, it is better to use the completion
  (Tab key) to cycle through valid values.
* If you do not provide a buffer name, the command is applied on the current
  buffer.

## References

http://www.weechat.org/files/doc/stable/weechat\_scripting.en.html

http://www.weechat.org/files/doc/stable/weechat\_plugin\_api.en.html

## License

This software is licensed under the BSD3 license.

© 2013-2014 Sylvain Laperche sylvain.laperche@gmail.com.
