#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "PCPA104.CH" 
#DEFINE CABECALHO "CZG_CDAC/CZG_DSAC/CZG_CDRC/CZG_DSRC/CZG_CDFATD/CZG_DSFATD/CZG_CDGRIV/CZG_DSGRIV/CZG_VRFH/CZG_TPMP/CZG_DSTPMP/CZG_CDMD/CZG_NMMD/CZG_VRFH/CZG_DTFH/"
#DEFINE GRID "CZG_FILIAL/"

#DEFINE OPER_COPIAR			15

static __lAutomacao := isBlind()
//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA104
Cadastro Ficha Tecnica

@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0

/*/
//-----------------------------------------------------------------
Function PCPA104
Local	oBrw	:= FWmBrowse():New()
Private cParam104
Private cTpAtrib		:= ""
Private cVlFaixa		:= ""
Private lEnd			:= .F.
Private aParenteses		:= {}
Private cFormula		:= ""
Private cFormNova		:= ""
Private lRetorno		:= .F.
Private nOpVersao		:= 0
Private lWhen			:= .T.
Private cVerFicha		:= ""
Private lEntrou			:= .F.
Private cVLTB			:=  ""
Private cAbreTela		:= 'S'
Private cExecVald		:= 'S'
Private aTemplates		:= {}
Private aValores		:= {}
Private lValid			:= .T.
Private lExecuta		:= .T.
Private lCopyAll		:= .F.

Private lFichaIncos		:= .F.
Private cCZGIncons		:= ""
Private cTempl			:= ""
Private cProd			:= ""
Private cRecur			:= ""
Private cVers			:= ""
Private cFamTec			:= ""

oBrw:SetDescription(STR0009)//Ficha Técnica
oBrw:SetAlias( 'CZG')
oBrw:SetMenuDef( 'PCPA104' )

//Filtra o browse por familia tecnica caso tela tenha sido chamada pelo DPRA100 ou DPRA300
//cFamTec - Verifica se a variavel Private foi instanciada para utilizar no filtro. 
If IsInCallStack('DPRA100')
	oBrw:SetFilterDefault( "CZG_CDAC = ' ' .AND. CZG_CDRC = ' ' .AND. CZG_CDFATD <> ' ' .AND. CZG_CDFATD = '" + DG3->DG3_CDFATD + "'" )
ElseIf IsInCallStack('DPRA300')	
	oBrw:SetFilterDefault( "CZG_CDAC = ' ' .AND. CZG_CDRC = ' ' .AND. CZG_CDFATD <> ' ' .AND. CZG_CDFATD = '" + POSICIONE('DG3',1,xFilial('DG3')+DG0->DG0_CDACDV,'DG3_CDFATD') + "'" )
ElseIf FunName() == 'PCPC101'
	oBrw:SetFilterDefault(Iif(Type('cFiltro')=="C",cFiltro," ")) //Variável cFiltro definida no PCPC101.
ElseIf FunName() != 'PCPA104'
	oBrw:SetFilterDefault( "CZG_CDAC = ' ' .AND. CZG_CDRC = ' ' .AND. CZG_CDFATD <> ' '" )
EndIf

oBrw:Activate()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCZG  	:= FWFormStruct( 1, 'CZG', { |cCampo| AllTrim( cCampo ) + '/' $ CABECALHO } ,/*lViewUsado*/ )
Local oStruGrid 	:= FWFormStruct( 1, 'CZG', { |cCampo| !AllTrim( cCampo ) + '/' $ CABECALHO + GRID } ,/*lViewUsado*/ )

Local oModel  	:= 	MPFormModel():New('PCPA104',,{|oModel| VldOk104(oModel) }, {|| If(FWFORMCOMMIT(SELF), PCPA104GCOP(), .F.) } )//PCPA104GCOP
Local nIndex    := 7

oModel:SetActivate( { |oModel| TelaTipo( oModel, oStruCZG) } )

oModel:AddFields('CZGMASTER', /*cOwner*/, oStruCZG)
oModel:GetModel( 'CZGMASTER' ):SetPrimaryKey( { 'CZG_CDAC','CZG_CDRC','CZG_CDMD','CZG_VRFH','CZG_CDAB' } )

oModel:AddGrid('CZGDETAIL', 'CZGMASTER', oStruGrid)

oModel:SetRelation( 'CZGDETAIL' , { { 'CZG_FILIAL' , 'xFilial( "CZG" )' } , { 'CZG_CDAC' , 'CZG_CDAC' } , { 'CZG_CDRC' , 'CZG_CDRC' }, {'CZG_CDFATD' , 'CZG_CDFATD'}, { 'CZG_CDMD' , 'CZG_CDMD' } , { 'CZG_VRFH' , 'CZG_VRFH' } } , CZG->( IndexKey( nIndex ) ) )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel  		:=  FWLoadModel( 'PCPA104' )
Local oStruCZG   		:=  FWFormStruct( 2, 'CZG', { |cCampo| AllTrim( cCampo ) + '/' $ CABECALHO } ,/*lViewUsado*/ )
Local oStruGrid 		:=  FWFormStruct( 2, 'CZG', { |cCampo| !AllTrim( cCampo ) + '/' $ CABECALHO + GRID } ,/*lViewUsado*/ )
Local oView 	 		:=  FWFormView():New()
Local cParam104  		:=  ''

lEntrou := .F.

oView:SetModel( oModel )

oStruCZG:AddGroup ( 'GRP_DADOS', 'Dados Produto', '' , 1 )
oStruCZG:AddGroup ( 'GRP_TEMPLATE' , 'Template' , '' , 1 )


oStruCZG:SetProperty( 'CZG_CDAC'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_DSAC'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_CDRC'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_DSRC'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_CDFATD' , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_DSFATD' , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_CDGRIV' , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_DSGRIV' , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_TPMP'   , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )
oStruCZG:SetProperty( 'CZG_DSTPMP' , MVC_VIEW_GROUP_NUMBER , 'GRP_DADOS' )

oStruCZG:SetProperty( 'CZG_CDMD' , MVC_VIEW_GROUP_NUMBER , 'GRP_TEMPLATE' )
oStruCZG:SetProperty( 'CZG_NMMD' , MVC_VIEW_GROUP_NUMBER , 'GRP_TEMPLATE' )
oStruCZG:SetProperty( 'CZG_VRFH' , MVC_VIEW_GROUP_NUMBER , 'GRP_TEMPLATE' )
oStruCZG:SetProperty( 'CZG_DTFH' , MVC_VIEW_GROUP_NUMBER , 'GRP_TEMPLATE' )


oView:AddField( 'VIEW_CZG', oStruCZG, 'CZGMASTER' )

oView:AddGrid ( 'VIEW_GRID', oStruGrid, 'CZGDETAIL' )

oView:CreateHorizontalBox( 'FIELDSCZG', 50 )

oView:CreateHorizontalBox( 'GRIDCZG', 50,,,,)

oView:SetOwnerView( 'VIEW_CZG', 'FIELDSCZG' )
oView:SetOwnerView( 'VIEW_GRID', 'GRIDCZG' )

oView:SetFieldAction( 'CZG_CDMD', { |oView, cIDView, cField, xValue| flAction( oView, cIDView, cField, xValue ) } )

oView:SetCloseOnOk({||.T.})

Return oView

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author  Jefferson Arthur Guermandi
@since   07/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
   Local aRotina := {}
   ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCPA104' OPERATION 2 ACCESS 0 //Visualizar
   ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCPA104' OPERATION 3 ACCESS 0 //Incluir
   
   If SuperGetMv("MV_PCPMOFT",.F.,"N") == "S"
      ADD OPTION aRotina Title STR0042 Action 'PCPA104RDRBTN(1)' OPERATION 4 ACCESS 0 //Alterar
   EndIf
   
   ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.PCPA104'  OPERATION 5 ACCESS 0 //Excluir
   ADD OPTION aRotina Title STR0006 Action 'PCPA104RDRBTN(4)' OPERATION 2 ACCESS 0 //Nova Versão
   ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.PCPA104'  OPERATION 8 ACCESS 0 //Imprimir
   ADD OPTION aRotina Title STR0033 Action 'PCPA104RDRBTN(2)' OPERATION 9 ACCESS 0 //Copiar
   
   ADD OPTION aRotina Title STR0047 Action 'PCPA104RDRBTN(3)' OPERATION 9 ACCESS 0 //Copia Geral

   ADD OPTION aRotina Title STR0053 Action 'PCPA104CST()' OPERATION 1 ACCESS 0 //Consultar

Return aRotina
//---------------------------------------------------------------------------------------------
Static Function flAction(oView, cIDView, cField, xValue)
	cAbreTela := 'S'
	cExecVald := 'S'
Return .T.
//---------------------------------------------------------------------------------------------
Function PCPA104VNU()

	Local cValPad
	Local nI
	Local oModel    := FwModelActive()
	Local oModelDet := oModel:GetModel('CZGDETAIL')
	Local nResult   := 0
	Local aOldArea  := GetArea()
	Local nLinha    := oModelDet:GetLine()
	Local nPonto    := 0
	Local cFormato  := " ( "	
	
	If cExecVald = 'N'
		Return .T.
	EndIf
	If (oModelDet:GetValue('CZG_TPAB') == 'R' .Or. ;
	    oModelDet:GetValue('CZG_TPAB') == 'L' .Or. ;
	    oModelDet:GetValue('CZG_TPAB') == 'A')
		Return .T.
	EndIf
	For nI := 1 To oModelDet:GetQtdLine()
		oModelDet:GoLine(nI)
		If oModelDet:GetValue('CZG_TPAB') == 'R'
			cValPad := validForm(oModelDet:GetValue('CZG_VLFO'))
			cValPad := StrTran(cValPad,",", ".")
			oModelDet:GoLine(nI)
			nResult := &(cValPad)
			oModelDet:GetStruct():SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { || .t. } )
			oModelDet:LoadValue('CZG_VLNR', nResult)
			oModelDet:GetStruct():SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { || PCPA104WGRID(3) } )
			cFormNova := ""
		EndIf
	Next

	oModelDet:GoLine(nLinha)

	DbSelectArea( "CZB" )
	CZB->(dbSetOrder(1))
	CZB->(dbSeek(xFilial("CZB") + oModelDet:GetValue('CZG_CDAB')))
	
	cValor := cValtoChar(M->CZG_VLNR)

	For nI := 1 To Len(cValor)
		If Substr(cValor,nI,1) == "."
			nPonto := nI
		EndIf
	Next

	If nPonto != 0
		cValorInt := SubStr(cValtoChar(M->CZG_VLNR),1,(nPonto-1))
		cValorDec := SubStr(cValtoChar(M->CZG_VLNR),(nPonto+1))

		If cValorInt == "0"
			cValorInt := ""
		EndIf

	Else
		cValorInt := cValtoChar(M->CZG_VLNR)
		cValorDec := ""
	EndIf
	//Verifica se possuirá valor decimal
	If CZB->CZB_VLPRC == 0
		If ((Len(cValorInt) > CZB->CZB_TMAB) .OR. (Len(cValorDec) > CZB->CZB_VLPRC))
			//Monta string com o formato necessário
			For nI := 1 To CZB->CZB_TMAB
				cFormato += "9"
			Next
			
			//Finaliza com um parenteses
			cFormato += " )"
			Help( ,, 'Help',, STR0029 + cFormato, 1, 0 ) // "Tamanho não compatível com tamanho informado no cadastro do atributo. Verifique!"
			
			Return .F.
		Endif
	Else
		//Monta string com o formato necessário, se não houver números inteiros insere um zero
		If (CZB->CZB_TMAB - CZB->CZB_VLPRC - 1) != 0
			For nI := 1 To (CZB->CZB_TMAB - CZB->CZB_VLPRC - 1)
				cFormato += "9"
			Next
		EndIf
		
		//Coloca uma virgula
		cFormato += ","
		
		//Insere os decimais
		For nI := 1 To CZB->CZB_VLPRC
			cFormato += "9"
		Next
		
		//Finaliza com um parenteses
		cFormato += " )"
		
		If ((Len(cValorInt) > CZB->CZB_TMAB - CZB->CZB_VLPRC - 1) .OR. (Len(cValorDec) > CZB->CZB_VLPRC))
			Help( ,, 'Help',, STR0029 + cFormato, 1, 0 ) // "Tamanho não compatível com tamanho informado no cadastro do atributo. Verifique!"
			
			Return .F.
		Endif
	EndIf
		
	RestArea(aOldArea)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104Atrib
Carrega grid de acordo com o template escolhido


@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104Atrib()

	Local cQuery 		:= ""
	Local cAlias 		:= GetNextAlias()
	Local cTemplate   := M->CZG_CDMD
	Local nI 			:= 1
	Local kI          := 1
	Local jI          := 1
	Local cDTpAtrib   := ""
	Local oStruGrid 	:= FWFormStruct( 2, 'CZG', { |cCampo| !AllTrim( cCampo ) + '/' $ CABECALHO + GRID })
	Local oModel
	Local oView 		 := FWFormView():New()
	Local cValor      := ""
	Local lRet        := .T.
	Local cVerMax		 := ""

	If !PCPA104FIL(.f.)
		Help( ,, 'Help',,STR0027, 1, 0 ) //"O Template selecionado é inválido!"
		Return .F.
	EndIf
	
	cAbreTela := 'N'
	
	If nOpVersao <> 1
		cExecVald := 'N'
	Else
		cExecVald := 'S'
	EndIf
	
	CLEARGRID('CZGDETAIL')
	
	cQuery := " SELECT CZE.CZE_CDAB, CZB.CZB_DSAB, CZB.CZB_TPAB, CZB.CZB_VLPAAB, CZB.CZB_NMAB, CZB.CZB_TPTB, CZB.CZB_STAB, CZE.CZE_SQAB "

	cQuery += " FROM " + RetSqlName('CZE') + " CZE "
	cQuery += " LEFT JOIN " + RetSqlName( "CZB" ) + " CZB ON ( CZB.CZB_FILIAL = '" + xFilial( "CZB" ) + "' AND CZB.CZB_CDAB = CZE.CZE_CDAB AND CZB.D_E_L_E_T_ = '' ) "

	cQuery += " WHERE CZE.CZE_CDMD= '" + cTemplate + "' "
	cQuery += " AND CZE.CZE_FILIAL = '" + xFilial("CZE") + "' "
	cQuery += " AND CZE.D_E_L_E_T_ = '' "
	cQuery += " Order by CZE.CZE_SQAB, CZE.CZE_CDAB "

	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
	DbSelectArea( cAlias )
	
	INSRGRIDATR(cAlias)

	//retorna a ultima versao de acordo com o where	
	oModel	:= FWModelActive()
	oModel:LoadValue("CZGMASTER","CZG_VRFH", FichaNextVer(versaoFT(), 5))
	
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} versaoFT
Retorna a ultima versão da ficha técnica

@author Lucas Konrad França
@since 05/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function versaoFT(cTgtProd)
	Local cQuery := ""
	Local cVerMax := 0
	Local cAliasCZG := GetNextAlias()
	
	Default cTgtProd := ""

	cQuery := " SELECT COALESCE(MAX(CZG.CZG_VRFH), '0') VERSAO "
	
	cQuery += " FROM " + RetSqlName('CZG') + " CZG "
	
	cQuery += " WHERE CZG.CZG_FILIAL = '" + xFilial("CZG") + "' "
	cQuery += " AND CZG.D_E_L_E_T_ = '' "
	cQuery += " AND CZG.CZG_CDMD = '" + If(AllTrim(M->CZG_CDMD) == "", CZG->CZG_CDMD, M->CZG_CDMD ) + "'"
	
	cQuery += FLTRVRSRULE(cTgtProd)
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasCZG, .F., .T.)
	DbSelectArea( cAliasCZG )
	
	While ((cAliasCZG)->(!Eof() ))
	   cVerMax  := (cAliasCZG)->VERSAO
	   (cAliasCZG)->(DbSkip())
	End

Return cVerMax
//-------------------------------------------------------------------
/*/{Protheus.doc} TelaTipo
Escolhe tipo de cadastro

@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function TelaTipo(oModel, oStruCZG)
	Local nOp  := oModel:GetOperation()
	Local oModelCZG     := oModel:GetModel('CZGDETAIL')
	oModelCZG:SetNoInsertLine(.T.)
	oModelCZG:SetNoDeletetLine(.T.)
   
	If FunName() <> 'DPRA342'
		If nOpVersao <> 1
			If nOp == 3 .AND. !IsInCallStack("PCPA104COP")
				If Pergunte("PCPA004",.T.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega parametros do programa                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cParam104 := &("mv_par01")
				EndIf
			EndIf
		EndIf
	EndIf
	
	//Operação de Cópia, limpa os campos necessários.
	If IsInCallStack("PCPA104COP") .or. __lAutomacao
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_CDAC','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_DSAC','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_CDRC','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_DSRC','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_CDGRIV','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_DSGRIV','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_TPMP','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_DSTPMP','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_CDFATD','')
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_DSFATD','')
	   
	   //Atribui o valor do template que está sendo copiado
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_CDMD',cTempl)
	   
	   //Atualiza a data da ficha técnica
	   oModel:GetModel('CZGMASTER'):LoadValue('CZG_DTFH',DATE())
	   
   		If lFichaIncos
			MSGINFO(STR0049)//STR0049
			INSRGRIDATR(cCZGIncons)
		EndIf
		
	EndIf
	
	If IsInCallStack("PCPA104RDRBTN")
      oModelCZG:SetNoInsertLine(.T.)
      oModelCZG:SetNoDeletetLine(.T.)
	EndIf
	
Return(oStruCZG)
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104WCPOS
Inibe campos que nao podem ser editados de acordo com o tipo cadastro

@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function PCPA104WCPOS(lCampo) // Função chamada no WHEN do campo que será desabilitado (CZD_CDRC)
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelCZG := oModel:GetModel('CZGMASTER')
Local lEntrou   := .F.

If (lWhen)
	Do Case
		Case lCampo == 1
		 	If (cParam104 == 2 .Or. cParam104 == 4 .Or. cParam104 == 5 .Or. nOpVersao == 1)
				If (empty(oModelCZG:GetValue("CZG_CDAC")) .Or. !empty(oModelCZG:GetValue("CZG_CDAC")))
					lRet := .F.
				EndIf
	 		EndIf
		Case lCampo == 2
		 	If (cParam104 == 1  .Or. cParam104 == 4 .Or. nOpVersao == 1)
				If (empty(oModelCZG:GetValue("CZG_CDRC")) .Or. !empty(oModelCZG:GetValue("CZG_CDRC")))
					lRet := .F.
				EndIf
	 		EndIf
	 Case lCampo == 3
			If (cParam104 == 1 .Or. cParam104 == 2 .Or. cParam104 == 3 .Or. nOpVersao == 1)
				If (empty(oModelCZG:GetValue("CZG_CDFATD")) .Or. !empty(oModelCZG:GetValue("CZG_CDFATD")))//o campo "CZG_CDFATD" na opcao 1, 2 fica sempre desabilitado
					lRet := .F.
				EndIf
			EndIf
	 Case lCampo == 4
	 		Do Case
	 			Case cParam104 == 1
					If empty(oModelCZG:GetValue("CZG_CDAC"))
						aTemplates := { }
						lEntrou := .T.
					EndIf
	 			Case cParam104 == 2
					If empty(oModelCZG:GetValue("CZG_CDRC"))
						aTemplates := { }
						lEntrou := .T.
					EndIf
	 			Case cParam104 == 3
					If empty(oModelCZG:GetValue("CZG_CDRC")) .OR. empty(oModelCZG:GetValue("CZG_CDAC"))
						aTemplates := { }
						lEntrou := .T.
					EndIf
	 			Case cParam104 == 4
					If empty(oModelCZG:GetValue("CZG_CDFATD"))
						aTemplates := { }
						lEntrou := .T.
					EndIf
	 			Case cParam104 == 5
	 				If empty(oModelCZG:GetValue("CZG_CDRC")) .OR. empty(oModelCZG:GetValue("CZG_CDFATD"))
						aTemplates := { }
						lEntrou := .T.
					EndIf
	 		EndCase
	 		If !lEntrou
			   aTemplates := PCPA104CTP(oModelCZG:GetValue("CZG_TPMP"),oModelCZG:GetValue("CZG_CDGRIV"),oModelCZG:GetValue("CZG_CDRC"),oModelCZG:GetValue("CZG_CDFATD"))
			EndIf
			If (nOpVersao == 1)
				If (empty(oModelCZG:GetValue("CZG_CDMD")) .Or. !empty(oModelCZG:GetValue("CZG_CDMD")))
					lRet := .F.
				EndIf
			EndIf
			//Para cópia, o campo fica desabilitado.
			If IsInCallStack("PCPA104COP")
			   lRet := .F.
			EndIf
	EndCase
EndIf

//Na modificação, não permite alterar os campos mestres, somente os valores dos atributos.
If oModel:GetOperation() == 4
   lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104WGRID
Inibe campos do grid que nao podem ser editados de acordo com o atributo

@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function PCPA104WGRID(lCampo)      // Função chamada no WHEN do campo que será desabilitado (CZG_VLFG)
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelCZG		:= oModel:GetModel('CZGDETAIL')
Local nI := 0
Local nLine := oModelCZG:GetLine()


If lValid
   aValores := { }
   For nI := 1 To oModelCZG:GetQtdLine()
      oModelCZG:GoLine(nI)
      Do Case
         Case oModelCZG:GetValue("CZG_TPAB") == 'F'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLFG"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'C'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLCHAR"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'N'
            aAdd(aValores,{oModelCZG:GetValue("CZG_VLNR")})
         Case oModelCZG:GetValue("CZG_TPAB") == 'O'
            aAdd(aValores,{ oModelCZG:GetValue("CZG_VLNR"), oModelCZG:GetValue("CZG_AFINF"), oModelCZG:GetValue("CZG_AFSUP")})
         Case oModelCZG:GetValue("CZG_TPAB") == 'D'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLDT"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'L'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLLST"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'A'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLFX"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'I'
            aAdd(aValores,oModelCZG:GetValue("CZG_BITMAP"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'R'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLFO"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'M'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLMEMO"))
         Case oModelCZG:GetValue("CZG_TPAB") == 'T'
            aAdd(aValores,oModelCZG:GetValue("CZG_VLTB"))
      EndCase
   Next
EndIf

If !lValid .And. lExecuta
   lValid := .T.
EndIf

oModelCZG:GoLine(nLine)

If (lCampo <> 13)
	cTpAtrib := oModelCZG:GetValue("CZG_TPAB")
EndIf

Do Case
 	Case lCampo == 0
		If (!empty(oModelCZG:GetValue("CZG_CDAB"))) //o campo CZG_CDAB fica desabilitado
			lRet := .F.
		EndIf

	Case lCampo == 1 //Campo Flag F
		 If (cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "O" )
           If ((empty(oModelCZG:GetValue("CZG_VLFG"))) .Or. !empty(oModelCZG:GetValue("CZG_VLFG"))) //o campo CZG_VLFG fica desabilitado nos atributos acima
              lRet := .F.
           EndIf
		EndIf
	Case lCampo == 2  //Campo Char C
		 If (cTpAtrib == "F" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_VLCHAR"))) .Or. !empty(oModelCZG:GetValue("CZG_VLCHAR"))) //o campo "CZG_VLCHAR" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 3 //Campo Numerico N  /Tolerancia O
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" )
				If ((empty(oModelCZG:GetValue("CZG_VLNR"))) .Or. !empty(oModelCZG:GetValue("CZG_VLNR"))) //o campo "CZG_VLNR" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 4    //Campo Data    D
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_VLDT"))) .Or. !empty(oModelCZG:GetValue("CZG_VLDT"))) //o campo "CZG_VLDT" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 5  //Campo Lista L
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_VLLST"))) .Or. !empty(oModelCZG:GetValue("CZG_VLLST"))) //o campo "CZG_VLLST" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 6   //Campo Faixa  A
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_VLFX"))) .Or. !empty(oModelCZG:GetValue("CZG_VLFX"))) //o campo "CZG_VLFX" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
				If cAbreTela == 'S' .And. lExecuta
					If ((cTpAtrib == "A") .And. (!lEnd))
						If !lEntrou
							If IsInCallStack('PCPA104')
								PCPA104FX()
							EndIf
						   lEntrou := .T.
						 Else
						 	lEntrou := .F.
						 EndIf
					EndIf
				EndIf
				lEnd := .F.
	Case lCampo == 7  //Campo Imagem I
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_BITMAP"))) .Or. !empty(oModelCZG:GetValue("CZG_BITMAP"))) //o campo "CZG_BITMAP" fica desabilitado nos atributos acima
					lRet := .F.
		  		EndIf
		EndIf
	Case lCampo == 8 //Campo Formula R
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_VLFO"))) .Or. !empty(oModelCZG:GetValue("CZG_VLFO"))) //o campo "CZG_VLFO" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 9  //Campo Memo M
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "T" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_VLMEMO"))) .Or. !empty(oModelCZG:GetValue("CZG_VLMEMO"))) //o campo "CZG_VLMEMO" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 10  //Campo Tabela
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "O" )
				If ((empty(oModelCZG:GetValue("CZG_VLTB"))) .Or. !empty(oModelCZG:GetValue("CZG_VLTB"))) //o campo "CZG_VLTB" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 11  //Afastamento Inferior     O Tolerancia
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" )
				If ((empty(oModelCZG:GetValue("CZG_AFINF"))) .Or. !empty(oModelCZG:GetValue("CZG_AFINF"))) //o campo "CZG_AFINF" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf
	Case lCampo == 12  //Afastamento Superior     O Tolerancia
		 If (cTpAtrib == "F" .Or. ;
		 		cTpAtrib == "C" .Or. ;
			   cTpAtrib == "N" .Or. ;
			   cTpAtrib == "D" .Or. ;
			   cTpAtrib == "A" .Or. ;
			   cTpAtrib == "L" .Or. ;
			   cTpAtrib == "I" .Or. ;
			   cTpAtrib == "R" .Or. ;
			   cTpAtrib == "M" .Or. ;
			   cTpAtrib == "T" )
				If ((empty(oModelCZG:GetValue("CZG_AFSUP"))) .Or. !empty(oModelCZG:GetValue("CZG_AFSUP"))) //o campo "CZG_AFSUP" fica desabilitado nos atributos acima
					lRet := .F.
				EndIf
		EndIf

 	Case lCampo == 13
		If (!empty(oModelCZG:GetValue("CZG_TPAB"))) //o campo CZG_TPAB fica desabilitado
			lRet := .F.
		EndIf

EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104FX
Tela para cadastrar o valor da faixa

@author Jefferson Arthur Guermandi
@since 07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function PCPA104FX()
Local oMdl   	:= FWModelActive()
Local oMdlF3 	:= oMdl:GetModel('CZGDETAIL')
Local aCpos   	:= {}       	//Array com os dados
Local aRet    	:= {}       	//Array do retorno da opcao selecionada
Local oDlg                  	//Objeto Janela
Local oLbx                  	//Objeto List box
Local cTitulo 	:= "Campos"  	//Titulo da janela --Campos do sitema
Local cNoCpos 	:= ""
Local cDescr  	:= "X3_TITULO"
Local lRet    	:= .F.
Local cVlIniFx, cVlFinFx
Local cVlFx := 0

DbSelectArea("CZB")
CZB->(dbSetOrder(1))
CZB->(dbSeek(xFilial("CZB") + (AllTrim(oMdlF3:GetValue('CZG_CDAB')))))

cVlIniFx := CZB->CZB_VLBGFX
cVlFinFx := CZB->CZB_VLEDFX

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

@ 010,010 SAY STR0001 SIZE 60, 7 OF oDlg PIXEL  //'Limite Faixa Inferior'
@ 010,130 MSGET strtran(cValtoChar(cVlIniFx),".",",") SIZE 55,11 OF oDlg PIXEL WHEN .F.
@ 030,010 SAY STR0003 SIZE 60, 7 OF oDlg PIXEL  //'Valor da Faixa'
@ 030,130 MSGET cVlFx SIZE 60,08 OF oDlg PIXEL Valid IIf(ValidaValor(cVlIniFx, cVlFinFx,(cVlFx)),.T.,.F.) PICTURE '@E 99,999,999.9999'
@ 050,010 SAY STR0002 SIZE 60, 7 OF oDlg PIXEL  //'Limite Faixa Superior'
@ 050,130 MSGET strtran(cValtoChar(cVlFinFx),".",",") SIZE 55,11 OF oDlg PIXEL WHEN .F.

DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION ( eventBtn(@oDlg,"CONFIRM",@oMdlF3,cVlFx))  ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaValor
Funcao de validacao do valor
@param
@return

@author  Jefferson Arthur Guermandi
@since  10/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaValor(cVlIniFx, cVlFinFx, cVlFx)

If (cVlFx < cVlIniFx)
	Alert(STR0013) //"Valor deve ser maior ou igual o valor inicial da faixa."
	Return .F.
EndIf

If (cVlFx > cVlFinFx)
	Alert(STR0014) //"Valor deve ser menor ou igual o valor final da faixa."
	Return .F.
EndIf

Return  .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} eventBtn
Funcao de Evento do Botao da Faixa
@param
@return

@author  Jefferson Arthur Guermandi
@since  10/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function eventBtn(oDlg,cTpBtn,oMdlF3,cVlFx)

	Local oView := Nil
	
	lEnd		:=	oDlg:End()
	lValid		:= .F.
	lExecuta	:= .F.
	
	oView		:=	FWViewActive()
	oMdlF3:SetValue('CZG_VLFX' ,cVlFx)
	oview:Refresh("VIEW_GRID")
	
	PCPA104VAL(6)
	
	lValid		:= .T.
	lExecuta	:= .T.
Return

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA103VER
Função que executa nova versao da ficha tecnica.

@author  Jefferson Arthur Guermandi
@since   07/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA104VER()
	
	Local iTamProd, iTamRec, iTamFTec
	Local lRet				:= .T.
	Local aArea			:= GetArea()	
	Local cChave			:= ""
	Local cQuery			:= ""
	Local cAlias			:= GetNextAlias()
	Local cTitulo			:= ""
	Local lCancela		:= .F.
	Local lConfirma		:= .F.
	Local cPrograma		:= ""
	Local nOperation		:= 0
	
	cVerFicha           := CZG->CZG_VRFH
	iTamProd            := len(AllTrim(CZG->CZG_CDAC))
	iTamRec             := len(AllTrim(CZG->CZG_CDRC))
	iTamFTec            := len(AllTrim(CZG->CZG_CDFATD))	
	
	cTempl   := CZG->CZG_CDMD
   	cProd    := CZG->CZG_CDAC
   	cRecur   := CZG->CZG_CDRC
   	cFamTec  := CZG->CZG_CDFATD
   	cAtrib   := CZG->CZG_CDAB
   	cVers    := CZG->CZG_VRFH	
	
	cParam104 := tipoFT(cProd, cRecur, cFamTec)
	
	DbSelectArea("CZG")
	CZG->(dbSetOrder(6))
	CZG->(dbSetOrder(1))
	
	If CZG->(MsSeek(xFilial("CZG") + cProd+cRecur+cTempl+cVers+cAtrib+cFamTec ))
		lWhen        := .F.
		__nOper      := OPER_COPIAR
		cTitulo      := STR0030 //"Cópia"
		cPrograma    := 'PCPA104'
		nOperation   := MODEL_OPERATION_INSERT
	
		oModel       := FWLoadModel( cPrograma )
		nOpVersao    := oModel:GetOperation()
		oModel:SetOperation( nOperation ) // Inclusão
		oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
		cExecVald := 'S'
	
		If !Empty(AllTrim(CZG->CZG_CDAC))
	  		oModel:SetValue("CZGMASTER","CZG_CDAC",CZG->CZG_CDAC)
		Else
	  		oModel:SetValue("CZGMASTER","CZG_CDAC","")
		EndIf
	
		If !Empty(AllTrim(CZG->CZG_CDRC))
	  		oModel:SetValue("CZGMASTER","CZG_CDRC",CZG->CZG_CDRC)
		Else
	  		oModel:SetValue("CZGMASTER","CZG_CDRC","")
		EndIf
	
		If !Empty(AllTrim(CZG->CZG_CDFATD))
	  		oModel:SetValue("CZGMASTER","CZG_CDFATD",CZG->CZG_CDFATD)
		Else
	  		oModel:SetValue("CZGMASTER","CZG_CDFATD","")
		EndIf
		
		//Fazer load dos novos registros no CZGDETAIL
		
		oModel:LoadValue('CZGMASTER','CZG_DTFH',DATE())
	
		oModel:LoadValue("CZGMASTER","CZG_CDMD",CZG->CZG_CDMD)
		lWhen        := .T.
	 	oModel:SetValue("CZGMASTER","CZG_VRFH", FichaNextVer(versaoFT() , 5))
	 	
	 	If lFichaIncos
			MSGINFO(STR0048)//O template relacionado a esta ficha possui novos atributos, será gerado uma nova versão com os mesmos inclusos.
			INSRGRIDATR(cCZGIncons)
		EndIf
	 	
		If !__lAutomacao
		nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
		oModel:DeActivate()
		EndIf
		__nOper      := 0
		nOpVersao  	 := 0
	EndIf
	
	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104TAB
Consulta padrão específica - tabelas do sistema (SX2)

@param
@return

@author  Jefferson Arthur Guermandi
@since   07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104TAB()
Local lRet
Local oModel     := FWModelActive()
Local oModelCZG  := oModel:GetModel('CZGDETAIL')
Private cVLTB    := oModelCZG:GetValue('CZG_VLTB')

lValid := .F.
lExecuta := .F.

lRet:=PCPA104CTAB()
oModel     := FWModelActive()
oModelCZG  := oModel:GetModel('CZGDETAIL')
oModelCZG:SetValue('CZG_VLTB',AllTrim(cVLTB))
lValid := .F.
lExecuta := .T.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104TAB
Consulta padrão específica - tabelas do sistema (SX2)

@param
@return

@author  Jefferson Arthur Guermandi
@since   07/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104CTAB()
	Local oMdl   	:= FWModelActive()
	Local oMdlF3 	:= oMdl:GetModel('CZGDETAIL')
	Local aCpos   	:= {}      		//Array com os dados
	Local aRet    	:= {}       	//Array do retorno da opcao selecionada
	Local oDlg                  	//Objeto Janela
	Local oLbx                  	//Objeto List box
	Local cTitulo 	:= STR0012  	//Titulo da janela --Tabela
	Local cNoCpos 	:= ""
	Local lRet    	:= .F.
   Local cTab     := ""
   Local cTabAux  := ""
   Local cCampo   := ""
   Local cDescricao := ""
	
	//=======================
	// Procurar campo na CDB
	//=======================
	DbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	CZB->(dbSeek(xFilial("CZB") + (AllTrim(oMdlF3:GetValue('CZG_CDAB')))))

	cTab 	     := AllTrim(CZB->CZB_VLPAAB)
	cCampo 	  := AllTrim(CZB->CZB_IDCDG)
	cDescricao := AllTrim(CZB->CZB_IDDS)
	
	If !__lAutomacao
		dbSelectArea(cTab)
		dbSetOrder(1)	
	
		&(cTab)->(dbSeek(xFilial(cTab)))


		If At('_',cCampo) == 3
			cTabAux := SubStr(cTab,2,2)
		Else
			cTabAux := cTab
		EndIf
		//=====================================================
		// Carrega o vetor com as tabelas do sistema
		//=====================================================
		While (!&(cTab)->(Eof()) .And. (&((cTab)+"->"+cTabAux+"_FILIAL") == xFilial(cTab)))
		aAdd( aCpos, { &(cTab+'->'+cCampo), &(cTab+'->'+cDescricao) } )

		&(cTab)->(DbSkip())
		Enddo

		If Len( aCpos ) > 0

			DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
														//Codigo, Descrição
			@ 10,10 LISTBOX oLbx FIELDS HEADER STR0010, STR0011  SIZE 230,95 OF oDlg PIXEL

			oLbx:SetArray( aCpos )
			oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
			oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

			DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTER

			If Len(aRet) > 0
				lRet := .T.
				cVlTb := AllTrim(aret[1])
			EndIf
		Else
			Help( ,, 'Help',, STR0022 + cTab, 1, 0 ) // Não existem dados na tabela
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validacao e resolucao da Formula

@param
@return

@author  Jefferson Arthur Guermandi
@since   25/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidForm(cFormula)
Local nJ
Local nK
Local nI
Local cAtributo
Local nCount := 0
Local oModel    := FwModelActive()
Local lPassou
//Local oModelDet := oModel:GetModel('CZGDETAIL')

cFormula := AllTrim(cFormula)
lPassou := .F.

For nJ := 1 To Len(cFormula)
	If IsAlpha(SubStr(cFormula,nJ))
		nCount := 0
		For nK := nJ To Len(cFormula)
			If SubStr(cFormula, nK+1,1) == "("
				Help( ,, 'Help',, STR0015 , 1, 0 ) // Parênteses aberto sem estar com um operador válido. Favor, verificar
				Return .F.
			EndIf
			nCount++
			If SubStr(cFormula, nK+1,1) $ "/*+.=^-()"
				Exit
			EndIf
		Next
		cAtributo := SubStr(cFormula, nJ, nCount)
		lPassou := .F.
		For nI := 1 To oModel:GetModel('CZGDETAIL'):GetQtdLine()
			oModel:GetModel('CZGDETAIL'):GoLine(nI)
			If oModel:GetModel('CZGDETAIL'):GetValue('CZG_TPAB') == 'N' .AND. ;
				AllTrim(oModel:GetModel('CZGDETAIL'):GetValue('CZG_NMAB')) == AllTrim(cAtributo)
				cFormNova := cFormNova + CValToChar(oModel:GetModel('CZGDETAIL'):GetValue('CZG_VLNR'))
				lPassou := .T.
				Exit
			EndIf
		Next

		If !lPassou
			cFormNova := "0"
			Return cFormNova
		EndIf
	/*	DbSelectArea("CZB")
		CZB->(DbSetOrder(2))
		CZB->(DbGoTop())
		If CZB->(dbSeek(xFilial("CZB")+cAtributo))
		   //Verificar se existe valor, se não existir exibir resultado em branco da formula
			If Len(AllTrim(CZB->CZB_VLPAAB)) > 0
	  			cFormNova := cFormNova + AllTrim(CZB->CZB_VLPAAB)
	      Else
	         cFormNova := ""
	         Exit
	      EndIf
		EndIf    */

		nJ := nK

 	Else
 	   If IsDigit(SubStr(cFormula,nJ))
			nCount := 0
			For nK := nJ To Len(cFormula)
				If SubStr(cFormula, nK+1,1) == "("
					Help( ,, 'Help',, STR0015 , 1, 0 ) // Parênteses aberto sem estar com um operador válido. Favor, verificar
					Return .F.
				EndIf
				nCount++
				If SubStr(cFormula, nK+1,1) $ "/*+.=^-()"
					Exit
				EndIf
			Next
			cFormNova := cFormNova + SubStr(cFormula, nJ, nCount)
			nJ := nK
		Else
			If (SubStr(cFormula,nJ,1) $ '()')
			cFormNova := cFormNova + SubStr(cFormula,nJ,1)
			Else
		  		If SubStr(cFormula, nJ,1) $ "/*+.=^-"
					cFormNova := cFormNova + SubStr(cFormula, nJ,1)
		  		EndIf
		  	EndIf
		EndIf
	EndIf
Next


If SubStr(cFormula,Len(cFormula),1) $ "/*+.=^-("
	Help( ,, 'Help',, STR0016, 1, 0 ) // Fórmula incorreta, favor verificar
	Return .F.
EndIf

Return cFormNova
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VPosParenteses
Localiza posicao parenteses na Formula
@param
@return

@author  Jefferson Arthur Guermandi
@since   25/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VPosParenteses(cFormula)


Local nInd
Local nInd2
Local nNumParenteses := 0

aParenteses := {0, 0}

For nInd := 1 TO Len(cFormula)
	If PCPA104VCaracter(SubStr(cFormula,nInd,1),'(')
		nNumParenteses := nNumParenteses + 1

		For nInd2 := nInd + 1 To Len(cFormula)
			If PCPA104VCaracter(SubStr(cFormula,nInd2,1),'(')
				nNumParenteses  := nNumParenteses + 1
			EndIf
			If PCPA104VCaracter(SubStr(cFormula,nInd2,1),')')
				nNumParenteses := nNumParenteses - 1

				If nNumParenteses == 0
					aParenteses := {nInd, nInd2}
					Return aParenteses
				EndIf

			EndIf
		Next

		Exit
	EndIf
Next

Return aParenteses
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VCaracter
Localiza caracter
@param
@return

@author  Jefferson Arthur Guermandi
@since   25/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VCaracter(cChar,cConteudo)
Local nInd

For nInd := 1 To Len(cConteudo)
	If cChar == SubStr(cConteudo,nInd,1)
		Return .T.
	EndIf
Next

Return .F. //--- PCPA104VCaracter


//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VLL
Consulta padrão específica - valor e conteudo da lista
@param
@return

@author  Jefferson Arthur Guermandi
@since   28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VLL()
	Local oMdl   	:= FWModelActive()
	Local oMdlF3 	:= oMdl:GetModel('CZGDETAIL')
	Local aRet    	:= {}       	//Array do retorno da opcao selecionada
	Local aItems	:= {}
	Local oDlg                  	//Objeto Janela
	Local cTitulo 	:= STR0012  	//Titulo da janela --Campos do sitema
	Local cNoCpos 	:= ""
	Local lRet    	:= .F.
	Local nI		:= 0
	Local aDadosCZC := {}
	Local cConteudo := ""
	Local cValor    := ""
	Local oView 	:= NIL
	Local lComposta := .F.
	Private cCombo1
	Private oLbx                  	//Objeto List box
	Private aCpos   := {}      		//Array com os dados

	lValid := .F.

	DbSelectArea("CZC")
	CZC->(dbSetOrder(1))
	CZC->(dbSeek(xFilial("CZC") + (AllTrim(oMdlF3:GetValue('CZG_CDAB')))))

	//=====================================================
	// Carrega o vetor com as opções cadastradas
	//=====================================================
	While ((!CZC->(Eof())) .And. (CZC->CZC_CDAB == AllTrim(oMdlF3:GetValue('CZG_CDAB'))))
		if !Empty(CZC->CZC_VLTB)
			lComposta := .T.
		EndIf

		//If aDadosCZC[nI][4] == .F.
		aAdd( aCpos, { CZC->CZC_NMTB, CZC->CZC_VLTB } )
		CZC->(DbSkip())
		//Endif
	EndDo

	If Len( aCpos ) > 0

		aCpos := aSort( aCpos,,,{|x,y| x[1] < y[1]})
		If !__lAutomacao
		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

		@ 10,10 LISTBOX oLbx FIELDS HEADER STR0017, STR0018  SIZE 230,95 OF oDlg PIXEL

		oLbx:SetArray( aCpos )
		oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
		oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

		If lComposta
			@ 109,10  SAY oAcao VAR STR0050 OF oDlg PIXEL //"Ordenação Lista:"
			aItems	:= {STR0051,STR0052} //'Conteudo' 'Valor'
			cCombo1	:= aItems[1]
			oCombo1 := TComboBox():New(107,55,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,45,20,oDlg,,{||MudaOrdem()},,,,.T.,,,,,,,,,'cCombo1')
		EndIf

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
		EndIf
		If Len(aRet) > 0
			lRet 		:= .T.
			cConteudo 	:= aRet[1]
			cValor  	:= aRet[2]
			oView 		:=	FWViewActive()
			oMdlF3:GetStruct():SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { || .t. } )
			lExecuta 	:= .F.
			oMdlF3:SetValue('CZG_VLLST',cConteudo)
			lValid 		:= .F.
			oMdlF3:SetValue('CZG_VLNR', val(cValor))
			lValid 		:= .F.
			oMdlF3:GetStruct():SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { ||PCPA104WGRID(3)  } )
			oview:Refresh()
			lExecuta 	:= .T.
		EndIf
	EndIf
   
Return lRet
//------------------------------------------------------------
Static Function MudaOrdem()
	If cCombo1 == STR0051 //'Conteudo'
		aCpos := aSort( aCpos,,,{|x,y| x[1] < y[1]})
	ElseIf cCombo1 == STR0052 //'Valor'
		aCpos := aSort( aCpos,,,{|x,y| x[2] < y[2]})
	EndIf
	oLbx:Refresh()
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VLista
Valida se o valor existe na lista
@param
@return

@author  Jefferson Arthur Guermandi
@since   11/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VLista()
	Local oMdl   	:= FWModelActive()
	Local oMdlF3 	:= oMdl:GetModel('CZGDETAIL')
	Local lRet    	:= .T.
   
   If !Empty(oMdlF3:GetValue('CZG_VLLST'))
      If !ExistCpo('CZC',oMdlF3:GetValue("CZG_CDAB")+oMdlF3:GetValue('CZG_VLLST'),2)
      	lRet := .f.
      EndIf
   EndIf

Return lRet
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VTabela
Validações dos campos da GetDados

@param

@author Jefferson Arthur Guermandi
@since 10/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA104VTabela()
Local lRet := .T.
Local cTab := '   ',cTabAux,cCampo := ''
Local aOldArea := GetArea()
Local oModel    := FWModelActive()
Local oModelCZG := oModel:GetModel('CZGDETAIL') 

	DbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	If CZB->(dbSeek(xFilial("CZB") + oModelCZG:GetValue("CZG_CDAB")))

		cTab   := AllTrim(CZB->CZB_VLPAAB)
		cCampo := AllTrim(CZB->CZB_IDCDG)

		If At('_',cCampo) == 3
			cTabAux := SubStr(cTab,2,2)
		Else
			cTabAux := cTab
		EndIf

		cAliasQry := GetNextAlias()
		cQuery := " SELECT 1 "
		cQuery += " FROM " + RetSQLName( cTab )
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += "   AND "+cTabAux+"_FILIAL = '"+xFilial(cTab)+"'"		
		cQuery += "   AND "+cCampo+" = '"+M->CZG_VLTB+"'"
		
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(Eof())
			lRet := .f.
		End
		(cAliasQry)->(dbCloseArea())
	Else
		lRet := .f.
	EndIf
	If !lRet
		Help( ,, 'Help',,STR0023, 1, 0 ) //"O conteúdo informado é inválido!"
	EndIf

RestArea(aOldArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldOk104
Funcao de validacao do confirmar
@param
@return

@author  Jefferson Arthur Guermandi
@since  30/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldOk104(oModel)

	Local aAreaAux := {}
	Local aColsCZG := {}
	Local aOldArea := GetArea()
	Local cAlias   := GetNextAlias()
	Local cCodProd := oModel:GetModel('CZGMASTER'):GetValue('CZG_CDAC')
	Local cMsg := ""
	Local cQuery := ""
	Local cTemplate := ""
	Local cTpAtrib := ""
	Local cVerMax := 0
	Local iTam   := ""
	Local lRet 	 := .F.
	Local nJ, nX, nI, nScan
	Local nOp  := oModel:GetOperation()
	Local nRecno := 0
	
	//Executa somente para nova versao e se a ficha não estiver inconsistente com a template.
	If nOpVersao == 1 .AND. lFichaIncos == .F.
		iTam          := LEN(oModel:GetModel('CZGDETAIL'):ADATAMODEL)

		If Empty(cCodProd)
			DbSelectArea("SB1")
			DbSetOrder(1)
			SB1->(MsSeek(xFilial("SB1")+cProd))

			If SB1->B1_MSBLQL != '2'
				Help( ,, 'Help',, STR0063, 1, 0 ) //Produto bloqueado. Verifique o cadastro de produtos!
				lRet := .F.
				Return lRet
			EndIf
		EndIf	
	
		//cQuery := " SELECT ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),CZG_VLMEMO)),'') AS MEMO, * "
		cQuery := "SELECT CZG.R_E_C_N_O_, "
		cQuery += "       CZG.CZG_TPAB, "
		cQuery += "       CZG.CZG_CDAB, "
		cQuery += "       CZG.CZG_VLFG, "
		cQuery += "       CZG.CZG_VLCHAR, "
		cQuery += "       CZG.CZG_VLDT,   "
		cQuery += "       CZG.CZG_VLFX,   "
		cQuery += "       CZG.CZG_VLLST,  "
		cQuery += "       CZG.CZG_VLNR,   "
		cQuery += "       CZG.CZG_BITMAP, "
		cQuery += "       CZG.CZG_VLFO,   "
		cQuery += "       CZG.CZG_VLTB,   "
		cQuery += "       CZG.CZG_AFSUP,  "
		cQuery += "       CZG.CZG_AFINF   "
		cQuery += " FROM " + RetSqlName('CZG') + " CZG "
	
		cQuery += " WHERE CZG.CZG_VRFH = '" + cVerFicha + "' "
		cQuery += " AND CZG.CZG_CDAC   = '" + oModel:GetModel('CZGMASTER'):GetValue('CZG_CDAC') + "'"
		cQuery += " AND CZG.CZG_CDRC   = '" + oModel:GetModel('CZGMASTER'):GetValue('CZG_CDRC') + "'"
		cQuery += " AND CZG.CZG_CDFATD = '" + oModel:GetModel('CZGMASTER'):GetValue('CZG_CDFATD') + "'"
		cQuery += " AND CZG.CZG_FILIAL = '" + xFilial("CZG") + "' "
		cQuery += " AND CZG.D_E_L_E_T_ = '' "
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
		DbSelectArea( cAlias )
		
		While ((cAlias)->(!Eof() ))
			cTpAtrib  := (cAlias)->CZG_TPAB
	
	
			For nJ := 1 To iTam
				oModel:GetModel('CZGDETAIL'):GoLine( nJ )
				If (!(oModel:GetModel('CZGDETAIL'):IsDeleted(nJ))  .And.;
				     (AllTrim(oModel:GetModel('CZGDETAIL'):GetValue("CZG_CDAB")) == AllTrim((cAlias)->CZG_CDAB)))
					Do Case
						Case cTpAtrib == "F"
							If (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLFG") <> (cAlias)->CZG_VLFG)
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "C"
							If (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLCHAR") <> (cAlias)->CZG_VLCHAR)
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "N"
							If (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLNR") <> (cAlias)->CZG_VLNR)
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "D"
							If (!Empty(oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLDT")) .And.;
								 (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLDT") <> StoD((cAlias)->CZG_VLDT)))
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "A"
							If (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLFX") <> (cAlias)->CZG_VLFX)
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "L"
							If ((oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLLST") <> (cAlias)->CZG_VLLST) .Or.;
							    (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLNR") <> (cAlias)->CZG_VLNR))
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "I"
							If (oModel:GetModel('CZGDETAIL'):GetValue("CZG_BITMAP") <> (cAlias)->CZG_BITMAP)
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "R"
							If ((oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLFO") <> (cAlias)->CZG_VLFO) .Or.;
							    (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLNR") <> (cAlias)->CZG_VLNR))
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "T"
							If (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLTB") <> (cAlias)->CZG_VLTB)
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "O"
							If ((oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLNR") <> (cAlias)->CZG_VLNR) .Or.;
							    (oModel:GetModel('CZGDETAIL'):GetValue("CZG_AFSUP") <> (cAlias)->CZG_AFSUP) .Or.;
								(oModel:GetModel('CZGDETAIL'):GetValue("CZG_AFINF") <> (cAlias)->CZG_AFINF))
								lRet:=  .T.
								Exit
							EndiF
						Case cTpAtrib == "M"
							aAreaAux := GetArea()
							nRecno := (cAlias)->R_E_C_N_O_
							dbSelectArea("CZG")
							CZG->(dbSetOrder(1))
							CZG->(dbGoTo(nRecno))
							If (oModel:GetModel('CZGDETAIL'):GetValue("CZG_VLMEMO") <> CZG->CZG_VLMEMO)
								lRet:=  .T.
								RestArea(aAreaAux)
								Exit
							EndiF
							RestArea(aAreaAux)
					EndCase
				EndIf
			Next
	
		   //Se achou uma mudanca ja sai do while e grava
		  	If lRet
		   	Exit
		  	Else
		  		(cAlias)->(DbSkip())
		  	EndIf
		EndDo
	Else
		lRet := .T.
	EndIf
	
	If !lRet
		Help( ,, 'Help',, STR0019, 1, 0 ) //Não houve alterações na nova ficha técnica e não será gerada. Verifique!
	EndIf
	
	//Valida se algum atributo esta sem valor
	If (nOp == 3 .Or. nOp == 4)
		Aadd(aColsCZG,{'C',{'CZG_VLCHAR'}})
		Aadd(aColsCZG,{'F',{'CZG_VLFG'}})
		Aadd(aColsCZG,{'N',{'CZG_VLNR'}})
		Aadd(aColsCZG,{'D',{'CZG_VLDT'}})
		Aadd(aColsCZG,{'A',{'CZG_VLFX'}})
		Aadd(aColsCZG,{'L',{'CZG_VLLST'}})
		Aadd(aColsCZG,{'I',{'CZG_BITMAP'}})
		Aadd(aColsCZG,{'R',{'CZG_VLFO'}})
		Aadd(aColsCZG,{'O',{'CZG_VLNR','CZG_AFSUP','CZG_AFINF'}})
		Aadd(aColsCZG,{'T',{'CZG_VLTB'}})
		Aadd(aColsCZG,{'M',{'CZG_VLMEMO'}})
	
	   cTemplate := oModel:GetModel('CZGMASTER'):GetValue("CZG_CDMD")
	
		For nI := 1 to oModel:GetModel('CZGDETAIL'):GetQtdLine()
			oModel:GetModel('CZGDETAIL'):GoLine(nI)
			If !Empty(oModel:GetModel('CZGDETAIL'):GetValue("CZG_CDAB"))
				nScan := aSCAN(aColsCZG, {|x| AllTrim(Upper(x[1])) == oModel:GetModel('CZGDETAIL'):GetValue('CZG_TPAB') })
	
				For nX := 1 to Len(aColsCZG[nScan][2])
					If  ((!(oModel:GetModel('CZGDETAIL'):IsDeleted(nI))) .And.;
						  (Empty(oModel:GetModel('CZGDETAIL'):GetValue(aColsCZG[nScan][2][nX]))))
					  //	If nOpVersao == 1
					   		oModel:GetModel('CZGDETAIL'):GoLine(nI)
					  //  	Else
					  //  		oModel:GetModel('CZGDETAIL'):GoLine(nX)
					  // 	EndIf
	
	
					   //Verificar se o atributo e obrigatorio
						DbSelectArea("CZE")
						CZE->(dbSetOrder(1))
						CZE->(dbSeek(xFilial("CZE") + cTemplate + (AllTrim(oModel:GetModel('CZGDETAIL'):GetValue("CZG_CDAB")))))
	
					   If (CZE->CZE_LGOB == "1")
							DbSelectArea("CZB")
							CZB->(dbSetOrder(1))
							CZB->(dbSeek(xFilial("CZB") + (AllTrim(oModel:GetModel('CZGDETAIL'):GetValue("CZG_CDAB")))))
							If CZB->CZB_STAB <> "2"
	   						Help( ,, 'Help',, STR0020 +AllTrim(CZB->CZB_DSAB)+ STR0021, 1, 0 )
	   						oModel:GetModel('CZGDETAIL'):GoLine(nI)
	   						Return .F.
	   				   EndIf
						EndIf
					EndIf
				Next
			EndIf
		Next
	EndIf
	
	If IsInCallStack("PCPA104COP") //Se está realizando a cópia
	   
	   cVerMax := versaoFT(oModel:GetModel("CZGMASTER"):GetValue("CZG_CDAC"))
	   oModel:SetValue("CZGMASTER","CZG_VRFH",PADL(Val(cVerMax) + 1,5,"0"))
	
	   aTemplates := PCPA104CTP(oModel:GetModel("CZGMASTER"):GetValue("CZG_TPMP"),oModel:GetModel("CZGMASTER"):GetValue("CZG_CDGRIV"),oModel:GetModel("CZGMASTER"):GetValue("CZG_CDRC"),oModel:GetModel("CZGMASTER"):GetValue("CZG_CDFATD"))
	   If !PCPA104FIL(.F.)
	      
	      Do Case
	         Case cParam104 == 1
	            cMsg := M->CZG_CDMD + " " + STR0037//"Produto não disponível para o template"
	         Case cParam104 == 2
	            cMsg := M->CZG_CDMD + " " + STR0038 //"Recurso não disponível para o template"
	         Case cParam104 == 3
	            cMsg := M->CZG_CDMD + " " + STR0039 //"Produto/Recurso não disponível para o template"
	         Case cParam104 == 4
	            cMsg := M->CZG_CDMD + " " + STR0040 //"Família técnica não disponível para o template"
	         Case cParam104 == 5
	            cMsg := M->CZG_CDMD + " " + STR0041 //"Família técnica/Recurso não disponível para o template"
	      EndCase
	      
	      Help( ,, 'Help',, cMsg, 1, 0 )
	      lRet := .F.
	   EndIf
	   
	EndIf
	
	RestArea(aOldArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Get_Ficha_Tecnica
Funcao de retorna template e versão
@param
@return

@author  Jefferson Arthur Guermandi
@since  31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
	Function Get_Ficha_Tecnica(cProduto, cRecurso, cFamTecn, aFTecnica)
	Local aOldArea := GetArea()
	Local iTamProd, iTamRec, iTamFTec
	Local cAlias   := GetNextAlias()
	
	Default cProduto := ""
	Default cRecurso := ""
	Default cFamTecn := ""
	Default aFTecnica := {}
	
	iTamProd := len(AllTrim(cProduto))
	iTamRec  := len(AllTrim(cRecurso))
	iTamFTec := len(AllTrim(cFamTecn))

	If !__lAutomacao
		//Verifica se não foi passado nenhum parametro
		If ((iTamProd == 0) .And. (iTamFTec == 0) .And.  (iTamRec == 0)) 
			Help( ,, 'Help',, STR0025, 1, 0 )   //"Não foi passado nenhum parâmetro"
			Return
		EndIf
	EndIf
	//retorna a ultima versao de acordo com o where
	cQuery := " SELECT MAX(CZG.CZG_VRFH) VERSAO, "
	cQuery +=        " CZG.CZG_CDAC,"
	cQuery +=        " CZG.CZG_CDRC,"
	cQuery +=        " CZG.CZG_CDMD "
	cQuery += " FROM " + RetSqlName('CZG') + " CZG "
	
	cQuery += " WHERE CZG.CZG_FILIAL = '" + xFilial("CZG") + "' "
	cQuery += " AND CZG.D_E_L_E_T_ = '' "
	
	If (iTamRec == 0) .And. (iTamFTec == 0)      //Somente Produto
		cQuery += " AND CZG.CZG_CDAC = '" + cProduto + "'"
		cQuery += " AND CZG.CZG_CDRC = ''"
	      cQuery += " AND CZG.CZG_CDFATD = ''"
	Else
		If (iTamProd == 0) .And. (iTamFTec == 0)    //Somente Recurso
			cQuery += " AND CZG.CZG_CDRC = '" + cRecurso + "'"
	   	cQuery += " AND CZG.CZG_CDAC = ''"
	         cQuery += " AND CZG.CZG_CDFATD = ''"
		Else
	  		If (iTamProd == 0) .And. (iTamRec == 0)   //Somente Familia Tecnica
				cQuery += " AND CZG.CZG_CDFATD = '" + cFamTecn + "'"
				cQuery += " AND CZG.CZG_CDRC = ''"
	      	cQuery += " AND CZG.CZG_CDAC = ''"
	      Else
		  		If (iTamFTec == 0)    //Produto x Recurso
					cQuery += " AND CZG.CZG_CDAC = '" + cProduto + "'"
					cQuery += " AND CZG.CZG_CDRC = '" + cRecurso + "'"
				Else
					If (iTamProd == 0)    //Familia Tecnica x Recurso
						cQuery += " AND CZG.CZG_CDFATD = '" + cFamTecn + "'"
						cQuery += " AND CZG.CZG_CDRC = '" + cRecurso + "'"
		         EndIf
		      EndIf
		   EndIf
		EndIf
	EndIf
	
	cQuery += " GROUP BY CZG_CDAC,"
	cQuery +=          " CZG_CDRC,"
	cQuery +=          " CZG_CDMD "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
	DbSelectArea( cAlias )
	
	While ((cAlias)->(!Eof() ))
		Aadd(aFTecnica,{Alltrim((cAlias)->(CZG_CDAC)), AllTrim((cAlias)->(CZG_CDRC)), AllTrim((cAlias)->(CZG_CDMD)),(cAlias)->VERSAO})
		(cAlias)->(DbSkip())
	End
	(cAlias)->(dbCloseArea())
	RestArea(aOldArea)
	
Return aFTecnica
//-------------------------------------------------------------------
/*/{Protheus.doc} Get_Atributo_Ficha_Tecnica
Funcao que retorna atributos da ficha
@param
@return

@author  Jefferson Arthur Guermandi
@since  01/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function Get_Atributo_Ficha_Tecnica(cProduto, cRecurso, cFamTecn, cTemplate, cVersao, cAtributo, aAtributo)
Local aOldArea := GetArea()
Local iTamProd, iTamRec, iTamFTec
Local cAlias   := GetNextAlias()
Local cTpAtrib := ""

Default cProduto := ""
Default cRecurso := ""
Default cFamTecn := ""
Default cTemplate:= ""
Default cAtributo := ""
Default aAtributo :={}

iTamProd := len(AllTrim(cProduto))
iTamRec  := len(AllTrim(cRecurso))
iTamFTec := len(AllTrim(cFamTecn))
iTamTempla := len(AllTrim(cTemplate))
iTamVersao := len(AllTrim(cVersao))
iTamAtrib  := len(AllTrim(cAtributo))

//Verifica se não foi passado nenhum parametro
If !__lAutomacao
If ((iTamProd == 0) .And. (iTamFTec == 0) .And. ;
     (iTamRec == 0) .And. (iTamTempla == 0) .And. ;
     (itamVersao == 0) .And. (iTamAtrib == 0))
	Help( ,, 'Help',, "Não foi passado nenhum parâmetro", 1, 0 )
	Return
EndIf
EndIf

If (iTamTempla == 0) .And. (iTamVersao == 0) //Caso não tenha template e versão retorna tributos da ultima versao
	DbSelectArea( "CZG" )
	CZG->(dbSetOrder(6))
	CZG->(dbGoBottom())

   If CZG->(dbSeek(xFilial("CZG") + CZG->CZG_VRFH))
   	While (!CZG->(Eof()))
			cTpAtrib := AllTrim(CZG->CZG_TPAB)
			aAtributo := PCPA104BAtributo(cTpAtrib, aAtributo)
   		CZG->(DbSkip())
   	EndDo
   EndIf
Else
	//retorna a ultima versao de acordo com o where
	cQuery := " SELECT MAX(CZG.CZG_VRFH) VERSAO, "
	cQuery +=        " CZG.CZG_CDAC, "
	cQuery +=        " CZG.CZG_CDRC, "
	cQuery +=        " CZG.CZG_CDMD, "
	cQuery +=        " CZG.CZG_CDAB, "
	cQuery +=        " CZG.CZG_CDFATD "

	cQuery += " FROM " + RetSqlName('CZG') + " CZG "

	cQuery += " WHERE CZG.CZG_FILIAL = '" + xFilial("CZG") + "' "
 	cQuery += " AND CZG.CZG_CDMD = '" + cTemplate + "'"
	cQuery += " AND CZG.D_E_L_E_T_ = '' "

	If (iTamVersao <> 0)
		cQuery += " AND CZG.CZG_VRFH = '" + cVersao + "'"
		If (iTamAtrib <> 0)
			cQuery += " AND CZG.CZG_CDAB = '" + cAtributo + "'"
  		EndIf
	EndIf

	If (iTamRec == 0) .And. (iTamFTec == 0)      //Somente Produto
		cQuery += " AND CZG.CZG_CDAC = '" + cProduto + "'"
		cQuery += " AND CZG.CZG_CDRC = ''"
      cQuery += " AND CZG.CZG_CDFATD = ''"
	Else
		If (iTamProd == 0) .And. (iTamFTec == 0)    //Somente Recurso
			cQuery += " AND CZG.CZG_CDRC = '" + cRecurso + "'"
	   	cQuery += " AND CZG.CZG_CDAC = ''"
         cQuery += " AND CZG.CZG_CDFATD = ''"
		Else
	  		If (iTamProd == 0) .And. (iTamRec == 0)   //Somente Familia Tecnica
				cQuery += " AND CZG.CZG_CDFATD = '" + cFamTecn + "'"
				cQuery += " AND CZG.CZG_CDRC = ''"
	      	cQuery += " AND CZG.CZG_CDAC = ''"
	      Else
		  		If (iTamFTec == 0)    //Produto x Recurso
					cQuery += " AND CZG.CZG_CDAC = '" + cProduto + "'"
					cQuery += " AND CZG.CZG_CDRC = '" + cRecurso + "'"
				Else
					If (iTamProd == 0)    //Familia Tecnica x Recurso
						cQuery += " AND CZG.CZG_CDFATD = '" + cFamTecn + "'"
						cQuery += " AND CZG.CZG_CDRC = '" + cRecurso + "'"
		         EndIf
		      EndIf
		   EndIf
		EndIf
	EndIf
	cQuery += " GROUP BY CZG.CZG_CDAC, "
	cQuery +=          " CZG.CZG_CDRC, "
	cQuery +=          " CZG.CZG_CDFATD, "
	cQuery +=          " CZG.CZG_CDMD, "
	cQuery +=          " CZG.CZG_CDAB "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
	DbSelectArea( cAlias )

	While ((cAlias)->(!Eof() ))

		DbSelectArea("CZG")
		CZG->(dbSetOrder(1))
		If CZG->(dbSeek(xFilial("CZG")+(cAlias)->(CZG_CDAC)+(cAlias)->(CZG_CDRC)+(cAlias)->(CZG_CDMD)+(cAlias)->(VERSAO)+(cAlias)->(CZG_CDAB)+(cAlias)->(CZG_CDFATD)))
			cTpAtrib  := AllTrim(CZG->CZG_TPAB)
			aAtributo := PCPA104BAtributo(cTpAtrib, aAtributo)
		EndIf
	   (cAlias)->(DbSkip())
	EndDo
(cAlias)->(dbCloseArea())
EndIf

RestArea(aOldArea)
Return   aAtributo

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104BAtributo
Funcao que retorna atributos da ficha
@param
@return

@author  Jefferson Arthur Guermandi
@since  01/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function PCPA104BAtributo(cTpAtrib, aAtributo)

			Do Case
				Case cTpAtrib == "F"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLFG})
				Case cTpAtrib == "C"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLCHAR})
				Case cTpAtrib == "N"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLNR})
				Case cTpAtrib == "D"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLDT})
				Case cTpAtrib == "A"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLFX})
				Case cTpAtrib == "L"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLLST ,CZG->CZG_VLNR})
				Case cTpAtrib == "I"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_BITMAP})
				Case cTpAtrib == "R"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLFO, CZG->CZG_VLNR})
				Case cTpAtrib == "T"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLTB})
				Case cTpAtrib == "O"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLNR, CZG->CZG_AFINF, CZG->CZG_AFSUP })
				Case cTpAtrib == "M"
 					aAdd(aAtributo,{Alltrim(CZG->CZG_CDAC), AllTrim(CZG->CZG_CDRC), AllTrim(CZG->CZG_CDMD), AllTrim(CZG->CZG_CDFATD), CZG->CZG_DTFH, AllTrim(CZG->CZG_CDAB),CZG->CZG_VLMEMO})
			EndCase


Return aAtributo
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104Tolerancia()
Valida se o valor superior da tolerancia
@param
@return

@author  Jefferson Arthur Guermandi
@since   12/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104Tolerancia()

	Local oMdl   	:= FWModelActive()
	Local oModelCZG:= oMdl:GetModel('CZGDETAIL')
	
	
	If !Empty(oModelCZG:GetValue('CZG_AFINF')) .And. !Empty(oModelCZG:GetValue('CZG_AFSUP'))
		If  oModelCZG:GetValue('CZG_AFSUP') < oModelCZG:GetValue('CZG_AFINF')
			Help( ,, 'Help',, STR0024, 1, 0 )//"Valor superior da tolerância deve ser maio o que valor inferior da tolerância."
			Return .F.
		Endif
	EndIf
	
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VRecurso
Valida se o recurso esta usado na SG2
@param
@return

@author  Jefferson Arthur Guermandi
@since   13/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VRecurso()
	Local aOldArea := GetArea()
	Local cAlias   := GetNextAlias()
	Local lRet    		:= .T.
	Local cQuery     	:= ""
	Local cRecurso    := ""
	Local cProduto    := ""

	If !__lAutomacao
		If Empty(AllTrim(M->CZG_CDRC))
			Return .T.
		EndIf
		
		If (Empty(AllTrim(M->CZG_CDRC)) .Or. !(ExistCpo("SH1",M->CZG_CDRC)))
			lRet := .F.
			Return lRet
		EndIf
	EndIf

	If (cParam104 == 3)   //somente se for recurso x Produto
		cRecurso := Iif(__lAutomacao,'',M->CZG_CDRC)
		cProduto := Iif(__lAutomacao,'',M->CZG_CDAC)
	
		cQuery := " SELECT COUNT(*) REGISTRO "
	
		cQuery += " FROM " + RetSqlName('SG2') + " SG2 "
	
		cQuery += " WHERE SG2.G2_RECURSO = '" + cRecurso + "' "
		cQuery += " AND SG2.G2_PRODUTO = '" + cProduto + "' "
		cQuery += " AND SG2.G2_FILIAL = '" + xFilial("SG2") + "' "
		cQuery += " AND SG2.D_E_L_E_T_ = '' "
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAlias, .F., .T.)
		DbSelectArea( cAlias )
	
		If (cAlias)->REGISTRO == 0
		    lRet := .F.
		 	 Help( ,, 'Help',, STR0026, 1, 0 ) // "O recurso escolhido não está no cadastro de operação do produto"
		    Return lRet
		EndIf
	EndIf
	
	If IsInCallStack("PCPA104COP") //se estiver realizando a Cópia
	   If cParam104 == 2 //Somente recurso
	      If cRecur == M->CZG_CDRC
	         Help( ,, 'Help',, STR0034, 1, 0 ) // "Não é possível realizar a cópia para o mesmo recurso."   
	         lRet := .F.
	      EndIf
	   Else
	      If cParam104 == 3 //Recurso x Produto
	         If !Empty(M->CZG_CDAC) .And. (M->CZG_CDAC == cProd .And. cRecur == M->CZG_CDRC)
	            Help( ,, 'Help',, STR0032, 1, 0 ) // "Não é possível realizar a cópia para o mesmo produto/recurso."   
	            lRet := .F.
	         EndIf  
	      Else
	         If cParam104 == 5 //Fam. téc. x recurso
	            If !Empty(M->CZG_CDFATD) .And. (cRecur == M->CZG_CDRC .And. cFamTec == M->CZG_CDFATD)
	               Help( ,, 'Help',, STR0035, 1, 0 ) // "Não é possível realizar a cópia para a mesma Família técnica/recurso."   
	               lRet := .F.
	            EndIf
	         EndIf
	      EndIf
	   EndIf
	EndIf
	RestArea(aOldArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104FIL
Função que irá indicar se o Template selecionado é permitido.

@param lSx3 Indica se a função é chamada pelo dicionário (.T) ou programa (.F.)

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104FIL(lSx3)
	Local cTemplate
	Default lSx3 := .t.
	
	If IsInCallStack('DPRA210') .Or. IsInCallStack('DPRA210VTP')
		cTemplate := M->DGN_CDMD
	Else
		cTemplate := M->CZG_CDMD
	EndIf
	
	If Len(aTemplates) > 0
		If aSCAN(aTemplates, {|x| x[1] == IF(lSx3,CZD->CZD_CDMD,cTemplate) }) > 0
			Return .t.
		EndIf
	EndIf
	
Return .f.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104CTP
Função que irá retornar um array com todos os templates pertencentes ao Produto desenvolvido e/ou Recurso.

@param lTipo Codigo da familia do produto
@param lGrupo Codigo do grupo de estoque
@param lRecurso Código do recurso
@param lFTecnica Código da família técnica

@author Marcos Wagner Junior
@since 31/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104CTP(lTipo,lGrupo,lRecurso,lFTecnica)
	Local aOldArea := GetArea()
	Local cTipo:="0"
	
	Default lFTecnica := ' '
	aTemplates := {}
	
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DISTINCT(CZF.CZF_CDMD) "
	cQuery += "FROM " + RetSQLName( 'CZF' ) + " CZF "
	cQuery += "WHERE CZF.D_E_L_E_T_ = ' ' "
	
	If (!empty(lTipo) .OR. !empty(lGrupo)) .AND. ;
		(empty(lRecurso) .AND. empty(lFTecnica))
		cTipo := "1"
	Else
		If !empty(lRecurso) .AND. ;
			(empty(lTipo) .AND. empty(lGrupo) .AND. empty(lFTecnica))
			cTipo := "2"
		Else
			If !empty(lRecurso) .AND. (!empty(lTipo) .OR. !empty(lGrupo)) .AND. ;
				empty(lFTecnica)
				cTipo := "3"
			Else
				If !empty(lFTecnica) .AND. ;
					(empty(lRecurso) .AND. empty(lTipo) .AND. empty(lGrupo))
					cTipo := "4"
				Else
					If (!empty(lFTecnica) .AND. !empty(lRecurso)) .AND.;
						(empty(lTipo) .AND. empty(lGrupo))
						cTipo := "5"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	If cTipo == "0"
		RestArea(aOldArea)
		Return aTemplates
	EndIf
	
	Do Case
		Case cTipo == "1"
			cQuery += " AND ((CZF.CZF_TPMP   = '"+lTipo+"'"
			cQuery += " AND  CZF.CZF_CDGRIV = '"+lGrupo+"')"
			cQuery += "  OR (CZF.CZF_TPMP   = '"+lTipo+"'"
			cQuery += " AND  CZF.CZF_CDGRIV = ' ')"
			cQuery += "  OR (CZF.CZF_TPMP   = ' '"
			cQuery += " AND  CZF.CZF_CDGRIV = '"+lGrupo+"'))"
			cQuery += " AND  CZF.CZF_CDRC   = ' '"
			cQuery += " AND CZF.CZF_CDFATD  = ' '"
	
		Case cTipo == "2"
			cQuery += " AND CZF.CZF_CDRC   = '"+lRecurso+"'"
			cQuery += " AND CZF.CZF_CDGRIV = ' '"
			cQuery += " AND CZF.CZF_TPMP   = ' '"
			cQuery += " AND CZF.CZF_CDFATD = ' '"
	
		Case cTipo == "3"
			cQuery += " AND CZF.CZF_CDRC   = '"+lRecurso+"'"
			cQuery += " AND ((CZF.CZF_TPMP   = '"+lTipo+"'"
			cQuery += " AND CZF.CZF_CDGRIV = '"+lGrupo+"')"
			cQuery += "  OR (CZF.CZF_TPMP   = '"+lTipo+"'"
			cQuery += " AND CZF.CZF_CDGRIV = ' ')"
			cQuery += "  OR (CZF.CZF_TPMP   = ' '"
			cQuery += " AND CZF.CZF_CDGRIV = '"+lGrupo+"'))"
			cQuery += " AND CZF.CZF_CDFATD = ' '"
	
		Case cTipo == "4"
			cQuery += " AND CZF.CZF_CDFATD = '"+lFTecnica+"'"
			cQuery += " AND CZF.CZF_CDGRIV = ' '"
			cQuery += " AND CZF.CZF_TPMP   = ' '"
			cQuery += " AND CZF.CZF_CDRC   = ' '"
	
		Case cTipo == "5"
			cQuery += " AND CZF.CZF_CDFATD = '"+lFTecnica+"'"
			cQuery += " AND CZF.CZF_CDRC   = '"+lRecurso+"'"
	EndCase
	
	cQuery += "  AND CZF.CZF_FILIAL = '"+xFilial('CZF')+"'"
	cQuery += "  ORDER BY CZF.CZF_CDMD "
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )
	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While !(cAliasQry)->(Eof())
		Aadd(aTemplates,{(cAliasQry)->CZF_CDMD})
		(cAliasQry)->(dbSkip())
	End
	
	(cAliasQry)->(dbCloseArea())
	RestArea(aOldArea)
Return aTemplates
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VTB
Função que irá validar o campo CZG_VLTB.

@author Lucas Konrad França
@since 14/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VTB()

      Local lRet := .T.
      Local oMdl        := FWModelActive()
      Local oMdlF3      := oMdl:GetModel('CZGDETAIL')
      Local cTab     := ""
      Local cCampo   := ""
      Local cDescricao := ""
      Local cQuery     := ""
      Local cTabAux    := ""
      Local aArea := GetArea()
      Local cValor
      Local aAreaTab

      If Empty( M->CZG_VLTB )
            Return .T.
      EndIf

      //=======================
      // Procurar campo na CDB
      //=======================

      DbSelectArea("CZB")
      CZB->(dbSetOrder(1))
      CZB->(dbSeek(xFilial("CZB") + (AllTrim(oMdlF3:GetValue('CZG_CDAB')))))

      cTab        := AllTrim(CZB->CZB_VLPAAB)
      cCampo            := AllTrim(CZB->CZB_IDCDG)
      cDescricao  := AllTrim(CZB->CZB_IDDS)

      If At('_',cCampo) == 3
            cTabAux := SubStr(cTab,2,2)
      Else
            cTabAux := cTab
      EndIf

      aAreaTab := &(cTab)->(GetArea())

      dbSelectArea("SX3")
      SX3->(dbSetOrder(1))
      SX3->(dbSeek(SubStr(cCampo,1,10)))

      If tamSX3(cCampo)[3] != 'N'
            cValor := "'"+oMdlF3:GetValue('CZG_VLTB')+"'"
      Else
            cValor := oMdlF3:GetValue('CZG_VLTB')
      EndIf

      DbSelectArea(cTab)
      (cTab)->(dbSetOrder(1))
      (cTab)->(dbGoTop())
      If (cTab)->(Eof())
            Help( ,, 'Help',,STR0028, 1, 0 ) //Valor inválido para esta tabela.
            lRet := .F.
      EndIf

      &(cTab)->(RestArea(aAreaTab))
      RestArea(aArea)

      If lRet
            cAliasQry := GetNextAlias()
            cQuery := " SELECT "+cCampo
            cQuery += "   FROM "+RetSqlName(cTab)
            cQuery += "  WHERE "+cCampo+" = "+cValor
            cQuery += "    AND "+cTabAux+"_FILIAL = '"+xFilial(cTab)+"'"

            dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )
            dbSelectArea(cAliasQry)
            (cAliasQry)->(dbGoTop())
            If (cAliasQry)->(Eof())
                  Help( ,, 'Help',,STR0028, 1, 0 ) //Valor inválido para esta tabela.
                  lRet := .F.
            EndIf
            (cAliasQry)->(dbCloseArea())
            RestArea(aArea)
      EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104Codigo
Valida se o recurso esta usado na SG2
@param
@return

@author  Jefferson Arthur Guermandi
@since   18/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104Codigo()
Local aOldArea := GetArea()
Local lRet    		:= .T.

If (Vazio() .Or. (Empty(AllTrim(M->CZG_CDAC))) .Or. !ExistCpo("SB1",M->CZG_CDAC))
	lRet := .F.
	Return lRet
EndIf

If ((cParam104 == 3) .And. !(Empty(AllTrim(M->CZG_CDRC))))  //somente se for recurso x Produto
	lRet := PCPA104VRecurso()
EndIf

//Se estiver realizando a cópia
If IsInCallStack("PCPA104COP")
   If cParam104 == 1
      If cProd == M->CZG_CDAC
         Help( ,, 'Help',, STR0031, 1, 0 ) //"Não é possível realizar a cópia para o mesmo produto."
         lRet := .F.
      EndIf
   Else
      If cParam104 == 3 .And. !Empty(M->CZG_CDRC)
         If cProd == M->CZG_CDAC .And. cRecur == M->CZG_CDRC
            Help( ,, 'Help',, STR0032, 1, 0 ) //"Não é possível realizar a cópia para o mesmo produto/recurso."
            lRet := .F.
         EndIf
      EndIf   
   EndIf
EndIf

RestArea(aOldArea)

Return lRet
//-------------------------------------------------------------------

/*/{Protheus.doc} PCPA104VVChar
Valida se o valor caracter
@param
@return

@author  Jefferson Arthur Guermandi
@since   21/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VVChar()
Local aOldArea := GetArea()
Local lRet    		:= .T.
Local oMdl   	:= FWModelActive()
Local oModelCZG:= oMdl:GetModel('CZGDETAIL')


DbSelectArea( "CZB" )
CZB->(dbSetOrder(1))
CZB->(dbSeek(xFilial("CZB") + AllTrim(oModelCZG:GetValue('CZG_CDAB'))))

If (Len(AllTrim(oModelCZG:GetValue('CZG_VLCHAR'))) > CZB->CZB_TMAB)
	Help( ,, 'Help',, STR0029, 1, 0 ) //"Tamanho não compatível com tamanho informado para atributo."
	lRet := .F.
	Return lRet
Endif

RestArea(aOldArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VFTec
Valida se existe a F. Tecnica
@param
@return

@author  Jefferson Arthur Guermandi
@since   22/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VFTec()
Local lRet    		:= .T.

If (Empty(AllTrim(M->CZG_CDFATD)) .Or. !(ExistCpo("CZL",M->CZG_CDFATD)))
	lRet := .F.
	Return lRet
EndIf

If IsInCallStack("PCPA104COP") //Se for cópia
   If cParam104 == 4 //Somente família técnica
      If cFamTec == M->CZG_CDFATD
         Help( ,, 'Help',, STR0036, 1, 0 ) //"Não é possível realizar a cópia para a mesma Família técnica." 
         lRet := .F.
      EndIf
   Else
      //Família técnica X Recurso
      If cParam104 == 5 .And. !Empty(M->CZG_CDRC)  
         If cFamTec == M->CZG_CDFATD .And. cRecur == M->CZG_CDRC
            Help( ,, 'Help',, STR0035, 1, 0 ) //"Não é possível realizar a cópia para a mesma Família técnica/recurso." 
            lRet := .F.
         EndIf 
      EndIf
   EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104COP
Função para execução da Cópia da Ficha Técnica
@param
@return

@author  Lucas Konrad França
@since   30/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104COP(lCpyAll)
   Local oModel    := FwLoadModel("PCPA104")
   
   Default lCpyAll := .F.
   
   cTempl   := CZG->CZG_CDMD
   cProd    := CZG->CZG_CDAC
   cRecur   := CZG->CZG_CDRC
   cFamTec  := CZG->CZG_CDFATD
   cVers    := CZG->CZG_VRFH
   lCopyAll := lCpyAll
   
   //Carrega a variável cParam104
   cParam104 := tipoFT(cProd, cRecur, cFamTec)
   
   //Executa a cópia
   If !__lAutomacao
   nRet := FWExecView( STR0030 , "PCPA104", 9, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
   oModel:DeActivate()
   EndIf
   
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} tipoFT
Função que retorna o tipo da ficha técnica (Produto, Produto x Recurso, Recurso, Família técnica, Família técnica x Recurso)
@param  cProduto
         cRecurso
         cFamilia
@return cTipo (1 = Produto;
                 2 = Recurso;
                 3 = Produto x Recurso;
                 4 = Família técnica;
                 5 = Família técnica x Recurso)

@author  Lucas Konrad França
@since   30/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function tipoFT(cProduto, cRecurso, cFamilia)
   Local cTipo := Nil
   If !Empty(cProduto) .And. (Empty(cRecurso) .And. Empty(cFamilia)) //Produto
      cTipo := 1
   Else
      If !Empty(cRecurso) .And. (Empty(cProduto) .And. Empty(cFamilia)) //Recurso
         cTipo := 2
      Else
         If (!Empty(cProduto) .And. !Empty(cRecurso)) .And. Empty(cFamilia) //Produto x Recurso
            cTipo := 3
         Else
            If !Empty(cFamilia) .And. (Empty(cProduto) .And. Empty(cRecurso)) // Família técnica
               cTipo := 4
            Else
               If (!Empty(cFamilia) .And. !Empty(cRecurso)) .And. Empty(cProduto) //Família técnica x Recurso
                  cTipo := 5
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
Return cTipo

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA104VAL
Função para validação dos atributos inativos
@param  nCampo (1 = Valor flag;
                  2 = Valor char;
                  3 = Valor numerico;
                  4 = Valor data;
                  5 = Valor lista;
                  6 = Valor faixa;
                  7 = Valor formula;
                  8 = Valor memo;
                  9 = Valor tabela;
                  10 = Afastamento superior;
                  11 = Afastamento inferior;
                  12 = Imagem.)
@return lRet

@author  Lucas Konrad França
@since   30/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function PCPA104VAL(nCampo)
   Local oModel := FwModelActive()
   Local oView  := FWViewActive()

   If lValid
      DbSelectArea("CZB")
      DbSetOrder(1)
      If CZB->(dbSeek(xFilial("CZB") + oModel:GetModel("CZGDETAIL"):GetValue("CZG_CDAB")))
         If CZB->CZB_STAB == "2"
            If !MsgYesNo(STR0043) //"Atributo inativo, deseja informá-lo mesmo assim?"
               Do Case
                  Case nCampo == 1
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLFG",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 2 
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLCHAR",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 3
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLNR",aValores[oModel:GetModel("CZGDETAIL"):GetLine()][1])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 4
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLDT",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 5
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLLST",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 6
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLFX",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 7
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLFO",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 8
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLMEMO",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 9
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_VLTB",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 10
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_AFINF",aValores[oModel:GetModel("CZGDETAIL"):GetLine()][2])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 11
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_AFSUP",aValores[oModel:GetModel("CZGDETAIL"):GetLine()][3])
                     lValid := .T.
                     lExecuta := .T.
                  Case nCampo == 12
                     lValid := .F.
                     lExecuta := .F.
                     oModel:GetModel("CZGDETAIL"):SetValue("CZG_BITMAP",aValores[oModel:GetModel("CZGDETAIL"):GetLine()])
                     lValid := .T.
                     lExecuta := .T.
               EndCase
            EndIf
         EndIf
      EndIf
   Else
      lValid := .T.
   EndIf
   If !__lAutomacao
   oView:Refresh()
   EndIf
Return .T.
//-------------------------------------------------------------------
//Cópia Geral
Function PCPA104GCOP()
	
	Local nInd				:= 1
	Local nIStru
	Local cQuery	
	Local cToCopy	
	Local cVlMemo			:= ""
	Local cProdTgt      := CZG->CZG_CDAC
	Local cNewVers      := ""
	Local aCopyStru     := {}
	Local cLastVers
	Local cCurrVers     := ""
	Local cSelectFields := ""	

	If IsInCallStack("PCPA104COP") .AND. lCopyAll
	
		MSGINFO(STR0045)
	
		cSelectFields := TABLEFIELDS('CZG', 1, ", ", {|cField| If( cField != "CZG_VLMEMO" .AND. cField != "CZG_CDAC" .AND. cField != "CZG_VRFH" .AND. cField != "CZG_CDMD", .T., .F.)} )
		
		cToCopy := getNextAlias()
		// Carrega os registros que serão copiados.
		cQuery := "SELECT CZG_CDAC, CZG_VRFH, CZG_CDMD, "+cSelectFields
		cQuery += " FROM "+RetSqlName( "CZG" )+" WHERE CZG_FILIAL = '"+xFilial("CZG")+"'"
		cQuery += "  AND CZG_CDAC = '"+cProd+"'"
		cQuery += "  AND ( CZG_VRFH != '"+cVers+"' AND CZG_CDMD = '"+CZG->CZG_CDMD+"' OR CZG_CDMD != '"+CZG->CZG_CDMD+"' ) "
		cQuery += "  AND D_E_L_E_T_ = '' "
		
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cToCopy, .T., .T. )
		
		aCopyStru := (cToCopy)->(dbStruct())
		
		cNewVers := nextVrsGCOP((cToCopy)->CZG_CDMD, cProdTgt)
		
		cCurrVers := (cToCopy)->CZG_VRFH
		cCurrTmpl := (cToCopy)->CZG_CDMD
		
		cAliasCurrVIn := INCONSSQL(cCurrVers, (cToCopy)->CZG_CDMD, cProd, cProdTgt, (cToCopy)->CZG_CDRC, (cToCopy)->CZG_CDFATD)
		If !(cAliasCurrVIn)->(EOF())			
			INSRTABLEATR(cAliasCurrVIn, cNewVers)
		EndIf
		
		dbSelectArea("CZG")
		DbSetOrder(1)
		
		While !(cToCopy)->(EOF())
			
			//Localiza o valor da VL_MEMO antes de dar lock na tabela.
			//Variaveis do tipo Memo são ignoradas pelo comando COPY() e TcGenQry()			
			CZG->(DbSeek((cToCopy)->CZG_FILIAL+(cToCopy)->CZG_CDAC+(cToCopy)->CZG_CDRC+(cToCopy)->CZG_CDFATD+(cToCopy)->CZG_CDMD+(cToCopy)->CZG_VRFH+(cToCopy)->CZG_CDAB))			
			cVlMemo := CZG->CZG_VLMEMO
			
			RecLock("CZG", .T.)
			
			If cCurrTmpl != (cToCopy)->CZG_CDMD
			
				cNewVers := nextVrsGCOP((cToCopy)->CZG_CDMD, cProdTgt)
				
				cCurrVers := (cToCopy)->CZG_VRFH
				cCurrTmpl := (cToCopy)->CZG_CDMD
				
			Elseif cCurrVers != (cToCopy)->CZG_VRFH
			 
				cNewVers  := FichaNextVer(cNewVers, LEN(cNewVers))
				cCurrVers := (cToCopy)->CZG_VRFH
				
			EndIf
			
			CZG->CZG_VRFH   := cNewVers
			CZG->CZG_CDAC   := cProdTgt
			CZG->CZG_VLMEMO := cVlMemo
			CZG->CZG_CDMD   := cCurrTmpl
			
			For nIStru := 4 to Len(aCopyStru)
				If VALTYPE(CZG->&(aCopyStru[nIStru][1])) != "D"
					CZG->&(aCopyStru[nIStru][1]) := (cToCopy)->&(aCopyStru[nIStru][1])
				Else
					CZG->&(aCopyStru[nIStru][1]) := CTOD((cToCopy)->&(aCopyStru[nIStru][1]))
				EndIF
			End
			
			MsUnLock()
			nInd++
			(cToCopy)->(dbSkip())
		End
		
	EndIf  
   
Return .T.
//-------------------------------------------------------------------
//Retorna os fields da tabela cTable de acordo com o parametro nType
// nType = 0 Retorna uma Array
// nType = 1 Retorna uma string concatenada pelo parametro cConcat
// bException = Validação sobre insersção de field no retorno
Function TABLEFIELDS(cTable, nType, cConcat, bException)

	Local xResult
	Local aStruct
	
	Default nType      := 0
	Default cConcat    := ""
	Default bException := {|cField| .T.}
	
	DbSelectArea(cTable)
	aStruct = dbStruct()
	
	Do Case
		Case nType == 0
			xResult := TBLFILDARR(aStruct, bException)
		Case nType == 1
			xResult := TBLFILDSTR(aStruct, cConcat, bException)
	EndCase

Return xResult
//-------------------------------------------------------------------
Static Function TBLFILDARR(aStruct, bException)
	
	Local nI
	Local nSize      := Len(aStruct)
	Local aResult    := {}
	Local cCurrField := ""
	
	For nI := 1 To nSize
		cCurrField := aStruct[nI][1]
		If Eval(bException, cCurrField)
			AADD(aResult, cCurrField)
		EndIf
	Next

Return  aResult
//-------------------------------------------------------------------
Static Function TBLFILDSTR(aStruct, cConcat, bException)

	Local nI
	Local nSize      := Len(aStruct)
	Local cResult    := ""
	Local cCurrField := ""

	For nI := 1 To nSize
		cCurrField := aStruct[nI][1]
		If Eval(bException, cCurrField)
			If nI == 1
				cResult += aStruct[nI][1]				
			Else
				cResult += cConcat+aStruct[nI][1]
			EndIf
		EndIf
	Next

Return cResult
//-------------------------------------------------------------------
Static Function FichaNextVer(cVers, nSize)
	
	Local cNextVer := toStr(++Val(cVers))
	
Return PADL( cNextVer , nSize , "0" )
//-------------------------------------------------------------------
Static Function toStr(xString)
Return AllTrim(Str(xString))
//-------------------------------------------------------------------
// Verifica se a ficha corrente é consistente criando o alias cCZGIncons com os fields faltantes.
// Retorno .F. =  Não é incosistente.
Static Function CURFICHACONSIS()
	
	cCZGIncons  := INCONSSQL(CZG->CZG_VRFH, CZG->CZG_CDMD, CZG->CZG_CDAC, , CZG->CZG_CDRC, CZG->CZG_CDFATD)

Return !(cCZGIncons)->(EOF())
//-------------------------------------------------------------------
/* Gerencia como a view será aberta.
	nAct = 1 Alteração
	nAct = 2 Cópia
	nAct = 3 Cópia Geral
*/
Function PCPA104RDRBTN(nAct)
	
	Local oModel
		
	lFichaIncos := CURFICHACONSIS()
	 
	Do Case
		Case nAct == 1 .AND. lFichaIncos == .F.
			
			oModel := FwLoadModel("PCPA104")
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			oModel:Activate(.F.)
			
   			nRet   := FWExecView( STR0042 , "PCPA104", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
   			oModel:DeActivate()
		Case nAct == 1 .AND. lFichaIncos == .T.
			PCPA104VER()
		Case nAct == 2
			PCPA104COP()
		Case nAct == 3
			PCPA104COP(.T.)
		Case nAct == 4
			PCPA104VER()
	EndCase//TODO
	
Return Nil
//-------------------------------------------------------------------
Static Function INSRGRIDATR(cAlias)

	Local oModel			:= FWModelActive()
	Local oModelCZG		:= oModel:GetModel('CZGDETAIL')
	Local oStructCZG		:= oModelCZG:GetStruct()
	
 	Local nI				:= LEN(oModelCZG:aDataModel) 	
	Local cValorPadrao	:= ""
	Local cAtributo      := ""
	Local aArea          := GetArea()
	Local lNewLine       := .T.
	
	oModelCZG:SetNoInsertLine(.F.)
	oModelCZG:SetNoDeletetLine(.F.)
	
	oModelCZG:GoLine(1)
	If nI == 1 .AND. AllTrim(oModelCZG:GetValue('CZG_CDAB')) == ""
		lNewLine := .F.
	Else
		nI++
	EndIf

	While ((cAlias)->(!Eof() ))
		
		If lNewLine
			oModelCZG:AddLine()
		EndIf
		lNewLine := .T.
		
		oModelCZG:GoLine( nI )

		oStructCZG:SetProperty('CZG_CDAB', MODEL_FIELD_WHEN, { || .T. } )
		oModelCZG:LoadValue('CZG_CDAB' ,(cAlias)->(CZE_CDAB))

		oStructCZG:SetProperty('CZG_CDAB', MODEL_FIELD_WHEN, { || PCPA104WGRID(0) } )

		oModelCZG:LoadValue('CZG_NMAB' ,(cAlias)->(CZB_NMAB))
		oModelCZG:LoadValue('CZG_DSAB' ,(cAlias)->(CZB_DSAB))

		cTpAtrib := (cAlias)->(CZB_TPAB)
		cValorPadrao := ""

		oModelCZG:LoadValue('CZG_TPAB' ,(cAlias)->(CZB_TPAB))

		oModelCZG:LoadValue('CZG_SQAB' ,(cAlias)->(CZE_SQAB))

		Do Case
			Case cTpAtrib == "F"
				If (AllTrim((cAlias)->(CZB_VLPAAB)) == '1')
					oModelCZG:LoadValue('CZG_VLFG', '1')
				Else
					oModelCZG:LoadValue('CZG_VLFG', '2')
				EndIf

			Case cTpAtrib == "C"
				oModelCZG:LoadValue('CZG_VLCHAR', (cAlias)->(CZB_VLPAAB))

			Case cTpAtrib == "N"
				oModelCZG:LoadValue('CZG_VLNR', val(strtran((cAlias)->(CZB_VLPAAB), ",", ".")) )

			Case cTpAtrib == "D"
			    cValorPadrao := StoD(Right( AllTrim((cAlias)->(CZB_VLPAAB)) , 4 ) + SubStr( AllTrim((cAlias)->(CZB_VLPAAB)) , 4, 2 ) + Left( AllTrim((cAlias)->(CZB_VLPAAB)) , 2 ))
	 			 oModelCZG:LoadValue('CZG_VLDT', cValorPadrao)

			Case cTpAtrib == "L"
 				oModelCZG:LoadValue('CZG_VLLST', SubStr((cAlias)->(CZB_VLPAAB),1,20))
				If ((cAlias)->(CZB_TPTB) == '2') //lista composta
		     		cValorPadrao := AllTrim((cAlias)->(CZB_VLPAAB))
		     		cAtributo    := AllTrim((cAlias)->(CZE_CDAB))
					aArea        := GetArea()
					DbSelectArea("CZC")
					CZC->(dbSetOrder(2))
					CZC->(dbSeek(xFilial("CZC") +  cAtributo +  cValorPadrao))
			    	oStructCZG:SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { || .T. } )
					oModelCZG:LoadValue('CZG_VLNR', val(strtran(CZC->CZC_VLTB, ",", ".")) )
					oStructCZG:SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { || PCPA104WGRID(3) } )
					RestArea(aArea)
				EndIf

	 		Case cTpAtrib == "A"
		   		oModelCZG:LoadValue('CZG_VLFX', val(strtran((cAlias)->(CZB_VLPAAB), ",", ".")) )

			Case cTpAtrib == "M"
				oModelCZG:LoadValue('CZG_VLMEMO', (cAlias)->(CZB_VLPAAB))

			Case cTpAtrib == "R"
				oStructCZG:SetProperty('CZG_VLFO', MODEL_FIELD_WHEN, { || .T. } )
				oModelCZG:LoadValue('CZG_VLFO', (cAlias)->(CZB_VLPAAB) )
				oStructCZG:SetProperty('CZG_VLFO', MODEL_FIELD_WHEN, { || PCPA104WGRID(8) } )
				cValorPadrao := validForm((cAlias)->(CZB_VLPAAB))
				cValorPadrao := StrTran(cValorPadrao,",", ".")
				oModelCZG:GoLine( nI )
				oStructCZG:SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { || .t. } )
		  		oModelCZG:LoadValue('CZG_VLNR', &(cValorPadrao))
				oStructCZG:SetProperty('CZG_VLNR', MODEL_FIELD_WHEN, { || PCPA104WGRID(3) } )
				cFormNova := ""

			Case cTpAtrib == "O"
				oModelCZG:LoadValue('CZG_VLNR', val(strtran((cAlias)->(CZB_VLPAAB), ",", ".")) )
		EndCase
		
		(cAlias)->(DbSkip())
		nI++

	End
	
	orderGrid(oModelCZG)

	oModelCZG:SetNoInsertLine(.T.)
	oModelCZG:SetNoDeletetLine(.T.)
	oModelCZG:GoLine(1)
	
	RestArea(aArea)

Return Nil
//-------------------------------------------------------------------
// Insere atributos faltantes direto na tabela.
Static Function INSRTABLEATR(cAlias, cVersion)
	
	Local cTpAtrib      := ""	
	Local cValorPadrao  := ""
	Local cCurrAtributo
	Local xCZG_VLNR     := Nil
	Local aArea
	
	DbSelectArea("CZG")
	
	While ((cAlias)->(!Eof() ))
	
		If ((cAlias)->(CZB_TPTB) == '2') //lista composta
		
     		cValorPadrao  := AllTrim((cAlias)->(CZB_VLPAAB))
     		cCurrAtributo := AllTrim((cAlias)->(CZE_CDAB))
			
			dbSetOrder(2)
			dbSeek(xFilial("CZC") +  cAtributo +  cValorPadrao)
	    	
			xCZG_VLNR := val(strtran(CZC->CZC_VLTB, ",", "."))
			
		EndIf
		
		RecLock("CZG", .T.)
		
		CZG_CDAC   := (cAlias)->(CZG_CDAC)
		CZG_CDMD   := (cAlias)->(CZE_CDMD)
		CZG_CDAB   := (cAlias)->(CZE_CDAB)
		CZG_NMAB   := (cAlias)->(CZB_NMAB)
		CZG_DSAB   := (cAlias)->(CZB_DSAB)
		CZG_TPAB   := (cAlias)->(CZB_TPAB)
		CZG_FILIAL := xFilial('CZG')
		CZG_VRFH   := cVersion
		
		cTpAtrib := (cAlias)->(CZB_TPAB)
		cValorPadrao := ""

		Do Case
			Case cTpAtrib == "F"
			
				If (AllTrim((cAlias)->(CZB_VLPAAB)) == '1')
					CZG_VLFG := '1'
				Else
					CZG_VLFG := '2'
				EndIf

			Case cTpAtrib == "C"
			
				CZG_VLCHAR := (cAlias)->(CZB_VLPAAB)
				
			Case cTpAtrib == "N"
			
				CZG_VLNR := val(strtran((cAlias)->(CZB_VLPAAB), ",", "."))
				
			Case cTpAtrib == "D"
			
			    cValorPadrao := StoD(Right( AllTrim((cAlias)->(CZB_VLPAAB)) , 4 ) + SubStr( AllTrim((cAlias)->(CZB_VLPAAB)) , 4, 2 ) + Left( AllTrim((cAlias)->(CZB_VLPAAB)) , 2 ))
	 			 CZG_VLDT := cValorPadrao
	 			 
			Case cTpAtrib == "L"
			
 				CZG_VLLST := SubStr((cAlias)->(CZB_VLPAAB),1,20)
 				
				If xCZG_VLNR != Nil		     		
					CZG_VLNR := xCZG_VLNR
				EndIf

	 		Case cTpAtrib == "A"
		   		CZG_VLFX := val(strtran((cAlias)->(CZB_VLPAAB), ",", "."))

			Case cTpAtrib == "M"
				CZG_VLMEMO := (cAlias)->(CZB_VLPAAB)

			Case cTpAtrib == "R"
			
				cValorPadrao := validForm((cAlias)->(CZB_VLPAAB))
				cValorPadrao := StrTran(cValorPadrao,",", ".")
				
				CZG_VLFO := (cAlias)->(CZB_VLPAAB)				
		  		CZG_VLNR := &(cValorPadrao)

			Case cTpAtrib == "O"
				CZG_VLNR := val(strtran((cAlias)->(CZB_VLPAAB), ",", "."))
		EndCase
		
		MsUnLock()
		(cAlias)->(DbSkip())

	End
	
Return Nil
//-------------------------------------------------------------------
// Limpa o grid sem reiniciar o Model.
Static Function CLEARGRID(cSubModel, oModel)

	Local nI         := 0
	Local nTamHeader := 0
	
	Default oModel   := FWModelActive()
	
	oSubModel	:= oModel:GetModel(cSubModel)
	nTamHeader	:= LEN(oSubModel:aHeader)
	
	oSubModel:SetNoInsertLine(.F.)
	oSubModel:SetNoDeletetLine(.F.)
	
	oSubModel:GoLine(1)
	
	ASIZE(oSubModel:aDataModel, 1)
	ASIZE(oSubModel:aCols, 1)	
	
	For nI := 1 To nTamHeader
		oModel:ClearField( cSubModel , oSubModel:aHeader[nI][2])
	Next nI
	
	//AddLine força um refresh no grid, os aSizes removem a nova linha em branco.
	oSubModel:AddLine()
	ASIZE(oSubModel:aDataModel, 1)
	ASIZE(oSubModel:aCols, 1)
	
Return Nil
//-------------------------------------------------------------------
// Função que contem o SQL para buscar os atributos faltantes da versão
Static Function INCONSSQL(cTgtVers, cTgtTempl, cTgtProd, cTgtNewProd, cTgtRec, cTgtFatd)		

	Local cSqlAlias := GetNextAlias()
	Local cQuery    := ""
	
	Default cTgtNewProd := cTgtProd	
	
	cQuery := 	" SELECT CZE_CDAB, CZB_DSAB, CZB_TPAB, CZB_VLPAAB, CZB_NMAB, " 
	cQuery += 	"     CZB_TPTB, CZB_STAB, CZE_CDMD, '"+cTgtNewProd+"' AS CZG_CDAC, CZE_SQAB "
	cQuery += 	" FROM " + RetSqlName( "CZE" ) + " AS CZE "
	cQuery +=	"  LEFT JOIN " + RetSqlName( "CZG" ) + "  AS CZG ON CZG_CDAB = CZE_CDAB AND CZG_VRFH = '" + cTgtVers + "'"
	cQuery +=	"    AND CZG.CZG_CDAC = '" + cTgtProd + "' AND CZG.CZG_CDMD = '" + cTgtTempl  + "'" 
	cQuery +=   "    AND CZG.CZG_CDRC = '" + cTgtRec + "' AND CZG.CZG_CDFATD = '" + cTgtFatd + "' AND CZG.D_E_L_E_T_ = ''"											
	cQuery +=	"  INNER JOIN " + RetSqlName( "CZB" ) + " AS ATR ON CZB_CDAB = CZE_CDAB "	
	cQuery +=	"  WHERE CZE.CZE_CDMD = '" + cTgtTempl + "'"				
	cQuery +=	"    AND CZG_CDAC IS NULL "
	cQuery +=	"    AND CZE_FILIAL     = '" + xFilial( "CZE" ) + "'"
	cQuery +=	"    AND CZE.D_E_L_E_T_ = '' "
	cQuery +=   " Order by CZE.CZE_SQAB, CZE.CZE_CDAB "

	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cSqlAlias, .T., .T. )
	
Return cSqlAlias
//-------------------------------------------------------------------
//Regra para realizar o filtro da ultima versão.
Static Function FLTRVRSRULE(cProdToCop)

	Local cQuery := ""
	
	Default cProdToCop := ""	
	
	If (cParam104 == 1)//Somente Produto
		cQuery += " AND CZG.CZG_CDAC = '" + If(cProdToCop == "", M->CZG_CDAC, cProdToCop) + "'"
		cQuery += " AND CZG.CZG_CDRC = ''"
		cQuery += " AND CZG.CZG_CDFATD = ''"
	ElseIf (cParam104 == 2)//Somente Recurso
		cQuery += " AND CZG.CZG_CDRC = '" + M->CZG_CDRC + "'"
		cQuery += " AND CZG.CZG_CDAC = ''"
		cQuery += " AND CZG.CZG_CDFATD = ''"
	ElseIf (cParam104 == 4)//Somente Familia Tecnica
		cQuery += " AND CZG.CZG_CDFATD = '" + M->CZG_CDFATD + "'"
		cQuery += " AND CZG.CZG_CDAC = ''"
		cQuery += " AND CZG.CZG_CDRC = ''"
	ElseIf (cParam104 == 3)//Produto x Recurso
		cQuery += " AND CZG.CZG_CDAC = '" + M->CZG_CDAC + "'"
		cQuery += " AND CZG.CZG_CDRC = '" + M->CZG_CDRC + "'"
	ElseIf (cParam104 == 5)//Familia Tecnica x Recurso
		cQuery += " AND CZG.CZG_CDFATD = '" + M->CZG_CDFATD + "'"
		cQuery += " AND CZG.CZG_CDRC   = '" + M->CZG_CDRC + "'"
	EndIf		

Return cQuery
//-------------------------------------------------------------------
Static Function nextVrsGCOP(cTemplate, cProd)

	Default cProd := ""

	cLastVers := getNextAlias()
		
	cQuery := "SELECT DISTINCT TOP 1 CZG_VRFH AS LAST_VERSION, DATALENGTH(CZG_VRFH) AS FIELD_SIZE"
	cQuery += " FROM "+RetSqlName( "CZG" )+" CZG WHERE CZG_FILIAL = '"+xFilial("CZG")+"'"
	cQuery += " AND CZG.CZG_CDMD = '"+ cTemplate +"' AND D_E_L_E_T_ = '' "
	
	cQuery += FLTRVRSRULE(cProd)
	
	cQuery += "ORDER BY CZG_VRFH DESC "
	
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cLastVers, .T., .T. )
	
	If !(cLastVers)->(EOF())
		cNewVers := FichaNextVer((cLastVers)->(LAST_VERSION), (cLastVers)->(FIELD_SIZE))
	Else
		cNewVers := FichaNextVer('0', 5)
	EndIf
		
Return cNewVers

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} orderGrid
Ordena a grid dos atributos, conforme o campo CZG_SQAB+CZG_CDAB

@author  Lucas Konrad França
@since   18/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function orderGrid(oModelCZG)
	Local nI     := 0
	Local nJ     := 0
	Local cAtrib := ""
	Local cSeq   := ""
	Local nTamSX3 := TamSX3("CZG_SQAB")[1]

	For nI := 1 To oModelCZG:GetQtdLine()-1
		oModelCZG:GoLine(nI)
		cAtrib := cValToChar(oModelCZG:GetValue("CZG_CDAB"))
		cSeq   := StrZero(oModelCZG:GetValue("CZG_SQAB"),nTamSX3)
		
		For nJ := nI+1 To oModelCZG:GetQtdLine()
			oModelCZG:GoLine(nJ)
			
			If cSeq+cAtrib > StrZero(oModelCZG:GetValue("CZG_SQAB"),nTamSX3)+cValToChar(oModelCZG:GetValue("CZG_CDAB"))
				oModelCZG:LineShift(nI,nJ)
			EndIf
		Next nJ
	Next nI

Return

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA104CST
Tela de pesquisa de fichas técnicas.

@author  Lucas Konrad França
@since   25/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA104CST()
	Local aFichas := {}

	If Pergunte("PCPA104A",.T.)
		consFicha(@aFichas)
		
		IF Len(aFichas) > 0 
			exibeCons(aFichas)
		Else
			ShowHelpDlg( 'PCPA104', { 'Não foram encontrados registros com o filtro informado' }, , { 'Altere as faixas de pesquisa' } )
		Endif
	EndIf

Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} consFicha
Faz a consulta das fichas técnicas que respeitem os parâmetros informados no pergunte PCPA104A.

@param aFichas - array das fichas técnicas encontradas. Parâmetro por referência.
         [1] - Produto
         [2] - Recurso
         [3] - Grupo de estoque
         [4] - Tipo de material
         [5] - Família técnica
         [6] - Versão ficha
         [7] - Data ficha
         [8] - Template

@author  Lucas Konrad França
@since   25/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function consFicha(aFichas)
	Local cQuery     := ""
	Local cAlias     := GetNextAlias()
	Local cProdDe    := ""
	Local cProdAte   := ""
	Local cRecDe     := ""
	Local cRecAte    := ""
	Local cGrpDe     := ""
	Local cGrpAte    := ""
	Local cTipoDe    := ""
	Local cTipoAte   := ""
	Local cFtDe      := ""
	Local cFtAte     := ""
	Local cVersaoDe  := ""
	Local cVersaoAte := ""
	Local dDataDe    := Nil
	Local dDateAte   := Nil
	Local cTempDe    := ""
	Local cTempAte   := ""

	cProdDe    := mv_par01
	cProdAte   := mv_par02
	cRecDe     := mv_par03
	cRecAte    := mv_par04
	cGrpDe     := mv_par05
	cGrpAte    := mv_par06
	cTipoDe    := mv_par07
	cTipoAte   := mv_par08
	cFtDe      := mv_par09
	cFtAte     := mv_par10
	cVersaoDe  := mv_par11
	cVersaoAte := mv_par12
	dDataDe    := mv_par13
	dDateAte   := mv_par14
	cTempDe    := mv_par15
	cTempAte   := mv_par16

	cQuery := " SELECT DISTINCT CZG.CZG_CDAC, "
	cQuery +=                 " CZG.CZG_CDRC, "
	cQuery +=                 " SB1.B1_GRUPO, "
	cQuery +=                 " SB1.B1_TIPO, "
	cQuery +=                 " CZG.CZG_CDFATD, "
	cQuery +=                 " CZG.CZG_VRFH, "
	cQuery +=                 " CZG.CZG_DTFH, "
	cQuery +=                 " CZG.CZG_CDMD "
	cQuery +=   " FROM " + RetSqlName("CZG") + " CZG "
	//cQuery +=   " LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=   " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=                " ON CZG.CZG_CDAC   = SB1.B1_COD "
	cQuery +=               " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=               " AND SB1.B1_FILIAL  = '"+ xFilial("SB1")+"' "
	cQuery +=               " AND CZG.CZG_CDAC <> ' ' "
	cQuery +=               " AND SB1.B1_GRUPO BETWEEN '" + cGrpDe  + "' AND '" + cGrpAte  + "' "
	cQuery +=               " AND SB1.B1_TIPO  BETWEEN '" + cTipoDe + "' AND '" + cTipoAte + "' "
	cQuery +=  " WHERE CZG.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND CZG.CZG_FILIAL = '" + xFilial("CZG") + "' "
	cQuery +=    " AND CZG.CZG_CDAC   BETWEEN '" + cProdDe       + "' AND '" + cProdAte       + "' "
	cQuery +=    " AND CZG.CZG_CDRC   BETWEEN '" + cRecDe        + "' AND '" + cRecAte        + "' "
	cQuery +=    " AND CZG.CZG_CDFATD BETWEEN '" + cFtDe         + "' AND '" + cFtAte         + "' "
	cQuery +=    " AND CZG.CZG_VRFH   BETWEEN '" + cVersaoDe     + "' AND '" + cVersaoAte     + "' "
	cQuery +=    " AND CZG.CZG_DTFH   BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDateAte) + "' "
	cQuery +=    " AND CZG.CZG_CDMD   BETWEEN '" + cTempDe       + "' AND '" + cTempAte       + "' "
	cQuery +=  " ORDER BY 1, 2, 3, 4, 5, 6, 7, 8"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	While (cAlias)->(!Eof())
		aAdd(aFichas, {(cAlias)->(CZG_CDAC),;
                     (cAlias)->(CZG_CDRC),;
                     (cAlias)->(B1_GRUPO),;
                     (cAlias)->(B1_TIPO),;
                     (cAlias)->(CZG_CDFATD),;
                     (cAlias)->(CZG_VRFH),;
                     StoD((cAlias)->(CZG_DTFH)),;
                     (cAlias)->(CZG_CDMD)})
		(cAlias)->(dbSkip())
	End
	
	(cAlias)->(dbCloseArea())
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} exibeCons
Exibe a tela de consulta das fichas técnicas

@param aFichas - array com as fichas técnicas a serem exibidas.
         [1] - Produto
         [2] - Recurso
         [3] - Grupo de estoque
         [4] - Tipo de material
         [5] - Família técnica
         [6] - Versão ficha
         [7] - Data ficha
         [8] - Template

@author  Lucas Konrad França
@since   25/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function exibeCons(aFichas)
	Local oDlg, oLbx
	
	DEFINE MSDIALOG oDlg TITLE STR0009 FROM 0,0 TO 397,850 PIXEL //"Ficha Técnica"

	@ 05,05 LISTBOX oLbx FIELDS HEADER STR0054, STR0055,;//"Produto", "Recurso" ,;
                                      STR0056, STR0057,;//"Grupo de estoque", "Tipo de material",;
                                      STR0058, STR0059,;//"Família técnica", "Versão ficha",;
                                      STR0060, STR0061 SIZE 420,173 OF oDlg PIXEL //"Data ficha", "Template"

	oLbx:SetArray(aFichas)
	oLbx:bLine     := {|| {aFichas[oLbx:nAt,1],;
                          aFichas[oLbx:nAt,2],;
                          aFichas[oLbx:nAt,3],;
                          aFichas[oLbx:nAt,4],;
                          aFichas[oLbx:nAt,5],;
                          aFichas[oLbx:nAt,6],;
                          aFichas[oLbx:nAt,7],;
                          aFichas[oLbx:nAt,8]}}
	oLbx:bLDblClick := {|| { consOk(oDlg,aFichas[oLbx:nAt]) }}

	TButton():New(183,05,STR0062/*'Pesquisar'*/,oDlg,{|| newPesqui(@aFichas,oLbx)},40,11,,,,.T.)

	DEFINE SBUTTON FROM 183,370 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 183,399 TYPE 1 ACTION (consOk(oDlg,aFichas[oLbx:nAt])) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTER
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} newPesqui
Realiza novamente a consulta das fichas técnicas.

@param aFichas - array com as fichas técnicas a serem exibidas.
         [1] - Produto
         [2] - Recurso
         [3] - Grupo de estoque
         [4] - Tipo de material
         [5] - Família técnica
         [6] - Versão ficha
         [7] - Data ficha
         [8] - Template
@param oLbx - Referência do componente de ListBox.

@author  Lucas Konrad França
@since   25/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function newPesqui(aFichas,oLbx)

	If Pergunte("PCPA104A",.T.)
		aFichas := {}
		consFicha(@aFichas)
		oLbx:SetArray(aFichas)
		oLbx:bLine     := {|| {aFichas[oLbx:nAt,1],;
                             aFichas[oLbx:nAt,2],;
                             aFichas[oLbx:nAt,3],;
                             aFichas[oLbx:nAt,4],;
                             aFichas[oLbx:nAt,5],;
                             aFichas[oLbx:nAt,6],;
                             aFichas[oLbx:nAt,7],;
                             aFichas[oLbx:nAt,8]}}
	EndIf
	
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} consOk
Ação de confirmar da tela de pesquisa.

@param oDlg     - Referência do componente da janela.
@param aFichas - array com as fichas técnicas a serem exibidas.
         [1] - Produto
         [2] - Recurso
         [3] - Grupo de estoque
         [4] - Tipo de material
         [5] - Família técnica
         [6] - Versão ficha
         [7] - Data ficha
         [8] - Template

@author  Lucas Konrad França
@since   25/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function consOk(oDlg,aFichas)
	Local cTipo    := "1"

	If (!Empty(aFichas[4]) .OR. !Empty(aFichas[3])) .AND. ;
	   (Empty(aFichas[2]) .AND. Empty(aFichas[5]))
		cTipo := "1" //Produto
	Else
		If !Empty(aFichas[2]) .AND. ;
		   (Empty(aFichas[4]) .AND. Empty(aFichas[3]) .AND. Empty(aFichas[5]))
			cTipo := "2" //Recurso
		Else
			If !Empty(aFichas[2]) .AND. (!Empty(aFichas[4]) .OR. !Empty(aFichas[3])) .AND. ;
			   Empty(aFichas[5])
				cTipo := "3" //Produto x Recurso
			Else
				If !Empty(aFichas[5]) .AND. ;
				   (Empty(aFichas[2]) .AND. Empty(aFichas[4]) .AND. Empty(aFichas[3]))
					cTipo := "4" //Família Técnica
				Else
					If (!Empty(aFichas[5]) .AND. !Empty(aFichas[2])) .AND.;
					   (Empty(aFichas[3]) .AND. Empty(aFichas[4]))
						cTipo := "5" //Família técnica x Recurso
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cTipo $ "123"
		CZG->(dbSetOrder(1))
		CZG->(dbSeek(xFilial("CZG")+aFichas[1]+aFichas[2]+aFichas[8]+aFichas[6]))
	Else
		CZG->(dbSetOrder(4))
		CZG->(dbSeek(xFilial("CZG")+aFichas[5]+aFichas[2]))
		
		While CZG->(!Eof()) .And. CZG->(CZG_FILIAL+CZG_CDFATD+CZG_CDRC) == xFilial("CZG")+aFichas[5]+aFichas[2]
			If CZG->(CZG_VRFH) == aFichas[6] .And. CZG->(CZG_CDMD) == aFichas[8] .And. CZG->(CZG_DTFH) == aFichas[7]
				Exit
			EndIf
			
			CZG->(dbSkip())
		End
	EndIf
	oDlg:End()
	
Return Nil
