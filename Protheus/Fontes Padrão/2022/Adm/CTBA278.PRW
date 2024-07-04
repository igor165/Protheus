#include "ctba278.ch"
#include "protheus.ch"

Static __cCW3ENTF3	:= ""
Static _oCtba278

// 17/08/2009 -- Filial com mais de 2 caracteres

//AMARRACAO PARA BOLETIM TECNICO - FNC: 00000005765-2008-912
//AMARRACAO PARA BOLETIM TECNICO - FNC: 00000029121-2010
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ctba278 ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastramento de Indices Estatisticos para Grupos de Rateios³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB - Manutenção de Rateios Off-Line                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba278(xAutoCab,xAutoItens,nOpcAuto)

Local cFilPad	:= ""
Local cAlias	:= "CW3"
Local aCores	:= {}

Private aRotina := MenuDef()
Private lCTQ_MSBLQL	:= IIF(CTQ->(FieldPos("CTQ_MSBLQL")) > 0,.T.,.F.)
Private lCTQ_STATUS  := IIF(CTQ->(FieldPos("CTQ_STATUS")) > 0,.T.,.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para rotina automatica    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

Private lCtb278Auto 	:= ( ValType(xAutoCab) == "A" .And. ValType(xAutoItens) == "A" )
Private aAutoCab   	:= {}
Private aAutoItens 	:= {}
Private lRpc       	:= Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela
Private cCadastro  	:= STR0006 						// "Grupos de Rateios"
Private aIndexFil	:= {}
Private bFiltraBrw:= {|| Nil}

If (!AMIIn(34)) .And. (!lCtb278Auto)				// Acesso somente pelo SIGACTB ou Rotina automatica
	Return
EndIf

If !lCTQ_STATUS
	ShowHelpDlg("CTQSTATUS", {STR0046,STR0047},5,{STR0048,STR0049},5)   //"O campo CTQ_STATUS não está disponível "##"no dicionário de dados."##"Executar o compatibilizador UPDCTB com "##"data igual ou superior a 28/07/2008"
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFilPad := "CW3_FILIAL = '"+xFilial("CW3")+"'"+" AND CW3_SEQUEN = '"+StrZero(1,TamSx3("CW3_SEQUEN")[1])+"'"

If lCtb278Auto
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"CW3")
Else
	mBrowse( 6,1,22,75,"CW3",,,,,,,,,,,,,,cFilPad)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("CW3")
CW3->( dbSetOrder(1) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o filtro MBROWSE                              		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb278PES³ Autor ³ Claudio D. de Souza   ³ Data ³ 01/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB278PES()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA278                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb278Pes()
AxPesqui()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ Ctb278Cad ³ Autor ³ Eduardo Nunes Cirqueira ³ Data ³ 19/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Programa de inclusao de Grupos de Rateios                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb278Cad(cAlias,nReg,nOpcx)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias = Alias do arquivo                                     ³±±
±±³          ³ nReg   = Numero do registro                                   ³±±
±±³          ³ nOpcx  = Opcao selecionada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba278                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb278Cad(cAlias,nReg,nOpcx)

Local oDlg
Local nOpcA
Local oGet
Local cArqTmp
Local oFnt

Local aArea      := CW3->(GetArea())
Local aDados     := {}
Local aAltera    := {}
Local aGetDB     := {}		// Campos da GetDados

Local nOpcGDB    := nOpcX	// Variavel para carregar a GetDB
Local nOpcao     := If(nOpcX == 3, 4, nOpcX)

Local lCusto     := CtbMovSaldo("CTT")
Local lItem      := CtbMovSaldo("CTD")
Local lClVl      := CtbMovSaldo("CTH")
Local lDigita    := (nOpcx == 3 .or. nOpcx == 4)		// LÓGICO - INDICA QUANDO OS CAMPOS PODEM SER EDITADOS (INCLUSAO OU ALTERACAO)
Local oSize
Local nLinIni	:= 0
Local nColIni	:= 0
Local nLinEnd	:= 0
Local nColEnd	:= 0
Local cAliasTmp  := ""
Local aButtons	 := {} 		//Aadd(aButtons,{"USER", {|| Rotina()}, "Texto"})

Private aHeader  := {}
Private oTotFat
Private nTotFat  := 0
Private cPictVal := PesqPict("CT2","CT2_VALOR")

Private cCw3_Codigo
Private cCw3_Desc
Private	cCw3_Entidade
Private aCw3_Entid 		:= CtbCbox("CW3_ENTID","",TamSx3("CW3_ENTID")[1])

// Botao para preenchimento do aCols com base no Cadastro de Entidade selecionado
AADD(aButtons,{"NCO", {|| IIF(nOpcao==4,Ctb278Entid(oGet),.T.)}	, STR0050})   //"Entidade"

// Botao para atualizacao do aCols com base nas formulas
AAdd(aButtons,{"FORM",{|| IIF(nOpcao==4,Ctb278Recalc(),.T.) }		, STR0051,	STR0052})  //'Recalculo formulas'##'Rec. Form.'

(cAlias)->(DbClearFil())
RestArea(aArea)

aGetDB 		:= {	"CW3_SEQUEN","CW3_CODENT","CW3_UM","CW3_FATOR","CW3_FORMUL" }
cAliasTmp 	:= "TMP"

If nOpcX == 3 // Inclusao
	cCw3_Codigo 	:= CriaVar("CW3_CODIGO")
	cCw3_Desc   	:= CriaVar("CW3_DESCRI")
	cCw3_Entidade  	:= CriaVar("CW3_ENTID")
Else
	cCw3_Codigo 	:= CW3->CW3_CODIGO
	cCw3_Desc   	:= CW3->CW3_DESCRI
	cCw3_Entidade  	:= CW3->CW3_ENTID
Endif

Ctb278aHeader(cAlias,aGetDb,aAltera)
Ctb278CriaTmp(cAlias, cAliasTmp)	// Cria Arquivo temporario
Ctb278Carr(nOpcX)								// Carrega dados no temporario

If !lCtb278Auto
	DEFINE FONT oFnt	NAME "Arial" Size 10,15

	DbSelectArea(cAlias)
	DEFINE MSDIALOG oDlg TITLE STR0006 From 0,0 To 463,702 PIXEL OF oMainWnd //"Indices Estatisticos"

	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "CABECALHO",  100, 20, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "GETDADOS" ,  100, 60, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "RODAPE" ,  100, 20, .T., .T. ) // Totalmente dimensionavel

	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() 	   // Dispara os calculos

	nLinIni := oSize:GetDimension("CABECALHO","LININI")
	nColIni := oSize:GetDimension("CABECALHO","COLINI")

	@ nLinIni+13,   nColIni+4 TO 39, 349		OF oDlg PIXEL
	@ nLinIni+23,   nColIni+9 SAY STR0007		OF oDlg PIXEL	//	"Cod Indice"
	@ nLinIni+21,  nColIni+47 MSGET cCw3_Codigo OF oDlg SIZE 30, 9 PIXEL PICTURE PesqPict("CW3","CW3_CODIGO");
												   When nOpcX == 3 ;
												   Valid Ctb278Valid("CW3_CODIGO",cCw3_Codigo) .and. FreeForUse("CW3",cCw3_Codigo)
	@ nLinIni+23, nColIni+100 SAY STR0008		OF oDlg PIXEL	//	"Descrição"
	@ nLinIni+21, nColIni+135 MSGET cCw3_Desc   OF oDlg SIZE 80, 9 PIXEL PICTURE PesqPict("CW3","CW3_DESC");
	 											   When nOpcX == 3 .Or. nOpcX == 4 ;
	 											   Valid Ctb278Valid("CW3_DESC",cCw3_Desc)
	@ nLinIni+23, nColIni+242 SAY STR0009		OF oDlg PIXEL	//	"Entidade"
	@ nLinIni+21, nColIni+272 MSCOMBOBOX cCw3_Entidade ITEMS aCw3_Entid OF oDlg PIXEL SIZE 60,9  ;
													When nOpcX == 3 ;
													Valid Ctb278VerEnt(cCw3_Entidade)

	nLinIni := oSize:GetDimension("RODAPE","LININI")
	nColIni := oSize:GetDimension("RODAPE","COLINI")
	nLinEnd := oSize:GetDimension("RODAPE","LINEND")
	nColEnd := oSize:GetDimension("RODAPE","COLEND")

	@ nLinIni,  nColIni+4 TO  nLinEnd,nColEnd 								 OF oDlg PIXEL
	@ nLinIni+10,  nColIni+7 SAY STR0010 								 OF oDlg PIXEL	//	"Total Fator"
	@ nLinIni+10, 	nColIni+47 SAY oTotFat VAR nTotFat PICTURE PesqPict("CW3","CW3_FATOR")	 OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE

	nLinIni := oSize:GetDimension("GETDADOS","LININI")
	nColIni := oSize:GetDimension("GETDADOS","COLINI")
	nLinEnd := oSize:GetDimension("GETDADOS","LINEND")
	nColEnd := oSize:GetDimension("GETDADOS","COLEND")

	oGet := MSGetDb():New(nLinIni,nColIni,nLinEnd,nColEnd,nOpcao,"Ctb278LOk", "Ctb278TOk", "+CW3_SEQUEN",.T.,aAltera,,.T.,,cAliasTmp,,,,,,, "Ctb278Del")

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
			{||nOpca:=1,If(Ctb278TOK(nOpcX,cCw3_Codigo),oDlg:End(),nOpca := 0)},;
			{||nOpca:=2,oDlg:End()},,aButtons) VALID nOpca != 0
Else
	lOk	:= MsGetDBAuto(	"TMP",;
						aAutoItens,;
						"Ctb278LOK",;
						{ || Ctb278TOk(nOpcX,cCw3_Codigo) },;
						aAutoCab,;
						nOpcGDB )

	nOpcA := If( lOk,1,0 )
EndIf

If nOpcA == 1 .and. nOpcX <> 2
	Begin Transaction
		If !lCtb278Auto
			AADD(aDados,{"CW3_CODIGO",cCw3_Codigo})
			AADD(aDados,{"CW3_DESCRI",cCw3_Desc  })
			AADD(aDados,{"CW3_ENTID" ,cCw3_Entidade  })
		Else
			// Se estiver executando rotina automatica e NAO FOR Exclusao,
			// alimentar "aDados" com todos os elementos da matriz recebida
			If nOpcX <> 5
				AADD(aDados,{"CW3_CODIGO",aAutoCab[01,02]})
				AADD(aDados,{"CW3_DESCRI",aAutoCab[02,02]})
				AADD(aDados,{"CW3_ENTID" ,aAutoCab[03,02]})
			Else
				// Se estiver executando rotina automatica e FOR Exclusao,
				// alimentar "aDados" apenas com o codigo do grupo de rateio,
				// que eh o primeiro elemento da matriz recebida
				aDados := {	{"CW3_CODIGO",aAutoCab[01,02]} }
				AADD(aDados,{"CW3_ENTID" ,aAutoCab[03,02]})
			EndIf
		EndIf
		Ctb278Grava(cAlias,aDados,nOpcX)
	End Transaction
EndIf

RetIndex("CW3")

DbSelectArea(cAliasTmp)
dbCloseArea()

If _oCtba278 <> Nil
	_oCtba278:Delete()
	_oCtba278 := Nil
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
±±³Fun‡…o    ³Ctb278aHea³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepar aHeader para GetDb                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba278                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb278aHeader(cAlias,aGetDb,aAltera)
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
					 	If(x3_campo="CW3_FATOR","Ctb278Fator(.T.)",x3_valid),;
					 	x3_usado,;
					 	x3_tipo,;
					 	"TMP",;
					 	x3_context } )

		If Alltrim(x3_campo) <> "CW3_SEQUEN"
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
±±³Fun‡…o    ³Ctb278Grav³ Autor ³ Claudio D. de Souza   ³ Data ³ 18.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as informacoes do indice                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba278                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb278Grava(cAlias,aDados,nOpcX)

Local aArea			:= GetArea()
Local aOrder		:= {2,3,4,5}

Local nAscan, nX	:= 0
Local nCont			:= 0

Local cCw3_Codigo	:= ""
Local cCw3_Entidade	:= ""
Local cMsg			:= ""

Local lDelSEQ1		:= .F.
Local lInclui		:= .T.
Local aDadosCW3		:= {}
Local aDelCW3		:= {}
Local nCountSeq		:= 0

cCw3_Codigo 	:= aDados[Ascan(aDados,{|e| e[1] = "CW3_CODIGO" } )][2]	 // Obtem o codigo do indice
cCw3_Entidade 	:= aDados[Ascan(aDados,{|e| e[1] = "CW3_ENTID"  } )][2]		// Obtem a entidade

(cAlias)->(dbSetOrder(1))

If nOpcX == 5	//	Se for Exclusao

	If (cAlias)->(MsSeek(xFilial(cAlias)+cCw3_Codigo))
		While (cAlias)->(!Eof() .And. FWxFilial(cAlias) == CW3->CW3_FILIAL .And. CW3->CW3_CODIGO == cCw3_Codigo)

			AADD(aDelCW3,{(cAlias)->CW3_ENTID, (cAlias)->CW3_CODENT, 0, 0})
			RecLock(cAlias,.F.,.T.)
			(cAlias)->(dbDelete())
			(cAlias)->(dbSkip())

		EndDo
	EndIf

	If !(IsBlind())
		IF MsgYesNo(STR0023+CRLF+STR0024+CRLF+STR0025+CRLF+STR0026) //"Deseja excluir as entidades removidas deste indice estatístico "#"de todos os grupos de rateios e de todos os rateios vinculados "#"nesta operacao? "#"ATENÇÃO: Esta ação não pode ser desfeita."
			Ctb278Amarra(cCw3_Codigo,cCw3_Entidade,.T.,aDelCW3)
		ENDIF
	EndIf
Else

    // Se for Inclusao em rotina automatica, verificar se o indice ja existe. Se existir,
    // nao deixar incluir e abandonar a rotina.
	If lCtb278Auto .AND. nOpcX == 03
		If (cAlias)->(MsSeek(xFilial(cAlias)+cCw3_Codigo))
			lInclui := .F.
		EndIf
	EndIf

	If lInclui

		TMP->(dbGoTop())
		While TMP->(!Eof())
			(cAlias)->(dbSetOrder(1))
			If TMP->CW3_FLAG  //  Se a linha estiver excluida
				If nOpcX == 3  //  Se for Inclusao
					If TMP->CW3_SEQUEN == StrZero(1,LEN(TMP->CW3_SEQUEN)) // Se excluiu a primeira linha
						lDelSEQ1 := .T.
					Endif
				Else
					If (cAlias)->(dbSeek(xFilial(cAlias)+cCw3_Codigo+TMP->CW3_SEQUEN))
						If TMP->CW3_SEQUEN == StrZero(1,LEN(TMP->CW3_SEQUEN))
							lDelSEQ1 := .T.
						Endif

						Reclock(cAlias,.F.,.T.)
						(cAlias)->(dbDelete())
						(cAlias)->(MsUnlock())

						AADD(aDelCW3,{TMP->CW3_ENTID, TMP->CW3_CODENT, 0, 0})

					EndIf
				EndIf
			Else

				If ! (cAlias)->(dbSeek(xFilial(cAlias)+cCw3_Codigo+TMP->CW3_SEQUEN))
					RecLock(cAlias,.T.)
				Else
					RecLock(cAlias,.F.)
				EndIf

				For nX := 1 To (cAlias)->(fCount())
					cNomeCpo := (cAlias)->(FieldName(nx))
					If cNomeCpo == "CW3_FILIAL"
						(cAlias)->CW3_FILIAL := xFilial("CW3")
					ElseIf lDelSEQ1 .and. cNomeCpo == "CW3_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA AS DEMAIS SEQUENCIAS
						nCountSeq++
						(cAlias)->CW3_SEQUEN := StrZero(nCountSeq,LEN(TMP->CW3_SEQUEN))
					Else
						// Pesquisa o campo atual em aHeader
						nAscan := Ascan(aHeader,{|e| Upper(AllTrim(e[2])) == Upper(AllTrim((cAlias)->(FieldName(nX))))})
						If nAscan > 0 .And. (cAlias)->(FieldPos(TMP->(FieldName(nX)))) > 0
							(cAlias)->(FieldPut(nX,TMP->(FieldGet(nX)))) // CW3 e TMP tem a mesma estrutura
						Else
							nAscan := Ascan(aDados, {|e| e[1] == (cAlias)->(FieldName(nX))})
							If nAscan > 0
								(cAlias)->(FieldPut(nX,aDados[nAscan][2]))
							Endif
						Endif
					Endif
				Next

				AADD(aDadosCW3,{TMP->CW3_ENTID, TMP->CW3_CODENT, TMP->CW3_FATOR})

				(cAlias)->(MsUnlock())
			EndIf
			TMP->(dbSkip())
		EndDo
	EndIf

	// Atualizando os Grupos de Rateio que contem este Indice Estatistico
	If nOpcx == 4 	//	Alteracao
			Ctb278Amarra(cCw3_Codigo,cCw3_Entidade,.F.,aDadosCW3)
			If !(IsBlind())
				IF Len(aDelCW3) > 0 .AND. MsgYesNo(STR0027+CRLF+STR0028+CRLF+STR0029+CRLF+STR0026) //"Deseja excluir de todos os grupos de rateios e de  "#"todos os rateios vinculados a este indice as entidades "#"removidas nesta operacao? "#"ATENÇÃO: Esta ação não pode ser desfeita."
					Ctb278Amarra(cCw3_Codigo,cCw3_Entidade,.T.,aDelCW3)
				ENDIF
			EndIf
	ENDIF

ENDIF

RestArea(aArea)
Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb278Cria³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara arquivo temporario para GetDb a partir do CW3      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba278                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb278CriaTmp(cAlias,cAliasTmp)
Local aArea	:= GetArea()
Local aStru := (cAlias)->(DbStruct())

aadd(aStru,{"CW3_FLAG","L",01,0})

If _oCtba278 <> Nil
	_oCtba278:Delete()
	_oCtba278 := Nil
Endif

_oCtba278 := FWTemporaryTable():New( cAliasTmp )
_oCtba278:SetFields(aStru)
_oCtba278:AddIndex("1", {"CW3_FILIAL","CW3_CODIGO"})

//------------------
//Criação da tabela temporaria
//------------------
_oCtba278:Create()

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb278Carr³ Autor ³ Claudio D. de Souza   ³ Data ³ 19.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega dados para GetDB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb278Carr(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA278                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                  					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb278Carr(nOpc)
Local aSaveArea := GetArea()
Local nPos
Local nCont
Local cAliasTmp	:= "TMP"
Local cGrupo

If nOpc != 3						// Visualizacao / Alteracao / Exclusao
	cGrupo := CW3->CW3_CODIGO
	dbSelectArea("CW3")
	dbSetOrder(1)
	If dbSeek(xFilial()+cGrupo)
		nTotFat := 0
		While !Eof() .And. (CW3->(CW3_FILIAL + CW3_CODIGO)) == (xFilial("CW3") + cGrupo)
			dbSelectArea(cAliasTmp)
			dbAppend()
			For nCont := 1 To Len(aHeader)
				nPos := FieldPos(aHeader[nCont][2])
				If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
					FieldPut(nPos,CW3->(FieldGet(FieldPos(aHeader[nCont][2]))))
				EndIf
			Next
			nTotFat += (cAliasTmp)->CW3_FATOR
			dbSelectArea("CW3")
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
	(cAliasTmp)->CW3_SEQUEN := "001"
EndIf

dbSelectArea(cAliasTmp)
dbGoTop()

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb278TOK ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao completa da GetDb e dados do cabeçalho           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb278TOK(nOpcX)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA278                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcX = Opcao selecionada             					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb278TOk(nOpcX)

LOCAL lRet    	:= .T.
LOCAL nRecno  	:= TMP->(Recno())
LOCAL lFatZero 	:= GETMV("MV_CTQFTZR",.F.,.T.)  // PERMITE FATOR ZERADO QUANDO USA FORMULA
Local nSomaAux  := 0
Local aSize 	:= TamSX3("CW3_FATOR")
Local nVlMax 	:= val(repl('9',aSize[1]-IIf(aSize[2]>0,aSize[2]+1,0)))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos campos obrigatorios do cabecalho                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCtb278Auto
	IF 	Empty(cCw3_Codigo) 	.OR.;
		Empty(cCw3_Desc)	.OR.;
		Empty(cCw3_Entidade)
		Help("",1,"OBRIGCAMPO") // CAMPOS OBRIGATORIOS NÃO PREENCHIDOS
		lRet := .F.
	ENDIF
Else
	IF 	Empty(aAutoCab[01,02]) 	.OR.;
		Empty(aAutoCab[02,02])	.OR.;
		Empty(aAutoCab[03,02])
		Help("",1,"OBRIGCAMPO") // CAMPOS OBRIGATORIOS NÃO PREENCHIDOS
		lRet := .F.
	ENDIF
Endif

IF lRet
	dbSelectArea("TMP")
	dbGotop()
	While ! Eof()
		IF !(TMP->CW3_FLAG)
			IF lFatZero .AND. Empty(TMP->CW3_FATOR) .AND. Empty(TMP->CW3_FORMUL)
				IF ! lRpc
					Help("CTBA278",1,"HELP","CW3TFATOR",STR0016+CRLF+STR0017,1,0) //"Obrigatório informar os fatores "#"para as linhas."
				ENDIF
				lRet := .F.
			ELSEIF !lFatZero .AND. Empty(TMP->CW3_FATOR)
				IF ! lRpc
					Help("CTBA278",1,"HELP","CW3TFATOR",STR0016+CRLF+STR0017,1,0) //"Obrigatório informar os fatores "#"para as linhas."
				ENDIF
				lRet := .F.
			ENDIF
		ENDIF
		DbSkip()
	EndDo
ENDIF

IF lRet .And. (nOpcX == 3 .Or. nOpcX == 4)
    TMP->( DbGoTop() )
    While ! TMP->(EOF())
    	IF !TMP->CW3_FLAG
	    	IF Empty(TMP->CW3_CODENT)
				Help("CTBA278",1,"HELP","CW3TCODENT",STR0013,1,0) //"Campo Cod. Entidade nao pode ficar em branco"
				lRet := .F.
				Exit
			ENDIF
			// Validacao para avaliar se existem outras linhas com as mesmas entidades contabeis
			IF  !CT278VLDENT(TMP->CW3_CODENT)
				Help("",1,"EXISTCHAV") // Esta chave já existe
				lRet := .F.
				Exit
			ENDIF
			nSomaAux += TMP->CW3_FATOR
		ENDIF
		TMP->( DbSkip() )
	EndDo
ENDIF

If lRet .And. Int(nSomaAux) > nVlMax
	lRet := .F.
	Help("CTBA278",1,"HELP","CW3MAXFATOR",STR0053 ,1,0) //"Fator inválido. A soma dos fatores implicará em valor fora da faixa de representação numérica."
EndIf

TMP->(MsGoTo(nRecno))
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA278Delº Autor ³ ------------------ º Data ³  04/19/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Na exclusão de uma linha do grupo de rateio, atualiza o    º±±
±±º          ³ valor no rodape.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb278Del()
Local lRet := .T.

If TMP->CW3_FLAG
	lRet := CT278VlFat(TMP->CW3_FATOR,.T.)
	If lRet
		nTotFat += TMP->CW3_FATOR
	EndIf
Else
	nTotFat -= TMP->CW3_FATOR
Endif
oTotFat:Refresh()

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb278Validº Autor ³ ------------------ º Data ³  02/08/07     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar a digitacao do codigo e descricao do grupo de rateio   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb278Valid(cCampo,xConteudo)
Local lRet  := .T., aArea := GetArea()

If Empty(xConteudo)
	lRet := .f.
	Help(" ",1,"VAZIO")
Else
	If cCampo = "CW3_CODIGO"
		DbSelectArea("CW3")
		dbSetOrder(1)
		If CW3->(MsSeek(xFilial("CW3")+xConteudo))
			lRet := .F.
			Help(" ",1,"JAEXISTINF")
		Endif
	EndIf
Endif
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb278LOk ºAutor  ³Marcos S. Lobo      º Data ³  02/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validação de linha da tela de cadastro de Indices  º±±
±±º          ³Estatisticos para Grupos de Rateio.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb278LOk()

LOCAL lRet	 		:= .T.
LOCAL cEntid 		:= ""
LOCAL lFatZero 		:= GETMV("MV_CTQFTZR",.F.,.T.)  // PERMITE FATOR ZERADO QUANDO USA FORMULA
LOCAL aCW3_CadEntid := { "CT1", "CTT", "CTD", "CTH" }

If !TMP->CW3_FLAG			/// SE NÃO ESTIVER DELETADO

	If lFatZero .AND. Empty(TMP->CW3_FATOR) .AND. Empty(TMP->CW3_FORMUL)
		If ! lRpc
			Help("CTBA278",1,"HELP","CW3LFATOR",STR0018,1,0) // "Obrigatório informar o fator para a linha."
		EndIf
		lRet := .F.
	ElseIf !lFatZero .AND. Empty(TMP->CW3_FATOR)
		If ! lRpc
			Help("CTBA278",1,"HELP","CW3LFATOR",STR0018,1,0) // "Obrigatório informar o fator para a linha."
		EndIf
		lRet := .F.
	Endif

	If lRet .And. Empty(TMP->CW3_CODENT)
		Help("CTBA278",1,"HELP","CW3LCODENT",STR0014,1,0) // "Preencher o codigo da Entidade Contábil"
		lRet := .F.
	EndIf

	If lRet .And. ! Empty(cCw3_Entidade)
		cEntid := aCW3_CadEntid[ Val(cCw3_Entidade) ]
		lRet   := ExistCpo(cEntid,TMP->CW3_CODENT,1)
	EndIf

	// Validacao para avaliar se existem outras linhas com as mesmas entidades contabeis
	If lRet .AND. !CT278VLDENT(TMP->CW3_CODENT)
		Help("",1,"EXISTCHAV") // Esta chave já existe
		lRet := .F.
	Endif

	If lRet
		lRet := CT278LinFat()
	EndIf

Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb278VerEntºAutor  ³ Eduardo Nunes Cirqueira º Data ³ 04/08/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a digitacao da Entidade, exigindo 1-Conta Contabil;     º±±
±±º          ³ 2-Centro Custo; 3-Item Contabil ou 4-Classe Valor              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb278VerEnt(cEntidade)
Local lRet := (cEntidade $ "1234")

If ! lRet
	Help("CTBA278",1,"HELP","CW3ENTIDADE",STR0015,1,0) //	"Entidade incorreta. Informar 1-Conta Contabil; 2-Centro Custo; 3-Item Contabil; 4-Classe Valor"
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT278VLDENT ºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se existe outra linha com a mesma entidade da atual.    º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT278VLDENT(cEntidade)

Local nRecno := TMP->( Recno() )
Local lRet 	:= .T.

TMP->(DbGotop())
While TMP->(!EOF())

	IF !TMP->CW3_FLAG .AND. TMP->(Recno()) != nRecno .AND. TMP->CW3_CODENT	== cEntidade
			lRet := .F.
	ENDIF

	TMP->(DbSkip())
End

TMP->(DbGoto(nRecno))
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB278VLCW3 ºAutor  ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a digitacao do campo CW3_CODENT.                        º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB278VLCW3()
LOCAL lRet 			:= .F.
LOCAL aCW3_CadEntid := { "CT1", "CTT", "CTD", "CTH" }
LOCAL cCw3_CodEnt	:= &(ReadVar())

lRet := ExistCpo(aCW3_CadEntid[ Val(cCw3_Entidade) ],ALLTRIM(cCw3_CodEnt),1)

If cCw3_Entidade = '1'
	DbSelectArea("CT1")
	DbSetOrder(1) //CT1_FILIAL+CT1_CONTA
	DbSeek(xFilial("CT1") + cCw3_CodEnt)
	If CT1->CT1_BLOQ <> '1'
		lRet	:= .T.
	Else
		MsgInfo (STR0055) //"Conta Contábil Bloqueada"
		lRet	:= .F.
	Endif
Endif

If cCw3_Entidade = '2'
	DbSelectArea("CTT")
	DbSetOrder(1) // CTT_FILIAL+CTT_CUSTO
	DbSeek(xFilial("CTT") + cCw3_CodEnt)
	If CTT->CTT_BLOQ <> '1'
		lRet	:= .T.
	Else
		MsgInfo (STR0056) //"Centro de Custo Bloqueado"
		lRet	:= .F.
	Endif
Endif

If cCw3_Entidade = '3'
	DbSelectArea("CTD")
	DbSetOrder(1) //  CTD_FILIAL+CTD_ITEM
	DbSeek(xFilial("CTD") + cCw3_CodEnt)
	If CTD->CTD_BLOQ <> '1'
		lRet	:= .T.
	Else
		MsgInfo (STR0057) //"Item Contábil Bloqueado"
		lRet	:= .F.
	Endif
Endif

If cCw3_Entidade = '4'
	DbSelectArea("CTH")
	DbSetOrder(1) //CTH_FILIAL+CTH_CLVL
	DbSeek(xFilial("CTH") + cCw3_CodEnt)
	If CTH->CTH_BLOQ <> '1'
		lRet	:= .T.
	Else
		MsgInfo (STR0054) //"Classe de Valor Bloqueada"
		lRet	:= .F.
	Endif
Endif



Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ ConPadCW3   º Autor ³ Eduardo Nunes Cirqueira º Data ³ 15/08/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre a tela de pesquisa referente a tabela da entidade           º±±
±±º          ³ selecionada                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indice de Rateio                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ConPadCW3()

Local aEntid := { {"CT1","CT1_CONTA"}, {"CTT","CTT_CUSTO"}, {"CTD","CTD_ITEM"}, {"CTH","CTH_CLVL"} }
Local cEntid
Local cCampo
Local lRet

If ! Empty(cCw3_Entidade)

	cEntid := aEntid[ Val(cCw3_Entidade),1 ]
	cCampo := aEntid[ Val(cCw3_Entidade),2 ]

	ConPad1( ,,,cEntid,,,.F. )
    __cCW3ENTF3 := (cEntid)->&cCampo

EndIf

Return .T.

Function RetPadCW3()
Local  cRet :=""

cRet := __cCW3ENTF3

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb278Fatorº Autor ³ Eduardo Nunes Cirqueira º Data ³ 04/08/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o total dos fatores utilizados no cadastro de indices º±±
±±º          ³ de cada linha do grupo de rateio.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb278Fator(lHelp)

Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaTmp	:= TMP->(GetArea())

Default lHelp := .F.

If !TMP->CW3_FLAG

	If lHelp
		lRet := CT278VlFat()
	EndIf

	If lRet
		TMP->CW3_FATOR := M->CW3_FATOR
		nTotFat := 0
		TMP->(dbGoTop())
		While TMP->(!EOF())
			If !TMP->CW3_FLAG
				nTotFat += TMP->CW3_FATOR
			EndIf
			TMP->(dbSkip())
		EndDo
		oTotFat:Refresh()
	EndIf

EndIf

RestArea(aAreaTmp)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb278Entid º Autor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o aCols do cadastro de tipos de rateios com base nas  º±±
±±º          ³ entidades selecionadas no cadastro contabil vinculado ao       º±±
±±º          ³ tipo do grupo, quando o mesmo nao for combinado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb278Entid(oGetDB)

LOCAL aChave	:= {}
LOCAL aArea		:= GetArea()
LOCAL bCondicao	:= {|| .T.}
LOCAL aAlias	:= {"CT1","CTT","CTD","CTH"}
LOCAL aCposAlias:= {"CT1_CONTA","CTT_CUSTO","CTD_ITEM","CTH_CLVL"}
LOCAL cAlias	:= ""
LOCAL cTitulo	:= ""
LOCAL cFilAlias	:= ""
LOCAL cEntidade := ""

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

IF EMPTY(cCw3_Entidade) .OR. cCw3_Entidade == "5" // Combinado
	Help("CTBA278",1,"HELP","CTB278ENTID",STR0030,1,0) //	"O tipo de entidade selecionada não permite o uso deste recurso"
	RETURN .T.
ELSEIF !MsgYesNo(STR0031+CRLF+STR0032+CRLF+STR0033+CRLF+STR0034) //"Esta rotina ira refazer os dados do grupo de rateio, "#"apagando as informacoes atuais e substituindo-as pela "#"selecao dos itens do indice estatistico."#"Deseja continuar?"
	RETURN .T.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as entidades do intervalo no array da ListBox        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias 		:= aAlias[Val(cCw3_Entidade)]
cFilAlias 	:= xFilial(cAlias)
cTitulo		:= (SX2->(DbSeek(cAlias)),X2NOME())

DO CASE
	CASE  cCw3_Entidade == "1"
		cEntidade := STR0042//"Conta Contabil"
	CASE  cCw3_Entidade == "2"
		cEntidade := STR0043//"Centro de Custo"
	CASE  cCw3_Entidade == "3"
		cEntidade := STR0044//"Item Contabil"
	CASE  cCw3_Entidade == "4"
		cEntidade := STR0045//"Classe de Valor"
ENDCASE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array aChave com os itens que serao exibidos em tela   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CtbChave(cAlias,cFilAlias,aCposAlias,cCw3_Entidade,cFilExpr,@aChave)

IF Len(aChave) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela para selecao dos itens da entidade contabil       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg:= MSDIALOG():New(000,000,300,625, cTitulo,,,,,,,,,.T.)
	oDlg:lEscClose := .F.
	oGroup := TGROUP():New(005,015,125,300,cTitulo,oDlg,,,.T.)

	bClick := {||(AEval(aChave, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))}
	bSetGet:= {|l| IIF(PCount()>0,lQual:=l,lQual)}
	oChkQual:= tCheckBox():New(15,20,STR0041,bSetGet,oDlg,50,10,,bClick,,,,,,.T.) //"Inverte Seleção"

	bDBLClick := {|| (aChave:=CtbTroca(oQual:nAt,aChave),oQual:Refresh())}
	oQual := TwBrowse():New(30,20,273,090,,{"",cEntidade},,oDlg,,,,,bDBLClick,,,,,,,.F.,,.T.,,.F.,,,)
	oQual:SetArray(aChave)
	oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2]}}

	oBtnOK  := SBUTTON():New(134, 210, 01, {|| IIF(CtbMarcaOk(aChave),(lRet := .T.,oDlg:End()),)}, oDlg, .T., , {|| .T.})
	oBtnCan := SBUTTON():New(134, 240, 02, {|| (lRet := .F.,oDlg:End())}		, oDlg, .T., , {|| .T.})
	oBtnFil := SBUTTON():New(134, 270, 17, {|| (	cFilExpr := BuildExpr(cAlias),;
													CtbChave(cAlias,cFilAlias,aCposAlias,cCw3_Entidade,cFilExpr,@aChave),;
													oQual:SetArray(aChave),;
													oQual:bLine := { || {If(aChave[oQual:nAt,1],oOk,oNo),aChave[oQual:nAt,2]}},;
													oQual:Refresh())}	, oDlg, .T., , {|| .T.})

	oDlg:lCentered := .T.
	oDlg:Activate()
ELSE
	HELP(" ",1,"NORECS")
ENDIF

Ctb278AtuTMP(oGetDb,aChave,cCw3_Entidade)

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
Static Function CtbChave(cAlias,cFilAlias,aCposAlias,cEntidade,cFilExpr,aChave)
Local aArea 	:= GetArea()
Local bBlock
Local xResult
Local cFilConPad:= ""
aChave := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aChave    - Contem as entidades que serao exibidas na tela de  |
//| selecao.                                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SXB->(DbSeek(PADR(cAlias,6,"")+"6"+"01")) .AND. !Empty(SXB->XB_CONTEM)
	cFilConPad := ALLTRIM(SXB->XB_CONTEM)
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

Do While (cAlias)->(!Eof()) .AND. (cAlias)->&(cAlias+"_FILIAL") == cFilAlias
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aChave    - Contem as entidades que serao exibidas na tela de  |
	//| selecao.                                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF (cAlias)->&(cAlias+"_CLASSE") == "2" .AND. (cAlias)->&(cFilExpr)// SOMENTE ENTIDADES ANALITICAS
		Aadd(aChave,{.F.,(cAlias)->&(aCposAlias[Val(cEntidade)])})
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
±±ºUso       ³ CTBA278                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbTroca(nIt,aArray)

aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMarcaOkº Autor ³ Arnaldo R. Junior  º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                    º±±
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
	Help("CTBMARCA",1,"HELP","NOMARKITENS",STR0035,1,0) //"Nao existem itens marcados"
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb278AtuTMPº Autor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o aCols com os itens selecionados.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb278AtuTMP(oGetDb,aChave,cTpEntid)

LOCAL nX 	 := 0
LOCAL lItens := .F.
LOCAL cNewSeq:= ""
LOCAL nCount := 0
LOCAL lUsaLinha := .F.

// Inicia a variavel de totalizacao do fator
nTotFat := 0

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

		IF nCount <= oGetDb:nCount
			TMP->CW3_FLAG := .T. // Marca a Linha como excluida
		ELSE
			lUsaLinha := .T.
			Exit
		ENDIF

		cNewSeq := TMP->CW3_SEQUEN
		TMP->(DbSkip())
	END

	nTotFat:= 0
	oTotFat:Refresh()
	oGetDb:Refresh()

	FOR nX := 1 to Len(aChave)
		IF aChave[nX,1]

			IF !lUsaLinha
				oGetDb:AddLine()
			ELSE
				lUsaLinha := .F.
			ENDIF

			M->CW3_ENTID		:= cTpEntid
			M->CW3_CODENT		:= aChave[nX,2]
			M->CW3_FATOR		:= 0
			M->CW3_FORMUL		:= ""

			Ctb278Fator()
			M->CW3_FATOR		:= TMP->CW3_FATOR  // Atualizado pela Ctb278Fator()

			// Atualiza dados do temporario para compatibilizar com as variaveis em memoria
			TMP->CW3_ENTID		:= M->CW3_ENTID
			TMP->CW3_CODENT		:= M->CW3_CODENT
			TMP->CW3_FORMUL		:= M->CW3_FORMUL

		ENDIF
	NEXT nX

	oGetDb:lNewLine := .F.  //Variavel pra proibir a exclusão da primeira linha do aCols apos uso da rotina "Entidade"
	oGetDb:Refresh()

ENDIF

RETURN .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb278ReCalcº Autor ³ Gustavo Henrique º Data ³  21/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza os fatores do indice com base nas formulas informa-º±±
±±º          ³ das.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA278                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb278ReCalc()

Local nRecno := TMP->( Recno() )
Local bBlock
Local xResult

// Inicia a variavel de totalizacao do fator
nTotFat := 0

TMP->( dbGoTop() )

IF ExistBlock( "CT278RFA" )
	ExecBlock( "CT278RFA" ,.F.,.F.,{"TMP"})
Endif

Do While TMP->( ! EoF() )
	IF !TMP->CW3_FLAG
		IF !Empty(TMP->CW3_FORMUL)

			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &(TMP->CW3_FORMUL)
			RECOVER
				xResult := ""
			END SEQUENCE
			ErrorBlock(bBlock)

			IF ValType(xResult) == "N"
				TMP->CW3_FATOR := xResult
			ENDIF

		ENDIF
		nTotFat	+= TMP->CW3_FATOR
	ENDIF
	TMP->( dbSkip() )
EndDo

TMP->( dbGoTo( nRecno ) )

IF ExistBlock( "CT278RFB" )
	ExecBlock( "CT278RFB" ,.F.,.F.,{"TMP"})
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb278Amarra³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza as amarracoes entre os indices, cadastro de grupos, ³±±
±±³          ³ cadastro de amarracoes e rateios                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA278                      								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb278Amarra(cCw3_Codigo,cCw3_Entidade,lExclusao,aDadosAlt,lDireto,lGeraCTQ)

Local aArea			:= GetArea()
Local nX 			:= 0
Local cFilCW1 		:= xFilial("CW1")
Local cFilCW2		:= xFilial("CW2")
Local aGrupoAlt		:= {}
Local aNickCW1		:= {"CW1_CONTA","CW1_CCUSTO","CW1_ITEM","CW1_CLVL"}
Local cNickName		:= ""
Local lRet			:= .F.

Default lDireto		:= .F.
Default lGeraCTQ	:= .F.

cNickName := aNickCW1[Val(cCw3_Entidade)]

DbSelectArea("CW1")
DbOrderNickName(cNickName)

FOR nX := 1 to Len(aDadosAlt)

	IF CW1->( MsSeek(cFilCW1+cCw3_Codigo+aDadosAlt[nX][2]) )

		RecLock("CW1",.F.)
		IF lExclusao
        	CW1->(DbDelete())
		ELSE
			CW1->CW1_FATOR 	:= aDadosAlt[nX][3]
			CW1->( MsUnLock() )
		ENDIF
		MsUnLock()

		IF ( aScan(aGrupoAlt, {|aLinha| aLinha[1] == CW1->CW1_CODIGO} ) ) == 0
			Aadd( aGrupoAlt, {CW1->CW1_CODIGO,CW1->CW1_TIPO,cCw3_Entidade})
		ENDIF

	ENDIF

NEXT nX

IF Len(aGrupoAlt) > 0
	lGeraCTQ := IIF(lDireto,lGeraCTQ,MsgYesNo(STR0038,STR0039)) //"Deseja atualizar os rateios off-line vinculados as amarrações deste índice estatístico?"#"Atualização de Rateios Off-Line"
ENDIF

// Recompoe o percentual do rateio com base nos novos fatores atualizados
// Atualizar as Amarracoes de Rateio que contem os grupos afetados por esta atualizacao
FOR nX := 1 to Len(aGrupoAlt)
	lRet := Ctb276Cw1Per( cFilCW1, "CW1", aGrupoAlt[nX,1])
	IF lRet
		lRet := Ctb276Amarra( cFilCW1, cFilCW2, aGrupoAlt[nX,1], aGrupoAlt[nX,2], aGrupoAlt[nX,3], lExclusao,.T.,lGeraCTQ)
		IF 	!lRet
			Help("CTBA278",1,"HELP","Ctb278Amarra",STR0019+CRLF+STR0020	+aGrupoAlt[nX,1]+STR0021+aGrupoAlt[nX,2],1,0) //"Amarrações do grupo de rateios não atualizadas"#"Grupo: "#" / Tipo: "
		ENDIF
	ELSE
		Help("CTBA278",1,"HELP","Ctb278Amarra",STR0022+	CRLF+STR0020+aGrupoAlt[nX,1]+STR0021+aGrupoAlt[nX,2],1,0) //"Grupo de rateio não atualizado"#"Grupo: "#" / Tipo: "
	ENDIF
NEXT nX

RestArea(aArea)
RETURN Len(aGrupoAlt) > 0

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Ctb278Atf³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os fatores dos indices estatisticos com base      ³±±
±±³          ³ nas formulas.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA278                    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb278Atf()

IF Pergunte("CTB278",.T.)
	MsgRun(STR0036, STR0037, {|| Ctb278AtfPrc()}) // "Recalculando fatores com base nas fÓrmulas..."#"Atualizando indices de rateios"
ENDIF

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb278AtfPrc³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento da atualizacao de fatores com base nas         ³±±
±±³          ³ formulas.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA278                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Ctb278AtfPrc()

Local aArea			:= GetArea()
Local cFilCW3 		:= xFilial("CW3")
Local cAliasCW3		:= "__CW3"
Local cCW3_Codigo	:= ""
Local cCw3_Entidade	:= ""
Local lUsaForm		:= .F.
Local aDadosCW3		:= {}
Local bBlock
Local xResult

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o CW3 com outro alias, pois o mesmo está filtrado       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasCW3) > 0
	DbSelectArea(cAliasCW3)
	DbCloseArea()
EndIf
ChkFile("CW3",.F.,cAliasCW3)

DbSelectArea(cAliasCW3)
DbSetOrder(1)

DbSeek(cFilCW3+MV_PAR01,.T.)
While (cAliasCW3)->(!EOF()) .AND. (cAliasCW3)->CW3_FILIAL == cFilCW3 .AND.;
									(cAliasCW3)->CW3_CODIGO <= MV_PAR02

	IF ExistBlock( "CT278RFA" )
		ExecBlock( "CT278RFA" ,.F.,.F.,{cAliasCW3})
	Endif

	cCW3_Codigo 	:= (cAliasCW3)->CW3_CODIGO
	cCw3_Entidade	:= (cAliasCW3)->CW3_ENTID
	lUsaForm		:= .F.

	BEGIN TRANSACTION
	Do While CW3->(!EOF()) .AND. 	(cAliasCW3)->CW3_FILIAL == cFilCW3 .AND.;
									(cAliasCW3)->CW3_CODIGO == cCW3_Codigo

		IF !Empty((cAliasCW3)->CW3_FORMUL)

			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &((cAliasCW3)->CW3_FORMUL)
			RECOVER
				xResult := ""
			END SEQUENCE
			ErrorBlock(bBlock)

			IF ValType(xResult) == "N"
				RecLock(cAliasCW3,.F.)
				(cAliasCW3)->CW3_FATOR := xResult
				MsUnlock()
				lUsaForm	:= .T.
			ENDIF

			AADD(aDadosCW3,{(cAliasCW3)->CW3_ENTID, (cAliasCW3)->CW3_CODENT, (cAliasCW3)->CW3_FATOR})

		ENDIF

		(cAliasCW3)->( dbSkip() )

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a atualizacao dos grupos e rateios off-line se houve alteracao no³
	//³ fator do indice estatistico pelo uso de formula.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lUsaForm
		Ctb278Amarra(cCw3_Codigo,cCw3_Entidade,.F.,aDadosCW3,.T.,MV_PAR03==1)
	ENDIF

	END TRANSACTION

	IF ExistBlock( "CT278RFB" )
		ExecBlock( "CT278RFB" ,.F.,.F.,{cAliasCW3})
	Endif

END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o alias temporario e restaura a situação do CW3     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(cAliasCW3) > 0
	DbSelectArea(cAliasCW3)
	DbCloseArea()
EndIf

RestArea(aArea)
RETURN

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
LOCAL aCtb278BUT:= {}
LOCAL nX		:= 0

AADD(aRotina, {STR0001, "Ctb278Pes", 0, 1})//	"Pesquisar"
AADD(aRotina, {STR0002, "Ctb278Cad", 0, 2})//	"Visualizar"
AADD(aRotina, {STR0003, "Ctb278Cad", 0, 3})//	"Incluir"
AADD(aRotina, {STR0004, "Ctb278Cad", 0, 4})//	"Alterar"
AADD(aRotina, {STR0005, "Ctb278Cad", 0, 5})//	"Excluir"
AADD(aRotina, {STR0040, "Ctb278Atf", 0, 4})//	"Atualizar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA PARA ADICAO DE ITENS NO AROTINA                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("Ctb278BUT")
	aCtb278BUT := ExecBlock("Ctb278BUT",.F.,.F.,aRotina)

	IF ValType(aCtb278BUT) == "A" .AND. Len(aCtb278BUT) > 0
		FOR nX := 1 to len(aCtb278BUT)
			aAdd(aRotina,aCtb278BUT[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT278VlFatºAutor  ³Microsiga           º Data ³  08/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o Valor do Fator                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT278VlFat(nValorAux,lDel)
Local lRet 		:= .T.
Local nSomaAux  := 0
Local aSize 	:= TamSX3("CW3_FATOR")
Local nVlMax 	:= val(repl('9',aSize[1]-IIf(aSize[2]>0,aSize[2]+1,0)))

Default nValorAux := M->CW3_FATOR
Default lDel	  := .F.

nSomaAux := nTotFat
If lDel
	nSomaAux += nValorAux
Else
	nSomaAux += (nValorAux  - TMP->CW3_FATOR)
EndIf
If Int(nSomaAux) > nVlMax
	lRet := .F.
	Help("CTBA278",1,"HELP","CW3MAXFATOR",STR0053 ,1,0) //"Fator inválido. A soma dos fatores implicará em valor fora da faixa de representação numérica."
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA278   ºAutor  ³Microsiga           º Data ³  08/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT278LinFat()
Local lRet 		:= .T.
Local nSomaAux  := 0
Local aSize 	:= TamSX3("CW3_FATOR")
Local nVlMax 	:= val(repl('9',aSize[1]-IIf(aSize[2]>0,aSize[2]+1,0)))
Local aArea		:= TMP->(GetArea())

TMP->(dbGoTop())
While TMP->(!Eof())
	If !TMP->CW3_FLAG
		nSomaAux += TMP->CW3_FATOR
	EndIf
	TMP->(dbSkip())
EndDo

If Int(nSomaAux) > nVlMax
	lRet := .F.
	Help("CTBA278",1,"HELP","CW3MAXFATOR",STR0053 ,1,0) //"Fator inválido. A soma dos fatores implicará em valor fora da faixa de representação numérica."
EndIf

TMP->(RestArea(aArea))
Return lRet
