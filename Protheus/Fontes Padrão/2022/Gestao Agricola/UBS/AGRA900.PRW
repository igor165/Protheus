#INCLUDE "AGRA900.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#include "totvs.ch"
#include "topconn.ch"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE "APWIZARD.CH"

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900
//Rotina de Ordem de Carregamento
@author bruna.rocio
@since 25/10/2016
@version undefined
@type function
/*/
/*/
-------------------------------------------------------------------------------------*/
Function AGRA900()
    Local oBrowse  	:= Nil
    Private cAliTHi	:= "",vVetToC := {},nQtdC := 0

    SetKey(VK_F4,{|| AGRA900F4()})

    // Seta acao para tecla F12
    SetKey(VK_F12, {|| Pergunte('AGRA900', .T.) }   ) // F12
    Pergunte('AGRA900', .F.)

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('NPM')
    oBrowse:SetDescription( STR0001 ) //Ordem de carregamento
    oBrowse:SetMenuDef( "AGRA900" )
    oBrowse:DisableDetails()

    // Adiciona legendas
    AGRLEGEBROW(@oBrowse,{{"NPM_STATUS = '1'",AGRRETSX3BOX("NPM_STATUS",'1'),"YELLOW"}   ,{"NPM_STATUS = '2'",AGRRETSX3BOX("NPM_STATUS",'2'),"BLUE"},;
        {"NPM_STATUS = '3'",AGRRETSX3BOX("NPM_STATUS",'3'),"GREEN"}    ,{"NPM_STATUS = '4'",AGRRETSX3BOX("NPM_STATUS",'4'),"RED"},;
        {"NPM_STATUS = '5'",AGRRETSX3BOX("NPM_STATUS",'5'),"BR_CANCEL"},{"NPM_STATUS = '6'",AGRRETSX3BOX("NPM_STATUS",'6'),"BLACK"}})
    oBrowse:Activate()
    SetKey (VK_F4, nil)
Return

/** -------------------------------------------------------------------------------------
/{Protheus.doc} MenuDef
//Definição do MenuDef()
@author thiago.rover
@since 31/10/2016
@version undefined
@type function
------------------------------------------------------------------------------------------ **/
Static Function MenuDef()
    Local nx
    Local nOper
    Private aRotina := {}

    Pergunte('AGRA900', .F.)

    ADD OPTION aRotina Title STR0002 Action 'AGR900PRE(2)'   	OPERATION 2    ACCESS 0 //visualizar
    ADD OPTION aRotina Title STR0003 Action 'AGR900PRE(3)'      OPERATION 3    ACCESS 0 //Incluir
    ADD OPTION aRotina Title STR0024 Action 'AGR900PRE(4)'      OPERATION 4    ACCESS 0 //alterar
    ADD OPTION aRotina Title STR0060 Action 'AGR900PRE(5)'   	OPERATION 5    ACCESS 0 //Exclusão carregamento
    ADD OPTION aRotina Title STR0078 Action 'AGR900PRE(13)'		OPERATION 13   ACCESS 0 //NF-e Sefaz
    ADD OPTION aRotina Title STR0015 Action 'AGR900PRE(6)'      OPERATION 6    ACCESS 0 //Prep. Doc. Saida
    ADD OPTION aRotina Title STR0025 Action 'AGR900PRE(8)'	    OPERATION 8    ACCESS 0 //Gerar Pedido de Venda
    ADD OPTION aRotina Title STR0135 Action 'AGR900PRE(9)'      OPERATION 9    ACCESS 0 //Exclui o ped. Venda
    ADD OPTION aRotina Title STR0136 Action 'AGR900PRE(10)'	    OPERATION 10   ACCESS 0 //Canc/Exc Docto Fiscal
    ADD OPTION aRotina Title STR0134 Action 'AGR900PRE(11)'	    OPERATION 11   ACCESS 0 //Historico
    ADD OPTION aRotina Title STR0061 Action 'AGR900PRE(12)'		OPERATION 12   ACCESS 0 //Imprime Laudos Tecnicos
    If !Empty(MV_PAR01) .And. MV_PAR01 = 2
        ADD OPTION aRotina Title STR0140 Action 'AGR900PRE(14)'	OPERATION 14   ACCESS 0 //Conhecimento
    EndIf

    //TODO Remover impressao fixa do fonte e disponibilizar fonte em separado
    If EXISTBLOCK("AGR900P3")
        ADD OPTION aRotina Title STR0079 Action 'U_AGR900P3'	OPERATION 7 ACCESS 0 //Impressão Ordem
    Else
        ADD OPTION aRotina Title STR0079 Action 'AGR900PRE(7)'	OPERATION 7 ACCESS 0 //Impressão Ordem
    EndIf

    //Inicializa o numero de operação de acordo com o menu padrão
    For nX := 1 To Len(aRotina)
        nOper := aRotina[nX][4]
    Next nX

    //Ponto de Entrada para Adição de opções no menu
    if ExistBlock('AGR900P4')
        aRetM := ExecBlock('AGR900P4',.F.,.F.)
        If Type("aRetM") == 'A'
            for nx := 1 To Len(aRetM)
                nOper ++
                ADD OPTION aRotina Title aRetM[nx,1] Action aRetM[nx,2] OPERATION 7 ACCESS 0
            Next nx
        Endif
    Endif

Return aRotina

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
//Modelo de dados da Ordem de Carregamento
@author bruna.rocio
@since 25/10/2016
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   	:= Nil
    Local oStruNPM 	:= FwFormStruct( 1, "NPM" ) // Ordem de Carregamento
    Local oStruNPH 	:= FwFormStruct( 1, "NPH" ) // Itens da Aut. Carregamento
    Local oStruNPN 	:= FwFormStruct( 1, "NPN" ) // Itens da Ordem de Carregamento

    //Addicionando Campos
    oStruNPN:AddField('NPN_ITEMAC','NPN_ITEMAC','NPN_ITEMAC','C',3,AGRSEEKDIC("SX3","NPN_ITEMAC ",2,"X3_DECIMAL"),NIL,NIL,NIL,NIL,NIL,NIL,NIL,.F.)

    //Alterando Propriedades WHEN da NPH
    AGRWHENMVC(oStruNPH,{{'NPH_QUANT'},{'NPH_CODPRO'},{'NPH_PRCVEN'},{'NPH_CULTRA','ValidNPH("NPH_CULTRA"	)'},;
        {'NPH_CTVAR','ValidNPH("NPH_CTVAR")'},{'NPH_CATEG','ValidNPH("NPH_CATEG"	)'},{'NPH_PENE','ValidNPH("NPH_PENE")'}})
    oStruNPH:SetProperty( "NPH_LOCAL",MODEL_FIELD_OBRIGAT, .F. )

    //Alterando Propriedades INIT da NPN
    AGRINIPADMVC(oStruNPN,{{'NPN_CODPRO',"FwFldGet('NPH_CODPRO')"},{'NPN_LOCAL',"FwFldGet('NPH_LOCAL'	)"},{'NPN_ITEMAC',"FwFldGet('NPH_ITEM')"},;
        {'NPN_CODAC',"FwFldGet('NPH_CODAC')"}})

    //Alterando Propriedades WHEN da NPN
    AGRWHENMVC(oStruNPN,{{'NPN_LOCALI',"Localiza(FwFldGet('NPH_CODPRO'))"},{'NPN_ITEM'},{'NPN_CULTRA'},{'NPN_CTVAR'},{'NPN_CATEG'},{'NPN_PENE'}})

    //Gatilho da NPN
    oStruNPN:AddTrigger( "NPN_QUANT","NPN_SEGUM",{|| .T. },{|| FwFldGet('NPH_SEGUM')})//Garante que a 2a.UM. eh preenchida

    oStruNPN:SetProperty( "NPN_QUANT",MODEL_FIELD_OBRIGAT,.F.)

    oStruNPN:SetProperty( "NPN_LOTE" 	, MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"AGRA900CPO()") ) 
	
    // Instancia o model
    oModel := MpFormModel():New( 'AGRA900',/*bPre*/,{| oModel | TudoOK( oModel )}, {|OMdl| AGRA900GRV(oMdl)},/*bCancel*/)

    // Adiciona estrutura do cabecalho no modelo de dados
    oModel:AddFields( 'MdFieldNPM', /*cOwner*/, oStruNPM)

    // Adiciona estrutura da Grid no modelo de dados
    oModel:AddGrid( 'MdGridNPH','MdFieldNPM',oStruNPH)
    oModel:AddGrid( 'MdGridNPN','MdGridNPH' ,oStruNPN,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValLin(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)},{|oModelGrid, nLine|PosValLin(oModelGrid, nLine)})

    // Adiciona campo calculado
    oModel:AddCalc( 'AGRA900CALC', 'MdGridNPH', 'MdGridNPN', 'NPN_QUANT', 'NPN_XTOTAL', 'SUM',,,'TOTAL' )

    // Seta Relacionamento
    oModel:SetRelation( 'MdGridNPH',{{'NPH_FILIAL','xFilial("NPH") '},{'NPH_ORDEMC','NPM_CODIGO'}},NPH->(IndexKey(1)))
    if  FWSIXUtil():ExistIndex( "NPN" , "5" ) 
	   oModel:SetRelation( 'MdGridNPN',{{'NPN_FILIAL','xFilial("NPN")'},{'NPN_ORDEMC'	,'NPM_CODIGO'	},;
        { 'NPN_ITEMAC','NPH_ITEM'},{'NPN_CODAC'	,'NPH_CODAC'}},NPN->(IndexKey(5)))
	Else
        oModel:SetRelation( 'MdGridNPN',{{'NPN_FILIAL','xFilial("NPN")'},{'NPN_ORDEMC'	,'NPM_CODIGO'	},;
        { 'NPN_ITEMAC','NPH_ITEM'},{'NPN_CODAC'	,'NPH_CODAC'}},NPN->(IndexKey(1)))
    endif
    // Descricao dos Modelos
    oModel:SetDescription( STR0006 ) //Modelo de dados da ordem de carregamento
    AGRSETDESCRIP(oModel,{{'MdFieldNPM',STR0007},{'MdGridNPH',STR0008},{'MdGridNPN',STR0009}}) //Cabeçalho da Ordem de Carregamento #Itens da autorização de carregamento #Itens da ordem de carregamento

    // Ativa o Grid como Opcional
    oModel:GetModel('MdGridNPN'):SetOptional( .T. )

    // Seta Chave Primaria
    oModel:SetPrimaryKey( {"NPM_FILIAL","NPM_CODIGO"} )

    // Permite editar o modelo de dados mas não grava as alteracoes no banco
    oModel:GetModel( 'MdGridNPH' ):SetOnlyQuery ( .T. )

    // Valida a ativação do model
    oModel:SetVldActive( { |oMdl| AGRA900ACT( oMdl ) } )

    oModel:GetModel( 'MdGridNPN' ):SetUniqueLine( { 'NPN_LOTE','NPN_LOCALI'} )

    // Seta chave primaria
    oModel:SetPrimaryKey( {"NPN_FILIAL","NPN_LOCAL","NPN_LOCALI","NPN_LOTE"} )

Return oModel

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oView		:= Nil
    Local oModel	:= FwLoadModel( "AGRA900" )
    Local oStruNPM 	:= FwFormStruct( 2, "NPM",{|cCampo| !(Alltrim(cCampo) $ "NPM_NUMPV|NPM_NFS|NPM_SERNFS")} ) // Ordem de Carregamento
    Local oStruNPH 	:= FwFormStruct( 2, "NPH" ) // Itens da Aut. Carregamento
    Local oStruNPN 	:= FwFormStruct( 2, "NPN", {|cCampo| !(Alltrim(cCampo) $ "NPN_ORDEMC|NPN_CODPRO")}) // Itens da Ordem de Carregamento

    oStruNPH:RemoveField('NPH_QTDDIS')

    // Instancia a View
    oView := FwFormView():New()

    // Seta o model
    oView:SetModel( oModel )

    // Adiciona os campos na estrutura da View
    oView:AddField('VwFieldNPM', oStruNPM, 'MdFieldNPM' )
    oView:AddGrid( 'VwGridNPH' , oStruNPH, 'MdGridNPH')
    oView:AddGrid( 'VwGridNPN' , oStruNPN, 'MdGridNPN',,{ || fNPNGotFoc(oModel,oView)})

    // Cria o Box
    AGRCRIABOX(oView,{{'EMCIMA',30},{"MEIO",30},{'EMBAIXO',40}})

    // Seta Owner
    AGRSETOWNERV(oView,{{'VwFieldNPM','EMCIMA'},{'VwGridNPH','MEIO'},{'VwGridNPN','EMBAIXO'}})
    // Seta titulo da View
    AGRENABTVIEW(oView,{'VwFieldNPM','VwGridNPH','VwGridNPN'})

    oView:AddUserButton(STR0134,'CLIPS',{|oView| AGRA900HIS()}) //Historico

    // Seta para não permitir modificar a grid
    AGRSETNOLINE(oModel,.T.,.T.,.T.,'MdGridNPH')

    // Seta o campo incremental da Grid
    oView:AddIncrementField( 'VwGridNPN', 'NPN_ITEM' )

    // Seta acção do campo
    oView:SetFieldAction( 'NPM_CODAC', { |oView, cIDView, cField, xValue| AGRA900CAR( oView, xValue ) } )
    oView:SetFieldAction( 'NPH_LOCAL', { |oView, cIDView, cField, xValue| PosLocal( xValue ) } )
    oView:SetViewProperty('VwGridNPH',"CHANGELINE",{{|oView,cViewID| NPHCHLINE()}})
    oStruNPN:RemoveField('NPN_CODAC')

    oStruNPN:RemoveField('NPN_CODAC')
    oView:SetCloseOnOk( {||.t.} )
Return oView

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} DadosLote
Valida e posiciona dados do lote na seleção
@author: Maicol lange
@since: 14/01/2014
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function DadosLote()
    Local lRet := .T.,aArea := GetArea()
    If IsInCallStack("AGRA900") .And. (oView := FwViewActive()) <> Nil
        oModel	 := FWModelActive()
        oGridNPN := oModel:GetModel("MdGridNPN")
        AGRLOADVALUE(oGridNPN,{{"NPN_CULTRA",""},{"NPN_CTVAR",""},{"NPN_PENE",""},{"NPN_CATEG",""}})

        If !Empty(FwFldGet("NPN_LOTE"))
            CodSaf := AGRSEEKDIC("ADA",xfilial("NPM")+FwFldGet("NPH_NUMCP"),1,"ADA_CODSAF")
            If !Empty(CodSaf)
                If AGRIFDBSEEK("NP9",CodSaf+FwFldGet("NPN_CODPRO")+FwFldGet("NPN_LOTE") ,1,.f.)
                    cCODENT := Alltrim(NP9->NP9_FILIAL+CodSaf+FwFldGet("NPN_CODPRO")+FwFldGet("NPN_LOTE"))
                    If Empty(AGRDOCLOTPAI(CodSaf,FwFldGet("NPN_CODPRO"),FwFldGet("NPN_LOTE"),.t.))
                        Help(" ",1,"AGRA900ND",,CHR(13)+STR0062+" "+Alltrim(NP9->NP9_LOTE)+" "+"Safra"+" "+CodSaf,3,0) //
                        lRet := .f.
                    EndIf
                    AGRLOADVALUE(oGridNPN,{{"NPN_CULTRA",NP9->NP9_CULTRA},{"NPN_CTVAR",NP9->NP9_CTVAR},{"NPN_PENE",NP9->NP9_PENE},{"NPN_CATEG",NP9->NP9_CATEG}})
                Else
                    lRet := .F.
                Endif
            Endif
        EndIf
        oView:Refresh('VwGridNPN')
    Endif
    RestArea(aArea)
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} NPHCHLINE
//Função executada no evento de change-line
@author bruna.rocio
@since 12/07/2016
@version undefined

@type function
/*/
// -------------------------------------------------------------------------------------
Static Function NPHCHLINE()
    Local oModel		:= FWModelActive()
    Local oGridNPN	:= oModel:GetModel("MdGridNPN")
    Local oGridNPH	:= oModel:GetModel("MdGridNPH")
    oGridNPN:GoLine(1)
    oGridNPH:SetNoUpdateLine( .F. )
Return .t.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLocal
//Ação do campo NPH_LOCAL
@author bruna.rocio
@since 12/07/2016
@version undefined
@param cLocal, characters, descricao
@type function
/*/
// -------------------------------------------------------------------------------------
Static Function PosLocal(cLocal)
    Local oModel			:= FWModelActive()
    Local oView			:= FWViewActive()
    Local oGridNPN		:= oModel:GetModel("MdGridNPN")
    Local ni				:= 0
    Local aSaveLines	:= FWSaveRows()

    For ni := 1  To oGridNPN:Length()
        oGridNPN:GoLine(nI)
        oGridNPN:loadValue("NPN_LOCAL",cLocal)
    next ni
    FWRestRows(aSaveLines)
    oView:Refresh('VwGridNPN')
Return .t.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900CAR
Carrega os dados da autorizaão de carregamento para o Grid.
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900CAR(oView, cAutoriza)
    Local oModel	:= FWModelActive()
    Local oGridNPH	:= oModel:GetModel("MdGridNPH")
    Local oGridNPN	:= oModel:GetModel("MdGridNPN")
    Local aAuxNPH	:= oGridNPH:GetStruct():GetFields()
    Local nLinha 	:= 0,nI := 0

    AGRSETNOLINE(oGridNPH,.F.,.F.,.F.)

    IF Empty( FwFldGet("NPM_CODAC") )
        Return ( .t. )
    EndIF

    BeginSQL Alias "NPHTMP"
		SELECT *
		FROM %Table:NPH% NPH
		WHERE NPH.NPH_FILIAL=%xFilial:NPH% AND NPH.NPH_CODAC=%Exp:FwFldGet("NPM_CODAC")% AND NPH.%NotDel%
    EndSQL

    nLinha := 0
    While !NPHTMP->(EOF())
        nLinha++

        If nLinha > oGridNPH:GetQtdLine()
            oGridNPH:AddLine()
        EndIf

        oGridNph:GoLine( nLinha )  // Posiciona o Grid na Linha
        For nI := 1 To Len(aAuxNPH)
            // Tratamento para preencher o campo virtual descrição do produto
            If aAuxNPH[nI][3] $ "NPH_DESCPR"
                SB1->(dbSeek(xFilial("SB1")+NPHTMP->NPH_CODPRO))
                oGridNPH:LoadValue(aAuxNPH[nI][3],SB1->B1_DESC)
                Loop
            EndIf

            If NPHTMP->(FieldPos(aAuxNPH[nI][3])) > 0 // Valida se a coluna existe no arquivo temporario
                oGridNPH:LoadValue(aAuxNPH[nI][3],NPHTMP->&(aAuxNPH[nI][3]))
            EndIf
        Next

        oGridNPN:InitLine()
        AGRLOADVALUE(oGridNPN,{{"NPN_ITEM"	,'001'},{"NPN_CODPRO",oGridNPH:GetValue("NPH_CODPRO"	)},{"NPN_LOCAL",oGridNPH:GetValue("NPH_LOCAL")}	,;
            {"NPN_CODAC",oGridNPH:GetValue("NPH_CODAC")},{"NPN_ITEMAC",oGridNPH:GetValue("NPH_ITEM")}})
        NPHTMP->(dbSkip())
    End

    AGRSETNOLINE(oGridNPH,.T.,.F.,.T.)

    oGridNPH:Goline(1)
    NPHTMP->(dbCloseArea())

    If !IsBlind()
        oView:Refresh()
    EndIf
Return .T.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900F4
Consulta de Saldos
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900F4()
    If ReadVar() == "M->NPN_LOTE"
        F4Lote2(FwFldGet("NPN_CODPRO"),FwFldGet("NPN_LOCAL"),FwFldGet("NPN_LOCALI"),FwFldGet("NPH_CULTRA"),FwFldGet("NPH_CTVAR"),FwFldGet("NPH_CATEG"),FwFldGet("NPH_PENE"))
    ElseIf ReadVar() == "M->NPN_LOCALI"
        F4Localiz(,,, "AGR900",FwFldGet("NPN_CODPRO"),FwFldGet("NPN_LOCAL"),,ReadVar())
    ElseIf ReadVar() == "M->NPN_QUANT"
        MaViewSB2(FwFldGet("NPH_CODPRO"))
    EndIf
Return .T.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900GRV
Gravação do modelo de dados
@param: Nil
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA900GRV(oModel)
    Local oGridNPH	:= oModel:GetModel('MdGridNPH')
    Local oGridNPN	:= oModel:GetModel('MdGridNPN')
    Local nOperation:= oModel:GetOperation()
    Local nL,nX,nPos := 0
    Local lRet      := .T.
    Local cContrato :=""
    Local cReserva	:= ""
    local cCliente	:=""
    Local cChavNPG	:= FwFldGet("NPH_CODAC")
    Local cCNPMAc	:= NPM->NPM_CODAC
    Local aMatNPN
    Local vVetNPN := {}
    Local nSaveSx8  := GetSx8Len()

    // Guarda o empenho
    If AGRIFDBSEEK("NPN",FwFldGet("NPM_CODIGO"),1,.F.)
        aMatNPN := {}
        While !Eof() .And. NPN->NPN_FILIAL == Xfilial("NPN") .And. NPN->NPN_ORDEMC == FwFldGet("NPM_CODIGO")
            If Ascan(vVetNPN,{|x| x = NPN->NPN_CODAC+NPN->NPN_ITEMAC}) = 0
                Aadd(vVetNPN,NPN->NPN_CODAC+NPN->NPN_ITEMAC)
            EndIf
            If !Empty(NPN->NPN_QUANT)
                Aadd(aMatNPN,{NPN->NPN_CODPRO,NPN->NPN_LOCAL,NPN->NPN_QUANT,NPN->NPN_LOTE,NPN->NPN_LOCALI,NPM->NPM_DATA,NPN->NPN_QTD2UM,NPN->NPN_RESERV})
            EndIf
            AGRDBSELSKIP("NPN")
        End
    EndIf

    If nOperation = 5
        If !Empty(NPM->NPM_NUMPV) .Or. !Empty(NPM->NPM_NFS) .Or. !Empty(NPM->NPM_SERNFS)
            Help(" ",1,"AGRA900PV",,CHR(13) +  STR0063,,3,0) //Carregamento com pedido de venda e nota fiscal relacionada
            Return .f.
        EndIf
    EndIf

    Begin Transaction
        /*PERCORRE AMBOS GRIDS PARA VALIDAR OPERAÇÕES EFETUADAS E EFETUAR A OPERAÇÃO NA RESERVA EQUIVALENTE*/
        NPH->(dbSetOrder(1))
        For nL := 1 To oGridNPH:Length()
            oGridNPH:Goline(nL)
            For nX := 1 to oGridNPN:GetQtdLine()
                oGridNPN:GoLine(nX)
                If oGridNPN:IsDeleted()
                    //--------------------
                    // Deleta a Reserva
                    //--------------------
                    If AGRIFDBSEEK("SC0",(oGridNPN:GetValue ("NPN_RESERV") + oGridNPN:GetValue ("NPN_CODPRO") + oGridNPN:GetValue ("NPN_LOCAL")),1,.F.)
                        lRet := a430Reserv({3,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},SC0->C0_NUM,SC0->C0_PRODUTO,SC0->C0_LOCAL,SC0->C0_QUANT,;
                            {SC0->C0_NUMLOTE,SC0->C0_LOTECTL,SC0->C0_LOCALIZ,SC0->C0_NUMSERI})

                        If !lRet
                            Help(,, STR0029,, STR0139, 1, 0 ) //aviso #Só é possivel excluir ordem de carregamento com nf excluida
                        Endif
                    Endif
                ElseIf oGridNPN:IsInserted() .and. oGridNPN:GetValue ("NPN_QUANT") > 0

                    //----------------------------
                    // Pega um numero de reserva
                    //----------------------------
                    AGRIFDBSEEK("ADA",oGridNPH:GetValue ("NPH_NUMCP"),1,.F.)
                    cReserva := GetSx8Num("SC0","C0_NUM")
                    While (GetSX8Len() > nSaveSx8)
                        ConfirmSx8()
                        dbSkip()
                    End

                    //---------------------------------------
                    // Valida o saldo para efetuar a reserva
                    //---------------------------------------
                    dbSelectArea("SB2")
                    dbSetOrder(1)
                    MsSeek(xFilial("SB2")+fWfldGet('NPN_CODPRO')+fWfldGet('NPN_LOCAL'))

                    If ( !RecLock("SB2") .Or. SaldoMov() < fWfldGet('NPN_QUANT') )
                        Help(,, STR0029,, STR0138, 1, 0 )   //aviso #Só é possivel excluir ordem de carregamento com nf excluida
                        lRet := .F.
                    Else
                        lRet := .T.
                    EndIf

                    If lRet //Chama a função para criação de reserva
 
                        //-------------------------
                        // Efetua a Reserva
                        //-------------------------

                        lRet := a430Reserv({1,"CL",ADA->ADA_CODCLI,UsrRetName(__cUserId),NPN->NPN_FILIAL},;
                            cReserva,oGridNPN:GetValue ("NPN_CODPRO"),oGridNPN:GetValue ("NPN_LOCAL"),oGridNPN:GetValue ("NPN_QUANT"),;
                            {"",oGridNPN:GetValue ("NPN_LOTE"),oGridNPN:GetValue ("NPN_LOCALI"),""})

                        //-------------------------------
                        // Se o retorno for ok, atualiza
                        //-------------------------------
                        If lRet
                            oGridNPN:SetValue("NPN_RESERV", cReserva )
                        Else
                            Help(,, STR0029,,STR0137 , 1, 0 ) //Aviso #"Reserva do lote não pôde ser efetuada."
                        Endif
                    Endif
                ElseIf oGridNPN:IsUpdated()
                    //--------------------
                    // Altera a Reserva
                    //--------------------
                    If AGRIFDBSEEK("SC0",(oGridNPN:GetValue ("NPN_RESERV") + oGridNPN:GetValue ("NPN_CODPRO") + oGridNPN:GetValue ("NPN_LOCAL")),1,.F.)
                        lRet := a430Reserv({2,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},;
                            oGridNPN:GetValue ("NPN_RESERV"),oGridNPN:GetValue ("NPN_CODPRO"),oGridNPN:GetValue ("NPN_LOCAL"),oGridNPN:GetValue ("NPN_QUANT"),;
                            {SC0->C0_NUMLOTE,oGridNPN:GetValue ("NPN_LOTE"),oGridNPN:GetValue ("NPN_LOCALI"),SC0->C0_NUMSERI})

                        //-------------------------------
                        // Se o retorno for ok, atualiza
                        //-------------------------------
                        If lRet
                            oGridNPN:SetValue("NPN_RESERV", cReserva )
                        Else
                            Help(,, STR0029,,STR0137 , 1, 0 ) //Aviso #"Reserva do lote não pôde ser efetuada."
                        Endif

                    ElseIf oGridNPN:GetValue ("NPN_QUANT") > 0
                        //------------------------------
                        // Pega um numero de reserva
                        //------------------------------
                        AGRIFDBSEEK("ADA",oGridNPH:GetValue ("NPH_NUMCP"),1,.F.)
                        cReserva := GetSx8Num("SC0","C0_NUM")
                        While (GetSX8Len() > nSaveSx8)
                            ConfirmSx8()
                            dbSkip()
                        End

                        //---------------------------------------
                        // Valida o saldo para efetuar a reserva
                        //---------------------------------------
                        dbSelectArea("SB2")
                        dbSetOrder(1)
                        MsSeek(xFilial("SB2")+fWfldGet('NPN_CODPRO')+fWfldGet('NPN_LOCAL'))

                        If ( !RecLock("SB2") .Or. SaldoMov() < fWfldGet('NPN_QUANT') )
                            Help(,, STR0029,, STR0138, 1, 0 )  //aviso #Só é possivel excluir ordem de carregamento com nf excluida
                            lRet := .F.
                        Else
                            lRet := .T.
                        EndIf

                        If lRet
                            //--------------------
                            // Efetua a Reserva
                            //--------------------
                            lRet := a430Reserv({1,"CL",ADA->ADA_CODCLI,UsrRetName(__cUserId),NPN->NPN_FILIAL},;
                                cReserva,oGridNPN:GetValue ("NPN_CODPRO"),oGridNPN:GetValue ("NPN_LOCAL"),oGridNPN:GetValue ("NPN_QUANT"),;
                                {"",oGridNPN:GetValue ("NPN_LOTE"),oGridNPN:GetValue ("NPN_LOCALI"),""})

                            //-------------------------------
                            // Se o retorno for ok, atualiza
                            //-------------------------------
                            If lRet
                                oGridNPN:SetValue("NPN_RESERV", cReserva )
                            Else
                                Help(,, STR0029,,STR0137 , 1, 0 ) //Aviso #"Reserva do lote não pôde ser efetuada."
                            Endif
                        Endif

                    Endif
                EndIf
            Next nx
        Next nL

        If nOperation == MODEL_OPERATION_DELETE
            // Busca relacionamento da autorização de Carregamento com o contrato de parceria
            If (nPosCtr := aScan(oGridNPH:aHeader,{ |x| Alltrim(x[2]) == "NPH_NUMCP" } ) )  > 0
                If (nPos := aScan(oGridNPH:aCols,{ |x| !Empty( x[nPosCtr] ) } ) ) > 0
                    AGRALTCAMBA("NPG",FwFldGet("NPM_CODAC"),1,"NPG_STATUS","2")
                    cContrato := oGridNPH:aCols[nPos,nPosCtr]
                EndIf
            EndIf
        EndIf

        If lRet
            NPH->(dbSetOrder(1))
            For nX := 1 To oGridNPH:Length()
                oGridNPH:Goline(nX)

                // Atualiza relacionamento com os itens da Autorização de carregamento
                If nOperation == 3 .Or. nOperation == 5
                    AGRALTCAMBA("NPH",FwFldGet("NPH_CODAC")+FwFldGet("NPH_ITEM"),1,"NPH_ORDEMC",;
                        If(nOperation == 3,FwFldGet("NPM_CODIGO"),CriaVar("NPH_ORDEMC")))
                EndIf
                If nOperation == 3 .Or. nOperation == 4
                    If AGRIFDBSEEK("NPH",FwFldGet("NPH_CODAC")+FwFldGet("NPH_ITEM"),1,.f.)
                        AGRTRAVAREG("NPH",.F.)
                        AGRGRAVAREG("NPH",{{'NPH_LOCAL',FwFldGet("NPH_LOCAL")},{'NPH_CATEG',FwFldGet("NPH_CATEG")},{'NPH_PENE',FwFldGet("NPH_PENE")}})
                        AGRDESTRAREG()
                    EndIf
                EndIf
            Next nx
        EndIf

        If lRet
            FWFormCommit(oModel)
            // Atualiza Status do Contrato de Parceria
            AGRIFDBSEEK("ADA",oGridNPH:GetValue ("NPH_NUMCP"),1,.F.)
            cCliente := ADA->ADA_CODCLI
            Ft400StatCt()

            AGRTRAVAROT("AGRA900GRV")
            If nOperation = 5 .AND. aMatNPN <> Nil
                //Deleta a RESERVA
                For nx := 1 To Len(aMatNPN)
                    //--------------------
                    // Deleta a Reserva
                    //--------------------
                    AGRIFDBSEEK("SC0",(aMatNPN[nx,8]+aMatNPN[nx,1]+aMatNPN[nx,2]),1,.F.)
                    a430Reserv({3,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},;
                        SC0->C0_NUM,;
                        SC0->C0_PRODUTO,;
                        SC0->C0_LOCAL,;
                        SC0->C0_QUANT,;
                        {SC0->C0_NUMLOTE,;
                        SC0->C0_LOTECTL,;
                        SC0->C0_LOCALIZ,;
                        SC0->C0_NUMSERI})
                Next nx
            EndIf
            //Atualiza o status da autorização
            AGRA900NPGS(cChavNPG,NPM->NPM_CODIGO)
            AGRDESTROTIN("AGRA900GRV")

            // Gera histórico
            If nOperation = 4 .And. !Empty(cAliTHi)
                AGRHISTNREG("NPN",1,cAliTHi)
            EndIf

        EndIf

        // Exclusão da ordem
        If nOperation == MODEL_OPERATION_DELETE
            AGRALTCAMBA("NPG",cCNPMAc,1,"NPG_STATUS","2")
        EndIf

        If !lRet
            DisarmTransaction()
        EndIf

    End Transaction
Return(lRet)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900CPO
Validação de Campos
@author: Aecio Ferreira Gomes
@since: 20/02/2013
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900CPO()
    Local cStatus  := AGR890STAT(FwFldGet("NPM_CODAC"))
    Local cReadVar := ReadVar()
    Local lRet	:= .T.

    If cReadVar == "M->NPN_LOCALI"
        lRet := Vazio() .Or. ExistCPO("SBE",NPN->NPN_LOCAL+M->NPN_LOCALI )
    ElseIf cReadVar == "M->NPM_LOCAL"
        lRet := ExistCPO("NNR")
    ElseIf cReadVar == "M->NPM_CODAC"
        lRet := Vazio() .Or. ExistCPO("NPG")
        If lRet .And. cStatus <> "2" .AND. !Empty(M->NPM_CODAC)
            lRet := .F.
            Help(" ",1,"AGRA900STATUS")
        EndIf

        If lRet .And. !Empty(M->NPM_CODAC).And. AGRIFDBSEEK("NPH",M->NPM_CODAC,1,.F.)
            While !Eof() .And. NPH->NPH_FILIAL = Xfilial("NPH") .And. NPH->NPH_CODAC = M->NPM_CODAC
                If !Empty(NPH->NPH_ORDEMC)
                    Help(" ",1,"AGRA900JACL",,CHR(13)+STR0065,3,0) //ja existe um carregamento para esta autorização
                    Return .f.
                EndIf
                DbSkip()
            End
        EndIf
    ElseIf cReadVar == "M->NPN_LOTE"
        lRet := VldLoteNPN()
    EndIf
Return(lRet)

/*/{Protheus.doc} VldLoteNPN
Validação do campo NPN_LOTE, usa função fQryLote para manter mesma retorno e filtro de dados da consulta
@type function
@version  P12
@author claudineia.reinert
@since 25/08/2021
@return Logical, Retorno logica .t. ou .f.
/*/
Static Function VldLoteNPN()
    Local lRet      := .T.
    Local cCodSaf   := Posicione("ADA",1,fWxfilial("ADA")+FwFldGet("NPH_NUMCP"),"ADA_CODSAF")
    Local cAliasQry := "" 
    Local oModel    := FWModelActive()
    Local oGridNPN  := oModel:GetModel("MdGridNPN")

    //faz a consulta e cria o alias ja posicionado
    cAliasQry := fQryLote(FwFldGet('NPN_CODPRO'), cCodSaf, FwFldGet("NPH_CULTRA"), FwFldGet("NPH_CTVAR"), FwFldGet("NPH_PENE"), FwFldGet("NPH_CATEG"), FwFldGet("NPH_LOCAL"),FwFldGet("NPN_LOTE")) //query retorno filtro da consulta dos lotes
    
    IF (cAliasQry)->(!EOF()) .AND. (cAliasQry)->(NP9_LOTE) = FwFldGet("NPN_LOTE")  
        lRet := .T.
        oGridNPN:SetNoUpdateLine( .F. )
        //carrega valores para os campos-gatilho
        AGRLOADVALUE(oGridNPN,{{"NPN_LOCALI",(cAliasQry)->BF_LOCALIZ},{"NPN_CULTRA",(cAliasQry)->NP9_CULTRA},{"NPN_CTVAR",(cAliasQry)->NP9_CTVAR},;
                {"NPN_CATEG",(cAliasQry)->NP9_CATEG},{"NPN_PENE",(cAliasQry)->NP9_PENE},{"NPN_LOCAL" ,(cAliasQry)->B8_LOCAL}})      
    Else
        lRet := .F.
        AgrHelp(Alltrim(DescriSX3("NPN_LOTE")),STR0147,STR0148)
    EndIf

    ARGCLOSEAREA(cAliasQry) //fecha alias

Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900DT
Validação da data da autorização
@author: Inácio Luiz Kolling
@since: 08/06/2015
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900DT()
    If FwFldGet("NPN_DATA") <> NPG->NPG_DTAUTO
        Help(,,"DATAINVALD",,STR0107,1,0) //Divergencia da data de carregamento com a autorização. Replanejar a autorização de carregamento
        Return .f.
    EndIf
Return .t.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900STA
Geração do pedido de venda
@author: Inácio Luiz Kolling
@since: 08/06/2015
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900STA()
    Local nx,nPos,cPvGerado	:= Criavar("C5_NUM",.F. )  // Ira Armazenar o nr. do Pv Gerado
    Local aArea	  	:= GetArea()
    Local cItSC6	:= StrZero(0,TamSX3("C6_ITEM")[1])
    Local aMatNPN	:= {} //,1] chave ,2] item pedido
    Local aMatNPH	:= {} //,1] chave ,2] somatório
    Local aMatSC6	:= {}
    Local cChavNPM 	:= NPM->NPM_CODIGO+NPM->NPM_CODAC
    Local cCarrega 	:= NPM->NPM_CODAC
    Local nPesoL	:= 0
    Local nPesoB	:= 0
    Local lAGR900P5 := EXISTBLOCK("AGR900P5")
    Local lRet      := .T.
    Local lAlerta1  := .F.
    Local lAlerta2  := .F.
    Local lHelp 	:= .F.
    Private lMsErroAuto	:= .F.
    Private lMSHelpAuto := .T.
    Private lParT9      := .t.
    Private aPedido		:= {{},{}}
    Private aItens      := {}
    Private nCustPed

    Pergunte('AGRA900', .F.)

    Store 0 To nx,nPos,nCustPed

    AGRIFDBSEEK("NPH",NPM->NPM_CODAC,1,.F.)
    cContr := NPH->NPH_NUMCP

    //Valida Status
    If NPM->NPM_STATUS $ "12"
        If NPM->NPM_STATUS = '1' .AND. !IsIncallStack("AGRA900_003")
            If !MsgYesNo(STR0043,STR0029)   //Ordem de carregamento não utilizará toda a quantidade disponivel da autorização de carregamento, deseja prosseguir? //aviso
                lPedi := .F.
            EndIf
        EndIf
        // -->> Verifica se Vai Gerar um Pv, em Outra Moeda Se Sim, Verifica se existe a axa da Moeda Cadastrada.	<<--
        // -->> Não irá permitir Gerar um Pv em Outra Moeda que não tenha taxa de moeda Cadastrada					<<--
        AGRIFDBSEEK("ADA",cContr,1,.F.) // Posiciono no Contrato
        SM2->(DbSetOrder(1))
        IF !(ADA->ADA_MOEDA = 1) .and. (!SM2->(DBSEEK(DtoS(dDataBase))) /*se nao achar*/ .or.  xMoeda( 1, ADA->ADA_MOEDA, 1, dDataBase, TamSX3("M2_MOEDA2")[2] ) == 0 )//Se não encontrou Taxa Cadastrada na Data
            //Atenção a Xmoeda ira encontrar a Taxa mais proxima da mais atual para menos aatul o por isso do Dbseek
            MsgStop(STR0133 + cValToChar(ADA->ADA_MOEDA), Alltrim( Procname() )) 		//###'O pedido não pode ser gerado pois não existe taxa informada para a Moeda: '### "AGRA900STA"
        Else
            nModulo := 5
            Begin Transaction
                If EXISTBLOCK ("AGR900PV")
                    aPedido := ExecBlock("AGR900PV",.F.,.F.,{aPedido})

                    If ValType(aPedido)== 'A' .and. Len(aPedido) > 0
                        aItens := aPedido[2]
                    EndIf
                Else
                    dbSelectArea('NPG')
                    dbSetOrder(1)
                    If dbSeek(fwxFilial('NPG')+NPM->NPM_CODAC)
                        AGRIFDBSEEK("NPH",NPM->NPM_CODAC,1,.F.)
                        AGRIFDBSEEK("ADA",NPH->NPH_NUMCP,1,.F.)
                        cADACont := NPH->NPH_NUMCP

                        aAdd(aPedido[1],{"C5_TIPO"	 ,"N"				   										  ,Nil})
                        aAdd(aPedido[1],{"C5_CLIENTE",NPG->NPG_CLIORI											  ,Nil})
                        aAdd(aPedido[1],{"C5_LOJACLI",NPG->NPG_LOJORI											  ,Nil})
                        aAdd(aPedido[1],{"C5_CLIENT" ,If(!Empty(NPG->NPG_CLIDES),NPG->NPG_CLIDES,NPG->NPG_CLIORI) ,Nil})
                        aAdd(aPedido[1],{"C5_LOJAENT",If(!Empty(NPG->NPG_LOJDES),NPG->NPG_LOJDES,NPG->NPG_LOJORI) ,Nil})
                        aAdd(aPedido[1],{"C5_CONDPAG",NPG->NPG_CONDPG											  ,Nil})
                        
                        If SC5->(FieldPos("C5_INDPRES")) > 0 //Presença Comprador (NT 2020.006)
                            aAdd(aPedido[1],{"C5_INDPRES", "0"   ,Nil})
                        EndIf

                        If AGRIFDBSEEK("DA3",NPG->NPG_PLACA,3,.f.)
                            IIf ( !Empty(DA3->DA3_COD), aAdd(aPedido[1],{"C5_VEICULO" , DA3->DA3_COD , Nil}), )
                        Endif

                        AGRAREAORDE("DA3",1)

                        IIf ( !Empty(NPG->NPG_TRANSP), aAdd(aPedido[1],{"C5_TRANSP"  , NPG->NPG_TRANSP , Nil}), )
                        IIf ( !Empty(ADA->ADA_MOEDA) , aAdd(aPedido[1],{"C5_MOEDA"   , ADA->ADA_MOEDA  , Nil}), )
                        IIf ( !Empty(ADA->ADA_TABELA), aAdd(aPedido[1],{"C5_TABELA"  , ADA->ADA_TABELA , Nil}), )
                        IIf ( !Empty(ADA->ADA_MENNOT), aAdd(aPedido[1],{"C5_MENNOT"  , ADA->ADA_MENNOT, Nil}), )
                        IIf ( !Empty(ADA->ADA_FRETE) , aAdd(aPedido[1],{"C5_FRETE"   , ADA->ADA_FRETE  , Nil}), )
                        IIf ( !Empty(ADA->ADA_TPFRET), aAdd(aPedido[1],{"C5_TPFRETE" , ADA->ADA_TPFRET , Nil}), )
                        IIf ( !Empty(ADA->ADA_SEGURO), aAdd(aPedido[1],{"C5_SEGURO"  , ADA->ADA_SEGURO , Nil}), )
                        IIf ( !Empty(NPM->NPM_VOLUME), aAdd(aPedido[1],{"C5_VOLUME1" , NPM->NPM_VOLUME , Nil}), )
                        IIf ( !Empty(NPM->NPM_ESPECI), aAdd(aPedido[1],{"C5_ESPECI1" , NPM->NPM_ESPECI , Nil}), )

                        nCustPed := 0
                        dbSelectArea('NPH')
                        dbSetOrder(1)
                        If dbSeek(fwxFilial('NPH')+NPM->NPM_CODAC)

                            While !Eof() .And. NPH->NPH_FILIAL+NPH->NPH_CODAC = fwxFilial("NPH")+NPM->NPM_CODAC

                                dbSelectArea('NPN')
                                dbSetOrder(2)
                                If dbSeek(fwxFilial('NPN')+NPH->NPH_CODAC+NPH->NPH_ITEM)
                                    nQtdC := 0
                                    While !Eof() .And. NPN->NPN_FILIAL+NPN->NPN_CODAC+NPN->NPN_ITEMAC = fwxFilial("NPN")+NPH->NPH_CODAC+NPH->NPH_ITEM
                                        If !Empty(NPN->NPN_QUANT) .And. Empty(NPN->NPN_NUMPV) .And. Empty(NPN->NPN_ITEMPV)
                                            nQtdC += NPN->NPN_QUANT

                                            aPedido[2]	:= {}
                                            cItSC6 := Soma1(cItSC6)
                                            aAdd(aPedido[2],{"C6_ITEM"	 ,cItSC6												,Nil})
                                            aAdd(aPedido[2],{"C6_PRODUTO",NPN->NPN_CODPRO 						  				,Nil})
                                            aAdd(aPedido[2],{"C6_QTDVEN" ,NPN->NPN_QUANT										,Nil})
                                            aAdd(aPedido[2],{"C6_PRCVEN" ,NPH->NPH_PRCVEN						  				,Nil})
                                            aAdd(aPedido[2],{"C6_LOCAL"	 ,NPN->NPN_LOCAL							  			,Nil})
                                            aAdd(aPedido[2],{"C6_VALOR"	 ,a410Arred(NPH->NPH_PRCVEN * NPN->NPN_QUANT ,"C6_VALOR"),Nil})
                                            aAdd(aPedido[2],{"C6_CODSAF" ,ADA->ADA_CODSAF						  				,Nil})

                                            //Adiciona pesos dos produtos ao pedido e soma para adicionar ao cabeçalho em seguida
                                            AGRIFDBSEEK("SB1",NPN->NPN_CODPRO,1,.F.)
                                            aAdd(aPedido[2],{"C6_PESOL"  ,SB1->B1_PESO						  				,Nil})
                                            aAdd(aPedido[2],{"C6_PBRUTO" ,SB1->B1_PESBRU					  				,Nil})
                                            nPesoL 	+= (SB1->B1_PESO	* NPN->NPN_QUANT)
                                            nPesoB	+= (SB1->B1_PESBRU	* NPN->NPN_QUANT)

                                            nCustPed += a410Arred(NPH->NPH_PRCVEN * NPN->NPN_QUANT,"C6_VALOR")

                                            Aadd(aMatSC6,{cItSC6,NPN->NPN_QTD2UM,CriaVar("ADB_NUMCTR"),CriaVar("ADB_ITEM"),0,0,NPN->NPN_QUANT})

                                            // Se existir o contrato
                                            If AGRIFDBSEEK("ADB",NPH->NPH_NUMCP+NPH->NPH_ITEMCP,1,.f.)
                                                aAdd(aPedido[2],{"C6_TES"	,	ADB->ADB_TES								,Nil})
                                                aAdd(aPedido[2],{"C6_PRUNIT",	ADB->ADB_PRUNIT	                            ,Nil})
                                                //Alimenta contrato, caso o pergunte esteja com a opção SIM.
                                                If MV_PAR02 = 1
                                                    aAdd(aPedido[2],{"C6_CONTRAT"	,ADB->ADB_NUMCTR							,Nil})
                                                    aAdd(aPedido[2],{"C6_ITEMCON",	ADB->ADB_ITEM								,Nil})
                                                EndIF
                                                aMatSC6[Len(aMatSC6),3] := ADB->ADB_NUMCTR
                                                aMatSC6[Len(aMatSC6),4] := ADB->ADB_ITEM
                                                //Valida Parametro do Faturamento MV_NDESCTP
                                                If !GetNewPar("MV_NDESCTP",.F.)

                                                    aMatSC6[Len(aMatSC6),5] := ADB->ADB_DESC
                                                    aMatSC6[Len(aMatSC6),6] := (ADB->ADB_VALDES / 100) * NPN->NPN_QUANT
                                                Endif
                                                cContrato := ADB->ADB_NUMCTR
                                            Else
                                                AGRIFDBSEEK("SB1",NPN->NPN_CODPRO,1,.F.)
                                                aAdd(aPedido[2],{"C6_TES",SB1->B1_TS, Nil})
                                            EndIf

                                            //Localiza reserva do produto caso encontre, repassa ao item do pedido
                                            dbSelectArea('SC0')
                                            dbSetOrder(1)
                                            If dbSeek(FwXFilial('SC0')+NPN->NPN_RESERV+NPN->NPN_CODPRO+NPN->NPN_LOCAL)
                                                aAdd(aPedido[2],{"C6_RESERVA" ,SC0->C0_NUM		,Nil})
                                                aAdd(aPedido[2],{"C6_QTDRESE" ,SC0->C0_QUANT	,Nil})
                                            Endif

                                            aAdd(aPedido[2],{"C6_LOCALIZ",NPN->NPN_LOCALI,'alwaysTrue()'})

                                            //Manipula array antes da chamada de geração do Pedido
                                            //aPedido [1] = Cabeçalho
                                            //aPedido [2] = Itens
                                            If lAGR900P5
                                                aPedido := ExecBlock("AGR900P5",.F.,.F.,{aPedido})
                                            Endif

                                            aAdd(aItens,aPedido[2])
                                            Aadd(aMatNPN,{NPN->NPN_CODPRO+NPN->NPN_ORDEMC+NPN->NPN_ITEM,cItSC6, NPN->(Recno() )})

                                        EndIf
                                        dbSelectArea('NPN')
                                        dbSkip()
                                    End
                                Endif

                                If !Empty(nQtdC)
                                    Reclock("NPH",.F.)
                                    NPH->NPH_QTDDIS := NPH->NPH_QTDDIS - nQtdC
                                    MsUnlock()
                                EndIf

                                Aadd(aMatNPH,{NPH->NPH_CODAC+NPH->NPH_ITEM,nQtdC})
                                dbSelectArea('NPH')
                                dbSkip()
                            End
                        Endif

                        vVetToC := AGRSOMACAMP("ADB",cADACont,1,"ADB->ADB_FILIAL = XFILIAL('ADB') .And. ADB->ADB_NUMCTR = '"+cADACont+"'",{"ADB_QUANT"})

                        Aadd(aPedido[1],{"C5_MOEDA" 	,nCustPed,Nil})

                        //Adiciona soma de pesos ao cabeçalho do pedido
                        Aadd(aPedido[1],{"C5_PESOL" 	,nPesoL,Nil})
                        Aadd(aPedido[1],{"C5_PBRUTO" 	,nPesoB,Nil})

                        If !Empty(aItens)
                            // Permite manipular os dados antes executar a rotina automatica para criar o pedido de venda
                            If ExistBlock("AGR900P2")
                                lParT9 := ExecBlock("AGR900P2",.F.,.F.,)
                            EndIf
                        EndIf
                    Endif
                EndIf

                If !Empty(aItens) .And. lParT9
                    lGeraPed := If(AGRGRAVAHIS(STR0032,"NPM",xFilial("NPM")+NPM->NPM_CODIGO+NPM->NPM_CODAC,"A") <> 1,.F.,.T.)
                    If lGeraPed

                        acab       := aPedido[1]
                        aPedido[1] := FWVetByDic(aCab,'SC5')
                        aItens     := FWVetByDic(aItens,'SC6',.T.)
                        MsAguarde({||MSExecAuto({|a,b,c|Mata410(a,b,c)},aPedido[1],aItens,3)},STR0010,STR0011) //Aguarde... //Gerando pedido de venda...
                    Else
                        //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
                        RollBackSx8()
                        DisarmTransaction()
                        RestArea(aArea)
                        lRet := .F.
                        lHelp := .T.
                        Break
                    Endif

                    If lMsErroAuto
                        //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
                        RollBackSX8()
                        DisarmTransaction()
                        lRet := .F.
                        lAlerta1 := .T.
                    Else
                        cPvGerado := SC5->C5_NUM
                        //TODO Atualiza campos dos itens do pedido que estão tanto problema a geração automática
                        For nx := 1 To Len(aMatSC6)
                            If AGRIFDBSEEK("SC6",SC5->C5_NUM+aMatSC6[nx,1],1,.F.)
                                AGRTRAVAREG(,.F.)
                                AGRGRAVAREG("SC6",{{'C6_CONTRAT',aMatSC6[nx,3]},{'C6_ITEMCON',aMatSC6[nx,4]},;
                                    {'C6_DESCONT',aMatSC6[nx,5]},{'C6_VALDESC',aMatSC6[nx,6]}})
                                AGRDESTRAREG()
                                AGRALTCAMBA("SC9",SC6->C6_NUM+SC6->C6_ITEM+"01"+SC6->C6_PRODUTO,1,"C9_LOTECTL",SC6->C6_LOTECTL)
                            EndIf
                        Next nx

                        // Faz relacionamento da ordem de carregamento com o pedido de vendas
                        AGRALTCAMBA("NPM",cChavNPM,1,"NPM_NUMPV",SC5->C5_NUM)
                        If !Empty(cPvGerado)
                            // Atualiza NPN e NPH
                            For nx := 1 To Len(aMatNPN)
                                nPosReg := 3
                                NPN->(dBGoto( aMatNPN [nX , nPosReg ] ))
                                AGRTRAVAREG("NPN",.F.)
                                AGRGRAVAREG("NPN",{{'NPN_NUMPV',SC5->C5_NUM},{'NPN_ITEMPV',aMatNPN[nx,2]}})
                                AGRDESTRAREG()
                            Next nx
                        Endif
                    EndIf
                Else
                    //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
                    If !lParT9
                        DisarmTransaction()
                    EnDiF
                    lRet := .F.
                    lAlerta2 := .T.
                EndIf
            End Transaction

            //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
            If !lRet
                Do Case
                    Case lHelp
                        Help(,,STR0029,,STR0045,1,0) //aviso //gravações realizadas
                    Case lAlerta1
                        MostraErro()
                        Alert(STR0108+Chr(13)+STR0109) //saldo insuficiente para o lote //passagem de parametros para função padrão
                    Case lAlerta2
                        Alert(STR0080+Chr(13)+STR0081) //não possivel gerar o pedido de vendas //problema de relacionamento entre autorização, ordem, pedido, nota fiscal
                End Case
                Return
            EndIf

            // Atualiza o status da autorização
            AGRA900NPGS(cCarrega,NPM->NPM_CODIGO)

            // Atualiza o contrato
            AGRIFDBSEEK("ADA",cContr,1,.F.)
            Ft400StatCt()

            IF !Empty(cPVGerado)   //Contem o Nr. do Pv Gerado, Então Passo Pela Liberação do ERP
                // Checa itens liberados
                aPvlNfs 	:= {}
                aBloqueio	:= {}

                // -- Verificando se o PV encontra-se Liberado e Abastecendo os Arrays [ APVLNFS e Abloqueio ] -- //
                DBSelectArea("SC5")
                SC5->( dbSetOrder(1) )
                IF SC5->( dbSeek(xFilial("SC5")+ cPVGerado ) )
                    Ma410LbNfs( 2, @aPvlNfs, @aBloqueio )  // Chama Rotina para Liberacao de pedido
                EndIF
            EndIF
            nModulo := 67
            RestArea(aArea)
        EndIf
    Else
        Alert(STR0074) //item em pedido de venda, finalizado ou cancelado
    EndIf
Return


// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900ACT
Validação antes da ativação do modelo de dados
@author: Aecio Ferreira Gomes
@since: 25/02/2013
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA900ACT(oModel)
    Local nOperation := oModel:GetOperation(),lRet := .T.

    // Valida se o Pedido de vendas existe, caso nao exista corta o relacionamento
    If (nOperation = MODEL_OPERATION_DELETE .Or. nOperation = MODEL_OPERATION_UPDATE) .And.;
            !Empty(NPM->NPM_NUMPV) .And. AGRIFDBSEEK("SC5",NPM->NPM_NUMPV,1,.F.)
        lRet := .F.
        Help(" ",1,"AGRA900PV",,CHR(13)+STR0066,3,0) //autorização com pedido de venda relacionado
    EndIf

    If lRet .And. nOperation = MODEL_OPERATION_UPDATE
        cAliTHi := AGRCOPINREG("NPN",Xfilial("NPN")+NPM->NPM_CODIGO,1,;
            "NPN->NPN_FILIAL = XFILIAL('NPN') .And. NPN->NPN_ORDEMC = '"+NPM->NPM_CODIGO+"'",{"NPN_ORDEMC"})
    EndIf
Return(lRet)

// -------------------------------------------------------------------------------------
/*/ {Protheus.doc} AGRA900NFS()
Preparação do documento de saída.
@author: Aecio Ferreira Gomes
@since:  25/02/2013
@Uso: 	 AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900NFS(cAlias,cRecno,nOpc)
    Local lRet 		:= .T.
    Local cChavNPM 	:= NPM->NPM_CODIGO+NPM->NPM_CODAC
    Local cPedido 	:= NPM->NPM_NUMPV
    Local cAut      := NPM->NPM_CODAC
    Local cOrdem    := NPM->NPM_CODIGO

    If !Empty(NPM->NPM_NFS)
        lRet := .F.
        Help(" ",1,"AGRA900NFS")
    EndIf

    If lRet .And. !AGRIFDBSEEK("SD2",cPedido,8,.f.)
        If AGRIFDBSEEK("SC5",cPedido,1,.F.)
            // Gera Nota Fiscal Emerson
            lRet:= FEmiteNF(cPedido)
        Else
            Help(" ",1,"AGR900NAOPV")
            lRet := .F.
        EndIf
    EndIf

    //Atualiza ordem de carregametno com o número da nota fiscal de saída e série
    If !Empty(cPedido) .And. AGRIFDBSEEK("SD2",cPedido,8,.f.)
        If AGRIFDBSEEK("NPM",cChavNPM,1,.F.)
            RecLock("NPM",.f.)
            AGRGRAVAREG("NPM",{{'NPM_NFS',SD2->D2_DOC},{'NPM_SERNFS',SD2->D2_SERIE},{'NPM_STATUS','4'}})
            NPM->( MsUnlock() )
        EndIf
        // ATUALIZA STATUS DO LOTE
        nQtdNPN := 0
        AGRIFDBSEEK("NPN",NPM->NPM_CODIGO,1,.f.)
        cContrato	:= Posicione("NPH", 1, xFilial("NPH")+NPN->NPN_CODAC+NPN->NPN_ITEMAC,"NPH_NUMCP")
        cSafra		:= Posicione("ADA", 1, xFilial("ADA")+cContrato,"ADA_CODSAF")
        cLoteNPN	:= NPN->NPN_LOTE
        cProdNPN	:= NPN->NPN_CODPRO
        While !Eof() .And. NPN->NPN_FILIAL+NPN->NPN_ORDEMC = xFilial("NPN")+NPM->NPM_CODIGO
            nQtdNPN += If(!Empty(NPN->NPN_QUANT),NPN->NPN_QUANT,0)
            dbSkip()
        End

        If AGRIFDBSEEK("NPG",cAut,1,.F.)
            // Atualiza o status da autorização
            AGRA900NPGS(cAut,cOrdem)
        EndIf

        // Atualiza o contrato
        AGRIFDBSEEK("ADA",cContrato,1,.F.)
        Ft400StatCt()
    EndIf
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} F4Lote2
Função F4 do campo Lote
@author: Inácio Luiz Kolling
@since: 08/06/2015
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function F4Lote2(cCod,cLocal,cLocali,cCultra,cCtvar,cCateg,cPene)
    Local cQuery ,cIndice := "",aIndex := {"NP9_LOTE"}
    Local nIndice,cChaveA,lRastroS := If(Rastro(cCod,"S"),.t.,.f.)
    local nx,ny,nSaldoL,nSaldoBF,cLocaliz
    Local oModel		:= FWModelActive()
    Local oGridNPN	:= oModel:GetModel("MdGridNPN")
    Local nlinha		:= oGridNPN:getline()
    Local CodSaf		:= AGRSEEKDIC("ADA",xfilial("ADA")+FwFldGet("NPH_NUMCP"),1,"ADA_CODSAF")
    Local aMatLote 	:= {},aSeek := {},aColumns	 := {}
    Local lQtdPrev := If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
    Local cAliNP9 := ""

    For nx := 1 To oGridNPN:Length()
        oGridNPN:GoLine(nx)
        if !oGridNPN:IsDeleted()
            cLocaln	 := alltrim(oGridNPN:GetValue("NPN_LOCAL",nx))
            cLote 	 := alltrim(oGridNPN:GetValue("NPN_LOTE",nx))
            cLocaliz := Alltrim(oGridNPN:GetValue("NPN_LOCALI",nx))
            if !Empty(cLocaliz) .and. !Empty(cLocaliz)
                Aadd(aMatLote,{cLote,cLocaliz,cLocaln})
            endif
        endif
    next
    oGridNPN:goline(nlinha)

    //Cria estrutura de arquivo temporario
    aCamTRB :=	{{"NP9_LOTE"},{"B8_LOCAL"},{"BF_LOCALIZ"},{"NP9_CULTRA"},{"NP9_CTVAR"},{"NP9_CATEG"},{"NP9_PENE"},{"NP9_2UM"},;
        {"B8_DTVALID"},{"B8_SALDO",TamSX3("B8_SALDO")[3],TamSX3("B8_SALDO")[1],TamSX3("B8_SALDO")[2],AGRTITULO("B8_SALDO"),PesqPict("SB8","B8_SALDO")},;
        {"BF_QUANT",TamSX3("BF_QUANT")[3],TamSX3("BF_QUANT")[1],TamSX3("BF_QUANT")[2],"Saldo Endereco",PesqPict("SBF","BF_QUANT")},;
        {"NP9_TIPLOT",TamSX3("NP9_TIPLOT")[3],TamSX3("NP9_TIPLOT")[1],TamSX3("NP9_TIPLOT")[2],AGRTITULO("NP9_TIPLOT"),PesqPict("NP9","NP9_TIPLOT")},;
        {"NP9_TRATO",TamSX3("NP9_TRATO")[3],TamSX3("NP9_TRATO")[1],TamSX3("NP9_TRATO")[2],AGRTITULO("NP9_TRATO"),PesqPict("NP9","NP9_TRATO")},;
        {"NP9_EMB",TamSX3("NP9_EMB")[3],TamSX3("NP9_EMB")[1],TamSX3("NP9_EMB")[2],AGRTITULO("NP9_EMB"),PesqPict("NP9","NP9_EMB")}}

    aRet := AGRCRIATRB(,aCamTRB,aIndex,FunName(),.t.)
    cNomeTRB := aRet[3] //Nome do arquivo temporário
    cAliTRBL := aRet[4] //Nome do alias do arquivo temporario
    aArqTemp := aRet[5] //Matriz com a estrutura do arquivo temporario + label e picutre

    //chama função que gera os dados para a consulta 
    cAliNP9 := fQryLote(cCod, CodSaf, cCultra, cCtvar, cPene, cCateg, cLocal) //query retorno filtro da consulta dos lotes
    
    While (cAliNP9)->(!Eof())
        nIndice := If(lRastroS,2,3)
        cChaveA := If(lRastroS,(cAliNP9)->BF_NUMLOTE+(cAliNP9)->NP9_LOTE+cCod+(cAliNP9)->B8_LOCAL,cCod+(cAliNP9)->B8_LOCAL+(cAliNP9)->NP9_LOTE)
        If AGRIFDBSEEK("SB8",cChaveA,nIndice,.f.)
            nSaldoL  := SB8Saldo(.F.,!Empty((cAliNP9)->NP9_LOTE),NIL,NIL,NIL,lQtdPrev,NIL,ddatabase,)
            nSaldoBF := SaldoSBF((cAliNP9)->B8_LOCAL,(cAliNP9)->BF_LOCALIZ,(cAliNP9)->NP9_PROD,NIL,(cAliNP9)->NP9_LOTE,NIL,.F.,NIL,.T.)
            //  (.F.)-> Retira o empenho
            If aScan(aMatLote,{|x| AllTrim(x[1]) = Alltrim((cAliNP9)->NP9_LOTE) .And. AllTrim(x[2]) = Alltrim((cAliNP9)->BF_LOCALIZ) .And.;
                    AllTrim(x[3]) = Alltrim((cAliNP9)->B8_LOCAL)}) = 0 .And. !Empty(nSaldoL)
                AGRGRAVA2T(cAliTRBL,cAliNP9)
                AGRGRAVAREG(cAliTRBL,{{'NP9_TRATO',(AGRRETSX3BOX("NP9_TRATO"	,(cAliNP9)->NP9_TRATO))},;
                    {'NP9_TIPLOT',(AGRRETSX3BOX("NP9_TIPLOT",(cAliNP9)->NP9_TIPLOT))},;
                    {'NP9_EMB',(AGRRETSX3BOX("NP9_EMB",(cAliNP9)->NP9_EMB))},{'B8_SALDO',nSaldoL},{'BF_QUANT',nSaldoBF}})
            EndIf
        EndIf
        AGRDBSELSKIP(cAliNP9)
    End

    // monta a estruta para index
    For nx := 1 To Len(aIndex)
        cIndice := aIndex[nx]
        cIndice := StrTran(cIndice," ","")
        cIndice := StrTran(cIndice,"Dtos(","")
        cIndice := StrTran(cIndice,"Descend(","")
        cIndice := StrTran(cIndice,")","")
        cDescIn := Space(1)
        vVetInT := {}
        While !Empty(cIndice)
            nPos := At("+",cIndice)
            cCam := If(nPos > 0,Alltrim(SubStr(cIndice,1,nPos-1)),Alltrim(SubStr(cIndice,1,Len(cIndice))))
            Aadd(vVetInT,cCam)
            cIndice := StrTran(cIndice,If(nPos > 0,cCam+"+",cCam),"")
        End
        cTamInd := 0
        For ny := 1 To Len(vVetInT)
            nPos1 := Ascan(aArqTemp,{|x| Alltrim(x[1]) == Alltrim(vVetInT[ny])})
            If nPos1 > 0
                cDescIn += Alltrim(aArqTemp[nPos1,5])+If(ny < len(vVetInT)," + ","")
                cTamInd += aArqTemp[nPos1,3]
            EndIf
        Next ny
        Aadd(aSeek,{cDescIn,{{"","C",cTamInd,0,' ',,}}})
    Next nx

    DEFINE MSDIALOG oDlgX TITLE STR0023 FROM 00,00 TO 500,1000 PIXEL OF oMainWnd //Consulta de lote de semente
    DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
    // Instancia o layer
    oFWL1 := FWLayer():New()
    // Inicia o Layer
    oFWL1:init( oDlgX,.F.)
    // Cria uma linha unica para o Layer
    oFWL1:addLine( 'SUP', 10 , .F.)
    oFWL1:addLine( 'INF', 90 , .F.)
    // Cria colunas
    oFWL1:addCollumn('ESQ',100,.T.,'SUP' )
    oPnlLine1 := oFWL1:getLinePanel('INF')
    oPnDir    := oFWL1:getColPanel('ESQ','SUP')

    @ 004,010 SAY SM0->M0_CODIGO+"/"+FWCodFil()+" - "+SM0->M0_FILIAL+"/"+SM0->M0_NOME  Of oPnDir PIXEL SIZE 245,009
    @ 014,010 SAY Alltrim(cCod)+ " - "+ POSICIONE("SB1", 1, xFilial("SB1") + cCod, "B1_DESC") Of oPnDir PIXEL SIZE 245,009 FONT oBold

    For nx := 1 To Len(aArqTemp)
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[nx]:SetData(&("{||"+aArqTemp[nx,1]+"}"))
        aColumns[nx]:SetTitle	( Alltrim(aArqTemp[nx,5]))
        aColumns[nx]:SetPicture(Alltrim(aArqTemp[nx,6]))
        aColumns[nx]:SetType(Alltrim(aArqTemp[nx,2]))
        aColumns[nx]:SetSize(aArqTemp[nx,3])
        aColumns[nx]:SetReadVar(aArqTemp[nx,1])
    Next nx

    DEFINE FWFORMBROWSE oBrowsX DATA TABLE ALIAS cAliTRBL OF oPnlLine1
    oBrowsX:SetTemporary(.T.)
    oBrowsX:SetFieldFilter(AGRITEMCBRW(aArqTemp))
    oBrowsX:SetColumns(aColumns)
    oBrowsX:SetDBFFilter(.T.)
    oBrowsX:SetUseFilter(.T.)
    oBrowsX:DisableDetails(.F.)
    oBrowsX:SetSeek(,aSeek)
    oBrowsX:SetDoubleClick(&('{||AGRA900DUP()}'))
    oBrowsX:AddButton("Sair",{|| oDlgX:end()},,9,0)
    ACTIVATE FWFORMBROWSE oBrowsX
    ACTIVATE MSDIALOG oDlgX CENTER

    AGRDELETRB(cAliTRBL,cNomeTRB)
    ARGCLOSEAREA(cAliNP9)
    DbSelectArea("NPN")
Return .T.

/*/{Protheus.doc} fQryLote
Função que monta a query com o filtro dos lotes para consulta de lote da ordem de carregamento
@type function
@version  P12
@author claudineia.reinert
@since 25/08/2021
@param cCod, character, codigo do produto
@param CodSaf, character, codigo da safra
@param cCultra, character, codigo da cultura
@param cCtvar, character, codigo da cultivar
@param cPene, character, codigo da penenira
@param cCateg, character, codigo da cayegoria
@param cLocal, character, codigo do local de armazem
@return variant, Retorna o alias com os dados da consulta
/*/
Static Function fQryLote(cCod, CodSaf, cCultra, cCtvar, cPene, cCateg, cLocal, cLote)
    Local cAliasLote    := GetNextAlias()
    Local cQuery        := ""
    Local cRetQuery     := ""
    Default cLote       := ""

    cQuery := " AND NP9_PROD ='"+cCod+"' AND NP9_CODSAF ='"+CodSaf+"' "
    cQuery += if(!empty(cCultra), "	AND NP9_CULTRA='"+cCultra+"' ","")
    cQuery += if(!empty(cCtvar), "	AND NP9_CTVAR='"+cCtvar+"' ","")
    cQuery += if(!empty(cPene), "	AND NP9_PENE 	='"+cPene+"' ","")
    cQuery += if(!empty(cCateg),"	AND NP9_CATEG='"+cCateg+"' ","")
    cQuery += if(!empty(cLocal),"	AND B8_LOCAL='"+cLocal+"' ","")
    cQuery += " AND NP9_STATUS  = '2'"

    //ponto de entrada para manipular query 
    If ExistBlock("AGR900P7")
        cRetQuery := ExecBlock("AGR900P7",.F.,.F.,{cQuery})
        If ValType(cRetQuery) == "C"
            cQuery := cRetQuery
        EndIf
    EndIf

    If FWIsInCallStack( "VldLoteNPN") .and. !Empty(cLote)
        //só acrescenta o filtro do lote quando validação do campo, para usar mesma consulta do filtro F4
        cQuery := " AND NP9_LOTE = '"+cLote+"' " + cQuery
    EndIF

    If Empty(cQuery)
        cQuery := "%%"
    Else
        cQuery := "% " + cQuery + " %"
    Endif

    BeginSQL Alias cAliasLote
		COLUMN B8_DTVALID AS DATE
		SELECT NP9.NP9_PROD,NP9.NP9_LOTE,NP9.NP9_TRATO,	NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_2UM,	NP9.NP9_CULTRA,
		NP9.NP9_CTVAR,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SBF.BF_LOCALIZ,SB8.B8_LOCAL,SBF.BF_NUMLOTE
		FROM %Table:SB8% SB8
		INNER JOIN %table:NP9% NP9 ON NP9.%notDel%
		AND NP9.NP9_FILIAL = %xFilial:NP9%  AND  NP9.NP9_LOTE = SB8.B8_LOTECTL AND NP9.NP9_PROD = SB8.B8_PRODUTO
		LEFT JOIN %table:SBF% SBF ON
		SBF.%notDel%							AND
		SBF.BF_FILIAL = %xFilial:SBF%	AND SBF.BF_LOCAL = SB8.B8_LOCAL AND SBF.BF_PRODUTO	= %exp:cCod%	AND SBF.BF_LOTECTL = NP9.NP9_LOTE
		WHERE
		SB8.B8_FILIAL=%xFilial:SB8%    %exp:cQuery%  AND  SB8.%NotDel%
    EndSQL

    //Carrega os dados para o arquivo temporario
    ARGSETIFARQUI(cAliasLote)

Return cAliasLote

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900DUP
Função double-click do browse de pesquisa do lote
@author: Inácio Luiz Kolling
@since: 08/06/2015
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900DUP()
    Local oModel   := FWModelActive()
    Local oGridNPN := oModel:GetModel("MdGridNPN")
    Local oView	   := FWViewActive()

    oGridNPN:SetNoUpdateLine( .F. )
    If !empty((cAliTRBL)->NP9_LOTE )
        M->NPN_LOTE := (cAliTRBL)->NP9_LOTE
        AGRLOADVALUE(oGridNPN,{{"NPN_LOCALI",(cAliTRBL)->BF_LOCALIZ},{"NPN_CULTRA",(cAliTRBL)->NP9_CULTRA},{"NPN_CTVAR",(cAliTRBL)->NP9_CTVAR},;
            {"NPN_CATEG",(cAliTRBL)->NP9_CATEG},{"NPN_PENE",(cAliTRBL)->NP9_PENE},{"NPN_LOCAL" ,(cAliTRBL)->B8_LOCAL}})
        oView:Refresh()
    Endif
    oDlgX:end()
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900CONH
Prepara e ou imprime os documentos conhecimento
@author: Inácio Luiz Kolling
@since: 19/06/2015
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900CONH()
    Local aArea := GetArea(),lTemCon := .f.

    If !Empty(MV_PAR01) .And. MV_PAR01 = 1
        If AGRIFDBSEEK("NPH",NPM->NPM_CODIGO,3,.f.)
            AGRIFDBSEEK("ADA",NPH->NPH_NUMCP,1,.f.)
            If AGRIFDBSEEK("NPN",NPM->NPM_CODIGO,1,.f.)
                While !Eof() .and. NPN->NPN_FILIAL = xFilial("NPN") .and. NPN->NPN_ORDEMC = NPM->NPM_CODIGO
                    If !Empty(NPN->NPN_LOTE)
                        If AGRIFDBSEEK("NP9",ADA->ADA_CODSAF+NPN->NPN_CODPRO+NPN->NPN_LOTE,1,.f.)
                            cChaveLP := AGRDOCLOTPAI(NP9->NP9_CODSAF,NP9->NP9_PROD,NP9->NP9_LOTE)
                            If !Empty(cChaveLP)
                                lTemCon := AGRIMPDOCON("NP9"+NP9->NP9_FILIAL+NP9->NP9_FILIAL+cChaveLP)
                            EndIf
                        EndIf
                    EndIf
                    AGRDBSELSKIP("NPN")
                End
            Endif
        EndIf
    Else
        lTemCon := AGRIMPDOCON("NPM"+NPM->NPM_FILIAL+NPM->NPM_FILIAL+NPM->NPM_CODIGO)
    EndIf
    If !lTemCon
        Help(" ",1,"AGRA900ND",,CHR(13)+STR0062,3,0) //não existe documento de analise para o carregamento do lote
    EndIf
    RestArea(aArea)
Return .T.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidNPH
Validação para a leitura de campos
@author: Inácio Luiz Kolling
@since: 24/06/2015
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function ValidNPH(cCampo)
Return IIf(Empty(AGRSEEKDIC("NPH",xfilial("NPH")+FwFldGet("NPH_CODAC")+FwFldGet("NPH_ITEM"),1,cCampo)),.t.,.f.)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900DPV
Emerson exclusao do PV
@author: EC
@since: 01/04/2015
@Uso: AGRADPV
/*/
// -------------------------------------------------------------------------------------
Function AGRA900DPV(cAlias, nReg, nAcao )
    // Salvando Areas //
    Local aAreaATU	:=  GetArea()
    Local aAreaNPG	:=  NPG->(GetArea())
    Local aAreaNPH	:=  NPH->(GetArea())
    Local aAreaNPM	:=  NPM->(GetArea())
    Local aAreaNPN	:=  NPN->(GetArea())

    Local aCabORD	:= {}, aItensORD	:= {}
    Local cChavNPM	:= NPM->NPM_CODIGO+NPM->NPM_CODAC
    Local cCarrega	:= NPM->NPM_CODAC
    Local nSaveSx8  := GetSx8Len()
    Local lRet      := .T.

    // -- Vars. ExecAuto -- //
    Private lMsErroAuto := .F.,lMSHelpAuto := .T.

    AGRIFDBSEEK("NPH",NPM->NPM_CODAC,1,.F.)
    cContr := NPH->NPH_NUMCP
    cNumPV := NPM->NPM_NUMPV // Número do pedido de venda

    IF !Empty( NPM->(NPM_NFS +NPM_SERNFS) )
        Alert( STR0126 ) 	//#'Antes de Cancelar o Pedido de Vendas, Can/Exc. o documento fiscal.'
        Return()
    ElseIF Empty( cNumPV )
        Alert( STR0127 )	//#"Não há pedido de venda emitido para esta Ordem de Carregamento."
        Return()
    EndIF

    cNumPV := NPM->NPM_NUMPV // Número do pedido de venda

    BEGIN TRANSACTION
        If AGRIFDBSEEK("SC5",cNumPV,1,.F.)
            Aadd(aCabORD,{"C5_NUM",cNumPV,Nil})
            If AGRIFDBSEEK("SC6",cNumPV,1,.F.)
                While !Eof() .And. SC6->C6_FILIAL = Xfilial("SC6") .And. SC6->C6_NUM = cNumPV
                    Aadd(aItensORD,{})
                    Aadd(aTail(aItensORD),{"C6_NUM" ,SC6->C6_NUM	,Nil})
                    Aadd(aTail(aItensORD),{"C6_ITEM",SC6->C6_ITEM	,Nil})
                    DbSkip()
                EndDo
            EndIf
        EndIF

        If AGRIFDBSEEK("SC5",cNumPV,1,.F.)
            // Desfaz a liberação
            AGRTRAVAREG(,.F.)
            SC5->C5_LIBEROK := " "
            AGRDESTRAREG()
            AGRIFDBSEEK("SC6",cNumPV,1,.F.)
            While !Eof() .And. SC6->C6_FILIAL = Xfilial("SC6") .And. SC6->C6_NUM = cNumPV
                AGRIFDBSEEK("SC0",SC6->C6_RESERVA + SC6->C6_PRODUTO + SC6->C6_LOCAL ,1,.F.)
                If SC0->C0_QUANT = 0
                    AGRTRAVAREG("SC6",.F.)
                    AGRGRAVAREG("SC6",{{'C6_RESERVA',''},{'C6_QTDRESE',0}})
                    AGRDESTRAREG()
                    //recria reservas do produto para vinculo ao pedido
                    // RECRIAR RESERVA PARA ITEM
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³Pega um numero de reserva                                          ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    cReserva := GetSx8Num("SC0","C0_NUM")
                    While (GetSX8Len() > nSaveSx8)
                        ConfirmSx8()
                    End
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³Efetua a Reserva  ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    dbSelectArea("NPN")
                    dbSetOrder(3)
                    dbSeek(xFilial("NPN")+cNumPV+SC6->C6_ITEM)

                    DbSelectArea("SB2")
                    Dbsetorder(1)
                    DbSeek(xFilial("SB2")+NPN->NPN_CODPRO+NPN->NPN_LOCAL)

                    If ( !RecLock("SB2") .Or. SaldoMov() < NPN->NPN_QUANT )
                        Help(,, STR0029,, STR0138, 1, 0 )
                        lRet := .F.
                    Else
                        lRet := .T.
                    EndIf

                    If lRet
                        // de acordo com documento : https://tdn.totvs.com/display/public/PROT/A430Reserv a função a430Reserv apenas tem retorno Nil por isso retirado lRet
                        a430Reserv({1,"CL",SC6->C6_CLI,UsrRetName(__cUserId),xFilial('SC6')},cReserva,SC6->C6_PRODUTO,SC6->C6_LOCAL,SC6->C6_QTDVEN,{"",SC6->C6_LOTECTL,SC6->C6_LOCALIZ,""})

                        Reclock("NPN",.F.)
                        NPN->NPN_RESERV	:= cReserva
                        MsUnlock("NPN")
                    Endif
                Endif
                AGRDBSELSKIP("SC6")
            end
            MsAguarde({||MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabORD,aItensORD,5)},STR0037,STR0040) //"Aguarde..."###"Excluindo Pedido de Vendas..."
        EndIf

        If lMSErroAuto
            //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
            DisarmTransaction()
            lRet := .F.
            Break
        Else
            while ( AGRIFDBSEEK("NPN",cNumPV,3,.F.))
                If AGRIFDBSEEK("NPH",NPN->NPN_CODAC+NPN->NPN_ITEMAC,1,.F.)
                    AGRTRAVAREG(,.F.)
                    NPH->NPH_QTDDIS += NPN->NPN_QUANT
                    AGRDESTRAREG()
                EndIf
                AGRTRAVAREG("NPN",.F.)
                NPN->NPN_NUMPV 	:= ""
                NPN->NPN_ITEMPV	:= ""
                AGRDESTRAREG()
            EndDo

            If AGRIFDBSEEK("NPM",cChavNPM,1,.F.)   //Atualizando o Cabec. da Ordem de Carregamento
                AGRTRAVAREG(,.F.)
                AGRGRAVAREG("NPM",{{'NPM_NUMPV',""},{'NPM_STATUS','2'}})
                AGRDESTRAREG()
            EndIF
        EndIF
    END TRANSACTION()

    //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
    If !lRet
        MostraErro()
        Return
    EndIf

    // Atualiza o status da autorização
    AGRA900NPGS(cCarrega,NPM->NPM_CODIGO)
    // Atualiza o contrato
    AGRIFDBSEEK("ADA",cContr,1,.F.)
    Ft400StatCt()

    // Restaurando Areas //
    RestArea(aAreaAtu)
    RestArea(aAreaNPG)
    RestArea(aAreaNPH)
    RestArea(aAreaNPM)
    RestArea(aAreaNPN)
Return()

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900DNF
Rotina de Exclusão/Cancelamento de NF.
@author: Emerson Coelho
@since: 29/09/2015
@Uso: AGRA900
/*/
// -------------------------------------------------------------------------------------
Function AGRA900DNF(cAlias, nReg, nAcao )
    // Salvando Areas
    Local aAreaATU	:=  GetArea()
    Local aAreaNPG	:=  NPG->(GetArea())
    Local aAreaNPH	:=  NPH->(GetArea())
    Local aAreaNPM	:=  NPM->(GetArea())
    Local aAreaNPN	:=  NPN->(GetArea())
    Local aRegSD2	:= {},aRegSE1 := {},aRegSE2 := {}
    Local cChavNPM	:= NPM->NPM_CODIGO+NPM->NPM_CODAC
    Local cAutCarr	:= NPM->NPM_CODAC
    Local cCodCtrPar:= Criavar('ADA_NUMCTR',.F.)
    Local lContinua := .t.
    Local cModAtu   := cModulo
    Local nModAtu   := nModulo
    Local lRet      := .T.
    Local lAlerta   := .F.

    cNFS	:= NPM->NPM_NFS	// Número da Nota Fiscal
    cSERNFS	:= NPM->NPM_SERNFS 	// Série da Nota Fiscal

    //Encontro o Nr. do Contrato
    IF AGRIFDBSEEK("NPH",NPM->NPM_CODAC,1,.F.)
        cCodCtrPar 	:= NPH->NPH_NUMCP
    EndIF

    IF Empty( cNfs ) .and. Empty( cSernfs )
        Alert( STR0128 )	//#"Não há documento fiscal vinculado a essa ordem de carregamento."
        lContinua := .f.
        Return()
    EndIF

    nModulo := 5
    cModulo := "FAT"
    IF lContinua
        BEGIN TRANSACTION

            IF MsgYesNo( STR0130,STR0029) 	//#'Confirma o Exclusao do docto Fiscal?' # Aviso

                dbSelectArea('SF2')
                dbSetOrder(1)
                If dbSeek(xFilial('SF2')+cNFS+cSERNFS)
                    If !MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2,'MATA460') // Validação na exclusão da Nota Fiscal
                        //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
                        DisarmTransaction()
                        lRet := .F.
                        lAlerta := .T.
                        Break
                    Else
                        // Estorna o documento de saída e deixa o pedido de vendas em carteira
                        MsAguarde({||SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.T.))},STR0037,STR0038) //"Aguarde..."###"Estonarndo o documento de saída..."
                        SF2->( MsUnlock() )
                        lContinua := .t.
                    EndIF
                Endif
            Else
                //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
                DisarmTransaction()
                Break
            EndIF
            IF lContinua
                If AGRIFDBSEEK("NPM",cChavNPM,1,.F.)
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³Atualiza NPM      ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    Reclock("NPM",.F.)
                    NPM->NPM_NFS := ''
                    NPM->NPM_SERNFS := ''
                    MsUnlock()
                EndIF
            EndIF
        End TRANSACTION
    EndIF

    //Alterar a lógica do programa para que a transação não tenha nenhuma interrupção de interface - SONARQUBE
    If !lRet
        If lAlerta
            Alert( STR0131 )		//#"Não foi possivel excluir o docto. de saida."
        EndIf
        Return
    EndIf

    nModulo := nModAtu
    cModulo := cModAtu

    IF lContinua
        // Atualiza o status da autorização
        AGRA900NPGS(cAutCarr,NPM->NPM_CODIGO)
        // Atualiza o contrato
        AGRIFDBSEEK("ADA",cCodCtrPar,1,.F.)
        Ft400StatCt()
    EndIF

    // Restaurando Areas //
    RestArea(aAreaATU)
    RestArea(aAreaNPG)
    RestArea(aAreaNPH)
    RestArea(aAreaNPM)
    RestArea(aAreaNPN)
Return

// -------------------------------------------------------------------------------------
/*/ {Protheus.doc} FEmiteNF
Emite NFs. do Ubs. e Principalmente do Pedido de Troca
@param: 	cPedido ( Nr. do Pedido a Ser Emitido
@Return:	Array de dois elementos
aRet[1] = numero da nota fiscal emitida
aRet[2] = serie da nota fiscal emitida
@author: E.Coelho
@since: 21/05/2015
/*/
// -------------------------------------------------------------------------------------
Static function FEmiteNF( cPedido )
    Local aAreaATU		:= GetArea()
    Local aAreaSM2		:= SM2->( GetArea() )
    Local _nPrcVen,_nRegDAK,nX
    Local lEmitiuNf		:= .f.,lContinua := .t.,lOutraMoed	 := .f.
    Local aPvlNfs			:= {},aTexto 	:= {}
    Local cRot      	:= ProcName()
    Local cModAtu   	:= cModulo
    Local nModAtu   	:= nModulo
    Local dDataMoe		:= dDatabase
    Local cSerie			:= '',cNota :=''
    Local aBloqueio 	:= {{"","","","","","","",""}}
    Local cTpNrNfs  	:= SuperGetMV("MV_TPNRNFS")
    Local nTotDocOM     := 0   //Total Doc em Outra moeda

    Private lMudouNum := .F.
    Private cNumero   := ""
    Store 0 To _nPrcVen,_nRegDAK,nX

    SetFunName("MATA461")

    cModulo	:= 'FAT'
    nModulo := 5

    //--Posiciona no Pedido a Gerar o Doct Fiscal --
    AGRIFDBSEEK("SC5",cPedido,1,.F.)

    // Montagem da Interface
    aadd(aTexto,"")
    aTexto[1] := PadC(STR0046 + SC5->C5_NUM,160)+CRLF+CRLF //"Pedido de Venda: "
    aTexto[1] += STR0047 + CRLF + CRLF  //"O assistente identificou que o pedido de venda não possui itens liberados e irá realizar "
    aTexto[1] += STR0048  //"Favor liberar o Pedido de Venda.

    // Verifica se o usuario tem premissao para gerar   o ³
    If cPaisLoc <> "BRA" .AND. FieldPos("C5_CATPV") > 0 .AND. !Empty(SC5->C5_CATPV)
        If AliasIndic("AGS") //Tabela que relaciona usuario com os Tipos de Pedidos de vendas que ele tem acesso
            If AGRIFDBSEEK("AGS",__cUserId,1,.F.) //Se não encontrar o usuário na tabela, permite ele alterar o pedido
                If !AGRIFDBSEEK("AGS",__cUserId+ SC5->C5_CATPV,1,.F.) //Verifica se o usuario tem premissao
                    MsgStop(STR0075) //Este usuario não tem permissão para gerar documento de saida para pedidos de venda com esse tipo
                    lContinua := .F.
                EndIf
            EndIf
        EndIf
    EndIf

    If lContinua
        Ma410LbNfs(1,@aPvlNfs,@aBloqueio) // Verificando se o Pv. Possui Itens bloqueados

        IF Len( aPvLnfs ) == 0 .or. Len( aBloqueio ) > 0
            lContinua := .f.
            DEFINE WIZARD oWizard TITLE STR0049 HEADER STR0050 MESSAGE STR0051 TEXT aTexto[1] NEXT {|| oWizard:SetPanel(3),.T.}	FINISH {||.T.} //Assitente para preparação do documento de saida ###Atenção ###Inconsistencia na ordem de pagamento selecionada
            ACTIVATE WIZARD oWizard CENTERED ON INIT (oWizard:oNext:Disable(),oWizard:oNext:Hide(),oWizard:oFinish:Show(),oWizard:oFinish:Enable(),;
                oWizard:oCancel:Hide() )
        EndIF
    EndIF

    aPvLnfs :={}
    cSerie  := cNota := ''

    IF lContinua
        //Escolhendo a Serie da Nf.
        lContinua := Iif( Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS")), .t., .f.)
        // Verifica se o registro está travado para outra estação,pois, está ocorrendo problema na geração da NFE
        If AGRIFDICIONA("SX6",Xfilial("SX6")+"MV_NUMITEN",1,.f.)
            If !SoftLock("SX6")
                SX6->(MsRUnLock())
            EndIf
        EndIf
    EndIF

    IF lContinua
        Pergunte("MT460A",.F.)

        // Preparando p PV para  Gerar a Nf.
        If AGRIFDBSEEK('SC5',cPedido,1,.F.)
            lEhTroca 	:= .f.
            nVrMoedNeg	:= 0
            cNktTrcNum 	:= ''
            nTotDocOM	:= 0
            If AGRIFDBSEEK("SC6",cPedido,1,.F.)
                While !Eof() .And. SC6->C6_FILIAL+SC6->C6_NUM = Xfilial("SC6")+cPedido

                    //Verifica se é contrato de troca
                    IF !Empty(SC6->C6_CONTRAT) .and. ALIASINDIC("NKT")
                        IF ADA->(FieldPos('ADA_TRCNUM')) > 0
                            cNktTrcNum:= Posicione("ADA", 1, xFilial("ADA")+SC6->C6_CONTRAT, "ADA_TRCNUM")
                            If AGRIFDBSEEK("NKT",cNktTrcNum,1,.f.)
                                nVrMoedNeg	:= NKT->NKT_VRPAUT
                                nMoeda		:= SC5->C5_MOEDA
                                lEhTroca	:= .t.
                            EndIF
                        EndIF
                    EndIF

                    If AGRIFDBSEEK('SC9',SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_NUM+SC6->C6_ITEM,2,.F.)
                        // Posiciona na condicao de pagamento
                        AGRIFDBSEEK('SE4',SC5->C5_CONDPAG,1,.F.)
                        // Posiciona no produto
                        AGRIFDBSEEK('SB1',SC6->C6_PRODUTO,1,.F.)
                        // Posiciona no saldo em estoque
                        AGRIFDBSEEK('SB2',SC6->C6_PRODUTO+SC6->C6_LOCAL,1,.F.)
                        // Posiciona no TES
                        cTes := SC6->C6_TES
                        AGRIFDBSEEK('SF4',cTes,1,.F.)

                        // Converte o valor unitario em Reais quando pedido em outra moeda
                        _nPrcVen := SC9->C9_PRCVEN
                        If (SC5->C5_MOEDA!=1)
                            _nPrcVen := xMoeda(_nPrcVen,SC5->C5_MOEDA,1,dDataMoe)
                            lOutraMoed := .t.
                        EndIf

                        // Monta array para gerar a nota fiscal
                        Aadd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,_nPrcVen,	SC9->C9_PRODUTO,;
                            .F.,SC9->(RecNo()),SC5->(RecNo()),SC6->(RecNo()),	SE4->(RecNo()),SB1->(RecNo()),SB2->(RecNo()),;
                            SF4->(RecNo()),SC6->C6_LOCAL,_nRegDAK,	SC9->C9_QTDLIB2})

                        nTotDocOM += a410Arred( SC9->C9_PRCVEN * SC9->C9_QTDLIB,"C6_VALOR")

                    EndIf
                    SC6->( DBSkip() )
                EndDo
            Else
                Aviso(cRot,STR0046+Trim(cPedido)+" "+STR0076,{STR0054}) //Pedido de venda ###sem itens ###Abandonar
                lConTiua :=.f.
            EndIf
        Else
            Aviso(cRot,STR0046+" "+STR0055,{STR0054}) //Pedido de venda ###não localizado ###Abandonar
            lContinua := .f.
        EndIf

        IF lContinua 	// Tudo ok Para emitir a NF,
            DbSelectArea('SM2')
            SM2->(DbSetorder(1)) //M2_MOEDA
            IF lEhTroca  	// O pedido e é um Pv. de Troca e esta em Outra Moeda , Verifica se existe uma Taxa na Data;
                If !SM2->(DBSEEK(DtoS(dDataBase))) .or. xMoeda( 1, ADA->ADA_MOEDA, 1, dDataBase, TamSX3("M2_MOEDA2")[2] ) == 0
                    Aviso(cRot,STR0052+" "+trim(cPedido)+" "+STR0056,{STR0054})  //###Procname()###"Pedido"####"é um pedido de Troca. Favor antes de prosseguir Cadastrar a Taxa da Moeda de Troca para a data de Hoje." #"&Abandonar"
                    lContinua := .f.
                EndIF
            ElseIF lOutraMoed // Pedido é em outra Moeda e não Possui taxa Cadastrada Para a Moeda
                IF !SM2->(DBSEEK(DtoS(dDataBase))) .or.  xMoeda( 1, ADA->ADA_MOEDA, 1, dDataBase, TamSX3("M2_MOEDA2")[2] ) == 0 //Se não encontrou Taxa Cadastrada na Data
                    //Atenção a Xmoeda irah encontrar a Taxa mais proxima da mais atual para menos aatul o por isso do Dbseek
                    Aviso(cRot,STR0052+" "+trim(cPedido)+" "+STR0132,{STR0054})  //#"Pedido" + #"é um pedido em Outra Moeda. Favor antes de prosseguir Cadastrar a Taxa da Moeda para a data de Hoje." #"&Abandonar"
                    lContinua := .f.
                EndIF
            EndIF
        EndIF

        //-- Inicio Emitindo NF --//
        IF lContinua
            If !Empty(aPvlNfs)

                IF lEhTroca		// Verifica se é contrato de troca
                    // -- Vars Utilizada durante a emissao da nf. de Trocas, no MATA461, na Função MaPvPrcIt() ,
                    // -- Para conversão da Moeda pela Taxa negociada do Trocas
                    Private lOGNFTRC 	:= .t.
                    Private nTRCTotMER	:= 	0
                    Private nOgTxTroca	:=  nVrMoedNeg
                    Private nTRCTotDoc	:=  A410ARRED( nTotDocOM * nOgTxTroca, 'D2_TOTAL' )
                    Private cDocUltIt	:=  aPvlNfs[len(aPvlnfs), 1 ] + aPvlNfs[len(aPvlnfs), 2 ]  //Identifica o ultimo item que compoe a NF ( SC9->C9_PEDIDO,SC9->C9_ITEM )
                    // --------------------------------------------------------------------------------------
                EndIF

                IF lContinua
                    // -- Esse foi um ajuste que fiz na Sem.Goias (Eles usam SD9), pq a conexão deles estava caindo e deixando o parametro bloqueado --
                    If cTpNrNfs == "3" .and. !lMudouNum = .t. 		//Controle pela SD9 e o nr. não foi mudado na tela
                        lMudouNum 		:= .T.    	// Força a Chamar a funcao Ma461NumNF  e nao chamar a NXTSX5NOTA na função MAPVLNFS, ( Razao stavamos com
                        // DEADLOCK frequente  no mv_numiten. mesmo criando o mv_numiten por filial , na Sem. Goias e
                        // como utilizam a SD9 fizemos essa solução de contorno)
                        cNumero		:= CriaVar("F2_DOC", .f.)
                    EndIF

                    // Emite Docto Fiscal
                    cNota := ''
                    MsAguarde({|| cNota := MaPvlNfs(aPvlNfs	,cSerie,MV_PAR01 = 1,MV_PAR02 = 1,MV_PAR03 = 1,MV_PAR04 = 1,MV_PAR05 = 1,;
                        MV_PAR07,MV_PAR08	,MV_PAR15 = 1,MV_PAR16 = 2,,,,,,dDataMoe)},STR0037,STR0058) //"Aguarde..."###"Gerando pedido de vendas..."
                EndIF
                lEmitiuNF := IIF(!Empty(cNota),.t.,.f.)
            EndIF
        EndIF
        SX5->(MsRUnlock())
    EndIF
    cModulo := cModAtu
    nModulo := nModAtu
    RestArea(aAreaATU)
    RestArea(aAreaSM2)
Return (lEmitiuNF)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900NPGS
//Atualiza o status da autorização e ordem de carregamento
@author  Inácio Luiz Kolling
@since 10/07/2015
@version undefined
@type function
@param cChavNPH - Código da autorização   |   Obrigatório
/*/
// -------------------------------------------------------------------------------------
Function AGRA900NPGS(cChavNPH,cVordem)
    Local cStatAu  := " ",cStatOr := " ",lSair := .f.,lTemNPN, lAtend := .T.
    Local cChavNPM := NPM->NPM_CODIGO + NPM->NPM_CODAC
    Local cOrdem	  := If(cVordem = Nil,FwFldGet("NPM_CODIGO"),cVOrdem)
    Local nTotH    := 0,	nTotN := 0,nIteH := 0, nSoma := 0

    // Aplicação da regra passada pela SG
    // Verifica se está aguardando carregamento.
    If AGRIFDBSEEK("NPH",cChavNPH,1,.F.)
        Store .f. To lSair,lTemNPN
        While !Eof() .And. NPH->NPH_FILIAL = Xfilial("NPH") .And. NPH->NPH_CODAC = cChavNPH .And. !lSair
            If !Empty(NPH->NPH_LOCAL)
                lSair := .t.
                Exit
            Endif
            If !lSair
                AGRIFDBSEEK("NPN",cOrdem,1,.F.)
                While !Eof() .And. NPN->NPN_FILIAL = Xfilial("NPN") .And. NPN->NPN_ORDEMC = cOrdem
                    If NPN->NPN_ITEMAC = NPH->NPH_ITEM
                        If !Empty(NPN->NPN_LOCAL) .And. (!Empty(NPN->NPN_QUANT) .Or. !Empty(NPN->NPN_LOTE))
                            lTemNPN := .t.
                            Exit
                        Endif
                    EndIf
                    AGRDBSELSKIP("NPN")
                End
            EndIf
            AGRDBSELSKIP("NPH")
        End

        If !lSair .And. !lTemNPN
            cStatAu := "9"	//Agd Carregamento
            cStatOr := "6"	//Agd Carregamento
        EndIf
    EndIf

    If Empty(cStatAu)
        // Verifica se está em pedido..todas as ordens da autorização for igual a quantidade dos itens das ordens de carregamento sem NFs
        If AGRIFDBSEEK("NPH",cChavNPH,1,.F.)
            While !Eof() .And. NPH->NPH_FILIAL = Xfilial("NPH") .And. NPH->NPH_CODAC = cChavNPH
                If AGRIFDBSEEK("NPN",cOrdem,1,.F.)
                    While !Eof() .And. NPN->NPN_FILIAL = Xfilial("NPN") .And. NPN->NPN_ORDEMC = cOrdem
                        If NPN->NPN_ITEMAC = NPH->NPH_ITEM
                            //SOMA ATENDIDOS
                            nSoma += NPN->NPN_QUANT
                        EndIf
                        AGRDBSELSKIP("NPN")
                    End
                    If (nSoma <> NPH->NPH_QUANT)
                        lAtend := .F.
                    Endif
                EndIf
                AGRDBSELSKIP("NPH")
                nSoma := 0
            End
            If AGRIFDBSEEK("NPM",cOrdem+cChavNPH,1,.F.) .And. !Empty(NPM->NPM_NUMPV) .And. Empty(NPM->NPM_NFS) .and. lAtend
                cStatAu := "6"	//Em Pedido de Venda
                cStatOr := "3"	//Em Pedido de Venda
            ElseIf AGRIFDBSEEK("NPM",cOrdem+cChavNPH,1,.F.) .And. !Empty(NPM->NPM_NUMPV) .And. Empty(NPM->NPM_NFS) .and. !lAtend
                cStatAu := "8"	//Parc. Atendida
                cStatOr := "3"	//Em Pedido de Venda
            ElseIf AGRIFDBSEEK("NPM",cOrdem+cChavNPH,1,.F.) .And. !Empty(NPM->NPM_NUMPV) .And. !Empty(NPM->NPM_NFS) .and. !lAtend
                cStatAu := "8"	//Parc. Atendida
                cStatOr := "4"	//Finalizada
            ElseIf AGRIFDBSEEK("NPM",cOrdem+cChavNPH,1,.F.) .And. !Empty(NPM->NPM_NUMPV) .And. !Empty(NPM->NPM_NFS) .and. lAtend
                cStatAu := "7"	//Finalizada
                cStatOr := "4"	//Finalizada
            EndIf

        EndIf
    EndIf

    If Empty(cStatAu)
        // Verifica se está carregada, e se todos os itens da autorização forem iguais a quantidade dos itens da ordem de carregamento
        If AGRIFDBSEEK("NPH",cChavNPH,1,.F.)
            While !Eof() .And. NPH->NPH_FILIAL = Xfilial("NPH") .And. NPH->NPH_CODAC = cChavNPH
                nTotH += NPH->NPH_QUANT
                nIteH ++
                If AGRIFDBSEEK("NPN",cOrdem,1,.F.)
                    nQtdN := 0
                    While !Eof() .And. NPN->NPN_FILIAL = Xfilial("NPN") .And. NPN->NPN_ORDEMC = cOrdem
                        If NPN->NPN_ITEMAC = NPH->NPH_ITEM
                            If !Empty(NPN->NPN_QUANT) .And. Empty(NPN->NPN_NUMPV)
                                nQtdN += NPN->NPN_QUANT
                                cStatOr := "2"	//Carregada
                            EndIf
                        Endif
                        AGRDBSELSKIP("NPN")
                    End
                    nTotN += nQtdN
                EndIf
                AGRDBSELSKIP("NPH")
            End
            If !Empty(cStatOr)
                cStatAu := If(nTotH = nTotN,"5","8")	// Carregada ou Parc. Atendida
            EndIf
        EndIf
    EndIf

    If Empty(cStatAu)
        If AGRIFDBSEEK("NPH",cChavNPH,1,.F.)
            // Verifica se está em carregamento..todas as ordens da autorização sem itens de carregamento
            lSair := .T.
            While !Eof() .And. NPH->NPH_FILIAL = Xfilial("NPH") .And. NPH->NPH_CODAC = cChavNPH .And. !lSair
                If !Empty(NPH->NPH_LOCAL)
                    If AGRIFDBSEEK("NPN",cOrdem,1,.F.)
                        While !Eof() .And. NPN->NPN_FILIAL = Xfilial("NPN") .And. NPN->NPN_ORDEMC = cOrdem
                            If NPN->NPN_ITEMAC = NPH->NPH_ITEM .And. lSair
                                If !Empty(NPN->NPN_LOCAL)
                                    If !Empty(NPN->NPN_QUANT) .Or. !Empty(NPN->NPN_LOTE)
                                        lSair := .f.
                                    EndIf
                                EndIf
                            EndIf
                            AGRDBSELSKIP("NPN")
                        End
                    EndIf
                EndIf
                AGRDBSELSKIP("NPH")
            End
            If lSair
                cStatAu := "4"	//Em Carregamento
                cStatOr := "1"	//Em Carregamento
            EndIf
        EndIf
    EndIf
    //Grava os Status
    If !Empty(cStatAu)
        AGRALTCAMBA("NPG",cChavNPH,1,"NPG_STATUS",cStatAu)
        AGRALTCAMBA("NPM",cChavNPM,1,"NPM_STATUS",cStatOr)
    EndIf

Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900IMP
//Impressão da ordem de carregamento
@author  Inácio Luiz Kolling
@since 04/08/2015
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Function AGRA900IMP()
    Private oPrint
    oFont11  := TFont():New( "Arial" ,,11,,.f.,,,,,.f. )
    oFont11N := TFont():New( "Arial" ,,11,,.t.,,,,,.f. )
    oFont14  := TFont():New( "Arial" ,,14,,.f.,,,,,.f. )
    oFont14N := TFont():New( "Arial" ,,14,,.t.,,,,,.f. )

    oPrint  := TMSPrinter():New(OemToAnsi(STR0082)) //Impressora
    limpbol := oPrint:Setup()

    If !limpbol
        Return
    Endif
    oPrint:SetPortrait()
    oPrint:SetPaperSize(9)
    AGRA900IPRC()
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900IPRC
//Processa e imprime a ordem de carregamento
@author  Inácio Luiz Kolling
@since 04/08/2015
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA900IPRC()
    Local aMatNPN := {},lTemNPH := .f.,lTemNPN := .f.,nx
    Private nLin  := 20,nPag := 1

    oPrint:EndPage()
    oPrint:StartPage()

    oPrint:Say(nLin,450 ,STR0083                                                         ,oFont14N,100) //ORDEM DE CARREGAMENTO Nº
    oPrint:Say(nLin,1300,NPM->NPM_CODIGO+" - "+AGRRETSX3BOX("NPM_STATUS",NPM->NPM_STATUS),oFont14 ,100)

    oPrint:Say(nLin,2100,STR0084                 ,oFont11N,100) //Pagina
    oPrint:Say(nLin,2250,TransForm(npag,"@E 999"),oFont11 ,100)

    nLin += 90
    oPrint:Say(nLin,80,STR0085        ,oFont11N,100) //Autorização:
    oPrint:Say(nLin,350,NPM->NPM_CODAC,oFont11,100)

    AGRIFDBSEEK("NPH",NPM->NPM_CODIGO,3,.F.)
    nLin += 60
    oPrint:Say(nLin,135,STR0086                           ,oFont11N,100) //Contrato:
    oPrint:Say(nLin,350,NPH->NPH_NUMCP                    ,oFont11 ,100)
    oPrint:Say(nLin,1000,STR0052                          ,oFont11N,100) //Pedido
    oPrint:Say(nLin,1200,NPM->NPM_NUMPV                   ,oFont11 ,100)
    oPrint:Say(nLin,1750,STR0034                          ,oFont11N,100) //nota fiscal
    oPrint:Say(nLin,2000,NPM->NPM_NFS+"  "+NPM->NPM_SERNFS,oFont11 ,100)

    AGRIFDBSEEK("NPG",NPM->NPM_CODAC,1,.F.)
    AGRIFDBSEEK("SA1",NPG->NPG_CLIORI,1,.F.)

    nLin += 60
    oPrint:Say(nLin,165,STR0089                                                         ,oFont11N,100) //Cliente:
    oPrint:Say(nLin,350,Alltrim(NPG->NPG_CLIORI)+"  "+NPG->NPG_LOJORI+"   "+SA1->A1_NOME,oFont11 ,100)

    AGRIFDBSEEK("SA4",NPG->NPG_TRANSP,1,.F.)
    nLin += 60
    oPrint:Say(nLin,005,STR0090                                   ,oFont11N,100) //Transportadora:
    oPrint:Say(nLin,350,Alltrim(NPG->NPG_TRANSP)+"  "+SA4->A4_NOME,oFont11 ,100)

    AGRIFDBSEEK("DA4",NPG->NPG_MOTO,1,.F.)
    nLin += 60
    oPrint:Say(nLin,120,STR0091                                  ,oFont11N,100) //Motorista:
    oPrint:Say(nLin,350,Alltrim(NPG->NPG_MOTO)+"  "+DA4->DA4_NOME,oFont11 ,100)

    AGRIFDBSEEK("DA3",NPG->NPG_PLACA,1,.F.)
    nLin += 60
    oPrint:Say(nLin,195 ,STR0092                                     ,oFont11N,100) //Placa:
    oPrint:Say(nLin,350 ,NPG->NPG_PLACA                              ,oFont11,100)
    oPrint:Say(nLin,1750,STR0093                                     ,oFont11N,100) //Capacidade:
    oPrint:Say(nLin,2000,TransForm(DA3->DA3_CAPACM,"@E 9,999,999.99"),oFont11,100)

    nLin += 60
    oPrint:Box(nLin,10,nLin,2300)

    nLin += 40
    oPrint:Say(nLin,1000,STR0094,oFont14N,100) //PRODUTOS

    AGRA900ISEP(70,1) //60

    nLin += 10
    oPrint:Say(nLin,20  ,STR0087,oFont11N,100) //Item
    oPrint:Say(nLin,120 ,STR0088,oFont11N,100) //Cliente:
    oPrint:Say(nLin,470 ,STR0096,oFont11N,100) //Descrição
    oPrint:Say(nLin,1220,STR0097,oFont11N,100) //Cultivar
    oPrint:Say(nLin,1465,STR0098,oFont11N,100) //CAt.
    oPrint:Say(nLin,1560,STR0099,oFont11N,100) //Pen.
    oPrint:Say(nLin,1670,STR0100,oFont11N,100) //Local
    oPrint:Say(nLin,2000,STR0101,oFont11N,100) //Quantidade
    oPrint:Say(nLin,2235,STR0102,oFont11N,100) //Un.

    DbSelectArea("NPH")
    While !Eof() .And. NPH->NPH_FILIAL = Xfilial("NPH") .And. NPH->NPH_ORDEMC = NPM->NPM_CODIGO
        lTemNPH := .T.
        If nLin > 2200
            AGRA900NPAG()
        EndIf

        AGRA900ISEP(60,1)

        AGRIFDBSEEK("SB1",NPH->NPH_CODPRO,1,.F.)
        AGRIFDBSEEK("NNR",NPH->NPH_LOCAL,1,.F.)

        oPrint:Say(nLin,30  ,NPH->NPH_ITEM            							     ,oFont11,100)
        oPrint:Say(nLin,120 ,NPH->NPH_CODPRO         							     ,oFont11,100)
        oPrint:Say(nLin,470 ,SubStr(SB1->B1_DESC,1,30)							     ,oFont11,100)
        oPrint:Say(nLin,1220,NPH->NPH_CTVAR         								     ,oFont11,100)
        oPrint:Say(nLin,1465,NPH->NPH_CATEG         								     ,oFont11,100)
        oPrint:Say(nLin,1560,NPH->NPH_PENE           							     ,oFont11,100)
        oPrint:Say(nLin,1670,NPH->NPH_LOCAL+"-"+SubStr(NNR->NNR_DESCRI,1,11),oFont11,100)
        oPrint:Say(nLin,2025,TransForm(NPH->NPH_QUANT,"@E 9,999,999.99")    ,oFont11,100)
        oPrint:Say(nLin,2235,SB1->B1_UM															,oFont11,100)

        If AGRIFDBSEEK("NPN",NPH->NPH_CODAC+NPH->NPH_ITEM,2,.F.)
            While !Eof() .And. NPN->NPN_FILIAL = Xfilial("NPN") .And. NPN->NPN_CODAC = NPH->NPH_CODAC .And. NPN->NPN_ITEMAC = NPH->NPH_ITEM
                If !Empty(NPN->NPN_QUANT) .And. NPN->NPN_ORDEMC = NPH->NPH_ORDEMC
                    lTemNPN := .T.
                    Aadd(aMatNPN,{NPN->NPN_CODPRO,NPN->NPN_ITEMAC,NPN->NPN_LOCAL,NPN->NPN_LOCALI,NPN->NPN_LOTE,NPN->NPN_QUANT})
                EndIf
                AGRDBSELSKIP("NPN")
            End
        EndIf
        AGRDBSELSKIP("NPH")
    End

    If lTemNPH
        nLin += 60
        oPrint:Box(nLin,10,nLin,2300)
    EndIf

    If lTemNPN
        nLin += 80
        If nLin > 2200
            AGRA900NPAG()
        EndIf

        oPrint:Say(nLin,1050,STR0103,oFont14N,100) //LOTES

        AGRA900ISEP(70)

        nLin += 10
        oPrint:Say(nLin,20  ,STR0087,oFont11N,100) //item
        oPrint:Say(nLin,120 ,STR0100,oFont11N,100) //Local
        oPrint:Say(nLin,470 ,STR0104,oFont11N,100) //Endereço
        oPrint:Say(nLin,1220,STR0105,oFont11N,100) //Lote
        oPrint:Say(nLin,2000,STR0101,oFont11N,100) //Quantidade
        oPrint:Say(nLin,2235,STR0102,oFont11N,100) //Un.

        For nx := 1 To Len(aMatNPN)
            If nLin > 2200
                AGRA900NPAG()
            EndIf
            AGRA900ISEP(60)

            AGRIFDBSEEK("SB1",aMatNPN[nx,1],1,.F.)
            oPrint:Say(nLin,30  ,aMatNPN[nx,2]            							,oFont11,100)
            oPrint:Say(nLin,120 ,aMatNPN[nx,3]												,oFont11,100)
            oPrint:Say(nLin,470 ,aMatNPN[nx,4]							             ,oFont11,100)
            oPrint:Say(nLin,1220,aMatNPN[nx,5]                             ,oFont11,100)
            oPrint:Say(nLin,2025,TransForm(aMatNPN[nx,6],"@E 9,999,999.99"),oFont11,100)
            oPrint:Say(nLin,2235,SB1->B1_UM													,oFont11,100)
        Next nx
        nLin += 60
        oPrint:Box(nLin,10,nLin,2300)
    EndIf

    oPrint:EndPage()
    RetIndex('NPM')
    Set Filter To
    oPrint:Preview()
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900NPAG
//Controle de página
@author  Inácio Luiz Kolling
@since 04/08/2015
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA900NPAG()
    nLin := 10
    nPag ++
    oPrint:EndPage()
    oPrint:StartPage()
    oPrint:Say(nLin,2100,STR0084                 ,oFont11N,100) //Pagina
    oPrint:Say(nLin,2250,TransForm(npag,"@E 999"),oFont11 ,100)
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900ISEP
//Imprime separador de itens
@author  Inácio Luiz Kolling
@since 04/08/2015
@version undefined
@type function
@param nSoma - Quantidade de linhas a somar  |   Obrigatório
nNum  - Contralador de grade          |   Não Obrigat
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA900ISEP(nSoma,nNum)
    nLin += nSoma
    oPrint:Box(nLin,10  ,nLin      ,2300)
    oPrint:Box(nLin,10  ,nLin+nSoma,10)
    oPrint:Box(nLin,115 ,nLin+nSoma,115)
    oPrint:Box(nLin,460 ,nLin+nSoma,460)
    oPrint:Box(nLin,1210,nLin+nSoma,1210)

    If nNum <> Nil
        oPrint:Box(nLin,1450,nLin+nSoma,1450)
        oPrint:Box(nLin,1550,nLin+nSoma,1550)
        oPrint:Box(nLin,1655,nLin+nSoma,1655)
    EndIf
    oPrint:Box(nLin,1945,nLin+nSoma,1945)
    oPrint:Box(nLin,2230,nLin+nSoma,2230)
    oPrint:Box(nLin,2300,nLin+nSoma,2300)
Return

// -------------------------------------------------------------------------------------
/*{Protheus.doc}
Validação Para o Grid Ganhar o Focus a GridNPH só deverá Ganhar o Foco se estiver pelo menso uma linha no Grid NPH
@author  Emerson coelho
@version P11 R7
@Since   26/06/15
/*/
// -------------------------------------------------------------------------------------
Static Function fNPNGotFoc(oModel,oView)
    IF ( Empty(FwFldGet("NPM_CODAC") ) )
        Help(,, STR0029,,STR0110 , 1, 0 ) //#Aviso#Favor Informar autorização de Carregamento.
        oView:GetViewObj("VwFieldNPM")[3]:GetFWEditCTRL("NPM_CODAC"):OCtrl:OGet:SetFocus()
        Return .f.
    EndIF
Return .t.

// -------------------------------------------------------------------------------------
/** {Protheus.doc} TudoOk
Função que valida o modelo de dados após a confirmação
@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Emersnon
@since: 	26/09/15
*/
// -------------------------------------------------------------------------------------
Static Function TudoOk( oModel )
    Local nQtNPN		 := 0,nQtNPH := 0,nI := 0,nX := 0
    Local lRetorno	 := .t.
    Local oGridNPH	 := oModel:GetModel( "MdGridNPH"  )
    Local oGridNPN	 := oModel:GetModel( "MdGridNPN"  )
    Local nOperation := oModel:GetOperation()
    Local aSaveLines := FWSaveRows()

    IF nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
        nLinha := oGridNPH:GetQtdLine()
        For nX := 1 To oGridNPH:Length()
            oGridNPH:GoLine(nX)   // No Grid NPH não é possivel deletar a Linha ( Nao Testo )
            nQtNPN := 0
            nQtNPH := fWfldGet("NPH_QUANT")
            // Varrendo as Linhas da Npn
            For nI := 1 To oGridNPN:Length()
                oGridNPN:GoLine(nI)
                If .Not. oGridNPN:IsDeleted()
                    nQtNPN += fWfldGet("NPN_QUANT")
                    If ! oGridNPN:IsDeleted() .and. oGridNPN:IsUpdated() .and. FwFldget('NPN_QUANT') > 0
                        // Validando Qtd. Novamente  Para verificar se realmente tenho saldo Antes de iniciar a Gravacao//
                        lRastro 	:= IIF(!Empty(fWfldGet('NPN_CODPRO')), 	 Rastro(fWfldGet('NPN_CODPRO')),.f.	)
                        lLocaliza	:= IIF(!Empty(fWfldGet('NPN_CODPRO')), Localiza(fWfldGet('NPN_CODPRO')),.f.	)
                        IF ! A900Saldo(fWfldGet('NPN_CODPRO'),fWfldGet('NPN_LOCAL'),fWfldGet('NPN_QUANT'),/*nQuant2UM*/,fWfldGet('NPN_LOTE'),/*cSubLotehjnaotemnatela*/,IIF(lLocaliza,fWfldGet('NPN_LOCALI'),nil),nil/*aTravas*/)
                            If ( lLocaliza )
                                Help(,, STR0029,,STR0111 + fWfldGet("NPH_ITEM") + "/"+ fWfldGet("NPN_ITEM") , 1, 0 )   //#Aviso#"Produto não posui saldo no lote/endereço; Item da autorizacao/Ordem Carregamento:"
                                Return()
                            ElseIF ( lRastro )
                                Help(,, STR0029,,STR0112 + fWfldGet("NPH_ITEM") + "/"+  fWfldGet("NPN_ITEM") , 1, 0 )	//#Aviso#"Produto não posui saldo no lote; Item da autorizacao/Ordem Carregamento:"
                                Return()
                            Else //Só B2
                                Help(,, STR0029,,STR0113 + fWfldGet("NPH_ITEM")+ "/"+  fWfldGet("NPN_ITEM") , 1, 0 )	//#Aviso#"Produto não posui saldo; Item da autorizacao/Ordem Carregamento:"
                                Return()
                            EndIF
                            lContinua := .f.
                            Exit
                        EndIF
                    EndIF
                EndIF
            Next
            IF  ! nQtNPN <= nQtNPH .and. lRetorno
                Help(,, STR0029,,STR0114 + fWfldGet("NPH_ITEM") + STR0115 , 1, 0 )  ////#Aviso #"A soma da quantidade dos itens da ordem de carregamento é maior que a quantidade do item: " #", da Autorizacao; Favor verificar."
                lRetorno:=.f.
                Exit
            EndIF

            IF ! lRetorno
                Exit
            EndIF
        Next
    EndIF
    FWRestRows(aSaveLines)
Return( lRetorno )

//------------------------------------------------------------------
/*{Protheus.doc} PreValLin(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
Rotina de Pre validação do modelo COO(Solicitações)
@author alexandre.gimenez
@param oModelGrid Modelo
@param nLinha Linha corrente
@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
@param cCampo Campo atualizado
@param Vr. inserido no Campo
@param Vr. que do Cpos antes da Inserção do novo vr.
@return lRet
@since 12/09/2013
@version 1.1
*/
//------------------------------------------------------------------
Static Function PreValLin(oModelNPN, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)

    IF cAcao == "CANSETVALUE"   	// não posso alterar linhas
        IF ( oModelNPN:GetDataId() > 0  .And. ! fWfldGet('NPN_QUANT') = 0 .And. ! oModelNPN:IsUpdated() )	// Não Posso Alterar as Linhas q ja Estão Salvas tem que deletar e salvar , para eliminar o empenho
            Help(,, STR0029,,STR0116 , 1, 0 ) 	// #Aviso #"Não é possivel Alterar itens com empenho/reserva de estoque; Delete a linha;"
            Return .f.
        EndIF
    EndIF

Return .t.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} PosValLin(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
	Rotina de Pre validação do modelo COO(Solicitações)
	@author EC
	@param oModelGrid Modelo
	@param nLinha Linha corrente
	@return lRet // .t. Ok Linha esta ok, .f. Linha não esta OK
	@since 12/09/2013
	@version 1.1
/*/
//------------------------------------------------------------------
Static Function PosValLin(oModelNPN, nLinha)
    Local lContinua		:= .t.,lRastro := .f.,lLocaliza	 := .f.
    Local lLinUpdted	:= oModelNPN:IsUpdated()  //Verifica se a Linha Recebeu Valores
    Local cCodSaf			:= Posicione("ADA",1,fWxfilial("ADA")+FwFldGet("NPH_NUMCP"),"ADA_CODSAF")

    IF fWfldGet('NPN_QUANT') == 0
        Return(.t.)  // Não Valido Nada, antes de gerar o Pv,Pq se não informar qtd. não fazemos nada;
    ElseIF fWfldGet('NPN_QUANT') < 0
        Help(,, STR0029,,STR0117 , 1, 0 )	//#Aviso # "Quantidade invalida."
        lContinua := .f.
    ElseIF fWfldGet('NPN_QUANT') > 0  		// Se tem Qtd. digitada preciso validar o estoque
        lRastro 	:= IIF(!Empty(fWfldGet('NPN_CODPRO')), 	 Rastro(fWfldGet('NPN_CODPRO')),.f.	)
        lLocaliza	:= IIF(!Empty(fWfldGet('NPN_CODPRO')), Localiza(fWfldGet('NPN_CODPRO')),.f.	)

        IF lRastro .and. Empty( fWfldGet('NPN_LOTE') ) 	// Verificando se o Produto é Controlado Por Lote
            Help(,, STR0029,,STR0118 , 1, 0 )			//Aviso #"Produto Controla Lote. Favor informar o lote do produto"
            lContinua := .f.
        ElseIf lRastro .and. ! Empty( fWfldGet('NPN_LOTE') ) //Validar o Lote na NP9
            DbSelectArea('NP9')
            NP9->(DbsetOrder(1)) // NP9_FILIAL+NP9_CODSAF+NP9_PROD+NP9_LOTE
            IF ! NP9->(DbSeek(fwXfilial('NP9') + cCodSaf + fWfldGet('NPN_CODPRO')+fWfldGet('NPN_LOTE')))
                Help(,, STR0029,,STR0119 , 1, 0 )	//#Aviso #"Não foi encontrado Lote para este produto na safra informada no contrato"
                lContinua := .f.
            Else
                IF NP9->NP9_STATUS != '2'			//Verifica se o Lote de semente esta ok para faturar
                    Help(,, STR0029,,STR0120 + cCodSaf + "/" + NP9->NP9_LOTE + "/"  + NP9->NP9_PROD  , 1, 0 )	//Aviso #"O lote não se encontra disponivel. Verifique a Situacão do Lote, para este produto e safra. Safra/Lote/Produto:"
                    lContinua := .f.
                EndIF
            EndIF
        ElseIf lLocaliza .and. Empty( fWfldGet('NPN_LOCALI') )  // Verificando se o Produto é Controlado Por endereço
            Help(,, STR0029,,STR0121 , 1, 0 )					//Aviso #"Produto Controlado por endereço. Favor informar o endereço"
            lContinua := .f.
        EndIF
    ElseIf Empty( fWfldGet('NPN_LOCAL') )		 	// Verificando se o Local / Armazem foi Prennchido
        Help(,, STR0029,,STR0122 , 1, 0 )			//Aviso # "Armazem invalido.Favor informar o Armazem do Produto;"
        lContinua := .f.
    EndIF

    IF lContinua .and. lLinUpdted // Se a Linha recebeu vrs.
        lContinua := SldBlqSB2(fWfldGet('NPN_CODPRO'),fWfldGet('NPN_LOCAL')) // Verifica se o Saldo do Armazem Esta Bloqueado e apresenta mensagem de bloqueio caso esteja bloqueado
        IF  lContinua
            IF ! A900Saldo(fWfldGet('NPN_CODPRO'),fWfldGet('NPN_LOCAL'),fWfldGet('NPN_QUANT'),/*nQuant2UM*/,fWfldGet('NPN_LOTE'),/*cSubLotehjnaotemnatela*/,IIF(lLocaliza,fWfldGet('NPN_LOCALI'),nil),nil/*aTravas*/)
                If ( lLocaliza )
                    Help(,, STR0029,,STR0123 , 1, 0 )		//Aviso #"Produto não posui saldo no lote/endereço;"
                ElseIF ( lRastro )
                    Help(,, STR0029,,STR0124 , 1, 0 )		// Aviso #"Produto não posui saldo no lote;"
                Else //Só B2
                    Help(,, STR0029,,STR0125 , 1, 0 )  		//Aviso #"Produto não posui saldo."
                EndIF
                lContinua := .f.
            EndIF
        EndIF
    EndIF
Return (lContinua)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A900Saldo
Rotina que Verifica o Saldo do Produto;
@author Emerson Coelho
@params  	cLocal    - Armazem 	do produto analisado
nQuant    - Quantidade 	do a Ser Analisada
nQuant2UM - Quantidade  em 2a Moeda a Ser Analizado
cLoteCtl  - Lote a Ser Analisaddo
cNumLote  - Sub-Lote a Ser Analisado
cEndereco - Endereço do Produto
aTravas   - Array com os Recno travados
@return  .t. Se possui Saldo, .f. se não Possui o Saldo > ou = q Qtd. Passada
@since 28/092015
/*/
// -------------------------------------------------------------------------------------
Static Function A900Saldo(cProduto,cLocal,nQuant,nQuant2UM,cLoteCtl,cNumLote,cEndereco,aTravas)
    Local aAreaSB8	:=	SB8->(GetArea()),aAreaSBF	:=	SBF->(GetArea()),aAreaSB2	:=	SB2->(GetArea()),aArea	:=	GetArea()
    Local nCnt			:= 0,nCnt2 := 0,nSaldo := 0
    Local lRet     	:= .T.
    Local aArray   	:= {}
    Local lRastro  	:= Rastro(cProduto)
    Local lLocaliza	:= Localiza(cProduto)
    Default aTravas := {}

    IF lRet
        // Checa o saldo do lote/Endereco/Abate/Empenhaddos e Reservados.
        If ( lRastro .Or. lLocaliza )
            aArray := SldPorLote(cProduto,cLocal,nQuant,nQuant2UM,cLoteCtl,cNumLote,cEndereco,/*nUMERO DE SERIE*/NIL,@aTravas,nil,NIL,NIL,NIL,NIL,/*dDatabase*/,,,)
            If lRet .And. lRastro
                nSaldo := 0
                For nCnt := 1 to Len(aArray)
                    For nCnt2 := 1 to Len(aArray[nCnt,10])
                        nSaldo += aArray[nCnt,10,nCnt2,2]
                    Next nCnt2
                Next nCnt
                lRet := QtdComp(nSaldo) >= QtdComp(nQuant)
            EndIf
            If lRet .And. lLocaliza
                nSaldo := 0
                For nCnt := 1 to Len(aArray)
                    nSaldo += aArray[nCnt,5]
                Next nCnt
                lRet := QtdComp(nSaldo) >= QtdComp(nQuant) //QtdComp Retorna um numero arredondado com nCasas Decimais.
            EndIf
        Else
            AGRIFDBSEEK("SB2",cProduto+cLocal,1,.f.)
            lRet := !(SaldoMov() < nQuant)
        EndIf
    EndIf
    RestArea(aArea   )
    RestArea(aAreaSB8)
    RestArea(aAreaSBF)
    RestArea(aAreaSB2)
Return( lRet )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900HIS
//Mostra em tela o Historico do item da ordem de carregamento
@author  Inácio Luiz Kolling
@since 30/11/2015
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Function AGRA900HIS(lMenu)
    Local nChaTam 	:= TAMSX3("NK9_CHAVE")[1]
    Local cChaveI 	:= Alltrim(xFilial('NPM')+If(lMenu = Nil,FwFldGet("NPM_CODIGO")+FwFldGet("NPM_CODAC"),NPM->NPM_CODIGO))
    Local cChaveA 	:= cChaveI+Space(If(lMenu = Nil,nChaTam-Len(cChaveI),0))

    AGRHISTTABE("NPM",cChaveA,If(lMenu <> Nil,Len(cChaveI),))
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGR900DPED
//Função Auxiliar para a exclusão do pedido de venda via módulo SIGAFAT
@author  Bruna Rocio
@since 25/02/2016
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Function AGR900DPED(cPedido)
    Local aAreaAtu := GetArea()
    Local lRetorno := .T.

    If AGRIFDBSEEK("NPM",cPedido,2,.F.)

        while ( AGRIFDBSEEK("NPN",cPedido,3,.F.))
            cChavNPM := NPN->NPN_ORDEMC
            cCarrega := NPN->NPN_CODAC

            If AGRIFDBSEEK("NPH",NPN->NPN_CODAC+NPN->NPN_ITEMAC,1,.F.)
                cContr := NPH->NPH_NUMCP
                AGRTRAVAREG(,.F.)
                NPH->NPH_QTDDIS += NPN->NPN_QUANT
                AGRDESTRAREG()
            EndIf

            AGRTRAVAREG("NPN",.F.)
            NPN->NPN_NUMPV 	:= ""
            NPN->NPN_ITEMPV	:= ""
            AGRTRAVAREG(,.F.)
            AGRDESTRAREG()
        EndDo

        If AGRIFDBSEEK("NPM",cChavNPM,1,.F.)   //Atualizando o Cabec. da Ordem de Carregamento
            AGRTRAVAREG(,.F.)
            AGRGRAVAREG("NPM",{{'NPM_NUMPV',""},{'NPM_STATUS','2'}})
            AGRDESTRAREG()
        EndIF

        // Atualiza o status da autorização
        AGRA900NPGS(cCarrega,NPM->NPM_CODIGO)
        // Atualiza o contrato
        AGRIFDBSEEK("ADA",cContr,1,.F.)
        AGRTRAVAREG(,.F.)
        Ft400StatCt()
        AGRDESTRAREG( )
    Endif

    // Restaurando Areas //
    RestArea(aAreaAtu)
Return lRetorno
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} A900LTBRW
//Retorna os detalhes do LOTE
@author bruna.rocio
@since 08/07/2016
@version undefined
@param cCampo, characters, descricao
@param cLote, characters, descricao
@param cCODAC, characters, descricao
@type function
/*/
// -------------------------------------------------------------------------------------
Function A900LTBRW(cCampo, cLote, cCODAC)
    Local aArea    := GetArea()
    Local cRet     := ""
    Local cContrat := ""
    Local cSafra   := ""

    cContrat := Posicione('NPH',1,xFilial('NPH')+cCODAC,'NPH_NUMCP')
    cSafra   := Posicione('ADA',1,xFilial('ADA')+cContrat,'ADA_CODSAF')

    If cCampo = "NPN_CULTRA"
        cRet := Posicione('NP9',3,xFilial('NP9')+cSafra+cLote,'NP9_CULTRA')
    ElseIf cCampo = "NPN_CTVAR"
        cRet := Posicione('NP9',3,xFilial('NP9')+cSafra+cLote,'NP9_CTVAR')
    ElseIf cCampo = "NPN_CATEG"
        cRet := Posicione('NP9',3,xFilial('NP9')+cSafra+cLote,'NP9_CATEG')
    ElseIf cCampo = "NPN_PENE"
        cRet := Posicione('NP9',3,xFilial('NP9')+cSafra+cLote,'NP9_PENE')
    EndIf

    RestArea(aArea)
Return cRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900PRE
//Função Pré-Menu
@author Thiago Henrique Rover
@since 31/10/2016
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Function AGR900PRE(nOp)
    Local lRet := .T.

    if ExistBlock("AGR900P6")
        lRet := ExecBlock("AGR900P6",.F.,.F.,{nOp})
        if !lRet
            return
        Endif
    Endif

    Do Case
        Case nOp == 2 //"Visualizar"
            FWExecView('', 'VIEWDEF.AGRA900', MODEL_OPERATION_VIEW, , {|| .T. })
        Case nOp == 3 //incluir
            FWExecView('', 'VIEWDEF.AGRA900', MODEL_OPERATION_INSERT, , {|| .T. })
        Case nOp == 4 //"Alterar"
            FWExecView('', 'VIEWDEF.AGRA900', MODEL_OPERATION_UPDATE, , {|| .T. })
        Case nOp == 5 //"Excluir"
            FWExecView('', 'VIEWDEF.AGRA900', MODEL_OPERATION_DELETE, , {|| .T. })
        Case nOp == 6 //Geração de Nota Fiscal
            AGRA900NFS()
        Case nOp == 7 //Impressão
            AGRA900IMP()
        Case nOp == 8 //Geração de Pedido de Venda
            AGRA900STA()
        Case nOp == 9 //Exclui Pedido de Venda
            AGRA900DPV()
        Case nOp == 10 //Exclui Documento Fiscal
            AGRA900DNF()
        Case nOp == 11 //Histórico
            AGRA900HIS("M")
        Case nOp == 12 //Conhecimento (lote de sementes)
            AGRA900CONH()
        Case nOp == 13 //SPEDNFE
            AGRA900SPED()
        Case nOp == 14 //Conhecimento (Ordem de Carregamento)
            AGRA900COR()
    EndCase

Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900SPED
//Tratamento para chamada da SPEDNFE
@author bruna.rocio
@since 25/10/2016
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Function AGRA900SPED()
    Local nModOld := nModulo
    Local cModOld := cModulo
    Local lRet    := .T.

    nModulo := 5 //SIGAFAT
    cModulo := "FAT"

    SPEDNFE()

    nModulo := nModOld
    cModulo := cModOld
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA900COR
//Mantem os conhecimentos da ordem de carregamento
@author carlos.augusto
@since 08/12/2016
@version undefined
@type function
/*/
// -------------------------------------------------------------------------------------
Function AGRA900COR()
    AGRCONHECIM("NPM")
return
//-------------------------------------------------------------------
/*/{Protheus.doc} AGR900FIL()
Filtro para consulta padrão de lote
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function AGR900FIL()

    Local lShow as logical
    Local cAliasCount as char
    Local cAliasNLP as char
    Local aAreaNP9 as array
    Local oModelAut as object
    Local cAcNPM as char

    aAreaNP9 := NP9->(GetArea())

    cAliasCount := GetNextAlias()
    cAliasNLP := GetNextAlias()

    If IsInCallStack('AGRA900') .and. TableInDic('NLP')
        
        oModelAut := FWModelActive()

        cAcNPM := oModelAut:GetModel('MdFieldNPM'):GetValue('NPM_CODAC')

        lShow := .F.
        // verifica se possui reserva para o contrato de parceria da autorização de entrega
        BeginSql Alias cAliasCount
            SELECT COUNT(*) AS HAS_RESERVE

            FROM %table:NPH% NPH

            INNER JOIN %table:NLP% NLP ON NLP.NLP_FILIAL = NPH.NPH_FILIAL
                AND NLP.NLP_NUMCTR = NPH.NPH_NUMCP
                AND NLP.D_E_L_E_T_ = NPH.D_E_L_E_T_

            WHERE NPH.%notDel%
                AND NPH.NPH_FILIAL = %Exp:FWxfilial('NPM')%
                AND NPH.NPH_CODAC  = %Exp:cAcNPM%
        EndSql

        If !(cAliasCount)->(EoF()) .and. (cAliasCount)->HAS_RESERVE > 0
            // caso possua reserva, verifica se o lote posicionado está na reserva
            BeginSql Alias cAliasNLP
                SELECT COUNT(*) AS HAS_RESERVE

                FROM %table:NPH% NPH

                INNER JOIN %table:NLP% NLP ON NLP.NLP_FILIAL = NPH.NPH_FILIAL
                    AND NLP.NLP_NUMCTR = NPH.NPH_NUMCP
                    AND NLP.D_E_L_E_T_ = NPH.D_E_L_E_T_

                WHERE NPH.%notDel%
                    AND NPH.NPH_FILIAL = %Exp:FWxfilial('NPM')%
                    AND NPH.NPH_CODAC  = %Exp:cAcNPM%
                    AND NLP.NLP_LOTE = %Exp:NP9->NP9_LOTE%
            EndSql

            If !(cAliasNLP)->(EoF()) .and. (cAliasNLP)->HAS_RESERVE > 0
                lShow := .T.
            EndIf

        Else
            // se não possui reserva, busca somente os lotes livres (não reservados)
            BeginSql Alias cAliasNLP
                SELECT COUNT(*) AS HAS_RESERVE

                FROM %table:NLP% NLP 

                WHERE NLP.%notDel%
                    AND NLP.NLP_FILIAL = %Exp:NP9->NP9_FILIAL%
                    AND NLP.NLP_LOTE = %Exp:NP9->NP9_LOTE%
            EndSql

             If !(cAliasNLP)->(EoF()) .and. (cAliasNLP)->HAS_RESERVE == 0
                lShow := .T.
            EndIf

        EndIf
    Else
        lShow := .T.
    EndIf

    (cAliasCount)->(DBCloseArea())
    (cAliasNLP)->(DBCloseArea())

    RestArea(aAreaNP9)
 
Return lShow

