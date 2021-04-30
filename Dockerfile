FROM crystallang/crystal

COPY . .

EXPOSE 80
EXPOSE 5432

RUN shards install --ignore-crystal-version