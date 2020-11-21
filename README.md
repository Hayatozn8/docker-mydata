<span id="catalog"></span>

<span style='font-size:18px'>目录<span>

- [工程结构](#工程结构)
- [构建与启动](#构建与启动)
    - [构建与启动的指令](#构建与启动的指令)
        - [build.sh---编译镜像](#build.sh---编译镜像)
        - [compose.sh---启动compose](#compose.sh---启动compose)
        - [mkimg.sh---创建镜像模板](#mkimg.sh---创建镜像模板)
    - [镜像编译](#镜像编译)
        - [编译流程](#编译流程)
        - [默认的构建顺序](#默认的构建顺序)
    - [启动compose](#启动compose)
- [开发](#开发)
    - [设置镜像的entrypoint](#设置镜像的entrypoint)
        - [基础镜像中的entrypoint启动器](#基础镜像中的entrypoint启动器)
        - [设置自定义镜像中的entrypoint](#设置自定义镜像中的entrypoint)
    - [镜像开发](#镜像开发)
    - CMD的设置
- [各镜像中提供的通用工具](#各镜像中提供的通用工具)
    - [env-common](#env-common)
        - [entrypoint启动器](#entrypoint启动器)
        - [env2conf.sh---环境变量写入配置文件](#env2conf.sh---环境变量写入配置文件)
    - [env-ssh](#env-ssh)
        - [createSSHConnect.sh---创建ssh连接](#createSSHConnect.sh---创建ssh连接)

- [启动默认提供的compose](#启动默认提供的compose)
    - [zknode与zookeeper集群](#zknode与zookeeper集群)
    - [普通hadoop集群](#普通hadoop集群)
    - [高可用hadoop集群](#高可用hadoop集群)
    - [hive+普通hadoop集群](#hive+普通hadoop集群)
    - [spark+hive+普通hadoop集群](#spark+hive+普通hadoop集群)
- [默认架构图](#默认架构图)
- [](#)

# 工程结构
[top](#catalog)

|目录/文件|功能|
|-|-|
|img|镜像文件目录|
|bin|指令文件|
|compose|保存docker-compose，一个目录一个docker-compose|
|resource|资源目录，保存各镜像所需的的安装包|
|conf|配置|
|design|整体设计|


# 构建与启动
## 构建与启动的指令
### build.sh---编译镜像
[top](#catalog)
- 功能: 读取镜像列表，并编译镜像
- 使用方法
    ```text
    Usage:
        build.sh [-f imgListFilePath] [-i imgID]

    Build image by imgageID list file or imageID.
    conf/imglist is used by default

    Options:
        -f imgListFilePath          read list of imageID from <imgListFilePath> and build every image
        -i imageID                  build image by imageID
    ```

### compose.sh---启动compose
[top](#catalog)
- 功能: 启动 `compose/` 目录下的 `docker-compose`
- 使用方法
    ```text
    compose.sh compose/<composeName> [param of docker-compose]
    ```

### mkimg.sh---创建镜像模板
[top](#catalog)
- 功能: 在 `img` 目录下创建镜像模板
- 使用方法
    ```text
    mkimg.sh <imgID>
    ```
- 执行后会自动创建以下内容
    ```
    - entrypoint
        - entrypoint/main.sh
    - add
    - Dockerfile
    ```

## 镜像编译
### 编译流程
[top](#catalog)
1. 准备docker编译环境
    - 需要提前拉取基础镜像
    - 需要有足够的内存
2. 需要准备安装包，并放在 `resource` 目录下
3. 设置编译目标
    - 通过 镜像ID 列表编译
        - 需要创建 镜像ID 列表文件
        - 默认需要将 镜像ID 列表写入 `conf/imglist`，也可以自定义
        - 编译时，将按照列表顺序进行编译
    - 编译指定的**某个**镜像
4. 启动编译
    - 调用编译指令
        - 通过 镜像ID 列表编译
            ```sh
            sh bin/build.sh -f xxx
            sh bin/build.sh # use conf/imglist
            ```
        - 编译指定的**某个**镜像
            ```sh
            sh bin/build.sh -n imgID
            ```
    - 编译时，自动执行的操作
        1. 将各个镜像目录下的: `Dockerfile`、`entrypoint/`、`add/` 拷贝到 `resource/`
        2. 根据 `Dockerfile` 生成 `.dockerignore`
        3. 执行编译
        4. 编译结束后，将 `Dockerfile`、`entrypoint/`、`add/`、`resource/`


### 默认的构建顺序
[top](#catalog)
- 参考
    - bin/build.sh
- 基础环境部分的构建顺序
    ```
    env/common
    env/ssh
    env/jdk8/
    env/zknode
    env/hanode
    ```
- 其他内容的构建
    - nginx，独立构建
        ```
        hdnginx
        ```
    - hive
        ```
        env/hanode
        hive/base
        ```
    - spark
        ```
        hive/base
        hdspark/hd-hive-spark
        ```
    - kafka
        ```
        kafka-base/
        kafka-eagle-node/
        kafka-eagle-webui/
        ```

## 启动compose
[top](#catalog)
- 所有 `docker-compose.yml` 统一保存到 `compose/<composeName>/docker-compose.yml`
- 操作方法
    ```shell
    sh bin/compose.sh <composeName> up -d
    sh bin/compose.sh <composeName> ps
    sh bin/compose.sh <composeName> down
    ```

# 开发

## 设置镜像的entrypoint
### 基础镜像中的entrypoint启动器
[top](#catalog)

- 所在位置
    - `evn-common:/dockerenv/entrypoint_default_run.sh`

- 功能
    - 依照 `include`、`exclude`，依次执行各个镜像的 entrypoint

- 默认情况下，所有 evn-common 为基础的镜像的 entrypoint 全部由该启动器负责启动

- 启动器的启动方式
    - exec 形式启动，**没有任何参数**
        ```dockerfile
        ENTRYPOINT [ "/dockerenv/entrypoint_default_run.sh" ]
        ```

- 执行时使用的环境变量及功能
    |环境变量|路径|功能|
    |-|-|-|
    |DOCKERENV              |/dockerenv/                    |保存与docker本身相关的文件|
    |DOCKERENV_ENTRYPOINT   |/dockerenv/entrypoint/         |保存各个镜像的entrypoint文件<br>需要以`<imgID>/main.sh`的格式保存启动器需要执行的内容|
    |ENTRYPOINT_INCLUDE     |/dockerenv/entrypoint/include  |保存需要执行的imgID列表<br>启动器会按照顺序执行各个 `imgID` 下的 `main.sh`<br>|
    |ENTRYPOINT_EXCLUDE     |/dockerenv/entrypoint/exclude  |保存需要从 `include` 文件中**排除**的 `imgID`|
    ```

- 启动器的执行内容
    1. 读取 `/dockerenv/entrypoint/exclude` 中的 `imgID`，创建**排除**列表
    2. 读取 `/dockerenv/entrypoint/include` 中的 `imgID`，创建需要执行的 `imgID` 列表
        - 创建时，会忽略 1 中的排除列表
    3. 按照 `imgID` 的顺序，依次调用 `/dockerenv/entrypoint/<imgID>/main.sh`
    4. 调用结束后，检查 `CMD` 指令的参数
    5. 如果没有 `CMD` 参数，将会默认执行 `tail -f /dev/null`，使容器持续运行
    6. 如果有 `CMD` 参数，会执行 `CMD` 指令

### 设置自定义镜像中的entrypoint
[top](#catalog)
- 开发镜像需要使用 entrypoint
    - 需要保存在 `img/<imgID>/entrypoint/main.sh`
    - `main.sh` 不应该有任何的参数

- 在 Dockerfile 中将 `main.sh` 添加到容器中
    ```dockerfile
    # 1. 添加到容器
    ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/<imgID>/main.sh

    # 2. 设置权限，并将 imgID 添加到 include
    RUN chmod a+x $DOCKERENV_ENTRYPOINT/zknode/main.sh \
        && echo '<imgID>' >> $ENTRYPOINT_INCLUDE

    # 3. 如果需要关闭某个底层容器的 entrypoint，
    #    需要将目标容器的 imgID 添加到 exclude
    RUN echo '<otherImgID>' >> $ENTRYPOINT_EXCLUDE
    ```

- 如果 `img/<imgID>/entrypoint/main.sh` 中还有其他的辅助 shell 或文件，需要在 Dockerfile 中手动设置 `ADD` 或 `COPY` 指令

## 镜像开发
[top](#catalog)
- 一个镜像一个目录
- 目录名 = 镜像ID
- 用于编译的目录和文件
    - `Dockerfile`
    - `entrypoint/`，保存当前镜像的entrypoint文件
    - `add/`，保存需要通过 `ADD`、`COPY` 指令添加到镜像中的文件
- **用于编译的目录和文件**，在编译时，会被拷贝到 `resource` 目录下进行编译
- 除了用于编译的内容，也可以包含其他内容，不会影响编译
- 编译镜像时需要的安装包，需要手动放到 `resource/` 目录下
    - 只放到镜像目录下不会生效

## CMD的设置
[top](#catalog)
- TODO


# 各镜像中提供的通用工具
## env-common
### entrypoint启动器
[top](#catalog)
- 参考
    - [基础镜像中的entrypoint启动器](#基础镜像中的entrypoint启动器)

### env2conf.sh---环境变量写入配置文件
[top](#catalog)
- 保存位置
    - 开发目录
        - [img/env-common/add/env2conf/env2conf.sh](img/env-common/add/env2conf/env2conf.sh)

    - 容器内
        - /usr/bin/env2conf.sh

- 功能
    - 可以读取**指定前缀的**环境变量，将环境变量转换为: `xx.yy.zz` 的形式，并将转换后的名字和变量值组合成配置内容写入配置文件
        - 读取时会自动在前缀后面添加 `_`，所以前缀最后的末尾最好不要有 `_`，否则可能影响配置的设置

- 支持的配置文件类型
    - xml 类型
        - xml 文件
    - txt 类型
        - properties、ini 等以 `=` 为分割符，分割属性和属性值的配置文件
        - `=` 以外的字符作分割符的文件，需要在指令中手动设置分隔符

- 使用方法
    ```text
    Usage:
        env2conf.sh -e envPrefix -c confPath [options]
        -e envPrefix  | --envPrefix=envPrefix   evn startkey
        -c confPath   | --conf=confPath         config path

    Options:
        -i include    | --include=include       [list] only use the element of include list
        -x exclude    | --exclude=exclude       [list] will not write to config
        -t [txt,xml]  | --type=[txt,xml]        type of conf, default type is [txt]
        -d delimiter  | --delimiter=delimiter   delimiter of confkey confValue, default type is [=]
                    | --xmlTemplate=...       when -t/--type is xml, must set xmlTemplate !!!
                                                example:
                                                    <property><name>@key@</name><value>@value@</value></property>
                                                @key@, @value@ will be repalced by env
                    | --xmlAppendTo=...       when -t/--type is xml, must set xmlAppendTo !!!
                                                example:
                                                    configuration
                                                after replaced key and value of xmlTemplate,
                                                will append the replaced string to config before the tag
                                                set with xmlAppendTo
                                                append example:
                                                    <configuration>
                                                        <property><name>xxx</name><value>yyy</value></property>
                                                    </configuration>
    ```

- 示例
    - 设置 txt 型文件
        ```sh
        # 读取
        env2conf.sh -e ZOO \
                    -t txt
                    -c $ZOOKEEPER_HOME/conf/zoo.cfg \
                    -x "my.id"
        ```
    - 设置 xml 型文件
        - TODO

## env-ssh
### createSSHConnect.sh---创建ssh连接
[top](#catalog)
- 保存位置
    - 开发目录
        - [img/env-ssh/add/createSSHConnect.sh](img/env-ssh/add/createSSHConnect.sh)

    - 容器内
        - /usr/bin/createSSHConnect.sh

- 功能
    - 与指定的 `user@IP`，或 `user@hostname` 创建 ssh 连接

- 使用方法
    ```sh
    createSSHConnect.sh "user@IP"
    createSSHConnect.sh "user@hostname"
    ```

- TODO
    - 密码设置

---------------------------------------



# 启动默认提供的compose
## zknode与zookeeper集群
[top](#catalog)
- 镜像 zknode
    - environment

        |环境变量|功能|
        |-|-|
        |`ZOO_MY_ID`|设置 `myid` 中的数值，容器启动后会根据环境变量自动设置<br><span style='color:red'>如果想要容器自动启动zookeeper，必须设置该环境变量</span>|
        |`ZOO_SERVERS`|整个zk集群中的各节点的ip与通信端口<br>该环境变量<span style='color:red'>会覆盖配置文件中的内容</span>|

    - volumes

        |数据卷路径|功能|
        |-|-|
        |`/zkconfig`|zk集群配置文件<br>需要注意不能和 `ZOO_SERVERS` 同时使用，否则会被 `ZOO_SERVERS` 覆盖|

- 启动操作
    - [img/env/zknode/entrypoint/main.sh](img/env/zknode/entrypoint/main.sh)

- 已经包含 zknode 的镜像
    - hanode 及其派生的其他镜像

- 只包含zk集群的启动配置

    |启动配置路径|功能|
    |-|-|
    |[conf/szkcluster/docker-compose.yml](conf/szkcluster/docker-compose.yml)|不使用配置文件的简易集群启动，3 个 节点|
    |[conf/zkcluster/docker-compose.yml](conf/zkcluster/docker-compose.yml)|提供默认的配置文件，通过配置文件来启动集群，3 个 节点|

## 普通hadoop集群
[top](#catalog)
- 集群操作
    ```shell
    sh sbin/compose.sh hdcluster up -d
    sh sbin/compose.sh hdcluster ps
    sh sbin/compose.sh hdcluster down
    ```
- TODO

## 高可用hadoop集群
[top](#catalog)
- 集群操作
    ```shell
    sh sbin/compose.sh hacluster up -d
    sh sbin/compose.sh hacluster ps
    sh sbin/compose.sh hacluster down
    ```
- TODO

## hive+普通hadoop集群
[top](#catalog)
- TODO
- 使用hive之前，需要手动初始化
    ```sh
    schematool -dbType mysql -initSchema
    ```

## spark+hive+普通hadoop集群
[top](#catalog)
- TODO


# 默认架构图
[top](#catalog)
- ![架构图](design/structure.png)


# python部分的编译与启动
1. 需要先编译基础部分
    ```sh
    sh build.sh
    ```
2. 再编译pyspark
    ```sh
    sh buildpy.sh
    ```
3. 启动
    ```sh
    sh clusterpy.sh
    ```
