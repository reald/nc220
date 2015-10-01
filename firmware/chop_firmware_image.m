% Extract parts of TP-Link NC200/NC220 firmware image
%
% (c) Dennis Real 2015, v0.11
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3 of the License.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Usage: octave -q chop_firmware_image.m imagefile.bin

arglist = argv();

if ( length(arglist) == 0 )
  filename='NC220_1.0.27_Build_150629_Rel.22346.bin'
else
  filename = arglist{1}
end

magic = [ 0xaa 0xaa 0xfd 0xfd ];
ubootmagic = [ 0x27 0x05 0x19 0x56 ];
ubootheaderlen = 64;
alwayszero = [ 0 0 0 0 ];
alwaysone = [ 1 0 0 0 ];
alwaystwo = [ 2 0 0 0 ];

%% nc200 specifics
nc200image = [ 0xc8 0x00 0x00 0x00 ];

%% nc220 specifics
nc220name = 'NC220';

%% read image
image = fileread(filename);
nbytes = length(image)

%% check magic
if ( sum((image(1:4)-0) != magic) != 0 )
  disp('This is not a tplink nc 200/220 firmware image');
  exit(-1);
end

%% nc200 or nc220 image?
if ( sum((image(5:8)-0) == nc200image) != 0 )
  disp('Trying NC200 firmware image decompose...');

  timestampofs = 0x8;
  timestamplen = 4;

  filesizeofs = timestampofs + timestamplen;
  filesizelen = 4;
  md5ofs = filesizeofs + filesizelen;
  md5len = 16;
  firmwarenameofs = md5ofs + md5len;
  firmwarenamelen = 64;

  alwayszeroofs = firmwarenameofs + firmwarenamelen;
  alwayszerolen = 4;
  posRootUImageofs = alwayszeroofs + alwayszerolen;
  posRootUImagelen = 4;
  filesizeRootUImageofs = posRootUImageofs + posRootUImagelen;
  filesizeRootUImagelen = 4;
  nameRootUImageofs = filesizeRootUImageofs + filesizeRootUImagelen;
  nameRootUImagelen = 20;

  alwaysoneofs = nameRootUImageofs + nameRootUImagelen;
  alwaysonelen = 4;
  posfsImageofs = alwaysoneofs + alwaysonelen;
  posfsImagelen = 4;
  filesizefsImageofs = posfsImageofs + posfsImagelen;
  filesizefsImagelen = 4;
  namefsImageofs = filesizefsImageofs + filesizefsImagelen;
  namefsImagelen = 20;  

  alwaystwoofs = namefsImageofs + namefsImagelen;
  alwaystwolen = 4;
  posdspImageofs = alwaystwoofs + alwaystwolen;
  posdspImagelen = 4;
  filesizedspImageofs = posdspImageofs + posdspImagelen;
  filesizedspImagelen = 4;
  namedspImageofs = filesizedspImageofs + filesizedspImagelen;
  namedspImagelen = 20;


else
  disp('Trying NC220 firmware image decompose...');

  timestampofs = 0x4;
  timestamplen = 4;
  filesizeofs = timestampofs + timestamplen;
  filesizelen = 4;
  md5ofs = filesizeofs + filesizelen;
  md5len = 16;
  firmwarenameofs = md5ofs + md5len;
  firmwarenamelen = 64;

  alwayszeroofs = firmwarenameofs + firmwarenamelen;
  alwayszerolen = 4;
  posRootUImageofs = alwayszeroofs + alwayszerolen;
  posRootUImagelen = 4;
  filesizeRootUImageofs = posRootUImageofs + posRootUImagelen;
  filesizeRootUImagelen = 4;
  nameRootUImageofs = filesizeRootUImageofs + filesizeRootUImagelen;
  nameRootUImagelen = 20;

  alwaysoneofs = nameRootUImageofs + nameRootUImagelen;
  alwaysonelen = 4;
  posfsImageofs = alwaysoneofs + alwaysonelen;
  posfsImagelen = 4;
  filesizefsImageofs = posfsImageofs + posfsImagelen;
  filesizefsImagelen = 4;
  namefsImageofs = filesizefsImageofs + filesizefsImagelen;
  namefsImagelen = 20;  

  alwaystwoofs = namefsImageofs + namefsImagelen;
  alwaystwolen = 4;
  posdspImageofs = alwaystwoofs + alwaystwolen;
  posdspImagelen = 4;
  filesizedspImageofs = posdspImageofs + posdspImagelen;
  filesizedspImagelen = 4;
  namedspImageofs = filesizedspImageofs + filesizedspImagelen;
  namedspImagelen = 20;

  cameranameofs = namedspImageofs + namedspImagelen;
  cameranamelen = 64;

  cameraname = image(cameranameofs+1:cameranameofs+1 + cameranamelen - 1)

  if ( strncmp(cameraname, nc220name, min(length(cameraname), length(nc220name)) ) != 0 )
    disp(cstrcat('Image name: ', nc220name, ' ok.'));
  else
    disp(cstrcat('Image name not valid: ', cameraname, ' != ', nc220name));
   exit(-1);
  end
end


%% investigate firmware image

% timestamp
Timestamp = ctime(sum((image(timestampofs+1:timestampofs+1 + timestamplen - 1)-0) .* [1, 256, 256^2, 256^3]))

% filesize
if ( nbytes != sum((image(filesizeofs+1:filesizeofs+1 + filesizelen - 1)-0) .* [1, 256, 256^2, 256^3]) )
  printf("File size mismatch %d != %d\n" , nbytes, sum((image(filesizeofs+1:filesizeofs+1 + filesizelen - 1)-0) .* [1, 256, 256^2, 256^3]) );
  exit(-1);
else
  printf("File size ok: %d bytes\n", nbytes);
end

% consistency check
dataofs = alwayszeroofs;
datalen = alwayszerolen;
datareq = alwayszero;
data = image(dataofs+1: dataofs+1 + datalen - 1)-0;

if ( sum(data != datareq) != 0 )
  disp('File inconsistent!');
end

dataofs = alwaysoneofs;
datalen = alwaysonelen;
datareq = alwaysone;
data = image(dataofs+1: dataofs+1 + datalen - 1)-0;

if ( sum(data != datareq) != 0 )
  disp('File inconsistent!');
end

dataofs = alwaystwoofs;
datalen = alwaystwolen;
datareq = alwaystwo;
data = image(dataofs+1: dataofs+1 + datalen - 1)-0;

if ( sum(data != datareq) != 0 )
  disp('File inconsistent!');
end

% firmware name
Firmware = image(firmwarenameofs+1: firmwarenameofs+1 + firmwarenamelen - 1)

% rootUImage

targetofs = posRootUImageofs;
targetlen = posRootUImagelen;
rootUImagepos = sum(image(targetofs+1: targetofs+1 + targetlen - 1) .* [1, 256, 256^2, 256^3])

targetofs = filesizeRootUImageofs;
targetlen = filesizeRootUImagelen;
rootUImagesize = sum(image(targetofs+1: targetofs+1 + targetlen - 1) .* [1, 256, 256^2, 256^3])

% fsImage

targetofs = posfsImageofs;
targetlen = posfsImagelen;
fsImagepos = sum(image(targetofs+1: targetofs+1 + targetlen - 1) .* [1, 256, 256^2, 256^3])

targetofs = filesizefsImageofs;
targetlen = filesizefsImagelen;
fsImagesize = sum(image(targetofs+1: targetofs+1 + targetlen - 1) .* [1, 256, 256^2, 256^3])

% dspImage

targetofs = posdspImageofs;
targetlen = posdspImagelen;
dspImagepos = sum(image(targetofs+1: targetofs+1 + targetlen - 1) .* [1, 256, 256^2, 256^3])

targetofs = filesizedspImageofs;
targetlen = filesizedspImagelen;
dspImagesize = sum(image(targetofs+1: targetofs+1 + targetlen - 1) .* [1, 256, 256^2, 256^3])

% check md5

md5req = image(md5ofs+1: md5ofs+1 + md5len - 1);
md5reqstr = reshape(tolower(dec2hex(md5req-0,2))', 1,32 )

md5str = md5sum(image(rootUImagepos+1 : nbytes), 1)

if ( strcmp(md5str, md5reqstr) == 0 )
  disp('MD5 check failed!');
  exit(-1);
end

% check uboot magic
if ( sum((image(rootUImagepos+1:rootUImagepos+1 + 4 - 1)-0) != ubootmagic) != 0 )
  disp('Uboot magic check failed');
  exit(-1);
end

% save parts

fid = fopen(strcat(filename, ".uImage"), "w");
fwrite(fid, image(rootUImagepos+1 : rootUImagepos+1 + rootUImagesize - 1), "char");
fclose(fid);

fid = fopen(strcat(filename, ".kernel.lzma"), "w");
fwrite(fid, image(rootUImagepos+1 + ubootheaderlen : rootUImagepos+1 + rootUImagesize - 1), "char");
fclose(fid);

fid = fopen(strcat(filename, ".fs"), "w");
fwrite(fid, image(fsImagepos+1 : fsImagepos+1 + fsImagesize - 1), "char");
fclose(fid);

fid = fopen(strcat(filename, ".dsp"), "w");
fwrite(fid, image(dspImagepos+1 : dspImagepos+1 + dspImagesize - 1), "char");
fclose(fid);

% decompress kernel

system(cstrcat("lzma -k -f -d ", filename, ".kernel.lzma"));
 
printf("SUCCESS!\n");
