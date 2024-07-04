#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA064.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA064
Cadastro MVC da Apuracao de IPI

@author Fabio V Santana
@since 26/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA064
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Apuracao de IPI
oBrw:SetAlias( 'C2N')
oBrw:SetMenuDef( 'TAFA064' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf064Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA064' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA064" , , aFuncao)
EndIf                                     

Return( aRotina ) 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC2N 	:= 	FWFormStruct( 1, 'C2N' )
Local oStruC2P 	:= 	FWFormStruct( 1, 'C2P' )
Local oStruC2O 	:= 	FWFormStruct( 1, 'C2O' )
Local oStruT6X 	:= 	nil
Local oStruT86  :=  nil  

Local 	oModel 	:= 	MPFormModel():New('TAFA064' ,,{ |oModel| ValidModel( oModel ) },{ |oModel| SaveModel( oModel ) } )

If AliasInDic( "T6X" )
	oStruT6X 	:= 	FWFormStruct( 1, 'T6X' )
EndIf
If AliasInDic( "T86" )
	oStruT86  := FWFormStruct( 1, 'T86' )
Endif

oModel:AddFields('MODEL_C2N', /*cOwner*/, oStruC2N)

oModel:AddGrid('MODEL_C2P', 'MODEL_C2N', oStruC2P)
oModel:GetModel( 'MODEL_C2P' ):SetUniqueLine( { 'C2P_CFOP','C2P_CSTIPI'} )  
oModel:GetModel( 'MODEL_C2P' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C2O', 'MODEL_C2N', oStruC2O)
oModel:GetModel( 'MODEL_C2O' ):SetUniqueLine( { 'C2O_INDAJU','C2O_CODAJU' } )   
oModel:GetModel( 'MODEL_C2O' ):SetOptional( .T. )

If AliasInDic( "T6X" )
	oModel:AddGrid('MODEL_T6X', 'MODEL_C2N', oStruT6X)   //Resumo Por Natureza de operação
	oModel:GetModel( 'MODEL_T6X' ):SetUniqueLine( { 'T6X_NATOPE', 'T6X_TPOPER' } )
	oModel:GetModel( 'MODEL_T6X' ):SetOptional( .T. )
EndIf

If AliasInDic( "T86" )
	oModel:AddGrid('MODEL_T86', 'MODEL_C2O', oStruT86)
	oModel:GetModel( 'MODEL_T86' ):SetUniqueLine( { 'T86_CODPAR', 'T86_CODMOD', 'T86_NUMDOC', 'T86_DTDOC', 'T86_SERDOC' } )  
	oModel:GetModel( 'MODEL_T86' ):SetOptional( .T. )
EndIf
oModel:SetRelation( 'MODEL_C2P' , { { 'C2P_FILIAL' , 'xFilial( "C2P" )' } , { 'C2P_ID' , 'C2N_ID' }} , C2P->( IndexKey( 3 ) ) )
                                                        
oModel:SetRelation( 'MODEL_C2O' , { { 'C2O_FILIAL' , 'xFilial( "C2O" )' } , { 'C2O_ID' , 'C2N_ID' }} , C2O->( IndexKey( 4 ) ) )

If AliasInDic( "T6X" )
	oModel:SetRelation( 'MODEL_T6X' , { { 'T6X_FILIAL' , 'xFilial( "T6X" )' } , { 'T6X_ID' , 'C2N_ID' }} , T6X->( IndexKey( 1 ) ) )
EndIf
If AliasInDic( "T86" )
	oModel:SetRelation( 'MODEL_T86' , { { 'T86_FILIAL' , 'xFilial( "T86" )' } , { 'T86_ID' , 'C2N_ID' }, { 'T86_CODAJU' , 'C2O_CODAJU' }} , T86->( IndexKey( 1 ) ) )
EndIf

oModel:GetModel( 'MODEL_C2O' ):SetOptional( .T. )  
oModel:GetModel( "MODEL_C2N" ):SetPrimaryKey( { "C2N_INDAPU", "C2N_DTINI", "C2N_DTFIM" } )           

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA064' )
Local oStruC2N 	:= 	FWFormStruct( 2, 'C2N' )
Local oStruC2P 	:= 	FWFormStruct( 2, 'C2P' )
Local oStruC2O 	:= 	FWFormStruct( 2, 'C2O' )
Local oStruT6X 	:= 	nil //Resumo por Natureza de Operação
Local oStruT86  :=  FWFormStruct( 2, 'T86' )
Local oView     := 	FWFormView():New()

If AliasInDic( "T6X" )
	oStruT6X 	:= FWFormStruct( 2, 'T6X' ) 
	oStruT6X:RemoveField("T6X_ID")
EndIf
If AliasInDic( "T86" )
	oStruT86 	:= FWFormStruct( 2, 'T86' ) 
	oStruT86:RemoveField("T86_ID")
EndIf
oView:SetModel( oModel )
oView:AddField( 'VIEW_C2N', oStruC2N, 'MODEL_C2N' )
oView:EnableTitleView( 'VIEW_C2N', STR0001) //Apuracao de IPI

oView:AddGrid ( 'VIEW_C2O', oStruC2O, 'MODEL_C2O' )
oView:AddGrid ( 'VIEW_C2P', oStruC2P, 'MODEL_C2P' )
If AliasInDic( "T6X" )
	oView:AddGrid ( 'VIEW_T6X', oStruT6X, 'MODEL_T6X' )
EndIf

If AliasInDic( "T86" )
	oView:AddGrid ( 'VIEW_T86', oStruT86, 'MODEL_T86' )
EndIf
oView:CreateHorizontalBox( 'FIELDSC2N', 30 )          
oView:CreateHorizontalBox( 'FOLDERGERAL', 70 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //Ajuste da Apuracao de IPI
oView:CreateHorizontalBox( 'GRIDC2O', 40,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'PANFOLDER2', 60,,, 'FOLDER1', 'ABA01' )

oView:CreateFolder( 'FOLDER2', 'PANFOLDER2' )
If AliasInDic( "T86" )
	oView:AddSheet( 'FOLDER2', 'ABA01', STR0009) //Identificação Documento Fiscal
	oView:CreateHorizontalBox( 'GRIDT86', 100,,, 'FOLDER2', 'ABA01' )
	
	If TamSX3("T86_CODPAR")[1] == 36
		oStruT86:RemoveField( "T86_CODPAR")
		oStruT86:SetProperty( "T86_CPARTI", MVC_VIEW_ORDEM, "03" )
	EndIf
	
	If TamSX3("T86_CODITE")[1] == 36
		oStruT86:RemoveField( "T86_CODITE")
		oStruT86:SetProperty( "T86_ITEM", MVC_VIEW_ORDEM, "11" )
	EndIf
	
Endif
oView:AddSheet( 'FOLDER1', 'ABA02', STR0003) //Detalhamento do IPI por CFOP
oView:CreateHorizontalBox( 'GRIDC2P', 100,,, 'FOLDER1', 'ABA02' )

If AliasInDic( "T6X" )
	oView:AddSheet( 'FOLDER1', 'ABA03', STR0008) //Resumo por Natureza de Operação
	oView:CreateHorizontalBox( 'GRIDT6X', 100,,, 'FOLDER1', 'ABA03' )
	If TamSX3("T6X_NATOPE")[1] == 36
		oStruT6X:RemoveField( "T6X_NATOPE")
		oStruT6X:SetProperty( "T6X_CODNAT", MVC_VIEW_ORDEM, "03" )
	EndIf
EndIf
oView:SetOwnerView( 'VIEW_C2N', 'FIELDSC2N' )
oView:SetOwnerView( 'VIEW_C2O', 'GRIDC2O' )
oView:SetOwnerView( 'VIEW_C2P', 'GRIDC2P' )
If AliasInDic( "T6X" )
	oView:SetOwnerView( 'VIEW_T6X', 'GRIDT6X' )
EndIf
If AliasInDic( "T86" )
	oView:SetOwnerView( 'VIEW_T86', 'GRIDT86' )
Endif

Return oView
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
Return XFUNReflex( nOperation , {""} , 'TAFA064' )	//Array com uma posicao branco para sempre dar mensagem     

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 24/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()  
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'C2N', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction


Return .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf064Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf064Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro := {} 
Local cID			 := ""   //Identificação do registro 
Local nTotDAju := 0
Local nTotCAju := 0
Local lNegat      := .F.   
Local nValAbs := 0
Local nVlrDIpi   := 0
Local nVlrCIpi   := 0

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C2N->( Recno() )

If (C2N->C2N_STATUS $ (' 1'))     
	
	//Verifica os campos obrigatórios e suas opções váidas (C2S)     	  	
	If Empty(C2N->C2N_INDAPU)
		aAdd(aLogErro,{"C2N_INDAPU","000010","C2N",nRecno}) //"Campo Inconsistente ou Vazio" 
	ElseIf !(C2N->C2N_INDAPU)$("01")
		aAdd(aLogErro,{"C2N_INDAPU","000006","C2N",nRecno}) // "Conteúdo do campo não condiz com as opções possíveis" 
	EndIf                                                           
	
	dbSelectArea("C2O")
	C2O->(dbSetOrder(1))
	If MsSeek(xFilial("C2O") + C2N->C2N_ID)
		cID:= C2O->C2O_ID
		While(!C2O->(Eof()) .And. cID == C2O->C2O_ID)    
			If C2O->C2O_INDAJU == '0'
				nTotDAju+= C2O->C2O_VLAJU
			Else
				nTotCAju+= C2O->C2O_VLAJU		      
			EndIf
			cID:= C2O->C2O_ID
			C2O->(dbSkip())
		Enddo	
	Endif             
	
	If !(C2N->C2N_VODEB == nTotDAju)
		aAdd(aLogErro,{"C2N_VODEB","000513","C2N",nRecno}) //"Valor do campo deve corresponder a soma dos debitos no campo 'Val. Ajuste' dos registros de Ajuste de Apuração." 	 
	EndIf
	
	If !(C2N->C2N_VOCRED == nTotCAju)
		aAdd(aLogErro,{"C2N_VOCRED","000512","C2N",nRecno}) //"Valor do campo deve corresponder a soma dos créditos no campo 'Val. Ajuste' dos registros de Ajuste de Apuração." 	 
	EndIf 
	
	dbSelectArea("C2P")
	C2P->(dbSetOrder(1))
	If MsSeek(xFilial ("C2P") + C2N->C2N_ID)
		cID:= C2P->C2P_ID
		While(!C2P->(Eof()) .And. cID == C2P->C2P_ID) 
			cCFOP := Posicione("C0Y", 3, xFilial("C0Y") + C2P->C2P_CFOP, "C0Y_CODIGO")
			If Left(cCFOP ,1) $ ("5|6")
				nVlrDIpi += C2P->C2P_VLIPI  
			ElseIf Left(cCFOP ,1) $ ("1|2|3")
				nVlrCIpi += C2P->C2P_VLIPI  
			Endif
			cID:= C2P->C2P_ID
	    	C2P->(dbSkip())
	    EndDo
	
	EndIf
	  
	If !(C2N->C2N_VDEB == nVlrDIpi )
		aAdd(aLogErro,{"C2N_VDEB","000511","C2N",nRecno}) //"Valor do campo deve corresponder a soma dos debitos no campo 'Val. IPI' " 	 
	EndIf
	If !(C2N->C2N_VCRED == nVlrCIpi )
		aAdd(aLogErro,{"C2N_VCRED","000510","C2N",nRecno}) //"Valor do campo deve corresponder a soma dos creditos no campo 'Val. IPI'" 	 
	EndIf
	  
	lNegat:= ((C2N->C2N_VDEB +  C2N->C2N_VODEB) - (C2N->C2N_VSDANT + C2N->C2N_VCRED + C2N->C2N_VOCRED) < 0) 
	nValAbs:= (C2N->C2N_VDEB +  C2N->C2N_VODEB) - (C2N->C2N_VSDANT + C2N->C2N_VCRED + C2N->C2N_VOCRED)
	If lNegat
			  
		If ( Round(nValAbs,2) * -1 ) <> C2N->C2N_VSCRED 
			aAdd(aLogErro,{"C2N_VSCRED","000509","C2N",nRecno}) //"Valor do 'Sld Credor' deve corresponder ao valor absoluto da expressão: (('Val Deb.' + 'Outros Debitos') - ('Crd Anterior' + 'Val Crédito' + 'Outros Créditos'))"
		Endif
	 	
	 	//************************************************************************************//
		// Caso o Saldo Credor for negativo o Saldo devedor deve ser zerado. //
		//*************************************************************************************
		If C2N->C2N_VSDEV <> 0
			aAdd(aLogErro,{"C2N_VSDEV","000508","C2N",nRecno}) //"Valor do 'Sld Devedor' deve igual a 'Zero', quando o saldo credor corresponder a um valor negativo"                                                                                           
		Endif
		
	Else
		If Round(nValAbs,2) <> C2N->C2N_VSDEV
			aAdd(aLogErro,{"C2N_VSCRED","000509","C2N",nRecno}) //"Valor do 'Sld Credor' deve corresponder ao valor absoluto da expressão: (('Val Deb.' + 'Outros Debitos') - ('Crd Anterior' + 'Val Crédito' + 'Outros Créditos'))"
		Endif
	 	//************************************************************************************//
		// Caso o Saldo Credor for negativo o Saldo devedor deve ser zerado. //
		//*************************************************************************************
		If C2N->C2N_VSCRED <> 0
			aAdd(aLogErro,{"C2N_VSDEV","000508","C2N",nRecno}) //"Valor do 'Sld Devedor' deve igual a 'Zero', quando o saldo credor corresponder a um valor negativo"                                                                                           
		Endif  
		
	Endif	
	
	//ATUALIZO O STATUS DO REGISTROS          
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C2N",.F.)
	    	C2N->C2N_STATUS := "1" 
	    C2N->( MsUnlock() )    
	Else
		RecLock("C2N",.F.)
	    	C2N->C2N_STATUS := "0" 
	    C2N->( MsUnlock() )        
	EndIf

Else
	AADD(aLogErro,{"C2N_ID","000305", "C2N", nRecno })   //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
