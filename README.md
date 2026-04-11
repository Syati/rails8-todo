# rails8-todo

## 開発環境

- Ruby / Rails 8
- PostgreSQL
- Docker Compose

## ローカル起動

DB のみ起動（Rails アプリはローカル実行する場合）:

```zsh
make up/service
```

全サービス起動（DB + アプリ）:

```zsh
make up
```

`docker-compose.yml` では `app.build.dockerfile: ./docker/app/Dockerfile` を参照しています。

## `RAILS_ENV=develop` でのビルド

`docker/app/Dockerfile` は `RAILS_ENV=develop` を受け取り、内部で `development` 相当として扱えるようにしています。

```zsh
docker build -f docker/app/Dockerfile --build-arg RAILS_ENV=develop -t rails8_todo:develop .
```

## DB準備（アプリコンテナ内）

```zsh
docker compose run --rm app bin/rails db:prepare
```
