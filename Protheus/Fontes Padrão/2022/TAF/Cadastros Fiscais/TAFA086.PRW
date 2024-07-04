#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA086.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA086
Cadastro MVC de Cadastro de Bombas

@author Danilo L Zanaga
@since 14/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA086()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Bombas
oBrw:SetAlias( 'C55')
oBrw:SetMenuDef( 'TAFA086' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Danilo L Zanaga
@since 14/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf086Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA086' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA086" , , aFuncao)
EndIf                                     

Return( aRotina )  
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 14/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC55 	:= 	FWFormStruct( 1, 'C55' )
Local oStruC56 	:= 	FWFormStruct( 1, 'C56' )
Local oStruC57 	:= 	FWFormStruct( 1, 'C57' )
Local oModel 	:= 	MPFormModel():New( 'TAFA086' ,,, { |oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C55', /*cOwner*/, oStruC55)
                                         
oModel:AddGrid('MODEL_C56', 'MODEL_C55', oStruC56)             
oModel:GetModel( 'MODEL_C56' ):SetUniqueLine({'C56_NMLACR','C56_DTAPLI'}) 
oModel:SetRelation( 'MODEL_C56' , { { 'C56_FILIAL' , 'xFilial( "C56" )' } , { 'C56_ID' , 'C55_ID' } } , C56->( IndexKey( 1 ) ) )

oModel:AddGrid('MODEL_C57', 'MODEL_C55', oStruC57)             
oModel:GetModel( 'MODEL_C57' ):SetUniqueLine({'C57_NMBICO','C57_CODIGO','C57_NMTANQ'}) 
oModel:SetRelation( 'MODEL_C57' , { { 'C57_FILIAL' , 'xFilial( "C57" )' } , { 'C57_ID' , 'C55_ID' } } , C57->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C55" ):SetPrimaryKey( { "C55_SERIE", "C55_MODELO" } )                                                                                                                                  

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 14/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA086' )
Local 	oStruC55 	:= 	FWFormStruct( 2, 'C55' )
Local   oStruC56 	:= 	FWFormStruct( 2, 'C56' )
Local   oStruC57 	:= 	FWFormStruct( 2, 'C57' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C55', oStruC55, 'MODEL_C55' )
oView:EnableTitleView( 'VIEW_C55', STR0001 ) //Cadastro de Bombas
                                             
oView:AddGrid ( 'VIEW_C56', oStruC56, 'MODEL_C56' )
oView:EnableTitleView( 'VIEW_C56', STR0002) //"Lacres das bombas"

oView:AddGrid ( 'VIEW_C57', oStruC57, 'MODEL_C57' )
oView:EnableTitleView( 'VIEW_C57', STR0003) //"Bicos das bombas"


oView:CreateHorizontalBox( 'FIELDSC55', 40 )
oView:CreateHorizontalBox( 'GRIDC56', 30)
oView:CreateHorizontalBox( 'GRIDC57', 30)

oView:SetOwnerView( 'VIEW_C55', 'FIELDSC55' )
oView:SetOwnerView( 'VIEW_C56', 'GRIDC56' )
oView:SetOwnerView( 'VIEW_C57', 'GRIDC57' )

If TamSX3("C57_CODIGO")[1] == 36
	oStruC57:RemoveField("C57_CODIGO")
	oStruC57:SetProperty("C57_ITEM", MVC_VIEW_ORDEM, "04" )	
EndIf
Return oView	                                                

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 19/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()  
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'C55', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction


Return .T.                    

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf058Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf086Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro  := {} 
Local cChave    := ""           
Local cID		  := ""

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C55->( Recno() )

If (C55->C55_STATUS $ (' 1'))  
	If Empty(C55->C55_SERIE)
		aAdd(aLogErro,{"C55_SERIE","000010","C55",nRecno}) //"Campo Inconsistente ou Vazio"  
	EndIf
	
	If Empty(C55->C55_FABRIC)
		aAdd(aLogErro,{"C55_FABRIC","000010","C55",nRecno}) //"Campo Inconsistente ou Vazio"  
	EndIf
	
	If Empty(C55->C55_MODELO)
		aAdd(aLogErro,{"C55_MODELO","000010","C55",nRecno}) //"Campo Inconsistente ou Vazio"  
	EndIf                               
	
	If Empty(C55->C55_TPMEDI )
		aAdd(aLogErro,{"C55_TPMEDI","000010","C55",nRecno}) //"Campo Inconsistente ou Vazio"  
	ElseIf !(C55->C55_TPMEDI $ ("01"))
		aAdd(aLogErro,{"C55_TPMEDI","000006","C55",nRecno}) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
	EndIf
	
	//Valída o Conteúdo do Campo Código, na Grid "Bicos de Bombas (C57)"   
	dbSelectArea("C57")
	dbSetOrder(1)
	If MsSeek(xFilial("C57") + C55->C55_ID) 
		cID:= C57->C57_ID
		While (!C57->(Eof()) .And. C57->C57_ID== cID)   
			If !Empty(C57->C57_CODIGO)  
				cChave := C57->C57_CODIGO
				xValRegTab("C1L",cChave,3,,@aLogErro,, { "C55", "C57_CODIGO", nRecno } )
			EndIf				 
			C57->(dbSkip()) 
			cID:= C57->C57_ID 
		Enddo
		             
	EndIf                                                              
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C55",.F.)
		    C55->C55_STATUS := "1" 
	 	C55->( MsUnlock() )    
	Else
		RecLock("C55",.F.)
	    	C55->C55_STATUS := "0" 
	    C55->( MsUnlock() )        
	EndIf

Else
	AADD(aLogErro,{"C55_ID","000305", "C55", nRecno })   //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
