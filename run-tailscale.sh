#!/usr/bin/env bash

/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
PID=$!

ADVERTISE_ROUTES=${ADVERTISE_ROUTES:-10.0.0.0/8}
until /render/tailscale up --authkey="${TAILSCALE_AUTHKEY}" --hostname="${RENDER_SERVICE_NAME}" --advertise-routes="$ADVERTISE_ROUTES" --accept-routes; do
  sleep 0.1
done
export ALL_PROXY=socks5://localhost:1055/
tailscale_ip=$(/render/tailscale ip)
echo "Tailscale is up at IP ${tailscale_ip}"


socat TCP-LISTEN:${REV_PORT:-8080},fork,reuseaddr,bind=0.0.0.0 SOCKS5:localhost:${REV_HOST}:${REV_PORT:-8080},socksport=1055 &
echo "Proxy to ${REV_HOST}:${REV_PORT:-8080} is up"


wait ${PID}
