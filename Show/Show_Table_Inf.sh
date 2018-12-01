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
	local ret
	ret=`mysql --defaults-extra-file=./$file -u $1 -e"select user();"`
	if [ $? -eq 1 ];
	then
                echo "MYSQLに接続できませんでした。"
                exit 1
	else
		echo "MYSQLに接続できました"
		local user_list=`echo $ret | awk '{ print $2; }'`
		echo "$user_listでログインしました"
        fi
}

#所有のDBを返す
Show_DB(){
	local file=".my.cnf"
	local ret
	ret=`mysql --defaults-extra-file=./$file -e "show databases;"`
	if [ $? -gt 0 ];
	then
		exit 0
	fi
	echo "/* データベース一覧 */"
	ARRAY=($ret)
	Show_array
}


#所有のテーブルを配列に格納しShow_arrayを呼ぶ（引数：データベース名）
Show_Table(){
	local file=".my.cnf"
	local ret
	ret=`mysql --defaults-extra-file=./$file -e "use $1;show tables;"`
	if [ $? -gt 0 ];
       	then
		echo "存在しないデータベース名です"
		echo "最初からやり直してください"
		exit 1
	fi
	ARRAY=($ret)
	echo "/* $1内のテーブル一覧 */"
	Show_array
}
#配列の中身を縦に表示
Show_array(){
	local i=0
	local e	
	for e in "${ARRAY[@]}"
	do
		echo "*** ${e}"
		let i++
	done
}
#テーブル情報を返す(引数:データベース名 テーブル名)
Show_TableInf(){
	local file=".my.cnf"
	local ret
	ret=`mysql --defaults-extra-file=./$file -e "use $1;SHOW COLUMNS FROM $2"`
	if [ $? -gt 0 ];
	then
		echo "存在しないテーブル名です"
		echo "最初からやり直してください"
		exit 1
	fi
	echo "/* $2テーブルの列情報 */"
	mysql --defaults-extra-file=./$file -e "use $1;SHOW COLUMNS FROM $2"
}

echo "テーブルの列情報を表示"
Account
Show_DB
read -p "データベース名を入力 : " Show_DB
Show_Table $Show_DB
read -p "テーブル名を入力 : " Show_Table
Show_TableInf $Show_DB $Show_Table
