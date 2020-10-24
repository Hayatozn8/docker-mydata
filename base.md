- 创建环境镜像
    - [env/memo.md](env/memo.md)
- 规范
    - entrypoint、cmd
        - 所有 entrypoint、cmd 用的启动文件保存在以下两个目录
            - /dockerenv/entrypoint/
            - /dockerenv/cmd/
        - 对应的环境变量
            - DOCKERENV = /dockerenv
            - DOCKERENV_ENTRYPOINT = /dockerenv/entrypoint
            - DOCKERENV_CMD = /dockerenv/cmd
        - 所有的启动文件，以`父级目录名/镜像目录名/启动文件名` 进行保存
            - 默认名为 main
        - entrypoint、cmd 的默认启动文件
            - /dockerenv/entrypoint_default_start.sh
            - /dockerenv/cmd_default_start.sh
        - 使用默认的 entrypoint 启动时，如果没有设置 cmd，会自动维持容器运行不会退出
        - 需要的添加到引入的按顺序添加到 `include`
        - 不需要引入的添加到 `exclude`

- 高可用的使用流程
    1. 设置compose
        - hanode/docker-compose_ha.yml
    2. 设置 ha 集群中的 NN，用逗号分割
        - hanode/ha.env
        - 如: `NN=nn01,nn02,nn03`
        - **第一个结点作为主结点**
            - 它必须等待 nn02、nn03 启动后才能启动
            - 它将作为主启动结点，来启动整个 ha 集群
    3. 修改 hadoop 的配置，添加多个 NN 的配置
        - hanode/haconf/hdfs-site.xml
        - hanode/haconf/core-site.xml
    4. 修改 zookeeper 的网络配置
        - hanode/haconf/hdfs-site.xml
        - 如
            ```sh
            server.1=nn01:2888:3888
            server.2=nn02:2888:3888
            server.3=nn03:2888:3888
            ```

- 其他问题
    - hive -mysql 的初始化有时间问题，仍然需要手动初始化
        - schematool -dbType mysql -initSchema
    - hive mysql 版本没有参数化
    - nginx 的上下游ip替换
        - 只能访问 50070，8088
