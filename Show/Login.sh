#!/bin/bash

#ユーザー追加
Add(){
        local file=".my.cnf"
	local username
	local password
	local hostname

	echo "ユーザーを新規追加"
	read -p "ユーザー名 : " username </dev/tty
	read -s -p "パスワード : " password </dev/tty
	echo
	read -p "ホスト名 : " hostname </dev/tty
	#ファイル内にかきこみ
	{ echo "[client]";
		echo "user = $username";
		echo "password = $password";
		echo "host = $hostname";
	} >> $file
	echo "追加完了"
}

#ログインユーザー選ぶ
Account(){
	local file=".my.cnf"
	local login_user
	if [ ! -e $file ];
	then
		Add
	fi
	echo "/* ログインユーザーリスト */"
	cat $file | grep 'user = ' | awk '{print $3}'
	read -p"ユーザー名を指定[新規作成:add] : " login_user </dev/tty
	if [ "$login_user" = "add" ];
	then
		Add
		Account
	else
		Connect $login_user
	fi

}

#MYSQL接続テスト(引数:ユーザー名)
Connect(){
	local file=".my.cnf"
	local ret=`mysql --defaults-extra-file=./$file -u $1 -e"select user();"`
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
