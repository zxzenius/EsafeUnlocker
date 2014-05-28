unit EsafeUnlockerForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StrUtils, StdCtrls, ShellAPI, SearchThread, UnlockThread;

type
  TForm1 = class(TForm)
    InfoLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FileExtList, FolderList, FileList, LockedFileList: TStringList;
    function GetTargetExt(ExtList: TStrings): Boolean;
    procedure WMdropfiles(var Msg: TMessage); message WM_DROPFILES;
    procedure MatchLockedFiles();
    procedure SearchFolder();
    procedure SearchDone(Sender: TObject);
    procedure UnlockFiles();
    procedure UnlockDone(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FileExtList.Free;
  FolderList.Free;
  FileList.Free;
  LockedFileList.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FileExtList:= TStringList.Create;
  FolderList:= TStringList.Create;
  FileList:= TStringList.Create;
  LockedFileList:= TStringList.Create;
  LockedFileList.Sorted:= True;
  LockedFileList.Duplicates:= dupIgnore;
  if GetTargetExt(FileExtList) then
  begin
    Form1.DragMode:= dmAutomatic;
  end;
  DragAcceptFiles(Form1.Handle, True);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  //if GetTargetExt(FileExtList) then
   // Form1.Caption:= ExtractFileMain(Application.ExeName);
end;

function TForm1.GetTargetExt(ExtList: TStrings): Boolean;
var
  AppName: string;
begin
  AppName:= UpperCase(ExtractFileName(Application.ExeName));
  FileExtList.Clear;
  Result:= False;
  if AppName = 'ACAD.EXE' then
  begin
    FileExtList.Add('.DWG');
    Exit(True);
  end;
  if AppName = 'WINWORD.EXE' then
  begin
    FileExtList.Add('.DOC');
    FileExtList.Add('.DOCX');
    Exit(True);
  end;
  if AppName = 'EXCEL.EXE' then
  begin
    FileExtList.Add('.XLS');
    FileExtList.Add('.XLSX');
    FileExtList.Add('.XML');
    Exit(True);
  end;
  if AppName = 'HYSYS.EXE' then
  begin
    FileExtList.Add('.HSC');
    Exit(True);
  end;
end;

procedure TForm1.MatchLockedFiles;
var
  i: integer;
begin
  for i:= 0 to FileList.Count - 1 do
  begin
    if FileExtList.IndexOf(UpperCase(ExtractFileExt(FileList[i]))) > -1 then
      LockedFileList.Add(FileList[i]);
  end;
  FileList.Clear;
end;

procedure TForm1.SearchDone(Sender: TObject);
begin
  UnlockFiles;
end;

procedure TForm1.SearchFolder;
begin
  with TSearchThread.Create(FolderList, FileExtList, InfoLabel, LockedFileList) do
    OnTerminate:= SearchDone;
end;

procedure TForm1.UnlockDone(Sender: TObject);
begin
  //WinExec()
  //
end;

procedure TForm1.UnlockFiles;
begin
  with TUnlockThread.Create(LockedFileList, InfoLabel) do
    OnTerminate:= UnlockDone;
end;

procedure TForm1.WMdropfiles(var Msg: TMessage);
var
  DragIndex, DragCount: integer;
  DragFileName: array[0..255] of char;
begin
  DragIndex:= -1;
  DragCount:= DragQueryFile(Msg.WParam, DragIndex, DragFileName, 255);
  //FolderList.Clear;
  for DragIndex:= 0 to DragCount - 1 do
  begin
    DragQueryFile(Msg.WParam, DragIndex, DragFileName, 255);
    if DirectoryExists(DragFileName) then
      FolderList.Add(Trim(DragFileName))
    else if FileExists(DragFileName) then
      FileList.Add(DragFileName)
  end;
  MatchLockedFiles;
  SearchFolder;
  DragFinish(Msg.WParam);
end;

end.
