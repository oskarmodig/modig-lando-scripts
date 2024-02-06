#!/bin/bash

echo_progess "Removing WordPress folder"
rm -rf wordpress

echo_progess "Destroying lando app"
lando destroy -y
