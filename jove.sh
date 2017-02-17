#!/bin/bash
while true ; do
  for entr in launch.sh ; do
    entry="${entr/.sh/}"
    tmux kill-session -t $entry
    rm -rf ~/.telegram-cli/$entry/data/animation/*
    rm -rf ~/.telegram-cli/$entry/data/audio/*
    rm -rf ~/.telegram-cli/$entry/data/document/*
    rm -rf ~/.telegram-cli/$entry/data/photo/*
    rm -rf ~/.telegram-cli/$entry/data/sticker/*
    rm -rf ~/.telegram-cli/$entry/data/temp/*
    rm -rf ~/.telegram-cli/$entry/data/video/*
    rm -rf ~/.telegram-cli/$entry/data/voice/*
    rm -rf ~/.telegram-cli/$entry/data/profile_photo/*
    tmux new-session -d -s $entry "./$entr"
    tmux detach -s $entry
  done
  echo -e "${CYAN}|-------------|---------------|----------------|----------------|${NC}"
echo -e "${CYAN}|EDIT     __  |BY  _______    | ___ POUYA.P___ |  ____________  |${NC}"
echo -e "${CYAN}|        |  | |   /  __   \   | \  \      /  / | |   _________| |${NC}"
echo -e "${CYAN}|        |  | |  /  |  |   \  |  \  \    /  /  | |  |_________  |${NC}"
echo -e "${CYAN}| ___    /  / | |   |  |    | |   \  \  /  /   | |   _________| |${NC}"
echo -e "${CYAN}| \  \__/  /  |  \  |__|   /  |    \  \/  /    | |  |_________  |${NC}"
echo -e "${CYAN}|  \______/   |   \_______/   |     \____/     | |____________| |${NC}"
echo -e "${CYAN}|-------------|---------------|----------------|----------------|${NC}"
echo -e "${CYAN}|THIS SOURCE BASED ON TELEMUTE AND EDITED FOR JOVEGOD BY POUYA.P|${NC}"
echo -e "${CYAN}|-------------|---------------|----------------|----------------|${NC}"
  sleep 1800
done
