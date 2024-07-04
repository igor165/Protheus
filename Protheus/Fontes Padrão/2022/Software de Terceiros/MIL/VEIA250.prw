#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include 'VEIA250.CH'

/*/{Protheus.doc} VEIA250
Cadastro de Markups e Descontos para calculo de Valor de Venda dos Pacotes

@author Andre Luis Almeida
@since 03/07/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/ 
Function VEIA250( cCodMar , cModVei , cSegMod )

	Local cFiltVV2  := "" // SQL - Filtro padrão do Browse no VV2 caso receba Marca/Modelo/Segmento por parametro
	Local cVV2xVN3  := "" // SQL - Filtro auxiliar com o posicionamento do VN3 partindo do VV2
	Local cVV2xVN0  := "" // SQL - Filtro auxiliar com o posicionamento do VN0 partindo do VV2
	Local nTamObj1  := 65
	Local nTamObj2  := 35
	Private cCadastro := STR0001 // Markups e Descontos para calculo de Valor de Venda dos Pacotes
	Private aSize     := FWGetDialogSize( oMainWnd )
	Default cCodMar   := ""
	Default cModVei   := ""
	Default cSegMod   := ""

	If !Empty( cCodMar + cModVei + cSegMod ) // Se receber Marca/Modelo/Segmento por parametro, fazer Filtro no Browse do VV2
		cFiltVV2 := "@    VV2_CODMAR = '"+cCodMar+"'"
		cFiltVV2 += " AND VV2_MODVEI = '"+cModVei+"'"
		cFiltVV2 += " AND VV2_SEGMOD = '"+cSegMod+"'"
		nTamObj1 := 35
		nTamObj2 := 65
	EndIf

	cVV2xVN3 := "( SELECT TEMP.VN3_CODIGO "
	cVV2xVN3 += "  FROM " + RetSqlName("VN3") + " TEMP "
	cVV2xVN3 += " WHERE TEMP.VN3_FILIAL = VV2_FILIAL "
	cVV2xVN3 += "   AND TEMP.VN3_CODMAR = VV2_CODMAR "
	cVV2xVN3 += "   AND TEMP.VN3_MODVEI = VV2_MODVEI "
	cVV2xVN3 += "   AND TEMP.VN3_SEGMOD = VV2_SEGMOD "
	cVV2xVN3 += "   AND TEMP.D_E_L_E_T_ = ' ' "
	cVV2xVN3 += ")"

	cVV2xVN0 := "( SELECT TEMP.VN0_CODIGO "
	cVV2xVN0 += "  FROM " + RetSqlName("VN0") + " TEMP "
	cVV2xVN0 += " WHERE TEMP.VN0_FILIAL = VV2_FILIAL "
	cVV2xVN0 += "   AND TEMP.VN0_CODMAR = VV2_CODMAR "
	cVV2xVN0 += "   AND TEMP.VN0_MODVEI = VV2_MODVEI "
	cVV2xVN0 += "   AND TEMP.VN0_SEGMOD = VV2_SEGMOD "
	cVV2xVN0 += "   AND TEMP.VN0_STATUS = '1' "
	cVV2xVN0 += "   AND TEMP.D_E_L_E_T_ = ' ' "
	cVV2xVN0 += ")"

	oDlgVA250 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkArea := FWUIWorkArea():New( oDlgVA250 )
		oWorkArea:CreateHorizontalBox( "LINE01", nTamObj1 )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ_MODELOS" } )
		oWorkArea:CreateHorizontalBox( "LINE02", nTamObj2 )
		oWorkArea:SetBoxCols( "LINE02", { "OBJ_MARKUP_DESCONTOS" } )
		oWorkArea:Activate()

		oBrwVV2 := FwMBrowse():New()
		oBrwVV2:SetOwner(oWorkarea:GetPanel("OBJ_MODELOS"))
		oBrwVV2:SetDescription(STR0008) // Modelos de Máquinas
		oBrwVV2:SetMenuDef( 'VEIA250' )
		oBrwVV2:SetAlias('VV2')
		oBrwVV2:lChgAll := .T.//nao apresentar a tela para informar a filial
		If !Empty(cFiltVV2)
			oBrwVV2:SetFilterDefault( cFiltVV2 )
		EndIf
		oBrwVV2:AddFilter( STR0002 , "@ EXISTS "+cVV2xVN3 ,.f.,.f.,) // Modelos com Markup/Desconto cadastrado
		oBrwVV2:AddFilter( STR0003 , "@ NOT EXISTS "+cVV2xVN3 ,.f.,.f.,) // Modelos sem Markup/Desconto cadastrado
		oBrwVV2:AddFilter( STR0004 , "@ VV2_COMERC='1'" ,.f.,.f.,) // Modelos comercializados
		oBrwVV2:AddFilter( STR0005 , "@ VV2_COMERC<>'1'" ,.f.,.f.,) // Modelos não comercializados
		oBrwVV2:AddFilter( STR0006 , "@ EXISTS "+cVV2xVN0 ,.f.,.f.,) // Modelos com Pacotes cadastrados
		oBrwVV2:AddFilter( STR0007 , "@ NOT EXISTS "+cVV2xVN0 ,.f.,.f.,) // Modelos sem Pacotes cadastrados
		oBrwVV2:DisableDetails()
		oBrwVV2:lOptionReport := .f.
		oBrwVV2:ForceQuitButton(.T.)
		oBrwVV2:Activate()

		oBrwVN3 := FwMBrowse():New()
		oBrwVN3:SetOwner(oWorkarea:GetPanel("OBJ_MARKUP_DESCONTOS"))
		oBrwVN3:SetDescription(STR0009) // Markups e Descontos
		oBrwVN3:SetMenuDef( 'VEIA251' )
		oBrwVN3:SetAlias('VN3')
		oBrwVN3:AddFilter( STR0010 , "@ VN3_TIPO='1'",.f.,.f.,) // Markups - A VISTA
		oBrwVN3:AddFilter( STR0011 , "@ VN3_TIPO='2'",.f.,.f.,) // Markups - A PRAZO
		oBrwVN3:AddFilter( STR0012 , "@ VN3_TIPO='3'",.f.,.f.,) // Descontos
		oBrwVN3:AddFilter( STR0013 , "@ VN3_USRDES=' '",.f.,.f.,) // Ativos
		oBrwVN3:AddFilter( STR0014 , "@ VN3_USRDES<>' '",.f.,.f.,) // Desativados
		oBrwVN3:AddLegend( 'VA2500011_CorBrowse()=="1"' , 'BR_VERDE'    , STR0015+" ( "+Transform(dDataBase,"@D")+" )" ) // Vigorando hoje
		oBrwVN3:AddLegend( 'VA2500011_CorBrowse()=="2"' , 'BR_LARANJA'  , STR0016 ) // Antigos
		oBrwVN3:AddLegend( 'VA2500011_CorBrowse()=="3"' , 'BR_AZUL'     , STR0017 ) // Futuros
		oBrwVN3:AddLegend( 'VA2500011_CorBrowse()=="4"' , 'BR_VERMELHO' , STR0014 ) // Desativados
		oBrwVN3:DisableLocate()
		oBrwVN3:DisableDetails()
		oBrwVN3:SetAmbiente(.F.)
		oBrwVN3:SetWalkthru(.F.)
		oBrwVN3:SetInsert(.f.)
		oBrwVN3:SetUseFilter()
		oBrwVN3:lOptionReport := .f.
		oBrwVN3:Activate()

		oRelac:= FWBrwRelation():New()
		oRelac:AddRelation( oBrwVV2 , oBrwVN3 , {{ "VN3_FILIAL", "xFilial('VN3')" } , { "VN3_CODMAR", "VV2_CODMAR" } , { "VN3_MODVEI", "VV2_MODVEI" } , { "VN3_SEGMOD", "VV2_SEGMOD" } })
		oRelac:Activate()

	oDlgVA250:Activate( , , , , , , ) //ativa a janela

Return NIL
 
/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 06/07/2021
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0018 ACTION 'VEIA252()' OPERATION 4 ACCESS 0 // Replicar
ADD OPTION aRotina TITLE STR0019 ACTION 'VEIA242( VV2->VV2_CODMAR , VV2->VV2_MODVEI , VV2->VV2_SEGMOD , "" , .t. )' OPERATION 2 ACCESS 0 // Visualiza Pacotes com Valores do Modelo selecionado
ADD OPTION aRotina TITLE STR0020 ACTION 'VA2400171_EnviarEmail(.t.,.t.)' OPERATION 9 ACCESS 0 // Enviar e-mail de alteração na Lista de Preços dos Pacotes
Return aRotina

/*/
{Protheus.doc} VA2500011_CorBrowse
Retorna a cor para o browse (VN3 posicionado)

@author Andre Luis Almeida
@since 03/07/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA2500011_CorBrowse()
Local oSqlHlp
Local cQuery  := ""
Local cRetCor := "2" // 2-Antigos
If !Empty(VN3->VN3_USRDES) // Desativado
	cRetCor := "4" // 4-Desativados
Else // Verificar se esta Vigorando pela DataBase
	If VN3->VN3_DATINI <= dDataBase
		oSqlHlp := DMS_SqlHelper():New()
		cQuery := "SELECT TEMP.VN3_CODIGO "
		cQuery += "  FROM " + RetSqlName("VN3") + " TEMP "
		cQuery += " WHERE TEMP.VN3_FILIAL = '"+VN3->VN3_FILIAL+"' "
		cQuery += "   AND TEMP.VN3_CODMAR = '"+VN3->VN3_CODMAR+"' "
		cQuery += "   AND TEMP.VN3_MODVEI = '"+VN3->VN3_MODVEI+"' "
		cQuery += "   AND TEMP.VN3_SEGMOD = '"+VN3->VN3_SEGMOD+"' "
		cQuery += "   AND TEMP.VN3_TIPO   = '"+VN3->VN3_TIPO  +"' "
		cQuery += "   AND TEMP.VN3_USRDES = ' ' " // ativo
		cQuery += "   AND TEMP.VN3_DATINI <= '"+dtos(dDataBase)+"' "
		cQuery += "   AND TEMP.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY TEMP.VN3_DATINI DESC "
		If VN3->VN3_CODIGO == FM_SQL(oSqlHlp:TOPFunc(cQuery,1))
			cRetCor := "1" // 1-Vigorando hoje
		EndIf
	Else
		cRetCor := "3" // 3-Futuros
	EndIf
EndIf
Return cRetCor

/*/
{Protheus.doc} VA2500021_Retorna_Indice_VN3
Retorna o Indice Ativo pela Data de Referencia

@author Andre Luis Almeida
@since 03/07/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA2500021_Retorna_Indice_VN3(cMarVN3,cModVN3,cSegVN3,cTipVN3,dDatRef)
Local oSqlHlp := DMS_SqlHelper():New()
Local cQuery  := ""
Default cMarVN3 := VN3->VN3_CODMAR
Default cModVN3 := VN3->VN3_MODVEI
Default cSegVN3 := VN3->VN3_SEGMOD
Default cTipVN3 := VN3->VN3_TIPO
Default dDatRef := dDataBase
cQuery := "SELECT TEMP.VN3_INDVLR "
cQuery += "  FROM " + RetSqlName("VN3") + " TEMP "
cQuery += " WHERE TEMP.VN3_FILIAL = '"+xFilial("VN3")+"' "
cQuery += "   AND TEMP.VN3_CODMAR = '"+cMarVN3+"' "
cQuery += "   AND TEMP.VN3_MODVEI = '"+cModVN3+"' "
cQuery += "   AND TEMP.VN3_SEGMOD = '"+cSegVN3+"' "
cQuery += "   AND TEMP.VN3_TIPO   = '"+cTipVN3+"' "
cQuery += "   AND TEMP.VN3_USRDES = ' ' " // ativo
cQuery += "   AND TEMP.VN3_DATINI <= '"+dtos(dDatRef)+"' "
cQuery += "   AND TEMP.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY TEMP.VN3_DATINI DESC "
Return FM_SQL(oSqlHlp:TOPFunc(cQuery,1))