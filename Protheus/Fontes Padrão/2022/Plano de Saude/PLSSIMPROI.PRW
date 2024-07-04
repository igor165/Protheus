#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'Totvs.CH'
#Include 'topconn.ch'
#include 'PLSSIMPROI.ch'

static aImpB6G  := {}
static cCodOpe	:= PlsIntpad()
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

function PLSIMPSIM(cCaminho, aDadosImp, lAutoma, oRegua,cCodmsg, dDataMsg)
local aCodBF8       := {}
local aLinhaLd      := {}
local cTipArq       as char
local cArqCom       as char
local cCodUnid      := ""
local cPrecSim      := ""
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
local nTipPrec      := ""
local nTamConf      as numeric
local oArquivo      as object 
local nPosDescP     := 0
local nPosPrFE      := 0
local nPosPrVE      := 0
local nPosPrUE      := 0
local nPosPrFF      := 0
local nPosPrVF      := 0
local nPosTpEmb     := 0
local nPosTpfra     := 0
local nPosQtEmb     := 0
local nPosTpAlt     := 0
local nPosFabri     := 0
local nPosCodSi     := 0
local nPosNrRA      := 0
local nPosDtVA      := 0
local nPosClPro     := 0 
local nPosRefP      := 0
local nPosPrUF      := 0
local nColArq       := 0
local cTpArqimp     :=""
default cCaminho    := ""
default aDadosImp   := {}
default lAutoma     := .f.
default cCodmsg     :=""
default dDataMsg    := dDataVaz




if ( empty(cCaminho) .or. empty(aDadosImp) )
    Help(nil, nil , STR0001, nil, STR0002, 1, 0, nil, nil, nil, nil, nil, {STR0003} )//"Caminho do arquivo ou array com os dados estão inválidos"/ "Problema no retorno da função. Verifique"
else
    cVerAjs := padr(cCodmsg, TamSX3("B6F_EDICBR")[1], "")

    nTamConf := len(aDadosImp)
    iif( !lAutoma, oRegua:SetRegua1(nTamConf), "")
    for nFor := 1 to nTamConf
        if len(aDadosImp[nFor,6]) > 0
            iif( !lAutoma, oRegua:IncRegua1(STR0004 + cValToChar(nFor) + "] de [" +cValToChar(nTamConf)+"]"), "" )//Configuração [

            for nFor2:= 1 to len(aDadosImp[nFor,6]) 
                cArqCom  := cCaminho + aDadosImp[nFor,6,nFor2]
                cTipArq  := aDadosImp[nFor,1]
                cPrecSim := aDadosImp[nFor,2] 

                cTpArqimp := iif(".TXT" $ aDadosImp[nFor,6,nFor2],"TXT","CSV")
                BEGIN TRANSACTION

                  oArquivo := FWFileReader():New(cArqCom)
                  aCodBF8 := GeraConBF8(aDadosImp[nFor])
                  lGrvProc  := .t.      

                //Variáveis de posição do arquivo
                  nPosDescP := PosicArquivo(cTpArqimp,'cDescPro')  //3 Descrição do Produto
                  nPosPrFE  := PosicArquivo(cTpArqimp,'nPrecFabE') //6 Preço Fábrica Embalagem
                  nPosPrVE  := PosicArquivo(cTpArqimp,'nPrecVenE') //7 Preço Venda Embalagem
                  nPosPrUE  := PosicArquivo(cTpArqimp,'nPrecUsuE') //8 Preço Usuário Embalagem
                  nPosPrFF  := PosicArquivo(cTpArqimp,'nPrecFabF') //9 Preço Fábrica Fração
                  nPosPrVF  := PosicArquivo(cTpArqimp,'nPrecVenF') //10 Preço Venda Fração
                  nPosPrUF  := PosicArquivo(cTpArqimp,'nPrecUsuF') //11 Preço Usuário Fração
                  nPosTpEmb := PosicArquivo(cTpArqimp,'cTipEmb')   //12 Tipo de Embalagem
                  nPosTpfra := PosicArquivo(cTpArqimp,'cTipFrac')  //13 Tipo de Fração
                  nPosQtEmb := PosicArquivo(cTpArqimp,'cQtdEmb')   //14 Quantidade Embalagem
                  nPosTpAlt := PosicArquivo(cTpArqimp,'cTpAlt')    //17 Tipo de Alteração
                  nPosFabri := PosicArquivo(cTpArqimp,'cFrabri')   //18 Fabricante
                  nPosCodSi := PosicArquivo(cTpArqimp,'cCodSimpT') //19 Cód.SIMPRO/TISS
                  nPosNrRA  := PosicArquivo(cTpArqimp,'cNrRegAnv') //23 Número do Registro Anvisa 
                  nPosDtVA  := PosicArquivo(cTpArqimp,'cDtvldAnv') //24 Data de Validade do Registro Anvisa
                  nPosTuss  := PosicArquivo(cTpArqimp,'cCodTuss')  //29 Código TUSS
                  nPosClPro := PosicArquivo(cTpArqimp,'cClasProd') //30 Indica a classificação do produto
                  nPosRefP  := PosicArquivo(cTpArqimp,'cRefProd')  //31 Referência do Produto
                  cCodUnid  := alltrim( RetcBox("B6G_CODUND", cValtoChar(aImpB6G[6])) ) //1=REA;2=VMD;3=VMT
                  nColArq   := PosicArquivo(cTpArqimp,'',.t.)
                  cTissCdPad:= PLSGETVINC("BTU_CDTERM", "BR4", .f., "87", aCodBF8[2], .t.)
                                   
                 //regra do preço
                if  cValtoChar(aImpB6G[5]) == "1" .and. aDadosImp[nFor][2] =="1"    //1=Valor Total+"PMC" = Preço Venda Embalagem 
                    nTipPrec := nPosPrVE                                                                      
                elseif cValtoChar(aImpB6G[5]) == "1" .and. aDadosImp[nFor][2] =="2"  //1=Valor Total+"PFB" = Preço Fábrica Embalagem
                    nTipPrec := nPosPrFE   
                elseif cValtoChar(aImpB6G[5]) == "1" .and. aDadosImp[nFor][2] =="3"  //1=Valor Total+"PUSU" = Preço Usuário Embalagem
                    nTipPrec := nPosPrUE   
                elseif cValtoChar(aImpB6G[5]) == "2" .and. aDadosImp[nFor][2] =="1"  // 2=Valor Fracionado+"PMC" = Preço Venda Fração
                    nTipPrec := nPosPrVF   
                elseif cValtoChar(aImpB6G[5]) == "2" .and. aDadosImp[nFor][2] =="2"   //2=Valor Fracionado+"PFB" = Preço Fábrica Fração
                    nTipPrec := nPosPrFF   
                elseif cValtoChar(aImpB6G[5]) == "2" .and. aDadosImp[nFor][2] =="3"   //2=Valor Fracionado+"PUSU" = Preço usuario Fração
                    nTipPrec := nPosPrUF   
                endif

                  if (oArquivo:Open()) 
                      nTamReg := oArquivo:getFileSize()
                      iif(!lAutoma, oRegua:SetRegua2(-1), "")
                      oArquivo:setBufferSize(16384)
                     
                      while oArquivo:hasLine()
                          cLinha :=  oArquivo:GetLine() 
                          lGrvProc := .t.

                         //Senão tem separador valido ja na primeira linha, ignora o arquivo e passa para o proximo
                          if At( ";", cLinha) == 0 .or. At( ";", cLinha) > 16
                            GrvLogOperLog("2",STR0006+ aDadosImp[nFor,6,nFor2] + STR0026)//Arquivo "" Não é valido, o separador deve ser ponto e virgula(;)
                            lGrvB6F := .f.
                            exit 
                          endif

                          cLinha := LimpaNome(cLinha,";",.T.)
                          aLinhaLd := StrTokArr2( cLinha, ";",.T.)

                         /*Pode ter registros com colunas diferentes no meio do arquivo. Se maior que o total de colunas ou menor que a 
                         posição do Código Simpro, fica impossível de importar e registramos no log. 
                         Se o registro contiver colunas a menos que o esperado, mas tem a posição  do Cód. Simpro, preenchemos com vazio os demais*/
                         if ( len(aLinhaLd) > nColArq .or. len(aLinhaLd) < nPosCodSi )
                            /*O item: 'X' - Código da Apresentação: 'Y', possui registro inválido, com colunas a mais que o esperado.
                            Este registro não será importado. Verifique esse item no arquivo. */
                            lGrvProc := .f.
                            GrvLogOperLog("3", STR0021 + aLinhaLd[nPosDescP] + STR0022 + aLinhaLd[nPosCodSi] + STR0023 + STR0024)
                          elseif ( len(aLinhaLd) < nColArq .and. len(aLinhaLd) >= nPosCodSi )
                            for nFor3 := (len(aLinhaLd)+1) to nColArq
                                aadd(aLinhaLd, " ")
                            next
                          endif
                        
  
                          if lGrvProc
                              lRetGrProc := GeraProced(aCodBF8[1], aCodBF8[2],aCodBF8[3], aLinhaLd, cTipArq,cCodmsg, nPosTuss, nPosDescP,lForneBA8,lApreBA8,;//10
                                            nPosPrFE, nPosPrVE, nPosPrUE, nPosPrFF, nPosPrVF, nPosPrUF, nPosTpEmb, nPosTpfra, nPosQtEmb,nPosTpAlt,;//20
                                            nPosFabri, nPosCodSi, nPosNrRA, nPosDtVA, nPosClPro, nPosRefP,cCodUnid,nTipPrec,dDataMsg,cPrecSim,cTpArqimp,cTissCdPad )//32
                              lGrvB6F := iif(lGrvB6F, lGrvB6F, lRetGrProc )
                          endif
                          iif(!lAutoma, oRegua:IncRegua2(STR0005 + cvaltochar(oArquivo:getBytesRead()) + "] do total [" + cValToChar(nTamReg)+"]"), "") //"Lendo ["
                      enddo
                      iif(!lAutoma, oRegua:IncRegua2(" - "), "")
                      if lGrvB6F
                        GravaB6F(aDadosImp[nFor,6,nFor2], cCodmsg, aCodBF8[1], aImpB6G[4], cTipArq, cPrecSim)
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
local cTpProc   := iif( cValtoChar(aDados[1]) == "1", "1", iif( cValtoChar(aDados[1]) == "2", "2", "9" ) ) //1=Materiais;2=Medicamentos;3=Soluções;4=Perfumaria;5=Saneantes;6=Reagentes
local cCodTiss  := iif( cValtoChar(aDados[1]) == "1", "19", "20") 
local aRetFun   := {'', ''}
local lFncNivel := FindFunction("PlRetNivel")

B6G->(DbSetOrder(1))
BF8->(dbsetorder(1))
B6G->( dbgoto(aDados[4]) )
if B6G->B6G_CRITDE == "1"
    cCodTde := PLBF8VLC(cCodOpe)
    cNomeTip := substr("TABELA SIMPRO - " + alltrim(RetcBox("B6G_TIPPRO",cValtoChar(aDados[1]))),1,40)
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
local nFor2     := 0
local nSubs     := 0
default cSepard := ";"
default lImpExc := .f.

if lImpExc
    nSubs := aScan(aCaracSub, {|x| x == cSepard}) 
    if ( nSubs > 0 )
        aDel(aCaracSub, nSubs)
        aSize(aCaracSub, len(aCaracSub) - 1)
    endif
endif    

cDescri := fwcutoff(cDescri, .t.)
cDescri := strtran(cDescri, "&", "E")

for nFor2 := 1 to Len(aCaracSub)
    cDescri := strtran(cDescri, aCaracSub[nFor2],"")
next

return cDescri


//-------------------------------------------------------------------
/*/ {Protheus.doc} PosicArquivo
Essa função visa simplificar alterações futuras no layout, pois está no formato esperado de exportação do 
sistema Simpro. Caso tenha alguma alteração, basta alterar os arrays abaixo para a nova posição e chamá-la,
que irá retornar o novo local, sem precisar alterar outras partes do sistema, devido a mudança de layout.

Layouts aceitos, csv, txt.
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function PosicArquivo(cTipArq,cPesquisa,lContQtd)
local aLayCSV := {'cCodusu', 'cCodfrac', 'cDescPro', 'dDataVig','cIdent',; //5
                    'nPrecFabE','nPrecVenE','nPrecUsuE','nPrecFabF','nPrecVenF','nPrecUsuF',; //11
                    'cTipEmb','cTipFrac','cQtdEmb','cQtdeFraU','cLucrUsu','cTpAlt',; //17
                    'cFrabri','cCodSimpT','cCodMerc','nPerDesc','nIpiProd','cNrRegAnv',; //23
                    'cDtvldAnv','nNroCdBar','cTpList','cMedHosp','cProdFrac','cCodTuss',;//29
                    'cClasProd','cRefProd','cProdGen','cMedMatD'}//33

local aLayTXT:= {'cCodusu', 'cCodfrac', 'cDescPro', 'dDataVig','cIdent',; //5
                    'nPrecFabE','nPrecVenE','nPrecUsuE','nPrecFabF','nPrecVenF','nPrecUsuF',; //11
                    'cTipEmb','cTipFrac','cQtdEmb','cQtdeFraU','cLucrUsu','cTpAlt',; //17
                    'cFrabri','cCodSimpT','cCodMerc','nPerDesc','nIpiProd','cNrRegAnv',; //23
                    'cDtvldAnv','nNroCdBar','cTpList','cMedHosp','cProdFrac','cCodTuss',;//29
                    'cClasProd','cRefProd','cProdGen','cMedMatD'}//33
local nFor          := 0
local nQtdPosSimp   := 0
local layoutF       := 0
default cTipArq     := ""
default cPesquisa   := ""
default lContQtd    :=.f.

layoutF := iif(cTipArq=='CSV',aLayCSV,aLayTXT)

for nFor := 1 to len(layoutF)
    if lContQtd
        nQtdPosSimp := len(layoutF)
        exit
    else 
       if  upper(cPesquisa) == upper(layoutF[nFor])
            nQtdPosSimp := nFor
            exit
       endif
    endif
next

return nQtdPosSimp





//-------------------------------------------------------------------
/*/ {Protheus.doc} GeraProced
Inclui/Altera os procedimentos nas tabelas BA8/BR8/BD4
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GeraProced(cCodTab, cCodPad,cNivel, aDados, cTipArq, cCodMsg, nPosTuss, nPosDescP,lForneBA8, lApreBA8,; //10
              nPosPrFE, nPosPrVE, nPosPrUE, nPosPrFF, nPosPrVF, nPosPrUF, nPosTpEmb, nPosTpfra, nPosQtEmb,nPosTpAlt,;//20
              nPosFabri, nPosCodSi, nPosNrRA, nPosDtVA, nPosClPro, nPosRefP,cCodUnid,nTipPrec,dDataMsg,cPrecSim,cTpArqimp,cTissCdPad )//33
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
local dDataFim  := dDataVaz
local cDsClas   :=""
local cRegAnv   :=""
local cRefFab   :=""

//Verifica se o item possui código TUSS, para validar se é uma inclusão nova e demais regras
BD4->(dbsetorder(1))
BA8->(dbsetorder(1)) //BA8_FILIAL, BA8_CODTAB, BA8_CDPADP, BA8_CODPRO
BF8->(dbsetorder(1))
BTQ->(dbsetorder(1))
BTU->(dbsetorder(2)) //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_VLRSIS
BR8->(dbsetorder(1))

//Valores dos campos do Arquivo
cCodItem    := aDados[nPosTuss]
cDescItem   := aDados[nPosDescP] 
cFabric     := aDados[nPosFabri]   
cAprese     := STR0027 + aDados[nPosTpEmb]+' '+STR0028+aDados[nPosTpfra]+' '+STR0029+cValToChar(val(SubStr(aDados[nPosQtEmb],1,Len(aDados[nPosQtEmb])-2))) //"Tipo Embalagem:**" "Unidade:**" "Qtd. Embalagem:***"
cUnidad     := cCodUnid
nValItem    := PlRtValor(aDados[nTipPrec],cTpArqimp,nTipPrec)
dDataFim    := daysub(dDataMsg,1) //data para encerrar a vigência quando ja existe um BD4
cDsClas     := PlDesClas(aDados,nPosClPro) //Descrição da classificação do Produto
cRegAnv     := Alltrim(aDados[nPosNrRA])   //Nro registro anvisa ou ISENTO,NAO CONTROLADO,NOTIFICACAO,SI/NC
cRefFab     := Alltrim(aDados[nPosRefP])   //Referencia do Produto

if !empty( cCodItem )
    //Se não existir esse código na TDE, verifico se existe na própria 
    if !BA8->( MsSeek(cxFilBA8 + cCodOpe + cCodTab + cCodPad + cCodItem) )
        cCodTmp := aDados[nPosCodSi]
        VerTdeProp(cCodTmp, dDataFim, cCodMsg, dDataMsg)
        lInclusao := .t.
    else
        lImpAtual := FinalDtBD4(cCodOpe+cCodTab, cCodPad, cCodItem, dDataFim, cCodMsg, dDataMsg)
        lInclusao := .f.
        nRecBkp := BA8->(recno())
    endif  

else
    cCodItem  := aDados[nPosCodSi]
    aRetFun   := VerTdeProp(cCodItem,dDataFim, cCodMsg, dDataMsg)
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
        BA8->BA8_DSCLAS := cDsClas
        BA8->BA8_RGANVI := cRegAnv
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
        BD4->BD4_VIGINI	:= dDataMsg
        BD4->BD4_VIGFIM	:= dDataVaz
        BD4->BD4_VALREF := nValItem
        BD4->BD4_CHVIMP := "SIMPRO|" + cVerAjs + "|" + cTipArq + "|" + cPrecSim
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
            while BTQ->(BTQ_FILIAL + Alltrim(BTQ_CODTAB + BTQ_CDTERM)) == cxFilBTQ + alltrim(cTab64 + BA8->BA8_CODPRO)
                if( BTQ->BTQ_VIGDE == dDataMsg )
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
            BTQ->BTQ_VIGDE 	:= dDataMsg
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
            BTQ->BTQ_REFFAB := cRefFab
        BTQ->(MsUnlock())
    endif

    //De-Para automático no item
    if !lTdeProp
        //BTU_FILIAL+BTU_CODTAB+BTU_ALIAS+BTU_CDTERM
        lInclDeP := !BTU->( DbSeek(cxFilBTU + cTissCdPad + "BR8" + PADR(cxFilBR8 + BR8->(BR8_CODPAD+ BR8_CODPSA), nBTUCmp)) )
        BTU->(RecLock("BTU", lInclDeP))
            if lInclDeP
                BTU->BTU_FILIAL := cxFilBTU
                BTU->BTU_CODTAB := cTissCdPad
                BTU->BTU_VLRSIS := cxFilBR8 + BR8->BR8_CODPAD + BR8->BR8_CODPSA
                BTU->BTU_ALIAS  := "BR8"
            endif
            BTU->BTU_VLRBUS := BA8->BA8_CODPRO
            BTU->BTU_CDTERM := BA8->BA8_CODPRO 
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
static function VerTdeProp(cCodItem, dData, cCodMsg, dDataMsg)
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
    lImpAtual := FinalDtBD4(BA8->BA8_CODTAB, BA8->BA8_CDPADP, BA8->BA8_CODPRO, dData, cCodMsg, dDataMsg)
else
    lExsBA8 := .f.              
endif
return {lExsBA8, aImpB6G[4], nCdPadPro, nRecno, lImpAtual}


//-------------------------------------------------------------------
/*/ {Protheus.doc} GravaB6F
Grava a importação realizada na tabela B6F
@since 05/2020
@version P12
/*/
//-------------------------------------------------------------------
static function GravaB6F(cNomeArq, cCodMsg, cCodTab, cCodTabPro, cTipArq, cPrecBra, cTabTip)
local lInclui   := .t.
local dDataInc  := dDataImp
default cTabTip := "2" //1=Brasindice;2=Simpro;3=A900 

cCodMsg := cVerAjs

B6F->(dbsetorder(2))
if B6F->( MsSeek(cxFilBF6 + cCodOpe + cTabTip + cCodMsg + cTipArq + cPrecBra) ) //B6F_FILIAL+B6F_CODOPE+B6F_TPARQ+B6F_EDICBR+B6F_TIPPRO+B6F_TIPO
    lInclui := .f.
endif

B6F->(Reclock("B6F", lInclui))
    B6F->B6F_FILIAL := cxFilBF6
    B6F->B6F_CODIGO := iif(lInclui, GetSx8Num('B6F', 'B6F_CODIGO'), B6F->B6F_CODIGO)
    B6F->B6F_CODOPE := cCodOpe
    B6F->B6F_TPARQ  := '2' //1=Brasindice;2=Simpro;3=A900
    B6F->B6F_EDICBR := cCodMsg
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
/*/ {Protheus.doc} FinalDtBD4
Finaliza vigência na BD4 e checa se a versão Símpro é atual ou não, caso tenha 
importações anteriore
@since 04/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function FinalDtBD4(cCodTab, cCodPad, cCodPro, dData, cCodMsg, dDataInf)
local aDados    := {}
local cSql      := ''
local lRet      := .t.
default dData   := dDataImp

cSql := QueryBD4(cCodTab, cCodPad, cCodPro, dData, cCodMsg, .t.)
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
            if upper(aDados[1]) == "SIMPRO"
                if ( val(aDados[2]) < val(cCodMsg) ) 
                    lRet := GravaBD4Fim(TABBD4->REC, dData, dDataInf)    
                    if !lRet 
                        exit
                    endif
                else
                    /*Item: TDE('X') - Cod. Tp Saúde ('Y') - Evento('Z') encontra-se importado no sistema, com versão igual ou superior ('A')
                    a que está sendo importada neste momento (versão:'B'). O item não será importado. */
                    GrvLogOperLog("3", STR0014 + cCodTab + STR0015 + cCodPad + STR0016 + cCodPro + STR0017 +;
                                aDados[2] + STR0018 + cCodMsg + STR0019)
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
static function QueryBD4(cCodTab, cCodPad, cCodPro, dData, cCodMsg, lChave)
local cSql  := ""
default lChave := .f.

cSql := " SELECT R_E_C_N_O_ REC, BD4_CHVIMP CHAVE FROM " + RetSqlName("BD4")
cSql += " WHERE "
cSql += " BD4_FILIAL     = '" + cxFilBD4 + "' "
cSql += " AND BD4_CODTAB = '" + cCodTab  + "' "
cSql += " AND BD4_CDPADP = '" + cCodPad  + "' "
cSql += " AND BD4_CODPRO = '" + cCodPro  + "' "
cSql += " AND (BD4_VIGFIM = ' ' OR BD4_VIGFIM > '" + cDatDtoS + "') "
cSql += " AND D_E_L_E_T_ = ' '  "
cSql += " ORDER BY BD4_CHVIMP DESC "

return cSql


//-------------------------------------------------------------------
/*/ {Protheus.doc} GrvLogOperLog
Grava no array aOperLog (fonte PLSSIMPRO, função OprLogSist), as informações de erro encontradas nas operações, para exibir
no final de todo processamento, para o usuário verificar.
*cTipErro: 0=Arquivo duplicado regras / 1=Info Arquivos Orfãos / 2=Erro Importação / 3=Registro não importado
@since 05/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function GrvLogOperLog(cTipErro, cMensagem)
staticcall(PLSSIMPRO, OprLogSist, cTipErro, cMensagem) 
return 


/*/{Protheus.doc} PlRtValor
    Retorna valor conforme Layout
    @type  Static Function
    @since 08/09/2021
    @return return_var, return_type, return_description
/*/
Static Function PlRtValor(nValor,cArquivo,cTipValor)

Default nValor  :=0
Default arquivo :=0

if cArquivo == "TXT"
    if cTipValor == 6 .or. cTipValor == 7 .or. cTipValor == 8 //6 Preço Fábrica Embalagem |7 Preço Venda Embalagem | 8 Preço Usuário Embalagem
        nValor := SubStr(nvalor,1,Len(nvalor)-2) + "." + SubStr(nvalor,Len(nvalor)-1)
    else 
        nValor := SubStr(nvalor,1,Len(nvalor)-3) + "." + SubStr(nvalor,Len(nvalor)-2) //FRACIONADOS
    endif    
 else 
    if cTipValor == 6 .or. cTipValor == 7 .or. cTipValor == 8 //6 Preço Fábrica Embalagem |7 Preço Venda Embalagem | 8 Preço Usuário Embalagem
        nValor := SubStr(nvalor,1,Len(nvalor)-2) + "." + SubStr(nvalor,Len(nvalor)-1)
    else 
        nValor := SubStr(nvalor,1,Len(nvalor)-3) + "." + SubStr(nvalor,Len(nvalor)-2)//FRACIONADOS
    endif  
endif 

Return val(nValor)

/*/{Protheus.doc} PlDesClas
    Retorna a descrição da classificação do produto 
    @type  Static Function
    @since 15/09/2021
    @param nPosClPro --da classificação do produto  no Array
    @return classificação do produto
/*/
Static Function PlDesClas(aDados,PlDesClas)
local aCodDes := {'BD','MC','ME','OT','PT','ST','IT'}
local aDescri := {'BEM DURAVEL','MATERIAL DE CONSUMO','MATERIAL ESPECIAL',;
                  'ORTESE','PROTESE','SINTESE', 'INSTRUMENTAL'}
local nFor    :=0 
local cRet    := ""

for nFor= 1 to len(aCodDes)
    if UPPER(aDados[PlDesClas]) == UPPER(aCodDes[nFor])
        cRet := aDescri[nFor]
        exit
    endif
next

if empty(cRet) 
    cRet:='SEM CLASSIFICACAO'
endif

Return cRet
