use std::env;
use std::path::PathBuf;

mod cmdline;
mod common;
mod container;
#[macro_use]
mod core;
mod nmk;
mod nmkup;
mod pathenv;
mod terminal;
mod tmux;
mod zsh;

fn main() {
    let arg0 = env::args().next().map(PathBuf::from);
    let name = arg0.as_ref()
        .and_then(|a| a.file_stem())
        .and_then(std::ffi::OsStr::to_str);
    match name {
        Some("nmk") => nmk::main(),
        Some("nmkup") => {
            if let Err(e) = nmkup::main() {
                eprintln!("{:?}", e);
                std::process::exit(-1);
            }
        }
        Some(name) => panic!("Not support command name: {}", name),
        None => unimplemented!()
    }
}
