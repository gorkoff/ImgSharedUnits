unit UBinaryImages;

interface

uses
  VCL.Graphics;

type
  /// �������� �����������
  TCBinaryImage = class
  private
    ImgHeight: word; // ������ �����������
    ImgWidth: word; // ������ �����������
    ImgPixels: array of array of boolean; // ������� �����������

    procedure SetHeight(newHeight: word); // ������ ����� ������ �����������
    function GetHeight: word; // �������� ������ �����������

    procedure SetWidth(newWidth: word); // ������ ����� ������ �����������
    function GetWidth: word; // �������� ������ �����������

    procedure SetPixelValue(
      i, j: integer;
      value: boolean); // ������������� �������� ��������� �������. ���� ������������� ���������� �� ��������� �����������, ��������������� �������� ���������� �������
    function GetPixelValue(i, j: integer): boolean; // ���������� �������� ������ �����������. ���� ������������� ���������� �� ��������� �����������, ������������ �������� ���������� �������

    procedure InitPixels; // ������������� ������� ����������� �������� ����������
    procedure FreePixels; // ������������ �������� �����������
  public
    constructor Create; // ������� �����������
    destructor FreeBinaryImage; // ����������� ����������

    function SaveToBitMap: TBitmap; // ���������� ����������� � ���� ������� �����

    property Height: word read GetHeight write SetHeight; // �������� ��� ������ � ������ ������ �����������
    property Width: word read GetWidth write SetWidth; // �������� ��� ������ � ������ ������ �����������
    property Pixels[row, col: integer]: boolean read GetPixelValue write SetPixelValue; // �������� ��� ������ � ������ ��������� ��������

    procedure Invert; // ����������� ������ ������ ������������ ����������� (��� �������� ������ �����������)
  end;

implementation

uses
  UPixelConvert, SysUtils;

constructor TCBinaryImage.Create;
begin
  inherited;
  self.ImgHeight := 0;
  self.ImgWidth := 0;
end;

destructor TCBinaryImage.FreeBinaryImage;
begin
  self.FreePixels;
  inherited;
end;

procedure TCBinaryImage.FreePixels;
var
  i: word;
begin
  if (self.ImgHeight > 0) and (self.ImgWidth > 0) then
  begin
    for i := 0 to self.ImgHeight - 1 do
    begin
      SetLength(
        self.ImgPixels[i],
        0);
      Finalize(self.ImgPixels[i]);
      self.ImgPixels[i] := nil;
    end;
    SetLength(
      self.ImgPixels,
      0);
    Finalize(self.ImgPixels);
    self.ImgPixels := nil;
  end;
end;

procedure TCBinaryImage.InitPixels;
var
  i, j: word;
begin
  if (self.ImgHeight > 0) and (self.ImgWidth > 0) then
  begin
    SetLength(
      self.ImgPixels,
      self.ImgHeight);
    for i := 0 to self.ImgHeight - 1 do
    begin
      SetLength(
        self.ImgPixels[i],
        self.ImgWidth);
      for j := 0 to self.ImgWidth - 1 do
        self.ImgPixels[i, j] := false;
    end;
  end;
end;

function TCBinaryImage.GetPixelValue(i, j: integer): boolean;
begin
  if i < 0 then
    i := 0;
  if i >= self.ImgHeight then
    i := self.ImgHeight - 1;
  if j < 0 then
    j := 0;
  if j >= self.ImgWidth then
    j := self.ImgWidth - 1;
  GetPixelValue := self.ImgPixels[i, j];
end;

procedure TCBinaryImage.SetPixelValue(
  i, j: integer;
  value: boolean);
begin
  if i < 0 then
    i := 0;
  if i >= self.ImgHeight then
    i := self.ImgHeight - 1;
  if j < 0 then
    j := 0;
  if j >= self.ImgWidth then
    j := self.ImgWidth - 1;
  self.ImgPixels[i, j] := value;
end;

procedure TCBinaryImage.SetHeight(newHeight: word);
begin
  FreePixels;
  self.ImgHeight := newHeight;
  self.InitPixels;
end;

function TCBinaryImage.GetHeight: word;
begin
  GetHeight := self.ImgHeight;
end;

procedure TCBinaryImage.SetWidth(newWidth: word);
begin
  FreePixels;
  self.ImgWidth := newWidth;
  self.InitPixels;
end;

function TCBinaryImage.GetWidth: word;
begin
  GetWidth := self.ImgWidth;
end;

function TCBinaryImage.SaveToBitMap: TBitmap;
var
  i, j: word;
  BM: TBitmap;
  p: TColorPixel;
  line: pByteArray;
begin
  p := TColorPixel.Create;
  BM := TBitmap.Create;
  BM.PixelFormat := pf24bit;
  BM.Height := self.ImgHeight;
  BM.Width := self.ImgWidth;
  for i := 0 to self.ImgHeight - 1 do
  begin
    line := BM.ScanLine[i];
    for j := 0 to self.ImgWidth - 1 do
    begin
      if self.ImgPixels[i, j] then
        p.SetRGB(
          0,
          0,
          0)
      else
        p.SetRGB(
          1,
          1,
          1);
      line[3 * j + 2] := round(p.GetRed * 255);
      line[3 * j + 1] := round(p.GetGreen * 255);
      line[3 * j + 0] := round(p.GetBlue * 255);
    end;
  end;
  SaveToBitMap := BM;
  p.Free;
end;

procedure TCBinaryImage.Invert;
var
  i, j: word;
begin
  for i := 0 to self.ImgHeight - 1 do
    for j := 0 to self.ImgWidth - 1 do
      self.ImgPixels[i, j] := not self.ImgPixels[i, j];
end;

end.
