// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "VEICC640.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICC640 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 22/01/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ CEV - Desempenho                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC640(cPAREmp,aPAREmp,dPARDtI,dPARDtF,cPARVen,cPARCCl,cPARLCl,cPARTip,nPARDia)
Local lDClik      := .f.
Local aFWArrFilAtu:= FWArrFilAtu()
Local aObjects    := {} , aInfo := {}, aPos := {}
Local aSizeHalf   := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private lMarcar   := .f.
Private aVisitas  := {}
Private aClientes := {}
Private aCliAux   := {}
Private aVetEmp   := {}
Private aEmpr     := {} // Empresas Consolidadas
Private cEmpr     := "" // Nome da Empresa
Private dDatIni   := (dDataBase+1)-(day(dDataBase))
Private dDatFin   := dDataBase
Private cVended   := space(SA3->(TamSX3("A3_COD")[1]))
Private cCodCli   := space(SA1->(TamSX3("A1_COD")[1]))
Private cLojCli   := space(SA1->(TamSX3("A1_LOJA")[1]))
Private cCEVTip   := "3"
Private aCEVTip   := {"1="+STR0007,"2="+STR0008,"3="+STR0009} // Pecas / Servicos / Veiculos
Private nCEVDia   := 30
Default cPAREmp   := ""
Default aPAREmp   := aEmpr
Default dPARDtI   := dDatIni
Default dPARDtF   := dDatFin
Default cPARVen   := cVended
Default cPARCCl   := cCodCli
Default cPARLCl   := cLojCli
Default cPARTip   := cCEVTip
Default nPARDia   := nCEVDia
aEmpr := aPAREmp
If !Empty(cPAREmp)
	cEmpr := STR0004 //  - Consolidado: 
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0006,STR0005) // Nao existem dados para esta Consulta! / Atencao
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFWArrFilAtu[SM0_FILIAL] })
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,1]==cFilAnt)
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+cFilAnt+" )"
EndIf
dDatIni := dPARDtI // Data Inicial
dDatFin := dPARDtF // Data Final
cVended := cPARVen // Vendedor
cCodCli := cPARCCl // Codigo do Cliente
cLojCli := cPARLCl // Loja do Cliente
cCEVTip := cPARTip // Tipo
nCEVDia := nPARDia // Dias

aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  20 , .T. , .F. } ) // Topo
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox 1 - Analise por Visitas
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox 2 - Analise por Clientes
aPos := MsObjSize( aInfo, aObjects )

Processa( {|| FS_LEVANT(0) } )

DbSelectArea("VC1")

DEFINE MSDIALOG oCEVAgeVis FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) PIXEL OF oMainWnd // CEV - Desempenho Vendedores

@ aPos[2,1]+000,aPos[2,2]+000 LISTBOX oLbVisitas FIELDS HEADER STR0003+" - "+"Analise por Visitas","Total Visitas","Visitas Produtivas","Visitas não Produtivas","Vendas" COLSIZES 140,70,70,70,70 SIZE aPos[2,4]-4,aPos[2,3]-aPos[2,1] OF oCEVAgeVis PIXEL 
oLbVisitas:SetArray(aVisitas)
oLbVisitas:bLine := { || { aVisitas[oLbVisitas:nAt,1]+" - "+aVisitas[oLbVisitas:nAt,2] ,;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,3],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,3]/aVisitas[1,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,4],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,4]/aVisitas[oLbVisitas:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,5],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,5]/aVisitas[oLbVisitas:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,6],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,6]/aVisitas[oLbVisitas:nAt,3])*100,"@E 9999.9")+"%")}} 

@ aPos[3,1]+000,aPos[3,2]+000 LISTBOX oLbClientes FIELDS HEADER STR0003+" - "+"Analise por Clientes","Total Clientes","Visitas Produtivas","Visitas não Produtivas","Vendas" COLSIZES 140,70,70,70,70 SIZE aPos[3,4]-4,aPos[3,3]-aPos[3,1] OF oCEVAgeVis PIXEL
oLbClientes:SetArray(aClientes)
oLbClientes:bLine := { || { aClientes[oLbClientes:nAt,1]+" - "+aClientes[oLbClientes:nAt,2] ,;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,3],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,3]/aClientes[1,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,4],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,4]/aClientes[oLbClientes:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,5],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,5]/aClientes[oLbClientes:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,6],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,6]/aClientes[oLbClientes:nAt,3])*100,"@E 9999.9")+"%")}} 

@ aPos[1,1]+000,aPos[1,2]+002 SAY STR0010 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Periodo
@ aPos[1,1]+008,aPos[1,2]+002 MSGET oDatIni VAR dDatIni PICTURE "@D" SIZE 42,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
@ aPos[1,1]+009,aPos[1,2]+046 SAY STR0011 SIZE 10,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //a
@ aPos[1,1]+008,aPos[1,2]+050 MSGET oDatFin VAR dDatFin PICTURE "@D" VALID ( dDatIni <= dDatFin ) SIZE 42,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+095 SAY STR0003 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Vendedor
@ aPos[1,1]+008,aPos[1,2]+095 MSGET oVended VAR cVended PICTURE "@!" F3 "SA3" SIZE 35,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+133 SAY STR0002 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Cliente
@ aPos[1,1]+008,aPos[1,2]+133 MSGET oCodCli VAR cCodCli PICTURE "@!" F3 "SA1" SIZE 35,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE
@ aPos[1,1]+008,aPos[1,2]+168 MSGET oLojCli VAR cLojCli PICTURE "@!" SIZE 15,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+196 SAY STR0013 SIZE 30,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Tipo
@ aPos[1,1]+008,aPos[1,2]+196 MSCOMBOBOX oCEVTip VAR cCEVTip SIZE 50,08 COLOR CLR_BLACK ITEMS aCEVTip OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+000,aPos[1,2]+249 SAY "Dias para Venda" SIZE 47,08 OF oCEVAgeVis PIXEL COLOR CLR_BLUE //Dias para Venda
@ aPos[1,1]+008,aPos[1,2]+249 MSGET oCEVDia VAR nCEVDia PICTURE "@E 999" VALID ( nCEVDia >= 0 ) SIZE 43,06 OF oCEVAgeVis PIXEL COLOR CLR_BLUE

@ aPos[1,1]+008,aPos[1,2]+295 BUTTON oOk PROMPT STR0015 OF oCEVAgeVis SIZE 18,10 PIXEL ACTION Processa( {|| FS_LEVANT(1) } ) //OK
@ aPos[1,1]+000,aPos[1,4]-090 BUTTON oEmpr PROMPT UPPER(STR0017) OF oCEVAgeVis SIZE 40,09 PIXEL ACTION (lDClik:=.t.,oCEVAgeVis:End())  //Filiais

@ aPos[1,1]+000,aPos[1,4]-045 BUTTON oSair PROMPT STR0012 OF oCEVAgeVis SIZE 40,09 PIXEL ACTION oCEVAgeVis:End() // SAIR
ACTIVATE MSDIALOG oCEVAgeVis CENTER
If lDClik
	VEICC640(cEmpr,aEmpr,dDatIni,dDatFin,cVended,cCodCli,cLojCli,cCEVTip,nCEVDia)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_LEVANT ³ Autor ³  Andre Luis Almeida   ³ Data ³ 23/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levantamento dos Valores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVANT(nTip)
Local cQuery      := ""
Local cQAlias     := "SQLVC1"
Local cQAlSF2     := "SQLSF2"
Local nEmpr       := 0
Local cFilSALVA   := cFilAnt
Local nY          := 0
Local nX          := 0
Local aVendas     := {}
Local cFilSA1     := ""
Local cFilSA3     := ""
Local cFilSF2     := ""
Local lVC1_CONPRO := ( VC1->(FieldPos("VC1_CONPRO")) > 0 )
Local cPrefOri    := ""
If cCEVTIP == "1" // Pecas 
	cPrefOri := Alltrim(GetNewPar("MV_PREFBAL","BAL"))
ElseIf cCEVTIP == "2" // Servicos
	cPrefOri := Alltrim(GetNewPar("MV_PREFOFI","OFI"))
ElseIf cCEVTIP == "3" // Veiculos
	cPrefOri := Alltrim(GetNewPar("MV_PREFVEI","VEI"))
EndIf
//
aVisitas := {}
aAdd(aVisitas,{ STR0014 , "" , 0 , 0 , 0 , 0 , "" }) // Total Geral
//
aCliAux   := {}
aClientes := {}
aAdd(aClientes,{ STR0014 , "" , 0 , 0 , 0 , 0 , "" }) // Total Geral
//
For nEmpr := 1 to len(aEmpr)
	cFilAnt := aEmpr[nEmpr,1]
	cFilSA1 := xFilial("SA1")
	cFilSA3 := xFilial("SA3")
	cFilSF2 := xFilial("SF2")
	cQuery := "SELECT VC1.VC1_DATVIS , VC1.VC1_CODCLI , VC1.VC1_LOJA , VC1.VC1_CODVEN "
	If lVC1_CONPRO
		cQuery += ", VC1.VC1_CONPRO "
	EndIf
	cQuery += "FROM "+RetSqlName("VC1")+" VC1 , "+RetSqlName("VC5")+" VC5 "
	cQuery += "WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
	If !Empty(cCodCli+cLojCli)
		cQuery += "VC1.VC1_CODCLI='"+cCodCli+"' AND VC1.VC1_LOJA='"+cLojCli+"' AND "
	EndIf
	If !Empty(cVended) // Vendedor
		cQuery += "VC1.VC1_CODVEN='"+cVended+"' AND "
	EndIf
	cQuery += "VC1.VC1_DATVIS>='"+dtos(dDatIni)+"' AND VC1.VC1_DATVIS<='"+dtos(dDatFin)+"' AND "
	cQuery += "VC1.D_E_L_E_T_=' ' AND "
	cQuery += "VC5.VC5_FILIAL='"+xFilial("VC5")+"' AND VC5.VC5_TIPAGE=VC1.VC1_TIPAGE AND "
	Do Case
		Case cCEVTIP == "1" // Pecas 
			cQuery += "VC5.VC5_AGEOFI IN ('3','6','7') AND "
		Case cCEVTIP == "2" // Servicos
			cQuery += "VC5.VC5_AGEOFI IN ('1','2') AND "
		Case cCEVTIP == "3" // Veiculos
			cQuery += "VC5.VC5_AGEOFI IN ('4','5') AND "
	EndCase
	cQuery += "VC5.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
	Do While !( cQAlias )->( Eof() )
		nProdS := 0
		nProdN := 0
		If lVC1_CONPRO
			If ( cQAlias )->( VC1_CONPRO ) <> '0'
				nProdS := 1
			Else
				nProdN := 1
			EndIf
		Else
			nProdS := 1
		EndIf
		//
		nY := aScan(aVisitas,{|x| x[7] == cFilSA3 + ( cQAlias )->( VC1_CODVEN ) })
		If nY <= 0		
			aAdd(aVisitas,{ ( cQAlias )->( VC1_CODVEN ) , "" , 0 , 0 , 0 , 0 , cFilSA3 + ( cQAlias )->( VC1_CODVEN ) })
			nY := len(aVisitas)
			aVisitas[nY,2] := left(FM_SQL("SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+cFilSA3+"' AND SA3.A3_COD='"+( cQAlias )->( VC1_CODVEN )+"' AND SA3.D_E_L_E_T_=' '"),20)
			//
			aAdd(aClientes,{ ( cQAlias )->( VC1_CODVEN ) , aVisitas[nY,2] , 0 , 0 , 0 , 0 , cFilSA3 + ( cQAlias )->( VC1_CODVEN ) })
		EndIf
		//
		nX := aScan(aCliAux,{|x| x[1] == cFilSA1 + ( cQAlias )->( VC1_CODCLI ) + ( cQAlias )->( VC1_LOJA ) + cFilSA3 + ( cQAlias )->( VC1_CODVEN ) })
		If nX <= 0
			aAdd(aCliAux,{ cFilSA1 + ( cQAlias )->( VC1_CODCLI ) + ( cQAlias )->( VC1_LOJA ) + cFilSA3 + ( cQAlias )->( VC1_CODVEN ) })
			aClientes[nY,3]++      // Total de Clientes
		EndIf
		//
		aVisitas[nY,3]  += ( nProdS + nProdN ) // Total de Visitas
		aVisitas[nY,4]  += nProdS              // Visitas Produtivas
		aVisitas[nY,5]  += nProdN              // Visitas Nao Produtivas
		//
		aClientes[nY,4] += nProdS              // Visitas Produtivas
		aClientes[nY,5] += nProdN              // Visitas Nao Produtivas
		//
		cQuery := "SELECT SF2.F2_FILIAL , SF2.F2_DOC , SF2.F2_SERIE , SF2." + FGX_MILSNF("SF2", 3, "F2_SERIE") + " "
		cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
		cQuery += "WHERE SF2.F2_FILIAL='"+cFilSF2+"' AND "
		cQuery += "SF2.F2_CLIENTE='"+( cQAlias )->( VC1_CODCLI )+"' AND SF2.F2_LOJA='"+( cQAlias )->( VC1_LOJA )+"' AND "
		cQuery += "SF2.F2_EMISSAO>='"+( cQAlias )->( VC1_DATVIS )+"' AND SF2.F2_EMISSAO<='"+dtos(stod(( cQAlias )->( VC1_DATVIS ))+nCEVDia)+"' AND "
		cQuery += "SF2.F2_PREFORI='"+cPrefOri+"' AND SF2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF2 , .F., .T. )
		Do While !( cQAlSF2 )->( Eof() )
			nX := aScan(aVendas,{|x| x[1] == ( cQAlSF2 )->( F2_FILIAL ) + ( cQAlSF2 )->( F2_DOC ) + ( cQAlSF2 )->( F2_SERIE ) })
			If nX <= 0
				aAdd(aVendas,{ ( cQAlSF2 )->( F2_FILIAL ) + ( cQAlSF2 )->( F2_DOC ) + ( cQAlSF2 )->( F2_SERIE ) })
				aVisitas[nY,6]++
				aClientes[nY,6]++
        	EndIf
			( cQAlSF2 )->( DbSkip() )
		EndDo
		( cQAlSF2 )->( dbCloseArea() )		
		//
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
Next
cFilAnt := cFilSALVA
// Totalizar Visitas e Clientes //
For nY := 1 to len(aVisitas)
	aVisitas[1,3]  += aVisitas[nY,3]  // Total de Visitas
	aVisitas[1,4]  += aVisitas[nY,4]  // Visitas Produtivas
	aVisitas[1,5]  += aVisitas[nY,5]  // Visitas Nao Produtivas
	aClientes[1,3] += aClientes[nY,3] // Total de Clientes
	aClientes[1,4] += aClientes[nY,4] // Visitas Produtivas
	aClientes[1,5] += aClientes[nY,5] // Visitas Nao Produtivas
Next
If nTip # 0
	oLbVisitas:nAt := 1
	oLbVisitas:SetArray(aVisitas)
	oLbVisitas:bLine := { || { aVisitas[oLbVisitas:nAt,1]+" - "+aVisitas[oLbVisitas:nAt,2] ,;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,3],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,3]/aVisitas[1,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,4],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,4]/aVisitas[oLbVisitas:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,5],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,5]/aVisitas[oLbVisitas:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aVisitas[oLbVisitas:nAt,6],"@E 9,999,999"))+FG_AlinVlrs(Transform((aVisitas[oLbVisitas:nAt,6]/aVisitas[oLbVisitas:nAt,3])*100,"@E 9999.9")+"%")}} 
	oLbVisitas:SetFocus()
	oLbVisitas:Refresh()
	//
	oLbClientes:nAt := 1
	oLbClientes:SetArray(aClientes)
	oLbClientes:bLine := { || { aClientes[oLbClientes:nAt,1]+" - "+aClientes[oLbClientes:nAt,2] ,;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,3],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,3]/aClientes[1,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,4],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,4]/aClientes[oLbClientes:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,5],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,5]/aClientes[oLbClientes:nAt,3])*100,"@E 9999.9")+"%"),;
						FG_AlinVlrs(Transform(aClientes[oLbClientes:nAt,6],"@E 9,999,999"))+FG_AlinVlrs(Transform((aClientes[oLbClientes:nAt,6]/aClientes[oLbClientes:nAt,3])*100,"@E 9999.9")+"%")}} 
	oLbClientes:SetFocus()
	oLbClientes:Refresh()
EndIf
cFilAnt := cFilSALVA
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILIAIS³ Autor ³  Andre Luis Almeida   ³ Data ³ 11/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta Filiais                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFWArrFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFWArrFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0017 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0018,STR0019 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIK    ³ Autor ³  Andre Luis Almeida  ³ Data ³ 26/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marcar todas as Filiais                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)
