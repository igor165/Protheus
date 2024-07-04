// ษออออออออหออออออออป
// บ Versao บ 15     บ
// ศออออออออสออออออออผ
#INCLUDE "PROTHEUS.CH"
#INCLUDE "VEIVA690.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ VEIVA690 ณ Autor ณ Rafael Goncalves      ณ Data ณ 05/08/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Despesa com Veiculos - custos variaveis                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Veiculo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

FUNCTION VEIVA690()
PRIVATE aRotina := MenuDef()
Private nReg := 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de atualizacoes                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cCadastro := STR0001 //Despesa com Vendas

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("VRH")
DbSelectArea("VRG")
DbSelectArea("VRF")
dbSetORder(1)
mBrowse( 6, 1,22,75,"VRF")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEI690    บAutor  ณRafael Goncalves    บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Tela                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEI690(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
Local nPos := 0
Local cQueryL  := ""
Local cQAlSQLL := "ALIASSQLL"
Local cMoment := ""

Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"	

Local lAltCpo := .t.
Local nOrdCpo := 0 
Local ni	  := 0 

Private lSMar   := .f.
Private lSGmod  := .f.
Private lSMod   := .f.
Private lVeicTot:= .f.
Private lVlrDes := .T.
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
Private cCodigo := space(len(VRF_CODIGO))
Private cDescri := space(100)
Private aRet := {} 

Private cAtivo 	:= ""
Private aAtivo 	:= X3CBOXAVET("VRF_ATIVO","1")  
Private nVlrDes := 0 

Private lVVD_FILENT := VVD->(FieldPos("VVD_FILENT")) <> 0

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private aBotoes := {;
{"PESQUISA", { || FS_CONSULNF() } , STR0002 } ; // "Consulta Nota Fiscal"
}

//VERIFRICA SE EXISTE NF PARA A DESPESA SE EXISTIR NรO DEIXA ALTERAR OU EXCLUIR
If nOpc =4 .or. nOpc =5  //visualizar/alterar/excluir levanta as infomacoes anteriores
	If !Empty(VRF->VRF_NUMNFI) .and. !Empty(VRF->VRF_SERNFI)
		DbSelectArea("SF1")
		DbSetOrder(1)
		if DbSeek(xFilial("SF1") + VRF->VRF_NUMNFI + VRF->VRF_SERNFI )
        	Msginfo(STR0004,STR0003) // "Nใo ้ possํvel manipular a despesa, existe nota fiscal vแlida"
        	Return
  		EndIF
  	EndIF
EndIF

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

If  nOpc =2 .or. nOpc =4 .or. nOpc =5  //visualizar/alterar/excluir levanta as infomacoes anteriores
	//SELECIONA AS MARCAR//
	cQueryL := "SELECT VRG.* FROM "+RetSqlName("VRG")+" VRG "
	cqueryL += "WHERE VRG.VRG_FILIAL='"+xFilial("VRG")+"' AND VRG.VRG_CODDES='"+VRF->VRF_CODDES+"' AND VRG.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryL ), cQAlSQLL , .F., .T. )
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aMar, {|x| x[2] == ( cQAlSQLL )->( VRG_CODMAR ) }) // Verifica se a Marca esta selecionada
		If nPos > 0
			aMar[nPos,1] := .T.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	( cQAlSQLL )->( DbGotop() )
	FS_LEVANTA("GRU",.f.)	// Levanta Grupos de Modelo das marcas selecionadas.
    
    //SELECIONA OS GRUPO MODELO//
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aGru, {|x| x[2]+x[3] == ( cQAlSQLL )->( VRG_CODMAR )+( cQAlSQLL )->( VRG_GRUMOD ) }) // Verifica se o grupo modelo esta selecionada
		If nPos > 0
			aGru[nPos,1] := .T.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo                             
	( cQAlSQLL )->( DbGoTop() )    
	FS_LEVANTA("MOD",.f.)	// Levanta Modelos
    
    //SELECIONA OS GRUPO MODELO//
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aMod, {|x| x[2]+x[3]+x[6] == ( cQAlSQLL )->( VRG_CODMAR )+( cQAlSQLL )->( VRG_GRUMOD )+( cQAlSQLL )->( VRG_MODVEI ) }) // Verifica se o grupo modelo esta selecionada
		If nPos > 0
			aMod[nPos,1] := .t.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	( cQAlSQLL )->( DbCloseArea() )    
		
	DbSelectArea("VRG")
	DbSetORder(1)
	DbSeek(xFilial("VRG")+VRF->VRF_CODDES)

	cAnoFab := VRG->VRG_FABMOD
	cOpcVei := VRG->VRG_OPCION
	cCodigo := VRF->VRF_CODIGO
	cEstVei := VRG->VRG_ESTVEI 
	nVlrDes := VRF->VRF_VALDES
	cAtivo  := VRF->VRF_ATIVO
	cDescri := VRF->VRF_DESCRI 

	aAdd(aRet,{VRF->VRF_FORPRO,VRF->VRF_CODFOR,VRF->VRF_LOJA,"",VRF->VRF_NUMNFI,VRF->VRF_SERNFI,VRF->VRF_DATEMI,VRF->VRF_TESDES,VRF->VRF_NATURE,VRF->VRF_CODBCO,VRF->VRF_FORPAG,""})	

	FS_CONSVEIC("1")//levanta veiculos para marca/grupo e modelo selecionado
	
	//Le o VVD para verificar veiculos com despesa
    For ni := 1 to len(aVeicTot) // Monta Vetor por Marca (Modelo)
    	DbSelectArea("VV1")
    	DbSetOrder(2)
    	If DbSeek(xFilial("VV1")+aVeicTot[ni,8])
			cQuery := "SELECT COUNT(*) AS QTD FROM "+RetSqlName("VVD")+" VVD "
			If !lVVD_FILENT
				cQuery += " WHERE VVD.VVD_FILIAL = '" + VV1->VV1_FILENT + "'" // antes do VVD_FILENT
			Else
				cQuery += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + VV1->VV1_FILENT + "' ) " // novos registros
				cQuery += "       OR (VVD.VVD_FILIAL = '" + VV1->VV1_FILENT + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
			Endif
			cQuery+= " AND VVD.VVD_CHAINT='"+VV1->VV1_CHAINT+"'  AND VVD.VVD_TRACPA='"+VV1->VV1_TRACPA+"' AND VVD.VVD_CODVRE='"+VRF->VRF_CODDES+"' AND VVD.D_E_L_E_T_=' ' "
			aVeicTot[ni,1] := ( FM_SQL( cQuery ) > 0 )
		EndIF
     Next

EndIF


If Len(aVeicTot) <= 0  //adicina registro em branco veiculos.
	aAdd(aVeicTot,{.f.," "," "," "," "," "," "," "," ",0," "})
Endif  

//verifica se for visualizacao ou exclusao nao permite alterar
If nOpc =2 .or. nOpc =5  //visualizar/excluir nao permite alterar
	lAltCpo := .f.
	lVlrDes:= .f.
EndIF  
If nOpc =2
	cMoment := STR0005 // "Visualizar"
ElseIf nOpc =3
	cMoment := STR0006 // "Incluir"
ElseIf nOpc =4
	cMoment := STR0007 // "Alterar" 
ElseIf nOpc =5
	cMoment := STR0008 // "Excluir" 
EndIF

DEFINE MSDIALOG oDespVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0009+" - "+cMoment OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // "Despesas com Veํculos"
oDespVeic:lEscClose := .F. 

//divide a janela em tres colunas.
nTam := ( aPos[1,4] / 3 )

@ aPos[1,1]-001,aPos[1,2]+(nTam*0) TO aPos[1,3],(nTam*3)-2 LABEL "" OF oDespVeic PIXEL

nOrdCpo := 006
// ESTADO DO VEICULO //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0010 SIZE 50,8 OF oDespVeic PIXEL COLOR CLR_BLACK // Estado do Veiculo 
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSCOMBOBOX oEstVei VAR cEstVei SIZE 30,08 COLOR CLR_BLACK ITEMS aEstVei OF oDespVeic ON CHANGE FS_CONSVEIC() PIXEL COLOR CLR_BLUE  WHEN lAltCpo
nOrdCpo += 031
// ANO FINAL //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0011 SIZE 50,8 OF oDespVeic PIXEL COLOR CLR_BLACK // "Ano Fab."
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oAnoFab VAR cAnoFab PICTURE "@R 9999/9999" SIZE 35,08 VALID FS_CONSVEIC() OF oDespVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo
nOrdCpo += 040
// OPCIONAIS //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0012 SIZE 50,8 OF oDespVeic PIXEL COLOR CLR_BLACK // "Opcionais"
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oOpcVei VAR cOpcVei PICTURE VRG->(X3PICTURE("VRG_OPCION")) SIZE 70,08 VALID FS_CONSVEIC() OF oDespVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo
nOrdCpo += 085 
@ aPos[1,1],aPos[1,2]+001 TO aPos[1,1]+028,nOrdCpo-9 LABEL STR0013 OF oDespVeic PIXEL // "Filtro"
// VALOR FINAL //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0014 SIZE 55,8 OF oDespVeic PIXEL COLOR CLR_BLUE // "Valor Despesa" 
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSGET oVlrDes VAR nVlrDes PICTURE "@E 999,999,999.99" SIZE 55,08 VALID Positivo() OF oDespVeic PIXEL COLOR CLR_BLUE HASBUTTON  WHEN (lVlrDes)
nOrdCpo += 056
//OBRIGATORIO //
@ aPos[1,1]+007,aPos[1,2]+nOrdCpo SAY STR0056 SIZE 55,8 OF oDespVeic PIXEL COLOR CLR_BLUE // "Ativo"
@ aPos[1,1]+015,aPos[1,2]+nOrdCpo MSCOMBOBOX oAtivo VAR cAtivo SIZE 30,08 COLOR CLR_BLACK ITEMS aAtivo OF oDespVeic /*ON CHANGE FS_FILTVETOR()*/ PIXEL COLOR CLR_BLUE WHEN lAltCpo
nOrdCpo += 039

@ aPos[1,1],aPos[1,2]+(nOrdCpo-100 ) TO aPos[1,1]+028,nOrdCpo LABEL STR0015 OF oDespVeic PIXEL // "Informa็๕es Despesa"

// Codigo //
@ aPos[1,1]+030,aPos[1,2]+006 SAY STR0016 SIZE 50,8 OF oDespVeic PIXEL COLOR CLR_BLACK  // "C๓digo despesa"
@ aPos[1,1]+038,aPos[1,2]+006 MSGET oCodigo VAR cCodigo PICTURE "@!" F3 "VV5A" VALID FS_VALCODIGO() SIZE 100,08 OF oDespVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo
// descricao //
@ aPos[1,1]+030,aPos[1,2]+106 SAY STR0017 SIZE 50,8 OF oDespVeic PIXEL COLOR CLR_BLACK  // "Descri็ใo"
@ aPos[1,1]+038,aPos[1,2]+106 MSGET oDescri VAR cDescri PICTURE "@!" SIZE 220,08 OF oDespVeic PIXEL COLOR CLR_BLUE  WHEN .f.


// MARCA //
@ aPos[2,1]-002,aPos[2,2]+(nTam*0) TO aPos[2,3]-003,(nTam*1) LABEL STR0018 OF oDespVeic PIXEL // Marca 
@ aPos[2,1]+006,aPos[2,2]+(nTam*0)+1 LISTBOX oLbMar FIELDS HEADER "",STR0018,STR0017 COLSIZES 10,20,40 SIZE nTam-5,aPos[2,3]-aPos[2,1]-12 OF oDespVeic PIXEL ON DBLCLICK (FS_TIK("MAR",oLbMar:nAt,nOpc),FS_CONSVEIC()) // "Marca" "Descri็ใo"
oLbMar:SetArray(aMar)
oLbMar:bLine := { || { 	IIf(aMar[oLbMar:nAt,1],oVerd,oVerm) , aMar[oLbMar:nAt,2] , aMar[oLbMar:nAt,3] }}

// GRUPO DO MODELO //
@ aPos[2,1]-002,aPos[2,2]+(nTam*1) TO aPos[2,3]-003,(nTam*2) LABEL STR0019 OF oDespVeic PIXEL // Grupo do Modelo 
@ aPos[2,1]+006,aPos[2,2]+(nTam*1)+1 LISTBOX oLbGru FIELDS HEADER "",STR0018,STR0020 COLSIZES 10,20,40 SIZE nTam-5,aPos[2,3]-aPos[2,1]-12 OF oDespVeic PIXEL ON DBLCLICK (FS_TIK("GRU",oLbGru:nAt,nOpc),,FS_CONSVEIC()) // "Marca" "Grupo do Modelo - Descricao"
oLbGru:SetArray(aGru)
oLbGru:bLine := { || { 	IIf(aGru[oLbGru:nAt,1],oVerd,oVerm) , aGru[oLbGru:nAt,2] , aGru[oLbGru:nAt,4] }}

// MODELO //
@ aPos[2,1]-002,aPos[2,2]+(nTam*2) TO aPos[2,3]-003,(nTam*3) LABEL STR0021 OF oDespVeic PIXEL // Modelo
@ aPos[2,1]+006,aPos[2,2]+(nTam*2)+1 LISTBOX oLbMod FIELDS HEADER "",STR0018,STR0022 COLSIZES 10,20,40 SIZE nTam-5,aPos[2,3]-aPos[2,1]-12 OF oDespVeic PIXEL ON DBLCLICK (FS_TIK("MOD",oLbMod:nAt,nOpc),FS_CONSVEIC()) // "Marca" "Modelo - Descri็ใo"
oLbMod:SetArray(aMod)
oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oVerd,oVerm) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5] }}

// VEICULOS //
@ aPos[3,1]-001,aPos[3,2] LISTBOX oLbVeic FIELDS HEADER ;
	" " ,;
	STR0030,; // "Loja"
	STR0018,; // "Marca"
	STR0021,; // "Modelo"
	STR0023,; // "Fab/Mod"
	STR0024,; // "Combustํvel"
	STR0025,; // "Opcionais Fแbrica"
	STR0026,; // "Chassi"
	STR0027,; // "Placa"
	STR0028,; // "Kilometragem"
	STR0029 ; // "Tipo Veํculo"
	COLSIZES 10,55,25,70,40,65,120,90,40,50,50;
	SIZE aPos[3,4]-2,aPos[3,3]-aPos[3,1]+3 OF oDespVeic PIXEL ON DBLCLICK (FS_TIK2(oLbVeic:Nat,nOpc))

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
								
@ aPos[2,1]+006,aPos[2,2]+(nTam*0)+003 CHECKBOX oCMar  VAR lSMar  PROMPT "" OF oDespVeic ON CLICK FS_TIK3("MAR",lSMar,nOpc) SIZE 40,10 PIXEL		
@ aPos[2,1]+006,aPos[2,2]+(nTam*1)+003 CHECKBOX oCGMod VAR lSGmod PROMPT "" OF oDespVeic ON CLICK FS_TIK3("GRU",lSGmod,nOpc) SIZE 40,10 PIXEL
@ aPos[2,1]+006,aPos[2,2]+(nTam*2)+003 CHECKBOX oCMod  VAR lSMod  PROMPT "" OF oDespVeic ON CLICK FS_TIK3("MOD",lSMod,nOpc) SIZE 40,10 PIXEL
@ aPos[3,1]-001,aPos[3,2]+001 CHECKBOX oVeicTot VAR lVeicTot  PROMPT "" OF oDespVeic ON CLICK FS_TIK4(lVeicTot,nOpc) SIZE 40,10 PIXEL

ACTIVATE MSDIALOG oDespVeic ON INIT EnchoiceBar(oDespVeic, { || IF(FS_GRAVAR(nOpc),oDespVeic:End(),.T.) , .f. },{|| oDespVeic:End() },,aBotoes)

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRAVAR บAutor  ณRafael Goncalves    บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava despesa do Veiculo                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAVAR(nOpc)
Local lRet := .t.
Local ni := 0
Local cCodDes := SPACE(LEN(VRF->VRF_CODDES))
Local lAltGrv := .t.  
Local aGrvVei := {} 
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"	
Local lachoVVD := .T.//controlo grava/altera VVD 
Local lVVDDel := .F. //controlo delecao do registro
Local lGerNf := .f.  //controlo usar parametros da parambox
Local nValVVD := 0 	  //valor despesa com rateio.
Local nQtdVei := 0

Local aParamBox := {}
Local lParamb := .f.
Local cForPro := "Nใo" 
Local cCodFor := space(TamSX3("A2_COD")[1]) //Fornecedor
Local cLojFor := space(TamSX3("A2_LOJA")[1]) //Loja	
Local cNomFor := space(TamSX3("A2_NREDUZ")[1]) //Nome
Local cNumNfi := space(TamSX3("VV0_NUMNFI")[1]) // Nota Fiscal
Local cSernfi := space(FGX_MILSNF("VV0", 6,"VV0_SERNFI")) // Serie tam = 3antigo para parambox
Local cData := ddatabase
Local cCodTes := Space(TamSX3("F4_CODIGO")[1]) // TES
Local cNature := Space(TamSX3("VVF_NATURE")[1]) //Natureza
Local cBanco  := Space(TamSX3("VRF_CODBCO")[1]) //Banco
Local cForPag := Space(TamSX3("VRF_FORPAG")[1]) //Forma de pagamento
Local cDesPag := Space(TamSX3("VRF_DESFPG")[1]) //descricao forma de pagamento

Local lVVD_FILUCP := VVD->(FieldPos("VVD_FILUCP")) <> 0
Local aMovAux     := {}
Local cFilUCp     := "" // Filial da Ultima Entrada por Compra
Local cTraUCp     := "" // Tracpa da Ultima Entrada por Compra

Local _nj := 1
         
IF Empty(nVlrDes) .and. lVlrDes .and. lRet
	MsgStop(STR0031,STR0003) // "Nใo informado o campo Valor da Despesa do Veํculo"
	lRet := .f.
	oVlrDes:SetFocus()
EndIF 
IF Empty(cAtivo) .and. lRet
	MsgStop(STR0032,STR0003) // "Nใo informado o campo Ativo."
	lRet := .f.
	oAtivo:SetFocus()
EndIF
IF Empty(cCodigo) .and. lRet
	MsgStop(STR0033,STR0003) // "Nใo informado o campo C๓digo da Despesa do Veํculo"
	lRet := .f.
	oCodigo:SetFocus()
EndIF  

If lRet
	lRet := .f. 
	For _nj := 1 to len(aVeicTot)
	    If aVeicTot[_nj,1]
	    	lRet := .t.
	    	Exit
		EndIF	
	Next

	If !lRet
		MsgStop(STR0034,STR0003) // "Nใo selecionado Veํculo para Gerar a Despesa"
	EndIF
EndIF

If lRet
	If ( nOpc == 3 .Or. nOpc == 4 ) //Inclusao/alteracao
		If nOpc == 4
			If Empty(VRF->VRF_NUMNFI) .and. Empty(VRF->VRF_SERNFI)
				If MsgYesNo(STR0035, STR0003) // "Deseja gerar Nota fiscal de entrada?"
					lParamb:= .t.
				EndIF
			EndIf
		ElseIf nOpc == 3
			If MsgYesNo(STR0035, STR0003) // "Deseja gerar Nota fiscal de entrada?"
				lParamb:= .t.
			EndIF  
		EndIf
	
		If lParamb
			While .T.
				aParamBox:= {}
				aRet := {} 
				
				aAdd(aParamBox,{2,STR0036,cForPro,{STR0047,STR0048},80,"",.T.}) // "Formulแrio Pr๓prio" {"Sim","Nใo"}
				aAdd(aParamBox,{1,STR0037,cCodFor,"","","VV6A","",0,.F.})  // "Fornecedor"
				aAdd(aParamBox,{1,STR0030,cLojFor,"",'vazio() .or. FG_Seek("SA2","MV_PAR02+MV_PAR03",1,.f.,"MV_PAR04","A2_NREDUZ")',"","",0,.F.}) // "Loja"
				aAdd(aParamBox,{1,STR0038,cNomFor,"","","",".F.",0,.F.}) //Nome
				aAdd(aParamBox,{1,STR0039,cNumNfi,"","","","MV_PAR01='Nใo'",0,.F.}) // Nota Fiscal
				aAdd(aParamBox,{1,STR0040,cSernfi,"","","","MV_PAR01='Nใo'",0,.F.}) // Serie
				aAdd(aParamBox,{1,STR0041,cData,"@D","","","",0,.F.})
				aAdd(aParamBox,{1,STR0042,cCodTes,"",'(vazio() .or. FG_Seek("SF4","MV_PAR08",1,.f.)) .and. MV_PAR08 < "500"',"SF4","",0,.F.}) // TES
				aAdd(aParamBox,{1,STR0043,cNature,"",'vazio() .or. FG_Seek("SED","MV_PAR09",1,.f.)',"SED","",0,.F.}) //natureza
				aAdd(aParamBox,{1,STR0044,cBanco,"",'vazio() .or. FG_Seek("SA6","MV_PAR10",1,.f.)',"VRF1","",0,.F.}) //Banco
				aAdd(aParamBox,{1,STR0045,cForPag,"",'FG_Seek("SE4","MV_PAR11",1,.f.,"MV_PAR12","E4_DESCRI ")',"SE4","",0,.F.}) //Forma de pagamento
				aAdd(aParamBox,{1,STR0046,cDesPag,"","","",".F.",0,.F.}) //descricao forma de pagamento
		
				If ParamBox(aParamBox,STR0047,@aRet,,,,,,,,.F.) // "Dados referente Nota Fiscal"
					If Empty(aRet[1]) .or. Empty(aRet[2]) .or. Empty(aRet[3]);
						.or. Empty(aRet[4]) .or. Empty(aRet[7]) .or. Empty(aRet[8]) .or. Empty(aRet[9]);
					    .or. Empty(aRet[10]) .or. Empty(aRet[11]) .or. Empty(aRet[12]) .and. ;
					    Iif(aRet[1]==STR0048,Empty(aRet[5]) .and. Empty(aRet[6]),.t.)
			   			
						msginfo(STR0049,STR0003) // "Necessแrio o preenchimento de todos os campos"
						cForPro := aRet[1] // Formulario Proprio
						cCodFor := aRet[2] // Fornecedor
						cLojFor := aRet[3] // Loja	
						cNomFor := aRet[4] // Nome
						cNumNfi := aRet[5] // Nota Fiscal
						cSernfi := aRet[6] // Serie
						cData   := aRet[7] // Data
						cCodTes := aRet[8] // TES
						cNature := aRet[9] // Natureza
						cBanco  := aRet[10] // Banco
						cForPag := aRet[11] // Forma de pagamento
						cDesPag := aRet[12] // descricao forma de pagamento
					
					Else
						Processa ({ || lGerNf := FS_GERNOTA(aRet)},STR0050,STR0051) //gera nota fiscal
						If lGerNf
							Exit
						Else
							cForPro := aRet[1] // Formulario Proprio
							cCodFor := aRet[2] // Fornecedor
							cLojFor := aRet[3] // Loja	
							cNomFor := aRet[4] // Nome
							cNumNfi := aRet[5] // Nota Fiscal
							cSernfi := aRet[6] // Serie
							cData   := aRet[7] // Data
							cCodTes := aRet[8] // TES
							cNature := aRet[9] // Natureza
							cBanco  := aRet[10] // Banco
							cForPag := aRet[11] // Forma de pagamento
							cDesPag := aRet[12] // descricao forma de pagamento
						EndIf
					EndIf
				Else
			   		lGerNf := .f.
					Exit
				EndIf
			EndDo
        EndIF


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
			cCodDes := VRF->VRF_CODDES
			If TCCANOPEN(RetSqlName("VRG"))
				cString := "DELETE FROM "+RetSqlName("VRG")+" WHERE VRG_FILIAL='"+xFilial("VRG")+"' AND VRG_CODDES='"+cCodDes+"' "
				TCSQLEXEC(cString)
			EndIF
			lAltGrv := .f.
		elseif nOpc == 3
			cCodDes := GetSXENum("VRF","VRF_CODDES")
			ConfirmSx8()
			lAltGrv := .t.
		endif
		DBSelectArea("VRF")
		RecLock("VRF", lAltGrv )
			VRF->VRF_FILIAL := xFilial("VRF")
			VRF->VRF_CODDES := cCodDes
			VRF->VRF_CODIGO := cCodigo
			VRF->VRF_DESCRI := alltrim(cDescri)
			VRF->VRF_VALDES := nVlrDes //valor total da despesa
			VRF->VRF_ATIVO  := cAtivo 
			VRF->VRF_FORPRO := Iif(lGerNf,Iif(aRet[1]=="Sim","1","0"),"")
			VRF->VRF_CODFOR := Iif(lGerNf,aRet[2],"")
			VRF->VRF_LOJA   := Iif(lGerNf,aRet[3],"")
			//VRF->VRF_NOMFOR := Iif(lGerNf,aRet[4],"")
			VRF->VRF_NUMNFI := Iif(lGerNf,aRet[5],"")
			VRF->VRF_SERNFI := Iif(lGerNf,aRet[6],"")		
			if Fieldpos("VRF_SDOC") > 0
				VRF->VRF_SDOC := Iif(lGerNf, FGX_UFSNF(aRet[6]), "")
			endif
			VRF->VRF_DATEMI := Iif(lGerNf,aRet[7],ctod("  /  /  "))
			VRF->VRF_TESDES := Iif(lGerNf,aRet[8] ,"")
			VRF->VRF_NATURE := Iif(lGerNf,aRet[9],"")
			VRF->VRF_CODBCO := Iif(lGerNf,aRet[10],"")						
			VRF->VRF_FORPAG := Iif(lGerNf,aRet[11],"")
			//VRF->VRF_DESFPG := Iif(lGerNf,aRet[12],"")
		MsUnLock()
		
		DBSelectArea("VRG")
		for ni:=1 to len(aGrvVei)
			RecLock("VRG", .t. )
			VRG->VRG_FILIAL := xFilial("VRG")
			VRG->VRG_CODDES := cCodDes //pegar valor do PAI  VRG_CODDES
			VRG->VRG_SEQUEN := StrZero(ni,tamsX3("VRG_SEQUEN")[1])
			VRG->VRG_CODMAR := aGrvVei[ni,1]
			VRG->VRG_GRUMOD := aGrvVei[ni,2]
			VRG->VRG_MODVEI := aGrvVei[ni,3]
			VRG->VRG_FABMOD := cAnoFab
			VRG->VRG_OPCION := cOpcVei
			VRG->VRG_ESTVEI := cEstVei
			MsUnLock()
		next
		//RATEIO DO VALOR TOTAL PARA A QUANTIDADE DE VEICULOS SELECIONADOS
		For ni := 1 to len(aVeicTot)
			If aVeicTot[ni,1]
		    	nQtdVei ++
			EndIF
		Next 
		nValVVD := nVlrDes/nQtdVei //calcula o valor da despesa dividindo o total pela quantidade de veiculos
		
		//grava despesa dos veiculos
	    For ni := 1 to len(aVeicTot) // Monta Vetor por Marca (Modelo)
	    	lachoVVD := .t.
	    	lVVDDel := .F.
	    	DbSelectArea("VV1")
	    	DbSetOrder(2)
	    	If DbSeek(xFilial("VV1")+aVeicTot[ni,8])
				cQuery := "SELECT VVD.R_E_C_N_O_ AS RECVVD FROM "+RetSqlName("VVD")+" VVD "
				If !lVVD_FILENT
					cQuery += " WHERE VVD.VVD_FILIAL = '" + VV1->VV1_FILENT + "'" // antes do VVD_FILENT
				Else
					cQuery += " WHERE ( ( VVD.VVD_FILIAL = '" + xFilial("VVD") + "' AND VVD.VVD_FILENT = '" + VV1->VV1_FILENT + "' ) " // novos registros
					cQuery += "       OR (VVD.VVD_FILIAL = '" + VV1->VV1_FILENT + "' AND VVD.VVD_FILENT = ' ' ) ) " // registro antigos
				Endif
				cQuery += " AND VVD.VVD_CHAINT='"+VV1->VV1_CHAINT+"'  AND VVD.VVD_TRACPA='"+VV1->VV1_TRACPA+"' AND VVD.VVD_CODVRE='"+cCodDes+"' AND VVD.D_E_L_E_T_=' ' "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
				If !( cQAlSQL )->( Eof() )//existe o resgitro
					lachoVVD := .F. //Altera o registro
				   	DbSelectArea("VVD")
					DbGoTo(( cQAlSQL )->( RECVVD ))
					lVVDDel := .t. //se nao tiver ticado no list bos verifica para delecao
				EndIF
				( cQAlSQL )->( DbCloseArea() ) 

				If lVVD_FILUCP
					cFilUCp := VV1->VV1_FILENT // Ultima Filial de Entrada
					cTraUCp := VV1->VV1_TRACPA // Ultimo TraCpa de Entrada
					aMovAux := FGX_VEIMOVS( VV1->VV1_CHASSI , "E" , "0" ) // Retorna a ultima Entrada por Compra do Veiculo
					If len(aMovAux) > 0
						cFilUCp := aMovAux[1,2] // Ultima Filial de Entrada por Compra
						cTraUCp := aMovAux[1,3] // Ultimo TraCpa de Entrada por Compra
					EndIf
				EndIf

					//DbSetOrder(1)
				//DbSeek(xFilial("VVD")+cCodDes+aVeicTot[ni,8])
				If aVeicTot[ni,1] //SE TIVER TICADO GRAVAR NA TABELA VVD
					RecLock("VVD",lachoVVD)
					If lVVD_FILENT
						VVD->VVD_FILIAL := xFilial("VVD")
						VVD->VVD_FILENT := VV1->VV1_FILENT
					Else
						VVD->VVD_FILIAL := VV1->VV1_FILENT
					Endif
					VVD->VVD_FILIAL := xFilial("VVD")
					VVD->VVD_TIPOPE := "0" //Despesa
					VVD->VVD_TRACPA := VV1->VV1_TRACPA
					VVD->VVD_CHAINT := VV1->VV1_CHAINT
					VVD->VVD_DATADR := dDataBase
					VVD->VVD_DATVEN := dDataBase
					VVD->VVD_CODFOR := Iif(lGerNf,aRet[2],"")
					VVD->VVD_LOJA   := Iif(lGerNf,aRet[3],"")
					VVD->VVD_CODCLI := ""
					VVD->VVD_LOJACL := ""
					VVD->VVD_NUMNFI := Iif(lGerNf,aRet[5],"")
					VVD->VVD_SERNFI := Iif(lGerNf,aRet[6],"")
					if fieldpos("VVD_SDOC") > 0
						VVD->VVD_SDOC := iif(lGerNf, FGX_UFSNF(aRet[6]), "")
					endif
					VVD->VVD_NUMTIT := ""
					VVD->VVD_TIPTIT := ""
					VVD->VVD_NATURE := Iif(lGerNf,aRet[9],"")
					VVD->VVD_NUMOSV := ""//VEC->VEC_NUMOSV
					VVD->VVD_CODIGO := cCodigo
					VVD->VVD_DESCRI := cDescri
					VVD->VVD_VALOR  := nValVVD
					VVD->VVD_ATUCUS := "0"//ATUA CUSTO
					VVD->VVD_GERTIT := "0"
					VVD->VVD_EXPCPG := "0"
					VVD->VVD_CODVRE := cCodDes
					If lVVD_FILUCP
						VVD->VVD_FILUCP := cFilUCp // Ultima Filial de Entrada por Compra
						VVD->VVD_TRAUCP := cTraUCp // Ultimo TraCpa de Entrada por Compra
					EndIf
					MsUnLock()
				ElseIf lVVDDel
					RecLock("VVD",.F.,.T.)
					dbdelete()
					MsUnlock()
				EndIf 
			EndIF
		Next 
	ElseIf nOpc == 5//exclusao
		cCodDes := VRF->VRF_CODDES//codigo do despesa
		If MsgYesNo("Deseja excluir a Despesa do veiculo nบ '"+ cCodDes +"'",STR0003)
			//exclui arquivo filho
			cQuery := "SELECT VVD.* FROM "+RetSqlName("VVD")+" VVD "
			cquery += "WHERE VVD.VVD_FILIAL='"+xFilial("VVD")+"' AND VVD.VVD_CODVRE='"+cCodDes+"' AND VVD.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
			   	DbSelectArea("VVD")
				DbGoTo(( cQAlSQL )->( R_E_C_N_O_ ))
				RecLock("VVD",.F.,.T.)
					dbdelete()
				MsUnlock()
				( cQAlSQL )->( DbSkip() )	
			EndDo
			( cQAlSQL )->( DbCloseArea() ) 
									
			DbSelectArea("VVD")
			
			//	exclui filtros - Fillho
			If TCCANOPEN(RetSqlName("VRG"))
				cString := "DELETE FROM "+RetSqlName("VRG")+" WHERE VRG_FILIAL='"+xFilial("VRG")+"' AND VRG_CODDES='"+cCodDes+"' "
				TCSQLEXEC(cString)
				
				//exclui arquivo pai
				RecLock("VRF",.F.,.T.)
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
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CONSVEIC บAutor  ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta Veiculos                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
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
Local cOpcSel	:= "" //opcional select
Local lOpc		:= .f.
Local cMarGru := "INICIA" 
Local cQryTemp := "" 
Local lAddveic := .f.
Local aVetEmp	:= {} 
Local cSLVFil   := cFilAnt  
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
Local _nk:=0

Default cTipo := "0"

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
       
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFilAtu   := FWArrFilAtu()
	aAdd( aVetEmp, { cFilAnt, aFilAtu[5] })
Next
cFilAnt := cBkpFilAnt
cQuery := "SELECT VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_TIPVEI , VV1.VV1_FILENT , VV1.VV1_FABMOD , VV1.VV1_KILVEI , VV1.VV1_RESERV , VV1.VV1_BITMAP , VV1.VV1_DTHVAL , VV1.VV1_SUGVDA , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI , VV1.VV1_COMVEI , VV1.VV1_OPCFAB , VV1.VV1_TRACPA , VV2.VV2_GRUMOD , VV2.VV2_DESMOD "
cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' "
if Len(aGrvVei ) > 0
	for ni := 1 to Len(aGrvVei)
		cQryTemp := "" 
		if aGrvVei[ni,1]!=""
			cQryTemp +=" AND VV1.VV1_CODMAR='"+alltrim(aGrvVei[ni,1])+"'"
		endif
		if aGrvVei[ni,2]!=""
			cQryTemp +=" AND VV2.VV2_GRUMOD='"+alltrim(aGrvVei[ni,2])+"'"
		endif		
		if aGrvVei[ni,3]!=""
			cQryTemp +=" AND VV1.VV1_MODVEI='"+alltrim(aGrvVei[ni,3])+"'"
		endif	 
		cQryTemp += " AND " 
	
		If !Empty(cEstVei)// Estado do Veiculo (Novos/Usados)
			cQryTemp += "VV1.VV1_ESTVEI='"+cEstVei+"' AND "
		EndIf
		
		If !Empty(cAnoFab)// Ano Fabricacao/Modelo
			cQryTemp += "VV1.VV1_FABMOD='"+cAnoFab+"' AND "
		EndIf
		cQryTemp += "VV1.VV1_SITVEI IN ('0') AND "
		//	cQuery += "VV1.VV1_SITVEI IN ('0','2','3','4') AND "
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
						//( cQAlSQL )->( DbSkip() )//desconsidera o veiculo 
						lAddveic:= .f.
					EndIF 
					IF lAddveic

						For _ni:=1 to 5
							cOpcSel := ""
							If !Empty(Substr(( cQAlSQL )->( VV1_OPCFAB ),(_ni*4)-3,3))
								cOpcSel := Substr(( cQAlSQL )->( VV1_OPCFAB ),(_ni*4)-3,3)
								If !(cOpcSel $ cOpcVei)
									//( cQAlSQL )->( DbSkip() )//desconsidera o veiculo
									lAddveic:= .f.
									exit
								EndIF
								
							EndIF
						next
					EndIF
				EndIF
				if lAddveic
				
            		_nk := aScan(aVetEmp,{|x| x[1] == IIf(!Empty(( cQAlSQL )->( VV1_FILIAL )),( cQAlSQL )->( VV1_FILIAL ),( cQAlSQL )->( VV1_FILENT )) })//pega a posicao da filial no array
 					aAdd(aVeicTot, { .F. ,;//Tick
						IIf(!Empty(( cQAlSQL )->( VV1_FILIAL )),( cQAlSQL )->( VV1_FILIAL )+" - " + Iif(_nk>0,aVetEmp[_nk,2],""),( cQAlSQL )->( VV1_FILENT )+" - " + Iif(_nk>0,aVetEmp[_nk,2],"")) , ;
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
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LEVANTA  บAutor  ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta MARCA / GRUPO MODELO / MODELO /  ...               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVANTA(cTipo,lRefresh)
Local aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
Local cCodSM0 := aSM0[1]
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
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK      บAutor  ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK dos ListBox de Filtro                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
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
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK2    บAutor   ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK2 da Selecao dos veiculos                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK2(nLinha,nOpc)
If nOpc =2 .or. nOpc =5  //visualizar/excluir nao permite alterar
	Return()
EndIF

If !aVeicTot[nLinha,01]
	DbSelectArea("VVA")
	DbSetOrder(2)
	If DbSeek(xFilial("VVA")+aVeicTot[nLinha,08])//chassi 
		lTroca := .T.
		While ! VVA->(EOF()) .AND. ALLTRIM(VVA->VVA_FILIAL) == ALLTRIM(xFilial("VVA")) .AND. ALLTRIM(VVA->VVA_CHASSI) == ALLTRIM(aVeicTot[nLinha,08])
			DbSelectArea("VV9")
			DbSetOrder(1)
			If DbSeek(xFilial("VV9")+VVA->VVA_NUMTRA)
				If VV9->VV9_STATUS=="L" //APROVADO
					DbSelectArea("VAI")
					DbSetOrder(4)
					DbSeek( xFilial("VAI") + __CUSERID )
					If VAI->VAI_MANDES != "1"
						MsgInfo(STR0052,STR0003) // "Usuแrio sem permissใo para lan็ar despesa com veํculos com proposta aprovada."
						lTroca := .F.
						EXIT
					EndIF
				EndIf
			EndIf
			VVA->(DbSkip())
		EndDo
		If lTroca
			aVeicTot[nLinha,01] := !aVeicTot[nLinha,01]
		EndIf
	Else
		aVeicTot[nLinha,01] := !aVeicTot[nLinha,01]
	EndIF
Else
	aVeicTot[nLinha,01] := !aVeicTot[nLinha,01]
EndIf

oLbVeic:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK3     บAutor  ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK3 da Selecao de todos list filtro.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK3(cChama,lTipo,nOpc)
Local _ni:= 1
Local lOk := .f.
If nOpc =2 .or. nOpc =5  //visualizar/excluir nao permite alterar
	Return()
EndIF
If cChama = "MAR"
	lOk    := .t.
	lSGmod := .F.
	lSMod  := .F.
	For _ni := 1 to Len(aMar)
		aMar[_ni,01] := lTipo
	Next
	FS_LEVANTA("GRU",.t.)
	FS_LEVANTA("MOD",.t.)
ElseIF cChama = "GRU"
	For _ni := 1 to Len(aMar)
		If aMar[_ni,01]
			lOk := .t.
			Exit
		EndIf
	Next
	lSMod := .F.
	If Len(aGru) > 1 .or. ( Len(aGru) == 1 .and. !Empty(aGru[1,03]) )
		For _ni := 1 to Len(aGru)
			aGru[_ni,01] := lTipo 
		Next
		FS_LEVANTA("MOD",.t.)
	EndIf
ElseIF cChama = "MOD"
	For _ni := 1 to Len(aGru)
		If aGru[_ni,01]
			lOk := .t.
			Exit
		EndIf
	Next
	If Len(aMod) > 1 .or. ( Len(aMod) == 1 .and. !Empty(aMod[1,06]) )
		For _ni := 1 to Len(aMod)
			aMod[_ni,01] := lTipo
		Next
	EndIf
EndIF   
oCGMod:Refresh() 
oCMod:Refresh()
oLbMar:Refresh()
oLbGru:Refresh()
oLbMod:Refresh()
If lOk
	FS_CONSVEIC() 
EndIf
Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK4     บAutor  ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK4(lVeicTot,nOpc)
Local _ni:= 1
If nOpc =2 .or. nOpc =5  //visualizar/excluir nao permite alterar
	Return()
EndIF
For _ni := 1 to Len(aVeicTot)
	If !aVeicTot[_ni,01]
		DbSelectArea("VVA")
		DbSetOrder(2)
		If DbSeek(xFilial("VVA")+aVeicTot[_ni,08])//chassi 
			lTroca := .T.
			While ! VVA->(EOF()) .AND. ALLTRIM(VVA->VVA_FILIAL) == ALLTRIM(xFilial("VVA")) .AND. ALLTRIM(VVA->VVA_CHASSI) == ALLTRIM(aVeicTot[nLinha,08])
				DbSelectArea("VV9")
				DbSetOrder(1)
				If DbSeek(xFilial("VV9")+VVA->VVA_NUMTRA)
					If VV9->VV9_STATUS=="L" //APROVADO
						DbSelectArea("VAI")
						DbSetOrder(4)
						DbSeek( xFilial("VAI") + __CUSERID )
						If VAI->VAI_MANDES != "1"
							lTroca := .F.
							EXIT
						EndIF
					EndIf
				EndIf
				VVA->(DbSkip())
			EndDo
			If lTroca
				aVeicTot[_ni,01] := lVeicTot
			EndIf
		Else
			aVeicTot[_ni,01] := lVeicTot
		EndIF
	Else
		aVeicTot[_ni,01] := lVeicTot
	EndIf
Next 
 
oLbVeic:Refresh()
									
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALCODIGOบAutor  ณRafael Goncalves    บ Data ณ  12/08/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALCODIGO()
Local lRet := .t. 
If !Empty(cCodigo)
	DbSelectArea("VV5")
	DbSetORder(1)
	IF DbSeek(xFilial("VV5")+"0"+cCodigo)
		cDescri:= VV5->VV5_DESCRI		
	    oDescri:Refresh()
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !dbSeek(xFilial("SB1")+VV5->VV5_PECINT)
			MsgInfo(STR0053,STR0003)
			lRet := .f.
	    Else
		    lRet := .t.
	    Endif
	Else
		lRet := .f.
	EndIF
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GERNOTA  บAutor  ณRafael Goncalves    บ Data ณ  18/08/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera Nota fiscal                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GERNOTA(aRet)
Local aCab  := {}
Local aItem := {}
Local cFormProp := "" 
Local lRet := .t. 
Local cParam := GetNewPar("MV_ESPECNF","NF")
Private cSerie, cNumero			// Serie e numero da NF quando formulario proprio
Private lMsErroAuto := .f.
Private lMudouNum := .f. 		// Indica se houve mudanca da sequencia de nota fiscal

If aRet[1]==STR0047 // Form.Proprio igual a SIM
	lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
	If !lRet
		Return(lRet)
	EndIf 
Endif 


If aRet[1]==STR0047 // Form.Proprio igual a SIM
	cFormProp := "S"
	If !(lMudouNum)
		cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
	EndIf 
	aRet[5] := cNumero
	aRet[6] := cSerie
Else
	cNumero := aRet[5]
	cSerie  := aRet[6]
	cFormProp := "N"
Endif 

aCab := {;
{"F1_TIPO"	   , 'N'		,NIL},;
{"F1_DOC"	   , cNumero	,NIL},;
{"F1_SERIE"	   , cSerie		,NIL},;
{"F1_EMISSAO"  , aRet[7]	,NIL},;
{"F1_FORNECE"  , aRet[2]	,NIL},;
{"F1_LOJA"	   , aRet[3]	,NIL},;
{"F1_ESPECIE"  , cParam		,NIL},;
{"F1_COND"	   , aRet[11]	,NIL},;
{"F1_FORMUL"   ,cFormProp	,Nil},;
{"E2_NATUREZ"	,aRet[9]    ,Nil}}
//		{"F1_RECBMTO"	, dDataBase			 ,Nil}}
lRet := .f.	
DbSelectArea("VV5")
DbSetOrder(1)
If DbSeek(xFilial("VV5")+"0"+cCodigo)
	DbSelectArea("SB1")
	DbSetOrder(1)
	If dbSeek(xFilial("SB1")+VV5->VV5_PECINT)
		lRet := .t.			
		DbSelectArea("SF4")
		DbSetOrder()
		DbSeek(xFilial("SF4")+aRet[8])
		
		Aadd(aItem , {	{"D1_ITEM","01",NIL},;
		{"D1_COD"	, SB1->B1_COD	,NIL},;
		{"D1_UM"	, SB1->B1_UM	,NIL},;
		{"D1_QUANT"	, 1 			,NIL},;
		{"D1_VUNIT"	, nVlrDes 		,NIL},;
		{"D1_TOTAL"	, nVlrDes 		,NIL},;
		{"D1_TES"	, aRet[8]		,NIL},;
		{"D1_RATEIO",'2' 			,NIL},;
		{"D1_LOCAL"	, FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),NIL}} )

//		{"D1_CF"	, SF4->F4_CF	,NIL},;

//		{"D1_VALIPI", VIA->VIA_VALIPI,NIL},;
//		{"D1_IPI"	, VIA->VIA_TXAIPI,NIL},;
//		{"D1_BASEIPI", ( VIA->VIA_VALIPI / ( VIA->VIA_TXAIPI/100 ) ),NIL},;
//		{"D1_VALICM" , VIA->VIA_VALICM,NIL},;
		
		&& Seleciona a ordem dos arquivos SA2,SB1 p/ funcionar MATA140
		SA2->( DbSetOrder(1) )
		SB1->( DbSetOrder(1) )
		
		MSExecAuto({|x,y| MATA103(x,y)},aCab,aItem)
		
		aCab  := {}
		aItem := {}
		
		If lMSErroAuto
			DisarmTransaction()
			MostraErro()
			lRet := .f.
		EndIf
	EndIF
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX6")
MsRUnLock()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef     บAutor  ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Definicao do Menu                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0054 ,"axPesqui"	, 0 , 1},;	//Pesquisar
					{ STR0005 ,"VEI690"	, 0 , 2},;	//Visualizar
					{ STR0006 ,"VEI690"	, 0 , 3},; //Incluir
					{ STR0007 ,"VEI690"	, 0 , 4},; 	//Retirar
					{ STR0008 ,"VEI690"	, 0 , 5} }	//Excluir
Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CONSULNF บAutor  ณRafael Goncalves  บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abre consulta de nota fiscal                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculo                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CONSULNF()
           
if !inclui
	DbSelectArea("SF1")
	DbSetOrder(1)
	if DbSeek( xFilial("SF1") + VRF->VRF_NUMNFI+VRF->VRF_SERNFI )
		A103NFiscal("SF1",nReg,2)	
    Else
	   MsgInfo( STR0055 ) // "Nใo existe nota fiscal relacionada เ esta despesa."
	   Return(.f.)
	Endif
Else
   MsgInfo( STR0055 )
   Return(.f.)
Endif	
Return(.t.)
