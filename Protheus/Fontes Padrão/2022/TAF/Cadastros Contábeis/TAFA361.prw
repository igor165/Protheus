#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE 'TAFA361.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} TAFA361   

Cadastro Identificação dos Períodos e Formas de Apuração do IRPJ e 
da CSLL no Ano-Calendário


@author Evandro dos Santos Oliveira	
@since 30/05/2014
@version 1.0

*/
//-------------------------------------------------------------------
Function TAFA361()

	Local oBrw := FWmBrowse():New()
	
	oBrw:SetDescription(STR0009) //"Bloco L - Lucro Líquido"
	oBrw:SetAlias("CAP")
	oBrw:SetMenuDef("TAFA361")
	CAP->(DbSetOrder(2))
	oBrw:Activate()

Return Nil 

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef                

Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 30/05/2014
@version 1.0
*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {}
Local aFuncao := {{ "" , "TAF361Vld" , "2" }}

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA361' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA361" , , aFuncao)
EndIf

Return( aRotina )      

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Evandro dos Santos Oliveira
@since 30/05/2014
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()
	
	Local 	oStruCAP 	:= FWFormStruct( 1, 'CAP' )
	Local 	oStruCAQ 	:= FWFormStruct( 1, 'CAQ' )
	Local 	oStruCAR 	:= FWFormStruct( 1, 'CAR' )  
	Local 	oStruCAS 	:= FWFormStruct( 1, 'CAS' )  
	Local 	oStruCAT 	:= FWFormStruct( 1, 'CAT' ) 
	Local	oModel		:= Nil 
	Local   lVldModel
	
	oModel := MPFormModel():New('TAFA361',,,{|oModel|SaveModel(oModel)})
		
	lVldModel := IIf(Type("lVldModel") == "U",.F.,lVldModel)

	If lVldModel
		oStruCAP:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
	EndIf

	oModel:AddFields('MODEL_CAP', /*cOwner*/, oStruCAP )
	oModel:GetModel('MODEL_CAP'):SetPrimaryKey({"CAP_DTINI","CAP_DTFIN","CAP_IDPERA"})

	
	oModel:AddGrid( 'MODEL_CAQ', 'MODEL_CAP', oStruCAQ,,,,, { |oMdlG| LoadGrid(oMdlG, 'CAQ') } )
	oModel:GetModel('MODEL_CAQ'):SetOptional(.T.)
	oModel:GetModel('MODEL_CAQ'):SetUniqueLine({'CAQ_IDCODC'})
	
	
	oModel:AddGrid('MODEL_CAR','MODEL_CAP',oStruCAR)
	oModel:GetModel('MODEL_CAR'):SetOptional(.T.)
	oModel:GetModel('MODEL_CAR'):SetUniqueLine({'CAR_INDAVA'})
	oModel:GetModel('MODEL_CAR'):SetNoInsertLine(.T.)
	
	oModel:AddGrid('MODEL_CAS','MODEL_CAP',oStruCAS)
	oModel:GetModel('MODEL_CAS'):SetOptional(.T.)
	oModel:GetModel('MODEL_CAS'):SetUniqueLine({'CAS_IDCODC'})

	oModel:AddGrid( 'MODEL_CAT', 'MODEL_CAP', oStruCAT, ,,,, { |oMdlG| LoadGrid(oMdlG, 'CAT') } )
	oModel:GetModel('MODEL_CAT'):SetOptional(.T.)
	oModel:GetModel('MODEL_CAT'):SetUniqueLine({'CAT_IDCODC'})

	oModel:SetRelation( 'MODEL_CAQ', { { 'CAQ_FILIAL', 'xFilial( "CAQ" )' } , { 'CAQ_ID' , "CAP_ID" } }, CAQ->( IndexKey( 1 ) ) ) 
	oModel:SetRelation( 'MODEL_CAR', { { 'CAR_FILIAL', 'xFilial( "CAR" )' } , { 'CAR_ID' , "CAP_ID" } }, CAR->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'MODEL_CAS', { { 'CAS_FILIAL', 'xFilial( "CAS" )' } , { 'CAS_ID' , "CAP_ID" } }, CAS->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'MODEL_CAT', { { 'CAT_FILIAL', 'xFilial( "CAT" )' } , { 'CAT_ID' , "CAP_ID" } }, CAT->( IndexKey( 1 ) ) )
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc}  LoadGrid
Funcao que carrega as informações e ordena a grid

@author Vitor Henrique
@since 25/09/2015
@version 1.0

/*/
//-------------------------------------------------------------------   
Static Function LoadGrid(oGrid, cAlias)
	Local aRet        := {}
	Local cQuery      := ''  
	Local cAliasQuery := GetNextAlias()
	Local aArea       := GetArea()
		
	If cAlias == 'CAQ'
		cQuery += " SELECT distinct CAQ.CAQ_FILIAL, CAQ.CAQ_ID, CAQ.CAQ_IDCODC, CAQ.CAQ_REGECF, CHA.CHA_CODIGO CAQ_CODCTA, CHA.CHA_DESCRI CAQ_DCODCT, CAQ.CAQ_SALINI, CAQ.CAQ_INDINI "
		
		If TAFColumnPos("CAQ_VLRTD")
			cQuery += ", CAQ.CAQ_VLRTD, CAQ.CAQ_VLRTC "
		EndIF

		cQuery += ", CAQ.CAQ_SALFIN, CAQ.CAQ_INDFIN ,CAQ.R_E_C_N_O_ R_E_C_N_O_ "
		cQuery += " FROM " + RetSqlName('CAQ') +" CAQ"
		cQuery += " LEFT JOIN " + RetSqlName('CHA') + " CHA "
		cQuery += " ON CHA.CHA_ID = CAQ.CAQ_IDCODC"
		cQuery += " WHERE CAQ.CAQ_FILIAL = '" + xFilial('CAQ') + "' "
		cQuery += " AND CAQ.CAQ_ID = '" + CAP->CAP_ID + "' "
		cQuery += " AND CAQ.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY CHA.CHA_CODIGO "
			
		
	ElseIf cAlias == 'CAT'
	
		cQuery += " SELECT DISTINCT CAT.CAT_FILIAL, CAT.CAT_ID, CAT.CAT_IDCODC, CAT.CAT_REGECF, CHA.CHA_CODIGO CAT_CODCTA, CHA.CHA_DESCRI CAT_DCODCT, CAT.CAT_SALFIN, CAT.CAT_INDFIN, CAT.R_E_C_N_O_  R_E_C_N_O_  "
		cQuery += " FROM " + RetSqlName('CAT') +" CAT"
		cQuery += " LEFT JOIN " + RetSqlName('CHA') + " CHA "
		cQuery += " ON CHA.CHA_ID = CAT.CAT_IDCODC"
		cQuery += " WHERE CAT.CAT_FILIAL = '" + xFilial('CAT') + "' "
		cQuery += " AND CAT.CAT_ID = '" + CAP->CAP_ID + "' "
		cQuery += " AND CAT.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY CHA.CHA_CODIGO "		
			
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQuery, .F., .T. )
	
	aRet := FWLoadByAlias( oGrid, cAliasQuery, cAlias )
	(cAlias)->(DBGoto(0))


	(cAliasQuery)->(DbCloseArea())
	RestArea(aArea)
Return aRet

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira
@since 02/06/2014
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel		:= FWLoadModel( 'TAFA361' )
	Local oStruCAP  	:= FWFormStruct( 2, 'CAP' )
	Local oStruCAQ  	:= FWFormStruct( 2, 'CAQ' )
	Local oStruCAR  	:= FWFormStruct( 2, 'CAR' )  
	Local oStruCAS  	:= FWFormStruct( 2, 'CAS' )  
	Local oStruCAT  	:= FWFormStruct( 2, 'CAT' ) 
	Local oView      	:= FWFormView():New()
	
	oView:SetModel(oModel)
	
	oStruCAP:RemoveField('CAP_ID')
	oStruCAP:RemoveField('CAP_IDPERA')
	oStruCAQ:RemoveField('CAQ_IDCODC')
	oStruCAS:RemoveField('CAS_IDCODC')
	oStruCAT:Removefield("CAT_IDCODC")
	oView:AddField( 'VIEW_CAP', oStruCAP, 'MODEL_CAP' )

	oView:AddGrid ( 'VIEW_CAQ', oStruCAQ, 'MODEL_CAQ' )
	oView:AddGrid ( 'VIEW_CAR', oStruCAR, 'MODEL_CAR' )
	oView:AddGrid ( 'VIEW_CAS', oStruCAS, 'MODEL_CAS' )
	//oView:EnableTitleView("VIEW_CAS",STR0004) 				//"Informativo da Composição de Custos"
	oView:AddGrid ( 'VIEW_CAT', oStruCAT, 'MODEL_CAT' )
	
	oView:CreateHorizontalBox('FIELDSCAP'		,020)
	oView:CreateHorizontalBox('PANFOLDER1' 	,080)

	oView:CreateFolder('FOLDER1','PANFOLDER1')
	
	oView:AddSheet('FOLDER1'	, 'ABA01'	, STR0002 )   					//"Balanço Patrimonial"
	oView:CreateHorizontalBox( 'GRIDCAQ', 100,,,'FOLDER1', 'ABA01' )
	
	oView:AddSheet('FOLDER1'	, 'ABA02'	, STR0003 )    					//"Método de Avaliação do Estoque Final" 
	oView:CreateVerticalBox( 'GRIDCAR', 050,,,'FOLDER1', 'ABA02' )
	oView:CreateVerticalBox( 'GRIDCAS', 050,,,'FOLDER1', 'ABA02' )	
	
	oView:AddSheet('FOLDER1'	, 'ABA03'	, STR0005 )  					//"Demonstração do Resultado Líquido no Período Fiscal"
	oView:CreateHorizontalBox( 'GRIDCAT', 100,,,'FOLDER1', 'ABA03' )
	
	oView:SetOwnerView("VIEW_CAP","FIELDSCAP")
	oView:SetOwnerView("VIEW_CAQ","GRIDCAQ")
	oView:SetOwnerView("VIEW_CAR","GRIDCAR")
	oView:SetOwnerView("VIEW_CAS","GRIDCAS")
	oView:SetOwnerView("VIEW_CAT","GRIDCAT")

	oStruCAQ:SetProperty( "CAQ_SALFIN", MVC_VIEW_ORDEM, "13" )
	oStruCAQ:SetProperty( "CAQ_INDFIN", MVC_VIEW_ORDEM, "14" )
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.


@author Evandro dos Santos Oliveira
@since 04/06/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local nOperation := oModel:GetOperation()
	
	CAQ->( dbGoTop() )
	
	Begin Transaction 
		
		If nOperation == MODEL_OPERATION_UPDATE 
			TAFAltStat( "CAP", " " )
		EndIf  
	
		FwFormCommit( oModel )
				
	End Transaction 
	
Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} TAF361Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Evandro dos Santos Oliveira
@since 03/06/2014
@version 1.0
*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF361Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro		:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local cCAQKey		:= ""
Local cCASKey		:= ""
Local cCATKey		:= ""
Local aAreaCAP 		:= GetArea("CAP")
Local nSALFINA		:=	0
Local nSALFINP		:=	0
Local nSALINIA		:=	0
Local nSALINIP		:=	0
Local nRecCHD			:=	0
Local nIndVen			:= 0 //3.01.01.01.01.02|3.11.01.01.01.02
Local nIndRop			:= 0 //3.01.01.07.01.32|3.11.01.07.01.32
Local nIndPag			:= 0 //3.01.01.05.01.06|3.01.01.05.01.07|3.01.01.05.01.0|3.01.01.05.01.10|3.11.01.05.01.06|3.11.01.05.01.07|3.11.01.05.01.09|3.11.01.05.01.10
Local cIdTpCnt		:= ""
Local cTipCont		:= ""
Local cPerAPur		:= ""
Local cIndVen			:= ""
Local cIndRop			:= ""
Local cIndPag			:= ""
Local cContCHA		:= ""

Default lJob 		:= .F.

If (CAP->CAP_STATUS $ (' |1'))
	
	If !Empty(CAP->CAP_IDPERA)
		cChave := CAP->CAP_IDPERA
		xVldECFTab("CAH",cChave,1,,@aLogErro,{"CAP","CAP_PERAPU", nRecno})
	EndIf

	If CAP->CAP_DTINI > CAP->CAP_DTFIN
		aAdd( aLogErro,{ "CAP_DTFIN", "000033", "CAP", nRecno } ) //STR0033 - "A data de período final dever ser maior ou igual a data de período inicial."
	EndIf
	
	//VALIDA_PERIODO
	xVldECFReg( cAlias,"VALIDA_PERIODO", @aLogErro,{CAP->CAP_DTINI,CAP->CAP_DTFIN,CAP->CAP_IDPERA})
	
	dbSelectArea("CAQ")
	dbSetOrder(1)
		
	cCAQKey:= CAP->CAP_ID
		
	If CAQ->(MsSeek(xFilial("CAQ")+cCAQKey))
		
		Do While !CAQ->( Eof() ) .And. cCAQKey == CAQ->CAQ_ID
				
			If Empty(CAQ->CAQ_IDCODC)
				Aadd(aLogErro,{"CAQ_CODCTA","000001","CAP",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			Else
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CAQ->CAQ_IDCODC
				xVldECFTab("CHA",cChave,1,,@aLogErro,{"CAP","CAQ_CODCTA", nRecno})
			EndIf
			
			If !(CAQ->CAQ_INDFIN $ "1|2")
				aAdd(aLogErro,{"CAQ_INDFIN","000002","CAP", nRecno }) 	//STR0002 "Conteúdo do campo não condiz com as opções possíveis."
			EndIf
			
			If Empty(CAQ->CAQ_REGECF)
				Aadd(aLogErro,{"CAQ_REGECF","000001","CAP",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			Else
				If !(CAQ->CAQ_REGECF $ "1|2|3|")
					aAdd(aLogErro,{"CAQ_REGECF","000002","CAP", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis."
				EndIf
			EndIf
					
			//Busca na tabela de conta referecial
			CHA->(DbSetOrder(1)) 
			If CHA->(DbSeek( xFilial("CHA") + CAQ->CAQ_IDCODC ) )
				cIdTpCnt:=	CHA->CHA_CODNAT
			EndIF
			
			//Busca o Código da Natureza
			C2R->(DbSetOrder(3)) 		
			If C2R->(DbSeek( xFilial("C2R") + cIdTpCnt) )
				cTipCont:=	C2R->C2R_CODIGO
			EndIF		
		
			//Somatório do valor do saldo inicial	
			//Se situação do saldo final for devedor, subtrai. Senão, soma.			
			If cTipCont=='01'
				If CAQ->CAQ_INDINI == '1'
					nSALINIA:= nSALINIA - CAQ->CAQ_SALINI
				Else
					nSALINIA:= nSALINIA + CAQ->CAQ_SALINI
				EndIf
			ElseIf cTipCont=='02'
				If CAQ->CAQ_INDINI == '1'
					nSALINIP:= nSALINIP - CAQ->CAQ_SALINI
				Else
					nSALINIP:= nSALINIP + CAQ->CAQ_SALINI
				EndIf
			EndIf		
		
			//Somatório do valor do saldo final	
			//Se situação do saldo final for devedor, subtrai. Senão, soma.			
			If cTipCont=='01'
				If CAQ->CAQ_INDFIN == '1'
					nSALFINA:= nSALFINA - CAQ->CAQ_SALFIN
				Else
					nSALFINA:= nSALFINA + CAQ->CAQ_SALFIN
				EndIf
			ElseIf cTipCont=='02'
				If CAQ->CAQ_INDFIN == '1'
					nSALFINP:= nSALFINP - CAQ->CAQ_SALFIN
				Else
					nSALFINP:= nSALFINP + CAQ->CAQ_SALFIN
				EndIf
			EndIf
			
		CAQ->( DbSkip() )
	EndDo
	
	//Busca o Periodo de Apuração
	cPerAPur:= Posicione("CAH",1,xFilial("CAH")+CAP->CAP_IDPERA,"CAH_CODIGO")//Posiciona no Código da Natureza
		
	//REGRA_BALANCO_SALDO_FINAL
	If ( nSALFINA + nSALFINP ) <> 0
		If cPerAPur == "A00" .OR. cPerAPur == "A12" .OR. cPerAPur == "T04"
			AADD(aLogErro,{"CAQ_SALFIN","000144","CAP",nRecno}) //STR0022 - "A soma do campo 'Vl.Cta.Ref.' deve ser igual ao campo 'Vl.Saldo Fin'."
		EndIf
	EndIf		
	
	//REGRA_BALANCO_SALDO_INICIAL
	If ( nSALINIA + nSALINIP ) <> 0
		If cPerAPur == "A00" .OR. cPerAPur == "A01" .OR. cPerAPur == "A02" .OR. cPerAPur == "A03" .OR. cPerAPur == "A04" .OR. cPerAPur == "A05" .OR. cPerAPur == "A06" .OR. cPerAPur == "A07" .OR. cPerAPur == "A08" .OR. cPerAPur == "A09" .OR. cPerAPur == "A10" .OR. cPerAPur == "A11" .OR. cPerAPur == "A12" .OR. cPerAPur == "T01"
			AADD(aLogErro,{"CAQ_SALINI","000145","CAP",nRecno}) //STR0022 - "A soma do campo 'Vl.Cta.Ref.' deve ser igual ao campo 'Vl.Saldo Fin'."
		EndIf
	EndIf	
		
EndIf


dbSelectArea("CAR")
dbSetOrder(1)

If CAR->(MsSeek(xFilial("CAR")+CAP->CAP_ID))

	If Empty( CAR->CAR_INDAVA )
		aAdd( aLogErro, { "CAR_INDAVA", "000001", "CAP", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	Else
		If !( CAR->CAR_INDAVA $ "1|2|3|4|5|6|7|8" )
			aAdd( aLogErro, { "CAR_INDAVA", "000002", "CAP", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
		EndIf
	EndIf

	dbSelectArea("CAS")
	dbSetOrder(1)

	cCASKey:= CAR->CAR_ID

	If CAS->(MsSeek(xFilial("CAS")+cCASKey))

		Do While !CAS->( Eof() ) .And. cCASKey == CAS->CAS_ID

			If Empty(CAS->CAS_IDCODC)
				Aadd(aLogErro,{"CAS_CODCTA","000001","CAP",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
			Else
			//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := CAS->CAS_IDCODC
				xVldECFTab("CH6",cChave,1,,@aLogErro,{"CAP","CAS_CODCTA", nRecno})
			EndIf
	
			CAS->( DbSkip() )
		EndDo
	
	EndIF
	
EndIF
		
dbSelectArea("CAT")
dbSetOrder(1)

cCATKey:= CAP->CAP_ID
nRecCHD := 0
If BuscaCHD(CAP->CAP_DTINI, CAP->CAP_DTFIN,@nRecCHD)
	CHD->(DbGoTo(nRecCHD))
	cIndVen	:= CHD->CHD_INDVEN
	cIndRop	:= CHD->CHD_INDROP
	cIndPag	:= CHD->CHD_INDPAG	
EndIf

If CAT->(MsSeek(xFilial("CAT")+cCATKey))

	Do While !CAT->( Eof() ) .And. cCATKey == CAT->CAT_ID
			
		If Empty(CAT->CAT_IDCODC)
			Aadd(aLogErro,{"CAT_CODCTA","000001","CAP",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
		Else
			//Chave de busca na tabela FILHO ou Consulta padrao
			cChave := CAT->CAT_IDCODC
			xVldECFTab("CHA",cChave,1,,@aLogErro,{"CAP","CAT_CODCTA", nRecno})
		EndIf
			
		If Empty(CAT->CAT_INDFIN)
			Aadd(aLogErro,{"CAT_INDFIN","000001","CAP",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
		Else
			If !(CAT->CAT_INDFIN $ "1|2")
				aAdd(aLogErro,{"CAT_INDFIN","000002","CAP", nRecno }) //STR0002 "Conteúdo do campo não condiz com as opções possíveis."
			EndIf
		EndIf
			
		If Empty(CAT->CAT_REGECF)
			Aadd(aLogErro,{"CAT_REGECF","000001","CAP",nRecno}) //STR0001 - "Campo inconsistente ou vazio."
		Else
			If !(CAT->CAT_REGECF $ "1|2|3|")
				aAdd(aLogErro,{"CAT_REGECF","000002","CAP", nRecno}) 	//STR0002 "Conteúdo do campo não condiz com as opções possíveis."
			EndIf
		EndIf
		
		 //cIndVen  
		 cContCHA := POSICIONE("CHA",1,XFILIAL("CHA")+CAT->CAT_IDCODC,"CHA_CODIGO")
		 If cContCHA $ "3.01.01.01.01.02|3.11.01.01.01.02"
			nIndVen += CAT->CAT_SALFIN
		 EndIf		 
		
		//IndRop 
		If cContCHA $ "3.01.01.07.01.32|3.11.01.07.01.32"
			nIndRop += CAT->CAT_SALFIN
		EndIf
				
		//cIndPag
		If cContCHA $ "3.01.01.05.01.06|3.01.01.05.01.07|3.01.01.05.01.0|3.01.01.05.01.10|3.11.01.05.01.06|3.11.01.05.01.07|3.11.01.05.01.09|3.11.01.05.01.10"
			nIndPag +=  CAT->CAT_SALFIN
		EndIf
		
		CAT->( DbSkip() )
	EndDo
				
EndIf
		If cIndVen == '1' .And. (nIndVen == 0)
			aAdd(aLogErro,{"CAT_IDCODC","000318","CAP", nRecno}) // Houve indicação de vendas a comercial exportadora com fins específicos de exportação (campo IND_VEND_EXP do registro 0020) não condizente com os valores declarados como receita de vendas a comercial exportadora nas linhas "3.01.01.01.01.02" e "3.11.01.01.01.02" do registro L300
		EndIf
		If cIndVen == '2' .And. (nIndVen > 0)
			aAdd(aLogErro,{"CAT_IDCODC","000318","CAP", nRecno}) // Houve indicação de vendas a comercial exportadora com fins específicos de exportação (campo IND_VEND_EXP do registro 0020) não condizente com os valores declarados como receita de vendas a comercial exportadora nas linhas "3.01.01.01.01.02" e "3.11.01.01.01.02" do registro L300		
		EndIf
		
		If cIndRop == '1' .And. (nIndRop == 0 )
			aAdd(aLogErro,{"CAT_IDCODC","000319","CAP", nRecno}) //Houve indicação de royalltes recebidos ou pagos a beneficiários do Brasil e do exterior (campo IND_ROY_PAG do registro 0020) não condizente com os valores declarados nas linhas "3.01.01.07.01.32" e "3.11.01.07.01.32" do registro L300 		
		EndIf
		
		If cIndRop == '2' .And. (nIndRop > 0 )
			aAdd(aLogErro,{"CAT_IDCODC","000319","CAP", nRecno}) //Houve indicação de royalltes recebidos ou pagos a beneficiários do Brasil e do exterior (campo IND_ROY_PAG do registro 0020) não condizente com os valores declarados nas linhas "3.01.01.07.01.32" e "3.11.01.07.01.32" do registro L300 
		EndIf
		
		If cIndPag == '1' .And. nIndPag == 0
			aAdd(aLogErro,{"CAT_IDCODC","000320","CAP", nRecno}) //Houve indicação de participações avaliadas pelo método de equivalência patrimonial (campo IND_PART_COLIG do registro 0020) não condizente com os valores declarados nas linhas "3.01.01.05.01.06", "3.01.01.05.01.07", "3.01.01.09.01.09", "3.01.01.09.01.10", "3.11.01.05.01.06", "3.11.01.05.01.07", "3.11.01.09.01.09" e 3.11.01.09.01.10 do registro L300.
		EndIf
		If cIndPag == '2' .And. nIndPag > 0
			aAdd(aLogErro,{"CAT_IDCODC","000320","CAP", nRecno}) //Houve indicação de participações avaliadas pelo método de equivalência patrimonial (campo IND_PART_COLIG do registro 0020) não condizente com os valores declarados nas linhas "3.01.01.05.01.06", "3.01.01.05.01.07", "3.01.01.09.01.09", "3.01.01.09.01.10", "3.11.01.05.01.06", "3.11.01.05.01.07", "3.11.01.09.01.09" e 3.11.01.09.01.10 do registro L300. 
		EndIf
				 
RestArea(aAreaCAP)
//ATUALIZO O STATUS DO REGISTRO
cStatus := Iif(Len(aLogErro) > 0,"1","0")
TAFAltStat( "CAP", cStatus )
		
Else
	
	AADD(aLogErro,{"CAP_ID","000017","CAP", nRecno})//STR0017 - Registro já validado.
	
EndIf
	
//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)
//-------------------------------------------------------------------
/*{Protheus.doc} BuscaCHD

Funcao que disponibiliza o Recno na CHD para posterior uso

@return .T.

@author Henrique Pereira
@since 07/04/2017
@version 1.0
*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function BuscaCHD(dPerIni, dPerFin, nRecCHD)
Local lRet := .F.
Local cSelect  := ""
Local cFrom    := ""
Local cWhere   := ""
Local cAliasQry := GetNextAlias()

cSelect := "CHD.R_E_C_N_O_ "
cFrom	 := RetSqlName( "CHD" ) + " CHD "
cWhere  := " CHD.CHD_FILIAL = '" + xFilial("CHD" ) + "' AND "
cWhere  += " CHD.CHD_PERINI BETWEEN '" + DToS( dPerIni ) + "' AND '" + DToS( dPerFin ) + "' AND "
cWhere  += " CHD.CHD_PERFIN BETWEEN '" + DToS( dPerIni ) + "' AND '" + DToS( dPerFin ) + "' AND "
cWhere  += " CHD.D_E_L_E_T_ = '' "

cSelect := "%"	+	cSelect	+	"%"
cFrom   := "%"	+	cFrom  	+	"%"
cWhere	 := "%"	+	cWhere 	+	"%"

// Não existe looping pois a CHD contem 1 periodo por filial 
If !Empty(cSelect)
	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
EndIf


If (cAliasQry)->R_E_C_N_O_ > 0
   nRecCHD := (cAliasQry)->R_E_C_N_O_
   lRet := .T.
EndIf

Return lRet