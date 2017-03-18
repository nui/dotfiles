const path = require('path');

const tmuxDir = __dirname;
const templateFile = 'tmux.conf.jinja2';

module.exports = {
    versions: [1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4],
    dir: tmuxDir,
    template: {
        name: templateFile,
        path: path.join(tmuxDir, templateFile)
    },
    tmpEnvs: [
        'NMK_TMUX_256_COLOR',
        'NMK_TMUX_DEFAULT_SHELL',
        'NMK_TMUX_DEFAULT_TERMINAL',
        'NMK_TMUX_DETACH_ON_DESTROY',
    ],
};
