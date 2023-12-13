FROM python:alpine3.7
COPY . /app
WORKDIR /app
RUN pip3 install flask
RUN pip install Flask-PyMongo
ENV PORT 5000
EXPOSE 5000
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]
