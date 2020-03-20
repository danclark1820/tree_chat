#!/bin/sh

release_ctl eval --mfa "TreeChat.ReleaseTasks.migrate/1" --argv -- "$@"
