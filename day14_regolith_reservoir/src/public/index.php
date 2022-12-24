 <!DOCTYPE html>
 <html>

 <head>
     <title>Day 14 - Regolith Reservoir</title>
 </head>

 <body>

     <?php
        $input_lines = read_input();
        $paths = parse_input($input_lines);
        $field_initial = generate_field($paths);
        $field = simulate($field_initial);
        $count = count_grains($field);
        echo "<h4> Solution 1: {$count} </h4>";

        $field = setUpPart2($field_initial);
        $field = simulate2($field);
        $count = count_grains($field);
        echo "<h4> Solution 2: {$count} </h4>";
        ?>

 </body>

 </html>

 <?php
    function read_input()
    {
        $input_lines = array();

        $handle = fopen("input.txt", "r");
        if ($handle) {
            while (($line = fgets($handle)) !== false) {
                $line = substr($line, 0, -1);
                array_push($input_lines, $line);
            }

            fclose($handle);
        }

        log_to_console($input_lines);
        return $input_lines;
    }

    function setUpPart2($state)
    {
        $field = $state[0];
        $start = $state[1];

        // Add a floor on bottom
        $y = count($field);

        for ($i = 0; $i < count($field[0]); $i++) {
            $field[$y][$i] = '#';
        }
        
        print_field($field, "Initial Field - Part 2");

        $new_state = $state;
        $new_state[0] = $field;
        
        return $new_state;
    }

    function simulate($state)
    {
        $field = $state[0];
        $start = $state[1];

        $field_new = array(true, true);

        while ($field_new[1]) {
            $field_new = simulateGrain($field, $start);
            if ($field_new[1]) {
                $field = $field_new[0];
            }
        }


        print_field($field, "Simulated: ");
        return $field;
    }

    function simulate2($state)
    {
        $field = $state[0];
        $start = $state[1];

        $field_new = array(true, true);



        while ($field_new[1]) {
            $field_new = simulateGrain2($field, $start);
            $field = $field_new[0];
        }


        print_field($field, "Simulated Part 2: ");
        return $field;
    }

    function count_grains($field)
    {
        $count = 0;
        foreach ($field as $lines) {
            foreach ($lines as $entry) {
                if ($entry == 'o') {
                    $count++;
                }
            }
        }

        return $count;
    }

    function simulateGrain($field, $start)
    {
        $finished = false;

        $current_position = $start;

        while (!$finished) {
            if (!array_key_exists($current_position[0] + 1, $field)) {
                return array($field, false); // No further moves possible
            }

            if ($field[$current_position[0] + 1][$current_position[1]] == '.') {
                $current_position[0]++;
            } else if ($field[$current_position[0] + 1][$current_position[1] - 1] == '.') {
                $current_position[0]++;
                $current_position[1]--;
            } else if (!array_key_exists($current_position[1] + 1, $field[$current_position[0] + 1])) {
                return array($field, false);
            } else if ($field[$current_position[0] + 1][$current_position[1] + 1] == '.') {
                $current_position[0]++;
                $current_position[1]++;
            } else {
                $finished = true;
            }
        }

        $field[$current_position[0]][$current_position[1]] = 'o';
        return array($field, true);
    }

    function simulateGrain2($field, $start)
    {
        $finished = false;

        $current_position = $start;

        while (!$finished) {
            if (!array_key_exists($current_position[0] + 1, $field)) {
                echo "ERROR";
            }

            if ($field[$current_position[0] + 1][$current_position[1]] == '.') {
                $current_position[0]++;
            } else if ($field[$current_position[0] + 1][$current_position[1] - 1] == '.') {
                $current_position[0]++;
                $current_position[1]--;
            } else if (!array_key_exists($current_position[1] + 1, $field[$current_position[0] + 1])) {
                echo "ERROR";
            } else if ($field[$current_position[0] + 1][$current_position[1] + 1] == '.') {
                $current_position[0]++;
                $current_position[1]++;
            } else if ($current_position[0] == $start[0] && $current_position[1] == $start[1]) {
                $field[$start[0]][$start[1]] = 'o';
                return array($field, false); // No further moves possible
            } else {
                $finished = true;
            }
        }

        $field[$current_position[0]][$current_position[1]] = 'o';
        return array($field, true);
    }

    function generate_field($paths)
    {
        // Extend all dimensions by one for nicer visualization
        $max_y = get_max_y($paths) + 1;
        $min_max_x = get_min_max_x($paths);

        // Just lackluster calculations, but these don't have to match up
        // Drawing the field slightly bigger is fine as long as the relations are correct
        $offset = $min_max_x[0] - 250;
        $min_x = 0;
        $max_x = $min_max_x[1] - $offset;

        $field = array();

        for ($y = 0; $y <= $max_y; $y++) {
            array_push($field, array());
            for ($x = 0; $x <= $max_x + 250; $x++) {
                array_push($field[count($field) - 1], '.');
            }
        }

        // Place Faucet
        $field[0][500 - $offset] = '+';

        foreach ($paths as $path) {
            $field = insert_path($field, $offset, $path);
        }

        log_to_console($field);
        print_field($field, "Initial Field");

        // Also return start point to avoid unnecessary searching
        return array($field, array(0, 500 - $offset, $offset));
    }

    function insert_path($field, $offset, $path)
    {
        $last_x = -1;
        $last_y = -1;

        foreach ($path as $vertex) {
            $field[$vertex[1]][$vertex[0] - $offset] = '#';

            if ($last_x != $vertex[0] && $last_x != -1) {
                foreach (range($last_x, $vertex[0]) as $number) {
                    $field[$vertex[1]][$number - $offset] = '#';
                }
            } elseif ($last_y != $vertex[1] && $last_y != -1) {
                foreach (range($last_y, $vertex[1]) as $number) {
                    $field[$number][$vertex[0] - $offset] = '#';
                }
            }


            $last_x = $vertex[0];
            $last_y = $vertex[1];
        }

        return $field;
    }

    function get_max_y($paths)
    {
        $max = 0;

        foreach ($paths as $path) {
            foreach ($path as $vertex) {
                if ($vertex[1] > $max) {
                    $max = $vertex[1];
                }
            }
        }

        return $max;
    }

    function print_field($field, $heading)
    {
        echo "<h4>{$heading}</h4>";

        $y = 0;

        foreach ($field as $lines) {
            echo "<p style=\"font-family: monospace; font-size:25px;\">";
            foreach ($lines as $entry) {
                echo "{$entry}&nbsp&nbsp&nbsp&nbsp";
            }
            echo "&nbsp&nbsp{$y}\t";
            echo "</p>";
            $y++;
        }
    }

    function get_min_max_x($paths)
    {
        $max = 500;
        $min = 500;

        foreach ($paths as $path) {
            foreach ($path as $vertex) {
                if ($vertex[0] > $max) {
                    $max = $vertex[0];
                } elseif ($vertex[0] < $min) {
                    $min = $vertex[0];
                }
            }
        }

        return array($min, $max);
    }

    function parse_input($input_lines)
    {
        $paths = array();

        foreach ($input_lines as $value) {
            $parsed = parse_path($value);
            array_push($paths, $parsed);
        }

        return $paths;
    }

    function parse_path($line)
    {
        $pattern = "/[0-9]+,[0-9]+/";

        $tokens = array();
        preg_match_all($pattern, $line, $tokens);

        $path = $tokens[0];
        $path_parsed = array();

        foreach ($path as $point) {
            $coords = explode(",", $point);
            array_push($path_parsed, array(intval($coords[0]), intval($coords[1])));
        }

        return $path_parsed;
    }

    function log_to_console($data)
    {
        $output = json_encode($data);
        echo "<script>console.log('{$output}');</script>\n";
    }
