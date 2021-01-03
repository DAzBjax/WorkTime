program WorkTime;

uses
  Vcl.Forms, SyncObjs,
  MainForm_unit in 'MainForm_unit.pas' {MainForm} ,
  AddFilterForm_unit in 'AddFilterForm_unit.pas' {AddFilterForm} ,
  DataModule in 'DataModule.pas', Winapi.Windows {g_DataModule: TDataModule};

{$R *.res}

var
  mutex: TMutex;
  isMutexNotAsquired: integer;

begin
  Application.Initialize;

  isMutexNotAsquired := 10; //10trys (6000ms*10 = 60s)
  mutex := TMutex.Create(nil, false, '{32E65D83-5582-434C-93BC-60725C80AB80}', true); //create mutex
  if (GetLastError = ERROR_ALREADY_EXISTS) then //have another app with this mutex
  begin
    while (isMutexNotAsquired > 0) do //10trys
    begin
      if (mutex.WaitFor(6000) <> wrSignaled) then //this not wait in delphi xe4 ?
      begin
        dec(isMutexNotAsquired);
      end
      else
      begin
         break;
      end;
    end;
  end;

  if (isMutexNotAsquired = 0) then //10 truys are leave = error (60s timeout)
  begin
    mutex.Free;
    mutex := nil;
    halt;
  end;

  mutex.Acquire; //acquire global mutex

  Application.MainFormOnTaskbar := true;
  Application.CreateForm(Tg_DataModule, g_DataModule);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAddFilterForm, AddFilterForm);
  Application.Run;

  mutex.Release; //release global mutex
  mutex.Free;

end.
