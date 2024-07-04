#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA083.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA083
Cadastro MVC de Controle dos creditos fiscais - ICMS

@author Danilo L Zanaga
@since 10/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA083()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Controle dos creditos fiscais - ICMS
oBrw:SetAlias('C50')
oBrw:SetMenuDef( 'TAFA083' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf083Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA083" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC50 	:= 	FWFormStruct( 1, 'C50' )
Local oStruC51 	:= 	FWFormStruct( 1, 'C51' )
Local 	oModel 	:=  MPFormModel():New( 'TAFA083' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C50', /*cOwner*/, oStruC50)
                           	
oModel:AddGrid('MODEL_C51', 'MODEL_C50', oStruC51)             
oModel:GetModel( 'MODEL_C51' ):SetUniqueLine({ 'C51_TPUTIL','C51_NRODOC'}) 

oModel:SetRelation( 'MODEL_C51' , { { 'C51_FILIAL' , 'xFilial( "C51" )' } , { 'C51_ID' , 'C50_ID' } } , C51->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C50" ):SetPrimaryKey( { "C50_PERIOD", "C50_CODAJU" } )                                                                                                                          
oModel:GetModel( 'MODEL_C51' ):SetOptional( .T. )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA083' )
Local 	oStruC50 	:= 	FWFormStruct( 2, 'C50' )
Local   oStruC51 	:= 	FWFormStruct( 2, 'C51' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C50', oStruC50, 'MODEL_C50' )
oView:EnableTitleView( 'VIEW_C50', STR0001 ) //Controle dos creditos fiscais - ICMS

oView:AddGrid ( 'VIEW_C51', oStruC51, 'MODEL_C51' )
oView:EnableTitleView( 'VIEW_C51', STR0002) //"Itens do Documento de Exportação"


oView:CreateHorizontalBox( 'FIELDSC50', 50 )
oView:CreateHorizontalBox( 'GRIDC51', 50)
oView:SetOwnerView( 'VIEW_C50', 'FIELDSC50' )
oView:SetOwnerView( 'VIEW_C51', 'GRIDC51' )

Return oView	  


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		//Funcao responsavel por setar o Status do registro para Branco³
		TAFAltStat( "C50", " " )	
	EndIf
	FwFormCommit( oModel )
        
End Transaction
       
Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF083Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF083Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}  
Local nCrdUtil  := C50->C50_CRDUTI
Local nTotCrUt  := 0
Local nTotCrAc  := 0

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C50->( Recno() )

If C50->C50_STATUS $ ( " |1" )
	
	// Validação de campos obrigatórios
	If Empty(C50->C50_PERIOD)
 		aAdd(aLogErro,{"C50_PERIOD","000010","C50",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C50->C50_CODAJU)
 		aAdd(aLogErro,{"C50_CODAJU","000010","C50",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C50->C50_SLDCRD)
 		aAdd(aLogErro,{"C50_SLDCRD","000010","C50",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C50->C50_CRDAPR)
 		aAdd(aLogErro,{"C50_CRDAPR","000010","C50",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C50->C50_CRDREC)
 		aAdd(aLogErro,{"C50_CRDREC","000010","C50",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C50->C50_CRDUTI)
 		aAdd(aLogErro,{"C50_CRDUTI","000010","C50",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty(C50->C50_SDCRFI)
 		aAdd(aLogErro,{"C50_SDCRFI","000010","C50",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf
	
	//Id Codigo Apuracao (ICMS)
	If !Empty(C50->C50_CODAJU)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C50->C50_CODAJU
		xValRegTab("C1A",cChave,4,,@aLogErro,, { "C50", "C50_CODAJU", nRecno } )
	EndIf
	
	//Valida a Grid Utilização de crédico fiscais 	
	dbSelectArea("C51")
	C51->(dbSetORder(1))
	If C51->(MsSeek(xFilial("C51") + C50->C50_ID))
		cId:=C51->C51_ID
		While (!C51->(Eof()) .And. cId==C51->C51_ID)

			// Validação de campos obrigatórios
			If Empty(C51->C51_TPUTIL)
		 		aAdd(aLogErro,{"C51_TPUTIL","000010","C51",nRecno}) //"Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C51->C51_CRUTIL)
		 		aAdd(aLogErro,{"C51_CRUTIL","000010","C51",nRecno}) //"Campo Inconsistente ou Vazio"
			EndIf
			
			//Total de credito utilizado
			If !(C51->C51_CRUTIL > 0)
				AADD(aLogErro,{"C51_CRUTIL","000520","C51", nRecno }) //STR0520 - "O valor informado no campo deve ser maior que 0 (zero)"
			EndIF     
			
			nTotCrUt += C51->C51_CRUTIL 			
			
			//Id Codigo Credito (ICMS)
			If !Empty(C51->C51_TPUTIL)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C51->C51_TPUTIL
				xValRegTab("C4Z",cChave,3,,@aLogErro,, { "C50", "C51_TPUTIL", nRecno } )
			EndIf			
			C51->(dbSkip())
		Enddo
	Endif   
	
	//Total de credito utilizado no período
	If !(nCrdUtil == nTotCrUt)
		AADD(aLogErro,{"C50_CRDUTI","000522","C50", nRecno }) //STR0022 - "O valor informado neste campo deve ser igual ao somatório do campo Tot.Cr.Util"
				
	EndIF   
	
	//Saldo de crédito fiscal acumulado
	nTotCrAc:= (C50->C50_SLDCRD + C50->C50_CRDAPR + C50->C50_CRDREC) - nCrdUtil
   
	If !(C50->C50_SDCRFI == nTotCrAc)
		AADD(aLogErro,{"C50_SDCRFI","000523","C50", nRecno }) //STR0523 - "O valor desse campo deve ser igual à soma dos valores dos campos Sld.Crd.Fisc, Tot.Crd.Apr. e Tot.Crd.Rec. diminuido do valor do campo Tot.Crd.Uti."
				
	EndIF  

	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C50",.F.)
			C50->C50_STATUS := "1"
		C50->( MsUnlock() )
	Else
		RecLock("C50",.F.)
			C50->C50_STATUS := "0"
		C50->( MsUnlock() )
	EndIf
	
Else	
	AADD(aLogErro,{"C50_ID","000305", "C50", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar³
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)