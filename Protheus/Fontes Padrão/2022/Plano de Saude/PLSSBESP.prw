#INCLUDE "PLSSBESP.CH"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSSBESP   ³ Autor ³ Romulo Ferrari    ³ Data ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe as subespecialidades de acordo com a especialidade   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ F3                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/             
Function PLSSBESP(cDado,cCodEsp,cCampo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := 1, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aSubEsp  := {}
LOCAL nInd
Local nIteMar
Local cBak := cDado

DEFAULT cCampo  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ coloca virgula no comeco (caso tenha inicializador padrao)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDado  := AllTrim(cDado)
if subs(cDado,len(cDado),1) != "," .AND. cDado != ""
	cDado += ","
endif

cSQL := " SELECT  BFN_CODSUB, BFN_DESCRI FROM "+RetSQLName("BFN")
cSQL += "  WHERE BFN_FILIAL = '"+xFilial("BFN")+"' "
cSQL += "    AND BFN_CODESP = '"+cCodEsp+"' "
cSQL += "    AND D_E_L_E_T_ = ' ' "

PLSQuery(cSQL,"TrbBFN")

While ! TrbBFN->(Eof())
	
      aadd(aSubEsp,{TrbBFN->BFN_CODSUB,TrbBFN->BFN_DESCRI,If(Alltrim(TrbBFN->BFN_CODSUB)$cDado,.T.,.F.)})
	
	TRBBFN->(DbSkip())
Enddo
TrbBFN->(DbCloseArea())
DbSelectArea("BA1")

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010, 010 TO 35,100 OF GetWndDefault() //"Sub Especialidades" 

@ 020,012 SAY oSay PROMPT STR0002 SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione a(s) subespecialidade(s)"

oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oCritica:AddColumn(TcColumn():New(" ",{ || IF(aSubEsp[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oCritica:AddColumn(TcColumn():New(STR0003,{ || OemToAnsi(aSubEsp[oCritica:nAt,1]) },; //"Codigo"
"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:AddColumn(TcColumn():New(STR0004,{ || OemToAnsi(aSubEsp[oCritica:nAt,2]) },; //"Descricao"
"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:SetArray(aSubEsp)
oCritica:bLDblClick := { || aSubEsp[oCritica:nAt,3] := Eval( { || nIteMar := 0, aEval(aSubEsp, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 30 .Or. aSubEsp[oCritica:nAt, 3],IF(aSubEsp[oCritica:nAt,3],.F.,.T.),.F.) })}

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == 1
	
	cDado := ""
	For nInd := 1 To Len(aSubEsp)
		If aSubEsp[nInd,3]
			cDado += aSubEsp[nInd,1]+","
		Endif
	Next
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ tira a virgula do final                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if subs(cDado,len(cDado),1) == ","
	cDado := subs(cDado,1,len(cDado)-1)
endif

if !empty(cCampo)
	cCampo  := "M->"+cCampo
	&cCampo := cDado
endif

Return(cDado)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSACRED   ³ Autor ³ Jean Schulz       ³ Data ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe todas as acreditacoes disponiveis                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ F3                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/             
Function PLSACRED(cDado,cCampo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := 1, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aSubEsp  := {}
LOCAL nInd, nI
Local nIteMar
Local cBak := cDado

DEFAULT cCampo  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ coloca virgula no comeco (caso tenha inicializador padrao)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDado  := AllTrim(cDado)
if subs(cDado,len(cDado),1) != "," .AND. cDado != ""
	cDado += ","
endif 

aSX5    := FWGetSX5("TG")
nLenSX5 := LEN(aSX5) 

FOR nI := 1 TO nLenSX5	
	aadd(aSubEsp,{aSX5[nI][3],aSX5[nI][4],If(Alltrim(aSX5[nI][3])$cDado,.T.,.F.)})	
NEXT

DbSelectArea("BA1")

DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010, 010 TO 35,100 OF GetWndDefault() //"Acreditação" 

@ 020,012 SAY oSay PROMPT STR0002 SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Escolha quais aplicam-se a este credenciado"

oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oCritica:AddColumn(TcColumn():New(" ",{ || IF(aSubEsp[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oCritica:AddColumn(TcColumn():New(STR0003,{ || OemToAnsi(aSubEsp[oCritica:nAt,1]) },; //"Codigo"
"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:AddColumn(TcColumn():New(STR0004,{ || OemToAnsi(aSubEsp[oCritica:nAt,2]) },; //"Descricao"
"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:SetArray(aSubEsp)
oCritica:bLDblClick := { || aSubEsp[oCritica:nAt,3] := Eval( { || nIteMar := 0, aEval(aSubEsp, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 30 .Or. aSubEsp[oCritica:nAt, 3],IF(aSubEsp[oCritica:nAt,3],.F.,.T.),.F.) })}

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == 1
	
	cDado := ""
	For nInd := 1 To Len(aSubEsp)
		If aSubEsp[nInd,3]
			cDado += aSubEsp[nInd,1]+","
		Endif
	Next
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ tira a virgula do final                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if subs(cDado,len(cDado),1) == ","
	cDado := subs(cDado,1,len(cDado)-1)
endif

if !empty(cCampo)
	cCampo  := "M->"+cCampo
	&cCampo := cDado
endif

Return(cDado)