#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CRMA190.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} Conexoes
Realiza Conexoes entre as entidades

@author Paulo Figueira
@since 12/02/14
@version P12
/*/
//-------------------------------------------------------------------
Function CRMA190(cAlias)

Static cAliasCor  := "" // Alias da entidade Selecionada

Local cEntida    	:= Alias()
Local oBrowse    	:= Nil
Local aChavEnt   	:= {}
Local nRecno		:= 0
Local aColCnx		:= CRMA190Col()

Private aRotina   := MenuDef()

Default cAlias    := ""

cAliasCor := IIF(!Empty(cAlias),cAlias,cEntida)//verificando a qual deve ser a origem do alias

nRecno		:=	(cAliasCor)->(Recno())// Recno da entidade Selecionada
aChavEnt 	:= CRMA090Chav( cAliasCor, nRecno ) //Retorna a entidade e o x2_unico do registro selecionado 

oBrowse := FWMBrowse():New()
oBrowse:SetCanSaveArea(.T.) 
oBrowse:SetAlias('AO7')
oBrowse:SetOnlyFields({"AO7_FILIAL"})
oBrowse:SetFields(aColCnx)
oBrowse:SetFilterDefault("AO7_FILIAL == '"+xFilial("AO7")+"' .AND. AO7_ENTTOR == '"+aChavEnt[1]+"' .AND. AO7_CHVTOR == '"+aChavEnt[2]+"'")
oBrowse:SetAttach(.T.) //Habilita as visões do Browse
oBrowse:SetTotalDefault('AO7_FILIAL','COUNT',STR0010) // "Total de Registros"
oBrowse:SetMainProc("CRMA190") 
oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação

@return   	aRotina - Array das operações

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION 'VIEWDEF.CRMA190'		OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0008 	ACTION 'CRMA190CON' 			OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.CRMA190' 	OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0004 	ACTION 'VIEWDEF.CRMA190' 	OPERATION 5 ACCESS 0 //Desconectar

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Modelo de dados (Regra de Negocio)

@return   	oModel - Objeto do modelo

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruAO7 	 := FWFormStruct( 1, 'AO7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	 := Nil
Local bCommit	 := {|oModel| CRM190Cmt(oModel) }

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('CRMA190',,  /*bPosValidacao*/,bCommit, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'AO7MASTER', /*cOwner*/, oStruAO7, /*bPreValidacao*/, /*bPosValidacao*/, /* bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Interface de interacao com o Modelo de Dados (Model)

@return   	oView - Objeto da View

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   	:= FWLoadModel( 'CRMA190' )
Local oStruAO7 	:= FWFormStruct( 2, 'AO7' )
Local nX		:= 0
Local oView		:= Nil

oStruAO7:RemoveField("AO7_CODLNK")

// Crio os Agrupamentos de Campos
 oStruAO7:AddGroup( 'GRUPO1', STR0005, '', 2 ) 
 oStruAO7:AddGroup( 'GRUPO2', STR0006, '', 2 )

 //Altero propriedades dos campos da estrutura, no caso colocando cada campo no seu grupo (grupo1=cabeçalho e grupo2=itens)
For nX := 1 To Len(oStruAO7:aFields) // Campos da tabela AO7

	If oStruAO7:aFields[nX][VIEWS_VIEW_ID] $ "AO7_FILIAL|AO7_ENTCNA|AO7_DENTCN|AO7_CHVECN|AO7_DSPECN|AO7_FCONEX|AO7_DCONEX|AO7_OBSCON|AO7_MSBLQL"
		oStruAO7:SetProperty( oStruAO7:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' ) // Conectar a
	Else
		oStruAO7:SetProperty( oStruAO7:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO2' ) // Conectar de
	EndIf

Next nX
  
// Cria o objeto de View
oView := FWFormView():New()
oView:SetContinuousForm()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_AO7', oStruAO7, 'AO7MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

oView:SetCloseOnOk({|| .T.} )
 
Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} Crm190TEnt()

Gatilho da descrição da entidade

@Return   	cDescEnt

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRM190TEnt()

Local cDescEnt		:= ""

If	GetRpoRelease() >= "12.1.027"
	cDescEnt := FwSX2Util():GetX2Name(FwFldGet("AO7_ENTTOR")/*cAlias*/, /*lSeekByFile*/)
Else
	cDescEnt := Posicione("SX2",1,FwFldGet("AO7_ENTTOR"),"X2_NOME")
EndIf
Return AllTrim(cDescEnt)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA190GSX2()

Carrega o SX2 do Alias passado por parâmetro

@Return   	aRet - array contendo:
			[1] - X2_UNICO  - CHAVE UNICA
			[2] - cDisplay  - X2_DYSPLAY
			[3] - X2_SYSOBJ - NOME DA ROTINA

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function CRMA190GSX2(cAliasEnt)

Local aArea       := {}
Local aAreaSX2    := {}
Local aSX2Info    := {}
Local aRet        := {}
Local cUnico      := ""
Local cDisplay    := ""
Local cSysObj     := ""

If ! Empty(cAliasEnt)
	If	GetRpoRelease() >= "12.1.027"
		aSX2Info    := FwSX2Util():GetSX2Data(cAliasEnt /*cAlias*/, {"X2_UNICO","X2_DISPLAY","X2_SYSOBJ"} /*aFields*/, /*lQuery*/)
		cUnico		:= AllTrim(aSX2Info[01,02])
		cDisplay	:= AllTrim(aSX2Info[02,02])
		cSysObj		:= AllTrim(aSX2Info[03,02])
		If ! Empty(cUnico) .AND. ! Empty(cDisplay)
			cDisplay := UpStrTran(cDisplay, "+", "+' | '+", 1)	//Separa os campos do X2_DISPLAY por pipes
			aRet     := {cUnico, cDisplay, cSysObj}
		EndIf
	Else
		aArea       := GetArea()
		aAreaSX2    := SX2->(GetArea())
		SX2->(DbSetOrder(1))
		If SX2->(DbSeek(cAliasEnt))
			cUnico		:= AllTrim(SX2->X2_UNICO)
			cDisplay	:= AllTrim(SX2->X2_DISPLAY)
			cSysObj		:= AllTrim(SX2->X2_SYSOBJ)
			IF	! Empty(cUnico) .AND. ! Empty(cDisplay)
				cDisplay	:= UpStrTran(cDisplay, "+", "+' | '+", 1)	//Separa os campos do X2_DISPLAY por pipes
				aRet		:= {cUnico, cDisplay, cSysObj}
			EndIf
		EndIf
		RestArea(aAreaSX2)
		RestArea(aArea)
		aSize(aAreaSX2, 0)
		aSize(aArea, 0)
	EndIf
EndIf
FreeObj(aSX2Info)
Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM190Disp(cTipoCnx,lIniBrowse)

Cahamda do Inicializador padrão ou inicializador padrão dos campos AO7_DSPECN e 
AO7_DCNTOR, para gatilhar a descrição dos mesmos recenbendo o tipo de conexão "CNX_A"
ou "CNX_D"
		cTipoCnx = "CNX_A" - Descrição do campo AO7_DSPECN
		cTipoCnx = "CNX_D" - Descrição do campo AO7_DCNTOR
		lIniBrowse = .T. - Chamada do inicializador do Browse
		lIniBrowse = .F. - Chamada do inicializador Padrão

@Return   	cDscDisp - X2_DISPLAY do Alias 

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRM190Disp(cTipoCnx,lIniBrowse)
Local cDscDisp	 		:= ""
Local cAlias	 		:= ""
Local cChave	 		:= " 
Local aSX2 	 		:= {}

Default cTipoCnx 		:= ""
Default lIniBrowse 	:= .F.

If !Empty(cTipoCnx) 
	If cTipoCnx == "CNX_A" .And. !lIniBrowse
		cAlias	 := FwFldGet("AO7_ENTCNA") 
		cChave	 := FwFldGet("AO7_CHVECN")  
	ElseIf cTipoCnx == "CNX_A" .And. lIniBrowse
		cAlias	 := AO7->AO7_ENTCNA 
		cChave	 := AO7->AO7_CHVECN
	ElseIf cTipoCnx == "CNX_D" .And. !lIniBrowse
		cAlias	 := FwFldGet("AO7_ENTTOR") 
		cChave	 := FwFldGet("AO7_CHVTOR") 
	ElseIf cTipoCnx == "CNX_D" .And. lIniBrowse
		cAlias	 :=  AO7->AO7_ENTTOR 
		cChave	 :=  AO7->AO7_CHVTOR 	 	
	EndIf
	
	aSX2 := CRMA190GSX2(cAlias)
	If Len(aSX2) > 0
		cDisplay := CRMA190GSX2(cAlias)[2]
		DbSelectArea(cAlias) 
		DbSetOrder(1)
		If DbSeek(Rtrim(cChave))
			cDscDisp := (cAlias)->&(cDisplay)
		EndIf
	EndIf
EndIf
Return(cDscDisp)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Crm190Chave()

Retorna a chave do display da entidade que foi selecionada

@Return   	cEntidade

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRM190Chave()

Local aSX2 := CRMA190GSX2(cAliasCor)                                                                                   

cChave := (cAliasCor)->&(aSX2[1])                                                                                     
                                                               
Return(cChave)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Crm190Ent()

Gatilho da descrição do tipo da entidade chamada da consulta especifica ENTCNX 
do campo AO7_CHVECN 

@Return   	lRetorno

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRM190Ent()

Local aArea	 	 := GetArea()
Local oModel	 := FwModelActive()
Local oMdlAO7	 := oModel:GetModel("AO7MASTER")
Local cAlias	 := oMdlAO7:GetValue("AO7_ENTCNA")  
Local aSX2		 := {}
Local lRetorno 	 := .F. 


Static cChvEnt := "" 

If !Empty(cAlias) 
	If Conpad1(,,,cAlias)
		lRetorno := .T.
		aSX2 := CRMA190GSX2(cAlias) 
		cChvEnt  := (cAlias)->&(aSX2[1])
	EndIf
EndIf

RestArea(aArea)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM190ChvCnx()

CHave de conexão 

@Return   	cChvEnt - Retorno da consulta especifica ENTCNX do campo AO7_CHVECN 

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRM190ChvCnx()
Return(cChvEnt) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA190Cor()

Função chamada do gatilho do campo AO7_FCONEX para preenchimento automatico da 
função correspondente(AO7_FUNCOR) caso exista apenas uma função correspondente.

@Return   	cFunCorres - Código da Função Correspondente

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA190Cor()

Local aArea			:= GetArea()
Local cFunCorres	:= ""
Local aFunCor		:= {}
Local oView 		:= FWViewActive()

AO8->(DbSetOrder(1))
cCodPai := FwFldGet("AO7_FCONEX" )

DBSelectArea("AOA")
AOA->(DBSetOrder(1)) //AO8_FILIAL + AO8_CODFUN + AOA_CDFUNC
If DbSeek(xFilial("AOA")+ cCodPai)
	While !AOA->(Eof()).And. cCodPai == AOA->AOA_CODFUN
		aAdd(aFunCor,{AOA->AOA_CDFUNC})	
		AOA->(DbSkip())
	EndDo
	//Caso exista apenas um filho gatilha automaticamente a função correspondente
	If Len(aFunCor) == 1
		cFunCorres := aFunCor[1][1]
	Else
		cFunCorres := ""
		oView:oModel:SetValue('AO7MASTER', "AO7_DSCFCO", "")
	EndIf
EndIf

RestArea(aArea)

Return cFunCorres
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA190Alias()

Retorna o Alias da entidade
Chamado pelo ini padrão do campo AO7_ENTTOR

@Return   	cAliasCor - Alias Corrente

@author	Paulo Figueira
@since		13/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA190Alias()
Return(cAliasCor)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA190Con()

Função chamada da rotina de menu das rotinas de prospect, suspec, cliente....

@Return   	Nil

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA190Con(cAlias)
	
Local cEntida := Alias()	

Default cAlias := ""

If !IsInCallStack("CRMA190")
	cAliasCor := IIF(!Empty(cAlias),cAlias,cEntida)//verificando a qual deve ser a origem do alias 	
EndIf

FWExecView(STR0009 ,"VIEWDEF.CRMA190",3,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM190VCda

Valida o campo AO7_ENTCNA.

@sample	CRM190VCda()

@param		Nenhum
			
@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		17/09/2014
@version	P12          
/*/
//-----------------------------------------------------------------------------
Function CRM190VCda()

Local oModel 		:= FwModelActive()
Local nFilSize	:= FWSizeFilial()
Local oMdlAO7		:= oModel:GetModel("AO7MASTER")
Local cEntCna		:= oMdlAO7:GetValue("AO7_ENTCNA")
Local cChvEcn		:= oMdlAO7:GetValue("AO7_CHVECN")
Local cEntTor		:= oMdlAO7:GetValue("AO7_ENTTOR")
Local cChvTor		:= oMdlAO7:GetValue("AO7_CHVTOR")
Local cChvEcnSF	:= AllTrim(SubStr(cChvEcn,(nFilSize+1),Len(cChvEcn)))
Local lRetorno	:= .T.

If !Empty(cEntCna)
	lRetorno := ( ExistCpo(cEntCna,cChvEcnSF,1) .AND. CRMXLibReg(cEntCna,cChvEcnSF,1) )
Else	
	lRetorno := .F.
	Help(" ",1,"REGNOIS") 	
EndIf

If lRetorno 
	If ( cEntCna+cChvEcn ) == ( cEntTor+cChvTor )
		lRetorno := .F. 
		Help(" ",1,"CRMCONEX01") 
	EndIf
EndIf

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA190Col

Retorna as colunas que serao apresentadas no Browse.

@sample	CRMA190Col

@param		Nenhum
			
@return	ExpA - Colunas do Browse.

@author	Anderson Silva
@since		17/09/2014
@version	P12          
/*/
//-----------------------------------------------------------------------------
Static Function CRMA190Col()

Local aAreaSX3	:= SX3->(GetArea())
Local aColumns 	:= {}
Local aCampos	:= {}
Local nX		:= 0
Local cInitBrw	:= ""
Local cObfNCli	:= IIF(FATPDIsObfuscate("A1_NOME",,.T.),FATPDObfuscate("CUSTOMMER","A1_NOME",,.T.),"")  

aAdd(aCampos,{"AO7_DSPECN",STR0011}) //"Conectado a:"
aAdd(aCampos,{"AO7_DCONEX",STR0012}) //"Função"

aAdd(aCampos,{"AO7_DCNTOR",STR0013})  //"Conectado de:"
aAdd(aCampos,{"AO7_DSCFCO",STR0012}) //"Função"

DbSelectArea("SX3")
DbSetOrder(2) //X3_CAMPO

For nX := 1 To Len(aCampos)
	If SX3->(DbSeek(aCampos[nX][1]))
		If aCampos[nX,1] $ "AO7_DSPECN|AO7_DCNTOR"
			cInitBrw := "IIF(Empty('" + cObfNCli + "')," + AllTrim(SX3->X3_INIBRW) + ",'" + cObfNCli + "')"
		else
			cInitBrw := AllTrim(SX3->X3_INIBRW)
		EndIf
		aAdd(aColumns,{ aCampos[nX][2] 					,;
						  &("{|| " + cInitBrw + " }")	,;
						  SX3->X3_TIPO					,;
						  SX3->X3_PICTURE				,;
						  0								,;
						  SX3->X3_TAMANHO				,;
						  SX3->X3_DECIMAL })
	EndIf
Next nX  

RestArea(aAreaSX3)  

Return(aColumns)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM190Cmt

Bloco de Commit de Conexoes.

@sample	CRM190Cmt(oModel)

@param		ExpO1 - Model de Conexoes
			
@return	ExpL - Verdadeiro

@author	Anderson Silva
@since		17/09/2014
@version	P12          
/*/
//-----------------------------------------------------------------------------
Static Function CRM190Cmt(oModel)

Local cChvCnx  	:= ""
Local nOperation	:= oModel:GetOperation()

// Guarda a chave da conexao para atualizar o link. 
If ( nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE )
	cChvCnx := AO7->AO7_CODLNK+AO7->AO7_ENTTOR+AO7->AO7_CHVTOR 
EndIf 

FWFormCommit(oModel,Nil,{|oModel,cId,cAlias| CRM190CmtAft(oModel,cId,cAlias,cChvCnx) })

Return(.T.)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM190CmtAft

Bloco de transacao durante o commit do model. 

@sample	CRM190CmtAft(oModel,cId,cAlias,cChave))

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias
			ExpC4 - Chave da Conexao

@return	ExpL  - Verdadeiro

@author	Anderson Silva
@since		17/09/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRM190CmtAft(oModel,cId,cAlias,cChvCnx)

Local aAreaAO7	:= AO7->(GetArea())
Local nOperation	:= oModel:GetOperation()
Local oStruAO7	:= Nil
Local lInclui		:= .F.
Local nX			:= 0
Local lRetorno 	:= .T.

If cId == "AO7MASTER"
	
	oStruAO7 := oModel:GetStruct()
	
	DbSelectArea("AO7")
	AO7->(DbSetOrder(5)) //AO7_FILIAL+AO7_CODLNK+AO7_ENTCNA+AO7_CHVECN      
	
	If nOperation == MODEL_OPERATION_INSERT
		lInclui := .T.
	Else
		lRetorno := DbSeek(xFilial("AO7")+cChvCnx)
	EndIf
	
	If lRetorno 
	
		If ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE )
			
			RecLock("AO7",lInclui)
				
				AO7->AO7_FILIAL	:= xFilial("AO7")
				AO7->AO7_ENTCNA	:= oModel:GetValue("AO7_ENTTOR")
				AO7->AO7_CHVECN	:= oModel:GetValue("AO7_CHVTOR")
				AO7->AO7_FCONEX 	:= oModel:GetValue("AO7_FUNCOR")
				
				AO7->AO7_ENTTOR	:= oModel:GetValue("AO7_ENTCNA")
				AO7->AO7_CHVTOR	:= oModel:GetValue("AO7_CHVECN")
				AO7->AO7_FUNCOR	:= oModel:GetValue("AO7_FCONEX")
				
				
				For nX := 1 To Len(oStruAO7:aFields) // Campos da tabela AO7
					If !( oStruAO7:aFields[nX,MODEL_FIELD_IDFIELD] + "|" $ "AO7_FILIAL|AO7_ENTCNA|AO7_CHVECN|AO7_FCONEX|AO7_ENTTOR|AO7_CHVTOR|AO7_FUNCOR|" )
						FieldPut(FieldPos(oStruAO7:aFields[nX][MODEL_FIELD_IDFIELD]),oModel:GetValue(oStruAO7:aFields[nX][MODEL_FIELD_IDFIELD]))
					EndIf
				Next nX
				
			AO7->(MsUnlock())
		Else
			RecLock("AO7",lInclui)
			AO7->(DbDelete())
			AO7->(MsUnlock())
		EndIf
	
	EndIf
	
EndIf

RestArea(aAreaAO7)

Return(.T.)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive