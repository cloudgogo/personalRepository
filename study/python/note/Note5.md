#循环
##`for`...`in`循环
* 依次把`list`或`tuple`中的每个元素迭代出来，看例子：
```
names = ['Michael', 'Bob', 'Tracy']
for name in names:
    print(name)
```
如果要计算1-100的整数之和，从1写到100有点困难，幸好Python提供一个`range()`函数，可以生成一个整数序列，再通过`list()`函数可以转换为`list`。比如range(5)生成的序列是从0开始小于5的整数：
```
sum = 0
for x in range(101):
    sum = sum + x
print(sum)
```
##break和continue
* 与java相同，结束循环和跳出当前这次循环进行下一次
注意的就是如果应该在Java中是{}内的内容，就缩进
```python
n = 1
while n <= 100:
    if n > 10: # 当n = 11时，条件满足，执行break语句
        break # break语句会结束当前循环
    print(n)
    n = n + 1
print('END')
```
```python
n = 0
while n < 10:
    n = n + 1
    if n % 2 == 0: # 如果n是偶数，执行continue语句
        continue # continue语句会直接继续下一轮循环，后续的print()语句不会执行
    print(n)
```

