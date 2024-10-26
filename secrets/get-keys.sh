#!/usr/bin/env sh

wg genkey | tee client.private | wg pubkey > client.pub
wg genkey | tee server.private | wg pubkey > server.pub
