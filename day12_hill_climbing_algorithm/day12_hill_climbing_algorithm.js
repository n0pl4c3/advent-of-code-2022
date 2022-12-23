class Node {
    constructor(value, adjacencies, start, end) {
        this.value = value;
        this.adjacencies = adjacencies;
        this.start = start;
        this.end = end;
        this.visited = false;
    }
}

class Graph {
    constructor(input) {
        this.nodes = []

        for (var i = 0; i < input.length; i++) {
            for (var j = 0; j < input[i].length; j++) {
                var start_node = false;
                var end_node = false;
                
                if (input[i][j] == 'S') {
                    start_node = true;
                    input[i][j] = 'a';
                } else if (input[i][j] == 'E') {
                    end_node = true;
                    input[i][j] = 'z';
                }
                
                
                this.nodes.push(new Node(input[i][j],
                                         this.calculateAdjacencies(input, i, j, this.nodes.length),
                                         start_node, end_node));               
            }
        }
    }


    computeStep(node, path) {
        path.push(node);

        if (this.nodes[node].end) {
            console.log("Found Path");
            console.log(path);
            return [[-1], path];
        }

        var next  = []
        for (var i = 0; i < this.nodes[node].adjacencies.length; i++) {
            var adjacency = this.nodes[node].adjacencies[i];
            if (!this.nodes[adjacency].visited) {
                this.nodes[adjacency].visited = true;
                next.push(adjacency);
            }
        }

        return [next, path];
    }
    
    // I could have used a proper algo like A* or Dijkstra here,
    // bug part of the fun of AoC is coming up with shitty, but selfmade, ideas
    // Though it kinda resembles Dijkstra just in bad on second thought
    findPaths(node, path) {
        this.nodes[node].visited = true;
        path.push(node);
        
        var schedule = []
        for (var i = 0; i < this.nodes[node].adjacencies.length; i++) {
            var adjacency = this.nodes[node].adjacencies[i];
            this.nodes[adjacency].visited = true;
            schedule.push(this.computeStep(adjacency, path.slice(0)));
        }
        
        // What am I even doing here
        while (schedule.length != 0) {
            //console.log("Schedule: ");
            //console.log(schedule.slice(0));
            for (var i = 0; i < schedule.length; i++) {
                for (var steps = 0; steps < schedule[0][0].length; steps++) {
                    var result = this.computeStep(schedule[0][0][steps], schedule[0][1].slice());
                    //console.log("Visited " + schedule[0][0][steps] + " returned ");
                    //console.log(result);
                    //console.log("\n");
                    if (result[0].length != 0) {
                        if(result[0][0] == -1){
                            return (result[1].length - 1);
                        } else {
                            schedule.push(result);
                        }
                    }
                }
                schedule.shift();
            }
        }

        return -1;
    }

    computePath(node) {
        return this.findPaths(node, []);
    }
    
    computePathStart() {
        this.reset();
        return this.computePath(this.getStartNode(), []);
    }

    computeAllPaths() {
        var viable = [];
        for (var i = 0; i < this.nodes.length; i++) {
            if (this.nodes[i].value == 'a') {
                viable.push(i);
            }
        }
        
        var paths = [];

        for (var i = 0; i < viable.length; i++) {
            this.reset();
            const result = this.computePath(viable[i]);
            if (result != -1) {
                paths.push(result);
            }
        }

        return Math.min(...paths);
    }

    reset() {
        for (var i = 0; i < this.nodes.length; i++) {
            this.nodes[i].visited = false;
        }
    }

    // Find Start node
    getStartNode() {
        for (var i = 0; i < this.nodes.length; i++) {
            if (this.nodes[i].start) {
                return i;
            }
        }

        return -1;
    }

    // I hate myself sometimes, but at this point I just want to get it over with JS
    hackyCharCode(character) {
        if (character == 'S') {
            return 'a'.charCodeAt(0);
        } else if (character == 'E') {
            return 'z'.charCodeAt(0);
        } else {
            return character.charCodeAt(0);
        }
    }

    calculateAdjacencies(input, i, j, index) {
        var adjacencies = []
        var value = input[i][j].charCodeAt(0);

        if (i != 0 && (this.hackyCharCode(input[i - 1][j]) - 1) <= value) {
            adjacencies.push(index - input[i].length);
        }

        if (i != (input.length - 1) && (this.hackyCharCode(input[i + 1][j]) - 1) <= value) {
            adjacencies.push(index + input[i].length);
        }

        if (j != 0 && (this.hackyCharCode(input[i][j - 1]) - 1) <= value) {
            adjacencies.push(index - 1);
        }

        if (j != (input[i].length - 1) && (this.hackyCharCode(input[i][j + 1]) - 1) <= value) {
            adjacencies.push(index + 1);
        }

        return adjacencies;
    }
}


// Extract array of fields from input
function extractFields(input) {
    const input_tokens = input.split(/\r?\n/);

    var fields = []
    
    for (var i = 0; i < input_tokens.length; i++) {
        if(input_tokens[i] != "") {

            fields[i] = []
            
            for (var j = 0; j < input_tokens[i].length; j++) {
                fields[i][j] = input_tokens[i].charAt(j);
            }
        }
    }

    return fields;
}

// Parse Input File into Graph
function parseInput(input) {
    var fields = extractFields(input);
    console.log("Input as Array: ");
    console.log(fields);

    var graph = new Graph(fields);
    console.log(graph);
    console.log("Start Node: " + graph.getStartNode());

    var result1 = graph.computePathStart();
    console.log("Result Part 1: " + result1);
    console.log(graph.computeAllPaths());
}

// Start processing when file is loaded
function setUpInputFile(){
    let file = document.getElementById("readfile");
    file.addEventListener("change", function () {
        var reader = new FileReader();
        reader.onload = function (progressEvent) {
            parseInput(this.result);
        };
        reader.readAsText(this.files[0]);
    });
}


setUpInputFile();
