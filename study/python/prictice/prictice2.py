#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
小明身高1.75，体重80.5kg。请根据BMI公式（体重除以身高的平方）帮小明计算他的BMI指数，并根据BMI指数：

低于18.5：过轻
18.5-25：正常
25-28：过重
28-32：肥胖
高于32：严重肥胖
用if-elif判断并打印结果：
'''
print('请输入身高')
hight=input()
print('请输入体重')
weight=input()
h=float(hight)
w=float(weight)
bim=w/pow(h,2)
if bim<18.5:
	print('体重过轻')
elif bim>=18.5&bim<25:
	print('正常')
elif bim>=25&bim<28:
	print('体重过重')
elif bim>=28&bim<32:
	print('肥胖')
elif bim>=32:
	print('严重肥胖')
