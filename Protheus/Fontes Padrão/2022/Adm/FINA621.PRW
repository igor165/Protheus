#Include "PROTHEUS.CH"
#Include "FINA621.CH"

//Tratamento gestao corporativa
Static lFWCodFil := .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fina621  ³ Autor ³ 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Incluir solicitacoes de transferencia de debito            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fina621()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION Fina621(aAuto,nPosArotina)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local lRet		:= .T.
Private aRotina := MenuDef()

//inclusao para tratamento de gestao corporativa
Private lGestao := lFWCodFil .and. Len(SE6->E6_FILIAL) > 2


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotAuto	:= aAuto
PRIVATE cCadastro	:= STR0001 //"Solicitação de transferência"
Private lImp  := (SuperGetMv("MV_IMPTRAN",.F.,"1") == "2" )
Private lGerImp := !(FWIsInCallStack("FINA631") .And. lImp )

DEFAULT nPosArotina := 0

If XFilial("SE6") != XFilial("SE2")
	Help(" ",1,"Fina621",,STR0035 ,1,0) //"As tabelas SE6/SE2 devem ter o mesmo compartilhamento. Verifique com Administrador."
	Return
Endif

If nPosArotina > 0
	dbSelectArea('SE2')
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	lRet := Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SE2",,,,,,Fa621Leg())
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fa621Inc ³ Autor ³ Claudio D. de Souza   ³ Data ³ 06/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Incluir solicitacoes de transferencia/distribuição de 	  ³±±
±±³          ³ debito 								                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa621Inc(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS/FIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fa621Inc(cAlias,nReg,nOpc)
Local lPanelFin := IsPanelFin()
Local oDlg
Local nOpcA	 	:= 0
Local cNomCli	:= Space(40)
Local oMemo
Local cHistDeb := Spac(40) + Chr(13) + Chr(10) + Spac(40) + Chr(13) + Chr(10)
Local oOk    	:= LoadBitmap( GetResources(), "LBOK")
Local oNo    	:= LoadBitmap( GetResources(), "LBNO")
Local oCheck
Local cCheck
Local aCheck 	:= {}
Local aArea		:= GetArea()
Local lRet		:= .F.
Local cFilBak	:= cFilAnt	 //Apenas para restaurar de pois do processamento
Local aGetImp := {}
Local oNomCli	:= nil

Private lF621Auto := aRotAuto<>nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA - 12/01/12 - Shark
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock( "FA621CHK" ) )
	If !(ExecBlock("FA621CHK",.F.,.F.))
		Return .F.
	EndIf
Endif

Begin Sequence

	If lImp .And. SE2->E2_TIPO $ MVISS+"/"+MVTAXA+"/"+MVTXA+"/"+MVINSS+"/"+"SES"+"/"+"INA"
		MsgStop(STR0038 ,STR0007 ) //"O parametro MV_IMPTRAN está ativo!A transfêrencia deve ser feita apenas pelo título principal.""O parametro MV_IMPTRAN está ativo!A transfêrencia deve ser feita apenas pelo título principal."
		Break
	EndIf 
	
	If lImp	
		aGetImp := getArea()					
		cQuery := " SELECT COUNT(*) AS CONT "
		cQuery += " FROM "+RetSqlName("SE2")+" SE2 "
		cQuery += " WHERE E2_TITPAI = '"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"' "
		cQuery += " AND E2_FILIAL = '"+SE2->E2_FILIAL+"' AND D_E_L_E_T_ = ' ' AND E2_SALDO <> E2_VALOR"
							
		If Select("TSQL") > 0
			dbSelectArea("TSQL")
			DbCloseArea()
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSQL",.F.,.T.)
							
		dbSelectArea("TSQL")
		dbGotop()
		Do While TSQL->(!Eof())
			TCSetField("TSQL", "CONT" ,"N",14,0)							
			If (TSQL->CONT == 0 )
				lRet := .T.
			EndIf
			Exit		
		EndDo
		dbSelectArea("TSQL")
		DbCloseArea()
		If !lRet
			MsgStop(STR0005 ,STR0007 ) //"A transferência somente poderá ser solicitada se o título não tiver baixas parciais e não tenha solicitações em aberto."#"Atenção"
			Break
		EndIf	
		RestArea(aGetImp)	
	EndIf

	If !Empty(SE2->E2_NUMBOR)
		MsgStop(STR0043 ,STR0007 ) // "Titulo em Borderô. Não é permitida a solicitação de transferência" # "Atenção"
		Break
	Endif						

	// Se ja houve baixa ou se ja foi solicitada uma transferencia,
	// nao permite nova transferencia
	If 	SE2->E2_SALDO <> SE2->E2_VALOR .OR.;
		!Empty(SE2->E2_NUMSOL)
		MsgStop(STR0005 ,STR0007 ) //"A transferência somente poderá ser solicitada se o título não tiver baixas parciais e não tenha solicitações em aberto."#"Atenção"
		Break
	Endif

	// Se for uma fatura cancelada
	// nao permite a inclusao da solicitacao da transferencia
	If SE2->E2_STATUS == "C"
		IW_MSGBOX(STR0006, STR0007,"STOP") 				////"Titulo cancelado. Não é permitida a inclusão da solicitação de transferência"    "Atenção"
		Break// Vai para a primeira linha apos o end sequence
	Endif
	// Se for um titulo de abatimento
	// nao permite a inclusao da solicitacao da transferencia
	If SE2->E2_TIPO $ MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM
		IW_MSGBOX(STR0008, STR0007,"STOP")    /////"Não é permitida a inclusão da solicitação de transferência para titulos de abatimento. Por favor posicione sobre o titulo principal para efetuar a solicitação."    "Atenção"
		Break // Vai para a primeira linha apos o end sequence
	Endif
	//Titulo de adiantamento
	If SE2->E2_TIPO $ MVPAGANT
		Help( ,, STR0007,, STR0040, 1, 0) //Não é permitida a solicitação de transferência de títulos de adiantamento.
		Break
	Endif
	dbSelectArea("SE6")
	DbSetOrder(4)
	If !Empty(SE2->E2_NUMSOL) .And.;
		MsSeek(xFilial("SE6")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FILORIG))
		Help( ,, 'HELP',, STR0009 + SE6->E6_FILDEB, 1, 0)	//////"Já existe solicitação de transferência do titulo"+CHR(13)+"para a filial "
		Break // Vai para a primeira linha apos o end sequence
	Endif

	If !lF621Auto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica tabela de check-list de transferencia  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX5")
		dbSeek(xFilial("SX5")+"G2")
		While SX5->(X5_FILIAL+X5_TABELA) == xFilial("SX5")+"G2"
			AAdd( aCheck,{.F., X5Descri()})
			dbSkip()
		End

		dbSelectArea("SE6")
		DbSetOrder(1)
		RegToMemory("SE6",.F.)
		M->E6_FILDEB	:= CriaVar("E6_FILDEB")
		
		If !lPanelFin
			M->E6_FILDEB	:= cFilAnt
		EndIf
		
		M->E6_CLIENTE	:= SE2->E2_FORNECE
		M->E6_LOJA		:= SE2->E2_LOJA
		
		dbSelectArea("SE2")
		RegToMemory("SE2",.F.)

		DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM 0,0 TO 500,708

		@  04, 03 TO 100, 352 OF oDlg  PIXEL LABEL STR0010 				//"Dados do título a transferir"
		MsMGet():New("SE2",SE2->(RecNo()),2,,,,,{11,7,95,349},,3,,,,,,.T.)

		@ 101, 03 TO 160, 352 OF oDlg  PIXEL LABEL STR0011				////"Check-List para transferência" //
		@ 108, 07 LISTBOX oCheck VAR cCheck Fields HEADER "",STR0012  SIZE 341,50 ON RIGHT CLICK ListBoxAll(108,7,@oCheck,oOk,oNo,@aCheck) NoScroll OF oDlg PIXEL //    "Itens para checagem"
		oCheck:SetArray(aCheck)
		oCheck:bLine := { || {If(aCheck[oCheck:nAt,1],oOk,oNo),aCheck[oCheck:nAt,2]}}
		oCheck:bLDblClick := {|| aCheck[oCheck:nAt][1] := !aCheck[oCheck:nAt][1], oCheck:DrawSelect()}

		@ 161, 03 TO 230, 352 OF oDlg  PIXEL LABEL STR0013					/////"Dados da Transferência" //

		@ 172, 07 SAY STR0016 OF oDlg  PIXEL        /////"Filial de Crédito"
		@ 170, 44 MSGET M->E6_FILDEB OF oDlg  WHEN .T. SIZE 49,8 PIXEL F3 "SM0" VALID ExistCpo("SM0",cEmpAnt+M->E6_FILDEB) .and. CheckSx3("E6_FILDEB",M->E6_FILDEB) HASBUTTON
		@ 172, 93 SAY STR0017 OF oDlg  PIXEL                  ////"Fornecedor Credito"
		@ 170,141 MSGET M->E6_CLIENTE OF oDlg SIZE 42,8  PIXEL F3 "SA2" VALID (Vazio() .Or. ExistCpo("SA2",M->E6_CLIENTE+ALLTRIM(M->E6_LOJA))) .And. CheckSx3("E6_CLIENTE",M->E6_CLIENTE) .And. FA621FOR() HASBUTTON
		@ 170,180+Len(M->E6_CLIENTE) MSGET M->E6_LOJA OF oDlg SIZE 15,8 PIXEL VALID (Vazio() .Or. ExistCpo("SA2",M->E6_CLIENTE+ALLTRIM(M->E6_LOJA))).And. CheckSx3("E6_LOJA",M->E6_LOJA)  .And. FA621FOR()
		@ 170,201+Len(M->E6_CLIENTE+M->E6_LOJA) MSGET oNomCli Var cNomCli WHEN {||cNomCli := Posicione("SA2",1,xFilial("SA2")+M->E6_CLIENTE+M->E6_LOJA,"A2_NOME"),.F.} OF oDlg  PIXEL SIZE 135,8  OBFUSCATED RetGlbLGPD('A2_NOME')

		@ 184, 07 SAY STR0018 OF oDlg  PIXEL          ////"Histórico"
		@ 184, 43 GET oMemo VAR cHistDeb OF oDlg MEMO SIZE 300,40 PIXEL FONT oDlg:oFont COLOR CLR_BLACK,CLR_HGRAY
		oMemo:bRClicked := {||AllwaysTrue()}

		If lPanelFin  //Chamado pelo Painel Financeiro
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT FaMyBar(oDlg,;
			{||If(Fa621TOk(oDlg,aCheck,M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA,lF621Auto),(nOpcA:=1,oDlg:End()),nOpcA:=0)},;
			{||nOpcA:=0,oDlg:End()},,,.F.,.F.)

	   Else
			DEFINE SBUTTON FROM 233, 290 TYPE 1 ACTION (If(Fa621TOk(oDlg,aCheck,M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA,lF621Auto),(nOpcA:=1,oDlg:End()),nOpcA:=0)) ENABLE OF oDlg
			DEFINE SBUTTON FROM 233, 320 TYPE 2 ACTION (nOpcA:=0,oDlg:End()) ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTERED
		Endif

	Else

		dbSelectArea("SE6")
		DbSetOrder(1)
		RegToMemory("SE6",.F.)
		M->E6_FILDEB	:= CriaVar("E6_FILDEB")
		M->E6_CLIENTE	:= CriaVar("E6_CLIENTE")
		M->E6_LOJA		:= CriaVar("E6_LOJA")

		dbSelectArea("SE2")
		RegToMemory("SE2",.F.)

		aValidGet := {}
		If (nT := ascan(aRotAuto,{|x| x[1]='E6_FILDEB'}) ) > 0
			Aadd(aValidGet,{'E6_FILDEB' ,PAD(aRotAuto[nT,2],TamSx3("E6_FILDEB")[1]),"CheckSx3('E6_FILDEB',M->E6_FILDEB)",.t.})
		EndIf
		If (nT := ascan(aRotAuto,{|x| x[1]='E6_CLIENTE'}) ) > 0
			Aadd(aValidGet,{'E6_CLIENTE' ,PAD(aRotAuto[nT,2],TamSx3("E6_CLIENTE")[1]),"CheckSx3('E6_CLIENTE',M->E6_CLIENTE)",.t.})
		EndIf
		If (nT := ascan(aRotAuto,{|x| x[1]='E6_LOJA'}) ) > 0
			Aadd(aValidGet,{'E6_LOJA' ,PAD(aRotAuto[nT,2],TamSx3("E6_LOJA")[1]),"CheckSx3('E6_LOJA',M->E6_LOJA) ",.t.})
		EndIf
		If (nT := ascan(aRotAuto,{|x| x[1]='AUTHISTDEB'}) ) > 0
			Aadd(aValidGet,{'AUTHISTDEB' ,aRotAuto[nT,2],".T.",.t.})
		EndIf
		AAdd( aCheck,{.T., STR0019})                               ////"Transferência Automática"
		If SE2->(MsVldGAuto(aValidGet)) .and. Fa621TOk(oDlg,aCheck,M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA,lF621Auto)
			nOpcA:=1
		Else
			nOpcA:=0
		EndIf

	Endif
	If nOpcA == 1
		If !Fa621Grava(M->E6_FILDEB,M->E6_CLIENTE,M->E6_LOJA,cHistDeb)
			IW_MSGBOX(STR0020, STR0007, "STOP") //###  "Solicitação não efetuada, tente novamente"  "Atenção"
		Else
			lRet := .T.
		Endif
	Endif
End Sequence

cFilAnt := cFilBak
RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa621Grava³ Autor ³ Claudio D. de Souza   ³ Data ³ 26/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as solicitacoes de transferencia de debito           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa621Grava(cFilDeb,cCliDeb,cLojaDeb,cHistDeb)			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION Fa621Grava(cFilDeb As Character,cCliDeb As Character,cLojaDeb As Character,cHistDeb As Character) As Logical
Local lRet		As Logical  
Local cNumSol	As Character 
Local cFilBak	As Character 
Local lCompSE2  As Logical 
Local lCompSE6  As Logical 
Local cE6Ind7   As Character 
Local cE6Chave  As Character 
Local nOrder    As Numeric 

lRet	 :=.F.
cNumSol	 := ""
cFilBak	 := cFilAnt	 //Apenas para restaurar de pois do processamento
lCompSE2 :=  FWModeAccess("SE2",3)== "C" .AND. FWModeAccess("SE2",2)== "C"  .AND. FWModeAccess("SE2",1)== "C"
lCompSE6 :=  FWModeAccess("SE6",3)== "C".AND. FWModeAccess("SE6",2)== "C"  .AND. FWModeAccess("SE6",1)== "C"

If (lCompSE2 .AND. lCompSE6) .AND. (cCliDeb == SE2->E2_FORNECE) 
	MsgStop(STR0037)  //"As tabelas SE6/SE1 devem ter o mesmo compartilhamento. Verifique com Administrador."
		cFilAnt	:= cFilBak
	Return
Endif  

cE6Ind7   := SE6->(IndexKey(7))
cE6Chave  := ""
nOrder    := Iif(!Empty(cE6Ind7) .and. Alltrim(cE6Ind7) == "E6_NUMSOL" ,7,3)

BEGIN TRANSACTION
	If RecLock("SE2",.F.)
		While .t.
			cNumSol := GetSxENum("SE6", "E6_NUMSOL","E6_NUMSOL"+cEmpAnt,nOrder)
			ConfirmSx8()
			dbSelectArea("SE6")
			dbSetOrder(nOrder)
			// Proteção para garantir a existencia do Indice.
			If nOrder == 7 
				cE6Chave := cNumSol
			else
				cE6Chave := cFilDeb+cNumSol
			Endif
 
			If !dbSeek(cE6Chave)
				Exit
			EndIf
		EndDo

		If RecLock("SE6",.T.)
			lRet := .T.
			SE6->E6_FILIAL		:= xFilial("SE6")
			SE6->E6_FILORIG		:= SE2->E2_FILORIG
			SE6->E6_TIPOSOL		:= "P"
			SE6->E6_NUMSOL		:= cNumSol
			SE6->E6_DATSOL		:= dDataBase
			SE6->E6_HORSOL		:= StrTran(Left(Time(),5),":","")
			SE6->E6_PREFIXO		:= SE2->E2_PREFIXO
			SE6->E6_NUM			:= SE2->E2_NUM
			SE6->E6_PARCELA		:= SE2->E2_PARCELA
			SE6->E6_TIPO   		:= SE2->E2_TIPO
			SE6->E6_VALOR  		:= SE2->E2_VALOR
			SE6->E6_SITSOL   	:= "1" // Em aberto
			SE6->E6_USRSOL   	:= RetCodUsr()
			SE6->E6_CLIENTE		:= cCliDeb
			SE6->E6_LOJA		:= cLojaDeb
			SE6->E6_FILDEB		:= cFilDeb
			// Grava historico
			MSMM(SE6->E6_CDHSOL,,,cHistDeb,1,,,"SE6","E6_CDHSOL")
			MsUnlock()
		Endif

		SE2->E2_NUMSOL		:= SE6->E6_NUMSOL
		If SpbInUse() .AND. Trim(SE2->E2_MODSPB) == ""
			SE2->E2_MODSPB := "1"
		EndIf
		If Trim(SE2->E2_FLUXO) == ""
			SE2->E2_FLUXO := "S"
		EndIf
		If Trim(SE2->E2_MULTNAT) == ""
			SE2->E2_MULTNAT := "2"
		EndIf
		MsUnlock()
	Endif
	If lImp
		aGetRec := SE2->(getArea())
		cQuery := " SELECT R_E_C_N_O_ "
		cQuery += " FROM "+RetSqlName("SE2")+" SE2 "
		cQuery += " WHERE E2_TITPAI = '"+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"' "
		cQuery += " AND E2_FILIAL = '"+SE2->E2_FILIAL+"' AND D_E_L_E_T_ = ' ' AND E2_SALDO > 0"
						
		If Select("TSQL") > 0
			dbSelectArea("TSQL")
			DbCloseArea()
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSQL",.F.,.T.)
							
		dbSelectArea("TSQL")
		dbGotop()
		DbSelectArea("SE2")
		Do While TSQL->(!Eof())
			TCSetField("TSQL", "R_E_C_N_O_" ,"N",14,0)
			DbGoTo(TSQL->R_E_C_N_O_)
			Reclock("SE2", .F.)
			SE2->E2_NUMSOL		:= SE6->E6_NUMSOL
			If SpbInUse() .AND. Trim(SE2->E2_MODSPB) == "" 
				SE2->E2_MODSPB := "1"
			EndIf
			If Trim(SE2->E2_FLUXO) == "" 
				SE2->E2_FLUXO := "S"
			EndIf
			If Trim(SE2->E2_MULTNAT) == "" 
				SE2->E2_MULTNAT := "2"
			EndIf
			SE2->(MsUnlock())
			TSQL->(dbSkip())	
		EndDo
		RestArea(aGetRec) 
	Endif
END TRANSACTION	
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa621TOk  ³ Autor ³ Claudio D. de Souza   ³ Data ³ 26/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar o botao Ok na inclusao das solic de transf de debito³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fa621TOk(oDlg,aCheck,cFilDeb,cCliDeb)					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION Fa621TOk(oDlg,aCheck,cFilDeb,cCliDeb,cLojaDeb,lF621Auto)
Local lRet		:= .T.
Local cMsgErr	:= ""

// Se todos os itens do check-list estiverem marcados, autoriza a transferencia.
aEval(aCheck, {|e| lRet := lRet .And. e[1] } )

If lRet

	If Empty(cCliDeb) .or. Empty(cLojaDeb)
		lRet := .F.
		cMsgErr := STR0036 //Os campos Fornecedor e Loja devem ser preenchidos
		Help( ,, 'HELP',, cMsgErr, 1, 0)
	Endif

	If SE2->E2_FILORIG == cFilDEb .And. SE2->E2_FORNECE == cCliDeb .And. SE2->E2_LOJA==cLojaDeb
		lRet := .F.
		cMsgErr := STR0021 + cFilDeb + STR0022 //"Proibido a inclusão da solicitação de transferência para a mesma Empresa/Filial ("    ")"
		Help( ,, 'HELP',, cMsgErr, 1, 0)
	Endif

	If lRet .And. cEmpAnt != SM0->M0_CODIGO
		lRet := .F.
		IW_MSGBOX(STR0023, STR0007, "STOP") // "A empresa destino deve ser igual a empresa origem"   "Atenção"
	Endif

Else
	IW_MSGBOX(STR0024, STR0007,"STOP") //###  "É necessário que todos os itens do check-list sejam verificados para efetuar a solicitação"   "Atenção"
Endif

If lRet .and. Empty(cFilDeb)
	cMsgErr := STR0021 + cFilDeb + STR0022 //"Proibido a inclusão da solicitação de transferência para a mesma Empresa/Filial ("    ")"
	Help( ,, 'HELP',, cMsgErr, 1, 0)
	lRet := .F.
EndIf

If (ExistBlock( "FA621TOK" ) ) .and. lRet
	If ValType( lRet := ExecBlock("FA621TOK",.F.,.F.,{aCheck,cFilDeb,cCliDeb,cLojaDeb,lF621Auto}) ) <> "L"
		Help( ,, 'HELP',, STR0002, 1, 0) //"Retorno do ponto de entrada FA621TOK invalido!"
		lRet := .F.
	EndIf
Endif

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa621Leg    ³ Autor ³ Claudio D. de Souza ³ Data ³ 27.03.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA621                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa621Leg(nReg)

Local aLegenda := {	{"BR_VERDE"		, STR0025 },;	     ////"Sem solicitação"
						{"BR_VERMELHO"	, STR0026 },;		 ////"Com solicitação"
						{"BR_PRETO"		, STR0027} }       ////"Fatura cancelada"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { "E2_STATUS#'C' .And. E2_NUMSOL=' '", aLegenda[1][1] } )
	Aadd(uRetorno, { "E2_STATUS#'C' .And. E2_NUMSOL#' '", aLegenda[2][1] } )
	Aadd(uRetorno, { "E2_STATUS='C'", aLegenda[3][1] } )
Else
	BrwLegenda(cCadastro, STR0028,aLegenda)        ////"Legenda"
Endif

Return uRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³28/11/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local Nx         := 0
Local aRotinaNew := {}
Local aRotina	   := {{STR0031	,"AxPesqui", 0 , 1,,.F.},;	//"Pesquisar"
						{STR0032	,"AxVisual", 0 , 2},;		//"Visualizar"
						{STR0033	,"Fa621Inc", 0 , 3},;		//"Solicitar"
						{STR0034 	,"Fa621Leg", 0 , 6,,.F.}}	//"Legenda"
						
If ExistBlock("FIN621MNU")
	aRotinaNew := ExecBlock("FIN621MNU",.F.,.F.,aRotina)
	If ( ValType(aRotinaNew) == "A" )
		For Nx:=1 To len(aRotinaNew)
			Aadd(aRotina,{ aRotinaNew[Nx][1],;
				 			 aRotinaNew[Nx][2],;
				 			 aRotinaNew[Nx][3],;
				 			 aRotinaNew[Nx][4],;
				 			 aRotinaNew[Nx][5]})
		Next nx
	EndIf
EndIf						
						
Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA621T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 27.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA621                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinA621T(aParam)

	ReCreateBrow("SE2",FinWindow)
	cRotinaExec := "FINA621"
	FinA621(aParam[1])
	ReCreateBrow("SE2",FinWindow)

	dbSelectArea("SE2")

	INCLUI := .F.
	ALTERA := .F.

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa621Auto  ³ Autor ³ Acacio Egas          ³ Data ³ 20.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada automatica para geração de transferencia e         ³±±
±±³Descri‡…o ³ aprovacao.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA621                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa621Auto(nRecSe2,cfilDest,cHist, lAprov, lMsgErro)
Local aVetor 		:= {}
Local cFilbak		:= cFilAnt
Local lRet			:= .F.
Local IsAuto		:= Type("lMsErroAuto")<>"U"
Local cQuery 		:= ""


Default nRecSe2	:= SE2->(RECNO())
Default cHist		:= STR0029	 //"Solicitação de Transferencia/Distribuição de titulo entre filiais."
Default lAprov	:= .F.
Default lMsgErro	:= .F.

If	!IsAuto
	lMsErroAuto := .F.
EndIf

DbSelectArea("SE2")
DbGoto(nRecSe2)

aVetor :={	{"E6_FILDEB"	,cfilDest,Nil},;
			{"E6_CLIENTE"	,SE2->E2_FORNECE,Nil},;
			{"E6_LOJA"		,SE2->E2_LOJA,Nil},;
			{"AUTHISTDEB"	,cHist,Nil}}

If !IsAuto
	MSExecAuto({|x,y| Fina621(x,y)},aVetor,3) //Inclusao de Solicitação de transferencia
Else
	lRet	:= Fina621(aVetor,3)
EndIf

If !lMsErroAuto

	If lAprov
		cQuery := "SELECT SE6.*,R_E_C_N_O_ RECNOSE6 FROM " + RetSqlName( "SE6" ) + " SE6 "
		cQuery += "WHERE D_E_L_E_T_ = ' ' AND SE6.E6_FILORIG='" + SE2->E2_FILORIG + "' "
		cQuery += "AND E6_NUMSOL='" + SE2->E2_NUMSOL + "' "
		cQuery += "AND E6_TIPOSOL='P' "

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), "TMPSE6", .F., .T. )

		TMPSE6->(dbGoTop())
		While !TMPSE6->(eof())
			SE6->(dbGoto(TMPSE6->RECNOSE6))
			SE2->(DbGoto(nRecSe2))
			aVetor :={{"E6_NUMSOL"	,SE2->E2_NUMSOL,Nil}}
			cFilAnt	:= SE6->E6_FILDEB
			If	!IsAuto
				MSExecAuto({|x,y| Fina631(x,y)},aVetor,3) //Aprovação Automatica da transferencia
			Else
				lRet	:= Fina631(aVetor,3)
			EndIf
			cFilAnt	:= cFilbak
			If lMsErroAuto
				lRet	:= .F.
				Exit
			EndIf
			TMPSE6->(dbSkip())
		EndDo
		TMPSE6->(DbCloseArea())
	Else
		lRet	:= .T.
	Endif

Endif

If lMsgErro .and. lMsErroAuto
	mostraerro()
Endif

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa621Estor ³ Autor ³ Acacio Egas          ³ Data ³ 20.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada automatica para estorno de transferencia e         ³±±
±±³Descri‡…o ³ aprovacao.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA621                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa621Estor(nRecSe2,lMsgErro)

Local aVetor 	:= {}
Local cFilbak	:= cFilAnt
Local lRet		:= .F.
Local IsAuto	:= Type("lMsErroAuto")<>"U"

Default nRecSe2 := SE2->(RECNO())
Default lMsgErro:= .F.

If	!IsAuto
	lMsErroAuto := .F.
EndIf

DbSelectArea("SE2")
DbGoto(nRecSe2)

If !Empty(SE2->E2_NUMSOL)

	aVetor :={{"E6_NUMSOL"	,SE2->E2_NUMSOL,Nil}}

	cFilAnt	:= SE6->E6_FILDEB

	If !IsAuto
		MSExecAuto({|x,y| Fina631(x,y)},aVetor,6) //Excluir
	Else
		Fina631(aVetor,6)
	EndIf

	cFilAnt := cFilbak

	If lMsgErro .and. lMsErroAuto
		If !IsBlind()
			mostraerro()
		EndIf
	Endif

Else

	Help( ,, 'HELP',, STR0030, 1, 0) //"Este titulo não foi utilizado em tranferencia."
	lMsErroAuto := .T.

EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa621Stat  ³ Autor ³ Acacio Egas          ³ Data ³ 20.02.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Status do titulo na rotina de transferencia.     ³±±
±±³          ³ 0= Titulo Normal;                                          ³±±
±±³          ³ 1=Titulo transferido;                                      ³±±
±±³          ³ 2= Titulo de transferencia;                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA621                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa621Stat(nRecSe2,aAreaSE6)

Local cQuery
Local nRet	:= 0

Default nRecSe2	:= SE2->(Recno())

DbSelectArea("SE2")
DbGoto(nRecSe2)

If !Empty(SE2->E2_NUMSOL)

	DbSelectArea("SE6")
	DbSetOrder(3)
	If DbSeek(xFilial("SE6")+SE2->E2_NUMSOL) .and. SE6->E6_SITSOL=="2"
		nRet := 1
		aAreaSE6	:= SE6->(GetArea())
	EndIf

Else

	cQuery := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName( "SE6" ) + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' AND E6_FILDEB='" + SE2->E2_FILIAL + "' AND "
	cQuery += "E6_PREFIXO='" + SE2->E2_PREFIXO + "' AND E6_NUM='" + SE2->E2_NUM + "' AND "
	cQuery += "E6_PARCDES='" + SE2->E2_PARCELA + "' AND E6_TIPO='" + SE2->E2_TIPO + "' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), "TMPSE6", .F., .T. )
	If TMPSE6->(!Eof())
		DbSelectArea("SE6")
		DbSetOrder(3)
		DbGoto(TMPSE6->(REC))
		SE6->(GetArea())
		nRet := 2
	EndIf
	TMPSE6->(DbCloseArea())

EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}FA621FOR
Programa p/ verificar se o fornecedor de origem 
tem o mesmo CNPJ do fornecedor de destino.
@author Caique Bispo Ferreira
@since  28/01/2015
@version 11
/*/
//-------------------------------------------------------------------
Function FA621FOR()

Local lRet := .F.
Local cCgcO	:= ""
Local lCompSA2 := !(FwFilial() $ xFilial("SA2"))

If "E6_CLIENTE" $ ReadVar() 
	M->E6_LOJA := SA2->A2_LOJA
EndIf

If lCompSA2
	lRet := SE2->(E2_FORNECE+E2_LOJA) == M->(E6_CLIENTE+E6_LOJA)
Else
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	//Verifico o fornecedor do titulo 
	If SA2->(DbSeek(xFilial("SA2", SE2->E2_FILORIG) + SE2->(E2_FORNECE+E2_LOJA)))
		cCgcO := SA2->A2_CGC
		SA2->(DbSetOrder(1))	//A2_FILIAL+A2_CGC
		If SA2->(DbSeek(M->E6_FILDEB + M->(E6_CLIENTE+E6_LOJA)))
			If cCgcO == SA2->A2_CGC
				lRet := .T.
			EndIf
		EndIf
	EndIF
EndIf

If !lRet
	HELP(' ',1,"FORNEC_DESTINO" ,,STR0041,1,0,,,,,, {STR0042})	//"O fornecedor informado não tem relação com o fornecedor original do título.."###"Selecione um fornecedor de destino com o mesmo CNPJ/CPF do fornecedor do titulo que deseja transferir."
EndIf

Return lRet

