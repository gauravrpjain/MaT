function onEdit()
{
  var closed = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Closed");
  var deleted = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Deleted");
  var masterSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("Master Sheet");

  var s = SpreadsheetApp.getActiveSheet();
  if(s.getName()!="Tracker"){
    Logger.log("ERror Still PErsists");
  return;
  }
  var time = new Date();
  time = Utilities.formatDate(time, "GMT+05:30", "yyyy-MM-dd, hh:mm:ss");
  
  {  
    var r = s.getActiveCell();
    var column = r.getColumn();
    var row = r.getRow();
    {
      if (s.getRange(row, 1).getValue() == "")
      {
        var ID = masterSheet.getLastRow();
        s.getRange(row,1).setValue(ID);
        masterSheet.getRange(masterSheet.getLastRow()+1,1).setValue(ID);
        s.getRange(row, 9).setValue("Open");
        r.copyTo(masterSheet.getRange(masterSheet.getLastRow(),column));
        masterSheet.getRange('N'+ masterSheet.getLastRow().toString()).setValue(time);
      }
      else{
        var ID = s.getRange(row, 1).getValue();
        var addition = Session.getActiveUser().getEmail() + " on "+time+" : \n" + r.getValue() + "\n\n"+ masterSheet.getRange(ID+1, column).getValue();
        masterSheet.getRange(ID+1, column).setValue(addition);
      }
    }
    if( r.getColumn() == 7 ) { //checks the column
      SpreadsheetApp.getActiveSheet().getRange('H' + row.toString()).setValue(time);
    }
    if(r.getColumn()==9){
      if(r.getValue() == "Closed"){ 
        var ui = SpreadsheetApp.getUi();
        var response = ui.prompt('Confirmation', 'Do you want to close the task?', ui.ButtonSet.YES_NO);
        // Process the user's response.
        if (response.getSelectedButton() == ui.Button.YES) {
          var targetRange = closed.getRange(closed.getLastRow() + 1, 1);
          masterSheet.getRange(s.getRange(row, 1).getValue()+1,15).setValue(time);
          s.getRange(r.getRow(), 1, 1, s.getLastColumn()).moveTo(targetRange);
          s.deleteRow(r.getRow());
        } else if (response.getSelectedButton() == ui.Button.NO) {
          r.setValue("Open");
        } else {
          r.setValue("Open");
        }
      }
      if(r.getValue() == "Deleted/No longer required"){ 
        var ui = SpreadsheetApp.getUi();
        var response = ui.prompt('Confirmation', 'Do you want to delete the task?', ui.ButtonSet.YES_NO); 
        // Process the user's response.
        if (response.getSelectedButton() == ui.Button.YES) {
          var targetRange = deleted.getRange(deleted.getLastRow() + 1, 1);
          masterSheet.getRange(s.getRange(row, 1).getValue()+1,15).setValue(time);
          s.getRange(r.getRow(), 1, 1, s.getLastColumn()).moveTo(targetRange);
          s.deleteRow(r.getRow()); 
        } else if (response.getSelectedButton() == ui.Button.NO) {
          r.setValue("Open");
        } else {
          r.setValue("Open");
        }
      }  
    }
  }
}
