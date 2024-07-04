#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FWBrowse.ch'
#Include 'FINA761.ch'

STATIC __cSituacao := ""
STATIC __cTabela	:= ""
STATIC __cAbaAtiva	:= ""
STATIC __cTabModel	:= ""
STATIC __lGrid		:= .F.
STATIC __lModif		:= .F.
STATIC __aF761Ctrl	:= {}
STATIC oModAtu	:= NIL
STATIC oModFull	:= NIL
STATIC oModPai		:= NIL
STATIC oModFVN  := NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA761VAR
Rotina responsável pela tela de campos variáveis

@param cSituacao - Situação informada
@param cTabela	 - Tabela que contém o campo de situação (Pai)
@param oModelAtu - Model atual
@param cAbaAtiva - Aba ativa do botão de campos variáveis
@param cTabModel - Tabela do modelo em que foi acionado o botão de campos variáveis

@author Mauricio Pequim Jr
@since 05/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fina761Var(cSituacao,cTabela,oModelAtu,cAbaAtiva,cTabModel,lModified,oModel,cModelID,aF761Ctrl)

Local oModelAtv	:= oModel //FwModelActive()		//Model completo (FINA761)
Local oModelFVN	:= oModelAtv:GetModel('DETFVN')
Local oModelTab	:= oModelAtv:GetModel("DET"+cTabela)
Local nOper	 	:= oModelAtv:GetOperation()
Local cCpoItem	:= cTabModel + "_ITEM"
Local cCpItTbPai	:= cTabela + "_ITEM"
Local cModSon		:= IIf(!EMPTY(cModelID),cModelID,"DET"+cTabModel)
Local aSeekFVN	:= {}

DEFAULT cSituacao := ""
DEFAULT cTabela   := ""
DEFAULT cTabModel := ""	

If cTabela == "FV2"
	oModelTab	:= oModelAtv:GetModel("PCOSITUACA")
EndIf

__cSituacao	:= cSituacao
__cTabela	:= cTabela
__cTabModel	:= cTabModel
__cAbaAtiva	:= cAbaAtiva
__aF761Ctrl	:= aF761Ctrl
oModFull	:= oModelAtv
oModAtu 	:= oModelAtu
oModFVN 	:= oModelFVN
__lModif	:= lModified

//Verifico se o model de campos variáveis foi chamado de uma tabela filha da que contém a informação da situação
__lGrid	 	:= (cTabela != cTabModel)

If __lGrid
	oModPai		:= oModAtu
	oModAtu		:= oModelAtv:GetModel(cModSon)
Endif 

dbSelectArea('FVN')

If nOper == MODEL_OPERATION_INSERT
	aAdd(aSeekFVN,{'FVN_TABELA',cTabModel})
	aAdd(aSeekFVN,{'FVN_ITETAB', oModAtu:GetValue(cCpoItem)})
	If __lGrid
		aAdd(aSeekFVN,{'FVN_TABPAI',cTabela})
		aAdd(aSeekFVN,{'FVN_ITEPAI',oModelTab:GetValue(cCpItTbPai)})
	EndIf
	If !oModelFVN:IsEmpty() .AND. oModelFVN:SeekLine(aSeekFVN)
		nOper := 4
	EndIf
Endif
		
FV4->(dbSetOrder(1))	//FV4_FILIAL+FV4_SITUAC+FV4_IDCAMP
FV4->(DbGoTop())
If FV4->(DbSeek(xFilial("FV4")+__cSituacao))
	While FV4->(!Eof()) .AND. FV4->(FV4_FILIAL+FV4_SITUAC) == xFilial("FV4")+__cSituacao
		If FV4->FV4_STATUS == '1' .AND. Iif(__lGrid,FV4->FV4_LOCAL == '2',FV4->FV4_LOCAL == '1')
			FWExecView(STR0077, 'FINA761VAR', nOper, /*oDlg*/, {|| .T. }/*bCloseOnOk*/, /*bOk*/ , 50/*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )	//"Campos Variáveis"
			Exit
		EndIf
		FV4->(DbSkip())
	EndDo
Else
	Help( ,,"NO_COMPLEM",,STR0120, 1, 0 )	//"Não é necessária a informação de complementos para esta situação."
Endif

FWModelActive(oModelAtv)

lModified := __lModif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao responsavel pelo modelo

@author Mauricio Pequim Jr
@since 05/01/2015
@version 1.0

@return Objeto Retorna o objeto do modelo de dados do cadastro de documento habéis

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModelAtv		:= FwModelActive()
Local oModel 		:= MPFormModel():New('FINA761VAR',/*bPre*/,/*{||F761ValDoc()}*/,{|| F761AtuFVN(oModelAtv)}/*bCommit*/,/*bCancel*/)
Local oStruModel	:= F761ModelStru()
Local oStruGrid		:= NIL

oModel:Addfields("FIELDVAR",/*cOwner*/,oStruModel /*oStruct*/,/*bPre*/,/*bPost*/,{|oModel| F761LoadMod(oModel,oModelAtv) }/*bLoad*/)
oModel:SetDescription("Campos Variáveis")
oModel:GetModel("FIELDVAR"):SetDescription("Campos Variáveis")

oModel:SetPrimaryKey({})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Mauricio Pequim Jr

@since 05/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oModel 	:= FWLoadModel('FINA761VAR')
Local oView		:= FWFormView():New()
Local oViewStru	:= F761ViewStru()

oView:SetModel(oModel)
oView:AddField('VFIELDVAR', oViewStru,"FIELDVAR" )

	oView:CreateHorizontalBox( 'BOXFORM1', 100)
	oView:SetOwnerView('VFIELDVAR','BOXFORM1')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F761ModelStru	

Estrutura de dados para armazenar no modelo dos campos essenciais cadastro do Documento Hábil

@author Mauricio Pequim Jr
@since 05/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function F761ModelStru()

Local oStruModel := FWFormModelStruct():New()
Local lObrigat	 := .F.
Local cTipoCpo	 := ""
Local aComboValues := {}
Local bWhen		:= ""
Local bValid	:= ""

FV4->(dbSetOrder(1))	//FV4_FILIAL+FV4_SITUAC+FV4_IDCAMP
FV4->(DbGoTop())
If FV4->(DbSeek(xFilial("FV4")+__cSituacao))
	While !FV4->(EOF()) .and. FV4->(FV4_FILIAL+FV4_SITUAC) == xFilial("FV4")+__cSituacao .AND. FV4->FV4_STATUS == '1'

		//Verifico se o campo variável pertence a tabela da situação ou do item
		If (__lGrid .and. FV4->FV4_LOCAL == "1") .OR. (!__lGrid .and. FV4->FV4_LOCAL == "2")
			FV4->(DBSkip())
			Loop
		Endif

		DO CASE
			Case FV4->FV4_TPCAMP $ '1/2'		//Caracter ou numerico
				cTipoCpo := "C"
			CASE FV4->FV4_TPCAMP == '3'		//Lógico 				
				cTipoCpo := "L"
			CASE FV4->FV4_TPCAMP == '4'		//Data
				cTipoCpo := "D"
		END CASE					

		If !Empty(FV4->FV4_OPCOES)
			aComboValues := STRTOKARR(FV4->FV4_OPCOES,";")
		Else
			aComboValues := {}
		Endif		

		If !Empty(FV4->FV4_VALID)
			bValid := FwBuildFeature( STRUCT_FEATURE_VALID,FV4->FV4_VALID )
		Else
			bValid := FwBuildFeature( STRUCT_FEATURE_VALID,"AllwaysTrue()" )
		Endif

		If !Empty(FV4->FV4_WHEN)
			bWhen := MontaBlock("{|| "+ FV4->FV4_WHEN +" } ")
		Else
			bWhen := MontaBlock("{|| AllwaysTrue() } ")
		Endif

		lObrigat	:= If(FV4->FV4_OBGCAM == '1',.T.,.F.)// .and. Eval(bWhen)
		lObrigat	:= lObrigat .and. Eval(bWhen)

		oStruModel:AddField(			  ;
			FV4->FV4_DSCAMP 	, ;	// [01] Titulo do campo		//"Filial do Sistema"
			FV4->FV4_DSCAMP		, ;	// [02] ToolTip do campo	//"Filial do Sistema"
			"C" + FV4->FV4_IDCAMP	, ;	// [03] Id do Field
			cTipoCpo			, ;	// [04] Tipo do campo
			FV4->FV4_TAMCAM		, ;	// [05] Tamanho do campo
			FV4->FV4_DECCAM			, ;	// [06] Tamanho do campo
			bValid				, ;	// [07] Code-block de validação do campo
			bWhen				, ;	// [08] Code-block de validação do campo
			aComboValues		, ;	// [09] aComboValues (Opções)
			lObrigat			)	// [10] Indica se o campo tem preenchimento obrigatório

		FV4->(dbSkip())
	EndDo

Endif

Return oStruModel


//------------------------------------------------------------------- 
/*/{Protheus.doc} F761ViewStru		

Estrutura de interface para as informações essenciais do cadastro do Documento Hábil.

@author Mauricio Pequim Jr
@since 05/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
//Monta estrutura da View
Static Function F761ViewStru()

Local oStruView	:= FWFormViewStruct():New()
Local cPicture	:= ""
Local cTipoCpo	:= ""
Local aComboValues := {}

FV4->(dbSetOrder(1))	//FV4_FILIAL+FV4_SITUAC+FV4_IDCAMP
FV4->(DbGoTop())
If FV4->(DbSeek(xFilial("FV4")+__cSituacao))
	While !FV4->(EOF()) .and. FV4->(FV4_FILIAL+FV4_SITUAC) == xFilial("FV4")+__cSituacao .AND. FV4->FV4_STATUS == '1'

		//Verifico se o campo variável pertence a tabela da situação ou do item
		If (__lGrid .and. FV4->FV4_LOCAL == "1") .OR. (!__lGrid .and. FV4->FV4_LOCAL == "2")
			FV4->(DBSkip())
			Loop
		Endif

		cPicture := FV4->FV4_PICCAM
		DO CASE
			Case FV4->FV4_TPCAMP $ '1/2'		//Caracter ou numerico
				cTipoCpo := "C"
				cPicture := "@R "+ FV4->FV4_PICCAM
			CASE FV4->FV4_TPCAMP == '3'		//Lógico 				
				cTipoCpo := "L"
			CASE FV4->FV4_TPCAMP == '4'		//Data
				cTipoCpo := "D"
		END CASE					

		If !Empty(FV4->FV4_OPCOES)
			aComboValues := STRTOKARR(FV4->FV4_OPCOES,";")
		Else
			aComboValues := {}
		Endif		

		oStruView:AddField(				  ;
			"C" + FV4->FV4_IDCAMP		, ;		// [01] Id do Field
			Right(FV4->FV4_IDCAMP,2) 	, ;		// [02] Ordem
			FV4->FV4_DSCAMP 			, ;		// [03] Titulo do campo		//"Filial do Sistema"
			FV4->FV4_DSCAMP				, ;		// [04] ToolTip do campo	//"Filial do Sistema"
										, ;		// [05] Help
			cTipoCpo					, ;		// [06] Tipo do campo
			cPicture					, ;		// [07] Picture
										, ;		// [08] PictVar
			Alltrim(FV4->FV4_CSPCAM)	, ;		// [09] F3
			.T.							, ;		// [10] Cmpo Evitável ?
										, ;		// [11] Folder
										, ;		// [12] Grupo
			aComboValues				, ;		// [13] aComboValues (Opções)
										, ;		// [14] nMaxLenCombo
			          	   				, ;  	// [16] cIniBrow
			          	   				, ;		// [17] lVirtual
			          	   				)		// [18] cPictVar
			          	   						

		FV4->(dbSkip())
	EndDo

Endif

Return oStruView


//-------------------------------------------------------------------
/*/{Protheus.doc} F761LoadMod
Inicializador de valores da View

@author Mauricio Pequim Jr

@since 06/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F761LoadMod(oModel,oModelAtv)

Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local oStruct		:= F761ModelStru()
Local aAux			:= oStruct:GetFields()
Local nTamFVN		:= oModFVN:Length()
Local cItem			:= ""
Local cIdCampo		:= ""
Local cValor		:= ""
Local cTipo			:= ""
Local nX			:= 0
Local nPos			:= 0
Local aDadosField	:= {}
Local aValorCpos	:= {}
Local cTabela		:= ""
Local nTamCpo		:= 0
Local oModelTab	:= Nil
Local cCpoItem	:= __cTabModel + "_ITEM"
Local cCpItTbPai	:= __cTabela + "_ITEM"
Local bTabFilho	:= { || Iif(__lGrid,oModFVN:GetValue('FVN_TABPAI',nX) == __cTabela .AND. oModFVN:GetValue('FVN_ITEPAI',nX) == oModelTab:GetValue(cCpItTbPai),.T.)}

If  __cTabela == "FV5"
	oModelTab := 	oModelAtv:GetModel("PCOEMPENHO")
ElseIf  __cTabela == "FV2"
	oModelTab := 	oModelAtv:GetModel("PCOSITUACA")
Else
	oModelTab := 	oModelAtv:GetModel("DET"+__cTabela)
EndIf

//Se for uma alteração
If nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_VIEW
			
	cCpoItem := __cTabModel + "_ITEM"

	If !Empty(__cTabModel)
		aValorCpos := {}
		cItem	:= oModAtu:GetValue(cCpoItem)
		For nX := 1 to nTamFVN
			oModFVN:GoLine(nX)
			If !(oModFVN:IsDeleted()) .and. oModFVN:GetValue('FVN_TABELA',nX) == __cTabModel .and. oModFVN:GetValue('FVN_ITETAB',nX) == cItem .AND. Eval(bTabFilho)
				cIdCampo := AllTrim(oModFVN:GetValue('FVN_CAMPO'))
				If ( nPos := AScan( aAux, { |x| x[3] == cIdCampo } ) ) > 0
					cTipo	 := aAux[nPos][4]
					nTamCpo	 := aAux[nPos][5]
					cValor	 := oModFVN:GetValue("FVN_VALOR",nX)
					
					If cTipo $ 'C|N'
						cValor := Substr(cValor,1,nTamCpo)
					ElseIf cTipo == 'D'
						cValor := CTOD(cValor) 
					Endif

					AADD(aValorCpos,cValor)
				Endif
			Endif
			
		Next nX
	Endif
	If Len(aValorCpos) > 0
		aDadosField := {aValorCpos,1}
	Endif
Endif

Return aDadosField

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FVNCarga		TO DO

Atualiza model da FVN apos confirmação da tela de campos variaveis

@author Mauricio Pequim Jr
@since 29/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function  F761AtuFVN(oModelAtv)

Local lRet		:= .T.
Local oModel	:= FwModelActive()
Local oSubField := oModel:GetModel("FIELDVAR")
Local nOperation:= oModel:GetOperation()
Local oModelFVN := oModelATV:GetModel("DETFVN")  
Local cIdCampo	:= ""
Local cTipo		:= ""
Local cValor	:= ""
Local oStruct 	:= oSubField:GetStruct()
Local aAux		:= oStruct:GetFields()
Local nX		:= 0
Local cLog		:= ""
Local cItemTab	:= ""
Local cTabPai	:= ""
Local cItemPai	:= ""


If (lRet := oModel:VldData())

	cItemTab := oModAtu:GetValue(__cTabModel+"_ITEM",oModAtu:GetLine())
	
	If __lGrid
		cTabPai	 :=	__cTabela		
		cItemPai := oModPai:GetValue(__cTabela+"_ITEM",oModPai:GetLine())
	Endif

	For nX := 1 to Len(aAux)
		cIdCampo := aAux[nX][3]
		cTipo	 := aAux[nX][4]
		cValor	 := oSubField:GetValue(cIdCampo)
		
		If cTipo == 'D'
			cValor := DTOC(cValor)
		Endif

		If nOperation == MODEL_OPERATION_UPDATE
			If !(oModelFVN:SeekLine( { {"FVN_TABELA", __cTabModel}, {"FVN_ITETAB", cItemTab}, {"FVN_CAMPO", cIdCampo} } ))
	 			oModelFVN:AddLine()		
			Endif	
		ElseIf !(oModelFVN:IsEmpTy())
 			oModelFVN:AddLine()		
		Endif	
			
		oModelFVN:SetValue("FVN_TABELA" , __cTabModel)
		oModelFVN:SetValue("FVN_ITETAB" , cItemTab)
		oModelFVN:SetValue("FVN_CAMPO"  , cIdCampo)			
		oModelFVN:SetValue("FVN_VALOR"  , cValor)
		oModelFVN:SetValue("FVN_TABPAI" , cTabPai)
		oModelFVN:SetValue("FVN_ITEPAI" , cItemPai)
	Next

	If !(lRet := oModelFVN:VldData())
	    cLog := cValToChar(oModelFVN:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
	    cLog += cValToChar(oModelFVN:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
	    cLog += cValToChar(oModelFVN:GetErrorMessage()[MODEL_MSGERR_MESSAGE])       
	    
	    Help( ,,"MODELFVN",,cLog, 1, 0 )	             
	Else
		__lModif := .T.
	Endif	
Else
    cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
    cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
    cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])        	
    
    Help( ,,"MODELVAR",,cLog, 1, 0 )	             
Endif

//Limpa os objetos MVC da memória
oModel:Deactivate()
oModel:Destroy()
oModel := Nil
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761WhenCtr
When do campo variável de contrato. 

@author Mauricio Pequim Jr
@since 12/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function F761WhenCtr(lGRU)

Local lRet		:= .T.
Local oModelTab	:= Nil
Local nTipFor		:= GTpForOrg(oModFull:GetModel('CABDI'):GetValue("FV0_FORNEC"),oModFull:GetModel('CABDI'):GetValue("FV0_LOJA"))
Local nPosCtrl	:= 0
DEFAULT lGRU		:= .F.

If  __cTabModel == "FV5"
	oModelTab := 	oModFull:GetModel("PCOEMPENHO")
ElseIf  __cTabModel == "FV2"
	oModelTab := 	oModFull:GetModel("PCOSITUACA")
Else
	oModelTab := 	oModFull:GetModel("DET"+__cTabModel)
EndIf

If __cAbaAtiva == "PCOSITUACA" .AND. !lGRU
	lRet := (oModFull:GetModel("PCOSITUACA"):Getvalue("FV2_CONTRA",oModFull:GetModel("PCOSITUACA"):GetLine()) == "1" )
ElseIf lGRU
	lRet := nTipFor == 2 // Se o fornecedor for oficial (Órgão Público)
Endif

If (nPosCtrl := aScan(__aF761Ctrl,{|cTab| cTab[1] == __cTabModel})) == 0
	Aadd(__aF761Ctrl,{__cTabModel,lRet})
Else
	If !lRet .AND. __aF761Ctrl[nPosCtrl][2]
		__aF761Ctrl[nPosCtrl][2] := lRet
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761VCGC
Validação de campo de CNPJ

@author Alvaro Camillo Neto
@since 04/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function F761VCGC(cIDCampo)

Local lRet			:= .F.
Local oModel		:= FWModelActive()
Local oModelTab 	:= oModel:GetModel("FIELDVAR")
Local cConteudo	:= ""

If oModelTab != Nil
	cConteudo	:= oModelTab:GetValue(cIDCampo)
	lRet 		:= CGC(cConteudo)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761VCT1
Validação de campo de conta

@author Alvaro Camillo Neto
@since 04/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function F761VCT1(cIDCampo)

Local lRet			:= .F.
Local oModel		:= FWModelActive()
Local oModelTab 	:= oModel:GetModel("FIELDVAR")
Local cConteudo	:= ""

If oModelTab != Nil
	cConteudo	:= oModelTab:GetValue(cIDCampo)
	lRet 		:= ValidaConta(cConteudo)
EndIf

Return lRet


