unit SearchAndUnlock;

interface

uses
  Classes {$IFDEF MSWINDOWS}, Windows {$ENDIF}, StdCtrls, SysUtils;

type
  TSearchThread = class(TThread)
  private
    InfoLabel: TLabel;
    CurrInfo: string;
    FolderList, ResultList, FilterList: TStrings;
    procedure Dosearch(SearchResult: TStrings);
    procedure UpdateInfo;
  protected
    procedure Execute; override;
  public
    constructor Create(FolderList: TStrings; FilterList: TStrings;
      InfoLabel: TLabel; ResultList: TStrings);
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TSearchThread.UpdateCaption;
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

{ TSearchThread }

constructor TSearchThread.Create(FolderList, FilterList: TStrings;
  InfoLabel: TLabel; ResultList: TStrings);
begin
  Self.FolderList := FolderList;
  Self.FilterList := FilterList;
  Self.InfoLabel := InfoLabel;
  Self.ResultList := ResultList;
  FreeOnTerminate := True;
  inherited Create(False);
end;

procedure TSearchThread.Dosearch(SearchResult: TStrings);
var
  sr: TSearchRec;
  Flag: integer;
begin
  Flag := FindFirst('*.*', faDirectory, sr);
  while Flag = 0 do
  begin
    if ((sr.Attr and faDirectory) <> 0) and (sr.Name <> '.') and
      (sr.Name <> '..') then
    begin
      ChDir(sr.Name);
      CurrInfo := ExpandFileName(sr.Name);
      Synchronize(UpdateInfo);
      Dosearch(SearchResult);
      ChDir('..');
    end
    else if ((sr.Attr and faDirectory) = 0) and
      (FilterList.IndexOf(UpperCase(ExtractFileExt(sr.Name))) > -1) then
      SearchResult.Add(ExpandFileName(sr.Name));
    Flag := FindNext(sr);
  end;
  SysUtils.FindClose(sr);
end;

procedure TSearchThread.Execute;
var
  i: integer;
begin
  InfoLabel.Caption := '';
  InfoLabel.Show;
  for i := 0 to FolderList.Count - 1 do
  begin
    ChDir(FolderList[0]);
    FolderList.Delete(0);
    Dosearch(ResultList);
    ChDir('\');
  end;
  NameThreadForDebugging('SearchThread');
  { Place thread code here }
end;

procedure TSearchThread.UpdateInfo;
begin
  InfoLabel.Caption := 'Searching:' + CurrInfo;
end;

end.
