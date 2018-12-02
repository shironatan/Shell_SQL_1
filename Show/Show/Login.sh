#!/bin/bash

#ユーザー変更
Change(){
        local file=".my.cnf"
	local username
	local password
	local hostname

	echo "ユーザーを変更"
	read -p "ユーザー名 : " username </dev/tty
	read -s -p "パスワード : " password </dev/tty
	echo
	read -p "ホスト名 : " hostname </dev/tty
	#ファイル内にかきこみ
	{ echo "[client]";
		echo "user = $username";
		echo "password = $password";
		echo "host = $hostname";
	} > $file
	echo "変更完了"
}

#ログインユーザー選ぶ
Account(){
	local file=".my.cnf"
	local login_user
	if [ ! -e $file ];
	then
		Add
	fi
	echo "/* ログインユーザー */"
	cat $file | grep 'user = ' | awk '{print $3}'
	read -p"ユーザー名を指定[変更:change] : " login_user </dev/tty
	if [ "$login_user" = "change" ];
	then
		Change
		Account
	else
		USER="$login_user"
	fi

}

#MYSQL接続テスト
Connect(){
	local file=".my.cnf"
	local ret
	ret=`mysql --defaults-extra-file=./$file -u $USER -e"select user();"`
	if [ $? -eq 1 ]; then
                echo "MYSQLに接続できませんでした。"
                exit 1
	else
		echo "MYSQLに接続できました"
		local user_list=`echo $ret | awk '{ print $2; }'`
		echo "$user_listでログインしました"
        fi
}

echo "ユーザー名を指定してMYSQLへログイン"
Account
Connect
