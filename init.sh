screen -dmS supervisor supervisord -c /app/supervisord.conf

# Test
sleep 15
./screenshot-login.sh

# SLeep 1000s
sleep 1000
