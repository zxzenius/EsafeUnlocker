unit ZUtils;

interface

uses
  SysUtils, StrUtils;

function ExtractFileMain(FullFileName: string): string;

implementation

function ExtractFileMain(FullFileName: string): string;
begin
  if FullFileName = '' then
    Exit('');
  Result:= ExtractFileName(LeftStr(FullFileName,
           Length(FullFileName) - Length(ExtractFileExt(FullFileName))))
end;

end.
