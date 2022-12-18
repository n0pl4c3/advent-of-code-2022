package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// Limit up to which to consider dirs for part 1
const limit = 100000

// Maximum Space of FS
const fs_size = 70000000

// Minimum Free space needed
const free_needed = 30000000

// Parsed Commands and Entries
type TtyIO int

const (
	cd TtyIO = iota
	ls
	directory
	file
	start_node
)

type Command struct {
	kind   TtyIO
	target string
	size   int
	next   *Command
}

// Basic Tree Structure
type Directory struct {
	name           string
	total_size     int
	parent         *Directory
	subdirectories []*Directory
	files          []*File
}

type File struct {
	name string
	size int
}

func main() {
	fmt.Println("--- Reading Input ---")
	input := readFile()
	fmt.Println("\nSUCCESS")

	fmt.Println("\n--- Parsing commands ---")
	commands := parseInput(input)

	printPlan(commands)

	fmt.Println("\n--- Generating File Tree ---")
	top_level := executePlan(commands)
	fmt.Println("\nSUCCESS")

	fmt.Println("\n--- FS without sizes  ---")
	printFs(top_level, "")

	fmt.Println("\n--- Populating Directory Sizes  ---")
	populateSize(top_level)
	fmt.Println("\nSUCCESS")

	fmt.Println("\n--- FS with Directory Sizes ---")
	printFs(top_level, "")

	fmt.Println("\n--- Calculating Solution for Part 1 ---")
	solution := solution1(top_level)
	fmt.Println("Solution 1: " + strconv.Itoa(solution))

	fmt.Println("\n--- Calculating Solution for Part 2 ---")
	solution = solution2(top_level, top_level.total_size, top_level.total_size)
	fmt.Println("Solution 2: " + strconv.Itoa(solution))
}

// Find size of smallest directory that if deleted gets the enough space freed up
func solution2(level *Directory, best int, total int) int {

	if ((fs_size - total) + level.total_size) >= free_needed {
		new_best := best

		if level.total_size < best {
			new_best = level.total_size
		}

		for _, directory := range level.subdirectories {
			new_best = solution2(directory, new_best, total)
		}

		return new_best
	} else {
		return best
	}
}

// Returns sum of directory sizes <= limit
func solution1(level *Directory) int {
	accumulator := 0

	if level.total_size <= limit {
		accumulator += level.total_size
	}

	for _, directory := range level.subdirectories {
		accumulator += solution1(directory)
	}

	return accumulator
}

// Populates the size of all directories
func populateSize(level *Directory) int {
	for _, file := range level.files {
		level.total_size += file.size
	}

	for _, directory := range level.subdirectories {
		level.total_size += populateSize(directory)
	}

	return level.total_size
}

// Visualizes the generated directory structure
func printFs(level *Directory, prefix string) {
	fmt.Println(prefix + "- " + level.name + " (dir) size=" + strconv.Itoa(level.total_size))

	prefix += "\t"

	for _, file := range level.files {
		fmt.Println(prefix + "- " + file.name + " (file, size=" + strconv.Itoa(file.size) + ")")
	}

	for _, directory := range level.subdirectories {
		printFs(directory, prefix)
	}
}

// Creates directory tree based on game plan
func executePlan(command *Command) *Directory {

	// First Command is always the placeholder start
	if command.kind != start_node {
		panic("Malformed Command Plan")
	}

	command = command.next

	// First real cmd is cd /
	if command.kind != cd || command.target != "/" {
		panic("Malformed Command Plan, first cmd != cd /")
	}

	top_level := &Directory{
		name:           command.target,
		total_size:     0,
		parent:         nil,
		subdirectories: make([]*Directory, 0),
		files:          make([]*File, 0),
	}

	current_directory := top_level

	command = command.next

	for command != nil {
		current_directory = evaluateCommand(current_directory, command)
		command = command.next
	}

	return top_level
}

// Evaluate a single command on the current directory structure
func evaluateCommand(current_directory *Directory, command *Command) *Directory {
	switch command.kind {
	case start_node:
		panic("Found second start node")
	case ls:
		// Nothing to be done for ls
		return current_directory
	case cd:
		if command.target == ".." {
			if current_directory.parent != nil {
				return current_directory.parent
			} else {
				panic("Tried to move up to non-existent dir")
			}
		} else {
			next_dir := directory_exist(current_directory, command.target)

			if next_dir == nil {
				next_dir = &Directory{
					name:           command.target,
					total_size:     0,
					parent:         current_directory,
					subdirectories: make([]*Directory, 0),
					files:          make([]*File, 0),
				}

				current_directory.subdirectories = append(current_directory.subdirectories, next_dir)
			}

			return next_dir
		}
	case directory:
		next_dir := directory_exist(current_directory, command.target)

		if next_dir == nil {
			next_dir = &Directory{
				name:           command.target,
				total_size:     0,
				parent:         current_directory,
				subdirectories: make([]*Directory, 0),
				files:          make([]*File, 0),
			}

			current_directory.subdirectories = append(current_directory.subdirectories, next_dir)
		}

		return current_directory
	case file:
		if !file_exist(current_directory, command.target) {
			file := &File{
				name: command.target,
				size: command.size,
			}

			current_directory.files = append(current_directory.files, file)
			return current_directory
		}

		return current_directory
	default:
		panic("Invalid Command")
	}
}

// Check if a directory has a given subdirectory
func directory_exist(location *Directory, name string) *Directory {
	for _, dir := range location.subdirectories {
		if dir.name == name {
			return dir
		}
	}

	return nil
}

// check if a dir has a given file
func file_exist(location *Directory, name string) bool {
	for _, file := range location.files {
		if file.name == name {
			return true
		}
	}

	return false
}

// Parses the commands and outputs given in input
func parseInput(input []string) *Command {

	var start *Command = &Command{
		kind:   start_node,
		target: "",
		size:   0,
		next:   nil,
	}

	var fs_ptr *Command = start

	for _, line := range input {
		tokens := strings.Split(line, " ")
		var next *Command = nil

		if tokens[0] == "$" {
			if tokens[1] == "cd" {
				next = &Command{
					kind:   cd,
					target: tokens[2],
					size:   0,
					next:   nil,
				}
			} else { // ls
				next = &Command{
					kind:   ls,
					target: "",
					size:   0,
					next:   nil,
				}
			}
		} else if tokens[0] == "dir" {
			next = &Command{
				kind:   directory,
				target: tokens[1],
				size:   0,
				next:   nil,
			}
		} else {
			size, err := strconv.Atoi(tokens[0])
			check(err)

			next = &Command{
				kind:   file,
				target: tokens[1],
				size:   size,
				next:   nil,
			}
		}

		fs_ptr.next = next
		fs_ptr = fs_ptr.next
	}
	return start
}

// Prints the current plan of commands to execute
// Including finds that will be found along the way
func printPlan(start *Command) {
	fmt.Println("\nPrinting Game Plan:")

	for start != nil {
		switch start.kind {
		case start_node:
			fmt.Println("== START ==")
		case ls:
			fmt.Println("> ls")
		case cd:
			fmt.Println("> cd " + start.target)
		case directory:
			fmt.Println("dir " + start.target)
		case file:
			fmt.Println("" + start.target +
				" [" + strconv.Itoa(start.size) + "]")
		default:
			panic("Ah yes")
		}

		start = start.next
	}

	fmt.Println("== DONE ==\n")
}

// Reads the puzzle input line by line
func readFile() []string {
	var input []string

	file, err := os.Open("input.txt")
	check(err)

	scanner := bufio.NewScanner(file)

	scanner.Split(bufio.ScanLines)

	for scanner.Scan() {
		input = append(input, scanner.Text())
	}

	file.Close()

	return input
}

// Given this is an AoC challenge,
// there really isn't much use in more error handling
func check(e error) {
	if e != nil {
		panic(e)
	}
}
