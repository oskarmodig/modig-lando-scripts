echo_progress "Update translations"
call_wp language plugin update --all
call_wp language theme update --all
call_wp language core update
