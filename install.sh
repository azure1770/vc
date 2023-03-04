#!/bin/bash
pwd=$(pwd)
source $pwd/vcvars

is_command() {
    # Checks to see if the given command (passed as a string argument) exists on the system.
    # The function returns 0 (success) if the command exists, and 1 if it doesn't.
    local check_command="$1"

    command -v "${check_command}" >/dev/null 2>&1
}

check_unp() {
str="Unp"
    printf "%b %s" "${INFO}" "$str"
    sleep 1
if ! is_command unp ; then
    printf "%b %b %s"\\n "${OVER}" "${CROSS}" "$str"
    sleep 2
    clear
    echo -e $LGREEN"$str installing..."$RALL
    sudo apt-get install unp -y
    clear
else
    printf "%b %b %s"\\n "${OVER}" "${TICK}" "$str"
fi
}

check_vc() {
str="Veracrypt"
    printf "%b %s" "${INFO}" "$str"
    sleep 1
if ! is_command veracrypt; then
    printf "%b %b %s"\\n "${OVER}" "${CROSS}" "$str"
    sleep 2
    clear
    echo -e $LGREEN"$str installing..."$RALL
    echo ""
    wget `curl https://veracrypt.fr/en/Downloads.html | grep "setup.tar.bz2" | grep -iv -e "sig" -e "x86" -e "freebsd" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' -e 's/&#43;/+/'`
    unp veracrypt*setup.tar.bz2
    ./veracrypt*setup-console-x64
    sudo rm veracrypt* -R
    clear
else
    printf "%b %b %s"\\n "${OVER}" "${TICK}" "$str"
fi
}

check_kpcx() {
str="KeepassXC"
    printf "%b %s" "${INFO}" "$str"
    sleep 1
if ! is_command keepassxc ; then
    printf "%b %b %s"\\n "${OVER}" "${CROSS}" "$str"
    sleep 2
    clear
    echo -e $LGREEN"$str installing..."$RALL
    sudo add-apt-repository ppa:phoerious/keepassxc -y
    sudo apt-get update
    sudo apt install keepassxc -y
    clear
else
    printf "%b %b %s"\\n "${OVER}" "${TICK}" "$str"
fi
}

check_config() {
str="Config"
    printf "%b %s" "${INFO}" "$str"
    sleep 1
if [[ -f /bin/vcvars ]] && [[ -f /bin/vcsec ]] && [[ -f /bin/vc ]]; then
    printf "%b %b %s"\\n "${OVER}" "${TICK}" "$str"
    sleep 1
else
    printf "%b %b %s"\\n "${OVER}" "${CROSS}" "$str"
    sleep 2
    clear
    echo -e $LGREEN"$str installing..."$RALL
    sleep 1
    sudo cp $pwd/vc /bin/vc
    sudo cp $pwd/vcvars /bin/vcvars
    sudo cp $pwd/vcsec /bin/vcsec
    sudo chmod +x /bin/vc
    sudo nano /bin/vcvars
    sudo nano /bin/vcsec
    mkmp=$(cat /bin/vcvars | grep "ContainerMP" | sed 's/ContainerMP\=//')
    mkdir -p $mkmp
    mkmp=$(cat /bin/vcvars | grep "ContainerDir" | sed 's/ContainerDir\=//')
    mkdir -p $mkcd
    clear
    first_container
fi
}

check_dep() {
check_unp
check_vc
check_kpcx
check_config
}

check_exit() {
if is_command unp >/dev/null 2>&1 ; then
banner_post
check_dep
banner_fin
exit
fi
}

first_container() {
while true
do
#echo ""
read -r -n 1 -p "Would you create a Veracrypt Container (Y|n)? " cvcc && printf "\n"
case "$cvcc" in
    y|Y|"")
    veracrypt -t -c
    break
    ;;
    n|N)
    break
    ;;
    *)
      echo " Invalid input..."
    ;;
esac
done
clear
}

banner_post() {
clear
echo ""
echo -e "\e[92m******************\e[39m"
echo -e "\e[92m* Setup VC & KP  *\e[39m"
echo -e "\e[92m******************\e[39m"
echo ""
}

banner_fin() {
echo ""
echo -e "\e[92m******************\e[39m"
echo -e "\e[92m* Setup Finished *\e[39m"
echo -e "\e[92m******************\e[39m"
echo ""
}

banner_aborted() {
echo ""
echo -e "\e[31m******************\e[39m"
echo -e "\e[31m* Setup Aborted! *\e[39m"
echo -e "\e[31m******************\e[39m"
echo ""
}

show_usage() {
banner_post
printf " -i | Install\n"
printf " -c | Create Container"
printf "\n\n"
printf " -r | Remove Installation\n"
printf " -h | Display this helpscreen"
printf "\n\n"
return 0
}

remove_install() {
sudo apt-get remove unp keepassxc -y
sudo veracrypt-uninstall.sh
sudo rm /bin/vc
sudo rm /bin/vcsec
sudo rm /bin/vcvars
echo ""
}

install(){
banner_post
check_dep
banner_fin
}

if [[ $# -eq 0 ]]; then
check_exit
show_usage
while true
do
echo ""
read -r -n 1 -p "Proceed with Installation... (Y|n)? " cvcc && printf "\n"
case "$cvcc" in
    y|Y|"")
    install
    check_exit
    break
    ;;
    n|N)
    banner_aborted
    break
    ;;
esac
done
fi

while [ ! -z "$1" ];do
    case "$1" in
    -h|help)
    show_usage
    ;;

    -i)
    install
    ;;

    -c)
    first_container
    ;;

    -r)
    remove_install
    ;;

    *)
    show_usage
esac
shift
done
