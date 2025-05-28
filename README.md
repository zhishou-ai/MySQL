# MySQL
主要介绍怎样部署聊天软件后端的MySQL数据库，包括MySQL的下载以及数据库建表

首先打开官网https://downloads.mysql.com/archives/community
下载9.2版本，然后找到mysql的安装路径，一般都是C:\Program Files\MySQL\MySQL Server 9.2\bin，然后将这个路径添加进PATH系统变量，添加进系统变量的步骤是：1，打开“编辑系统环境变量”这个选项，然后点“环境变量”，然后选中“PATH”变量选择编辑，然后新建，将刚才的地址粘贴进去，保存就行了。
然后是建好服务器所需要的表，首先找到这里的“zhishou_chat_setup.sql”然后打开存储这个文件的文件夹，然后在文件夹里打开cmd命令行，然后输入“mysql -u root -p < zhishou_chat_setup.sql”就可以了。
