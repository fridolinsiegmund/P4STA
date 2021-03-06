current_user=$USER # to prevent root as $USER save it before root execution
add_sudo_rights() {
  current_user=$USER 
  if (sudo -l | grep -q '(ALL : ALL) NOPASSWD: '$1); then 
    echo 'visudo entry already exists';  
  else
    sleep 0.1
    echo $current_user' ALL=(ALL:ALL) NOPASSWD:'$1 | sudo EDITOR='tee -a' visudo; 
  fi
}

check_iperf_version() {
  currentver="$(iperf3 -v)"
  currentver=$(echo $currentver | cut -c1-11)
  requiredver="iperf 3.1.3"
   if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then 
          echo "ok"
   else
          echo "nok"
   fi
}


result=$(check_iperf_version)
if [ $result = "ok" ]; then
  printf "IPerf3 is already installed!"
else

  printf "\n-----------------------------------------\n"
  printf "Installing iPerf3"
  sudo apt update
  sudo apt remove -y iperf3 libiperf0
  wget https://iperf.fr/download/ubuntu/libiperf0_3.1.3-1_amd64.deb
  wget https://iperf.fr/download/ubuntu/iperf3_3.1.3-1_amd64.deb
  sudo dpkg -i libiperf0_3.1.3-1_amd64.deb iperf3_3.1.3-1_amd64.deb
  rm libiperf0_3.1.3-1_amd64.deb iperf3_3.1.3-1_amd64.deb
  printf "\n-----------------------------------------\n"
fi
printf "Installing ethtool"
sudo apt -y install ethtool iproute2 net-tools lsof
printf "\n-----------------------------------------\n"
printf "\nAdding the following entries to visudo at ***HOST***:\n"
add_sudo_rights $(which reboot)
add_sudo_rights $(which ethtool)
add_sudo_rights $(which ifconfig)
add_sudo_rights $(which ip)
add_sudo_rights $(which pkill)
printf "\n-----------------------------------------\n"

