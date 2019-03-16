#!/bin/bash

#Display menu
echo "==========================================================="
figlet "User Management Automation"
echo "==========================================================="

# Priviledge Check
if [[ $UID -ne 0 ]]
then
    echo "Please run the script with root privileges... Exiting.."
    exit 1
fi

#display menu
echo
echo "1. Single User Add"
echo "2. Bulk Uuser Add via file"
echo "3. Bulk User Delete"
echo

#get the choice from user
read -p "Enter a choice from above menu: " choice

#-------------------------
# Single User check
#-------------------------
if [[ "$choice" = "1" ]]
then
    echo "You have selected single user add option"
    echo

    #get the username
    read -p "Enter the username: " USER_NAME

    #check if the user already in system
    user=$(grep -R $USER_NAME "/etc/passwd" | wc -l)
    if [[ "$user" -eq "1" ]]
    then
        echo "User account already exists in system. Exiting"
        exit 0
    else
        echo "User account not found in system. Creating user account with username \"${USER_NAME}\""
        echo
        #add the user and assign a shell
        useradd -m $USER_NAME -c "$USER_NAME" -s /bin/bash
        echo "User account successfully created!"
        echo
        read -p "Do you want to grant sudo permission to this user ? Enter [Y or N]: " addsudo_permission
        if [[ "$addsudo_permission" = "Y" || "$addsudo_permission" = "y" ]]
        then
            #add user to sudo group
            usermod -a -G sudo $USER_NAME
            echo "User \"${USER_NAME}\" has been successfully added to sudo group. Exiting now.."
            echo
            exit 0
        elif [[ "$addsudo_permission" = "N" || "$addsudo_permission" = "n" ]]
        then
            echo "User has not been added to the sudo group. Exiting.."
            echo
            exit 0
        fi
    fi

#-------------------------
# Bulk User check
#-------------------------
elif [[ "$choice" = "2" ]]
then
    echo "You have selected bulk user add option"
    echo
    echo "Make sure the new user list is in the current directory with users.txt as filename"
    echo

    users=$(cat users.txt)
    for uname in $users; do
        check=$(grep -R $uname "/etc/passwd" | wc -l)
        if [[ "$check" -eq "1" ]]
        then
            echo "User account \"$uname\" present in system"
        elif [[ "$check" -eq "0" ]]
        then
            #add user and assign a shell
            useradd -m $uname -c "$uname" -s /bin/bash
            echo "User account \"$uname\" has been created successfully"
        fi
    done

#-----------------------
# Bulk User Delete
#-----------------------
elif [[ "$choice" = "3" ]]
then

    users=$(cat users.txt)
    for uname in $users; do
        check=$(grep -R $uname "/etc/passwd" | wc -l)
        if [[ "$check" -eq "1" ]]
        then
            #delete a users
            userdel -r $uname 2>/dev/null
            echo "User account \"$uname\" has been deleted successfully"
        elif [[ "$check" -eq "0" ]]
        then
            echo "User account \"$uname\" does not exist"
        fi
    done

else
    echo
    echo "Select only the options available.. Exiting.."
    exit 1
fi
