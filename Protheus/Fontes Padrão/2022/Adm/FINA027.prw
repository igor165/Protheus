#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'  
#INCLUDE 'FINA027.CH'

Static __lCatEFD := .F. 

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA027()
Cadastro de retenções previas de INSS
 
@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function FINA027()
    Local oBrowse

    __lCatEFD := FLX->(ColumnPos("FLX_CATEFD")) > 0
 
    If AliasIndic("FLX") .AND. AliasIndic("FJW") .AND. FindFunction("FINA027A" )

		DbSelectArea ("FLX")
		DbSelectArea ("FJW")
		
		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias( 'FJW' )
		oBrowse:SetDescription( STR0001 ) //"Retenções Prévias de INSS"
		oBrowse:Activate()
    Else
        Alert("Dicionário desatualizado, favor verificar atualizações do cadastro de prévias de INSS") //"Dicionário desatualizado, favor verificar atualizações do motor de cálculo fiscal."
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função responsavel pelo menu da rotina de retenções previas de INSS

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    aAdd( aRotina, { STR0002,	'VIEWDEF.FINA027', 0, 2, 0, NIL } )	//"Visualizar"
    aAdd( aRotina, { STR0003,	'VIEWDEF.FINA027', 0, 3, 0, NIL } )	//"Incluir"
    aAdd( aRotina, { STR0004,	'VIEWDEF.FINA027', 0, 4, 0, NIL } )	//"Alterar"
    aAdd( aRotina, { STR0005,	'VIEWDEF.FINA027', 0, 5, 0, NIL } )	//"Excluir"
    aAdd( aRotina, { STR0006,	'F027Recor()', 0, 6, 0, NIL } )			//"Recorrente"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Função responsavel pelo modelo de dados da rotina de retenções 
previas de INSS

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruFJW := EstrFJW()
    Local oStruFLX := FWFormStruct( 1, 'FLX', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel

    oModel := MPFormModel():New( 'FINA027',  , { |oModel| ValPos( oModel ) } ,  , /*bCancel*/ )

    oModel:AddFields( 'FJWMASTER', /*cOwner*/, oStruFJW )
    oModel:AddGrid( 'FLXDETAIL', 'FJWMASTER', oStruFLX, { |oModel, nLine, cAction, cField, xValue, xOldValue| VLnPre( oModel, nLine, cAction, cField, xValue, xOldValue ) }/*LinaPre*/ , { |oModel| VLnPos( oModel ) }/*bLinePost*/,/*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    oModel:SetPrimaryKey( { "FJW_FILIAL", "FJW_FORNEC","FJW_LOJA" } )

    oModel:SetRelation( 'FLXDETAIL', { { 'FLX_FILIAL', 'xFilial( "FLX" ) ' } , { 'FLX_FORNEC', 'FJW_FORNEC' }, { 'FLX_LOJA', 'FJW_LOJA' } } , FLX->( IndexKey( 1 ) ) )

    oModel:GetModel( 'FLXDETAIL' ):SetUniqueLine( { 'FLX_FILIAL', 'FLX_FORNEC','FLX_LOJA','FLX_ITEM' } )
    oModel:GetModel( 'FLXDETAIL' ):SetUseOldGrid( .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Função responsavel pela View da rotina de retenções previas de INSS

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView
    Local oModel   := FWLoadModel( 'FINA027' )
    // Cria a estrutura a ser usada na View
    Local oStruFJW := FWFormStruct( 2, 'FJW' )
    Local oStruFLX := FWFormStruct( 2, 'FLX',{ |x| !ALLTRIM(x) $ 'FLX_FORNEC,FLX_LOJA,FLX_NOME'})
    Local nOperation := 0

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel( oModel )

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField( 'VIEW_FJW', oStruFJW, 'FJWMASTER' )

    //Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
    oView:AddGrid(  'VIEW_FLX', oStruFLX, 'FLXDETAIL' )

    oView:AddIncrementField( 'VIEW_FLX', 'FLX_ITEM' )

    oStruFJW:SetProperty( 'FJW_NOME' , MVC_VIEW_CANCHANGE ,.F.)

    // Criar "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'EMCIMA' , 15 )
    oView:CreateHorizontalBox( 'EMBAIXO', 85 )

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView( 'VIEW_FJW', 'EMCIMA'   )
    oView:SetOwnerView( 'VIEW_FLX', 'EMBAIXO'  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} EstrFJW

Estrutura de dados para armazenar no modelo dos campos 
Cabeçalho das Previas de INSS

@author pequim
@since 08/04/2015
@version 12.1.5
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------
Static Function EstrFJW()

    Local oStruFJW := FWFormStruct( 1, 'FJW', /*bAvalCampo*/, /*lViewUsado*/ )

    oStruFJW:SetProperty('FJW_NOME'  , MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,Posicione('SA2',1,xFilial('SA2')+FJW->(FJW_FORNEC+FJW_LOJA),'A2_NOME'),'')" ) )

    oStruFJW:AddTrigger('FJW_FORNEC','FJW_NOME',  { || .T.}/*bPre*/,{ |oModel| F027GatFor()})
    oStruFJW:AddTrigger('FJW_FORNEC','FJW_LOJA',  { || .T.}/*bPre*/,{ |oModel| GatForn("E2_LOJA")}) 	
    oStruFJW:AddTrigger('FJW_LOJA'  ,'FJW_NOME',  { || .T.}/*bPre*/,{ |oModel| F027GatFor()})

Return oStruFJW

//-------------------------------------------------------------------
/*/{Protheus.doc} ValPos()
Validação Tudo OK
- valida se o periodo ja possui retenções previas de INSS no periodo e confirma inclusão

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function ValPos(oModel)
    Local nOperation := oModel:GetOperation()
    Local oView	:= FWViewActive()
    Local lOk	:= .F.
    Local lRet	:= .F.
    Local cQuery := ""
    Local aAreaFJW := {}

    IF nOperation == 3 

        aAreaFJW := FJW->( GetArea() )
        cTmp    := GetNextAlias()
        cQuery  := ""
        cQuery  += "SELECT * FROM " + RetSqlName( 'FJW' ) + " FJW "
        cQuery  += "WHERE FJW_FILIAL = '" + xFilial('FJW') +"'
        cQuery  += "AND FJW_FORNEC = '" + FwFldGet( 'FJW_FORNEC' ) + "' "
        cQuery  += "AND FJW_LOJA = '" + FwFldGet( 'FJW_LOJA' ) + "' "
        cQuery  += "AND D_E_L_E_T_ = ' '"
        
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )	
        lRet := (cTmp)->( !EOF() )

        (cTmp)->( dbCloseArea() )	

        RestArea( aAreaFJW )
        
        If lRet
            lOk := .F.
            oModel:SetErrorMessage('FJWMASTER', , 'FJWMASTER', , ,STR0007, STR0008, , )//"Registro ja existente na tabela FJW!", "Escolha a opção Alterar e inclua um registro."
        Else
            lOk := .T.
        EndIf
        
        If lOk
            If F027VerFLX()
                oView:SetInsertMessage(STR0035,STR0034)//"Incluido com sucesso", "Periodo já possui retenções de INSS e os mesmos não serão recalculados"
                lOk := .T.
            EndIf
        EndIf

    EndIF

    If nOperation == 4
        If F027VerFLX()
            oView:ShowUpdateMsg(.T.)
            oView:SetUpdateMessage(STR0036,STR0034)//"Alterado com sucesso","Periodo já possui retenções de INSS e os mesmos não serão recalculados"
        EndIf
        lOk := .T.
    EndIf

    If nOperation == 5
        If F027VerFLX()
            oModel:SetErrorMessage('FJWMASTER', , 'FJWMASTER', , ,STR0011 ,  , , )//"Periodo já possui retenções de INSS e os mesmo não poderá ser excluido!"
            lOk := .F.
        Else
            lOk := .T.
        EndIf

    EndIf

    oModel	 := Nil

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} VLnPre()
Pré validação da grid
- bloqueia alteração de grid 

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function VLnPre(oModel, nLine, cAction)
    Local lOk			:= .T.
    Local nAltPrin		:= SUPERGETMV('MV_ALTPRIN', .F., 2)
    Local nOperation	:= oModel:GetOperation()
    Local oModel		:= FWModelActive()
    Local oAuxFLX		:= oModel:GetModel('FLXDETAIL')

    If nOperation == 4
        If nAltPrin == '1'
            If cAction = "DELETE"
                If F027VerFLX()
                    MsgAlert(STR0034)
                EndIf
            EndIf
        ElseIf FWIsInCallStack("FINA027")
            oModel:SetErrorMessage('FJWMASTER', , , , ,STR0012, , , )//"Não é permitido alterar os registros ja incluidos!"
            lOk	:= .F.
        EndIf
    EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} VLnPos()
pós validação da grid
- verifica na inclusão de uma linha nova, se a inclusao é em um mes 
	anterior ao corrente 
- impede que seja excluido uma linha caso exista retenção no periodo
- verifica se o periodo de retenção é valido
@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function VLnPos(oModel)
    Local lOk			:= .T.
    Local cDtBase		:= ''
    Local cDtIni		:= ''
    Local oModel := FWModelActive()
    Local nOperation := oModel:GetOperation()
    Local oAuxFLX  := oModel:GetModel('FLXDETAIL')

    If nOperation == 4 .OR. nOperation == 3 
        
        cDtBase := SUBSTR(Dtos(date()),1,6)
        cDtIni	 := SUBSTR(Dtos(oAuxFLX:GetValue('FLX_DTINI',oAuxFLX:GetLine())),1,6)
        
        If Val(cDtIni) < Val(cDtBase)
            lOk := .F.
            oModel:SetErrorMessage('FJWMASTER', , , , ,STR0013, , , )//"Não é possivel incluir uma retenção com o mes anterior ao corrente!"
        Else
            lOk := .T.
        EndIf
       
        If oAuxFLX:IsDeleted( oAuxFLX:GetLine() )
        
            If F027VerFLX()	  
                oModel:SetErrorMessage('FJWMASTER', , 'FJWMASTER', , ,STR0014, , , )//"Periodo já possui retenções de INSS e os mesmo não poderá ser excluido!"
                lOk := .F.
            Else
                lOk := .T.
            EndIf
        EndIf

        If lOk .AND. __lCatEFD .and. FWHasEAI("FINA404",.T.,.F.,.T.) .AND. Empty(FwFldGet( 'FLX_CATEFD' ))
            lOk := .F.
            oModel:SetErrorMessage('FJWMASTER', , , , ,STR0037, , , )//"O preenchimento da categoria do eSocial é obrigatorio quando a integracao de autonomos (FINA404) via EAI está ativa."
        Endif
        
        If lOk 
            lOk := ValData(oModel)
        endIf
        
        If lOk .AND. oAuxFLX:IsInserted( oAuxFLX:GetLine() )
            
            dbSelectArea('FLX')
            dbSetOrder(1)
            
            If ( dbSeek( xFilial( 'FLX' ) + FwFldGet( 'FLX_FORNEC' ) + FwFldGet( 'FLX_LOJA' ) + FwFldGet( 'FLX_ITEM' ) ) )
                lOk := MSGYESNO(STR0015 + FwFldGet( 'FLX_ITEM' ), STR0016)//"Registro ja existente na tabela de itens, Item :","Reg. Existente"
            Else
                lOk := .T.
            EndIf
            
        EndIf

    EndIf

    oModel	 := Nil

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} F027VerFLX()
Valida se no periodo informado existe retenção de INSS na SE2

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F027VerFLX()
	Local lRet := .F.
	local cFornec := ''
	Local cLoja := ''
	Local cDtIni := ''
	Local cDtFim := ''
	Local cQuery := ""
	Local cTmp := ""
	Local aAreaSE2 := {}
	
	If FWIsInCallStack("FINA027")
		cFornec := FwFldGet('FJW_FORNEC')
		cLoja := FwFldGet('FJW_LOJA')
		cDtIni := Dtos(FwFldGet('FLX_DTINI'))
		cDtFim := Dtos(FwFldGet('FLX_DTFIM'))
	Else
		cFornec := FJW->FJW_FORNEC
		cLoja := FJW->FJW_LOJA
		cDtIni := Dtos(FLX->FLX_DTINI)
		cDtFim := Dtos(FLX->FLX_DTFIM)
	EndIf

	aAreaSE2 := SE2->( GetArea() )
	cTmp    := GetNextAlias()
	cQuery  := ""
	cQuery  += "SELECT * FROM " + RetSqlName( 'SE2' ) + " SE2 "
 	cQuery  += "WHERE E2_FILIAL = '" + xFilial('SE2') +"'
 	cQuery  += "AND E2_FORNECE = '" + cFornec + "' "
	cQuery  += "AND E2_LOJA = '" + cLoja + "' "
	cQuery  += "AND E2_EMISSAO >= '" + cDtIni + "' "
	cQuery  += "AND E2_EMISSAO <= '" + cDtFim  + "' "
	cQuery  += "AND E2_VRETINS > 0 "
	cQuery  += "AND D_E_L_E_T_ = ' '"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )
	lRet := (cTmp)->( !EOF() )

	(cTmp)->( dbCloseArea() )

	RestArea( aAreaSE2 )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} ValData()
Valida se o periodo é valido

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function ValData(oModel)
	Local lRet := .F.
	Local oAuxFLX  := oModel:GetModel('FLXDETAIL')
	Local cDtIni := Dtos(oAuxFLX:GetValue('FLX_DTINI',oAuxFLX:GetLine()))
	Local cDtFim := Dtos(oAuxFLX:GetValue('FLX_DTFIM',oAuxFLX:GetLine()))

	If Val(cDtIni) > Val(cDtFim)
		oModel:SetErrorMessage('FLXDETAIL', , 'FLXDETAIL', , ,STR0017, STR0018, , )//"Periodo de retenção incorreto!", "Insira um periodo valido."
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F027Recor()
Gravacao recorrente

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F027Recor()

	Local oProcesso	:= Nil
	Local bProcess 	:= {|oSelf|F027PRecorr(oSelf)}
	
	oProcesso := tNewProcess():New("FINA027",;
		STR0010 +" "+ STR0006,;//"Inclusão" + "Recorrente"
		bProcess,;
		STR0019,;//"Inclusão Recorrente de retenção de INSS"
		"FINA027")
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F027PRecorr(oSelf)
Gravacao recorrente

@author Rodolfo Novaes de Sousa
@since 18/03/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F027PRecorr(oSelf)
	Local lRet		:= .F.
	Local lExiste	:= .F.
	Local cLog		:= ""
	Local dDtIni	:= CTOD("//")
	Local dDtFim	:= CTOD("//")
	local nMes		:= 0
	Local nMesFim	:= 0
	Local oModel	:= Nil
	Local oAuxFLX	:= Nil
	Local oAuxFJW	:= Nil
	Local aParam	:= {}
	Local cItem		:= ''
	Local nI		:= 0
	
	aAdd(aParam, {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10})
			  
	If len(cvaltochar(aParam[1,3])) < 4
		MSGINFO (STR0020, STR0022)//"Favor inserir um ano valido.", "Erro"
		return .F.
	EndIf
	If len(cvaltochar(aParam[1,4])) < 1 .or. (aParam[1,4] < 1 .or. aParam[1,4] > 12)
		MSGINFO (STR0021, STR0022)//"Favor inserir um mes valido.", "Erro"
		return .F.
	EndIf
	
	If len(cvaltochar(aParam[1,5])) < 1 .or. (aParam[1,5] < 1 .or. aParam[1,5] > 12)
		MSGINFO (STR0021, STR0022)//"Favor inserir um mes valido.", "Erro"
		return .F.
	EndIf
	
	oModel		:= FWLoadModel( 'FINA027' )
	oAuxFJW	:= oModel:GetModel('FJWMASTER')
	oAuxFLX	:= oModel:GetModel('FLXDETAIL')
	
	//verifica se ja existe registro na FJW
	dbselectarea("FJW")
	dbsetorder(1)
	aAreaFJW := FJW->( GetArea() )
	lExiste := ( dbSeek( xFilial( 'FJW' ) + aParam[1,1] + aParam[1,2] ) )

	If !lExiste
		//se não existir, seta operação para inclusão
		oModel:SetOperation(3)			
	Else
		//se existir seta operação para "ALTERAÇÃO"	
		oModel:SetOperation(4)
	EndIf	
	
	oModel:Activate()
			
	oAuxFJW:setValue('FJW_FORNEC', aParam[1,1])
	oAuxFJW:setValue('FJW_LOJA', aParam[1,2])
	oAuxFJW:setValue('FJW_NOME' , Posicione("SA2",1,xFilial("SA2")+MV_PAR01+MV_PAR02,"A2_NOME"))
		
	nMes := aParam[1,4]
	nMesFim :=  aParam[1,5]
	
	if lExiste
		oAuxFLX:GoLine(oAuxFLX:Length())
		cItem :=  oAuxFLX:GetValue('FLX_ITEM')
	Else
		cItem := '000000'
	EndIf
	
	oSelf:SaveLog(STR0023)//"Log gravação recorrente"
	oSelf:SetRegua1(nMesFim - nMes)
	oSelf:IncRegua1( STR0024  + cValToChar( nI ))//"Processando..."
	
	//inclui na FLX os registros, 1 por mes 
	for nI := nMes to nMesFim
		oAuxFLX:AddLine()
		cItem  := Soma1(cItem)
		dDtIni := FirstDay(ctod("15/" + strzero(nI,2) +"/"+ cvaltochar(aParam[1,3])))
		dDtFim := LastDay(ctod("15/" + strzero(nI,2) +"/"+ cvaltochar(aParam[1,3])))
		
		oAuxFLX:SetValue( 'FLX_FORNEC' , aParam[1,1])
		oAuxFLX:LoadValue( 'FLX_LOJA' , aParam[1,2])
		oAuxFLX:SetValue( 'FLX_NOME' , Posicione("SA2",1,xFilial("SA2")+MV_PAR01+MV_PAR02,"A2_NOME"))
		oAuxFLX:SetValue( 'FLX_ITEM' , cItem)
		oAuxFLX:SetValue( 'FLX_DTINI' , dDtIni)
		oAuxFLX:SetValue( 'FLX_DTFIM' , dDtFim)
		oAuxFLX:SetValue( 'FLX_ENTIDA' , aParam[1,8])
		oAuxFLX:SetValue( 'FLX_TIPO' , cvaltochar(aParam[1,9]))
		oAuxFLX:SetValue( 'FLX_CNPJ' , aParam[1,10])
		oAuxFLX:SetValue( 'FLX_BASE' , aParam[1,6])
		oAuxFLX:SetValue( 'FLX_INSS' , aParam[1,7])
	next nMes
	
	//Gravação do Modelo de Dados.
	If oModel:VldData()
		lRet := oModel:CommitData()
		MSGINFO(STR0025, STR0026)//"Processamento concluido com sucesso!" , "Ok"
	Else
		lRet := .F.
		For nI := 1 To 6
			cLog += oModel:GetErrorMessage( ) [nI] + " - "
		Next nZ
		If !Empty(cLog)
			oSelf:SaveLog(cLog)
		EndIf
		MSGINFO(STR0027, STR0022)//"Houve erros no processamento, favor verificar o log.", "Erro"
	Endif
	
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F027GatFor()
Gatilho disparado dos campos FJW_FORNEC E FJW_LOJA 

@author Mauricio Pequim Jr
@since 09/04/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F027GatFor()

    Local oModel	:= FWModelActive()
    Local oSubFWJ	:= oModel:GetModel("FJWMASTER")
    Local cForn	:= oSubFWJ:GetValue("FJW_FORNEC","A2_NOME")
    Local cLoja	:= oSubFWj:GetValue("FJW_LOJA","A2_LOJA")
    Local cNome	:= ""

    cLoja := IIF(Empty(cLoja),"",cLoja)

    cNome := Substr(Posicione("SA2",1,xFilial("SA2")+cForn+cLoja,'A2_NOME') ,1 ,TAMSX3("FJW_NOME")[1] )

Return cNome

//-------------------------------------------------------------------
/*/{Protheus.doc} F027VldCgc()
Validação do campo FLX_CGC 

@author Mauricio Pequim Jr
@since 09/04/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F027VldCgc()

    Local oModel	:= FWModelActive()
    Local oSubFLX	:= oModel:GetModel("FLXDETAIL")
    Local cTipo		:= oSubFLX:GetValue("FLX_TIPO")
    Local lRet := .T.

    If !Vazio()
        If cTipo == "1" .And. !(Len(AllTrim(M->FLX_CNPJ))==11)
            Help(" ",1,"CPFINVALID")
            lRet := .F.
        ElseIf cTipo == "2" .And. !(Len(AllTrim(M->FLX_CNPJ))==14)
            Help(" ",1,"CGC")
            lRet := .F.
        ElseIf !Cgc(M->FLX_CNPJ)
            lRet := .F.
        EndIf
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F027PRINSS()

@author Lucas de Oliveira
@since 13/04/2015
@version P12.1.5
/*/
//-------------------------------------------------------------------
Function F027PRINSS(cFornece, cLoja, dEmissao, dVencRea)
    Local nValor	as numeric
    Local aArea		as array
    Local lVencto	as logical
    Local dDataAcm	as date
    Local cQuery	as character
    Local cTmp      as character

    aArea       := GetArea()
    lVencto	    := SuperGetMv("MV_ACMINSS",.T.,"1") == "2"  //1 = Emissao, 2= Vencimento Real
    dDataAcm	:= CTOD("//")

    DEFAULT cFornece    := ""
    DEFAULT cLoja       := ""
    DEFAULT dEmissao    := CTOD("//")
    DEFAULT dVencRea    := CTOD("//")

    dDataAcm	:= dEmissao

    If !Empty(cFornece) .OR. !Empty(cLoja) .OR. !Empty(dEmissao) .OR. If(lVencto, !Empty(dVencRea), !Empty(dEmissao)) 
        
        cTmp   := GetNextAlias()
        cQuery := "SELECT SUM(FLX_INSS) NVALINSS FROM " + RetSQLname("FLX")
        cQuery += " WHERE "
        cQuery += "FLX_FORNEC = '"+ cFornece +"' AND "
        cQuery += "FLX_LOJA = '"+ cLoja +"' AND "
        cQuery += "FLX_INSS > 0 AND "
        
        If lVencto
            cQuery += "'"+ DTOS(dVencRea) +"' BETWEEN FLX_DTINI AND FLX_DTFIM AND "
        Else
            cQuery += "'"+ DTOS(dEmissao) +"' BETWEEN FLX_DTINI AND FLX_DTFIM AND "
        EndIf

        cQuery += "D_E_L_E_T_ = ' ' "
        
        cQuery := ChangeQuery(cQuery)
        
        dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .T.)
        TcSetField(cTmp,"NVALINSS"  ,"N", 17,2)
        
        nValor := (cTmp)->nValInss
        
        (cTmp)->( dbCloseArea() )
        
        RestArea(aArea)
        
    EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDCNPJCPF()
Trato o valor passado no MV_PAR09 (pessoa Física ou Jurídica)

@author Lucas de Oliveira
@since 08/10/2015
@version P12.1.7
/*/
//-------------------------------------------------------------------
Function VLDCNPJCPF()
    Local lRet	:= .T.

    lRet := Vazio() .Or. Cgc(MV_PAR10)

Return lRet
