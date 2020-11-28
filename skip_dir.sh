#!/bin/bash

# 给出基准目录去除跳过目录的检索情况，跳过目录为相对目录
# sh skip.sh root exclude1 exclude2 ...
# 提供对root目录去除root/exclude1、root/exclude2的检索参数

# 想到更好的办法...脚本仅存储

REMAIN_DIR=""
BAN_DIR=""

function err_msg()
{
	echo "$@"
	exit 1
}

# 跳过目录中若父子目录存在，将干扰结果
function check_subdir()
{
	if [ $# -eq 2 ]; then
		[[ "$1" =~ ^$2 || "$2" =~ ^$1 ]] && err_msg "$1 $2 dir repat"
		return 0
	elif [ $# -gt 2 ]; then
		local single_str=$1
		shift
		for i in $@; do
			[[ "$single_str" =~ ^$i || "$i" =~ ^$single_str ]] && err_msg "$single_str $i dir repat"
		done
		check_subdir $@
	fi
	return 0
}

# 校验所有目录是否存在及跳过目录间是否存在父子目录
function check_parameter()
{
	local root_dir=$1
	[ -d $root_dir ] || err_msg "$root_dir is not exist"
	shift
	for i in $@; do
		[ -d $root_dir/$i ] || err_msg "$root_dir/$i is not exist"
	done
	check_subdir $@
}

function skip_dir()
{
	local root_dir=$(cd $1 && pwd)
	local exclude_dir=$2
	for i in $(echo $exclude_dir | tr '/' ' '); do
		REMAIN_DIR="$REMAIN_DIR $(find $root_dir/* -maxdepth 0 | grep -v "/$exclude_dir$")"
		local root_dir=$root_dir/$i
		BAN_DIR="$BAN_DIR $root_dir"
	done
}

# 去除不可能目录
function remove_ban_dir()
{
	for i in $(echo $BAN_DIR); do
		REMAIN_DIR=$(echo $REMAIN_DIR | xargs -n 1 | grep -vx "$i")
	done
}

function main()
{
	check_parameter $@
	local root_dir=$1
	shift
	while [ $# -ge 1 ]; do
		local exclude_dir=$1
		skip_dir $root_dir $exclude_dir
		shift
	done
	REMAIN_DIR=$(echo $REMAIN_DIR | xargs -n 1 | sort -u)
	BAN_DIR=$(echo $BAN_DIR | xargs -n 1 | sort -u)
	remove_ban_dir
	echo $REMAIN_DIR | xargs -n 1
}

main $@
