use std::fs::File;
use std::io::{prelude::BufRead, stdin, stdout, BufReader, Write};

use cassandra_cpp::{Session, Statement};

use chrono::{Duration, Utc};

use tracing::*;

#[derive(Debug)]
pub struct Stats {
    pub time: Duration,
    pub failed: usize,
    pub suceeded: usize,
}

#[instrument]
pub async fn parse_file(path: String, session: &Session) -> Stats {
    match File::open(&path) {
        Ok(file) => {
            debug!("File {} opened", path);
            let queries = BufReader::new(file)
                .lines()
                .filter_map(|l| match l {
                    Ok(l) => {
                        let trimmed = l.trim();
                        let mut chars = trimmed.chars();

                        // Skip single-line comments and empty lines
                        if trimmed.len() > 1
                            && chars.nth(0).unwrap() != '-'
                            && chars.nth(1).unwrap() != '-'
                        {
                            Some(trimmed.to_owned())
                        } else {
                            None
                        }
                    }
                    Err(e) => panic!("Error reading line: {}", e),
                })
                .collect::<Vec<String>>();

            let start_time = Utc::now();
            let mut success = 0;
            let mut fail = 0;

            info!("Destroying Cassandra...");

            for query in queries {
                debug!("Query: {}", query);
                match session.execute(&Statement::new(&query, 0)).await {
                    Ok(_) => {
                        success += 1;
                        debug!("Successful: {}", query);
                    }
                    Err(e) => {
                        fail += 1;
                        debug!("Failed: {}", query);
                        debug!("Reason: {}", e);
                    }
                };
            }

            let taken = Utc::now() - start_time;

            info!("Benchmark took {}", taken);

            return Stats {
                time: taken,
                failed: fail,
                suceeded: success,
            };
        }
        Err(e) => panic!("Couldn't open file '{}': {}", path, e),
    }
}

#[instrument]
pub async fn shell(session: &Session) {
    'repl: loop {
        let mut query = String::new();
        print!("DESTROYER: ");
        stdout().flush().unwrap();
        match stdin().read_line(&mut query) {
            Ok(_) => match &session.execute(&Statement::new(&query, 0)).await {
                Ok(msg) => println!("{}", msg),
                Err(e) => error!("{}", e),
            },
            Err(e) => {
                debug!("Received error reading from stdin: {}", e);
                break 'repl;
            }
        }
    }
}
