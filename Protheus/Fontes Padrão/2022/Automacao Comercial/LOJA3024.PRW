#INCLUDE "Loja3024.ch"
#include "Protheus.ch"
#Include 'TopConn.ch'
#include "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ LJ3024Manณ Autor ณ                       ณ Data ณ20/04/2011  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Rotina que define a prioridade da regra de desconto.         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ LJ3024Man                                       	    	    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nil                                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Sigaloja                    			   						ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function LJ3024Man()

Static lNovRegDesc := SuperGetMv("MV_LJRGDES",,.F.) .And. RGVldTable() //Validacao da Nova Regra de Desconto Ativa

Local nX			:= 0                 // Contador
Local aCpoGDa      	:= {"MEJ_PRINUM","MEJ_CODREG","MEJ_DESC","MEJ_ACUMUL","MEJ_DATEDE","MEJ_DATATE"}	// aCpoGDa
Local aAlter       	:= {"MEJ_PRINUM","MEJ_CODREG","MEJ_DESC","MEJ_ACUMUL","MEJ_DATEDE","MEJ_DATATE"}  	// aAlter
Local nSuperior    	:= C(025)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(002)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(150)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(300)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local cLinhaOk     	:= "LJ3024Lok()"  	// Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk      	:=  "AllwaysTrue"   // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              // Campos estaticos na GetDados.
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99
Local cSuperApagar 	:= ""               // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cApagaOk     	:= "AllwaysTrue"    // Funcao executada para validar a exclusao de uma linha do aCols
Local aHeadRG    	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aColRG       	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Local _cQry         := ""				// Query que realizarแ os filtros para retorno dos campos na MsNewGetDados
Local cSeek         := ""               // cSeek
Local cWhile        := ""               // cWhile
Local aNoFields     := {"MEJ_CODREG"}  	// aNoFields
Local aButtons 		:= {}              	// aButtons
Local nOpcA     	:= 0                // nOpcA
Local oSButton1 := NIL				// Botใo Voltar
Local oSButton2 := NIL				// Botใo Avan็ar

// Variaveis Private de uso Generico
Private oGetD                                             // Objeto
Private oOk     := LoadBitmap( GetResources(), "LBOK")   // OK
Private oNo     := LoadBitmap( GetResources(), "LBNO")   // Nao

// Variaveis de controle
Private VISUAL  := .F.				// Variaveis de controle
Private INCLUI  := .F.				// Variaveis de controle
Private ALTERA  := .T.				// Variaveis de controle
Private DELETA  := .F.				// Variaveis de controle
Private nOpc 	:= 7				// Variaveis de controle
Private _aColRG := {}               // Array a ser tratado internamente na MsNewGetDados como aCols    - COPIA -

IF lNovRegDesc == .F.   // valida se parametro da nova regra esta T e se o UPDATE foi aplicado.
	MsgInfo(STR0002)	//"Para utilizar nova regra de desconto verificar MV_LJRGDES e Update"
	Return
ENDIF

LJ3024OrganizaSeq()   /// organiza prioridade.

DEFINE DIALOG oDlg TITLE STR0001 FROM 180,180 TO 580,1090 of oMainWnd PIXEL //"Define a prioridade da regra de Desconto"

If INCLUI
	dbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			Aadd(aHeadRG,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID	,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		Endif
	Next nX
	
	aAux := {}
	For nX := 1 to Len(aCpoGDa)
		If DbSeek(aCpoGDa[nX])
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aAux,.F.)
	Aadd(aColRg,aAux)
Else
	_cQry := "SELECT * FROM " + RetSqlName("MEJ")
	_cQry += " WHERE MEJ_FILIAL = '" + xFilial("MEJ") + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '  order by MEJ_PRINUM"
	
	cSeek  := 	xFilial("MEJ") /// +M->MEI_CODREG
	cWhile :=	"D_E_L_E_T_ = ' '"                ///  +MEJ->MEJ_CODREG
	FillGetDados(nOpc , "MEJ", 1,    cSeek,{||&(cWhile)}, {|| .T. }          , /*aNoFields*/,/*aYesFields*/, /*lOnlyYes*/,_cQry, /*bMontAcols*/, INCLUI,@aHeadRG, @aColRg,/*{||Lj3021Item()}*/ , /*bBeforeCols*/,/*bAfterHeader*/, /*cAliasQry*/)
EndIf
_aColRG := aColRG

		oGetD := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,2,cLinhaOk,cTudoOk,"",aAlter,nFreeze,nMax,,cSuperApagar,cApagaOk,oDlg,@aHeadRG,@aColRg)
		oGetD:bChange := {||LJ3024Lok()}
		oGetD:oBrowse:bLostFOcus := {||LJ3024Lok()}
		oGetD:oBrowse:bEditCol	 := {||LJ3024Lok()}     /// oGetD:oBrowse:nAt
		oGetD:oBrowse:BLDBLCLICK:= { ||LJ3024Prioridade(3,aColRg, oGetD:oBrowse:nAt) }
		oGetD:lcaneditline := .T.

		oSButton2 := SButton():New( 180,395,19,{||LJ3024Prioridade(2)},oDlg,.T.,,)     // botใo Avan็ar
		oSButton1 := SButton():New( 180,425,20,{||LJ3024Prioridade(1)},oDlg,.T.,,)     // botใo Voltar


		ACTIVATE DIALOG oDlg      CENTERED ON INIT EnchoiceBar(oDlg, {||nOpcA := 1 , IIF (LJ3024ValCad(nOpc) ,oDlg:End(),)} ,  {||oDlg:End()} ,.F.,@aButtons,,)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRotina de Gravacao das tabelas                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcA == 1 .AND. nOpc > 2
	Begin Transaction
	GravaPrioridadeRegra()     ////  Altera a prioridade da regra
	End Transaction
EndIf

Return (Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GravaPrioridadeRegra      บAutor  ณ   บ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que altera a prioridade da regra			  		  บฑฑ
ฑฑบ          ณ               											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaPrioridadeRegra(INCLUI)      

Local _nI := 0		// Contador
Local _nPrioridade  := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_PRINUM"})	// Prioridade
Local _nCodReg      := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_CODREG"}) 	// CodReg  

Default INCLUI := .F.	// INCLUI

DbSelectArea("MEJ")
DbSetOrder(2) // MEJ_FILIAL+MEJ_CODREG

For _nI := 1 to Len(oGetD:aCols)
	If dbSeek( xFilial("MEJ") + oGetD:Acols[_nI][_nCodReg])
		RecLock("MEJ",.F.)
		MEJ->MEJ_PRINUM := oGetD:Acols[_nI][_nPrioridade]
		MsUnLock()
	EndIf
Next _nI

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LJ3024LokบAutor  ณ                    บ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a linha do Getdados da prioridade					  บฑฑ
ฑฑบ          ณ               											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ3024Lok()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LJ3024Prioridade   	บAutor ณ   บ Data ณ  04/04/2011	  	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera a prioridade (acima ou abaixo) no Grid			  บฑฑ
ฑฑบ          ณ              											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja                          			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function LJ3024Prioridade(nPriori, aArrayCols, nLinhaCols)

Local _nPrioridade  := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_PRINUM"})  // _nPrioridade
Local _nCodReg      := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_CODREG"})  // _nCodReg
Local _cMEJ_DESC    := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_DESC"})    // _cMEJ_DESC
Local _cMEJ_ACUMUL  := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_ACUMUL"})  // _cMEJ_ACUMUL
Local _dMEJ_DATEDE  := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_DATEDE"})  // _dMEJ_DATEDE
Local _dMEJ_DATATE  := aScan(oGetD:aHeader,{ |x| Alltrim(x[2]) == "MEJ_DATATE"})  // _dMEJ_DATATE

Local _nValorAtual	:= oGetD:Acols[oGetD:oBrowse:nAt][_nPrioridade]                // _nValorAtual
Local _nCodRegAtual := oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]   					// linha selecionada
Local _nCodRegAbaixo:= 0 															// _nCodRegAbaixo
Local _nCodRegAcima := 0 															// _nCodRegAcima
Local _nValor 		:= 0 															// _nValor
Local _nValor2	 	:= 0 															// _nValor2 
Local _cQry         := ""				// Query que realizarแ os filtros para retorno dos campos na MsNewGetDados
Local cSeek         := ""				// cSeek
Local cWhile        := ""				// cWhile
Local aNoFields     := {"MEJ_CODREG"}   // aNoFields
Local aHeadRG    	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aColRG       	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Local _nI 			:= 0
Local nCountFor		:= 0
Local lRet			:= .T.
Local nPosDest 		:= 0				//Pisicao da Prioridade a ser alterada
Local nDif			:= 0				//Guarda diferen็a entre a linha de origem e a inha de destino
Local aLinha 		:= {}				//Armazena as linha entre linha de origem e linha de destino

Default nPriori	 	:= 0				// nPriori 
Default aArrayCols	:= {} 				//Array aCols
Default nLinhaCols	:= 0				//Linha do aCols que foi escolhida

If oGetD:oBrowse:nAt == 1      			// se linha atual igual a UM, nao existe a anterior
	If oGetD:oBrowse:nLen > 1
		_nCodRegAbaixo := oGetD:Acols[oGetD:oBrowse:nAt+1][_nCodReg]
	Else
		_nCodRegAbaixo := oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]
	EndIf
else
	_nCodRegAcima:=oGetD:Acols[oGetD:oBrowse:nAt-1][_nCodReg]   //// Linha abaixo
	
	If oGetD:oBrowse:nAt >1 .AND. oGetD:oBrowse:nAt < Len(oGetD:Acols)
		_nCodRegAbaixo := oGetD:Acols[oGetD:oBrowse:nAt+1][_nCodReg]
	Endif
Endif


dbSelectArea("MEJ")
MEJ->(dbSetOrder(2))    // MEJ_FILIAL+MEJ_CODREG

If nPriori == 1 .AND. oGetD:oBrowse:nAt > 1  //// Sobe uma posi็ao
	
	_nValor := GETDTOVAL(_nValorAtual)-1                      //// StrZero(_nValor2,2)
	_nValor2 := _nValor +1
	
	oGetD:Acols[oGetD:oBrowse:nAt][_nPrioridade] := StrZero(_nValor,2)
	oGetD:Acols[oGetD:oBrowse:nAt-1][_nPrioridade] := StrZero(_nValor2,2)
		
	cCodRegOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]
	cDescPrOrig		:= _nValor
	cDescOrig 		:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_DESC]
	cAcumulOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_ACUMUL]
	cDataDEOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATEDE]
	cDataAteOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATATE]
	
	cCodRegDest 	:= oGetD:Acols[oGetD:oBrowse:nAt-1][_nCodReg]
	cDescPrDest		:= _nValor2
	cDescDest 		:= oGetD:Acols[oGetD:oBrowse:nAt-1][_cMEJ_DESC]
	cAcumulDest 	:= oGetD:Acols[oGetD:oBrowse:nAt-1][_cMEJ_ACUMUL]
	cDataDEDest 	:= oGetD:Acols[oGetD:oBrowse:nAt-1][_dMEJ_DATEDE]
	cDataAteDest 	:= oGetD:Acols[oGetD:oBrowse:nAt-1][_dMEJ_DATATE]
	
	oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]      	:=cCodRegDest
	oGetD:Acols[oGetD:oBrowse:nAt][_nPrioridade]   	:=StrZero(_nValor2,2)
	oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_DESC]		:=cDescDest
	oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_ACUMUL]	:=cAcumulDest
	oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATEDE] 	:=cDataDEDest
	oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATATE]    :=cDataAteDest
	
	oGetD:Acols[oGetD:oBrowse:nAt-1][_nCodReg]      	:=cCodRegOrig
	oGetD:Acols[oGetD:oBrowse:nAt-1][_nPrioridade]   	:=StrZero(_nValor,2)
	oGetD:Acols[oGetD:oBrowse:nAt-1][_cMEJ_DESC]		:=cDescOrig
	oGetD:Acols[oGetD:oBrowse:nAt-1][_cMEJ_ACUMUL] 		:=cAcumulOrig
	oGetD:Acols[oGetD:oBrowse:nAt-1][_dMEJ_DATEDE] 		:=cDataDEOrig
	oGetD:Acols[oGetD:oBrowse:nAt-1][_dMEJ_DATATE]  	:=cDataAteOrig

	// Posiciona o registro no seu contador correspondente
	oGetD:oBrowse:nAt:=oGetD:oBrowse:nAt-1
	oGetD:oBrowse:SetFocus()	
	
Elseif nPriori == 2 .AND. oGetD:oBrowse:nAt < Len(oGetD:Acols)   ///  desce uma posi็ao
	
	_nValor := VAL(_nValorAtual)+1       /// valor atual da prioridade.   // StrZero(_nValor2,2)
	_nValor2 := _nValor -1
	
	oGetD:Acols[oGetD:oBrowse:nAt][_nPrioridade] := StrZero(_nValor,2)
	oGetD:Acols[oGetD:oBrowse:nAt+1][_nPrioridade] := StrZero(_nValor2,2)
	
	cCodRegOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]
	cDescPrOrig		:= _nValor
	cDescOrig 		:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_DESC]
	cAcumulOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_ACUMUL]
	cDataDEOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATEDE]
	cDataAteOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATATE]
	
	cCodRegDest 	:= oGetD:Acols[oGetD:oBrowse:nAt+1][_nCodReg]
	cDescPrDest		:= _nValor2
	cDescDest 		:= oGetD:Acols[oGetD:oBrowse:nAt+1][_cMEJ_DESC]
	cAcumulDest 	:= oGetD:Acols[oGetD:oBrowse:nAt+1][_cMEJ_ACUMUL]
	cDataDEDest 	:= oGetD:Acols[oGetD:oBrowse:nAt+1][_dMEJ_DATEDE]
	cDataAteDest 	:= oGetD:Acols[oGetD:oBrowse:nAt+1][_dMEJ_DATATE]
	
	oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]      	:=cCodRegDest
	oGetD:Acols[oGetD:oBrowse:nAt][_nPrioridade]   	:=StrZero(_nValor2,2)
	oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_DESC]		:=cDescDest
	oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_ACUMUL]	:=cAcumulDest
	oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATEDE] 	:=cDataDEDest
	oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATATE]    :=cDataAteDest
	
	oGetD:Acols[oGetD:oBrowse:nAt+1][_nCodReg]      :=cCodRegOrig
	oGetD:Acols[oGetD:oBrowse:nAt+1][_nPrioridade]  :=StrZero(_nValor,2)
	oGetD:Acols[oGetD:oBrowse:nAt+1][_cMEJ_DESC]	:=cDescOrig
	oGetD:Acols[oGetD:oBrowse:nAt+1][_cMEJ_ACUMUL]	:=cAcumulOrig
	oGetD:Acols[oGetD:oBrowse:nAt+1][_dMEJ_DATEDE] 	:=cDataDEOrig
	oGetD:Acols[oGetD:oBrowse:nAt+1][_dMEJ_DATATE]  :=cDataAteOrig

	// Posiciona o registro no seu contador correspondente
	oGetD:oBrowse:nAt:=oGetD:oBrowse:nAt+1
	oGetD:oBrowse:SetFocus()	

ElseIf nPriori == 3

	nPosDest := LJ3024RetPrior(aArrayCols, nLinhaCols)

	If nPosDest == 0
		//Se retornar .F. da fun็ใo LJ3024RetPrior
		lRet := .F.
	EndIf	

	If lRet
		//Verifica se a diferen็a, entra a linha de origem e destino, ้ maior ou menor
		If (nPosDest < nLinhaCols) 
			nDif := nLinhaCols - nPosDest
		ElseIf 	(nPosDest > nLinhaCols)
			nDif := nPosDest - nLinhaCols 
		Endif		

		//Se a prioridade digitada for menor que a linha clicada
		If (nPosDest < nLinhaCols)

			//Guarda dados da linha que foi escolhida
			cCodRegOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]
			cDescPrOrig		:= _nValor
			cDescOrig 		:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_DESC]
			cAcumulOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_ACUMUL]
			cDataDEOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATEDE]
			cDataAteOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATATE]

			//Guarda em aLInha, as linha que serใo deslocadas para baixo
			For _nI :=  1 to nDif
				cCodRegDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_nCodReg]
				cDescDest 		:= oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_cMEJ_DESC]
				cAcumulDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_cMEJ_ACUMUL]
				cDataDEDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_dMEJ_DATEDE]
				cDataAteDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_dMEJ_DATATE]	

				Aadd(aLinha, {cCodRegDest,cDescDest,cAcumulDest,cDataDEDest,cDataAteDest})

				++nCountFor 

			Next _nI

			// Atualiza linha escolhia, na posi็ใo da prioridade digitada
			oGetD:Acols[oGetD:oBrowse:nAt-nDif][_nCodReg]      	:=cCodRegOrig
			oGetD:Acols[oGetD:oBrowse:nAt-nDif][_cMEJ_DESC]		:=cDescOrig 
			oGetD:Acols[oGetD:oBrowse:nAt-nDif][_cMEJ_ACUMUL]	:=cAcumulOrig
			oGetD:Acols[oGetD:oBrowse:nAt-nDif][_dMEJ_DATEDE] 	:=cDataDEOrig
			oGetD:Acols[oGetD:oBrowse:nAt-nDif][_dMEJ_DATATE]  :=cDataAteOrig

			//Atualiza as linhas que foram armazedas em aLinha
			nCountFor := 1
			For _nI := 1 to Len(aLinha)

				oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_nCodReg]      	:=aLinha[_nI,1]
				oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_cMEJ_DESC]		:=aLinha[_nI,2]
				oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_cMEJ_ACUMUL]	:=aLinha[_nI,3]
				oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_dMEJ_DATEDE] 	:=aLinha[_nI,4]
				oGetD:Acols[(oGetD:oBrowse:nAt-nDif+nCountFor)][_dMEJ_DATATE]   :=aLinha[_nI,5]

				++nCountFor

			Next _nI

			oGetD:oBrowse:nAt:=oGetD:oBrowse:nAt-nDif
			oGetD:oBrowse:SetFocus()				

		ElseIf (nPosDest > nLinhaCols) 	//Se a prioridade digitada for maior que a linha clicada

			//Guarda dados da linha que foi escolhida
			cCodRegOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_nCodReg]
			cDescOrig 		:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_DESC]
			cAcumulOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_cMEJ_ACUMUL]
			cDataDEOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATEDE]
			cDataAteOrig 	:= oGetD:Acols[oGetD:oBrowse:nAt][_dMEJ_DATATE]

			//Guarda em aLInha, as linha que serใo deslocadas para cima			
			nCountFor := 0
			For _nI :=  1 to nDif
				++nCountFor 			
				cCodRegDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_nCodReg]
				cDescDest 		:= oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_cMEJ_DESC]
				cAcumulDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_cMEJ_ACUMUL]
				cDataDEDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_dMEJ_DATEDE]
				cDataAteDest 	:= oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_dMEJ_DATATE]	

				Aadd(aLinha, {cCodRegDest,cDescDest,cAcumulDest,cDataDEDest,cDataAteDest})

			Next _nI

			// Atualiza linha escolhia, na posi็ใo da prioridade digitada
			oGetD:Acols[oGetD:oBrowse:nAt+nDif][_nCodReg]      	:=cCodRegOrig
			oGetD:Acols[oGetD:oBrowse:nAt+nDif][_cMEJ_DESC]		:=cDescOrig
			oGetD:Acols[oGetD:oBrowse:nAt+nDif][_cMEJ_ACUMUL]	:=cAcumulOrig
			oGetD:Acols[oGetD:oBrowse:nAt+nDif][_dMEJ_DATEDE] 	:=cDataDEOrig
			oGetD:Acols[oGetD:oBrowse:nAt+nDif][_dMEJ_DATATE]  :=cDataAteOrig

			//Atualiza as linhas que foram armazedas em aLinha
			nCountFor := 0
			For _nI := 1 to Len(aLinha)
				oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_nCodReg]      	:=aLinha[_nI,1]
				oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_cMEJ_DESC]		:=aLinha[_nI,2]
				oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_cMEJ_ACUMUL]	:=aLinha[_nI,3]
				oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_dMEJ_DATEDE] 	:=aLinha[_nI,4]				
				oGetD:Acols[(oGetD:oBrowse:nAt+nCountFor)][_dMEJ_DATATE]   :=aLinha[_nI,5]

				++nCountFor				

			Next _nI

			oGetD:oBrowse:nAt:=oGetD:oBrowse:nAt+nDif
			oGetD:oBrowse:SetFocus()	
		EndIf	

		oGetD:refresh()

	EndIf

EndIf	

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaRegraบAutor  ณ   				 บ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Organiza a sequencia da prioridade, para nao ter GAP	      บฑฑ
ฑฑบ          ณ  quando excluida uma regra, mantem sempre a sequencia      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja                          			              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ3024OrganizaSeq()

Local nSeq 	:= 1	// nSeq
Local _aSeq :={}	// _aSeq
Local nX 	:= 0	// nX

Begin Transaction

dbSelectArea("MEJ")
MEJ->(DbSetOrder(1))      // MEJ_FILIAL+MEJ_PRINUM+MEJ_CODREG
MEJ->(dbGoTop())

While !MEJ->( Eof() )
	AADD(_aSeq,{MEJ->(RECNO()),StrZero(nSeq,2)})  //
	nSeq := nSeq + 1
	MEJ->( dbSkip() )
End

For nX := 1 to Len(_aSeq)
	dbSelectArea("MEJ")
	MEJ->(dbGoTop())
	MEJ->(dbGoTo(_aSeq[nX][1]))      /// procura o RECNO , mesmo sem Indice.
	RecLock("MEJ",.F.)
	MEJ->MEJ_PRINUM := _aSeq[nX][2]
	MsUnLock()
Next nX

End Transaction       

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJ3024ValCad      บ Autor              บ Data ณ  04/04/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ao de campos antes de gravar.						  บฑฑ
ฑฑบ          ณ           												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja                        			                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ3024ValCad(nOpc) 

Local _lRet    := .T.   // Retorno

Default nOpc := 0 		// nOpc

Return _lRet

/*/{Protheus.doc} LJ3024RetPrior
	Cria tela para informar a Prioridade da Regra de Desconto
	@author Gilmar Costa
	@since 29/07/2020
	@version p12
*/
Function LJ3024RetPrior(aRegraDes, nLin)
Local lConfirma 	:= .F.
Local cNumPrior		:= aRegraDes[nLin,1]
Local cAltPrior		:= Space(Len(aRegraDes[nLin,1]))
Local nTamPrior		:= Len(aRegraDes[nLin,1])
Local nPosRegrDes 	:= 0

	DEFINE MSDIALOG oDlgPgto TITLE STR0003 FROM 0,0 TO 10,41 OF oDlgPgto  //"Altera Prioridade Regra Desconto"
	@ 0.3,1 TO 5,20 OF oDlgPgto
		
	@ 1.5,2     Say STR0004  SIZE 10,1 	//"Da Prioridade: "
	@ 1.3,12.2  MSGET oNumPrior VAR cNumPrior	RIGHT SIZE 20,07 PICTURE PesqPict("MEJ","MEJ_PRINUM") WHEN .F.

	@ 2.8,2     Say STR0006  SIZE 10,1 	//"Para Prioridade: "
	@ 2.3,12.2  MSGET oNumPrior VAR cAltPrior	RIGHT SIZE 20,07 PICTURE PesqPict("MEJ","MEJ_PRINUM") 


	DEFINE SBUTTON FROM 53,095 	TYPE 1 ACTION (lConfirma := .T., oDlgPgto:End()) ENABLE		//Ok
	DEFINE SBUTTON FROM 53,124.1 	TYPE 2 ACTION ( oDlgPgto:End(), Nil) ENABLE				//Cancelar
	ACTIVATE MSDIALOG oDlgPgto CENTERED

	If lConfirma
		cAltPrior := StrZero(Val(cAltPrior),nTamPrior)
		nPosRegrDes  := aScan(aRegraDes,{ |x| Alltrim(x[1]) == cAltPrior})	// Prioridade	
		If nPosRegrDes == 0
			MsgAlert(STR0005) //"Prioridade digitada invalida!!!"
		EndIf				
	EndIf	

Return(nPosRegrDes)
