# Other TP-Link camera
[TP-link NC210](nc210.md)

# TP-Link NC220
Some more or less random stuff about TP-Link NC220 IP Camera

# Playing Streams

* Most browsers do not support the live view anymore: "Um, this browser may not support camera video well. Your browser is outdated. 
  Please update to the latest version to play videos."

## Workaround

* You can directly open the mjpeg video stream as URL:
  * Replace "nc220.lan" by your camera ip
  * Replace password string by your password, base64 encoded
  * http://nc220.lan:8080/stream/video/mjpeg?resolution=VGA&Username=admin&Password=YWRtaW4=
  * http://nc220.lan:8080/stream/video/mjpeg?Username=admin&Password=YWRtaW4=
  * Note: Username and Password have to be given inside the url string. The password window seems not to work.


There are a bunch of audio and video sources where you can try to obtain streams from. Most of them do not work as expected but there are some working constellations.

**Playing streams requires authentication!** Use your normal camera user account. **The _password_ must be _base64 encoded_.** In the examples here the standard password _admin_ (YWRtaW4= in base64) is used.

## List of available Video Sources
* http://nc220.lan:8080/stream/video/mjpeg
  * `cvlc --network-caching=0 http://admin:YWRtaW4=@nc220.lan:8080/stream/video/mjpeg`
* http://nc220.lan:8080/stream/video/h264
* http://nc220.lan:8080/stream/video/mjpeg_mixed
* rtsp://admin:admin@nc220.lan:554/h264_vga.sdp
  * ~~vlc --started-from-file rtsp://admin:admin@nc220.lan:554/h264_vga.sdp~~

## List of available Audio Sources
* http://nc220.lan:8080/stream/audio/wavpcm
* http://nc220.lan:8080/stream/audio/wavpcmblock
* http://nc220.lan:8080/stream/audio/mpegmp2
  * `mplayer -nocache -user admin -passwd YWRtaW4= "http://nc220.lan:8080/stream/audio/mpegmp2"`
* http://nc220.lan:8080/stream/audio/mpegmp2block
* http://nc220.lan:8080/stream/audio/mpegaac
* http://nc220.lan:8080/stream/audio/mpegaacblock

# Getting Still Images
* wget --user=admin --password=YWRtaW4= http://nc220.lan:8080/stream/snapshot.jpg

# Portscan
```
PORT     STATE SERVICE
80/tcp   open  http
554/tcp  open  rtsp
2020/tcp open  xinupageserver
8080/tcp open  http-proxy
```

# Firmware
The camera itself runs under linux. Some GPL files can be downloaded at tplink http://www.tp-link.com/en/gpl-code.html?model=NC220 .


# Hardware
Some hardware info and pictures from inside can be found at FCC:
* https://fccid.io/TE7NC220
* https://fccid.io/TE7NC200


# Discontinued
Don´t have the time to look on this any longer. Feel free to fork and continue.
