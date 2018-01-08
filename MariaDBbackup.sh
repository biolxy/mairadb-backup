#!/bin/bash 
#This is a ShellScript For Auto DB Backup 
# Powered by aspbiz 原作者
#2004-09 
#Setting 
#设置数据库名，数据库登录名，密码，备份路径，日志路径，数据文件位置，以及备份方式 
#默认情况下备份方式是tar，还可以是mysqldump,mysqldotcopy 
#默认情况下，用root(空)登录mysql数据库，备份至/root/dbxxxxx.tgz
#可以将这个脚本放进crontab，每天5点02分执行一次，自动备份 20 5 * * * root sh /data2/public/lixiangyong/MariaDBbackup/MariaDBbackup.sh 
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

export $PATH
DBName="biolxyDB"   #mysql 
DBUser="root" 
DBPasswd="root"
#BackupPath="/data2/public/lixiangyong/MariaDBbackup" 
LogFile="db.bak.log" 
DBPath="/usr/local/mariadb/var" 
#BackupMethod=mysqldump 
#BackupMethod=tar 
#Setting End 
NewFile=db$(date +%y%m%d).tgz 
DumpFile=db$(date +%y%m%d) 
OldFile=db$(date +%y%m%d --date='5 days ago').tgz 
echo "-------------------------------------------" >> $LogFile 
echo $(date +"%y-%m-%d %H:%M:%S") >> $LogFile 
echo "--------------------------" >> $LogFile 
#Delete Old File 
if [ -f $OldFile ] 
then 
	rm -f $OldFile >> $LogFile 2>&1 
	echo "[$OldFile]Delete Old File Success!" >> $LogFile 
else 
	echo "[$OldFile]No Old Backup File!" >> $LogFile 
fi 
if [ -f $NewFile ] 
then 
   echo "[$NewFile]The Backup File is exists,Can't Backup!" >> $LogFile 
else 
	case $BackupMethod in 
	*) 
		if [ -z $DBPasswd ] 
		then 
		 mysqldump -u $DBUser --opt $DBName > $DumpFile 
		else 
		 mysqldump -u $DBUser -p$DBPasswd $DBName > $DumpFile 
		fi 
		tar czvf $NewFile $DumpFile >> $LogFile 2>&1 
		echo "[$NewFile]Backup Success!" >> $LogFile 
		rm -rf $DumpFile 
		;; 
	tar) 
		/bin/lnmp stop >/dev/null 2>&1 
		tar czvf $NewFile $DBPath/$DBName >> $LogFile 2>&1 
		/bin/lnmp start >/dev/null 2>&1 
		echo "[$NewFile]Backup Success!" >> $LogFile 
		;; 
	esac 
fi 
echo "-------------------------------------------" >> $LogFile 
