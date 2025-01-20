# p5-valkey-benchmark

## 概要
このリポジトリでは、PerlでFFI（Foreign Function Interface）を利用して、ValkeyというCライブラリと連携するクライアントを構築しています。以下のモジュールとスクリプトが含まれています。

- `lib/Valkey/FFI.pm`: Cライブラリの`valkey`と連携するためのFFIモジュール。
- `lib/Valkey/Client.pm`: `Valkey::FFI`を使用してValkeyサーバーと通信するクライアントモジュール。
- `t/01-basic.t`: クライアントモジュールの基本操作が正しく動作するかをテストするスクリプト。
- `benchmark/benchmark.pl`: `Benchmark`モジュールを使用して、`Redis`、`Redis::Fast`、および`Valkey::Client`のパフォーマンスを比較するベンチマークスクリプト。

## 使用方法
### Docker Compose
Docker Composeを使用して、Valkeyサーバーとアプリケーション環境をセットアップします。

```yaml
services:
  valkey:
    image: valkey/valkey:8
    cpus: 4
    mem_limit: 1g
    ports:
      - "6379:6379"
  app:
    build:
      context: .
      dockerfile: Dockerfile
    working_dir: /app
    volumes:
      - .:/app
    depends_on:
      - valkey
```
