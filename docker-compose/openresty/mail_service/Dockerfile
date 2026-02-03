FROM docker.1ms.run/python:3.9-slim
RUN pip install flask -i https://pypi.tuna.tsinghua.edu.cn/simple
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]