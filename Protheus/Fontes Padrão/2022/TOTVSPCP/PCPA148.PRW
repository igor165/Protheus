#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA148.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA148
Função para cadastro dos termos PCP
@author  Thiago kobi Zoppi
@since   03/12/2019
/*/
//-------------------------------------------------------------------
Function PCPA148()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('HWH')
	oBrowse:SetDescription(STR0001) //"Termo de Consentimento"
	
	oBrowse:AddLegend(  "!EMPTY(HWH_DTFIM) .AND. HWH_DTFIM < DATE()  " , "RED",STR0002) //"Não Vigente"
	oBrowse:AddLegend( "HWH_DATA <= HWH_DTFIM .OR. EMPTY(HWH_DTFIM) ", "GREEN",STR0003)    //"Vigente" 

	oBrowse:Activate()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@author  Thiago kobi Zoppi
@since   03/12/2019
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.PCPA148" OPERATION 2 ACCESS 0 //"Visualizar" 
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.PCPA148" OPERATION 3 ACCESS 0 //"Incluir"        
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.PCPA148" OPERATION 4 ACCESS 0 //"Alterar"        
    ADD OPTION aRotina TITLE STR0025 ACTION "VIEWDEF.PCPA148" OPERATION 5 ACCESS 0 //"Excluir"       
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.PCPA148" OPERATION 8 ACCESS 0 //"Imprimir"       
    ADD OPTION aRotina TITLE STR0008 ACTION "PCPA148A()"	  OPERATION 8 ACCESS 0 //"Termo X Usuario"

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@author  Thiago kobi Zoppi
@since   03/12/2019
/*/
//-----------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruHWH := FWFormStruct(1,"HWH")
	
	oModel:= MPFormModel():New("PCPA148", /*bPre*/, {|oMdl| MDMVlPos( oMdl ) }/*bPos*/)
	oModel:addFields('MASTERHWH',,oStruHWH)
	oModel:SetDescription(STR0001) //"Termo de Consentimento"
    oModel:SetPrimaryKey({ "HWH_FILIAL", "HWH_CODIGO" } )
	
	oStruHWH:SetProperty('*'        , MODEL_FIELD_WHEN,{|oMdl| HabilitCpo(oMdl) } )
	oStruHWH:SetProperty('HWH_DTFIM', MODEL_FIELD_WHEN,{|oMdl|.T.               } )
	oStruHWH:SetProperty( "HWH_DATA", MODEL_FIELD_INIT, { | | Date() } ) 

	oModel:SetActivate({|oMod| })	
	 
Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@author  Thiago kobi Zoppi
@since   03/12/2019
/*/
//-----------------------------------------------------------------
Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local oStrHWH:= FWFormStruct(2, 'HWH')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FORM_TERMO' , oStrHWH,'MASTERHWH' ) 
	oView:CreateHorizontalBox( 'BOX_FORM_TERMO', 100)
	oView:SetOwnerView('FORM_TERMO','BOX_FORM_TERMO')	
	
Return oView

Function PCPA148A()
	Local oBrowse, n
	Local oButton
	Local oColumn
	Local oTempTable
	local  aSize      := {}
	local  aObjects   := {}
	local  aInfo      := {}
	Local cAliasQry   := GetNextAlias()
	Local aAllUser    := FWSFALLUSERS()
	Local lOk         := .T.
	Local aFields     := {}
	Local cAlias      := GetNextAlias()
	Static oDlg
	
	//SET FILIAL
	cFilant := FWPesqSM0("M0_CODFIL",cEmpAnt) 

	oTempTable := FWTemporaryTable():New( cAlias )


	aadd(aFields,{ STR0020 ,"C",15                       ,0}) //"LOGIN"   
	aadd(aFields,{ STR0021 ,"C",30                       ,0}) //"USUARIO" 
	aadd(aFields,{ STR0022 ,"C",TAMSX3("HWH_DESCRI")[1]+8,0}) //"TERMO"   
	aadd(aFields,{ STR0023 ,"D",TAMSX3("HWI_DATA")[1]    ,0}) //"DT_ACEIT"
	aadd(aFields,{ STR0024 ,"C",8                        ,0}) //"STATUS"  
	
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("indice1", {STR0020} ) //"LOGIN"      
	oTempTable:AddIndex("indice2", {STR0021} ) //"USUARIO" 
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()

	// Obtém a a área de trabalho e tamanho da dialog
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } ) // Dados da Enchoice 
	AAdd( aObjects, { 200, 100, .T., .T. } ) // Dados da getdados 
	AAdd( aObjects, { 300, 100, .T., .T. } ) // Dados da getdados 
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
	aPosObj := MsObjSize( aInfo, aObjects,.T.) 	


	//Query para selecionar todos os termos vigentes.
	BeginSql Alias cAliasQry

		SELECT
			HWH_TITULO,HWH_CODIGO,HWH_DESCRI,HWH_TERMO
		FROM %table:HWH% HWH
		WHERE HWH_FILIAL = %xFilial:HWH%
			AND (HWH.HWH_DATA <= HWH.HWH_DTFIM OR HWH.HWH_DTFIM = '')
			AND HWH.%notDel%
			
	EndSql

	While !(cAliasQry)->(Eof())
		//Varre os usuarios
		For n:= 1 to Len(aAllUser)
			
			DBSelectArea("HWI")
			DBSetOrder(1)
			IF DBSEEK(xFilial("HWI")+aAlluser[n][2]+(cAliasQry)->HWH_CODIGO)
			 	lOk	:= .T. 
			Else
				lOk	:= .F. 
			EndIf

			RECLOCK(cAlias,.t.)
				Replace LOGIN    WITH aAlluser[n][3]
				Replace USUARIO  WITH aAlluser[n][4]
				Replace TERMO    WITH ALLTRIM((cAliasQry)->HWH_CODIGO)+' - ' + ALLTRIM((cAliasQry)->HWH_DESCRI)
				Replace DT_ACEIT WITH HWI->HWI_DATA
				Replace STATUS   WITH IF(lOk,STR0009,STR0010 ) //"Aceito" //"Pendente"
			Msunlock()

			
		Next
		(cAliasQry)->(DbSkip())
	End
		(cAliasQry)->(DbCloseArea())
	
	DEFINE MSDIALOG oDlg TITLE STR0011 FROM aSize[7],0 TO aSize[6],aSize[5]  COLORS 0, 16777215 PIXEL //"Termos X Usuarios"

		DEFINE FWFORMBROWSE oBrowse DATA TABLE ALIAS cAlias OF oDlg        
			ADD LEGEND DATA 'STATUS == "Aceito  "   '  COLOR "GREEN" TITLE STR0012   OF oBrowse   //"Termo Aceito"    
			ADD LEGEND DATA 'STATUS == "Pendente" '    COLOR "RED"   TITLE STR0013 OF oBrowse    //"Termo Pendente"    
			
			ADD BUTTON oButton TITLE STR0014 ACTION { ||oDlg:end() } OF oBrowse     // Sair   
			   
			ADD COLUMN oColumn DATA { || LOGIN    } TITLE STR0015 SIZE 15 OF oBrowse                        //"Login"
			ADD COLUMN oColumn DATA { || USUARIO  } TITLE STR0016 SIZE 30 OF oBrowse                        //"Usuario"
			ADD COLUMN oColumn DATA { || TERMO    } TITLE STR0017 SIZE TAMSX3("HWH_DESCRI")[1]+8 OF oBrowse //"Termo"
			ADD COLUMN oColumn DATA { || DT_ACEIT } TITLE STR0018 SIZE TAMSX3("HWI_DATA")[1] OF oBrowse     // "Dt_Aceite"
			ADD COLUMN oColumn DATA { || STATUS   } TITLE STR0019 SIZE 8 OF oBrowse                         //"Status"
		
		ACTIVATE FWFORMBROWSE oBrowse
	
   	ACTIVATE MSDIALOG oDlg CENTERED


oTempTable:Delete() 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HabilitCpo
HabilitCpo
@author  Thiago kobi Zoppi
@since   09/12/2012
/*/
//-------------------------------------------------------------------
Static Function HabilitCpo(oModel)
	Local lRet 		:= .T.
	Local cCodigo	:= oModel:GetValue("HWH_CODIGO") 
	Local cAliasQry	:= GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT
			COUNT(HWI_CODTER) AS COUNT 
		FROM %table:HWI% HWI
		WHERE HWI_FILIAL = %xFilial:HWI%
			AND HWI_CODTER =  %exp:cCodigo%
			AND HWI.%notDel%
	EndSql
	
	If (cAliasQry)->COUNT > 0 
		lRet := .F.
	ENDIF 

	(cAliasQry)->(DbCloseArea())
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MDMVlPos
MDMVlPos - Pos validacao do model
@author  Thiago kobi Zoppi
@since   09/12/2019
/*/
//-------------------------------------------------------------------
Static Function MDMVlPos( oModel )    
	Local nOperation := oModel:GetOperation()
	Local lRet       := .T.
	Local oModel	 :=	FWModelActive()
	Local oMdlHWH	 := oModel:GetModel('MASTERHWH')
	Local cCodigo    := oMdlHWH:GetValue("HWH_CODIGO")
	Local cAliasQry  := GetNextAlias()

   If  nOperation == MODEL_OPERATION_DELETE 
		
		BeginSql Alias cAliasQry
			SELECT
				COUNT(HWI_CODTER) AS COUNT 
			FROM %table:HWI% HWI
			WHERE HWI_FILIAL = %xFilial:HWI%
				AND HWI_CODTER =  %exp:cCodigo%
				AND HWI.%notDel%
		EndSql
		
		If (cAliasQry)->COUNT > 0 
			HELP(' ',1,STR0027 ,,STR0026,2,0,,,,,, {}) // "PCPA148 - MDMVlPos" //"Não foi possivel excluir o termo, pois existem usuários vinculados."
			lRet := .F.
		ENDIF 
     
   EndIf

Return( lRet )