FROM python:latest
COPY ./init/preprocess.py .
CMD ["preprocess.py"]
ENTRYPOINT ["python"]