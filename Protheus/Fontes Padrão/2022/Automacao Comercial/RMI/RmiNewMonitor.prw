#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMINEWMONI.CH"
#INCLUDE "FWBROWSE.CH"  

//Posicao do aLstMnt
#DEFINE PLEG		1			//Legenda - Vermelho = Erro | Amarelo = Erro por dependencia de outro cadastro | Azul = Erro de Integracacao com o ERP
#DEFINE PASSIN		2			//Assinantes
#DEFINE PROCES		3			//Processos
#DEFINE PETAPA		4			//Etapa
#DEFINE PDPROC		5			//Pendente de Processamento
#DEFINE PROCEOK		6			//Processado
#DEFINE PROERRO		7			//Erro
#DEFINE PREPROC     8           //Aguardando Reprocessamento
#DEFINE PCONFIR     9           //Aguardando Confirmação
#DEFINE PORIGEM     10          //Origem

//Posicao do aLstMnt2
#DEFINE CETAPA      2
#DEFINE CALIAS		3			//Assinantes
#DEFINE CDATA		4			//Etapa
#DEFINE HORA		5			//Processos
#DEFINE ERROR		6			//Pendente de Processamento
#DEFINE CHAVE		7			//Tabela Processada
#DEFINE MSGORI      8           //Mensagem Origem
#DEFINE MSGPUB      9           //Mensagem Publicada
#DEFINE UIDORI      10          //Id Origem - MHL_UIDORI

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiNewMoni
Monitor de integração utilizado para apresentação das inconsistencias
apresentadas nas tabelas MHQ, MHR, SL1 e SLX

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiNewMoni()

    //Variaveis da Tela Main
    Local oLayer    := Nil
    Local aButtons 	:= {}
    Local oDlg      := Nil
    Local aCoors    := {} 
    Local oPnUp     := Nil
    Local oPnCenter := Nil
    Local oPnDown   := Nil
    Local oPnbotao  := Nil
    Local oPnColR   := Nil
    Local oPnColD   := Nil
    Local oPnColC   := Nil
    Local oPnColB   := Nil
    Local oColumn   := Nil
    Local oFont     := Nil
    Local oSay      := Nil

    //Variaveis dos GET
    Local oDtIni    := Nil
    Local oDtFim    := Nil
    Local dDtIni    := dDataBase
    Local dDtFim    := dDataBase
    Local oAssinante := Nil
    Local cAssinante := Space( TamSx3("MHO_COD")[1] )
    Local oProcesso  := Nil
    Local cProcesso  := Space( TamSx3("MHN_COD")[1] )

    //Variaveis do List dos Itens Consultados
    Local oLstMnt   := Nil
    Local aLstMnt	:= {}
    Local aCabMnt	:= {" ",STR0001, STR0003, STR0002, STR0004, STR0005, STR0006, STR0027, STR0037, STR0046} //"Assinantes", "Processos", "Etapa", "Pendente Processamento", "Processado", "Erro", "Aguardando Reprocessamento", "Aguardando Confirmação", "Origem"
    Local bDblClick := { |oLstMnt| Processa( {| | GeraTitulo(oLstMnt, aLstMnt, "", oSay), aLstMnt2 := RmiAtuErro(dDtIni, dDtFim, aLstMnt, oLstMnt), oLstMnt2:SetArray(aLstMnt2), oLstMnt2:Refresh()} ) }
    Local bChangeMnt:= { |oLstMnt| oSay:SetText(""), oSay:CtrlRefresh(), oLstMnt2:SetArray( {} ), oLstMnt2:Refresh() }
    
    //Variaveis do List dos Itens detalhes Consultados
    Local oLstMnt2  := Nil
    Local aLstMnt2	:= {}
    Local aCabMnt2	:= {" ", STR0002, STR0018, STR0019, STR0020, STR0021, STR0023, STR0033, STR0034} //" ", "Etapa", "Tabela", "Data Processamento", "Hora Processamento", "Descrição do Erro", "Chave de Busca", "Msg. Recebida", "Msg. Publicada"

    If ValTables()

        oLayer := FWLayer():new()
        aCoors := MsAdvSize() 

        DEFINE MSDIALOG oDlg TITLE STR0011 FROM aCoors[7],aCoors[1] TO aCoors[6],aCoors[5] PIXEL    //"Monitor de Integração"

        oLayer:Init(oDlg,.F.)
        oLayer:oPanel:Align := CONTROL_ALIGN_ALLCLIENT
        
        oLayer:AddLine('UP'    , 010, .F.)
        oLayer:AddLine('CENTER', 035, .F.)
        oLayer:AddLine('BOTAO', 05, .F.)
        oLayer:AddLine('DOWN', 043, .F.)
        
        oLayer:addCollumn('RIGHT' , 100, .F., 'UP')
        oLayer:addCollumn('CENTER', 40 , .F., 'UP')
        oLayer:addCollumn('BOTAO' , 05 , .F., 'CENTER')
        oLayer:addCollumn('DOWN'  , 40 , .F., 'BOTAO')
        
        oPnUp	    := oLayer:GetLinePanel('UP'	    )
        oPnCenter	:= oLayer:GetLinePanel('CENTER' )
        oPnbotao	:= oLayer:GetLinePanel('BOTAO' )
        oPnDown     := oLayer:GetLinePanel('DOWN' )
        
        oPnColR:= oLayer:GetColPanel('RIGHT' , 'UP')
        oPnColC:= oLayer:GetColPanel('CENTER', 'UP')
        oPnColB:= oLayer:GetColPanel('BOTAO' , 'CENTER')
        oPnColD:= oLayer:GetColPanel('DOWN', 'BOTAO')
        
        //Layer Superior
        //"Período:"
        oDtIni	:= tGet():New(004,010,{|u| Iif( PCount() > 0, dDtIni := u, dDtIni)},oPnColR,40,12,"@D",,,,,,,.T.,,,,,,,,,,"dDtIni",,,,,,, STR0012, 1)
                        
        //"a"
        oDtFim	:= tGet():New(011,052,{|u| Iif( PCount() > 0, dDtFim := u, dDtFim)},oPnColR,40,12,"@D",,,,,,,.T.,,,,,,,,,,"dDtFim",,,,,,, "a  "  , 2)

        //"Assinante:"
        //oAssinante     := tGet():New(005, 116, bSetGet(cAssinante), oPnColR, 60, 11, "@!", {|| Empty(cAssinante) .Or. ExistCpo("MHO", cAssinante)},,,,,,.T.,,,,,,,,,, cAssinante,,,,,,, STR0044, 1)
        //oAssinante:cF3 := "MHO"

        //"Processo:"
        oProcesso     := tGet():New(005, 116, bSetGet(cProcesso), oPnColR, 60, 11, "@!", {|| Empty(cProcesso) .Or. ExistCpo("MHN", cProcesso)},,,,,,.T.,,,,,,,,,, cProcesso,,,,,,, STR0045, 1)
        oProcesso:cF3 := "MHN"
        
        //"Pesquisar"
        TButton():New( 012, 195, STR0014,oPnColR,{|| Processa( {|| oLstMnt2:SetArray(aLstMnt2:={}),oLstMnt2:Refresh(),aLstMnt := RmiConGeral(dDtIni, dDtFim, cAssinante, cProcesso), oLstMnt:SetArray(aLstMnt), oLstMnt:Refresh() } ) }, 40,13,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Pesquisa"

        aAdd(aButtons, {"USER", {|| Processa( {|| GeraTitulo(oLstMnt,aLstMnt,"",oSay),aLstMnt := RmiConGeral(dDtIni, dDtFim, cAssinante, cProcesso), oLstMnt:SetArray(aLstMnt), oLstMnt:Refresh() } ) } , STR0016    } ) //"Atualiza"
        aAdd(aButtons, {"USER", {|| IIF(LEN(aLstMnt) > 0 ,Processa( {|| Reprocessa(oLstMnt,aLstMnt,dDtIni,dDtFim),aLstMnt := RmiConGeral(dDtIni, dDtFim, cAssinante, cProcesso), oLstMnt:SetArray(aLstMnt),oLstMnt:Refresh() } ),.T.) } , STR0028  } ) // "Reprocessa"
        aAdd(aButtons, {"USER", {|| BtLegenda()} , STR0015    } ) //"Legenda"

        TButton():New( 001, 005, STR0025, oPnbotao, bDblClick, 60, 13, , , .F., .T., .F., , .F., , , .F.)   //"Detalhe do Erro"
        
        TButton():New( 001, 075, STR0024,oPnbotao,{|| Processa( {||DlgToExcel({{"ARRAY","MONITOR_" + DtoS( Date() ) + StrTran( Time(), ":", ""),aCabMnt2,aLstMnt2} })} ) },;
            60,13,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Exporta Dados"

        oFont := TFont():New('Courier new',,-18,.T.,.T.,,,,,.T.)//define o tamanho do fonte no titulo do detalhe 
        oSay:= TSay():New(002, 275,{|| "" },oPnbotao,,oFont,.F.,.F.,.F.,.T.,,,200,008)//define a posição do texto no detalhe do erro

        //Layer Inferior//FWBrowse(): SetLineOk ( < bLineOk> ) -->
        DEFINE FWBROWSE oLstMnt DATA ARRAY ARRAY aLstMnt LINE BEGIN 1 NO LOCATE NO CONFIG NO SEEK NO REPORT OF oPnCenter 
            ADD STATUSCOLUMN    oColumn DATA { || aLstMnt[oLstMnt:At()][PLEG   ] } DOUBLECLICK { |oLstMnt2|BtLegenda() } OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PASSIN ] } DOUBLECLICK bDblClick TITLE aCabMnt[PASSIN]  TYPE "C" ALIGN 1 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PROCES ] } DOUBLECLICK bDblClick TITLE aCabMnt[PROCES]  TYPE "C" ALIGN 1 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PETAPA ] } DOUBLECLICK bDblClick TITLE aCabMnt[PETAPA]  TYPE "C" ALIGN 1 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PDPROC ] } DOUBLECLICK bDblClick TITLE aCabMnt[PDPROC]  TYPE "N" ALIGN 0 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PROCEOK] } DOUBLECLICK bDblClick TITLE aCabMnt[PROCEOK]	TYPE "N" ALIGN 0 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PROERRO] } DOUBLECLICK bDblClick TITLE aCabMnt[PROERRO] TYPE "N" ALIGN 0 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PREPROC] } DOUBLECLICK bDblClick TITLE aCabMnt[PREPROC]	TYPE "N" ALIGN 0 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PCONFIR] } DOUBLECLICK bDblClick TITLE aCabMnt[PCONFIR]	TYPE "N" ALIGN 0 SIZE 11 OF oLstMnt
            ADD COLUMN          oColumn DATA { || aLstMnt[oLstMnt:At()][PORIGEM] } DOUBLECLICK bDblClick TITLE aCabMnt[PORIGEM]	TYPE "C" ALIGN 1 SIZE 11 OF oLstMnt
        ACTIVATE FWBROWSE oLstMnt
        oLstMnt:bChange := bChangeMnt
		        
        DEFINE FWBROWSE oLstMnt2 DATA ARRAY ARRAY aLstMnt2 LINE BEGIN 1 NO LOCATE NO CONFIG NO SEEK NO REPORT OF oPnDown 
            ADD STATUSCOLUMN    oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][PLEG	 ] } DOUBLECLICK { |oLstMnt2|BtLegenda() } OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][CETAPA] } TITLE aCabMnt2[CETAPA] TYPE "C" ALIGN 1 SIZE 12 OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][CALIAS] } TITLE aCabMnt2[CALIAS] TYPE "C" ALIGN 0 SIZE 10 OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][CDATA ] } TITLE aCabMnt2[CDATA ] TYPE "D" ALIGN 0 SIZE 10 OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][HORA	 ] } TITLE aCabMnt2[HORA  ] TYPE "C" ALIGN 0 SIZE 10 OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][ERROR ] } TITLE aCabMnt2[ERROR ] TYPE "C" ALIGN 1 SIZE 20 DOUBLECLICK { |oLstMnt2|/*CampoMemo(aLstMnt2[oLstMnt2:At()][ERROR ])*/ }  OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][CHAVE ] } TITLE aCabMnt2[CHAVE ] TYPE "C" ALIGN 1 SIZE 20 OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][MSGORI] } TITLE aCabMnt2[MSGORI]	TYPE "C" ALIGN 1 SIZE 20 DOUBLECLICK { |oLstMnt2| }  OF oLstMnt2
            ADD COLUMN          oColumn2 DATA { || aLstMnt2[oLstMnt2:At()][MSGPUB] } TITLE aCabMnt2[MSGPUB]	TYPE "C" ALIGN 1 SIZE 20 DOUBLECLICK { |oLstMnt2| }  OF oLstMnt2
        ACTIVATE FWBROWSE oLstMnt2

        ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() }, .F., aButtons, /*nRecno*/, /*cAlias*/, .F., .F., .F., .F., .F., "RmiMonitor")

        FwFreeObj(aButtons)
        FwFreeObj(aCoors )
        FwFreeObj(aLstMnt)
        FwFreeObj(aCabMnt)
        FwFreeObj(aLstMnt2)
        FwFreeObj(aCabMnt2)
        FwFreeObj(oDlg   )
    EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IntAtiva
Adiciona os botoes a outras ações e habilita as integrações

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValTables()

    Local lRet      := .T.
    Local lTabelas  := FwAliasInDic("MHQ") .And. FwAliasInDic("MHR") .And. FwAliasInDic("MHL")
    Local lCampos   :=  MHL->( ColumnPos("MHL_UIDORI") ) > 0 .And.;
                        MHQ->( ColumnPos("MHQ_UUID"  ) ) > 0 .And.;
                        MHR->( ColumnPos("MHR_UIDMHQ") ) > 0 .And.;
                        SLX->( ColumnPos("LX_UUID"   ) ) > 0

    //Acesso apenas para modulo e licença do Varejo
    If !AmIIn(12)
        LjxjMsgErr(STR0026)             //"Esta rotina deve ser executada somente pelo módulo 12 (Controle de Lojas)"
        lRet := .F.

    ElseIf !lTabelas .Or. !lCampos
        LjxjMsgErr(STR0017, STR0043)    //"Dicionário de dados desatualizado."  //"Aplique o pacote de Expedição Contínua - Varejo"
        lRet := .F.
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BtLegenda
Add a legenda aos itens do grid consolidado das informações de
publicação, distribuição, gravabatch e cancelamento

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BtLegenda()
    
    Local aLegs := {}

    AAdd(aLegs, {"BR_VERMELHO"	, STR0008	})  //"Com erro(s)"
    AAdd(aLegs, {"BR_VERDE"		, STR0009   })  //"Sem erro(s)"
    AAdd(aLegs, {"BR_AMARELO"   , STR0027   })  //"Aguardando Reprocessamento"
    AAdd(aLegs, {"BR_PINK"      , STR0038   })  //"Aguardando Processamento de Retorno TOTVS Live"

    BrwLegenda(STR0011, STR0015, aLegs)         //"Monitor de Integração"    //"Legenda"

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiConGeral
Retorna o resultado com todos os registros pendentes e com erros nas tabelas
MHQ e MHR

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiConGeral(dDtIni, dDtFim, cAssinante, cProcesso)

Local cQuery    := ""   //Armazena a query
Local cTabela   := ""   //Proxima tabela temporaria
Local aLstMnt   := {}   //Array para retorno da função
Local nX        := 1    //Variavel de loop
Local cStatus 	:= ""
Local nTotal  	:= 0
Local nPos    	:= 0

Default dDtIni := Date()
Default dDtFim := Date()

cTabela := GetNextAlias()

cQuery := " SELECT ASSINANTE"
cQuery +=       " , PROCESSO"
cQuery +=       " , STATUS"
cQuery +=       " , ETAPA"
cQuery +=       " , SUM(CONTADOR) TOTAL"
cQuery +=       " , ORIGEM"
cQuery += " FROM ("

//Publicação
cQuery +=           " SELECT MHQ_ORIGEM ASSINANTE"
cQuery +=               " , CASE"
cQuery +=                   " WHEN MHQ_CPROCE = '" + PadR("VENDA", TamSx3("MHQ_CPROCE")[1]) + "' AND MHQ_EVENTO = '2' THEN 'CANCELAMENTO'"
cQuery +=                   " ELSE MHQ_CPROCE"
cQuery +=               " END PROCESSO"
cQuery +=               " ,CASE MHQ_STATUS "
cQuery +=                   " WHEN '0' THEN 'PENDENTE' "
cQuery +=                   " WHEN '1' THEN 'PENDENTE' "
cQuery +=                   " WHEN '3' THEN 'COM ERRO' "
cQuery +=                   " WHEN '4' THEN 'REPROCESSAR' "  
cQuery +=               " END STATUS"
cQuery +=               " , 'PUBLICACAO' ETAPA"
cQuery +=               " , COUNT(MHQ_STATUS) CONTADOR"
cQuery +=               " , MHQ_ORIGEM ORIGEM"
cQuery +=           " FROM " + RetSqlName("MHQ") + " MHQ"

cQuery +=           Where("MHQ", dDtIni, dDtFim)

cQuery +=           " GROUP BY MHQ_STATUS"
cQuery +=                  " , MHQ_CPROCE"
cQuery +=                  " , MHQ_EVENTO"
cQuery +=                  " , MHQ_ORIGEM"

cQuery +=           " UNION ALL"

//Distribuição
cQuery +=           " SELECT MHR_CASSIN ASSINANTE"
cQuery +=               " , MHR_CPROCE PROCESSO"
cQuery +=               " , CASE MHR_STATUS "
cQuery +=                   " WHEN '1' THEN 'PENDENTE' "
cQuery +=                   " WHEN '2' THEN 'PROCESSADOS' "
cQuery +=                   " WHEN '3' THEN 'COM ERRO' "      
cQuery +=                   " WHEN '6' THEN 'AGUARDANDO CONFIRMAÇÃO' "      
cQuery +=               " END STATUS"
cQuery +=               " , 'DISTRIBUICAO' ETAPA"
cQuery +=               " , COUNT(MHR_STATUS) CONTADOR"
cQuery +=               " , MHQ_ORIGEM ORIGEM"

cQuery +=           " FROM " + RetSqlName("MHR") + " MHR"
cQuery +=           " INNER JOIN " + RetSqlName("MHQ") + " MHQ ON MHR.MHR_UIDMHQ = MHQ.MHQ_UUID AND MHQ.D_E_L_E_T_ = ' '"

cQuery +=           Where("MHR", dDtIni, dDtFim)

cQuery +=           " GROUP BY MHR_STATUS"
cQuery +=                  " , MHR_CPROCE"
cQuery +=                  " , MHR_CASSIN"
cQuery +=                  " , MHQ_ORIGEM"

cQuery +=           " UNION ALL"

//Venda
cQuery +=           " SELECT 'PROTHEUS' ASSINANTE"
cQuery +=               " , 'VENDA' PROCESSO"
cQuery +=               " , CASE "
cQuery +=                   " WHEN L1_SITUA IN ('IP','RX') THEN 'PENDENTE'"
cQuery +=                   " WHEN L1_SITUA IN ('OK') THEN 'PROCESSADOS'"
cQuery +=                   " ELSE 'COM ERRO'"
cQuery +=               " END STATUS"
cQuery +=               " , 'GRVBATCH' ETAPA"
cQuery +=               " , COUNT(L1_SITUA) CONTADOR"
cQuery +=               " , MHQ_ORIGEM ORIGEM"

cQuery +=           " FROM " + RetSqlName("SL1") + " SL1"
cQuery +=           " INNER JOIN " + RetSqlName("MHQ") + " MHQ ON SL1.L1_UMOV = MHQ.MHQ_UUID AND MHQ.D_E_L_E_T_ = ' '"

cQuery +=           Where("SL1", dDtIni, dDtFim)

cQuery +=           " GROUP BY L1_SITUA"
cQuery +=                  " , MHQ_ORIGEM"

cQuery +=           " UNION ALL"

//Cancelamento
cQuery +=           " SELECT 'PROTHEUS' ASSINANTE"
cQuery +=               " , 'CANCELAMENTO' PROCESSO"
cQuery +=               " , CASE LX_SITUA"
cQuery +=                   " WHEN 'IP' THEN 'PENDENTE'"
cQuery +=                   " WHEN 'OK' THEN 'PROCESSADOS'"
cQuery +=                   " ELSE 'COM ERRO'"
cQuery +=               " END STATUS"
cQuery +=               " , 'GRVBATCH' ETAPA"
cQuery +=               " , COUNT(LX_SITUA) CONTADOR"
cQuery +=               " , MHQ_ORIGEM ORIGEM"

cQuery +=           " FROM " + RetSqlName("SLX") + " SLX"
cQuery +=           " INNER JOIN " + RetSqlName("MHQ") + " MHQ ON SLX.LX_UUID = MHQ.MHQ_UUID AND MHQ.D_E_L_E_T_ = ' '"

cQuery +=           Where("SLX", dDtIni, dDtFim)

cQuery +=           " GROUP BY LX_SITUA"
cQuery +=                  " , MHQ_ORIGEM"

cQuery += " ) TAB"

cQuery += " WHERE 1=1"
If !Empty(cAssinante)
    cQuery += " AND ASSINANTE = '" + cAssinante + "'"
EndIf
If !Empty(cProcesso)
    cQuery += " AND PROCESSO = '" + cProcesso + "'"
EndIf

cQuery += " GROUP BY ASSINANTE"
cQuery +=       " , PROCESSO"
cQuery +=       " , ETAPA"
cQuery +=       " , STATUS"
cQuery +=       " , ORIGEM"
cQuery += " ORDER BY ASSINANTE DESC"    
cQuery +=       " , PROCESSO"
cQuery +=       " , ETAPA"
cQuery +=       " , STATUS"
cQuery +=       " , ORIGEM"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

While !(cTabela)->( Eof() )

    cStatus := AllTrim( (cTabela)->STATUS )
    nTotal  := (cTabela)->TOTAL
    nPos    := aScan(aLstMnt, {|x| x[PASSIN] == (cTabela)->ASSINANTE .And. x[PROCES] == (cTabela)->PROCESSO .And. x[PETAPA] == (cTabela)->ETAPA} )

    If nPos == 0
        AAdd(aLstMnt, { ""                  ,;
                        (cTabela)->ASSINANTE,;
                        (cTabela)->PROCESSO ,;
                        (cTabela)->ETAPA    ,;
                        0                   ,;
                        0                   ,;
                        0                   ,;
                        0                   ,;
                        0                   ,;
                        (cTabela)->ORIGEM } )
                        
        nPos := Len(aLstMnt)
    EndIf

    Do Case
        Case cStatus == "PENDENTE"
            aLstMnt[nPos][PDPROC] := nTotal
        Case cStatus == "PROCESSADOS"
            aLstMnt[nPos][PROCEOK] := nTotal
        Case cStatus == "COM ERRO"
            aLstMnt[nPos][PROERRO] := nTotal
        Case cStatus == "REPROCESSAR"
            aLstMnt[nPos][PREPROC] := nTotal
        Case cStatus == "AGUARDANDO CONFIRMAÇÃO"
            aLstMnt[nPos][PCONFIR] := nTotal
    End Case

    (cTabela)->( DbSkip() )
EndDo
(cTabela)->( DbCloseArea() )

//Add legenda, quando não tem erro fica azul e quando tem fica vermelho.
For nX := 1 To Len(aLstMnt)

    If aLstMnt[nX][PROERRO] > 0
        aLstMnt[nX][PLEG] := "BR_VERMELHO"
    ElseIf aLstMnt[nX][PREPROC] > 0
        aLstMnt[nX][PLEG] := "BR_AMARELO"
    ElseIf aLstMnt[nX][PCONFIR] > 0
        aLstMnt[nX][PLEG] := "BR_PINK"    
    Else    
        aLstMnt[nX][PLEG] := "BR_VERDE"    
    EndIf

Next nX

Return aLstMnt

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiAtuErro
Retorna o resultado com todos os registros pendentes e com erros nas tabelas
MHQ e MHR

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiAtuErro(dDtIni, dDtFim,aLstMnt,oLstMnt,cClick)
Local cQuery    := "" //Armazena a query
Local cTabela   := "" //Proxima tabela temporaria
Local aRet      := {} //Array para retorno do resultado da query
Local cTaLias   := ""
Local cDescErro := ""
Local cMHQMENSAG:= ""
Local cMHQMSGORI:= ""
Local cEtapa    := ""
Local cProcesso := ""
Local cJoin     := ""
Local cBanco    := AllTrim( Upper( TcGetDB() ) )

Default dDtIni := Date()
Default dDtFim := Date()
Default aLstMnt := {}

If !Empty(aLstMnt) 

    cTabela   := GetNextAlias()
    cEtapa    := Alltrim( aLstMnt[oLstMnt:nAt][PETAPA] )
    cProcesso := Alltrim( aLstMnt[oLstMnt:nAt][PROCES] )

    Do Case
        Case Alltrim(aLstMnt[oLstMnt:nAt][PETAPA]) == "DISTRIBUICAO"
            cTAlias := 'MHR'
            cJoin   := " INNER JOIN " + RetSqlName("MHR") + " MHR ON MHL.MHL_UIDORI = MHR.MHR_UIDMHQ"

        Case Alltrim(aLstMnt[oLstMnt:nAt][PETAPA]) == "GRVBATCH"

            If cProcesso == "CANCELAMENTO"
                cTAlias := 'SLX'
                cJoin   := " INNER JOIN " + RetSqlName("SLX") + " SLX ON MHL.MHL_UIDORI = SLX.LX_UUID"
            Else
                cTAlias := 'SL1'
                cJoin   := " INNER JOIN " + RetSqlName("SL1") + " SL1 ON MHL.MHL_UIDORI = SL1.L1_UMOV"
            EndIf                

        OTherWise 
            cTAlias := 'MHQ' 
            cJoin   := " INNER JOIN " + RetSqlName("MHQ") + " MHQ ON MHL.MHL_UIDORI = MHQ.MHQ_UUID"
    End Case
    
    cQuery := " SELECT  MHL.R_E_C_N_O_ RECMHL, MHL.MHL_FILIAL, MHL.MHL_ALIAS,"
    cQuery += " MHL.MHL_DATA, MHL.MHL_HORA, MHL.MHL_INDICE, MHL.MHL_CHAVE, MHL.MHL_UIDORI, "

    If "MSSQL" $ cBanco

        cQuery += " ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), MHL.MHL_ERROR)),'') AS MHL_ERROR"
        cQuery += ", ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), MHQ.MHQ_MENSAG)),'') MHQ_MENSAG "
        cQuery += ", ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), MHQ.MHQ_MSGORI)),'') MHQ_MSGORI "
        cQuery += ", MHQ.R_E_C_N_O_ RECMHQ"
    Else

        cQuery += " '' MHL_ERROR"
        cQuery += ", '' MHQ_MENSAG "
        cQuery += ", '' MHQ_MSGORI "
        cQuery += ", 0 RECMHQ "
    EndIf

    If "MSSQL" $ cBanco
        cQuery += "  FROM " + RetSqlName("MHL") + " MHL WITH (NOLOCK)"
    Else
        cQuery += "  FROM " + RetSqlName("MHL") + " MHL "
    EndIf

    //JOIN
    cQuery += cJoin

    If cTAlias <> "MHQ"
        cQuery += " INNER JOIN " + RetSqlName("MHQ") + " MHQ ON MHL.MHL_UIDORI = MHQ.MHQ_UUID "
    EndIf

    //WHERE
    cQuery += Where(cTAlias, dDtIni, dDtFim)

    cQuery += " AND MHL.MHL_ALIAS ='"+cTAlias+"'"
    cQuery += " AND MHL.D_E_L_E_T_ = ' '"

    If Alltrim(aLstMnt[oLstMnt:nAt][PETAPA]) == "GRVBATCH"
        cQuery += " AND MHL.MHL_CPROCE = '"+Alltrim(aLstMnt[oLstMnt:nAt][PETAPA])+"'"
    else
        cQuery += " AND MHL.MHL_CPROCE = '"+Alltrim(aLstMnt[oLstMnt:nAt][PROCES])+"'"
    EndIf    

    cQuery += " AND MHL.MHL_CASSIN = '"+Alltrim(aLstMnt[oLstMnt:nAt][PASSIN])+"'"
    cQuery += " AND MHL.MHL_STATUS IN ('IR','3') "

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

    TcSetField(cTabela, "MHL_DATA", "D", 8, 0)

    While !(cTabela)->( Eof() )     
        
        MHL->( dbGoTo( (cTabela)->RECMHL ) )
        //Caso seja base SQL ja tem o tratamento para a leitura do erro e fica mais rapido
        If Empty((cTabela)->MHL_ERROR)
            cDescErro := AllTrim( Memoline( MHL->MHL_ERROR ) )
        Else
            cDescErro := AllTrim( (cTabela)->MHL_ERROR )
        EndIf

        If Empty(cDescErro)
            cDescErro := AllTrim( MHL->MHL_ERROR )
        EndIf

        MHQ->( dbGoTo( (cTabela)->RECMHQ ) )
        If Empty((cTabela)->MHQ_MSGORI)
            cMHQMSGORI := AllTrim( Memoline( MHQ->MHQ_MSGORI ) )
        Else
            cMHQMSGORI := AllTrim( (cTabela)->MHQ_MSGORI )
        EndIf

        If Empty(cMHQMSGORI)
            cMHQMSGORI := AllTrim(MHQ->MHQ_MSGORI)
        EndIf

        If Empty((cTabela)->MHQ_MENSAG)
            cMHQMENSAG := AllTrim( Memoline( MHQ->MHQ_MENSAG ) )
        Else
            cMHQMENSAG := AllTrim( (cTabela)->MHQ_MENSAG )
        EndIf

        If Empty(cMHQMENSAG)
            cMHQMENSAG := AllTrim(MHQ->MHQ_MENSAG)
        EndIf
        
        Aadd(aRet,  {   "BR_VERMELHO"               ,;
                        aLstMnt[oLstMnt:nAt][PETAPA],;
                        (cTabela)->MHL_ALIAS        ,;
                        (cTabela)->MHL_DATA         ,;
                        (cTabela)->MHL_HORA         ,;
                        cDescErro                   ,;
                        (cTabela)->MHL_CHAVE        ,;
                        cMHQMSGORI                  ,;
                        cMHQMENSAG                  ,;
                        (cTabela)->MHL_UIDORI   }   )
        
        (cTabela)->( DbSkip() )
    EndDo
    (cTabela)->( DbCloseArea() )
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mostra erro
Retorna o resultado registros com erros nas tabelas

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CampoMemo(cTexto)
    
    DEFINE DIALOG oDlg TITLE STR0025 FROM 180,180 TO 550,700 PIXEL //"Detalhe do Erro"

        // Cria Fonte para visualização
        oFont := TFont():New('Courier new',,-18,.T.)

        // Usando o método New
        oSay1:= TSay():New(01,01,{||},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,550,700)
        oSay1:SetText( cTexto )

        // Métodos
        oSay1:CtrlRefresh()

        //oSay:SetText( cTexto )

        oSay1:SetTextAlign( 0, 0 )

        // Propriedades
        oSay1:lTransparent = .T.

        oSay1:lWordWrap = .T.

    ACTIVATE DIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTitulo
Atualiza o titulo do grid detalhe conforme linha selecionada

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraTitulo(oLstMnt,aLstMnt,cTexto,oSay) 

    If Len(aLstMnt) > 0
        cTexto := Alltrim(aLstMnt[oLstMnt:At()][PASSIN ])+" | "+Alltrim(aLstMnt[oLstMnt:At()][PROCES ])+" | "+Alltrim(aLstMnt[oLstMnt:At()][PETAPA ])
        oSay:SetText(cTexto)
        oSay:CtrlRefresh()
    endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RepVndChef
Prepara o Registro para Reprocessamento.

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RepVndChef(oLstMnt,aLstMnt,dDtIni,dDtFim)

    Local cQuery    := ""
    Local aArea     := GetArea()
    Local cTabTemp  := GetNextAlias()
    Local lMHR,lSL1 := .F.

    If Alltrim(aLstMnt[oLstMnt:At()][PROCES]) == "VENDA" 
        If MSGYESNO( I18n(STR0032,{Alltrim(aLstMnt[oLstMnt:nAt][PROCES])}) + Alltrim(Str(aLstMnt[oLstMnt:At()][PROERRO])))    //"Confirma o Reprocessamento de #1 - Total - "
            If Alltrim(aLstMnt[oLstMnt:At()][PETAPA]) == "PUBLICACAO"
                
                cQuery += " SELECT MHQ_UUID  UUID  "
                cQuery += " FROM " + RetSqlName("MHQ") + " HQ"
                cQuery += " WHERE MHQ_STATUS = '3' "
                cQuery += " AND MHQ_DATGER BETWEEN  '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
                cQuery += " AND MHQ_ORIGEM = 'CHEF' "
                cQuery += " AND MHQ_CPROCE ='VENDA' "
                cQuery += " AND HQ.D_E_L_E_T_ <> '*'"
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabTemp, .T., .F.)
            elseif Alltrim(aLstMnt[oLstMnt:At()][PETAPA]) == "DISTRIBUICAO"
                lMHR   := .T.
                cQuery += " SELECT MHR_UIDMHQ  UUID  "
                cQuery += " FROM " + RetSqlName("MHR") + " HR"
                cQuery += " INNER JOIN " + RetSqlName("MHQ") + " MHQ ON MHQ.MHQ_UUID = HR.MHR_UIDMHQ"
                cQuery += " AND MHQ_ORIGEM = 'CHEF' "
                cQuery += " AND MHQ.D_E_L_E_T_ <> '*'"
                cQuery += " WHERE MHR_STATUS = '3' "
                cQuery += " AND MHR_CPROCE ='VENDA' "
                cQuery += " AND MHR_DATPRO BETWEEN  '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
                cQuery += " AND HR.D_E_L_E_T_ <> '*'"
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabTemp, .T., .F.)
            elseIf Alltrim(aLstMnt[oLstMnt:At()][PETAPA]) == "GRVBATCH"
                lSL1   := .T.
                cQuery += " SELECT L1_UMOV UUID,SL1.R_E_C_N_O_  Recno  "
                cQuery += " FROM " + RetSqlName("SL1") + " SL1"
                cQuery += " INNER JOIN " + RetSqlName("MHQ") + " MHQ ON MHQ.MHQ_UUID = SL1.L1_UMOV"
                cQuery += " AND MHQ_ORIGEM = 'CHEF' "
                cQuery += " AND MHQ.D_E_L_E_T_ <> '*'"
                cQuery += " WHERE L1_SITUA IN ('ER','IR')"
                cQuery += " AND SL1.L1_UMOV <> ' ' "
                cQuery += " AND SL1.L1_EMISSAO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
                cQuery += " AND SL1.D_E_L_E_T_ <> '*'"
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabTemp, .T., .F.)
            EndIf

            If (cTabTemp)->(!EOF())
                
                dbSelectArea("MHQ")
                MHQ->(dbSetOrder(7)) 
                
                dbSelectArea("MHR")
                MHR->(dbSetOrder(3))
                
                dbSelectArea("SL1")
                Begin Transaction
                    While (cTabTemp)->(!EOF())
                        
                        If lSL1 
                            SL1->(dbGoto((cTabTemp)->Recno))
                            If SL1->L1_SITUA  $ "ER|IR"
                                SL1->(RecLock("SL1",.F.))
                                SL1->L1_SITUA := 'RP'
                                SL1->(MsUnLock())
                                IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
                            EndIf
                        EndIf  
                        
                        If lMHR .AND. MHR->( DbSeek(xFilial("MHR")+(cTabTemp)->UUID))
                            MHR->(RecLock("MHR",.F.))
                            MHR->MHR_STATUS := '4'
                            MHR->(MsUnLock()) 
                        EndIf        
                        
                        If  MHQ->( DbSeek(xFilial("MHQ")+(cTabTemp)->UUID))
                            MHQ->(RecLock("MHQ",.F.))
                            MHQ->MHQ_STATUS := '4'
                            MHQ->(MsUnLock()) 
                        EndIf

                        (cTabTemp)->( DbSkip() )
                    EndDo
                End Transaction
            else
                MSGINFO( STR0029, STR0028 ) //"Não foi encontrado registro para reprocessar na linha selecionada"   //"Reprocessar"
                MSGINFO( STR0030, STR0028 ) //"Verifique se a Origem da Venda é TOTVS CHEF "                        //"Reprocessar"
            EndIf
            (cTabTemp)->(DbCloseArea())
        EndIf
    else
        MSGINFO(STR0031, STR0028 )    //"Só é Possível o reprocessamento para Vendas e de Origem TOTVS CHEF "       //"Reprocessar"   
    endIf

    RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReprocInt
Reprocessa registros com erro na MHQ ou MHR de qualquer processo.
Deleta MHR, MHM, MHL, SL1, SL2 e SL4.
Colocar a publicação no status para gerar tudo de novo. (MHQ->MHQ_STATUS := "0").

@author  Varejo
@since   17/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReprocInt(oLstMnt,aLstMnt,dDtIni,dDtFim,aDetErro) 

    Local aArea     := GetArea()
    Local oRmiDel   := RmiBuscaObj():New()
    Local oRmiRep   := RmiGrvMsgPubObj():New()
    Local nI        := 0

    If RmiOrigemDado(aLstMnt[oLstMnt:nAt],dDtIni,dDtFim)

        If Len(aDetErro) > 0

            If MsgYesNo( I18n(STR0032,{Alltrim(aLstMnt[oLstMnt:nAt][PROCES])}) + Alltrim(Str(aLstMnt[oLstMnt:nAt][PROERRO])))    //"Confirma o Reprocessamento de #1 - Total - "

                For nI := 1 To Len(aDetErro)
                        
                    Begin Transaction

                        oRmiDel:DelDistrib(aDetErro[nI][UIDORI]) 
                        oRmiDel:DelVenda(aDetErro[nI][UIDORI])
                        LjGrvLog("ReprocInt","[DelDePara] Chamada do Method DelDePara(aDetErro[nI][11]) ->",{aDetErro[nI][UIDORI]})
                        oRmiDel:DelDePara(aDetErro[nI][UIDORI])
                        oRmiDel:DelLog(aDetErro[nI][UIDORI])

                        oRmiRep:Reprocessa(aDetErro[nI][UIDORI], Alltrim(aLstMnt[oLstMnt:nAt][PROCES]))

                    End Transaction

                Next nI

                MsgInfo(STR0039) //"Os registros voltaram para o status de pendentes de processamento na etapa de publicação com sucesso."
            EndIf
        EndIf

    Else
        MsgInfo(STR0042) //"Registros de Origem Protheus não serão reprocessados! Favor corrigir os registros no Protheus para novo envio."
    EndIF

    FwFreeObj(oRmiRep)
    FwFreeObj(oRmiDel)

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiOrigemDado
Prepara o Registro para Reprocessamento interno .

@author  Danilo Rodrigues
@since   01/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RmiOrigemDado(aLstMnt,dDtIni,dDtFim) 

    Local lRet      := .T.
    Local cQuery    := ""
    Local aArea     := GetArea()
    Local cTabTemp  := GetNextAlias()

    If Alltrim(aLstMnt[PETAPA]) == "PUBLICACAO"
        
        cQuery += " SELECT MHQ_ORIGEM FROM " + RetSqlName("MHQ") + " MHQ "         
        cQuery += "     WHERE MHQ_FILIAL = '" + xFilial("MHQ") + "' "
        cQuery += "         AND MHQ_ORIGEM = '" + aLstMnt[PASSIN] + "' "
        cQuery += "         AND MHQ_CPROCE = '" + aLstMnt[PROCES] + "' " 
        cQuery += "         AND MHQ_STATUS = '3' "
        cQuery += "         AND MHQ_DATGER BETWEEN  '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
        cQuery += "         AND D_E_L_E_T_ = ' ' "
        cQuery += "     GROUP BY MHQ_ORIGEM "
        
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabTemp, .T., .F.)
        
        //Origem PROTHEUS não reprocessa porque não tem a classe RmiGrvMsgPub para gerar a MHQ_MENSAG        
        If (cTabTemp)->(!EOF()) .and. Alltrim((cTabTemp)->MHQ_ORIGEM) == "PROTHEUS"
            lRet := .F.
        EndIF

    ElseIf Alltrim(aLstMnt[PETAPA]) == "DISTRIBUICAO"

        cQuery += " SELECT MHQ_ORIGEM FROM " + RetSqlName("MHR") + " MHR"
        cQuery += "     INNER JOIN " + RetSqlName("MHQ") + " MHQ ON" 
        cQuery += " 	    MHR_CPROCE = MHQ_CPROCE AND "
        cQuery += " 	    MHR_UIDMHQ = MHQ_UUID AND "
        cQuery += "     	MHQ.D_E_L_E_T_ = ' ' "
        cQuery += "     WHERE MHR_CPROCE = '" + aLstMnt[PROCES] + "' "
        cQuery += "         AND MHR_CASSIN = '" + aLstMnt[PASSIN] + "' " 
        cQuery += "         AND MHR_STATUS = '3' "
        cQuery += "         AND MHR_DATPRO BETWEEN  '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"
        cQuery += "         AND MHR.D_E_L_E_T_ = ' ' "    
        cQuery += "     GROUP BY MHQ_ORIGEM "
        
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabTemp, .T., .F.)

        //Origem PROTHEUS não reprocessa porque não tem a classe RmiGrvMsgPub para gerar a MHQ_MENSAG
        If (cTabTemp)->(!EOF()) .and. Alltrim((cTabTemp)->MHQ_ORIGEM) == "PROTHEUS"
            lRet := .F.
        EndIF

    EndIF 

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Where
Retorna o cláusula Where de cada tabela envolvida no processo de integração.
Função utilizada no grid de resumo e detalhe.

@type    function
@param   cTabela, Caractere, Tabela que terá o where retornado
@param   dDtIni, Data, Data inicial utilizada no monitor
@param   dDtFim, Data, Data final utilizada no monitor
@return  Caractere, Where da tabela

@author  Rafael Tenorio da Costa
@since   27/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Where(cTabela, dDtIni, dDtFim)

    Local cWhere := ""

    Do Case

        //Publicação
        Case cTabela == "MHQ"
            cWhere := " WHERE"
            cWhere += " MHQ_STATUS <> '2'"
            cWhere += " AND MHQ_DATGER BETWEEN  '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"

        //Distribuição
        Case cTabela == "MHR"
            cWhere := " WHERE"
            cWhere += " MHR_STATUS <> '0'"
            cWhere += " AND ( (MHR_DATPRO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "')"
            cWhere +=       " OR MHR_STATUS = '1' )"

        //Venda
        Case cTabela == "SL1"
            cWhere := " WHERE"        
            cWhere += " L1_SITUA IN ('IP','RX','OK','IR','ER')"
            cWhere += " AND L1_EMISSAO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"

        //Cancelamento
        Case cTabela == "SLX"
            cWhere := " WHERE"
            cWhere += " LX_SITUA IN ('IP','OK','IR')"
            cWhere += " AND LX_DTMOVTO BETWEEN '" + DtoS(dDtIni) + "' AND '" + DtoS(dDtFim) + "'"

    End Case

    cWhere += " AND " + cTabela + ".D_E_L_E_T_ = ' '"

Return cWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} Reprocessa
Prepara o Registro para Reprocessamento.

@type   function
@param  oLstMnt, FwBrowse, Grid com o resumo dos erros
@param  aLstMnt, Array, Array com resumo dos erros
@param  dDtIni, Data, Data inicial da tela
@param  dDtFim, DAta, Data final da tela

@author  Varejo
@since   16/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Reprocessa(oLstMnt,aLstMnt,dDtIni,dDtFim)

    Local aDetErro  := {}                                           //Detalhes do erro
    Local cOrigem   := Alltrim( aLstMnt[oLstMnt:nAt][PORIGEM] )
    Local cProcesso := Alltrim( aLstMnt[oLstMnt:nAt][PROCES]  )

    If aLstMnt[oLstMnt:nAt][PROERRO] > 0

        aDetErro :=  RmiAtuErro(dDtIni,dDtFim,aLstMnt,oLstMnt)    

        If cOrigem == "LIVE" .And. cProcesso == "VENDA"

            RepLive(cProcesso, aDetErro)

        ElseIf cOrigem == "CHEF" .And. cProcesso == "VENDA"

            RepVndChef(oLstMnt,aLstMnt,dDtIni,dDtFim)
        Else

            //Reprocessa registros com erro na MHQ ou MHR de qualquer processo.
            ReprocInt(oLstMnt,aLstMnt,dDtIni,dDtFim,aDetErro)
        EndIf
    Else

        MsgInfo(STR0040 + Alltrim(aLstMnt[oLstMnt:nAt][PROCES]) + STR0041) //"Não existem registros de " # " para reprocessamento!"
    EndIf
    
    FwFreeArray(aDetErro)

Return  Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RepLive
Envia os tickets para o LIVE para disponibilizar novamente na busca.

@type   function
@param  cProcesso, Caractere, Processo que terá o tickets liberados novamente
@param  aDetErro, Array, Array com os dados da MHL. (aLstMnt2)

@author  Rafael Tenorio da Costa
@since   27/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RepLive(cProcesso, aDetErro)

    Local oBusca    := Nil
    Local oJsParams := Nil
    Local nCont     := 0
    Local cAux      := ""

    oJsParams := JsonObject():New()
    oJsParams["tickets"] := {}

    For nCont:=1 To Len(aDetErro)
        
        If MHQ->(FieldPos('MHQ_IDEXT')) > 0
            cAux := Posicione("MHQ", 7, xFilial("MHQ") + aDetErro[nCont][UIDORI], "MHQ_IDEXT")     //MHQ_FILIAL + MHQ_UUID
        Else
            cAux := Posicione("MHQ", 7, xFilial("MHQ") + aDetErro[nCont][UIDORI], "MHQ_CHVUNI")     //MHQ_FILIAL + MHQ_UUID
            cAux := SubStr(cAux, 1, At("|", cAux) - 1)
        EndIf
        If aScan(oJsParams["tickets"], {|x| x == cAux}) == 0
            Aadd(oJsParams["tickets"], cAux)
        EndIf
    Next nCont

    //Efetua o reprocessamento
    oBusca := RmiBusLiveObj():New()
    If oBusca:getSucesso()
        oBusca:Reprocessa(cProcesso, oJsParams)
    EndIf

    If oBusca:getSucesso()
        MsgInfo( I18n(STR0047, {"LIVE"}), STR0048)    //"Os tickets do #1 serão disponibilizados novamente, aguarde uns minutos até o processo de busca ser executado."     //"Reprocessamento"
    Else
        //Gera log de erro
        oBusca:getRetorno()
    EndIf

    FwFreeObj(oJsParams)
    FwFreeObj(oBusca)

Return Nil
