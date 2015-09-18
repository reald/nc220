#!/usr/bin/perl
#
# Proof of concept:
# Configure motion detection for tp-link nc220 lan camera.
# May work for nc200 camera, too.
#
# (c) Dennis Real 2015, v0.2
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Known issues:
# - No connection timeout handling
# - Timeout issues: - Reading/Writing camera too fast will block you for some minutes
#                   - Maybe calling cyclic watcherheartbeat.fcgi helps???
# - Code needs clean up!

use strict;
use warnings;

use MIME::Base64;

use LWP;
use HTTP::Cookies;

use Tk;
use Tk::JPEG;


# config #####################

my $user = "admin";
my $password = "admin";
my $password_b64 = encode_base64($password, "");
my $camera_addr = "nc220.lan";
my $camera_admin_port = 80;
my $camera_stream_port = 8080;
my $camera_realm = "TP-Link IP-Camera";
my $snapshotfile = "/tmp/nc220_snapshot.jpg";
my $debug = 1;

# constants ##################

my $camera_pic_width = 640;
my $camera_pic_height = 480;
my $motion_colunms = 16;
my $motion_rows = 12;

my $url_admin = "http://${camera_addr}:$camera_admin_port";
my $url_stream = "http://${camera_addr}:$camera_stream_port";

# vars #######################

my %fields = ();
my %output_areas = ();
my $sensitivity = 0;
my $enablemotiondetect = 0;
my $daynightmode = 0;
my $daymodestarttime = 0;
my $daymodeendtime = 0;
my $connection_token = "";
my $browserAdminConnection;

# main #######################

# fetch image from camera
CamFetchImage();



# tk #########################

my $mainWindow = MainWindow->new( -title=>'TP-Link NC220 motion detection configuration');

my $canvas = $mainWindow->Canvas( -width=>$camera_pic_width,
                                  -height=>$camera_pic_height
                                )->pack();
#$canvas->configure(-scrollregion=> [$canvas->bbox('all')] );

my $img = $mainWindow->Photo( -file => $snapshotfile );

$canvas->createImage(0,0,
                      -image => $img,
                      -anchor => 'nw',
                      -tags => ['img'],
                    );


my $enable_btn = $mainWindow->Checkbutton(
  -text => 'Enable motion detection (must be enabled to update fields)',
  -variable => \$enablemotiondetect )->pack();

my $topframe = $mainWindow->Frame()->pack(-expand=>1);

my $frame1 = $topframe->Frame()->grid(-row=>0, -column=>0);

my $lable1 = $frame1->Label( -text=> 'Day/Night:' )->pack();

my $radio1 = $frame1->Radiobutton( -text => 'Auto',
   -value => 1,
   -variable => \$daynightmode )->pack(-anchor=>'center');

my $radio2 = $frame1->Radiobutton( -text => 'Day',
   -value => 2,
   -variable => \$daynightmode )->pack(-anchor=>'center');

my $radio3 = $frame1->Radiobutton( -text => 'Night',
   -value => 3,
   -variable => \$daynightmode )->pack(-anchor=>'center');


$frame1 = $topframe->Frame()->grid(-row=>0, -column=>1);

$lable1 = $frame1->Label( -text=> 'Sensitivity:' )->pack();

$radio1 = $frame1->Radiobutton( -text => 'High',
   -value => 3,
   -variable => \$sensitivity )->pack(-anchor => 'center');

$radio2 = $frame1->Radiobutton( -text => 'Mid',
   -value => 2,
   -variable => \$sensitivity )->pack(-anchor => 'center');

$radio3 = $frame1->Radiobutton( -text => 'Low',
   -value => 1,
   -variable => \$sensitivity )->pack(-anchor => 'center');


$frame1 = $topframe->Frame()->grid(-row=>2, -column=>0, -columnspan=>2);

my $readimage_btn = $frame1->Button( -text => 'Get image',
                                     -command => \&GuiUpdateImage, )->pack(-side=>'left');

my $disableall_btn = $frame1->Button( -text => 'Disable all', 
                                      -command => \&GuiDisableAllFields, )->pack( -side=>'left' );

my $enableall_btn = $frame1->Button( -text => 'Enable all', 
                                     -command => \&GuiEnableAllFields, )->pack( -side=>'left' );

my $readcamera_btn = $frame1->Button( -text => 'Read config from Camera', 
                                     -command => \&CamReadConfig, )->pack( -side=>'left' );

my $savecamera_btn = $frame1->Button( -text => 'Save config to Camera', 
                                     -command => \&CamSaveConfig, )->pack( -side=>'left' );


my $rebootcamera_btn = $frame1->Button( -text => 'Reboot', 
                                     -command => \&CamReboot, )->pack( -side=>'left' );

my $quit_btn = $frame1->Button( -text => 'Quit', 
                                -command => sub { CamDisconnect(); exit(0); }, )->pack( -side=>'left' );;
$mainWindow->bind('<KeyPress-q>' => sub { exit(0); });

#GuiDrawLines();
GuiPlaceFields();

                                     
MainLoop;


# sub functions ##############

# gui functions

sub get_current 
{
  my ( $c, $x, $y ) = @_;
  $c->addtag( qw/current closest/, $x, $y );
  my @tags = grep {$_ ne 'current'} $c->gettags(qw/current/);
  $c->dtag(qw/current current/);
  return @tags;
}



sub GuiPlaceFields
{
  my $d_x = $camera_pic_width / $motion_colunms;
  my $d_y = $camera_pic_height / $motion_rows;

  my $idx = 0;
  for ( my $y = 0; $y < $motion_rows; $y++ )
  {
    my $y_pos = $y * $d_y;  
    
    for ( my $x = 0; $x < $motion_colunms; $x++ )
    {
      my $x_pos = $x * $d_x;

      my $id = $canvas->createRectangle($x_pos+1, $y_pos+1, $x_pos + $d_x, $y_pos + $d_y, -outline=>'red', -fill=>'lightgreen', -activestipple=>'gray50', -stipple=>'transparent', -tags=>"item$idx");
      $fields{"item$idx"} = 1;
      $idx++;
    }

  }

  
  $canvas->CanvasBind('<1>' => sub { my ($c) = @_;
                                     GuiToggleField( get_current( $c, $Tk::event->x, $Tk::event->y ) ), "\n"; }
                     );
                        
}



sub GuiToggleField
{
  my $param = shift;
  
  if ( $fields{$param} == 1 )
  {
    $canvas->itemconfigure($param, -fill=>"black", -stipple=>'gray75');
    $fields{$param} = 0;
  }
  else
  {
    $canvas->itemconfigure($param, -fill=>'lightgreen', -stipple=>'transparent');   
    $fields{$param} = 1;
  }
}



sub GuiDisableAllFields
{
  for ( my $i = 0; $i < $motion_colunms * $motion_rows; $i++)
  {
    my $param = "item$i";
    $canvas->itemconfigure($param, -fill=>"black", -stipple=>'gray75');
    $fields{$param} = 0;
  }
}



sub GuiEnableAllFields
{
  for ( my $i = 0; $i < $motion_colunms * $motion_rows; $i++)
  {
    my $param = "item$i";
    $canvas->itemconfigure($param, -fill=>"lightgreen", -stipple=>'transparent');
    $fields{$param} = 1;
  }
}



sub GuiRedrawFields
{
  for ( my $i = 0; $i < $motion_colunms * $motion_rows; $i++)
  {
    my $item = "item$i";
    if ( $fields{$item} == 1 )
    {
      $canvas->itemconfigure($item, -fill=>"lightgreen", -stipple=>'transparent');
    }
    else
    {
      $canvas->itemconfigure($item, -fill=>"black", -stipple=>'gray75');    
    }
  }
}



sub GuiRedrawImage
{
  $img->blank;
  $img->read($snapshotfile);
  $mainWindow->update;
}



sub GuiUpdateImage
{
  CamFetchImage();
  GuiRedrawImage();
}




# camera communication

sub CamFetchImage
{
  # connect to camera stream interface, get image, save image to file

  printDebug("Fetching Image from Camera ${url_stream} to ${snapshotfile}...");
  my $browser = LWP::UserAgent->new;
  my $req =  HTTP::Request->new( GET => "${url_stream}/stream/snapshot.jpg");
  $req->authorization_basic($user, $password_b64);
  my $cam_image = $browser->request( $req );

  $cam_image->is_success() or die "Error connecting camera ${camera_addr}:${camera_stream_port}: " . $cam_image->message() . " (" .$cam_image->status_line . ")"; 

  open(my $fh, '>', $snapshotfile);
  print $fh $cam_image->content();
  close ($fh);

  printDebug("done\n");
  
  #my $fetchimage = `wget --user=$user --password=$password_b64 ${url_stream}/stream/snapshot.jpg`;
}                    



sub CamCreateAreaInfos
{
  # sum up status of all single fields in areas for sending to camera
  
  my $area = 1;
  my $areaold = 1;
  my $areavalue = 0;
  my $areaintern = 0;
  
  for ( my $i = 0; $i < $motion_colunms * $motion_rows; $i++)
  {
    my $item = "item$i";
    $area = int($i / 8) + 1;
    $areaintern = $i % 8;

    if ( $area != $areaold )
    {
      # new area entered
      $output_areas{$areaold} = $areavalue;
      $areaold = $area;
      $areavalue = 0;

    }

    if ( $fields{$item} != 0 )
    {
      # set bit
      $areavalue |= 1<<$areaintern;
    }

  }

  # finish last field
  $output_areas{$areaold} = $areavalue;

}



sub CamConnectAdminInterface
{
  # login as admin if not already done

  my $req;

  if ( $connection_token eq "" )
  {
    $browserAdminConnection = LWP::UserAgent->new;
    $browserAdminConnection->cookie_jar( {} ); # use cookies
    
    $req = $browserAdminConnection->post( "${url_admin}/login.fcgi",
                                             [ 'Username'=>$user,
                                               'Password'=>$password_b64
                                             ],
                                            );
  
    die "Connection Error: ", $req->status_line unless $req->is_success;
  
    my $line = $req->content;

    printDebug($line . "\n");
  
    # expected: {"errorCode":0, "isAdmin":1, "token":"skfhdskfhksdhfkdhf"}
    
    if ( ($line =~ m/"errorCode":0,/)
          && ($line =~ m/"isAdmin":1,/) )
    {
      # errorCode ok and admin account. go on.
      $connection_token = $line;
      $connection_token =~ s/.*"token":"([a-zA-Z0-9]*)".*/$1/;
    }
    else
    {
      die("Error: Could not login or no admin account\n($line)\n");
    }


  }
  else
  {
    # already logged in. try heartbeat.
    

    $req = $browserAdminConnection->post( "${url_admin}/watcherheartbeat.fcgi",
                                             [ 'token'=>$connection_token
                                             ],
                                            );
  
    die "Heartbeat Error: ", $req->status_line unless $req->is_success;
    
    printDebug("Already connected: " . $req->content . "\n");

  }


}



sub CamReadConfig
{
  # connect to camera admin interface and retrieve configuration data

  CamConnectAdminInterface();

  # motion detection settings
  my $req = $browserAdminConnection->post( "${url_admin}/mdconf_get.fcgi" );
  
  die "Error retrieving camera config:\n", $req->status_line unless $req->is_success;

  # expected: {"errorCode":"0","is_enable":"1","precision":"3","area":[0,0,0,0,0,0,0,0,80,0,32,0,80,0,0,0,0,0,0,0,0,0,0,0,0]}  
  CamProcessConfig($req->content);

  printDebug($req->content . "\n");


  # daynightmode
  $req = $browserAdminConnection->post( "${url_admin}/daynightconfsettinginit.fcgi");

  die "Connection Error: ", $req->status_line unless $req->is_success;

  my $line = $req->content;

  printDebug($req->content . "\n");  


  # expected: {"errorCode":"0","daynightmode":"3", "daymodestarttime":"390","daymodeendtime":"1080"}
  if ( ($line =~ m/"errorCode":"0",/)
        && ($line =~ m/"daynightmode":"(\d)", "daymodestarttime":"(\d+)","daymodeendtime":"(\d+)"/) )
  {
    # errorCode ok and daynightmode received
    $daynightmode = $1;
    $daymodestarttime = $2;
    $daymodeendtime = $3;
  }
  else
  {
    printDebug("Warning: Did not get day/night settings\n($line)\n");
  }


}



sub CamProcessConfig
{
  # 1. process received camera configuration data
  # 2. store result in global variables
  # 3. update gui

  my $line = shift;
    
  #{"errorCode":"0","is_enable":"1","precision":"3","area":[0,0,0,0,0,0,0,0,80,0,32,0,80,0,0,0,0,0,0,0,0,0,0,0,0]}

  if ( ! $line =~ m/.*"errorCode":"0".*/ )
  {
    die ("Response has error:\n($line)\n");
  }

  if ( $line =~ m/.*"is_enable":"([01])".*/ )
  {
    $enablemotiondetect = $1;
  }

  if ( $line =~ m/.*"precision":"([0123])".*/ )
  {
    $sensitivity = $1;
  }

  my $area = $line;
  $area =~ s/.*"area":\[(.*)\].*/$1/;

  my @list = split(/,/, $area);

  if ( scalar(@list) != (($motion_colunms * $motion_rows) / 8) + 1 )
  {
    # there are 25 areas in resonse instead of 24?!?
    die ("Received " . scalar(@list) . " area fields instead of " . ($motion_colunms * $motion_rows) / 8 . "\n($area)");
  }
  
  for (my $j=0; $j < ($motion_colunms * $motion_rows) / 8; $j++)
  {

    my $value = $list[$j];
      
    my $idx_base = (8 * ($j+1)) - 8;
      
    for ( my $i = 0; $i <= 7; $i++ )
    {
      if ( $value & (1 << $i) )
      {
        $fields{"item". ($idx_base + $i)} = 1;
      }
      else
      {
        $fields{"item". ($idx_base + $i)} = 0;
      }
    }
  }

  GuiRedrawFields();

}



sub CamSaveConfig
{
  # connect to camera and save configuration data
  
  CamConnectAdminInterface();

  # save common data

  # translate all separated fields to area codes for sending
  CamCreateAreaInfos();

  printDebug("Saving data...\n");
  my $req = $browserAdminConnection->post( "${url_admin}/mdconf_set.fcgi",
                         [ 'is_enable'=>$enablemotiondetect,
                           'precision'=>$sensitivity,
                           'area1'=>$output_areas{1},
                           'area2'=>$output_areas{2},
                           'area3'=>$output_areas{3},
                           'area4'=>$output_areas{4},
                           'area5'=>$output_areas{5},
                           'area6'=>$output_areas{6},
                           'area7'=>$output_areas{7},
                           'area8'=>$output_areas{8},
                           'area9'=>$output_areas{9},
                           'area10'=>$output_areas{10},
                           'area11'=>$output_areas{11},
                           'area12'=>$output_areas{12},
                           'area13'=>$output_areas{13},
                           'area14'=>$output_areas{14},
                           'area15'=>$output_areas{15},
                           'area16'=>$output_areas{16},
                           'area17'=>$output_areas{17},
                           'area18'=>$output_areas{18},
                           'area19'=>$output_areas{19},
                           'area20'=>$output_areas{20},
                           'area21'=>$output_areas{21},
                           'area22'=>$output_areas{22},
                           'area23'=>$output_areas{23},
                           'area24'=>$output_areas{24},
                           'area25'=>0,
                           'token'=>$connection_token
                         ], );
  
  die "error: ", $req->status_line unless $req->is_success;

  printDebug($req->content() . "\n");

  # save daynight settings

  $req = $browserAdminConnection->post( "${url_admin}/daynightconf.fcgi",
                         [ 'daynightmode'=>$daynightmode,
                           'token'=>$connection_token
                         ], );
  
  die "error: ", $req->status_line unless $req->is_success;

  printDebug($req->content() . "\n");

}



sub CamDisconnect
{

  if ( $connection_token ne "" )
  {
    # logout
    my $req = $browserAdminConnection->post( "${url_admin}/logout.fcgi",
                                             [ 'token'=>$connection_token
                                             ],
                                            );
  
    die "Logout Error: ", $req->status_line unless $req->is_success;
  
    my $line = $req->content;
    
    printDebug($line . "\n");

    $connection_token = "";
  }

}



sub CamReboot
{

  if ( $connection_token ne "" )
  {
    # reboot
    my $req = $browserAdminConnection->post( "${url_admin}/reboot.fcgi",
                                             [ 'token'=>$connection_token
                                             ],
                                            );
  
    die "Reboot Error: ", $req->status_line unless $req->is_success;
  
    my $line = $req->content;
    
    printDebug($line . "\n");

    $connection_token = "";
  }

}



sub printDebug
{
  my $line = shift;
  
  if ( $debug != 0 )
  {
    print STDERR $line;
  }
}


# old

sub GuiDrawLines
{
  my $d_x = $camera_pic_width / $motion_colunms;
  my $d_y = $camera_pic_height / $motion_rows;
  
  for ( my $x = 1; $x < $motion_colunms; $x++ )
  {
    my $x_pos = $x * $d_x;
    my $id = $canvas->createLine($x_pos, 0, $x_pos, $camera_pic_height);
  }
  for ( my $y = 1; $y < $motion_rows; $y++ )
  {
    my $y_pos = $y * $d_y;
    my $id = $canvas->createLine(0, $y_pos, $camera_pic_width, $y_pos);
  }  
  
}
