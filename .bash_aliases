alias dcu="docker compose up -d"
alias dcd="docker compose down -v"
alias dp='docker rmi $(docker images -q)'
alias nuke='docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && docker rmi $(docker images -aq) -f && docker volume rm $(docker volume ls -q)'
alias sudonuke='sudo docker stop $(sudo docker ps -aq) && sudo docker rm $(sudo docker ps -aq) && sudo docker rmi $(sudo docker images -aq) -f && sudo docker volume rm $(sudo docker volume ls -q)'
alias prune='docker system prune -a && docker volume prune'

alias vima="v ~/.bash_aliases"
alias cata="cat ~/.bash_aliases"
alias sba="source ~/.bash_aliases && echo 'sourced ~/.bash_aliases'"
alias sp="source ~/.profile && echo 'sourced ~/.profile'"

alias night="xrandr --output HDMI-1 --brightness 0.3 && echo 'Owl mode'"
alias evelate="xrandr --output HDMI-1 --brightness 0.6 && echo 'Eve late'"
alias eve="xrandr --output HDMI-1 --brightness 0.6 && echo 'Good evening'"
alias afternoon="xrandr --output HDMI-1 --brightness 0.8 && echo 'Good afternoon'"
alias day="xrandr --output HDMI-1 --brightness 1 && echo 'Wakey wakey'"

alias g='cd ~/Git'
alias F='echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode && F keys'
alias v='nvim'
alias V='nvim ~/.dotfiles/.config/nvim/init.lua'
alias f='if [ -z "$TMUX" ]; then tmux new-session -s mysession "nvim \$(fzf)"; else nvim $(fzf); fi'
alias g='lazygit'
alias t='if [ -z "$TMUX" ]; then tmux new-session -s mysession; else echo "tmux session already active"; fi'
alias j='cd ~/Git/jedwaltondev'
alias ds='cd ~/Git/jedwaltondev/dev && ./start.sh'
alias d='cd ~/Downloads'
alias D='cd ~/.dotfiles'
alias s='scrot -s ~/Pictures/screenshot_%Y-%m-%d-%H-%M-%S.png'
alias c='ssh dev@localhost -p 2222'

#Python
alias venvactivate='source env/bin/activate'
alias venvnew='python3 -m venv env'
alias venvrequirements='pip install -r requirements.txt'
alias venvfreeze='pip freeze > requirements.txt'
alias venvdeactivate='deactivate'


