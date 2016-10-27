# TP-Link NC220
Some more or less random stuff about TP-Link NC220 (and NC200) IP Camera

The TP-Link NC220 and NC200 cameras have a bad support for some browsers especially under linux. Some workarounds and observations will be collected here. It is not necessary to use any cloud service for accessing this camera. All tests here are done with the NC220 but there is a good chance that some of these workarounds will work for the NC200 camera, too.

# Configure
The standard username is admin and the password is admin, too. (Can be found under the camera stand.)
It is possible to make all configuration settings with any browser except motion detection. 
For configuring motion detection usually a special plugin is needed. This doesn´t work under linux so it was
necessary to reverse engineer the protocol. The proof of concept configuration tool (written in Perl Tk) 
can be found in the software folder. Please note: This is only a fast hacked proof of concept, there are still some
issues to do.

# Playing Streams

* Windows: Live view is only possible with special browser plugins. Firefox and IE are working. Chrome does not support Netscape Plugin API any longer ("Meanwhile, NPAPI’s 90s-era architecture has become a leading cause of hangs, crashes, security incidents, and code complexity") so live view is not possible with Chrome.

* Linux: When opening the live view window in your browser a plugin is served for download but it will not work. 

## Workaround
There are a bunch of audio and video sources where you can try to obtain streams from. Most of them do not work as expected but there are some working constellations.

**Playing streams requires authentication!** Use your normal camera user account. **The _password_ must be _base64 encoded_.** In the examples here the standard password _admin_ (YWRtaW4= in base64) is used.

## List of available Video Sources
* http://[ipofcamera]:8080/stream/video/mjpeg
  * `cvlc --network-caching=0 http://admin:YWRtaW4=@[ipofcamera]:8080/stream/video/mjpeg`
* http://[ipofcamera]:8080/stream/video/h264
* http://[ipofcamera]:8080/stream/video/h264_mixed
* http://[ipofcamera]:8080/stream/video/mjpeg_mixed
* http://[ipofcamera]:8080/stream/video/h264_previous
* rtsp://admin:admin@[device-ip]:554/h264_vga.sdp
  * `vlc --started-from-file rtsp://admin:admin@[device-ip]:554/h264_vga.sdp`
* rtmp://[device-ip]:1935/stream/video/h264
  * `ffplay rtmp://192.168.1.49:1935/stream/video/h264`
  * video and audio stream
  * Works without authentication! (WTF?)

## List of available Audio Sources
* http://[ipofcamera]:8080/stream/audio/wavpcm
* http://[ipofcamera]:8080/stream/audio/wavpcmblock
* http://[ipofcamera]:8080/stream/audio/mpegmp2
  * `mplayer -nocache -user admin -passwd YWRtaW4= "http://[ipofcamera]:8080/stream/audio/mpegmp2"`
* http://[ipofcamera]:8080/stream/audio/mpegmp2block
* http://[ipofcamera]:8080/stream/audio/mpegaac
* http://[ipofcamera]:8080/stream/audio/mpegaacblock

# Getting Still Images
* wget --user=admin --password=YWRtaW4= http://[ipofcamera]:8080/stream/snapshot.jpg

# Portscan
```
PORT     STATE SERVICE
80/tcp   open  http
554/tcp  open  rtsp
1935/tcp open  rtmp
2020/tcp open  xinupageserver
8080/tcp open  http-proxy
```

Port 80 is used for configuration interface, streams are served at port 8080 and 554. What are the other ports for? Please report your experiences!

# Firmware
The camera itself runs under linux. Some GPL files can be downloaded at tplink http://www.tp-link.com/en/gpl-code.html?model=NC220 .

An analysis of the firmware image layout can be found in the firmware folder.

# Hardware
Some hardware info and pictures from inside can be found at FCC:
* https://fccid.io/TE7NC220
* https://fccid.io/TE7NC200


# Contribute
Please report your investigation results of this device!
