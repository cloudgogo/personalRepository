#!/usr/bin/env python3
# -*- coding: utf-8 -*-
classmate = ["a", 1, 1.02]
print("%s,%d,%f" % (classmate[0], classmate[1], classmate[2]))
print("%f" % classmate[-1])
# 求长度
len = len(classmate)
print("长度为%d" % len)
# 追加元素
classmate.append('adam')
print(classmate)
classmate.insert(0, 'lalla')
print(classmate)
son = ['a', 'b', 'c']
classmate.insert(1, son)
print(classmate)
print(classmate[1][1])
print(son[1])
classmate.pop()
print(classmate)
classmate.pop(0)
print(classmate)


t = ('a', 'b', classmate)
print(t)
t = (1)
'''
tuple中的元素只有一个的话需要加,表明其是一个tuple
'''
print(t)
t = (1,)
print(t)
