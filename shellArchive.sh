#   iOS端自动打包
#   必须打包前设置好证书
#------------------------------------------------
#使用介绍:
# 1. 需要outPackaging文件夹 拷贝到项目根目录
# 2. 其中outPackaging > plist中的名字与证书输出文件夹名字一致,便于识别
# 3. 命令行执行,bash ebankPackaging.sh

#------------------------------------------------
#配置参数
#取当前时间字符串添加到文件结尾
now=$(date +"_%m月%d日(%H点%M分)")

#工程名字-----需完善
Project_Name="工程名"

#蒲公英 参数-----需完善
uKey=""
api_key=""
password=""

#配置打包方式Release或者Debug
Configuration="Debug"

#基础主路径----根据路径完善里面的plist路径
BUILD_PATH=./outPackaging

#plist 与 输出文件夹名称,需要与plist文件的名称对应上
#.plist后缀不需要写c ---- 需完善
path_plist1="export_AppStore"
path_plist2="export_AdHoc"
path_plist3="export_Enterprise"

#不同版本的基础子路径
PATH_PLIST1=${BUILD_PATH}/Archive/${path_plist1}${now}
PATH_PLIST2=${BUILD_PATH}/Archive/${path_plist2}${now}
PATH_PLIST3=${BUILD_PATH}/Archive/${path_plist3}${now}


#配置编译文件的存放地址
CONFIGURATION_BUILD_PATH1=${PATH_PLIST1}/${Configuration}-iphoneos
CONFIGURATION_BUILD_PATH2=${PATH_PLIST2}/${Configuration}-iphoneos
CONFIGURATION_BUILD_PATH3=${PATH_PLIST3}/${Configuration}-iphoneos


#下面是获取上传到第三方统计崩溃日志的文件，如果没有用到可以删除该部分
#111111111111111111111111111111111
DSYM_PATH1=${CONFIGURATION_BUILD_PATH1}/${Project_Name}.app.dSYM
DSYM_ZIP_PATH1=${PATH_PLIST1}/${Project_Name}.app.dSYM.zip
DSYM_COPY_PATH1=${PATH_PLIST1}/copy
#2222222222222222222222
DSYM_PATH2=${CONFIGURATION_BUILD_PATH2}/${Project_Name}.app.dSYM
DSYM_ZIP_PATH2=${PATH_PLIST2}/${Project_Name}.app.dSYM.zip
DSYM_COPY_PATH2=${PATH_PLIST2}/copy
#3333333333333333333333
DSYM_PATH3=${CONFIGURATION_BUILD_PATH3}/${Project_Name}.app.dSYM
DSYM_ZIP_PATH3=${PATH_PLIST3}/${Project_Name}.app.dSYM.zip
DSYM_COPY_PATH3=${PATH_PLIST3}/copy


#配置打包结果输出的路径
#1111111111111111
PrijectOutPath1=${PATH_PLIST1}/${path_plist1}
#22222222222
PrijectOutPath2=${PATH_PLIST2}/${path_plist2}
#33333333333
PrijectOutPath3=${PATH_PLIST3}/${path_plist3}

#加载各个版本的plist文件，为了实现一个脚本打包所有版本，这里对不同对版本创建了不同的plist配置文件。等号后面是文件路径，一般把plist文件放在与脚本同一级别的文件层中。我这里测试用所以plist文件都一样，实际使用是请分开配置为不同文件
#echo $EBANK_D_DIS_ExportOptionsPlist #打印变量
ExportOptionsPlist1="./outPackaging/plist/$path_plist1.plist"
ExportOptionsPlist2="./outPackaging/plist/$path_plist2.plist"
ExportOptionsPlist3="./outPackaging/plist/$path_plist3.plist"

#判断文件是否存在
if [[ ! -f "$ExportOptionsPlist1" ]]; then
echo ""
echo "~~~~~~~~~~~~$path_plist1.plist(未找到)~~~~~~~~~~~~~~~"
echo $YUANHUANPP_ExportOptionsPlist
echo ""
exit 0
fi
#else
#echo "文件存在"
#fi

if [[ ! -f "$ExportOptionsPlist2" ]]; then
echo ""
echo "~~~~~~~~~~~~$path_plist2.plist(未找到)~~~~~~~~~~~~~~~"
echo ""
exit 0
fi

if [[ ! -f "$ExportOptionsPlist3" ]]; then
echo ""
echo "~~~~~~~~~~~~path_plist3.plist(未找到)~~~~~~~~~~~~~~~"
echo ""
exit 0
fi

#在终端中提示 根据输入的序号不同，打包成不同版本的ipa
echo "~~~~~~~~~~~~选择打包方式(输入序号)~~~~~~~~~~~~~~~"
echo "  1 $path_plist1"
echo "  2 $path_plist2"
echo "  3 $path_plist3"

# 读取用户在终端中输入并存到变量里
read parameter
sleep 0.5
method="$parameter"

# 判读用户是否有输入
if [ -n "$method" ]
then
# 选择1111111111111111#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ "$method" = "1" ]
then
#创建文件夹
mkdir ${PATH_PLIST1}
#编译文件
mkdir ${CONFIGURATION_BUILD_PATH1}
#打包输出的文件
mkdir ${PrijectOutPath1}
#copy
mkdir ${DSYM_COPY_PATH1}
#编译
xcodebuild archive -scheme $Project_Name -configuration $Configuration -archivePath ${PATH_PLIST1}/$Project_Name.xcarchive CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_PATH1}
#打包
xcodebuild  -exportArchive -archivePath ${PATH_PLIST1}/$Project_Name.xcarchive -exportOptionsPlist $ExportOptionsPlist1 -exportPath ${PrijectOutPath1}
# zip -r 目标路径  源文件路径 ，开始压缩dSYM文件
zip -r ${DSYM_ZIP_PATH1} ${DSYM_PATH1}
# cp -r 源文件路径 目标路径 ， 把压缩包拷贝到指定地方
cp -r ${DSYM_ZIP_PATH1} ${DSYM_COPY_PATH1}

# 生成文件完毕后,判断试下是否成功,并且打印路径或失败情况
OUT__PATH=${PrijectOutPath1}/${Project_Name}".ipa"

echo "=============================================="
echo "=============================================="
if [[ ! -f "$OUT__PATH" ]]; then
echo ""
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo ""
exit 0
else
echo ""
echo "~~~~~~~~~~~~ipa生成已经完成~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~路径:~~~~~~~~~~~~~~~~~"
echo "$OUT__PATH"
echo ""
#上传蒲公英
echo "~~~~~~~~~~~~~~~~正在上传ipa到蒲公英~~~~~~~~~~~~~~~~~~~"
curl -F "file=@$OUT__PATH" -F "uKey=$uKey" -F "_api_key=$api_key" -F "password=$password" https://www.pgyer.com/apiv1/app/upload
if [ $? = 0 ]
then
echo -e "\n"
echo "~~~~~~~~~~~~~~~~上传蒲公英成功~~~~~~~~~~~~~~~~~~~"
else
echo -e "\n"
echo "~~~~~~~~~~~~~~~~上传蒲公英失败~~~~~~~~~~~~~~~~~~~"
fi
fi
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 选择22222222222#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
elif [ "$method" = "2" ]
then
#创建文件夹
mkdir ${PATH_PLIST2}
#编译文件
mkdir ${CONFIGURATION_BUILD_PATH2}
#打包输出的文件
mkdir ${PrijectOutPath2}
#copy
mkdir ${DSYM_COPY_PATH2}
#编译
xcodebuild archive -scheme $Project_Name -configuration $Configuration -archivePath ${PATH_PLIST2}/$Project_Name.xcarchive CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_PATH2}
#打包
xcodebuild  -exportArchive -archivePath ${PATH_PLIST2}/$Project_Name.xcarchive -exportOptionsPlist $ExportOptionsPlist2 -exportPath ${PrijectOutPath2}
# zip -r 目标路径  源文件路径 ，开始压缩dSYM文件
zip -r ${DSYM_ZIP_PATH2} ${DSYM_PATH2}
# cp -r 源文件路径 目标路径 ， 把压缩包拷贝到指定地方
cp -r ${DSYM_ZIP_PATH2} ${DSYM_COPY_PATH2}
# 生成文件完毕后,判断试下是否成功,并且打印路径或失败情况
OUT__PATH=${PrijectOutPath2}/${Project_Name}".ipa"

echo "=============================================="
echo "=============================================="
if [[ ! -f "$OUT__PATH" ]]; then
echo ""
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo ""
exit 0
else
echo ""
echo "~~~~~~~~~~~~ipa生成已经完成~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~路径:~~~~~~~~~~~~~~~~~"
echo "$OUT__PATH"
echo ""
#上传蒲公英
echo "~~~~~~~~~~~~~~~~正在上传ipa到蒲公英~~~~~~~~~~~~~~~~~~~"
curl -F "file=@$OUT__PATH" -F "uKey=$uKey" -F "_api_key=$api_key" -F "password=$password" https://www.pgyer.com/apiv1/app/upload
if [ $? = 0 ]
then
echo -e "\n"
echo "~~~~~~~~~~~~~~~~上传蒲公英成功~~~~~~~~~~~~~~~~~~~"
else
echo -e "\n"
echo "~~~~~~~~~~~~~~~~上传蒲公英失败~~~~~~~~~~~~~~~~~~~"
fi
fi
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 选择3333333333#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
elif [ "$method" = "3" ]
then
#创建文件夹
mkdir ${PATH_PLIST3}
#编译文件
mkdir ${CONFIGURATION_BUILD_PATH3}
#打包输出的文件
mkdir ${PrijectOutPath3}
#copy
mkdir ${DSYM_COPY_PATH3}
#编译
xcodebuild archive -scheme $Project_Name -configuration $Configuration -archivePath ${PATH_PLIST3}/$Project_Name.xcarchive CONFIGURATION_BUILD_DIR=${CONFIGURATION_BUILD_PATH3}
#打包
xcodebuild  -exportArchive -archivePath ${PATH_PLIST3}/$Project_Name.xcarchive -exportOptionsPlist $ExportOptionsPlist3 -exportPath ${PrijectOutPath3}
# zip -r 目标路径  源文件路径 ，开始压缩dSYM文件
zip -r ${DSYM_ZIP_PATH3} ${DSYM_PATH3}
# cp -r 源文件路径 目标路径 ， 把压缩包拷贝到指定地方
cp -r ${DSYM_ZIP_PATH3} ${DSYM_COPY_PATH3}
# 生成文件完毕后,判断试下是否成功,并且打印路径或失败情况
OUT__PATH=${PrijectOutPath3}/${Project_Name}".ipa"

echo "=============================================="
echo "=============================================="
if [[ ! -f "$OUT__PATH" ]]; then
echo ""
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~生成ipa包失败,未找到文件夹~~~~~~~~~~~~~~~"
echo ""
exit 0
else
echo ""
echo "~~~~~~~~~~~~ipa生成已经完成~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~路径:~~~~~~~~~~~~~~~~~"
echo "$OUT__PATH"
echo ""
#上传蒲公英
echo "~~~~~~~~~~~~~~~~正在上传ipa到蒲公英~~~~~~~~~~~~~~~~~~~"
curl -F "file=@$OUT__PATH" -F "uKey=$uKey" -F "_api_key=$api_key" -F "password=$password" https://www.pgyer.com/apiv1/app/upload
if [ $? = 0 ]
then
echo -e "\n"
echo "~~~~~~~~~~~~~~~~上传蒲公英成功~~~~~~~~~~~~~~~~~~~"
else
echo -e "\n"
echo "~~~~~~~~~~~~~~~~上传蒲公英失败~~~~~~~~~~~~~~~~~~~"
fi
fi
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
else
#如果是其他输入，则在终端中提示参数无效并退出
echo "参数无效...."
exit 1
fi
fi
