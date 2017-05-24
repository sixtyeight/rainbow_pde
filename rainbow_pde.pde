import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.net.InetAddress;
import java.util.Enumeration;

import artnet4j.*;

ArtNetClient  artnet;
ArtNetNode    artnetReceiver;

Minim      minim;
AudioInput lineIn;
FFT        fft;

byte[] artnetBuffer = new byte[512];

void setup()
{
  frameRate(120);
  size(500, 500);

  minim = new Minim(this);
  lineIn = minim.getLineIn(Minim.STEREO, 4096, 44100, 8);
  fft = new FFT(lineIn.bufferSize(), lineIn.sampleRate());

  try
  {
    artnet = new ArtNetClient();
    artnet.open(null, "10.20.255.255");
    artnetReceiver = artnet.getReceiver();
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

int [] rgbBuffer = new int[3];
ArtDmxPacket dmx = new ArtDmxPacket();

void draw()
{
  // fft.forward( lineIn.mix );
  // map(fft.calcAvg(50, 500), 0, 9, 0, 1);
  // map((fft.calcAvg(500, 3000)), 0, 1, 0, 1);
  // map((fft.calcAvg(500, 1000)), 0, 1, 0, 1);

  for (int i=0; i<12; i++) {
    int pos = 0;
    pos = ((i * 256 / 12) + (frameCount % 256)) & 255;
    wheel(pos, rgbBuffer);

    int umbrellaOffset = i * 5;
    artnetBuffer[umbrellaOffset] = (byte) (rgbBuffer[0]); // r
    artnetBuffer[umbrellaOffset+1] = (byte) (rgbBuffer[1]); // g
    artnetBuffer[umbrellaOffset+2] = (byte) (rgbBuffer[2]); // b
  }

  // artnet.send(3, artnetBuffer);
  for(int j=0; j<4; j++) {
    artnet.send(dmx, artnetReceiver, 3, artnetBuffer);
  }
}

void stop()
{
  artnet.close();
}

void wheel(int pos, int[] destArray)
{
  pos = 255 - pos;

  // System.out.println("pos: " + pos);
  
  if (pos < 85) {
    destArray[0] = 255 - pos * 3;
    destArray[1] = 0;
    destArray[2]= pos * 3;
    return;
  }
  if (pos < 170) {
    pos -= 85;
    destArray[0] = 0;
    destArray[1] = pos * 3;
    destArray[2]= 255 - pos * 3;
    return;
  }
  pos -= 170;
  destArray[0] = pos * 3;
  destArray[1] = 255 - pos * 3;
  destArray[2]= 0;
}