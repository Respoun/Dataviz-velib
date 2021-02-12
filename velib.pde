import http.requests.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.Microsoft;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.marker.*;

PFont police;
UnfoldingMap map;
Location borneLocation; //<>//

static String name;
static int capacity, available, rows, num;
static float longitude, latitude;
float step, sz, offSet, theta, angle;


void setup(){
  
  //Setup screen
  size(1920, 1080, P2D);
  smooth(8); 
  noStroke();
    
  //Setup font
  police = createFont("TwCenMT-Condensed-48", 500); 
  textFont(police, 80);
  
  // get call method 
  call();
  
  //Allocate location and setup marker
  borneLocation = new Location(longitude, latitude);
  map = new UnfoldingMap(this, new StamenMapProvider.TonerBackground());
  MapUtils.createDefaultEventDispatcher(this, map);
  map.setTweening(false);
  map.zoomToLevel(20);
  map.panTo(borneLocation);
  SimplePointMarker borneMarker = new SimplePointMarker(borneLocation);
  map.addMarkers(borneMarker);
  
  //setup animation 
  strokeWeight(10);
  step = 30;
  num = available+1;
  
} //<>// //<>// //<>//

void draw() { //<>//
  map.draw();
  fill(0,0,0);
  textAlign(LEFT); 
  text(name, 100+100, 0+100);
  textAlign(CENTER, TOP);
  text(available+" / "+capacity,200+100, 0+100);
  
  //animation
  translate(width/2, height/2);
  angle=0;
  
  for (int i=0; i<num; i++) {
    stroke(0);
    noFill();
    sz = i*step;
    float offSet = TWO_PI+TWO_PI/num*i;
    float arcEnd = map(sin(theta+offSet),-1,1, PI, TWO_PI+TWO_PI);
    arc(0, 0, sz, sz, PI, arcEnd);
  }
  
  //map(map.getZoom(),5,15,,);
  //scale
  colorMode(RGB);
  resetMatrix();
  theta += .0200;
   
  if (keyPressed) {
    if (key == 'r') {
      setup();
      redraw();
     }
  }
}


void call(){
  rows = 100;
  String api_url = "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&q=&rows="+ rows +"&facet=name&facet=is_installed&facet=is_renting&facet=is_returning&facet=nom_arrondissement_communes"; 
  
  GetRequest get = new GetRequest(api_url);
  get.send();
  get.addHeader("Accept", "application/json");
  
  String data = get.getContent();
  JSONObject json = parseJSONObject(data);
  JSONArray records = json.getJSONArray("records");
  
  int r = int(random(rows));
  JSONObject fields = records.getJSONObject(r).getJSONObject("fields");
  name = fields.getString("name");
  capacity = fields.getInt("capacity");
  available = fields.getInt("numbikesavailable");
  JSONArray coordinates = fields.getJSONArray("coordonnees_geo");
  longitude = coordinates.getFloat(0);
  latitude = coordinates.getFloat(1);  
}
