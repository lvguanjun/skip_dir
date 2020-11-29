# 目录跳过脚本

## 用途
用于当遍历基准目录所有文件时，需要跳过指定目录，例`grep -r root`

## 使用方法
`sh skip_dir.sh root exclude1 exclude2 ...`
`sh simpile_skip_dir.sh root exclude1 exclude2 ...`

***注：exclude为相对目录***

## 其他
simpile_skip_dir.sh方法更好，find遍历基准目录,深度为最深的跳过目录，`grep -v`去除跳过目录的父子目录
