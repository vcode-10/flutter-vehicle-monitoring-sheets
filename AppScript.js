const LOGS_SHEET_NAME = "Logs";
const KENDARAAN_SHEET_NAME = "Kendaraan";
const SOPIR_SHEET_NAME = "Sopir";
const JENIS_BBM_SHEET_NAME = "JenisBBM";
const FOLDER_ID = "YOUR_GOOGLE_DRIVE_FOLDER_ID"; // <-- GANTI DENGAN ID FOLDER ANDA

// Fungsi utama untuk menangani request GET
function doGet(e) {
  const action = e.parameter.action;

  if (action == "getVehicles") {
    return getSheetDataAsJson(KENDARAAN_SHEET_NAME);
  }
  if (action == "getDrivers") {
    return getSheetDataAsJson(SOPIR_SHEET_NAME);
  }
  if (action == "getFuelTypes") {
    return getSheetDataAsJson(JENIS_BBM_SHEET_NAME);
  }
  if (action == "getTodaysReports") {
    const driverName = e.parameter.driverName;
    return getTodaysReportsByDriver(driverName);
  }
  
  return ContentService.createTextOutput("Invalid action").setMimeType(ContentService.MimeType.JSON);
}

// Fungsi utama untuk menangani request POST
function doPost(e) {
  const action = e.parameter.action;

  if (action == "addReport") {
    return addReport(e);
  }
  if (action == "updateFuelPrices") {
    return updateFuelPrices(e);
  }
  
  return ContentService.createTextOutput("Invalid action").setMimeType(ContentService.MimeType.JSON);
}

// Helper function untuk membaca data dari sheet dan mengubahnya jadi JSON
function getSheetDataAsJson(sheetName) {
  try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);
    const data = sheet.getDataRange().getValues();
    const headers = data.shift();
    
    const result = data.map(row => {
      const entry = {};
      headers.forEach((header, index) => {
        entry[header] = row[index];
      });
      return entry;
    });

    return ContentService.createTextOutput(JSON.stringify(result)).setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({ status: 'error', message: error.toString() })).setMimeType(ContentService.MimeType.JSON);
  }
}

// Fungsi untuk mengambil laporan hari ini berdasarkan sopir
function getTodaysReportsByDriver(driverName) {
  // (Gunakan kode doGet Anda yang sudah diperbaiki sebelumnya, tambahkan filter by driverName)
  // ... Logika ini akan sama seperti doGet Anda yang terakhir, tetapi dengan tambahan:
  // .filter(entry => entry.nama_driver === driverName);
  // Ini untuk memastikan hanya data sopir yang dipilih yang tampil.
  // ... (Silakan implementasikan berdasarkan kode doGet Anda yang sudah ada)
   try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);
    const allData = sheet.getDataRange().getValues();
    const headers = allData.shift(); // Remove header row

    const today = new Date();
    today.setHours(0, 0, 0, 0); 

    const todaysEntries = allData.filter(row => entry.nama_driver === driverName );

    const result = todaysEntries.map(row => {
      const entry = {};
      headers.forEach((header, index) => {
        entry[header] = row[index];
      });
      return entry;
    });
    
    return ContentService
     .createTextOutput(JSON.stringify(result)) 
     .setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    Logger.log(error.toString());
    return ContentService
     .createTextOutput(JSON.stringify({ 'status': 'error', 'message': error.toString() }))
     .setMimeType(ContentService.MimeType.JSON);
  }
}

// Fungsi untuk menambah laporan baru
function addReport(e) {
  try {
    const data = JSON.parse(e.postData.contents);

    const imageBase64 = data.foto_base64; // Key name must match Flutter
    const mimeType = data.foto_mime_type || 'image/jpeg';
    const decodedImage = Utilities.base64Decode(imageBase64);
    const blob = Utilities.newBlob(decodedImage, mimeType, `photo_${new Date().getTime()}.jpg`);
    
    const folder = DriveApp.getFolderById(FOLDER_ID);
    const file = folder.createFile(blob);
    
    file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
    const photoUrl = `https://drive.google.com/uc?id=${file.getId()}`; // A direct image link

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
      photoUrl 
    ];

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

// Fungsi BARU untuk mengedit harga BBM
function updateFuelPrices(e) {
  try {
    const updatedPrices = JSON.parse(e.postData.contents); // Menerima array [{jenis_bbm: 'Pertalite', harga_per_liter: 11000}]
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(JENIS_BBM_SHEET_NAME);
    const data = sheet.getDataRange().getValues();
    const headers = data.shift();
    const fuelTypeColumnIndex = headers.indexOf('jenis_bbm');
    const priceColumnIndex = headers.indexOf('harga_per_liter');

    updatedPrices.forEach(updatedFuel => {
      for (let i = 0; i < data.length; i++) {
        if (data[i][fuelTypeColumnIndex] === updatedFuel.jenis_bbm) {
          // Update harga di baris yang cocok (i + 2 karena header sudah dihapus dan sheet 1-based)
          sheet.getRange(i + 2, priceColumnIndex + 1).setValue(updatedFuel.harga_per_liter);
          break;
        }
      }
    });
    
    return ContentService.createTextOutput(JSON.stringify({ status: 'success', message: 'Harga BBM berhasil diperbarui' })).setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({ status: 'error', message: error.toString() })).setMimeType(ContentService.MimeType.JSON);
  }
}