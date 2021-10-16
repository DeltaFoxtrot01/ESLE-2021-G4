mod parser;
use parser::*;

use std::{
    fs::File,
    io::{stdout, Write},
};

use cassandra_cpp::*;

use structopt::StructOpt;

use tracing::*;

const DEF_KEYSPACE: &str = "destroyer";
const DEF_STRATEGY: &str = "SimpleStrategy";
const DEF_REPLICATION: &str = "3";

// Set the number of characters that make a table column
const TAB_SIZE: usize = 25;

const BASE_10: usize = 10;

#[derive(Debug, StructOpt)]
/// Benchmark utility for Apache Cassandra
struct Cli {
    /// Whether to use default init or not
    ///
    /// If set, deletes keyspace `destroyer` and recreates it
    /// along with 3 tables: items, owns, buyers
    #[structopt(short, long)]
    init: bool,

    /// File to run against cassandra
    #[structopt(short, long)]
    file: Option<String>,

    /// File to store the statistics of the test (defaults to `stdout`)
    #[structopt(short, long)]
    output: Option<String>,

    /// The address of the Cassandra database
    address: String,
}

#[instrument]
async fn init(session: &Session) {
    // Clear keyspace
    let query = stmt!(&format!("DROP KEYSPACE {};", DEF_KEYSPACE));

    match session.execute(&query).await {
        Ok(_) => debug!("Keyspace dropped"),
        Err(e) => warn!("Keyspace didn't exist: {}", e),
    }

    // Create new keyspace
    let query = stmt!(&format!(
        "CREATE KEYSPACE {} WITH replication = {{'class': '{}', 'replication_factor': {}}};",
        DEF_KEYSPACE, DEF_STRATEGY, DEF_REPLICATION
    ));
    match session.execute(&query).await {
        Ok(_) => debug!("Keyspace {} created", DEF_KEYSPACE),
        Err(e) => warn!("Couldn't create keyspace: {}", e),
    }

    let query = stmt!(&format!("USE {};", DEF_KEYSPACE));
    match session.execute(&query).await {
        Ok(_) => debug!("Keyspace {} selected", DEF_KEYSPACE),
        Err(e) => warn!("Couldn't select keyspace: {}", e),
    }

    // Create new tables
    let query = stmt!("CREATE TABLE items (name TEXT, price FLOAT, PRIMARY KEY((name)));");
    match session.execute(&query).await {
        Ok(_) => debug!("Table created"),
        Err(e) => warn!("Couldn't create table: {}", e),
    }

    let query = stmt!("CREATE TABLE buyers (name TEXT, age INT, PRIMARY KEY((name)));");
    match session.execute(&query).await {
        Ok(_) => debug!("Table created"),
        Err(e) => warn!("Couldn't create table: {}", e),
    }

    let query = stmt!(
        "CREATE TABLE owns (buyer TEXT, product TEXT, amount INT, PRIMARY KEY((buyer, product)));"
    );
    match session.execute(&query).await {
        Ok(_) => debug!("Table created"),
        Err(e) => warn!("Couldn't create table: {}", e),
    }
}

#[tokio::main]
async fn main() {
    // Define logging
    set_logger(None);
    tracing_subscriber::fmt::init();

    let args = Cli::from_args();

    // Connect to cluster
    let mut cluster = Cluster::default();
    cluster.set_contact_points(&args.address).unwrap();

    match cluster.connect_async().await {
        Ok(ref mut session) => {
            // Custom init
            if args.init {
                init(&session).await;
            }

            // Check if using stdin or given file
            if let Some(file) = args.file {
                let results = parse_file(file, &session).await;

                let mut output = if let Some(file) = args.output {
                    match File::create(&file) {
                        Ok(file) => Box::new(file) as Box<dyn Write>,
                        Err(e) => {
                            error!("Couldn't create file '{}', using stdout: {}", file, e);
                            Box::new(stdout()) as Box<dyn Write>
                        }
                    }
                } else {
                    Box::new(stdout())
                };

                // Get time
                let nanos = results.time.num_nanoseconds().unwrap();
                let seconds = nanos as usize / BASE_10.pow(9);
                let nanos = nanos as usize % BASE_10.pow(9);

                let time = format!("{}.{:09}", seconds, nanos).parse::<f64>().unwrap();

                // Pretty print
                output
                    .write_fmt(format_args!(
                        "
Destroyer Stats:
----------------
{:width$} {:>4}
{:width$} {:>4}
{:width$} {:>4}
{:width$} {:>4.9}
{:width$} {:>4.9}
",
                        "Suceeded:",
                        results.suceeded,
                        "Failed:",
                        results.failed,
                        "Total Requests:",
                        results.suceeded + results.failed,
                        "Total Time (s):",
                        time,
                        "Troughput (req/s):",
                        (results.suceeded + results.failed) as f64 / (time),
                        width = TAB_SIZE,
                    ))
                    .expect("Couldn't write stats")
            } else {
                shell(&session).await;
            }
        }
        Err(e) => error!("{:?}", e),
    }
}
