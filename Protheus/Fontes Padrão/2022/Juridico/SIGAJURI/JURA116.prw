#INCLUDE "JURA116.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "FWMVCDEF.CH"

//campos virtuais referentes à instância atual ou que utilizam função para mostrar o valor
#DEFINE CAMPOSNAOCONFIG 'NSZ_DCOMAR/NSZ_NUMPRO/NSZ_DLOC2N/NSZ_DLOC3N/NSZ_DNATUR/NSZ_DTIPAC/NSZ_PATIVO/'+;
						'NSZ_PPASSI/NSZ_TIPOPR/NSZ_CONMES/NUQ_INSATU/NUQ_CAJURI/NT9_CAJURI/'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA116
Restrição de Cadastros Básicos

@author Jorge Luis Branco Martins Junior
@since 23/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA116()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NVA" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NVA" )
JurSetBSize( oBrowse )
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

@author Juliana Iwayama Velho
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA116", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA116", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA116", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA116", 0, 5, 0, NIL } ) // "Excluir"
                                              	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Campos Exportação Personalizada

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel( "JURA116" )
Local oStructNVA
Local oStructNVB
Local oStructNVC
Local oView

oStructNVA := FWFormStruct( 2, "NVA" )
oStructNVB := FWFormStruct( 2, "NVB" )
oStructNVC := FWFormStruct( 2, "NVC" )

oStructNVB:RemoveField( "NVB_CPESQ" )
oStructNVC:RemoveField( "NVC_CTABEL" )

//JurSetAgrp( 'NQ0',, oStructNQ0 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA116_TABELA", oStructNVA, "NVAMASTER"  )   
oView:AddGrid ( "JURA116_RELACI", oStructNVB, "NVBDETAIL"  )
oView:AddGrid ( "JURA116_CAMPOS", oStructNVC, "NVCDETAIL"  )
                                                   
oView:CreateHorizontalBox( "FORMTABELA" , 10 )
oView:CreateHorizontalBox( "FORMRELACI" , 45 )
oView:CreateHorizontalBox( "FORMCAMPOS" , 45 )

oView:SetOwnerView( "NVAMASTER" , "FORMTABELA" )
oView:SetOwnerView( "NVBDETAIL" , "FORMRELACI" )
oView:SetOwnerView( "NVCDETAIL" , "FORMCAMPOS" )

oView:AddIncrementField( "NVBDETAIL" , "NVB_COD" )	
oView:AddIncrementField( "NVCDETAIL" , "NVC_COD" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Campos Exportação Personalizada

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0

@obs NQVMASTER - Dados dos Campos Exportação Personalizada

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructNVA := FWFormStruct(1,"NVA")
Local oStructNVB := FWFormStruct(1,"NVB")
Local oStructNVC := FWFormStruct(1,"NVC")
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
//oStructNVA := FWFormStruct(1,"NVA")
//oStructNVB := FWFormStruct(1,"NVB")
//oStructNVC := FWFormStruct(1,"NVC")

oStructNVB:RemoveField( "NVB_CPESQ" )
oStructNVC:RemoveField( "NVC_CTABEL" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA116", /*Pre-Validacao*/, {|oX|JA116TOK(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

oModel:AddFields( "NVAMASTER", /*cOwner*/, oStructNVA,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "NVAMASTER" ):SetDescription( STR0008 ) 

oModel:AddGrid( "NVBDETAIL", "NVAMASTER" /*cOwner*/, oStructNVB, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NVBDETAIL"  ):SetDescription( STR0009 )
oModel:SetRelation( "NVBDETAIL", { { "NVB_FILIAL", "XFILIAL('NVA')" }, { "NVB_CPESQ", "NVA_COD" } }, NVB->( IndexKey( 1 ) ) )

oModel:AddGrid( "NVCDETAIL", "NVBDETAIL" /*cOwner*/, oStructNVC, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:SetRelation( "NVCDETAIL", { { "NVC_FILIAL", "XFILIAL('NVB')" }, { "NVC_CTABEL", "NVB_COD" } }, NVC->( IndexKey( 1 ) ) ) 

//oModel:GetModel( "NVBDETAIL" ):SetUniqueLine( { "NVB_COD" } )
//oModel:GetModel( "NVCDETAIL" ):SetUniqueLine( { "NVC_COD" } )             
oModel:GetModel( "NVBDETAIL" ):SetUniqueLine( { "NVB_TABELA" } )
oModel:GetModel( "NVCDETAIL" ):SetUniqueLine( { "NVC_VALOR" } )

                                                                  
JurSetRules( oModel, "NVAMASTER",, 'NVA' )
JurSetRules( oModel, "NVBDETAIL",, 'NVB' )
JurSetRules( oModel, "NVCDETAIL",, 'NVC' )

oStructNVB:SetProperty("NVB_TABELA" , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "EXISTCPO( 'SX2',FwFldGet('NVB_TABELA'),1) .And. JA116VerTab(NVB_TABELA)") )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116TOK
Valida informações ao salvar

@param 	oModel  	Model a ser verificado
@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA116TOK(oModel)
Local lRet     	:= .T.
Local aArea    	:= GetArea()
Local aAreaNVA 	:= NVA->( GetArea() )
Local nOpc     	:= oModel:GetOperation()
Local oModelNVA := oModel:GetModel('NVAMASTER') 

If nOpc == 3
	If !Empty(JurGetDados("NVA",2,XFILIAL("NVA")+oModelNVA:GetValue( "NVA_CPESQ" ), "NVA_COD"))
		lRet := .F.
		JurMsgErro(STR0010 + oModelNVA:GetValue( "NVA_CPESQ" ) + STR0011 )
	EndIf
EndIf

RestArea(aAreaNVA)
RestArea(aArea   )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116Vld
Valida informações ao salvar

@author Jorge Luis Branco Martins Junior
@since 06/08/12
@version 1.0
/*/
//-------------------------------------------------------------------

Function JA116Vld()
Local aArea	  	:= GetArea()
Local lRet			:= .T.
Local cRet	 		:= ""
Local oModel    := FWModelActive()
Local nOpc			:= oModel:GetOperation()
Local oModelNVB := oModel:GetModel('NVBDETAIL')
Local oModelNVC := oModel:GetModel('NVCDETAIL')
Local cTabela		:= ""
Local cCod			:= ""

	If Alltrim(cTabela) == '' .Or. cTabela == NIL .Or. nOpc == 3
		cTabela := oModelNVB:GetValue( "NVB_TABELA" ) 
	EndIf
	
	If Alltrim(cCod) == '' .Or. cCod == NIL .Or. nOpc == 3
		cCod := oModelNVC:GetValue( "NVC_VALOR" )
	EndIf	
  
	If !Empty(Alltrim(cTabela))
		If !JA116VerTab(cTabela)
			lRet := .F.
			JurMsgErro(STR0015) //"Tabela não é um Cadastro Básico"
		Endif		
  		cRet := JA116Desc(cTabela,cCod)
	  	If Empty(Alltrim(cRet))
			lRet := .F.
			JurMsgErro(STR0012)
	  	EndIf
	Else
		lRet := .F.
		JurMsgErro(STR0013)
	EndIf
	
RestArea( aArea )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116IniP
Inicializador padrão da descrição do campo na NVC

@author Jorge Luis Branco Martins Junior
@since 06/08/12
@version 1.0
/*/
//-------------------------------------------------------------------

Function JA116IniP()
Local aArea	  := GetArea()
Local cRet	 	:= ""
Local cTabela	:= NVB->NVB_TABELA
Local cCod		:= NVC->NVC_VALOR

	If !INCLUI
		If Alltrim(cTabela) == '' .Or. cTabela == NIL
			cTabela := FwFldGet("NVB_TABELA")
		EndIf
		If !Empty(Alltrim(cTabela))
    		cRet := JA116Desc(cTabela,cCod)
    	EndIf
	EndIf

RestArea( aArea )
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116GatD
Gatilho da descrição do campo na NVC

@author Jorge Luis Branco Martins Junior
@since 06/08/12
@version 1.0
/*/
//-------------------------------------------------------------------

Function JA116GatD()
Local aArea	  := GetArea()
Local cRet	 	:= ""
Local cTabela	:= FwFldGet("NVB_TABELA")
Local cCod		:= FwfldGet("NVC_VALOR")

cRet := JA116Desc(cTabela,cCod)

RestArea( aArea )
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116F3Exp
Expressão do F3 de seleção na NVC

@author Jorge Luis Branco Martins Junior
@since 06/08/12
@version 1.0
/*/
//-------------------------------------------------------------------

Function JA116F3Exp(cTab)
Local aArea   := GetArea()
Local lRet 	:= .F.
Local nI		:= 0
Local aStruct := {} 
Local aPesq   := {}
Local nResult := 0

If !Empty(Alltrim(cTab)) .And. JA116VerTab(ctab) //verifica se a tabela escolhida é de cadastro basico

	SX3->(DbSetOrder(1))
	SX3->(DbGoTop())
	SX3->(MsSeek(cTab))

	While (SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cTab)
		If !('_FILIAL' $ SX3->X3_CAMPO)
			If SX3->X3_TIPO <> "M"
				If SX3->X3_CONTEXT <> "V" 
					aAdd(aPesq,AllTrim(SX3->X3_CAMPO))
				Endif
			Endif
		Endif
		SX3->(DbSkip())
	EndDo

	nResult := JurF3SXB(cTab, aPesq,, .F., .F.)

	If nResult > 0
		DbSelectArea(cTab)
		(cTab)->(dbgoTo(nResult))
		lRet := .T.
	EndIf

Else
  	lRet := .F.
  	MsgAlert(STR0013)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
EndIf
  
RestArea( aArea )
  
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116F3Ret
Retorno do F3 de seleção na NVC

@author Jorge Luis Branco Martins Junior
@since 06/08/12
@version 1.0
/*/
//-------------------------------------------------------------------

Function JA116F3Ret()
Local cRet    := ""
Local cUnico  := ""
Local aArea   := GetArea()

	cTab := FwFldGet("NVB_TABELA")
	cUnico  := FWX2Unico(cTab)

	If cTab <> 'RD0'
		If !Empty( cUnico )
			aCod := StrToArray( FWX2Unico(cTab), '+' )
			cRet := (cTab)->&(aCod[2])
		EndIf
	Else
		cRet := RD0->RD0_SIGLA
	EndIf
	
	RestArea( aArea )
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116Desc
Busca a Descrição NVC

@author Jorge Luis Branco Martins Junior
@since 06/08/12
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function JA116Desc(cTabela,cCod)
Local aArea   := GetArea()
Local cQuery	:= ''
Local cCampo	:= ''
Local cDesc		:= ''
Local cRet		:= ''
Local aCod		:= {}
Local aStruct	:= (cTabela)->( dbStruct() )
Local cAlias	:= GetNextAlias()
Local cUnico  := FWX2Unico(cTabela)

	If !Empty( cUnico )
	 	aCod   := StrToArray( cUnico, '+' )
	  	cCampo := aCod[2]	
		cDesc  := aStruct[3][1]
	  
	  	If cTabela == 'RD0'
			cCampo := 'RD0_SIGLA'
			cDesc  := 'RD0_NOME'
		EndIf
	  
		cQuery := "SELECT "+ cDesc + " DESCR FROM "+RetSqlName(cTabela)+" "+cTabela+" "+ CRLF
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += Iif ( Left (cTabela,1) == 'S', Right (cTabela,2), cTabela) + "_FILIAL = '" + xFilial(cTabela) + "' AND " + CRLF
		cQuery += cCampo + " = '" + cCod + "'" + CRLF
		cQuery := ChangeQuery(cQuery, .F.)
		    
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .T. )
		    
		If !(cAlias)->( EOF() )
			cRet := (cAlias)->DESCR
		EndIf

	Else
		JurMsgErro(STR0014)
	EndIf	  

	(cAlias)->( dbCloseArea() )	

	RestArea( aArea )
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA116VerTab(cTab)
	Verificar se a tabela é de cadastro básico do Sigajuri. As que usam a função JurSetRest()

@param  cTab Nome da tabela
@Return lRet

@author Ronaldo Gonçalves de Oliveira
@since 31/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA116VerTab(cTab)
Local aTab    := { "NSY","NSZ","NT9","NT2","NT3","NT4","NTA","NUN","NUQ","O0M","O0N","O08","NXY", "NWU","NYP","NUV"} //Entidades Principais
Local aTabAux := {}
Local nI   := 0
Local lRet    := .T.

	//Valida se a tabela é uma entidade principal
	If Ascan(aTab, cTab ) > 0
		JurMsgErro(STR0015) //"Tabela não é um Cadastro Básico"
		lRet := .F. 
	EndIf

	While ( lRet .And. ( nI < Len( aTab ) ) .And. Empty( aTabAux ) )
		nI++
		aTabAux := JURSX9(cTab, aTab[nI] )
		
		If !Empty( aTabAux ) .And. ( ( "+" $ aTabAux[1][1] ) .Or. ( "+" $ aTabAux[1][2] ) )
			JurMsgErro(STR0015) //"Tabela não é um Cadastro Básico"
			lRet := .F. 
		EndIf
	EndDo

	If Empty( aTabAux )
		JurMsgErro(STR0015) //"Tabela não é um Cadastro Básico"
		lRet := .F. 
	EndIf

Return lRet
