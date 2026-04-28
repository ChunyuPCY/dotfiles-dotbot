# Age (Encrypt and Decrypt "api key")

## Generate private and public key

```shell
age-keygen -o filename
```

## Encrypt key

```shell
echo "your api key" | age -o encrypted.age -r public-key
```

## Decrypt key

```shell
# export some key
export DEEPSEEK_API_KEY=$(age -d -i filename encrypted.age)
```
