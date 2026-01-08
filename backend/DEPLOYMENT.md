# GoAhead Backend - Deployment Guide

## 🚀 Free Deployment Options

### Option 1: Render.com (Recommended)

1. **Sign up** at [render.com](https://render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Configure:
   - **Name**: `goahead-api`
   - **Root Directory**: `backend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

5. Add **Environment Variables**:
   ```
   MONGO_URI=your_mongodb_connection_string
   JWT_SECRET=your_super_secret_jwt_key_here
   NODE_ENV=production
   PORT=10000
   ```

6. Click **Deploy**!

**Free Tier**: 750 hours/month, sleeps after 15 min inactivity

---

### Option 2: Vercel

1. Install Vercel CLI: `npm i -g vercel`
2. Navigate to backend folder: `cd backend`
3. Run: `vercel`
4. Follow prompts and add environment variables
5. Deploy: `vercel --prod`

---

### Option 3: Railway.app

1. Sign up at [railway.app](https://railway.app)
2. Click **"New Project"** → **"Deploy from GitHub Repo"**
3. Select your repo, set root directory to `backend`
4. Add environment variables
5. Deploy!

**Free Tier**: $5 credits/month

---

## 📦 MongoDB Atlas (Free Database)

1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free M0 cluster
3. Create a database user
4. Whitelist IP: `0.0.0.0/0` (allows all IPs)
5. Get connection string: `mongodb+srv://user:pass@cluster.mongodb.net/goahead`

---

## Environment Variables Required

```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/goahead
JWT_SECRET=your_super_secret_key_minimum_32_characters
NODE_ENV=production
PORT=3000
```

---

## After Deployment

Update your Flutter app's API URL in:
`lib/config/constants.dart`

```dart
static const String apiBaseUrl = 'https://your-deployed-api.onrender.com/api';
```
