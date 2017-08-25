#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#file
'''
匿名函数lambda
'''
#map(),range()都是方法，需要用list()列表生成器生成list
print(list(map(lambda x:x*x,list(range(10)))))
print(list(map(lambda x:x*x,[x**x for x in range(10) if x>1]))[1:5])
print(map(lambda x:x*x,list(range(10))))
print([x*x for x in range(1,10)])

print(list(range(10)))
#匿名函数也是变量
x=lambda x:x*x

m=list(map(x,[1,2,3]))
print(m)

print([x for x in range(10) if x%2==0])
def bulid(x,y):
	return lambda x,y: x * x + y * y
print([x for x in range(10) if x%2==0])
from functools import reduce
#相当于多层函数调用，这样就无法使用了
print(reduce(bulid,[x for x in range(10) if x%2==0]))
print(reduce(lambda x,y: x * x + y * y,[x for x in range(10) if x%2==0]))
def bulid(x,y):
	return  x * x + y * y
print(reduce(bulid,[x for x in range(10) if x%2==0]))
'''
filter
map用于对列表对象进行计算
而filter则用于对列表进行筛选
'''
def is_odd(n):
	return n%2==0
l=list(filter(is_odd, list(range(100))))
print (l)

print("abcde" and "   abcde   ".strip())
#用filter把空的字符串去掉
'''
def not_empty(s):
    return s and s.strip()

s=list(filter(not_empty, ['A', '', 'B', None, 'C', '  ']))
print  (s)

def not_empty(s):
	return s and s.strip()
'''
'''
???出错了???
原因
关键是理解”s and s.strip()“ 这个表达式的值。Python语法是这么运行的：
如果s is None，那么s会被判断为False。而False不管和什么做and，结果都是False，所以不需要看and后面的表达式，直接返回s（注意不是返回False）。
如果s is not None，那么s会被判断为True，而True不管和什么and都返回后一项。于是就返回了s.strip()。
s.strip()和s 本身就会报错
def not_empty(s):
	a=False
	if len(s.strip())>0:
		a=True
	return a

l= list(filter(not_empty, ['A', '', 'B', None, 'C', '  ']))
print(l)
'''
def not_empty(s):
    return s and s.strip()

s=list(filter(not_empty, ['   A', '', 'B   ', None, 'C', '  ']))
print(s)

s=sorted([11,-2,-3,6,10,5,7,2])
print(s)

s=sorted([x**x for x in range(5)])
print(s)
s=[x*y for x in range(10) for y in range(5) if x*y>0 and x*y<28]
print(s)
s=sorted(s)
print(s)