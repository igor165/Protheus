#INCLUDE "TMSA890.ch"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa890   ³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Incluir solicitacoes de transferencia de debito            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa890()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION Tmsa890

Local aHlpPor1    :=  {"Solicitação não efetuada",", tente novamente"}
Local aHlpIng1    :=  {"Request not made., try again "}
Local aHlpEsp1    :=  {"Solicitud no efectuada, intente nuevamente"}
Local aHlpPor2    :=  {"A empresa destino deve ser"," igual a empresa origem"}
Local aHlpIng2    :=  {"The destination company must be"," equal to origin company"}
Local aHlpEsp2    :=  {"La empresa destino debe ser"," igual a la de origen"}
Local aHlpPor3    :=  {"É necessário que todos os itens do ","check-list sejam verificados para ","efetuar a solicitação"}
Local aHlpIng3    :=  {"It is necessary that all the items of ","check-list to be verified to  ","make the request "}
Local aHlpEsp3    :=  {"Es necesario que todos los items de ","check-list sean verificados para ","efectuar la solicitud"}
Local aHlpPor4	  :=  {"Não é possível fazer transferência, pois","excedeu o limite de crédito do cliente","selecionado."}
Local aHlpIng4	  :=  {"Unable to transfer, it exceeded the","credit limit of the selected customer."}
Local aHlpEsp4	  :=  {"No se puede transferir, se superó el","límite de crédito de los clientes","seleccionados."}
Local aHlpPor5	  :=  {"Não é possível fazer transferência, pois","a data de vencimento do limite de","crédito expirou."}
Local aHlpIng5	  :=  {"Unable to transfer, as the expiration","date of the credit limit has expired."}
Local aHlpEsp5	  :=  {"No se puede transferir, como la fecha","de expiración del plazo de crédito","ha caducado."}

//Ajuste de Novos Helps
PutHelp("PTMSA89001",aHlpPor1,aHlpIng1,aHlpEsp1,.F.)
PutHelp("PTMSA89002",aHlpPor2,aHlpIng2,aHlpEsp2,.F.)
PutHelp("PTMSA89003",aHlpPor3,aHlpIng3,aHlpEsp3,.F.)
PutHelp("PTMSA89004",aHlpPor4,aHlpIng4,aHlpEsp4,.F.)
PutHelp("PTMSA89005",aHlpPor5,aHlpIng5,aHlpEsp5,.F.)

PRIVATE aRotina	:=	MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0004 //"Solicitação de transferência"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"DT6",,,,,,Tmsa890Leg())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa890Inc³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Incluir solicitacoes de transferencia de debito            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa890Inc(cAlias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Tmsa890Inc(cAlias,nReg,nOpc)

Local oDlg
Local nOpcA	 	:= 0
Local cNomCli	:= Space(40)
Local oMemo
Local cHistDeb	:= Spac(40) + Chr(13) + Chr(10) + Spac(40) + Chr(13) + Chr(10)
Local oOk    	:= LoadBitmap( GetResources(), "LBOK")
Local oNo    	:= LoadBitmap( GetResources(), "LBNO")
Local oCheck
Local cCheck
Local aCheck 	:= {}
Local aSX5MJ	:= {}
Local aArea		:= GetArea()                                          
Local lFatTMS	:= .T.  
Local nCont		:= 0
Local nXMJ		:= 0
Local cTmsERP  := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP

Begin Sequence                

	If cTmsERP == '1' //-- ERP Datasul
		lFatTMS := .T.
	Else
	  	DbSelectArea("SE1")
		DbSetOrder(2) 
		If SE1->(MsSeek(xFilial("SE1")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+DT6->DT6_PREFIX+DT6->DT6_NUM))
			While SE1->(!EOF()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SE1")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV+DT6->DT6_PREFIX+DT6->DT6_NUM
				If !(SE1->E1_TIPO $ MVABATIM) .OR. ;
				((SE1->E1_TIPO $ MVABATIM) .AND. !(SE1->E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVISABT+"/"+MVFUABT+"/"+MVI2ABT))
					//-- Verifica se a fatura foi gerada pelo faturamento do SIGATMS
					If Upper(Alltrim(SE1->E1_ORIGEM)) <> "TMSA850"  .And. Upper(Alltrim(SE1->E1_ORIGEM)) <> "TMSA491" 
						lFatTMS := .F.
						nCont   += 1
					EndIf
				EndIf 
				SE1->(DbSkip())
			EndDo	
		EndIf	
	EndIf
	
	// Se estiver FATURADO, se ja houve baixa ou se ja foi solicitada uma transferencia,
	// nao permite nova transferencia
	If !Empty(DT6->(DT6_PREFIX+DT6_NUM+DT6_TIPO))	.Or.;
		!Empty(DT6->DT6_NUMSOL) 
		If lFatTMS
			If cTmsERP ==  '1' //-- ERP Datasul
				Help(" ",1,"TMSA89007") //"Transferencia somente podera ser solicitada se o documento (conhecimento) nao estiver vinculado em uma fatura de transporte a receber e nao tenha solicitacao de transferencia em aberto."
			Else
				Help(" ",1,"FIN62001") //"A transferencia somente podera ser solicitada se o titulo estiver em carteira, não tenha baixas parciais e não tenha solicitacoes em aberto"
			EndIf
			Break// Vai para a primeira linha apos o end sequence
		EndIf	
	Endif
	
	dbSelectArea("DVX")
	DbSetOrder(4)
	If !Empty(DT6->DT6_NUMSOL) .And.;
		MsSeek(xFilial("DVX")+DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE+DT6_FILORI))
		Help( " ", 1, "FIN62004",,STR0005+CHR(13)+STR0006 + DVX->DVX_FILDEB, 4, 0) //"Já existe solicitação de transferência do titulo"###"para a filial "
		Break // Vai para a primeira linha apos o end sequence
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica tabela de check-list de transferencia  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aSX5MJ := FwGetSX5("MJ",)
	For nXMJ := 1 to Len(aSX5MJ)
		If aSX5MJ[nXMJ,1] == xFilial("SX5")
			AAdd( aCheck,{.F., aSX5MJ[nXMJ,4]})
		Endif
	Next nXMJ
		
	dbSelectArea("DVX")
	DbSetOrder(1)
	RegToMemory("DVX",.F.)
	M->DVX_FILDEB	:= CriaVar("DVX_FILDEB")
	M->DVX_CLIDEV	:= CriaVar("DVX_CLIDEV")
	M->DVX_LOJDEV	:= CriaVar("DVX_LOJDEV")
	If DVX->(FieldPos("DVX_VENCTO")) > 0
		M->DVX_VENCTO := DT6->DT6_VENCTO
	EndIf	
	dbSelectArea("DT6")
	RegToMemory("DT6",.F.)
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM 0,0 TO 550,708
	
	@  05, 03 TO 100, 352 OF oDlg  PIXEL LABEL STR0007 //"Dados do título a transferir"
	MsMGet():New("DT6",DT6->(RecNo()),2,,,,,{11,7,95,349},,3,,,,,,.T.)
	
	@ 102, 03 TO 160, 352 OF oDlg  PIXEL LABEL STR0008 //"Check-List para transferência"
	@ 108, 07 LISTBOX oCheck VAR cCheck Fields HEADER "",STR0009  SIZE 341,50 ON RIGHT CLICK ListBoxAll(108,7,@oCheck,oOk,oNo,@aCheck) NoScroll OF oDlg PIXEL //"Itens para checagem"
	oCheck:SetArray(aCheck)
	oCheck:bLine := { || {If(aCheck[oCheck:nAt,1],oOk,oNo),aCheck[oCheck:nAt,2]}}
	oCheck:bLDblClick := {|| aCheck[oCheck:nAt][1] := !aCheck[oCheck:nAt][1], oCheck:DrawSelect()}
	
	@ 162, 03 TO 260, 352 OF oDlg  PIXEL LABEL STR0010 //"Dados da Transferência"
	@ 172, 07 SAY STR0011 OF oDlg  PIXEL  //"Filial de Débito"
	@ 170, 43 MSGET M->DVX_FILDEB OF oDlg  PIXEL F3 "SM0" VALID CheckSx3("DVX_FILDEB",M->DVX_FILDEB) .And. TMSValidEmp(cEmpAnt+M->DVX_FILDEB) .And. TMSA890Vld('DVX_FILDEB')
	@ 172, 92 SAY STR0012 OF oDlg  PIXEL //"Cliente a Débito"
	@ 170,134 MSGET M->DVX_CLIDEV WHEN .F. OF oDlg  PIXEL F3 "SA1" VALID CheckSx3("DVX_CLIDEV",M->DVX_CLIDEV) .And. TMSA890Vld('DVX_CLIDEV')
	@ 170,130+Len(M->DVX_CLIDEV)+42 				MSGET M->DVX_LOJDEV WHEN .F. OF oDlg  PIXEL VALID CheckSx3("DVX_LOJDEV",M->DVX_LOJDEV) .And. TMSA890Vld('DVX_LOJDEV')
	@ 170,130+Len(M->DVX_CLIDEV+M->DVX_LOJDEV)+62	MSGET cNomCli WHEN {||cNomCli := Posicione("SA1",1,xFilial("SA1")+M->DVX_CLIDEV+M->DVX_LOJDEV,"A1_NOME"),.F.} OF oDlg  PIXEL SIZE 150,10
   	If(DVX->(FieldPos("DVX_VENCTO"))) > 0 .And. nCont <= 1
		@ 186, 07 SAY STR0017 OF oDlg  PIXEL  //"Dt. Vencto."
		@ 184, 40 MSGET M->DT6_VENCTO  OF oDlg PIXEL Valid Tmsa890Vct() .And. TMSA890Vld('DT6_VENCTO')
	EndIf
	@ 205, 07 SAY STR0013 OF oDlg  PIXEL  //"Histórico"
	@ 205, 43 GET oMemo VAR cHistDeb OF oDlg MEMO SIZE 300,40 PIXEL FONT oDlg:oFont COLOR CLR_BLACK,CLR_HGRAY
	oMemo:bRClicked := {||AllwaysTrue()}
	DEFINE SBUTTON FROM 263, 290 TYPE 1 ACTION (If(Tmsa890TOk(oDlg,aCheck,M->DVX_FILDEB,M->DVX_CLIDEV,M->DVX_LOJDEV,DT6->DT6_VALTOT),(nOpcA:=1,oDlg:End()),nOpcA:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 263, 320 TYPE 2 ACTION (nOpcA:=0,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpcA == 1
		If ! Tmsa890Grv(M->DVX_FILDEB,M->DVX_CLIDEV,M->DVX_LOJDEV,cHistDeb)
			Help(" ",1,"TMSA89001") //"Solicitação não efetuada, tente novamente"
		Endif
	Endif
End Sequence
RestArea(aArea)
	                                   
Return Nil     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa890Grv³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as solicitacoes de transferencia de debito           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tms890Grv(cFilDeb,cCliDeb,cLojaDeb,cHistDeb)				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION Tmsa890Grv(cFilDeb,cCliDeb,cLojaDeb,cHistDeb)

Local lRet :=.F.

Begin Transaction
	If RecLock("DT6",.F.)
		If RecLock("DVX",.T.)
			lRet := .T.
			DVX->DVX_FILIAL		:= xFilial("DVX")
			DVX->DVX_FILORIG	:= cFilAnt
			DVX->DVX_NUMSOL		:= GetSxENum("DVX", "DVX_NUMSOL","DVX_NUMSOL"+cEmpAnt)
			DVX->DVX_DATSOL		:= dDataBase
			DVX->DVX_HORSOL		:= StrTran(Left(Time(),5),":","")
			DVX->DVX_FILDOC		:= DT6->DT6_FILDOC
			DVX->DVX_DOC			:= DT6->DT6_DOC
			DVX->DVX_SERIE	   	:= DT6->DT6_SERIE
			DVX->DVX_SITSOL   	:= "1" // Em aberto
			DVX->DVX_USRSOL   	:= RetCodUsr() 
			DVX->DVX_CLIDEV		:= cCliDeb
			DVX->DVX_LOJDEV		:= cLojaDeb
			DVX->DVX_FILDEB		:= cFilDeb     
			If DVX->(FieldPos("DVX_VENCTO")) > 0
				DVX->DVX_VENCTO := M->DT6_VENCTO
			EndIf	
			// Grava historico
			MSMM(DVX->DVX_CDHSOL,,,cHistDeb,1,,,"DVX","DVX_CDHSOL")
			DT6->DT6_NUMSOL		:= DVX->DVX_NUMSOL
			MsUnlock()
			ConfirmSx8()
		Endif	
		MsUnlock()
	Endif
End Transaction

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa890TOk³ Autor ³ Claudio D. de Souza   ³ Data ³ 21/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validar o botao Ok na inclusao das solic de transf de debito³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tms890TOk(oDlg,aCheck,cFilDeb,cCliDeb)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION Tmsa890TOk(oDlg,aCheck,cFilDeb,cCliDeb,cLojaDeb,nValFre)

Local lRet := .F.
Local nX
Local cCodBlq  := ''
Local lBlqCred := GetMV("MV_TMSCRTR",,.F.)

// Se um dos itens do check-list estiverem marcados, autoriza a transferencia.
For nX := 1 To Len(aCheck)
	If aCheck[nX][1]
		lRet := .T.
		Exit
	Endif
Next

If lRet
	If DT6->DT6_FILDEB == cFilDEb .And. DT6->DT6_CLIDEV == cCliDeb .And. DT6->DT6_LOJDEV == cLojaDeb
		lRet := .F.
		Help(" ",1,"TMSA89006") //"Filial de debito deve se diferente do título que esta sendo transferido"
	Endif
	If lRet .And. cEmpAnt != SM0->M0_CODIGO
		lRet := .F.
		Help(" ",1,"TMSA89002") //"A empresa destino deve ser igual a empresa origem"
	Endif	
Else
	Help(" ",1,"TMSA89003") //"E necessario que ao menos ums dos itens do check-list esteja marcado para efetuar a solicitacao"
Endif

If lRet .And. lBlqCred
	lRet := MaAvalCred(cCliDeb,cLojaDeb,nValFre,,.F.,@cCodBlq) //-- Avalia credito do devedor
	If !lRet
		If cCodBlq == "01"
			Help(" ",1,"TMSA89004") //"Não e possível fazer transferencia, pois excedeu o limite de credito do cliente selecionado.
		ElseIf cCodBlq == "04"
			Help(" ",1,"TMSA89005") //"Não e possível fazer transferencia, pois a data de vencimento do limite de credito expirou.
		EndIf
	EndIf
EndIf


Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Tmsa890Leg  ³ Autor ³ Claudio D. de Souza ³ Data ³ 21.12.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse ou retorna a ³±±
±±³          ³ para o BROWSE                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMS890	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmsa890Leg(nReg)

Local aLegenda := { 	{"BR_VERDE"   , STR0015 },; 	//"Sem solicitação"
							{"BR_VERMELHO", STR0014 } } 	//"Com solicitação"
Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { "DT6_NUMSOL=' '", aLegenda[1][1] } )
	Aadd(uRetorno, { "DT6_NUMSOL#' '", aLegenda[2][1] } )
Else
	BrwLegenda(cCadastro,STR0016,aLegenda) //"Legenda"
Endif

Return uRetorno 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Fa620Venc ³ Autor ³ Gilson da Silva       ³ Data ³ 08/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera data de Vencimento de acordo com a condicao do Cliente³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Data de  vencimento.					    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA890                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Tmsa890Vct()

Local lRet := .T.

If M->DT6_VENCTO < DT6->DT6_DATEMI .Or. M->DT6_VENCTO < DT6->DT6_VENCTO
	Help(" ",1,"NOVENCREA")
	lRet := .F.
EndIf

Return  lRet   


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
     
Private aRotina	:=	{{STR0001	,"AxPesqui"		, 0 , 1,0,.F.},;		//"Pesquisar"
                    	 {STR0002	,"AxVisual"		, 0 , 2,0,NIL},; 		//"Visualizar"
                    	 {STR0003	,"Tmsa890Inc"	, 0 , 3,0,NIL},;  	//"Solicitar"
							 {STR0016   ,"Tmsa890Leg"	, 0 , 6,0,.F.}} 		//"Legenda"


If ExistBlock("TM890MNU")
	ExecBlock("TM890MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |TMSA890VldºAutor  ³Totvs               º Data ³  12/30/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao responsavel por executar o PE TM890VLD              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA890Vld( cCpo )
Local lRet := .T.
Local lTM890Vld := ExistBlock("TM890VLD")

If lTM890Vld
	lRet := ExecBlock("TM890Vld",.F.,.F.,{cCpo})
	If ValType(lRet) <> "L"
		lRet := .T.
	EndIf
EndIf	

Return( lRet )


