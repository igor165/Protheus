#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'Totvs.CH'
#Include 'topconn.ch'
#include 'PLSBRASINI.ch'

static cCodOpe	:= PlsIntpad()
static aImpB6G  := {}
static cVerAjs  := ""
static dDataImp := msdate()
static cHoraImp := time()
static cDatDtoC := dtoc(dDataImp)
static cDatDtoS := dtos(dDataImp)
static cxFilBD4 := xFilial("BD4")
static cxFilBTQ := xFilial("BTQ")
static cxFilBA8 := xFilial("BA8")
static cxFilBF8 := xFilial("BF8")
static cxFilBR8 := xFilial("BR8")
static cxFilBTU := xFilial("BTU")
static cxFilBF6 := xFilial("BF6")
static dDataVaz := Stod("")	
static nBTUCmp  := TamSx3("BTU_VLRSIS")[1]

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSBRASIMP
Início da importação do arquivo
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
function PLSBRASIMP(cCaminho, aDadosImp, lAutoma, oRegua, dDataInf, cVersao)
local aCodBF8       := {}
local aLinhaLd      := {}
local cTipArq       as char
local cArqCom       as char
local cCodUnid      := ""
local cPrecBra      := ""
local dDataFim      := dDataVaz
local lApreBA8      := BA8->(FieldPos("BA8_DFORMA")) > 0
local lForneBA8     := BA8->(FieldPos("BA8_NMFABR")) > 0
local lGrvProc      := .t.
local lGrvB6F       := .f.
local lRetGrProc    := .f.
local nFor          := 0
local nFor2         := 0
local nFor3         := 0
local nTamReg       := 0
local nPosTuss      := 0
local nPosDesc      := 0
local nPosApre      := 0
local nCodBras      := 0
local nEdicao       := 0
local nTotPrec      := 0
local nPrecFra      := 0
local nFabric       := 0
local nTipPrec      := ""
local nTamConf      as numeric
local nColArq       := 0
local nCodApre      := 0
local oArquivo      as object 
default cCaminho    := ""
default aDadosImp   := {}
default lAutoma     := .f.

if ( empty(cCaminho) .or. empty(aDadosImp) )
    Help(nil, nil , STR0001, nil, STR0002, 1, 0, nil, nil, nil, nil, nil, {STR0003} )//"Caminho do arquivo ou array com os dados estão inválidos"/ "Problema no retorno da função. Verifique"
else
    cVerAjs := padr(cVersao, TamSX3("B6F_EDICBR")[1], "")

    nTamConf := len(aDadosImp)
    iif( !lAutoma, oRegua:SetRegua1(nTamConf), "")
    for nFor := 1 to nTamConf
        if len(aDadosImp[nFor,6]) > 0
            iif( !lAutoma, oRegua:IncRegua1(STR0004 + cValToChar(nFor) + "] de [" +cValToChar(nTamConf)+"]"), "" )//Configuração [

            for nFor2:= 1 to len(aDadosImp[nFor,6]) 
                cArqCom  := cCaminho + aDadosImp[nFor,6,nFor2]
                cTipArq  := aDadosImp[nFor,1]
                cPrecBra := aDadosImp[nFor,2] 

                if !QtdColEsper( cTipArq, aDadosImp[nFor,6,nFor2], cArqCom, cPrecBra)
                    exit 
                endif

                BEGIN TRANSACTION

                  oArquivo := FWFileReader():New(cArqCom)
                  aCodBF8 := GeraConBF8(aDadosImp[nFor])
  
                  //Variáveis de posição do arquivo
                  nPosTuss  := PosicArquivo(cTipArq, .f., 'cCodTUSS')
                  nPosDesc  := PosicArquivo(cTipArq, .f., 'cDescitem')
                  nPosApre  := PosicArquivo(cTipArq, .f., 'cNomApres')
                  nCodBras  := PosicArquivo(cTipArq, .f., 'cCodBrasin')
                  nEdicao   := PosicArquivo(cTipArq, .f., 'cEdicao')
                  nTotPrec  := PosicArquivo(cTipArq, .f., 'cTotPreco')
                  nPrecFra  := PosicArquivo(cTipArq, .f., 'cFraPreco')
                  nFabric   := PosicArquivo(cTipArq, .f., 'cNomLab') 
                  nCodApre  := PosicArquivo(cTipArq, .f., 'cCodApres') 
                  dDataFim  := daysub(dDataInf,1)
                  cCodUnid  := alltrim( RetcBox("B6G_CODUND", cValtoChar(aImpB6G[6])) ) //1=REA;2=VMD;3=VMT
                  nTipPrec  := iif( cValtoChar(aImpB6G[5]) == "1", nTotPrec, nPrecFra) //1=Valor Total;2=Valor Fracionado  
                  nColArq   := PosicArquivo(cTipArq, .t., '')  
                  lGrvProc  := .t.
                  cTissCdPad:= alltrim(PLSGETVINC("BTU_CDTERM", "BR4", .f., "87", aCodBF8[2], .t.))  
  
                  if (oArquivo:Open()) 
                      nTamReg := cvaltochar( oArquivo:getFileSize() )
                      iif(!lAutoma, oRegua:SetRegua2(-1), "")
                      oArquivo:setBufferSize(16384)
                      while oArquivo:hasLine()
                          cLinha :=  oArquivo:GetLine() 
                          lGrvProc := .t.
                          cLinha := LimpaNome(cLinha)
                          aLinhaLd := StrTokArr( cLinha, "," )
  
                          /*Pode ter registros com colunas diferentes no meio do arquivo. Se maior que o total de colunas ou menor que a 
                          posição do Código Brasíndice, fica impossível de importar e registramos no log. 
                          Se o registro contiver colunas a menos que o esperado, mas tem a posição  do Cód. Brasíndice, preenchemos com vazio os demais*/
                          if ( len(aLinhaLd) > nColArq .or. len(aLinhaLd) < nCodBras )
                              /*O item: 'X' - Código da Apresentação: 'Y', possui registro inválido, com colunas a mais que o esperado.
                               Este registro não será importado. Verifique esse item no arquivo. */
                              lGrvProc := .f.
                              GrvLogOperLog("3", STR0021 + aLinhaLd[nPosDesc] + STR0022 + aLinhaLd[nCodApre] +  ;
                                            STR0023 + STR0024)
                          elseif ( len(aLinhaLd) < nColArq .and. len(aLinhaLd) >= nCodBras )
                              for nFor3 := (len(aLinhaLd)+1) to nColArq
                                  aadd(aLinhaLd, " ")
                              next
                          endif
  
                          if lGrvProc
                              lRetGrProc := GeraProced(aCodBF8[1], aCodBF8[2], aLinhaLd, cTipArq, nPosTuss, nPosDesc, nPosApre, nCodBras, nEdicao, nTotPrec/*10*/, nPrecFra,;
                                        nFabric, lForneBA8, lApreBA8, dDataInf, cVersao, dDataFim, cCodUnid, nTipPrec, cPrecBra /*20*/, aCodBF8[3], cTissCdPad)
                              lGrvB6F := iif(lGrvB6F, lGrvB6F, lRetGrProc )
                          endif
                          iif(!lAutoma, oRegua:IncRegua2(STR0005 + cvaltochar(oArquivo:getBytesRead()) + "] do total [" + nTamReg +"]"), "") //"Lendo ["
                      enddo
                      iif(!lAutoma, oRegua:IncRegua2(" - "), "")
                      if lGrvB6F
                        GravaB6F(aDadosImp[nFor,6,nFor2], cVersao, aCodBF8[1], aImpB6G[4], cTipArq, cPrecBra)
                      endif  
                      oArquivo:close()   
                  endif 
                
                end transaction
            next

        else
            iif(!lAutoma, oRegua:IncRegua1(STR0004 + cValToChar(nFor) + "] de [" + cValToChar(nTamConf) + "]"), "") //Configuração [
        endif
    next
  
endif
return


//-------------------------------------------------------------------
/*/ {Protheus.doc} QtdColEsper
Retorna se a quantidade de colunas do arquivo e o tipo de preço esperado é válido.
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function QtdColEsper(cTipArq, cNomeArq, cArqVld, cTipPreco)
local aLinha    := {}
local cPreco    := iif(cTipPreco == "1", "PMC", "PFB")
local cLinha    := ""
local cCboxTPro := alltrim(RetcBox("B6G_TIPPRO",cValtoChar(cTipArq)))
local cErrortxt := ""
local lRetEsp   := .t.
local nColunas  := PosicArquivo(cTipArq, .t., '')  //"1=Materiais","2=Medicamentos","3=Soluções"
local nPosTpPr  := PosicArquivo(cTipArq, .f., 'cTipPreco')
local oArqVld   := nil 
default nColuna := 0

oArqVld := FWFileReader():New(cArqVld)
if (oArqVld:Open()) 
    if !oArqVld:eof()    
        cLinha := oArqVld:GetLine() 
        cLinha := LimpaNome(cLinha)
        aLinha := StrTokArr( cLinha, "," )
    endif
else
    cErrortxt := iif( !empty(oArqVld:error():message), oArqVld:error():message, cvaltochar(ferror()) )        
endif
oArqVld:Close()   

if len(aLinha) > 0
    if len(aLinha) != nColunas
        lRetEsp := .f.
        //Arquivo 'X' do tipo 'X' não possui a quantidade mínima de colunas esperada no arquivo. Quantidade de colunas esperada: 'A' - no arquivo: 'B' 
        GrvLogOperLog("2", STR0006 + cNomeArq + STR0007 + cCboxTPro + STR0010 + STR0011 + cValtoChar(nColunas) + STR0012 + cValtoChar(len(aLinha)) )
    
    elseif upper(aLinha[nPosTpPr]) != cPreco
        lRetEsp := .f.
        //Arquivo 'X' do tipo 'XX' possui valor do tipo 'Y' mas a configuração no sitema é para 'Z'
        GrvLogOperLog("2", STR0006 + cNomeArq + STR0007 + cCboxTPro + STR0008 + aLinha[nPosTpPr] + STR0009 + cPreco)
    endif
else
    //Arquivo 'X' inválido, sem delimitador ou outro tipo de problema. Verifique se o arquivo é válido."
    GrvLogOperLog("2", STR0006 + cNomeArq + STR0013 + iif(!empty(cErrortxt), CRLF + cErrortxt, "") )
    lRetEsp := .f.
endif    

return lRetEsp


//-------------------------------------------------------------------
/*/ {Protheus.doc} GeraConBF8
Gera ou consulta uma TDE para importação dos dados
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GeraConBF8(aDados)
local cCodTde   := ""
local aAreaB6G  := B6G->(GetArea())
local aAreaBF8  := {}
local cNomeTip  := ""
local cTpProc   := iif( cValtoChar(aDados[1]) == "1", "1", iif( cValtoChar(aDados[1]) == "2", "2", "9" ) ) //1=Materiais;2=Medicamentos;3=Soluções
local cCodTiss  := iif( cValtoChar(aDados[1]) == "1", "19", "20") 
local aRetFun   := {'', ''}
local lFncNivel := FindFunction("PlRetNivel")

B6G->(DbSetOrder(1))
BF8->(dbsetorder(1))
B6G->( dbgoto(aDados[4]) )
if B6G->B6G_CRITDE == "1"
    cCodTde := PLBF8VLC(cCodOpe)
    cNomeTip := substr("TABELA BRASÍNDICE - " + alltrim(RetcBox("B6G_TIPPRO",cValtoChar(aDados[1]))),1,40)
    BF8->( RecLock("BF8", .t.) )
        BF8->BF8_FILIAL := cxFilBF8
        BF8->BF8_CODINT := cCodOpe
        BF8->BF8_CODIGO := cCodTde
        BF8->BF8_DESCM 	:= cNomeTip
        BF8->BF8_CODPAD := B6G->B6G_CODPAD
        BF8->BF8_ESPTPD := "1"
        BF8->BF8_TPPROC := cTpProc //0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Diárias;5=Órtese/Prótese;6=Pacote;7=Gases Medicinais;8=Aluguéis;9=Outros      
        BF8->BF8_TABTIS := cCodTiss 
    BF8->(MsUnLock())
    aRetFun := {BF8->BF8_CODIGO, B6G->B6G_CODPAD, iif(lFncNivel, PlRetNivel(BF8->BF8_CODPAD), "3")}

    B6G->( RecLock("B6G", .f.) )
        B6G->B6G_CRITDE := "0"
        B6G->B6G_CODTDE := BF8->BF8_CODIGO
    B6G->(MsUnLock())    
else
    aAreaBF8 := BF8->(getarea())
    if BF8->( MsSeek(cxFilBF8 + B6G->(B6G_CODOPE + B6G_CODTDE)) )
        aRetFun := {BF8->BF8_CODIGO, BF8->BF8_CODPAD, iif(lFncNivel, PlRetNivel(BF8->BF8_CODPAD), "3")}
    endif
    RestArea(aAreaBF8)
endif  

DadImpProc(aDados[4])

RestArea(aAreaB6G)

return aRetFun


//-------------------------------------------------------------------
/*/ {Protheus.doc} GeraProced
Inclui/Altera os procedimentos nas tabelas BA8/BR8/BD4
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GeraProced(cCodTab, cCodPad, aDados, cTipArq, nPosTuss, nPosDesc, nPosApre, nCodBras, nEdicao, nTotPrec/*10*/,;
                           nPrecFra, nFabric, lForneBA8, lApreBA8, dDatainf, cVersao, dDataFim, cCodUnid, nTipPrec, cPrecTab /*20*/, cNivel, cTissCdPad)
local cCodItem  := ""
local nValItem  := 0 
local cDescItem := ""
local lInclusao := .f.
local nRecBkp   := 0
local aRetFun   := {}
local lImpAtual := .t.
local cFabric   := ""
local cAprese   := ""
local cUnidad   := ""
local lTdeProp  := .f.
local cTab64    := "64"
local cCodTmp   := ""

//Verifica se o item possui código TUSS, para validar se é uma inclusão nova e demais regras
BD4->(dbsetorder(1))
BA8->(dbsetorder(1)) //BA8_FILIAL, BA8_CODTAB, BA8_CDPADP, BA8_CODPRO
BF8->(dbsetorder(1))
BTQ->(dbsetorder(1))
BTU->(dbsetorder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
BR8->(dbsetorder(1))

//Valores dos campos do Arquivo
cCodItem    := aDados[nPosTuss]
cDescItem   := aDados[nPosDesc] + iif(!lApreBA8, ' - ' + aDados[nPosApre], "")
cFabric     := aDados[nFabric]   
cAprese     := aDados[nPosApre]
cUnidad     := cCodUnid
nValItem    := val(aDados[nTipPrec])

if !empty( cCodItem )
    //Se não existir esse código na TDE, verifico se existe na própria 
    if !BA8->( MsSeek(cxFilBA8 + cCodOpe + cCodTab + cCodPad + cCodItem) )
        cCodTmp := aDados[nCodBras]
        VerTdeProp(cCodTmp, dDataFim, cVersao, dDatainf)
        lInclusao := .t.
    else
        lImpAtual := FinalDtBD4(cCodOpe+cCodTab, cCodPad, cCodItem, dDataFim, cVersao, dDatainf)
        lInclusao := .f.
        nRecBkp := BA8->(recno())
    endif  

else
    cCodItem  := aDados[nCodBras]
    aRetFun   := VerTdeProp(cCodItem,dDataFim, cVersao, dDatainf)
    lInclusao := iif( !aRetFun[1], .t., .f. )
    cCodTab   := aRetFun[2]
    cCodPad   := aRetFun[3]
    nRecBkp   := aRetFun[4]
    lImpAtual := aRetFun[5]  
    lTdeProp  := .t.                
endif

if lImpAtual
    //Gravação da tabela BA8
    iif( !lInclusao .and. BA8->(recno()) != nRecBkp, BA8->(dbgoto(nRecBkp)), '') 
    BA8->(RecLock("BA8", lInclusao))
    if lInclusao
        BA8->BA8_FILIAL := cxFilBA8
        BA8->BA8_CDPADP := cCodPad
        BA8->BA8_CODPRO := cCodItem
        BA8->BA8_NIVEL  := cNivel
        BA8->BA8_CODPAD := cCodPad
        BA8->BA8_CODTAB := cCodOpe + cCodTab
    endif
        BA8->BA8_ANASIN := "1"
        BA8->BA8_DESCRI := cDescItem
        iif(lApreBA8,  BA8->BA8_DFORMA  := cAprese, '')
        iif(lForneBA8, BA8->BA8_NMFABR := cFabric, '')
        BA8->BA8_SITUAC	:= '1'

    BA8->(MsUnLock())

    //Gravação da tabela BD4
    BD4->(Reclock("BD4",.T.))
        BD4->BD4_FILIAL := cxFilBD4
        BD4->BD4_CODPRO := BA8->BA8_CODPRO
        BD4->BD4_CODTAB := BA8->BA8_CODTAB
        BD4->BD4_CDPADP := BA8->BA8_CDPADP
        BD4->BD4_CONSFT := "0"
        BD4->BD4_CODIGO := cUnidad
        BD4->BD4_VIGINI	:= dDataInf
        BD4->BD4_VIGFIM	:= dDataVaz
        BD4->BD4_VALREF := nValItem
        BD4->BD4_CHVIMP := "BRASINDICE|" + cVerAjs + "|" + cTipArq + "|" + cPrecTab
    BD4->(MsUnlock())		

    //Gravação da tabela BR8
    lInclusao := .t.
    if BR8->(msSeek(cxFilBR8 + BA8->BA8_CDPADP + BA8->BA8_CODPRO))
        lInclusao := .f.
    endif 
    BR8->(RecLock("BR8", lInclusao))
    if (lInclusao)
        BR8->BR8_FILIAL := cxFilBR8
        BR8->BR8_CODPAD := BA8->BA8_CDPADP
        BR8->BR8_CODPSA := BA8->BA8_CODPRO
        BR8->BR8_NIVEL  := BA8->BA8_NIVEL
    endif  
        BR8->BR8_ANASIN := BA8->BA8_ANASIN
        BR8->BR8_DESCRI := cDescItem
        BR8->BR8_RISCO  := "0"
        BR8->BR8_BENUTL := aImpB6G[1]
        BR8->BR8_CLASSE := aImpB6G[2]
        BR8->BR8_AUTORI := aImpB6G[3]
        BR8->BR8_TPPROC := iif( cTipArq == "1", "1", iif( cTipArq == "2", "2", "9" ) )
        BR8->BR8_DTINT 	:= cDatDtoC + " " + cHoraImp
    BR8->(MsUnLock())

    //Gravação da tabela BTQ - se TDE for própria
    if (lTdeProp)
        lInclusao := .t.

        if BTQ->( MsSeek(cxFilBTQ + cTab64 + BA8->BA8_CODPRO) )
            while BTQ->(BTQ_FILIAL + alltrim(BTQ_CODTAB + BTQ_CDTERM)) == cxFilBTQ + alltrim(cTab64 + BA8->BA8_CODPRO)
                if( BTQ->BTQ_VIGDE == dDataInf )
                    lInclusao := .f.
                    nRecBkp := BTQ->(recno())
                else
                    BTQ->(RecLock("BTQ", .f.))
                        BTQ->BTQ_DATFIM := dDataFim
                    BTQ->(MsUnLock())
                endif
                BTQ->(dbskip())
            enddo
        endif
        
        iif( !lInclusao .and. BTQ->(recno()) != nRecBkp, BTQ->(dbgoto(nRecBkp)), '') 
        BTQ->(RecLock("BTQ", lInclusao))
            BTQ->BTQ_FILIAL := cxFilBTQ
            BTQ->BTQ_CODTAB := cTab64
            BTQ->BTQ_CDTERM	:= BA8->BA8_CODPRO
            BTQ->BTQ_VIGDE 	:= dDataInf
            BTQ->BTQ_VIGATE := dDataVaz
            BTQ->BTQ_DATFIM := dDataVaz
            BTQ->BTQ_DESTER := cDescItem				
            BTQ->BTQ_LABORA := iif( cTipArq != "1", cFabric, '')
            BTQ->BTQ_FABRIC := iif( cTipArq == "1", cFabric, '')
            BTQ->BTQ_APRESE := cAprese
            BTQ->BTQ_CODGRU := iif( cTipArq == "1", "029", "030")
            BTQ->BTQ_DESGRU := iif( cTipArq == "1", "MATERIAIS E OPME", "MEDICAMENTOS")
            BTQ->BTQ_DSCDET := cDescItem
            BTQ->BTQ_FENVIO := "CONSOLIDADO"
        BTQ->(MsUnlock())
    endif

    //De-Para automático no item
    if !lTdeProp
        //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
        lInclDeP := !BTU->( DbSeek(cxFilBTU + cTissCdPad + "BR8" + PADR(cxFilBR8 + BR8->(BR8_CODPAD+ BR8_CODPSA), nBTUCmp)) )
        BTU->(RecLock("BTU", lInclDeP))
            if lInclDeP
                BTU->BTU_FILIAL := cxFilBTU
                BTU->BTU_CODTAB := cTissCdPad
                BTU->BTU_ALIAS  := "BR8"
                BTU->BTU_VLRSIS := cxFilBR8 + BR8->BR8_CODPAD + BR8->BR8_CODPSA
            endif
            BTU->BTU_VLRBUS := BR8->BR8_CODPSA
            BTU->BTU_CDTERM := BR8->BR8_CODPSA
        BTU->( MsUnlock() )
    endif
    
endif 

return lImpAtual


//-------------------------------------------------------------------
/*/ {Protheus.doc} VerTdeProp
Verifica se o item existe na TDE própria, informado no cadastro de configurações B6G
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function VerTdeProp(cCodItem, dData, cVersao, dDataInf)
local nCdPadPro := 0
local lExsBA8   := .t.
local nRecno    := 0
local lImpAtual := .t.
default dData   := dDataImp

BF8->( dbsetorder(1) )
if BF8->( MsSeek(cxFilBF8 + cCodOpe + aImpB6G[4]) )
    nCdPadPro := BF8->BF8_CODPAD
endif

BA8->( dbsetorder(1) )
if BA8->( MsSeek(cxFilBA8 + cCodOpe + aImpB6G[4] + nCdPadPro + cCodItem) )
    nRecno := BA8->(recno())
    lImpAtual := FinalDtBD4(BA8->BA8_CODTAB, BA8->BA8_CDPADP, BA8->BA8_CODPRO, dData, cVersao, dDataInf)
else
    lExsBA8 := .f.              
endif
return {lExsBA8, aImpB6G[4], nCdPadPro, nRecno, lImpAtual}


//-------------------------------------------------------------------
/*/ {Protheus.doc} FinalDtBD4
Finaliza vigência na BD4 e checa se a versão Brasíndice é atual ou não, caso tenha 
importações anteriore
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function FinalDtBD4(cCodTab, cCodPad, cCodPro, dData, cVersao, dDataInf)
local aDados    := {}
local cSql      := ''
local lRet      := .t.
default dData   := dDataImp

cSql := QueryBD4(cCodTab, cCodPad, cCodPro, dData, cVersao, .t.)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TABBD4",.F.,.T.)

if ( TABBD4->(!eof()) )
    while TABBD4->(!eof())
        if ( empty(TABBD4->CHAVE) )
            lRet := GravaBD4Fim(TABBD4->REC, dData, dDataInf)
            if !lRet 
                exit
            endif
        else
            aDados := separa(TABBD4->CHAVE, '|')
            if upper(aDados[1]) == "BRASINDICE"
                if ( val(aDados[2]) < val(cVersao) ) 
                    lRet := GravaBD4Fim(TABBD4->REC, dData, dDataInf)    
                    if !lRet 
                        exit
                    endif
                else
                    /*Item: TDE('X') - Cod. Tp Saúde ('Y') - Evento('Z') encontra-se importado no sistema, com versão igual ou superior ('A')
                    a que está sendo importada neste momento (versão:'B'). O item não será importado. */
                    GrvLogOperLog("3", STR0014 + cCodTab + STR0015 + cCodPad + STR0016 + cCodPro + STR0017 +;
                                aDados[2] + STR0018 + cVersao + STR0019)
                    lRet := .f.
                    exit
                endif			 
            endif
        endif
        TABBD4->(dbSkip())
    enddo

else 
    lRet := .t.
endif
TABBD4->(dbCloseArea())
return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} QueryBD4
Montagem da query na BD4. Consulta com o campo ou não da BD4_CHVIMP
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function QueryBD4(cCodTab, cCodPad, cCodPro, dData, cVersao, lChave)
local cSql  := ""
default lChave := .f.

cSql := " SELECT R_E_C_N_O_ REC, BD4_CHVIMP CHAVE FROM " + RetSqlName("BD4")
cSql += " WHERE "
cSql += " BD4_FILIAL     = '" + cxFilBD4 + "' "
cSql += " AND BD4_CODTAB = '" + cCodTab + "' "
cSql += " AND BD4_CDPADP = '" + cCodPad + "' "
cSql += " AND BD4_CODPRO = '" + cCodPro + "' "
cSql += " AND (BD4_VIGFIM = ' ' OR BD4_VIGFIM > '" + cDatDtoS + "') "
cSql += " AND D_E_L_E_T_ = ' '  "
cSql += " ORDER BY BD4_CHVIMP DESC "

return cSql


//-------------------------------------------------------------------
/*/ {Protheus.doc} GravaBD4Fim
Grava na BD4 a data final da vigência.
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GravaBD4Fim(nRecno, dData, dDataInf)
local lRet  := .t.

BD4->(dbGoTo(nRecno))
//Para não ocorrer erro de chave duplicada, caso a data inicial seja igual em ambas as situações
if (BD4->BD4_VIGINI != dDataInf)
    BD4->(Reclock("BD4",.F.))
        BD4->BD4_VIGFIM := dData	
    BD4->(MsUnlock())
else
    lRet := .f.
    /*Item: TDE('X') - Cod. Tp Saúde ('Y') - Evento('Z') está importado no sistema com a mesma data inicial (BD4_VIGINI) 
    dessa importação. Devido a regras de integridade, o item não será importado." */
    GrvLogOperLog("3", STR0014 + BD4->BD4_CODTAB + STR0015 + BD4->BD4_CDPADP + STR0016 + BD4->BD4_CODPRO + STR0025)
endif  
return lRet



//-------------------------------------------------------------------
/*/ {Protheus.doc} LimpaNome
Retirar caracteres especiais e apóstrofo dos campos de descrição
OBS: Quebramos a string, pois pode ter descrições usando vírgula, que quebra o array depois. 
Dessa forma, tratamos aqui também essa particularidade.
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function LimpaNome(cDescri, cSepard, lImpExc)
local aCaracSub := {"'", ";", "#", "°", 'ª', "$", "•", "=", "º", "§", "¬", "¢", "£", "¨"}
local aTempDad  := {}
local cTempDesc := ""
local nFor      := 0
local nFor2     := 0
local nSubs     := 0
default cSepard := ","
default lImpExc := .f.

if lImpExc
    nSubs := aScan(aCaracSub, {|x| x == cSepard}) 
    if ( nSubs > 0 )
        aDel(aCaracSub, nSubs)
        aSize(aCaracSub, len(aCaracSub) - 1)
    endif
endif    

cDescri := fwcutoff(cDescri, .t.)
cDescri := strtran(cDescri, '""','" "') //Para não excluir campos vazios do array, ao usar StrTokArr
cDescri := strtran(cDescri, "&", "E")

for nFor2 := 1 to Len(aCaracSub)
    cDescri := strtran(cDescri, aCaracSub[nFor2],"")
next

aTempDad := StrTokArr2( cDescri, '"' )
For nFor := 1 to len(aTempDad)
    if ( len(aTempDad[nFor]) > 2 .and. (cSepard $ aTempDad[nFor]) )
        aTempDad[nFor] := strtran(aTempDad[nFor], cSepard, ".")
    endif
    cTempDesc += upper( aTempDad[nFor] )
next
return cTempDesc


//-------------------------------------------------------------------
/*/ {Protheus.doc} LimpArrObj
Função para limpar arrays
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function LimpArrObj (aLmpArray)
default aLmpArray   := {}

if len(aLmpArray) > 0
	while Len(aLmpArray) > 0
		aDel(aLmpArray, len(aLmpArray))
		aSize(aLmpArray, len(aLmpArray)-1)	
	enddo
	aLmpArray := {}
endif

return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} DadImpProc
Preenche a variável estática aImpB6G, que armazena até o fim do processamento do arquivo as informações
sobre as configurações presentes na tabela B6G mãe, pois utilizamos na função VerTdeProp e outras partes, ao
invés de ficar posicionando direto na tabela várias vezes.
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function DadImpProc(nRecnoB6G)

LimpArrObj(aImpB6G)
if B6G->(recno()) != nRecnoB6G
    B6G->( dbgoto(nRecnoB6G) )
endif

aImpB6G := {B6G->B6G_ATIVO, B6G->B6G_CLASSE, B6G->B6G_AUTORI, B6G->B6G_TDEPRO, B6G->B6G_TIPVAL, B6G->B6G_CODUND}

return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} PosicArquivo
Essa função visa simplificar alterações futuras no layout, pois está no formato esperado de exportação do 
sistema Brasíndice. Caso tenha alguma alteração, basta alterar os arrays abaixo para a nova posição e chamá-la,
que irá retornar o novo local, sem precisar alterar outras partes do sistema, devido a mudança de layout.
IMPORTANTE: A Operadora, na hora de exportar o arquivo do sistema Brasíndice, deve marcar todos os campos opcionais
para exportação. Se não marcar, o sistema critica o arquivo, pois terá colunas a menos.
Medicamentos    := Colunas padrão + Código EAN + Código TISS + Código TUSS  + Genérico
Soluções        := Colunas padrão + Código EAN + Código TISS + Código TUSS  
Materiais       := Colunas padrão + Código TISS + Código TUSS
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function PosicArquivo(cTipArq, lContQtd, cPesquisa)
local aMaterais := {"1", {'cCodLab', 'cNomLab', 'cCdItemLab', 'cDescitem', 'cCodApres', 'cNomApres', 'cTotPreco', 'cQtdFrac', 'cTipPreco', 'cFraPreco', 'cEdicao',;
                           'cIPI', 'cFlagPIS', 'cCodBrasin'/*, 'cHierarq',*/, 'cCodTUSS'} }
local aMedicamentos := {"2", {'cCodLab', 'cNomLab', 'cCdItemLab', 'cDescitem', 'cCodApres', 'cNomApres', 'cTotPreco', 'cQtdFrac', 'cTipPreco', 'cFraPreco', 'cEdicao',;
                        'cIPI', 'cFlagPIS', 'cCodEAN', 'cCodBrasin', 'cFlagGener', 'cCodTUSS'} }
local aSolucoes := {"3", {'cCodLab', 'cNomLab', 'cCdItemLab', 'cDescitem', 'cCodApres', 'cNomApres', 'cTotPreco', 'cQtdFrac', 'cTipPreco', 'cFraPreco', 'cEdicao',;
                        'cIPI', 'cFlagPIS', 'cCodEAN', 'cCodBrasin', 'cCodTUSS'} }
local aExclusao := {"E", {'cCodLab', 'cNomLab', 'cCdItemLab', 'cDescitem', 'cCodApres', 'cNomApres', 'cCodProp', 'cCodEAN', 'cCodBrasin', 'cCodTUSS'} }
local aTipArquivos := {aMaterais, aMedicamentos, aSolucoes, aExclusao}
local nFor1         := 0
local nFor2         := 0
local nQtdPosBras   := 0
default lContQtd    := .f.
default cPesquisa   := ""

cTipArq := iif( valtype(cTipArq) == "N", cValtoChar(cTipArq), cTipArq )

for nFor1 := 1 to len(aTipArquivos)
    if cTipArq == aTipArquivos[nFor1,1]
        if lContQtd
            nQtdPosBras := len(aTipArquivos[nFor1,2])
            exit
        endif
        for nFor2 := 1 to len(aTipArquivos[nFor1,2])
            if upper(cPesquisa) == upper(aTipArquivos[nFor1,2,nFor2])
                nQtdPosBras := nFor2
                exit
            endif
        next
    endif
next

return nQtdPosBras


//-------------------------------------------------------------------
/*/ {Protheus.doc} GrvLogOperLog
Grava no array aOperLog (fonte PLSBRASIN1, função OprLogSist), as informações de erro encontradas nas operações, para exibir
no final de todo processamento, para o usuário verificar.
*cTipErro: 0=Arquivo duplicado regras / 1=Info Arquivos Orfãos / 2=Erro Importação / 3=Registro não importado
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GrvLogOperLog(cTipErro, cMensagem)
staticcall(PLSBRASIN1, OprLogSist, cTipErro, cMensagem) 
return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} GravaB6F
Grava a importação realizada na tabela B6F
@since 05/2020
@version P12
/*/
//-------------------------------------------------------------------
static function GravaB6F(cNomeArq, cVersao, cCodTab, cCodTabPro, cTipArq, cPrecBra, cTabTip)
local lInclui   := .t.
local dDataInc  := dDataImp
default cTabTip := "1" //1=Brasindice;2=Simpro;3=A900 

cVersao := cVerAjs

B6F->(dbsetorder(2))
if B6F->( MsSeek(cxFilBF6 + cCodOpe + cTabTip + cVersao + cTipArq + cPrecBra) ) //B6F_FILIAL+B6F_CODOPE+B6F_TPARQ+B6F_EDICBR+B6F_TIPPRO+B6F_TIPO
    lInclui := .f.
endif

B6F->(Reclock("B6F", lInclui))
    B6F->B6F_FILIAL := cxFilBF6
    B6F->B6F_CODIGO := iif(lInclui, GetSx8Num('B6F', 'B6F_CODIGO'), B6F->B6F_CODIGO)
    B6F->B6F_CODOPE := cCodOpe
    B6F->B6F_TPARQ  := '1' //1=Brasindice;2=Simpro;3=A900
    B6F->B6F_EDICBR := cVersao
    B6F->B6F_DATIMP := dDataInc
    B6F->B6F_USUARI := UsrRetName(RetCodUsr())
    B6F->B6F_ARQUIV := cNomeArq
    B6F->B6F_CODTDE := cCodTab
    B6F->B6F_TDEPRO := cCodTabPro
    B6F->B6F_TIPPRO := cTipArq
    B6F->B6F_TIPO   := cPrecBra
    iif(lInclui, B6F->(confirmSX8()), '')
B6F->(MsUnlock())
return 


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSBRAAEXC
Inicia o processo de importação do arquivo de "Excluídos da Edição" da Brasíndice
@since 06/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLSBRAAEXC( cCaminho, cArqExc, lAuto, cDataFim, cVersao )
local aLinhaLd  := {}
local cTipArq   := "E" //Exclusão
local cSeparad  := ";"
local cRetTab   := RetSqlName("BD4")
local cChaveExc := ""
local cUpdProced:= ""
local cLinha    := ""
local lRetFun   := .f.
local nPosDesc  := PosicArquivo(cTipArq, .f., 'cDescitem')
local nCodApre  := PosicArquivo(cTipArq, .f., 'cCodApres') 
local nCodBras  := PosicArquivo(cTipArq, .f., 'cCodBrasin')
local nPosTuss  := PosicArquivo(cTipArq, .f., 'cCodTUSS') 
local nColArq   := PosicArquivo(cTipArq, .t., '')
local oArquExc  := nil

if ( empty(cCaminho) .or. empty(cArqExc) )
    Help(nil, nil , STR0001, nil, STR0002, 1, 0, nil, nil, nil, nil, nil, {STR0003} )//"Caminho do arquivo ou array com os dados estão inválidos"/ "Problema no retorno da função. Verifique"
else
    ProcRegua(-1)
    cVerAjs := padr(cVersao, TamSX3("B6F_EDICBR")[1], "")
    cChaveExc := "BRASINDICE|" + cVerAjs + "|E|E"

    BEGIN TRANSACTION

        oArquExc := FWFileReader():New(cCaminho + cArqExc)
        if (oArquExc:Open()) 
            oArquExc:setBufferSize(16384)
            while oArquExc:hasLine()
                cLinha :=  oArquExc:GetLine() 
                aLinhaLd := StrTokArr2( strtran(cLinha, '"', ""), cSeparad, .t.)

                //Se ocorrer de ter o separador ';' no meio das descrições, chama a função limpanome para garantir
                if len(aLinhaLd) > nColArq
                    cLinha := LimpaNome(cLinha, cSeparad, .t.)
                    aLinhaLd := StrTokArr2( cLinha, cSeparad, .t.)
                endif

                /*Se o registro tiver colunas a mais que o esperado ou menor que a posição do código Brasíndice, fica impossível importar e registramos no log.*/
                if ( len(aLinhaLd) > nColArq .or. len(aLinhaLd) < nCodBras )
                    GrvLogOperLog("3", STR0021 + aLinhaLd[nPosDesc] + STR0022 + aLinhaLd[nCodApre] + STR0023 + STR0024)
                else
                    cUpdProced := formatIn(aLinhaLd[nCodBras] + "|" + aLinhaLd[nPosTuss], "|")
                    lRetfun := QryUpdExcluidos(cUpdProced, cRetTab, cDataFim, cChaveExc)
                    if !lRetFun
                        exit
                    endif
                endif
            enddo
            oArquExc:close()
            if ( lRetFun .and. QryCountExc(cChaveExc, cRetTab) )
                GravaB6F(cArqExc, cVersao, "", "", cTipArq, cTipArq, "1")
            endif 
        endif 
    END TRANSACTION
endif 
return lRetFun


//-------------------------------------------------------------------
/*/ {Protheus.doc} QryUpdExcluidos
Realiza o update nos registros que combinarem o mesmo código de procedimento, finalizando vigência e adicionando a chave de pesquisa
@since 06/2020
@version P12
/*/
//-------------------------------------------------------------------
static function QryUpdExcluidos(aCodProc, cRetTab, cDataFim, cChaveExc)
local cSql      := ""
local nRetUpd   := 0
local lContinua := .t.

cSql := " UPDATE " + cRetTab
cSql += "   SET BD4_VIGFIM = '" + cDataFim + "', "
cSql += "   BD4_CHVIMP = '" + cChaveExc + "' "
cSql += " WHERE "
cSql += "   BD4_FILIAL = '" + cxFilBD4 + "' "
csql += "   AND BD4_CODPRO IN " + aCodProc
cSql += "   AND (BD4_VIGFIM = ' ' OR BD4_VIGFIM > '" + cDatDtoS + "') "
cSql += "   AND D_E_L_E_T_ = ' ' " 

nRetUpd := TCSqlExec(cSql)
if nRetUpd < 0
	GrvLogOperLog("DL", "Query EXC - " + TCSQLError() + CRLF)
	lContinua := .f.
    DisarmTransaction()
endif
return lContinua


//-------------------------------------------------------------------
/*/ {Protheus.doc} QryCountExc
Query que verifica se houve registros excluídos na BD4. Se sim, retorna .t., para gravar o registro da exclusão na B6F.
@since 06/2020
@version P12
/*/
//-------------------------------------------------------------------
static function QryCountExc(cChave, cRetTab)
local cSql := ""
local lRet := .f.

cSql := " SELECT COUNT(*) CONT FROM " + cRetTab
cSql += "   WHERE BD4_FILIAL     = '" + cxFilBD4 + "' "
cSql += "     AND BD4_CHVIMP = '" + cChave + "' "
cSql += "     AND D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"CNTBD4EXC",.F.,.T.)
lRet := iif( CNTBD4EXC->CONT > 0, .t., .f.)
CNTBD4EXC->(dbclosearea())

return lRet 
