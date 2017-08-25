#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r'''
小明的成绩从去年的72分提升到了今年的85分，
请计算小明成绩提升的百分点，并用字符串格式化显示出'xx.x%'，
只保留小数点后1位

'''
s1=72
s2=85
upper=(s2-s1)/s1
print(upper)
print('小明的成绩去年为:',s1,',今年的成绩为:',s2,'成绩提升了:%.2f' %upper)
print('小明的成绩去年为:%0d,今年的成绩为:%0d,成绩提升了:%.2f'  %(s1,s2,upper))
time.sleep() 