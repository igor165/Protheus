#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA890.CH'

Static lLegend	:= .T.
Static cPrdF3 := ""

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA890
 
Realiza apontamento dos materiais de Recursos Humanos do Local de Atencimento
@author Serviços
@since 31/10/13
@version P11 R9

@return  .T. 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA890()
Local oBrowse
Local aColumns	:= {}
Local cQuery	:= ""
Local cAliasPro	:= "MNTPRO2"
Local oDlg 		:= Nil   							// Janela Principal.
Local aSize	 	:= FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.

oBrowse := FWFormBrowse():New()
aColumns := At890Cols(cAliasPro)
cQuery   := At890Query()

DEFINE DIALOG oDlg TITLE STR0001 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL // "Apontamento de Materiais"
	
// Cria um Form Browse
oBrowse := FWFormBrowse():New()
// Atrela o browse ao Dialog form nao abre sozinho
oBrowse:SetOwner(oDlg)
// Indica que vai utilizar query
oBrowse:SetAlias(cAliasPro)
oBrowse:SetDataQuery(.T.)
oBrowse:SetQuery(cQuery)

//Filtros
oBrowse:SetUseFilter(.T.)
oBrowse:SetFieldFilter(aColumns[2])

oBrowse:SetColumns(aColumns[1])
	
oBrowse:AddButton(STR0001,; //"Alocação de atendentes"
		{|| MsgRun(STR0024,STR0025,{|| At890Apon((cAliasPro)->TFL_CODIGO, (cAliasPro)->TFJ_GESMAT)} ) },,,,.F.,1)// "Montando os componentes visuais..."##"Aguarde" 						 

oBrowse:AddButton(STR0032,; //"Retorno Material de Implantação" 
		{|| MsgRun(STR0024,STR0025,{|| At890RtMip((cAliasPro)->TFL_CODIGO, (cAliasPro)->TFL_CONTRT, (cAliasPro)->TFJ_GESMAT) } ) },,,,.F.,1)// "Montando os componentes visuais..."##"Aguarde" 						 

oBrowse:AddButton( STR0023, { || oDlg:End() },,,, .F., 2 )	//'Sair'

oBrowse:SetDescription(STR0001)	//"Apontamento de Materiais"

oBrowse:Activate()

ACTIVATE DIALOG oDlg CENTERED

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

MenuDef do Fonte TECA890
@author Serviços
@since 31/10/13
@version P11 R9

@return  .T. 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TECA890'	OPERATION 4	ACCESS 0 //"Apontamento"

Return (aRotina)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Criação do Modelo de Dados conforme arquitetura MVC
@author Serviços
@since 31/10/13
@version P11 R9
@return oModel: Modelo de Dados
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function ModelDef()
Local cCodBase		:= ""
Local cCodArmaz		:= ""
Local lBaseOp		:= TecBaseOp()
Local oStruTFL 		:= FwFormStruct(1,'TFL',/*bAvalCampo*/,/*lViewUsado*/)
Local oStrGrdMtCn 	:= FwFormStruct(1,'TFT',/*bAvalCampo*/,/*lViewUsado*/)
Local oStGrdMtImp 	:= FwFormStruct(1,'TFS',/*bAvalCampo*/,/*lViewUsado*/)
Local oModel
Local bDcommit 	  	:= {|oModel| At890Commit(oModel)}
Local aAux4	      	:= {}
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local lTFTCampo := (TFT->(ColumnPos("TFT_CODSA"))>0)
Local lTFSCampo := (TFS->(ColumnPos("TFS_CODSA"))>0)
Local lABSCampo := (ABS->(ColumnPos("ABS_BASEOP"))>0)

lLegend			  := .T.

//Criação dos Campos
oStruTFL:AddField(STR0137,STR0137,'TFL_CNTREC','C',TAMSX3("TFJ_CNTREC")[1],0,/* */,/*bValid*/, /*bWhen*/, .F., {|| Posicione("TFJ", 1, xFilial("TFJ") + TFL->TFL_CODPAI ,"TFJ_CNTREC") } ,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Contrato recorrente"#"Contrato recorrente"

oStrGrdMtCn:AddField(STR0003,STR0003,'TFT_SIT','BT',1,0,{||At890GetLg()}/*bValid*/,/*bWhen*/, /*aValues*/, .F., {|| At890LgTFT()},/*lKey*/, /*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Status"
oStGrdMtImp:AddField(STR0003,STR0003,'TFS_SIT','BT',1,0,{||At890GetLg()}/*bValid*/,/*bWhen*/, /*aValues*/, .F., {|| At890LgTFS()},/*lKey*/, /*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Status"

oStrGrdMtCn:AddField(STR0004,STR0004,'TFT_SLDTTL','N',11,2,/* */,/*bValid*/, /*bWhen*/, .F., /* */,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Saldo"
oStGrdMtImp:AddField(STR0004,STR0004,'TFS_SLDTTL','N',11,2,/* */,/*bValid*/, /*bWhen*/, .F., /* */,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Saldo"

iF lGsApmat
	oStrGrdMtCn:AddField(STR0004,STR0004,'TFT_QTDSA','N',11,2,/* */,/*bValid*/, /*bWhen*/, .F., /* */,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Quantidade atendida SA" na tabela TFT
	oStGrdMtImp:AddField(STR0004,STR0004,'TFS_QTDSA','N',11,2,/* */,/*bValid*/, /*bWhen*/, .F., /* */,/*lKey*/, .F./*lNoUpd*/, .T./*lVirtual*/,/*cValid*/)//"Quantidade atendida SA  na tabela TFS"
Endif

//When dos campos
oStGrdMtImp:SetProperty("*",MODEL_FIELD_WHEN,{|| Empty(FwFldGet("TFS_ITAPUR")) })
oStGrdMtImp:SetProperty("TFS_PRODUT",MODEL_FIELD_WHEN,{|| !Empty(FwFldGet("TFS_ITAPUR")) .OR.  Empty(FwFldGet("TFS_ITAPUR")) })
oStGrdMtImp:SetProperty("TFS_DPROD",MODEL_FIELD_WHEN,{|| !Empty(FwFldGet("TFS_ITAPUR")) .OR.  Empty(FwFldGet("TFS_ITAPUR"))})
oStGrdMtImp:SetProperty("TFS_SLDTTL",MODEL_FIELD_WHEN,{|| .T. })

oStrGrdMtCn:SetProperty("*",MODEL_FIELD_WHEN,{|| Empty(FwFldGet("TFT_ITAPUR")) })
oStrGrdMtCn:SetProperty("TFT_PRODUT",MODEL_FIELD_WHEN,{|| !Empty(FwFldGet("TFT_ITAPUR")) .OR.  Empty(FwFldGet("TFT_ITAPUR"))})
oStrGrdMtCn:SetProperty("TFT_SLDTTL",MODEL_FIELD_WHEN,{|| .T. })

//Validação dos campos
If  lGsApmat .And. lTFTCampo .And. lTFSCampo
	oStGrdMtImp:SetProperty("TFS_QUANT", MODEL_FIELD_OBRIGAT, .F.)
	oStrGrdMtCn:SetProperty("TFT_QUANT", MODEL_FIELD_OBRIGAT, .F.)
Endif


oStrGrdMtCn:SetProperty("TFT_PRODUT",MODEL_FIELD_VALID,{|| At890TWYVld(FWFLDGET("TFT_PRODUT")) })
oStGrdMtImp:SetProperty("TFS_PRODUT",MODEL_FIELD_VALID,{|| At890TWYVld(FWFLDGET("TFS_PRODUT")) })

oStrGrdMtCn:SetProperty("TFT_CODTFH",MODEL_FIELD_VALID,{|| AT890VlLoc( 'TFT', FWFLDGET("TFL_CODIGO")) })
oStGrdMtImp:SetProperty("TFS_CODTFG",MODEL_FIELD_VALID,{|| AT890VlLoc( "TFS", FWFLDGET("TFL_CODIGO") ) })

oStrGrdMtCn:SetProperty("TFT_LOCALI",MODEL_FIELD_VALID,{|| Empty(FwFldGet("TFT_LOCALI")) .or. ExistCpo("SBE",FwFldGet("TFT_LOCAL")+FwFldGet("TFT_LOCALI"),1) })
oStGrdMtImp:SetProperty("TFS_LOCALI",MODEL_FIELD_VALID,{|| Empty(FwFldGet("TFS_LOCALI")) .or. ExistCpo("SBE",FwFldGet("TFS_LOCAL")+FwFldGet("TFS_LOCALI"),1)})

oStrGrdMtCn:SetProperty("TFT_QUANT",MODEL_FIELD_VALID,{|| At890ValdQnt(FWFLDGET("TFT_QUANT"), "TFH", FWFLDGET("TFT_CODTFH")) })
oStGrdMtImp:SetProperty("TFS_QUANT",MODEL_FIELD_VALID,{|| At890ValdQnt(FWFLDGET("TFS_QUANT"), "TFG", FWFLDGET("TFS_CODTFG")) })


oStGrdMtImp:SetProperty("TFS_DPROD",MODEL_FIELD_INIT, {|oMdl| Posicione("SB1", 1, xFilial("SB1") + TFS->TFS_PRODUT ,"B1_DESC")}  )
oStGrdMtImp:SetProperty("TFS_TM",MODEL_FIELD_VALID,{ ||At890TM('TFS')})
oStrGrdMtCn:SetProperty("TFT_TM",MODEL_FIELD_VALID,{ ||At890TM('TFT')})

If lBaseOp .And. lABSCampo
	cCodBase := Posicione("ABS", 1, xFilial("ABS") + TFL->TFL_LOCAL ,"ABS_BASEOP")
	If !Empty(cCodBase)
		cCodArmaz := Posicione("AA0", 1, xFilial("AA0") + cCodBase ,"AA0_LOCPAD")
		If !Empty(cCodArmaz)
			oStrGrdMtCn:SetProperty("TFT_LOCAL",MODEL_FIELD_WHEN,{|| .F.})
			oStrGrdMtCn:SetProperty("TFT_LOCAL",MODEL_FIELD_INIT,{|| cCodArmaz})
			oStGrdMtImp:SetProperty("TFS_LOCAL",MODEL_FIELD_WHEN,{|| .F.})
			oStGrdMtImp:SetProperty("TFS_LOCAL",MODEL_FIELD_INIT,{|| cCodArmaz})
		EndIf
	EndIf
EndIF

//Criação dos Gatilhos
aAux4 := FwStruTrigger("TFT_CODTFH","TFT_PRODUT","At890DcTFT(),At890SlTFH(),At890PrTFT()",.F.,Nil,Nil,Nil) 					//Gatilho do material de consumo, preenche produto, descrição do produto e saldo
oStrGrdMtCn:AddTrigger(aAux4[1],aAux4[2],aAux4[3],aAux4[4])

aAux4 := FwStruTrigger("TFS_CODTFG","TFS_PRODUT","At890DcTFS(),At890SlTFG(),At890PrTFS()",.F.,Nil,Nil,Nil) 					//Gatilho do material de consumo, preenche produto, descrição do produto e saldo
oStGrdMtImp:AddTrigger(aAux4[1],aAux4[2],aAux4[3],aAux4[4])

oModel := MPFormModel():New('TECA890',/*bPreValidacao*/,{|oModel| At890ApVl(oModel)},bDcommit,/*bCancel*/)

oModel:AddFields('TFLMASTER',/*cOwner*/,oStruTFL,/*bPreValidacao*/,/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)
 
oModel:AddGrid('TFTGRID', 'TFLMASTER',oStrGrdMtCn,{|oMdlG,nLine,cAcao,cCampo| At890PosVal(oMdlG,nLine,cAcao,"TFT_ITAPUR","TFT",cCampo)}/*bPreValidacao*/,{|| At890LinhaOK()},/*bCarga*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation('TFTGRID', {{'TFT_FILIAL', 'xFilial("TFT")'}, {'TFT_CODTFL', 'TFL_CODIGO'}}, TFT->(IndexKey(1)))

oModel:AddGrid('TFSGRID', 'TFLMASTER',oStGrdMtImp,{|oMdlG,nLine,cAcao,cCampo| At890PosVal(oMdlG,nLine,cAcao,"TFS_ITAPUR","TFS",cCampo)}/*bPreValidacao*/,{|| At890LnOKTFS()},/*bCarga*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation('TFSGRID', {{'TFS_FILIAL', 'xFilial("TFS")'}, {'TFS_CODTFL', 'TFL_CODIGO'}}, TFS->(IndexKey(1)))

oModel:GetModel('TFLMASTER'):SetDescription('TFL')
oModel:GetModel('TFLMASTER'):SetOnlyView(.T.)

oModel:GetModel('TFSGRID'):SetDescription('TFS')
oModel:GetModel('TFTGRID'):SetDescription('TFT')
oModel:GetModel('TFSGRID'):SetOptional(.T.)
oModel:GetModel('TFTGRID'):SetOptional(.T.)

oModel:setDescription(STR0001)//"Apontamento de Materiais"

//Filtra o grid de implantação pra não carregar movimentos de devolução
oModel:GetModel('TFSGRID'):SetLoadFilter({{'TFS_MOV',"'1'",MVC_LOADFILTER_EQUAL}})

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return (oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Criação da View da Tela de Cadastro
@author Serviços
@since 31/10/13
@version P11 R9
@return ExpO: View criada para o cadastro
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function ViewDef()
Local oView	
Local oModel	:= FwLoadModel('TECA890')
Local oStruTFL	:= FwFormStruct(2,'TFL')
Local oStrGrdMtCn	:= FwFormStruct(2,'TFT')
Local oStrGrdImp	:= FwFormStruct(2,'TFS')
Local nOperation 	:= oModel:GetOperation()
Local lTecEntCtb    := FindFunction("TecEntCtb") .And. TecEntCtb("TFT") .And. TecEntCtb("TFS")
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)

oView := FWFormView():New()
oView:SetModel(oModel)

//Remove o campo da View
oStrGrdImp:RemoveField("TFS_MOV")

If !lTecEntCtb
    If TFS->( ColumnPos('TFS_CONTA') ) > 0
        oStrGrdImp:RemoveField("TFS_CONTA")
    EndIf
    If TFS->( ColumnPos('TFS_ITEM') ) > 0
        oStrGrdImp:RemoveField("TFS_ITEM")
    EndIf
    If TFS->( ColumnPos('TFS_CLVL') ) > 0
        oStrGrdImp:RemoveField("TFS_CLVL")
    EndIf
    If TFT->( ColumnPos('TFT_CONTA') ) > 0
        oStrGrdMtCn:RemoveField("TFT_CONTA")
    EndIf
    If TFT->( ColumnPos('TFT_ITEM') ) > 0
        oStrGrdMtCn:RemoveField("TFT_ITEM")
    EndIf
    If TFT->( ColumnPos('TFT_CLVL') ) > 0
        oStrGrdMtCn:RemoveField("TFT_CLVL")
    EndIf
EndIf

oStruTFL:AddField( 'TFL_CNTREC', ; // cIdField
       				'45', ; // cOrdem
                     STR0137, ; // "Contrato recorrente"
                     STR0137, ; // "Contrato recorrente"
                     {}, ; // aHelp
                   	'C', ; // cType
                   	'@ ', ; // cPicture
       				Nil, ; // nPictVar
                     Nil, ; // Consulta F3
                     .F., ; // lCanChange
                    '', ; // cFolder
                     Nil, ; // cGroup
                     {STR0138,STR0139}, ; // aComboValues "1=Sim"##"2=Não"
                     Nil, ; // nMaxLenCombo
                     Nil, ; // cIniBrow
                     .T., ; // lVirtual
                     Nil ) // cPictVar
//Campo virtual que indicará se o apontamento do material de consumo foi ou não apurado. 
oStrGrdMtCn:AddField( 'TFT_SIT', ;	// cIdField
       				'01', ; 		// cOrdem
                    STR0003, ;		// cTitulo
                    STR0003, ;		// cDescric
                    {}, ;			// aHelp
                   	'BT', ; 		// cType
                   	'', ; 			// cPicture
       				Nil, ; 			// nPictVar
                    Nil, ; 			// Consulta F3
                    .T., ; 			// lCanChange
                    '', ; 			// cFolder
                    Nil, ; 			// cGroup
                    Nil, ; 			// aComboValues
                    Nil, ; 			// nMaxLenCombo
                    Nil, ; 			// cIniBrow
                    .T., ; 			// lVirtual
                    Nil ) 			// cPictVar
//Campo virtual para visualização do saldo do material de consumo.    
oStrGrdMtCn:AddField( 'TFT_SLDTTL', ; // cIdField
       				'07', ; // cOrdem
                    	STR0004, ; // cTitulo
                     STR0004, ; // cDescric
                     {}, ; // aHelp
                   	'N', ; // cType
                   	'@E 99,999,999.99', ; // cPicture
       				Nil, ; // nPictVar
                     Nil, ; // Consulta F3
                     .F., ; // lCanChange
                    	'', ; // cFolder
                     Nil, ; // cGroup
                     Nil, ; // aComboValues
                     Nil, ; // nMaxLenCombo
                     Nil, ; // cIniBrow
                     .T., ; // lVirtual
                     Nil ) // cPictVar
//Campo virtual que indicará se o apontamento do material operacional foi ou não apurado.       
iF lGsApmat 
	oStrGrdMtCn:AddField( 'TFT_QTDSA', ; // cIdField
					'09', ; // cOrdem
					STR0170,; // cTitulo
					STR0171,; // cDescric
						{}, ; // aHelp
					'N', ; // cType
					'@E 99,999,999.99', ; // cPicture
					Nil, ; // nPictVar
						Nil, ; // Consulta F3
						.F., ; // lCanChange
						'', ; // cFolder
						Nil, ; // cGroup
						Nil, ; // aComboValues
						Nil, ; // nMaxLenCombo
						Nil, ; // cIniBrow
						.T., ; // lVirtual
						Nil ) // cPictVar
//Campo virtual que indicará a quantidade que foi atendida no armazem.
Endif	              
oStrGrdImp:AddField( 'TFS_SIT', ; // cIdField
       				'01', ; // cOrdem
                    	STR0003, ; // cTitulo
                     STR0003, ; // cDescric
                     {}, ; // aHelp
                   	'BT', ; // cType
                   	'', ; // cPicture
       				Nil, ; // nPictVar
                     Nil, ; // Consulta F3
                     .T., ; // lCanChange
                    	'', ; // cFolder
                     Nil, ; // cGroup
                     Nil, ; // aComboValues
                     Nil, ; // nMaxLenCombo
                     Nil, ; // cIniBrow
                     .T., ; // lVirtual
                     Nil ) // cPictVar 
//Campo virtual para visualização do saldo do material operacional.                      
oStrGrdImp:AddField( 'TFS_SLDTTL', ; // cIdField
       				'07', ; // cOrdem
                     STR0004, ; // cTitulo
                     STR0004, ; // cDescric
                     {}, ; // aHelp
                   	'N', ; // cType
                   	'@E 99,999,999.99', ; // cPicture
       				Nil, ; // nPictVar
                     Nil, ; // Consulta F3
                     .F., ; // lCanChange
                    	'', ; // cFolder
                     Nil, ; // cGroup
                     Nil, ; // aComboValues
                     Nil, ; // nMaxLenCombo
                     Nil, ; // cIniBrow
                     .T., ; // lVirtual
                     Nil ) // cPictVar
iF lGsApmat
	oStrGrdImp:AddField( 'TFS_QTDSA', ; // cIdField
						'09', ; // cOrdem
						STR0170, ; // cTitulo
						STR0171, ; // cDescric
						{}, ; // aHelp
						'N', ; // cType
						'@E 99,999,999.99', ; // cPicture
						Nil, ; // nPictVar
						Nil, ; // Consulta F3
						.F., ; // lCanChange
						'',  ; // cFolder
						Nil, ; // cGroup
						Nil, ; // aComboValues
						Nil, ; // nMaxLenCombo
						Nil, ; // cIniBrow
						.T., ; // lVirtual
						Nil ) // cPictVar
//Campo virtual que indicará a quantidade que foi atendida no armazem.
Endif

oView:AddField('VIEW_GERAL', oStruTFL, 'TFLMASTER') 	//View geral onde será o cabeçalho, tabela TFL

oView:AddGrid('VIEW_MAIMP', oStrGrdImp, 'TFSGRID')
oView:AddGrid('VIEW_MACONS', oStrGrdMtCn, 'TFTGRID')

oView:CreateHorizontalBox('TELAGERAL',30)
oView:CreateHorizontalBox('METADE',70)

oView:CreateFolder('PASTA','METADE')
oView:AddSheet('PASTA','ABA01',STR0028)//"Material de Implantação"
oView:AddSheet('PASTA','ABA02',STR0029)//"Material de Consumo"

oView:CreateHorizontalBox('INFERIOR', 100,,,'PASTA','ABA01')
oView:CreateHorizontalBox('MAXINFERIOR', 100,,,'PASTA','ABA02')

oView:SetOwnerView( 'VIEW_GERAL','TELAGERAL' )
oView:SetOwnerView( 'VIEW_MAIMP', 'INFERIOR' )
oView:SetOwnerView( 'VIEW_MACONS', 'MAXINFERIOR' )
oView:AddUserButton(STR0166,"",{|| At890CpAp(oModel,oView) },,,)  //"Copiar apontamentos"

oView:SetCloseOnOk({|| .T.} )

If isInCallStack("At890Apon")
	IF TFJ->TFJ_GESMAT == '4'
		oView:HideFolder('PASTA',STR0029, 2)
	ElseIf TFJ->TFJ_GESMAT == '5'
		oView:HideFolder('PASTA',STR0028, 2)
	EndIf
EndIf

Return (oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890ConsMC

Realiza a Consulta especifica para os Materiais de Consumo do local de atendimento
@sample  At890ConsMC() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890ConsMC()
Local lRet              := .T.
Local aCmpBco           := {}
Local cQuery            := ""
Local cDscCmp           := ""
Local cConteudo   	   := ""
Local cCodigo           := ""
Local cEntida           := ""
Local cLocal            := ""
Local lOk               := .F.
Local cProdut 			:= ""
Local cPesq				:= Space(TamSX3("TFT_CODTFH")[1])
Local oPesqui			:= Nil //Objeto Pesquisa
Local oModel            := Nil //Modelo atual
Local oDlgCmp           := Nil //Dialog
Local oPanel            := Nil //Objeto Panel
Local oFooter           := Nil //Rodapé
Local oListBox          := Nil //Grid campos
Local oOk               := Nil //Objeto Confirma 
Local oCancel           := Nil //Objeto Cancel
Local aCabec			:= {STR0005,STR0006,STR0007}

aCmpBco := At890QryMC(@aCabec)

If !Empty(aCmpBco)

      //  Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
      Define MsDialog oDlgCmp FROM 000, 000 To 350, 550 Pixel
                  
      //Cria o Panel de pesquisa
      @ 000, 000 MsPanel oPesqui Of oDlgCmp Size 000, 012 // Coordenada para o panel
      oPesqui:Align   := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
       
      @ 02,147 SAY STR0063 SIZE 70,30 PIXEL OF oPesqui//"Cod. Mat. Cons: " 
      
      @ 001,190 GET oPesqui VAR cPesq SIZE 25,03 OF oDlgCmp PIXEL
            
      @ 001,227 BUTTON STR0055 SIZE 50,10 ACTION {|| At890Find(cPesq, oListBox, 1) } OF oDlgCmp PIXEL //"Pesquisar"
                  
      // Cria o panel principal
      @ 000, 000 MsPanel oPanel Of oDlgCmp Size 250, 340 // Coordenada para o panel
      oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
            
      // Criação do grid para o panel    
      oListBox := TWBrowse():New( 40,05,204,100,,aCabec,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Código"###"Produto"###"Desc Produto"
      oListBox:SetArray(aCmpBco) // Atrela os dados do grid com a matriz
      oListBox:bLine := &(At890BLin(aCmpBco)) // Indica as linhas do grid
      oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgCmp:End()} // Duplo clique executa a ação do objeto indicado
      oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
            
      // Cria o panel para os botoes     
      @ 000, 000 MsPanel oFooter Of oDlgCmp Size 000, 010 // Corrdenada para o panel dos botoes (size)
      oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
                  
      // Botoes para o grid auxiliar     
      @ 000, 000 Button oCancel Prompt STR0008  Of oFooter Size 030, 000 Pixel //"Cancelar"
      oCancel:bAction := { || lOk := .F., oDlgCmp:End() }
      oCancel:Align   := CONTROL_ALIGN_RIGHT
            
      @ 000, 000 Button oOk     Prompt STR0009 Of oFooter Size 030, 000 Pixel //"Confirmar"
      oOk:bAction     := { || lOk := .T.,cCodigo:=aCmpBco[oListBox:nAT][1],oDlgCmp:End() } // Acao ao clicar no botao
      oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
     	cProdut:= aCmpBco[oListBox:nAT][2]
            // Ativa a tela exibindo conforme a coordenada
      Activate MsDialog oDlgCmp Centered
                  
      //Utilizar o modelo ativo para substituir os valores das variaves de memoria      
      oModel      := FWModelActive()
            
	If lOk 
    	oModel:SetValue("TFTGRID","TFT_CODTFH", cCodigo)
    	oModel:SetValue("TFTGRID","TFT_PRODUT", "")
    	oModel:SetValue("TFTGRID","TFT_DPROD", "")
    	oModel:SetValue("TFTGRID","TFT_SLDTTL", 0)
	EndIf
Else
      Help( ,, 'Help',, STR0010, 1, 0 )//"Não há Materiais de Consumo para este Local de Atendimento"
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT890RetMC

Retorna a variavel da memoria do model, para a consulta especifica
@sample     At890RetMC() 
@since      31/10/2013
@version 	 P11 R9
     
@return     cCodigo, CHARACTER, conteudo da variavel de memoria.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890RetMC()

Return FwFldGet("TFT_CODTFH")

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890QryMC

Realiza a Query para a consulta especifica para trazer somentete materiais de consumo que o local de atendimento possua.
@sample     At890QryMC() 
@since      31/10/2013 
@version 	 P11 R9
     
@return     aRet, Array com os Responsaveis
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890QryMC(aCabec)


	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local aRet      := {}
	Local oModel    := FwModelActive()
	Local oMdlTFL	:= nil
	Local cAlias := GetNextAlias()
	Local cCond 	:= ''
	Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.) 
	Local lAt890Camp := ExistBlock("AT890CMP")
	Local aRetNew	:= {}
	Default aCabec	:= {}

	If ValType(oModel) == 'O' .and. oModel:GetId() == 'TECA890'
		
		oMdlTFL := oModel:GetModel('TFLMASTER')
		cCond	:= oMdlTFL:GetValue('TFL_CODIGO')
		If lOrcPrc //Orçamento com tabela de Precificação
			BeginSql Alias cAlias
				SELECT
					TFH_COD, 
					TFH_PRODUT
				
				FROM %table:TFL% TFL
				
				INNER JOIN %table:TFH% TFH
					 ON TFH.TFH_FILIAL = %xFilial:TFH%   
					AND TFH.TFH_CODPAI = TFL.TFL_CODIGO
				
				WHERE
					TFL.TFL_FILIAL = %xFilial:TFL% AND
					TFL.TFL_CODIGO = %Exp:cCond% AND  	
					TFL.%NotDel% AND
					TFH.%NotDel% 
			
			EndSql
		Else //orçamento Sem tabela de Precificação
			BeginSql Alias cAlias
				SELECT
					TFH_COD, 
					TFH_PRODUT
				
				FROM %table:TFL% TFL
				
				INNER JOIN %table:TFF% TFF
					 ON TFF.TFF_FILIAL = %xFilial:TFF%  
					AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
				
				INNER JOIN %table:TFH% TFH
					 ON TFH.TFH_FILIAL = %xFilial:TFH%   
					AND TFH.TFH_CODPAI = TFF.TFF_COD
				
				WHERE
					TFL.TFL_FILIAL = %xFilial:TFL% AND
					TFL.TFL_CODIGO = %Exp:cCond% AND  	
					TFF.TFF_ENCE <> '1' AND
					TFL.%NotDel% AND
					TFF.%NotDel% AND
					TFH.%NotDel%  
					
			EndSql
		EndIf
	EndIf
	While !(cAlias)->(Eof())					 
		//faz dbseek na SB1 e ve se o produto existe lá para que seja aceito.
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1") + (cAlias)->TFH_PRODUT))
			aAdd(aRet,{(cAlias)->TFH_COD 	,;
				 (cAlias)->TFH_PRODUT 		,;
				 Posicione("SB1", 1, xFilial("SB1") + (cAlias)->TFH_PRODUT, "B1_DESC")})	
		EndIf				
		(cAlias)->(DbSkip())	
	EndDo
	(cAlias)->(DbCloseArea())
	If lAt890Camp
		aRetNew := ExecBlock("AT890CMP",.F.,.F.,{aRet,aCabec,"TFH"})
		If ValType( aRetNew ) == "A"
			aRet   := aClone(aRetNew[1])
			aCabec := aClone(aRetNew[2])
		EndIf
	Endif
	
	RestArea(aAreaSB1)
	RestArea(aArea)

Return(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890ConsMI

Realiza a Consulta especifica para os Materiais operacionais do local de atendimento

@sample  At890ConsMI() 
@author  Serviços
@since 	  31/10/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890ConMI()
Local lRet					:= .T.
Local aCmpBco				:= {}
Local cQuery				:= ""
Local cDscCmp				:= ""
Local cConteudo   		:= ""
Local cCodigo				:= ""
Local cEntida				:= ""
Local cLocal				:= ""
Local lOk					:= .F.
Local cPesq				:= Space(TamSX3("TFS_CODTFG")[1])
Local oModel				:= Nil //Modelo atual
Local oDlgCmp				:= Nil //Dialog
Local oPanel				:= Nil //Objeto Panel
Local oFooter				:= Nil //Rodapé
Local oListBox			:= Nil //Grid campos
Local oOk					:= Nil //Objeto Confirma 
Local oCancel				:= Nil //Objeto Cancel
Local oPesqui				:= Nil //Objeto Pesquisa
Local aCabec	:= {STR0005,STR0006,STR0007}

aCmpBco := At890QryMI(aCabec)

If !Empty(aCmpBco)

      //    Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
      Define MsDialog oDlgCmp FROM 000, 000 To 350, 550 Pixel
                  
      //Cria o Panel de pesquisa
      @ 000, 000 MsPanel oPesqui Of oDlgCmp Size 000, 012 // Coordenada para o panel
      oPesqui:Align   := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
      
      @ 02,150 SAY STR0064 SIZE 70,030 PIXEL OF oPesqui  //"Cod. Mat. Imp: " 
      
      @ 001,190 GET oPesqui VAR cPesq SIZE 25,03 OF oDlgCmp PIXEL
            
      @ 001,227 BUTTON STR0055 SIZE 50,10 ACTION {|| At890Find(cPesq, oListBox, 1) } OF oDlgCmp PIXEL //"Pesquisar"
                  
      // Cria o panel principal
      @ 000, 000 MsPanel oPanel Of oDlgCmp Size 250, 340 // Coordenada para o panel
      oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
            
      // Criação do grid para o panel    
      oListBox := TWBrowse():New( 40,05,204,100,,aCabec,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Código"###"Produto"###"Desc Produto"
      oListBox:SetArray(aCmpBco) // Atrela os dados do grid com a matriz
      oListBox:bLine := &(At890BLin(aCmpBco))  // Indica as linhas do grid
      oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgCmp:End()} // Duplo clique executa a ação do objeto indicado
      oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
            
      // Cria o panel para os botoes     
      @ 000, 000 MsPanel oFooter Of oDlgCmp Size 000, 010 // Corrdenada para o panel dos botoes (size)
      oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
                  
      // Botoes para o grid auxiliar     
      @ 000, 000 Button oCancel Prompt STR0008  Of oFooter Size 030, 000 Pixel //"Cancelar"
      oCancel:bAction := { || lOk := .F., oDlgCmp:End() }
      oCancel:Align   := CONTROL_ALIGN_RIGHT
            
      @ 000, 000 Button oOk     Prompt STR0009 Of oFooter Size 030, 000 Pixel //"Confirmar"
      oOk:bAction     := { || lOk := .T.,cCodigo:=aCmpBco[oListBox:nAT][1],oDlgCmp:End() } // Acao ao clicar no botao
      oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
     	cProdut:= aCmpBco[oListBox:nAT][2]
            // Ativa a tela exibindo conforme a coordenada
      Activate MsDialog oDlgCmp Centered
                  
      //Utilizar o modelo ativo para substituir os valores das variaves de memoria      
      oModel      := FWModelActive()
            
	If lOk 
    	oModel:SetValue("TFSGRID","TFS_CODTFG", cCodigo)
    	oModel:SetValue("TFSGRID","TFS_PRODUT", "")
    	oModel:SetValue("TFSGRID","TFS_DPROD", "")
    	oModel:SetValue("TFSGRID","TFS_SLDTTL", 0)
	EndIf
Else
      Help( ,, 'Help',, STR0011, 1, 0 )//"Não há Materiais operacionais para este Local de Atendimento"
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT890RetMI

Retorna a variavel da memoria do model, para a consulta especifica

@sample  AT890RetMI() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
     
@return  cCodigo, CHARACTER, conteudo da variavel de memoria.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890RetMI()
Return (FwFldGet("TFS_CODTFG"))

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890QryMI

Realiza a Query para a consulta especifica do Material Operacional especifico do local de atendimento.

@sample  At890QryMI() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
    
@return     aRet, Array com os Responsaveis
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890QryMI(aCabec)

	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local aRet      := {}
	Local oModel    := FwModelActive()
	Local oMdlTFL	:= nil
	Local cAlias := GetNextAlias()
	Local cCond 	:= ''
	Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.) 
	Local lAt890Camp := ExistBlock("AT890CMP")	
	Local aRetNew := {}
	Default aCabec	:= {}

	If ValType(oModel) == 'O' .and. oModel:GetId() == 'TECA890'
		oMdlTFL := oModel:GetModel('TFLMASTER')
		cCond	:= oMdlTFL:GetValue('TFL_CODIGO')
		If lOrcPrc //Orçamento com tabela de Precificação
			BeginSql Alias cAlias

				SELECT
					TFG_COD, 
					TFG_PRODUT
				
				FROM %table:TFL% TFL
				
				INNER JOIN %table:TFG% TFG
					 ON TFG.TFG_FILIAL = %xFilial:TFG%   
					AND TFG.TFG_CODPAI = TFL.TFL_CODIGO
				
				WHERE
					TFL.TFL_FILIAL = %xFilial:TFL% AND
					TFL.TFL_CODIGO = %Exp:cCond% AND  	
					TFL.%NotDel% AND
					TFG.%NotDel% 
			EndSql
		Else //orçamento Sem tabela de Precificação
			BeginSql Alias cAlias
				SELECT
					TFG_COD, 
					TFG_PRODUT
				
				FROM %table:TFL% TFL
				
				INNER JOIN %table:TFF% TFF
					 ON TFF.TFF_FILIAL = %xFilial:TFF%  
					AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
				
				INNER JOIN %table:TFG% TFG
					 ON TFG.TFG_FILIAL = %xFilial:TFG%   
					AND TFG.TFG_CODPAI = TFF.TFF_COD
				
				WHERE
					TFL.TFL_FILIAL = %xFilial:TFL% AND
					TFL.TFL_CODIGO = %Exp:cCond% AND  	
					TFL.%NotDel% AND
					TFF.%NotDel% AND
					TFG.%NotDel%  
			EndSql
		EndIf
	EndIf
	While !(cAlias)->(Eof())					 
		//faz dbseek na SB1 e ve se o produto existe lá para que seja aceito.
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1") + (cAlias)->TFG_PRODUT))
			aAdd(aRet,{(cAlias)->TFG_COD 	,;
				 (cAlias)->TFG_PRODUT 		,;
				 Posicione("SB1", 1, xFilial("SB1") + (cAlias)->TFG_PRODUT, "B1_DESC")})	
		EndIf				
		(cAlias)->(DbSkip())	
	EndDo
	(cAlias)->(DbCloseArea())
	If lAt890Camp
		aRetNew := ExecBlock("AT890CMP",.F.,.F.,{aRet,aCabec,"TFG"})
		If ValType( aRetNew ) == "A"
			aRet   := aClone(aRetNew[1])
			aCabec := aClone(aRetNew[2])
		EndIf
	Endif
	
	RestArea(aAreaSB1)
	RestArea(aArea)

Return(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890PrTFS

Realiza busca do produto para preenchimento no gatilho

@sample  At890PrTFS() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
    
@return     cFinal, Valor do Produto
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890PrTFS()
Local cFinal	:= ""
Local aArea	:=	GetArea()
DbSelectArea("TFG")
DbSetOrder(1)
If TFG->(DbSeek(xFilial("TFG")+(FwFldGet("TFS_CODTFG"))))
	cFinal:=TFG->TFG_PRODUT
EndIf
RestArea(aArea)
Return cFinal

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890DcTFS

Realiza busca do produto para preenchimento no gatilho

@sample  At890PrTFS() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
    
@return     cDesc, Descrição do Produto
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890DcTFS()

	Local aArea		:= GetArea()
	Local aAreaTFG	:= TFG->(GetArea())
	Local aAreaSB1	:= SB1->(GetArea()) 
	Local aSaveLines	:= FWSaveRows()
	Local cFinal	:= ""
	Local cDesc		:= ""
	Local oModel	:= FwModelActive() 
	Local oMdlTFS	:= Nil
	
	If ValType(oModel)=='O' .and. oModel:GetId()=='TECA890'
		oMdlTFS := oModel:GetModel('TFSGRID') 
		DbSelectArea("TFG")
		TFG->(DbSetOrder(1))
		If TFG->(DbSeek(xFilial("TFG") + (oMdlTFS:GetValue("TFS_CODTFG"))))
			cFinal := TFG->TFG_PRODUT
		EndIf
		
		If !Empty (cFinal) 
			cDesc := Posicione("SB1",1,xFilial("SB1") + cFinal,"B1_DESC")
		End
		
		At890Set(oModel:GetModel("TFSGRID"), "TFS_DPROD", cDesc )
		
	EndIf

	FWRestRows(aSaveLines)
	RestArea(aAreaSB1)
	RestArea(aAreaTFG)
	RestArea(aArea)

Return cDesc 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890SlTFG

Busca saldo atual, quando ouver o disparo do gatilho do campo quantidade.

@sample  At890SlTFG() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@return nSld: Retorna saldo atual do material Operacional posicionado
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890SlTFG()

	Local aArea			:= GetArea()
	Local aAreaTFG 		:= TFG->(GetArea())
	Local aSaveLines		:= FWSaveRows()
	Local oModel			:= FwModelActive()
	Local oModelTFS		:= nil
	Local cProdut			:= ""
	Local cCodTFG			:= ""
	Local nSld				:= 0
	Local nX				:= 0
	Local nLAt				:= 0 
	Local lSeExist 		:= .F.
	
	If ValType(oModel)=='O' .and. oModel:GetId()== 'TECA890'	
		oModelTFS := oModel:GetModel("TFSGRID") 
		cCodTFG := oModelTFS:GetValue("TFS_CODTFG")//FWFLDGET("TFT_CODTFH")
		nLAt := oModelTFS:GetLine() //Captura Linha Atual
		//Caso já Exista o Produto na Grid Ele Pega o Ultimo Valor do (Saldo - Saldo)
		For nX := 1 To oModelTFS:Length() 
			oModelTFS:GoLine(nX)
			If  !oModelTFS:IsDeleted() .and.;
				oModelTFS:GetValue("TFS_CODTFG") = cCodTFG .and.;
				oModelTFS:GetValue("TFS_SLDTTL") > 0
				nSld := oModelTFS:GetValue("TFS_SLDTTL")
				lSeExist := .T.
			EndIf
		Next nX
		If !lSeExist
			DbSelectArea("TFG")
			TFG->(DbSetOrder(1))//TFH_FILIAL + TFH_COD
			If TFG->(DbSeek(xFilial("TFG") + cCodTFG))
				nSld := TFG->TFG_SLD
			EndIf	
		EndIf
		oModelTFS:GoLine(nLAt)//Retorna para linha Atual
		oModel:LoadValue("TFSGRID","TFS_SLDTTL", nSld)
	EndIf
	
	FWRestRows(aSaveLines)	
	RestArea(aAreaTFG)
	RestArea(aArea)

Return nSld

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890PrTFT

Busca produto, quando ouver o disparo do gatilho do campo material.
@sample  At890PrTFT() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@return cFinal: Retorna produto relacionado ao material do local de atendimento.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890PrTFT()
Local cFinal	:= ""
Local aArea	:=GetArea()
DbSelectArea("TFH")
DbSetOrder(1)
If TFH->(DbSeek(xFilial("TFH")+(FwFldGet("TFT_CODTFH"))))
	cFinal:=TFH->TFH_PRODUT
EndIf
RestArea(aArea)
Return cFinal

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890DcTFT

Busca produto, quando ouver o disparo do gatilho do campo material.

@sample  At890DcTFT() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@return cFinal: Retorna a descrição do produto relacionado ao material do local de atendimento.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890DcTFT()

	Local aArea		:= GetArea()
	Local aAreaTFH	:= TFH->(GetArea())
	Local aAreaSB1	:= SB1->(GetArea()) 
	Local aSaveLines	:= FWSaveRows()
	Local cFinal	:= ""
	Local cDesc     := ""
	Local oModel	:= FwModelActive() 
	Local oMdlTFT	:= Nil
	
	If ValType(oModel)=='O' .and. oModel:GetId()=='TECA890'
		oMdlTFT := oModel:GetModel('TFTGRID') 
		DbSelectArea("TFH")
		TFH->(DbSetOrder(1))
		If TFH->(DbSeek(xFilial("TFH") + (oMdlTFT:GetValue("TFT_CODTFH"))))
			cFinal := TFH->TFH_PRODUT
		EndIf
		
		If !Empty (cFinal) 
			cDesc := Posicione("SB1",1,xFilial("SB1") + cFinal,"B1_DESC")
		End
		
		At890Set(oModel:GetModel("TFTGRID"), "TFT_DPROD", cDesc )
	EndIf
	
	FWRestRows(aSaveLines)
	RestArea(aAreaSB1)
	RestArea(aAreaTFH)
	RestArea(aArea) 

Return cDesc
///

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890SlTFH

Busca saldo atual, quando ouver o disparo do gatilho do campo quantidade.
@sample  At890DcTFT() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@return nSld: Retorna saldo atual do material de consumo posicionado
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890SlTFH()

	Local aArea		:= GetArea()
	Local aAreaTFH 	:= TFH->(GetArea())
	Local aSaveLines:= FWSaveRows()
	Local oModel	:= FwModelActive()
	Local oModelTFT	:= nil//oModel:GetModel("TFTGRID")
	Local cProdut	:= ""
	Local cCodTFH	:= ""
	Local nSld		:= 0
	Local nX		:= 0
	Local nLAt		:= 0 
	Local lSeExist 	:= .F.
	Local lCntRec	:= .F.
	Local dDtIni 	:= FirstDate(dDataBase)
	Local dDtFim 	:= LastDate(dDataBase)

	If ValType(oModel)=='O' .and. oModel:GetId()== 'TECA890'	
		lCntRec := (oModel:GetValue("TFLMASTER","TFL_CNTREC") == "1")
		oModelTFT := oModel:GetModel("TFTGRID") 
		cCodTFH := oModelTFT:GetValue("TFT_CODTFH")//FWFLDGET("TFT_CODTFH")
		nLAt := oModelTFT:GetLine() //Captura Linha Atual
		//Caso já Exista o Produto na Grid Ele Pega o Ultimo Valor do (Saldo - Saldo)
		For nX := 1 To oModelTFT:Length() 
			oModelTFT:GoLine(nX)
			If lCntRec
				If !oModelTFT:IsDeleted() .and.;
					 oModelTFT:GetValue("TFT_CODTFH") = cCodTFH .and.;
					  oModelTFT:GetValue("TFT_SLDTTL") > 0 .And.;
						oModelTFT:GetValue("TFT_DTAPON") >= dDtini .And.;
						 oModelTFT:GetValue("TFT_DTAPON") <= dDtFim 
					nSld := oModelTFT:GetValue("TFT_SLDTTL")
					lSeExist := .T.
				EndIf
			Else
				If  !oModelTFT:IsDeleted() .and.;
					oModelTFT:GetValue("TFT_CODTFH") = cCodTFH .and.;
					oModelTFT:GetValue("TFT_SLDTTL") > 0
					nSld := oModelTFT:GetValue("TFT_SLDTTL")
					lSeExist := .T.
				EndIf
			Endif
		Next nX
		If !lSeExist
			DbSelectArea("TFH")
			TFH->(DbSetOrder(1))//TFH_FILIAL + TFH_COD
			If TFH->(DbSeek(xFilial("TFH") + cCodTFH))
				If  lCntRec
					nSld := At890SldRc(TFH->TFH_COD)
				Else
					nSld := TFH->TFH_SLD					
				Endif
			EndIf	
		EndIf
		oModelTFT:GoLine(nLAt)//Retorna para linha Atual
		oModel:SetValue("TFTGRID","TFT_SLDTTL", nSld)
	EndIf
	
	FWRestRows(aSaveLines)	
	RestArea(aAreaTFH)
	RestArea(aArea)

Return nSld

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890Commit

Realiza a Gravação dos Dados utilizando o Model
@sample  At890DcTFT() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@param ExpO:Modelo de Dados da Tela de Locais de Atendimento

@return ExpL: Retorna .T. quando houve sucesso na Gravação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890Commit(oModel)

Local lRetorno 	:= .T.
Local lConfirm 
Local nOperation	:= oModel:GetOperation()

//A operação no momento só permite alteração e não entrará no caso de exclusão.
If nOperation == 5					// Quando a operação for de exclusão, questionará se realmente deseja excluir a exceção por cliente junto as exceções por periodo que estão relacionadas.
	If !IsBlind()
		lConfirm:= MsgYesNo(STR0012) //"Deseja realmente desfazer o apontamento?"
	Else
		lConfirm	:= .T.
	EndIf
		
	If lConfirm == .T.
		Begin Transaction
	
		If !(lRetorno := At890ExcAt(oModel))
			DisarmTransacation()
		Else
			FWFormCommit(oModel)
		EndIf
	
		End Transaction
	EndIf
Else								//Senão for exclusão, não haverá questionamento.
	Begin Transaction
	
		If !(lRetorno := At890ExcAt(oModel))
			DisarmTransacation()
		Else
			lLegend	:= .F.
			FWFormCommit(oModel)			
		EndIf
	End Transaction
EndIf

Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890ExcAt

Realiza a Gravação dos dados utilizando a ExecAuto MATA240 para inclusão e extorno de apontamentos.
no Modulo Estoque
@sample  At890ExcAt() 
@author  Serviços
@since 	  31/10/13
@version P11 R9
@param ExpO:Modelo de Dados da Tela de Locais de Atendimento

@return ExpL: Retorna .T. quando houve sucesso na ExecAuto
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890ExcAt(oModel)

Local aLinha			:= {}				//array que será passado com os valores no execauto para preencher a tabela PS2
Local aLinha2			:= {}
Local lRetorno		:= .T.				//validador de retorno, caso ocorra algum erro, ele retorna false, evitando que seja adicionado dados na tabela ABV
Local lAlter			:= .T.				// Será quem definirá se houve ou não alteração em alguma linha do grid
Local nCntFor			:= 0
Local aArea			:= GetArea()		//Pega posição GetArea()
Local aSaveLines		:= FWSaveRows()
Local aDados			:= {}
Local oModelTFS		:= oModel:GetModel("TFSGRID")
Local oModelTFT		:= oModel:GetModel("TFTGRID")
Local oMdlTFL 		:= oModel:GetModel('TFLMASTER')
Local cCodTWZ			:= ""
Local lCntRec			:= oMdlTFL:GetValue("TFL_CNTREC") == "1"
Local lTecEntCtb 		:= FindFunction("TecEntCtb") .And. TecEntCtb("TFT") .And. TecEntCtb("TFS")
Local aCab := {}
Local aItens := {}
Local cNumero := ""
Local cPrdTFS := ""
Local cQtdTFS := "" 
Local cLocTFS := ""
Local dEmiTFS := ""
Local cPrdTFT := ""
Local cQtdTFT := "" 
Local cLocTFT := ""
Local dEmiTFT := ""
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local lTFTCampo := (TFT->(ColumnPos("TFT_CODSA"))>0)
Local lTFSCampo := (TFS->(ColumnPos("TFS_CODSA"))>0)
Local lBarra    := .T.

Private lMsErroHelp := .T.
Private lMsErroAuto 	:= .F. 			// Informa a ocorrência de erros no ExecAuto
Private INCLUI 		:= .T. 			// Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
Private ALTERA 		:= .F. 			// Variavel necessária para o ExecAuto identificar que se trata de uma alteração

For nCntFor := 1 To oModelTFS:Length()											//Percorrerá todo grid do material Operacional
	aLinha2:={}
	aLinha:={}
	oModelTFS:GoLine(nCntFor)				
	aSaveLines	:= FWSaveRows()
	aDados	:= aClone(oModelTFS:GetOldData())
	If Empty(oModelTFS:GetValue("TFS_ITAPUR"))											// Verifica se o apontamento ainda não foi apurado
		If (!oModelTFS:IsDeleted() .AND. !Empty(oModelTFS:GetValue("TFS_CODTFG")))		//	Verifica se é uma linha deletada e se tem código de apontamento
			//Apontamento antigo
			If !(lGsApmat .And. lTFSCampo )
				aadd(aLinha,{"D3_FILIAL"    ,xFilial("SD3")			,NIL})		//	aLinha array que será enviado pelo execauto MATA240
				aadd(aLinha,{"D3_TM"     	,oModelTFS:GetValue("TFS_TM")/*aDados[2][nCntFor][13]*/	,NIL})
				aadd(aLinha,{"D3_COD"     	,oModelTFS:GetValue("TFS_PRODUT")/*aDados[2][nCntFor][4]*/ 	,NIL})
				aadd(aLinha,{"D3_QUANT"     ,oModelTFS:GetValue("TFS_QUANT")/*aDados[2][nCntFor][6] 	*/,NIL})
				aadd(aLinha,{"D3_LOCAL"		,oModelTFS:GetValue("TFS_LOCAL")/*aDados[2][nCntFor][8]*/ 	,NIL})
				aadd(aLinha,{"D3_LOCALIZ"   ,oModelTFS:GetValue("TFS_LOCALI")/*aDados[2][nCntFor][9]*/ 	,NIL})
				aadd(aLinha,{"D3_CC"      	,oModelTFS:GetValue("TFS_CC")/*aDados[2][nCntFor][7]*/	,NIL})
				If lTecEntCtb
					aadd(aLinha,{"D3_CONTA"     ,oModelTFS:GetValue("TFS_CONTA")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_ITEMCTA"   ,oModelTFS:GetValue("TFS_ITEM")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_CLVL"      ,oModelTFS:GetValue("TFS_CLVL")/*aDados[2][nCntFor][7]*/		,NIL})
				Endif
				aadd(aLinha,{"D3_LOTECTL"   ,oModelTFS:GetValue("TFS_LOTECT")/*aDados[2][nCntFor][10]*/ ,NIL})
				aadd(aLinha,{"D3_NUMLOTE"   ,oModelTFS:GetValue("TFS_NUMLOT")/*aDados[2][nCntFor][11]*/ ,NIL})
				aadd(aLinha,{"D3_NUMSERI"   ,oModelTFS:GetValue("TFS_NUMSER")/*aDados[2][nCntFor][12]*/ ,NIL})			
				FwRestRows(aSaveLines)
			Endif
			// Verifica se a linha do apontamento do material operacional possui movimentação	
			If (!(lGsApmat .And. lTFSCampo) .And. !Empty(oModelTFS:GetValue("TFS_NUMMOV")/*aDados[2][nCntFor][14]*/) .Or.;
			 	(lGsApmat .And. lTFSCampo .And. !Empty(oModelTFS:GetValue("TFS_CODSA"))))
				//Apontamento antigo
				If !(lGsApmat .And. lTFSCampo)
					aadd(aLinha,{"D3_NUMSEQ"   ,oModelTFS:GetValue("TFS_NUMMOV")/*aDados[2][nCntFor][14]*/ ,NIL})
				Endif
				DbSelectArea("TFS")
				TFS->(DbSetOrder(1))
				If TFS->(DbSeek(xFilial("TFS")+oModelTFS:GetValue("TFS_CODIGO")/*aDados[2][nCntFor][2]*/))		//Verifica se a linha teve alteração
					//Apontamento antigo
					If !(lGsApmat .And. lTFSCampo) 
						aLinha2:={}													//array que receberá o valores da tabela para comparação com o linha atual
						aadd(aLinha2,{TFS->TFS_FILIAL		})		
						aadd(aLinha2,{TFS->TFS_TM			})
						aadd(aLinha2,{TFS->TFS_PRODUT		})
						aadd(aLinha2,{TFS->TFS_QUANT		})
						aadd(aLinha2,{TFS->TFS_LOCAL	 	})
						aadd(aLinha2,{TFS->TFS_LOCALI	 	})
						aadd(aLinha2,{TFS->TFS_CC			})
						If lTecEntCtb
							aadd(aLinha2,{TFS->TFS_CONTA })
							aadd(aLinha2,{TFS->TFS_ITEM  })
							aadd(aLinha2,{TFS->TFS_CLVL  })
						Endif
						aadd(aLinha2,{TFS->TFS_LOTECT	 	})
						aadd(aLinha2,{TFS->TFS_NUMLOT	 	}) 
						aadd(aLinha2,{TFS->TFS_NUMSER	 	})
						aadd(aLinha2,{TFS->TFS_NUMMOV	 	})		
						lAlter	:=	At890Alt(aLinha2, aLinha)
					Else
						lAlter  := TFS->TFS_QUANT != oModelTFS:GetValue("TFS_QUANT") 
					Endif
				EndIf
				If lAlter															//Verifica se a linha sofreu alteração
					If !(lGsApmat .And. lTFSCampo) 
						DbSelectArea("SD3")
						DbSetOrder(6)
						If SD3->(DbSeek(xFilial("SD3")+Dtos(oModelTFS:GetValue("TFS_DTAPON")/*aDados[2][nCntFor][15]*/)+ oModelTFS:GetValue("TFS_NUMMOV")/*aDados[2][nCntFor][14]*/))
							aadd(aLinha,{"D3_EMISSAO"   ,SD3->D3_EMISSAO ,NIL})
							aadd(aLinha,{"INDEX"			,6						, NIL})
							MATA240(aLinha,5)											// Quando teve alteração a movimentação atual será extornada.
							If !lMsErroAuto
								DbSelectArea("TFS")
								DbSetOrder(1)
								If TFS->(DbSeek(xFilial("TFS")+FWFLDGET("TFS_CODIGO")))
									lRetorno	:=	At890Extrn(TFS->TFS_QUANT, "TFG", TFS->TFS_CODTFG)
								EndIf
								If lRetorno

									At995ExcC(oMdlTFL:GetValue("TFL_CODPAI"),TFS->TFS_CODTWZ)

									aLinha[12][2]:= TFS->TFS_NUMLOT

									MATA240(aLinha,3)	// Depois do movimento ter sido extornado ele irá gerar uma nova movimentação
									If !lMsErroAuto
										lRetorno	:=	At890Apont(FWFLDGET("TFS_QUANT"), "TFG", FWFLDGET("TFS_CODTFG"))
										If lRetorno
											ConOut(STR0013) //"Inclusao com sucesso!"
											oModelTFS:GoLine(nCntFor)
											oModelTFS:LoadValue("TFS_NUMMOV",SD3->D3_NUMSEQ)
											oModelTFS:LoadValue("TFS_DTAPON",dDataBase)
											cCodTWZ := At995Custo(oMdlTFL:GetValue("TFL_CODPAI"),;
																oModelTFS:GetValue("TFS_CODTFG"),;
																oMdlTFL:GetValue("TFL_CODIGO"),;
																oModelTFS:GetValue("TFS_PRODUT"),;
																"2",SD3->D3_CUSTO1,"TECA890")
											If !Empty(cCodTWZ)
												oModelTFS:LoadValue("TFS_CODTWZ",cCodTWZ)
											EndIf
										EndIf
									Else
										ConOut(STR0014) //"Erro na inclusao!"
										If !isBlind()
											MostraErro()
										EndIf
										lRetorno	:=	.F.
									EndIf
								EndIf
							Else
								ConOut(STR0015) //"Erro na Alteração!"
								MostraErro()
								lRetorno	:=	.F.
							EndIf
						EndIf
					Else
						If oModelTFS:GetValue("TFS_QUANT") <> 0
							Begin Transaction

								MsgRun(STR0172, STR0173, {||lBarra}) //"Alterando Solicitação ao Armazem"#"Processando Solicitação"

								cNumero	    := TFS->TFS_CODSA // Numero da SA que vai ser alterada 

								DbSelectArea("SCP")
								SCP->(DbSetorder(1))

								cPrdTFS     := oModelTFS:GetValue("TFS_PRODUT") 
								cQtdTFS     := oModelTFS:GetValue("TFS_QUANT")
								cLocTFS     := oModelTFS:GetValue("TFS_LOCAL")
								dEmiTFS     := oModelTFS:GetValue("TFS_DTAPON")
								cUM         := Posicione("SB1",1,xFilial("SB1")+cPrdTFS,"B1_UM")
						
								Aadd( aCab, { "CP_NUM"                  ,cNumero                       , nil })	
								Aadd( aCab, { "CP_EMISSAO"              ,dEmiTFS                       , nil })

								Aadd(aItens,{})

								Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,cValtoChar(StrZero(nCntFor,2)) ,nil})
								Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,Alltrim(cPrdTFS)               ,nil})
								Aadd(aItens[Len(aItens)],{"CP_UM"      ,cUM                            ,nil})
								Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,cQtdTFS                        ,nil})
								Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,dEmiTFS                        ,nil})
								Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,cLocTFS                        ,nil})
								Aadd(aItens[Len(aItens)],{"AUTDELETA" ,'N'                             ,nil })

								MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 4 )

								If lMsErroAuto
									MostraErro()
									DisarmTransaction()
									lRetorno := .F.
								Else
									aItens := {}
									aCab   := {}								
									DbSelectArea("TFS")
									TFS->(DbSetOrder(1))
									If TFS->(DbSeek(xFilial("TFS")+oModelTFS:GetValue("TFS_CODIGO")))
										lRetorno	:=	At890Extrn(TFS->TFS_QUANT, "TFG", TFS->TFS_CODTFG)
										lRetorno	:=	lRetorno .And. At890Apont(oModelTFS:GetValue("TFS_QUANT"), "TFG", oModelTFS:GetValue("TFS_CODTFG"))
									EndIf
								EndIf

							End Transaction
						Endif
					Endif
				Endif
			Else	
				//Inclusão
				If !(lGsApmat .And. lTFSCampo )
			    	MATA240(aLinha,3) //Se for a primeira inclusão irá gerar a movimentação
					If !lMsErroAuto
						lRetorno	:=	At890Apont(FWFLDGET("TFS_QUANT"), "TFG", FWFLDGET("TFS_CODTFG"))
						If lRetorno
							ConOut(STR0013) //"Inclusao com sucesso! "
							oModelTFS:GoLine(nCntFor)
							oModelTFS:LoadValue("TFS_NUMMOV",SD3->D3_NUMSEQ)
							cCodTWZ := At995Custo(oMdlTFL:GetValue("TFL_CODPAI"),;
												oModelTFS:GetValue("TFS_CODTFG"),;
												oMdlTFL:GetValue("TFL_CODIGO"),;
												oModelTFS:GetValue("TFS_PRODUT"),;
												"2",SD3->D3_CUSTO1,"TECA890")
							If !Empty(cCodTWZ)
								oModelTFS:LoadValue("TFS_CODTWZ",cCodTWZ)
							EndIf
						EndIf
					Else
						ConOut(STR0014) //"Erro na inclusao!"
						MostraErro()
						lRetorno	:=	.F.
					EndIf
				Else
					If Empty(oModelTFS:GetValue("TFS_CODSA")) .And. oModelTFS:GetValue("TFS_QUANT") <> 0 .And. oModelTFS:IsInserted()

						MsgRun(STR0174, STR0173, {||lBarra}) //"Processando Solicitação"#"Gerando Solicitação ao Armazem"
						
						Begin Transaction 

							cNumero  := At890INum('SCP', 'CP_NUM', 1)

							dbSelectArea('SCP')
							SCP->( dbSetOrder(1))

							cPrdTFS     := oModelTFS:GetValue("TFS_PRODUT")
							cQtdTFS     := oModelTFS:GetValue("TFS_QUANT")
							cLocTFS     := oModelTFS:GetValue("TFS_LOCAL")
							dEmiTFS     := oModelTFS:GetValue("TFS_DTAPON")
							cUM         := Posicione("SB1",1,xFilial("SB1")+cPrdTFS,"B1_UM")

							Aadd( aCab  , { "CP_NUM"                  ,cNumero                       ,nil})	
							Aadd( aCab  , { "CP_EMISSAO"              ,dEmiTFS                       ,nil})

							Aadd(aItens,{})

							Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,cValtoChar(StrZero(nCntFor,2)) ,nil})
							Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,Alltrim(cPrdTFS)               ,nil})
							Aadd(aItens[Len(aItens)],{"CP_UM"      ,cUM                            ,nil})
							Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,cQtdTFS                        ,nil})
							Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,dEmiTFS                        ,nil})
							Aadd(aItens[Len(aItens)],{"CP_LOCAL"  ,cLocTFS                         ,nil})

							MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 3 )

							if lMsErroAuto
								MostraErro()
								DisarmTransaction()
								lRetorno := .F.
							else
								oModelTFS:LoadValue('TFS_CODSA',cNumero) // Inclui o numero da SA na tabela TFS apos a inclusão
								aItens := {}
								aCab   := {}
								lRetorno :=	At890Apont(oModelTFS:GetValue("TFS_QUANT"), "TFG", oModelTFS:GetValue("TFS_CODTFG"))
							EndIf

						End Transaction
					Endif	
				Endif	
			EndIf	
		Else
			//Se for um delete
			///tratamento de extorno por delete
			If !(lGsApmat .And. lTFSCampo ) .And. !Empty(oModelTFS:GetValue("TFS_NUMMOV")/*aDados[2][nCntFor][14]*/) .AND. !Empty(oModelTFS:GetValue("TFS_CODTFG")/*aDados[2][nCntFor][3]*/)//Valida se é uma linha que já possuia movimentação

				aadd(aLinha,{"D3_FILIAL"    ,xFilial("SD3")														,NIL})		
				aadd(aLinha,{"D3_TM"     	,oModelTFS:GetValue("TFS_TM")/*aDados[2][nCntFor][13]*/			,NIL})
				aadd(aLinha,{"D3_COD"     	,oModelTFS:GetValue("TFS_PRODUT")/*aDados[2][nCntFor][4]*/ 		,NIL})
				aadd(aLinha,{"D3_QUANT"     ,oModelTFS:GetValue("TFS_QUANT")/*aDados[2][nCntFor][6] 	*/	,NIL})
				aadd(aLinha,{"D3_LOCAL"		,oModelTFS:GetValue("TFS_LOCAL")/*aDados[2][nCntFor][8]*/ 		,NIL})
				aadd(aLinha,{"D3_LOCALIZ"   ,oModelTFS:GetValue("TFS_LOCALI")/*aDados[2][nCntFor][9]*/ 		,NIL})
				aadd(aLinha,{"D3_CC"      	,oModelTFS:GetValue("TFS_CC")/*aDados[2][nCntFor][7]*/			,NIL})
				If lTecEntCtb
					aadd(aLinha,{"D3_CONTA"     ,oModelTFS:GetValue("TFS_CONTA")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_ITEMCTA"   ,oModelTFS:GetValue("TFS_ITEM")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_CLVL"      ,oModelTFS:GetValue("TFS_CLVL")/*aDados[2][nCntFor][7]*/		,NIL})
				Endif
				aadd(aLinha,{"D3_LOTECTL"   ,oModelTFS:GetValue("TFS_LOTECT")/*aDados[2][nCntFor][10]*/		,NIL})
				aadd(aLinha,{"D3_NUMLOTE"   ,oModelTFS:GetValue("TFS_NUMLOT")/*aDados[2][nCntFor][11]*/		,NIL})
				aadd(aLinha,{"D3_NUMSERI"   ,oModelTFS:GetValue("TFS_NUMSER")/*aDados[2][nCntFor][12]*/		,NIL})	
				aadd(aLinha,{"D3_NUMSEQ"    ,oModelTFS:GetValue("TFS_NUMMOV")/*aDados[2][nCntFor][14]*/		,NIL})
				DbSelectArea("SD3")
				DbSetOrder(6)
				If SD3->(DbSeek(xFilial("SD3")+Dtos(oModelTFS:GetValue("TFS_DTAPON")/*aDados[2][nCntFor][15]*/)+ oModelTFS:GetValue("TFS_NUMMOV")/*aDados[2][nCntFor][14]*/))	//Posiciona na movimentação
					aadd(aLinha,{"D3_EMISSAO"   ,SD3->D3_EMISSAO ,NIL})										//recebe no array a data de movimentação
					aadd(aLinha,{"INDEX"			,6					, NIL})
					MATA240(aLinha,5)		//Executa extorno da movimentação
					If !lMsErroAuto
						DbSelectArea("TFS")
						DbSetOrder(1)
						If TFS->(DbSeek(xFilial("TFS")+FWFLDGET("TFS_CODIGO")))
							lRetorno	:=	At890Extrn(TFS->TFS_QUANT, "TFG", TFS->TFS_CODTFG)
							If lRetorno
								At995ExcC(oMdlTFL:GetValue("TFL_CODPAI"),TFS->TFS_CODTWZ)
							EndIf
						EndIf
						ConOut(STR0016) //"Estorno com sucesso!"
					Else
						ConOut(STR0017) //"Erro no Estorno!"
						MostraErro()
						lRetorno	:=	.F.
					EndIf
				EndIf
			
			ElseIf lGsApmat .And. lTFSCampo .And. !Empty(oModelTFS:GetValue("TFS_CODSA")) .And.;
				!Empty(oModelTFS:GetValue("TFS_CODTFG")) .And. oModelTFS:GetValue("TFS_QUANT") <> 0

				MsgRun(STR0174, STR0187, {||lBarra}) //"Excluindo Solicitação ao Armazem"
				
				Begin Transaction 

					dbSelectArea('SCP')
					SCP->( dbSetOrder(1))

					Aadd( aCab  , { "CP_NUM"	,oModelTFS:GetValue('TFS_CODSA'),nil})	
					Aadd( aCab  , { "CP_EMISSAO",oModelTFS:GetValue("TFS_DTAPON"),nil})

					Aadd(aItens,{})

					Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,cValtoChar(StrZero(nCntFor,2)) ,nil})
					Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,Alltrim(oModelTFS:GetValue("TFS_PRODUT")),nil})
					Aadd(aItens[Len(aItens)],{"CP_UM"      ,Posicione("SB1",1,xFilial("SB1")+oModelTFS:GetValue("TFS_PRODUT"),"B1_UM"),nil})
					Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,oModelTFS:GetValue("TFS_QUANT"),nil})
					Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,oModelTFS:GetValue("TFS_DTAPON"),nil})
					Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,oModelTFS:GetValue("TFS_LOCAL"),nil})

					MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 5 )

					if lMsErroAuto
						MostraErro()
						DisarmTransaction()
						lRetorno := .F.
					else
						aItens := {}
						aCab   := {}
						DbSelectArea("TFS")
						TFS->(DbSetOrder(1))
						If TFS->(DbSeek(xFilial("TFS")+oModelTFS:GetValue("TFS_CODIGO")))
							lRetorno	:=	At890Extrn(TFS->TFS_QUANT, "TFG", TFS->TFS_CODTFG)
						Endif
					EndIf
				End Transaction
			Endif
		EndIf
		aLinha := {}
	Else		//Se a linha foi deletada e já foi apurado.
		oModelTFS:UnDeleteLine()
	EndIf
	FwRestRows( aSaveLines )	
Next nCntFor

For nCntFor := 1 To oModelTFT:Length()									//Percorrerá todo grid do material Operacional
	aLinha2:={}
	aLinha:={}
	oModelTFT:GoLine(nCntFor)
	aSaveLines	:= FWSaveRows()
	aDados	:= aClone(oModelTFT:GetOldData())
	If Empty(oModelTFT:GetValue("TFT_ITAPUR")/*aDados[2][nCntFor][16]*/)									//Verifica se ja foi apurado
		If (!oModelTFT:IsDeleted() .AND. !Empty(oModelTFT:GetValue("TFT_CODTFH")/*aDados[2][nCntFor][3]*/))
			If !(lGsApmat .And. lTFTCampo )
				aadd(aLinha,{"D3_FILIAL"    ,xFilial("SD3")														,NIL})		
				aadd(aLinha,{"D3_TM"     	,oModelTFT:GetValue("TFT_TM")/*aDados[2][nCntFor][13]*/			,NIL})
				aadd(aLinha,{"D3_COD"     	,oModelTFT:GetValue("TFT_PRODUT")/*aDados[2][nCntFor][4]*/ 		,NIL})
				aadd(aLinha,{"D3_QUANT"     ,oModelTFT:GetValue("TFT_QUANT")/*aDados[2][nCntFor][6]*/ 		,NIL})
				aadd(aLinha,{"D3_LOCAL"		,oModelTFT:GetValue("TFT_LOCAL")/*aDados[2][nCntFor][8]*/ 		,NIL})
				aadd(aLinha,{"D3_LOCALIZ"   ,oModelTFT:GetValue("TFT_LOCALI")/*aDados[2][nCntFor][9]*/ 		,NIL})
				aadd(aLinha,{"D3_CC"      	,oModelTFT:GetValue("TFT_CC")/*aDados[2][nCntFor][7]*/			,NIL})
				If lTecEntCtb
					aadd(aLinha,{"D3_CONTA"     ,oModelTFT:GetValue("TFT_CONTA")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_ITEMCTA"   ,oModelTFT:GetValue("TFT_ITEM")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_CLVL"      ,oModelTFT:GetValue("TFT_CLVL")/*aDados[2][nCntFor][7]*/		,NIL})
				Endif
				aadd(aLinha,{"D3_LOTECTL"   ,oModelTFT:GetValue("TFT_LOTECT")/*aDados[2][nCntFor][10]*/		,NIL})
				aadd(aLinha,{"D3_NUMLOTE"   ,oModelTFT:GetValue("TFT_NUMLOT")/*aDados[2][nCntFor][11]*/		,NIL})
				aadd(aLinha,{"D3_NUMSERI"   ,oModelTFT:GetValue("TFT_NUMSER")/*aDados[2][nCntFor][12]*/		,NIL})	
			Endif
			If (!(lGsApmat .And. lTFTCampo) .And. !Empty(oModelTFT:GetValue("TFT_NUMMOV")/*aDados[2][nCntFor][14]*/) .Or.;
			 	(lGsApmat .And. lTFTCampo .And. !Empty(oModelTFT:GetValue("TFT_CODSA"))))
				If !(lGsApmat .And. lTFTCampo)
					aadd(aLinha,{"D3_NUMSEQ"   ,oModelTFT:GetValue("TFT_NUMMOV")/*aDados[2][nCntFor][14]*/ ,NIL})
				Endif
				DbSelectArea("TFT")
				TFT->(DbSetOrder(1))
				If TFT->(DbSeek(xFilial("TFT")+ oModelTFT:GetValue("TFT_CODIGO")/*aDados[2][nCntFor][2]*/)) //busca TFT pelo código
					If !(lGsApmat .And. lTFTCampo)
						aLinha2:={}
						aadd(aLinha2,{TFT->TFT_FILIAL		})		
						aadd(aLinha2,{TFT->TFT_TM			})
						aadd(aLinha2,{TFT->TFT_PRODUT		})
						aadd(aLinha2,{TFT->TFT_QUANT		})
						aadd(aLinha2,{TFT->TFT_LOCAL	 	})
						aadd(aLinha2,{TFT->TFT_LOCALI	 	})
						aadd(aLinha2,{TFT->TFT_CC			})
						If lTecEntCtb
							aadd(aLinha2,{TFT->TFT_CONTA })
							aadd(aLinha2,{TFT->TFT_ITEM  })
							aadd(aLinha2,{TFT->TFT_CLVL  })
						Endif
						aadd(aLinha2,{TFT->TFT_LOTECT	 	})
						aadd(aLinha2,{TFT->TFT_NUMLOT	 	})
						aadd(aLinha2,{TFT->TFT_NUMSER	 	})	
						aadd(aLinha2,{TFT->TFT_NUMMOV	 	})	
						lAlter	:=	At890Alt(aLinha2, aLinha)					//Se houve alteração 
					Else
						lAlter := TFT->TFT_QUANT != oModelTFT:GetValue("TFT_QUANT") 
					Endif
				EndIf
				If lAlter
					If !lGsApmat .And. lTFTCampo  
						DbSelectArea("SD3")
						DbSetOrder(6)
						If SD3->(DbSeek(xFilial("SD3")+Dtos(oModelTFT:GetValue("TFT_DTAPON")/*aDados[2][nCntFor][15]*/)+ oModelTFT:GetValue("TFT_NUMMOV")/*aDados[2][nCntFor][14]*/))
							aadd(aLinha,{"D3_EMISSAO"   ,SD3->D3_EMISSAO,			NIL})
							aadd(aLinha,{"INDEX"			,6,							NIL})
							MATA240(aLinha,5)
							If !lMsErroAuto
								DbSelectArea("TFT")
								DbSetOrder(1)
								If TFT->(DbSeek(xFilial("TFT")+FWFLDGET("TFT_CODIGO")))
									lRetorno	:=	At890Extrn(TFT->TFT_QUANT, "TFH", TFT->TFT_CODTFH, lCntRec)
								EndIf
								If lRetorno
									At995ExcC(oMdlTFL:GetValue("TFL_CODPAI"),TFT->TFT_CODTWZ)
									aLinha[12][2]:=TFT->TFT_NUMLOT
									MATA240(aLinha,3)	
									If !lMsErroAuto
										lRetorno	:=	At890Apont(FWFLDGET("TFT_QUANT"), "TFH", FWFLDGET("TFT_CODTFH"), lCntRec)
										If lRetorno
											ConOut(STR0013) //"Inclusao com sucesso!"
											oModelTFT:GoLine(nCntFor)
											oModelTFT:LoadValue("TFT_NUMMOV",SD3->D3_NUMSEQ)
											oModelTFT:LoadValue("TFT_DTAPON",dDataBase)
											cCodTWZ := At995Custo(oMdlTFL:GetValue("TFL_CODPAI"),;
														oModelTFT:GetValue("TFT_CODTFH"),;
														oMdlTFL:GetValue("TFL_CODIGO"),;
														oModelTFT:GetValue("TFT_PRODUT"),;
														"3",SD3->D3_CUSTO1,"TECA890")
											If !Empty(cCodTWZ)
												oModelTFT:LoadValue("TFT_CODTWZ",cCodTWZ)
											EndIf
										EndIf
									Else
										ConOut(STR0014) //"Erro na inclusão!"
										MostraErro()
										lRetorno	:=	.F.
									EndIf
								EndIf
							Else
								ConOut(STR0015) //"Erro na Alteração!"
								MostraErro()
								lRetorno	:=	.F.
							EndIf
						EndIf
					Else
						If oModelTFT:GetValue("TFT_QUANT") <> 0

							MsgRun(STR0172, STR0173, {||lBarra})

							Begin Transaction

								dbSelectArea('SCP')
								SCP->( dbSetOrder(1))

								    cNumero 	:= TFT->TFT_CODSA // Numero da SA que vai ser alterada 
									cPrdTFT     := oModelTFT:GetValue("TFT_PRODUT")
									cQtdTFT     := oModelTFT:GetValue("TFT_QUANT")
									cLocTFT     := oModelTFT:GetValue("TFT_LOCAL")
									dEmiTFT     := oModelTFT:GetValue("TFT_DTAPON")
									cUM         := Posicione("SB1",1,xFilial("SB1")+cPrdTFT,"B1_UM")
									
										
									Aadd( aCab, { "CP_NUM"                  ,cNumero                       , nil })	
									Aadd( aCab, { "CP_EMISSAO"              ,dEmiTFT                       , nil })

									Aadd(aItens,{})

									Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,cValtoChar(StrZero(nCntFor,2)) ,nil})
									Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,Alltrim(cPrdTFT)               ,nil})
									Aadd(aItens[Len(aItens)],{"CP_UM"      ,cUM                            ,nil})
									Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,cQtdTFT                        ,nil})
									Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,dEmiTFT                        ,nil})
									Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,cLocTFT                        ,nil})

									MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 4 )

									If lMsErroAuto
										MostraErro()
										lRetorno := .F.
										DisarmTransaction()
									Else
										oModelTFT:LoadValue('TFT_CODSA',cNumero) // Inclui o numero da SA	
										aItens := {}
										DbSelectArea("TFT")
										TFT->(DbSetOrder(1))
										If TFT->(DbSeek(xFilial("TFT")+oModelTFT:GetValue("TFT_CODIGO")))
											lRetorno	:=	At890Extrn(TFT->TFT_QUANT, "TFH", TFT->TFT_CODTFH,lCntRec)
											lRetorno	:=	lRetorno .And. At890Apont(oModelTFT:GetValue("TFT_QUANT"), "TFH", oModelTFT:GetValue("TFT_CODTFH"),lCntRec)
										EndIf
									EndIf

							End Transaction
						Endif						
					Endif
				EndIf
			Else
				If !(lGsApmat .And. lTFTCampo)  
					MATA240(aLinha,3)
					If !lMsErroAuto
						lRetorno	:=	At890Apont(oModelTFT:GetValue("TFT_QUANT"), "TFH", oModelTFT:GetValue("TFT_CODTFH"), lCntRec)
						If lRetorno
							ConOut(STR0013) //"Inclusao com sucesso!"
							oModelTFT:GoLine(nCntFor)
							oModelTFT:LoadValue("TFT_NUMMOV",SD3->D3_NUMSEQ)
							cCodTWZ := At995Custo(oMdlTFL:GetValue("TFL_CODPAI"),;
										oModelTFT:GetValue("TFT_CODTFH"),;
										oMdlTFL:GetValue("TFL_CODIGO"),;
										oModelTFT:GetValue("TFT_PRODUT"),;
										"3",SD3->D3_CUSTO1,"TECA890")
							If !Empty(cCodTWZ)
								oModelTFT:LoadValue("TFT_CODTWZ",cCodTWZ)
							EndIf
						EndIf
					Else
						ConOut(STR0014) //"Erro na inclusão!"
						If !isBlind()
							MostraErro()
						EndIf
						lRetorno	:=	.F.
					EndIf		
				Else
					If Empty(oModelTFT:GetValue("TFT_CODSA")) .And. oModelTFT:GetValue("TFT_QUANT") <> 0  .And. oModelTFT:IsInserted()

						MsgRun(STR0174, STR0173, {||lBarra}) //"Processando Solicitação"#"Gerando Solicitação ao Armazem"

						Begin Transaction

							cNumero	    := At890INum('SCP', 'CP_NUM', 1)
							
							dbSelectArea('SCP')
							SCP->( dbSetOrder(1))

							cPrdTFT     := oModelTFT:GetValue("TFT_PRODUT")
							cQtdTFT     := oModelTFT:GetValue("TFT_QUANT")
							cLocTFT     := oModelTFT:GetValue("TFT_LOCAL")
							dEmiTFT     := oModelTFT:GetValue("TFT_DTAPON")
							cUM         := Posicione("SB1",1,xFilial("SB1")+cPrdTFT,"B1_UM")				
								
							Aadd( aCab, { "CP_NUM"                  ,cNumero ,nil })	
							Aadd( aCab, { "CP_EMISSAO"              ,dEmiTFT ,nil })
							Aadd(aItens,{})
							Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,cValtoChar(StrZero(nCntFor,2)) ,nil})
							Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,Alltrim(cPrdTFT) ,nil})
							Aadd(aItens[Len(aItens)],{"CP_UM"      ,cUM ,nil})
							Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,cQtdTFT ,nil})
							Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,dEmiTFT ,nil})
							Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,cLocTFT ,nil})

							MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 3 )

							if lMsErroAuto
								MostraErro()
								lRetorno := .F.
								DisarmTransaction()
							else
								oModelTFT:LoadValue('TFT_CODSA',cNumero) // Inclui o numero da SA
								aCab   := {}	
								aItens := {}
								lRetorno := At890Apont(oModelTFT:GetValue("TFT_QUANT"), "TFH", oModelTFT:GetValue("TFT_CODTFH"),lCntRec)
							EndIf
						End Transaction
					Endif	
				Endif
			EndIf
		Else
		///tratar extorno aqui.
			If !(lGsApmat .And. lTFTCampo ) .And. !Empty(oModelTFT:GetValue("TFT_NUMMOV")/*aDados[2][nCntFor][14]*/) .AND. !Empty(oModelTFT:GetValue("TFT_CODTFH")/*aDados[2][nCntFor][3]*/)
				aadd(aLinha,{"D3_FILIAL"    ,xFilial("SD3")													,NIL})		
				aadd(aLinha,{"D3_TM"     	,oModelTFT:GetValue("TFT_TM")/*aDados[2][nCntFor][13]*/		,NIL})
				aadd(aLinha,{"D3_COD"     	,oModelTFT:GetValue("TFT_PRODUT")/*aDados[2][nCntFor][4]*/ 	,NIL})
				aadd(aLinha,{"D3_QUANT"     ,oModelTFT:GetValue("TFT_QUANT")/*aDados[2][nCntFor][6]*/ 	,NIL})
				aadd(aLinha,{"D3_LOCAL"		,oModelTFT:GetValue("TFT_LOCAL")/*aDados[2][nCntFor][8]*/ 	,NIL})
				aadd(aLinha,{"D3_LOCALIZ"   ,oModelTFT:GetValue("TFT_LOCALI")/*aDados[2][nCntFor][9]*/ 	,NIL})
				aadd(aLinha,{"D3_CC"      	,oModelTFT:GetValue("TFT_CC")/*aDados[2][nCntFor][7]*/		,NIL})
				If lTecEntCtb
					aadd(aLinha,{"D3_CONTA"     ,oModelTFT:GetValue("TFT_CONTA")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_ITEMCTA"   ,oModelTFT:GetValue("TFT_ITEM")/*aDados[2][nCntFor][7]*/		,NIL})
					aadd(aLinha,{"D3_CLVL"      ,oModelTFT:GetValue("TFT_CLVL")/*aDados[2][nCntFor][7]*/		,NIL})
				Endif
				aadd(aLinha,{"D3_LOTECTL"   ,oModelTFT:GetValue("TFT_LOTECT")/*aDados[2][nCntFor][10]*/ ,NIL})
				aadd(aLinha,{"D3_NUMLOTE"   ,oModelTFT:GetValue("TFT_NUMLOT")/*aDados[2][nCntFor][11]*/ ,NIL})
				aadd(aLinha,{"D3_NUMSERI"   ,oModelTFT:GetValue("TFT_NUMSER")/*aDados[2][nCntFor][12]*/ ,NIL})	
				aadd(aLinha,{"D3_NUMSEQ"   ,oModelTFT:GetValue("TFT_NUMMOV")/*aDados[2][nCntFor][14]*/ ,NIL})
				DbSelectArea("SD3")
				DbSetOrder(6)
				If SD3->(DbSeek(xFilial("SD3")+Dtos(oModelTFT:GetValue("TFT_DTAPON")/*aDados[2][nCntFor][15]*/)+ oModelTFT:GetValue("TFT_NUMMOV")/*aDados[2][nCntFor][14]*/))
					aadd(aLinha,{"D3_EMISSAO"   ,SD3->D3_EMISSAO 		,	NIL})
					aadd(aLinha,{"INDEX"			,6						,	NIL})
					MATA240(aLinha,5)
					If !lMsErroAuto
						DbSelectArea("TFT")
						DbSetOrder(1)
						If TFT->(DbSeek(xFilial("TFT")+FWFLDGET("TFT_CODIGO")))
							lRetorno	:=	At890Extrn(TFT->TFT_QUANT, "TFH", TFT->TFT_CODTFH, lCntRec)
							At995ExcC(oMdlTFL:GetValue("TFL_CODPAI"),TFT->TFT_CODTWZ)
						EndIf
						ConOut(STR0016) //"Estorno com sucesso!"
					Else
						ConOut(STR0017) //"Erro no Estorno!"
						MostraErro()
						lRetorno	:=	.F.
					EndIf
				EndIf
			ElseIf lGsApmat .And. lTFTCampo .And. !Empty(oModelTFT:GetValue("TFT_CODSA")) .And.;
					!Empty(oModelTFT:GetValue("TFT_CODTFH")) .And. oModelTFT:GetValue("TFT_QUANT") <> 0

				MsgRun(STR0174, "Excluindo Solicitação ao Armazem", {||lBarra}) //"Processando Solicitação"#"Gerando Solicitação ao Armazem"
				
				Begin Transaction 

					dbSelectArea('SCP')
					SCP->( dbSetOrder(1))

					Aadd( aCab  , { "CP_NUM"	,oModelTFT:GetValue('TFT_CODSA'),nil})	
					Aadd( aCab  , { "CP_EMISSAO",oModelTFT:GetValue("TFT_DTAPON"),nil})

					Aadd(aItens,{})

					Aadd(aItens[Len(aItens)],{"CP_ITEM"    ,cValtoChar(StrZero(nCntFor,2)) ,nil})
					Aadd(aItens[Len(aItens)],{"CP_PRODUTO" ,Alltrim(oModelTFT:GetValue("TFT_PRODUT")),nil})
					Aadd(aItens[Len(aItens)],{"CP_UM"      ,Posicione("SB1",1,xFilial("SB1")+oModelTFT:GetValue("TFT_PRODUT"),"B1_UM"),nil})
					Aadd(aItens[Len(aItens)],{"CP_QUANT"   ,oModelTFT:GetValue("TFT_QUANT"),nil})
					Aadd(aItens[Len(aItens)],{"CP_DATPRF"  ,oModelTFT:GetValue("TFT_DTAPON"),nil})
					Aadd(aItens[Len(aItens)],{"CP_LOCAL"   ,oModelTFT:GetValue("TFT_LOCAL"),nil})

					MSExecAuto({|x,y,z| mata105(x,y,z)},aCab, aItens , 5 )

					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						lRetorno := .F.
					Else
						aItens := {}
						aCab   := {}
						DbSelectArea("TFT")
						TFT->(DbSetOrder(1))
						If TFT->(DbSeek(xFilial("TFT")+oModelTFT:GetValue("TFT_CODIGO")))
							lRetorno	:=	At890Extrn(TFT->TFT_QUANT, "TFH", TFT->TFT_CODTFH,lCntRec)
						Endif
					EndIf
				End Transaction			
			EndIf
		EndIf
		aLinha := {}
	Else
		oModelTFT:UnDeleteLine()
	EndIf
	FwRestRows( aSaveLines )	
Next nCntFor	 
RestArea(aArea)
Return (lRetorno)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890Apont

Realiza a Gravação dos dados utilizando a ExecAuto MATA240 para inclusão de apontamentos
no Modulo Estoque
@author  Serviços
@since 	  31/10/13
@version P11 R9
@param nQuApnt: Quantidade que se deseja apontar.
@param cAliasMat: O "alias" que se deseja, podendo ser da TFG para matériais operacionais e TFH para os matériais de Consumo.
@param cCodMat: Código do Material a ser apontado.

@return lRet: Retorna .T. quando o saldo do material foi suficiente para suprir a quantidade do apontamento.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890Apont(nQuApnt, cAliasMat, cCodMat, lCntRec)

Local aArea		:= GetArea()
Local nQuApont	:=	nQuApnt
Local cCodigo		:=	cCodMat
Local lRet			:= .F.
Default lCntRec		:= .F.

DbSelectArea(cAliasMat)
DbSetOrder(1)
If (cAliasMat)->(DbSeek(xFilial(cAliasMat)+cCodigo))
	If cAliasMat == "TFG" .AND. (cAliasMat)->TFG_SLD >= nQuApont
		RecLock(cAliasMat,.F.)
		(cAliasMat)->TFG_SLD	:=	(cAliasMat)->TFG_SLD - nQuApont
		MsUnlock()
		lRet:=.T.
	ElseIf cAliasMat == "TFH"		
		If !lCntRec .AND. (cAliasMat)->TFH_SLD >= nQuApont
			RecLock(cAliasMat,.F.)
				(cAliasMat)->TFH_SLD	:=	(cAliasMat)->TFH_SLD - nQuApont
			MsUnlock()
		Endif
		lRet:=.T.
	Else
		HELP(,,'Saldo',,STR0020)//"Saldo insuficiente para esta quantidade!"
		lRet:= .F.
	EndIf
EndIf
RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890Extrn

Realiza a Gravação dos dados utilizando a ExecAuto MATA240 para extorno de apontamentos
no Modulo Estoque
@author  Serviços
@since 	  31/10/13
@version P11 R9
@param nQuApnt: Quantidade que se deseja apontar.
@param cAliasMat: O "alias" que se deseja, podendo ser da TFG para matériais operacionais e TFH para os matériais de Consumo.
@param cCodMat: Código do Material a ser apontado.

@return lRet: Retorna .T. quando o extorno for realizado.
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At890Extrn(nQuApnt, cAliasMat, cCodMat, lCntRec )
Local aArea	:= GetArea()	
Local nQuApont	:=	nQuApnt
Local cCodigo		:=	cCodMat
Local lRet			:= .F.
Default lCntRec 	:= .F.

DbSelectArea(cAliasMat)
DbSetOrder(1)
If (cAliasMat)->(DbSeek(xFilial(cAliasMat)+cCodigo))
	If cAliasMat == "TFG"
		RecLock(cAliasMat,.F.)
		(cAliasMat)->TFG_SLD	:=	(cAliasMat)->TFG_SLD + nQuApont 	
		MsUnlock()
		lRet:=.T.
	ElseIf cAliasMat == "TFH"
		If !lCntRec
			RecLock(cAliasMat,.F.)
				(cAliasMat)->TFH_SLD	:=	(cAliasMat)->TFH_SLD + nQuApont
			MsUnlock()
		Endif
		lRet:=.T.
	EndIf
EndIf
RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890Alt

Realiza a Gravação dos dados utilizando a ExecAuto MATA240 para extorno de apontamentos
no Modulo Estoque
@author  Serviços
@since 	  31/10/13
@version P11 R9
@param aDdBnc: Array com informações do Banco
@param aDdGrid:Array com informações da linha do Grid

@return lRet: Retorna .T. quando encontrou valores diferentes nos arrays.
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At890Alt(aDdBnc, aDdGrid)//Teve alteração
Local nCont	:= 0
Local lRet	:= .F.
For nCont := 1 To Len(aDdBnc)
	If	aDdBnc[nCont][1]!=aDdGrid[nCont][2]
		lRet	:= .T.
	EndIf
Next nCont

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890GetLegend

Cria as informações referentes a legenda do grid de material de consumo.

@author  Serviços
@since 	  31/10/13
@version P11 R9
@return lRet: Retorna .T. quando a criação foi bem sucedida.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890GetLg()
Local	oLegenda := FwLegend():New()
Local   lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)

       If	lLegend   .And.  lGsApmat    
	           oLegenda:Add('','BR_BRANCO'     ,STR0175)//"Solicitação inicial" 
               oLegenda:Add('','BR_AMARELO'    ,STR0176)//	"Solicitação Gerada"           
               oLegenda:Add('','BR_VERDE'      ,STR0177)//  "Solicitação em análise"         
			   oLegenda:Add('','BR_PRETO'      ,STR0178) // "Solicitação atendida "              
			   oLegenda:Add('','BR_MARROM'     ,STR0179)//  "Solicitação parcialmente atendida "       
               oLegenda:Add('','BR_VERMELHO'   ,STR0180)//"Rejeitada"			               
               oLegenda:View()
               DelClassIntf()
		else
               oLegenda:Add('','GREEN',STR0021)	//"Apontamento não apurado"
               oLegenda:Add('','RED'  ,STR0022)	//"Apontamento Apurado"
               oLegenda:View()
               DelClassIntf()
       EndIf                                                                                                                                   
Return .T.


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890LgTFT

Atribui a cor verde nos apontamento do material de consumo que não foram apurados e vermelho no que já foram apurados.
@author  	Serviços
@since 	  	31/10/13
@version	P11 R9
@return 	br_verde para o apontamento que não foi apurado
@return 	br_vermelho par ao apontamento já apurado
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890LgTFT()

Local cCor       
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local cQry       := ""
Local cAliasTFT  := ""
Local cCodTFT    := ""
local cPreTFT    := ""
Local cStatus    := ""
Local nQuant     := 0
Local nQtdEnt    := 0
Local nQtdzero   := 0
Local lTFTCampo := (TFT->(ColumnPos("TFT_CODSA"))>0)

If lGsApmat .And. lTFTCampo

	cCor       := 'BR_BRANCO' // Inicial
	cAliasTFT  := GetNextAlias() 
	cCodTFT    := TFT->TFT_CODSA 

	cQry := " SELECT CP_PREREQU, CP_STATSA,CP_STATUS, CP_QUANT, CP_QUJE , CP_NUM, TFT_QUANT"
	cQry += " FROM  "+RetSqlName("TFL")+" TFL "
	cQry += " INNER JOIN  "+RetSqlName("TFT")+" TFT ON TFT_CODTFL = TFL_CODIGO AND TFT_FILIAL = '" +xFilial("TFT") +"'  "
	cQry += " INNER JOIN  "+RetSqlName("SCP")+" SCP ON CP_NUM     = TFT_CODSA  AND CP_FILIAL  = '" +xFilial("SCP") +"' "
	cQry += " WHERE SCP.D_E_L_E_T_ = '' AND TFT.D_E_L_E_T_ = '' AND TFL.D_E_L_E_T_ = '' "
	cQry += " AND TFL_FILIAL = '" +xFilial("TFL")+"' "
	cQry += " AND TFT_CODSA = '"+cCodTFT+"'"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFT,.T.,.T.)

	If (cAliasTFT)->(!Eof())

		cPreTFT := (cAliasTFT)->CP_PREREQU // Pre-requisição
		cStatus := (cAliasTFT)->CP_STATUS  // Status da SA
		nQuant  := (cAliasTFT)->CP_QUANT   // Quantidade solicitada
        nQtdEnt := (cAliasTFT)->CP_QUJE    // Quantidade atendida

        If  Empty(cPreTFT)  .And. Empty(cStatus) .And.  nQtdEnt == nQtdzero
			cCor := 'BR_AMARELO'
			Return cCor
		ElseIf !Empty(cPreTFT)  .And. Empty(cStatus) .aND. At890SCQ(cCodTFT) .And. nQtdEnt == nQtdzero
			cCor := 'BR_VERDE'
			Return cCor
		ElseIf  !Empty(cPreTFT) .And. cStatus == 'E' .And. At890Req(cCodTFT) .And. (nQuant == nQtdEnt)
			cCor := 'BR_PRETO'
			Return cCor
		ElseIf  !Empty(cPreTFT) .And. cStatus == 'E' 
			cCor := 'BR_VERMELHO'
			Return cCor
		ElseIf  !Empty(cPreTFT) .And.  Empty(cStatus) .And. (nQuant != nQtdEnt)
			cCor := 'BR_MARROM'
			Return cCor
		Endif	

	Endif

	(cAliasTFT)->(DbCloseArea())	
else
	If Empty(TFT->TFT_ITAPUR)
		cCor := 'br_verde'
	Else
		cCor := 'br_vermelho'
	EndIf
Endif		

Return cCor


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890LgTFS

Atribui a cor verde nos apontamento do material operacional que não foram apurados e vermelho no que já foram apurados.
@author 	Serviços
@since 		31/10/13
@version 	P11 R9
@return 	br_verde para o apontamento que não foi apurado
@return 	br_vermelho par ao apontamento já apurado
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890LgTFS()

Local cCor       
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local cQry       := ""
Local cAliasSCP  := ""
Local cCodTFS    := ""
local cPreTFS    := ""
local cStatus    := ""
Local nQuant     := 0
Local nQtdEnt    := 0
Local nQtdzero   := 0
Local lTFSCampo := (TFS->(ColumnPos("TFS_CODSA"))>0)

If lGsApmat .And. lTFSCampo

	cCor       := 'BR_BRANCO' 
	cAliasSCP := GetNextAlias()  
	cCodTFS  := TFS->TFS_CODSA

	cQry := " SELECT CP_PREREQU, CP_STATSA,CP_STATUS, CP_QUANT, CP_QUJE, TFS_CODTFG ,CP_NUM"
	cQry += " FROM  "+RetSqlName("TFL")+" TFL "
	cQry += " INNER JOIN  "+RetSqlName("TFS")+" TFS ON TFS_CODTFL = TFL_CODIGO AND TFS_FILIAL = '" +xFilial("TFS") +"'  "
	cQry += " INNER JOIN  "+RetSqlName("SCP")+" SCP ON CP_NUM     = TFS_CODSA  AND CP_FILIAL  = '" +xFilial("SCP") +"' "
	cQry += " WHERE SCP.D_E_L_E_T_ = '' AND TFS.D_E_L_E_T_ = '' AND TFL.D_E_L_E_T_ = '' "
	cQry += " AND TFL_FILIAL = '" +xFilial("TFL")+"' "
	cQry += " AND TFS_CODSA = '"+cCodTFS+"'"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSCP,.T.,.T.)

	If (cAliasSCP)->(!Eof())

		cPreTFS := (cAliasSCP)->CP_PREREQU // Pre-requisição
		cStatus := (cAliasSCP)->CP_STATUS  // Status da SA
		nQuant  := (cAliasSCP)->CP_QUANT   // Quantidade solicitada
        nQtdEnt := (cAliasSCP)->CP_QUJE   // Quantidade atendida

		If Empty(cPreTFS)  .And. Empty(cStatus) .And.  nQtdEnt == nQtdzero
			cCor := 'BR_AMARELO'
			Return cCor
		ElseIf !Empty(cPreTFS)  .And. Empty(cStatus) .And.  At890SCQ(cCodTFS) .And. nQtdEnt == nQtdzero
			cCor := 'BR_VERDE'
			Return cCor
		ElseIf  !Empty(cPreTFS) .And. cStatus == 'E' .And.  At890Req(cCodTFS) .And. (nQuant == nQtdEnt)
			cCor := 'BR_PRETO'
			Return cCor
		ElseIf  !Empty(cPreTFS) .And. cStatus == 'E' 
			cCor := 'BR_VERMELHO'
			Return cCor
		ElseIf  !Empty(cPreTFS) .And.  Empty(cStatus) .And. (nQuant != nQtdEnt)
			cCor := 'BR_MARROM'
			Return cCor
		Endif	   

	Endif

	(cAliasSCP)->(DbCloseArea())	

else
	If Empty(TFT->TFT_ITAPUR)
		cCor	:= 'br_verde'
	Else
		cCor	:=  'br_vermelho'
	EndIf
Endif		
Return cCor



//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890SdTFS()

Inicializador do campo Saldo do material operacional
@author 	Serviços
@since 		31/10/13
@version 	P11 R9
@Param		ExpO:Modelo de Dados da Tela de Locais de Atendimento

@return O saldo atual do material selecionado
/*/
//-------------------------------------------------
Static Function InitDados( oModel )

Local cDesLoc	:= ""
Local cMunic	:= ""
Local cEstado	:= ""
Local oMdlTFS := oModel:GetModel("TFSGRID")
Local oMdlTFT := oModel:GetModel("TFTGRID")
Local nX := 0
Local nPos := 0
Local nPosP := 0
Local nVal := 0
Local aRetTFG := {}
Local aRetTFH := {}
Local aQtdTFG := {}
Local aQtdTFH := {}
Local lOrcprc	:= .F.
Local aCodTfl	:= {}
Local cCodTFJ	:= ""
Local lCntRec	:= .F.
Local QtdSA     := 0
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local lTFTCampo := (TFT->(ColumnPos("TFT_CODSA"))>0)
Local lTFSCampo := (TFS->(ColumnPos("TFS_CODSA"))>0)

cDesLoc	:= Posicione("ABS", 1, xFilial("ABS")+FWFLDGET("TFL_LOCAL"), "ABS_DESCRI")
cMunic	:= Posicione("ABS", 1, xFilial("ABS")+FWFLDGET("TFL_LOCAL"), "ABS_MUNIC" )
cEstado	:= Posicione("ABS", 1, xFilial("ABS")+FWFLDGET("TFL_LOCAL"), "ABS_ESTADO" )

oModel:LoadValue("TFLMASTER", "TFL_DESLOC", cDesLoc)               
oModel:LoadValue("TFLMASTER", "TFL_MUNIC", cMunic)                
oModel:LoadValue("TFLMASTER", "TFL_ESTADO", cEstado) 

lCntRec := oModel:GetValue("TFLMASTER","TFL_CNTREC") == "1"

// Obtendo o código do local de Atendimento              
cNrCtr  := oModel:GetModel('TFLMASTER'):GetValue('TFL_CONTRT')
cCodTFJ := oModel:GetModel('TFLMASTER'):GetValue('TFL_CODPAI')
// Obtendo valor do parâmetro MV_ORCPRC
TFJ->(DbSetOrder(5))
TFJ->(dbSeek(xFilial('TFJ') + cNrCtr))
lOrcPrc := !Empty(TFJ->TFJ_CODTAB)

aCodTFL := AT890CodTFL(cCodTFJ)
aRetTFH := At890TFHRetAr(aCodTfl, lOrcPrc)
aRetTFG := At890TFGRetAr(aCodTFL, lOrcPrc)

// Inicialização do saldo para material de implantação
For nX := 1 To oMdlTFS:Length()
	oMdlTFS:GoLine(nX) 
	If !Empty(oMdlTFS:GetValue('TFS_CODTFG'))
		If Len(aQtdTFG) == 0 
			Aadd(aQtdTFG,  { oMdlTFS:GetValue('TFS_CODTFG'), oMdlTFS:GetValue('TFS_QUANT')})
		Else
			nPos := Ascan(aQtdTFG, {|x| x[1]  == oMdlTFS:GetValue('TFS_CODTFG')})
			If nPos == 0 			
				Aadd(aQtdTFG,  { oMdlTFS:GetValue('TFS_CODTFG'), oMdlTFS:GetValue('TFS_QUANT')})
			Else
				aQtdTFG[nPos,2] += oMdlTFS:GetValue('TFS_QUANT')
			EndIf
		EndIf	 	 
	EndIf
Next nx


For nX := 1 To oMdlTFS:Length()        	
	oMdlTFS:GoLine(nX)
	If !Empty(oMdlTFS:GetValue('TFS_CODTFG'))  
		nPos := ASCAN(aQtdTFG, { |x| Alltrim(x[1]) == Alltrim(oMdlTFS:GetValue('TFS_CODTFG')) })
		nPosP := ASCAN(aRetTFG, {|X| Alltrim(x[1]) == Alltrim(oMdlTFS:GetValue('TFS_CODTFG')) })
		nVal:= aRetTFG[nPosP,2] - aQtdTFG[nPos,2] 	
		At890Set(oMdlTFS, "TFS_SLDTTL", nVal )
		iF  lGsApmat .And. lTFSCampo	   
			QtdSA := At890QtdSA(Alltrim(oMdlTFS:GetValue('TFS_CODSA')),oMdlTFS:GetValue('TFS_QUANT'))
			If !Empty(oMdlTFS:GetValue('TFS_CODSA')) 
				At890Set(oMdlTFS, "TFS_QTDSA", QtdSA )
				At890Set(oMdlTFS, "TFS_SLDTTL", nVal )
			else
				At890Set(oMdlTFS, "TFS_QTDSA", oMdlTFS:GetValue('TFS_QUANT') )			
			Endif
		Endif	
	EndIf     	
Next nX	

// Inicialização do saldo para material de Consumo
For nX := 1 To oMdlTFT:Length()
	oMdlTFT:GoLine(nX) 
	If !Empty(oMdlTFT:GetValue('TFT_CODTFH'))
		 If Len(aQtdTFH) == 0 		 	
			 Aadd(aQtdTFH,  { oMdlTFT:GetValue('TFT_CODTFH'), oMdlTFT:GetValue('TFT_QUANT'), oMdlTFT:GetValue('TFT_DTAPON') })		 
		 Else
			If lCntRec
				nPos := Ascan(aQtdTFH, {|x| x[1]  == oMdlTFT:GetValue('TFT_CODTFH') .And. x[3]  >= FirstDate(oMdlTFT:GetValue('TFT_DTAPON')) .And. x[3]  <= LastDate(oMdlTFT:GetValue('TFT_DTAPON')) })			
			Else
				nPos := Ascan(aQtdTFH, {|x| x[1]  == oMdlTFT:GetValue('TFT_CODTFH')})
			Endif
			If nPos == 0
				Aadd(aQtdTFH,  { oMdlTFT:GetValue('TFT_CODTFH'), oMdlTFT:GetValue('TFT_QUANT'), oMdlTFT:GetValue('TFT_DTAPON')})
			Else
				aQtdTFH[nPos,2] += oMdlTFT:GetValue('TFT_QUANT')
			EndIf
		EndIf	 	 
	EndIf
Next nx
	
For nX := 1 To oMdlTFT:Length()  
	oMdlTFT:GoLine(nX)
	If !Empty(oMdlTFT:GetValue('TFT_CODTFH'))
		If lCntRec
			nPos := ASCAN(aQtdTFH, { |x| Alltrim(x[1]) == Alltrim(oMdlTFT:GetValue('TFT_CODTFH')) .And. x[3]  >= FirstDate(oMdlTFT:GetValue('TFT_DTAPON')) .And. x[3]  <= LastDate(oMdlTFT:GetValue('TFT_DTAPON')) })
		Else
			nPos := ASCAN(aQtdTFH, { |x| Alltrim(x[1]) == Alltrim(oMdlTFT:GetValue('TFT_CODTFH')) })
		Endif
		nPosP := ASCAN(aRetTFH, {|X| Alltrim(x[1]) == Alltrim(oMdlTFT:GetValue('TFT_CODTFH')) })		
		nVal:= aRetTFH[nPosP,2] - aQtdTFH[nPos,2] 
		At890Set(oMdlTFT, "TFT_SLDTTL", nVal )
		iF  lGsApmat .And. lTFTCampo
		    QtdSA := At890QtdSA(Alltrim(oMdlTFT:GetValue('TFT_CODSA')),oMdlTFT:GetValue('TFT_QUANT'))
			If !Empty(oMdlTFT:GetValue('TFT_CODSA')) 
				At890Set(oMdlTFT, "TFT_QTDSA", QtdSA )
				At890Set(oMdlTFT, "TFT_SLDTTL", nVal )
			else
				At890Set(oMdlTFT, "TFT_QTDSA", oMdlTFT:GetValue('TFT_QUANT') )				
			Endif
		Endif	
	EndIf 
Next nX	

Return Nil


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890Set

Função para inicializar valores para campos calculados do modelo

@author 	Serviços
@since 		21/11/2018

@return lRet 
/*/
//-------------------------------------------------
Static Function At890Set(oModel, cField, xValue)

Local lRet := .T.

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	oModel:LoadValue( cField, xValue )
Else
	lRet := oModel:SetValue( cField, xValue )
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At870Cols

Colunas para o browse com os dados do Local x Orçamento
@author Serviços
@since 02/12/2013
@version P11 R9

@param		ExpC1 - Alias utilizado para o retorno das colunas	
@return	nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890Cols(cAliasPro)

Local nI			:= 0 
Local aArea		:= GetArea()
Local aColumns	:= {}
Local aFiltros	:= {}
Local cCampo 		:= ""
Local nLinha 		:= 0
Local aCampos 	:= { 	"ADY_OPORTU", "TFL_CONTRT", "TFL_LOCAL", "ABS_DESCRI", "ABS_MUNIC",;
							"ABS_ESTADO", "TFL_DTINI","TFL_DTFIM" }
							
DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For nI:=1 To Len(aCampos)
	If SX3->(dbSeek(aCampos[nI]))
		cCampo := AllTrim(SX3->X3_CAMPO)
		AAdd(aColumns,FWBrwColumn():New())
		nLinha := Len(aColumns)
	   	aColumns[nLinha]:SetType(SX3->X3_TIPO)
	   	aColumns[nLinha]:SetTitle(X3Titulo())
		aColumns[nLinha]:SetSize(SX3->X3_TAMANHO)
		aColumns[nLinha]:SetDecimal(SX3->X3_DECIMAL)
		If SX3->X3_TIPO == "D"
			aColumns[nLinha]:SetData(&("{|| sTod(" + cCampo + ")}"))		
		Else
			aColumns[nLinha]:SetData(&("{||" + cCampo + "}"))	
		EndIf
		aAdd(aFiltros,{cCampo,X3Titulo(),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE})
	EndIf
Next nI
SX3->(dbCloseArea())

RestArea(aArea)

Return({aColumns, aFiltros})

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890Query

Query com os dados do Local x Orçamento
@author Serviços
@since 02/12/2013
@version P11 R9
	
@return	nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890Query

Local cQuery 		:= ""
Local lVersion23	:= SuperGetMv("MV_ORCSIMP",,"2") == "1"
Local lOrcPrc		:= SuperGetMv("MV_ORCPRC",,.F.) 

cQuery := ""
If lVersion23
	cQuery += "SELECT "
	cQuery += "CASE WHEN ADY.ADY_OPORTU IS NOT NULL THEN ADY.ADY_OPORTU ELSE '' END ADY_OPORTU, "
	cQuery += "TFL_CONTRT,TFL_CODIGO, TFL_LOCAL, ABS_DESCRI, ABS_MUNIC, ABS_ESTADO, TFL_DTINI, TFL_DTFIM, TFJ_GESMAT, "
Else
	cQuery += "SELECT ADY_OPORTU, TFL_CONTRT,TFL_CODIGO, TFL_LOCAL, ABS_DESCRI, ABS_MUNIC, ABS_ESTADO, TFL_DTINI,TFL_DTFIM, TFJ_GESMAT, "
EndIf
cQuery += " TFJ_CNTREC "
cQuery += " FROM " + RetSqlName("TFL") + " TFL"
cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9"
cQuery += " ON CN9_FILIAL = '" + xFilial("CN9") + "' AND"
cQuery += " TFL_CONTRT = CN9_NUMERO  AND"  
cQuery += " TFL_CONREV = CN9_REVISA"
cQuery += " AND CN9.D_E_L_E_T_ = ' '"

cQuery += " INNER JOIN " + RetSqlName("TFJ")+ " TFJ"
cQuery += " ON TFJ_FILIAL = '" + xFilial("TFJ") + "' AND"
cQuery += " TFL_CODPAI = TFJ_CODIGO"  
cQuery += " AND TFJ.D_E_L_E_T_ = ' '"
 
cQuery += " INNER JOIN " + RetSqlName("ABS")+ " ABS"
cQuery += " ON ABS_FILIAL = '" + xFilial("ABS") + "' AND"
cQuery += " TFL_LOCAL = ABS_LOCAL" 
cQuery += " AND ABS.D_E_L_E_T_ = ' '"
If lVersion23
	cQuery += " LEFT JOIN " + RetSqlName("ADY")+ " ADY"
Else 
	cQuery += " INNER JOIN " + RetSqlName("ADY")+ " ADY"
EndIf
cQuery += " ON ADY_FILIAL = '" + xFilial("ADY") + "' AND"
cQuery += " TFJ_PROPOS = ADY_PROPOS"  

If lOrcPrc
	cQuery += " INNER JOIN " + RetSqlName("TFG") + " TFG "
	cQuery += " ON TFG.TFG_CODPAI = TFL.TFL_CODIGO "
	cQuery += " AND TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
	cQuery += " AND TFG.D_E_L_E_T_ = ' ' "
Else
	cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_CODPAI = TFL.TFL_CODIGO "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("TFG") + " TFG "
	cQuery += " ON TFG.TFG_CODPAI = TFF.TFF_COD "
	cQuery += " AND TFG.TFG_FILIAL = '" + xFilial("TFG") + "' "
	cQuery += " AND TFG.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE TFL_FILIAL = '"+xFilial("TFL")+"' "
If lVersion23
	cQuery += " AND (ADY.D_E_L_E_T_ = ' ' OR ADY.D_E_L_E_T_ IS NULL)"
EndIf
cQuery += " AND CN9_SITUAC = '05' "
cQuery += " AND TFJ_STATUS = '1' "
cQuery += " AND TFL.D_E_L_E_T_ = ' '"

cQuery += " UNION "

If lVersion23
	cQuery += "SELECT "
	cQuery += "CASE WHEN ADY.ADY_OPORTU IS NOT NULL THEN ADY.ADY_OPORTU ELSE '' END ADY_OPORTU, "
	cQuery += "TFL_CONTRT,TFL_CODIGO, TFL_LOCAL, ABS_DESCRI, ABS_MUNIC, ABS_ESTADO, TFL_DTINI, TFL_DTFIM, TFJ_GESMAT, "
Else
	cQuery += "SELECT ADY_OPORTU, TFL_CONTRT,TFL_CODIGO, TFL_LOCAL, ABS_DESCRI, ABS_MUNIC, ABS_ESTADO, TFL_DTINI,TFL_DTFIM, TFJ_GESMAT, "
EndIf
cQuery += " TFJ_CNTREC "
cQuery += " FROM " + RetSqlName("TFL") + " TFL"
cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9"
cQuery += " ON CN9_FILIAL = '" + xFilial("CN9") + "' AND"
cQuery += " TFL_CONTRT = CN9_NUMERO  AND"  
cQuery += " TFL_CONREV = CN9_REVISA"
cQuery += " AND CN9.D_E_L_E_T_ = ' '"

cQuery += " INNER JOIN " + RetSqlName("TFJ")+ " TFJ"
cQuery += " ON TFJ_FILIAL = '" + xFilial("TFJ") + "' AND"
cQuery += " TFL_CODPAI = TFJ_CODIGO"  
cQuery += " AND TFJ.D_E_L_E_T_ = ' '"
 
cQuery += " INNER JOIN " + RetSqlName("ABS")+ " ABS"
cQuery += " ON ABS_FILIAL = '" + xFilial("ABS") + "' AND"
cQuery += " TFL_LOCAL = ABS_LOCAL" 
cQuery += " AND ABS.D_E_L_E_T_ = ' '"
If lVersion23
	cQuery += " LEFT JOIN " + RetSqlName("ADY")+ " ADY"
Else 
	cQuery += " INNER JOIN " + RetSqlName("ADY")+ " ADY"
EndIf
cQuery += " ON ADY_FILIAL = '" + xFilial("ADY") + "' AND"
cQuery += " TFJ_PROPOS = ADY_PROPOS"  

If lOrcPrc
	cQuery += " INNER JOIN " + RetSqlName("TFH") + " TFH "
	cQuery += " ON TFH.TFH_CODPAI = TFL.TFL_CODIGO "
	cQuery += " AND TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
	cQuery += " AND TFH.D_E_L_E_T_ = ' ' "
Else
	cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
	cQuery += " ON TFF.TFF_CODPAI = TFL.TFL_CODIGO "
	cQuery += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
	cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("TFH") + " TFH "
	cQuery += " ON TFH.TFH_CODPAI = TFF.TFF_COD "
	cQuery += " AND TFH.TFH_FILIAL = '" + xFilial("TFH") + "' "
	cQuery += " AND TFH.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE TFL_FILIAL = '"+xFilial("TFL")+"' "
If lVersion23
	cQuery += " AND (ADY.D_E_L_E_T_ = ' ' OR ADY.D_E_L_E_T_ IS NULL)"
EndIf
cQuery += " AND CN9_SITUAC = '05' "
cQuery += " AND TFJ_STATUS = '1' "
cQuery += " AND TFL.D_E_L_E_T_ = ' '"

cQuery += " UNION "

If lVersion23
	cQuery += "SELECT "
	cQuery += "CASE WHEN ADY.ADY_OPORTU IS NOT NULL THEN ADY.ADY_OPORTU ELSE '' END ADY_OPORTU, "
	cQuery += "TFL_CONTRT,TFL_CODIGO, TFL_LOCAL, ABS_DESCRI, ABS_MUNIC, ABS_ESTADO, TFL_DTINI, TFL_DTFIM, TFJ_GESMAT, "
Else
	cQuery += "SELECT ADY_OPORTU, TFL_CONTRT,TFL_CODIGO, TFL_LOCAL, ABS_DESCRI, ABS_MUNIC, ABS_ESTADO, TFL_DTINI,TFL_DTFIM, TFJ_GESMAT, "
EndIf
cQuery += " TFJ_CNTREC "
cQuery += " FROM " + RetSqlName("TFL") + " TFL"
cQuery += " INNER JOIN " + RetSqlName("CN9") + " CN9"
cQuery += " ON CN9_FILIAL = '" + xFilial("CN9") + "' AND"
cQuery += " TFL_CONTRT = CN9_NUMERO  AND"  
cQuery += " TFL_CONREV = CN9_REVISA"
cQuery += " AND CN9.D_E_L_E_T_ = ' '"

cQuery += " INNER JOIN " + RetSqlName("TFJ")+ " TFJ"
cQuery += " ON TFJ_FILIAL = '" + xFilial("TFJ") + "' AND"
cQuery += " TFL_CODPAI = TFJ_CODIGO"

cQuery += " AND TFJ.D_E_L_E_T_ = ' '"
 
cQuery += " INNER JOIN " + RetSqlName("ABS")+ " ABS"
cQuery += " ON ABS_FILIAL = '" + xFilial("ABS") + "' AND"
cQuery += " TFL_LOCAL = ABS_LOCAL" 
cQuery += " AND ABS.D_E_L_E_T_ = ' '"
If lVersion23
	cQuery += " LEFT JOIN " + RetSqlName("ADY")+ " ADY"
Else 
	cQuery += " INNER JOIN " + RetSqlName("ADY")+ " ADY"
EndIf
cQuery += " ON ADY_FILIAL = '" + xFilial("ADY") + "' AND"
cQuery += " TFJ_PROPOS = ADY_PROPOS"  

cQuery += " WHERE TFL_FILIAL = '"+xFilial("TFL")+"' "
If lVersion23
	cQuery += " AND (ADY.D_E_L_E_T_ = ' ' OR ADY.D_E_L_E_T_ IS NULL)"
EndIf
cQuery += " AND CN9_SITUAC = '05' "
cQuery += " AND TFJ_STATUS = '1' "
cQuery += " AND TFL.D_E_L_E_T_ = ' '"
cQuery += " AND TFJ_GESMAT <> '1' "

If lVersion23
	cQuery += " ORDER BY TFL_CONTRT"
Else
	cQuery += " ORDER BY ADY_OPORTU"
EndIf

Return(cQuery)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890Apon

Inícia a página de apontamento
@author Serviços
@param cCodTFL - Código a ser buscado na tabela TFL
@since 02/12/2013
@version P11 R9
	
@return	lRet- valor true quando tudo ocorrer de acordo
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890Apon(cCodTFL,cCodGesMat)	

Local aArea := GetArea()
Local cAliasTFL	:="TFL"
Local lRet := .F.
Local nTipo := 0
Private INCLUI := .F.
Private ALTERA := .T.
Private EXCLUI := .F.

Default cCodGesMat := ""

//Foi necessario abrir o SX3
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
DbSelectArea(cAliasTFL)
TFL->(DbSetOrder(1))//TFL_FILIAL+TFL_CODIGO
If (cAliasTFL)->(DbSeek(xFilial("TFL")+cCodTFL))
	//verificar se local está encerrado - TFL_ENCE = 1
	If 	(cAliasTFL)->TFL_ENCE <> "1"
		If cCodGesMat $ "4|5"
			nTipo := Aviso( STR0033, STR0123 +; //Atenção ## "Os itens de Material de Implantação são controlados por "
			IIF(cCodGesMat == '4', STR0124,STR0125) + STR0126 +; //quantidade ## valor ## " e os Materiais de Consumo são controlados por "
			IIF(cCodGesMat == '4', STR0125,STR0124) + STR0127; //valor ## quantidade ## ". Selecione o tipo do apontamento: "
			, { STR0128 + " (" + IIF(cCodGesMat == '4',STR0129,STR0130)+")"; //"Quantidade" ## 'Mat.Implantação' ## 'Mat.Consumo'
			, STR0131 + " (" + IIF(cCodGesMat == '4',STR0130,STR0129)+")" }, 2 ) //Valor ## 'Mat.Consumo' ## 'Mat.Implantação'
		EndIf
		//Quando o codigo gestão de materiais for igual a 2 ou 3 deve-se chamar a rotina de apontamento de materiais por valor (TECA891)
		If (cCodGesMat == '2' .or. cCodGesMat == '3') .OR. nTipo == 2
			DbSelectArea(cAliasTFL)
			TFL->(DbSetOrder(1))//TFL_FILIAL+TFL_CODIGO
			If (cAliasTFL)->(DbSeek(xFilial("TFL")+cCodTFL))	
				FWExecView(Upper(STR0001),"VIEWDEF.TECA891",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)//"Apontamento de Materiais"
				lRet:=.T.
			Else
				Help( ' ', 1, 'TECA891', , STR0026, 1, 0 )	
			EndIf
		Else
			DbSelectArea(cAliasTFL)
			TFL->(DbSetOrder(1))//TFL_FILIAL+TFL_CODIGO
			If (cAliasTFL)->(DbSeek(xFilial("TFL")+cCodTFL))
				
				DbSelectArea("TFJ")
				DbSetOrder(1)
				TFJ->(DbSeek(xFilial("TFJ")+TFL->TFL_CODPAI))
				DbSelectArea("TFL")
				
				FWExecView(Upper(STR0001),"VIEWDEF.TECA890",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)//"Apontamento de Materiais"
				lRet := .T.
			Else
				Help( ' ', 1, 'TECA890', , STR0026, 1, 0 )	
			EndIf
		Endif
	Elseif (cAliasTFL)->TFL_ENCE == "1" // local ja encerrado
		lRet:= .F.
		Aviso( STR0033, STR0034, { STR0035 }, 2 )	//"Atenção", "Local já encerrado. Não permitido gerar movimentação", { "OK" } 
	Endif
Else
	Aviso( STR0036, STR0037, {STR0038 }, 2 )	//"Atenção", "Registro não encontrado. Favor verificar", { "OK" } 
Endif
RestArea(aArea)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890PosVal

Inícia a página de apontamento
@author Serviços
@param cCodTFL - Código a ser buscado na tabela TFL
@since 02/12/2013
@version P11 R9
	
@return	lRet- valor true quando tudo ocorrer de acordo
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890PosVal(oMdlG,nLine,cAcao,cCampo,cIdent,cCampoMVC)

Local oView			:= FWViewActive()
Local lRet		 		:= .T.
Local aSaveLines 		:= FWSaveRows() 
Local cCpoVal			:= ""
Local cPrdPrin  		:= ""
Local cTab				:= IIF(cCampoMVC <> nil, SubStr(cCampoMVC,1,3),'')
Local ctabAlias		:= ""
Local dDtIni 		:= FirstDate(dDataBase)
Local dDtFim 		:= LastDate(dDataBase)
Local lCntRec		:= .F.
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local lTFTCampo := (TFT->(ColumnPos("TFT_CODSA"))>0)
Local lTFSCampo := (TFS->(ColumnPos("TFS_CODSA"))>0)

If !IsInCallStack("InitDados") .And. lRet .And. cIdent == "TFT"
	lCntRec := oMdlG:GetModel():GetValue("TFLMASTER","TFL_CNTREC") == "1"
	If lCntRec .And. !(oMdlG:GetValue("TFT_DTAPON") >= dDtini .And. oMdlG:GetValue("TFT_DTAPON") <= dDtFim)
		lRet := .F.
		If cAcao == "DELETE"
			Help(,,'At890PosVal',,STR0140+cValtoChar(oMdlG:GetValue("TFT_DTAPON"))+STR0141+cValtoChar(FirstDate(oMdlG:GetValue("TFT_DTAPON")))+STR0142+cValtoChar(LastDate(oMdlG:GetValue("TFT_DTAPON"))),1,0)//"Apontamento realizado em"##". Entre com a data base no período de "##" a " 
		Endif
	Endif
Endif

If cTab = 'TFS'
	cCpoVal	:= 'TFS_CODTFG'
ElseIf cTab = 'TFT'
	cCpoVal	:= 'TFT_CODTFH'
Endif
if(cIdent=="TFS")
	ctabAlias := "TFG"
Else
	ctabAlias := "TFH"
EndIf
If lRet .And. cAcao == "UNDELETE" 
	At890Undel(ctabAlias, oMdlG, oMdlG:GetValue(cIdent+"_QUANT"), oMdlG:GetValue(cIdent+"_COD"+ctabAlias),nLine)
EndIf
If lRet .And. cAcao == "DELETE"
	lRet := At890Delet(ctabAlias, oMdlG, oMdlG:GetValue(cIdent+"_QUANT"), oMdlG:GetValue(cIdent+"_COD"+ctabAlias))
EndIf
If lRet .And. !Empty(cCpoVal)
	cPrdPrin :=	At890PrdPad(oMdlG:GetValue(cCpoVal),cTab)
EndIf	
If lRet .And. (cCampoMVC == 'TFS_PRODUT' .Or. cCampoMVC == 'TFT_PRODUT')  .And. cAcao == 'CANSETVALUE' .And. !(!Empty(FwFldGet("TFS_ITAPUR")) .OR.  AT890VldTWY(cPrdPrin))
	lRet := .F.
EndIf
If !Empty(FwFldGet(cCampo)) .AND.  cAcao == "DELETE" .And. lRet
	lRet:=.F.
	Help(,,'AT890DEL',,STR0027,1,0)//"Apontamento já apurado! Não pode ser deletado"
EndIf
If cAcao == "SETVALUE" .AND. cCampoMVC == "TFS_CODTFG" .And. lRet
	oMdlG:SetValue("TFS_QUANT", 0)
EndIf
If cAcao == "SETVALUE" .AND. cCampoMVC == "TFT_CODTFH" .And. lRet
	oMdlG:SetValue("TFT_QUANT", 0)
EndIf

If cIdent == "TFS"  .And. lGsApmat .And. cCampoMVC == 'TFS_QUANT' .And. lRet 
	If cAcao == "SETVALUE" .And. !IsInCallStack("InitDados") .And. FwFldGet("TFS_QUANT") == 0
		lRet := .F.
		HELP("",1,"At890PosVal",,STR0050,1,0)//"Quantidade não preenchida!"
	Endif
Endif

If cIdent == "TFS"  .And. lGsApmat .And. cCampoMVC == 'TFS_QUANT' .And. lTFSCampo .And. lRet
	If cAcao == "SETVALUE" .And. !IsInCallStack("InitDados")
		DbSelectArea("TFS")
		TFS->(DbSetOrder(1))
		If TFS->(DbSeek(xFilial("TFS")+oMdlG:GetValue("TFS_CODIGO"))) .And. Empty(oMdlG:GetValue("TFS_CODSA")) .And.;
			 oMdlG:GetValue("TFS_QUANT") <> 0 .And. !Empty(oMdlG:GetValue("TFS_NUMMOV"))
			lRet := .F.
			Help( "", 1, "At890PosVal", ,STR0185, 1, 0,,,,,,; // "Não é possível alterar este item." 
										{STR0186}) // "Realize a inclusão de uma nova linha." 
		Endif
		If lRet .And. At890Verif(oMdlG:GetValue("TFS_CODSA"))
			lRet := .F.
			HELP("",1,"At890PosVal",,STR0182,1,0)	// "Não é possível alterar este item nas seguintes legendas: encerrado/rejeitado/em analise/atendido parcialmente. Se necessario realize um novo apontamento para consumir o saldo" 
		Endif
	Endif
Endif

If cIdent == "TFT"  .And. lGsApmat .And. cCampoMVC == 'TFT_QUANT' .And. lRet
	If cAcao == "SETVALUE" .And. !IsInCallStack("InitDados") .And. FwFldGet("TFT_QUANT") == 0
		lRet := .F.
		HELP("",1,"At890PosVal",,STR0050,1,0)// "Quantidade não preenchida!"   	
	Endif
Endif

If cIdent == "TFT"  .And. lGsApmat .And. cCampoMVC == 'TFT_QUANT' .And. lTFTCampo .And. lRet
	If cAcao == "SETVALUE" .And. !IsInCallStack("InitDados")
		DbSelectArea("TFT")
		DbSetOrder(1)
		If TFT->(DbSeek(xFilial("TFT")+oMdlG:GetValue("TFT_CODIGO"))) .And. Empty(oMdlG:GetValue("TFT_CODSA")) .And.;
			 oMdlG:GetValue("TFT_QUANT") <> 0 .And. !Empty(oMdlG:GetValue("TFT_NUMMOV"))
			 lRet := .F.
			 Help( "", 1, "At890PosVal", ,STR0185, 1, 0,,,,,,; //"Não é possível alterar este item." 
										{STR0182}) // "Não é possível alterar este item nas seguintes legendas: encerrado/rejeitado/em analise/atendido parcialmente. Se necessario realize um novo apontamento para consumir o saldo" 
		Endif
		If lRet .And. At890Verif(oMdlG:GetValue("TFT_CODSA"))
			lRet := .F.
			HELP(,,STR0181,,STR0182,1,0)	
		Endif
	Endif
Endif	

FwRestRows( aSaveLines )		

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890ValdQnt

Valida campo quantidade
no Modulo Estoque
@author  Serviços
@since 	  31/10/13
@version P11 R9
@param nQuApnt: Quantidade que se deseja apontar.
@param cAliasMat: O "alias" que se deseja, podendo ser da TFG para matériais operacionais e TFH para os matériais de Consumo.
@param cCodMat: Código do Material a ser apontado.

@return lRet: Retorna .T. quando o saldo do material foi suficiente para suprir a quantidade do apontamento.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890ValdQnt(nQuApnt, cAliasMat, cCodMat, cAcao)

Local aArea			:= GetArea()
Local cCodigo			:= cCodMat
Local lRet				:= .F.
Local oModel			:= FWModelActive()
Local oView			:= FwViewActive()
Local oModelTFS		:= oModel:GetModel("TFSGRID")
Local oModelTFT		:= oModel:GetModel("TFTGRID")
Local nQuant			:= 0
Local nQuantant		:= 0
Local nX				:= 1
Local nSld				:= 0
Local cProdut			:= ""
Local aSaveLines		:= FWSaveRows()
Local oMdl893TFS		:= oModel:GetModel("TFSDETAIL")
Local nTpMov			:= "" //tipo de movimento - envio / retorno
Local tmpQry1			:= ""
Local cProduto		:= ""
Local nQtTFS			:= 0
Local cCodTFG 		:= ""
Local lRestoreLine	:= .F.
Local lCntRec		:= oModel:GetValue("TFLMASTER","TFL_CNTREC") == "1"
Local nSldTFH		:= 0
Local dDtIni 		:= FirstDate(dDataBase)
Local dDtFim 		:= LastDate(dDataBase)

If POSITIVO(nQuApnt) 
	//verificar rotina chamada
	If !IsInCallStack("At890RtMip")
		DbSelectArea(cAliasMat)
		DbSetOrder(1)
		If (cAliasMat)->(DbSeek(xFilial(cAliasMat)+cCodigo))
			If cAliasMat == "TFG" 
				cProdut := oModelTFS:GetValue("TFS_CODTFG")	
				For nX := 1 To oModelTFS:Length() 
					oModelTFS:GoLine(nX)
					If oModelTFS:GetValue("TFS_CODTFG")==cProdut .AND. !oModelTFS:IsDeleted() 
						nQuant := nQuant + oModel:GetModel("TFSGRID"):GetValue("TFS_QUANT")
						nQuantant:= nQuantant+Posicione("TFS", 1, xFilial("TFS") + oModelTFS:GetValue("TFS_CODIGO"), "TFS_QUANT")
					EndIf
				Next nX
				If (cAliasMat)->TFG_SLD + nQuantant - nQuant >= 0
					lRet := .T.
					If(cAcao == "UNDELETE")
						nSld := (cAliasMat)->TFG_SLD + nQuantant - nQuant -  nQuApnt
					Else	
						nSld := (cAliasMat)->TFG_SLD + nQuantant - nQuant
					EndIf
					For nX := 1 To oModelTFS:Length() 
						oModelTFS:GoLine(nX)
						If oModelTFS:GetValue("TFS_CODTFG") == cProdut 
							 oModelTFS:LoadValue("TFS_SLDTTL", nSld )
						EndIf
					Next nX	
				Else
					HELP(,,'Saldo',,STR0020)//"Saldo insuficiente para esta quantidade!"
					lRet := .F.
				EndIf

			ElseIf cAliasMat == "TFH" 
				cProdut:=oModelTFT:GetValue("TFT_CODTFH")
				For nX := 1 To oModel:GetModel( "TFTGRID" ):Length() 
					oModelTFT:GoLine(nX)
					If lCntRec
						If oModelTFT:GetValue("TFT_CODTFH")==cProdut .And.;
							oModelTFT:GetValue("TFT_DTAPON") >= dDtini .And.;
							 oModelTFT:GetValue("TFT_DTAPON") <= dDtFim .And.;
							  !oModelTFT:IsDeleted()
							nQuant := nQuant+oModel:GetModel("TFTGRID"):GetValue("TFT_QUANT")
							nQuantant:= nQuantant+Posicione("TFT", 1, xFilial("TFT") + FWFLDGET("TFT_CODIGO"), "TFT_QUANT")
						EndIf					
					Else
						If oModelTFT:GetValue("TFT_CODTFH")==cProdut .AND. !oModelTFT:IsDeleted()
							nQuant := nQuant+oModel:GetModel("TFTGRID"):GetValue("TFT_QUANT")
							nQuantant:= nQuantant+Posicione("TFT", 1, xFilial("TFT") + FWFLDGET("TFT_CODIGO"), "TFT_QUANT")
						EndIf
					Endif
				Next nX
				
				If lCntRec
					nSldTFH := At890SldRc(TFH->TFH_COD)
				Else
					nSldTFH :=(cAliasMat)->TFH_SLD
				Endif
				
				If nSldTFH + nQuantant - nQuant >= 0
					lRet := .T.
					If(cAcao == "UNDELETE")
						nSld := nSldTFH + nQuantant - nQuant -  nQuApnt
					Else	
						nSld := nSldTFH + nQuantant - nQuant
					EndIf
					For nX := 1 To oModel:GetModel( "TFTGRID" ):Length() 
						oModelTFT:GoLine(nX)
						If lCntRec
							If oModelTFT:GetValue("TFT_CODTFH")=cProdut .And.;
							 	oModelTFT:GetValue("TFT_DTAPON") >= dDtini .And.;
								 oModelTFT:GetValue("TFT_DTAPON") <= dDtFim
								oModel:LoadValue("TFTGRID", "TFT_SLDTTL", nSld )
							EndIf
						Else
							If oModelTFT:GetValue("TFT_CODTFH")=cProdut
								oModel:LoadValue("TFTGRID", "TFT_SLDTTL", nSld )
							EndIf						
						Endif
					Next nX	
				Else
					HELP(,,'Saldo',,STR0020)//"Saldo insuficiente para esta quantidade!"
					lRet:= .F.
				EndIf
			EndIf
		EndIf
		
		lRestoreLine := .T.
		FwRestRows( aSaveLines )
		RestArea(aArea)
	Else	//rotina de retorno material implantação TECA893
		nSld		:= 0
		nQuant		:= 0
		cCodTFG	:= oMdl893TFS:GetValue("TFS_CODTFG")
		CProduto	:= oMdl893TFS:GetValue("TFS_PRODUT")
		nQtTFS		:= oMdl893TFS:GetValue("TFS_QUANT")
		//montar query
		tmpQry1:=GetNextAlias()
		BeginSql Alias tmpQry1
			SELECT  TFS.TFS_PRODUT, TFS.TFS_QUANT, TFS.TFS_MOV 
			FROM %Table:TFS% TFS
			WHERE	TFS.TFS_FILIAL = %xFilial:TFS% 	
			AND TFS_CODTFG = %Exp:cCodTFG%
			AND TFS_PRODUT = %Exp:cProduto% 
			AND TFS.%NotDel%
		EndSql
	
		While (tmpQry1)->(!EOF())
			//verificar saldo
			nQuant:= (tmpQry1)->TFS_QUANT
			nTpMov:= (tmpQry1)->TFS_MOV
			If nTpMov == "1"
				nSld:= nSld + nQuant
			Elseif nTpMov == "2"
				 nSld:= nSld - nQuant
			Endif	  
			(tmpQry1)->(DbSkip())
		Enddo
	(tmpQry1)->(DbCloseArea())
		//verificar se saldo e positivo
		If (nSld - nQtTFS) >= 0 
			lRet:= .T.
		Else
			HELP(,,'Saldo',,STR0039) //"Saldo insuficiente para retornar esta quantidade, verifique!" 
			lRet:= .F.
		Endif
	Endif
	If VALTYPE(oView) == 'O' .AND. oView:isActive()
		oView:Refresh()
	EndIf
	If lRestoreLine
		FwRestRows( aSaveLines )
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890LinhaOK

Valida campos referentes a estoque
no Modulo Estoque
@author  Serviços
@since 	  31/10/13
@version P11 R9

@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890LinhaOK()
Local aArray		:= {}
Local nX			:= 0
Local lRet			:= .T.
Local nQtd			:= 0
Local aArea		:= GetArea()
Local oModel	:= FWModelActive()
Local oModelTFT	:= oModel:GetModel("TFTGRID")
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local lTFTCampo := (TFT->(ColumnPos("TFT_CODSA"))>0)

If !(lGsApmat .And. lTFTCampo)
	If	!Empty(oModelTFT:GetValue("TFT_LOTECT")) .OR.; 
		!Empty(oModelTFT:GetValue("TFT_NUMLOT")) .OR.;
		!Empty(oModelTFT:GetValue("TFT_LOCALI")) .OR.;
		!Empty(oModelTFT:GetValue("TFT_NUMSER"))
	
		aArray := SldPorLote(oModelTFT:GetValue("TFT_PRODUT"),oModelTFT:GetValue("TFT_LOCAL"),oModelTFT:GetValue("TFT_QUANT"),NIL,oModelTFT:GetValue("TFT_LOTECT"),;
							oModelTFT:GetValue("TFT_NUMLOT"),oModelTFT:GetValue("TFT_LOCALI"),oModelTFT:GetValue("TFT_NUMSER"))
		For nX := 1 to Len(aArray)
			nQtd += aArray[nX, 5]
		Next nX
	Else
		dbSelectArea("SB2")
		dbSetOrder(1)	
		If (!DbSeek(xFilial("SB2")+oModelTFT:GetValue("TFT_PRODUT")+oModelTFT:GetValue("TFT_LOCAL")) )
			lRet := .F.
		Else
			nQtd := SaldoSB2()
		EndIf
	EndIf
	If nQtd < oModelTFT:GetValue("TFT_QUANT") .And. Empty(oModelTFT:GetValue("TFT_NUMMOV"))
		lRet := .F.
		Help(,,STR0030,,STR0031,1,0)//"Saldo Insuficiente" #	"Saldo Insuficiente para realizar a movimentação com estas informações de estoque"
	EndIf
	RestArea(aArea)
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890LnOKTFS

Valida campos referentes a estoque
no Modulo Estoque
@author  Serviços
@since 	  31/10/13
@version P11 R9

@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890LnOKTFS()

Local aArray		:= {}
Local nX			:= 0
 Local lRet			:= .T.
Local nQtd			:= 0
Local aArea		:= GetArea()
Local oModel	:= FWModelActive()
Local oModelTFS	:= oModel:GetModel("TFSGRID")

If	!Empty(oModelTFS:GetValue("TFS_LOTECT")) .OR.; 
	!Empty(oModelTFS:GetValue("TFS_NUMLOT")) .OR.;
	!Empty(oModelTFS:GetValue("TFS_LOCALI")) .OR.;
	!Empty(oModelTFS:GetValue("TFS_NUMSER"))
 
	aArray := SldPorLote( oModelTFS:GetValue("TFS_PRODUT"),oModelTFS:GetValue("TFS_LOCAL"),oModelTFS:GetValue("TFS_QUANT"),NIL,oModelTFS:GetValue("TFS_LOTECT"),;
							oModelTFS:GetValue("TFS_NUMLOT"),oModelTFS:GetValue("TFS_LOCALI"),oModelTFS:GetValue("TFS_NUMSER"))
	For nX := 1 to Len(aArray)
		nQtd += aArray[nX, 5]
	Next nX
	
Else
	dbSelectArea("SB2")
	dbSetOrder(1)	
	If (!DbSeek(xFilial("SB2")+oModelTFS:GetValue("TFS_PRODUT")+oModelTFS:GetValue("TFS_LOCAL")) )
		lRet := .F.
	Else
		nQtd := SaldoSB2()
	EndIf
EndIf

				      
If nQtd < oModelTFS:GetValue("TFS_QUANT") .And. Empty(oModelTFS:GetValue("TFS_NUMMOV"))
	lRet := .F.
	Help(,,STR0030,,STR0031,1,0)//"Saldo Insuficiente" #	"Saldo Insuficiente para realizar a movimentação com estas informações de estoque"
EndIf


RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890RetMi

Função para retornar material de implantação do contrato 
no Modulo Estoque
@author  Serviços
@since 	  17/08/15
@version P12

@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890RtMip(cCodTFL,cConTrt,cCodGesMat)

Local aArea 	:= {}
Local oModel 	:= Nil
Local aArea 	:= GetArea()
Local lRet 		:= .F.

Default cConTrt 	:= ""
Default cCodGesMat := ""

//Foi necessario abrir o SX3
DbSelectArea("SX3")
SX3->(DbSetOrder(1))

DbSelectArea("TFL")
TFL->(DbSetOrder(1))//TFL_FILIAL+TFL_CODIGO
If TFL->(DbSeek(xFilial("TFL")+cCodTFL))
	If TFL->TFL_ENCE <> "1"
		If cCodGesMat $ '2|3|5'
			lRet := .F.
			Aviso(STR0033,STR0065, {STR0042}, 2) //"Atenção","O Contrato/Orçamento escolhido utiliza apontamento por valor, onde não há retorno"
		Else
			lRet := .T.
			FWExecView( STR0043, "VIEWDEF.TECA893", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/,	{||.T.}/*bOk*/,/*nReducao*/, /*aButtons*/, {||.T.}/*bCancel*/ ) //"Retorno Material de Implantação"		
		EndIf
	Else
		lRet := .F.
		Aviso( STR0033, STR0041, { STR0042 }, 2 )	//"Atenção", "Local já encerrado. Não permitido gerar movimentação", { "OK" } 
	Endif
Endif	

RestArea(aArea)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890VdSld

Função Para fazer validação do Material
@author  Joni Lima
@since 	  19/08/16
@version P12

@param oMdlGrid, Objeto, FwFormGrid
@param cCampo  , Caractre, Campo 
@param xValue  , x       , Valor a ser validado
@param nLin    , numerico, Linha Posicionada
@param xOldValue, x      , Valor Anterior do Campo

@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890VdSld(oMdlGrid,cCampo,xValue,nLin,xOldValue)

Local aArea			:= GetArea()
Local aSaveLines		:= FWSaveRows()
Local oModel			:= oMdlGrid:GetModel()
Local cTab				:= LEFT(cCampo,3)
Local cCodField 		:= cTab + '_COD' + IIF(cTab=='TFT','TFH','TFG')
Local cSldField 		:= cTab + '_SLDTTL'
Local cProdut			:= ""
Local cCodMat			:= ""
Local nX				:= 0
Local lRet				:= .T.
	
If ValType(oModel)=='O' .and. oModel:GetId()== 'TECA890'	 
	cCodMat := oMdlGrid:GetValue(cCampo)
	For nX := 1 To oMdlGrid:Length() 
		oMdlGrid:GoLine(nX)
		If  !oMdlGrid:IsDeleted() .and.;
			oMdlGrid:GetValue(cCodField) = cCodMat .and.;
			oMdlGrid:GetValue(cSldField) == 0 .and. nLin <> nX
			lRet := .F.
			oModel:GetModel():SetErrorMessage(oModel:GetId(),cCampo,oModel:GetModel():GetId(),cCampo,cCampo,; 
				STR0044, STR0045 ) //# 'Material não possui mais Saldo para apontamento' #'Verificar Material'  
		EndIf
	Next nX
	oMdlGrid:GoLine(nLin)//Volta para Linha 
EndIf
	
FWRestRows(aSaveLines)	
RestArea(aArea)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890TFHRetAr

Função que executa query para trazer valores iniciais para tela
@author  Joni Lima
@since 	  19/08/16
@version P12
@param cCond  , Caractere, Codigo para filtro 
@return lRet: Retorna array contendo os dados para {COdigo,Saldo,Saldo}
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890TFHRetAr(aCodTFL,lOrcPrc)
	
Local aArea 	:= GetArea()
Local aRet		:= {}
Local cAlias 	:= GetNextAlias()
Local cCond		:= ""
Local nX

Default lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.) 

For nX := 1 To Len(aCodTFL)
	If nX > 1
		cCond += "','"
	EndIf
	cCond += aCodTFL[nX][1]
Next nX

If lOrcPrc //Orçamento com tabela de Precificação
	BeginSql Alias cAlias
		SELECT
		TFH_COD,
		TFH_QTDVEN,
		TFH_SLD
		
		FROM %table:TFL% TFL
		
		INNER JOIN %table:TFH% TFH
		ON TFH.TFH_FILIAL = %xFilial:TFH%
		AND TFH.TFH_CODPAI = TFL.TFL_CODIGO
		
		WHERE
		TFL.TFL_FILIAL = %xFilial:TFL% AND
		TFL.TFL_CODIGO IN (%Exp:cCond%) AND
		TFL.%NotDel% AND
		TFH.%NotDel%
	EndSql
Else //orçamento Sem tabela de Precificação
	BeginSql Alias cAlias
		SELECT
		TFH_COD,
		TFH_QTDVEN,
		TFH_SLD
		
		FROM %table:TFL% TFL
		
		INNER JOIN %table:TFF% TFF
		ON TFF.TFF_FILIAL = %xFilial:TFF%
		AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
		
		INNER JOIN %table:TFH% TFH
		ON TFH.TFH_FILIAL = %xFilial:TFH%
		AND TFH.TFH_CODPAI = TFF.TFF_COD
		
		WHERE
		TFL.TFL_FILIAL = %xFilial:TFL% AND
		TFL.TFL_CODIGO IN (%Exp:cCond%) AND
		TFF.TFF_ENCE <> '1' AND
		TFL.%NotDel% AND
		TFF.%NotDel% AND
		TFH.%NotDel%
	EndSql
EndIf

While !(cAlias)->(Eof())
	AADD(aRet,{(cAlias)->TFH_COD ,(cAlias)->TFH_QTDVEN,(cAlias)->TFH_QTDVEN,(cAlias)->TFH_SLD})
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(DbCloseArea())
RestArea(aArea)
	
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890TFGRetAr

Função que executa query para trazer valores iniciais para tela
@author  Joni Lima
@since 	  19/08/16
@version P12
@param cCond  , Caractere, Codigo para filtro 
@return lRet: Retorna array contendo os dados para {COdigo,Saldo,Saldo}
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890TFGRetAr(aCodTFL, lOrcPrc)
	
Local aArea 	:= GetArea()
Local aRet		:= {}
Local cAlias 	:= GetNextAlias()
Local cCond		:= ""
Local nX

Default lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)

For nX := 1 To Len(aCodTFL)
	If nX > 1
		cCond += "','"
	EndIf
	cCond += aCodTFL[nX][1]
Next nX

If lOrcPrc //Orçamento com tabela de Precificação
	BeginSql Alias cAlias
		SELECT
		TFG_COD,
		TFG_QTDVEN,
		TFG_SLD
		
		FROM %table:TFL% TFL
		
		INNER JOIN %table:TFG% TFG
		ON TFG.TFG_FILIAL = %xFilial:TFG%
		AND TFG.TFG_CODPAI = TFL.TFL_CODIGO
		
		WHERE
		TFL.TFL_FILIAL = %xFilial:TFL% AND
		TFL.TFL_CODIGO IN (%Exp:cCond%) AND
		TFL.%NotDel% AND
		TFG.%NotDel%
	EndSql
Else //orçamento Sem tabela de Precificação
	BeginSql Alias cAlias
		SELECT
		TFG_COD,
		TFG_QTDVEN,
		TFG_SLD
		
		FROM %table:TFL% TFL
		
		INNER JOIN %table:TFF% TFF
		ON TFF.TFF_FILIAL = %xFilial:TFF%
		AND TFF.TFF_CODPAI = TFL.TFL_CODIGO
		
		INNER JOIN %table:TFG% TFG
		ON TFG.TFG_FILIAL = %xFilial:TFG%
		AND TFG.TFG_CODPAI = TFF.TFF_COD
		
		WHERE
		TFL.TFL_FILIAL = %xFilial:TFL% AND
		TFL.TFL_CODIGO IN (%Exp:cCond%) AND
		TFL.%NotDel% AND
		TFF.%NotDel% AND
		TFG.%NotDel%
	EndSql
EndIf
While !(cAlias)->(Eof())
	AADD(aRet,{(cAlias)->TFG_COD ,(cAlias)->TFG_QTDVEN,(cAlias)->TFG_QTDVEN, (cAlias)->TFG_SLD})
	(cAlias)->(DbSkip())
EndDo
(cAlias)->(DbCloseArea())

RestArea(aArea)
	
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  AT890VldTWY
Valida campos referentes a itens intercambiaveis
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function AT890VldTWY(cCodProd)
	
	Local lRet			:= .T.
	Local aAreaTWY	:= TWY->(GetArea())
	
	DbSelectArea("TWY")
	TWY->(DbSetOrder(1))
	If !TWY->(DbSeek(FwxFilial("TWY") + cCodProd))
		lRet	:= .F.
	Else
		If TWY->TWY_ATIVO != "1"
			lRet	:= .F.
		Endif
	Endif
	RestArea(aAreaTWY)
	
Return lRet



Static Function At890PrdPad(cCod,cTab)

	Local aArea   	:= GetArea()
	Local aAreaTFG 	:= TFG->(GetArea())
	local aAreaTFH 	:= TFH->(GetArea())
	Local cRet := ''
	Default cTab := ''
	
	If !Empty(cTab)
		If cTab == 'TFS'
			dbSelectArea('TFG')
			TFG->(DbSetOrder(1)) //TFG_FILIAL + TFG_COD
			If (TFG->(dbSeek(xFilial('TFG') + cCod)))
				cRet := TFG->TFG_PRODUT					
			EndIf
		ElseIf cTab == 'TFT'
			dbSelectArea('TFH')
			TFH->(DbSetOrder(1)) //TFH_FILIAL + TFH_COD
			
			If (TFH->(dbSeek(xFilial('TFH') + cCod)))
				cRet := TFH->TFH_PRODUT					
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaTFH)
	RestArea(aAreaTFG)
	RestArea(aArea)
	
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890ConsTWY
Monta tela de consulta padrão com dados da TWY
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890ConsTWY()
Local lRet				:= .T.
Local aCmpBco			:= {}
Local cQuery			:= ""
Local cDscCmp			:= ""
Local cConteudo		:= ""
Local cEntida			:= ""
Local cLocal			:= ""
Local cCdPrdTWY		:= ""
Local lOk				:= .F.
Local cPesq			:= Space(TamSX3("TFS_PRODUT")[1])
Local oPesqui			:= Nil //Objeto Pesquisa
Local oModel         := Nil //Modelo atual
Local oDlgCmp        := Nil //Dialog
Local oPanel         := Nil //Objeto Panel
Local oFooter        := Nil //Rodapé
Local oListBox       := Nil //Grid campos
Local oOk            := Nil //Objeto Confirma
Local oCancel        := Nil //Objeto Cancel
Local aSaveLines		:= {}
	
	aCmpBco := At890RtTWY()
	ProdTWY(cCdPrdTWY)
	
	If !Empty(aCmpBco)
		
		//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela
		Define MsDialog oDlgCmp FROM 000, 000 To 350, 550 Pixel
		//	Cria o Panel de pesquisa
		@ 000, 000 MsPanel oPesqui Of oDlgCmp Size 000, 012 // Coordenada para o panel
		oPesqui:Align   := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		@ 02,00 SAY STR0058 SIZE 70,10 PIXEL OF oPesqui//"Cod. Prod. Imp: "
		@ 001,075 GET oPesqui VAR cPesq SIZE 30,03 OF oDlgCmp PIXEL
		@ 001,247 BUTTON STR0055 SIZE 30,10 ACTION {|| At890Find(cPesq, oListBox, 2) } OF oDlgCmp PIXEL //"Pesquisar"
		//	Cria o panel principal
		@ 000, 000 MsPanel oPanel Of oDlgCmp Size 250, 340 // Coordenada para o panel
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		//	Criação do grid para o panel
		oListBox := TWBrowse():New( 40,05,204,100,,{STR0005,STR0006,STR0007},,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Código"###"Produto"###"Desc Produto"
		oListBox:SetArray(aCmpBco) // Atrela os dados do grid com a matriz
		oListBox:bLine := { ||{aCmpBco[oListBox:nAT][1], aCmpBco[oListBox:nAT][2], aCmpBco[oListBox:nAT][3]}} // Indica as linhas do grid
		oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgCmp:End()} // Duplo clique executa a ação do objeto indicado
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
		//	Cria o panel para os botoes
		@ 000, 000 MsPanel oFooter Of oDlgCmp Size 000, 010 // Corrdenada para o panel dos botoes (size)
		oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		//	Botoes para o grid auxiliar
		@ 000, 000 Button oCancel Prompt STR0008  Of oFooter Size 030, 000 Pixel //"Cancelar"
		oCancel:bAction := { || lOk := .F., oDlgCmp:End() }
		oCancel:Align   := CONTROL_ALIGN_RIGHT
		@ 000, 000 Button oOk     Prompt STR0009 Of oFooter Size 030, 000 Pixel //"Confirmar"
		oOk:bAction     := { || lOk := .T.,cCdPrdTWY:=aCmpBco[oListBox:nAT][2],oDlgCmp:End() } // Acao ao clicar no botao
		oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
		cProdut:= aCmpBco[oListBox:nAT][2]
		//	Ativa a tela exibindo conforme a coordenada
		Activate MsDialog oDlgCmp Centered
		
		//	Utilizar o modelo ativo para substituir os valores das variaves de memoria
		oModel      := FWModelActive()
		
		If lOk
			aSaveLines	:= FWSaveRows()
			ProdTWY(cCdPrdTWY) //Altera a váriavel Static para executar o SetValue
			FwRestRows( aSaveLines )
		EndIf
	Else
		Help( ,, 'Help',, STR0010, 1, 0 )//"Não há Materiais de Consumo para este Local de Atendimento"
	EndIf
	
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890RtTWY
Monta array com dados da TWY
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At890RtTWY()
	
	Local aRet       	:= {}
	Local aAreaTWY		:= TWY->(GetArea())
	Local oModel 		:= FwModelActive()
	Local oMdlTFS		:= oModel:GetModel('TFSGRID')
	Local cCond 		:= oMdlTFS:GetValue('TFS_CODTFG')//&(READVAR())//FwFldGet("TFS_CODTFG")
	Local cProdPdr		:= At890PrdPad(cCond,'TFS')
	
	DbSelectArea("TWY")
	DbsetOrder(1)
	
	If TWY->(DbSeek(FwxFilial("TWY") + cProdPdr ))
		While TWY->(!Eof()) .And. Alltrim(TWY->TWY_CODPRO) == Alltrim(cProdPdr)
			If TWY->TWY_ATIVO == "1"
				aAdd(aRet,{TWY->TWY_CODPRO, TWY->TWY_CODINT, Posicione("SB1", 1, xFilial("SB1") + TWY->TWY_CODINT, "B1_DESC")})
				TWY->(DbSkip())
			Endif
		EndDo
	Endif
	RestArea(aAreaTWY)
Return(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890RetII
Retorna informação para campo TFS_PRODUT
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890RetII()
	Local oModel	:= FWModelActive()
	Local cRet := (oModel:GetValue( 'TFSGRID', 'TFS_PRODUT' ))
	If Empty(cRet)
		cRet := ProdTWY()
	EndIf
Return cRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890TWYTFT 
Monta tela de consulta padrão com dados da TWY
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890TWYTFT()
	
Local lRet			:= .T.
Local aCmpBco		:= {}
Local cQuery		:= ""
Local cDscCmp		:= ""
Local cConteudo	:= ""
Local cEntida		:= ""
Local cLocal		:= ""
Local cCdPrdTWY	:= ""
Local lOk			:= .F.
Local cPesq			:= Space(TamSX3("TFT_PRODUT")[1])
Local oPesqui		:= Nil //Objeto Pesquisa
Local oModel        := Nil //Modelo atual
Local oDlgCmp       := Nil //Dialog
Local oPanel        := Nil //Objeto Panel
Local oFooter       := Nil //Rodapé
Local oListBox      := Nil //Grid campos
Local oOk           := Nil //Objeto Confirma
Local oCancel       := Nil //Objeto Cancel
Local aSaveLines	:= {}
	
	aCmpBco := At890TWYRet()
	ProdTWY(cCdPrdTWY)
	
	If !Empty(aCmpBco)
		
		//    Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela
		Define MsDialog oDlgCmp FROM 000, 000 To 350, 550 Pixel
		
	//Cria o Panel de pesquisa
	@ 000, 000 MsPanel oPesqui Of oDlgCmp Size 000, 012 // Coordenada para o panel
	oPesqui:Align   := CONTROL_ALIGN_TOP //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	      
	@ 02,00 SAY STR0059 SIZE 70,10 PIXEL OF oPesqui//"Cod. Prod. Cons: "
	      
	@ 001,065 GET oPesqui VAR cPesq SIZE 25,03 OF oDlgCmp PIXEL
	            
	@ 001,247 BUTTON STR0055 SIZE 30,10 ACTION {|| At890Find(cPesq, oListBox, 2) } OF oDlgCmp PIXEL //"Pesquisar"	
	
	
		// Cria o panel principal
		@ 000, 000 MsPanel oPanel Of oDlgCmp Size 250, 340 // Coordenada para o panel
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		
		// Criação do grid para o panel
		oListBox := TWBrowse():New( 40,05,204,100,,{STR0005,STR0006,STR0007},,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Código"###"Produto"###"Desc Produto"
		oListBox:SetArray(aCmpBco) // Atrela os dados do grid com a matriz
		oListBox:bLine := { ||{aCmpBco[oListBox:nAT][1], aCmpBco[oListBox:nAT][2], aCmpBco[oListBox:nAT][3]}} // Indica as linhas do grid
		oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgCmp:End()} // Duplo clique executa a ação do objeto indicado
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
		
		// Cria o panel para os botoes
		@ 000, 000 MsPanel oFooter Of oDlgCmp Size 000, 010 // Corrdenada para o panel dos botoes (size)
		oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		
		// Botoes para o grid auxiliar
		@ 000, 000 Button oCancel Prompt STR0008  Of oFooter Size 030, 000 Pixel //"Cancelar"
		oCancel:bAction := { || lOk := .F., oDlgCmp:End() }
		oCancel:Align   := CONTROL_ALIGN_RIGHT
		
		@ 000, 000 Button oOk     Prompt STR0009 Of oFooter Size 030, 000 Pixel //"Confirmar"
		oOk:bAction     := { || lOk := .T.,cCdPrdTWY:=aCmpBco[oListBox:nAT][2],oDlgCmp:End() } // Acao ao clicar no botao
		oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
		cProdut:= aCmpBco[oListBox:nAT][2]
		// Ativa a tela exibindo conforme a coordenada
		Activate MsDialog oDlgCmp Centered
		
		//Utilizar o modelo ativo para substituir os valores das variaves de memoria
		oModel      := FWModelActive()
		
		If lOk
			aSaveLines	:= FWSaveRows()
			ProdTWY(cCdPrdTWY)//Altera a váriavel Static para executar o SetValue
			FwRestRows( aSaveLines )
		EndIf
	Else
		Help( ,, 'Help',, STR0010, 1, 0 )//"Não há Materiais de Consumo para este Local de Atendimento"
	EndIf
	
Return(lRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890TWYTFT
Monta array com dados da TWY
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At890TWYRet()
	
	Local aRet      := {}
	Local aAreaTWY	:= TWY->(GetArea())
	Local aArea		:= GetArea()
	Local oModel 		:= FwModelActive()
	Local oMdlTFT		:= oModel:GetModel('TFTGRID')
	Local cCond 		:= oMdlTFT:GetValue('TFT_CODTFH')
	Local cProdPdr		:= At890PrdPad(cCond,'TFT')
	
	DbSelectArea("TWY")
	TWY->(DbsetOrder(1))
	
	If TWY->(DbSeek(FwxFilial("TWY") + cProdPdr ))
		While TWY->(!Eof()) .And. Alltrim(TWY->TWY_CODPRO) == Alltrim(cProdPdr)
			If TWY->TWY_ATIVO == "1"
				aAdd(aRet,{TWY->TWY_CODPRO, TWY->TWY_CODINT, Posicione("SB1", 1, xFilial("SB1") + TWY->TWY_CODINT, "B1_DESC")})
				TWY->(DbSkip())
			Endif
		EndDo
	Endif
	RestArea(aArea)
	RestArea(aAreaTWY)
Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890RtTFT
Retorna informação para campo TFS_PRODUT
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At890RtTFT()
	Local oModel	:= FWModelActive()
	Local cRet := (oModel:GetValue( 'TFTGRID', 'TFT_PRODUT' ))
	If Empty(cRet)
		cRet := ProdTWY()
	EndIf
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890TWYVld
Valida campos referentes a itens intercambiaveis
no Modulo Gestão Serviços
@author  Serviços
@since 	  05/09/2016
@version P12
@return lRet: Retorna .T. quando os campos estiverem ok.
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At890TWYVld(cCodPrd)
	
Local aAreaTWY := TWY->(GetArea())
Local aArea	 := GetArea()
Local lRet		 := .T.
Local lChk		 := .T.
Local oModel 	 := FwModelActive()
Local oView 	 := FwViewActive()
Local cCpoGrd	 := ReadVar()
Local cCpoOrig := ""
Local cCodori 	:= cCodPrd 

Default cCodPrd  := ""

If SubStr(cCpoGrd,4,3) == "TFT"
	cCpoGrd	:=  SubStr(cCpoGrd,4,10)
	If cCpoGrd	 != "TFT_PRODUT"
		Return lRet
	Else
		cCpoOrig	:= oModel:GetModel('TFTGRID'):GetValue('TFT_CODTFH') //FWFLDGET("TFT_CODTFH")
		cCodPrd	:= oModel:GetModel('TFTGRID'):GetValue('TFT_PRODUT')
		lChk	:= .F.
	Endif
ElseIf SubStr(cCpoGrd,4,3) == "TFS"
	cCpoGrd	:=  SubStr(cCpoGrd,4,10)
	If cCpoGrd	 != "TFS_PRODUT"
		Return lRet
	Else
		cCpoOrig	:= oModel:GetModel('TFSGRID'):GetValue('TFS_CODTFG') //FWFLDGET("TFS_CODTFG")
		cCodPrd	:= oModel:GetModel('TFSGRID'):GetValue('TFS_PRODUT')
		lChk	:= .F.
	Endif
Endif
	
If !lChk .And. lRet
	DbSelectArea("TWY")
	TWY->(DbSetOrder(2))//TWY_FILIAL+TWY_CODINT
	If !TWY->(DbSeek(FwxFilial("TWY") + cCodPrd)) .And. cCodori <> cCodPrd
		Help( ,, 'AT890TWY',, STR0047, 1, 0 ) // "Produto escolhido não tem Itens Intercambiaveis cadastrados."
			lRet	:= .F.
	Else
		If TWY->TWY_ATIVO == "2"
			Help( ,, 'AT890ATIVO',, STR0046, 1, 0 ) // Este Produto esta Bloqueado para uso.
			lRet	:= .F.
		Endif
	Endif
Endif
	
If lRet
	dbSelectArea("SB5")
	SB5->(dbSetOrder(1))
	If SB5->(dbSeek(xFilial("SB5")+cCodPrd))
		If cCpoGrd == "TFS_PRODUT" //MI
			If SB5->B5_GSMI <> "1"
				Help( ,, 'AT890NOMI',, STR0038, 1, 0 ) //"Produto selecionado não é um Material de implantação. Escolha um produto MI! "
				lRet := .F.
			EndIf
		ElseIf cCpoGrd == "TFT_PRODUT" //MC
			If SB5->B5_GSMC <> "1"
				Help( ,, 'AT890NOMC',, STR0040, 1, 0 ) //"Produto selecionado não é um Material de consumo. Escolha um produto MC! "
				lRet := .F.			
			EndIf
		EndIf
	Else
		Help( ,, 'AT890SB5',, STR0036, 1, 0 ) //"Produto selecionado possui cadastro na rotina de complemento de produto (SB5), escolha um produto que já esteja cadastrado. "
		lRet := .F.
	EndIf
EndIf
	
	RestArea(aArea)
	RestArea(aAreaTWY)
	
	If !IsBlind() .AND. VALTYPE(oView) == 'O'
		oView:Refresh()
	EndIf
	
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At890Find
Posiciona no registro das consultas especificas do apontamento de materiais
@author  Serviços
@param cPesq	, Caracter	, conteudo do Get de pesquisa
@param oListBox	, objeto	, Grid com os produtos 
@param nOpc		, numérico	, Valor quando é a consulta dos códigos ou produtos 
@since 	  15/12/2016
@version P12
@return nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890Find(cPesq, oListBox, nOpc)
Local nPos := 0

If !Empty(cPesq)
	If nOpc == 1
		nPos := ASCAN(oListBox:aArray,{|x| alltrim(x[1]) == alltrim(cPesq)})
	ElseIf nOpc == 2
		nPos := ASCAN(oListBox:aArray,{|x| alltrim(x[2]) == alltrim(cPesq)})
	EndIf
	
	If nPos <> 0 
		oListBox:GoPosition(nPos)
		oListBox:Refresh()
	EndIf
EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890Delet
Calcula o saldo nas ações de Delete
@author diego.bezerra
@since 	  21/02/2018
@version P12
@return nil
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At890Delet(ctabAlias, oAtModel, nVlDel, cCodigo )

Local nX				:= 1
Local aSaveLines 		:= FwSaveRows()
Local nSld 			:= 0
Local lRet 			:= .T.
Local nQuant 			:= 0
Local nQuantant 		:= 0
Local oView			:= FwViewActive()
Local nTSld 			:= 0
Local lCntrRec		:= .T.
Local nSldTFH		:= 0
Local lCntRec		:= .F.
Local dDtIni 		:= FirstDate(dDataBase)
Local dDtFim 		:= LastDate(dDataBase)
Local lGsApmat   := SuperGetMv('MV_GSAPMAT',.F.,.F.)
Local lTFTCampo  := (TFT->(ColumnPos("TFT_CODSA"))>0)
Local lTFSCampo  := (TFS->(ColumnPos("TFS_CODSA"))>0)

If (ctabAlias)->(DbSeek(xFilial(ctabAlias)+cCodigo))
	If ctabAlias == "TFG"
		If (lGsApmat .And. lTFSCampo .And. !Empty(oAtModel:GetValue("TFS_NUMMOV"))) .or. Empty(oAtModel:GetValue("TFS_CODTFG")) .or. !At890Vsfe(oAtModel:GetValue("TFS_CODSA")) 
			cProdut:= oAtModel:GetValue("TFS_CODTFG")
			For nX := 1 To oAtModel:Length() 
				oAtModel:GoLine(nX)
				If oAtModel:GetValue("TFS_CODTFG") == cProdut
					nQuant := nQuant + oAtModel:GetValue("TFS_QUANT")
					nQuantant:= nQuantant+Posicione("TFS", 1, xFilial("TFS") + oAtModel:GetValue("TFS_CODIGO"), "TFS_QUANT")
					If !oAtModel:IsDeleted()
						nTSld = oAtModel:GetValue("TFS_SLDTTL")
					EndIf
				EndIf
			Next nX
			If (ctabAlias)->TFG_SLD + nQuantant - nQuant >= 0
				lRet := .T.
				nSld:= nTSld + nVlDel
				For nX := 1 To oAtModel:Length() 
					oAtModel:GoLine(nX)
					If oAtModel:GetValue("TFS_CODTFG") == cProdut 
						oAtModel:LoadValue("TFS_SLDTTL", nSld )
					EndIf
				Next nX	
			Else
				HELP(,,'Saldo',,STR0020) //"Saldo insuficiente para esta quantidade!"
				lRet:= .F.
			EndIf

		Else
			Help( "", 1, "At890Delet", , STR0183, 1, 0,,,,,,; // "Parâmetro MV_BLQREVI está ativo e não pode acontecer medição para valor menor."
																	{STR0184})
			lRet:= .F.		
	Endif

		
	Elseif ctabAlias == "TFH"
		If (lGsApmat .And. lTFTCampo .And. !Empty(oAtModel:GetValue("TFT_NUMMOV"))) .or. Empty(oAtModel:GetValue("TFT_CODTFH")) .or. !At890Vsfe(oAtModel:GetValue("TFT_CODSA")) 
			lCntRec := oAtModel:GetModel():GetValue("TFLMASTER","TFL_CNTREC") == "1"
			cProdut:= oAtModel:GetValue("TFT_CODTFH")
			For nX := 1 To oAtModel:Length() 
				oAtModel:GoLine(nX)
				If lCntRec 
					If oAtModel:GetValue("TFT_CODTFH") == cProdut .And.;
						oAtModel:GetValue("TFT_DTAPON") >= dDtini .And.;
						oAtModel:GetValue("TFT_DTAPON") <= dDtFim
						nQuant := nQuant + oAtModel:GetValue("TFT_QUANT")
						nQuantant:= nQuantant+Posicione("TFT", 1, xFilial("TFT") + oAtModel:GetValue("TFT_CODIGO"), "TFT_QUANT")
						If !oAtModel:IsDeleted()
							nTSld = oAtModel:GetValue("TFT_SLDTTL")
						EndIf
					Endif
				Else
					If oAtModel:GetValue("TFT_CODTFH") == cProdut
						nQuant := nQuant + oAtModel:GetValue("TFT_QUANT")
						nQuantant:= nQuantant+Posicione("TFT", 1, xFilial("TFT") + oAtModel:GetValue("TFT_CODIGO"), "TFT_QUANT")
						If !oAtModel:IsDeleted()
							nTSld = oAtModel:GetValue("TFT_SLDTTL")
						EndIf
					EndIf
				Endif
			Next nX
			
			If lCntrRec
				nSldTFH := At890SldRc((ctabAlias)->TFH_COD)
			Else
				nSldTFH := (ctabAlias)->TFH_SLD
			Endif
			
			If nSldTFH + nQuantant - nQuant >= 0
				lRet := .T.
				nSld:= nTSld + nVlDel
				For nX := 1 To oAtModel:Length() 
					oAtModel:GoLine(nX)
					If lCntRec 
						If oAtModel:GetValue("TFT_CODTFH") == cProdut .And.;
							oAtModel:GetValue("TFT_DTAPON") >= dDtini .And.;
							oAtModel:GetValue("TFT_DTAPON") <= dDtFim
							oAtModel:LoadValue("TFT_SLDTTL", nSld )
						EndIf
					Else
						If oAtModel:GetValue("TFT_CODTFH") == cProdut 
							oAtModel:LoadValue("TFT_SLDTTL", nSld )
						EndIf
					Endif
				Next nX
			Else
				HELP(,,'Saldo',,STR0020) //"Saldo insuficiente para esta quantidade!"
				lRet:= .F.
			EndIf	
		Else
			Help( "", 1, "At890Delet", , STR0183, 1, 0,,,,,,; // "Parâmetro MV_BLQREVI está ativo e não pode acontecer medição para valor menor."
																	{STR0184})
			lRet:= .F.				
		Endif
	EndIf	
EndIf

FWRestRows(aSaveLines)
If Valtype(oView) == 'O'
	oView:Refresh()
EndIf
Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890Undel
Cálcula o saldo nas ações de Undelete
@author diego.bezerra
@since 	  21/02/2018
@version P12
@return nil
/*/
//--------------------------------------------------------------------------------------------------------------------

Static Function At890Undel(ctabAlias, oAtModel, nVlDel, cCodigo, nLine)

Local nX					:= 1
Local aSaveLines 			:= FwSaveRows()
Local nSld 				:= 0
Local lRet 				:= .T.
Local nQuant 				:= 0
Local nQuantant 			:= 0
Local nTSld 				:= 0
Local oView				:= FwViewActive()
Local lCntRec		:= .F.
Local dDtIni 		:= FirstDate(dDataBase)
Local dDtFim 		:= LastDate(dDataBase)

If (ctabAlias)->(DbSeek(xFilial(ctabAlias)+cCodigo))
	lCntRec := (oAtModel:GetModel():GetValue("TFLMASTER","TFL_CNTREC") == "1")
	If ctabAlias == "TFG" 
		cProdut:= oAtModel:GetValue("TFS_CODTFG")	
		For nX := 1 To oAtModel:Length() 
			oAtModel:GoLine(nX)
			If oAtModel:GetValue("TFS_CODTFG") == cProdut
				nQuant := nQuant + oAtModel:GetValue("TFS_QUANT")
				nQuantant:= nQuantant + Posicione("TFS", 1, xFilial("TFS") + oAtModel:GetValue("TFS_CODIGO"), "TFS_QUANT")
				nTSld = oAtModel:GetValue("TFS_SLDTTL")
			EndIf
		Next nX
		If nTSld + nQuantant - nQuant >= 0
			lRet := .T.
			nSld:= nTSld - nVlDel
			For nX := 1 To oAtModel:Length() 
				oAtModel:GoLine(nX)
				If oAtModel:GetValue("TFS_CODTFG") == cProdut 
					oAtModel:LoadValue("TFS_SLDTTL", nSld )
				EndIf
			Next nX	
		Else
			oAtModel:GoLine(nLine)
			oAtModel:LoadValue("TFS_QUANT", 0)
			HELP(,,'Saldo',,STR0020) //"Saldo insuficiente para esta quantidade!"
			lRet:= .F.
			oView:Refresh()
		EndIf
	ElseIf ctabAlias == "TFH" 
		cProdut:= oAtModel:GetValue("TFT_CODTFH")	
		For nX := 1 To oAtModel:Length() 
			oAtModel:GoLine(nX)
			If lCntRec
				If oAtModel:GetValue("TFT_CODTFH") == cProdut .And.;
					oAtModel:GetValue("TFT_DTAPON") >= dDtini .And.;
					 oAtModel:GetValue("TFT_DTAPON") <= dDtFim
					nQuant := nQuant + oAtModel:GetValue("TFT_QUANT")
					nQuantant := nQuantant + Posicione("TFT", 1, xFilial("TFT") + oAtModel:GetValue("TFT_CODIGO"), "TFT_QUANT")
					nTSld = oAtModel:GetValue("TFT_SLDTTL")
				EndIf
			Else
				If oAtModel:GetValue("TFT_CODTFH") == cProdut
					nQuant := nQuant + oAtModel:GetValue("TFT_QUANT")
					nQuantant := nQuantant + Posicione("TFT", 1, xFilial("TFT") + oAtModel:GetValue("TFT_CODIGO"), "TFT_QUANT")
					nTSld = oAtModel:GetValue("TFT_SLDTTL")
				EndIf
			Endif
		Next nX
		If nTSld + nQuantant - nQuant >= 0
			lRet := .T.
			nSld:= nTSld - nVlDel
			For nX := 1 To oAtModel:Length() 
				oAtModel:GoLine(nX)
				If lCntRec
					If oAtModel:GetValue("TFT_CODTFH") == cProdut .And.;
						oAtModel:GetValue("TFT_DTAPON") >= dDtini .And.;
					 	 oAtModel:GetValue("TFT_DTAPON") <= dDtFim
						oAtModel:LoadValue("TFT_SLDTTL", nSld )
					EndIf
				Else
					If oAtModel:GetValue("TFT_CODTFH") == cProdut 
						oAtModel:LoadValue("TFT_SLDTTL", nSld )
					EndIf
				Endif	
			Next nX
		Else
			oAtModel:GoLine(nLine)
			oAtModel:LoadValue("TFT_QUANT", 0)
			oView:Refresh()
			HELP(,,'Saldo',,STR0020) //"Saldo insuficiente para esta quantidade!"
			lRet:= .F.
		EndIf
	EndIf
EndIf
FWRestRows(aSaveLines)

If valtype(oView) == 'O'
	oView:Refresh()
EndIf

Return lRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProdTWY

@author Mateus Boiani
@since 03/09/2018
@description Função utilizada para controlar o valor retornado no F3 dos campos TFT_PRODUT e TFS_PRODUT
@param cProd	, string, Váriavel de setValue
@return cPrdF3, string, Váriavel static
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ProdTWY(cProd)
If VALTYPE(cProd) == "C"
	cPrdF3 := cProd
EndIf
Return cPrdF3

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890NGMat

@author fabiana.silva
@since 04/06/2019
@description Verifica se a funcionalidade de gestão de Materiais está atualizada
@return lRet - Funcionalidade habilitada
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At890NGMat()
Local lRet := .F.
Local aAreaSX3 := {}
Local cCombo := ""

aAreaSX3 := SX3->(GetArea())

SX3->(DbSetOrder(2)) //X3_CAMPO
If SX3->(DbSeek("TFJ_GESMAT"))
	cCombo := SX3->(X3CBox())
	lRet := ( "4=" $ cCombo .AND. "5=" $ cCombo)
EndIf
RestArea(aAreaSX3)

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890ApVl

@author Diego Bezerra
@since 20/09/2019
@param oModel, objeto, modelo ativo
@description Pós valide que verifica se um apontamento pode ser estornado
@return lRet - .F. = Item  não pode ser estornado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890ApVl(oModel)

Local lRet 		:= .T.
Local aTotais 	:= {}
Local nX		:= 0
Local oModelTFS	:= oModel:GetModel("TFSGRID")
Local lDeleted	:= .F.
Local aTfs		:= {}
Local nPos		:= 0

For nX := 1 to oModelTFS:Length()
	oModelTFS:GoLine(nX)
	If !lDeleted
		lDeleted := oModelTFS:IsDeleted()
	EndIf
	If oModelTFS:IsDeleted()
		nPos := ASCAN(aTfs,{|x| x[1] == oModelTFS:GetValue("TFS_CODTFG")})
		
		If nPos > 0
			aTfs[nPos][2] += oModelTFS:GetValue("TFS_QUANT")
		Else
			aAdd(aTfs,{oModelTFS:GetValue("TFS_CODTFG"),oModelTFS:GetValue("TFS_QUANT")})
		EndIf
	EndIf
Next nX

If lDeleted
	For nX := 1 to Len(aTfs)
		aTotais := At890TotA(aTfs[nX][1])
		If Len(aTotais) > 1
			If ((aTotais[1][2]-aTfs[nX][2]) < aTotais[2][2])
				lRet := .F.
			EndIf
		EndIf
	Next nX
EndIf

If !lRet
	Help( ' ', 1, 'SALDO INCORRETO', ,STR0132,1,0)	//"Essa operação não pode ser realizada. O saldo de materiais não pode ser menor que o total retornado."
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890TotA

@author Diego Bezerra
@since 20/09/2019
@param cCodTFG, string, código da TFG(Material de Implantação) relacionada ao apontamento 
@description Verifica as quantidades de materiais de implantação apontados / retornados
@return aTotais, array, contém os valores apontados e retornados
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890TotA(cCodTFG)

Local aTotais	:= {}
Local cQueryTFS	:= ""
Local cAliasTFS	:= getNextAlias()

cQueryTFS := "SELECT '1' as TP_MOV, CASE WHEN SUM(TFS_QUANT) IS NOT NULL THEN SUM(TFS_QUANT) ELSE 0 END AS APONTADO FROM "
cQueryTFS += retSqlName("TFS")+" where TFS_CODTFG = '"+cCodTFG+"' AND TFS_MOV = '1' AND TFS_FILIAL = '"+xFilial("TFS")+"' AND D_E_L_E_T_ = ' '"
cQueryTFS += " UNION ALL "
cQueryTFS += "SELECT '2' as TP_MOV, CASE WHEN SUM(TFS_QUANT) IS NOT NULL THEN SUM(TFS_QUANT) ELSE 0 END AS APONTADO FROM "
cQueryTFS += retSqlName("TFS")+" where TFS_CODTFG = '"+cCodTFG+"' AND TFS_MOV = '2' AND TFS_FILIAL = '"+xFilial("TFS")+"' AND D_E_L_E_T_ = ' '"

cQueryTFS	:= ChangeQuery(cQueryTFS)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQueryTFS),cAliasTFS, .F., .T.)

While (cAliasTFS)->(!EOF())
	aAdd(aTotais,{(cAliasTFS)->TP_MOV,(cAliasTFS)->APONTADO })
	(cAliasTFS)->(DbSkip())
EndDo
(cAliasTFS)->(dbCloseArea())

Return aTotais
//-------------------------------------------------------------------------------------------------------------------------

/*/{Protheus.doc} At890TM(cAliasMat) 

		Validar tipo de movimento no apontamrnto do Material de Implantação e de Consumo
@author Junior Geraldo Dos Santos	
@since		03/10/2019
@version 	P12
@return lRet - .F. = Não pode utilizar tipos de movimentos que sejam diferente de "R", ou seja, Requisição  
/*/
Function At890TM(cAliasMat)

Local oModel     := FWModelActive()
Local oModelTFS	 := oModel:GetModel("TFSGRID")
Local oModelTFT	 := oModel:GetModel("TFTGRID")
Local lRet       := .T.
Local cTipo      := ""
Default cAliasMat  := ""

//verifica se o tipo de movimento é de requisição "R"
If cAliasMat =="TFS"
	If !Empty(oModelTFS:GetValue("TFS_TM"))
		cTipo:=Posicione("SF5",1,xFilial("SF5")+oModelTFS:GetValue("TFS_TM"),"F5_TIPO")
		
		If cTipo <> "R"
			Aviso( STR0133, STR0134 ,{  }, 2 )// "Tipo de Movimentação Inválido","Deve-se usar o tipo de movimento de requisição."
			lRet:= .F.
		Endif
	EndIf
ElseIf cAliasMat =="TFT"
	If !Empty(oModelTFT:GetValue("TFT_TM"))	
		cTipo:=Posicione("SF5",1,xFilial("SF5")+oModelTFT:GetValue("TFT_TM"),"F5_TIPO")
		
		If cTipo <> "R"
			Aviso( STR0133, STR0134 ,{  }, 2 )// "Tipo de Movimentação Inválido","Deve-se usar o tipo de movimento de requisição."
			lRet:= .F.
		Endif
	EndIf
EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT890VlLoc
@description  Valid do campo TFT_CODTFH e TFS_CODTFG 
@return lRet - se o material é pertencente ao local de atendimento selecionado
@author Augusto Albuquerque
@since  16/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT890VlLoc( cGrid, cCodLocal)
Local cAlias	:= GetNextAlias()
Local cCod		:= ""	
Local lOrcPrc 	:= SuperGetMv("MV_ORCPRC",,.F.) 
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelTFS	:= oModel:GetModel("TFSGRID")
Local oModelTFT	:= oModel:GetModel("TFTGRID")

Default cGrid		:= ""
Default cCodLocal	:= "" 

If cGrid == "TFS"
	cCod := oModelTFS:GetValue("TFS_CODTFG")
	If lOrcPrc
		BeginSql Alias cAlias
			SELECT COUNT(1) CONT
			FROM %table:TFG% TFG
			WHERE 
				TFG.TFG_FILIAL = %xFilial:TFG%
				AND TFG.TFG_COD = %Exp:cCod%
				AND TFG.TFG_CODPAI = %Exp:cCodLocal%
				AND TFG.%NotDel% 	
		EndSql
	
	Else
		BeginSql Alias cAlias
			SELECT COUNT(1) CONT
			FROM %table:TFG% TFG
			
			INNER JOIN %Table:TFF% TFF
				 ON TFF.TFF_FILIAL = %xFilial:TFF%  
				 AND TFG.TFG_CODPAI = TFF.TFF_COD
				 AND TFF.%NotDel%
			WHERE
				TFG.TFG_FILIAL = %xFilial:TFG% 
				AND TFG.TFG_COD = %Exp:cCod%
				AND TFF.TFF_CODPAI = %Exp:cCodLocal%	
				AND TFF.TFF_ENCE <> '1'
				AND TFF.%NotDel%  
				
		EndSql
	EndIf
	
	lRet := ((cAlias)->CONT > 0)
	(cAlias)->(DbCloseArea())
ElseIf cGrid == "TFT"
	cCod := oModelTFT:GetValue("TFT_CODTFH")
	If lOrcPrc
		BeginSql Alias cAlias
			SELECT COUNT(1) CONT
			FROM %table:TFH% TFH
			WHERE 
				TFH.TFH_FILIAL = %xFilial:TFH%
				AND TFH.TFH_COD = %Exp:cCod%
				AND TFH.TFH_CODPAI = %Exp:cCodLocal%
				AND TFH.%NotDel% 	
		EndSql
	Else
		BeginSql Alias cAlias
			SELECT COUNT(1) CONT
			FROM %table:TFH% TFH
			
			INNER JOIN %Table:TFF% TFF
				 ON TFF.TFF_FILIAL = %xFilial:TFF%  
				AND TFH.TFH_CODPAI = TFF.TFF_COD 
				AND TFF.%NotDel%
			WHERE
				TFH.TFH_FILIAL = %xFilial:TFH% 
				AND TFH.TFH_COD = %Exp:cCod% 	
				AND TFF.TFF_CODPAI = %Exp:cCodLocal%
				AND TFF.TFF_ENCE <> '1'
				AND TFH.%NotDel%  
				
		EndSql
	EndIf
	lRet := ((cAlias)->CONT > 0)
	(cAlias)->(DbCloseArea())
EndIf

If !lRet
	Help(NIL, NIL, "AT890VlLoc", NIL, STR0135 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0136}) // "Material selecionado não pertence ao local." ## "Selecione um material que faça parte do local!"
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT890CodTFL
@description  Função para retorno dos locais de atendimento
@return aRet - Retorno de todos os locais de atendimento do contrato
@author Augusto Albuquerque
@since  31/12/2019
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT890CodTFL(cCodTFJ)
Local aRet		:= {}
Local cAliasTFJ	:= GetNextAlias()

BeginSql Alias cAliasTFJ
	SELECT
	TFL.TFL_CODIGO	
	FROM %table:TFJ% TFJ

	INNER JOIN %table:TFL% TFL
		ON TFL.TFL_FILIAL = %xFilial:TFL%
		AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
		AND TFL.TFL_CONTRT = TFJ.TFJ_CONTRT
		AND TFL.TFL_CONREV = TFJ.TFJ_CONREV
		AND TFL.%NotDel%
	WHERE
		TFJ.TFJ_FILIAL = %xFilial:TFJ%
		AND TFJ.TFJ_CODIGO = %Exp:cCodTFJ% 
		AND TFJ.%NotDel%
EndSql

While !(cAliasTFJ)->(Eof())
	AADD( aRet, {(cAliasTFJ)->(TFL_CODIGO)})
	(cAliasTFJ)->(DbSkip())	
EndDo
(cAliasTFJ)->(DbCloseArea())
Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890CntRc
@description  Saldo do material recorrente.
@return nSldRec
@author Kaique Schiller
@since  11/06/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At890SldRc(cCodTFH)
Local nSldRec 	:= 0
Local cAliasQry := GetNextAlias()
Local dDtIni 	:= FirstDate(dDataBase)
Local dDtFim 	:= LastDate(dDataBase)

BeginSql Alias cAliasQry
	SELECT TFH_QTDVEN-COALESCE(SUM(TFT.TFT_QUANT),0) SLDREC
	FROM %table:TFH% TFH
	LEFT JOIN %table:TFT% TFT
			ON TFT.TFT_FILIAL = %xFilial:TFT%
		AND TFT.TFT_CODTFH = TFH.TFH_COD
		AND TFT.TFT_DTAPON BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
		AND TFT.%NotDel%
	WHERE
		TFH.TFH_FILIAL = %xFilial:TFH% AND
		TFH.TFH_COD    = %Exp:cCodTFH% AND
		TFH.%NotDel%
	GROUP BY TFH_QTDVEN
EndSql

If !(cAliasQry)->(Eof())					 
	nSldRec := (cAliasQry)->SLDREC
Endif

(cAliasQry)->(DbCloseArea())

Return nSldRec

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At890CpAp
@description  Abre tela para copiar apontamento de materiais
@author Diego Bezerra
@since  07/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Function At890CpAp( oModel, oView  )

Local oMdlTFL	
Local oMdlTFT	
Local oMdlTFS	
Local cCodTfl 	
Local nGesMat		:= TFJ->TFJ_GESMAT	
Local oDlgSelect
Local oSair
Local oBuscar
Local oLimpar
Local oDataDe
Local oDataAte
Local oListMI
Local oListMC
Local oListTGU
Local oMarkT    	:= LoadBitmap(GetResources(), "LBOK")
Local oMarkF     	:= LoadBitmap(GetResources(), "LBNO")
Local dGetDtDe 		:= Date()
Local dGetDtAte 	:= Date()
Local aDtParam		:= {}
Local nPosBtn		:= 0
Local nPosBtn2		:= 0
Local cTitulo		:= ""
Local aCpTFS		:= {}
Local aCpTFT		:= {}
Local aCpTGU		:= {}
Local nSize			:= 210
Local nPosic		:= 220
Local lRec			:= TFJ->TFJ_CNTREC == '1'
Local cIdMdl		:= oModel:GetId() 
Local aSorting   	:= {0, .F.}

If nGesMat == '4' .OR. nGesMat == '5'
	nSize	:= 420
	nPosic	:= 007
EndIf

If cIdMdl == 'TECA890'
	oMdlTFL	:= oModel:GetModel("TFLMASTER")
	oMdlTFT	:= oModel:GetModel("TFTGRID")
 	oMdlTFS	:= oModel:GetModel("TFSGRID")
EndIf

cTitulo := STR0143 //"Cópia de apontamento de materiais"

DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 440,900 PIXEL TITLE cTitulo 

nPosBtn := 160
nPosBtn2 := 210
aAdd(adtParam, dGetDtde)
aAdd(aDtParam, dGetDtAte)

@ 006, 9 SAY STR0144 SIZE 50, 19 PIXEL //Data de Início
@ 006, 80 SAY STR0145  SIZE 50, 19 PIXEL //"Data Fim"
oDataDe := TGet():New( 014, 009, { | u | If( PCount() == 0, adtParam[1], adtParam[1] := u ) },oDlgSelect, ;
					060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtDe",,,,.T.)

oDataAte := TGet():New( 014, 80, { | u | If( PCount() == 0, adtParam[2], adtParam[2] := u ) },oDlgSelect, ;
					060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtAte",,,,.T.)


If nGesMat == '1' .OR. nGesMat == '4'
	If (nGesMat == '4' .AND. cIdMdl == 'TECA890') .OR. nGesMat == '1'
		@ 030, 007 SAY STR0167 SIZE 80, 19 PIXEL //"Materiais de Implantação"
		oListMI := TWBrowse():New(038, 007, nSize, 150,,{},,oDlgSelect,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListMI:addColumn(TCColumn():New(	"", &("{|| IIF(oListMI:aARRAY[oListMI:nAt,5] == 'S', oMarkT, oMarkF ) }"),,,,,10,.T.))
		oListMI:addColumn(TCColumn():New(	STR0146, &("{|| oListMI:aARRAY[oListMI:nAt,3] }"),,,,,30)) //'Quantidade'
		oListMI:addColumn(TCColumn():New(	STR0147, &("{|| oListMI:aARRAY[oListMI:nAt,2] }"),,,,,80)) //'Produto'
		oListMI:bLDblClick := { || {IIF(oListMI:aARRAY[oListMI:nAt,5] == 'N', oListMI:aARRAY[oListMI:nAt,5] := 'S', oListMI:aARRAY[oListMI:nAt,5] := 'N')} }

		oListMI:SetArray(aCpTFS)
		oListMI:lAutoEdit    := .T.
		oListMI:bHeaderClick := { |a, b| { at890HdCk(oListMI:aARRAY, oListMI, a, b, aSorting, oDlgSelect) }}

		oListMI:Refresh()
	EndIf
EndIf

If nGesMat == '1' .OR. nGesMat == '5'
	If (nGesMat == '5' .AND. cIdMdl == 'TECA890') .OR. nGesMat == '1'
		@ 030, nPosic SAY STR0168 SIZE 80, 19 PIXEL //"Materiais de Consumo"
		oListMC := TWBrowse():New(038, nPosic, nSize, 150,,{},,oDlgSelect,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oListMC:addColumn(TCColumn():New(	"", &("{|| IIF(oListMC:aARRAY[oListMC:nAt,5] == 'S', oMarkT, oMarkF ) }"),,,,,10,.T.))
		oListMC:addColumn(TCColumn():New(	STR0146, &("{|| oListMC:aARRAY[oListMC:nAt,3] }"),,,,,30)) //'Quantidade'
		oListMC:addColumn(TCColumn():New(	STR0147, &("{|| oListMC:aARRAY[oListMC:nAt,2] }"),,,,,80)) // 'Produto'
		oListMC:bLDblClick := { || {IIF(oListMC:aARRAY[oListMC:nAt,5] == 'N', oListMC:aARRAY[oListMC:nAt,5] := 'S', oListMC:aARRAY[oListMC:nAt,5] := 'N')} }

		oListMC:SetArray(aCpTFT)
		oListMC:lAutoEdit    := .T.
		oListMC:bHeaderClick := { |a, b| { at890HdCk(oListMC:aARRAY, oListMC, a, b, aSorting, oDlgSelect) }}
		oListMC:Refresh()
	EndIf
EndIf

If cIdMdl == 'TECA891'
	@ 030, 007 SAY STR0169 SIZE 80, 19 PIXEL //"Materiais de por valor"
	oListTGU := TWBrowse():New(038, 007, 420, 150,,{},,oDlgSelect,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListTGU:addColumn(TCColumn():New(	"", &("{|| IIF(oListTGU:aARRAY[oListTGU:nAt,5] == 'S', oMarkT, oMarkF ) }"),,,,,10,.T.))
	oListTGU:addColumn(TCColumn():New(	STR0146, &("{|| oListTGU:aARRAY[oListTGU:nAt,3] }"),,,,,30)) //'Quantidade'
	oListTGU:addColumn(TCColumn():New(	STR0148, &("{|| oListTGU:aARRAY[oListTGU:nAt,4] }"),,,,,30)) //'Valor'
	oListTGU:addColumn(TCColumn():New(	STR0147, &("{|| oListTGU:aARRAY[oListTGU:nAt,2] }"),,,,,80)) //'Produto'
	oListTGU:bLDblClick := { || {IIF(oListTGU:aARRAY[oListTGU:nAt,5] == 'N', oListTGU:aARRAY[oListTGU:nAt,5] := 'S', oListTGU:aARRAY[oListTGU:nAt,5] := 'N')} }
	
	oListTGU:SetArray(aCpTGU)
	oListTGU:lAutoEdit    := .T.
	oListTGU:bHeaderClick := { |a, b| { at890HdCk(oListTGU:aARRAY, oListTGU, a, b, aSorting, oDlgSelect) }}

	oListTGU:Refresh()
EndIF

oBuscar  := TButton():New( 014, nPosBtn, STR0149, oDlgSelect, {|| getAppCp(oListMC, oListMI, oListTGU, cCodTfl, aDtParam, nGesMat, oMdlTFS, oMdlTFT, @aCpTFS, @aCpTFT, @aCpTGU) }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Buscar"
															        copyApClr(oListMI, oListMC, oListTGU, aCpTFS, aCpTFT, aCpTGU )	
oLimpar	 := TButton():New( 014, nPosBtn2, STR0150, oDlgSelect, {|| copyApClr(oListMI, oListMC, oListTGU, @aCpTFS, @aCpTFT, @aCpTGU ) }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Limpar"
oSair 	 := TButton():New( 200, 414, STR0151,oDlgSelect, {|| oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Sair
oRefresh := TButton():New( 014, 405, STR0152,oDlgSelect, {|| copyApGr(oMdlTFS, oMdlTFT, oModel, aCpTFS, aCpTFT, aCpTGU, @oDlgSelect, nGesMat, lRec, oView) }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Copiar"
ACTIVATE MSDIALOG oDlgSelect CENTER

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getAppCp
@description  Controla chamada das funções que preenchem o browse com itens para cópia
@param oListMC, Objeto, objeto listbox com itens de material de consumo
@param oListMI, Objeto, objeto listbox com itens de material de implantação
@param oListTGU, Objeto, objeto listbox com itens de apontamento por valor
@param aDtParam, Array, array com os parametros de data
@param nGesMat, string, indica o tipo de apontamento de materiais
@param oMdlTFS, objeto, modelo de dados de apontamento dos materiais de implantação
@param aCpTFS, Array, array com os dados dos apontamentos de material de implantação
@param aCpTGU, Array, array com os dados dos apontamentos por valor
@param cCodTfl, String, código da tfl do intem posicionado do browse
@author Diego Bezerra
@since  07/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Static function getAppCp(oListMC, oListMI, oListTGU, cCodTfl, aDtParam, nGesMat, oMdlTFS, oMdlTFT,  aCpTFS, aCpTFT, aCpTGU)

Local oMdlAll
Local cIdMdl
Local nCount := 0
oMdlAll := FWModelActive()
cIdMdl	:= oMdlAll:GetId()

aCpTFS := {}
aCpTFT := {}
aCpTGU := {}

If (nGesMat == '1' .OR. nGesMat == '4') .AND. cIdMdl == 'TECA890'
	getTFS(cCodTfl, aDtParam, oListMI, oMdlTFS, aCpTFS)
	oListMI:SetArray(aCpTFS)
	nCount += Len(aCpTFS)
EndIf

If (nGesMat == '1' .OR. nGesMat == '5') .AND. cIdMdl == 'TECA890'
	getTFT(cCodTfl, aDtParam, oListMC, oMdlTFT, aCpTFT)
	oListMC:SetArray(aCpTFT)
	nCount += Len(aCpTFT)
EndIf

If cIdMdl == 'TECA891'
	getTGU(cCodTfl, aDtParam, oListTGU, oMdlAll, aCpTGU)
	oListTGU:SetArray(aCpTGU)
	nCount += Len(aCpTGU)
EndIf

If nCount == 0
	MsgInfo( STR0154 ) //"Ningún apunte se encontró para el período informado"
EndIf

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTFS
@description  Preenche o array statico aCpTFS com os itens que poderão ser copiados, de apontamentos de material de implantação
@param cCodTfl, string, código da tfl do item posicionado no browse
@param aDtParam, array, contém parâmetros de data
@param oListMI, Objeto, objeto listbox com itens de material de implantação
@param oMdlTFS, Objeto, modelo de dados de apontamento dos materiais de implantação
@param aCpTFS, Array, array com os dados dos apontamentos de material de implantação
@author Diego Bezerra
@since  07/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Static function getTFS(cCodTfl, aDtParam, oListMI, oMdlTFS, aCpTFS)

Local nX 		 := 0
Local lTecEntCtb := FindFunction("TecEntCtb") .And. TecEntCtb("TFS")

For nX := 1 to oMdlTFS:Length()
	oMdlTFS:GoLine(nX)
	If !Empty(oMdlTFS:GetValue("TFS_PRODUT")) .AND. ;
			( oMdlTFS:GetValue("TFS_DTAPON") >= aDtParam[1] .AND. oMdlTFS:GetValue("TFS_DTAPON") <= aDtParam[2] ) 
		
		aAdd(aCpTFS, {;
			oMdlTFS:GetValue("TFS_PRODUT"),; // 1
			oMdlTFS:GetValue("TFS_DPROD"),;  // 2
			oMdlTFS:GetValue("TFS_QUANT"),;  // 3
			oMdlTFS:GetValue("TFS_TM"),;     // 4
			'S',;							 // 5
			oMdlTFS:GetValue("TFS_LOCAL"),;  // 6
			oMdlTFS:GetValue("TFS_CODTFG"),; // 7
			oMdlTFS:GetValue("TFS_CC"),;	 // 8
			'',;							 // 9 -- log de erro
			'',;						     // 10 
			'',;							 // 11
			'',;						     // 12
			})
		
		If lTecEntCtb
			aCpTFS[nX,10] := oMdlTFS:GetValue("TFS_CONTA")
			aCpTFS[nX,11] := oMdlTFS:GetValue("TFS_ITEM")
			aCpTFS[nX,12] := oMdlTFS:GetValue("TFS_CLVL")
		Endif
	EndIf
Next nX

oListMI:Refresh()
Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTFT
@description  Preenche o array statico aCpTFT com os itens que poderão ser copiados, de apontamentos de material de consumo
@param cCodTfl, string, código da tfl do item posicionado no browse
@param aDtParam, array, contém parâmetros de data
@param oListMC, Objeto, objeto listbox com itens de material de consumo
@param oMdlTFT, Objeto, modelo de dados de apontamento dos materiais de consumo
@param aCpTFT, Array, array com dados de apontamento dos materiais de consumo
@author Diego Bezerra
@since  07/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Static function getTFT(cCodTfl, aDtParam, oListMC, oMdlTFT, aCpTFT)

Local nX := 0
Local lTecEntCtb := FindFunction("TecEntCtb") .And. TecEntCtb("TFT")

For nX := 1 to oMdlTFT:Length()
	oMdlTFT:GoLine(nX)
	If !Empty(oMdlTFT:GetValue("TFT_PRODUT")) .AND.;
			( oMdlTFT:GetValue("TFT_DTAPON") >= aDtParam[1] .AND. oMdlTFT:GetValue("TFT_DTAPON") <= aDtParam[2] ) 
		
		aAdd(aCpTFT, {;
			oMdlTFT:GetValue("TFT_PRODUT"),; // 1
			oMdlTFT:GetValue("TFT_DPROD"),;  // 2
			oMdlTFT:GetValue("TFT_QUANT"),;  // 3
			oMdlTFT:GetValue("TFT_TM"),;     // 4
			'S',;							 // 5
			oMdlTFT:GetValue("TFT_LOCAL"),;  // 6
			oMdlTFT:GetValue("TFT_CODTFH"),; // 7
			oMdlTFT:GetValue("TFT_CC"),;	 // 8
			'',;							 // 9 -- log de erro
			'',;							 // 10
			'',;							 // 11 
			'',;							 // 12 
		})

		If lTecEntCtb
			aCpTFT[nX,10] := oMdlTFT:GetValue("TFT_CONTA")
			aCpTFT[nX,11] := oMdlTFT:GetValue("TFT_ITEM")
			aCpTFT[nX,12] := oMdlTFT:GetValue("TFT_CLVL")
		Endif
	EndIf
Next nX

oListMC:Refresh()

Return .T.


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTGU
@description  Preenche o array aCpTGU com os materiais que serão copiados para apontamento por valor
@param cCodTfl, string, código da tfl do item posicionado no browse
@param aDtParam, array, contém parâmetros de data
@param oListTGU, Objeto, objeto listbox com itens de material para apontamento por valor
@param oMdlAll, Objeto, modelo de dados ativo
@param aCpTGU, Array, array que será preenchido com os dados de apontamento por valor
@author Diego Bezerra
@since  07/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function getTGU(cCodTfl, aDtParam, oListTGU, oMdlAll, aCpTGU)

Local nX 	:= 0
Local oMdlTGU := oMdlAll:GetModel("MODEL_TGU")
Local oMdlTFL := oMdlAll:GetModel("MODEL_TFL")
For nX := 1 to oMdlTGU:Length()
	oMdlTGU:GoLine(nX)
		If !Empty(oMdlTGU:GetValue("TGU_PROD")) .AND.;
			( oMdlTGU:GetValue("TGU_DATA") >= aDtParam[1] .AND. oMdlTGU:GetValue("TGU_DATA") <= aDtParam[2] ) 
			
			aAdd(aCpTGU, {;
				oMdlTGU:GetValue("TGU_PROD"),; 		// 1
				oMdlTGU:GetValue("TGU_DESCPR"),;	// 2
				oMdlTGU:GetValue("TGU_QUANT"),;		// 3
				oMdlTGU:GetValue("TGU_VALOR"),;		// 4
				'S',;								// 5
				oMdlTFL:GetValue("TFL_LOCAL"),;		// 6
				'',;								// 7
				'',;									// 8
				'';									// 9 -- log de erro
			})
		EndIf
Next nX

oListTGU:Refresh()

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} copyApClr
@description  Limpa os dois objetos browse, que exibem os materiais que podem ser copiados
@param oListMC, Objeto, objeto listbox com itens de material de consumo
@param oListMI, Objeto, objeto listbox com itens de material de implantação
@param oListTGU, Objeto, objeto listbox com itens de apontamento por valor
@param aCpTFS, Array, array com os itens de apontamento de material de consumo
@param aCpTFT, Array, array com os itens de apontamento de materIal de implantação
@param aCpTGU, Array, arrya com os itens de apontamento por valor
@author Diego Bezerra
@since  07/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------

Static Function copyApClr(oListMI, oListMC, oListTGU, aCpTFS, aCpTFT, aCpTGU )

aCpTFS := {}
aCpTFT := {}
aCpTGU := {}

If Valtype(oListMI) == 'O'
	oListMI:SetArray(aCpTFS)
	oListMI:Refresh()
EndIf
If Valtype(oListMC) == 'O'
	oListMC:SetArray(aCpTFT)
	oListMC:Refresh()
EndIf

If Valtype(oListTGU) == 'O'
	oListTGU:SetArray(aCpTFT)
	oListTGU:Refresh()
EndIf


Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} copyApGr
@description  Abre o browse de apontamento de materiais e preenche os registros escolhidos para cópia
@param cAliasPro, string, alias do browse de apontamentos
@author Diego Bezerra
@since  07/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Static Function copyApGr(oMdlTFS, oMdlTFT, oMdlAll, aCpTFS, aCpTFT, aCpTGU, oDlgSelect, nGesMat, lRec, oView)

Local nX 		:= 0
Local aSldTFS 	:= {}
Local aSldTFT	:= {}
Local nSldTGU	:= 0
Local nPos 		:= 0
Local cLogMsg	:= ""
Local cLogTFS	:= ""
Local cLogTFT	:= ""
Local cLogTGU	:= ""
Local oMdlTGU	:= oMdlAll:GetModel("MODEL_TGU")
Local oMdlTFL 	:= oMdlAll:GetModel("MODEL_TFL")
Local nCount	:= 0
Local aArea		:= {}
Local aFolder	:= {} 
Local lTecEntCtb := FindFunction("TecEntCtb") .And. TecEntCtb("TFT") .And. TecEntCtb("TFS")


If Empty(aCpTGU) .And. nGesMat <> '2'
	aFolder := oView:GetFolderActive("PASTA", 2)
	If nGesMat == '1' .OR. nGesMat == '4'
		For nX := 0 to oMdlTFS:Length()
			oMdlTFS:GoLine(nX)
			nPos := aScan(aSldTFS, {|x| x[1] == oMdlTFS:GetValue("TFS_CODTFG") })
			If nPos == 0
				aAdd(aSldTFS,{Alltrim(oMdlTFS:GetValue("TFS_CODTFG")), oMdlTFS:GetValue("TFS_SLDTTL")})
			EndIf
		Next nX

		If !EMPTY(aCpTFS)
			If aFolder[2] <> STR0028
				oView:SelectFolder("PASTA",STR0028,2)
			Endif
			aArea := GetArea()
			For nX := 1 to Len(aCpTFS)
				If aCpTFS[nX][5] == 'S'
					nPos := ASCAN(aSldTFS, { |x| Alltrim(x[1]) == Alltrim(oMdlTFS:GetValue('TFS_CODTFG')) })
					If nPos > 0 .AND. aSldTFS[nPos][2] >= aCpTFS[nX][3]
						oMdlTFS:GoLine(oMdlTFS:addLine())
						oMdlTFS:SetValue("TFS_CODTFG", aCpTFS[nX][7])
						If oMdlTFS:CanSetValue("TFS_PRODUT")
							oMdlTFS:SetValue("TFS_PRODUT", ALLTRIM(aCpTFS[nX][1]))
						EndIf
						oMdlTFS:SetValue("TFS_QUANT", aCpTFS[nX][3])
						oMdlTFS:SetValue("TFS_LOCAL", aCpTFS[nX][6])
						oMdlTFS:SetValue("TFS_TM", aCpTFS[nX][4])
						oMdlTFS:SetValue("TFS_CC", aCpTFS[nX][8])
						If lTecEntCtb
							oMdlTFS:SetValue("TFS_CONTA", aCpTFS[nX][10])
							oMdlTFS:SetValue("TFS_ITEM", aCpTFS[nX][11])
							oMdlTFS:SetValue("TFS_CLVL", aCpTFS[nX][12])
						Endif
						aSldTFS[nPos][2] -= aCpTFS[nX][3]
						nCount++
					Else
						aCpTFS[nX][9] += CRLF + STR0155 + ALLTRIM(aCpTFS[nX][2]) + STR0156 + cValToChar(aCpTFS[nX][3]) //'Saldo insuficiente para o produto '#" -- Quantidade: "
					EndIf
				EndIf
			Next nX
			RestArea(aArea)
		EndIf
	EndIf

	If nGesMat == '1' .OR. nGesMat == '5'
		aArea := GetArea()
		For nX := 0 to oMdlTFT:Length()
			oMdlTFT:GoLine(nX)
			If lRec
				nPos := aScan(aSldTFT, {|x| AllTrim(x[1]) == oMdlTFT:GetValue("TFT_CODTFH") .AND.;
											x[3] == cValToChar(Year(oMdlTFT:GetValue('TFT_DTAPON')))+cValToChar(Month(oMdlTFT:GetValue('TFT_DTAPON'))) })
				If nPos == 0
					aAdd(aSldTFT,{Alltrim(oMdlTFT:GetValue("TFT_CODTFH")), oMdlTFT:GetValue("TFT_SLDTTL"), ;
						cValToChar(Year(oMdlTFT:GetValue('TFT_DTAPON')))+cValToChar(Month(oMdlTFT:GetValue('TFT_DTAPON'))) ,oMdlTFT:GetValue('TFT_DTAPON') })
				EndIf
			Else
				nPos := aScan(aSldTFT, {|x| x[1] == oMdlTFT:GetValue("TFT_CODTFH") })
				If nPos == 0
					aAdd(aSldTFT,{Alltrim(oMdlTFT:GetValue("TFT_CODTFH")), oMdlTFT:GetValue("TFT_SLDTTL")})
				EndIf
			EndIf
		Next nX
		RestArea(aArea)

		If !EMPTY(aCpTFT)
			If aFolder[2] <> STR0029
				oView:SelectFolder("PASTA",STR0029,2)
			Endif
			aArea := GetArea()
			For nX := 1 to Len(aCpTFT)
				If aCpTFT[nX][5] == 'S'

					If lRec
						nPos := aScan(aSldTFT, {|x| AllTrim(x[1]) == aCpTFT[nX][7] .AND.;
											x[3] == cValToChar(Year(dDataBase))+cValToChar(Month(dDataBase)) })
					Else
						nPos := aScan(aSldTFT, {|x| AllTrim(x[1]) == aCpTFT[nX][7] })
					EndIf

					If lRec .AND. nPos == 0
						aAdd(aSldTFT,{aCpTFT[nX][7], sldTFH(aCpTFT[nX][7]), cValToChar(Year(dDataBase))+cValToChar(Month(dDataBase)), dDataBase })
						nPos := Len(aSldTFT)
					EndIf

					If (!lRec .AND. nPos > 0 .AND. aSldTFT[nPos][2] >= aCpTFT[nX][3]) .OR.;
							( lRec .AND. Year(dDataBase) >= Year(aSldTFT[1][4]) .AND. Month(dDataBase) >= Month(aSldTFT[1][4]);
								.AND. aSldTFT[nPos][2] >= aCpTFT[nX][3] )

								
						oMdlTFT:GoLine(oMdlTFT:addLine())
						oMdlTFT:SetValue("TFT_CODTFH", aCpTFT[nX][7])
						If oMdlTFT:CanSetValue("TFT_PRODUT")
							oMdlTFT:SetValue("TFT_PRODUT", ALLTRIM(aCpTFT[nX][1]))
						EndIf
						oMdlTFT:SetValue("TFT_QUANT", aCpTFT[nX][3])
						oMdlTFT:SetValue("TFT_LOCAL", aCpTFT[nX][6])
						oMdlTFT:SetValue("TFT_TM", aCpTFT[nX][4])
						oMdlTFT:SetValue("TFT_CC", aCpTFT[nX][8])
						If lTecEntCtb
							oMdlTFT:SetValue("TFT_CONTA", aCpTFT[nX][10])
							oMdlTFT:SetValue("TFT_ITEM", aCpTFT[nX][11])
							oMdlTFT:SetValue("TFT_CLVL", aCpTFT[nX][12])
						Endif
						aSldTFT[nPos][2] -= aCpTFT[nX][3]
						nCount++
					Else
						aCpTFT[nX][9] += CRLF + STR0157 + ALLTRIM(aCpTFT[nX][2]) + STR0156 + cValToChar(aCpTFT[nX][3]) //'Saldo insuficiente o material '#" -- Quantidade: "
					EndIf
				EndIf
			Next nX
			RestArea(aArea)
		EndIf
	EndIf
	If aFolder[2] <> oView:GetFolderActive("PASTA", 2)[2]
		oView:SelectFolder("PASTA",aFolder[2],2)
	Endif
Else
	oMdlTFL := oMdlAll:GetModel("MODEL_TFL")
	oMdlTGU := oMdlAll:GetModel("MODEL_TGU")
	nSldTGU := oMdlTFL:GetValue("TFL_SALDO")
	aArea := GetArea()
	For nX := 1 to Len(aCpTGU)
		If aCpTGU[nX][5] == 'S'
			If nSldTGU >= (aCpTGU[nX][3] * aCpTGU[nX][4])
				oMdlTGU:GoLine(oMdlTGU:addLine())
				oMdlTGU:SetValue("TGU_DATA", dDataBase)
				oMdlTGU:SetValue("TGU_PROD", aCpTGU[nX][1])
				oMdlTGU:SetValue("TGU_QUANT", aCpTGU[nX][3])
				oMdlTGU:SetValue("TGU_VALOR", aCpTGU[nX][4])
				nSldTGU -= (aCpTGU[nX][3] * aCpTGU[nX][4])
				nCount++
			Else
				aCpTGU[nX][9] += CRLF + STR0157 + ALLTRIM(aCpTGU[nX][2]) + STR0158 + cValToChar(aCpTGU[nX][3] * aCpTGU[nX][4]) //'Saldo insuficiente para material '#" -- Total: "
			EndIf
		EndIf
	Next nX
	RestArea(aArea)
EndIf

If !ISBlind() .AND. (!Empty(aCpTFS) .OR. !Empty(aCpTFT) .OR. !Empty(aCpTGU))
	If !Empty(aCpTFS)
		For nX := 1 to Len(aCpTFS)
			cLogTFS += aCpTFS[nX][9]
		Next nX
		If !Empty(cLogTFS)
			cLogMsg += STR0159	// "##### Problemas de processamento na cópia de Materiais de Implantação #####"
			cLogMsg += cLogTFS + CRLF
		EndIf
	EndIf

	If !Empty(aCpTFT)
		For nX := 1 to Len(aCpTFT)
			cLogTFT += aCpTFT[nX][9]
		Next nX
		If !Empty(cLogTFT)
			cLogMsg += STR0160	// "##### Problemas de processamento na cópia de Materiais de Consumo #####"
			cLogMsg += cLogTFT + CRLF
		EndIf
	EndIf

	If !Empty(aCpTGU)
		For nX := 1 to Len(aCpTGU)
			cLogTGU += aCpTGU[nX][9]
		Next nX
		If !Empty(cLogTGU)
			cLogMsg += STR0161 // "##### Problemas de processamento na cópia de Materiais por valor #####"
			cLogMsg += cLogTGU + CRLF
		EndIf
	EndIf

	If !Empty(cLogMsg)
		AtShowLog(cLogMsg,STR0162 ,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Log de erros - Cópia de apontamento de materiais"
	EndIf
EndIf

If nCount > 0
	MsgInfo(STR0164 + cValToChar(nCount) + STR0165) //"Foram copiados "#" registros."
EndIf

oDlgSelect:End()

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} sldTFH
@description  Retorna o saldo de material de consumo
@return nSld, numérico, saldo do material de consumo
@author Diego Bezerra
@since  09/07/2020
*/
//--------------------------------------------------------------------------------------------------------------------
Static function sldTFH(cCodTFH)

Local cQuery 	:= ""
Local cAliasQry	:= getNextAlias()
Local nSld		:= 0

cQuery += " SELECT TFH_SLD FROM " + retSqlName('TFH') + " TFH " 
cQuery += " WHERE TFH.TFH_COD = '" + cCodTFH + "' AND TFH.TFH_FILIAL = '" + xFilial("TFH") + "' AND TFH.D_E_L_E_T_ = ' '"

cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
	nSld	:= (cAliasQry)->TFH_SLD
EndIf
(cAliasQry)->(dbCloseArea())

Return nSld

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrwMkAll
Realiza a seleção de todos as linhas de um browse com mark
@author		Diego Bezerra
@since		30/06/2020
@param oListBox - Objet do tipo twbrowse manipulado

@version	P12.1.30
/*/
//------------------------------------------------------------------------------
Static function BrwMkAll(oListBox)

Local nX
Local aAux := oListBox:aArray

For nX := 1 to Len(aAux)
	If aAux[nX][5] == 'S'
		aAux[nX][5] := 'N'
	Else
		aAux[nX][5] := 'S'
	EndIf
Next nX
oListBox:SetArray(aAux)
oListBox:Refresh()
Return .T.


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at890HdCk
@description Faz o sort dos dados ao clicar no cabeçalho da coluna
@author       Diego Bezerra
@since        12/08/2018
@param        aRegs, array, registros presentes no grid
@param        oListBox, obj, objeto TWBrowse
@param        b, int, coluna selecionada
@param        aSorting, array, utilizado para definir se a busca sera a > b ou a < b
@param        oDlgSelect, obj, tela em que o TWBrowse é filho
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function at890HdCk(aRegs, oListBox, a, b, aSorting, oDlgSelect)

If b <> 1 
	If aSorting[1] == b .and. aSorting[2]
		aSorting[2] := .F.
		aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) > TecNumDow(l2[b])})
	Else
		If aSorting[1] != b
			aSorting[1] := b
		EndIf
		aSorting[2] := .T.
		aRegs := aSort(aRegs, 1, Len(aRegs), {|l1, l2| TecNumDow(l1[b]) < TecNumDow(l2[b])})
	EndIf
	oListBox:SetArray(aRegs)
	oListBox:Refresh()
Else
	BrwMkAll(oListBox)
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At890BLin
Monta o bloco de código dinamico para novas colunas 
@author		Kaique Schiller
@since		26/01/2022
@param cBlq - Bloco de código em character
/*/
//------------------------------------------------------------------------------
Static Function At890BLin(aCamp)
Local nX := 0
Local cBlq	:= ""

for nX := 1 to Len(aCamp[1])
	If nX == 1
		cBlq := "{ || {" 
	Endif
	cBlq += "aCmpBco[oListBox:nAT]["+cValToChar(nX)+"]" 
	If nX == Len(aCamp[1])
		cBlq += "} }"
	Else
		cBlq += ","
	Endif		
next nX
Return cBlq

//------------------------------------------------------------------------------
/*/{Protheus.doc} At890cansa
Realiza o estorno da SA e da TFS\TFT no caso de rejeiçao da solicitacao do Armazem
@author		Vitor kwon
@since		14/03/2022
@param Nil
/*/
//------------------------------------------------------------------------------

Function AT890CANSA(cNumSA,nQtdCP,nQtdCQ) 

Local cCodTFG    := ""
Local cCodTFH    := ""
Local cCodTFT    := ""
Local cQuery     := ""
Local cAliasQry	 := GetNextAlias()
Local cAliasQFT	 := GetNextAlias()
Local cAliasSA   := "TFS"
Local cAliasTFG  := "TFG"
local cAliasSCP  := "SCP"
Local lRet       := .F.
Local cAliasTFT  := "TFT"
Local cAliasTFH  := "TFH"
Local lTFTCampo  := (TFT->(ColumnPos("TFT_CODSA"))>0)
Local lTFSCampo  := (TFS->(ColumnPos("TFS_CODSA"))>0)
Local nEstor     := 0
Local nEstorTFT  := 0
local nValTFG    := 0
Local nValTFT    := 0
Local nQtdTFGTot := 0
Local nQtATCP    := 0
Local nQtdTFHTot := 0
Local cCodPRD    := ""
Local cCodPRDTFT := ""
Local cCodTFS    := ""

iF lTFTCampo .And. lTFSCampo

	cQuery := " SELECT TFS_CODTFG CODTFG, TFS_PRODUT CODPROD FROM " + RetSqlName('TFS') + " TFS " 
	cQuery += " WHERE TFS.TFS_CODSA = '" + cNumSA + "' AND TFS.TFS_FILIAL = '" + xFilial("TFS") + "' AND TFS.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	iF (cAliasQry)->(!Eof())

			cCodTFG := (cAliasQry)->CODTFG
			cCodPRD :=  (cAliasQry)->CODPROD

			DbSelectArea("TFS")
			DbSetorder(3)

			DbSelectArea("TFG")
			DbSetorder(1)

			DbSelectArea("SCP")
			DbSetorder(2)

			lRet :=  (cAliasTFG)->(DbSeek(xFilial(cAliasTFG)+cCodTFG))
			lRet :=  lRet .And. (cAliasSA)->(DbSeek(xFilial(cAliasSA)+cCodTFG))
			lRet :=  lRet .And. (cAliasSCP)->(DbSeek(xFilial(cAliasSCP)+cCodPRD+cNumSA+SCQ->CQ_ITEM))
             
			If  lRet

				nQtdTFGTot := TFS->TFS_QUANT + TFG->TFG_SLD  

				If cAliasSA == "TFS"  .And. SCP->CP_QUJE == 0 

				    nEstor  := 0
					nValTFG := nQtdTFGTot

				Elseif 	cAliasSA == "TFS"  .And. SCP->CP_QUJE > 0 

				    cCodTFS := At890TFS(cNumSA)

					(cAliasSA)->(DbSetorder(1))
					(cAliasSA)->(DbSeek(xFilial(cAliasSA)+cCodTFS))

					nQtATCP := (nQtdCP-nQtdCQ)
				    nEstor  := nQtATCP
					nValTFG := TFG->TFG_SLD + SCQ->CQ_QTDISP
				
				Endif

				If cAliasSA == "TFS"  
					RecLock(cAliasSA,.F.)
						TFS->TFS_QUANT	:= nEstor
					(cAliasSA)->(MsUnlock())
				Endif

				If cAliasTFG == "TFG"  
					RecLock(cAliasTFG,.F.)
						TFG->TFG_SLD	:= nValTFG
					(cAliasTFG)->(MsUnlock())	
				Endif

			EndIf
		(cAliasQry)->(DbCloseArea())	
	else 

		cQuery := " SELECT TFT_CODTFH CODTFH , TFT_CODIGO AS CODTFT , TFT_PRODUT PRDTFT FROM " + RetSqlName('TFT') + " TFT " 
		cQuery += " WHERE TFT.TFT_CODSA = '" + cNumSA + "' AND TFT.TFT_FILIAL = '" + xFilial("TFT") + "' AND TFT.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQFT, .F., .T.)

		iF (cAliasQFT)->(!Eof())

			cCodTFH     :=  (cAliasQFT)->CODTFH
			cCodTFT     :=  (cAliasQFT)->CODTFT
			cCodPRDTFT  :=  (cAliasQFT)->PRDTFT

			DbSelectArea("TFT")
			DbSetorder(1)

			DbSelectArea("TFH")
			DbSetorder(1)

			DbSelectArea("SCP")
			DbSetorder(2)

			lRet :=  (cAliasTFT)->(DbSeek(xFilial(cAliasTFT)+cCodTFT))
			lRet :=  lRet .And. (cAliasTFH)->(DbSeek(xFilial(cAliasTFH)+cCodTFH))
			lRet :=  lRet .And. (cAliasSCP)->(DbSeek(xFilial(cAliasSCP)+cCodPRDTFT+cNumSA))


			If  lRet 

				nQtdTFHTot := TFT->TFT_QUANT + TFH->TFH_SLD  

				If cAliasTFT == "TFT"  .And. SCP->CP_QUJE == 0 

					nEstorTFT  := 0
					nValTFT := nQtdTFHTot

				Elseif 	cAliasTFT == "TFT"  .And. SCP->CP_QUJE > 0 

					cCodTFT := At890TFT(cNumSA)

					(cAliasTFT)->(DbSetorder(1))
					(cAliasTFT)->(DbSeek(xFilial(cAliasTFT)+cCodTFT))

					nQtATCP := (nQtdCP-nQtdCQ)
					nEstorTFT  := nQtATCP
					nValTFT := TFH->TFH_SLD + SCQ->CQ_QTDISP
				
				Endif

				If cAliasTFT == "TFT"
					RecLock(cAliasTFT,.F.)
						TFT->TFT_QUANT	:=	nEstorTFT	
					(cAliasTFT)->(MsUnlock())	
				Endif
				
				If cAliasTFH == "TFH"
					RecLock(cAliasTFH,.F.)
						TFH->TFH_SLD	:=	nValTFT
					(cAliasTFH)->(MsUnlock())	
				Endif		
			EndIf
	    Endif
		(cAliasQFT)->(DbCloseArea())
	Endif
Endif						

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At890QtdSA
Informa a quantidade que foi atendida na SA
@author		Vitor kwon
@since		17/03/2022
@param Nil
/*/
//------------------------------------------------------------------------------

Function At890QtdSA(cCodSA,nQtdTFSA)

Local cQuery    := ""
Local nQtdSA    := 0
Local cPreReq   := ""
Local cStat     := ""
Local nQtdZero  := 0
Local cAliasQry := GetNextAlias()
local nRet      := 0

    

	cQuery := " SELECT CP_QUANT, CP_PREREQU, CP_STATUS, CP_QUJE FROM " + RetSqlName('SCP') + " SCP " 
	cQuery += " WHERE CP_NUM  = '" + cCodSA + "' AND SCP.CP_FILIAL = '" + xFilial("SCP") + "' AND SCP.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

	nQtdSA  := (cAliasQry)->CP_QUANT
	cPreReq := (cAliasQry)->CP_PREREQU
    cStat   := (cAliasQry)->CP_STATUS
	nSolic  := (cAliasQry)->CP_QUJE

        iF 	cStat == "E" .And. cPreReq == "S" .And. nSolic > 0 .And. At890Req(cCodSA) 
            nRet := nSolic
        ElseIF cStat == "E" .And. cPreReq == "S"  .And. nSolic == nQtdZero 
			nRet := nSolic
		Elseif cStat == "E" .And. cPreReq == "S"  .And. nQtdTFSA == nQtdSA 
			nRet := nQtdSA
		Elseif 	!Empty(cPreReq) .And.  Empty(cStat) .And. nSolic == nQtdZero
            nRet := nSolic
		Elseif Empty(cStat) .And. cPreReq == "S"  .And. nSolic != nQtdSA
			nRet := nSolic
		Endif

	(cAliasQry)->(DbCloseArea())	
     
Return nRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At890Verif
Verifica se a SA foi encerrada/rejeitada/analise ou atendida parcialmente.Esta função foi utilizada no valid At890PosVal
@author		Vitor kwon
@since		17/03/2022
@param 		Nil
/*/
//------------------------------------------------------------------------------
Function At890Verif(cCodSA) 
Local cQuery    := ""
Local cPreReq   := ""
Local cStat     := ""
Local cAliasQry := GetNextAlias()
local lRet      := .F.

cQuery := " SELECT CP_PREREQU, CP_STATUS FROM " + RetSqlName('SCP') + " SCP " 
cQuery += " WHERE CP_NUM  = '" + cCodSA + "' AND SCP.CP_FILIAL = '" + xFilial("SCP") + "' AND SCP.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

cPreReq := (cAliasQry)->CP_PREREQU
cStat   := (cAliasQry)->CP_STATUS

If cStat == "E" .And. cPreReq == "S"
	lRet := .T.
Endif

If At890Req(cCodSA) .And. cPreReq == "S" 
	lRet := .T.
Endif

If At890SCQ(cCodSA) .And. cPreReq == "S"  
	lRet := .T.
Endif

(cAliasQry)->(DbCloseArea())

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} At890SCQ
Verifica se tem a tabela SCQ criada
@author		Vitor kwon
@since		17/03/2022
@param Nil
/*/
//------------------------------------------------------------------------------


Function At890SCQ(cCodSCQ) 

Local cQry := ""
local lRet := .F.
local cAliasSCQ := ""

    cAliasSCQ := GetNextAlias()  

	cQry := " SELECT CQ_NUM"
	cQry += " FROM  "+RetSqlName("SCQ")+" SCQ "
	cQry += " WHERE SCQ.D_E_L_E_T_ = '' "
	cQry += " AND CQ_FILIAL = '" +xFilial("SCQ")+"' "
	cQry += " AND CQ_NUM = '"+cCodSCQ+"'"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSCQ,.T.,.T.)

	iF (cAliasSCQ)->(!Eof())
        lRet := .T.
	Endif

	(cAliasSCQ)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At890SCQ
Verifica se a SCQ tem numero de requisição
@author		Vitor kwon
@since		17/03/2022
@param Nil
/*/
//------------------------------------------------------------------------------

Function At890Req(cCodSCQ) 

Local cQry := ""
local lRet := .F.
Local cNumReq := ""
local cAliasSCQ := ""

    cAliasSCQ := GetNextAlias()  

	cQry := " SELECT CQ_NUMREQ"
	cQry += " FROM  "+RetSqlName("SCQ")+" SCQ "
	cQry += " WHERE SCQ.D_E_L_E_T_ = '' "
	cQry += " AND CQ_FILIAL = '" +xFilial("SCQ")+"' "
	cQry += " AND CQ_NUM = '"+cCodSCQ+"'"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasSCQ,.T.,.T.)

    cNumReq := (cAliasSCQ)->CQ_NUMREQ

	if !Empty(cNumReq)
	   lRet := .T.
	Endif   

	(cAliasSCQ)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At890TFS
Função para verificar o codigo da TFS no apontamento para estorno da quantidade 
@author		Vitor kwon
@since		19/04/2022
@param Nil
/*/
//------------------------------------------------------------------------------


Function At890TFS(cCodSA) 

Local cQry := ""
local cRet := ""
local cAliasTFS := ""

cAliasTFS := GetNextAlias()  

	cQry := " SELECT TFS_CODIGO CODTFS"
	cQry += " FROM  "+RetSqlName("TFS")+" TFS "
	cQry += " WHERE TFS.D_E_L_E_T_ = '' "
	cQry += " AND TFS_FILIAL = '" +xFilial("TFS")+"' "
	cQry += " AND TFS_CODSA = '"+cCodSA+"'"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFS,.T.,.T.)

	cRet :=  (cAliasTFS)->CODTFS

(cAliasTFS)->(DbCloseArea())

Return cRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At890TFT
Função para verificar o codigo da TFT no apontamento para estorno da quantidade 
@author		Vitor kwon
@since		19/04/2022
@param Nil
/*/
//------------------------------------------------------------------------------


Function At890TFT(cCodSA) 

Local cQry := ""
local cRet := ""
local cAliasTFT := ""

cAliasTFT := GetNextAlias()  

	cQry := " SELECT TFT_CODIGO CODTFT"
	cQry += " FROM  "+RetSqlName("TFT")+" TFT "
	cQry += " WHERE TFT.D_E_L_E_T_ = '' "
	cQry += " AND TFT_FILIAL = '" +xFilial("TFT")+"' "
	cQry += " AND TFT_CODSA = '"+cCodSA+"'"
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFT,.T.,.T.)

	cRet :=  (cAliasTFT)->CODTFT

(cAliasTFT)->(DbCloseArea())

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At890INum

Função de inicializador padrão de auto numeração com confirmação de gravação

@author Vitor Kwon
@since 19/04/22
/*/
//-------------------------------------------------------------------

Static Function At890INum(cAlias, cCampo, nQualndex)

Local aArea     := GetArea()
Local aAreaTmp  := (cAlias)->(GetArea())
Local cProxNum  := ""

Default nQualndex := 1
         
cProxNum  := GetSx8Num(cAlias, cCampo,, nQualndex)

dbSelectArea(cAlias)
dbSetOrder(nQualndex)
  
While dbSeek( xFilial( cAlias ) + cProxNum )
    If ( __lSx8 )
        ConfirmSX8()
    EndIf
    cProxNum := GetSx8Num(cAlias, cCampo,, nQualndex)
End

RestArea(aAreaTmp)
RestArea(aArea)

Return(cProxNum)


//------------------------------------------------------------------------------
/*/{Protheus.doc} At890Vsfe
Verifica se foi realizada a entrada no estoque para permitir a deleção se necessario
@author		Vitor kwon
@since		17/03/2022
@param 		Nil
/*/
//------------------------------------------------------------------------------
Function At890Vsfe(cCodSA) 
Local cQuery    := ""
Local cPreReq   := ""
Local cStat     := ""
Local cAliasQry := GetNextAlias()
local lRet      := .T.

cQuery := " SELECT CP_PREREQU, CP_STATUS FROM " + RetSqlName('SCP') + " SCP " 
cQuery += " WHERE CP_NUM  = '" + cCodSA + "' AND SCP.CP_FILIAL = '" + xFilial("SCP") + "' AND SCP.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

cPreReq := (cAliasQry)->CP_PREREQU
cStat   := (cAliasQry)->CP_STATUS

If Empty(cPreReq) .And. Empty(cStat)
	lRet := .F.
Endif

(cAliasQry)->(DbCloseArea())

Return lRet
