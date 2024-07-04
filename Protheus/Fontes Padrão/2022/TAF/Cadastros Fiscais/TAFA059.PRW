#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA059.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA059
Cadastro de Natureza de Operação

@author Marcio Nunes
@since 23/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA059()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Natureza de Operação
oBrw:SetAlias( 'C1N')
oBrw:SetMenuDef( 'TAFA059' ) 
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf059Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA059" , , aFuncao)

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 23/07/2012
@version 1.0
/*/XFUNVldUni("C1N",1, M->C1N_CODNAT)                                                                                              
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1N 	:= 	FWFormStruct( 1, 'C1N' )
Local oModel		:= MPFormModel():New( 'TAFA059' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C1N', /*cOwner*/, oStruC1N)     
oModel:GetModel( "MODEL_C1N" ):SetPrimaryKey( { "C1N_CODNAT" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA059' )
Local 	oStruC1N 	:= 	FWFormStruct( 2, 'C1N' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oStruC1N:RemoveField('C1N_IDNATE')
oStruC1N:RemoveField('C1N_IDOPAN')
oView:AddField( 'VIEW_C1N', oStruC1N, 'MODEL_C1N' )

oView:EnableTitleView( 'VIEW_C1N', STR0001 ) //Cadastro de Natureza de Operação
oView:CreateHorizontalBox( 'FIELDSC1N', 100 )
oView:SetOwnerView( 'VIEW_C1N', 'FIELDSC1N' )


If TAFColumnPos( "C1N_ID" )
	If TamSX3("C1N_ID")[1] == 36
		oStruC1N:RemoveField("C1N_ID")				
	EndIf
EndIf

If TAFColumnPos( "C1N_IDMOT" )
	If TamSX3("C1N_IDMOT")[1] == 36
		oStruC1N:RemoveField("C1N_IDMOT")				
	EndIf
EndIf	

If TAFColumnPos( "C1N_IDREG" )
	If TamSX3("C1N_IDREG")[1] == 36
		oStruC1N:RemoveField("C1N_IDREG")				
	EndIf
EndIf	

If TAFColumnPos( "C1N_IDTIPO" )
	If TamSX3("C1N_IDTIPO")[1] == 36
		oStruC1N:RemoveField("C1N_IDTIPO")				
	EndIf
EndIf

If TAFColumnPos( "C1N_IDSIT" )
	If TamSX3("C1N_IDSIT")[1] == 36
		oStruC1N:RemoveField("C1N_IDSIT")				
	EndIf
EndIf

If TAFColumnPos( "C1N_IDEXIG" )
	If TamSX3("C1N_IDEXIG")[1] == 36
		oStruC1N:RemoveField("C1N_IDEXIG")				
	EndIf
EndIf	

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C1N", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF059Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF059Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C1N->( Recno() )

If C1N->C1N_STATUS $ ( " |1" )

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C1N", cStatus )
	
Else
	AADD(aLogErro,{"C1N_ID","000305", "C1N", nRecno })
	
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro) 

//-------------------------------------------------------------------
/*/{Protheus.doc} C1NInicia

Funcao que valida o inicializador padrao dos campos virtuais da C1N

@author Matheus Prada
@since 04/11/2019
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function C1NInicia(cCampo)

Local cInic := ''

If !(ProcName() == "TAFXDBH")

	cCampo := Alltrim(SubStr(cCampo,At('>',cCampo)+1, Len(cCampo) ))

	Do Case
	
		Case cCampo == "C1N_CODANP"
		cInic:= IIF(!INCLUI .AND. !EMPTY(C1N->C1N_IDOPAN),POSICIONE("T5A",1,XFILIAL("T5A")+C1N->C1N_IDOPAN,"T5A_CODOPE"),"")

		Case cCampo == "C1N_DESANP"
		cInic:= IIF(!INCLUI.AND.!EMPTY(C1N->C1N_IDOPAN),POSICIONE("T5A",1,XFILIAL("T5A")+C1N->C1N_IDOPAN,"T5A_CODOPE+' - '+T5A_ESPECI"),"")

		Case cCampo == "C1N_NATECF"
		cInic:= IIF(!INCLUI .and. !Empty(C1N->C1N_IDNATE),Posicione("CHK",1,xFilial("CHK")+C1N->C1N_IDNATE,"CHK_CODIGO"),"")

		Case cCampo == "C1N_DNATEC"
		cInic:= IIF(!INCLUI .and. !Empty(C1N->C1N_IDNATE),Posicione("CHK",1,xFilial("CHK")+C1N->C1N_IDNATE,"CHK_DESCRI"),"")     

		Case cCampo == "C1N_CODMOT"
		cInic:= IIF(!INCLUI .AND. !EMPTY(C1N->C1N_IDMOT),POSICIONE("T81",1,XFILIAL("T81")+C1N->C1N_IDMOT,"T81_CODIGO"),"")

		Case cCampo == "C1N_DESMOT"
		cInic:= IIF(!INCLUI.AND.!EMPTY(C1N->C1N_IDMOT),POSICIONE("T81",1,XFILIAL("T81")+C1N->C1N_IDMOT,"T81_CODIGO+' - '+T81_DESCRI"),"")

		Case cCampo == "C1N_CODREG"
		cInic:= IIF(!INCLUI .AND. !EMPTY(C1N->C1N_IDREG),POSICIONE("T82",1,XFILIAL("T82")+C1N->C1N_IDREG,"T82_CODIGO"),"")

		Case cCampo == "C1N_DESREG"
		cInic:= IIF(!INCLUI.AND.!EMPTY(C1N->C1N_IDREG),POSICIONE("T82",1,XFILIAL("T82")+C1N->C1N_IDREG,"T82_CODIGO+' - '+T82_DESCRI"),"")

		Case cCampo == "C1N_CODTIP"
		cInic:= IIF(!INCLUI .AND. !EMPTY(C1N->C1N_IDTIPO),POSICIONE("T83",1,XFILIAL("T83")+C1N->C1N_IDTIPO,"T83_CODIGO"),"")

		Case cCampo == "C1N_DESTIP"
		cInic:= IIF(!INCLUI.AND.!EMPTY(C1N->C1N_IDTIPO),POSICIONE("T83",1,XFILIAL("T83")+C1N->C1N_IDTIPO,"T83_CODIGO+' - '+T83_DESCRI"),"")

		Case cCampo == "C1N_CODSIT"
		cInic:= IIF(!INCLUI .AND. !EMPTY(C1N->C1N_IDSIT),POSICIONE("T84",1,XFILIAL("T84")+C1N->C1N_IDSIT,"T84_CODIGO"),"")

		Case cCampo == "C1N_DESSIT"
		cInic:= IIF(!INCLUI.AND.!EMPTY(C1N->C1N_IDSIT),POSICIONE("T84",1,XFILIAL("T84")+C1N->C1N_IDSIT,"T84_CODIGO+' - '+T84_DESCRI"),"")

		Case cCampo == "C1N_CODEXI"
		cInic:= IIF(!INCLUI .AND. !EMPTY(C1N->C1N_IDEXIG),POSICIONE("T85",1,XFILIAL("T85")+C1N->C1N_IDEXIG,"T85_CODIGO"),"")

		Case cCampo == "C1N_DESEXI"
		cInic:= IIF(!INCLUI.AND.!EMPTY(C1N->C1N_IDEXIG),POSICIONE("T85",1,XFILIAL("T85")+C1N->C1N_IDEXIG,"T85_CODIGO+' - '+T85_DESCRI"),"")

	EndCase
EndIf 

Return cInic