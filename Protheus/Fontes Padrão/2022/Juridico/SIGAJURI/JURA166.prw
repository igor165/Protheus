#INCLUDE "JURA166.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA166
Alter. Processos Encerrados

@author Juliana Iwayama Velho
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA166(cProcesso, cClaMotAlt)
Local oBrowse
Local cFiltro := ""
Local aArea     := GetArea()
             
Default cProcesso  := ''
Default cClaMotAlt := ''

oBrowse := FWMBrowse():New()     
oBrowse:SetMenuDef('JURA166') 
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NUV" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NUV" )
JurSetBSize( oBrowse )

	dbSelectArea("NUV")
	
If !Empty(cProcesso) 
	cFiltro := " (NUV_CAJURI == '" + cProcesso + "')"
ENdif

If !Empty(cClaMotAlt) .And. ColumnPos('NUV_CLMTAL') > 0
	IF !Empty(cFiltro)
		cFiltro := cFiltro + " .And. "
	Endif

	cFiltro := cFiltro + " (NUV_CLMTAL == '" + cClaMotAlt + "')"
Endif

oBrowse:SetFilterDefault( cFiltro )	  

	//Ordenação do grid de andamentos de forma decrescente
	If (ColumnPos("NUV_DTDESC")) > 0
	NUV->(dbSetOrder(3))            //filial + dtdesc
	EndIf 
	
oBrowse:Activate() 

	RestArea( aArea )

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
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

//aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
If JA162AcRst('11')
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA166", 0, 2, 0, NIL } ) // "Visualizar"
EndIf	
/*
aAdd( aRotina, { STR0003, "VIEWDEF.JURA166", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA166", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA166", 0, 5, 0, NIL } ) // "Excluir"
*/
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Alter. Processos Encerrados

@author Juliana Iwayama Velho
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA166" )
Local oStruct    := FWFormStruct( 2, "NUV" )   
Local cGrpRest   := JurGrpRest()

JurSetAgrp( 'NUV',, oStruct )

	If oStruct:HasField("NUV_CLMTAL")
		oStruct:RemoveField( "NUV_CLMTAL" ) 
	EndIf 
	
	//campo para ordem decrescente 
	If oStruct:HasField("NUV_DTDESC")
		oStruct:RemoveField( "NUV_DTDESC" ) 
	EndIf         


oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA166_VIEW", oStruct, "NUVMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA166_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Alter. Processos Encerrados"
oView:EnableControlBar( .T. )    

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Alter. Processos Encerrados

@author Juliana Iwayama Velho
@since 05/08/09
@version 1.0

@obs NUVMASTER - Dados do Alter. Processos Encerrados

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NUV" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA166", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NUVMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Alter. Processos Encerrados"
oModel:GetModel( "NUVMASTER" ):SetDescription( STR0009 ) // "Dados de Alter. Processos Encerrados"
JurSetRules( oModel, "NUVMASTER",, "NUV",, "JURA166" )

Return oModel      

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA166PROC
Verifica qual tela relacionada ao Assunto Jurídico está sendo alterada
para preenchimento do campo de relacionamento

@Return cRet                  Código do Assunto Jurídico

@author Juliana Iwayama Velho
@since 05/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA166PROC()
Local cRet := ''

Do Case
    Case IsInCallStack( 'JURA095TOK' ); cRet := NSZ->NSZ_COD
    Case IsInCallStack( 'JA055TOK'   ); cRet := NSZ->NSZ_COD
    Case IsInCallStack( 'JURA100TOK' ); cRet := If (!Empty(M->NT4_CAJURI),M->NT4_CAJURI,NT4->NT4_CAJURI)
    Case IsInCallStack( 'JURA106TOK' ); cRet := If (!Empty(M->NTA_CAJURI),M->NTA_CAJURI,NTA->NTA_CAJURI)
    Case IsInCallStack( 'JURA098'    ); cRet := If (!Empty(M->NT2_CAJURI),M->NT2_CAJURI,NT2->NT2_CAJURI)
    Case IsInCallStack( 'JURA099TOK' ); cRet := If (!Empty(M->NT3_CAJURI),M->NT3_CAJURI,NT2->NT3_CAJURI)
    Case IsInCallStack( 'JURA154TOK' ); cRet := If (!Empty(M->NUN_CAJURI),M->NUN_CAJURI,NUN->NUN_CAJURI)
    Case IsInCallStack( 'JURA094TOK' ); cRet := If (!Empty(M->NSY_CAJURI),M->NSY_CAJURI,NSY->NSY_CAJURI)
EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J166ClaMot()
Filtro da consulta padrão NQX, para trazer só os motivos conforme a Classificação passada. 
Uso Geral. 

@return 

@author Reginaldo Soares
@since 23/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J166ClaMot()

	Local cRet   := "@#@#"
	Local oModel := FWModelActive()
	
	DbSelectArea("NUV")
	If ColumnPos('NUV_CLMTAL') > 0 .And. oModel <> Nil
		cRet := "@#NQX->NQX_CLMTAL == '" + FwFldGet('NUV_CLMTAL') + "'@#"
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J166VdlCma()
Filtro da consulta padrão NQX, para trazer só os motivos conforme a Classificação passada. 
Uso Geral. 

@return 

@author Reginaldo Soares
@since 23/01/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function J166VdlCma()

	Local lRet	 := .T.
	Local oModel := FWModelActive()
		
	DbSelectArea("NUV")
	If ColumnPos('NUV_CLMTAL') > 0
		If FwFldGet('NUV_CLMTAL') <> JurGetDados("NQX", 1, xFilial('NQX') + M->NUV_CMOTIV, "NQX_CLMTAL")
			JurMsgErro(STR0010,,STR0011) //("Codigo informado inválido",,"Informar Código Válido")
			lRet := .F.
		Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J166GrvJus()
Grava a justificativa de alteração.

@author  Rafael Tenorio da Costa
@since 	 08/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J166GrvJus(cCajuri, cUserAut, cCodJust, cJustifi)

	Local aArea		:= GetArea()
	Local oModel    := FWModelActive()
	Local lRetorno	:= .F.
	Local oModelNUV := Nil
	
	Default cUserAut:= UsrRetName(__CUSERID)

	//--Proteção para aumento no tamanho do campo NUV_USUALT
	cUserAut := Substr( cUserAut, 1, GetSx3Cache("NUV_USUALT", "X3_TAMANHO") )

	oModelNUV := FWLoadModel("JURA166")
	oModelNUV:SetOperation(3)
	oModelNUV:Activate()
	
	oModelNUV:SetValue("NUVMASTER", "NUV_FILIAL", xFilial("NUV") )
	oModelNUV:SetValue("NUVMASTER", "NUV_CAJURI", cCajuri		 )
	oModelNUV:SetValue("NUVMASTER", "NUV_USUALT", cUserAut	 	 )
	oModelNUV:SetValue("NUVMASTER", "NUV_CMOTIV", cCodJust		 )
	oModelNUV:SetValue("NUVMASTER", "NUV_JUSTIF", cJustifi       )
	
	If oModelNUV:GetModel("NUVMASTER"):HasField("NUV_CLMTAL")
		oModelNUV:SetValue("NUVMASTER", "NUV_CLMTAL", JurGetDados("NQX", 1, xFilial("NQX") + cCodJust, "NQX_CLMTAL") )	//NQX_FILIAL + NQX_COD
	EndIf
	
	If ( lRetorno := oModelNUV:VldData() )
		lRetorno := oModelNUV:CommitData()
	EndIf
	
	If !lRetorno
		JurMsgErro(STR0012)	//"Não foi possível íncluir a justificativa"
	EndIf	
	
	oModelNUV:DeActivate()
	oModelNUV:Destroy()
	
	FWModelActive(oModel, .T.)
	RestArea(aArea)

Return lRetorno