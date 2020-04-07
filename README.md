# tetris-wifi

Console Tetris wrapper, instrumented to determine effect of 802.11 RF "WiFi" radiation using randomized self-experiments

Installation:

- Edit and test `wifi-flood-daemon` to make sure that it does the right thing on your system. Ideally you should be able to detect a change using an RF meter. Also, it should restore the network when it is done.
    
      $ ./wifi-flood start
      $ ./wifi-flood stop
      Killing process
      Sent signal

- Run something like `make PREFIX=~/.local install`.

- Install the instrumented version of bsdgames tetris. This version collects data that will end up in `~/.tetris-wifi`.

      git clone https://github.com/navarum/tweaks tweaks.navarum
      ./tweaks.navarum/examples/install-tweaks tetris

- Test with a meter and `tetris-wifi -t`.

      $ tetris-wifi -t
      Testing wifi-flood (pulse)
      Testing wifi-flood (off)
      Killing process
      Sent signal

- Try to reduce the variance by always playing under similar conditions.

- TODO: figure out a good way to analyze the resulting data.
