#coding: utf-8
require 'net/http'
require 'digest/sha1'

URL = 'http://api.feieyun.cn/Api/Open/'#不需要修改
STIME = Time.new.to_i.to_s #不需要修改

USER = '****************' #*必填*：登录管理后台的账号名
UKEY = '****************' #*必填*: 飞鹅云后台注册账号后生成的UKEY 【备注：这不是填打印机的KEY】
SN = '*********' #*必填*：打印机编号，必须要在管理后台里手动添加打印机或者通过API添加之后，才能调用API

SIG = Digest::SHA1.hexdigest(USER+UKEY+STIME) #签名



#**********测试时，打开下面注释掉方法的即可,更多接口文档信息,请访问官网开放平台查看**********


#添加打印机接口（支持批量）============================
def addprinter(snlist)
        params = {}
        params["user"] = USER
        params["stime"] = STIME
        params["sig"] = SIG
        params["apiname"] = "Open_printerAddlist" #固定
        params["printerContent"] = snlist
        uri = URI.parse(URL)
        res = Net::HTTP.post_form(uri, params)
        puts res.body
end

#添加打印机接口（支持批量）
#***返回值有如下几种***
#正确例子：{"msg":"ok","ret":0,"data":{"ok":["sn#key#remark#carnum","316500011#abcdefgh#快餐前台"],"no":["316500012#abcdefgh#快餐前台#13688889999  （错误：识别码不正确）"]},"serverExecutedTime":3}
#错误：{"msg":"参数错误 : 该帐号未注册.","ret":-2,"data":null,"serverExecutedTime":37}

#提示：打印机编号(必填) # 打印机识别码(必填) # 备注名称(选填) # 流量卡号码(选填)，多台打印机请换行（\n）添加新打印机信息，每次最多100行(台)。
#snlist = "sn1#key1#remark1#carnum1\nsn2#key2#remark2#carnum2"
#addprinter snlist




#方法1，打印订单(内容)============================
def print()
        #标签说明：
        #单标签:
        #"<BR>"为换行,"<CUT>"为切刀指令(主动切纸,仅限切刀打印机使用才有效果)
        #"<LOGO>"为打印LOGO指令(前提是预先在机器内置LOGO图片),"<PLUGIN>"为钱箱或者外置音响指令
        #成对标签：
        #"<CB></CB>"为居中放大一倍,"<B></B>"为放大一倍,"<C></C>"为居中,<L></L>字体变高一倍
        #<W></W>字体变宽一倍,"<QR></QR>"为二维码,"<BOLD></BOLD>"为字体加粗,"<RIGHT></RIGHT>"为右对齐
        #拼凑订单内容时可参考如下格式
        #根据打印纸张的宽度，自行调整内容的格式，可参考下面的样例格式
      
        content = '<CB>测试打印</CB><BR>'
        content.concat('名称　　　　　 单价  数量 金额<BR>')
        content.concat('--------------------------------<BR>')
        content.concat('饭　　　　　 　10.0   10  10.0<BR>')
        content.concat('炒饭　　　　　 10.0   10  10.0<BR>')
        content.concat('蛋炒饭　　　　 10.0   100 100.0<BR>')
        content.concat('鸡蛋炒饭　　　 100.0  100 100.0<BR>')
        content.concat('西红柿炒饭　　 1000.0 1   100.0<BR>')
        content.concat('西红柿蛋炒饭　 100.0  100 100.0<BR>')
        content.concat('西红柿鸡蛋炒饭 15.0   1   15.0<BR>')
        content.concat('备注：加辣<BR>')
        content.concat('--------------------------------<BR>')
        content.concat('合计：xx.0元<BR>')
        content.concat('送货地点：广州市南沙区xx路xx号<BR>')
        content.concat('联系电话：13888888888888<BR>')
        content.concat('订餐时间：2014-08-08 08:08:08<BR>')
        content.concat('<QR>http://www.dzist.com</QR>')
        
        params = {}
        params["user"] = USER  
        params["stime"] = STIME
        params["sig"] = SIG  
        params["apiname"] = "Open_printMsg" #固定
        params["sn"] = SN #打印机编号 
        params["content"] = content #打印内容 
        params["times"] = "1" #打印联数 
        uri = URI.parse(URL)
        res = Net::HTTP.post_form(uri, params)
        #服务器返回的JSON字符串，建议要当做日志记录起来
        puts res.body
end  

#***方法1返回值有如下几种***
#正确例子：{"msg":"ok","ret":0,"data":"xxxx_xxxx_xxxxxxxxx","serverExecutedTime":6}
#错误：{"msg":"错误信息.","ret":非零错误码,"data":null,"serverExecutedTime":5}

#print #方法1调用 
 



  
#方法2，查询某订单是否打印成功==========================
def queryOrderState(strorderid)
        params = {}
        params["user"] = USER  
        params["stime"] = STIME
        params["sig"] = SIG
        params["apiname"] = "Open_queryOrderState" #固定
        params["orderid"] = strorderid  
        uri = URI.parse(URL)
        res = Net::HTTP.post_form(uri, params)
        puts res.body
end

#***方法2返回值有如下几种***
#已打印：{"msg":"ok","ret":0,"data":true,"serverExecutedTime":6}
#未打印：{"msg":"ok","ret":0,"data":false,"serverExecutedTime":6}

#queryOrderState "xxxxxxxxx_xxxxxxxxx_xxxxxxxxxxx" #方法2调用


 
 


#方法3，查询指定打印机某天的订单详情=========================
def queryOrderInfoByDate(strdate)
        params = {}
        params["user"] = USER  
        params["stime"] = STIME
        params["sig"] = SIG
        params["apiname"] = "Open_queryOrderInfoByDate" #固定
        params["sn"] = SN
        params["date"] = strdate#注意日期格式为yyyy-MM-dd
        uri = URI.parse(URL)
        res = Net::HTTP.post_form(uri, params)
        puts res.body
end  

#***方法3返回值有如下几种(print:已打印,waiting:未打印)***
#正确例子：{"msg":"ok","ret":0,"data":{"print":6,"waiting":1},"serverExecutedTime":9}
#错误例子：{"msg":"参数错误 : 时间格式不正确。","ret":1001,"data":null,"serverExecutedTime":37}
 
#queryOrderInfoByDate "2017-04-07" #方法3调用 
 
 




#方法4，查询打印机的状态==============================
def queryPrinterStatus()
        params = {}
        params["user"] = USER  
        params["stime"] = STIME
        params["sig"] = SIG
        params["apiname"] = "Open_queryPrinterStatus" #固定
        params["sn"] = SN
        uri = URI.parse(URL)
        res = Net::HTTP.post_form(uri, params)
        puts res.body
end  

#***方法4返回值有如下几种***
#{"msg":"ok","ret":0,"data":"离线","serverExecutedTime":9}
#{"msg":"ok","ret":0,"data":"在线，工作状态正常","serverExecutedTime":9}
#{"msg":"ok","ret":0,"data":"在线，工作状态不正常","serverExecutedTime":9}

#queryPrinterStatus #方法4调用




