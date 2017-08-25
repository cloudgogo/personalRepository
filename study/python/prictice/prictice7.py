# -*- coding: utf-8 -*-
'''

'''
from functools import reduce

def qiuji(x,y):
	return x*y
def prod(L):
	return reduce(qiuji, L)

print('3 * 5 * 7 * 9 =', prod([3, 5, 7, 9]))

'''
利用map和reduce编写一个str2float函数，把字符串'123.456'转换成浮点数123.456：
'''


