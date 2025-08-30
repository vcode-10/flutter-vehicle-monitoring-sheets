// Ganti dengan ID folder Google Drive Anda
const FOLDER_ID = "1bPNF-C10PhZjeRSbqg6suH4VMyzRpStX"; 

// Nama-nama Sheet di file Google Sheet Anda
const SHEET_PERJALANAN = "PerjalananHarian";
const SHEET_LOGS = "Logs";
const SHEET_RUTE = "Rute";
const SHEET_KENDARAAN = "Kendaraan";
const SHEET_SOPIR = "Sopir";

/**
 * Menangani semua request GET dari aplikasi Flutter.
 * Merutekan request ke fungsi yang sesuai berdasarkan parameter 'action'.
 */
function doGet(e) {
  const action = e.parameter.action;

  try {
    if (action == "getInitialData") {
      return getInitialData();
    }
    if (action == "getTripStatus") {
      return getTripStatus(e.parameter.vehicleId, e.parameter.driverId);
    }
    if (action == "getLastOdometer") {
      return getLastOdometer(e.parameter.vehicleId);
    }
    
    throw new Error("Aksi GET tidak valid.");

  } catch (error) {
    return returnJsonError(error);
  }
}

/**
 * Menangani semua request POST dari aplikasi Flutter.
 * Merutekan request ke fungsi yang sesuai berdasarkan parameter 'action'.
 */
function doPost(e) {
  const action = e.parameter.action;
  const data = JSON.parse(e.postData.contents);

  try {
    if (action == "startTrip") {
      return startTrip(data);
    }
    if (action == "addFuelLog") {
      return addFuelLog(data);
    }
    if (action == "endTrip") {
      return endTrip(data);
    }
   
    throw new Error("Aksi POST tidak valid.");

  } catch (error) {
    return returnJsonError(error);
  }
}

/**
 * Mengambil semua data awal yang dibutuhkan aplikasi saat startup.
 * (Kendaraan, Sopir, Rute) dalam satu kali panggilan.
 */
function getInitialData() {
  const vehicles = getSheetDataAsJson(SHEET_KENDARAAN);
  const drivers = getSheetDataAsJson(SHEET_SOPIR);
  const routes = getSheetDataAsJson(SHEET_RUTE);

  const initialData = {
    vehicles: vehicles,
    drivers: drivers,
    routes: routes,
  };
  return returnJsonSuccess(initialData);
}

/**
 * Memeriksa apakah sudah ada perjalanan yang aktif untuk kombinasi
 * kendaraan dan sopir pada hari ini.
 */
function getTripStatus(vehicleId, driverId) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_PERJALANAN);
  const data = sheet.getDataRange().getValues();
  const todayStr = new Date().toLocaleDateString('id-ID'); 

  for (let i = data.length - 1; i >= 1; i--) { 
    const row = data[i];
    const tripDate = new Date(row[1]).toLocaleDateString('id-ID');
    const tripVehicleId = row[3];
    const kmAkhir = row[5];

    if (tripVehicleId === vehicleId && tripDate === todayStr) {
      // Jika ditemukan perjalanan hari ini untuk kendaraan yang sama
      const status = {
        tripExists: true,
        tripId: row[0], 
        isFinished: kmAkhir !== "" && kmAkhir > 0,
      };
      return returnJsonSuccess(status);
    }
  }

  return returnJsonSuccess({ tripExists: false });
}


/**
 * Mengambil nilai KM Akhir terakhir dari sebuah kendaraan.
 */
function getLastOdometer(vehicleId) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_PERJALANAN);
  const data = sheet.getDataRange().getValues();

  // Loop dari bawah ke atas untuk menemukan entri terakhir
  for (let i = data.length - 1; i >= 1; i--) {
    const row = data[i];
    if (row[3] === vehicleId) { // Cek kolom id_kendaraan
      const lastOdometer = row[5]; // Ambil km_akhir
      return returnJsonSuccess({ lastOdometer: lastOdometer || 0 });
    }
  }
  return returnJsonSuccess({ lastOdometer: 0 }); // Jika kendaraan baru
}

/**
 * Mencatat perjalanan baru di sheet 'PerjalananHarian'.
 */
function getTripStatus(vehicleId, driverId) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_PERJALANAN);
  const data = sheet.getDataRange().getValues();
  
  // Menggunakan perbandingan tanggal yang lebih andal
  const today = new Date();
  today.setHours(0, 0, 0, 0); // Atur ke awal hari ini

  for (let i = data.length - 1; i >= 1; i--) { 
    const row = data[i];
    
    // Cek jika sel tanggal tidak kosong sebelum diproses
    if (row[1]) {
      const tripDate = new Date(row[1]);
      tripDate.setHours(0, 0, 0, 0); // Atur tanggal perjalanan ke awal hari juga
      
      const tripVehicleId = row[3];
      const kmAkhir = row[5];

      // Bandingkan tanggal secara langsung
      if (tripVehicleId === vehicleId && tripDate.getTime() === today.getTime()) {
        const status = {
          tripExists: true,
          tripId: row[0],
          isFinished: kmAkhir !== "" && kmAkhir > 0,
        };
        return returnJsonSuccess(status);
      }
    }
  }

  return returnJsonSuccess({ tripExists: false });
}

/**
 * Mencatat pengisian BBM baru di sheet 'Logs'.
 */
function addFuelLog(data) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_LOGS);
  
  // Proses upload foto
  const imageBase64 = data.foto_base64;
  const mimeType = data.foto_mime_type || 'image/jpeg';
  const decodedImage = Utilities.base64Decode(imageBase64);
  const blob = Utilities.newBlob(decodedImage, mimeType, `log_${new Date().getTime()}.jpg`);
  const folder = DriveApp.getFolderById(FOLDER_ID);
  const file = folder.createFile(blob);
  file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
  const photoUrl = `https://drive.google.com/uc?id=${file.getId()}`;

  const logId = Utilities.getUuid();
  const newRow = [
    logId,
    data.id_perjalanan,
    new Date(), 
    data.km_isi_bbm,
    data.jenis_bbm,
    data.jumlah_liter,
    data.biaya,
    photoUrl,
  ];

  sheet.appendRow(newRow);
  return returnJsonSuccess({ message: "Log BBM berhasil ditambahkan." });
}

function endTrip(data) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_PERJALANAN);
  const allData = sheet.getDataRange().getValues();
  const tripId = data.id_perjalanan;

  for (let i = 1; i < allData.length; i++) {
    if (allData[i][0] === tripId) {
      const kmAwal = allData[i][4];
      const kmAkhir = data.km_akhir;
      const totalKm = kmAkhir - kmAwal;

      // Update sel yang sesuai (ingat, indeks array 0-based, range sheet 1-based)
      sheet.getRange(i + 1, 6).setValue(kmAkhir);   // Kolom F (km_akhir)
      sheet.getRange(i + 1, 7).setValue(totalKm);  // Kolom G (total_km)
      
      return returnJsonSuccess({ message: "Perjalanan berhasil diselesaikan." });
    }
  }
  throw new Error("ID Perjalanan tidak ditemukan.");
}

/**
 * Membaca seluruh data dari sebuah sheet dan mengubahnya menjadi array objek JSON.
 */
function getSheetDataAsJson(sheetName) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);
  if (!sheet) return [];
  const data = sheet.getDataRange().getValues();
  if (data.length < 2) return [];

  const headers = data.shift();
  
  return data.map(row => {
    const entry = {};
    headers.forEach((header, index) => {
      entry[header] = row[index];
    });
    return entry;
  });
}

/**
 * Mengembalikan respons sukses dalam format JSON.
 */
function returnJsonSuccess(payload) {
  return ContentService
    .createTextOutput(JSON.stringify({ status: "success", data: payload }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * Mengembalikan respons error dalam format JSON.
 */
function returnJsonError(error) {
  Logger.log(error);
  return ContentService
    .createTextOutput(JSON.stringify({ status: "error", message: error.message }))
    .setMimeType(ContentService.MimeType.JSON);
}
