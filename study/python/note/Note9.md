#切片
##切片(Slice)
###EXAMPLE
新建一个list
```
>>> L = ['Michael', 'Sarah', 'Tracy', 'Bob', 'Jack']
```
取前三个元素
```
>>> [L[0], L[1], L[2]]
['Michael', 'Sarah', 'Tracy']
```
取前N个元素
```
>>> r = []
>>> n = 3
>>> for i in range(n):
...     r.append(L[i])
... 
>>> r
['Michael', 'Sarah', 'Tracy']
```
>range()函数提供了类似于java中的for(i=1;i<?;i++)的功能

对于这种问题python提供了切片可以简化其的操作
```
>>> L[0:3]
['Michael', 'Sarah', 'Tracy']
```
如果第一个为0，可省略
类似的 既然python支持`L[-1]`
那么同样也支持倒数切片
```
>>> L[-2:]
['Bob', 'Jack']
>>> L[-2:-1]
['Bob']
```
tuple也支持切片，同样类似，tuple切片之后仍为tuple
```
>>> (0, 1, 2, 3, 4, 5)[:3]
(0, 1, 2)
```
前10个数，每两个取一个：
```
>>> L[:10:2]
[0, 2, 4, 6, 8]
```
字符串也可以看做list，同样类似，字符串切片之后仍为字符串
