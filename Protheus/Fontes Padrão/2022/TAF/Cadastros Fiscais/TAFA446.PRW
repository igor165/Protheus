#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA446.CH"
//-------------------------------------------------------------------                                                       
/*/{Protheus.doc} TAFA446
Cadastro MVC - Apuração de ICMS DIFAL/FECP

@author Paulo Sérgio V.B. Santana
@since 30/08/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA446
Local oBrw	      := FWmBrowse():New()
Local cEnter    := Chr(13) + Chr(10)
Local cTitulo   := ""
Local cMensagem := ""
If !TAFAlsInDic( "LEF",.F. ) 
	cTitulo :=  STR0009  //"Dicionário Incompatível"
	cMensagem := STR0010 //"Inconsistência: O Ambiente do TAF está com o dicionário de dados incompatível com a versão dos fontes no repositório de dados. "
	cMensagem += STR0011 //"Para utilizar a rotina verifique os procedimentos necessários para atualização através do link abaixo:" + cEnter
	cMensagem += STR0012 //"http://tdn.totvs.com/pages/viewpage.action?pageId=248579149"
	
	Aviso( cTitulo, cMensagem, { STR0013 }, 3 ) // #"Encerrar"
Else
	LEF->( dbSetOrder(3) )
	oBrw:SetDescription( STR0001 ) //Apuração de DIFAL/FECP
	oBrw:SetAlias( 'LEF' )
	oBrw:SetMenuDef( 'TAFA446' )
	oBrw:Activate()  
Endif
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Paulo Sérgio V.B. Santana
@since 30/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()    
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf446Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA446' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA446" , , aFuncao)
EndIf                                     

Return( aRotina ) 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Sérgio V.B. Santana
@since 30/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruLEF 	as object
Local oStruLEG 	as object
Local oStruLEH 	as object
Local oStruLEI 	as object
Local oStruLEQ 	as object
Local oModel 		as object

oStruLEF 	:= 	FWFormStruct( 1, 'LEF' )
oStruLEG 	:= 	FWFormStruct( 1, 'LEG' )
oStruLEH 	:= 	FWFormStruct( 1, 'LEH' )
oStruLEI 	:= 	FWFormStruct( 1, 'LEI' )
oStruLEQ 	:= 	FWFormStruct( 1, 'LEQ' )
oModel		:= 	MPFormModel():New( 'TAFA446' ,,{ |oModel| ValidModel( oModel ) },{ |oModel| SaveModel( oModel ) }  )
      
oModel:AddFields('MODEL_LEF', /*cOwner*/, oStruLEF )

oModel:AddGrid('MODEL_LEG', 'MODEL_LEF', oStruLEG)  //Ajustes
oModel:GetModel( 'MODEL_LEG' ):SetUniqueLine( { 'LEG_CODAJU' } )
oModel:GetModel( 'MODEL_LEG' ):SetOptional( .T. )

oModel:AddGrid('MODEL_LEH', 'MODEL_LEG', oStruLEH)   //Informacoes adicionais Ajuste Apuração
oModel:GetModel( 'MODEL_LEH' ):SetUniqueLine( { 'LEH_DOCARR', 'LEH_NRPROC' } )
oModel:GetModel( 'MODEL_LEH' ):SetOptional( .T. )

oModel:AddGrid('MODEL_LEI', 'MODEL_LEF', oStruLEI)   //Obrigações a Recolher
oModel:GetModel( 'MODEL_LEI' ):SetUniqueLine( { 'LEI_DOCARR', 'LEI_NRPROC' } )
oModel:GetModel( 'MODEL_LEI' ):SetOptional( .T. )

oModel:AddGrid('MODEL_LEQ', 'MODEL_LEG', oStruLEQ)   //Identificação dos Documentos Fiscais
oModel:GetModel( 'MODEL_LEQ' ):SetUniqueLine( { 'LEQ_CODPAR', 'LEQ_CODMOD', 'LEQ_NRODOC','LEQ_DTDOC','LEQ_SERDOC','LEQ_SUBSER','LEQ_CODITE' } )
oModel:GetModel( 'MODEL_LEQ' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_LEG' , { { "LEG_FILIAL" , 'xFilial( "LEG" )' } , { 'LEG_ID' , 'LEF_ID' }} , LEG->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_LEI' , { { 'LEI_FILIAL' , 'xFilial( "LEI" )' } , { 'LEI_ID' , 'LEF_ID' }} , LEI->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_LEH' , { { 'LEH_FILIAL' , 'xFilial( "LEH" )' } , { 'LEH_ID' , 'LEF_ID' }, { 'LEH_CODAJU' , 'LEG_CODAJU' } } , LEH->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_LEQ' , { { 'LEQ_FILIAL' , 'xFilial( "LEQ" )' } , { 'LEQ_ID' , 'LEF_ID' }, { 'LEQ_CODAJU' , 'LEG_CODAJU' } } , LEQ->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_LEF" ):SetPrimaryKey( { "LEF_DTINI", "LEF_DTFIN", "LEF_UF"  } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Sérgio V.B. Santana
@since 30/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	 	as object
Local oStruLEF 	as object
Local oStruLEG 	as object 
Local oStruLEH 	as object  
Local oStruLEI 	as object
Local oStruLEQ 	as object
Local oView 	 	as object
Local cGrpPerio	as character
Local cGrpDIFAL	as character
Local cGrpFECP	as character
Local nI			as numeric

oModel		:= FWLoadModel( 'TAFA446' )
oStruLEF	:= FWFormStruct( 2, 'LEF' )
oStruLEG	:= FWFormStruct( 2, 'LEG' ) 
oStruLEH	:= FWFormStruct( 2, 'LEH' )  
oStruLEI	:= FWFormStruct( 2, 'LEI' )
oStruLEQ	:= FWFormStruct( 2, 'LEQ' )
oView		:= FWFormView():New()

cGrpPerio:= "LEF_UF|LEF_DESCUF|LEF_DTINI|LEF_DTFIN|"
cGrpDIFAL:= "LEF_SLDCRD|LEF_TOTDEB|LEF_OUTDEB|LEF_TOTCDI|LEF_SLDDIF|LEF_DEDDIF|LEF_VLREC|LEF_ESTCDI|LEF_OUTCDI|LEF_ESTDDI|LEF_DEBESD|LEF_SLDSEG"
cGrpFECP := "LEF_TODEBF|LEF_TOTCDF|LEF_SLDCRF|LEF_OUTDFC|LEF_ESTCFC|LEF_OUTCFC|LEF_ESTDFC|LEF_SLDDAF|LEF_DEDFCP|LEF_VLRECF|LEF_SLDCTF|LEF_DEBESF|"
ni       := 0

oView:SetModel( oModel )

oView:AddField( 'VIEW_LEF', oStruLEF, 'MODEL_LEF' )
oView:AddGrid ( 'VIEW_LEG', oStruLEG, 'MODEL_LEG' )
oView:AddGrid ( 'VIEW_LEH', oStruLEH, 'MODEL_LEH' )
oView:AddGrid ( 'VIEW_LEI', oStruLEI, 'MODEL_LEI' )
oView:AddGrid ( 'VIEW_LEQ', oStruLEQ, 'MODEL_LEQ' )

oView:CreateHorizontalBox( 'FIELDSLEF', 30 )          
oView:CreateHorizontalBox( 'PANFOLDER1', 70 )

oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //'Ajustes da Apuracao' 
oView:CreateHorizontalBox( 'GRIDLEG', 40,,, 'FOLDER1', 'ABA01' )
oView:CreateHorizontalBox( 'PANFOLDER2', 60,,, 'FOLDER1', 'ABA01' )

oView:CreateFolder( 'FOLDER2', 'PANFOLDER2' )

oView:AddSheet( 'FOLDER2', 'ABA01', STR0003) //'Informações adicionais'
oView:CreateHorizontalBox( 'GRIDLEH', 100,,, 'FOLDER2', 'ABA01' )

oView:AddSheet( 'FOLDER2', 'ABA02', STR0008) //Identificação dos Documentos Fiscais
oView:CreateHorizontalBox( 'GRIDLEQ', 100,,, 'FOLDER2', 'ABA02' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0004) //'Valores declaratórios'
oView:CreateHorizontalBox( 'GRIDLEI', 100,,, 'FOLDER1', 'ABA02' )

oView:SetOwnerView( 'VIEW_LEF', 'FIELDSLEF' )
oView:SetOwnerView( 'VIEW_LEG', 'GRIDLEG' )
oView:SetOwnerView( 'VIEW_LEH', 'GRIDLEH' )
oView:SetOwnerView( 'VIEW_LEI', 'GRIDLEI' )
oView:SetOwnerView( 'VIEW_LEQ', 'GRIDLEQ' )

/*----------------------------------------------------------------
					Grupo de campos do DIFAL
----------------------------------------------------------------*/
oStruLEF:AddGroup( "GRP_PERIODO", STR0005, "", 1 ) //Período de Apuração
oStruLEF:AddGroup( "GRP_DIFAL"  , STR0006, "", 1 ) //Apuração DIFAL
oStruLEF:AddGroup( "GRP_FECP"   , STR0007, "", 1 ) //Apuração FECP

aCmpGrp := StrToKArr(cGrpPerio,"|")
For nI := 1 to Len(aCmpGrp)
	oStruLEF:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_PERIODO")
Next nI

aCmpGrp := StrToKArr(cGrpDIFAL,"|")
For nI := 1 to Len(aCmpGrp)
	oStruLEF:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_DIFAL")
Next nI

aCmpGrp := StrToKArr(cGrpFECP,"|")
For nI := 1 to Len(aCmpGrp)
	oStruLEF:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_FECP")
Next nI

If TamSX3("LEQ_CODPAR")[1] == 36
	oStruLEQ:SetProperty("LEQ_CPARTI", MVC_VIEW_ORDEM, "04" )
	oStruLEQ:RemoveField("LEQ_CODPAR")
EndIf

If TamSX3("LEQ_CODITE")[1] == 36
	oStruLEQ:SetProperty("LEQ_ITEM", MVC_VIEW_ORDEM, "13" )
	oStruLEQ:RemoveField("LEQ_CODITE")
EndIf
oStruLEG:RemoveField("LEG_IDSUBI")
oStruLEG:RemoveField("LEG_ID")
oStruLEH:RemoveField("LEH_ID")
oStruLEQ:RemoveField("LEQ_ID")
oStruLEF:RemoveField("LEF_ID")
oStruLEF:RemoveField("LEF_STATUS")

Return oView         

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 30/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local nOperation 	as numeric

nOperation:= oModel:GetOperation()  
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'LEF', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de valida da inclusao dos dados, chamada no final, no momento da gravacao do modelo

@param  oModel -> Modelo de dados
@return .T. ou  .F.

@author Paulo Sérgio V.B. Santana
@since 30/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local 	nOperation		as numeric
nOperation 	:= 	oModel:GetOperation()
Return XFUNReflex( nOperation , {""} , 'TAFA446' )	//Array com uma posicao branco para sempre dar mensagem                                                                                                                                   

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf446Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo Sérgio V.B. Santana
@since 30/08/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf446Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro as array
Local cChave	as character	        
Local cID	as character 		//Identificação do registro 
Local cCodAju as character	//Código do Ajuste

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := LEF->( Recno() )
  
If (LEF->LEF_STATUS $ (' 1'))     
	/********************************************************************************* //
	|| Verifica os campos obrigatórios e suas opções váidas (LEF)     	                 ||
	//*********************************************************************************/ 	
	If Empty(LEF->LEF_UF)
		aAdd(aLogErro,{"LEF_UF","000010","LEF",nRecno}) //"Campo Inconsistente ou Vazio" 
	Else
		cChave := LEF->LEF_UF
		xValRegTab("C09",cChave,3,,@aLogErro, { "LEF", "LEG_UF", nRecno } )
	EndIf                                                           
	
	IF Empty( LEF->LEF_DTINI ) .Or. Empty( LEF->LEF_DTFIN )
		If Empty( LEF->LEF_DTINI ) 
			aAdd(aLogErro,{"LEF_DTINI","000010","LEF",nRecno}) //"Campo Inconsistente ou Vazio" 
		EndIf    
	  	If Empty( LEF->LEF_DTFIN ) 
			aAdd(aLogErro,{"LEF_DTFIN","000010","LEF",nRecno}) //"Campo Inconsistente ou Vazio" 
		EndIf
	Else
		If LEF->LEF_DTINI >= LEF->LEF_DTFIN
			aAdd(aLogErro,{"LEF_DTFIN","000578","LEF",nRecno}) //Campo Inconsistente ou Vazio" 
		Endif  
	Endif
	
  	dbSelectArea("LEG")
  	LEG->(dbSetOrder(1))
  	If MsSeek(xFilial("LEG") + LEF->LEF_ID)
  		cID:= LEG->LEG_ID
  		While(!LEG->(Eof()) .And. cID == LEG->LEG_ID) 
  	 		If Empty(LEG->LEG_CODAJU)
				aAdd(aLogErro,{"LEG_CODAJU","000010","LEF",nRecno}) //"Campo Inconsistente ou Vazio" 
			Else
				cChave := LEG->LEG_CODAJU 
  				xValRegTab("C1A",cChave,4,,@aLogErro, { "LEF", "LEG_CODAJU", nRecno } )     
   			EndIf	                 
   			
   			dbSelectArea("LEH")
			LEH->(dbSetOrder(1))
  			If MsSeek(xFilial("LEH") + LEG->LEG_ID + LEG->LEG_CODAJU)
  				cID    := LEH->LEH_ID  
  				cCodAju:= LEH->LEH_CODAJU
  				While(!LEH->(Eof()) .And. cID == LEH->LEH_ID .And. cCodAju == LEH->LEH_CODAJU) 
  	 				If !Empty(LEH->LEH_DOCARR)
						cChave := LEH->LEH_DOCARR
						xValRegTab("C0R",cChave,4,,@aLogErro, { "LEF", "LEH_DOCARR", nRecno } ) 
					EndIf
   					If !Empty(LEH->LEH_NRPROC)
						cChave := LEH->LEH_NRPROC
  						xValRegTab("C1G",cChave,3,,@aLogErro,,  { "LEF", "LEH_NRPROC", nRecno })     
   					EndIf   						
  		   			LEH->(dbSkip())            
  				Enddo
    		Endif
    		LEG->(dbSkip())                                      
    	Enddo
    Endif
    
	dbSelectArea("LEI")
  	LEI->(dbSetOrder(1))
  	If MsSeek(xFilial("LEI") + LEF->LEF_ID)
  		cID:= LEI->LEI_ID
  		While(!LEI->(Eof()) .And. cID == LEI->LEI_ID) 
 			If !Empty(LEI->LEI_DOCARR)
				cChave := LEI->LEI_DOCARR
				xValRegTab("C0R",cChave,4,,@aLogErro, { "LEF", "LEI_DOCARR", nRecno } ) 
			EndIf
			If !Empty(LEI->LEI_NRPROC)
				cChave := LEI->LEI_NRPROC
				xValRegTab("C1G",cChave,3,,@aLogErro,,  { "LEF", "LEI_NRPROC", nRecno })     
			EndIf 	
  		   LEI->(dbSkip())         
  		Enddo
    Endif        
  	
	//ATUALIZO O STATUS DO REGISTRO
	//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
	RecLock("LEF",.F.)
	LEF->LEF_STATUS := IIF( Len(aLogErro) > 0,"1","0" ) 
	LEF->( MsUnlock() )    
	
Else
	AADD(aLogErro,{"LEF_ID","000305", "LEF", nRecno })   //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
