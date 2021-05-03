FROM crystallang/crystal

COPY . .

EXPOSE 80

RUN shards install --ignore-crystal-version