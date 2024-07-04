unit Lib;

interface

uses
Classes, SysUtils, Dialogs, IniFiles, Registry, Windows, Winsock, i18n;

const
  //Produto e Versão
  cVERSION     = 'Protheus Crystal Integration';
  cBUILD       = '20140130';

  cABRECH      = '{';
  cABRECOLCHE  = '[';
  cACTIVE      = 'ACTIVE';
  cADM         = 'Administrador';
  cAND         = ' AND ';

  //Versões do Protheus suportadas.
  cAP5         = 'AP5';
  cAP6         = 'AP6';
  cAP7         = 'AP7';
  cMP8         = 'MP8';
  cP10         = 'P10';
  cP11         = 'P11';

  cASPASDUP    = '"';
  cASTERISCO   = '*';
  cBARINV      = '\';
  cBARRA       = '/';
  cBRANCO      = ' ';
  cCOMBO       = 'C';
  cCRTOP       = 'crtop.yyx';
  cCRWINI      = 'crwini.ini';
  cCRYSINI     = 'crysini.ini';
  cCRWAUTO     = 'crwauto.ini';
  cDATA        = 'DATA';
  cDATABASE    = 'DataBase';
  cDBASE       = 'DBAS';
  cDEFDIR      = 'DefaultDir';
  cDIFERENTE   = ' <> ';
  cDISTR       = 'DISTRIBUTION';
  cDLL         = 'DLL';
  cDLLODBC     = 'crdb_odbc.dll';
  cDRIVERS     = 'DRIVERS';
  cDSNDATA     = 'DSNDATA';
  cDSNSXS      = 'DSNSXS';
  cELSE        = '#ELSE';
  cENDIF       = '#ENDIF';
  cENVIRONMENT = 'ENVIRONMENT';
  cFECHACH     = '}';
  cFECHACOLCHE = ']';
  cFILELOG     = 'crlog.log';
  cFILIAL      = '_FILIAL';
  cFOXPRO      = 'FOX';
  cFUNCAO      = 'CRWSX';
  cGERAPDF     = 'GERAPDF';
  cGET         = 'G';
  cIFDEFSPA    = '#IFDEF SPANISH';
  cIFDEFENG    = '#IFDEF ENGLISH';
  cINTERROG    = '?';
  cIGUAL       = '=';
  cLOCAL       = 'LOCAL';
  cLOCALPDF    = 'LOCALPDF';
  cLOG         = 'LOG';
  cNOME        = 'NOME';
  cODBCDATA    = 'ODBCDATA';
  cODBCSXS     = 'ODBCSXS';
  cIPEXTERNO   = 'IPEXTERNO';
  cIPINTERNO   = 'IPINTERNO';
  cPATHLOG     = 'PATHLOG';
  cPATH        = 'PATH';
  cAUTO        = 'AUTO';
  cPARDATA     = '10';
  cPARDATAHORA = '16';
  cPARLOGICO   = '9';
  cPARNUM      = '7';
  cPCH         = '.ch';
  cPFTC        = '.ftc';
  cPRINT       = 'PRINT';
  cPIPE        = '|';
  cPONTO       = '.';
  cPORT        = 'PORT';
  cPOSTGRE     = 'POSTGRE';
  cPREG        = '.reg';
  cPROCEDURE   = ';1';
  cPROTCRW     = 'protcrw.ini';
  cPTXT        = '.txt';
  cPV          = ';';
  cPWDADMVAZIO = '[]';
  cPWDADMOIZAV = '][';
  cRAIZ        = 'C:\';
  cRMTINI      = 'rmt.ini';
  cSMARTINIP10 = 'totvssmartclient.ini';
  cSMARTINIP11 = 'smartclient.ini';
  cROOTPATH    = 'ROOTPATH';
  cRPT         = 'RPT';
  cSERVER      = 'SERVER';
  cSETUP       = 'setup.exe';
  cSOURCEDB    = 'SourceDB';
  cSTR         = 'STR';
  cSTRING      = 'S';
  cSX1         = 'SX1';
  cSX2         = 'SX2';
  cSXS         = 'SXS';
  cTABCOMPART  = 'C';
  cTABEXCLUS   = 'E';
  cTEMPLOG     = 'TEMPLOG';
  cTEXTO       = 'TEXTO';
  cTIPO        = 'TIPO';
  cTRATASQLDEL = 'TRATASQLDEL';
  cTRATAFILIAL = 'TRATAFILIAL';
  cTXT         = 'TXT';
  cUM          = '1';
  cVAZIO       = '';
  cVARTMP      = 'TMP';
  cVIRGULA     = ',';
  cZERO        = '0';

  //Constantes usadas na exportação para arquivo
  nXLS         = 4;
  nXLSTabular  = 5;
  nPDF         = 6;
  nTXT         = 7;
  nDOC         = 8;

  cPXLS        = '.xls';
  cPPDF        = '.pdf';
  cPDOC        = '.doc';

  cEXPORT      = 'EXPORT';
  cUPDODBCPATH = 'UPDODBCPATH';
      
  cnMaxVarValueSize = 250;
  nConst            = 3;
  SE_RESTORE_PRIV   = 'SerestorePrivilege';
  PATHREG           = '\Software\ODBC\ODBC.INI\';


procedure SetValINI(sArquivo : String; sSecao : String; sParam : String; sValor : String);
procedure GravaArquivo(sArquivo : String; slValores : TStringList; bSobrepor : Boolean);
procedure gravalog(sTexto : String; sLog : String);
procedure DeletaArqs(aArqs : TStringList; sLog : String);
procedure ExibeErro(sMensagem: string);
function GetTokenAdv(sTexto : String; nIndice : Integer; sDelimit : String) : String;
function GetTokenAdvCount(sTexto : String; sDelimit : String) : Integer;
function ValidaArqs(cDir : String; slArqs : TStringList; nIdioma : Integer) : Boolean;
function ValidaArq(sCaminho : String; sMensagemErro : String):Boolean;
function Deletado(sBanco : String; sTabela : String) : String;
function Filial(sAlias : String; sTabela : String; sTipoEmpresa : String;  sTipoUnidade : String; sTipoFilial : String; sEmpresa : String; sUnidade : String; sFilial : String; sLayout: String ) : String;
function IncWhere(sClausAnt : String; sClausInc : String; sOper : String) : String;
function RetValINI(sArquivo : String; sSecao : String; sParam : String; sVlDef : String) : String;
function crialog(sDiretorio : String) : String;
function TipoAcesso(sDiretorio : String) : String;
function AcessaSXs(sSX : String; sTipo : String; sFile : String; sEnv : String; sADMPass : String; sSrv : String; sNome : String; sGEmp : String; sEmp : String; sUni : String; sFil : String; sPath : String; sLog : String; nIdioma : Integer ) : TStringList;
function RetSRV(sArq : String) : String;
function RetINI(sVersion : String) : String;
function LeCH(sArquivo : String; nIdioma : Integer) : TStringList;
function invertetexto(original : string) : string;
function GetEnvVar(const csVarName : string ) : string;
function HabilitaPriv(const privilegio : string; status : Integer) : Integer;
function ValidaODBC(sLocaliz : String; lCria : Boolean; sLog : String; nIdioma : Integer; sTipo : String) : Boolean;
function ValidaInst(cDir : String; cDirTemp : String; sLog : String; nIdioma : Integer) : Boolean;
function Encrip(sTexto : String) : String;
function Decrip(sTexto : String) : String;
function RetTipoDSN(sODBC : String) : String;
function ProcessaReg(nTipo : Integer; sODBC : String; sFileREG : String; lObrig : Boolean; nIdioma : Integer; sTipo : String; bDeletar : Boolean; sLog : String) : Boolean;
function LeTXT(sArquivo : String) : TStringList;
function LocalInd(slValor : TStringList; nPosIni : Integer; nQtdItem : Integer; sValor : String) : Integer;
function ExisteDrvCrystal9 : Boolean;
function GetIP : String;
function IsIPExt(var cIPext:String) : Boolean;
function IsIPInt(var cIPInt:String) : Boolean;
Procedure TrocaServerODBC( AliasODBC : String ; sLog : String ) ;
function RetConnectBufferStr(buffer:String):String;
function GetRPTRunOnServer():Boolean;
Procedure SetRPTRunOnServer(bParam: Boolean);
function GetLog():String;
Procedure SetLog(sParam: String);

//Funções do protheus

Function  APCreateConnControl(cServer: pchar; nPort: integer; cEnvironment: pchar; cUser: pchar; cPassWord: pchar): integer; stdcall; external 'APAPI.DLL';
Function  APDestroyConnControl(ObjectID: integer): boolean; stdcall; external 'APAPI.DLL';
Function  APConnect(ObjectID: integer): boolean; stdcall; external 'APAPI.DLL';
Procedure APDisconnect(ObjectID: integer); stdcall; external 'APAPI.DLL';
Function  AddStringParam(ObjectID: integer; value: pchar): boolean; stdcall; external 'APAPI.DLL';
Function  ResultAsArray(ObjectID: integer): variant; stdcall; external 'APAPI.DLL';
Function  CallProc(ObjectID: integer; cFunction: pchar): boolean; stdcall; external 'APAPI.DLL';

var
  bRPTRunOnServer: Boolean;
  sLibLog : String;

implementation

procedure GravaArquivo(sArquivo : String; slValores : TStringList; bSobrepor : Boolean);
var
  i : Integer;
  F : TextFile;
begin
  AssignFile(F, sArquivo);

  if (bSobrepor) or (Not ValidaArq(sArquivo, cVAZIO)) then
    Rewrite(F)
  else
    Append(F);

  for i:=0 to slValores.Count-1 do
  begin
    Writeln(F,slValores[i]);
  end;

  CloseFile(F);

end;
   
function GetTokenAdv(sTexto : String; nIndice : Integer; sDelimit : String) : String;
var
  i : Integer;
  nCount : Integer;
  nInicio : Integer;
  sRetorno : String;
begin
  nInicio := 1;
  nCount := 1;
  sRetorno := sTexto;
  for i := 1 to Length(sTexto) do
  begin
    if (sTexto[i] = sDelimit) then
    begin
      if (nCount = nIndice) then
        sRetorno := Copy(sTexto, nInicio, i-nInicio);
      inc(nCount);
      nInicio := i+1;
    end;
  end;
  if (nCount = nIndice) then
    sRetorno := Copy(sTexto, nInicio, length(sTexto));
  result := sRetorno;
end;

function GetTokenAdvCount(sTexto : String; sDelimit : String) : Integer;
var
  i : Integer;
  nCount : Integer;
begin
  nCount := 0;
  if (sTexto <> cVAZIO) then
    inc(nCount);
  for i := 1 to Length(sTexto)-1 do
    if (sTexto[i] = sDelimit) then
      inc(nCount);
  result := nCount
end;

function ValidaArq(sCaminho : String; sMensagemErro : String) : Boolean;
begin
  If FileExists(sCaminho) then
    result := True
  else
  begin
    if (sMensagemErro <> cVAZIO) then
      ExibeErro(sMensagemErro);
    result := False;
  end;
end;

function Deletado(sBanco : String; sTabela : String) : String;
var
  sDelete : String;
begin
  sDelete := 'D_E_L_E_T_';

  if (Pos('PERVASIVE', UpperCase(sBanco)) > 0) then
    sDelete := 'D_E_L_E_T_E_D';

  if (Pos('CLIENT ACCESS', UpperCase(sBanco)) > 0) then
    sDelete := '@DELETED@';

  Result := cABRECH + sTabela + cPONTO + sDelete + cFECHACH;
end;

function IncWhere(sClausAnt : String; sClausInc : String; sOper : String) : String;
begin
  if (length(trim(sClausAnt)) > 0) then
    result := sClausAnt + cBRANCO + sOper + cBRANCO + sClausInc
  else
    result := sClausInc;
end;

function Filial(sAlias : String; sTabela : String; sTipoEmpresa : String;  sTipoUnidade : String; sTipoFilial : String; sEmpresa : String; sUnidade : String; sFilial : String; sLayout: String ) : String;
var
    cIniField   :String;
    i           :Integer;
    lEmpresa    :Boolean;
    lUnidade    :Boolean;
begin
   lEmpresa     := false;
   lUnidade     := false;

   //Tabelas Siga que iniciam com S o inicializador do campo são 2 caract. Outras são 3.
   if sAlias[1]='S' then
        cIniField := Copy(sTabela, 2, 2)
   else
        cIniField := Copy(sTabela, 1, 3);


   //Verifica o layout em caso de gestão de empresas.
   for i:= 1 to Length(sLayout) do
   begin
        if ( sLayout[i] = 'E' ) then
            lEmpresa := true;

        if ( sLayout[i] = 'U' ) then
            lUnidade := true;
   end;

   //Monta a expressão de filtro para filial.
   result := cABRECH;
   result := result + sAlias;
   result := result + cPONTO;
   result := result + cIniField;
   result := result + cFILIAL;
   result := result + cFECHACH;
   result := result + cBRANCO;
   result := result + cIGUAL;
   result := result + cBRANCO;
   result := result + cASPASDUP;

   //Verifica o compartilhamento da Empresa.
    if ( lEmpresa ) then
    begin
		if (sTipoEmpresa = cTABEXCLUS) then
		begin
            result := result + sEmpresa
        end
		else
            for i:= 1 to Length(sEmpresa) do
            begin
                result := result + ' ';
            end
    end;


    //Verifica o comparilhamento da Unidade de Negócio.
    if ( lUnidade ) then
    begin
		if (sTipoUnidade = cTABEXCLUS) then
		begin
            result := result + sUnidade
        end
		else
            for i:= 1 to Length(sUnidade) do
            begin
                result := result + ' ';
            end
    end;
    

   //Verifica o comparilhamento da Filial.
   if (sTipoFilial = cTABEXCLUS) then
        result := result + sFilial
   else
        for i:= 1 to Length(sFilial) do
        begin
            result := result + ' ';
        end;

        
   //Finaliza a montagem da expressão.
   result := result + cASPASDUP;
end;

function RetValINI(sArquivo : String; sSecao : String; sParam : String; sVlDef : String) : String;
var
  oIni : TIniFile;
  Retorno : String;
begin
  if ValidaArq(sArquivo, cVAZIO) then
  begin
    oIni := TIniFile.Create(sArquivo);
    Retorno := oIni.ReadString(sSecao, sParam, sVlDef);
    oIni.Free;
  end
  else
    Retorno := sVldef;
  result := Retorno;
end;

procedure SetValINI(sArquivo : String; sSecao : String; sParam : String; sValor : String);
var
  oIni : TIniFile;
begin
  oIni := TIniFile.Create(sArquivo);
  oIni.WriteString(sSecao, sParam, sValor);
  oIni.Free;
end;

function crialog(sDiretorio : String) : String;
var
  sRet : String;
begin
  sRet := cVAZIO;
  sDiretorio := sDiretorio + cBARINV + cCRYSINI;

  if not FileExists(sDiretorio) then
    sRet := cRAIZ + cFILELOG
  else if RetValINI(sDiretorio, cPATH, cPATHLOG, cVAZIO) <> cVAZIO then
    sRet := RetValINI(sDiretorio, cPATH, cPATHLOG, cVAZIO) + cBARINV + cFILELOG
  else if RetValINI(sDiretorio, cPATH, cTEMPLOG, cZERO) = cUM then
    sRet := GetEnvVar(cVARTMP) + cBARINV + cFILELOG
  else if RetValINI(sDiretorio, cPATH, cLOG, cZERO) = cUM then
    sRet := cRAIZ + cFILELOG;   

  if FileExists(sRet) then
    DeleteFile(PChar(sRet));

  Result := sRet;
end;

procedure gravalog(sTexto : String; sLog : String);
var
  slTexto : TStringList;
begin
  if (sLog <> cVazio) then
  begin
    slTexto := TStringList.Create;
    slTexto.Add( '[' + datetostr(date()) + '][' + timetostr( time() ) + '] ' + sTexto );
    slTexto.Add('');
    GravaArquivo(sLog, slTexto, false);
    slTexto.Free;
  end;
end;

function AcessaSXs(sSX : String; sTipo : String; sFile : String; sEnv : String; sADMPass : String; sSrv : String; sNome : String; sGEmp : String; sEmp : String; sUni : String; sFil : String; sPath : String; sLog : String; nIdioma : Integer ) : TStringList;
var
    slRetorno : TStringList;
    tfF : TextFile;
	xRet : Variant;
    sS :  String;	
	sDrivers : String;	
	sServer: String;
	sPorta : String;
	sIni :  String;
    nAP : Integer;
	nLowItem : Integer;
	nHighItem : Integer;
	i : Integer;
	nInd : Integer;
	bConOK : Boolean;
begin
	slRetorno   := TStringList.Create;
    bConOK      := false;

	GravaLog('Acessando ' + sSX, sLog);

    //Acessa o arquivo de texto contendo os parâmetros.
	if (sTipo = cTXT) then
	begin
		if ( Not FileExists( sFile )) then
			GravaLog('Não foi possível acessar o arquivo -> ' + sFile, sLog)
		else
		begin
			GravaLog('Abrindo', sLog);
			AssignFile(tfF, sFile);
			Reset(tfF);
			GravaLog('Antes do While', sLog);
			
			while not Eof(tfF) do
			begin
				Readln(tfF, sS);
				slRetorno.Add(sS);
			end;
			
			GravaLog('Depois do While', sLog);
			CloseFile(tfF);
			GravaLog('Fechando', sLog);
			GravaLog('Qtde de itens inseridos -> ' + inttostr(slRetorno.Count), sLog);
		end;
	end;

    //Estabelece conexão com servidro para recuperar os parâmetros.
	if (sTipo = cDLL) then
	begin
		sINI 		:= RetINI(trim(sSRV));
		sDrivers 	:= RetValINI(sPath + cBARINV + sINI,cDRIVERS,cACTIVE,cVAZIO);


        if not GetRPTRunOnServer() then
        begin
		    GravaLog('Arquivo de configuração do cliente -> ' + sINI , sLog);
        end
        else
            GravaLog('Arquivo de configuração do cliente -> ' + cCRWINI , sLog);


        if Trim(sDrivers)=cVAZIO then
		begin
			sDrivers := RetValINI(sPath + cBARINV + cCRWINI, cSXS, cDRIVERS, cVazio);
		end;


		GravaLog('Drivers:' + sDrivers, sLog);

		for nInd := 1 to GetTokenAdvCount(sDrivers, cVIRGULA) do
			begin
				if not bConOK then
				begin
					nAP := 0;
					try
						GravaLog('Criando Conexão', sLog);

						sServer := RetValINI(sPath + cBARINV + sINI,GetTokenAdv(sDrivers, nInd, cVIRGULA), cSERVER, cVAZIO);
						If Trim(sServer) = cVAZIO then
							sServer := RetValINI(sPath + cBARINV + cCRWINI, cSXS, cServer, cVazio);
							
						GravaLog('Servidor: ' + sServer, sLog);

						sPorta  := RetValINI(sPath + cBARINV + sINI,GetTokenAdv(sDrivers, nInd, cVIRGULA), cPORT, cZERO);
						If Trim(sPorta) = cZero then
							sPorta := RetValINI(sPath + cBARINV + cCRWINI, cSXS, cPort, cZero);
							
						GravaLog('Porta: ' + sPorta, sLog);

						If Length(sADMPass) > 100 then
							begin
								GravaLog('Usando Session :'+sADMPass, sLog);
								nAP := APCreateConnControl(PChar(sServer),strtoint(sPorta),PChar(sEnv),PChar(sADMPass),Pchar(''))
							end
						else
                        begin
                            GravaLog('Usando Senha padrão', sLog);
                            nAP := APCreateConnControl(PChar(sServer),strtoint(sPorta),PChar(sEnv),PChar(cADM),PChar(sADMPass));
						end;

						if (nAP < 0) then
						begin
							ExibeErro(SetTexto(19, nIdioma));
							Gravalog('Erro na criação de instância. Possivelmente problemas na alocação de memória. Parametros -> Server -> ' + sServer + ' | Porta -> ' + sPorta + ' | Environment -> ' + sEnv + ' | Usuario -> ' + cADM + ' | PWD -> ' + Encrip(sADMPass), sLog);
						end
						else
						begin
							try
								GravaLog('Abrindo Conexão', sLog);
								if APConnect(nAP) then
								begin
									AddStringParam(nAP,PChar(trim(ExtractFileName(sFile))));
									GravaLog('Parametro para CRWSX: '+trim(ExtractFileName(sFile)), sLog);

									try
										GravaLog('Chamando Funcao: '+cFuncao, sLog);
										
										if CallProc(nAP,cFUNCAO) then
										begin
											GravaLog('Recebendo o retorno da funcao', sLog);
											xRet := ResultAsArray(nAP);
											
											if VarIsArray(xRet) then
											begin
												nLowItem  := VarArrayLowBound(xRet,1);
												nHighItem := VarArrayHighBound(xRet,1);
												slRetorno.Clear;
												GravaLog('Preenchendo Retorno', sLog);
												
												for i := nLowItem to nHighItem do
													slRetorno.Add(xRet[i]);
												
													GravaLog('Depois de preenchido Retorno', sLog);
													GravaLog('Qtde de itens inseridos -> ' + inttostr(slRetorno.Count), sLog);
													bConOK := true;
												end
											else
											begin
												ExibeErro(SetTexto(19, nIdioma));
												GravaLog('Tipo diferente de Array. O tipo retornado foi: ' + IntToStr(VarType(xRet)), sLog);
											end;
										end
										else
										begin
											ExibeErro(SetTexto(19, nIdioma));
											GravaLog('Falha na execução da função. Verifique o ambiente informado ou o repositório utilizado.', sLog);
										end;
									except
										ExibeErro(SetTexto(19, nIdioma));
										GravaLog('Falha na conexao.', sLog);
									end;
								end
								else
								begin
									ExibeErro(SetTexto(19, nIdioma));
									GravaLog('Não foi possível se conectar ao servidor indicado. Por favor, verifique os parametros -> Server -> ' + sServer + ' | Porta -> ' + sPorta + ' | Environment -> ' + sEnv + ' | Usuario -> ' + cADM + ' | PWD -> ' + Encrip(sADMPass), sLog);
								end;
							finally
								APDisconnect(nAP);
								GravaLog('Fechando a conexão com o Protheus.', sLog);
							end;
						end;
					finally
					  APDestroyConnControl(nAP);
				end;
			end;
		end;
	end;

    Result := slRetorno;
end;

function TipoAcesso(sDiretorio : String) : String;
var
  sRet : String;
begin
  sRet := cTXT;
  if (RetValINI(sDiretorio + cBARINV + cCRYSINI, cPATH, cDLL, cZERO) = cUM) then
    sRet := cDLL;
    result := sRet;
end;

//Retorna a versão do servidor do qual o componente está sendo invocado.

function RetSRV(sArq : String) : String;
var
  sRet : String;
begin
  sRet := sArq;
  if (sRet = cVAZIO) then
  begin
    if FileExists(cMP8 + cRMTINI) then
      sRet := cMP8
    else if FileExists(cAP7 + cRMTINI) then
      sRet := cAP7
    else if FileExists(cAP6 + cRMTINI) then
      sRet := cAP6
    else if FileExists(cAP5 + cRMTINI) then
      sRet := cAP5
  end
  else
    sRet := Copy(sRet, 1, 3);

    if (sRet = 'TOT') then
        sRet := cP10
    else if (sRet = 'APP') then
        sRet := cP11;

    Result := sRet;
end;

//Retorna o nome arquivo de inicialização da versão que está sendo utilizada.

function RetINI(sVersion : String) : String;
var
  sRet : String;
begin

  if (sVersion <> cVAZIO) then
  begin
    if (sVersion = cP11) then
        sRet := cSMARTINIP11    //'smartclient.ini'
    else if (sVersion = cP10) then
        sRet := cSMARTINIP10    //'totvssmartclient.ini'
    else if (sVersion = cMP8) then
        sRet := cMP8 + cRMTINI //'mp8rmt.ini'
    else if (sVersion = cAP7) then
      sRet := cAP7 + cRMTINI   //'ap7rmt.ini'
    else if (sVersion = cAP6) then
      sRet := cAP6 + cRMTINI   //'ap6rmt.ini'
    else if (sVersion = cAP5) then
      sRet := cAP5 + cRMTINI   //'ap5rmt.ini'
  end;

  Result := sRet;
end;


function LeCH(sArquivo : String; nIdioma : Integer) : TStringList;
var
  tfF : TextFile;
  slRetorno : TStringList;
  nIdiomaCorr : Integer;
  sS : String;
begin
  slRetorno := TStringList.Create;
  nIdiomaCorr := 0;
  if nIdioma <> 0 then
  begin
    AssignFile(tfF, sArquivo);
    Reset(tfF);
    while not Eof(tfF) do
    begin
      Readln(tfF, sS);
      sS := Trim(sS);
      if (Pos(cIFDEFSPA, sS) > 0) then
        nIdiomaCorr := 1
      else if (Pos(cIFDEFENG, sS) > 0) then
        nIdiomaCorr := 2
      else if (Pos(cELSE, sS) > 0) or (Pos(cENDIF, sS) > 0) then
        nIdiomaCorr := 0
      else
      begin
        if (nIdiomaCorr = nIdioma) then
        begin
          slRetorno.Add(cASPASDUP + Copy(sS, Pos(cASPASDUP, sS) + 1, length(sS)-Pos(cASPASDUP, sS)-1) + cASPASDUP);
        end;
      end;
    end;
      CloseFile(tfF);
  end;
  Result := slRetorno;
end;

function LeTXT(sArquivo : String) : TStringList;
var
  tfF : TextFile;
  slRetorno : TStringList;
  sS : String;
begin
  slRetorno := TStringList.Create;
  AssignFile(tfF, sArquivo);
  Reset(tfF);
  while not Eof(tfF) do
  begin
    Readln(tfF, sS);
    sS := Trim(sS);
    slRetorno.Add(sS);
  end;
  CloseFile(tfF);
  Result := slRetorno;
end;

function invertetexto(original : string) : string;
var
  i : integer;
  texto : string;
begin
  texto := cVAZIO;
  if length(original) > 0 then
    for i:= length(original) downto 0 do
      texto := texto + original[i];
  Result := texto;
end;

function GetEnvVar(const csVarName : string ) : string;
var
  pc1 : PChar;
  pc2 : PChar;
begin
  pc1 := StrAlloc( Length( csVarName ) + 1 );
  pc2 := StrAlloc( cnMaxVarValueSize + 1 );
  StrPCopy( pc1, csVarName );
  GetEnvironmentVariableA(pc1, pc2, cnMaxVarValueSize );
  Result := StrPas( pc2 );
  StrDispose( pc1 );
  StrDispose( pc2 );
end;

function HabilitaPriv(const privilegio : string; status : Integer) : Integer;
var
  hToken : THandle;
  aluid : TLargeInteger;
  cbPrevTP : DWORD;
  tp, fPrevTP : PTokenPrivileges;
begin
  result := 0;
  if OpenProcessToken (GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  try
    LookupPrivilegeValue (Nil, PChar (privilegio), aluid);
    cbPrevTP := SizeOf (TTokenPrivileges) + sizeof (TLUIDAndAttributes);
    GetMem (tp, cbPrevTP);
    GetMem (fPrevTP, cbPrevTP);
    try
      tp^.PrivilegeCount := 1;
      tp^.Privileges [0].Luid := aLuid;
      tp^.Privileges [0].Attributes := status;
      if not AdjustTokenPrivileges (hToken, False, tp^, cbPrevTP, fPrevTP^, cbPrevTP) then
        RaiseLastWin32Error;
      result := fPrevTP^.Privileges [0].Attributes;
    finally
      FreeMem (fPrevTP);
      FreeMem (tp);
    end
  finally
    CloseHandle (hToken);
  end
end;

function ProcessaReg(nTipo : Integer; sODBC : String; sFileREG : String; lObrig : Boolean; nIdioma : Integer; sTipo : String; bDeletar : Boolean; sLog : String) : Boolean;
var
  reg : Tregistry;
  sKey : String;
  lRet : Boolean;
  lRetCont : Boolean;
  slArq : TStringList;
begin
  slArq := TStringList.Create;
  slArq.Add(sFileREG);
  if lObrig then
    lRet := False
  else
    lRet := True;
  if Trim(sODBC) <> cVAZIO then
  begin
    reg := Tregistry.Create;
    sKey := '\Software\ODBC\ODBC.INI\'+sODBC;
    if nTipo = 1 then //BACKUP
    begin
      reg.rootkey := HKEY_CURRENT_USER;
      HabilitaPriv('SeBackupPrivilege', SE_PRIVILEGE_ENABLED);
      DeletaArqs(slArq, cVazio);
      lRet := reg.Savekey(sKey, sFileREG) = true;
      if lRet then
        ExibeErro(SetTexto(20, nIdioma))
      else
        ExibeErro(SetTexto(21, nIdioma));
    end
    else //RESTORE
    begin
      reg.rootkey := HKEY_CURRENT_USER;
//      reg.rootkey := HKEY_LOCAL_MACHINE;
      HabilitaPriv('SeRestorePrivilege', SE_PRIVILEGE_ENABLED);
      if bDeletar then
      begin
        gravalog('Deletar chave -> ' + sKey, sLog);
        lRetCont := reg.DeleteKey(sKey);
        if lRetCont then
          gravalog('Chave deletada -> ' + sKey, sLog)
        else
          gravalog('Erro na deleção da chave -> ' + sKey, sLog);
      end
      else
        lRetCont := true;
      if lRetCont then
      begin
        lRetCont := reg.CreateKey(sKey);
        if lRetCont then
          gravalog('Chave criada -> ' + sKey, sLog)
        else
          gravalog('Falha na criaçao da chave -> ' + sKey, sLog);
      end;
      if lRetCont then
      begin
        lRet := reg.RestoreKey(sKey, sFileREG) = true;
        if lRet then
          gravalog('Chave restaurada -> ' + sKey, sLog)
        else
          gravalog('Erro na restauração da chave -> ' + sKey, sLog);
        sKey := '\Software\ODBC\ODBC.INI\'+'ODBC Data Sources';
        reg.OpenKey(sKey,true);
        reg.WriteString(sODBC, sTIPO);
//        ExibeErro(SetTexto(22, nIdioma))
      end
      else
        ExibeErro(SetTexto(23, nIdioma));
    end;
    reg.free;
  end;
  result := lRet;
end;

function ValidaODBC(sLocaliz : String; lCria : Boolean; sLog : String; nIdioma : Integer; sTipo : String) : Boolean;
var
  sFileReg : String;
  sDSNREG : String;
  RFArq : TRegIniFile;
  lRet : Boolean;
begin
  lRet := False;
  gravalog('Localizacao do .REG -> ' + sLocaliz, sLog);
  if FileExists(sLocaliz) then
  begin
    sFileReg := Copy(sLocaliz,length(ExtractFileDir(sLocaliz)) + 2,length(sLocaliz)-length(ExtractFileDir(sLocaliz)));
    gravalog('.REG -> ' + sFileReg, sLog);
    sDSNREG := Copy(sFileReg,1,Pos(Uppercase(cPREG),UpperCase(sFileReg))-1);
    gravalog('ODBC -> ' + sDSNREG, sLog);
    RFArq := TRegIniFile.Create;
    RFArq.rootkey := HKEY_CURRENT_USER;
    if RFArq.OpenKey(PATHREG + sDSNREG, false) then
    begin
      gravalog('Existe ODBC', sLog);
      if lCria then
      begin
        gravalog('Precisa reconfigurar ODBC', sLog);
        //altera chave
        if ProcessaReg(2, sDSNREG, sLocaliz, true, nIdioma, sTipo, true, sLog) then
        begin
          gravalog('Restore com sucesso', sLog);
          lRet := true;
        end
        else
          gravalog('Problema no restore', sLog);
      end
      else
      begin
        gravalog('Não precisa reconfigurar', sLog);
        lRet := true;
      end;
    end
    else
    begin
      gravalog('Nao existe ODBC', sLog);
      if lCria then
      begin
        gravalog('Precisa configurar', sLog);
        if ProcessaReg(2, sDSNREG, sLocaliz, true, nIdioma, sTipo, false, sLog) then
        begin
          gravalog('Restore com sucesso', sLog);
          lRet := True;
        end
        else
          gravalog('problema no restore', sLog);
      end;
    end;
    RFArq.CloseKey;
    RFArq.Free;
  end
  else
    gravalog('Arquivo REG nao localizado', sLog);
  result := lRet;
end;

function ValidaArqs(cDir : String; slArqs : TStringList; nIdioma : Integer) : Boolean;
var
 i : Integer;
 lFalha : Boolean;
begin
  lFalha := True;
  For i:= 0 to slArqs.Count-1 do
    if Not ValidaArq(cDir + slArqs[i], setTexto(18, nIdioma) + cDir + slArqs[i]) then
      lFalha := False;
  Result := lFalha
end;

function ValidaInst(cDir : String; cDirTemp : String; sLog : String; nIdioma : Integer) : Boolean;
var
  slArqsInst : TStringList;
  lRet : Boolean;
begin
  lRet := False;
  slArqsInst := TStringList.Create;
  slArqsInst.Add('INSTMSIA.EXE');
  slArqsInst.Add('INSTMSIW.EXE');
  slArqsInst.Add('SETUP.INI');
  slArqsInst.Add('SETUP.EXE');
  slArqsInst.Add('DATA.MSI');

  if ValidaArqs(cDir + cBARINV, slArqsInst, nIdioma) then
  Begin
    lRet := True;
    gravalog('Existe arquivos de instalacao', sLog);
    WinExec(PChar(cDir + cBARINV + cSETUP),SW_SHOWNORMAL);
  end;
  slArqsInst.Destroy;
  Result := lRet;
end;

function Encrip(sTexto : String) : String;
var
  nInd : Integer;
  sNovoTexto : String;
begin
  sNovoTexto := cVAZIO;
  for nInd := 1 to length(sTexto) do
    sNovoTexto := sNovoTexto + chr(ord(sTexto[nInd]) + (nInd + nConst));
  Result := sNovoTexto;
end;

function Decrip(sTexto : String) : String;
var
  nInd : Integer;
  sNovoTexto : String;
begin
  sNovoTexto := cVAZIO;
  for nInd := 1 to length(sTexto) do
    sNovoTexto := sNovoTexto + chr(ord(sTexto[nInd])-(nInd + nConst));
  Result := sNovoTexto;
end;

procedure DeletaArqs(aArqs : TStringList; sLog : String);
var
  i : Integer;
begin
  gravalog('Existe(m) ' + inttostr(aArqs.Count) + ' arquivo(s) para deletar', sLog);
  for i := 0 to aArqs.Count-1 do
  begin
    gravalog('Deletando -> ' + aArqs[i], sLog);
    if ValidaArq(aArqs[i], cVAZIO) then
      if DeleteFile(PChar(aArqs[i])) then
        gravalog('Deletacao OK', sLog)
      else
        gravalog('Erro na deletacao', sLog);
  end;
end;

function RetTipoDSN(sODBC : String) : String;
var
  reg : Tregistry;
  sValor : String;
  sKey : String;
begin
  reg := Tregistry.Create;
  reg.rootkey := HKEY_CURRENT_USER;
  sValor := cVAZIO;
  sKey := '\Software\ODBC\ODBC.INI\'+'ODBC Data Sources';
  reg.OpenKey(sKey,true);
  sValor := reg.ReadString(sODBC);
  result := sValor;
end;

function LocalInd(slValor : TStringList; nPosIni : Integer; nQtdItem : Integer; sValor : String) : Integer;
var
  i : Integer;
  bLocaliz : Boolean;
  nRet : Integer;
begin
  i := 0;
  bLocaliz := False;
  nRet := -1;
  sValor := UpperCase(sValor);
  while (Not bLocaliz) and (i <= slValor.Count-1) do
  begin
    if UpperCase(Copy(slValor[i],nPosIni,nQtdItem)) = sValor then
    begin
      bLocaliz := True;
      nRet := i;
    end;
    inc(i);
  end;
  Result := nRet;
end;

function ExisteDrvCrystal9 : Boolean;
Var  reg : Tregistry;
     sKey : String;
     SubKeys : TStringList;
     i : Integer;
begin
  Result:=False;
  Try
    SubKeys := TStringList.Create;
    reg := Tregistry.Create;
    reg.rootkey := HKEY_LOCAL_MACHINE;
    sKey := '\Software\Microsoft\Windows\CurrentVersion\Uninstall';
    reg.OpenKey(sKey,true);
    reg.GetKeyNames(SubKeys);
    for i:=0 to SubKeys.Count-1 do
      begin
        reg.OpenKey(sKey+'\'+SubKeys[i],true);
        if UpperCase(Trim(reg.ReadString('DisplayName'))) = 'PROTHEUS X CRYSTAL' then
          begin
            Result:=True;
            Exit;
          end
      end;
  finally
    SubKeys.Free;
  end;
end;
         
//Retorna o IP da estação onde está o SGCRYS32.EXE sendo executado.
function GetIP : String;
var ipwsa:TWSAData;
    p:PHostEnt;
    s:array[0..128] of char;
    c:pchar;
begin
  wsastartup(257,ipwsa);
  GetHostName(@s, 128);
  p := GetHostByName(@s);
  c := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
  Result := String(c);
end;

//Retorna se o IP é externo ( >=200.x.x.x )
function IsIPExt(var cIPext:String) : Boolean;
Var cIPAtual : String;
    sTempDir : String;
begin
   cIPAtual := GetIP;
   sTempDir := GetEnvVar(cVARTMP) + cBARINV;
   cIPExt := RetValIni(sTempDir + cPROTCRW,cODBCDATA,cIPEXTERNO,cVAZIO);
   Result := (cIPExt <> cVazio) and ( StrtoInt(Copy(cIPAtual,1,3)) >= 200 );
end;

//Retorna se o IP é interno ( <200.x.x.x )
function IsIPInt(var cIPInt:String) : Boolean;
Var cIPAtual : String;
    sTempDir : String;
begin
   cIPAtual := GetIP;
   sTempDir := GetEnvVar(cVARTMP) + cBARINV;
   cIPInt := RetValIni(sTempDir + cPROTCRW,cODBCDATA,cIPINTERNO,cVAZIO);
   Result := (cIPInt <> cVazio) and ( StrtoInt(Copy(cIPAtual,1,3)) >= 172 );
end;


//Troca o nome do server no Alias ODBC para acesso externo.
Procedure TrocaServerODBC( AliasODBC : String ; sLog : String ) ;
var RFArq : TRegIniFile;
    cIPExt : String;
    cIPInt : String;
begin
   GravaLog('IP Atual:'+GetIP, sLog);
   //Se for IPExterno e está informado o IP Externo no ProtCRW.INI
   if IsIPExt(cIPExt) then
     begin
       GravaLog('Trocando para IP Externo:'+cIPExt, sLog);
       RFArq := TRegIniFile.Create;
       RFArq.rootkey := HKEY_CURRENT_USER;
       if RFArq.OpenKey(PATHREG + AliasODBC, false) then
          RFArq.WriteString(PATHREG + AliasODBC,cServer,cIPExt);
       RFArq.CloseKey;
       RFArq.Free;
     end
   else
      //Se for IPInterno e está informado o IP Interno no ProtCRW.INI
      if IsIPInt(cIPInt) then
         begin
           GravaLog('Trocando para IP Interno:'+cIPInt, sLog);
           RFArq := TRegIniFile.Create;
           RFArq.rootkey := HKEY_CURRENT_USER;
           if RFArq.OpenKey(PATHREG + AliasODBC, false) then
              RFArq.WriteString(PATHREG + AliasODBC,cServer,cIPInt);
           RFArq.CloseKey;
           RFArq.Free;
         end
end;

//troca no connectionbufferstring o server de acordo com o protcrw.ini - NÃO USADO
function RetConnectBufferStr(buffer:String):String;
Var sTempDir : String;
    cIPAtual : String;
    cIPExt,cIpInt : String;
    i,j:Integer;
    cAux :String;
begin
   Result:='';
   cIPAtual := GetIP;
   sTempDir := GetEnvVar(cVARTMP) + cBARINV;
   cIPExt := RetValIni(sTempDir + cPROTCRW,cODBCDATA,cIPEXTERNO,cVAZIO);
   cIPInt := RetValIni(sTempDir + cPROTCRW,cODBCDATA,cIPINTERNO,cVAZIO);
   if (cIPExt <> cVazio) {nd ( StrtoInt(Copy(cIPAtual,1,3)) >= 200 )} then //está externo
      For i:=1 to GetTokenAdvCount(buffer,';') do
        begin
           cAux := GetTokenAdv(buffer,i,';');
           For j:=1 to GetTokenAdvCount(cAux,'=') do
              if GetTokenAdv(cAux,1,'=') = 'WSID' then cAux:='WSID='+cIPExt;
           Result:=Result+cAux+';'
        end;
    Result:=Copy(result,1,Length(result)-1);
end;


//Exibe os erros encontrados na execução do relatório.
procedure ExibeErro(sMensagem: string);
begin
    if GetRPTRunOnServer() then
        //Em execuções no servidor, apenas grava o crlog.log.
        gravalog(sMensagem, GetLog())
    else
        //Em execuções no client, exibe o log.
        ShowMessage(sMensagem);
end;


//Indica se a execução de relatório será no servidor ou local.
function GetRPTRunOnServer():Boolean;
begin
  Result := bRPTRunOnServer;
end;


//Define se a execução de relatório será no servidor ou local.
Procedure SetRPTRunOnServer(bParam: Boolean);
begin
  bRPTRunOnServer := bParam;
end;


//Retorna o arquivo de log.
function GetLog():string;
begin
  Result := sLibLog;
end;


//Define o arquivo de log.
Procedure SetLog(sParam: String);
begin
  sLibLog := sParam;
end;
end.


