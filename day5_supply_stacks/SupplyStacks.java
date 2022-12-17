import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Collections;
import java.util.ArrayList;

class SupplyStacks {

    // Current state of stacks
    private ArrayList<ArrayList<Character>> state;

    // Saving initial state for part 2
    private ArrayList<ArrayList<Character>> stateBackup;

    // Encoding of permutations to be performed
    private ArrayList<int[]> permutations;

    /** 
    * Initializes state and permutations of SupplyStack
    * @param stateStr List defining the initial state, each stack given as a string of characters ('?' for empty fields)
    * @param permutations List of Arrays defining permutations as [number, from, to] each, indexed from 1
    */
    public SupplyStacks(ArrayList<String> stateStr, ArrayList<int[]> permutations) {
	state = new ArrayList<>();
        Collections.reverse(stateStr);

	// Numbering is unneeded information
	stateStr.remove(0);
	
	for (String line : stateStr) {
            for (int i = 0; i < line.length(); i++) {

		// Initialize Lists
		if (state.size() < i + 1) {
		    state.add(new ArrayList<Character>());
		}

		if (line.charAt(i) != '?') {
		    state.get(i).add(line.charAt(i));
		}
	    }
	}

	this.permutations = permutations;

	this.stateBackup = new ArrayList<>();
	
	// Deep Copy State
	for (ArrayList<Character> entry : state) {
	    this.stateBackup.add(new ArrayList<>(entry));
	}
    }

    /** 
    * Resets the state to the initial state, creating a deep-copy
    */
    public void resetState() {
	this.state.clear();
	
	// Deep Copy State
	for (ArrayList<Character> entry : stateBackup) {
	    this.state.add(new ArrayList<>(entry));
	}
    }

    /**
     * Print the current state for debugging
     */
    public void printDebug() {
	for (ArrayList<Character> stack : state) {
	    System.out.println(stack);
	}
    }

    /**
     * Performs the parsed permutations on the state, one element at a time
     */
    public void performPermutations() {
	System.out.println("Initial State");
	this.printDebug();

	for(int[] permutation : permutations) {
	    System.out.println("Moving " + permutation[0] + " elements from "
			       + permutation[1] + " to " + permutation[2]);

	    for (int i = 0; i < permutation[0]; i++) {
		Character item = state.get(permutation[1] - 1).remove(state.get(permutation[1] - 1).size() - 1);
		state.get(permutation[2] - 1).add(item);
	    }

	    this.printDebug();
	}
    }

    /**
    * Performs the parsed permutations on the state, moving all elements of a permutation at once
    */
    public void performPermutationsWithOrder() {
	System.out.println("Initial State");
	this.printDebug();

	for(int[] permutation : permutations) {
	    System.out.println("Moving " + permutation[0] + " elements from "
			       + permutation[1] + " to " + permutation[2]);
	    
	   //Character item = state.get(permutation[1] - 1).remove(state.get(permutation[1] - 1).size() - 1);
	    state.get(permutation[2] - 1).addAll(state.get(permutation[1] - 1)
						 .subList(state.get(permutation[1] - 1).size() - permutation[0],
							  state.get(permutation[1] - 1).size()));
	    state.get(permutation[1] - 1).subList(state.get(permutation[1] - 1).size() - permutation[0],
						  state.get(permutation[1] - 1).size()).clear();
	    this.printDebug();
	}
    }

    public String getSolution() {
	String solution = "";
	for (ArrayList<Character> stack : state) {
	    solution += stack.get(stack.size()-1);
	}
        return solution;
    }

    public static SupplyStacks initialize() {
	ArrayList<String> stacks = new ArrayList<String>();
        ArrayList<int[]> permutations = new ArrayList<>();
	
        String filename = "./input.txt";
        try {
	    BufferedReader reader = new BufferedReader(new FileReader(filename));
	    String line = reader.readLine();

      	    while (line != null && line.length() != 0) {
		stacks.add(line.replaceAll("    ", "[?]").replaceAll("[\\s+\\[\\]]",""));
		line = reader.readLine();
	    }

	    line = reader.readLine();
	    
	    while (line != null) {
	        String tokens[] =  line.replaceAll("(move|from|to)", "").split("  ");
		int permutation[] = {Integer.parseInt(tokens[0].replaceAll("[\\s+\\[\\]]","")),
				      Integer.parseInt(tokens[1].replaceAll("[\\s+\\[\\]]","")),
		                      Integer.parseInt(tokens[2].replaceAll("[\\s+\\[\\]]",""))};
		permutations.add(permutation);
		line = reader.readLine();
	    }

            reader.close();
	} catch (IOException e) {
	    e.printStackTrace();
	}

	System.out.println(stacks);

	return new SupplyStacks(stacks, permutations);
    }
    
    public static void main(String[] args) {
        SupplyStacks stack = SupplyStacks.initialize();
	stack.printDebug();
	stack.performPermutations();

	String solution = stack.getSolution();
	System.out.println("Solution Part 1: " + solution);

	stack.resetState();
	stack.printDebug();

	stack.performPermutationsWithOrder();

	solution = stack.getSolution();
	System.out.println("Solution Part 2: " + solution);
    }
}
