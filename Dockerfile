FROM python:3.14-slim@sha256:a2b82f3c48559aa0a8446d9af49826b6e2b2016f4cd2afabfe6013ec53729170 AS build
WORKDIR /build
COPY requirements.txt .
RUN pip wheel --require-hashes --no-cache-dir --wheel-dir=/wheels -r requirements.txt
FROM python:3.14-slim@sha256:a2b82f3c48559aa0a8446d9af49826b6e2b2016f4cd2afabfe6013ec53729170 AS test
WORKDIR /test
COPY requirements*.txt ./
RUN pip install --require-hashes --no-cache-dir -r requirements-dev.txt
COPY app.py .
COPY tests ./tests
COPY ci ./ci
ENV PYTHONDONTWRITEBYTECODE=1
RUN chmod -R a+rX /test
CMD ["sh", "ci/test.sh"]

FROM python:3.14-slim@sha256:a2b82f3c48559aa0a8446d9af49826b6e2b2016f4cd2afabfe6013ec53729170
RUN groupadd -g 10001 app && useradd -u 10001 -g app app
WORKDIR /app
COPY --from=build /wheels /wheels
COPY requirements.txt .
RUN pip install --require-hashes --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && rm -rf /wheels
COPY --chown=app:app --chmod=644 app.py .
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
USER 10001:10001
EXPOSE 8082
CMD ["uvicorn","app:app","--host","0.0.0.0","--port","8082","--no-access-log"]
