#INCLUDE "ctba270.ch"
#INCLUDE "PROTHEUS.CH"
#include "tbiconn.ch"

Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
Static __cProcPrinc := "CTBA270"
Static __oCTB2701	:= Nil
Static __oCTB2702	:= Nil
                                    
//AMARRACAO PARA BOLETIM TECNICO - FNC: 00000029121-2010

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Ctba270  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 15.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastramento de rateios Off-Line                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba270(xAutoCab,xAutoItens,nOpcAuto)

LOCAL nX		   	:= 0
LOCAL cFilEsp		:= ""
LOCAL cAlias		:= "CTQ"
LOCAL aCores		:= {}
LOCAL aCT270Cores 	:= {}

Private lCTQ_MSBLQL	:=.T.
Private lCTQ_STATUS	:= .T.

PRIVATE aRotina 	:= MenuDef()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para rotina automatica    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private lCt270Auto   := ( ValType(xAutoCab) == "A" .And. ValType(xAutoItens) == "A" )
Private aAutoCab     := {}
Private aAutoItens   := {}
Private lRpc         := Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela
Private aIndexFil    := {}
Private cFilPad      := ""
Private bFiltraBrw
Private aIndexes


cCadastro := STR0006 //"Rateios Off-Line"

If ( !AMIIn(34)	) .And.;		// Acesso somente pelo SIGACTB ou Rotina automatica
	( !lCt270Auto	)
	Return
EndIf

aIndexes := CTBEntGtIn()

/*
If lCTQ_MSBLQL
	AADD(aCores,{ "CTQ_MSBLQL <> '1'"	, "BR_VERDE"}) 		// "Desbloqueado"
	AADD(aCores,{ "CTQ_MSBLQL == '1'"	, "BR_PRETO"}) 		// "Bloqueado pelo usuario"
ElseIf lCTQ_STATUS
	AADD(aCores,{ "CTQ_STATUS == '1'"	, "BR_VERDE"}) 		// "Indice atualizado"
	AADD(aCores,{ "CTQ_STATUS == '2'"	, "BR_VERMELHO"}) 	// "Indice desatualizado"
	AADD(aCores,{ "CTQ_STATUS == '3'"	, "BR_PRETO"}) 		// "Bloqueado pelo usuario"
EndIf
*/
// Observação: Quando Está Desbloqueado e Indice atualizado ele mostra VERDE, 
// Se eu Bloqueio ele muta para PRETO
// Quando Desbloquei novamente ele volta como LARANJA, para segurança ele volta com Indice Desatualizado, para
// forçar atualizar o Indice Novamente, porque poderia ter sido alterado alguma coisa enquanto ele estava 
// bloqueado.
IF lCTQ_STATUS .AND. lCTQ_MSBLQL

                AADD(aCores,{ "CTQ_STATUS == '1' .AND. CTQ_MSBLQL <> '1'" , "BR_VERDE"})         // "Desbloqueado e Indice atualizado"
                AADD(aCores,{ "CTQ_STATUS == '2' .AND. CTQ_MSBLQL <> '1'" , "BR_AMARELO"})       // "Desbloqueado e Indice desatualizado"
                AADD(aCores,{ "CTQ_STATUS == '3' .AND. CTQ_MSBLQL <> '1'" , "BR_LARANJA"})       // "Desbloqueado porem Bloqueado por Indice"
                AADD(aCores,{ "CTQ_STATUS == '1' .AND. CTQ_MSBLQL == '1'" , "BR_VERMELHO"})      // "Bloqueado e Indice atualizado"
                AADD(aCores,{ "CTQ_STATUS == '2' .AND. CTQ_MSBLQL == '1'" , "BR_AZUL"})          // "Bloqueado e Indice desatualizado"
                AADD(aCores,{ "CTQ_STATUS == '3' .AND. CTQ_MSBLQL == '1'" , "BR_PRETO"})         // "Bloqueado pelo usuario e por indice"

ElseIf lCTQ_STATUS .AND. !lCTQ_MSBLQL

                AADD(aCores,{ "CTQ_STATUS == '1'"    , "BR_VERDE"})         // "Indice atualizado"
                AADD(aCores,{ "CTQ_STATUS == '2'"    , "BR_AMARELO"})       // "Indice desatualizado"
                AADD(aCores,{ "CTQ_STATUS == '3'"    , "BR_PRETO"})         // "Bloqueado pelo usuario"

ElseIf !lCTQ_STATUS .AND. lCTQ_MSBLQL

                AADD(aCores,{ "CTQ_MSBLQL <> '1'"   , "BR_VERDE"})          // "Desbloqueado"
                AADD(aCores,{ "CTQ_MSBLQL == '1'"   , "BR_PRETO"})          // "Bloqueado pelo usuario"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 00000120713 - Melhorias diversas no cadastro de rateios off-line ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("CT270LEG")
	aCT270Cores := ExecBlock("CT270LEG",.F.,.F.,{1})

	IF ValType(aCT270Cores) == "A" .AND. Len(aCT270Cores) > 0
		FOR nX := 1 to len(aCT270Cores)
			aAdd(aCores,aCT270Cores[nX])
		NEXT
	ENDIF

ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 00000120713 - Melhorias diversas no cadastro de rateios off-line ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilPad := "CTQ_SEQUEN = '"+StrZero(1,TamSx3("CTQ_SEQUEN")[1])+"'"

//PONTO DE ENTRADA - FILBROWSE
IF ExistBlock("C270BROW")
	cFilEsp := ExecBlock("C270BROW",.F.,.F.,cFilPad)
	cFilPad	:= IIF(ValType(cFilEsp) == "C",cFilEsp,cFilPad)
ENDIF

//PONTO DE ENTRADA - MBROWSE
IF ExistBlock("C270BRWT")
	cFilEsp := ExecBlock("C270BRWT",.F.,.F.,cFilPad)
	cFilPad	:= IIF(ValType(cFilEsp) == "C",cFilEsp,cFilPad)
ENDIF


If lCt270Auto
	Ctb270IniVar()
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"CTQ")
Else
	dbSelectArea("CTQ")

	Ctb270IniVar()

	mBrowse( 6, 1,22,75,"CTQ",,,,,,aCores,,,,,,,,cFilPad)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CTQ")
dbSetOrder(1)


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Ctb270Leg³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a legenda do MBrowse.							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA270                    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270Leg()

LOCAL aLegenda  	:= 	{}
LOCAL cTitulo		:= (SX2->(DbSeek("CTQ")),X2NOME())
LOCAL aCT270Cores 	:= {}
LOCAL nX			:= 0
/*
If lCTQ_MSBLQL
	AADD(aLegenda,{"BR_VERDE"   , STR0037})   	//"Desbloqueado"
	AADD(aLegenda,{"BR_PRETO" 	 , STR0036})		//"Bloqueado pelo usuario"
ElseIf lCTQ_STATUS
	AADD(aLegenda,{"BR_VERDE"   , STR0028})    	//"Rateio válido"
	AADD(aLegenda,{"BR_VERMELHO", STR0029})		//"Rateio inválido"
	AADD(aLegenda,{"BR_PRETO" 	 , STR0036})		//"Bloqueado pelo usuario"
EndIf
*/
// Observação: Quando Está Desbloqueado e Indice atualizado ele mostra VERDE, 
// Se eu Bloqueio ele muta para PRETO
// Quando Desbloquei novamente ele volta como LARANJA, para segurança ele volta com Indice Desatualizado, para
// forçar atualizar o Indice Novamente, porque poderia ter sido alterado alguma coisa enquanto ele estava 
// bloqueado.

IF lCTQ_STATUS .AND. lCTQ_MSBLQL

                AADD(aLegenda,{"BR_VERDE"   , STR0043})      // "Desbloqueado e Indice atualizado"
                AADD(aLegenda,{"BR_AMARELO" , STR0044})      // "Desbloqueado e Indice desatualizado"    
                AADD(aLegenda,{"BR_LARANJA" , STR0045})      // "Desbloqueado porem Bloqueado por Indice"
                AADD(aLegenda,{"BR_VERMELHO", STR0042})      // "Bloqueado e Indice atualizado"
                AADD(aLegenda,{"BR_AZUL"    , STR0038})      // "Bloqueado e Indice desatualizado"
                AADD(aLegenda,{"BR_PRETO"   , STR0039})      // "Bloqueado pelo usuario e por indice"

ElseIf lCTQ_STATUS .AND. !lCTQ_MSBLQL

                AADD(aLegenda,{"BR_VERDE"   , STR0040})      // "Indice atualizado"
                AADD(aLegenda,{"BR_AMARELO" , STR0041})      // "Indice desatualizado"
                AADD(aLegenda,{"BR_PRETO"   , STR0036})      // "Bloqueado pelo usuario"

ElseIf !lCTQ_STATUS .AND. lCTQ_MSBLQL

                AADD(aLegenda,{"BR_VERDE"   , STR0037})      // "Desbloqueado"
                AADD(aLegenda,{"BR_PRETO"   , STR0036})      // "Bloqueado pelo usuario"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 00000120713 - Melhorias diversas no cadastro de rateios off-line ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("CT270LEG")
	aCT270Cores := ExecBlock("CT270LEG",.F.,.F.,{2})

	IF ValType(aCT270Cores) == "A" .AND. Len(aCT270Cores) > 0
		FOR nX := 1 to len(aCT270Cores)
			aAdd(aLegenda,aCT270Cores[nX])
		NEXT
	ENDIF

ENDIF

BrwLegenda(cTitulo,STR0031, aLegenda) // "Legenda"

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB270PES³ Autor ³ Claudio D. de Souza   ³ Data ³ 01/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa com filtro                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB270PES()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA270                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270Pes
AxPesqui()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Ctb270Cad³ Autor ³ Claudio D. de Souza   ³ Data ³ 07.12.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de inclusao de rateios                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Ctb270Cad(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270Cad(cAlias,nReg,nOpcx)
Local oDlg
Local nOpcA
Local cCtq_Rateio
Local cCtq_Desc
Local cCtq_Tipo

Local cCtq_CtPar
Local cCtq_CCPar
Local cCtq_ItPar
Local cCtq_ClPar

Local cCtq_CtOri
Local cCtq_CCOri
Local cCtq_ItOri
Local cCtq_ClOri

Local nCtq_PerBas
Local oGet
Local cArqTmp
Local oFnt
Local aArea		:= GetArea()
Local aDados	:= {}
Local aAltera 	:= {}
Local aGetDB	:= {}		//Campos da GetDados
Local aButtons	:= {}
Local nOpcGDB	:= nOpcX	//Variavel para carregar a GetDB

Local nQtdEntid := CtbQtdEntd() - 4 //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor 
Local lCusto	:= CtbMovSaldo("CTT")
Local lItem 	:= CtbMovSaldo("CTD")
Local lClVl		:= CtbMovSaldo("CTH")
Local lEC05		:= If(_lCpoEnt05,CtbMovSaldo("CT0",,"05"),.F.) //Entidade 05
Local lEC06		:= If(_lCpoEnt06,CtbMovSaldo("CT0",,"06"),.F.) //Entidade 06
Local lEC07		:= If(_lCpoEnt07,CtbMovSaldo("CT0",,"07"),.F.) //Entidade 07
Local lEC08		:= If(_lCpoEnt08,CtbMovSaldo("CT0",,"08"),.F.) //Entidade 08
Local lEC09		:= If(_lCpoEnt09,CtbMovSaldo("CT0",,"09"),.F.) //Entidade 09

Local nOpcao 		:= If(cAlias=="CV9",2,If(nOpcX == 3, 4, nOpcX))

Local lDigita := (nOpcx == 3 .or. nOpcx == 4)			/// LÓGICO - INDICA QUANDO OS CAMPOS PODEM SER EDITADOS (INCLUSAO OU ALTERACAO)

Local oFnt1
Local cDscCtaOri:= ""
Local oDscCtaOri
Local cDscCtaPar:= ""
Local oDscCtaPar
Local cDscCCOri	:= ""
Local oDscCCOri
Local cDscCCPar	:= ""
Local oDscCCPar
Local cDscItOri	:= ""
Local oDscItOri
Local cDscItPar	:= ""
Local oDscItPar
Local cDscClOri	:= ""
Local oDscClOri
Local cDscClPar	:= ""
Local oDscClPar
Local cDscE05Ori:= "" //Entidade 05
Local oDscE05Ori
Local cDscE05Par:= ""
Local oDscE05Par
Local cDscE06Ori:= "" //Entidade 06
Local oDscE06Ori
Local cDscE06Par:= ""
Local oDscE06Par
Local cDscE07Ori:= "" //Entidade 07
Local oDscE07Ori
Local cDscE07Par:= ""
Local oDscE07Par
Local cDscE08Ori:= "" //Entidade 08
Local oDscE08Ori
Local cDscE08Par:= ""
Local oDscE08Par
Local cDscE09Ori:= "" //Entidade 09
Local oDscE09Ori
Local cDscE09Par:= ""
Local oDscE09Par
Local cF3E05
Local cF3E06
Local cF3E07
Local cF3E08
Local cF3E09

Local cAliasTmp	:= ""
Local aCtq_Tipo	:= {}
Local cCtq_MSBLQL	:= "0"
Local aCtq_MSBLQL	:= {}
Local lCT270DLG	:= ExistBlock("CT270DLG")
Local lCT270DLB	:= ExistBlock("CT270DLB")

Local aSize   	:= MsAdvSize()
Local oSize

Local nT		:= 0
Local nI		:= 0

Private aHeader 	:= {}
Private oTotRat
Private oTotVlr
Private nTotRat 		:= 0
Private nTotVlr 		:= 0
Private cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Private lCtq_Percentual := .T.

Private cCtq_E05Ori //Entidade 05 Origem
Private cCtq_E06Ori //Entidade 06 Origem
Private cCtq_E07Ori //Entidade 07 Origem
Private cCtq_E08Ori //Entidade 08 Origem
Private cCtq_E09Ori //Entidade 09 Origem

Private cCtq_E05Par //Entidade 05 Partida
Private cCtq_E06Par //Entidade 06 Partida
Private cCtq_E07Par //Entidade 07 Partida
Private cCtq_E08Par //Entidade 08 Partida
Private cCtq_E09Par //Entidade 09 Partida

dbSelectArea("CT0")
dbSetOrder(1)
dbSeek(xFilial("CT0"))

Do While !CT0->(Eof()) .And. CT0->CT0_FILIAL==xFilial("CT0")
	If CT0->CT0_ID=="05"
		cF3E05 := CT0->CT0_F3ENTI
	EndIf
     
	If CT0->CT0_ID=="06"
		cF3E06 := CT0->CT0_F3ENTI
	EndIf

	If CT0->CT0_ID=="07"
		cF3E07 := CT0->CT0_F3ENTI
	EndIf

	If CT0->CT0_ID=="08"
		cF3E08 := CT0->CT0_F3ENTI
	EndIf

	If CT0->CT0_ID=="09"
		cF3E09 := CT0->CT0_F3ENTI
	EndIf

	CT0->(dbSkip())
EndDo
RestArea(aArea)

If cAlias == "CTQ"
	(cAlias)->(DbClearFil())
	RestArea(aArea)
EndIf

aGetDB := {	If(cAlias=="CTQ","CTQ","CV9")+"_SEQUEN",;
			If(cAlias=="CTQ","CTQ","CV9")+"_CTCPAR",;
			If(cAlias=="CTQ","CTQ","CV9")+"_CCCPAR",;
			If(cAlias=="CTQ","CTQ","CV9")+"_ITCPAR",;
			If(cAlias=="CTQ","CTQ","CV9")+"_CLCPAR",;
			If(_lCpoEnt05,If(cAlias=="CTQ","CTQ","CV9")+"_E05CP",""),; //Entidade 05
			If(_lCpoEnt06,If(cAlias=="CTQ","CTQ","CV9")+"_E06CP",""),; //Entidade 06
			If(_lCpoEnt07,If(cAlias=="CTQ","CTQ","CV9")+"_E07CP",""),; //Entidade 07
			If(_lCpoEnt08,If(cAlias=="CTQ","CTQ","CV9")+"_E08CP",""),; //Entidade 08
			If(_lCpoEnt09,If(cAlias=="CTQ","CTQ","CV9")+"_E09CP",""),; //Entidade 09
			If(cAlias=="CTQ","CTQ","CV9")+"_UM",;
			If(cAlias=="CTQ","CTQ","CV9")+"_VALOR",;
			If(cAlias=="CTQ","CTQ","CV9")+"_PERCEN",;
			If(cAlias=="CTQ","CTQ","CV9")+"_FORMUL",;
			If(cAlias=="CTQ","CTQ","CV9")+"_INTERC"}

cAliasTmp	:= Iif( cAlias == "CTQ", "TMP", "TMP1" )
nOpcx	   	:= Iif( cAlias == "CV9", 2, nOpcx)

If CT270HRAT() $ "1/3" .And. cAlias # "CV9"
	AAdd(aButtons,{"POSCLI",{|| Ctb270Hist() },STR0016,STR0016}) //"Histórico"
Endif

AAdd(aButtons,{"FORM", {|| Ctb270ReCalc() }, STR0020,	STR0021})  //'Recalculo formulas'##'Rec. Form.'

IF lCT270DLB
    aButtons:= ExecBlock( "CT270DLB",.F.,.F.,aButtons )      
ENDIF

If nOpcX == 3 // Inclusao
	cCtq_Rateio := CriaVar("CTQ_RATEIO")
	cCtq_Desc   := CriaVar("CTQ_DESC")
	cCtq_Tipo   := CriaVar("CTQ_TIPO")
	cCtq_CtPar  := CriaVar("CTQ_CTPAR")
	cCtq_CCPar  := CriaVar("CTQ_CCPAR")
	cCtq_ItPar  := CriaVar("CTQ_ITPAR")
	cCtq_ClPar  := CriaVar("CTQ_CLPAR")
	cCtq_E05Par  := If(_lCpoEnt05,CriaVar("CTQ_E05PAR"),"")
	cCtq_E06Par  := If(_lCpoEnt06,CriaVar("CTQ_E06PAR"),"")
	cCtq_E07Par  := If(_lCpoEnt07,CriaVar("CTQ_E07PAR"),"")
	cCtq_E08Par  := If(_lCpoEnt08,CriaVar("CTQ_E08PAR"),"")
	cCtq_E09Par  := If(_lCpoEnt09,CriaVar("CTQ_E09PAR"),"")
	cCtq_CtOri  := CriaVar("CTQ_CTORI")
	cCtq_CCOri  := CriaVar("CTQ_CCORI")
	cCtq_ItOri  := CriaVar("CTQ_ITORI")
	cCtq_ClOri  := CriaVar("CTQ_CLORI")
	cCtq_E05Ori  := If(_lCpoEnt05,CriaVar("CTQ_E05ORI"),"")
	cCtq_E06Ori  := If(_lCpoEnt06,CriaVar("CTQ_E06ORI"),"")
	cCtq_E07Ori  := If(_lCpoEnt07,CriaVar("CTQ_E07ORI"),"")
	cCtq_E08Ori  := If(_lCpoEnt08,CriaVar("CTQ_E08ORI"),"")
	cCtq_E09Ori  := If(_lCpoEnt09,CriaVar("CTQ_E09ORI"),"")
	nCtq_PerBas := CriaVar("CTQ_PERBAS")
	cCtq_MSBLQL := IIF(lCtq_MSBLQL,CriaVar("CTQ_MSBLQL"),"0")

Else
	cCtq_Rateio := CTQ->CTQ_RATEIO
	cCtq_Desc   := CTQ->CTQ_DESC
	cCtq_Tipo   := CTQ->CTQ_TIPO
	cCtq_CtPar  := CTQ->CTQ_CTPAR
	cCtq_CCPar  := CTQ->CTQ_CCPAR
	cCtq_ItPar  := CTQ->CTQ_ITPAR
	cCtq_ClPar  := CTQ->CTQ_CLPAR
	cCtq_E05Par := If(_lCpoEnt05,CTQ->CTQ_E05PAR,"")
	cCtq_E06Par := If(_lCpoEnt06,CTQ->CTQ_E06PAR,"")
	cCtq_E07Par := If(_lCpoEnt07,CTQ->CTQ_E07PAR,"")
	cCtq_E08Par := If(_lCpoEnt08,CTQ->CTQ_E08PAR,"")
	cCtq_E09Par := If(_lCpoEnt09,CTQ->CTQ_E09PAR,"")
	cCtq_CtOri  := CTQ->CTQ_CTORI
	cCtq_CCOri  := CTQ->CTQ_CCORI
	cCtq_ItOri  := CTQ->CTQ_ITORI
	cCtq_ClOri  := CTQ->CTQ_CLORI
	cCtq_E05Ori := If(_lCpoEnt05,CTQ->CTQ_E05ORI,"")
	cCtq_E06Ori := If(_lCpoEnt06,CTQ->CTQ_E06ORI,"")
	cCtq_E07Ori := If(_lCpoEnt07,CTQ->CTQ_E07ORI,"")
	cCtq_E08Ori := If(_lCpoEnt08,CTQ->CTQ_E08ORI,"")
	cCtq_E09Ori := If(_lCpoEnt09,CTQ->CTQ_E09ORI,"")
	nCtq_PerBas := CTQ->CTQ_PERBAS
	cCtq_MSBLQL := IIF(lCtq_MSBLQL,CTQ->CTQ_MSBLQL,"0")

	If !lCt270Auto
		//Carregar variaveis de descricao de entidades contabeis.
		Ctb270CDsc(cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,cCtq_E05Ori,cCtq_E06Ori,cCtq_E07Ori,cCtq_E08Ori,cCtq_E09Ori,;
	               cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,cCtq_E05Par,cCtq_E06Par,cCtq_E07Par,cCtq_E08Par,cCtq_E09Par,;
		@cDscCtaOri,@cDscCCOri,@cDscItOri,@cDscClOri,@cDscE05Ori,@cDscE06Ori,@cDscE07Ori,@cDscE08Ori,@cDscE09Ori,;
		@cDscCtaPar,@cDscCCPar,@cDscItPar,@cDscClPar,@cDscE05Par,@cDscE06Par,@cDscE07Par,@cDscE08Par,@cDscE09Par)
	EndIf

Endif

Ctb270aHeader(cAlias,aGetDb,aAltera)
cArqTmp   := Ctb270CriaTmp(cAlias, cAliasTmp) // Cria Arquivo temporario
Ctb270Carr(nOpcX,cAlias) // Carrega dados no temporario
aCtq_Tipo := CtbCbox("CTQ_TIPO","",TamSx3("CTQ_TIPO")[1])
aCtq_MSBLQL := IIF(lCtq_MSBLQL,CtbCbox("CTQ_MSBLQL","",TamSx3("CTQ_MSBLQL")[1]),{})

If !lCt270Auto
	DEFINE FONT oFnt  	NAME "Arial" Size 10,15
	DEFINE FONT oFnt1    NAME "Arial" Size 5,10

	//Faz o calculo automatico de dimensoes de objetos
	oSize := FwDefSize():New(.T.)
	
	oSize:lLateral := .F.
	oSize:lProp	:= .T. // Proporcional

	oSize:AddObject( "1STROW" ,  100, 007, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "2NDROW" ,  100, 053, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "3RDROW" ,  100, 035, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "4THROW" ,  100, 005, .T., .T. ) // Totalmente dimensionavel
		
	oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
	
	oSize:Process() // Dispara os calculos		


	a1stRow :=	{oSize:GetDimension("1STROW","LININI"),;
				oSize:GetDimension("1STROW","COLINI"),;
				oSize:GetDimension("1STROW","LINEND"),;
				oSize:GetDimension("1STROW","COLEND")}

	a2ndRow :=	{oSize:GetDimension("2NDROW","LININI"),;
				oSize:GetDimension("2NDROW","COLINI"),;
				oSize:GetDimension("2NDROW","LINEND"),;
				oSize:GetDimension("2NDROW","COLEND")}

	a3rdRow :=	{oSize:GetDimension("3RDROW","LININI"),;
				oSize:GetDimension("3RDROW","COLINI"),;
				oSize:GetDimension("3RDROW","LINEND"),;
				oSize:GetDimension("3RDROW","COLEND")}
	
	a4thRow :=	{oSize:GetDimension("4THROW","LININI"),;
				oSize:GetDimension("4THROW","COLINI"),;
				oSize:GetDimension("4THROW","LINEND"),;
				oSize:GetDimension("4THROW","COLEND")}

	DbSelectArea(cAlias)
	DEFINE MSDIALOG oDlg TITLE STR0006 From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL //0,0 To 600,1000 PIXEL OF oMainWnd //"Rateios Off-line"
	
	@ a1stRow[1] + 006,a1stRow[2] + 002 TO 39, 496 OF oDlg PIXEL
	@ a1stRow[1] + 006,a1stRow[2] + 000 SAY STR0007 OF oDlg PIXEL //"Código Rateio"
	@ a1stRow[1] + 004,a1stRow[2] + 045 MSGET cCtq_Rateio OF oDlg SIZE 30, 9 PIXEL PICTURE PesqPict("CTQ","CTQ_RATEIO") When nOpcX == 3 Valid Ctb270Valid("CTQ_RATEIO",cCtq_Rateio) .and. FreeForUse("CTQ",cCtq_Rateio)
				 
	@ a1stRow[1] + 006,a1stRow[2] + 083 SAY STR0008 OF oDlg PIXEL //"Descrição"
	@ a1stRow[1] + 004,a1stRow[2] + 120 MSGET cCtq_Desc   OF oDlg SIZE 80, 9 PIXEL PICTURE PesqPict("CTQ","CTQ_DESC") When nOpcX == 3 .Or. nOpcX == 4 Valid Ctb270Valid("CTQ_DESC",cCtq_Desc)
	  			 
	@ a1stRow[1] + 006,a1stRow[2] + 206 SAY STR0009 OF oDlg PIXEL //"Tipo"
	@ a1stRow[1] + 004,a1stRow[2] + 219 MSCOMBOBOX cCtq_Tipo	ITEMS aCtq_Tipo OF oDlg PIXEL SIZE 70,12  When nOpcX == 3 .Or. nOpcX == 4 VALID Ctb270Valid("CTQ_TIPO",cCtq_Tipo)
									
	@ a1stRow[1] + 006,a1stRow[2] + 304 SAY STR0010 OF oDlg PIXEL //"Perc. Base"
	@ a1stRow[1] + 004,a1stRow[2] + 334 MSGET nCtq_PerBas OF oDlg PIXEL SIZE 10,9  PICTURE PesqPict("CTQ","CTQ_PERBAS") When nOpcX == 3 .Or. nOpcX == 4 Valid Ctb270Valid("CTQ_PERBAS",nCtq_PerBas)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ BOPS 00000120713 - MELHORIA: BLOQUEIO DE RATEIOS             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lCtq_MSBLQL
		@ a1stRow[1] + 006,a1stRow[2] + 402 SAY STR0022    OF oDlg PIXEL //"Bloqueado"
		@ a1stRow[1] + 006,a1stRow[2] + 432 MSCOMBOBOX cCtq_MSBLQL	ITEMS aCtq_MSBLQL OF oDlg PIXEL SIZE 60,9  When nOpcX == 3 .Or. nOpcX == 4 VALID Ctb270Valid("CTQ_MSBLQL",cCtq_MSBLQL)
	ENDIF
	
	
	@ a2ndRow[1] + 000,a2ndRow[2] + 005 TO a2ndRow[3],(a2ndRow[4] / 2) - 5 OF oDlg PIXEL LABEL STR0011 //"Origem"
	@ a2ndRow[1] + 010,a2ndRow[2] + 010 SAY STR0012 OF oDlg PIXEL //"Conta"
	@ a2ndRow[1] + 008,a2ndRow[2] + 050 MSGET oCt1Ori VAR cCtq_CtOri  OF oDlg PIXEL SIZE 80,9 PICTURE PesqPict("CTQ","CTQ_CTORI") F3 "CT1" Valid .T. .And. Ctb105Cta(cCtq_CtOri)  .And. Ctb270Say("CT1",cCtq_CtOri,@oDscCtaOri,@cDscCtaOri)  
	oCt1Ori:lReadOnly := !lDigita
	
	@ a2ndRow[1] + 023,a2ndRow[2] + 010 SAY CtbSayApro("CTT")	OF oDlg PIXEL //"C.Custo"
	@ a2ndRow[1] + 021,a2ndRow[2] + 050 MSGET oCTTOri VAR cCtq_CCOri  OF oDlg PIXEL SIZE 40,9 PICTURE PesqPict("CTQ","CTQ_CCORI") F3 "CTT" Valid CheckSx3("CTQ_CCORI",cCtq_CCOri) .And. Ctb105CC(cCtq_CCOri) .And. Ctb270Say("CTT",cCtq_CCOri,@oDscCCOri,@cDscCCOri) .And. CtbAmarra(cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,.T.)
	oCTTOri:lReadOnly := !lDigita .or. !lCusto
	
	@ a2ndRow[1] + 036,a2ndRow[2] + 010 SAY CtbSayApro("CTD") OF oDlg PIXEL //"Item Contabil"
	@ a2ndRow[1] + 034,a2ndRow[2] + 050 MSGET oCTDOri VAR cCtq_ItOri  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_ITORI") F3 "CTD" Valid CheckSx3("CTQ_ITORI",cCtq_ItOri) .And. Ctb105Item(cCtq_ItOri) .And. Ctb270Say("CTD",cCtq_ItOri,@oDscItOri,@cDscItOri) .And. CtbAmarra(cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,.T.)
	oCTDOri:lReadOnly := !lDigita .or. !lItem
	
	@ a2ndRow[1] + 049,a2ndRow[2] + 010 SAY CtbSayApro("CTH") OF oDlg PIXEL //"Valor"
	@ a2ndRow[1] + 047,a2ndRow[2] + 050 MSGET oCTHOri VAR cCtq_ClOri  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_CLORI") F3 "CTH" Valid CheckSx3("CTQ_CLORI",cCtq_ClOri) .And. Ctb105ClVl(cCtq_ClOri) .And. Ctb270Say("CTH",cCtq_ClOri,@oDscClOri,@cDscClOri) .And. CtbAmarra(cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,.T.)
	oCTHOri:lReadOnly := !lDigita .or. !lCLVL
	
	If _lCpoEnt05 //Inclui o campo origem para entidade 05
		@ a2ndRow[1] + 062,a2ndRow[2] + 010 SAY CtbSayApro("","05") OF oDlg PIXEL //Entidade 05
		@ a2ndRow[1] + 060,a2ndRow[2] + 050 MSGET oCV0E5Ori VAR cCtq_E05Ori  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E05ORI") F3 cF3E05 Valid IIf(Empty(cCtq_E05Ori),(cDscE05Ori:="", .T.) ,.F.) .Or. CheckSx3("CTQ_E05ORI",cCtq_E05Ori) .And. CTB105EntC(,cCtq_E05Ori,,"05") .And. Ctb270Say("CT0",cCtq_E05Ori,@oDscE05Ori,@cDscE05Ori,"05")
		oCV0E5Ori:lReadOnly := !lDigita .or. !lEC05
	EndIf
	
	If _lCpoEnt06  //Inclui o campo origem para entidade 06
		@ a2ndRow[1] + 075,a2ndRow[2] + 010 SAY CtbSayApro("","06") OF oDlg PIXEL //Entidade 06
		@ a2ndRow[1] + 073,a2ndRow[2] + 050 MSGET oCV0E6Ori VAR cCtq_E06Ori  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E06ORI") F3 cF3E06 Valid IIf(Empty(cCtq_E06Ori),(cDscE06Ori:="",.T.),.F.) .Or. CheckSx3("CTQ_E06ORI",cCtq_E06Ori) .And. CTB105EntC(,cCtq_E06Ori,,"06") .And. Ctb270Say("CT0",cCtq_E06Ori,@oDscE06Ori,@cDscE06Ori,"06")
		oCV0E6Ori:lReadOnly := !lDigita .or. !lEC06
	EndIf
	If _lCpoEnt07 //Inclui o campo origem para entidade 07
		@ a2ndRow[1] + 088,a2ndRow[2] + 010 SAY CtbSayApro("","07") OF oDlg PIXEL //Entidade 07
		@ a2ndRow[1] + 086,a2ndRow[2] + 050 MSGET oCV0E7Ori VAR cCtq_E07Ori  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E07ORI") F3 cF3E07 Valid IIf(Empty(cCtq_E07Ori),(cDscE07Ori:="",.T.),.F.) .Or. CheckSx3("CTQ_E07ORI",cCtq_E07Ori) .And. CTB105EntC(,cCtq_E07Ori,,"07") .And. Ctb270Say("CT0",cCtq_E07Ori,@oDscE07Ori,@cDscE07Ori,"07")
		oCV0E7Ori:lReadOnly := !lDigita .or. !lEC07
	EndIf
	If _lCpoEnt08  //Inclui o campo origem para entidade 08
		@ a2ndRow[1] + 101,a2ndRow[2] + 010 SAY CtbSayApro("","08") OF oDlg PIXEL //Entidade 08
		@ a2ndRow[1] + 099,a2ndRow[2] + 050 MSGET oCV0E8Ori VAR cCtq_E08Ori  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E08ORI") F3 cF3E08 Valid IIf(Empty(cCtq_E08Ori),(cDscE08Ori:="",.T.),.F.) .Or. CheckSx3("CTQ_E08ORI",cCtq_E08Ori) .And. CTB105EntC(,cCtq_E08Ori,,"08") .And. Ctb270Say("CT0",cCtq_E08Ori,@oDscE08Ori,@cDscE08Ori,"08")
		oCV0E8Ori:lReadOnly := !lDigita .or. !lEC08
	EndIf
	If _lCpoEnt09 //Inclui o campo origem para entidade 09
		@ a2ndRow[1] + 114,a2ndRow[2] + 010 SAY CtbSayApro("","09") OF oDlg PIXEL //Entidade 09
		@ a2ndRow[1] + 112,a2ndRow[2] + 050 MSGET oCV0E9Ori VAR cCtq_E09Ori  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E09ORI") F3 cF3E09 Valid IIf(Empty(cCtq_E09Ori),(cDscE09Ori:="",.T.),.F.) .Or. CheckSx3("CTQ_E09ORI",cCtq_E09Ori) .And. CTB105EntC(,cCtq_E09Ori,,"09") .And. Ctb270Say("CT0",cCtq_E09Ori,@oDscE09Ori,@cDscE09Ori,"09")
		oCV0E9Ori:lReadOnly := !lDigita .or. !lEC09
	EndIf

	@ a2ndRow[1] + 000,(a2ndRow[4] / 2) + 5 TO a2ndRow[3],a2ndRow[4] OF oDlg PIXEL LABEL STR0013 //"Partida"
	@ a2ndRow[1] + 010,(a2ndRow[4] / 2) + 10 SAY STR0012       OF oDlg PIXEL //"Conta"
	@ a2ndRow[1] + 008,(a2ndRow[4] / 2) + 50 MSGET oCT1Par VAR cCtq_CtPar  OF oDlg PIXEL SIZE 80,9 PICTURE PesqPict("CTQ","CTQ_CTPAR") F3 "CT1" Valid .T. .And. Ctb105Cta(cCtq_CtPar) .And. Ctb270Say("CT1",cCtq_CtPar,@oDscCtaPar,@cDscCtaPar)	
	oCT1Par:lReadOnly := !lDigita
	
	@ a2ndRow[1] + 023,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("CTT")	OF oDlg PIXEL //"C.Custo"
	@ a2ndRow[1] + 021,(a2ndRow[4] / 2) + 50 MSGET oCTTPar VAR cCtq_CCPar  OF oDlg PIXEL SIZE 40,9 PICTURE PesqPict("CTQ","CTQ_CCPAR") F3 "CTT" Valid CheckSx3("CTQ_CCPAR",cCtq_CCPar) .And. Ctb105CC(cCtq_CCPar) .And. Ctb270Say("CTT",cCtq_CCPar,@oDscCCPar,@cDscCCPar) .And. CtbAmarra(cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,.T.)
	oCTTPar:lReadOnly := !lDigita .or. !lCusto
	
	@ a2ndRow[1] + 036,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("CTD")	OF oDlg PIXEL //"Item"
	@ a2ndRow[1] + 034,(a2ndRow[4] / 2) + 50 MSGET oCTDPar VAR cCtq_ItPar  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_ITPAR") F3 "CTD" Valid CheckSx3("CTQ_ITPAR",cCtq_ItPar) .And. Ctb105Item(cCtq_ItPar) .And. Ctb270Say("CTD",cCtq_ItPar,@oDscItPar,@cDscItPar) .And. CtbAmarra(cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,.T.)
	oCTDPar:lReadOnly := !lDigita .or. !lItem
	
	@ a2ndRow[1] + 049,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("CTH")	OF oDlg PIXEL //"Valor"
	@ a2ndRow[1] + 047,(a2ndRow[4] / 2) + 50 MSGET oCTHPar VAR cCtq_ClPar  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_CLPAR") F3 "CTH" Valid CheckSx3("CTQ_CLPAR",cCtq_ClPar) .And. Ctb105ClVl(cCtq_ClPar) .And. Ctb270Say("CTH",cCtq_ClPar,@oDscClPar,@cDscClPar) .And. CtbAmarra(cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,.T.)
	oCTHPar:lReadOnly := !lDigita .or. !lCLVL
	
	If _lCpoEnt05  //Inclui o campo para entidade 05
		@ a2ndRow[1] + 062,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("","05") OF oDlg PIXEL //Entidade 05
		@ a2ndRow[1] + 060,(a2ndRow[4] / 2) + 50 MSGET oCV0E5Par VAR cCtq_E05Par  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E05PAR") F3 cF3E05 Valid IIf(Empty(cCtq_E05Par),(cDscE05Par:="",.T.),.F.) .Or. CheckSx3("CTQ_E05PAR",cCtq_E05Par) .And. CTB105EntC(,cCtq_E05Par,,"05") .And. Ctb270Say("CT0",cCtq_E05Par,@oDscE05Par,@cDscE05Par,"05")
		oCV0E5Par:lReadOnly := !lDigita .or. !lEC05
	EndIf
	If _lCpoEnt06  //Inclui o campo partida para entidade 06
		@ a2ndRow[1] + 075,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("","06") OF oDlg PIXEL //Entidade 06
		@ a2ndRow[1] + 073,(a2ndRow[4] / 2) + 50 MSGET oCV0E6Par VAR cCtq_E06Par  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E06PAR") F3 cF3E06 Valid IIf(Empty(cCtq_E06Par),(cDscE06Par:="",.T.),.F.) .Or. CheckSx3("CTQ_E06PAR",cCtq_E06Par) .And. CTB105EntC(,cCtq_E06Par,,"06") .And. Ctb270Say("CT0",cCtq_E06Par,@oDscE06Par,@cDscE06Par,"06")
		oCV0E6Par:lReadOnly := !lDigita .or. !lEC06
	EndIf
	If _lCpoEnt07  //Inclui o campo partida para entidade 07
		@ a2ndRow[1] + 088,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("","07") OF oDlg PIXEL //Entidade 07
		@ a2ndRow[1] + 086,(a2ndRow[4] / 2) + 50 MSGET oCV0E7Par VAR cCtq_E07Par  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E07PAR") F3 cF3E07 Valid IIf(Empty(cCtq_E07Par),(cDscE07Par:="",.T.),.F.) .Or. CheckSx3("CTQ_E07PAR",cCtq_E07Par) .And. CTB105EntC(,cCtq_E07Par,,"07") .And. Ctb270Say("CT0",cCtq_E07Par,@oDscE07Par,@cDscE07Par,"07")
		oCV0E7Par:lReadOnly := !lDigita .or. !lEC07
	EndIf
	If _lCpoEnt08  //Inclui o campo partida para entidade 08
		@ a2ndRow[1] + 101,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("","08") OF oDlg PIXEL //Entidade 08
		@ a2ndRow[1] + 099,(a2ndRow[4] / 2) + 50 MSGET oCV0E8Par VAR cCtq_E08Par  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E08PAR") F3 cF3E08 Valid IIf(Empty(cCtq_E08Par),(cDscE08Par:="",.T.),.F.) .Or. CheckSx3("CTQ_E08PAR",cCtq_E08Par) .And. CTB105EntC(,cCtq_E08Par,,"08") .And. Ctb270Say("CT0",cCtq_E08Par,@oDscE08Par,@cDscE08Par,"08")
		oCV0E8Par:lReadOnly := !lDigita .or. !lEC08
	EndIf
	If _lCpoEnt09  //Inclui o campo partida para entidade 09
		@ a2ndRow[1] + 114,(a2ndRow[4] / 2) + 10 SAY CtbSayApro("","09") OF oDlg PIXEL //Entidade 09
		@ a2ndRow[1] + 112,(a2ndRow[4] / 2) + 50 MSGET oCV0E9Par VAR cCtq_E09Par  OF oDlg PIXEL SIZE 30,9 PICTURE PesqPict("CTQ","CTQ_E09PAR") F3 cF3E09 Valid IIf(Empty(cCtq_E09Par),(cDscE09Par:="",.T.),.F.) .Or. CheckSx3("CTQ_E09PAR",cCtq_E09Par) .And. CTB105EntC(,cCtq_E09Par,,"09") .And. Ctb270Say("CT0",cCtq_E09Par,@oDscE09Par,@cDscE09Par,"09")
		oCV0E9Par:lReadOnly := !lDigita .or. !lEC09
	EndIf

	@ a2ndRow[1] + 010,a2ndRow[2] + 145 SAY oDscCtaOri PROMPT cDscCtaOri SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	@ a2ndRow[1] + 023,a2ndRow[2] + 145 SAY oDscCCOri  PROMPT cDscCCOri  SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	@ a2ndRow[1] + 036,a2ndRow[2] + 145 SAY oDscItOri  PROMPT cDscItOri  SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	@ a2ndRow[1] + 049,a2ndRow[2] + 145 SAY oDscClOri  PROMPT cDscClOri  SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	If _lCpoEnt05
		@ a2ndRow[1] + 062,a2ndRow[2] + 145 SAY oDscE05Ori PROMPT cDscE05Ori SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt06
		@ a2ndRow[1] + 075,a2ndRow[2] + 145 SAY oDscE06Ori PROMPT cDscE06Ori SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt07
		@ a2ndRow[1] + 088,a2ndRow[2] + 145 SAY oDscE07Ori PROMPT cDscE07Ori SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt08
		@ a2ndRow[1] + 101,a2ndRow[2] + 145 SAY oDscE08Ori PROMPT cDscE08Ori SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt09
		@ a2ndRow[1] + 114,a2ndRow[2] + 145 SAY oDscE09Ori PROMPT cDscE09Ori SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf

	@ a2ndRow[1] + 010,(a2ndRow[4] / 2) + 145 SAY oDscCtaPar PROMPT cDscCtaPar SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	@ a2ndRow[1] + 023,(a2ndRow[4] / 2) + 145 SAY oDscCCPar  PROMPT cDscCCPar  SIZE 90,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	@ a2ndRow[1] + 036,(a2ndRow[4] / 2) + 145 SAY oDscItPar  PROMPT cDscItPar  SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	@ a2ndRow[1] + 049,(a2ndRow[4] / 2) + 145 SAY oDscClPar  PROMPT cDscClPar  SIZE 90,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	If _lCpoEnt05
		@ a2ndRow[1] + 062,(a2ndRow[4] / 2) + 145 SAY oDscE05Par PROMPT cDscE05Par SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt06
		@ a2ndRow[1] + 075, (a2ndRow[4] / 2) + 145 SAY oDscE06Par PROMPT cDscE06Par SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt07
		@ a2ndRow[1] + 088, (a2ndRow[4] / 2) + 145 SAY oDscE07Par PROMPT cDscE07Par SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt08
		@ a2ndRow[1] + 101, (a2ndRow[4] / 2) + 145 SAY oDscE08Par PROMPT cDscE08Par SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf
	If _lCpoEnt09
		@ a2ndRow[1] + 114, (a2ndRow[4] / 2) + 145 SAY oDscE09Par PROMPT cDscE09Par SIZE 85,12 OF oDlg PIXEL FONT oFnt1 COLOR CLR_HBLUE
	EndIf

	@ a4thRow[1] + 000,a4thRow[2] + 132	TO 39, 426 OF oDlg PIXEL
	@ a4thRow[1] + 003,a4thRow[2] + 132	SAY STR0014 OF oDlg PIXEL //"Total rateado"
	@ a4thRow[1] + 003,a4thRow[2] + 172	SAY oTotRat VAR nTotRat PICTURE "999.99%" OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE

	If CTQ->( FieldPos("CTQ_VALOR") ) > 0
		@ a4thRow[1] + 003,a4thRow[2] + 365	SAY STR0017 OF oDlg PIXEL //"Total valor"
		@ a4thRow[1] + 003,a4thRow[2] + 365	SAY oTotVlr VAR nTotVlr PICTURE cPictVal OF oDlg PIXEL FONT oFnt COLOR CLR_HBLUE
	EndIf

 	IF lCT270DLG
 	    oDlg := ExecBlock("CT270DLG",.F.,.F.,oDlg)
 	ENDIF

	oGet := MSGetDb():New(a3rdRow[1],a3rdRow[2],a3rdRow[3],a3rdRow[4],nOpcao,"Ctb270LOk","Ctb270TOk","+CTQ_SEQUEN",.T.,aAltera,,.T.,,cAliasTmp,"Ctb270FOK",,,oDlg,,,"Ctb270Del")	

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
					{||nOpca:=1,if(Ctb270TOK(nCtq_PerBas,nOpcX,cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,;
					cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,;
					cCtq_E05Ori,cCtq_E06Ori,cCtq_E07Ori,cCtq_E08Ori,cCtq_E09Ori,;
					cCtq_E05Par,cCtq_E06Par,cCtq_E07Par,cCtq_E08Par,cCtq_E09Par),oDlg:End(),nOpca := 0)},;
					{||nOpca:=2,oDlg:End()},,aButtons) VALID nOpca != 0
Else
	cCtq_Rateio := 	aAutoCab[01,02]
	cCtq_Desc   := 	aAutoCab[02,02]
	cCtq_Tipo   := 	aAutoCab[03,02]
	cCtq_CtPar  := 	aAutoCab[04,02]
	cCtq_CcPar  := 	aAutoCab[05,02]
	cCtq_ItPar  := 	aAutoCab[06,02]
	cCtq_ClPar  := 	aAutoCab[07,02]
  	cCtq_CtOri  := 	aAutoCab[08,02]
	cCtq_Ccori  := 	aAutoCab[09,02]
	cCtq_ItOri  := 	aAutoCab[10,02]
	cCtq_ClOri  := 	aAutoCab[11,02]
	nCtq_Perbas := 	aAutoCab[12,02]
	cCtq_MSBLQL :=  aAutoCab[13,02]
	cCtq_E05Par := If(_lCpoEnt05,aAutoCab[14,02],"")
	cCtq_E06Par := If(_lCpoEnt06,aAutoCab[15,02],"")
	cCtq_E07Par := If(_lCpoEnt07,aAutoCab[16,02],"")
	cCtq_E08Par := If(_lCpoEnt08,aAutoCab[17,02],"")
	cCtq_E09Par := If(_lCpoEnt09,aAutoCab[18,02],"")

	cCtq_E05Ori := If(_lCpoEnt05,aAutoCab[19,02],"")
	cCtq_E06Ori := If(_lCpoEnt06,aAutoCab[20,02],"")
	cCtq_E07Ori := If(_lCpoEnt07,aAutoCab[21,02],"")
	cCtq_E08Ori := If(_lCpoEnt08,aAutoCab[22,02],"")
	cCtq_E09Ori := If(_lCpoEnt09,aAutoCab[23,02],"")

	lOk	:= MsGetDBAuto(	"TMP",		aAutoItens,;
						"Ctb270LOK",;
						{ || Ctb270TOk(	aAutoCab[12,02],;
										nOpcX,;
										aAutoCab[08,02],;
										aAutoCab[09,02],;
										aAutoCab[10,02],;
										aAutoCab[11,02],;
										aAutoCab[04,02],;
										aAutoCab[05,02],;
										aAutoCab[06,02],;
										aAutoCab[07,02],;
								   		If(_lCpoEnt05,aAutoCab[19,02],""),;
										If(_lCpoEnt06,aAutoCab[20,02],""),;
										If(_lCpoEnt07,aAutoCab[21,02],""),;
										If(_lCpoEnt08,aAutoCab[22,02],""),;
										If(_lCpoEnt09,aAutoCab[23,02],""),;
										If(_lCpoEnt05,aAutoCab[14,02],""),;
										If(_lCpoEnt06,aAutoCab[15,02],""),;
										If(_lCpoEnt07,aAutoCab[16,02],""),;
										If(_lCpoEnt08,aAutoCab[17,02],""),;
										If(_lCpoEnt09,aAutoCab[18,02],""))},;
						aAutoCab,;
						nOpcGDB	)
	nOpcA := If( lOk,1,0 )
EndIf

If nOpcA == 1 .and. nOpcX <> 2
	Begin Transaction
		If !lCt270Auto
			AADD(aDados,{"CTQ_RATEIO" ,cCtq_Rateio})
			AADD(aDados,{"CTQ_DESC"   ,cCtq_Desc  })
			AADD(aDados,{"CTQ_TIPO"   ,cCtq_Tipo  })
			AADD(aDados,{"CTQ_CTPAR"  ,cCtq_CtPar })
			AADD(aDados,{"CTQ_CCPAR"  ,cCtq_CcPar })
			AADD(aDados,{"CTQ_ITPAR"  ,cCtq_ItPar })
			AADD(aDados,{"CTQ_CLPAR"  ,cCtq_ClPar })
  			AADD(aDados,{"CTQ_CTORI"  ,cCtq_CtOri })
			AADD(aDados,{"CTQ_CCORI"  ,cCtq_Ccori })
			AADD(aDados,{"CTQ_ITORI"  ,cCtq_ItOri })
			AADD(aDados,{"CTQ_CLORI"  ,cCtq_ClOri })
			AADD(aDados,{"CTQ_PERBAS",nCtq_Perbas})

			IF lCTQ_MSBLQL
				If !lCTQ_Percentual
			 		AADD(aDados,{"CTQ_MSBLQL","1"})
				Else
			 		AADD(aDados,{"CTQ_MSBLQL",cCtq_MSBLQL})
				Endif
			
			ENDIF

			If (_lCpoEnt05,AADD(aDados,{"CTQ_E05PAR" ,cCtq_E05Par }),Nil)
			If (_lCpoEnt06,AADD(aDados,{"CTQ_E06PAR" ,cCtq_E06Par }),Nil)
			If (_lCpoEnt07,AADD(aDados,{"CTQ_E07PAR" ,cCtq_E07Par }),Nil)
			If (_lCpoEnt08,AADD(aDados,{"CTQ_E08PAR" ,cCtq_E08Par }),Nil)
			If (_lCpoEnt09,AADD(aDados,{"CTQ_E09PAR" ,cCtq_E09Par }),Nil)
			If (_lCpoEnt05,AADD(aDados,{"CTQ_E05ORI" ,cCtq_E05Ori }),Nil)
			If (_lCpoEnt06,AADD(aDados,{"CTQ_E06ORI" ,cCtq_E06Ori }),Nil)
			If (_lCpoEnt07,AADD(aDados,{"CTQ_E07ORI" ,cCtq_E07Ori }),Nil)
			If (_lCpoEnt08,AADD(aDados,{"CTQ_E08ORI" ,cCtq_E08Ori }),Nil)
			If (_lCpoEnt09,AADD(aDados,{"CTQ_E09ORI" ,cCtq_E09Ori }),Nil)

		Else
			// Se estiver executando rotina automatica e NAO FOR Exclusao,
			// alimentar "aDados" com todos os elementos da matriz recebida
			If nOpcX <> 5
				AADD(aDados,{"CTQ_RATEIO",aAutoCab[01,02]})
				AADD(aDados,{"CTQ_DESC"  ,aAutoCab[02,02]})
				AADD(aDados,{"CTQ_TIPO"  ,aAutoCab[03,02]})
				AADD(aDados,{"CTQ_CTPAR" ,aAutoCab[04,02]})
				AADD(aDados,{"CTQ_CCPAR" ,aAutoCab[05,02]})
				AADD(aDados,{"CTQ_ITPAR" ,aAutoCab[06,02]})
				AADD(aDados,{"CTQ_CLPAR" ,aAutoCab[07,02]})
				AADD(aDados,{"CTQ_CTORI" ,aAutoCab[08,02]})
				AADD(aDados,{"CTQ_CCORI" ,aAutoCab[09,02]})
				AADD(aDados,{"CTQ_ITORI" ,aAutoCab[10,02]})
				AADD(aDados,{"CTQ_CLORI" ,aAutoCab[11,02]})
				AADD(aDados,{"CTQ_PERBAS",aAutoCab[12,02]})

				IF lCTQ_MSBLQL .AND. Len(aAutoCab) >= 13
					If !lCTQ_Percentual
				 		AADD(aDados,{"CTQ_MSBLQL","1"})
					Else
						AADD(aDados,{"CTQ_MSBLQL",aAutoCab[13,02]})	
					Endif
				ENDIF

				If(_lCpoEnt05,AADD(aDados,{"CTQ_E05PAR",aAutoCab[14,02]}),Nil)
				If(_lCpoEnt06,AADD(aDados,{"CTQ_E06PAR",aAutoCab[15,02]}),Nil)
				If(_lCpoEnt07,AADD(aDados,{"CTQ_E07PAR",aAutoCab[16,02]}),Nil)
				If(_lCpoEnt08,AADD(aDados,{"CTQ_E08PAR",aAutoCab[17,02]}),Nil)
				If(_lCpoEnt09,AADD(aDados,{"CTQ_E09PAR",aAutoCab[18,02]}),Nil)
				If(_lCpoEnt05,AADD(aDados,{"CTQ_E05ORI",aAutoCab[19,02]}),Nil)
				If(_lCpoEnt06,AADD(aDados,{"CTQ_E06ORI",aAutoCab[20,02]}),Nil)
				If(_lCpoEnt07,AADD(aDados,{"CTQ_E07ORI",aAutoCab[21,02]}),Nil)
				If(_lCpoEnt08,AADD(aDados,{"CTQ_E08ORI",aAutoCab[22,02]}),Nil)
				If(_lCpoEnt09,AADD(aDados,{"CTQ_E09ORI",aAutoCab[23,02]}),Nil)

                If Len(aAutoItens) > 0
                    For	nI:= 1 to Len(aAutoItens)	
                        TMP->(dbGoTop())
                        TMP->(RecLock("TMP",.F.))
                            For nT := 1 to Len(aAutoItens[nI])
                                If CTQ->( FieldPos(aAutoItens[nI,nT,01]) ) > 0
                                    TMP->&(aAutoItens[nI,nT,01]) := aAutoItens[nI,nT,02]
                                EndIf
                            Next nT
                            TMP->CTQ_SEQUEN := StrZero(nI,LEN(TMP->CTQ_SEQUEN))
                        TMP->(MsUnlock())
                        TMP->(dbskip())
                    Next NI
                EndIf
			Else
				// Se estiver executando rotina automatica e FOR Exclusao,
				// alimentar "aDados" apenas com o codigo do rateio, que e o primeiro elemento da matriz recebida
				aDados := {	{"CTQ_RATEIO",aAutoCab[01,02]} }
			EndIf
		EndIf
		Ctb270Grava(cAlias,aDados,nOpcX)
		//Processa Gatilhos
		EvalTrigger()
	End Transaction
EndIf

RetIndex("CTQ")

If !FWIsInCallStack("CTB270HIST")
	//-----------------------------
	// Tabela temporaria TMP - CTQ
	//-----------------------------
	If __oCTB2701 <> Nil
		__oCTB2701:Delete()
		__oCTB2701:=Nil
	EndIf
EndIf

If cAlias == "CTQ"
	dbSelectArea("CTQ")
	Set Filter TO &('CTQ_SEQUEN=="'+StrZero(1,TamSx3("CTQ_SEQUEN")[1])+'"')
EndIf

If nOpcA <> 1
	RestArea(aArea)
EndIf

dbSelectArea(cAlias)

Return nOpcA

/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb270aHea³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepar aHeader para GetDb                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb270aHeader(cAlias,aGetDb,aAltera)
Local aArea  := GetArea()

dbSelectArea("Sx3")
dbSetOrder(1)

dbseek(cAlias)
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. (Ascan(aGetDb,Trim(x3_campo)) > 0 .Or. X3_PROPRI == 'U')
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
					 x3_tamanho, x3_decimal,;
					 If(x3_campo="CTQ_PERCEN","Ctb270Perc(M->CTQ_PERCEN)",If(x3_campo="CTQ_VALOR","Ctb270Valor()",x3_valid)),;
					 x3_usado, x3_tipo, "TMP", x3_context } )
		If Alltrim(x3_campo) <> "CTQ_SEQUEN"
			Aadd(aAltera,Trim(X3_CAMPO))
		EndIf
	ENDIF
	Skip
EndDO
// Adiciona na ultima coluna o campo nulo, para que o percentual fique visivel na GetDb
/* Removido pois foram incluidos novos campos ao final do grid, após o percentual
AADD(aHeader,{ "", "CTQ_NULO", "",;
					 1, 0, ".t.",;
					 CHR(0)+CHR(0)+CHR(1), "C", "TMP", "V" } )
*/
RestArea(aArea)

Return Nil


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb270Grav³ Autor ³ Claudio D. de Souza   ³ Data ³ 18.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as informacoes do rateio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270Grava(cAlias,aDados,nOpcX)

Local aArea			:= GetArea()
Local nAscan, nX	:= 0
Local cCtq_Rateio	:= ""
Local lDelSEQ1		:= .F.
Local lInclui		:= .T.
Local lCT270GrA    := ExistBlock("CT270GRA")  // Ponto de entrada para antes da gravação
Local lCT270GrD    := ExistBlock("CT270GRD")  // Ponto de entrada para depois da gravação
Local lCT270GrL    := ExistBlock("CT270GRL")  // Ponto de entrada para manipulação durante o loop

IF lCT270GrA
	ExecBlock("CT270GRA",.F.,.F.)
ENDIF

cCtq_Rateio := aDados[Ascan(aDados,{|e| e[1] = "CTQ_RATEIO" } )][2]	 // Obtem o codigo do rateio

(cAlias)->(dbSetOrder(1))

If nOpcX == 5	//Se for Exclusao
	If (cAlias)->(MsSeek(xFilial(cAlias)+cCtq_Rateio))
		While (cAlias)->(!Eof() .And. xFilial(cAlias) == CTQ_FILIAL .And. CTQ_RATEIO == cCtq_Rateio)
			RecLock(cAlias,.F.,.T.)
			(cAlias)->(dbDelete())
			(cAlias)->(dbSkip())
		EndDo
	EndIf
Else

   // Se for Inclusao em rotina automatica, verificar se o rateio ja existe. Se existir,
   // nao deixar incluir e abandonar a rotina sem causar erro.
	If lCt270Auto
		If (cAlias)->(MsSeek(xFilial(cAlias)+cCtq_Rateio))
			lInclui := .F.
		EndIf
	EndIf

	If lInclui .Or. nOpcX == 4
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava tabela de historico de rateios off-line ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CtbHistRat( cCtq_Rateio,,,,,"CTBA270",cAlias, aHeader)

		TMP->(dbGoTop())
		While TMP->(!Eof())
			(cAlias)->(dbSetOrder(1))
			If TMP->CTQ_FLAG  //  Se a linha estiver excluida
				If nOpcX == 3  //  Se for Inclusao de Rateio
					If TMP->CTQ_SEQUEN == StrZero(1,LEN(TMP->CTQ_SEQUEN)) // Se excluiu a primeira linha
						lDelSEQ1 := .T.
					Endif
				Else
					If (cAlias)->(dbSeek(xFilial(cAlias)+cCtq_Rateio+TMP->CTQ_SEQUEN))
						If TMP->CTQ_SEQUEN == StrZero(1,LEN(TMP->CTQ_SEQUEN))
							lDelSEQ1 := .T.
						Endif
						Reclock(cAlias,.F.,.T.)
						(cAlias)->(dbDelete())
						(cAlias)->(MsUnlock())
					EndIf
				EndIf
			Else

				If ! (cAlias)->(dbSeek(xFilial(cAlias)+cCtq_Rateio+TMP->CTQ_SEQUEN))
					RecLock(cAlias,.T.)
				Else
					RecLock(cAlias)
				EndIf

				For nX := 1 To (cAlias)->(fCount())
					cNomeCpo := (cAlias)->(FieldName(nx))
					If cNomeCpo == "CTQ_FILIAL"
						(cAlias)->CTQ_FILIAL := xFilial("CTQ")

					ElseIf cNomeCpo == "CTQ_STATUS" .And. lCTQ_STATUS
						(cAlias)->CTQ_STATUS := iif( lCTQ_MSBLQL .and. (cAlias)->CTQ_MSBLQL == '1' , "3" , IIF(lCTQ_Percentual,"1","2") )

					ElseIf lDelSEQ1 .and. cNomeCpo == "CTQ_SEQUEN"		/// SE DELETOU A 1ª SEQUENCIA RENUMERA A PROXIMA PARA 0001
						(cAlias)->CTQ_SEQUEN := StrZero(1,LEN(TMP->CTQ_SEQUEN))
						lDelSEQ1 := .F.
					Else
						// Pesquisa o campo atual em aHeader
						nAscan := Ascan(aHeader,{|e| Upper(AllTrim(e[2])) == Upper(AllTrim((cAlias)->(FieldName(nX))))})
						If nAscan > 0 .And. (cAlias)->(FieldPos(TMP->(FieldName(nX)))) > 0
							(cAlias)->(FieldPut(nX,TMP->(FieldGet(nX)))) // CTQ e TMP tem a mesma estrutura
						Else
							nAscan := Ascan(aDados, {|e| e[1] == (cAlias)->(FieldName(nX))})
							If nAscan > 0
								(cAlias)->(FieldPut(nX,aDados[nAscan][2]))
							Endif
						Endif
					Endif
				Next
				(cAlias)->(MsUnlock())
			EndIf

			IF lCT270GrL
				ExecBlock("CT270GRL",.F.,.F.)
			ENDIF

			TMP->(dbSkip())
		EndDo
	EndIf
EndIf

IF lCT270GrD
	ExecBlock("CT270GRD",.F.,.F.)
EndIf

RestArea(aArea)
Return


/*/
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb270Cria³ Autor ³ Claudio D. de Souza   ³ Data ³ 20.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara arquivo temporario para GetDb a partir do CTQ      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb270CriaTmp(cAlias,cAliasTmp)
Local aArea	:= GetArea()
Local aStru	:= (cAlias)->(DbStruct())

If cAlias == "CTQ"

	AAdd(aStru,{"CTQ_NULO","C",01,0})
	AAdd(aStru,{"CTQ_FLAG","L",01,0})

	If __oCTB2701 <> Nil
		__oCTB2701:Delete()
		__oCTB2701:=Nil
	ElseIf Select(cAliasTmp) > 0 .and. ("CT2_" $ (cAliasTmp)->(Field(1)))  //Verifica se é o TMP da CT2 q está aberto se tiver fecha
		(cAliasTmp)->(DBCloseArea()) 
	EndIf

	__oCTB2701 := FWTemporaryTable():New( cAliasTmp )
	__oCTB2701:SetFields(aStru)
	__oCTB2701:AddIndex("1", StrToKarr2( (cAlias)->( IndexKey() ), "+"))
	__oCTB2701:Create()

//----------------------------------------------------------------
// Alias para o recurso de visualizacao do Historico - MV_CTBHRAT
//----------------------------------------------------------------
ElseIf cAlias == "CV9"

	If __oCTB2702 <> Nil
		__oCTB2702:Delete()
		__oCTB2702:=Nil
	EndIf

	__oCTB2702 := FWTemporaryTable():New( cAliasTmp )
	__oCTB2702:SetFields(aStru)
	__oCTB2702:AddIndex("1", StrToKarr2( (cAlias)->( IndexKey() ), "+"))
	__oCTB2702:Create()

EndIf

RestArea(aArea)

Return cAliasTmp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb270Carr³ Autor ³ Claudio D. de Souza   ³ Data ³ 19.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega dados para GetDB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb270Carr(nOpc)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA270                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                      				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb270Carr(nOpc,cAlias)
Local aSaveArea:= GetArea()
Local nPos, nCont
Local cAliasTmp
Local cRateio
Local cRevisao
Local lCtqValor := ( CTQ->(FieldPos("CTQ_VALOR")) > 0 )

cAliasTmp := If( cAlias == "CTQ", "TMP", "TMP1" )

If nOpc != 3						// Visualizacao / Alteracao / Exclusao
	If cAlias == "CTQ"
		cRateio  := (cAlias)->CTQ_RATEIO
		cRevisao := ""
	Else
		cRateio := (cAlias)->CV9_RATEIO
		cRevisao := (cAlias)->CV9_REVISAO
	EndIf
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If dbSeek(xFilial()+cRateio+cRevisao)
		nTotRat := 0
		nTotVlr := 0
		If cAlias == "CTQ"
			bCond := { || (cAlias)->( CTQ_FILIAL + CTQ_RATEIO ) == xFilial(cAlias) + cRateio }
		Else
			bCond := { || (cAlias)->( CV9_FILIAL + CV9_RATEIO + CV9_REVISA ) == xFilial(cAlias) + cRateio + cRevisao }
		EndIf
		While !Eof() .And. Eval(bCond)
			dbSelectArea(cAliasTmp)
			dbAppend()
			For nCont := 1 To Len(aHeader)
				nPos := FieldPos(aHeader[nCont][2])
				If (aHeader[nCont][08] <> "M" .And. aHeader[nCont][10] <> "V" )
					FieldPut(nPos,(cAlias)->(FieldGet(FieldPos(aHeader[nCont][2]))))
				EndIf
			Next
			nTotRat += Iif( cAlias == "CTQ", (cAliasTmp)->CTQ_PERCEN, (cAliasTmp)->CV9_PERCEN )
			If lCtqValor
				nTotVlr += Iif( cAlias == "CTQ", (cAliasTmp)->CTQ_VALOR, (cAliasTmp)->CV9_VALOR )
			EndIf
			dbSelectArea(cAlias)
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
	If cAlias == "CTQ"
		(cAliasTmp)->CTQ_SEQUEN:= "001"
	Else
		(cAliasTmp)->CV9_SEQUEN:= "001"
	EndIf
EndIf

dbSelectArea(cAliasTmp)
dbGoTop()

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb270Percº Autor ³ ------------------ º Data ³  10/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do percentual da linha de detalhe do rateio      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb270Perc( nCTQPERCEN )

LOCAL lRet := .F.
LOCAL nTotRatAnt:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite a utilizacao de um fator ou percentual em branco quando utiliza-se formula ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lFatZero := GETMV("MV_CTQFTZR",.F.,.T.)


DEFAULT nCTQPERCEN := 0

If lRpc .AND. nTotRat <= 0 
	Ctb270Valor()
Endif

If lFatZero .AND. Empty(nCTQPERCEN) .AND. Empty(TMP->CTQ_FORMUL) .AND. !TMP->CTQ_FLAG
	If ! lRpc
		Help(" ",1,"INVPERCEN")
	EndIf
	lRet := .F.
ElseIf !lFatZero .AND. Empty(nCTQPERCEN) .AND. !TMP->CTQ_FLAG
	If ! lRpc
		Help(" ",1,"INVPERCEN")
	EndIf
	lRet := .F.
ElseIf !TMP->CTQ_FLAG        
   	nTotRatAnt := nTotRat
   IF nCTQPERCEN >= 0 
		nTotRat -= TMP->CTQ_PERCEN
		nTotRat += nCTQPERCEN // M->CTQ_PERCEN
		lRet := .T.
	Else	
	   nTotRat := nTotRatAnt
		MsgAlert(STR0023)  
		lRet := .F.
	Endif
	If lRet .AND. Valtype(oTotRat) == "O"
		oTotRat:Refresh()
	EndIf
ElseIf TMP->CTQ_FLAG
	lRet := .T.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb270Valoº Autor ³ ------------------ º Data ³  10/07/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de atualizacao do valor do rateio                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb270Valor()

Local lRet := .F.
Local nValor:= M->CTQ_VALOR


If !TMP->CTQ_FLAG 
   IF nValor < 0 
		MsgAlert(STR0029)
		lRet := .F.
   Else
		nTotVlr += (M->CTQ_VALOR - TMP->CTQ_VALOR)
		lRet := .T.
		Ctb270AtuPer()
		If lRet .AND. Valtype(oTotRat) == "O"
			oTotRat:Refresh()
		EndIf
		
		If Valtype(oTotVlr) == "O"
			oTotVlr:Refresh()
		EndIf
	
		If Valtype(oTotRat) == "O"
			oTotRat:Refresh()
		EndIf	
	Endif
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA270DELº Autor ³ ------------------ º Data ³  04/19/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Na exclusão de uma linha do rateio, atualiza os valores no º±±
±±º          ³ rodape.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb270Del

If TMP->CTQ_FLAG
	nTotRat += TMP->CTQ_PERCEN
	nTotVlr += TMP->CTQ_VALOR

Else
	nTotRat -= TMP->CTQ_PERCEN
	nTotVlr -= TMP->CTQ_VALOR
	
Endif
If Valtype(oTotRat) == "O"
	oTotRat:Refresh()
EndIf
If Valtype(oTotVlr) == "O"
	oTotVlr:Refresh()
EndIf


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA270VALº Autor ³ ------------------ º Data ³  04/19/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao da confirmacao do rateio                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb270Valid(cCampo,xConteudo)
Local lRet  := .T., aArea := GetArea()

If Empty(xConteudo) .and. cCampo <> "CTQ_MSBLQL"
	lRet := .f.
	Help(" ",1,"VAZIO")
Else
	Do Case
	Case cCampo = "CTQ_PERBAS"
		If xConteudo > 100
			lRet := .F.
			Help(" ",1,"INVPERBAS")
		Endif
	Case cCampo = "CTQ_RATEIO"
		DbSelectArea("CTQ")
		dbSetOrder(1)
		If CTQ->(MsSeek(xFilial("CTQ")+xConteudo))
			lRet := .F.
			Help(" ",1,"RATJAEXIST")
		Endif
	EndCase
Endif
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB270Say³ Autor ³ Simone Mie Sato	    ³ Data ³ 03/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostrar a descricao das entidades contabeis.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB270Say()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA270                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270Say(cAlias,cCodigo,oDesc,cSay,cIdEntid)

Local aSaveArea  := GetArea()
Local cPlanoEnt  := ""
Local cEntAlias  := ""

DEFAULT cIdEntid := ""


If !Empty(cIdEntid) //Validação para as novas entidades contábeis
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+cIdEntid)
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[Val(CT0->CT0_ID)][1])
		If MsSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCodigo) .And. !Empty(cCodigo)
			cSay := ALLTRIM((CT0->CT0_ALIAS)->&(CT0->CT0_CPODSC))
		EndIf
	EndIf
Else
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If MsSeek(xFilial()+cCodigo)
		cSay := ALLTRIM((cAlias)->&(cAlias+"_DESC01"))
	Else
		cSay := ""
	EndIf
EndIf

oDesc:SetText(cSay)

RestArea(aSaveArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb270CDsc³ Autor ³ Simone Mie Sato	    ³ Data ³ 04/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostrar a descricao das entidades contabeis.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb270CDsc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270CDsc(cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,cCtq_E05Ori,cCtq_E06Ori,cCtq_E07Ori,cCtq_E08Ori,cCtq_E09Ori,;
					cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,cCtq_E05Par,cCtq_E06Par,cCtq_E07Par,cCtq_E08Par,cCtq_E09Par,;
					cDscCtaOri,cDscCCOri,cDscItOri,cDscClOri,cDscE05Ori,cDscE06Ori,cDscE07Ori,cDscE08Ori,cDscE09Ori,;
					cDscCtaPar,cDscCCPar,cDscItPar,cDscClPar,cDscE05Par,cDscE06Par,cDscE07Par,cDscE08Par,cDscE09Par)

Local aSaveArea	:= GetArea()
Local cPlanoEnt := ""

// Carrega descricao da Conta
If !Empty(cCtq_CtOri)
	dbSelectArea("CT1")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_CtOri)
	cDscCtaOri := CT1->CT1_DESC01
EndIf
If !Empty(cCtq_CtPar)
	dbSelectArea("CT1")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_CtPar)
	cDscCtaPar := CT1->CT1_DESC01
EndIf
If !Empty(cCtq_CCOri)
	dbSelectArea("CTT")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_CCOri)
	cDscCCOri := CTT->CTT_DESC01
EndIf
If !Empty(cCtq_CcPar)
	dbSelectArea("CTT")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_CcPar)
	cDscCCPar := CTT->CTT_DESC01
EndIf
If !Empty(cCtq_ItOri)
	dbSelectArea("CTD")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_ItOri)
	cDscItOri := CTD->CTD_DESC01
EndIf

If !Empty(cCtq_ItPar)
	dbSelectArea("CTD")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_ItPar)
	cDscItPar :=  CTD->CTD_DESC01
EndIf

If !Empty(cCtq_ClOri)
	dbSelectArea("CTH")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_ClOri)
	cDscClOri :=  CTH->CTH_DESC01
EndIf

If !Empty(cCtq_ClPar)
	dbSelectArea("CTH")
	dbSetOrder(1)
	dbSeek(xFilial()+cCtq_ClPar)
	cDscClPar := CTH->CTH_DESC01
EndIf

//Entidade 05
If _lCpoEnt05 .And. !Empty(cCtq_E05Ori)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"05")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[5][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E05Ori)
			cDscE05Ori := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf
If _lCpoEnt05 .And. !Empty(cCtq_E05Par)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"05")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[5][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E05Par)
			cDscE05Par := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf

//Entidade 06
If _lCpoEnt06 .And. !Empty(cCtq_E06Ori)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"06")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[6][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E06Ori)
			cDscE06Ori := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf
If _lCpoEnt06 .And. !Empty(cCtq_E06Par)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"06")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[6][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E06Par)
			cDscE06Par := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf

//Entidade 07
If _lCpoEnt07 .And. !Empty(cCtq_E07Ori)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"07")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[7][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E07Ori)
			cDscE07Ori := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf
If _lCpoEnt07 .And. !Empty(cCtq_E07Par)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"07")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[7][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E07Par)
			cDscE07Par := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf

//Entidade 08
If _lCpoEnt08 .And. !Empty(cCtq_E08Ori)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"08")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[8][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E08Ori)
			cDscE08Ori := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf
If _lCpoEnt08 .And. !Empty(cCtq_E08Par)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"08")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[8][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E08Par)
			cDscE08Par := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf

//Entidade 09
If _lCpoEnt09 .And. !Empty(cCtq_E09Ori)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"09")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[9][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E09Ori)
			cDscE09Ori := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf
If _lCpoEnt09 .And. !Empty(cCtq_E09Par)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+"09")
		If CT0->CT0_ALIAS=="CV0"
			cPlanoEnt := CT0->CT0_ENTIDA
		Else
			cPlanoEnt := ""
		EndIf
		dbSelectArea(CT0->CT0_ALIAS)
		dbSetOrder(aIndexes[9][1])
		If dbSeek(xFilial(CT0->CT0_ALIAS)+cPlanoEnt+cCtq_E09Par)
			cDscE09Par := &(CT0->CT0_ALIAS+"->"+CT0->CT0_CPODSC)
		EndIf
	EndIf
EndIf

RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT270AJSEQºAutor  ³Marcos S. Lobo      º Data ³  02/25/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta rateios que tiveram a sequencia (linha) 001 excluida º±±
±±º          ³na alteracao, renumerando a sequencia 002 para 001.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT270AjSeq()

Local cFilCTQ := xFilial("CTQ")
Local cSeq1	  := "0001"
Local nLidos  := 0
Local nAdjust := 0
Local nTotReg := 0

If !MsgYesNo(STR0025) // "Esta rotina efetua o ajuste das linhas de Rateio Off-Line. Continuar ?"
	Return
EndIf

dbSelectArea("CTQ")
cSeq1	:= StrZero(1,Len(CTQ->CTQ_SEQUEN))
nTotReg := RecCount()
dbSetOrder(1)
dbSeek(cFilCTQ,.T.)
While !Eof()
	If CTQ->CTQ_SEQUEN <> cSeq1
		RecLock("CTQ",.F.)
		Field->CTQ_SEQUEN := cSeq1
		CTQ->(MsUnlock())
		nAdjust++
	EndIf
	dbSeek(cFilCTQ+Soma1(CTQ->CTQ_RATEIO),.T.)
	nLidos++
	If nLidos > nTotReg
		Exit
	Endif
EndDo

if ( FwRetIdiom()=="en" )
	MsgInfo(alltrim(str(nAdjust))+" records(s) affected.","Table: CT9")
else
	MsgInfo("Ajuste efetuado em "+alltrim(str(nAdjust))+" registro(s).","Tabela CTQ")
endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb270Hist ºAutor ³ Gustavo Henrique  º Data ³  02/21/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe historico do Rateio Off-Line                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb270Hist()

Local aSize := MsAdvSize(,.F.,430)
Local aRotina := { {STR0018,"Ctb270Cad",0,2}}	// "Detalhes"

MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro,"CV9",,aRotina,,"'"+xFilial('CV9')+CTQ->CTQ_RATEIO+"'","'"+xFilial('CV9')+CTQ->CTQ_RATEIO+"'",.F.,,,{{STR0019,1}},xFilial('CV9')+CV9->CV9_RATEIO)	// "Revisão + Sequência"

//-------------------------------------------
// Tabela temporaria TMP1 - CV9 - MV_CTBHRAT
//-------------------------------------------
If __oCTB2702 <> Nil
	__oCTB2702:Delete()
	__oCTB2702:=Nil
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb270AtuPerº Autor ³ Gustavo Henrique º Data ³  21/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza percentuais do rateio off-line a partir dos valoresº±±
±±º          ³ informados.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rateio Off-Line                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb270AtuPer()

Local nRecno 	:= TMP->( Recno() )
Local nDifPerc	:= 0
Local aDados	:= {}
Local aTamPerc	:= TAMSX3("CTQ_PERCEN")
Local lRet		:= .T.
Local nX		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a variavel totalizadora do percentual                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotRat := 0

TMP->( dbGoTop() )
// PREPARA DADOS PARA ATUALIZACAO DO PERCENTUAL PELO FATOR
Do While TMP->( ! EoF() )
	If !TMP->CTQ_FLAG
		If TMP->(Recno()) == nRecno
			AADD(aDados,{"", M->CTQ_VALOR	, 0, TMP->( Recno() ) }) // 3- Novo percentual
		Else
			AADD(aDados,{"", TMP->CTQ_VALOR , 0, TMP->( Recno() ) }) // 3- Novo percentual
		EndIf
	EndIf
	TMP->( dbSkip() )
EndDo

// COMPOE PERCENTUAIS COM BASE NA RELACAO DO FATOR DA LINHA COM O TOTAL DO FATOR DO GRUPO
// FATOR GLOBAL JÁ ESTA ATUALIZADO: PRIVATE nTotFat
For nX := 1 to Len(aDados)
	aDados[nX][3] := Round(NoRound((aDados[nX][2]/nTotVlr)*100,aTamPerc[2]+1),aTamPerc[2])
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
	TMP->CTQ_PERCEN := aDados[nX][3]
	If TMP->(Recno()) == nRecno
		M->CTQ_PERCEN := aDados[nX][3]
	Endif
Next nX

TMP->( dbGoTo( nRecno ) )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT270HRAT ºAutor  ³ Arnaldo R. Junior      º Data ³  23/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Avalia o tipo e o conteudo do parametro MV_CTBHRAT para        º±±
±±º          ³ tratamento dos historicos e das movimentacoes.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ CTB270HRAT()                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Caracter: ("0123")                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ SIGACTB - RATEIO OFF-LINE (CTQ / CV9)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION CT270HRAT()
Local cCTBHAT	:= "0"
Local xCTBHAT 	:= SuperGetMV("MV_CTBHRAT",.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 00000125457 - Alteracao no tratamento do parâmetro MV_CTBHRAT 					³
//³ Alteração: Tipo Original:Lógico / Alterado para: Caractere		   					³
//³ Conteúdos Originais: .F. - Desativado / .T. - Ativado			   					³
//³ Novos conteúdos: "0" - Desativo / "1" - Histórico / "2" - Movimentos / "3" - Ambos	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ValType(xCTBHAT) == "U"
	cCTBHAT := "0" // Desativado
ElseIf  ValType(xCTBHAT) == "L"
	cCTBHAT := IIF(xCTBHAT == .T., "3","0")
ElseIf	ValType(xCTBHAT) == "C"
	cCTBHAT := IIF(xCTBHAT $ "0/1/2/3", xCTBHAT,"0")
Endif

Return cCTBHAT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Ctb270ReCalcº Autor ³ Gustavo Henrique º Data ³  21/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza percentuais do rateio off-line a partir dos valoresº±±
±±º          ³ informados.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Rateio Off-Line                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ctb270ReCalc()

Local nRecno 	:= TMP->( Recno() )
Local xResult
Local bBlock
Local lUsaForm 	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a variavel totalizadora do fator                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotVlr	:=	0

TMP->( dbGoTop() )

IF ExistBlock( "CT270RFA" )
	ExecBlock( "CT270RFA" ,.F.,.F.,{"TMP"})
Endif

Do While TMP->( ! EoF() )
	IF !TMP->CTQ_FLAG
		IF !Empty(TMP->CTQ_FORMUL)

			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &(TMP->CTQ_FORMUL)
			RECOVER
				xResult := ""
			END SEQUENCE
			ErrorBlock(bBlock)

			IF ValType(xResult) == "N"
				TMP->CTQ_VALOR := xResult
		 		lUsaForm := .T.
		 	ENDIF

		ENDIF
		nTotVlr	+= TMP->CTQ_VALOR
	ENDIF
	TMP->( dbSkip() )
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a atualizacao dos percentuais devido alteracao no fator ³
//³ somente se o cadastro de rateios utilizar formula.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lUsaForm
	Ctb270AtuPer()
ENDIF

TMP->( dbGoTo( nRecno ) )

IF ExistBlock( "CT270RFB" )
	ExecBlock( "CT270RFB" ,.F.,.F.,{"TMP"})
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Ctb270Atf³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os percentuais e os fatores com base nas formulas ³±±
±±³          ³ dos cadastros de rateios off-lines.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA270                    								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270Atf()

IF Pergunte("CTB270",.T.)
	MsgRun(STR0026, STR0027, {|| Ctb270AtfPrc()})  //"Atualizando cadastros de rateios."#"Recalculando fatores com base nas formulas"
ENDIF

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb270AtfPrc³ Autor ³ ARNALDO RAYMUNDO JR.  ³ Data ³ 21/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento da atualizacao dos percentuais e dos fatores   ³±±
±±³          ³ com base nas formulas                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA270                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ctb270AtfPrc()

Local aArea			:= GetArea()
Local cFilCTQ 		:= xFilial("CTQ")
Local cCTQ_Rateio	:= ""
Local cAliasCTQ		:= "CTQ"
Local lUsaForm		:= .F.
Local bBlock
Local xResult

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa o filtro do CTQ para o processamento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAliasCTQ)
DbSetOrder(1)
DbClearFilter()
DbGoTop()

DbSeek(cFilCTQ+MV_PAR01,.T.)
While (cAliasCTQ)->(!EOF()) .AND. 	(cAliasCTQ)->CTQ_FILIAL == cFilCTQ .AND.;
									(cAliasCTQ)->CTQ_RATEIO <= MV_PAR02

	IF ExistBlock( "CT270RFA" )
		ExecBlock( "CT270RFA" ,.F.,.F.,{cAliasCTQ})
	Endif

	lUsaForm 	:= .F.
	cCTQ_Rateio	:= (cAliasCTQ)->CTQ_RATEIO
	BEGIN TRANSACTION
	Do While (cAliasCTQ)->(!EOF()) .AND. 	(cAliasCTQ)->CTQ_FILIAL == cFilCTQ .AND.;
											(cAliasCTQ)->CTQ_RATEIO == cCTQ_Rateio

		IF !Empty((cAliasCTQ)->CTQ_FORMUL)

			bBlock := ErrorBlock( { |e| ChecErro(e) } )
			BEGIN SEQUENCE
				xResult := &((cAliasCTQ)->CTQ_FORMUL)
			RECOVER
				xResult := ""
			END SEQUENCE
			ErrorBlock(bBlock)

			IF ValType(xResult) == "N"
				RecLock(cAliasCTQ,.F.)
				(cAliasCTQ)->CTQ_VALOR := xResult
				MsUnlock()
				lUsaForm := .T.
			ENDIF

		ENDIF

		(cAliasCTQ)->( dbSkip() )

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a atualizacao dos percentuais devido alteracao no fator ³
	//³ somente se o grupo de rateios utilizar formula.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lUsaForm
		Ct270CTQPer(cFilCTQ, cAliasCTQ, cCTQ_Rateio)
	ENDIF

	END TRANSACTION

	IF ExistBlock( "CT270RFB" )
		ExecBlock( "CT270RFB" ,.F.,.F.,{cAliasCTQ})
	Endif

END

RestArea(aArea)
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct270CTQPer º Autor ³ Arnaldo Raymundo Jr.    º Data ³ 28/01/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza o cadastro de Grupos, refazendo os percentuais        º±±
±±º          ³ com base nos fatores informados para cada linha.               º±±
±±º          ³ Chamada externamente para recomposicao devido a uma atualizacaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ct270CTQPer(cFilCTQ, cAliasCTQ, cCTQ_Rateio)

Local aArea 	:= GetArea()
Local nTotPerc	:= 0
Local nDifPerc	:= 0
Local nTotFat	:= 0
Local aDados	:= {}
Local aTamPerc	:= TAMSX3("CTQ_PERCEN")
Local lRet		:= .T.
Local nX		:= 0
Local cCTQSEQ	:= Replicate("0",TAMSX3("CTQ_SEQUEN")[1])

Private lCTQ_MSBLQL	:= .T.
Private lCTQ_STATUS  := .T.

// PREPARA DADOS PARA ATUALIZACAO DO PERCENTUAL PELO FATOR
DbSelectArea(cAliasCTQ)
DbSetOrder(1)
DbSeek(cFilCTQ+cCTQ_Rateio)
While (cAliasCTQ)->(!Eof()) .AND. (cAliasCTQ)->(CTQ_FILIAL+CTQ_RATEIO) == cFilCTQ+cCTQ_Rateio

	cCTQSEQ := SOMA1(cCTQSEQ)
	AADD(aDados,{cCTQSEQ, (cAliasCTQ)->CTQ_VALOR, 0, (cAliasCTQ)->(Recno()) }) // 3- Novo percentual
	nTotFat += (cAliasCTQ)->CTQ_VALOR
	(cAliasCTQ)->(DbSkip())

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
	(cAliasCTQ)->(dbGoto(aDados[nX][4]))
	RECLOCK(cAliasCTQ,.F.)
	(cAliasCTQ)->CTQ_PERCEN	:= aDados[nX][3]
	If lCTQ_MSBLQL
	(cAliasCTQ)->CTQ_MSBLQL	:= IIF(nTotPerc <> 100,"1","2")
	EndIf
	If lCTQ_STATUS
	(cAliasCTQ)->CTQ_STATUS	:= IIF(nTotPerc <> 100,"2","1")
	EndIf
	MSUNLOCK()
Next nX

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB270LOk ºAutor  ³Marcos S. Lobo      º Data ³  02/20/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validação de linha da tela de cadastro de rateios  º±±
±±º          ³off-line.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb270LOk()
LOCAL lRet := .T.
Local lCtb270lOk := ExistBlock( "CTB270LOK" )
LOCAL lFatZero := GETMV("MV_CTQFTZR",.F.,.T.)  // PERMITE FATOR + PERCENTUAL ZERADO QUANDO USA FORMULA

IF ! lCtb270lOk
	// controle de validação de linha efetuado pelo padrão
	If !TMP->CTQ_FLAG			/// SE NÃO ESTIVER DELETADO
		IF lFatZero .AND. Empty(TMP->CTQ_FORMUL) .AND. Empty(TMP->CTQ_PERCEN)
			If ! lRpc
				Help(" ",1,"CTQ_PERCEN")
			EndIf
			lRet := .F.
		ElseIf !lFatZero .AND. Empty(TMP->CTQ_PERCEN)
			If ! lRpc
				Help(" ",1,"CTQ_PERCEN")
			EndIf
			lRet := .F.
		Endif
		If lRet
			lRet := CTBVldCpos()			
		EndIf
		If lRet
			lRet := CtbVldChv()
		EndIf
	Endif
Else
	// controle de validação de linha efetuado pelo usuario
	lRet := ExecBlock( "CTB270LOK",.F.,.F.)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb270TOK ³ Autor ³ Claudio D. de Souza   ³ Data ³ 19.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega dados para GetDB                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb270TOK(nCtq_PerBas,nOpcX)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA270                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nCtq_PerBas = Percentual Base           					  ³±±
±±³          ³ nOpcX       		                     					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb270TOk(nCtq_PerBas,nOpcX,cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,cCtq_E05Ori,cCtq_E06Ori,cCtq_E07Ori,cCtq_E08Ori,cCtq_E09Ori,cCtq_E05Par,cCtq_E06Par,cCtq_E07Par,cCtq_E08Par,cCtq_E09Par)

LOCAL lRet 			:= .T.
LOCAL nRecno 		:= TMP->(Recno())
LOCAL nTotDig		:= 0
LOCAL lCtb270TOK	:= IIf(ExistBlock("CTB270TOK"),.T.,.F.)
LOCAL lUsaForm	    := .F.
LOCAL lRetObrig		:= .T.
LOCAL lRetObrigP	:= .T.
LOCAL cLogIncons	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite a utilizacao de um fator ou percentual em branco quando utiliza-se formula ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lFatZero 		:= GETMV("MV_CTQFTZR",.F.,.T.)
Local ___lCT270ET  	:= GetNewPar( "MV_CT270ET" , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos campos obrigatorios do cabecalho                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpcX == 3 .Or. nOpcX == 4)
	If	Empty(cCtq_CtOri) .And. Empty(cCtq_CCOri) .And. Empty(cCtq_ItOri) .And. Empty(cCtq_ClOri) .And.;
	    Empty(cCtq_E05Ori) .And. Empty(cCtq_E06Ori) .And. Empty(cCtq_E07Ori) .And. Empty(cCtq_E08Ori) .And.;
	    Empty(cCtq_E09Ori)
		If !lRpc
			MsgAlert(STR0015)	//"Preencher as entidades origem. Não é permitido deixar todas as entidades origem em branco."
		EndIf
		Return .F.
	EndIf

	// validação das Entidades
	// RFC - Verificar a possibilidade de disponibilizar a verificação das amarrações das entidades (Fututo)
	IF lRet .And. ___lCT270ET
		//ORIGEM
		If lRet .And. ! Empty(cCtq_CtOri)
			lRet := ValidaBloq(cCtq_CtOri,dDataBase,"CT1",!lRpc)
		Endif
		If lRet .And. ! Empty(cCtq_CCOri)
			lRet := ValidaBloq(cCtq_CCOri,dDataBase,"CTT",!lRpc)
		Endif
		If lRet .And. ! Empty(cCtq_ItOri)
			lRet := ValidaBloq(cCtq_ItOri,dDataBase,"CTD",!lRpc)
		Endif
		If lRet .And. ! Empty(cCtq_ClOri)
			lRet := ValidaBloq(cCtq_ClOri,dDataBase,"CTH",!lRpc)
		Endif
		If lRet .And. _lCpoEnt05 .And. ! Empty(cCtq_E05Ori) //Entidade 05
			lRet := ValidaBloq(cCtq_E05Ori,dDataBase,AliasCT0("05"),!lRpc,"05",PlanoCT0("05"))
		Endif
		If lRet .And. _lCpoEnt06 .And. ! Empty(cCtq_E06Ori) //Entidade 06
			lRet := ValidaBloq(cCtq_E06Ori,dDataBase,AliasCT0("06"),!lRpc,"06",PlanoCT0("06"))
		Endif
		If lRet .And. _lCpoEnt07 .And. ! Empty(cCtq_E07Ori) //Entidade 07
			lRet := ValidaBloq(cCtq_E07Ori,dDataBase,AliasCT0("07"),!lRpc,"07",PlanoCT0("07"))
		Endif
		If lRet .And. _lCpoEnt08 .And. ! Empty(cCtq_E08Ori) //Entidade 08
			lRet := ValidaBloq(cCtq_E08Ori,dDataBase,AliasCT0("08"),!lRpc,"08",PlanoCT0("08"))
		Endif
		If lRet .And. _lCpoEnt09 .And. ! Empty(cCtq_E09Ori) //Entidade 09
			lRet := ValidaBloq(cCtq_E09Ori,dDataBase,AliasCT0("09"),!lRpc,"09",PlanoCT0("09"))
		Endif
		//PARTIDA
		If lRet .And. ! Empty(cCtq_CtPar)
			lRet := ValidaBloq(cCtq_CtPar,dDataBase,"CT1",!lRpc)
		Endif
		If lRet .And. ! Empty(cCtq_CCPar)
			lRet := ValidaBloq(cCtq_CCPar,dDataBase,"CTT",!lRpc)
		Endif
		If lRet .And. ! Empty(cCtq_ItPar)
			lRet := ValidaBloq(cCtq_ItPar,dDataBase,"CTD",!lRpc)
		Endif
		If lRet .And. ! Empty(cCtq_ClPar)
			lRet := ValidaBloq(cCtq_ClPar,dDataBase,"CTH",!lRpc)
		Endif
		If lRet .And. _lCpoEnt05 .And. ! Empty(cCtq_E05Par) //Entidade 05
			lRet := ValidaBloq(cCtq_E05Par,dDataBase,AliasCT0("05"),!lRpc,"05",PlanoCT0("05"))
		Endif
		If lRet .And. _lCpoEnt06 .And.! Empty(cCtq_E06Par) //Entidade 06
			lRet := ValidaBloq(cCtq_E06Par,dDataBase,AliasCT0("06"),!lRpc,"06",PlanoCT0("06"))
		Endif
		If lRet .And. _lCpoEnt07 .And. ! Empty(cCtq_E07Par) //Entidade 07
			lRet := ValidaBloq(cCtq_E07Par,dDataBase,AliasCT0("07"),!lRpc,"07",PlanoCT0("07"))
		Endif
		If lRet .And. _lCpoEnt08 .And. ! Empty(cCtq_E08Par) //Entidade 08
			lRet := ValidaBloq(cCtq_E08Par,dDataBase,AliasCT0("08"),!lRpc,"08",PlanoCT0("08"))
		Endif
		If lRet .And. _lCpoEnt09 .And. ! Empty(cCtq_E09Par) //Entidade 09
			lRet := ValidaBloq(cCtq_E09Par,dDataBase,AliasCT0("09"),!lRpc,"09",PlanoCT0("09"))
		Endif
	Endif

	//Não fazer a validação de entidades obrigatórias na partida caso todos os campos estejam em branco

	If !(Empty(cCtq_CtPar) .And. Empty(cCtq_CCPar) .And. Empty(cCtq_ItPar) .And. Empty(cCtq_ClPar) .And. ;
		Empty(cCtq_E06Par) .And. Empty(cCtq_E06Par) .And. Empty(cCtq_E07Par) .And. Empty(cCtq_E08Par) .And. Empty(cCtq_E09Par) )
	
		// Verificar se há entidades contábeis configuradas com outras entidades contábeis obrigatórias
		
		lRetObrig := CtbObrig(	cCtq_CtPar,;
								cCtq_CCPar,;
								cCtq_ItPar,;
								cCtq_ClPar,;
								.T.,;
								"1",.F.,,;
								"",;
								IIf( _lCpoEnt05, cCtq_E05Par, NIL ),;
								IIf( _lCpoEnt06, cCtq_E06Par, NIL ),;
								IIf( _lCpoEnt07, cCtq_E07Par, NIL ),;
								IIf( _lCpoEnt08, cCtq_E08Par, NIL ),;
								IIf( _lCpoEnt09, cCtq_E09Par, NIL ) )

		//Se houver inconsistência, avisar ao usuário se deseja continuar

		If !lRetObrig 
			lRet := MsgYesNo( STR0059 + CRLF + CRLF +; //Foram encontradas inconsistências no cadastro de rateio.
			STR0057 + CRLF + CRLF + ; //As entidades informadas na partida possuem obrigatoriedades ou aceites de outras entidades:
			STR0060) //Deseja continuar mesmo assim?
		EndIf
	
	EndIf

	If lRet
		// verifica as linhas do Rateio
		DbSelectArea( "TMP" )
		nTmpRec := Recno()

		dbGotop()
		While TMP->(!Eof())
			// verifica o percentual
			IF Ctb270Perc( TMP->CTQ_PERCEN )
				IF !(TMP->CTQ_FLAG)
					nTotDig	+= TMP->CTQ_PERCEN
				ENDIF
				IF !lUsaForm .AND. !EMPTY(TMP->CTQ_FORMUL)
					lUsaForm := .T.
				ENDIF
			ELSE
				lRet := .F.
				Exit
			ENDIF

			// verifica o bloqueio das entidades
			// RFC - Verificar a possibilidade de disponibilizar a verificação das amarrações das entidades (Fututo)
			IF lRet .And. ___lCT270ET
				If lRet .And. ! Empty(TMP->CTQ_CTCPAR)
					lRet := ValidaBloq(TMP->CTQ_CTCPAR,dDataBase,"CT1",!lRpc)
				Endif
				If lRet .And. ! Empty(TMP->CTQ_CCCPAR)
					lRet := ValidaBloq(TMP->CTQ_CCCPAR,dDataBase,"CTT",!lRpc)
				Endif
				If lRet .And. ! Empty(TMP->CTQ_ITCPAR)
					lRet := ValidaBloq(TMP->CTQ_ITCPAR,dDataBase,"CTD",!lRpc)
				Endif
				If lRet .And. ! Empty(TMP->CTQ_CLCPAR)
					lRet := ValidaBloq(TMP->CTQ_CLCPAR,dDataBase,"CTH",!lRpc)
				Endif
		   		If lRet .And. _lCpoEnt05 .And. ! Empty(TMP->CTQ_E05PAR) //Entidade 05
					lRet := ValidaBloq(TMP->CTQ_E05PAR,dDataBase,AliasCT0("05"),!lRpc,"05",PlanoCT0("05"))
				Endif
		   		If lRet .And. _lCpoEnt06 .And. ! Empty(TMP->CTQ_E06PAR) //Entidade 06
					lRet := ValidaBloq(TMP->CTQ_E06PAR,dDataBase,AliasCT0("06"),!lRpc,"06",PlanoCT0("06"))
				Endif
		   		If lRet .And. _lCpoEnt07 .And. ! Empty(TMP->CTQ_E07PAR) //Entidade 07
					lRet := ValidaBloq(TMP->CTQ_E07PAR,dDataBase,AliasCT0("07"),!lRpc,"07",PlanoCT0("07"))
				Endif
		   		If lRet .And. _lCpoEnt08 .And. ! Empty(TMP->CTQ_E08PAR) //Entidade 08
					lRet := ValidaBloq(TMP->CTQ_E08PAR,dDataBase,AliasCT0("08"),!lRpc,"08",PlanoCT0("08"))
				Endif
		   		If lRet .And. _lCpoEnt09 .And. ! Empty(TMP->CTQ_E09PAR) //Entidade 09
					lRet := ValidaBloq(TMP->CTQ_E09PAR,dDataBase,AliasCT0("09"),!lRpc,"09",PlanoCT0("09"))
				Endif
			ENDIF

			If !TMP->CTQ_FLAG // Não verificar linhas deletadas

				// Verificar se há entidades contábeis configuradas com outras entidades contábeis obrigatórias

				lRetObrigP := CtbObrig(	TMP->CTQ_CTCPAR,;
								TMP->CTQ_CCCPAR,;
								TMP->CTQ_ITCPAR,;
								TMP->CTQ_CLCPAR,;
								.T.,;
								"1",.F.,,;
								"",;
								IIf( _lCpoEnt05, TMP->CTQ_E05PAR, NIL ),;
								IIf( _lCpoEnt06, TMP->CTQ_E06PAR, NIL ),;
								IIf( _lCpoEnt07, TMP->CTQ_E07PAR, NIL ),;
								IIf( _lCpoEnt08, TMP->CTQ_E08PAR, NIL ),;
								IIf( _lCpoEnt09, TMP->CTQ_E09PAR, NIL ) )
				
				IIf (!lRetObrigP, cLogIncons += TMP->CTQ_SEQUEN + CRLF , Nil)

			EndIf

			TMP->(DbSkip())
		EndDo

		TMP->( DbGoTo( nTmpRec ) )
	Endif
//Se houver inconsistência, avisar ao usuário se deseja continuar
	If !lRetObrigP
					lRet := (Aviso(STR0061, STR0059 + CRLF + CRLF +; //"Atenção" // "Foram encontradas inconsistências no cadastro de rateio."
					STR0058 + CRLF + CRLF +; //As entidades informadas na contra partida possuem obrigatoriedades ou não aceitam outras entidades (Ex: centro de custo, item contabil, classe de valor e entidades adicionais)
					STR0060 + CRLF + CRLF +; // Deseja continuar mesmo assim?
					STR0065 + CRLF + CRLF + cLogIncons, {STR0063, STR0062}, 3) == 2) //Linhas inconsistentes: // "Não" // "Sim"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao de consistencia do rateio. Caso invalido ficará bloqueado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lRet
		IF nTotRat <> 100 .AND. !lFatZero
			IF !lRpc
				Help(" ",1,"PERCINVAL")
			ENDIF
			lRet := .F.
		ELSEIF nTotDig <> 100 .AND. lFatZero .And. !lUsaForm
			IF !lRpc
				Help(" ",1,"PERCINVAL")
			ENDIF
			lRet := .F.
		ELSEIF nTotDig <> 100 .AND. lFatZero .And. lUsaForm
			IF !lRpc
				Help("CTBA270",1,"HELP","CTBA270PERC",STR0023+CRLF+STR0024,1,0) //"Percentual informado diferente de 100%"#"Rateio será gravado como bloqueado."
			ENDIF
			lCTQ_Percentual := .F.
		ELSEIF nTotDig == 100
			lCTQ_Percentual := .T.
		ENDIF
	ENDIF

	If lRet
		If nCtq_PerBas	<> Nil .AND. nCtq_PerBas == 0
			If !lRpc
				Help("",1,"NOPERDGBAS")
			EndIf
			lRet	:= .F.
		EndIf
	EndIf

	If lRet
		lRet := CTBVldCpos()			
	EndIf
	If lRet
		lRet := CtbVldChv()
	EndIf
EndIf

If lRet
	If lCtb270TOk
		lRet :=  ExecBlock("CTB270TOK", .F., .F., {nOpcX,cCtq_CtOri,cCtq_CCOri,cCtq_ItOri,cCtq_ClOri,;
                                                   cCtq_CtPar,cCtq_CCPar,cCtq_ItPar,cCtq_ClPar,;
                                                   cCtq_E05Ori,cCtq_E06Ori,cCtq_E07Ori,cCtq_E08Ori,cCtq_E09Ori,;
                                                   cCtq_E05Par,cCtq_E06Par,cCtq_E07Par,cCtq_E08Par,cCtq_E09Par } )
	EndIf
EndIf

TMP->(MsGoTo(nRecno))
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb270FOK ºAutor  ³Marcelo Akama       º Data ³  30/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a validação de campos da tela de cadastro de rateios º±±
±±º          ³off-line.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBA270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb270FOK()
Local lRet		:= .T.
Local cCampo	:= ReadVar()

Do Case
	Case cCampo == "M->CTQ_E05CP"
		lRet := CTB105EntC(,M->CTQ_E05CP,,"05")
	Case cCampo == "M->CTQ_E06CP"
		lRet := CTB105EntC(,M->CTQ_E06CP,,"06")
	Case cCampo == "M->CTQ_E07CP"
		lRet := CTB105EntC(,M->CTQ_E07CP,,"07")
	Case cCampo == "M->CTQ_E08CP"
		lRet := CTB105EntC(,M->CTQ_E08CP,,"08")
	Case cCampo == "M->CTQ_E09CP"
		lRet := CTB105EntC(,M->CTQ_E09CP,,"09")
EndCase

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
LOCAL aCT270BUT	:= {}
LOCAL nX		:= 0

AADD(aRotina, { STR0001	,"Ctb270Pes", 0 , 1}) //"Pesquisar"
AADD(aRotina, { STR0002	,"Ctb270Cad", 0 , 2}) //"Visualizar"
AADD(aRotina, { STR0003	,"Ctb270Cad", 0 , 3}) //"Incluir"
AADD(aRotina, { STR0004	,"Ctb270Cad", 0 , 4}) //"Alterar"
AADD(aRotina, { STR0005	,"Ctb270Cad", 0 , 5}) //"Excluir"
AADD(aRotina, { STR0030	,"Ctb270Atf", 0 , 4}) //"Atualizar"
AADD(aRotina, { STR0031	,"Ctb270Leg", 0 , 6}) //"Legenda"
AADD(aRotina, { STR0052,"CT270IMP", 0 , 3}) //"Importar"
AADD(aRotina, { STR0053,"CT270LOG", 0 , 2}) //"Log Proc"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 00000120713 - Melhorias diversas no cadastro de rateios off-line ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF ExistBlock("CT270BUT")
	aCT270BUT := ExecBlock("CT270BUT",.F.,.F.,aRotina)

	IF ValType(aCT270BUT) == "A" .AND. Len(aCT270BUT) > 0
		FOR nX := 1 to len(aCT270BUT)
			aAdd(aRotina,aCT270BUT[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlanoCT0  ºAutor  ³Microsiga           º Data ³  24/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o plano das novas entidades contabeis               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlanoCT0(cIdEntid)

Local cRet := ""
Local aSaveArea := GetArea()
Default cIdEntid := ""

dbSelectArea("CT0")
dbSetOrder(1)
If dbSeek(xFilial("CT0")+cIdEntid)
	cRet := CT0->CT0_ENTIDA
EndIf

RestArea(aSaveArea)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AliasCT0  ºAutor  ³Marcelo Akama       º Data ³  17/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o alias das novas entidades contabeis               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AliasCT0(cIdEntid)

Local cRet := ""
Local aSaveArea := GetArea()
Default cIdEntid := ""

dbSelectArea("CT0")
dbSetOrder(1)
If dbSeek(xFilial("CT0")+cIdEntid)
	cRet := CT0->CT0_ALIAS
EndIf

RestArea(aSaveArea)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb270IniVar ºAutor  ³Microsiga        º Data ³  06/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analise da existência dos campos das novas entidades       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb270IniVar()

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CTQ->(FieldPos("CTQ_E05ORI")>0 .And. FieldPos("CTQ_E05PAR")>0)
EndIf

If _lCpoEnt06 == Nil
	_lCpoEnt06 := CTQ->(FieldPos("CTQ_E06ORI")>0 .And. FieldPos("CTQ_E06PAR")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CTQ->(FieldPos("CTQ_E07ORI")>0 .And. FieldPos("CTQ_E07PAR")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CTQ->(FieldPos("CTQ_E08ORI")>0 .And. FieldPos("CTQ_E08PAR")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CTQ->(FieldPos("CTQ_E09ORI")>0 .And. FieldPos("CTQ_E09PAR")>0)
EndIf

Return

/*{Protheus.doc}CT270IMP
Importa o arquivo de rateio
@author Mayara Alves da silva
@since 05/07/2015
@version P12
@project Inovação Controladoria
*/
Function CT270IMP()

Local aHeadCsv		:= {}	//Array com o cabecalho do arquivo CSV
Local aColsCsv		:= {}	//Array com os intens do arquivo CSV
Local aCpoCab		:= {}
Local aCpoItens		:= {}
Local aCab			:= {}
Local aItens		:= {}
Local aAux			:= {}
Local aErro			:= {}

Local nCont0		:= 0 		
Local nCont1		:= 0
Local nCont2		:= 0
Local nPos1			:= 0 
Local nPos2			:= 0
Local nPosRateio	:= 0
Local nRegrava		:= 2 
Local nIniLog		:= 0 
Local nSpace		:= 0 
Local nX		   	:= 0

Local cCodRat		:= ""
Local cRatAnt		:= ""
Local cMensIni		:= ""
Local cLogErro		:= ""
Local cId			:= ""
Local cMensagem		:= ""
Local cMsg			:= ""

Local lErro			:= .F.
Local lExiste		:= .F. 
Local lRegrava		:= .F.

PRIVATE lMsErroAuto 	:= .F.	//Determina se houve algum tipo de erro durante a execucao do ExecAuto
Private lMsHelpAuto     := .T. //Define se mostra ou não os erros na tela (T= Nao mostra; F=Mostra)
Private lAutoErrNoFile 	:= .T. //Habilita a gravacao de erro da rotina automatica

cCtq_Rateio := CriaVar("CTQ_RATEIO") 
cCtq_Desc 	:= CriaVar("CTQ_DESC") 
cCtq_Tipo 	:= CriaVar("CTQ_TIPO") 
cCtq_CtPar 	:= CriaVar("CTQ_CTPAR") 
cCtq_CCPar 	:= CriaVar("CTQ_CCPAR") 
cCtq_ItPar 	:= CriaVar("CTQ_ITPAR") 
cCtq_ClPar 	:= CriaVar("CTQ_CLPAR")
cCtq_E05Par := If(_lCpoEnt05,CriaVar("CTQ_E05PAR"),"")
cCtq_E06Par := If(_lCpoEnt06,CriaVar("CTQ_E06PAR"),"")
cCtq_E07Par := If(_lCpoEnt07,CriaVar("CTQ_E07PAR"),"")
cCtq_E08Par := If(_lCpoEnt08,CriaVar("CTQ_E08PAR"),"")
cCtq_E09Par := If(_lCpoEnt09,CriaVar("CTQ_E09PAR"),"") 
cCtq_CtOri 	:= CriaVar("CTQ_CTORI") 
cCtq_CCOri 	:= CriaVar("CTQ_CCORI") 
cCtq_ItOri 	:= CriaVar("CTQ_ITORI") 
cCtq_ClOri 	:= CriaVar("CTQ_CLORI") 
cCtq_E05Ori := If(_lCpoEnt05,CriaVar("CTQ_E05ORI"),"")
cCtq_E06Ori := If(_lCpoEnt06,CriaVar("CTQ_E06ORI"),"")
cCtq_E07Ori := If(_lCpoEnt07,CriaVar("CTQ_E07ORI"),"")
cCtq_E08Ori := If(_lCpoEnt08,CriaVar("CTQ_E08ORI"),"")
cCtq_E09Ori := If(_lCpoEnt09,CriaVar("CTQ_E09ORI"),"")
nCtq_PerBas	:= CriaVar("CTQ_PERBAS") 
cCtq_MSBLQL := '0'

AADD(aCpoCab, {"CTQ_RATEIO",cCtq_Rateio})
AADD(aCpoCab, {"CTQ_DESC",cCtq_Desc}) 
AADD(aCpoCab, {"CTQ_TIPO",cCtq_Tipo}) 
AADD(aCpoCab, {"CTQ_CTPAR",cCtq_CtPar}) 
AADD(aCpoCab, {"CTQ_CCPAR",cCtq_CcPar}) 
AADD(aCpoCab, {"CTQ_ITPAR",cCtq_ItPar}) 
AADD(aCpoCab, {"CTQ_CLPAR",cCtq_ClPar})
AADD(aCpoCab, {"CTQ_CTORI",cCtq_CtOri}) 
AADD(aCpoCab, {"CTQ_CCORI",cCtq_CCOri}) 
AADD(aCpoCab, {"CTQ_ITORI",cCtq_ItOri}) 
AADD(aCpoCab, {"CTQ_CLORI",cCtq_ClOri}) 
AADD(aCpoCab, {"CTQ_PERBAS",nCtq_Perbas})
AADD(aCpoCab, {"CTQ_MSBLQL",cCtq_MSBLQL})


If _lCpoEnt05 .Or. _lCpoEnt06 .Or. _lCpoEnt07 .Or. _lCpoEnt08 .Or. _lCpoEnt09
	AADD(aCpoCab,{"CTQ_E05PAR",cCtq_E05Par})
	AADD(aCpoCab,{"CTQ_E06PAR",cCtq_E06Par})
	AADD(aCpoCab,{"CTQ_E07PAR",cCtq_E07Par})
	AADD(aCpoCab,{"CTQ_E08PAR",cCtq_E08Par})
	AADD(aCpoCab,{"CTQ_E09PAR",cCtq_E09Par})
	AADD(aCpoCab,{"CTQ_E05ORI",cCtq_E05Ori})
	AADD(aCpoCab,{"CTQ_E06ORI",cCtq_E06Ori})
	AADD(aCpoCab,{"CTQ_E07ORI",cCtq_E07Ori})
	AADD(aCpoCab,{"CTQ_E08ORI",cCtq_E08Ori})
	AADD(aCpoCab,{"CTQ_E09ORI",cCtq_E09Ori})
EndIf

AADD(aCpoItens, "CTQ_FILIAL")
AADD(aCpoItens, "CTQ_CTORI") 
AADD(aCpoItens, "CTQ_CCORI") 
AADD(aCpoItens, "CTQ_ITORI") 
AADD(aCpoItens, "CTQ_CLORI") 
AADD(aCpoItens, "CTQ_CTPAR") 
AADD(aCpoItens, "CTQ_CCPAR") 
AADD(aCpoItens, "CTQ_ITPAR") 
AADD(aCpoItens, "CTQ_CLPAR")
If _lCpoEnt05 .Or. _lCpoEnt06 .Or. _lCpoEnt07 .Or. _lCpoEnt08 .Or. _lCpoEnt09 
	AADD(aCpoItens,"CTQ_E05PAR")
	AADD(aCpoItens,"CTQ_E06PAR")
	AADD(aCpoItens,"CTQ_E07PAR")
	AADD(aCpoItens,"CTQ_E08PAR")
	AADD(aCpoItens,"CTQ_E09PAR")
EndIf
AADD(aCpoItens, "CTQ_SEQUEN") 
AADD(aCpoItens, "CTQ_CTCPAR") 
AADD(aCpoItens, "CTQ_CCCPAR") 
AADD(aCpoItens, "CTQ_ITCPAR") 
AADD(aCpoItens, "CTQ_CLCPAR")
If _lCpoEnt05 .Or. _lCpoEnt06 .Or. _lCpoEnt07 .Or. _lCpoEnt08 .Or. _lCpoEnt09
	AADD(aCpoItens,"CTQ_E05CP")
	AADD(aCpoItens,"CTQ_E06CP")
	AADD(aCpoItens,"CTQ_E07CP")
	AADD(aCpoItens,"CTQ_E08CP")
	AADD(aCpoItens,"CTQ_E09CP")
EndIf
 
AADD(aCpoItens, "CTQ_UM") 
AADD(aCpoItens, "CTQ_VALOR") 
AADD(aCpoItens, "CTQ_PERCEN") 
AADD(aCpoItens, "CTQ_FORMUL") 
AADD(aCpoItens, "CTQ_INTERC")
      	
CTBArqRat(@aHeadCSV,@aColsCSV,@nRegrava)

If Len(aHeadCSV) == 0 
	Return
EndIf

lRegrava		:= IIf(nRegrava == 1,.T.,.F.)

nPosRateio	:= Ascan(aHeadCSV,"CTQ_RATEIO")

//Começa o log de processamento
//ProcLogIni( {},__cProcPrinc,"Rateio Off-line",@cId )
	
cMensIni := STR0046//"Importação do arquivo: "

For nCont0:= 1  to Len(aColsCSV)

	//Chama MsExecAuto
	If nCont0 > 1 .And. cRatAnt <> aColsCsv[nCont0][nPosRateio]
		If !lExiste
			MSExecAuto( {|X,Y,Z| CTBA270(X,Y,Z)} ,aCab ,aItens, 3)
		Else
			If lRegrava
				nSpace		:= Len(CTQ->CTQ_RATEIO)-Len(cRatAnt)
				cCodRat		:= cRatAnt+Space(nSpace)
				dbSelectArea("CTQ")
				Set Filter To	
				dbSetOrder(1)
				If dbSeek(xFilial("CTQ")+cCodRat)
					While !Eof() .And. CTQ->CTQ_FILIAL == xFilial("CTQ") .And. CTQ->CTQ_RATEIO == cCodRat
						Reclock("CTQ",.F.)
						dbDelete()
						MsUnlock()
						dbSkip()
					End
				EndIf
				cCodRat	:= ""
				MSExecAuto( {|X,Y,Z| CTBA270(X,Y,Z)} ,aCab ,aItens, 3)
			Else
				lErro	:= .T.
				cMensagem := STR0050 + cRatAnt +STR0051//" já existe."
			
				ProcLogAtu( STR0049, cMensagem ,"",,.T.)//"MENSAGEM"##"Rateio:" #######+" já existe."
			Endif
		EndIf 

		If lMsErroAuto <> Nil
			If lMsErroAuto
			
				aErro := GetAutoGrLog()
            	cMsg := ""
				nIniLog	:= ASCAN(aErro,"Tabela CTQ ")
				If nIniLog > 0 
                	For nX := nIniLog To Len(aErro)
						cMsg += aErro[nX] + CRLF
                	Next nX
                EndIf
                aErro	:= {}
         		lErro	:= .T.
				nIniLog	:= 0          			
				cLogErro 	:= STR0047+ cRatAnt	//"Erro no Rateio "
				cLogErro	+= cMsg
				
				ProcLogAtu(STR0048,cMensIni,cLogErro,,.T. ) //"ERRO"
				lMsErroAuto	:= .F.
				cMsg 		:= ""
				cLogErro	:= ""
			EndIf
		EndIf	
		aCab	:= {}
		aItens	:= {}
	Endif


	If nCont0 == 1 .Or. cRatAnt <> Alltrim(aColsCsv[nCont0][nPosRateio])
		CTQ->(dbSetOrder(1))
		If CTQ->(dbSeek(xFilial("CTQ")+aColsCsv[nCont0][nPosRateio]))
			lExiste	:= .T.
		Else
			lExiste	:= .F.
		EndIf   
		
		//Cabeçalho
		For nCont1 := 1 to Len(aCpoCab)
			nPos1	:= Ascan(aHeadCSV, aCpoCab[nCont1][1])
		
			If nPos1 > 0 
				If aCpoCab[nCont1][1] $ ("CTQ_PERBAS")
					AADD(aCab,{aCpoCab[nCont1][2],Val(aColsCSV[nCont0][nPos1]),NIL})
				Else 
					AADD(aCab,{aCpoCab[nCont1][2],aColsCSV[nCont0][nPos1],NIL})
				EndIf
			Else
				If aCpoCab[nCont1][1] $ ("CTQ_E05ORI/CTQ_E06ORI/CTQ_E07ORI/CTQ_E08ORI/CTQ_E09ORI/CTQ_E05PAR/CTQ_E06PAR/CTQ_E07PAR/CTQ_E08PAR/CTQ_E09PAR") 
					AADD(aCab,{"","",NIL})
				EndIf	
			EndIf			
		Next
	EndIf 

	//Itens
	For nCont2 := 1 to Len(aCpoItens)
		nPos2	:= Ascan(aHeadCSV,aCpoItens[nCont2])
		If nPos2 > 0 
			If aCpoItens[nCont2] $ ("CTQ_VALOR/CTQ_PERCEN")
				AADD(aAux,{aCpoItens[nCont2],Val(aColsCSV[nCont0][nPos2]),NIL})
			Else 
				AADD(aAux,{aCpoItens[nCont2],aColsCSV[nCont0][nPos2],NIL})
			EndIf
		Else
			If aCpoItens[nCont2] $ ("CTQ_E05CP/CTQ_E06CP/CTQ_E07CP/CTQ_E08CP/CTQ_E09CP/CTQ_E05PAR/CTQ_E06PAR/CTQ_E07PAR/CTQ_E08PAR/CTQ_E09PAR")
				AADD(aAux,{aCpoItens[nCont2],"",NIL})
			EndIf		
		EndIf
	Next
	AADD(aItens,aAux)
	nCont2 := 1
	aAux	:= {}
	cRatAnt	:= aColsCsv[nCont0][nPosRateio]
Next

If !lExiste
	MSExecAuto( {|X,Y,Z| CTBA270(X,Y,Z)} ,aCab ,aItens, 3)
Else
	If lRegrava	
		nSpace		:= Len(CTQ->CTQ_RATEIO)-Len(cRatAnt)
		cCodRat		:= 	cRatAnt+Space(nSpace)
		dbSelectArea("CTQ")	
		Set Filter To
		dbSetOrder(1)
		If dbSeek(xFilial("CTQ")+cCodRat)
			While !Eof() .And. CTQ->CTQ_FILIAL == xFilial("CTQ") .And. CTQ->CTQ_RATEIO == cCodRat
				Reclock("CTQ",.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()				
			End
		EndIf
		cCodRat	:= ""
		MSExecAuto( {|X,Y,Z| CTBA270(X,Y,Z)} ,aCab ,aItens, 3)
	Else
		lErro	:= .T.
		cMensagem := STR0050 + cRatAnt +STR0051 //" já existe."
	
		ProcLogAtu( STR0049, cMensagem ,"",,.T.)//"MENSAGEM"##"Rateio:" #######+" já existe."
	Endif
EndIf


If lMsErroAuto <> Nil
	If lMsErroAuto
		lErro	:= .T.
		aErro := GetAutoGrLog()
        cMsg := ""
		nIniLog	:= ASCAN(aErro,"Tabela CTQ ")
		
		If nIniLog > 0 
	        For nX := nIniLog To Len(aErro)
				cMsg += aErro[nX] + CRLF
   	     	Next nX
   	     EndIf
   	    nIniLog	:= 0  
       	aErro	:= {} 
		cLogErro := STR0047+ cRatAnt	+ CRLF//"Erro no Rateio "
		
		cLogErro	+= cMsg
		
		ProcLogAtu(STR0048,cMensIni,cLogErro,,.T. ) //"ERRO"
		lMsErroAuto	:= .F.	
		cMsg		:= ""
		cLogErro	:= ""	
	EndIf
EndIf
cMensIni := "Importação do arquivo: "
ProcLogAtu("FIM",cMensIni,,,.T.) //"FIM"

//Se teve algum erro, mostra o log de erros.
If lErro
	ProcLogView(,__cProcPrinc)
Endif

Return

/*{Protheus.doc}CT270LOG
Mostra log da rotina de importação
@author Mayara Alves da silva
@since 05/07/2015
@version P12
@project Inovação Controladoria
*/
Function CT270LOG()

ProcLogView(,__cProcPrinc)

Return
/*{Protheus.doc CTBVldCpos
Mostra log da rotina de importação
@author TOTVS
@since 07/01/2018
@version P12
@project Inovação Controladoria
*/
Static Function CTBVldCpos()
Local lRet 		:= .T.

If Select("TMP") > 0

	If !TMP->CTQ_FLAG
		cChvPesq := TMP->(CTQ_CTCPAR+CTQ_CCCPAR+CTQ_ITCPAR+CTQ_CLCPAR)
		cChvPesq += If(_lCpoEnt05,TMP->CTQ_E05CP,"") //Entidade 05
		cChvPesq += If(_lCpoEnt06,TMP->CTQ_E06CP,"") //Entidade 06
		cChvPesq += If(_lCpoEnt07,TMP->CTQ_E07CP,"") //Entidade 07
		cChvPesq += If(_lCpoEnt08,TMP->CTQ_E08CP,"") //Entidade 08
		cChvPesq += If(_lCpoEnt09,TMP->CTQ_E09CP,"") //Entidade 09
			
		If Empty(cChvPesq)			
			MsgAlert(STR0056) //"Preencher as entidades de destino. Não é permitido deixar todas as entidades em branco."
			lRet := .F.
		EndIf
	EndIf

EndIf

Return lRet
/*{Protheus.doc CTBVldChv
Mostra log da rotina de importação
@author TOTVS
@since 07/01/2018
@version P12
@project Inovação Controladoria
*/
Static Function CTBVldChv()
Local nRecVld   := 0
Local aAreaTMP  := {}
Local cChvPesq  := ""
Local lRet 		:= .T.
Local bMontaChv := Nil

If Select("TMP") > 0
 	aAreaTMP := TMP->(GetArea())
	nRecVld  := TMP->(Recno())

	bMontaChv := { || 	TMP->(CTQ_CTCPAR+CTQ_CCCPAR+CTQ_ITCPAR+CTQ_CLCPAR)+;
						If(_lCpoEnt05,TMP->CTQ_E05CP,"")+; //Entidade 05
						If(_lCpoEnt06,TMP->CTQ_E06CP,"")+; //Entidade 06
						If(_lCpoEnt07,TMP->CTQ_E07CP,"")+; //Entidade 07
						If(_lCpoEnt08,TMP->CTQ_E08CP,"")+; //Entidade 08
						If(_lCpoEnt09,TMP->CTQ_E09CP,"");  //Entidade 09												
	}
	
	cChvPesq := Eval(bMontaChv)

	TMP->(dbGoTop())
	While !TMP->(Eof()) .And. lRet
		If !TMP->CTQ_FLAG .And. nRecVld <> TMP->(Recno())
			If cChvPesq == Eval(bMontaChv)
				Help(" ",1,"JAGRAVADO")
				lRet := .F.
			EndIf			
		EndIf
		TMP->(dbSkip())
	EndDo

	RestArea(aAreaTMP)
EndIf

Return lRet
