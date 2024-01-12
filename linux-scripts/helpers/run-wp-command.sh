#!/bin/bash

call_wp() {
    lando wp "$@" --path=wordpress
}
