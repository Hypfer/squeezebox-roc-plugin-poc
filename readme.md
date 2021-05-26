# ROC Input for the LMS

This repository contains a slightly modified version of the `WaveInput` plugin for the logitech media server
with the aim of using the [Roc Toolkit](https://github.com/roc-streaming/roc-toolkit) to inject arbitrary audio
into the LMS via the network.

This is pretty much unsupported and just my solution to get stuff that requires a chromecast into my multi-room system.

To use this, you will need the `roc-recv` in your `$PATH`

I'm using a custom dockerfile to achieve that:

```
FROM lmscommunity/logitechmediaserver:8.2.0
RUN apt update && apt install -y alsa-utils

RUN apt install -y g++ pkg-config scons ragel gengetopt libunwind8-dev libpulse-dev libsox-dev libtool intltool autoconf automake make cmake build-essential git

RUN cd /tmp && git clone https://github.com/Hypfer/roc-toolkit.git
RUN cd /tmp/roc-toolkit && scons -Q --build-3rdparty=libuv,openfec,cpputest
RUN cd /tmp/roc-toolkit && scons -Q --build-3rdparty=libuv,openfec,cpputest install
RUN cd /tmp/roc-toolkit && scons -Q --enable-pulseaudio-modules --build-3rdparty=libuv,openfec,pulseaudio,cpputest
RUN cd /tmp/roc-toolkit && scons -Q --enable-pulseaudio-modules --build-3rdparty=libuv,openfec,pulseaudio,cpputest install
```

Note that I'm using my fork there, which just consists of an added `exit(-1);` when it's unable to output received audio
because otherwise the `roc-recv` binary won't die on input switch of the LMS.

The custom plugin location for the LMS can be found in Settings > Information. Just paste that ROCInput folder there.

Then, restart and create a new favourite with a URL that starts with `rocin:`. Playing that will start the roc-recv instance.
For the codec, only 320k MP3 CBR is supported because that was the only thing that worked reliably. YMMV

If your network has issues keeping up, and you're experiencing `Rebuffering` messages, try increasing the bufferThreshold
in the ROCIN.pm.


To get the chromecast audio into the system, I bought an HDMI Audio Extractor from Aliexpress. That thing pretends to be 
an always-on display (including HDCP support..) so you won't need an additional dummy HDMI plug.

I've also went through four different USB Soundcards before I found one that supports TOSLINK S/PDIF in on Linux.
Everything else either didn't work at all or only supported analog in.

The card that finally worked is the [Terratec Aureon 5.1 USB MK.2](https://github.com/opensrc/alsa/blob/master/lib/md/Terratec_Aureon_5.1_USB_MK.2.md)
which came out in 2004 and can only be bought second-hand.
It does work though so if you're looking for TOSLINK S/PDIF digital audio in on Linux just get that one.

Unfortunately, the USB Controller of my NAS, which houses the LMS doesn't play well with USB Soundcards and just dies randomly
with no way to recover. Therefore, I had to move the Audio input to another host and transfer the audio via the network
which is why this plugin even exists.

I now have another Raspberry Pi right next to the NAS with this command running to inject the audiostream:
`arecord -d0 -c2 -f S16_LE -r 44100 -twav -D plughw:1,0 | roc-send -vv -s rtp+rs8m:192.168.x.x:10001 -r rs8m:192.168.x.x:10002 -i - -d wav`

And that's about it. This enables me to cast twitch music streams to the whole house.
Feel free to improve on this.

Also,
