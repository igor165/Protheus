#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA081.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA081
Cadastro MVC - Controle dos Creditos Fiscais - Pis/Pasep/Cofins

@author Rodrigo Aguilar
@since 15/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA081
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Controle dos Creditos Fiscais - Pis/Pasep/Cofins"                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
oBrw:SetAlias( 'C5F' )
oBrw:SetMenuDef( 'TAFA081' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Rodrigo Aguilar
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf081Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA081" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5F 	:= 	FWFormStruct( 1, 'C5F' )
Local oStruC5G 	:= 	FWFormStruct( 1, 'C5G' )
Local oStruC6P 	:= 	FWFormStruct( 1, 'C6P' )

Local oModel		:= MPFormModel():New( 'TAFA081' ,,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields('MODEL_C5F', /*cOwner*/, oStruC5F )

oModel:AddGrid('MODEL_C5G', 'MODEL_C5F', oStruC5G)  
oModel:AddGrid('MODEL_C6P', 'MODEL_C5G', oStruC6P)  

oModel:GetModel( 'MODEL_C5G' ):SetUniqueLine( { 'C5G_CDPAR' , 'C5G_CODMOD' , 'C5G_SER' , 'C5G_SUBSER' , 'C5G_NUMDOC' , 'C5G_DTOPER' } )
oModel:GetModel( 'MODEL_C6P' ):SetUniqueLine( { 'C6P_CODITE' , 'C6P_CSTPC' } )
                           
oModel:SetRelation( 'MODEL_C5G' , { { 'C5G_FILIAL' , 'xFilial( "C5G" )' } , { 'C5G_ID' , 'C5F_ID' } } , C5G->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C6P' , { { 'C6P_FILIAL' , 'xFilial( "C6P" )' } , { 'C6P_ID' , 'C5F_ID' }, {'C6P_CDPAR','C5G_CDPAR'},{'C6P_CODMOD','C5G_CODMOD'},{'C6P_SER','C5G_SER'},{'C6P_SUBSER','C5G_SUBSER'},{'C6P_NUMDOC','C5G_NUMDOC'},{'C6P_DTOPER','C5G_DTOPER'} } , C6P->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C5F" ):SetPrimaryKey( { "C5F_TPTRIB", "C5F_PERIOD", "C5F_PERAPR", "C5F_ORCRE", "C5F_CNPJ", "C5F_CDCRE" } )                                                                                  

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA081' )
Local oStruC5F 	:= 	FWFormStruct( 2, 'C5F' ) //Contr.Crd PIS/PASEP/COFINS    
Local oStruC5G 	:= 	FWFormStruct( 2, 'C5G' ) //Apuração de Crdto Extemporâneo
Local oStruC6P 	:= 	FWFormStruct( 2, 'C6P' ) //Apuração de Crdto Extemporâneo

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )   

oStruC5F:RemoveField('C5F_IDENT')

oView:AddField( 'VIEW_C5F', oStruC5F, 'MODEL_C5F' )
oView:EnableTitleView( 'VIEW_C5F', STR0002) //"Informações de Controle dos Creditos Fiscais" 

oView:AddGrid ( 'VIEW_C5G', oStruC5G, 'MODEL_C5G' )
oView:EnableTitleView( 'VIEW_C5G', STR0003) //"Documentos e Operacoes de Períodos Anteriores" 

oView:AddGrid ( 'VIEW_C6P', oStruC6P, 'MODEL_C6P' )
oView:EnableTitleView( 'VIEW_C6P', STR0004) //"Itens dos Documentos e Operacoes de Períodos Anteriores" 

oView:CreateHorizontalBox( 'FIELDSC5F', 30 )          
oView:CreateHorizontalBox( 'GRIDC5G', 35 ) 
oView:CreateHorizontalBox( 'GRIDC6P', 35 ) 

oView:SetOwnerView( 'VIEW_C5F', 'FIELDSC5F' )
oView:SetOwnerView( 'VIEW_C5G', 'GRIDC5G' )
oView:SetOwnerView( 'VIEW_C6P', 'GRIDC6P' )

If TamSX3("C6P_CODITE")[1] == 36
	oStruC6P:RemoveField("C6P_CODITE")
	oStruC6P:SetProperty("C6P_ITEM", 	MVC_VIEW_ORDEM, "09")
EndIf

If TamSX3("C5G_CODCTA")[1] == 36
	oStruC5G:RemoveField( "C5G_CODCTA")
	oStruC5G:SetProperty( "C5G_CTACTB", MVC_VIEW_ORDEM, "12" )
EndIf   

If TamSX3("C5G_CDPAR")[1] == 36
	oStruC5G:RemoveField( "C5G_CDPAR")
	oStruC5G:SetProperty( "C5G_PARTIC", MVC_VIEW_ORDEM, "04" )
EndIf   
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C5F", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF081Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF081Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""
Local cC5GKey  := ""
Local cC6PKey  := ""
Local nPISCOF  := 0

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5F->( Recno() )

If C5F->C5F_STATUS $ ( " |1" )

	If Empty(C5F->C5F_TPTRIB)
		AADD(aLogErro,{"C5F_TPTRIB","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	Else
		
		If !C5F->C5F_TPTRIB $ ('1|2')
			AADD(aLogErro,{"C5F_TPTRIB","000006", "C5F",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
		EndIf	
		
	EndIf

	If Empty(C5F->C5F_PERIOD)
		AADD(aLogErro,{"C5F_PERIOD","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5F->C5F_PERAPR)
		AADD(aLogErro,{"C5F_PERAPR","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5F->C5F_ORCRE)
		AADD(aLogErro,{"C5F_ORCRE","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	Else
	
		If !C5F->C5F_ORCRE $ ('01|02')
			AADD(aLogErro,{"C5F_ORCRE","000006", "C5F",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
		EndIf
		
	EndIf

	If Empty(C5F->C5F_CDCRE)
		AADD(aLogErro,{"C5F_CDCRE","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5F->C5F_VLCRAP)
		AADD(aLogErro,{"C5F_VLCRAP","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5F->C5F_TCRAPU)
		AADD(aLogErro,{"C5F_TCRAPU","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5F->C5F_VLCRDS)
		AADD(aLogErro,{"C5F_VLCRDS","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5F->C5F_SLCDIS)
		AADD(aLogErro,{"C5F_SLCDIS","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5F->C5F_SLCUTL)
		AADD(aLogErro,{"C5F_SLCUTL","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf


	//Valido o campo de CNPJ, passando o terceiro parametro da funcao CGC como .F.
	//Para que nao seja apresentado o alert de validacao                          
	If !Empty(C5F->C5F_CNPJ) 
		If !CGC(C5F->C5F_CNPJ,,.F.) 
			AADD(aLogErro,{"C5F_CNPJ", "000005", "C5F", nRecno }) //STR0005 - "CPF/CNPJ Inconsistente"    
		EndIf
	EndIf

	If !Empty(C5F->C5F_CDCRE)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C5F->C5F_CDCRE
		xValRegTab("C4D",cChave,3,,@aLogErro,, { "C5F", "C5F_CDCRE", nRecno } )
	EndIf	

	If !Empty(C5F->C5F_VLCRAP) .And. !Empty(C5F->C5F_VLCREX)
		If !(C5F->C5F_TCRAPU == (C5F->C5F_VLCRAP + C5F->C5F_VLCREX))
			AADD(aLogErro,{"C5F_TCRAPU","000541", "C5F",nRecno }) //STR0541 - "O valor deve corresponder à soma dos campos 'Vlr. Crd. Apur.' e 'Vlr. Crd. Ext.'."
		EndIf   
	EndIf	

	If !Empty(C5F->C5F_TCRAPU) .And. !Empty(C5F->C5F_VLCRDS) .And. !Empty(C5F->C5F_VCRRAN) .And. !Empty(C5F->C5F_VCRCAN)
		If !(C5F->C5F_SLCDIS == (C5F->C5F_TCRAPU - C5F->C5F_VLCRDS - C5F->C5F_VCRRAN - C5F->C5F_VCRCAN))
			AADD(aLogErro,{"C5F_SLCDIS","000542", "C5F",nRecno }) //STR0542 - "O valor deve corresponder à subtração do campo 'Vl. Cred. Apur.' menos os campos 'Vlr. Crd. Des. Ant.', 'Vl. Crd. Res. Ant.' e 'Vl. Crd. Comp. Ant.'."
		EndIf   
	EndIf	

	If !Empty(C5F->C5F_SLCDIS) .And. !Empty(C5F->C5F_VLCRDE) .And. !Empty(C5F->C5F_VCRRAT) .And. !Empty(C5F->C5F_VCRCAT) .And. !Empty(C5F->C5F_VCRTRA) .And. !Empty(C5F->C5F_VLOTCR)
		If !(C5F->C5F_SLCUTL == (C5F->C5F_SLCDIS - C5F->C5F_VLCRDE - C5F->C5F_VCRRAT - C5F->C5F_VCRCAT - C5F->C5F_VCRTRA - C5F->C5F_VLOTCR))
			AADD(aLogErro,{"C5F_SLCUTL","000543", "C5F",nRecno }) //STR0543 - "O valor deve corresponder à subtração do campo 'Sld. Crd. Disp.' menos os campos 'Vlr. Crd. Des. Atu.', 'Vl. Crd. Res. Atu.', 'Vl. Crd. Comp. Atu.', 'Vlr. Out. Crd.'."
		EndIf   
	EndIf	

	//INICIO C5G
	C5G->( DBSetOrder(1) )
	
	cC5GKey := C5F->C5F_ID
	If C5G->( MsSeek( xFilial("C5G") + cC5GKey ) )

		Do While !C5G->( Eof() ) .And. cC5GKey == C5G->C5G_ID

			If Empty(C5G->C5G_DTOPER)
				AADD(aLogErro,{"C5G_DTOPER","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C5G->C5G_CNPJRF)
				AADD(aLogErro,{"C5G_CNPJRF","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			Else
				If !CGC(C5G->C5G_CNPJRF,,.F.)
					AADD(aLogErro,{"C5G_CNPJRF","000005", "C5F",nRecno }) //STR0005 - "CPF/CNPJ Inconsistente" 
				EndIf
			EndIf
			
			/*If !Empty(C5G->C5G_CDPAR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5G->C5G_CDPAR
				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C5F", "C5G_CDPAR", nRecno } )
			EndIf*/	

			If !Empty(C5G->C5G_CODCTA)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5G->C5G_CODCTA
				xValRegTab("C1O",cChave,3,,@aLogErro,, { "C5F", "C5G_CODCTA", nRecno })
			EndIf
			
			If !Empty(C5G->C5G_CCUSTO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C5G->C5G_CCUSTO
				xValRegTab("C1P",cChave,3,,@aLogErro,, { "C5F", "C5G_CCUSTO", nRecno })
			EndIf
			
			//³INICIO C6P
			C6P->( DBSetOrder(1) )
			
			cC6PKey := C5G->(C5G_ID + C5G_CDPAR + C5G_CODMOD + C5G_SER + C5G_SUBSER + C5G_NUMDOC + DToS(C5G_DTOPER))
			If C6P->( MsSeek( xFilial("C6P") + cC6PKey ) )
		
				Do While !C6P->( Eof() ) .And. cC6PKey == C6P->(C6P_ID + C6P_CDPAR + C6P_CODMOD + C6P_SER + C6P_SUBSER + C6P_NUMDOC + DToS(C6P_DTOPER))
		
					If Empty(C6P->C6P_VLOPER)
						AADD(aLogErro,{"C6P_VLOPER","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C6P->C6P_CFOP)
						AADD(aLogErro,{"C6P_CFOP","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C6P->C6P_CNATBC)
						AADD(aLogErro,{"C6P_CNATBC","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C6P->C6P_ORCRE)
						AADD(aLogErro,{"C6P_ORCRE","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C6P->C6P_CSTPC)
						AADD(aLogErro,{"C6P_CSTPC","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C6P->C6P_VLBCPC)
						AADD(aLogErro,{"C6P_VLBCPC","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C6P->C6P_ALQPC)
						AADD(aLogErro,{"C6P_ALQPC","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C6P->C6P_VLRPC)
						AADD(aLogErro,{"C6P_VLRPC","000010", "C5F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If !Empty(C6P->C6P_CODITE)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C6P->C6P_CODITE
						xValRegTab("C1L",cChave,3,,@aLogErro,, { "C5F", "C6P_CODITE", nRecno } )
					EndIf	

					If !Empty(C6P->C6P_CFOP)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C6P->C6P_CFOP
						xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C5F", "C6P_CFOP", nRecno })
					EndIf
					
					If !Empty(C6P->C6P_CNATBC)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C6P->C6P_CNATBC
						xValRegTab("C11",cChave,3,,@aLogErro,, { "C5F", "C6P_CNATBC", nRecno })
					EndIf
					
					If !Empty(C6P->C6P_CSTPC)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C6P->C6P_CSTPC
						xValRegTab("C17",cChave,3,,@aLogErro,, { "C5F", "C6P_CSTPC", nRecno })
					EndIf
					
					If !C6P->C6P_ORCRE $ ('0|1')
						AADD(aLogErro,{"C6P_ORCRE","000006", "C5F",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
					EndIf	

					nPISCOF := nPISCOF + C6P->C6P_VLRPC 
		
					C6P->( DbSkip() )
				EndDo
			EndIf
			//FIM C6P

			C5G->( DbSkip() )
		EndDo
	EndIf
	//FIM C5G

	If !Empty(C5F->C5F_VLCREX) .And. !Empty(nPISCOF)
		If !(C5F->C5F_VLCREX == nPISCOF)
			AADD(aLogErro,{"C5F_VLCREX","000544", "C5F",nRecno }) //STR0544 - "O valor deve corresponder ao somatório de todos os valores informados no campo 'Vlr. Pis/Cof.' (C6P_VLRPC)."
		EndIf 
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C5F", cStatus )

Else
	AADD(aLogErro,{"C5F_ID","000305","C5F",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)