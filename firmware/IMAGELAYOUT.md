# TP-Link NC220 Firmware Image Layout

The firmware image (.bin) consists roughly of 4 parts:

1. Header
2. root_Uimage (Kernel + ?)
3. fs_Image (Filesystem)
4. dsp_Image

## 1. Header
```
- Offset 0x00000000: 4 Bytes, Magic Number 0xfdfdaaaa
- Offset 0x00000004: 4 Bytes, Timestamp (low byte first)
- Offset 0x00000008: 4 Bytes, Filesize of complete .bin file (low byte first)
- Offset 0x0000000C: 16 Bytes, MD5(root_Uimage + fs_Image + dsp_Image)
- Offset 0x0000001C: 68 Bytes, Firmware Name, padded with 0x00 Bytes

- Offset 0x00000060: 4 Bytes, Position Offset of root_Uimage in this .bin file (low byte first)
- Offset 0x00000064: 4 Bytes, File size of root_Uimage (low byte first)
- Offset 0x00000068: 20 Bytes, Name of root_Uimage, padded with 0x00 Bytes
- Offset 0x0000007C: 4 Bytes, Unknown!!, here 0x00000001

- Offset 0x00000080; 4 Bytes, Position Offset of fs_Image in this .bin file (low byte first)
- Offset 0x00000084: 4 Bytes, File size of fs_Image (low byte first)
- Offset 0x00000088: 20 Bytes, Name of fs_Image, padded with 0x00 Bytes
- Offset 0x0000009C: 4 Bytes, Unknown!!, here 0x00000002

- Offset 0x000000A0; 4 Bytes, Position Offset of dsp_Image in this .bin file (low byte first)
- Offset 0x000000A4: 4 Bytes, File size of dsp_Image (low byte first)
- Offset 0x000000A8: 20 Bytes, Name of dsp_Image, padded with 0x00 Bytes

- Offset 0x000000BC: 68 Bytes, Camera Name, padded with 0x00 Bytes

- Offset 0x000000FC: Here starts the root_Uimage
- Offset 0x001c84c5 (only valid for NC220_1.0.27_Build_150629_Rel.22346): Here starts the fs_Image
- Offset 0x0074fa01 (only valid for NC220_1.0.27_Build_150629_Rel.22346): Here starts the dsp_Image
```


### Example: NC220_1.0.27_Build_150629_Rel.22346.bin

```
00000000  aa aa fd fd a2 24 91 55  01 fa 76 00 75 59 a2 1e  |.....$.U..v.uY..|
00000010  ea 8f c0 14 8b ed c3 4f  a9 98 98 75 31 2e 30 2e  |.......O...u1.0.|
00000020  32 37 20 42 75 69 6c 64  20 31 35 30 36 32 39 20  |27 Build 150629 |
00000030  52 65 6c 2e 32 32 33 34  36 00 00 00 00 00 00 00  |Rel.22346.......|
00000040  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000060  fc 00 00 00 c9 83 1c 00  72 6f 6f 74 5f 75 49 6d  |........root_uIm|
00000070  61 67 65 00 00 00 00 00  00 00 00 00 01 00 00 00  |age.............|
00000080  c5 84 1c 00 3c 75 58 00  66 73 5f 49 6d 61 67 65  |....<uX.fs_Image|
00000090  00 00 00 00 00 00 00 00  00 00 00 00 02 00 00 00  |................|
000000a0  01 fa 74 00 00 00 02 00  64 73 70 5f 49 6d 61 67  |..t.....dsp_Imag|
000000b0  65 00 00 00 00 00 00 00  00 00 00 00 4e 43 32 32  |e...........NC22|
000000c0  30 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |0...............|
000000d0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000e0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
000000f0  00 00 00 00 00 00 00 00  00 00 00 00 27 05 19 56  |............'..V|
00000100  e2 6d 05 df 55 89 11 1d  00 1c 83 89 80 00 00 00  |.m..U...........|
00000110  80 00 c3 10 9a 72 59 84  05 05 02 03 4c 69 6e 75  |.....rY.....Linu|
00000120  78 20 4b 65 72 6e 65 6c  20 49 6d 61 67 65 00 00  |x Kernel Image..|
00000130  00 00 00 00 00 00 00 00  00 00 00 00 5d 00 00 00  |............]...|
00000140  02 a0 72 49 00 00 00 00  00 00 00 6f fd ff ff a3  |..rI.......o....|
00000150  b7 ff 47 3e 48 15 72 39  61 51 b8 92 28 e6 a3 86  |..G>H.r9aQ..(...|
00000160  07 f9 ee e4 1e 82 d3 2f  c5 3a 3c 01 4b b1 7e c9  |......./.:<.K.~.|
[...]

```

### Extracting parts from firmware image
```
$ dd if=NC220_1.0.27_Build_150629_Rel.22346.bin bs=1 skip=0 count=0xfc of=NC220_1.0.27_Build_150629_Rel.22346.bin.header
$ dd if=NC220_1.0.27_Build_150629_Rel.22346.bin bs=1 skip=0xfc count=0x1c83c9 of=NC220_1.0.27_Build_150629_Rel.22346.bin.kernel.uboot
$ dd if=NC220_1.0.27_Build_150629_Rel.22346.bin bs=1 skip=0x1c84c5 count=0x58753c of=NC220_1.0.27_Build_150629_Rel.22346.bin.fs
$ dd if=NC220_1.0.27_Build_150629_Rel.22346.bin bs=1 skip=0x74fa01 count=0x20000 of=NC220_1.0.27_Build_150629_Rel.22346.bin.dsp

$ cat NC220_1.0.27_Build_150629_Rel.22346.bin.kernel.uboot > 3images
$ cat NC220_1.0.27_Build_150629_Rel.22346.bin.fs >> 3images
$ cat NC220_1.0.27_Build_150629_Rel.22346.bin.dsp  >> 3images

$ md5sum *
7559a21eea8fc0148bedc34fa9989875 *3images (Compare to image header!)
4c4c2abb19a9fbaab1c1587879a05924 *NC220_1.0.27_Build_150629_Rel.22346.bin
41c9da859016509e21697b68b30023c2 *NC220_1.0.27_Build_150629_Rel.22346.bin.dsp
3d9acb1366211cee62084b7a074fa066 *NC220_1.0.27_Build_150629_Rel.22346.bin.fs
83aa510aec555f1bda201298100fb069 *NC220_1.0.27_Build_150629_Rel.22346.bin.header
f1876e1a1bb25addb15b7d9bd3546294 *NC220_1.0.27_Build_150629_Rel.22346.bin.kernel.uboot
```

## 2. root_Uimage (Kernel + ?)

Uboot Header

```
#define IH_MAGIC    0x27051956    /* Image Magic Number     */
#define IH_NMLEN    32            /* Image Name Length      */

typedef struct image_header {
    uint32_t    ih_magic;         /* Image Header Magic Number */
    uint32_t    ih_hcrc;          /* Image Header CRC Checksum */
    uint32_t    ih_time;          /* Image Creation Timestamp  */
    uint32_t    ih_size;          /* Image Data Size           */
    uint32_t    ih_load;          /* Data     Load  Address    */
    uint32_t    ih_ep;            /* Entry Point Address       */
    uint32_t    ih_dcrc;          /* Image Data CRC Checksum   */
    uint8_t     ih_os;            /* Operating System          */
    uint8_t     ih_arch;          /* CPU architecture          */
    uint8_t     ih_type;          /* Image Type                */
    uint8_t     ih_comp;          /* Compression Type          */
    uint8_t     ih_name[IH_NMLEN];    /* Image Name            */
} image_header_t;
```

```
$mkimage -l NC220_1.0.27_Build_150629_Rel.22346.bin.kernel.uboot
Image Name:   Linux Kernel Image
Created:      Tue Jun 23 09:56:13 2015
Image Type:   MIPS Linux Kernel Image (lzma compressed)
Data Size:    1868681 Bytes = 1824.88 kB = 1.78 MB
Load Address: 80000000
Entry Point:  8000c310
```

If you remove the uboot header you can uncompress the kernel image with lzma:
```
dd if=NC220_1.0.27_Build_150629_Rel.22346.bin.kernel.uboot of=NC220_1.0.27_Build_150629_Rel.22346.bin.kernel.lzma bs=1 skip=64
lzma -d NC220_1.0.27_Build_150629_Rel.22346.bin.kernel.lzma
```

**Can somebody find the initramfs??? Something with cpio??? Please report!!!**

## 3. fs_Image (Filesystem)

The fs_Image can be mounted using mtd-tools
```
  sudo apt-get install mtd-tools
  sudo modprobe -v mtd
  sudo modprobe -v jffs2
  sudo modprobe -v mtdram total_size=256000 erase_size=256
  sudo modprobe -v mtdblock 
  sudo dd if=NC220_1.0.27_Build_150629_Rel.22346.bin.fs of=/dev/mtd0
  sudo mount -t jffs2 /dev/mtdblock0 /mnt/fs
```

List of files:

```
./lib                                                                                                                                                        
./lib/libevent_openssl-2.0.so.5                                                                                                                              
./lib/libupnpjrpc.so                                                                                                                                         
./lib/libudt.so                                                                                                                                              
./lib/libcloud.so.0                                                                                                                                          
./lib/libcrypto.so.0.9.8                                                                                                                                     
./lib/libevent-2.0.so.5                                                                                                                                      
./lib/mod_dirlisting.so                                                                                                                                      
./lib/libssl.so.0.9.8                                                                                                                                        
./lib/mod_access.so                                                                                                                                          
./lib/libjrpc.so                                                                                                                                             
./lib/libfcgi.so.0                                                                                                                                           
./lib/kernel                                                                                                                                                 
./lib/kernel/crypto
./lib/kernel/crypto/aes_generic.ko
./lib/kernel/crypto/ansi_cprng.ko
./lib/kernel/drivers
./lib/kernel/drivers/net
./lib/kernel/drivers/net/wireless
./lib/kernel/drivers/net/wireless/rt2860v2_ap
./lib/kernel/drivers/net/wireless/rt2860v2_ap/rt2860v2_ap.ko
./lib/libfdk-aac.so.0
./lib/mod_fastcgi.so
./lib/libnss_mdns-0.2.so
./lib/mod_staticfile.so
./lib/libminiupnpc.so.9
./lib/mod_indexfile.so
./etc
./etc/fstab
./etc/profile
./etc/passwd
./etc/group
./etc/2048_newroot.cer
./bin
./bin/img_built
./bin/pppd
./bin/rinetd
./bin/filecut
./bin/wget
./bin/ssmtp
./bin/wput
./bin/tp_mp_server
./bin/watch_adalarm.sh
./bin/watch_lighttpd.sh
./www
./www/js
./www/js/guest.js
./www/js/plug.js
./www/js/common.js
./www/js/index.js
./www/js/analytics.js
./www/js/login.js
./www/lib
./www/lib/jqueryX.js
./www/lib/raphael-min.js
./www/css
./www/css/common.css
./www/css/plug.css
./www/css/login.css
./www/guest.html
./www/favicon.png
./www/favicon.ico
./www/images
./www/images/button.png
./www/images/asideblue.png
./www/images/loading.gif
./www/images/220.png
./www/images/img.png
./www/images/button-hover.png
./www/images/button1px.png
./www/images/logo.png
./www/images/button-active.png
./www/images/asidebackground.png
./www/images/button-disable.png
./www/images/tp-link_logo.png
./www/images/loadings.gif
./www/i18n
./www/i18n/en.js
./www/index.html
./www/login.html
./config
./config/SingleSKU_CE.dat
./config/modules.conf
./config/RT2860AP.dat
./config/SingleSKU_FCC.dat
./config/onvif_1.conf_bak
./config/workmod_define.conf
./config/conf.d
./config/conf.d/debug.conf
./config/conf.d/fastcgi.conf
./config/conf.d/mime.conf
./config/conf.d/dirlisting.conf
./config/lighttpd.conf
./config/SingleSKU.dat
./config/onvif_1.conf
./config/ipcamera
./config/ipcamera/ssmtp.conf
./config/ipcamera/videoctrl.conf
./config/ipcamera/cloud.conf
./config/ipcamera/Wireless.conf
./config/ipcamera/Session.conf
./config/ipcamera/ftp.conf
./config/ipcamera/um.conf
./config/ipcamera/MDConf.conf
./config/ipcamera/NetConf.conf
./config/ipcamera/datetime.conf
./config/ipcamera/system.conf
./config/ipcamera/button.conf
./config/ipcamera/bonjour.conf
./config/ipcamera/MyLog.conf
./config/ipcamera/upnp.conf
./config/ipcamera/user.conf
./config/ipcamera/Ddns.conf
./config/ipcamera/IPLocationConf.conf
./sbin
./sbin/upgrader
./sbin/autoupgrade.sh
./sbin/lighttpd
./sbin/ad_alarm
./sbin/mdnew_alarm
./sbin/relayd
./sbin/gpld
./sbin/p2pd
./sbin/streamd
./sbin/onvif
./sbin/upnp
./sbin/ssl-tunnel
./sbin/mDNSResponderPosix
./sbin/ftpnew_alarm
./sbin/smtpnew_alarm
./sbin/autoupgradenotice
./sbin/ipcamera
./sbin/doubletalk
./share
```

## 4. dsp_Image

Anything interesting here?

## Flashing modified images

It should be possible to flash your own firmware. But be careful when doing so. There seems to be no way to access the bootloader yet. Your device may be bricked forever!

Some oberservations so far:

- Camera checks for file suffix .bin
- Firmware Name and Timestamp seem not to be checked by the camera before flashing

Can somebody open the camera case safely?

# TP-Link NC200 Firmware Image Layout

The NC200 firmware image has a slightly different image layout.

## 1. Header
```
- Offset 0x00000000: 4 Bytes, Magic Number 0xfdfdaaaa
- Offset 0x00000004: 4 Bytes, 0x000000C8 -> 200dez -> Model Name
- Offset 0x00000008: 4 Bytes, Timestamp (low byte first)
- Offset 0x0000000C: 4 Bytes, Filesize of complete .bin file (low byte first)
- Offset 0x00000010: 16 Bytes, MD5(root_Uimage + fs_Image + dsp_Image)
- Offset 0x00000020: 68 Bytes, Firmware Name, padded with 0x00 Bytes

- Offset 0x00000064: 4 Bytes, Position Offset of root_Uimage in this .bin file (low byte first)
- Offset 0x00000068: 4 Bytes, File size of root_Uimage (low byte first)
- Offset 0x0000006C: 20 Bytes, Name of root_Uimage, padded with 0x00 Bytes
- Offset 0x00000080: 4 Bytes, Unknown!!, here 0x00000001

- Offset 0x00000084; 4 Bytes, Position Offset of fs_Image in this .bin file (low byte first)
- Offset 0x00000088: 4 Bytes, File size of fs_Image (low byte first)
- Offset 0x0000008C: 20 Bytes, Name of fs_Image, padded with 0x00 Bytes
- Offset 0x000000A0: 4 Bytes, Unknown!!, here 0x00000002

- Offset 0x000000A4; 4 Bytes, Position Offset of dsp_Image in this .bin file (low byte first)
- Offset 0x000000A8: 4 Bytes, File size of dsp_Image (low byte first)
- Offset 0x000000A8: 20 Bytes, Name of dsp_Image, padded with 0x00 Bytes

- Offset 0x000000C0: Here starts the root_Uimage
...
```
