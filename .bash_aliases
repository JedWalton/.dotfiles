alias v=nvim
alias dcu="docker compose up -d"
alias dcd="docker compose down -v"

alias vima="v ~/.bash_aliases"
alias cata="cat ~/.bash_aliases"
alias sba="source ~/.bash_aliases && echo 'sourced ~/.bash_aliases'"
alias sp="source ~/.profile && echo 'sourced ~/.profile'"

alias night="xrandr --output HDMI-0 --brightness 0.3 && echo 'Goodnight :*'"
alias eve="xrandr --output HDMI-0 --brightness 0.6 && echo 'Good evening'"
alias day="xrandr --output HDMI-0 --brightness 1 && echo 'Wakey wakey'"

alias k='kubectl'
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

alias mk="minikube kubectl --"

alias gp='git add . && git commit -m "+" && git push'

## Misc configuration
#echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode
#If that doesn't work, remember to set it back to 1 for consistency's sake:
#echo 1 | sudo tee /sys/module/hid_apple/parameters/fnmode
