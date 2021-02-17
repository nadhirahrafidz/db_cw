FROM python:latest
RUN pip install --upgrade pip
RUN pip install pandas
COPY ./init/preprocess.py .
CMD ["preprocess.py"]
ENTRYPOINT ["python"]