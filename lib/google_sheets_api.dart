import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "expense-tracker-324813",
  "private_key_id": "988ad0dac9fd531834d8e72dc32998f961d2096a",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCqAMAHx/DAA1zN\nlhm2Hzzq1UuUrgUtK8iu07waADuMtV0hYjfUqMiMlP6Rk5TYVCzdhxtO7SVzshzH\npUmpnRmmfgoltuC8kQKT7nSsqzNpgti29fEuz3STsFCZiQ+7sGJTrZ6eQ2rJpjxH\nN4iWrtoKQ15bRk31D4GEww7sWABGeJp/l7TRzC2qYNWWPb143hu9RcmHWolfn68e\nXrQMPajFJIwakxVm6PuGqgMBhQ1kvV/cZA25jczIwGpgGZh+xWI3Hwrr38YYRi39\nCDjkDucgHQFoHicGFVLIytbsFQmscRWbXQTXNTaUNuPRuOwWr/NCG7bGgs/9dyV0\n8gTGcpl7AgMBAAECggEAD1Kw/FXCHMFQ1WD9oUpDtq3FOboAhaR7WrK2ZihcnB97\nk11weqHZ+oqyPvnf6F3Li3SFlBtQ85KVM7OLJhdSCNoC3SJhZrp+7BZWr636UAmd\nfsqm06YBGnZbO9nvfQBDF8q/tmeNa26PfIkELgMsBdFlSSUKZ5fFs1GhLNFdX2L4\n8VD/tlW7o0czpaH/eMrdbBbUf4KnOqcOtSHrE7l6ZzzzFd095ejH+0uR1mftAlmJ\ntNumsYjZjuj8P327DXRRaAUCMpcIBiaRhJcAUAbIaZtA3yw8Of09NT6FMddTVfQt\n+hI7Pv3j0jIr5dDwiJDBB1YHIZzA6ZpsTPWJocgmFQKBgQDuuZgQkVQRErcrkBUP\nvXOXvZwwdrfGiY9KJb2VaV8khbCtPY4Z591zJiIKTMCCpBbH0fJqHoW7CEoVi1sS\n6jN9FL4dUKLqKvlQtD2aHU3lA35LQE8HmZnR6cyofZ58oophnMU+/NCqqm5TX0s3\n8xo0C01bXqi4KtkNFoQr/mHdnwKBgQC2ThKhhST6a5G8gHJ8oYQRHwPZY6xCTPuz\n0N2t6KG+MsPws1cm+8EjwJmRzCrXBgljbLj70e8kTnBceyzCCXzRO2R6DQYdRJh9\ncMdAtfO98kjs8R3atfeggQOP7hDP+YBk/xLUVwI5zUsohPm2afzQFxfsluicL8DG\nGgpjIKX+pQKBgQCp1vzq/JoUs34BzjZNxnmQwWN3z16cL430MLmarSb1cu/psNuC\nbsXMgJrDPSvRRjC25RVUjnaSRCmA/m5DHMCZAsLnVFEzzHMoCbOyC5s5jayymQQg\n4hTflTj3vrec8H8HR2PFllRWt35abnezTI+d61ST5tqefE2D1DsgmZDC/QKBgQCD\nK+vF4ho4QPvsiPNXb5OqCgnn+gqw7dlRiaBniHIQe1B2uWOk/hH7GpKk0CWm74YD\nzu/O6T/LfNDmCg6rUs5HcheaphJXLssVvvbvPbwyWMlWCyty+elByHJ6tk3MhvZ2\nNP4kYLKOSoOglQVj1iD8zRD+v5qA/u8S2xvMNWqarQKBgEmGSOJ+cuCRpVxRmoUQ\nlDMLpjhTavYAeTqg+4bfiGqWL6wBFukz+YXB8W7hEhQRxUZ9G1ZCEZHVmmXFuO2l\nQp+Pm32r6b/ICGYIgEFrrhkkOl5puBQ8lgOc3CkQEBdE2e48341GLRVwvb/ajSNQ\nLsK2TTHfuF5v4miHKq3aMA4f\n-----END PRIVATE KEY-----\n",
  "client_email": "expense-tracker-app@expense-tracker-324813.iam.gserviceaccount.com",
  "client_id": "114869304597209631635",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expense-tracker-app%40expense-tracker-324813.iam.gserviceaccount.com"
}
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1oRDZA9jqVc3cQUhZZ0sSVq6WjZTt83g27oAnoJnVoVA';
  static final _gsheets = GSheets(_credentials);
  static Worksheet _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}