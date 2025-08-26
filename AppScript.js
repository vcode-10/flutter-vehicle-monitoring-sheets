// ID folder Google Drive tempat foto akan disimpan.
// Ganti dengan ID folder "VehicleMonitoringPhotos" Anda.
const FOLDER_ID = "1bPNF-C10PhZjeRSbqg6suH4VMyzRpStX"; // <-- PASTE YOUR FOLDER ID HERE
const SHEET_NAME = "Logs"; // <-- Ganti jika nama Sheet Anda berbeda

function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);

    // --- FIX 1: Correctly decode the image and create the file ---
    const imageBase64 = data.foto_base64; // Key name must match Flutter
    const mimeType = data.foto_mime_type || 'image/jpeg';
    const decodedImage = Utilities.base64Decode(imageBase64);
    const blob = Utilities.newBlob(decodedImage, mimeType, `photo_${new Date().getTime()}.jpg`);
    
    const folder = DriveApp.getFolderById(FOLDER_ID);
    const file = folder.createFile(blob);
    
    // --- FIX 2: Make the file publicly viewable to get a working URL ---
    file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
    const photoUrl = `https://drive.google.com/uc?id=${file.getId()}`; // A direct image link

    // --- FIX 3: Define the row data in the correct order ---
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);
    const timestamp = new Date();
    const newRow = [
      timestamp,
      data.id_kendaraan || 'N/A',
      data.nama_driver || 'N/A',
      data.odometer || 0,
      data.jenis_bbm || 'N/A',
      data.jumlah_liter || 0,
      data.biaya || 0,
      photoUrl // Use the generated URL
    ];

    // --- FIX 4: Append the correctly defined row ---
    sheet.appendRow(newRow);

    return ContentService
     .createTextOutput(JSON.stringify({ 'status': 'success', 'message': 'Data saved successfully' }))
     .setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    Logger.log(error.toString());
    return ContentService
     .createTextOutput(JSON.stringify({ 'status': 'error', 'message': error.toString() }))
     .setMimeType(ContentService.MimeType.JSON);
  }
}

// Optional: Add a test function to verify your setup
function testDoPost() {
  // This simulates a POST request for testing
  const testData = {
    postData: {
      contents: JSON.stringify({
        id_kendaraan: "TEST123",
        nama_driver: "Test Driver",
        odometer: 1000,
        jenis_bbm: "Pertalite",
        jumlah_liter: 10.5,
        biaya: 100000,
        foto_base64: "test-base64-string", // This won't work for real images
        foto_mime_type: "image/jpeg"
      })
    }
  };
  
  const result = doPost(testData);
  Logger.log(result.getContent());
}

function doGet(e) {
  try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);
    const allData = sheet.getDataRange().getValues();
    const headers = allData.shift(); // Remove header row

    // --- FIX 5: Correctly filter for today's entries ---
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Set to the beginning of today

    const todaysEntries = allData.filter(row => {
      const rowDate = new Date(row[0]); // Timestamp is in the first column (index 0)
      return rowDate >= today;
    });

    // --- FIX 6: Convert rows to JSON objects using headers ---
    const result = todaysEntries.map(row => {
      const entry = {};
      headers.forEach((header, index) => {
        entry[header] = row[index];
      });
      return entry;
    });
    
    return ContentService
     .createTextOutput(JSON.stringify(result)) // Directly return the array of objects
     .setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    Logger.log(error.toString());
    return ContentService
     .createTextOutput(JSON.stringify({ 'status': 'error', 'message': error.toString() }))
     .setMimeType(ContentService.MimeType.JSON);
  }
}