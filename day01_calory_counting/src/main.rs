use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn main() {
    //part_one();
    part_two();
}

fn part_one() {
    let lines = read_lines("./input.txt").expect("Unable to read file");

    let mut maximum: u64 = 0;
    let mut current_sum: u64 = 0;
    for line in lines {
        if let Ok(num) = line.unwrap().parse::<u64>() {
            current_sum += num;
        } else {
            if current_sum > maximum {
                maximum = current_sum;
            }
            current_sum = 0;
        }
    }

    println!("Part One Solution: {}", maximum);
}

fn part_two() {
    let lines = read_lines("./input.txt").expect("Unable to read file");

    let mut maximum: Vec<u64> = Vec::from([0, 0, 0]);
    let mut current_sum: u64 = 0;
    for line in lines {
        if let Ok(num) = line.unwrap().parse::<u64>() {
            //           println!("Add {}", num);
            current_sum += num;
        } else {
            if current_sum >= 60000 {
                println!("Next {}", current_sum);
            }
            for i in 0..maximum.len() {
                if maximum[i] < current_sum {
                    let temp = maximum[i];
                    maximum[i] = current_sum;
                    if i == 0 {
                        maximum[i + 2] = maximum[i + 1];
                        maximum[i + 1] = temp;
                    } else if i == 1 {
                        maximum[i + 1] = temp;
                    }
                    break;
                }
            }
            current_sum = 0;
        }
    }

    println!("Part Two Solution: {:?}", maximum);
    println!("{}", maximum.iter().sum::<u64>());
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
