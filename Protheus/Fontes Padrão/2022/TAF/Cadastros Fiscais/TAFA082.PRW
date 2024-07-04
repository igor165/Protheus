#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA082.CH"
//--------------------------------------------------------------------
/*/{Protheus.doc} TAFA082
Cadastro MVC de Informacoes de Exportacao - Complemento do Documento

@author Fabio V Santana
@since 06/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA082
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Informacoes de Exportacao - Complemento do Documento
oBrw:SetAlias( 'C4F')
oBrw:SetMenuDef( 'TAFA082' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 06/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf082Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA082" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 06/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4F 	:= 	FWFormStruct( 1, 'C4F' )
Local oStruC4G 	:= 	FWFormStruct( 1, 'C4G' )
Local oStruC4H 	:= 	FWFormStruct( 1, 'C4H' )

Local oModel		:= MPFormModel():New( 'TAFA082' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C4F', /*cOwner*/, oStruC4F)

oModel:AddGrid('MODEL_C4G', 'MODEL_C4F', oStruC4G)
If TAFColumnPos('C4G_SEQUEN')
	oModel:GetModel( 'MODEL_C4G' ):SetUniqueLine({ 'C4G_CODMOD','C4G_SERIE','C4G_NUMDOC','C4G_DTDOC','C4G_CODITE','C4G_SEQUEN'})
Else
	oModel:GetModel( 'MODEL_C4G' ):SetUniqueLine({ 'C4G_CODMOD','C4G_SERIE','C4G_NUMDOC','C4G_DTDOC','C4G_CODITE'})
EndIf 

oModel:AddGrid('MODEL_C4H', 'MODEL_C4F', oStruC4H)
oModel:GetModel( 'MODEL_C4H' ):SetUniqueLine({ 'C4H_CODPAR','C4H_CODMOD','C4H_SERIE','C4H_NUMDOC','C4H_DTDOC'})  
oModel:GetModel( 'MODEL_C4H' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C4G' , { { 'C4G_FILIAL' , 'xFilial( "C4G" )' } , { 'C4G_ID' , 'C4F_ID' }} , C4G->( IndexKey( 1 ) ) )

oModel:SetRelation( 'MODEL_C4H' , { { 'C4H_FILIAL' , 'xFilial( "C4H" )' } , { 'C4H_ID' , 'C4F_ID' } , { 'C4H_CMOD', 'C4G_CODMOD' }, { 'C4H_SER', 'C4G_SERIE' }, { 'C4H_DOC', 'C4G_NUMDOC' }, { 'C4H_DT', 'C4G_DTDOC' }, { 'C4H_CODITE', 'C4G_CODITE' } } , C4H->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C4F" ):SetPrimaryKey( { "C4F_INDDOC" ,"C4F_NRODE", "C4F_DTDE", "C4F_NATEXP" } )                                                                                                       

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 06/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA082' )
Local oStruC4F 	:= 	FWFormStruct( 2, 'C4F' )
Local oStruC4G 	:= 	FWFormStruct( 2, 'C4G' )
Local oStruC4H 	:= 	FWFormStruct( 2, 'C4H' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4F', oStruC4F, 'MODEL_C4F' )
oView:EnableTitleView( 'VIEW_C4F', STR0001) //Informacoes de Exportacao - Complemento do Documento

oView:AddGrid ( 'VIEW_C4G', oStruC4G, 'MODEL_C4G' )
oView:EnableTitleView( 'VIEW_C4G', STR0002) //"Itens do Documento de Exportação"

oView:AddGrid ( 'VIEW_C4H', oStruC4H, 'MODEL_C4H' )
oView:EnableTitleView( 'VIEW_C4H', STR0003) //"Exportacoes Indiretas - Mercadorias de Terceiros"

oView:CreateHorizontalBox( 'FIELDSC4F', 40 )          

oView:CreateHorizontalBox( 'GRIDC4G', 30,,,,)
oView:CreateHorizontalBox( 'GRIDC4H', 30,,,,)

oView:SetOwnerView( 'VIEW_C4F', 'FIELDSC4F' )
oView:SetOwnerView( 'VIEW_C4G', 'GRIDC4G' )
oView:SetOwnerView( 'VIEW_C4H', 'GRIDC4H' )

If TAFColumnPos('C4G_SEQUEN')
	oView:AddIncrementField( 'VIEW_C4G', 'C4G_SEQUEN' )
EndIf 

If TamSX3("C4H_CODPAR")[1] == 36
	oStruC4H:SetProperty("C4H_CPARTI", MVC_VIEW_ORDEM, "08" )
	oStruC4H:RemoveField("C4H_CODPAR")
EndIf

If TamSX3("C4G_CODITE")[1] == 36
	oStruC4G:RemoveField("C4G_CODITE")
	oStruC4G:SetProperty("C4G_ITEM", MVC_VIEW_ORDEM, "09" )	
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
		TAFAltStat( "C4F", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF082Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF082Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""
Local cCodMod  := ""
Local cC4GKey  := ""
Local cC4HKey  := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4F->( Recno() )

If C4F->C4F_STATUS $ ( " |1" )

	If Empty(C4F->C4F_INDDOC)
		AADD(aLogErro,{"C4F_INDDOC","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4F->C4F_NRODE)
		AADD(aLogErro,{"C4F_NRODE","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4F->C4F_DTDE)
		AADD(aLogErro,{"C4F_DTDE","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4F->C4F_NATEXP)
		AADD(aLogErro,{"C4F_NATEXP","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4F->C4F_DTAVB)
		AADD(aLogErro,{"C4F_DTAVB","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !C4F->C4F_INDDOC $ (' 0|1')
		AADD(aLogErro,{"C4F_INDDOC","000006", "C4F",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	If !C4F->C4F_NATEXP $ (' 0|1|2|3')
		AADD(aLogErro,{"C4F_NATEXP","000006", "C4F",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	If !Empty(C4F->C4F_TPCHC)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4F->C4F_TPCHC
		xValRegTab("C0S",cChave,3,,@aLogErro,, { "C4F", "C4F_TPCHC", nRecno } )
	EndIf	

	If !Empty(C4F->C4F_PAIS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4F->C4F_PAIS
		xValRegTab("C08",cChave,3,,@aLogErro,, { "C4F", "C4F_PAIS", nRecno } )
	EndIf	

	If (C4F->C4F_INDDOC == "0") .And. Empty(C4F->C4F_NRORE)
		AADD(aLogErro,{"C4F_NRORE","000545", "C4F",nRecno }) //STR0545 - "O campo 'Reg Export' deve ser preenchido se o campo 'Tp Documento' for '0' (zero)."
	EndIf	

	If (C4F->C4F_INDDOC == "0") .And. Empty(C4F->C4F_DTRE)
		AADD(aLogErro,{"C4F_DTRE","000546", "C4F",nRecno }) //STR0546 - "O campo 'Dt. Reg. Exp.' deve ser preenchido se o campo 'Tp Documento' for '0' (zero)."
	EndIf	

	//INICIO C4G
	C4G->( DBSetOrder(1) )
	
	cC4GKey := C4F->C4F_ID
	If C4G->( MsSeek( xFilial("C4G") + cC4GKey ) )

		Do While !C4G->( Eof() ) .And. cC4GKey == C4G->C4G_ID

			If Empty(C4G->C4G_CODMOD)
				AADD(aLogErro,{"C4G_CODMOD","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C4G->C4G_SERIE)
				AADD(aLogErro,{"C4G_SERIE","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C4G->C4G_NUMDOC)
				AADD(aLogErro,{"C4G_NUMDOC","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C4G->C4G_CODITE)
				AADD(aLogErro,{"C4G_CODITE","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If !Empty(C4G->C4G_CODMOD)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C4G->C4G_CODMOD
				xValRegTab("C01",cChave,3,,@aLogErro,, { "C4F", "C4G_CODMOD", nRecno } )
			EndIf	

			If !Empty(C4G->C4G_CODITE)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C4G->C4G_CODITE
				xValRegTab("C1L",cChave,3,,@aLogErro,, { "C4F", "C4G_CODITE", nRecno })
			EndIf
			
			If !C4G->C4G_CODREL $ (' |0|1|2|3')
				AADD(aLogErro,{"C4G_CODREL","000006", "C4F",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
			EndIf
			
			cCodMod := Posicione("C01",1,xFilial("C01") + C4G->C4G_CODMOD,"C01_CODIGO")
			If cCodMod == "55" .And. Empty(C4G->C4G_CHVNFE) 
				AADD(aLogErro,{"C4G_CHVNFE","000547", "C4F",nRecno }) //STR0547 - "O campo 'Chave da NFE' deve ser preenchido se o 'Modelo da Nota Fiscal' for '55 - Nota Fiscal Eletrônica'."
			EndIf	
			
			//INICIO C4H
			C4H->( DBSetOrder(1) )
			
			cC4HKey := C4G->(C4G_ID + C4G_CODMOD + C4G_NUMDOC + DToS(C4G_DTDOC) + C4G_CODITE)
			If C4H->( MsSeek( xFilial("C4H") + cC4HKey ) )
		
				Do While !C4H->( Eof() ) .And. cC4HKey == C4H->(C4H_ID + C4H_CMOD + C4H_DOC + DToS(C4H_DT) + C4H_CODITE)
		
					If Empty(C4H->C4H_CODPAR)
						AADD(aLogErro,{"C4H_CODPAR","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4H->C4H_CODMOD)
						AADD(aLogErro,{"C4H_CODMOD","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4H->C4H_SERIE)
						AADD(aLogErro,{"C4H_SERIE","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4H->C4H_NUMDOC)
						AADD(aLogErro,{"C4H_NUMDOC","000010", "C4F",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If !Empty(C4H->C4H_CODPAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C4H->C4H_CODPAR
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C4F", "C4H_CODPAR", nRecno } )
					EndIf	

					If !Empty(C4H->C4H_CODMOD)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C4H->C4H_CODMOD
						xValRegTab("C01",cChave,3,,@aLogErro,, { "C4F", "C4H_CODMOD", nRecno })
					EndIf
					
					If !Empty(C4H->C4H_UNID)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C4H->C4H_UNID
						xValRegTab("C1J",cChave,3,,@aLogErro,, { "C4F", "C4H_UNID", nRecno })
					EndIf
					
					cCodMod := Posicione("C01",1,xFilial("C01") + C4H->C4H_CODMOD,"C01_CODIGO")
					If cCodMod == "55" .And. Empty(C4H->C4H_CHVNFE) 
						AADD(aLogErro,{"C4H_CHVNFE","000547", "C4F",nRecno }) //STR0547 - "O campo 'Chave da NFE' deve ser preenchido se o 'Modelo da Nota Fiscal' for '55 - Nota Fiscal Eletrônica'."
					EndIf	
		
					C4H->( DbSkip() )
				EndDo
			EndIf
			//FIM C4H

			C4G->( DbSkip() )
		EndDo
	EndIf
	//FIM C4G

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4F", cStatus )

Else
	AADD(aLogErro,{"C4F_ID","000305","C4F",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
