function Daily_mail() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName("Daily");
  var date = new Date();
  var day = date.getDay();
  var today_header = sheet.getRange('G1');
  var today_date = print_date(date);
  var pdate = today_header.getValue();
  if( pdate == today_date) {
    return;
  }
  
  sheet.insertColumnAfter(6);
  today_header.setValue(today_date);
  
  var looper = 2;
  
    while(sheet.getRange(looper, 1).getValue() != 0){
     if(date.getDate()%Math.abs(sheet.getRange(looper, 5).getValue())==0)
     {
      if(sheet.getRange(looper, 5).getValue()>1||!is_weekend(date))
      {
       var to = sheet.getRange(looper, 1).getValue();
       var cc = {cc: sheet.getRange(looper, 2).getValue()};
       var sub = sheet.getRange(looper, 3).getValue();
       var body = sheet.getRange(looper, 4).getValue();
       //sheet.getRange(looper,9).setValue(looper+to+cc+sub+body);  
        GmailApp.sendEmail(to, sub, body, cc);
       sheet.getRange(looper,6).setValue(today_date);
       sheet.getRange(looper,7).setValue("Y");     
      }
       else
      {
        sheet.getRange(looper,7).setValue("N");
      }
     }
       else
      {
        sheet.getRange(looper,7).setValue("N");
       }
     looper++;
    }

    return;
  
  
}

function print_date(date){
  var day = date.getDate();
var month = date.getMonth()+1;
  var year = date.getYear();
  if(month<10)
    return year+"0"+month+day;
   else
      return year+month+day;
}

function is_weekend(day)
{
if(day==0 || day ==6)
  return true;
  else
    return false;
}
