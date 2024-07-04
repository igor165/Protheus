#INCLUDE "ACDV020.ch" 
#include "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV020    ³ Autor ³ Fernando Alves      ³ Data ³ 06/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apontamento de Producao simples (MATA250)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD           	    								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³                          ³              |                  ³±±
±±³      02  ³Erike Yuri da Silva       ³08/06/2006    |00000100508       ³±±
±±³      03  ³Erike Yuri da Silva       ³09/06/2006    |00000100707       ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³                          ³              |                  ³±±
±±³      06  ³                          ³              |                  ³±±
±±³      07  ³                          ³              |                  ³±±
±±³      08  ³Erike Yuri da Silva       ³09/06/2006    |00000100707       ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³Erike Yuri da Silva       ³08/06/2006    |00000100508       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/             
Function ACDV020()
Local bkey05
Local bkey09
Local bkey24
Local lACD020in	:=	ExistBlock("ACD020IN")
Local lVolta := .F.
Private nQTD    := 0
Private aProdCD := {}
Private lMSErroAuto:= .F.
Private cOP := space(Len(SH6->H6_OP))
Private cTM := space(Len(SF5->F5_CODIGO))
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf


// -- Verifica se data do Protheus esta diferente da data do sistema.
DLDataAtu()

If IsTelnet() .AND.  VtModelo() == "RF"
	bKey05 := VTSetKey(05,{|| CB020Encer()}, STR0033)   // "Encerrar"
	bkey09 := VTSetKey(09,{|| AIV020Hist()}, STR0023) //"Informacao"
	bKey24 := VTSetKey(24,{|| Estorna()},STR0024)   // CTRL+X //"Estorno"
EndIf

While .T.
	If !lVolta
		cOP := space(Len(SH6->H6_OP))
		nQTD:= 0
	EndIF
	
	// Ponto de entrada para preenchimento dos campos cTM e cOP
	If lACD020in
		ExecBlock("ACD020IN",.F.,.F.)
	EndIf
	If IsTelnet() .and. lVT100B
		lVolta := .F.
		VTCLEAR()
		@ 0,0 vtSay STR0001 //"Apontamento"
		@ 1,0 VTSAY STR0002 //"Tipo de movimento:"
		@ 2,0 VTGET cTM  pict '@!' Valid AIV020VLTM() F3 "SF5" //When Empty(cTM)
		VTRead
		
		If vtLastKey() != 27
			VTClear
			@ 0,0 VTSAY STR0003 //"OP: "
			@ 1,0 VTGET cOP pict '@!'  Valid AIV020ValOP() F3 "SC2" ;
				when iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
			@ 2,0 VTSAY STR0004 //"Quantidade: "
			@ 3,0 VTGET nQTD pict CBPictQtde() Valid VldQTD()
			VTREAD	
		EndIf
		
		If lVolta
			Loop
		EndIf
		
		If vtLastKey() == 27
			Exit
		EndIf
	ElseIf IsTelnet() .and. VtModelo() == "RF"
		VTCLEAR()
		@ 0,0 vtSay STR0001 //"Apontamento"
		@ 1,0 VTSAY STR0002 //"Tipo de movimento:"
		@ 2,0 VTGET cTM  pict '@!' Valid AIV020VLTM() F3 "SF5" When Empty(cTM)
		@ 3,0 VTSAY STR0003 //"OP: "
		@ 4,0 VTGET cOP pict '@!'  Valid AIV020ValOP() F3 "SC2"
		@ 5,0 VTSAY STR0004 //"Quantidade: "
		@ 6,0 VTGET nQTD pict CBPictQtde() Valid VldQTD()
		VTREAD
		If vtLastKey() == 27
			Exit
		EndIf
	Else
		TerIsQuit()
		//TerCBuffer()
		TerCls()
		If (IsTelnet() .AND. VtModelo() == "MT44") .Or. (TerProtocolo() == "GRADUAL" .AND. TerModelo() == "MT44")
			//         1         2         3         4
			//1234567890123456789012345678901234567890
			//Apontamento               TM: 999
			//OP: XXXXXXXXXXX   Quantidade: 999.999,99
			@ 0,00 TerSay STR0001 //"Apontamento"
			@ 0,27 TerSay STR0025     //"TM:"
			
			//Esta validacao eh usada devido microterminal com protocolo Gradual
			If !Empty(cTM)
				TerKeyBoard(chr(13))
			EndIf
			@ 0,31 TerGetRead cTM  pict '@!' Valid AIV020VLTM() // When Empty(cTM)
			If TerEsc()
				Exit
			EndIf
			@ 1,00 TerSay STR0018 //"OP:"
			@ 1,05 TerGetRead cOP pict PesqPict("SC2","C2_NUM")  Valid AIV020ValOP() /*F3 "SC2"*/
			If TerEsc()
				Exit // quando for executa pelo sigaacdt a rotina devera' retornar ao menu
			Endif
			@ 1,19 TerSay STR0026 //"Quantidade:"
			@ 1,31 TerGetRead nQTD pict CBPictQtde() Valid VldQTD()
			
			If TerEsc()
				Exit
			Endif
		Else
			//         1         2
			//12345678901234567890
			//Apontamento
			//TM: 999
			//--------------------- NOVA TELA
			//OP:  XXXXXXXXXXX
			//Qdt: 999.999,99
			@ 0,00 TerSay STR0001 //"Apontamento"
			@ 1,00 TerSay STR0025 //"TM:"
			@ 1,05 TerGetRead cTM  pict '@!' Valid AIV020VLTM()  When Empty(cTM)
			
			TerCls()
			If TerEsc()
				Exit // quando for executa pelo sigaacdt a rotina devera' retornar ao menu
			Endif
			
			@ 0,00 TerSay STR0018 //"OP:"
			@ 0,05 TerGetRead cOP pict PesqPict("SC2","C2_NUM")  Valid AIV020ValOP() /*F3 "SC2" */
			If TerEsc()
				Exit // quando for executa pelo sigaacdt a rotina devera' retornar ao menu
			Endif
			@ 1,00 TerSay STR0027 //"Qtd:"
			@ 1,05 TerGetRead nQTD pict CBPictQtde() Valid VldQTD()
			
			If TerEsc()
				Exit
			EndIf
		EndIf
	EndIf
	
	If TerEsc()
		Exit
	EndIf
EndDo

If !Empty(aProdCD) .AND. CBYesNo(STR0005,STR0006,.T.) //"Confirma apontamento?"###"ATENCAO"
	If ExistBlock('ACD020PR')
		ExecBlock('ACD020PR',.F.,.F.)
	EndIf		
	GravaOP(aProdCD)
EndIf


If IsTelnet() .and. VtModelo() == "RF"
	vtsetkey(05,bkey05)
	vtsetkey(09,bkey09)
	vtsetkey(24,bkey24)
Else
	TerCls()
	TerIsQuit()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AIV020VlTM ³ Autor ³ Fernando Alves      ³ Data ³ 18/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o get de tipo de movimento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD           	    								           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AIV020VlTM()
If Empty(cTM)
	Return .F.
EndIf

DbSelectArea("SF5")
SF5->(DbSetOrder(1))
If !SF5->(DbSeek(xFilial("SF5")+cTM))
	CBAlert(STR0007+chr(13)+chr(10)+STR0008,STR0010,.T.,4000,2)  //"Tipo de movimento"###"nao existe!"###"Aviso"
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	Else
		cTM := space(Len(SF5->F5_CODIGO))
	EndIf
	Return .F.
EndIf

If SF5->F5_TIPO # "P"
	CBAlert(STR0009,STR0010,.T.,4000,2)
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	Else
		cTM := space(Len(SF5->F5_CODIGO))
	EndIf
	Return .F.
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AIV020ValOP³ Autor ³ Fernando Alves      ³ Data ³ 07/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida OP informada pelo usuario                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ AICVA020          	    								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AIV020ValOP()
Local lACD020OP:= (ExistBlock("ACD020OP"))

If Empty(cOP)
	Return .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Existe e posiciona o registro                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SC2")
SC2->(DbSetOrder(1))
If !SC2->(DbSeek(xFilial("SC2")+cOp))
	CBAlert(STR0011+chr(13)+chr(10)+STR0008,STR0010,.T.,4000,2) 	 //"Ordem de Producao"###"nao existe!"###"Aviso"
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	Else
		cOP := space(Len(SH6->H6_OP))
	EndIf
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP ja foi encerrada                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SC2->C2_DATRF)
	If IsTelnet() .AND. VtModelo() == "RF"
		VTBEEP(2)
		VtAlert(STR0034,STR0010,.T.,3000) // Ordem de Produção encerrada.            X
		VTKeyBoard(chr(20))
		VTGEtSetFocus('cOP')
	Else
		CBAlert(STR0011+chr(13)+chr(10)+STR0028,STR0010,.T.,4000,2) 			 //"Ordem de Producao"###"ja encerrada!"###"Aviso"
		cOP := space(Len(SH6->H6_OP))
	EndIf
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP e do tipo Firme                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SC2->C2_TPOP # "F"
	CBAlert(STR0029,STR0010,.T.,4000,2)  //"Nao e permitida movimentacao com OPs Previstas"###"Aviso"
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	Else
		cOP := space(Len(SH6->H6_OP))
	EndIf
	Return .F.
Endif
If lACD020OP
	If ! ExecBlock("ACD020OP",.F.,.F.)
		Return .f.
	EndIf
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldQTD     ³ Autor ³ Fernando Alves      ³ Data ³ 06/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da quantidade informada para o apontamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD           	    								           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldQTD()
Local nPos
Local cLote    := Space(TamSX3("D3_LOTECTL")[1])
Local dValid   := ctod('')
Local lACD020QE:= (ExistBlock("ACD020QE"))

If Empty(nQTD)
	Return .F.
Endif

cProduto := SC2->C2_PRODUTO
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cProduto))
If Empty(SB1->B1_FORMLOT)
	If !Empty(SuperGetMV("MV_FORMLOT",.F.,""))
		cLote := Formula(SuperGetMV("MV_FORMLOT",.F.,""))
	EndIf
Else
	cLote := Formula(SB1->B1_FORMLOT)
EndIf
dValid   := dDataBase+SB1->B1_PRVALID
If ! CBRastro(cProduto,@cLote,,@dValid,,.T.)
	If IsTelnet() .and. VtModelo() == "RF"
		nQTD := 0
	EndIf
	Return .f.
EndIf

nPos := aScan(aProdCD,{|x| x[1] == cOP .and. x[3] == cLote .and. x[4] == dValid })
If Empty(nPos)
	If lACD020QE
		If ! ExecBlock("ACD020QE",.F.,.F.,{nQTD})
			Return .f.
		EndIf
	Endif
	Aadd(aProdCD,{cOP,nQtd,cLote,dValid})
Else
	If lACD020QE
		If ! ExecBlock("ACD020QE",.F.,.F.,{(aProdCD[nPos,2]+nQTD)})
			Return .f.
		EndIf
	Endif
	aProdCD[nPos,2] += nQTD
Endif

If ExistBlock('V020FQTD')
	ExecBlock('V020FQTD',.F.,.F.)
EndIf

Return .T.

Static Function GravaOP(aProdCD)
Local aMata250		:= {}
Local i
Local nPosCol		:= 0
Local lMostraErro	:= .T.
Local lACD020ME		:= ExistBlock('ACD020ME') //Indica se deve ou nao mostrar o erro caso exista
Local lACD020GV		:= ExistBlock('ACD020GV')
Local lACD020G2		:= ExistBlock('ACD020G2')	
Local cDiaCTB		:= ""

If cPaisLoc == "PTG"
	VTCLEAR()
	cDiaCTB := Space(TamSX3("D3_DIACTB")[1])
	@ 0,0 VTSAY RetTitle("D3_DIACTB") //"Diario CTB"
	@ 1,0 VTGET cDiaCTB Pict '@!' Valid !Empty(cDiaCTB) .And. ExistCPO("CVL",cDiaCTB) F3 "CVL" When Empty(cDiaCTB)
	VTREAD
	If vtLastKey() == 27
		Return .T.
	EndIf
EndIf

//VERIFICAR SE SERA NECESSARIO RETIRAR A FUNCAO VTMODELO PARA ESTE CASO
If IsTelnet() .AND. VtModelo() == "RF"
	VTMSG(STR0012) //"Aguarde..."
Else
	nPosCol	:= If(TerModelo()=="MT16",5,15)
	TerCls()
	@ 0,nPosCol TerSay STR0012	//"Aguarde..."
EndIf

Begin Transaction
For i := 1 To Len(aProdCD)
	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+aProdCD[i,1])
	aMata250      :={{"D3_TM"     ,cTM						, NIL},;
	{"D3_COD"    ,SC2->C2_PRODUTO	, NIL},;
	{"D3_UM"     ,SC2->C2_UM      	, NIL},;
	{"D3_QUANT"  ,aProdCD[i,2], NIL},;
	{"D3_OP"     ,aProdCD[i,1]     , NIL},;
	{"D3_LOCAL"  ,SC2->C2_LOCAL  	, NIL},;
	{"D3_EMISSAO",dDataBase      		, NIL}}
	
	If Rastro(SC2->C2_PRODUTO)
		aadd(aMata250,{"D3_LOTECTL",aProdCD[i,3]		,nil})
		aadd(aMata250,{"D3_DTVALID",aProdCD[i,4]    	,nil})
	EndIf
	
	//--Tratamento para Portugal: contabilizacao do diario
	If cPaisLoc == "PTG"
		aadd(aMata250,{"D3_DIACTB",cDiaCTB		,nil})
	EndIf
	
	If lACD020GV
		aMata250 := Execblock('ACD020GV',.F.,.F.,aMata250)
	Endif

	If lACD020G2//Foi adicionado ponto de entrada semelhante ao 'ACD020GV' devido a necessidade 
		aMata250 := Execblock('ACD020G2',.F.,.F.,{aMata250,I})//de passar mais variáveis como parâmetro.
	Endif
	
	lMsHelpAuto:=.T.
	lMSErroAuto := .F.
	nModuloOld  := nModulo
	nModulo     := 4
	msExecAuto({|x|MATA250(x)},aMata250)
	nModulo     := nModuloOld
	
	lMsHelpAuto:=.F.
	If lMSErroAuto
		DisarmTransaction()
		Break
	EndIf
Next
End Transaction
If lMSErroAuto         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³PE que perminte visualizar ou nao o erro gerado no log³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lACD020ME 
		lMostraErro := If(ValType(lMostraErro := ExecBlock('ACD020ME',.F.,.F.,{NomeAutoLog()}))#"L",.T.,lMostraErro)		
	EndIf

	If lMostraErro
		If IsTelnet()
			VTDispFile(NomeAutoLog(),.t.)
		Else
			TerDispFile(NomeAutoLog())
		EndIf
	EndIf
Endif
Return !lMSErroAuto

Static Function AIV020Hist()
Local aCab  := {STR0013,STR0014,STR0021,STR0022} //"OP"###"Quantidade" //"Lote"###"Validade"
Local aSize := {12,16,10,8}
Local aSave := VTSAVE()
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
VTClear()
VTaBrowse(0,0,iif(lVT100B,3,7),19,aCab,aProdCD,aSize)
VtRestore(,,,,aSave)
Return


Static Function Estorna()
Local aTela
Local cOP
aTela := VTSave()
VTClear()
cOP := space(Len(SH6->H6_OP))
@ 00,00 VtSay Padc(STR0017,VTMaxCol()) //"Estorno da Leitura"
@ 02,00 VtSay STR0018 //"OP:"
@ 03,00 VtGet cOP pict "@!" Valid VldEstorno(cOP) F3 "SC2"
VtRead
vtRestore(,,,,aTela)
Return

Static Function VldEstorno(cOP)
Local nPos
Local cProduto := Space(TamSX3("B1_COD")[1])
Local cLote    := Space(TamSX3("D3_LOTECTL")[1])
Local dValid   := ctod('')
If Empty(cOP)
	Return .f.
EndIF

cProduto := SC2->C2_PRODUTO
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cProduto))
dValid   := dDataBase+SB1->B1_PRVALID
If ! CBRastro(cProduto,@cLote,,@dValid)
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	EndIf
	Return .f.
EndIf

nPos := aScan(aProdCD,{|x| x[1] == cOP .and. x[3] == cLote .and. x[4] == dValid })
If Empty(nPos)
	CBAlert(STR0019,STR0010,.T.,4000,2)
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	EndIf
	Return .f.
EndIf
If ! VTYesNo(STR0020,STR0006,.t.) //"Confirma o estorno desta OP?"###"ATENCAO"
	If IsTelnet() .and. VtModelo() == "RF"
		VTKeyBoard(chr(20))
	EndIf
	Return .f.
EndIf
//Estorno do aProdCD
aDel(aProdCD,nPos)
aSize(aProdCD,Len(aProdCD)-1)
If IsTelnet() .and. VtModelo() == "RF"
	VTKeyBoard(chr(20))
EndIf
Return .f.
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CB020Encer    ³ Autor ³ Aecio Ferreira Gomes³ Data ³ 11/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Responsavel pelo Encerramento das Ops.						³±±
±±³          ³ 						                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 										                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ACDV020                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CB020Encer()

Local aMata250 := {}

While .T.
	
	If IsTelnet() .and. VtModelo() == "RF"
		VTCLEAR()
		@ 0,0 vtSay STR0030 //"Encerramento da OP"
		@ 1,0 VTSAY STR0003 //"OP: "
		@ 2,0 VTGET cOP pict '@!'  Valid AIV020ValOP() F3 "SC2" 
		VTREAD
		If vtLastKey() == 27
			Exit
		EndIf
	EndIf
	DbSelectArea("SD3")
	DbSetOrder(1)
	DBSetFilter( {|| cOP == SD3->D3_OP .And.(SD3->D3_COD == SC2->C2_PRODUTO .AND. Empty(SD3->D3_ESTORNO).And. Subs(SD3->D3_CF,1,2) == "PR" )}, "cOP == SD3->D3_OP .And.(Empty(SD3->D3_ESTORNO).And. Subs(D3_CF,1,2) == 'PR'" ) //Verifica se o registro existe na tabela SD3
	DbGoTop()
	If !EOF() .And. cOP == SD3->D3_OP .And.(SD3->D3_COD == SC2->C2_PRODUTO .AND. Empty(SD3->D3_ESTORNO).And.Subs(SD3->D3_CF,1,2) == "PR")  // Se existir o registro nao encerra a OP.
		If ! VTYesNo(STR0031,STR0010,.T.)  //"Deseja encerrar a OP?"###"Aviso"
			VTClearGET('cOP')
			VTGEtSetFocus('cOP')
			Loop
		EndIf	
		lMsHelpAuto :=.T.
		lMSErroAuto := .F.
		nModuloOld  := nModulo
		nModulo     := 4

		MsExecAuto({|x,Y| MATA250(aMata250,7)})// "Encerra ordem de producao"
		
		nModulo     := nModuloOld 
 		lMsHelpAuto:=.F.
    Else
		VTAlert(STR0032,STR0010,.T.,3000) // "Nao existem apontamentos para a ordem de producao"
	EndIf
	DBClearFilter()

	VTClearGET('cOP')
	VTGEtSetFocus('cOP')
End

If lMSErroAuto         
	VTDispFile(NomeAutoLog(),.t.)
Endif

Return !lMSErroAuto         
