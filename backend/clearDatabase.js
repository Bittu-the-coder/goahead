import dotenv from 'dotenv';
import mongoose from 'mongoose';
import connectDB from './config/db.js';

dotenv.config();

const clearAllCollections = async () => {
  try {
    await connectDB();

    const collections = await mongoose.connection.db.collections();

    console.log('🗑️  Clearing all collections...\n');

    for (let collection of collections) {
      const count = await collection.countDocuments();
      await collection.deleteMany({});
      console.log(`✅ Cleared ${collection.collectionName}: ${count} documents deleted`);
    }

    console.log('\n✨ All collections cleared successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error clearing collections:', error);
    process.exit(1);
  }
};

clearAllCollections();
