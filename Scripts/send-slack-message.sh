# Configure webhook url here: https://api.slack.com/apps/A02BYNXJG5D/incoming-webhooks?

curl -s -X POST -H 'Content-type: application/json' \
 --data "{ \"attachments\": [ { \"color\": \"#2eb886\", \"blocks\": [ { \"type\": \"section\", \"text\": { \"type\": \"mrkdwn\", \"text\": \"$1\" } }, { \"type\": \"section\", \"text\": { \"type\": \"mrkdwn\", \"text\": \"$2\" } } ] } ] }" \
 https://hooks.slack.com/services/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 > /dev/null

if [ $? -eq 0 ]; then
   echo "slack message sent"
else
   echo "failed to send slack message"
fi
