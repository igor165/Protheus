#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA063.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA063
Cadastro MVC - Apuração de ICMS

@author Mauro A. Goncalves
@since 30/07/2012
@version  1.0

/*/
//-------------------------------------------------------------------
Function TAFA063
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Apuração de ICMS
oBrw:SetAlias( 'C2S' )
oBrw:SetMenuDef( 'TAFA063' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Mauro A. Goncalves
@since 30/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf063Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA063' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA063" , , aFuncao)
EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 30/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC2S 	:= 	FWFormStruct( 1, 'C2S' )
Local oStruC2T 	:= 	FWFormStruct( 1, 'C2T' )
Local oStruT02 	:= 	FWFormStruct( 1, 'T02' )
Local oStruC2U 	:= 	FWFormStruct( 1, 'C2U' )
Local oStruC2V 	:= 	FWFormStruct( 1, 'C2V' )
Local oStruC2X 	:= 	FWFormStruct( 1, 'C2X' )
Local oStruC2Z 	:= 	FWFormStruct( 1, 'C2Z' )
Local oStruC6Z 	:= 	FWFormStruct( 1, 'C6Z' )
Local oStruT6U 	:= 	nil
Local oModel 	:= 	MPFormModel():New( 'TAFA063' ,,{ |oModel| ValidModel( oModel ) },{ |oModel| SaveModel( oModel ) }  )

If AliasInDic( "T6U" )
	oStruT6U 	:= 	FWFormStruct( 1, 'T6U' )
EndIf

oModel:AddFields('MODEL_C2S', /*cOwner*/, oStruC2S )

oModel:AddGrid('MODEL_C2T', 'MODEL_C2S', oStruC2T)  //Ajustes

If !TAFColumnPos( "C2T_IDTMOT" ) .And.  !TAFColumnPos( "C2T_CODAJ1" ) 
	oModel:GetModel( 'MODEL_C2T' ):SetUniqueLine( { 'C2T_CODAJU', 'C2T_SUBITE' } )
Else
	If !TAFColumnPos( "C2T_SEQREG" ) .And.  !TAFColumnPos( "C2T_CODAJ1" )
		oModel:GetModel( 'MODEL_C2T' ):SetUniqueLine( { 'C2T_CODAJU', 'C2T_SUBITE', 'C2T_CODMOT' } )
	elseIf !TAFColumnPos( "C2T_CODAJ1" )
		oModel:GetModel( 'MODEL_C2T' ):SetUniqueLine( { 'C2T_CODAJU', 'C2T_SUBITE', 'C2T_CODMOT', 'C2T_SEQREG' } )
	EndIf
EndIf

oModel:GetModel( 'MODEL_C2T' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C2U', 'MODEL_C2T', oStruC2U)   //Informacoes adicionais (Processos referenciados ou DA)
oModel:GetModel( 'MODEL_C2U' ):SetUniqueLine( { 'C2U_DOCARR', 'C2U_NRPROC' } )
oModel:GetModel( 'MODEL_C2U' ):SetOptional( .T. )

oModel:AddGrid('MODEL_T02', 'MODEL_C2T', oStruT02)   //Credito Acumulado de ICMS
oModel:GetModel( 'MODEL_T02' ):SetUniqueLine( { 'T02_CODIGO' } )
oModel:GetModel( 'MODEL_T02' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C2V', 'MODEL_C2T', oStruC2V)   //Identificacao dos documentos fiscais
oModel:GetModel( 'MODEL_C2V' ):SetUniqueLine( { 'C2V_CODPAR', 'C2V_CODMOD', 'C2V_NRODOC', 'C2V_DTDOC', 'C2V_SERDOC', 'C2V_SUBSER' } )
oModel:GetModel( 'MODEL_C2V' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C2X', 'MODEL_C2S', oStruC2X)   //Valores declaratorios
oModel:GetModel( 'MODEL_C2X' ):SetUniqueLine( { 'C2X_INFADC' } )
oModel:GetModel( 'MODEL_C2X' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C2Z', 'MODEL_C2S', oStruC2Z)   //Obrigacoes a recolher

If TAFColumnPos( "C2Z_DOCARR" )
	oModel:GetModel( 'MODEL_C2Z' ):SetUniqueLine( { 'C2Z_DOCARR', 'C2Z_NRPROC' } )
else
	oModel:GetModel( 'MODEL_C2Z' ):SetUniqueLine( { 'C2Z_CODOR' } )
endif
oModel:GetModel( 'MODEL_C2Z' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C6Z', 'MODEL_C2S', oStruC6Z)   //Resumo Por CFOP
oModel:GetModel( 'MODEL_C6Z' ):SetUniqueLine( { 'C6Z_CODCTA', 'C6Z_CFOP' } )
oModel:GetModel( 'MODEL_C6Z' ):SetOptional( .T. )

If AliasInDic( "T6U" )
	oModel:AddGrid('MODEL_T6U', 'MODEL_C2S', oStruT6U)   //Resumo Por Natureza de operação
	oModel:GetModel( 'MODEL_T6U' ):SetUniqueLine( { 'T6U_NATOPE', 'T6U_TPOPER' } )
	oModel:GetModel( 'MODEL_T6U' ):SetOptional( .T. )
EndIf

If !TAFColumnPos( "C2T_IDTMOT" )
	oModel:SetRelation( 'MODEL_C2T' , { { 'C2T_FILIAL' , 'xFilial( "C2T" )' } , { 'C2T_ID' , 'C2S_ID' }} , C2T->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'MODEL_C2U' , { { 'C2U_FILIAL' , 'xFilial( "C2U" )' } , { 'C2U_ID' , 'C2S_ID' }, { 'C2U_CODAJU' , 'C2T_CODAJU' } } , C2U->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'MODEL_C2V' , { { 'C2V_FILIAL' , 'xFilial( "C2V" )' } , { 'C2V_ID' , 'C2S_ID' }, { 'C2V_CODAJU' , 'C2T_CODAJU' } } , C2V->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'MODEL_T02' , { { 'T02_FILIAL' , 'xFilial( "T02" )' } , { 'T02_ID' ,'C2S_ID' }, { 'T02_CODAJU' , 'C2T_CODAJU' } , { 'T02_IDSUBI' , 'C2T_IDSUBI' }} , T02->( IndexKey( 1 ) ) )
Else
	If !TAFColumnPos( "C2T_SEQREG" )
		oModel:SetRelation( 'MODEL_C2T' , { { 'C2T_FILIAL' , 'xFilial( "C2T" )' } , { 'C2T_ID' , 'C2S_ID' }} , C2T->( IndexKey( 2 ) ) )
		oModel:SetRelation( 'MODEL_C2U' , { { 'C2U_FILIAL' , 'xFilial( "C2U" )' } , { 'C2U_ID' , 'C2S_ID' }, { 'C2U_CODAJU' , 'C2T_CODAJU' }, { 'C2U_IDSUBI' , 'C2T_IDSUBI' }, { 'C2U_IDTMOT' , 'C2T_IDTMOT' }   } , C2U->( IndexKey( 1 ) ) )
		oModel:SetRelation( 'MODEL_C2V' , { { 'C2V_FILIAL' , 'xFilial( "C2V" )' } , { 'C2V_ID' , 'C2S_ID' }, { 'C2V_CODAJU' , 'C2T_CODAJU' }, { 'C2V_IDSUBI' , 'C2T_IDSUBI' }, { 'C2V_IDTMOT' , 'C2T_IDTMOT' }   } , C2V->( IndexKey( 1 ) ) )
		oModel:SetRelation( 'MODEL_T02' , { { 'T02_FILIAL' , 'xFilial( "T02" )' } , { 'T02_ID' ,'C2S_ID' }, { 'T02_CODAJU' , 'C2T_CODAJU' } , { 'T02_IDSUBI' , 'C2T_IDSUBI' }, { 'T02_IDTMOT' , 'C2T_IDTMOT' }   } , T02->( IndexKey( 1 ) ) )
	Else
		oModel:SetRelation( 'MODEL_C2T' , { { 'C2T_FILIAL' , 'xFilial( "C2T" )' } , { 'C2T_ID' , 'C2S_ID' }} , C2T->( IndexKey( 1 ) ) )
		oModel:SetRelation( 'MODEL_C2U' , { { 'C2U_FILIAL' , 'xFilial( "C2U" )' } , { 'C2U_ID' , 'C2S_ID' }, { 'C2U_CODAJU' , 'C2T_CODAJU' }, { 'C2U_IDSUBI' , 'C2T_IDSUBI' }, { 'C2U_IDTMOT' , 'C2T_IDTMOT' },  { 'C2U_SEQREG' , 'C2T_SEQREG' } } , C2U->( IndexKey( 1 ) ) )
		oModel:SetRelation( 'MODEL_C2V' , { { 'C2V_FILIAL' , 'xFilial( "C2V" )' } , { 'C2V_ID' , 'C2S_ID' }, { 'C2V_CODAJU' , 'C2T_CODAJU' }, { 'C2V_IDSUBI' , 'C2T_IDSUBI' }, { 'C2V_IDTMOT' , 'C2T_IDTMOT' },  { 'C2V_SEQREG' , 'C2T_SEQREG' } } , C2V->( IndexKey( 1 ) ) )
		oModel:SetRelation( 'MODEL_T02' , { { 'T02_FILIAL' , 'xFilial( "T02" )' } , { 'T02_ID' ,'C2S_ID' }, { 'T02_CODAJU' , 'C2T_CODAJU' } , { 'T02_IDSUBI' , 'C2T_IDSUBI' }, { 'T02_IDTMOT' , 'C2T_IDTMOT' },  { 'T02_SEQREG' , 'C2T_SEQREG' } } , T02->( IndexKey( 1 ) ) )
	EndIf
EndIf

oModel:SetRelation( 'MODEL_C2X' , { { 'C2X_FILIAL' , 'xFilial( "C2X" )' } , { 'C2X_ID' , 'C2S_ID' }} , C2X->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C2Z' , { { 'C2Z_FILIAL' , 'xFilial( "C2Z" )' } , { 'C2Z_ID' , 'C2S_ID' }} , C2Z->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C6Z' , { { 'C6Z_FILIAL' , 'xFilial( "C6Z" )' } , { 'C6Z_ID' , 'C2S_ID' }} , C6Z->( IndexKey( 1 ) ) )

If AliasInDic( "T6U" )
	oModel:SetRelation( 'MODEL_T6U' , { { 'T6U_FILIAL' , 'xFilial( "T6U" )' } , { 'T6U_ID' , 'C2S_ID' }} , T6U->( IndexKey( 1 ) ) )
EndIf

oModel:GetModel( "MODEL_C2S" ):SetPrimaryKey( { "C2S_TIPAPU", "C2S_DTINI", "C2S_DTFIN", "C2S_INDAPU" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 30/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA063' )
Local oStruC2S 	:= 	FWFormStruct( 2, 'C2S' ) //Apuração de ICMS
Local oStruC2T 	:= 	FWFormStruct( 2, 'C2T' ) //Ajustes da Apuracao do Tributo
Local oStruC2U 	:= 	FWFormStruct( 2, 'C2U' ) //Ajustes - Informações adicionais
Local oStruC2V 	:= 	FWFormStruct( 2, 'C2V' ) //Ajustes - Informações adicionais (Identificação dos documentos fiscais)
Local oStruC2X 	:= 	FWFormStruct( 2, 'C2X' ) //Valores declaratórios
Local oStruC2Z 	:= 	FWFormStruct( 2, 'C2Z' ) //Obrigações a recolher
Local oStruC6Z 	:= 	FWFormStruct( 2, 'C6Z' ) //Resumo Por CFOP
Local oStruT6U 	:= 	nil 					//Resumo Por CFOP
Local oStruT02 	:= 	FWFormStruct( 2, 'T02' ) //Crédito Acumulado de ICMS
Local oView 	:= 	FWFormView():New()

oStruC2T:RemoveField("C2T_ID")
oStruC2T:RemoveField("C2T_IDSUBI")
oStruC2T:RemoveField("C2T_IDTMOT")
oStruT02:RemoveField("T02_IDSUBI")
oStruT02:RemoveField("T02_IDTMOT")
oStruT02:RemoveField("T02_ID")

If TAFColumnPos( "C2T_SEQREG" )
	oStruT02:RemoveField("T02_SEQREG")
	oStruC2V:RemoveField("C2V_SEQREG")
	oStruC2U:RemoveField("C2U_SEQREG")
EndIf

If AliasInDic( "T6U" )
	oStruT6U 	:= 	FWFormStruct( 2, 'T6U' ) //Resumo Por CFOP
	oStruT6U:RemoveField("T6U_ID")
	oView:AddGrid ( 'VIEW_T6U', oStruT6U, 'MODEL_T6U' )
EndIf

If TamSX3("C6Z_CODCTA")[1] == 36
	oStruC6Z:SetProperty( "C6Z_CTACTB", MVC_VIEW_ORDEM, "03" )
Else
	oStruC6Z:SetProperty( "C6Z_CODCTA", MVC_VIEW_ORDEM, "03" )
EndIf

If TamSX3("C2V_CODPAR")[1] == 36
	oStruC2V:RemoveField("C2V_CODPAR")
			
	oStruC2V:SetProperty("C2V_CPARTI", MVC_VIEW_ORDEM, "03" )	
	oStruC2V:SetProperty("C2V_DCODPA", MVC_VIEW_ORDEM, "04" )
	oStruC2V:SetProperty("C2V_CODMOD", MVC_VIEW_ORDEM, "05" )
	oStruC2V:SetProperty("C2V_DCODMO", MVC_VIEW_ORDEM, "06" )
	oStruC2V:SetProperty("C2V_NRODOC", MVC_VIEW_ORDEM, "07" )
	oStruC2V:SetProperty("C2V_DTDOC", MVC_VIEW_ORDEM,  "08" )
	oStruC2V:SetProperty("C2V_SERDOC", MVC_VIEW_ORDEM, "09" )
	oStruC2V:SetProperty("C2V_SUBSER", MVC_VIEW_ORDEM, "10" )
	
	If TamSX3("C2V_CODITE")[1] == 36		
		oStruC2V:RemoveField("C2V_CODITE")
		oStruC2V:SetProperty("C2V_ITEM",   MVC_VIEW_ORDEM, "11" )
	Else
		oStruC2V:SetProperty("C2V_CODITE",   MVC_VIEW_ORDEM, "11" )
	EndIf	
	
	oStruC2V:SetProperty("C2V_DCODIT", MVC_VIEW_ORDEM, "12" )	
	oStruC2V:SetProperty("C2V_VLRAJU", MVC_VIEW_ORDEM, "13" )
	oStruC2V:SetProperty("C2V_DTVIST", MVC_VIEW_ORDEM, "14" )
	oStruC2V:SetProperty("C2V_CODMOT", MVC_VIEW_ORDEM, "15" )
	oStruC2V:SetProperty("C2V_DESMOT", MVC_VIEW_ORDEM, "16" )
	oStruC2V:SetProperty("C2V_CHVELE", MVC_VIEW_ORDEM, "17" )
EndIf

oStruC6Z:SetProperty( "C6Z_DCODCT", MVC_VIEW_ORDEM, "04" )
oStruC6Z:SetProperty( "C6Z_CFOP"  , MVC_VIEW_ORDEM, "05" )
oStruC6Z:SetProperty( "C6Z_DCFOP" , MVC_VIEW_ORDEM, "06" )
oStruC6Z:SetProperty( "C6Z_VLCONT", MVC_VIEW_ORDEM, "07" )
oStruC6Z:SetProperty( "C6Z_BASE"  , MVC_VIEW_ORDEM, "08" )
oStruC6Z:SetProperty( "C6Z_IMPCRD", MVC_VIEW_ORDEM, "09" )
oStruC6Z:SetProperty( "C6Z_ISENNT", MVC_VIEW_ORDEM, "10" )
oStruC6Z:SetProperty( "C6Z_OUTROS", MVC_VIEW_ORDEM, "11" )

oView:SetModel( oModel )

oView:AddField( 'VIEW_C2S', oStruC2S, 'MODEL_C2S' )
oView:AddGrid ( 'VIEW_C2T', oStruC2T, 'MODEL_C2T' )
oView:AddGrid ( 'VIEW_C2U', oStruC2U, 'MODEL_C2U' )
oView:AddGrid ( 'VIEW_C2V', oStruC2V, 'MODEL_C2V' )
oView:AddGrid ( 'VIEW_C2X', oStruC2X, 'MODEL_C2X' )
oView:AddGrid ( 'VIEW_C2Z', oStruC2Z, 'MODEL_C2Z' )
oView:AddGrid ( 'VIEW_C6Z', oStruC6Z, 'MODEL_C6Z' )
oView:AddGrid ( 'VIEW_T02', oStruT02, 'MODEL_T02' )

oView:CreateHorizontalBox( 'FIELDSC2S', 30 )
oView:CreateHorizontalBox( 'PANFOLDER1', 70 )

oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )
If TAFColumnPos( "C2T_SEQREG" )	
	oView:AddIncrementField( "VIEW_C2T", "C2T_SEQREG" )
EndIf

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //'Ajustes da Apuracao'
oView:CreateHorizontalBox( 'GRIDC2T', 40,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'PANFOLDER2', 60,,, 'FOLDER1', 'ABA01' )

oView:CreateFolder( 'FOLDER2', 'PANFOLDER2' )

oView:AddSheet( 'FOLDER2', 'ABA01', STR0003) //'Informações adicionais'
oView:CreateHorizontalBox( 'GRIDC2U', 100,,, 'FOLDER2', 'ABA01' )
oView:AddSheet( 'FOLDER2', 'ABA02', STR0004) //'Identificação dos documentos fiscais'
oView:CreateHorizontalBox( 'GRIDC2V', 100,,, 'FOLDER2', 'ABA02' )
oView:AddSheet( 'FOLDER2', 'ABA03', STR0013) //'Crédito Acumulado de ICMS'
oView:CreateHorizontalBox( 'GRIDT02', 100,,, 'FOLDER2', 'ABA03' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0005) //'Valores declaratórios'
oView:CreateHorizontalBox( 'GRIDC2X', 100,,, 'FOLDER1', 'ABA02' )

oView:AddSheet( 'FOLDER1', 'ABA03', STR0006) //'Obrigações a recolher'
oView:CreateHorizontalBox( 'GRIDC2Z', 100,,, 'FOLDER1', 'ABA03' )

oView:AddSheet( 'FOLDER1', 'ABA04', STR0012) //"Resumo por CFOP"
oView:CreateHorizontalBox( 'GRIDC6Z', 100,,, 'FOLDER1', 'ABA04' )

If AliasInDic( "T6U" )
	oView:AddSheet( 'FOLDER1', 'ABA05', STR0014) //"Resumo por Natureza"
	oView:CreateHorizontalBox( 'GRIDT6U', 100,,, 'FOLDER1', 'ABA05' )
	oView:SetOwnerView( 'VIEW_T6U', 'GRIDT6U' )
	If TamSX3("T6U_NATOPE")[1] == 36
		oStruT6U:RemoveField( "T6U_NATOPE")
		oStruT6U:SetProperty( "T6U_CODNAT", MVC_VIEW_ORDEM, "03" )
	EndIf
EndIf

oView:SetOwnerView( 'VIEW_C2S', 'FIELDSC2S' )
oView:SetOwnerView( 'VIEW_C2T', 'GRIDC2T' )
oView:SetOwnerView( 'VIEW_C2U', 'GRIDC2U' )
oView:SetOwnerView( 'VIEW_C2V', 'GRIDC2V' )
oView:SetOwnerView( 'VIEW_C2X', 'GRIDC2X' )
oView:SetOwnerView( 'VIEW_C2Z', 'GRIDC2Z' )
oView:SetOwnerView( 'VIEW_C6Z', 'GRIDC6Z' )
oView:SetOwnerView( 'VIEW_T02', 'GRIDT02' )

If TamSX3("C6Z_CODCTA")[1] == 36
	oStruC6Z:RemoveField("C6Z_CODCTA")		
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 20/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( 'C2S', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif

	FwFormCommit( oModel )

End Transaction


Return .T.

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
Return XFUNReflex( nOperation , {""} , 'TAFA063' )	//Array com uma posicao branco para sempre dar mensagem

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf063Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 20/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function Taf063Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro := {}
Local cChave   := ""
Local cID			 := ""   //Identificação do registro
Local cCodAju  := ""  //Código do Ajuste

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C2S->( Recno() )

If (C2S->C2S_STATUS $ (' 1'))
	If !(Empty(C2T->C2T_CODAJU)) .And. Empty(C2T->C2T_CODAJ1)
		/********************************************************************************* //
		|| Verifica os campos obrigatórios e suas opções váidas (C2S)     	  ||
		//*********************************************************************************/
		If Empty(C2S->C2S_TIPAPU)
			aAdd(aLogErro,{"C2S_TIPAPU","000010","C2S",nRecno}) //"Campo Inconsistente ou Vazio"
		ElseIf !(C2S->C2S_TIPAPU)$("01")
			aAdd(aLogErro,{"C2S_TIPAPU","000006","C2S",nRecno}) // "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
	
		If !Empty( C2S->C2S_INDAPU ) .AND. !(C2S->C2S_INDAPU) $ (" 345678")
			aAdd(aLogErro,{"C2S_INDAPU","000006","C2S",nRecno}) // "Conteúdo do campo não condiz com as opções possíveis"
		EndIf
	
	  	dbSelectArea("C2T")
	  	C2T->(dbSetOrder(1))
	  	If MsSeek(xFilial("C2T") + C2S->C2S_ID)
	  		cID:= C2T->C2T_ID
	  		While(!C2T->(Eof()) .And. cID== C2T->C2T_ID)
	  	 		If Empty(C2T->C2T_CODAJU)
					aAdd(aLogErro,{"C2T_CODAJU","000010","C2S",nRecno}) //"Campo Inconsistente ou Vazio"
				Else
					cChave := C2T->C2T_CODAJU
	  				xValRegTab("C1A",cChave,4,,@aLogErro, { "C2S", "C2T_CODAJU", nRecno } )
	   			EndIf
	
	   			dbSelectArea("C2U")
				C2U->(dbSetOrder(1))
	  			If MsSeek(xFilial("C2U") + C2T->C2T_ID + C2T->C2T_CODAJU)
	  				cID:= C2U->C2U_ID
	  				cCodAju:= C2U->C2U_CODAJU
	  				While(!C2U->(Eof()) .And. cID == C2U->C2U_ID .And. cCodAju == C2U->C2U_CODAJU)
	  	 				If Empty(C2U->C2U_DOCARR)
							aAdd(aLogErro,{"C2U_DOCARR","000010","C2S",nRecno}) //"Campo Inconsistente ou Vazio"
						Else
							cChave := C2U->C2U_DOCARR
	  						xValRegTab("C0R",cChave,6,,@aLogErro,, { "C2S", "C2U_DOCARR", nRecno } )
	   					EndIf
	  		   			cID:= C2U->C2U_ID
	  					cCodAju:= C2U->C2U_CODAJU
	  					C2U->(dbSkip())
	  				Enddo
	    		Endif
	
	    		dbSelectArea("C2V")
				C2V->(dbSetOrder(1))
	  			If MsSeek(xFilial("C2V") + C2T->C2T_ID + C2T->C2T_CODAJU)
	  				cID:= C2V->C2V_ID
	  				cCodAju:= C2V->C2V_CODAJU
	  				While(!C2V->(Eof()) .And. cID == C2V->C2V_ID .And. cCodAju == C2V->C2V_CODAJU)
	  	 				If Empty(C2V->C2V_CODMOD)
							aAdd(aLogErro,{"C2U_CODMOD","000010","C2S",nRecno}) //"Campo Inconsistente ou Vazio"
						Else
							cChave := C2V->C2V_CODMOD
	  						xValRegTab("C01",cChave,3,,@aLogErro,, { "C2S", "C2V_CODMOD", nRecno } )
	   					EndIf
	   					// Demetrio - 20/08/2014
	   					// Retirada a validação do campo, pois não é obrigatório.
	   					If !Empty(C2V->C2V_CODITE)
							cChave := C2V->C2V_CODITE
	  						xValRegTab("C1L",cChave,3,,@aLogErro,, { "C2S", "C2V_CODITE", nRecno })
	   					EndIf
	  		   			cID:= C2V->C2V_ID
	  					cCodAju:= C2V->C2V_CODAJU
	  					C2V->(dbSkip())
	  				Enddo
	    		Endif
	   			cID:= C2T->C2T_ID
	  			C2T->(dbSkip())
	  		Enddo
	    Endif
	
	   	dbSelectArea("C6Z")
	  	C6Z->(dbSetOrder(1))
	  	If MsSeek(xFilial("C6Z") + C2S->C2S_ID)
	  		cID:= C6Z->C6Z_ID
	  		While(!C6Z->(Eof()) .And. cID== C6Z->C6Z_ID)
	  	 		If !Empty(C6Z->C6Z_CODCTA)
					cChave := C6Z->C6Z_CODCTA
	  				xValRegTab("C1O",cChave,3,,@aLogErro,, { "C2S", "C6Z_CODCTA", nRecno } )
	   			EndIf
	
	  		   	If !Empty(C6Z->C6Z_CFOP)
					cChave := C6Z->C6Z_CFOP
	  				xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C2S", "C6Z_CFOP", nRecno })
	   			EndIf
	   		   	cID:= C6Z->C6Z_CFOP
	  			C6Z->(dbSkip())
	  		Enddo
	    Endif
	    
	    If AliasInDic( "T6U" )
		    If !T6U->T6U_TPOPER $ ('0|1')
				AADD(aLogErro,{"T6U_TPOPER","000006", "T6U",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf
		EndIf	
	Endif
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C2S",.F.)
	    	C2S->C2S_STATUS := "1"
	    C2S->( MsUnlock() )
	Else
		RecLock("C2S",.F.)
	    	C2S->C2S_STATUS := "0"
	    C2S->( MsUnlock() )
	EndIf

Else
	AADD(aLogErro,{"C2S_ID","000305", "C2S", nRecno })   //Registros válidos não podem ser validados novamente
EndIf

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
