import controlP5.*;
import org.json.*; 
import processing.net.*;


ControlP5 controlP5;
ControlFont font;

Client myClient;
Client tomClient;
String tomData;                       // string to hold incoming data
String tomIp = "128.122.151.164";
int pAttnValue = 0;
int pDeltaValue = 0;
int pAVZone = 0;
int pDVZone = 0;
Channel[] channels = new Channel[11];
Monitor[] monitors = new Monitor[10];
Graph graph;
ConnectionLight connectionLight;
int packetCount = 0;
int globalMax;
String scaleMode;

void setup() {
	size(1024, 768);
	smooth();
	
	// Set up the knobs and dials
	controlP5 = new ControlP5(this);
	controlP5.setColorLabel(color(0));
	// controlP5.setColorValue(color(0));	
	controlP5.setColorBackground(color(0));
	//controlP5.setColorForeground(color(130));
	// controlP5.setColorActive(color(0));	
	
	font = new ControlFont(createFont("DIN-MediumAlternate", 12), 12);
    
        // Connect to ThinkGear socket (default = 127.0.0.1:13854)
        // By default, Thinkgear only binds to localhost:
        // To allow other hosts to connect and run Processing from another machine, run ReplayTCP (http://www.dlcsistemas.com/html/relay_tcp.html)
        // OR, use netcat (windows or mac) to port forard (clients can now connect to port 13855).  Ex:  nc -l -p 13855 -c ' nc localhost 13854'
        
        String thinkgearHost = "127.0.0.1";
        int thinkgearPort = 13854;
        
        String envHost = System.getenv("THINKGEAR_HOST");
        if (envHost != null) {
          thinkgearHost = envHost;
        }
        String envPort = System.getenv("THINKGEAR_PORT");
        if (envPort != null) {
           thinkgearPort = Integer.parseInt(envPort);
        }
       
        println("Connecting to host = " + thinkgearHost + ", port = " + thinkgearPort);
        myClient = new Client(this, thinkgearHost, thinkgearPort);
        String command = "{\"enableRawOutput\": false, \"format\": \"Json\"}\n";
        print("Sending command");
        println (command);
        myClient.write(command);
        
        //instantiate tomClient
        println("connecting to tom's ip");
        tomClient = new Client(this, tomIp, 8080);	
	
	// Creat the channel objects
	// yellow to purple and then the space in between, grays for the alphas
	channels[0] = new Channel("Signal Quality", color(0), "");
	channels[1] = new Channel("Attention", color(100), "");
	channels[2] = new Channel("Meditation", color(50), "");
	channels[3] = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep");
	channels[4] = new Channel("Theta", color(245, 80, 71), "Drowsy");
	channels[5] = new Channel("Low Alpha", color(237, 0, 119), "Relaxed");
	channels[6] = new Channel("High Alpha", color(212, 0, 149), "Relaxed");
	channels[7] = new Channel("Low Beta", color(158, 18, 188), "Alert");
	channels[8] = new Channel("High Beta", color(116, 23, 190), "Alert");
	channels[9] = new Channel("Low Gamma", color(39, 25, 159), "???");
	channels[10] = new Channel("High Gamma", color(23, 26, 153), "???");
	
	// Manual override for a couple of limits.
	channels[0].minValue = 0;
	channels[0].maxValue = 200;
	channels[1].minValue = 0;
	channels[1].maxValue = 100;
	channels[2].minValue = 0;
	channels[2].maxValue = 100;
	channels[0].allowGlobal = false;
	channels[1].allowGlobal = false;
	channels[2].allowGlobal = false;
	
	// Set up the monitors, skip the signal quality
	
	for (int i = 0; i < monitors.length; i++) {
		monitors[i] = new Monitor(channels[i + 1], i * (width / 10), height / 2, width / 10, height / 2, this);
	}
	
	monitors[monitors.length - 1].w += width % monitors.length;
	
	
	
	// Set up the graph
	graph = new Graph(0, 0, width, height / 2);
	
	connectionLight = new ConnectionLight(width - 98, 10, 20, this);
	
	globalMax = 0;
}

void draw() {
  	
        //if there's data from tom's server, log the data

       if (tomClient.available() > 0) {
          println("data from tom");
          // get the data:
          tomData = tomClient.readString(); 
          background(#000045);
          fill(#eeeeff);
          println(tomData);
        } 
  
	// find the global max
	if(scaleMode == "Global") {
		if(channels.length > 3) {
			for(int i = 3; i < channels.length; i++) {
				if (channels[i].maxValue > globalMax) globalMax = channels[i].maxValue;
			}
		}
	}	
	
	background(255);

	graph.update();
	graph.draw();
	
	connectionLight.update();
	connectionLight.draw();
	
	for (int i = 0; i < monitors.length; i++) {
		monitors[i].update();
		monitors[i].draw();

                int curAttnValue = monitors[0].currentValue;
                int curDeltaValue = monitors[1].currentValue;
                int curAVZone = 2;
                int curDVZone = 2;
                
                if(curAttnValue<120){
                  curAVZone = 1;
                } else if (curAttnValue>=120 && curAttnValue<140){
                  curAVZone = 2;
                } else if (curAttnValue>=140 && curAttnValue<160){
                  curAVZone = 3;
                } else if (curAttnValue>=160 && curAttnValue<180){
                  curAVZone = 4;
                } else if (curAttnValue>=180 && curAttnValue<200){
                  curAVZone = 5;
                } else if (curAttnValue>=200 && curAttnValue<220){
                  curAVZone = 6;
                } else if (curAttnValue>=220 && curAttnValue<240){
                  curAVZone = 7; 
                } else if (curAttnValue>=240 && curAttnValue<260){
                  curAVZone = 8;
                } else if (curAttnValue>=260){
                  curAVZone = 9;
                }

                if(curDeltaValue<50){
                  curDVZone = 1;
                } else if (curDeltaValue>=50 && curDeltaValue<60){
                  curDVZone = 2;
                } else if (curDeltaValue>=60 && curDeltaValue<70){
                  curDVZone = 3;
                } else if (curDeltaValue>=70 && curDeltaValue<80){
                  curDVZone = 4;
                } else if (curDeltaValue>=80 && curDeltaValue<90){
                  curDVZone = 5;
                } else if (curDeltaValue>=90 && curDeltaValue<100){
                  curDVZone = 6;
                } else if (curDeltaValue>=100 && curDeltaValue<110){
                  curDVZone = 7; 
                } else if (curDeltaValue>=110 && curDeltaValue<120){
                  curDVZone = 8;
                } else if (curDeltaValue>=120 && curDeltaValue<=130){
                  curDVZone = 9;
                } else if (curDeltaValue>=130 && curDeltaValue<140){
                  curDVZone = 10;
                } else if (curDeltaValue>=140 && curDeltaValue<150){
                  curDVZone = 11;
                } else if (curDeltaValue>=150 && curDeltaValue<160){
                  curDVZone = 12;
                } else if (curDeltaValue>=160 && curDeltaValue<170){
                  curDVZone = 13;
                } else if (curDeltaValue>=170 && curDeltaValue<180){
                  curDVZone = 14;
                } else if (curDeltaValue>=180 && curDeltaValue<190){
                  curDVZone = 15; 
                } else if (curDeltaValue>=190 && curDeltaValue<200){
                  curDVZone = 16;
                } else if (curDeltaValue>=200 && curDeltaValue<210){
                  curDVZone = 17;
                } else if (curDeltaValue>=210 && curDeltaValue<220){
                  curDVZone = 18;
                } else if (curDeltaValue>=220 && curDeltaValue<230){
                  curDVZone = 19;
                } else if (curDeltaValue>=230 && curDeltaValue<240){
                  curDVZone = 20;
                } else if (curDeltaValue>=240 && curDeltaValue<250){
                  curDVZone = 21;
                } else if (curDeltaValue>=250 && curDeltaValue<260){
                  curDVZone = 22;
                } else if (curDeltaValue>=260 && curDeltaValue<270){
                  curDVZone = 23; 
                } else if (curDeltaValue>=270 && curDeltaValue<280){
                  curDVZone = 24;
                } else if (curDeltaValue>=280 && curDeltaValue<290){
                  curDVZone = 25;
                } else if (curDeltaValue>=290 && curDeltaValue<300){
                  curDVZone = 26;
                } else if (curDeltaValue>=300 && curDeltaValue<310){
                  curDVZone = 27;
                } else if (curDeltaValue>=310 && curDeltaValue<320){
                  curDVZone = 28;
                } else if (curDeltaValue>=320 && curDeltaValue<330){
                  curDVZone = 29;
                } else if (curDeltaValue>=330 && curDeltaValue<340){
                  curDVZone = 30;
                } else if (curDeltaValue>=340 && curDeltaValue<350){
                  curDVZone = 31; 
                } else if (curDeltaValue>=350){
                  curDVZone = 32;
                }             
                
                println("HORIZONTAL: " + curAttnValue + " , " + pAttnValue + " , " + curAVZone + " , " + pAVZone);
//                println("curAttnValue: " + curAttnValue + " pAttnValue: " + pAttnValue + " curAVZone: " + curAVZone + " pAVZone: " + pAVZone);
                println("VERTICAL: " + curDeltaValue + " , " + pDeltaValue + " , "  + curDVZone + " , "  + pDVZone);

                if(pAVZone < curAVZone){
                  
                  println("writing r");
                  tomClient.write('r');
                  
                } else if (pAVZone > curAVZone ){
                  
                  println("writing l");
                  tomClient.write('l');
                  
                } else if (pDVZone < curDVZone){
                          
                  println("writing u");
                  tomClient.write('u');        
                  
                } else if (pDVZone > curDVZone){
                          
                  println("writing d");
                  tomClient.write('d');        
                  
                }

                pAttnValue = curAttnValue;
                pAVZone = curAVZone;
                pDeltaValue = curDeltaValue;
                pDVZone = curDVZone;
                
	}
	
	
	
}

void clientEvent(Client  myClient) {
  
  // Sample JSON data:
  // {"eSense":{"attention":91,"meditation":41},"eegPower":{"delta":1105014,"theta":211310,"lowAlpha":7730,"highAlpha":68568,"lowBeta":12949,"highBeta":47455,"lowGamma":55770,"highGamma":28247},"poorSignalLevel":0}
  
  if (myClient.available() > 0) {
  
    String data = myClient.readString();
    try {
      JSONObject json = new JSONObject(data);
      
      channels[0].addDataPoint(Integer.parseInt(json.getString("poorSignalLevel")));
      
      JSONObject esense = json.getJSONObject("eSense");
      if (esense != null) {
        channels[1].addDataPoint(Integer.parseInt(esense.getString("attention")));
        channels[2].addDataPoint(Integer.parseInt(esense.getString("meditation"))); 
      }
      
      JSONObject eegPower = json.getJSONObject("eegPower");
      if (eegPower != null) {
        channels[3].addDataPoint(Integer.parseInt(eegPower.getString("delta")));
        channels[4].addDataPoint(Integer.parseInt(eegPower.getString("theta"))); 
        channels[5].addDataPoint(Integer.parseInt(eegPower.getString("lowAlpha")));
        channels[6].addDataPoint(Integer.parseInt(eegPower.getString("highAlpha")));  
        channels[7].addDataPoint(Integer.parseInt(eegPower.getString("lowBeta")));
        channels[8].addDataPoint(Integer.parseInt(eegPower.getString("highBeta")));
        channels[9].addDataPoint(Integer.parseInt(eegPower.getString("lowGamma")));
        channels[10].addDataPoint(Integer.parseInt(eegPower.getString("highGamma")));
      }
      
      packetCount++;
  
      
    }
    catch (JSONException e) {
      println ("There was an error parsing the JSONObject." + e);
    };
  
  }

}

void keyReleased() {
  // send out anything that's typed:
  println("writing x");
  tomClient.write(key);
}

// Extend core's Map function to the Long datatype.
long mapLong(long x, long in_min, long in_max, long out_min, long out_max)  { 
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min; 
}

long constrainLong(long value, long min_value, long max_value) {
  if(value > max_value) return max_value;
  if(value < min_value) return min_value;
  return value;
}

