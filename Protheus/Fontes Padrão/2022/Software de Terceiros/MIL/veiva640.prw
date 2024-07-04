// ษออออออออหออออออออป
// บ Versao บ 33     บ
// ศออออออออสออออออออผ

#Include "PROTHEUS.CH"
#Include "VEIVA640.CH"
Static cMVMIL0006 := GetNewPar("MV_MIL0006","")

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007037_1"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ VEIVA640 ณ Autor ณ Rafael Goncalves      ณ Data ณ 24/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Bonus do Veiculo                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Veiculo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA640()

Private aRotina := MenuDef()
Private cCadastro := (STR0001) //Bonus do Veiculo

DBSelectArea("VZQ")
DbSetOrder(1)
DbSelectArea("VZR")
DbSetOrder(1)
DbSelectArea("VZT")
DbSetOrder(1)
mBrowse( 6, 1,22,75,"VZT")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEI640_V  บAutor  ณThiago			     บ Data ณ  26/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela - Visualiza                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function VEI640_V(cAlias,nReg,nOpc) 
nOpc := 2
VEI640(cAlias,nReg,nOpc)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEI640_I  บAutor  ณThiago			     บ Data ณ  26/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela - Inclusao	                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function VEI640_I(cAlias,nReg,nOpc) 
nOpc := 3
VEI640(cAlias,nReg,nOpc)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEI640_A  บAutor  ณThiago			     บ Data ณ  26/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela - Alterar		                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function VEI640_A(cAlias,nReg,nOpc) 
nOpc := 4
VEI640(cAlias,nReg,nOpc)
Return
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEI640_E  บAutor  ณThiago			     บ Data ณ  26/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela - Excluir		                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function VEI640_E(cAlias,nReg,nOpc) 
nOpc := 5
VEI640(cAlias,nReg,nOpc)
Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVEI640    บAutor  ณRafael Goncalves    บ Data ณ  24/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEI640(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects  := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam   := 0
Local nPos      := 0
Local ni        := 0
Local lAltCpo   := .t.
Local cQueryL   := ""
Local cQAlSQLL  := "ALIASSQLL"
Local cAltDesc  := ""
Local lVZQ_COMVEN := ( VZQ->(FieldPos("VZQ_COMVEN")) > 0 )
Local lVZQ_BONPOR := ( VZQ->(FieldPos("VZQ_BONPOR")) > 0 )
Local lVZQ_DINMVD := ( VZQ->(FieldPos("VZQ_DINMVD")) > 0 ) .and. ( cMVMIL0006 == "JD" )
Local lVZQ_CDCAMP := ( VZQ->(FieldPos("VZQ_CDCAMP")) > 0 )
Local lVZQ_EVENTO := ( VZQ->(FieldPos("VZQ_EVENTO")) > 0 )
Local lVZT_OPCFAB := ( VZT->(FieldPos("VZT_OPCFAB")) > 0 )
Local lVZQ_VLRPRV := ( VZQ->(FieldPos("VZQ_VLRPRV")) > 0 )
//
Private cFiltroVX5 := "051" // Filtro tabela VX5 - 051 - Eventos
Private lSMar   := .f.
Private lSGmod  := .f.
Private lSMod   := .f.
//
Private oVerd   := LoadBitmap( GetResources() , "BR_VERDE" )	// Selecionado
Private oVerm   := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Nao Selecionado
Private aMar    := {} // Marca
Private aGru    := {} // Grupo do Modelo
Private aMod    := {} // Modelo
Private aVeicTot:= {} // Veiculos Total
// Filtros Tela //
Private cFilVV1 := xFilial("SD2")
Private aFilVV1 := {}
Private aNomFil := {}
Private cAnoFab := SPACE(9)
Private cEstVei := ""
Private aEstVei := {"","0="+STR0041,"1="+STR0042,"2="+STR0043} // Novo / Usado / Fat. Direto
Private cDatVer := ""
Private aDatVer := X3CBOXAVET("VZQ_DATVER","0")
Private cComVen := "1"
Private aComVen := IIf(lVZQ_COMVEN,X3CBOXAVET("VZQ_COMVEN","0"),{"1"})
Private cBonPor := "1"
Private aBonPor := {"1="+STR0008,"2="+STR0047} // Bonus Geral / Bonus UF
Private cTipBon := "1"
Private aTipBon := X3CBOXAVET("VZQ_TIPBON","0")
Private cObriga := "0"
Private aObriga := X3CBOXAVET("VZQ_OBRIGA","0")
Private cDescri := space(TAMSX3('VZQ_DESCRI')[1])
Private cCdCamp := IIf(lVZQ_CDCAMP,space(TAMSX3('VZQ_CDCAMP')[1]),"")
Private dDatIni := ctod("")
Private dDatFim := ctod("")
Private dDtCIni := ctod("")
Private dDtCFim := ctod("")
Private dDInMvd := ctod("")
Private dDFiMvd := ctod("")
Private dDInEnt := ctod("")
Private dDFiEnt := ctod("")
Private dDtFIni := ctod("")
Private dDtFFim := ctod("")
Private dDtOIni := ctod("")
Private dDtOFim := ctod("")
Private cEvento := IIf(lVZQ_EVENTO,space(TAMSX3('VZQ_EVENTO')[1]),"")
Private nVlrPrv := 0
Private nVlrBon := 0
Private nPrcBon := 0
Private cVZQ_VALBUF := ""
Private cVZQ_PERBUF := ""
Private nVlrAnt := 0  // guarda o valor anterior
Private nPrcAnt := 0  // guarda o percentual anterior
Private cVlrAnt := "" // guarda o valor anterior por UF 
Private cPrcAnt := "" // guarda o percentual anterior por UF
Private cOpcVei := space(100)
Private cOpcFab := space(150)
Private lBotAtu := .f. // Botao de Atualizar
Private oOk     := LoadBitmap( GetResources(), "LBTIK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private aAuxVeic:= {}
Private lTod    := .f.
Private nRecVZT := VZT->(RecNo())

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 077 , .T. , .F. } ) 	//Cabecalho
AAdd( aObjects, { 0, 100 , .T. , .F. } )  	//list box
AAdd( aObjects, { 0,   0 , .T. , .T. } )  	//Rodape

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPos  := MsObjSize (aInfo, aObjects,.F.)

FS_LEVANTA("MAR",.f.)	// Levanta Marcas
FS_LEVANTA("GRU",.f.)	// Levanta Grupos de Modelo
FS_LEVANTA("MOD",.f.)	// Levanta Modelos      

If nOpc == 2 .or. nOpc == 4 .or. nOpc == 5  //visualizar/alterar/excluir levanta as infomacoes anteriores

	DbSelectArea("VZQ")
	DbSetOrder(1)
	If !DbSeek(VZT->VZT_FILIAL+VZT->VZT_CODBON)
		Return()
	EndIf

	//SELECIONA AS MARCAS//
	cQueryL := "SELECT VZT.* FROM "+RetSqlName("VZT")+" VZT "
	cqueryL += "WHERE VZT.VZT_FILIAL='"+xFilial("VZT")+"' AND VZT.VZT_CODBON='"+VZQ->VZQ_CODBON+"' AND VZT.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryL ), cQAlSQLL , .F., .T. )
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aMar, {|x| x[2] == ( cQAlSQLL )->( VZT_CODMAR ) }) // Verifica se a Marca esta selecionada
		If nPos > 0
			aMar[nPos,1] := .T.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	( cQAlSQLL )->( DbGoTop() )

	FS_LEVANTA("GRU",.f.)	// Levanta Grupos de Modelo das marcas selecionadas.
	//SELECIONA OS GRUPO MODELO//
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aGru, {|x| x[2]+x[3] == ( cQAlSQLL )->( VZT_CODMAR )+( cQAlSQLL )->( VZT_GRUMOD ) }) // Verifica se o grupo modelo esta selecionada
		If nPos > 0
			aGru[nPos,1] := .T.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	( cQAlSQLL )->( DbGoTop() )

	FS_LEVANTA("MOD",.f.,nOpc)	// Levanta Modelos
	//SELECIONA OS MODELOS//
	While !( cQAlSQLL )->( Eof() )
		nPos := aScan(aMod, {|x| x[2]+x[3]+x[6] == ( cQAlSQLL )->( VZT_CODMAR )+( cQAlSQLL )->( VZT_GRUMOD )+( cQAlSQLL )->( VZT_MODVEI ) }) // Verifica se o grupo modelo esta selecionada
		If nPos > 0
			aMod[nPos,1] := .t.
		EndIf
		( cQAlSQLL )->( DbSkip() )
	EndDo
	For ni := 1 to len(aMod)
		If !aMod[ni,1] //manutencao no valor do veiculo
			aMod[ni,7] := VZQ->VZQ_VALBON
			aMod[ni,8] := VZQ->VZQ_PERBON
			If lVZQ_BONPOR
				aMod[ni,9] := VZQ->VZQ_VALBUF
				aMod[ni,10]:= VZQ->VZQ_PERBUF
			EndIf
		EndIf
	Next
	( cQAlSQLL )->( DbCloseArea() )
	
	DbSelectArea("VZT")
	DbGoTo(nRecVZT)
	
	cComVen := "1"
	If lVZQ_COMVEN
		cComVen := VZQ->VZQ_COMVEN
	EndIf
	cTipBon := VZQ->VZQ_TIPBON
	cObriga := VZQ->VZQ_OBRIGA
	cAnoFab := VZT->VZT_FABMOD
	cOpcVei := VZT->VZT_OPCION
	cEstVei := VZT->VZT_ESTVEI
	nVlrBon := VZQ->VZQ_VALBON
	nPrcBon := VZQ->VZQ_PERBON
	If lVZQ_BONPOR
		cBonPor     := VZQ->VZQ_BONPOR
		cVZQ_VALBUF := VZQ->VZQ_VALBUF
		cVZQ_PERBUF := VZQ->VZQ_PERBUF
	EndIf
	dDatIni := VZQ->VZQ_DATINI
	dDatFim := VZQ->VZQ_DATFIN
	dDtCIni := VZQ->VZQ_DINCPA
	dDtCFim := VZQ->VZQ_DFICPA
	cDatVer := VZQ->VZQ_DATVER
	cDescri := VZQ->VZQ_DESCRI
	
	If lVZQ_DINMVD
		dDInMvd := VZQ->VZQ_DINMVD
		dDFiMvd := VZQ->VZQ_DFIMVD
		dDInEnt := VZQ->VZQ_DINENT
		dDFiEnt := VZQ->VZQ_DFIENT
	Endif
		
	If lVZQ_CDCAMP
		cCdCamp := VZQ->VZQ_CDCAMP // Codigo da Campanha
		dDtFIni := VZQ->VZQ_DINFDD // Data Inicial FDD
		dDtFFim := VZQ->VZQ_DFIFDD // Data Final FDD
		dDtOIni := VZQ->VZQ_DINORS // Data Inicial ORSD 
		dDtOFim := VZQ->VZQ_DFIORS // Data Final ORSD
	EndIf
	
	If lVZQ_EVENTO
		cEvento := VZQ->VZQ_EVENTO
	EndIf

	If lVZQ_VLRPRV
		nVlrPrv := VZQ->VZQ_VLRPRV
	EndIf
	
	cOpcFab := VZT->VZT_OPCFAB

	FS_CONSVEIC("1")//levanta veiculos para marca/grupo e modelo selecionado
	
	//Le o VZR para verificar veiculos de excesao de bonus
	For ni := 1 to len(aVeicTot) // Monta Vetor por Marca (Modelo)
		DbSelectArea("VZR")
		DbSetOrder(1)
		If DbSeek(xFilial("VZR") + VZQ->VZQ_CODBON + aVeicTot[ni,8])
			aVeicTot[ni,1] := .t.
		EndIf
	Next
	aAuxVeic := aClone( aVeicTot )//controle dos veiculos selecionados
EndIf

If Len(aVeicTot) <= 0
	aAdd(aVeicTot,{.f.," "," "," "," "," "," "," "," ",0," "})
EndIf

//verifica se for visualizacao ou exclusao nao permite alterar
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	lAltCpo := .f.
EndIF
IF nOpc == 2
	cAltDesc := STR0037 // "Visualizar"
ElseIf nOpc == 3
	cAltDesc := STR0038 // "Incluir"
ElseIf nOpc == 4
	cAltDesc := STR0039 // "Alterar"
ElseIf nOpc == 5
	cAltDesc := STR0040 // "Excluir"
EndIF
        
nVlrAnt := nVlrBon
nPrcAnt := nPrcBon
cVlrAnt := cVZQ_VALBUF
cPrcAnt := cVZQ_PERBUF

// PONTO DE ENTRADA PARA ALTERACAO DOS VETORES DA TELA
If ExistBlock("VA640AVE")
	ExecBlock("VA640AVE",.f.,.f.)
EndIf

DEFINE MSDIALOG oBonVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE STR0001+" - "+cAltDesc OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS//bonus do veiculo
oBonVeic:lEscClose := .F.

@ aPos[1,1],aPos[1,2]+000 TO aPos[2,1]-2,aPos[1,4]-2 LABEL "" OF oBonVeic PIXEL

// descricao //
@ aPos[1,1]+004,aPos[1,2]+005 SAY STR0009 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Descricao

If lVZQ_CDCAMP

	@ aPos[1,1]+003,aPos[1,2]+066 MSGET oDescri VAR cDescri PICTURE "@!" SIZE 205,08 OF oBonVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo

	// CODIGO CAMPANHA
	@ aPos[1,1]+004,aPos[1,2]+279 SAY STR0056 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Codigo
	@ aPos[1,1]+003,aPos[1,2]+301 MSGET oCdCamp VAR cCdCamp PICTURE "@!" SIZE 070,08 OF oBonVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo

Else

	@ aPos[1,1]+003,aPos[1,2]+066 MSGET oDescri VAR cDescri PICTURE "@!" SIZE 305,08 OF oBonVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo

EndIf

// TIPO BONUS //
@ aPos[1,1]+016,aPos[1,2]+005 SAY STR0002 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Tipo Bonus
@ aPos[1,1]+015,aPos[1,2]+066 MSCOMBOBOX oComVen VAR cComVen SIZE 52,08 COLOR CLR_BLACK ITEMS aComVen OF oBonVeic VALID FS_COMVEN() PIXEL COLOR CLR_BLUE WHEN lAltCpo
@ aPos[1,1]+015,aPos[1,2]+126 MSCOMBOBOX oTipBon VAR cTipBon SIZE 65,08 COLOR CLR_BLACK ITEMS aTipBon OF oBonVeic  ON CHANGE FS_CONSVEIC() VALID NaoVazio() PIXEL COLOR CLR_BLUE WHEN lAltCpo

// VALOR/PERCENTUAL //
@ aPos[1,1]+032,aPos[1,2]+005 MSCOMBOBOX oBonPor VAR cBonPor SIZE 58,08 COLOR CLR_BLUE ITEMS aBonPor OF oBonVeic ON CHANGE FS_BONUF("0",nOpc) PIXEL COLOR CLR_BLUE  WHEN lAltCpo .and. lVZQ_BONPOR
@ aPos[1,1]+027,aPos[1,2]+066 MSGET oVlrBon VAR nVlrBon PICTURE "@E 999,999,999.99" SIZE 55,08 VALID (Positivo() .and. (FS_ALTVLR(),nVlrAnt:=nVlrBon)) OF oBonVeic PIXEL COLOR CLR_BLUE HASBUTTON  WHEN lAltCpo .and. cBonPor=="1"
@ aPos[1,1]+039,aPos[1,2]+066 BUTTON oVZQ_VLRBUF PROMPT STR0053 OF oBonVeic SIZE 55,10 PIXEL ACTION (FS_BONUF("1",nOpc),cVlrAnt:=cVZQ_VALBUF) WHEN cBonPor=="2" // Valor por UF
@ aPos[1,1]+027,aPos[1,2]+126 MSGET oPrcBon VAR nPrcBon PICTURE "@E 99.9999%" SIZE 55,08 VALID (Positivo() .and. (FS_ALTVLR(),nPrcAnt:=nPrcBon)) OF oBonVeic PIXEL COLOR CLR_BLUE HASBUTTON  WHEN lAltCpo .and. cBonPor=="1"
@ aPos[1,1]+039,aPos[1,2]+126 BUTTON oVZQ_PERBUF PROMPT STR0054 OF oBonVeic SIZE 55,10 PIXEL ACTION (FS_BONUF("2",nOpc),cPrcAnt:=cVZQ_PERBUF) WHEN cBonPor=="2" // % por UF

// OPCIONAIS //
@ aPos[1,1]+052,aPos[1,2]+005 SAY STR0012 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Opcionais
@ aPos[1,1]+051,aPos[1,2]+066 MSGET oOpcVei VAR cOpcVei PICTURE VZT->(X3PICTURE("VZT_OPCION")) SIZE 116,08 VALID FS_CONSVEIC() OF oBonVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo

// ESTADO //
@ aPos[1,1]+064,aPos[1,2]+005 SAY STR0010 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Estado
@ aPos[1,1]+063,aPos[1,2]+066 MSCOMBOBOX oEstVei VAR cEstVei SIZE 50,08 COLOR CLR_BLUE ITEMS aEstVei OF oBonVeic ON CHANGE FS_CONSVEIC() PIXEL COLOR CLR_BLUE  WHEN lAltCpo

// ANO FAB/MOD DO VEICULO //
@ aPos[1,1]+064,aPos[1,2]+119 SAY STR0011 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Fab/Mod
@ aPos[1,1]+063,aPos[1,2]+145 MSGET oAnoFab VAR cAnoFab PICTURE "@R 9999/9999" SIZE 25,08 VALID FS_CONSVEIC() OF oBonVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo

// OBRIGATORIO //
@ aPos[1,1]+016,aPos[1,2]+206 SAY STR0007 SIZE 55,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Obrigatorio
@ aPos[1,1]+015,aPos[1,2]+251 MSCOMBOBOX oObriga VAR cObriga SIZE 35,08 COLOR CLR_BLUE ITEMS aObriga OF oBonVeic PIXEL COLOR CLR_BLUE WHEN lAltCpo

// DATA VERIFICAR //
@ aPos[1,1]+016,aPos[1,2]+289 SAY STR0055 SIZE 65,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Data a verificar
@ aPos[1,1]+015,aPos[1,2]+328 MSCOMBOBOX oDatVer VAR cDatVer SIZE 43,08 COLOR CLR_BLUE ITEMS aDatVer OF oBonVeic VALID FS_DATVER() PIXEL COLOR CLR_BLUE WHEN lAltCpo

If lVZQ_VLRPRV
	@ aPos[1,1]+016,aPos[1,2]+386 SAY STR0063 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Vlr.Previsto p/Bonus
	@ aPos[1,1]+015,aPos[1,2]+440 MSGET oVlrPrv VAR nVlrPrv PICTURE "@E 99,999,999,999.99" SIZE 65,08 VALID Positivo() OF oBonVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo
EndIf
	
// DATA VIGENCIA //
@ aPos[1,1]+028,aPos[1,2]+206 SAY STR0004 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Data de Venda
@ aPos[1,1]+027,aPos[1,2]+251 MSGET oDatIni VAR dDatIni VALID(IIF(dDatIni>dDatFim,dDatFim:=dDatIni,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo .and. cDatVer <> "1" HASBUTTON
@ aPos[1,1]+028,aPos[1,2]+308 SAY STR0005 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // a
@ aPos[1,1]+027,aPos[1,2]+324 MSGET oDatFim VAR dDatFim VALID(IIF(dDatIni>dDatFim,.F.,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK  WHEN lAltCpo .and. cDatVer <> "1" HASBUTTON

// DATA COMPRA //
@ aPos[1,1]+040,aPos[1,2]+206 SAY STR0006 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Data de Compra
@ aPos[1,1]+039,aPos[1,2]+251 MSGET oDtCIni VAR dDtCIni VALID(IIF(dDtCIni>dDtCFim,dDtCFim:=dDtCIni,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo .and. cDatVer <> "0" HASBUTTON
@ aPos[1,1]+040,aPos[1,2]+308 SAY STR0005 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // a
@ aPos[1,1]+039,aPos[1,2]+324 MSGET oDtCFim VAR dDtCFim VALID(IIF(dDtCIni>dDtCFim,.F.,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK  WHEN lAltCpo .and. cDatVer <> "0" HASBUTTON

If ( GetNewPar("MV_MIL0014","0") == "1" ) // Utiliza Rotina Central de Pedido? (0=Nใo;1=Sim)

	If lVZQ_CDCAMP

		// DATA FDD //
		@ aPos[1,1]+052,aPos[1,2]+206 SAY STR0057 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Data FDD
		@ aPos[1,1]+051,aPos[1,2]+251 MSGET oDtFIni VAR dDtFIni PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
		@ aPos[1,1]+052,aPos[1,2]+308 SAY STR0005 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // a
		@ aPos[1,1]+051,aPos[1,2]+324 MSGET oDtFFim VAR dDtFFim PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK  WHEN lAltCpo HASBUTTON
	
		// DATA ORSD //
		@ aPos[1,1]+064,aPos[1,2]+206 SAY STR0058 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Data ORSD
		@ aPos[1,1]+063,aPos[1,2]+251 MSGET oDtOIni VAR dDtOIni PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
		@ aPos[1,1]+064,aPos[1,2]+308 SAY STR0005 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // a
		@ aPos[1,1]+063,aPos[1,2]+324 MSGET oDtOFim VAR dDtOFim PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
	
	EndIf

	If lVZQ_DINMVD

		// DATA MARCAR VENDIDO //
		@ aPos[1,1]+028,aPos[1,2]+386 SAY STR0059 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // "Marcado Vendido"
		@ aPos[1,1]+027,aPos[1,2]+436 MSGET oDInMvd VAR dDInMvd VALID(IIF(dDInMvd>dDFiMvd,dDFiMvd:=dDInMvd,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
		@ aPos[1,1]+028,aPos[1,2]+489 SAY STR0005 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // a
		@ aPos[1,1]+027,aPos[1,2]+501 MSGET oDFiMvd VAR dDFiMvd VALID(IIF(dDInMvd>dDFiMvd,.F.,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK  WHEN lAltCpo HASBUTTON
	
		// DATA DE ENTREGA //
		@ aPos[1,1]+040,aPos[1,2]+386 SAY STR0060 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // "Entrega"
		@ aPos[1,1]+039,aPos[1,2]+436 MSGET oDInEnt VAR dDInEnt VALID(IIF(dDInEnt>dDFiEnt,dDFiEnt:=dDInEnt,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
		@ aPos[1,1]+040,aPos[1,2]+489 SAY STR0005 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // a
		@ aPos[1,1]+039,aPos[1,2]+501 MSGET oDFiEnt VAR dDFiEnt VALID(IIF(dDInEnt>dDFiEnt,.F.,.T.)) PICTURE "@D" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK  WHEN lAltCpo HASBUTTON
	
	EndIf

	If lVZQ_EVENTO

		// EVENTO //
		@ aPos[1,1]+052,aPos[1,2]+386 SAY STR0061 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // "Evento"
		@ aPos[1,1]+051,aPos[1,2]+436 MSGET oEvento VAR cEvento VALID ( Empty(cEvento) .or. OFIOA560VL("051",cEvento) ) F3 "VX5AUX" PICTURE "@!" SIZE 47,08 OF oBonVeic PIXEL COLOR CLR_BLACK WHEN lAltCpo HASBUTTON
	
	EndIf

	If lVZT_OPCFAB

		// OPCIONAIS FABRICA//
		@ aPos[1,1]+064,aPos[1,2]+386 SAY STR0062 SIZE 50,8 OF oBonVeic PIXEL COLOR CLR_BLUE // Opcionais Fแbrica
		@ aPos[1,1]+063,aPos[1,2]+436 MSGET oOpcFab VAR cOpcFab PICTURE VZT->(X3PICTURE("VZT_OPCFAB")) SIZE 137,08 VALID FS_CONSVEIC() OF oBonVeic PIXEL COLOR CLR_BLUE  WHEN lAltCpo

	EndIf

EndIf

nTam := ( aPos[1,4] / 7 )

// MARCA //
@ aPos[2,1],aPos[2,2]+(nTam*0) TO aPos[2,3]-003,(nTam*2) LABEL STR0013 OF oBonVeic PIXEL // Marca
@ aPos[2,1]+007,aPos[2,2]+(nTam*0)+2 LISTBOX oLbMar FIELDS HEADER "",STR0013,STR0009 COLSIZES 10,20,40 SIZE (nTam*2)-6,aPos[2,3]-aPos[2,1]-12 OF oBonVeic PIXEL ON DBLCLICK (FS_TIK("MAR",oLbMar:nAt,nOpc),FS_CONSVEIC())//Marca # Descricao
oLbMar:SetArray(aMar)
oLbMar:bLine := { || { 	IIf(aMar[oLbMar:nAt,1],oVerd,oVerm) , aMar[oLbMar:nAt,2] , aMar[oLbMar:nAt,3] }}
oLbMar:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lsMar := !lsMar , FS_TIK3("MAR",lsMar,nOpc) ) ,Nil) , }

// GRUPO DO MODELO //
@ aPos[2,1],aPos[2,2]+(nTam*2) TO aPos[2,3]-003,(nTam*4) LABEL STR0015 OF oBonVeic PIXEL // Grupo do Modelo
@ aPos[2,1]+007,aPos[2,2]+(nTam*2)+2 LISTBOX oLbGru FIELDS HEADER "",STR0013,STR0009 COLSIZES 10,20,40 SIZE (nTam*2)-6,aPos[2,3]-aPos[2,1]-12 OF oBonVeic PIXEL ON DBLCLICK (FS_TIK("GRU",oLbGru:nAt,nOpc),,FS_CONSVEIC())//Marca # Descricao
oLbGru:SetArray(aGru)
oLbGru:bLine := { || { 	IIf(aGru[oLbGru:nAt,1],oVerd,oVerm) , aGru[oLbGru:nAt,2] , aGru[oLbGru:nAt,4] }}
oLbGru:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lsgMod := !lsgMod , FS_TIK3("GRU",lsgMod,nOpc) ) ,Nil) , }

// MODELO //
@ aPos[2,1],aPos[2,2]+(nTam*4) TO aPos[2,3]-003,(nTam*7) LABEL STR0016 OF oBonVeic PIXEL // Modelo
@ aPos[2,1]+007,aPos[2,2]+(nTam*4)+2 LISTBOX oLbMod FIELDS HEADER "",STR0013,STR0017,STR0003,STR0048 COLSIZES 10,20,120,40,20 SIZE ((nTam*3)-6),aPos[2,3]-aPos[2,1]-12 OF oBonVeic PIXEL ON DBLCLICK (Iif(oLbMod:nColPos<=3,FS_TIK("MOD",oLbMod:nAt,nOpc),FS_MANVKR(oLbMod:nAt,nOpc)),FS_CONSVEIC())//Marca # Modelo - Descricao # Valor Bonus
oLbMod:SetArray(aMod)
oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oVerd,oVerm) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5] , FG_AlinVlrs(Transform(IIf(aMod[oLbMod:nAt,1],aMod[oLbMod:nAt,7],0),"@E 999,999,999.99")), FG_AlinVlrs(Transform(IIf(aMod[oLbMod:nAt,1],aMod[oLbMod:nAt,8],0),"@E 99.9999%"))  }}
oLbMod:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lsMod := !lsMod , FS_TIK3("MOD",lsMod,nOpc) ) ,Nil) , }

// VEICULOS //
@ aPos[3,1]-002,aPos[3,2] TO aPos[3,3],aPos[3,4] LABEL STR0044 OF oBonVeic PIXEL // excecoes
@ aPos[3,1]+005,aPos[3,2]+002 LISTBOX oLbVeic FIELDS HEADER " ",STR0019,STR0013,STR0016,STR0022,STR0023,STR0024,STR0021,STR0020,STR0018,STR0014, STR0062 COLSIZES ;//"Loja ## Marca ## Modelo ## Fab/Mod ## Combustivel ## Opcionais Fabrica ## Chassi ## Placa ## Kilometragem ## Tipo Veiculo"
10,55,25,70,40,65,120,90,40,50,50,90 SIZE aPos[3,4]-005,aPos[3,3]-aPos[3,1]-009 OF oBonVeic PIXEL ON DBLCLICK FS_TIK2(oLbVeic:Nat,nOpc)
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
oLbVeic:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lTod := !lTod , FS_TIK2(0,nOpc) ) ,Nil) , }

ACTIVATE MSDIALOG oBonVeic ON INIT EnchoiceBar(oBonVeic,{|| IF(FS_GRAVAR(nOpc),oBonVeic:End(),.T.) , .f. },{|| oBonVeic:End() } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณ FS_BONUF ณ Autor ณ Andre Luis Almeida    ณ Data ณ 12/03/15 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Valores / Percentuais por Estados ( UF )                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_BONUF(cTp,nOpc)
Local aRet      := {}
Local aParamBox := {}
Local cAlt      := IIf(nOpc==3.or.nOpc==4,".T.",".F.")
Local cRet      := ""
Local cMascara  := ""
Local cMascGrv  := "@E 9999999"
Local nX        := 3
Local ni        := 0
Local nDiv      := 0
Local cTit      := ""
Local aUF       := {"AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG","PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"}
If cTp == "0" // Validacao combo 
	If cAlt == ".T."
		If cBonPor == "1" // Bonus Geral
			nVlrBon := nVlrAnt
			nPrcBon := nPrcAnt
			cVlrAnt := cVZQ_VALBUF
			cPrcAnt := cVZQ_PERBUF
		ElseIf cBonPor == "2" // Bonus por UF
			nVlrBon := 0
			nPrcBon := 0
			FS_ALTVLR()
			cVZQ_VALBUF := cVlrAnt
			cVZQ_PERBUF := cPrcAnt
		EndIf
	EndIf
Else // Botoes
	If cTp $ "1/3" // Valores
		cMascara := "@E 99,999.99"
		If cTp == "1"
			cCampo := cVZQ_VALBUF // Geral
		Else
			cCampo := cManVlr // Modelo
		EndIf
		nDiv := 100
		cTit := STR0053 // Valores por UF
	ElseIf cTp $ "2/4" // %
		cMascara := "@E 99.9999"
		If cTp == "2"
			cCampo := cVZQ_PERBUF // Geral
		Else
			cCampo := cManPrc // Modelo
		EndIf
		nDiv := 10000
		cTit := STR0054 // % por UF
	EndIf
	For ni := 1 to len(aUF)
		AADD(aParamBox,{1,aUF[ni],(val(substr(cCampo,nX,7))/nDiv),cMascara,"positivo()","",cAlt,40,.f.})
		nX += 9
	Next
	If ParamBox(aParamBox,cTit,@aRet,,,,,,,,.f.)
		If cAlt == ".T."
			For ni := 1 to len(aUF)
				cRet += aUF[ni]+Transform((aRet[ni]*nDiv),cMascGrv) // ( UF ) + ( Valor ou % )
			Next
			If cTp == "1" // Valores
				cVZQ_VALBUF := cRet
			ElseIf cTp == "2" // %
				cVZQ_PERBUF := cRet
			ElseIf cTp == "3" // Valores Modelo
				cManVlr := cRet
			ElseIf cTp == "4" // % Modelo
				cManPrc := cRet
			EndIf
		EndIf
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FS_GRAVARณ Autor ณ Rafael Goncalves      ณ Data ณ 24/05/10 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ BGrava Bonus do Veiculo                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GRAVAR(nOpc)
Local lRet        := .t.
Local ni          := 0
Local cCodBon     := SPACE(LEN(VZQ->VZQ_CODBON))
Local lAltGrv     := .t.
Local aGrvVei     := {}
Local lVZQ_COMVEN := ( VZQ->(FieldPos("VZQ_COMVEN")) > 0 )
Local lVZQ_BONPOR := ( VZQ->(FieldPos("VZQ_BONPOR")) > 0 )
Local lVZQ_EVENTO := ( VZQ->(FieldPos("VZQ_EVENTO")) > 0 )
Local lVZQ_DINMVD := ( VZQ->(FieldPos("VZQ_DINMVD")) > 0 )  .and. ( cMVMIL0006 == "JD" )
Local lVZQ_CDCAMP := ( VZQ->(FieldPos("VZQ_CDCAMP")) > 0 )
Local lVZQ_VLRPRV := ( VZQ->(FieldPos("VZQ_VLRPRV")) > 0 )
If !FS_COMVEN()
	lRet := .f.
EndIf
If lRet
	If Empty(cDescri)
		MsgStop(STR0028,STR0031)//Nใo informado o campo Descricao do Bonus do Veiculo  ##  Atencao
		lRet := .f.
		oDescri:SetFocus()
	EndIf
EndIf
If lRet
	If cDatVer <> "1"  // 0-Data de Venda
		If Empty(dDatIni)
			MsgStop(STR0026,STR0031)//Nใo informado o campo Data Inicial de Venda do Bonus do Veiculo  ##  Atencao
			lRet := .f.
			oDatIni:SetFocus()
		ElseIf Empty(dDatFim)
			MsgStop(STR0027,STR0031)//Nใo informado o campo Data Final de Venda do Bonus do Veiculo  ##  Atencao
			lRet := .f.
			oDatFim:SetFocus()
		EndIf
	EndIf
EndIf
If lRet
	If cDatVer <> "0"  // 1-Data de Compra
		If Empty(dDtCIni)
			MsgStop(STR0051,STR0031)//Nใo informado o campo Data Inicial de Compra do Bonus do Veiculo  ##  Atencao
			lRet := .f.
			oDtCIni:SetFocus()
		ElseIf Empty(dDtCFim)
			MsgStop(STR0052,STR0031)//Nใo informado o campo Data Final de Compra do Bonus do Veiculo  ##  Atencao
			lRet := .f.
			oDtCFim:SetFocus()
		EndIf
	EndIf
EndIf
If lRet
	If Empty(cTipBon)
		MsgStop(STR0029,STR0031)//Nใo informado o campo Tipo de Bonus do Veiculo  ##  Atencao
		lRet := .f.
		oTipBon:SetFocus()
	EndIf
EndIf
If lRet
	If Empty(cObriga)
		MsgStop(STR0030,STR0031)//Nใo informado o campo Obrigatorio.  ##  Atencao
		lRet := .f.
		oObriga:SetFocus()
	EndIf
EndIf
If lRet
	If ( nOpc == 3 .Or. nOpc == 4 ) //Inclusao/alteracao
		if Len(aMod) == 0 .or. Empty(aMod[1,2])
		   MsgStop(STR0049,STR0031)
		   Return(.f.)
		Endif
		For ni := 1 to len(aMod)
		    if aMod[ni,1] 
				aAdd(aGrvVei,{aMod[ni,2],aMod[ni,3],aMod[ni,6],aMod[ni,7],aMod[ni,8],aMod[ni,9],aMod[ni,10]})
		    Endif		
		Next    
		if len(aGrvVei) <= 0
		   MsgStop(STR0049,STR0031)
		   Return(.f.)
		Endif		
		lAltGrv := .t.
		If nOpc == 4
			cCodBon := VZQ->VZQ_CODBON
			If TCCANOPEN(RetSqlName("VZT"))
				cString := "DELETE FROM "+RetSqlName("VZT")+" WHERE VZT_FILIAL='"+xFilial("VZT")+"' AND VZT_CODBON='"+cCodBon+"' "
				TCSQLEXEC(cString)
			EndIF
			//exclui arquivo filho
			DbSelectArea("VZR")
			DbSetOrder(1)
			DbSeek(xFilial("VZR")+cCodBon)
			While !Eof() .AND. VZR->VZR_CODBON==cCodBon
				RecLock("VZR",.F.,.T.)
				dbdelete()
				MsUnlock()
				DbSelectArea("VZR")
				DbSkip()
			Enddo
			lAltGrv := .f.
		elseif nOpc == 3
			cCodBon := GetSXENum("VZQ","VZQ_CODBON")
			ConfirmSx8()
		endif
		DBSelectArea("VZQ")
		RecLock("VZQ", lAltGrv )
		VZQ->VZQ_FILIAL := xFilial("VZQ")
		VZQ->VZQ_CODBON := cCodBon
		If lVZQ_COMVEN
			VZQ->VZQ_COMVEN := cComVen
		EndIf
		VZQ->VZQ_TIPBON := cTipBon
		VZQ->VZQ_OBRIGA := cObriga
		VZQ->VZQ_VALBON := nVlrBon
		VZQ->VZQ_PERBON := nPrcBon
		If lVZQ_BONPOR
			VZQ->VZQ_BONPOR := cBonPor
			VZQ->VZQ_VALBUF := cVZQ_VALBUF
			VZQ->VZQ_PERBUF := cVZQ_PERBUF
		EndIf
		VZQ->VZQ_DATINI := dDatini
		VZQ->VZQ_DATFIN := dDatFim
		VZQ->VZQ_DINCPA := dDtCIni
		VZQ->VZQ_DFICPA := dDtCFim
		VZQ->VZQ_DATVER := cDatVer
		VZQ->VZQ_DESCRI := cDescri
		If lVZQ_DINMVD
			VZQ->VZQ_DINMVD := dDInMvd
			VZQ->VZQ_DFIMVD := dDFiMvd
			VZQ->VZQ_DINENT := dDInEnt
			VZQ->VZQ_DFIENT := dDFiEnt
		Endif
		If lVZQ_CDCAMP
			VZQ->VZQ_CDCAMP := cCdCamp // Codigo da Campanha
			VZQ->VZQ_DINFDD := dDtFIni // Data Inicial FDD
			VZQ->VZQ_DFIFDD := dDtFFim // Data Final FDD
			VZQ->VZQ_DINORS := dDtOIni // Data Inicial ORSD 
			VZQ->VZQ_DFIORS := dDtOFim // Data Final ORSD
		EndIf		
		If lVZQ_EVENTO
			VZQ->VZQ_EVENTO := cEvento
		EndIf
		If lVZQ_VLRPRV
			VZQ->VZQ_VLRPRV := nVlrPrv
		EndIf
		MsUnLock()
		
		DBSelectArea("VZT")
		for ni := 1 to len(aGrvVei)
			RecLock("VZT", .t. )
				VZT->VZT_FILIAL := xFilial("VZT")
				VZT->VZT_CODBON := cCodBon //pegar valor do PAI  VZT_CODBON
				VZT->VZT_SEQUEN := StrZero(ni,tamsX3("VZT_SEQUEN")[1])
				VZT->VZT_CODMAR := aGrvVei[ni,1]
				VZT->VZT_GRUMOD := aGrvVei[ni,2]
				VZT->VZT_MODVEI := aGrvVei[ni,3]
				VZT->VZT_FABMOD := cAnoFab
				VZT->VZT_OPCION := cOpcVei
				VZT->VZT_ESTVEI := cEstVei
				VZT->VZT_VALBON := IIf(!Empty(aGrvVei[ni,4]),aGrvVei[ni,4],nVlrBon)//valor do bonus por modelo
				VZT->VZT_PERBON := IIf(!Empty(aGrvVei[ni,5]),aGrvVei[ni,5],nPrcBon)//percentual do bonus por modelo
				If lVZQ_BONPOR
					VZT->VZT_BONPOR := cBonPor
					VZT->VZT_VALBUF := aGrvVei[ni,6]
					VZT->VZT_PERBUF := aGrvVei[ni,7]
				EndIf
				VZT->VZT_OPCFAB := cOpcFab
			MsUnLock()
		next
		//grava excecao do Bonus
		For ni := 1 to len(aVeicTot) // Monta Vetor por Marca (Modelo)
			DbSelectArea("VZR")
			DbSetOrder(1)
			DbSeek(xFilial("VZR")+cCodBon+aVeicTot[ni,8])
			If aVeicTot[ni,1] //SE TIVER TICADO EH UMA EXCECAO GRAVAR NA TABELA VZR
				RecLock("VZR", !Found() )
				VZR->VZR_FILIAL := xFilial("VZR")
				VZR->VZR_CODBON := cCodBon
				VZR->VZR_CHASSI := aVeicTot[ni,8]
				MsUnLock()
			ElseIf Found()
				RecLock("VZR",.F.,.T.)
				dbdelete()
				MsUnlock()
			EndIf
		Next
	ElseIf nOpc == 5//exclusao
		cCodBon := VZQ->VZQ_CODBON//codigo do bonus
		If MsgYesNo(STR0046+"'"+ cCodBon +"'",STR0031) //"Deseja excluir o bonus nบ '# Atencao"
			//exclui arquivo filho
			DbSelectArea("VZR")
			DbSetOrder(1)
			DbSeek(xFilial("VZR")+cCodBon)
			While !Eof() .AND. VZR->VZR_CODBON==cCodBon
				RecLock("VZR",.F.,.T.)
				dbdelete()
				MsUnlock()
				DbSelectArea("VZR")
				DbSkip()
			Enddo
			
			//	exclui filtros - Fillho
			If TCCANOPEN(RetSqlName("VZT"))
				cString := "DELETE FROM "+RetSqlName("VZT")+" WHERE VZT_FILIAL='"+xFilial("VZT")+"' AND VZT_CODBON='"+cCodBon+"' "
				TCSQLEXEC(cString)
				
				//exclui arquivo pai
				RecLock("VZQ",.F.,.T.)
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
ฑฑบPrograma  ณVEIVA640DELบAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณexclui tabela VZS e zera valores na VVA                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VEIVA640DEL(cAtend,nRecVVA)
Local cString   := ""
Default nRecVVA := 0
DbSelectArea("VVA")
DbSetOrder(1)
If nRecVVA > 0
	DbGoTo(nRecVVA)
Else
	DbSeek(xFilial("VVA")+cAtend)
EndIf
If VVA->VVA_BONCON+VVA->VVA_BONREG+VVA->VVA_BONFAB > 0
	
	If TCCANOPEN(RetSqlName("VZS"))   
		If VZS->(FieldPos("VZS_FILATE")) > 0 // Filial do Atendimento	
			cString := "DELETE FROM "+RetSqlName("VZS")+" WHERE VZS_FILIAL='"+xFilial("VZS")+"' AND VZS_FILATE='"+VVA->VVA_FILIAL+"' AND VZS_NUMATE='"+VVA->VVA_NUMTRA+"' "
        Else
			cString := "DELETE FROM "+RetSqlName("VZS")+" WHERE VZS_FILIAL='"+xFilial("VZS")+"' AND VZS_NUMATE='"+cAtend+"' "
        Endif
		If VVA->(FieldPos("VVA_ITETRA")) > 0
			cString += " AND ( VZS_ITETRA='     ' OR VZS_ITETRA='"+VVA->VVA_ITETRA+"' ) "
		EndIf
		TCSQLEXEC(cString)
	EndIF
		
	//altera valor VVA
	DbSelectArea("VVA")
	RecLock("VVA", .f. )
	VVA->VVA_BONCON := 0
	VVA->VVA_BONREG := 0
	VVA->VVA_BONFAB := 0
	MsUnLock()
	
	MsgInfo(STR0032,STR0031) //A troca do veiculo fez com que os dados referentes a Bonus fossem deletados! Sera necessario nova verifica็ใo de Bonus! # Atencao

EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CONSVEICบAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณLevanta Veiculos                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CONSVEIC(cTipo)
Local cQuery    := ""
Local cQAlSQL   := "ALIASSQL"
Local ni        := 0
Local _ni       := 0
Local nPos      := 0
Local _cVV1     := ""
Local aAux      := {}
Local cOpcSel   := "" //opcional select
Local lOpc	    := .f.
Local lLevVei   := .f.
Local cMarGru   := "INICIA"
Local cQryTemp  := ""
Local lAddveic  := .t.
Local aVetEmp   := {}
Local _nk       := 0
Local aFilAtu   := FWArrFilAtu()
Local aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt:= cFilAnt
Local nCont     := 0
Default cTipo   := "0"
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aAdd(aVetEmp,{ xFilial("VVF") , FWFilialName() }) // ( xFilial("VVF") == VV1_FILENT )
Next
cFilAnt := cBkpFilAnt

aVeicTot  := {}
aGrvVei   := {}

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

If cTipBon $ "1/2" //levantar veiculos de bonus 1-fabricao / 2 - regional somente qdo informar marca+grumod
	If lTemMarca .and. lTemGrupo
		lLevVei := .t.
	EndIf
Else //se for concessionaria carrega veiculos a qualquer momento.
	lLevVei := .t.
EndIf
If lLevVei
	
	if Len(aGrvVei ) > 0
		for ni := 1 to Len(aGrvVei)
			cQuery := "SELECT VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_ESTVEI , VV1.VV1_TIPVEI , VV1.VV1_FILENT , VV1.VV1_FABMOD , VV1.VV1_KILVEI , VV1.VV1_RESERV , VV1.VV1_BITMAP , VV1.VV1_DTHVAL , VV1.VV1_SUGVDA , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI , VV1.VV1_COMVEI , VV1.VV1_OPCFAB , VV1.VV1_TRACPA , VV2.VV2_GRUMOD , VV2.VV2_DESMOD "
			cQuery += "FROM "+RetSqlName("VV1")+" VV1 "
			cQuery += "INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND "
			cQryTemp := "("
			if aGrvVei[ni,1]!=""
				cQryTemp +=" VV1.VV1_CODMAR='"+alltrim(aGrvVei[ni,1])+"'"
			endif
			if aGrvVei[ni,2]!=""
				cQryTemp +=" AND VV2.VV2_GRUMOD='"+alltrim(aGrvVei[ni,2])+"'"
			endif
			if aGrvVei[ni,3]!=""
				cQryTemp +=" AND VV1.VV1_MODVEI='"+alltrim(aGrvVei[ni,3])+"'"
			endif
			If Alltrim("["+cQryTemp+"]") <> Alltrim("[(]")
				cQryTemp += ") AND "
			Else
				cQryTemp := ""
			EndIf			
			If !Empty(cEstVei)// Estado do Veiculo (Novos/Usados)
				cQryTemp += "VV1.VV1_ESTVEI='"+cEstVei+"' AND "
			EndIf
			
			If !Empty(cAnoFab)// Ano Fabricacao/Modelo
				cQryTemp += "VV1.VV1_FABMOD='"+cAnoFab+"' AND "
			EndIf
			cQuery += "VV1.VV1_SITVEI IN ('0','2','3','4') AND " // 0=Estoque / 2=Transito / 3=Remessa / 4=Consignado
			cQryTemp += "VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHASSI "
			
			cQryTemp:= cQuery+cQryTemp
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryTemp ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				If _cVV1 # ( cQAlSQL )->( VV1_CHASSI )
					_cVV1 := ( cQAlSQL )->( VV1_CHASSI )
					lAddveic := .t.
					//verifica opcionais de fabrica.
					If !Empty(cOpcVei)
						IF Empty(( cQAlSQL )->( VV1_OPCFAB ))//se o veiculo nao possuir opcional desconsiderar.
							lAddveic:= .f.
						EndIF
						IF lAddveic
							For _ni := 1 to 5
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
						( cQAlSQL )->( VV1_FILENT )+" - " + Iif(_nk>0,aVetEmp[_nk,2],"") , ;
						( cQAlSQL )->( VV1_CODMAR ) , ;
						( cQAlSQL )->( VV2_DESMOD ) , ;
						( cQAlSQL )->( VV1_FABMOD ) , ;
						( cQAlSQL )->( VV1_COMVEI ) , ;
						left(( cQAlSQL )->( VV1_OPCFAB ),80) , ;
						( cQAlSQL )->( VV1_CHASSI ) , ;
						( cQAlSQL )->( VV1_PLAVEI ) , ;
						( cQAlSQL )->( VV1_KILVEI ) , ;
						( cQAlSQL )->( VV1_TIPVEI )  } )
					EndIf
				EndIf
				
				( cQAlSQL )->( DbSkip() )
			EndDo
			cQryTemp := ""
			( cQAlSQL )->( dbCloseArea() )
		Next
	EndIf
EndIf

If Len(aVeicTot) <= 0
	aAdd(aVeicTot,{.f.," "," "," "," "," "," "," "," ",0," "})
Endif

If Len(aAuxVeic) >0
	//ticar veiculo selecionados antes do filtro.
	For _ni := 1 to len(aVeicTot)
		
		nPos := aScan(aAuxVeic, {|x| x[8] == aVeicTot[_ni,8] }) // Verifica se a Marca esta selecionada
		If nPos > 0//ticar o veiculo
			If aAuxVeic[nPos,1]
				aVeicTot[_ni,1] := .t.
			EndIF
		EndIF
		
	Next
EndIF

// PONTO DE ENTRADA PARA ALTERACAO DOS VETORES DA TELA
If ExistBlock("VA640AV2")
	ExecBlock("VA640AV2",.f.,.f.)
EndIf

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
ฑฑบPrograma  ณFS_LEVANTA บAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Levanta FILIAL / MARCA / GRUPO MODELO / MODELO /  ...      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LEVANTA(cTipo,lRefresh,nOpc)
Local nPos      := 0
Local cQuery    := ""
Local cQAlSQL   := "ALIASSQL"
Local ni        := 0
Local nValBon   := 0
Local nPerBon   := 0
Local cValBon   := ""
Local cPerBon   := ""
Local cQueryVZT := ""
Local cQAlSVZT  := "ALIASSVZT"
Local lVZQ_BONPOR := ( VZQ->(FieldPos("VZQ_BONPOR")) > 0 )
Default nOpc    := 3
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
		aMod := {}                                                                         //, VZT.VZT_CODBON , VZT.VZT_VALBON , VZQ.VZQ_VALBON
		cQuery := "SELECT DISTINCT VV2.VV2_MODVEI , VV2.VV2_CODMAR , VV2.VV2_GRUMOD , VV2.VV2_DESMOD FROM "+RetSqlName("VV2")+" VV2 "
		cQuery += "WHERE "
		cQuery += "VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.D_E_L_E_T_=' ' ORDER BY VV2.VV2_CODMAR , VV2.VV2_DESMOD "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			nPos := aScan(aGru, {|x| x[2]+x[3] == ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD ) }) // Verifica se a Marca e o Grupo do Modelo estao selecionados
			If nPos > 0 .and. aGru[nPos,1]                                         

				lAchou := aScan(aModAux,{|x| x[2] + x[3] + x[6]== ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD ) + ( cQAlSQL )->( VV2_MODVEI ) } ) > 0
				
				if(!Empty(nVlrBon))
					nValBon := nVlrBon
				Else
					nValBon := 0
				EndIF
				if(!Empty(nPrcBon))
					nPerBon := nPrcBon
				Else
					nPerBon := 0
				EndIF
				cValBon := ""
				cPerBon := ""
				
				If (nOpc == 2 .or. nOpc == 4 .or. nOpc == 5)
					If lVZQ_BONPOR
						cQueryVZT := "SELECT VZT.VZT_VALBON, VZT.VZT_PERBON, VZT.VZT_VALBUF, VZT.VZT_PERBUF FROM "+RetSqlName("VZT")+" VZT "
					Else
						cQueryVZT := "SELECT VZT.VZT_VALBON, VZT.VZT_PERBON FROM "+RetSqlName("VZT")+" VZT "
					EndIf
					cQueryVZT += "WHERE VZT.VZT_FILIAL='"+xFilial("VZT")+"' AND VZT.VZT_CODBON='"+VZQ->VZQ_CODBON+"' AND VZT.D_E_L_E_T_=' ' AND"
					cQueryVZT += "'" +( cQAlSQL )->( VV2_CODMAR )+ "'=VZT.VZT_CODMAR AND '" +( cQAlSQL )->( VV2_GRUMOD )+ "'=VZT.VZT_GRUMOD AND '" +Alltrim(( cQAlSQL )->( VV2_MODVEI ))+ "'=VZT.VZT_MODVEI"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryVZT ), cQAlSVZT , .F., .T. )
					While !( cQAlSVZT )->( Eof() )
						If !Empty(( cQAlSVZT )->(VZT_VALBON ))
							nValBon := ( cQAlSVZT )->(VZT_VALBON )
						ElseIf !Empty(VZQ->VZQ_VALBON )
							nValBon := VZQ->VZQ_VALBON
						ElseIf !Empty(nVlrBon)
							nValBon := nVlrBon
						Else
							nValBon := 0
						EndIf
						If !Empty(( cQAlSVZT )->(VZT_PERBON ))
							nPerBon := ( cQAlSVZT )->(VZT_PERBON )
						ElseIf !Empty(VZQ->VZQ_PERBON )
							nPerBon := VZQ->VZQ_PERBON
						ElseIf !Empty(nPrcBon)
							nPerBon := nPrcBon
						Else
							nPerBon := 0
						EndIf
						If lVZQ_BONPOR
							If !Empty(( cQAlSVZT )->(VZT_VALBUF ))
								cValBon := ( cQAlSVZT )->(VZT_VALBUF )
							Else
								cValBon := ""
							EndIf
							If !Empty(( cQAlSVZT )->(VZT_PERBUF ))
								cPerBon := ( cQAlSVZT )->(VZT_PERBUF )
							Else
								cPerBon := ""
							EndIf
						EndIf
						( cQAlSVZT )->( DbSkip() )
					EndDo
					( cQAlSVZT )->( DbCloseArea() )
				EndIF
				aAdd(aMod,{lAchou,( cQAlSQL )->( VV2_CODMAR ),( cQAlSQL )->( VV2_GRUMOD ),"'"+Alltrim(( cQAlSQL )->( VV2_MODVEI ))+"'",Alltrim(( cQAlSQL )->( VV2_MODVEI ))+" - "+( cQAlSQL )->( VV2_DESMOD ),( cQAlSQL )->( VV2_MODVEI ),nValBon,nPerBon,cValBon,cPerBon})
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aMod) <= 0
			aAdd(aMod,{.f.,"","","","","",0,0,"",""})
		EndIf
		If lRefresh
			oLbMod:nAt := 1
			oLbMod:SetArray(aMod)
			oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oVerd,oVerm) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5] , FG_AlinVlrs(Transform(IIf(aMod[oLbMod:nAt,1],aMod[oLbMod:nAt,7],0),"@E 999,999,999.99")), FG_AlinVlrs(Transform(IIf(aMod[oLbMod:nAt,1],aMod[oLbMod:nAt,8],0),"@E 99.9999%")) }}
			oLbMod:Refresh()
		EndIf
EndCase
Return(.t.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK     บAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
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
			aMar[nLinha,1] := !lSelLin
			oLbMar:Refresh()
		EndIf
		FS_LEVANTA("GRU",.t.)
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "GRU"
		If len(aGru) > 1 .or. !Empty(aGru[1,2])
			lSelLin := aGru[nLinha,1]
			aGru[nLinha,1] := !lSelLin
			oLbGru:Refresh()
		EndIf
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "MOD"
		If len(aMod) > 1 .or. !Empty(aMod[1,2])
			lSelLin := aMod[nLinha,1]
			aMod[nLinha,1] := !lSelLin
			oLbMod:Refresh()
		EndIf
EndCase
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK2    บAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK2 da Selecao dos veiculos                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK2(nLinha,nOpc)
Local ni := 0
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	Return()
EndIF
If nLinha <> 0
	aVeicTot[nLinha,01] := 	!aVeicTot[nLinha,01]
Else
	For ni := 1 to Len(aVeicTot)
		aVeicTot[ni,01] := lTod
	Next
Endif
oLbVeic:Refresh()
FS_COMVEN()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TIK3    บAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ TIK3 da Selecao de todos list filtro.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TIK3(cChama,lTipo,nOpc)
Local _ni := 1
If nOpc == 2 .or. nOpc == 5  //visualizar/excluir nao permite alterar
	Return()
EndIF
If cChama = "MAR"
	lSGmod := .F.
	lSMod := .F.
	For _ni := 1 to Len(aMar)
		aMar[_ni,01] := lTipo
	Next
	FS_LEVANTA("GRU",.t.)
	FS_LEVANTA("MOD",.t.)
ElseIF cChama = "GRU"
	lSMod := .F.
	For _ni := 1 to Len(aGru)
		aGru[_ni,01] := lTipo
	Next
	FS_LEVANTA("MOD",.t.)
ElseIF cChama = "MOD"
	For _ni := 1 to Len(aMod)
		aMod[_ni,01] := lTipo
	Next
EndIF
oLbMar:Refresh()
oLbGru:Refresh()
oLbMod:Refresh()
FS_CONSVEIC()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTVLR  บAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ ALTERAR O VALOR DO BONUS NO LISTBOX MODELOS.               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ALTVLR()
Local ni := 0
For ni := 1 to len(aMod)
	If !Empty(aMod[ni,2])
		If aMod[ni,7] == nVlrAnt //valor for igual
			aMod[ni,7] := nVlrBon//recebe valor atual
		EndIf
		If aMod[ni,8] == nPrcAnt //valor for igual
			aMod[ni,8] := nPrcBon//recebe valor atual
		EndIf
	EndIf
	If nVlrBon == 0 .and. nPrcBon == 0
		aMod[ni,1] := .f.
	EndIf
Next
oLbMod:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MANVKR  บAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ MANUTENCAO NO VALOR DO BONUS                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MANVKR(nLinha,nOpc)
Private nManVlr := aMod[nLinha,7]
Private nManPrc := aMod[nLinha,8]
Private cManVlr := aMod[nLinha,9]
Private cManPrc := aMod[nLinha,10]
If !Empty(aMod[nLinha,5])
	DEFINE MSDIALOG oManVlrPct FROM 1,1 TO 09,40 TITLE (STR0033) OF oMainWnd STYLE DS_MODALFRAME STATUS //Manutencใo no Valor do Bonus
	@ 012,005 SAY STR0003 SIZE 55,8 OF oManVlrPct PIXEL COLOR CLR_BLUE // Valor Bonus
	@ 011,038 MSGET oManVal VAR nManVlr PICTURE "@E 999,999,999.99" SIZE 55,08 VALID (Positivo()) OF oManVlrPct PIXEL COLOR CLR_BLUE HASBUTTON WHEN cBonPor=="1"
	@ 011,095 BUTTON oManVlr PROMPT STR0053 OF oManVlrPct SIZE 55,10 PIXEL ACTION (FS_BONUF("3",nOpc)) WHEN cBonPor=="2" // Valor por UF
	@ 025,005 SAY STR0048 SIZE 55,8 OF oManVlrPct PIXEL COLOR CLR_BLUE // Valor %
	@ 024,038 MSGET oManPer VAR nManPrc PICTURE "@E 99.9999%" SIZE 55,08 VALID (Positivo()) OF oManVlrPct PIXEL COLOR CLR_BLUE HASBUTTON WHEN cBonPor=="1"
	@ 024,095 BUTTON oManPrc PROMPT STR0054 OF oManVlrPct SIZE 55,10 PIXEL ACTION (FS_BONUF("4",nOpc)) WHEN cBonPor=="2" // Valor por UF
	@ 041,010 BUTTON oZerar PROMPT (STR0045) OF oManVlrPct SIZE 40,10 PIXEL ACTION (aMod[nLinha,1]:=.t.,aMod[nLinha,7]:=nManVlr:=0,aMod[nLinha,8]:=nManPrc:=0,aMod[nLinha,9]:=cManVlr:="",aMod[nLinha,10]:=cManPrc:="",oLbMod:Refresh(),oManVlrPct:End()) WHEN ( nOpc==3 .or. nOpc==4 ) // Zerar Valores
	@ 041,058 BUTTON oOK    PROMPT (STR0034) OF oManVlrPct SIZE 40,10 PIXEL ACTION (aMod[nLinha,1]:=.t.,aMod[nLinha,7]:=nManVlr,aMod[nLinha,8]:=nManPrc,aMod[nLinha,9]:=cManVlr,aMod[nLinha,10]:=cManPrc,oLbMod:Refresh(),oManVlrPct:End()) // OK
	@ 041,106 BUTTON oSair  PROMPT (STR0035) OF oManVlrPct SIZE 40,10 PIXEL ACTION (oManVlrPct:End()) // SAIR
	ACTIVATE MSDIALOG oManVlrPct CENTER
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef    บAutor  ณRafael Goncalves    บ Data ณ  01/07/10  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta aRotina ( MENUDEF )                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0036 	,"axPesqui"	, 0 , 1},;	//Pesquisar
					{ STR0037	,"VEI640_V"	, 0 , 2},;	//Visualizar
					{ STR0038 	,"VEI640_I"	, 0 , 3},; 	//Incluir
					{ STR0039 	,"VEI640_A"	, 0 , 4},; 	//Alterar
					{ STR0040 	,"VEI640_E"	, 0 , 5} }	//Excluir
Return aRotina 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_COMVEN บAutor  ณ Andre Luis Almeida บ Data ณ  11/07/12  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz as validacoes do Bonus de Compra                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_COMVEN()
Local lRet := .t.
Local ni  := 0
Local nj  := 0
If cComVen == "0" // Bonus de Compra
	For ni := 1 to len(aVeicTot)
		If aVeicTot[ni,1]
			lRet := .f.
			If MsgYesNo(STR0050,STR0031) // Impossivel cadastrar excecoes para Bonus de Compra. Deseja desmarcar todas as excecoes? / Atencao
				lRet := .t.
				For nj := 1 to len(aVeicTot)
					aVeicTot[nj,1] := .f.
				Next
				oLbVeic:Refresh()
			EndIf
			Exit
		EndIf		
	Next
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_DATVER บAutor  ณ Andre Luis Almeida บ Data ณ  16/03/15  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ DATVER - Limpa campos de Datas Compra / Venda              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DATVER()
Local lRet := .t.
If cDatVer == "1" // 1=Data de Compra
	dDatIni := ctod("")
	dDatFim := ctod("")
	oDatIni:Refresh()
	oDatFim:Refresh()
ElseIf cDatVer == "0" // 0=Data de Venda
	dDtCIni := ctod("")
	dDtCFim := ctod("")
	oDtCIni:Refresh()
	oDtCFim:Refresh()
EndIf
Return(lRet)
