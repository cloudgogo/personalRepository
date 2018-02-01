#finereport导出excel带链接方案
1. 导出链接js:
```
window.open("http://172.18.12.36:8080/CindascReport/ReportServer?reportlet=getdatevalue.cpt&op=view&format=excel&extype=simple&isExcel2003=true")
```
2. import模板内容
```
=HYPERLINK(CONCATENATE(MID(CELL("filename"),FIND("[",CELL("filename")),FIND("]",CELL("filename"))-FIND("[",CELL("filename"))+1),"sheet2!A1"),"跳转") 
```