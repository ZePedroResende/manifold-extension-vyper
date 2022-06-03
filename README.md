# foundry-vyper-template

template for testing vyper with foundry.

### Setup

```sh
git clone https://github.com/ZePedroResende/foundry-vyper-template.git
cd foundry-vyper-template
cp envrc.sample .envrc
```
### Compile vyper
```sh
brownie compile --all
```

### Run Tests

```sh
forge test
```

### Update Gas Snapshots

```sh
forge snapshot
```
