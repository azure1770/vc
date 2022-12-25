#/bin/bash


#Check Veracrypt
if [ ! -f /bin/veracrypt ]
then
    apt-get install unp -y
    wget `curl https://veracrypt.fr/en/Downloads.html | grep "setup.tar.bz2" | grep -iv -e "sig" -e "x86" -e "freebsd" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' -e 's/&#43;/+/'`
    unp veracrypt*setup.tar.bz2
    ./veracrypt*setup-console-x64
    sudo rm veracrypt* -R
fi

#Check KeepassXC
if [ `dpkg -l | grep -E '^ii' | grep keepassxc | cut -d" " -f 3` = 'keepassxc' ]
then
    :
else
    sudo add-apt-repository ppa:phoerious/keepassxc -y
    sudo apt-get update
    sudo apt install keepassxc -y
fi

sudo cp ./vc /bin
sudo cp ./vcvars /bin
sudo cp ./vcsec /bin
sudo chmod +x /bin/vc

#Create first Veracrypt Container
echo ""

while true
do
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

sudo nano /bin/vcvars

clear
echo ""
echo ""
echo -e "\e[92m******************\e[39m"
echo -e "\e[92m* Setup Finished *\e[39m"
echo -e "\e[92m******************\e[39m"
echo ""
