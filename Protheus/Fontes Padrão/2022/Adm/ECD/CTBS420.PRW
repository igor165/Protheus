#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include "CTBS420.ch"

//Compatibilização de fontes 30/05/2018

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS420
Cadastro do Bloco K - Conglomerados Economicos

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function CTBS420()
Local oBrowse

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'CQQ' )

oBrowse:SetDescription( STR0001 ) //STR0001 //"Cadastro do Bloco K - Conglomerados Economicos"

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 	Action 'VIEWDEF.CTBS420' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003   Action 'VIEWDEF.CTBS420A' OPERATION 3 ACCESS 0   //observe que alteracao e inclusao faz pelo CTBS420A //'Incluir'
ADD OPTION aRotina Title STR0004   Action 'VIEWDEF.CTBS420A' OPERATION 4 ACCESS 0   //observe que alteracao e inclusao faz pelo CTBS420A //'Alterar'
ADD OPTION aRotina Title STR0005   Action 'VIEWDEF.CTBS420' OPERATION 5 ACCESS 0 //'Excluir'

ADD OPTION aRotina Title STR0006   Action 'VIEWDEF.CTBS420' OPERATION 4 ACCESS 0 //'K115 Emp.Evento'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCQQ := FWFormStruct(1,'CQQ')
Local oStruCQR := FWFormStruct(1,'CQR')
Local oStruCQS := FWFormStruct(1,'CQS')
Local oStruCQT := FWFormStruct(1,'CQT')
Local oModel

oModel := MPFormModel():New('CTBS420', /*<bPre >*/, /*<bPost >*/, /*<bCommit >*/, /*<bCancel>*/)

oModel:AddFields('CQQMASTER',,oStruCQQ)

oModel:AddGrid('CQRDETAIL','CQQMASTER',oStruCQR, { || CQRLPRE() }/*bLinePre*/, /*bLinePost*/{ || CQRLPOS() }, /*bPreVal*/, { || CQRLPOS1() }/*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('CQSDETAIL','CQRDETAIL',oStruCQS, /*bLinePre*/, /*bLinePost*/{ || CQSLPOS() }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('CQTDETAIL','CQSDETAIL',oStruCQT, /*bLinePre*/, /*bLinePost*/{ || CQTPosVld() }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('CQRDETAIL',{{'CQR_FILIAL','XFilial("CQR")'},{'CQR_IDBLK','CQQ_IDBLK'}}, CQR->(IndexKey(1)) )
oModel:SetRelation('CQSDETAIL',{{'CQS_FILIAL','XFilial("CQS")'},{'CQS_IDBLK','CQQ_IDBLK'},{'CQS_CODEMP','CQR_CODEMP'}},CQS->(IndexKey(1)))
oModel:SetRelation('CQTDETAIL',{{'CQT_FILIAL','XFilial("CQT")'},{'CQT_IDBLK','CQQ_IDBLK'},{'CQT_CODEMP','CQR_CODEMP'},{'CQT_CODEVE','CQS_CODEVE'}}, CQT->(IndexKey(1)) )

oModel:SetDescription('Bloco K')

oModel:GetModel('CQQMASTER'):SetDescription( STR0007 ) //STR0007 //"Registro K030: Periodo Escrituração Bloco K - Conglomerados Econômicos"
oModel:GetModel('CQRDETAIL'):SetDescription( STR0008 ) //STR0008 //"Registro K100: Relação Empresas Consolidadas"
oModel:GetModel('CQSDETAIL'):SetDescription( STR0009 ) //STR0009 //"Registro K110: Eventos Societarios / Empresa"
oModel:GetModel('CQTDETAIL'):SetDescription( STR0010 ) //STR0010 //"Registro K115: Empresas Participantes Evento Societario"

oModel:GetModel( 'CQSDETAIL' ):SetOptional( .T. )
oModel:GetModel( 'CQTDETAIL' ):SetOptional( .T. )

oModel:GetModel( 'CQRDETAIL' ):SetUniqueLine( { 'CQR_GRUFIL' } )

oModel:GetModel( 'CQSDETAIL' ):SetUniqueLine( { 'CQS_CODEVE' } )

oModel:GetModel( 'CQTDETAIL' ):SetUniqueLine( { 'CQT_EMPPAR', 'CQT_CONDPT' } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruCQQ	:= FWFormStruct(2,'CQQ')
Local oStruCQR	:= FWFormStruct(2,'CQR')
Local oStruCQS	:= FWFormStruct(2,'CQS')
Local oStruCQT	:= FWFormStruct(2,'CQT')
Local oModel		:= FWLoadModel('CTBS420')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CQQ',oStruCQQ,'CQQMASTER')

oStruCQR:SetProperty( 'CQR_CDPAIS' , MVC_VIEW_LOOKUP    ,'CCH')
oStruCQR:SetProperty( '*'          , MVC_VIEW_CANCHANGE , .F. )

oView:AddGrid('VIEW_CQR',oStruCQR,'CQRDETAIL')
oView:AddGrid('VIEW_CQS',oStruCQS,'CQSDETAIL')
oView:AddGrid('VIEW_CQT',oStruCQT,'CQTDETAIL')

oView:SetAfterViewActivate({|oView| CQTPRECD(oView)})
	
oView:CreateHorizontalBox( 'INCALT', 75 )
oView:CreateHorizontalBox( 'BOXK115', 25 )

// Cria Folder na view
oView:CreateFolder( 'REGISTRO', "INCALT" )
// Cria pastas nas folders
oView:AddSheet( 'REGISTRO', 'K030', STR0011 ) //'K030 - Conglomerados Economicos'

oView:CreateFolder( 'REGK115', "BOXK115" )
// Cria pastas nas folders
oView:AddSheet( 'REGK115', 'K115', STR0012 ) //'K115 - Empresas Participantes Evento'


// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP' 			,  20,,, 'REGISTRO', 'K030' )
oView:CreateHorizontalBox( 'CENTER_TOP' 	,  35,,, 'REGISTRO', 'K030' )
oView:CreateHorizontalBox( 'CENTER_DOWN' 	,  20,,, 'REGISTRO', 'K030' )
oView:CreateHorizontalBox( 'DOWN'			,  25,,, 'REGK115', 'K115' )

oView:SetOwnerView('VIEW_CQQ','TOP'		)
oView:SetOwnerView('VIEW_CQR','CENTER_TOP'		)
oView:SetOwnerView('VIEW_CQS','CENTER_DOWN'	)
oView:SetOwnerView('VIEW_CQT','DOWN'	)

oView:EnableTitleView('VIEW_CQQ')
oView:EnableTitleView('VIEW_CQR')
oView:EnableTitleView('VIEW_CQS')
oView:EnableTitleView('VIEW_CQT')

oModel:SetPrimarykey({'CQQ_FILIAL','CQQ_IDBLW'})  //COLOCAR NO DICIONARIO X2_UNICOADMIN

oView:SetOnlyView('CQRDETAIL')
oView:SetOnlyView('CQSDETAIL')

//Define que a tela sera um formulario continuo
oView:SetContinuousForm(.T.)

oView:SetCloseOnOk({||.T.})

oView:SetViewCanActivate( {|oView| CQTPRECD(oView)} )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CQRLPOS1()
Validação Tudo OK preenchimento da grade referente registro K100 - Empresas participantes da consolidacao

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQRLPOS1()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oGridCQR := oModel:GetModel("CQRDETAIL")
Local nLinOri  := oGridCQR:GetLine()  //grava a linha atual da grade para retornar apos contagem laco for...next
Local nX
Local oView		:= FWViewActive()

For nX:=1 TO oGridCQR:Length()
	
	oGridCQR:GoLine(nX)  //vai para linha
	
	If ! oGridCQR:IsDeleted()  //se nao estiver deletada
		lRet := CQRLPOS(.F.)
		If !lRet
			Exit
		EndIf
	EndIf

Next 

If lRet
	oGridCQR:GoLine(nLinOri)  //vai para linha posicionada anteriormente ao laco for...next se estiver tudo ok senao continua na linha a ser editada
Else
	oView:Refresh("CQRDETAIL")  //ESTE REFRESH EH NECESSARIO PARA ATUALIZAR A GRADE COM OS NOVOS VALORES ATRIBUIDOS
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CQRLPOS()
Validação sobre o preenchimento do registro K100 / validacao CGC obrigatorio para quando pais igual a Brasil

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQRLPOS(lValLinha)
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local aAux 	:= {}
Local nX 		:= 0

Default lValLinha := .T.

//----------------------------------------
// Valida se o bloco W250 esta preenchido
//----------------------------------------
If oModel:GetModel( 'CQRDETAIL' ):IsEmpty()
	Help( , ,"CQRLPOS", ,STR0013,1,0,,,,,,{ STR0014 })	 //STR0013 ###  //"Cadastro do bloco K100 não preenchido!" //"Para solucionar efetue o cadastro dos registros referente ao bloco K100"
																																											    //"Para solucionar efetue o cadastro dos registros referente ao bloco K100"                    
	lRet := .F.
Else
	//primeiro verifica se codigo do pais 01058-brasil se preencheu CNPJ
	If oModel:GetModel( 'CQRDETAIL' ):GetValue("CQR_CDPAIS") = '01058' .And. ;//codigo do brasil
		Empty(oModel:GetModel( 'CQRDETAIL' ):GetValue("CQR_CNPJ")) //CNPJ VAZIO
		Help( , ,"CQRLPOS", ,STR0015,1,0,,,,,,{ STR0016 })	   //"CNPJ obrigatorio para pais Brasil." //"Preecnha o CNPJ da empresa."

		lRet := .F.
	
	EndIf

	//primeiro verifica se empresa e empresa participante do k115 sao iguais 
	If oModel:GetModel( 'CQRDETAIL' ):GetValue("CQR_CODEMP") == oModel:GetModel( 'CQTDETAIL' ):GetValue("CQT_EMPPAR") 
		Help( , ,"CQRLPOS", ,STR0029,1,0,,,,,,{ STR0030 })  //"Codigo da Empresa participante e contra parte iguais. "##"Preencha o campo Cd.Empr.Part. diferente do Cd.Seq.Empresa . "	   

		lRet := .F.
	
	EndIf

	
	If !lValLinha
	    //VERIFICA SE CAMPOS OBRIGATORIOS ESTAO PREENCHIDO
		aAux := oModel:GetModel( 'CQRDETAIL' ):GetStruct():GetFields()

		For nX := 1 TO Len(aAux)
           //campos obrigatorios volta a obrigatoriedade para preencher a grade - valida posterior linOk e TudOK		
			If aAux[nX][10] .And. Empty( oModel:GetModel( 'CQRDETAIL' ):GetValue(aAux[nX,3]) )
				Help( , ,"CQR_OBRIGAT", ,STR0031+aAux[nX,2],1,0,,,,,,{ STR0032 })  //"Campo Obrigatorio nao preenchido: "###"Preencha o campo informado."
				
				lRet := .F.
					   
			EndIf
			
			If !lRet
				Exit
			EndIf
			
		Next nX
	
	EndIf
	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CQRLPRE()
Pre=Validação sobre o preenchimento do Registo K030
Somente pode preencher a grade do K100 se K030 estiver com datas preenchidas
@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQRLPRE()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

//primeiro verifica se descricao foi preenchida
If Empty( oModel:GetModel( 'CQQMASTER' ):GetValue("CQQ_DESC") )
	
	Help( , ,"CQRLPRE", ,STR0017,1,0,,,,,,{ STR0018 })	   //"Descricao do registro em branco." //"Preecnha a descricao do registro."
	If !IsBlind()
		MSGINFO(STR0019, STR0028 )	   //"CQRLPRE - Descricao do registro em branco. -> Preecnha a descricao do registro."  ## "Atencao"
	EndIf
	lRet := .F.
	
ElseIf Empty( oModel:GetModel( 'CQQMASTER' ):GetValue("CQQ_DTINI") )
	
	Help( , ,"CQRLPRE", ,STR0020,1,0,,,,,,{ STR0021 })	   //"Data inicial não informada." //"Preecnha a data inicial."
	If !IsBlind()
		MSGINFO(STR0022, STR0028 )	   //"CQRLPRE - Data inicial não informada.Preecnha a data inicial."  ## "Atencao"
	EndIf

	lRet := .F.

ElseIf Empty( oModel:GetModel( 'CQQMASTER' ):GetValue("CQQ_DTFIM") )
	
	Help( , ,"CQRLPRE", ,STR0023,1,0,,,,,,{ STR0024 })	   //"Data final não informada." //"Preecnha a data final."
	If !IsBlind()
		MSGINFO(STR0025, STR0028 )	   //"CQRLPRE - Data final não informada.-> Preecnha a data final."  ## "Atencao"
	EndIf
	lRet := .F.

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CQSLPOS
Validação sobre o preenchimento do Neto quando o filho estiver 
preenchido

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQSLPOS()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

//----------------------------------------
// Valida se o bloco K110 esta preenchido
//----------------------------------------
If oModel:GetModel( 'CQSDETAIL' ):IsEmpty()
	Help( , ,"CQSLPOS", ,STR0026,1,0,,,,,,{ STR0027 })	 //"Cadastro do bloco K100 não preenchido!" ###  //"Cadastro do bloco K110 não preenchido!" //"Para solucionar efetue o cadastro dos registros referente ao bloco K110"
																																											    //"Para solucionar efetue o cadastro dos registros referente ao bloco K100"                    
	lRet := .F.
EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} CQTPosVld
Pós-validações do submodelo CQS

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------
Static Function CQTPosVld()
Local lRet			:= .T.
Local oModCQT     := FWModelActive()
Local nOperation	:= oModCQT:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE 
	If oModCQT:GetModel( 'CQSDETAIL' ):IsEmpty()
		oModCQT:SetValue("CQT_IDBLK", CQS->CQS_IDBLK )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB420INI
Inicializador Padrao dos submodelo CQR /CQS / CQT 
//EM DESUSO POIS O RELACIONAMENTO DO MODEL AUTOMATICAMENTE CONTEMPLA ESSES CAMPOS NA INCLUSAO E ALTERACAO
@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Function CTB420INI(cCampo)
Local oModel	:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local cRetorno := ""

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE 

	If cCampo $ 'CQR_IDBLK|CQS_IDBLK|CQT_IDBLK'
		cRetorno := oModel:GetValue('CQQMASTER','CQQ_IDBLK')
	EndIf

	If cCampo $ 'CQS_CODEMP|CQT_CODEMP'
		cRetorno := oModel:GetValue('CQRDETAIL','CQR_CODEMP')
	EndIf

	If cCampo $ 'CQT_CODEVE'
		cRetorno := oModel:GetValue('CQSDETAIL','CQS_CODEVE')
	EndIf

EndIf

Return(cRetorno)                                                                                                          



//-------------------------------------------------------------------
/*/{Protheus.doc} CQTPRECD
Desabilita a inclusao/alteracao quando pressionado acoes relacionadas - Reg. K115 Emp.Evento 

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------

Static function CQTPRECD(oView)
Local nOperation	:= oView:GetOperation()

If OVIEW:GetBrowseOpc() == 5  //acoes relacionadas K115
	If nOperation == MODEL_OPERATION_UPDATE
	 	//K115 somente deve permitir editar a grade inferior e model esta modo de alteracao
		oView:SetOnlyView("VIEW_CQQ")			
		If oView:IsActive()
			oView:Refresh("VIEW_CQQ")
		EndIf

		oView:SetViewProperty("VIEW_CQR", "ONLYVIEW") 
		oView:SetNoInsertLine("VIEW_CQR")


		oView:SetViewProperty("VIEW_CQS", "ONLYVIEW")
		oView:SetNoInsertLine("VIEW_CQS")
		
	EndIf
Else
	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE  
	
		oView:HideFolder("REGK115",1,2)
		
	EndIf
	 
EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} CT420PEREV
Desabilita a inclusao/alteracao quando pressionado acoes relacionadas - Reg. K115 Emp.Evento se evento = Nao ou evento nao preenchido

@author TOTVS
@since 13/03/2018
@version P12.1.17
/*/
//-------------------------------------------------------------------


Function CT420PEREV()

Return( (!EMPTY(FwFldGet("CQS_CODEVE"))) .And. FwFldGet("CQR_EVENTO")=="1"  )

