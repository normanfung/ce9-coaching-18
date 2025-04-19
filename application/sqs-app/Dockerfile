# Using latest base image  from DockerHub
FROM python:latest

#Creating working directory inside container#
WORKDIR /app

#Copy source code into working directory inside container
COPY . /app

#Install flask inside container
RUN pip install -r requirements.txt

#Expose container port
EXPOSE 5002

#Start flask app
CMD ["python", "flask_s3_app.py"]