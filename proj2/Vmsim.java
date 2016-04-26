

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Hashtable;


public class Vmsim {
	static Frame[] frames;
	static int address;
	static boolean write = false;
	static boolean pageFault = true;
	static int emptyFrame;
	static int currFrameNum = 0;
	static int references = 0;
	static int writesToDisk = 0;
	static int numPageFaults = 0;
	static int memoryAcceses = 0;
	static int refresh = 32;
	static String fileName = "gcc.trace";
	static Hashtable<Integer, ArrayList<Integer>> nextOccHash;
	static int framePointer;
	
	public static void main(String[] args) throws IOException {
		
		framePointer = 0;
		String alg = "nru";
	//	frames = new Frame[];
	//	frames = new Frame[Integer.parseInt(args[1])];
		if(args[3].equals("nru"))
	      {
			frames = new Frame[Integer.parseInt(args[1])];
			 alg = "nru";
	         refresh = Integer.parseInt(args[5]);
	         fileName = args[6];
	      }
		if(args[3].equals("aging"))
	      {
			frames = new Frame[Integer.parseInt(args[1])];
			 alg = "aging";
			 refresh = frames.length;
	         if(args[4].equals("-r")){
	        	 refresh = Integer.parseInt(args[5]);
	        	 fileName = args[6];
	         }
	         else{
	        	 fileName = args[4];
	         }
	      }
		if(args[3].equals("opt"))
	      {
			frames = new Frame[Integer.parseInt(args[1])];
			 alg = "opt";
	         fileName = args[4];
	      }
		if(args[3].equals("clock"))
	      {
			frames = new Frame[Integer.parseInt(args[1])];
			 alg = "clock";
	         fileName = args[4];
	      }
	      
		
		String line = "";
		String[] lineParts;
		
		
        FileReader fr = new FileReader(fileName);
        BufferedReader br = new BufferedReader(fr);
        
        if(alg.equals("opt")){
        	optPreprocess();
        	//br = new BufferedReader(fr);
        }
        
        while((line = br.readLine()) != null) {
        	emptyFrame = -1;
        	pageFault = true;
        	write = false;
            lineParts = line.split(" ");
         //   address = Integer.parseInt(lineParts[0], 16);
            address = Integer.parseUnsignedInt(lineParts[0], 16);
            address = address >> 12;
            
            if(lineParts[1].charAt(0) == 'W'){
            	write = true;
            }
            
            
            
            //search through frames
            for(int i = 0; i < frames.length; i++){
            	if(frames[i] == null){
            		if(emptyFrame == -1){
            			emptyFrame = i;
            		}
            		continue;
            	}
            	else if(frames[i].pageNum == address){
            	//	frames[i].ref = true;
            		pageFault = false;
            		System.out.println("hit");
            		currFrameNum = i;
            		break;
            	}
            }
         if(alg.equals("nru")) {
            nruAlg();
         }
         else if(alg.equals("aging")) {
             agingAlg();
          }
         else if(alg.equals("opt")) {
             optAlg();
          }
         else if(alg.equals("clock")) {
             clockAlg();
          }
         
         frames[currFrameNum].ref = true;
 	    if(write == true){
 	    	frames[currFrameNum].dirty = true;
 	    }      
            memoryAcceses++;
            
         //  System.out.println(address );
         //   break;
        }
        
        br.close();
        
        //make algorithm capital letter
        char original = alg.charAt(0);
        char replace = Character.toUpperCase(original);
        String newAlg = Character.toString(replace);
        alg = alg.substring(1);
        newAlg = newAlg.concat(alg);
        System.out.println( newAlg 
        		+ "\nNumber of frames: " + frames.length
        		+ "\nTotal Memory Acceses: " + memoryAcceses
        		+ "\nTotal page faults: " + numPageFaults 
        	    + "\nWrites to disk: " + writesToDisk
        		 );

	}
	
	public static void clockAlg(){
		
		if(pageFault == true && emptyFrame == -1){
			while(true){
				if(frames[framePointer % (frames.length)].ref == true){
					frames[framePointer % (frames.length)].ref = false;
					framePointer++;
				}
				else{
					//frames[framePointer % (frames.length)].pageNum = address;
					currFrameNum = framePointer % (frames.length);
					framePointer++;
					
					break;
				}
			}
			//place page in selected frame
			numPageFaults++;
			if(frames[currFrameNum].dirty == true){
	    		writesToDisk++;
	    		System.out.println("page fault - evict dirty");
	    	}
			else{
				System.out.println("page fault - evict clean");
			}
	    	frames[currFrameNum].pageNum = address;
	    	frames[currFrameNum].dirty = false;
		}
		else if(pageFault == true){
	    	numPageFaults++;
	    	frames[emptyFrame] = new Frame(address);
	    	System.out.println("page fault - no eviction");
		}
	}
	
	public static void optAlg(){
		ArrayList<Integer> currList;
		int farthestFrame = -1;
		//loop through frames to see which is used farthest in the future
		if(pageFault == true && emptyFrame == -1){
			for(int i = 0; i < frames.length; i++){
				//check each frame's hash arraylist of line numbers where it is used 
				currList = nextOccHash.get(frames[i].pageNum);
				if(currList.size() != 0 && currList != null){
					//delete any we passed already
					for(int j = 0; j < currList.size(); j++){
						if(currList.get(0) < memoryAcceses + 1){
							currList.remove(0);
						}
						else{
							break;
						}
					}
					//store the num of the farthest
					if(farthestFrame == -1){
						if(currList.size() != 0){
							farthestFrame = currList.get(0);
							currFrameNum = i;
						}
					}
					else{
						if(currList.size() != 0){
							if(currList.get(0) > farthestFrame){
								farthestFrame = currList.get(0);
								currFrameNum = i;
							}
						}
					}
				}
				else{
					//current List is null so never used again so use this
					currFrameNum = i;
					break;
				}
			}
			//place page in selected frame
			numPageFaults++;
			if(frames[currFrameNum].dirty == true){
	    		writesToDisk++;
	    		System.out.println("page fault - evict dirty");
	    	}
			else{
				System.out.println("page fault - evict clean");
			}
	    	frames[currFrameNum].pageNum = address;
	    	frames[currFrameNum].dirty = false;
		}
		else if(pageFault == true){
	    	numPageFaults++;
	    	frames[emptyFrame] = new Frame(address);
	    	System.out.println("page fault - no eviction");
	    }
		
		
	}
	
	public static void optPreprocess() throws IOException{
		FileReader fr = new FileReader(fileName);
        BufferedReader br = new BufferedReader(fr);
		nextOccHash = new Hashtable<Integer, ArrayList<Integer>>();
		ArrayList<Integer> curr;
		int lineNum = 0;
		String line = "";
		String[] lineParts;
		 while((line = br.readLine()) != null) {
			   lineNum++;
			   lineParts = line.split(" ");
	         //   address = Integer.parseInt(lineParts[0], 16);
	            address = Integer.parseUnsignedInt(lineParts[0], 16);
	            address = address >> 12;
            
                if(nextOccHash.get(address) != null){
                	curr = nextOccHash.get(address);
                	curr.add(lineNum);
                }
                else{
                	curr = new ArrayList<Integer>();
                	curr.add(lineNum);
                	nextOccHash.put(address, curr);
                }
		 }
	}
	
	public static void agingAlg(){
	//	boolean foundGood = false;
		int lowest = -1;
	    //if page fault and no empty frame
	    if(pageFault == true && emptyFrame == -1){
	    	numPageFaults++;
	    	for(int i = 0; i < frames.length; i++){
	    		if(frames[i].ref == false){
	    			if(lowest == -1){
	    				lowest = (int)frames[i].age;
	    				currFrameNum = i;
	    				
	    			}
	    			else if((int)frames[i].age < lowest){
	    				lowest = (int)frames[i].age;
	    				currFrameNum = i;
	    			}
	    		}
	    	}
	    	//if all are referenced then choose last referenced before this one
	    	if(lowest == -1 ){
	    		for(int i = 0; i < frames.length; i++){
	    			if(lowest == -1){
	    				lowest = (int)frames[i].age;
	    				currFrameNum = i;
	    				
	    			}
	    			else if((int)frames[i].age < lowest){
	    				lowest = (int)frames[i].age;
	    				currFrameNum = i;
	    			}
		    	}
	    	}
	    	if(frames[currFrameNum].dirty == true){
	    		writesToDisk++;
	    		System.out.println("page fault - evict dirty");
	    	}
			else{
				System.out.println("page fault - evict clean");
			}
	    	frames[currFrameNum].pageNum = address;
	    	frames[currFrameNum].dirty = false;
	    	//frames[currFrameNum].ref = true;
	    }
		else if(pageFault == true){
	    	numPageFaults++;
	    	frames[emptyFrame] = new Frame(address);
	    	System.out.println("page fault - no eviction");
	    	//frames[currFrameNum].ref = true;
	    	
	    }
		
		references++;
		if(references == refresh){
			//System.out.println(address );
			references = 0;
			for(int i = 0; i < frames.length; i++){
				if(frames[i] != null){
					frames[i].age = (frames[i].age >> 1);
					if(frames[i].ref == true){
						frames[i].age = (frames[i].age | 128);
					}
					frames[i].ref = false;
				}
			}
		}
	}
	
	public static void nruAlg(){
		
		boolean foundEmpty = false;
	    //if page fault and no empty frame
	    if(pageFault == true && emptyFrame == -1){
	    	numPageFaults++;
	    	for(int i = 0; i < frames.length; i++){
	    		if(frames[i].ref == false && frames[i].dirty == false){
	    			currFrameNum = i;
	    			foundEmpty = true;
	    			break;
	    		}
	    	}
	    	if(!foundEmpty){
	        	for(int i = 0; i < frames.length; i++){
	        		if(frames[i].ref == false && frames[i].dirty == true){
	        			//writesToDisk++;
	        			currFrameNum = i;
	        			foundEmpty = true;
	        			break;
	        		}
	        	}
	    	}
	    	if(!foundEmpty){
	        	for(int i = 0; i < frames.length; i++){
	        		if(frames[i].ref == true && frames[i].dirty == false){
	        			currFrameNum = i;
	        			foundEmpty = true;
	        			break;
	        		}
	        	}
	    	}
	    	if(!foundEmpty){
	        	for(int i = 0; i < frames.length; i++){
	        		if(frames[i].ref == true && frames[i].dirty == true){
	        			//writesToDisk++;
	        			currFrameNum = i;
	        			foundEmpty = true;
	        			break;
	        		}
	        	}
	    	}
	    	if(frames[currFrameNum].dirty == true){
	    		writesToDisk++;
	    		System.out.println("page fault - evict dirty");
	    	}
			else{
				System.out.println("page fault - evict clean");
			}
	    	frames[currFrameNum].pageNum = address;
	    	frames[currFrameNum].dirty = false;
	    }
	    //if page fault and there is empty frame put address in it
	    else if(pageFault == true){
	    	numPageFaults++;
	    	frames[emptyFrame] = new Frame(address);
	    	System.out.println("page fault - no eviction");
	    }
	    
	    
	    
	    references++;
		if(references == refresh){
			//System.out.println(address );
			references = 0;
			for(int i = 0; i < frames.length; i++){
				if(frames[i] != null){
					frames[i].ref = false;
				}
			}
		}
	}	
	
	private static class Frame{
		public int pageNum;
		public boolean ref;
		public boolean dirty;
		public int age;
		public Frame(int f){
			pageNum = f;
			ref = false;
			dirty = false;
			age = 0;
		}
	}
}