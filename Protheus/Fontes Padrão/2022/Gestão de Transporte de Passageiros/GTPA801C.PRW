#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "APWIZARD.CH"
#INCLUDE "SPEDNFE.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#Include "GTPA801C.ch"


/*/
 * {Protheus.doc} GTPA801C()
 * Carta de Correção
 * type    Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Function GTPA801C()
Local cStatus := G99->G99_STATRA
Local cRet	  := ''

If cStatus $ '2'
	cRet := G99Cce()	
Else
	FwAlertHelp(STR0002, STR0001) //"Apenas CTE Autorizado podem ser corrigidos." //"CCE"
Endif

Return


/*/
 * {Protheus.doc} G99Cce()
 * Carta de Correção CTE
 * type    Function
 * author  Eduardo Ferreira
 * since   16/08/2019
 * version 12.25
 * param   cAlias, nReg, nOpc
 * return  cRetorno
/*/
function G99Cce(cAlias, nReg, nOpc, lAuto)
local cError     := ''
local cEntidade  := getCfgEntidade(@cError)
local lContinua  := .T.
local cChaveCte  := ''
local cProtocolo := ''
local oFont      := Nil
local oWizard    := Nil
local cLbStatus  := ''
local oImgStatus := Nil
local cCorrecao  := ''
local cBtmStatus := ''
local cRetorno   := ''
local oSay       := Nil
Local aItensAju  := {}
private oCte     := Nil
Default lAuto    := .F.

If(empty(cEntidade))
    lContinua := .F.
EndIf

cAmbiente := left(getCfgAmbiente(@cError), 1)

If(empty(cAmbiente))
    lContinua := .F.
EndIf

If(lContinua)
    cChaveCte  := G99->G99_CHVCTE
    cProtocolo := G99->G99_PROTCA
Else
    lContinua := .F.
EndIf

lContinua := .T.

If(lContinua)
    FwMsgRun( ,{||GTP712LOAD()},,STR0003) //"Carregando tabela de tags CT-e ..."
    DEFINE FONT oFont NAME "Arial" SIZE 0, -13 BOLD
    cTexto := STR0004 + CRLF //'Informe os dados para correção.'
    cTexto += STR0005 + CRLF +CRLF //'As correções deverão ser informadas da seguinte forma:'
    cTexto += STR0006 + CRLF +CRLF  //'Grupo:Campo:Valor;Grupo:Campo:Valor'
    cTexto += STR0007 + CRLF  //'IMPORTANTE:'
    cTexto += STR0008 //'No conteúdo a ser alterado, não poderá conter o caracter de dois pontos (:) '

    If lAuto
        cCorrecao := MontStr(aItensAju)
        cEntidade := '000001'
        cAmbiente := '2'
        cChaveCte := 'SP21031844104500016753CTE1234567891123456781'
        cProtocolo := '123455666676'
        cCorrecao  := 'compl:xObs:teste de automacao;'
        ProCCe(cEntidade, cAmbiente ,cChaveCte, cProtocolo, cCorrecao, @cLbStatus, @oImgStatus, @cRetorno, lAuto)
    Else
        oWizard := APWizard():new( STR0010,STR0009,; //"Assistente para transmissão " //"Evento de Carta de Correção"
                                    STR0011+CRLF,cTexto,,,,,,.F.) //"CTe - Carta de Correção "

        oWizard:NewPanel(STR0012,STR0013,{||.T.},{|| cCorrecao:=MontStr(aItensAju),.T. },{||.T.},.T.,{||MontTag(oWizard:oMPanel[2],aItensAju)})                            //'Montagem' //'Atribuições'

        oWizard:NewPanel ( STR0014 ,"" , {||.T.} ,; //"Dados para Correção"
            {|| processa({|| ProCCe(cEntidade, cAmbiente ,cChaveCte, cProtocolo, cCorrecao, @cLbStatus, @oImgStatus, @cRetorno) }), .T.} , {|| .T.})

        @000,000 GET cCorrecao MEMO SIZE 299, 138 PIXEL OF oWizard:oMPanel[3] //2

        oWizard:NewPanel ( STR0015 , cRetorno , {|| .T.} , {|| .T.} , {|| .T.}) //"Finalizado Processo de Carta de Correção"

        oImgStatus := TBitmap():New(010,010,260,184,,cBtmStatus,.T.,oWizard:oMPanel[4], {||},,.F.,.F.,,,.F.,,.T.,,.F.)  
        @012,025 SAY oSay PROMPT cLbStatus OF  oWizard:oMPanel[4] PIXEL FONT oFont SIZE 150, 015                        
        @032,010 GET cRetorno MEMO SIZE 290, 115 READONLY PIXEL OF oWizard:oMPanel[4]                                   

        ACTIVATE WIZARD oWizard CENTERED

    Endif
Else
    aviso(STR0016, cError, {STR0016}, 3) //STR0016 //"CTe - Carta de Correção"
EndIf

freeObj(oCte)
oCte := nil

Return cRetorno


/*/
* {Protheus.doc} GTP712LOAD()
* Carrega tabela para uso na carta de correção de CTE
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   Não há
* return  lRet
/*/
Function GTP712LOAD()
Local lRet    := .T.
Local aArea   := GetArea()
Local oModel  := FwLoadModel('GTPA712')
Local oMdlG53 := oModel:GetModel('G53MASTER')
Local aDados  := {}
Local nX	  := 0

//        		G53_GRUPO,G53_CAMPO,G53_DESCRI  
aAdd(aDados,{'ide'        , 'CFOP'          , STR0017}) //'Código Fiscal de Operações e Prestações'
aAdd(aDados,{'ide'        , 'natOP'         , STR0018}) //'Natureza da Operação'
aAdd(aDados,{'ide'        , 'cMunEnv'       , STR0019}) //'Código do Município de envio do CT-e'
aAdd(aDados,{'ide'        , 'xMunEnv'       , STR0020}) //'Nome do Município de envio do CT-e'
aAdd(aDados,{'ide'        , 'UFEnv'         , STR0021}) //'Sigla da UF de envio do CT-e'
aAdd(aDados,{'ide'        , 'indIEToma'     , STR0022}) //'Indicador do papel do tomador na prestação do serviço'
aAdd(aDados,{'ide'        , 'cMunIni'       , STR0023}) //'Código do Município de início da prestação'
aAdd(aDados,{'ide'        , 'xMunIni'       , STR0024}) //'Nome do Município do início da prestação'
aAdd(aDados,{'ide'        , 'UFIni'         , STR0025}) //'UF do início da prestação'
aAdd(aDados,{'ide'        , 'cMunFim'       , STR0026}) //'Código do Município de término da prestação'
aAdd(aDados,{'ide'        , 'xMunFim'       , STR0027}) //'Nome do Município do término da prestação'
aAdd(aDados,{'ide'        , 'UFFim'         , STR0028})	//'UF do término da prestação'
aAdd(aDados,{'infPercurso', 'UFPer'         , STR0029})	//'Sigla das Unidades da Federaç?o do percurso do veículo.'
aAdd(aDados,{'compl'      , 'xObs'          , STR0030})	//'Observações Gerais'
aAdd(aDados,{'emit'       , 'CNPJ'          , STR0031})	//'CNPJ do emitente'
aAdd(aDados,{'emit'       , 'IE'            , STR0032})	//'Inscrições Estadual do Emitente'
aAdd(aDados,{'emit'       , 'xNome'         , STR0033})	//'Razão social ou Nome do emitente'
aAdd(aDados,{'emit'       , 'xFant'         , STR0034})	//'Nome fantasia'
aAdd(aDados,{'enderEmit'  , 'xLgr'          , STR0035})	//'Logradouro'
aAdd(aDados,{'enderEmit'  , 'nro'           , STR0036})	//'Número'
aAdd(aDados,{'enderEmit'  , 'xBairro'       , STR0037})	//'Bairro'
aAdd(aDados,{'enderEmit'  , 'cMun'          , STR0038})	//'Código do município'
aAdd(aDados,{'enderEmit'  , 'CEP'           , STR0039})	//'CEP'
aAdd(aDados,{'enderEmit'  , 'UF'            , STR0040})	//'Sigla da UF'
aAdd(aDados,{'enderEmit'  , 'fone'          , STR0041})	//'Telefone'
aAdd(aDados,{'toma'       , 'CPF'           , STR0042})	//'Número do CPF'
aAdd(aDados,{'toma'       , 'xNome'         , STR0043}) //'Razão social ou nome do tomador'
aAdd(aDados,{'toma'       , 'xFant'         , STR0034}) //'Nome fantasia'
aAdd(aDados,{'toma'       , 'fone'          , STR0041}) //'Telefone'
aAdd(aDados,{'enderEmit'  , 'cPais'         , STR0044})	//'Código do país'
aAdd(aDados,{'enderEmit'  , 'xPais'         , STR0045})	//'Nome do país'
aAdd(aDados,{'enderToma'  , 'xLgr'          , STR0035}) //'Logradouro'
aAdd(aDados,{'enderToma'  , 'nro'           , STR0036}) //'Número'
aAdd(aDados,{'enderToma'  , 'xBairro'       , STR0037}) //'Bairro'
aAdd(aDados,{'enderToma'  , 'cMun'          , STR0038}) //'Código do município'
aAdd(aDados,{'enderToma'  , 'xMun'          , STR0046}) //'Nome do município'
aAdd(aDados,{'enderToma'  , 'CEP'           , STR0039}) //'CEP'
aAdd(aDados,{'enderToma'  , 'UF'            , STR0040}) //'Sigla da UF'
aAdd(aDados,{'enderToma'  , 'cPais'         , STR0044}) //'Código do país'
aAdd(aDados,{'enderToma'  , 'xPais'         , STR0045})	//'Nome do país'
aAdd(aDados,{'infServico' , 'xDescServ'     , STR0047})	//'Descrição do Serviço prestado'
aAdd(aDados,{'rodoOS'     , 'NroRegEstadual', STR0048})	//'Número do Registro Estadual'
aAdd(aDados,{'veic'       , 'placa'         , STR0049})	//'Placa do veículo'
aAdd(aDados,{'veic'       , 'UF'            , STR0050})	//'UF'
	
G53->(DbSetOrder(1))//G53_FILIAL+G53_CODIGO
For nX := 1 to Len(aDados)
	If !G53->( DbSeek(xFilial('G53')+PadR( aDados[nX][1], TamSX3("G53_GRUPO")[1] )+PadR( aDados[nX][2], TamSX3("G53_CAMPO")[1] )) )	
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()			
			oMdlG53:SetValue('G53_GRUPO' , aDados[nX][1])
			oMdlG53:SetValue('G53_CAMPO' , aDados[nX][2])
			oMdlG53:SetValue('G53_DESCCP', aDados[nX][3])
			If oModel:VldData() 
				oModel:CommitData()
			EndIf
		EndIf
		
		oModel:Deactivate()
	
	EndIf
Next

oModel:Destroy()
RestArea(aArea)
GtpDestroy(aDados)

Return lRet


/*/
* {Protheus.doc} ProCCe()
* Processa correção do CTe
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cEntidade, cAmbiente, cChaveCte, cProtocolo, cCorrecao, cLbStatus, oImgStatus, cRetorno
* return  lvalid
/*/
function ProCCe(cEntidade, cAmbiente, cChaveCte, cProtocolo, cCorrecao, cLbStatus, oImgStatus, cRetorno, lAuto)
local oReq      := Nil
local oResp     := Nil
local cReq      := ''
local lValid      
Default lAuto   := .F.

lValid := VldCCeCTe(@cCorrecao, @cRetorno)

if(lValid)
    cReq := '{ "msg": {"entidade": "' + cEntidade +'", "ambiente": "' + cAmbiente +'"'
    cReq += ', "cte": [ {"chaveCTe": "' + cChaveCTe + '", "protocolo": "' + cProtocolo +  '",'
    cReq += cCorrecao + '}]}}'
    if(fwJsonDeserialize(cReq, @oReq) )
        CTeCCe(oReq, @oResp)
        if(oResp:error == nil)
            cReq := '{"msg": {"entidade": "' + cEntidade + '", "codEvento": "110110", "chaveCTe": "' + cChaveCte + '"}}'
            if(fwJsonDeserialize(cReq, @oReq))
                CTeConsutEvent(oReq, @oResp)
                if(oResp:error == nil)
                    if(oResp:response:status == 1)
                        oImgStatus:setBmp("qmt_cond.png")
                        cLbStatus := STR0051 //"Carta de Correção não Processada!"
                        cRetorno += STR0052 //"Acompanhe o Status de Processamento atraves da opção 'Consultar Eventos'"
                    elseif(oResp:response:status == 2)
                        oImgStatus:setBmp("qmt_ok.png")
                        cLbStatus := STR0053 //"Carta de Correção Autorizada!"
                        cRetorno := oResp:response:details + CRLF + STR0054 + oResp:response:autorizacao:protocolo //"Protocolo: "
                    elseif(oResp:response:status == 3)
                        oImgStatus:setBmp("qmt_no.png")
                        cLbStatus := STR0055 //"Carta de Correção Rejeitada"
                        cRetorno := STR0056 + oResp:RESPONSE:rejeicao:codigo //"Rejeição: "
                        cRetorno += oResp:RESPONSE:rejeicao:motivo
                    endif
                    
                    AtuXmlRet(cRetorno, cvaltochar(ORESP:RESPONSE:STATUS))

                else
                    oImgStatus:setBmp("qmt_cond.png")
                    cLbStatus := STR0057 //"Carta de Correção não Autorizada."
                    cRetorno := decode64(oResp:error)
                endif
            else
                oImgStatus:setBmp("qmt_cond.png")
                cLbStatus := STR0058 //"Carta de Correção não transmitida."
                cRetorno := STR0059 +CRLF + cReq //"Requisicao inválida:"
            endif
        else
            If !lAuto
                oImgStatus:setBmp("qmt_cond.png")
            Endif
            cLbStatus := STR0060 //"Carta de Correção não transmitida"
            cRetorno := decode64(oResp:error)
        endif
    else
        oImgStatus:setBmp("qmt_no.png")
        cLbStatus := STR0058 //"Carta de Correção não transmitida."
        cRetorno := STR0059 +CRLF + cReq //"Requisicao inválida:"
    endif
    If !lAuto
        oImgStatus:refresh()
    Endif
endif

Return lvalid


/*/
* {Protheus.doc} MontStr()
* Funcao responsavel por MontaStr
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   aItensAju
* return  Strtag
/*/
Static Function MontStr(aItensAju) 
Local Strtag := ''
Local nX     := 0

For nX := 1 To Len(aItensAju)
    Strtag += aItensAju[nX][1]+':'+aItensAju[nX][2]+':'+aItensAju[nX][3]+';'
Next nX

Return Strtag


/*/
* {Protheus.doc} MontTag()
* Funcao responsavel por MontaTAG
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   oPanel,aItensAju
* return  Não há
/*/
Static Function MontTag(oPanel,aItensAju)
Local aTagCpo    := GrCpo() 
Local aItens1    := TagGrCte(@aTagCpo)
Local cGrupo     := aItens1[1]
Local aItens2    := TagGrCpo(aTagCpo,cGrupo)
Local cCampo     := aItens2[1]
Local oCboGrupo  := Nil
Local oCboCampo  := Nil
Local oSayDesc   := Nil
Local oGetText   := Nil
Local cTexto     := SPACE(80)
Local oButInsere := Nil
Local oButExclui := Nil
Local oGrid      := Nil

oPanelGrid:= tPanel():New(045,005,,oPanel,,,,,,270,085)

   TSay():New(005,000,{||STR0061},oPanel,,,,,,.T.) //'Grupo'

   oCboGrupo := TComboBox():New(000,020,{|u|if(PCount()>0,cGrupo:=u,cGrupo)},;
             aItens1,100,20,oPanel,,{|| oCboCampo:aItems:=TagGrCpo(aTagCpo,cGrupo)  };
            ,,,,.T.,,,,,,,,,'cGrupo')

    TSay():New(005,130,{||STR0062},oPanel,,,,,,.T.) //'Campo'
    
    oCboCampo := TComboBox():New(000,150,{|u|if(PCount()>0,cCampo:=u,cCampo)},;
             aItens2,100,20,oPanel,,{||oSayDesc:SetText( TagDesc(aTagCpo,cGrupo,cCampo) )  };
            ,,,,.T.,,,,,,,,,'cCampo')
    
    oSayDesc := TSay():New(020,020,{||TagDesc(aTagCpo,cGrupo,cCampo)},oPanel,,,,,,.T.)       

    oGetText := TGet():New( 030,020, { | u | If( PCount() == 0, cTexto, cTexto := u ) },oPanel,230,010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cTexto",,,,  )

    oButInsere := TButton():Create( oPanel,030,255,STR0063,{||  SetGrid(oGrid,aItensAju,cGrupo, cCampo,'1',cTexto)  }, 30,12,,,,.T.,,,,,,) //"Adiciona"

    oButExclui := TBtnBmp2():New( 120,560,26,26,STR0064,,,,{||  ExcItem(oGrid,aItensAju)  },oPanel,,,.T. ) //'EXCLUIR'

    DEFINE FWBROWSE oGrid DATA ARRAY ARRAY aItensAju NO CONFIG  NO REPORT NO LOCATE OF oPanelGrid
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),1] } TITLE STR0061 SIZE 070 OF oGrid //'Grupo'
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),2] } TITLE STR0062 SIZE 070 OF oGrid //'Campo'
        ADD COLUMN oColumn DATA { || aItensAju[oGrid:At(),3] } TITLE STR0065 SIZE 100 OF oGrid //"Texto"
        oGrid:ACOLUMNS[1]:NALIGN := 1 //Alinhamento 
        oGrid:ACOLUMNS[2]:NALIGN := 1 //Alinhamento 
        oGrid:ACOLUMNS[3]:NALIGN := 1 //Alinhamento  
        oGrid:SetLineHeight(25) //Altura de cada linha
    ACTIVATE FWBROWSE oGrid

Return


/*/
* {Protheus.doc} GrCpo()
* Funcao responsavel por retorna o grupo do CPO
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   Não há
* return  aTagCPO
/*/
Static Function GrCpo()
Local aTagCPO := {}

dbSelectArea('G53')
G53->(DbSetOrder(1))
G53->(DbGoTop())

While G53->(!Eof())
    AADD(aTagCPO,{G53->G53_GRUPO,G53->G53_CAMPO,G53->G53_DESCCP})
    G53->(dbSkip())
END

Return aTagCPO


/*/
* {Protheus.doc} TagGrCte()
* Funcao responsavel por retorna a Tag do grupo do Cte
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   aTagCpo
* return  aGrupo
/*/
Static Function TagGrCte(aTagCpo)
Local aGrupo := {}
Local cGrupo := ''
Local nX     := 0

For nX := 1 to Len(aTagCpo)
    If cGrupo <> AllTrim(aTagCpo[nX][1])
       AADD(aGrupo, AllTrim( aTagCpo[nX][1] )  )
       cGrupo := AllTrim( aTagCpo[nX][1] )       
    EndIf
Next nX

Return aGrupo


/*/
* {Protheus.doc} TagGrCpo()
* Funcao responsavel por retorna a Tag do grupo do CPO
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   aTagCpo,cGrupo
* return  aCampos
/*/
Static Function TagGrCpo(aTagCpo,cGrupo)
Local aCampos := {}
Local nX      := 0

For nX := 1 to Len(aTagCpo)

    If cGrupo == AllTrim(aTagCpo[nX][1])
       AADD(aCampos,   AllTrim( aTagCpo[nX][2] )  )             
    EndIf

Next nX

Return aCampos


/*/
* {Protheus.doc} TagDesc()
* Funcao responsavel por retorna a Descrição
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   aTagCpo,cGrupo,cCampo
* return  cDescricao
/*/
Static Function TagDesc(aTagCpo,cGrupo,cCampo)
Local cDescricao := ''
Local nX         := 0

For nX := 1 to Len(aTagCpo)

    If cGrupo == AllTrim(aTagCpo[nX][1]) .AND. cCampo == AllTrim(aTagCpo[nX][2]) 
       cDescricao := AllTrim(aTagCpo[nX][3] )       
    EndIf

Next nX

Return cDescricao


/*/
* {Protheus.doc} ExcItem()
* Funcao responsavel por retorna Excluir o Item
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   oGrid,aItensAju
* return  Não há
/*/
Static Function ExcItem(oGrid,aItensAju) 
Local nX := oGrid:nAt

IF !Empty(aItensAju)
    ADel(aItensAju, nX)
    ASize(aItensAju, Len(aItensAju)-1)
    oGrid:SetArray(aItensAju)
    oGrid:Refresh()    
EndIf

Return


/*/
* {Protheus.doc} ExcItem()
* Funcao responsavel por Seta valor no grid
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   oGrid,aItensAju,cGrupo, cCampo,cSeq,cTexto
* return  Não há
/*/
Static Function SetGrid(oGrid,aItensAju,cGrupo, cCampo,cSeq,cTexto) 
Local cMsg := STR0066 //'A limitação de itens a serem corrigidos é de 20 itens'

If Len(aItensAju) < 19
    If aScan( aItensAju,{|x| x[1] == AllTrim(cGrupo) .AND. x[2] == AllTrim(cCampo)}) == 0
        AADD( aItensAju ,{ cGrupo, cCampo,Alltrim(cTexto) } )
        oGrid:SetArray(aItensAju)
        oGrid:Refresh()     
    EndIf
Else
    Alert(cMsg)
EndIf        

Return


/*/
* {Protheus.doc} VldCCeCTe()
* Valida e monta Mensagem da correção
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cCorrecao, cRetorno
* return  lValid
/*/
static function VldCCeCTe(cCorrecao, cRetorno)
local lValid := .T.
local nC     := 0

private aValor

cCorrecao := Alltrim(cCorrecao)
cCorrecao := StrTran(cCorrecao,Chr(10),"")
cCorrecao := StrTran(cCorrecao,Chr(13),"")
cCorrecao := StrTran(cCorrecao,Chr(135),"&Amp;")
cCorrecao := StrTran(cCorrecao,Chr(198),"&atilde;")

aCorrecao := Strtokarr2( cCorrecao, ";", .F.)

if(!empty(aCorrecao))

    cCorrecao := '"correcoes": ['

    for nC :=  1 to len(aCorrecao)
        aValor := Strtokarr2(aCorrecao[nC], ":", .T.)      
        aRet := VldDados( aValor )
        //----------------------------------
        // Processo executado com sucesso
        //----------------------------------
        if aRet[1] 
            if Len(aValor) >= 3
                if(nC > 1)
                    cCorrecao += ','
                endif          
                cCorrecao += '{"grupo":"' + aValor[1] +'", "campo": "' + aValor[2] + '", "valor": "' + aValor[3] + '"}'        
            endif    
        //----------------------------------
        // Processo falhou
        //----------------------------------    
        else
            if Len(aRet) >= 2
                if( len(aRet[2]) > 0 )
                    lValid		:= aRet[1]
                    cCorrecao := aRet[2]
                endif
            endif
        endif
    next

    cCorrecao += ']'

    if(empty(cCorrecao))
        lValid := .F.
        cCorrecao := STR0067 + cCorrecao //"Estrutura invalida"
    endif
else
    cCorrecao := STR0067 + cCorrecao //"Estrutura invalida"
endif

if(!lValid)
    aviso(STR0016, cCorrecao, {''}, 3) //"CTe - Carta de Correção"
endif
    
return lValid


/*/
* {Protheus.doc} CTeCCe()
* Transmite uma Carta de Correção de CTe para o TSS
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   oReq, oResp
* return  oResp <> nil
/*/
function CTeCCe(oReq, oResp)   
local cXml     := ''
local cError   := '' 
local lSend     
local aIds     := {}
local cJsonRet := ''
local nItens   := 0

cXml := xmlEvCCe(oReq:msg:cte[1]:chaveCte,;
    oReq:msg:ambiente, oReq:msg:cte[1]:correcoes)

lSend := TransmitEvento(oReq:msg:entidade, cXml, @aIds, @cError)

if(lSend)        
    cJsonRet := '{ "motivo": "Carta de Correcao Transmitida com Sucesso", "idEvento": ['  
    
    for nItens := 1 to len(aIds)            
        cJsonRet += '{"id": "' + aIds[nItens] + '"}'
    next
    
    cJsonRet += ']}'    
    
    
    GTPA812RET(G99->G99_CODIGO, '1', oReq:msg:CTE[1]:CHAVECTE, NIL,cJsonRet,'1',cXml)
   

endif    

oResp :=  GetJsResp(cJsonRet, cError) 
    
return (oResp <> nil)


/*/
* {Protheus.doc} xmlEvCCe()
* Montagem do Xml de carta de correção
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cChaveCTe, cAmbiente, aCorrecao
* return  cXml
/*/
static function xmlEvCCe(cChaveCTe, cAmbiente, aCorrecao)   
local cEntidade   := getCfgEntidade()
local cTipoEvento := '110110'
Local cError      := ''
Local cVersaoCTe  := getCfgVersao(@cError, cEntidade, '57')
local cXml        := ''
local nCorrecao   := 0

cXml += '<envEvento>'
cXml += '<eventos>'
cXml += '<detEvento versaoEvento="' + cVersaoCTe  + '">'
cXml += '<tpEvento>' + cTipoEvento + '</tpEvento>'
cXml +=' <chNFe>'+ cChaveCTe +'</chNFe>'

For nCorrecao := 1 to len(aCorrecao) 
    cXml += '<correcao>'
    cXml += '<grupo>' + aCorrecao[nCorrecao]:grupo + '</grupo>'
    cXml += '<campo>' + aCorrecao[nCorrecao]:campo + '</campo>'
    cXml += '<valor>' + aCorrecao[nCorrecao]:valor + '</valor>'
    cXml += '</correcao>'
Next

cXml += '</detEvento>'
cXml += '</eventos>'
cXml += '</envEvento>'

return cXml


/*/
* {Protheus.doc} TransmitEvento()
* Transmissão dos Eventos
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cEntidade, cXml, aIds, cError
* return  lSend
/*/
static function TransmitEvento(cEntidade, cXml, aIds, cError)
local oWS      := Nil
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
local lSend    := .F.
local nEventos := 0

oWs:= WsNFeSBra():New()

oWs:cUserToken	:= "TOTVS"
oWs:cID_ENT		:= cEntidade
oWs:cXML_LOTE	:= cXml
oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"

if oWS:remessaEvento()
    for nEventos := 1 to len(oWS:oWSREMESSAEVENTORESULT:cString)
        aadd(aIds, oWS:oWSREMESSAEVENTORESULT:cString[nEventos])
    next    
    
    lSend := !empty(aIds)
else
    cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
endif

return lSend


/*/
* {Protheus.doc} GetJsResp()
* MOnta Resposta padrão Json 
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cJsonRet, cError
* return  oResp
/*/
function GetJsResp(cJsonRet, cError)
local oResp := Nil      

default cError   := 'null'
default cJsonRet := 'null'

if( empty(cError) )
    cError := 'null'
endif    

if( cJsonRet <> 'null' .and. !fwJsonDeserialize(cJsonRet, @oResp))        
    cError := "invalid JSON Message: " + cJsonRet        
endif

if(cError <> 'null')
    cError := '"' + encode64(cError) + '"'    
    cJsonRet := 'null'
endif    

fwJsonDeserialize('{ "error": ' + cError + ',"response":  ' + cJsonRet + '}', @oResp)

return oResp


/*/
* {Protheus.doc} CTeConsutEvent()
* Consulta Status dos Eventos do CTe
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   oReq, oResp
* return  oResp <> nil
/*/
function CTeConsutEvent(oReq, oResp)   
local oWS        := Nil
Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Local nTime      := GTPGetRules("RETSTAEVEN")
local cStatEven  := ''
local cMotEven   := ''
local cProtocolo := ''    
local cJsonRet   := ''
local cError     := ''

oWS  := wsNFeSBra():new()
oWS:_URL        := AllTrim(cURL) + "/NFeSBRA.apw"
oWS:cUserToken  := "TOTVS"
oWS:cID_ENT     := oReq:msg:entidade
oWS:cEvento     := oReq:msg:codEvento
oWS:cChvInicial := oReq:msg:chaveCTe
oWS:cChvFinal   := oReq:msg:chaveCTe

Sleep(nTime)

if(oWS:nfeMonitorLoteEvento())
    nLote := len(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO)
    if ( nLote > 0 )
        cStatEven := str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven, 3)
        cMotEven  := alltrim(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:cCMotEven)
        
        if( oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nCStatEven == 0 )            
        
            cJsonRet :='{"status": 1, "details": "Aguardando Processamento.", '
            cJsonRet += '"autorizacao":{"protocolo": ""}, '
            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }' 
            
            GTPA812RET(G99->G99_CODIGO, '1', oReq:msg:chaveCTe, oWS, cJsonRet,'2')
        
        elseif(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo > 0 )

            cProtocolo:= alltrim(str(oWS:oWSNFEMONITORLOTEEVENTORESULT:oWSNFEMONITOREVENTO[nLote]:nProtocolo))
            cJsonRet := '{"status": 2, "details": "Evento Autorizado.", '
            cJsonRet += '"autorizacao":{"protocolo": "' + cProtocolo + '"}, '
            cJsonRet += '"rejeicao": {"codigo": "", "motivo": ""} }'
       
           GTPA812RET(G99->G99_CODIGO, '1', oReq:msg:chaveCTe, oWS, cJsonRet,'2')
        else
            cJsonRet := '{"status": 3, "details": "Evento Rejeitado.", '
            cJsonRet += '"autorizacao":{"protocolo": "" }, "rejeicao": '
            cJsonRet += '{ "codigo": "' + cStatEven +'", "motivo":"' + cMotEven + '"}}' 
            
            GTPA812RET(G99->G99_CODIGO, '1', oReq:msg:chaveCTe, oWS, cJsonRet,'2')
        endif
    else
        cError := STR0068 //"Documento não possui evento."
    endif        
else
    cError := iif( empty( getWscError(3)), getWscError(1), getWscError(3))
endif

oResp := GetJsResp(cJsonRet, cError)
    
return oResp <> nil


/*/
* {Protheus.doc} VldDados()
* Funcao responsavel por validar os dados recebidos.
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   aValid
* return  aRet
/*/
static function VldDados( aValid )
local aRet		:= {}
default aValid 	:= {}
private aDados 	:= aValid

if( type("aDados[1]") <> "U" .and. type("aDados[2]") <> "U" .and. type("aDados[3]") <> "U" )
    aRet := validLen( aDados[1], aDados[2], aDados[3] )
else
    aRet := { .F., STR0067 } //"Estrutura invalida"
endif				

return aRet


/*/
* {Protheus.doc} validLen()
* Funcao responsavel por validar o tamanho do conteudo.
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cGrupo, cTag, cConteudo
* return   lValid, cRet
/*/
static function validLen( cGrupo, cTag, cConteudo )	
local lValid := .T.
local cRet	 := ''

default cGrupo	  := ''
default cTag	  := ''
default cConteudo := ''
        
if ( !(empty(cGrupo)) .and. !(empty(cTag)) .and. !(empty(cConteudo)) )
    //---------------------------------------
    // Grupo IDE
    //---------------------------------------
    if alltrim(upper(cGrupo)) == "IDE"
        //---------------------------------------
        // Tag somente com 1 conteudo
        //---------------------------------------
        if( upper(cTag) $ "TPIMP|TPEMIS|CDV|TPAMB|TPCTE|PROCEMI|TPSERV|INDIETOMA" )
            if len(alltrim(cConteudo)) <> 1
                lValid 	:= .F.									
                cRet 	:= STR0070 + alltrim(cTag) + STR0069 //" deve ter o máximo de 1 caracter."
            endif
        endif
    //---------------------------------------
    // Grupo COMPLEMENTOS
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "COMPL"
        if( len(alltrim(cConteudo)) < 15 ) 
            lValid	:= .F.
            cRet		:= STR0072 + alltrim(cTag) + STR0071 //" deve ter o mínimo de 15 caracteres."
        elseif( len(alltrim(cConteudo)) > 255)
            lValid 	:= .F.
            cRet		:= STR0072 + alltrim(cTag) + STR0073 //"A Correção para a tag "
        endif
    //---------------------------------------
    // Grupo EMITENTE
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "EMIT"
        //---------------------------------------
        // Tag no minimo 1 conteudo
        //---------------------------------------
        if upper(cTag) $ "NRO"
            if len(alltrim(cConteudo)) == 0
                lValid := .F.									
                cRet := STR0070 + alltrim(cTag) + STR0074 //"A correção para a tag "
            endif
        endif
    //---------------------------------------
    // Grupo TOMADOR
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "TOMA"
        //---------------------------------------
        // Tag no minimo 1 conteudo
        //---------------------------------------
        if upper(cTag) $ "NRO"
            if len(alltrim(cConteudo)) == 0
                lValid := .F.									
                cRet := STR0075 //"A correção deve ter o mínimo de 1 caracter"
            endif
        endif
    //---------------------------------------
    // Grupo IMPOSTOS
    //---------------------------------------
    elseif alltrim(upper(cGrupo)) == "IMP"
        //---------------------------------------
        // Valores nao podem serem alterados
        //---------------------------------------
        lValid := .F.									
        cRet := STR0070 + alltrim(cTag) + STR0076 //"A correção para a tag "
    endif
endif
                            
return { lValid, cRet }


/*/
* {Protheus.doc} AtuXmlRet()
* Atualiza o XmlRet na G99
* type    Function
* author  Eduardo Ferreira
* since   16/08/2019
* version 12.25
* param   cRet, oResp
* return  Não há
/*/
Static Function AtuXmlRet(cRet, cResp)
Local cStat := "Status: "

RecLock("G99", .F.)
    G99->G99_XMLRET := cRet + CRLF + cStat + cResp 
MsUnLock()

Return 

Static Function ExecTest()


Return
