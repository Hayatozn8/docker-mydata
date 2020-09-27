# docker build -t hd-hive-pyspark ./hdspark
FROM hd-hive-spark

# pip install --upgrade pyspark
# pip install --upgrade jupyter notebook
# PYSPARK_DRIVER_PYTHON ipython
# PYSPARK_DRIVER_PYTHON_OPTS notebook

RUN yum -y install python36 \
    && curl -O https://bootstrap.pypa.io/get-pip.py \
    && /usr/bin/python3.6 get-pip.py \
    && pip install jupyter notebook \
    && pip install pyspark \
    && jupyter notebook --generate-config \
    && echo "c.NotebookApp.ip='*'" >> /root/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.port =8888" >> /root/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py \
    && echo 'hive' >> $DOCKERENV_ENTRYPOINT/exclude

ENV PYSPARK_PYTHON=python3

# 引入ssh 的 main.sh
ADD entrypoint/main.sh $DOCKERENV_ENTRYPOINT/pyspark/main.sh
RUN chmod a+x $DOCKERENV_ENTRYPOINT/pyspark/main.sh \
    && echo 'pyspark' >> $DOCKERENV_ENTRYPOINT/include