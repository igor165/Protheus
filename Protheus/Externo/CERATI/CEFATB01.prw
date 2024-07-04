//Bibliotecas
#Include 'Protheus.ch'
#include 'totvs.ch'
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#INCLUDE "TOPCONN.CH"  

#Include "Colors.ch"
#Include "rwmake.ch"
#Include "Font.ch"
#Include "ap5mail.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

#DEFINE MVC_VIEW_WIDTH 5

Static cTitulo := "Lançamento de Despacho | v5"
/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 05.07.2022                                                           |
 | Cliente  : Cerati                                                               |
 | Desc		: Rotina de Lançamento de despachos.				                   |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_CEFATB01()                                                         |
 '---------------------------------------------------------------------------------*/
User Function CEFATB01()
	Local aArea     	:= GetArea()
	Local oBrowse
	Private aRotina		:= MenuDef()
	Private aRodap2   	:= {}
	Private cPerg		:= SubS(ProcName(),3)
	Private cPath 	 	:= "C:\totvs_relatorios\"
	Private nLSeq   	:= 0
	Private cArquivo   	:= cPath + cPerg +; 
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
	Private _cHoraIni 	:= Time()
/* 	Private aColsLt		:= {}
	Private aCols		:= {} */
	Private aEtq		:= {}
	Private aPed		:= {}
	Private lCFATALERT 	:= .T.
	Private lInicia	   	:= .F.
	Private cCliCFGru 	:= GetMV('OM_CLCFGRU', .F., '07850601')
	Private lShwRomane  := GetMV('ZZ_FT2ROMA', .F., .T. ) //Exibe a coluna com o Romaneio?
	Private lShwSldWMs  := GetMV('ZZ_FT2SLDW', .F., .T. ) //Exibe a coluna com o Saldo do WMS?
	Private dUlFat      := GetMV('MV_DATFAT')

	Private nPeso, nPeca
	Private nQtdp, nPesoP, nQtdD, nPesoD, nSaldo, nPsMin, nPsMax,nQtd2 := 0
	Private nQtde, nTotlTmp, nTotL, nVolume
	Private cCodbar, cNcs, cLote, cValidade, cProduto, cTpDesp, cDescp, cLoteVif
	Private lPreSZ7 := .F.
	Private lLmpGrid := .f.
	private oFont                // Objeto Fonte
	private oFontNW
	private oFontGRD             // Objeto Fonte
	private oFontBRW             // Objeto Fonte
	private oFontBRW2
	private oFontBRW3
	private oFontBRW4
	
	//Instanciando FWMBrowse - Somente com dicionÃ¡rio de dados
	GeraX1(cPerg)

	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZ5")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Ativa a Browse
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CEFATB01' OPERATION  3 ACCESS 0//MODEL_OPERATION_INSERT 	ACCESS 0 //OPERATION 3
Return aRotina

Static Function ModelDef()
	Local oModel        := Nil
	Local bVldCom       := {|| .T. }
	Local oStrCabec 	:= FWFormStruct(1, "Cabec")
	Local oStrGridM   	:= FWFormStruct(1, "GridM")
 	Local oStrRDp 		:= FWFormStruct(1, "Rodap1")
	Local oStrRLt 		:= FWFormStruct(1, "RodapG2")
	Local oStrRLt2 		:= FWFormStruct(1, "Rodap2")
	Local bPreZ6	 	:= {|oModelGrid, nLine, cAction, cField| FSZ6LPre(oModelGrid, nLine, cAction, cField) }
	Local bPreZ7		:= {|oModelGrid, nLine, cAction, cField| FSZ7LPre(oModelGrid, nLine, cAction, cField) }
	Local aGatilhos		:= {}
	Local nI 
	Private nTot   		:= 0, nTotVol:= 0

	oStrCabec 	:= GetModelCabec(oModel, oStrCabec)
	oStrGridM	:= GetMdGridM(oModel, oStrGridM)
 	oStrRDp 	:= getMdRDp(oModel, oStrRDp)   
	oStrRLt		:= GetMdRGl(oModel, oStrRLt)
	oStrRLt2	:= GetMdpLt2(oModel, oStrRLt2)

	aAdd(aGatilhos, FWStruTriggger( "CBC_CTPAD",;     //Campo Origem
                                    "CBC_LOTEVIF",;     //Campo Destino
                                	"",;				//Regra de Preenchimento
                                    .F.,;           	//Irá Posicionar?
                                    "",;            	//Alias de Posicionamento
                                    0,;             	//Índice de Posicionamento
                                    '',;            	//Chave de Posicionamento
                                    NIL,;           	//Condição para execução do gatilho
                                    "01");          	//Sequência do gatilho
    )

    For nI := 1 To Len(aGatilhos)
        oStrCabec:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
                            	aGatilhos[nI][02],; //Campo Destino
                            	aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
                            	aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

	oModel := MPFormModel():New("FATB01CE" , /*Pre-Validacao*/, /* bVldPos */ /*Pos-Validacao*/, bVldCom /*Commit*/, /*Cancel*/)
	
	oModel:AddFields('FORMCabec', 			, oStrCabec)
	oModel:AddGrid('FORMGridM', 'FORMCabec'	, oStrGridM,bPreZ6)
	
	//Atribuindo formulários para o modelo
    //Rodapé ABA01
 	oModel:AddFields("FORMRodap1", 'FORMGridM', oStrRDp)
	oModel:SetRelation("FORMRodap1", {{SubStr(Alltrim('Z5G_NUM'),11,6), 'RDP_PED'},;
									  {'Z5G_NUM', 'Z7G_PRODUTO'},;
									  {SubStr(Alltrim('Z5G_CLI'),1,6), SubStr(Alltrim('RDP_CLI'),1,6)},;
									  {SubStr(Alltrim('Z5G_CLI'),8,2), SubStr(Alltrim('RDP_CLI'),8,2)}})
    //GRID ABA02
	oModel:AddGrid('FORMRG2', 'FORMGridM' , oStrRLt,bPreZ7)

	//CAMPOS ABA02
	oModel:AddFields('FORMRLT2', 'FORMRG2', oStrRLt2)
	oModel:SetRelation('FORMRLT2', {{"Z7G_PESO","RLT_VLR2"}})
	
	oModel:GetModel("FORMRodap1"):SetOnlyView()
	oModel:GetModel("FORMRLT2"):SetOnlyView()

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({})

	oModel:GetModel("FORMGridM"):SetUniqueLine({"Z6G_ITEM","Z5G_NUM","Z5G_NOTA"})
	//Adicionando descrição ao modelo
	oModel:SetDescription("Rotina de " + cTitulo)
	
    //Setando GRID ABA02 como Não obrigatória
	oModel:SetOptional("FORMRG2", .T.)

	//Setando a descrição do Formulário
	oModel:GetModel("FORMCabec"):SetDescription("Cabeçalho do " + cTitulo)
 	oModel:GetModel("FORMGridM"):SetDescription("Grid do " + cTitulo) 
 	oModel:GetModel("FORMRodap1"):SetDescription("Formulário do " + cTitulo) 
 	oModel:GetModel("FORMRG2"):SetDescription("Grid Rodape do " + cTitulo) 
 	oModel:GetModel("FORMRLT2"):SetDescription("Formulário do " + cTitulo) 
Return oModel

Static Function ViewDef()
	Local oModel    := FWLoadModel("CEFATB01")
	Local oStrCabec := FWFormStruct(2, "Cabec")
	Local oStrGridM := FWFormStruct(2, "GridM")
 	Local oStrRDp 	:= FWFormStruct(2, "Rodap1")
	Local oStrRLt 	:= FWFormStruct(2, "RodapG2")
	Local oStrRLt2 	:= FWFormStruct(2, "Rodap2")
	Local oView     := Nil

	//Criando os campos Virtuais do Cabeçalho e Rodapé.
	oStrCabec 		:= GetViewCabec(oModel, oStrCabec)
	oStrGridM		:= GetVGridM(oModel, oStrGridM)
  	oStrRDp 		:= GetVRpDp(oModel, oStrRDp)   
  	oStrRLt 		:= GetVRpGl(oModel, oStrRLt)   
	oStrRLt2		:= GetVRpLt2(oModel, oStrRLt2)
	
	//Criando a view que será o retorno da Função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABECA', 20)
	oView:CreateHorizontalBox('GRID'  , 55)
	oView:CreateHorizontalBox('RODAPE2', 25)
	
	//Pasta do RODAPE2
	oView:CreateFolder( 'PASTARODAPE', 'RODAPE2' )
	oView:AddSheet( 'PASTARODAPE', 'ABA01', 'Despacho')
 	oView:AddSheet( 'PASTARODAPE', 'ABA02', 'Multi-Lote')
	
	//Caixas Horizontais do RODAPE2
	oView:CreateHorizontalBox(	'RODAPEPRIN'	, 100,,,'PASTARODAPE', 'ABA01') 
    oView:CreateVerticalBox(	'RPSECESQ'		, 70,,, 'PASTARODAPE', 'ABA02')
    oView:CreateVerticalBox(	'RPSECDIR'		, 30,,, 'PASTARODAPE', 'ABA02')

	//Atribuindo formulários para interface
	oView:AddField( 'VIEW_Cabec' 	, oStrCabec , 'FORMCabec')
	oView:AddGrid(  'VIEW_GridM'   	, oStrGridM , 'FORMGridM',,{|| ViewActv() })
 	oView:AddField( "VIEW_Rodap01" 	, oStrRDp 	, "FORMRodap1")
	oView:AddGrid( 	'VIEW_RodapLT'	, oStrRLt	, 'FORMRG2')
	oView:AddField( 'VIEW_Rodap02'	, oStrRLt2	, 'FORMRLT2')

	//Botoes
	oView:AddUserButton( 'PesoPAD' 			, 'Peso Padrão'		, {|oView| CEFATBP()} )
	oView:AddUserButton( 'Limpar' 			, 'Limpar'			, {|oView| CEFATBL()} )
	oView:AddUserButton( 'Visualizar' 		, 'Visualizar'		, {|oView| U_CEFATBV()}) 
 	oView:AddUserButton( 'GeraNF' 			, 'GeraNF'			, {|| MsAguarde( { |oView| CEFATBNF() } , "Aguarde..." )} )
 	oView:AddUserButton( 'Preencher Volume' , 'Preencher Volume', {|oView| CEFATBVol()} ) 
	oView:AddUserButton( 'Etiquetas' 		, 'Etiquetas'		, {|oView| CEFATBE()} ) 
	oView:AddUserButton( 'Zerar Volume'		, 'Zerar Volume'	, {|oView| CEFATBZ()} ) 
	oView:AddUserButton( 'Despachar'		, 'Despachar'		, {|oView| CEFATBD()} )  

	//ForÃ§a o fechamento da janela na confirmaÃ§Ã£o
	oView:SetCloseOnOk({||.T.})

	//O Formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_Cabec"		, "CABECA"   	)
	oView:SetOwnerView("VIEW_GridM"  	, "GRID"     	)
 	oView:SetOwnerView("VIEW_Rodap01"	, "RODAPEPRIN" 	)
 	oView:SetOwnerView("VIEW_RodapLT"	, "RPSECESQ"	)
 	oView:SetOwnerView("VIEW_Rodap02"	, "RPSECDIR"	)
	
	oView:SetViewProperty('*', "ENABLENEWGRID")
    oView:SetViewProperty('VIEW_GridM', 'SETCSS', { "QTableView { selection-background-color: #1C9DBD; } " })
	oView:SetViewProperty('VIEW_Cabec', 'SETCOLUMNSEPARATOR', {10})
	oView:SetViewProperty("VIEW_GridM", "GRIDCANGOTFOCUS", {.T.})
Return oView
/* 
    Pré Validação de linha da GRID do RODAPE 
    Formulário: FORMRodap1
*/
Static Function FSZ7LPre(oModelGrid, nLine, cAction, cField)
	Local aArea 		:= GetArea()
	Local oModel 		:= FWModelActive()
	Local oView 		:= FWViewActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelGR 		:= oModel:GetModel("FORMRG2")
	Local lRet			:= .T.	
	Local aSaveLines 	:= FWSaveRows()	
	Local nQtdlib2, nQtdlib, nOmavol

	if cAction == 'DELETE'
		cLoteVif := AllTrim(oModelGR:GetValue("Z7G_CODBAR"))

		IF oModelGM:SeekLine({{"Z5G_NUM"		, oModelGR:GetValue("Z7G_PED") },;
								{"Z6G_PRODUTO"	, oModelGR:GetValue("Z7G_PRODUTO")},;
								{"Z5G_CLI"		, oModelGR:GetValue("Z7G_CLI")}})

			nQtdlib2 := oModelGM:GetValue("Z6G_QTDLIB2") - oModelGR:GetValue("Z7G_QTDE") 
			nQtdlib	 := oModelGM:GetValue("Z6G_QTDLIB")  - oModelGR:GetValue("Z7G_PESO") 
			nOmavol  := nQtdlib2

			oModelGM:LoadValue("Z6G_QTDLIB2",nQtdlib2)
			oModelGM:LoadValue("Z6G_QTDLIB", nQtdlib)
			oModelGM:LoadValue("Z6G_OMAVOL", nOmavol)

			SZ6->(DbSelectArea('SZ6'))
			SZ6->(DbSetOrder(1))
			SZ6->(DbGoTop())
			
			If SZ6->(DbSeek(xFilial('SZ6')+;
				oModelGM:GetValue("Z5G_NUM")+;
				oModelGM:GetValue("Z6G_ITEM")+;
				oModelGM:GetValue("Z6G_PRODUTO")))

                    RECLOCK('SZ6',.F.)
                        SZ6->Z6_OMAVOL  := oModelGM:GetValue("Z6G_OMAVOL") 
                        SZ6->Z6_QTDLIB2 := oModelGM:GetValue("Z6G_QTDLIB2") 
                        SZ6->Z6_QTDLIB  := oModelGM:GetValue("Z6G_QTDLIB") 
                    SZ6->(MSUNLOCK())
                SZ6->(DBSKIP())
			EndIf
			
			SZ7->(DbSelectArea('SZ7'))
			SZ7->(DbSetOrder(1))

			cCodBar	:= oModelGR:GetValue("Z7G_CODBAR")
			cLote 	:= oModelGR:GetValue("Z7G_LOTE")
			cProd   := oModelGR:GetValue("Z7G_PRODUTO")
			cPed    := oModelGR:GetValue("Z7G_PED")
			cCli    := SubStr(oModelGR:GetValue("Z7G_CLI"),1,6)
			cLoj    := SubStr(oModelGR:GetValue("Z7G_CLI"),8,2)
			cItem   := oModelGR:GetValue("Z7G_ITEM")
			cSeq    := oModelGR:GetValue("Z7G_NSEQ")
			nPeso   := oModelGR:GetValue("Z7G_PESO")
			nQtde   := oModelGR:GetValue("Z7G_QTDE")
			
			if SZ7->(DbSeek(xFilial('SZ7')+;
					SubStr(cCodBar,1,50)+;
					SubStr(cProd,1,15)+;
					SubStr(cPED,1,29)+;
					SubStr(cITEM,1,02)+;
					SubStr(cCLI,1,06)+;
					SubStr(cLOJ,1,02)+;
					AllTrim(str(cSEQ))))

				RECLOCK('SZ7',.F.)
					SZ7->(DbDelete())
				SZ7->(MSUNLOCK())
			endif

			/* oView:Refresh("VIEW_RodapLT") */
		ENDIF	
	elseif cAction == 'UNDELETE'
		oModel:SetErrorMessage("","","","","HELP", 'Lote Já Deletado!', "") 
		RETURN(.F.)
	elseif cAction == 'SETVALUE'
		if oModelGR:IsEmpty()
			oModel:SetErrorMessage("","","","","HELP", 'Não há lote para ser Alterado!', "") 
			lRet := .F.
		ENDIF
	ENDIF
	RestArea(aArea)
	FWRestRows( aSaveLines )
	oView:Refresh()
RETURN lRet 

Static Function FSZ6LPre(oModelGrid, nLine, cAction, cField)
	Local oModel 		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelGR 		:= oModel:GetModel("FORMRG2")
	Local lRet			:= .T.	
	Local aSaveLines 	:= FWSaveRows()	

 	if cAction == 'SETVALUE'
		if cField $ 'Z6G_QTDLIB2|Z6G_QTDLIB|Z6G_OMAVOL'
			if Empty(oModelGM:GetValue("Z5G_NUM"))
				oModel:SetErrorMessage("","","","","HELP", 'código do pedido vazio', "Informe o código da transportadora e data de entrega") 
				lRet := .F.
			elseif !oModelGR:IsEmpty()
				oModel:SetErrorMessage("","","","","HELP", 'Não pode ser alterado', "Item com lote só pode ser alterado no lote") 
				lRet := .F.
			elseif SUBSTR(oModelGM:GetValue("Z5G_CLI"),1,6)+SUBSTR(oModelGM:GetValue("Z5G_CLI"),8,2)  == ALLTRIM(cCliCFGru)
				MsgAlert('Pedidos NT somente podem ter peso por despacho')
				lRet := .F.
			endif
		EndIf
	EndIf 
	FWRestRows( aSaveLines )
RETURN lRet
/* 
    Campos Cabeçalho ModelDef 
*/
Static Function GetModelCabec(oModel,oStrCabec)
	oStrCabec:AddField('Romaneio?'		 		, 'Romaneio?'			, 'CBC_CBROMA'	, 'C', 1                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('SN') ")					,,{'S=Sim', 'N=Não'}		                                                                                                                							,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'N'" )                                                                             	,.F.,.F.,.T.)
	oStrCabec:AddField('Tp. Cliente?'	 		, 'Tp. Cliente?'		, 'CBC_TPCLI'	, 'C', 1                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('RV')")					 	,,{'R=Rede', 'V=Varejo'}	                                                                                                            								,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'R'" )                                                                             	,.F.,.F.,.T.)
	oStrCabec:AddField('Tipo Shelf'		 		, 'Tipo Shelf'			, 'CBC_TPSHELF'	, 'C', 1                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('1')")					 	,,{'1=1/3', '2=2/3'}		                                                                                                            								,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )                                                                             	,.F.,.F.,.T.)
	oStrCabec:AddField('Estado'			 		, 'Estado'				, 'CBC_UF'		, 'C', 2                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('SP')")  				 	,,{'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'}  	,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'SP'" )                                                                            	,.F.,.F.,.T.)
	oStrCabec:AddField('Transp. Padrão'	        , 'Transp. Padrão'	    , 'CBC_CTPAD'	, 'C', 6                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"ExistCpo('SA4') .and. U_CEFATBPG()")	,,{}                                                                                                                                      								,.T.,                                                                                                                           	,.F.,.F.,.T.)
	oStrCabec:AddField('Transp. Primario'	    , 'Transp. Primario'    , 'CBC_CTPRIM'	, 'C', 6                        ,0                      ,  		                                                                	,,{}                                                                                                                                       								,.F.,                                                                                                                           	,.F.,.F.,.T.)
	oStrCabec:AddField('Transp. Entrega'	    , 'Cod. Transp Entrega'	, 'CBC_CTENTR'	, 'C', 6                        ,0                      ,			  	                                                            ,,{}                                                                                                                                       								,.F.,                                                                                                                           	,.F.,.F.,.T.)
	oStrCabec:AddField('Entrega'				, 'Entrega'				, 'CBC_ENTREGA'	, 'D', 8                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"U_VALIDATA(M->CBC_ENTREGA)")			,,{}                                                                                                                                       								,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "dUlFat")                                                                        	    ,.F.,.F.,.T.)
	oStrCabec:AddField('Placa Primaria'			, 'Placa Primaria'		, 'CBC_PLACAP'	, 'C', 8                        ,0                      ,					  	                                                    ,,{}                                                                                                                                       								,.F.,                                                                                                                           	,.F.,.F.,.T.)
	oStrCabec:AddField('Placa Entrega'			, 'Placa Entrega'		, 'CBC_PLACAE'	, 'C', 8                        ,0                      ,					  	                                                    ,,{}                                                                                                                                       								,.F.,                                                                                                                           	,.F.,.F.,.T.)
	oStrCabec:AddField('Transp. Padrão'			, 'Transp. Padrão'		, 'CBC_NTPAD'	, 'C',40                        ,0                      ,																		  	,,{}                                                                                                                                       								,.F.,                                                                                                                           	,.F.,.F.,.T.)
	oStrCabec:AddField('Transp. Primario'		, 'Transp. Primario'	, 'CBC_NTPRIM'	, 'C',40                        ,0                      ,																		  	,,{}                                                                                                                                       								,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!Inclui,Posicione('SA4',1,xFilial('SA4')+M->Z5_TRANSP , 'A4_NOME'), '')")	,.F.,.F.,.T.)
	oStrCabec:AddField('Transp. Entrega'		, 'Transp. Entrega'		, 'CBC_NTENTR'	, 'C',40                        ,0                      ,																		  	,,{}                                                                                                                                       								,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!Inclui,Posicione('SA4',1,xFilial('SA4')+M->Z5_TRANSP3, 'A4_NOME'), '')")	,.F.,.F.,.T.)
	oStrCabec:AddField('Pallet'					, 'Pallet'				, 'CBC_PALLET'	, 'C',02                        ,0                      ,																		  	,,{'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'}                                                                 ,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'01'" )																				,.F.,.F.,.T.)
	oStrCabec:AddField('Romaneio'				, 'Romaneio'			, 'CBC_ROMA'	, 'C',15                        ,0                      ,																		  	,,																																										,.F.,																																,.F.,.F.,.T.)
	oStrCabec:AddField('Zona'					, 'Zona'				, 'CBC_ZONA'	, 'C',15                        ,0                      ,																		  	,,																																										,.F.,																																,.F.,.F.,.T.)
	oStrCabec:AddField('NF'						, 'NF'					, 'CBC_NF'		, 'C', 1                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12')")						,,{'1=NF Normal','2=NF Automatico'}																																		,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )  																				,.F.,.F.,.T.)
	oStrCabec:AddField('Itens'					, 'Itens'				, 'CBC_ITENS'	, 'C', 1                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('123')")					,,{'1=Todos os Itens','2=Itens a Granel','3=Peso Padrão'}																												,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'1'" )  																				,.F.,.F.,.T.)
	oStrCabec:AddField('Ordenação'				, 'Ordenação'			, 'CBC_ORDG'	, 'C', 1                        ,0                      ,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('1234')")					,,{'1=Zona Crescente Roteiro Crescente','2=Zona Crescente Roteiro Decrescente','3=Codigo de Produto','4=Cidade'}														,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'3'" )  																				,.F.,.F.,.T.)
    oStrCabec:AddField('Lote VIF'			    , 'Lote VIF'			, 'CBC_LOTEVIF'	, 'C',TAMSX3('Z6_LOTEVIF')[1]	,TAMSX3('Z6_LOTEVIF')[2],FwBuildFeature( STRUCT_FEATURE_VALID,"U_VLDLTCB()")						,,																																										,.F.,																																,.F.,.F.,.T.)
	oStrCabec:AddField('Manter Foco?'			, 'Manter Foco?'		, 'CBC_FOCO'	, 'C',1							,0						,FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('SN')")						,,{'S=Sim', 'N=Não'}																																					,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "'S'" )																					,.F.,.F.,.T.)
Return oStrCabec
/*
	Campos Cabeçalho ViewDef 
*/
Static Function GetViewCabec(oModel,oStrCabec)
	oStrCabec:AddField('CBC_CBROMA'	,  '1', 'Filtra Romaneio?'		, 'Filtra Romaneio?'	,{}, 'C',,,		,.T.									,,,{'S=Sim', 'N=Não'}																														,1, 'N'				,.T.,,,)
	oStrCabec:AddField('CBC_NTPAD'	,  '2', 'Transp. Padrão'		, 'Transp. Padrão'		,{}, 'C',,,		,.F.									,,,{}																																		,,					,.F.,,,)
	oStrCabec:AddField('CBC_NF' 	,  '3', 'NF'					, 'NF'					,{}, 'C',,,		,.T.									,,,{'1=NF Normal','2=NF Automatico'}																										,1,'1'				,.T.,,,)
	oStrCabec:AddField('CBC_ORDG'	,  '4', 'Ordenação'				, 'Ordenação'			,{}, 'C',,,		,.T.									,,,{'1=Zona Crescente Roteiro Crescente','2=Zona Crescente Roteiro Decrescente','3=Codigo de Produto','4=Cidade'}							,1,'1'				,.T.,,,)
	oStrCabec:AddField('CBC_PALLET' ,  '5', 'Pallet'				, 'Pallet'				,{}, 'C',,,		,.T.									,,,{'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'}									,2,'01'				,.T.,,,)
	oStrCabec:AddField('CBC_ZONA'	,  '6', 'Zona'					, 'Zona'				,{}, 'C',,,"ACY",.T.									,,,																																			,,					,.T.,,,)
	oStrCabec:AddField('CBC_ITENS'	,  '7', 'Itens'					, 'Itens'				,{}, 'C',,,		,.T.									,,,{'1=Todos os Itens','2=Itens a Granel','3=Peso Padrão'}																					,1,'1'				,.T.,,,)
   	oStrCabec:AddField('CBC_LOTEVIF',  '8', 'Lote VIF'				, 'Lote VIF'			,{}, 'C',,,     ,.T.									,,,{}																																	    ,,  				,.T.,,,)
	oStrCabec:AddField('CBC_FOCO'	,  '9', 'Manter Foco?'			, 'Manter Foco?'		,{}, 'C',,,     ,.T.									,,,{'S=Sim', 'N=Não'}																														,,'S'				,.T.,,,)
	oStrCabec:AddField('CBC_TPCLI'	, '10', 'Tp. Cliente?'		    , 'Tp. Cliente?'		,{}, 'C',,,		,.T.									,,,{'R=Rede','V=Varejo'}																													,1, 'R'				,.F.,,,)
	oStrCabec:AddField('CBC_UF'		, '11', 'Estado'				, 'Estado'				,{}, 'C',,,		,.T.									,,,{'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO' },2, 'SP'			,.F.,,,)
	oStrCabec:AddField('CBC_TPSHELF', '12', 'Tipo Shelf'			, 'Tipo Shelf'			,{}, 'C',,,		,.T.									,,,{'1=1/3','2=2/3'}																														,1, 'R'				,.F.,,,)
	oStrCabec:AddField('CBC_ROMA'	, '13', 'Romaneio'				, 'Romaneio'			,{}, 'C',,,		,.T.									,,,{}																																		,,					,.T.,,,)
	oStrCabec:AddField('CBC_ENTREGA', '14', 'Entrega'				, 'Entrega'				,{}, 'D',,,		,.T.									,,,{}																																		, , dToC(dUlFat)	,.T.,,,)
	oStrCabec:AddField('CBC_PLACAE'	, '15', 'Placa Entrega'		    , 'Placa Entrega'		,{}, 'C',,,		,.F.									,,,{}																																		,,					,.T.,,,)
	oStrCabec:AddField('CBC_PLACAP'	, '16', 'Placa Primaria'		, 'Placa Primaria'		,{}, 'C',,,		,.F.									,,,{}																																		,,					,.T.,,,)
	oStrCabec:AddField('CBC_CTPAD'	, '17', 'Transp. Padrão'	    , 'Transp. Padrão'	    ,{}, 'C',,,"SA4",.T.									,,,{}																																		,,		            ,.F.,,,)
	oStrCabec:AddField('CBC_CTPRIM'	, '18', 'Transp. Primario'      , 'Transp. Primario'    ,{}, 'C',,,     ,.F.									,,,{}																																		,,					,.F.,,,)
	oStrCabec:AddField('CBC_CTENTR'	, '19', 'Transp Entrega'		, 'Transp Entrega'		,{}, 'C',,,		,.F.									,,,{}																																		,,					,.F.,,,)
	oStrCabec:AddField('CBC_NTENTR'	, '20', 'Transp. Entrega'		, 'Transp. Entrega'		,{}, 'C',,,		,.F.									,,,{}																																		,,					,.F.,,,)
	oStrCabec:AddField('CBC_NTPRIM'	, '21', 'Transp. Primario'		, 'Transp. Primario'	,{}, 'C',,,		,.F.									,,,{}																																		,,					,.F.,,,)
Return oStrCabec
/* 
    Campos Grid Principal ModelDef
 */
Static Function GetMdGridM(oModel, oStrGridM)
	oStrGridM:AddField(''		 			, ''					, 'Z6G_LEGEND'	, 'C',50						,0							,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Item'		 		, 'Item'				, 'Z6G_ITEM'	, 'C',TAMSX3('Z6_ITEM')[1]		,TAMSX3('Z6_ITEM')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Pedido'				, 'Pedido'				, 'Z5G_NUM'		, 'C',TAMSX3('Z6_NUM')[1]		,TAMSX3('Z6_ITEM')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Cliente'	 		, 'Cliente'				, 'Z5G_CLI'		, 'C',09						,0							,														,,,.F.,,.F.,.F.,.T.) // CLIENTE + '-' + LOJA
	oStrGridM:AddField('Razão Social'	 	, 'Razão Social'		, 'A1G_NREDUZ'	, 'C',TAMSX3('A1_NREDUZ')[1]	,TAMSX3('A1_NREDUZ')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Roteiro'			, 'Roteiro'				, 'A1G_ROTENTR'	, 'C',TAMSX3('A1_ROTENTR')[1]	,TAMSX3('A1_ROTENTR')[2]	,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Produto'			, 'Produto'				, 'Z6G_PRODUTO'	, 'C',TAMSX3('Z6_PRODUTO')[1]	,TAMSX3('Z6_PRODUTO')[2]	,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Qtd Vend.'			, 'Qtd. Vend.'			, 'Z6G_UNSVEN'	, 'N',TAMSX3('Z6_UNSVEN')[1]	,TAMSX3('Z6_UNSVEN')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Peso Vend.'			, 'Peso Vend.'			, 'Z6G_QTDVEN'	, 'N',TAMSX3('Z6_QTDVEN')[1]	,TAMSX3('Z6_QTDVEN')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Unid Med.'			, 'Unid Med.'			, 'Z6G_UM'		, 'C',TAMSX3('Z6_UM')[1]		,TAMSX3('Z6_UM')[2]			,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Qtd. Desp.'			, 'Qtd. Desp.'			, 'Z6G_QTDLIB2'	, 'N',TAMSX3('Z6_QTDLIB2')[1]	,TAMSX3('Z6_QTDLIB2')[2]	,FwBuildFeature( STRUCT_FEATURE_VALID,"U_VLDLIB2()") 	,,,.F.,,.F.,.T.,.T.)
	oStrGridM:AddField('Peso Desp.'			, 'Peso Desp.'			, 'Z6G_QTDLIB'	, 'N',TAMSX3('Z6_QTDLIB')[1]	,TAMSX3('Z6_QTDLIB')[2]		,FwBuildFeature( STRUCT_FEATURE_VALID,"U_VLDLIB()")		,,,.F.,,.F.,.T.,.T.)
	oStrGridM:AddField('Volume(s)'			, 'Volume(s)'			, 'Z6G_OMAVOL'	, 'N',TAMSX3('Z6_OMAVOL')[1]	,TAMSX3('Z6_OMAVOL')[2]		,FwBuildFeature( STRUCT_FEATURE_VALID,"U_VLDVOL1()") 	,,,.F.,,.F.,.T.,.T.)
	oStrGridM:AddField('Lote VIF'			, 'Lote VIF'			, 'Z6G_LOTEVIF'	, 'C',TAMSX3('Z6_LOTEVIF')[1]	,TAMSX3('Z6_LOTEVIF')[2]	,FwBuildFeature( STRUCT_FEATURE_VALID,"U_VLDLOTE()")	,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('NCS'				, 'NCS'					, 'Z6G_NCS'		, 'C',06						,0							,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Nota'		 		, 'Nota'				, 'Z5G_NOTA'	, 'C',13						,0							,														,,,.F.,,.F.,.F.,.T.) /* NOTA + '-' + SERIE */
	oStrGridM:AddField('Venda a Vista?'	 	, 'Venda a Vista?'		, 'Z6G_VVISTA'	, 'C',TAMSX3('Z6_VVISTA')[1]	,TAMSX3('Z6_VVISTA')[2]		,														,,,.F.,,.F.,.F.,.T.)
	if lShwRomane 
		oStrGridM:AddField('Romaneio'	 	, 'Romaneio'			, 'Z6G_ROMAN'	, 'C',12						,0							,														,,,.F.,,.F.,.F.,.T.)
	ENDIF
	if lShwSldWMs 
		oStrGridM:AddField('Saldo WMS'		 ,'Saldo WMS'			, 'Z6G_SALDWMS'	, 'N',TAMSX3('Z6_SALDWMS')[1]	,TAMSX3('Z6_SALDWMS')[2]	,														,,,.F.,,.F.,.F.,.T.)
	ENDIF
	oStrGridM:AddField('Kit'	 			, 'Kit'					, 'Z6G_XPRDKIT'	, 'C',TAMSX3('Z6_XPRDKIT')[1]	,TAMSX3('Z6_XPRDKIT')[2]	,														,,,.F.,,.F.,.F.,.T.)
	oStrGridM:AddField('Zona'				,'Zona'					, 'A1G_GRPVEN'	, 'C',TAMSX3('A1_GRPVEN')[1]	,TAMSX3('A1_GRPVEN')[2]		,														,,,.F.,,.F.,.F.,.T.)
Return oStrGridM
/* 
    Campos Grid Principal ViewDef
*/
Static Function GetVGridM(oModel, oStrGridM)
	oStrGridM:AddField('Z6G_LEGEND'		, '1' 	, ''				, ''				,{}, 'C',"@BMP"			 ,,/* F3 */,.F.,,,,,,.T.) 
	oStrGridM:AddField('Z6G_QTDLIB'		, '2'	, 'Peso Desp.'		, 'Peso Desp.'		,{}, 'N',"@E 999,999.999",,/* F3 */,.T.,,,,,,.T.)
	oStrGridM:AddField('Z6G_LOTEVIF'	, '3' 	, 'Lote VIF'		, 'Lote VIF'		,{}, 'C',				 ,,/* F3 */,.T.,,,,,,.T.)
	if lShwRomane 
		oStrGridM:AddField('Z6G_ROMAN'	, '4'	, 'Romaneio'		, 'Romaneio'		,{}, 'C',				 ,,		   ,.F.,,,,,,.T.)
	ENDIF
	if lShwSldWMs 
		oStrGridM:AddField('Z6G_SALDWMS', '5'	,'Saldo WMS'		,'Saldo WMS'		,{},'N',				 ,,/* F3 */,.F.,,,,,,.T.)
	ENDIF
	oStrGridM:AddField('Z6G_XPRDKIT'	, '6'	, 'Kit'				, 'Kit'				,{}, 'C',				 ,,		   ,.F.,,,,,,.T.)
	oStrGridM:AddField('Z5G_NOTA'		, '7'	, 'Nota'			, 'Nota'			,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.F.)
	oStrGridM:AddField('Z6G_ITEM'		, '8' 	, 'Item'			, 'Item'			,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.) 
	oStrGridM:AddField('Z6G_VVISTA'		, '9'	, 'Venda a Vista?'	, 'Venda a Vista?'	,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('Z5G_NUM'		, '10' 	, 'Pedido'			, 'Pedido'			,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('Z5G_CLI'		, '11' 	, 'Cod. Cliente'	, 'Cod. Cliente'	,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('A1G_NREDUZ'		, '12' 	, 'Razão Social'	, 'Razão Social'	,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('A1G_GRPVEN'		, '13' 	, 'Zona'			, 'Zona'			,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('A1G_ROTENTR'	, '14' 	, 'Roteiro'			, 'Roteiro'			,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('Z6G_PRODUTO'	, '15' 	, 'Produto'			, 'Produto'			,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('Z6G_UNSVEN'		, '16' 	, 'Qtd. Vend.'		, 'Qtd. Vend.'		,{}, 'N',"@E 9999"		 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('Z6G_QTDVEN'		, '17' 	, 'Peso Vend.'		, 'Peso Vend.'		,{}, 'N',"@E 999,999.999",,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('Z6G_UM'			, '18'	, 'Unid Med.'		, 'Unid Med.'		,{}, 'C',				 ,,/* F3 */,.F.,,,,,,.T.)
	oStrGridM:AddField('Z6G_QTDLIB2'	, '19'	, 'Qtd. Desp.'		, 'Qtd. Desp.'		,{}, 'N',"@E 9999"		 ,,/* F3 */,.T.,,,,,,.T.)
	oStrGridM:AddField('Z6G_OMAVOL'		, '20'	, 'Volume(s)'		, 'Volume(s)'		,{}, 'N',"@E 9999"		 ,,/* F3 */,.T.,,,,,,.T.)
	oStrGridM:AddField('Z6G_NCS'		, '21'	, 'NCS'				, 'NCS'				,{}, 'C',				 ,,		   ,.F.,,,,,,.T.)
Return oStrGridM 
/* 
    Campos Grid Rodape ModelDef
 */
Static Function GetMdRGl(oModel, oStrRLt)
	oStrRLt:AddField('Item'					, 'Item'			, 'Z7G_ITEM'	, 'C',TAMSX3('Z7_ITEM')[1]		,TAMSX3('Z7_ITEM')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Pedido'				, 'Pedido'			, 'Z7G_PED'		, 'C',TAMSX3('Z7_PEDIDO')[1]	,TAMSX3('Z7_PEDIDO')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Cod Barras'			, 'Cod Barras'		, 'Z7G_CODBAR'	, 'C',TAMSX3('Z7_CODBAR')[1]	,TAMSX3('Z7_CODBAR')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Produto'				, 'Produto'			, 'Z7G_PRODUTO'	, 'C',TAMSX3('Z7_PRODUTO')[1]	,TAMSX3('Z7_PRODUTO')[2]	,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Lote'			 		, 'Lote'			, 'Z7G_LOTE'	, 'C',TAMSX3('Z7_LOTE')[1]		,TAMSX3('Z7_LOTE')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Validade'			 	, 'Validade'		, 'Z7G_VALID'	, 'D',TAMSX3('Z7_VALID')[1]		,TAMSX3('Z7_VALID')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Qtde'			 		, 'Qtde'			, 'Z7G_QTDE'	, 'N',TAMSX3('Z7_QTDE')[1]		,TAMSX3('Z7_QTDE')[2]		,FwBuildFeature( STRUCT_FEATURE_VALID,"U_VLDQTDL()")	,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Peso'			 		, 'Peso'			, 'Z7G_PESO'	, 'N',TAMSX3('Z7_PESO')[1]		,TAMSX3('Z7_PESO')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('NCS'			 		, 'NCS'				, 'Z7G_NCS'		, 'C',TAMSX3('Z7_LOTE')[1]		,TAMSX3('Z7_LOTE')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Sequencia'			, 'Sequencia'		, 'Z7G_NSEQ'	, 'N',TAMSX3('Z7_NSEQ')[1]		,TAMSX3('Z7_NSEQ')[2]		,														,,,.F.,,.F.,.F.,.T.)
	oStrRLt:AddField('Cliente'				, 'Cliente'			, 'Z7G_CLI'		, 'C',09						,0							,														,,,.F.,,.F.,.F.,.T.)
Return oStrRLt
/* 
    Campos Grid Rodape ViewDef
*/
Static Function GetVRpGl(oModel, oStrRLt)  
	oStrRLt:AddField('Z7G_CODBAR'	, '1' 	, 'Cod Barras'	, 'Cod Barras'	,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_VALID'	, '2' 	, 'Validade'	, 'Validade'	,{}, 'D',						,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_QTDE'		, '3' 	, 'Qtde'		, 'Qtde'		,{}, 'N',"@E 999,999,999.9999"	,,,.T.,,,,,,.T.)
	oStrRLt:AddField('Z7G_PESO'		, '4' 	, 'Peso'		, 'Peso'		,{}, 'N',"@E 9,999,999.999"		,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_NCS'		, '5' 	, 'NCS'			, 'NCS'			,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_NSEQ'		, '6' 	, 'Sequencia'	, 'Sequencia'	,{}, 'N',"@E 999,999,999.9999"	,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_ITEM'		, '7' 	, 'Item'		, 'Item'		,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_PED'		, '8' 	, 'Pedido'		, 'Pedido'		,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_CLI'		, '9' 	, 'Cliente'		, 'Cliente'		,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_PRODUTO'	, '10' 	, 'Produto'		, 'Produto'		,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRLt:AddField('Z7G_LOTE'		, '11' 	, 'Lote'		, 'Lote'		,{}, 'C',						,,,.F.,,,,,,.T.)
Return oStrRLt
/* 
    Campos Lateral Direita ABA02 Rodape ModelDef
*/
Static Function GetMdpLt2(oModel, oStrRLt2)
	oStrRLt2:AddField('Peso Total Item'	, 'Peso Total Item'		, 'RLT_VLR1'	, 'N',12 ,2,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRLt2:AddField('Peso Total'		, 'Peso Total'			, 'RLT_VLR2'	, 'N',12 ,2,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRLt2:AddField('Obs'				, 'Obs'					, 'RLT_OBS'		, 'C',100,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
Return oStrRLt2
/* 
    Campos Lateral Direita ABA02 Rodape ViewDef
*/
Static Function GetVRpLt2(oModel, oStrRLt2)
	oStrRLt2:AddField('RLT_VLR1'	, '1', 'Peso Total Item'	, 'Peso Total Item'	,{}, 'C',,,,.F., 'PASTARODAPE', 'GRUPO01',,,,.T.)
	oStrRLt2:AddField('RLT_VLR2'	, '2', 'Peso Total'			, 'Peso Total'		,{}, 'C',,,,.F., 'PASTARODAPE', 'GRUPO01',,,,.T.)
	oStrRLt2:AddField('RLT_OBS'		, '3', 'Obs'				, 'Obs'				,{}, 'C',,,,.F., 'PASTARODAPE', 'GRUPO01',,,,.T.)
RETURN oStrRLt2
/* 
    Campos ABA01 Rodape ModelDef
*/
Static Function getMdRDp( oModel , oStrRDp)
	oStrRDp:AddField('Produto'			, 'Produto'				, 'RDP_PROD', 'C',100,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRDp:AddField('Cliente'			, 'Cliente'				, 'RDP_CLI'	, 'C',100,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRDp:AddField('Pedido'			, 'Pedido'				, 'RDP_PED'	, 'C',100,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRDp:AddField('Obs'				, 'Obs'					, 'RDP_OBS'	, 'C',100,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRDp:AddField('Endereço'			, 'Endereço'			, 'RDP_END'	, 'C',100,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRDp:AddField('Peso Total Item'	, 'Peso Total Item'		, 'RDP_VLR1', 'N',13	,2,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStrRDp:AddField('Peso Total'		, 'Peso Total'			, 'RDP_VLR2', 'N',13	,2,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
Return oStrRDp
/* 
    Campos ABA01 Rodape ViewDef
*/
Static Function GetVRpDp(oModel, oStrRDp)
	oStrRDp:AddField('RDP_PROD'	, '1', 'Produto'		, 'Produto'			,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRDp:AddField('RDP_CLI'	, '2', 'Cliente'		, 'Cliente'			,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRDp:AddField('RDP_VLR1'	, '3', 'Peso Total Item', 'Peso Total Item'	,{}, 'N',"@E 999,999,999.999"	,,,.F.,,,,,,.T.)
	oStrRDp:AddField('RDP_PED'	, '4', 'Pedido'			, 'Pedido'			,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRDp:AddField('RDP_OBS'	, '5', 'Obs Item'		, 'Obs Item'		,{}, 'C',						,,,.F.,,,,,,.T.)
	oStrRDp:AddField('RDP_VLR2'	, '6', 'Peso Total'		, 'Peso Total'		,{}, 'N',"@E 999,999,999.999"	,,,.F.,,,,,,.T.)
	oStrRDp:AddField('RDP_END'	, '7', 'Endereço'		, 'Endereço'		,{}, 'C',						,,,.F.,,,,,,.T.)
Return oStrRDp
User Function FATB01CE()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oModelR 		:= nil
	Local oGridM 		:= nil
	Local oGridR 		:= nil
	Local _cMsg 		:= ''
	Local nTot, nTotVol, nLinha
	Local aSaveLines
	
	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 

		If Alltrim(cIdPonto) == "MODELVLDACTIVE"
		    nOper := oObj:nOperation
            If nOper != 3
                xRet := .F.
            EndIf
		else
			if Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'FORMRLT2' .AND. cIdIXB5 == 'CANSETVALUE'
				oModel 	 	:= FwModelActivate()
				oGridM 		:= oModel:GetModel("FORMGridM")
				oGridR 		:= oModel:GetModel("FORMRG2")
				oModelR 	:= oModel:GetModel("FORMRLT2")

				_cMsg 		:= AllTrim(Posicione('SZ5',1,xFilial('SZ5')+oGridR:GetValue('Z7G_PED'), 'Z5_MENNOTA'))
				nTot 		:= oGridR:GetValue("Z7G_QTDE")
				nTotVol 	:= oGridR:GetValue("Z7G_PESO")

				oGridR:LoadValue("RLT_VLR1", nTot)
				oGridR:LoadValue("RLT_VLR2", nTotVol)
				oGridR:LoadValue("RLT_OBS" , _cMsg)

 			elseif Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'FORMRG2' .and. cIdIXB5 == 'SETVALUE' /* !(aParam[5] $ "ISENABLE-ADDLINE") */
				oModel 	 	:= FwModelActivate()
				oGridM 		:= oModel:GetModel("FORMGridM")
				oGridR 		:= oModel:GetModel("FORMRG2")
				oModelR 	:= oModel:GetModel("FORMRLT2")

				if !oGridR:IsEmpty()
					cProd 	:= oGridR:GetValue("Z7G_PRODUTO")
					cPed 	:= oGridR:GetValue("Z7G_PED")
					cCli 	:= oGridR:GetValue("Z7G_CLI")

					if !oGridM:IsEmpty()
						oGridM:SeekLine({{"Z5G_NUM", cPed},{"Z6G_PRODUTO",cProd},{"Z5G_CLI",cCli}})
					endif

					_cMsg 		:= AllTrim(Posicione('SZ5',1,xFilial('SZ5')+oGridR:GetValue('Z7G_PED'), 'Z5_MENNOTA'))
					nTot 		:= oGridR:GetValue("Z7G_QTDE")
					nTotVol 	:= oGridR:GetValue("Z7G_PESO")

					oModelR:LoadValue("RLT_VLR1", nTot)
					oModelR:LoadValue("RLT_VLR2", nTotVol)
					oModelR:LoadValue("RLT_OBS" , _cMsg)
				endif 
			elseIf Alltrim(cIdPonto) == 'FORMPRE' .AND. cIdModel == 'FORMRodap1' .and. cIdIXB4 == 'CANSETVALUE'
				oModel 	 	:= FwModelActivate()
				oView 		:= FWViewActive()
				oGridM 		:= oModel:GetModel("FORMGridM")
				oGridR 		:= oModel:GetModel("FORMRG2")
				oModelR 	:= oModel:GetModel("FORMRodap1")
				aSaveLines 	:= FWSaveRows()
				nLinha := oGridM:GetLine()
				if !oGridM:IsEmpty()
					_Cli  		:= SubStr(oGridM:GetValue("Z5G_CLI"),1,6)
					_Loja 		:= SubStr(oGridM:GetValue("Z5G_CLI"),8,2)
					_CliNome 	:= AllTrim(oGridM:GetValue("Z5G_CLI")) + " / " +;
									Posicione('SA1',1,xFilial('SA1')+_Cli+_Loja, 'A1_NOME')
					_End  		:= AllTrim(Posicione('SA1',1,xFilial('SA1')+_Cli+_Loja, 'A1_MUN')) + " - " +;
									AllTrim(Posicione('SA1',1,xFilial('SA1')+_Cli+_Loja, 'A1_BAIRRO')) + ", " +;
									AllTrim(Posicione('SA1',1,xFilial('SA1')+_Cli+_Loja, 'A1_EST')) + ", " +;
									AllTrim(Posicione('SA1',1,xFilial('SA1')+_Cli+_Loja, 'A1_END')) 
					_cProd 		:=  AllTrim(oGridM:GetValue("Z6G_PRODUTO")) + " " +;
									AllTrim(Posicione('SB1',1,xFilial('SB1')+;
									AllTrim(oGridM:GetValue("Z6G_PRODUTO")), 'B1_DESC'))
					_cMsg 		:= AllTrim(Posicione('SZ5',1,xFilial('SZ5')+AllTrim(oGridM:GetValue('Z5G_NUM')), 'Z5_MENNOTA'))
					_cPed 		:= SubStr(AllTrim(oGridM:GetValue("Z5G_NUM")),11,6)
					nTot 		:= oGridM:GetValue("Z6G_QTDLIB")
					nTotVol 	:= oGridM:GetValue("Z6G_OMAVOL")
					
					oModelR:LoadValue('RDP_PROD', _cProd)
					oModelR:LoadValue('RDP_CLI' , _CliNome)
					oModelR:LoadValue('RDP_OBS' , _cMsg)
					oModelR:LoadValue('RDP_PED' , _cPed)
					oModelR:LoadValue('RDP_END' , _End)
					oModelR:LoadValue("RDP_VLR1", nTot)
					oModelR:LoadValue("RDP_VLR2", nTotVol)
					
					_cPed 		:= oGridM:GetValue("Z5G_NUM")
					_cProd 		:= oGridM:GetValue("Z6G_PRODUTO")
					
					IF cIdIXB5 == 'RDP_PROD'
					 	RefreshMultiLote(_Cli,_Loja,_cPed,_cProd)
					ENDIF
				endif 
				FWRestRows( aSaveLines )
				xRet := .T.
			elseif Alltrim(cIdPonto) == 'FORMPOS'
				oModel 	 	:= FwModelActivate()
				oGridM 		:= oModel:GetModel("FORMGridM")
				oGridR 		:= oModel:GetModel("FORMRG2")
				oModelR 	:= oModel:GetModel("FORMRodap1")

				if oGridR:IsEmpty()
					xRet := .T.
				endif
			ENDIF
		ENDIF
	ENDIF
RETURN xRet 
Static Function RefreshMultiLote(_cCli,_cLoja,_cPed,_cProd)
	Local oModel 	:= FwModelActivate()
	Local oGridR 	:= oModel:GetModel("FORMRG2")
	Local oModelR 	:= oModel:GetModel("FORMRLT2")
	Local _cAlias 	:= GetNextAlias()
	Local _cQry 	:= ""
	
	oGridR:SetNoInsertLine(.F.)
	_cQry := " SELECT * " + CRLF
	_cQry += " FROM "+RetSqlName("SZ7")+" SZ7" + CRLF
	_cQry += " WHERE Z7_FILIAL = '"+FWxFilial("SZ7")+"'" + CRLF
	_cQry += " 	AND Z7_PEDIDO = '"+_cPed+"'" + CRLF
	_cQry += " 	AND Z7_CLIENTE = '"+_cCli+"'" + CRLF
	_cQry += " 	AND Z7_LOJA = '"+_cLoja+"' " + CRLF
	_cQry += " 	AND Z7_PRODUTO = '"+_cProd+"' " + CRLF
	_cQry += " 	AND SZ7.D_E_L_E_T_ = ''	" + CRLF
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry), _cAlias, .F., .T. )

	oGridR:ClearData()

	While !(_cAlias)->(EOF())

		_cNcs := SubStr(AllTrim((_cAlias)->Z7_CODBAR),11,0)

		If !oGridR:IsEmpty()
			oGridR:AddLine()
		EndIf

		oGridR:LoadValue("Z7G_CODBAR"	, (_cAlias)->Z7_CODBAR)
		oGridR:LoadValue("Z7G_VALID"	, IIF( LEN( AllTrim( (_cAlias)->Z7_VALID) ) > 0, sToD((_cAlias)->Z7_VALID), STOD("")))
		oGridR:LoadValue("Z7G_QTDE"		, (_cAlias)->Z7_QTDE)
		oGridR:LoadValue("Z7G_PESO"		, (_cAlias)->Z7_PESO)
		oGridR:LoadValue("Z7G_NCS"		, _cNcs)
		oGridR:LoadValue("Z7G_NSEQ"		, (_cAlias)->Z7_NSEQ)
		oGridR:LoadValue("Z7G_ITEM"		, (_cAlias)->Z7_ITEM)
		oGridR:LoadValue("Z7G_PED"		, (_cAlias)->Z7_PEDIDO)
		oGridR:LoadValue("Z7G_CLI"		, (_cAlias)->Z7_CLIENTE + '-' +(_cAlias)->Z7_LOJA)
		oGridR:LoadValue("Z7G_PRODUTO"	, (_cAlias)->Z7_PRODUTO)
		oGridR:LoadValue("Z7G_LOTE"		, (_cAlias)->Z7_LOTE)
		
		nLSeq1 := (_cAlias)->Z7_NSEQ
		IF nLSeq1 > nLSeq
			nLSeq:=nLSeq1
		ENDIF

		_cMsg 		:= AllTrim(Posicione('SZ5',1,xFilial('SZ5')+(_cAlias)->Z7_PEDIDO, 'Z5_MENNOTA'))
		nTot 		:= (_cAlias)->Z7_QTDE 
		nTotVol 	:= (_cAlias)->Z7_PESO 

		oModelR:LoadValue("RLT_VLR1", nTot)
		oModelR:LoadValue("RLT_VLR2", nTotVol)
		oModelR:LoadValue("RLT_OBS" , _cMsg)
		
		(_cAlias)->(DbSkip())
	ENDDO
	(_cAlias)->(DbCloseArea())

	oGridR:SetNoInsertLine(.T.)
	oGridR:GoLine(1)
Return nil

Static Function ViewActv()
	Local oModel := FWModelActive()
	Local oModelC := oModel:GetModel("FORMCabec")

	if oModelC:GetValue("CBC_FOCO") == 'S'
    	oView    := FWViewActive()
    	oView:Refresh('VIEW_Cabec')
    	oView:GetViewObj("VIEW_Cabec")[3]:getFWEditCtrl("CBC_LOTEVIF"):oCtrl:OGet:SetFocus()
	endif 
Return
/* 
    Preenchimento do Formulário
    Chamado na Validação do Campo CBC_CTPAD 
	e na Função U_CEFATBV
*/
User Function CEFATBPG()
	Local aArea 		:= GetArea()
	Local _cQry 		:= ''
	Local oModel 		:= FWModelActive()
	Local oView 		:= FWViewActive()
	Local oModelGM 	 	:= oModel:GetModel('FORMGridM')
	Local oModelGR 		:= oModel:GetModel('FORMRG2')
	Local oModelCab 	:= oModel:GetModel('FORMCabec')
	Local _cAlias 		:= GetNextAlias()
	local lRet			:= .T.
	
	lPreSZ7 := .F.

	oModelGM:SetNoInsertLine(.F.)
	oModelGR:SetNoInsertLine(.F.)
	
	If !oModelGM:IsEmpty()
		oModelGM:ClearData()
	EndIf
	if oMOdelCab:GetValue("CBC_CBROMA") == 'N'
		_cQry := " SELECT  Z5_NUM " 	+ CRLF
		_cQry += "		,Z5_VVISTA " 	+ CRLF
		_cQry += "		,Z5_CLIENT " 	+ CRLF
		_cQry += "		,Z5_LOJACLI " 	+ CRLF
		_cQry += "		,A1_NREDUZ " 	+ CRLF
		_cQry += "		,A1_GRPVEN " 	+ CRLF
		_cQry += "		,A1_ROTENTR " 	+ CRLF
		_cQry += "		,Z5_TRANSP " 	+ CRLF
		_cQry += "      ,Z5_TRANSP2 " 	+ CRLF
		_cQry += "		,Z5_TRANSP3 " 	+ CRLF
		_cQry += "		,Z5_VEICULO " 	+ CRLF
		_cQry += "		,Z5_VEIC2 " 	+ CRLF
		_cQry += "		,Z5_NOTA " 		+ CRLF
		_cQry += "		,Z5_SERIE " 	+ CRLF
		_cQry += "      ,Z6_PRODUTO " 	+ CRLF
		_cQry += "		,Z6_UNSVEN " 	+ CRLF
		_cQry += "		,Z6_QTDVEN " 	+ CRLF
		_cQry += "		,Z6_UM " 		+ CRLF
		_cQry += "		,Z6_QTDLIB2 " 	+ CRLF
		_cQry += "		,Z6_QTDLIB " 	+ CRLF
		_cQry += "		,Z6_OMAVOL " 	+ CRLF
		_cQry += "		,Z6_OK " 		+ CRLF
		_cQry += "		,Z6_LOTEVIF " 	+ CRLF
		_cQry += "		,Z6_ITEM " 		+ CRLF
		_cQry += "		,Z5_CIDADE " 	+ CRLF
		_cQry += "		,Z5_END " 		+ CRLF
		_cQry += "		,A4_NOME " 		+ CRLF
		_cQry += "		,Z6_XPRDKIT " 	+ CRLF
		_cQry += "		,Z6_SALDWMS " 	+ CRLF
		_cQry += "FROM "+RetSqlName("SZ6")+" Z6 " + CRLF
		_cQry += " LEFT JOIN "+RetSqlName("SZ5")+" Z5 ON Z5_FILIAL = Z6_FILIAL " + CRLF
		_cQry += " 	  AND Z6.Z6_NUM = Z5.Z5_NUM 		 " + CRLF
		_cQry += "	  AND Z5_TRANSP = '" + AllTrim(oModelCab:GetValue("CBC_CTPAD")) + "'" + CRLF
		_cQry += "	  AND Z5.D_E_L_E_T_ = '' " + CRLF
		_cQry += " JOIN "+RetSqlName("SA1")+" A1 ON A1_COD = Z5_CLIENTE  " + CRLF
		_cQry += "		AND A1_LOJA = Z5_LOJACLI  " + CRLF
		_cQry += "		AND A1.D_E_L_E_T_ = ' '  " + CRLF
		_cQry += " JOIN "+RetSqlName("SA4")+" A4  " + CRLF
		_cQry += "    ON A4_COD = Z5_TRANSP  " + CRLF
		_cQry += "	 AND A4.D_E_L_E_T_ = ' '  " + CRLF
		_cQry += "	  JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = Z6_PRODUTO " + CRLF
		DO CASE                              //'1 - Todos Itens','2 - Itens a granel','3 - Peso Padrao'
		CASE SUBSTR(oModelCab:GetValue("CBC_ITENS"),1,1) =='2'
			_cQry += " AND B1_TPDESP='2'  "+ CRLF
		CASE SUBSTR(oModelCab:GetValue("CBC_ITENS"),1,1) =='3'
			_cQry += " AND B1_TPDESP='3'  "+ CRLF
		ENDCASE
		_cQry += "	  AND B1_FILIAL = '02' " + CRLF
		_cQry += "	  AND B1.D_E_L_E_T_ = '' " + CRLF
		_cQry += "WHERE Z6_STATUS = '1'   " + CRLF
		_cQry += "   AND Z6_ENTREG = '"+ dToS(oModelCab:GetValue("CBC_ENTREGA")) + "'" + CRLF
		_cQry += "   AND Z6.D_E_L_E_T_ = '' " + CRLF

		DO CASE
			CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='1'   //'1 - Zona crescente Roteiro Crescente'
				_cQry += "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR     ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "+ CRLF
			CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='2'   //'2 - Zona Crescente Roteiro Decrescente'
				_cQry += "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR DESC,Z5_NUM,Z5_CLIENTE DESC ,Z5_LOJACLI,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO)  "+ CRLF
			CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='3'   //'3 - Codigo de Produto'
				_cQry += "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO),A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM  "+ CRLF
			CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='4'   //'4 - Cidade'
				_cQry += "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, Z5_CIDADE,Z5_END,Z5_NUM,Z5_CLIENTE ,Z5_LOJACLI  "+ CRLF
			OTHERWISE
				_cQry += "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "+ CRLF
		ENDCASE
	ELSE 
		_cQry :=       	" SELECT Z5_VVISTA,Z5_NUM,Z5_CLIENTE,Z5_LOJACLI,A1_NREDUZ,A1_GRPVEN,A1_ROTENTR "
		_cQry += CRLF + "        , Z5_TRANSP,Z5_TRANSP2,Z5_TRANSP3,Z5_VEICULO,Z5_VEIC2,Z5_NOTA,Z5_SERIE "
		_cQry += CRLF + "        , Z6_PRODUTO,Z6_UNSVEN,Z6_QTDVEN ,Z6_UM,Z6_QTDLIB2,Z6_QTDLIB,Z6_OMAVOL,Z6_OK,Z6_ITEM,Z5_CIDADE,Z5_END,A4_NOME, Z6_XPRDKIT "
		_cQry += CRLF + "        , COALESCE(Z23.Z23_ID,'') Z23_ID, Z6_SALDWMS "
		_cQry += CRLF + " FROM "+RetSqlName('SZ5')+" Z5 "
		_cQry += CRLF + " INNER JOIN " + RetSqlName('SZ6') + " Z6 "
		_cQry += CRLF + " 	ON Z6_NUM=Z5_NUM "
		_cQry += CRLF + "   AND Z6_STATUS IN ('1')  "
		_cQry += CRLF + "   AND Z6_ENTREG ='"+DTOS(oModelCab:GetValue("CBC_ENTREGA"))+"'  "
		_cQry += CRLF + "   AND Z6.D_E_L_E_T_=' ' "
		_cQry += CRLF + " INNER JOIN " + RetSqlName('SA1') + " A1 "
		_cQry += CRLF + "    ON A1_COD=Z5_CLIENTE  "
		_cQry += CRLF + "   AND A1_LOJA=Z5_LOJACLI "
		_cQry += CRLF + "   AND A1_XTPCLI  = '" + oModelCab:GetValue("CBC_TPCLI") + "'"
		_cQry += CRLF + "   AND A1_EST = '" + oModelCab:GetValue("CBC_UF") + "'"
		IF !EMPTY(oModelCab:GetValue("CBC_ZONA"))
			_cQry += CRLF + " AND A1_GRPVEN='"+oModelCab:GetValue("CBC_ZONA")+"'  "
		ENDIF
		_cQry += CRLF + "   AND A1.D_E_L_E_T_=' ' "
		_cQry += CRLF + " INNER JOIN " + RetSqlName('SA4') + " A4 "
		_cQry += CRLF + "    ON A4_COD=Z5_TRANSP "
		_cQry += CRLF + "   AND A4.D_E_L_E_T_=' ' "
		_cQry += CRLF + " INNER JOIN " + RetSqlName('SB1') + " B1 "
		_cQry += CRLF + "   ON  B1_COD=Z6_PRODUTO "
		_cQry += CRLF + "   AND B1_FILIAL ='02'  "
		_cQry += CRLF + "   AND B1.D_E_L_E_T_=' '  "
		If !Empty( oModelCab:GetValue("CBC_ROMA") )
			_cQry += CRLF + " INNER JOIN " + RetSqlName('Z23') + " Z23 "
			_cQry += CRLF + "    ON Z23_FILIAL = '02'"
			_cQry += CRLF + "   AND Z23_NUM = Z6.Z6_NUM "
			_cQry += CRLF + "   AND Z23.D_E_L_E_T_=' '  "
			_cQry += CRLF + "   AND Z23.Z23_ID = '" + oModelCab:GetValue("CBC_ROMA") + "' "
		Else
			_cQry += CRLF + " LEFT JOIN " + RetSqlName('Z23') + " Z23 "
			_cQry += CRLF + "    ON Z23_FILIAL = '02'"
			_cQry += CRLF + "   AND Z23_NUM = Z6.Z6_NUM "
			_cQry += CRLF + "   AND Z23.D_E_L_E_T_=' '  "
		Endif
		_cQry += CRLF + " WHERE Z5.D_E_L_E_T_=' '"
		_cQry += CRLF + "   AND Z5_TRANSP='"+oModelCab:GetValue("CBC_CTPAD")+"' "
		_cQry += CRLF + "   AND CASE WHEN (Z5_XTPSHEL IS NULL OR Z5_XTPSHEL = '' ) "
		_cQry += CRLF + "            THEN A1_XTPSHEL ELSE Z5_XTPSHEL END = '" + oModelCab:GetValue("CBC_TPSHELF") + "'
	
		DO CASE                              //'1 - Todos Itens','2 - Itens a granel','3 - Peso Padrao'
		CASE SUBSTR(oModelCab:GetValue("CBC_ITENS"),1,1) =='2'
			_cQry += CRLF + " AND B1_TPDESP='2'  "
		CASE SUBSTR(oModelCab:GetValue("CBC_ITENS"),1,1) =='3'
			_cQry += CRLF + " AND B1_TPDESP='3'  "
		ENDCASE
		//------------------------- ORDER------------------------------
		DO CASE
		CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='1'   //'1 - Zona crescente Roteiro Crescente'
			_cQry += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR     ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "
		CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='2'   //'2 - Zona Crescente Roteiro Decrescente'
			_cQry += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR DESC,Z5_NUM,Z5_CLIENTE DESC ,Z5_LOJACLI,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO)  "
		CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='3'   //'3 - Codigo de Produto'
			_cQry += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO),A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM  "
		CASE SUBSTR(oModelCab:GetValue("CBC_ORDG"),1,1) =='4'   //'4 - Cidade'
			_cQry += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, Z5_CIDADE,Z5_END,Z5_NUM,Z5_CLIENTE ,Z5_LOJACLI  "
		OTHERWISE
			_cQry += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "
		ENDCASE
	ENDIF

	If lower(cUserName) $ 'bernardo'
		MemoWrite(StrTran(cArquivo,".xml","")+"_LancamentoDespacho_.sql" , _cQry)
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry), _cAlias, .F., .T. )

	oModelCab:LoadValue("CBC_CTPRIM", (_cAlias)->Z5_TRANSP2)
	oModelCab:LoadValue("CBC_CTENTR", (_cAlias)->Z5_TRANSP3)
	oModelCab:LoadValue("CBC_NTENTR", Posicione('SA4',1,xFilial('SA4')+(_cAlias)->Z5_TRANSP3 , 'A4_NOME'))
	oModelCab:LoadValue("CBC_NTPAD" , Posicione('SA4',1,xFilial('SA4')+(_cAlias)->Z5_TRANSP  , 'A4_NOME'))
	oModelCab:LoadValue("CBC_NTPRIM", Posicione('SA4',1,xFilial('SA4')+(_cAlias)->Z5_TRANSP2 , 'A4_NOME'))
	oModelCab:LoadValue("CBC_CTPRIM", (_cAlias)->Z5_TRANSP2)
	oModelCab:LoadValue("CBC_PLACAE", (_cAlias)->Z5_VEICULO)
	oModelCab:LoadValue("CBC_PLACAP", (_cAlias)->Z5_VEIC2)

	While !(_cAlias)->(EOF())
	 	cROTENT:=StrZero((_cAlias)->A1_ROTENTR,5)
		cROTENT:=SubStr(cROTENT,1,3) + ' / ' + SubStr(cROTENT,4,2)  

		if (_cAlias)->Z5_NOTA == "" 
			cNota := ""
		else 
			cNota := AllTrim((_cAlias)->Z5_NOTA) + '-' + AllTrim((_cAlias)->Z5_SERIE)
		ENDIF
		
		If !oModelGM:IsEmpty()
			oModelGM:AddLine()
		EndIf

		oModelGM:LoadValue("Z5G_NUM"	, AllTrim((_cAlias)->Z5_NUM) 										) 
		oModelGM:LoadValue("Z5G_CLI"	, AllTrim((_cAlias)->Z5_CLIENT+'-'+(_cAlias)->Z5_LOJACLI) 			) 
		oModelGM:LoadValue("A1G_NREDUZ"	, AllTrim((_cAlias)->A1_NREDUZ) 									) 
		oModelGM:LoadValue("A1G_ROTENTR", 					 cROTENT					 					) 
		oModelGM:LoadValue("Z6G_PRODUTO", AllTrim((_cAlias)->Z6_PRODUTO) 									) 
		oModelGM:LoadValue("Z6G_UNSVEN"	, 		  (_cAlias)->Z6_UNSVEN 										) 
		oModelGM:LoadValue("Z6G_QTDVEN"	, 		  (_cAlias)->Z6_QTDVEN 										) 
		oModelGM:LoadValue("Z6G_UM"		, AllTrim((_cAlias)->Z6_UM) 										) 
		oModelGM:LoadValue("Z6G_QTDLIB2", 		  (_cAlias)->Z6_QTDLIB2 									) 
		oModelGM:LoadValue("Z6G_QTDLIB"	, 		  (_cAlias)->Z6_QTDLIB 										) 
		oModelGM:LoadValue("Z6G_OMAVOL"	, 		  (_cAlias)->Z6_OMAVOL 										) 
		oModelGM:LoadValue("Z5G_NOTA"	, 					 cNota											) 
		oModelGM:LoadValue("Z6G_VVISTA"	, AllTrim((_cAlias)->Z5_VVISTA) 									) 
		oModelGM:LoadValue("Z6G_LOTEVIF", AllTrim((_cAlias)->Z6_LOTEVIF) 									) 
		oModelGM:LoadValue("Z6G_ITEM"	, 		  (_cAlias)->Z6_ITEM										) 
		oModelGM:LoadValue("Z6G_SALDWMS", 		  (_cAlias)->Z6_SALDWMS										)			 
		oModelGM:LoadValue("Z6G_XPRDKIT", AllTrim((_cAlias)->Z6_XPRDKIT)									)			 
		oModelGM:LoadValue("A1G_GRPVEN" , AllTrim((_cAlias)->A1_GRPVEN)										)			 

		cLeg := LOTECLR(oModel, oModelGM)
		oModelGM:LoadValue("Z6G_LEGEND"	, cLeg ) 

		(_cAlias)->(dbSkip())
	ENDDO
	(_cAlias)->(dbCloseArea())

 	oModelGM:SetNoInsertLine(.T.)
	oModelGM:SetNoDeleteLine(.T.)
	oModelGM:GoLine(1)

	oModelGR:SetNoInsertLine(.T.) 

	lPreSZ7 := .T. 
	lInicia := .T.

	oView:Refresh()

	RestArea(aArea)
RETURN lRet
/* 
    Função chamada no botão Visualizar e Validação do Campo CBC_CTPAD
    Faz a chamada da Função U_CEFATBPG Para inclusÃ£o dos dados
*/
User Function CEFATBV()
	Local oModel 	:= FWModelActive()
	Local oModelCab := oModel:GetModel('FORMCabec')

	If Empty(oModelCab:GetValue('CBC_CTPRIM'))
		MsgAlert('Por Favor, preencher o Codigo e Placa  da Transportadora Primaria')
		Return .F.
	EndIf

	If Empty(oModelCab:GetValue('CBC_PLACAP'))
		MsgAlert('Por Favor, preencher o Codigo e Placa  da Transportadora Primaria')
		Return .F.
	EndIf

	MsAguarde( { || U_CEFATBPG() } , "Aguarde..." )
Return 
/* 
    Preencher Campos Z6G_QTDLIB2, Z6G_QTDLIB, Z6G_OMAVOL Com Peso Padrão
    Chamado no botão PesoPAD
*/
Static Function CEFATBP()
	If MsgYesNo('Preencher peso Despachado com o Peso Padrao do Produto  ?  ')
		MsAguarde( { || CEFATBP2() } , "Aguarde Preenchendo com Peso Padrao..." )
	EndIf
Return
/* ---------------------------------------------------------------------------------- */
/* Chamado pela Função a cima */
Static Function CEFATBP2()
	Local aArea  		:= GetArea()
	Local oModel 		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelGR 		:= oModel:GetModel("FORMRG2")
	Local aSaveLines 	:= FWSaveRows()
	Local nPeso_
	Local cProd
	Local nI

	If !oModelGM:IsEmpty()
		For nI := 1 to oModelGM:GetQtdLine()
		
			oModelGM:GoLine(nI)

			If oModelGM:GetValue("Z6G_UNSVEN")>0
				cProd := oModelGM:GetValue("Z6G_PRODUTO")
				nPeso_ := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_PESO")
				If nPeso_ > 0 .And. oModelGR:IsEmpty() .and. oModelGM:GetValue("Z6G_QTDLIB") == 0 
					oModelGM:LoadValue("Z6G_QTDLIB2", oModelGM:GetValue("Z6G_UNSVEN"))
					oModelGM:LoadValue("Z6G_QTDLIB" , oModelGM:GetValue("Z6G_UNSVEN") * nPeso_)
					oModelGM:LoadValue("Z6G_OMAVOL" , oModelGM:GetValue("Z6G_UNSVEN"))
				EndIf
			EndIf
		Next nI
	EndIf 
	FWRestRows(aSaveLines)
	RestArea(aArea)
Return
/* 
    Faz a limpeza do Formulário, chamado no botão Limpar e final do Despacho na Função CEFATBD2()
*/
Static Function CEFATBL()
 	Local oModel 		:= FWModelActive()
	Local oModelCab 	:= oModel:GetModel("FORMCabec")
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelRLt 	:= oModel:GetModel("FORMRodap1")
	Local oModelRGt 	:= oModel:GetModel("FORMRG2")
	Local oModelRLt2 	:= oModel:GetModel("FORMRLT2")
	
	aRodap2 := {}

	//Cabeçalho
	oModelCab:LoadValue("CBC_CBROMA"	, "N"	)
	oModelCab:LoadValue("CBC_TPCLI"		, "R"	)
	oModelCab:LoadValue("CBC_TPSHELF"	, "1"	)
	oModelCab:LoadValue("CBC_UF"		, 'SP'	)
	oModelCab:LoadValue("CBC_CTPAD"		, ""	)
	oModelCab:LoadValue("CBC_CTPRIM"	, ""	)
	oModelCab:LoadValue("CBC_CTENTR"	, ""	)
	oModelCab:LoadValue("CBC_ENTREGA"	, dUlFat)
	oModelCab:LoadValue("CBC_PLACAP"	, ""	)
	oModelCab:LoadValue("CBC_PLACAE"	, ""	)
	oModelCab:LoadValue("CBC_NTPAD"		, ""	)
	oModelCab:LoadValue("CBC_NTPRIM"	, ""	)
	oModelCab:LoadValue("CBC_NTENTR"	, ""	)

	oModelGM:ClearData()

	oModelRGt:ClearData()

	oModelRLt:LoadValue("RDP_PROD"	,"")
	oModelRLt:LoadValue("RDP_CLI"	,"")
	oModelRLt:LoadValue("RDP_VLR1"	,0)
	oModelRLt:LoadValue("RDP_PED"	,"")
	oModelRLt:LoadValue("RDP_OBS"	,"")
	oModelRLt:LoadValue("RDP_VLR2"	,0)
	oModelRLt:LoadValue("RDP_END"	,"")

	oModelRLt2:LoadValue("RLT_VLR1",0)
	oModelRLt2:LoadValue("RLT_VLR2",0)
	oModelRLt2:LoadValue("RLT_OBS" , '')
RETURN
/* 
    Função para reservar NF, chamado no botão GeraNF
*/
Static Function CEFATBNF()
	Local aArea    		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oModelCab 	:= oModel:GetModel('FORMCabec')
	Local oModelGM 		:= oModel:GetModel('FORMGridM')
	Local _cAlias 		:= GetNextAlias()
	LOCAL _cQry 		:= ""
	LOCAL _cQryNF2 		:= ""
	LOCAL _cQryNF 		:= ""
	Local nI        	:= 0
	LOCAL cAutoFAT  	:= GETMV('MV_AUTOFAT')
	Local cGrpProd		:= ""
	Local _cSerie		:= ""
	Local lFirst3		:= .T.
	Local lRet 			:= .T.
	Local aSaveLines 	:= FWSaveRows()

	PRIVATE lNFFirst :=.T.

	If !oModelGM:IsEmpty()
	
		FOR nI :=1 TO oModelGM:GetQtdLine()
			SZ6->(DBSEEK(xFILIAL('SZ6')+oModelGM:GetValue("Z5G_NUM")+SUBSTR(oModelGM:GetValue("Z5G_CLI"),1,6)+SUBSTR(oModelGM:GetValue("Z5G_CLI"),8,2)+oModelGM:GetValue("Z6G_PRODUTO")))
			IF SZ6->(FOUND())
				DO WHILE .NOT. SZ6->(EOF()) .AND.  SZ6->Z6_FILIAL==xFILIAL('SZ6') .AND.;
						SZ6->Z6_NUM     == oModelGM:GetValue("Z5G_NUM")           .AND.  ;
						SZ6->Z6_CLI     == SUBSTR(oModelGM:GetValue("Z5G_CLI"),1,6) .AND.  ;
						SZ6->Z6_LOJA    == SUBSTR(oModelGM:GetValue("Z5G_CLI"),8,2) .AND.  ;
						SZ6->Z6_PRODUTO == oModelGM:GetValue("Z6G_PRODUTO")

					IF SZ6->Z6_ITEM == oModelGM:GetValue("Z6G_ITEM")
						SZ6->(RECLOCK('SZ6',.F.))
						SZ6->Z6_OMAVOL   := oModelGM:GetValue("Z6G_OMAVOL")//
						SZ6->(MSUNLOCK())
					ENDIF
					SZ6->(DBSKIP())
				ENDDO
			ELSE
				MSGALERT('MSG 000001A','MSG')
			ENDIF
		NEXT

		Do While !Empty(cAutoFAT)
			MsgAlert("Geração NF Bloqueado,  " +cAutoFAT, "Atenção...")
			cAutoFAT := GETMV('MV_AUTOFAT')
		ENDDO

		PutMv("MV_AUTODES",SubStr(cUsuario,7,15))
		
		If MsgYesNo('Gravar numero automatico da NF no Pré Pedido ?', 'Atenção')
			If MsgYesNo('Gravar numero automatico da NF no Pré Pedido ?', 'Atenção')
				
				_cQry := " SELECT  Z5_NUM " + CRLF
				_cQry += "		,Z5_CLIENT " + CRLF
				_cQry += "		,Z5_LOJACLI " + CRLF
				_cQry += "		,A1_NREDUZ " + CRLF
				_cQry += "		,A1_GRPVEN " + CRLF
				_cQry += "		,A1_ROTENTR " + CRLF
				_cQry += "		,Z5_TRANSP " + CRLF
				_cQry += "       ,Z5_TRANSP2 " + CRLF
				_cQry += "		,Z5_TRANSP3 " + CRLF
				_cQry += "		,Z5_VEICULO " + CRLF
				_cQry += "		,Z5_VEIC2 " + CRLF
				_cQry += "		,Z5_NOTA " + CRLF
				_cQry += "		,Z5_SERIE " + CRLF
				_cQry += "		 ,Z5_EMPRESA "+ CRLF
				_cQry += "      ,Z6_PRODUTO " + CRLF
				_cQry += "		,Z6_UNSVEN " + CRLF
				_cQry += "		,Z6_QTDVEN " + CRLF
				_cQry += "		,Z6_UM " + CRLF
				_cQry += "		,Z6_QTDLIB2 " + CRLF
				_cQry += "		,Z6_QTDLIB " + CRLF
				_cQry += "		,Z6_OMAVOL " + CRLF
				_cQry += "		,Z6_OK " + CRLF
				_cQry += "		,Z6_ITEM " + CRLF
				_cQry += "		,A4_NOME " + CRLF
				_cQry += "FROM "+RetSqlName("SZ6")+" Z6 " + CRLF
				_cQry += " LEFT JOIN "+RetSqlName("SZ5")+" Z5 ON Z5_FILIAL = Z6_FILIAL " + CRLF
				_cQry += " 	  AND Z6.Z6_NUM = Z5.Z5_NUM 		 " + CRLF
				_cQry += "	  AND Z5_TRANSP = '" + AllTrim(oModelCab:GetValue("CBC_CTPAD")) + "'" + CRLF
				_cQry += "	  AND Z5.D_E_L_E_T_ = '' " + CRLF
				_cQry += " LEFT JOIN "+RetSqlName("SA1")+" A1 ON A1_COD = Z5_CLIENTE  " + CRLF
				_cQry += "		AND A1_LOJA = Z5_LOJACLI  " + CRLF
				_cQry += "		AND A1.D_E_L_E_T_ = ' '  " + CRLF
				_cQry += " JOIN "+RetSqlName("SA4")+" A4  " + CRLF
				_cQry += "    ON A4_COD = Z5_TRANSP  " + CRLF
				_cQry += "	 AND A4.D_E_L_E_T_ = ' '  " + CRLF
				_cQry += "WHERE Z6_STATUS = '1'   " + CRLF
				_cQry += "   AND Z6_ENTREG = '"+ dToS(oModelCab:GetValue("CBC_ENTREGA")) + "'" + CRLF
				_cQry += "   AND Z6.D_E_L_E_T_ = '' " + CRLF

				If lower(cUserName) $ 'bernardo'
					MemoWrite(StrTran(cArquivo,".xml","")+"_LancamentoDespacho_.sql" , _cQry)
				EndIf
				
				dbUseArea( .T., "TOPCONN", TcGenQry( ,,_cQry), _cAlias, .F., .T. )
				
				cNUMPPV :=(_cAlias)->Z5_NUM

				_cSerie  := GetMV("MV_SERFAT")

				SZ5->(DbSelectArea('SZ5'))
				SZ5->(DbSetOrder(1))
				SZ5->(DbGoTop())
				
				cPEDIDO := (_cAlias)->Z5_NUM
				lFIRST3 := .T.

				Do While !(_cAlias)->(EOF())

					cGrpProd := AllTrim(Posicione('SB1',1,xFilial('SB1')+(_cAlias)->Z6_PRODUTO, 'B1_GRUPO'))

						If (_cAlias)->Z5_EMPRESA == 'B' 
							
							SZ5->(DBSEEK(xFILIAL('SZ5')+(_cAlias)->Z5_NUM))
							
							IF SZ5->(FOUND())
								IF  (_cAlias)->Z5_NUM <>cPEDIDO .OR. lFIRST3==.T.	

									DO CASE
									CASE  SZ5->Z5_EMPRESA =='1' //MATRIZ
										_cSerie  := GetMV("MV_SERFAT")
									CASE  SZ5->Z5_EMPRESA =='B' //VINHEDO
										_cSerie  := ALLTRIM(GetMV("MV_SERFAT"))//'1  ' Rodolfo Vacari 22/02/2017
									OTHERWISE
										_cSerie  := GetMV("MV_SERFAT")
									ENDCASE

									cPEDIDO :=(_cAlias)->Z5_NUM
									lFIRST3:=.F.
									
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
									SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
									SZ5->Z5_VEIC2    := oModelCab:GetValue("CBC_PLACAE")
									SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")
									If Empty(ALLTRIM(SZ5->Z5_NOTA))
										_cQryNF := "SELECT X5_DESCRI FROM "+RetSqlName('SX5')+" WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery _cQryNF ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA())
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										_cQryNF2 := "UPDATE "+RetSqlName('SX5')+" SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(_cQryNF2)

										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie

										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
						ENDIF
						ElseIf (_cAlias)->Z5_EMPRESA == 'C'
							
							SZ5->(DBSEEK(xFILIAL('SZ5')+(_cAlias)->Z5_NUM))

							IF SZ5->(FOUND())
								IF  (_cAlias)->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=(_cAlias)->Z5_NUM
									lFIRST3:=.F.

									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
									SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
									SZ5->Z5_VEIC2    := oModelCab:GetValue("CBC_PLACAE")
									SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")

									If Empty(SZ5->Z5_NOTA)
										_cQryNF := "SELECT X5_DESCRI FROM "+RetSqlName('SX5')+" WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '2' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery _cQryNF ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA())
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										_cQryNF2 := "UPDATE "+RetSqlName('SX5')+" SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '2' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(_cQryNF2)

										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie

										SZ5->Z5_NOTA  := cNOTA
										SZ5->Z5_SERIE := cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
							cFilEmp := cBkpEmp
							cFilAnt := cBkpFil
						ElseIf (_cAlias)->Z5_EMPRESA == '7'
							cEmpAnt := "07"
							cFilAnt := "01"
							SZ5->(DBSEEK(xFILIAL('SZ5')+(_cAlias)->Z5_NUM))
							IF SZ5->(FOUND())
								IF  (_cAlias)->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=(_cAlias)->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
									SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
									SZ5->Z5_VEIC2    := oModelCab:GetValue("CBC_PLACAE")
									SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")

									If Empty(SZ5->Z5_NOTA)
										_cQryNF := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '01' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery _cQryNF ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA())
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										_cQryNF2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '01' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(_cQryNF2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
							cFilEmp := cBkpEmp
							cFilAnt := cBkpFil
						ElseIf (_cAlias)->Z5_EMPRESA == 'R'
							cEmpAnt := "07"
							cFilAnt := "02"
							SZ5->(DBSEEK(xFILIAL('SZ5')+(_cAlias)->Z5_NUM))
							IF SZ5->(FOUND())
								IF  (_cAlias)->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=(_cAlias)->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
									SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
									SZ5->Z5_VEIC2    := oModelCab:GetValue("CBC_PLACAE")
									SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")	

									If Empty(SZ5->Z5_NOTA)
										_cQryNF := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '02' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery _cQryNF ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA())
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										_cQryNF2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '02' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(_cQryNF2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
						cFilEmp := cBkpEmp
						cFilAnt := cBkpFil
						ElseIf (_cAlias)->Z5_EMPRESA == 'P'
							cEmpAnt := "07"
							cFilAnt := "04"
							SZ5->(DBSEEK(xFILIAL('SZ5')+(_cAlias)->Z5_NUM))
							IF SZ5->(FOUND())
								IF  (_cAlias)->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=(_cAlias)->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
									SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
									SZ5->Z5_VEIC2    := oModelCab:GetValue("CBC_PLACAE")
									SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")

									If Empty(SZ5->Z5_NOTA)
										_cQryNF := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '04' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery _cQryNF ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA())
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										_cQryNF2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '04' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(_cQryNF2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
						ElseIf (_cAlias)->Z5_EMPRESA == 'G'
							cEmpAnt := "07"
							cFilAnt := "06"
							SZ5->(DBSEEK(xFILIAL('SZ5')+(_cAlias)->Z5_NUM))
							IF SZ5->(FOUND())
								IF  (_cAlias)->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=(_cAlias)->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
									SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
									SZ5->Z5_VEIC2    := oModelCab:GetValue("CBC_PLACAE")
									SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")

									If Empty(SZ5->Z5_NOTA)
										_cQryNF := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '06' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery _cQryNF ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA())
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										_cQryNF2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '06' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(_cQryNF2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
						ElseIf (_cAlias)->Z5_EMPRESA == '6'
							cEmpAnt := "06"
							cFilAnt := "01"
							SZ5->(DBSEEK(xFILIAL('SZ5')+(_cAlias)->Z5_NUM))
							IF SZ5->(FOUND())
								IF  (_cAlias)->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=(_cAlias)->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
									SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
									SZ5->Z5_VEIC2    := oModelCab:GetValue("CBC_PLACAE")
									SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")

									If Empty(SZ5->Z5_NOTA)
										_cQryNF := "SELECT X5_DESCRI FROM SX5060 WHERE X5_FILIAL = '' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery _cQryNF ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA())
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										_cQryNF2 := "UPDATE SX5060 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(_cQryNF2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF

							cFilEmp := cBkpEmp
							cFilAnt := cBkpFil
						EndIf
					(_cAlias)->(DBSKIP())
				ENDDO
			EndIf
			For nI := 1 to oModelGM:GetQtdLine()
				oModelGM:GoLine(nI)
					if REPLACE(oModelGM:GetValue("Z5G_NOTA"), '-', '') != '' 
					cNota   := Posicione('SZ5', 1, xFilial('SZ5') + oModelGM:GetValue("Z5G_NUM"), 'Z5_NOTA' ) 
					_cSerie := Posicione('SZ5', 1, xFilial('SZ5') + oModelGM:GetValue("Z5G_NUM"), 'Z5_SERIE' )
					oModelGM:LoadValue("Z5G_NOTA", cNota + '-' + _cSerie)
				EndIf
			Next
		EndIf
		(_cAlias)->(DBCloseArea())
		PutMv("MV_AUTODES", '')
		FWRestRows( aSaveLines )
	ELSE
		MsgYesNo('Nao existe itens para numeração, pressione visualizar ', 'Arte[')
	EndIf
	RestArea(aArea)
Return lRet
/* 
    Função para preencher Volume para impressão das Etiquetas
    Chamado no botão PreVol
*/
Static Function CEFATBVol()
	If(MsgYesNo("Deseja preencher o volume para impressão das etiquetas?"))
		MsAguarde( { || CEFATBVol1() } , "Aguarde..." )
	EndIf
RETURN
/* 
    Chamado na Função acima
*/
Static Function CEFATBVol1()
	Local aArea    		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel('FORMGridM')
	Local nI
	Local aSaveLines 	:= FWSaveRows()
	
	If !oModelGM:IsEmpty()
		for nI := 1 to oModelGM:GetQtdLine()
			oModelGM:GoLine(nI)
			If oModelGM:GetValue("Z6G_OMAVOL")==0
				oModelGM:LoadValue("Z6G_OMAVOL" , oModelGM:GetValue("Z6G_UNSVEN"))
				oModelGM:LoadValue("Z6G_QTDLIB2", oModelGM:GetValue("Z6G_UNSVEN"))
				oModelGM:LoadValue("Z6G_QTDLIB" , oModelGM:GetValue("Z6G_QTDVEN"))
			EndIf
		NEXT
	
		SZ5->(DbSelectArea('SZ5'))
		SZ5->(DbSetOrder(1))
		SZ5->(DbGoTop())
		SZ6->(DbSelectArea('SZ6'))
		SZ6->(DbSetOrder(1))
		SZ6->(DbGoTop())

		for nI := 1 to oModelGM:GetQtdLine()
			oModelGM:GoLine(nI)

			If SZ6->(DbSeek(xFilial('SZ6')+;
				oModelGM:GetValue("Z5G_NUM")+;
				oModelGM:GetValue("Z6G_ITEM")+;
				oModelGM:GetValue("Z6G_PRODUTO")))

                    RECLOCK('SZ6',.F.)
                        SZ6->Z6_OMAVOL   := oModelGM:GetValue("Z6G_OMAVOL") 
                    SZ6->(MSUNLOCK())
                SZ6->(DBSKIP())
			EndIf
		NEXT 
	EndIf
	FWRestRows( aSaveLines )
	RestArea(aArea)
RETURN
/* Gerar Peguntas SX1
*/
Static Function GeraX1(cPerg)
	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local nPergs	:= 0
	Local i := 0, j := 0

	//Conta quantas perguntas existem ualmente.
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg
			nPergs++
			SX1->(DbSkip())
		EndDo
	EndIf

	aAdd(aRegs,{cPerg, "01", "N.F. de:		", "", "", "MV_CH1" , TamSX3("Z5_NOTA")[3]	, TamSX3("Z5_NOTA")[1]	, TamSX3("Z5_NOTA")[2]	, 0, "G",  "", "MV_PAR01", ""										, "","",""			,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "02", "N.F. ate:		", "", "", "MV_CH2" , TamSX3("Z5_NOTA")[3]	, TamSX3("Z5_NOTA")[1]	, TamSX3("Z5_NOTA")[2]	, 0, "G",  "", "MV_PAR02", ""										, "","","ZZZZZZZZZ"	,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "03", "Serie de:		", "", "", "MV_CH3" , TamSX3("Z5_SERIE")[3]	, TamSX3("Z5_SERIE")[1]	, TamSX3("Z5_SERIE")[2]	, 0, "G",  "", "MV_PAR03", "'1'"									, "","","'1'"		,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "04", "Serie ate:	", "", "", "MV_CH4" , TamSX3("Z5_SERIE")[3]	, TamSX3("Z5_SERIE")[1]	, TamSX3("Z5_SERIE")[2]	, 0, "G",  "", "MV_PAR04", ""										, "","","ZZ"		,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "05", "Cliente de:	", "", "", "MV_CH5" , TamSX3("A1_COD")[3] 	, TamSX3("A1_COD")[1] 	, TamSX3("A1_COD")[2]	, 0, "G",  "", "MV_PAR05", ""										, "","",""			,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","","SA1"	,"","","","",""})
	aAdd(aRegs,{cPerg, "06", "Cliente ate:	", "", "", "MV_CH6" , TamSX3("A1_COD")[3] 	, TamSX3("A1_COD")[1] 	, TamSX3("A1_COD")[2]	, 0, "G",  "", "MV_PAR06", ""										, "","","ZZZZZZ"	,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "07", "Pedido de:	", "", "", "MV_CH7" , "C"					, 6						, 0						, 0, "G",  "", "MV_PAR07", ""										, "","",""			,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "08", "Pedido ate:	", "", "", "MV_CH8" , "C"					, 6						, 0						, 0, "G",  "", "MV_PAR08", ""										, "","","ZZZZZZ"	,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "09", "Produto de:	", "", "", "MV_CH9" , TamSX3("B1_COD")[3] 	, TamSX3("B1_COD")[1] 	, TamSX3("B1_COD")[2]	, 0, "G",  "", "MV_PAR09", ""										, "","",""			,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "10", "Produto ate:	", "", "", "MV_CH10", TamSX3("B1_COD")[3] 	, TamSX3("B1_COD")[1] 	, TamSX3("B1_COD")[2]	, 0, "G",  "", "MV_PAR10", ""										, "","","ZZZZZZ"	,"",""											,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "11", "Ordem:		", "", "", "MV_CH11", "C"					, 1						, 0						, 0, "C",  "", "MV_PAR11", "1 - Zona crescente Roteiro Crescente"  	, "","","1"			,"","2 - Zona Crescente Roteiro Decrescente"   	,"","","","","3 - Codigo de Produto","","","","","4 - Cidade"	,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "12", "Tipo:			", "", "", "MV_CH12", "C"					, 1						, 0						, 0, "C",  "", "MV_PAR12", "1 - Impressora Zebra"					, "","","3"			,"","2 - Jato de Tinta"   						,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})
	aAdd(aRegs,{cPerg, "13", "Entrega:		", "", "", "MV_CH13", "D"					, 8						, 0						, 0, "G",  "", "MV_PAR13", 											, "","",""			,"" ,""   										,"","","","",""						,"","","","",""				,"","","","","","","","",""		,"","","","",""})

	//Se quantidade de perguntas for diferente, apago todas
	SX1->(DbGoTop())
	If nPergs <> Len(aRegs)
		For nX:=1 To nPergs
			If SX1->(DbSeek(cPerg))		
				If RecLock('SX1',.F.)
					SX1->(DbDelete())
					SX1->(MsUnlock())
				EndIf
			EndIf
		Next nX
	EndIf

	// Gravação das perguntas na tabela SX1
	If nPergs <> Len(aRegs)
		DbSelectArea("SX1")
		DbSetOrder(1)
		For i := 1 to Len(aRegs)
			If !DbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
					For j := 1 to FCount()
						If j <= Len(aRegs[i])
							FieldPut(j,aRegs[i,j])
						EndIf
					Next j
				MsUnlock()
			EndIf
		Next i
	EndIf

	RestArea(_aArea)
RETURN

Static Function fPrintX1(cPerg)
    Local lRet := .F.
	If Pergunte(cPerg, .T.)
        U_PrintSX1(cPerg)
		   If Len(Directory(cArquivo + "*.*","D")) == 0
				If Makedir(cArquivo) == 0 
					ConOut('Diretório criado com sucesso.')
					MsgAlert('Diretório criado com sucesso: ', + cArquivo, 'Aviso')
				ELSE
					ConOut("Não foi possivel criar o Diretório. Erro: " + CValToChar(FError()))
					MsgAlert('Não foi possível criar o Diretório. Erro', CValToChar(FError()), 'Aviso')
				EndIf
        	EndIf
		lRet := .T.
	EndIf
RETURN lRet

User Function PrintSX1(cPerg)
	Local cPrint := ""
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg
			
			cPrint += IIf(Empty(cPrint),"",CRLF) + ;
					PadR(AllTrim(SX1->X1_PERGUNT), 30, "_") + ;
					": " + ;
					cValToChar(&(SX1->X1_VAR01))
			
			SX1->(DbSkip())
		EndDo
	EndIf
	MemoWrite(StrTran(cArquivo,".xml","")+"_Parametros.txt" , cPrint)
Return nil 
/* 
    Gerar Etiquetas
    Chamada no botão Etiquetas
*/
Static Function CEFATBE()
	Local aArea    		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oModelCab 	:= oModel:GetModel('FORMCabec')
	Local _cAlias 		:= GetNextAlias()
	Local _cQry			:= ''
	Local cLRotEnt	 	:= ""
	Local cMunicipio	:= CriaVar("A1_MUN",.F.)
	Local nI 			
	Local lRet			:= .T.
	Local aSaveLines 	:= FWSaveRows()


	if !Empty(oModelCab:GetValue("CBC_CTPAD"))
		lPerg := fPrintX1(cPerg)
		If lPerg
		
			U_PrintSX1(cPerg) 
			
			If Len( Directory(cPath + "*.*","D") ) == 0
				If Makedir(cPath) == 0
					ConOut('Diretorio Criado com Sucesso.')
				Else
					ConOut( "Não foi possivel criar o Diretório. Erro: " + cValToChar( FError() ) )
				EndIf
			EndIf sss
			
			nHandle := FCreate(cArquivo)
			If nHandle != -1
				conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			else 
				_cQry := " SELECT  Z6_ITEM " + CRLF
				_cQry += " 		,Z5_NUM " + CRLF
				_cQry += " 		,SUBSTRING(Z5_NUM,LEN(Z5_NUM) - 5,6) as PEDIDO " + CRLF
				_cQry += " 		,Z5_VVISTA " + CRLF
				_cQry += " 		,Z5_CLIENT " + CRLF
				_cQry += " 		,Z5_LOJACLI " + CRLF
				_cQry += " 		,A1_NREDUZ " + CRLF
				_cQry += " 		,A1_GRPVEN " + CRLF
				_cQry += " 		,A1_ROTENTR " + CRLF
				_cQry += " 		,Z5_TRANSP " + CRLF
				_cQry += "      ,Z5_TRANSP2 " + CRLF
				_cQry += " 		,Z5_TRANSP3 " + CRLF
				_cQry += " 		,Z5_VEICULO " + CRLF
				_cQry += " 		,Z5_VEIC2 " + CRLF
				_cQry += " 		,Z5_NOTA " + CRLF
				_cQry += " 		,Z5_SERIE " + CRLF
				_cQry += "      ,Z6_PRODUTO " + CRLF
				_cQry += " 		,Z6_UNSVEN " + CRLF
				_cQry += " 		,Z6_QTDVEN " + CRLF
				_cQry += " 		,Z6_UM " + CRLF
				_cQry += " 		,Z6_QTDLIB2 " + CRLF
				_cQry += " 		,Z6_QTDLIB " + CRLF
				_cQry += " 		,Z6_OMAVOL " + CRLF
				_cQry += " 		,Z6_OK " + CRLF
				_cQry += " 		,Z6_ITEM " + CRLF
				_cQry += " 		,Z5_CIDADE " + CRLF
				_cQry += " 		,Z5_END " + CRLF
				_cQry += " 		,A4_NOME " + CRLF
				_cQry += " FROM "+RetSqlName('SZ6')+" Z6 " + CRLF
				_cQry += "  LEFT JOIN "+RetSqlName('SZ5')+" Z5 ON Z5_FILIAL = Z6_FILIAL " + CRLF
				_cQry += "  	  AND Z6.Z6_NUM = Z5.Z5_NUM 		 " + CRLF
				_cQry += " 	  AND Z5_TRANSP = '"+oModelCab:GetValue("CBC_CTPAD")+"' " + CRLF
				If !Empty(MV_PAR07)
					_cQry += "   AND SUBSTRING(Z5_NUM,LEN(Z5_NUM) - 5,6) >='"+MV_PAR07+"'  AND SUBSTRING(Z5_NUM,LEN(Z5_NUM) - 5,6) <='"+MV_PAR08+"'  " + CRLF
				ENDIF 
				IF !Empty(MV_PAR01)
					_cQry += "   AND Z5_NOTA    >='"+StrZero(Val(MV_PAR01),TamSX3('Z5_NOTA')[1])+"'   AND  Z5_NOTA    <= '"+StrZero(Val(MV_PAR02),TamSX3('Z5_NOTA')[1])+"'  " + CRLF
					_cQry += "   AND Z5_SERIE   >='"+MV_PAR03+"'  AND  Z5_SERIE   <= '"+MV_PAR04 +"'  " + CRLF
				ENDIF
				If !Empty(MV_PAR05)
					_cQry += "   AND Z5_CLIENTE >='"+StrZero(Val(MV_PAR05),Val(TamSX3('Z5_CLIENTE')[1]))+"' AND  Z5_CLIENTE <= '"+StrZero(Val(MV_PAR06),TamSX3('Z5_CLIENTE')[1])+"' " + CRLF
				ENDIF
				_cQry += " 	  AND Z5.D_E_L_E_T_ = '' " + CRLF
				_cQry += "  LEFT JOIN "+RetSqlName('SA1')+" A1 ON A1_COD = Z5_CLIENTE  " + CRLF
				_cQry += " 		AND A1_LOJA = Z5_LOJACLI  " + CRLF
				_cQry += " 		AND A1.D_E_L_E_T_ = ''  " + CRLF
				_cQry += "  JOIN "+RetSqlName('SA4')+" A4  " + CRLF
				_cQry += "     ON A4_COD = Z5_TRANSP  " + CRLF
				_cQry += " 	 AND A4.D_E_L_E_T_ = ''  " + CRLF
				_cQry += " WHERE Z6_STATUS IN ('1')   " + CRLF
				If !Empty(MV_PAR13)
					_cQry += "   AND Z6_ENTREG ='"+DTOS(MV_PAR13)+"' "  + CRLF
				ENDIF
				_cQry += "    AND Z6_PRODUTO >='"+MV_PAR09+"'   AND  Z6_PRODUTO <= '"+MV_PAR10  +"'  "+ CRLF
				_cQry += "    AND Z6.D_E_L_E_T_ = '' " + CRLF

				If lower(cUserName) $ 'bernardo'
					MemoWrite(StrTran(cArquivo,".xml","")+"_LancamentoDespacho_.sql" , _cQry)
				EndIf
				
				dbUseArea( .T., "TOPCONN", TcGenQry( ,,_cQry), _cAlias, .F., .T. )

				while !(_cAlias) -> (EOF())
					cLRotEnt := ""
					DbSelectArea("SA1")
					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial('SA1')+(_cAlias)->Z5_CLIENTE+(_cAlias)->Z5_LOJACLI))
					cMunicipio := AllTrim(SA1->A1_MUN) + "/" + AllTrim(SA1->A1_EST)

					If !Empty(SA1->A1_SEQVIS2)
						cLRotEnt += 'B'
					EndIf

					If !Empty(SA1->A1_SEQVIS3)
						cLRotEnt += 'C'
					EndIf

					If !Empty(SA1->A1_SEQVIS4)
						cLRotEnt += 'D'
					EndIf

					If !Empty(SA1->A1_SEQVIS5)
						cLRotEnt += 'E'
					EndIf

					If !Empty(SA1->A1_SEQVIS6)
						cLRotEnt += 'F'
					EndIf

					for nI := 1 to (_cAlias)->Z6_OMAVOL
						cROTENT := StrZero((_cAlias)->A1_ROTENTR,5)
						cROTENT := SubStr(cROTENT,1,3)+'/'+SubStr(cROTENT,4,2)

						aAdd(aEtq, { (_cAlias)->Z5_NOTA+" "+(_cAlias)->Z5_SERIE,;
									(_cAlias)->A1_GRPVEN,;
									cROTENT,;
									AllTrim(SubStr((_cAlias)->Z5_NUM,4,14)),;
									AllTrim(UPPER(oModelCab:GetValue("CBC_PLACAE"))),;
									AllTrim(cMUNICIPIO) + " Entrega: " + cLRotEnt,;
									.F.,;
									(_cAlias)->Z5_EMPRESA,;
									(_cAlias)->Z5_NUM,;
									(_cAlias)->Z5_CLIENTE + "/" + (_cAlias)->Z5_LOJACLI,;
									AllTrim(Posicione("SA1",1,xFilial("SA1") + (_cAlias)->Z5_CLIENTE + (_cAlias)->Z5_LOJACLI, "A1_NOME"))})

						nPosPed    := aScan(aPED,{|x| x[1]==AllTrim(SubStr((_cAlias)->Z5_NUM,4,14))})

						If nPosPed == 0
							aAdd(aPED,{AllTrim(SubStr((_cAlias)->Z5_NUM,4,14)),1,0})
						Else
							aPed[nPosPed][2] := aPed[nPosPed][2] + 1
						EndIf
					NEXT
					(_cAlias)->(DBSkip())
				ENDDO
				(_cAlias)->(DBCloseArea())
				if Len(aEtq) > 0 
					If MV_PAR12==1
						MsAguarde({||CEFATBE2(), "Gerando Etiqueta..."})
					else
						MsAguarde({||CEFATBE1(), "Gerando Etiqueta..."})
					EndIf
					lRet:=.t.
				else 
					MsgAlert("Não há dados com os parametros informados", "Arte[")
					lRet := .F.
				ENDIF
			EndIf
		EndIf
	else
		MsgAlert("Informe o código da Transportadora", "Atenção")
		lRet := .F.
	ENDIF
	FWRestRows( aSaveLines )
	RestArea(aArea)
return lRet
/* 
    impressão das Etiquetas
    Chamada na Função CEFATBE
*/
Static Function CEFATBE2()
	LOCAL nX   	 	:= 1
	LOCAL cPorta 	:= 'LPT1'
	Local cNoReSNF  := AllTrim(SuperGetMv("OM_NORESNF",,"R"))

	FOR nX := 1 TO LEN(aEtq)

		nPosPed := aScan(aPED,{|x| x[1]==aEtq[nX][04]})

		If nPosPed > 0
			aPed[nPosPed][3] := aPed[nPosPed][3] + 1
			cEtiq := AllTrim(Str(aPed[nPosPed][3]))+ '/' + AllTrim(Str(aPed[nPosPed][2]))
		Else
			cEtiq := ''
		EndIf

		MSCBPRINTER("ZEBRA",cPorta,20,300,.F.,,,,,,.T.) // SETA IMPRESSORA ZEBRA ZPL
		MSCBBEGIN(1,6)
		MSCBBOX(1,1,31,20,04,"B")
		If AllTrim(aEtq[nX][08]) $ cNoReSNF .Or. Empty(aEtq[nX][01]) //Nota Fiscal Nao reservada imprime pedido.
			MSCBSAY(02,03 ,aEtq[nX][09]                                         ,"N","0","55,55")
			MSCBSAY(02,07 ,"Rot. "+AllTrim(aEtq[nX][02]) + " - " + aEtq[nX][03] ,"N","0","55,55")
			MSCBSAY(02,11 ,aEtq[nX][10] + ": " + SubStr(aEtq[nX][11],1, 20) 	,"N","H","015")
			MSCBSAY(02,13 ,"Placa: "+ aEtq[nX][05]					            ,"N","H","015")
			MSCBSAY(02,15 ,aEtq[nX][06]                                         ,"N","H","015")
			MSCBSAY(02,17 ,cEtiq                                        	 	,"N","H","018")
		Else
			MSCBSAY(02,02 ,aEtq[nX][01]                                         ,"N","G","015")
			MSCBSAY(02,05 ,aEtq[nX][10] + " - " + SubStr(aEtq[nX][11],1, 20)    ,"N","H","015")
			MSCBSAY(02,08 ,"Rot. "+aEtq[nX][02]+" - "+aEtq[nX][03]              ,"N","H","015")
			MSCBSAY(02,11 ,"Ped. "+aEtq[nX][04] +" "+ aEtq[nX][05]              ,"N","H","015")
			MSCBSAY(02,14 ,aEtq[nX][06]                                         ,"N","H","015")
			MSCBSAY(02,17 ,cEtiq                                 				,"N","H","018")
		EndIf
		MSCBEND()
		MSCBCLOSEPRINTER()
	NEXT nX
RETURN
/* 
    impressão das Etiquetas
    Chamada na Função CEFATBE
*/
Static Function CEFATBE1()
	cString  :="SA1"
	cDesc1   := OemToAnsi("Impressao das etiquetas para caixas dos")
	cDesc2   := OemToAnsi("produtos enviados via transportadora.")
	cDesc3   := ""
	tamanho  :="G"
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog :=""
	aLinha   := { }
	nLastKey := 0
	lEnd     := .f.
	titulo   :=""
	cabec1   :=""
	cabec2   :=""
	cCancel  := "***** CANCELADO PELO OPERADOR *****"
	m_pag    := 1  //Variavel que acumula numero da pagina
	wnrel    :="ETQTRANS"            //Nome Default do relatorio em Disco
	SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If nLastKey == 27
		//	Set Filter To
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		//	Set Filter To
		Return
	EndIf

	RptStatus({|| (RptDetail()) })
RETURN
/* 
    impressão das Etiquetas
    Chamada na Função CEFATBE1
*/
Static Function RptDetail()
	*----------------------------------------------------------------------------*
	LOCAL nLIN	:= 3
	LOCAL nX	:= 1

	SetRegua(LEN(aEtq)) //Ajusta numero de elementos da regua de relatorios

//Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
//1			2			3			4		5		6			7
//F2_DOC+" "+F2_SERIE, A1_GRPVEN, A1_ROTENTR, C5_NUM, C5_VEICULO, A1_MUN, C5_VOLUME1,.F.


/*************************************************************************************/
/*	O "FOR" ABAIXO IMPRIME AS ETIQUETAS DA MANEIRA CORRETA		4 32 60					*/
/*	VERIFIQUE A POSICAO DAS COLUNAS ANTES DE IMPRIMIR			5 35 66				 */
/*************************************************************************************/
	ncont :=0
	FOR nX := 1 TO LEN(aEtq)
		ncont :=ncont+1

		nPosPed    := aScan(aPED,{|x| x[1]==aEtq[nX][04]})

		If nPosPed > 0
			aPed[nPosPed][3] := aPed[nPosPed][3] + 1
			cEtiq := AllTrim(Str(aPed[nPosPed][3]))+ '/' + AllTrim(Str(aPed[nPosPed][2]))
		Else
			cEtiq := ''
		EndIf
		@ nLIN,4  PSAY cEtiq

		nLIN++
		@ nLIN,4  PSAY aEtq[nX][01]

		If nX+1 <= LEN(aEtq)
			@ nLIN,32 PSAY aEtq[nX+1][01]
		EndIf
		If nX+2 <= LEN(aEtq)
			@ nLIN,60 PSAY aEtq[nX+2][01]
		EndIf

		nLIN := nLIN + 1

		@ nLIN,4 PSAY aEtq[nX][02]+" - "+aEtq[nX][03]
		If nX+1 <= LEN(aEtq)
			@ nLIN,32 PSAY aEtq[nX+1][02]+" - "+aEtq[nX+1][03]
		EndIf
		If nX+2 <= LEN(aEtq)
			@ nLIN,60 PSAY aEtq[nX+2][02]+" - "+aEtq[nX+2][03]
		EndIf

		nLIN := nLIN + 1

		@ nLIN,4 PSAY aEtq[nX][04] +" "+ aEtq[nX][05]
		If nX+1 <= LEN(aEtq)
			@ nLIN,32 PSAY aEtq[nX+1][04] +" "+ aEtq[nX+1][05]
		EndIf
		If nX+2 <= LEN(aEtq)
			@ nLIN,60 PSAY aEtq[nX+2][04] +" "+ aEtq[nX+2][05]
		EndIf

		nLIN := nLIN + 1

		@ nLIN,4 PSAY aEtq[nX][06]
		If nX+1 <= LEN(aEtq)
			@ nLIN,32 PSAY aEtq[nX+1][06]
		EndIf
		If nX+2 <= LEN(aEtq)
			@ nLIN,60 PSAY aEtq[nX+2][06]
		EndIf

		DO CASE
		CASE NCONT ==1
			NLIN :=9
		CASE NCONT ==2
			NLIN :=15
		CASE NCONT ==3
			NLIN :=22
		CASE NCONT ==4
			NLIN :=28
		CASE NCONT ==5
			NLIN :=34
		CASE NCONT ==6
			NLIN :=40
		CASE NCONT ==7
			NLIN :=47
		CASE NCONT ==8
			NLIN :=53
		CASE NCONT ==9
			NLIN :=59
		CASE NCONT >=10
			NCONT:=0
			NLIN :=3
		ENDCASE
		nX	 := nX + 2
	NEXT

	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	EndIf

	MS_FLUSH() //Libera fila de relatorios em spool

RETURN
/* 
    Função para Zerar volume apÃ³s impressão das Etiquetas 
    Chamada no botão Zerar_Vol
*/
Static Function CEFATBZ()
	Local aArea    		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel('FORMGridM')
	Local nY
	Local lRet 			:= .T. 
	Local aSaveLines 	:= FWSaveRows()

	if !oModelGM:IsEmpty()
		If MsgYesNo('Zera Coluna de Volume ?', 'Atenção')
			If MsgYesNo('Zera Coluna de Volume ?', 'Atenção')

				For nY := 1 to oModelGM:GetQtdLine()
					oModelGM:GoLine(nY)
					oModelGM:LoadValue("Z6G_OMAVOL" ,0)
				Next
			EndIf
		EndIf

		IF oModelGM:GetQtdLine() >0

		SZ6->(DBSELECTAREA('SZ6'))
		SZ6->(DBSETORDER(1))
		SZ6->(DbGoTop())
			FOR nY := 1 TO oModelGM:GetQtdLine()
				oModelGM:GoLine(nY)
				IF SZ6->(DBSEEK(xFILIAL('SZ6')+;
						oModelGM:GetValue("Z5G_NUM")+;	
						oModelGM:GetValue("Z6G_ITEM")+;
						oModelGM:GetValue("Z6G_PRODUTO"))) 

                            RECLOCK('SZ6',.F.)
                                SZ6->Z6_OMAVOL   := oModelGM:GetValue("Z6G_OMAVOL")
                            SZ6->(MSUNLOCK())
						SZ6->(DBSKIP())
				ELSE
					MSGALERT('MSG 000001A', 'MSG')
				ENDIF
			NEXT
		ENDIF
	else
		oModel:SetErrorMessage("","","","","HELP", 'Grid Vazia!', "Preencha os campos Entrega e Transportadora") 
		lRet := .F.
	ENDIF
	FWRestRows( aSaveLines )
	RestArea(aArea)
RETURN lRet
/* 
    Despachar Pedidos, Chamado no botão Despacho
*/
Static Function CEFATBD()
	Local oModel 		:= FWModelActive()
	Local oModelCab 	:= oModel:GetModel("FORMCabec")
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local nI
	Local aVVCorte 		:= {},  aKitCorte := {}
	Local nTamKit
	Local cMsgCorte 	:= ''
	Local cTtPad, cNtPad

	if !oModelGM:IsEmpty()
		aVVCorte  	:= VldVVista(oModel,oModelGM)
		aKitCorte 	:= VldKit(oModel,oModelGM)
		nTamKit		:= Len( aKitCorte )
		If len(aVVCorte) > 0
			cMsgCorte := 'OS PEDIDOS ABAIXO SÃO DO TIPO VENDA A VISTA E NÃO PODEM SOFRER CORTES:' + CRLF + CRLF
			For nI := 1 To len(aVVCorte)
				cMsgCorte += '- ' + aVVCorte[ nI ] + CRLF
			Next nI
				Aviso('PEDIDOS VENDA Ã€ VISTA', cMsgCorte,{"OK"}, 2)
			Return
		EndIf 

		If nTamKit > 0
			cMsgCorte := 'OS PEDIDOS ABAIXO SÃO DO TIPO KIT E NÃO PODEM SOFRER CORTES:' + CRLF + CRLF
			For nI := 1 To nTamArray
				cMsgCorte += '- ' + aKitCorte[ nI ] + CRLF
			Next nI
			Aviso('PEDIDOS KIT', cMsgCorte,{"OK"}, 2)
			Return
		Endif

		If MSGYESNO('Despachar ?', 'Atenção')
			cTtPad := oModelCab:GetValue("CBC_CTPAD")
			cNtPad := AllTrim(oModelCab:GetValue("CBC_NTPAD"))
			MsAguarde( { || CEFATBD2() } , "Aguarde..." )
			cTipe :='N'
			cTit  :='DESPACHO'
			cMen1 :=''
			cMen2 :=''
			cMen3 :='Despachado Transportadora '+cTtPad+'-'+cNtPad
			cMen4 :=''
			nP1   :=135
			nP2   :=0
			nP3   :=500
			nP4   :=700
			U_CFATALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)
			EndIf
	else
		oModel:SetErrorMessage("","","","","HELP", 'Grid Vazia!', "Preencha os campos Entrega e Transportadora") 
		lRet := .F.
	EndIf
RETURN
/* 
    Salva Dados Antes de despachar 
    Chamada na Função CEFATBD
*/
Static Function CEFATBD2()
	Local aArea 		:= GetArea()
	Local oModel 		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelCab 	:= oModel:GetModel("FORMCabec")
	Local nI
	Local cPed 	  		:= ""

	SZ5->(DbSelectArea('SZ5'))
	SZ5->(DbSetOrder(1))//FILIAL+NUMERO
	SZ5->(DbGoTop())

	SZ6->(DbSelectArea('SZ6'))
	SZ6->(DbSetOrder(1))//FILIAL+NUMERO+ITEM+PRODUTO
	SZ6->(DbGoTop())

	_cHoraFim := Time()
	for nI := 1 to oModelGM:GetQtdLine()
		oModelGM:GoLine(nI)

 		If SZ6->(DbSeek(xFilial('SZ6')+;
				oModelGM:GetValue("Z5G_NUM")+;
				oModelGM:GetValue("Z6G_ITEM")+;
				oModelGM:GetValue("Z6G_PRODUTO")))

					RecLock('SZ6',.F.)
					If oModelGM:GetValue("Z6G_QTDLIB") > 0 
						SZ6->Z6_QTDLIB2 := oModelGM:GetValue("Z6G_QTDLIB2")
					else 
						SZ6->Z6_QTDLIB2 := 0 
					EndIf
					SZ6->Z6_QTDLIB   := oModelGM:GetValue("Z6G_QTDLIB")
					SZ6->Z6_STATUS   := '2'
					SZ6->Z6_OMAVOL   := oModelGM:GetValue("Z6G_OMAVOL")
					SZ6->(MSUNLOCK())
				SZ6->(DBSKIP())
		ELSE
			MsgAlert('MSG 000001', 'MSG')
		EndIf
		
		If SZ5->(DbSeek(xFilial('SZ5')+AllTrim(oModelGM:GetValue("Z5G_NUM"))))
			RECLOCK('SZ5',.F.)
			
			SZ5->Z5_VEICULO  := oModelCab:GetValue("CBC_PLACAP")
			SZ5->Z5_HORAINI  := _cHoraIni
			SZ5->Z5_HORAFIM  := _cHoraFim

			SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
			SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
			SZ5->Z5_VEIC2    := UPPER(oModelCab:GetValue("CBC_PLACAP"))
			SZ5->Z5_VEICULO  := UPPER(oModelCab:GetValue("CBC_PLACAP"))

			If Empty(SZ5->Z5_NOTA)
				SZ5->Z5_NOTA  	:= SubStr(oModelGM:GetValue("Z5G_NOTA"),1,9)
				SZ5->Z5_SERIE  	:= SubStr(oModelGM:GetValue("Z5G_NOTA"),11,1)
			EndIf

			SZ5->(MSUNLOCK())
		ELSE
			MsgAlert('MSG 000002', 'MSG')
		EndIf
		cPed := AllTrim(oModelGM:GetValue("Z5G_NUM"))

		SA4->(DbSelectArea('SA4'))
		SA4->(DbSetOrder(1))
		If SA4->(DbSeek(xFilial('SA4')+oModelCab:GetValue("CBC_CTPAD")))
			RECLOCK('SA4',.F.)
			SA4->A4_LOCAL:='2'
			SA4->(MSUNLOCK())
		EndIf
		U_UPDFGSZ4(cPed)
	Next nI  
	CEFATBL()
	RestArea(aArea)
RETURN
/*
return Array, aRet - Array com os Pedidos de Venda Não OK.
Chamado no CEFATBD DEspacho
/*/
Static Function VldVVista(oModel,oModelGM)
	Local nI
	Local aRet 			:= {}
	Local aVVCorte  	:= {}
	Local nLin
	Local lVVCorte  	:= .F.
	Local lVVDesp   	:= .F.
	Local nPosPV    	:= 0

	nLin := oModelGM:GetQtdLine()

		for nI := 1 to nLin
			oModelGM:GoLine(nI)
			If oModelGM:GetValue("Z6G_VVISTA") == 'S'
				_cPed := AllTrim(oModelGM:GetValue("Z5G_NUM"))
				If ( oModelGM:GetValue("Z6G_OMAVOL") > 0) .And. (oModelGM:GetValue("Z6G_OMAVOL") < oModelGM:GetValue("Z6G_UNSVEN") )
					lVVCorte := .T.
					lVVDesp  := .T.
				elseif ( oModelGM:GetValue("Z6G_OMAVOL") > 0) .And. (oModelGM:GetValue("Z6G_OMAVOL") == oModelGM:GetValue("Z6G_UNSVEN") )
					lVVCorte := .F.
					lVVDesp  := .T.
				elseif oModelGM:GetValue("Z6G_OMAVOL") == 0
					lVVCorte := .T.
					lVVDesp  := .F.
				EndIf
				If ( nPosPV := aScan( aVVCorte, { |x| x[1] == cPedido } ) ) == 0
					aAdd( aVVCorte, { cPedido, lVVDesp, lVVCorte } )
				else 
					If !aVVCorte[ nPosPV, 3] .And. lVVCorte
						aVVCorte[ nPosPV, 3] := .T.
					EndIf
					If !aVVCorte[ nPosPV, 2] .And. lVVDesp
						aVVCorte[ nPosPV, 2] := .T.
					EndIf
				EndIf
			EndIf
		NEXT nI
		For nI := 1 To Len( aVVCorte )
			If aVVCorte[ nI, 2] .And. aVVCorte[ nI, 3]
				aAdd( aRet, aVVCorte[ nI, 1] )
			EndIf
		Next nI
RETURN aRet
/* Validação do Campo Z6G_QTDLIB2 Grid Principal */
User Function VLDLIB2()
	Local aArea			:= GetArea()
	Local aSaveLines 	:= FWSaveRows()
	Local oModel 		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local lRet 			:= .T.
	Local nQtd			:= &(ReadVar())

	if nQtd > oModelGM:GetValue("Z6G_UNSVEN") 
		IF MSGYESNO('Quantidade total maior que quantidade do pedido ' +CRLF+;
				'Qtde Pedido   : ' +LTRIM(TransForm(oModelGM:GetValue("Z6G_UNSVEN")       	, '@E 999,999,999.999'))+CRLF+;
				'Qtde Despacho : ' +LTRIM(TransForm(nQtd 									, '@E 999,999,999.999'))+CRLF+;
				'Diferença    : '  +LTRIM(TransForm(nQtd - oModelGM:GetValue("Z6G_UNSVEN")  , '@E 999,999,999.999'))+CRLF+;
				'Aceita ?' )

			oModelGM:LoadValue("Z6G_QTDLIB2"   , &(ReadVar()))
			U_FATBGRV()
		ENDIF 
	ENDIF 

	FWRestRows( aSaveLines )
	RestArea(aArea)
RETURN lRet 
/* Validação do Campo Z6_QTDLIB Grid Principal*/
User Function VLDLIB() 
	Local aArea 		:= GetArea()
	Local oModel 		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local lRet 			:= .T.
	Local aSaveLines 	:= FWSaveRows()

	SB1->(DbSelectArea('SB1'))
	SB1->(DbSetOrder(1))

	SB1->(DbSeek(xFilial("SB1") + oModelGM:GetValue("Z6G_PRODUTO")))
	
	nPesoMin := SB1->B1_PESOMIN
	nPesoMax := SB1->B1_PESOMAX

	If oModelGM:GetValue("Z6G_QTDLIB") > 0
		If oModelGM:GetValue("Z6G_UNSVEN") > 0 
			If oModelGM:GetValue("Z6G_QTDLIB2") * nPesoMin > oModelGM:GetValue("Z6G_QTDVEN") //oModelGM:GetValue("Z6G_UNSVEN")
				lRet := fDigSenha()
			elseif oModelGM:GetValue("Z6G_QTDLIB2") * nPesoMax < oModelGM:GetValue("Z6G_QTDVEN")
				lRet := fDigSenha()
			EndIf
		elseif oModelGM:GetValue("Z6G_QTDLIB") > oModelGM:GetValue("Z6G_UNSVEN") 
			IF !MSGYESNO('Peso Digitado maior que peso do Pedido continua ? '	+ CRLF +;
				'Peso Pedido  : ' +LTRIM(TransForm(oModelGM:GetValue("Z6G_UNSVEN") ,'@E 999,999,999.999'))  )
				Return(.F.)
			ENDIF
		ENDIF
	EndIf
	If oModelGM:GetValue("Z6G_QTDLIB") > 0
		do case 
			CASE oModelGM:GetValue("Z6G_UNSVEN") != 0
				oModelGM:LoadValue("Z6G_OMAVOL", oModelGM:GetValue("Z6G_QTDLIB2"))
			CASE oModelGM:GetValue("Z6G_UNSVEN") == 0 .And. oModelGM:GetValue("Z6G_QTDLIB2") != 0
				oModelGM:LoadValue("Z6G_OMAVOL", oModelGM:GetValue("Z6G_QTDLIB2"))
			CASE oModelGM:GetValue("Z6G_UNSVEN") == 0 .And. oModelGM:GetValue("Z6G_QTDLIB2") == 0
				oModelGM:LoadValue("Z6G_QTDLIB2", 1)
				oModelGM:LoadValue("Z6G_OMAVOL" , 1)
		ENDCASE
	ELSE
		oModelGM:LoadValue("Z6G_QTDLIB2" , 0)
		oModelGM:LoadValue("Z6G_OMAVOL"  , 0)
	EndIf
	oModelGM:LoadValue("Z6G_QTDLIB"   , &(ReadVar()))
	U_FATBGRV()

	FWRestRows( aSaveLines )
	
	RestArea(aArea)

RETURN lRet
 /* Validação do Campo Z6G_OMAVOL Grid Principal */
User Function VLDVOL1()
	Local aArea		:= GetArea()
	Local oModel 	:= FWModelActive()
	Local oModelGM 	:= oModel:GetModel("FORMGridM")
	Local lRet 		:= .T.

	oModelGM:LoadValue("Z6G_OMAVOL"   , &(ReadVar()))
	U_FATBGRV()
	
	RestArea(aArea)
RETURN lRet 
 /* Validação do Campo Z7G_QTDE Grid do Rodape ABA02 */
User Function VLDQTDL()
	Local oModel 		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelGR 		:= oModel:GetModel("FORMRG2")
	Local lRet 			:= .t. 
	Local aArea 		:= GetArea()

	If !msgyesno('Alterar quantidade do Lote ?', 'Confirma')
		lRet := .F.
	else
		IF oModelGM:SeekLine({{"Z5G_NUM"		, oModelGR:GetValue("Z7G_PED") },;
								{"Z6G_PRODUTO"	, oModelGR:GetValue("Z7G_PRODUTO")},;
								{"Z5G_CLI"		, oModelGR:GetValue("Z7G_CLI")}})

			oModelGR:LoadValue("Z7G_QTDE"   , &(ReadVar()))
			oModelGM:LoadValue("Z6G_QTDLIB2", oModelGR:GetValue("Z7G_QTDE"))
			oModelGM:LoadValue("Z6G_QTDLIB" , oModelGR:GetValue("Z7G_PESO"))
			oModelGM:LoadValue("Z6G_OMAVOL" , oModelGR:GetValue("Z7G_QTDE"))
		ENDIF
		U_FATBGRV()
	ENDIF
	RestArea(aArea)

RETURN lRet
/* 
    Gravação do Formulário completo, Chamado nas Funções: 
        FSZ7LPre
        VLDLIB
        VLDVOL1
*/
USER Function FATBGRV()
	
	Local oModel 		:= FWModelActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelCab 	:= oModel:GetModel("FORMCabec")
	Local oModelGR 		:= oModel:GetModel("FORMRG2")
	Local nI, nJ
	Local nTotLin		:= oModelGM:GetQtdLine()
	Local aSaveLines 	:= FWSaveRows()	
	Local cLoteZ6, cPed, cItem, cCli, cLoj 
	cLoteZ6 := iIf(Empty( AllTrim( oModelGM:GetValue("Z6G_LOTEVIF") ) ), oModelGM:GetValue("Z6G_LOTEVIF"), cLoteVif )
	cPed 	:= oModelGM:GetValue("Z5G_NUM")
	cItem	:= oModelGM:GetValue("Z6G_ITEM")
	cCli 	:= SubStr(oModelGM:GetValue("Z5G_CLI"),1,6)
	cLoj 	:= SubStr(oModelGM:GetValue("Z5G_CLI"),8,2)

	oModelGM:LoadValue("Z6G_LOTEVIF"  , PadR('', TamSX3('Z6_LOTEVIF')[1]))

	If SZ5->(DbSeek(xFilial('SZ5')+oModelGM:GetValue("Z5G_NUM")))
		SZ5->(RECLOCK('SZ5',.F.))
			SZ5->Z5_TRANSP2  := oModelCab:GetValue("CBC_CTPRIM")
			SZ5->Z5_TRANSP3  := oModelCab:GetValue("CBC_CTENTR")
			SZ5->Z5_VEIC2    := UPPER(oModelCab:GetValue("CBC_PLACAE"))
			SZ5->Z5_VEICULO  := UPPER(oModelCab:GetValue("CBC_PLACAP"))
			If Empty(SZ5->Z5_NOTA)
				cNota := REPLACE(oModelGM:GetValue("Z5G_NOTA"), '-', '')
				if cNota != ''
					SZ5->Z5_NOTA  := SubStr(cNota,1,9)
					SZ5->Z5_SERIE := SubStr(cNota,10,3)
				EndIf 
			EndIf
			SZ5->(MSUNLOCK())
	ELSE
		MsgAlert('MSG 000006', 'MSG')
	EndIf

	If nTotLin > 0 .And. !Empty(oModelGM:GetValue("Z5G_NUM"))
		SZ5->(DbSelectArea('SZ5'))
		SZ5->(DbSetOrder(1))//NUMERO
		SZ5->(DbGoTop())

		SZ6->(DbSelectArea('SZ6'))
		SZ6->(DbSetOrder(1))//NUMERO+ITEM+PRODUTO
		SZ6->(DbGoTop())

		for nI := 1 to oModelGM:GetQtdLine()
			oModelGM:GoLine(nI)
			 if SZ6->(DbSeek(xFilial('SZ6')+;
					oModelGM:GetValue("Z5G_NUM")+;
					oModelGM:GetValue("Z6G_ITEM")+;
					oModelGM:GetValue("Z6G_PRODUTO")))

					SZ6->(RECLOCK('SZ6',.F.))
					   	SZ6->Z6_QTDLIB2  := oModelGM:GetValue("Z6G_QTDLIB2") 
						SZ6->Z6_QTDLIB   := oModelGM:GetValue("Z6G_QTDLIB") 
						SZ6->Z6_VALOR    := oModelGM:GetValue("Z6G_QTDLIB") * SZ6->Z6_PRCVEN
					 	SZ6->Z6_OMAVOL   := oModelGM:GetValue("Z6G_OMAVOL")
					If !oModelGM:IsDeleted()
						 SZ6->Z6_OK      := .F.
					ELSE
						 SZ6->Z6_OK      :=.T.
					EndIf

					IF !oModelGR:IsEmpty()
						SZ7->(DbSelectArea('SZ7'))
						SZ7->(DbSetOrder(1))

						for nJ := 1 to oModelGR:GetQtdLine()
							oModelGR:GoLine(nJ)

							cCodBar	:= oModelGR:GetValue("Z7G_CODBAR")
							cLote 	:= oModelGR:GetValue("Z7G_LOTE")
							cProd   := oModelGR:GetValue("Z7G_PRODUTO")
							cPed    := oModelGR:GetValue("Z7G_PED")
							cCli    := SubStr(oModelGR:GetValue("Z7G_CLI"),1,6)
							cLoj    := SubStr(oModelGR:GetValue("Z7G_CLI"),8,2)
							cItem   := oModelGR:GetValue("Z7G_ITEM")
							cSeq    := oModelGR:GetValue("Z7G_NSEQ")
							nPeso   := oModelGR:GetValue("Z7G_PESO")
							nQtde   := oModelGR:GetValue("Z7G_QTDE")
							dData   := If(Len(AllTrim(oModelGR:GetValue("Z7G_CODBAR"))) >= 31,SubStr(oModelGR:GetValue("Z7G_CODBAR"),28,4)+SubStr(oModelGR:GetValue("Z7G_CODBAR"),26,2) + SubStr(oModelGR:GetValue("Z7G_CODBAR"),24,2),"")

							If SZ7->(DbSeek(xFilial('SZ7')+SubStr(cCodBar,1,50)+SubStr(cProd,1,15)+SubStr(cPED,1,29)+SubStr(cITEM,1,02)+SubStr(cCLI,1,06)+SubStr(cLOJ,1,02)+AllTrim(str(cSEQ))))
								If oModelGR:IsDeleted()
										SZ7->(RECLOCK('SZ7',.F.))
											SZ7->(DbDelete())
										SZ7->(MSUNLOCK())
										GravaZ24(cProd,cCodBar,cLOTE,cPED,nPeso,nQtde,.T.) 
								ELSE
									SZ7->(RECLOCK('SZ7',.F.))
										SZ7->Z7_FILIAL  := xFilial('SZ7')
										SZ7->Z7_CODBAR  := cCodBar
										SZ7->Z7_PRODUTO := cProd
										SZ7->Z7_LOTE    := cLote   
										if Len(dData) > 0
											SZ7->Z7_VALID   := sToD(dData)
										ENDIF
										SZ7->Z7_QTDE    := nQtde
										SZ7->Z7_PESO    := nPeso
										SZ7->Z7_PEDIDO  := cPed 
										SZ7->Z7_ITEM    := cItem
										SZ7->Z7_CLIENTE := cCli
										SZ7->Z7_LOJA    := cLoj
										SZ7->Z7_NSEQ	:= cSeq
										/* SZ7->Z7_PALLET	:= oModelCab:GetValue("CBC_PALLET") */
									SZ7->(MSUNLOCK())
								EndIf
							ELSE 
								SZ7->(RECLOCK('SZ7', .T.))
									SZ7->Z7_FILIAL  := xFilial('SZ7')
									SZ7->Z7_CODBAR  := cLoteZ6
									SZ7->Z7_PRODUTO := cProd
									SZ7->Z7_LOTE    := cLote
									if Len(dData) > 0
										SZ7->Z7_VALID   := sToD(dData)
									ENDIF
									SZ7->Z7_QTDE    := nQtde
									SZ7->Z7_PESO    := nPeso
									SZ7->Z7_PEDIDO  := cPed
									SZ7->Z7_ITEM    := cItem
									SZ7->Z7_CLIENTE := cCli 
									SZ7->Z7_LOJA    := cLoj 
									SZ7->Z7_NSEQ	:= cSeq
								 	/* SZ7->Z7_PALLET	:= oModelCab:GetValue("CBC_PALLET")   */
								SZ7->(MSUNLOCK())
							EndIf
						NEXT nJ
					ENDIF 
					SZ6->(MSUNLOCK())
				SZ6->(DBSKIP())
			EndIf
		NEXT
		SZ6->(DBCloseArea())
		SZ5->(DBCloseArea())
	ELSE
		MsgAlert('MSG 000005', 'MSG')
	EndIf


	for nI := 1 to oModelGM:GetQtdLine()
        cLeg := LOTECLR(oModel,oModelGM)
        oModelGM:GoLine()
	    oModelGM:LoadValue("Z6G_LEGEND",cLeg) 
    NEXT

	FWRestRows( aSaveLines )
RETURN
	*----------------------------------------------------------------------------*
USER FUNCTION VALIDATA(dDATA1B)
	*----------------------------------------------------------------------------*
	LOCAL lRET :=.T.
	LOCAL nDIFDAT := dDATA1B-DATE()
	IF nDIFDAT >=2
		IF MSGYESNO('Data atual '+ALLTRIM(dtoc(date()))+' data digitada '+ALLTRIM(dtoc(dDATA1B))+' entrega futura '+ALLTRIM(str(nDIFDAT))+' dias Confirma ?' ,'Atenção 1/2')
			IF MSGNOYES('Data atual '+ALLTRIM(dtoc(date()))+' data digitada '+ALLTRIM(dtoc(dDATA1B))+' entrega futura '+ALLTRIM(str(nDIFDAT))+' dias Confirma ?' ,'Atenção 2/2')
				lRET :=.T.
			ELSE
				lRET :=.F.
			ENDIF
		ELSE
			lRET :=.F.
		ENDIF
	ENDIF
RETURN lRET
/* Valida Lote Cabeçalho */
User Function VLDLTCB()
	Local oModel 	:= FWModelActive()
	Local oModelGM 	:= oModel:GetModel("FORMGridM")
	Local lRet 		:= .T. 
	Local nLinha	:= oModelGM:GetLine()

	oModelGM:GoLIne(nLinha)
	IF oModelGM:SetValue("Z6G_LOTEVIF", &(ReadVar()))
		if oModelGM:GetValue("Z6G_QTDLIB2") >= oModelGM:GetValue("Z6G_UNSVEN")
			oModelGM:GoLine(nLinha + 1 )
		endif
	ENDIF 

Return lRet

User Function VLDLOTE()
	Local oModel 		:= FWModelActive()
	Local oView 		:= FWViewActive()
	Local oModelGM 		:= oModel:GetModel("FORMGridM")
	Local oModelGR 		:= oModel:GetModel("FORMRG2")
	Local lRet := .T. 

	if !MLOTE2(oModel, oView, oModelGM, oModelGR)
		lRet :=.F. 
	ENDIF

Return lRet

STATIC Function MLOTE2(oModel, oView, oModelGM, oModelGR/* , cLoteVif */)
	*----------------------------------------------------------------------------*
	Local aArea	:= GetArea()
	Local lRet			:= .T.
	Local cTipe, cTit, cMen1, cMen2, cMen3, cMen4
	Local cFornece 	:= SuperGetMV( "MV_YFORSA5", .F., "003811;003811" )
	Local cALias := GetNextAlias()

	cLoteVif 	:= AllTrim(oModelGM:GetValue("Z6G_LOTEVIF"))
	cCodBar  	:= AllTrim(cLoteVif)

	cNcs      	:= SubStr(AllTrim(cLoteVif),11,06)
	nLSeq 		:= nLSeq+1

	If SubStr(AllTrim(cLoteVif),04,01) <> ','
		cTipe :='N'
		cTit  :='Mensagem'
		cMen1 :='Problema na leitura do Codigo de Barra'+cLoteVif+ ' '
		cMen2 :='Selecionar outro código de barra, ou tente novamente.'
		cMen3 :=''
		cMen4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700
		U_CFATALERT(cTipe,cTit,cMen1,cMen2,cMen3,cMen4,nP1,nP2,nP3,nP4)
		nLSeq :=nLSeq-1
		RETURN(.F.)
	ELSE
		SZ7->(DbSelectArea('SZ7'))
		SZ7->(DbSetOrder(1))

		If SZ7->(DbSeek(xFilial('SZ7')+cLoteVif)) .And. !Empty(cLoteVif)
			
			SZ7->(DbCloseArea())
			
			cTipe :='N'
			cTit  :='Mensagem'
			cMen1 :='Codigo de Barra '+cLoteVif+ ' Já despachado '
			cMen2 :='Selecionar outro código de barra '
			cMen3 :=''
			cMen4 :=''
			nP1   :=135
			nP2   :=0
			nP3   :=300
			nP4   :=700
			U_CFATALERT(cTipe,cTit,cMen1,cMen2,cMen3,cMen4,nP1,nP2,nP3,nP4)//lCFATALERT :=.T.
			nLSeq :=nLSeq-1
			RETURN(.F.)
			
		else 
			SZ7->(DbCloseArea())
			//If Len(AllTrim(cLoteVif)) == 26
			If Len(AllTrim(cLoteVif)) == 26
				//  012,0100015961630060574152
				//  012,010 001   596163 0060574 152
				//  peso    peÃ§as nsc    lote    prod
				//	*--------PESO--------------
				cPeso     :=SubStr(AllTrim(cLoteVif),01,03)+'.'+SubStr(AllTrim(cLoteVif),05,03)
				nPeso     :=VAL(SubStr(AllTrim(cPeso),01,07))
				//	*--------PECA--------------
				cPeca     :=SubStr(AllTrim(cLoteVif),08,03)
				nPeca     :=VAL(SubStr(AllTrim(cPeca),01,03))
				//	*----------------------
				cNcs      :=SubStr(AllTrim(cLoteVif),11,06)
				cLote     :=SubStr(AllTrim(cLoteVif),17,07)
				cValidade :=SPACE(10)
				cProduto  :=SubStr(AllTrim(cLoteVif),24,Len(cLoteVif))
				cProduto := AllTrim(cProduto)
			ElseIf Len(AllTrim(cLoteVif)) == 28 .Or. Len(AllTrim(cLoteVif)) == 29 
				//  012,0100015961630060574152
				//  012,010 001   596163 0060574 152
				//  peso    peÃ§as nsc    lote    prod
				*--------PESO--------------
				cPeso     :=SubStr(AllTrim(cLoteVif),01,03)+'.'+SubStr(AllTrim(cLoteVif),05,03)
				nPeso     :=VAL(SubStr(AllTrim(cPeso),01,07))
				*--------PECA--------------
				cPeca     :=SubStr(AllTrim(cLoteVif),08,03)
				nPeca     :=VAL(SubStr(AllTrim(cPeca),01,03))
				*----------------------
				cNcs      :=SubStr(AllTrim(cLoteVif),11,06)
				cLote     :=SubStr(AllTrim(cLoteVif),17,07)
				cValidade :=SPACE(10)
				cProduto  :=SubStr(AllTrim(cLoteVif),24,Len(cLoteVif))  
				cProduto := AllTrim(cProduto)
			Elseif Len(AllTrim(cLoteVif)) == 36 .AND. At(',', cLoteVif) == 5
				*--------PESO--------------
				cPeso     :=SubStr(AllTrim(cLoteVif),01,04)+'.'+SubStr(AllTrim(cLoteVif),06,03)
				nPeso     :=VAL(SubStr(AllTrim(cPeso),01,08))
				*--------PECA--------------
				cPeca     :=SubStr(AllTrim(cLoteVif),09,02)
				nPeca     :=VAL(SubStr(AllTrim(cPeca),01,03))
				*----------------------
				cNcs      :=SubStr(AllTrim(cLoteVif),11,06)
				cLote     :=SubStr(AllTrim(cLoteVif),17,07)
				//cValidade :=SPACE(10)
				cValidade := SubStr(AllTrim(cLoteVif),24,08)
				cProduto  :=SubStr(AllTrim(cLoteVif),32,Len(cLoteVif))  // TAMANHO 26+ENTER =27
				cProduto := AllTrim(cProduto)
				If len(cProduto) == 0
					cProduto  :=SubStr(AllTrim(cLoteVif),21,Len(cLoteVif))  // TAMANHO 26+ENTER =27
					cProduto := AllTrim(cProduto)
				ElseIF len(cProduto) < 3
					cProduto  :=SubStr(AllTrim(cLoteVif),24,Len(cLoteVif))  // TAMANHO 26+ENTER =27
					cProduto := AllTrim(cProduto)
				EndIf
			Else
				//  012,010001596163006057427052016152
				//  012,010 001   596163 0060574 27052016  152
				//  peso    peÃ§as nsc    lote    validade  prod
				*--------PESO--------------
				cPeso     := SubStr(AllTrim(cLoteVif),01,03)+'.'+SubStr(AllTrim(cLoteVif),05,03)
				nPeso     := VAL(SubStr(AllTrim(cPeso),01,07))
				*--------PECA--------------
				cPeca     := SubStr(AllTrim(cLoteVif),08,03)
				nPeca     := VAL(SubStr(AllTrim(cPeca),01,03))
				*----------------------
				cNcs      := SubStr(AllTrim(cLoteVif),11,06)
				cLote     := SubStr(AllTrim(cLoteVif),17,07)
				cValidade := SubStr(AllTrim(cLoteVif),24,08)
				cProduto  :=SubStr(AllTrim(cLoteVif),32,Len(cLoteVif))  // TAMANHO 26+ENTER =27
				cProduto := AllTrim(cProduto)
				If len(cProduto) == 0
					cProduto  :=SubStr(AllTrim(cLoteVif),21,Len(cLoteVif))  // TAMANHO 26+ENTER =27
					cProduto := AllTrim(cProduto)
				ElseIF len(cProduto) < 3
					cProduto  :=SubStr(AllTrim(cLoteVif),24,Len(cLoteVif))  // TAMANHO 26+ENTER =27
					cProduto := AllTrim(cProduto)
				EndIf
			EndIf

			IF nPeca <=0   
				cTIPE :='N'
				cTIT  :='Mensagem'
				cMEN1 :='Erro no codigo de barra, Quantidade '+cPeca+ ' PCs '
				cMEN2 :='Verique a etiqueta e faça a leitura novamente.   '
				cMEN3 :=''
				cMEN4 :=''
				nP1   :=135
				nP2   :=0
				nP3   :=300
				nP4   :=700

				U_CFATALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.
				nLSeq :=nLSeq-1
				RETURN(.F.)
			else
				nQtdp 	:= oModelGM:GetValue("Z6G_UNSVEN")
				nPesoP 	:= oModelGM:GetValue("Z6G_QTDVEN")
				nQtdD 	:= oModelGM:GetValue("Z6G_QTDLIB2")
				nPesoD 	:= oModelGM:GetValue("Z6G_QTDLIB")

				nSALDO := nQtdp - nQtdD

				// DbSelectArea('SZD')
				//SZD->(DbSetOrder(1))//NUMERO
				//SZD->(DBSeek(xFilial("SZD") + oModelGM:GetValue("Z6G_LOTEVIF") + oModelGM:GetValue("Z6G_PRODUTO")))
/* 				BeginSQL alias "qTMP"
					%noParser%
					SELECT ZD_PRODUTO
					FROM  %table:SZD%
					WHERE ZD_FILIAL = %exp:xFilial('SZD')% 
					AND ZD_CODBAR	= %exp:oModelGM:GetValue("Z6G_LOTEVIF")%
					AND ZD_PRODUTO  = %exp:oModelGM:GetValue("Z6G_PRODUTO")%
					AND %notDel%
				EndSQL

				If !qTMP->(Eof())
					cProduto := qTMP->ZD_PRODUTO
				EndIf

				qTMP->(DBCLOSEAREA()) */

					cQry:= " SELECT * FROM "+RetSqlName("SA5")+" A5 "
					//cQry+= " WHERE A5_FILIAL = '"+xFilial("SA5")+"' AND A5_CODPRF LIKE '%"+cProduto+"'"
					//cQry+= " WHERE A5_FILIAL = '"+xFilial("SA5")+"' AND A5_CODPRF = '"+cProduto+"'"
					cQry+= " WHERE A5_FILIAL = '  ' AND CAST (CAST (A5_CODPRF AS int) AS varchar) = '"+cProduto+"'"
					cQry+= " AND A5_FORNECE IN " + FormatIn(cFornece,";")
					cQry+= " AND D_E_L_E_T_ = ' ' "

					If SELECT(cAlias)>0
						dbSelectArea(cAlias)
						dbCloseArea()
					EndIf

					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )

					If !(cAlias)->(Eof())

						cProduto := AllTrim((cAlias)->A5_PRODUTO)

					EndIf

				If AllTrim(oModelGM:GetValue("Z6G_PRODUTO")) <> AllTrim(cProduto)
					cTipe :='N'
					cTit  :='Mensagem'
					cMen1 :='Produto diferente do Pedido'
					cMen2 :=''
					cMen3 :=''
					cMen4 :=''
					nP1   :=135
					nP2   :=0
					nP3   :=300
					nP4   :=700
					U_CFATALERT(cTipe,cTit,cMen1,cMen2,cMen3,cMen4,nP1,nP2,nP3,nP4)//lCFATALERT :=.T.
					nLSeq :=nLSeq-1
					RETURN(.F.)
				else
					SB1->(DbSelectArea('SB1'))
					SB1->(DbSetOrder(1))

					If SB1->(DbSeek(xFilial('SB1')+cProduto))
						nPsMin  := (SB1->B1_PESOMIN)* nPeca
						nPsMax  := (SB1->B1_PESOMAX)* nPeca

						cTpDesp := SB1->B1_TPDESP
						cDescp  := SB1->B1_DESC
					ELSE
						nQE     := 1
						nPsMin  := 0
						nPsMax  := 0
						cTpDesp := Space(15)
						cDescp  := Space(15)
					EndIf
					SB1->(DBCloseArea())
					nQE :=nPeca

				//1a Chamada
					If nPeso < nPsMin
						cTipe :='N'
						cTit  :='Mensagem 1/2'
						cMen1 :='Peso minimo do cadastro '+lTrim(TransForm(nPsMin, '@E 999,999,999.999')) + ' '
						cMen2 :='Peso da Etiqueta        '+lTrim(TransForm(nPeso , '@E 999,999,999.999')) +' Confirma  ?'
						cMen3 :='Quantidade '+lTrim(TransForm(nQE , '@E 999,999,999.999')) +' Pcs por Embalagem '
						cMen4 :='DIFERENÇA    '+lTrim(TransForm(nPeso-nPsMin, '@E 999,999,999.999')) + ' Kg'
						nP1   :=135
						nP2   :=0
						nP3   :=400
						nP4   :=600
						U_CFATALERT(cTipe,cTit,cMen1,cMen2,cMen3,cMen4,nP1,nP2,nP3,nP4)//lCFATALERT :=.T.

						If lCFATALERT ==.F.
							nLSeq :=nLSeq-1
							Return(.F.)
						EndIf
					elseIf nPeso < nPsMin
						cTipe :='N'
						cTit  :='Mensagem 2/2'
						cMen1 :='Peso minimo do cadastro '+lTrim(TransForm(nPsMin, '@E 999,999,999.999')) + ' '
						cMen2 :='Peso da Etiqueta        '+lTrim(TransForm(nPeso , '@E 999,999,999.999')) +' Confirma  ?'
						cMen3 :='Quantidade '+lTrim(TransForm(nQE , '@E 999,999,999.999')) +' Pcs por Embalagem '
						cMen4 :='DIFERENÇA    '+lTrim(TransForm(nPeso-nPsMin, '@E 999,999,999.999')) + ' Kg'
						nP1   :=135
						nP2   :=0
						nP3   :=400
						nP4   :=600
						U_CFATALERT(cTipe,cTit,cMen1,cMen2,cMen3,cMen4,nP1,nP2,nP3,nP4)//lCFATALERT :=.T.
						If lCFATALERT == .F.
							nLSeq :=nLSeq-1
						    Return(.F.)
						EndIf 
					elseIf nPeso > nPsMax
						cTipe :='N'
						cTit  :='Mensagem 1/2'
						cMen1 :='Peso Maximo do cadastro '+lTrim(TransForm(nPsMax, '@E 999,999,999.999')) + ' '
						cMen2 :='Peso da Etiqueta        '+lTrim(TransForm(nPeso , '@E 999,999,999.999')) +' Confirma  ?'
						cMen3 :='Quantidade '+lTrim(TransForm(nQE , '@E 999,999,999.999')) +' Pcs por Embalagem '
						cMen4 :='DIFERENÇA    '+lTrim(TransForm(nPeso-nPsMax, '@E 999,999,999.999')) + ' Kg'
						nP1   :=135
						nP2   :=0
						nP3   :=400
						nP4   :=600
						U_CFATALERT(cTipe,cTit,cMen1,cMen2,cMen3,cMen4,nP1,nP2,nP3,nP4)//lCFATALERT :=.T.
 						If lCFATALERT ==.F.
							nLSeq :=nLSeq-1
							Return(.F.) 
					 	EndIf  
					elseIf nPeso > nPsMax
						cTipe :='N'
						cTit  :='Mensagem 2/2'
						cMen1 :='Peso Maximo do cadastro '+lTrim(TransForm(nPsMax, '@E 999,999,999.999')) + ' '
						cMen2 :='Peso da Etiqueta        '+lTrim(TransForm(nPeso , '@E 999,999,999.999')) +' Confirma  ?'
						cMen3 :='Quantidade '+lTrim(TransForm(nQE , '@E 999,999,999.999')) +' Pcs por Embalagem '
						cMen4 :='DIFERENÇA    '+lTrim(TransForm(nPeso-nPsMax, '@E 999,999,999.999')) + ' Kg'
						nP1   :=135
						nP2   :=0
						nP3   :=400
						nP4   :=600
						U_CFATALERT(cTipe,cTit,cMen1,cMen2,cMen3,cMen4,nP1,nP2,nP3,nP4)//lCFATALERT :=.T.
			 			If lCFATALERT ==.F.
							nLSeq :=nLSeq-1
							Return(.F.)
				 		EndIf  
					EndIf

					If oModelGM:GetValue("Z6G_OMAVOL") + nPeca > nQtdp
						cTIPE :='N'
						cTIT  :='Mensagem'
						cMEN1 :='Quantidade de volumes maior que a quantidade do Pedido.'
						cMEN2 :='Verique a etiqueta e faça a leitura novamente.'
						cMEN3 :='Qtde do Pedido: ' + cValToChar( nQtdp ) + ' PCS.'
						cMEN4 :='Qtde Bipada: ' + cValToChar( oModelGM:GetValue("Z6G_OMAVOL") + nPECA ) + ' PCS.'
						nP1   :=135
						nP2   :=0
						nP3   :=400
						nP4   :=700

						U_CFATALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.
						
						IF !lCFATALERT
								Return(.F.) 
						Endif
						lPass := fDigSenha()
						If !lPass
							Return(.F.) 
						Endif

					ElseIf oModelGM:GetValue("Z6G_OMAVOL") + nPeca == nQtdp
						SB1->(DbSelectArea('SB1'))
						SB1->(DbSetOrder(1))

						If SB1->(DbSeek(xFilial('SB1')+cProduto))
							nPsMin  := (SB1->B1_PESOMIN)* nQtdp
							nPsMax  := (SB1->B1_PESOMAX)* nQtdp
						ENDIF
						SB1->(DBCloseArea())

						If (nPesoD + nPESO < nPsMin) .OR. (nPesoD + nPESO > nPsMax)
							cTIPE :='N'
							cTIT  :='Mensagem'
							cMEN1 :='Peso despachado (' + cValToChar(nPesoD + nPESO) + ') fora do intervalo permitido.'
							cMEN2 :='Verique a etiqueta e faça a leitura novamente.'
							cMEN3 :='Peso Máximo: ' + cValToChar( nPsMin ) + ' KGs.'
							cMEN4 :='Peso Máximo: ' + cValToChar( nPsMax ) + ' KGs.'
							nP1   :=135
							nP2   :=0
							nP3   :=400
							nP4   :=700

							U_CFATALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

							RETURN(.F.)
						Endif
					Endif
					//Validação NT
					IF SUBSTR(oModelGM:GetValue("Z5G_CLI"),1,6)+SUBSTR(oModelGM:GetValue("Z5G_CLI"),8,2)  == ALLTRIM(cCliCFGru)
						cMEN1 := ValidZ24(cPRODUTO,cNCS,cLOTE,nPESO,nPECA)

						If ALLTRIM(cMEN1) <> ""
							cTIPE :='N'
							cTIT  :='Mensagem 1/1'
							//cMEN1 :=''
							cMEN2 :='Produto: '+ALLTRIM(cPRODUTO)+' '
							cMEN3 :='Linha: '+str(oModelGM:GetLine())+''//Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
							cMEN4 :=''
							nP1   :=135
							nP2   :=0
							nP3   :=400
							nP4   :=600

							U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.
							oModelGM:LoadValue("Z6G_LOTEVIF", PadR('', TamSX3('Z6_LOTEVIF')[1]))
							Return(.F.)
						ENDIF
					ENDIF
					if lRet 
						nQtde     :=0
						nTotlTmp  :=0

						nQtde:= nQE

						If cTpDesp=='2'
							cDescp   := Posicione('SB1',1,xFilial('SB1')+cProduto+Space(12), 'B1_DESC')
							_Produto := cProduto+'-'+cDescp
							_Plote   := nPeso
							_PReal   :=  0
							_Loop    := .T.
							_nOpc1   := 2

							DO WHILE _Loop
								DEFINE MSDIALOG oDlg2 FROM 0,0 TO 200,400 TITLE OemToAnsi("Item a Granel") OF oMainWnd PIXEL

								nLin:=18
								@ nLin,10 SAY OemToAnsi("ITEM A GRANEL") OF oDlg2 PIXEL COLOR CLR_RED  FONT oFontBRW SIZE 120,010
								nLin := nLin+18
								@ nLin,10 SAY OemToAnsi("Produto ")      OF oDlg2 PIXEL SIZE 040,010 FONT oFontBRW3
								@ nLin,50 MSGET _Produto   WHEN(.F.)     OF oDlg2 PIXEL SIZE 130,005 FONT oFontBRW3
								nLin := nLin+12
								@ nLin,10 SAY OemToAnsi("Peso Lote")     OF oDlg2 PIXEL SIZE 040,010 FONT oFontBRW3
								@ nLin,50 MSGET  _Plote    WHEN(.F.)     PICTURE "@E 999,999.999" OF oDlg2 PIXEL SIZE 060,005 FONT oFontBRW3
								nLin := nLin+12
								@ nLin,10 SAY OemToAnsi("PESO REAL")     OF oDlg2 PIXEL SIZE 040,010 COLOR CLR_RED  FONT oFontBRW3
								@ nLin,50 MSGET _PReal     WHEN(.T.)     PICTURE "@E 999,999.999"  OF oDlg2 PIXEL SIZE 060,005 COLOR CLR_RED  FONT oFontBRW3

								DEFINE SBUTTON FROM 080, 010 TYPE 1 ACTION (_nOpc1 := 1,oDlg2:End()) ENABLE OF oDlg2
								ACTIVATE MSDIALOG  oDlg2 ON INIT EnchoiceBar(oDlg2,{||_nOpc1:=1,oDlg2:End() },{||_nOpc1:=2,oDlg2:End() }) CENTERED

								If _nOpc1==1
									If _PReal <=0
										MsgAlert('Peso Real nao pode ser Zero ' +CRLF+;
											'Preencha o Peso Real do produto ')
										_Loop :=.T.
									ELSE
										_Loop :=.F.
										nPeso :=_PReal
									EndIf
								EndIf
								If _nOpc1==2
									_Loop :=.T.
									Return("")
								EndIf
							ENDDO
						EndIf

						nTotL	:= oModelGM:GetValue("Z6G_QTDLIB") + nPeso
						nVolume := oModelGM:GetValue("Z6G_OMAVOL") + nQtde
						
						nQtd2 := oModelGM:GetValue("Z6G_QTDLIB2")+nQtde

						oModelGR:SetNoInsertLine(.F.)
						If !oModelGR:IsEmpty()
							oModelGR:AddLIne()
						ENDIF
						oModelGR:LoadValue("Z7G_PED"		, oModelGM:GetValue("Z5G_NUM"))
						oModelGR:LoadValue("Z7G_CODBAR"		, cCodbar)
						oModelGR:LoadValue("Z7G_PRODUTO"	, cProduto)
						oModelGR:LoadValue("Z7G_LOTE"		, cLote)
						oModelGR:LoadValue("Z7G_VALID"		, IIF(Len(cValidade)>0, cToD(SubS(cValidade,1,2)+'/'+SubS(cValidade,3,2)+'/'+SubS(cValidade,5)),STOD("")))
						oModelGR:LoadValue("Z7G_QTDE"		, nQtde)
						oModelGR:LoadValue("Z7G_PESO"		, nPeso)
						oModelGR:LoadValue("Z7G_NCS"		, cNcs)
						oModelGR:LoadValue("Z7G_NSEQ"		, nLSeq)
						oModelGR:LoadValue("Z7G_CLI"		, oModelGM:GetValue("Z5G_CLI"))
						oModelGR:LoadValue("Z7G_ITEM"		, oModelGM:GetValue("Z6G_ITEM"))
						oModelGR:Goline(1)
						
						oModelGR:SetNoInsertLine(.T.)
						
						oModelGM:LoadValue("Z6G_NCS"      , cNcs)
						oModelGM:LoadValue("Z6G_QTDLIB2"  , nQtd2)
						oModelGM:LoadValue("Z6G_QTDLIB"   , nTotL)
						oModelGM:LoadValue("Z6G_OMAVOL"   , nVolume)
						
						U_FATBGRV()

						GravaZ24(cPRODUTO,cCodBar,cLOTE,oModelGM:GetValue("Z5G_NUM"),nPESO,nPECA,.F.) 
					ENDIF
				ENDIF
			ENDIF
		EndIf
	EndIf
	RestArea(aArea)
Return  lRet 
/* Função para ALerta de Erro
    Chamada na Função MLOTE2
*/
USER Function CFATALERT(eTIPE,eCAB,eMEN1,eMEN2,eMEN3,eMEN4,nP1,nP2,nP3,nP4)
	LOCAL   enOPC1 :=1
	Private oEXP
	Private oFontX1
	Private oFontX2

	DEFINE  FONT oFontX1    NAME "Arial" SIZE 0,-20 BOLD
	DEFINE  FONT oFontX2    NAME "Arial" SIZE 0,-35 BOLD
	DEFINE MSDIALOG oEXP TITLE OemToAnsi(eCAB)  From nP1,nP2 To nP3,nP4 PIXEL

	@ 35,018 Say OEMTOANSI(eMEN1) OF oEXP PIXEL COLOR CLR_BLUE FONT oFontX1
	@ 50,018 Say OEMTOANSI(eMEN2) OF oEXP PIXEL COLOR CLR_BLUE FONT oFontX1
	@ 65,018 Say OEMTOANSI(eMEN3) OF oEXP PIXEL SIZE 280,050 COLOR CLR_RED  FONT oFontX1
	@ 80,018 Say OEMTOANSI(eMEN4) OF oEXP PIXEL SIZE 280,050 COLOR CLR_RED  FONT oFontX2

	DEFINE SBUTTON FROM 500, 500 TYPE 2 ACTION (enOPC1 := 1,oEXP:End()) ENABLE OF oEXP  FONT oFontX1 //COLOR CLR_BLUE

	ACTIVATE MSDIALOG oEXP  ON INIT EnchoiceBar(oEXP ,{||enOPC1:=1, oEXP:End() },{||enOPC1:=2, oEXP:End() }) CENTERED

	If enOPC1==1
		lCFATALERT :=.T.
		RETURN
	EndIf

	If enOPC1==2
		lCFATALERT :=.F.
		RETURN
	EndIf
RETURN
Static Function fDigSenha()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	local  _lReturn := .f.
	Private cSenha   := Space(10)

	DEFINE MsDialog Senhadlg From 067,020 To 169,312 Title OemToAnsi("Liberação de Acesso") Pixel Style DS_MODALFRAME

	Senhadlg:lEscClose     := .T. //.F. //Nao permite sair ao se pressionar a tecla ESC.

	@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
	@ 015,089 Get cSenha Size 50,10 Password
	@ 037,106 BmpButton Type 1 Action fOK(@_lReturn)
	Activate MsDialog Senhadlg CENTERED
Return(_lReturn)

Static Function fOK(_lReturn)
	Private cUSRTRAN := SuperGetMV("OM_USRTRAN",.F.,"OMAMORI")
	Private cUserSys := RetCodUsr()
	Private nOpca    :=0
	Private oDlg
	Private lMsg	 :=.F.

	If Empty(cSenha)
		MsgStop("Senha Não Confere !!!")
		cSenha  := Space(10)
		dlgRefresh(Senhadlg)
		_lReturn  := .F.
	EndIf

	If AllTrim(cSenha) $ cUSRTRAN
		_lReturn  := .T.
		Close(Senhadlg)
	Else
		MsgStop("Senha Não Confere !!!")
		cSenha  := Space(10)
		dlgRefresh(Senhadlg)
		_lReturn  := .F.
	EndIf
Return(_lReturn)
/* Função para Colorir a legenda da GRID 
    Chamadas:   U_CEFATBPG()
                U_FATBGRV()
 */
Static Function LOTECLR(oModel, oModelGM)
	Local cRet        := 'BR_AZUL'//RGB(0,0,0)   //RGB(0,0,255)
	Local nQtdV       := 0
	Local nQtdD       := 0
	Local nPesoD      := 0
	Local lLoteOk     := .F.
	Local cProduto    := ''
	Local aAreaSB1    := {}
	Local nPSMIN      := 0
	Local nPSMAX      := 0 
	Local lKitPrd	  := .F.

	nLinha := oModelGM:GetLine()

	If !oModelGM:IsEmpty()

		aAreaSB1 := SB1->( GetArea() )
		
		cProduto := oModelGM:GetValue("Z6G_PRODUTO")
		
		SB1->( dbSetOrder( 1 ) )
		SB1->( dbSeek( FwxFilial("SB1") + cProduto ) )

		nPSMIN := SB1->B1_PESOMIN
		nPSMAX := SB1->B1_PESOMAX 

		RestArea( aAreaSB1 )

		nQtdV   := oModelGM:GetValue("Z6G_QTDLIB2")
		nQtdD   := oModelGM:GetValue("Z6G_OMAVOL")
		nPesoD  := oModelGM:GetValue("Z6G_QTDLIB")

		If (nQtdD >= nQtdV) .AND. nPesoD >= ( nQtdV * nPSMIN )
			lLoteOk:= .T.
		EndIF

		If !Empty(oModelGM:GetValue("Z6G_XPRDKIT"))
			lKitPrd:= .T.
		EndIf

		If oModelGM:GetValue("Z6G_VVISTA")  != 'S' .and. !lKitPrd
			If nPesoD == 0 .AND. Mod(nLinha,2) == 0 .AND. !oModelGM:IsDeleted()
				cRet := 'BR_BRANCO'//RGB(255,255,255)
			ElseIf nPesoD == 0 .AND. !oModelGM:IsDeleted()
				cRet := 'BR_CINZA'//RGB(178,203,231) 
			Elseif nPesoD > 0 .AND. !lLoteOk
				cRet := 'BR_AZUL'//RGB(0, 0, 255)
			Elseif nPesoD > 0 .AND. lLoteOk
				cRet := 'BR_MARROM'//RGB(128,128,128)
			Endif
		Elseif oModelGM:GetValue("Z6G_VVISTA")  == 'S' .and. !lKitPrd
			If nPesoD == 0 .AND. Mod(nLinha,2) != 0  .AND. !oModelGM:IsDeleted()
				cRet := 'BR_AMARELO'//RGB(247,217,23)
			ElseIf nPesoD == 0 .AND. !oModelGM:IsDeleted()
				cRet := 'BR_MARRON_OCEAN'// RGB(245,240,213) 
			Elseif nPesoD > 0 .AND. !lLoteOk
				cRet := 'BR_AZUL'//RGB(0, 0, 255)
			Elseif nPesoD > 0 .AND. lLoteOk
				cRet := 'BR_MARROM'//RGB(128,128,128)
				Elseif oModelGM:IsDeleted()
				cRet := 'BR_MARROM'//RGB(128,128,128) 
			Endif
		ElseIf oModelGM:GetValue("Z6G_VVISTA") != 'S' .And. lKitPrd
			If Mod(nLinha,2) == 0 .AND. !oModelGM:IsDeleted()
				nRet := 'CLR_MAGENTA'//RGB(214,0,110)
			ElseIf !oModelGM:IsDeleted()
				nRet := 'CLR_HMAGENTA'//RGB(255,0,255)
			Elseif lLoteOk
				nRet := 'CLR_RED'//RGB(242,184,216)
			Elseif oModelGM:IsDeleted()
				nRet := 'CLR_HRED'//RGB(242,184,216)
			Endif
		Endif
	EndIf
Return cRet

/*/{Protheus.doc} VldKit
Valida Pedidos do Tipo Venda KIT
@type function
@version 12.1.25
@author Leonardo Robes
@since 20/05/2021
@return Array, aRet - Array com os Pedidos de Venda Não OK.
/*/
Static Function VldKit(oModel, oModelGM)

	Local aRet      := {}
	Local aKitCorte := {}
	Local nI        := 0
	Local nPosPV    := 0
	Local cPedido   := ''
	Local lKitCorte := .F.
	Local lKitDesp  := .F.

	/* nTamArray := Len( oGetDados:aCols ) */
	If !oModelGM:IsEmpty()
		For nI := 1 To oModelGM:GetQtdLine()
			If !Empty(oModelGM:GetValue("Z6G_XPRDKIT"))
				cPedido := oModelGM:GetValue("Z5G_NUM")
				If ( oModelGM:GetValue("Z6G_OMAVOL") > 0 ) .AND. ( oModelGM:GetValue("Z6G_OMAVOL") < oModelGM:GetValue("Z6G_UNSVEN") )
					lKitCorte := .T.
					lKitDesp  := .T.
				ElseIf ( oModelGM:GetValue("Z6G_OMAVOL") > 0 ) .AND. ( oModelGM:GetValue("Z6G_OMAVOL") == oModelGM:GetValue("Z6G_UNSVEN") )
					lKitCorte := .F.
					lKitDesp  := .T.
				Elseif  oModelGM:GetValue("Z6G_OMAVOL") == 0
					lKitCorte := .T.
					lKitDesp  := .F.
				Endif
				If ( nPosPV := aScan( aKitCorte, { |x| x[1] == cPedido } ) ) == 0
					Aadd( aKitCorte, { cPedido, lKitDesp, lKitCorte } )
				Else
					If !aKitCorte[ nPosPV, 3] .AND. lKitCorte
						aKitCorte[ nPosPV, 3] := .T.
					Endif
					If !aKitCorte[ nPosPV, 2] .AND. lKitDesp
						aKitCorte[ nPosPV, 2] := .T.
					Endif
				Endif
			Endif
		Next nI

		nTamArray := Len( aKitCorte )
		For nI := 1 To nTamArray
			If aKitCorte[ nI, 2] .AND. aKitCorte[ nI, 3]
				Aadd( aRet, aKitCorte[ nI, 1] )
			Endif
		Next nI
	Endif
Return aRet


/*/{Protheus.doc} GravaZ24
Valida as leituras do VIF
@type function
@version 12.1.25
@author Leonardo Robes
@since 06/06/2022
@return mensagem com o erro
/*/

Static Function GravaZ24(cPRODUTO,cCodbarr,cLOTE,cPed,nPeso1,nPeca1,lDel)
	Local cFornece 	:= SuperGetMV( "MV_YFORSA5", .F., "003811;003811" )
	Local lProdExt  := .F.
	Local cProdExt	:= ""
	Local cAliasTMP := GetNextAlias()
	Local cxLote	:= SUBSTR(cLOTE,2,6)
	Local cNCS1		:= ""
	Local cQuery	:= ""
rETURN 
	If Len(AllTrim(cCodbarr)) == 26
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	ElseIf Len(AllTrim(cCodbarr)) == 28 .Or. Len(AllTrim(cCodbarr)) == 29 //29 = ADELE
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	Elseif Len(AllTrim(cCodbarr)) == 36 .AND. At(',', cCodbarr) == 5
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	Else
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	EndIf

	cQuery := " SELECT * FROM " + RetSqlName("SA5") + " A5 "
	cQuery += " WHERE A5_FILIAL = '  ' AND A5_PRODUTO = '"+cPRODUTO+"'"
	cQuery += " AND A5_FORNECE IN " + FormatIn(cFornece,";")
	cQuery += " AND D_E_L_E_T_ = ' ' "

	If SELECT(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cAliasTMP, .F., .T. )

	If !(cAliasTMP)->(Eof())
		cProdExt := cValToChar( Val( (cAliasTMP)->A5_CODPRF ) )
		lProdExt := .T.
	EndIf

	(cAliasTMP)->(dbCloseArea())

	If nPeca1 > 1
		cUpdate:= "  UPDATE Z24010 SET Z24_NUPRPV = '"+IIF(lDel,"",ALLTRIM(cPed))+"' "
		cUpdate+= "  WHERE   D_E_L_E_T_  = '' "
		cUpdate+= "      AND Z24_FILIAL  = '02'  "
		cUpdate+= "      AND Z24_PROD = '" + ALLTRIM(Iif( !lProdExt, cPRODUTO, cProdExt )) + "'  "
		cUpdate+= "      AND ( RIGHT(RTRIM(Z24_PALETE),6) = '" + cNCS1 + "' OR SUBSTRING(RIGHT(RTRIM(Z24_PALETE),7),1,6) = '" + cNCS1 + "' )  "
		cUpdate+= "      AND Z24_DATA >= '20220101'"
	Else
		cUpdate:= "  UPDATE Z24010 SET Z24_NUPRPV = '"+IIF(lDel,"",ALLTRIM(cPed))+"' "
		cUpdate+= "  WHERE   D_E_L_E_T_  = '' "
		cUpdate+= "      AND Z24_FILIAL  = '02'  "
		cUpdate+= "      AND Z24_PROD = '" + ALLTRIM(Iif( !lProdExt, cPRODUTO, cProdExt )) + "'  "
		cUpdate+= "      AND ( RIGHT(RTRIM(Z24_CAIXA),6) = '" + cNCS1 + "' OR SUBSTRING(RIGHT(RTRIM(Z24_CAIXA),7),1,6) = '" + cNCS1 + "' )  "
		cUpdate+= "      AND ( Z24_LOTE = '" + cxLote + "' OR 1=1 ) "
		cUpdate+="      AND Z24_ESTORN = '' "
		cUpdate+= "      AND Z24_DATA >= '20220101' "
	EndIF

	If TcSqlExec( cUpdate ) < 0
		Alert( "TCSQLError() " + TCSQLError() )
	EndIf
Return

/*/{Protheus.doc} ValidZ24
Valida as leituras do VIF
@type function
@version 12.1.25
@author Leonardo Robes
@since 06/06/2022
@return mensagem com o erro
/*/
Static Function ValidZ24(cPRODUTO,cNCS,cLOTE,nPESO,nPECA)
	Local cRet	:= ""
	Local cFornece 	:= SuperGetMV( "MV_YFORSA5", .F., "003811;003811" )
	Local lProdExt  := .F.
	Local cProdExt	:= ""
	Local cAliasTMP := GetNextAlias()
	Local cxLote	:= SUBSTR(cLOTE,2,6)
	Local cQuery	:= ""

	cQuery := " SELECT * FROM " + RetSqlName("SA5") + " A5 "
	cQuery += " WHERE A5_FILIAL = '  ' AND A5_PRODUTO = '"+cPRODUTO+"'"
	cQuery += " AND A5_FORNECE IN " + FormatIn(cFornece,";")
	cQuery += " AND D_E_L_E_T_ = ' ' "

	If SELECT(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cAliasTMP, .F., .T. )

	If !(cAliasTMP)->(Eof())
		cProdExt := cValToChar( Val( (cAliasTMP)->A5_CODPRF ) )
		lProdExt := .T.
	EndIf

	(cAliasTMP)->(dbCloseArea())

	If nPECA > 1

		cQuery := CRLF + "  SELECT Z24_PALETE MEDIDA, ISNULL(C2_QUJE,0) PROD,ISNULL(COUNT(Z24_PALETE),0) PECAS, ISNULL(SUM(Z24_QTDE),0) PESO "
		cQuery += CRLF + "  FROM "+ RetSqlName("Z24") +" (NOLOCK) Z24 "
		cQuery += CRLF + "  LEFT JOIN "+ RetSqlName("SC2") +" (NOLOCK) C2 ON C2_FILIAL = Z24_FILIAL AND C2_PRODUTO = Z24_PROD "
		cQuery += CRLF + "  AND SUBSTRING(C2_XOPVIF,1,6) = Z24_OF AND C2_QUANT >= 1 AND C2.D_E_L_E_T_ = ''
		cQuery += CRLF + "  WHERE   Z24.D_E_L_E_T_  = '' "
		cQuery += CRLF + "      AND Z24.Z24_FILIAL  = '02'  "
		cQuery += CRLF + "      AND Z24.Z24_PROD = '" + Iif( !lProdExt, cPRODUTO, cProdExt ) + "'  "
		cQuery += CRLF + "      AND ( RIGHT(RTRIM(Z24.Z24_PALETE),6) = '" + cNCS + "' OR SUBSTRING(RIGHT(RTRIM(Z24.Z24_PALETE),7),1,6) = '" + cNCS + "' )  "
		// cQuery += CRLF + "      AND Z24.Z24_VLDLT = '" + dDtValid + "'  "
		cQuery += CRLF + "      AND Z24_ESTORN = '' "
		cQuery += CRLF + "      AND Z24_NUPRPV = '' "
		cQuery += CRLF + "      AND Z24_DATA >= '20220101' "
		cQuery += CRLF + "  GROUP BY Z24_PALETE, C2_QUJE "

	Else

		cQuery := CRLF + "  SELECT TOP 1 Z24_CAIXA MEDIDA, ISNULL(C2_QUJE,0) PROD,1 PECAS, ISNULL(Z24_QTDE,0) PESO "
		cQuery += CRLF + "  FROM "+ RetSqlName("Z24") +" (NOLOCK) Z24 "
		cQuery += CRLF + "  LEFT JOIN "+ RetSqlName("SC2") +" (NOLOCK) C2 ON C2_FILIAL = Z24_FILIAL AND C2_PRODUTO = Z24_PROD "
		cQuery += CRLF + "  AND SUBSTRING(C2_XOPVIF,1,6) = Z24_OF AND C2_QUANT >= 1 AND C2.D_E_L_E_T_ = ''
		cQuery += CRLF + "  WHERE   Z24.D_E_L_E_T_  = '' "
		cQuery += CRLF + "      AND Z24.Z24_FILIAL  = '02'  "
		cQuery += CRLF + "      AND Z24.Z24_PROD = '" + Iif( !lProdExt, cPRODUTO, cProdExt ) + "'  "
		cQuery += CRLF + "      AND ( RIGHT(RTRIM(Z24.Z24_CAIXA),6) = '" + cNCS + "' OR SUBSTRING(RIGHT(RTRIM(Z24.Z24_CAIXA),7),1,6) = '" + cNCS + "' )  "
		cQuery += CRLF + "      AND ( Z24.Z24_LOTE = '" + cxLote + "' OR 1=1 ) "
		cQuery += CRLF + "      AND Z24_ESTORN = '' "
		cQuery += CRLF + "      AND Z24_NUPRPV = '' "
		cQuery += CRLF + "      AND Z24_DATA >= '20220101' "
		cQuery += CRLF + "  ORDER BY Z24.R_E_C_N_O_ DESC"

	EndIF

	If SELECT(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cAliasTMP, .F., .T. )

	If !(cAliasTMP)->(Eof())

		If (cAliasTMP)->PESO == 0
			cRet:= "Codigo de Barras Não integrado Protheus "
		ElseIf (cAliasTMP)->PROD == 0 .AND. LEN(ALLTRIM(cPRODUTO)) < 5
			cRet:= "Encerramento de OP Não integrado ao protheus! "
		ElseIf (cAliasTMP)->PECAS <> nPECA
			cRet:= "Quantidade de caixas lido diferente do integrado ao protheus! "
		ElseIf (cAliasTMP)->PESO <> nPESO
			cRet:= "Quantidade do peso lido diferente do integrado ao protheus! "
		EndIf
	Else
		cRet:= "Codigo de Barras Não integrado Protheus ou ja bipado"
	EndIf

	(cAliasTMP)->(dbCloseArea())
Return(cRet)
