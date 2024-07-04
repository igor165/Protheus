#INCLUDE "FINA570.CH" 
#INCLUDE "PROTHEUS.CH"

STATIC __lProc := .F.
STATIC __lAuto := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINA570  ³ Autor ³ Leonardo Ruben        ³ Data ³ 19.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recalculo dos Saldos dos Caixinhas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void FINA570(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Localizacoes                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINA570(lAutomato AS LOGICAL, nAutoOpca AS NUMERIC) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cKey, cCondicao, nIndex
Local aArea := GetArea()
Local lPergunte := .F.
Local lPanelFin := IsPanelFin()
Local lFilComp := FWModeAccess("SET",3, cEmpAnt) == "C"
Local lEmpComp := FWModeAccess("SET",1, cEmpAnt) == "C"
LOCAL lReturn := .F.
LOCAL aGetFil := {}
LOCAL nI := 0

DEFAULT lAutomato := .F.
DEFAULT nAutoOpca := 1

__lAuto := lAutomato

Private aSelFil := {}
Private cIndice := NIL
Private cIndex  := NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros do Grupo FIA570 no SX1                          ³
//³ De Caixinha          mv_par01                              ³
//³ A Caixinha           mv_par02                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega funcao Pergunte									   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If xFilial("FIJ") <> xFilial("SET")
	//###Recálculo do caixinha###
    //###O compartilhamento das tabelas FIJ e SET estão diferentes. Acesse o Configurador > Base de Dados e ajuste o compartilhamento.###
    Help("",1,"HELP",STR0022,STR0008,1,0)
	Return
EndIf

SetKey (VK_F12,{|a,b| AcessaPerg("FIA570",.T.)})

IF lPanelFin
    lPergunte := PergInPanel("FIA570",.T.)
ELSE
    lPergunte := Pergunte("FIA570",!__lAuto)
ENDIF

If !lPergunte
	Set Key VK_F12 To
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria indice condicianal                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCondicao := 'ET_CODIGO>="'+mv_par01+'".AND.ET_CODIGO<="'+mv_par02+'"'
cCondicao := cCondicao + '.AND.ET_SITUAC=="0"'	// Somente caixinha com situacao "Aberto"

cIndex  := CriaTrab(Nil,.F.)
cKey    := "ET_FILIAL+ET_CODIGO"
IndRegua("SET",cIndex,cKey,,cCondicao,OemToAnsi(STR0001))  //"Un Momento por favor..."
nIndex  := RetIndex("SET")
dbSelectArea("SET")
dbSetOrder(nIndex+1)
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta tela para chamada da funcao de processamento    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOpca := IF(__lAuto,nAutoOpca,2)
IF EMPTY(__lAuto)
    If lPanelFin  //Chamado pelo Painel Financeiro
        aSays := {}
        AADD(aSays,OemToAnsi( STR0003 ) ) //"Este programa recalcula os saldos dos Caixinhas"
        AADD(aSays,OemToAnsi( STR0004 ) ) //"em aberto, considerando os comprovantes de reembolso"
        AADD(aSays,OemToAnsi( STR0005 ) ) //"e de adiantamento."

        aButtonTxt := {}
        AADD(aButtonTxt,{STR0007,STR0007, {||Pergunte("FIA570",.T. )}}) // Parametros
        FaMyFormBatch(aSays,aButtonTxt,{||nOpca :=1},{||nOpca:=0})
    Else
        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,392 TITLE OemToAnsi(STR0002) PIXEL	 //"Rec lculo dos Saldos dos Caixinhas"
        @ 18, 6 TO 66, 187 LABEL "" OF oDlg  PIXEL
        @ 29, 15 SAY OemToAnsi(STR0003) SIZE 168, 8 OF oDlg PIXEL					 //"Este programa recalcula os saldos dos Caixinhas"
        @ 38, 15 SAY OemToAnsi(STR0004) SIZE 168, 8 OF oDlg PIXEL					 //"em aberto, considerando os comprovantes de reembolso"
        @ 48, 15 SAY OemToAnsi(STR0005) SIZE 168, 8 OF oDlg PIXEL	                 //"e de adiantamento."
        DEFINE SBUTTON FROM 80, 093 TYPE 5 ACTION Pergunte("FIA570",.T.) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 123 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 153 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
        ACTIVATE MSDIALOG oDlg CENTERED
    EndIf
ENDIF
// ---------------------------------------------------------------------------------------------

IF nOpca == 1
    aSelFil := {XFILIAL("SEU",cFilAnt)}
	IF mv_par04 = 1 .and. lFilComp // considera outras filiais se SET compartilhada
        aGetFil := AdmGetFil(.T.,!lEmpComp,"SET",!lEmpComp,!lAutomato/*lHelp*/,!lAutomato/*lExibeTela*/)
        FOR nI := 1 TO LEN(aGetFil)
            IF EMPTY(ASCAN(aSelFil,{|e| e == FWxFilial("SEU",aGetFil[nI]) }))
                AADD(aSelFil,FWxFilial("SEU",aGetFil[nI]))
            ENDIF
        NEXT nI

        lReturn := EMPTY(aSelFil)
    ENDIF
    IF EMPTY(lReturn)
        //"Recálculo dos Saldos dos Caixinhas"###"Efetuando Rec lculo dos Saldos dos Caixinhas..."
        Processa({|lEnd| FA570Process(@lEnd)},STR0002,STR0006,.F.)
    ENDIF
ENDIF

dbSelectArea("SET")
dbClearFil()
RetIndex("SET")

RestArea(aArea)

Set Key VK_F12 To

If lPanelFin  //Chamado pelo Painel Financeiro
	dbSelectArea(FinWindow:cAliasFile)
	ReCreateBrow(FinWindow:cAliasFile,FinWindow)
	INCLUI := .F.
	ALTERA := .F.
EndIf

RestStatic()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FA570Process³ Autor ³ Leonardo Ruben        ³ Data ³19/06/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o recalculo dos saldos dos caixinhas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA570                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA570Process(lEnd)
Local aArea 	:= GetArea()
Local aGrvSET 	:= {}

dbSelectArea("SET")
While !Eof()  // varre o filtro

	If SET->ET_FILIAL <> FWxFilial("SET")
		SET->(dbSkip())
		Loop
	EndIf 

	aGrvSET := Fa570AtuSld(SET->ET_CODIGO)
	If aGrvSET[1][1] >= 0 .And. !aGrvSET[1][2]
		dbSelectArea("SET")
		SET->(RecLock("SET",.F.))		
		SET->ET_SALDO := aGrvSET[1][1]
		SET->(MsUnlock())
		__lProc := .T.
	Endif	
	dbSkip()
EndDo

If !IsBlind() .AND. EMPTY(__lAuto)
	If __lProc
		MsgInfo(STR0010,STR0009)
	Else
		F570Help()
	EndIf
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa570Comp  ³ Autor ³ Leonardo Ruben        ³ Data ³19/06/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor total dos comprovantes de um caixinha      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA570                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa570Comp(cCaixa As Character) As Array
Local nTotComp 	As Numeric
Local nTotRep 	As Numeric
Local cSeqCxa	As Character
Local lF570Cal 	As Logical

Local lRepCxV	As Logical   // Verifica se trabalha com reposicao variavel
Local nSldCx	As Numeric
Local nSldAnt	As Numeric
Local nSldVlr	As Numeric
Local lF570SdCx As Logical
Local lF570Rec  As Logical
Local cQuery    As Character
Local cAliasTmp As Character
Local cSEUFil	As Character
Local cAliasWrk As Character
Local lRegIni   As Logical // Identifica primeiro registro da tabela
Local nX 		As Numeric
Local lFINCTAL	As Logical	// Despesa Necessita ser aprovada
Local lFJIMCFIL As Logical
Local cFilFIJ	As Character
Local cFilComp  As Character
Local lGrava    As Logical
Local lFirst	As Logical
Local aGrvSld   As Array
Local aGrvSET   As Array
Local aAreaSEU  As Array
Local aArea     AS Array
Local nZ 		As Numeric
Local cAliasFIJ As Character
Local lLimpaFIJ As Logical
Local nPos		As Numeric

nTotComp 	:= 0
nTotRep 	:= 0
lF570Cal 	:= ExistBlock("F570CAL")
lRepCxV		:= GetNewPar("MV_RPCXMN","2")== "1" .And. ExistBlock("F550VREP")   // Verifica se trabalha com reposicao variavel
nSldCx		:= 0
nSldAnt		:= 0
nSldVlr		:= 0
lF570SdCx 	:= ExistBlock("F570SDCX")
lF570Rec  	:= ExistBlock("F570REC")
cQuery      := ""
cAliasTmp   := ""
cSEUFil		:= ""
cAliasWrk 	:= ""
lRegIni  	:= .t. // Identifica primeiro registro da tabela
nX 			:= 1
lFINCTAL	:= SuperGetMV("MV_FINCTAL", .T., "1") == "2"	// Despesa Necessita ser aprovada
lFJIMCFIL 	:= FWMODEACCESS("FIJ",3) == 'C'
cFilFIJ		:= xFilial( "FIJ" )
cFilComp  	:= Space(Len(xFilial("SET")))
lGrava    	:= .F.
lLimpaFIJ 	:= .F.
aGrvSld   	:= {}
aGrvSET   	:= {}
aAreaSEU  	:= {}
aArea       := {}
nZ 			:= 1
cAliasFIJ 	:= ""
lFirst		:= .T.
nPos		:= 0

Private lFxMultSld := FXMultSld() //Controla saldo bancario multiplas naturezas, verifica a existencia dos campos A6_MOEDA e a tabela FIJ (Paises BRA|PER|BOL)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona-se no caixinha                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SET")
dbSetOrder(1)
dbSeek( xFilial()+cCaixa)
dUltRep := SET->ET_ULTREP
nSldAnt	:= SET->ET_SALANT
nSldVlr := SET->ET_VALOR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna a sequencia atual do caixinha                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeqCxa := Fa570SeqAtu( cCaixa)


If Type( "aSelFil" ) <> "A"
	aSelFil := {xFilial( "SEU" , cFilAnt ) }
EndIf

For nX := 1 To Len(aSelFil)
	cSEUFil += "'" + FWxFilial("SEU",aSelFil[nX] ) + "',"
Next Nx
cSEUFil := SubStr(cSEUFil,1,Len(cSEUFil)-1)
cQuery := " SELECT EU_FILIAL, EU_TIPO, EU_DTDIGIT, EU_CAIXA, EU_SEQCXA, EU_NROADIA, EU_VALOR, EU_STATUS, EU_CODAPRO, R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName( "SEU" )
cQuery += " WHERE EU_FILIAL IN ("+cSEUFil+") "
cQuery += " AND EU_CAIXA = '"+cCaixa+"' "
cQuery += " AND EU_SEQCXA < '"+cSeqCxa+"' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY EU_FILIAL, EU_SEQCXA, R_E_C_N_O_ "
cQuery := ChangeQuery(cQuery)
cAliasWrk := GetNextAlias()
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasWrk, .T., .T.)
													
cAliasTmp := cAliasWrk

lFirst	:= .T.

While (cAliasTmp)->(!Eof())

	If lFxMultSld
		If lFJIMCFIL 
			cFilFIJ := xFilial('FIJ', (cAliasTmp)->EU_FILIAL)
		EndIf

		If lFJIMCFIL .and. lGrava

			If (nPos := Ascan(aGrvSld,{|x| x[1] + x[2]== cFilComp + (cAliasTmp)->EU_CAIXA })) = 0
				AADD(aGrvSld,{cFilComp,(cAliasTmp)->EU_CAIXA,nTotRep})
			Else
				aGrvSld[nPos][3] += nTotRep
			EndIf
			nSldCx := 0
			lGrava := .F.

		EndIf 	

		If ( cFilFIJ <> cFilComp .Or. Empty(AllTrim(cFilComp)) ) .And. lFirst
			//**************************************************
			// Deleta todas os Movimentos de Saldo do Caixinha *
			//**************************************************
			lFirst	:= .F.
			lLimpaFIJ := .T.

			aAreaSEU := (cAliasTmp)->(GetArea())
	
			cQuery := " SELECT FIJ_FILIAL, FIJ_CODCX, FIJ_DATA, R_E_C_N_O_ "
			cQuery += " FROM " + RetSqlName( "FIJ" )
			cQuery += " WHERE "
			cQuery += "FIJ_FILIAL = '" + cFilFIJ + "' AND "
			cQuery += "FIJ_CODCX = '" + cCaixa + "' AND "
			If MV_PAR03 = 1
				cQuery +=  "FIJ_DATA >= '" + DtoS(dUltRep) + "' AND "
			EndIf
			cQuery += "D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			cAliasFIJ := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasFIJ, .T., .T.)

			(cAliasFIJ)->( dbGoTop() )

			dbSelectArea("FIJ")

			While (cAliasFIJ)->(!Eof())
				FIJ->( dbGoTo((cAliasFIJ)-> R_E_C_N_O_))
				FIJ->(RecLock("FIJ",.F.))
				FIJ->FIJ_SALDO := 0
				FIJ->(MsUnlock())
				(cAliasFIJ)->( dbSkip() )
			EndDo

			(cAliasFIJ)->( dbCloseArea() )
			cFilComp := cFilFIJ

			RestArea(aAreaSEU)
		EndIf
	EndIf

	If (cAliasTmp)->EU_TIPO == "10" .or. (cAliasTmp)->EU_TIPO == "92"

		nTotRep := (cAliasTmp)->EU_VALOR
		 
		If lFxMultSld
			// Cria saldo inicial de reposicao
			If lRepCxV						
				If lRegIni
					AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)) , (cAliasTmp)->EU_VALOR, .T. , cFilFIJ )
				Else
					AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)) , (cAliasTmp)->EU_VALOR, .F. , cFilFIJ )
				EndIf
			Else		
				AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)) , (cAliasTmp)->EU_VALOR , lRegIni , cFilFIJ )
			EndIf
		EndIf
					
		lRegIni := .F.
		lGrava 	:= .T.
		nSldCx += nTotRep
		(cAliasTmp)->( dbSkip() )
		Loop
	ElseIf (cAliasTmp)->EU_TIPO == "11"


		// Zera Saldo do Caixinha  
		If lFxMultSld
			AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)), (cAliasTmp)->EU_VALOR * (-1) , .F. )
		EndIf
		nTotComp += (cAliasTmp)->EU_VALOR
		(cAliasTmp)->(dbSkip())
		Loop
	ElseIf lFINCTAL .AND. (!Empty((cAliasTmp)->EU_CODAPRO) .AND. (cAliasTmp)->EU_STATUS $ "01|02")
		// Despesa ainda não aprovada
		(cAliasTmp)->(dbSkip())
		Loop
	ElseIf (cAliasTmp)->EU_TIPO == "00" .AND. !Empty((cAliasTmp)->EU_NROADIA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o tipo for despesa e representar prestacao de contas³
		//³de adiantamento, devo ignorar pois neste caso somente  ³
		//³os movimentos do tipo 01(Adiantamento)  e 02(devolucao ³
		//³de adiantamento devem ser considerados.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(cAliasTmp)->(dbSkip())
		Loop	
	ElseIf (cAliasTmp)->EU_TIPO == "02" 

		//*************************************
		// Reposicao de saldo do adiantamento *
		//*************************************	
		aArea := GetArea()
		SEU->(dbSetOrder(1))
		dbSelectArea("SEU")			

		If SEU->(dbSeek(xFilial("SEU")+(cAliasTmp)->EU_NROADIA)) //Posiciona na Despesa 			
			If (SEU->(dbSeek(xFilial("SEU")+SEU->EU_NROADIA)) .And. SEU->EU_TIPO <> "01") .or. (Empty(SEU->EU_NROADIA) .AND. SEU->EU_TIPO <> "01") //Caso for despesa de prestação de contas, Posiciona no Adiantamento, caso exista
				If lFxMultSld
					AtuSalCxa(cCaixa, IIf(cAliasTmp == "TMPSEU", (cAliasTmp)->EU_DTDIGIT, StoD((cAliasTmp)->EU_DTDIGIT)), (cAliasTmp)->EU_VALOR , , cFilFIJ )					
				EndIf
				nTotComp -= (cAliasTmp)->EU_VALOR
			Endif
		EndIf
		RestArea(aArea)		
		(cAliasTmp)->(dbSkip())
		Loop
	ElseIf (cAliasTmp)->EU_TIPO>="90"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reposicoes canceladas, aguardando autorizacao, cheques ³
		//³aguardando compensacao etc.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(cAliasTmp)->(dbSkip())
		Loop
	EndIf

	//***************************
	// Despesas ou adiantamento *
	//***************************
	If lFxMultSld
		AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)) , (cAliasTmp)->EU_VALOR*(-1) , , cFilFIJ )
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Aqui estao sendo somados   :                           ³
	//³- Gastos/despesas em aberto (tipo 00)                  ³
	//³- Adiantamentos fechados/rendidos (tipo 01)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotComp += (cAliasTmp)->EU_VALOR

	(cAliasTmp)->(dbSkip())
EndDo
If Select(cAliasTmp)>0
	(cAliasTmp)->(dbclosearea())
EndIf

cQuery := " SELECT EU_FILIAL, EU_TIPO, EU_DTDIGIT, EU_CAIXA, EU_SEQCXA, EU_NROADIA, EU_VALOR, EU_BAIXA, EU_STATUS, EU_CODAPRO, R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName( "SEU" )
cQuery += " WHERE EU_FILIAL IN ("+cSEUFil+") "
cQuery += " AND EU_CAIXA = '"+cCaixa+"' "
cQuery += " AND EU_SEQCXA >= '"+cSeqCxa+"' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY EU_FILIAL, EU_SEQCXA, EU_DTDIGIT, R_E_C_N_O_ "
cQuery := ChangeQuery(cQuery)
cAliasWrk := GetNextAlias()
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasWrk, .T., .T.)

cAliasTmp := cAliasWrk

lFirst	:= .T.

While (cAliasTmp)->(!Eof())

	//Ponto de entrada para desconsiderar alguns movimentos para a recomposicao do saldo
	If lF570SdCx
		If ExecBlock("F570SDCX",.F.,.F.,{cAliasTmp})
			(cAliasTmp)->(dbSkip())
			Loop
		EndIf
	EndIf

	If lFJIMCFIL
		cFilFIJ := xFilial('FIJ', (cAliasTmp)->EU_FILIAL)
	Else
		cFilFIJ := xFilial('FIJ')
	EndIf

	If lFJIMCFIL .and. lGrava 

		If (nPos := Ascan(aGrvSld,{|x| x[1] + x[2]== cFilComp + (cAliasTmp)->EU_CAIXA })) = 0
			AADD(aGrvSld,{cFilComp,(cAliasTmp)->EU_CAIXA,nTotRep})
		Else
			aGrvSld[nPos][3] += nTotRep
		EndIf

		nSldCx := 0
		lGrava := .F.
	EndIf

	If  !lLimpaFIJ .and. ( cFilFIJ <> cFilComp .Or. Empty(AllTrim(cFilComp)) ) .And. lFirst
		//**************************************************
		// Deleta todas os Movimentos de Saldo do Caixinha *
		//**************************************************
		lFirst	:= .F.

		aAreaSEU := (cAliasTmp)->(GetArea())

		cQuery := " SELECT FIJ_FILIAL, FIJ_CODCX, FIJ_DATA, R_E_C_N_O_ "
		cQuery += " FROM " + RetSqlName( "FIJ" )
		cQuery += " WHERE "
		cQuery += "FIJ_FILIAL = '" + cFilFIJ + "' AND "
		cQuery += "FIJ_CODCX = '" + cCaixa + "' AND "
		If MV_PAR03 = 1
			cQuery +=  "FIJ_DATA >= '" + DtoS(dUltRep) + "' AND "
		EndIf
		cQuery += "D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		cAliasFIJ := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasFIJ, .T., .T.)

		(cAliasFIJ)->( dbGoTop() )

		dbSelectArea("FIJ")

		While (cAliasFIJ)->(!Eof())
			FIJ->( dbGoTo((cAliasFIJ)-> R_E_C_N_O_))
			FIJ->(RecLock("FIJ",.F.))
			FIJ->FIJ_SALDO := 0
			FIJ->(MsUnlock())
			(cAliasFIJ)->( dbSkip() )
		EndDo

		(cAliasFIJ)->( dbCloseArea() )
		cFilComp := cFilFIJ

		RestArea(aAreaSEU)
	EndIf

	If (cAliasTmp)->EU_TIPO == "10" .or. (cAliasTmp)->EU_TIPO == "92"
		//Reposicao incial da ultima sequencia (abertura)   
		If lRepCxV
			nTotRep := (cAliasTmp)->EU_VALOR
			If lF570Rec
				nTotRep := ExecBlock( "F570REC", .f., .f., { (cAliasTmp)->EU_VALOR, SET->ET_SALANT, SET->ET_VALOR } )
			EndIf
			If lFxMultSld
				// Cria saldo inicial de reposicao 
				AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)) , nTotRep + SET->ET_SALANT, .T. , cFilFIJ)
			EndIf
		Else
			nTotRep := (cAliasTmp)->EU_VALOR
			If lF570Rec
				nTotRep := ExecBlock( "F570REC", .f., .f., { (cAliasTmp)->EU_VALOR, SET->ET_SALANT, SET->ET_VALOR } )
			EndIf
			If lFxMultSld
				// Cria saldo inicial de reposicao 
				AtuSalCxa( cCaixa, SET->ET_ULTREP , nTotRep , .F., cFilFIJ )
			EndIf
		EndIf

		lGrava :=  .T.
		nSldCx += nTotRep
		(cAliasTmp)->(dbSkip())
		Loop
	ElseIf (cAliasTmp)->EU_TIPO == "11"

		If lFxMultSld
			// Zera Saldo do Caixinha  
			AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)), (cAliasTmp)->EU_VALOR * (-1) , .T. )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³fechou-se a sequencia (caixa fechado, pois esta   ³
		//³eh a ultimia sequencia). Saldo zero.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFxMultSld
			nTotRep -= (cAliasTmp)->EU_VALOR
		EndIf
		
		nTotComp += (cAliasTmp)->EU_VALOR
		(cAliasTmp)->(dbSkip())
		Loop
	ElseIf lFINCTAL .AND. (!Empty((cAliasTmp)->EU_CODAPRO) .AND. (cAliasTmp)->EU_STATUS $ "01|02")
		// Despesa ainda não aprovada
		(cAliasTmp)->(dbSkip())
		Loop
	ElseIf (cAliasTmp)->EU_TIPO == "00" .AND. !Empty((cAliasTmp)->EU_NROADIA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o tipo for despesa e representar prestacao de contas³
		//³de adiantamento, devo ignorar pois neste caso somente  ³
		//³os movimentos do tipo 01(Adiantamento)  e 02(devolucao ³
		//³de adiantamento devem ser considerados.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(cAliasTmp)->(dbSkip())
		Loop	
	ElseIf (cAliasTmp)->EU_TIPO == "02" 
        IF (cPaisLoc == "BRA")
            (cAliasTmp)->(dbSkip())
            Loop	
        ENDIF
		aArea := GetArea()
		SEU->(dbSetOrder(1))
		dbSelectArea("SEU")			

		If SEU->(dbSeek(xFilial("SEU")+(cAliasTmp)->EU_NROADIA)) //Posiciona na Despesa 			
			If cPaisLoc == "ARG" .And. (SEU->EU_TIPO == "01" .Or. (Empty(SEU->EU_NROADIA) .AND. SEU->EU_TIPO <> "01"))
				nTotComp -= (cAliasTmp)->EU_VALOR
			Else
				If ((SEU->(dbSeek(xFilial("SEU")+SEU->EU_NROADIA)) .And. SEU->EU_TIPO <> "01") .or. (Empty(SEU->EU_NROADIA) .AND. SEU->EU_TIPO <> "01")) .And. IIf(cPaisLoc == "ARG", SEU->(!Eof()), .T.) //Caso for despesa de prestação de contas, Posiciona no Adiantamento, caso exista
					If lFxMultSld

						//Reposicao de saldo do adiantamento

						AtuSalCxa(cCaixa, IIf(cAliasTmp == "TMPSEU", (cAliasTmp)->EU_DTDIGIT, StoD((cAliasTmp)->EU_DTDIGIT)), (cAliasTmp)->EU_VALOR , , cFilFIJ )	

						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o tipo for devolucao de adiantamento, o mesmo foi   ³
						//³rendido/baixado, logo considero o quanto foi devolvido ³
						//³como reposicao para o caixinha. Desconto do total de   ³
						//³comprovantes (pois considerei o adiantamento inicial)  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nTotComp -= (cAliasTmp)->EU_VALOR

					ElseIf cPaisLoc <> "BRA"
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o tipo for devolucao de adiantamento, o mesmo foi   ³
						//³rendido/baixado, logo considero o quanto foi devolvido ³
						//³como reposicao para o caixinha. Desconto do total de   ³
						//³comprovantes (pois considerei o adiantamento inicial)  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nTotComp -= (cAliasTmp)->EU_VALOR
					EndIf
				Endif
			EndIf
		EndIf
		RestArea(aArea)		
		(cAliasTmp)->(dbSkip())
		Loop
	ElseIf (cAliasTmp)->EU_TIPO>="90"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reposicoes canceladas, aguardando autorizacao, cheques ³
		//³aguardando compensacao etc.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		(cAliasTmp)->(dbSkip())
		Loop
	EndIf

	If lFxMultSld
		//***************************
		// Despesas ou adiantamento *
		//***************************
		AtuSalCxa( cCaixa, IIf(cAliasTmp == "TMPSEU",(cAliasTmp)->EU_DTDIGIT,StoD((cAliasTmp)->EU_DTDIGIT)) , (cAliasTmp)->EU_VALOR*(-1) , , cFilFIJ )
	EndIf

	//Aqui estao sendo somados: Gastos/despesas em aberto (tipo 00), Adiantamentos fechados/rendidos (tipo 01)
	nTotComp += (cAliasTmp)->EU_VALOR
	//Ponto de entrada F570CAL
	//Ponto de entrada utilizado para tratamentos diferenciados do calculo
	//do saldo do caixinha
   	If lF570Cal
		nTotComp := ExecBlock("F570CAL",.F.,.F.,{nTotComp})
	EndIf

	(cAliasTmp)->(dbSkip())
EndDo

//Ponto de entrada utilizado para tratamentos diferenciados do calculo
//do saldo do caixinha
If ExistBlock("FA570SCX")
	nTotComp := ExecBlock("FA570SCX",.F.,.F.,{nTotComp})
EndIf

If  Select(cAliasTmp) > 0 .and. lFJIMCFIL .and. Len( aGrvSld ) > 0
	If (nPos := Ascan(aGrvSld,{|x| x[1] + x[2]== cFilComp + cCaixa })) > 0
		aGrvSld[nPos][3] -= nTotComp
		nSldCx := aGrvSld[nPos][3]
	EndIf
Else
	nSldCx -= nTotComp
EndIf

//**********************************************************************************************************
// Para ambiente com nivel de compartilhamento entre filiais CEE, realizo a atualização do saldo neste momento.*
// Pois a rotina não estava preparada para tratar este nivel de compartilhamento.*
//**********************************************************************************************************
If lFJIMCFIL .and.Len( aGrvSld ) > 0
	dbSelectArea("SET")
	SET->(dbSetOrder(1))
	For nZ := 1 To Len(aGrvSld)
		SET->(dbSeek(aGrvSld[nZ][1] + aGrvSld[nZ][2]))
		RecLock("SET",.F.)
		SET->ET_SALDO := aGrvSld[nZ][3]
		SET->(MsUnlock())
		__lProc		:= .T.
	Next nZ
EndIf 
	
If Select(cAliasTmp) > 0
	(cAliasTmp)->(dbclosearea())
EndIf

AADD(aGrvSET,{nSldCx,lFJIMCFIL})	

Return aGrvSET

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa570SeqAtu³ Autor ³ Leonardo Ruben        ³ Data ³03/07/01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a sequencia atual do caixinha                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa570SeqAtu( cCaixa)
Local cSeqAtu := ""
Local cFilSEU := ""
Local aAreaSEU 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona-se no ultimo registro da ultima sequencia          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEU")
aAreaSEU := SEU->(GetArea())
dbSetOrder(5)  // FILIAL+CAIXA+SEQCXA+NUMERO
DbSeek(xFilial()+cCaixa+"999999",.T.)
If !Found()
	dbSkip(-1)
EndIf
If Bof() .or. cCaixa <> EU_CAIXA  // nao ha registros para esse caixinha
	cSeqAtu := "000001"
Else
	If ExistBlock("FA550VERIF",.T.) .And. Fa550Verif()
		cFilSEU:=xFilial("SEU")
		While SEU->EU_TIPO>="90" .And. SEU->EU_FILIAL==cFilSEU .And. SEU->EU_CAIXA==cCaixa .And. !SEU->(Bof())
			SEU->(DbSkip(-1))
		Enddo
	Endif
	cSeqAtu := EU_SEQCXA
EndIf

SEU->(RestArea(aAreaSEU))

Return cSeqAtu

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa570AtuSld³ Autor ³ Leonardo Ruben        ³ Data ³19/06/00³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o valor do saldo do caixinha                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA570                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa570AtuSld(cCaixa)
Local aGrvSET
Local aArea := GetArea()

aGrvSET := Fa570Comp(cCaixa)

RestArea(aArea)
Return aGrvSET

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F570VldFor ºAutor  ³Clovis Magenta     º Data ³  08/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de validação dos campos EU_FORNECE e EU_LOJA no SX3 º±±
±±º          ³ // nopc = 1 --> fornecedor											  º±±
±±º          ³ // nopc = 2 --> loja                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function F570VldFor(nOpc)
Local lOk := .T.
Local nPosForn := 0
Local nPosLoja := 0
Local lIsGetD  := Type("aHeader")=="A"
Local cValor	:= &(Readvar())

DEFAULT nOpc := 1

If lIsGetD
	nPosForn := aScan(aHeader,{|x| Alltrim(x[2])=="EU_FORNECE"})
	nPosLoja := aScan(aHeader,{|x| Alltrim(x[2])=="EU_LOJA"})

	If nOpc == 1
		lOk := IIF(!EMPTY(aCols[n][nPosLoja]), (Vazio() .or. ExistCpo('SA2', cValor+aCols[n][nPosLoja])),.T.)
	Else
		lOk := IIF(!EMPTY(aCols[n][nPosForn]), ExistCpo('SA2', aCols[n][nPosForn]+cValor),.T.)
	Endif

Else

	If nOpc == 1
			lOk := IIF(!EMPTY(M->EU_LOJA), (Vazio() .or. ExistCpo('SA2', M->EU_FORNECE+M->EU_LOJA)), (Vazio() .OR. ExistCpo('SA2', M->EU_FORNECE)) )
	Else
		lOk := IIF(!EMPTY(M->EU_FORNECE),ExistCpo('SA2', M->EU_FORNECE+M->EU_LOJA),.T.)
	Endif

Endif

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtuSldAnt ºAutor  ³Daniel Mendes       º Data ³  08/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza os sados conforme valores enviados                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA570                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuSldAnt( cCaixa , nValor , lAmbos , lTodasFil , aFiliais )
Local aArea   := {}
Local cQuery  := ""
Local cSETFil := ""
Local nX      := 0

aArea := GetArea()

If lTodasFil
	For nX := 1 To Len( aFiliais )
		cSETFil += "'" + FWxFilial( "SET" , aFiliais[ nX ] ) + "',"
	Next nX

	cSETFil := SubStr( cSETFil , 1 , Len( cSETFil ) - 1 )
	cQuery  := " UPDATE " + RetSQLName( "SET" )
	cQuery  += " SET ET_SALANT = " + cValToChar( nValor )

	If lAmbos
		cQuery  += " , ET_SALDO  = " + cValToChar( nValor )
	EndIf

	cQuery  += " WHERE "
	cQuery  += " ET_FILIAL IN ( " + cSETFil + ") AND "
	cQuery  += " ET_CODIGO = '" + cCaixa + "' AND "
	cQuery  += " D_E_L_E_T_ = ' ' "

	TCSQLExec( cQuery )
Else
	If cPaisLoc == "ARG" .And. SEU->EU_STATUS = "03" 
		If RecLock( "SET" , .F. )
			SET->ET_SALANT := SET->ET_SALDO
			If lAmbos
				SET->ET_SALDO  := SET->ET_SALDO + nValor
			EndIf
			SET->( MsUnLock() )
		EndIf
	Else
		If RecLock( "SET" , .F. )
			If lAmbos
				SET->ET_SALDO  := nValor
			EndIf
			SET->ET_SALANT := nValor
			SET->( MsUnLock() )
			__lProc		:= .T.
		EndIf
	Endif
EndIf

RestArea( aArea )
aSize( aArea , 0 )
aArea := Nil

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  RestStatic ºAutor  ³Rodrigo Oliveira    º Data ³  15/01/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Restaura os valores das variáveis Statics                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA570                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RestStatic()

	__lProc	:=	.F.

Return Nil

/*/{Protheus.doc} F570Help
	Montagem do HELP no processo de recalculo do caixinha
	@type  Static Function
	@author Vitor Duca
	@since 15/12/2020
	@version 1.0
	@return 
/*/	
Static Function F570Help()
	Local cMsg 		AS Character
	Local cTitulo 	AS Character
	Local aBtLinks 	AS Array

	cTitulo  := STR0022//"Recálculo do caixinha"
	aBtLinks := ARRAY(2,2)

	cMsg := "<font size='6' color='#0c9abe'><b>"+STR0023+"</b></font><br/><br/>"//HELP - NOPROCESS

	cMsg += "<font size='4' color='#444'><b>"+STR0013+"</b></font><br/>"//"Ocorrência"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
	cMsg += "<font size='4' color='#666'>"+STR0014+"<br/>"//"Não foi possivel efetuar o recalculo do caixinha."                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
	cMsg += "</font><br/><br/>"

	cMsg += "<font size='4' color='#444'><b>"+STR0015+"</b></font>"//"Possiveis causas"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	cMsg += "<ul>" 
    cMsg +=   "<font size='4' color='#666'><li>"+STR0016+"</li></font>" //"Não foi encontrado registros nas tabelas SET e SEU. "                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    cMsg +=   "<font size='4' color='#666'><li>"+STR0017+"</li></font>" //"O saldo do caixinha não pode ser negativo."                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    cMsg +=   "<font size='4' color='#666'><li>"+STR0018+"</li></font>"  //"A rotina não efetua o recálculo de saldo dos caixinhas com a situação de fechado."                                                                                                                                                                                                                                                                                                                                                                                                                                 
    cMsg += "</ul><br/><br/>"

	cMsg += "<font size='4' color='#444'><b>"+STR0019+"</b></font>"//"Para maiores informações acesse:"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	cMsg += "<br/>"

	aBtLinks[1,1] := STR0020//"Recálculo do caixinha - FINA570"
	aBtLinks[1,2] := STR0021//"https://tdn.totvs.com/x/TwB0Ig"

	FinHelp(cTitulo, cMsg, aBtLinks, 325, 600)
Return	
