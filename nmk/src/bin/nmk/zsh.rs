use std::os::unix::process::CommandExt;
use std::path::Path;
use std::process::Command;
use std::time::Instant;

use nmk::bin_name::ZSH;
use nmk::platform::{is_alpine, is_arch, is_mac};

use crate::cmdline::Opt;
use crate::core::*;
use crate::utils::print_usage_time;

fn has_vendored_zsh(nmk_home: &Path) -> bool {
    nmk_home.join("vendor").join("bin").join(ZSH).exists()
}

pub fn use_global_rcs(_arg: &Opt, nmk_home: &Path) -> bool {
    // Disable global resource files on some platform
    //   - Some linux distributions force sourcing /etc/profile, they do reset PATH set by nmk.
    //   - MacOs doesn't respect PATH set by nmk, it change the order.
    let not_friendly_global_rcs = is_mac() || is_alpine() || is_arch();
    let no_global_rcs = not_friendly_global_rcs && !has_vendored_zsh(nmk_home);
    !no_global_rcs
}

pub fn setup(arg: &Opt, nmk_home: &Path) {
    let global_rcs = use_global_rcs(arg, nmk_home);
    if !global_rcs {
        log::debug!("ignore zsh global rcs");
    }
    set_env("NMK_ZSH_GLOBAL_RCS", one_hot!(global_rcs));
}

pub fn exec_login_shell(arg: &Opt, start: &Instant) -> ! {
    let mut cmd = Command::new(ZSH);
    cmd.arg("--login");
    log::debug!("login command: {:?}", cmd);
    print_usage_time(&arg, &start);
    let err = cmd.exec();
    panic!("exec fail with {:?}", err);
}
