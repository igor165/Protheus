#INCLUDE "OGA200.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

#DEFINE _CRLF CHR(13)+CHR(10)  

Static __lPlVnd	:= SuperGetMv('MV_AGRO027',.F.,.F.) //Parametro se usa plano de vendas Agro Comercial
Static __aTab1220 := {"N9D","N9A"} //tabelas SLC - previsão liberação 122X
Static __lLib1220 := Nil

/** {Protheus.doc} OGA200
Rotina para Reservas quantidades em contratos
----
@param: 	Nil
@author: 	Bruna Rocio
@since: 	08/06/2010  Refeito em 19/05/2016 - Inácio Luiz Kolling
@Uso: 		SIGAAGR - Originação de Grãos
*/    
Function OGA200()
	Local oMBrowse	 := Nil

	__lLib1220 := AGRTABDIC(__aTab1220) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NJB")
	oMBrowse:SetDescription(STR0001) //"Cadastro de Reserva"
	oMBrowse:AddLegend("NJB_STATUS == '0'","WHITE",STR0002) //"Solicitada"
	oMBrowse:AddLegend("NJB_STATUS == '1'","GREEN",STR0003) //"Reservada"
	oMBrowse:AddLegend("NJB_STATUS == '2'","BLUE" ,STR0004) //"Liberada"
	oMBrowse:AddLegend("NJB_STATUS == '3'","RED"  ,STR0005) //"Cancelada"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return 

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		OGA200 - Amostras
*/
Static Function MenuDef()
	Local aRotina := {}
	Local nx
	aAdd(aRotina,{STR0006					,'PesqBrw'							,0,1,0,.T.}) //'Pesquisar'
	aAdd(aRotina,{STR0007					,'ViewDef.OGA200'					,0,2,0,.T.}) //'Visualizar'
	aAdd(aRotina,{STR0008					,'ViewDef.OGA200'					,0,3,0,.T.}) //'Incluir'
	aAdd(aRotina,{STR0009					,'ViewDef.OGA200'					,0,4,0,.T.}) //'Alterar'
	aAdd(aRotina,{STR0010					,'OGA200R()'						,0,4,0,.F.}) //'Reservar'
	aAdd(aRotina,{STR0011					,'OGA200L()'    					,0,4,0,.F.}) //'Liberar'
	aAdd(aRotina,{STR0012					,'OGA200C()'    					,0,4,0,.F.}) //'Cancelar'
	aAdd(aRotina,{STR0029					,'OGA200A'  		  				,0,4,0,.F.}) //'Avaliar'
	aAdd(aRotina,{STR0013					,'ViewDef.OGA200'					,0,5,0,.T.}) //'Excluir'
	aAdd(aRotina,{STR0014					,'ViewDef.OGA200'					,0,8,0,.T.}) //'Imprimir'
	aAdd(aRotina,{STR0014+" Warrant"		,'OGR205(NJB->NJB_CODRES)'			,0,9,0,.F.}) //'Imprimir Warrant'

	If ExistBlock('OG200MNU')
		aRetM := ExecBlock('OG200MNU',.F.,.F.)
		If Type("aRetM") == 'A'
			For nx := 1 To Len(aRetM)
				Aadd(aRotina,aRetM[nx])	
			Next nx	
		EndIf
	EndIf
Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		OGA200 - Amostras
*/
Static Function ModelDef()
	Local oStruNJB 	:= FWFormStruct( 1, "NJB" )
	Local bPre := {|oFieldModel, cAction, cIDField, xValue| ValidPre(oFieldModel, cAction, cIDField, xValue)}
	Local oModel 	:= MPFormModel():New( "OGA200", ,{|oModel| OGA200POSVLD(oModel)} , ,) 

	If __lLib1220 == nil
		__lLib1220 := AGRTABDIC(__aTab1220) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC
	Endif

	If __lLib1220
		
		oStruNJB:SetProperty( "NJB_CODCTR"  , MODEL_FIELD_WHEN  , {||OG200WHCTR()} )
		oStruNJB:SetProperty( "NJB_CODSAF"  , MODEL_FIELD_WHEN  , {||OG200WHN01()} )
		oStruNJB:SetProperty( "NJB_CODPRO"  , MODEL_FIELD_WHEN  , {||OG200WHN01()} )
		oStruNJB:SetProperty( "NJB_CODENT"  , MODEL_FIELD_WHEN  , {||OG200WHN01()} )
		oStruNJB:SetProperty( "NJB_FILPVN" 	, MODEL_FIELD_WHEN  , {||OG200WHN01()} )
		
		If __lPlVnd //usa planejamento de venda agro comercial
			oStruNJB:SetProperty( "NJB_CODCTR", MODEL_FIELD_OBRIGAT , .F.  ) //a obrigatoriedade será validada antes de gravar o modelo
			oStruNJB:SetProperty( "NJB_CODTER", MODEL_FIELD_OBRIGAT , .F.  )
			oStruNJB:SetProperty( "NJB_LOJTER", MODEL_FIELD_OBRIGAT , .F.  )
		EndIf
		
	EndIf

	oStruNJB:SetProperty("NJB_CODCTR",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"GATNJB()"))

	oModel:SetDescription(STR0001)
	oModel:AddFields( "OGA200_NJB", Nil, oStruNJB,bPre,/*< bPost >*/,/*< bLoad >*/)			
	oModel:SetDescription( STR0001 ) //"Cadastro de Reserva"
	oModel:GetModel( "OGA200_NJB" ):SetDescription( STR0016 ) //"Dados da Reserva"
	oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		OGA200 - Amostras
*/
Static Function ViewDef()
	Local oStruNJB := FWFormStruct( 2, "NJB" )
	Local oModel   := FWLoadModel( "OGA200" )
	Local oView    := FWFormView():New()
	
	If __lLib1220 .AND. .NOT. __lPlVnd //NÂO usa planejamento de venda agro comercial
		oStruNJB:RemoveField('NJB_FILPVN')
	EndIf
	
	oView:SetModel( oModel )
	oView:AddField("OGA200_NJB",oStruNJB,"OGA200_NJB")
	oView:CreateHorizontalBox( "UNICO", 100 )
	oView:SetOwnerView( "OGA200_NJB", "UNICO" )
	oView:EnableTitleView( "OGA200_NJB" )
Return oView

/** {Protheus.doc} IniModelo
Funcao para validação da inicializacao do formulario

@param: 	oModel - Modelo de Dados
@param: 	nOperation - Operação escolhida pelo usuario (3-inclui, 4-altera, 5-exclui)
@return:	lRetorno - .t. ou .f.
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		ARMA251 - Romaneio de Compra
*/
Static Function IniModelo( oModel, nOperation )
	Local cMens := " "
	///	__lWarranN := .f.
	If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE) .And. NJB->NJB_STATUS <> "0"
		cMens := If(nOperation == MODEL_OPERATION_UPDATE,STR0019,STR0021)
	EndIf
	If !Empty(cMens)
		Help(,,STR0017,,cMens,1,0)
		Return .f.
	EndIf
Return .t.

/** {Protheus.doc} OGA200
Rotina para 

@param: 	Nil
@author: 	Bruna Rocio		-- Alteração: Ana Laura Olegini
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200R()
	Local aAreaAtu 	:= GetArea()
	Local aAreaNJB	:= NJB->( GetArea() )
	Local oMdl200 	:= nil
	Local oMdLNJB	:= nil
	Local lContinua := .t.
	Local cNumWarr	:= ''

	If ! NJB->NJB_STATUS == "0"
		Help(,,STR0017,,STR0024,1,0)
		lContinua := .f.
	EndIF

	DbSelectArea( "NJR" )
	DbSetOrder(1)
	If !DbSeek(xFilial('NJR') + NJB->NJB_CODCTR) .AND. (.NOT. __lLib1220 .OR. .NOT. __lPlVnd)
		Help(,,"HELP",,STR0051+": " + NJB->NJB_CODCTR ,1,0)
		lContinua := .f.
	Endif

	If lContinua .and. MsgYesNo(STR0022,STR0023) //"Confirma a reserva de produto?"###"Confirmação"
		oMdl200 := fwLoadModel('OGA200')
		oMdl200:SetOperation( 4 )
		oMdl200:Activate()
		oMdlNJB := oMdl200:GetModel('OGA200_NJB')
		oMdlNJB:SetValue('NJB_DATRES', dDataBase	)
		oMdlNJB:SetValue('NJB_STATUS', '1'		)

		IF !Empty(NJB->NJB_CODCTR) .AND. Posicione("NJ2",1,FWxFilial("NJ2")+NJB->NJB_TIPRES,"NJ2_WRRANT") == "1" .And. Empty(NJB->NJB_WRRANT) //Verificando se é Warrant

			cNumWarr := GetMV("MV_OGNRWAR")
			cNumWarr	:= Soma1( Replicate("0",10 - Len( Alltrim( cNumWarr ) ) ) + Alltrim( cNumWarr ) )

			dBSelectArea( 'NJB' )
			NJB->(dbSetOrder(5))  //NJB_FILIAL+NJB_WRRANT
			While .t.
				IF NJB->(MsSeek(fWxFilial("NJB") + cNumWarr ))   // Verifica se ja existe Warrant com esse nr.
					cNumWarr := Soma1( cNumWarr )    // busca o proximo numero disponivel
					Loop
				Else
					IF ! MayIUseCode( "NJB_WRRANT" + fWXfilial('NJB') + cNumWarr )		//--- Verifica se esta na memoria, sendo usado 	---//
						cNumWarr := Soma1(cNumWarr)			 								//--- Busca o proximo numero disponivel 			---//
						Loop
					Else
						Exit
					EndIF
				EndIF
			EndDO

			RestArea( aAreaNJB )

			// Gravando o Parametro Atualizado
			If GetMv("MV_OGNRWAR") < cNumWarr
				PUTMV("MV_OGNRWAR", cNumWarr )			
			Endif		

			oMdl200:LoadValue("OGA200_NJB", "NJB_WRRANT", cNumWarr)    

		EndIF

		lContinua := FWFormCommit(oMdl200, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, {||AtuQtdRes( oMdlNJB:GetValue('NJB_QTDPRO') ) }, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
	EndIf

	RestArea( aAreaAtu )
Return ( lcontinua )

/** {Protheus.doc} OGA200L
Rotina para liberação da reserva

@param: 	Nil
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200L()
	BEGIN TRANSACTION
		DbSelectArea( "NJB" )
		If NJB->NJB_AVALIA == '1'  // 1 - Avaliado
			If NJB->NJB_STATUS == "1"
				If MsgYesNo ( STR0025, STR0023 ) //"Confirma a liberação da reserva de produto?"###"Confirmação"
					DbSelectArea( "NJB" )
					RecLock("NJB",.f.)
					NJB->NJB_DATLIB := dDataBase
					NJB->NJB_STATUS := "2"
					msUnLock()

					DbSelectArea( "NJR" )
					DbSetOrder(1)
					If DbSeek( xFilial('NJR') + NJB->NJB_CODCTR)
						RecLock('NJR',.f.)
						NJR->NJR_QTDRES -= NJB->NJB_QTDPRO
						msUnLock()
					Endif
				EndIf
			Else
				Help(,,STR0017,,STR0026,1,0)
			EndIf
		Else
			Help(,,STR0017,,STR0030,1,0)
		Endif
	END TRANSACTION
Return 

/** {Protheus.doc} OGA200C
Rotina para cancelamento da reserva

@param: 	Nil
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200C()
	BEGIN TRANSACTION
		DbSelectArea( "NJB" )
		If NJB->NJB_AVALIA == '1'  // 1 - Avaliado
			If NJB->NJB_STATUS == "1"
				If MsgYesNo ( STR0027, STR0023 ) //"Confirma o cancelamento da reserva de produto?"###"Confirmação"
					DbSelectArea( "NJB" )
					If RecLock( "NJB", .f.)
						NJB->NJB_DATCAN := dDataBase
						NJB->NJB_STATUS := "3"
						msUnLock()
					EndIf

					DbSelectArea( "NJR" )
					DbSetOrder(1)
					If DbSeek( xFilial('NJR') + NJB->NJB_CODCTR)
						RecLock('NJR',.f.)
						NJR->NJR_QTDRES -= NJB->NJB_QTDPRO
						msUnLock()
					Endif
				EndIf
			Else
				ShowHelpDlg(STR0017,{STR0018,STR0028},5,{STR0020},5) //"HELP"###"Somente registros com status de"###"-Reservado- podem ser -Cancelados-."###"Solução"
			EndIf
		Else
			Help(,,STR0017,,STR0030,1,0)
		Endif
	END TRANSACTION
Return

/** {Protheus.doc} OGA200GrRsv // usada no OGA250 ???
Rotina responsável por gera uma reserva automática a partir OGA250ATUC que atualiza o contrato

@param: 	Nil
@author: 	Vinicius Pagung
@since: 	16/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA200GrRsv(cRomaneio)  
	Local cNewRsv 		:= ""
	Local aMatdad 		:= {}
	Local aAreaAtu	 	:= GetArea()
	Local cAliasQry	 	:= GetNextAlias()
	Local cQuery
	Local lContinua		:= .T.
	///	__lWarranN := .f.

	cAliasQry := GetNextAlias()
	cQuery := " SELECT NJJ_FILIAL, NJJ_DATPS2, NJJ_DATPS2, NNK_TIPRES, NJM_CODENT, NJM_LOJENT, NJ2_CODTER, NJ2_LOJTER, NJJ_TABELA, NJJ_CODSAF, "
	cQuery += " NJJ_CODPRO, NJJ_UM1PRO, NJJ_CODROM, NJM_CODCTR, NJM_ITEROM, NJK_ITEM, NJM_QTDFCO, NNK_PERRET, NJM_QTDFCO, NNK_PERRET,  NNK_TIPRES "
	cQuery += " FROM " + RetSqlName("NJJ") + " NJJ "

	cQuery += " INNER JOIN " + RetSqlName("NJK") + " NJK "
	cQuery += "   ON NJK.NJK_FILIAL = '" + xFilial('NJK') + "'"
	cQuery += "  AND NJK.NJK_CODROM = '" + cRomaneio + "'"
	cQuery += "  AND NJK.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName("NNK") + " NNK "
	cQuery += "   ON NNK.NNK_FILIAL = '" + xFilial('NNK') + "'"
	cQuery += "   AND NNK.NNK_CODTAB = NJJ.NJJ_TABELA "
	cQuery += "   AND NNK.NNK_CODDES = NJK.NJK_CODDES " 
	cQuery += "   AND NNK.NNK_TIPRES <> '' "
	cQuery += "   AND NNK.NNK_PERRET > 0 "
	cQuery += "   AND NJK.NJK_PERDES >= NNK.NNK_PERINI "
	cQuery += "   AND NJK.NJK_PERDES <= NNK.NNK_PERFIM "
	cQuery += "   AND NNK.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName("NJ2") + " NJ2 "
	cQuery += "   ON NJ2.NJ2_FILIAL = '" + xFilial('NJ2') + "'"
	cQuery += "  AND NJ2.NJ2_TIPRES = NNK.NNK_TIPRES "
	cQuery += "  AND NJ2.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName("NJM") + " NJM "
	cQuery += "   ON NJM.NJM_FILIAL = '" + xFilial('NJM') + "'"
	cQuery += "  AND NJM.NJM_CODROM = '" + cRomaneio + "'"
	cQuery += "  AND NJM.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE NJJ.NJJ_FILIAL  = '" +  xFilial('NJJ') + "'"
	cQuery += "   AND NJJ.NJJ_CODROM  = '" + cRomaneio + "'"
	cQuery += "   AND NJJ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 

	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof()) 

			cNewRsv := GetSXENum('NJB','NJB_CODRES')
			ConfirmSX8()
			aMatdad := {}
			Aadd(aMatdad,{'NJB_FILIAL',(cAliasQry)->NJJ_FILIAL})
			Aadd(aMatdad,{'NJB_CODRES',cNewRsv})
			Aadd(aMatdad,{'NJB_DATA',  SToD( (cAliasQry)->NJJ_DATPS2)})
			Aadd(aMatdad,{'NJB_DATVEN',CToD("31/12/2050")})
			Aadd(aMatdad,{'NJB_DATRES',SToD((cAliasQry)->NJJ_DATPS2) })
			Aadd(aMatdad,{'NJB_TIPRES',(cAliasQry)->NNK_TIPRES})
			Aadd(aMatdad,{'NJB_CODENT',(cAliasQry)->NJM_CODENT})
			Aadd(aMatdad,{'NJB_LOJENT',(cAliasQry)->NJM_LOJENT})
			Aadd(aMatdad,{'NJB_TABELA',(cAliasQry)->NJJ_TABELA})
			Aadd(aMatdad,{'NJB_CODSAF',(cAliasQry)->NJJ_CODSAF})
			Aadd(aMatdad,{'NJB_CODPRO',(cAliasQry)->NJJ_CODPRO})
			Aadd(aMatdad,{'NJB_UM1PRO',(cAliasQry)->NJJ_UM1PRO})
			Aadd(aMatdad,{'NJB_OBS'		,STR0032})
			Aadd(aMatdad,{'NJB_STATUS','1'})
			Aadd(aMatdad,{'NJB_CODROM',(cAliasQry)->NJJ_CODROM})
			Aadd(aMatdad,{'NJB_CODCTR',(cAliasQry)->NJM_CODCTR}) 
			Aadd(aMatdad,{'NJB_ITEROM',(cAliasQry)->NJM_ITEROM})
			Aadd(aMatdad,{'NJB_ITECLA',(cAliasQry)->NJK_ITEM})
			Aadd(aMatdad,{'NJB_QTDTOT',(cAliasQry)->NJM_QTDFCO})
			Aadd(aMatdad,{'NJB_PERRET',(cAliasQry)->NNK_PERRET})
			Aadd(aMatdad,{'NJB_AVALIA','0'})
			Aadd(aMatdad,{'NJB_LIBERA','1'})
			Aadd(aMatdad,{'NJB_CODTER',(cAliasQry)->NJ2_CODTER}) 
			Aadd(aMatdad,{'NJB_LOJTER',(cAliasQry)->NJ2_LOJTER})
			Aadd(aMatdad,{'NJB_QTDPRO',ROUND((cAliasQry)->NJM_QTDFCO *((cAliasQry)->NNK_PERRET/100),0)})

			// Gera NJB automático
			If !AGRMODELAUT("NJB",aMatdad,'OGA200','OGA200_NJB')
				lContinua := .F.				
			EndIf

			If lContinua
				DbSelectArea( "NJR" )
				DbSetOrder(1)
				If DbSeek( xFilial('NJR') + NJB->NJB_CODCTR)
					RecLock('NJR',.f.)
					NJR->NJR_QTDRES := NJR->NJR_QTDRES + NJB->NJB_QTDPRO
					msUnLock()
				Endif
			EndIf

			( cAliasQry )->( DbSkip() )
		EndDo
	EndIf
	(cAliasQry)->(dbCloseArea())

	RestArea( aAreaAtu )

Return lContinua

/** {Protheus.doc} GATNJB
Função usada para gatilho

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	16/06/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function GATNJB()
	Local oModel		:= FwModelActive()
	Local oNJB			:= oModel:GetModel( "OGA200_NJB" )

	If !Empty(oNJB:GetValue("NJB_CODCTR")) .and. !ExistCpo('NJR',oNJB:GetValue("NJB_CODCTR"),1)
		Return .f.
	EndIf
	If !OG200TPCONT()
		Return .f.
	EndIf
		
	If !Empty(oNJB:GetValue("NJB_CODCTR")) .And. !Empty(Posicione("NJR",1,xFilial("NJR")+FwFldGet("NJB_CODCTR"),"NJR_CODCTR")) 
		oNJB:LoadValue("NJB_CODPRO",NJR->NJR_CODPRO)
		oNJB:SetValue("NJB_UM1PRO",NJR->NJR_UM1PRO)
		oNJB:LoadValue("NJB_CODENT",NJR->NJR_CODENT)
		oNJB:SetValue("NJB_CODTER",NJR->NJR_CODTER)
		oNJB:SetValue("NJB_LOJENT",NJR->NJR_LOJENT)
		oNJB:LoadValue("NJB_CODSAF",NJR->NJR_CODSAF)
		oNJB:SetValue("NJB_TABELA",NJR->NJR_TABELA)
		If Posicione("NJ2",1,xFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_WRRANT") == "1"
			oNJB:SetValue("NJB_VLRBAS",NJR->NJR_VLRBAS)
		EndIf	
		Posicione("NJ0",1,xFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0_NOME")
		oNJB:SetValue("NJB_NOMENT",NJ0->NJ0_NOME)
	EndIf	
Return .t.

/** {Protheus.doc} OG200GT1VLRBAS
Função usada para gatilho do Campo NJRVLRBAS

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	16/06/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OG200GT1VLRBAS()
	Local oModel		:= FwModelActive()
	Local oNJB			:= oModel:GetModel( "OGA200_NJB" )
	Local nVlrBas		:= 0

	IF Posicione("NJ2",1,xFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_WRRANT") == "1"
		If !Empty(oNJB:GetValue("NJB_CODCTR")) .And. !Empty(Posicione("NJR",1,xFilial("NJR")+FwFldGet("NJB_CODCTR"),"NJR_CODCTR")) 
			nVlrBas := NJR->NJR_VLRBAS
		EndIf	
	EndIf

	OG200lWarr()

Return( nVlrBas ) 
/*
+=================================================================================================+
| Função    : OG200TPCONT                                                                         |
| Descrição : Valida o contrato pelo tipo de reserva,Warrant for Compra ou deposito de terceiro   |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 18/05/2016                                                                          |
+=================================================================================================+                                                                           |  
|Referências: Dicionário de dados                                                                 |
+=================================================================================================+ 
*/
Function OG200TPCONT()

	If !Empty(FwFldGet("NJB_TIPRES")) .And. Posicione("NJ2",1,xFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_WRRANT") == "1" .And. ;
	!Empty(Posicione("NJR",1,xFilial("NJR")+FwFldGet("NJB_CODCTR"),"NJR_CODCTR")) .And. !NJR->NJR_TIPO $ '13'
		Help(,1,"HELP",,STR0033+" Warrant "+STR0034,1,0)
		Return .f. 
	EndIf

Return .t.

/*
+=================================================================================================+
| Função    : OG200TPWCON                                                                         |
| Descrição : Valida tipo de reserva for Warrant e o contrato for Compra ou deposito de terceiro  |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 18/05/2016                                                                          |
+=================================================================================================+                                                                           |  
|Referências: Dicionário de dados                                                                 |
+=================================================================================================+ 
*/
Function OG200TPWCON()
	Local oModel	:= FwModelActive()
	Local oView		:= FwViewActive()
	Local oNJB		:= oModel:GetModel('OGA200_NJB')

	Posicione("NJ2",1,xFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_WRRANT")

	If NJ2->NJ2_WRRANT == "1" .And. !Empty(Posicione("NJR",1,xFilial("NJR")+FwFldGet("NJB_CODCTR"),"NJR_CODCTR"));
	.And. !NJR->NJR_TIPO $ '13'
		Help(,1,"HELP",,STR0035+" Warrant "+STR0036,1,0)
		Return .f. 
	EndIf
	// Alterou tipo de reserva de warrant para nao warrant
	If NJ2->NJ2_WRRANT <> "1" .And.	(!Empty(FwFldGet("NJB_VLRBAS")) .Or. !Empty(FwFldGet("NJB_CODEX1")) .Or. ;
	!Empty(FwFldGet("NJB_CODEX2")) .Or. !Empty(FwFldGet("NJB_CODEX3")) .Or. !Empty(FwFldGet("NJB_CODEX4")))

		//Help(,,"HELP",,STR0037,1,0)

		Aviso( "Help", STR0037, { "OK" }, 3, "" )    // "Tipo de Reserva não está relacionado a uma Warrant,isto fará com que os dados referente a Warrant sejam eliminados"

		oNJB:LoadValue("NJB_WRRANT",	" "	)
		oNJB:LoadValue("NJB_VLRBAS",	0	)
		oNJB:LoadValue("NJB_CODEX1",	" "	)
		oNJB:LoadValue("NJB_DESEX1",	" "	)
		oNJB:LoadValue("NJB_PMDEX1",	0	)
		oNJB:LoadValue("NJB_CODEX2",	" "	)
		oNJB:LoadValue("NJB_DESEX2",	" "	)
		oNJB:LoadValue("NJB_PMDEX2",	0	)
		oNJB:LoadValue("NJB_CODEX3",	" "	)
		oNJB:LoadValue("NJB_DESEX3",	" "	)
		oNJB:LoadValue("NJB_PMDEX3",	0	)
		oNJB:LoadValue("NJB_CODEX4",	" "	)
		oNJB:LoadValue("NJB_DESEX4",	" "	)
		oNJB:LoadValue("NJB_PMDEX4",	0	)

		oView:Refresh('OGA200_NJB')
		Return .T.
	EndIf 

	If NJ2->NJ2_WRRANT == "1"
		oNJB:LoadValue("NJB_VLRBAS",NJR->NJR_VLRBAS)
	EndIf

Return .t.

/** {Protheus.doc} OGA200
Rotina para Atualizar a qtd. Reservada do Contrato

@param: 	Qtd. Reserva
@author: 	Emerson Coelho
@since: 	21/06/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function AtuQtdRes( nQtdRes )
	Local aAreaNJR	:= NJR->( GetArea() )

	DbSelectArea( "NJR" )
	DbSetOrder(1)
	If NJR->( DbSeek(xFilial('NJR') + NJB->NJB_CODCTR) )
		RecLock('NJR',.f.)
		NJR->NJR_QTDRES += nQtdRes
		NJR->( msUnLock() )
	Endif
	RestArea( aAreaNJR )
Return( .T. )

/** {Protheus.doc} OG200lWarr
Função que retorna se a reserva Refere-se a uma Warrant

@param: 	nil
@author: 	Emerson Coelho
@since: 	21/06/2016
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OG200lWarr()
	lWarrant := IIf(Posicione("NJ2",1,xFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_WRRANT") == "1",.T.,.F.)

Return lWarrant

/*{Protheus.doc} 
Função de consulta de arquivo Utilizado no Pergunte para a consulta padrao OGGARQ
@param		nil.
@sample   	OGGETARQ( READVAR() )
@return   	nil
@author   	Agro
@since    	25/07/2016
@version  	P11
*/

Function OGGETDOT( cCPO )	
	Local cRET    	  := cGetFile( STR0024  +  STR0025 , STR0026,,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+128,.f.) // "Arquivo Dot | *.Dot|" + "Arquivo .Dotx |*.Dotx|" # "Selecione o Arquivo de Modelo" 

	&(cCPO) := cRET   
	Iif( 1 < 0,OGGETDOT("XX"),"")//Retira o Warning de compilacao    
Return (!Empty(cRET))

/*/{Protheus.doc} OGA200POSVLD
//TODO Função que realiza validações antes de gravar o modelo
@author claudineia.reinert
@since 20/06/2018
@version undefined
@param oModel, object, objeto do modelo
@type function
/*/
Static Function OGA200POSVLD(oModel)
	Local lRetorno := .T.

	If !VLDOBGGRV(oModel) .OR. !OGA200VAL(oModel)
		lRetorno := .F.
	EndIf

Return lRetorno

/*{Protheus.doc} 
Função que verifica e barra caso a quantidade da reserva seja maior que o contrato
@param		oModel
@sample   	OGA200VAL(oModel)
@return   	lRetorno
@author   	Thiago Henrique Rover
@since    	14/03/2017
@version  	P11
*/
Static Function OGA200VAL(oModel)

	Local oGridNJB   := oModel:GetModel('OGA200_NJB') //Pega o modelo da Grid
	Local nSldFis    := Posicione('NJR',1,xfilial("NJR")+ FwFldGet("NJB_CODCTR"),'NJR_SLDFIS') //Posiciona no registro e retorna o valor do campo
	Local nQtdctr    := Posicione('NJR',1,xfilial("NJR")+ FwFldGet("NJB_CODCTR"),'NJR_QTDCTR') //Posiciona no registro e retorna o valor do campo
	Local cCodCTR    := Posicione('NJR',1,xfilial("NJR")+ FwFldGet("NJB_CODCTR"),'NJR_CODCTR') //Posiciona no registro e retorna o valor do campo
	Local nTipo      := Posicione('NJR',1,xfilial("NJR")+ FwFldGet("NJB_CODCTR"),'NJR_TIPO') //Posiciona no registro e retorna o valor do campo
	Local cAlias     := GetNextAlias()
	Local lRetorno   := .T.
	Local nQtdpro    := 0
	Local cValida

	If !Empty(oGridNJB:GetValue("NJB_QTDPRO")) //Valida se o campo não está vazio
		nQtdpro += FwFldGet('NJB_QTDPRO') // FwFlGet retorna o valor do campo e captura na variável
	Endif
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		return .T.
	EndIf
	
	//Valida se o timpo do contrato é Compra ou Venda
		If nTipo $ "1,2"  
	
			//Select para buscar contratos pelo status 
			cAlias  := GetNextAlias()
			cValida := "SELECT SUM(NJB_QTDPRO) NJB_QTDPRO "
			cValida += "FROM"+RetSqlName("NJB") + " NJB "
			cValida += "WHERE NJB_FILIAL = '" + xFilial("NJB") + "'"
			cValida += "AND NJB.NJB_CODCTR = '"+cCodCTR+"'"
			cValida += "AND NJB.NJB_CODRES <> '"+oGridNJB:GetValue("NJB_CODRES")+"'"
			cValida += "AND NJB.NJB_STATUS IN('0','1')"
			cValida += "AND NJB.D_E_L_E_T_ = ' ' "
			cValida := ChangeQuery( cValida )
	
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cValida), cAlias,.T.,.T.)
	
			//Estrutura para capturar o valor do campo
			(cAlias)->(dbGoTop())
			While !(Eof())
				If !Empty((cAlias)->NJB_QTDPRO)
					cValida := (cAlias)->NJB_QTDPRO + nQtdpro
				Else
					cValida := nQtdpro
				Endif
				Exit
			End
	
			//Verificação se o valor do contrato é divergente ao cadastro de reservas
			if nQtdctr >= nQtdpro .AND. cValida <= nQtdctr 
				lRetorno := .T.
			Else
				oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", STR0052/*Validação*/ , STR0053/*Quantidade da reserva é superior a quantidade do contrato.*/, , "", "")	
				return .F.
			Endif
	
		Else
			//Valida se o tipo de contrato é Armazenado em terceiros ou de terceiros
			If nTipo $ "3,4"
	
				//Select para buscar contratos pelo status 
				cAlias  := GetNextAlias()
				cValida := "SELECT SUM(NJB_QTDPRO) NJB_QTDPRO "
				cValida += "FROM"+RetSqlName("NJB") + " NJB "
				cValida += "WHERE NJB_FILIAL = '" + xFilial("NJB") + "'"
				cValida += "AND NJB.NJB_CODCTR = '"+cCodCTR+"'"
				cValida += "AND NJB.NJB_CODRES <> '"+oGridNJB:GetValue("NJB_CODRES")+"'"
				cValida += "AND NJB.NJB_STATUS IN('0','1')"
				cValida += "AND NJB.D_E_L_E_T_ = ' ' "
				cValida := ChangeQuery( cValida )
	
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cValida), cAlias,.T.,.T.)
	
				//Estrutura para capturar o valor do campo
				(cAlias)->(dbGoTop())
				While !(Eof())
					If !Empty((cAlias)->NJB_QTDPRO)
						cValida := (cAlias)->NJB_QTDPRO + nQtdpro
					Else
						cValida := nQtdpro
					Endif
					Exit
				End
	
					//Verificação se o valor do contrato é divergente ao cadastro de reservas
				if nSldFis >= nQtdpro .AND. cValida <= nSldFis 
					lRetorno := .T.
				Else
					oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", STR0052/*Validação*/ , STR0053/*Quantidade da reserva é superior a quantidade do contrato.*/, , "", "")	
					return .F.
				Endif
	
			Endif
		Endif

Return lRetorno

/*/{Protheus.doc} VLDOBGGRV
//TODO Função que verifica a obrigatoriedade de campos antes de salvar o modelo
@author claudineia.reinert
@since 20/06/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function VLDOBGGRV(oModel)
	Local lRetorno 	:= .T.
	Local cMsg 		:= STR0055 + _CRLF + _CRLF //Os seguintes campos são obrigatórios: "
	Local cTipRes	

	If NJ2->(ColumnPos('NJ2_TIPOOP')) > 0

		cTipRes := Posicione("NJ2",1,FWxFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_TIPOOP")

		If __lPlVnd .and. cTipRes == "2" .AND. Empty(FwFldGet("NJB_DATVEN") )
			lRetorno := .F.
			cMsg := cMsg + "* " + GetSx3Cache("NJB_DATVEN","X3_TITULO") + _CRLF  
		EndIf
		If __lPlVnd .and. Empty(FwFldGet("NJB_FILPVN")) .AND. cTipRes == "2" 
			lRetorno := .F.
			cMsg := cMsg + "* " + GetSx3Cache("NJB_FILPVN","X3_TITULO") + _CRLF  
		EndIf
		If Empty(FwFldGet("NJB_CODCTR")) .AND. (cTipRes == "1" .OR. Empty(cTipRes))  //tipo em branco|1-contratos
			lRetorno := .F.
			cMsg := cMsg + "* " + GetSx3Cache("NJB_CODCTR","X3_TITULO") + _CRLF  
		EndIf

	EndIf

	If Empty(FwFldGet("NJB_CODENT")) .AND. !Empty(FwFldGet("NJB_CODCTR"))
		lRetorno := .F.
		cMsg := cMsg + "* " + GetSx3Cache("NJB_CODENT","X3_TITULO") + _CRLF  
	EndIf
	If Empty(FwFldGet("NJB_CODTER")) .AND. !Empty(FwFldGet("NJB_CODCTR"))
		lRetorno := .F.
		cMsg := cMsg + "* " + GetSx3Cache("NJB_CODTER","X3_TITULO") + _CRLF  
	EndIf
	If Empty(FwFldGet("NJB_LOJTER")) .AND. !Empty(FwFldGet("NJB_CODTER"))
		lRetorno := .F.
		cMsg := cMsg + "* " + GetSx3Cache("NJB_LOJTER","X3_TITULO") + _CRLF  
	EndIf
	If Empty(FwFldGet("NJB_CODSAF") )
		lRetorno := .F.
		cMsg := cMsg + "* " + GetSx3Cache("NJB_CODSAF","X3_TITULO") + _CRLF  
	EndIf
	If Empty(FwFldGet("NJB_CODPRO") )
		lRetorno := .F.
		cMsg := cMsg + "* " + GetSx3Cache("NJB_CODPRO","X3_TITULO") + _CRLF  
	EndIf

	If !lRetorno
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", STR0052 , cMsg, , "", "")	//#Valiação
	EndIf


Return lRetorno

/*{Protheus.doc} 
Função de consulta de arquivo Utilizado no Pergunte para a consulta padrao OGSARQ
@param		nil.admin
@sample   	OGSAVARQ( READVAR() )
@return   	nil
@author   	Agro
@since    	25/07/2016
@version  	P11
*/

Function OGSLOCAL( cCPO )
	Local cRET := cGetFile(STR0027 ,STR0028,1,,.F., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.) //"Arquivo pdf |*.pdf|" #"Local de gravação"

	&(cCPO) := cRET   
	Iif( 1 < 0,OGSLOCAL("XX"),"")//Retira o Warning de compilacao    
Return (!Empty(cRET))


Function OGA200DOC()
	Local cCaminho 	:= M->&(ReadVar())
	Local cExtensao := ""

	cExtensao:= Upper(SUBSTR(cCaminho, AT(".", cCaminho) + 1))

	If cExtensao == "DOTX"
		cRedVar := STRTRAN(Upper(M->&(ReadVar())), ".DOTX", ".PDF")
	ElseIf cExtensao == "DOT"
		cRedVar := STRTRAN(Upper(M->&(ReadVar())), ".DOT", ".PDF")
	EndIf

Return cRedVar

/*/{Protheus.doc} OG200WHCTR
//TODO WHEN para o campo de contrato
@author claudineia.reinert
@since 21/06/2018
@version undefined

@type function
/*/
Static Function OG200WHCTR()
	Local lRet := .T.

	If __lLib1220 .AND. Empty(FwFldGet("NJB_CODCTR")) .and. __lPlVnd .and. Posicione("NJ2",1,FWxFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_TIPOOP") == "2"
		//desabilita campo codigo contrato se não tem contrato informado e usa planejamento de vendas e o tipo da reserva for para plano de venda
		lRet := .F. 
	EndIf

Return lRet

/*/{Protheus.doc} OG200WHN01
//TODO WHEN para os campos safra, produto e entidade
@author claudineia.reinert
@since 21/06/2018	
@version undefined

@type function
/*/
Static Function OG200WHN01()
	Local lRet := .F.

	If __lPlVnd .AND. Posicione("NJ2",1,FWxFilial("NJ2")+FwFldGet("NJB_TIPRES"),"NJ2_TIPOOP") == "2"
		//habilita campo ENTIDADE,SAFRA,PRODUTO e FILIAL PLANO DE VENDAS se usa planejamento de vendas, não tem contrato informado e tipo da reserva for pra plano de vendas(2) 
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} OG200PreM
//TODO Pre validaç?o de model para substituir ADDTRIGGER
@author claudineia.reinert
@since 21/06/2018
@version undefined

@type function
/*/
Static Function ValidPre(oFieldModel, cAction, cIDField, xValue)
	Local lRet := .T.

	If cAction == "SETVALUE" .AND. cIDField == "NJB_TIPRES"
			oFieldModel:LoadValue("NJB_CODPRO","")
			oFieldModel:LoadValue("NJB_CODSAF","")
			oFieldModel:LoadValue("NJB_CODENT","")
			oFieldModel:LoadValue("NJB_FILPVN","")
			oFieldModel:LoadValue("NJB_CODCTR","")
			oFieldModel:LoadValue("NJB_LOJENT","")
			oFieldModel:LoadValue("NJB_NOMENT","")
			oFieldModel:LoadValue("NJB_NLJENT","")
	EndIf

Return lRet
