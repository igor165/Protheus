#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPA115.CH'

/*/{Protheus.doc} GTPA115
    Programa em MVC do cadastro de Bilhetes (Passagens)
    @type  Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example
    GTPA115()
    @see (links_or_references)
/*/
Function GTPA115(lFiltro)

Local cAliasFilt	:= GetNextAlias()
Local cUserAtual	:= RetCodUsr()
Local oBrowse	 	:= FWMBrowse():New()
Local cAgeUser		:= ""
Local nCont := 0
Local aFiltro := {}

Default lFiltro		:= .T.

oBrowse:SetAlias("GIC")
oBrowse:SetDescription(STR0001) // "Cadastro de Passagens (Bilhetes)"
oBrowse:SetMenuDef('GTPA115')

If lFiltro
	BeginSQL Alias cAliasFilt
		SELECT GI6_CODIGO 
		FROM %Table:GI6% GI6
		INNER JOIN %Table:G9X% G9X ON
			G9X.G9X_CODGI6 = GI6.GI6_CODIGO
			AND G9X.G9X_CODUSR = %Exp:cUserAtual%
			AND G9X.%NotDel%
		WHERE	
			GI6.%NotDel%
	EndSQL
			
	IF (cAliasFilt)->(!EOF())
		
		While (cAliasFilt)->(!Eof())
		
			cAgeUser += (cAliasFilt)->GI6_CODIGO + '|'
			If Len(cAgeUser) >= 1024
				AADD(aFiltro, cAgeUser)	
				cAgeUser := ""		
			EndIf
			(cAliasFilt)->(dbSkip())
		End
		
		For nCont := 1 To LEN(aFiltro)
			oBrowse:SetFilterDefault ( 'GIC_AGENCI $ "' + aFiltro[nCont] + '"')
		Next nCont
		
	Endif
	If Select(cAliasFilt) > 0
		(cAliasFilt)->(dbCloseArea())
	Endif
Endif
If !IsBlind()
	oBrowse:Activate()
Endif
Return()

/*/{Protheus.doc} GTPA115NoFil
(long_description)
@type function
@author jacomo.fernandes
@since 26/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA115NoFil()
Return GTPA115(.F.)

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados para o cadastro de Bilhetes (Passagens)
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= nil
Local oStrGIC	:= FWFormStruct( 1, "GIC",,.F. )
Local oStrGZP	:= FWFormStruct( 1, "GZP",,.F. )
Local bCommit	:= { |oModel| GA115Commit(oModel)}
Local bPosValid	:= {|oModel| GA115PosVld(oModel)}
Local bValid    := {|oSubMdl,cAction,cField,xValue| GA115Valid(oSubMdl,cAction,cField,xValue)}


SetModelStruct(oStrGIC,oStrGZP)

oModel := MPFormModel():New("GTPA115")

oModel:SetPost(bPosValid)
oModel:SetCommit(bCommit)

oModel:AddFields("GICMASTER", /*cOwner*/, oStrGIC, bValid)
oModel:addGrid('GZPPAGTO','GICMASTER',oStrGZP, /*bPreValid*/  , /*bPosLValid*/ , /*bPre*/,/*bPost*/, /*bLoad*/ )

oModel:GetModel( 'GZPPAGTO' ):SetMaxLine(6)

oModel:SetRelation("GZPPAGTO", {{"GZP_FILIAL","xFilial('GZP')"},{"GZP_CODIGO","GIC_CODIGO"},{"GZP_CODBIL","GIC_BILHET"}}, GZP->(IndexKey(1)))
oModel:GetModel("GZPPAGTO"):SetOptional(.t.)

oModel:SetDescription(STR0001) // "Cadastro de Passagens (Bilhetes)"

oModel:SetVldActivate({|oModel| GA115Del(oModel)})

Return(oModel)

/*/{Protheus.doc} SetModelStruct
(long_description)
@type  Static Function
@author user
@since 19/02/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStrGIC,oStrGZP)

Local bFldVal  := {|oMdl,cField,uNewValue,uOldValue|FieldVal(oMdl,cField,uNewValue,uOldValue) } 
Local bFldWhen := {|oMdl,cField,uVal|FieldWhen(oMdl,cField,uVal) } 
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

oStrGIC:SetProperty('GIC_CODGID', MODEL_FIELD_OBRIGAT, .F.)
oStrGIC:SetProperty('GIC_CODSRV', MODEL_FIELD_OBRIGAT, .F.)
oStrGIC:SetProperty('GIC_DTVIAG', MODEL_FIELD_OBRIGAT, .F.)
oStrGIC:SetProperty('GIC_BILHET', MODEL_FIELD_OBRIGAT, .F.)
oStrGIC:SetProperty('GIC_HORA'  , MODEL_FIELD_OBRIGAT, .F.)
oStrGIC:SetProperty('GIC_LINHA' , MODEL_FIELD_OBRIGAT, .F.)
oStrGIC:SetProperty('GIC_LOCORI', MODEL_FIELD_OBRIGAT, .F.)
oStrGIC:SetProperty('GIC_LOCDES', MODEL_FIELD_OBRIGAT, .F.)

oStrGIC:SetProperty( 'GIC_DTVEND', MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty( 'GIC_BILREF', MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty( 'GIC_TIPDOC', MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty( 'GIC_AGENCI', MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty( 'GIC_TIPO'  , MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty( 'GIC_ECF'   , MODEL_FIELD_VALID, bFldVal)

//Validações de campos abaixo foram adicionados para permitir a inclusão de bilhetes mesmo se um dos dados abaixo estiver inativo.
oStrGIC:SetProperty('GIC_LINHA'	 , MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty('GIC_COLAB'	 , MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty('GIC_LOCORI' , MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty('GIC_LOCDES' , MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty('GIC_CODGID' , MODEL_FIELD_VALID, bFldVal)
oStrGIC:SetProperty('GIC_CODSRV' , MODEL_FIELD_VALID, bFldVal)

oStrGIC:SetProperty( 'GIC_AGENCI', MODEL_FIELD_WHEN, bFldWhen)
oStrGIC:SetProperty( 'GIC_TIPDOC', MODEL_FIELD_WHEN, bFldWhen)
oStrGIC:SetProperty( 'GIC_SERIE' , MODEL_FIELD_WHEN, bFldWhen)
oStrGIC:SetProperty( 'GIC_SUBSER', MODEL_FIELD_WHEN, bFldWhen)
oStrGIC:SetProperty( 'GIC_NUMCOM', MODEL_FIELD_WHEN, bFldWhen)
oStrGIC:SetProperty( 'GIC_NUMDOC', MODEL_FIELD_WHEN, bFldWhen)

oStrGIC:SetProperty("GIC_ORIGEM" , MODEL_FIELD_INIT, {|| "1" })
oStrGIC:SetProperty("GIC_CODIGO" , MODEL_FIELD_INIT, {|| GTPXENUM('GIC','GIC_CODIGO',1) })
oStrGIC:SetProperty("GIC_TIPO"   , MODEL_FIELD_INIT, {|| "E" })

If !(GtpIsInPoui())
	oStrGIC:aTriggers:= {}
EndIf

oStrGIC:AddTrigger("GIC_TIPDOC"	, "GIC_TIPDOC"	,{ || .T. }, bFldTrig)
oStrGIC:AddTrigger("GIC_AGENCI"	, "GIC_AGENCI"	,{ || .T. }, bFldTrig)
oStrGIC:AddTrigger("GIC_SERIE"	, "GIC_SERIE"	,{ || .T. }, bFldTrig)
oStrGIC:AddTrigger("GIC_TIPO"	, "GIC_TIPO"	,{ || .T. }, bFldTrig)
oStrGIC:AddTrigger("GIC_LOCORI"	, "GIC_LOCORI"	,{ || .T. }, bFldTrig)
oStrGIC:AddTrigger("GIC_LOCDES"	, "GIC_LOCDES"	,{ || .T. }, bFldTrig)
oStrGIC:AddTrigger("GIC_DTVEND"	, "GIC_DTVEND"	,{ || .T. }, bFldTrig)
oStrGIC:AddTrigger("GIC_CODG9B"	, "GIC_DSCG9B"	,{ || .T. }, bFldTrig)

aTrigAux := FwStruTrigger("GIC_NUMDOC", "GIC_BILHET", "FWFldGet('GIC_NUMDOC')")
oStrGIC:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	

aTrigAux := FwStruTrigger("GZP_FPAGTO", "GZP_DCART", "Posicione('SAE',1,xFilial('SAE')+M->GZP_FPAGTO,'AE_DESC')")
oStrGZP:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
aTrigAux := FwStruTrigger("GZP_DCART", "GZP_FPAGTO","GetAdmCart()",NIL,NIL,NIL,NIL,"FwIsInCallStack('GTPI115') .OR. FwIsInCallStack('GI115Job') .OR. FwIsInCallStack('GTPIRJ115')")
oStrGZP:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	

If FwIsInCallStack('GTPJ001') .OR. FwIsInCallStack('GTPIRJ115') .OR. FwIsInCallStack('GI115Job') .OR. FwIsInCallStack('GI115Receb')
	If FwIsInCallStack('GTPIRJ115') .OR. FwIsInCallStack('GI115Job') .OR. FwIsInCallStack('GI115Receb')
		oStrGIC:SetProperty('*', MODEL_FIELD_VALID, {||.T.})
	EndIf
	oStrGIC:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStrGIC:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
Endif

Return 

/*/{Protheus.doc} FieldVal
(long_description)
@type  Static Function
@author user
@since 19/02/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldVal(oMdl,cField,uNewValue,uOldValue)
Local lRet     := .T.
Local oModel   := oMdl:GetModel()
Local aAreaGYA := {}
Local aSeek    := {}
LOCAL aResult  := {}
If !FWISINCALLSTACK("GTPIRJ115") .AND. !FwIsInCallStack('GI115Job') .AND. !FwIsInCallStack('GI115Receb')
	Do Case
		Case Empty(uNewValue)
			lRet := .T.
		Case cField == "GIC_DTVEND"
			IF (uNewValue > dDatabase)
				oModel:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"VldDVend",STR0010, STR0011) //"Data da venda não pode ser maior que a data atual","Informe uma data válida"
				lRet := .F.	
			ENDIF	
		
		Case cField == "GIC_BILREF"
			If !(EMPTY(uNewValue)) .AND. !GIC->(DbSeek(xFilial('GIC')+uNewValue)) 
				oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"VldBilRef",STR0012, STR0013,uNewValue,uOldValue)//"Não existe registro relacionado a este código." ##"Informe um código que exista no cadastro"
				lRet := .F.
			ElseIf oMdl:GetValue('GIC_CODIGO') == uNewValue
				oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"VldBilRef",STR0014, STR0013,uNewValue,uOldValue) //"Bilhete referenciado não pode possuír o mesmo código desse registro"##"Informe um código que exista no cadastro"
				lRet := .F.
			EndIf
		Case cField == "GIC_TIPDOC"
			aAreaGYA := GYA->(GetArea())
			dbSelectArea("GYA")
			GYA->(dbSetOrder(1))
			
			If !GYA->(DbSeek(xFilial("GYA")+uNewValue))

				oModel:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"VldCtrlDoc",STR0039,"") // "Tipo de Documento inexistente", "" 
				lRet := .F.
			
			Endif
		
			RestArea(aAreaGYA)
		Case cField == "GIC_AGENCI"
			
			lRet := ValidUserAg(oMdl,cField,uNewValue,uOldValue)
			
		Case cField == "GIC_TIPO"
			If oMdl:GetOperation() == MODEL_OPERATION_INSERT .and. !FwIsInCallStack('GTPA115C') .and. !FwIsInCallStack('GTPI115')
				If !(uNewValue $ 'E/M')
					oMdl:GetModel():SetErrorMessage(oMdl:GetId(), cField, oMdl:GetId(), cField, 'GTPA115VLD', STR0041, STR0042) //"Não é possivel informar esse tipo de Bilhete numa inclusão manual", "Selecione outro tipo"
					lRet := .F.
				Endif
			EndIf
		Case cField == 'GIC_ECF'
			If !Empty(oMdl:GetValue('GIC_AGENCI'))
				aResult := {{"GI6_FILRES"}}
				If oMdl:GetOperation() == MODEL_OPERATION_INSERT .and. !FwIsInCallStack('GTPA115C') .and. !FwIsInCallStack('GTPI115')
					aAdd(aSeek, {"GI6_CODIGO",oMdl:GetValue('GIC_AGENCI')})
		
					If ( GTPSeekTable("GI6",aSeek,aResult) )
						If Empty(aResult[2,1]) 
							oMdl:GetModel():SetErrorMessage(oMdl:GetId(), cField, oMdl:GetId(), cField, 'GTPA115VLD', STR0043)//"Filial responsável não localizada."
							lRet := .F.
						Else
							aSeek := {}
							aAdd(aSeek, {"LG_FILIAL",aResult[2,1]})
							aAdd(aSeek, {"LG_CODIGO",oMdl:GetValue('GIC_ECF')})
							aResult := {{"LG_CODIGO"}}
							If !GTPSeekTable("SLG",aSeek,aResult)
								oMdl:GetModel():SetErrorMessage(oMdl:GetId(), cField, oMdl:GetId(), cField, 'GTPA115VLD', STR0045 + oMdl:GetValue('GIC_ECF') + STR0044)//"O ECF " + oMdl:GetValue('GIC_ECF') + " não está cadastrado"
								lRet := .F.						
							Endif						
						EndIf
					EndIf
									
				Endif	
			Else
				oModel:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"VldDVend",'GTPA115VLD', STR0049)//"Agência não informada!"	
				lRet := .F.		
			Endif
		Case cField == 'GIC_LINHA'
			lRet := GTPExistCpo('GI2',uNewValue+'2',4,.F.)
		Case cField == 'GIC_COLAB'
			lRet := GTPExistCpo('GYG',uNewValue,1,.F.)
		Case cField == 'GIC_LOCORI'
			lRet := GTPExistCpo('GI1',uNewValue,1,.F.)
		Case cField == 'GIC_LOCDES'
			lRet := GTPExistCpo('GI1',uNewValue,1,.F.)
		Case cField == 'GIC_CODGID'
			lRet := GTPExistCpo('GID',uNewValue+'2',4,.F.)
		Case cField == 'GIC_CODSRV'
			lRet := GTPExistCpo('GYN',uNewValue,1,.F.)

	EndCase
EndIf
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetAdmCart()
 Função utilizada nas integrações EAI e JSon da rjintegra
@sample	GetAdmCart()
 
@param		
 
@return	
 
@author	Fernando Amorim(Cafu)
@since		18/01/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GetAdmCart()
Local oModel		:= FwModelActive()
Local oGridModel	:= oModel:GetModel('GZPPAGTO')
Local cValorCp		:= alltrim(oGridModel:GetValue("GZP_DCART"))
Local cRet			:= ''
Local cAlias		:= GetNextAlias()
Local aCab			:= {}

Private lMsErroAuto := .F.


BeginSQL Alias cAlias

	SELECT
		AE_COD		
	FROM
		%Table:SAE% SAE
	WHERE
		AE_FILIAL = %XFilial:SAE%
		AND SAE.%NotDel%
		AND UPPER(RTRIM(AE_DESC)) = %Exp: UPPER(RTRIM(cValorCp)) %
			
EndSQL

If (cAlias)->(!Eof())

	cRet := (cAlias)->AE_COD
	
Endif

(cAlias)->(DbCloseArea())

//verificar de gerar o sem administradora via execauto
If Empty(cRet)
	If SAE->(DbSeek(xFilial("SAE")+ '999'))
		cRet	:= '999' // cadastro na administradora para sem bandeira 
	Else
		
		aCab := {}
		aCab := {	{ "AE_COD"	, '999'							, Nil },;  
			{ "AE_DESC"			, 'BANDEIRA NAO IDENTIFICADA'   , Nil },; 
	 		{ "AE_TIPO"			, 'CD'				    		, Nil },; 
	 		{ "AE_FINPRO"		, 'S'				    		, Nil }}
	 	
		MsExecAuto({|a,b,c| LojA070(a,b,c)},aCab,Nil,3)

		If !lMsErroAuto
			cRet	:= '999'
		Endif
	Endif
Endif
	
Return cRet

/*/{Protheus.doc} FieldWhen
	(long_description)
	@type  Static Function
	@author user
	@since 19/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function FieldWhen(oMdl,cField,uVal)

Local oModel	:= oMdl:GetModel()
Local nOpc		:= oModel:GetOperation()
Local lRet      := .T.

Do Case
	Case cField == "GIC_AGENCI"
        lRet := nOpc == MODEL_OPERATION_INSERT .AND. oMdl:GetValue("GIC_TIPO") $ "E|M"
    Case cField == "GIC_TIPDOC"
        lRet := nOpc == MODEL_OPERATION_INSERT .AND. oMdl:GetValue("GIC_TIPO") $ "E|M"
    Case cField == "GIC_SERIE"
        lRet := nOpc == MODEL_OPERATION_INSERT .AND. oMdl:GetValue("GIC_TIPO") $ "E|M"
	Case cField == "GIC_SUBSER"
        lRet := nOpc == MODEL_OPERATION_INSERT .AND. oMdl:GetValue("GIC_TIPO") $ "E|M"
	Case cField == "GIC_NUMCOM"
        lRet := nOpc == MODEL_OPERATION_INSERT .AND. oMdl:GetValue("GIC_TIPO") $ "E|M"
	Case cField == "GIC_NUMDOC"
        lRet := nOpc == MODEL_OPERATION_INSERT .AND. oMdl:GetValue("GIC_TIPO") $ "E|M"

EndCase

Return lRet

/*/{Protheus.doc} FieldTrigger
	(long_description)
	@type  Static Function
	@author user
	@since 19/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function FieldTrigger(oMdl,cField,uVal)

Local cNextAlias	:= GetNextAlias()
Local nP			:= 0
Local aTabValues	:= {}	
Local lUpdTarTab 	:= .f.
Local lNoInt		:= .f.

Do Case
    Case cField == "GIC_TIPDOC"
		If GtpIsInPoui()
			oMdl:ClearField('GIC_SERIE')
			oMdl:ClearField('GIC_SUBSER')
			oMdl:ClearField('GIC_NUMCOM')
			oMdl:ClearField('GIC_NUMDOC')
		EndIf
    Case cField == "GIC_AGENCI"
		If GtpIsInPoui()
			oMdl:ClearField('GIC_TIPDOC')
			oMdl:ClearField('GIC_SERIE')
			oMdl:ClearField('GIC_SUBSER')
			oMdl:ClearField('GIC_NUMCOM')
			oMdl:ClearField('GIC_NUMDOC')
		EndIf
    Case cField == "GIC_SERIE" .OR. cField == "GIC_TIPO"
		If GtpIsInPoui()
			oMdl:ClearField('GIC_SUBSER')
			oMdl:ClearField('GIC_NUMCOM')
			oMdl:ClearField('GIC_NUMDOC')
			If uVal ==  'I'
				oMdl:ClearField('GIC_TIPDOC')
				oMdl:ClearField('GIC_SERIE')
			Endif
		EndiF
	Case cField == "GIC_LOCORI"
		BeginSql  Alias cNextAlias
			
			SELECT 
				GIE_HORLOC
			FROM 
				%Table:GIE% GIE
			WHERE
				GIE.GIE_FILIAL	= %xFilial:GIE% 
				AND GIE.GIE_CODGID	= %Exp:oMdl:GetValue('GIC_CODGID') % 
				AND GIE.GIE_IDLOCP 	= %Exp:oMdl:GetValue('GIC_LOCORI') %
				AND GIE.GIE_HIST 	= '2'
				AND GIE.%NotDel%
		EndSql 
		
		If (cNextAlias)->(!EOF())
			oMdl:SetValue('GIC_HORA',(cNextAlias)->GIE_HORLOC )
		Else
			oMdl:SetValue('GIC_HORA','0000')
		Endif

		(cNextAlias)->(DbCloseArea())

		lUpdTarTab := !Empty(oMdl:GetValue('GIC_LOCDES')) .And. !Empty(oMdl:GetValue('GIC_DTVEND'))
	Case cField == "GIC_LOCDES"
		lUpdTarTab := !Empty(oMdl:GetValue('GIC_LOCORI')) .And. !Empty(oMdl:GetValue('GIC_DTVEND'))
	Case cfIELD == "GIC_DTVEND"
		lUpdTarTab := !Empty(oMdl:GetValue('GIC_LOCORI')) .And. !Empty(oMdl:GetValue('GIC_LOCDES'))
EndCase

If ( lUpdTarTab .And. cField $ "GIC_LOCORI|GIC_LOCDES|GIC_DTVEND" )
	
	aTabValues := GA115GetValueTab(oMdl)
	
	lNoInt		:= FwIsInCallStack("GTPA115") .and. !FwIsInCallStack("GTPA115C") 
	
	For nP := 1 to Len(aTabValues)
	
		If ( aTabValues[nP,1] == "1" )
			
			oMdl:SetValue("GIC_TARTAB",aTabValues[nP,2])
			
			If ( lNoInt )
				oMdl:SetValue("GIC_TAR",aTabValues[nP,2])
			EndIf
		
		ElseIf ( aTabValues[nP,1] == "2" )
			
			oMdl:SetValue("GIC_PEDTAB",aTabValues[nP,2])
			
			If ( lNoInt )
				oMdl:SetValue("GIC_PED",aTabValues[nP,2])
			EndIf
				
		ElseIf ( aTabValues[nP,1] == "3" )
		
			oMdl:SetValue("GIC_TAXTAB",aTabValues[nP,2])
			
			If ( lNoInt )
				oMdl:SetValue("GIC_TAX",aTabValues[nP,2])
			EndIf
			
		ElseIf ( aTabValues[nP,1] == "4" )
		
			oMdl:SetValue("GIC_SGTAB",aTabValues[nP,2])
			
			If ( lNoInt )
				oMdl:SetValue("GIC_SGFACU",aTabValues[nP,2])
			EndIf
			
		EndIf
		
	Next nP
	
EndIf

Return uVal
/*/{Protheus.doc} ViewDef
    Função que define a View para o cadastro de Configuração DARUMA da Agência
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
Local oView		 := nil
Local oModel	 := FwLoadModel("GTPA115")
Local oStrGIC	 := FWFormStruct( 2, "GIC",,.F. )	//Bilhetes
Local oStrGZP	 := FWFormStruct( 2, "GZP",,.F. )	//Bilhetes

SetViewStruct(oStrGIC,oStrGZP)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_GIC", oStrGIC, "GICMASTER" )
oView:AddGrid("VIEW_GZP",oStrGZP,"GZPPAGTO")

oView:AddIncrementField('VIEW_GZP','GZP_ITEM')

oView:GetModel('GZPPAGTO'):SetNoInsertLine(.T.)
oView:GetModel('GZPPAGTO'):SetNoUpdateLine(.T.)
oView:GetModel('GZPPAGTO'):SetNoDeleteLine(.T.)

// Divisão Horizontal
oView:CreateHorizontalBox( 'SUPERIOR'  	, 60)
oView:CreateHorizontalBox( 'INFERIOR'	, 40)
oView:SetOwnerView("VIEW_GIC", "SUPERIOR")
oView:SetOwnerView("VIEW_GZP", "INFERIOR")
oView:EnableTitleView('VIEW_GZP','Pagto Cartão') //

Return(oView)

/*/{Protheus.doc} SetViewStruct
(long_description)
@type  Static Function
@author user
@since 20/02/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStrGIC,oStrGZP)
Local oModel	 := FwLoadModel("GTPA115")
Local aFieldsGIC := aClone(oStrGIC:GetFields())
Local cFldGIC    := ""
Local nx         := 0

//Tira obrigatoriedade de alguns Campos
//oStrGIC:SetProperty("GIC_SERIE",MODEL_FIELD_OBRIGAT,.F.)
oStrGIC:SetProperty("GIC_DTREM",MODEL_FIELD_OBRIGAT,.F.)
oStrGIC:SetProperty("GIC_NFORMU",MODEL_FIELD_OBRIGAT,.F.)
oStrGIC:SetProperty("GIC_CANCEL",MODEL_FIELD_OBRIGAT,.F.)
oStrGIC:SetProperty("GIC_TPVEND",MODEL_FIELD_OBRIGAT,.F.)

oModel:GetModel('GICMASTER'):GetStruct():SetProperty('GIC_TIPO',MODEL_FIELD_INIT,{||'E'})

If FwIsInCallStack('GTPJ001') 
	oStrGIC:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStrGIC:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
Endif

//Remove Campos desnecessários
cFldGIC := "GIC_FILIAL|GIC_SECORI|GIC_SECDES|GIC_TITPAG|GIC_TPVEND|GIC_CATEG|GIC_CODLOC|GIC_DESCLO|GIC_DTREM|GIC_NFORMU|GIC_QTXEMB|GIC_TITCAM|GIC_TOTGER|GIC_TOTSEG|GIC_TTXEM|GIC_PAGTXE|"
cFldGIC += "GIC_ITECOM|GIC_CANCEL|GIC_ABERTO|GIC_DOC|GIC_SDOCNF|GIC_SERNFS|GIC_DTMOVI|GIC_HRREAL|GIC_NCOMPL|GIC_LOTE|GIC_ITEM|GIC_CARGA|GIC_TITCAN|GIC_CODGQ6|GIC_PERCOM|GIC_PERIMP|"
cFldGIC += "GIC_VALCOM|GIC_VALIMP|GIC_NOTA|GIC_CLIENT|GIC_LOJA|GIC_STAPRO|GIC_FILNF|GIC_SERINF|GIC_DTINCL|GIC_DTALTE"

For nX := 1 to Len(aFieldsGIC)
	If AllTrim(aFieldsGIC[nX][1])+"|" $ cFldGIC 
		oStrGIC:RemoveField(aFieldsGIC[nX][1])   	
	Endif
Next
// Forma de pagamento Cartão
oStrGZP:RemoveField("GZP_FILIAL")
oStrGZP:RemoveField("GZP_CODIGO")
oStrGZP:RemoveField("GZP_CODBIL")
oStrGZP:RemoveField("GZP_DTVEND")

oStrGIC:AddGroup('GRP001', 'Dados do Bilhetes','', 2)
oStrGIC:AddGroup('GRP002', STR0006,'', 2) // Taxas e Tarifas
oStrGIC:AddGroup('GRP003', STR0018,'', 2) // Controle De Documento

oStrGIC:SetProperty( 'GIC_CODIGO', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_TIPO'  , MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_AGENCI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_DESAGE', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_BILHET', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_LINHA' , MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_NLINHA', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_SENTID', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_CODGID', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_CODSRV', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_LOCORI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_NLOCOR', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_LOCDES', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_NLOCDE', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_DTVIAG', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_HORA'  , MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_BILREF', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStrGIC:SetProperty( 'GIC_DTVEND', MVC_VIEW_GROUP_NUMBER, 'GRP001')

oStrGIC:SetProperty( 'GIC_TAR'   , MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_TARTAB', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_TAX'   , MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_TAXTAB', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_PED'   , MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_PEDTAB', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_SGFACU', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_SGTAB' , MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_OUTTOT', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStrGIC:SetProperty( 'GIC_VALTOT', MVC_VIEW_GROUP_NUMBER, 'GRP002')

oStrGIC:SetProperty( 'GIC_TIPDOC', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStrGIC:SetProperty( 'GIC_SERIE' , MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStrGIC:SetProperty( 'GIC_SUBSER', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStrGIC:SetProperty( 'GIC_NUMCOM', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStrGIC:SetProperty( 'GIC_NUMDOC', MVC_VIEW_GROUP_NUMBER, 'GRP003')

oStrGIC:SetProperty( 'GIC_NUMFCH', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_VLACER', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_TARTAB', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_TAXTAB', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_PEDTAB', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_SGTAB' , MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_VALTOT', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_CONFER', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_DTCONF', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_MOTREJ', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_SUBSER', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( 'GIC_NUMCOM', MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( "GIC_ORIGEM", MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( "GIC_CODIGO", MVC_VIEW_CANCHANGE, .F.)
oStrGIC:SetProperty( "GIC_STATUS", MVC_VIEW_CANCHANGE, .F.)

// Dados do Bilhetes
oStrGIC:SetProperty( 'GIC_CODIGO', MVC_VIEW_ORDEM, '02')
oStrGIC:SetProperty( 'GIC_BILHET', MVC_VIEW_ORDEM, '03')
oStrGIC:SetProperty( 'GIC_TIPO'  , MVC_VIEW_ORDEM, '04')
oStrGIC:SetProperty( 'GIC_LINHA' , MVC_VIEW_ORDEM, '05')
oStrGIC:SetProperty( 'GIC_NLINHA', MVC_VIEW_ORDEM, '06')
oStrGIC:SetProperty( 'GIC_SENTID', MVC_VIEW_ORDEM, '07')
oStrGIC:SetProperty( 'GIC_CODGID', MVC_VIEW_ORDEM, '08')
oStrGIC:SetProperty( 'GIC_CODSRV', MVC_VIEW_ORDEM, '09')
oStrGIC:SetProperty( 'GIC_LOCORI', MVC_VIEW_ORDEM, '10')
oStrGIC:SetProperty( 'GIC_NLOCOR', MVC_VIEW_ORDEM, '11')
oStrGIC:SetProperty( 'GIC_LOCDES', MVC_VIEW_ORDEM, '12')
oStrGIC:SetProperty( 'GIC_NLOCDE', MVC_VIEW_ORDEM, '13')
oStrGIC:SetProperty( 'GIC_DTVIAG', MVC_VIEW_ORDEM, '14')
oStrGIC:SetProperty( 'GIC_HORA'  , MVC_VIEW_ORDEM, '15')
oStrGIC:SetProperty( 'GIC_AGENCI', MVC_VIEW_ORDEM, '26')
oStrGIC:SetProperty( 'GIC_DESAGE', MVC_VIEW_ORDEM, '27')
oStrGIC:SetProperty( 'GIC_DTVEND', MVC_VIEW_ORDEM, '31')
oStrGIC:SetProperty( 'GIC_BILREF', MVC_VIEW_ORDEM, '39')

// Taxas e Tarifas
oStrGIC:SetProperty( 'GIC_TAR'   , MVC_VIEW_ORDEM, '16')
oStrGIC:SetProperty( 'GIC_TARTAB', MVC_VIEW_ORDEM, '17')
oStrGIC:SetProperty( 'GIC_TAX'   , MVC_VIEW_ORDEM, '18')
oStrGIC:SetProperty( 'GIC_TAXTAB', MVC_VIEW_ORDEM, '19')
oStrGIC:SetProperty( 'GIC_PED'   , MVC_VIEW_ORDEM, '20')
oStrGIC:SetProperty( 'GIC_PEDTAB', MVC_VIEW_ORDEM, '21')
oStrGIC:SetProperty( 'GIC_SGFACU', MVC_VIEW_ORDEM, '22')
oStrGIC:SetProperty( 'GIC_SGTAB' , MVC_VIEW_ORDEM, '23')
oStrGIC:SetProperty( 'GIC_OUTTOT', MVC_VIEW_ORDEM, '24')
oStrGIC:SetProperty( 'GIC_VALTOT', MVC_VIEW_ORDEM, '25')

// Controle De Documento
oStrGIC:SetProperty( 'GIC_TIPDOC', MVC_VIEW_ORDEM, '42')
oStrGIC:SetProperty( 'GIC_SERIE' , MVC_VIEW_ORDEM, '43')
oStrGIC:SetProperty( 'GIC_SUBSER', MVC_VIEW_ORDEM, '44')
oStrGIC:SetProperty( 'GIC_NUMCOM', MVC_VIEW_ORDEM, '45')
oStrGIC:SetProperty( 'GIC_NUMDOC', MVC_VIEW_ORDEM, '46')

Return 

/*/{Protheus.doc} MenuDef
    Função responsável pela montagem de aRotina - opções do menu do browse
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 27/03/2017
    @version 1
    @param 
    @return aRotina, array, Array com as opções de Menu
    @example
    aRotina := MenuDef()
    @see (links_or_references)
/*/
Static Function MenuDef()

Local aRotina := {}

    ADD OPTION aRotina Title STR0002 Action "VIEWDEF.GTPA115"	OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina Title STR0003 Action "VIEWDEF.GTPA115"	OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina Title STR0004 Action "VIEWDEF.GTPA115"	OPERATION 4 ACCESS 0 // "Alterar" 
    ADD OPTION aRotina Title STR0005 Action "VIEWDEF.GTPA115"	OPERATION 5 ACCESS 0 // "Excluir"
    ADD OPTION aRotina Title STR0017 Action "VIEWDEF.GTPA115A"	OPERATION 5 ACCESS 0 // "Excluir Massa de Bilhetes"
    ADD OPTION aRotina Title STR0015 Action "VIEWDEF.GTPA115A"	OPERATION 3 ACCESS 0 // "Gerar Massa de Bilhetes"
    ADD OPTION aRotina Title STR0023 Action "VIEWDEF.GTPA115C"	OPERATION 9 ACCESS 0 // 'Cancelamento'
    ADD OPTION aRotina Title STR0024 Action "VIEWDEF.GTPA115D"  OPERATION 9 ACCESS 0 // 'Devolução'
    ADD OPTION aRotina Title STR0025 Action "GTPA115I()"        OPERATION 3 ACCESS 0 // 'Inutilização'

Return(aRotina)

/*/{Protheus.doc} MenuDef
    Função que valida se o bilhete pode ser excluído
    @type  Static Function
    @author Flavio Martins
    @since 07/08/2017
    @version 1
    @param 
    @return nil
    @example
    @see (links_or_references)
/*/
Function GA115Del(oModel)
Local lRet          := .T.

If FwIsInCallStack('GTPA115') .AND. ( oModel:GetOperation() == MODEL_OPERATION_DELETE .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE )

    If !Empty(GIC->GIC_NUMFCH) .or. !Empty(GIC->GIC_CODREQ)  
        oModel:SetErrorMessage(oModel:GetId(), , oModel:GetId(), , "GA115Del", STR0007)
        lRet := .F.
    Endif
    If lRet .and. GIC->GIC_ORIGEM == '2' //Origem automatica 
    	oModel:SetErrorMessage(oModel:GetId(), , oModel:GetId(), , "GA115Del", STR0026)
        lRet := .F.
    Endif
    If lRet .and. !Empty(GIC->GIC_CODGY3) //DAPE
    	oModel:SetErrorMessage(oModel:GetId(), , oModel:GetId(), , "GA115Del", STR0027)
        lRet := .F.
    Endif
    
Endif

Return lRet    

/*/{Protheus.doc} GA115VldCtr(cTipoDoc, cSerie, cSubSerie, cCompl, cNumero)
Valida a numeração do controle de documentos
@author 	Flavio Martins	
@sample	GA115VldCtr(cTipoDoc, cSerie, cSubSerie, cCompl, cNumero)
@return	lLogico 	Retorna um valor lógico
@since		10/10/2017
@version	P12
/*/
Function GA115VldCtr(cAgencia,cTipoDoc, cSerie, cSubSerie, cCompl, cNumero, dDtEmiss)
Local lRet 		    := .T.
Local cAliasGII	    := GetNextAlias() 

Default dDtEmiss    := dDataBase

	BeginSQL Alias cAliasGII 
        
        COLUMN GII_DTINI as Date
        COLUMN GII_DTFIM as Date

		SELECT
			GII_UTILIZ,
			GII_DTINI,
			GII_DTFIM
		FROM %Table:GII% GII	
		WHERE 
			GII_FILIAL	= %xFilial:GII%
			AND GII_AGENCI 	= %Exp:cAgencia%
			AND GII_TIPO 	= %Exp:cTipoDoc%
			AND GII_SERIE 	= %Exp:cSerie%
			AND GII_SUBSER	= %Exp:cSubSerie%
			AND GII_NUMCOM	= %Exp:cCompl%
			AND GII_BILHET	= %Exp:cNumero%
			AND GII.%NotDel%			

	EndSQL
		
	If (cAliasGII)->(Eof())	
		lRet := .F.
		Help( ,, 'Help',"GTPA115",STR0019, 1, 0 ) // "Número de Documento não encontrado"
	EndIf
	
	If lRet .And. ((cAliasGII)->GII_UTILIZ) == "T"
		lRet := .F.
		Help( ,, 'Help',"GTPA115",STR0020, 1, 0 ) // "Status do número não permite sua utilização"
	EndIf
	
	If lRet .And. !EMPTY((cAliasGII)->GII_DTINI) .AND. !EMPTY((cAliasGII)->GII_DTFIM)
		If !( (cAliasGII)->GII_DTINI <= dDtEmiss .AND. (cAliasGII)->GII_DTFIM >= dDtEmiss )
			Help( ,, 'Help',"GTPA115",STR0048, 1, 0 )//"Esse documento não se encontra dentro da validade"
			lRet := .F.
		Endif
	EndIf

	(cAliasGII)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} GA115AtuCtr(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumero, cUtil)
Atualiza o status no controle de documentos
@author 	Flavio Martins	
@sample	
@return	lLogico 	Retorna um valor lógico
@since		20/10/2017
@version	P12
/*/
Function GA115AtuCtr(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumero, lUtil, cAliasTab, cChave)
Local aArea		:= GetArea()
Local aAreaGII	:= GII->(GetArea())
Local lRet			:= .T.
Local oMasterGII	:= Nil
Local oMod102B	:= Nil
	
	DbSelectArea('GII')
	GII->(dbSetOrder(4)) //"GII_FILIAL+GII_AGENCI+GII_TIPO+GII_SERIE+GII_SUBSER+GII_NUMCOM+GII_BILHET"
	If !FWISINCALLSTACK("GTPIRJ115") .AND. !FwIsInCallStack('GI115Job') .AND. !FwIsInCallStack('GI115Receb')
		If GII->(DbSeek(xFilial('GII')+cAgencia+cTipoDoc+cSerie+cSubSerie+cCompl+cNumero)) 

			oMod102B := FWLoadModel('GTPA102B')
		
			oMod102B:SetOperation( MODEL_OPERATION_UPDATE )

			oMod102B:Activate()
		
			oMasterGII:= oMod102B:GetModel('GIIMASTER')

			oMasterGII:LoadValue('GII_UTILIZ', lUtil)
			
			If lUtil
				oMasterGII:LoadValue('GII_ALIAS',  cAliasTab)
				oMasterGII:LoadValue('GII_CHVTAB', cChave)
			Else
				oMasterGII:ClearField('GII_ALIAS')
				oMasterGII:ClearField('GII_CHVTAB')
			Endif
			
			If oMod102B:VldData()
				lRet := FwFormCommit(oMod102B)
				oMod102B:DeActivate()
				oMod102B:Destroy()
			Else
				JurShowErro( oMod102B:GetModel():GetErrormessage() )
				oMod102B:DeActivate()
			Endif
		
		Else
			Help( ,, 'Help',"GTPA115A",STR0028, 1, 0 ) // "Controle de Documentos não encontrado"
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaGII)
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} GA115PosVld(oModel)
Pós-Validação do  modelo
@author 	Flavio Martins	
@sample	
@return	lLogico 	Retorna um valor lógico
@since		27/10/2017
@version	P12
/*/

Static Function GA115PosVld(oModel)
Local lRet 		:= .T.
Local oMdlGIC   := oModel:GetModel('GICMASTER')
Local cAgencia 	:= oMdlGIC:GetValue('GIC_AGENCI')
Local cTipoDoc 	:= oMdlGIC:GetValue('GIC_TIPDOC')
Local cSerie	:= oMdlGIC:GetValue('GIC_SERIE')
Local cSubSerie	:= oMdlGIC:GetValue('GIC_SUBSER')
Local cCompl   	:= oMdlGIC:GetValue('GIC_NUMCOM')
Local cNumero  	:= oMdlGIC:GetValue('GIC_NUMDOC')
Local nVlTot	:= oMdlGIC:GetValue('GIC_VALTOT')
Local cColab	:= oMdlGIC:GetValue('GIC_COLAB')
Local dDtEmiss  := oMdlGIC:GetValue('GIC_DTVEND')
Local oMdlGZP	:= oModel:GetModel('GZPPAGTO')
Local nVLCTOT	:= 0
Local nI		:= 0
Local cMsgProb	:= ""
Local cMsgSolu	:= ""
Local cTitulo	:= ""

If oModel:GetOperation() == MODEL_OPERATION_INSERT  
	lRet := oMdlGIC:SetValue("GIC_DTINCL",FWTimeStamp(2))//dd/mm/aaaa-hh:mm:ss
ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
	lRet := oMdlGIC:SetValue("GIC_DTALTE",FWTimeStamp(2))//dd/mm/aaaa-hh:mm:ss
Endif

If ( lRet )

	If ( oMdlGIC:GetValue("GIC_ORIGEM") == "1" .And. oMdlGIC:GetValue("GIC_TIPO") $ "E|M" )
		If !FWISINCALLSTACK("GTPIRJ115") .AND. !FwIsInCallStack('GI115Job') .AND. !FwIsInCallStack('GI115Receb')
			If ( Empty(cTipoDoc) .And. Empty(cSerie) .And. Empty(cNumero) )
				
				cMsgProb	:= STR0029 //"Preenchimento obrigatório dos campos de Controle de Documento"
				cMsgSolu	:= STR0030 //"Quando a Origem for Manual e o Tipo de Bilhete for: ou Embarcado ou Manual; " 
				cMsgSolu	+= STR0031 //"é necessário preencher as informações do Controle de Documentos."	
				cTitulo		:= STR0032 //"Documento Obrigatório" 
				
				FWAlertHelp(cMsgProb,cMsgSolu,cTitulo)
				
				lRet := .f.	
			ElseIf Empty(cColab)
				cMsgProb	:= STR0033 //"Preenchimento obrigatório do colaborador que emitiu a passagem"
				cMsgSolu	:= STR0030 //"Quando a Origem for Manual e o Tipo de Bilhete for: ou Embarcado ou Manual; " 
				cMsgSolu	+= STR0034 //"é necessário preencher as informações do Colaborador."	
				cTitulo		:= STR0035 //"Colaborador Obrigatório" 
				
				FWAlertHelp(cMsgProb,cMsgSolu,cTitulo)
				
				lRet := .f.	
			ElseIf oModel:GetOperation() == MODEL_OPERATION_INSERT;
				.AND. !(oMdlGIC:GetValue('GIC_STATUS') $ "C/D/I");
				.AND. !GA115VldCtr(cAgencia,cTipoDoc, cSerie, cSubSerie, cCompl, cNumero,dDtEmiss)
				lRet := .F.

			EndIf
		EndIf
	EndIf
		
EndIf

If lRet
	If 	oMdlGZP:Length() >= 1 .AND. oMdlGZP:GetValue("GZP_VALOR",1) > 0 
		nVLCTOT := 0
		For nI := 1 to oMdlGZP:Length()		
			oMdlGZP:GoLine(nI)
			If !oMdlGZP:IsDeleted()
				nVLCTOT += oMdlGZP:GetValue("GZP_VALOR")
			Endif
		Next nI
		If nVLCTOT > nVlTot
			cMsgProb	:= STR0036 //"O Valor do pagamento em cartão é maior que o valor da compra do bilhete"
			cMsgSolu	:= STR0037 //"Corrija o valor do pagamento pelo cartão.  " 
			cTitulo		:= STR0038 //"Valor incorreto" 
			oMdlGZP:GetModel():SetErrorMessage(oMdlGZP:GetId(),"GZP_VALOR",oMdlGZP:GetId(),"GZP_VALOR",cTitulo,cMsgProb,cMsgSolu) 
		Endif
	Else
		lRet := .T.
	Endif
Endif
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
			cVersão - Versão da mensagem
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXml, nTypeTrans, cTypeMessage,cVersao )
Return GTPI115( cXml, nTypeTrans, cTypeMessage,cVersao )

/*/{Protheus.doc} GA115Valid(oModel)

@author 	GTP	
@sample	
@return	lLogico 	Retorna um valor lógico
@since		27/10/2017
@version	P12
/*/
Static Function GA115Valid(oSubMdl,cAction,cField,xValue)

Local lRet	:= .t.
If !FWISINCALLSTACK("GTPIRJ115") .AND. !FwIsInCallStack('GI115Job') .AND. !FwIsInCallStack('GI115Receb')
	If ( cAction == "CANSETVALUE" )

		If ( cField == "GIC_BILHET" )
			//Não se permite a digitação do campo Num.Bilhete se a origem é manual e os Tipos forem ou embarcada ou manual
			lRet := !(oSubMdl:GetValue("GIC_ORIGEM") == "1" .And. oSubMdl:GetValue("GIC_TIPO") $ "E|M") 	
		EndIf

	ElseIf ( cAction == "SETVALUE" )
		
		If ( cField $ "GIC_TIPO" )
		
			oSubMdl:ClearField('GIC_BILHET')

		EndIf
	EndIf
EndIf
Return(lRet)

/*/{Protheus.doc} GA115GetValueTab()

@author 	GTP	
@sample	
@return	lLogico 	Retorna um valor lógico
@since		27/10/2017
@version	P12
/*/
Static Function GA115GetValueTab(oMdl)

Local aResultSet	:= {{"G5G_TPREAJ","G5G_VALOR"}}
Local aSeek		:= {}
Local aResultado	:= {}

Local cOrderBy	:= "G5G_VIGENC DESC,G5G_DTREAJ DESC,G5G_HRREAJ DESC"	//"G5G_DTREAJ,G5G_HRREAJ DESC"

aAdd(aSeek,{"G5G_FILIAL",xFilial("G5G")})
aAdd(aSeek,{"G5G_LOCORI",oMdl:GetValue('GIC_LOCORI')})
aAdd(aSeek,{"G5G_LOCDES",oMdl:GetValue('GIC_LOCDES')})
aAdd(aSeek,{"G5G_CODLIN",oMdl:GetValue('GIC_LINHA')})
aAdd(aSeek,{"G5G_VIGENC",oMdl:GetValue('GIC_DTVEND'),"<="})

//Valor de Tabela 1=Tarifa
aAdd(aSeek,{"G5G_TPREAJ","1"})

GTPSeekTable("G5G",aSeek,aResultSet,.f.,cOrderBy,.t.)

//Valor de Tabela 2=Pedagio
aSeek[Len(aSeek),2] := "2"
GTPSeekTable("G5G",aSeek,aResultSet,.f.,cOrderBy,.t.)

//Valor de Tabela 3=Tx.embarque
aSeek[Len(aSeek),2] := "3"
GTPSeekTable("G5G",aSeek,aResultSet,.f.,cOrderBy,.t.)

//Valor de Tabela 4=Seguro
aSeek[Len(aSeek),2] := "4"
GTPSeekTable("G5G",aSeek,aResultSet,.f.,cOrderBy,.t.)

nP := aScan(aResultSet,{|x| x[1] == "1" })

If ( nP > 0 )
	aAdd(aResultado,{aResultSet[nP,1],aResultSet[nP,2]})
EndIf

nP := aScan(aResultSet,{|x| x[1] == "2" })

If ( nP > 0 )
	aAdd(aResultado,{aResultSet[nP,1],aResultSet[nP,2]})
EndIf

nP := aScan(aResultSet,{|x| x[1] == "3" })

If ( nP > 0 )
	aAdd(aResultado,{aResultSet[nP,1],aResultSet[nP,2]})
EndIf

nP := aScan(aResultSet,{|x| x[1] == "4" })

If ( nP > 0 )
	aAdd(aResultado,{aResultSet[nP,1],aResultSet[nP,2]})
EndIf

Return(aResultado)

/*/{Protheus.doc} GA115Commit(oModel)
//
@author 	Flavio Martins	
@sample	
@return	lRet 
@since		12/04/2018
@version	P12
/*/

Static Function GA115Commit(oModel)
Local lRet 		:= .T.
Local cAliasTab	:= "GIC"
Local cChave	:= ""
Local nOpc		:= oModel:GetOperation()
Local lUtil		:= If(nOpc <> MODEL_OPERATION_DELETE,.T.,.F.)
Local cAgencia	:= oModel:GetModel('GICMASTER'):GetValue('GIC_AGENCI')
Local cTipo	 	:= oModel:GetModel('GICMASTER'):GetValue('GIC_TIPO')
Local cTipoDoc 	:= oModel:GetModel('GICMASTER'):GetValue('GIC_TIPDOC')
Local cSerie	:= oModel:GetModel('GICMASTER'):GetValue('GIC_SERIE')
Local cSubSerie	:= oModel:GetModel('GICMASTER'):GetValue('GIC_SUBSER')
Local cCompl   	:= oModel:GetModel('GICMASTER'):GetValue('GIC_NUMCOM')
Local cNumero  	:= oModel:GetModel('GICMASTER'):GetValue('GIC_NUMDOC')
Local cOrigem	:= oModel:GetModel('GICMASTER'):GetValue('GIC_ORIGEM')

	lRet := FwFormCommit(oModel)
	
	If lRet .AND. cTipo $ 'E|M' .And. cOrigem == '1' .AND. !(oModel:GetModel('GICMASTER'):GetValue('GIC_STATUS') $ "C/D")
		cChave	:= xFilial("GIC")+oModel:GetModel('GICMASTER'):GetValue('GIC_CODIGO')
			
		Begin Transaction
			IF oModel:GetOperation() <> MODEL_OPERATION_UPDATE .AND. ;
				!GA115AtuCtr(cAgencia, cTipoDoc, cSerie, cSubSerie, cCompl, cNumero, lUtil, cAliasTab, cChave)
				lRet := .F.
				DisarmTransaction()
			Endif
			
		End Transaction	
		
	Endif
	
Return lRet
