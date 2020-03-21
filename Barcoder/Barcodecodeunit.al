codeunit 50100 Barcodecodeunit
{
    trigger OnRun()
    begin

    end;

    procedure GenerateBarcode(BarcodeType: Option "c39","c128b","qr"; ValueTxt: Text; ShowText: Boolean; var BarcodeImageText: Text) //This procedure should be called from the report code
    var
        URL: Text;
    begin
        GetBarcodeOptions(BarcodeType, ValueTxt, URL, ShowText); //Generating barcode API URL based on options provided
        GetBarcodeImageText(URL, BarcodeImageText); //Contacting the API and converting the image into Base64 that can be used in report
    end;

    local procedure GetBarcodeOptions(BarcodeType: Option "c39","c128b","qr"; ValueTxt: Text; var URL: Text; ShowText: Boolean)
    var
        BaseURL: Label 'http://www.barcodes4.me/barcode/';
    begin
        URL := BaseURL;

        if barcodeType = barcodeType::qr then begin
            URL += Format(barcodeType) + '/imagename.png?value=' + ValueTxt + '&ecclevel=3';
            exit;
        end;
        URL += Format(barcodeType) + '/' + ValueTxt + '.png';
        if ShowText then
            URL += '?IsTextDrawn=1';

    end;


    local procedure GetBarcodeImageText(var URL: Text; var BarcodeImageText: Text)
    var
        Tmplob: Record TempBlob temporary;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ResponseStream: InStream;
        ostream: OutStream;
        bigtext: BigText;
    begin
        //calling API
        If not Client.Get(URL, ResponseMessage) then
            exit;
        if ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content().ReadAs(ResponseStream);
        end else
            exit;

        //Converting to base64
        Tmplob.Init();
        Tmplob.Insert();
        Tmplob.Blob.CreateOutStream(ostream, TextEncoding::UTF8);
        CopyStream(ostream, ResponseStream);
        BarcodeImageText := Tmplob.ToBase64String();
    end;

    var
}