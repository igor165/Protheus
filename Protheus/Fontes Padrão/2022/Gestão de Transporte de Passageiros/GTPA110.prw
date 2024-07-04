#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA110.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA110()
Cadastro de Emiss�o de Vales
 
@sample	GTPA110()
 
@return	oBrowse  Retorna o Cadastro de Emiss�o de Vales
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA110()

Local oBrowse	:= Nil		

Private aRotina := MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias("GQP")
oBrowse:SetDescription(STR0001)	// "Controle de Vales"
oBrowse:AddLegend( "GQP_STATUS=='1'", "RED", STR0009) //Pendente
oBrowse:AddLegend( "GQP_STATUS=='2'", "GREEN" , STR0010 ) //Baixado
oBrowse:Activate()

Return (oBrowse)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Defini��o do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com op��es do menu
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aRotina	:= {}
Local oModel	:= FwModelActive()

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA110' OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA110' OPERATION 3 ACCESS 0 // #Incluir
ADD OPTION aRotina TITLE STR0012    ACTION 'GA110Oper()'     OPERATION 5 ACCESS 0 // #Excluir
ADD OPTION aRotina TITLE STR0008    ACTION 'GTPR107()'    	 OPERATION 2 ACCESS 0 // #Imprimir Recibo
ADD OPTION aRotina TITLE STR0021    ACTION 'GA113Oper(3)'    OPERATION 3 ACCESS 0 // #Autoriza��o na Folha

Return ( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruGQP     := FWFormStruct(1,'GQP')
Local oStr2GQP     := FWFormStruct(1,'GQP')
Local bPosValidMdl := {|oModel| GA110PosValidMdl(oModel)}
Local bCommit      := {|oModel| GA110CommitMdl(oModel)}
Local oModel


// Gatilho Departamento - Retorna a descri��o do campo dapartamento
oStruGQP:AddTrigger("GQP_DEPART", "GQP_DESCDP", {||.T.}, {|| Posicione('SQB',1,xFilial('SQB')+oModel:GetModel("FIELDGQP"):GetValue("GQP_DEPART"),'QB_DESCRIC')}) 
// Modo de Edi��o
oStruGQP:SetProperty("GQP_DEPART", MODEL_FIELD_WHEN,{|| IIF(oModel:GetModel("FIELDGQP"):GetValue("GQP_ORIGEM") == "2",.T., .F.)})  

// Gatilho da Origem               
oStruGQP:AddTrigger('GQP_ORIGEM'  , ;     // [01] Id do campo de origem
					'GQP_ORIGEM'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	  // [03] Bloco de codigo de valida��o da execu��o do gatilho
		 			{ || GA110TrigOrig() } ) // [04] Bloco de codigo de execu��o do gatilho

// Gatilho de sugest�o da data de vig�ncia do vale               
oStruGQP:AddTrigger('GQP_TIPO'  , ;     // [01] Id do campo de origem
					'GQP_TIPO'  , ;     // [02] Id do campo de destino
		 			{ || .T. }    , ; 	// [03] Bloco de codigo de valida��o da execu��o do gatilho
		 			{ || GA110TrigVigenc() } ) // [04] Bloco de codigo de execu��o do gatilho


oStr2GQP:SetProperty("GQP_CODIGO", MODEL_FIELD_WHEN,	{|| .T.}) // Modo de Edi��o 
oStr2GQP:SetProperty("GQP_CODIGO", MODEL_FIELD_VALID, 	{|| .T.}) // Valida��o ExisteChav 

//Bloqueia os campos quando a tela n�o for de inclus�o
oStruGQP:SetProperty('GQP_VIGENC',MODEL_FIELD_WHEN,{|| INCLUI   })
oStruGQP:SetProperty('GQP_VALOR' ,MODEL_FIELD_WHEN,{|| INCLUI   })
oStruGQP:SetProperty('GQP_SLDDEV',MODEL_FIELD_WHEN,{|| .F.   	})
oStruGQP:SetProperty('GQP_USREMI',MODEL_FIELD_WHEN,{|| INCLUI})
oStruGQP:SetProperty('GQP_CODFUN',MODEL_FIELD_WHEN,{|| INCLUI})

oStruGQP:SetProperty('GQP_VIGENC',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA110VldVigenc()"))
oStruGQP:SetProperty('GQP_EMISSA',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA110VldEmis()"	 ))
oStruGQP:SetProperty('GQP_SLDDEV',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA110VldSldDev()"))
oStruGQP:SetProperty('GQP_CODFUN',MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID , "GA110VldCodFun()"))

oModel := MPFormModel():New('GTPA110',/*bPreValidMdl*/, bPosValidMdl, bCommit, /*bCancel*/ )

oModel:SetDescription(STR0002) // Emiss�o de Vales
 
oModel:AddFields('FIELDGQP',,oStruGQP)

oModel:AddGrid("GRIDGQP", "FIELDGQP", oStr2GQP,/*bPreVld*/,,,,{|oModel| GA110Load(oModel)})

oModel:GetModel('FIELDGQP'):SetDescription(STR0002)  //Emiss�o de Vales
oModel:GetModel('GRIDGQP'):SetDescription(STR0013)   //Vales Pendentes

oModel:GetModel('GRIDGQP'):SetOptional(.T.)   //GRID n�o obrigatorio
oModel:GetModel('GRIDGQP'):SetOnlyQuery(.T.)   //N�o deixa atualizar no banco de dados

oModel:GetModel('GRIDGQP'):SetNoInsertLine(.T.)
oModel:GetModel('GRIDGQP'):SetNoUpdateLine(.T.)
oModel:GetModel('GRIDGQP'):SetNoDeleteLine(.T.)


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel   := ModelDef()
Local oStruGQP := FWFormStruct(2, 'GQP')
Local oStru2GQP := FWFormStruct(2, 'GQP')

oStruGQP:SetProperty("GQP_DEPART", MVC_VIEW_LOOKUP , "SQB")

// Remove campos do GRID
oStru2GQP:RemoveField("GQP_ORIGEM")
oStru2GQP:RemoveField("GQP_CODAGE")
oStru2GQP:RemoveField("GQP_DESCAG")
oStru2GQP:RemoveField("GQP_CODFUN")
oStru2GQP:RemoveField("GQP_DEPART")
oStru2GQP:RemoveField("GQP_VALOR")
oStru2GQP:RemoveField("GQP_TIPO")
oStru2GQP:RemoveField("GQP_USREMI")

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEWGQP', oStruGQP, 'FIELDGQP') 
oView:AddGrid('VIEWGRIDGQP', oStru2GQP, 'GRIDGQP') 

oView:CreateHorizontalBox( 'SUPERIOR', 70)
oView:CreateHorizontalBox( 'INFERIOR', 30)
oView:SetOwnerView('VIEWGQP','SUPERIOR')
oView:SetOwnerView('VIEWGRIDGQP','INFERIOR')

Return oView

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110VldEmis
Valida funcion�rio do vale, se o funcion�rio j� tiver um vale do mesmo tipo 
pendende, n�o ser� poss�vel criar outro do mesmo tipo.

@sample GA110VldCodFun()
@return  lRet

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA110VldCodFun()
Local oModel	  := FWModelActive()
Local cAliasGQP	  := GetNextAlias()
Local oMdlGQP	  := oModel:GetModel('FIELDGQP')
Local cCodFun	  := oMdlGQP:GetValue("GQP_CODFUN")
Local cTipoVal    := oMdlGQP:GetValue("GQP_TIPO")
Local lRet		  := .T.

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	BeginSQL Alias cAliasGQP
		SELECT 
			COUNT(*) GQP_TIPO
		FROM 
			%table:GQP% GQP 
		WHERE
			GQP.GQP_FILIAL = %xFilial:GQP%
			AND GQP.GQP_STATUS = '1' 
			AND GQP.GQP_TIPO = %Exp:cTipoVal%  
			AND GQP.GQP_CODFUN = %Exp:cCodFun% 
			AND GQP.%NotDel%
	EndSQL
	// Verifica se j� existe um vale aberto daquele tipo para aquele funcion�rio
	If ((cAliasGQP)->GQP_TIPO > 0)
		Help(,, STR0014,, STR0020, 1,0 ) // J� existe um vale com este tipo para esse funcion�rio, Aten��o
		lRet := .F.
	EndIf
	(cAliasGQP)->(DbCloseArea())
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110VldEmis
Valida data de emiss�o do vale

@sample GA110VldEmis()
@return  lRet

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA110VldEmis()
Local oModel	  := FWModelActive()
Local cAliasGQP	  := GetNextAlias()
Local oMdlGQP	  := oModel:GetModel('FIELDGQP')
Local cNumVal	  := oMdlGQP:GetValue("GQP_CODIGO")
Local dDataEmis   := oMdlGQP:GetValue("GQP_EMISSA")
Local lRet		  := .T.

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	// A data de vig�ncia do vale n�o pode ser maior que o per�odo de vig�ncia do tipo do vale
	If dDataEmis < dDataBase
		Help(,, STR0014,, STR0018, 1,0 ) // A data de emiss�o do vale n�o pode ser inferior a data atual!, Aten��o
		lRet := .F.
	EndIf
ElseIF oModel:GetOperation() == MODEL_OPERATION_UPDATE
	// Come�a consulta SQL na tabela tempor�ria criada
	BeginSQL Alias cAliasGQP
		SELECT 
			GQP.GQP_EMISSA
		FROM 
			%table:GQP% GQP
		WHERE 
			GQP.GQP_FILIAL = %xFilial:GQP%
			AND GQP.GQP_CODIGO = %Exp:cNumVal% 
			AND GQP.%NotDel%
	EndSQL
	// Verifica se a data de altera��o � menor que a data ja cadastrada no banco em caso de update
	If (oMdlGQP:GetValue("GQP_EMISSA") < STOD((cAliasGQP)->GQP_EMISSA))
		Help(,, STR0014,, STR0019, 1,0 ) // A data de emiss�o do vale n�o pode ser inferior a data atual!, Aten��o
		lRet := .F.
	EndIf

	(cAliasGQP)->(DbCloseArea())
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110VldSldDev
Valida o saldo devedor digitado

@sample GA110VldSldDev()
@return  lRet

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA110VldSldDev()
Local oModel	:= FWModelActive()
Local oMdlGQP	:= oModel:GetModel('FIELDGQP')
Local nValor 	:= oMdlGQP:GetValue("GQP_VALOR")
Local nSldDev	:= oMdlGQP:GetValue("GQP_SLDDEV")
Local lRet		:= .T.

// O saldo devedor n�o pode ser maior que o valor do vale
If nSldDev > nValor
	Help(, , STR0014 , , STR0017, 1,0 ) //O saldo devedor do vale n�o pode ser maior que seu valor., Aten��o
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110VldVigenc
Valida data de vig�ncia de acordo com o per�odo de vig�ncia do vale

@sample GA110VldVigenc()
@return  lRet

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA110VldVigenc()
Local oModel	  :=FWModelActive()
Local oMdlGQP	  := oModel:GetModel('FIELDGQP')
Local dDataVigc	  := oMdlGQP:GetValue("GQP_VIGENC")
Local dDataEmis   := oMdlGQP:GetValue("GQP_EMISSA")
Local nPerVigenc  := Posicione("G9A",1,xFilial("G9A") + oMdlGQP:GetValue("GQP_TIPO"),"G9A_PERVIG")
Local dDataVigenc := dDataBase + nPerVigenc
Local lRet		  := .T.

// A data de vig�ncia do vale n�o pode ser maior que o per�odo de vig�ncia do tipo do vale
If oMdlGQP:GetValue("GQP_VIGENC") > dDataVigenc
	Help(,, STR0014,, STR0016, 1,0 ) // A data de vig�ncia excede o per�odo de vig�ncia do tipo deste vale!, Aten��o
	lRet := .F.
EndIf

// A data de vig�ncia do vale n�o pode ser menor que a emiss�o do mesmo
If dDataEmis > dDataVigc
	Help(,, STR0014,, STR0016, 1,0 ) // A data de vig�ncia excede o per�odo de vig�ncia do tipo deste vale!, Aten��o
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110TrigOrig
Fun��o que limpa os dados da ag�ncia caso a origem seja um departamento

@sample	GA110TrigOrig()

@author	    Renan Ribeiro Brando - Inova��o
@since		09/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA110TrigOrig()

Local oModel    := FwModelActive()
Local oFieldGQP := oModel:GetModel('FIELDGQP')

If oFieldGQP:GetValue("GQP_ORIGEM") == "2"
	oFieldGQP:LoadValue("GQP_CODAGE", "") // Necess�rio LoadValue pq campo � consulta padr�o
	oFieldGQP:LoadValue("GQP_DESCAG", "") 
Else
	oFieldGQP:LoadValue("GQP_DEPART", "") 
	oFieldGQP:LoadValue("GQP_DESCDP", "") 
EndIf

Return

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110TrigVigenc
Fun��o que sugere uma data de vig�ncia do vale de acordo com o per�do de vig�ncia do tipo do vale 

@sample	GA110TrigVigenc()

@author	    Renan Ribeiro Brando - Inova��o
@since		09/03/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA110TrigVigenc()

Local oModel      := FwModelActive()
Local oFieldGQP   := oModel:GetModel('FIELDGQP')
Local nPerVigenc  := Posicione("G9A",1,xFilial("G9A") + oFieldGQP:GetValue("GQP_TIPO"),"G9A_PERVIG")

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	oFieldGQP:SetValue("GQP_VIGENC", dDataBase + nPerVigenc)
EndIf
 
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110PosValidMdl(oModel)
P�s valida��o do commit MVC, caso ag�ncia n�o seja informado mostra aviso
 
@sample	GA110PosValidMdl(oModel)
 
@return	lRet 
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA110PosValidMdl(oModel)

Local oMdlGQP	  := oModel:GetModel('FIELDGQP')
Local lRet		  := .T.

// Se j� existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGQP:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGQP:GetOperation() == MODEL_OPERATION_UPDATE)
	If (!ExistChav("GQP", oMdlGQP:GetValue("GQP_CODIGO")))
        lRet := .F.
    EndIf
EndIf

If oMdlGQP:GetValue('GQP_ORIGEM') = '1' .AND. Empty(oMdlGQP:GetValue('GQP_CODAGE')) 
	lRet := .F.
	Help(,, STR0014, , STR0007, 1,0 )	// "Aten��o, "Informe o c�digo da ag�ncia"
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110CommitMdl(oModel)
Rotina executada no Commit do modelo de dados
 
@sample	GA110CommitMdl()
@param  oModel - model utilizado
@return	lRet - retorna se o commit foi realizado com sucesso
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/ 
//--------------------------------------------------------------------------------------------------------
Static Function GA110CommitMdl(oModel)

Local lRet      := .F.
Local nValor	:= oModel:GetValue("FIELDGQP","GQP_VALOR")

// Atualiza o saldo devedor na tabela GQP
If (oModel:GetOperation() == MODEL_OPERATION_INSERT)
	oModel:LoadValue("FIELDGQP","GQP_SLDDEV", nValor)
Endif

If oModel:VldData()
	lRet := .T.
	FWFormCommit(oModel)
EndIf

Return(lRet)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA110Load(oModel)
Fun��o que � executada pelo bloco de carga do Grid
 
@sample	GA110Load(oModel)
@param oModel - model utilizado 
@return	aLoad - array com os dados da tabela a ser carregada no GRID
 
@author	Renan Ribeiro Brando -  Inova��o
@since		08/03/2017
@version	P12
/*/ 
//--------------------------------------------------------------------------------------------------------
Static Function GA110Load(oModel)
Local aLoad := {}
Local aFlds := {}
Local aAux 	:= {}
Local cAliasGQP := GetNextAlias()  // Cria tabela tempor�ria
Local nI := 0
Local cCodFun := GQP->GQP_CODFUN

aFlds := oModel:GetStruct():GetFields()

// Come�a consulta SQL na tabela tempor�ria criada
BeginSQL Alias cAliasGQP
	SELECT 
		GQP.GQP_CODIGO, GQP.GQP_DESFIN, GQP.GQP_EMISSA, GQP.GQP_VIGENC, GQP.GQP_CODFUN,
		GQP.GQP_TIPO, G9A.G9A_DESCRI, GQP.GQP_VALOR,  GQP.GQP_SLDDEV, GQP.GQP_STATUS, GQP.GQP_USREMI, GQP.R_E_C_N_O_
	FROM 
		%table:GQP% GQP, %table:G9A% G9A
	WHERE 
		GQP.GQP_FILIAL = %xFilial:GQP%
		AND GQP.GQP_TIPO = G9A.G9A_CODIGO
		AND GQP.GQP_CODFUN = %Exp:cCodFun% 
		AND GQP.%NotDel%
		AND GQP_STATUS = '1'
EndSQL

While ( (cAliasGQP)->(!Eof()) ) //varredura da tabela ou arquivo tempor�rio
	For nI := 1 to Len(aFlds)
  		aAdd(aAux,(cAliasGQP)->&(aFlds[nI,3]))  //&->pega o conte�do do campo ao inv�s do nome
 	Next nI
	// Adiciona campo ao array aLoad
 	aAdd(aLoad,{(cAliasGQP)->R_E_C_N_O_,aClone(aAux)})
 	aAux := {}
	// Pula para pr�xima linha da tabela
 	(cAliasGQP)->(DbSkip())
End
Return(aLoad)

//--------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GA110Oper
ExecView utilizado para realizar mais de um tipo de opera��o no banco de dados simultaneamente

@sample GA110Oper()

@author	Renan Ribeiro Brando - Inova��o
@since		08/03/2017
@version	P12
*/
//--------------------------------------------------------------------------------------------------------
Function GA110Oper()

Local oModel	 
Local oModelGQP 
Local oModelGQU
Local cNumVal 	  := GQP->GQP_CODIGO
Local lRet        := .T.
Local lGQQ		  := .F.
Local lGQU 		  := .F.
Local lG96		  := .F.

// Verifica se o vale tem presta��o de contas
DBSelectArea("GQQ")
If DBSeek(xFilial('GQQ') + cNumVal + Posicione("GQQ",1,xFilial("GQQ") + cNumVal,"GQQ_CODIGO"))
	lGQQ := .T.
EndIf
// Verifica se o vale tem prorroga��o
DBSelectArea("GQU")
If DBSeek(xFilial('GQU') + cNumVal + STR(Posicione("GQU",1,xFilial("GQU") + cNumVal,"GQU_NUMPRO"),3,0))
	lGQU := .T.
EndIf
// Verifica se o vale possui autoriza��o na folha (baixado)
DBSelectArea("G96")
If DBSeek(xFilial('G96') + cNumVal) .OR. GQP->GQP_STATUS == "2"
	lG96 := .T.
EndIf
// Se o vale possuir alguma prorroga��o, presta��o de contas ou autoriza��o de pagamentos n�o poder� ser deletado.
If ( lGQQ .OR. lGQU .OR. lG96)
	MsgAlert( STR0015, STR0014 ) // Vales que possuem pend�ncias n�o podem ser deletados!, Aten��o
	lRet := .F.
EndIf

If lRet
	FWExecView( STR0001,'VIEWDEF.GTPA110', MODEL_OPERATION_DELETE, , , , , )
EndIf

Return