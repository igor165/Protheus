(*
P11

Projeto: Protheus Crystal Integration
---------+-------------------+--------------------------------------------------------
 Data     | Autor             | Descricao
---------+-------------------+--------------------------------------------------------
 05.02.08 | BI Team           | Pacote de integração único para versões do Crystal
          |                   | Reports inferiores a 2008.
--------------------------------------------------------------------------------------
Manutenção:
        Baixar Merge Modules de: https://websmp230.sap-ag.de/sap(bD1wdCZjPTAwMQ==)/bc/bsp/spn/bobj_download/main.htm

        Para alteração de versão, alterar o valor da constante cBUILD para a data da alteração.

Configuração do ambiente:
        Instalar o pacote Protheus Crystal Integration.msi na estação. Obs.: O Crystal não deve estar instaldo.

        Clicar em projetos, Import Type Library e adionar as seguintes librarys em um novo pacote.

        1 - Crystal ActiveX Report Viewer Library 11.5
        2 - Crystal ActiveX Design Run Time Library 11.5

        Alterar das seguintes classes:
                TReport para TCReport
                TDatabase para TCDatabase
                TApplication para TCApplication

 Parâmetros para Debug:
      sCaminho, sNome, nOrdem, sFiltro, sGrupoEmpresa, sTitulo, nDestino, nCopias, sCoords, sHandle, bAtualiza, nIdioma, sLogin,  sEmpresa, sUnidade, sFilial, sParams, sSX1, sSX2, sPassAdm, sEnv, sSrv, sAutoConfig, bShowGauge, bRunOnServer, sUserPath
---------------------------------------------------------------------------------------
*)

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Lib, Crysini, Senha, Gauge, Viewer, FileCtrl,
  ComCtrls, CRAXDRT_TLB, OleServer, OleCtrls, DBTables, Registry, Printers, i18n;

type
  TfMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure inicial(sCaminho, sNome, nOrdem, sFiltro, sGrupoEmpresa, sTitulo, nDestino, nCopias, sCoords, sHandle, bAtualiza, nIdioma, sLogin, sEmpresa, sUnidade, sFilial, sParams, sSX1, sSX2, sPassAdm, sEnv, sSrv, sAutoConfig, bShowGauge, bRunOnServer, sUserPath, sTables : PChar);
  procedure ValidaCrysini();
  procedure ValidaSenha();
  procedure CriaGauge();
  procedure IncGauge(nValue : Integer);
  procedure FechaGauge();
  function TrocarTabelas(RPT : IReport) : IReport;
  function PreencheParams(RPT : IReport ) : IReport;
  function TratarFormulas(RPT : IReport; sTables: PChar) : IReport;
  function SubReports(RPT : IReport) : IReport;

var
  fMain: TfMain;
  sAppPath : String;
  sArqTMP : String;
  slLista : TStringList;

  //Armazena os valores recuperados do crysini.ini.
  sRootPath : String;
  sSXPath : String;
  sExportPath :String;
  sUpdODBCPath :String;

  sRPTPath, sRPTNome, sRPTFiltro, sRPTGrupoEmpresa, sRPTTitulo, sTitulo, sRPTCoord, sRPTHandle, sRPTLogin, sRPTEmpresa, sRPTUnidade, sRPTfilial, sRPTParams, sRPTSX1, sRPTSX2, sRPTPassAdm, sRPTEnv, sRPTSrv, sRPTOpen, sRPTBanco, sRPTExtExport, sRPTSXAutoConfig, sRPTUserPath : String;
  nRPTOrdem, nRPTDest, nRPTCopias, nRPTIdioma,nRPTMinPage, nRPTMaxPage, nRPTFormatType : Integer;
  bRPTAtualiza, bRPTShowGauge : Boolean;
  sBanco : String;
  sLog : String;
  nQtdParam : Integer;
  sSTROpen : String;
  slSTR : TStringList;
  sTempDir : String;
  aArquivos : TStringList;
  aParamsValores : TStringList;
  bRPTExport : Boolean;
  bUpdODBCPath: Boolean;
  sRPTExport : String;
  bProcessa : Boolean;
implementation
uses CommDlg;
{$R *.DFM}

procedure TfMain.FormCreate(Sender: TObject);
var
    valores: TStringList;
    parametros:Integer;
    parametro: Integer;

begin
	aArquivos       := TStringList.Create;
	aParamsvalores  := TStringList.Create;
	nQtdParam       := ParamCount;
	bRPTExport      := False;
	bUpdODBCPath    := False;
	sRPTExport      := cVAZIO;
	sAppPath        := GetCurrentDir();
	sTempDir        := GetEnvVar(cVARTMP) + cBARINV;
        sLog            := Crialog(sAppPath);

    aArquivos.Clear;

	if GetTokenAdvCount(sTempDir, cPV) > 1 then
	begin
	    ExibeErro(SetTexto(25, nIdioma));
	    ExibeErro(SetTexto(17, nIdioma));
	end;

        //Seta o arquivo de log global.
	SetLog(sLog);

	gravalog('Protheus Crystal Integration ' + cBUILD, sLog);
	gravalog('Diretório TEMP da maquina -> ' + sTempDir, sLog);
	gravalog('Parametros recebidos: -> ' + inttostr( ParamCount ) , sLog);

        //É passado um ínico parâmetro para o executável separado por | e com * no lugar de vazio.
	if (ParamCount = 1) then
		begin
		valores := TStringList.Create;
		gravalog('Parâmetro único de inicialização.' , sLog);

		try
			try
			//Recupera os parâmetros separados por '|' recebidos pelo executável.
			parametros := ExtractStrings(['|'],[' '],PChar( ParamStr(1) ), valores );

			//Substitui o caracter '*' por ' ' em cada parâmetros.
			For parametro := 0 to ( parametros - 1 ) do
				valores[parametro] := StringReplace( valores[parametro], '*', ' ', [rfReplaceAll, rfIgnoreCase] );

			//Passa os parâmetros para a função principal.
			if ( parametros > 0 ) then
				inicial(PChar(valores[0]), PChar(valores[1]), PChar(valores[2]), PChar(valores[3]), PChar(valores[4]),
                                        PChar(valores[5]), PChar(valores[6]), PChar(valores[7]), PChar(valores[8]), PChar(valores[9]),
                                        PChar(valores[10]), PChar(valores[11]), PChar(valores[12]), PChar(valores[13]), PChar(valores[14]),
                                        PChar(valores[15]), PChar(valores[16]), PChar(valores[17]), PChar(valores[18]), PChar(valores[19]),
                                        PChar(valores[20]), PChar(valores[21]), PChar(valores[22]), PChar(valores[23]), PChar(valores[24]),
                                        PChar(valores[25]), PChar(valores[26]) );


			//Captura as excessões para realizar tratamento personalizado.
			Except
				On e:Exception Do
				Begin
					if GetRPTRunOnServer() then
						//Quando a execução for servidor as mensagens de erro são gravadas apenas no log.
						gravalog('Generic Error  -> ' + e.Message, sLog)
					else
						//Quando a execução é local, a exibição da mensagem é exibida para o usuário.
						ShowMessage(e.Message);
					End;
			End;
		finally
			FreeAndNil(valores);
		end;
	end
	else
	begin
		if GetRPTRunOnServer() then
		   gravalog('Parâmetros de execução incorretos. O fonte crystal.prw deve estar com data igual ou superior a 20/12/2011.', sLog)
		else
		begin
			ShowMessage('Parâmetros de execução incorretos.'
			+ #13#10 +
			'O fonte crystal.prw deve estar com data igual ou superior a 20/12/2011.'
			+ #13#10 +
			'Informe sobre este erro ao administrador do sistema. ');
		end;
	end;
end;


procedure inicial(sCaminho, sNome, nOrdem, sFiltro, sGrupoEmpresa, sTitulo, nDestino, nCopias, sCoords, sHandle, bAtualiza, nIdioma, sLogin,  sEmpresa, sUnidade, sFilial, sParams, sSX1, sSX2, sPassAdm, sEnv, sSrv, sAutoConfig, bShowGauge, bRunOnServer, sUserPath, sTables : PChar);
var
    Report : IReport;
    Application1 : TApplication;
begin
	ThousandSeparator 	:= cVIRGULA;
	DecimalSeparator 	:= cPONTO;
	slLista           	:= TStringList.Create;
	slSTR             	:= TStringList.Create;
	Application1      	:= TApplication.Create(fMain);
	bProcessa         	:= True;

	//Loga a versão da aplicação. .
	gravalog('Diretório do SGCRYS32  -> ' + sAppPath, sLog);
	gravalog('Versao -> ' + cVERSION + ' ' + cBUILD, sLog);

	//Loga os parâmetros recebidos.
	gravalog('Param1 -> ' + strPas(sCaminho), sLog);
	gravalog('Param2 -> ' + strPas(sNome), sLog);
	gravalog('Param3 -> ' + strPas(nOrdem), sLog);
	gravalog('Param4 -> ' + strPas(sFiltro), sLog);
	gravalog('Param5 -> ' + strPas(sGrupoEmpresa), sLog);
	gravalog('Param6 -> ' + strPas(sTitulo), sLog);
	gravalog('Param7 -> ' + strPas(nDestino), sLog);
	gravalog('Param8 -> ' + strPas(nCopias), sLog);
	gravalog('Param9 -> ' + strPas(sCoords), sLog);
	gravalog('Param10 -> ' + strPas(sHandle), sLog);
	gravalog('Param11 -> ' + strPas(bAtualiza), sLog);
	gravalog('Param12 -> ' + strPas(nIdioma), sLog);
	gravalog('Param13 -> ' + Encrip(strPas(sLogin)), sLog);
	gravalog('Param14 -> ' + strPas(sEmpresa), sLog);
	gravalog('Param15 -> ' + strPas(sUnidade), sLog);
	gravalog('Param16 -> ' + strPas(sFilial), sLog);
	gravalog('Param17 -> ' + strPas(sParams), sLog);
	gravalog('Param18 -> ' + strPas(sSX1), sLog);
	gravalog('Param19 -> ' + strPas(sSX2), sLog);
	gravalog('Param20 -> ' + Encrip(strPas(sPassAdm)), sLog);
	gravalog('Param21 -> ' + strPas(sEnv), sLog);
	gravalog('Param22 -> ' + strPas(sSrv), sLog);
	gravalog('Param23 -> ' + strPas(sAutoConfig), sLog);
	gravalog('Param24 -> ' + strPas(bShowGauge), sLog);
	gravalog('Param25 -> ' + strPas(bRunOnServer), sLog);
	gravalog('Param26 -> ' + strPas(sUserPath), sLog);
	gravalog('Param27 -> ' + strPas(sTables), sLog);

	sRPTPath 			:= strPas(sCaminho);
	sRPTNome 			:= strPas(sNome);

	if Trim(strPas(nOrdem)) <> cVAZIO then
		nRPTOrdem       := strtoint( strPas( nDestino ) )
	else
		nRPTOrdem 		:= 0;

	sRPTFiltro 			:= strPas(sFiltro);
	sRPTGrupoEmpresa 	:= strPas(sGrupoEmpresa);
	sRPTTitulo 			:= strPas(sTitulo);

	if Trim(strPas(nDestino)) <> cVAZIO then
		nRPTDest 		:= strtoint(strPas(nDestino))
	else
		nRPTDest 		:= 0;

	if Trim(strPas(nCopias)) <> cVAZIO then
		nRPTCopias 		:= strtoint(strPas(nCopias))
	else
		nRPTCopias 		:= 1;

	sRPTCoord 			:= strPas(sCoords);
	sRPTHandle 			:= strPas(sHandle);
	bRPTAtualiza 		:= Trim(strPas(bAtualiza)) = cZERO;

	if Trim(strPas(nIdioma)) <> cVAZIO then
		nRPTIdioma 		:= strtoint(strPas(nIdioma))
	else
		nRPTIdioma 		:= 1;

	sRPTLogin 			:= strPas(sLogin);
	sRPTEmpresa       	:= strPas( sEmpresa );
	sRPTUnidade       	:= strPas( sUnidade );
	sRPTFilial        	:= strPas( sFilial );
	sRPTParams        	:= strPas( sParams );

	if (trim(strPas(sPassAdm)) = cPWDADMVAZIO) or  (trim(strPas(sPassAdm)) = cPWDADMOIZAV) then
		sRPTPassAdm := cVAZIO
	else
		sRPTPassAdm := copy(trim(strPas(sPassAdm)),2 ,length(trim(strPas(sPassAdm)))-2);

	sRPTEnv             := strPas(sEnv);
	sRPTSrv             := RetSRV(trim(strPas(sSRV)));
	bRPTShowGauge       := Trim(strPas(bShowGauge)) = 'T';
	sRPTUserPath        := Trim(strPas(sUserPath));

	SetRPTRunOnServer(Trim(strPas(bRunOnServer)) = 'T');

	//Verifica o destino do relatório:
	//4 - Excel
	//5 - Excel Tabular
	//6 - PDF
	//7 - Text
	//8 - Word

	//Excel 7.0
	if (nRPTDest = nXLS) then
	begin
		bRPTExport := true;
		nRPTFormatType := 27;
		sRPTExtExport := cPXLS;
	end
	//Excel 7.0 Tabular
	else if (nRPTDest = nXLSTabular) then
	begin
		bRPTExport := true;
		nRPTFormatType := 28;
		sRPTExtExport := cPXLS;
	end
	//Portable Document format (PDF)
	else if (nRPTDest = nPDF) then
	begin
		bRPTExport := true;
		nRPTFormatType := 31;
		sRPTExtExport := cPPDF;
	end
	//Texto
	else if (nRPTDest = nTXT)  then
	 begin
		bRPTExport := true;
		nRPTFormatType := 8;
		sRPTExtExport := cPTXT;
	end
	//Word
	else if (nRPTDest = nDOC)  then
	begin
		bRPTExport := true;
		nRPTFormatType := 39;
		sRPTExtExport := cPDOC;
	end;

	//Recupera o caminho do arquivo de configuração.
	sRPTSXAutoConfig := sAutoConfig;

	//Validação do Crysini.
	gravalog('Antes do ValidaCrysini', sLog);
	ValidaCrysini();
	gravalog('Depois do ValidaCrysini', sLog);

	//Recupera o valor da chave UPDODBCPATH do crysini.ini.
	if sUpdODBCPath = cUM then
		bUpdODBCPath := True;

	//Recupera o valor da chave EXPORT do crysini.ini.
	if ( sRPTUserPath = cVAZIO) then
	begin
	    if sExportPath = cVAZIO then
		    sRPTExport := cRAIZ +  Trim(sRPTTitulo)
	    else
		    sRPTExport := sExportPath + cBARINV +  Trim(sRPTTitulo)
	    end
	else
	begin
		sRPTExport  := sRootPath + sRPTUserPath + cBARINV +  Trim(sRPTTitulo);
	end;

        //Recupera o caminho do arquivo do relatório.
        sRPTOpen   := sRootPath + sRPTPath;

	GravaLog('Caminho RPT -> ' + sRPTOpen, sLog);

	CriaGauge();
	IncGauge(5);

	//Valida o arquivo com conteúdo dos parâmetros usados no relatório.
	if ValidaArq(sSXPath + cBARINV + strPas(sSX1), cVAZIO) then
	begin
		sRPTSX1 := sSXPath + cBARINV + strPas(sSX1);
        aArquivos.Add( sRPTSX1 );
	end
	else
		sRPTSX1 := strPas(sSX1);

        GravaLog('Caminho SX1 -> ' + sRPTSX1, sLog);

	//Valida o arquivo com conteúdo do compartilhamento das tabelas usadas no relatório.
	if ValidaArq(sSXPath + cBARINV + strPas(sSX2), cVAZIO) then
	begin
		sRPTSX2 := sSXPath + cBARINV + strPas(sSX2);
        aArquivos.Add( sRPTSX2 );
	end
	else
		sRPTSX2 := strPas(sSX2);

        GravaLog('Caminho SX2 -> ' + sRPTSX2, sLog);
	GravaLog('Antes do ValidaRPT', sLog);

	if Not ValidaArq(sRPTOpen,SetTexto(1, nRPTIdioma) + sRPTOpen) and bProcessa then
		bProcessa := False;

	IncGauge(5);
	gravalog('Depois do ValidaRPT', sLog);

	gravalog('Antes da abertura do RPT', sLog);
	if bProcessa then
	begin
		if (nRPTIdioma <> 0) then
		begin
			sSTROpen := ChangeFileExt(sRPTOpen, cPCH);
			GravaLog('Caminho do CH -> ' + sSTROpen, sLog);
			if ValidaArq(sSTROpen,cVAZIO) then
			begin
				slSTR := LeCH(sSTROpen, nRPTIdioma);
			end;
		end;
		Report := Application1.OpenReport(sRPTOpen, crOpenReportByTempcopy);
	end;

	gravalog('Depois da abertura do RPT', sLog);

	if bProcessa and bRPTAtualiza then
	begin
		gravalog('Inicio do processamento', sLog);

		gravalog('Antes de descartar os dados', sLog);
		Report.DiscardSavedData;
		gravalog('Depois de descartar os dados', sLog);

		gravalog('Antes do TrocarTabelas', sLog);
		Report := TrocarTabelas(Report);
		IncGauge(5);
		gravalog('Depois do TrocarTabelas', sLog);

		gravalog('Antes do PreencheParams', sLog);
		Report := PreencheParams(Report);
		IncGauge(5);
		gravalog('Depois do PreencheParams', sLog);

		//Neste ponto, verifica se os parâmetros do relatório foram preenchidos corretamente.
		if bProcessa then
		begin
			gravalog('Antes do TratarFormulas', sLog);
			Report := TratarFormulas(Report, sTables);
			IncGauge(5);
			gravalog('Depois do TratarFormulas', sLog);

			gravalog('Antes do SubReports', sLog);
			Report := SubReports(Report);
			IncGauge(45);
			gravalog('Depois do SubReports', sLog);
		end;

		gravalog('Fim do processamento', sLog);
	end
	else
	begin
		IncGauge(65);
		gravalog('Não realizou processamento', sLog);
	end;

	if bProcessa then
		//bRPTExport será true quando o tipo de impressão for 4,5 ou 6.
		if bRPTExport = true then
		begin
			gravalog('Antes da Exportação do Relatório', sLog);
			gravalog('Caminho de Exportação->' + sRPTExport , sLog);

			//nRPTFormatType, Exportação para arquivo
			Report.ExportOptions.Reset;
			Report.ExportOptions.DestinationType    := crEDTDiskFile;
			Report.ExportOptions.FormatType         := nRPTFormatType;
			Report.ExportOptions.DiskFileName       := sRPTExport + sRPTExtExport;
			Report.Export(false);

			gravalog('Depois do Exportação do Relatório', sLog);
		end
	    else
	    begin
		    //Exibição do relatório em vídeo.
		    if (nRPTDest = 1) then
		    begin
			    gravalog('Antes da exibição do relatório em vídeo', sLog);
			    With TfViewer.Create(fMain) do
			    begin
				    IncGauge(10);
				    Caption := cVERSION + '   [' + cBUILD + ']';
				    RepView := Report;
				    sArquivo := sLog;
				    //Desabilita a opção de impressão quando configurada esta opção no crysini.
				    CRViewer91.EnablePrintButton := RetValINI(sAppPath + cBARINV + cCRYSINI, cPATH, cPRINT, cUM) = cUM;
				    //Desabilita a opção de atualização quando executado no servidor ou sem a opção atualiza marcada.
				    CRViewer91.EnableRefreshButton := Trim(strPas(bAtualiza)) = cZERO;
				    CRViewer91.ReportSource := Report;
				    ShowModal;
				    gravalog('Depois da exibição do relatório em vídeo', sLog);
			    end;
		    end
		    else
		    begin
			    gravalog('Antes do envio do relatório para a impressora', sLog);
			    IncGauge(10);
			    FechaGauge();
			    nRPTMinPage := 1;
			    nRPTMaxPage := Report.PrintingStatus.Get_NumberOfPages;

			    //Impressora com tela de escolha de printers.
			    if (nRPTDest = 2) then
                begin
                    gravalog('Não pediu Parâmetros de impressão', sLog);
                    Report.PrintOut(false, nRPTCopias, true, nRPTMinPage, nRPTMaxPage);
			    end
			    //Impressora com tela de escolha de printers.
                else if(nRPTDest = 3) then
		    	begin
				    gravalog('Pediu Parâmetros de impressão', sLog);
				    Report.PrinterSetup(0);
				    Report.PrintOut(false, nRPTCopias, true, nRPTMinPage, nRPTMaxPage);
		        end;
		        gravalog('Depois do envio do relat¶ório para a impressora', sLog);
        end;
	end;

        gravalog('Instrução executada -> ' + Report.SQLQueryString, sLog);
	gravalog('Fim da execução do programa', sLog);
	gravalog('Antes do deleta arquivos', sLog);
	DeletaArqs(aArquivos, sLog);
	gravalog('Depois do deleta arquivos', sLog);
    
	aArquivos.Destroy;
end;


//Realiza a validação dos valores informados no arquivo de configuração [CRYSINI.INI].
procedure ValidaCrysini();
begin
    //Exibe o caminho do arquivo CRYSINI.INI.
    gravalog('Lendo CRYSINI em: ' + sAppPath, sLog);

    //Verifica a existência do arquivo CRYSINI.INI.
    if (Not FileExists(sAppPath + cBARINV + cCRYSINI)) then
    begin
		//Verifica se o caminho informado na chave DATA é válido.
		if (Not DirectoryExists(RetValINI(sAppPath + cBARINV + cCRYSINI, cPATH, cDATA, cVAZIO))) then
		begin
			gravalog('Diretório informado na chave DATA é inválido', sLog);
		end;

		//Verifica se o caminho informado na chave SXS é válido.
		if (Not DirectoryExists(RetValINI(sAppPath + cBARINV + cCRYSINI, cPATH, cSXS, cVAZIO))) then
		begin
			gravalog('Diretório informado na chave SXS é inválido', sLog);
		end;

		if (Not GetRPTRunOnServer()) then
		begin
			//Abre a tela para o preenchimento dos parâmetros do arquivo CRYSINI.INI.
			gravalog('Antes da chamada da tela do ' + cCRYSINI, sLog);
			With TfCrysini.Create(fMain) do
			begin
				Caption := cVERSION;
				sPathEXE := sAppPath;
				ShowModal;
				gravalog('Depois da chamada da tela do ' + cCRYSINI, sLog);
			end;
		end;
    end;

    //Recupera os valores das chaves do CRYSINI.INI.
    sRootPath    := RetValINI(sAppPath + cBARINV + cCRYSINI, cPATH, cDATA, cVAZIO);
    sSXPath      := RetValINI(sAppPath + cBARINV + cCRYSINI, cPATH, cSXS, cVAZIO);
    sExportPath  := RetValINI(sAppPath + cBARINV + cCRYSINI, cPATH, cEXPORT, cVAZIO);
    sUpdODBCPath := RetValINI(sAppPath + cBARINV + cCRYSINI, cPATH, cUPDODBCPATH, cVAZIO);
 
    //Exibe os valores das chaves do arquivo CRISINI.INI.
    gravalog('Valor da linha ' + cSXS  + ' do ' + cCRYSINI + ' -> ' + sSXPath, sLog);
    gravalog('Valor da linha ' + cDATA + ' do ' + cCRYSINI + ' -> ' + sRootPath, sLog);
    gravalog('Valor da linha ' + cEXPORT  + ' do ' + cCRYSINI + ' -> ' + sExportPath, sLog);
end;


procedure ValidaSenha();
var
    F : TextFile;
begin
	if (Not ValidaArq(sAppPath + cBARINV + cCRTOP, cVAZIO)) then
	begin
		gravalog('Senha informada sem uso do ' + cCRTOP, sLog);
		
		if (trim(sRPTLogin) = cBARRA) or (trim(sRPTLogin) = cVAZIO) then
		begin
			gravalog('Ocorreu erro na valiação do usuário ou senha!', sLog);
            (*
			With TfSenha.Create(fMain) do
			begin
				sLogin := sRPTLogin;
				ShowModal;
				sRPTLogin := sLogin;
				gravalog('Depois da chamada da tela de Login', sLog);
				gravalog('Login informado pelo usuário via tela -> ' + sRPTLogin, sLog);
			end;
            *)
		end;
	end
	else
		begin
			gravalog('Senha informada com uso do ' + cCRTOP, sLog);
			AssignFile(F, sAppPath + cBARINV + cCRTOP);
			Reset(F);
			Readln(F, sRPTLogin);
			CloseFile(F);
			gravalog('Login informado pelo usuário via arquivo ' + cCRTOP + ' -> ' + sRPTLogin, sLog);
	end;
end;



procedure CriaGauge();
begin
	if (bRPTShowGauge) then
	Begin
		With TfGauge.Create(fMain) do
		begin
			Caption := cVERSION + ' ' + cBUILD;
			lblReport.caption :=  SetTexto(2, nRPTIdioma) + sRPTNome;

			Show;
			Update;
		end;
	end;
end;



procedure IncGauge(nValue : Integer);
var
    i : Integer;
begin
    For i:=0 to Screen.FormCount-1 do
	    if Screen.Forms[i] is TfGauge then
	    Begin
		    TfGauge(Screen.Forms[i]).ProgressBar1.StepBy(nValue);
    end;
end;


procedure FechaGauge();
var
    i : Integer;
begin
    For i:=0 to Screen.FormCount-1 do
	    if Screen.Forms[i] is TfGauge then
	    Begin
		    TfGauge(Screen.Forms[i]).Close;
    end;
end;


function PreencheParams(RPT : IReport ) : IReport;
var
    i : Integer;
    S :  String;
    SValor : String;
    slParams : TStringList;
    bProc : boolean;
begin
	slParams := TStringList.Create;
	slParams.Clear;
	aArquivos.Add(sRPTSX1);

	if RetValINI(sAppPath + cBARINV + cCRWINI, cSXS, cSX1, cUM) = cUM then
	begin
		if (trim(sRPTParams) = cVAZIO) then
		begin
			slParams := AcessaSXs(cSX1,TipoAcesso(sAppPath),sRPTSX1,sRPTEnv,sRPTPassAdm,sRPTSrv,sRPTNome,sRPTGrupoEmpresa, sRPTEmpresa, sRPTUnidade, sRPTFilial,sAppPath,sLog,nRPTIdioma );
			
			gravalog('qtde de parametros passados -> '      + inttostr(slParams.Count), sLog);
			gravalog('qtde de parametros no relatorio -> '  + inttostr(rpt.Get_ParameterFields.Get_Count), sLog);

			//Quando a execução for no servidor.
			if GetRPTRunOnServer() then
			begin
				//Verifica se a quantidade de parâmetros passados é menor do que a quantidade de parâmetros do relatório.
				if( rpt.Get_ParameterFields.Get_Count > slParams.Count ) then
				begin
					bProcessa := False;
					gravalog('Erro -> Parâmetros insuficientes para execução do relatório no servidor', sLog);
				end;
			end
	    end
	    else
	    begin
		    gravalog('qtde de parametros passados -> '      + inttostr(GetTokenAdvCount(sRPTParams, cPV)), sLog);
		    gravalog('qtde de parametros no relatorio -> '  + inttostr(rpt.Get_ParameterFields.Get_Count), sLog);

		    //Quando a execução for no servidor.
		    if GetRPTRunOnServer() then
		    begin
			    //Verifica se a quantidade de parâmetros passados é menor do que a quantidade de parâmetros do relatório.
			    if( rpt.Get_ParameterFields.Get_Count > GetTokenAdvCount(sRPTParams, cPV) ) then
			    begin
				    bProcessa := False;
				    gravalog('Erro -> Parâmetros insuficientes para execução do relatório no servidor', sLog);
            end;
		end
	end;

	for i := 1 to rpt.Get_ParameterFields.Get_Count do
	begin
		bProc := false;
		if (trim(sRPTParams) = cVAZIO) then
		begin
			if (i <= slParams.Count) then
			begin
				bProc := true;
				S := slParams.Strings[i-1];
				Gravalog('valor da linha -> ' + S, sLog);
				
				if (GetTokenAdv(S, 3, cPV) = cGET) or (GetTokenAdv(S, 3, cPV) = cSTRING) then
					sValor := GetTokenAdv(S, 2, cPV)
				else
				if (GetTokenAdv(S, 3, cPV) = cCOMBO) then
				sValor := GetTokenAdv(S, 4, cPV);
			end;
		end
		else
		begin
			if (i <= GetTokenAdvCount(sRPTParams,cPV)) then
			begin
				bProc := true;
				sValor := GetTokenAdv(sRPTParams, i, cPV);
			end;
		end;

		gravalog('Nome do Parametro ' + inttostr(i) + ' -> ' + rpt.Get_ParameterFields.Item[i].Get_Name, sLog);
		gravalog('Tipo do Parametro ' + inttostr(i) + ' -> ' + varastype(RPT.Get_ParameterFields.Item[i].Get_ValueType,8), sLog);
		gravalog('Valor atual do Parametro ' + inttostr(i) + ' -> ' + vartostr(RPT.Get_ParameterFields.Item[i].Get_CurrentValue), sLog);
	  
		if bProc then
		begin
			gravalog('Valor a ser atribuido ao parametro ' + inttostr(i) + ' -> ' + sValor, sLog);
			aParamsValores.add(sValor);
			if (varastype(RPT.Get_ParameterFields.Item[i].Get_ValueType,8) = cPARDATAHORA) then
				if (trim(sRPTParams) = cVAZIO) then
					RPT.Get_ParameterFields.Item[i].SetCurrentValue(strtodatetime(Copy(sValor,2,length(sValor)-2)),RPT.Get_ParameterFields.Item[i].Get_ValueType)
				else
					RPT.Get_ParameterFields.Item[i].SetCurrentValue(strtodatetime(sValor),RPT.Get_ParameterFields.Item[i].Get_ValueType)
				else
				begin
					if (varastype(RPT.Get_ParameterFields.Item[i].Get_ValueType,8) = cPARDATA) then
						if (trim(sRPTParams) = cVAZIO) then
							RPT.Get_ParameterFields.Item[i].SetCurrentValue(strtodate(Copy(sValor,2,length(sValor)-2)),RPT.Get_ParameterFields.Item[i].Get_ValueType)
						else
							RPT.Get_ParameterFields.Item[i].SetCurrentValue(strtodate(sValor),RPT.Get_ParameterFields.Item[i].Get_ValueType)
						else
						begin
						if (varastype(RPT.Get_ParameterFields.Item[i].Get_ValueType,8) = cPARNUM) then
							RPT.Get_ParameterFields.Item[i].SetCurrentValue(strtofloat(sValor),RPT.Get_ParameterFields.Item[i].Get_ValueType)
						else
						begin
							if (varastype(RPT.Get_ParameterFields.Item[i].Get_ValueType,8) = cPARLOGICO) then
								if UpperCase(Trim(sValor)) = cUM then
									RPT.Get_ParameterFields.Item[i].SetCurrentValue(True,RPT.Get_ParameterFields.Item[i].Get_ValueType)
								else
									RPT.Get_ParameterFields.Item[i].SetCurrentValue(False,RPT.Get_ParameterFields.Item[i].Get_ValueType)
								else
									RPT.Get_ParameterFields.Item[i].SetCurrentValue(sValor,RPT.Get_ParameterFields.Item[i].Get_ValueType);
						end;
					end;
				end;
			end;
		end;
	end;
	result := RPT;
end;


function TrocarTabelas(RPT : IReport) : IReport;
var
    x : Integer;
    i : Integer;
    n : Integer;
    S : String;
    sDSN : String;
    sDataBase : String;
    slParams : TStringList;
    xx : olevariant;
    sConBufStr : String;
    rifReg : TRegIniFile;
    cServerOracle : String;
    cDatabaseDB2 : String;
    cbuffer:Pchar;
begin
    cBuffer:=StrAlloc(255);
	sConBufStr := cVAZIO;
	slParams := TStringList.Create;
	slParams.Clear;

    if (RetValINI(sAppPath + cBARINV + cCRWINI, cSXS, cSX2, cUM) = cUM) then
		slParams := AcessaSXs(cSX2,TipoAcesso(sAppPath),sRPTSX2,sRPTEnv,sRPTPassAdm,sRPTSrv,sRPTNome,sRPTGrupoEmpresa, sRPTEmpresa, sRPTUnidade, sRPTFilial, sAppPath,sLog,nRPTIdioma );
		gravalog('qtde de tabelas RPT -> ' + inttostr(RPT.Get_Database.Get_Tables.Get_Count), sLog);

		for i := 1 to RPT.Get_Database.Get_Tables.Get_Count do
		begin
			if rpt.Get_Database.Get_Tables.Item[i].Get_DllName <> cDLLODBC then
			begin
				gravalog('DLL -> ' + rpt.Get_Database.Get_Tables.Item[i].Get_DllName, sLog);
			end;

			if (rpt.Get_Database.Get_Tables.Item[i].Get_DllName = cDLLODBC) then
			begin
				gravalog('TrocaServerODBC Realizado',sLog );
				TrocaServerODBC(Trim(rpt.Get_Database.Get_Tables.Item[i].Get_LogOnServerName),sLog);
				gravalog('Descricao -> ' + RPT.Get_Database.Get_Tables.Item[i].Get_DecriptiveName, sLog);
				sDSN 		:= Trim(rpt.Get_Database.Get_Tables.Item[i].Get_LogOnServerName);
				gravalog('DSN -> ' + sDSN, sLog);
				sBanco 		:= Trim(session.GetAliasDriverName(sDSN));
				sRPTBanco 	:= sBanco;
				gravalog('Banco - > ' + sBanco, sLog);
				sDataBase 	:= Trim(rpt.Get_Database.Get_Tables.Item[i].Get_LogOnDatabaseName);
				gravalog('DataBase -> ' + sDataBase, sLog);
				
				if (Pos(cDBASE,UpperCase(sBanco)) = 0) and (Pos(cFOXPRO,UpperCase(sBanco)) = 0) then
				begin
					gravalog('Antes do ValidaSenha', sLog);
					ValidaSenha();
					gravalog('Depois do ValidaSenha', sLog);
				end;

				IncGauge(5);

				gravalog('Alias RPT-> ' + RPT.Get_Database.Get_Tables.Item[i].Get_Name, sLog);
				gravalog('Tabela RPT-> ' + RPT.Get_Database.Get_Tables.Item[i].Get_Location, sLog);

				S := trim(RPT.Get_Database.Get_Tables.Item[i].Get_Location);
				n := -1;

				if (Copy(trim(RPT.Get_Database.Get_Tables.Item[i].Get_Location), length(trim(RPT.Get_Database.Get_Tables.Item[i].Get_Location))-1, 2) <> cProcedure) and (slParams.Count > 0) then
				begin
					gravalog('Nao e procedure', sLog);
					n := LocalInd(slParams, 1, 3, Copy(RPT.Get_Database.Get_Tables.Item[i].Get_Location, 1, 3));

					if n >= 0 then
					begin
						gravalog('Item encontrado -> ' + slParams[n], sLog);
						if Pos(cPOSTGRE, UpperCase(sBanco)) > 0 then
							S := LowerCase(slParams[n])
						else
							S := slParams[n];
						gravalog('Tabela SX2 -> ' + GetTokenAdv(S, 1, cPV), sLog);
					end
					else
					begin
						gravalog('Nenhum item localizado', sLog);
						S := RPT.Get_Database.Get_Tables.Item[i].Get_Location;
					end;
				end;

				if ((Pos(cDBASE,UpperCase(sBanco)) <> 0) or (Pos(cFOXPRO,UpperCase(sBanco)) <> 0)) and bUpdODBCPath then
				begin
					gravalog('DBASE ou FOXPRO', sLog);
					rifReg := TRegIniFile.Create;
					rifReg.RootKey := HKEY_LOCAL_MACHINE;

					if rifReg.OpenKey(PATHREG + sDSN, false) then
					begin
						gravalog('Path Current -> ' + rifReg.CurrentPath, sLog);

						//dBase.
						if (Pos(cDBASE,UpperCase(sBanco)) > 0) then
							if n > 0 then
								rifReg.WriteString(cVAZIO,cDEFDIR,sRootPath + GetTokenAdv(slParams[n],2,cPV))
							else
								rifReg.WriteString(cVAZIO,cDEFDIR,sSXPath);
								
						//Fox Pro.
						if (Pos(cFOXPRO,UpperCase(sBanco)) > 0) then
							if n > 0 then
								rifReg.WriteString(cVAZIO,cSOURCEDB,sRootPath + GetTokenAdv(slParams[n],2,cPV))
							else
								rifReg.WriteString(cVAZIO,cSOURCEDB,sSXPath);

				end;
				rifReg.Free;
			end
			else
			begin
				gravalog('BASE TOP', sLog);
				rifReg := TRegIniFile.Create;
				
				if rifReg.OpenKey(PATHREG + sDSN, false) then
				begin
					cServerORACLE := rifReg.ReadString(cVAZIO, 'SERVER', cVAZIO);
					cDataBaseDB2 := rifReg.ReadString(cVAZIO, 'SERVER', cVAZIO);
					sDataBase := rifReg.ReadString(cVAZIO, cDATABASE, cVAZIO);
					gravalog('sDataBase -> ' + sDataBase, sLog);
				end;
				
				rifReg.Free;
				gravalog('Informacoes de login -> sDSN=' + sDsn + '-sDatabase=' + sDatabase + '-User=' + Encrip(Trim(GetTokenAdv(sRPTLogin,1,cBARRA))) + '-Pwd=' + Encrip(Trim(GetTokenAdv(sRPTLogin,2,cBARRA))), sLog);
				RPT.Get_Database.Get_Tables.Item[i].SetLogOnInfo(sDSN,sDataBase,Trim(GetTokenAdv(sRPTLogin,1,cBARRA)),Trim(GetTokenAdv(sRPTLogin,2,cBARRA)));
			end;
			
			if (n >= 0) then
			begin
				gravalog('Atualizando localizacao', sLog);
				if (Pos(cDBASE,UpperCase(sBanco)) <> 0) or (Pos(cFOXPRO,UpperCase(sBanco)) <> 0) then
				begin
					gravalog('antes location DBASE ou FOXPRO', sLog);
					RPT.Get_Database.Get_Tables.Item[i].Location := GetTokenAdv(S, 1, cPV);
					RPT.Get_Database.Get_Tables.Item[i].CheckDifferences(x,xx);
					
					if (i = RPT.Get_Database.Get_Tables.Get_Count) then
						RPT.Get_Database.Verify;
				end
				else if (Pos('ORACLE',UpperCase(sBanco)) <> 0) then //Microsoft ODBC Oracle
				begin
					gravalog('Location -> ' + RPT.Get_Database.Get_Tables.Item[i].Get_Location(), sLog);
					sConBufStr := 'DSN='+RPT.Get_Database.Get_Tables.Item[i].Get_LogOnServerName+';;User ID='+GetTokenAdv(sRPTLogin,1,cBARRA)+';;Password='+GetTokenAdv(sRPTLogin,2,cBARRA)+';;SERVER=ORACLE';
					gravalog('BASE ORACLE (CONNBUFFER )'+sConBufStr , sLog);
					RPT.Get_Database.Get_Tables.Item[i].SetTableLocation(GetTokenAdv(S, 1, cPV), GetTokenAdv(S, 1, cPV), sConBufStr);
					RPT.Get_Database.Get_Tables.Item[i].Location := GetTokenAdv(S, 1, cPV);
					RPT.Get_Database.Get_Tables.Item[i].CheckDifferences(x,xx);
					
					if (i = RPT.Get_Database.Get_Tables.Get_Count) then
						RPT.Get_Database.Verify;
				end
				else if (Pos('DB2',UpperCase(sBanco)) <> 0) then
				begin
					 cDataBaseDB2:=RetValINI(trim(strpas(cBuffer))+'\DB2CLI.INI',RPT.Get_Database.Get_Tables.Item[i].LogOnServerName,'DBALIAS','');
					 RPT.Get_Database.Get_Tables.Item[i].SetLogOnInfo(sDSN,cDataBaseDB2,Trim(GetTokenAdv(sRPTLogin,1,cBARRA)),Trim(GetTokenAdv(sRPTLogin,2,cBARRA)));
					 RPT.Get_Database.Get_Tables.Item[i].Location := GetTokenAdv(S, 1, cPV);
					 RPT.Get_Database.Get_Tables.Item[i].CheckDifferences(x,xx);
					 
					 if (i = RPT.Get_Database.Get_Tables.Get_Count) then
					   RPT.Get_Database.Verify;
				end
				else  //SQL Server/INFORMIX/outros
				begin
					gravalog('Antes do Location SQL', sLog);
					gravalog('Valor Inicial :' + RPT.Get_Database.Get_Tables.Item[i].Get_Location , sLog);
					gravalog('Valor Final   :' + GetTokenAdv(S, 1, cPV), sLog);

					RPT.Get_Database.Get_Tables.Item[i].Location := GetTokenAdv(S, 1, cPV);

					gravalog('Depois do Location SQL', sLog);

                    if (i = RPT.Get_Database.Get_Tables.Get_Count) then
						RPT.Get_Database.Verify;
				end;
				slLista.Add(GetTokenAdv(S, 1, cPV) + cPV + GetTokenAdv(S, 3, cPV) + cPV + GetTokenAdv(S, 4, cPV) + cPV + GetTokenAdv(S, 5, cPV) + cPV + GetTokenAdv(S, 6, cPV) );
			end;
		end;
    end;
	
	if (Pos(cDBASE,UpperCase(sBanco)) <> 0) or (Pos(cFOXPRO,UpperCase(sBanco)) <> 0) then
			RPT.Set_FieldMappingType(2);
			
	result := RPT;
	strdispose(cBuffer);
end;

//------------------------------------------------------------------------------------------------------
// Função que trata as fórmulas do crystal, TRATAFILIAL (Trata filiais)
// e TRATASQLDEL(registros deletados)
//
//  @param RPT          : Recebe o relatório.
//  @param sTables      : Recebe as tabelas que não terão tratamento de filial e registros deletados
//------------------------------------------------------------------------------------------------------
function TratarFormulas(RPT : IReport; sTables: PChar) : IReport;
var
    i             : Integer;
    n             : Integer;
    nPosicao      : Integer;
    sTipoEmpresa  : String;
    sTipoUnidade  : String;
    sTipoFilial   : String;
    sLayout       : String;
    nSTR          : Integer;
    sFormula      : string;
    sTabComp      : String;
begin

	gravalog('Fórmula de Seleção Grupo 	-> ' + RPT.Get_GroupSelectionFormula, sLog);
	gravalog('Fórmula de Seleção Inicial 	-> ' + RPT.Get_RecordSelectionFormula, sLog);
	gravalog('Quantidade de Fórmulas 	-> ' + inttostr(RPT.Get_FormulaFields.Get_Count), sLog);

	for i := 1 to RPT.Get_FormulaFields.Get_Count do
	begin
		sFormula := RPT.Get_FormulaFields.Item[i].Get_FormulaFieldName;
		GravaLog('Formula -> ' + sFormula, sLog);

		if (Copy(sFormula, 1, 1) = cPIPE) then
		begin
			if (Pos(cDBASE,UpperCase(sRPTBanco)) <> 0) or (Pos(cFOXPRO,UpperCase(sRPTBanco)) <> 0) then
			begin
				gravalog('Conteúdo Original -> ' + RPT.Get_FormulaFields.Item[i].Get_Text, sLog);
				RPT.Get_FormulaFields.Item[i].Set_Text(cABRECH + Copy(sFormula, 2, length(sFormula)-1) + cFECHACH);
				gravalog('Novo Conteúdo     -> ' +  RPT.Get_FormulaFields.Item[i].Get_Text, sLog);
			end;
		end;

		if (slSTR.Count > 0) then
		begin
			if (Copy(sFormula, 1, 3) = cSTR) then
			begin
				nSTR := strtoint(Copy(sFormula, 4, 4));
				if ((slSTR.Count-1) >= nSTR-1) then
				begin
					gravalog('Conteúdo Original -> ' + RPT.Get_FormulaFields.Item[i].Get_Text, sLog);
					RPT.Get_FormulaFields.Item[i].Set_Text(slSTR[nSTR-1]);
					gravalog('Novo Conteúdo     -> ' +  RPT.Get_FormulaFields.Item[i].Get_Text, sLog);
				end
				else
					gravalog('STR -> ' + inttostr(nSTR) + ' nao encontrado no CH', sLog);
			end;
		end;

		if (uppercase(trim(sFormula)) = cTRATASQLDEL) then
		begin
			for n := 1 to RPT.Get_Database.Get_Tables.Get_Count do
			begin
                                // Recebe as três primeiras posições da tabela da vez.
                                sTabComp := Copy(RPT.Get_Database.Get_Tables.Item[n].Get_Name, 1, 3);

                                // Verifica se a tabela da vez está contida na tabela a ser tratada.
                                if pos(sTabComp, sTables) > 0 then
                                begin
                                        gravalog('A Tabela ' + RPT.Get_Database.Get_Tables.Item[n].Get_Name + ' não irá receber tratamento de Delete.', sLog);
                                end
                                else
                                begin
                                        RPT.Set_RecordSelectionFormula(IncWhere(RPT.Get_RecordSelectionFormula, Deletado(sBanco, RPT.Get_Database.Get_Tables.Item[n].Get_Name) + cDIFERENTE + cASPASDUP + cASTERISCO + cASPASDUP, cAND));
               				gravalog('Nova Fórmula de Seleção -> ' + RPT.Get_RecordSelectionFormula, sLog);        
                                end;
			end;
		end;

                sTabComp := ''; // Zera variável.

		if ( uppercase( trim( sFormula ) ) = cTRATAFILIAL ) then
		begin
                        if (RetValINI(sAppPath + cBARINV + cCRWINI, cSXS, cSX2, cUM) = cUM) then
                        begin
			    //Para cada tabela presente no relatório
			    for n := 1 to RPT.Get_Database.Get_Tables.Get_Count do
			    begin
				    sTipoEmpresa    := cVAZIO;
				    sTipoUnidade    := cVAZIO;
				    sTipoFilial     := cVAZIO;

				    //Localiza o alias da tabela na lista gerada pela função CRWSX2 do Protheus
				    nPosicao := LocalInd(slLista, 1, 3, Copy(RPT.Get_Database.Get_Tables.Item[n].Get_Location, 1, 3));

				    if ( nPosicao >= 0 ) then
                                    begin
				        //Recupera o compartilhamento de Empresa, Unidade de Negócio e Filial
                                        sLayout      := GetTokenAdv(slLista[nPosicao], 5, cPV);
				        sTipoEmpresa := GetTokenAdv(slLista[nPosicao], 4, cPV);
				        sTipoUnidade := GetTokenAdv(slLista[nPosicao], 3, cPV);
				        sTipoFilial  := GetTokenAdv(slLista[nPosicao], 2, cPV);

				        gravalog('Tabela: '             + GetTokenAdv(slLista[nPosicao], 1, cPV), sLog);
				        gravalog('Empresa: '            + sTipoEmpresa, sLog);
				        gravalog('Unidade de Negócio: ' + sTipoUnidade, sLog);
				        gravalog('Filial: '             + sTipoFilial, sLog);
                                        gravalog('Layout: '             + sLayout, sLog);

                                        // Recebe as três primeiras posições da tabela da vez.
                                        sTabComp := Copy(RPT.Get_Database.Get_Tables.Item[n].Get_Name, 1, 3);

                                        // Verifica se a tabela da vez está contida na tabela a ser tratada.
                                        if pos(sTabComp, sTables) > 0 then
                                        begin
                                                gravalog('A Tabela ' + RPT.Get_Database.Get_Tables.Item[n].Get_Name + ' não irá receber tratamento de Filial.', sLog);
                                        end
                                        else
                                        begin
                                                //Monta fórmula de seleção de compartilhamento de tabela
				                RPT.Set_RecordSelectionFormula(IncWhere(RPT.Get_RecordSelectionFormula, Filial(RPT.Get_Database.Get_Tables.Item[n].Get_Name, RPT.Get_Database.Get_Tables.Item[n].Get_Location, sTipoEmpresa, sTipoUnidade, sTipoFilial, sRPTEmpresa, sRPTUnidade, sRPTfilial, sLayout), cAND));
				                gravalog('Nova Fórmula de Seleção -> ' + RPT.Get_RecordSelectionFormula, sLog);
                                        end;
                                    end;
                              end;
			end;
		end;
	end;

	gravalog('Fórmula de Seleção Final -> ' + RPT.Get_RecordSelectionFormula, sLog);
	result := RPT;
end;


function SubReports(RPT : IReport) : IReport;
var
    Sections : ISections;
    Section : ISection;
    RepObjects : IReportObjects;
    RepObject : IReportObject;
    SubObject : ISubReportObject;
    SubReport : IReport;
    n : Integer;
    j : Integer;
begin
	Sections := RPT.Get_Sections;

	for n := 1 to Sections.Get_Count do
	begin
		Section := Sections.Get_Item(n);
		RepObjects := Section.Get_ReportObjects;
		for j := 1 to RepObjects.Get_Count do
		begin
			  RepObject := IReportObject(RepObjects.Get_Item(j));
			  if (RepObject.Get_Kind = crSubreportObject) then
			  begin
					gravalog('Tem SubRelatorio', sLog);
					SubObject := ISubReportObject(RepObject);
					SubReport := SubObject.OpenSubreport;
					Gravalog('Antes Trocar Tabelas - SubReport -> ' + inttostr(j), sLog);
					SubReport := TrocarTabelas(SubReport);
					Gravalog('Depois Trocar Tabelas - SubReport -> ' + inttostr(j), sLog);
					Gravalog('Antes Tratar Formulas - SubReport -> ' + inttostr(j), sLog);
					SubReport := TratarFormulas(SubReport, '');
					Gravalog('Depois Tratar Formulas - SubReport -> ' + inttostr(j), sLog);
			  end;
		end;
	end;
	result := RPT;
end;


procedure TfMain.FormShow(Sender: TObject);
begin
  fMain.Close;
end;


procedure TfMain.FormDestroy(Sender: TObject);
begin
  aParamsValores.Free;
end;


end.

