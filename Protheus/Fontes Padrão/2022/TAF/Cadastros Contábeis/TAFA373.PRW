#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA373.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA373
Cadastro MVC de Demonstrativo das Diferenças na Adoção Inicial

@author Denis R de Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA373()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Demonstrativo das Diferenças na Adoção Inicial"
oBrw:SetAlias( 'CHF')
oBrw:SetMenuDef( 'TAFA373' )
CHF->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF373Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA373" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCHF := FWFormStruct( 1, 'CHF' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA373' , , , {|oModel| SaveModel( oModel ) } )  


lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCHF:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CHF' , /*cOwner*/, oStruCHF) 

//Define a chave única de gravação das informações
oModel:GetModel('MODEL_CHF'):SetPrimaryKey( { 'CHF_PERIOD','CHF_CODCTA','CHF_CODCUS'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 26/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA373' )
Local oStruCHF:= 	FWFormStruct( 2, 'CHF' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel ) 

oStruCHF:RemoveField('CHF_ID')
                                       
oView:AddField('VIEW_CHF' , oStruCHF,  'MODEL_CHF' ) 
oView:EnableTitleView( 'VIEW_CHF', STR0001 ) //"Demonstrativo das Diferenças na Adoção Inicial" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
If TamSX3("CHF_CODCTA")[1] == 36
	oStruCHF:RemoveField( "CHF_CODCTA")
	oStruCHF:SetProperty( "CHF_CTACTB", MVC_VIEW_ORDEM, "04" )
EndIf
oView:SetOwnerView( 'VIEW_CHF', 'PAINEL_PRINCIPAL' )   

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R de Oliveira
@since 26/11/2014
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
		TAFAltStat( "CHF", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF373Vld

@author Denis R de Oliveira
@since 26/11/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF373Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local nVLSDSC		:= CHF->CHF_VLSDSC
Local nVLSDFI		:= CHF->CHF_VLSDFIadmin	
Local nVLDFSD   	:= CHF->CHF_VLDFSD
Local cAnoCal		:= ""

Default lJob := .F.

If CHF->CHF_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento    
	If Empty(CHF->CHF_PERIOD)
		Aadd( aLogErro, {"CHF_PERIOD", "000001", "CHF", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
		
	//Valida o Código da Conta
	If Empty(CHF->CHF_CODCTA)
		Aadd( aLogErro, {"CHF_CODCTA", "000001", "CHF", nRecno }) //STR0001 - Campo Inconsistente ou Vazio
    Else
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CHF->CHF_CODCTA
		xVldECFTab("C1O",cChave,3,,@aLogErro,{"CHF","CHF_CODCTA",nRecno })
    EndIf
    
    //Valida o Saldo Societário 
	If nVLSDSC < 0
		Aadd( aLogErro, {"CHF_VLSDSC", "000132", "CHF", nRecno }) //STR0132 - "O campo Valor do Saldo Societário da Conta não pode ser negativo."
	EndIF
	
	//Valida o Saldo Fiscal
	If nVLSDFI	 < 0
		Aadd( aLogErro, {"CHF_VLSDFI", "000133", "CHF", nRecno }) //STR0133 - "O campo Valor do Saldo Fiscal da Conta não pode ser negativo."
	EndIF
	
	//Valida o Indicador do Valor do Saldo Societário
	If ! Empty(CHF->CHF_INDSOC)
		If !CHF->CHF_INDSOC $ ('1|2')
			Aadd( aLogErro, {"CHF_INDSOC", "000002", "CHF", nRecno }) //STR0002 - Conteúdo do campo não condiz com as opções possiveis.
		Else
			If CHF->CHF_INDSOC == "1" 
				nVLSDSC:= nVLSDSC * -1
			EndIf
		EndIf
	EndIf 
	  
    
	//Valida o Indicador do Valor do Saldo Fiscal
	If ! Empty(CHF->CHF_INDFIS)	
		If !CHF->CHF_INDFIS $ ('1|2')
			Aadd( aLogErro, {"CHF_INDFIS", "000002", "CHF", nRecno }) //STR0002 - Conteúdo do campo não condiz com as opções possiveis.
		Else
			If CHF->CHF_INDFIS == "1"
				nVLSDFI:= nVLSDFI * -1
			EndIf
		EndIf
	EndIf 
	
	//Valida o Indicador da Diferença de Saldos
	If ! Empty(CHF->CHF_INDDIF)
		If !CHF->CHF_INDDIF $ ('1|2')
			Aadd( aLogErro, {"CHF_INDDIF", "000002", "CHF", nRecno }) //STR0002 - Conteúdo do campo não condiz com as opções possiveis.
		Else 
			If CHF->CHF_INDDIF == "1"
				nVLDFSD:= nVLDFSD * -1
			EndIf
		EndIf
	Endif
		
	//Valida o Indicador da Diferença de Saldos
	If Empty(CHF->CHF_MTDCTL)
		Aadd( aLogErro, {"CHF_MTDCTL", "000001", "CHF", nRecno }) //STR0001 - Campo Inconsistente ou Vazio	
	ElseIf !CHF->CHF_MTDCTL $ ('1|2|3|4|5')
		Aadd( aLogErro, {"CHF_MTDCTL", "000002", "CHF", nRecno }) //STR0002 - Conteúdo do campo não condiz com as opções possiveis.
	EndIf
	
    //Valida o Código do Centro de Custos da Subconta
	If ! Empty(CHF->CHF_CCUSUB)
    	//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := CHF->CHF_CCUSUB
		xVldECFTab("C1P",cChave,3,,@aLogErro,{"CHF","CHF_CCUSUB",nRecno })
    EndIf
    
	/*--------------------------------------*
	 | Validações conforme Layout Dez/14    |%
	 | Responsável: Evandro dos S. Oliveira |
	 | Data: 09/02/2014					     |
	 *--------------------------------------*/     
    
    cAnoCal := AllTrim(DTOS(CHF->CHF_PERIOD))
    cAnoCal := Substr(cAnoCal,1,4)  
    
    /*REGRA_CCUS_Y665*/
	If !Empty(cAnoCal)

		cChave := CHF->CHF_CODCUS
		If Val(cAnoCal) >= 2015 //Estou admitindo que a regra valerá para os anos acima de 2015, por que o Manual não diz explícitamente isso.
			If ! Empty(CHF->CHF_CODCUS)
				xVldECFTab("C1P",cChave,3,,@aLogErro,{"CHF","CHF_CODCUS",nRecno })
		    EndIf
		EndIf

	EndIf
	
	/*REGRA_Y665_DIF_SALDOS - Retirado pois o Manual se contradiz a respeito do campo DIF_SALDOS*/
/*	If (CHF->CHF_VLSDSC + CHF->CHF_VLSDFI) <> CHF->CHF_VLDFSD
		Aadd( aLogErro, {"CHF_VLDFSD", "000199", "CHF", nRecno })	// STR0199	- A Soma dos Campos 'Título Vlr S' e 'Vlr Sld Fis' deve ser igual ao campo 'Vlr Dif Sld'
	EndIf*/
	
	/*REGRA_MET_CONTR_OBRIG*/
	If CHF->CHF_MTDCTL $ '12' .And. Empty(CHF->CHF_CODSUB)
		Aadd( aLogErro, {"CHF_CODSUB", "000200", "CHF", nRecno })  // STR0200 - 'O campo "Cod SubConta" deve ser preenchido quando "Método Ctl" for igual a 1-Contr.subcta ou 2-Contr.subct,3º/4º art. 11'	
	EndIf
	
	/*REGRA_MET_CONTR_NAO_PREENCH*/
	If CHF->CHF_MTDCTL $ '34' 
		If !Empty(CHF->CHF_CODSUB)
			Aadd( aLogErro, {"CHF_CODSUB", "000201", "CHF", nRecno }) // STR0201 - 'O campo "Cod SubConta" não deve ser preenchido quando "Método Ctl" for igual a 3-Não contr. subcta, 5º art. 11 ou 4-Não contr. subconta-s/ ajustes'
		EndIf
		
		If !Empty(CHF->CHF_CCUSUB)
			Aadd( aLogErro, {"CHF_CCUSUB", "000202", "CHF", nRecno }) // STR0202 - 'O campo "C Custo Sub" não deve ser preenchido quando "Método Ctl" for igual a 3-Não contr. subcta, 5º art. 11 ou 4-Não contr. subconta-s/ ajustes'
		EndIf
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
		RecLock("CHF",.F.)
		CHF->CHF_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CHF",.F.)
		CHF->CHF_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CHF_ID","000017", "CHF", nRecno })//Registro já validado
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)