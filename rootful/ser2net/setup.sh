#!/bin/bash
set -e

firewall-cmd --add-port=2000/tcp --permanent
firewall-cmd --reload
