// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "fileio.ch"
#Include "protheus.ch"
#Include "VEICC510.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICC510 ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Contatos por Cliente                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC510()

Local lVC1ESTVEI := ( VC1->(FieldPos("VC1_ESTVEI")) > 0 )
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lVerOutros := .t.
Local cVendedor  := ""
Private oDlg,oLbInicial,oLbFinal,oCodCli,oNomCli,oTipAge,oDescri,cObserv,cEstVei,cMarca,cModelo,nQtd,dData,cPrePag
Private oDlgPend,oLbTexto,aVetor:={}

If PERGUNTE("VCC510",.t.)
	
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox
	aAdd( aObjects, { 0 , 80 , .T. , .F. } ) // Rodape
	aPos := MsObjSize( aInfo, aObjects )

	VAI->(DbSetOrder(4))
	VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
	cVendedor := VAI->VAI_CODVEN
	If ( VAI->(FieldPos("VAI_CEVOUT")) > 0 )
		If VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
	   		lVerOutros := .f.
		EndIf
	EndIf
	
	DbSelectArea("VC1")
	DbSetOrder(3)
	DbSeek(xFilial("VC1")+MV_PAR01)
	Do While !Eof() .and. VC1->VC1_FILIAL == xFilial("VC1") .and. VC1->VC1_TIPAGE == MV_PAR01
		If lVerOutros .or. cVendedor == VC1->VC1_CODVEN
			If Empty(MV_PAR03+MV_PAR04) .or. VC1->VC1_CODCLI+VC1->VC1_LOJA == MV_PAR03+MV_PAR04
				Aadd(aVetor,{VC1->VC1_DATAGE,VC1->VC1_DATVIS,VC1->VC1_CODVEN,Posicione("SA3",1,xFilial("SA3")+VC1->VC1_CODVEN,"A3_NOME"),Posicione("VCA",1,xFilial("VCA")+VC1->VC1_CODABO,"VCA_DESABO"),Posicione("VC0",1,xFilial("VC0")+VC1->VC1_TIPCON,"VC0_DESCON"),VC1->VC1_OCOMEM,VC1->VC1_CODMAR,Posicione("VV2",1,xFilial("VV2")+VC1->VC1_CODMAR+VC1->VC1_MODVEI,"VV2_DESMOD"),VC1->VC1_QTDINT,VC1->VC1_DATINT,Posicione("VC7",1,xFilial("VC7")+VC1->VC1_PREPAG,"VC7_DESPAG"),IIf(lVC1ESTVEI.and.!Empty(VC1->VC1_CODMAR),X3CBOXDESC("VC1_ESTVEI",IIf(!Empty(VC1->VC1_ESTVEI),VC1->VC1_ESTVEI,"2")),"")})
			EndIf
		EndIf
		DbSelectArea("VC1")
		DbSkip()
	EndDo
	
	If Len(aVetor) <= 0
		Help(" ",1,"NAOEXISTIT")
		Return
	EndIf
	
	Asort(aVetor,,,{|x,y|x[2]+x[1] > y[2]+y[1]})
	
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+MV_PAR03+MV_PAR04))

	cTitulo := MV_PAR01+"-"+Alltrim(MV_PAR02)+" - "+STR0001+": "+MV_PAR03+"-"+MV_PAR04+" - "+Alltrim(left(SA1->A1_NOME,25))   //Contatos por Cliente
	
	DEFINE MSDIALOG oDlgPend TITLE cTitulo From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL STATUS
	
	@ aPos[1,1],aPos[1,2] LISTBOX oLbTexto FIELDS HEADER 	STR0004,;  //"Dt Agenda"
															STR0005,;  //"Dt Visita"
															STR0006,;  //"Cod Vendedor"
															STR0007,;  //"Nome"
															STR0008,;  //"Tipo de Abordagem"
															STR0009;   //"Tipo de Contato"
															COLSIZES 40,40,40,100,60,60 SIZE aPos[1,4]-3,aPos[1,3] OF oDlgPend PIXEL ON CHANGE FS_OBSVC510()
	
	oLbTexto:SetArray(aVetor)
	oLbTexto:bLine := { || { 	Dtoc(aVetor[oLbTexto:nAt,1]) ,;
								Dtoc(aVetor[oLbTexto:nAt,2]) ,;
								aVetor[oLbTexto:nAt,3] ,;
								aVetor[oLbTexto:nAt,4] ,;
								aVetor[oLbTexto:nAt,5] ,;
								aVetor[oLbTexto:nAt,6]}}

	@ aPos[2,1]+012,aPos[2,2] GET oObserv VAR cObserv OF oDlgPend MEMO SIZE aPos[2,4]-3,025 PIXEL READONLY MEMO
	
	@ aPos[2,1]+040,aPos[2,2] TO aPos[2,1]+070,aPos[2,4] LABEL STR0011 OF oDlgPend PIXEL //"Interesse"

	@ aPos[2,1]+055,aPos[2,2]+003 MSGET oEstVei VAR cEstVei PICTURE "@!" SIZE 080,10 OF oDlgPend PIXEL COLOR CLR_BLACK When .f.
	@ aPos[2,1]+047,aPos[2,2]+088 SAY STR0012 OF oDlgPend PIXEL COLOR CLR_BLUE //"Marca"
	@ aPos[2,1]+055,aPos[2,2]+088 MSGET oMarca VAR cMarca PICTURE "@!" SIZE 075,10 OF oDlgPend PIXEL COLOR CLR_BLACK When .f.
	@ aPos[2,1]+047,aPos[2,2]+168 SAY STR0013 OF oDlgPend PIXEL COLOR CLR_BLUE //"Modelo"
	@ aPos[2,1]+055,aPos[2,2]+168 MSGET oModelo VAR cModelo PICTURE "@!" SIZE 100,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+274 SAY STR0014 OF oDlgPend PIXEL COLOR CLR_BLUE //"Qtd"
	@ aPos[2,1]+055,aPos[2,2]+274 MSGET oQtd VAR nQtd PICTURE "999" SIZE 20,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+300 SAY STR0015 OF oDlgPend PIXEL COLOR CLR_BLUE //"Data"
	@ aPos[2,1]+055,aPos[2,2]+300 MSGET oData VAR dData PICTURE "@D" SIZE 40,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+345 SAY STR0016 OF oDlgPend PIXEL COLOR CLR_BLUE //"Pref Pagto"
	@ aPos[2,1]+055,aPos[2,2]+345 MSGET oPrePag VAR cPrePag PICTURE "@!" SIZE 80,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.

	ACTIVATE MSDIALOG oDlgPend ON INIT EnchoiceBar(oDlgPend,{|| nOpca := 1,(oDlgPend:End())},{|| nOpca := 0,(oDlgPend:End())})
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OBSVC510³ Autor ³  Fabio               ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Observacoes MEMO / variaveis tela                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSVC510()
cObserv := MSMM(aVetor[oLbTexto:nAt,7],47)
cEstVei := aVetor[oLbTexto:nAt,13]
cMarca  := aVetor[oLbTexto:nAt,8]
cModelo := aVetor[oLbTexto:nAt,9]
nQtd    := aVetor[oLbTexto:nAt,10]
dData   := aVetor[oLbTexto:nAt,11]
cPrePag := aVetor[oLbTexto:nAt,12]
oObserv:Refresh()
oEstVei:Refresh()
oMarca:Refresh()
oModelo:Refresh()
oQtd:Refresh()
oData:Refresh()
oPrePag:Refresh()
Return