# docker build -t hd-hive-pyspark ./hdspark
FROM hd-hive-spark

# pip install --upgrade pyspark
# pip install --upgrade jupyter notebook
# PYSPARK_DRIVER_PYTHON ipython
# PYSPARK_DRIVER_PYTHON_OPTS notebook

# password=1234
RUN yum -y install python36 \
    && curl -O https://bootstrap.pypa.io/get-pip.py \
    && /usr/bin/python3.6 get-pip.py \
    && pip install jupyter notebook \
    && pip install pyspark \
    && jupyter notebook --generate-config \
    && echo "c.NotebookApp.ip='*'" >> /root/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.port =8888" >> /root/.jupyter/jupyter_notebook_config.py \
    && echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py

# jupyter notebook --allow-root