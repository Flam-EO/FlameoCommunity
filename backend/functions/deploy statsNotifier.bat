@ECHO OFF
CD statsNotifier
gcloud functions deploy statsNotifier --runtime python311 --trigger-http --project flameoapp-pyme --region europe-central2 --entry-point stats_notifier --env-vars-file .env.yaml
