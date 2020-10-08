//********Merge with ImgProcessing******** //<>//
import gab.opencv.*;
//********Merge with ImgProcessing********
import processing.video.*;

class ImageProcessing extends PApplet {
  Movie cam;
  OpenCV opencv;
  TwoDThreeD converter;
  PVector rotation;
  PImage img;

  /********SETTINGS FOR HSB TRESHOLD********/
  final int Hmin = 105, Hmax = 140;
  final int Smin = 35, Smax = 255;
  final int Bmin = 40, Bmax = 255;
  /*****************************************/


  BlobDetection blobDetection;

  List<PVector> detectedCorners;

  void settings() {
    size(455, 255, P2D);
  }


  void setup() {

    opencv = new OpenCV(this, 100, 100);

    blobDetection = new BlobDetection();
    
    //Video
    cam = new Movie (this, "testvideo.avi"); //Put the absolute path here !!
    cam.loop();
  }


  void draw() {

    if (cam.available() == true) cam.read();
    img = cam.get();

    converter =new TwoDThreeD(img.width, img.height, 0);

    img.resize(img.width/2, img.height/2);
    image(img, 0, 0);
    
    img = thresholdHSB(img, Hmin, Hmax, Smin, Smax, Bmin, Bmax );
    img = convolute(img);
    img = blobDetection.findConnectedComponents(img, false);
    img = scharr(img);
    img = threshold(img, 100); // PImage threshold(PImage img, int threshold) the threshold value can be changed
    plotLines(hough(img, 4), img);

    ArrayList<PVector> lines = hough(img, 4); 
    detectedCorners = new QuadGraph().findBestQuad(lines, width, height, width*height, width*height/64, false);

    stroke(0);
    for (PVector vector : detectedCorners) {
      fill(color(255, 255, 255));
      ellipse(vector.x, vector.y, 30, 30);
    }

  }

  PVector getRotation() {
    if (detectedCorners == null) {
      return new PVector(0, 0, 0);
    }

    if (detectedCorners.size() == 4) {
      for (PVector corner : detectedCorners) {
        corner.set(corner.x, corner.y, 1);
      }

      rotation = converter.get3DRotations(detectedCorners);
      if ((rotation.x) <= - PI/3) rotation.set(rotation.x + PI, rotation.y, rotation.z);
      else if ((rotation.x) >= PI/3) rotation.set(rotation.x - PI, rotation.y, rotation.z);
    }

    return rotation;
  }
  
  
  
  

  //*******************************
  //         CONVOLUTION
  //*******************************
  PImage convolute(PImage img) {
    float[][] kernel = {
      { 9, 12, 9}, 
      { 12, 15, 12}, 
      { 9, 12, 9}};


    float normFactor = 99.f;

    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);

    // kernel size N = 3
    for (int i = 1; i < img.width -1; i++) {
      for (int j = 1; j< img.height -1; j++) {
        int tot = 0;
        int c = 0;
        for (int l = 0; l<3; l++) {
          for (int h = 0; h<3; h++) {
            c = i-1 + img.width*(j-1+h) +l;
            tot += kernel[h][l] * brightness(img.pixels[c]);
          }
        }
        result.pixels[j * img.width + i] = color(tot/normFactor);
      }
    }
    return result;
  }


  //*******************************
  //          THRESHOLD
  //*******************************
  // Inverted Binary Threshold
  PImage threshold(PImage img, int threshold) {
    // create a new, initially transparent, 'result' image
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (brightness(img.pixels[i]) < threshold) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = color(255);
      }
    }
    return result;
  }


  // HUE Method
  PImage applyHue(PImage img, int min, int max) {
    // create a new, initially transparent, 'result' image 
    PImage result = createImage(img.width, img.height, RGB);

    for (int i = 0; i < img.width * img.height; i++) {
      float h = hue(img.pixels[i]);
      if (min < h && max > h) {
        result.pixels[i] = img.pixels[i];
      } else {
        result.pixels[i] = color(h);
      }
    }
    return result;
  }


  // Threhold method for HUE, BRIGHTNESS and SATURATION
  PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
    PImage result = createImage(img.width, img.height, RGB);

    for (int i = 0; i < img.width * img.height; i++) {
      float hue = hue(img.pixels[i]);
      float bri = brightness(img.pixels[i]);
      float sat = saturation(img.pixels[i]);
      if (hue >= minH && hue <= maxH && bri <= maxB && bri >= minB && sat >= minS && sat <= maxS)
        result.pixels[i] = color(255);
      else
        result.pixels[i] = color(0);
    }
    return result;
  }

  //*******************************
  //            SCHARR 
  //*******************************
  PImage scharr(PImage img) {
    float[][] vKernel = {
      { 3, 0, -3 }, 
      { 10, 0, -10 }, 
      { 3, 0, -3 } };

    float[][] hKernel = {
      { 3, 10, 3 }, 
      { 0, 0, 0 }, 
      { -3, -10, -3 } };
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];

    // ***********************************
    // Implement here the double convolution
    // ***********************************
    for (int j = 1; j< img.height -1; j++) {
      for (int i = 1; i < img.width -1; i++) {
        float sum_v = 0;
        float sum_h = 0;
        int c = 0;
        for (int l = 0; l<3; l++) {
          for (int h = 0; h<3; h++) {
            c = i -1 + img.width * (j-1+h) +l;
            sum_v += vKernel[h][l] * brightness(img.pixels[c]);
            sum_h += hKernel[h][l] * brightness(img.pixels[c]);
          }
        }

        float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        buffer[j * img.width + i] = sum; 
        if (max <= sum) max = sum;
      }
    }

    for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
      for (int x = 1; x < img.width - 1; x++) { // Skip left and right
        int val=(int) ((buffer[y * img.width + x] / max)*255);
        result.pixels[y * img.width + x]=color(val);
      }
    }
    return result;
  }


  //*******************************
  //            HOUGH
  //*******************************

  // **********************************************************************
  // Step_1 - Draw the lines requiered - Compute and Store the polar representation
  // of lines passing through edge pixels 
  // **********************************************************************
  ArrayList<PVector> hough(PImage edgeImg, int nLines) {

    float discretizationStepsPhi = 0.07f;
    float discretizationStepsR = 2.8f;

    ArrayList<Integer> bestCandidates=new ArrayList<Integer>();

    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
      edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
    // our accumulator
    int[] accumulator = new int[phiDim * rDim];


    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }


    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator: r += rDim / 2
          for (int phi=0; phi<phiDim; ++phi) {
            int accR = (int) ((x*tabCos[phi]+y*tabSin[phi])+rDim/2);
            ++accumulator[phi*rDim+accR];
          }
        }
      }
    }


    // **********************************************************************
    // Step_2 - Display the accumulator
    // **********************************************************************
    /*PImage houghImg = createImage(rDim, phiDim, ALPHA);
     for (int i = 0; i < accumulator.length; i++) {
     houghImg.pixels[i] = color(min(255, accumulator[i]));
     }
     // You may want to resize the accumulator to make it easier to see:
     houghImg.resize(400, 400);
     houghImg.updatePixels();
     image(houghImg,img.width+50,0);*/

    final int minVotes=50;
    final int REGION_SIZE = 10;

    // Step 2 - Week 11 - Find Local Maxima
    for (int elem = 0; elem < accumulator.length; ++elem) {
      if (accumulator[elem] > minVotes && isMaxOverArea(accumulator, elem, REGION_SIZE, phiDim, rDim)) {
        bestCandidates.add(elem);
      }
    }

    // Sort the lsit of bestCandidates with the HoughComparator class 
    bestCandidates.sort(new HoughComparator(accumulator));

    // Construction of the arrayList of the lines for the return
    ArrayList<PVector> lines = new ArrayList<PVector>();

    // New method to find the lines (do not need to check if " > minVotes"
    // since the array bestCandidate already checked that condition
    for (int i=0; i < bestCandidates.size() && i < nLines; ++i) {
      int idx = bestCandidates.get(i);
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim));
      int accR = idx - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      lines.add(new PVector(r, phi));
    }
    return lines;
  }

  private boolean isMaxOverArea(int[] accumulator, int idx, int REGION_SIZE, int phiDim, int rDim) {
    int threshold=accumulator[idx];
    for (int dx=Math.max(0, idx%rDim-REGION_SIZE); dx<Math.min(rDim, idx%rDim+REGION_SIZE); ++dx) {
      for (int dy=Math.max(0, idx/rDim-REGION_SIZE); dy<Math.min(phiDim, idx/rDim+REGION_SIZE); ++dy) {
        if (accumulator[dx+dy*rDim]>threshold) {
          return false;
        }
      }
    }
    return true;
  }

  // **********************************************************************
  // Step_3 - Plot lines on the top of the image
  // **********************************************************************
  void plotLines(ArrayList<PVector> lines, PImage edgeImg) {
    for (int idx = 0; idx < lines.size(); idx++) {
      PVector line=lines.get(idx);
      float r = line.x;
      float phi = line.y;

      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)

      // compute the intersection of this line with the 4 borders of the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      //stroke(255, 0, 0);
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }
}
