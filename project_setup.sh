#!/usr/bin/env bash

echo "Installing vcshooks script..."

flutter pub global activate vcshooks 1.0.0-nullsafety.0

flutter pub global run vcshooks --project-type flutter .
