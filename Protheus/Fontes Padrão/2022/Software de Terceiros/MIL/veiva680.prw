// ษออออออออหออออออออป
// บ Versao บ 09     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIVA680.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ VEIVA680 ณ Autor ณ Rafael Goncalves      ณ Data ณ 05/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ  Custo com Vendas - Custos com Veiculos                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Veiculo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA680()
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001) //Custos Fixos
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DBSelectArea("VRD")
DbSelectArea("VRC")
DbSelectArea("VRB")
DbSelectArea("VRA")
dbSetORder(1)
mBrowse( 6, 1,22,75,"VRA")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VEI680?  บAutor  ณRafael Goncalves    บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama VEI680  V-isualizar / I-ncluir / A-lterar / E-xcluir บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEI680V(cAlias,nReg,nOpc)
	nOpc := 2
	VEI680(cAlias,nReg,nOpc)
Return()
//
Function VEI680I(cAlias,nReg,nOpc)
	nOpc := 3
	VEI680(cAlias,nReg,nOpc)
Return()
//
Function VEI680A(cAlias,nReg,nOpc)
	nOpc := 4
	VEI680(cAlias,nReg,nOpc)
Return()
//
Function VEI680E(cAlias,nReg,nOpc)
	nOpc := 5
	VEI680(cAlias,nReg,nOpc)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VEI680   บAutor  ณRafael Goncalves    บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Tela                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEI680(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
Local nPos := 0
Local cQueryL  := ""
Local cQAlSQLL := "ALIASSQLL"

Local lAltCpo := .t.
Local nOrdCpo := 0
Local ni	:= 0
Private lSMar  := .f.
Private lSGmod := .f.
Private lSMod  := .f.
Private lVeicTot  := .f.
Private lVlrCus := .T.
Private lPerCus := .T.
//
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )	// Selecionado
Private oVerm   := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Nao Selecionado
Private aMar    := {} // Marca
Private aGru    := {} // Grupo do Modelo
Private aMod    := {} // Modelo
Private aVeicTot:= {} // Veiculos Total
// Filtros Tela //
Private cAnoFab := SPACE(9)
Private cEstVei := ""
Private aEstVei := X3CBOXAVET("VV1_ESTVEI","1")
Private cOpcVei := space(100)
Private cAtivo 	:= ""
Private aAtivo 	:= X3CBOXAVET("VRA_ATIVO","1")
Private dDatIni := ctod("")
Private dDatFim := ctod("")
Private nVlrCus := 0
Private nPerCus := 0
Private cDescri := space(100)

Private lBotAtu := .f. // Botao de Atualizar

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 052 , .T. , .F. } ) 	//Cabecalho
AAdd( aObjects, { 0, 103 , .T. , .F. } )  	//list box
AAdd( aObjects, { 0, 000 , .T. , .T. } )  	//Rodape

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

FS_LEVANTA("MAR",.f.)	// Levanta Marcas
FS_LEVANTA("GRU",.f.)	// Levanta Grupos de Modelo
FS_LEVANTA("MOD",.f.)	// Levanta Modelos

If nOpc == 2 .or. nOpc == 4 .or. nOpc == 5  //visualizar/alterar/excluir levanta as infomacoes anteriores
	//SELECIONA AS MARCAR//
	cQueryL := "SELECT VRD.* FROM "+RetSqlName("VRD")+" VRD "
	cqueryL += "WHERE VRD.VRD_FILIAL='"+xFilial("VRD")+"' AND VRD.VRD_CODCUS='"+VRA->VRA_CODCUS+"' AND VRD.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryL ), cQAlSQLL , .F., .T. )
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aMar, {|x| x[2] == ( cQAlSQLL )->( VRD_CODMAR ) }) // Verifica se a Marca esta selecionada
		If nPos > 0
			aMar[nPos,1] := .T.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	( cQAlSQLL )->( DbGotop() )
	FS_LEVANTA("GRU",.f.)	// Levanta Grupos de Modelo das marcas selecionadas.
	
	//SELECIONA OS GRUPO MODELO//
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aGru, {|x| x[2]+x[3] == ( cQAlSQLL )->( VRD_CODMAR )+( cQAlSQLL )->( VRD_GRUMOD ) }) // Verifica se o grupo modelo esta selecionada
		If nPos > 0
			aGru[nPos,1] := .T.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	( cQAlSQLL )->( DbGoTop() )
	FS_LEVANTA("MOD",.f.)	// Levanta Modelos
	
	//SELECIONA OS GRUPO MODELO//
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aMod, {|x| x[2]+x[3]+x[6] == ( cQAlSQLL )->( VRD_CODMAR )+( cQAlSQLL )->( VRD_GRUMOD )+( cQAlSQLL )->( VRD_MODVEI ) }) // Verifica se o grupo modelo esta selecionada
		If nPos > 0
			aMod[nPos,1] := .t.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	( cQAlSQLL )->( DbCloseArea() )
	
	DbSelectArea("VRD")
	DbSetORder(1)
	DbSeek(xFilial("VRD")+VRA->VRA_CODCUS)
	
	cAnoFab := VRD->VRD_FABMOD
	cOpcVei := VRD->VRD_OPCION
	cEstVei := VRD->VRD_ESTVEI
	nVlrCus := VRA->VRA_VALCUS
	nPerCus := VRA->VRA_PERCUS
	dDatIni := VRA->VRA_DATINI
	dDatFim := VRA->VRA_DATFIN
	cAtivo  := VRA->VRA_ATIVO
	cDescri := VRA->VRA_DESCRI
	FS_VARPER(.f.) //when campo valor ou percentual valor
	FS_CONSVEIC("1")//levanta veiculos para marca/grupo e modelo selecionado
	//Le o VRB para verificar veiculos de excesao de Custo
	For ni := 1 to len(aVeicTot) // Seleciona os veiculos em excessao
		DbSelectArea("VRB")
		DbSetOrder(1)
		If DbSeek(xFilial("VRB") + VRA->VRA_CODCUS + aVeicTot[ni,8])
			aVeicTot[ni,1] := .t.
		EndIf
	Next
EndIF


If Len(aVeicTot) <= 0  //adicina registro em branco veiculos.
	aAdd(aVeicTot,{.f.," "," "," "," "," "," "," "," ",0," "})
Endif

//verifica se for visualizacao ou exclusao nao permite alterar
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	lAltCpo := .f.
	lPerCus:= .f.
	lVlrCus:= .f.
EndIF

DEFINE MSDIALOG oCustVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0001 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
oCustVeic:lEscClose := .F.

//divide a janela em tres colunas.
nTam := ( aPos[1,4] / 3 )

@ aPos[1,1]-001,aPos[1,2]+(nTam*0) TO aPos[1,3],(nTam*3)-2 LABEL "" OF oCustVeic PIXEL

nOrdCpo := 006
// ESTADO DO VEICULO //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0034 SIZE 50,8 OF oCustVeic PIXEL COLOR CLR_BLACK // Estado do Veiculo
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSCOMBOBOX oEstVei VAR cEstVei SIZE 30,08 COLOR CLR_BLACK ITEMS aEstVei OF oCustVeic ON CHANGE FS_CONSVEIC() PIXEL COLOR CLR_BLUE  WHEN lAltCpo
nOrdCpo += 031
// ANO FINAL //

@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0002 SIZE 50,8 OF oCustVeic PIXEL COLOR CLR_BLACK // Ano Final
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oAnoFab VAR cAnoFab PICTURE "@R 9999/9999" SIZE 35,08 VALID FS_CONSVEIC() OF oCustVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo
nOrdCpo += 040
// OPCIONAIS //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0003 SIZE 50,8 OF oCustVeic PIXEL COLOR CLR_BLACK // KM Maxima
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oOpcVei VAR cOpcVei PICTURE VRD->(X3PICTURE("VRD_OPCION")) SIZE 70,08 VALID FS_CONSVEIC() OF oCustVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo
nOrdCpo += 085
@ aPos[1,1],aPos[1,2]+001 TO aPos[1,1]+028,nOrdCpo-9 LABEL STR0004 OF oCustVeic PIXEL


// VALOR FINAL //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0005 SIZE 55,8 OF oCustVeic PIXEL COLOR CLR_BLUE // Valor Final
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oVlrCus VAR nVlrCus PICTURE "@E 999,999,999.99" SIZE 55,08 VALID FS_VARPER() OF oCustVeic PIXEL COLOR CLR_BLUE HASBUTTON  WHEN (lVlrCus)
nOrdCpo += 056
// PERCENTUAL CUSTO //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0006 SIZE 40,8 OF oCustVeic PIXEL COLOR CLR_BLUE // Valor Final
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oPerCus VAR nPerCus PICTURE "@E 999.99%" SIZE 40,08 VALID FS_VARPER() OF oCustVeic PIXEL COLOR CLR_BLUE HASBUTTON  WHEN (lPerCus)
nOrdCpo += 041
// DATA INICIAL //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0007 SIZE 50,8 OF oCustVeic PIXEL COLOR CLR_BLUE // Data  Final
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni>dDatFim,dDatFim:=dDatIni,.T.)) PICTURE "@D" SIZE 42,08 /* VALID FS_FILTVETOR()*/ OF oCustVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
nOrdCpo += 043
// DATA FINAL //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0008 SIZE 50,8 OF oCustVeic PIXEL COLOR CLR_BLUE // Data  Final
@ aPos[1,1]+015	,aPos[1,2]+nOrdCpo MSGET odatFim VAR dDatFim VALID(IIF(dDatIni>dDatFim,.F.,.T.)) PICTURE "@D" SIZE 42,08 /* VALID FS_FILTVETOR()*/ OF oCustVeic PIXEL COLOR CLR_BLACK  WHEN lAltCpo HASBUTTON
nOrdCpo += 043
//OBRIGATORIO //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0009 SIZE 55,8 OF oCustVeic PIXEL COLOR CLR_BLUE // Valor Final
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSCOMBOBOX oAtivo VAR cAtivo SIZE 30,08 COLOR CLR_BLACK ITEMS aAtivo OF oCustVeic /*ON CHANGE FS_FILTVETOR()*/ PIXEL COLOR CLR_BLUE WHEN lAltCpo
nOrdCpo += 039
@ aPos[1,1],aPos[1,2]+(nOrdCpo-225) TO aPos[1,1]+028,nOrdCpo LABEL STR0010 OF oCustVeic PIXEL

// descricao //
@ aPos[1,1]+030,aPos[1,2]+006 SAY STR0011 SIZE 50,8 OF oCustVeic PIXEL COLOR CLR_BLACK
@ aPos[1,1]+038,aPos[1,2]+006 MSGET oDescri VAR cDescri PICTURE "@!" SIZE 360,08 OF oCustVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo


// MARCA //
@ aPos[2,1]-002,aPos[2,2]+(nTam*0) TO aPos[2,3]-003,(nTam*1) LABEL STR0012 OF oCustVeic PIXEL // Marca
@ aPos[2,1]+006,aPos[2,2]+(nTam*0)+1 LISTBOX oLbMar FIELDS HEADER "",STR0012,STR0011 COLSIZES 10,20,40 SIZE nTam-5,aPos[2,3]-aPos[2,1]-12 OF oCustVeic PIXEL ON DBLCLICK (FS_TIK("MAR",oLbMar:nAt,nOpc),FS_CONSVEIC())
oLbMar:SetArray(aMar)
oLbMar:bLine := { || { 	IIf(aMar[oLbMar:nAt,1],oVerd,oVerm) , aMar[oLbMar:nAt,2] , aMar[oLbMar:nAt,3] }}

// GRUPO DO MODELO //
@ aPos[2,1]-002,aPos[2,2]+(nTam*1) TO aPos[2,3]-003,(nTam*2) LABEL STR0013 OF oCustVeic PIXEL // Grupo do Modelo
@ aPos[2,1]+006,aPos[2,2]+(nTam*1)+1 LISTBOX oLbGru FIELDS HEADER "",STR0012,STR0014, COLSIZES 10,20,40 SIZE nTam-5,aPos[2,3]-aPos[2,1]-12 OF oCustVeic PIXEL ON DBLCLICK (FS_TIK("GRU",oLbGru:nAt,nOpc),,FS_CONSVEIC())
oLbGru:SetArray(aGru)
oLbGru:bLine := { || { 	IIf(aGru[oLbGru:nAt,1],oVerd,oVerm) , aGru[oLbGru:nAt,2] , aGru[oLbGru:nAt,4] }}
// MODELO //
@ aPos[2,1]-002,aPos[2,2]+(nTam*2) TO aPos[2,3]-003,(nTam*3) LABEL STR0015 OF oCustVeic PIXEL // Modelo
@ aPos[2,1]+006,aPos[2,2]+(nTam*2)+1 LISTBOX oLbMod FIELDS HEADER "",STR0012,STR0016 COLSIZES 10,20,40 SIZE nTam-5,aPos[2,3]-aPos[2,1]-12 OF oCustVeic PIXEL ON DBLCLICK (FS_TIK("MOD",oLbMod:nAt,nOpc),FS_CONSVEIC())
oLbMod:SetArray(aMod)
oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oVerd,oVerm) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5] }}

// VEICULOS //
@ aPos[3,1]-002,aPos[3,2] TO aPos[3,3],aPos[3,4] LABEL STR0017 OF oCustVeic PIXEL // Excecoes
@ aPos[3,1]+006,aPos[3,2]+001 LISTBOX oLbVeic FIELDS HEADER " ",STR0019,STR0012,STR0015,STR0020,STR0021,STR0022,STR0023,STR0024,STR0025,STR0026 COLSIZES ;
10,55,25,70,40,65,120,90,40,50,50   SIZE aPos[3,4]-5,aPos[3,3]-aPos[3,1]-10 OF oCustVeic PIXEL ON DBLCLICK (FS_TIK2(oLbVeic:Nat,nOpc))
oLbVeic:SetArray(aVeicTot)
oLbVeic:bLine := { || { IIf(aVeicTot[oLbVeic:nAt,01],oOk,oNo),;
aVeicTot[oLbVeic:nAt,02],;
aVeicTot[oLbVeic:nAt,03],;
aVeicTot[oLbVeic:nAt,04],;
Transform(aVeicTot[oLbVeic:nAt,05],"@R 9999/9999"),;
X3CBOXDESC("VV1_COMVEI",aVeicTot[oLbVeic:nAt,06]),;
Transform(aVeicTot[oLbVeic:nAt,07],VV1->(x3Picture("VV1_OPCFAB"))),;
aVeicTot[oLbVeic:nAt,08],;
Transform(aVeicTot[oLbVeic:nAt,09],VV1->(x3Picture("VV1_PLAVEI"))),;
FG_AlinVlrs(Transform(aVeicTot[oLbVeic:nAt,10],"@E 999,999,999")),;
X3CBOXDESC("VV1_TIPVEI",aVeicTot[oLbVeic:nAt,11]) }}

@ aPos[2,1]+006,aPos[2,2]+(nTam*0)+003 CHECKBOX oCMar  VAR lSMar  PROMPT "" OF oCustVeic ON CLICK FS_TIK3("MAR",lSMar,nOpc) SIZE 40,10 PIXEL
@ aPos[2,1]+006,aPos[2,2]+(nTam*1)+003 CHECKBOX oCGMod VAR lSGmod PROMPT "" OF oCustVeic ON CLICK FS_TIK3("GRU",lSGmod,nOpc) SIZE 40,10 PIXEL
@ aPos[2,1]+006,aPos[2,2]+(nTam*2)+003 CHECKBOX oCMod  VAR lSMod  PROMPT "" OF oCustVeic ON CLICK FS_TIK3("MOD",lSMod,nOpc) SIZE 40,10 PIXEL
@ aPos[3,1]+006,aPos[3,2]+003 CHECKBOX oVeicTot VAR lVeicTot  PROMPT "" OF oCustVeic ON CLICK FS_TIK4(lVeicTot,nOpc) SIZE 40,10 PIXEL

//oTipBon:SetFocus()
ACTIVATE MSDIALOG oCustVeic ON INIT EnchoiceBar(oCustVeic,{|| IF(FS_GRAVAR(nOpc),oCustVeic:End(),.T.) , .f. },{|| oCustVeic:End() } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_GRAVARณ Autor ณ Rafael Goncalves      ณ Data ณ 05/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ  Grava Custo do Veiculo                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAVAR(nOpc)
Local lRet := .t.
Local ni := 0
Local cCodCus := SPACE(LEN(VRA->VRA_CODCUS))
Local lAltGrv := .t.
Local aGrvVei := {}
//verifica variaveis informadas.
IF Empty(nVlrCus) .and. Empty(nPerCus) .and. lRet
	MsgStop(STR0027,STR0018)
	lRet := .f.
	oVlrCus:SetFocus()
EndIF
IF Empty(nVlrCus) .and. lVlrCus .and. lRet
	MsgStop(STR0028,STR0018)
	lRet := .f.
	oPerCus:SetFocus()
EndIF
IF Empty(nPerCus) .and. lPerCus .and. lRet
	MsgStop(STR0028,STR0018)
	lRet := .f.
	oPerCus:SetFocus()
EndIF
Private lPerCus := .T.
IF Empty(dDatIni) .and. lRet
	MsgStop(STR0029,STR0018)
	lRet := .f.
	oDatIni:SetFocus()
EndIF
IF Empty(dDatFim) .and. lRet
	MsgStop(STR0030,STR0018)
	lRet := .f.
	oDatFim:SetFocus()
EndIF
IF Empty(cAtivo) .and. lRet
	MsgStop(STR0031,STR0018)
	lRet := .f.
	oAtivo:SetFocus()
EndIF

If lRet
	If ( nOpc == 3 .Or. nOpc == 4 ) //Inclusao/alteracao
		
		For ni := 1 to len(aMod)
			//marca -grumor - modelo
			If aMod[ni,1]
				aAdd(aGrvVei,{aMod[ni,2],aMod[ni,3],aMod[ni,6]})
			EndIf
		Next
		
		For ni := 1 to len(aGru)
			//marca -grumor - modelo
			If aGru[ni,1]
				nPos := aScan(aGrvVei, {|x| x[1]+x[2] == aGru[ni,2]+aGru[ni,3] }) // Verifica se a Marca esta selecionada
				If nPos <= 0
					aAdd(aGrvVei,{aGru[ni,2],aGru[ni,3],""})
				EndIf
			EndIf
		Next
		
		For ni := 1 to len(aMar)
			//marca -grumor - modelo
			If aMar[ni,1]
				nPos := aScan(aGrvVei, {|x| x[1] == aMar[ni,2] }) // Verifica se a Marca esta selecionada
				If nPos <= 0
					aAdd(aGrvVei,{aMar[ni,2],"",""})
				EndIf
			EndIf
		Next
		
		lAltGrv := .t.
		
		
		If nOpc == 4
			cCodCus := VRA->VRA_CODCUS
			If TCCANOPEN(RetSqlName("VRD"))
				cString := "DELETE FROM "+RetSqlName("VRD")+" WHERE VRD_FILIAL='"+xFilial("VRD")+"' AND VRD_CODCUS='"+cCodCus+"' "
				TCSQLEXEC(cString)
			EndIF
			lAltGrv := .f.
		elseif nOpc == 3
			cCodCus := GetSXENum("VRA","VRA_CODCUS")
			ConfirmSx8()
			lAltGrv := .t.
		endif
		DBSelectArea("VRA")
		RecLock("VRA", lAltGrv )
		VRA->VRA_FILIAL := xFilial("VRA")
		VRA->VRA_CODCUS := cCodCus
		VRA->VRA_DESCRI := cDescri
		VRA->VRA_VALCUS := nVlrCus
		VRA->VRA_PERCUS := nPerCus
		VRA->VRA_DATINI := dDatini
		VRA->VRA_DATFIN := dDatFim
		VRA->VRA_ATIVO  := cAtivo
		
		
		MsUnLock()
		
		DBSelectArea("VRD")
		for ni:=1 to len(aGrvVei)
			RecLock("VRD", .t. )
			VRD->VRD_FILIAL := xFilial("VRD")
			VRD->VRD_CODCUS := cCodCus //pegar valor do PAI  VRD_CODCUS
			VRD->VRD_SEQUEN := StrZero(ni,tamsX3("VRD_SEQUEN")[1])
			VRD->VRD_CODMAR := aGrvVei[ni,1]
			VRD->VRD_GRUMOD := aGrvVei[ni,2]
			VRD->VRD_MODVEI := aGrvVei[ni,3]
			VRD->VRD_FABMOD := cAnoFab
			VRD->VRD_OPCION := cOpcVei
			VRD->VRD_ESTVEI := cEstVei
			MsUnLock()
		next
		
		//grava EXCECAO CUSTO
		For ni := 1 to len(aVeicTot) // Monta Vetor por Marca (Modelo)
			DbSelectArea("VRB")
			DbSetOrder(1)
			DbSeek(xFilial("VRB")+cCodCus+aVeicTot[ni,8])
			If aVeicTot[ni,1] //SE TIVER TICADO EH UMA EXCECAO GRAVAR NA TABELA VRB
				RecLock("VRB", !Found() )
				VRB->VRB_FILIAL := xFilial("VRB")
				VRB->VRB_CODCUS := cCodCus
				VRB->VRB_CHASSI := aVeicTot[ni,8]
				MsUnLock()
			ElseIf Found()
				RecLock("VRB",.F.,.T.)
				dbdelete()
				MsUnlock()
			EndIf
		Next
	ElseIf nOpc == 5//exclusao
		cCodCus := VRA->VRA_CODCUS//codigo do Custo
		If MsgYesNo(STR0032+ cCodCus +"'",STR0018)
			//exclui arquivo filho
			DbSelectArea("VRB")
			DbSetOrder(1)
			DbSeek(xFilial("VRB")+cCodCus)
			While !Eof()
				RecLock("VRB",.F.,.T.)
				dbdelete()
				MsUnlock()
				DbSelectArea("VRB")
				DbSkip()
			Enddo
			
			//	exclui filtros - Fillho
			If TCCANOPEN(RetSqlName("VRD"))
				cString := "DELETE FROM "+RetSqlName("VRD")+" WHERE VRD_FILIAL='"+xFilial("VRD")+"' AND VRD_CODCUS='"+cCodCus+"' "
				TCSQLEXEC(cString)
				
				//exclui arquivo pai
				RecLock("VRA",.F.,.T.)
				dbdelete()
				MsUnlock()
				
			EndIF
		EndIF
		
	EndIF
EndIF

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CONSVEICบAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta Veiculos                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CONSVEIC(cTipo)
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local ni      := 0
Local _ni	  := 0
Local nPos    := 0
Local _cVV1   := ""
Local aAux    := {}
Local cOpcSel := "" //opcional select
Local lOpc	  := .f.
Local cMarGru := "INICIA"
Local cQryTemp:= ""
Local lAddveic:= .f.
Local aVetEmp := {}
Local _nk     := 0
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
Default cTipo := "0"
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd(aVetEmp,{ xFilial("VVF") , FWFilialName() }) // ( xFilial("VVF") == VV1_FILENT )
Next
cFilAnt := cBkpFilAnt

aVeicTot := {}
aGrvVei := {}

lTemMarca := .f.
lTemGrupo := .f.

For ni := 1 to len(aMod)
	//marca -grumor - modelo
	If aMod[ni,1]
		aAdd(aGrvVei,{aMod[ni,2],aMod[ni,3],aMod[ni,6]})
		lTemMarca := .t.
		lTemGrupo := .t.
	EndIf
Next

For ni := 1 to len(aGru)
	//marca -grumor - modelo
	If aGru[ni,1]
		nPos := aScan(aGrvVei, {|x| x[1]+x[2] == aGru[ni,2]+aGru[ni,3] }) // Verifica se a Marca esta selecionada
		If nPos <= 0
			aAdd(aGrvVei,{aGru[ni,2],aGru[ni,3],""})
			lTemMarca := .t.
			lTemGrupo := .t.
		EndIf
	EndIf
Next

For ni := 1 to len(aMar)
	//marca -grumor - modelo
	If aMar[ni,1]
		nPos := aScan(aGrvVei, {|x| x[1] == aMar[ni,2] }) // Verifica se a Marca esta selecionada
		If nPos <= 0
			aAdd(aGrvVei,{aMar[ni,2],"",""})
		EndIf
	EndIf
Next

cQuery := "SELECT VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_TIPVEI , VV1.VV1_FILENT , VV1.VV1_FABMOD , VV1.VV1_KILVEI , VV1.VV1_RESERV , VV1.VV1_BITMAP , VV1.VV1_DTHVAL , VV1.VV1_SUGVDA , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI , VV1.VV1_COMVEI , VV1.VV1_OPCFAB , VV1.VV1_TRACPA , VV2.VV2_GRUMOD , VV2.VV2_DESMOD "
cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND "
if Len(aGrvVei ) > 0
	for ni := 1 to Len(aGrvVei)
		
		If !Empty(aGrvVei[ni,1]+aGrvVei[ni,2]+aGrvVei[ni,3])
			cQryTemp := "("
			if !Empty(aGrvVei[ni,1])
				cQryTemp +=" VV1.VV1_CODMAR='"+alltrim(aGrvVei[ni,1])+"'"
			endif
			if !Empty(aGrvVei[ni,2])
				cQryTemp +=" AND VV2.VV2_GRUMOD='"+alltrim(aGrvVei[ni,2])+"'"
			endif
			if !Empty(aGrvVei[ni,3])
				cQryTemp +=" AND VV1.VV1_MODVEI='"+alltrim(aGrvVei[ni,3])+"'"
			endif
			cQryTemp += ") AND "
		Else
			cQryTemp +=" VV1.VV1_CODMAR='___' AND " // Nao selecionar nada
		EndIf
		
		If !Empty(cEstVei)// Estado do Veiculo (Novos/Usados)
			cQryTemp += "VV1.VV1_ESTVEI='"+cEstVei+"' AND "
		EndIf
		
		If !Empty(cAnoFab)// Ano Fabricacao/Modelo
			cQryTemp += "VV1.VV1_FABMOD='"+cAnoFab+"' AND "
		EndIf
		cQryTemp += "VV1.VV1_SITVEI='0' AND "
		cQryTemp += "VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHASSI "
		
		cQryTemp:= cQuery+cQryTemp
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryTemp ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			If _cVV1 # ( cQAlSQL )->( VV1_CHASSI )
				lAddveic := .t.
				_cVV1 := ( cQAlSQL )->( VV1_CHASSI )
				
				//verifica opcionais de fabrica.
				If !Empty(cOpcVei)
					IF Empty(( cQAlSQL )->( VV1_OPCFAB ))//se o veiculo nao possuir opcional desconsiderar.
						lAddveic:= .f.
					EndIF
					IF lAddveic
						
						For _ni:=1 to 5
							cOpcSel := ""
							If !Empty(Substr(( cQAlSQL )->( VV1_OPCFAB ),(_ni*4)-3,3))
								cOpcSel := Substr(( cQAlSQL )->( VV1_OPCFAB ),(_ni*4)-3,3)
								If !(cOpcSel $ cOpcVei)
									lAddveic:= .f.
									exit
								EndIF
								
							EndIF
						next
					EndIF
				EndIF
				if lAddveic
					
					_nk := aScan(aVetEmp,{|x| x[1] == ( cQAlSQL )->( VV1_FILENT ) })//pega a posicao da filial no array
					
					aAdd(aVeicTot, { .F. ,;//Tick
					( cQAlSQL )->( VV1_FILENT )+" - "+Iif(_nk>0,aVetEmp[_nk,2],"") , ;
					( cQAlSQL )->( VV1_CODMAR ) , ;
					( cQAlSQL )->( VV2_DESMOD ) , ;
					( cQAlSQL )->( VV1_FABMOD ) , ;
					( cQAlSQL )->( VV1_COMVEI ) , ;
					left(( cQAlSQL )->( VV1_OPCFAB ),80) , ;
					( cQAlSQL )->( VV1_CHASSI ) , ;
					( cQAlSQL )->( VV1_PLAVEI ) , ;
					( cQAlSQL )->( VV1_KILVEI ) , ;
					( cQAlSQL )->( VV1_TIPVEI )  } )
				EndIF
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( dbCloseArea() )
	NEXT
EndIF

If Len(aVeicTot) <= 0
	aAdd(aVeicTot,{.f.," "," "," "," "," "," "," "," ",0," "})
Endif

IF cTipo <> "1"
	oLbVeic:SetArray(aVeicTot)
	oLbVeic:bLine := { || { IIf(aVeicTot[oLbVeic:nAt,01],oOk,oNo),;
	aVeicTot[oLbVeic:nAt,02],;
	aVeicTot[oLbVeic:nAt,03],;
	aVeicTot[oLbVeic:nAt,04],;
	Transform(aVeicTot[oLbVeic:nAt,05],"@R 9999/9999"),;
	X3CBOXDESC("VV1_COMVEI",aVeicTot[oLbVeic:nAt,06]),;
	Transform(aVeicTot[oLbVeic:nAt,07],VV1->(x3Picture("VV1_OPCFAB"))),;
	aVeicTot[oLbVeic:nAt,08],;
	Transform(aVeicTot[oLbVeic:nAt,09],VV1->(x3Picture("VV1_PLAVEI"))),;
	FG_AlinVlrs(Transform(aVeicTot[oLbVeic:nAt,10],"@E 999,999,999")),;
	X3CBOXDESC("VV1_TIPVEI",aVeicTot[oLbVeic:nAt,11]) }}
	oLbVeic:Refresh()
EndIf
dbSelectArea("VV1")
dbSetOrder(1)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_LEVANTAบAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta MARCA / GRUPO MODELO / MODELO /  ...               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVANTA(cTipo,lRefresh)
Local nPos    := 0
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local ni := 0
Do Case
	Case cTipo == "MAR" // Levanta Marcas
		aMar := {}
		cQuery := "SELECT VE1.VE1_CODMAR , VE1.VE1_DESMAR FROM "+RetSqlName("VE1")+" VE1 "
		cquery += "WHERE VE1.VE1_FILIAL='"+xFilial("VE1")+"' AND VE1.D_E_L_E_T_=' ' ORDER BY VE1.VE1_CODMAR "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			aAdd(aMar,{.f.,( cQAlSQL )->( VE1_CODMAR ),( cQAlSQL )->( VE1_DESMAR )})
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aMar) == 1
			aMar[1,1] := .t.
		EndIf
		If len(aMar) == 0
			aAdd(aMar,{.f.,"",""})
		EndIf
		If lRefresh
			oLbMar:nAt := 1
			oLbMar:SetArray(aMar)
			oLbMar:bLine := { || { 	IIf(aMar[oLbMar:nAt,1],oVerd,oVerm) , aMar[oLbMar:nAt,2] , aMar[oLbMar:nAt,3] }}
			oLbMar:Refresh()
		EndIf
	Case cTipo == "GRU" // Levanta Grupos de Modelo
		aGruAux := {}
		for ni := 1 to len(aGru)
			If aGru[ni,1]
				aAdd(aGruAux,aGru[ni])
			EndIf
		Next
		aGru := {}
		cQuery := "SELECT VVR.VVR_CODMAR , VVR.VVR_GRUMOD , VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR "
		cQuery += "WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND VVR.D_E_L_E_T_=' ' ORDER BY VVR.VVR_CODMAR , VVR.VVR_DESCRI "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			nPos := aScan(aMar, {|x| x[2] == ( cQAlSQL )->( VVR_CODMAR ) }) // Verifica se a Marca esta selecionada
			If nPos > 0 .and. aMar[nPos,1]
				lAchou := aScan(aGruAux,{|x| x[2] + x[3] == ( cQAlSQL )->( VVR_CODMAR ) + ( cQAlSQL )->( VVR_GRUMOD ) } ) > 0
				aAdd(aGru,{lAchou,( cQAlSQL )->( VVR_CODMAR ),( cQAlSQL )->( VVR_GRUMOD ),( cQAlSQL )->( VVR_DESCRI )})
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aGru) <= 0
			aAdd(aGru,{.f.,"","",""})
		EndIf
		If lRefresh
			oLbGru:nAt := 1
			oLbGru:SetArray(aGru)
			oLbGru:bLine := { || { 	IIf(aGru[oLbGru:nAt,1],oVerd,oVerm) , aGru[oLbGru:nAt,2] , aGru[oLbGru:nAt,4] }}
			oLbGru:Refresh()
		EndIf
	Case cTipo == "MOD" // Levanta Modelos
		aModAux := {}
		for ni := 1 to len(aMod)
			If aMod[ni,1]
				aAdd(aModAux,aMod[ni])
			EndIf
		Next
		aMod := {}
		cQuery := "SELECT DISTINCT VV2.VV2_MODVEI , VV2.VV2_CODMAR , VV2.VV2_GRUMOD , VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 "
		cQuery += "WHERE VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_DESMOD "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			nPos := aScan(aGru, {|x| x[2]+x[3] == ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD ) }) // Verifica se a Marca e o Grupo do Modelo estao selecionados
			If nPos > 0 .and. aGru[nPos,1]
				//nPos := aScan(aMod, {|x| x[2]+x[5] == ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_DESMOD ) })
				//If nPos <= 0
				lAchou := aScan(aModAux,{|x| x[2] + x[3] + x[6]== ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD ) + ( cQAlSQL )->( VV2_MODVEI ) } ) > 0
				aAdd(aMod,{lAchou,( cQAlSQL )->( VV2_CODMAR ),( cQAlSQL )->( VV2_GRUMOD ),"'"+Alltrim(( cQAlSQL )->( VV2_MODVEI ))+"'",Alltrim(( cQAlSQL )->( VV2_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ),( cQAlSQL )->( VV2_MODVEI ) })
				//lse
				//	aMod[nPos,4] += ",'"+Alltrim(( cQAlSQL )->( VV2_MODVEI ))+"'"
				//EndIf
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aMod) <= 0
			aAdd(aMod,{.f.,"","","","",""})
		EndIf
		If lRefresh
			oLbMod:nAt := 1
			oLbMod:SetArray(aMod)
			oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oVerd,oVerm) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5] }}
			oLbMod:Refresh()
		EndIf
EndCase
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ  FS_TIK   บAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK dos ListBox de Filtro                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK(cTipo,nLinha,nOpc)
Local lSelLin := .f.
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	Return()
EndIF
Do Case
	Case cTipo == "MAR"
		If len(aMar) > 1 .or. !Empty(aMar[1,2])
			lSelLin := aMar[nLinha,1]
			//aEval( aMar , {|x| x[1] := .f. } )
			aMar[nLinha,1] := !lSelLin
			oLbMar:Refresh()
		EndIf
		FS_LEVANTA("GRU",.t.)
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "GRU"
		If len(aGru) > 1 .or. !Empty(aGru[1,2])
			lSelLin := aGru[nLinha,1]
			//aEval( aGru , {|x| x[1] := .f. } )
			aGru[nLinha,1] := !lSelLin
			oLbGru:Refresh()
		EndIf
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "MOD"
		If len(aMod) > 1 .or. !Empty(aMod[1,2])
			lSelLin := aMod[nLinha,1]
			//aaEval( aMod , {|x| x[1] := .f. } )
			aMod[nLinha,1] := !lSelLin
			oLbMod:Refresh()
		EndIf
EndCase
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ  FS_TIK2  บAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK2 da Selecao dos veiculos                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK2(nLinha,nOpc)
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	Return()
EndIF
If !Empty(aVeicTot[nLinha,03]+aVeicTot[nLinha,04])
	aVeicTot[nLinha,01] := 	!aVeicTot[nLinha,01]
	oLbVeic:Refresh()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ  FS_TIK3  บAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK3 da Selecao de todos list filtro.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK3(cChama,lTipo,nOpc)
Local _ni:= 1
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	Return()
EndIf
If cChama == "MAR"
	lSGmod := .F.
	lSMod := .F.
	For _ni := 1 to Len(aMar)
		aMar[_ni,01] := lTipo
	Next
	FS_LEVANTA("GRU",.t.)
	FS_LEVANTA("MOD",.t.)
ElseIf cChama == "GRU"
	lSMod := .F.
	For _ni := 1 to Len(aGru)
		aGru[_ni,01] := lTipo
	Next
	FS_LEVANTA("MOD",.t.)
ElseIf cChama == "MOD"
	For _ni := 1 to Len(aMod)
		aMod[_ni,01] := lTipo
	Next
EndIf
oCGMod:Refresh()
oCMod:Refresh()
oLbMar:Refresh()
oLbGru:Refresh()
oLbMod:Refresh()
FS_CONSVEIC()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ  FS_TIK4  บAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK da Selecao do Vetor aVeicTot (veiculos)                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK4(lVeicTot,nOpc)
Local _ni:= 1
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	Return()
EndIF
For _ni := 1 to Len(aVeicTot)
	If !Empty(aVeicTot[_ni,03]+aVeicTot[_ni,04])
		aVeicTot[_ni,01] := lVeicTot
	EndIf
Next
oLbVeic:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_VARPER บAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ when campo valor ou percentual                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VARPER(cMomet)
default cMomet := .t.

lPerCus:= .T.
lVlrCus:= .T.

If !Empty(nVlrCus)
	lPerCus:= .f.
	if cMomet
		oDatIni:SetFocus()
	EndIF
EndIf

If !Empty(nPerCus)
	lVlrCus:= .f.
EndIF

If cMomet
	oPerCus:Refresh()
	oVlrCus:Refresh()
EndiF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณVEIVA680DELบAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณEXCLUI VALORES DA TABELA VRC                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA680DEL(cAtend,cChaInt)
Local cString   := ""
Default cChaInt := ""
If TCCANOPEN(RetSqlName("VRC"))
	cString := "DELETE FROM "+RetSqlName("VRC")+" WHERE VRC_FILIAL='"+xFilial("VRC")+"' AND VRC_NUMATE='"+cAtend+"' "
	If !Empty(cChaInt)
		cString += "AND (VRC_CHAINT = '     ' OR VRC_CHAINT='"+cChaInt+"') "
	EndIf
	TCSQLEXEC(cString)
	MsgInfo(STR0033,STR0018) //A troca do veiculo fez com que os dados referente(s) ao(s) Custo com Vendas fossem deletado(s)! Sera necessario nova verifica็ใo de Custo com Vendas! # Atencao
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef   บAutor  ณRafael Goncalves    บ Data ณ  09/08/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta aRotina MENUDEF                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0035 	,"axPesqui"	, 0 , 1},;	//Pesquisar
{ STR0036	,"VEI680V"	, 0 , 2},;	//Visualizar
{ STR0037 	,"VEI680I"	, 0 , 3},; //Incluir
{ STR0038 	,"VEI680A"	, 0 , 4},; 	//Alterar
{ STR0039 	,"VEI680E"	, 0 , 5} }	//Excluir
Return aRotina