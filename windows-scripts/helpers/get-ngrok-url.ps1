param(
    [String]$url
)
(Invoke-RestMethod http://localhost:4040/api/tunnels).tunnels |
    Where-Object { $_.config.addr -eq $url } |
    Select-Object -ExpandProperty public_url -First 1
