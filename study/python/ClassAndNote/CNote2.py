'''
返回函数
'''
#回顾函数参数：主要回顾的是可变参数，关键字参数和命名关键字参数(位置参数和默认参数在此不进行回顾)
#*args 可变参数
def sum(*num):
	sum=0
	for n in num:
		sum+=n
	return sum
print(sum(1,3,4,3))
#加*号将会把tuple和list转换为适合的可变参数类型
print(sum(*[x*2 for x in range(15)]))
