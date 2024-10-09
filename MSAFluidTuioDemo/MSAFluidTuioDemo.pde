/***********************************************************************
 * 
 * Demo of the MSAFluid library (www.memo.tv/msafluid_for_processing) controlled by TUIO
 * Move mouse to add dye and forces to the fluid.
 * Alternatively use a TUIO tracker/server to control remotely (www.tuio.org)
 * 
 * Click mouse to turn off fluid rendering seeing only particles and their paths.
 * Demonstrates feeding input into the fluid and reading data back (to update the particles).
 * Also demonstrates using Vertex Arrays for particle rendering.
 * 
/***********************************************************************
 
 Copyright (c) 2008, 2009, Memo Akten, www.memo.tv
 *** The Mega Super Awesome Visuals Company ***
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of MSA Visuals nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 * ***********************************************************************/ 

import msafluid.*;
import oscP5.*;

int FLUID_WIDTH = 100;//90;
float FLUID_WEIGHT = 0.2; //2;
float FLUID_FADE_SPEED = 0.1;//0.003;
float FLUID_DELTA_T = 0.5;
float FLUID_VISC = 0.0001;

String fluid_weight_addr = "/misk-ac/fluid/weight";
String fluid_fadespeed_addr = "/misk-ac/fluid/fade-speed";
String fluid_deltat_addr = "/misk-ac/fluid/delta-t";
String fluid_visc_addr = "/misk-ac/fluid/visc";

float invWidth, invHeight;    // inverse of screen dimensions
float aspectRatio, aspectRatio2;

MSAFluidSolver2D fluidSolver;
ParticleSystem particleSystem;
OscP5 oscP5;
//NetAddress myBroadcastLocationOSC;

PImage imgFluid;
PImage sprite;  

boolean drawFluid = true;

PVector vel= new PVector(0,0);

void setup() {
    //size(960, 640, P2D);    // use OPENGL rendering for bilinear filtering on texture
    //size(screen.width * 49/50, screen.height * 49/50, OPENGL);
    fullScreen(P2D);
    //hint( ENABLE_OPENGL_4X_SMOOTH );    // Turn on 4X antialiasing
    invWidth = 1.0f/width;
    invHeight = 1.0f/height;
    aspectRatio = width * invHeight;
    aspectRatio2 = aspectRatio * aspectRatio;

    // create fluid and set options
    fluidSolver = new MSAFluidSolver2D((FLUID_WIDTH), (FLUID_WIDTH * height/width));
    fluidSolver.enableRGB(true).setFadeSpeed(FLUID_FADE_SPEED).setDeltaT(FLUID_DELTA_T).setVisc(FLUID_VISC);
    
    // create image to hold fluid picture
    imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), RGB);
    sprite = loadImage("sprite.png");

    // create particle system
    particleSystem = new ParticleSystem(100);
    //hint(DISABLE_DEPTH_MASK);
    
    // create osc object
    oscP5 = new OscP5(this,12000);

    // init TUIO
    initTUIO();
}

void mouseMoved() {
    float mouseNormX = mouseX * invWidth;
    float mouseNormY = mouseY * invHeight;
    float mouseVelX = (mouseX - pmouseX) * invWidth;
    float mouseVelY = (mouseY - pmouseY) * invHeight;

    addForce(mouseNormX, mouseNormY, mouseVelX, mouseVelY);
    
    //vel.x = mouseVelX*30;
    //vel.y = mouseVelY*30;
}

/*void touchMoved() {
    float mouseNormX = touches[0].x * invWidth;
    float mouseNormY = touches[0].y * invHeight;
    float mouseVelX = (random(-.3, .3)) * invWidth;
    float mouseVelY = (random(-.3, .3)) * invHeight;

    addForce(mouseNormX, mouseNormY, mouseVelX, mouseVelY);
    
    //vel.x = mouseVelX*30;
    //vel.y = mouseVelY*30;
}*/

void draw() {
    updateTUIO();
    fluidSolver.update();

    if(drawFluid) {
        for(int i=0; i<fluidSolver.getNumCells(); i++) {
            int d = (int)(FLUID_WEIGHT * 100); // 2;
            imgFluid.pixels[i] = color(fluidSolver.r[i] * d, fluidSolver.g[i] * d, fluidSolver.b[i] * d);
        }  
        imgFluid.updatePixels();//  fastblur(imgFluid, 2);
        image(imgFluid, 0, 0, width, height);
    } 
    particleSystem.update(vel);
    particleSystem.display();
    //particleSystem.setEmitter(mouseX, mouseY);
}

void mousePressed() {
    //drawFluid ^= true;
}

void keyPressed() {
    switch(key) {
    case 'r': 
        break;
    }
}



// add force and dye to fluid, and create particles
void addForce(float x, float y, float dx, float dy) {
    float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio
    
    //println("x: " + x + ", y: " + y + ", vx: " + dx + ", vy: " + dy);

    if(speed > 0) {
        if(x<0) x = 0; 
        else if(x>1) x = 1;
        if(y<0) y = 0; 
        else if(y>1) y = 1;

        float colorMult = 5;
        float velocityMult = 30.0f;

        int index = fluidSolver.getIndexForNormalizedPosition(x, y);

        color drawColor;

        colorMode(HSB, 360, 1, 1);
        float hue = ((x + y) * 180 + frameCount) % 360;
        drawColor = color(hue, 1, 1);
        colorMode(RGB, 1);  

        fluidSolver.rOld[index]  += red(drawColor) * colorMult;
        fluidSolver.gOld[index]  += green(drawColor) * colorMult;
        fluidSolver.bOld[index]  += blue(drawColor) * colorMult;
        
        vel.x = dx * velocityMult/2;
        vel.y = dy * velocityMult/2;

        fluidSolver.uOld[index] += dx * velocityMult;
        fluidSolver.vOld[index] += dy * velocityMult;
        
        particleSystem.setEmitter(x * width, y * height);
        //particleSystem.update(new PVector(dx*velocityMult, dy*velocityMult));

    }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  if(theOscMessage.checkAddrPattern(fluid_weight_addr)) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("f")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      FLUID_WEIGHT = theOscMessage.get(0).floatValue();  
      //print("### received an osc message /test with typetag ifs.");
      return;
    }  
  }
  else if(theOscMessage.checkAddrPattern(fluid_fadespeed_addr)) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("f")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float firstValue = theOscMessage.get(0).floatValue();  
      //float secondValue = theOscMessage.get(1).floatValue();
      //String thirdValue = theOscMessage.get(2).stringValue();
      //print("### received an osc message /test with typetag ifs.");
      println(" values: "+firstValue);
      //fluidSolver.setVisc(firstValue/100);
      //fluidSolver.setDeltaT(firstValue / 127);
      fluidSolver.setFadeSpeed(firstValue / 10);
      return;
    } 
    else if(theOscMessage.checkAddrPattern(fluid_deltat_addr)) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("f")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float firstValue = theOscMessage.get(0).floatValue();  
      //float secondValue = theOscMessage.get(1).floatValue();
      //String thirdValue = theOscMessage.get(2).stringValue();
      //print("### received an osc message /test with typetag ifs.");
      println(" values: "+firstValue);
      //fluidSolver.setVisc(firstValue/100);
      fluidSolver.setDeltaT(firstValue);
      //fluidSolver.setFadeSpeed(firstValue / 10);
      return;
    }
    else if(theOscMessage.checkAddrPattern(fluid_visc_addr)) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("f")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float firstValue = theOscMessage.get(0).floatValue();  
      //float secondValue = theOscMessage.get(1).floatValue();
      //String thirdValue = theOscMessage.get(2).stringValue();
      //print("### received an osc message /test with typetag ifs.");
      println(" values: "+firstValue);
      fluidSolver.setVisc(firstValue/100);
      //fluidSolver.setDeltaT(firstValue / 127);
      //fluidSolver.setFadeSpeed(firstValue / 10);
      return;
    }
  }
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}
