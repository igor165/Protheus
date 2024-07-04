#INCLUDE "JURA160.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"
				
Static _cTipo := Nil
Static _cPesq := Nil						

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA160
Campos Configuração Grid Pesquisa

@param 	cPesq  Código da pesquisa, tabela 
@param 	cTipo  Tipo da pesquisa. Processo, Andamento, Garantia ou Follow Up. //1=Processo 2=Follow-Up 3=Garantias 4=Andamento 5=Despesa

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA160(cPesq, cTipo)
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NYE" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NYE" )
JurSetBSize( oBrowse )

J160setTp(cTipo)
J160setPesq(cPesq)

oBrowse:SetFilterDefault(" NYE_CPESQ == '" + cPesq + "'")
 
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA160", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA160", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA160", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA160", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA160", 0, 8, 0, NIL } ) // "Imprimir"
aAdd( aRotina, { STR0013, "JA160CONFG"     , 0, 3, 0, NIL } ) // "Config. Inicial"
aAdd( aRotina, { STR0015, "JA160Ordem"     , 0, 3, 0, NIL } ) // "Ordem Grid"
                                              	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Campos Exportação Personalizada

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel( "JURA160" )
Local oStructNYE
Local oStructNYF
Local oStructNYG
Local oView

oStructNYE := FWFormStruct( 2, "NYE" )
oStructNYF := FWFormStruct( 2, "NYF" )
oStructNYG := FWFormStruct( 2, "NYG" )

oStructNYF:RemoveField( "NYF_CTABPR" )
oStructNYG:RemoveField( "NYG_CTABRE" )
oStructNYG:RemoveField( "NYG_CTABPR" )

JurSetAgrp( 'NYE',, oStructNYE )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA160_TABELA", oStructNYE, "NYEMASTER"  )   
oView:AddGrid ( "JURA160_RELACI", oStructNYF, "NYFDETAIL"  )
oView:AddGrid ( "JURA160_CAMPOS", oStructNYG, "NYGDETAIL"  )
                                                   
oView:CreateHorizontalBox( "FORMTABELA" , 15 )
oView:CreateHorizontalBox( "FORMRELACI" , 45 )
oView:CreateHorizontalBox( "FORMCAMPOS" , 40 )

oView:SetOwnerView( "NYEMASTER" , "FORMTABELA" )
oView:SetOwnerView( "NYFDETAIL" , "FORMRELACI" )
oView:SetOwnerView( "NYGDETAIL" , "FORMCAMPOS" )

oView:AddIncrementField( "NYFDETAIL" , "NYF_COD" )
oView:AddIncrementField( "NYGDETAIL" , "NYG_COD" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

/*<- Fecha a tela apos o cadastro para não chamar o 
//<- "oModel:SetVldActivate" mais de uma vez -> */
oView:bCloseOnOK := {||.T.} 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Campos Exportação Personalizada

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

@obs NYGMASTER - Dados dos Campos Exportação Personalizada

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNYE := NIL
Local oStructNYF := NIL
Local oStructNYG := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNYE := FWFormStruct(1,"NYE")
oStructNYF := FWFormStruct(1,"NYF")
oStructNYG := FWFormStruct(1,"NYG")

oStructNYF:RemoveField( "NYF_CTABPR" )
oStructNYG:RemoveField( "NYG_CTABRE" )
oStructNYG:RemoveField( "NYG_CTABPR" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA160", /*Pre-Validacao*/, {|oX|JA160TOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NYEMASTER", /*cOwner*/, oStructNYE,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NYEMASTER" ):SetDescription( STR0008 ) 

oModel:AddGrid( "NYFDETAIL", "NYEMASTER" /*cOwner*/, oStructNYF, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NYFDETAIL"  ):SetDescription( STR0009 )
oModel:SetRelation( "NYFDETAIL", { { "NYF_FILIAL", "XFILIAL('NYE')" }, { "NYF_CTABPR", "NYE_COD" } }, NYF->( IndexKey( 2 ) ) )

oModel:AddGrid( "NYGDETAIL", "NYFDETAIL" /*cOwner*/, oStructNYG, /*bLinePre*/, {|oX|J160VLDNYG(oX)}/*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:SetRelation( "NYGDETAIL", { { "NYG_FILIAL", "XFILIAL('NYF')" }, { "NYG_CTABPR", "NYE_COD" }, { "NYG_CTABRE", "NYF_COD" } }, NYG->( IndexKey( 1 ) ) ) 

oModel:GetModel( "NYFDETAIL" ):SetUniqueLine( { "NYF_TABELA","NYF_APELID" } )
oModel:GetModel( "NYGDETAIL" ):SetUniqueLine( { "NYG_CAMPO" } )
                                                                  
JurSetRules( oModel, "NYEMASTER",, 'NYE' )
JurSetRules( oModel, "NYFDETAIL",, 'NYF' )
JurSetRules( oModel, "NYGDETAIL",, 'NYG' )

//<-- Pre validação da quantidade de assuntos juridicos
oModel:SetVldActivate( {|oX| JA160VlMsg(oX)} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA160TOK(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local nOpc     := oModel:GetOperation() 

If nOpc == 3 .Or. nOpc == 4
	
	If lRet
		lRet:= JA160VFILT()
	EndIf
	
	If lRet
		lRet := J160VLVIRT( oModel ) //valida os campos virtuais incluídos.
	Endif
		
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160NCAMP
Retorna os campos para não aparecer na consulta padrão

@Return cRet	 	Filtro de campos

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA160NCAMP()
Return " .AND. !X3_CAMPO $ ('"+CAMPOSNAOCONFIG+"')"  

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160VLDCP
Verifica se o campo digitado é permitido a configuração

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA160VLDCP()
Local lRet := .T.

If !Empty (FwFldGet('NYG_CAMPO'))
	lRet := ! (FwFldGet('NYG_CAMPO') $ "('"+CAMPOSNAOCONFIG+"')")
EndIf

If !lRet .And. !Empty (FwFldGet('NYG_CAMPOT'))
	lRet := ! (FwFldGet('NYG_CAMPOT') $ "('"+CAMPOSNAOCONFIG+"')")
EndIf

If !lRet
	JurMsgErro(STR0012)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160VFILT
Valida se o campo de filtro possui os campos com apelido

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Static Function JA160VFILT()
Local lRet       := .T.
Local aArea      := GetArea()
Local oModel     := FWModelActive()
Local oModelNYF  := oModel:GetModel('NYFDETAIL')
Local nCt        := 0
Local aApelid    := {}
Local aCampos    := {}

For nCt := 1 To oModelNYF:GetQtdLine()
	
	oModelNYF:GoLine( nCt )
	
	If !oModelNYF:IsDeleted()
				
		If !Empty( oModelNYF:GetValue('NYF_FILTRO') )
			
			aApelid:= JurAtAll(AllTrim( FwFldGet('NYF_APELID') )+'.', AllTrim( FwFldGet('NYF_FILTRO') ))
			
			aCampos:= JurAtAll(PrefixoCpo( FwFldGet('NYF_TABELA') )+'_', AllTrim( FwFldGet('NYF_FILTRO') ))
			
			If ( Len(aCampos) == 0 .And. Len(aApelid) == 0 ) .Or. ( Len(aCampos) <> Len(aApelid) )

				lRet := .F.
				JurMsgErro(STR0010)
				Exit

			EndIf
			
		EndIf
		
	EndIf
	
Next

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160CONFG(cPesq, cTipo)
Realiza a carga inicial da configuração de campos

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA160CONFG(cPesq, cTipo)
Local lRet     := .T.
Local oModel   := ModelDef()
Local aArea    := GetArea()
Local aAreaNYE := NYE->( GetArea() )
Local cAssJur

Default cPesq := ""
Default cTipo := ""

If IsIncallStack("J160CarIni")
	J160setTp(cTipo)
	J160setPesq(cPesq)
EndIf

NYE->( dbSetOrder(1) )
NYE->( dbSeek( J160getPesq() ) )

If NYE->(EOF())

	cAssJur := JA160AssJur()

	//Valida se existe apenas um assunto jurídico vinculado.
	If !(cAssJur $ "-1/0")
	
		//1=Processo 2=Follow-Up 3=Garantias 4=Andamento 5=Despesa
		
		If J160getTp()=="1"
			lRet:= JA160NSZ(oModel, cAssJur)
		ElseIf J160getTp()=="2"
			lRet:= JA160NTA(oModel, cAssJur)
		ElseIf J160getTp()=="3"
			lRet:= JA160NT2(oModel)
		ElseIf J160getTp()=="4"
			lRet:= JA160NT4(oModel)
		ElseIf J160getTp()=="5"
			lRet:= JA160NT3(oModel)
		ElseIf J160getTp()=="6"
			lRet:= JA160O0M(oModel)
		Endif
		
	Else
		//Exibe mensagem de erro pois o assunto está vinculado a mais de um assunto jurídico.
		If cAssJur == "-1"
			JurMsgErro(STR0020) //"Existe mais de um assunto jurídico vinculado"
		Else
			JurMsgErro(STR0021) //"Você deve vincular ao menos um assunto jurídico para poder fazer a configuração de grid."
		Endif
	EndIf

Else
	lRet := .F.
	JurMsgErro( STR0016 )	
EndIf

RestArea(aAreaNYE)
RestArea(aArea)

Return lRet   

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160NSZ
Inclusão de configuração de processo

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Static Function JA160NSZ(oModel, cAssJur)
Local nI 
Local lRet      := .T.
Local aNYG      := {}
Local oModelNYF := oModel:GetModel('NYFDETAIL')
Local oModelNYG := oModel:GetModel('NYGDETAIL')
Local nNYF := 1

oModel:SetOperation( 3 )
If  !( oModel:Activate() )
    Return .F.
EndIf    

//Configuração para Processo     
If !oModel:SetValue('NYEMASTER','NYE_TABELA','NSZ') .Or. !oModel:SetValue('NYEMASTER','NYE_DTABEL', JA023TIT('NYE_TABELA')) .Or. !oModel:SetValue('NYEMASTER','NYE_APELID','NSZ001') .Or.;
 !oModel:SetValue('NYEMASTER','NYE_CPESQ',J160getPesq())
	lRet := .F.
	JurMsgErro( STR0014 )
EndIf

//Campos por tipo de assunto jurídico pai.
If cAssJur $ "001/002/003/004" //Contencioso/Criminal/Adm/Cade

	//Campos NSZ
	If lRet
		nNYF := 1
		//oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_CCLIEN') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_CCLIEN')) 
			lRet := .F.                                                                        
			JurMsgErro( STR0014 )	
		Else
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_COD',JA160X3Des('NSZ_COD')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			aAdd( aNYG, {'NSZ_SITUAC',JA160X3Des('NSZ_SITUAC')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
		
		//Instância principal
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NUQ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NUQ001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO',"NUQ001.NUQ_INSATU = '1'") .Or. !oModelNYG:LoadValue('NYG_CAMPO' ,'NUQ_NUMPRO') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NUQ_NUMPRO')) 
				lRet := .F.                                                                        
				JurMsgErro( STR0014 )	
			EndIf
		Endif
		
		//Clientes
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','SA1') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','SA1001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'A1_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('A1_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Área
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NRB') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NRB001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'NRB_DESC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NRB_DESC'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Participante 1 - Coordenador
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','RD0') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','RD0001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CPART1') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'RD0_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('RD0_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf

	EndIf
	//Fim - Contencioso/Criminal/Adm/Cade

ElseIf cAssJur $ "005" //Consultivo 

	//Campos NSZ
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_COD')) 
			lRet := .F.
			JurMsgErro( STR0014 )
		Else
			aAdd( aNYG, {'NSZ_NUMREG',JA160X3Des('NSZ_NUMREG')} )
			aAdd( aNYG, {'NSZ_CCLIEN',JA160X3Des('NSZ_CCLIEN')} )
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			aAdd( aNYG, {'NSZ_SITUAC',JA160X3Des('NSZ_SITUAC')} )
			aAdd( aNYG, {'NSZ_CDPSOL',JA160X3Des('NSZ_CDPSOL')} )
			
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
			
		//Clientes
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','SA1') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','SA1001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'A1_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('A1_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Participante 2 - Responsável
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','RD0') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','RD0001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CODRES') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'RD0_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('RD0_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	EndIf
	//Fim - Consultivo

ElseIf cAssJur $ "006/013" //Contratos|NIP 

	//Campos NSZ
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_COD')) 
			lRet := .F.
			JurMsgErro( STR0014 )	
		Else
			aAdd( aNYG, {'NSZ_NUMCON',JA160X3Des('NSZ_NUMCON')} )
			aAdd( aNYG, {'NSZ_CCLIEN',JA160X3Des('NSZ_CCLIEN')} )
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			aAdd( aNYG, {'NSZ_SITUAC',JA160X3Des('NSZ_SITUAC')} )
			aAdd( aNYG, {'NSZ_CDPSOL',JA160X3Des('NSZ_CDPSOL')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
			
		//Clientes
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','SA1') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','SA1001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'A1_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('A1_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Participante 2 - Responsável
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','RD0') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','RD0001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CODRES') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'RD0_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('RD0_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	EndIf
	//Fim - Contratos

ElseIf cAssJur $ "007/008" //Procurações/Societário 

	//Campos NSZ
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_COD')) 
			lRet := .F.
			JurMsgErro( STR0014 )	
		Else
			aAdd( aNYG, {'NSZ_CCLIEN',JA160X3Des('NSZ_CCLIEN')} )
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			aAdd( aNYG, {'NSZ_SITUAC',JA160X3Des('NSZ_SITUAC')} )
			aAdd( aNYG, {'NSZ_CDPSOL',JA160X3Des('NSZ_CDPSOL')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
			
		//Clientes
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','SA1') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','SA1001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'A1_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('A1_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Participante 2 - Responsável
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','RD0') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','RD0001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CODRES') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'RD0_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('RD0_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	EndIf
	//Fim - Procurações/Societário

ElseIf cAssJur $ "009" //Ofícios 

	//Campos NSZ
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_COD')) 
			lRet := .F.
			JurMsgErro( STR0014 )	
		Else
			aAdd( aNYG, {'NSZ_NUMREG',JA160X3Des('NSZ_NUMREG')} )
			aAdd( aNYG, {'NSZ_CCLIEN',JA160X3Des('NSZ_CCLIEN')} )
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			aAdd( aNYG, {'NSZ_SITUAC',JA160X3Des('NSZ_SITUAC')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
			
		//Clientes
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','SA1') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','SA1001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'A1_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('A1_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	//Participante 2 - Responsável
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','RD0') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','RD0001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CODRES') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'RD0_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('RD0_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	EndIf
	//Fim - Ofícios

ElseIf cAssJur $ "010" //Licitações 

	//Campos NSZ
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_COD')) 
			lRet := .F.                                                                        
			JurMsgErro( STR0014 )	
		Else
			aAdd( aNYG, {'NSZ_NUMLIC',JA160X3Des('NSZ_NUMLIC')} )
			aAdd( aNYG, {'NSZ_CCLIEN',JA160X3Des('NSZ_CCLIEN')} )
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			aAdd( aNYG, {'NSZ_SITUAC',JA160X3Des('NSZ_SITUAC')} )
			aAdd( aNYG, {'NSZ_CDPSOL',JA160X3Des('NSZ_CDPSOL')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
			
		//Clientes
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','SA1') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','SA1001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'A1_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('A1_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Modalidade
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NY4') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NY4001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'NY4_DESC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NY4_DESC'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Critério de Julgamento
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NY5') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NY5001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'NY5_DESC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NY5_DESC'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
		//Participante 2 - Responsável
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','RD0') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','RD0001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CODRES') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'RD0_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('RD0_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	EndIf
	//Fim - Licitações

ElseIf cAssJur $ "011" //Marcas e Patentes 

	//Campos NSZ
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_COD')) 
			lRet := .F.                                                                        
			JurMsgErro( STR0014 )	
		Else
			aAdd( aNYG, {'NSZ_NUMPED',JA160X3Des('NSZ_NUMPED')} )
			aAdd( aNYG, {'NSZ_CCLIEN',JA160X3Des('NSZ_CCLIEN')} )
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			aAdd( aNYG, {'NSZ_SITUAC',JA160X3Des('NSZ_SITUAC')} )
			aAdd( aNYG, {'NSZ_NOMEMA',JA160X3Des('NSZ_NOMEMA')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0014 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
			
		//Clientes
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','SA1') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','SA1001') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'A1_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('A1_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	//Participante 2 - Responsável
		If lRet
			oModelNYF:AddLine()
			If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','RD0') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','RD0001') .Or.;
				!oModelNYF:SetValue('NYF_FILTRO','RD0001.RD0_CODIGO = NSZ001.NSZ_CODRES') .Or.;
				!oModelNYG:LoadValue('NYG_CAMPO' ,'RD0_NOME') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('RD0_NOME'))
				lRet := .F.
				JurMsgErro( STR0014 )
			EndIf
		EndIf
		
	EndIf
	//Fim - Marcas e Patentes

Endif // Fim Execução

If lRet
		JA160Grava(oModel, lRet)
EndIf
	
oModel:DeActivate()	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160NTA
Inclusão de configuração de follow-up

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Static Function JA160NTA(oModel, cAssJur)
Local lRet := .T.
Local nI 
Local aNYG      := {}
Local oModelNYF := oModel:GetModel('NYFDETAIL')
Local oModelNYG := oModel:GetModel('NYGDETAIL')
Local nNYF := 1

oModel:SetOperation( 3 )
If  !( oModel:Activate() )
    Return .F.
EndIf    

//Configuração para Follow-up
If !oModel:SetValue('NYEMASTER','NYE_TABELA','NTA') .Or. !oModel:SetValue('NYEMASTER','NYE_DTABEL', JA023TIT('NYE_TABELA') ) .Or. !oModel:SetValue('NYEMASTER','NYE_APELID','NTA001') .Or.;
 !oModel:SetValue('NYEMASTER','NYE_CPESQ',J160getPesq())
	lRet := .F.
	JurMsgErro( STR0017 )
EndIf

//Campos NTA
If lRet
	If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NTA') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NTA001') .Or.;
		!oModelNYG:LoadValue('NYG_CAMPO' ,'NTA_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,"Código") 
		lRet := .F.                                                                        
		JurMsgErro( STR0017 )	
	Else
		aAdd( aNYG, {'NTA_CAJURI',JA160X3Des('NTA_CAJURI')} )
		aAdd( aNYG, {'NTA_DTFLWP',JA160X3Des('NTA_DTFLWP')} )
		aAdd( aNYG, {'NTA_HORA'  ,JA160X3Des('NTA_HORA')} )
		aAdd( aNYG, {'NTA_CTIPO' ,JA160X3Des('NTA_CTIPO')} )
		aAdd( aNYG, {'NTA_DTIPO' ,JA160X3Des('NTA_DTIPO')} )
		
		For nI := 1 To Len( aNYG )
			oModelNYG:AddLine()
			If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
				lRet := .F.
				JurMsgErro( STR0017 + ': '+aNYG[nI][1] )
				Exit
			EndIf
		Next
		
		aNYG := {}
	EndIf
Endif

//Resultado
If lRet
	oModelNYF:AddLine()
	If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NQN') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NQN001') .Or.;
		 !oModelNYG:LoadValue('NYG_CAMPO' ,'NQN_DESC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,"Resultado")
		lRet := .F.
		JurMsgErro( STR0017 )
	EndIf
EndIf

//Número do processo
If lRet
	oModelNYF:AddLine()
	If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
		 !oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_NUMPRO') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,"Número do processo")
		lRet := .F.
		JurMsgErro( STR0017 )
	EndIf
EndIf

If lRet
			JA160Grava(oModel, lRet)
EndIf	
	
oModel:DeActivate()
 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA160NT2
Inclusão de configuração de garantias

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Static Function JA160NT2(oModel)
Local lRet := .T.
Local nI 
Local aNYG      := {}
Local oModelNYF := oModel:GetModel('NYFDETAIL')
Local oModelNYG := oModel:GetModel('NYGDETAIL')
Local nNYF := 1

oModel:SetOperation( 3 )
If  !( oModel:Activate() )
    Return .F.
EndIf    

//Configuração para Garantias     
If !oModel:SetValue('NYEMASTER','NYE_TABELA','NT2') .Or. !oModel:SetValue('NYEMASTER','NYE_DTABEL', JA023TIT('NYE_TABELA') ) .Or. !oModel:SetValue('NYEMASTER','NYE_APELID','NT2001') .Or.;
 !oModel:SetValue('NYEMASTER','NYE_CPESQ',J160getPesq())
	lRet := .F.
	JurMsgErro( STR0019 )
EndIf

//Campos NT2
If lRet
	If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NT2') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NT2001') .Or.;
		!oModelNYG:LoadValue('NYG_CAMPO' ,'NT2_DATA') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NT2_DATA')) 
		lRet := .F.                                                                        
		JurMsgErro( STR0019 )	
	Else
		aAdd( aNYG, {'NT2_MOVFIN',JA160X3Des('NT2_MOVFIN')} )
		
		For nI := 1 To Len( aNYG )
			oModelNYG:AddLine()
			If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
				lRet := .F.
				JurMsgErro( STR0019 + ': '+aNYG[nI][1] )
				Exit
			EndIf
		Next
		
		aNYG := {}
	EndIf
Endif

//Tipo de Garantia/Alvará
If lRet
	oModelNYF:AddLine()
	If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NQW') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NQW001') .Or.;
		 !oModelNYG:LoadValue('NYG_CAMPO' ,'NQW_DESC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NQW_DESC'))
		lRet := .F.
		JurMsgErro( STR0019 )
	EndIf
EndIf

If lRet
			JA160Grava(oModel, lRet)
EndIf	
	
oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160NT4
Inclusão de configuração de andamento

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//-------------------------------------------------------------------               
Static Function JA160NT4(oModel)
Local lRet := .T.      
Local nI 
Local aNYG      := {}
Local oModelNYF := oModel:GetModel('NYFDETAIL')
Local oModelNYG := oModel:GetModel('NYGDETAIL')
Local nNYF := 1

oModel:SetOperation( 3 )
If ( lRet := oModel:Activate() )

	//Configuração para Andamentos
	If !oModel:SetValue('NYEMASTER','NYE_TABELA','NT4') .Or. !oModel:SetValue('NYEMASTER','NYE_DTABEL', JA023TIT('NYE_TABELA') ) .Or. !oModel:SetValue('NYEMASTER','NYE_APELID','NT4001') .Or.;
	 !oModel:SetValue('NYEMASTER','NYE_CPESQ',J160getPesq())
		lRet := .F.
		JurMsgErro( STR0018 )
	EndIf
	
	//Campos NT4
	If lRet
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NT4') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NT4001') .Or.;
			!oModelNYG:LoadValue('NYG_CAMPO' ,'NT4_DTANDA') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NT4_DTANDA')) 
			lRet := .F.                                                                        
			JurMsgErro( STR0018 )	
		Else
			aAdd( aNYG, {'NT4_PCLIEN',JA160X3Des('NT4_PCLIEN')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0018 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
	Endif
	
	//Fase
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NQG') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NQG001') .Or.;
			 !oModelNYG:LoadValue('NYG_CAMPO' ,'NQG_DESC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NQG_DESC'))
			lRet := .F.
			JurMsgErro( STR0018 )
		EndIf
	EndIf
	
	//Ato Processual
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NRO') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA'))  .Or. !oModelNYF:SetValue('NYF_APELID','NRO001') .Or.;
			 !oModelNYG:LoadValue('NYG_CAMPO' ,'NRO_DESC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NRO_DESC'))
			lRet := .F.
			JurMsgErro( STR0018 )
		EndIf
	EndIf
	
	If lRet
		JA160Grava(oModel, lRet)
	EndIf	
		
	oModel:DeActivate()
EndIf

Return lRet                    

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160NT3
Inclusão de configuração de despesas

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Reginaldo N Soares
@since 21/09/16
@version 1.0
/*/
//-------------------------------------------------------------------               
Static Function JA160NT3(oModel)
Local lRet := .T.      
Local nI 
Local aNYG      := {}
Local oModelNYF := oModel:GetModel('NYFDETAIL')
Local oModelNYG := oModel:GetModel('NYGDETAIL')
Local nNYF := 1

oModel:SetOperation( 3 )
If ( lRet := oModel:Activate() )

	//Configuração para Despesas
	If !oModel:SetValue('NYEMASTER','NYE_TABELA','NT3') .Or. !oModel:SetValue('NYEMASTER','NYE_DTABEL', JA023TIT('NYE_TABELA') ) .Or. !oModel:SetValue('NYEMASTER','NYE_APELID','NT3001') .Or.;
	 !oModel:SetValue('NYEMASTER','NYE_CPESQ',J160getPesq())
		lRet := .F.
		JurMsgErro( STR0032 )
	EndIf
	
	//Campos NSZ
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NSZ') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NSZ001') .Or.;
		   !oModelNYG:LoadValue('NYG_CAMPO' ,'NSZ_COD') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('NSZ_COD')) 
			lRet := .F.
			JurMsgErro( STR0032 )	
		Else
			aAdd( aNYG, {'NSZ_CCLIEN',JA160X3Des('NSZ_CCLIEN')} )
			aAdd( aNYG, {'NSZ_LCLIEN',JA160X3Des('NSZ_LCLIEN')} )
			aAdd( aNYG, {'NSZ_NUMCAS',JA160X3Des('NSZ_NUMCAS')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0032 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
	Endif

	//Campos NT3
	If lRet
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','NT3') .Or. !oModelNYF:SetValue('NYF_DTABEL', JA023TIT('NYF_TABELA')) .Or. !oModelNYF:SetValue('NYF_APELID','NT3001') 
			lRet := .F.
			JurMsgErro( STR0032 )	
		Else
			aAdd( aNYG, {'NT3_CTPDES',JA160X3Des('NT3_CTPDES')} )
			aAdd( aNYG, {'NT3_DTPDES',JA160X3Des('NT3_DTPDES')} )
			aAdd( aNYG, {'NT3_DATA'  ,JA160X3Des('NT3_DATA'  )} )
			aAdd( aNYG, {'NT3_VALOR' ,JA160X3Des('NT3_VALOR' )} )
			aAdd( aNYG, {'NT3_COD'   ,JA160X3Des('NT3_COD'   )} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0032 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
	Endif

	If lRet
		JA160Grava(oModel, lRet)
	EndIf	
		
	oModel:DeActivate()
EndIf

Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160O0M
Inclusão de configuração de despesas

@Param oModel		Model ativo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Reginaldo N Soares
@since 21/09/16
@version 1.0

/*/
//-------------------------------------------------------------------               
Static Function JA160O0M(oModel)
Local lRet := .T.      
Local nI 
Local aNYG      := {}
Local oModelNYF := oModel:GetModel('NYFDETAIL')
Local oModelNYG := oModel:GetModel('NYGDETAIL')
Local nNYF := 1

oModel:SetOperation( 3 )
If ( lRet := oModel:Activate() )

	//Configuração para Solic Documentos
	If !oModel:SetValue('NYEMASTER','NYE_TABELA','O0M') .Or. !oModel:SetValue('NYEMASTER','NYE_DTABEL', INFOSX2( FwFldGet('NYE_TABELA'), 'X2_NOME' ) ) .Or. !oModel:SetValue('NYEMASTER','NYE_APELID','O0M001') .Or.;
	 !oModel:SetValue('NYEMASTER','NYE_CPESQ',J160getPesq())
		lRet := .F.
		JurMsgErro( STR0032 )
	EndIf

	//Campos O0M
	If lRet
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','O0M') .Or. !oModelNYF:SetValue('NYF_DTABEL', INFOSX2( FwFldGet('NYF_TABELA'), 'X2_NOME' )) .Or. !oModelNYF:SetValue('NYF_APELID','O0M001') 
			lRet := .F.
			JurMsgErro( STR0032 )	
		Else
			aAdd( aNYG, {'O0M_CAJURI',JA160X3Des('O0M_CAJURI' )} )
			aAdd( aNYG, {'O0M_COD'   ,JA160X3Des('O0M_COD'   )} )
			aAdd( aNYG, {'O0M_DTSOLI',JA160X3Des('O0M_DTSOLI')} )

			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0032 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
	Endif

	//Campos O0N
	If lRet
		oModelNYF:AddLine()
		If !oModelNYF:SetValue('NYF_COD',Padl(nNYF++,4,'0')) .Or. !oModelNYF:SetValue('NYF_TABELA','O0N') .Or. !oModelNYF:SetValue('NYF_DTABEL', INFOSX2( FwFldGet('NYF_TABELA'), 'X2_NOME' )) .Or. !oModelNYF:SetValue('NYF_APELID','O0N001') .Or.;
		   !oModelNYG:LoadValue('NYG_CAMPO' ,'O0N_CTPDOC') .Or. !oModelNYG:LoadValue('NYG_DCAMPO' ,JA160X3Des('O0N_CTPDOC')) 
			lRet := .F.
			JurMsgErro( STR0032 )	
		Else
			aAdd( aNYG, {'O0N_DTPDOC',JA160X3Des('O0N_DTPDOC')} )
			aAdd( aNYG, {'O0N_SIGLA', JA160X3Des('O0N_SIGLA')} )
			aAdd( aNYG, {'O0N_SEQ',   JA160X3Des('O0N_SEQ')} )
			aAdd( aNYG, {'O0N_STATUS',JA160X3Des('O0N_STATUS')} )
			
			For nI := 1 To Len( aNYG )
				oModelNYG:AddLine()
				If !oModelNYG:LoadValue('NYG_CAMPO',aNYG[nI][1]) .Or. !oModelNYG:LoadValue('NYG_DCAMPO',aNYG[nI][2])
					lRet := .F.
					JurMsgErro( STR0032 + ': '+aNYG[nI][1] )
					Exit
				EndIf
			Next
			
			aNYG := {}
		EndIf
	Endif

	If lRet
		JA160Grava(oModel, lRet)
	EndIf	
		
	oModel:DeActivate()
EndIf

Return lRet  


//-------------------------------------------------------------------
/*/{Protheus.doc} JA160Grava
Grava a configuração de tabelas, relacionamentos e campos

@Param oModel	Model ativo
@Param lRet		.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Static Function JA160Grava(oModel, lRet) 
Local aErro:= {}
If lRet
	If ( lRet := oModel:VldData() )
		oModel:CommitData()
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		aErro := oModel:GetErrorMessage()
		JurMsgErro(aErro[6])
	EndIf
	
EndIf
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} JA160X3Des
Retorna a descrição do campo indicado pelo parametro

@Param cCampo	Nome do campo do qual deseja que a descrição
@Return cRet    Retorna a descrição do campo indicado pelo parametro

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Function JA160X3Des(cCampo)

Local aArea		:= GetArea()
Local cRet 		:= ''

	If !Empty(cCampo)
		Do Case
			Case __Language == 'PORTUGUESE'
				cRet := GetSx3Cache(cCampo,"X3_DESCRIC")
			Case __Language == 'ENGLISH'
				cRet := GetSx3Cache(cCampo,"X3_DESCENG")
			Case __Language == 'SPANISH'
				cRet := GetSx3Cache(cCampo,"X3_DESCSPA")
			OtherWise
				cRet := GetSx3Cache(cCampo,"X3_DESCENG") //-- Padrão em Inglês
		EndCase
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J160setTp
Armazena o valor da varíavel cTipo para o fonte inteiro

@Param cCampo	Nome do campo do qual deseja que a descrição
@Return Não ha retorno

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Function J160setTp(cTipo)
	_cTipo := cTipo
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J160getTp
Retorna o valor da varíavel cTipo para o fonte inteiro

@Return Retorna o conteúdo da variável cTipo

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Function J160getTp(cTipo)
Return _cTipo

//-------------------------------------------------------------------
/*/{Protheus.doc} J160setPesq
Armazena o valor da varíavel _cPesq para o fonte inteiro

@Param cPesq	Código da pesquisa que está sendo alterada
@Return Não ha retorno

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Function J160setPesq(cPesq)
	_cPesq := cPesq
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J160getPesq
Retorna o valor da varíavel _cPesq para o fonte inteiro

@Return Retorna o conteúdo da variável cPesq

@author André Spirigoni Pinto
@since 01/11/13
@version 1.0

/*/
//------------------------------------------------------------------- 
Function J160getPesq()
Return _cPesq

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160Ordem
Função que mostra uma janela para que o usuário defina a ordem
dos campos no grid

@author André Spirigoni Pinto
@since 05/11/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function JA160Ordem()
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local aItens    := {}
Local oListBox1 := Nil         
Local oDlg  	  := Nil
Local cSQL      := ''

cSQL := "SELECT NYG.NYG_CAMPO,NYG.NYG_DCAMPO, NYH.NYH_ORDEM, NYF.NYF_APELID"+ CRLF
cSQL += " FROM "+RetSQlName('NYE')+" NYE "+ CRLF
cSQL += " JOIN "+RetSQlName('NYF')+" NYF "+ CRLF
cSQL += " ON (NYF.NYF_CTABPR = NYE.NYE_COD) AND NYE.D_E_L_E_T_ = ' ' " + CRLF
cSQL += " JOIN "+RetSQlName('NYG')+" NYG "+ CRLF
cSQL += " ON (NYG.NYG_CTABRE = NYF.NYF_COD AND NYG.NYG_CTABPR = NYE.NYE_COD)" + CRLF
cSQL += " LEFT JOIN "+RetSQlName('NYH')+" NYH "+ CRLF
cSQL += " ON (NYH.NYH_CPESQ = NYE.NYE_CPESQ AND NYH.NYH_CAMPO = NYG.NYG_CAMPO " + CRLF
cSQL += " AND NYH.NYH_APELID = NYF.NYF_APELID "+ CRLF
cSQL += " AND NYH.NYH_FILIAL = '" + xFilial("NYH")+"'"+ CRLF
cSQL += " AND NYH.D_E_L_E_T_ = ' ' )" + CRLF
cSQL += " WHERE NYE.NYE_FILIAL = '" + xFilial("NYE")+"'"+ CRLF
cSQL += " AND NYF.NYF_FILIAL = '" + xFilial("NYF")+"'"+ CRLF
cSQL += " AND NYG.NYG_FILIAL = '" + xFilial("NYG")+"'"+ CRLF
cSQL += " AND NYE.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += " AND NYF.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += " AND NYG.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += " AND NYE.NYE_CPESQ = '" + J160getPesq() + "'"+ CRLF
cSQL += " ORDER BY NYH.NYH_ORDEM"+ CRLF

cSQL := ChangeQuery(cSQL)

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cSQL ), cAliasQry, .T., .F. )

(cAliasQry)->(DbgoTop())

While !(cAliasQry)->( EOF())

	aAdd(aItens, AllTrim((cAliasQry)->NYF_APELID) + ' - ' +(cAliasQry)->NYG_CAMPO + ' - ' + (cAliasQry)->NYG_DCAMPO )
	(cAliasQry)->(DbSkip())

End

(cAliasQry)->(dbCloseArea())
RestArea(aArea)

DEFINE MSDIALOG oDlg TITLE STR0015 FROM C(0),C(0) TO C(400),C(340) PIXEL

// Cria Componentes Padroes do Sistema 
@ C(006),C(010) Say    STR0022 Size C(115),C(007) COLOR CLR_BLACK PIXEL OF oDlg //"Campos disponíveis"	
@ C(080),C(110) Button STR0023 Size C(050),C(012) PIXEL OF oDlg Action JA160OrdUp(oListBox1, aItens) //"Mover para Cima"
@ C(100),C(110) Button STR0024 Size C(050),C(012) PIXEL OF oDlg Action JA160OrdDn(oListBox1, aItens) //"Mover para Baixo"	
@ C(180),C(007) Button STR0025 Size C(050),C(012) PIXEL OF oDlg Action MsgRun(STR0026,STR0027,{|| JA160OSave(aItens), oDlg:End() }) //"Salvar" //"Preparando campos para a exportação..." "Aguarde" 
@ C(180),C(065) Button STR0028 Size C(050),C(012) PIXEL OF oDlg Action oDlg:End() //"Sair"

oListBox1 := tListBox():New(C(015),C(007),,aItens,C(100),C(160),,oDlg,,,,.T.) 

ACTIVATE MSDIALOG oDlg CENTERED
		
Return(.F.) 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160OrdUp
Função que move um item da lista de ordem para cima

@author André Spirigoni Pinto
@since 05/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA160OrdUp(oListBox1, aItens)
Local lRet := .T.
Local nCurPos
Local cTmp

nCurPos := oListBox1:GetPos()
If oListBox1:GetPos() > 1
	cTmp := aItens[nCurPos-1]
	aItens[nCurPos-1] := aItens[nCurPos]
	aItens[nCurPos] := cTmp
	
	oListBox1:SetItems(aItens)
	oListBox1:Select(nCurPos-1)
Endif 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160OrdDn
Função que move um item da lista de ordem para baixo

@author André Spirigoni Pinto
@since 05/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA160OrdDn(oListBox1, aItens)
Local lRet := .T.
Local nCurPos
Local cTmp

nCurPos := oListBox1:GetPos()
If oListBox1:GetPos() < oListBox1:Len()
	cTmp := aItens[nCurPos+1]
	aItens[nCurPos+1] := aItens[nCurPos]
	aItens[nCurPos] := cTmp
	
	oListBox1:SetItems(aItens)
	oListBox1:Select(nCurPos+1)
Endif 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160OSave
Função que salva os dados da lista de ordem no banco de dados.

@author André Spirigoni Pinto
@since 05/11/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA160OSave(aItens)
Local lRet := .T.
Local aArea    := GetArea()
Local aAreaNYH := NYH->(GetArea())
Local lOk := .T.
Local nCt

NYH->( dbSetOrder( 1 ) )

//Se existe, apaga todos os registros da pesquisa.
While NYH->( dbSeek( xFilial('NYH') + J160getPesq() ) )
	Reclock( 'NYH', .F. )
	dbDelete()
	MsUnlock()
	
	If !Deleted()
		lOk := .F.
		lRet := .F.
	Endif
EndDo				
					
If lOk
	For nCt := 1 To Len(aItens)
		RecLock('NYH', .T.)
		NYH->NYH_FILIAL := xFilial('NYH')
		NYH->NYH_CPESQ   := J160getPesq()
		NYH->NYH_APELID  := SubStr(aItens[nCt],1,At(' - ',aItens[nCt]))
		NYH->NYH_CAMPO   := SubStr( 		SubStr(aItens[nCt],At(' - ',aItens[nCt])+3), 1 , At(' - ',SubStr(aItens[nCt],At(' - ',aItens[nCt])+3)) 		)
		NYH->NYH_ORDEM   := PadL(AllTrim(Str(nCt)),2,'0')
		MsUnlock()
		
		If __lSX8
			ConFirmSX8()
			lOk := .T.
		EndIf
	
	Next
Endif

RestArea(aAreaNYH)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160AssJur
Função que retorna o tipo de assunto jurídico vinculado a pesquisa atual.

@Return Código do assunto jurídico vinculado a pesquisa.

@author André Spirigoni Pinto
@since 10/11/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function JA160AssJur()
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cRet		:= "0"
Local nCt	 	:= 0
Local cSQL      := ''

cSQL := "SELECT NVJ.NVJ_CASJUR, NVJ.NVJ_CPESQ, NYB.NYB_CORIG"+ CRLF
cSQL += " FROM "+RetSQlName('NVJ')+" NVJ "+ CRLF
cSQL += " JOIN "+RetSQlName('NYB')+" NYB "+ CRLF
cSQL += " ON (NVJ.NVJ_CASJUR = NYB.NYB_COD) AND NYB.D_E_L_E_T_ = ' ' " + CRLF
cSQL += " WHERE NVJ.NVJ_FILIAL = '" + xFilial("NVJ")+"'"+ CRLF
cSQL += " AND NVJ.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += " AND NYB.NYB_FILIAL = '" + xFilial("NYB")+"'"+ CRLF
cSQL += " AND NYB.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += " AND NVJ.NVJ_CPESQ = '" + J160getPesq() + "'"+ CRLF
cSQL += " AND NVJ.NVJ_CASJUR IS NOT NULL "+ CRLF
cSQL += " AND NYB.NYB_CORIG IS NOT NULL "

cSQL := ChangeQuery(cSQL)

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cSQL ), cAliasQry, .T., .F. )

While !(cAliasQry)->( EOF())
	
	cRet := IIF(Empty((cAliasQry)->NYB_CORIG),(cAliasQry)->NVJ_CASJUR,(cAliasQry)->NYB_CORIG)
	nCt++
	(cAliasQry)->(DbSkip())
	
End

(cAliasQry)->(dbCloseArea())
RestArea(aArea)

//caso tenha mais de um assunto jurídico, retornar mensagem de erro.
If nCt > 1
	cRet := "-1"
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J160VLCAMPO
Função que valida o campo inserido na tabela NYG. valida a tabela de origem
e valida se o campo é real.

@param 	cCampo 	    Nome do campo
@param 	cTabela 	Nome do campo de tabela

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 13/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function J160VLCAMPO( cCampo , cCampoTab )
Local aArea	:= GetArea()
Local lRet		:= .T.
Local cTabela	:= FwFldGet( cCampoTab )
Local cArqv     := GetSx3Cache(cCampo,"X3_ARQUIVO")

	cCampo := Alltrim( cCampo )

	If cArqv <> cTabela
		lRet := .F.
		JurMsgErro( STR0029 ) //"Campo Inválido. Verifique a digitação ou utilize F3."		
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA160VlMsg

Pre validação para verificação da quantidade de assuntos jurídicos 
vinculados

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Rafael Rezende Costa
@since 18/09/14
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA160VlMsg(oModel)
Local lRet		:= .T.
Local cStatus := ''
Local aNYECod := {}  

If oModel:GetOperation() == 3

	cStatus := JA160AssJur()
	
	//------------------------------------------------------------------------------
	//Foi utilizado ApMsgInfo nas mensagens, porque JurMsgErro não era apresentado.
	//------------------------------------------------------------------------------
	If !EMPTY(cStatus).AND.!( cStatus == "-1" .OR. cStatus == "0" )
	
		aNYECod := JA160VCod( J160GetPesq() )
			
		If LEN( aNYECod ) > 0
			lRet := .F.
			ApMsgInfo(STR0030)// "Grid já cadastrado!"			
		EndIF
		
	ElseIf cStatus == "-1"
		lRet := .F.
		ApMsgInfo(STR0020) //"Existe mais de um assunto jurídico vinculado"
		
	ElseIf cStatus == "0"
		lRet := .F.
		ApMsgInfo(STR0021) //"Você deve vincular ao menos um assunto jurídico para poder fazer a configuração de grid."		
	Endif
EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JA160VCod

Função para verificar se existe alguma configuração já 
lançada na tabela NYE

@Return aSQL	 	Array com os dados 

@author Rafael Rezende Costa
@since 03/10/14
@version 1.0
/*/
//------------------------------------------------------------------- 
Function JA160VCod(cCod)
Local aSQL  := {}
Local cSQL   := ''	

Default cCod := ''

IF !Empty(cCod)
	
	cSQL := "SELECT NYE_CPESQ, NYE_TABELA"+ CRLF
	cSQL += " FROM "+RetSQlName('NYE')+" NYE "+ CRLF	
	cSQL += " WHERE NYE.NYE_FILIAL = '" + xFilial("NYE")+"'"+ CRLF	
	cSQL += " AND NYE.D_E_L_E_T_ = ' ' "+ CRLF	
	cSQL += " AND NYE.NYE_CPESQ = '" + cCod + "'"+ CRLF	
		
	
	aSQL := JurSQL( cSQL, { "NYE_CPESQ","NYE_TABELA" } )
EndIf

Return aSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} J160VLVIRT
Função que valida o campo inserido na tabela NYG. valida a tabela de origem
e valida se o campo é real.

@param 	oModel 	    Estrutura do modelo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 13/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J160VLVIRT( oModel )
Local lRet		:= .T.
Local aCampos   := {}
Local aCampDef  := {"NSZ_COD","NTA_COD","NT4_COD","NT2_COD","NSZ_FILIAL","NT2_FILIAL","NT4_FILIAL","NT2_CAJURI","NT4_CAJURI"}
Local nCt       := 0
Local oModelNYF := oModel:GetModel("NYFDETAIL")
Local oModelNYG := Nil
Local nTemp     := 0
local cBrwIni   := ""
Local nTab      := 0
Local cCampo    := ""
Local cCampErro := ""
Local cContext  := ""
local cArqv     := ""

For nTab := 1 to oModelNYF:GetQtdLine()

	If lRet

		oModelNYF:GoLine(nTab)
		
		oModelNYG := oModel:GetModel("NYGDETAIL")
		
		aSize(aCampos,0)
		aCampos := aClone(aCampDef)	

		//Cria o array com a lista de campos
		For nCt := 1 to oModelNYG:GetQtdLine()

			oModelNYG:GoLine(nCt)

			if !oModelNYG:IsDeleted(nCt) .And. lRet
				aAdd(aCampos,oModelNYG:GetValue("NYG_CAMPO",nCt))
			Endif
		Next
	
		For nCt := 1 to oModelNYG:GetQtdLine()

			oModelNYG:GoLine(nCt)

			if !oModelNYG:IsDeleted(nCt) .And. lRet
				cCampo := Alltrim( oModelNYG:GetValue("NYG_CAMPO",nCt) )
				cContext := GetSx3Cache(cCampo,"X3_CONTEXT")
				
				If cContext == "V"

					cBrwIni := AllTrim(	GetSx3Cache(cCampo,"X3_INIBRW") ) 
					nTemp := aScan(aCampos,{|x| At(AllTrim(x),cBrwIni) > 0})

					While nTemp > 0
						cArqv := GetSx3Cache(cCampo,"X3_ARQUIVO")
						cBrwIni := strTran(cBrwIni, cArqv + "->" + AllTrim(aCampos[nTemp]),'_')
						nTemp := aScan(aCampos,{|x| At(x,cBrwIni) > 0},nTemp)
					End
					
					if At("->", cBrwIni) > 0
						lRet := .F.						
						cCampErro := SubStr(cBrwIni,(At("->",cBrwIni)+2),10)						
						Help( ,, "J160VLVIRT",, I18N(STR0031,{cCampErro} ) , 1, 0 ) //"Para adicionar campos virtuais, os campos utilizados pelo Inicializador de Browse devem estar no grid. Adicione o campo #1."					
						Exit
					Endif 
				Endif
			Endif

		Next
	Endif

Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J160VLDNYG
Função que valida se o campo é real.
@param 	oModel 	    Estrutura do modelo
@Return lRet	 	.T./.F. As informações são válidas ou não
@author Clóvis Eduardo Teixeira
@since 21/07/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J160VLDNYG( oModel )
Local lRet		:= .T.
Local aCampos   := {}
Local aCampDef  := {"NSZ_COD","NTA_COD","NT4_COD","NT2_COD","NSZ_FILIAL","NT2_FILIAL","NTA_FILIAL","NT4_FILIAL","NT2_CAJURI","NT4_CAJURI","NTA_CAJURI"}
Local nCt       := 0  
Local oModelNYG := Nil
Local nTemp     := 0
local cBrwIni   := ""
Local cCampo    := ""
Local cCampErro := ""
Local cContext  := ""
local cArqv     := ""

	oModel    := FwModelActive()
	oModelNYG := oModel:GetModel("NYGDETAIL")
	aCampos   := aClone(aCampDef)

	//Cria o array com a lista de campos
	For nCt := 1 to oModelNYG:GetQtdLine()
		if !oModelNYG:IsDeleted(nCt) .And. lRet
			aAdd(aCampos,oModelNYG:GetValue("NYG_CAMPO",nCt))
		Endif
	Next
	
	nCt := oModelNYG:nLine

	if !oModelNYG:IsDeleted(nCt) 
		cCampo   := Alltrim( oModelNYG:GetValue("NYG_CAMPO",nCt) )
		cContext := GetSx3Cache(cCampo,"X3_CONTEXT")
		
		If cContext == "V"

			cBrwIni := AllTrim(	GetSx3Cache(cCampo,"X3_INIBRW") ) 
			nTemp := aScan(aCampos,{|x| At(AllTrim(x),cBrwIni) > 0})

			While nTemp > 0
				cArqv := GetSx3Cache(cCampo,"X3_ARQUIVO")
				cBrwIni := strTran(cBrwIni, cArqv + "->" + AllTrim(aCampos[nTemp]),'_')
				nTemp := aScan(aCampos,{|x| At(x,cBrwIni) > 0},nTemp)
			End
			
			if At("->", cBrwIni) > 0
				lRet := .F.
				cCampErro := SubStr(cBrwIni,(At("->",cBrwIni)+2),10)
				JurMsgErro( I18N(STR0031,{cCampErro})) //"Para adicionar campos virtuais, os campos utilizados pelo Inicializador de Browse devem estar no grid. Adicione o campo #1."
			Endif 
		Endif
	Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} J160CarIni()
Função que verifica as pesquisas criadas e chama função de configuração inicial para cada uma delas

@Return 

@author Wellington Coelho
@since 23/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function J160CarIni()
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cSQL      := ''

cSQL := " SELECT NVG.NVG_CPESQ, NVG.NVG_TPPESQ "
cSQL += " FROM "+RetSQlName('NVG')+" NVG "
cSQL += " WHERE NVG.NVG_FILIAL = '" + xFilial("NVG")+"'"
cSQL += " AND NVG.D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY NVG.NVG_CPESQ, NVG.NVG_TPPESQ "

cSQL := ChangeQuery(cSQL)

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cSQL ), cAliasQry, .T., .F. )

While !(cAliasQry)->( EOF())
	
	JA160CONFG((cAliasQry)->NVG_CPESQ, (cAliasQry)->NVG_TPPESQ )
	(cAliasQry)->(DbSkip())
End

(cAliasQry)->(dbCloseArea())
RestArea(aArea)

Return Nil
