# Not for production use
FROM python:alpine3.7
EXPOSE 3000
ENV FORTUNE_API http://localhost:3000
WORKDIR /app 
COPY . .
RUN pip install -r requirements.txt
ENV FLASK_APP app
ENTRYPOINT [ "flask", "run", "--host=0.0.0.0", "--port=3000"]