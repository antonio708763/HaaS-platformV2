#!/usr/bin/env bash
set -euo pipefail

echo "=== HaaS Network Validation (Tier-1 Baseline) ==="
echo

echo "[1/6] Testing default gateway..."
ping -c 2 192.168.110.1 || true
echo

echo "[2/6] Testing public internet reachability..."
ping -c 2 8.8.8.8 || true
echo

echo "[3/6] Testing DNS resolution through system resolver..."
getent hosts google.com || true
echo

echo "[4/6] Testing AdGuard primary..."
curl -I --max-time 5 http://192.168.20.53:3000 || true
echo

echo "[5/6] Testing AdGuard secondary..."
curl -I --max-time 5 http://192.168.20.54:3000 || true
echo

echo "[6/6] Testing Proxmox..."
curl -kI --max-time 5 https://192.168.20.10:8006 || true
echo

echo "Validation run complete."
