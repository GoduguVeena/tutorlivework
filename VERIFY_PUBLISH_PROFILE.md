# ?? VERIFY YOUR PUBLISH PROFILE SECRET

## ? Current Error:
```
Deployment Failed, Error: Publish profile is invalid for app-name and slot-name provided. 
Provide correct publish profile credentials for app.
```

## ?? What This Means:
The publish profile in your GitHub secret doesn't match the web app name in Azure.

---

## ? **SOLUTION: Re-download and Update Publish Profile**

The publish profile you added earlier might be outdated or for a different app. Let's get the correct one:

### **Step 1: Download Fresh Publish Profile from Azure**

1. Go to Azure Portal: https://portal.azure.com
2. Search for **"TutorLive"** in the search bar
3. Click on your web app (should show as **TutorLive**)
4. At the top, click **"Get publish profile"** button
5. A file will download (e.g., `TutorLive.PublishSettings`)
6. Open it with Notepad
7. **Copy the ENTIRE content** (Ctrl+A, then Ctrl+C)

### **Step 2: Update the GitHub Secret**

1. Go to: https://github.com/shahid-afrid/tutorlivev1/settings/secrets/actions
2. Find `AZURE_WEBAPP_PUBLISH_PROFILE` in the list
3. Click the **pencil icon (Update)** next to it
4. Delete the old content
5. **Paste the new content** from the file you just downloaded
6. Click **"Update secret"**

---

## ?? **Verify the Publish Profile Contains:**

When you open the `.PublishSettings` file, it should look like this:

```xml
<publishData>
  <publishProfile 
    profileName="TutorLive - Web Deploy" 
    publishMethod="MSDeploy" 
    publishUrl="tutorlive-XXXXX.scm.centralindia-01.azurewebsites.net:443" 
    msdeploySite="TutorLive"    <-- ?? THIS MUST MATCH YOUR APP NAME!
    userName="$TutorLive" 
    userPWD="XXXXXXXXXXXX" 
    ...
  />
  ...
</publishData>
```

**Key things to check:**
- ? `msdeploySite="TutorLive"` (should match the app name exactly)
- ? `publishUrl` contains the correct Azure URL
- ? `userName` starts with `$TutorLive`

---

## ?? **After Updating the Secret:**

### Option 1: Re-run the Failed Workflow
1. Go to: https://github.com/shahid-afrid/tutorlivev1/actions
2. Click on the failed workflow run
3. Click **"Re-run all jobs"**

### Option 2: Push a New Commit
```bash
cd C:\Users\shahi\Source\Repos\tutor-livev1
git commit --allow-empty -m "Retry deployment with fixed publish profile"
git push origin main
```

---

## ?? **Why This Happened:**

1. **Typo in workflow file**: Had `setup-dotenv` instead of `setup-dotnet` (? FIXED!)
2. **Possible publish profile mismatch**: The secret might have an old or incorrect publish profile
3. **Case sensitivity**: Azure Linux apps are case-sensitive with app names

---

## ? **Checklist:**

- [x] Fixed typo in workflow file (`setup-dotnet`)
- [ ] Downloaded fresh publish profile from Azure Portal
- [ ] Updated `AZURE_WEBAPP_PUBLISH_PROFILE` secret in GitHub
- [ ] Verified `msdeploySite` matches "TutorLive" in the XML
- [ ] Re-ran the workflow or pushed new commit

---

## ?? **Still Having Issues?**

If the error persists after updating the publish profile, check:

1. **App Name in Azure Portal:**
   - Go to Azure Portal ? Your Web App
   - Look at the top - what does it say? Should be **"TutorLive"**
   - If it's different, we need to update the workflow file

2. **Environment Variable in Workflow:**
   ```yaml
   env:
     AZURE_WEBAPP_NAME: TutorLive  # ?? This should match Azure exactly
   ```

3. **Publish Profile Format:**
   - Make sure you copied the ENTIRE XML file content
   - Should start with `<publishData>` and end with `</publishData>`

---

## ?? **Next Steps:**

1. Download fresh publish profile NOW
2. Update the GitHub secret
3. Re-run the workflow
4. Your app should deploy successfully!

Good luck! ??
