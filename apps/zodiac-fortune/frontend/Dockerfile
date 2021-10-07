# Not for production use
FROM python:alpine3.7
ENV PORT 80
EXPOSE ${PORT}
ENV FORTUNE_API http://localhost:3000
WORKDIR /app 
COPY . .
RUN pip install -r requirements.txt
ENV FLASK_APP app
ENTRYPOINT flask run --host=0.0.0.0 --port=${PORT}