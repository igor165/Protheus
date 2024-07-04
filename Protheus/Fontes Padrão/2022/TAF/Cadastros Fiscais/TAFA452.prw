#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA452.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA452
Sped Fiscal Registro Insumos

@author Vitor Henrique
@since 01/08/2015
@version 1.0

/*/ 
//------------------------------------------------------------------
Function TAFA452(lCalled)
Local oBrw := FWmBrowse():New()
Default lCalled := .F.

	If TAFAlsInDic( "LEZ" )
		oBrw:SetDescription(STR0003) //"Insumos"
		oBrw:SetAlias('LEZ')
		oBrw:SetMenuDef( 'TAFA452' )
		If lCalled
			oBrw:SetFilterDefault( "LEZ_CODPRO == '" + C1L->C1L_ID + "'" )
		EndIf
		oBrw:Activate()
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf452Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA452" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT25 := FWFormStruct( 1, 'T25' )
Local oStruLEZ := FWFormStruct( 1, 'LEZ' )
Local oModel   := MPFormModel():New( 'TAFA452' , , , {|oModel| SaveModel(oModel)})

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruLEZ:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_LEZ', /*cOwner*/, oStruLEZ)

oModel:AddGrid("MODEL_T25","MODEL_LEZ",oStruT25)
oModel:GetModel("MODEL_T25"):SetUniqueLine({"T25_IDINSU"})

oModel:GetModel('MODEL_LEZ'):SetPrimaryKey({"LEZ_CODPRO","LEZ_DTINI", "LEZ_DTFIN"})
oModel:SetRelation("MODEL_T25",{ {"T25_FILIAL","xFilial('T25')"}, {"T25_ID","LEZ_ID"} },T25->(IndexKey(1)) )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'TAFA452' )
Local oStruT25 := FWFormStruct( 2, 'T25' )
Local oStruLEZ := FWFormStruct( 2, 'LEZ' )
Local oView    := FWFormView():New()

/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel )


oView:AddField("VIEW_LEZ",oStruLEZ,"MODEL_LEZ")
oView:EnableTitleView("VIEW_LEZ",STR0002) 

oView:AddGrid("VIEW_T25",oStruT25,"MODEL_T25")
oView:EnableTitleView("VIEW_T25",STR0001) 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",28)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") //LEZ

oView:CreateHorizontalBox("PAINEL_INFERIOR",72)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")  


/*-----------------------------------------------------------------------------------
Amarração para exibição das informações
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_LEZ', 'PAINEL_PRINCIPAL' ) 
oView:SetOwnerView( 'VIEW_T25', 'PAINEL_INFERIOR' )


/*-----------------------------------------------------------------------------------
Remove campos da tela
-------------------------------------------------------------------------------------*/
oStruLEZ:RemoveField('LEZ_ID')

If TamSX3("LEZ_CODPRO")[1] == 36
	oStruLEZ:RemoveField("LEZ_CODPRO")
	oStruLEZ:SetProperty("LEZ_PRODTO", 	MVC_VIEW_ORDEM, "03")
EndIf    

If TamSX3("T25_IDINSU")[1] == 36
	oStruT25:RemoveField("T25_IDINSU")
	oStruT25:SetProperty("T25_INSUMO", 	MVC_VIEW_ORDEM, "03")
EndIf
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Vitor Henrique
@Since 01/08/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )                              
Local nOperation := oModel:GetOperation()
Local lRet := .F.

Begin Transaction
	If nOperation == MODEL_OPERATION_INSERT
		
		If Taf452Dt(M->LEZ_CODPRO, DTos(M->LEZ_DTINI), DTos(M->LEZ_DTFIN), .F.)
			FwFormCommit( oModel )
			lRet := .T.
		Else
			oModel:SetErrorMessage (,,,,,"Erro",STR0004) //	Já existe um registro para esse produto que compreende a Data Inicial e Data Final.			
		EndIf
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
	
		If Taf452Dt(M->LEZ_CODPRO, DTos(M->LEZ_DTINI), DTos(M->LEZ_DTFIN), .T.)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao responsavel por setar o Status do registro para Branco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TAFAltStat( "LEZ", " " )
			
			FwFormCommit( oModel )
			
			lRet := .T.
		Else
			oModel:SetErrorMessage (,,,,,"Erro",STR0004) //	Já existe um registro para esse produto que compreende a Data Inicial e Data Final.	
		EndIf
	
	ElseIf nOperation == MODEL_OPERATION_DELETE
		FwFormCommit( oModel )	
		lRet := .T.
	EndIf

End Transaction

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf452Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf452Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro		:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local cIdTipo       := ""
Local cCodTipo      := ""
Local cUniItemD  	:= ""
Local cUniItemO		:= ""
Local lFound		:= .F. 
                
Default lJob := .F. 

	//TRATAMENTO PARA DICIONARIO DESATUALIZADO(12.1.8)
	If TAFAlsInDic("T25") .AND. TAFAlsInDic("LEZ")
		
		If !Taf452Dt(LEZ->LEZ_CODPRO, DTos(LEZ->LEZ_DTINI), DTos(LEZ->LEZ_DTFIN), .T.)
			AADD(aLogErro,{"LEZ_CODPRO","000911","LEZ",nRecno}) //STR0911 - "Já existe um registro para esse produto que compreende a Data Inicial e Data Final."
		EndIf
	
		/*----------------------------------------------------------
				Validações do Registro 0210
		----------------------------------------------------------*/
			
			("T25")->( DbSetOrder( 1 ) )
			("T25")->( DbSeek ( xFilial("T25")+LEZ->LEZ_ID) )
				
			//Laço para geração dos registros filhos
			While T25->(!Eof()) .And. (alltrim(xFilial("T25")+T25->T25_ID) == alltrim(xFilial("LEZ")+LEZ->LEZ_ID))
				
				If T25->T25_IDINSU == LEZ->LEZ_CODPRO					
					AADD(aLogErro,{"T25_IDINSU","000909","LEZ",nRecno}) //STR0909 - "O código do produto deve ser diferente do código de insumo."	
				EndIf
				
				cIdTipo  := POSICIONE("C1L",3, xFilial("C1L")+T25->T25_IDINSU ,"C1L_TIPITE")
				cCodTipo := POSICIONE("C2M",3, xFilial("C2M")+cIdTipo ,"C2M_CODIGO")
					
				If !(cCodTipo $ ('00|01|02|03|04|05|10'))					
					AADD(aLogErro,{"T25_IDINSU","000677","LEZ",nRecno}) //STR0677 - "Somente podem ser informados nesse campo itens cujos seus tipos sejam iguais a 00, 01, 02, 03, 04, 05 e 10."	
				EndIf
				
				T25->( dbSkip() )
			EndDo
	EndIf
	
	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")

	If RecLock("LEZ",.F.)
		LEZ->LEZ_STATUS := cStatus
		LEZ->(MsUnlock())
	EndIf
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Não apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro) 

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf452Rel

Funcao que retorna o relac para o inicializador do browser

@return cValor - Valor para preencher campo de relac na sx3

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf452Rel()
Local cValor := ""

cValor	:=	POSICIONE("C1L",3, xFilial("C1L")+LEZ->LEZ_CODPRO, "Alltrim(C1L_CODIGO)+ ' - ' + Alltrim(C1L_DESCRI)")

Return cValor
//-------------------------------------------------------------------
/*/{Protheus.doc} Taf452Dt

Funcao que valida se data que compoe a chave da tabela esta certa. A validação é dividida em quatro tipos de validação.

@param cIdProd - Id do Produto
@param dDtIni - Data Inicial
@param dDtFin - Data Final
@param lJob3  - Verifica se function foi chamada por job3 ou pelo valid do campo

@return lVld - Retorno se as datas da chave são validas ou não.

@author Vitor Henrique
@since 01/08/2015
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function Taf452Dt(cIdProd, dDtIni, dDtFin, lJob3)
Local lVld 			:= .F.
Local cQuery		:= ""
Local cQuery2		:= ""
Local cQuery3		:= ""
Local cQuery4		:= ""
Local cQuery5		:= ""
Local cQuery6		:= ""
Local cAliasQ   	:= GetNextAlias()
Local cAliasQ2   	:= GetNextAlias()
Local cAliasQ3   	:= GetNextAlias()
Local cAliasQ4   	:= GetNextAlias()
Local cAliasQ5  	:= GetNextAlias()
Local cAliasQ6  	:= GetNextAlias()
	
	
	If !Empty(cIdProd) .AND. !Empty(dDtIni) 
	
		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³PARTE 1³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		
		//Query para a validação de Datas dentre dt. inicial e dt. final
		cQuery += " SELECT COUNT(*) QTD "
		cQuery += " FROM " + RetSqlName('LEZ') +" LEZ "
		cQuery += " WHERE LEZ_CODPRO = '" + cIdProd + "' "
		If !Empty(dDtFin)
			cQuery += " AND LEZ_DTINI >= '" + dDtIni + "' "
			cQuery += " AND LEZ_DTFIN <= '"   + dDtFin + "' "
			cQuery += " AND LEZ_DTFIN <> ''"   
		Else
			cQuery += " AND (LEZ_DTFIN >=  '" + dDtIni + "' "
			cQuery += " OR LEZ_DTFIN = '')"   
		EndIf
		
		If lJob3
			cQuery += " AND LEZ_ID <> '" + LEZ->LEZ_ID + "' "	
		EndIf
		
		cQuery += " AND LEZ.D_E_L_E_T_ = ' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQ, .F., .T. )
		
		If (cAliasQ)->QTD == 0
			lVld := .T.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³PARTE 2³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		If lVld .AND. !Empty(dDtFin)
		
			//Query para a validação de DTINI e DTFIN fora dos parametros de busca
			cQuery2 += " SELECT COUNT(*) QTD "
			cQuery2 += " FROM " + RetSqlName('LEZ') +" LEZ "
			cQuery2 += " WHERE LEZ_CODPRO = '" + cIdProd + "' "
			cQuery2 += " AND LEZ_DTINI <= '" + dDtIni + "' "
			If !Empty(dDtFin)
				cQuery2 += " AND LEZ_DTFIN >= '"   + dDtFin + "' "
			EndIf
			
			If lJob3
				cQuery2 += " AND LEZ_ID <> '" + LEZ->LEZ_ID + "' "
			EndIf	
			
			cQuery2 += " AND LEZ.D_E_L_E_T_ = ' ' "
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ) , cAliasQ2, .F., .T. )
			
			If (cAliasQ2)->QTD == 0
				lVld := .T.
			Else
				lVld := .F.
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄ¿
			//³PARTE 3³
			//ÀÄÄÄÄÄÄÄÄÄÙ	
			If lVld 
			
				//Query para a validação de DTFIN fora da busca e DTINI dentro dos parametros de busca
				cQuery3 += " SELECT COUNT(*) QTD "
				cQuery3 += " FROM " + RetSqlName('LEZ') +" LEZ "
				cQuery3 += " WHERE LEZ_CODPRO = '" + cIdProd + "' "
				cQuery3 += " AND LEZ_DTINI BETWEEN '"   + dDtIni  + "' "
				cQuery3 += " AND '"   + dDtFin  + "' "	
				cQuery3 += " AND LEZ_DTFIN not BETWEEN '"   + dDtIni  + "' "
				cQuery3 += " AND '"   + dDtFin  + "' "	
				
				If lJob3
					cQuery3 += " AND LEZ_ID <> '" + LEZ->LEZ_ID + "' "
				EndIf
				
				cQuery3 += " AND LEZ.D_E_L_E_T_ = ' ' "
				
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery3 ) , cAliasQ3, .F., .T. )
				
				If (cAliasQ3)->QTD == 0
					lVld := .T.
				Else
					lVld := .F.
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄ¿
				//³PARTE 4³
				//ÀÄÄÄÄÄÄÄÄÄÙ	
				If lVld 
				
					//Query para a validação de DTINI fora da busca e DTFIN dentro dos parametros de busca
					cQuery4 += " SELECT COUNT(*) QTD "
					cQuery4 += " FROM " + RetSqlName('LEZ') +" LEZ "
					cQuery4 += " WHERE LEZ_CODPRO = '" + cIdProd + "' "
					cQuery4 += " AND LEZ_DTINI not BETWEEN '"   + dDtIni  + "' "
					cQuery4 += " AND '"   + dDtFin  + "' "	
					cQuery4 += " AND LEZ_DTFIN BETWEEN '"   + dDtIni  + "' "
					cQuery4 += " AND '"   + dDtFin  + "' "	
					
					If lJob3
						cQuery4 += " AND LEZ_ID <> '" + LEZ->LEZ_ID + "' "
					EndIf
					
					cQuery4 += " AND LEZ.D_E_L_E_T_ = ' ' "
					
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery4 ) , cAliasQ4, .F., .T. )
					
					If (cAliasQ4)->QTD == 0
						lVld := .T.
					Else
						lVld := .F.
					EndIf
					
					
					//ÚÄÄÄÄÄÄÄÄÄ¿
					//³PARTE 5³
					//ÀÄÄÄÄÄÄÄÄÄÙ				
					If lVld 
					
						//Query para a validação de DTFIN em branco e DTINI maior que o parametro de data inicial
						cQuery5 += " SELECT COUNT(*) QTD "
						cQuery5 += " FROM " + RetSqlName('LEZ') +" LEZ "
						cQuery5 += " WHERE LEZ_CODPRO = '" + cIdProd + "' "
						cQuery5 += " AND LEZ_DTINI <= '"   + dDtIni  + "' "
						cQuery5 += " AND LEZ_DTFIN = '' "  
						
						If lJob3
							cQuery5 += " AND LEZ_ID <> '" + LEZ->LEZ_ID + "' "
						EndIf
						
						cQuery5 += " AND LEZ.D_E_L_E_T_ = ' ' "
						
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery5 ) , cAliasQ5, .F., .T. )
						
						If (cAliasQ5)->QTD == 0
							lVld := .T.
						Else
							lVld := .F.
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄ¿
					//³PARTE 6³
					//ÀÄÄÄÄÄÄÄÄÄÙ			
					If lVld 
					
						//Query para a validação de DTFIN em branco e DTINI menor que o parametro de data inicial
						cQuery6 += " SELECT COUNT(*) QTD "
						cQuery6 += " FROM " + RetSqlName('LEZ') +" LEZ "
						cQuery6 += " WHERE LEZ_CODPRO = '" + cIdProd + "' "
						cQuery6 += " AND LEZ_DTINI <= '"   + dDtFin  + "' "
						cQuery6 += " AND LEZ_DTFIN = '' "  
						
						If lJob3
							cQuery6 += " AND LEZ_ID <> '" + LEZ->LEZ_ID + "' "
						EndIf
						
						cQuery6 += " AND LEZ.D_E_L_E_T_ = ' ' "
						
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery6 ) , cAliasQ6, .F., .T. )
						
						If (cAliasQ6)->QTD == 0
							lVld := .T.
						Else
							lVld := .F.
						EndIf
					EndIf
					
				EndIf
			EndIf
		EndIf
	
		DbCloseArea(cAliasQ)
		DbCloseArea(cAliasQ2)
		DbCloseArea(cAliasQ3)
		DbCloseArea(cAliasQ4)
		DbCloseArea(cAliasQ5)
		DbCloseArea(cAliasQ6)
	Else
		lVld := .T.
	EndIf

Return lVld 
