FROM python:3.8.13-slim-buster

WORKDIR /

COPY . .

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "--timeout", "90", "--log-level", "debug", "Foodimg2Ing:app"]