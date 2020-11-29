#!/bin/bash

# 给出基准目录去除跳过目录的检索情况，跳过目录为相对目录
# sh skip.sh root exclude1 exclude2 ...
# 提供对root目录去除root/exclude1、root/exclude2的检索参数


function err_msg()
{
	echo "$@"
	exit 1
}

# 校验所有目录是否存在
function check_parameter()
{
	local root_dir=$1
	[ -d $root_dir ] || err_msg "$root_dir is not exist"
	shift
	for i in $@; do
		[ -d $root_dir/$i ] || err_msg "$root_dir/$i is not exist"
	done
}

# 获取跳过目录的最大深度
function get_skip_maxdepth()
{
	local maxdeepth=0
	for i in $@; do
		local one_depth=$(echo $i | sed 's|/$||' | awk -F / '{print NF}')
		local maxdepth=$((maxdepth>one_depth?maxdepth:one_depth))
	done
	echo $maxdepth
}

function main()
{
	check_parameter $@
	local root_dir=$( cd $1 && pwd)
	shift
	local maxdepth=$[$(get_skip_maxdepth $@)-1]
	REMAIN_DIR=$(find $root_dir/* -maxdepth $maxdepth)
	for i in $@; do
		local exclude_dir=$root_dir
		for j in $(echo $i | tr '/' ' '); do
			local exclude_dir=$exclude_dir/$j
			REMAIN_DIR=$(echo $REMAIN_DIR | xargs -n 1 | grep -vx "$exclude_dir")
		done
		REMAIN_DIR=$(echo $REMAIN_DIR | xargs -n 1 | grep -vx "$exclude_dir/.*")
	done
	echo $REMAIN_DIR | xargs -n 1
}

main $@
