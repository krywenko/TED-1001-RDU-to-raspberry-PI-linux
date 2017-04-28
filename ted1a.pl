#!/usr/bin/perl -w -s

system("stty -F /dev/ttyUSB0 1200 cs8 raw");

open INFILE, "/dev/ttyUSB0"
   or die "\nCannot open /dev/ttyUSB0!\n";
   
 #mqtt setting  
   
 $ip = "192.168.168.43";
 $port= "1883";
#topics
  $ted = 'TED';
  $ted2 = 'TED2';
  $ted3 = 'TED3';
   


@data = ();
$buf = "";
$begin = 0;
$started = 0;
sub processPacket($);

while (read(INFILE, $buf, 1)) {
  $d = ord($buf) ^ 0xff;
  if ($d == 0x55 && $started == 0) {
    $started = 1;
    $a = 0;
   
  }
  if ($started == 1) {
    $data[$a] = $d;
    $sum += $data[$a];
     printf("0x%02X ", $data[$a]);
    $a++;
        if ($a >= 11) {
      $sum -= $data[9];
      $sum &= 0xff;
      if ($sum == 0) { processPacket($data); }
      $started=1;
      $a = 0;     
    }
    
  }
  if ( $begin <= 22) {
  $cnt = ($begin + 1);
  $begin = $cnt;}
  # print "$begin bit ";
  if ($begin >= 23) {close INFILE;}
}

  # Working sub process packet stuff
  sub processPacket($) {
  local($data) = @_;
 
  
  $mtu = $data[1];
  # the $mtu equals your mtu number put in a Decimal to Hexadecimal Converter )
  if ($begin <=  22) {
  $begin = 1;
  if ($mtu == 0xE5 ) {
  #  If the power reading is way off, uncomment the other power line
   $p = (($data[5]^0xff)<<8) + ($data[4]^0xff);
   # print "$p ";
   $pa = ($data[5]<<8) + $data[4];
   # print "$pa ";
  if ($p <= 5000) {
  $voltage = ($data[8] << 8) | $data[7];
  $voltage = sprintf("%.3f",123.6 + ($voltage - 27620) / 85 * 0.2);
  $p = sprintf("%.3f",(1.19 + 0.84 * (($p - 288.0) / 204.0)));
  @tda = localtime(time);
  $td = ($tda[4]+1)."/$tda[3]/".(1900+$tda[5])." $tda[2]:$tda[1]:$tda[0]";
  print "$td, Hydro $p, Voltage $voltage\n";
  system("mosquitto_pub -h $ip -p $port -t $ted -m $p");
  system("mosquitto_pub -h $ip -p $port -t $ted/volt -m $voltage");
  $begin = 0;
  }
  if ($pa <= 5000) {
  # $power = ($data[5]<<8) + $data[4];
  $voltage = ($data[8] << 8) | $data[7];
  $voltage = sprintf("%.3f",123.6 + ($voltage - 27620) / 85 * 0.2);
  $pa = sprintf("%.3f",(0 - (1.19 + 0.84 * (($pa - 288.0) / 204.0))));
  @tda = localtime(time);
  $td = ($tda[4]+1)."/$tda[3]/".(1900+$tda[5])." $tda[2]:$tda[1]:$tda[0]";
  print "$td, Hydro $pa, Voltage $voltage\n";
  system("mosquitto_pub -h $ip -p $port -t $ted -m $pa");
  system("mosquitto_pub -h $ip -p $port -t $ted/volt -m $voltage");
  $begin = 0;
  }
  }
  
   if ($mtu == 0xA0 ) {
  #  If the power reading is way off, uncomment the other power line
   $w = (($data[5]^0xff)<<8) + ($data[4]^0xff);
   # print "$w ";
   $wa = ($data[5]<<8) + $data[4];
   # print "$wa ";
  if ($w <= 5000) {
  $voltage1 = ($data[8] << 8) | $data[7];
  $voltage1 = sprintf("%.3f",123.6 + ($voltage1 - 27620) / 85 * 0.2);
  $w = sprintf("%.3f",(1.19 + 0.84 * (($w - 288.0) / 204.0)));
  @tda = localtime(time);
  $td = ($tda[4]+1)."/$tda[3]/".(1900+$tda[5])." $tda[2]:$tda[1]:$tda[0]";
  print "$td, Wind $w, Voltage $voltage1\n";
  system("mosquitto_pub -h $ip -p $port -t $ted2 -m $w");
  system("mosquitto_pub -h $ip -p $port -t $ted2/volt -m $voltage1");
  $begin = 0;
  }
  if ($wa <= 5000) {
  # $power = ($data[5]<<8) + $data[4];
  $voltage1 = ($data[8] << 8) | $data[7];
  $voltage1 = sprintf("%.3f",123.6 + ($voltage1 - 27620) / 85 * 0.2);
  $wa = sprintf("%.3f",(0 - (1.19 + 0.84 * (($wa - 288.0) / 204.0))));
  @tda = localtime(time);
  $td = ($tda[4]+1)."/$tda[3]/".(1900+$tda[5])." $tda[2]:$tda[1]:$tda[0]";
  print "$td, Wind $wa, Voltage $voltage1\n";
  system("mosquitto_pub -h $ip -p $port -t $ted2 -m $wa");
  system("mosquitto_pub -h $ip -p $port -t $ted2/volt -m $voltage1");
  $begin = 0;
  }
  }
    if ($mtu == 0xB1 ) {
  #  If the power reading is way off, uncomment the other power line
   $s = (($data[5]^0xff)<<8) + ($data[4]^0xff);
   # print "$s ";
   $sa = ($data[5]<<8) + $data[4];
   # print "$sa ";
  if ($s <= 5000) {
  $voltage2 = ($data[8] << 8) | $data[7];
  $voltage2 = sprintf("%.3f",123.6 + ($voltage2 - 27620) / 85 * 0.2);
  $s = sprintf("%.3f",(1.19 + 0.84 * (($s - 288.0) / 204.0)));
  @tda = localtime(time);
  $td = ($tda[4]+1)."/$tda[3]/".(1900+$tda[5])." $tda[2]:$tda[1]:$tda[0]";
  print "$td, Solar $s, Voltage $voltage2\n";
  system("mosquitto_pub -h $ip -p $port -t $ted3 -m $s");
  system("mosquitto_pub -h $ip -p $port -t $ted3/volt -m $voltage2");
  $begin = 0;
  }
  if ($sa <= 5000) {
  # $power = ($data[5]<<8) + $data[4];
  $voltage2 = ($data[8] << 8) | $data[7];
  $voltage2 = sprintf("%.3f",123.6 + ($voltage2 - 27620) / 85 * 0.2);
  $sa = sprintf("%.3f",(0 - (1.19 + 0.84 * (($sa - 288.0) / 204.0))));
  @tda = localtime(time);
  $td = ($tda[4]+1)."/$tda[3]/".(1900+$tda[5])." $tda[2]:$tda[1]:$tda[0]";
  print "$td, Solar $sa, Voltage $voltage2\n";
  system("mosquitto_pub -h $ip -p $port -t $ted3 -m $sa");
  system("mosquitto_pub -h $ip -p $port -t $ted3/volt -m $voltage2");
  $begin = 0;
  }
  }
  
}}

  
close INFILE;
