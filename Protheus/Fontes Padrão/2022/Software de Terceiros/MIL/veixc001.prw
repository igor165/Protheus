// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 57     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "VEIXC001.CH"

Static nAVEIMAX := IIf(GetVersao(.f.)=="P10",1,GetNewPar("MV_AVEIMAX",1)) // Qtde maxima de veiculos que podem ser selecionados por Atendimento

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  27/12/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006248_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXC001 º Autor ³ Andre Luis Almeida º Data ³  25/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta de Veiculos                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lRetorno .t. = Retorna Veiculo                             º±±
±±º          ³          .f. = Nao Retorna Veiculo                         º±±
±±º          ³ aRetFiltro = Retorno o Veiculo / Modelo / Cor / Progresso  º±±
±±º          ³   [n,01] = Chassi Interno (CHAINT)                         º±±
±±º          ³   [n,02] = Estado do Veiculo (Novo/Usado)                  º±±
±±º          ³   [n,03] = Marca                                           º±±
±±º          ³   [n,04] = Grupo Modelo                                    º±±
±±º          ³   [n,05] = Modelo                                          º±±
±±º          ³   [n,06] = Cor                                             º±±
±±º          ³   [n,07] = Cod.Progresso (Pedido)                          º±±
±±º          ³   [n,08] = Tipo (1-Normal/3-VendaFutura/4-Simulacao)       º±±
±±º          ³   [n,09] = Valor do Veiculo                                º±±
±±º          ³   [n,10] = Segmento                                        º±±
±±º          ³ cNumAte = Numero do Atendimento                            º±±
±±º          ³ nQtdVei = Qtdade de Veiculos que ja estao no Atendimento   º±±
±±º          ³ cNovoUsado = Atendimento de Veiculo NOVO ou USADO          º±±
±±º          ³ cTpFatVV0 = Tipo de Faturamento ( Novo/Usado )             º±±
±±º          ³ aIntOport = Vetor com Interesses do Cliente (Oportunidade) º±±
±±º          ³ cCliAtend = Codigo do Cliente do Atendimento               º±±
±±º          ³ cLojAtend = Loja do Cliente do Atendimento                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXC001(lRetorno,aRetFiltro,cNumAte,nQtdVei,cNovoUsado,cTpFatVV0,aIntOport,cCliAtend,cLojAtend)
Local nTam        := 0
Local aObjects    := {} , aInfo := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lEstVei     := .t.
Local nOpcao      := 0
Local ni          := 0
Local nLinha      := 0
Local nColuna     := 0
Local nCol1       := 0
Local nCol2		  := 0
Local aColunas    := {}
Local cSitVis     := "21111211" // Visualizar situacoes do Veiculo
//
Private aPosP     := {}
Private lAtend    := FM_PILHA("VEIXA018") // Consulta chamada pelo Atendimento de Veiculos VEIXA018
Private aVetMod   := {} // Vetor com Modelos para Retorno ( Simulacao / Venda Futura )
Private aVJ1      := {}
Private lRetVJ1   := .f.
Private aVeicCust := {} // Campos Customizados no ListBox de Veiculos
Private aNewBot   := {}
Private oOkTik    := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik    := LoadBitmap( GetResources() , "LBNO" )
Private oBran     := LoadBitmap( GetResources() , "BR_BRANCO" )	// Estoque
Private oLara     := LoadBitmap( GetResources() , "BR_LARANJA" )	// Em Transito
Private oPink     := LoadBitmap( GetResources() , "BR_PINK" ) 	// Remessa Saida
Private oCinz     := LoadBitmap( GetResources() , "BR_CINZA" ) 	// Remessa Entrada
Private oAzul     := LoadBitmap( GetResources() , "BR_AZUL" ) 	// Consignado
Private oVerm     := LoadBitmap( GetResources() , "BR_VERMELHO" )	// Pedido
Private oAmar     := LoadBitmap( GetResources() , "BR_AMARELO" ) 	// Reservados
Private oPret     := LoadBitmap( GetResources() , "BR_PRETO" ) 	// Bloqueados
Private oOkCon    := LoadBitmap( GetResources() , "AVGOIC1" )
Private oNoCon    := nil
Private lMar      := .f. // Marca Total
Private lGru      := .f. // Grupo do Modelo Total
Private lMod      := .f. // Modelo Total
Private lCor      := .f. // Cor Total
Private aMar      := {} // Marca
Private aGru      := {} // Grupo do Modelo
Private aMod      := {} // Modelo
Private aCor      := {} // Cor
Private aVeicTot  := {} // Veiculos Total
Private aVeicVer  := {} // Veiculos com Filtros
Private lTodBon   := .f. // Totaliza todos os Bonus (mesmo os NAO obrigatorios)
Private cFilVV1   := xFilial("VVF")
Private aFilVV1   := {}
Private cUFFiltro := "  "
Private cAnoIni   := "    "
Private cAnoFin   := "9999"
Private cTipCor   := ""
Private aTipCor   := X3CBOXAVET("VVC_TIPCOR","1")
Private cCombus   := ""
Private aCombus   := X3CBOXAVET("VV1_COMVEI","1")
Private cEstVei   := ""
Private aEstVei   := X3CBOXAVET("VV1_ESTVEI","0")
Private cTipVei   := ""
Private aTipVei   := X3CBOXAVET("VV1_TIPVEI","1")
Private nVlrIni   := 0
Private nVlrFin   := 9999999
Private nKMMaxi   := 999999999
Private nPDiasEI  := 0
Private nPDiasEF  := 99999
Private aUFTot    := {}
Private aUFFiltro := {}
Private cFoto     := ""
Private aFoto     := {"","0="+STR0002,"1="+STR0003} // Nao / Sim
Private cPromoc   := ""
Private aPromoc   := X3CBOXAVET("VV1_PROMOC","1")
Private lTipVei   := .t.
Private cOpcVei   := space(100)
Private cCfgVei   := space( TamSx3('VQ0_CONFIG')[1] )
Private lAutoma   := .t. // Atualizacao Automatica
Private lBotAtu   := .f. // Botao de Atualizar
Private cChassi   := space(TamSX3("VV1_CHASSI")[1])
Private cTpFatAt  := ""
Private cMarSel   := "" // Marcas selecionadas
Private lCkFilEst := .f. // CheckBox Fisico Estoque
Private lCkFilTra := .f. // CheckBox Fisico Em Transito
Private lCkFilRem := .f. // CheckBox Fisico Remessa Entrada
Private lCkFilRMS := .f. // CheckBox Fisico Remessa Saida
Private lCkFilCon := .f. // CheckBox Fisico Consignado
Private lCkFilPed := .f. // CheckBox Fisico Pedido
Private lCkFilNor := .f. // CheckBox Comercial Normal
Private lCkFilRes := .f. // CheckBox Comercial Reservados
Private lCkFilBlo := .f. // CheckBox Comercial Bloqueados
Private cCdCliAt  := ""
Private cLjCliAt  := ""
//
Private cTimeDig  := Time()			// Controle de tempo nos posicionamentos do ListBox
Private aPesq     := {"","","",""}	// Posicionamento na digitacao dos ListBox
//
Private cCadastro  := STR0001+IIf(lAtend," <F7>","")
//
// Parametros //
Default lRetorno   := .f.
Default aRetFiltro := {{"","","","","","","","1",0,""}}
Default cNumAte    := ""
Default nQtdVei    := 0
Default cNovoUsado := ""
Default cTpFatVV0  := ""
Default aIntOport  := {}
Default cCliAtend  := ""
Default cLojAtend  := ""
//
cTpFatAt := cTpFatVV0 // ( 0=Novo / 1=Usado )
//
cCdCliAt := cCliAtend // Codigo do Cliente do Atendimento
cLjCliAt := cLojAtend // Loja do Cliente do Atendimento
//
//////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos //
//////////////////////////////////////////////////////////////////////////////
If !AMIIn(11)
	Return
EndIf
//
lRetVJ1 := lRetorno
//
aAdd(aNewBot,{"FILTRO"    ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , FS_TOTFILT() , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },STR0094}) 	// Filtros
aAdd(aNewBot,{"MAQFOTO"   ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),VEIXC003(aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F4> "+STR0048)})	// Foto
aAdd(aNewBot,{"BMPVISUAL" ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,14]),VEIVC140(aVeicVer[oLbVeic:nAt,14], aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F5> "+STR0005)})	// Rastreamento do Veiculo
aAdd(aNewBot,{"PARAMETROS",{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),VX002VV1(aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F6> "+STR0006)})	// Visualiza Cadastro do Veiculo
If lAtend // Consulta chamada pelo Atendimento de Veiculos VEIXA018
	aAdd(aNewBot,{"ROTEIRO" ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(FS_PROGRES(lRetVJ1,@aVJ1),(nOpcao:=3,oConsVeic:End()),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F8> "+STR0007)})				// Progresso de Veiculo
	aAdd(aNewBot,{"LIQCHECK",{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(FS_SIMVDFUT(@aRetFiltro),(nOpcao:=2,oConsVeic:End()),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F9> "+STR0008)})					// Simulacao / Venda Futura
Else // Consulta chamada diretamente pelo MENU
	aAdd(aNewBot,{"INFATEND",{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),VEIXX012(1,,aVeicVer[oLbVeic:nAt,24],,"_",,.t.),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F7> "+STR0104)})	// Informações de Atendimento
	aAdd(aNewBot,{"ROTEIRO" ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(FS_PROGRES(lRetVJ1,@aVJ1),.t.,.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F8> "+STR0007)})										// Progresso de Veiculo
	aAdd(aNewBot,{"LJPRECO" ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),FGX_VEISIM(aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F9> "+STR0009)})	// Simulacao
EndIf
aAdd(aNewBot,{"AVGLBPAR1",{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),FS_BONUS(oLbVeic:nAt),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },(STR0078)})							// Bonus do Veiculo
aAdd(aNewBot,{"FOLDER11" ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),FS_DOCTO(oLbVeic:nAt),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },(STR0060)})							// Banco de Conhecimento
aAdd(aNewBot,{"BMPCPO"   ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , FS_MOSTRACFG() , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) }, "<F10>"+STR0088})
aAdd(aNewBot,{"ANALITIC" ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , VXC001TOT() , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F11> "+STR0087)})																		// Totais 
aAdd(aNewBot,{"BMPCPO"   ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , VXC001F12(.t.,cNumAte,nQtdVei) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) },("<F12> "+STR0079)})													// Parametros/Colunas
aAdd(aNewBot,{"BMPCPO"   ,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , VC001LEG() , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) }, STR0090 })													// Parametros/Colunas
//
If (ExistBlock("VXC01MD")) // Ponto de Entrada para adicionar opções no Menu
	aNewBot := ExecBlock("VXC01MD", .f., .f., {aNewBot})
EndIf
//
FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei)
//
FS_ADDVET("aVeicVer") // Adiciona linha em branco no Vetor
//
VAI->(Dbsetorder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
If VAI->VAI_ESTVEI $ "01" // Usuario somente pode vender 0-Novo ou 1-Usado
	If !Empty(cNovoUsado)
		If VAI->VAI_ESTVEI <> cNovoUsado
			If cNovoUsado == "0" // Atendimento Especifico para Veiculos Novos
				MsgStop(STR0074,STR0050) // Usuario sem permissao para Atendimentos de Veiculo Novo. / Atencao
				Return
			Else // Atendimento Especifico para Veiculos Usados
				MsgStop(STR0075,STR0050) // Usuario sem permissao para Atendimentos de Veiculo Usados. / Atencao
				Return
			EndIf
		EndIf
	EndIf
	lEstVei := .f.
	aEstVei := {VAI->VAI_ESTVEI+"="+X3CBOXDESC("VV1_ESTVEI",VAI->VAI_ESTVEI)} // Novos ou Usados
Else
	If !Empty(cNovoUsado) // Atendimento Especifico para Veiculos Novos ou Usados
		lEstVei := .f.
		aEstVei := {cNovoUsado+"="+X3CBOXDESC("VV1_ESTVEI",cNovoUsado)} // Novos ou Usados
	EndIf
EndIf
cEstVei := LEFT(aEstVei[1],TamSx3("VV1_ESTVEI")[1])
If VAI->VAI_TIPVEI $ "123" // Usuario somente pode vender 1-Normal ou 2-Taxi ou 3-Frotista
	lTipVei := .f.
	aTipVei := {VAI->VAI_TIPVEI+"="+X3CBOXDESC("VV1_TIPVEI",VAI->VAI_TIPVEI)} // Normal, Taxi ou Frotista
EndIf
cTipVei := LEFT(aTipVei[1],TamSx3("VV1_TIPVEI")[1])
If VAI->(ColumnPos("VAI_BONUSC")) > 0
	If VAI->VAI_BONUSC == "2"
		lTodBon := .t. // Totaliza todos os Bonus (mesmo os NAO obrigatorios)
	EndIf
EndIf
If VAI->(ColumnPos("VAI_SITVIS")) > 0
	If !Empty(VAI->VAI_SITVIS)
		cSitVis := VAI->VAI_SITVIS
	EndIf
EndIf
lCkFilEst := ( substr(cSitVis,1,1) == "2" ) // CheckBox Fisico Estoque
lCkFilTra := ( substr(cSitVis,2,1) == "2" ) // CheckBox Fisico Em Transito
lCkFilRem := ( substr(cSitVis,3,1) == "2" ) // CheckBox Fisico Remessa Entrada
lCkFilRMS := ( substr(cSitVis,3,1) == "2" ) // CheckBox Fisico Remessa Saida
lCkFilCon := ( substr(cSitVis,4,1) == "2" ) // CheckBox Fisico Consignado
lCkFilPed := ( substr(cSitVis,5,1) == "2" ) // CheckBox Fisico Pedido
lCkFilNor := ( substr(cSitVis,6,1) == "2" ) // CheckBox Comercial Normal
lCkFilRes := ( substr(cSitVis,7,1) == "2" ) // CheckBox Comercial Reservados
lCkFilBlo := ( substr(cSitVis,8,1) == "2" ) // CheckBox Comercial Bloqueados
//
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 103 , .T. , .F. } ) // ListBox (Filtros)
aAdd( aObjects, { 0 ,  22 , .T. , .F. } ) // Campos (Filtros) / Botao Pesquisar
aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Veiculos
aAdd( aObjects, { 0 ,  19 , .T. , .F. } ) // CheckBox dos Veiculos
aPosP := MsObjSize( aInfo, aObjects )
//
If ( len(aIntOport) == 1 ) .and. ( len(aIntOport[1]) > 6 ) .and. !Empty(aIntOport[1,7]) // Filtrar os Opcionais do Veiculo selecionado
	cOpcVei := aIntOport[1,7]
EndIf
//
FS_LEVANTA("FIL",.f.)	// Levanta Filiais
FS_ESTVEI(.f.,aIntOport) // Levanta Marcas / Cores / Grupos de Modelo / Levanta Modelos

DEFINE MSDIALOG oConsVeic FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+IIf(lAtend," <F7>","")) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
oConsVeic:lEscClose := .F.

nTam := ( aPosP[2,4] / 4 ) // 4 colunas

nLinha := 0
If lAtend // Consulta chamada pelo Atendimento de Veiculos VEIXA018
	@ aPosP[1,1]-003,aPosP[1,2]+(nTam*0) TO aPosP[1,1]+017,(nTam*1) LABEL (" "+STR0033+" ") OF oConsVeic PIXEL // Chassi
	@ aPosP[1,1]+004,(nTam*0)+006 MSGET oChassi VAR cChassi PICTURE "@!" F3 "VV1" SIZE (nTam*1)-006,08 VALID IIf(FS_PESQCHASSI(cNumAte),( ni := 1 , nOpcao := 1 , oConsVeic:End() ),.t.) OF oConsVeic PIXEL COLOR CLR_BLUE HASBUTTON
	nLinha := 21
EndIf

// ESTADO DO VEICULO //
@ aPosP[1,1]-001+nLinha,aPosP[1,2]+(nTam*0) TO aPosP[1,1]+012+nLinha,(nTam*1) LABEL "" OF oConsVeic PIXEL
@ aPosP[1,1]+002+nLinha,aPosP[1,2]+(nTam*0)+005 SAY STR0010 SIZE 60,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Estado do Veiculo
@ aPosP[1,1]+000+nLinha,aPosP[1,2]+(nTam*0)+055 MSCOMBOBOX oEstVei VAR cEstVei SIZE (nTam*1)-(55+aPosP[1,2]),08 COLOR CLR_BLACK ITEMS aEstVei OF oConsVeic ON CHANGE FS_ESTVEI(.t.) PIXEL COLOR CLR_BLUE WHEN lEstVei

// MARCA //
@ aPosP[1,1]+012+nLinha,aPosP[1,2]+(nTam*0) TO aPosP[2,1]-003,(nTam*1) LABEL STR0011 OF oConsVeic PIXEL // Marca
oLbMar := MsBrGetDBase():new( aPosP[1,1]+019+nLinha , aPosP[1,2]+(nTam*0)+1 , nTam-5 , aPosP[1,3]-(aPosP[1,1]+20+nLinha) ,,,, oConsVeic ,,,,, { || FS_TIK("MAR",oLbMar:nAt) } ,,,,,,, .F. , "" , .T. ,, .F. ,,, )
oLbMar:bCustomEditCol := { | nCol, cEdit, nKey, oSelf, oMother | FS_POSLBX(1,nCol,nKey) }
oLbMar:setArray( aMar )
oLbMar:addColumn( TCColumn():New( ""                        , { || IIf(aMar[oLbMar:nAt,1],oOkTik,oNoTik) }                 ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // selecionado
oLbMar:addColumn( TCColumn():new( STR0011                   , { || aMar[oLbMar:nAt,2] }                                    ,,,, "LEFT" , 20 ,.F.,.F.,,,,.F.,) )
oLbMar:addColumn( TCColumn():new( STR0012                   , { || aMar[oLbMar:nAt,3] }                                    ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbMar:bGotFocus := { || aPesq[1] := "" }
oLbMar:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMar := !lMar , FS_TIK("MAR",0) ) , FS_ORDVET(nCol,1) ) , }

// GRUPO DO MODELO //
@ aPosP[1,1]-003,aPosP[1,2]+(nTam*1) TO aPosP[2,1]-003,(nTam*2) LABEL STR0013 OF oConsVeic PIXEL // Grupo do Modelo
oLbGru := MsBrGetDBase():new( aPosP[1,1]+004 , aPosP[1,2]+(nTam*1)+1 , nTam-5 , aPosP[1,3]-(aPosP[1,1]+05) ,,,, oConsVeic ,,,,, { || FS_TIK("GRU",oLbGru:nAt) } ,,,,,,, .F. , "" , .T. ,, .F. ,,, )
oLbGru:bCustomEditCol := { | nCol, cEdit, nKey, oSelf, oMother | FS_POSLBX(2,nCol,nKey) }
oLbGru:setArray( aGru )
oLbGru:addColumn( TCColumn():New( ""                        , { || IIf(aGru[oLbGru:nAt,1],oOkTik,oNoTik) }                 ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // selecionado
oLbGru:addColumn( TCColumn():new( STR0011                   , { || aGru[oLbGru:nAt,2] }                                    ,,,, "LEFT" , 20 ,.F.,.F.,,,,.F.,) )
oLbGru:addColumn( TCColumn():new( STR0012                   , { || aGru[oLbGru:nAt,4] }                                    ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbGru:bGotFocus := { || aPesq[2] := "" }
oLbGru:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lGru := !lGru , FS_TIK("GRU",0) ) , FS_ORDVET(nCol,2) ) , }

// MODELO //
@ aPosP[1,1]-003,aPosP[1,2]+(nTam*2) TO aPosP[2,1]-003,(nTam*3) LABEL STR0014 OF oConsVeic PIXEL // Modelo
oLbMod := MsBrGetDBase():new( aPosP[1,1]+004 , aPosP[1,2]+(nTam*2)+1 , nTam-5 , aPosP[1,3]-(aPosP[1,1]+05) ,,,, oConsVeic ,,,,, { || FS_TIK("MOD",oLbMod:nAt) } ,,,,,,, .F. , "" , .T. ,, .F. ,,, )
oLbMod:bCustomEditCol := { | nCol, cEdit, nKey, oSelf, oMother | FS_POSLBX(3,nCol,nKey) }
oLbMod:setArray( aMod )
oLbMod:addColumn( TCColumn():New( ""                        , { || IIf(aMod[oLbMod:nAt,1],oOkTik,oNoTik) }                 ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // selecionado
oLbMod:addColumn( TCColumn():new( STR0011                   , { || aMod[oLbMod:nAt,2] }                                    ,,,, "LEFT" , 20 ,.F.,.F.,,,,.F.,) )
oLbMod:addColumn( TCColumn():new( STR0012                   , { || aMod[oLbMod:nAt,5] }                                    ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbMod:bGotFocus := { || aPesq[3] := "" }
oLbMod:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMod := !lMod , FS_TIK("MOD",0) ) , FS_ORDVET(nCol,3) ) , }

// TIPO DE COR //
@ aPosP[1,1]+000,aPosP[1,2]+(nTam*3) TO aPosP[1,1]+013,(nTam*4) LABEL "" OF oConsVeic PIXEL
@ aPosP[1,1]+003,aPosP[1,2]+(nTam*3)+005 SAY STR0015 SIZE 60,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Tipo de Cor
@ aPosP[1,1]+001,aPosP[1,2]+(nTam*3)+040 MSCOMBOBOX oTipCor VAR cTipCor SIZE (nTam*1)-(40+aPosP[1,2]),08 COLOR CLR_BLACK ITEMS aTipCor OF oConsVeic ON CHANGE FS_TIK("COR",-1) PIXEL COLOR CLR_BLUE

// COR //
@ aPosP[1,1]+013,aPosP[1,2]+(nTam*3) TO aPosP[2,1]-003,(nTam*4) LABEL STR0016 OF oConsVeic PIXEL // Cor
oLbCor := MsBrGetDBase():new( aPosP[1,1]+020 , aPosP[1,2]+(nTam*3)+1 , nTam-5 , aPosP[1,3]-(aPosP[1,1]+21) ,,,, oConsVeic ,,,,, { || FS_TIK("COR",oLbCor:nAt) } ,,,,,,, .F. , "" , .T. ,, .F. ,,, )
oLbCor:bCustomEditCol := { | nCol, cEdit, nKey, oSelf, oMother | FS_POSLBX(4,nCol,nKey) }
oLbCor:setArray( aCor )
oLbCor:addColumn( TCColumn():New( ""                        , { || IIf(aCor[oLbCor:nAt,1],oOkTik,oNoTik) }                 ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // selecionado
oLbCor:addColumn( TCColumn():new( STR0011                   , { || aCor[oLbCor:nAt,2] }                                    ,,,, "LEFT" , 20 ,.F.,.F.,,,,.F.,) )
oLbCor:addColumn( TCColumn():new( STR0012                   , { || aCor[oLbCor:nAt,4] }                                    ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbCor:bGotFocus := { || aPesq[4] := "" }
oLbCor:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lCor := !lCor , FS_TIK("COR",0) ) , FS_ORDVET(nCol,4) ) , }


@ aPosP[2,1]-001,aPosP[2,2]+(nTam*0) TO aPosP[3,1]-004,(nTam*4)-40 LABEL "" OF oConsVeic PIXEL


// BOTAO - FILTROS //
@ aPosP[2,1]+002,aPosP[2,2]+003 BUTTON oFiltros PROMPT STR0094 OF oConsVeic SIZE 28,16 PIXEL ACTION FS_TOTFILT() // Filtros


// LOJA //
@ aPosP[2,1]+000,aPosP[2,2]+033 SAY STR0017 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Loja
@ aPosP[2,1]+008,aPosP[2,2]+033 MSCOMBOBOX oFilVV1 VAR cFilVV1 SIZE 55,08 COLOR CLR_BLACK ITEMS aFilVV1 OF oConsVeic ON CHANGE FS_CONSVEIC(1) PIXEL COLOR CLR_BLUE WHEN Empty(cUFFiltro)

// UF //
@ aPosP[2,1]+000,aPosP[2,2]+088 SAY STR0095 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // UF Lojas
@ aPosP[2,1]+008,aPosP[2,2]+088 MSCOMBOBOX oUFFiltro VAR cUFFiltro SIZE 24,08 COLOR CLR_BLACK ITEMS aUFFiltro OF oConsVeic ON CHANGE FS_CONSVEIC(3) PIXEL COLOR CLR_BLUE WHEN Empty(cFilVV1) 

// ANO INICIAL //
@ aPosP[2,1]+000,aPosP[2,2]+112 SAY STR0019 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Ano Inicial
@ aPosP[2,1]+008,aPosP[2,2]+112 MSGET oAnoIni VAR cAnoIni PICTURE "@R 9999" SIZE 27,08 VALID FS_FILTVETOR() OF oConsVeic PIXEL COLOR CLR_BLUE

// ANO FINAL //
@ aPosP[2,1]+000,aPosP[2,2]+139 SAY STR0020 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Ano Final
@ aPosP[2,1]+008,aPosP[2,2]+139 MSGET oAnoFin VAR cAnoFin PICTURE "@R 9999" SIZE 27,08 VALID FS_FILTVETOR() OF oConsVeic PIXEL COLOR CLR_BLUE

// COMBUSTIVEL //
@ aPosP[2,1]+000,aPosP[2,2]+166 SAY STR0021 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Combustivel
@ aPosP[2,1]+008,aPosP[2,2]+166 MSCOMBOBOX oCombus VAR cCombus SIZE 65,08 COLOR CLR_BLACK ITEMS aCombus OF oConsVeic ON CHANGE FS_FILTVETOR() PIXEL COLOR CLR_BLUE

// VALOR INICIAL //
@ aPosP[2,1]+000,aPosP[2,2]+231 SAY STR0022 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Valor Inicial
@ aPosP[2,1]+008,aPosP[2,2]+231 MSGET oVlrIni VAR nVlrIni PICTURE "@E 9,999,999" SIZE 33,08 VALID FS_FILTVETOR() OF oConsVeic PIXEL COLOR CLR_BLUE HASBUTTON

// VALOR FINAL //
@ aPosP[2,1]+000,aPosP[2,2]+269 SAY STR0023 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Valor Final
@ aPosP[2,1]+008,aPosP[2,2]+269 MSGET oVlrFin VAR nVlrFin PICTURE "@E 9,999,999" SIZE 33,08 VALID FS_FILTVETOR() OF oConsVeic PIXEL COLOR CLR_BLUE HASBUTTON

// KM MAXIMA //
@ aPosP[2,1]+000,aPosP[2,2]+308 SAY STR0024 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // KM Maxima
@ aPosP[2,1]+008,aPosP[2,2]+308 MSGET oKMMaxi VAR nKMMaxi PICTURE "@E 999,999,999" SIZE 36,08 VALID FS_FILTVETOR() OF oConsVeic PIXEL COLOR CLR_BLUE HASBUTTON

// FOTO //
@ aPosP[2,1]+000,aPosP[2,2]+344 SAY STR0004 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Ft-Vd
@ aPosP[2,1]+008,aPosP[2,2]+344 MSCOMBOBOX oFoto VAR cFoto SIZE 23,08 COLOR CLR_BLACK ITEMS aFoto OF oConsVeic ON CHANGE FS_FILTVETOR() PIXEL COLOR CLR_BLUE

// PROMOCAO //
@ aPosP[2,1]+000,aPosP[2,2]+364 SAY STR0072 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Promocao
@ aPosP[2,1]+008,aPosP[2,2]+367 MSCOMBOBOX oPromoc VAR cPromoc SIZE 23,08 COLOR CLR_BLACK ITEMS aPromoc OF oConsVeic ON CHANGE FS_FILTVETOR() PIXEL COLOR CLR_BLUE WHEN ( len(aPromoc) > 1 )

nSobrou := (nTam*4)-435

// OPCIONAIS //
@ aPosP[2,1]+000,aPosP[2,2]+390 SAY STR0025 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Opcionais
@ aPosP[2,1]+008,aPosP[2,2]+390 MSGET oOpcVei VAR cOpcVei PICTURE VV1->(X3PICTURE("VV1_OPCFAB")) SIZE nSobrou/2 , 08 VALID FS_FILTVETOR() OF oConsVeic PIXEL COLOR CLR_BLUE

// CONFIGURACAO 'BUSCA' //
@ aPosP[2,1]+000,aPosP[2,2]+390+nSobrou/2 SAY STR0088 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Configuracao
@ aPosP[2,1]+008,aPosP[2,2]+390+nSobrou/2 MSGET oCfgVei VAR cCfgVei PICTURE "@!" SIZE nSobrou/2 , 08 VALID FS_FILTVETOR() OF oConsVeic PIXEL COLOR CLR_BLUE

// ATUALIZAR //
@ aPosP[2,1]+000,(nTam*4)-037 BUTTON oAtualizar PROMPT STR0026 OF oConsVeic SIZE 35,08 PIXEL ACTION ( lBotAtu := .t. , FS_CONSVEIC(2) )
@ aPosP[2,1]+010,(nTam*4)-038 CHECKBOX oAutoma VAR lAutoma PROMPT "" OF oConsVeic SIZE 10,10 PIXEL
@ aPosP[2,1]+008,(nTam*4)-029 SAY STR0027 SIZE 35,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Atualizacao
@ aPosP[2,1]+015,(nTam*4)-029 SAY STR0071 SIZE 35,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Automatica

// VEICULOS //
oLbVeic := TWBrowse():New(aPosP[3,1]-001,aPosP[3,2],(aPosP[3,4]-2),(aPosP[3,3]-aPosP[3,1]+3),,,,oConsVeic,,,,,{ || IIf(lAtend,IIf(!aVeicVer[oLbVeic:nAt,26],IIf(!Empty(aVeicVer[oLbVeic:nAt,24]).and.FS_VALVEI(cNumAte,nQtdVei),(aVeicVer[oLbVeic:nAt,26]:=.t.,IIf(nAVEIMAX==1,(nOpcao:=1,oConsVeic:End()),.t.)),.t.),aVeicVer[oLbVeic:nAt,26]:=.f.),.t.) },,,,,,,.F.,,.T.,,.F.,,,)
If lAtend
	oLbVeic:addColumn( TCColumn():New( "", { || IIf(aVeicVer[oLbVeic:nAt,26],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
EndIf
oLbVeic:addColumn( TCColumn():New( "1", { || IIf(aVeicVer[oLbVeic:nAt,01]=="N",oBran,IIf(aVeicVer[oLbVeic:nAt,01]=="T",oLara,IIf(aVeicVer[oLbVeic:nAt,01]=="E",oPink,IIf(aVeicVer[oLbVeic:nAt,01]=="S",oCinz,IIf(aVeicVer[oLbVeic:nAt,01]=="C",oAzul,IIf(aVeicVer[oLbVeic:nAt,01]=="P",oVerm,oBran)))))) } ,,,,"LEFT" ,08,.T.,.F.,,,,.F.,) ) // Cor 1
oLbVeic:addColumn( TCColumn():New( "2", { || IIf(aVeicVer[oLbVeic:nAt,02]=="R",oAmar,IIf(aVeicVer[oLbVeic:nAt,02]=="B",oPret,oBran)) } ,,,,"LEFT" ,08,.T.,.F.,,,,.F.,) ) // Cor 2
oLbVeic:addColumn( TCColumn():New( "3", { || IIF(FS_TemConfig(aVeicVer[oLbVeic:nAt]), oOkCon, oNoCon) } ,,,,"LEFT" ,08,.T.,.F.,,,,.F.,) ) // Config
aColunas := VXC001F12(.f.,cNumAte,nQtdVei)
For ni := 1 to len(aColunas)
	oLbVeic:addColumn( TCColumn():New( aColunas[ni,2] , aColunas[ni,3] ,,,, aColunas[ni,4] , aColunas[ni,5] ,.F.,.F.,,,,.F.,) )
Next
oLbVeic:nAT := 1
oLbVeic:SetArray(aVeicVer)

//////////////////////////////////////////
// Qtde de colunas BOTOES 1 - Fisico    //
//////////////////////////////////////////
nCol1 := 0
For ni := 1 to 5
	If ( substr(cSitVis,ni,1) <> "0" )
		nCol1++
		If ni == 3 // Mais uma coluna para Remessa (Entrada e Saida)
			nCol1++
		EndIf
	EndIf
Next
If nCol1 == 0
	nCol1 := 1
EndIf
//////////////////////////////////////////
// Qtde de colunas BOTOES 2 - Comercial //
//////////////////////////////////////////
nCol2 := 0
For ni := 6 to 8
	If ( substr(cSitVis,ni,1) <> "0" )
		nCol2++
	EndIf
Next
If nCol2 == 0
	nCol2 := 1
EndIf
//
nTam := ( aPosP[4,4] / ( nCol1 + nCol2 ) )
nColuna := 0
//
@ aPosP[4,1]-000,(nTam*0.0)+004 TO aPosP[4,1]+20,(nTam*nCol1) LABEL (" 1 - "+STR0038+" ") OF oConsVeic PIXEL // Fisica
If ( substr(cSitVis,1,1) <> "0" ) // CheckBox Fisico Estoque
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilEst VAR lCkFilEst PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("EST") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxBran RESOURCE "BR_BRANCO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0039 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Estoque
	nColuna++
EndIf
If ( substr(cSitVis,2,1) <> "0" ) // CheckBox Fisico Em Transito
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilTra VAR lCkFilTra PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("TRA") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxLara RESOURCE "BR_LARANJA" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0040 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Em Transito
	nColuna++
EndIf
If ( substr(cSitVis,3,1) <> "0" ) // CheckBox Fisico Remessa
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilRem VAR lCkFilRem PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("REM") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxPink RESOURCE "BR_PINK" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0100 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Remessa Entrada
	nColuna++
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilRMS VAR lCkFilRMS PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("RMS") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxCinz RESOURCE "BR_CINZA" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0101 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Remessa Saida
	nColuna++
EndIf
If ( substr(cSitVis,4,1) <> "0" ) // CheckBox Fisico Consignado
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilCon VAR lCkFilCon PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("CON") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxAzul RESOURCE "BR_AZUL" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0042 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Consignado
	nColuna++
EndIf
If ( substr(cSitVis,5,1) <> "0" ) // CheckBox Fisico Pedido
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilPed VAR lCkFilPed PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("PED") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0105 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Pedido Fabrica
	nColuna++
EndIf	
//
@ aPosP[4,1]-000,(nTam*nCol1)+004 TO aPosP[4,1]+20,(nTam*(nCol1+nCol2)) LABEL (" 2 - "+STR0043+" ") OF oConsVeic PIXEL // Comercial
If ( substr(cSitVis,6,1) <> "0" ) // CheckBox Comercial Normal
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilNor VAR lCkFilNor PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("NOR") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxBrac RESOURCE "BR_BRANCO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0044 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Normal
	nColuna++
EndIf
If ( substr(cSitVis,7,1) <> "0" ) // CheckBox Comercial Reservados
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilRes VAR lCkFilRes PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("RES") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxAmar RESOURCE "BR_AMARELO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0045 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Reservados
	nColuna++
EndIf
If ( substr(cSitVis,8,1) <> "0" ) // CheckBox Comercial Bloqueados
	@ aPosP[4,1]+009,(nTam*nColuna)+010 CHECKBOX oCkFilBlo VAR lCkFilBlo PROMPT "" OF oConsVeic ON CLICK FS_CKFiltro("BLO") SIZE 08,08 PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+019 BITMAP oxPret RESOURCE "BR_PRETO" OF oConsVeic NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosP[4,1]+009,(nTam*nColuna)+028 SAY STR0046 SIZE 50,8 OF oConsVeic PIXEL COLOR CLR_BLUE // Bloqueados
	nColuna++
EndIf 
//
If len(aIntOport) > 0 // Caso haja interesse do Cliente 
	FS_CONSVEIC(2)
EndIf
//
ACTIVATE MSDIALOG oConsVeic ON INIT EnchoiceBar(oConsVeic,{ || IIf(FS_VALSELEC(),( nOpcao := 1 , oConsVeic:End() ),.t.) }, { || oConsVeic:End() },,aNewBot)

If lRetorno .and. lAtend .and. nOpcao > 0 // Tem retorno e consulta chamada pelo Atendimento de Veiculos VEIXA018
	If nOpcao == 1 // Clique no OK da Janela ou DuploClique no ListBox de Veiculos ( Existe VV1 )
		aRetFiltro := {}
		For ni := 1 to len(aVeicVer)
			If aVeicVer[ni,26] // Tik OK -> veiculo selecionado

				FS_AddRetFiltro(@aRetFiltro)
				
				VV1->(DbSetOrder(1))
				VV1->(DbSeek(xFilial("VV1")+aVeicVer[ni,24])) // Chassi Interno
				FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
				aRetFiltro[len(aRetFiltro),01] := VV1->VV1_CHAINT // Chaint
				aRetFiltro[len(aRetFiltro),02] := VV1->VV1_ESTVEI // Estado do Veiculo (Novo/Usado)
				aRetFiltro[len(aRetFiltro),03] := VV1->VV1_CODMAR // Marca
				aRetFiltro[len(aRetFiltro),04] := VV2->VV2_GRUMOD // Grupo do Modelo
				aRetFiltro[len(aRetFiltro),05] := VV1->VV1_MODVEI // Modelo
				aRetFiltro[len(aRetFiltro),06] := VV1->VV1_CORVEI // Cor
				aRetFiltro[len(aRetFiltro),07] := "" // Codigo Progresso
				aRetFiltro[len(aRetFiltro),08] := "1" // Tipo (1-Normal)
				aRetFiltro[len(aRetFiltro),09] := aVeicVer[ni,09] // Valor do Veiculo
				aRetFiltro[len(aRetFiltro),10] := VV2->VV2_SEGMOD // Segmento do Veiculo
			EndIf
		Next
	Else // Progresso de Veiculos ( VJ1 )
		If len(aVJ1) > 0
			VJ1->(DbSetOrder(1))
			If VJ1->(DbSeek(xFilial("VJ1")+aVJ1[1]+aVJ1[2]))
				aRetFiltro := {}

				FS_AddRetFiltro(@aRetFiltro)

				VV2->(DbSetOrder(1))
				VV2->(DbSeek(xFilial("VV2")+VJ1->VJ1_CODMAR+VJ1->VJ1_MODVEI))
				aRetFiltro[len(aRetFiltro),01] := ""  // Chaint
				aRetFiltro[len(aRetFiltro),02] := "0" // Estado do Veiculo (0=Novo/1=Usado)
				aRetFiltro[len(aRetFiltro),03] := VJ1->VJ1_CODMAR // Marca
				aRetFiltro[len(aRetFiltro),04] := VV2->VV2_GRUMOD // Grupo do Modelo
				aRetFiltro[len(aRetFiltro),05] := VJ1->VJ1_MODVEI // Modelo
				aRetFiltro[len(aRetFiltro),06] := STRZERO(VJ1->VJ1_COREXT,2) // Cor
				aRetFiltro[len(aRetFiltro),07] := VJ1->VJ1_CODPED // Codigo Progresso
				aRetFiltro[len(aRetFiltro),08] := "3" // Tipo (3=VendaFutura)
				// Valor do Veiculo -> FGX_VLRSUGV retorna o Valor Sugerido para Venda do Veiculo ( VVP (vlr tabela) + VVC (vlr cor adicional) )
				aRetFiltro[len(aRetFiltro),09] := FGX_VLRSUGV( "" , VJ1->VJ1_CODMAR , VJ1->VJ1_MODVEI , VV2->VV2_SEGMOD , STRZERO(VJ1->VJ1_COREXT,2) , .t. , cCdCliAt , cLjCliAt )
				aRetFiltro[len(aRetFiltro),10] := VV2->VV2_SEGMOD // Segmento do Veiculo
			EndIf
		EndIf
	EndIf
EndIf

FS_HAB_FX(.f.,{},"",0) // Desabilita Botos <F4> <F5> <F6> <F7> <F8> <F9> <F11> <F12>

DbSelectArea("VV9")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALSELEC³ Autor ³ Andre Luis Almeida   ³ Data ³ 06/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se o usuario selecionou algum Veiculo               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALSELEC()
Local lRet := .f.
Local ni   := 0
If lAtend // Consulta chamada pelo Atendimento de Veiculos VEIXA018
	For ni := 1 to len(aVeicVer)
		If aVeicVer[ni,26] // Tik OK -> selecionado
			lRet := .t.
			Exit
		EndIf
	Next
	If !lRet
		MsgStop(STR0055,STR0050) // Veiculo não selecionado! / Atencao
	EndIf
	If lRet .and. ExistBlock("VXC01VAL" )
		lRet := ExecBlock("VXC01VAL", .f., .f.)
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALVEI ³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Veiculo selecionado no botao OK da janela           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumAte = Numero do Atendimento                            ³±±
±±³          ³ nQtdVei = Qtdade de Veiculos que ja estao no Atendimento   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALVEI(cNumAte,nQtdVei)
Local lRet := .f.
Local ni   := 0
Local nQtd := 1
If lAtend // Consulta chamada pelo Atendimento de Veiculos VEIXA018
	For ni := 1 to len(aVeicVer)
		If aVeicVer[ni,26] // Veiculo selecionado no ListBox
			nQtd++
		EndIf
	Next
	// Verificar as Qtdades: "MAXIMA permitida por Atendimento" com "Veiculos selecionados no ListBox" + "Veiculos que ja estao no Atendimento"
	If nAVEIMAX < ( nQtd + nQtdVei )
		MsgStop(STR0073,STR0050) // Impossivel selecionar o Veiculo. A quantidade máxima permitida por Atendimento foi atingida! / Atencao
	Else
		If !Empty(aVeicVer[oLbVeic:nAt,24]) // Verifica se CHASSI nao esta vazio
			If VEIXX012(1,,aVeicVer[oLbVeic:nAt,24],,cNumAte) // Validacoes do Chassi
				lRet    := .t.
			EndIf
		Else
			MsgStop(STR0055,STR0050) // Veiculo não selecionado! / Atencao
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SIMVDFUT³ Autor ³ Andre Luis Almeida  ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta/Escolhe Modelos/Cores para utilizar na Simulacao   ³±±
±±³          ³ ou Venda Futura                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SIMVDFUT(aRetFiltro)
Local cQuery    := ""
Local cQAlSQL   := "ALIASSQL"
Local cQAlAux   := "ALIASAUX"
Local cNamVV2   := RetSqlName("VV2")
Local cNamVVC   := RetSqlName("VVC")
Local cFilVV2   := xFilial("VV2")
Local cFilVVC   := xFilial("VVC")
Local nOpcSFV   := 0  // Opcao Radio: Simulacao / Venda Futura
Local ni        := 0
Local nj        := 0
Local nContVVA  := 0
Local lOk       := .f.
Local lRet      := .f.
Local nVlTabela := 0 // Valor de tabela para fat. dir. / venda dir. / simulacao
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
aVetMod := {}
For ni := 1 to len(aMod)
	If aMod[ni,1] // Levanta Modelos
		cQuery := "SELECT VV2.VV2_CODMAR , VV2.VV2_SEGMOD , VV2.VV2_GRUMOD , VV2.VV2_MODVEI , VV2.VV2_DESMOD"
		cQuery += "  FROM "+cNamVV2+" VV2"
		cQuery += " WHERE VV2.VV2_FILIAL='"+cFilVV2+"'"
		cQuery += "   AND VV2.VV2_CODMAR='"+aMod[ni,2]+"'"
		cQuery += "   AND VV2.VV2_MODVEI IN ("+aMod[ni,4]+")"
		cQuery += "   AND VV2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			For nj := 1 to len(aCor) // Levanta Cores
				If aCor[nj,1] .and. aCor[nj,2] == aMod[ni,2]
					cQuery := "SELECT VVC_CORVEI , VVC_DESCRI"
					cQuery += "  FROM "+cNamVVC
					cQuery += " WHERE VVC_FILIAL='"+cFilVVC+"'"
					cQuery += "   AND VVC_CODMAR='"+aCor[nj,2]+"'"
					cQuery += "   AND VVC_CORVEI IN ("+aCor[nj,3]+")"
					cQuery += "   AND D_E_L_E_T_=' ' "
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
					While !( cQAlAux )->( Eof() )

						aAdd(aVetMod,{.f.,; // 1
							( cQAlSQL )->( VV2_CODMAR ),; // 2
							( cQAlSQL )->( VV2_GRUMOD ),; // 3
							( cQAlSQL )->( VV2_MODVEI ),; // 4
							( cQAlSQL )->( VV2_DESMOD ),; // 5
							( cQAlAux )->( VVC_CORVEI ),; // 6
							( cQAlAux )->( VVC_DESCRI ),; // 7
							( cQAlSQL )->( VV2_SEGMOD ),; // 8
							0}) // 9

						( cQAlAux )->( DbSkip() )
					EndDo
					( cQAlAux )->( DbCloseArea() )
				EndIf
			Next
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
	EndIf
Next
If len(aVetMod) > 0 // Escolher o Tipo do Atendimento, Modelo/Cor desejado
	lRet :=  .t.
	If len(aVetMod) == 1
		aVetMod[1,1] := .t.
	EndIf
	aObjects := {}
	For ni := 1 to Len(aSizeHalf)
		aSizeHalf[ni] := INT(aSizeHalf[ni] * 0.8)
	Next
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	aAdd( aObjects, { 0 ,  22 , .T. , .F. } ) // Selecione o Tipo de Atendimento
	aAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // ListBox dos Modelos/Cores do Veiculo
	aPos := MsObjSize( aInfo, aObjects )
	nOpcSFV := 0 // 1=Simulacao / 2=Venda Futura
	While .t.
		ni := 0

		DEFINE MSDIALOG oSelModVei FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0047 OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Selecione o Tipo de Atendimento e Modelo/Cor do Veiculo desejado
		oSelModVei:lEscClose := .F.
		
		@ aPos[1,1]+005,aPos[1,2]+003 RADIO oTpAtend VAR nOpcSFV 3D SIZE 100,20 PROMPT STR0009,STR0049 OF oSelModVei PIXEL ON CHANGE VXC01TIKVF(0) // Simulacao / Venda Futura
		
		@ aPos[2,1],aPos[2,2] LISTBOX oLbModVei FIELDS HEADER "",STR0011,STR0014,STR0012,STR0016,STR0012,STR0102 COLSIZES 10,20,90,140,50,80,25 SIZE aPos[2,4],aPos[2,3]-aPos[2,1] OF oSelModVei PIXEL ON DBLCLICK VXC01TIKVF(nOpcSFV)
		oLbModVei:SetArray(aVetMod)
		oLbModVei:bLine := { || {	IIf(aVetMod[oLbModVei:nAt,1],oOkTik,oNoTik) ,;
									aVetMod[oLbModVei:nAt,2] ,;
									Alltrim(aVetMod[oLbModVei:nAt,3])+" - "+aVetMod[oLbModVei:nAt,4] ,;
									aVetMod[oLbModVei:nAt,5] ,;
									aVetMod[oLbModVei:nAt,6] ,;
									aVetMod[oLbModVei:nAt,7] ,;
									FG_AlinVlrs(Transform(aVetMod[oLbModVei:nAt,9],"@EZ 9999")) }}
		
		ACTIVATE MSDIALOG oSelModVei CENTER ON INIT EnchoiceBar(oSelModVei,{ ||  ni := 1 , oSelModVei:End() }, { || ni := 2 , oSelModVei:End() },,)
		If ni == 1
			lOk := .t.
			If lAtend // Consulta chamada pelo Atendimento de Veiculos VEIXA018
				nContVVA := 0
				If !Empty(M->VV0_NUMTRA)
					nContVVA := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName('VVA')+" WHERE VVA_FILIAL='"+xFilial('VVA')+"' AND VVA_NUMTRA='"+M->VV0_NUMTRA+"' AND D_E_L_E_T_=' '")
				EndIf
				For ni := 1 to len(aVetMod) // Verificar se existe algum modelo/cor selecionado
					If aVetMod[ni,1]
						nContVVA += aVetMod[ni,9]
					EndIf
				Next
				// Verificar as Qtdades: "MAXIMA permitida por Atendimento" com "Veiculos Informados na Venda Futura" + "Veiculos que ja estao no Atendimento"
				If nAVEIMAX < nContVVA // Qtde MAXIMA permitida
					MsgStop(STR0073,STR0050) // Impossivel selecionar o Veiculo. A quantidade máxima permitida por Atendimento foi atingida! / Atencao
					lOk := .f.
				EndIf
			EndIf
			If lOk
				If nOpcSFV == 0 // Verificar se foi escolhido o Tipo de Atendimento
					MsgStop(STR0051,STR0050) // Informe o Tipo de Atendimento. / Atencao
				Else
					lOk := .f.
					For ni := 1 to len(aVetMod) // Verificar se existe algum modelo/cor selecionado
						If aVetMod[ni,1]
							lOk := .t.
							Exit
						EndIf
					Next
					If !lOk
						MsgStop(STR0052,STR0050) // Informe o Modelo/Cor desejados. / Atencao
					Else
						aRetFiltro := {}
						For ni := 1 to len(aVetMod) // Verificar se existe algum modelo/cor selecionado
							If aVetMod[ni,1]

								VV2->(DbSetOrder(1))
								VV2->(MsSeek(xFilial("VV2") + aVetMod[ni,2] + aVetMod[ni,4] + aVetMod[ni,8] ))

								nVlTabela := FGX_VLRSUGV( "" , aVetMod[ni,2] , aVetMod[ni,4] , VV2->VV2_SEGMOD , aVetMod[ni,6] , .t. , cCdCliAt , cLjCliAt )

								For nj := 1 to aVetMod[ni,9]
									FS_AddRetFiltro(@aRetFiltro)
									
									aRetFiltro[len(aRetFiltro),01] := "" // CHAINT
									aRetFiltro[len(aRetFiltro),02] := "0" // Estado do Veiculo (0=Novo/1=Usado)
									aRetFiltro[len(aRetFiltro),03] := aVetMod[ni,2] // Marca
									aRetFiltro[len(aRetFiltro),04] := aVetMod[ni,3] // Grupo do Modelo
									aRetFiltro[len(aRetFiltro),05] := aVetMod[ni,4] // Modelo
									aRetFiltro[len(aRetFiltro),06] := aVetMod[ni,6] // Cor
									aRetFiltro[len(aRetFiltro),07] := "" // Codigo Progresso
									aRetFiltro[len(aRetFiltro),08] := IIf(nOpcSFV==2,"3","4") // 3=Venda Futura / 4=Simulacao
									aRetFiltro[len(aRetFiltro),09] := nVlTabela
									aRetFiltro[len(aRetFiltro),10] := aVetMod[ni,8] // Segmento do Modelo
								Next
							EndIf
						Next
						lRet := .t.
						Exit
					EndIf
				EndIf
			EndIf
		ElseIf ni == 2
			lRet := .f.
			Exit
		EndIf
	EndDo
Else
	MsgStop(STR0008+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0056,STR0050) // Simulacao / Venda Futura / Marca/Modelo/Cor nao selecionados! / Atencao
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXC01TIKVF³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/05/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tik dos Modelos na Venda Futara ou Simulacao               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXC01TIKVF(nOpcSFV)
Local aRet      := {}
Local aParamBox := {}
Do Case
	Case nOpcSFV <= 1
		aEval( aVetMod , {|x| x[1] := .f. } )
		aEval( aVetMod , {|x| x[9] :=  0  } )
		If nOpcSFV == 1 // Simulacao
			aVetMod[oLbModVei:nAt,1] := .t.
			aVetMod[oLbModVei:nAt,9] := 1
		EndIf
	Case nOpcSFV == 2 // Venda Futura
		aVetMod[oLbModVei:nAt,9] := 0
		If !aVetMod[oLbModVei:nAt,1]
			aAdd(aParamBox,{1,STR0102,1,"@E 9999","MV_PAR01>=1","",".T.",30,.t.}) // Quantidade
			If ParamBox(aParamBox,STR0049,@aRet,,,,,,,,.f.) // Venda Futura
				aVetMod[oLbModVei:nAt,9] := aRet[1]
				aVetMod[oLbModVei:nAt,1] := .t.
			EndIf
		Else
			aVetMod[oLbModVei:nAt,1] := .f.
		EndIf
EndCase
oLbModVei:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_HAB_FX ³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita as teclas F4 / F5 / F6 / F8 / F9 / F12            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_HAB_FX(lHabil,aRetFiltro,cNumAte,nQtdVei)
SetKey(VK_F4,Nil)
SetKey(VK_F5,Nil)
SetKey(VK_F6,Nil)
SetKey(VK_F7,Nil)
SetKey(VK_F8,Nil)
SetKey(VK_F9,Nil)
SetKey(VK_F10,Nil)
SetKey(VK_F11,Nil)
SetKey(VK_F12,Nil)
If lHabil
	//
	SetKey(VK_F4,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),VEIXC003(aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })			// Foto do Veiculo ( F4 )
	SetKey(VK_F5,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,14]),VEIVC140(aVeicVer[oLbVeic:nAt,14], aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })			// Rastreamento do Veiculo ( F5 )
	SetKey(VK_F6,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),VX002VV1(aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })			// Visualiza Cadastro do Veiculo VV1 ( F6 )
	If lAtend // Consulta chamada pelo Atendimento de Veiculos VEIXA018
		////////////////////////////////////////////////////////////
		// Consulta chamada pelo Atendimento de Veiculos VEIXA018 //
		////////////////////////////////////////////////////////////
		SetKey(VK_F8,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(FS_PROGRES(lRetVJ1,@aVJ1),(nOpcao:=3,oConsVeic:End()),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })					// Progresso de Veiculos ( F8 )
		SetKey(VK_F9,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(FS_SIMVDFUT(@aRetFiltro),(nOpcao:=2,oConsVeic:End()),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })					// Simulacao / Venda Futura ( F9 )
	Else
		////////////////////////////////////////////////////////////
		// Consulta chamada diretamente pelo MENU                 //
		////////////////////////////////////////////////////////////
		SetKey(VK_F7,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),VEIXX012(1,,aVeicVer[oLbVeic:nAt,24],,"_",,.t.),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })		// Visualiza Informações de Atendimento (VEIXX012)
		SetKey(VK_F8,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(FS_PROGRES(lRetVJ1,@aVJ1),.t.,.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })											// Progresso de Veiculos ( F8 )
		SetKey(VK_F9,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , IIf(!Empty(aVeicVer[oLbVeic:nAt,24]),FGX_VEISIM(aVeicVer[oLbVeic:nAt,24]),.t.) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })	// Simulacao ( F9 )
	EndIf
	if VQ0->( ColumnPos('VQ0_CONFIG') ) > 0 .AND. VV1->( ColumnPos('VV1_CFGBAS') ) > 0 // cfg bas and cfg avancada
		SetKey(VK_F10, {|| FS_MOSTRACFG() })
	EndIf
	SetKey(VK_F11,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , VXC001TOT() , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })																			// Impressao ( F11 )
	SetKey(VK_F12,{|| FS_HAB_FX(.f.,@aRetFiltro,cNumAte,nQtdVei) , VXC001F12(.t.,cNumAte,nQtdVei) , FS_HAB_FX(.t.,@aRetFiltro,cNumAte,nQtdVei) })														// Parametros/Colunas ( F12 )
	//
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ESTVEI ³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ NOVO/USADO - Monta ListBox's Marca/Cor/Grupo Modelo/Modelo ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ESTVEI(lRefresh,aIntOport)
Default aIntOport := {}
lMar := .f. // Marca Total
lGru := .f. // Grupo do Modelo Total
lMod := .f. // Modelo Total
lCor := .f. // Cor Total
FS_LEVANTA("MAR",lRefresh,aIntOport) // Levanta Marcas
FS_LEVANTA("COR",lRefresh,aIntOport) // Levanta Cores
FS_LEVANTA("GRU",lRefresh,aIntOport) // Levanta Grupos de Modelo
FS_LEVANTA("MOD",lRefresh,aIntOport) // Levanta Modelos
If lRefresh
	FS_CONSVEIC(2)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LEVANTA³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta FILIAL / MARCA / GRUPO MODELO / MODELO / COR / ... ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANTA(cTipo,lRefresh,aIntOport)
Local nPos        := 0
Local nPos2       := 0
Local cQuery      := ""
Local cQAlSQL     := "ALIASSQL"
Local lTikCor     := .f.
Local lAux        := .f.
Local cAux        := ""
Local cAux2       := ""
Local nRecSM0     := SM0->(RecNo())
Local cSlvFilAnt  := cFilAnt
Local cUF         := ""
Local aFilAtu     := {}
Default aIntOport := {}
Do Case
	Case cTipo == "FIL" // Levanta Filiais
		If ExistBlock("VXC01FIL") // PE utilizado para criar o Vetor (aFilVV1) com as possiveis FILIAIS da Consulta F7
			ExecBlock("VXC01FIL",.F.,.F.)
		Else
			aFilAtu := FWArrFilAtu()
			aFilVV1 := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
			aAdd( aFilVV1 , "" )
			Asort(aFilVV1)
		EndIf
		aAdd(aUFTot,{"  ","X",.t.}) // Todas as UF 
		For nPos := 1 to len(aFilVV1)
			If !Empty(aFilVV1[nPos])
				cFilAnt := aFilVV1[nPos]
				aFilAtu := FWArrFilAtu()
				If SM0_RECNO > 0 .and. aFilAtu[SM0_RECNO] > 0
					DbSelectArea("SM0")
					DbGoTo(aFilAtu[SM0_RECNO])
				EndIf
				cUF := IIf(!Empty(SM0->M0_ESTCOB),SM0->M0_ESTCOB,SM0->M0_ESTENT) // Pegar UF da Filial de Entrada do Veiculo ( VV1_FILENT )
				If !Empty(cUF)
					nPos2 := aScan(aUFTot, {|x| x[1] == cUF })
					If nPos2 <= 0
						aAdd(aUFTot,{cUF,aFilVV1[nPos],.f.}) // UF Individual
					Else
						aUFTot[nPos2,2] += "/"+aFilVV1[nPos]
					EndIf
				EndIf
			EndIf
		Next
		Asort(aUFTot,,,{|x,y| x[1] < y[1] })
		For nPos := 1 to len(aUFTot)
			aAdd(aUFFiltro,aUFTot[nPos,1])
		Next
		DbSelectArea("SM0")
		DbGoTo(nRecSM0)
		cFilAnt := cSlvFilAnt
		
	Case cTipo == "MAR" // Levanta Marcas
		aMar := {}
		cQuery := "SELECT VE1.VE1_CODMAR , VE1.VE1_DESMAR FROM "+RetSqlName("VE1")+" VE1 "
		cquery += "WHERE VE1.VE1_FILIAL='"+xFilial("VE1")+"' AND VE1.D_E_L_E_T_=' ' ORDER BY VE1.VE1_CODMAR "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
		While !( cQAlSQL )->( Eof() )
			lAux := lMar
			If len(aIntOport) > 0 .and. !lAux
				If aScan(aIntOport, {|x| x[1] == ( cQAlSQL )->( VE1_CODMAR ) }) > 0 // Verifica se tem interesse na Marca (Oportunidade de Negocios)
					lAux := .t.
				EndIf
			EndIf
			If left(cEstVei,1) == "0" // Novos
				If Empty(VAI->VAI_MARNOV) .or. ( ( cQAlSQL )->( VE1_CODMAR ) $ VAI->VAI_MARNOV )
					aAdd(aMar,{lAux,( cQAlSQL )->( VE1_CODMAR ),( cQAlSQL )->( VE1_DESMAR )})
				EndIf
			Else //left(cEstVei,1) == "1" // Usados
				If Empty(VAI->VAI_MARUSA) .or. ( ( cQAlSQL )->( VE1_CODMAR ) $ VAI->VAI_MARUSA )
					aAdd(aMar,{lAux,( cQAlSQL )->( VE1_CODMAR ),( cQAlSQL )->( VE1_DESMAR )})
				EndIf
			EndIf
			( cQAlSQL )->( DbSkip() )
		EndDo
		( cQAlSQL )->( DbCloseArea() )
		If len(aMar) == 1
			lMar := .t.
			aMar[1,1] := .t.
		EndIf
		If len(aMar) <= 0
			aAdd(aMar,{.f.,"",""})
		EndIf
		//
		cMarSel	:= ""
		For nPos := 1 to len(aMar)
			If aMar[nPos,1]
				cMarSel += "'"+aMar[nPos,2]+"'," // Marcas selecionadas
			EndIf
		Next
		If len(cMarSel) > 0
    		cMarSel := left(cMarSel,len(cMarSel)-1)
		EndIf
		//
		If lRefresh
			oLbMar:nAt := 1
			oLbMar:SetArray(aMar)
			oLbMar:bLine := { || { 	IIf(aMar[oLbMar:nAt,1],oOkTik,oNoTik) , aMar[oLbMar:nAt,2] , aMar[oLbMar:nAt,3] }}
			oLbMar:Refresh()
		EndIf
	Case cTipo == "COR" // Levanta Cores
		aCor := {}
		If !Empty(cMarSel)
			cQuery := "SELECT VVC.VVC_CODMAR , VVC.VVC_CORVEI , VVC.VVC_TIPCOR , VVQ.VVQ_DESCRI"
			cQuery += "  FROM "+RetSqlName("VVC")+" VVC"
			cQuery += "  JOIN "+RetSqlName("VVQ")+" VVQ"
			cQuery += "    ON ( VVQ.VVQ_FILIAL=VVC.VVC_FILIAL AND VVQ.VVQ_GRUCOR=VVC.VVC_GRUCOR AND VVQ.D_E_L_E_T_=' ' )"
			cQuery += " WHERE VVC.VVC_FILIAL='"+xFilial("VVC")+"'"
			cQuery += "   AND VVC.VVC_CODMAR IN ("+cMarSel+")"
			cQuery += "   AND VVC.D_E_L_E_T_=' '"
			cQuery += " ORDER BY VVC.VVC_CODMAR , VVQ.VVQ_DESCRI"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				lTikCor := lCor
				If !lTikCor
					If ( cQAlSQL )->( VVC_TIPCOR ) == left(cTipCor,1)
						lTikCor := .t.
					Else
						lTikCor := .f.
					EndIf
				EndIf
				If nPos == 0 .or. cAux <> ( cQAlSQL )->( VVC_CODMAR ) + ( cQAlSQL )->( VVQ_DESCRI )
					cAux := ( cQAlSQL )->( VVC_CODMAR ) + ( cQAlSQL )->( VVQ_DESCRI )
					nPos := aScan(aCor, {|x| x[2]+x[4] == cAux })
				EndIf
				If nPos <= 0
					lAux := lTikCor
					If len(aIntOport) > 0 .and. !lAux
						If aScan(aIntOport, {|x| x[1]+x[4] == ( cQAlSQL )->( VVC_CODMAR ) + ( cQAlSQL )->( VVC_CORVEI ) }) > 0 // Verifica se tem interesse na Cor (Oportunidade de Negocios)
							lAux := .t.
						EndIf
					EndIf
					aAdd(aCor,{lAux,( cQAlSQL )->( VVC_CODMAR ),"'"+Alltrim(( cQAlSQL )->( VVC_CORVEI ))+"'",( cQAlSQL )->( VVQ_DESCRI ),( cQAlSQL )->( VVC_TIPCOR )})
				Else
					aCor[nPos,3] += ",'"+Alltrim(( cQAlSQL )->( VVC_CORVEI ))+"'"
					aCor[nPos,5] += "/"+( cQAlSQL )->( VVC_TIPCOR )
				EndIf
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
		EndIf
		If len(aCor) <= 0
			aAdd(aCor,{.f.,"","","",""})
		EndIf
		If lRefresh
			oLbCor:nAt := 1
			oLbCor:SetArray(aCor)
			oLbCor:bLine := { || { 	IIf(aCor[oLbCor:nAt,1],oOkTik,oNoTik) , aCor[oLbCor:nAt,2] , aCor[oLbCor:nAt,4] }}
			oLbCor:Refresh()
		EndIf
	Case cTipo == "GRU" // Levanta Grupos de Modelo
		aGru := {}
		If !Empty(cMarSel)
			cQuery := "SELECT VVR_CODMAR , VVR_GRUMOD , VVR_DESCRI"
			cQuery += "  FROM "+RetSqlName("VVR")
			cQuery += " WHERE VVR_FILIAL='"+xFilial("VVR")+"'"
			cQuery += "   AND VVR_CODMAR IN ("+cMarSel+")"
			If left(cEstVei,1) == "0" // Novos ( Filtrar somente Modelos ainda comercializados )
				cQuery += " AND VVR_COMERC='1'"
			EndIf
			cQuery += "   AND D_E_L_E_T_=' '"
			cQuery += " ORDER BY VVR_CODMAR , VVR_DESCRI "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				lAux := lGru
				If len(aIntOport) > 0 .and. !lAux
					If aScan(aIntOport, {|x| x[1]+x[2] == ( cQAlSQL )->( VVR_CODMAR ) + ( cQAlSQL )->( VVR_GRUMOD ) }) > 0 // Verifica se tem interesse no Grupo do Modelo (Oportunidade de Negocios)
						lAux := .t.
					EndIf
				EndIf
				aAdd(aGru,{lAux,( cQAlSQL )->( VVR_CODMAR ),( cQAlSQL )->( VVR_GRUMOD ),( cQAlSQL )->( VVR_DESCRI )})
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
		EndIf
		If len(aGru) <= 0
			aAdd(aGru,{.f.,"","",""})
		EndIf
		If lRefresh
			oLbGru:nAt := 1
			oLbGru:SetArray(aGru)
			oLbGru:bLine := { || { 	IIf(aGru[oLbGru:nAt,1],oOkTik,oNoTik) , aGru[oLbGru:nAt,2] , aGru[oLbGru:nAt,4] }}
			oLbGru:Refresh()
		EndIf
	Case cTipo == "MOD" // Levanta Modelos
		aMod := {}
		If !Empty(cMarSel)
			cQuery := "SELECT VV2_CODMAR , VV2_GRUMOD , VV2_MODVEI , VV2_DESMOD "
			cQuery += "  FROM "+RetSqlName("VV2")
			cQuery += " WHERE VV2_FILIAL='"+xFilial("VV2")+"'"
			cQuery += "   AND VV2_CODMAR IN ("+cMarSel+")"
			If left(cEstVei,1) == "0" // Novos ( Filtrar somente Modelos ainda comercializados )
				cQuery += " AND VV2_COMERC='1'"
			EndIf
			cQuery += "   AND D_E_L_E_T_=' '"
			cQuery += " ORDER BY VV2_CODMAR , VV2_GRUMOD , VV2_DESMOD "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
			While !( cQAlSQL )->( Eof() )
				lAux := lMod
				If nPos == 0 .or. cAux <> ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD )
					cAux := ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_GRUMOD )
					nPos := aScan(aGru, {|x| x[2]+x[3] == cAux }) // Verifica se a Marca e o Grupo do Modelo estao selecionados
				EndIf
				If nPos > 0 .and. aGru[nPos,1]
					If nPos2 == 0 .or. cAux2 <> ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_DESMOD )
						cAux2 := ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_DESMOD )
						nPos2 := aScan(aMod, {|x| x[2]+x[5] == cAux2 })
					EndIf
					If nPos2 <= 0
						If len(aIntOport) > 0 .and. !lAux
							If aScan(aIntOport, {|x| x[1]+x[3] == ( cQAlSQL )->( VV2_CODMAR ) + ( cQAlSQL )->( VV2_MODVEI ) }) > 0 // Verifica se tem interesse no Modelo (Oportunidade de Negocios)
								lAux := .t.
							EndIf
						EndIf
						aAdd(aMod,{lAux,( cQAlSQL )->( VV2_CODMAR ),( cQAlSQL )->( VV2_GRUMOD ),"'"+Alltrim(( cQAlSQL )->( VV2_MODVEI ))+"'",( cQAlSQL )->( VV2_DESMOD )})
					Else
						aMod[nPos2,4] += ",'"+Alltrim(( cQAlSQL )->( VV2_MODVEI ))+"'"
					EndIf
				EndIf
				( cQAlSQL )->( DbSkip() )
			EndDo
			( cQAlSQL )->( DbCloseArea() )
		EndIf
		If len(aMod) <= 0
			aAdd(aMod,{.f.,"","","",""})
		EndIf
		If lRefresh
			oLbMod:nAt := 1
			oLbMod:SetArray(aMod)
			oLbMod:bLine := { || { 	IIf(aMod[oLbMod:nAt,1],oOkTik,oNoTik) , aMod[oLbMod:nAt,2] , aMod[oLbMod:nAt,5] }}
			oLbMod:Refresh()
		EndIf
EndCase
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK    ³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ TIK dos ListBox de Filtro                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(cTipo,nLinha)
Local ni := 0
Do Case
	Case cTipo == "MAR"
		If len(aMar) > 1 .or. !Empty(aMar[1,2])
			If nLinha == 0 // Tik Total
				For ni := 1 to len(aMar)
					aMar[ni,1] := lMar
				Next
			Else
				aMar[nLinha,1] := !aMar[nLinha,1]
			EndIf
			oLbMar:Refresh()
		EndIf
		//
		cMarSel	:= ""
		For ni := 1 to len(aMar)
			If aMar[ni,1]
				cMarSel += "'"+aMar[ni,2]+"'," // Marcas selecionadas
			EndIf
		Next
		If len(cMarSel) > 0
    		cMarSel := left(cMarSel,len(cMarSel)-1)
		EndIf
		//
		FS_LEVANTA("COR",.t.)
		FS_LEVANTA("GRU",.t.)
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "GRU"
		If len(aGru) > 1 .or. !Empty(aGru[1,2])
			If nLinha == 0 // Tik Total
				For ni := 1 to len(aGru)
					aGru[ni,1] := lGru
				Next
			Else
				aGru[nLinha,1] := !aGru[nLinha,1]
			EndIf
			oLbGru:Refresh()
		EndIf
		FS_LEVANTA("MOD",.t.)
	Case cTipo == "MOD"
		If len(aMod) > 1 .or. !Empty(aMod[1,2])
			If nLinha == 0 // Tik Total
				For ni := 1 to len(aMod)
					aMod[ni,1] := lMod
				Next
			Else
				aMod[nLinha,1] := !aMod[nLinha,1]
			EndIf
			oLbMod:Refresh()
		EndIf
	Case cTipo == "COR"
		If len(aCor) > 1 .or. !Empty(aCor[1,2])
			If nLinha == -1 // Selecionando o Tipo de Cor
				lCor := .f.
				For ni := 1 to len(aCor)
					If left(cTipCor,1) $ aCor[ni,5]
						aCor[ni,1] := .t.
					Else
						aCor[ni,1] := .f.
					EndIf
				Next
			ElseIf nLinha == 0 // Tik Total
				cTipCor := ""
				For ni := 1 to len(aCor)
					aCor[ni,1] := lCor
				Next
			Else
				cTipCor := ""
				aCor[nLinha,1] := !aCor[nLinha,1]
			EndIf
			oTipCor:Refresh()
			oLbCor:Refresh()
		EndIf
EndCase
FS_CONSVEIC(2)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CONSVEIC³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Veiculos                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONSVEIC(nTp)
Local cQuery  := ""
Local cQAlSQL := "ALIASSQL"
Local cQAlAux := "ALIASSQLAUX"
Local ni      := 0
Local nj      := 0
Local nPos    := 0
Local nFil    := 0
Local _cVV1   := ""
Local cLetraF := "N" // Fisica (Estoque/Remessa/Consignado/...)
Local cLetraC := "N" // Comercial (Bloqueado/Reservado/Normal)
Local aAux    := {}
Local lAux    := .t.
Local aRet    := {}
Local lReserv := .f.
Local dDatRes := dDataBase
Local cHorTmp := ""
Local cCodInd := ""
Local nDiaCar := 0
Local cGruVei := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cAtuFil := ""
Local cVVAFil := ""
Local cSE2Fil := ""
Local cVV1Fil := ""
Local cSA1Fil := ""
Local cSA2Fil := ""
Local cVV2Fil := ""
Local cVVCFil := ""
Local cSB1Fil := ""
Local cVVFFil := "" // Utiliza a filial do VVF pois a funcao FGX_AMOVVEI grava VV1_FILENT := xFilial("VVF")
Local cBkpFilP  := cFilAnt // Salva cFilAnt principal ( Filial Atual )
Local aQUltMov  := {}
Local nValorVda := 0
Local lVerBloq  := ( VAI->VAI_BLOQVE <> "0" ) // Nao mostrar veiculos bloqueados
Local cBloqStat := GetNewPar("MV_BLQSTAV","LO") // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro
Local lMostraVei:= .t.
Local lPromoc     := ( VV1->(ColumnPos("VV1_PROMOC")) > 0 )
Local lFotos      := ( VV1->(ColumnPos("VV1_FOTOS"))  > 0 )
Local lVQ0_CONFIG := ( VQ0->(ColumnPos("VQ0_CONFIG")) > 0 )
Local lVV1_CFGBAS := ( VV1->(ColumnPos("VV1_CFGBAS")) > 0 )
Local lVVF_TIPDOC := ( VVF->(ColumnPos("VVF_TIPDOC")) > 0 )
Local lVV9_APRPUS := ( VV9->(ColumnPos("VV9_APRPUS")) > 0 )
Local cDatEnt   := ""
Local nBonus    := 0
Local nDiasEst  := 0
Local lJaPago   := .f.
Local cNTpTit   := ""
Local cCampoSQL := ""
Local lVXC01QRY := ExistBlock("VXC01QRY")
Local cVXC01QRY := ""
Local cPedVQ0   := "" // Nro.Pedido
Local cDatFDD   := "" // Dt.FDD
Local cDatPed   := "" // Dt.Pedido
Local cSitVei1  := ""
Local cSitVei2  := ""
Local cNomVV1   := RetSqlName("VV1")
Local cNomVV2   := RetSqlName("VV2")
Local cNomVVC   := RetSqlName("VVC")
Local cNomSB1   := RetSqlName("SB1")
Local cNomVVF   := RetSqlName("VVF")
Local cNomVVG   := RetSqlName("VVG")
Local cNomSF1   := RetSqlName("SF1")
Local cNomSE2   := RetSqlName("SE2")
Local cNomVV9   := RetSQLName("VV9")
Local cNomVV0   := RetSQLName("VV0")
Local cNomVVA   := RetSQLName("VVA")
Local cNomSA1   := RetSqlName("SA1")
Local cNomSA2   := RetSqlName("SA2")
Local cNomVQ0   := RetSqlName("VQ0")

If nTp == 1 // Quando Selecionar Filial
	For ni := 1 to len(aUFTot)
		aUFTot[ni,3] := .f. // Retirar UF
	Next
	aUFTot[1,3] := .t. // Todas UF
ElseIf nTp == 3 // Quando Selecionar UF Filiais
	For ni := 1 to len(aUFTot)
		aUFTot[ni,3] := .f.
	Next
	ni := aScan(aUFTot,{|x| x[1] == cUFFiltro }) // UF escolhida
	If ni <= 0
		ni := 1
	Else
		cFilVV1 := ""
	EndIf
	aUFTot[ni,3] := .t.
EndIf

If lAutoma .or. lBotAtu // Atualizacao Automatica ou Botao de Atualizar
	
	aVeicTot := {}

	///////////////////////////////////////
	// Verifica TIK para filtrar SITVEI  //
	///////////////////////////////////////
	cSitVei1 += IIf(lCkFilEst,"'0',","") // Estoque
	cSitVei1 += IIf(lCkFilRem .or. lCkFilRMS,"'3',","") // Remessa
	cSitVei1 += IIf(lCkFilCon,"'4',","") // Consignado
	If len(cSitVei1) > 0
		cSitVei1 := left(cSitVei1,len(cSitVei1)-1) // SITVEI com TRACPA ( JOIN )
	EndIf
	cSitVei2 += IIf(lCkFilTra,"'2',","") // Em Transito
	cSitVei2 += IIf(lCkFilPed,"'8',","") // Pedido
	If len(cSitVei2) > 0
		cSitVei2 := left(cSitVei2,len(cSitVei2)-1) // SITVEI sem TRACPA ( LEFT JOIN )
	EndIf

	If !Empty(cSitVei1+cSitVei2) // Selecionou ( TIK - Estoque / Remessa / Consignado / Em Transito / Pedido )
	
		///////////////////////////////////////
		// Monta Vetor por Marca (Modelo)    //
		///////////////////////////////////////
		For ni := 1 to len(aMod)
			If aMod[ni,1] .and. !Empty(aMod[ni,2])
				nPos := aScan(aAux,{|x| x[1] == aMod[ni,2] })
				If nPos <= 0
					aAdd(aAux,{aMod[ni,2],aMod[ni,4],""})
				Else
					aAux[nPos,2] += IIf(!Empty(aAux[nPos,2]),",","")+aMod[ni,4] // IN de modelos
				EndIf
			EndIf
		Next
		For ni := 1 to len(aAux)
			lAux := .t.
			For nj := 1 to len(aGru) // Verificar se TODOS os grupos de modelos da marca estao selecionados
				If aAux[ni,1] == aGru[nj,2]
					If !aGru[nj,1]
						lAux := .f. // um nao selecionado
						Exit
	    			EndIf
				EndIf
			Next
			If lAux
				For nj := 1 to len(aMod) // Verificar se TODOS os modelos da marca estao selecionados
					If aAux[ni,1] == aMod[nj,2]
						If !aMod[nj,1]
							lAux := .f. // um nao selecionado
							Exit
	    				EndIf
					EndIf
				Next
				If lAux // TODOS os modelos da marca estao selecionados
					aAux[ni,2] := "*"
				EndIf
			EndIf
		Next
		
		///////////////////////////////////////
		// Monta Vetor por Marca (Modelo/Cor)//
		///////////////////////////////////////
		For ni := 1 to len(aAux)
			lAux := .t.
			For nj := 1 to len(aCor) // Verificar se TODAS as cores da marca estao selecionadas
				If aAux[ni,1] == aCor[nj,2]
					If !aCor[nj,1]
						lAux := .f. // uma nao selecionada
						Exit
	    			EndIf
				EndIf
			Next
			If lAux // TODAS as cores da marca estao selecionadas
				aAux[ni,3] := "*"
			EndIf
		Next
		For ni := 1 to len(aAux)
			If aAux[ni,3] <> "*" // Caso TODAS as cores da marca nao estao selecionadas
				For nj := 1 to len(aCor)
					If aCor[nj,1]
						If aAux[ni,1] == aCor[nj,2]
							If Empty(aAux[ni,3])
								aAux[ni,3] += aCor[nj,3]
							Else
								aAux[ni,3] += ","+aCor[nj,3] // IN de cores
							EndIf
						EndIf
					EndIf
				Next
			EndIf
		Next
	
		///////////////////////////////////////
		// Levanta todas as Filiais do VVA   //
		///////////////////////////////////////
		cQuery := "SELECT DISTINCT VVA.VVA_FILIAL FROM "+cNomVVA+" VVA WHERE VVA.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		While !( cQAlAux )->( Eof() )
			cVVAFil += "'"+( cQAlAux )->( VVA_FILIAL )+"',"
			( cQAlAux )->( dbSkip() )
		EndDo
		( cQAlAux )->( dbCloseArea() )
		If !Empty(cVVAFil)
			cVVAFil := left(cVVAFil,len(cVVAFil)-1)
		Else
			cVVAFil := "'"+xFilial("VVA")+"'"
		EndIf
	
		///////////////////////////////////////
		// Levanta todas as Filiais do SE2   //
		///////////////////////////////////////
		cQuery := "SELECT DISTINCT SE2.E2_FILIAL FROM "+cNomSE2+" SE2 WHERE SE2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
		While !( cQAlAux )->( Eof() )
			cSE2Fil += "'"+( cQAlAux )->( E2_FILIAL )+"',"
			( cQAlAux )->( dbSkip() )
		EndDo
		( cQAlAux )->( dbCloseArea() )
		If !Empty(cSE2Fil)
			cSE2Fil := left(cSE2Fil,len(cSE2Fil)-1)
		Else
			cSE2Fil := "'"+xFilial("SE2")+"'"
		EndIf
		cNTpTit := FormatIN(MVABATIM,"|")

		///////////////////////////////////////
		// Agrupar Marcas ( diminuir SQLs )  //
		///////////////////////////////////////
		aRet := {}
		aAdd(aRet,{"","*","*"})
		For ni := 1 to len(aAux)
			If aAux[ni,2] == "*" .and. aAux[ni,3] == "*"
				aRet[1,1] += "'"+aAux[ni,1]+"',"
			Else
				aAdd(aRet,aClone(aAux[ni]))
			EndIf
		Next
		If len(aRet[1,1]) > 0
			aRet[1,1] := left(aRet[1,1],len(aRet[1,1])-1) // IN
		EndIf
		aAux := aClone(aRet)
		aRet := {}

		cCampoSQL := "VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , "
		cCampoSQL += "VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , "
		cCampoSQL += "VV1.VV1_ESTVEI , VV1.VV1_TIPVEI , VV1.VV1_FILENT , "
		cCampoSQL += "VV1.VV1_FABMOD , VV1.VV1_KILVEI , VV1.VV1_RESERV , "
		cCampoSQL += "VV1.VV1_DTHVAL , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , "
		cCampoSQL += "VV1.VV1_PLAVEI , VV1.VV1_COMVEI , VV1.VV1_OPCFAB , "
		cCampoSQL += "VV1.VV1_TRACPA , VV2.VV2_GRUMOD , VV2.VV2_DESMOD , "
		cCampoSQL += "VVC.VVC_DESCRI , VVF.VVF_DATEMI , SF1.F1_DOC "
		If lFotos // Existe o campo de Fotos
			cCampoSQL += ", VV1.VV1_FOTOS "
		EndIf
		If lPromoc // Existe o campo de Promocao
			cCampoSQL += ", VV1.VV1_PROMOC "
		EndIf
		If lVV1_CFGBAS // 
			cCampoSQL += ", VV1.VV1_CFGBAS "
		EndIf
		If lVVF_TIPDOC
			cCampoSQL += ", VVF.VVF_TIPDOC "
		EndIf

		///////////////////////////////////////
		// For das Filiais possiveis no VV1  //
		///////////////////////////////////////
		For nFil := 1 to Len(aFilVV1)
			If Empty(aFilVV1[nFil])
				Loop
			EndIf
			If !Empty(cFilVV1)
				If cFilVV1 <> aFilVV1[nFil]
					Loop
				EndIf
			EndIf
	
			cFilAnt := aFilVV1[nFil] // Multi Filial -> Muda cFilAnt para utilizar xFilial dos arquivos
	
			cVV1Fil := xFilial("VV1")
			cSA1Fil := xFilial("SA1")
			cSA2Fil := xFilial("SA2")
			cVV2Fil := xFilial("VV2")
			cVVCFil := xFilial("VVC")
			cSB1Fil := xFilial("SB1")	
			cVVFFil := xFilial("VVF") // Utiliza a filial do VVF pois a funcao FGX_AMOVVEI grava VV1_FILENT := xFilial("VVF")
	
			For ni := 1 to len(aAux)
				
				If Empty(aAux[ni,1]) // Desconsiderar SEM MARCA
					Loop
				EndIf
				
				cQuery := "SELECT "+cCampoSQL+", SUM(SE2.E2_VALOR) AS VALOR , SUM(SE2.E2_SALDO) AS SALDO"
				cQuery += "  FROM "+cNomVV1+" VV1"
				cQuery += "  JOIN "+cNomVV2+" VV2 ON ( VV2.VV2_FILIAL='"+cVV2Fil+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI AND VV1.VV1_SEGMOD=VV2.VV2_SEGMOD "+IIf(left(cEstVei,1)=="0","AND VV2.VV2_COMERC='1' ","")+"AND VV2.D_E_L_E_T_=' ' ) " // Novos ( Filtrar somente Modelos ainda comercializados )
				If !Empty(cSitVei2) // Precisa de LEFT JOIN
					cQuery += " LEFT "
				EndIf
				cQuery += "  JOIN "+cNomSB1+" SB1 ON ( SB1.B1_FILIAL='"+cSB1Fil+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE=VV1.VV1_CHAINT AND SB1.D_E_L_E_T_=' ' ) "
				If !Empty(cSitVei2) // Precisa de LEFT JOIN
					cQuery += " LEFT"
				EndIf
				cQuery += "  JOIN "+cNomVVF+" VVF ON ( VVF.VVF_FILIAL=VV1.VV1_FILENT AND VVF.VVF_TRACPA=VV1.VV1_TRACPA AND VVF.D_E_L_E_T_=' ' ) "
				If lVVF_TIPDOC
					cQuery += "  LEFT JOIN " // Se existir o campo, trazer todos os registros com ou sem NF SF1
				Else
					If !Empty(cSitVei2) // Precisa de LEFT JOIN
						cQuery += " LEFT"
					EndIf
					cQuery += " JOIN " // Se nao existir o campo, trazer somente os registros com NF SF1
				EndIf
				cQuery +=                cNomSF1+" SF1 ON ( SF1.F1_FILIAL=VVF.VVF_FILIAL AND SF1.F1_DOC=VVF.VVF_NUMNFI AND SF1.F1_SERIE=VVF.VVF_SERNFI AND SF1.F1_FORNECE=VVF.VVF_CODFOR AND SF1.F1_LOJA=VVF.VVF_LOJA AND SF1.D_E_L_E_T_=' ' ) "
				cQuery += "  LEFT JOIN "+cNomVVC+" VVC ON ( VVC.VVC_FILIAL='"+cVVCFil+"' AND VVC.VVC_CODMAR=VV1.VV1_CODMAR AND VVC.VVC_CORVEI=VV1.VV1_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
				cQuery += "  LEFT JOIN "+cNomSE2+" SE2 ON ( SE2.E2_FILIAL IN ("+cSE2Fil+") AND SE2.E2_NUM=SF1.F1_DOC AND SE2.E2_PREFIXO=SF1.F1_PREFIXO AND SE2.E2_FORNECE=SF1.F1_FORNECE AND SE2.E2_LOJA=SF1.F1_LOJA AND SE2.D_E_L_E_T_=' ' AND SE2.E2_TIPO NOT IN "+cNTpTit+" ) "
				cQuery += " WHERE VV1.VV1_FILIAL='"+cVV1Fil+"' AND "
				If len(aAux[ni,1]) == 3
					cQuery += "VV1.VV1_CODMAR='"+aAux[ni,1]+"' AND "
				Else
					cQuery += "VV1.VV1_CODMAR IN ("+aAux[ni,1]+") AND "
				EndIf
				If !Empty(aAux[ni,2])
					If aAux[ni,2] <> "*" // TODOS os modelos da marca nao estao selecionados, necessario fazer contido
						cQuery += "VV1.VV1_MODVEI IN ("+aAux[ni,2]+") AND "
					EndIf
				Else
					Loop // Pula linha do vetor quando nao existe MODELO de Veiculo para a Marca
				EndIf
				If !Empty(aAux[ni,3])
					If aAux[ni,3] <> "*" // TODAS as cores da marca nao estao selecionadas, necessario fazer contido
						cQuery += "VV1.VV1_CORVEI IN ("+aAux[ni,3]+") AND "
					EndIf
				Else
					Loop // Pula linha do vetor quando nao existe COR de Veiculo para a Marca
				EndIf
				//	
				cQuery += "( "
				If len(cSitVei1) > 0 // Estoque / Remessa / Consignado
					If len(cSitVei1) == 3
						cQuery += "( VV1.VV1_SITVEI="+cSitVei1+" AND VV1.VV1_TRACPA<>' ' ) "
					Else
						cQuery += "( VV1.VV1_SITVEI IN ("+cSitVei1+") AND VV1.VV1_TRACPA<>' ' ) "
					EndIf
					If len(cSitVei2) > 0
						cQuery += "OR "
					EndIf
				EndIf
				If len(cSitVei2) > 0 // Em Transito / Pedido
					If len(cSitVei2) == 3
						cQuery += "VV1.VV1_SITVEI="+cSitVei2+" "
					Else
						cQuery += "VV1.VV1_SITVEI IN ("+cSitVei2+") "
					EndIf
				EndIf
				cQuery += ") AND "
				//	
				cQuery += "VV1.VV1_ESTVEI='"+left(cEstVei,1)+"' AND "
				//
				If !Empty(cTipVei) // Tipo do Veiculo (Normal/Taxi/Frotista)
					cQuery += "VV1.VV1_TIPVEI='"+cTipVei+"' AND "
				EndIf
				cQuery += "VV1.VV1_FILENT='"+cVVFFil+"' AND "
				If !Empty(cTipCor)
					cQuery += "VVC.VVC_TIPCOR='"+left(cTipCor,1)+"' AND "
				EndIf
				cQuery += "VV1.D_E_L_E_T_=' ' "
				If lVXC01QRY
					cVXC01QRY := ExecBlock("VXC01QRY",.f.,.f.)
					If !Empty(cVXC01QRY)
						cQuery += " AND "+cVXC01QRY+" "
					EndIf
				EndIf			
				cQuery += "GROUP BY "+cCampoSQL+" "
				cQuery += "ORDER BY VV1.VV1_CHAINT "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
				While !( cQAlSQL )->( Eof() )
					If _cVV1 # ( cQAlSQL )->( VV1_CHAINT )
						_cVV1 := ( cQAlSQL )->( VV1_CHAINT )

						lMostraVei := .t.
						cLetraC := "N"

		 				If lVVF_TIPDOC .and. ( cQAlSQL )->( VV1_SITVEI ) <> "8" // Diferente de Pedido - Validar Tipo de Documento
							If Empty(( cQAlSQL )->( F1_DOC )) .and. ( cQAlSQL )->( VVF_TIPDOC ) <> '2'
								lMostraVei := .f.	// Desconsiderar se nao existe a NF no SF1 e o Tipo de Documento no VVF é NF
							EndIf
						EndIf

						If lMostraVei
							lReserv := .f.
							If ( cQAlSQL )->( VV1_RESERV ) $ "1/3" // Reservado
								If !Empty(( cQAlSQL )->( VV1_DTHVAL ))
									lReserv := .t.
									dDatRes := ctod(subs(( cQAlSQL )->( VV1_DTHVAL ),1,8))
									if dDataBase > dDatRes
										lReserv := .f.
									Elseif dDataBase == dDatRes
										cHorTmp := subs(( cQAlSQL )->( VV1_DTHVAL ),10,2)+":"+subs(( cQAlSQL )->( VV1_DTHVAL ),12,2)
										if Substr(Time(),1,5) > cHorTmp
											lReserv := .f.
										Endif
									Endif
									If lReserv
										cLetraC := "R"
										If !lCkFilRes
											lMostraVei := .f.
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
	
						If lMostraVei
							aRet := VM060VEIBLO(( cQAlSQL )->( VV1_CHAINT ),"B") // Verifica se o Veiculo esta Bloqueado, retorna registro do Bloqueio.
							If len(aRet) > 0
								cLetraC := "B"
								If !lCkFilBlo .or. !lVerBloq // TIK ou Usuario nao pode ver os Veiculos BLOQUEADOS //
									lMostraVei := .f.
								EndIf
							EndIf
						EndIf
						
						If lMostraVei .and. !lCkFilNor .and. cLetraC == "N" // Normal
							lMostraVei := .f.
						EndIf
	
						//////////////////////////////////////////////////////////////////////////
						// Nao mostrar Veiculos que estao em Atendimentos com STATUS Bloqueados //
						//////////////////////////////////////////////////////////////////////////
						If lMostraVei .and. !Empty(cBloqStat)
	
							cQuery := "SELECT VV9.VV9_STATUS , "
							If lVV9_APRPUS .and. "L" $ cBloqStat // Considerar Aprovacao Previa se considera Status Aprovado
								cQuery += " VV9.VV9_APRPUS AS APR_PREVIA "
							Else
								cQuery += " ' ' AS APR_PREVIA " // Desconsiderar Aprovacao Previa
							EndIf
							cQuery += "  FROM "+cNomVVA+" VVA"
							cQuery += "  JOIN "+cNomVV0+" VV0 ON ( VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_=' ' )"
							cQuery += "  JOIN "+cNomVV9+" VV9 ON ( VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.D_E_L_E_T_=' ' )"
							cQuery += " WHERE VVA.VVA_FILIAL IN ("+cVVAFil+")"
							If !Empty(( cQAlSQL )->( VV1_CHASSI ))
								cQuery += "  AND VVA.VVA_CHASSI='"+( cQAlSQL )->( VV1_CHASSI )+"'" // Necessario devido a validação nas demais Filiais
							Else
								cQuery += "  AND VVA.VVA_CHAINT='"+( cQAlSQL )->( VV1_CHAINT )+"'"
								cQuery += "  AND VVA.VVA_CHASSI=' '" // Necessario devido a validação nas demais Filiais
							EndIf
							cQuery += "   AND VVA.D_E_L_E_T_ = ' '"
							cQuery += "   AND VV9.VV9_STATUS NOT IN ('C','F','T','R','D')" // Considerar somente atendimento em aberto
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
							While !( cQAlAux )->( Eof() )
								If ( cQAlAux )->( VV9_STATUS ) $ cBloqStat .or. !Empty( ( cQAlAux )->( APR_PREVIA ) ) // STATUS de outro Atendimento do mesmo Veiculo que bloqueia novo Atendimento
									lMostraVei := .f.
									Exit
								EndIf
								( cQAlAux )->( dbSkip() )
							EndDo
							( cQAlAux )->( dbCloseArea() )

						EndIf
						//////////////////////////////////////////////////////////////////////////

						If lMostraVei

							nDiasEst := 0
							aQUltMov := FM_VEIUMOV( ( cQAlSQL )->( VV1_CHASSI ) , "E" , "0" )
							If len(aQUltMov) > 0
								nDiasEst := (dDataBase-aQUltMov[5])
							EndIf
							
							Do Case
								Case ( cQAlSQL )->( VV1_SITVEI ) == "0" // Estoque
									cLetraF := "N"
								Case ( cQAlSQL )->( VV1_SITVEI ) == "2" // Transito
									cLetraF := "T"
								Case ( cQAlSQL )->( VV1_SITVEI ) == "3" // Remessa
									cLetraF := "R"
								Case ( cQAlSQL )->( VV1_SITVEI ) == "4" // Consignado
									cLetraF := "C"
								Case ( cQAlSQL )->( VV1_SITVEI ) == "8" // Pedido
									cLetraF := "P"
							EndCase
							
							If cLetraF $ "RC" // Remessa / Consignado
								aQUltMov := FGX_VEIMOVS( ( cQAlSQL )->( VV1_CHASSI ) , , )
								If cLetraF == "R" // Remessa
									cLetraF := " "
									For nj := 1 to len(aQUltMov)										
										If aQUltMov[nj,1]=="E" 		// Entrada
											If Empty(cLetraF)
												cLetraF := "E"
											EndIf
											Exit
										ElseIf aQUltMov[nj,1]=="S"	// Saida por Remessa
											If Empty(cLetraF)
												cLetraF := "S"
											EndIf
											If len(aQUltMov) >= ( nj+1 )
												If aQUltMov[nj+1,1]=="S" // Saida por Venda
													If aQUltMov[nj+1,5]=="0" // Venda
														lMostraVei := .f. // Desconsiderar Veiculo ja Vendido e esta em Remessa
														Exit
													EndIf
												EndIf
											EndIf
										EndIf
									Next
									If cLetraF == "E" .and. !lCkFilRem
										lMostraVei := .f.
									ElseIf cLetraF == "S" .and. !lCkFilRMS
										lMostraVei := .f.
									EndIf
								EndIf
								If lMostraVei
									cAtuFil := ""
									If len(aQUltMov) > 0
										If aQUltMov[1,1] == "S" // SAIDA
											If aQUltMov[1,5] $ "67" // Retorno de Remessa / Retorno de Consignado
												cQuery  := "SELECT A2_NOME FROM "+cNomSA2
												cQuery  += " WHERE A2_FILIAL='"+cSA2Fil+"' AND A2_COD='"+aQUltMov[1,7]+"' AND A2_LOJA='"+aQUltMov[1,8]+"' AND D_E_L_E_T_=' '"
												cAtuFil := STR0062+": "+aQUltMov[1,7]+"-"+aQUltMov[1,8]+" "+left(FM_SQL(cQuery),20) // Fornecedor
											Else
												cQuery  := "SELECT A1_NOME FROM "+cNomSA1
												cQuery  += " WHERE A1_FILIAL='"+cSA1Fil+"' AND A1_COD='"+aQUltMov[1,7]+"' AND A1_LOJA='"+aQUltMov[1,8]+"' AND D_E_L_E_T_=' '"
												cAtuFil := STR0063+": "+aQUltMov[1,7]+"-"+aQUltMov[1,8]+" "+left(FM_SQL(cQuery),20) // Cliente
											EndIf
										Else // ENTRADA
											If aQUltMov[1,5] $ "78" // Retorno de Remessa / Retorno de Consignado
												cQuery  := "SELECT A1_NOME FROM "+cNomSA1
												cQuery  += " WHERE A1_FILIAL='"+cSA1Fil+"' AND A1_COD='"+aQUltMov[1,7]+"' AND A1_LOJA='"+aQUltMov[1,8]+"' AND D_E_L_E_T_=' '"
												cAtuFil := STR0063+": "+aQUltMov[1,7]+"-"+aQUltMov[1,8]+" "+left(FM_SQL(cQuery),20) // Cliente
											Else
												cQuery  := "SELECT A2_NOME FROM "+cNomSA2
												cQuery  += " WHERE A2_FILIAL='"+cSA2Fil+"' AND A2_COD='"+aQUltMov[1,7]+"' AND A2_LOJA='"+aQUltMov[1,8]+"' AND D_E_L_E_T_=' '"
												cAtuFil := STR0062+": "+aQUltMov[1,7]+"-"+aQUltMov[1,8]+" "+left(FM_SQL(cQuery),20) // Fornecedor
											EndIf
										EndIf
									EndIf
								EndIf
							Else // Nome da Filial que esta o Veiculo ( VV1_FILENT )
								cAtuFil := ( cQAlSQL )->( VV1_FILENT )
								cAtuFil += " - "+left(FWFilialName(cEmpAnt,( cQAlSQL )->( VV1_FILENT ),1),15)
							EndIf
							
							If lMostraVei
	
								cCodInd := ""
								nDiaCar := 0
								If !Empty(( cQAlSQL )->( VV1_TRACPA )) .and. !Empty(( cQAlSQL )->( VV1_CHASSI ))
									// Posicionamento no VVG //
									cQuery := "SELECT VVG_CODIND , VVG_DIACAR"
									cQuery += "  FROM "+cNomVVG
									cQuery += " WHERE VVG_FILIAL='"+( cQAlSQL )->( VV1_FILENT )+"'"
									cQuery += "   AND VVG_TRACPA='"+( cQAlSQL )->( VV1_TRACPA )+"'"
									cQuery += "   AND VVG_CHASSI='"+( cQAlSQL )->( VV1_CHASSI )+"'"
									cQuery += "   AND D_E_L_E_T_=' '"
									dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
									If !( cQAlAux )->( Eof() )
										cCodInd := ( cQAlAux )->( VVG_CODIND )
										nDiaCar := ( cQAlAux )->( VVG_DIACAR )
									Endif
									( cQAlAux )->( dbCloseArea() )
								EndIf
			
								nBonus  := FGX_BONVEI(( cQAlSQL )->( VV1_CHAINT ),( cQAlSQL )->( VV1_CODMAR ),( cQAlSQL )->( VV1_MODVEI ),,,,( cQAlSQL )->( VV1_ESTVEI ),( cQAlSQL )->( VV2_GRUMOD ),dDataBase,"",,"","1",dDataBase,,lTodBon)

								cConfig := ""
								If lVV1_CFGBAS
									cConfig := ( cQAlSQL )->( VV1_CFGBAS )
								EndIf

								//////////////////////////////////
								// Posicionamento no Pedido VQ0 //
								//////////////////////////////////
								cPedVQ0 := ""
								cDatFDD := ""
								cDatPed := ""
								cDatEnt := ""
								cQuery := "SELECT VQ0_NUMPED , VQ0_DATFDD , VQ0_DATPED"
								If cLetraF == "P" // Pedido
									cQuery += " , VQ0_DATPRE"
								EndIf
								If lVQ0_CONFIG .and. Empty(cConfig)
									cQuery += " , VQ0_CONFIG"
								EndIf
								cQuery += "  FROM "+cNomVQ0
								cQuery += " WHERE VQ0_FILIAL='"+( cQAlSQL )->( VV1_FILIAL )+"'"
								cQuery += "   AND VQ0_CHAINT='"+( cQAlSQL )->( VV1_CHAINT )+"'"
								cQuery += "   AND D_E_L_E_T_=' '"
								dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux , .F., .T. )
								If !( cQAlAux )->( Eof() )
									cPedVQ0 := ( cQAlAux )->( VQ0_NUMPED ) // Nro.Pedido
									cDatFDD := Transform(stod(( cQAlAux )->( VQ0_DATFDD )),"@D") // Data FDD
									cDatPed := Transform(stod(( cQAlAux )->( VQ0_DATPED )),"@D") // Data Pedido
									If cLetraF == "P" // Pedido
										cDatEnt := Transform(stod(( cQAlAux )->( VQ0_DATPRE )),"@D") // Data Entrega
									EndIf
									If lVQ0_CONFIG .and. Empty(cConfig)
										cConfig := ( cQAlAux )->( VQ0_CONFIG )
									EndIf
								Endif
								( cQAlAux )->( dbCloseArea() )
								
								lJaPago := .f.
								If cLetraF <> "T" // Diferente de Em Transito
									If ( cQAlSQL )->( VALOR ) > 0
										lJaPago := ( ( cQAlSQL )->( SALDO ) <= 0 ) // Se ZERADO -> Ja pago!
									EndIf
								EndIf
	
								nValorVda := FGX_VLRSUGV( ( cQAlSQL )->( VV1_CHAINT ) , ( cQAlSQL )->( VV1_CODMAR ) , ( cQAlSQL )->( VV1_MODVEI ) , ( cQAlSQL )->( VV1_SEGMOD ) , ( cQAlSQL )->( VV1_CORVEI ) , .t. , cCdCliAt , cLjCliAt )
								
								aAdd( aVeicTot , { 	cLetraF ,;
													cLetraC ,;
													IIf(!Empty(( cQAlSQL )->( VV1_FILIAL )),( cQAlSQL )->( VV1_FILIAL ),( cQAlSQL )->( VV1_FILENT )) , ;
													( cQAlSQL )->( VV1_ESTVEI ) , ;
													Transform(nDiasEst,"@E 9,999") , ;
													( cQAlSQL )->( VV1_CODMAR ) , ;
													Alltrim(( cQAlSQL )->( VV1_MODVEI )) + " - " + ( cQAlSQL )->( VV1_SEGMOD ) + " - "+ ( cQAlSQL )->( VV2_DESMOD ) , ;
													left(( cQAlSQL )->( VVC_DESCRI ),18) , ;
													nValorVda , ;
													IIf( lFotos , ( cQAlSQL )->( VV1_FOTOS ) , "" ) , ;
													( cQAlSQL )->( VV1_FABMOD ) , ;
													( cQAlSQL )->( VV1_COMVEI ) , ;
													( cQAlSQL )->( VV1_OPCFAB ) , ;
													( cQAlSQL )->( VV1_CHASSI ) , ;
													( cQAlSQL )->( VV1_PLAVEI ) , ;
													( cQAlSQL )->( VV1_KILVEI ) , ;
													( cQAlSQL )->( VV1_TIPVEI ) , ;
													cDatEnt , ;
													cAtuFil , ;
													Transform(stod(( cQAlSQL )->( VVF_DATEMI )),"@D") , ;
													cCodInd , ;
													nDiaCar , ;
													( cQAlSQL )->( VV1_TRACPA ) , ;
													( cQAlSQL )->( VV1_CHAINT ) , ;
													IIf( lPromoc , ( cQAlSQL )->( VV1_PROMOC ) , "" ) , ;
													.f. ,;
													nBonus ,;
													lJaPago ,;
													cPedVQ0 ,;
													cConfig ,;
													cDatFDD ,;
													cDatPed })
							EndIf

						EndIf

					EndIf

					( cQAlSQL )->( DbSkip() )
				EndDo
				( cQAlSQL )->( dbCloseArea() )
			
			Next
			
		Next
	
	EndIf

	If Len(aVeicTot) <= 0
		FS_ADDVET("aVeicTot") // Adiciona linha em branco no Vetor
	Endif
	
	dbSelectArea("VV1")
	dbSetOrder(1)
	
	FS_FILTVETOR() // Filtra Vetor de Veiculos
	
EndIf

cFilAnt := cBkpFilP // Volta cFilAnt principal ( Filial Atual )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTVETOR³ Autor ³ Andre Luis Almeida  ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra/Ordena Vetor dos Veiculos                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTVETOR()
Local ni  := 0
Local nj  := 0
Local lOk := .t.
Local cOpcAux := ""
Local nOpcAux := 0
aVeicVer := {}
If lAutoma .or. lBotAtu // Atualizacao Automatica ou Botao de Atualizar
	lBotAtu := .f.
	For ni := 1 to len(aVeicTot)
		If cAnoIni+cAnoIni > aVeicTot[ni,11] // Verifica Ano Fab/Mod Inicial
			Loop // Pular Veiculo
		EndIf
		If cAnoFin+strzero(val(cAnoFin)+1,4) < aVeicTot[ni,11] // Verifica Ano Fab/Mod Final
			Loop // Pular Veiculo
		EndIf
		If nVlrIni > aVeicTot[ni,09] // Verifica Valor Inicial
			Loop // Pular Veiculo
		EndIf
		If nVlrFin < aVeicTot[ni,09] // Verifica Valor Final
			Loop // Pular Veiculo
		EndIf
		If nKMMaxi < aVeicTot[ni,16] // Verifica KM Maxima
			Loop // Pular Veiculo
		EndIf
		If !Empty(cTipVei) .and. ( aVeicTot[ni,17] <> cTipVei ) // Verifica Tipo do Veiculo (Normal/Tax/Frotista)
			Loop // Pular Veiculo
		EndIf
		If !Empty(cCombus) .and. ( aVeicTot[ni,12] <> cCombus ) // Verifica Combustivel
			Loop // Pular Veiculo
		EndIf
		If ( cFoto == "0" .and. aVeicTot[ni,10] == "1" ) .or. ( cFoto == "1" .and. aVeicTot[ni,10] <> "1" ) // Verifica se existe Fotos para o Veiculo
			Loop // Pular Veiculo
		EndIf
		If ( cPromoc == "0" .and. aVeicTot[ni,25] == "1" ) .or. ( cPromoc == "1" .and. aVeicTot[ni,25] <> "1" ) // Verifica Promocao do Veiculo
			Loop // Pular Veiculo
		EndIf
		If val(aVeicTot[ni,5]) < nPDiasEI .or. val(aVeicTot[ni,5]) > nPDiasEF // Verifica Dias de Estoque Inicial / Final
			Loop // Pular Veiculo
		EndIf
		If !aUFTot[1,3] // Escolheu uma UF
			nj := aScan(aUFTot, {|x| x[3] == .t. }) // UF escolhida
			If !( aVeicTot[ni,3] $ aUFTot[nj,2] )
				Loop // Pular Veiculo
			EndIf
        EndIf		
		If !Empty(cOpcVei) // Verifica Opcionais do Veiculo
			lOk := .t.
			cOpcAux := Alltrim(cOpcVei)
			For nj := 1 to len(cOpcAux)
				nOpcAux := at("/",cOpcAux)
				If nOpcAux <= 0
					nOpcAux := len(cOpcAux)+1
				EndIf
				If !(substr(cOpcAux,1,nOpcAux) $ aVeicTot[ni,13]) // Se nao existir o opcional
					lOk := .f. // Pular Veiculo
					Exit
				EndIf
				cOpcAux := substr(cOpcAux,nOpcAux+1)
				If Empty(cOpcAux)
					Exit
				EndIf
			Next
			If !lOk
				Loop // Pular Veiculo
			EndIf
		EndIf
		If !Empty(cCfgVei) .and. !FS_CfgContem(aVeicTot[ni],cCfgVei)
			Loop // Pular Veiculo
		EndIf
		aAdd(aVeicVer,aClone(aVeicTot[ni])) // Veiculos a serem visualizados
	Next
EndIf
If len(aVeicVer) <= 0
	FS_ADDVET("aVeicVer") // Adiciona linha em branco no Vetor
EndIf
// Ordem ListBox de Veiculos: Decrescente ( Dias Carencia - Dias Estoque ) + Crescente ( Marca + Modelo )
Asort(aVeicVer,,,{|x,y| strzero(9999999999-val(strzero(999999-(x[22]-Val(x[5])),10)),10)+x[6]+x[7] < strzero(9999999999-val(strzero(999999-(y[22]-Val(y[5])),10)),10)+y[6]+y[7] })
If ExistBlock("PEVM011OSV") // Ponto de Entrada que Ordena a Selecao do Veiculo
	ExecBlock("PEVM011OSV",.f.,.f.)
EndIf
oLbVeic:nAt := 1
oLbVeic:SetArray(aVeicVer)
oLbVeic:Refresh()
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TOTFILT ³ Autor ³ Andre Luis Almeida  ³ Data ³ 11/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Todos Filtros - Vetor dos Veiculos                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TOTFILT()
Local ni        := 0
Local aRet      := {}
Local aParamBox := {}
aAdd(aParamBox,{2,STR0017,cFilVV1,aFilVV1,70,"",.f.,"Empty(MV_PAR02)"}) 				// 01 - Loja
aAdd(aParamBox,{2,STR0095,cUFFiltro,aUFFiltro,30,"",.f.,"Empty(MV_PAR01)"}) 			// 02 - UF Lojas
aAdd(aParamBox,{1,STR0096,nPDiasEI,"@E 99,999","MV_PAR03>=0","",".T.",30,.f.}) 			// 03 - Dias De
aAdd(aParamBox,{1,STR0097,nPDiasEF,"@E 99,999","MV_PAR04>=0","",".T.",30,.f.})	 		// 04 - Dias Ate
aAdd(aParamBox,{2,STR0018,cTipVei,aTipVei,50,"",.f.,"lTipVei"}) 						// 05 - Tipo
aAdd(aParamBox,{1,STR0019,cAnoIni,"@R 9999","","",".T.",30,.f.}) 						// 06 - Ano Inicial
aAdd(aParamBox,{1,STR0020,cAnoFin,"@R 9999","","",".T.",30,.f.}) 						// 07 - Ano Final
aAdd(aParamBox,{2,STR0021,cCombus,aCombus,70,"",.f.,}) 									// 08 - Combustivel
aAdd(aParamBox,{1,STR0022,nVlrIni,"@E 9,999,999","MV_PAR09>=0","",".T.",50,.f.}) 		// 09 - Valor Inicial
aAdd(aParamBox,{1,STR0023,nVlrFin,"@E 9,999,999","MV_PAR10>=0","",".T.",50,.f.}) 		// 10 - Valor Final
aAdd(aParamBox,{1,STR0024,nKMMaxi,"@E 999,999,999","MV_PAR11>=0","",".T.",50,.f.}) 		// 11 - KM Maxima
aAdd(aParamBox,{2,STR0098,cFoto,aFoto,30,"",.f.,}) 										// 12 - Fotos/Videos
aAdd(aParamBox,{2,STR0072,cPromoc,aPromoc,30,"",.f.,"( len(aPromoc) > 1 )"}) 			// 13 - Promocao
aAdd(aParamBox,{1,STR0025,cOpcVei,VV1->(X3PICTURE("VV1_OPCFAB")),"","",".T.",80,.f.}) 	// 14 - Opcionais
aAdd(aParamBox,{1,STR0088,cCfgVei,"@!","","",".T.",80,.f.}) 							// 15 - Configuracao
If ParamBox(aParamBox,STR0094,@aRet,,,,,,,,.f.) // Filtros
	cFilVV1   := aRet[1]
	cUFFiltro := aRet[2]
	For ni := 1 to len(aUFTot)
		aUFTot[ni,3] := .f.
	Next
	ni := aScan(aUFTot,{|x| x[1] == cUFFiltro }) // UF escolhida
	If ni <= 0
		ni := 1
	Else
		cFilVV1 := ""	
	EndIf
	aUFTot[ni,3] := .t.
	nPDiasEI := aRet[3]
	nPDiasEF := aRet[4]
	cTipVei  := aRet[5]
	cAnoIni  := aRet[6]
	cAnoFin  := aRet[7]
	cCombus  := aRet[8]
	nVlrIni  := aRet[9]
	nVlrFin  := aRet[10]
	nKMMaxi  := aRet[11]
	cFoto    := aRet[12]
	cPromoc  := aRet[13]
	cOpcVei  := aRet[14]
	cCfgVei  := aRet[15]
	lBotAtu := .t.
	FS_CONSVEIC(2)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    FS_CfgContem ³ Autor ³ Vinicius Gati       ³ Data ³ 27/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz uma busca geral da Config do veiculo de acordo com     ³±±
±±³            filtro passado por parametro palavra por palavra           ³±±
±±³            aVeicDt := Array com dados do veiculo                      ³±±
±±³            cBusca  := Conteudo a buscar                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CfgContem(aVeicDt, cBusca)
	Local nLoop     := 1
	Local aPalavras := {} // aPalavras = config
	Local cPalavra  := ""
	Local cConfig   := UPPER(aVeicDt[30])
	aPalavras := STRTOKARR(cBusca, " ")
	For nLoop := 1 to Len(aPalavras)
		cPalavra := aPalavras[nLoop]
		If cPalavra $ cConfig
			Return .t.
		EndIf
	Next
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    FS_TemConfig ³ Autor ³ Vinicius Gati       ³ Data ³ 27/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o chaint possui uma configuracao               ³±±
±±³            aVeicData = Dados do veiculo                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TemConfig(aVeicData)
Local cChaInt  := aVeicData[24]
Local cConfig  := aVeicData[30]
Local lVQ0Conf := ( VQ0->(ColumnPos('VQ0_CONFIG')) > 0 )
Local lVV1Conf := ( VV1->(ColumnPos('VV1_CFGBAS')) > 0 )

If lVQ0Conf .or. lVV1COnf
	If !Empty(cConfig)
		Return .t.
	EndIf
	If lVV1Conf
		nQtdReg := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName('VQE')+" WHERE VQE_FILIAL='"+xFilial('VQE')+"' AND VQE_CHAINT='"+cChaInt+"' AND D_E_L_E_T_=' '")
		If nQtdReg > 0
			Return .t.
		EndIf
	EndIf
EndIf
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PROGRES ³ Autor ³ Andre Luis Almeida   ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta Chamada da Consulta que Visualiza Progresso Veiculos ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PROGRES(lRetVJ1,aVJ1)
Local aVetProg := {} // Consulta Progresso de Veiculos
Local ni       := 0
Local lRet     := .f.
For ni := 1 to len(aMod)
	If aMod[ni,1]
		aAdd(aVetProg,{aMod[ni,2],aMod[ni,4]})
	EndIf
Next
aVJ1 := VEIXC004(aVetProg,lRetVJ1) // Consulta Progresso de Veiculo
If len(aVJ1) > 0
	lRet := .t. 
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CKFiltro³ Autor ³ Andre Luis Almeida   ³ Data ³ 18/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla o TIK/Levantamento no CheckBox                    ³±±
±±³          ³ ( Estoque / Transito / Remessa / Reservado / Consignado )  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CKFiltro(cTip)
Local aAux  := {}
Local cAux1 := ""
Local cAux2 := ""
Local ni    := 0
Local lChamaFiltro := .f.
Do Case
	Case cTip == "EST"
		cAux1 := "N"
		lChamaFiltro := lCkFilEst
	Case cTip == "TRA"
		cAux1 := "T"
		lChamaFiltro := lCkFilTra
	Case cTip == "REM"
		cAux1 := "E"
		lChamaFiltro := lCkFilRem
	Case cTip == "RMS"
		cAux1 := "S"
		lChamaFiltro := lCkFilRMS
	Case cTip == "CON"
		cAux1 := "C"
		lChamaFiltro := lCkFilCon
	Case cTip == "PED"
		cAux1 := "P"
		lChamaFiltro := lCkFilPed
	Case cTip == "NOR"
		cAux2 := "N"
		lChamaFiltro := lCkFilNor
	Case cTip == "RES"
		cAux2 := "R"
		lChamaFiltro := lCkFilRes
	Case cTip == "BLO"
		cAux2 := "B"
		lChamaFiltro := lCkFilBlo
EndCase
lBotAtu := .t.
If lChamaFiltro // Chama o Filtro Novamente
	FS_CONSVEIC(2)
Else // Retirar do Vetor
	For ni := 1 to len(aVeicVer)
		If ( !Empty(cAux1) .and. cAux1 # aVeicVer[ni,01] ) .or. ( !Empty(cAux2) .and. cAux2 # aVeicVer[ni,02] )
			aAdd(aAux,aClone(aVeicVer[ni])) // Veiculos a serem visualizados
		EndIf
	Next
	aVeicTot := aClone(aAux) // Vetor Atualizado
	aVeicVer := aClone(aAux) // Vetor Atualizado
	FS_FILTVETOR()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQCHASSI³ Autor ³ Andre Luis Almeida ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa Veiculo ( Chassi / Placa / ... )                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PESQCHASSI(cNumAte)
Local cErro     := ""
Local lOk       := .f.
Local oVeiculos := DMS_Veiculo():New()

If !Empty(cChassi)
	If FG_POSVEI("cChassi",) // Pesquisa/Posicona no VV1
		lOk := .t.

		If !( VV1->VV1_SITVEI $ "0/2/3/4/8" )
			lOk := .f.
			cErro := "- "+STR0064 // Status invalido
			cErro += " ( "+Alltrim(X3CBOXDESC("VV1_SITVEI",VV1->VV1_SITVEI))+" )"
		EndIf

		If !lOk
			MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV1->VV1_CHASSI+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cErro,STR0050) // Veiculo nao pode ser selecionado! / Atencao
		Else
			VAI->(Dbsetorder(4))
			VAI->(DbSeek(xFilial("VAI")+__cUserID))

			If !Empty(VAI->VAI_ESTVEI) .and. VAI->VAI_ESTVEI <> "2" // Usuario somente pode vender 0-Novo ou 1-Usado
				If VV1->VV1_ESTVEI <> VAI->VAI_ESTVEI
					lOk := .f.
					cErro := "- "+STR0010 // Estado do Veiculo
				EndIf
			EndIf

			If !Empty(VAI->VAI_TIPVEI) .and. VAI->VAI_TIPVEI <> "0" // Tipo do Veiculo (Normal/Taxi/Frotista)
				If VV1->VV1_TIPVEI <> VAI->VAI_TIPVEI
					lOk := .f.
					cErro := "- "+STR0068 // Tipo do Veiculo
				EndIf
			EndIf

			If !lOk
				MsgStop(STR0069+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV1->VV1_CHASSI+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cErro,STR0050) // Usuario nao permitido para utilizar esse veiculo! / Atencao
			EndIf
		EndIf

		// Desconsiderar Chassi Bloqueado
		If oVeiculos:Bloqueado("", cChassi)
			lOk := .f. // A mensagem já é exibida dentro da função Bloqueado()
		EndIf
	Else
		MsgStop(STR0070+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cChassi,STR0050) // Veiculo nao encontrado! / Atencao
	EndIf

	FS_ESTVEI(.t.) // Limpa Filtros da Tela

	If lOk
		aVeicTot := {}
		FS_ADDVET("aVeicTot") // Adiciona linha em branco no Vetor
		aVeicTot[01,09] := FGX_VLRSUGV( VV1->VV1_CHAINT , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV1->VV1_SEGMOD , VV1->VV1_CORVEI , .t. , cCdCliAt , cLjCliAt )
		aVeicTot[01,14] := VV1->VV1_CHASSI
		aVeicTot[01,24] := VV1->VV1_CHAINT
		aVeicTot[01,26] := .T.

		lOk := VEIXX012(1,,aVeicTot[01,24],,cNumAte) // Validar se o Veiculo pode ser utilizado
		If lOk
			aVeicVer := aClone(aVeicTot)
		EndIf
	EndIf

	If !lOk
		oChassi:SetFocus()
	EndIf
EndIf

cChassi := space(TamSX3("VV1_CHASSI")[1])
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_BONUS    ³ Autor ³ Andre Luis Almeida ³ Data ³ 10/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Bonus do Veiculo                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BONUS(nLinhaVet)
Local aBonVei    := {}
Local lBonusVeic := .f.
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeAut  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam   := 0
Private oOkBon  := LoadBitmap( GetResources(), "LBTIK" )
Private oNoBon  := LoadBitmap( GetResources(), "LBNO" )
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
If VAI->(ColumnPos("VAI_BONUSV")) > 0
	If VAI->VAI_BONUSV <> "2" // Bonus - Visualiza
		lBonusVeic := .t.
	EndIf
Else
	If VAI->VAI_TIPTEC <= "3"  // 1=Diretor;2=Gerente;3=Supervisor
		lBonusVeic := .t.
	EndIf
EndIf
If lBonusVeic
	VV1->(DbSetOrder(1))
	VV1->(DbSeek( xFilial("VV1") + aVeicVer[nLinhaVet,24] ))
	VV2->(DbSetOrder(1))
	VV2->(DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI ))
    //
	FGX_BONVEI(VV1->VV1_CHAINT,VV1->VV1_CODMAR,VV1->VV1_MODVEI,,,,VV1->VV1_ESTVEI,VV2->VV2_GRUMOD,dDataBase,,@aBonVei,"","1",dDataBase,,.f.)
    //
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 0, 0 , .T. , .T. } )  	//list box
	// Fator de reducao de 0.8
	For nCntTam := 1 to Len(aSizeAut)
		aSizeAut[nCntTam] := INT(aSizeAut[nCntTam] * 0.8)
	Next
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosB := MsObjSize (aInfo, aObjects,.F.)
	DEFINE MSDIALOG oBonVeic FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE (STR0078+": "+Alltrim(VV1->VV1_CHASSI)+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Bonus do Veiculo
	oBonVeic:lEscClose := .F.
	@ aPosB[1,1]+003,aPosB[1,2] LISTBOX oLstVei FIELDS HEADER " ",STR0076,STR0054,STR0057,STR0058,STR0059 COLSIZES ; // Bonus / Bonus Vigente / Bonus Utilizado / Tipo do Bonus
	10,60,50,50,50,100 SIZE aPosB[1,4]-2,aPosB[1,3]-aPosB[1,1]+3 OF oBonVeic PIXEL
	oLstVei:SetArray(aBonVei)
	oLstVei:bLine := { || { IIf(aBonVei[oLstVei:nAt,01]=="1" .or. aBonVei[oLstVei:nAt,01]=="2" ,oOkBon,oNoBon),;
							aBonVei[oLstVei:nAt,05],;
							FG_AlinVlrs(Transform(aBonVei[oLstVei:nAt,03],"@E 999,999,999.99")) ,;
							FG_AlinVlrs(Transform(aBonVei[oLstVei:nAt,06],"@E 999,999,999.99")) ,;
							X3CBOXDESC("VZQ_TIPBON",aBonVei[oLstVei:nAt,04]) ,;
							aBonVei[oLstVei:nAt,07] }}
	ACTIVATE MSDIALOG oBonVeic ON INIT EnchoiceBar(oBonVeic,{|| oBonVeic:End() },{|| oBonVeic:End() } ) CENTER
Else
	MsgStop(STR0053,STR0050) // Usuario sem permissao para Visualizar o Bonus do Veiculo / Atencao
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DOCTO    ³ Autor ³ Andre Luis Almeida ³ Data ³ 10/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Banco de Conhecimento ( Documentos ... )                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DOCTO(nLinhaVet)
If !lAtend // Chamada diretamento do MENU
	Private	aRotina := {{ " " ," " , 0, 1},;	// Pesquisar
						{ " " ," " , 0, 2},;	// Visualizar
						{ " " ," " , 0, 3},;	// Incluir
						{ " " ," " , 0, 4},;	// Alterar
						{ " " ," " , 0, 5} }	// Excluir
Endif
VV1->(DbSetOrder(1))
VV1->(DbSeek( xFilial("VV1") + aVeicVer[nLinhaVet,24] ))
FGX_MSDOC("VV1",VV1->(RecNo()),4)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ORDVET   ³ Autor ³ Andre Luis Almeida ³ Data ³ 25/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ordenar vetores ( Marcas / Grupo Modelo / Modelos / Cores )³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ORDVET(nCol,nTp)
Local nPri := nCol // Ordem Primeira
Local nSeg := nCol // Ordem Segunda
Do Case
	Case nTp == 1 // Marca
		If nPri == 2
			nSeg := 3
		Else
			nSeg := 2
		EndIf
		Asort(aMar,,,{|x,y| x[nPri]+x[nSeg] < y[nPri]+y[nSeg] })
		oLbMar:Refresh()
	Case nTp == 2 // Grupo do Modelo
		If nPri == 2
			nSeg := 4
		Else
			nPri := 4
			nSeg := 2
		EndIf
		Asort(aGru,,,{|x,y| x[nPri]+x[nSeg] < y[nPri]+y[nSeg] })
		oLbGru:Refresh()
	Case nTp == 3 // Modelo
		If nPri == 2
			nSeg := 5
		Else
			nPri := 5
			nSeg := 2
		EndIf
		Asort(aMod,,,{|x,y| x[nPri]+x[nSeg] < y[nPri]+y[nSeg] })
		oLbMod:Refresh()
	Case nTp == 4 // Cor
		If nPri == 2
			nSeg := 4
		Else
			nPri := 4
			nSeg := 2
		EndIf
		Asort(aCor,,,{|x,y| x[nPri]+x[nSeg] < y[nPri]+y[nSeg] })
		oLbCor:Refresh()
EndCase
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXC001F12   ³ Autor ³ Andre Luis Almeida ³ Data ³ 27/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ F12 da rotina colunas a serem exibidas                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXC001F12(lMostra,cNumAte,nQtdVei)
Local aObjects    := {} , aPos := {} , aInfo := {} 
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local ni          := 0
Local ny          := 0
Local nPos        := 0
Local cABC        := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
Local aOrdens     := {}
Local cF12Col     := "04/05/06/07/08/09/10/11/12/13/14/15/16/17/18/19/20/21/22/23/24/25/" // Default
Local aF12Tot     := {} // F12 Total colunas default
Local lTemSX6     := .f. // Existe SX6 ?
Local lAtuSX6     := .f. // Atualiza SX6 ?
Private aF12NCol  := {} // F12 Parcial colunas nao selecionadas
Private aF12Col   := {} // F12 Parcial colunas selecionadas
//
If GetMv("MV_MIL0021",.T.,) // Caso exista o parametro MV_MIL0021
	lTemSX6 := .t.
	cF12Col := GetMv("MV_MIL0021") // Pegar o conteudo do parametro
Else
	/////////////////////////////////////////////
	// Criacao do PARAMETRO - Controle Interno //
	/////////////////////////////////////////////
	DbSelectArea("SX6")
	RecLock( "SX6",.T. )
	SX6->X6_FIL     := xFilial( "SX6" )
	SX6->X6_VAR     := "MV_MIL0021"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := STR0085 // Colunas utilizadas na Consulta de Veiculos
	SX6->X6_DESC1   := ""
	SX6->X6_DESC2   := ""
	SX6->X6_DSCSPA  := STR0085 // Colunas utilizadas na Consulta de Veiculos
	SX6->X6_DSCSPA1 := ""
	SX6->X6_DSCSPA2 := ""
	SX6->X6_DSCENG  := STR0085 // Colunas utilizadas na Consulta de Veiculos
	SX6->X6_DSCENG1 := ""
	SX6->X6_DSCENG2 := ""
	SX6->X6_CONTEUD := cF12Col
	SX6->X6_CONTSPA := cF12Col
	SX6->X6_CONTENG := cF12Col
	MsUnLock()
EndIf
//
aAdd(aF12Tot,{"04",STR0017,{ || aVeicVer[oLbVeic:nAt,03] }                                                    ,"LEFT" , 35}) // Loja 
aAdd(aF12Tot,{"05",STR0028,{ || aVeicVer[oLbVeic:nAt,05] }                                                    ,"LEFT" , 20}) // Dias
aAdd(aF12Tot,{"06",STR0029,{ || aVeicVer[oLbVeic:nAt,06]+" "+aVeicVer[oLbVeic:nAt,07] }                       ,"LEFT" ,100}) // Marca/Modelo
aAdd(aF12Tot,{"07",STR0016,{ || aVeicVer[oLbVeic:nAt,08] }                                                    ,"LEFT" , 30}) // Cor
aAdd(aF12Tot,{"08",STR0030,{ || Transform(aVeicVer[oLbVeic:nAt,09],"@E 9,999,999.99") }                       ,"RIGHT", 43}) // Valor
aAdd(aF12Tot,{"09",STR0076,{ || Transform(aVeicVer[oLbVeic:nAt,27],"@E 9,999,999.99") }                       ,"RIGHT", 33}) // Bonus
aAdd(aF12Tot,{"10",STR0004,{ || " "+IIf(aVeicVer[oLbVeic:nAt,10]<>"1","   ",STR0003) }                        ,"LEFT" , 20}) // Ft-Vd
aAdd(aF12Tot,{"11",STR0072,{ || " "+IIf(aVeicVer[oLbVeic:nAt,25]<>"1","   ",STR0003) }                        ,"LEFT" , 20}) // Promocao
aAdd(aF12Tot,{"12",STR0077,{ || " "+IIf(!aVeicVer[oLbVeic:nAt,28],"   ",STR0003) }                            ,"LEFT" , 20}) // Pago
aAdd(aF12Tot,{"13",STR0031,{ || Transform(aVeicVer[oLbVeic:nAt,11],"@R 9999/9999") }                          ,"LEFT" , 30}) // Fab/Mod
aAdd(aF12Tot,{"14",STR0021,{ || X3CBOXDESC("VV1_COMVEI",aVeicVer[oLbVeic:nAt,12]) }                           ,"LEFT" , 45}) // Combustivel
aAdd(aF12Tot,{"15",STR0032,{ || left(Transform(aVeicVer[oLbVeic:nAt,13],VV1->(x3Picture("VV1_OPCFAB"))),60) } ,"LEFT" , 80}) // Opcionais Fabrica
aAdd(aF12Tot,{"16",STR0033,{ || aVeicVer[oLbVeic:nAt,14] }                                                    ,"LEFT" , 65}) // Chassi
aAdd(aF12Tot,{"17",STR0034,{ || Transform(aVeicVer[oLbVeic:nAt,15],VV1->(x3Picture("VV1_PLAVEI"))) }          ,"LEFT" , 33}) // Placa
aAdd(aF12Tot,{"18",STR0035,{ || Transform(aVeicVer[oLbVeic:nAt,16],"@E 999,999,999") }                        ,"RIGHT", 40}) // KM
aAdd(aF12Tot,{"19",STR0018,{ || X3CBOXDESC("VV1_TIPVEI",aVeicVer[oLbVeic:nAt,17]) }                           ,"LEFT" , 30}) // Tipo
aAdd(aF12Tot,{"20",STR0105,{ || aVeicVer[oLbVeic:nAt,29] }                                                    ,"LEFT" , 35}) // Pedido Fabrica
aAdd(aF12Tot,{"21",STR0036,{ || aVeicVer[oLbVeic:nAt,18] }                                                    ,"LEFT" , 35}) // Prev.Entrega
aAdd(aF12Tot,{"22",STR0037,{ || aVeicVer[oLbVeic:nAt,19] }                                                    ,"LEFT" ,120}) // Observacao
aAdd(aF12Tot,{"23",STR0088,{ || aVeicVer[oLbVeic:nAt,30] }                                                    ,"LEFT", 100}) // Configuracao
aAdd(aF12Tot,{"24",STR0093,{ || aVeicVer[oLbVeic:nAt,31] }                                                    ,"LEFT" , 35}) // Data FDD
aAdd(aF12Tot,{"25",STR0103,{ || aVeicVer[oLbVeic:nAt,32] }                                                    ,"LEFT" , 35}) // Dt.Pedido
//
If ExistBlock("VXC01CPO")
	For ni := 15 to len(cABC)
		For ny := 1 to len(cABC)
			aAdd(aOrdens,substr(cABC,ni,1)+substr(cABC,ny,1))
		Next
	Next
	aVeicCust := ExecBlock("VXC01CPO",.f.,.f.,)
	For ni := 1 to len(aVeicCust)
		aAdd(aF12Tot,{ aOrdens[ni] , aVeicCust[ni,1] , aVeicCust[ni,4] , aVeicCust[ni,2] , aVeicCust[ni,3] }) // Campos Customizados
	Next
EndIf
//
For ni := 1 to len(cF12Col) step 3
	nPos := aScan(aF12Tot,{|x| x[1] == substr(cF12Col,ni,2) })
	If nPos > 0
		aAdd(aF12Col,aClone(aF12Tot[nPos]))
	EndIf
Next
If lMostra .and. lTemSX6
	If len(aF12Col) <= 0
		aAdd(aF12Col,{"X","",{ || .t. } ,"" , 0})
	EndIf
	For ni := 1 to len(aF12Tot)
		nPos := aScan(aF12Col,{|x| x[1] == aF12Tot[ni,1] })
		If nPos <= 0
			aAdd(aF12NCol,aClone(aF12Tot[ni]))
		EndIf
	Next
	If len(aF12NCol) <= 0
		aAdd(aF12NCol,{"X","",{ || .t. } ,"" , 0})
	EndIf
	// Tela tamanho fixo
	aSizeHalf[3] := 310
	aSizeHalf[4] := 230
	aSizeHalf[5] := 620
	aSizeHalf[6] := 475
	aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 0,  0, .T. , .T. } ) // Total
	aPos := MsObjSize( aInfo, aObjects )
	DEFINE MSDIALOG oVXC001F12 TITLE "<F12> "+STR0079 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // <F12> Parametros/Colunas
		oVXC001F12:lEscClose := .F.
		ni := ( aPos[1,4] / 5 )
		//
		@ aPos[1,1]+13,aPos[1,2]+(ni*2)+005 BUTTON oDir PROMPT ">>" OF oVXC001F12 SIZE ni-10,10 PIXEL ACTION FS_F12(">>",aF12Tot)
		@ aPos[1,1]+25,aPos[1,2]+(ni*2)+005 BUTTON oEsq PROMPT "<<" OF oVXC001F12 SIZE ni-10,10 PIXEL ACTION FS_F12("<<",aF12Tot)
		@ aPos[1,1]+37,aPos[1,2]+(ni*2)+005 BUTTON oCim PROMPT "/\" OF oVXC001F12 SIZE ni-10,10 PIXEL ACTION FS_F12("/\",aF12Tot) //"
		@ aPos[1,1]+49,aPos[1,2]+(ni*2)+005 BUTTON oBai PROMPT "\/" OF oVXC001F12 SIZE ni-10,10 PIXEL ACTION FS_F12("\/",aF12Tot) // "
		@ aPos[1,1]+61,aPos[1,2]+(ni*2)+005 BUTTON oDef PROMPT STR0082 OF oVXC001F12 SIZE ni-10,10 PIXEL ACTION FS_F12("*",aF12Tot) // Colunas Default
		//
		@ aPos[1,1]+00,aPos[1,2]+(ni*0) SAY STR0083 SIZE 120,8 OF oVXC001F12 PIXEL COLOR CLR_RED // COLUNAS NAO UTILIZADAS
		@ aPos[1,1]+10,aPos[1,2]+(ni*0) LISTBOX oF12NCol FIELDS HEADER STR0080,STR0081 COLSIZES ni*0.5,ni*1.3 SIZE ni*2,aPos[1,3]-aPos[1,1]-25 OF oVXC001F12 PIXEL // Sequencia / Coluna
		oF12NCol:SetArray(aF12NCol)
		oF12NCol:bLine := { || { IIf(!Empty(aF12NCol[oF12NCol:nAt,2]),Transform(oF12NCol:nAt,"@E 999999999"),"") , aF12NCol[oF12NCol:nAt,2] }}
		//
		@ aPos[1,1]+00,aPos[1,2]+(ni*3) SAY STR0084 SIZE 120,8 OF oVXC001F12 PIXEL COLOR CLR_BLUE // COLUNAS UTILIZADAS
		@ aPos[1,1]+10,aPos[1,2]+(ni*3) LISTBOX oF12Col  FIELDS HEADER STR0080,STR0081 COLSIZES ni*0.5,ni*1.3 SIZE ni*2,aPos[1,3]-aPos[1,1]-25 OF oVXC001F12 PIXEL // Sequencia / Coluna
		oF12Col:SetArray(aF12Col)
		oF12Col:bLine := { || { IIf(!Empty(aF12Col[oF12Col:nAt,2]),Transform(oF12Col:nAt,"@E 999999999"),"") , aF12Col[oF12Col:nAt,2] }}
		//
	ACTIVATE MSDIALOG oVXC001F12 CENTER ON INIT (EnchoiceBar(oVXC001F12,{|| lAtuSX6 := .t. , oVXC001F12:End() },{ || oVXC001F12:End() },,))
	If lAtuSX6
		cF12Col := ""
		// Destruir o objeto
		oLbVeic := Nil
		// Criar novamente o objeto ListBox de Veiculos	
		oLbVeic := TWBrowse():New(aPosP[3,1]-001,aPosP[3,2],(aPosP[3,4]-2),(aPosP[3,3]-aPosP[3,1]+3),,,,oConsVeic,,,,,{ || IIf(lAtend,IIf(!aVeicVer[oLbVeic:nAt,26],IIf(!Empty(aVeicVer[oLbVeic:nAt,24]).and.FS_VALVEI(cNumAte,nQtdVei),(aVeicVer[oLbVeic:nAt,26]:=.t.,IIf(nAVEIMAX==1,(nOpcao:=1,oConsVeic:End()),.t.)),.t.),aVeicVer[oLbVeic:nAt,26]:=.f.),.t.) },,,,,,,.F.,,.T.,,.F.,,,)
		If lAtend
			oLbVeic:addColumn( TCColumn():New( "", { || IIf(aVeicVer[oLbVeic:nAt,26],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
		EndIf
		oLbVeic:addColumn( TCColumn():New( "1", { || IIf(aVeicVer[oLbVeic:nAt,01]=="N",oBran,IIf(aVeicVer[oLbVeic:nAt,01]=="T",oLara,IIf(aVeicVer[oLbVeic:nAt,01]=="E",oPink,IIf(aVeicVer[oLbVeic:nAt,01]=="S",oCinz,IIf(aVeicVer[oLbVeic:nAt,01]=="C",oAzul,IIf(aVeicVer[oLbVeic:nAt,01]=="P",oVerm,oBran)))))) } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor 1
		oLbVeic:addColumn( TCColumn():New( "2", { || IIf(aVeicVer[oLbVeic:nAt,02]=="R",oAmar,IIf(aVeicVer[oLbVeic:nAt,02]=="B",oPret,oBran)) } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Cor 2
		oLbVeic:addColumn( TCColumn():New( "3", { || IIF(FS_TemConfig(aVeicVer[oLbVeic:nAt]), oOkCon, oNoCon) } ,,,,"LEFT" , 08,.T.,.F.,,,,.F.,) ) // Config
		For ni := 1 to len(aF12Col)
			oLbVeic:addColumn( TCColumn():New( aF12Col[ni,2] , aF12Col[ni,3] ,,,, aF12Col[ni,4] , aF12Col[ni,5] ,.F.,.F.,,,,.F.,) )
			cF12Col += aF12Col[ni,1]+"/" // carregar colunas para gravar no parametro
		Next
		oLbVeic:nAT := 1
		oLbVeic:SetArray(aVeicVer)
		oLbVeic:SetFocus()
		oLbVeic:Refresh()
		//
		PutMv("MV_MIL0021",cF12Col) // Gravar selecao das COLUNAS
		//
	EndIf
	//
EndIf
//
Return aF12Col

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MOSTRACFG³ Autor ³ Andre Vinicius Gati³ Data ³ 27/11/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar do F10 da rotina ( colunas ) do ListBox    ³±±
±±³            Mostra tela com detalhes da configuracao do veiculo        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MOSTRACFG()
	If VALTYPE(oLbVeic) == "O"
		If LEN(aVeicVer) > 0 .AND. oLbVeic:nAt > 0
			aEl     := aVeicVer[oLbVeic:nAt]
			cChaInt := aEl[24]
			VA380CFGVEI(cChaInt)
		EndIf
	EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_F12      ³ Autor ³ Andre Luis Almeida ³ Data ³ 27/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar do F12 da rotina ( colunas ) do ListBox    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_F12(cTp,aF12Tot)
Local aAux := {}
Do Case
	Case cTp == ">>"
		If aF12NCol[oF12NCol:nAt,1] <> "X"
			If aF12Col[oF12Col:nAt,1] == "X"
				aF12Col := {}
			EndIf
			aAdd(aF12Col,aClone(aF12NCol[oF12NCol:nAt]))
			aDel(aF12NCol,oF12NCol:nAt)
			aSize(aF12NCol,Len(aF12NCol)-1)
		EndIf
	Case cTp == "<<"
		If aF12Col[oF12Col:nAt,1] <> "X"
			If aF12NCol[oF12NCol:nAt,1] == "X"
				aF12NCol := {}
			EndIf
			aAdd(aF12NCol,aClone(aF12Col[oF12Col:nAt]))
			aDel(aF12Col,oF12Col:nAt)
			aSize(aF12Col,Len(aF12Col)-1)
		EndIf
	Case cTp == "/\"
		If oF12Col:nAt > 1
			aAux := aClone(aF12Col[oF12Col:nAt-1])
			aF12Col[oF12Col:nAt-1] := aClone(aF12Col[oF12Col:nAt])
			aF12Col[oF12Col:nAt]   := aClone(aAux)
			oF12Col:nAt--
		EndIf
	Case cTp == "\/"
		If oF12Col:nAt < len(aF12Col)
			aAux := aClone(aF12Col[oF12Col:nAt+1])
			aF12Col[oF12Col:nAt+1] := aClone(aF12Col[oF12Col:nAt])
			aF12Col[oF12Col:nAt]   := aClone(aAux)
			oF12Col:nAt++
		EndIf
	Case cTp == "*"
		aF12NCol     := {}
		oF12NCol:nAt := 1
		aF12Col      := aClone(aF12Tot)
		oF12Col:nAt  := 1
EndCase
If len(aF12NCol) <= 0
	aAdd(aF12NCol,{"X","",{ || .t. } ,"" , 0})
EndIf
If len(aF12Col) <= 0
	aAdd(aF12Col,{"X","",{ || .t. } ,"" , 0})
EndIf
oF12NCol:SetArray(aF12NCol)
oF12NCol:bLine := { || { IIf(!Empty(aF12NCol[oF12NCol:nAt,2]),Transform(oF12NCol:nAt,"@E 999999999"),"") , aF12NCol[oF12NCol:nAt,2] }}
oF12NCol:Refresh()
oF12Col:SetArray(aF12Col)
oF12Col:bLine := { || { IIf(!Empty(aF12Col[oF12Col:nAt,2]),Transform(oF12Col:nAt,"@E 999999999"),"") , aF12Col[oF12Col:nAt,2] }}
oF12Col:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXC001TOT   ³ Autor ³ Andre Luis Almeida ³ Data ³ 23/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totais / Impressao                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXC001TOT()
Local aObjects   := {} , aPos := {} , aInfo := {} 
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aVXC001TOT := {}
Local ni         := 0
Local nLin       := 0
Local nCol       := 0
// Tela tamanho fixo
aSizeHalf[3] := 305
aSizeHalf[4] := 122
aSizeHalf[5] := 610
aSizeHalf[6] := 242
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Total
aPos := MsObjSize( aInfo, aObjects )
//
aAdd(aVXC001TOT,{X3CBOXDESC("VV1_ESTVEI",left(cEstVei,1)),0,0,0,0,(lCkFilEst.or.lCkFilTra.or.lCkFilRem.or.lCkFilRMS.or.lCkFilCon.or.lCkFilPed)	,(lCkFilNor)				,(lCkFilRes)				,(lCkFilBlo)			 	}) // Total Geral
aAdd(aVXC001TOT,{space(5)+"- "+STR0039,0,0,0,0,(lCkFilEst)	 																		,(lCkFilEst.and.lCkFilNor)	,(lCkFilEst.and.lCkFilRes)	,(lCkFilEst.and.lCkFilBlo)	}) // Estoque
aAdd(aVXC001TOT,{space(5)+"- "+STR0040,0,0,0,0,(lCkFilTra)																			,(lCkFilTra.and.lCkFilNor)	,(lCkFilTra.and.lCkFilRes)	,(lCkFilTra.and.lCkFilBlo)	}) // Em Transito
aAdd(aVXC001TOT,{space(5)+"- "+STR0041,0,0,0,0,(lCkFilRem)																			,(lCkFilRem.and.lCkFilNor)	,(lCkFilRem.and.lCkFilRes)	,(lCkFilRem.and.lCkFilBlo)	}) // Remessa Entrada
aAdd(aVXC001TOT,{space(5)+"- "+STR0099,0,0,0,0,(lCkFilRMS)																			,(lCkFilRMS.and.lCkFilNor)	,(lCkFilRMS.and.lCkFilRes)	,(lCkFilRMS.and.lCkFilBlo)	}) // Remessa Saida
aAdd(aVXC001TOT,{space(5)+"- "+STR0042,0,0,0,0,(lCkFilCon)																			,(lCkFilCon.and.lCkFilNor)	,(lCkFilCon.and.lCkFilRes)	,(lCkFilCon.and.lCkFilBlo)	}) // Consignado
aAdd(aVXC001TOT,{space(5)+"- "+STR0105,0,0,0,0,(lCkFilPed)																			,(lCkFilPed.and.lCkFilNor)	,(lCkFilPed.and.lCkFilRes)	,(lCkFilPed.and.lCkFilBlo)	}) // Pedido Fabrica
If !Empty(aVeicVer[1,06])
	For ni := 1 to len(aVeicVer)
		nLin := 2
		nCol := 3
		Do Case
			Case aVeicVer[ni,01] == "T" // Transito
				nLin := 3 
			Case aVeicVer[ni,01] == "E" // Remessa Entrada
				nLin := 4
			Case aVeicVer[ni,01] == "S" // Remessa Saida
				nLin := 5
			Case aVeicVer[ni,01] == "C" // Consignado
				nLin := 6
			Case aVeicVer[ni,01] == "P" // Pedido
				nLin := 7
		EndCase
		Do Case
			Case aVeicVer[ni,02] == "R" // Reservado
				nCol := 4 
			Case aVeicVer[ni,02] == "B" // Bloqueado
				nCol := 5
		EndCase
		aVXC001TOT[0001,0002]++ // Total Geral
		aVXC001TOT[nLin,0002]++ // Total da Linha
		aVXC001TOT[0001,nCol]++ // Total da Coluna
		aVXC001TOT[nLin,nCol]++ // Linha / Coluna
	Next
EndIf
//
DEFINE MSDIALOG oVXC001TOT TITLE "<F11> "+STR0087 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // <F11> Totais
	@ aPos[1,1],aPos[1,2] LISTBOX oF11Lbx FIELDS HEADER STR0001,STR0086,STR0044,STR0045,STR0046 COLSIZES 80,45,45,45,45 SIZE aPos[1,4],aPos[1,3]-aPos[1,1] OF oVXC001TOT PIXEL
	oF11Lbx:SetArray(aVXC001TOT)
	oF11Lbx:bLine := { || { aVXC001TOT[oF11Lbx:nAt,1] , ;
							IIf(aVXC001TOT[oF11Lbx:nAt,6],Transform(aVXC001TOT[oF11Lbx:nAt,2],"@E 999999999999"),"") , ;
							IIf(aVXC001TOT[oF11Lbx:nAt,7],Transform(aVXC001TOT[oF11Lbx:nAt,3],"@E 999999999999"),"") , ;
							IIf(aVXC001TOT[oF11Lbx:nAt,8],Transform(aVXC001TOT[oF11Lbx:nAt,4],"@E 999999999999"),"") , ;
							IIf(aVXC001TOT[oF11Lbx:nAt,9],Transform(aVXC001TOT[oF11Lbx:nAt,5],"@E 999999999999"),"") }}
ACTIVATE MSDIALOG oVXC001TOT CENTER ON INIT (EnchoiceBar(oVXC001TOT,{|| oVXC001TOT:End() },{ || oVXC001TOT:End() },,))
//
Return

/*/{Protheus.doc} VC001LEG

	@author       Vinicius Gati
	@since        01/04/2014
	@description  Mostra a legenda dos status dos movimentos de estoque

/*/
Static Function VC001LEG()
	Local aLegenda := {          ;
		{"LBTIK"        , STR0092 },; // Selecionado
		{"LBNO"         , STR0091 },; // Não Selecionado
		{'',"----------------------------------------------"},;
		{''             ,"1 - " + STR0038 },; // Fisica
		{"BR_BRANCO"    , STR0039 },; //Estoque
		{"BR_LARANJA"   , STR0040 },; //Em Transito
		{"BR_PINK"      , STR0041 },; //Remessa Entrada
		{"BR_CINZA"     , STR0099 },; //Remessa Saida
		{"BR_AZUL"      , STR0042 },; //Consignado
		{"BR_VERMELHO"  , STR0105 },; //Pedido Fabrica
		{'',"----------------------------------------------"},;
		{''             ,"2 - " + STR0043 },; // Comercial
		{"BR_BRANCO"    , STR0044 },; //Normal
		{"BR_AMARELO"   , STR0045 },; //Reservados
		{"BR_PRETO"     , STR0046 },; //Bloqueados
		{'',"----------------------------------------------"},;
		{''             ,"3 - " + STR0088 },; // Configuração
		{"AVGOIC1"      , STR0089 } } //Possui Configuração
	BrwLegenda( STR0090, STR0090, aLegenda ) // Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_POSLBX ³ Autor ³ Andre Luis Almeida   ³ Data ³ 11/04/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posicionamento nos ListBox ( conforme digitacao )          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_POSLBX(nTp,nCol,nKey)
Local nAux     := 0
Local nPos     := 0
Local cKey     := UPPER(CHR(nKey))
///////////////////////
// Controle do Tempo //
///////////////////////
Local cTimeNow := Time() // 12:45:78 // hh:mm:ss
Local cNroNow  := ( substr(cTimeNow,1,2) + substr(cTimeNow,4,2) + substr(cTimeNow,7,2) ) // 124578 ( 12:45:78 - hh:mm:ss )
Local cNroDig  := ( substr(cTimeDig,1,2) + substr(cTimeDig,4,2) + substr(cTimeDig,7,2) ) // 124578 ( 12:45:78 - hh:mm:ss )
If cTimeDig == cTimeNow .or. ( val(cNroNow)-val(cNroDig) <= 1 )
	aPesq[nTp] += cKey // Incrementa
Else
	aPesq[nTp] := cKey // Inicia
EndIf
cTimeDig := cTimeNow // Inserir o Time na variavel de controle
//
Do Case
	Case nTp == 1 // Marca do Veiculo (Montadora)
		nCol := IIf(nCol<=2,2,3)
		nAux := IIf(nCol<=2,3,2)
		Asort(aMar,,,{|x,y| x[nCol]+x[nAux] < y[nCol]+y[nAux] })
		oLbMar:Refresh()
		If (nPos := aScan(aMar, {|x| SUBSTR(x[nCol],1,len(aPesq[nTp])) == aPesq[nTp] } )) > 0
			oLbMar:goPosition(nPos)
		Else
			aPesq[nTp] := left(aPesq[nTp],len(aPesq[nTp])-1)
		EndIf
	Case nTp == 2 // Grupo do Modelo do Veiculo
		nCol := IIf(nCol<=2,2,4)
		nAux := IIf(nCol<=2,4,2)
		Asort(aGru,,,{|x,y| x[nCol]+x[nAux] < y[nCol]+y[nAux] })
		oLbGru:Refresh()
		If (nPos := aScan(aGru, {|x| SUBSTR(x[nCol],1,len(aPesq[nTp])) == aPesq[nTp] } )) > 0
			oLbGru:goPosition(nPos)
		Else
			aPesq[nTp] := left(aPesq[nTp],len(aPesq[nTp])-1)
		EndIf
	Case nTp == 3 // Modelo do Veiculo
		nCol := IIf(nCol<=2,2,5)
		nAux := IIf(nCol<=2,5,2)
		Asort(aMod,,,{|x,y| x[nCol]+x[nAux] < y[nCol]+y[nAux] })
		oLbMod:Refresh()
		If (nPos := aScan(aMod, {|x| SUBSTR(x[nCol],1,len(aPesq[nTp])) == aPesq[nTp] } )) > 0
			oLbMod:goPosition(nPos)
		Else
			aPesq[nTp] := left(aPesq[nTp],len(aPesq[nTp])-1)
		EndIf
	Case nTp == 4 // Cor
		nCol := IIf(nCol<=2,2,4)
		nAux := IIf(nCol<=2,4,2)
		Asort(aCor,,,{|x,y| x[nCol]+x[nAux] < y[nCol]+y[nAux] })
		oLbCor:Refresh()
		If (nPos := aScan(aCor, {|x| SUBSTR(x[nCol],1,len(aPesq[nTp])) == aPesq[nTp] } )) > 0
			oLbCor:goPosition(nPos)
		Else
			aPesq[nTp] := left(aPesq[nTp],len(aPesq[nTp])-1)
		EndIf	
EndCase
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ADDVET ³ Autor ³ Andre Luis Almeida   ³ Data ³ 14/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona Linha em branco no Vetor de Veiculos              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ADDVET(cVet)
aAdd(&(cVet),{"N","N"," "," "," "," "," "," ",0," "," "," "," "," "," ",0," "," "," "," "," ",0," "," ","",.f.,0,.f.,"","","",""}) // 32 colunas
Return()


Static Function FS_AddRetFiltro(aRetFiltro)
	aAdd(aRetFiltro,{"","","","","","","","1",0,""})
Return
