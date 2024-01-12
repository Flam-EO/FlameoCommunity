@ECHO OFF
IF "%~1" == "--pro" GOTO PRO_CHECK1
GOTO TEST_DEPLOY

:PRO_CHECK1
SET /P CHECK1=You are going to deploy in production, continue? (yes/no):
IF /I "%CHECK1%" == "yes" GOTO PRO_CHECK2
EXIT /B

:PRO_CHECK2
SET /P CHECK2=To continue write 'deploy to production':
IF /I "%CHECK2%" == "deploy to production" GOTO PRO_DEPLOY
EXIT /B

:PRO_DEPLOY
CD fidelityEmailer
gcloud functions deploy fidelityEmailer --runtime python311 --trigger-http --project flameoapp-pyme --region europe-central2 --entry-point fidelity_emailer --env-vars-file .env.yaml
GOTO END

:TEST_DEPLOY
CD fidelityEmailer
gcloud functions deploy testt_fidelityEmailer --runtime python311 --trigger-http --project flameoapp-pyme --region europe-central2 --entry-point fidelity_emailer --env-vars-file .env.test.yaml

:END