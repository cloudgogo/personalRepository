# git命令
## git config 
git config 进行git配置    
git config global user.name "your name"    
git config global user.email  "your email address"    
## git init 
将当前目录初始化为git仓库(repository)，该目录下生成.git文件
## git add
将当前文件添加至git仓库中（之后进行重复的提交操作时依然需要此命令将修改文件添加至git仓库）
## git commit -m <注释>
将文件提交至git库中，注释在此命令中最好必选 -m（message） 
## git diff 
比较文件与库中文件的不同，查看修改的东西
## git status 
查看git的当前状态，（当前库是否有未提交文件等）
## git log
查看git历史版本信息，commitid（版本号）为各版本id    
git log --pretty=oneline 切换显示方式为单行
## git reflog 
查看历史操作（可以跟踪到commitid）
## git reset
* git reset --hard <commitid>          
  将当前版本（HEAD指向）置为commitid所对应的版本    
* git reset --hard HEAD^    
  将当前版本指向上一个版本    
* git reset --hard HEAD^^    
  将当前版本指向上上个版本
* git reset --hard HEAD~100    
  将当前版本指向前100个版本

2017-08-21 14:40
-----------------
## git add,git commit 与工作区，暂存区，和库
之前在git init时创建git库时在目录下发现了`.get`文件夹 ，该文件夹即为库，库中在一开始便包含一个暂存区，工作区则是git init下的目录，Git的版本库里存了很多东西，其中最重要的就是称为stage（或者叫index）的暂存区，还有Git为我们自动创建的第一个分支master，以及指向master的一个指针叫HEAD。

## git checkout -- <文件名>
git checkout -- 后加文件名，可以将文件恢复至暂存区或分支最新的状态，`--`不可以不加。否则将创建分支

## git rm 
将库中的文件进行rm  -rf 使用方法相同

## rm 文件及选择

```
graph TD
S(开始)-->A
A[在工作区用rm删除文件]-->B{是否确实要删除}
B-->|的确要删除|C[执行git rm 操作]
B-->|不应该删除|D[执行git checkout --< 文件名>的命令,将文件还原]
C-->E[执行git commit 操作]
E-->F[执行git status 命令将无错误]
D-->F
F-->G(结束)
F-->|需要回退之前未删除的版本|K[执行git reset --hard 命令恢复]
K-->G
```

