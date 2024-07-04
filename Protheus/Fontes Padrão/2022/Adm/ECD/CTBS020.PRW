#INCLUDE "CTBS020.ch"
#INCLUDE "PROTHEUS.CH" 
#Include "ApWizard.ch"  
#INCLUDE "ECD.CH"
#INCLUDE "FWLIBVERSION.CH"

//Compatibilização de fontes 30/05/2018

Static __cThreadArq := ""

Static aTiposLiv	:= {{"G","ECDLIVRO_G.XML"},;
 							{"R","ECDLIVRO_R.XML"},;
 							{"A","ECDLIVRO_A.XML"},;
 							{"B","ECDLIVRO_B.XML"},;
 							{"Z","ECDLIVRO_Z.XML"},;
 							{"0","ECDLIVRO_0.XML"},;
						   	{"F","ECDLIVRO_FCONT.XML"},;
						   	{"S","ECDLIVRO_S.XML"}}

Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBS020     ºAutor  ³Alvaro Camillo NetoºData³  25/02/10 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Wizard de exportação de dados                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBS020(cCodRev)
Local oWizard 		:= Nil
Local aPWiz1 		:= {}           
Local aPWiz2 		:= {} 
Local aRetWiz1		:= {}
Local aRetWiz2		:= {}
Local nOpcRot		:= 0
Local nX				:= 0 
Local lRet			:= .F.
Local aArea			:= GetArea()
Local aAreaCS0		:= CS0->(GetArea())
Local lFWCodFil   	:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa

Default cCodRev := ""

If !Empty(cCodRev)
	DbSelectArea("CS0")
	CS0->(dbSetOrder(1))
	CS0->(dbSeek(xFilial("CS0") + cCodRev))
EndIf

//Wizard 1: Confirmação das informações da escrituração
//Wizard 2: Nome do Arquivo / Caminho do Arquivo

//Wizard 1
aAdd(aPWiz1,{ 1,	"Cod Empresa" ,Space(TamSx3('CS0_CODEMP')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) 
aAdd(aPWiz1,{ 1,	IIF(lGestao,STR0025,STR0002) ,Space(TamSx3('CS0_CODFIL')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) //"Empresa/Unidade/Filial"##"Filial"
aAdd(aPWiz1,{ 1,	STR0003 ,Space(TamSx3('CS0_CODREV')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) //"Revisao"
aAdd(aPWiz1,{ 1,	STR0004	,Space(TamSx3('CS0_TPESC')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) //"Tipo Escrituracao"

aAdd(aRetWiz1,CS0->CS0_CODEMP)
aAdd(aRetWiz1,CS0->CS0_CODFIL)
aAdd(aRetWiz1,CS0->CS0_CODREV)
aAdd(aRetWiz1,CS0->CS0_TPESC)

//Wizard 2
aAdd(aPWiz2,{ 1,STR0005,Space(50),"","","","",50,	.T.})           //"Nome do arquivo"
aAdd(aPWiz2,{ 6,STR0006,Space(100),"","","",100,.T.,STR0007, "",GETF_LOCALHARD + GETF_RETDIRECTORY }) //"Diretório de Gravação"###"Todos os arquivos (*.*) |*.*"
aAdd(aPWiz2,{5,"Deseja separar seções em arquivos?",.F.,150,"",.F.})
aAdd(aRetWiz2,Space(50))
aAdd(aRetWiz2,Space(50))
aAdd(aRetWiz2,.F.)

DEFINE WIZARD oWizard TITLE STR0008; //"Escrituração"
       HEADER STR0009 ;  //"Geração de Arquivo Texto"
       MESSAGE STR0010 	 ; //"Parâmetros Iniciais..."
       TEXT STR0011; //"Essa rotina tem o objetivo de gerar o arquivo texto da escrituração"
       NEXT {||.T.} ;
       FINISH {|| .F. } ;
       PANEL

	//Wizard 1
   CREATE PANEL oWizard ;
          HEADER STR0012;  //"Dados da Escrituração"
          MESSAGE ""; 
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| .F. } ;
          PANEL
	
	//Wizard 2
   CREATE PANEL oWizard ;
          HEADER STR0013; //"Dados do Arquivo"
          MESSAGE ""; 
          BACK {|| .T. } ;
          NEXT {|| .T. } ;
          FINISH {|| nOpcRot := 1 , .T. } ;
          PANEL
	

ParamBox(aPWiz1,STR0014,@aRetWiz1,,,,,,oWizard:GetPanel(2)) //"Parâmetros..."
ParamBox(aPWiz2,STR0014,@aRetWiz2,,,,,,oWizard:GetPanel(3)) //"Parâmetros..."


ACTIVATE WIZARD oWizard CENTERED

If nOpcRot == 1
	lRet := CTBSGerTXT(aRetWiz1[1],aRetWiz1[2],aRetWiz1[3],aRetWiz2[1],aRetWiz2[2],aRetWiz2[3])
EndIf

If CS0->CS0_TIPLIV == "G" .And. __lMetric // Se indicativo da escrituraçaõ for tipo G	
	CTBS020Metrics("01", Nil, "001", Alltrim(ProcName()), Nil)
EndIf
      
RestArea(aAreaCS0)
RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSGerTXT   ºAutor³Alvaro Camillo Neto º Data ³  26/02/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta os parametros e gera o arquivo Texto                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBS022                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBSGerTXT(cEmpEsc,cFilEsp,cRevisao,cNomeArq,cCaminho,lSepara)
Local aArea			:= GetArea()
Local aAreaCS0		:= CS0->(GetArea())
Local cLayout		:= ""
Local nOrdem		:= 0
Local oObj        := Nil
Local lCopied 		:= .F.
Local aParams 		:= {}
Local nPosLiv	   := 0
Local cVersion

Default lSepara := .F. 
 
If ! EMPTY(ALLTRIM(CS0->CS0_LEIAUT)) .And. CS0->CS0_LEIAUT == "2.00"
	cVersion :=  "2.0"
ElseIf ! EMPTY(ALLTRIM(CS0->CS0_LEIAUT)) .And. CS0->CS0_LEIAUT == "3.00"
	cVersion :=  "3.0"
Else	
	cVersion :=  "1.0"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Reinicia as variaveis estaticas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
__NThreadArq := 0
cCaminho := AllTrim( cCaminho )

CS0->(DbSetOrder(2)) //CS0_FILIAL+CS0_CDOEMP+CS0_CODFIL+CS0_CODREV
If CS0->(dbSeek( xFilial("CS0") + cEmpEsc + cFilEsp + cRevisao  ))
 
	nPosLiv := aScan( aTiposLiv , {|x| Alltrim(x[1]) == AllTrim( CS0->CS0_TIPLIV ) } )
	If nPosLiv > 0
		cLayout := aTiposLiv[nPosLiv][2]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parametros da versao                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aParams,{STR0001	,CS0->CS0_CODEMP}) //"EMPRESA"
		AADD(aParams,{STR0002	,CS0->CS0_CODFIL}) //"FILIAL"
		AADD(aParams,{STR0003	,CS0->CS0_CODREV}) //"REVISAO"
		
		Processa( { || __NThreadArq := CTBS021Exp(cLayout,cVersion,aParams,cCaminho) }, STR0015, STR0016, .F. )  //"Gerando Arquivo Texto"###"Aguarde..."
	  
			If Empty(__NThreadArq)
			Aviso("SPED","ERRO",{"Ok"},3)
		Else	
			Processa( { || lCopied := CpyFileEcd( AllTrim( cCaminho ) , cNomeArq ,lSepara ) }, STR0017, STR0016, .F. ) //"Transferindo arquivo"###"Aguarde..."
		EndIf
	
	EndIf
EndIf

RestArea(aAreaCS0)
RestArea(aArea)
Return .T. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CPYFILEEcd ºAutor  ³Renato F. Campos   º Data ³  12/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CpyFileEcd( cFileOut ,cNomeArq,lSepara )
Local lCopied	:= .F.
Local lFTPConn	:= .F.
Local cArqFtp	:= ""
Local cDrive    := ""
Local cDir      := ""
Local cExt      := ""
Local cArqDest  := ""
Local cArqAux	:= ""
Local cEcdFile := "CTBSARQ.TXT"

IncProc( STR0018 ) //"Efetuando a copia do arquivo para o local informado"

// Separa cada item (Drive, Diretorio, Nome e Extensao) do arquivo informado
SplitPath(cFileOut,@cDrive,@cDir,@cArqDest,@cExt)
cArqDest += cNomeArq
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para ambiente Linux ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsSrvUnix() .And. GetRemoteType() == 1
	cDir := StrTran(cDir,"/","\")
Endif

cDir := cDrive + cDir

MakeDir(cDir)			// Caso nao exista o diretorio informado, cria-lo
FErase (cDir+cArqDest)	// Se o arquivo informado existir no diretorio destino, apaga-lo

// Gerando o arquivo com nome informado pelo usuario. Isso sera feito copiando o
// arquivo CTBSARQ.TXT atraves da funcao __CopyFile().
lCopied := 	__CopyFile( cECDFile , cDir + cArqDest )

IF lCopied .And. lSepara
	Processa( { || lCopied := ECD2files( cArqDest, cDir  ) }, STR0019, STR0016, .F. ) //"Desmembrando arquivos por identificadores"###"Aguarde..."
Endif

IF !lCopied
	Aviso( STR0020, STR0021 , { "Ok" },2 ) //"Atencao !"###"Nao foi possivel efetuar a transferencia do arquivo do SPED para a area informada !"
Else
	Aviso( STR0020, STR0022 + AllTrim(cDir+cArqDest) + " !" , { "Ok" },2 ) //"Atencao !"###"Arquivo gerado em: "
Endif

IncProc( STR0023 ) //"Concluido!"

Return lCopied

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ ECD2files   ³Autor ³ Totvs                ³Data³ 05/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte o arquivo no layout do ECD em arquivos TXT       ³±±
±±³          ³ cuja extensao do arquivo corresponde ao registro.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ECD2Files( cFilename, cDirDestino)

Local cNewFile	:= "" 
Local cLinha	:= ""
Local cReg		:= ""
Local cOldReg	:= ""
Local lRet		:= .F.
Local nHandle	:= 0
Local cFolder	:= ""
Local cArqDest	:= "" 
Local nPosEmp	:= 0 

cFilename := cDirDestino + cFilename  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a pasta que conterá os arquivos do softeam³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SplitPath(cFilename,,,@cArqDest)
cFolder := cDirDestino + cArqDest + "\"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento para ambiente Linux ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsSrvUnix() .And. GetRemoteType() == 1
	cFolder := StrTran(cFolder,"/","\")
Endif 

//
// Elimina arquivos do diretorio
//
If EXISTDIR(cFolder) 
	aLimpar := Directory( cFolder + '*.*' )
	aEval( aLimpar, { |y, x| FErase( cFolder + aLimpar[x][1] ) } )
	DirRemove( cFolder )
EndIf

MakeDir(cFolder) 

cNewFile := AllTrim( cFolder ) + DtoS( DDATABASE )

If File( cFilename )
	fT_fUse( cFilename )
	fT_fGotop()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³percorre todo o arquivo separando os registros em arrays³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While ( !fT_fEof() )
		cLinha		:= Upper( AllTrim( fT_fReadLn() ) )
		cReg   := UPPER(substr( cLinha, 2, 4 ))

			If cReg <> cOldReg
				cOldReg := cReg
				If nHandle > 0
					FClose( nHandle )
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica a existencia do arquivo e o cria se for necessario.³
				//³                                                            ³
				//³A extensao do arquivo deve ser o registro que esta sendo    ³
				//³processado.                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !File( cNewFile + "." + cReg )
					nHandle := fCreate( cNewFile + "." + cReg )
				Else
					nHandle := FOpen( cNewFile + "." + cReg )
					FSeek( nHandle, 0, 2 )								// Fim de Arquivo
				EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³os novos arquivos nao precisam do identificador pois a extensao³
			//³dos arquivos corresponde aos identificadores.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FWrite( nHandle, SubStr(cLinha,7, Len( cLinha ) -7 ) + CRLF )
        EndIf
		
		fT_fSkip()

		If fT_fEof() .AND. nHandle > 0
			FClose( nHandle )
		EndIf
	End
	
	fT_fUse()

	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} CTBS020Metrics
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CTBS020Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

Local cIdMetric  := ""
Local nValue := 0
Local dDateSend := CtoD("") 
Local nLapTime := 0

Default cEvent := ""
Default nStart := 0
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a versão da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)
	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01"

		//Evento 001 - Metrica de tempo médio
		If cSubEvent == '001' 
			
			cFunMet := cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCCTBS001",cFunBkp)
			SetFunName(cFunMet)
			
			//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
			cSubRoutine := Alltrim(cSubRoutine)
			cIdMetric  := "contabilidade-gerencial-protheus_escrituracao-contabil-qtd-livrog_total"
			nValue := 1
			dDateSend := LastDay( Date() ) 
			nLapTime := 0

			// Metrica
			FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nValue, dDateSend, nLapTime)

		EndIf
		
	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return 

