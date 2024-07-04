#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "OGA455.ch"

#define COL_COUNT  	22
#define COL_MARK    1
#define COL_CTR		2
#define COL_ROM		3
#define COL_TES     4
#define COL_DOC     5
#define COL_SERIE   6
#define COL_EMISSAO 7
#define COL_ITEM    8
#define COL_QUANT   9
#define COL_QTDFIX  10
#define COL_VUNIT   11
#define COL_VTOTAL  12
#define COL_SALDO   13
#define COL_DISTRIB 14
#define COL_VDISTR  15
#define COL_IDENTB6 16
#define COL_LOTECTL 17
#define COL_VAZIO   18
#define COL_CODROM  19
#define COL_ITEROM  20
#define COL_QTDRET  21
#define COL_QTDQTC  22

/*/{Protheus.doc} OGA455
//Transferencias de Saldos e Serviços entre Contratos
@author joaquim.burjack
@since 23/07/2018
@version 1.0

@type function
/*/
Function OGA455()
	Local   aArea   := GetArea()
	Local   oBrowse

	Private _aRegNJJ      	:= {}
	Private aMovServR 		:= {}
	Private aMovServV		:= {}
	Private _aItensTrf      := {}
	//Caso não exista a tabela no dicionário, não pode abrir a tela
	If .Not. TableInDic('NBT')
		MsgNextRel() 
		return()
	else
		//Caso o campo não exista, é necessário atualziar o dicionário, pois a tabela já foi expedida na 23
		// porém, os campos corretos só foram expedidos na 25.
		if NBT->(ColumnPos('NBT_VLRTOT')) <= 0
			MsgNextRel() 
			return()
		endIf
	EndIf

	SetKey(VK_F6,{|| OGA455DTAL("DESTINO")})

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NBT")
	oBrowse:SetDescription(STR0001) //"Transferências de Saldos entre Contratos"
	oBrowse:AddLegend( "NBT->NBT_STATUS == '1'", "RED",        STR0056 )//"Pendente" 
	oBrowse:AddLegend( "NBT->NBT_STATUS == '2'", "GRAY",       "Romaneios Gerados"  )//"Romaneios Gerados" 
	oBrowse:AddLegend( "NBT->NBT_STATUS == '3'", "YELLOW",     "NFs Geradas"  )//"NFs Geradas" 
	
	oBrowse:AddLegend( "NBT->NBT_STATUS == '4'", "GREEN",      STR0058 )//"Transf. Serv. Concluida" 
	oBrowse:AddLegend( "NBT->NBT_STATUS == '5'", "BR_CANCEL",  STR0059 ) //"Cancelado" 
	oBrowse:Activate()

	RestArea(aArea)
Return Nil


/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 23/07/2018
@version 1.0
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local lOG455MNU := ExistBlock('OG455MNU')
	Local Nx
	//Adicionando opções
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.OGA455'   OPERATION MODEL_OPERATION_VIEW   ACCESS 1 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.OGA455'   OPERATION MODEL_OPERATION_INSERT ACCESS 1 //'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.OGA455'   OPERATION MODEL_OPERATION_UPDATE ACCESS 1 //'Alterar'
	ADD OPTION aRotina TITLE STR0047 ACTION 'OGA455CAN'        OPERATION MODEL_OPERATION_UPDATE ACCESS 1 //'Excluir'
	ADD OPTION aRotina TITLE STR0054 ACTION 'OGA455TRVL()' OPERATION MODEL_OPERATION_UPDATE ACCESS 1 //'Bonificar'
    ADD OPTION aRotina TITLE STR0060 ACTION 'OGA455ROM()' OPERATION MODEL_OPERATION_UPDATE ACCESS 1 //"Gerar Romaneios"
    ADD OPTION aRotina TITLE STR0014 ACTION 'OGA455ACLC(NBT->NBT_FILIAL, NBT->NBT_CODTRF)' OPERATION MODEL_OPERATION_UPDATE ACCESS 1 //'Transferir'

	//PONTO DE ENTRADA PARA AÇÕES RELACIONADAS
	If lOG455MNU
		aRetM := ExecBlock('OG455MNU',.F.,.F.)
		If Type("aRetM") == 'A'
			For Nx := 1 To Len(aRetM)
				Aadd(aRotina,aRetM[Nx])
			Next Nx 
		EndIf
	EndIf
Return aRotina


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 23/07/2018
@version 1.0
@type function
/*/
Static Function ModelDef()
	Local oModel	:= MPFormModel():New('OGA455')
	Local oStruNBT  := FWFormStruct(1, 'NBT')
	Local oStruNBU  := FWFormStruct(1, 'NBU')	
	Local bPre := {|oFieldModel, cAction, cIDField, xValue| PreValNBT(oFieldModel, cAction, cIDField, xValue)}
	Local bPos := {|oFieldModel|fieldValidPos(oFieldModel)}

	oStruNBT:AddTrigger( "NBT_VLRTOT", "NBT_VLRUNI", {||.T.}, {||OGA455GtPr("NBT_VLRTOT")})
	oStruNBT:AddTrigger( "NBT_VLRUNI", "NBT_VLRTOT", {||.T.}, {||OGA455GtPr("NBT_VLRUNI")})

	//Criando o modelo e os relacionamentos
	oModel:AddFields('OGA455_NBT',/*cOwner*/,oStruNBT,bPre,bPos)

	oModel:SetPrimaryKey({"NBT_FILIAL","NBT_CODTRF"})
	oModel:SetDescription(STR0001) //"Transferencias de Saldos entre Contratos"
	oModel:GetModel('OGA455_NBT'):SetDescription(STR0006) //"Dados para Transferência"

	oModel:AddGrid('OGA455_NBU','OGA455_NBT',oStruNBU, , ,{|oModelGrid, nLine,cAction,cIDField,xVrNovo,xVrAnt|PreValNBU(oModelGrid, nLine, cAction, cIDField,xVrNovo,xVrAnt)})
	oModel:SetRelation('OGA455_NBU', { { 'NBU_FILIAL', 'FwxFilial( "NBU" )' }, { 'NBU_CODTRF','NBT_CODTRF' } }, NBU->(IndexKey()))
	oModel:GetModel('OGA455_NBU'):SetUniqueLine({"NBU_FILIAL","NBU_CODTRF","NBU_CTRORI","NBU_ITEM"})
	oModel:GetModel('OGA455_NBU'):SetDescription(STR0007) //"Romaneios Envolvidos na Transferência"
	oModel:GetModel( "OGA455_NBU" ):SetOptional( .t. )
 	oModel:AddCalc( 'OGA455QTD', 'OGA455_NBT', 'OGA455_NBU', 'NBU_QTDSEL', 'TOTQTDSEL','SUM',{||.t.},,'Qtd Total Selecionada',)

	oModel:SetVldActivate(	{ | oModel | VldActveMd( oModel,	oModel:GetOperation() ) } )

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 23/07/2018
@version 1.0
@type function
/*/
Static Function ViewDef()
	Local oView        := Nil
	Local oModel       := FWLoadModel('OGA455')
	Local oStruNBT     := FWFormStruct(2, 'NBT')
	Local oStruNBU     := FWFormStruct(2, 'NBU')
	Local oCalc		   := FWCalcStruct( oModel:GetModel( 'OGA455QTD') )
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:CreateHorizontalBox( 'CABEC', 45, , , , )
	oView:CreateHorizontalBox( 'DETALHES',45, , , , )
	oView:CreateHorizontalBox( 'RODAPE', 10,, , , )
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('OGA455_NBT',oStruNBT,'OGA455_NBT')
	oView:AddGrid('VWOGA455_NBU',oStruNBU,'OGA455_NBU')
	oView:AddField( 'VIEW_CALC', oCalc , 'OGA455QTD' )
    
    oView:SetViewProperty("VWOGA455_NBU", "GRIDDOUBLECLICK", {{|oGrid,cFieldName,nLineGrid,nLineModel| DoubleClick(oGrid,cFieldName,nLineGrid,nLineModel)}}) 
	
	//Amarrando a view com as box
	oView:SetOwnerView('OGA455_NBT','CABEC')
	oView:SetOwnerView('VWOGA455_NBU','DETALHES')
	oView:SetOwnerView( 'VIEW_CALC', 'RODAPE' )
	
	//Habilitando título
	oView:EnableTitleView('OGA455_NBT',STR0006) 	//'Dados para Transferência'
	oView:EnableTitleView('VWOGA455_NBU',STR0007)   //'Romaneios Envolvidos na Transferência'

	oView:AddUserButton( STR0013, 'SELECIONAR', {|x| OGA455SLCT(oModel)}) //"Selecionar Contratos"
	oView:AddUserButton( STR0012, 'NOTAS',      {|x| SelNotas(oModel)}) //"Selecionar Notas"


Return oView


/** {Protheus.doc} VldActveMd
Função que valida o modelo de dados antes da ativação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Marcelo Ferrari
@since:     05/12/2018
@Uso:       OGA700 - Negócios
@type function
*/
Static Function VldActveMd( oModel )
	Local lRetorno      := .t.
	Local nOperation    := oModel:GetOperation()
	Local cStatus       := NBT->( NBT_STATUS )

	if nOperation == MODEL_OPERATION_UPDATE
		If cStatus != "1"
			Help( ,,STR0016,, STR0017, 1, 0 ) //"Ajuda"#"A Opção de Exluir é somente para negócios com status 'Pendente'"
			lRetorno := .f.
		EndIf
	EndIf

Return( lRetorno )

/** {Protheus.doc} OGA455ROM
//"Gerando romaneio de entrada e Saída

@param: 	Nil
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	02/12/2014
@Uso: 		OG - Originação de Grãos
*/

Function OGA455ROM()
	Local oModel    as object
	Local oModel455 as object 
	Local nNBU		as numeric
	Local nQtdTotal := 0
	Local cAliasNBU  := GetNextAlias()

	Private _aLinha		:= {}
	//validação de geração.
	If NBT->NBT_STATUS != "1"
		Help( ,,STR0016,, "Romaneios já gerados", 1, 0 ) //"Ajuda"#"A Opção de Exluir é somente para negócios com status 'Pendente'"
		Return .T.
	EndIf

	//pegar o dados da transferência.
	oModel455 := FwLoadModel("OGA455")
	oModel455:SetOperation(MODEL_OPERATION_UPDATE) //operação de alterção					
	oModel455:Activate() //ativa o modelo	

	//group by nos contratos.
	BeginSQL alias cAliasNBU
	SELECT
		NBU_CODTRF,NBU_CTRORI,NBU_ROMDEV, SUM(NBU_QTDSEL) QTDSEL
	FROM
		%table:NBU% NBU
	WHERE
		NBU_FILIAL = %xFilial:NBU% AND
		NBU_CODTRF = %Exp:oModel455:GetValue("OGA455_NBT","NBT_CODTRF")% AND
		NBU.%notDel% GROUP BY NBU.NBU_CTRORI ,NBU.NBU_ROMDEV,NBU.NBU_CODTRF
	EndSql

	//agrupado por contrato e total da qtd
	While (cAliasNBU)->( !Eof() )
	//NBU (ITENS) GERA AS DEVOLUÇÕES
		nQtdTotal += (cAliasNBU)->(QTDSEL)
		If empty((cAliasNBU)->(NBU_ROMDEV))	
				
			oModel := FwLoadModel("OGA250")
			oModel:SetOperation( MODEL_OPERATION_INSERT )
			oModel:Activate()
			oModelNJJ := oModel:GetModel("NJJUNICO")
			oModelNJM := oModel:GetModel("NJMUNICO")
			//NJJ CABECALHO
			oModelNJJ:SetValue("NJJ_TIPENT","2") //define que é simbolico 
			oModelNJJ:SetValue("NJJ_TIPO","6") //devolucao
			oModelNJJ:SetValue("NJJ_CODCTR",(cAliasNBU)->(NBU_CTRORI))		
			oModelNJJ:SetValue("NJJ_PSSUBT",(cAliasNBU)->(QTDSEL))
			
			oModelNJJ:SetValue("NJJ_CODTRF",(cAliasNBU)->(NBU_CODTRF))		
		
			//INFORMAÇÕES DA NBT
			oModelNJJ:SetValue("NJJ_LOCAL" ,oModel455:GetValue("OGA455_NBT","NBT_LOCORI"))		
			oModelNJJ:SetValue("NJJ_TES"   ,oModel455:GetValue("OGA455_NBT","NBT_TESORI"))

			//NJM ITENS	
			oModelNJM:SetValue("NJM_ITEROM",PADL(1,TamSX3('NJM_ITEROM')[1],"0"))
	
			nItemTrf 	:= 0
			_aItensTrf  := {}
			_aLinha 	:= {}
			For nNBU := 1 to oModel455:GetModel("OGA455_NBU"):Length()	
			//filtrar o ctr
				oModel455:GetModel("OGA455_NBU"):GoLine(nNBU)
				
				If oModel455:GetModel("OGA455_NBU"):GetValue("NBU_CTRORI") == (cAliasNBU)->(NBU_CTRORI)
					//adiciona a nota fiscal de origem para a dev.
					aVlrNJM = GetDataSqA( "SELECT SUM(NJM_QTDFIS) NJM_QTDFIS, " + ;
										"SUM(NJM_VLRUNI * NJM_QTDFIS) / SUM(NJM_QTDFIS) PONDERADO " + ;
										"FROM " + RetSqlName("NJM") + " NJM " + ;
										"WHERE NJM_CODROM = '" + oModel455:GetValue("OGA455_NBU","NBU_ROMORI") + "' " + ;
										"AND NJM.D_E_L_E_T_ = ' ' " )
									
					nItemTrf += 1
					aAdd(_aItensTrf, {NJJ->(Recno()),;
						'0'+cValToChar(Len(_aItensTrf)+1),; //"C6_ITEM"   , cItemSeq
						oModelNJJ:GetValue("NJJ_CODPRO"),;				//"C6_PRODUTO", cProduto
						oModelNJJ:GetValue("NJJ_TES"),;							//"C6_TES"    , cTes
						oModel455:GetValue("OGA455_NBU","NBU_QTDSEL"),;							//"C6_QTDVEN" , nQuant
						oModel455:GetValue("OGA455_NBU","NBU_QTDSEL"),;							//"C6_QTDLIB" , nQuant
						aVlrNJM[2],;						//"C6_PRCVEN" , nPreco
						(oModel455:GetValue("OGA455_NBU","NBU_QTDSEL")*aVlrNJM[2]),;						//"C6_VALOR"  , nTotal
						oModelNJJ:GetValue("NJJ_LOCAL"),;							// "C6_LOCAL" , cLocal
						oModelNJJ:GetValue("NJJ_CODCTR"),;						//"C6_CTROG"  , cCodCtr
						oModelNJJ:GetValue("NJJ_CODSAF"),;				//"C6_CODSAF" , cCodSaf
						oModel455:GetValue("OGA455_NBU","NBU_NFORI"),;							//"C6_CODROM" , cCodDocC6
						PADL(1,TamSX3('C6_ITEM')[1],"0")})

						OGA455DDPD(nItemTrf,oModel455:GetModel("OGA455_NBU"),nNBU)	
				EndIf
			Next nNBU
			//Commit
			If oModel:VldData()
				oModel:CommitData()
					For nNBU := 1 to oModel455:GetModel("OGA455_NBU"):Length()	
						//filtrar o ctr
						oModel455:GetModel("OGA455_NBU"):GoLine(nNBU)
					
						If oModel455:GetModel("OGA455_NBU"):GetValue("NBU_CTRORI") == (cAliasNBU)->(NBU_CTRORI)
				
							oModel455:SetValue("OGA455_NBU","NBU_ROMDEV",oModelNJJ:GetValue("NJJ_CODROM"))
							oModel455:SetValue("OGA455_NBU","NBU_DATDEV",oModelNJJ:GetValue("NJJ_DATA"))
							oModel455:SetValue("OGA455_NBU","NBU_TESDEV",oModelNJJ:GetValue("NJJ_TES"))	
						EndIf	
					Next nNBU
			
				oModel:DeActivate() // Desativa o modelo
				oModel:Destroy() // Destroy o objeto modelo	
			Else
				AutoGrLog(oModel:GetErrorMessage()[6])
				AutoGrLog(oModel:GetErrorMessage()[7])
				If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
					AutoGrLog(oModel:GetErrorMessage()[2] + " = " + cValToChar(oModel:GetErrorMessage()[9]))
				EndIf

				MostraErro()
			EndIf
			//atualiza romaneio.	
			If OGA250ATUC( Alias(), Recno(), 4, .t. ) 

					For nNBU := 1 to oModel455:GetModel("OGA455_NBU"):Length()	
						//filtrar o ctr
						oModel455:GetModel("OGA455_NBU"):GoLine(nNBU)
					
						If oModel455:GetModel("OGA455_NBU"):GetValue("NBU_CTRORI") == (cAliasNBU)->(NBU_CTRORI)			
							oModel455:SetValue("OGA455_NBU","NBU_DOCDEV",NJJ->NJJ_DOCNUM)
						EndIf	
					Next nNBU		
			EndIf 
			
		EndIf
		(cAliasNBU)->(DbSkip())	
	Enddo
	(cAliasNBU)->(DbCloseArea())

	//VERIFICO SE FOI GERADO JÁ A ENTRADA //ROMDES
	If fGeraRem(oModel455:GetValue("OGA455_NBT","NBT_CODTRF"))
		
		//NBT (CABECALHO) GERA A NOVA REMESSA
		oModel := FwLoadModel("OGA250")
		oModel:SetOperation( MODEL_OPERATION_INSERT )
		oModel:Activate()
		oModelNJJ := oModel:GetModel("NJJUNICO")
		oModelNJM := oModel:GetModel("NJMUNICO")

		//NJJ CABECALHO
		oModelNJJ:SetValue("NJJ_TIPENT","2") //define que é simbolico 
		oModelNJJ:SetValue("NJJ_TIPO","3") //remessa
		oModelNJJ:SetValue("NJJ_CODCTR",oModel455:GetValue("OGA455_NBT","NBT_CTRDES"))		
		oModelNJJ:SetValue("NJJ_PSSUBT",nQtdTotal)

		oModelNJJ:SetValue("NJJ_TPFORM",oModel455:GetValue("OGA455_NBT","NBT_TPFORM"))	

		If oModel455:GetValue("OGA455_NBT","NBT_TPFORM") == '2'
			oModelNJJ:SetValue("NJJ_DOCSER",oModel455:GetValue("OGA455_NBT","NBT_DOCSER"))	
			oModelNJJ:SetValue("NJJ_DOCNUM",Alltrim(oModel455:GetValue("OGA455_NBT","NBT_DOCNUM")))
			oModelNJJ:SetValue("NJJ_DOCEMI",oModel455:GetValue("OGA455_NBT","NBT_DOCEMI"))	
			oModelNJJ:SetValue("NJJ_DOCESP",oModel455:GetValue("OGA455_NBT","NBT_DOCESP"))
			oModelNJJ:SetValue("NJJ_QTDFIS",nQtdTotal)
		
			If !Empty(oModel455:GetValue("OGA455_NBT","NBT_CHVNFE"))
				oModelNJJ:SetValue("NJJ_CHVNFE",oModel455:GetValue("OGA455_NBT","NBT_CHVNFE"))
			EndIf	
		EndIf

		oModelNJJ:SetValue("NJJ_CODTRF",oModel455:GetValue("OGA455_NBT","NBT_CODTRF"))		
		oModelNJJ:SetValue("NJJ_VLRUNI",oModel455:GetValue("OGA455_NBT","NBT_VLRUNI"))			
		oModelNJJ:SetValue("NJJ_VLRTOT",oModel455:GetValue("OGA455_NBT","NBT_VLRTOT"))			
		oModelNJM:SetValue("NJM_ITEROM",PADL(1,TamSX3('NJM_ITEROM')[1],"0"))
		oModelNJJ:SetValue("NJJ_LOCAL" ,oModel455:GetValue("OGA455_NBT","NBT_LOCDES"))		
		oModelNJJ:SetValue("NJJ_TES"   ,oModel455:GetValue("OGA455_NBT","NBT_TESDES"))	

		If oModel:VldData()
			oModel:CommitData()
				
			oModel:DeActivate() // Desativa o modelo
			oModel:Destroy() // Destroy o objeto modelo	
		Else
			AutoGrLog(oModel:GetErrorMessage()[6])
			AutoGrLog(oModel:GetErrorMessage()[7])
			If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
				AutoGrLog(oModel:GetErrorMessage()[2] + " = " + cValToChar(oModel:GetErrorMessage()[9]))
			EndIf

			MostraErro()
		EndIf

		//atualiza 
		If OGA250ATUC( Alias(), Recno(), 4, .t. )
			for nNBU := 1 to oModel455:GetModel("OGA455_NBU"):Length()
				oModel455:GetModel("OGA455_NBU"):GoLine(nNBU)
				oModel455:SetValue("OGA455_NBU","NBU_ROMDES",NJJ->NJJ_CODROM)
				oModel455:SetValue("OGA455_NBU","NBU_DATTRF",NJJ->NJJ_DATA)
				oModel455:SetValue("OGA455_NBU","NBU_TESTRF",NJJ->NJJ_TES)
				oModel455:SetValue("OGA455_NBU","NBU_DOCTRF",NJJ->NJJ_DOCNUM)			
			Next nNBU
		EndIf
		
		oModel455:SetValue("OGA455_NBT","NBT_STATUS","3")//gerado			
		
		If oModel455:VldData()
			oModel455:CommitData()

			oModel455:DeActivate() // Desativa o modelo
			oModel455:Destroy() // Destroy o objeto modelo	
		Else
			AutoGrLog(oModel455:GetErrorMessage()[6])
			AutoGrLog(oModel455:GetErrorMessage()[7])
			If !Empty(oModel455:GetErrorMessage()[2]) .And. !Empty(oModel455:GetErrorMessage()[9])
				AutoGrLog(oModel455:GetErrorMessage()[2] + " = " + cValToChar(oModel455:GetErrorMessage()[9]))
			EndIf

			MostraErro()
		EndIf
	EndIf

Return( .T. )

/*/{Protheus.doc} fGeraRem
	Verifica se foi gerado a nota fiscal de remessa.
	@type  Static Function
	@author mauricio.joao
	@since 05/02/2020
	@version 1.0
	@param cCodTrf, char, codigo da transferencia.
	/*/
Static Function fGeraRem(cCodtrf)
Local lReturn := .F.
Local nNBU  := GetNextAlias()

BeginSQL alias nNBU
SELECT
	NBU.NBU_ROMDES
FROM
%table:NBU% NBU
WHERE
	NBU_FILIAL = %xFilial:NBU% AND
	NBU_CODTRF = %Exp:cCodtrf% AND
	NBU.%notDel% GROUP BY NBU.NBU_ROMDES
EndSql

If Empty((nNBU)->( NBU_ROMDES ))
	lReturn := .T.
EndIf
(nNBU)->(DbCloseArea())

Return lReturn


/*/{Protheus.doc} SelNfsDev
Função auxiliar para seleção de documentos de origem para amarracao na NF de devolução.
@author joaquim.burjack
@since 05/12/2018
@version 1.0
@param cCodCtr, characters, descricao
@param nQtdDev, numeric, descricao
@param cProduto, characters, descricao
@param cLoteCtl, characters, descricao
@type function
/*/
Function SelNotas( oMdl)
	Local aRetorno      := {}
	Local aAreaAtu      := GetArea()
	Local cProduto      := Posicione("NJR",1,FwXfilial("NJR")+oMdl:getModel("OGA455_NBU"):GetValue("NBU_CTRORI"),"NJR_CODPRO")
	Local cCodCtr       := oMdl:getModel("OGA455_NBU"):GetValue("NBU_CTRORI")
	Local nQtdDev       := oMdl:getModel("OGA455_NBU"):GetValue("NBU_QTDCTR")   
	Local oSize         := Nil
	Local oDlg          := Nil
	Local oPnUm         := Nil
	Local oPnDois       := Nil
	Local oFont         := Nil	
	Local aButtons      := {}
	Local aAux          := {}
	Local nOpcao        := 0
	Local nY            := 0	
	Local cTesNFT       := AllTrim(SuperGetMV( "MV_TESNFT",, "" ))		
	Local oGridNBU  	:= oMdl:GetModel("OGA455_NBU")
	Local nZ        	:= 0
	Local nX            := 0	
	Local nLinha 		:= 0	
	Private oBrowse     := Nil
	Private oSay        := Nil
	Private nQtdAdl     := nQtdDev
	Private nQtdSel     := 0
	Private cAliasNNC   := ''

	If !Empty(oGridNBU:GetValue("NBU_ROMDES")) .AND. ;
	   !Empty(oGridNBU:GetValue("NBU_ROMDEV"))
	    
		Return( aRetorno )
	EndIf

	aAdd( aButtons, { "", {|| EditQtd()}, OemToAnsi( STR0030 )}) //"Editar"

	BeginSql Alias "Qry1"
		Select
		SD1.D1_DOC,
		SD1.D1_SERIE,
		SD1.D1_EMISSAO,
		SD1.D1_ITEM,
		SD1.D1_TES,
		SD1.D1_QUANT,
		SD1.D1_VUNIT,
		SD1.D1_TOTAL,
		SD1.D1_CODROM,
		SD1.D1_ITEROM,
		( SD1.D1_QUANT - SD1.D1_QTDEDEV ) as D1_SALDO,
		SD1.D1_IDENTB6,
		SD1.D1_LOTECTL
		From
		%Table:SD1% SD1
		Where
		SD1.D1_FILIAL  = %xFilial:SD1% And
		SD1.D1_CTROG   = %exp:cCodCtr% And
		SD1.D1_COD     = %exp:cProduto% AND
		( SD1.D1_QUANT - SD1.D1_QTDEDEV ) > 0 And
		SD1.%NotDel%
		Order By
		SD1.D1_EMISSAO,
		SD1.D1_SERIE,
		SD1.D1_DOC
	EndSql
	Qry1->( dbGoTop() )
	If Qry1->( Eof() )
		Qry1->( dbCloseArea() )
		RestArea( aAreaAtu )
		lNFOrigem := .F.
		Return( aRetorno )
	EndIf
	While .Not. Qry1->( Eof() )

		If SuperGetMV( "MV_OGUSANT",, .F. )

			If Qry1->( D1_TES ) = cTesNFT
				Qry1->( DbSkip() )
				Loop
			Endif
		Endif

		cSql    := "SELECT SUM(B6_SALDO) QTD_SALDO  " + ;
					"FROM " + RetSqlName("NJJ") + " NJJ " + ;
					"INNER JOIN " + RetSqlName("NJ0") + "  NJ0 ON " + ;
					"   NJ0_FILIAL = '" + fwXFilial("NJ0") + "' AND " + ;
					"   NJ0_CODENT = NJJ_CODENT AND " + ;
					"   NJ0_LOJENT = NJJ_LOJENT AND " + ;
					"   NJ0.D_E_L_E_T_ = ' '" + ;
					"INNER JOIN " + RetSqlName("SB6") + " SB6 ON " + ;
					"   B6_FILIAL = '" + fwXFilial("SB6") + "' AND " + ;
					"   NJJ_CODPRO = B6_PRODUTO AND " + ;
					"   NJ0_CODCLI = B6_CLIFOR AND " + ;
					"   NJ0_LOJCLI = B6_LOJA AND " + ;
					"   NJJ_DOCNUM = B6_DOC AND " + ;
					"   NJJ_DOCSER = B6_SERIE AND " + ;
					"   NJJ.D_E_L_E_T_ = SB6.D_E_L_E_T_ " + ;
					"WHERE 1=1 " + ;
					"AND NJJ_CODROM  = '" + Qry1->( D1_CODROM )  + "' " + ;
					"AND NJJ_DOCEMI  = '" + Qry1->( D1_EMISSAO )  + "' " + ;
					"AND NJJ_TIPO    = '3' " + ;
					"AND NJJ.D_E_L_E_T_ = ' ' " 
			
			nQtdSld :=  GetDataSql(cSql)
		If nQtdSld == 0
			Qry1->( dbSkip() )
			Loop
		End
		aAdd( aAux, Array( COL_COUNT ) )
		aAux[ Len( aAux ), COL_MARK     ] := "0"
		aAux[ Len( aAux ), COL_CTR      ] := cCodCtr
		aAux[ Len( aAux ), COL_ROM      ] := Qry1->( D1_CODROM   )
		aAux[ Len( aAux ), COL_TES      ] := Qry1->( D1_TES   )
		aAux[ Len( aAux ), COL_DOC      ] := Qry1->( D1_DOC   )
		aAux[ Len( aAux ), COL_SERIE    ] := Qry1->( D1_SERIE )
		aAux[ Len( aAux ), COL_EMISSAO  ] := DTOC( STOD( Qry1->( D1_EMISSAO ) ) )
		aAux[ Len( aAux ), COL_ITEM     ] := Qry1->( D1_ITEM  )
		aAux[ Len( aAux ), COL_QUANT    ] := Qry1->( D1_QUANT )
		//aAux[ Len( aAux ), COL_QTDFIX   ] := nQtdSld
		aAux[ Len( aAux ), COL_VUNIT    ] := A410Arred( Qry1->( D1_VUNIT ), "C6_PRCVEN" )
		aAux[ Len( aAux ), COL_VTOTAL   ] := Qry1->( D1_TOTAL )
		aAux[ Len( aAux ), COL_SALDO    ] := nQtdSld 
		aAux[ Len( aAux ), COL_DISTRIB  ] := 0
		aAux[ Len( aAux ), COL_VDISTR   ] := 0
		aAux[ Len( aAux ), COL_IDENTB6  ] := Qry1->( D1_IDENTB6 )
		aAux[ Len( aAux ), COL_LOTECTL  ] := Qry1->( D1_LOTECTL )

		//Qtd de devolução
		If nQtdAdl > 0            
			//Se o saldo da nota for diferente de zero        
			If !Qry1->( D1_SALDO )== 0 
				//Se q qtd de devolucao for maior ou igual que saldo
				If  nQtdAdl > nQtdSld 
					aAux[ Len( aAux ), COL_MARK     ] := "1"
					aAux[ Len( aAux ), COL_DISTRIB  ] := aAux[ Len( aAux ), COL_SALDO ]
					nQtdAdl -= aAux[ Len( aAux ), COL_SALDO ]
					nQtdSel += aAux[ Len( aAux ), COL_SALDO ]

					//Senao a qtd da nota for maior que a fixacao
				Elseif nQtdAdl <= nQtdSld  
					aAux[ Len( aAux ), COL_MARK     ] := "1"
					aAux[ Len( aAux ), COL_DISTRIB  ] := nQtdAdl 
					nQtdSel += nQtdAdl
					nQtdAdl := 0
				EndIf
			Endif

			//Tratando arrendondamentos chamado TUQTSG
			//aAux[ Len( aAux ), COL_VDISTR     ] := A410Arred( aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ], "C6_VALOR" ) 
			aAux[ Len( aAux ), COL_VUNIT    ] := aAux[ Len( aAux ), COL_VTOTAL ] / aAux[ Len( aAux ), COL_QUANT ]
			aAux[ Len( aAux ), COL_VDISTR   ] := aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ]
		EndIf

		aAux[ Len( aAux ), COL_VAZIO ] := "1"

		Qry1->( dbSkip() )
	EndDo
	Qry1->( dbCloseArea() )

	If len(aAux) == 0
		MsgAlert(STR0062) //"Não existem saldos em terceiros disponiveis para esse contrato."
		Return
	EndIf

	oSize := FwDefSize():New()
	oSize:AddObject( "P1", 100, 80, .t., .t., .t. )
	oSize:AddObject( "P2", 100, 20, .t., .t., .t. )
	oSize:lProp     := .t.
	oSize:aMargins  := { 3, 3, 3, 3 }
	oSize:Process()

	oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], STR0063,,,,,CLR_BLACK,CLR_WHITE,,,.t.)

	oPnUm   := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" ),oSize:GetDimension( "P1", "YSIZE" ) )
	oPnDois := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ),oSize:GetDimension( "P2", "YSIZE" ) )

	oBrowse := TCBrowse():New( 01, 01, 260, 156, , , , oPnUm, , , , , , , , , , , , .f., ,.t., , .f. )

	//oBrowse:AddColumn( TCColumn():New( ""      , {|| IIf( aAux[oBrowse:nAt, COL_MARK ] == "1", oStX, oStO )}             				  ,,,,"CENTER", 040,.t.,.t.,,,,.f.,))
	oBrowse:AddColumn( TCColumn():New( STR0031 , {|| aAux[ oBrowse:nAt, COL_CTR                     	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"Contrato"
	oBrowse:AddColumn( TCColumn():New( STR0032 , {|| aAux[ oBrowse:nAt, COL_ROM                     	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"Romaneio"
	oBrowse:AddColumn( TCColumn():New( STR0033 , {|| aAux[ oBrowse:nAt, COL_TES                     	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"TES"
	oBrowse:AddColumn( TCColumn():New( STR0034 , {|| aAux[ oBrowse:nAt, COL_SERIE                     	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"Serie" 
	oBrowse:AddColumn( TCColumn():New( STR0035 , {|| aAux[ oBrowse:nAt, COL_DOC                       	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"Numero"
	oBrowse:AddColumn( TCColumn():New( STR0036 , {|| aAux[ oBrowse:nAt, COL_EMISSAO                   	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"Emissao"
	oBrowse:AddColumn( TCColumn():New( STR0037 , {|| aAux[ oBrowse:nAt, COL_ITEM                      	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"Item"
	oBrowse:AddColumn( TCColumn():New( STR0038 , {|| aAux[ oBrowse:nAt, COL_IDENTB6                   	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))//"Ident"
	oBrowse:AddColumn( TCColumn():New( STR0040 , {|| Transform( aAux[ oBrowse:nAt, COL_QUANT          	  ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT" ,    ,.f.,.t.,,,,.f.,))//"Quantidade"
	oBrowse:AddColumn( TCColumn():New( STR0042 , {|| Transform( aAux[ oBrowse:nAt, COL_VUNIT          	  ], PesqPict("SC6","C6_PRCVEN"))},,,,"RIGHT" ,    ,.f.,.t.,,,,.f.,))//"Vlr. Unit."
	oBrowse:AddColumn( TCColumn():New( STR0043 , {|| Transform( aAux[ oBrowse:nAt, COL_VTOTAL             ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT" ,    ,.f.,.t.,,,,.f.,))//"Vlr. Total" 
	oBrowse:AddColumn( TCColumn():New( STR0064 , {|| Transform( aAux[ oBrowse:nAt, COL_SALDO   			  ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT" ,    ,.f.,.t.,,,,.f.,))//"Saldo"
	oBrowse:AddColumn( TCColumn():New( STR0045 , {|| Transform( aAux[ oBrowse:nAt, COL_DISTRIB            ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT" ,    ,.f.,.t.,,,,.f.,))//"Selecionada"
	oBrowse:AddColumn( TCColumn():New( STR0046 , {|| Transform( aAux[ oBrowse:nAt, COL_VDISTR         	  ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT" ,    ,.f.,.t.,,,,.f.,))//"Valor Selec."
	oBrowse:AddColumn( TCColumn():New( " "     , {|| aAux[ oBrowse:nAt, COL_VAZIO                     	  ]}                              ,,,,"LEFT"  ,    ,.f.,.t.,,,,.f.,))
	oBrowse:SetArray( aAux )
	oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oBrowse:bLDblClick  := {|| MarcaUm( aAux, oBrowse:nAt, nQtdDev ) }

	oFont   := TFont():New( "Courier new", , -16, .t. )
	oSay    := TSay():New( 01, 01, {|| RetTexto( aAux, nQtdDev ) }, oPnDois, , oFont, , , , .t., CLR_RED, CLR_WHITE, 200, 20 )
	oSay:Align := CONTROL_ALIGN_ALLCLIENT

	oDlg:Activate( , , , .t., {|| nQtdDev = nQtdSel }, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() },, @aButtons ) } )

	If nOpcao = 1 

		For nY := 1 to Len( aAux )
			If aAux[ nY, COL_MARK ] = "1"
				aAdd( aRetorno, aAux[ nY ] )
			EndIf
		Next nY
		
		If Empty(aRetorno)
			oGridNBU:Goline( 1 )
			RestArea( aAreaAtu )
			Return	
		EndIf

		//Percorre o Grid e verifica quais posicões de Avalores ja estão gravados com Romaneio
		For nX := 1 to oGridNBU:Length()
			oGridNBU:Goline( nX )
			For nZ := 1 to len(aRetorno)
				If aRetorno[nZ][2] == oGridNBU:GetValue("NBU_CTRORI") 
					aAdd(aRetorno[nZ], oGridNBU:GetValue("NBU_QTDCTR") )
					If !(oGridNBU:IsDeleted())
						oGridNBU:DeleteLine()
					EndIf
				EndIf
			Next nZ
			
		Next nX

		//Insere dados ao submodelo da tela
		oGridNBU:Goline(oGridNBU:Length() )
		nLinha := oGridNBU:Length()
		For nZ := 1 to Len(aRetorno)
			nLinha++
			oGridNBU:SetNoInsertLine( .F. )
			If (nLinha == 1) .AND. ;			   
			   ( (oGridNBU:IsDeleted) .OR. ;
			     ( !Empty(oGridNBU:GetValue("NBU_ROMDES") ) .AND. ;
			       !Empty(oGridNBU:GetValue("NBU_ROMDEV"))  ) )
				   
				nLinha++
				oGridNBU:AddLine()
			Else
				oGridNBU:AddLine()
			EndIf
			
			oGridNBU:Goline(nLinha)
			If oGridNBU:IsDeleted()
				oGridNBU:UnDeleteLine()
			Endif

			oGridNBU:LoadValue("NBU_ITEM",StrZero(oMdl:GetModel('OGA455_NBU'):Length(), TamSX3( "NBU_ITEM" )[1]) )
			omdl:SetValue( 'OGA455_NBU', 'NBU_FILIAL', 	FwXfilial("NBU") )
			omdl:SetValue( 'OGA455_NBU', 'NBU_CODTRF', 	oMdl:getModel("OGA455_NBT"):GetValue("NBT_CODTRF") )
			omdl:SetValue( 'OGA455_NBU', 'NBU_CTRORI', 	ARETORNO[nZ][2] )
			omdl:SetValue( 'OGA455_NBU', 'NBU_ROMORI', 	ARETORNO[nZ][3] )
			omdl:SetValue( 'OGA455_NBU', 'NBU_DATORI', 	CTOD(ARETORNO[nZ][7]) )
			omdl:SetValue( 'OGA455_NBU', 'NBU_TESORI', 	ARETORNO[nZ][4] )
			omdl:SetValue( 'OGA455_NBU', 'NBU_NFORI', 	ARETORNO[nZ][5] )
			omdl:SetValue( 'OGA455_NBU', 'NBU_QTDORI',	ARETORNO[nZ][13] )
			omdl:SetValue( 'OGA455_NBU', 'NBU_QTDSEL',	ARETORNO[nZ][14] )
			omdl:SetValue( 'OGA455_NBU', 'NBU_QTDCTR',	ARETORNO[nZ][Len( ARETORNO[nZ] )] )

			cSql := " SELECT *  FROM  " + RetSqlName("NJR") + "  NJR"
			cSql += " WHERE NJR_FILIAL = '" + FWxFilial("NJR") + "'"
			cSql += "   AND NJR_CODCTR = '" + ARETORNO[nZ][2]  + "'"
			cAliasNJR := GetSqlAll(cSql)

			oGridNBU:LoadValue("NBU_ENTORI",(cAliasNJR)->NJR_CODENT)
			oGridNBU:LoadValue("NBU_LOJORI",(cAliasNJR)->NJR_LOJENT)
			oGridNBU:LoadValue("NBU_TABORI",(cAliasNJR)->NJR_CODTSE)
			oGridNBU:LoadValue("NBU_NOMENT",Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,"NJ0_NOME"))
			oGridNBU:LoadValue("NBU_NLJENT",Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,"NJ0_NOMLOJ"))
			oGridNBU:LoadValue("NBU_DESTBO",Posicione("NNI",1,FWxFilial("NNI")+(cAliasNJR)->NJR_TABELA,"NNI_DESCRI"))

			oGridNBU:SetNoInsertLine( .T. )
		Next nZ

	EndIf
	
	//Calculo para dividir o valor da nota pela quantidade selecionada
	if !EMPTY(oMdl:GetModel("OGA455_NBT"):GetValue("NBT_VLRTOT"))
		//Calcula o valor unitário.
		OGA455ClUn(omdl)
	endIf

	RestArea( aAreaAtu )
Return( aRetorno )


/** {Protheus.doc} MarcaUm
*/
Static Function MarcaUm( aItsMrk, nLinMrk, nQtdDev )

	Do Case
		Case aItsMrk[ nLinMrk, COL_MARK ] == "0" .and. aItsMrk[ nLinMrk, COL_SALDO ] > 0

		If nQtdAdl > 0
			If nQtdAdl >= aItsMrk[ nLinMrk, COL_SALDO ]
				aItsMrk[ nLinMrk, COL_MARK      ] := "1"
				aItsMrk[ nLinMrk, COL_DISTRIB   ] := aItsMrk[ nLinMrk, COL_SALDO ]
				nQtdAdl -= aItsMrk[ nLinMrk, COL_SALDO ]
			Else
				aItsMrk[ nLinMrk, COL_MARK      ] := "1"
				aItsMrk[ nLinMrk, COL_DISTRIB   ] := nQtdAdl
				nQtdAdl := 0
			EndIf          
			aItsMrk[ nLinMrk, COL_VUNIT     ] := aItsMrk[ nLinMrk, COL_VTOTAL ] / aItsMrk[ nLinMrk, COL_QUANT ]
			aItsMrk[ nLinMrk, COL_VDISTR    ] := aItsMrk[ nLinMrk, COL_DISTRIB ] * aItsMrk[ nLinMrk, COL_VUNIT ]
		EndIf

		Case aItsMrk[ nLinMrk, COL_MARK ] == "1"
		aItsMrk[ nLinMrk, COL_MARK ] := "0"
		nQtdAdl += aItsMrk[ nLinMrk, COL_DISTRIB ]
		aItsMrk[ nLinMrk, COL_DISTRIB ] := 0
		aItsMrk[ nLinMrk, COL_VDISTR  ] := 0

	EndCase

	oSay:Refresh()
	oBrowse:Refresh()

Return( )

/*/{Protheus.doc} RetTexto
description
@type function
/*/
Static Function RetTexto( aItsMrk, nQtdDev )
	Local cTexto        := ""
	Local nX            := 0

	nQtdSel         := 0

	For nX := 1 to Len( aItsMrk )

		If aItsMrk[ nX, COL_MARK ] = "1"
			nQtdSel += aItsMrk[ nX, COL_DISTRIB ]
		EndIf
	Next nX

	cTexto += STR0065 + Transform( nQtdDev, "@E 999,999,999.99" )
	cTexto += Chr( 13 ) + Chr( 10 )
	cTexto += STR0066 + Transform( nQtdSel, "@E 999,999,999.99" )

Return( cTexto )

/*/{Protheus.doc} EditQtd
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 14/12/2018
@version 1.0
@type function
/*/
Static Function EditQtd()

	Local   nOpcao      := 0		
	Local   oDlg        := Nil
	Local   lMark       := oBrowse:aArray[ oBrowse:nAt, COL_MARK    ] = "1"
	Local   nQtdAnt :=  oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ]
	Local   nQtdSal :=  oBrowse:aArray[ oBrowse:nAt, COL_SALDO  ]
	Private nQtdNew :=  oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ]

	If lMark
		Define MsDialog oDlg Title STR0004 From 9,0 to 20,50 Of oMainWnd //"Alterar"
		@ 030,015 Say OemToAnsi(STR0040) Of oDlg Pixel            //"Quantidade: "
		@ 030,065 MsGet nQtdNew  Valid nQtdNew >= 0 .And. nQtdNew <= nQtdSal Picture("@E 999,999,999,999.99") Size 070, 010  Of oDlg Pixel
		Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() })
		If nOpcao == 1
			If  nQtdNew = 0
				oBrowse:aArray[ oBrowse:nAt, COL_MARK   ] := "0"
				oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ] := 0
			Else
				oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ] := nQtdNew
			EndIf

			oBrowse:aArray[ oBrowse:nAt, COL_VDISTR     ] := A410Arred( oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ] * oBrowse:aArray[ oBrowse:nAt, COL_VUNIT ], "C6_VALOR")

			nQtdAdl :=  nQtdAdl + ( nQtdAnt - nQtdNew )

			oSay:Refresh()
			oBrowse:Refresh()
		EndIf
	EndIf
Return( Nil )

/*/{Protheus.doc} OGA455SLCT
//Reponsável por passar por parametro os contratos já selecionados, se existirem, para a função de seleção de contratos
//Receber os contratos selecionados e refazer a grid da NBU com eles.
@author brunosilva
@since 19/12/2018
@version 1.0
@return lRet, lógico, se a função deu certo ou não.
@param oModel, object, modelo de dados da tela.
@type function
/*/
Static Function OGA455SLCT(oModel)
	Local lRet 			:= .T.
	Local aCtrSelec 	:= {}
	Local aCtrAdc		:= {}
	Local oMdlNBT		:= oModel:GetModel("OGA455_NBT")
	Local oMdlNBU		:= oModel:GetModel("OGA455_NBU")
	Local nOperation    := oModel:GetOperation()
	Local nX
	
	//Caso existam contratos já selecionados, alimento o array para enviar para a função de selecionar contratos
	//   para que os contratos já selecionados sejam selecionados já na abertura da tela.
	if !EMPTY(oMdlNBU:GetValue("NBU_CTRORI"))
		for nX := 1 to oMdlNBU:Length()
			oMdlNBU:Goline(nX)
			If !(oMdlNBU:IsDeleted())
			   aAdd(aCtrSelec, {oMdlNBU:GetValue("NBU_CTRORI"), oMdlNBU:GetValue("NBU_QTDCTR"),iif(EMPTY(oMdlNBU:GetValue("NBU_ROMDEV")),.T.,.F.)})
			EndIf
		next nX	
	endIf
	
	//função da seleção de contratos. Aadd(aRotina,aRetM[Nx])
	aCtrAdc := OGA455A(aCtrSelec, oMdlNBT:GetValue("NBT_CODTRF"))	
	
	if !EMPTY(aCtrAdc) .AND. ((nOperation = MODEL_OPERATION_INSERT) .OR. (nOperation= MODEL_OPERATION_UPDATE)) 
		//Preenche a GRID do NBU
		InsGridNBU(aCtrAdc, oModel)
	endIf
	
return lRet

/*/{Protheus.doc} InsGridNBU
//Responsável por preencher a GRID da NBU
@author brunosilva
@since 20/12/2018
@version 1.0
@return lRet, lógico
@param aValores, array, descricao
@param oMdl, object, descricao
@type function
/*/
Static Function InsGridNBU(aValores, oMdl)
	Local oGridNBU 		:= oMdl:GetModel("OGA455_NBU")
	Local oView			:= FwViewActive()
	Local nOperation	:= oMdl:GetOperation()
	Local nLinha 		:= 0	
	Local nX			:= 1	

	IF nOperation = MODEL_OPERATION_INSERT
		oGridNBU:cleardata()
		oGridNBU:InitLine()
	EndIf
	
	//Percorre o Grid e verifica quais posicões de Avalores ja estão gravados com Romaneio
	For nX := 1 to oGridNBU:Length()
	    oGridNBU:Goline( nX )
		nPosCtr := ASCAN(aValores,{|x| x[1] == oGridNBU:GetValue("NBU_CTRORI") })
		If nPosCtr > 0
			aValores[nPosCtr][3] += AllTrim(Str(nX)) + "|"
		Else
			if nPosCtr = 0 .AND. !(oGridNBU:Length() == 1 .AND. EMPTY(oGridNBU:GetValue("NBU_CTRORI")))
				oGridNBU:DeleteLine()
			endIf
		EndIf
	Next nX

	for nX := 1 to Len(aValores)
		aLins := StrTokArr( aValores[nX][3], "|" )
		If !Empty(aLins)
			//Aqui atualiza
			For nLinha := 1 to Len(aLins)
				oGridNBU:Goline( Val(aLins[nLinha]) )
				If oGridNBU:IsDeleted()
					oGridNBU:UnDeleteLine()
				Endif
				UpdGridNBU(aValores, nX, oMdl)
			Next nY
		Else
		   //Aqui Adiciona
			oGridNBU:SetNoInsertLine( .F. )
			IF oGridNBU:Length() == 1 .AND. !(EMPTY(oGridNBU:GetValue("NBU_CTRORI")))
				oGridNBU:AddLine()
			endIf
			oGridNBU:Goline( oGridNBU:Length() )
			UpdGridNBU(aValores, nX, oMdl, .T.)
		EndIf
	Next nX

	oGridNBU:Goline(1)
	oGridNBU:SetNoInsertLine( .T. )

	oView:Refresh("VWOGA455_NBU")

Return


Static Function UpdGridNBU(aValores, nX, oMdl, lAdd )
	Local oGridNBU 	:= oMdl:GetModel("OGA455_NBU")
	Local cSql		:= ""
	Local lRet		:= .T.

	Default lAdd := .F.

	If !(oGridNBU:IsDeleted()) .AND. ;
		Empty(oGridNBU:GetValue("NBU_ROMDES")) .AND. ;
		Empty(oGridNBU:GetValue("NBU_ROMDEV")) 

		cSql := " SELECT *  FROM  " + RetSqlName("NJR") + "  NJR"
		cSql += " WHERE NJR_FILIAL = '" + FWxFilial("NJR") + "'"
		cSql += "   AND NJR_CODCTR = '" + aValores[nX][1]  + "'"
		cAliasNJR := GetSqlAll(cSql)

		If lAdd
		   oGridNBU:LoadValue("NBU_ITEM",StrZero(oMdl:GetModel('OGA455_NBU'):Length(), TamSX3( "NBU_ITEM" )[1]) )
		EndIf
		oGridNBU:LoadValue("NBU_FILIAL",FWxFilial("NBU"))
		oGridNBU:LoadValue("NBU_CODTRF",oMdl:getModel("OGA455_NBT"):GetValue("NBT_CODTRF"))
		oGridNBU:LoadValue("NBU_CTRORI",(cAliasNJR)->NJR_CODCTR)
		oGridNBU:LoadValue("NBU_QTDCTR",aValores[nX][2])
		oGridNBU:LoadValue("NBU_ENTORI",(cAliasNJR)->NJR_CODENT)
		oGridNBU:LoadValue("NBU_LOJORI",(cAliasNJR)->NJR_LOJENT)
		oGridNBU:LoadValue("NBU_TABORI",(cAliasNJR)->NJR_CODTSE)
		oGridNBU:LoadValue("NBU_NOMENT",Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,"NJ0_NOME"))
		oGridNBU:LoadValue("NBU_NLJENT",Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT,"NJ0_NOMLOJ"))
		oGridNBU:LoadValue("NBU_DESTBO",Posicione("NNI",1,FWxFilial("NNI")+(cAliasNJR)->NJR_TABELA,"NNI_DESCRI"))
	EndIf
	
return lRet


/*/{Protheus.doc} OGA455DTAL
//Responsável por mostrar a detalhe com o serviços desmembrados.
@author brunosilva
@since 18/01/2019
@version 1.0

@type function
/*/
Static Function OGA455DTAL(cTipoOper)
	Local lRet 			:= .T.		
	Local oModel		:= FwModelActive()	
    Local oModelCtr		:= Nil
    Local cCodCtr       := ""   
    
	Private _cFltTot := ""
	Private _cFltDet := ""

    Default cTipoOper := ""

    If ValType(oModel) == "O"        
        If cTipoOper == "ORIGEM"
            oModelCtr := oModel:GetModel("OGA455_NBU")
            cCodCtr  := oModelCtr:GetValue("NBU_CTRORI")
        else
            oModelCtr := oModel:GetModel("OGA455_NBT")
            cCodCtr  := oModelCtr:GetValue("NBT_CTRDES")
        EndIf
    else
        cCodCtr := NBT->(NBT_CTRDES)
    EndIf

	_cFltDet := "     NKG_FILIAL >= '" + FWxFilial("NKG") + "'"
	_cFltDet += " AND NKG_FILIAL <= '" + FWxFilial("NKG") + "'"
	_cFltDet += " AND NKG_CODCTR >= '" + cCodCtr + "'"
	_cFltDet += " AND NKG_CODCTR <= '" + cCodCtr + "'"
	
	_cFltTot := " AND NKG_FILIAL >= '" + FWxFilial("NKG") + "'"
	_cFltTot += " AND NKG_FILIAL <= '" + FWxFilial("NKG") + "'"
	_cFltTot += " AND NKG_CODCTR >= '" + cCodCtr + "'"
	_cFltTot += " AND NKG_CODCTR <= '" + cCodCtr + "'"
	
	cCodEnt := Posicione("NJR",1,FwXfilial("NJR")+cCodCtr,"NJR_CODENT")
	cLojEnt := Posicione("NJR",1,FwXfilial("NJR")+cCodCtr,"NJR_LOJENT")
	
	OGA261A(cCodEnt,cLojEnt)
	
Return lRet

/*/{Protheus.doc} OGA455TRSV
//Função do WHEN do campo de 'Transfere serviço?'
@author brunosilva
@since 21/01/2019
@version 1.0

@type function
/*/
Function OGA455TRSV()
	Local lRet 		 := .T.
	Local oModel	 := FwModelActive()	
	
	//Caso só tenha uma linha na grid de serviços e ela estiver vazia, quer dizer que os serviços não foram calculados para dest/origem.
	//Por isso não deixa altera o campo.
	if (oModel:GetModel("OGA455_NBV"):Length() = 1 .AND. EMPTY(oModel:GetModel("OGA455_NBV"):GetValue("NBV_CODTRF")) ) 
		lRet := .F.
	elseif(oModel:GetModel("OGA4552_NBV"):Length() = 1 .AND. EMPTY(oModel:GetModel("OGA4552_NBV"):GetValue("NBV_CODTRF")) )   
		lRet := .F.
	endIf	
	
Return lRet

/*/{Protheus.doc} OGA455TRVL
//Responsável por abrir a tela de bonificação quando altera a opção do botão para bonificação.
@author brunosilva
@since 21/01/2019
@version 1.0

@type function
/*/
Function OGA455TRVL()
	Local lRet 		:= .T.
	Local aCtrs 	:= {}	
	Local nX		:= 1
	Local nY		:= 1
	Local nPosCtr	:= 0
	Local cAliasNBU	:= GetNextAlias()
	Local cFiltro	:= "AND ("
	
	Private _cCodTrf	:= NBT->NBT_CODTRF
	Private _cFltTot := ""
	Private _cFltDet	:= ""

	BeginSql Alias cAliasNBU
		SELECT
		NBU.NBU_CTRORI, NBU_ROMORI
		FROM
		%Table:NBU% NBU
		WHERE
		NBU.NBU_FILIAL  = %xFilial:NBU% AND
		NBU.NBU_CODTRF  = %exp:_cCodTrf% AND
		NBU.%NotDel%
	EndSql
	
	While !((cAliasNBU)->(Eof()))	
		cCtrLine := (cAliasNBU)->NBU_CTRORI
		cRomLine := (cAliasNBU)->NBU_ROMORI		
		if !EMPTY(cRomLine)
			nPosCtr  := ASCAN(aCtrs,{|x| x[1] == cCtrLine})
			if nPosCtr = 0
				aAdd(aCtrs,{})
				aAdd(aCtrs[LEN(aCtrs)],cCtrLine)
				aAdd(aCtrs[LEN(aCtrs)],cRomLine)				
			else
				aAdd(aCtrs[LEN(aCtrs)],cRomLine)
			endIf
		endIF	
		(cAliasNBU)->( DbSkip() )
	endDo
	
	for nX := 1 to Len(aCtrs)
		cFiltro += " (NKG_CODCTR = '" + aCtrs[nX][1] + "'"
		
		for nY := 1 to LEN(aCtrs[nX])
			if nY = 1
				cFiltro += " AND ("
			else
				if nY < LEN(aCtrs[nX])
					cFiltro += " NKG.NKG_CODROM = '" + aCtrs[nX][nY] + "' OR "
				else
					cFiltro += " NKG.NKG_CODROM = '" + aCtrs[nX][nY] + "')) "
				endIf
			endIf
		next nY
		
		if 	nX < LEN(aCtrs)
			cFiltro += " OR"
		endIf
	next nX
	cFiltro	+= ")"	
	
	
	_cFltDet := "     NKG_FILIAL = '" + FWxFilial("NKG") + "' "
	_cFltDet += cFiltro
	
	_cFltTot := " AND NKG_FILIAL = '" + FWxFilial("NKG") + "' "
	_cFltTot +=  cFiltro 
	
	OGA261A("","")
	
return lRet

/*/{Protheus.doc} OGA455CAN
Quando o Valor e contrato são alterados, limpa os dados do grid
@type function  
@author Marcelo Ferrari
@since 05/12/2018
/*/
Function OGA455CAN()
	Local cSql       := ""
	Local cAliasRom  := ""	
	Local nR         := 0
	Local cRomaneio  := ""
	Local lNotRomaneio := .F.
	Local LstRom     := "|"
	Local LstRomOri  := "|"
	Local lErroServico := .F.
	Local aRom       := {}
	Local aRomOri    := {}

	If !(NBT->NBT_STATUS $ "1|2")
		MsgAlert(STR0048, STR0049)  // "Cancelar", "Somente transferências com status 1 e 2 podem ser canceladas.")
		Return Nil
	Else

		cSql := "SELECT DISTINCT " + ;
		        "	NBU_ROMORI, " + ;
		        "	NBU_ROMDEV,  NJJD.NJJ_STATUS STATUS_DEV, " + ;
		        "	NBU_ROMDES,  NJJT.NJJ_STATUS STATUS_TRF " + ;
		        "FROM " + RetSqlName("NBU") + " NBU " + ;
		        "INNER JOIN " + RetSqlName("NJJ") + " NJJD ON   " + ;  //DEVOLUCAO
		        "   NJJD.NJJ_FILIAL = '"+ FwxFilial("NJJ") + "' AND " + ;
		        "   NBU.NBU_ROMDEV = NJJD.NJJ_CODROM AND " + ;
				"   NBU.D_E_L_E_T_ = NJJD.D_E_L_E_T_ " + ;
		        "INNER JOIN " + RetSqlName("NJJ") + " NJJT ON   " + ;  //TRANSFERENCIA
		        "   NJJT.NJJ_FILIAL = '"+ FwxFilial("NJJ") + "' AND " + ;
		        "   NBU.NBU_ROMDEV = NJJT.NJJ_CODROM AND " + ;
				"   NBU.D_E_L_E_T_ = NJJT.D_E_L_E_T_ " + ;
		        "WHERE NBU_FILIAL = '"+ FwxFilial("NBU") + "' " + ;
				"AND NBU_CODTRF = '" + NBT->NBT_CODTRF + "' " + ;
				"AND NBU.D_E_L_E_T_ = ' ' "

		cAliasRom := GetSqlAll(cSql)

		lRomConf := .F.
		nCont1 := 0
		While !( (cAliasRom)->(Eof()) )
			If ( (cAliasRom)->STATUS_DEV = '3' ) .OR. ( (cAliasRom)->STATUS_DEV = '3' )
				lRomConf := .T.
				Exit
			EndIf

			If !((cAliasRom)->NBU_ROMDEV $ LstRom)
				LstRom += (cAliasRom)->NBU_ROMDEV + "|"
				nCont1 := nCont1 + 1
			EndIf

			If !((cAliasRom)->NBU_ROMDES $ LstRom)
				LstRom += (cAliasRom)->NBU_ROMDES + "|"
				nCont1 := nCont1 + 1
			EndIf

			If !((cAliasRom)->NBU_ROMORI $ LstRomOri)
				LstRomOri += (cAliasRom)->NBU_ROMORI + "|"
			EndIf

			(cAliasRom)->(DbSkip())
		EndDo

		If lRomConf .AND. nCont1 > 0
			MsgAlert( STR0048, STR0050 ) //"Cancelar", "Não é possivel cancelar a Transferência enquanto houver romaneios vinculados com status igual a 'CONFIRMADO'")
			Return Nil
		EndIf

		lNotRomaneio := ( nCont1 = 0 )  //Transferência não possui romaneios de devolução/transferencia associados

		If MsgYesNo( STR0051  ) //"Deseja confirmar a transferência entre os contratos?"
			BEGIN TRANSACTION
				If AGRGRAVAHIS( STR0052 ,"NBT", NBT->NBT_FILIAL+NBT->NBT_CODTRF,"C") = 1   // "Cancelar Transferência"
					nCont1 := 0
					nCont2 := 0
					aRom := StrTokArr(LstRom, "|" )

					aRomOri := StrTokArr(LstRomOri, "|" )
					lErroServico := .F.
					For nR := 1 to Len(aRomOri)
						cSql := "SELECT NKG_FILIAL, NKG_CODCTR, NKG_ITEMOV, NKG_CODROM, NKG_ITEROM, NKG_CODTRF " + ;
												" ,NKG_FECSER ,NKS_DOCNUM, NKS_DOCSER, NKG.D_E_L_E_T_ " + ;
												"FROM " + RetSqlName("NKG") + " NKG " + ;
												"LEFT JOIN " + RetSqlName("NKS") + " NKS ON " + ;
												"   NKS_FILIAL = '"+ FwxFilial("NKS") + "' AND " + ;
												"   NKG_FECSER = NKS_FECSER AND  " + ;
												"   NKG.D_E_L_E_T_ = NKS.D_E_L_E_T_ " + ;
												"INNER JOIN " + RetSqlName("NBT") + " NBT ON " + ;
												"   NBT_FILIAL = '"+ FwxFilial("NBT") + "' AND " + ;
												"   NBT_CODTRF = NKG_CODTRF AND " + ;
												"   NKG.D_E_L_E_T_ = NBT.D_E_L_E_T_ " + ;
												"INNER JOIN " + RetSqlName("NBU") + " NBU ON " + ;
												"   NBU_FILIAL = '"+ FwxFilial("NBU") + "' AND " + ;
												"   NBT_CODTRF = NBU_CODTRF AND " + ;
												"   NBT.D_E_L_E_T_ = NBU.D_E_L_E_T_ " + ;
												"INNER JOIN " + RetSqlName("NBV") + " NBV ON " + ;
												"   NBV_FILIAL = '"+ FwxFilial("NBV") + "' AND " + ;
												"   NBV_CODTRF = NBT_CODTRF AND " + ;
												"   NBV_CODCTR = NBU_CTRORI AND " + ;
												"   NBV_CODDES = NKG_CODDES AND " + ;
												"   NBV.D_E_L_E_T_ = NBT.D_E_L_E_T_ " + ;
												"WHERE 1=1 " + ;
												"AND NKG_FILIAL = '"+ FwxFilial("NKG") + "' " + ;
												"AND NKG_CODTRF = '" + NBT->NBT_CODTRF + "' " + ;
												"AND NKG_CODCTR = NBU_CTRORI " + ;
												"AND NKG_CODROM = NBU_ROMORI " + ;
												"AND NBU_ROMORI = '" + cRomaneio + "' " + ;
												"AND NKG.D_E_L_E_T_ = ' ' "
						cAliasServ := GetSqlAll( cSql )

						While !(cAliasServ)->(Eof())
							If !(OGA261E( (cAliasServ)->NKG_CODCTR, (cAliasServ)->NKG_ITEMOV, .F. ))
								lErroServico := .T.
								Exit
							EndIf
						EndDo

						If lErroServico
							DisarmTransaction()
							Exit 
						EndIf
					Next nR

					If !lErroServico
						For nR := 1 to len(aRom)
							nCont1 := nCont1 + 1
							cRomaneio := aRom[nR]
						
							If NJJ->(DbSeek(fwXFilial("NJJ")+cRomaneio ))
								aValores := {}
								aAdd(aValores, "NJJ" )
								aAdd(aValores, (NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM) )
								aAdd(aValores, "B"  )  //Tipo = Alteracao
								aAdd(aValores, STR0053 + " [" + NBT->NBT_FILIAL+NBT->NBT_CODTRF + "]")  //"Cancelar Transferência de Saldo de Contratos:""

								OGA250REA( Nil, Nil, 4, aValores, .F.) 
								If NJJ->NJJ_STATUS $ '0|1'
									OGA250CAN( Nil, Nil, 4, aValores, .F. )
									If  NJJ->NJJ_STATUS = '4'
										//Cancela os serviços do Romaneio
										cAliasServ := GetSqlAll("")
										nCont2 := nCont2 + 1
									EndIf
								Else
									If NJJ->NJJ_STATUS = '4'
										nCont2 := nCont2 + 1
									EndIf
								EndIf
							EndIf

						Next nR

						If (nCont1 == nCont2) .OR. lNotRomaneio 
							RecLock( "NBT" , .F.)
								NBT->NBT_STATUS := OGA455STS(NBT->NBT_CODTRF)
							msUnLock( "NBT" )
						EndIf
					EndIf
				EndIf
			END TRANSACTION
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} OGA455ClUn
//Responsável por calcular o valor unitario baseado no valor total da nota fiscal.
@author brunosilva
@since 09/04/2019
@version 1.0
@param oModel, object, descricao
@type function
/*/
Function OGA455ClUn(oModel)
	Local oModelCalc	:= oModel:GetModel("OGA455QTD")
	Local nVlrTotal		:= oModel:GetModel("OGA455_NBT"):GetValue("NBT_VLRTOT")
	Local nQtdSelec		:= oModelCalc:GetValue("TOTQTDSEL", "TOTQTDSEL" )
	Local nVlrUnit		:= 0
	Local lRet			:= .T.
	
	Default oModel		:= FwModelActive()

	//Divide o valor totalda nota informada pela quantidade selecionada para transferencia
	nVlrUnit := nVlrTotal / nQtdSelec
	nVlrUnit := Round(nVlrUnit,TamSX3("NBT_VLRUNI")[2])
	
	//Seta o resultado da divisao no campo de valor unitario
	lRet := oModel:SetValue( 'OGA455_NBT', 'NBT_VLRUNI', nVlrUnit )
	
return lRet


/*/{Protheus.doc} OGA455GtPr
//Função responsavel por gatilhar o valor Unitário/total.
@author brunosilva
@since 09/04/2019
@version 1.0
@param cCampo, characters, descricao
@type function
/*/
Function OGA455GtPr(cCampo)
	Local oModel		:= FwModelActive()
	Local oModelCalc	:= oModel:GetModel("OGA455QTD")
	Local nQtdSelec		:= oModelCalc:GetValue("TOTQTDSEL", "TOTQTDSEL")
	Local nValor		:= 0
	
	//Somente se já houver notas selecionadas
	if nQtdSelec != 0
		if cCampo = "NBT_VLRTOT"
			nValor := oModel:GetModel("OGA455_NBT"):GetValue("NBT_VLRTOT") / nQtdSelec
			nValor := Round(nValor,TamSX3("NBT_VLRUNI")[2])
		elseIf cCampo = "NBT_VLRUNI"
			nValor := oModel:GetModel("OGA455_NBT"):GetValue("NBT_VLRUNI") * nQtdSelec
			nValor := Round(nValor,TamSX3("NBT_VLRTOT")[2])
		endIf
	endIf
	
return nValor


/*/{Protheus.doc} OGA455DDPD
//TODO Descrição auto-gerada.
@author brunosilva
@since 02/05/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param nX, numeric, descricao
@param nLine, numeric, descricao
@type function
/*/
Static Function OGA455DDPD(nX,oModelNBU, nNBU)
	Local lRet 		:= .T.
	Local cSql		:= "" 
	Local cAliasDoc	:= ""		
	
	cSql := "SELECT SD1.D1_IDENTB6, SD1.D1_DOC, SD1.D1_ITEM, SD1.D1_SERIE, SD1.D1_LOTECTL FROM " + RetSqlName("SD1") + " SD1" 
	cSql += " WHERE	SD1.D1_FILIAL = '"+ FwxFilial("SD1") + "' " 
	cSql += " AND SD1.D1_DOC    = '" + oModelNBU:GetValue("NBU_NFORI",nNBU) + "' " 
	cSql += " AND SD1.D1_CTROG  = '" + oModelNBU:GetValue("NBU_CTRORI",nNBU) + "' " 
	cSql += " AND SD1.D1_CODROM  = '" + oModelNBU:GetValue("NBU_ROMORI",nNBU) + "'  "
	
	cAliasDoc := GetSqlAll(cSql)	
	aItens := {}
	//_aLiaItens{} //LIMPA O ARRAY									
	aAdd( aItens, {"C6_ITEM"		, _aItensTrf[nX][2] 		, Nil } )
	aAdd( aItens, { "C6_PRODUTO"	, _aItensTrf[nX][3] 		, Nil } )
	aAdd( aItens, { "C6_TES"       , _aItensTrf[nX][4] 		, Nil } )
	aAdd( aItens, { "C6_IDENTB6"   , (cAliasDoc)->D1_IDENTB6  	, Nil } )
	aAdd( aItens, { "C6_NFORI"     , (cAliasDoc)->D1_DOC     	, Nil } )
	aAdd( aItens, { "C6_SERIORI"   , (cAliasDoc)->D1_SERIE    	, Nil } )
	aAdd( aItens, { "C6_ITEMORI"   , (cAliasDoc)->D1_ITEM     	, Nil } )
	aAdd( aItens, { "C6_QTDVEN"    , _aItensTrf[nX][5] 		, Nil } )
	aAdd( aItens, { "C6_QTDLIB"    , _aItensTrf[nX][5] 		, Nil } )
	aAdd( aItens, { "C6_PRCVEN"    , _aItensTrf[nX][7] 		, "alwaystrue()" } )
	aAdd( aItens, { "C6_VALOR"     , A410Arred((_aItensTrf[nX][7] * _aItensTrf[nX][5]), "C6_VALOR") , Nil } )
	aAdd( aItens, { "C6_LOCAL"     , _aItensTrf[nX][9]			, Nil } )
	aAdd( aItens, { "C6_CTROG"     , _aItensTrf[nX][10]		, Nil } )
	aAdd( aItens, { "C6_CODSAF"    , _aItensTrf[nX][11]		, "alwaystrue()" } )
	aAdd( aItens, { "C6_CODROM"    , _aItensTrf[nX][12]		, Nil } )
	aAdd( aItens, { "C6_ITEROM"    , _aItensTrf[nX][13]		, Nil } )
	aAdd( aItens, { "C6_LOTECTL"   , (cAliasDoc)->D1_LOTECTL   , Nil } )
	aAdd(_aLinha, aItens)

return lRet

/*/{Protheus.doc} PreValNBT(oFieldModel, cAction, cIDField, xValue)
	@type  Static Function
	@author mauricio.joao
	@since 29/10/2019
	@version 1.0
/*/
 Static Function PreValNBT(oFieldModel, cAction, cIDField, xValue)
 Local lRet := .T.
 If cAction == "SETVALUE" .AND. cIDField = "NBT_TESORI" //ORIGEM
	If Val(xValue) < 500
		Help( ,,STR0067,, STR0069, 1, 0 ) //"TES Invalida"#"TES da destino deve ser maior ou igual a 500."
		Return .F.		
	EndIf
 ElseIf cAction == "SETVALUE" .AND. cIDField = "NBT_TESDES" //DESTINO
	If Val(xValue) >= 500
		Help( ,,STR0067,, STR0068, 1, 0 ) //"TES Invalida"#"TES da origem deve ser menor do que 500."
		Return .F.		
	EndIf
 EndIf

Return lRet

/*/{Protheus.doc} PreValNBU
	Pré Validação do Modelo NBU
	@type  Static Function
	@author mauricio.joao
	@since 27/01/2020
	@version 1.0
	/*/
 Static Function PreValNBU(oModelGrid, nLine,cAction,cIDField,xVrNovo,xVrAnt)
Local lRet := .T.

If cAction == "CANSETVALUE"
	lRet := .F.
EndIf

If cAction == "CANSETVALUE" .And. cIDField == "NBU_OBSDES" .And.;
 !Empty(oModelGrid:GetValue("NBU_CODTRF",nLine)) .And.;
 !Empty(oModelGrid:GetValue("NBU_NFORI",nLine))
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} fieldValidPos(oFieldModel)
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
 Static Function fieldValidPos(oFieldModel)
Local lRet := .T.

If Empty(oFieldModel:GetValue("NBT_LOCORI"))
	Help( ,,STR0070,, STR0071+RetTitle("NBT_LOCORI"), 1, 0 ) //"Campo não preenchido."#"Favor preencher o campo "
	Return .F.
ElseIF Empty(oFieldModel:GetValue("NBT_LOCDES"))
	Help( ,,STR0070,, STR0071+RetTitle("NBT_LOCDES"), 1, 0 ) //"Campo não preenchido."#"Favor preencher o campo "
	Return .F.
ElseIF Empty(oFieldModel:GetValue("NBT_TESORI"))
	Help( ,,STR0070,, STR0071+RetTitle("NBT_TESORI"), 1, 0 ) //"Campo não preenchido."#"Favor preencher o campo "
	Return .F.
ElseIF Empty(oFieldModel:GetValue("NBT_TESDES"))
	Help( ,,STR0070,, STR0071+RetTitle("NBT_TESDES"), 1, 0 ) //"Campo não preenchido."#"Favor preencher o campo "
	Return .F.
ElseIF Empty(oFieldModel:GetValue("NBT_VLRUNI"))
	Help( ,,STR0070,, STR0071+RetTitle("NBT_VLRUNI"), 1, 0 ) //"Campo não preenchido."#"Favor preencher o campo "
	Return .F.
ElseIF Empty(oFieldModel:GetValue("NBT_VLRTOT"))
	Help( ,,STR0070,, STR0071+RetTitle("NBT_VLRTOT"), 1, 0 ) //"Campo não preenchido."#"Favor preencher o campo "
	Return .F.
EndIf

Return lRet

/*/{Protheus.doc} DoubleClick
    Função de duplo click na tabela de contratos de origem
    @type  Function
    @author user
    @since 06/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description    
    /*/
Static Function DoubleClick(oGrid,cFieldName,nLineGrid,nLineModel)
    
    If cFieldName == "NBU_CTRORI"
        OGA455DTAL("ORIGEM")
    EndIf

Return .T.
