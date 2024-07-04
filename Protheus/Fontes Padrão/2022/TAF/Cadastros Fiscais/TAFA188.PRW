#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA188.CH"                                   
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA188
Cadastro MVC - Apuração de ICMS ST

@author Mauro A. Goncalves
@since 31/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA188
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Apuração de ICMS ST
oBrw:SetAlias( 'C3J' )
oBrw:SetMenuDef( 'TAFA188' )
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
Local aFuncao := {{ "" , "TAF188Vld" , "2" } }
Local aRotina := {}

//Indica se o menu tera todas as opções de cadastro ou apenas a visualização
lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.TAF188' OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina	:=	xFunMnuTAF( "TAFA188" , , aFuncao )
EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 31/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3J 	:= 	FWFormStruct( 1, 'C3J' )
Local oStruC3K 	:= 	FWFormStruct( 1, 'C3K' )
Local oStruC3L 	:= 	FWFormStruct( 1, 'C3L' )
Local oStruC7A 	:= 	FWFormStruct( 1, 'C7A' )
Local oStruC3M 	:= 	FWFormStruct( 1, 'C3M' )
Local oStruC3N 	:= 	FWFormStruct( 1, 'C3N' )
Local oStruT6V 	:= 	FWFormStruct( 1, 'T6V' )
Local oModel    :=  MpFormModel():New("TAFA188",,{ |oModel| ValidModel( oModel ) } ,{|oModel| SaveModel(oModel)})
      
oModel:AddFields('MODEL_C3J', /*cOwner*/, oStruC3J )

oModel:AddGrid('MODEL_C3K', 'MODEL_C3J', oStruC3K)  //Ajustes

If !TAFColumnPos( "C3K_IDTMOT" )
	oModel:GetModel('MODEL_C3K'):SetUniqueLine({'C3K_CODAJU', 'C3K_SUBITE'})
Else
	oModel:GetModel('MODEL_C3K'):SetUniqueLine({'C3K_CODAJU', 'C3K_SUBITE', 'C3K_CODMOT'})
EndIf

oModel:GetModel('MODEL_C3K' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C3L', 'MODEL_C3K', oStruC3L)   //Informacoes adicionais (Processos referenciados ou DA) 
oModel:GetModel('MODEL_C3L'):SetUniqueLine({'C3L_DOCARR', 'C3L_NRPROC'})
oModel:GetModel('MODEL_C3L' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C7A', 'MODEL_C3J', oStruC7A)   //Resumo por CFOP 
oModel:GetModel('MODEL_C7A'):SetUniqueLine({'C7A_ESTADO', 'C7A_CFOP'})
oModel:GetModel('MODEL_C7A' ):SetOptional( .T. )                                             

If AliasInDic( "T6V" )
	oModel:AddGrid('MODEL_T6V', 'MODEL_C3J', oStruT6V)   //Resumo por Natureza de Operação 
	oModel:GetModel('MODEL_T6V'):SetUniqueLine({'T6V_ESTADO', 'T6V_NATOPE', 'T6V_TPOPER'})
	oModel:GetModel('MODEL_T6V' ):SetOptional( .T. )
EndIf                                                                                                                                                                             
                                                                                                                                                                            
oModel:AddGrid('MODEL_C3M', 'MODEL_C3K', oStruC3M)   //Identificacao dos documentos fiscais
oModel:GetModel('MODEL_C3M'):SetUniqueLine({'C3M_CODPAR', 'C3M_CODMOD', 'C3M_NRODOC', 'C3M_DTDOC', 'C3M_SERDOC' })
oModel:GetModel('MODEL_C3M' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C3N', 'MODEL_C3J', oStruC3N)   //Valores declaratorios

If !TAFColumnPos( "C3N_DOCARR" )
	oModel:GetModel('MODEL_C3N'):SetUniqueLine({'C3N_CODREC','C3N_NRPROC'})
else
	oModel:GetModel('MODEL_C3N'):SetUniqueLine({'C3N_DOCARR', 'C3N_NRPROC' })
endif

oModel:GetModel('MODEL_C3N' ):SetOptional( .T. )    

oModel:SetRelation('MODEL_C3K' , { { 'C3K_FILIAL' , 'xFilial( "C3K" )' } , { 'C3K_ID' , 'C3J_ID' }} , C3K->( IndexKey( 1 ) ) )
oModel:SetRelation('MODEL_C7A' , { { 'C7A_FILIAL' , 'xFilial( "C7A" )' } , { 'C7A_ID' , 'C3J_ID' }} , C7A->( IndexKey( 1 ) ) )

If !TAFColumnPos( "C3K_IDTMOT" )
	oModel:SetRelation('MODEL_C3L' , { { 'C3L_FILIAL' , 'xFilial( "C3L" )' } , { 'C3L_ID' , 'C3J_ID' }, { 'C3L_CODAJU' , 'C3K_CODAJU' }} , C3L->( IndexKey( 1 ) ) )
	oModel:SetRelation('MODEL_C3M' , { { 'C3M_FILIAL' , 'xFilial( "C3M" )' } , { 'C3M_ID' , 'C3J_ID' }, { 'C3M_CODAJU' , 'C3K_CODAJU' }} , C3M->( IndexKey( 1 ) ) )
Else
	oModel:SetRelation('MODEL_C3L' , { { 'C3L_FILIAL' , 'xFilial( "C3L" )' } , { 'C3L_ID' , 'C3J_ID' }, { 'C3L_CODAJU' , 'C3K_CODAJU' }, { 'C3L_IDSUBI' , 'C3K_IDSUBI' }, { 'C3L_IDTMOT' , 'C3K_IDTMOT' }} , C3L->( IndexKey( 1 ) ) )
	oModel:SetRelation('MODEL_C3M' , { { 'C3M_FILIAL' , 'xFilial( "C3M" )' } , { 'C3M_ID' , 'C3J_ID' }, { 'C3M_CODAJU' , 'C3K_CODAJU' }, { 'C3M_IDSUBI' , 'C3K_IDSUBI' }, { 'C3M_IDTMOT' , 'C3K_IDTMOT' }} , C3M->( IndexKey( 1 ) ) )
EndIf

If AliasInDic( "T6V" )
	oModel:SetRelation('MODEL_T6V' , { { 'T6V_FILIAL' , 'xFilial( "T6V" )' } , { 'T6V_ID' , 'C3J_ID' }} , T6V->( IndexKey( 1 ) ) )
EndIf

oModel:SetRelation('MODEL_C3N' , { { 'C3N_FILIAL' , 'xFilial( "C3N" )' } , { 'C3N_ID' , 'C3J_ID' }} , C3N->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C3J" ):SetPrimaryKey( { "C3J_UF", "C3J_DTINI", "C3J_DTFIN", "C3J_INDMOV" } )                                                                                                    

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 31/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA188' )
Local oStruC3J 	:= 	FWFormStruct( 2, 'C3J' ) //Apuração de ICMS
Local oStruC3K 	:= 	FWFormStruct( 2, 'C3K' ) //Ajustes da Apuracao do Tributo 
Local oStruC3L 	:= 	FWFormStruct( 2, 'C3L' ) //Ajustes - Informações adicionais  
Local oStruC7A 	:= 	FWFormStruct( 2, 'C7A' ) //Resumo Por Estado
Local oStruC3M 	:= 	FWFormStruct( 2, 'C3M' ) //Ajustes - Informações adicionais (Identificação dos documentos fiscais)
Local oStruC3N 	:= 	FWFormStruct( 2, 'C3N' ) //Valores declaratórios
Local oStruT6V 	:= 	nil //Resumo por CFOP
Local oView 	:= 	FWFormView():New()


If AliasInDic( "T6V" )
	oStruT6V 	:= 	FWFormStruct( 2, 'T6V' ) //Resumo por CFOP
	oStruT6V:removefield("T6V_ID")
EndIF

oStruC3K:removefield("C3K_IDSUBI")
oStruC3K:removefield("C3K_IDTMOT")

oView:SetModel( oModel )

oView:AddField( 'VIEW_C3J', oStruC3J, 'MODEL_C3J' )
oView:AddGrid ( 'VIEW_C3K', oStruC3K, 'MODEL_C3K' )
oView:AddGrid ( 'VIEW_C3L', oStruC3L, 'MODEL_C3L' )
oView:AddGrid ( 'VIEW_C7A', oStruC7A, 'MODEL_C7A' )
oView:AddGrid ( 'VIEW_C3M', oStruC3M, 'MODEL_C3M' )
oView:AddGrid ( 'VIEW_C3N', oStruC3N, 'MODEL_C3N' )

If AliasInDic( "T6V" )
	oView:AddGrid ( 'VIEW_T6V', oStruT6V, 'MODEL_T6V' )
EndIf

oView:CreateHorizontalBox( 'FIELDSC3J', 30 )          
oView:CreateHorizontalBox( 'PANFOLDER1', 70 )

oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0006) //'Ajustes da Apuracao' 
oView:CreateHorizontalBox( 'GRIDC3K', 40,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'PANFOLDER2', 60,,, 'FOLDER1', 'ABA01' )

oView:CreateFolder( 'FOLDER2', 'PANFOLDER2' )

oView:AddSheet( 'FOLDER2', 'ABA01', STR0003) //'Informações adicionais'
oView:CreateHorizontalBox( 'GRIDC3L', 100,,, 'FOLDER2', 'ABA01' )
oView:AddSheet( 'FOLDER2', 'ABA02', STR0004) //'Identificação dos documentos fiscais' 
oView:CreateHorizontalBox( 'GRIDC3M', 100,,, 'FOLDER2', 'ABA02' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0009) //'Valores declaratórios'
oView:CreateHorizontalBox( 'GRIDC3N', 100,,, 'FOLDER1', 'ABA02' )

oView:AddSheet( 'FOLDER1', 'ABA03', STR0010) //"Resumo Por Estado" 
oView:CreateHorizontalBox( 'GRIDC7A', 100,,, 'FOLDER1', 'ABA03' )

If AliasInDic( "T6V" )
	oView:AddSheet( 'FOLDER1', 'ABA04', STR0011) //"Resumo Por Natureza de Operação" 
	oView:CreateHorizontalBox( 'GRIDT6V', 100,,, 'FOLDER1', 'ABA04' )
	If TamSX3("T6V_NATOPE")[1] == 36
		oStruT6V:RemoveField( "T6V_NATOPE")
		oStruT6V:SetProperty( "T6V_CODNAT", MVC_VIEW_ORDEM, "05" )
	EndIf
EndIf

oView:SetOwnerView( 'VIEW_C3J', 'FIELDSC3J' )
oView:SetOwnerView( 'VIEW_C3K', 'GRIDC3K' )
oView:SetOwnerView( 'VIEW_C7A', 'GRIDC7A' )
oView:SetOwnerView( 'VIEW_C3L', 'GRIDC3L' )
oView:SetOwnerView( 'VIEW_C3M', 'GRIDC3M' )
oView:SetOwnerView( 'VIEW_C3N', 'GRIDC3N' )

If AliasInDic( "T6V" )
	oView:SetOwnerView( 'VIEW_T6V', 'GRIDT6V' )
EndIf

If TamSX3("C3M_CODPAR")[1] == 36
	oStruC3M:RemoveField("C3M_CODPAR")	
	
	oStruC3M:SetProperty("C3M_CPARTI", MVC_VIEW_ORDEM, "03" )
	oStruC3M:SetProperty("C3M_DCODPA", MVC_VIEW_ORDEM, "04" )
	oStruC3M:SetProperty("C3M_CODMOD", MVC_VIEW_ORDEM, "05" )
	oStruC3M:SetProperty("C3M_DCODMO", MVC_VIEW_ORDEM, "06" )
	oStruC3M:SetProperty("C3M_NRODOC", MVC_VIEW_ORDEM, "07" )
	oStruC3M:SetProperty("C3M_DTDOC",  MVC_VIEW_ORDEM, "08" )
	oStruC3M:SetProperty("C3M_SERDOC", MVC_VIEW_ORDEM, "09" )
	oStruC3M:SetProperty("C3M_SUBSER", MVC_VIEW_ORDEM, "10" )
	
	If TamSX3("C3M_CODITE")[1] == 36
		oStruC3M:RemoveField( "C3M_CODITE")
		oStruC3M:SetProperty("C3M_ITEM",   MVC_VIEW_ORDEM, "11" )
	Else
		oStruC3M:SetProperty("C3M_CODITE",   MVC_VIEW_ORDEM, "11" )
	EndIf
	
	oStruC3M:SetProperty("C3M_DCODIT", MVC_VIEW_ORDEM, "12" )
	oStruC3M:SetProperty("C3M_VLRAJU", MVC_VIEW_ORDEM, "13" )
	oStruC3M:SetProperty("C3M_DTVIST", MVC_VIEW_ORDEM, "14" )
	oStruC3M:SetProperty("C3M_CODMOT", MVC_VIEW_ORDEM, "15" )
	oStruC3M:SetProperty("C3M_DESMOT", MVC_VIEW_ORDEM, "16" )
	oStruC3M:SetProperty("C3M_CHVELE", MVC_VIEW_ORDEM, "17" )		
EndIf

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
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "C3J", " " )		
	EndIf
	FwFormCommit( oModel )
        
End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF188Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF188Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

Local cC3KKey		:= ""
Local cC3LKey		:= ""
Local cC3MKey		:= ""
Local cC3NKey		:= ""
Local cC7AKey		:= ""

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C3J->( Recno() )

If C3J->C3J_STATUS $ ( " |1" )
	
	//Valida o Codigo Id. UF
	If !Empty(C3J->C3J_UF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C3J->C3J_UF
		xValRegTab("C09",cChave,3,,@aLogErro,, { "C3J", "C3J_UF", nRecno } )
	EndIf
	
	//Valida o Indicador de movimento
	If !Empty(C3J->C3J_INDMOV)
		If !(C3J->C3J_INDMOV $ ("0|1"))
			AADD(aLogErro,{"C3J_INDMOV","000006","C3J", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
	EndIF

	//INICIO C3K
	C3K->( DBSetOrder(1) )
	
	cC3KKey := C3J->C3J_ID
	If C3K->( MsSeek( xFilial("C3K") + cC3KKey ) )

		Do While !C3K->( Eof() ) .And. cC3KKey == C3K->C3K_ID

			//Valida o Codigo do Ajuste
			If !Empty(C3K->C3K_CODAJU)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3K->C3K_CODAJU
				xValRegTab("C1A",cChave,4,,@aLogErro,, { "C3J", "C3K_CODAJU", nRecno } )
			EndIf
			
			//INICIO C3L
			C3L->( DBSetOrder(1) )
			
			cC3LKey := C3K->(C3K_ID + C3K_CODAJU)
			If C3L->( MsSeek( xFilial("C3L") + cC3LKey ) )
		
				Do While !C3L->( Eof() ) .And. cC3LKey == C3L->(C3L_ID + C3L_CODAJU)
					//Valida o Documento de arrecadacao
					If !Empty(C3L->C3L_DOCARR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C3L->C3L_DOCARR
						xValRegTab("C0R",cChave,6,,@aLogErro,, { "C3J", "C3L_DOCARR", nRecno } )
					EndIf
					
					//Valida o Numero do Processo
					If !Empty(C3L->C3L_NRPROC)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C3L->C3L_NRPROC
						xValRegTab("C1G",cChave,3,,@aLogErro,, { "C3J", "C3L_NRPROC", nRecno })
					EndIf
		
					C3L->( DbSkip() )
				EndDo
			EndIf
			//FIM C3L

			//INICIO C3M
			C3M->( DBSetOrder(1) )
			
			cC3MKey := C3K->(C3K_ID + C3K_CODAJU)
			If C3M->( MsSeek( xFilial("C3M") + cC3MKey ) )
		
				Do While !C3M->( Eof() ) .And. cC3MKey == C3M->(C3M_ID + C3M_CODAJU)
		
					//Valida o Id. Participante
					If !Empty(C3M->C3M_CODPAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C3M->C3M_CODPAR
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C3J", "C3M_CODPAR", nRecno })
					EndIf
					
					//Valida o Codigo de Identificacao Modelo
					If !Empty(C3M->C3M_CODMOD)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C3M->C3M_CODMOD
						xValRegTab("C01",cChave,3,,@aLogErro,, { "C3J", "C3M_CODMOD", nRecno })
					EndIf
					
					//Valida o Codigo do Item
					If !Empty(C3M->C3M_CODITE)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C3M->C3M_CODITE
						xValRegTab("C1L",cChave,3,,@aLogErro,, { "C3J", "C3M_CODITE", nRecno })
					EndIf
	
					C3M->( DbSkip() )
				EndDo
			EndIf
			//FIM C3M

			C3K->( DbSkip() )
		EndDo
	EndIf
	//FIM C3K
	
	//INICIO C3N
	C3N->( DBSetOrder(1) )
	
	cC3NKey := C3J->C3J_ID
	If C3N->( MsSeek( xFilial("C3N") + cC3NKey ) )

		Do While !C3N->( Eof() ) .And. cC3NKey == C3N->C3N_ID
			//Valida o Codigo obrigacao a recolher
			If !Empty(C3N->C3N_CODOBR)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C3N->C3N_CODOBR
				xValRegTab("C3E",cChave,3,,@aLogErro,, { "C3J", "C3N_CODOBR", nRecno })
			EndIf

			C3N->( DbSkip() )
		EndDo
	EndIf
	//FIM C3N

	//INICIO C7A
	C7A->( DBSetOrder(1) )
	
	cC7AKey := C3J->C3J_ID
	If C7A->( MsSeek( xFilial("C7A") + cC7AKey ) )

		Do While !C7A->( Eof() ) .And. cC7AKey == C7A->C7A_ID
			//Valida o Indicador Estado
			If !Empty(C7A->C7A_ESTADO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C7A->C7A_ESTADO
				xValRegTab("C09",cChave,3,,@aLogErro,, { "C3J", "C7A_ESTADO", nRecno })
			EndIf
			
			//Valida o Indicador CFOP
			If !Empty(C7A->C7A_CFOP)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C7A->C7A_CFOP
				xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C3J", "C7A_CFOP", nRecno })
			EndIf			

			C7A->( DbSkip() )
		EndDo
	EndIf
	//FIM C7A
	
	If AliasInDic( "T6V" )
	    If !T6V->T6V_TPOPER $ ('0|1')
			AADD(aLogErro,{"T6V_TPOPER","000006", "T6V",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C3J", cStatus )
	
Else	
	AADD(aLogErro,{"C3J_ID","000305", "C3J", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)

	
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de valida da inclusao dos dados, chamada no final, no momento da gravacao do modelo

@param  oModel -> Modelo de dados
@return .T. ou  .F.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()
Return XFUNReflex( nOperation , {""} , 'TAFA188' )	//Array com uma posicao branco para sempre dar mensagem
