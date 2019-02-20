# sed完全使用解析

#### 一、在某行的前一行或后一行添加内容

操作如下：

```
#匹配行前加 
$sed -i '/allow 361way.com/iallow www.361way.com' the.conf.file 
#匹配行前后 
$sed -i '/allow 361way.com/aallow www.361way.com' the.conf.file
```

而在书写的时候为便与区分，往往会在i和a前面加一个反加一个反斜扛 。代码就变成了：

```
$sed -i '/2222222222/a\3333333333' test.txt
$sed -i '/2222222222/i\3333333333' test.txt
```



#### 二、在某行（指具体行号）前或后加一行内容

```
$sed -i 'N;4addpdf' a.txt
$sed -i 'N;4ieepdf' a.txt
```

这里指定的行号是第四行 。

#### 三、删除指定行的上一行或下一行

```
#删除指定文件的上一行
$sed -i -e :a -e '$!N;s/.*n(.*directory)/1/;ta'  -e 'P;D' server.xml 
#删除指定文件的下一行 
$sed -i '/pattern="%/{n;d}' server.xml
```

这个写起来有点长，一般如果不是shell里的需要，我更喜欢用[vim](https://www.baidu.com/s?wd=vim&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)去处理。另外需要注意的是，在vim里如果替换的内容里tab这样的符号是需要在编辑模式下分别按ctrl+v 和crtl+I ，而不是不停的几个空格。



#### 一些特殊字符的使用

　　”^”表示行首

　　”$”符号如果在引号中表示行尾，但是在引号外却表示末行(最后一行)

```
# 注意这里的 " & " 符号，如果没有 “&”，就会直接将匹配到的字符串替换掉

$sed 's/^/添加的头部&/g' 　　　　 #在所有行首添加
$sed 's/$/&添加的尾部/g' 　　　　 #在所有行末添加
$sed '2s/原字符串/替换字符串/g'　 #替换第2行
$sed '$s/原字符串/替换字符串/g'   #替换最后一行
$sed '2,5s/原字符串/替换字符串/g' #替换2到5行
$sed '2,$s/原字符串/替换字符串/g' #替换2到最后一行
```

批量替换字符串

```
$sed -i "s/查找字段/替换字段/g" `grep 查找字段 -rl 路径`  
$sed -i "s/oldstring/newstring/g" `grep oldstring -rl yourdir
```

sed处理过的输出是直接输出到屏幕上的,使用参数”i”直接在文件中替换。

```
# 替换文件中的所有匹配项

$sed -i 's/原字符串/替换字符串/g' filename
```

多个替换可以在同一条命令中执行,用分号”;”分隔，其格式为:

```
# 同时执行两个替换规则

$sed 's/^/添加的头部&/g；s/$/&添加的尾部/g'
```



#### 注意点：

判断字符串是否为空！



```
正确做法：

#!/bin/sh

STRING=

if [ -z "$STRING" ]; then  
    echo "STRING is empty"  
fi

if [ -n "$STRING" ]; then  
    echo "STRING is not empty"  
fi
```

在shell脚本里，使用sed，然后用变量替换指定的字符串，一直出现这个错误；但是单独运行在外面可以

![](https://images2015.cnblogs.com/blog/746846/201611/746846-20161101155200455-662497254.png)

把分隔符/替换成#就可以：

```
$sed "s#revision=.*#revision=$sTime#g"  $location/default.xml
```

具体事例(原因:因为nodeNetWork存在特殊字符/,所以我们需要通过特殊字符替换原来的sed脚本，用#号取代/就可以正常通过编译执行)：

```
$nodeNetWork=8.8.8.8/8;
$sed -i "s#cidr:.*#cidr: $nodeNetWork#g" ippool.yaml
```

                          
