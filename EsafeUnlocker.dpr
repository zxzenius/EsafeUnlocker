program EsafeUnlocker;

uses
  Forms,
  EsafeUnlockerForm in 'EsafeUnlockerForm.pas' {Form1},
  UnlockThread in 'UnlockThread.pas',
  ZUtils in 'ZUtils.pas',
  MainFunc in 'MainFunc.pas',
  SearchThread in 'SearchThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
