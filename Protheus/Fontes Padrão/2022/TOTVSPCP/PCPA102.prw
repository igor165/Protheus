#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCPA102.CH' 
 
//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA102
Tela de cadastro de template

@author Lucas Konrad França
@since 10/09/2013
@version P12
/*/
//-----------------------------------------------------------------
Function PCPA102()
	Local oBrowse
	Private aDadosCze := {}
	Private lAltSeq   := .F.

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CZD')
	oBrowse:SetMenuDef('PCPA102')
	oBrowse:SetDescription( STR0001 ) //Cadastro de Template
	oBrowse:Activate()
Return NIL

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Camada Model do MVC.

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruCZD := FWFormStruct( 1, 'CZD' )
	Local oStruCZE := FWFormStruct( 1, 'CZE' )
	Local oModel
	Local nIndex   := 3

	oModel := MPFormModel():New( 'PCPA102',, {|oModel|PCPA102POS(oModel)}  /*bPost*/, {|oModel|PCPA102CMM(oModel)} /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'CZDMASTER', /*cOwner*/, oStruCZD )
	oModel:AddGrid( 'CZEDETAIL', 'CZDMASTER', oStruCZE,{ |oModelGrid, nLine, cAction, cField| PCPA102VGR(oModelGrid, nLine, cAction, cField) } )
	oModel:SetRelation( 'CZEDETAIL', { { 'CZE_FILIAL', 'xFilial( "CZE" )' }, { 'CZE_CDMD','CZD_CDMD' } }, CZE->( IndexKey( nIndex ) ) )
	oModel:SetDescription( STR0001 ) //Cadastro de Template
	oModel:GetModel( 'CZDMASTER' ):SetDescription( STR0002 ) //Dados do Template
	oModel:GetModel( 'CZEDETAIL' ):SetDescription( STR0003 ) //Dados do Atributo
	oModel:GetModel( 'CZEDETAIL' ):SetUniqueLine( { 'CZE_CDAB' } )
	oModel:GetModel( 'CZEDETAIL' ):SetUseOldGrid(.T.)

	oModel:SetActivate({|oModel| cargaCZE(oModel)})
	oModel:SetVldActivate({|oModel| PCPA102VAC(oModel)})

Return oModel

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada View do MVC.

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel( 'PCPA102' )
	Local oStruCZD := FWFormStruct( 2, 'CZD' )
	Local oStruCZE := FWFormStruct( 2, 'CZE' )
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_CZD', oStruCZD, 'CZDMASTER' )
	oView:AddGrid( 'VIEW_CZE', oStruCZE, 'CZEDETAIL' )
	oView:CreateHorizontalBox( 'SUPERIOR', 15 )
	oView:CreateHorizontalBox( 'INFERIOR', 85 )
	oView:SetOwnerView( 'VIEW_CZD', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_CZE', 'INFERIOR' )
	
	oStruCZE:RemoveField('CZE_CDMD')
	
	oView:AddUserButton( STR0026, 'PCPA102', { |oModel| regeraSeq(oModel) } ) //"Regerar sequência"

Return oView

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCPA102' OPERATION 2 ACCESS 0 //Visualizar
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCPA102' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCPA102' OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.PCPA102' OPERATION 5 ACCESS 0 //Excluir
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.PCPA102' OPERATION 8 ACCESS 0 //Imprimir
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.PCPA102' OPERATION 9 ACCESS 0 //Copiar
Return aRotina

Function PCPA102VAC(oModel)

	Local lRet   := .T.
	Local lFicha 
		
	If oModel:GetOperation() == 3

		oModel:GetModel('CZDMASTER'):GetStruct():SetProperty(   'CZD_NMMD', MODEL_FIELD_WHEN, {|| .T.  }  )
		//oModel:GetModel('CZEDETAIL'):GetStruct():SetProperty(   'CZE_LGOB', MODEL_FIELD_WHEN, {|| .T.  }  )
			
	ElseIf oModel:GetOperation() == 4
	   
		dbSelectArea("CZG")
		CZG->(dbSetOrder(2))
		lFicha := CZG->(dbSeek(xFilial("CZG")+CZD->CZD_CDMD))
		
		If lFicha .AND. SUPERGETMV("MV_PCPMOFT" , .F. , "N") == "N" 
			Help( ,, 'Help',, STR0022, 1, 0 ) //"Template já utilizado na ficha técnica, não pode ser alterado."
			lRet := .F.
		ElseIf lFicha .AND. SUPERGETMV("MV_PCPMOFT" , .F. , "N") == "S"			
        oModel:GetModel('CZDMASTER'):GetStruct():SetProperty(   'CZD_NMMD', MODEL_FIELD_WHEN, {|| .F.  }  )
		Endif
	EndIf
	
	lAltSeq := .F.

Return lRet

Static Function cargaCZE(oModel)
   Local nI
   
   aDadosCze := { }
   
   If oModel:GetOperation() == 4
      For nI := 1 To oModel:GetModel('CZEDETAIL'):getQtdLine()
         oModel:GetModel('CZEDETAIL'):GoLine(nI)
         aAdd(aDadosCze,{oModel:GetModel('CZEDETAIL'):GetValue('CZE_LGOB'),;
         	             oModel:GetModel('CZEDETAIL'):GetValue('CZE_CDAB'),;
         	             oModel:GetModel('CZEDETAIL'):GetValue('CZE_NMAB')})
      Next
      oModel:GetModel('CZEDETAIL'):GoLine(1)
   EndIf
Return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102VAL
Função de validação do campo Atributo (CZE_CDAB)

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102VAL()
	Local oModel:=FWModelActive()
	Local oModelCZE:=oModel:GetModel('CZEDETAIL')
	Local oModelCZD:=oModel:GetModel('CZDMASTER')
	if empty(FWFldGet('CZE_CDAB'))
		return .T.
	endif
	dbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	If !(CZB->(dbSeek(xFilial("CZB")+FWFldGet('CZE_CDAB'))))
		Help( ,, 'Help',, STR0010 , 1, 0 ) // Atributo não cadastrado.
		Return .F.
	else
		If FWFldGet('CZD_TPMD') == '1' .And. (CZB->CZB_RLAB != '1' .And. CZB->CZB_RLAB != '4')
		   Help( ,, 'Help',, STR0011, 1, 0 ) //Template de produto, permitido informar somente atributos com relacionamento 'Todos' ou 'Produto'.
		   Return .F.
		EndIf
		If FWFldGet('CZD_TPMD') == '2' .And. (CZB->CZB_RLAB != '2' .And. CZB->CZB_RLAB != '4')
		   Help( ,, 'Help',, STR0012, 1, 0 ) //Template de recurso, permitido informar somente atributos com relacionamento 'Todos' ou 'Recurso'.
		   Return .F.
		EndIf
		If FWFldGet('CZD_TPMD') == '3' .And. CZB->CZB_RLAB == '3'
			Help( ,, 'Help',, STR0019, 1, 0 ) //Template de Produto x Recurso, não permitido informar atributos do tipo 'Família Técnica'.
			Return .F.
		EndIf
		If FWFldGet('CZD_TPMD') == '4' .And. (CZB->CZB_RLAB != '3' .And. CZB->CZB_RLAB != '4')
			Help( ,, 'Help',, STR0020, 1, 0 ) //Template de Família técnica, permitido informar apenas atributos com relacionamento 'Todos' ou 'Família Técnica'.
			Return .F.
		EndIf
		If FWFldGet('CZD_TPMD') == '5' .And. CZB->CZB_RLAB == '1'
			Help( ,, 'Help',, STR0021, 1, 0 ) //Template de Família técnica x Recurso, não permitido informar atributos do tipo 'Produto'.
			Return .F.
		EndIf
		If CZB->CZB_STAB == 'I'
		   Help( ,, 'Help',, STR0013, 1, 0 ) //Não permitido informar atributos inativos.
		   Return .F.
		EndIf
		
		oModelCZE:setValue('CZE_CDMD',oModelCZD:getvalue('CZD_CDMD'))
		
		If !INCLUI .AND. CZG->(dbSeek(xFilial("CZG")+CZD->CZD_CDMD)) .AND. SUPERGETMV("MV_PCPMOFT" , .F. , "N") == "S"
			oModelCZE:loadValue('CZE_LGOB', '2' ) // Não obrigátorio caso a ficha esteja em uso.
		EndIf
	Endif
return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102POS
Função de validação da confirmação

@param oModel   Modelo

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102POS(oModel)
	Local var          := 0
	Local oModelCZE    := oModel:GetModel('CZEDETAIL')
	Local oModelCZD    := oModel:GetModel('CZDMASTER')
	Local nOperacao    := oModel:GetOperation()
	Local lFicha
	Local lAchou 
	Local cMsg := ""
	
	dbSelectArea("CZG")
	CZG->(dbSetOrder(2))
	lFicha := CZG->(dbSeek(xFilial("CZG")+CZD->CZD_CDMD))
	
	if nOperacao == 5
		dbSelectArea("CZG")
		CZG->(dbSetOrder(2))
		for var:= 1 to oModelCZE:getQtdLine()
			oModelCZE:goline(var)
			if CZG->(dbSeek(xFilial("CZG")+oModelCZD:getValue("CZD_CDMD")+oModelCZE:getValue("CZE_CDAB")))
				Help( ,, 'Help',, STR0014 + oModelCZE:getValue("CZE_CDAB") + STR0015, 1, 0 ) //Atributo XXXXX já está sendo utilizado na ficha técnica, exclusão não permitida.
				 return .F.
			endif
		next
	else
		dbSelectArea("CZB")
		CZB->(dbSetOrder(1))
		for var:= 1 to oModelCZE:getQtdLine()
			oModelCZE:goline(var)
			If oModelCZE:IsDeleted()
				Loop
			EndIf
			If !(CZB->(dbSeek(xFilial("CZB")+oModelCZE:getvalue('CZE_CDAB'))))
				Help( ,, 'Help',, STR0010 , 1, 0 ) //Atributo não cadastrado
				Return .F.
			else
				If FWFldGet('CZD_TPMD') == '1' .And. (CZB->CZB_RLAB != '1' .And. CZB->CZB_RLAB != '4')
				   Help( ,, 'Help',, STR0011, 1, 0 ) //Template de produto, permitido informar somente atributos com relacionamento 'Todos' ou 'Produto'.
				   Return .F.
				EndIf
				If FWFldGet('CZD_TPMD') == '2' .And. (CZB->CZB_RLAB != '2' .And. CZB->CZB_RLAB != '4')
				   Help( ,, 'Help',, STR0012, 1, 0 ) //Template de recurso, permitido informar somente atributos com relacionamento 'Todos' ou 'Recurso'.
				   Return .F.
				EndIf
				If FWFldGet('CZD_TPMD') == '3' .And. CZB->CZB_RLAB == '3'
					Help( ,, 'Help',, STR0019, 1, 0 ) //Template de Produto x Recurso, não permitido informar atributos do tipo 'Família Técnica'.
					Return .F.
				EndIf
				If FWFldGet('CZD_TPMD') == '4' .And. (CZB->CZB_RLAB != '3' .And. CZB->CZB_RLAB != '4')
					Help( ,, 'Help',, STR0020, 1, 0 ) //Template de Família técnica, permitido informar apenas atributos com relacionamento 'Todos' ou 'Família Técnica'.
					Return .F.
				EndIf
				If FWFldGet('CZD_TPMD') == '5' .And. CZB->CZB_RLAB == '1'
					Help( ,, 'Help',, STR0021, 1, 0 ) //Template de Família técnica x Recurso, não permitido informar atributos do tipo 'Produto'.
					Return .F.
				EndIf
				if CZB->CZB_STAB == '2'
				   Help( ,, 'Help',, STR0013 , 1, 0 ) //Não permitido informar atributos inativos.
				   Return .F.
				endif
			Endif
			oModelCZE:setvalue('CZE_CDMD',oModelCZD:getvalue('CZD_CDMD'))
		next
		
		If nOperacao == 4 .And. lFicha .And. SUPERGETMV("MV_PCPMOFT" , .F. , "N") == "S" 
		   lAchou := .F.
		   For var := 1 To Len(aDadosCze)
		      oModelCZE:GoLine(var)
		      If aDadosCze[var][1] != oModelCZE:GetValue('CZE_LGOB') .And. ;
		         aDadosCze[var][2] == oModelCZE:GetValue('CZE_CDAB') .And. ;
		         aDadosCze[var][1] == "2" 
              cMsg += Chr(13) + Chr(10) + AllTrim(aDadosCze[var][2]) + " - " + AllTrim(aDadosCze[var][3])
		         lAchou := .T.		         
		      EndIf
		   Next
		   If lAchou
		      Help( ,, 'Help',, STR0024 + cMsg + ".", 1, 0 ) //"Template já utilizado em uma ficha técnica, o(s) seguinte(s) atributo(s) não pode(m) ser alterado(s) para obrigatório: ATRIBUTOS..."
		      Return .F.
		   EndIf
		   For var := 1 To oModelCZE:getQtdLine()
		      oModelCZE:GoLine(var)
		      If oModelCZE:IsInserted() .And. oModelCZE:GetValue("CZE_LGOB") == "1"
		         Help( ,, 'Help',, STR0014 + AllTrim(oModelCZE:GetValue("CZE_CDAB")) + " - " + AllTrim(oModelCZE:GetValue("CZE_NMAB")) + STR0025, 1, 0 ) //"Atributo XXXX não pode ser incluido como Obrigatório."
		         Return .F.
		      EndIf
		   Next
		EndIf
	endif

return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102FIL
Função para filtro do zoom (CZE_CDAB)

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102FIL(oModel)
	Default oModel:=FWModelActive()

	If oModel:GetOperation() == 5
		Return .T.
	EndIf

	If M->CZD_TPMD == '1' .And. (CZB->CZB_RLAB != '1' .And. CZB->CZB_RLAB != '4')
	   Return .F.
	EndIf
	If M->CZD_TPMD == '2' .And. (CZB->CZB_RLAB != '2' .And. CZB->CZB_RLAB != '4')
	   Return .F.
	EndIf
	If M->CZD_TPMD == '3' .And. CZB->CZB_RLAB == '3'
		Return .F.
	EndIf
	If M->CZD_TPMD == '4' .And. (CZB->CZB_RLAB != '3' .And. CZB->CZB_RLAB != '4')
		Return .F.
	EndIf
	If M->CZD_TPMD == '5' .And. CZB->CZB_RLAB == '1'
		Return .F.
	EndIf
	If CZB->CZB_STAB == '2'
	   Return .F.
	EndIf
return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102VCD
Função para validação do código do template (CZD_CDMD)

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102VCD()

	Local oModel:=FWModelActive()
	Local oModelCZE:=oModel:GetModel('CZEDETAIL')
	Local oModelCZD:=oModel:GetModel('CZDMASTER')
	Local var:=0

	dbSelectArea("CZD")
	if (CZD->(dbSeek(xFilial("CZD")+oModelCZD:getValue("CZD_CDMD"))))
	   Help( ,, 'Help',, STR0017, 1, 0 ) //'Template já cadastrado.'
	   return .F.
	endif

	for var:= 1 to oModelCZE:getQtdLine()
	   oModelCZE:goline(var)
	   oModelCZE:setValue("CZE_CDMD",oModelCZD:getValue("CZD_CDMD"))
	next

return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102VGR
Função para validação da grid


@param oModelGrid      Modelo da grid
@param nLinha          Linha que está sendo modificada
@param cAcao           Ação que está sendo realizada

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function PCPA102VGR( oModelGrid, nLinha, cAcao, cCampo )
	Local lRet := .T.
	Local oModel := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()
	Local oModelCZE  := oModel:GetModel('CZEDETAIL')

	// Valida se pode ou não apagar uma linha do Grid
	If cAcao == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE
		//verifica se o atributo está sendo utilizado na ficha técnica
		dbSelectArea("CZG")
		CZG->(dbSetOrder(2))
		
		If !CZEWASCOMITED(FWFldGet('CZD_CDMD'), oModelCZE:getValue('CZE_CDAB'))
			lRet := .T.
		ElseIf CZG->(dbSeek(xFilial("CZG")+CZD->CZD_CDMD)) .AND. SUPERGETMV("MV_PCPMOFT" , .F. , "N") == "S"
			Help( ,, 'Help',,STR0023, 1, 0 )//"Não é possível excluir atributos enquanto o template estiver sendo utilizado na ficha técnica."
			lRet := .F.
		Elseif CZG->(dbSeek(xFilial("CZG")+FWFldGet('CZD_CDMD')+oModelCZE:getValue('CZE_CDAB'))) 
			Help( ,, 'Help',, STR0014 + FWFldGet('CZE_CDAB') + STR0015, 1, 0 ) //'Atributo XXXXX já está sendo utilizado na ficha técnica, exclusão não permitida.'
			lRet := .F.
		EndIf
	EndIf	

Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102WAB
Função para permitir ou não a alteração do atributo

@author  Lucas Konrad França
@since   10/09/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102WAB()

	Local oModel:=FWModelActive()
	If oModel:GetOperation() == 5
		Return .F.
	EndIf
	if oModel:GetOperation() == 4
		dbSelectArea("CZG")
		CZG->(dbSetOrder(2))
		if CZG->(dbSeek(xFilial("CZG")+FWFldGet('CZD_CDMD')+FWFldGet('CZE_CDAB')))
			Help( ,, 'Help',, STR0014 +FWFldGet('CZE_CDAB')+ STR0018, 1, 0 ) //'Atributo XXXX já está sendo utilizado na ficha técnica, alteração não permitida.'
			return .F.
		else
			return .T.
		endif
	endif

return .T.

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102WMD
Função para permitir ou não a alteração do tipo de template

@author  Lucas Konrad França
@since   03/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102WMD()
	Local lRet      := .T.
	Local oModel    := FWModelActive()
	Local oModelCZD := oModel:GetModel('CZDMASTER')

	dbSelectArea("CZF")
	CZF->(dbSetOrder(2))
	If CZF->(dbSeek(xFilial("CZF")+oModelCZD:GetValue('CZD_CDMD')))
		lRet := .F.
	EndIf

Return lRet
//---------------------------------------------------------------------------------------------
//Verifica se o atributo pode ser deletado durante a alteração.
Static Function CZEWASCOMITED(cTempl, cAtbr) 
	
	Local cSqlAlias := GetNextAlias()
	Local cQuery    := ""
	
	cQuery :=	" SELECT 1 " 
	cQuery +=	"     FROM " + RetSqlName('CZE') + " AS CZE "
	cQuery +=	" WHERE CZE.CZE_CDMD = '" + cTempl + "'"
	cQuery +=	" AND CZE_CDAB = '" + cAtbr + "'"
	cQuery +=	" AND CZE_FILIAL = '" + xFilial('CZE') + "'"
	cQuery +=	" AND CZE.D_E_L_E_T_ = ''"
	
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cSqlAlias, .T., .T. )
	
Return !(cSqlAlias)->(EOF())

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102SEQ
Retorna o próximo sequêncial do campo CZE_SQAB

@author  Lucas Konrad França
@since   18/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102SEQ()
	Local nSeq      := 0
	Local oModel    := FWModelActive()
	Local oModelCZE := oModel:GetModel('CZEDETAIL')
	Local nI        := 1
	Local nLinAtu   := oModelCZE:getLine()

	For nI := 1 To oModelCZE:getQtdLine()
		oModelCZE:goLine(nI)
		If oModelCZE:GetValue("CZE_SQAB") > nSeq
			nSeq := oModelCZE:GetValue("CZE_SQAB")
		EndIf
	Next nI
	nSeq++
	oModelCZE:goLine(nLinAtu)
Return nSeq

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} regeraSeq
Gera novamente o sequêncial CZE_SQAB

@author  Lucas Konrad França
@since   18/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function regeraSeq(oModel)
	Local nI        := 1
	Local oModelCZE := oModel:GetModel('CZEDETAIL')
	If oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4
		For nI := 1 To oModelCZE:GetQtdLine()
			oModelCZE:GoLine(nI)
			oModelCZE:SetValue("CZE_SQAB",nI)
		Next nI
		oModelCZE:GoLine(1)
	EndIf
Return Nil

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102CMM
Função de commit do model

@author  Lucas Konrad França
@since   18/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102CMM(oModel)
	Local lRet := .T.

	If oModel:GetOperation() != MODEL_OPERATION_INSERT .And. (Type("lAltSeq")=="L" .And. lAltSeq)
		lAltSeq := MsgYesNo(STR0027, STR0028) //"Sequência de atributos alterada. Deseja atualizar a sequência de atributos nas fichas técnicas que utilizam este template?" ## "Atenção"
	EndIf

	If Type("lAltSeq") != "L"
		lAltSeq := .F.
	EndIf

	Begin Transaction

		If lAltSeq
			Processa({|| atualizaFT(oModel)}, STR0029, STR0030, .F.) //"Processando" ## "Atualizando fichas técnicas"
		EndIf
		If lRet
			FWFormCommit(oModel)
		Else
			DisarmTransaction()
		EndIf

	End Transaction
Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102VSQ
Validação do campo CZE_SQAB

@author  Lucas Konrad França
@since   18/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102VSQ()
	Local lRet := .T.
	If !Positivo()
		lRet := .F.
	Else
		lAltSeq := .T.
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} atualizaFT
Atualiza a sequência dos atributos nas fichas técnicas que utilizam o template alterado.

@author  Lucas Konrad França
@since   18/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Static Function atualizaFT(oModel)
	Local lRet      := .T.
	Local cTemplate := oModel:GetModel("CZDMASTER"):GetValue("CZD_CDMD")
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local aAtrib    := {}
	Local nI        := 1

	For nI := 1 To oModel:GetModel("CZEDETAIL"):GetQtdLine()
		oModel:GetModel("CZEDETAIL"):GoLine(nI)
		aAdd(aAtrib, {oModel:GetModel("CZEDETAIL"):GetValue("CZE_CDAB"),;
                    oModel:GetModel("CZEDETAIL"):GetValue("CZE_SQAB") })
	Next nI

	cQuery := " SELECT COUNT(*) TOTAL "
	cQuery +=   " FROM " + RetSqlName("CZG") + " CZG "
	cQuery +=  " WHERE CZG.CZG_FILIAL = '" + xFilial("CZG") + "' "
	cQuery +=    " AND CZG.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND CZG.CZG_CDMD   = '" + cTemplate + "'"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

	ProcRegua((cAliasQry)->(TOTAL))
	(cAliasQry)->(dbCloseArea())

	dbSelectArea("CZG")
	CZG->(dbSetOrder(2))
	If CZG->(dbSeek(xFilial("CZG")+cTemplate))
		While CZG->(!Eof()) .And. CZG->(CZG_FILIAL+CZG_CDMD) == xFilial("CZG")+cTemplate
			nI := aScan(aAtrib, {|x| x[1] == CZG->CZG_CDAB})
			If nI > 0
				RecLock("CZG",.F.)
				CZG->CZG_SQAB := aAtrib[nI,2]
				CZG->(MsUnLock())
			EndIf
			CZG->(dbSkip())
			IncProc()
		End
	EndIf

Return lRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA102ATB
Função de consulta específica do campo CZE_CDAB

@author  Lucas Konrad França
@since   26/02/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------------
Function PCPA102ATB()
	Local oDlg, oList, oCheckBox
	Local aColunas  := {}
	Local aAtributo := buscaAtrib()
	Local lRet      := .F.

	Private lCheckAll := .F.

	//Valida se encontrou algum atributo.  
	If Empty(aAtributo)
		Help(,,'PCPA102',, STR0040,1,0 )
	Else 
		DEFINE MSDIALOG oDlg TITLE STR0039 FROM 0,0 TO 378,592 PIXEL //"Atributos"

		aAdd(aColunas," ")
		aAdd(aColunas,STR0035) //"Atributo"
		aAdd(aColunas,STR0036) //"Nome atributo"
		aAdd(aColunas,STR0037) //"Descrição"
		aAdd(aColunas,STR0038) //"Relação"

		oList := TWBrowse():New( 05, 05, 290,160,,aColunas,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oList:SetArray(aAtributo)
		oList:bLine := {|| {aAtributo[oList:nAt,1],;
                       aAtributo[oList:nAt,2],;
                       aAtributo[oList:nAt,3],;
                       aAtributo[oList:nAt,4],;
                       aAtributo[oList:nAt,5]} }
		oList:bLDblClick := {|| trocaCheck(oList, aAtributo)}


		@ 06, 06 CHECKBOX oCheckBox VAR lCheckAll PROMPT "" WHEN PIXEL OF oDlg SIZE 015,015 MESSAGE ""
		oCheckBox:bChange := {|| MarcaTodos(oList,aAtributo) }

		DEFINE SBUTTON FROM 170,240 TYPE 2 ACTION (lRet:=.F.,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 170,269 TYPE 1 ACTION (lRet:=confPad(oList,aAtributo),oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER

	Endif	
Return lRet

Static Function buscaAtrib()
	Local aAtributo := {}
	Local cRelac    := ""
	Local oCb
	Local oModel    := FWModelActive()
	Local oModelCZE := oModel:GetModel('CZEDETAIL')
	Local nI        := 1
	Local nLine     := oModelCZE:GetLine()
	Local lAchou    := .F.

	dbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	CZB->(dbSeek(xFilial("CZB")))
	While CZB->(!Eof()) .And. CZB->CZB_FILIAL == xFilial("CZB")
		If !PCPA102FIL(oModel)
			CZB->(dbSkip())
			Loop
		EndIf
		lAchou := .F.
		
		Do Case
			Case CZB->(CZB_RLAB) == "1"
				cRelac := STR0031 //"Produto"
			Case CZB->(CZB_RLAB) == "2"
				cRelac := STR0032 //"Recurso"
			Case CZB->(CZB_RLAB) == "3"
				cRelac := STR0033 //"Família Técnica"
			Case CZB->(CZB_RLAB) == "4"
				cRelac := STR0034 //"Todos"
		EndCase
		
		For nI := 1 To oModelCZE:GetQtdLine()
			oModelCZE:GoLine(nI)
			If oModelCZE:GetValue("CZE_CDAB") == CZB->(CZB_CDAB) .And. !oModelCZE:IsDeleted()
				lAchou := .T.
				Exit
			EndIf
		Next nI
		
		If lAchou
			oCb := LoadBitmap( GetResources(), "LBOK" )
		Else
			oCb := LoadBitmap( GetResources(), "LBNO" )
		EndIf
		
		aAdd(aAtributo,{oCb,;
                      CZB->(CZB_CDAB),;
                      CZB->(CZB_NMAB),;
                      CZB->(CZB_DSAB),;
                      cRelac,;
                      lAchou})
                      
		CZB->(dbSkip())
	End
	oModelCZE:GoLine(nLine)
Return aAtributo

Static Function MarcaTodos(oList,aAtributo)
	Local nI := 1

	For nI := 1 To Len(aAtributo)
		If lCheckAll
			aAtributo[nI,1] := LoadBitmap( GetResources(), "LBOK" )
			aAtributo[nI,6] := .T.
		Else
			aAtributo[nI,1] := LoadBitmap( GetResources(), "LBNO" )
			aAtributo[nI,6] := .F.
		EndIf
	Next nI
	oList:Refresh()
	
Return

Static Function trocaCheck(oList, aAtributo)
	If aAtributo[oList:nAt,6]
		aAtributo[oList:nAt,1] := LoadBitmap( GetResources(), "LBNO" )
	Else
		aAtributo[oList:nAt,1] := LoadBitmap( GetResources(), "LBOK" )
	EndIf
	aAtributo[oList:nAt,6] := !aAtributo[oList:nAt,6]
   
Return .T.

Static Function confPad(oList,aAtributo)
	Local nI := 0
	Local nJ := 0
	Local oModel    := FWModelActive()
	Local oModelCZE := oModel:GetModel('CZEDETAIL')
	Local nLine     := oModelCZE:GetLine()
	Local aAddAtrib := {}
	Local lAchou    := .F.
	Local lRet      := .T.
	Local oView     := FwViewActive()

	For nI := 1 To Len(aAtributo)
		lAchou := .F.
		If aAtributo[nI,6]
			For nJ := 1 To oModelCZE:GetQtdLine()
				oModelCZE:GoLine(nJ)
				If oModelCZE:GetValue("CZE_CDAB") == aAtributo[nI,2] .And. !oModelCZE:IsDeleted()
					lAchou := .T.
					Exit
				EndIf
			Next nJ
			
			If !lAchou
				aAdd(aAddAtrib, aAtributo[nI])
			EndIf
		EndIf
	Next nI
	
	If Len(aAddAtrib) < 1
		lRet := .F.
	Else
   
		If Len(aAddAtrib) > 1
			oModelCZE:GoLine(nLine)
			
			For nI := 1 To Len(aAddAtrib)
				If nI > 1
					oModelCZE:AddLine()
				EndIf
				
				oModelCZE:SetValue("CZE_CDAB",aAddAtrib[nI,2])
			Next nI
			oModelCZE:GoLine(nLine)
		EndIf
		
		dbSelectArea("CZB")
		CZB->(dbSetOrder(1))
		CZB->(dbSeek(xFilial("CZB")+aAddAtrib[1,2]))
		oModelCZE:GoLine(nLine)
		oView:Refresh()
	EndIf
   
Return lRet
