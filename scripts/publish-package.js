// Step 1: Import the S3Client object and all necessary SDK commands.
const { PutObjectCommand, S3Client } = require("@aws-sdk/client-s3");
const fs = require("fs");

// Step 2: The s3Client function validates your request and directs it to your Space's specified endpoint using the AWS SDK.
const s3Client = new S3Client({
  endpoint: "https://fra1.digitaloceanspaces.com", // Find your endpoint in the control panel, under Settings. Prepend "https://".
  region: "fra1", // Must be "us-east-1" when creating new Spaces. Otherwise, use the region in your endpoint (e.g. nyc3).
  credentials: {
    accessKeyId: process.env.KEY, // Access key pair. You can create access key pairs using the control panel or API.
    secretAccessKey: process.env.SECRET, // Secret access key defined through an environment variable.
  },
});

const fileStream = fs.readFileSync(process.env.PKG_NAME);

// Step 3: Define the parameters for the object you want to upload.
const s3Params = {
  Bucket: "my-npm-packages", // The path to the directory you want to upload the object to, starting with your Space name.
  Key: process.env.PKG_NAME, // Object key, referenced whenever you want to access this file later.
  // Body: "Hello, World!", // The object's contents. This variable is an object, not a string.
  ACL: "public", // Defines ACL permissions, such as private or public.
  Body: fileStream,
  Metadata: {
    // Defines metadata tags.
    "x-amz-meta-my-key": "your-value",
  },
};

// Step 4: Define a function that uploads your object using SDK's PutObjectCommand object and catches any errors.
const uploadObject = async () => {
  try {
    const data = await s3Client.send(new PutObjectCommand(s3Params));
    console.log(
      "Successfully uploaded object: " + s3Params.Bucket + "/" + s3Params.Key
    );
    return data;
  } catch (err) {
    console.log("Error", err);
  }
};

// Step 5: Call the uploadObject function.
uploadObject();
