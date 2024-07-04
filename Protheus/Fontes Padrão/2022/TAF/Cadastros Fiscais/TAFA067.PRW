#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA067.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA067
Cadastro MVC de Demais documentos

@author Fabio V Santana
@since 27/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA067
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Demais documentos
oBrw:SetAlias( 'C3B')
oBrw:SetMenuDef( 'TAFA067' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 27/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf067Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA067' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA067" , , aFuncao)
EndIf                                     

Return( aRotina )  
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 27/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3B 	:= 	FWFormStruct( 1, 'C3B' )
Local oStruC3C 	:= 	FWFormStruct( 1, 'C3C' )

Local 	oModel 	:= 	MPFormModel():New('TAFA067',,,{ |oModel| SaveModel( oModel ) }  )

oModel:AddFields('MODEL_C3B', /*cOwner*/, oStruC3B)

oModel:AddGrid('MODEL_C3C', 'MODEL_C3B', oStruC3C)

oModel:GetModel( 'MODEL_C3C' ):SetUniqueLine( { 'C3C_NUMPRO'} )  
                                                       
oModel:SetRelation( 'MODEL_C3C' , { { 'C3C_FILIAL' , 'xFilial( "C3C" )' } , { 'C3C_ID' , 'C3B_ID' }} , C3C->( IndexKey( 1 ) ) )   

oModel:GetModel( 'MODEL_C3C' ):SetOptional( .T. )    

oModel:GetModel( "MODEL_C3B" ):SetPrimaryKey ( { "C3B_INDOPE", "C3B_CODPAR", "C3B_CODITE" , "C3B_DTOPER" } )                                                                                                    

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 27/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA067' )
Local oStruC3B 	:= 	FWFormStruct( 2, 'C3B' )
Local oStruC3C 	:= 	FWFormStruct( 2, 'C3C' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )

If TamSX3("C3B_CODCTA")[1] == 36
	oStruC3B:RemoveField("C3B_CODCTA")
	oStruC3B:SetProperty("C3B_CTACTB", MVC_VIEW_ORDEM, "26")	
	oStruC3B:SetProperty("C3B_DCODCT", MVC_VIEW_ORDEM, "27")
	oStruC3B:SetProperty("C3B_CODCUS", MVC_VIEW_ORDEM, "28")
	oStruC3B:SetProperty("C3B_DCODCU", MVC_VIEW_ORDEM, "29")
	oStruC3B:SetProperty("C3B_DESDOC", MVC_VIEW_ORDEM, "30")	
EndIf

If TamSX3("C3B_CODPAR")[1] == 36
	oStruC3B:RemoveField( "C3B_CODPAR")
	oStruC3B:SetProperty( "C3B_PARTIC", MVC_VIEW_ORDEM, "07" )
EndIf

If TamSX3("C3B_CODITE")[1] == 36
	oStruC3B:RemoveField("C3B_CODITE")
	oStruC3B:SetProperty("C3B_ITEM", MVC_VIEW_ORDEM, "08")
EndIf

oView:AddField( 'VIEW_C3B', oStruC3B, 'MODEL_C3B' )
oView:EnableTitleView( 'VIEW_C3B', STR0001) //Demais Documentos

oView:AddGrid ( 'VIEW_C3C', oStruC3C, 'MODEL_C3C' )

oView:CreateHorizontalBox( 'FIELDSC3B', 60 )          

oView:CreateHorizontalBox( 'GRIDC3C', 40,,,,)

oView:SetOwnerView( 'VIEW_C3B', 'FIELDSC3B' )
oView:SetOwnerView( 'VIEW_C3C', 'GRIDC3C' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)
Local 	nOperation 	:= 	oModel:GetOperation()  
                     
Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C3B", "" )								          				
	EndIf  
	FwFormCommit( oModel )			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF067Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF067Vld(cAlias,nRecno,nOpc,lJob)

Local aCampos		:= {} //{Campo do registro filho/consulta padrao , opcao de validacao , opcao do combo(opcional)}
Local aLogErro	:= {}
Local cStatus		:= ""
Local aDadosUtil	:= {} 

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C3B->( Recno() ) 

If C3B->C3B_STATUS $ ( " |1" )

	/*+------------------------------------------------------+
	  | Data:08.09.2014	     	                 				 |
	  | Responsável: Evandro dos Santos Oliveira             |
	  | Descrição da Alteração: Inclusão das validações para |
	  | os campos obrigatórios	 						   	 	 |
	  +------------------------------------------------------+*/ 	
	If Empty(C3B->C3B_DTOPER)
		aAdd(aLogErro,{"C3B_DTOPER"	,"000010","C3B",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C3B->C3B_INDOPE)
		aAdd(aLogErro,{"C3B_INDOPER","000010","C3B",nRecno}) //"Campo Inconsistente ou Vazio" 
	Else
		xValRegTab("C3D",C3B_INDOPER,3,,@aLogErro,, { "C3B", "C3B_INDOPER", nRecno } )
	EndIf	
	
	If Empty(C3B->C3B_CODPAR)
		aAdd(aLogErro,{"C3B_CODPAR"	,"000010","C3B",nRecno}) //"Campo Inconsistente ou Vazio" 
	Else
		xValRegTab("C1H",C3B->C3B_CODPAR,5,,@aLogErro,, { "C3B", "C3B_CODPAR", nRecno } )
	EndIf	

	If Empty(C3B->C3B_NATBC)
		aAdd(aLogErro,{"C3B_NATBC"	,"000010","C3B",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C3B->C3B_CSTPIS)
		aAdd(aLogErro,{"C3B_CSTPIS"	,"000010","C3B",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf

	If Empty(C3B->C3B_CSTCOF)
		aAdd(aLogErro,{"C3B_CSTCOF" ,"000010","C3B",nRecno}) //"Campo Inconsistente ou Vazio" 
	EndIf
	

	If !Empty(C3B->C3B_CODITE)
		xValRegTab("C1L",C3B->C3B_CODITE,3,,@aLogErro,, { "C3B", "C3B_CODITE", nRecno } )
	EndIf

	If !Empty(C3B->C3B_NATBC)
		xValRegTab("C11",C3B->C3B_NATBC,3,,@aLogErro,,  { "C3B", "C3B_NATBC", nRecno } )
	EndIf	

	If !Empty(C3B->C3B_CODCUS)
		xValRegTab("C1P",C3B->C3B_CODCUS,3,,@aLogErro,, { "C3B", "C3B_CODCUS", nRecno } )
	EndIf		

	If !Empty(C3B->C3B_CSTPIS)
		xValRegTab("C17",C3B->C3B_CSTPIS,3,,@aLogErro,, { "C3B", "C3B_CSTPIS", nRecno } )
	EndIf	
	
	If !Empty(C3B->C3B_CSTCOF)
		xValRegTab("C17",C3B->C3B_CSTCOF,3,,@aLogErro,, { "C3B", "C3B_CSTCOF", nRecno } )
	EndIf	
	
	If !Empty(C3B->C3B_CODCTA)
		xValRegTab("C1O",C3B->C3B_CODCTA,3,,@aLogErro,, { "C3B", "C3B_CODCTA", nRecno } )
	EndIf	
	
	dbSelectArea("C3C")
	dbSetOrder(1)
	If C3C->(MsSeek(xFilial("C3C")))
		While !C3C->(Eof()) .And. C3B->C3B_ID == C3C->C3C_ID
			If Empty(C3C->C3C_NUMPRO)
				aAdd(aLogErro,{"C3C_NUMPRO"	,"000010","C3B",nRecno}) //"Campo Inconsistente ou Vazio" 
			Else
				xValRegTab("C1G",C3C->C3C_NUMPRO,3,,@aLogErro,, { "C3C", "C3C_NUMPRO", nRecno } )
			EndIf	
			C3C->(dbSkip())	
		EndDo
	EndIf


	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")

	If RecLock("C3B",.F.)
		C3B->C3B_STATUS := cStatus
		C3B->(MsUnlock())
	EndIf
Else
	AADD(aLogErro,{"C3B_ID","000305","C3B",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
