
#if [ "$(tty)" = "/dev/tty1" ]; then
#        exec sway
#fi

if (sys | get tty) == "/dev/tty1" {
    exec sway
}

let-env XDG_RUNTIME_DIR = "/home/joffi/.config"

