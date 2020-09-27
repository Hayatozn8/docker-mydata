# 开发内容及问题参考
- [base.md](base.md)

# 编译前提
1. 需要准备jar，并放在个目录下，包括
    - env/hdnode/hadoop-2.7.2.tar.gz
    - env/jdk8/jdk-8u144-linux-x64.tar.gz
    - hdspark/spark-3.0.1-bin-without-hadoop.tgz
    - hive/base/apache-hive-2.3.7-bin.tar.gz
    - hive/base/mysql-connector-java-8.0.19.tar.gz
2. 需要提前拉取 centos、mysql、nginx的镜像
3. 至少需要 4 G 以上的内存

# 编译与启动
- 编译
    ```sh
    sh build.sh
    ```
- 启动
    ```sh
    sh cluster.sh up -d
    ```
- 检查状态
    ```sh
    sh cluster.sh ps
    ```
- 卸载
    ```sh
    sh cluster.sh down
    ```