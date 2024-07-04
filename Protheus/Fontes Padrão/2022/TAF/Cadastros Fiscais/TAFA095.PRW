#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA095.CH"                                  

STATIC aCmpsAlts	:=	{}

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA095
Cadastro MVC de Identificação do equipamento SAT-CF-e

@author Danilo L Zanaga
@since 17/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA095()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Identificação do equipamento SAT-CF-e 
oBrw:SetAlias( 'C5Q')
oBrw:SetMenuDef( 'TAFA095' )
oBrw:SetCacheView(.F.)
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo Santana
@since 20/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf095Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA095' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA095" , , aFuncao)
EndIf                                     

Return( aRotina ) 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 17/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5Q 	:= 	FWFormStruct( 1, 'C5Q' )
Local oStruC5R 	:= 	FWFormStruct( 1, 'C5R' )
Local oStruC5S 	:= 	FWFormStruct( 1, 'C5S' )
Local oStruC5T 	:= 	FWFormStruct( 1, 'C5T' )
Local oStruC5U 	:= 	FWFormStruct( 1, 'C5U' )
Local oStruCAB 	:= 	FWFormStruct( 1, 'CAB' )
Local oModel 	:= 	MPFormModel():New( 'TAFA095',,{ |oModel| ValidModel( oModel ) },{ |oModel| SaveModel( oModel ) } )

aCmpsAlts	:=	{}

oModel:AddFields('MODEL_C5Q', /*cOwner*/, oStruC5Q)

oModel:AddGrid('MODEL_C5R', 'MODEL_C5Q', oStruC5R)             
oModel:GetModel( 'MODEL_C5R' ):SetUniqueLine({'C5R_DTDOC','C5R_CODSIT','C5R_NUMCFE'}) 
oModel:SetRelation( 'MODEL_C5R' , { { 'C5R_FILIAL' , 'xFilial( "C5R" )' } , { 'C5R_ID' , 'C5Q_ID' } } , C5R->( IndexKey( 1 ) ) )

oModel:AddGrid('MODEL_CAB', 'MODEL_C5R', oStruCAB)             
oModel:GetModel( 'MODEL_CAB' ):SetUniqueLine({'CAB_CFOP','CAB_CSTPIS','CAB_ALQPIS','CAB_CSTCOF','CAB_ALQCOF'}) 
oModel:GetModel( 'MODEL_CAB' ):SetOptional( .T. )
oModel:SetRelation( 'MODEL_CAB' , { { 'CAB_FILIAL' , 'xFilial( "CAB" )' } , { 'CAB_ID' , 'C5Q_ID' }, { 'CAB_DTDOC', 'C5R_DTDOC' },{ 'CAB_CODSIT', 'C5R_CODSIT' },{ 'CAB_NUMCFE', 'C5R_NUMCFE' }  } , CAB->( IndexKey( 1 ) ) )

oModel:AddGrid('MODEL_C5S', 'MODEL_C5R', oStruC5S)             
oModel:GetModel( 'MODEL_C5S' ):SetUniqueLine({'C5S_CODIGO'}) 
oModel:SetRelation( 'MODEL_C5S' , { { 'C5S_FILIAL' , 'xFilial( "C5S" )' } , { 'C5S_ID' , 'C5Q_ID' }, { 'C5S_DTDOC', 'C5R_DTDOC' },{ 'C5S_CODSIT', 'C5R_CODSIT' },{ 'C5S_NUMCFE', 'C5R_NUMCFE' }  } , C5S->( IndexKey( 1 ) ) )

oModel:AddGrid('MODEL_C5T', 'MODEL_C5S', oStruC5T)             
oModel:GetModel( 'MODEL_C5T' ):SetUniqueLine({'C5T_CODTRI','C5T_CST','C5T_MODBC'}) 
oModel:SetRelation( 'MODEL_C5T' , { { 'C5T_FILIAL' , 'xFilial( "C5T" )' } , { 'C5T_ID' , 'C5Q_ID' }, { 'C5T_DTDOC', 'C5R_DTDOC' },{ 'C5T_CODSIT', 'C5R_CODSIT' },{ 'C5T_NUMCFE', 'C5R_NUMCFE' }, { 'C5T_CODIGO', 'C5S_CODIGO'} , { 'C5T_CFOP', 'C5S_CFOP'} , { 'C5T_ORIGEM', 'C5S_ORIGEM'} } , C5T->( IndexKey( 1 ) ) )

oModel:AddGrid('MODEL_C5U', 'MODEL_C5R', oStruC5U)             
oModel:GetModel( 'MODEL_C5U' ):SetUniqueLine({'C5U_NUMERO'}) 
oModel:GetModel( 'MODEL_C5U' ):SetOptional( .T. )
oModel:SetRelation( 'MODEL_C5U' , { { 'C5U_FILIAL' , 'xFilial( "C5U" )' } , { 'C5U_ID' , 'C5Q_ID' }, { 'C5U_DTDOC', 'C5R_DTDOC' },{ 'C5U_CODSIT', 'C5R_CODSIT' },{ 'C5U_NUMCFE', 'C5R_NUMCFE' }  } , C5U->( IndexKey( 1 ) ) )
               
oModel:AddRules( 'MODEL_C5T', 'C5T_CODTRI', 'MODEL_C5T', 'C5T_CST', 2 )
oModel:AddRules( 'MODEL_C5T', 'C5T_CODTRI', 'MODEL_C5T', 'C5T_MODBC', 2 )  

oModel:GetModel( "MODEL_C5Q" ):SetPrimaryKey( { "C5Q_MODSAT" } )                                                                                                                                           


Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 17/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA095' )
Local 	oStruC5Q 	:= 	FWFormStruct( 2, 'C5Q' )
Local 	oStruC5R 	:= 	FWFormStruct( 2, 'C5R' )
Local   oStruC5S 	:= 	FWFormStruct( 2, 'C5S' )
Local   oStruC5T 	:= 	FWFormStruct( 2, 'C5T' )
Local   oStruC5U 	:= 	FWFormStruct( 2, 'C5U' )
Local   oStruCAB 	:= 	FWFormStruct( 2, 'CAB' )

Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oStruC5T:SetProperty( 'C5T_CST' , MVC_VIEW_LOOKUP  , { || XFUNChgF3() } )
oStruC5T:SetProperty( 'C5T_MODBC'  , MVC_VIEW_LOOKUP  , { || XFUNChgF3( ,,"MBC" ) } )

oView:AddField( 'VIEW_C5Q', oStruC5Q, 'MODEL_C5Q' )
oView:EnableTitleView( 'VIEW_C5Q', STR0001 ) //Identificação do equipamento SAT-CF-e

oView:AddGrid ( 'VIEW_C5R', oStruC5R, 'MODEL_C5R' )
oView:EnableTitleView( 'VIEW_C5R', STR0002) //Cupons do equipamento SAT-CF-e"

oView:AddGrid ( 'VIEW_C5S', oStruC5S, 'MODEL_C5S' )
oView:EnableTitleView( 'VIEW_C5S', STR0003) //Itens dos Cupons do equipamento SAT-CF-e"

oView:AddGrid ( 'VIEW_C5T', oStruC5T, 'MODEL_C5T' )
oView:EnableTitleView( 'VIEW_C5T', STR0004) //Tributos dos Itens dos Cupons do equipamento SAT-CF-e"

oView:AddGrid ( 'VIEW_C5U', oStruC5U, 'MODEL_C5U' )
oView:EnableTitleView( 'VIEW_C5U', STR0005) //Processos referenciados - CFe"

oView:AddGrid ( 'VIEW_CAB', oStruCAB, 'MODEL_CAB' )
oView:EnableTitleView( 'VIEW_CAB', STR0008 ) //"Registro análitico do Documento - CF-e (Código 59)"

oView:CreateHorizontalBox( 'FIELDSC5Q', 20 )     
oView:CreateHorizontalBox( 'GRIDC5R', 30)
 
oView:CreateHorizontalBox( 'PAINEL_INFERIOR', 50 )		//Painel da parte INFERIOR com os detalhes do documento

oView:CreateFolder( 'FOLDERS_PAINEL_INFERIOR', 'PAINEL_INFERIOR' )

//(1) - Folder "Detalhes"
oView:AddSheet( 'FOLDERS_PAINEL_INFERIOR', 'ABA01', STR0006) 
oView:AddSheet( 'FOLDERS_PAINEL_INFERIOR', 'ABA02', STR0007) 
oView:AddSheet( 'FOLDERS_PAINEL_INFERIOR', 'ABA03', STR0008 ) //"Registro análitico do Documento - CF-e (Código 59)"

//Fields (Cupons)
oView:CreateHorizontalBox( 'GRIDC5S', 050,,, 'FOLDERS_PAINEL_INFERIOR', 'ABA01' )
oView:CreateHorizontalBox( 'GRIDC5T', 050,,, 'FOLDERS_PAINEL_INFERIOR', 'ABA01' )
oView:CreateHorizontalBox( 'GRIDC5U', 100,,, 'FOLDERS_PAINEL_INFERIOR', 'ABA02' )
oView:CreateHorizontalBox( 'GRIDCAB', 100,,, 'FOLDERS_PAINEL_INFERIOR', 'ABA03' )

oView:SetOwnerView( 'VIEW_C5Q', 'FIELDSC5Q' )
oView:SetOwnerView( 'VIEW_C5R', 'GRIDC5R' )
oView:SetOwnerView( 'VIEW_C5S', 'GRIDC5S' )
oView:SetOwnerView( 'VIEW_C5T', 'GRIDC5T' )
oView:SetOwnerView( 'VIEW_C5U', 'GRIDC5U' )
oView:SetOwnerView( 'VIEW_CAB', 'GRIDCAB' )

If TamSX3("C5S_CODCTA")[1] == 36
	oStruC5S:RemoveField("C5S_CODCTA")
	oStruC5S:SetProperty("C5S_CTACTB", 	MVC_VIEW_ORDEM, "20")		
	oStruC5S:SetProperty("C5S_DCODCT", 	MVC_VIEW_ORDEM, "21")
EndIf

If TamSX3("C5S_CODIGO")[1] == 36
	oStruC5S:RemoveField("C5S_CODIGO")
	oStruC5S:SetProperty("C5S_ITEM", 	MVC_VIEW_ORDEM, "06")
EndIf
If TamSX3("CAB_CODCTA")[1] == 36
	oStruCAB:RemoveField("CAB_CODCTA")
	oStruCAB:SetProperty("CAB_CTACTB", 	MVC_VIEW_ORDEM, "25")		
	oStruCAB:SetProperty("CAB_DCODCT", 	MVC_VIEW_ORDEM, "26")
	oStruCAB:SetProperty("CAB_INFCOM", 	MVC_VIEW_ORDEM, "27")
EndIf

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validacao de alguns campos do model.

@param  oModel - parametro com o Model MVC 

@return lRet - Flag de validacao, onde .T. eh valido e .F. NAO valido

@author Danio L Zanaga
@since 17/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local	lRet		:=	.T.
Local	cCNPJ 		:= 	oModel:GetValue( 'MODEL_C5R' , 'C5R_CNPJ' )
Local	cCPF 		:= 	oModel:GetValue( 'MODEL_C5R' , 'C5R_CPF' )
Local 	nOperation 	:= 	oModel:GetOperation()

If( lRet := XFUNReflex( nOperation , aCmpsAlts , 'TAFA095' ) )
	
	//Validacao do campo CNPJ/CPF, dependendo do Tipo de Participante. PJ habilita o CNPJ, Fisica o CPF.
	If !Empty(cCNPJ) .And. !Empty(cCPF)
		Help( ,,"CNPJOUCPF",,, 1, 0 ) 
		lRet	:=	.F.
	EndIf
EndIf

Return lRet                  

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
		TAFAltStat( 'C5Q', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	
	FwFormCommit( oModel )		
	
End Transaction


Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} A095LogAlt
Funcao utilizada para atualizar uma variavel STATIC tratada no SAVE no modelo.
	Tratamento passado por framework para podermos identificar os campos alterados
	no modelo para podermos exibir alguns alertas.

@param  Nil

@return Sempre .T.
                
@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A095LogAlt()

If ValType( aCmpsAlts ) == "A" .And. aScan( aCmpsAlts , ReadVar() ) == 0
	aAdd( aCmpsAlts , ReadVar() )
EndIf

Return .T.                     

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf095Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 20/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf095Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro := {} 
Local cChave   := ""           
Local cID			 := ""   
Local dDtDoc   := CTOD("  /  /    ")
Local cCodSit   := ""
Local cNumCfe := ""

Default lJob:= .F.
  
//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5Q->( Recno() )

If (C5Q->C5Q_STATUS $ (' 1'))  
	
	//Valída o Conteúdo da Tabela Filho referente ao campo da "C5A"			   
	If Empty(C5Q->C5Q_MODSAT)
		aAdd(aLogErro,{"C5Q_MODSAT","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
	Else
		cChave := C5Q->C5Q_MODSAT
		xValRegTab("C0W",cChave,4,,@aLogErro,, { "C5Q", "C5Q_MODSAT", nRecno } )     
	EndIf	                                                                                                     
	
	//Valída o conteúdo da Grid "Cupom Fiscal Eletrônico emitido SAT-CF-e"  
	dbSelectArea("C5R")
	C5R->(dbSetOrder(1))
	If C5R->(MsSeek(xFilial("C5R") + C5Q->C5Q_ID)) 
		
   		If Empty(C5R->C5R_DTDOC)
			aAdd(aLogErro,{"C5R_DTDOC","000010","C5Q",nRecno}) 	//"Campo Inconsistente ou Vazio" 
		EndIf
		
   		If Empty(C5R->C5R_CODSIT)
			aAdd(aLogErro,{"C5R_CODSIT","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
		Else
			cChave := C5R->C5R_CODSIT
  			xValRegTab("C02",cChave,3,,@aLogErro,, { "C5Q", "C5R_CODSIT", nRecno })     
   		EndIf	  

   		If Empty(C5R->C5R_NUMCFE)
			aAdd(aLogErro,{"C5R_NUMCFE","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
		EndIf

   		If Empty(C5R->C5R_CHVCFE)
			aAdd(aLogErro,{"C5R_CHVCFE","000010","C5Q",nRecno})  	//"Campo Inconsistente ou Vazio" 
		EndIf

   		If Empty(C5R->C5R_VLCFE)
			aAdd(aLogErro,{"C5R_VLCFE","000010","C5Q",nRecno})  		//"Campo Inconsistente ou Vazio" 
		EndIf
	
    	cID:= C5R->C5R_ID
    	While (!C5R->(Eof()) .And. cID== C5R->C5R_ID)
    		dbSelectArea("C5S")
    		C5S->(dbSetOrder(1))
    	    If C5S->(MsSeek(xFilial("C5S") + C5R->C5R_ID + DTOS(C5R->C5R_DTDOC) + C5R->C5R_CODSIT + C5R->C5R_NUMCFE)) 
    	    	cID		   	:= C5S->C5S_ID
				dDtDoc    	:= C5S->C5S_DTDOC
				cCodSit   	:= C5S->C5S_CODSIT
				cNumCfe 	:= C5S->C5S_NUMCFE   
				
				//Valída o conteúdo da Grid "Itens do Cupon Fiscal Eletrônico" 					  
	        	While(!C5S->(Eof()) .And. dDtDoc == C5S->C5S_DTDOC .And. cCodSit  == C5S->C5S_CODSIT .And. cNumCfe == C5S->C5S_NUMCFE)      
	        	
					//Valída o registro da tabela da consulta padrão, apenas para os campos que não estão vazios"   
	   	        	If Empty(C5S->C5S_CODIGO)
						aAdd(aLogErro,{"C5S_CODIGO","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					Else
						cChave := C5S->C5S_CODIGO
  						xValRegTab("C1L",cChave,3,,@aLogErro,, { "C5Q", "C5S_CODIGO", nRecno })     
   					EndIf
   					
   					If Empty(C5S->C5S_VLOPR)
						aAdd(aLogErro,{"C5S_VLOPR","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
   					
    	        	If Empty(C5S->C5S_CFOP)
						aAdd(aLogErro,{"C5S_CFOP","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					Else
						cChave := C5S->C5S_CFOP
  						xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C5Q", "C5S_CFOP", nRecno })     
   					EndIf	         
   					
    	        	If Empty(C5S->C5S_ORIGEM)
						aAdd(aLogErro,{"C5S_ORIGEM","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					Else
						cChave := C5S->C5S_ORIGEM
  						xValRegTab("C03",cChave,3,,@aLogErro,, { "C5Q", "C5S_CFOP", nRecno })     
   					EndIf	
   					
   					If !Empty(C5S->C5S_CODOBS)
						cChave := C5S->C5S_CODOBS
  						xValRegTab("C3R",cChave,3,,@aLogErro,, { "C5Q", "C5S_CODOBS", nRecno })     
   					EndIf       
   					
   					If !Empty(C5S->C5S_CODCTA)
						cChave := C5S->C5S_CODCTA
  						xValRegTab("C1O",cChave,3,,@aLogErro,, { "C5Q", "C5S_CODCTA", nRecno })     
   					EndIf
    	        		    	                     

					/*+------------------------------------------------------+
					  | Data:26.08.2014	     	                 				 |
					  | Responsável: Evandro dos Santos Oliveira             |
					  | Descrição da Alteração: Inclusão das validações nas  |
					  | tabelas CAB, C5T, CSU 									 |
					  +------------------------------------------------------+*/ 
				  
				  	dbSelectArea("C5T")
				  	dbSetOrder(1)
					If MsSeek(xFilial("C5T")+C5S->C5S_ID+DTOS(C5S->C5S_DTDOC)+C5S->C5S_CODSIT+C5S->C5S_NUMCFE+C5S->C5S_CODIGO+C5S->C5S_CFOP+C5S->C5S_ORIGEM)
					
				  		While !C5T->(Eof()) .And. (	C5S->C5S_ID+DTOS(C5S->C5S_DTDOC)+C5S->C5S_CODSIT+C5S->C5S_NUMCFE+C5S->C5S_CODIGO+C5S->C5S_CFOP+C5S->C5S_ORIGEM  ==;
				  									   	C5T->C5T_ID+DTOS(C5T->C5T_DTDOC)+C5T->C5T_CODSIT+C5T->C5T_NUMCFE+C5T->C5T_CODIGO+C5T->C5T_CFOP+C5T->C5T_ORIGEM)                                                                                                                                                                                     
				  		
				  			If Empty(C5T->C5T_CODTRI)
								aAdd(aLogErro,{"C5T_CODTRI","000010","C5Q",nRecno}) 	//"Campo Inconsistente ou Vazio" 
							Else
								cChave := C5T_CODTRI
			  					xValRegTab("C3S",cChave,3,,@aLogErro,, { "C5Q", "C5T_CODTRI", nRecno })     
			   				EndIf	 
						
				  			If Empty(C5T->C5T_CST)
								aAdd(aLogErro,{"C5T_CST","000010","C5Q",nRecno}) 	//"Campo Inconsistente ou Vazio" 
							EndIf

							C5T->(dbSkip())
				  		EndDo
				  	EndIf
  
  					cID		 	:= C5S->C5S_ID
					dDtDoc    	:= C5S->C5S_DTDOC
					cCodSit   	:= C5S->C5S_CODSIT
					cNumCfe 	:= C5S->C5S_NUMCFE     
    	 			C5S->(dbSkip())	 				
    	 		EndDo                                                                                                           
    	   	EndIf
    	    
    	   	dbSelectArea("C5U")
		  	dbSetOrder(1)
			If MsSeek(xFilial("C5U")+C5R->C5R_ID+DTOS(C5R->C5R_DTDOC)+C5R->C5R_CODSIT+C5R->C5R_NUMCFE)
			
				While !C5U->(Eof()) .And. (	C5R->C5R_ID+DTOS(C5R->C5R_DTDOC)+C5R->C5R_CODSIT+C5R->C5R_NUMCFE ==;
											 	C5U->C5U_ID+DTOS(C5U->C5U_DTDOC)+C5U->C5U_CODSIT+C5U->C5U_NUMCFE)
						
			   		If Empty(C5U->C5U_NUMERO)
						aAdd(aLogErro,{"C5U_NUMERO","000010","C5Q",nRecno}) 	//"Campo Inconsistente ou Vazio" 
					Else
						cChave := C5U->C5U_NUMERO
			  			xValRegTab("C1G",cChave,3,,@aLogErro,, { "C5Q", "C5U_NUMERO", nRecno })     
			   		EndIf		 

					C5U->(dbSkip())
				EndDo                                                                                                                                                                                                               
			EndIf 	
    	    
    	    
    	   	dbSelectArea("CAB")
	   		dbSetOrder(1)
	   		If MsSeek(xFilial("CAB")+C5R->C5R_ID+DTOS(C5R->C5R_DTDOC)+C5R->C5R_CODSIT+C5R->C5R_NUMCFE)

	   			While !CAB->(Eof()) .And. (	C5R->C5R_ID+DTOS(C5R->C5R_DTDOC)+C5R->C5R_CODSIT+C5R->C5R_NUMCFE ==;
	   											CAB->CAB_ID+DTOS(CAB->CAB_DTDOC)+CAB->CAB_CODSIT+CAB->CAB_NUMCFE)
	   											
	   				If Empty(CAB->CAB_CFOP)
						aAdd(aLogErro,{"CAB_CFO","000010","C5Q",nRecno}) 	//"Campo Inconsistente ou Vazio" 
					Else
						cChave := CAB->CAB_CFOP
			  			xValRegTab("C0Y",cChave,3,,@aLogErro,, { "C5Q", "CAB_CFO", nRecno })     
			   		EndIf	
			   		
	   				If Empty(CAB->CAB_CSTPIS)
						aAdd(aLogErro,{"CAB_CSTPIS","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					Else
						cChave := CAB->CAB_CSTPIS
			  			xValRegTab("C17",cChave,3,,@aLogErro,, { "C5Q", "CAB_CSTPIS", nRecno })     
			   		EndIf	            
	   		
	   				If Empty(CAB->CAB_CSTCOF)
						aAdd(aLogErro,{"CAB_CSTCOF","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					Else
						cChave := CAB->CAB_CSTCOF
			  			xValRegTab("C17",cChave,3,,@aLogErro,, { "C5Q", "CAB_CSTCOF", nRecno })     
			   		EndIf	   
	   			
	   				If Empty(CAB->CAB_CODCTA)
						aAdd(aLogErro,{"CAB_CODCTA","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					Else
						cChave := CAB->CAB_CODCTA
			  			xValRegTab("C1O",cChave,3,,@aLogErro,, { "C5Q", "CAB_CODCTA", nRecno })     
			   		EndIf	
			   		
			   		If Empty(CAB->CAB_VLOPR)
						aAdd(aLogErro,{"CAB_VLOPR","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
			   		
			   		If Empty(CAB->CAB_VLBCPI)
						aAdd(aLogErro,{"CAB_VLBCPI","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf

			   		If Empty(CAB->CAB_VLPIS)
						aAdd(aLogErro,{"CAB_VLPIS","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf

			   		If Empty(CAB->CAB_VLBCCO)
						aAdd(aLogErro,{"CAB_VLBCCO","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf
					
			   		If Empty(CAB->CAB_VLCOFI)
						aAdd(aLogErro,{"CAB_VLCOFI","000010","C5Q",nRecno}) //"Campo Inconsistente ou Vazio" 
					EndIf

	   				CAB->(dbSkip())	
	   			EndDo
	   		EndIf             
	   		
    	   	cID:= C5R->C5R_ID                       
    	 	C5R->(dbSkip())
    	EndDo
    	
    	

    EndIf
    	
	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0	
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C5Q",.F.)
	    	C5Q->C5Q_STATUS := "1" 
	    C5Q->( MsUnlock() )    
	Else
		RecLock("C5Q",.F.)
	    	C5Q->C5Q_STATUS := "0" 
	    C5Q->( MsUnlock() )
	EndIf

Else
	AADD(aLogErro,{"C5Q_ID","000305", "C5Q", nRecno })   //Registros válidos não podem ser validados novamente
EndIf	

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
