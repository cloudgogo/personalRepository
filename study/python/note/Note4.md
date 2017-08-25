##条件判断
#if
- 根据Python的缩进规则，如果`if`语句判断是`True`，就把缩进的两行print语句执行了，否则，什么也不做。
```
age = 20
if age >= 18:
    print('your age is', age)
    print('adult')
```
- 也可以给`if`添加一个`else`语句，意思是，如果`if`判断是`False`，不要执行`if`的内容，去把`else`执行了：
```
age = 3
if age >= 18:
    print('your age is', age)
    print('adult')
else:
    print('your age is', age)
    print('teenager')
```
- 注意不要少些`:`
- 当然上面的判断是很粗略的，完全可以用`elif`做更细致的判断：
```
age = 3
if age >= 18:
    print('adult')
elif age >= 6:
    print('teenager')
else:
    print('kid')
```
int()可以将字符串转换为整型
float()转换为浮点型
long()转换为长整型
str()转换为字符串


int(x [,base ])         将x转换为一个整数    
long(x [,base ])        将x转换为一个长整数    
float(x )               将x转换到一个浮点数    
complex(real [,imag ])  创建一个复数    
str(x )                 将对象 x 转换为字符串    
repr(x )                将对象 x 转换为表达式字符串    
eval(str )              用来计算在字符串中的有效Python表达式,并返回一个对象    
tuple(s )               将序列 s 转换为一个元组    
list(s )                将序列 s 转换为一个列表    
chr(x )                 将一个整数转换为一个字符    
unichr(x )              将一个整数转换为Unicode字符    
ord(x )                 将一个字符转换为它的整数值    
hex(x )                 将一个整数转换为一个十六进制字符串    
oct(x )                 将一个整数转换为一个八进制字符串   