// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "FILEIO.CH"
#Include "PROTHEUS.CH"
#INCLUDE "VEICC520.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEICC520 ³ Autor ³  Fabio                ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Contatos Realizados no Periodo                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC520()

Local lVC1ESTVEI := ( VC1->(FieldPos("VC1_ESTVEI")) > 0 )
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lVerOutros := .t.
Local cVendedor  := ""
Local OXVERMELHO
Local OXverde ,ocert,oerr
Local nErr := 0, nCert := 0

Private overde   := LoadBitmap( GetResources(), "BR_verde" )
Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO")
Private oDlg,oLbInicial,oLbFinal,MV_PAR03,MV_PAR04,oTipAge,oDescri,cObserv,cEstVei,cMarca,cModelo,nQtd,dData,cPrePag
Private oDlgPend,oLbTexto,aVetor:={}

If PERGUNTE("VCC520",.t.)
	
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox
	aAdd( aObjects, { 0 , 80 , .T. , .F. } ) // Rodape
	aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Legenda
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
	DbSetOrder(5)
	DbSeek(xFilial("VC1")+MV_PAR01+Dtos(MV_PAR03),.t.)
	Do While !Eof() .And. VC1->VC1_TIPAGE == MV_PAR01 .And. VC1->VC1_DATVIS >= MV_PAR03 .And. VC1->VC1_DATVIS <= MV_PAR04
		If lVerOutros .or. cVendedor == VC1->VC1_CODVEN
			If !Empty(VC1->VC1_DATVIS)
				Aadd(aVetor,{VC1->VC1_DATAGE,VC1->VC1_DATVIS,VC1->VC1_CODVEN,Posicione("SA3",1,xFilial("SA3")+VC1->VC1_CODVEN,"A3_NOME"),VC1->VC1_CODCLI,Posicione("SA1",1,xFilial("SA1")+VC1->VC1_CODCLI,"A1_NREDUZ"),Posicione("VCA",1,xFilial("VCA")+VC1->VC1_CODABO,"VCA_DESABO"),Posicione("VC0",1,xFilial("VC0")+VC1->VC1_TIPCON,"VC0_DESCON"),VC1->VC1_OCOMEM,VC1->VC1_CODMAR,Posicione("VV2",1,xFilial("VV2")+VC1->VC1_CODMAR+VC1->VC1_MODVEI,"VV2_DESMOD"),VC1->VC1_QTDINT,VC1->VC1_DATINT,Posicione("VC7",1,xFilial("VC7")+VC1->VC1_PREPAG,"VC7_DESPAG"),IIf(lVC1ESTVEI.and.!Empty(VC1->VC1_CODMAR),X3CBOXDESC("VC1_ESTVEI",IIf(!Empty(VC1->VC1_ESTVEI),VC1->VC1_ESTVEI,"2")),"")})
				If dtoc(VC1->VC1_DATVIS) == dtoc(VC1->VC1_DATAGE)
					nCert := nCert + 1
				Else
					nErr := nErr + 1
				EndIf
			EndIf
		EndIf
		DbSelectArea("VC1")
		DbSkip()
	EndDo
	
	If Len(aVetor) <= 0
		Help(" ",1,"NAOEXISTIT")
		Return
	EndIf
	
	Asort(aVetor,2,,{|x,y|Dtos(x[2])+x[4]+x[6] > Dtos(y[2])+y[4]+y[6]})
	
	cTitulo := STR0001+" "+Dtoc(MV_PAR03)+STR0002+Dtoc(MV_PAR04)+" - "+MV_PAR02 //"Contatos Realizados no Periodo"###" a "
	
	DEFINE MSDIALOG oDlgPend TITLE cTitulo From aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL STATUS
	
	@ aPos[1,1],aPos[1,2] LISTBOX oLbTexto FIELDS HEADER OemToAnsi(""),;
	OemToAnsi(STR0003),; //"Dt Visita"
	OemToAnsi(STR0004),; //"Cod Vendedor"
	OemToAnsi(STR0005),; //"Nome"
	OemToAnsi(STR0006),; //"Cod Cliente"
	OemToAnsi(STR0005),; //"Nome"
	OemToAnsi(STR0007),; //"Tipo Abordagem"
	OemToAnsi(STR0008); //"Tipo de Contato"
	COLSIZES 60,40,60,40,60;
	SIZE aPos[1,4]-3,aPos[1,3] OF oDlgPend PIXEL ON CHANGE FS_OBSVC520()
	
	oLbTexto:SetArray(aVetor)
	oLbTexto:bLine := { || { If(Dtoc(aVetor[oLbTexto:nAt,1]) == Dtoc(aVetor[oLbTexto:nAt,2]),overde,overmelho),;
	Dtoc(aVetor[oLbTexto:nAt,2]) ,;
	aVetor[oLbTexto:nAt,3] ,;
	aVetor[oLbTexto:nAt,4] ,;
	aVetor[oLbTexto:nAt,5] ,;
	aVetor[oLbTexto:nAt,6] ,;
	aVetor[oLbTexto:nAt,7] ,;
	aVetor[oLbTexto:nAt,8]}}
	
	@ aPos[2,1]+012,aPos[2,2] GET oObserv VAR cObserv OF oDlgPend MEMO SIZE aPos[2,4]-3,025 PIXEL READONLY MEMO
	
	@ aPos[2,1]+040,aPos[2,2] TO aPos[2,1]+070,aPos[2,4] LABEL STR0009 OF oDlgPend PIXEL //"Interesse"
	
	@ aPos[2,1]+055,aPos[2,2]+003 MSGET oEstVei VAR cEstVei PICTURE "@!" SIZE 080,10 OF oDlgPend PIXEL COLOR CLR_BLACK When .f.
	@ aPos[2,1]+047,aPos[2,2]+088 SAY STR0010 OF oDlgPend PIXEL COLOR CLR_BLUE //"Marca"
	@ aPos[2,1]+055,aPos[2,2]+088 MSGET oMarca VAR cMarca PICTURE "@!" SIZE 075,10 OF oDlgPend PIXEL COLOR CLR_BLACK When .f.
	@ aPos[2,1]+047,aPos[2,2]+168 SAY STR0011 OF oDlgPend PIXEL COLOR CLR_BLUE //"Modelo"
	@ aPos[2,1]+055,aPos[2,2]+168 MSGET oModelo VAR cModelo PICTURE "@!" SIZE 100,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+274 SAY STR0012 OF oDlgPend PIXEL COLOR CLR_BLUE //"Qtd"
	@ aPos[2,1]+055,aPos[2,2]+274 MSGET oQtd VAR nQtd PICTURE "999" SIZE 20,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+300 SAY STR0013 OF oDlgPend PIXEL COLOR CLR_BLUE //"Data"
	@ aPos[2,1]+055,aPos[2,2]+300 MSGET oData VAR dData PICTURE "@D" SIZE 40,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[2,1]+047,aPos[2,2]+345 SAY STR0014 OF oDlgPend PIXEL COLOR CLR_BLUE //"Pref Pagto"
	@ aPos[2,1]+055,aPos[2,2]+345 MSGET oPrePag VAR cPrePag PICTURE "@!" SIZE 80,10 OF oDlgPend PIXEL COLOR CLR_BLACK when .f.
	@ aPos[3,1],aPos[3,2]+001 BITMAP oxVermelho RESOURCE "BR_VERMELHO" OF oDlg NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[3,1],aPos[3,2]+011 SAY STR0015 SIZE 150,40 OF oDlg  PIXEL COLOR CLR_BLUE //"Contatos realizados fora da data agendada"
	@ aPos[3,1],aPos[3,2]+165 BITMAP OXverde RESOURCE "BR_verde" OF oDlg NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[3,1],aPos[3,2]+175 SAY STR0016 OF oDlg  PIXEL COLOR CLR_BLUE //"Contatos realizados na data agendada"
	@ aPos[3,1],aPos[3,2]+120 MSGET oErr VAR nErr PICTURE "@!" SIZE 20,3 OF oDlg PIXEL COLOR CLR_BLUE when .f.
	@ aPos[3,1],aPos[3,2]+270 MSGET oCert VAR nCert PICTURE "@!" SIZE 20,3 OF oDlg PIXEL COLOR CLR_BLUE when .f.
	
	ACTIVATE MSDIALOG oDlgPend ON INIT EnchoiceBar(oDlgPend,{|| nOpca := 1,(oDlgPend:End())},{|| nOpca := 0,(oDlgPend:End())}) CENTER
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_OBSVC520³ Autor ³  Fabio               ³ Data ³ 05/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Observacoes MEMO / variaveis tela                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OBSVC520()

cObserv := MSMM(aVetor[oLbTexto:nAt,9],47)
cEstVei := aVetor[oLbTexto:nAt,15]
cMarca  := aVetor[oLbTexto:nAt,10]
cModelo := aVetor[oLbTexto:nAt,11]
nQtd    := aVetor[oLbTexto:nAt,12]
dData   := aVetor[oLbTexto:nAt,13]
cPrePag := aVetor[oLbTexto:nAt,14]

oObserv:Refresh()
oEstVei:Refresh()
oMarca:Refresh()
oModelo:Refresh()
oQtd:Refresh()
oData:Refresh()
oPrePag:Refresh()

Return