@ECHO OFF
CD newCompaniesWatchDog
gcloud functions deploy newCompaniesWatchDog --runtime python311 --trigger-event providers/cloud.firestore/eventTypes/document.create --trigger-resource "projects/flameoapp-pyme/databases/(default)/documents/companies/{companyID}" --project flameoapp-pyme --region europe-central2 --entry-point company_creator --env-vars-file .env.yaml
