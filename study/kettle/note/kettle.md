# `kettle` 入门
## `Spoon`介绍
1. `Kettle` `Spoon`是什么？？？
    * `Kettle`是一款`ETL`工具 `etl`是抽取，转换，装载的过程
    * `Spoon`是一个图形用户界面 它运行运行转换或者任务，其中转换是用`Pan`工具来运行，任务是用`Kitchen`来运行。`Pan`是一个数据转换引擎,他可以执行很多功能，例如：从不同的数据源读取，操作和写入数据。`Kitchen`是一个可以运行利用`XML`或数据资源库描述的任务，通常任务是在规定的时间间隔内用批处理的模式自动运行
2. 安装
    * 运行`Kettle`,首先请在`Pentaho`官网下载`Pentaho Data Integration`,然后请下载`jre`或`jdk`（我们需要Java的运行环境，因为该工具是用java编写并运行于java环境中的）,配置好`java`的运行环境，解压下载的zip包，由于`kettle`是一款绿色版软件，故解压后我们就可以运行`kettle`
3. 运行`Spoon`
    * 在`windows`下点击运行解压目录下的`Spoon.bat`批处理文件。
    * 在`linux`下运行`Spoon.sh`shell脚本文件。
4. 资源库
    * 一个`Kettle`资源库可以包含那些转换信息,这意味着为了数据库资源中加载一个转换,你必须连接相应的资源库
    * 要实现这些,你需要在数据库中定义一个数据库连接,你可以在`Spoon`启动的时候,利用资源库对话框来定义.
    * 资源库文件存储在文件`reposityries.xml`中,它位于你的缺省`home`目录的隐藏目录'.kettle'中.如果是`windows`系统,这个路径就是`c:\Documents and Settings\<username>\.kettle`.
    *  ** :admin用户的缺省密码也是admin.如果你创建了资源库,你可以在'资源库/编辑用户'菜单下面修改缺省密码.
5. 资源库自动登录
    * 你可以设置一下环境变量,来让 Spoon自动登录资源库
    * 环境变量:`KETTLE_REPOSITORY`,`KETTLE_USER`,`KETTLE_PASSWORD`
6. 定义
    1. 转换
        * `value`:`values`是行的一部分,并且是包含以下类型的数据:`Strings`,`floating point Numbers`, `unlimited precision BigNumbers`,`integers`,`dates`或者	`boolean`
        * `row`:一行包含0个或者多个`values`
        * `output stream`:一个output steam是离开一个步骤时的行的堆栈
        * `input stream`:一个input stream是进入一个步骤时行的堆栈
        * `hop`:一个hop代表两个步骤之间的一个或者多个数据流.一个hop总是代表着一个步骤的输出流和一个步骤的输入流.
        * `note`:一个note是一个转换附加文本注释信息
    2. 任务
        * `job entry`是一个任务的一部分,他执行某些内容
        * 
    3. 