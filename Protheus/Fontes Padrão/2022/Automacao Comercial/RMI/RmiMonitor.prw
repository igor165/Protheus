#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIMONITOR.CH"
#INCLUDE "FWBROWSE.CH"  

//Posicao do ListBox
#DEFINE PLEG		1			//Legenda - Vermelho = Erro | Amarelo = Erro por dependencia de outro cadastro | Azul = Erro de Integracacao com o ERP
#DEFINE PFILIAL		2			//Filial
#DEFINE PSTATUS		3			//Status
#DEFINE PDATA		4			//Data do Processamento
#DEFINE PHORA		5			//Hora do Processamento
#DEFINE PTAB		6			//Tabela Processada
#DEFINE PDESCTAB	7			//Descricao da Tabela
#DEFINE PREGIST		8			//Recno do Registro na Tabela Processada
#DEFINE PCODERR		9			//Codigo do Erro (STR)
#DEFINE PMSGERR		10			//Mensagem do Erro
#DEFINE PRECMHL		11			//Recno na tabela MHL
#DEFINE PRECPIN		12			//RECNO da tabela de cabecalho da camada(PIN)
#DEFINE PRECSL1		13			//RECNO da tabela de cabecalho do orcamento (SL1)
#DEFINE PDOC		14			//Documento Original da venda
#DEFINE PSERIE		15			//Serie do Documento
#DEFINE PSERSAT		16			//Numero de serie do equipamento SAT
#DEFINE PSERPDV		17			//Numero de serie do ECF

//Posicao do Array das Integracoes
#DEFINE PINTNOM		1			//Nome da Integracao
#DEFINE PINTAPL		2			//Integracao esta aplicada no ambiente
#DEFINE PINTCON		3			//Integracao esta selecionada para consultar
#DEFINE PINTPAI		4			//Tabela principal
#DEFINE PINTTAB		5			//Todas as tabelas da integracao

Static aIntegra	:= {}		    //Array contendo todas as integracoes disponiveis e se elas estao instaladas
/*==================================\
|	Elementos do Array aIntegra	    |
|-----------------------------------|
|aIntegra[1] - Nome Integracao		|
|aIntegra[2] - Integracao Aplicada	|
|aIntegra[3] - Integracao Consulta	|
|aIntegra[4] - Tabela Pai			|
|aIntegra[5] - Tabelas				|
\==================================*/

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRmiMonit
Monitor de Integração 
- Utilizado para apresentar e reprocessar registros integrados

@since 13/08/2019
/*/
//-------------------------------------------------------------------
Function RmiMonitor()

    //Variaveis da Tela Main
    Local oLayer    := FWLayer():new()
    Local aButtons 	:= {}
    Local oDlg      := Nil
    Local aCoors    := MsAdvSize() 
    Local oPnUp     := Nil
    Local oPnCenter := Nil
    Local oPnColR   := Nil
    Local oPnColC   := Nil
    Local oColumn   := Nil

    //Variaveis dos GET
    Local oErros    := Nil
    Local oFilial   := Nil
    Local oDtIni    := Nil
    Local oDtFim    := Nil
    Local cErros    := ""
    Local cFilInt   := ""
    Local dDtIni    := dDataBase
    Local dDtFim    := dDataBase

    //Variaveis do List dos Itens Consultados
    Local oLstMnt   := Nil
    Local aLstMnt	:= {}
    Local aCabMnt	:= {" ", STR0500, STR0501, STR0502, STR0503, STR0504, STR0505, STR0506, STR0507, STR0508, STR0509, STR0510, STR0511, STR0512, STR0513, STR0514, STR0515}    //"Filial", "Status", "Data", "Hora", "Tabela", "Desc. Tabela", "Registro", "Cod. Erro", "Erro", "Reg. Log", "Reg. Integração", "Reg. Orçamento", "Documento", "Serie", "Serie SAT", "Serie ECF"

    //Variaveis do List das Integracoes
    Local oLstInt   := Nil
    Local aLstInt	:= {}
    Local aCabInt	:= {" ", PadR(STR0516, 30), STR0517, STR0518}  //"Integração"   "Tabela Princípal"    "Tabelas"
    Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
    Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
    
    //Popula o Array aIntegra com todas as Integracoes existentes 
    aIntegra	:= {}
    aAdd(aIntegra,{STR0519  , .F., .F., "PI8", "PI8"						})		//"Produto"
    aAdd(aIntegra,{STR0520	, .F., .F., "PIA", "PIA"						})		//"Dados Adicionais de Produtos"
    aAdd(aIntegra,{STR0521  , .F., .F., "PJ7", "PJ7;PIS;PIT;PIU;PIV;PIW;PIX"})		//"Árvore Mercadologica"
    aAdd(aIntegra,{STR0522  , .F., .F., "PI6", "PI6"					    })		//"Transportadora"
    aAdd(aIntegra,{STR0523	, .F., .F., "PI1", "PI1;PI2;PI7"				})		//"Tabela de Preço"
    aAdd(aIntegra,{STR0524  , .F., .F., "PJ5", "PJ5;PJ6;PI9"				})		//"Saldos Iniciais"
    aAdd(aIntegra,{STR0525  , .F., .F., "PID", "PID"						})		//"Pedido de Compra"
    aAdd(aIntegra,{STR0526  , .F., .F., "PIB", "PIB;PIC"					})		//"Pedido de Venda"
    aAdd(aIntegra,{STR0527  , .F., .F., "PIH", "PIH"						})		//"Títulos a Pagar"
    aAdd(aIntegra,{STR0528  , .F., .F., "PIG", "PIG"						})		//"Títulos a Receber"
    aAdd(aIntegra,{STR0529  , .F., .F., "PI4", "PI4"						})		//"Fornecedores"
    aAdd(aIntegra,{STR0530  , .F., .F., "PI5", "PI5"					    })		//"Vendedores"
    aAdd(aIntegra,{STR0531	, .F., .F., "PI3", "PI3"						})		//"Clientes"
    aAdd(aIntegra,{STR0532  , .F., .F., "PIY", "PIY"						})		//"Contatos"
    aAdd(aIntegra,{STR0533	, .F., .F., "PJ0", "PJ0;PJ1;PJ2;PJ3;PJ4"		})		//"Credito e Referência Pessoal"
    aAdd(aIntegra,{STR0534  , .T., .T., "SL1", "SL1;SL2;SL4"				})		//"Cupom Fiscal"
    aAdd(aIntegra,{STR0534+" - Cancelado", .T., .T., "SLX", "SLX"				})		//"Cupom Fiscal"
    aAdd(aIntegra,{STR0535  , .F., .F., "PIL", "PIL;PIF"					})		//"Nota Fiscal de Saída"
    aAdd(aIntegra,{STR0536  , .F., .F., "PIJ", "PIJ"						})		//"Movimentação Bancária"
    aAdd(aIntegra,{STR0537  , .F., .F., "PIK", "PIK;PIE"				    })		//"Nota Fiscal de Entrada"
    aAdd(aIntegra,{STR0538  , .F., .F., "PIM", "PIM"						})		//"Redução Z"
    aAdd(aIntegra,{STR0539  , .F., .F., "PJD", "PJD"						})		//"Baixas Contas a Receber"
    aAdd(aIntegra,{STR0540  , .F., .F., "PIQ", "PIQ"						})		//"Situações"
    aAdd(aIntegra,{STR0541  , .F., .F., "PIR", "PIR"						})		//"Garantias"
    aAdd(aIntegra,{STR0542  , .F., .F., "PJ8", "PJ8"						})		//"Indicadores"
    aAdd(aIntegra,{STR0543  , .F., .F., "PII", "PII"					    })		//"Condições de Pagamento"
    aAdd(aIntegra,{STR0544  , .F., .F., "PJ9", "PJ9"						})      //"Demandas de Produtos"
    //Carrega as integrações ativas
    IntAtiva(@aLstInt)

    If Len(aLstInt) == 0

        MsgInfo(STR0545)    //"Nenhuma integração está aplicada nesse ambiente"
    Else

        DEFINE MSDIALOG oDlg TITLE STR0546 FROM aCoors[7],aCoors[1] TO aCoors[6],aCoors[5] PIXEL    //"Monitor de Integração"
            oLayer:Init(oDlg,.F.)
            oLayer:oPanel:Align := CONTROL_ALIGN_ALLCLIENT //CONTROL_ALIGN_TOP//
            
            oLayer:AddLine('UP'    , 020, .F.)
            oLayer:AddLine('CENTER', 075, .F.)
            
            oLayer:addCollumn('RIGHT' , 35, .F., 'UP')
            oLayer:addCollumn('CENTER', 65, .F., 'UP')
            
            oPnUp	    := oLayer:GetLinePanel('UP'	    )
            oPnCenter	:= oLayer:GetLinePanel('CENTER' )
            
            oPnColR:= oLayer:GetColPanel('RIGHT' , 'UP')
            oPnColC:= oLayer:GetColPanel('CENTER', 'UP')
            
            //Layer Superior
            TSay():New(010, 005,{|| STR0547 },oPnColR,,,.F.,.F.,.F.,.T.,,,200,008)  //"Período"
            oDtIni	:= tGet():New(008,030,{|u| Iif( PCount() > 0, dDtIni := u, dDtIni)},oPnColR,40,,"@D",,,,,,,.T.,,,,,,,,,,"dDtIni")
                            
            TSay():New(010, 075,{|| STR0548 },oPnColR,,,.F.,.F.,.F.,.T.,,,200,008)  //"a"
            oDtFim	:= tGet():New(008,083,{|u| Iif( PCount() > 0, dDtFim := u, dDtFim)},oPnColR,40,,"@D",,,,,,,.T.,,,,,,,,,,"dDtFim")

            TSay():New(025,	005,{|| STR0508 },oPnColR,,,.F.,.F.,.F.,.T.,,,200,008)  //"Erro"
            oErros	:= tGet():New(023,030,{|u| Iif( PCount() > 0, cErros := u, cErros)},oPnColR,170,,"@!",,,,,,,.T.)
            oErros:bGotFocus	:= {|| SelErros(@cErros,@oErros) }
            oErros:lReadOnly	:= .T.
                
            TSay():New(040, 005,{|| STR0500 },oPnColR,,,.F.,.F.,.F.,.T.,,,200,008)  //"Filial"
            oFilial:= tGet():New(038,030,{|u| Iif( PCount() > 0, cFilInt := u, cFilInt)},oPnColR,170,,"@!",,,,,,,.T.)
            oFilial:bGotFocus	:= {|| SelFiliais(@cFilInt,@oFilial) }
            oFilial:lReadOnly	:= .T.
            
            aAdd(aButtons, {"USER", {|| Processa( {|| BtAtualiza(dDtIni, dDtFim, @oLstMnt, @aLstMnt, aLstInt, cErros, cFilInt)}        ) } , STR0549    } ) //"Atualiza"
            aAdd(aButtons, {"USER", {|| Processa( {|| BtReproces(.T. , @oLstMnt, @aLstMnt, dDtIni, dDtFim, aLstInt, cErros, cFilInt)}  ) } , STR0550    } ) //"Reprocessa Manual"
            aAdd(aButtons, {"USER", {|| Processa( {|| BtReproces(.F. , @oLstMnt, @aLstMnt, dDtIni, dDtFim, aLstInt, cErros, cFilInt)}  ) } , STR0551    } ) //"Reprocessa Automático"
            aAdd(aButtons, {"USER", {|| BtExporta(aLstMnt, aCabMnt)                                                                      } , STR0552    } ) //"Exportar"
            aAdd(aButtons, {"USER", {|| Processa( {|| BtVisAcumu(cFilInt, dDtIni, dDtFim, aLstInt)}                                    ) } , STR0553    } ) //"Visão Acumulada"
            aAdd(aButtons, {"USER", {|| BtLegenda()                                                                                      } , STR0554    } ) //"Legenda"
            
            //List das Integacoes
            oLstInt:= TWBrowse():New(0,0,0,0,,aCabInt,,oPnColC,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
            oLstInt:Align    := CONTROL_ALIGN_ALLCLIENT
            oLstInt:lHScroll := .F.
            oLstInt:SetArray(aLstInt)
            oLstInt:bLDblClick 	:= { || SelIntegra(@aLstInt,@oLstInt), oLstInt:Refresh(), Processa( {|| BtAtualiza(dDtIni, dDtFim, @oLstMnt, @aLstMnt, aLstInt, cErros, cFilInt)} ) }
            oLstInt:bLine       := { || {   IIF(aLstInt[oLstInt:nAt][1],oOk,oNo),;
                                                aLstInt[oLstInt:nAt][2]         ,;
                                                aLstInt[oLstInt:nAt][3]         ,;
                                                aLstInt[oLstInt:nAt][4] }       }
            
            //Layer Inferior
            DEFINE FWBROWSE oLstMnt DATA ARRAY ARRAY aLstMnt LINE BEGIN 1 NO LOCATE NO CONFIG NO SEEK NO REPORT OF oPnCenter 
                ADD STATUSCOLUMN    oColumn DATA { || aLstMnt[oLstMnt:At()][PLEG	] } DOUBLECLICK { |oLstMnt|  } OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PFILIAL ] } TITLE aCabMnt[PFILIAL ]	TYPE "C" SIZE 04 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PSTATUS ] } TITLE aCabMnt[PSTATUS ]	TYPE "C" SIZE 04 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PDATA	] } TITLE aCabMnt[PDATA   ]	TYPE "D" SIZE 06 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PHORA	] } TITLE aCabMnt[PHORA	  ]	TYPE "C" SIZE 06 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PTAB	] } TITLE aCabMnt[PTAB	  ] TYPE "C" SIZE 04 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PDESCTAB] } TITLE aCabMnt[PDESCTAB]	TYPE "C" SIZE 10 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PREGIST ] } TITLE aCabMnt[PREGIST ]	TYPE "N" SIZE 08 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PCODERR ] } TITLE aCabMnt[PCODERR ]	TYPE "C" SIZE 06 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PMSGERR ] } TITLE aCabMnt[PMSGERR ]	TYPE "C" SIZE 30 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PRECMHL ] } TITLE aCabMnt[PRECMHL ]	TYPE "N" SIZE 06 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PRECPIN ] } TITLE aCabMnt[PRECPIN ] TYPE "N" SIZE 06 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PRECSL1 ] } TITLE aCabMnt[PRECSL1 ]	TYPE "N" SIZE 06 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PDOC	] } TITLE aCabMnt[PDOC	  ]	TYPE "C" SIZE 10 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PSERIE	] } TITLE aCabMnt[PSERIE  ]	TYPE "C" SIZE 04 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PSERSAT ] } TITLE aCabMnt[PSERSAT ]	TYPE "C" SIZE 10 OF oLstMnt
                ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PSERPDV ] } TITLE aCabMnt[PSERPDV ]	TYPE "C" SIZE 10 OF oLstMnt
            ACTIVATE FWBROWSE oLstMnt

        ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() }, .F., aButtons, /*nRecno*/, /*cAlias*/, .F., .F., .F., .F., .F., "RmiMonitor")

    EndIf

    FwFreeObj(aButtons)
    FwFreeObj(aCoors )
    FwFreeObj(aLstMnt)
    FwFreeObj(aCabMnt)
    FwFreeObj(aLstInt)
    FwFreeObj(aCabInt)
    
    FwFreeObj(oDlg   )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IntAtiva
Adiciona os botoes a outras ações e habilita as integrações

@since 13/08/2019
/*/
//-------------------------------------------------------------------
Static Function IntAtiva(aLstInt)

    Local aArea := GetArea()
    Local nI	:= 0

    //Verifica se encontra a tabela para ativa integração
    For nI := 1 to Len(aIntegra)

        If FwAliasInDic( aIntegra[nI][PINTPAI] )
            //Popula a tabela e seu nome para usar na pesquisa
            Aadd(aLstInt, {.F., aIntegra[nI][PINTNOM], aIntegra[nI][PINTPAI], aIntegra[nI][PINTTAB]} )
            //Adiciona a integracao como ativa
            aIntegra[nI][PINTAPL] := .T.
        EndIf
    Next nI
    
    RestArea(aArea)    

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SelIntegra
Marca/desmarca a integração que será analisada

@since 13/08/2019
/*/
//-------------------------------------------------------------------
Static Function SelIntegra(aLstInt, oLstInt)

    Local nI     := 0
    Local nAchou := 0
    Local nPos   := 0

    For nI := 1 to Len(aLstInt)

        //Verifica se ja existe uma integracao selecionada e nao sendo a atual
        If aLstInt[nI][1] .And. nI <> oLstInt:nAt
            nAchou := nI
            Exit
        EndIf
    Next nI

    If nAchou > 0

        If MsgYesNo( I18n(STR0555, { Alltrim( aLstInt[nAchou][2] ) }) ) //"Já existe uma integracao selecionada (#1) e é possivel escolher apenas uma. Deseja desmarcar a anterior e marcar essa nova?"
        
            //Desmarca a anterior
            aLstInt[nAchou][1] := !aLstInt[nAchou][1]

            If (nPos := aScan(aIntegra,{|x| Alltrim(x[PINTNOM]) == Alltrim(aLstInt[nAchou][2])})) <> 0
                aIntegra[nPos][PINTCON] := aLstInt[nAchou][1]
            EndIf
                    
            //Marca a nova
            aLstInt[oLstInt:nAt][1] := !aLstInt[oLstInt:nAt][1]

            If (nPos := aScan(aIntegra,{|x| Alltrim(x[PINTNOM]) == Alltrim(aLstInt[oLstInt:nAt][2])})) <> 0
                aIntegra[nPos][PINTCON] := aLstInt[oLstInt:nAt][1]
            EndIf
        EndIf

    Else
        aLstInt[oLstInt:nAt][1] := !aLstInt[oLstInt:nAt][1]
            
        If (nPos := aScan(aIntegra,{|x| Alltrim(x[PINTNOM]) == Alltrim(aLstInt[oLstInt:nAt][2])})) <> 0
            aIntegra[nPos][PINTCON] := aLstInt[oLstInt:nAt][1]
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BtAtualiza
Atualiza grid com os registros de erro

@since 13/08/2019
/*/
//-------------------------------------------------------------------
Static Function BtAtualiza( dDtIni, dDtFim , oLstMnt, aLstMnt, aLstInt,;
                            cErros, cFilInt)

    Local cQry		:= ""
    Local cAlias	:= GetNextAlias()
    Local aArea	    := GetArea()
    Local cDescErro := ""
    Local nPos		:= 0
    Local aIntegSel	:= IntegraSel(aLstInt)
    Local cTabInt	:= aIntegSel[2]
    Local cCodErro	:= ""
    Local cLegenda	:= ""
    Local cDescTab	:= aIntegSel[1]
    Local cHora     := MHL->MHL_HORA

    ProcRegua(0)
    IncProc(STR0556)    //"Selecionando registros. . ."

    If Empty(cTabInt)
        MsgInfo(STR0557)    //"Nenhuma Integração foi selecionada"
        Return Nil
    EndIf

    If cTabInt == "SL1"
        If "ORACLE" $ Upper(Alltrim(TcGetDB()))
            cQry := " SELECT NVL(SL1.R_E_C_N_O_,0) RECSL1, NVL(MHL.R_E_C_N_O_,0) RECMHL"
        Else
            cQry := " SELECT ISNULL(SL1.R_E_C_N_O_,0) RECSL1, ISNULL(MHL.R_E_C_N_O_,0) RECMHL"
        EndIf

        cQry += " FROM " + RetSQLName("SL1") + " SL1 LEFT JOIN " + RetSQLName("MHL") + " MHL "
        cQry +=    " ON MHL_ALIAS = 'SL1' AND SL1.R_E_C_N_O_ = MHL_RECNO AND SL1.D_E_L_E_T_ = MHL.D_E_L_E_T_"
        
        cQry += " WHERE SL1.D_E_L_E_T_ = ' '"
        cQry +=    IIF( !Empty(cFilInt)," AND L1_FILIAL IN ('" + StrTran(cFilInt,";","','") + "') ","")
        cQry +=    " AND L1_EMISSAO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
        cQry +=    " AND L1_SITUA IN ('IP','IR','IE','ER')"
        cQry +=    IIF( !Empty(cErros), " AND MHL_CODMEN IN ('"  + StrTran(cErros, ";", "','")  + "') ", "")

        cQry += " ORDER BY RECSL1"
    
    Else
        cQry := "SELECT R_E_C_N_O_ RECMHL," 
        
        If "MSSQL" $ Upper(Alltrim(TcGetDB()))
            cQry += " ISNULL(CONVERT(VARCHAR(100), CONVERT(VARBINARY(100), MHL_ERROR)),'') AS ERROR_SQL"
        Else
            cQry += " '' ERROR_SQL"
        EndIf
        
        If "MSSQL" $ Upper(Alltrim(TcGetDB()))
            cQry += "  FROM " + RetSqlName("MHL") + " WITH (NOLOCK)"
        Else
            cQry += "  FROM " + RetSqlName("MHL")
        EndIf          

        cQry += " WHERE MHL_DATA BETWEEN '" + dTos(dDtIni) + "' AND '" + dTos(dDtFim) + "'"
        cQry += "   AND D_E_L_E_T_ = ' '"
        cQry += "   AND MHL_ALIAS = '" + cTabInt + "'"
        
        //Caso tenha selecionado o Filtro por erros, adiciona no filtro
        If !Empty(cErros)
            cQry += " AND MHL_CODMEN IN('" + StrTran(cErros,";","','") + "')"
        EndIf
        
        //Caso tenha selecionado o Filtro por Filiais, adiciona no Filtro
        If !Empty(cFilInt)
            cQry += " AND MHL_FILIAL IN('" + StrTran(cFilInt,";","','") + "')"
        EndIf
        cQry += " ORDER BY RECMHL"
    EndIf

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQry), cAlias, .T., .F.)

    If !(cAlias)->( Eof() )

        //Zera a variavel independente se existem registros ou nao.
        aLstMnt := {}

        If cTabInt == "SL1"
        
            While !(cAlias)->( Eof() )

                cLegenda   := ""
                cCodErro   := ""
                cDescErro  := ""
                cHora      := ""

                SL1->( DbGoto( (cAlias)->RECSL1 ) )

                If !SL1->( Eof() )

                    //Erro do Gravabat - ERP
                    If SL1->L1_SITUA == "ER"

                        cLegenda  := "BR_AZUL"
                        cCodErro  := "INT_ERP"
                        cDescErro := StrTran( StrTran( AllTrim( MemoLine(SL1->L1_ERGRVBT) ), Chr(10), " "), Chr(13), " ")
                    Else

                        Do Case
                            //Integração Pendente
                            Case SL1->L1_SITUA == "IP"
                                cLegenda := "BR_BRANCO"

                            //Integração com Erro que pode ser corrigida com reprocessamento
                            Case SL1->L1_SITUA == "IR"
                                cLegenda := "BR_AMARELO"

                            //Integração com Erro
                            Case SL1->L1_SITUA == "IE"
                                cLegenda := "BR_VERMELHO"
                        End Case

                        If (cAlias)->RECMHL > 0

                            MHL->( DbGoto( (cAlias)->RECMHL ) )
                            If !MHL->( Eof() )
                                cHora     := MHL->MHL_HORA
                                cCodErro  := MHL->MHL_CODMEN
                                cDescErro := AllTrim( Memoline(MHL->MHL_ERROR) )
                            EndIf
                        EndIf

                    EndIf

                    AAdd(aLstMnt, { cLegenda            ,;  	//01 - Legenda do campo - Vermelho = Erro | Amarelo = Erro por dependencia de outro cadastro | Azul = Erro de Integracacao com o ERP
                                    SL1->L1_FILIAL      ,;		//02 - Filial
                                    SL1->L1_SITUA       ,;		//03 - Status
                                    SL1->L1_EMISSAO     ,;		//04 - Emissao
                                    cHora               ,;		//05 - Hora do Processamento
                                    "SL1"               ,;		//06 - Tabela
                                    cDescTab            ,;		//07 - Descricao da Tabela
                                    (cAlias)->RECSL1    ,;		//08 - Numero do registro
                                    cCodErro            ,;		//09 - Codigo do Erro
                                    cDescErro           ,;		//10 - Descricao completa do erro
                                    (cAlias)->RECMHL    ,;		//11 - RECNO da tabela de LOG (MHL)
                                    0                   ,;		//12 - RECNO da tabela de cabecalho da camada(PIN)
                                    (cAlias)->RECSL1    ,;		//13 - RECNO da tabela de cabecalho do orcamento (SL1)
                                    SL1->L1_DOC         ,;		//14 - Documento Original da venda
                                    SL1->L1_SERIE       ,;		//15 - Serie do Documento
                                    SL1->L1_SERSAT      ,;		//16 - Numero de serie do equipamento SAT
                                    SL1->L1_SERPDV  }   )    	//17 - Numero de serie do ECF
                EndIf
                            
                (cAlias)->( dbSkip() )
            End

            oLstMnt:SetArray(aLstMnt)
            oLstMnt:Refresh()

        Else

            While !(cAlias)->( Eof() )
                MHL->( dbGoTo( (cAlias)->RECMHL ) )
                
                //Caso seja base SQL ja tem o tratamento para a leitura do erro e fica mais rapido
                If Empty((cAlias)->ERROR_SQL)
                    cDescErro := AllTrim( Memoline( MHL->MHL_ERROR ) )
                Else
                    cDescErro := AllTrim( (cAlias)->ERROR_SQL )
                EndIf
                
                //Tenta buscar a tabela populada anteriormente no array, se nao achar pesquisa no SX2
                If ( nPos := aScan(aLstInt, {|x| x[2] == MHL->MHL_ALIAS} ) ) <> 0
                    cDescTab := aLstInt[nPos][1]
                Else
                    cDescTab := FwX2Nome(MHL->MHL_ALIAS)
                EndIf
            
                aAdd(aLstMnt,{	IIF(MHL->MHL_STATUS == "3", "BR_VERMELHO", "BR_AMARELO"),;  //01 - Legenda
                                MHL->MHL_FILIAL     ,;										//02 - Filial
                                MHL->MHL_STATUS     ,;										//03 - Status
                                DtoC(MHL->MHL_DATA) ,;										//04 - Data do Processamento
                                MHL->MHL_HORA       ,;										//05 - Hora do Processamento
                                MHL->MHL_ALIAS      ,;										//06 - Alias do Erro
                                cDescTab            ,;										//07 - Descricao da tabela onde o erro ocorreu
                                MHL->MHL_RECNO      ,;										//08 - Recno do Registro na Tabela Processada
                                MHL->MHL_CODMEN     ,;										//09 - Codigo do Erro (STR)
                                cDescErro           ,;	 									//10 - Mensagem do Erro
                                (cAlias)->RECMHL    ,;										//11 - Recno na tabela MHL
                                0                   ,;										//12 - RECNO da tabela de cabecalho da camada(PIN)
                                0                   ,;										//13 - RECNO da tabela de cabecalho do orcamento (SL1)
                                ""                  ,;										//14 - DOCUMENTO ORIGINAL DA VENDA
                                ""                  ,;										//15 - Serie do Documento
                                ""                  ,;										//16 - Numero de serie do equipamento SAT
                                ""  }               )										//17 - Numero de serie do ECF
                (cAlias)->( dbSkip() )
            End
        
            oLstMnt:SetArray(aLstMnt)
            oLstMnt:Refresh()
        EndIf

    Else

        aLstMnt := {}
        oLstMnt:SetArray(aLstMnt)
        oLstMnt:Refresh()

        If !IsInCallStack("BtReproces")
            MsgInfo(STR0558)    //"Não foram encontrados registros com o filtro selecionado"
        EndIf
    EndIf

    (cAlias)->( dbCloseArea() )

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BtReproces
Botão que chama rotina de reprocessamento de registos manual ou automático

@since 13/08/2019
/*/
//-------------------------------------------------------------------
Static Function BtReproces( lRepMan, oLstMnt, aLstMnt, dDtIni, dDtFim,;
                            aLstInt, cErros , cFilInt)

    Local nI        := 0
    Local nTamArray	:= Len(aLstMnt)

    If nTamArray > 0

        ProcRegua(0)
        IncProc(STR0559)    //"Reprocessando registros. . ."

        If lRepMan

            Reprocessa(aLstMnt[oLstMnt:nAt][PFILIAL], aLstMnt[oLstMnt:nAt][PTAB], aLstMnt[oLstMnt:nAt][PREGIST], aLstMnt[oLstMnt:nAt][PSTATUS], aLstMnt[oLstMnt:nAt][PRECMHL])
        Else

            For nI := 1 to nTamArray
                Reprocessa(aLstMnt[nI][PFILIAL], aLstMnt[nI][PTAB], aLstMnt[nI][PREGIST], aLstMnt[nI][PSTATUS], aLstMnt[nI][PRECMHL])
            Next nI
        EndIf

        BtAtualiza( dDtIni, dDtFim , @oLstMnt, @aLstMnt, aLstInt,;
                    cErros, cFilInt)
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Reprocessa
Deixa o registro apto para o reprocessamento, se existir log na MHL deleta

@since 13/08/2019
/*/
//-------------------------------------------------------------------
Static Function Reprocessa(cFilInt, cTab, nRecTab, cStatus, nRecnoMHL,cFilStatus)

    Local aArea	    := GetArea()
    Local aAreaMHL	:= MHL->( GetArea() )
    Local aAreaSL1	:= SL1->( GetArea() )
    Local cStaImp	:= ""
    Local lRet		:= .T.
     
    Default cFilStatus:= "LX_SITUA"
    
    Begin Transaction

        If cTab == "SL1" .And. nRecTab > 0

            SL1->( dbGoto(nRecTab) )
            If !SL1->( Eof() ) .AND. SL1->L1_SITUA $ "IR|IE|ER"

                cStaImp := IIF( SL1->L1_SITUA == "ER", "RX", "IP")

                RecLock("SL1",.F.)
                    SL1->L1_SITUA := cStaImp
                SL1->( MsUnLock() )
                IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
            EndIf
        Else
        	dbSelectArea(cTab) //Tabela no param do Monitor
            (cTab)->(dbGoTo(nRecTab))
            If !(cTab)->(Eof()) .AND. &(cTab + "->" + cFilStatus) $ "IR|IE|ER" 
	            (cTab)->(RecLock(cTab, .F.))
	            &(cTab + "->" + cFilStatus) := "IP" // RMI processar novamente.
	            (cTab)->(MsUnLock())
	            (cTab)->(DbCommit())
	        EndIf    
        EndIf

        //Posiciona na tabela de LOG para excluir o registro
        If nRecnoMHL > 0 .AND. lRet
            MHL->( DbGoto(nRecnoMHL) )
            If !MHL->( Eof() )
                RecLock("MHL", .F.)
                    MHL->( DbDelete() )
                MHL->( MsUnlock() )
            EndIf
        EndIf

    End Transaction

    RestArea(aAreaMHL)
    RestArea(aAreaSL1)
    RestArea(aArea)    

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SelFiliais
Apresenta tela para seleção de filiais que serão utilizadas na pesquisar
os registros integrados.

@since 14/08/2019
/*/
//-------------------------------------------------------------------
Static Function SelFiliais(cFilInt, oFilial)

    Local aArea     := GetArea()
    Local aAreaSM0  := SM0->( GetArea() )
    Local aLstFil	:= {}

    //Recupera as filiais
    dbSelectArea("SM0")
    SM0->( dbGoTop() )

    While !SM0->( Eof() )
        AAdd(aLstFil, {	IIF( Alltrim(SM0->M0_CODFIL) $ Alltrim(cFilInt), .T., .F.),;
                             Alltrim(SM0->M0_CODFIL)    ,;
                             Alltrim(SM0->M0_FILIAL) }  )
        SM0->( dbSkip() )
    End

    //Ordena pelo Codigo da Filial
    aSort(aLstFil,,, {|x,y| x[2] < y[2]} )

    cFilInt := TelaLista(STR0562, aLstFil)  //"Filiais"

    oFilial:Refresh()

    RestArea(aAreaSM0)
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SelFiliais
Apresenta tela para seleção de erros que serão utilizadas na pesquisar
os registros integrados.

@since 14/08/2019
/*/
//-------------------------------------------------------------------
Static Function SelErros(cErros, oErros)

    Local aLstErr := {}

    //Chama a funcao que retorna todos os erros catalogados
    ListaErros(@aLstErr, cErros)

    //Ordena pelo Codigo do erro
    ASort(aLstErr,,, {|x,y| x[2] < y[2]} )

    cErros := TelaLista(STR0563, aLstErr)   //"Catálogo de Erros"

    oErros:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TelaLista
Tela que apresenta uma lista para seleção.

@since 14/08/2019
/*/
//-------------------------------------------------------------------
Static Function TelaLista(cTitulo, aLista)

    Local cSelecao  := ""        
    Local oLista    := Nil
    Local oDlg      := Nil
    Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
    Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
    Local lOk		:= .F.
    Local nI		:= 0

    DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 500,400 PIXEL

        oLista := TWBrowse():New(003, 003, oDlg:nClientWidth / 2 - 7, oDlg:nClientHeight / 2 - 35,, {" ", STR0564, STR0556},, oDlg,,,,,,,,,,,, .F.,, .T.,, .F.,,,)  //"Código"  "Descrição"
        oLista:SetArray(aLista)
        oLista:bLine := {||  {	IIF(aLista[oLista:nAt][1], oOk, oNo),;
                                    aLista[oLista:nAt][2]           ,;
                                    aLista[oLista:nAt][3] } }
        oLista:bLDblClick  := {|| aLista[oLista:nAt][1] := !aLista[oLista:nAt][1], oDlg:Refresh() }
        TButton():New(oDlg:nClientHeight / 2 - 30, 003, STR0566, oDlg,{|| lOk := .T., oDlg:End()            }, 035, 010,,,, .T.,,,, {|| })  //"Confirmar"
        TButton():New(oDlg:nClientHeight / 2 - 30, 043, STR0567, oDlg,{|| oDlg:End()                        }, 035, 010,,,, .T.,,,, {|| })  //"Cancelar"
        TButton():New(oDlg:nClientHeight / 2 - 30, 083, STR0568, oDlg,{|| AtuLista(@oLista, @aLista, "M")	}, 035, 010,,,, .T.,,,, {|| })  //"Marcar"
        TButton():New(oDlg:nClientHeight / 2 - 30, 123, STR0569, oDlg,{|| AtuLista(@oLista, @aLista, "D")	}, 035, 010,,,, .T.,,,, {|| })  //"Desmarcar"
        TButton():New(oDlg:nClientHeight / 2 - 30, 163, STR0570, oDlg,{|| AtuLista(@oLista, @aLista, "I")	}, 035, 010,,,, .T.,,,, {|| })  //"Inverte"

    ACTIVATE MSDIALOG oDlg CENTERED

    If lOk
        For nI := 1 To Len(aLista)
            cSelecao += IIF(aLista[nI][1], Alltrim(aLista[nI][2]) + ";", "")
        Next nI
    EndIf

Return cSelecao

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuLista
Marca\Desmarca

@since 14/08/2019
/*/
//-------------------------------------------------------------------
Static Function AtuLista(oList, aList, cTipo)

    Local nI   := 0
    Local nCol := 1

    For nI := 1 to Len(aList)
        
        Do Case
            //Marcar Todos    
            Case cTipo == "M"		
                aList[nI][nCol] := .T.
            
            //Desmarcar Todos
            Case cTipo == "D"	
                aList[nI][nCol] := .F.
            
            //Inverte a Selecao de Todos
            OtherWise
                aList[nI][nCol] := !aList[nI][nCol]
        End Case

    Next nI

    oList:Refresh()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ListaErros
Carrega os erros catalogados

@since 14/08/2019
/*/
//-------------------------------------------------------------------
Static Function ListaErros(aLstErr, cErros)

    aLstErr := {}
    AAdd(aLstErr, { IIF("STR0001" $ cErros, .T., .F.), "STR0001", STR0001} )	//"Error Log no processamento automático (MsExecAuto)"
    AAdd(aLstErr, { IIF("STR0002" $ cErros, .T., .F.), "STR0002", STR0002} )	//"Campo obrigatório não preenchido"
    AAdd(aLstErr, { IIF("STR0003" $ cErros, .T., .F.), "STR0003", STR0003} )	//"Chave primária já existente"
    AAdd(aLstErr, { IIF("STR0004" $ cErros, .T., .F.), "STR0004", STR0004} )	//"CNPJ / CPF já existente na base"
    AAdd(aLstErr, { IIF("STR0005" $ cErros, .T., .F.), "STR0005", STR0005} )	//"Campo relacionado não encontrado"
    AAdd(aLstErr, { IIF("STR0006" $ cErros, .T., .F.), "STR0006", STR0006} )	//"Campos incompatíveis tabela integração x padrão"
    AAdd(aLstErr, { IIF("STR0007" $ cErros, .T., .F.), "STR0007", STR0007} )	//"Cod. TES Legado nao existe no Protheus(SF4): "  
    AAdd(aLstErr, { IIF("STR0008" $ cErros, .T., .F.), "STR0008", STR0008} )	//"Codigo Produto Legado não existe no Protheus (SB1): "
    AAdd(aLstErr, { IIF("STR0009" $ cErros, .T., .F.), "STR0009", STR0009} )	//"Codigo do Armazem Legado sem refernecia de De/Para no Protheus (Filial / Produto Origem / Arm. Origem): "
    AAdd(aLstErr, { IIF("STR0010" $ cErros, .T., .F.), "STR0010", STR0010} )	//"Não foi possível criar o Saldos Fisico para Produto/Armazem Protheus(SB2): "
    AAdd(aLstErr, { IIF("STR0011" $ cErros, .T., .F.), "STR0011", STR0011} )	//"Valor do IPI não informado (% IPI / Vlr. IPI): "
    AAdd(aLstErr, { IIF("STR0012" $ cErros, .T., .F.), "STR0012", STR0012} )	//"Percentual do IPI não informado (% IPI / Vlr. IPI): "
    AAdd(aLstErr, { IIF("STR0013" $ cErros, .T., .F.), "STR0013", STR0013} )	//"Valor do ICM não informado (% ICMS / Vlr. ICMS): "
    AAdd(aLstErr, { IIF("STR0014" $ cErros, .T., .F.), "STR0014", STR0014} )	//"Percentual do ICM não informado (% ICMS / Vlr. ICMS): "
    AAdd(aLstErr, { IIF("STR0015" $ cErros, .T., .F.), "STR0015", STR0015} )	//"Registro de Nota Fiscal de Origem Digitada e invalida (NFOrig/SerOrig/ItemOrig): "
    AAdd(aLstErr, { IIF("STR0016" $ cErros, .T., .F.), "STR0016", STR0016} )	//"Registro de Nota Fiscal de Origem Digitada não informado (NFOrig/SerOrig/ItemOrig): "
    AAdd(aLstErr, { IIF("STR0017" $ cErros, .T., .F.), "STR0017", STR0017} )	//"Somatoria dos itens diferente do cabecalho (Cabecalho/Item): "
    AAdd(aLstErr, { IIF("STR0018" $ cErros, .T., .F.), "STR0018", STR0018} )	//"Serie da Nota enviada pelo Legado sem referencia no Protheus(SX5) Tabela 01: "
    AAdd(aLstErr, { IIF("STR0019" $ cErros, .T., .F.), "STR0019", STR0019} )	//"Tipo de NF Invalido:  Tipos Validos (N- Normal, C- Compl. Preços, I- Compl.ICMS, P- Compl.IPI, D- Dev.Compras B- Utiliza Fornecedor): "
    AAdd(aLstErr, { IIF("STR0020" $ cErros, .T., .F.), "STR0020", STR0020} )	//"Codigo do Fornecedor Legado sem referencia De/Para no Protheus(SA2): "
    AAdd(aLstErr, { IIF("STR0021" $ cErros, .T., .F.), "STR0021", STR0021} )	//"Codigo do Cliente Legado sem referencia De/Para no Protheus(SA1): "
    AAdd(aLstErr, { IIF("STR0022" $ cErros, .T., .F.), "STR0022", STR0022} )	//"Codigo da Condicao de Pagamento Legado sem referencia De/Para no Protheus(SE4): "
    AAdd(aLstErr, { IIF("STR0023" $ cErros, .T., .F.), "STR0023", STR0023} )	//"Codigo da Moeda Inválida, não encontrado na tabela SX5: "
    AAdd(aLstErr, { IIF("STR0024" $ cErros, .T., .F.), "STR0024", STR0024} )	//"Mensagem Padrao (Legado) da Nota Fiscal de Saída não cadastrada no Protheus(SM4): "
    AAdd(aLstErr, { IIF("STR0025" $ cErros, .T., .F.), "STR0025", STR0025} )	//"Nao foram encontrados itens para o cabecalho"              
    AAdd(aLstErr, { IIF("STR0026" $ cErros, .T., .F.), "STR0026", STR0026} )	//"Tipo de operação vazio (PIF): "
    AAdd(aLstErr, { IIF("STR0027" $ cErros, .T., .F.), "STR0027", STR0027} )	//"CFOP Informado divergente do cadastrado no Protheus : "               
    AAdd(aLstErr, { IIF("STR0028" $ cErros, .T., .F.), "STR0028", STR0028} )	//"Data emissao da Nota Fiscal menor que a data de fechamento fiscal (MV_DATAFIS): "
    AAdd(aLstErr, { IIF("STR0029" $ cErros, .T., .F.), "STR0029", STR0029} )	//"Data emissao da Nota Fiscal menor que a data de fechamento estoque (MV_ULMES): "
    AAdd(aLstErr, { IIF("STR0030" $ cErros, .T., .F.), "STR0030", STR0030} )	//"Rotina automática não programada no fonte ZEMKM010, tabela "
    AAdd(aLstErr, { IIF("STR0031" $ cErros, .T., .F.), "STR0031", STR0031} )	//"Data de vencimento menor que a data de emissão: "
    AAdd(aLstErr, { IIF("STR0032" $ cErros, .T., .F.), "STR0032", STR0032} )	//"Natureza inválida.: "
    AAdd(aLstErr, { IIF("STR0033" $ cErros, .T., .F.), "STR0033", STR0033} )	//"Campo não encontrado na tabela de integração "
    AAdd(aLstErr, { IIF("STR0034" $ cErros, .T., .F.), "STR0034", STR0034} )	//"Tipo de movimentação bancária inválida (P-Pagar; R-Receber) "
    AAdd(aLstErr, { IIF("STR0035" $ cErros, .T., .F.), "STR0035", STR0035} )	//"Codigo do vendedor Legado sem referencia De/Para no Protheus (SA3): " 
    AAdd(aLstErr, { IIF("STR0036" $ cErros, .T., .F.), "STR0036", STR0036} )	//"Codigo da Estacao Legado sem referencia De/Para no Protheus (SLG): "
    AAdd(aLstErr, { IIF("STR0037" $ cErros, .T., .F.), "STR0037", STR0037} )	//"Codigo do Operador Legado sem referencia De/Para no Protheus (SA6): "
    AAdd(aLstErr, { IIF("STR0038" $ cErros, .T., .F.), "STR0038", STR0038} )	//"Quantidade invalida "
    AAdd(aLstErr, { IIF("STR0039" $ cErros, .T., .F.), "STR0039", STR0039} )	//"Codigo da Administradora sem referencia De/Para no Protheus (SAE)" 
    AAdd(aLstErr, { IIF("STR0040" $ cErros, .T., .F.), "STR0040", STR0040} )	//"Codigo do Municipio sem referencia De/Para no Protheus (CC2)" 
    AAdd(aLstErr, { IIF("STR0041" $ cErros, .T., .F.), "STR0041", STR0041} )	//"Estado e Municipio sem referencia De/Para no Protheus (CC2)" 
    AAdd(aLstErr, { IIF("STR0042" $ cErros, .T., .F.), "STR0042", STR0042} )	//"CNPJ / CPF Inválido"
    AAdd(aLstErr, { IIF("STR0043" $ cErros, .T., .F.), "STR0043", STR0043} )	//"Percentual maior que o Permitido"
    AAdd(aLstErr, { IIF("STR0044" $ cErros, .T., .F.), "STR0044", STR0044} )	//"Inscrição Estadual Inválida"
    AAdd(aLstErr, { IIF("STR0045" $ cErros, .T., .F.), "STR0045", STR0045} )	//"Preço Inválido"
    AAdd(aLstErr, { IIF("STR0046" $ cErros, .T., .F.), "STR0046", STR0046} )	//"Campo Filial em branco inválido, tabela Padrão Protheus Exclusiva."
    AAdd(aLstErr, { IIF("STR0047" $ cErros, .T., .F.), "STR0047", STR0047} )	//"Não foi possível efetuar a Liberação do Pedido. Verifique (SC5, SC6 e SC9): "
    AAdd(aLstErr, { IIF("STR0048" $ cErros, .T., .F.), "STR0048", STR0048} )	//"Não foi possível efetuar a Inclusão da Nota Fiscal de Saída. Verifique (SF2, SD2, SE1, SF3, SFT, CD2), provavelmente ja existe registro em alguma dessas tabelas. Para Reprocessamenteo o campo C9_NFISCAL deve estar em Branco."
    AAdd(aLstErr, { IIF("STR0049" $ cErros, .T., .F.), "STR0049", STR0049} )	//"Valor de Custo(PJ5_VINI1) inválido."
    AAdd(aLstErr, { IIF("STR0050" $ cErros, .T., .F.), "STR0050", STR0050} )	//"Quantidade(PJ5_QINI) inválida."
    AAdd(aLstErr, { IIF("STR0051" $ cErros, .T., .F.), "STR0051", STR0051} )	//"Quantidade(PJ5_QINI) 0 e Valor de Custo inválido."
    AAdd(aLstErr, { IIF("STR0052" $ cErros, .T., .F.), "STR0052", STR0052} )	//"Campo relacionado não encontrado, Linha."
    AAdd(aLstErr, { IIF("STR0053" $ cErros, .T., .F.), "STR0053", STR0053} )	//"Campo relacionado não encontrado, Familia."
    AAdd(aLstErr, { IIF("STR0054" $ cErros, .T., .F.), "STR0054", STR0054} )	//"Campo relacionado não encontrado, Grupo."
    AAdd(aLstErr, { IIF("STR0055" $ cErros, .T., .F.), "STR0055", STR0055} )	//"Campo relacionado não encontrado, SubGrupo."
    AAdd(aLstErr, { IIF("STR0056" $ cErros, .T., .F.), "STR0056", STR0056} )	//"Campo relacionado não encontrado, Cor."
    AAdd(aLstErr, { IIF("STR0057" $ cErros, .T., .F.), "STR0057", STR0057} )	//"Campo relacionado não encontrado, Especificacao."
    AAdd(aLstErr, { IIF("STR0058" $ cErros, .T., .F.), "STR0058", STR0058} )	//"Campo relacionado não encontrado, Capacidade."
    AAdd(aLstErr, { IIF("STR0059" $ cErros, .T., .F.), "STR0059", STR0059} )	//"Titulo já existente na base."
    AAdd(aLstErr, { IIF("STR0060" $ cErros, .T., .F.), "STR0060", STR0060} )	//"Titulo não existente na base."
    AAdd(aLstErr, { IIF("STR0061" $ cErros, .T., .F.), "STR0061", STR0061} )	//"Cliente / Loja informados no titulo, não existente no cadastro (SA1): "
    AAdd(aLstErr, { IIF("STR0062" $ cErros, .T., .F.), "STR0062", STR0062} )	//"Tipo do titulo, não existente no cadastro (SX5 - 05): "
    AAdd(aLstErr, { IIF("STR0063" $ cErros, .T., .F.), "STR0063", STR0063} )	//"Natureza do titulo, não existente no cadastro (SED): "
    AAdd(aLstErr, { IIF("STR0064" $ cErros, .T., .F.), "STR0064", STR0064} )	//"Nao foram encontrados itens para o orçamento - PIO (Itens do cupom fiscal)."
    AAdd(aLstErr, { IIF("STR0065" $ cErros, .T., .F.), "STR0065", STR0065} )	//"Nao foram encontradas formas de pagamento para o orçamento - PIP (Condicao negociada)."
    AAdd(aLstErr, { IIF("STR0066" $ cErros, .T., .F.), "STR0066", STR0066} )	//"Somatoria das formas de pagamento diferente do cabecalho (Cabecalho/Formas Pag): "
    AAdd(aLstErr, { IIF("STR0067" $ cErros, .T., .F.), "STR0067", STR0067} )	//"Conteudo do Campo inválido:"
    AAdd(aLstErr, { IIF("STR0068" $ cErros, .T., .F.), "STR0068", STR0068} )	//"Data de Baixa Invalida: "
    AAdd(aLstErr, { IIF("STR0069" $ cErros, .T., .F.), "STR0069", STR0069} )	//"Ação solicitada não definida na rotina, verifique o campo PJD_ACAO: 1 = Baixa, 3 = Cancelamento de baixa."
    AAdd(aLstErr, { IIF("STR0070" $ cErros, .T., .F.), "STR0070", STR0070} )	//"Titulo com saldo insuficiente para a baixa."
    AAdd(aLstErr, { IIF("STR0071" $ cErros, .T., .F.), "STR0071", STR0071} )	//"Falhou ao identificar o motivo da baixa (CR)."
    AAdd(aLstErr, { IIF("STR0072" $ cErros, .T., .F.), "STR0072", STR0072} )	//"Falhou ao identificar o tipo do titulo (CR)."
    AAdd(aLstErr, { IIF("STR0073" $ cErros, .T., .F.), "STR0073", STR0073} )	//"Não foi encontrado o cupom não fiscal."
    AAdd(aLstErr, { IIF("STR0074" $ cErros, .T., .F.), "STR0074", STR0074} )	//"Reserva não efetuada. Não foi encontrado o orçamento."
    AAdd(aLstErr, { IIF("STR0075" $ cErros, .T., .F.), "STR0075", STR0075} )	//"Não foi encontrado o Orçamento para exclusão: PIN_FILIAL\PIN_Legado "
    AAdd(aLstErr, { IIF("STR0076" $ cErros, .T., .F.), "STR0076", STR0076} )	//"Impossivel gerar número sequencial de orçamento correto. Informe ao administrador do sistema."
    AAdd(aLstErr, { IIF("STR0077" $ cErros, .T., .F.), "STR0077", STR0077} )	//"Codigo do Armazem e Endereço Legado sem referencia de De/Para no Protheus: "
    AAdd(aLstErr, { IIF("STR0078" $ cErros, .T., .F.), "STR0078", STR0078} )	//"Gerente não Informado ou Inválido: "
    AAdd(aLstErr, { IIF("STR0079" $ cErros, .T., .F.), "STR0079", STR0079} )	//"Gerente não Encontrado: "
    AAdd(aLstErr, { IIF("STR0080" $ cErros, .T., .F.), "STR0080", STR0080} )	//"Não foi possível gerar reserva: "
    AAdd(aLstErr, { IIF("STR0081" $ cErros, .T., .F.), "STR0081", STR0081} )	//"Não foi possível excluir reserva: "
    AAdd(aLstErr, { IIF("STR0082" $ cErros, .T., .F.), "STR0082", STR0082} )	//"Chave não encontrada para Alteração\Exclusão: "
    AAdd(aLstErr, { IIF("STR0083" $ cErros, .T., .F.), "STR0083", STR0083} )	//"CPF do Vendedor igual ao CPF do Gerente, PI5_CGC\PI5_XCPFG: "
    AAdd(aLstErr, { IIF("STR0084" $ cErros, .T., .F.), "STR0084", STR0084} )	//"Campo Inválido na Alteração do Codigo Legado: "
    AAdd(aLstErr, { IIF("STR0085" $ cErros, .T., .F.), "STR0085", STR0085} )	//"Chave não encontrada para Alteração do Codigo Legado: "
    AAdd(aLstErr, { IIF("STR0086" $ cErros, .T., .F.), "STR0086", STR0086} )	//"Quantidade Total do Saldo Inicial diferente da Quantidade Endereçada: Total(PJ5_QINI)/Endereçada(PJ6_QINI) "
    AAdd(aLstErr, { IIF("STR0087" $ cErros, .T., .F.), "STR0087", STR0087} )	//"Não foi encontrado Pedido de Venda gerado pelo Loja: "
    AAdd(aLstErr, { IIF("STR0088" $ cErros, .T., .F.), "STR0088", STR0088} )	//"Produto já existente nessa Tabela: Tabela\Produto "
    AAdd(aLstErr, { IIF("STR0089" $ cErros, .T., .F.), "STR0089", STR0089} )	//"Campo BE_CODPRO já preenchido: BE_FILIAL\BE_LOCAL\BE_LOCALIZ "
    AAdd(aLstErr, { IIF("STR0090" $ cErros, .T., .F.), "STR0090", STR0090} )	//"Registro já processado: "
    AAdd(aLstErr, { IIF("STR0091" $ cErros, .T., .F.), "STR0091", STR0091} )	//"Item Contabil e Centro de Custo não encontrado na tabela CTD: "
    AAdd(aLstErr, { IIF("STR0092" $ cErros, .T., .F.), "STR0092", STR0092} )	//"Cupom de Historico, PIN_XTPREG diferente de '3', inválido: PIN_XTPREG\PIO_TES "
    AAdd(aLstErr, { IIF("STR0093" $ cErros, .T., .F.), "STR0093", STR0093} )	//"Produto sem Saldo Endereçado, Produto tem Controla Endereço Ativo: PJ5_COD\B1_LOCALIZ\MV_LOCALIZ "
    AAdd(aLstErr, { IIF("STR0094" $ cErros, .T., .F.), "STR0094", STR0094} )	//"Evento não cadastrado na tabela de eventos (PJK): PJD_XEVENT\PJK_ACAO "
    AAdd(aLstErr, { IIF("STR0095" $ cErros, .T., .F.), "STR0095", STR0095} )	//"Filial de origem não localizada no De\Para do Prefixo (PJL): "
    AAdd(aLstErr, { IIF("STR0096" $ cErros, .T., .F.), "STR0096", STR0096} )	//"Filial do Sistema Legado não pode ter as informações Alteradas via integração. CNPJ "
    AAdd(aLstErr, { IIF("STR0097" $ cErros, .T., .F.), "STR0097", STR0097} )	//"Banco\Agência\Conta, não existente no cadastro (SA6): "
    AAdd(aLstErr, { IIF("STR0098" $ cErros, .T., .F.), "STR0098", STR0098} )	//"Indicador de Filial Inválida: PJ8_FILIAL "
    AAdd(aLstErr, { IIF("STR0099" $ cErros, .T., .F.), "STR0099", STR0099} )	//"Produto não tem controle de endereço, não deve existir PJ6(Saldo por Endereço): PJ5_COD\B1_LOCALIZ "
    AAdd(aLstErr, { IIF("STR0100" $ cErros, .T., .F.), "STR0100", STR0100} )	//"Não foi encontrado o Orçamento, será necessario processa-lo primeiro: PIN_FILIAL\PIN_Legado "
    AAdd(aLstErr, { IIF("STR0101" $ cErros, .T., .F.), "STR0101", STR0101} )	//"Aguardando Processamento do Cupom não Fiscal, pelo GRAVABAT: "
    AAdd(aLstErr, { IIF("STR0102" $ cErros, .T., .F.), "STR0102", STR0102} )	//"Registro encontrado na SL1 não é orçamento, não será excluido: PIN_FILIAL\PIN_Legado - L1_TIPO\L1_SITUA\L1_NUMMOV "
    AAdd(aLstErr, { IIF("STR0103" $ cErros, .T., .F.), "STR0103", STR0103} )	//"Não foi possível gerar a Nota Fiscal sobre o Cupom: "
    AAdd(aLstErr, { IIF("STR0104" $ cErros, .T., .F.), "STR0104", STR0104} )	//"Não foi localizada a Nota Fiscal de Origem para essa essa nota de Conhecimento de Frete: PIE_NFORI\PIE_SERIOR\FORNECEDOR\LOJA "
    AAdd(aLstErr, { IIF("STR0105" $ cErros, .T., .F.), "STR0105", STR0105} )	//"Codigo do Fornecedor Legado sem referencia De/Para no Protheus(SA2) na Nota de Frete(PIE_XCGCOR): "
    AAdd(aLstErr, { IIF("STR0106" $ cErros, .T., .F.), "STR0106", STR0106} )	//"Data de Emissao inválida: "
    AAdd(aLstErr, { IIF("STR0107" $ cErros, .T., .F.), "STR0107", STR0107} )	//"Data de Vencimento inválida: "
    AAdd(aLstErr, { IIF("STR0108" $ cErros, .T., .F.), "STR0108", STR0108} )	//"Valor do Titulo inválido: "
    AAdd(aLstErr, { IIF("STR0109" $ cErros, .T., .F.), "STR0109", STR0109} )	//"Data de vencimento real menor que a data de vencimento: "
    AAdd(aLstErr, { IIF("STR0110" $ cErros, .T., .F.), "STR0110", STR0110} )	//"Nota de Frete: Data de digitação(F1_DTDIGIT) da Nota de Origem, fora do periodo valido: "
    AAdd(aLstErr, { IIF("STR0111" $ cErros, .T., .F.), "STR0111", STR0111} )	//"Empresa\Filial não autorizada: "
    AAdd(aLstErr, { IIF("STR0112" $ cErros, .T., .F.), "STR0112", STR0112} )	//"Nao foi preenchida a Tes de Pedido corretamente favor verificar a tabela SF4: F4_CODIGO\F4_XTESPED "
    AAdd(aLstErr, { IIF("STR0113" $ cErros, .T., .F.), "STR0113", STR0113} )	//"Filial não cadastrada na tabela SLJ Identificação de Lojas: Empresa\Filial "
    AAdd(aLstErr, { IIF("STR0114" $ cErros, .T., .F.), "STR0114", STR0114} )	//"Erro indeterminado na MsExecAuto, rotina MATA103 exclusão de NFE.(nOpc=5). Favor Excluir essa Nota Fiscal manualmente e analisar a mensagem: F1_FILIAL\F1_DOC\F1_SERIE\F1_FORNECE\F1_LOJA\F1_TIPO "
    AAdd(aLstErr, { IIF("STR0115" $ cErros, .T., .F.), "STR0115", STR0115} )	//"Nota de Frete: Valor de Frete incorreto verifique: PIK_FRETE "
    AAdd(aLstErr, { IIF("STR0116" $ cErros, .T., .F.), "STR0116", STR0116} )	//"Aguardando processamento do Cupom Fiscal, verifique a tabela PIN: "
    AAdd(aLstErr, { IIF("STR0117" $ cErros, .T., .F.), "STR0117", STR0117} )	//"O Evento com uma Ação inválida. Verifique a tabela PJK: PJD_XEVENT\PJK_ACAO "
    AAdd(aLstErr, { IIF("STR0118" $ cErros, .T., .F.), "STR0118", STR0118} )	//"O Evento com a Ação de Baixa não foi localizado nessa relação de Baixas. Verifique a tabela PJK. (PJK_ACAO = '1')"
    AAdd(aLstErr, { IIF("STR0119" $ cErros, .T., .F.), "STR0119", STR0119} )	//"Titulo já Baixado: E1_STATUS\E1_SALDO "
    AAdd(aLstErr, { IIF("STR0120" $ cErros, .T., .F.), "STR0120", STR0120} )	//"Registro de Cessao na sequência errada. Deve ser o primeiro. PJD_XEVENT\PJK_CESSAO "
    AAdd(aLstErr, { IIF("STR0121" $ cErros, .T., .F.), "STR0121", STR0121} )	//"Filial de origem não localizada no De\Para do Prefixo (SLG): "
    AAdd(aLstErr, { IIF("STR0122" $ cErros, .T., .F.), "STR0122", STR0122} )	//"Não foi localizado o item na tabela SC9, verifique divergencia entre as tabela SC6\SC9 campos C6_ITEM\C9_ITEM: FILIAL\PEDIDO "
    AAdd(aLstErr, { IIF("STR0123" $ cErros, .T., .F.), "STR0123", STR0123} )	//"Não foi possível gerar Orçamento (SL1): "
    AAdd(aLstErr, { IIF("STR0124" $ cErros, .T., .F.), "STR0124", STR0124} )	//"Erro no retorno do Ponto de Entrada IN210AL1, retornar Array com 2 Posições [nome do campo | conteudo do campo] "
    AAdd(aLstErr, { IIF("STR0125" $ cErros, .T., .F.), "STR0125", STR0125} )	//"Erro no retorno do Ponto de Entrada IN210AL2, retornar Array com 2 Posições [nome do campo | conteudo do campo] "
    AAdd(aLstErr, { IIF("STR0126" $ cErros, .T., .F.), "STR0126", STR0126} )	//"Erro no retorno do Ponto de Entrada IN210AL4, retornar Array com 2 Posições [nome do campo | conteudo do campo] "
    AAdd(aLstErr, { IIF("STR0127" $ cErros, .T., .F.), "STR0127", STR0127} )	//"CFOP da camada diferente do cadastro da TES (SF4): "  
    AAdd(aLstErr, { IIF("STR0128" $ cErros, .T., .F.), "STR0128", STR0128} )	//"TES Inteligente não encontrado: "  
    AAdd(aLstErr, { IIF("STR0129" $ cErros, .T., .F.), "STR0129", STR0129} )	//"[DUPL] Identificado um registro com o mesmo Documento/Serie: "  
    AAdd(aLstErr, { IIF("STR0130" $ cErros, .T., .F.), "STR0130", STR0130} )	//"[DUPL] Identificado um registro com a mesma chave - XCODEX: "  
    AAdd(aLstErr, { IIF("STR0131" $ cErros, .T., .F.), "STR0131", STR0131} )	//"[DUPL] Identificado um registro com o mesmo Documento/Serie em outra filial - Filial Original/DOC/Serie: "  
    AAdd(aLstErr, { IIF("STR0132" $ cErros, .T., .F.), "STR0132", STR0132} )	//"[DUPL] Venda já importada Filial/Doc/Serie/Valor/Emissão NF: "  
    AAdd(aLstErr, { IIF("STR0133" $ cErros, .T., .F.), "STR0133", STR0133} )	//"Série da NFCe enviada é diferente da serie cadastrada no Cadastro de Estação: "
    AAdd(aLstErr, { IIF("STR0134" $ cErros, .T., .F.), "STR0134", STR0134} )	//"Vendas do tipo NFC-e devem ter a serie preenchida na camada"
    AAdd(aLstErr, { IIF("STR0135" $ cErros, .T., .F.), "STR0135", STR0135} )	//"Numero do equipamento SAT divergente entre a Camada e a Estacao: "
    AAdd(aLstErr, { IIF("STR0136" $ cErros, .T., .F.), "STR0136", STR0136} )	//"Numero de Serie da Impressora nao preenchido na Estacao: "
    AAdd(aLstErr, { IIF("STR0137" $ cErros, .T., .F.), "STR0137", STR0137} )	//"Estacao se configuracao definida para NFC-e, SAT ou Cupom Fiscal: "
    AAdd(aLstErr, { IIF("STR0138" $ cErros, .T., .F.), "STR0138", STR0138} )	//"CNPJ da Filial de origem nao cadastrado no Protheus: "
    AAdd(aLstErr, { IIF("STR0139" $ cErros, .T., .F.), "STR0139", STR0139} )	//"CNPJ da Filial de origem diferente do contido na Chave da NFC-e/SAT: "
    AAdd(aLstErr, { IIF("STR0140" $ cErros, .T., .F.), "STR0140", STR0140} )	//"Validacao usuario Ponto de entrada I180INCOK"
    AAdd(aLstErr, { IIF("STR0141" $ cErros, .T., .F.), "STR0141", STR0141} )	//"Validacao usuario Ponto de entrada I180EXCOK"
    AAdd(aLstErr, { IIF("STR0142" $ cErros, .T., .F.), "STR0142", STR0142} )	//"Validacao usuario Ponto de entrada IT250VL"
    
    AAdd(aLstErr, { IIF("STR0200" $ cErros, .T., .F.), "STR0200", STR0200} )	//"Nota Fiscal de Saida não gravada "
    AAdd(aLstErr, { IIF("STR0201" $ cErros, .T., .F.), "STR0201", STR0201} )	//"Item(ns) da Nota Fiscal de Saida não gravado(s) "
    AAdd(aLstErr, { IIF("STR0202" $ cErros, .T., .F.), "STR0202", STR0202} )	//"Validacao Usuario Ponto de entrada IN150SF2, não retornou conforme especificação do mesmo "
    AAdd(aLstErr, { IIF("STR0203" $ cErros, .T., .F.), "STR0203", STR0203} )	//"Nota Fiscal possui Status Devolução ao qual deve ser preenchido NF de Origem, Série e Item de Origem na PIF ex. Nota Fiscal de Devolução, verificar PIF_NFORI, PIF_SERIOR, PIF_ITEMORI  "

    AAdd(aLstErr, { IIF("STR0400" $ cErros, .T., .F.), "STR0400", STR0400} )	//"Não foi possivel encontrar a estacao pela busca por Filial/PDV: "
    AAdd(aLstErr, { IIF("STR0401" $ cErros, .T., .F.), "STR0401", STR0401} )	//"Nota Fiscal referente ao registro de cancelamento ja esta cancelada - Filial/Documento/Serie: "
    AAdd(aLstErr, { IIF("STR0402" $ cErros, .T., .F.), "STR0402", STR0402} )	//"Nao foi encontrado o registro de venda na camada para realizar o cancelamento - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0403" $ cErros, .T., .F.), "STR0403", STR0403} )	//"Venda nao processada pela camada - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0404" $ cErros, .T., .F.), "STR0404", STR0404} )	//"Venda com erro na camada - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0405" $ cErros, .T., .F.), "STR0405", STR0405} )	//"Venda nao processada pelo ERP - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0406" $ cErros, .T., .F.), "STR0406", STR0406} )	//"Venda processada pelo ERP, mas com erro - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0407" $ cErros, .T., .F.), "STR0407", STR0407} )	//"Venda com o processado de Cancelamento iniciado por outro registro - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0408" $ cErros, .T., .F.), "STR0408", STR0408} )	//"Nao foi encontrado o Orcamento no ERP (SL1/SL2/SL4) - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0409" $ cErros, .T., .F.), "STR0409", STR0409} )	//"Orcamento no ERP (SL1/SL2/SL4) ja cancelado - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0410" $ cErros, .T., .F.), "STR0410", STR0410} )	//"Processo de Venda ainda nao Finalizado - Filial/XCODEX: "
    AAdd(aLstErr, { IIF("STR0411" $ cErros, .T., .F.), "STR0411", STR0411} )	//"Venda processada pelo ERP, mas com erro - Filial/XCODEX: "

    AAdd(aLstErr, { IIF("STR0999" $ cErros, .T., .F.), "STR0999", STR0999} )	//"Divergencia nas Tabelas Relacionadas."

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BtExporta
Exporta resultado do grid para excel

@since 15/08/2019
/*/
//-------------------------------------------------------------------
Static Function BtExporta(aLstMnt, aCabMnt)

    Local aPergs := {}
    Local aRet	 := {}
    Local cFile	 := ""

    aAdd(aPergs, {6, STR0571, Space(50), "", "", "", 80, .T., I18n(STR0572, {" .XML |*.XML"}), "C:\", nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY)} )    //"Diretório"  //"Arquivos"

    If ParamBox(aPergs, STR0573, @aRet, , , .T., 130, 30, , , .F., .F.)     //"Exportação de Dados"
        cFile := Alltrim(aRet[1]) + "MONITOR_" + DtoS( Date() ) + StrTran( Time(), ":", "") + ".XML"
        Processa( {||Exporta(aLstMnt, cFile, aCabMnt) } )
        //abertura no Excel. 
        //Processa( {||DlgToExcel({{"ARRAY",cFile,aCabMnt,aLstMnt} })} )
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Exporta
Gera arquivo no formado para Xml formatado para Excel

@since 15/08/2019
/*/
//-------------------------------------------------------------------
Static Function Exporta(aLstMnt, cFile, aCabMnt)

    Local oExcel	 := FWMsExcelEx():New()
    Local cWorkSheet := STR0573 //"Exportação de Dados"
    Local cAglutina  := STR0546 //"Monitor de Integração"
    Local nI		 := 0
    Local nZ		 := 0
    Local nTamLin	 := Len(aCabMnt)
    Local aRow		 := {}
    Local lBackColor := .T.

    If Len(aLstMnt) == 0
        MsgInfo(STR0574)    //"Não existem registros para serem exportados"
        Return Nil
    EndIf

    ProcRegua(0)
    IncProc(STR0556)    //"Selecionando registros. . ."

    oExcel:AddworkSheet(cWorkSheet)
    oExcel:AddTable (cWorkSheet, cAglutina)

    //Inicia na sequencia 2, pois a primeira é a legenda
    For nI := 2 to Len(aCabMnt)
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³AddColumn(cWorkSheet,cTable,cColumn,nAlign,nFormat,lTotal)                                   ³
        //³Nome			Tipo		Descrição                                                           ³
        //³cWorkSheet	Caracteres	Nome da planilha                                                    ³
        //³cTable		Caracteres	Nome da tabela                                                      ³
        //³cColumn		Caracteres	Titulo da tabela que será adicionada                                ³
        //³nAlign		Numérico	Alinhamento da coluna ( 1-Left,2-Center,3-Right )                   ³
        //³nFormat		Numérico	Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime)   ³
        //³lTotal		Lógico		Indica se a coluna deve ser totalizada                              ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        oExcel:AddColumn(cWorkSheet, cAglutina, aCabMnt[nI], 1, 1)
    Next nI

    For nI := 1 to Len(aLstMnt)
        //Variavel de tratamento para diferenciar as cores de fundo 
        lBackColor := !lBackColor
        
        //Variavel de tratamento da montagem da linha
        aRow 		:= {}
        
        For nZ	:= 2 to nTamLin
            aAdd(aRow, aLstMnt[nI][nZ])
        Next nZ

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³FWMsExcelEx():AddRow(< cWorkSheet >, < cTable >, < aRow >,< aCelStyle >)-> NIL                       ³
        //³Nome		Tipo				Descrição                                                               ³
        //³cWorkSheet	Caracteres			Nome da planilha                                                    ³
        //³cTable		Caracteres			Nome da tabela                                                      ³
        //³aRow		Array of Records	Array com as informações da linha da linha                              ³
        //³aCelStyle	Array of Records	Array com as posições das colunas que receberão o estilo específicos³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        oExcel:AddRow(cWorkSheet, cAglutina, aRow)
    Next nI

    oExcel:Activate()

    IncProc(STR0575)    //"Salvando arquivo. . ."
    oExcel:GetXMLFile(cFile)

    MsgInfo(STR0576)    //"Arquivo gerado corretamente!"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Legenda
Apresenta legenda

@since 15/08/2019
/*/
//-------------------------------------------------------------------
Static Function BtLegenda()
    
    Local aLegs := {}

    AAdd(aLegs, {"BR_BRANCO"	, STR0577   })  //"Integração à Processar"
    AAdd(aLegs, {"BR_AMARELO"	, STR0578   })  //"Erro por Dependência"
    AAdd(aLegs, {"BR_VERMELHO"	, STR0579	})  //"Integração com Erro"
    AAdd(aLegs, {"BR_AZUL"		, STR0580   })  //"ERP com Erro"

    BrwLegenda(STR0546, STR0554, aLegs)     //"Monitor de Integração"    //"Legenda"

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} BtVisAcumu
Botão que chama rotina que prepara reprocessamento de registos manual ou automático

@since 15/08/2019
/*/
//-------------------------------------------------------------------
Static Function BtVisAcumu(cFilInt, dDtIni, dDtFim, aLstInt)

    Local oLayer	:= FWLayer():New()
    Local oDlg      := Nil
    Local oPnUp     := Nil
    Local oPnDown   := Nil
    Local oBrowse   := Nil
    Local oColumn   := Nil
    Local aButtons  := {}										//Array contendo os botoes da janela principal
    Local aCoors	:= MsAdvSize()								//Busca o tamanho da tela
    Local aBrwVis	:= {}										//Array contendo os dados a serem apresentados na tela
    Local oTFont	:= TFont():New('Lucida Sans', , 16, .T.)    //Objeto da Fonte
    Local oSayTotal := Nil
    Local cSayTotal := ""
    Local cTab		:= ""

    cTab := IntegraSel(aLstInt)[2] 
    If !cTab $ "SL1"

        Aviso(STR0581, STR0582)     //"Visão Acumulada"     //"Esta opção esta disponível apenas para integração de Cupom Fiscal"
    Else

        ProcRegua(0)
        IncProc(STR0556)    //"Selecionando registros. . ."

        //Chama a funcao que monta o ARRAY
        QueryAcumu(@cSayTotal, @aBrwVis, cFilInt, dDtIni, dDtFim,cTab)

        /*==================================================================\
        |					Elementos do ARRAY aBrwVis						|
        |-------------------------------------------------------------------|
        |aBrwVis[01] - Status												|
        |aBrwVis[02] - Filial												|
        |aBrwVis[03] - Descricao da Filial									|
        |aBrwVis[04] - Total Venda											|
        |aBrwVis[05] - Total Erros											|
        |aBrwVis[06] - Total a Processar									|
        |aBrwVis[07] - Total Venda na Camada								|
        |aBrwVis[08] - Total Erros na Camada								|
        |aBrwVis[09] - Total a Processar na Camada							|
        |aBrwVis[10] - Total Venda na Integracao ERP						|
        |aBrwVis[11] - Total Erros na Integracao ERP						|
        |aBrwVis[12] - Total a Processar na Integracao ERP					|
        |aBrwVis[13] - ARRAY contendo as informacoes abertas por Loja/Caixa|
        \==================================================================*/
        If Len(aBrwVis) > 0

            DEFINE MSDIALOG oDlg TITLE STR0581 FROM aCoors[7],aCoors[1] TO aCoors[6],aCoors[5] PIXEL     //"Visão Acumulada"     

                oLayer:Init(oDlg,.F.)
                oLayer:oPanel:Align := CONTROL_ALIGN_ALLCLIENT
                
                oLayer:AddLine('UP'    , 080, .F.)
                oLayer:AddLine('DOWN'  , 015, .F.)
                
                oPnUp   := oLayer:GetLinePanel('UP'	 )
                oPnDown := oLayer:GetLinePanel('DOWN')
                
                //Monta o FWBrowse com os totalizadoes
                DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aBrwVis LINE BEGIN 1 NO LOCATE NO CONFIG NO SEEK NO REPORT OF oPnUp 

                    ADD STATUSCOLUMN oColumn    DATA { || aBrwVis[oBrowse:At()][01] } DOUBLECLICK { |oBrowse|  } OF oBrowse
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][02] } TITLE STR0500 TYPE "C" SIZE 04 ID "FILIAL"  OF oBrowse    //"Filial"
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][03] } TITLE STR0556 TYPE "C" SIZE 20 ID "DESCRI"  OF oBrowse    //"Descrição"
                    
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][04] } TITLE STR0583 TYPE "N" SIZE 05 ID "TOT_VND" OF oBrowse    //"Total Venda"
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][05] } TITLE STR0584 TYPE "N" SIZE 05 ID "TOT_ER"  OF oBrowse    //"Total Erros"
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][06] } TITLE STR0585 TYPE "N" SIZE 10 ID "TOT_PRC" OF oBrowse    //"Total a Processar"
                    
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][07] } TITLE STR0586	TYPE "N" SIZE 10 ID "CAM_VND" OF oBrowse    //"Tot. Venda (Camada)"
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][08] } TITLE STR0587	TYPE "N" SIZE 10 ID "CAM_ER"  OF oBrowse    //"Tot. Erros (Camada)"
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][09] } TITLE STR0588	TYPE "N" SIZE 10 ID "CAM_PRC" OF oBrowse    //"Tot. A Proc (Camada)"
                    
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][10] } TITLE STR0589	TYPE "N" SIZE 10 ID "ERP_VND" OF oBrowse    //"Tot. Venda (ERP)"
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][11] } TITLE STR0590	TYPE "N" SIZE 10 ID "ERP_ER"  OF oBrowse    //"Tot. Erros (ERP)"
                    ADD COLUMN oColumn          DATA { || aBrwVis[oBrowse:At()][12] } TITLE STR0591 TYPE "N" SIZE 10 ID "ERP_PRC" OF oBrowse    //"Tot. A Proc (ERP)"
                    
                ACTIVATE FWBROWSE oBrowse

                oSayTotal := TSay():New(10, 05, {|| "<H1>" + cSayTotal + "</H1>"}, oPnDown, , oTFont,,,, .T., CLR_HBLUE, CLR_WHITE, 0, 0,,,,,, .T.)
                
            ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() },, aButtons)
        EndIf

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} QueryAcumu
Carrega grig com informações acumuladas do cupom

@since 15/08/2019
/*/
//-------------------------------------------------------------------
Static Function QueryAcumu(cSayTotal, aBrwVis, cFilInt, dDtIni, dDtFim,cTab)

    Local cQry		:= ""										//Variavel Auxiliar para montar a QUERY
    Local cAlias	:= GetNextAlias()							//Busca o proximo Alias disponivel
    Local aArea	    := GetArea()								//Salva a Area Atual
    Local cStatus	:= ""										//Status do processamento da Filial
    Local cFilAtu	:= ""										//Codigo da Filial que esta sendo tratada
    Local cNomeFil	:= ""										//Nome da Filial
    Local nQtdTot	:= 0										//Quantidade Total de Venda
    Local nQtdEr	:= 0										//Quantidade Total de Erros
    Local nQtdAProc := 0										//Quantidade Total de Vendas a Processar
    Local nQCamTot	:= 0										//Quantidade Total de Venda na Camada
    Local nQCamEr	:= 0										//Quantidade Total de Erros na Camada
    Local nQCamProc := 0										//Quantidade Total de Vendas a Processar na Camada
    Local nQLjTot	:= 0										//Quantidade Total de Venda na Integracao ERP
    Local nQljEr	:= 0										//Quantidade Total de Erros na Integracao ERP
    Local nQLjProc	:= 0										//Quantidade Total de Vendas a Processar na Integracao ERP
    Local nQGTot	:= 0
    Local nQGEr	    := 0
    Local nQGAProc	:= 0
    
    Default cTab := 'SL1'

    If cTab == 'SL1'
	    cQry += " SELECT L1_FILIAL FILIAL, L1_SITUA SITUA, COUNT(1) REG"
	    cQry += " FROM " + RetSqlName("SL1")+" SL1 "
	    cQry += " WHERE SL1.D_E_L_E_T_ = ' '"
	    cQry +=     IIF( !Empty(cFilInt), " AND L1_FILIAL IN ('" + StrTran(cFilInt, ";", "','") + "') ", "")
	    cQry +=     " AND L1_EMISSAO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
	    cQry += " GROUP BY L1_FILIAL, L1_SITUA"
    
    Else
	    cQry += " SELECT LX_FILIAL FILIAL, LX_SITUA SITUA, COUNT(1) REG"
	    cQry += " FROM " + RetSqlName("SLX")+" SLX "
	    cQry += " WHERE SLX.D_E_L_E_T_ = ' '"
	    cQry += IIF( !Empty(cFilInt), " AND LX_FILIAL IN ('" + StrTran(cFilInt, ";", "','") + "') ", "")
	    cQry +=     " AND SLX.LX_DTMOVTO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
	    cQry += " GROUP BY LX_FILIAL, LX_SITUA"
    EndIf
    cQry += " ORDER BY 1, 2 "
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias, .T., .F.)

    If !(cAlias)->( Eof() )

        While !(cAlias)->( Eof() )

            If Alltrim(cFilAtu) <> Alltrim( (cAlias)->FILIAL )
                cFilAtu	    := (cAlias)->FILIAL
                cNomeFil    := Alltrim(FWFilialName(cEmpAnt,(cAlias)->FILIAL))
                nQtdTot	    := 0
                nQtdEr		:= 0
                nQtdAProc	:= 0
                nQCamTot	:= 0
                nQCamEr	    := 0
                nQCamProc	:= 0
                nQLjTot	    := 0
                nQljEr		:= 0
                nQLjProc	:= 0
            EndIf

            Do Case

                Case (cAlias)->SITUA $ "IR|IE"
                    nQCamTot    += (cAlias)->REG
                    nQCamEr     += (cAlias)->REG

                Case (cAlias)->SITUA == "IP"
                    nQCamTot    += (cAlias)->REG
                    nQCamProc   += (cAlias)->REG

                Case (cAlias)->SITUA == "ER"
                    nQLjTot	    += (cAlias)->REG
                    nQljEr      += (cAlias)->REG
                
                Case (cAlias)->SITUA == "RX"
                    nQLjTot	    += (cAlias)->REG            
                    nQLjProc    += (cAlias)->REG
            End Case
            
            (cAlias)->( dbSkip() )
            
            If (cAlias)->( Eof() ) .Or. Alltrim(cFilAtu) <> Alltrim( (cAlias)->FILIAL )

                //Alimanta a variavel para total geral por filial
                nQtdTot 	:= nQCamTot    + nQLjTot
                nQtdEr		:= nQCamEr     + nQljEr
                nQtdAProc	:= nQCamProc   + nQLjProc

                nQGTot		+= nQtdTot
                nQGEr		+= nQtdEr
                nQGAProc	+= nQtdAProc
                
                //Tratra o status 
                cStatus	:= IIF(nQtdEr > 0, "BR_VERMELHO", IIF(nQtdAProc > 0, "BR_AMARELO", "BR_VERDE") )
                
                //Adiciono no Array
                Aadd(aBrwVis,{	cStatus	 , cFilAtu  , cNomeFil  , nQtdTot   ,;
                                nQtdEr   , nQtdAProc, nQCamTot  , nQCamEr	,;
                                nQCamProc, nQLjTot	, nQljEr    , nQLjProc	}   )
            EndIf
        End

        cSayTotal := I18n(STR0592, { cValToChar(nQGTot)  ,;
                                     cValToChar(nQGEr)   ,;
                                     cValToChar(nQGAProc)})     //"Total Geral: #1 - Total de Erros: #2 - Total a Processar: #3"
    EndIf

    (cAlias)->( dbCloseArea() )

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegraSel
Retorna a tabela principal da integração selecionada

@since 15/08/2019
/*/
//-------------------------------------------------------------------
Static Function IntegraSel(aLstInt)

    Local nPos     := aScan(aLstInt, {|x| x[1]})
    Local aRetorno := {"", "", ""}

    If nPos > 0 
        aRetorno[1] := aLstInt[nPos][2]
        aRetorno[2] := aLstInt[nPos][3]
        aRetorno[3] := aLstInt[nPos][4]
    EndIf

Return aRetorno