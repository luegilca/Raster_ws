import frames.timing.*;
import frames.primitives.*;
import frames.processing.*;

// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;
int multiSample = 1;
int alpha = 0;
int sampleRate = 0;
int matches = 0;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;
boolean shading = false;
boolean antialiasing = false;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;

// Vertex colors used for shading
int[] colorV0 = new int[]{ 255, 0, 0 };
int[] colorV1 = new int[]{ 0, 255, 0 };
int[] colorV2 = new int[]{ 0, 0, 255 };

//Triangle vector coordinates
float v1x = 0.0;
float v1y = 0.0;
float v2x = 0.0;
float v2y = 0.0;
float v3x = 0.0;
float v3y = 0.0;

void setup() {
  //use 2^n to change the dimensions
  size(512, 512, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBallInterpolation();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it :)
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    public void execute() {
      spin();
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow(2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  triangleRaster();
  popStyle();
  popMatrix();
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  
  noStroke(); 
  v1x = frame.coordinatesOf( v1 ).x( );
  v1y = frame.coordinatesOf( v1 ).y( );
  v2x = frame.coordinatesOf( v2 ).x( );
  v2y = frame.coordinatesOf( v2 ).y( );
  v3x = frame.coordinatesOf( v3 ).x( );
  v3y = frame.coordinatesOf( v3 ).y( );
  int[] pixelColor = { 0, 192, 230 };
  
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  int halfSize = (int) pow( 2, n ) / 2;
  if( isWindedClockWise( v1, v2, v3 ) ) {
    swapVectors( );
  } 
  for( int x = -halfSize; x <= halfSize; x++ ) {
    for(  int y = -halfSize; y <= halfSize; y++ ) {
      alpha = 0; 
      if( antialiasing ) {
        sampleRate = ( int )pow( 2, multiSample );
        matches = 0;
        for( float i = 0; i < sampleRate; i++ ){
          for( float j = 0; j < sampleRate; j++ ){
            float sampleX = x + i / sampleRate + (float) 1 / ( 2 * sampleRate );
            float sampleY = y + j / sampleRate + (float) 1 / ( 2 * sampleRate );
            
            float w0 = edgeFunction( sampleX, sampleY, v1x, v1y, v2x, v2y );
            float w1 = edgeFunction( sampleX, sampleY, v2x, v2y, v3x, v3y );
            float w2 = edgeFunction( sampleX, sampleY, v3x, v3y, v1x, v1y );
            
            if( isInside( w0, w1, w2 ) ){
              matches++;
              if( shading ) pixelColor = getShadingColor( w0, w1, w2 );
            }
            if( debug ) drawCenters( sampleX, sampleY);            
          }
        }
        alpha = matches * (int)(255/sampleRate);        
      }
      else {
        float centerX = x + 0.5;
        float centerY = y + 0.5;
        
        float w0 = edgeFunction( centerX, centerY, v1x, v1y, v2x, v2y );
        float w1 = edgeFunction( centerX, centerY, v2x, v2y, v3x, v3y );
        float w2 = edgeFunction( centerX, centerY, v3x, v3y, v1x, v1y );
        if( isInside( w0, w1, w2 ) ) {      
          alpha = 255;
          if( shading ) pixelColor = getShadingColor( w0, w1, w2 );         
        }        
        if( debug ) {
          drawCenters( centerX, centerY );
        }        
      }
      plotPixel( x, y, pixelColor[0], pixelColor[1], pixelColor[2], alpha);        
    }
  }
}

int[] getShadingColor( float w0, float w1, float w2 ) {
  float area = edgeFunction( v1x, v1y, v2x, v2y, v3x, v3y );
  float lambda0 = w0 / area;
  float lambda1 = w1 / area;
  float lambda2 = w2 / area;            
  
  int red = round( lambda0 * colorV0[0] + lambda1 * colorV1[0] + lambda2 * colorV2[0] );
  int green = round( lambda0 * colorV0[1] + lambda1 * colorV1[1] + lambda2 * colorV2[1] );
  int blue = round( lambda0 * colorV0[2] + lambda1 * colorV1[2] + lambda2 * colorV2[2] );
  
  return new int[]{ red, green, blue, 255 };
}

boolean isInside( float w0, float w1, float w2 ) {
  boolean inside = true;
  inside &= w0 >= 0.0; 
  inside &= w1 >= 0.0;
  inside &= w2 >= 0.0;
  return inside;
}

void plotPixel( int x, int y, int r, int g, int b, int a ) {
  pushStyle( );
  fill( color( r, g, b, a ) );
  rect( x, y, 1, 1 );
  popStyle( );
}

void drawCenters( float x, float y ){
  pushStyle();
  stroke( color( 255, 255, 0 ) );
  strokeWeight( 0.1 );
  point( x , y );
  popStyle();
}

boolean isWindedClockWise( Vector v0, Vector v1, Vector v2 ) {
  Vector result = new Vector(); 
  Vector.cross( Vector.subtract( v1, v0 ), Vector.subtract( v2, v0 ), result );
  return result.z( ) > 0;
}

void swapVectors( ) {
  Vector tmp = v1;
  v1 = v2;
  v2 = tmp;
}

float edgeFunction( float px, float py, float v0x, float v0y, float v1x, float v1y ) {
  return ( ( px - v0x ) * ( v1y - v0y ) - ( py - v0y ) * ( v1x - v0x ) );
}

void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(5);
  stroke(0, 255, 255);
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
}

void spin() {
  if (scene.is2D())
    scene.eye().rotate(new Quaternion(new Vector(0, 0, 1), PI / 100), scene.anchor());
  else
    scene.eye().rotate(new Quaternion(yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100), scene.anchor());
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '>')
    multiSample = multiSample < 4 ? multiSample + 1 : 1;
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
  if (key == 's')
    shading = !shading;
  if (key == 'a')
    antialiasing = !antialiasing;
}