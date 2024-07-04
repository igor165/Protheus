
// 17/08/2009 -- Filial com mais de 2 caracteres

#INCLUDE "CTBA150.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"      

STATIC l150AUT := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CTBA150   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 11.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Cadastro de Cambio de Moedas Contabeis       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctba150()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA150(aRotAuto,nOpcAuto,aRotItem)

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemtoAnsi(STR0004)	//"Cotacao de Moedas"

DEFAULT aRotAuto := {}
DEFAULT aRotItem := {}
DEFAULT nOpcAuto := 3

If Len(aRotAuto) > 0
	l150AUT := .T.
Endif


mBrowse( 6, 1,22,75,"CTP")

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb150Cal  ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe na tela o calendario e a getdados                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb150cal(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±³          ³ ExpA1 = Array com as cotações                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb150Cal(cAlias,nReg,nOpc, aAutoCab, dAutoData)

Local aSaveArea:= GetArea()
Local aAltera	:= {"CTP_TAXA","CTP_BLOQ"}
Local oDlg, oCalend
Local oGet
Local dData
Local lExclui 	 := ( nOpc == 5 )	//	Excluir
Local nX        := 0
Local nPos      := 0

Private aTELA[0][0],aGETS[0],aHeader[0]
Private aCols 		:= {}
Private aColsAnt	:= {}
Private nUsado 	:= 0
Private nPosMoeda, nPosTaxa, nPosBloq
Private lInclui
Private l150Auto	:= (aAutoCab<>NIL .And. dAutoData<>NIL)

IF !ChkPsw(84)
	Return
Endif

dbSelectArea("CTO")
dbSetOrder(1)
dbSeek(xFilial())
If Eof() .Or. (xFilial("CTO") <> CTO->CTO_FILIAL)
	Help(" ",1,"NOMOEDCTO")
	Return
EndIf	

DbSelectArea("CTP")
dbSetOrder(1)

If Bof() .And. Eof()
	dData := dDataBase
Else
	dData := CTP->CTP_DATA
EndIf

CTB150Ahead()
lInclui := Ctb150Acols(dData)
aColsAnt := Aclone(aCols)

nOpca := 0

nPosMoeda := Ascan( aHeader, { |x| AllTrim( x[2] ) == "CTP_MOEDA" } )
nPosTaxa  := Ascan( aHeader, { |x| AllTrim( x[2] ) == "CTP_TAXA"  } )

If !l150Auto  

	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0003) FROM 9,0 TO 23,80 OF oMainWnd //"Cambio Moedas Contabeis"
	
		oCalend:=MsCalend():New(0,0,oDlg)
	
		oCalend:dDiaAtu	:= dData
		dData					:= oCalend:dDiaAtu
	
		oCalend:bChange := {|| At150ChgDia(@oCalend,@oGet,@dData,@lInclui,lExclui), oDlg:Refresh() }
			
		oGet := MSGetDados():New(00,140,66,314,nOpc,"AlwaysTrue","AlwaysTrue","",.F.,aAltera)
		oGet:oBrowse:bAdd := { || .F. }
		
	    DEFINE SBUTTON FROM 80, 280 TYPE 1 ACTION (CTB150OK(dData,lInclui,lExclui),oDlg:End()) ENABLE Of oDlg
	
	ACTIVATE DIALOG oDlg CENTERED	
                     	
Else


   If nPosTaxa > 0 .And. nPosMoeda > 0

		nPos := Ascan( aCols, { |x| AllTrim( x[nPosMoeda] ) == aAutoCab[01][02] } ) //--- Moeda

		If nPos > 0

			aCols[nPos][nPosTaxa] := aAutoCab[02][02] //--- Taxa
		Else

			aCols := {}

			Aadd( aCols, Array(Len(aHeader)+1))

			aCols[Len(aCols)][nPosMoeda]      := aAutoCab[01][02] //--- Moeda
			aCols[Len(aCols)][nPosTaxa ]      := aAutoCab[02][02] //--- Taxa
			aCols[Len(aCols)][Len(aHeader)+1] := .F.
		EndIf

		Ctb150Grava(dAutoData,lExclui,l150Auto)
   EndIf
EndIf
RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb150Prj  ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 08/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a projecao de moedas [CTO/SM2]                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb150Prj(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb150Prj

Local oLbx
Local oDlg
Local nCont 	:= 1
Local cMoeda, nTaxa
Local oOk	  	:= LoadBitmap( GetResources(), "LBOK" )	
Local oNo	  	:= LoadBitmap( GetResources(), "LBNO" )
Local aCols		:= {}
Local nLeftLbx := 120
Local aArea 	:= CTP->(GetArea())
Local oSayPrj, oTpPrj
Local oTaxa, aTaxa, oDias
Local nDias		:= GetMV("MV_DIASPRO")
Local oRegresso, oPrj
Local cPict 	:= PesqPict("CTO","CTO_TXPRJ",TamSx3("CTO_TXPRJ")[1])
Local oBold
Local cSayPrj
Local nUsado	:= 8		// Esta variavel deve ser alterada de acordo com os defines
							// Abaixo
Local lReplica := .T.

Local oPanel1
Local oPanel2

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

nPosMoeda	:= 1
nPosDesc	:= 2
nPosTaxa	:= 3
nPosInfPrj	:= 4
nPosTpPrj	:= 5
nPosDias	:= 6
nPosDiaReg	:= 7
nPosRecno  	:= 8

SX3->(DbSetOrder(2))
SX3->(DbSeek("CTP_TAXA"))

aTaxa := { X3Titulo(), SX3->X3_PICTURE }

dbSelectArea("CTO")
dbSetOrder(1)
dbSeek(xFilial())
If Eof() .Or. (xFilial("CTO") <> CTO->CTO_FILIAL)
	Help(" ",1,"NOMOEDCTO")
	Return
EndIf	

While !Eof() .And. xFilial() == CTO->CTO_FILIAL

	dbSelectArea("CTP")
	dbSetOrder(1)
	If !dbSeek(xFilial()+Dtos(dDataBase)+CTO->CTO_MOEDA)
		cMoeda	:= CTO->CTO_MOEDA
		nTaxa	:= CriaVar("CTP_TAXA",.T.)
	Else		
		cMoeda	:= CTP->CTP_MOEDA
		nTaxa	:= CTP->CTP_TAXA
	EndIf	

	dbSelectArea("CTO")
	
	AADD(aCols,Array(nUsado+1))
	aCols[nCont][nPosMoeda]		:= cMoeda
	aCols[nCont][nPosDesc]		:= CTO->CTO_DESC
	aCols[nCont][nPosTaxa]		:= If(CTO->CTO_TXPRJ > 0, CTO->CTO_TXPRJ, nTaxa)
	aCols[nCont][nPosInfPrj]	:= {}
	aCols[nCont][nPosDias]		:= nDias
	aCols[nCont][nPosTpPrj]		:= 1
	aCols[nCont][nPosDiaReg]	:= 3
	aCols[nCont][nPosRecno]		:= CTO->(Recno())
	aCols[nCont][nUsado+1]		:= .T.

	aAdd(aCols[nCont][nPosInfPrj],{"",Transform(aCols[nCont][nPosTaxa],cPict)})
	nCont++	
	dbSkip()

EndDo	

DEFINE MSDIALOG oDlg FROM 70,1 TO 350,700 TITLE STR0009 PIXEL //"Projecao de moedas"
oPanel1 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,130,130,.F.,.F.)
oPanel1:Align := CONTROL_ALIGN_LEFT

oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,230,230,.F.,.F.)
oPanel2:Align := CONTROL_ALIGN_RIGHT

//Listbox - Painel 2 (Direita)
@ 01,nLeftLbx 	LISTBOX oLbx VAR cVar Fields;
					HEADER "", STR0010,STR0011,STR0012,STR0013+"/"+STR0030; //"Moeda"###"Descricao"###"Taxa"###"Dias"
					SIZE 293,54.5 ;
					ON DBLCLICK	(oLbx:aArray[oLbx:nAt][nUsado + 1] := !;
									oLbx:aArray[oLbx:nAt][nUsado + 1],;
									Ct150CtlObj({oTaxa, oTpPrj, oDias, oRegresso},;
									! aCols[oLbx:nAt,nUsado + 1]),;
									oLbx:Refresh());
					ON CHANGE	( cSayPrj := aCols[oLbx:nAt][nPosMoeda] + " - " + aCols[oLbx:nAt][nPosDesc],oSayPrj:Refresh(),;
									Ct150CtlObj({oTaxa, oTpPrj, oDias, oRegresso},;
									! aCols[oLbx:nAt,nUsado + 1]),;
									Ct150TextoP(aCols[oLbx:nAt][nPosTpPrj], oPanel1, oPrj));				
					OF oPanel2 PIXEL NOSCROLL

oLbx:SetArray(aCols)
oLbx:bLine := { || {	If(aCols[oLbx:nAt,nUsado + 1],oOk,oNo),;
							aCols[oLbx:nAt,1], aCols[oLbx:nAt,2],;
							Transform(aCols[oLbx:nAt,3],cPict), aCols[oLbx:nAt,nPosDias] } }

oLbx:Align := CONTROL_ALIGN_ALLCLIENT

//Dados de Projecao - PAINEL 1 (Esquerda)
cSayPrj := aCols[1][nPosMoeda] + " - " + aCols[1][nPosDesc]

@ 01,02 SAY STR0014 OF oPanel1 PIXEL FONT oBold
@ 13,02 SAY oSayPrj VAR cSayPrj OF oPanel1 PIXEL FONT oBold            
@ 25,02  CHECKBOX oReplica VAR lReplica PROMPT STR0025 PIXEL OF oPanel1 SIZE 80,9 MESSAGE STR0026; //"Replicar os dados abaixo"###"Se estiver marcado, copiará os dados abaixo para todas as moedas selecionadas"
			ON CLICK Ctb150Replica(aCols[oLbx:nAt][nPosDias],;
										  aCols[oLbx:nAt][nPosDiaReg],;
										  aCols[oLbx:nAt][nPosTaxa],;
										  aCols[oLbx:nAt][nPosTpPrj],;
										  lReplica,;
										  aCols,;
										  nUsado)
			
@ 40,02 	SAY STR0017            	SIZE 53, 07 OF oPanel1 PIXEL //"Tipo"
@ 67,02 	SAY oPrj PROMPT STR0015 SIZE 53, 07 OF oPanel1 PIXEL // //"Dias projecao"

@ 85,02 	SAY STR0016	SIZE 53, 07 OF oPanel1 PIXEL //"Dias regressao"
@102,02 	SAY aTaxa[1]     		   SIZE 53, 07 OF oPanel1 PIXEL


@ 41,60  RADIO oTpPrj Var aCols[oLbx:nAt][nPosTpPrj] 3D SIZE 65,10 ;
			ITEMS STR0018, STR0019 OF oPanel1 PIXEL; //"Regressao Linear"###"Inflacao projetada"
			On Change Ct150TextoP(aCols[oLbx:nAt][nPosTpPrj], oPanel1, oPrj) .And.;
						 Ct150CtlObj({oRegresso,oTaxa}) .And.;	
						 If(aCols[oLbx:nAt][nPosTpPrj] = 2,;
							(oPrj:cCaption:=STR0024,oPrj:Refresh(),aCols[oLbx:nAt][nPosDias] := 1,oDias:Refresh(),.T.),;
							(oPrj:cCaption:=STR0015,oPrj:Refresh(),.T.)) .And.;
					    Ctb150Replica(aCols[oLbx:nAt][nPosDias],;
					 					   aCols[oLbx:nAt][nPosDiaReg],;
 									  		aCols[oLbx:nAt][nPosTaxa],;
									  		aCols[oLbx:nAt][nPosTpPrj],;
									  		lReplica,;
									  		aCols,;
									  		nUsado)
oTpPrj:cReadVar := "c150TpPrj"

@ 67,60		MSGET oDias Var aCols[oLbx:nAt][nPosDias] Picture "9999";
			SIZE 50, 10 OF oPanel1 PIXEL Valid aCols[oLbx:nAt][nPosDias] > 0;
			ON Change If(aCols[oLbx:nAt][nPosTpPrj] = 2,;
							(oPrj:cCaption:=STR0024,oPrj:Refresh(),Ct150InfP(aCols, oLbx:nAt)),;
							(oPrj:cCaption:=STR0015,oPrj:Refresh(),.T.)) .And.;
						 Ctb150Replica(aCols[oLbx:nAt][nPosDias],;
										   aCols[oLbx:nAt][nPosDiaReg],;
										  	aCols[oLbx:nAt][nPosTaxa],;
										  	aCols[oLbx:nAt][nPosTpPrj],;
										  	lReplica,;
										  	aCols,;
										  	nUsado)
										  	
oDias:cReadVar := "c150Dias"
oDias:cSx1Hlp  := "c150Dias"

@ 82,60 	MSGET oRegresso Var aCols[oLbx:nAt][nPosDiaReg] Picture "999";
			SIZE 50, 10 OF oPanel1 PIXEL ;
			When aCols[oLbx:nAt][nPosTpPrj] <> 2;
			Valid aCols[oLbx:nAt][nPosDiaReg] > 0 ;
			ON Change Ctb150Replica(aCols[oLbx:nAt][nPosDias],;
										   aCols[oLbx:nAt][nPosDiaReg],;
										  	aCols[oLbx:nAt][nPosTaxa],;
										  	aCols[oLbx:nAt][nPosTpPrj],;
										  	lReplica,;
										  	aCols,;
										  	nUsado)
oRegresso:Enable()
oRegresso:cReadVar := "c150Reg"
oRegresso:cSx1Hlp  := "c150Reg"

@ 99,60 	MSGET oTaxa Var aCols[oLbx:nAt][nPosTaxa] Picture aTaxa[2];
			When aCols[oLbx:nAt][nPosTpPrj] <> 2 .And. aCols[oLbx:nAt][nPosMoeda] != "01";
			SIZE 50, 10 OF oPanel1 PIXEL HASBUTTON ;
			Valid aCols[oLbx:nAt][nPosTaxa] > 0 ON Change Ctb150Replica(aCols[oLbx:nAt][nPosDias],;
	  																						 aCols[oLbx:nAt][nPosDiaReg],;
										  													 aCols[oLbx:nAt][nPosTaxa],;
										  													 aCols[oLbx:nAt][nPosTpPrj],;
										  													 lReplica,;
										  													 aCols,;
	  																						 nUsado)
oTaxa:cReadVar := "c150Taxa"      
oTaxa:cSx1Hlp  := "c150Taxa"

						
ACTIVATE 	MSDIALOG oDlg Centered;
			ON INIT (EnchoiceBar(oDlg,{|| If(Ct150CfPrj(aCols),;
											  (Processa({|lEnd|Ct150GrPrj(aCols, nUsado)}), oDlg:End()),) },;	// Botao confirma
									  			{||oDlg:End()},,;										// Botao cancelar
					{ 	{ "DBG06"	, { || (aEval(oLbx:aArray, {|e| e[nUsado + 1] :=;
										    !e[nUsado + 1] }),;
										    Ct150CtlObj({oTaxa, oTpPrj, oDias, oRegresso},;
										    ! aCols[oLbx:nAt,nUsado + 1]),;
										    oLbx:Refresh()) }, STR0020, STR0031 },; //"Inverte selecao" "Inverte"
						{ "COMPTITL", { || Ct150InfP(aCols, oLbx:nAt) }, STR0021, STR0032 } }),; //"Projeta inflacao""Projetar"
			Ct150TextoP(aCols[oLbx:nAt][nPosTpPrj], oDlg, oPrj))

CTP->(RestArea(aArea))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct150GrPrj ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 08/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz gravacao dos dados informados para projecao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo informacoes das moedas para projecao³±±
±±³          ³ ExpN1 = Numero de campos usado para matriz                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function Ct150GrPrj(aCols, nUsado)

Local nCols, nPeriodos
Local dPeriodo
Local aMoedReg
Local aCalculo
Local nTaxa		:= 0
Local aX 		:= {}
Local nDias
Local nNumDia
Local dDataFin
Local nX
Local nMeses  
//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
Local lIntegDef  :=  FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CTBA150",.T.,,.T.)

DbSelectArea("CTP")
DbSetOrder(2)
ProcRegua(Len(aCols))

For nCols := 1 To Len(aCols)
	IncProc(STR0027) //"Projetando moedas selecionadas"
	aX := {}
	// Verifica as taxas informas para calculo da projecao atraves da inflacao
	For nX := 1 To Len(aCols[nCols][nPosInfPrj])
		Aadd(aX,Val(StrTran(StrTran(aCols[nCols][nPosInfPrj][nX][2],".",""),",",".")))
	Next 
		
	If Empty(aX)
		Loop
	EndIf	
	
	// Se a moeda estiver selecionada
	If aCols[nCols, nUsado + 1]
		CTO->(MsGoto(aCols[nCols][nPosRecno]))
		If CTO->CTO_TXPRJ <> aCols[nCols][nPosTaxa] 	// Gravo a taxa alterada no arquivo
			CTO->(RecLock("CTO", .F.))					// de moedas
			CTO->CTO_TXPRJ := aCols[nCols][nPosTaxa] 
			CTO->(MsUnLock())
		Endif
	
		If aCols[nCols][nPosTpPrj] = 1 // Projecao linear
			dPeriodo 	:= dDataBase - aCols[nCols][nPosDiaReg]
			aMoedPrj	:= {}
			aMoedReg	:= {}
			MsSeek(xFilial("CTP") + aCols[nCols][nPosMoeda] + Dtos(dPeriodo),.T.)
			dPeriodo := CTP_DATA					 		 
			While dPeriodo < dDataBase
				If !Eof()
					Aadd(aMoedReg, CTP_TAXA)
				Else
					Aadd(aMoedReg, aCols[nCols][nPosTaxa])
				Endif
				dPeriodo ++
				MsSeek(xFilial("CTP") + aCols[nCols][nPosMoeda] + Dtos(dPeriodo))
			EndDo
			
			If Len(aMoedReg) = 0
				Aadd(aMoedReg, aCols[nCols][nPosTaxa])
				dPeriodo ++
			Endif
			
			aCalculo := RLinear(aMoedReg)
			nDias := aCols[nCols][nPosDias]		 	
		Else // Inflacao projetada
			MsSeek(xFilial("CTP")+aCols[nCols][nPosMoeda]+Dtos(dDataBase))
			nPriVal := CTP->CTP_TAXA
			// Calcula o ultimo dia do periodo a projetar, se for inflacao projetada,
			// verifica quantos dias ha nos meses informado pelo usuario.
			nDias		:= 0
			dDataFin	:= dDataBase
			For nMeses := 1 To aCols[nCols][nPosDias]
				nDias    := (LastDay(dDataFin)-dDataBase)
				dDataFin := LastDay(dDataFin) + 1
			Next
			nNumDia := 0
		Endif
	
		For nPeriodos := 1 To nDias
			dPeriodo  := dDataBase + nPeriodos
			// Calcula a taxa para inflacao projetada
			If aCols[nCols][nPosTpPrj] != 1 	// Inflacao projetada
				If Month(dPeriodo) != Month(dPeriodo-1) // Se mudou o mes
					If nTaxa <> 0
						nPriVal := nTaxa
					Else		// Projecao no ultimo dia do mes - Busco taxa do primeiro dia
						MsSeek(xFilial("CTP")+aCols[nCols][nPosMoeda]+Dtos(dPeriodo))
						nPriVal := CTP->CTP_TAXA
					Endif
					nNumDia := 0
				Endif
				nTaxa := RInflac(aX,dPeriodo,nPriVal,++nNumDia)
			Else
				// Calcula a taxa da moeda projetada
				nTaxa :=	(aCalculo[2]*(dPeriodo-dDatabase+aCols[nCols][nPosDiaReg])+;
							(aCalculo[4]-(aCalculo[2]*aCalculo[3])))
			Endif	
			If ! MsSeek(xFilial("CTP")+aCols[nCols][nPosMoeda]+Dtos(dPeriodo))
				RecLock("CTP", .T.)
				Replace CTP_FILIAL With xFilial("CTP"),;
						  CTP_DATA 	 With dPeriodo,;
						  CTP_MOEDA	 With aCols[nCols][nPosMoeda],;
						  CTP_BLOQ   With "2"
			Else
				RecLock("CTP", .F.)
			Endif
			If CTP_MOEDA = "01"
				Replace CTP_TAXA With aCols[nCols][nPosTaxa]
			Else
			  		Replace CTP_TAXA With nTaxa
			Endif
			MsUnLock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integra Protheus x TIN                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lIntegDef
			  	FwIntegDef( 'CTBA150' )
			Else
				EvalTrigger()
			EndIf

			// Compatibilizacao com SM2
			dbSelectArea("SM2")
			dbSetOrder(1)
			If !dbSeek(CTP->CTP_DATA)
				RecLock("SM2",.T.)
				Replace M2_DATA	With CTP->CTP_DATA
			Else
				RecLock("SM2")
			EndIf		
			// Grava no SM2      
			If nCols > 1
				dbSelectArea("SM2")  
				cStr := cValtoChar(nCols)
				Replace &('M2_MOEDA'+cStr) With CTP->CTP_TAXA
			EndIf
			MsUnlock()
			dbSelectArea("CTP")
		Next 
	Endif	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct150CfPrj ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 08/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma a se sera feita a projecao das moedas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo informacoes das moedas para projecao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ct150CfPrj(aCols)

Local lProjeta := .F., nProjeta, nUsado := Len(aCols[1])

// Verifico se existem moedas marcadas para projecao
For nProjeta := 1 To Len(aCols)
	If aCols[nProjeta][nUsado] .And. aCols[nProjeta][nPosDias] > 0
		lProjeta := .T.
	Endif
Next

Return lProjeta .And. MsgYesNo(STR0028, STR0029) //"Confirma a projecao das moedas selecionadas"###"Atencao !"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ct150InfP ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 08/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre tela com dados para inflacao projetada                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo informacoes das moedas para projecao³±±
±±³          ³ ExpN1 = Posicao atual do elemento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ct150InfP(aCols, nPos)

Local oLbx, dDataI := dDataBase, nMeses, oDlg
Local aInfPrj := aCols[nPos][nPosInfPrj]
Local cPict := PesqPict("CTO","CTO_TXPRJ",TamSx3("CTO_TXPRJ")[1])

If aCols[nPos][nPosTpPrj] = 1
	Return .F.
Endif

If aCols[nPos][nPosDias] == 0 
	Return .F.
EndIf

If Len(aInfPrj) < aCols[nPos][nPosDias]
	For nMeses := 1 To aCols[nPos][nPosDias]
		If nMeses > Len(aInfPrj)
			Aadd(aInfPrj, { "", Transform(aCols[nPos][nPosTaxa],cPict)})
		Endif
		aInfPrj[nMeses][1] := MesExtenso(Month(dDataI)) + "/" + Str(Year(dDataI), 4)
		dDataI  := LastDay(dDataI) + 1
	Next
Else
	Asize(aInfPrj, aCols[nPos][nPosDias])	// Limito ao numero de dias informados
Endif

DEFINE MSDIALOG oDlg FROM 00,01 TO 280,250 TITLE STR0022 +; //"Inflacao projetada - "
				aCols[nPos][1] + ' - ' + aCols[nPos][2] PIXEL
@ 00,0 	LISTBOX oLbx Var cVar FIELDS HEADER STR0023,STR0012; //"Mes/Ano"###"Taxa"
		SIZE ((oDlg:nRight - oDlg:nLeft) / 2) - 3,((oDlg:nBottom - oDlg:nTop) / 2) - 28 OF oDlg PIXEL 

DEFINE SBUTTON oBtn FROM 00,00 TYPE 1 ACTION oDlg:End() ENABLE Of oDlg

oBtn:nTop  := oLbx:nHeight + 1
oBtn:nLeft := ((oDlg:nRight - oDlg:nLeft) / 2) + 60
	
oLbx:SetArray(aInfPrj)
oLbx:bLDblClick := {|| EditTaxa(oLbx,aInfPrj,cPict) } // Permite a edicao.
								
oLbx:bLine := { || { 	aInfPrj[oLbx:nAt,1], aInfPrj[oLbx:nAt,2] } }
				
ACTIVATE MSDIALOG oDlg Centered

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct150TextP ³ Autor ³ Wagner Mobile Costa  ³ Data ³ 11/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Diferencia/habilita botoes de acordo com o tipo de inflacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tipo de projecao informada para moeda			  ³±±
±±³          ³ 1=Linear, 2=Inflacao projetada 						      ³±±
±±³          ³ ExpO1 = Dialog para mudanca do botao Projetacao inflacao   ³±±
±±³          ³         da Enchoice Bar                                    ³±±
±±³          ³ ExpO2 = Objeto com o texto indicando  os  dias/meses  para ³±±
±±³          ³         projecao											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ct150TextoP(nTpPrj, oDlg, oPrj)

Local nBotPrj := Len(oDlg:aControls) - 2

// Utilizo aControls do Objeto odlg pois armazena EnchoiceBar
// Diminui dois do aControls pois os ultimos botoes sao Ok e Cancelar

If nTpPrj = 1 .And. nBotPrj > 15		// 15 Provisorio botao esta apos 15
	oDlg:aControls[nBotPrj]:Disable()
	oPrj:cCaption := STR0015 //"Dias projecao"
ElseIf nBotPrj > 15						
	oDlg:aControls[nBotPrj]:Enable()
	oPrj:cCaption := STR0024 //"Meses a projetar"
Endif
			 
Return .T.
			 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³At150chgdia³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastrar cotacoes no dia escolhido                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³At150ChgDia(oCalend,oGet,dData,lInclui,lExclui)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do Calendario                               ³±±
±±³          ³ ExpO2 = Objeto do Get		                              ³±±
±±³          ³ ExpD1 = Data           		                              ³±±
±±³          ³ ExpL1 = Define se eh inclusao ou nao		                  ³±±
±±³          ³ ExpL2 = Se for exclusao, retornar    	                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function At150ChgDia(oCalend,oGet,dData,lInclui,lExclui)

Local lRet := .F.
Local aSaveArea := GetArea()

If ! lExclui
	lRet := Ctb150Comp(lInclui)

	If lRet
		BEGIN TRANSACTION
			Ctb150Grava(dData)
		END TRANSACTION
	EndIf	

	dData := oCalend:dDiaAtu

	lInclui := CTB150Acols(dData)
	aColsAnt := Aclone(aCols)
	oGet:oBrowse:Refresh()

	RestArea(aSaveArea)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb150AHEAD³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera matriz Aheader - para montagem posterior da acols     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb150AHead                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb150Ahead()

Local aSaveArea := GetArea()

dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("CTO_DESC")
nUsado++
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				 x3_tamanho, x3_decimal, x3_valid,;
				 x3_usado, x3_tipo, x3_arquivo } )

dbSelectArea("Sx3")
dbSetOrder(1)
dbseek("CTP")
While !EOF() .And. (x3_arquivo == "CTP")
	IF 	X3USO(x3_usado) .AND. cNivel >= x3_nivel .And.;
		Trim(X3_CAMPO) != "CTP_DATA"
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
					 x3_tamanho, x3_decimal, x3_valid,;
					 x3_usado, x3_tipo, x3_arquivo } )
	ENDIF
	dBSkip()
EndDO

A150HeaderWT("CTP", aHeader)

RestArea(aSaveArea)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb150Acols³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera matriz Acols para preenchimento das cotacoes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb150Acols(dData,oGet)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1=Data				                                      ³±±
±±³          ³ ExpO1=Objeto do Get		                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb150Acols(dData,oGet)

Local aSaveArea:= GetArea()
Local lInclui	:= .F.	
Local nCont 	:= 1
Local cMoeda, nTaxa, cBloq
Local cAlias, nRecno
Local nPos_ALI_WT, nPos_REC_WT

nPosMoeda	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTP_MOEDA"})
nPosTaxa	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTP_TAXA"})
nPosBloq	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTP_BLOQ"})
nPosDesc	:= Ascan(aHeader,{|x|Alltrim(x[2]) = "CTO_DESC"})

nPos_ALI_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "CTP_ALI_WT"})
nPos_REC_WT := AScan(aHeader,{|x| Upper(AllTrim(x[2])) == "CTP_REC_WT"})

aCols := {}

dbSelectArea("CTO")
dbSetOrder(1)
dbSeek(xFilial())
While !Eof() .And. xFilial() == CTO->CTO_FILIAL

	dbSelectAREA("CTP")
	dbSetOrder(1)
	If !dbSeek(xFilial()+Dtos(dData)+CTO->CTO_MOEDA)
		lInclui	:= .T.
		cMoeda	:= CTO->CTO_MOEDA
		nTaxa	:= CriaVar("CTP_TAXA",.T.)
		cBloq	:= CriaVar("CTO_BLOQ",.T.)
		cAlias  := "CTP"
		nRecno	:= 0
	Else		
		lInclui	:= .F.
		cMoeda	:= CTP->CTP_MOEDA
		nTaxa	:= CTP->CTP_TAXA
		cBloq	:= CTP->CTP_BLOQ
		cAlias  := "CTP"
		nRecno	:= CTP->(Recno())
	EndIf	

	dbSelectArea("CTO")
	
	AADD(aCols,Array(nUsado+1))     
	aCols[nCont][nPosMoeda]	:= cMoeda
	aCols[nCont][nPosTaxa]	:= nTaxa
	aCols[nCont][nPosBloq]	:= cBloq			
	aCols[nCont][nPosDesc]	:= CTO->CTO_DESC
	aCols[nCont][nUsado+1]	:= .F.

	If nPos_ALI_WT > 0
		aCols[nCont][nPos_ALI_WT] := cAlias
	EndIf

	If nPos_REC_WT > 0
		aCols[nCont][nPos_REC_WT] := nRecno
	EndIf
	
	nCont++	
	dbSkip()

EndDo	
dbSelectArea("CTP")

RestArea(aSaveArea)
Return lInclui

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB150Grava³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava ou exclui as cotacoes digitadas na GetDados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTb150Grava(dData,lExclui)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data                                               ³±±
±±³          ³ ExpL1 = Se eh exclusao ou nao. 	                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb150Grava(dData,lExclui,l150Auto)

Local nCont
Local aSaveArea	:= GetArea()

//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
Local lIntegDef  :=  FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CTBA150",.T.,,.T.)
                           
DEFAULT lExclui 	:= .F.
DEFAULT l150Auto 	:= .F.
                           
If ! lExclui
	For nCont := 1 To Len(aCols)
		//If aCols[nCont][nPosTaxa] > 0
			dBSelectArea("CTP")
			dbSetOrder(1)
			If !DbSeek(xFilial() + Dtos(dData) + aCols[nCont][nPosMoeda])
				dbSelectArea("CTO")
				dbSetOrder(1)
				If dbSeek(xFilial() + aCols[nCont][nPosMoeda])
					dbSelectArea("CTP")
					RecLock("CTP",.T.)
					Replace CTP_FILIAL With xFilial()
					Replace CTP_DATA	With dData
					Replace CTP_MOEDA	With aCols[nCont][nPosMoeda]
				Else
					dbSelectArea("CTP")
				EndIf
			Else
				RecLock("CTP",.F.)
			EndIf
			If aCols[nCont][nPosMoeda] = "01"
				Replace CTP_TAXA With CriaVar("CTP_TAXA",.T.)
			Else
				Replace CTP_TAXA With aCols[nCont][nPosTaxa]
			Endif
			Replace CTP_BLOQ	With aCols[nCont][nPosBloq]
		//Endif
		// Grava no SM2      
		If nCont > 1
			// Compatibilizacao com SM2
			dbSelectArea("SM2")
			dbSetOrder(1)
			If !dbSeek(dData)	
				RecLock("SM2",.T.)
				Replace M2_DATA	With dData
				Replace M2_INFORM With "S"
			Else
				RecLock("SM2")
			EndIf		
			cStr := cValtoChar(nCont)
			If FieldPos("M2_MOEDA"+cStr) > 0 
				Replace &('M2_MOEDA'+cStr) With CTP->CTP_TAXA
			EndIf
			MsUnlock()
 		EndIf
      		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada IntegDef                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If  !l150Auto
			If lIntegDef 
				FwIntegDef( 'CTBA150' )
	  		Else
	  			EvalTrigger()
	  		EndIf
  		EndIf    
  		
	Next nCont
	
	dbSelectArea("CTP")
	MsUnlock()
	
	// ponto de entrada para antes da gravação
	IF ExistBlock("Ctb150Cal") 
		ExecBlock( "Ctb150Cal", .F. , .F.,{dData,lExclui,l150Auto } )
	Endif

Else
	For nCont := 1 To Len(aCols)
		If !l150Auto
			// Pedindo confirmacao para excluir
			If nCont == 1
				If !MsgYesNo( STR0033+"?" )
					Exit
				Endif
				CTP->( DbSetOrder(1) )
			EndIf
		EndIf
		// Apagando as taxas em todas as moedas
		If CTP->( DbSeek( xFilial() + Dtos(dData) + aCols[nCont][nPosMoeda] ) )  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chamada IntegDef                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If  !l150Auto
				If lIntegDef 
					FwIntegDef( 'CTBA150' )
		  		Else
		  			EvalTrigger()
		  		EndIf
  			EndIf    
  			
		    RecLock("CTP",.F.)
		    CTP->( DbDelete() )
		    CTP->( MsUnlock() )
		EndIf
	Next

	// ponto de entrada para antes da gravação
	IF ExistBlock( "Ctb150Del" ) 
		ExecBlock( "Ctb150Del", .F. , .F. ) 
	Endif

EndIf

RestArea(aSaveArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB150Comp ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Compara matriz aCols e aColsAnt                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb150comp(lInclui)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Se eh inclusao ou nao.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb150Comp(lInclui)

Local nCont, nCont1
Local lRet 		:= .F.
Local aSaveAREA := GetArea()               
Local lEntrei := .F.

For nCont := 1 To Len(aCols)
	For nCont1 := 1 To nUsado
		If lInclui .Or. (aCols[nCont][nCont1]!= aColsAnt[nCont][nCont1])
			lRet := MsgYesNo(OemToAnsi(STR0007),OemToAnsi(STR0006))
			lEntrei := .T.
			Exit
		EndIf			
	Next nCont1 
	If lEntrei
		Exit
	EndIf		
Next nCont

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB150Ok   ³ Autor ³ Pilar S Albaladejo   ³ Data ³ 17/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do botao OK                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb150Ok(dData,lInclui,lExclui)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 = Data                                                ³±±
±±³          ³ExpL1 = Se eh inclusao ou nao. 	                          ³±±
±±³          ³ExpL2 = Se eh exclusao ou nao. 	                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Ctb150Ok(dData,lInclui,lExclui)

Local lRet 		:= .T.
Local aSaveArea := GetArea()

// ponto de entrada para antes da gravação
IF ExistBlock("Ctb150TOk") 
	lRet := ExecBlock( "Ctb150TOk", .F. , .F.,{ dData,lInclui,lExclui }  )
Endif

IF lRet
	If !lExclui
		lRet := Ctb150Comp(lInclui)
	EndIf

	If lRet .Or. lExclui
		Ctb150Grava(dData,lExclui)
	EndIf	
Endif

RestArea(aSaveArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct150CtlObj³ Autor ³ Wagner Mobile Costa  ³ Data ³ 08/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Habilita/desabilita objetos de digitacao de projecao moeda ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct150CtlObj(aObjetos, lDesmarcado) 			                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Objetos para efetuar refresh ou desabilitar         ³±±
±±³          ³ExpL1 = Indica se a moeda esta marcada (sim permite edicao) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Ct150CtlObj(aObjetos, lDesmarcado)

Local nObjetos

DEFAULT lDesmarcado := .F.

For nObjetos := 1 To Len(aObjetos)
	// Se a moeda estiver desmarcada ou se for necessario avaliar o condicao When
	// do objeto e esta condicao nao for satisfeita, desabilita o objeto
	If lDesmarcado .Or. (ValType(Eval(aObjetos[nObjetos]:bWhen)) == "L" .And. !Eval(aObjetos[nObjetos]:bWhen))
		aObjetos[nObjetos]:Disable()
	Else
		// Se estiver marcada, verifica apenas se e necessario avaliar a condicao When
		// do objeto e se esta condicao nao for satisfeita, desabilita o objeto, caso contrario
		// habilita.
		If (ValType(Eval(aObjetos[nObjetos]:bWhen)) == "L" .And. !Eval(aObjetos[nObjetos]:bWhen))
			aObjetos[nObjetos]:Disable()
		Else
			aObjetos[nObjetos]:Enable()
		Endif	
	Endif
	aObjetos[nObjetos]:Refresh()
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³EditTaxa   ³ Autor ³ Claudio D. de Souza  ³ Data ³ 29/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permitir a edicao da taxa na ListBox                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oLbx    = Objeto ListBox                                   ³±±
±±³          ³ aInfPrj = Matriz do ListBox                                ³±±
±±³          ³ cPic    = Picture para edicao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function EditTaxa(oLbx,aInfPrj,cPict)
// Transforma para numerico para que o usuario possa editar o campo com entrada
// de numeros apenas.
aInfPrj[oLbx:nAt][2] := Val(StrTran(StrTran(aInfPrj[oLbx:nAt][2],".",""),",","."))
lEditCell(@aInfPrj,oLbx,cPict,2)
// Volta para caracter o numero editado para que possa ser exibido corretamente
// pela LISTBOX.
aInfPrj[oLbx:nAt][2] := Transform(aInfPrj[oLbx:nAt][2],cPict)
oLbx:SetFocus()
oLbx:GoDown()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb150Repli³ Autor ³ Claudio D. de Souza  ³ Data ³ 29/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Replicar os dados para todas as moedas selecionadas        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nDiasProj = Dias a Projetar                                ³±±
±±³          ³ nDiasReg  = Dias a Regredir                                ³±±
±±³          ³ nTaxa     = Taxa                                           ³±±
±±³          ³ nTipoProj = Tipo de Projecao                               ³±±
±±³          ³ lReplica  = Replicar os dados                              ³±±
±±³          ³ aCols     = Colunas  com os dados                          ³±±
±±³          ³ nUsado    = Tamanho de aCols[1]                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Ctb150Replica(nDiasProj,nDiasReg,nTaxa,nTipoProj,lReplica,;
										aCols,nUsado)
Local nX, nLen := Len(aCols)

If lReplica
	For nX := 1 To nLen
		// Se a moeda estiver selecionada
		If aCols[nX, nUsado + 1]
			aCols[nX][nPosDias]   := nDiasProj
		   	aCols[nX][nPosDiaReg] := nDiasReg
		   	If aCols[nX][nPosMoeda] <> "01"
			   	aCols[nX][nPosTaxa] := nTaxa
			Endif
		Endif
	Next
Endif	
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva    ³ Data ³ 01/12/06 ³±±
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
Local aCTBA150 := {}
Local nX := 0
Local aRotina := {		{ STR0001, "AxPesqui"		, 0 , 1,,.F.},;	//"Pesquisar"
                     	{ STR0002, "AxVisual"		, 0 , 2		},;	//"Visualizar"
                     	{ STR0003, "CTB150Cal"		, 0 , 3		},;	//"Cambio Moedas Contabeis"
                     	{ STR0008, "CTB150Prj()"	, 0 , 3,	},;	//"Projetar Moedas"
                     	{ STR0033, "CTB150Cal"		, 0 , 5		}}		//"Excluir"

IF ExistBlock( "CT150BUT" )
	aCTBA150 := ExecBlock( "CT150BUT",.F.,.F.,aRotina)
	
	IF ValType(aCTBA150) == "A" .AND. Len(aCTBA150) > 0
		FOR nX := 1 to len(aCTBA150)
			aAdd(aRotina, aCTBA150[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A150HeaderWT ºAutor ³ Paulo Carnelossi  º Data ³ 09/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona no aHeader campos necessarios para funcionamento  º±±
±±º          ³ Walk-Thru quando nao se utiliza a funcao FillGetDados()    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A150HeaderWT(cAlias, aHeader)
Local aArea := GetARea()
Local aAreaSX3 := SX3->(GetArea())
Local cUsado

dbSelectArea("SX3")
dbSetOrder(2)
cAlias := Alltrim(cAlias)

If SX3->(DbSeek(cAlias+"_FILIAL"))
	cUsado := SX3->X3_USADO

	AADD( aHeader, { STR0034 , cAlias+"_ALI_WT", "", 09, 0,, cUsado, "C", cAlias, "V"} ) //"Alias WT"
	nUsado++
	AADD( aHeader, { STR0035 , cAlias+"_REC_WT", "", 09, 0,, cUsado, "N", cAlias, "V"} ) //"Recno WT"
	nUsado++
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ Marcelo C. Coutinho  º Data ³  09/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem Única															    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mensagem Única                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXml, nType, cTypeMsg ,cVersion)
	Local aRet := {}
 
	aRet:= CTBI150( cXml, nType, cTypeMsg ,cVersion)
	
Return aRet