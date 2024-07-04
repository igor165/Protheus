#include "OGA730.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __lMarcAllE	:= .T. //marca tudo painel - varivel static
Static __lTelaAntec := .F.

/*/{Protheus.doc} OGA730
Rotina para cadastro de container's e relacionamento com uma IE
@type function
@version  P12
@author Thiago Henrique Rover
@since 21/11/2017
@param pcCod, variant, Codigo da intrução de embarque
@Uso: 		Mercado Externo
/*/
Function OGA730( pcCod )

	Local oMBrowse 		:= Nil
	Local cFiltroDef 	:= iIf( !Empty( pcCod ), "N91_CODINE='"+pcCod+"'", "" )
	Private cCodIe 		:= pcCod
	private aFardRom  	:= {}	
	private _aCnt      	:= {} //array de containers na geração da certificação antecipada
	private _lTelaCert 	:= .F. //se .T. esta executando a tela de certificação
	private _lTelaData 	:= .F. //se .T. esta executando a tela de registro de data
	private _lProdAlg	:= .F. //se produto no container é algodão(.t.)

	//Função válida somente para IE do tipo Externa
	If ValTpMerc(.F.) = "1" 
		Help(" ", 1, "OGA710TIPMERC") //##Problema: Função não disponível para mercado interno. ##Solução: Esta função é especifica para mercado externo.
		Return .T.
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N91" )
	oMBrowse:SetDescription( STR0001 ) //"Cadastro Container"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "OGA730" )

	oMBrowse:AddLegend( "N91_STATUS=='1'", "GREEN",  STR0002 ) //"Disponível"
	oMBrowse:AddLegend( "N91_STATUS=='2'", "YELLOW", STR0003 ) //"Em Estufagem"
	oMBrowse:AddLegend( "N91_STATUS=='3'", "ORANGE", STR0004 ) //"Estufado"
	oMBrowse:AddLegend( "N91_STATUS=='4'", "RED",    STR0005 ) //"Em Certificação"
	oMBrowse:AddLegend( "N91_STATUS=='5'", "GRAY",   STR0006 ) //"Certificado"
	oMBrowse:AddLegend( "N91_STATUS=='6'", "BLUE",   STR0026 ) //"Aprovado"

	oMBrowse:Activate()

Return

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Thiago Henrique Rover
@since: 	21/11/2017
@Uso: 		Mercado Externo
@type function
*/
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0007 	, "PesqBrw"			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0008	, "ViewDef.OGA730"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0009   	, "ViewDef.OGA730"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0010   	, "ViewDef.OGA730"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0011   	, "ViewDef.OGA730"	, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0012	, "OGA730HIS"       , 0, 7, 0, Nil } ) //"Histórico"
	aAdd( aRotina, { STR0017    , "OGA250B(.T.,N91->N91_CODINE,N91->N91_CONTNR,N91->N91_STATUS)", 0, 4, 0, Nil } ) //"Estufagem"
	aAdd( aRotina, { STR0027    , "OGA730ANT(N91->N91_CODINE)", 0, 4, 0, Nil } ) //"Gerar Antecipado"
	aAdd( aRotina, { STR0038    , "OGA730CANT(N91->N91_CODINE, N91->N91_CONTNR)", 0, 4, 0, Nil } ) //"Cons. Estufagem Antecipada"
	aAdd( aRotina, { STR0018	, "OGA730CERT"       , 0, 4, 0, Nil } ) //"Certificar"
	aAdd( aRotina, { STR0024	, "OGA730DT"         , 0, 4, 0, Nil } ) //"Registrar Saída/Entrada Terminal"
	aAdd( aRotina, { STR0053    , "OGA730NREM(N91->N91_CODINE, N91->N91_CONTNR)", 0, 4, 0, Nil } ) //"Painel Saldos Notas de Remessa"

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Thiago Henrique Rover
@since: 	21/11/2017
@Uso: 		Mercado Externo
*/
Static Function ModelDef()

	Local oStruN91 := FWFormStruct( 1, "N91" )
	Local oModel   := MPFormModel():New( "OGA730" , , , {| oModel | GrvModelo( oModel ) } )
	Default cCodIe := ''
	Default _lTelaCert := .F.
	
	//validação de variavel conforme https://jiraproducao.totvs.com.br/browse/DAGROOGD-11881
	If ! Empty( cCodIe )
		oStruN91:SetProperty( "N91_CODINE" , MODEL_FIELD_INIT , { | | cCodIe } ) 
		oStruN91:SetProperty( "N91_DESINE" , MODEL_FIELD_INIT , { | | Posicione( "N7Q", 1, xFilial( "N7Q" ) + cCodIe, "N7Q_DESINE" ) } ) 		
	EndIf

	If _lTelaCert //se tela de certificação
		oStruN91:SetProperty("N91_QTDCER"  ,MODEL_FIELD_OBRIGAT,.T.)
	EndIF

	oStruN91:AddTrigger( "N91_QTDCER", "N91_BRTCER", { || .T. }, { | oField | fTrgCer1( oField, "N91_BRTCER" ) } )
	oStruN91:AddTrigger( "N91_QTDCER", "N91_PCNTCN", { || .T. }, { | oField | fTrgCer1( oField, "N91_PCNTCN" ) } )
	oStruN91:AddTrigger( "N91_QTDCER", "N91_DPNTCN", { || .T. }, { | oField | fTrgCer1( oField, "N91_DPNTCN" ) } )

	oStruN91:SetProperty( "N91_CODINE"  , MODEL_FIELD_WHEN  , {||wVldN91('N91_CODINE', oModel)} )
	oStruN91:SetProperty( "N91_CONTNR"  , MODEL_FIELD_WHEN  , {||wVldN91('N91_CONTNR', oModel)} )
	oStruN91:SetProperty( "N91_QTDCER"  , MODEL_FIELD_WHEN  , {||wVldN91('N91_QTDCER', oModel)} )

	oStruN91:SetProperty( "N91_QTDCER" 	, MODEL_FIELD_VALID	, {| oField | VldQtdCer( oField ) } )

	oModel:AddFields( "N91UNICO", Nil, oStruN91 )
	oModel:SetDescription( STR0001 ) //"Cadastro de Container"
	oModel:GetModel( "N91UNICO" ):SetDescription( STR0001 ) //"Cadastro de Container"

	oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } ) 
	oModel:SetActivate({|oModel| ActModelo (oModel)})
	oModel:SetDeActivate( { | oModel | FimModelo( oModel )})  

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Thiago Henrique Rover
@since: 	21/11/2017
@Uso: 		Mercado Externo
*/
Static Function ViewDef()

	Local oStruN91 := FWFormStruct( 2, "N91" )
	Local oModel   := FWLoadModel( "OGA730" )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )

	oStruN91:RemoveField( "N91_DTULAL" )
	oStruN91:RemoveField( "N91_HRULAL" )
	//oStruN91:RemoveField( "N91_FILORG" )

	oView:AddField( "VIEW_N91", oStruN91, "N91UNICO" )
	oView:CreateHorizontalBox( "UM"  , 100 )
	oView:SetOwnerView( "VIEW_N91", "UM"   )

	oView:AddUserButton( STR0017 ,''       , { |oModel| OGA250B(.F.,N91->N91_CODINE,N91->N91_CONTNR,N91->N91_STATUS) } ) //"Vincular Fardos"

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

/** {Protheus.doc} wVldN91
When do campo - habilita ou desabilita edição do campo
@param:     cCampo - Nome do campo 
@return:    lRetorno - verdadeiro ou falso
@author:    Agroindustria
@since:     24/11/2017
@Uso:       OGA730
*/
Static Function wVldN91(cCampo, oModel)
	Local lRetorno  := .T.
	Local nOperation	:= oModel:GetOperation()
	Local oFldN91		:= oModel:GetModel( "N91UNICO" )

	If cCampo == 'N91_CODINE'
		If (!Empty(cCodIe) .or. nOperation == MODEL_OPERATION_UPDATE)
			lRetorno  := .F.
		ElseIf nOperation == MODEL_OPERATION_INSERT
			_lProdAlg := ProdAlgCnt(oFldN91:GetValue("N91_CODINE")) //seta variavel novamente quando altera o codigo da instrução de embarque
		EndIf
	ElseIf  cCampo == 'N91_CONTNR' .and. nOperation == MODEL_OPERATION_UPDATE
		lRetorno  := .F.
	ElseIf  cCampo == 'N91_QTDCER' .AND. ( Empty(oFldN91:GetValue("N91_CODINE")) .OR. ( _lProdAlg .AND. !_lTelaCert) ) //N91_CODINE em branco OU é produto algodao e não é tela de certificação
		lRetorno := .F.	//Não permite edição no campo N91_QTDCER
	EndIf

Return( lRetorno )

/** {Protheus.doc} GrvModelo

Função de commit do modelo, nela é realizado a gravação do histórico gravação no banco.

@param: 	Nil
@return:	.t.
@author: 	Thiago Henrique Rover
@since: 	21/11/2017
@Uso: 		Mercado Externo
*/
Static Function GrvModelo( oModel )
			
	Local aAreaAtu		:= GetArea()
	Local cTitulo		:= ""
	Local nOperation 	:= oModel:GetOperation()
	Local oFldN91		:= oModel:GetModel( "N91UNICO" )
	Local lRetorno		:= .T.
	Local nQtdCert      := 0
	Local cCodIne       := oFldN91:GetValue("N91_CODINE")
	
	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
			cTitulo 	:= STR0013 //"Cadastro IE X Container"  
			AGRGRAVAHIS(,,,,{"N91",xFilial("N91")+oFldN91:Getvalue('N91_CODINE')+oFldN91:Getvalue('N91_CONTNR'),"3",STR0009}) //Incluir
			AtuCntRes(nOperation,oFldN91:Getvalue('N91_CODINE'))
			AtuStaPesC(.T.,oFldN91:Getvalue('N91_CODINE'))
		EndIf
		
		If nOperation == MODEL_OPERATION_UPDATE
			cTitulo 	:= STR0014 //"Alteração IE X Container"
			AGRGRAVAHIS(,,,,{"N91",N91->N91_FILIAL+N91->N91_CODINE+N91->N91_CONTNR,"4",STR0010}) //Alterar
	
			If _lTelaCert //se tela de certificação
				oFldN91:SetValue('N91_STATUS','5')
				oFldN91:SetValue('N91_DTCERT',DDATABASE)
				AtuStaPesC(.F.,oFldN91:Getvalue('N91_CODINE'),oFldN91:Getvalue('N91_CONTNR')) //Atualiza Status Peso Certificado da Ie
				If _lProdAlg //se produto algodão
					RatFrdCnt() // realiza o rateio dos fardos 
				EndIf			
			EndIF
		EndIf
		
		If nOperation == MODEL_OPERATION_DELETE
	
			cTitulo 	:= STR0015 //"Excluida Autorização de Embarque/Desembarque"
			AGRGRAVAHIS(,,,,{"N91",N91->N91_FILIAL+N91->N91_CODINE+N91->N91_CONTNR,"5",STR0011}) //Excluir
			AtuCntRes(nOperation, N91->N91_CODINE)
	
			DelFrdCnt(oFldN91:Getvalue('N91_CODINE'),oFldN91:Getvalue('N91_CONTNR')) //desvincuila os fardos ao excluir o container
	
			//Elimina vínculo com as notas de remessa
			If !_lProdAlg
				//Elimina vínculo movimento antecipado x conteiner, caso já exista
				DbSelectArea("N9I")
				DbSetOrder(3)
				If N9I->(dbSeek( "3" + N91->N91_FILIAL + N91->N91_CODINE + N91->N91_CONTNR ) )
	
					While N9I->( !Eof() ) .AND. N9I->N9I_INDSLD = '3' .AND. N9I->N9I_FILORG == N91->N91_FILIAL .AND. N9I->N9I_CODINE == N91->N91_CODINE .AND. N9I->N9I_CONTNR == N91->N91_CONTNR
						nQtdCert += N9I->N9I_QTDFIS
						If RecLock( "N9I", .F. )
							N9I->(DbDelete())
							N9I->( msUnLock() )
						EndIf
						N9I->(DbSkip())
					EndDo
				EndIf
				N9I->(DbCloseArea())
	
				//Elimina vínculo da estufagem física
				OG710AEN9I('2',N91->N91_FILIAL,N91->N91_CODINE,N91->N91_CONTNR)
			EndIf
	
		EndIf
	
		If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE    
			oFldN91:SetValue("N91_DTULAL", DDATABASE )
			oFldN91:SetValue("N91_HRULAL", SubStr(TIME(), 0, 8) )
	
			If !_lProdAlg 
				If !_lTelaCert .and. !_lTelaData
					If !Empty(oFldN91:GetValue("N91_QTDFRD")) .OR. (!_lProdAlg .AND. !Empty(oFldN91:GetValue("N91_QTDCER")))
						If oFldN91:GetValue("N91_STUFIN") == '1'
							oFldN91:SetValue("N91_STATUS", "3")
						Else	
							oFldN91:SetValue("N91_STATUS", "2")
						EndIf
					Else
						oFldN91:SetValue("N91_STATUS", "1")
					EndIf
				EndIf
			EndIf
	
			If !(Empty(aFardRom))
				OGA730BGRV(.F.)
			EndIf
	
			//Vínculo com as notas de remessa
			If !_lProdAlg .And. !_lTelaData// Se Ñ for algodão e ñ for atualização da data de saida/chegada no terminal
	
				//Se alteração, limpa o registro e recria
				If nOperation == MODEL_OPERATION_UPDATE    
					OG710AEN9I('2',N91->N91_FILIAL,N91->N91_CODINE,N91->N91_CONTNR)
				EndIF
	
				cFilOrg := oFldN91:Getvalue('N91_FILORG')
				If OG730CTNREM('2', oFldN91:Getvalue('N91_CONTNR'), oFldN91:Getvalue('N91_CODINE'), oFldN91:Getvalue('N91_QTDCER'), @cFilOrg )
					If !Empty(cFilOrg) .And. oFldN91:Getvalue('N91_QTDCER') > 0
						oFldN91:SetValue("N91_FILORG", cFilOrg)
					EndIF
				Else
					DisarmTransaction()
					//"IE não possui Nota(s) de Remessa com saldo suficiente"##"Vincule as notas fiscais de remessa na Instrução de Embarque"
					oModel:GetModel():SetErrorMessage(oFldN91:GetId(), ,oFldN91:GetId(), "", "", STR0054, STR0056, "", "")									
					lRetorno := .F.
				EndIF
			EndIF
	
			//Gravar a data de saida na tabela de vinculo Rem. Form. Lote x IE
			If lRetorno .and. _lTelaData
				DbSelectArea("N9I")
				DbSetOrder(3)
				If N9I->(dbSeek( "2" + oFldN91:GetValue("N91_FILIAL") + oFldN91:Getvalue('N91_CODINE') + oFldN91:Getvalue('N91_CONTNR')) )
	
					While N9I->( !Eof() ) .AND. N9I->N9I_FILORG == oFldN91:GetValue("N91_FILIAL") .AND. N9I->N9I_CODINE == oFldN91:Getvalue('N91_CODINE') .AND. N9I->N9I_CONTNR == oFldN91:Getvalue('N91_CONTNR')
						If RecLock( "N9I", .F. )
							N9I->N9I_DTSAI := oFldN91:Getvalue('N91_DTSAI')
							N9I->( msUnLock() )
						EndIf
						N9I->(DbSkip())
					EndDo
	
				EndIf
				N9I->(DbCloseArea())
			EndIf
	
		EndIf
		
		If lRetorno 
			If _lProdAlg
				//SE FOR ALGODÃO - ajusta status do fardo na DXI
				OGA730STFR(oFldN91:Getvalue('N91_FILIAL'), oFldN91:Getvalue('N91_CODINE'), oFldN91:Getvalue('N91_CONTNR'), oFldN91:Getvalue('N91_STATUS'))
			EndIf
	
			If !(FWFormCommit( oModel )) 
				DisarmTransaction()		
				lRetorno := .F.			
			EndIf
		EndIf
		
		//Auto-cura: atualiza campos referente a certificação na instrução de embarque
		If lRetorno .And. (nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .And. _lTelaCert) )    
			CertAtuIE(cCodIne) 
		EndIf
	
		RestArea( aAreaAtu )
	
	End Transaction
	
Return( lRetorno )

/** {Protheus.doc} OGA730HIS
Descrição: Mostra em tela de Historico das Autorizações

@param: 	Nil
@author: 	Gilson Venturi
@since: 	02/06/2015
@Uso: 		OGA730 
*/
Function OGA730HIS()

	Local cChaveI := "N91->("+Alltrim(AGRSEEKDIC("SIX","N91",1,STR0016))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("N91",cChaveA)

Return

/** {Protheus.doc} AtuCntRes
Descrição:Atualiza o campo N7Q_QTDCOR (Quantidade de Containers Reservados) da 
Instrução de Embarque

@param: 	nOperation
* Se for inclusão soma  1 na quantidade
* Se for exclusão diminui 1 da quantidade
@author: 	Janaina F B Duarte
@since: 	23/11/2017
@Uso: 		OGA730 
*/
Static Function AtuCntRes(nOperation, cIE)

	dbSelectArea( "N7Q" ) 
	N7Q->(dbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE

	If N7Q->(dbSeek( xFilial( "N7Q" ) + cIe) )
		If RecLock( "N7Q", .F. )
			If nOperation = 3 // Inclusão
				N7Q->( N7Q_QTDCOR ) := N7Q->( N7Q_QTDCOR ) + 1
			Elseif nOperation = 5 // Exclusão
				N7Q->( N7Q_QTDCOR ) := N7Q->( N7Q_QTDCOR ) - 1
			EndIf
			N7Q->( msUnLock() )
		EndIf			
	EndIf	

	Return

	/*/{Protheus.doc} ValQtCnt()
	Valida se com a adição de mais um CNT não será ultrapassada a Qtd informada no campo N7Q_QTDCON
	22/12/2017 - Também valida se status do peso certificado permite a inclusão
	@type  Function
	@author Rafael Kleestadt da Cruz
	@since 23/11/2017
	@version 1.0
	@param param, param_type, param_descr
	@return lRet, Boolean, verdadeiro ou falso
	@example
	(examples)
	@see (links_or_references)
	/*/
Function ValQtCnt()
	Local cCodine   := ''
	Local lRet      := .T.
	Local nTotCnt   := 0
	Local nCntIe    := 0
	Local cQuery    := ''
	Local cAliasQT  := GetNextAlias()
	Local cStaPeC   := ''
	Local oModel	:= Nil
	 
	If IsInCallStack("OGA710")
		cCodine   := N7Q->N7Q_CODINE
	Else
		oModel  := FwModelActive()
		cCodine := oModel:GetValue("N91UNICO","N91_CODINE")
	EndIf

	DbSelectArea('N7Q')
	DbSetOrder(1)
	If DbSeek(xFilial('N7Q')+cCodine) .AND. N7Q_CODINE == cCodine
		nCntIe  := N7Q->N7Q_QTDCON
		cStaPeC := N7Q->N7Q_STAPCE
	EndIf

	cQuery := " SELECT COUNT(N91_CODINE) AS TOTAL"
	cQuery += " FROM "+ RetSqlName('N91') + " N91"
	cQuery += " WHERE N91.N91_CODINE = '" + cCodine + "'"
	cQuery += " AND N91.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQT, .F., .T.)

	nTotCnt := (cAliasQT)->TOTAL + 1

	If nTotCnt > nCntIe
		Help(" ", 1, "OGA730VALQTCNT") //##Problema: A quantidade de contêineres para esta instrução de embarque foi atingida. ##Solução: Selecione outra instrução de embarque ou aumente a quantidade do campo Q. Container da pasta "Itens da IE" desta instrução de embarque.
		Return .F.
	EndIf

	If cStaPeC == '4' //Aprovado
		Help(" ", 1, "OGA730PESOCER") //##Problema: Peso Certificado já foi Aprovado ##Solução: Para incluir mais containers, revise o Peso Certificado da Instrução de Embarque
		Return .F.
	EndIf

Return lRet

/** {Protheus.doc} ActModelo
Função que incializa o modelo de dados

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Thiago Henrique Rover
@since:     28/11/2017
@Uso: 		OGA730 - Container - Mercado Externo
*/
Static Function ActModelo( oModel )
	Local lRetorno      := .t.
	Local oModelN91 := oModel:GetModel("N91UNICO")
	Local nOperation    := oModel:GetOperation()

	_lProdAlg := ProdAlgCnt(oModelN91:GetValue("N91_CODINE")) //seta variavel 

	If oModel:Activate() .And. nOperation == MODEL_OPERATION_UPDATE   
		oModelN91:SetValue("N91_DTULAL", DDATABASE )
		oModelN91:SetValue("N91_HRULAL", SubStr(TIME(), 0, 8) )
	EndIf

Return( lRetorno )

/*/{Protheus.doc} IniModelo
Função criada para agrupar outras funções necessárias na inicialização do modelo. 
@type  Function
@author Rafael Kleestadt da Cruz
@since 23/11/2017
@version 1.0
@param oModel, Object, modelo de dados
nOperation, numeric, numero da operação.
@return lRetorno, boolean, verdadeiro ou falso
@example
(examples)
@see (links_or_references)
/*/
Static Function IniModelo( oModel, nOperation )
	Local lRetorno := .t.

	If IsInCallStack("OGA710") .And. nOperation = MODEL_OPERATION_INSERT 
		lRetorno := ValQtCnt()
	EndIf	

	If nOperation = MODEL_OPERATION_UPDATE .and. !(N91->N91_STATUS $ "1|2|3|4|5") .and. !_lTelaCert .and. !_lTelaData
		Help( , , STR0019, , STR0021, 1, 0 ) //"Ajuda"###"Status do container não permite alteração"
		lRetorno := .F.
	EndIf 

	If nOperation == MODEL_OPERATION_DELETE 
		If !(N91->N91_STATUS $ "1|2") 
			Help( ,, STR0019,, STR0025 + N91->( N91_STATUS ) + " - " + X3CboxDesc( "N91_STATUS", N91->( N91_STATUS ) ), 1, 0,) //"HELP"##"Operação não permitida para Container com status "
			lRetorno := .F.
		EndIf
	EndIf

Return lRetorno

/** {Protheus.doc} FimModelo
Função executada no Deactivate do modelo de dados

@param: 	oModel - Modelo de dados
@param: 	nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:	.T.
@author: 	Claudineia H. Reinert
@since: 	30/11/2017
@Uso: 		OGA730
*/
Static Function FimModelo( oModel )

	aFardRom := {}

Return .T.

/*/{Protheus.doc} OGA730CERT
Função que permite após container estufado a atualização
da quantidade total do container certificado

@author claudineia.reinert	
@since 27/11/2017
@version 1.0
@type function
/*/
Function OGA730CERT()
	Local aCoors    := FWGetDialogSize(oMainWnd) //array com tamanho da window
	Local oView
	Private _lTelaCert 	:= .F. 
	Private _lProdAlg	:= .F.

	If N91->N91_STATUS != "3" .AND. N91->N91_STATUS != "4"
		Help( ,, STR0019,, STR0020, 1, 0,) //'HELP'###"Somente Container com status de -Estufado- pode ser -Certificado-."
		Return .F.
	Else
		_lTelaCert := .T. //AO ABRIR TELA SETA PARA .T.
		_lProdAlg := ProdAlgCnt(N91->N91_CODINE)
		oView :=  FWLoadView( "OGA730" ) 
		oView:SetOperation(MODEL_OPERATION_UPDATE) //se que é alteração para a view
		oStrucN91 := oView:GetViewStruct("N91UNICO") //carrega a estrutura da N91 da view

		//DESABILITA FOLDERS QUE NÃO DEVEM APARECER, DEVE APARECER APENAS PESAGEM E CLASSIFICAÇÃO
		oView:SetAfterViewActivate({|oModel|oView:HideFolder("VIEW_N91",1,1),oView:HideFolder("VIEW_N91",3,1)})

		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
		oFWMVCWindow:SetTitle(STR0018)//"Certificar"

		aButtons  := {{.F.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}, {.T.,nil},{.T.,nil},{.f.,nil},{.f.,nil},{.f.,nil},;
		{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}}
		oFWMVCWindow:Activate(,,abuttons) 

		oView:DeActivate()
		FreeObj(oView)
		oFWMVCWindow:DeActivate()
		FreeObj(oFWMVCWindow)	
		_lTelaCert := .F. //APOS FECHAR TELA SETA PARA .F.
	EndIf

Return

/*/{Protheus.doc} OGA730DT
Função que permite informar data de saída e chegada no terminal portuário
@author tamyris.ganzenmueller
@since 06/12/2017
@version 1.0
@type function
/*/
Function OGA730DT()
	Local aCoors    := FWGetDialogSize(oMainWnd) //array com tamanho da window
	Local oView

	private _lTelaData := .T. //AO ABRIR TELA SETA PARA .T.
	
	oView :=  FWLoadView( "OGA730" ) 
	oView:SetOperation(MODEL_OPERATION_UPDATE) //se que é alteração para a view
	oStrucN91 := oView:GetViewStruct("N91UNICO") //carrega a estrutura da N91 da view

	oStrucN91:SetProperty( "N91_DTSAI"  , MVC_VIEW_CANCHANGE, .T. )
	oStrucN91:SetProperty( "N91_HRSAI"  , MVC_VIEW_CANCHANGE, .T. )
	oStrucN91:SetProperty( "N91_DTCHEG" , MVC_VIEW_CANCHANGE, .T. )
	oStrucN91:SetProperty( "N91_HRCHEG" , MVC_VIEW_CANCHANGE, .T. )
	oStrucN91:SetProperty( "N91_QTDCER" , MVC_VIEW_CANCHANGE, .T. )
	//oStruN91:SetProperty( "N91_QTDCER"  , MODEL_FIELD_WHEN  , {.T.} )

	//DESABILITA FOLDERS QUE NÃO DEVEM APARECER, DEVE APARECER APENAS PESAGEM E CLASSIFICAÇÃO
	oView:SetAfterViewActivate({|oModel|oView:HideFolder("VIEW_N91",1,1),oView:HideFolder("VIEW_N91",2,1)})

	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])

	aButtons  := {{.F.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}, {.T.,nil},{.T.,nil},{.f.,nil},{.f.,nil},{.f.,nil},;
	{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}}
	oFWMVCWindow:Activate(,,abuttons) 

	oView:DeActivate()
	FreeObj(oView)
	oFWMVCWindow:DeActivate()
	FreeObj(oFWMVCWindow)	
	_lTelaData := .F. //APOS FECHAR TELA SETA PARA .F.

Return

/** {Protheus.doc} fTrgCer1
Gatilho para preencher campos do container

@param: 	oField - Modelo de dados
@param: 	cFldVld - Nome do campo
@return:	nValor - valor do campo
@author: 	Claudineia H. Reinert
@since: 	30/11/2017
@Uso: 		OGA730
*/
Static Function fTrgCer1(oField, cFldVld)
	Local oModel    := oField:GetModel()
	Local oN91 		:= oModel:GetModel( "N91UNICO" )
	Local nValor	:= 0

	If _lTelaCert .and. cFldVld == 'N91_BRTCER'
		nValor := oN91:GetValue( "N91_QTDCER" ) + (oN91:GetValue( "N91_BRTREM" ) - oN91:GetValue( "N91_QTDREM" ))
	ElseIf _lTelaCert .and. cFldVld == 'N91_PCNTCN'
		nValor := round((((oN91:GetValue( "N91_QTDCER") / oN91:GetValue( "N91_QTDREM" )) - 1) * 100),2)
	ElseIf _lTelaCert .and. cFldVld == 'N91_DPNTCN'
		nValor := oN91:GetValue( "N91_QTDCER" ) - oN91:GetValue( "N91_QTDREM" )
	EndIf

Return nValor

/*{Protheus.doc} 
Função para ao excluir o container desvincular os fardos. 
@sample   	DelFrdCnt(pcCodIE, pcCodCnt)
@param		pcCodIE  - codigo da instrução de embarque
@param		pcCodCnt - codigo do container
@return   	lRetorno
@author   	claudineia H. Reinert
@since    	06/12/2017
@version  	P12
*/
Static Function DelFrdCnt(pcCodIE, pcCodCnt)
	Local cAliasFar := GetNextAlias() // Obtem o proximo alias disponivel
	Local cQryFar   := ""

	//--- Fardos ---//
	cQryFar := " SELECT DXI_FILIAL, DXI_SAFRA, DXI_CODIGO "
	cQryFar += " FROM " + RetSqlName("DXI") + " DXI "
	cQryFar += " WHERE DXI_CODINE = '" + pcCodIE + "' AND DXI_CONTNR = '" + pcCodCnt + "' "
	cQryFar += " AND DXI_CODINE <> '' AND DXI_CONTNR <> '' "
	cQryFar += " AND DXI.D_E_L_E_T_ = ' ' "	
	cQryFar := ChangeQuery(cQryFar)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQryFar),cAliasFar, .F., .T.) 

	DbselectArea( cAliasFar )
	(cAliasFar)->(DbGoTop())
	While (cAliasFar)->( !Eof() )
		
		DbSelectArea( "DXI" )
		DXI->(dbSetOrder(7))		
		If DXI->(dbSeek((cAliasFar)->(DXI_FILIAL)+(cAliasFar)->(DXI_SAFRA)+(cAliasFar)->(DXI_CODIGO)))			
			RecLock( "DXI", .F. )
			DXI->DXI_CONTNR := ''
			DXI->(MsUnLock())
			
			//retorna(2) status do fardo na DXI(DXI_STATUS)
			AGRXFNSF( 2 , "EstufagIni" ) //Aguardando estufagem
			
			DbSelectArea("N9D")
			N9D->(DbSetOrder(5))
			If N9D->(DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_ETIQ+'05'+'2'))
				If !N9D->(Eof()) .AND. Reclock("N9D",.F.)
			       N9D->(DbDelete())
				   N9D->(MsUnlock())
				EndIf
			EndIf
		 
		EndIf
		
		(cAliasFar)->(DbSkip())
	EndDo
	(cAliasFar)->(DbCloseArea())

Return .T.			

/*{Protheus.doc}  AtuStaPesC
Função que atualiza o status do Peso Certificado na IE 
@sample   	AtuStaPesC(pCodIe,pCodCont)
@param		lInclui  - .T. Indica que é inclusão e volta status para Certificação Parcial
.F. Indica operação de Certificação de Peso 
@param		pcCodIE  - codigo da instrução de embarque
@param		pcCodCnt - codigo do container
@return   	
@author   	Tamyris Ganzenmueller
@since    	21/12/2017
@version  	P12
*/
Static Function AtuStaPesC(lInclui,pCodIe,pcCodCnt)
	Local nTotCnt  := 0
	Local cAliasQT := GetNextAlias()
	Local lWFPortal := .F.
	
	// Na Certificação, verifica se há Containers não Certificados ou Aprovados 
	If !lInclui	
		cQuery := " SELECT COUNT(N91_CODINE) AS TOTAL"
		cQuery += "   FROM "+ RetSqlName('N91') + " N91"
		cQuery += "  WHERE N91.N91_CODINE =  '" + pCodIe   + "'"
		cQuery += "    AND N91.N91_CONTNR <> '" + pcCodCnt + "'"
		cQuery += "    AND N91.N91_STATUS <> '5' " //Certificado
		cQuery += "    AND N91.N91_STATUS <> '6' " //Aprovado
		cQuery += "    AND N91.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQT, .F., .T.)

		nTotCnt := (cAliasQT)->TOTAL 
	EndIf

	// Se Existir     -> Certificação Parcial, N7Q_STAPCE = 2=Em Certificação
	// Se não existir -> Certificação Total  , N7Q_STAPCE = 3=Certificado

	// Na Inclusão de um container, se status da IE era Certificado, volta para Em Certificação
	dbSelectArea( "N7Q" ) 
	N7Q->(dbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
	If N7Q->(dbSeek( xFilial( "N7Q" ) + pCodIe) )
		If RecLock( "N7Q", .F. )
			If (lInclui .And. N7Q->N7Q_STAPCE  = '3') .Or. !lInclui
				If nTotCnt > 0 .Or. lInclui
					N7Q->N7Q_STAPCE := '2' // 2=Em Certificação
				Else
					If N7Q->N7Q_QTDCON == N7Q->N7Q_QTDCOR
						N7Q->N7Q_STAPCE := '3' //3=Certificado
						lWFPortal := .T.
					EndIf
				EndIf				
			EndIf
			N7Q->( msUnLock() )
		EndIf			
	EndIf	
	
Return .T.

	/*/{Protheus.doc} ProdAlgCnt()
	//TODO Função verifica se produto do container é algodão
	@type  Static Function
	@author claudineia.reinert	
	@since 07/03/2018
	@version 1.0
	@param oModel, objeto, modelo de dados do MVC
	@return lRet, logico, se .T. o produto é algodão
	/*/
Function ProdAlgCnt(cCodIE)
	Local lRet := .F.

	DbSelectArea("N7Q")
	N7Q->(DbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
	If N7Q->(DbSeek(FwxFilial("N7Q") + cCodIE )) .and. AGRTPALGOD(N7Q->N7Q_CODPRO) //SE FOR ALGODÃO
		lRet := .T.
	EndIf

	Return lRet

	/*/{Protheus.doc} VldQtdCer()
	//TODO validação para o campo N91_QTDCER
	@type  Static Function
	@author claudineia.reinert	
	@since 07/03/2018
	@version 1.0
	@return lRet, logico, se .T. valor informado é valido
	/*/
Static Function VldQtdCer()
	Local aAreaN7Q 	 	:= N7Q->( GetArea() ) //area N7Q 
	Local oModel		:= FwModelActive()
	Local oN91			:= oModel:GetModel( "N91UNICO" )
	Local lRet 			:= .T.

	If .not. _lProdAlg .and. oN91:GetValue( "N91_STATUS") $ "1|2" //não é produto algodão e status do container iguala a disponivel(1) ou em estufagem(2)
		If lRet := ValPesCTN(oN91:GetValue("N91_CODINE"),oN91:GetValue("N91_QTDCER"),oN91:GetValue("N91_QTDCER"))
			oN91:SetValue("N91_QTDREM", oN91:GetValue("N91_QTDCER"))
			oN91:SetValue("N91_BRTREM", oN91:GetValue("N91_QTDCER"))
			oN91:SetValue("N91_QTDREC", oN91:GetValue("N91_QTDCER"))
			oN91:SetValue("N91_BRTREC", oN91:GetValue("N91_QTDCER"))				
		EndIf
	EndIf

	RestArea(aAreaN7Q)

Return lRet

/** {Protheus.doc} RatFrdCnt
Realiza a montagem do array para o rateio

@return:	Nil
@author: 	Claudineia Heerdt Reinert e Thiago Henrique Rover
@since: 	27/11/2017
@Uso: 		OGA730
*/
Static Function RatFrdCnt()
	Local oModel	
	Local oN91		
	Local cCodCnt	
	Local cCodIE	
	Local cQuery 	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local aRateio	:= {} //array com os dados para rateio
	Local nX		:= 0 
	Local nI		:= 0 
	Local nTaraFrd	:= 0 //tara do fardinho
	Local lRet      := .F.

	Local nPsParRat	:= 0 //peso para efetuar o rateio
	Local nPsTotFrd	:= 0 //peso bruto total dos fardinhos no beneficiamento

	If .not. __lTelaAntec //Se não for tela de Estufagem Antecipada

		//Atribuições para as variáveis
		oModel	   := FwModelActive()
		oN91	   := oModel:GetModel( "N91UNICO" )
		nPsParRat  := oN91:GetValue('N91_QTDCER') //peso para rateio
		cCodCnt	   := oN91:GetValue('N91_CONTNR') //codigo do container
		cCodIE	   := oN91:GetValue('N91_CODINE') //codigo da instrução de embarque

		//query para buscar os fardinhos do romaneio
		cQuery :=  " SELECT * "
		cQuery +=  " FROM "+ RetSqlName("DXI") + " DXI"
		cQuery +=  " WHERE DXI.DXI_CODINE   = '" + cCodIE + "' "
		cQuery +=  " AND DXI.DXI_CONTNR   = '" + cCodCnt + "' "
		cQuery +=  " AND DXI.D_E_L_E_T_   = ' ' "
		cQuery +=  " ORDER BY DXI.DXI_CODIGO "

		cQuery := ChangeQuery(cQuery)
		If Select(cAliasQry) <> 0
			(cAliasQry)->(dbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		While (cAliasQry)->(!Eof()) 

			nTaraFrd := (cAliasQry)->DXI_PSBRUT - (cAliasQry)->DXI_PSLIQU //tara do fardinho
			nPsTotFrd += (cAliasQry)->DXI_PSLIQU //peso liquido total dos fardinhos no beneficiamento

			Aadd( aRateio, { ;
			(cAliasQry)->DXI_CODINE,;
			(cAliasQry)->DXI_FILIAL,;
			(cAliasQry)->DXI_BLOCO ,; 
			(cAliasQry)->DXI_SAFRA ,;
			(cAliasQry)->DXI_CODIGO,;
			(cAliasQry)->DXI_PSBRUT,;
			(cAliasQry)->DXI_PSLIQU,;
			nTaraFrd,;
			0; //peso rateio
			})

			(cAliasQry)->( dbSkip() )

		EndDo
		(cAliasQry)->(dbCloseArea())

		lRet := ProcRateio(aRateio, nPsTotFrd, nPsParRat)

	Else //Se for tela de Estufagem Antecipada

		For nX := 1 to Len( _aCnt )
			For nI := 1 to Len( _aCnt[nX][8] )
				nTaraFrd := _aCnt[nX][8][nI][7] - _aCnt[nX][8][nI][8] //tara do fardinho
				nPsTotFrd += _aCnt[nX][8][nI][8] //peso liquido total dos fardinhos no beneficiamento

				Aadd( aRateio, { ;
				N91->N91_CODINE,;
				_aCnt[nX][8][nI][1],; //Filial
				_aCnt[nX][8][nI][3],; //Bloco
				_aCnt[nX][8][nI][2],; //Safra
				_aCnt[nX][8][nI][4],; //Codigo
				_aCnt[nX][8][nI][7],;//Peso Bruto
				_aCnt[nX][8][nI][8],;//Peso Líquido
				nTaraFrd,;
				0; //peso rateio
				})

			Next nI

			nPsParRat := _aCnt[nX][7]
			lRet := ProcRateio(aRateio, nPsTotFrd, nPsParRat) //Chamada da função

			//Limpando as variáveis
			nPsTotFrd := 0
			nPsTotRat := 0
			aRateio   := {}

		Next nX

	Endif
	//Atualiza quantidade instruida da IE com ganho de peso
	OG250EAQIE('05', N91->N91_FILIAL, N91->N91_CODINE)

Return lRet

/** -------------------------------------------------------------------------------------
{Protheus.doc} ProcRateio
Função generica que recebe a estrutura do array de rateio, essa serve para estufagem física e 
estufagem antecipada 

@author thiago.rover
@since 14/03/2018
-------------------------------------------------------------------------------------- **/
Static Function ProcRateio(aRateio, nPsTotFrd, nPsParRat)

	Local nI		:= 0 
	Local lRet	:= .T.
	Local nPsFrdRat	:= 0 //peso bruto do fardinho rateado
	Local nPercFrd	:= 0 //percentual do fardinho em relação ao peso bruto de todos os fardos
	Local nPsTotRat	:= 0 //peso bruto total do rateio dos fardinho

	For nI := 1 to Len( aRateio )
		nPercFrd  := (aRateio[nI][7] / nPsTotFrd)*100 //percentual do fardinho em relação ao peso bruto dos fardinhos do romaneio no beneficiamento 
		nPsFrdRat := round(nPsParRat * (nPercFrd/100) , 2) //Peso bruto de rateio do fardinho
		nPsTotRat += nPsFrdRat
		aRateio[nI][9] := nPsFrdRat //armazena no aRateio o novo peso liquido de rateio do fardinho 
		If nI = Len( aRateio ) .and. nPsParRat <> nPsTotRat
			aRateio[nI][9] += round((nPsParRat - nPsTotRat),2) //o ultimo fardinho recebe a diferença de peso que pode ser maior ou menor devido as casas decimais
		EndIf

		dbSelectArea( "DXI" ) 
		DXI->(dbSetOrder(7)) //FILIAL+SAFRA+CODIGO	
		If DXI->(dbSeek(aRateio[nI][2] + aRateio[nI][4] + aRateio[nI][5]))
			If RecLock( "DXI", .F. )

				DXI->( DXI_PESCER ) := aRateio[nI][9]					
				DXI->( msUnLock() )

			EndIf			
		EndIf	

		dbSelectArea( "N9D" ) 
		N9D->(dbSetOrder(5)) //FILIAL+SAFRA+ETIQUETA+TIPOMOV+STATUS	
		If N9D->(DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_ETIQ+'05'+'2'))

			nPesIni := N9D->N9D_PESINI

			If RecLock( "N9D", .F. )

				N9D->(N9D_PESFIM) := aRateio[nI][9]					
				N9D->(N9D_PESDIF) := aRateio[nI][9] - nPesIni

				N9D->( msUnLock() )

			EndIf			
		EndIf	

	Next nI

	Return lRet

	/*/{Protheus.doc} CertAtuIE()
	//TODO Atualiza campos na instrução de embarque(N7Q) na certificação do container
	@type  Static Function
	@author claudineia.reinert	
	@since 07/03/2018
	@version 1.0
	@return 
	/*/
Static Function CertAtuIE(cCodIne)
	Local lRet 		:= .T.
	Local cQuery    := ""
	Local cAliasN91 := GetNextAlias()
	Local nQtdCert  := 0
	Local nQtdFrd   := 0 
	Local nQtdRem   := 0
	Local nQtdCerFi := 0

	dbSelectArea( "N7Q" ) 
	N7Q->(dbSetOrder(1)) //N7Q_FILIAL+N7Q_CODINE
	If N7Q->(dbSeek( xFilial( "N7Q" ) + cCodIne ))

		// Monta a query de busca
		cQuery := "SELECT N91_QTDCER, N91_QTDANT, N91_QTDFRD, N91_QTDREM, N91_STATUS " 
		cQuery += " FROM " + RetSqlName("N91") + " N91 "				
		cQuery += " WHERE N91.D_E_L_E_T_ = ' ' "
		cQuery += "   AND N91.N91_FILIAL = '"+N7Q->(N7Q_FILIAL)+"' "
		cQuery += "   AND N91.N91_CODINE = '"+N7Q->(N7Q_CODINE)+"' "

		cQuery := ChangeQuery(cQuery)
		cAliasN91 := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasN91,.F.,.T.)

		If (cAliasN91)->(!EoF())
			While (cAliasN91)->(!EoF())

				nQtdCert += IIf((cAliasN91)->N91_QTDCER > 0 , (cAliasN91)->N91_QTDCER, (cAliasN91)->N91_QTDANT   )
				nQtdFrd  += (cAliasN91)->N91_QTDFRD

				If (cAliasN91)->N91_STATUS = '5' .Or. (cAliasN91)->N91_STATUS = '6'
					nQtdRem   += (cAliasN91)->N91_QTDREM
					nQtdCerFi += (cAliasN91)->N91_QTDCER
				EndIF 
				(cAliasN91)->(DbSkip())
			EndDo
		EndIf

		If RecLock( "N7Q", .F. )
			N7Q->( N7Q_QTDCER ) := nQtdCert
			If nQtdRem > 0
				N7Q->( N7Q_PCRMCE ) := IIF(nQtdRem > 0, round(((( nQtdCerFi / nQtdRem ) - 1) * 100),2), 0 )
			EndIf
			If _lProdAlg
				N7Q->( N7Q_QFRCER ) := nQtdFrd //atualiza a qtd de fardos certificado somando com a qtd de fardos do container
			EndIf 
			N7Q->( msUnLock() )
			lRet := .T.
		EndIf

	EndIf

Return lRet

/*{Protheus.doc} OGA730ANT

Função responsável por montar os array's para alimentar a tela

@@author Rafael Kleestadt da Cruz
@since 06/03/2018
@version undefined

@type function*/
Function OGA730ANT(cCodine)

	Local aAreaAtu   := GetArea()	
	Local nPsFrds    := 0//Capturar a quantidade de Fardos para IE
	Local cAliasN9D  := GetNextAlias()
	Local cAliasN9E  := GetNextAlias()
	Local cQueryN9E  := ""
	Local cTemRom    := .F.	
	Local cQuery     := ""
	Local aFrds      := {}
	Local nX         := 0
	Local nY         := 0
	Local cCodCnt 	 := "" //variavel para armazenar o codigo do container
	Local nCont		 := 0
	Local nPesoCnt    := 0 //variavel para armazenar o peso do container
	Local nPos       := 0
	Local nPsMax     := Posicione( "N7Q", 1, xFilial( "N7Q" ) + cCodine, "N7Q_PSCNTR" ) //variavel que armazena o peso maximo do container definido na instrução de embarque
	Local nQtCnt     := 0 //variavel para armazenar a quantidade de containers disponiveis
	Local aQtCnt	 := {} //array para armazenar codigo dos containers
	Local cStaFat    := Posicione( "N7Q", 1, xFilial( "N7Q" ) + cCodine, "N7Q_STAFAT" ) //variavel que armazena se já hoube faturamento da instrução de embarque
	Local aPartLot := {} //array para armazenar dados por filial quando partlot na IE igual a não
	Local nQtdMaxCnt := 0 //variavel para armazenar a qtd/peso maxima para o container
	Local cFilcurr   := ""
	Local aCtrl		 := {}
	Local nPesoRem 	 := 0

	Private  _lPsAcima  := .F. //variavel armazena se tem container com peso acima do peso maximo do container definido na IE
	Private  _cPartL     := Posicione( "N7Q", 1, xFilial( "N7Q" ) + cCodine, "N7Q_PARLOT" ) //variavel que armazena se permite PartLot

	_lProdAlg := ProdAlgCnt(cCodine)

	DbSelectArea("N91")
	DbSetOrder(1)
	If N91->(DbSeek(FwxFilial("N91")+cCodine))
		While N91->( !Eof() ) .And. N91->N91_CODINE == cCodine
			If N91->N91_STATUS == '1' 
				nQtCnt ++
				aadd(aQtCnt, N91->N91_CONTNR) //cria um array com os containers
			EndIf
			N91->(DbSkip())
		EndDo
	EndIf
	//DbCloseArea("N91")

	cQueryN9E := " SELECT DISTINCT N9E.N9E_FILIAL, N9E.N9E_CODROM  "
	cQueryN9E += "     FROM " + RetSqlName("N9E") + " N9E "
	cQueryN9E += " INNER JOIN " + RetSqlName("NJJ") + " NJJ ON NJJ.NJJ_FILIAL = N9E.N9E_FILIAL AND NJJ.NJJ_CODROM = N9E.N9E_CODROM AND NJJ.D_E_L_E_T_ = ' ' AND NJJ.NJJ_STATUS <> '4'"
	cQueryN9E += "    WHERE N9E.N9E_FILIE  = '" + xFilial( "N7Q" ) + "'"
	cQueryN9E += "      AND N9E.N9E_CODINE = '" + cCodIne + "'"
	cQueryN9E += "      AND N9E.D_E_L_E_T_ = ' ' "
	cQueryN9E += "      AND N9E.N9E_ORIGEM = '1' "
	cQueryN9E := ChangeQuery(cQueryN9E)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryN9E),cAliasN9E, .F., .T.) 
	DbselectArea( cAliasN9E)
	DbGoTop()
	If (cAliasN9E)->( !Eof() )
		cTemRom := .T.
	EndIf
	(cAliasN9E)->(DbCloseArea())

	If nQtCnt = 0
		Help(" ", 1, ".OGA730000001.") //#PROBLEMA:Container não encontrado para Instrução de Embarque informada. #Solução: Para gerar estufagem antecipada é necessário cadastrar ao menos um container.
		Return .F.
	ElseIf trim(cStaFat) == '3'

		Help(" ", 1, ".OGA730000003.") //PROBLEMA:A Instrução de Embarque ao qual o(s) container(s) está(ão) vinculado(s) já está Faturada. Certificação Antecipada não permitida! 
		Return .F.
	ElseIf cTemRom 
		Help(" ", 1, ".OGA730000005.") //PROBLEMA:A Instrução de Embarque ao qual o(s) container(s) está(ão) vinculado(s) já possui Romaneio de Exportação. Certificação Antecipada não permitida! 
		Return .F.

	Else
		__lTelaAntec := .T.

		If _lProdAlg  //se algodão

			cQuery := "     SELECT N9D.N9D_FILIAL AS FILIAL, "
			cQuery += " 	       N9D.N9D_SAFRA AS SAFRA, "
			cQuery += " 		   N9D.N9D_BLOCO AS BLOCO, "
			cQuery += " 		   N9D.N9D_CODFAR AS CODFAR, "
			cQuery += " 		   DXI.DXI_PSESTO AS PSESTO, "
			cQuery += " 		   DXI.DXI_PSBRUT AS PSBRUT, "
			cQuery += " 		   DXI.DXI_PSLIQU AS PSLIQU, "
			cQuery += " 		   DXI.DXI_CONTNR AS CONTNR "
			cQuery += "       FROM " + RetSqlName("N9D") + " N9D "
			cQuery += " INNER JOIN " + RetSqlName("DXI") + " DXI ON DXI.DXI_ETIQ = N9D.N9D_FARDO "
			cQuery += "        AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
			cQuery += "        AND DXI.DXI_BLOCO = N9D.N9D_BLOCO "
			cQuery += "        AND DXI.DXI_SAFRA = N9D.N9D_SAFRA "
			cQuery += "        AND DXI.D_E_L_E_T_ = ' '  "
			cQuery += " WHERE N9D.N9D_CODINE =  '" + cCodine + "'" 
			cQuery += "        AND N9D.N9D_TIPMOV = '04' "
			cQuery += "        AND N9D.N9D_STATUS = '2' "
			cQuery += "        AND N9D.D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY N9D.N9D_FILIAL "

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN9D, .F., .T.)
			DbselectArea( cAliasN9D )
			(cAliasN9D)->(DbGoTop())

			While (cAliasN9D)->( !Eof() )
				If Empty((cAliasN9D)->CONTNR)
					If Len(aPartLot) = 0 .OR. (_cPartL == '2' .and. aPartLot[Len(aPartLot)][1] != (cAliasN9D)->FILIAL)
						aFrds := {}
						AADD(aFrds, {(cAliasN9D)->FILIAL, (cAliasN9D)->SAFRA, (cAliasN9D)->BLOCO, (cAliasN9D)->CODFAR, (cAliasN9D)->CONTNR, (cAliasN9D)->PSESTO ,(cAliasN9D)->PSBRUT,(cAliasN9D)->PSLIQU})
						AADD(aPartLot, {(cAliasN9D)->FILIAL,(cAliasN9D)->PSESTO, aFrds})
					Else
						AADD(aFrds, {(cAliasN9D)->FILIAL, (cAliasN9D)->SAFRA, (cAliasN9D)->BLOCO, (cAliasN9D)->CODFAR, (cAliasN9D)->CONTNR, (cAliasN9D)->PSESTO ,(cAliasN9D)->PSBRUT,(cAliasN9D)->PSLIQU})
						aPartLot[Len(aPartLot)][2] += (cAliasN9D)->PSESTO
						aPartLot[Len(aPartLot)][3] := aFrds
					EndIf
					nPsFrds += (cAliasN9D)->PSESTO //Peso total dos fardos da IE
				EndIf
				(cAliasN9D)->(DbSkip())
			EndDo
			(cAliasN9D)->(DbCloseArea())

		Else //se grãos
			cQuery := " SELECT N9I_FILIAL AS FILIAL ,N9I_DOC AS DOC ,SUM(N9I_QTDFIS) AS PSESTO "
			cQuery += " FROM " + RetSqlName("N9I") + " "
			cQuery += " WHERE N9I_CODINE='" + cCodine + "' AND N9I_INDSLD='1' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY N9I_FILIAL,N9I_DOC"

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN9D, .F., .T.)
			DbselectArea( cAliasN9D )
			(cAliasN9D)->(DbGoTop())

			While (cAliasN9D)->( !Eof() )
				If Len(aPartLot) = 0 .OR. (_cPartL == '2' .and. aPartLot[Len(aPartLot)][1] != (cAliasN9D)->FILIAL)
					aFrds := {}
					AADD(aFrds, {(cAliasN9D)->FILIAL,(cAliasN9D)->DOC, , , , (cAliasN9D)->PSESTO ,(cAliasN9D)->PSESTO,(cAliasN9D)->PSESTO})
					AADD(aPartLot, {(cAliasN9D)->FILIAL,(cAliasN9D)->PSESTO, aFrds })
				Else
					AADD(aFrds, {(cAliasN9D)->FILIAL,(cAliasN9D)->DOC, , , , (cAliasN9D)->PSESTO ,(cAliasN9D)->PSESTO,(cAliasN9D)->PSESTO})
					aPartLot[Len(aPartLot)][2] += (cAliasN9D)->PSESTO
					aPartLot[Len(aPartLot)][3] := aFrds
				EndIf
				nPsFrds += (cAliasN9D)->PSESTO //Peso total dos fardos da IE
				(cAliasN9D)->(DbSkip())
			EndDo
			(cAliasN9D)->(DbCloseArea())

		EndIf

		If _cPartL == "2" .and. Len(aPartLot) > nQtCnt 
			Help(" ", 1, ".OGA730000004.") //#PROBLEMA: Não há containers com status disponiveis suficiente para a geração da certificação antecipada! #SOLUÇÂO: É necessário o cadastro de mais containers
			Return .F.
		EndIf

		nCalc	:= 0 //calculo de quantos containers para a filial
		nCont := 0 //contador de container que estão sendo reservados
		aCtrl := {} //variavel de controle para armazenar a posição da filial que teve qtd de container arredondado para cima
		For nY := 1 To Len(aPartLot)
			If _cPartL == "2"
				nCalc := round(((aPartLot[nY][2] / nPsFrds) * nQtCnt),2) 
				If int(nCalc) > 1 .and. round(nCalc,0) > nCalc
					AADD(aCtrl, nY) //armazena a posição da filial que teve qtd de container arredondado para cima
				EndIf
				nCalc := IIF(nCalc < 1, 1 , Round(nCalc,0)) //nCalc = numero de container para atender a qtd da filial
				nCont += nCalc
				//verifica se os container reservado ultrapassam a qtd de container disponivel
				If nCont > nQtCnt .and. Len(aCtrl) > 0 //se o contador ultrapassou a qtd de container disponivel para a estufagem antecipada e tem registro que arredondou qtd cnt para cima
					aPartLot[aCtrl[1]][5] -= 1 //decrementa ex: neste registro deu 1,88 ele arredondou para 2 então aqui decrementa o registro para 1
					nCont -= 1
				EndIf
				//define qtd maxima para estufagem em cada container
				If nPsMax > 0 //se na IE tem limite maximo de peso para o container			
					nQtdMaxCnt := nPsMax 
				Else
					nQtdMaxCnt := round((aPartLot[nY][2] / nCalc),2)
				EndIf
				//grava na filial a qtd maxima do container e qtd de container que a filial precisa para estufagem
				aadd(aPartLot[nY], nQtdMaxCnt) //qtd maxima de estufagem para cada container
				aadd(aPartLot[nY], nCalc) //qtd de container para a filial
			Else	
				//se partlot="sim" - tem compartilhamento do container para mais de uma filial, então aPartLot tem apenas um registro 
				If nPsMax > 0					
					nQtdMaxCnt := nPsMax //Quantidade de fardos a serem estufados em cada container
				Else
					nQtdMaxCnt := nPsFrds / nQtCnt
				EndIf
				AADD(aPartLot[nY], nQtdMaxCnt)
				AADD(aPartLot[nY], nQtCnt)
			EndIf
		Next nY

		If _lProdAlg //se algodão
			nPos := 0 //posição para pegar codigo do container no array aQtCnt
			cFilcurr := ""
			For nY := 1 To Len(aPartLot) //le o array 
				aFrds := aPartLot[nY][3]  //fardos da filial
				nQtdMaxCnt := aPartLot[nY][4] //peso maximo por container para filial
				nCont := 0 //controla qtd de container por filial
				For nX := 1 To Len(aFrds) //le os fardos
					nPesoCnt += aFrds[nX][6] //armazena a qtd no container
					If nX = 1 .OR. ( nPesoCnt > nQtdMaxCnt .and. nCont < aPartLot[nY][5] ) //se qtd no container maior que a qtd maxima e não é o ultimo container da filial então usa outro container
						nPos += 1 //nova posição para pegar outro container
						cCodCnt := aQtCnt[nPos]	//codigo do container			
						AADD(_aCnt, {"2", cCodCnt, aFrds[nX][1], 1, aFrds[nX][6] , nPsMax , 0 ,{ aFrds[nX] }}) //cria novo container com dos dados
						nPesoCnt := aFrds[nX][6] //inicia peso no container
						nCont += 1 //armazena a qtd de container para a filial
						cFilcurr := aFrds[nX][1]
					Else
						If _cPartL == "1" .and. cFilcurr != aFrds[nX][1] //se filial diferente e partLot igual a 1
							_aCnt[nPos, 3] := _aCnt[nPos, 3] + ', ' + aFrds[nX][1] //grava concatenando a filial para mostrar na tela que no container tem mais de uma filial
							cFilcurr := aFrds[nX][1]
						EndIf
						_aCnt[nPos, 4] += 1 //qtd fardos
						_aCnt[nPos, 5] += aFrds[nX][6] //peso do container
						_aCnt[nPos, 6] := nPsMax //peso máximo container
						_aCnt[nPos, 7] := 0 //será usado em tela para receber peso certificação
						AADD(_aCnt[nPos, 8], aFrds[nX]) //array de fardos	
					EndIf

					aFrds[nX][5] := cCodCnt //adiciona o codigo do container no array de fardos
					If nPsMax > 0 .and. nPesoCnt > nPsMax
						_lPsAcima := .T.
					EndIf	

				Next nX
			Next nY
		Else //se grãos
			nPos := 0 //posição para pegar codigo do container no array aQtCnt
			cFilcurr := ""
			For nY := 1 To Len(aPartLot) //le o array
				aFrds := aPartLot[nY][3] //array de notas de remessa para aPartLot
				nCont := 0 //controla qtd de container por aPartLot
				nQtdMaxCnt := aPartLot[nY][4] //peso maximo por container 
				nPesoCnt := 0  //irá armazenar o peso para o container
				nPesoRem := 0  
				While aPartLot[nY][2] > 0
					cFilcurr := ""
					If aPartLot[nY][2] > nQtdMaxCnt
						nPesoCnt := nQtdMaxCnt
					Else
						nPesoCnt := aPartLot[nY][2]
					EndIf

					//### DEFINE A FILIAL PARA O CONTAINER LENDO O ARRAY AFRD QUE TEM AS NOTAS DE REMESSA ###
					While Len(aFrds) > 0
						nX := 1
						If _cPartL == "1" .and. !Empty(cFilcurr) .and. AT(aFrds[nX][1], cFilcurr) = 0 
							cFilcurr := cFilcurr + ', ' + aFrds[nX][1] //concatena filiais quando part lot sim
						ElseIf Empty(cFilcurr)
							cFilcurr := aFrds[nX][1] 
						EndIf

						If (nPesoRem + aFrds[nX][6]) >= nPesoCnt .and. nCont <= aPartLot[nY][5] 
							aFrds[nX][6] += nPesoRem - nPesoCnt //armazena o saldo que ira ficar para o proximo container
							nPesoRem := 0
							If aFrds[nX][6] = 0 //deletta se zero
								aDel(aFrds,nX)
								aSize( aFrds,(Len(aFrds)-1) )
							EndIf
							Exit  //sai do while aFrds
						Else
							nPesoRem := aFrds[nX][6] //armazena peso da remessa para somar com a proxima remessa
							aDel(aFrds,nX)
							aSize( aFrds,(Len(aFrds)-1) )
						EndIf 

					EndDo

					//insere valores no aCnt que armazena os dados por container
					If nCont < aPartLot[nY][5]	//qtd container não ultrapassou a qtd definida para a filial(parlot)
						nPos += 1 //posição para pegar o codigo do container
						cCodCnt := aQtCnt[nPos]	//codigo do container
						AADD(_aCnt, {"2", cCodCnt, cFilcurr, 0, nPesoCnt , nPsMax ,  0 , {} }) //cria novo container com dos dados
						nCont += 1 //soma mais um para a qtd de container para a filial(partlot)
					Else
						//sobrou saldo para colocar em container então coloca no ultimo container da filial(partlot)
						_aCnt[nPos][5] += nPesoCnt
						_aCnt[nPos][3] := cFilcurr
					EndIf
					aPartLot[nY][2] -= nPesoCnt //subtrai o peso inserido do container

				EndDo
			Next nY
		EndIf

	EndIf
	RestArea( aAreaAtu )

Return OGA730TELA(_aCnt,nPsFrds)

/**-------------------------------------------------------------------------------------
{Protheus.doc} OGA730TELA

Função responsável pela interface da tela de Estufagem Antecipada

@author thiago.rover
@since 13/03/2018
@version undefined
@type function 
-------------------------------------------------------------------------------------**/

Static Function OGA730TELA(aAux, nPeso)

	Local aAreaAtu      := GetArea()
	Local oSize         := Nil
	Local oDlg          := Nil
	Local oStO          := LoadBitmap( GetResources(), "LBNO" )//"unchecked_15" )	//--Sem Seleção
	Local oStX          := LoadBitmap( GetResources(), "LBOK" )//"checked_15" )		//--Com Seleção
	Local aButtons      := {}
	Local nOpcao        := 0

	Local oBrowse     := Nil
	Private _nPsCertAnt   := nPeso //N7Q->N7Q_TOTLIQ

	Default aAux        := {}

	oSize := FwDefSize():New()
	oSize:AddObject( "P1", 100, 20, .t., .t., .t. )
	oSize:AddObject( "P2", 100, 80, .t., .t., .t. )
	oSize:lProp     := .t.
	oSize:aMargins  := { 3, 3, 3, 3 }
	oSize:Process()

	oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], STR0031 ,,,,,CLR_BLACK,CLR_WHITE,,,.t.)

	oPnUm   := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" ),oSize:GetDimension( "P1", "YSIZE" ) )
	oPnDois := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ),oSize:GetDimension( "P2", "YSIZE" ) )

	oBrowse := TCBrowse():New( 01, 01, 250, 150, , , ,oPnDois , , , , , , , , , , , , .f., ,.t., , .f. )

	TSay():New( 020, 200, {|| OemToAnsi( STR0030 ) }		, oPnUm, , , , , , .t., CLR_BLACK, CLR_WHITE, 050, 020 )
	TGet():New( 030, 200,bSetGet(_nPsCertAnt), oPnUm,096,010,"@E 99,999,999,999.9999", { || .t. },,,, .f., , .t., , .f., { || .t. }, .f., .f.,, .f., .f., ,"_nPsCertAnt")

	TButton():New(030, 300, STR0032 ,oPnUm,{|| BotaoCalc(aAux)},,,,,,.T.,,) //"Calcular"###"Calcular"

	//Colunas
	oBrowse:AddColumn( TCColumn():New( " " 		, { || IIf( aAux[oBrowse:nAt, 1] == "1", oStO, oStX ) }   ,                            ,,,"CENTER"    , 010,.t.,.t.,,,,.f.,) ) //"MarkAll"
	oBrowse:AddColumn( TCColumn():New( STR0033  , { || aAux[oBrowse:nAt, 2]                                            }   ,                            ,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Nome Container" 
	oBrowse:AddColumn( TCColumn():New( STR0034  , { || aAux[oBrowse:nAt, 3]                                            }   ,                            ,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Filial Origem"
	oBrowse:AddColumn( TCColumn():New( STR0035  , { || aAux[oBrowse:nAt, 4]                                            }   ,                            ,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Qtd Fardos"
	oBrowse:AddColumn( TCColumn():New( STR0036  , { || aAux[oBrowse:nAt, 5]                                            }   ,PesqPict('N91','N91_QTDCER'),,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Peso Referência"
	oBrowse:AddColumn( TCColumn():New( STR0055  , { || aAux[oBrowse:nAt, 6]                                            }   ,PesqPict('N7Q','N7Q_PSCNTR'),,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Peso Máximo Container"
	oBrowse:AddColumn( TCColumn():New( STR0037  , { || aAux[oBrowse:nAt, 7]                                            }   ,PesqPict('N91','N91_QTDCER'),,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Peso Certificado Antecipado"

	oBrowse:SetArray( aAux )
	oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	bValida := {|| .T. }
	oBrowse:bLDblClick	:= {|| MarcaUm( @oBrowse, aAux, @oBrowse:nAt ) }
	oBrowse:bHeaderClick := {|| MarcaTudo( @oBrowse, aAux,  @__lMarcAllE) }
	oBrowse:Refresh(.T.)

	oDlg:Activate( , , , .t., bValida, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, ExecGrav(oDlg, @oBrowse)},{|| nOpcao := 2, oDlg:End() },, @aButtons ) } )

	_aCnt := {}

	RestArea( aAreaAtu )

Return .T.

/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaUm

Função responsável por marcar/desmarcar um item clicado
@author: 	thiago.rover
@since: 	06/03/2018
-------------------------------------------------------------------------------------**/
Static Function MarcaUm( oBrowse,aItsMrk, nLinMrk )

	DO CASE      

		CASE aItsMrk[ nLinMrk, 1 ] == "1"
		aItsMrk[ nLinMrk, 1 ] := "2"

		CASE aItsMrk[ nLinMrk, 1 ] == "2"
		aItsMrk[ nLinMrk, 1 ] := "1"

	ENDCASE

	oBrowse:Refresh()

Return( )

/**-------------------------------------------------------------------------------------
{Protheus.doc} MarcaTudo
Marca/Desmarca Todos

@author: 	thiago.rover
@since: 	06/03/2018
-------------------------------------------------------------------------------------**/
Static Function MarcaTudo( oBrowse, aItsMrk, lMark )
	Local nX	:= 0

	For nX := 1 to Len( aItsMrk )                 

		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrowse:Refresh()

	lMark := !lMark

Return( )

/*/{Protheus.doc} BotaoCalc
//TODO Função encarregada em calcular e setar o valor no campo estufagem antecipada de acordo
com o markBrowse
@author thiago.rover
@since 12/03/2018
@version 1.0
@param aItsMrk, array, array com os itens da tela
@type function
/*/
Function BotaoCalc(aItsMrk)
	Local nX	    := 0
	Local nPesoEst	:= 0 //peso estoque
	Local nPerc		:= 0 //percentual para rateio peso certificação
	Local nPsRatCnt	:= 0 //peso rateado do container
	Local nPsCtrl	:= 0
	Local nCntSel	:= 0
	Local nPsMax    := Posicione( "N7Q", 1, xFilial( "N7Q" ) + N91->N91_CODINE, "N7Q_PSCNTR" ) //variavel que armazena o peso maximo do container definido na instrução de embarque

	//Estrutura de repetição para obter a soma do peso estoque dos registros selecionados
	For nX := 1 to Len( aItsMrk )

		If aItsMrk[ nX, 1 ] == "2"
			//nNumero += 1
			nPesoEst += aItsMrk[ nX, 5 ]
			nCntSel += 1 //numero de container selecionado
		EndIf

	Next nX

	If _lProdAlg .or. nPsMax = 0 //se algodão
		//Estrutura que valida se o container está marcado e divide proporcional o peso certificado 
		For nX := 1 to Len( aItsMrk )

			If nPesoEst = _nPsCertAnt
				aItsMrk[ nX, 7 ] := aItsMrk[ nX, 5 ]
			Else
				nPerc  := (aItsMrk[ nX, 5 ] / nPesoEst)*100 //percentual do container em relação ao peso estoque de todos os container selecionados 
				nPsRatCnt := round( (_nPsCertAnt * (nPerc/100)) , TamSX3("N91_QTDCER")[2]) //Peso rateio do container		
				If aItsMrk[ nX, 1 ] == "2"
					nPsCtrl += nPsRatCnt
					If nX = Len( aItsMrk ) .AND. nPsCtrl <> _nPsCertAnt //ajuste caso porcentagem calcular frações acima ou abaixo então o ultimo recebe a diferença
						nPsRatCnt += _nPsCertAnt - nPsCtrl
					EndIf
					aItsMrk[ nX, 7 ] := nPsRatCnt
				EndIf
			EndIf

			If nPsMax > 0 .and. aItsMrk[ nX, 7 ] > nPsMax
				_lPsAcima := .T.
			Else
				_lPsAcima := .F.
			EndIf

		Next nX
	Else //se grãos e tem capacidade maxima do container definido na IE
		nPsCtrl := _nPsCertAnt
		_lPsAcima := .F.

		For nX := 1 to Len( aItsMrk )
			If aItsMrk[ nX, 1 ] == "2" 				
				If nPsCtrl < nPsMax .and.  nX < Len( aItsMrk ) .and. aItsMrk[ nX, 5 ] <= nPsCtrl
					aItsMrk[ nX, 7 ] := aItsMrk[ nX, 5 ]
					nPsCtrl -= aItsMrk[ nX, 7 ] //subtrai o que ja foi colocado no container
				ElseIf nPsCtrl < nPsMax .or. nX = Len( aItsMrk )
					aItsMrk[ nX, 7 ] := nPsCtrl
					nPsCtrl := 0 //subtrai o que ja foi colocado no container
				ElseIf nPsCtrl < aItsMrk[ nX, 5 ] .And.  nPsCtrl >= nPsMax
					aItsMrk[ nX, 7 ] := nPsCtrl
					nPsCtrl := 0 //subtrai o que ja foi colocado no container
				ElseIF nPsCtrl >= nPsMax 
					aItsMrk[ nX, 7 ] := aItsMrk[ nX, 5 ]
					nPsCtrl -= aItsMrk[ nX, 7 ] //subtrai o que ja foi colocado no container
				EndIf				
			EndIf

			If nPsMax > 0 .and. aItsMrk[ nX, 7 ] > nPsMax
				_lPsAcima := .T.
			EndIf

		Next nX
	EndIf

Return .T.

/*/{Protheus.doc} ExecGrav
//TODO Tela expecifica para chamar o processo de gravação da certificação antecipada 
@author thiago.rover
@since 14/03/2018
@version 1.0
@param oDlg, object, descricao
@param oBrowse, object, descricao
@type function
/*/
Static Function ExecGrav(oDlg, oBrowse)
	Local lRet    := .T.

	If _lPsAcima //se tiver container com peso acima do peso maximo do container definido na instrução de embarque

		Help(" ", 1, ".OGA730000002.")
		lRet := .F.  //não permite salvar os dados da tela

	Else

		oProcess := MsNewProcess():New( { | lEnd | lRet := OGA730GRV()}, "Aguarde", "Gerando Estufagem antecipada", .F. ) //"Aguarde"###"Gerando Estufagem antecipada"
		oProcess:Activate()

	EndIf

	If lRet //se true/verdadeiro fecha tela 
		oDlg:End()
	EndIf

Return

/*/{Protheus.doc} MovFard
//TODO Função que gera o movimento do fardo do tipo Certificação de Peso - Antecipada
@author janaina.duarte
@since 17/03/2018
@version 1.0

@type function
/*/
Static Function MovFard()
	Local nX        := 0
	Local nY        := 0
	Local cEtiqueta := ''
	Local cCodine   := ''
	Local cRomaneio := ''
	Local cLocal    := ''
	Local cEntidade := ''
	Local cLoja     := ''
	Local dPesoF    := 0
	Local dPesoI    := 0
	Local cRegFis   := '' 
	Local lRet      := .T.

	//Gera o movimento do fardo referente à estufagem antecipada
	For nX := 1 To Len(_aCnt)  //percorre os containers
		For nY := 1 To Len(_aCnt[nX,8]) //percorre os fardos desse container

			DbSelectArea("DXI")
			DbSetOrder(7)
			If DbSeek(_aCnt[nX, 8, nY, 1] + _aCnt[nX, 8, nY, 2] + _aCnt[nX, 8, nY, 4]) //Filial+Safra+Fardo
				cEtiqueta := DXI->DXI_ETIQ
				cCodine   := DXI->DXI_CODINE
				cRomaneio := DXI->DXI_ROMFLO  //Romaneio de Remessa de Lote
				dPesoF    := DXI->DXI_PESCER  //Peso do Rateio
			endIf

			//Se já existir o movimento do fardo de estufagem antecipada, exclui primeiro, para depois gerar novamente
			DbSelectArea("N9D")
			DbSetOrder(5)
			DbSeek(_aCnt[nX, 8, nY, 1]+_aCnt[nX, 8, nY, 2]+cEtiqueta+'05'+'2') //Filial+Safra+Etiq Fardo+Tip Mov+Status
			While !N9D->(Eof()) .AND. _aCnt[nX, 8, nY, 1]+_aCnt[nX, 8, nY, 2]+cEtiqueta+'05'+'2' == ;
			N9D->N9D_FILIAL + N9D->N9D_SAFRA + N9D->N9D_FARDO + N9D->N9D_TIPMOV + N9D_STATUS 
				If AllTrim(N9D->N9D_TIPOPE) == '2'  //1-Física 2-Antecipada
					Reclock("N9D",.F.)
					N9D->(DbDelete())
					N9D->(MsUnlock())
				EndIf
				N9D->(DbSkip())
			EndDo

			DbSelectArea("N7Q")
			DbSetOrder(1)
			If DbSeek(xFilial("N7Q") + cCodine) //Filial+Instrução Embarque
				cLocal    := N7Q->N7Q_LOCAL
				cEntidade := N7Q->N7Q_ENTENT
				cLoja     := N7Q->N7Q_LOJENT			
			endIf

			dPesoI    := _aCnt[nX, 8, nY, 6]  //Peso Estoque
			cRegFis   := Posicione( "N9D", 2, _aCnt[nX, 8, nY, 1]+FWxFilial("N91")+_aCnt[nX, 8, nY, 2]+_aCnt[nX, 8, nY, 4]+"02"+"2", "N9D_ITEREF" )

			aFardos:= 	{{  {"N9D_FARDO"	, cEtiqueta          	},; //Etiqueta do Fardo
			{"N9D_TIPMOV"	,"05"					},; // 05-Certificação de Peso
			{"N9D_PESINI"	,dPesoI   				},; //Peso Ini
			{"N9D_PESFIM"	,dPesoF 	    		},; //Peso Fim
			{"N9D_PESDIF"	,dPesoF - dPesoI 		},; //Diferença de Peso
			{"N9D_LOCAL"	,cLocal            		},; //Local
			{"N9D_ENTLOC"	,cEntidade				},; //Entidade
			{"N9D_LOJLOC"	,cLoja           		},; //Loja
			{"N9D_DATA"	    ,dDatabase 				},; //Data
			{"N9D_STATUS"	,"2"                 	},; //Status
			{"N9D_CODROM"	,cRomaneio        		},; //Romaneio
			{"N9D_CODINE"   ,cCodine       		    },; //Instrução de Embarque
			{"N9D_ITEREF"	,cRegFis	 	        },; //Regra Fiscal 
			{"N9D_FILIAL"	,_aCnt[nX, 8, nY, 1]	},; //Filial DO FARDO
			{"N9D_FILORG"	, FWxFilial("N91")		},; //Filial de origem do movimento do fardo
			{"N9D_SAFRA"	,_aCnt[nX, 8, nY, 2]  	},; //Safra
			{"N9D_CONTNR"	,_aCnt[nX, 8, nY, 5]	},; //Container
			{"N9D_CODFAR"	,_aCnt[nX, 8, nY, 4]    },; //Fardo      
			{"N9D_BLOCO"	,_aCnt[nX, 8, nY, 3]	},; //Bloco
			{"N9D_TIPOPE"	,"2"					}}} //2-Estufagem Antecipada
			aRet := AGRMOVFARD(aFardos, 1, 2 ) 
		Next nY
	Next nX

Return lRet

/*/{Protheus.doc} OGA730GRV
//TODO Validação da confirmação dos dados da janela de certificação antecipada
@author thiago.rover / claudineia.reinert
@since 11/07/2018
@version P12 - 02

@type function
/*/
Static Function OGA730GRV()

	Local aArea	    := GetArea()
	Local aAreaN91	:= N91->(GetArea())
	Local nI	    := 0
	Local nX		:= 0
	Local lRet		:= .T.
	Local nQtdRemov	:= 0 //armazena a qtd antecipada anterior, caso refaça a certificação antecipada
	Local nQtdAntec	:= 0 // armazena a qtd antecipada atual(nova)
	Local aFardos	:= {}
	Local aN9I		:= {}
	Local cCodIE	:= N91->N91_CODINE

	Begin Transaction

		//Limpa campo quantidade antecipada do movimento tipo '1'
		DbSelectArea("N9I")
		N9I->(DbSetOrder(3))
		If N9I->(dbSeek( "1" + N91->N91_FILIAL + N91->N91_CODINE) )
			While N9I->( !Eof() ) .AND.  N9I->N9I_INDSLD = '1' .AND. N9I->N9I_FILORG == N91->N91_FILIAL .AND. N9I->N9I_CODINE == N91->N91_CODINE 
				If RecLock( "N9I", .F. )
					N9I->N9I_QTDANT := 0
					N9I->( msUnLock() )
				EndIf
				N9I->(DbSkip())
			EndDo
		EndIf
		N9I->(DbCloseArea())

		If !_lProdAlg			

			//Para grãos, elimina vínculo movimento antecipado x conteiner, caso já exista 
			DbSelectArea("N9I")
			DbSetOrder(3)
			If N9I->(dbSeek( "3" + N91->N91_FILIAL + N91->N91_CODINE ) )

				While N9I->( !Eof() ) .AND. N9I->N9I_INDSLD = '3' .AND. N9I->N9I_FILORG == N91->N91_FILIAL .AND. N9I->N9I_CODINE == N91->N91_CODINE
					If RecLock( "N9I", .F. )
						N9I->(DbDelete())
						N9I->( msUnLock() )
					EndIf
					N9I->(DbSkip())
				EndDo
			EndIf

		ElseIf __lTelaAntec 

			// Ao estufar container antecipado de algodão deve gravar a quantidade antecipada sem ganho de peso para movimento tipo '1'
			DbSelectArea("N9I")
			For nI := 1 To Len(_aCnt)
				aFardos := _aCnt[nI][8] //array dos fardos do container
				If _aCnt[nI][7] > 0 //se container tem valor para antecipada
					For nX := 1 To Len(aFardos) //lê os fardos do container
						aN9I := DOCN9IFRD(N91->N91_CODINE, aFardos[nX]) //busca recno N9I e peso do fardos
						If Len(aN9I) > 0 .AND. aN9I[1] > 0 //tem recno 
							N9I->(dbGoto(aN9I[1])) //posiciona pelo recno
							If RecLock("N9I", .F.)
								N9I->N9I_QTDANT += aN9I[2] //recebe peso do fardo referente a remessa
								N9I->(MsUnlock())
							EndIf
						EndIf
					Next nX
				EndIf
			Next nI  

			//Quando estufagem antecipada, limpa quantidade estufada de todos os containers
			dbSelectArea("N91")
			N91->(dbSetOrder(1)) //FILIAL+CODINE
			If N91->(dbSeek(FwxFilial("N91") + cCodIE )) 
				While N91->(!EoF()) .AND. N91->N91_CODINE == cCodIE
					If RecLock( "N91", .F. )
						N91->N91_QTDANT := 0
						N91->( msUnLock() )
					EndIf
					N91->(DbSkip())
				EndDo			
			EndIf
			RestArea(aAreaN91) //Restaura area da N91 inicial, para não perder a posição

		EndIF

		For nI := 1 To Len(_aCnt)
			dbSelectArea("N91")
			N91->(dbSetOrder(1)) //FILIAL+CODINE
			N91->(dbSeek(FwxFilial("N91") + N91->N91_CODINE + _aCnt[nI][2])) 	

			If RecLock( "N91", .F. )
				IF _cPartL == '2' .AND. _aCnt[nI][7] > 0
					N91->( N91_FILORG ) := _aCnt[nI][3]
				Else
					N91->( N91_FILORG ) := ''
				EndIf
				nQtdRemov += N91->( N91_QTDANT ) //qtd antecipada ja realizada anteriormente
				N91->( N91_QTDANT ) := _aCnt[nI][7] //novo valor da qtd antecipada no container
				nQtdAntec += _aCnt[nI][7] //qtd antecipada atual
				N91->( msUnLock() )
			EndIf

			If !_lProdAlg 
				//Vincula nota de remessa para grãos
				If !OG730CTNREM('3', N91->N91_CONTNR, N91->N91_CODINE, N91->N91_QTDANT, N91->N91_FILORG )
					lRet := .F.
					Help( , , STR0019, , STR0054, 1, 0 ) //"Ajuda"###"IE não possui Nota(s) de Remessa com saldo suficiente"
					Exit
				EndIf
			EndIF
		Next nI

		If lRet
			CertAtuIE(N91->N91_CODINE)
			If _lProdAlg 
				//SE ALGODÃO
				RatFrdCnt() //chama função para rateio dos fardos
				lRet := MovFard()
				OG250EAQIE('05', N91->N91_FILIAL, N91->N91_CODINE)
			EndIf
		EndIF

		If !lRet
			DisarmTransaction()
		EndIf

	End Transaction

	RestArea(aAreaN91)
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} OGA730CANT
//TODO Função responsavel por montar o array co os fardos estufados antecipadamente no conteiner posicionado e chamar a tela de consultaDescrição auto-gerada.
@author rafael.kleestadt
@since 16/03/2018
@version 1.0
@param cCodine, characters, Código da instrução de embarque
@param cContNr, characters, Código do contêiner posicionado
@type function
@see http://tdn.totvs.com/pages/editpage.action?pageId=318604330
/*/
Function OGA730CANT(cCodine, cContNr)
	Local cAliasN9D := GetNextAlias()
	Local cQuery    := ""
	Local aFrds     := {}

	If !ValTipProd() //Tipo de commodity Algodão

		//Busca os contêineres conforme movimento dos fardos e agrupa por contêiner e filial de origem
		cQuery := "   SELECT N9D.N9D_FILIAL, "
		cQuery += "          N9D.N9D_CODINE, "
		cQuery += "          N9D.N9D_SAFRA, "
		cQuery += "          N9D.N9D_BLOCO, "
		cQuery += "          N9D.N9D_FARDO, "
		cQuery += "          N9D.N9D_CODFAR, "
		cQuery += "          DXI.DXI_PSBRUT, "
		cQuery += "          DXI.DXI_PSLIQU, "
		cQuery += "          DXI.DXI_PESSAI, "
		cQuery += "          NJM.NJM_DOCSER, "
		cQuery += "			 NJM.NJM_DOCNUM, "
		cQuery += "          DXI.DXI_PESCHE, "
		cQuery += "          DXI.DXI_PESCER "     
		cQuery += "     FROM " + RetSqlName('N9D') + " N9D "
		cQuery += "    INNER JOIN " + RetSqlName('DXI') + " DXI ON DXI.DXI_ETIQ = N9D.N9D_FARDO AND DXI.D_E_L_E_T_ = ' ' AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
		cQuery += "    INNER JOIN "+ RetSqlName("NJJ") +" NJJ ON NJJ.D_E_L_E_T_ = ' ' AND NJJ.NJJ_FILIAL = N9D.N9D_FILIAL AND NJJ.NJJ_CODROM = N9D.N9D_CODROM AND NJJ.NJJ_STATUS = '3' "
		cQuery += "     LEFT OUTER JOIN "+ RetSqlName("NJM") +" NJM ON NJM.D_E_L_E_T_ = ' ' AND NJM.NJM_FILIAL = NJJ.NJJ_FILIAL AND NJM.NJM_CODROM = NJJ.NJJ_CODROM  "
		cQuery += "    WHERE N9D.N9D_CODINE = '" + cCodine + "' "
		cQuery += "      AND N9D.N9D_CONTNR = '" + cContNr + "' " 
		cQuery += "      AND N9D.N9D_TIPMOV = '05' "
		cQuery += "      AND N9D.N9D_STATUS = '2' "
		cQuery += "      AND N9D.N9D_TIPOPE = '2' "
		cQuery += "      AND N9D.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY N9D.N9D_FILIAL, N9D.N9D_CODINE, N9D.N9D_BLOCO, N9D.N9D_CODFAR "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN9D, .F., .T.)
		DbselectArea( cAliasN9D )
		(cAliasN9D)->(DbGoTop())
		If (cAliasN9D)->(!EoF())
			While (cAliasN9D)->(!EoF())

				aAdd(aFrds, {(cAliasN9D)->(N9D_FILIAL), (cAliasN9D)->(N9D_CODINE), (cAliasN9D)->(N9D_SAFRA), ;
				(cAliasN9D)->(N9D_BLOCO),  (cAliasN9D)->(N9D_FARDO),  (cAliasN9D)->(N9D_CODFAR),;
				(cAliasN9D)->(DXI_PSBRUT), (cAliasN9D)->(DXI_PSLIQU), (cAliasN9D)->(DXI_PESSAI),;
				(cAliasN9D)->(NJM_DOCSER), (cAliasN9D)->(NJM_DOCNUM), (cAliasN9D)->(DXI_PESCHE),;
				(cAliasN9D)->(DXI_PESCER)})

				(cAliasN9D)->(dbSkip())
			End
		EndIf
		(cAliasN9D)->(dbCloseArea())

	Else

		OGC130("N9I_CODINE='"+cCodIne+"' .And. N9I_CONTNR = '"+cContNr+"' .And. N9I_INDSLD = '3'")
		Return .T.
	EndIf


Return TelConAnt(aFrds)

/*/{Protheus.doc} TelConAnt
//TODO Função que mostra a tela com os fardos estufados antecipadamente no contêiner posicionado
@type  Function
@author rafael.kleestadt
@since 16/03/2018
@version 1.0
@param aFrds, array, array com os fardos a serem exibidos na tela
@return return, return_type, return_description
@see (http://tdn.totvs.com/pages/viewpage.action?pageId=338377171)
/*/
Static Function TelConAnt(aFrds)
	Local aAreaAtu  := GetArea()
	Local oSize     := Nil
	Local oDlg      := Nil
	Local nOpcao    := 0
	Local aButtons  := {}

	Private oBrowse := Nil
	Default aFrds   := {}

	oSize := FwDefSize():New()
	oSize:Process()

	oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], STR0038,,,,,CLR_BLACK,CLR_WHITE,,,.t.)

	oBrowse := TCBrowse():New( 01, 01, 250, 150, , , , , , , , , , , , , , , , .f., ,.t., , .f. )

	//Colunas
	oBrowse:AddColumn( TCColumn():New(STR0039 , { || aFrds[oBrowse:nAt,1] }									 , , , , "LEFT" , 020, .f., .t., , , , .f., ) ) //"Filial"
	oBrowse:AddColumn( TCColumn():New(STR0040 , { || aFrds[oBrowse:nAt,2] }									 , , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"IE"
	oBrowse:AddColumn( TCColumn():New(STR0041 , { || aFrds[oBrowse:nAt,3] }									 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Safra"
	oBrowse:AddColumn( TCColumn():New(STR0042 , { || aFrds[oBrowse:nAt,4] }									 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Bloco"
	oBrowse:AddColumn( TCColumn():New(STR0043 , { || aFrds[oBrowse:nAt,5] }									 , , , , "LEFT" , 060, .f., .t., , , , .f., ) ) //"Etiqueta"
	oBrowse:AddColumn( TCColumn():New(STR0044 , { || aFrds[oBrowse:nAt,6] }									 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Código"
	oBrowse:AddColumn( TCColumn():New(STR0045 , { || Transform( aFrds[oBrowse:nAt,7], "@E 999,999,999.99" ) }, , , , "RIGHT", 040, .f., .t., , , , .f., ) ) //"Peso Bruto"
	oBrowse:AddColumn( TCColumn():New(STR0046 , { || Transform( aFrds[oBrowse:nAt,8], "@E 999,999,999.99" ) }, , , , "RIGHT", 040, .f., .t., , , , .f., ) ) //"Peso Líquido"
	oBrowse:AddColumn( TCColumn():New(STR0047 , { || Transform( aFrds[oBrowse:nAt,9], "@E 999,999,999.99" ) }, , , , "RIGHT", 040, .f., .t., , , , .f., ) ) //"Peso Saída"
	oBrowse:AddColumn( TCColumn():New(STR0048 , { || aFrds[oBrowse:nAt,10] }								 , , , , "LEFT" , 030, .f., .t., , , , .f., ) ) //"Série NF"
	oBrowse:AddColumn( TCColumn():New(STR0049 , { || aFrds[oBrowse:nAt,11] }								 , , , , "LEFT" , 040, .f., .t., , , , .f., ) ) //"Número NF"
	oBrowse:AddColumn( TCColumn():New(STR0050 , { || Transform( aFrds[oBrowse:nAt,12],"@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Chegada"
	oBrowse:AddColumn( TCColumn():New(STR0051 , { || Transform( aFrds[oBrowse:nAt,13],"@E 999,999,999.99" ) }, , , , "RIGHT", 050, .f., .t., , , , .f., ) ) //"Peso Certificado"

	oBrowse:SetArray( aFrds )
	oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	bValida := {|| .T. }
	oBrowse:Refresh(.T.)

	oDlg:Activate( , , , .t., bValida, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, oDlg:End()},{|| nOpcao := 2, oDlg:End() },, @aButtons ) } )

	RestArea( aAreaAtu )

Return .T.

/*/{Protheus.doc} OGA730FST
//TODO Função para ajustar o Status do CNT conforme nova Flag "Entufagem Finalizada?"
@type  Function
@author rafael.kleestadt
@since 20/04/2018
@version 1.0
@return True, logical, True or False.
/*/
Function OGA730FST()
	Local oModel := FwModelActive()
	Local oN91	 := oModel:GetModel( "N91UNICO" )

	If "N91_STUFIN" $ ReadVar()
		If oN91:Getvalue("N91_STUFIN") == "2" //Não
			If oN91:Getvalue("N91_STATUS") $ "3|4"
				oN91:Setvalue("N91_STATUS", "2") //Em Estufagem
			EndIf
		Else //Sim
			If oN91:Getvalue("N91_STATUS") == "2"
				oN91:Setvalue("N91_STATUS", "3") //Estufado
			EndIf
		EndIf
	ElseIf "N91_STATUS" $ ReadVar()
		If oN91:Getvalue("N91_STATUS") == "1"
			oN91:LoadValue("N91_STUFIN", "2")
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} OGA730NREM
//TODO Função que abre a tela de Painel de Saldos de Nota de Remessa
@author tamyris.g
@since 02/05/2018
@version 1.0
@param cCodIne, characters, Codigo da Instrução de embarque
@param cContNr, characters, Codigo do container
@type function
/*/
Function OGA730NREM(cCodIne, cContNr)

	Local cFilter := "N9I_CODINE='"+cCodIne+"' .And. N9I_CONTNR = '"+cContNr+"' .And. N9I_INDSLD <> '3'" 

	OGC130(cFilter)

Return .T.

/*/{Protheus.doc} OG730CTNREM
//TODO Vínculo das notas de remessa com containers da IE
@author tamyris.g
@since 09/05/2018
@version 1.0
@param cOper, characters, identificador da operação (2-Estufagem Física, 3-Estufagem Antecipada)
@param cCodCtn, characters, Código do Conteiner
@param cCodIne, characters, Código da IE
@param cQtdCert, characters, Quantidade do Conteiner (Certificada/Certificada Antecipada)
@param cFilOrg, characters, Filial quando Part Lote = Não
@type function
/*/
Function OG730CTNREM(cOper, cCodCtn, cCodIne, cQtdCert, cFilOrg )

	Local nQtdSoma := 0
	Local nQtdVinc := cQtdCert
	Local nQtdSldo := cQtdCert
	Local cPartL   := Posicione( "N7Q", 1, xFilial( "N7Q" ) + cCodine, "N7Q_PARLOT" ) //variavel que armazena se permite PartLot
	Local cFilCont := '' 
	Local lSaldo   := .F.

	// Monta a query de busca
	cQuery := " WHERE N9I.N9I_CODINE = '"+cCodIne+"' "
	cQuery += "   AND N9I.N9I_CONTNR = '' "
	cQuery += "   AND N9I.N9I_INDSLD = '1' "
	cQuery += "   AND N9I.N9I_QTDFIS > 0 "
	If cOper == '3' //Estufagem antecipada
		cQuery += "   AND N9I.N9I_QTDFIS > N9I.N9I_QTDANT  "
	EndIf
	If !Empty(cFilOrg) .And. cPartL == '2' //Estufagem antecipada e não Partilha Lote
		cQuery += "   AND N9I.N9I_FILIAL = '"+cFilOrg+"' "
	EndIF
	cQuery += "   AND N9I.D_E_L_E_T_ = ' ' "

	/*--- Valida Saldo Remessa Remessa ****/ 

	If cOper == '3' //Estufagem antecipada
		If cPartL == '1' //Partilha Lote
			cQuery1 := "SELECT SUM(N9I_QTDFIS - N9I_QTDANT ) AS QTDREM FROM " + RetSqlName("N9I") + " N9I "
		Else //Não partilha Lote
			cQuery1 := "SELECT N9I_FILIAL, SUM(N9I_QTDFIS - N9I_QTDANT ) AS QTDREM FROM " + RetSqlName("N9I") + " N9I "
		EndIF
	Else
		If cPartL == '1' //Partilha Lote
			cQuery1 := "SELECT SUM(N9I_QTDFIS) AS QTDREM FROM " + RetSqlName("N9I") + " N9I "
		Else //Não partilha Lote
			cQuery1 := "SELECT N9I_FILIAL, SUM(N9I_QTDFIS) AS QTDREM FROM " + RetSqlName("N9I") + " N9I "
		EndIF

	EndIF

	cQuery1 += cQuery

	If cPartL == '1' //Partilha Lote
		cQuery1 += "  GROUP BY  N9I.N9I_CODINE "
	Else //Não partilha Lote
		cQuery1 += "  GROUP BY  N9I.N9I_FILIAL "
	EndIF

	cQuery1:= ChangeQuery(cQuery1)
	cAliasN9I := GetNextAlias()

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery1),cAliasN9I,.F.,.T.)
	If (cAliasN9I)->(!EoF())

		While (cAliasN9I)->(!EoF()) .and. !lSaldo

			If (cAliasN9I)->QTDREM >= cQtdCert   
				lSaldo := .T.

				If cPartL == '2' //Não partilha lote 
					cFilCont := (cAliasN9I)->N9I_FILIAL 
					If Empty(cFilOrg)
						cFilOrg := cFilCont
					EndIf
				EndIf 
			EndIf

			(cAliasN9I)->(dbSkip())
		EndDo
	EndIF
	(cAliasN9I)->(dbCloseArea())	

	//Se não partilha lote e não encontrou filial com saldo ou partilha lote e não tem saldo
	If !lSaldo
		Return .F.
	EndIF
	/*--- Fim Valida Remessa ****/ 

	/*---Busca Notas de Remessa para vincular ao Container ****/ 
	cQuery2 := "SELECT N9I_DOCEMI,N9I_FILIAL, N9I_DOC, N9I_SERIE, N9I_CLIFOR, N9I_LOJA, N9I_ITEDOC, N9I_FILORG, N9I_QTDFIS, (N9I_QTDFIS - N9I_QTDANT ) AS SDOANT FROM " + RetSqlName("N9I") + " N9I "
	cQuery2 += cQuery
	If cPartL == '2' //se não partilha lote
		cQuery2 += "AND N9I.N9I_FILIAL = '"+cFilCont+"' "
	EndIF
	cQuery2 += " ORDER BY N9I.N9I_DOCEMI,  N9I.N9I_FILIAL, N9I.N9I_DOC   "

	cQuery2 := ChangeQuery(cQuery2)
	cAliasN9I := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),cAliasN9I,.F.,.T.)

	If (cAliasN9I)->(!EoF())
		While (cAliasN9I)->(!EoF())

			nQtdVinc := nQtdSldo

			If cOper =='3' .And. nQtdSldo > (cAliasN9I)->SDOANT 
				nQtdVinc := (cAliasN9I)->SDOANT
			EndIf
			If cOper <>'3' .And. nQtdSldo > (cAliasN9I)->N9I_QTDFIS 
				nQtdVinc := (cAliasN9I)->N9I_QTDFIS
			EndIf

			If nQtdSoma >= cQtdCert    
				Exit
			Else
				//Salva container na N9I
				OG710AGN9I((cAliasN9I)->N9I_FILIAL, (cAliasN9I)->N9I_DOC, (cAliasN9I)->N9I_SERIE, (cAliasN9I)->N9I_CLIFOR, (cAliasN9I)->N9I_LOJA, (cAliasN9I)->N9I_ITEDOC, cOper, (cAliasN9I)->N9I_FILORG, cCodIne, cCodCtn, nQtdVinc )
				nQtdSoma += nQtdVinc 
				nQtdSldo -= nQtdVinc
			EndIf
			(cAliasN9I)->(dbSkip())
		EndDo
	EndIf
	(cAliasN9I)->(dbCloseArea())	

Return .T.

/*/{Protheus.doc} DOCN9IFRD
//TODO Busca o R_E_C_N_O_ da tabela N9I referente ao fardo e o peso do fardo na Remessa
@author claudineia.reinert
@since 11/07/2018
@version undefined
@param cCodIE, characters, descricao
@param aFardo, array, descricao
@type function
/*/
Static Function DOCN9IFRD(cCodIE, aFardo)
	Local aN9I 		:= {}
	Local cQry 	    := ""
	Local cAliasQry := GetNextAlias()

	cQry := " SELECT N9I.R_E_C_N_O_ AS RECNO, N9D.N9D_PESFIM AS PESO  " 
	cQry += " FROM " + RetSqlName("N9D") + " N9D  "
	cQry += " INNER JOIN " + RetSqlName("N9I") + " N9I ON N9I.D_E_L_E_T_ = ' ' AND N9I.N9I_CODINE = N9D.N9D_CODINE " 
	cQry += "    AND N9I.N9I_CODROM = N9D.N9D_CODROM AND N9I.N9I_ITEROM = N9D.N9D_ITEROM "
	cQry += " WHERE N9D.D_E_L_E_T_ = ' ' AND N9D_FILIAL = '"+ aFardo[1] +"' AND N9D_CODFAR = '"+ aFardo[4] +"' " 
	cQry += " AND N9D_CODINE = '"+ cCodIE +"' AND N9D_TIPMOV = '07' AND N9D_STATUS = '2' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
		aN9I := { (cAliasQry)->RECNO, (cAliasQry)->PESO }
	EndIf
	(cAliasQry)->(DbCloseArea())

Return aN9I

/*/{Protheus.doc} OGA730STFR
//TODO Atualiza Status do Fardo na DXI ao estufar ou certificar o container 
@obs Chamar esta função antes do FWFormCommit do model
@author claudineia.reinert
@since 19/07/2018
@version undefined
@param cFilCnt, characters, descricao
@param cCodIE, characters, descricao
@param cCodCnt, characters, descricao
@type function
/*/
Static Function OGA730STFR(cFilCnt, cCodIE, cCodCnt, cStatus)
	Local aAreaAtu 	:= GetArea()
	Local aAreaN91	:= N91->( GetArea() )
	Local aFrdSts 	:= {}	
	Local cQry 	    := ""
	Local cAliasQry := GetNextAlias()
	
	dbSelectArea("N91")
	N91->(dbSetOrder(1)) //FILIAL+CODINE+CONTAINER
	N91->(dbSeek(cFilCnt + cCodIE + cCodCnt )) 	

	cQry := " SELECT N9D_FILIAL, N9D_SAFRA, N9D_FARDO "
	cQry += " FROM " + RetSqlName("N9D") + " N9D "
	cQry += " WHERE N9D_FILORG='"+cFilCnt+"' AND N9D_CODINE='"+cCodIE+"' "
	cQry += " AND N9D_CONTNR='"+cCodCnt+"' "
	cQry += " AND N9D_TIPMOV='05' AND N9D_STATUS='2' AND D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())
			AADD(aFrdSts, { (cAliasQry)->N9D_FILIAL, (cAliasQry)->N9D_SAFRA, (cAliasQry)->N9D_FARDO })
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		
		If cStatus == "3" .AND. cStatus != N91->N91_STATUS
			//foi alterado de em estufagem para estufado
			//incluir(1) status do fardo na DXI(DXI_STATUS)
			AGRXFNSF( 1 , "EstufagFin", aFrdSts ) //ESTUFAGEM FINALIZADA
		ElseIf cStatus $ "1|2" .AND. cStatus != N91->N91_STATUS
			//Foi alterado de estufado para em estufagem
			//retorna(2) status do fardo na DXI(DXI_STATUS)
			AGRXFNSF( 2 , "EstufagFin", aFrdSts )
		ElseIf cStatus == "5"
			//na tela de certificação
			//incluir(1) status do fardo na DXI(DXI_STATUS)
			AGRXFNSF( 1 , "EstufagCert", aFrdSts ) //ESTUFAGEM CERTIFICADA
		EndIf
		
	EndIf
	
	RestArea( aAreaN91 )
	RestArea( aAreaAtu )	

Return .T.
