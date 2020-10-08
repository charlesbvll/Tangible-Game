import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

class BlobDetection {

  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    PImage result  =  input.copy();
    int [] labels  =  new int [result.width * result.height];
    
    
    // **********************************************************************
    // First pass: label the pixels and store labels' equivalences
    // **********************************************************************
    List<TreeSet<Integer>> labelsEquivalences =  new ArrayList<TreeSet<Integer>>();
    ArrayList<Integer> meter = new ArrayList<Integer>();

    int currLabel  =  0;

    // First loop - for height
    for (int y = 0; y < result.height; ++y) {
      TreeSet<Integer> colourAdjacent = new TreeSet<Integer>();
      // Second loop - for width
      for (int x = 0; x < result.width; ++x) {
        if (brightness(result.pixels[y*result.width+x]) == 255) {
          colourAdjacent.clear();
          for (int i = x-1; i <= x+1; i++) {
            // Checks first row
            if (y != 0) { 
              if (0 <= i && i < result.width && labels[(y-1)*result.width+i] != 0) {
                colourAdjacent.add(labels[(y-1)*result.width+i]);
              }
            } else {
              // Do nothing since we are at the first line and we cannot consider the y-1 th line...
            }
          }

          if (colourAdjacent.isEmpty()) {
            TreeSet tree_set = new TreeSet<Integer>();
            tree_set.add(++currLabel);
            labelsEquivalences.add(tree_set);
            meter.add(1);
            labels[y*result.width+x] = currLabel;
          } else {
            if (colourAdjacent.size()>1) {
              for (Integer i : colourAdjacent) {
                labelsEquivalences.get(i-1).addAll(colourAdjacent);
              }
            }
            int first = colourAdjacent.first();
            meter.set(first-1, meter.get(first-1)+1);
            labels[y*result.width+x] = first;
          }
        }
      }
    }


    // **********************************************************************  
    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest =  = true, count the number of pixels for each label
    // **********************************************************************

    // Merge all equivalence classes of labels
    for (int labEq = 0; labEq < labelsEquivalences.size(); ++labEq) {
      TreeSet<Integer> tree_set = labelsEquivalences.get(labEq);
      if (tree_set.size()>1) {
        TreeSet<Integer> acc = new TreeSet<Integer>();
        for (Integer i : tree_set) {
          TreeSet<Integer> other = labelsEquivalences.get(i-1);
          if (tree_set != other) { 
            acc.addAll(other);
          }
        }
        tree_set.addAll(acc);
        for (Integer i : tree_set) {
          labelsEquivalences.set(i-1, tree_set);
        }
      }
    }

    // Evaluate size of blob
    int[] blobSize = new int[labelsEquivalences.size()];
    for (int labEq = 0; labEq<labelsEquivalences.size(); ++labEq) {
      TreeSet<Integer> tree_set = labelsEquivalences.get(labEq);
      int total = 0;
      for (Integer i : tree_set) {
        total += meter.get(i-1);
      }
      blobSize[labEq] = total;
    }


    // **********************************************************************
    // Finally:
    // if onlyBiggest =  = false, output an image with each blob colored in one uniform color
    // if onlyBiggest =  = true, output an image with the biggest blob in white and others in black
    // **********************************************************************
    
    int[] colorArray = new int[blobSize.length];
    if (onlyBiggest) {
      int maximum  = -1;
      for (int i = 0; i < blobSize.length; i++) {
        maximum = max(maximum, blobSize[i]);
      }
      for (int i = 0; i < blobSize.length; i++) {
        colorArray[i] = (blobSize[i] == maximum) ? color(255) : color(0);
      }
    } else {
      for (TreeSet<Integer> tree_set : labelsEquivalences) {
        int randomColor = color(random(255), random(255), random(255));
        for (Integer i : tree_set) {
          colorArray[i-1] = randomColor;
        }
      }
    }

    // Fill the map with color according to their label
    for (int i = 0; i < result.width*result.height; ++i) {
      if (labels[i] != 0) {
        result.pixels[i] = colorArray[labels[i]-1];
      }
    }

    return result;
  }    
}
