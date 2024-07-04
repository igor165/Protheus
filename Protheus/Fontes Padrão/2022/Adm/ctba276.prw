#include "ctba276.ch"
#include "protheus.ch"

Static _oCtba276

// 17/08/2009 -- Filial com mais de 2 caracteres

//AMARRACAO PARA BOLETIM TECNICO - FNC: 00000005765-2008-912      
//AMARRACAO PARA BOLETIM TECNICO - FNC: 00000029121-2010
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ctba276 ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastramento de Grupos de Rateios                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB - Manutenção de Rateios Off-Line                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba276(xAutoCab,xAutoItens,nOpcAuto)

Local cAlias	:= "CW1"
Local aCores	:= {}

Private aRotina := MenuDef()
Private lCTQ_MSBLQL	:= IIF(CTQ->(FieldPos("CTQ_MSBLQL")) > 0,.T.,.F.)
Private lCTQ_STATUS  := IIF(CTQ->(FieldPos("CTQ_STATUS")) > 0,.T.,.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para rotina automatica    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Private lCTB276Auto := ( ValType(xAutoCab) == "A" .And. ValType(xAutoItens) == "A" )
Private aAutoCab   	:= {}
Private aAutoItens 	:= {}
Private lRpc       	:= Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela
Private cCadastro  	:= STR0006 						// "Grupos de Rateios"
Private cFilPad		:= ""
Private aIndexFil	:= {}
Private bFiltraBrw := {|| Nil}


If (!AMIIn(34)) .And. (!lCTB276Auto)				// Acesso somente pelo SIGACTB ou Rotina automatica
	Return
EndIf

If CTQ->(FieldPos("CTQ_STATUS")) == 0
	ShowHelpDlg("CTQSTATUS", {STR0072,STR0073},5,{STR0074,STR0075},5)  //"O campo CTQ_STATUS não está disponível "##"no dicionário de dados."##"Executar o compatibilizador UPDCTB com "##"data igual ou superior a 28/07/2008"
	Return
EndIf

AADD(aCores,{ "CW1_STATUS == '1'"	, "BR_VERDE"}) 		// "Indice atualizado"
AADD(aCores,{ "CW1_STATUS == '2'"	, "BR_VERMELHO"}) 	// "Indice desatualizado"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFilPad := "CW1_FILIAL = '"+xFilial("CW1")+"'"+" AND CW1_SEQUEN = '"+StrZero(1,TamSx3("CW1_SEQUEN")[1])+"'" 


If lCTB276Auto
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"CW1")
Else
	mBrowse( 6,1,22,75,"CW1",,,,,,aCores,,,,,,,,cFilPad)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CW1")
CW1->( dbSetOrder(1) )


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTB276Leg³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a legenda do MBrowse.							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA276                    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB276Leg()

LOCAL aLegenda  := 	{}       
LOCAL cTitulo	:= (SX2->(DbSeek("CW1")),X2NOME())

AADD(aLegenda,{"BR_VERDE"  		, STR0049}) //"Grupo válido    - liberado"
AADD(aLegenda,{"BR_VERMELHO" 	, STR0050}) //"Grupo inválido  - bloqueado"

BrwLegenda(cTitulo,STR0052, aLegenda) // "Legenda"

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB276PES³ Autor ³ Claudio D. de Souza   ³ Data ³ 01/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB276PES()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA276                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB276Pes()
AxPesqui()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ CTB276Cad ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Programa de inclusao de Grupos de Rateios                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ CTB276Cad(cAlias,nReg,nOpcx)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias = Alias do arquivo                                     ³±±
±±³          ³ nReg   = Numero do registro                                   ³±±
±±³          ³ nOpcx  = Opcao selecionada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba276                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB276Cad(cAlias,nReg,nOpcx)

Local oDlg
Local nOpcA
Local oGet
Local cArqTmp
Local oFnt

Local aArea      := CW1->( GetArea() )
Local aDados     := {}
Local aAltera    := {}
Local aGetDB     := {}		// Campos da GetDados

Local nOpcGDB    := nOpcX	// Variavel para carregar a GetDB
Local nOpcao     := If(nOpcX == 3, 4, nOpcX)

Local lCusto     := CtbMovSaldo("CTT")
Local lItem      := CtbMovSaldo("CTD")
Local lClVl      := CtbMovSaldo("CTH")
Local lDigita    := (nOpcx == 3 .or. nOpcx == 4)		// LÓGICO - INDICA QUANDO OS CAMPOS PODEM SER EDITADOS (INCLUSAO OU ALTERACAO)

Local cAliasTmp  	:= ""
Local aCw1_Tipo  	:= {}
Local aCw1_Entidade := {}

Local aButtons		:= {} 		//Aadd(aButtons,{"USER", {|| Rotina()}, "Texto"})
Local aUserButton	:= {}
Local lCTB276Bte	:= ExistBlock("CTB276BTE")
Local nX			:= 0

Local oSize		:= Nil
Local nLinIni	:= 0 
Local nColIni	:= 0 
Local nLinEnd	:= 0 
Local nColEnd	:= 0 

Private aHeader  := {}
Private oTotFat
Private oTotRat
Private nTotRat  := 0
Private nTotFat  := 0
Private cPictVal := PesqPict("CT2","CT2_VALOR")

Private cCw1_Codigo
Private cCw1_Desc
Private cCw1_Indice
Private cCw1_Tipo
Private cCw1_Entidade
Private lCw1_Percentual := .T.

(cAlias)->(DbClearFil())
RestArea(aArea)

// Botao para preenchimento do aCols com base no Indice Estatistico
AADD(aButtons,{"NCO", {|| IIF(nOpcao == 4,CTB276Indice(oGet),.T.)}, STR0060 })       //"Indice"
// Botao para preenchimento do aCols com base no Cadastro de Entidade
AADD(aButtons,{"NCO", {|| IIF(nOpcao == 4,CTB276ENTID(oGet),.T.)}	, STR0061 })       //"Entidade"
// Botao para atualizacao do aCols com base nas formulas
AAdd(aButtons,{"FORM",{|| IIF(nOpcao == 4,CTB276Recalc(),.T.)}	, STR0062,STR0063 })  //'Recalculo formulas'##'Rec. Form.'

IF lCTB276Bte
    aUserButton := ExecBlock("CTB276BTE",.F.,.F.)
	IF ValType(aUserButton) == "A" .AND. Len(aUserButton) > 0
		For nX := 1 to Len(aUserButton)
		 	AADD(aButtons,{aUserButton[nX][1],aUserButton[nX][2],aUserButton[nX][3]})
		Next nX
	ENDIF
ENDIF

aGetDB := {	"CW1_SEQUEN","CW1_CONTA","CW1_CCUSTO","CW1_ITEM","CW1_CLVL","CW1_PERCEN","CW1_FATOR","CW1_FORMUL"}

cAliasTmp := "TMP"
nOpcx     := nOpcx

If nOpcX == 3 // Inclusao
	cCw1_Codigo 	:= CriaVar("CW1_CODIGO")
	cCw1_Desc   	:= CriaVar("CW1_DESCRI")
	cCw1_Tipo   	:= CriaVar("CW1_TIPO")
	cCw1_Indice 	:= CriaVar("CW1_INDICE")
	cCw1_Entidade 	:= CriaVar("CW1_ENTID")
Else
	cCw1_Codigo 	:= CW1->CW1_CODIGO
	cCw1_Desc   	:= CW1->CW1_DESCRI
	cCw1_Tipo   	:= CW1->CW1_TIPO
	cCw1_Indice 	:= CW1->CW1_INDICE
	cCw1_Entidade 	:= CW1->CW1_ENTID
Endif

CTB276aHeader(cAlias,aGetDb,aAltera)
CTB276CriaTmp(cAlias, cAliasTmp)	// Cria Arquivo temporario
CTB276Carr(nOpcX)								// Carrega dados no temporario

aCw1_Tipo 		:= CtbCbox("CW1_TIPO","",TamSx3("CW1_TIPO")[1])
aCw1_Entidade   := CtbCbox("CW1_ENTID","",TamSx3("CW1_ENTID")[1])

If !lCTB276Auto
	DEFINE FONT oFnt	NAME "Arial" Size 10,15
	
	DbSelectArea(cAlias)
	DEFINE MSDIALOG oDlg TITLE STR0006 From 0,0 To 463,895 PIXEL OF oMainWnd //"Grupos de Rateio"
	
	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "CABECALHO",100, 15, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "GETDADOS" ,100, 70, .T., .T. ) // Totalmente dimensionavel 
	oSize:AddObject( "RODAPE" ,  100, 15, .T., .T. ) // Totalmente dimensionavel
	
	oSize:lProp 	:= .T. // Proporcional             
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() 	   // Dispara os calculos
	
	nLinIni := oSize:GetDimension("CABECALHO","LININI") 
	nColIni := oSize:GetDimension("CABECALHO","COLINI") 
	nLinEnd := oSize:GetDimension("CABECALHO","LINEND") 
	nColEnd := oSize:GetDimension("CABECALHO","COLEND")
	 
	@ nLinIni,nColIni TO nLinEnd,nColEnd OF oDlg PIXEL
	nLinIni += Round((nLinEnd - nLinIni)/4,0)
	@ nLinIni+2,nColIni+9 SAY STR0007 OF oDlg PIXEL	//	"Codigo Grupo"
	@ nLinIni,nColIni+45 MSGET cCw1_Codigo OF oDlg SIZE 30, 9 PIXEL PICTURE PesqPict("CW1","CW1_CODIGO");
												   When nOpcX == 3 ;
												   Valid CTB276Valid("CW1_CODIGO",cCw1_Codigo) .and. FreeForUse("CW1",cCw1_Codigo)
	@ nLinIni+2,nColIni+80 SAY STR0008		OF oDlg PIXEL	//	"Descrição"
	@ nLinIni,nColIni+109 MSGET cCw1_Desc   OF oDlg SIZE 80, 9 PIXEL PICTURE PesqPict("CW1","CW1_DESC");
	 											   When nOpcX == 3 .Or. nOpcX == 4 ;
	 											   Valid CTB276Valid("CW1_DESC",cCw1_Desc)
	@ nLinIni+2,nColIni+194 SAY STR0009		OF oDlg PIXEL	//	"Tipo"
	@ nLinIni,nColIni+211 MSCOMBOBOX cCw1_Tipo ITEMS aCw1_Tipo OF oDlg PIXEL SIZE 60,9  ;
													When nOpcX == 3 ;
													Valid CTB276VlTG(cCw1_Tipo)

	@ nLinIni+2,nColIni+278 SAY "Entidade"		OF oDlg PIXEL	//	"Entidade"
	@ nLinIni,nColIni+304 MSCOMBOBOX cCw1_Entidade ITEMS aCw1_Entidade OF oDlg PIXEL SIZE 60,9  ;
													When nOpcX == 3 ;
													Valid CheckSx3("CW1_ENTID",cCw1_Entidade)

	@ nLinIni+2,nColIni+367 SAY STR0010		OF oDlg PIXEL	//	"Indice Est"
	@ nLinIni,nColIni+394 MSGET cCw1_Indice	OF oDlg PIXEL SIZE 45,9  PICTURE PesqPict("CW1","CW1_INDICE");
								   				   When (nOpcX == 3 .Or. nOpcX == 4) .AND. cCw1_Tipo == "2" ;
								   				   F3 "CW3" ;
												   Valid ( CheckSx3("CW1_INDICE",cCw1_Indice) .AND.;
												   		   CTB276VlTE(cCw1_Indice, cCw1_Entidade) )


	nLinIni := oSize:GetDimension("RODAPE","LININI") 
	nColIni := oSize:GetDimension("RODAPE","COLINI") 
	nLinEnd := oSize:GetDimension("RODAPE","LINEND") 
	nColEnd := oSize:GetDimension("RODAPE","COLEND")

	@ nLinIni,nColIni TO  nLinEnd,nColEnd OF oDlg PIXEL
	nLinIni += Round((nLinEnd - nLinIni)/4,0)
	@ nLinIni+2,nColIni+9 SAY STR0064 OF oDlg PIXEL	//	"Total Fator"
	@ nLinIni+2,nColIni+054 SAY oTotFat VAR nTotFat PICTURE "@E 999,999,999.99 "	 OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE

	@ nLinIni+2,nColIni+229 SAY STR0011 								 OF oDlg PIXEL	//	"Total Percentual"
	@ nLinIni+2,nColIni+269 SAY oTotRat VAR nTotRat PICTURE "999.99%"	 OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	
	nLinIni := oSize:GetDimension("GETDADOS","LININI") 
	nColIni := oSize:GetDimension("GETDADOS","COLINI") 
	nLinEnd := oSize:GetDimension("GETDADOS","LINEND") 
	nColEnd := oSize:GetDimension("GETDADOS","COLEND")

	oGet := MSGetDb():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcao,"CTB276LOk", "CTB276TOk", "+CW1_SEQUEN",.T.,aAltera,,.T.,,cAliasTmp,,,,,,, "CTB276Del")

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
			{||nOpca:=1,If(CTB276TOK(nOpcX,cCw1_Indice,cCw1_Tipo),oDlg:End(),nOpca := 0)},;
			{||nOpca:=2,oDlg:End()},,aButtons) VALID nOpca != 0
Else
	cCw1_Codigo 	:= aAutoCab[1,2]
	cCw1_Desc   	:= aAutoCab[2,2]
	cCw1_Tipo   	:= aAutoCab[3,2]
	cCw1_Indice 	:= aAutoCab[4,2]
	cCw1_Entidade 	:= aAutoCab[5,2]

	lOk	:= MsGetDBAuto(	"TMP",;
						aAutoItens,;
						"CTB276LOK",;
						{ || CTB276TOk(nOpcX,cCw1_Indice,cCw1_Tipo) },;
						aAutoCab,;
						nOpcGDB )

	nOpcA := If( lOk,1,0 )
EndIf

If nOpcA == 1 .and. nOpcX <> 2
	Begin Transaction
		If !lCTB276Auto
			AADD(aDados,{"CW1_CODIGO"	,cCw1_Codigo})
			AADD(aDados,{"CW1_DESCRI"	,cCw1_Desc  })
			AADD(aDados,{"CW1_TIPO"  	,cCw1_Tipo  })
			AADD(aDados,{"CW1_INDICE"	,cCw1_Indice})
			AADD(aDados,{"CW1_ENTID"	,cCw1_Entid})			
		Else
			// Se estiver executando rotina automatica e NAO FOR Exclusao,
			// alimentar "aDados" com todos os elementos da matriz recebida
			If nOpcX <> 5
				AADD(aDados,{"CW1_CODIGO",aAutoCab[01,02]})
				AADD(aDados,{"CW1_DESCRI",aAutoCab[02,02]})
				AADD(aDados,{"CW1_TIPO"  ,aAutoCab[03,02]})
				AADD(aDados,{"CW1_INDICE",aAutoCab[04,02]})
				AADD(aDados,{"CW1_ENTID" ,aAutoCab[05,02]})			
			Else
				// Se estiver executando rotina automatica e FOR Exclusao,
				// alimentar "aDados" apenas com o codigo do grupo de rateio, 
				// que eh o primeiro elemento da matriz recebida
				aDados := {	{"CW1_CODIGO",aAutoCab[01,02]} }
			EndIf
		EndIf
		CTB276Grava(cAlias,aDados,nOpcX)
	End Transaction
EndIf

RetIndex("CW1")

DbSelectArea(cAliasTmp)
dbCloseArea()

If _oCtba276 <> Nil
	_oCtba276:Delete()
	_oCtba276 := Nil
Endif

DbSelectArea(cAlias)
Eval(bFiltraBrw)

RestArea(aArea)
dbSelectArea(cAlias)

Return nOpcA

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTB276aHea³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepar aHeader para GetDb                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba276                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB276aHeader(cAlias,aGetDb,aAltera)
Local aArea  := GetArea()

dbSelectArea("SX3")
dbSetOrder(1)

dbSeek(cAlias)

While !EOF() .And. (x3_arquivo == cAlias)

	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. (Ascan(aGetDb,Trim(x3_campo)) > 0 .Or. X3_PROPRI == 'U')

		AADD(aHeader,{	TRIM(X3Titulo()),;
						x3_campo,;
						x3_picture,;
					 	x3_tamanho,;
					 	x3_decimal,;
					 	If(x3_campo="CW1_PERCEN","CTB276Perc(M->CW1_PERCEN)",If(x3_campo="CW1_FATOR","CTB276Fator()",x3_valid)),;
					 	x3_usado,;
					 	x3_tipo,;
					 	"TMP",;
					 	x3_context } )

		If Alltrim(x3_campo) <> "CW1_SEQUEN"
			Aadd(aAltera,Trim(X3_CAMPO))
		EndIf			 

	ENDIF
	Skip
EndDo

RestArea(aArea)

Return Nil


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTB276Grav³ Autor ³ Claudio D. de Souza   ³ Data ³ 18.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as informacoes do rateio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba276                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB276Grava(cAlias,aDados,nOpcX)

LOCAL aArea			:= GetArea()
LOCAL nAscan, nX	:= 0

LOCAL cCw1_Codigo	:= ""
LOCAL cCw1_Entidade	:= ""

LOCAL cGrupo
LOCAL lDelSEQ1		:= .F.
LOCAL lInclui		:= .T.
LOCAL lAlterou      := .F.
LOCAL nCountSeq		:= 0

cCw1_Codigo 	:= aDados[Ascan(aDados,{|e| e[1] = "CW1_CODIGO" } )][2]	 // Obtem o codigo do grupo de rateio
cCw1_Entidade 	:= aDados[Ascan(aDados,{|e| e[1] = "CW1_ENTID"  } )][2]	 // Obtem o codigo do grupo de rateio

(cAlias)->(dbSetOrder(1))

If nOpcX == 5	//	Se for Exclusao
	If (cAlias)->(MsSeek(xFilial(cAlias)+cCw1_Codigo))
		While (cAlias)->(!Eof() .And. xFilial(cAlias) == CW1_FILIAL .And. CW1_CODIGO == cCw1_Codigo)
			RecLock(cAlias,.F.,.T.)
			(cAlias)->(dbDelete())
			(cAlias)->(dbSkip())
		EndDo
	EndIf
	lAlterou := .T.
Else              
   
   // Se for Inclusao em rotina automatica, verificar se o grupo de rateio ja existe. Se existir, 
   // nao deixar incluir e abandonar a rotina.
	If lCTB276Auto
		If (cAlias)->(MsSeek(xFilial(cAlias)+cCw1_Codigo))
			lInclui := .F.
		EndIf
	EndIf

	If lInclui	
	
		TMP->(dbGoTop())
		While TMP->(!Eof())

			(cAlias)->(dbSetOrder(1))
			If TMP->CW1_FLAG  //  Se a linha estiver excluida
				lAlterou := .T.
				If nOpcX == 3  //  Se for Inclusao de Rateio
					If TMP->CW1_SEQUEN == StrZero(1,LEN(TMP->CW1_SEQUEN)) // Se excluiu a primeira linha
						lDelSEQ1 := .T.
					Endif		
				Else
					If (cAlias)->(dbSeek(xFilial(cAlias)+cCw1_Codigo+TMP->CW1_SEQUEN))
						If TMP->CW1_SEQUEN == StrZero(1,LEN(TMP->CW1_SEQUEN))
							lDelSEQ1 := .T.
						Endif
						Reclock(cAlias,.F.,.T.)
						(cAlias)->(dbDelete())
						(cAlias)->(MsUnlock())
					EndIf
				EndIf
			Else		               

				If ! (cAlias)->(dbSeek(xFilial(cAlias)+cCw1_Codigo+TMP->CW1_SEQUEN))
					RecLock(cAlias,.T.)
				Else
					RecLock(cAlias)
				EndIf

				For nX := 1 To (cAlias)->(fCount())
					cNomeCpo := (cAlias)->(FieldName(nx))
					If cNomeCpo == "CW1_FILIAL"
						(cAlias)->CW1_FILIAL := xFilial("CW1") 
						
					ElseIf cNomeCpo == "CW1_STATUS"	
						(cAlias)->CW1_STATUS := IIF(lCw1_Percentual,"1","2")
						
					ElseIf lDelSEQ1 .and. cNomeCpo == "CW1_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA AS DEMAIS SEQUENCIAS
						nCountSeq++
						(cAlias)->CW1_SEQUEN := StrZero(nCountSeq,LEN(TMP->CW1_SEQUEN))
					Else
						// Pesquisa o campo atual em aHeader
						nAscan := Ascan(aHeader,{|e| Upper(AllTrim(e[2])) == Upper(AllTrim((cAlias)->(FieldName(nX))))})
						If nAscan > 0 .And. (cAlias)->(FieldPos(TMP->(FieldName(nX)))) > 0             
							If !lAlterou
								lAlterou := (cAlias)->&(cNomeCpo) <> TMP->&(cNomeCpo)
							EndIf
							(cAlias)->(FieldPut(nX,TMP->(FieldGet(nX)))) // CW1 e TMP tem a mesma estrutura
						Else
							nAscan := Ascan(aDados, {|e| e[1] == (cAlias)->(FieldName(nX))})
							If nAscan > 0
								If !lAlterou .And. !(cNomeCpo $ "CW1_CODIGO/CW1_DESCRI")
									lAlterou := (cAlias)->&(cNomeCpo) <> aDados[nAscan,2]
								EndIf
								(cAlias)->(FieldPut(nX,aDados[nAscan][2]))
							Endif	
						Endif
					Endif
				Next
				(cAlias)->(MsUnlock())
			EndIf
			TMP->(dbSkip())
		EndDo
   	EndIf
EndIf
                                                                                                   
// Atualizando a amarração e os rateios gerados por este grupo
If nOpcx != 3 .AND. lAlterou
	
	IF lCw1_Percentual
		CTB276Amarra(xFilial("CW1"),xFilial("CW2"),aDados[1,2],aDados[3,2],aDados[5,2],nOpcX==5) // Indica se foi a exclusao do grupo
	ELSE
		Help("CTBA276",1,"HELP","CTB276Amarra",	STR0019+CRLF+STR0020+CRLF+STR0021,1,0) //"Percentual do índice inválido."#"Não serão atualizadas as amarraçõees deste"#"grupo de rateios"
	ENDIF

EndIf	

RestArea(aArea)
Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTB276Cria³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara arquivo temporario para GetDb a partir do CW1      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba276                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB276CriaTmp(cAlias,cAliasTmp)

Local aArea	:= GetArea()
Local cArqTmp
Local aStru := (cAlias)->(DbStruct())
		
aadd(aStru,{"CW1_FLAG","L",01,0})

If _oCtba276 <> Nil
	_oCtba276:Delete()
	_oCtba276 := Nil
Endif

_oCtba276 := FWTemporaryTable():New( cAliasTmp )  
_oCtba276:SetFields(aStru) 
_oCtba276:AddIndex("1", {"CW1_FILIAL","CW1_CODIGO"})

//------------------
//Criação da tabela temporaria
//------------------
_oCtba276:Create()  

RestArea(aArea)

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB276Carr³ Autor ³ Claudio D. de Souza   ³ Data ³ 19.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega dados para GetDB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB276Carr(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA276                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB276Carr(nOpc)
Local aSaveArea := GetArea()
Local nPos
Local nCont
Local cAliasTmp
Local cGrupo

cAliasTmp := "TMP"

If nOpc != 3						// Visualizacao / Alteracao / Exclusao
	cGrupo := CW1->CW1_CODIGO
	dbSelectArea("CW1")
	dbSetOrder(1)
	If dbSeek(xFilial()+cGrupo)
		nTotRat := 0
		nTotFat := 0
		While !Eof() .And. (CW1->(CW1_FILIAL + CW1_CODIGO)) == (xFilial("CW1") + cGrupo)
			dbSelectArea(cAliasTmp)
			dbAppend()
			For nCont := 1 To Len(aHeader)
				nPos := FieldPos(aHeader[nCont][2])
				If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
					FieldPut(nPos,CW1->(FieldGet(FieldPos(aHeader[nCont][2]))))
				EndIf
			Next
			nTotRat += (cAliasTmp)->CW1_PERCEN
			nTotFat += (cAliasTmp)->CW1_FATOR
			dbSelectArea("CW1")
			dbSkip()
		EndDo
	EndIf
Else
	dbSelectArea(cAliasTmp)
	dbAppend()
	For nCont := 1 To Len(aHeader)
		If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
			nPos := FieldPos(aHeader[nCont][2])
			FieldPut(nPos,CriaVar(aHeader[nCont][2],.T.))
		EndIf
	Next nCont                      
	(cAliasTmp)->CW1_SEQUEN := "001" 
EndIf
	
dbSelectArea(cAliasTmp)
dbGoTop()

RestArea(aSaveArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276PERCº Autor ³ ------------------ º Data ³  02/08/07     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar a digitacao do percentual das entidades do           º±±
±±º          ³ grupo de rateio                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276Perc(nCW1PERCEN,nOpcX)

LOCAL lRet := .T.
LOCAL nTotRatAnt := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite a utilizacao de um fator ou percentual em branco quando utiliza-se formula ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lFatZero := GETMV("MV_CTQFTZR",.F.,.T.)

DEFAULT nCW1PERCEN := 0

If lFatZero .AND. Empty(nCW1PERCEN) .AND. Empty(TMP->CW1_FORMUL) .AND. !TMP->CW1_FLAG
	If ! lRpc
		Help(" ",1,"INVPERCEN")
	EndIf
	lRet := .F.
ElseIf !lFatZero .AND. Empty(nCW1PERCEN) .AND. !TMP->CW1_FLAG
	If ! lRpc
		Help(" ",1,"INVPERCEN")
	EndIf
	lRet := .F.
ElseIf !TMP->CW1_FLAG
	nTotRatAnt := nTotRat
	If nCW1PERCEN < 0
		nTotRat := nTotRatAnt
		MsgAlert(STR0022)  
		lRet := .F.  
   Else
   	nTotRat -= TMP->CW1_PERCEN
		nTotRat += nCW1PERCEN // M->CW1_PERCEN
		lRet := .T.
   Endif
  	If nTotRat > 100 .and. nOpcX <> 5
		lCw1_Percentual := ValidaPercent("L", cCw1_Tipo, cCw1_Entidade, nTotRat, nCW1PERCEN)
		if !lCw1_Percentual
			Help("CTBA276",1,"HELP","CTBA276PERC",STR0022+CRLF+STR0023,1,0)  //"Percentual informado diferente de 100%"#"Grupo será gravado como bloqueado."
		ENDIF
   Endif
 	If lRet
 		If !lCTB276Auto
			oTotRat:Refresh()
		EndIf
	End
Endif		

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB276TOK ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega dados para GetDB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB276TOK(nOpcX,cIndEstat,cCw1_Tipo)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA276                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcX     = Opcao selecionada          					  ³±±
±±³          ³ cIndEstat = Indice Estatistico (CW3) informado   		  ³±±
±±³          ³ cTipo     = Tipo do Grupo: 1-Origem; 2-Destino   		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276TOk(nOpcX)

LOCAL aArea   	:= GetArea()
LOCAL aAreaCW3	:= CW3->(GetArea())
LOCAL nRecno    := TMP->(Recno())
LOCAL lRet      := .T.
LOCAL nEntid    := 0
LOCAL aEntid    := {}
LOCAL cEntidade := ""
LOCAL nTotDig	:= 0
LOCAL lUsaForm	:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite a utilizacao de um fator ou percentual em branco quando utiliza-se formula ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lFatZero 	:= GETMV("MV_CTQFTZR",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos campos obrigatorios do cabecalho                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF 	Empty(cCw1_Codigo) 	.OR.;
	Empty(cCw1_Desc)	.OR.;
	Empty(cCw1_Tipo)	.OR.;
	Empty(cCw1_Entidade)
	Help("",1,"OBRIGCAMPO") // CAMPOS OBRIGATORIOS NÃO PREENCHIDOS
	lRet := .F.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validação dos percentuais individuais de cada linha          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lRet
	dbSelectArea("TMP")
	dbGotop()
	While TMP->(!Eof())
		IF CTB276Perc( TMP->CW1_PERCEN,nOpcX )
			IF !(TMP->CW1_FLAG)
				nTotDig	+= TMP->CW1_PERCEN
			ENDIF
			IF !lUsaForm .AND. !EMPTY(TMP->CW1_FORMUL)
				lUsaForm := .T.
			ENDIF
		ELSE
			lRet := .F.
			Exit
		ENDIF
		If lRet .And. !EMPTY(TMP->CW1_CONTA) .And. !TMP->CW1_FLAG
			If lRet .And. Posicione("CT1",1, xFilial("CT1")+TMP->CW1_CONTA,"CT1_BLOQ") == "1"
				ShowHelpDlg("CT1BLOQ",{STR0065 +AllTrim(TMP->CW1_CONTA)+ STR0066,STR0067},5,{STR0069,STR0070},5)  //"A conta"##"do plano de contas"##"está bloqueada."##"Favor escolher outra código do"##"plano de contas"
				lRet := .F.
				Exit
			EndIf
			If lRet .And. Posicione("CT1",1, xFilial("CT1")+TMP->CW1_CONTA,"CT1_CLASSE") == "1"
				ShowHelpDlg("CT1BLOQ",{STR0065 +AllTrim(TMP->CW1_CONTA)+ STR0066,STR0068},5,{STR0069,STR0070},5)  //"A conta"##"do plano de contas"##"está sintético."##"Favor escolher outra código do"##"plano de contas"
				lRet := .F.
				Exit
         EndIf
		EndIf
		TMP->(DbSkip())
	EndDo
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validações pertinentes apenas para tipo 2 - Destino          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lRet .AND. cCw1_Tipo == "2"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao da consistencia do grupo. Caso invalido ficará bloqueado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lRet .AND. (nOpcX == 3 .Or. nOpcX == 4)
		IF (nTotRat <> 100 .AND. !lFatZero) .OR. (nTotDig <> 100 .AND. lFatZero .And. !lUsaForm)

			lRet := ValidaPercent("T", cCw1_Tipo, cCw1_Entidade, nTotDig, NIL)

			IF !lRpc .AND. !lRet
				Help(" ",1,"PERCINVAL")
			ENDIF

		ELSEIF nTotDig <> 100 .AND. lFatZero .And. lUsaForm

			lCw1_Percentual := ValidaPercent("T", cCw1_Tipo, cCw1_Entidade, nTotDig, NIL)

			IF !lRpc .AND. !lCw1_Percentual
				Help("CTBA276",1,"HELP","CTBA276PERC",STR0022+CRLF+STR0023,1,0)  //"Percentual informado diferente de 100%"#"Grupo será gravado como bloqueado."
			ENDIF
		ELSEIF nTotDig == 100
			lCw1_Percentual := .T.
		ENDIF
	ENDIF

ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao da utilizacao das entidades e do indice estatistico      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lRet .And. (nOpcX == 3 .Or. nOpcX == 4)

	If nTotDig > 100
		lCw1_Percentual := ValidaPercent("T", cCw1_Tipo, cCw1_Entidade, nTotDig, NIL)
	EndIf

	// Jogando as entidades na matriz "aEntid" para ver se todas as entidades do indice foram utilizadas
	CW3->( DbSetOrder(2) )
    TMP->( DbGoTop() )
    While ! TMP->(EOF())
    	If ! TMP->CW1_FLAG
			If Empty(TMP->CW1_CONTA+TMP->CW1_CCUSTO+TMP->CW1_ITEM+TMP->CW1_CLVL)
				Help("CTBA276",1,"HELP","CTB276Entid",STR0012,1,0)//	"Todas as linhas devem ter ao menos uma Entidade Contábil"		
				lRet := .F.
				Exit
			EndIf
			Aadd( aEntid,{TMP->CW1_CONTA, TMP->CW1_CCUSTO, TMP->CW1_ITEM, TMP->CW1_CLVL} )
                   
            // Se informou o Indice estatistico, verificar se uma das entidades de cada linha esta cadastrada 
            // no Indice (CW3) informado 
            If !Empty(cCw1_Indice)
				For nEntid := 1 to 4
					cEntidade := aEntid[ Len(aEntid),nEntid ]
					If ! Empty( cEntidade )
						lRet := CW3->( DbSeek( xFilial("CW3")+cCw1_Indice+Str(nEntid,1)+cEntidade ) )
						If lRet
							Exit
						EndIf
					EndIf
				Next
				If !lRet
					lRet := MsgYesNo(STR0024+CRLF+STR0025) //"Existem entidades utilizadas que não pertencem ao indice estatístico."#"Deseja prosseguir com a operação?"
				EndIf
			EndIf

			// Validacao para avaliar se existem outras linhas com as mesmas entidades contabeis		
			If lRet .AND. !CT276VLDENT(TMP->CW1_CONTA,TMP->CW1_CCUSTO,TMP->CW1_ITEM,TMP->CW1_CLVL)
				Help("",1,"EXISTCHAV") // Esta chave já existe
				lRet := .F.
			Endif		
		
			If !lRet
				Exit
			Endif
		
		EndIf
		TMP->( DbSkip() )
	EndDo
EndIf

RestArea(aAreaCW3)
RestArea(aArea)
TMP->(MsGoTo(nRecno))
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTB276DELºAutor  ³Microsiga           º Data ³  04/19/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Na exclusão de uma linha do grupo de rateio, atualiza o    º±±
±±º          ³ valor no rodape.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276Del()

Local nCw1_Fator := TMP->CW1_FATOR

If TMP->CW1_FLAG
	nTotRat += TMP->CW1_PERCEN
	nTotFat += TMP->CW1_FATOR
	M->CW1_FATOR := TMP->CW1_FATOR
	IF nCw1_Fator != 0 .AND. !Empty(TMP->CW1_FORMUL)
		CTB276AtuPer(.T.)
	ENDIF
Else
	nTotRat -= TMP->CW1_PERCEN
	nTotFat -= TMP->CW1_FATOR	
	M->CW1_FATOR := 0
	IF nCw1_Fator != 0 .AND. !Empty(TMP->CW1_FORMUL)
		CTB276AtuPer(.T.)
	ENDIF
Endif
oTotRat:Refresh()
oTotFat:Refresh()


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276VALIDº Autor ³ ------------------ º Data ³  02/08/07     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar a digitacao do codigo e descricao do grupo de rateio  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276Valid(cCampo,xConteudo)
Local lRet  := .T., aArea := GetArea()

If Empty(xConteudo)
	lRet := .f.
	Help(" ",1,"VAZIO")
Else
	Do Case
	Case cCampo = "CW1_CODIGO"
		DbSelectArea("CW1")
		dbSetOrder(1)
		If CW1->(MsSeek(xFilial("CW1")+xConteudo))
			lRet := .F.
			Help(" ",1,"JAEXISTINF")
		Endif
	EndCase
Endif
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276LOk ºAutor  ³Marcos S. Lobo      º Data ³  02/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validação de linha da tela de cadastro de rateios  º±±
±±º          ³off-line.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276LOk()

LOCAL nOrdCW3     := CW3->( IndexOrd() )
LOCAL lAchouEntid := .F.
LOCAL cEntid      := ""
LOCAL cCodEnt     := ""
LOCAL lFatZero 	  := GETMV("MV_CTQFTZR",.F.,.T.)  // PERMITE FATOR + PERCENTUAL ZERADO QUANDO USA FORMULA
LOCAL lRet		  := .T.
  
IF !TMP->CW1_FLAG			/// SE NÃO ESTIVER DELETADO

	IF cCw1_Tipo == "1" // VALIDACOES PERTINENTES APENAS PARA GRUPOS DE DESTINO
	
		IF Empty(TMP->CW1_PERCEN)
			IF ! lRpc
				Help(" ",1,"NOPERCENT")
			ENDIF
			lRet := .F.
		ENDIF
 		
	ELSEIF cCw1_Tipo == "2" // VALIDACOES PERTINENTES APENAS PARA GRUPOS DE DESTINO
	
		IF lFatZero .AND. Empty(TMP->CW1_PERCEN) .AND. Empty(TMP->CW1_FORMUL)
			IF ! lRpc
				Help(" ",1,"NOPERCENT")
			ENDIF
			lRet := .F.
		ELSEIF !lFatZero .AND. Empty(TMP->CW1_PERCEN)
			IF ! lRpc
				Help(" ",1,"NOPERCENT")
			ENDIF
			lRet := .F.
		ENDIF
    
    	IF lRet .And. !Empty(cCw1_Indice)
			// Verificar no CW3 (Indices Estatisticos) se o indice informado contem a entidade 
			// informada na linha.
			CW3->( DbSetOrder(2) )
			CW3->( DbSeek( xFilial("CW3")+cCw1_Indice ) )
			IF ! CW3->(EOF())
				cEntid := CW3->CW3_ENTID
				IF     cEntid == "1"	;	cCodEnt := TMP->CW1_CONTA
				ELSEIF cEntid == "2"	;	cCodEnt := TMP->CW1_CCUSTO
				ELSEIF cEntid == "3"	;	cCodEnt := TMP->CW1_ITEM
				ELSEIF cEntid == "4"	;	cCodEnt := TMP->CW1_CLVL
				ENDIF
				lAchouEntid := CW3->( DbSeek( xFilial("CW3")+cCw1_Indice+cEntid+cCodEnt ) )
			ENDIF
			CW3->( DbSetOrder(nOrdCW3) )
        
			IF ! lAchouEntid
				IF !lRpc
					lRet := MsgYesNo(STR0024+CRLF+STR0025) //"Existem entidades utilizadas que não pertencem ao indice estatístico."#"Deseja prosseguir com a operação?"
				ELSE
					lRet :=	.F.
				ENDIF
			ENDIF

		ENDIF

    ENDIF
	
	IF lRet .And. Empty(TMP->CW1_CONTA+TMP->CW1_CCUSTO+TMP->CW1_ITEM+TMP->CW1_CLVL)
		Help("CTBA276",1,"HELP","CTB276Entid",STR0016,1,0)	//	"Preencher ao menos uma Entidade Contábil"
		lRet := .F.
	ENDIF

    // Validacao para avaliar se existem outras linhas com as mesmas entidades contabeis
	IF lRet .AND. !CT276VLDENT(TMP->CW1_CONTA,TMP->CW1_CCUSTO,TMP->CW1_ITEM,TMP->CW1_CLVL)
		Help("",1,"EXISTCHAV") // Esta chave já existe
		lRet := .F.
	ENDIF

ENDIF

RETURN lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276VlTG  ºAutor  ³ Eduardo Nunes Cirqueira º Data ³ 04/08/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a digitacao do Tipo de Grupo, exigindo 1-Origem ou      º±±
±±º          ³ 2-Destino                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276VlTG(cTipo)
Local lRet := (cTipo $ "12")
If ! lRet
	Help("CTBA276",1,"HELP","CTB276Grupo",STR0018,1,0) //	"Tipo do Grupo incorreto. Informar 1-Origem ou 2-Destino"
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276VlTE  ºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a digitacao do tipo de entidade do Indice de Rateio x   º±±
±±º          ³ Tipo de entidade do Grupo.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276VlTE(cCw3Indice, cGrpEntid)
Local aArea := GetArea()
Local lRet	:= .T.

IF Empty(cCw3Indice)
	Return .T.
ENDIF

CW3->(DbSetOrder(1))
CW3->(MsSeek(xFilial("CW3")+cCw3Indice))
IF cGrpEntid != "5" .AND. CW3->CW3_ENTID != cGrpEntid
	Help("CTBA276",1,"HELP","CTB276EntBase",	STR0026+CRLF+STR0027+CRLF+STR0028+CRLF+STR0029+CRLF+STR0030,1,0)
	//"Tipo de entidade do indice nao confere "#"com a entidade base do grupo."#"As entidades do indice de rateios e a "#"entidade base do grupo de rateios devem "#"ter o mesmo tipo."
	lRet := .F.
ENDIF

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT276VLDENT ºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se existe outra linha com a mesma combinacao de entida- º±±
±±º          ³ des da atual.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                       
Static Function CT276VLDENT(cConta,cCusto,cItemCTA,cCVLV)

Local nRecno := TMP->( Recno() )
Local lRet 	:= .T.

TMP->(DbGotop())
While TMP->(!EOF())
	
	IF !TMP->CW1_FLAG .AND. TMP->(Recno()) != nRecno
		IF  TMP->CW1_CONTA 	== cConta 	.AND. ;
			TMP->CW1_CCUSTO	== cCusto 	.AND. ;
			TMP->CW1_ITEM	== cItemCTA .AND. ;
			TMP->CW1_CLVL 	== cCVLV
			lRet := .F.
	    ENDIF
	ENDIF

	TMP->(DbSkip())
End

TMP->(DbGoto(nRecno))
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276AmarraºAutor  ³ Eduardo Nunes Cirqueira º Data ³ 04/08/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza para "2-Alterado" o status das Amarracoes de Grupo de º±±
±±º          ³ Rateio que contem o grupo (cCodGrupo) passado no parametro     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276Amarra(cFilCW1,cFilCW2,cCw1_Codigo,cCw1_Tipo,cCw1_Entid,lExclusao,lDireto,lGeraCTQ)

Local aArea 		:= GetArea()
Local lRet			:= .T.
Local aNickOri 		:= {"CW2_ORIGEM","CW2_CTTORI","CW2_CTDORI","CW2_CTHORI","CW2_ORIGEM"}
Local aNickDes		:= {"CW2_DESTIN","CW2_CTTDES","CW2_CTDDES","CW2_CTHDES","CW2_DESTIN"}
Local cNickName		:= ""
Local cKeyNick		:= ""
Local cCw1_CodEnt 	:= ""
Local aCw2_Codigo	:= {}
Local aParam		:= {"","",2}
Local lExistCW1		:= .F.
Local nX			:= 0

Default lDireto		:= .F.
Default lGeraCTQ	:= .F.

IF cCw1_Tipo == "1" // 1 - Origem
	cNickName := aNickOri[Val(cCw1_Entid)]
ELSE // 2 - Destino
	cNickName := aNickDes[Val(cCw1_Entid)]
ENDIF
cKeyNick  := "CW2->(CW2_FILIAL+"+cNickName+")"

DbSelectArea("CTQ")
DbSetOrder(2)

DbSelectArea("CW2")
DbOrderNickName(cNickName)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o status do cadastro de amarracoes      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CW2->(MsSeek(cFilCW2+cCw1_Codigo))
While !CW2->(Eof()) .And. &cKeyNick == cFilCW2+cCw1_Codigo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de status das amarracoes:               ³
	//³ 1- Pendente de geracao                           ³
	//³ 2- Alterado -> atualizar                         ³
	//³ 3- Gerado -> atualizado                          ³
	//³ 4- Bloqueado                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	AADD(aCw2_Codigo,CW2->CW2_CODIGO)
	RecLock("CW2",.F.)
	CW2->CW2_STATUS := IIF(lExclusao,"4","2")
	CW2->CW2_MSBLQL := IIF(lExclusao,"1","2")	
	CW2->(MsUnLock())
	CW2->( DbSkip() )

EndDo               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o grupo foi totalmente excluido       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lExclusao
	lExistCW1 := CW1->(MsSeek(cFilCW1+cCw1_Codigo))
ELSE
	lExistCW1 := .T.
ENDIF

IF !lDireto
	lGeraCTQ := MsgYesNo(STR0031,STR0032) //"Deseja atualizar os rateios off-line vinculados as amarrações deste grupo de rateios?"##"Atualização de Rateios Off-Line"
ENDIF

IF lGeraCTQ
	For nX := 1 to Len(aCw2_Codigo)
	
		IF lExistCW1
			aParam[1] := aCw2_Codigo[nX]
			aParam[2] := aCw2_Codigo[nX]
			CTB277GerCTQ(.T.,aParam)
		ELSE
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se existem rateios vinculados ao grupo   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF	CTQ->( DbSeek(xFilial("CTQ")+aCw2_Codigo[nX] ) )		
				MsgRun(STR0033,STR0034,{||CTB277DelCTQ(aCw2_Codigo[nX])})//"Excluindo rateios off-lines vinculados..."##"Exclusão de rateios off-line"
			ENDIF
			
		ENDIF
	
	Next nX
	
ENDIF

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTB276FPrc º Autor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o conteudo do campo CW1_FATOR de acordo com o fator   º±±
±±º          ³ da entidade no indice estatistico e refaz o percentual.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276FPrc(cCampo)
Local aArea 	:= GetArea()
Local cEntid	:= "0"
Local cCodEnt	:= &(ReadVar())

IF Empty(cCw1_Indice)
	Return .T.
ENDIF

DO CASE
	CASE cCampo == "CW1_CONTA"
		cEntid := "1"
	CASE cCampo == "CW1_CCUSTO"
		cEntid := "2"
	CASE cCampo == "CW1_ITEM"
		cEntid := "3"
	CASE cCampo == "CW1_CLVL"
		cEntid := "4"				
ENDCASE

CW3->(DbSetOrder(2))
IF 	CW3->(MsSeek(xFilial("CW3")+cCw1_Indice+cEntid+cCodEnt)) .AND.;
	CW3->CW3_ENTID == cEntid // SOMENTE SE O CAMPO CHAMADOR FOR A ENTIDADE VINCULADA NO INDICE

	M->CW1_FATOR := CW3->CW3_FATOR
	CTB276Fator()
	
ENDIF

RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTB276Fatorº Autor ³ Eduardo Nunes Cirqueira º Data ³ 04/08/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os totais dos fatores, percentuais e os percentuais   º±±
±±º          ³ de cada linha do grupo de rateio.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276Fator()

Local lRet := .F.

If !TMP->CW1_FLAG
	nTotFat += (M->CW1_FATOR - TMP->CW1_FATOR)
	lRet := .T.
	CTB276AtuPer()
	TMP->CW1_FATOR := M->CW1_FATOR
	oTotFat:Refresh()
	oTotRat:Refresh()
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276AtuPerºAutor  ³ Eduardo Nunes Cirqueira º Data ³ 04/08/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os percentuais com base nos valores dos fatores infor-º±±
±±º          ³ mados.                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276AtuPer(lDeleta)

Local nRecno 	:= TMP->( Recno() )
Local nDifPerc	:= 0
Local aDados	:= {} 
Local aTamPerc	:= TAMSX3("CW1_PERCEN")
Local lRet		:= .T.
Local nX		:= 0

Default lDeleta := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a variavel totalizadora do percentual                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotRat := 0
                  
TMP->( dbGoTop() )
// PREPARA DADOS PARA ATUALIZACAO DO PERCENTUAL PELO FATOR
Do While TMP->( ! EoF() )

	IF TMP->(Recno()) == nRecno
    
		If TMP->CW1_FLAG .AND. lDeleta
			AADD(aDados,{"", M->CW1_FATOR	, 0, TMP->( Recno() ) }) // 3- Novo percentual
		ElseIf !TMP->CW1_FLAG .AND. !lDeleta
			AADD(aDados,{"", M->CW1_FATOR	, 0, TMP->( Recno() ) }) // 3- Novo percentual
		EndIf

	ELSEIF !TMP->CW1_FLAG
		AADD(aDados,{"", TMP->CW1_FATOR, 0, TMP->( Recno() ) }) // 3- Novo percentual	
	ENDIF

	TMP->( dbSkip() )
EndDo

// COMPOE PERCENTUAIS COM BASE NA RELACAO DO FATOR DA LINHA COM O TOTAL DO FATOR DO GRUPO
// FATOR GLOBAL JÁ ESTA ATUALIZADO: PRIVATE nTotFat
For nX := 1 to Len(aDados)
	aDados[nX][3] := Round(NoRound((aDados[nX][2]/nTotFat)*100,aTamPerc[2]+1),aTamPerc[2])
	nTotRat += aDados[nX][3]
Next nX

// AJUSTA O PERCENTUAL PARA 100% CASO HAJA DIFERENCA
// REALIZA O AJUSTE SEMPRE NA ULTIMA LINHA CUJO O PERCENTUAL SUPORTE A DIFERENCA
IF nTotRat <> 100
	nDifPerc := 100 - nTotRat
	FOR nX := Len(aDados) TO 1 STEP -1
		IF aDados[nX][3] > ABS(nDifPerc)
			aDados[nX][3] += nDifPerc
			nTotRat += nDifPerc  
			EXIT
		ENDIF
	NEXT nX
ENDIF

// AJUSTA OS PERCENTUAIS DAS LINHAS PARA OS PERCENTUAIS CALCULADOS
For nX := 1 to Len(aDados)
	TMP->(dbGoto(aDados[nX][4]))
	TMP->CW1_PERCEN := aDados[nX][3]
	If TMP->(Recno()) == nRecno
		M->CW1_PERCEN := aDados[nX][3]
	Endif
Next nX

TMP->( dbGoTo( nRecno ) )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276IndiceºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o aCols do cadastro de grupo de rateios com base nas  º±±
±±º          ³ entidades selecionadas no cadastro de indice estatistico       º±±
±±º          ³ vinculado ao grupo.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276Indice(oGetDB)

LOCAL aChave		:= {}
LOCAL aArea			:= GetArea()
LOCAL bCondicao		:= {|| .T.}
LOCAL cAlias		:= "CW3"
LOCAL aCposAlias	:= {"CW3_CODENT"}
LOCAL cTitulo		:= ""
LOCAL cFilAlias		:= xFilial(cAlias)
LOCAL cEntidade 	:= ""
LOCAL cCw3_Entidade	:= ""

// Variaveis utilizadas na selecao de categorias
LOCAL oDlg,oChkQual,lQual,oQual,oBtnOK,oBtnCan,oBtnFil,oGroup
// Carrega bitmaps
LOCAL oOk      := LoadBitmap( GetResources(), "LBOK")
LOCAL oNo      := LoadBitmap( GetResources(), "LBNO")
// Variaveis utilizadas para lista de filiais
LOCAL nx       := 0
LOCAL nAchou   := 0
LOCAL cDescEnt := STR0059 //"Itens do indice estatistico:"
LOCAL lRet		:= .F.
LOCAL cFilExpr	:= ""
LOCAL bDBLClick, bClick, bSetGet

IF EMPTY(cCw1_Indice)
	Help("CTBA276",1,"HELP","CTB276Indice",STR0035+CRLF+STR0036,1,0) //"Nao existe um indice estatistico vinculado"##"a este cadastro."
	RETURN .T.
ELSEIF !MsgYesNo(STR0037+CRLF+STR0038+CRLF+STR0039+CRLF+STR0040) //"Esta rotina ira refazer os dados do grupo de rateio, "##"apagando as informacoes atuais e substituindo-as pela "#"selecao dos itens do indice estatistico."#				 
	RETURN .T.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as entidades do intervalo no array da ListBox        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
DbSeek(cFilAlias+cCw1_Indice)

cTitulo 	 := CW3->CW3_DESCRI
cCw3_Entidade:= CW3->CW3_ENTID

DO CASE
	CASE  cCw3_Entidade == "1"
		cEntidade := STR0055//"Conta Contabil"
	CASE  cCw3_Entidade == "2"
		cEntidade := STR0056//"Centro de Custo"
	CASE  cCw3_Entidade == "3"
		cEntidade := STR0057//"Item Contabil"	
	CASE  cCw3_Entidade == "4"
		cEntidade := STR0058//"Classe de Valor"	
ENDCASE	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array aChave com os itens que serao exibidos em tela   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CtbChave(cAlias,cFilAlias,aCposAlias,"1",cFilExpr,@aChave,cCw1_Indice)

IF Len(aChave) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela para selecao dos itens da entidade contabil       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg:= MSDIALOG():New(000,000,300,625, cTitulo,,,,,,,,,.T.)
	oDlg:lEscClose := .F.
	oGroup := TGROUP():New(005,015,125,300,cDescEnt,oDlg,,,.T.)
	
	bClick := {||(AEval(aChave, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))}
	bSetGet:= {|l| IIF(PCount()>0,lQual:=l,lQual)}
	oChkQual:= tCheckBox():New(15,20,STR0053,bSetGet,oDlg,50,10,,bClick,,,,,,.T.) //"Inverte Seleção"
    
	bDBLClick := {|| (CtbTroca(oQual:nAt,@aChave),oQual:Refresh())}
	oQual := TwBrowse():New(30,20,273,090,,{"",cEntidade,STR0054},,oDlg,,,,,bDBLClick,,,,,,,.F.,,.T.,,.F.,,,)//"Fator"
	oQual:SetArray(aChave)
	oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2],aChave[oQual:nAt,3]}}
    
	oBtnOK  := SBUTTON():New(134, 210, 01, {|| IIF(CtbMarcaOk(aChave),(lRet := .T.,oDlg:End()),)}, oDlg, .T., , {|| .T.}) 
	oBtnCan := SBUTTON():New(134, 240, 02, {|| (lRet := .F.,oDlg:End())}		, oDlg, .T., , {|| .T.}) 
	oBtnFil := SBUTTON():New(134, 270, 17, {|| (	cFilExpr := BuildExpr(cAlias),;
													CtbChave(cAlias,cFilAlias,aCposAlias,"1",cFilExpr,@aChave,cCw1_Indice),;
													oQual:SetArray(aChave),;
													oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2],aChave[oQual:nAt,3]}},;
													oQual:Refresh())}	, oDlg, .T., , {|| .T.})

	oDlg:lCentered := .T.
	oDlg:Activate()
ELSE
	HELP(" ",1,"NORECS")
ENDIF

CTB276AtuTMP(oGetDb,aChave,cCw3_Entidade,.T.)

RestArea(aArea)
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTB276EntidºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o aCols do cadastro de tipos de rateios com base nas  º±±
±±º          ³ entidades selecionadas no cadastro contabil vinculado ao       º±±
±±º          ³ tipo do grupo, quando o mesmo nao for combinado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276Entid(oGetDB)

LOCAL aChave	:= {}
LOCAL aArea		:= GetArea()
LOCAL bCondicao	:= {|| .T.}
LOCAL aAlias	:= {"CT1","CTT","CTD","CTH"}
LOCAL aCposAlias:= {"CT1_CONTA","CTT_CUSTO","CTD_ITEM","CTH_CLVL"}
LOCAL cAlias	:= ""
LOCAL cTitulo	:= ""
LOCAL cFilAlias	:= ""
LOCAL cEntidade := ""
LOCAL cTpEntid	:= ""

// Variaveis utilizadas na selecao de categorias
LOCAL oDlg,oChkQual,lQual,oQual,oBtnOK,oBtnCan,oBtnFil,oGroup
// Carrega bitmaps
LOCAL oOk       := LoadBitmap( GetResources(), "LBOK")
LOCAL oNo       := LoadBitmap( GetResources(), "LBNO")
// Variaveis utilizadas para lista de filiais
LOCAL nx        := 0
LOCAL nAchou    := 0
LOCAL lRet		:= .F.
LOCAL cFilExpr	:= ""
LOCAL bDBLClick, bClick, bSetGet

IF EMPTY(cCw1_Entidade) .OR. cCw1_Entidade == "5" // Combinado
	Help("CTBA276",1,"HELP","CTB276Entid",STR0041+CRLF+STR0042,1,0) //"O tipo de entidade selecionada não permite "#"o uso deste recurso"
	RETURN .T.
ELSEIF !MsgYesNo(STR0043+CRLF+STR0044+CRLF+STR0045+CRLF+STR0040) //"Esta rotina ira refazer os dados do grupo de rateio, "#"apagando as informacoes atuais e substituindo-as pela "#"selecao dos itens do indice estatistico."#"Deseja continuar?"
	RETURN .T.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as entidades do intervalo no array da ListBox        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias 		:= aAlias[Val(cCw1_Entidade)]
cFilAlias 	:= xFilial(cAlias)
cTitulo		:= (SX2->(DbSeek(cAlias)),X2NOME())

DO CASE 
	CASE  cCw1_Entidade == "1"
		cEntidade := STR0055//"Conta Contabil"
	CASE  cCw1_Entidade == "2"
		cEntidade := STR0056//"Centro de Custo"
	CASE  cCw1_Entidade == "3"
		cEntidade := STR0057//"Item Contabil"	
	CASE  cCw1_Entidade == "4"
		cEntidade := STR0058//"Classe de Valor"
ENDCASE	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array aChave com os itens que serao exibidos em tela   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CtbChave(cAlias,cFilAlias,aCposAlias,cCw1_Entidade,cFilExpr,@aChave)

IF Len(aChave) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela para selecao dos itens da entidade contabil       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg:= MSDIALOG():New(000,000,300,625, cTitulo,,,,,,,,,.T.)
	oDlg:lEscClose := .F.
	oGroup := TGROUP():New(005,015,125,300,cTitulo,oDlg,,,.T.)
	
	bClick := {||(AEval(aChave, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))}
	bSetGet:= {|l| IIF(PCount()>0,lQual:=l,lQual)}
	oChkQual:= tCheckBox():New(15,20,STR0053,bSetGet,oDlg,50,10,,bClick,,,,,,.T.)//"Inverte Seleção"
    
	bDBLClick := {|| (CtbTroca(oQual:nAt,@aChave),oQual:Refresh())}
	oQual := TwBrowse():New(30,20,273,090,,{"",cEntidade},,oDlg,,,,,bDBLClick,,,,,,,.F.,,.T.,,.F.,,,)
	oQual:SetArray(aChave)
	oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2]}}
    
	oBtnOK  := SBUTTON():New(134, 210, 01, {|| IIF(CtbMarcaOk(aChave),(lRet := .T.,oDlg:End()),)}, oDlg, .T., , {|| .T.}) 
	oBtnCan := SBUTTON():New(134, 240, 02, {|| (lRet := .F.,oDlg:End())}		, oDlg, .T., , {|| .T.})
	oBtnFil := SBUTTON():New(134, 270, 17, {|| (	cFilExpr := BuildExpr(cAlias),;
													CtbChave(cAlias,cFilAlias,aCposAlias,cCw1_Entidade,cFilExpr,@aChave),;
													oQual:SetArray(aChave),;
													oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2]}},;
													oQual:Refresh())}	, oDlg, .T., , {|| .T.})

	oDlg:lCentered := .T.
	oDlg:Activate()
ELSE
	HELP(" ",1,"NORECS")
ENDIF

CTB276AtuTMP(oGetDb,aChave,cCw1_Entidade,.F.)

RestArea(aArea)
RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtbChave º Autor ³ Arnaldo R. Junior  º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbChave(cAlias,cFilAlias,aCposAlias,cEntidade,cFilExpr,aChave,cCw1_Indice)
Local aArea 		:= GetArea()
Local bBlock
Local xResult
Local cFilConPad	:= ""

Default	cCw1_Indice	:= ""
aChave := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aChave    - Contem as entidades que serao exibidas na tela de  |
//| selecao.                                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cAlias != "CW3" .AND. SXB->(DbSeek(PADR(cAlias,6,"")+"6"+"01")) .AND. !Empty(SXB->XB_CONTEM)
	cFilConPad := ALLTRIM(SXB->XB_CONTEM)
ELSEIF cAlias == "CW3"
	cFilConPad := "CW3->CW3_CODIGO == cCw1_Indice"
ENDIF

IF Empty(cFilExpr) .AND. Empty(cFilConPad)
	cFilExpr := ".T."
ELSEIF Empty(cFilExpr) .AND. !Empty(cFilConPad)
	cFilExpr := cFilConPad
ELSEIF !Empty(cFilExpr) .AND. !Empty(cFilConPad)
	cFilExpr += " .AND. ("+cFilConPad+")"
ENDIF

bBlock := ErrorBlock( { |e| ChecErro(e) } )
BEGIN SEQUENCE
	xResult := (cAlias)->&(cFilExpr)
RECOVER
	cFilExpr := ".T."
END SEQUENCE
ErrorBlock(bBlock)

DbSelectArea(cAlias)
DbGotop()

IF cAlias == "CW3"
	DbSeek(cFilAlias+cCw1_Indice)
EndIf

Do While (cAlias)->(!Eof()) .AND. (cAlias)->&(cAlias+"_FILIAL") == cFilAlias
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aChave    - Contem as entidades que serao exibidas na tela de  |
	//| selecao.                                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF cAlias != "CW3" .AND. (cAlias)->&(cAlias+"_CLASSE") == "2" .AND. (cAlias)->&(cFilExpr)// SOMENTE ENTIDADES ANALITICAS
		Aadd(aChave,{.F.,(cAlias)->&(aCposAlias[Val(cEntidade)])})
	ELSEIF cAlias == "CW3" .AND. (cAlias)->&(cFilExpr)
		Aadd(aChave,{.F.,(cAlias)->&(aCposAlias[Val(cEntidade)]),(cAlias)->CW3_FATOR})
	ENDIF
	(cAlias)->(dbSkip())
EndDo

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtbTroca º Autor ³ Arnaldo R. Junior  º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbTroca(nIt,aArray)
aArray[nIt,1] := !aArray[nIt,1]
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMarcaOkº Autor ³ Arnaldo R. Junior  º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                                  
Static Function CtbMarcaOk(aArray)
LOCAL lRet:=.F.
LOCAL nx:=0

// Checa marcacoes efetuadas
For nx:=1 To Len(aArray)
	If aArray[nx,1]
		lRet:=.T.
	EndIf
Next nx
// Checa se existe algum item marcado na confirmacao
If !lRet
	Help("CTBMARCA",1,"HELP","NOMARKITENS",STR0046,1,0) //"Nao existem itens marcados"
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276AtuTMPº Autor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o aCols com os itens selecionados.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTB                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276AtuTMP(oGetDb,aChave,cTpEntid,lFator)

LOCAL nX 	 := 0
LOCAL lItens := .F.
LOCAL cNewSeq:= ""
LOCAL nCount := 0
LOCAL lUsaLinha := .F.
           
// Inicia as variaveis de totalizacao do fator e do percentual
nTotFat := 0
nTotRat := 0

// Verifica se existem itens selecionados no Array
FOR nX := 1 to Len(aChave)
	IF aChave[nX,1]
		lItens := .T.
		EXIT
	ENDIF
NEXT nX

IF lItens

	TMP->(DbGoTop())
	WHILE TMP->(!EOF())
		nCount++
		
		IF nCount <= oGetDb:nCount .OR. TMP->CW1_PERCENT != 0
			TMP->CW1_FLAG := .T. // Marca a Linha como excluida
		ELSE
			lUsaLinha := .T.
			Exit
		ENDIF

		cNewSeq := TMP->CW1_SEQUEN
		TMP->(DbSkip())	
	END

	nTotRat:= 0
	nTotFat:= 0
	oTotFat:Refresh()
	oTotRat:Refresh()
	oGetDb:Refresh()
	
	FOR nX := 1 to Len(aChave)
		IF aChave[nX,1]
			
			IF !lUsaLinha
				oGetDb:AddLine()
			ELSE
				lUsaLinha := .F.
			ENDIF
			
			M->CW1_CONTA		:= IIF(cTpEntid == "1", aChave[nX,2], "")
			M->CW1_CCUSTO		:= IIF(cTpEntid == "2", aChave[nX,2], "")
			M->CW1_ITEM			:= IIF(cTpEntid == "3", aChave[nX,2], "")
			M->CW1_CLVL			:= IIF(cTpEntid == "4", aChave[nX,2], "")
			M->CW1_PERCEN		:= 0
			M->CW1_FATOR		:= IIF(lFator,aChave[nX,3],0)
			M->CW1_FORMUL		:= ""
			
			CTB276Fator()
			M->CW1_PERCEN		:= TMP->CW1_PERCEN // Atualizado pela CTB276Fator()->CTB276AtuPer()
			
			// Atualiza dados do temporario para compatibilizar com as variaveis em memoria
			TMP->CW1_CONTA		:= M->CW1_CONTA
			TMP->CW1_CCUSTO		:= M->CW1_CCUSTO
			TMP->CW1_ITEM		:= M->CW1_ITEM
			TMP->CW1_CLVL		:= M->CW1_CLVL
			TMP->CW1_FORMUL		:= M->CW1_FORMUL
			
		ENDIF
	NEXT nX
	
	oGetDb:lNewLine := .F.
	oGetDb:Refresh()

ENDIF

RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTB276ReCalcº Autor ³ Gustavo Henrique º Data ³  21/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza os fatores e os percentuais do grupo a partir dos  º±±
±±º          ³ retornos das formulas.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB276ReCalc()

Local nRecno 	:= TMP->( Recno() )
Local xResult
Local bBlock
Local lUsaForm 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a variavel totalizadora do fator                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotFat:= 0

TMP->( dbGoTop() )

IF ExistBlock( "CT276RFA" )
	ExecBlock( "CT276RFA" ,.F.,.F.,{"TMP"})
Endif

Do While TMP->( ! EoF() )
	IF !TMP->CW1_FLAG
		IF !Empty(TMP->CW1_FORMUL)
			
			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &(TMP->CW1_FORMUL)
			RECOVER
				xResult := ""
			END SEQUENCE
			ErrorBlock(bBlock)
			
			IF ValType(xResult) == "N"
				TMP->CW1_FATOR := xResult
		 		lUsaForm := .T.
		 	ENDIF

		ENDIF	
		nTotFat	+= TMP->CW1_FATOR
	ENDIF
	TMP->( dbSkip() )
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a atualizacao dos percentuais devido alteracao no fator ³
//³ somente se o grupo de rateios utilizar formula.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lUsaForm
	CTB276AtuPer()
ENDIF
                                
TMP->( dbGoTo( nRecno ) )

IF ExistBlock( "CT276RFB" )
	ExecBlock( "CT276RFB" ,.F.,.F.,{"TMP"})
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTB276Atf³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os percentuais e os fatores com base nas formulas ³±±
±±³          ³ dos cadastros de grupos de rateios.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA276                    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB276Atf()

IF Pergunte("CTB276",.T.)
	MsgRun(STR0047,STR0048, {|| CTB276AtfPrc()}) //"Recalculando fatores com base nas fÓrmulas..."#"Atualizando grupos de rateios"
ENDIF

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTB276AtfPrc³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento da atualizacao dos percentuais e dos fatores   ³±±
±±³          ³ com base nas formulas                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA276                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Static Function CTB276AtfPrc()

Local aArea			:= GetArea()
Local cFilCW1 		:= xFilial("CW1")
Local cFilCW2		:= xFilial("CW2")
Local cAliasCW1		:= "CW1"
Local cCw1_Codigo	:= ""
Local cCw1_Entidade := ""
Local cCw1_Tipo		:= ""
Local lUsaForm		:= .F.
Local aParam		:= {}
Local bBlock
Local xResult

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa o filtro do CW1 para o processamento devido as funcoes ³
//³ vinculadas em outros fontes (CTBA277)						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAliasCW1)
DbSetOrder(1)
DbClearFilter()  
DbGoTop()

(cAliasCW1)->(DbSeek(cFilCW1+MV_PAR01,.T.))
While (cAliasCW1)->(!EOF()) .AND. 	(cAliasCW1)->CW1_FILIAL == cFilCW1 .AND.;
									(cAliasCW1)->CW1_CODIGO <= MV_PAR02
	
	IF ExistBlock( "CT276RFA" )
		ExecBlock( "CT276RFA" ,.F.,.F.,{cAliasCW1})
	Endif
	
	lUsaForm 		:= .F.
	cCw1_Codigo		:= (cAliasCW1)->CW1_CODIGO
	cCw1_Entidade   := (cAliasCW1)->CW1_ENTID
	cCw1_Tipo		:= (cAliasCW1)->CW1_TIPO

	BEGIN TRANSACTION
	Do While (cAliasCW1)->(!EOF()) .AND. 	(cAliasCW1)->CW1_FILIAL == cFilCW1 .AND.;
											(cAliasCW1)->CW1_CODIGO == cCw1_Codigo
	
		IF !Empty((cAliasCW1)->CW1_FORMUL)
		
			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &((cAliasCW1)->CW1_FORMUL)
			RECOVER
				xResult := ""
			END SEQUENCE
			ErrorBlock(bBlock)

			IF ValType(xResult) == "N"		
				RecLock(cAliasCW1,.F.)
				(cAliasCW1)->CW1_FATOR := xResult
				MsUnlock()
				lUsaForm := .T.
			ENDIF
		
		ENDIF
		
		(cAliasCW1)->( dbSkip() )
		
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a atualizacao dos percentuais devido alteracao no fator ³
	//³ somente se o grupo de rateios utilizar formula.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lUsaForm
		IF CTB276Cw1Per(cFilCW1, cAliasCW1, cCw1_Codigo)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa a atualizacao dos cadastros de rateios vinculado ao     ³
			//³ grupo atualizado, através do vinculo com a amarração            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			CTB276Amarra(cFilCW1,cFilCW2,cCw1_Codigo,cCw1_Tipo,cCw1_Entidade,.F.,.T.,MV_PAR03==1)
	    ENDIF
	ENDIF

	END TRANSACTION
	
	IF ExistBlock( "CT276RFB" )
		ExecBlock( "CT276RFB" ,.F.,.F.,{cAliasCW1})
	Endif

END

RestArea(aArea)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB276Cw1Perº Autor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o cadastro de Grupos, refazendo os percentuais        º±±
±±º          ³ com base nos fatores informados para cada linha.               º±±
±±º          ³ Chamada externamente para recomposicao devido a uma atualizacaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA276                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB276Cw1Per(cFilCW1, cAliasCW1, cCw1_Codigo)

Local aArea 	:= GetArea()
Local nTotPerc	:= 0
Local nDifPerc	:= 0
Local nTotFat	:= 0
Local aDados	:= {} 
Local aTamPerc	:= TAMSX3("CW1_PERCEN")
Local lRet		:= .T.
Local nX		:= 0
Local cCW1SEQ	:= Replicate("0",TAMSX3("CW1_SEQUEN")[1])

// PREPARA DADOS PARA ATUALIZACAO DO PERCENTUAL PELO FATOR
DbSelectArea(cAliasCW1)
DbSetOrder(1)
DbSeek(cFilCW1+cCw1_Codigo)
While (cAliasCW1)->(!Eof()) .AND. (cAliasCW1)->(CW1_FILIAL+CW1_CODIGO) == cFilCW1+cCw1_Codigo
    
	cCW1SEQ := SOMA1(cCW1SEQ)
	AADD(aDados,{cCW1SEQ, (cAliasCW1)->CW1_FATOR, 0, (cAliasCW1)->(Recno()) }) // 3- Novo percentual
	nTotFat += (cAliasCW1)->CW1_FATOR
	(cAliasCW1)->(DbSkip())

End

// COMPOE PERCENTUAIS COM BASE NA RELACAO DO FATOR DA LINHA COM O TOTAL DO FATOR DO GRUPO
For nX := 1 to Len(aDados)
	aDados[nX][3] := Round(NoRound((aDados[nX][2]/nTotFat)*100,aTamPerc[2]+1),aTamPerc[2])
	nTotPerc += aDados[nX][3]
Next nX

// AJUSTA O PERCENTUAL PARA 100% CASO HAJA DIFERENCA
// REALIZA O AJUSTE SEMPRE NA ULTIMA LINHA CUJO O PERCENTUAL SUPORTE A DIFERENCA
IF nTotPerc <> 100
	nDifPerc := 100 - nTotPerc
	FOR nX := Len(aDados) TO 1 STEP -1
		IF aDados[nX][3] > ABS(nDifPerc)
			aDados[nX][3] += nDifPerc
			nTotPerc += nDifPerc
			EXIT
		ENDIF
	NEXT nX
ENDIF

For nX := 1 to Len(aDados)
	(cAliasCW1)->(dbGoto(aDados[nX][4]))
	RECLOCK(cAliasCW1,.F.)
	(cAliasCW1)->CW1_SEQUEN := aDados[nX][1] 	// Renumera a sequencia, caso hajam itens excluidos
	(cAliasCW1)->CW1_PERCEN := aDados[nX][3]
	(cAliasCW1)->CW1_STATUS := IIF(nTotPerc <> 100,"2","1")
	MSUNLOCK()
Next nX

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ --------------------- ³ Data ³ -------- ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

LOCAL aRotina 	:= {}
LOCAL aCTB276BUT:= {}
LOCAL nX		:= 0

AADD(aRotina, {STR0001	,"CTB276Pes", 0, 1})//	"Pesquisar"
AADD(aRotina, {STR0002	,"CTB276Cad", 0, 2})//	"Visualizar"
AADD(aRotina, {STR0003	,"CTB276Cad", 0, 3})//	"Incluir"
AADD(aRotina, {STR0004	,"CTB276Cad", 0, 4})//	"Alterar"
AADD(aRotina, {STR0005	,"CTB276Cad", 0, 5})//	"Excluir"
AADD(aRotina, {STR0051	,"CTB276Atf", 0, 4})//	"Atualizar"
AADD(aRotina, {STR0052	,"CTB276Leg", 0, 2})//	"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA PARA ADICAO DE ITENS NO AROTINA                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("CTB276BUT")
	aCTB276BUT := ExecBlock("CTB276BUT",.F.,.F.,aRotina)
	
	IF ValType(aCTB276BUT) == "A" .AND. Len(aCTB276BUT) > 0
		FOR nX := 1 to len(aCTB276BUT)
			aAdd(aRotina,aCTB276BUT[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc}CT276VLCl
Valida se a classe contábil esta bloqueada (tanto campo quanto data)
@author Kássia Caregnatto
@since  26/06/2017
@version 12
/*/
//-------------------------------------------------------------------
Function CT276VLCl()

Local lOk		:= .T.
Local lBloq	:= .T.
Local cMsg		:= ""
Local cEnti	:= cCw1_Entidade
Local cId		:= M->CW1_CLVL
Local cBloq	:= ''
Local dDate	:= ''

dbSelectArea("CTH")
dbSetOrder( 1 )
dbSeek( xFilial("CTH") + cId)

cBloq	:= CTH->CTH_BLOQ
dDate	:= CTH->CTH_DTEXSF

If Empty(CTH->CTH_DTEXSF)
	lBloq	:= .F.
Else
	If dDate <= dDataBase
		lBloq	:= .T.
	Else
		lBloq	:= .F.
	Endif
Endif
 
If cEnti == '4'

	If cBloq == '1' .OR.  lBloq
		MsgInfo (STR0076) //"Classe de Valor Bloqueada"
		lOk	:= .F.
	Endif
	
Endif

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc}ValidaPercent
Valida o percentual de rateio caso o total seja diferente de 100%,
possibilitando a chamada do ponto de entrada CTB276CW1, para permitir
definir se a conta será gravada bloqueada ou liberada, mesmo que o percentual
seja diferente de 100%.
Para gravar a conta liberada, deverá retornar .T.
@author Jeferson Couto
@since  05/10/2021
@version 12
@params
	cTpVld			=> Tipo de Validação (L = Linha, T = Total)
	cCw1_Tipo		=> Tipo do Grupo de Rateio (1 = Origem, 2 = Destino)
	cCw1_Entidade	=> Entidade Contabil (1 = Conta Contabil, 2 = Centro de Custo, 3 = Item Contabil, 4 = Classe Valor, 5 = Combinado)
	nTotRat			=> Percentual total do rateio
	nLinRat			=> Percentual da Linha digitada (quando cTpVld = T, este parametro será nil)
/*/
//-------------------------------------------------------------------
Static Function ValidaPercent(cTpVld, cCw1_Tipo, cCw1_Entidade, nTotRat, nLinRat)

Local lCTB276CW1
Local lRet := .F.

If ExistBlock("CTB276CW1")
	lCTB276CW1 := ExecBlock("CTB276CW1",.F.,.F.,{cTpVld, cCw1_Tipo, cCw1_Entidade, nTotRat, nLinRat})
	If ValType(lCTB276CW1) == "L"
		lRet := lCTB276CW1
	Endif
Endif

Return lRet
