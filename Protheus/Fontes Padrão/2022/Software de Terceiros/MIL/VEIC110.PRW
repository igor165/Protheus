#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIC110.CH"

/*/{Protheus.doc} VEIC110
	Consulta Dados dos Clientes (SA1/VCF)

	@author Andre Luis Almeida
	@since 13/01/2021
/*/
Function VEIC110( cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli , cPropAg )

Default cGruNeg := "" // Grupo de Negocios
Default cCodCli := "" // Codigo do Cliente
Default cLojCli := "" // Loja do Cliente
Default cRegCli := "" // Regiao do Cliente
Default cMunCli := "" // Codigo do IBGE do Municipio do Cliente
Default cUFMCli := "" // UF do Municipio do Cliente
Default cPropAg := "" // Propriedade Agricola do Cliente

If Empty( cGruNeg + cCodCli + cLojCli + cRegCli + cMunCli + cUFMCli + cPropAg )

	oBrwSA1 := FWMBrowse():New()
	oBrwSA1:SetAlias('SA1')
	oBrwSA1:SetDescription(STR0001) // Clientes
	oBrwSA1:DisableDetails()
	oBrwSA1:SetAmbiente(.F.)
	oBrwSA1:SetWalkthru(.F.)
	oBrwSA1:SetUseFilter()
	oBrwSA1:Activate()

Else

	VC1100011_Visualizar( cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli , cPropAg )

EndIf

Return

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VC1100011_Visualizar( "" , SA1->A1_COD , SA1->A1_LOJA , "" , "" , "" , "" )' OPERATION 2 ACCESS 0 // Visualizar Cliente/Loja
	ADD OPTION aRotina TITLE STR0003 ACTION 'VC1100011_Visualizar( "" , SA1->A1_COD , "" , "" , "" , "" , "" )' OPERATION 2 ACCESS 0 // Visualizar Cliente (todas Lojas)

Return aRotina


/*/{Protheus.doc} VC1100011_Visualizar
	Tela para Visualizar SA1 e VCF por Grupo de Negocios, Cliente, Cliente/Loja, Regiao, Municipio e UF

	@author Andre Luis Almeida
	@since 13/01/2021
/*/
Function VC1100011_Visualizar( cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli , cPropAg )

Local aSize     := FWGetDialogSize( oMainWnd )
Local cTitulo   := ""
Local aClientes := {}
Local aCpoSA1   := {}
Local aCpoVCF   := {}
Local aHeaderTMP:= {}
Local aColsTMP  := {}
Local aNewBot   := {}
Default cGruNeg := ""
Default cCodCli := ""
Default cLojCli := ""
Default cRegCli := ""
Default cMunCli := ""
Default cUFMCli := ""
Default cPropAg := ""

/////////////////////////////////
// Variaveis utilizadas no SX3 //
/////////////////////////////////
Inclui := .f.
Altera := .f.
Exclui := .f.
Visualiza := .t.
/////////////////////////////////

Processa( {|| aClientes := VC1100021_CarregaClientes( cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli , cPropAg ) } , STR0006 , "", .T.) // Processando

If len(aClientes) == 0
	MsgStop(STR0005,STR0004) // Dados do Cliente nao encontrado! / Atencao
	Return
EndIf

Do Case
	Case !Empty(cGruNeg)
		cTitulo += Alltrim(str(len(aClientes)))+" "
		cTitulo += STR0007+": "+cGruNeg+" - " // Clientes do Grupo de Negócio
		cTitulo += Alltrim(left(FM_SQL("SELECT VJW_DESCRI FROM "+RetSQLName("VJW")+" WHERE VJW_FILIAL='"+xFilial("VJW")+"' AND VJW_CODIGO='"+cGruNeg+"' AND D_E_L_E_T_=' '"),30))
	Case !Empty(cCodCli)
		cTitulo += STR0008+": "+cCodCli // Cliente
		If !Empty(cLojCli)
			cTitulo += "-"+cLojCli+" "
			cTitulo += left(FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND A1_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '"),30)
		Else
			cTitulo += " - "+Alltrim(str(len(aClientes)))+" "+STR0014 // loja(s)
		EndIf
	Case !Empty(cRegCli)
		cTitulo += Alltrim(str(len(aClientes)))+" "
		cTitulo += STR0009+": "+Alltrim(cRegCli)+" - " // Clientes da Regiao
		cTitulo += Alltrim(left(FM_SQL("SELECT X5_DESCRI FROM "+RetSQLName("SX5")+" WHERE X5_FILIAL='"+xFilial("SX5")+"' AND X5_TABELA='A2' AND X5_CHAVE='"+cRegCli+"' AND D_E_L_E_T_=' '"),30))
	Case !Empty(cMunCli)
		cTitulo += Alltrim(str(len(aClientes)))+" "
		cTitulo += STR0001+" - " // Clientes
		VAM->(DbSetOrder(1))
		VAM->(Dbseek(xFilial("VAM")+cMunCli))
		cTitulo += Alltrim(left(VAM->VAM_DESCID,30))+" - "+VAM->VAM_ESTADO
	Case !Empty(cUFMCli)
		cTitulo += Alltrim(str(len(aClientes)))+" "
		cTitulo += STR0001+" - "+cUFMCli // Clientes
	Case !Empty(cPropAg)
		cTitulo += Alltrim(str(len(aClientes)))+" "
		cTitulo += STR0010+": "+cPropAg+" - " // Clientes da Prop.Agricola
		cTitulo += Alltrim(left(FM_SQL("SELECT VJY_NOME FROM "+RetSQLName("VJY")+" WHERE VJY_FILIAL='"+xFilial("VJY")+"' AND VJY_CODIGO='"+cPropAg+"' AND D_E_L_E_T_=' '"),30))
EndCase

cCadastro := cTitulo // Titulo PADRÃO da Tela 

AADD(aNewBot, {"RELATORIO",{|| VC1100061_ChamaImpressao( cTitulo , aClientes , aHeaderTMP , aColsTMP , aCpoSA1 , aCpoVCF ) }, STR0011 } ) // Imprimir Dados

oVEIC110 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],cTitulo,,,,128,,,,,.t.)

	If len(aClientes) > 1 // Mais de 1 Cliente - Montar aCols com todos os registros

		aHeaderTMP := VC1100031_CarregaHeader() // SA1 e VCF juntos na mesma aCols
		Processa( {|| aColsTMP := VC1100041_CarregaDados( aClientes , aHeaderTMP ) } , STR0006 , "", .T.) // Processando
		oGetDadTMP := MsNewGetDados():New(0,100,0,100,;
											0 ,; // Somente Visualizar
											/* cLinOk */,;
											/* cTudOk */,;
											,;
											{} ,; 	// Campos alteraveis da GetDados
											/* nFreeze */,;	// Campos estaticos da GetDados
											999 ,;
											/* cFldOk */,;
											/* cSuperDel */,;
											/* cDelOk */,;
											oVEIC110,;
											aHeaderTMP ,;
											aColsTMP)
		oGetDadTMP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	Else // Apenas 1 Cliente

		oWorkArea := FWUIWorkArea():New( oVEIC110 )
		oWorkArea:CreateHorizontalBox( "LINE01", 45 , .f. )
		oWorkArea:SetBoxCols( "LINE01", { "OBJSA1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 45 , .f. )
		oWorkArea:SetBoxCols( "LINE02", { "OBJVCF" } )
		oWorkArea:Activate()

		aCpoSA1 := VC1100051_CarregaCampos( "SA1" )
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") + aClientes[1,1] + aClientes[1,2] )
		RegToMemory("SA1",.F.,.F.)
		oEnchSA1 := MSMGet():New( "SA1" , SA1->(RecNo()) , 2 ,;
			/* aCRA */, /* cLetra */, /* cTexto */, aCpoSA1 , {0,0,(oVEIC110:nClientHeight/4),(oVEIC110:nClientWidth/2)} , {}, 3,;
			/* nColMens */, /* cMensagem */, /*cTudoOk*/, oWorkArea:GetPanel("OBJSA1"), .f., .t., .t. /* lColumn */ ,;
			"", .f. /* lNoFolder */, .f.)
		oEnchSA1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		aCpoVCF := VC1100051_CarregaCampos( "VCF" )
		DbSelectArea("VCF")
		DbSetOrder(1)
		DbSeek( xFilial("VCF") + aClientes[1,1] + aClientes[1,2] )
		RegToMemory("VCF",.F.,.F.)
		oEnchVCF := MSMGet():New( "VCF" , VCF->(RecNo()) , 2 ,;
			/* aCRA */, /* cLetra */, /* cTexto */, aCpoVCF , {0,0,(oVEIC110:nClientHeight/4),(oVEIC110:nClientWidth/2)} , {}, 3,;
			/* nColMens */, /* cMensagem */, /*cTudoOk*/, oWorkArea:GetPanel("OBJVCF"), .f., .t., .t. /* lColumn */ ,;
			"", .f. /* lNoFolder */, .f.)
		oEnchVCF:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	EndIf

oVEIC110:Activate( , , , , , , EnchoiceBar( oVEIC110, { || oVEIC110:End() }, { || oVEIC110:End() }, , aNewBot , , , , , .F., .T. ) ) //ativa a janela

Return

/*/{Protheus.doc} VC1100021_CarregaClientes
	Carrega vetor com os Clientes para serem apresentados na Consulta

	@author Andre Luis Almeida
	@since 13/01/2021
/*/
Static Function VC1100021_CarregaClientes( cGruNeg , cCodCli , cLojCli , cRegCli , cMunCli , cUFMCli , cPropAg )

Local aClientes := {}
Local cQuery    := ""
Local cQAlCli   := "SQLCLIENTES"

Do Case

	Case !Empty(cGruNeg) // Filtrar todos os Clientes do Grupo de Negocio
		cQuery := "SELECT DISTINCT VJX_CODCLI AS CODCLI , VJX_LOJCLI AS LOJCLI "
		cQuery += "  FROM " + RetSqlName("VJX")
		cQuery += " WHERE VJX_FILIAL ='" + xFilial("VJX") + "'"
		cQuery += "   AND VJX_GRUNEG ='" + cGruNeg + "'"
		cQuery += "   AND D_E_L_E_T_=' '"

	Case !Empty(cCodCli) // Filtrar todas as Propriedades Agricolas de um determinado Cliente
		cQuery := "SELECT A1_COD AS CODCLI , A1_LOJA AS LOJCLI "
		cQuery += "  FROM " + RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL ='" + xFilial("SA1") + "'"
		cQuery += "   AND A1_COD ='" + cCodCli + "'"
		If !Empty(cLojCli)
			cQuery += "   AND A1_LOJA ='" + cLojCli + "'"
		EndIf
		cQuery += "   AND D_E_L_E_T_=' '"
	
	Case !Empty(cRegCli)
		cQuery := "SELECT A1_COD AS CODCLI , A1_LOJA AS LOJCLI "
		cQuery += "  FROM " + RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL ='" + xFilial("SA1") + "'"
		cQuery += "   AND A1_REGIAO ='" + cRegCli + "'"
		cQuery += "   AND D_E_L_E_T_=' '"
	
	Case !Empty(cMunCli)
		cQuery := "SELECT A1_COD AS CODCLI , A1_LOJA AS LOJCLI "
		cQuery += "  FROM " + RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL ='" + xFilial("SA1") + "'"
		cQuery += "   AND A1_IBGE ='" + cMunCli + "'"
		cQuery += "   AND D_E_L_E_T_=' '"
	
	Case !Empty(cUFMCli)
		cQuery := "SELECT A1_COD AS CODCLI , A1_LOJA AS LOJCLI "
		cQuery += "  FROM " + RetSqlName("SA1")
		cQuery += " WHERE A1_FILIAL ='" + xFilial("SA1") + "'"
		cQuery += "   AND A1_EST ='" + cUFMCli + "'"
		cQuery += "   AND D_E_L_E_T_=' '"

	Case !Empty(cPropAg)
		cQuery := "SELECT DISTINCT VJZ_CODCLI AS CODCLI , VJZ_LOJCLI AS LOJCLI "
		cQuery += "  FROM " + RetSqlName("VJZ")
		cQuery += " WHERE VJZ_FILIAL ='" + xFilial("VJZ") + "'"
		cQuery += "   AND VJZ_PROAGR ='" + cPropAg + "'"
		cQuery += "   AND D_E_L_E_T_=' '"

EndCase

If !Empty(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlCli, .F., .T. )
	ProcRegua((cQAlCli)->(RecCount()))
	While !((cQAlCli)->(Eof()))
		IncProc(STR0012) // Levantando os Clientes...
		aAdd(aClientes,{ (cQAlCli)->CODCLI , (cQAlCli)->LOJCLI })
		(cQAlCli)->(dbSkip())
	End
	(cQAlCli)->(dbCloseArea())
	DbSelectArea("SA1")
EndIf

Return aClone(aClientes)

/*/{Protheus.doc} VC1100031_CarregaHeader
	Carrega aHeader do SA1/VCF juntos

	@author Andre Luis Almeida
	@since 13/01/2021
/*/
Static Function VC1100031_CarregaHeader()
Local aHeader  := {}
Local aAuxCpo  := {}
Local cCampo   := 0
Local nCntFor  := 0
Local cNAO_SA1 := "SA1_UUID/A1_UUID/A1_USERLGA/A1_USERLGI/" // Nao considerar os campos do SA1 (default)
Local cNAO_VCF := "VCF_FILIAL/VCF_CODCLI/VCF_LOJCLI/VCF_NOMCLI/VCF_UUID/" // Nao considerar os campos do VCF (default)
If ExistBlock("VC110NCP")
	cNAO_SA1 += ExecBlock("VC110NCP",.f.,.f.,{"SA1"}) // Nao considerar os campos do SA1 retornados pelo Ponto de Entrada
	cNAO_VCF += ExecBlock("VC110NCP",.f.,.f.,{"VCF"}) // Nao considerar os campos do VCF retornados pelo Ponto de Entrada
EndIf
DBSelectArea("SA1")
aAuxCpo := FWFormStruct(3,"SA1", { |cCampo| !ALLTRIM(cCampo) $ cNAO_SA1 } )[1]
For nCntFor := 1 to Len(aAuxCpo)
	cCampo := aAuxCpo[nCntFor,MODEL_FIELD_IDFIELD]
	If X3Usado(cCampo) // somente campos usados
		AADD(aHeader, {	aAuxCpo[nCntFor,MODEL_FIELD_TITULO]  ,;
						cCampo ,;
						GetSX3Cache(cCampo,"X3_PICTURE") ,;
						aAuxCpo[nCntFor,MODEL_FIELD_TAMANHO] ,;
						aAuxCpo[nCntFor,MODEL_FIELD_DECIMAL] ,;
						aAuxCpo[nCntFor,MODEL_FIELD_VALID]   ,;
						GetSX3Cache(cCampo,"X3_USADO") ,;
						aAuxCpo[nCntFor,MODEL_FIELD_TIPO]    ,;
						GetSX3Cache(cCampo,"X3_F3") ,;
						GetSX3Cache(cCampo,"X3_CONTEXT") ,;
						GetSX3Cache(cCampo,"X3_CBOX") ,;
						aAuxCpo[nCntFor,MODEL_FIELD_INIT] })
	EndIf
Next
DBSelectArea("VCF")
aAuxCpo := FWFormStruct(3,"VCF", { |cCampo| !ALLTRIM(cCampo) $ cNAO_VCF } )[1]
For nCntFor := 1 to Len(aAuxCpo)
	cCampo := aAuxCpo[nCntFor,MODEL_FIELD_IDFIELD]
	If X3Usado(cCampo) // somente campos usados
		AADD(aHeader, {	aAuxCpo[nCntFor,MODEL_FIELD_TITULO]  ,;
						cCampo ,;
						GetSX3Cache(cCampo,"X3_PICTURE") ,;
						aAuxCpo[nCntFor,MODEL_FIELD_TAMANHO] ,;
						aAuxCpo[nCntFor,MODEL_FIELD_DECIMAL] ,;
						aAuxCpo[nCntFor,MODEL_FIELD_VALID]   ,;
						GetSX3Cache(cCampo,"X3_USADO") ,;
						aAuxCpo[nCntFor,MODEL_FIELD_TIPO]    ,;
						GetSX3Cache(cCampo,"X3_F3") ,;
						GetSX3Cache(cCampo,"X3_CONTEXT") ,;
						GetSX3Cache(cCampo,"X3_CBOX") ,;
						aAuxCpo[nCntFor,MODEL_FIELD_INIT] })
	EndIf
Next
Return aClone(aHeader)

/*/{Protheus.doc} VC1100041_CarregaDados
	Carrega aCols dos Dados SA1/VCF

	@author Andre Luis Almeida
	@since 13/01/2021
/*/
Static Function VC1100041_CarregaDados( aClientes , aHeader )
Local aCols   := {}
Local nCntFor := 0
Local nCntCli := 0
Local cAliAtu := space(3)

ProcRegua(len(aClientes))

For nCntCli := 1 to len(aClientes)
	IncProc(STR0013) // Levantando Dados dos Clientes...
	AADD(aCols,Array(Len(aHeader)+1))
	For nCntFor := 1 to Len(aHeader)
		If cAliAtu <> left(aHeader[nCntFor,2],3)
			cAliAtu := left(aHeader[nCntFor,2],3)
			If cAliAtu == "VCF"
				dbSelectArea("VCF")
				dbSetOrder(1)
				dbSeek( xFilial("VCF") + aClientes[nCntCli,1] + aClientes[nCntCli,2] )
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek( xFilial("SA1") + aClientes[nCntCli,1] + aClientes[nCntCli,2] )
			EndIf
		EndIf
		Do Case
			Case aHeader[nCntFor,2] == "A1_FILIAL"
				aCols[Len(aCols),nCntFor] := xFilial("SA1")
			Case aHeader[nCntFor,2] == "A1_COD"
				aCols[Len(aCols),nCntFor] := aClientes[nCntCli,1]
			Case aHeader[nCntFor,2] == "A1_LOJA"
				aCols[Len(aCols),nCntFor] := aClientes[nCntCli,2]
			Case IsHeadRec(aHeader[nCntFor,2])
				If left(aHeader[nCntFor,2],3) == "VCF"
					aCols[Len(aCols),nCntFor] := VCF->(RecNo())
				Else
					aCols[Len(aCols),nCntFor] := SA1->(RecNo())
				EndIf
			Case IsHeadAlias(aHeader[nCntFor,2])
				If left(aHeader[nCntFor,2],3) == "VCF"
					aCols[Len(aCols),nCntFor] := "VCF"
				Else
					aCols[Len(aCols),nCntFor] := "SA1"
				EndIf
			OtherWise
				aCols[Len(aCols),nCntFor] := IIf(aHeader[nCntFor,10] # "V",FieldGet(ColumnPos(aHeader[nCntFor,2])),CriaVar(aHeader[nCntFor,2]))
		EndCase
	Next
	aCols[Len(aCols),Len(aHeader)+1]:=.F.
Next
Return aClone(aCols)

/*/{Protheus.doc} VC1100051_CarregaCampos
	Carrega os Campos do SA1/VCF

	@author Andre Luis Almeida
	@since 14/01/2021
/*/
Static Function VC1100051_CarregaCampos( cTab )
Local aAuxCpo := FWFormStruct(3,cTab, { |cCampo| !ALLTRIM(cCampo) $ "VCF_FILIAL/VCF_CODCLI/VCF_LOJCLI/VCF_NOMCLI/VCF_UUID/SA1_UUID/A1_UUID/A1_USERLGA/A1_USERLGI/" } )[1]
Local nCntFor := 0
Local aCpos   := {}
For nCntFor := 1 to Len(aAuxCpo)
	AADD(aCpos,aAuxCpo[nCntFor,MODEL_FIELD_IDFIELD])
Next
Return aClone(aCpos)

/*/{Protheus.doc} VC1100061_ChamaImpressao
	Chama Impressao tReport - Registros SA1/VCF

	@author Andre Luis Almeida
	@since 25/01/2021
/*/
Static Function VC1100061_ChamaImpressao( cTitulo , aClientes , aHeaderTMP , aColsTMP , aCpoSA1 , aCpoVCF )
Local aArea := GetArea()
//
oReport := ReportDef( cTitulo , aClientes , aHeaderTMP , aColsTMP , aCpoSA1 , aCpoVCF )
oReport:PrintDialog()
RestArea( aArea )
//
Return

/*/{Protheus.doc} ReportDef
	ReportDef para tReport

	@author Andre Luis Almeida
	@since 25/01/2021
/*/
Static Function ReportDef( cTitulo , aClientes , aHeaderTMP , aColsTMP , aCpoSA1 , aCpoVCF )
Local oReport
Local oSection1
Local oCell
Local nCntFor := 0
Local cAliAtu := space(3)
//
oReport := TReport():New("VEIC110",cTitulo,,{|oReport| VC1100071_Imprimir( oReport , aClientes )})
oReport:SetLandscape() // Imprime o relatório em Paisagem
//
oSection1 := TRSection():New(oReport,STR0001,{"SA1","VCF"}) // Clientes
If len(aClientes) > 1 // Mais de 1 Cliente
	For nCntFor := 1 to (Len(aHeaderTMP)-1)
		If cAliAtu <> left(aHeaderTMP[nCntFor,2],3)
			cAliAtu := left(aHeaderTMP[nCntFor,2],3)
		EndIf
		If cAliAtu == "VCF"
			TRCell():New(oSection1,aHeaderTMP[nCntFor,2],"VCF",,,)
		Else
			TRCell():New(oSection1,aHeaderTMP[nCntFor,2],"SA1",,,)
		EndIf
	Next
Else // Apenas 1 Cliente
	For nCntFor := 1 to Len(aCpoSA1)
		TRCell():New(oSection1,aCpoSA1[nCntFor],"SA1",,,)
	Next
	For nCntFor := 1 to Len(aCpoVCF)
		TRCell():New(oSection1,aCpoVCF[nCntFor],"VCF",,,)
	Next
EndIf
//
Return oReport

/*/{Protheus.doc} VC1100071_Imprimir
	Impressao em tReport

	@author Andre Luis Almeida
	@since 25/01/2021
/*/
Static Function VC1100071_Imprimir( oReport , aClientes )
Local oSection1 := oReport:Section(1)
Local nCntFor   := 0
oReport:SetMeter(len(aClientes))
oSection1:Init()
For nCntFor := 1 to len(aClientes)
	oReport:IncMeter()
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek( xFilial("SA1") + aClientes[nCntFor,1] + aClientes[nCntFor,2] )
	dbSelectArea("VCF")
	dbSetOrder(1)
	dbSeek( xFilial("VCF") + aClientes[nCntFor,1] + aClientes[nCntFor,2] )
	oSection1:PrintLine()
Next
oSection1:Finish()
Return Nil