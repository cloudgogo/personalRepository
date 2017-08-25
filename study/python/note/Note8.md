#函数的参数
##位置参数
```
def power(x):
    return x * x
```
##默认参数
```
def power(x, n=2):
    s = 1
    while n > 0:
        n = n - 1
        s = s * x
    return s
```
##可变参数
```
def calc(*numbers):
    sum = 0
    for n in numbers:
        sum = sum + n * n
    return sum

>>> nums = [1, 2, 3]
>>> calc(*nums)
```
##关键字参数
```
>>> extra = {'city': 'Beijing', 'job': 'Engineer'}
>>> person('Jack', 24, **extra)
name: Jack age: 24 other: {'city': 'Beijing', 'job': 'Engineer'}
```
