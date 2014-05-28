unit MainFunc;

interface

function GetAppName(FileExt: string): string;

implementation

function GetAppName(FileExt: string): string;
begin
  Result:= '';
  if (FileExt = '.DWG') then
    Result:= 'ACAD.EXE'
  else
  if (FileExt = '.DOC') or (FileExt = '.DOCX') then
    Result:= 'WINWORD.EXE'
  else
  if (FileExt = '.XLS') or (FileExt = '.XLSX') or (FileExt = '.XML') then
    Result:= 'EXCEL.EXE'
  else
  if (FileExt = '.HSC') then
    Result:= 'HYSYS.EXE'
end;

end.
