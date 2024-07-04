#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA350.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA350
Cadastro MVC de Demonstrativo IR e CSLL Retido Fonte

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA350()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Demonst. IR e CSLL Ret. Fonte"
oBrw:SetAlias( 'CEX')
oBrw:SetMenuDef( 'TAFA350' )
CEX->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Paulo VilasBoas Santana
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF350Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA350" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Vilas Boas
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCEX := FWFormStruct( 1, 'CEX' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA350' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCEX:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CEX' , /*cOwner*/, oStruCEX) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CEX'):SetPrimaryKey( { 'CEX_PERIOD','CEX_CNPJ','CEX_IDREC'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA350' )
Local oStruCEX:= 	FWFormStruct( 2, 'CEX' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCEX:RemoveField('CEX_ID')
oStruCEX:RemoveField('CEX_IDREC')
                                       
oView:AddField('VIEW_CEX' , oStruCEX,  'MODEL_CEX' ) 
oView:EnableTitleView( 'VIEW_CEX', STR0001 ) //"Demonst. IR e CSLL Ret. Fonte" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CEX', 'PAINEL_PRINCIPAL' )   

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Paulo Vilas Boas 
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao responsavel por setar o Status do registro para Branco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TAFAltStat( "CEX", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf350Vld

@author Paulo Vilas Boas Santana
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF350Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cCODREC  	:= Posicione( "CW9", 1, xFilial( "CW9" ) + CEX->CEX_IDREC, "CW9_CODIGO" )

Default lJob := .F.

If CEX->CEX_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CEX->CEX_PERIOD)
		Aadd( aLogErro, {"CEX_PERIOD", "000001", "CEX", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o CNPJ
	If Empty(CEX->CEX_CNPJ)
		Aadd( aLogErro, {"CEX_CNPJ", "000001", "CEX", nRecno }) //000001 - Campo Inconsistente ou Vazio
	Else 
		If !CGC(CEX->CEX_CNPJ,,.F.)
			Aadd( aLogErro, {"CEX_CNPJ", "000006", "CEX", nRecno }) //000006 - "CPF/CNPJ inconsistente." 
		EndIf	
	EndIf
	
	//Valida o nome da empresarial da fonte pagadora
	If Empty(CEX->CEX_NOMEMP)
		Aadd( aLogErro, {"CEX_NOMEMP", "000001", "CEX", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida o orgão público
	If Empty(CEX->CEX_ORGPUB)
		Aadd( aLogErro, {"CEX_ORGPUB", "000001", "CEX", nRecno }) //000001 - Campo Inconsistente ou Vazio	
	ElseIf !CEX->CEX_ORGPUB $ ('1|2')
		Aadd( aLogErro, {"CEX_ORGPUB", "000002", "CEX", nRecno }) //000002 - Conteúdo do campo não condiz com as opções possiveis.
	EndIf
	
	//Valida o código da receita
	If Empty(CEX->CEX_IDREC)
		Aadd( aLogErro, {"CEX_CODREC", "000001", "CEX", nRecno }) //000001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CEX->CEX_IDREC
		xVldECFTab("CW9",cChave,1,,@aLogErro,{"CEX","CEX_CODREC",nRecno })
    EndIf		
    
    //Valida o rendimento bruto/receita
    If Empty(CEX->CEX_RENDIM)
		Aadd( aLogErro, {"CEX_RENDIM", "000001", "CEX", nRecno }) //000001 - Campo Inconsistente ou Vazio
	EndIf
	
	//REGRA_COD_REC_IR_RET
	If cCODREC $ ('5928|5936|5944|6147|6175|6188|6190|6256|8739|8767|8850|' + ;
	              '8863|9060|9997|0916|0924|1708|3277|3426|5204|5232|5273|' + ;
	              '5557|5706|5928|5936|5944|6800|6813|8045|8468|9385|9999') .And. ;
       Empty(CEX->CEX_IRRET)

		Aadd( aLogErro, {"CEX_CODREC", "000166", "CEX", nRecno }) //STR0166 - "O campo 'IR.Ret.Fonte' deve ser preenchido quando o valor do campo 'Cod.Receita' for igual a 5928 ou 5936 ou 5944 ou 6147 ou 6175 ou 6188 ou 6190 ou 6256 ou 8739 ou 8767 ou 8850 ou 8863 ou 9060 ou 9997 ou 0916 ou 0924 ou 1708 ou 3277 ou 3426 ou 5204 ou 5232 ou 5273 ou 5557 ou 5706 ou 5928 ou 5936 ou 5944 ou 6800 ou 6813 ou 8045 ou 8468 ou 9385 ou 9999."
	EndIf

	//REGRA_COD_REC_CSLL_RET
	If cCODREC $ ('4085|4397|5928|5936|5944|6147|6175|6188|6190|6228|' + ;
	              '8739|8767|8850|8863|9060|9997|5952|5987|9998') .And. ;
	   Empty(CEX->CEX_CSLLRE)
		
		Aadd( aLogErro, {"CEX_CODREC", "000167", "CEX", nRecno }) //STR0167 - "O campo 'CSLL.Ret.Fon' deve ser preenchido quando o valor do campo 'Cod.Receita' for igual a 4085 ou 4397 ou 5928 ou 5936 ou 5944 ou 6147 ou 6175 ou 6188 ou 6190 ou 6228 ou 8739 ou 8767 ou 8850 ou 8863 ou 9060 ou 9997 ou 5952 ou 5987 ou 9998."
	EndIf

	//REGRA_COD_REC_ORG_PUB (REGRA_COD_REC_ORP_PUB)
	If CEX->CEX_ORGPUB == "1" .And. ;
	   !cCODREC $ ('4085|4397|5928|5936|5944|6147|6175|6188|' + ;
	               '6190|6228|6256|8739|8767|8850|8863|9060|9997')
		
		Aadd( aLogErro, {"CEX_CODREC", "000164", "CEX", nRecno }) //STR0164 - "Quando o campo 'Org.Pub' for igual a 'Sim', o valor do campo 'Cod.Receita' deve ser igual a 4085 ou 4397 ou 5928 ou 5936 ou 5944 ou 6147 ou 6175 ou 6188 ou 6190 ou 6228 ou 6256 ou 8739 ou 8767 ou 8850 ou 8863 ou 9060 ou 9997."
	EndIf

	//REGRA_COD_REC_ORG_PUB_NAO (REGRA_COD_REC_ORP_PUB_NAO)
	If CEX->CEX_ORGPUB == "2" .And. ;
	   !cCODREC $ ('0916|0924|1708|3277|3426|5204|5232|5273|5557|5706|5928|' + ;
	               '5936|5944|5952|5987|6800|6813|8045|8468|9385|9998|9999')
		
		Aadd( aLogErro, {"CEX_CODREC", "000165", "CEX", nRecno }) //STR0165 - "Quando o campo 'Org.Pub' for igual a 'Não', o valor do campo 'Cod.Receita' deve ser igual a 0916 ou 0924 ou 1708 ou 3277 ou 3426 ou 5204 ou 5232 ou 5273 ou 5557 ou 5706 ou 5928 ou 5936 ou 5944 ou 5952 ou 5987 ou 6800 ou 6813 ou 8045 ou 8468 ou 9385 ou 9998 ou 9999."
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("CEX",.F.)
		CEX->CEX_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CEX",.F.)
		CEX->CEX_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CEX_ID","000017", "CEX", nRecno })//Registro já validado
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)