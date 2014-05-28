unit UnlockThread;

interface

uses
  Classes {$IFDEF MSWINDOWS}, Windows {$ENDIF}, SysUtils, StdCtrls, ZUtils,
  MainFunc;

type
  TUnlockThread = class(TThread)
  private
    InfoLabel: TLabel;
    CurrInfo: string;
    AppPath: string;
    LockedFileList: TStrings;
    procedure UpdateInfo;
  protected
    procedure Execute; override;
  public
    constructor Create(LockedFileList: TStrings; InfoLabel: TLabel;
      AppPath: string);
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TUnlockThread.UpdateCaption;
  begin
  Form1.Caption := 'Updated in a thread';
  end;

  or

  Synchronize(
  procedure
  begin
  Form1.Caption := 'Updated in thread via an anonymous method'
  end
  )
  );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ TUnlockThread }

constructor TUnlockThread.Create(LockedFileList: TStrings; InfoLabel: TLabel;
  AppPath: string);
begin
  Self.LockedFileList := LockedFileList;
  Self.InfoLabel := InfoLabel;
  Self.AppPath := AppPath;
  FreeOnTerminate := True;
  inherited Create(False);
end;

procedure TUnlockThread.Execute;
var
  i, counter: Integer;
  LockedFile, UnlockedFile: TFileStream;
  SourceFileName, SourceFileExt, TargetFileMain, TargetFileName, AppName: string;
  CMDLine: string;
begin
  NameThreadForDebugging('UnlockThread');
  { Place thread code here }
  InfoLabel.Caption := '';
  counter := 0;
  for i := 0 to LockedFileList.Count - 1 do
  begin
    SourceFileName := LockedFileList[0];
    SourceFileExt := ExtractFileExt(SourceFileName);
    AppName := AppPath + GetAppName(SourceFileExt);
    LockedFileList.Delete(0);
    if not FileExists(AppName) then
      Continue;
    TargetFileMain := ExtractFilePath(SourceFileName) + ExtractFileMain
      (SourceFileName) + '_dec';
    TargetFileName:= TargetFileMain + '.TXT';
    CMDLine:= AppName + ' ' + SourceFileName + ' ' + TargetFileName;
    if WinExec(CMDLine, SW_HIDE) <= 31 then
      Continue;
    Inc(counter);
    CurrInfo := '[' + IntToStr(counter) + ']' + SourceFileName;
    Synchronize(UpdateInfo);
    TargetFileName:= TargetFileMain + SourceFileExt;
    if FileExists(TargetFileName) then
      DeleteFile(TargetFileName);
    RenameFile(SourceFileName, TargetFileName);
  end;
end;

procedure TUnlockThread.UpdateInfo;
begin
  InfoLabel.Caption := 'Unlocking:' + CurrInfo;
end;

end.
