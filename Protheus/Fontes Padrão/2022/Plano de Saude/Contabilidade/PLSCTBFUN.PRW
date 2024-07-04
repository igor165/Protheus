#INCLUDE 'PROTHEUS.CH'
#INCLUDE "PLSCTBFUN.CH"
#INCLUDE "PLSMGER.CH"

#DEFINE LP_FDESP 10
#DEFINE LP_FLTAV 20
#DEFINE LP_FRECE 30
#DEFINE LP_DLTAV 40
#DEFINE LP_DLTAC 50
#DEFINE LP_DLRAT 60

#DEFINE LP_P9CN    1
#DEFINE LP_P9CT    2
#DEFINE LP_P9AG    3
#DEFINE LP_P9BD9BL 4
#DEFINE LP_P9NB9NC 5
#DEFINE LP_P9LA    6
#DEFINE LP_P9LB    7
#DEFINE LP_P9LC    5
#DEFINE LP_P9LD    6

#DEFINE LP_P9A1    1
#DEFINE LP_P9AX9B6 2
#DEFINE LP_P9NX9N6 3
#DEFINE LP_P9A2    4

#DEFINE LP_PROVISAO_11		"9A1"
#DEFINE LP_PROVISAO_12		"9A2"

#DEFINE LP_PROVISAO_06		"9CN"
#DEFINE LP_CUSTO_06		    "9CT"

#DEFINE LP_PROVISAO_LA_06	"9LA"
#DEFINE LP_CUSTO_LA_06		"9LB"

#DEFINE LP_PROVISAO_LA_11   "9LC"
#DEFINE LP_PROVISAO_LAC_11  "9LD"

#DEFINE LP_RATEIO			"9A3"
#DEFINE LP_RATEIO_BAIXA_NB	"9NA"
#DEFINE LP_RATEIO_BAIXA		"9AA"
#DEFINE LP_RATEIO_CANCBX_NB "9N7"
#DEFINE LP_RATEIO_CANCBX 	"9B7"

#DEFINE DIGITACAO 	"1"

#DEFINE G_REEMBOLSO "04"
#DEFINE G_HONORARIO "06"
#DEFINE G_RES_INTER "05"
#DEFINE G_SOL_INTER "03"
#DEFINE G_PRORROGAC "11"
#DEFINE G_OUTRADESP "12"
#DEFINE G_ANEXQUIMI "07"
#DEFINE G_ANEXRADIO "08"
#DEFINE G_ANEXOPME  "09"

static __cSC7CodRDA	:= ""
static __lSC7LTPLS	:= .f.
static __aSC7DadPLS	:= {}
static __cFunName	:= upper(funName())
static __nLastFlg	:= 0
static lMV_PLSNECT	:= nil
static __lOracle	:= nil

/*/{Protheus.doc} PROMThread
Prepara as informacoes para o processamento multithread
@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function PROMThread(cTabMult, cTipo, nParTipCtb, cLp, cAliasPri)
    local aArea 	:= getArea()
    local nCount 	:= 0
    local cDirSem  	:= "\semaforo\"
    local cChave	:= ""
    local cCondic	:= ""
    local cReg		:= ""
    local aProcs	:= {}
    local lVal		:= .t.

    default cLp		:= "INDEF"

    //despesa - chave definida na quebra de querys do processo thread
    if cTipo == 'DES'

        //quebra por peg e protocolo
        if nParTipCtb == LP_P9CN .or. nParTipCtb == LP_P9CT

            cReg  	:= 'BD7 - REG -> '
            if nParTipCtb == LP_P9CN
                cCondic := cTabMult + "->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_PROTOC + BD7_DTDIGI)"
            else
                cCondic := cTabMult + "->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_PROTOC + BD7_DTCTBF)"
            endif
            lVal	:= .f.

            //quebra titulo
        elseIf nParTipCtb == LP_P9AG

            cReg   	 := 'SE2 - REG -> '
            cCondic  := cTabMult + "->SE2Recno"

            //quebra baixa ou cancelamento da baixa
        elseIf nParTipCtb == LP_P9BD9BL .or. nParTipCtb == LP_P9NB9NC

            cReg   	 := 'FK2 - REG -> '
            cCondic  := cTabMult + "->FK2Recno"

            //quebra provisao/cobranca lote aviso
        elseIf nParTipCtb == LP_P9LA .or. nParTipCtb == LP_P9LB

            cReg  	:= 'B6T - REG -> '
            cCondic := cTabMult + "->(B6T_SEQLOT + B6T_NMGPRE)"
            lVal	:= .f.

        endIf

        //receita - chave definida na quebra de querys do processo thread
    elseIf cTipo == 'REC'

        //quebra por recno SE1 ou FK1
        if nParTipCtb == LP_P9A1 .or. nParTipCtb == LP_P9A2

            cReg  	:= 'SE1 - REG -> '
            cCondic := cTabMult + "->SE1Recno"

        elseIF nParTipCtb == LP_P9AX9B6 .or. nParTipCtb == LP_P9NX9N6

            cReg  	:= 'FK1 - REG -> '
            cCondic := cTabMult + "->FK1Recno"

            //quebra provisao
        elseIf nParTipCtb == LP_P9LC .or. nParTipCtb == LP_P9LD

            cReg  	:= 'B6S - REG -> '
            cCondic := cTabMult + "->(B6S_NUMLOT + B6S_CODOPE + B6S_CODLDP + B6S_CODPEG)"
            lVal	:= .f.

        endIf

    endIf

    //Cria a pasta do semaforo caso não exista
    if ! existDir(cDirSem)
        montaDir(cDirSem)
    endIf

    if ! (cTabMult)->(eof())

        (cTabMult)->(dbGoTop())

        while ! (cTabMult)->(eof())

            if cChave <> iIf(lVal, allTrim( cValToChar( &(cCondic) ) ), &(cCondic) )

                cChave := iIf(lVal, allTrim( cValToChar( &(cCondic) ) ), &(cCondic) )
                nCount++

                FWLogMsg('INFO',, 'SIGAPLS', funName(), '', '01', STR0007 + strZero(nCount,10 ) + ' ] - ' + cReg + allTrim(cChave) , 0, 0, {})//'Lendo registro [ '

                aadd(aProcs, { strTran(strTran(cChave, chr(13), ''),chr(10),''), nCount, cReg } )

            endIf

            (cTabMult)->(dbSkip())
        endDo

    endIf

    restArea(aArea)

return(aProcs)

/*/{Protheus.doc} plsErr
tratamento de erro
@author  PLS TEAM
@version P12
@since   15.05.19
/*/
function plsErr(cErro, lMsg)
    local nPos := 0

    default lMsg := .f.

    if lMsg

        msgStop(cErro, STR0031)

        FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', cErro, 0, 0, {})

    else

        if ! empty(cErro)

            nPos  := at('THREAD ERROR', cErro)
            cErro := subStr(cErro, nPos, len(cErro))

            msgStop(cErro, STR0031)

        endIf

    endIf

return

/*/{Protheus.doc} SGrid
Inicia Grid
@author  PLS TEAM
@version P12
@since   15.05.19
/*/
function SGrid(aStart)
    local lRet 		:= .t.
    local cEmpParm  := aStart[1]	// Empresa conectada 	--> cEmpAnt
    local cFilParm  := aStart[2]	// Filial conectada 	--> cFilAnt
    local cProg		:= aStart[3]

    FWLogMsg('INFO',, 'SIGAPLS', funName(), '', '01', "Iniciando Ambiente", 0, 0, {})

    rpcSetType(3)
    rpcSetEnv(cEmpParm, cFilParm,,,, cProg, { "BD7", "BM1", "SE1", "FK1", "SE2", "FK2", "CT2", "CTK", "CV3" } )

    nModulo := 33 //SIGAPLS

return(lRet)

/*/{Protheus.doc} fGrid
Finalisa Grid
@author  PLS TEAM
@version P12
@since   15.05.19
/*/
function fGrid()

    FWLogMsg('INFO',, 'SIGAPLS', funName(), '', '01', "Processo de finalização dos agentes concluido (Terminate)", 0, 0, {})

return

/*/{Protheus.doc} plFiePar
querbra conteudo do campo com chave conctenada
@author  PLS TEAM
@version P12
@since   15.05.19
/*/
function plFiePar(cKey, cField, lPipe, cSubField, lCont)
    local aMat 		:= strTokArr2( cKey, "|" )
    local nI		:= 0
    local cInicial 	:= ''
    local cTam 		:= ''
    local cFieldKey	:= ''
    local cSql		:= ''
    local cSubStr	:= ''
    local cFilSub	:= ''

    default lPipe 		:= .t. //se o cField contem algum pipe tipo "|" no conteudo da chave
    default cSubField 	:= ''
    default lCont		:= .f.

    //verifica qual banco de dados
    getTpDB(@__lOracle)

    cSubStr := iIf( __lOracle, 'SUBSTR(', 'SUBSTRING(' )

    for nI := 1 to len(aMat)

        cFieldKey := aMat[nI]

        if empty(cInicial)
            cInicial := '1'
        else

            if empty(cSubField)
                cInicial := cValToChar( val(cInicial) + val(cTam) + iIf( lPipe, 1, 0 ) )
            else
                cInicial := cValToChar( val(cInicial) + val(cTam) )
            endIf

        endIf

        cTam := cValToChar( tamSX3(cFieldKey)[1] )

        if empty(cSubField)

            if lCont
                cSql += " " + cFieldKey + " = '" + subStr( cField, val(cInicial), val(cTam) ) + "' " + iIf(nI < len(aMat), 'AND', '')
            else
                cSql += " " + cFieldKey + " = " + cSubStr + cField + "," + cInicial + "," + cTam + " ) " + iIf(nI < len(aMat), 'AND', '')
            endIf

        else

            if empty(cSql)

                cFilSub  := subStr(cKey, 1, at('_',cKey) - 1)
                cFilSub  := iIf( len( allTrim(cFilSub) ) == 2, 'S','') + cFilSub
                cInicial := ''

                cSql += " " + cField + " = '" + xFilial(cFilSub) + "|' + "

            else

                cSql += cSubStr + cSubField + "," + cInicial + "," + cTam + " ) " + iIf(lPipe, iIf(nI < len(aMat), " + '|' + ", ''), '')

            endIf

        endIf

    next

return( cSql )


/*/{Protheus.doc} PLSMONFLAG
guarda recnos posicionados para monta aflag
@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function PLSMONFLAG(aRec, nTipo, cLp, lProc)

    //despesas
    if nTipo == LP_FDESP .and. lProc

        aadd(aRec, { BD7->( recno() ), cLp, lProc, CTK->(recno()) } )

        //despesas - provisao lote aviso
    elseIf nTipo == LP_FLTAV .and. lProc

        aadd(aRec, { B6T->( recno() ), cLp, lProc, CTK->(recno()) } )

        //receita
    elseIf nTipo == LP_FRECE .and. lProc

        aadd(aRec, { BM1->( recno() ), cLp, lProc, CTK->(recno()) } )

        //receita - provisao lote aviso
    elseIf (nTipo == LP_DLTAV .or. nTipo == LP_DLTAC) .and. lProc

        aadd(aRec, { B6S->( recno() ), cLp, lProc, CTK->(recno()) } )

        //Rateio de Impostaos
    elseIf (nTipo == LP_DLRAT ) .and. lProc

        aadd(aRec, { B6U->( recno() ), cLp, lProc, CTK->(recno()) } )
    endIf

return()

/*/{Protheus.doc} PLSCA100

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function PLSCA100(cArquivo, nHdlPrv, cLote, nTotal, lCabecalho, aFlagPLS, dDtLote, lMostraLC, lAglut, cLP, nTipo, cThReadID, cRotina, aFlagCTB)
    local aArea 		:= getArea()
    local nI			:= 0
    local lRet			:= len(aFlagPLS) > 0

    default aFlagCTB	:= {}

    dDtLote := iIf(dDtLote == nil, dDataBase, dDtLote)

    if nHdlPrv > 0

        rodaProva(nHdlPrv, nTotal)

        CA100INCL(cArquivo, nHdlPrv, 3, cLote, lMostraLC, lAglut,, dDtLote,, @aFlagCTB)

        //alimenta chave da ct2
        if lRet
            CTK->(dbsetOrder(1))
            for nI := 1 to len(aFlagPLS)

                if ! aFlagPLS[nI, 3]
                    loop
                endIf

                CTK->( msGoTo(aFlagPLS[nI, 4]) )

                cCtkSequen := CTK->CTK_SEQUEN
                cCtkRecori := CTK->CTK_RECORI

                //Quando a descrição do LP é muito grande gera CTKs complementares, que não tem o recno
                //Quando mais de uma sequência do LP é processada, pode gerar CTKs sem valor além dos CTK com valor
                //exemplo: o LP 9CT tem as sequências 001, 002, 003 e 004 configuradas, na contabilização todas são processadas
                //e irão gerar os CTK correspondentes. Caso somente as sequências 001 e 002 retornem valores para contabilizar, os CTK referente a eles
                //vão ter Recno, porém, os das sequências 003 e 004 não terão. Com isso, temos que voltar olhando tanto se é um CTK complementar (CTK_DC = 4) ou 
                //se naquela contabilização (CTK_SEQUEN), aquela origem (CTK_RECORI) teve valor contabilizado (geração do CT2 vinculado)
                //o recno que temos é do último CTK gerado, com ele nós voltamos até achar um CTK dessa contabilização e dessa origem, que tenha um CT2 vinculado
                While (CTK->(CTK_DC) == "4" .OR. empty(CTK->CTK_RECDES)) .And. CTK->CTK_SEQUEN == cCtkSequen .AND. CTK->CTK_RECORI == cCtkRecori
                    CTK->(dbskip(-1))
                endDo

                //Se parar em um RECDES vazio (sem CT2), se mudar a sequência não é mais da contabilização atual ou mudar o recno original não é mais do registro original atual 
                //não marca a origem
                if empty(CTK->CTK_RECDES) .OR. CTK->CTK_SEQUEN <> cCtkSequen .OR. CTK->CTK_RECORI <> cCtkRecori
                    loop
                endif

                CT2->( msGoTo(val(CTK->CTK_RECDES)))

                //Despesas
                if nTipo == LP_FDESP

                    BD7->( msGoTo(aFlagPLS[nI, 1]) )

                    if aFlagPLS[nI, 2] == LP_PROVISAO_06

                        BD7->(recLock("BD7",.f.))
                        BD7->BD7_LAPRO  := "S"
                        BD7->BD7_DTPRO  := dDtLote
                        BD7->BD7_CHVPRO	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        BD7->(msUnLock())

                    elseIf aFlagPLS[nI, 2] == LP_CUSTO_06

                        BD7->(recLock("BD7",.f.))
                        BD7->BD7_LA  	:= "S"
                        BD7->BD7_DTLA  	:= dDtLote
                        BD7->BD7_CHVLA	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        BD7->(msUnLock())

                    endIf

                    //Despesa - provisao lote aviso
                elseIf nTipo == LP_FLTAV

                    B6T->( msGoTo(aFlagPLS[nI,1]) )

                    if aFlagPLS[nI, 2] == LP_PROVISAO_LA_06

                        B6T->(recLock("B6T",.f.))
                        B6T->B6T_LAPRO  := "S"
                        B6T->B6T_DTPRO  := dDtLote
                        B6T->B6T_CHVPRO	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        B6T->(msUnLock())

                    elseIf aFlagPLS[nI, 2] == LP_CUSTO_LA_06

                        B6T->(recLock("B6T",.f.))
                        B6T->B6T_LA  	:= "S"
                        B6T->B6T_DTLA  	:= dDtLote
                        B6T->B6T_CHVLA	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        B6T->(msUnLock())

                    endIf

                    //receita
                elseIf nTipo == LP_FRECE

                    BM1->( msGoTo(aFlagPLS[nI,1]) )

                    if aFlagPLS[nI, 2] == LP_PROVISAO_11

                        BM1->( recLock("BM1",.f.) )

                        if BM1->(BM1_ANO + BM1_MES) > left(dtos(dDtLote),6)
                            BM1->BM1_LAFAT := "P"
                        endIf

                        BM1->BM1_LAPRO := "S"
                        BM1->BM1_DTPRO  := dDtLote
                        BM1->BM1_CHVPRO	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        BM1->(msUnLock())

                    elseIf aFlagPLS[nI, 2] == LP_PROVISAO_12

                        BM1->( recLock("BM1",.f.) )
                        BM1->BM1_LAFAT 	:= "S"
                        BM1->BM1_DTFAT  := dDtLote
                        BM1->BM1_CHVFAT	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        BM1->(msUnLock())

                    endIf

                    //Receita - provisao lote aviso
                elseIf nTipo == LP_DLTAV

                    B6S->( msGoTo(aFlagPLS[nI,1]) )

                    if aFlagPLS[nI, 2] == LP_PROVISAO_LA_11

                        B6S->(recLock("B6S",.f.))
                        B6S->B6S_LAPRO  := "S"
                        B6S->B6S_DTPRO  := dDtLote
                        B6S->B6S_CHVPRO	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        B6S->(msUnLock())

                    endIf

                    //Receita - cobranca lote aviso
                elseIf nTipo == LP_DLTAC

                    B6S->( msGoTo(aFlagPLS[nI,1]) )

                    if aFlagPLS[nI, 2] == LP_PROVISAO_LAC_11

                        B6S->(recLock("B6S",.f.))
                        B6S->B6S_LA  	:= "S"
                        B6S->B6S_DTLA  	:= dDtLote
                        B6S->B6S_CHVLA	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        B6S->(msUnLock())

                    endIf
                    //Receita - cobranca lote aviso
                elseIf nTipo == LP_DLRAT

                    B6U->( msGoTo(aFlagPLS[nI,1]) )

                    If aFlagPLS[nI, 2] $ LP_RATEIO+"/"+LP_RATEIO_BAIXA_NB+"/"+LP_RATEIO_BAIXA+"/"+LP_RATEIO_CANCBX_NB+"/"+LP_RATEIO_CANCBX

                        B6U->(RecLock("B6U", .F.))
                        If aFlagPLS[nI, 2] $ LP_RATEIO_CANCBX_NB+"/"+LP_RATEIO_CANCBX
                            B6U->B6U_LA_CAN := "S"
                        Else
                            B6U->B6U_LA := "S"
                        EndIf
                        B6U->B6U_DATPRO := dDtLote
                        B6U->B6U_CHVPRO	:= CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)
                        B6U->(MsUnLock())

                    EndIf

                endIf

            next

        endIf

        lCabecalho 	:= .f.
        cArquivo	:= ""
        nHdlPrv 	:= 0
        nTotal 		:= 0

        aFlagCTB 	:= aSize(aFlagCTB, 0)
        aFlagCTB 	:= {}

        aFlagPLS 	:= aSize(aFlagPLS, 0)
        aFlagPLS 	:= {}

    endIf

    restarea(aArea)

return(lRet)

/*/{Protheus.doc} PLSCTBCABEC

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function PLSCTBCABEC(nHdlPrv, cArquivo, lCriar, lCabecalho, cRotina, cLote)
    local aArea := getArea()

    lCriar 		:= iIf(lCriar == nil, .f., lCriar)
    nHdlPrv 	:= headProva( cLote, cRotina, substr(cUsuario,7,6), @cArquivo, lCriar )
    lCabecalho 	:= .t.

    restarea(aArea)

return

/*/{Protheus.doc} PLVLDISAPR
Distribui valor apresentado do bd6 no bd7
@author  PLS TEAM
@version P12
@since   27.10.16
/*/
function PLVLDISAPR(cAliasCAB, cMatricUsr, dDataCTB, cCodRda, dDatPro, cCodLoc, cChaveBD7)
    local aArea			:= getArea()
    local aAreaBD6 		:= BD6->(getArea())
    local aAreaBD7 		:= BD7->(getArea())
    local nJ			:= 0
    local nVlrTotEve	:= 0
    local nPos			:= 0
    local cRegAte 		:= ""
    local cSigla  		:= ""
    local cTipoGuia		:= ""
    local cOriMov	 	:= ""
    local cRegPag		:= ""
    local cRegCob		:= ""
    local cRegInt		:= ""
    local cFinAte		:= ""
    local cTipAdm 		:= ""
    local cCodPad   	:= BD6->BD6_CODPAD
    local cCodPro	  	:= BD6->BD6_CODPRO
    local aRdas			:= {}
    local aRetB43		:= {}
    local aAux			:= {}
    local aDadUsr		:= {}
    local aDadRDA		:= {}
    local aMatTOTBD7	:= {}
    local aPacote 		:= {0,0,{},""}
    local lCirurgico	:= .f.
    local lReembolso	:= .f.

    if BD6->BD6_FASE == DIGITACAO

        aDadUsr := PLSGETUSR()

        if ( empty(aDadUsr) .or. aDadUsr[2] != cMatricUsr )
            aDadUsr	:= PLSDADUSR(cMatricUsr,'1',.t.,dDataCTB)
        endIf

        aDadRDA := PLSGETRDA()

        if ( empty(aDadRDA) .or. aDadRDA[2] != cCodRda )
            aDadRDA := PLSDADRDA(plsIntPad(),cCodRda,'1',dDatPro,cCodLoc)
        endIf

        if ( len(aDadUsr) > 0 .and. !aDadUsr[1]) .or. ( len(aDadRda) .and. !aDadRda[1] )
            PlGrvlog('problemas na aDatUsr ou aDadRda - chave [' +  BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) + '] ', 'PLSCTB' , 1, .t., funName())
            return
        endIf

        BR8->( msSeek( xFilial("BR8") + cCodPad + cCodPro ) )

        if !(cAliasCAB)->( msSeek( xFilial(cAliasCAB) + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) ) )
            PlGrvlog('não encontrado cabecalho da guia - chave [' +  BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) + '] ', 'PLSCTB' , 1, .t., funName())
            return
        endIf

        cMatricUsr	:= (cAliasCAB)->&(cAliasCAB+"_OPEUSR") + (cAliasCAB)->&(cAliasCAB+"_CODEMP") + (cAliasCAB)->&(cAliasCAB+"_MATRIC") + (cAliasCAB)->&(cAliasCAB+"_TIPREG") + (cAliasCAB)->&(cAliasCAB+"_DIGITO")

        if cAliasCAB == 'BE4'

            cRegAte 	:= "1" //regime internacao
            cSigla  	:= (cAliasCAB)->&(cAliasCAB+"_SIGLA")

        else

            if cTipoGuia $ ( G_SOL_INTER + "|" + G_RES_INTER )
                cRegAte := '1'
            else
                cRegAte := (cAliasCAB)->&(cAliasCAB+"_REGATE")
            endIf

            cSigla  := (cAliasCAB)->&(cAliasCAB+"_SIGEXE")

        endIf

        cTipoGuia:= (cAliasCAB)->&(cAliasCAB+"_TIPGUI")
        cOriMov	 := (cAliasCAB)->&(cAliasCAB+"_ORIMOV")

        if cTipoGuia == G_REEMBOLSO
            lReembolso := .t.
        endIf

        //internacao
        if cTipoGuia $ (G_RES_INTER + "|" + G_HONORARIO)
            cRegInt := BE4->BE4_REGINT
        endIf

        if BD6->(fieldPos('BD6_REGPAG')) > 0
            cRegPag := BD6->BD6_REGPAG
        endif

        if BD6->(fieldPos('BD6_REGCOB')) > 0
            cRegCob := BD6->BD6_REGCOB
        endif

        if &(cAliasCAB)->( fieldPos( cAliasCAB + "_TIPPAC" ) ) > 0
            cFinAte := (cAliasCAB)->&(cAliasCAB + "_TIPPAC")
        else
            cFinAte := getNewPar("MV_PLSTPAA","9")
        endif

        if &(cAliasCAB)->( fieldPos( cAliasCAB + "_TIPADM" ) ) > 0
            cTipAdm := (cAliasCAB)->&(cAliasCAB + "_TIPADM" )
        endif

        // Monta matriz rdas
        aRdas := PLS720IBD7("0",0,BD6->BD6_CODPAD,BD6->BD6_CODPRO,"",;
            (cAliasCAB)->&(cAliasCAB+"_OPERDA"),(cAliasCAB)->&(cAliasCAB+"_CODRDA"),(cAliasCAB)->&(cAliasCAB+"_REGEXE"),;
            cSigla,(cAliasCAB)->&(cAliasCAB+"_ESTEXE"),(cAliasCAB)->&(cAliasCAB+"_CDPFRE"),;
            (cAliasCAB)->&(cAliasCAB+"_CODESP"),(cAliasCAB)->&(cAliasCAB+"_CODLOC"),;
            "3",BD6->BD6_SEQUEN,cOriMov,cTipoGuia)

        // Se e cirurgico ou nao
        lCirurgico := (BR8->BR8_TIPEVE == "2") //1=Clinico;2=Cirurgico;3=Ambos

        if PLSALIASEXI("B43")

            aRetB43 := PlRetPac((cAliasCAB)->&(cAliasCAB+"_OPERDA"),(cAliasCAB)->&(cAliasCAB+"_CODRDA"),cCodPad,cCodPro,nil,(cAliasCAB)->&(cAliasCAB+"_DATPRO"))

            for nJ := 1 To len(aRetB43)

                aadd(aPacote[3],{aRetB43[nJ][1],aRetB43[nJ][2],aRetB43[nJ][5],aRetB43[nJ][4],aRetB43[nJ][6],aRetB43[nJ][9]})

                aPacote[1] += aRetB43[nJ][5]
                aPacote[2] += aRetB43[nJ][4]
                aPacote[4] := aRetB43[nJ][10]
            next

        endIf

        //Calcula o valor do procedimento
        aValor := PLSCALCEVE(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_MESPAG,BD6->BD6_ANOPAG,BD6->BD6_OPEORI,;
            BD6->BD6_CODRDA,BD6->BD6_CODESP,iIf(len(aDadRda)>0,aDadRda[21],''),BD6->BD6_CODLOC,;
            BD6->BD6_QTDPRO,BD6->BD6_DATPRO,iIf(len(aDadUsr),aDadUsr[48],''),(cAliasCAB)->&(cAliasCAB+"_PADINT"),;
            cRegAte,BD6->BD6_VLRAPR,aDadUsr,(cAliasCAB)->&(cAliasCAB+"_PADCON"),;
            {},nil,nil,nil,nil,BD6->BD6_HORPRO,aRdas,nil,BD6->BD6_PROREL,BD6->BD6_PRPRRL,{},;
            lReembolso,BD6->BD6_DATPRO,substr(strtran(BD6->BD6_HORPRO,':',""),1,4),{},cTipoGuia,;
            .f.,BD6->BD6_VLRAPR,{},nil,lCirurgico,BD6->BD6_PERVIA,cRegPag,cRegCob,BD6->BD6_QTDPRO,;
            nil,aPacote, BD7->(BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV),;
            BD6->BD6_SEQUEN, nil, nil, cRegInt, cFinAte, nil, nil, nil, .f., nil, cTipAdm, {}, , BD6->BD6_RDAEDI)

        if len(aValor) > 0

            aAux	 	:= aValor[1]
            nVlrTotEve 	:= aValor[2]

            //distribui o valor apresentado do bd6 na bd7 conforme valor apresentado
            if nVlrTotEve > 0

                plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)

                while ! TRBBD7->(eof())

                    BD7->( dbGoTo( TRBBD7->REC ) )

                    nPos := ascan(aAux,{|x| allTrim(x[1]) == allTrim(BD7->BD7_CODUNM)})

                    if nPos > 0 .and. len(aAux[nPos][5]) > 0

                        PLDISBD7(nVlrTotEve, aAux[nPos][5][1][4])

                        //guarda total do bd7 para posterior conferencia
                        getTotBD7(aMatTOTBD7)

                    else
                        PlGrvlog(STR0020 + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) + STR0021 + allTrim(BD7->BD7_CODUNM) + ']', 'PLSCTB' , 1, .t., funName())//'Unidade não encontrada ou valor não definido na composição do evento! guia [' ##'] unidade ['
                    endIf

                    TRBBD7->(dbSkip())
                endDo

                TRBBD7->(dbCloseArea())

            endIf
        else
            PlGrvlog('problemas na PLSCALCEVE - chave [' +  BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO) + '] ', 'PLSCTB' , 1, .t., funName())
        endIf

    else

        if BD7->( msSeek(cChaveBD7) )

            while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cChaveBD7

                if BD7->BD7_PERCEN > 0

                    PLDISBD7(BD6->BD6_VLRBPR, BD7->BD7_VLRBPR)

                    //guarda total do bd7 para posterior conferencia
                    getTotBD7(aMatTOTBD7)

                endIf

                BD7->(dbSkip())
            endDo

        endIf

    endIf

    //verifica se o total do BD7 esta igual ao BD6 e ajusta
    if len(aMatTOTBD7) > 0
        setAjuGUI(aMatTOTBD7)
    endIf

    BD6->( restArea(aAreaBD6) )
    BD7->( restArea(aAreaBD7) )

    restArea(aArea)

return

/*/{Protheus.doc} PLSLogCTB
Log da contabilidade

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function PLSLogCTB(cRotina, lDate)
    local cFile := ''

    default lDate := .t.

    if lDate
        cFile := cRotina + "_" + dtos(Date()) + "_" + allTrim(Str(thReadID())) + "_" + allTrim(getComputerName()) + ".LOG"
    else
        cFile := cRotina + "_" + allTrim(Str(thReadID())) + "_" + allTrim(getComputerName()) + ".LOG"
    endIf

    cFile := strTran(cFile,'/','_')

return( cFile )

/*/{Protheus.doc} PLSRATT
Retorna valor do rateio
Rateio do imposto, titulo, titulo negociado, baixa, proporcao do imposto sobre a baixa ou sobre qualquer valor (nValBas)

cAlias	 - Alias de trabalho SE1 ou SE2
nValRat  - Valor de Rateio Ex.: BM1_VALOR ou BD7_VLRPAG
cId 	 - Identificador da LP (sequencia)
cImp     - Valor a ser usado sobre o valor do titulo para proporcao. Ex.: Impostos ou Descontos/Acrescimo.
cImpRet  - Valor a ser abatido de cImp para casos de retorno de valor restando a ser pago
lConBX	 - considerar valores de rateio na baixa
cValEsp	 - Valor Especifico para rateio ex.: PDD

Variaveis utilizadas
nPercen    - contem o percentual de nValRat sobre o valor total do titulo
nValBas	   - valor base para rateio depende da LP (pode ser sobre o valor do titulo ou da baixa)
nVlrCal	   - guarda o valor proporcional sobre as regras acima se encontrar zero deve colocar um 0.00001 para registrar nas CTK e CV3. Ex.: Resultado final gravado no contabil.
cChv???    - variaveis globais para controle de rateio x multThRead
nThReadTit - valor total do titulo
nVlrAux    - diferenca encontrada no arredondamento
nTotRAT e nTotRAD - serve somente para controlar diferenca de arredondamento

Obs.: Lembrar que a LP deve ser configurada corretamente pode ser pela (competencia ou caixa)

@author PLSTEAM
@since 08/08/2019
@version P12
@return Retorna valor rateado
/*/
function PLSRATT(cAlias, nValRat, cId, cImp, cImpRet, lConBX, cValEsp, lConBXNEG, cAliasVI)

    local nVlrCal 	:= 0
    local nVlrSRound:= 0
    local nTotRAT	:= 0
    local nTotRAD	:= 0
    local nPercen	:= 0
    local nThReadTit:= 0
    local nVlrAux	:= 0
    local nValBas 	:= 0
    local nValFK6	:= 0
    local cChvRATV 	:= ""
    local cChvRATD  := ""
    local cChvRATX  := ""
    local cChvRATY 	:= ""
    local cChvRATR 	:= ""
    local cChvRATT 	:= ""
    local cChvRATF 	:= ""
    local cChvRATC 	:= ""
    local cChvRATZ 	:= ""
    local cChvComp	:= "RAT" + "_" + allTrim(str(thReadID())) + "_" + allTrim(getComputerName())
    local cAliasBX  := ""
    //local cAliasVI  := ""
    local cIdFk		:= ""
    local cIdDOC	:= ""
    local aValImp	:= {}

    default cImp	:= ""
    default cImpRet	:= ""
    default cValEsp	:= ""
    default lConBX	:= .f.
    default cAliasVI := iIf(cAlias == 'SE1', 'BM1', 'BD7')

    cAliasBX := iIf(cAlias == 'SE1', 'FK1', 'FK2')

    cChvRATY := "Y" + "PL" + cAlias + cChvComp
    cChvRATR := "R" + "PL" + cAlias + cChvComp
    cChvRATT := "T" + "PL" + cAlias + cChvComp
    cChvRATF := "F" + "PL" + cAlias + cChvComp
    cChvRATC := "C" + "PL" + cAlias + cChvComp
    cChvRATZ := "Z" + "PL" + cAlias + cChvComp
    cChvRATW := "W" + "PL" + cAlias + cChvComp

    cChvRATV := "V" + "PL" + cAlias + cChvComp + "_" + cId
    cChvRATD := "D" + "PL" + cAlias + cChvComp + "_" + cId
    cChvRATX := "X" + "PL" + cAlias + cChvComp + "_" + cId

    //limpar totais por lp sequencia
    if  ! ( cId $ getGlbValue(cChvRATC) )

        putGlbValue(cChvRATC, getGlbValue(cChvRATC) + cId + '|'  )
        glbUnLock()

        clearGlbValue(cChvRATV)
        clearGlbValue(cChvRATD)
        clearGlbValue(cChvRATX)

    endIf

    //somente quando for baixa ou titulo diferente
    if val(getGlbValue(cChvRATR)) <> (cAlias)->(recno()) .or. ( ! (cAliasBX)->(eof()) .and. val(getGlbValue(cChvRATF)) <> (cAliasBX)->(recno()) )

        ratGLBPub(cAlias, 1)

        putGlbValue(cChvRATR, cValToChar( (cAlias)->(recno()) ) )
        glbUnLock()

        putGlbValue(cChvRATF, cValToChar( (cAliasBX)->(recno()) ) )
        glbUnLock()

        nThReadTit := valorTit(cAlias, .f.)

        if lConBX
            cIdFk 	:= iIf( cAliasBX == 'FK1', FK1->FK1_IDFK1, FK2->FK2_IDFK2 )
            cIdDOC	:= iIf( cAliasBX == 'FK1', FK1->FK1_IDDOC, FK2->FK2_IDDOC )
            nValFK6 := valTitFK46(cAlias, cIdFk, cIdDOC, nil, nil, cAliasBX)

            putGlbValue(cChvRATW, cValToChar(nValFK6) )
            glbUnLock()
        endIf

        putGlbValue(cChvRATT, cValToChar(nThReadTit) )
        glbUnLock()

    elseIf getGlbValue(cChvRATY) <> cValToChar( (cAliasVI)->( recno() ) ) + '|' + cId

        nThReadTit 	:= val(getGlbValue(cChvRATT))
        nValFK6 	:= val(getGlbValue(cChvRATW))

    endIf

    if nThReadTit > 0 .and. getGlbValue(cChvRATY) <> cValToChar( (cAliasVI)->( recno() ) ) + '|' + cId

        putGlbValue(cChvRATY, cValToChar( (cAliasVI)->( recno() ) ) + '|' + cId )
        glbUnLock()

        //percentual de rateio
        nPercen := ( nValRat / nThReadTit )
        nVlrCal := iIf( nValRat < 0, 0, nValRat )

        //tratamento para rateio de valores especificos Ex.: Impostos
        if ! empty(cImp)

            if lConBX
                cIdFk  := iIf( cAliasBX == 'FK1', FK1->FK1_IDFK1, FK2->FK2_IDFK2 )
                cIdDOC := iIf( cAliasBX == 'FK1', FK1->FK1_IDDOC, FK2->FK2_IDDOC )
            endIf

            getGlbVars(cChvRATZ, aValImp)

            nPos := aScan( aValImp, { |x| x[1] == cIdFk + cImp } )

            if nPos == 0

                nValBas := valTitFK46(cAlias, cIdFk, cIdDOC, cImp, cImpRet)

                if ! empty(cIdFk)

                    aadd(aValImp, { cIdFk + cImp, cValToChar(nValBas) } )

                    putGlbVars(cChvRATZ, aValImp)

                endIf

            else
                nValBas := val( aValImp[nPos, 2] )
            endIf

            if nValBas == 0
                return nValBas
            endIf

        else

            if lConBX

                nValBas := iIf( cAliasBX == 'FK1', FK1->FK1_VALOR, FK2->FK2_VALOR )
                nValBas -= nValFK6

                //TODO: 29/08/2019 - deve ser removido assim que ajustar lote de cobranca
                //tratamento expecifico para DDI
                if lConBXNEG .and. cAlias == 'SE1'

                    nPercen := ( nValBas / SE1->E1_VALOR )
                    nValBas += valorTit(cAlias, .t., .t.)

                endIf

            else

                if empty(cValEsp)
                    nValBas := valorTit(cAlias, .t.)
                else
                    nValBas := &(cValEsp)
                endIf

            endIf

        endIf

        if lConBXNEG //TODO: 29/08/2019 - deve ser removido assim que ajustar lot de cobranca
            nVlrCal := ( nValRat * nPercen )//TODO deve ser removido assim que ajustar lot de cobranca
        else
            nVlrCal := ( nValBas * nPercen )
        endIf

        //totais e arredondamento
        nTotRAT := val(getGlbValue(cChvRATV))
        nTotRAD := val(getGlbValue(cChvRATD))

        if nTotRAT <> nTotRAD
            nVlrAux := (nTotRAD - nTotRAT)
        endIf

        nVlrSRound := nVlrCal

        nTotRAD += nVlrCal
        nVlrCal	:= round(nVlrCal + nVlrAux, 2)
        nTotRAT += nVlrCal

        putGlbValue( cChvRATV, cValToChar(nTotRAT) )
        glbUnLock()

        putGlbValue( cChvRATD, cValToChar(nTotRAD) )
        glbUnLock()

        //verifica se tem diferenca
        if nTotRAT > 0 .and. nTotRAT > nValBas

            nVlrCal -= ( nTotRAT - nValBas )

            putGlbValue(cChvRATV, cValToChar( nValBas ) )
            glbUnLock()

        endIf

        putGlbValue(cChvRATX, cValToChar(nVlrCal) )
        glbUnLock()

    else
        nVlrCal := val(getGlbValue(cChvRATX))
    endIf

    //somente para registrar o lancamento da CTK e CV3
    if nVlrCal <= 0
        nVlrCal := 0.000001
    endIf

    //ponto de entrada para ajustar valor final rateado (regra especifica)
    if existBlock("PLSRATV")
        nVlrCal := execBlock("PLSRATV", .f., .f., { cId, nTotRAT, nTotRAD, nVlrSRound, nVlrAux, nVlrCal, nValBas, nPercen } )
    endIf

return nVlrCal

/*/{Protheus.doc} ratGLBPub
limpa variaveis publicas rateio

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function ratGLBPub(cAlias, nTp)
    local cChvComp 	:= "RAT_" + allTrim(str(thReadID())) + "_" + allTrim(getComputerName())
    local cChvRATY 	:= "Y" + "PL" + cAlias + cChvComp
    local cChvRATR 	:= "R" + "PL" + cAlias + cChvComp
    local cChvRATT 	:= "T" + "PL" + cAlias + cChvComp
    local cChvRATF 	:= "F" + "PL" + cAlias + cChvComp
    local cChvRATC 	:= "C" + "PL" + cAlias + cChvComp
    local cChvRATZ 	:= "Z" + "PL" + cAlias + cChvComp
    local cChvRATW 	:= "W" + "PL" + cAlias + cChvComp
    local cKeyAux  	:= "IMPFULL_" + allTrim(str(thReadID())) + "_" + allTrim(getComputerName())
    local aGlbGet  	:= {}
    local nValor   	:= 0
    local nI		:= 0

    default nTp := 0

    if nTp == 0

        getGlbVars(cKeyAux, aGlbGet, nValor)

        for nI := 1 to len(aGlbGet)
            clearGlbValue(aGlbGet[nI,1])
        next

        clearGlbValue(cKeyAux)

    endIf

    clearGlbValue(cChvRATY)
    clearGlbValue(cChvRATR)
    clearGlbValue(cChvRATT)
    clearGlbValue(cChvRATF)
    clearGlbValue(cChvRATZ)
    clearGlbValue(cChvRATW)

    if nTp == 0
        clearGlbValue(cChvRATC)
    endIf

return

/*/{Protheus.doc} PLIMPFUL
retorna o valor sem considerar rateio
@author PLSTEAM
@since 04/04/2019
@version P12
/*/
function PLIMPFUL(cId, cAlias, nField)
    local nRet  	:= 0
    local cKeyAux	:= "IMPFULL_" + allTrim(str(thReadID())) + "_" + allTrim(getComputerName())
    local cKey		:= cKeyAux + "_" + cId
    local aGlbPut 	:= {}
    local nValor	:= 0

    getGlbVars(cKeyAux, aGlbPut, nValor)

    if aScan(aGlbPut, { |x| x[1] == cKey } ) == 0

        aadd(aGlbPut, { cKey, "0" } )

        putGlbVars(cKeyAux, aGlbPut, nValor)

    endIf

    if val(getGlbValue(cKey)) <> (cAlias)->(recno())

        clearGlbValue(cKey)

        putGlbValue(cKey, cValToChar( (cAlias)->(recno()) ) )
        glbUnLock()

        nRet := nField

    endIf

return(nRet)

/*/{Protheus.doc} PLIMPFK6
retorna valores de juros, multa e desconto
@author PLSTEAM
@since 04/04/2019
@version P12
/*/
function PLIMPFK6(cId, cAlias, cTpDoc)
    local nRet  := 0
    local cKey	:= "IMPFK6_" + allTrim(str(thReadID())) + "_" + allTrim(getComputerName()) + "_" + cId
    local cIdFk	:= ''
    local cSql	:= ''

    if val(getGlbValue(cKey)) <> (cAlias)->(recno())

        cIdFk := iIf( cAlias == 'FK1', FK1->FK1_IDFK1, FK2->FK2_IDFK2 )

        cSql := " SELECT SUM(FK6_VALMOV) FK6_VALMOV "
        cSql += "   FROM " + retSQLName('FK6')
        cSql += "  WHERE FK6_FILIAL = '" + xFilial('FK6') + "' "
        cSql += "    AND FK6_IDORIG = '" + cIdFk + "' "
        cSql += "    AND FK6_TABORI = '" + cAlias + "' "
        cSql += "    AND FK6_TPDOC IN " + formatIn(cTpDoc, "|")
        cSql += "    AND D_E_L_E_T_ = ' ' "

        MPSysOpenQuery( cSql, 'TRBFK6S' )

        if ! TRBFK6S->(eof())
            nRet := TRBFK6S->FK6_VALMOV
        endIf

        TRBFK6S->(dbCloseArea())

        clearGlbValue(cKey)

        putGlbValue(cKey, cValToChar( (cAlias)->(recno()) ) )
        glbUnLock()

    endIf

return(nRet)

/*/{Protheus.doc} valorTit
retorna valor total do titulo parcelado na origem ou nao.

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
static function valorTit(cAlias, lTitPos, lValDC)
    local nValTot 	 := 0
    local nI	  	 := 0
    local cChvPub 	 := "TITMOVL_" + allTrim(str(thReadID())) + "_" + allTrim(getComputerName()) + "_"
    local cChvTIT	 := ''
    local lFound 	 :=	.f.
    local aMatTIT 	 := {}
    local aArea		 := (cAlias)->(getArea())

    local nMVVLRETIR := getNewPar("MV_VLRETIR", 10)
    local nMVVLRETIN := getNewPar("MV_VLRETIN", 10)
    local lIsIssBx	 := findFunction("IsIssBx")
    local lIRPFBaixa := iIf( cPaisLoc == "BRA", SA2->A2_CALCIRF == "2", .f.)
    local lCalcIssBx :=	iIf(lIsIssBx, isIssBx("P"), getNewPar("MV_MRETISS",.f.,"1") == "2" )
    local lInssBx 	 :=	getNewPar("MV_INSBXCP", .f., "2") == "1"
    local lPCCBaixa	 := getNewPar("MV_BX10925", "2") == "1" //PCC = PIS/COFINS/CSLL - '2' - Emissao | '1' - Baixa

    default lTitPos := .f.
    default lValDC	:= .f.

    if ! lTitPos

        //retorna titulo vinculado a tabela do PLS com liquidacao/reliquidacao ou nao.
        if cAlias == 'SE1'

            cChvTIT := SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)
            cChvPub += SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

        elseIf cAlias == 'SE2'

            cChvTIT := SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA)
            cChvPub += cChvTIT

        endIf

        //estes dados foram gravados na chamada da PLSTITMOV no CTB11 e CTB06
        getGlbVars(cChvPub, aMatTIT)

        //para garantir a falha no carregamento dos dados publicos.
        if len(aMatTIT) == 0
            aMatTIT := PLSTITMOV(cAlias)
        endIf

        if len(aMatTIT) > 0

            //retorna o valor total do titulo origem que foi liquidado ou reliquidado (SE1 ou SE2)
            for nI := 1 to len(aMatTIT)

                lFound 	:= .f.

                //aMatTIT da SE2 tem contem a filial na chave
                cChvAux := iIf(cAlias == 'SE1', xFilial(cAlias) + aMatTIT[nI], strTran(aMatTIT[nI],"|","") )

                if AT(allTrim(cChvTIT), cChvAux) > 0
                    lFound := .t.
                else

                    (cAlias)->(dbSetOrder(1))

                    lFound := (cAlias)->( msSeek( cChvAux ) )

                endIf

                if lFound
                    nValTot += valTitPos(cAlias, lIRPFBaixa, lInssBx, lPCCBaixa, lCalcIssBx, nMVVLRETIR, nMVVLRETIN)
                endIf

            next

        endIf

        clearGlbValue(cChvPub)

    else
        nValTot := valTitPos(cAlias, lIRPFBaixa, lInssBx, lPCCBaixa, lCalcIssBx, nMVVLRETIR, nMVVLRETIN, lValDC)
    endIf

    (cAlias)->(restArea(aArea))

return(nValTot)

/*/{Protheus.doc} valTitPos
Retorna o valor do titulo posicionado
@author TOTVS
@since 08/09/2019
/*/
static function valTitPos(cAlias, lIRPFBaixa, lInssBx, lPCCBaixa, lCalcIssBx, nMVVLRETIR, nMVVLRETIN, lValDC)
    local nVlrIR	 := 0
    local nVlrINSS	 := 0
    local nVlrPCC	 := 0
    local nValTot	 := iIf(cAlias == 'SE1', SE1->E1_VALOR, SE2->E2_VALOR )
    local cTab		 := criaTrab(nil, .f.)
    local cSql		 := ''

    if cAlias == 'SE2'

        //IRRF
        nVlrIR := iIf( ! lIRPFBaixa, SE2->E2_IRRF, 0 )
        nVlrIR := iIf( nVlrIR >= nMVVLRETIR, nVlrIR, 0 )

        //INSS
        nVlrINSS := iIf( ! lInssBx, SE2->E2_INSS, 0 )
        nVlrINSS := iIf( nVlrINSS >= nMVVLRETIN, nVlrINSS, 0 )

        //PIS/COFINS/CSLL
        nVlrPCC  := iIf( ! lPCCBaixa, SE2->( E2_PIS + E2_COFINS + E2_CSLL ), 0 )

        nValTot += nVlrIR
        nValTot += nVlrINSS
        nValTot += nVlrPCC
        nValTot += iIf(! lCalcIssBx, SE2->E2_ISS, 0 )

    elseIf cAlias == 'SE1' .and. SE1->E1_TIPO != MV_CRNEG

        //TODO: 29/08/2019 - quando lote de pagamento gerar titulo separado para CREDITO deve ser removido
        //TODO: ou informar este valor como desconto ou acrescimo no titulo nao abater diretamente o valor do titulo
        cSql := " SELECT SUM(BM1_VALOR) VALOR "
        cSql += "   FROM " + retSQLName("BM1") + " BM1 "
        cSql += "  WHERE BM1_FILIAL = '" + xFilial("BM1") + "' "
        cSql += "    AND BM1_PREFIX = '" + SE1->E1_PREFIXO + "' "
        cSql += "    AND BM1_NUMTIT = '" + SE1->E1_NUM + "' "
        cSql += "    AND BM1_PARCEL = '" + SE1->E1_PARCELA + "' "
        cSql += "    AND BM1_TIPTIT = '" + SE1->E1_TIPO + "' "
        cSql += "    AND BM1_TIPO   = '2' "
        cSql += "    AND BM1.D_E_L_E_T_ = ' ' "

        MPSysOpenQuery(cSql, cTab)

        if ! (cTab)->(eof())

            if lValDC
                nValTot := (cTab)->VALOR
            else
                nValTot += (cTab)->VALOR
            endIf

        endIf

        (cTab)->(dbCloseArea())

    endIf

return(nValTot)

/*/{Protheus.doc} valTitFK46
Retorna do imposto retido ou nao
@author TOTVS
@since 08/09/2019
/*/
static function valTitFK46(cAlias, cIdFk, cIdDOC, cImp, cImpRet, cTabOri)
    local nValor  := 0
    local cSql	  := ''
    local cIdImp  := ''

    default cIdFk   := ''
    default cImp	:= ''
    default cImpRet := ''
    default cTabOri	:= ''

    if empty(cTabOri)

        cIdImp += iIf('E1_VRETIRF' $ cImp .or. 'E1_IRRF'   $ cImp .or. 'E2_IRRF'    $ cImp .or. 'E2_VRETIRF' $ cImp, 'IRF|', '')
        cIdImp += iIf('E1_VRETISS' $ cImp .or. 'E1_ISS'    $ cImp .or. 'E2_ISS'     $ cImp .or. 'E2_VRETISS' $ cImp, 'ISS|', '')
        cIdImp += iIf('E1_INSS'    $ cImp .or. 'E2_INSS'   $ cImp .or. 'E2_VRETINS' $ cImp, 'INSS|', '')
        cIdImp += iIf('E1_PIS'     $ cImp .or. 'E2_PIS'    $ cImp .or. 'E2_VRETPIS' $ cImp, 'PIS|', '')
        cIdImp += iIf('E1_COFINS'  $ cImp .or. 'E2_COFINS' $ cImp .or. 'E2_VRETCOF' $ cImp, 'COF|', '')
        cIdImp += iIf('E1_CSLL'    $ cImp .or. 'E2_CSLL'   $ cImp .or. 'E2_VRETCSL' $ cImp, 'CSL|', '')

        cSql := " SELECT SUM(FK4_VALOR) VALIMP "
        cSql += "   FROM " + retSQLName('FK4')
        cSql += "  WHERE FK4_FILIAL = '" + xFilial('FK4') + "' "
        cSql += "    AND FK4_IDORIG IN('" + cIdFk + "','" + cIdDOC + "') "

        if ! empty(cIdImp)
            cSql += " AND FK4_IMPOS IN " + formatIn( strTran(cIdImp,",''",''), "|")
        endIf

        cSql += " AND D_E_L_E_T_ = ' ' "

        MPSysOpenQuery( cSql, 'TRBFK4I' )

        nValor := TRBFK4I->VALIMP

        TRBFK4I->(dbCloseArea())

        if nValor == 0 .and. empty(cIdFk)

            if ! empty(cImpRet) .and. ! empty(cImp)
                nValor := (cAlias)->(&cImp) - (cAlias)->(&cImpRet)
            elseIf ! empty(cImp)
                nValor := (cAlias)->(&cImp)
            endIf

        endIf

    elseIf ! empty(cIdFk) .and. ! empty(cTabOri)

        cSql := " SELECT FK6_VALMOV, FK6_TPDOC, FK6_ACAO "
        cSql += "   FROM " + retSQLName('FK6')
        cSql += "  WHERE FK6_FILIAL = '" + xFilial('FK6') + "' "
        cSql += "    AND FK6_IDORIG = '" + cIdFk + "' "
        cSql += "    AND FK6_TABORI = '" + cTabOri + "' "
        cSql += "    AND D_E_L_E_T_ = ' ' "

        MPSysOpenQuery( cSql, 'TRBFK6I' )

        if ! TRBFK6I->(eof())

            while ! TRBFK6I->(eof())

                if TRBFK6I->FK6_ACAO == '1' .or. TRBFK6I->FK6_TPDOC $ 'MT|JR'
                    nValor += TRBFK6I->FK6_VALMOV
                elseIf TRBFK6I->FK6_ACAO == '2' .or. TRBFK6I->FK6_TPDOC $ 'DC'
                    nValor -= TRBFK6I->FK6_VALMOV
                endIf

                TRBFK6I->(dbSkip())
            endDo

        endIf

        TRBFK6I->(dbCloseArea())

    endIf

return(nValor)

/*/{Protheus.doc} PLSTITMOV
Funcao chamada na liquidacao ou reliquidacao sem utilidade no momento chamada no (fina250)
@author TOTVS
@since 08/09/2019
/*/
function PLSTITMOV(cAlias)
    local nI		:= 0
    local nRecno	:= 0
    local nTamBD7	:= BD7->(tamSX3("BD7_CHKSE2")[1])
    local cChvPLS   := ''
    local cChvDES   := ''
    local cChvPub	:= "TITMOVL_" + allTrim(str(thReadID())) + "_" + allTrim(getComputerName()) + "_"
    local aMatTit	:= {}
    local aMatOri	:= {}
    local aAreaA	:= {}
    local aAreaB	:= {}
    Local cFornec	:= ""
    Local aAreaBAU	:= {}

    if cAlias == 'SE1'

        aAreaA := BM1->(getArea())

        BM1->(dbSetOrder(4))//BM1_FILIAL+BM1_PREFIX+BM1_NUMTIT+BM1_PARCEL+BM1_TIPTIT+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_CODTIP
        FI7->(dbSetOrder(2))//FI7_FILIAL+FI7_PRFDES+FI7_NUMDES+FI7_PARDES+FI7_TIPDES+FI7_CLIDES+FI7_LOJDES

        cChvPLS := SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)
        cChvDES := SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

        cChvPub += cChvDES

        if BM1->( msSeek( xFilial('BM1') + cChvPLS ) )

            aadd(aMatTit, cChvPLS)

            //verifica se tem liquidacao ou reliquidacao
        elseIf FI7->( msSeek( xFilial('FI7') + cChvDES ) )

            while ! FI7->( eof() ) .and. cChvDES == FI7->( FI7_PRFDES + FI7_NUMDES + FI7_PARDES + FI7_TIPDES + FI7_CLIDES + FI7_LOJDES )

                nRecno := FI7->(recno())

                plsRecLIQ('FI7', 'BM1', aMatOri, FI7->FI7_PRFORI, FI7->FI7_NUMORI, FI7->FI7_PARORI, FI7->FI7_TIPORI, FI7->FI7_CLIORI, FI7->FI7_LOJORI )

                FI7->(msGoTo(nRecno))

                FI7->(dbSkip())
            endDo

            for nI := 1 to len(aMatOri)

                if BM1->( msSeek( xFilial('BM1') + aMatOri[nI, 1] ) )

                    aadd(aMatTit, aMatOri[nI, 1])

                endIf

            next

        endIf

        BM1->(restArea(aAreaA))

    elseIf cAlias == 'SE2'

        aAreaA := BD7->(getArea())
        aAreaB := BGQ->(getArea())

        BD7->(dbSetOrder(18))//BD7_FILIAL+BD7_CHKSE2
        BGQ->(dbSetOrder(7))//BGQ_FILIAL+BGQ_PREFIX+BGQ_NUMTIT+BGQ_PARCEL+BGQ_TIPTIT
        FI8->(dbSetOrder(2))//FI8_FILIAL+FI8_PRFDES+FI8_NUMDES+FI8_PARDES+FI8_TIPDES+FI8_FORDES+FI8_LOJDES

        cChvDES := SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA)
        cChvPub += cChvDES

        cChvPLS := SE2->( E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|' + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|' + E2_LOJA )
        cChvPLS	:= cChvPLS + space( nTamBD7 - len( cChvPLS ) )
        cChvDC	:= SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO)
        cFornec := SE2->E2_FORNECE

        if BD7->( msSeek( xFilial('BD7') + cChvPLS ) )

            aadd(aMatTit, cChvPLS )

        elseIf BGQ->( msSeek( xFilial("BGQ") + cChvDC ) )
            aAreaBAU := BAU->(getArea())
            BAU->(dbsetOrder(1))
            BAU->(MsSeek(xfilial("BAU")+BGQ->BGQ_CODIGO))
            While xFilial("BGQ") + cChvDC == BGQ->(BGQ_FILIAL+BGQ_PREFIX+BGQ_NUMTIT+BGQ_PARCEL+BGQ_TIPTIT)
                If Alltrim(cFornec) == AllTrim(BAU->BAU_CODSA2)
                    aadd(aMatTit, cChvPLS )
                    exit
                else
                    BGQ->(dbskip())
                endIf
            EndDo
            RestArea(aAreaBAU)
            //verifica se tem liquidacao ou reliquidacao
        elseIf FI8->( msSeek( xFilial('FI8') + cChvDES ) )

            while ! FI8->( eof() ) .and. cChvDES == FI8->( FI8_PRFDES + FI8_NUMDES + FI8_PARDES + FI8_TIPDES + FI8_FORDES + FI8_LOJDES )

                nRecno := FI8->(recno())

                plsRecLIQ('FI8', 'BD7', aMatOri, FI8->FI8_PRFORI, FI8->FI8_NUMORI, FI8->FI8_PARORI, FI8->FI8_TIPORI, FI8->FI8_FORORI, FI8->FI8_LOJORI )

                FI8->(msGoTo(nRecno))

                FI8->(dbSkip())
            endDo

            for nI := 1 to len(aMatOri)

                if BD7->( msSeek( xFilial('BD7') + aMatOri[nI, 1] ) ) .or. BGQ->( msSeek( xFilial("BGQ") + aMatOri[nI, 2] ) )

                    aadd(aMatTit, aMatOri[nI, 1])

                endIf

            next

        endIf

        BD7->(restArea(aAreaA))
        BGQ->(restArea(aAreaB))

    endIf

    //guarda na variavel puplica para utilizacao no RATEIO
    if len(aMatTit) > 0
        putGlbVars(cChvPub, aMatTit)
    endIf

return(aMatTit)

/*/{Protheus.doc} PLSRACTL
Rotina responsável por retornar o array com o alias e
recno presentes na CTL vinculados com o lançamento padrão

@author  PLS TEAM
@version P12
@since   15.11.05
/*/
function PLSRACTL(cLctoPadrao)
    local aTabRecOri := {}
    local cAliasCTL	 := ''

    CTL->(dbSetOrder(1))
    if CTL->( msSeek(xFilial("CTL") + cLctoPadrao ) )

        cAliasCTL := CTL->CTL_ALIAS

        aadd(aTabRecOri, cAliasCTL)
        aadd(aTabRecOri, &(cAliasCTL + "->(recno())") )

    endIf

return(aTabRecOri)

/*/{Protheus.doc} plsRecLIQ
retorna as origens liquidadas
@author PLSTEAM
@since 27/08/2019
@version P12
/*/
function plsRecLIQ(cAlias, cAliasPLS, aMatOri, cPrefixo, cNumero, cParcela, cTipo, cCliFor, cLoja )
    local cSql 		:= ''
    local cPrOri 	:= ''
    local cNuOri 	:= ''
    local cPaOri 	:= ''
    local cTpOri 	:= ''
    local cCFOri 	:= ''
    local cLoOri 	:= ''
    local cChvMOV	:= ''
    local cChvDC	:= ''
    local cTab 		:= criaTrab(nil, .f.)
    local nTamBD7	:= BD7->(tamSX3("BD7_CHKSE2")[1])

    cSql := " SELECT " + cAlias + "_PRFORI, "
    cSql +=              cAlias + "_NUMORI, "
    cSql +=              cAlias + "_PARORI, "
    cSql +=              cAlias + "_TIPORI, "
    cSql +=              iIf(cAlias == "FI7", " FI7_CLIORI, ", " FI8_FORORI, ")
    cSql +=              cAlias + "_LOJORI "

    cSql += "   FROM " + retSqlName(cAlias) + " " + cAlias

    cSql += "  WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
    cSql += "    AND " + cAlias + "_PRFDES = '" + cPrefixo + "' "
    cSql += "    AND " + cAlias + "_NUMDES = '" + cNumero + "' "
    cSql += "    AND " + cAlias + "_PARDES = '" + cParcela + "' "
    cSql += "    AND " + cAlias + "_TIPDES = '" + cTipo + "' "
    cSql += "    AND " + iIf(cAlias == "FI7", " FI7_CLIDES = '", " FI8_FORDES = '") + cCliFor + "' "
    cSql += "    AND " + cAlias + "_LOJDES = '" + cLoja + "' "
    cSql += "    AND " + cAlias + ".D_E_L_E_T_ = ' ' "

    MPSysOpenQuery( cSql, cTab )

    if ! (cTab)->(eof())

        while ! (cTab)->(eof())

            cPrOri := (cTab)->&( cAlias + '_PRFORI' )
            cNuOri := (cTab)->&( cAlias + '_NUMORI' )
            cPaOri := (cTab)->&( cAlias + '_PARORI' )
            cTpOri := (cTab)->&( cAlias + '_TIPORI' )
            cCFOri := (cTab)->&( iIf(cAlias == 'FI7', 'FI7_CLIORI', 'FI8_FORORI') )
            cLoOri := (cTab)->&( cAlias + '_LOJORI' )

            if (cAlias)->( msSeek( xFilial(cAlias) + cPrOri + cNuOri + cPaOri + cTpOri + cCFOri + cLoOri ) )

                plsRecLIQ(cAlias, cAliasPLS, aMatOri, cPrOri, cNuOri, cPaOri, cTpOri, cCFOri, cLoOri  )

            else

                if cAliasPLS == 'BM1'
                    cChvMOV := cPrOri + cNuOri + cPaOri + cTpOri
                else

                    cChvMOV := xFilial('FI8') + '|' + cPrOri + '|' + cNuOri + '|' + cPaOri + '|' + cTpOri + '|' + cCFOri + '|' + cLoOri
                    cChvMOV := cChvMOV + space( nTamBD7 - len( cChvMOV ) )
                    cChvDC	:= cPrOri + cNuOri + cPaOri + cTpOri

                endIf

                if aScan(aMatOri,{|x| x[1] == cChvMOV } ) == 0
                    aadd(aMatOri, { cChvMOV, cChvDC } )
                endIf

            endIf

            (cTab)->(dbSkip())
        endDo

    else

        if cAliasPLS == 'BM1'
            cChvMOV := cPrefixo + cNumero + cParcela + cTipo
        else

            cChvMOV := xFilial('FI8') + '|' + cPrefixo + '|' + cNumero + '|' + cParcela + '|' + cTipo + '|' + cCliFor + '|' + cLoja
            cChvMOV := cChvMOV + space( nTamBD7 - len( cChvMOV ) )
            cChvDC	:= cPrefixo + cNumero + cParcela + cTipo

        endIf

        if aScan(aMatOri,{|x| x[1] == cChvMOV } ) == 0
            aadd(aMatOri, { cChvMOV, cChvDC } )
        endIf

    endIf

    (cTab)->(dbCloseArea())

return

/*/{Protheus.doc} PLSVLDB5F
verifica se usuario e habitual
@author PLSTEAM
@since 04/04/2019
@version P12
/*/
function PLSVLDB5F(cMatric, dData, lPos, cOpeDES, cOpeORI)
    local lRet := .f.

    default dData 	:= ctod('')
    default lPos 	:= .f.
    default cOpeDES := ''
    default cOpeOri	:= plsIntPad()

    if FWAliasInDic("B5F")

        if ! lPos

            if ! empty(cOpeDES)

                B5F->(dbSetOrder(1)) //B5F_FILIAL+B5F_OPEORI+B5F_OPEHAB+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO+DTOS(B5F_VIGINI)

                //Se existe, vigencia valida e status = 3 - 1=Pend.Envio;2=Enviado;3=Acatado;4=Rejeitado;5=Recebido
                lRet := B5F->( msSeek( xFilial("B5F") + cOpeORI + cOpeDES + cMatric ) )

                if ! empty(dData) .and. lRet
                    lRet := PLSINTVAL("B5F", "B5F_VIGINI", "B5F_VIGFIM", dData) .and. B5F->B5F_STATUS == '3'
                endIf

            endIf

        else

            B5F->(dbSetOrder(3)) //B5F_FILIAL+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO
            B5F->( msSeek( xFilial("B5F") + cMatric ) )

        endIf

    endIf

return(lRet)

/*/{Protheus.doc} PLSRALCTM
Retorna alias contas medicas
@author PLSTEAM
@since 04/04/2019
@version P12
/*/
function PLSRALCTM(cTpGuia)
    local cRet := 'BD5'

    if G_RES_INTER == cTpGuia .or. G_SOL_INTER == cTpGuia .or. G_PRORROGAC == cTpGuia
        cRet := 'BE4'
    elseIf G_OUTRADESP == cTpGuia
        cRet := 'BD6'
    elseIf G_ANEXQUIMI == cTpGuia .or. G_ANEXRADIO == cTpGuia .or. G_ANEXOPME == cTpGuia
        cRet := 'B4A'
    endIf

return(cRet)

/*/{Protheus.doc} PLSMT120
verifica se e pedido do PLS e nao permite desconto
@author PLSTEAM
@since 18/02/2019
@version P12
/*/
function PLSMT120(aHeader, aCols, nOpc)
    local lRet 	 		:= .f.
    local nI	 		:= 0
    local nPosOR 		:= 0
    local nPosLP 		:= 0
    local nPosVD 		:= 0
    local lPLSA470  	:= isInCallStack("PLSA470")

    default nOpc 	:= 0
    default aHeader := {}
    default aCols 	:= {}

    //exclusao do Pedido de Compras atraves do Lote de Pagamento.
    if !lPLSA470

        if len(aHeader) > 0 .and. len(aCols) > 0

            nPosOR := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "C7_ORIGEM" } )
            nPosLP := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "C7_LOTPLS" } )
            nPosVD := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "C7_VLDESC" } )

            if nPosLP > 0 .and. nPosVD > 0 .and. nPosOR > 0

                for nI := 1 to len(aCols)

                    if ( ! empty(aCols[nI,nPosLP]) .or. 'PLS' $ aCols[nI,nPosOR] ) .and. ( aCols[nI,nPosVD] <> 0 .or. ( type('C7_VLDESC') == 'N' .and. M->C7_VLDESC <> 0 ) )

                        lRet := .t.

                    endIf

                next

            endIf

        elseIf ( ! empty(SC7->C7_LOTPLS) .or. 'PLS' $ SC7->C7_ORIGEM )

            lRet := .t.

        endIf

        if lRet

            if nOpc == 0

                aviso(STR0031, STR0034, {"Ok"})//"Atenção"##"Não é permitido incluir desconto para pedido gerado pelo modulo SIGAPLS."

            elseIf nOpc == K_Excluir

                aviso(STR0031, STR0035, {"Ok"})//"Atenção" ##"Este pedido não poderá ser excluído pois foi gerado pelo modulo SIGAPLS."

            elseIf nOpc == K_Alterar

                aviso(STR0031, STR0036, {"Ok"}) //"Atenção"##"Este pedido não poderá ser alterado pois foi gerado pelo modulo SIGAPLS."

            endIf

        endIf

    endIf

return(lRet)

/*/{Protheus.doc} PLSMT103
verifica se pode alterar a quantidade do pedido se e permitido pedido pls com outro pedido sem lote.
grava a chave do titulo na bd7 (mata103 e mata140)
@author PLSTEAM
@since 207/12/2016
@version P12
/*/
function PLSMT103(nTipo, aHeader, aCols, nLinha)
    local aArea 	:= {}
    local nPos	 	:= 0
    local nI		:= 0
    local nPerDes	:= 0
    local nValDes	:= 0
    local cPedido	:= ''
    local cItemPed	:= ''
    local lRet		:= .t.
    local lNoLotPls	:= .f.
    local lDesconto := .f.
    local lPEMT103	:= existblock("PLSPEMT103")

    if lPEMT103

        lRet := execBlock("PLSPEMT103",.F.,.F.)

    else

        do case

            case nTipo == 1

                //Verifica se tem pedido do PLS e se tem mais de um registro
                if cPaisLoc == "BRA" .and. len(aHeader) > 0 .and. len(aCols) > 0

                    aArea := SC7->(getArea())

                    lDesconto 	 := .f.
                    __lSC7LTPLS  := .f.
                    __cSC7CodRDA := ''
                    __aSC7DadPLS := {}

                    for nI := 1 to len(aCols)

                        if ! aCols[nI][ len(aCols[nI]) ]

                            nPos := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "D1_PEDIDO" } )
                            if nPos > 0
                                cPedido	:= aCols[nI, nPos]
                            endIf

                            nPos := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "D1_ITEMPC" } )
                            if nPos > 0
                                cItemPed := aCols[nI, nPos]
                            endIf

                            nPos := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "D1_DESC" } )
                            if nPos > 0
                                nPerDes	:= aCols[nI, nPos]
                            endIf

                            nPos := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "D1_VALDESC" } )
                            if nPos > 0
                                nValDes := aCols[nI, nPos]
                            endIf

                            if ! empty(cPedido) .and. ! empty(cItemPed)

                                SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
                                if SC7->( msSeek( xFilial("SC7") + cPedido + cItemPed ) ) .and. ( ! empty(SC7->C7_LOTPLS) .or. 'PLS' $ SC7->C7_ORIGEM )

                                    __lSC7LTPLS  := .t.
                                    __cSC7CodRDA := SC7->C7_CODRDA

                                    if nPerDes <> 0 .or. nValDes <> 0
                                        lDesconto := .t.
                                    endIf

                                    aadd(__aSC7DadPLS, { SC7->C7_NUM, SC7->C7_ITEM } )
                                else
                                    lNoLotPls := .t.
                                endIf

                            endIf

                        endIf

                    next

                    if __lSC7LTPLS .and. lNoLotPls

                        aviso(STR0031,STR0037,{"Ok"})//"Atenção"##"Não é permitido incluir outro tipo de pedido junto com pedido gerado pelo modulo SIGAPLS."
                        lRet := .f.

                    endIf

                    if __lSC7LTPLS .and. lRet .and. lDesconto
                        aviso(STR0031,STR0038,{"Ok"})//"Atenção"##"Não é permitido incluir desconto para pedido gerados pelo modulo SIGAPLS."
                        lRet := .f.
                    endIf

                    SC7->( restArea(aArea) )

                endIf

            case nTipo == 2

                if __lSC7LTPLS
                    SE2->E2_CODRDA	:= __cSC7CodRDA
                    SE2->E2_LA      := " "
                endIf

            case nTipo == 3

                // Atualiza o numero do titulo no movimento do PLS
                if __lSC7LTPLS .and. len(__aSC7DadPLS) > 0
                    PLSBD7SE2( __aSC7DadPLS, SE2->( E2_FILIAL+'|'+E2_PREFIXO+'|'+E2_NUM+'|'+E2_PARCELA+'|'+E2_TIPO+'|'+E2_FORNECE+'|'+E2_LOJA ) )
                endIf

            case nTipo == 4

                // Atualiza o numero do titulo no movimento do PLS
                if __lSC7LTPLS .and. len(__aSC7DadPLS) > 0
                    PLSBD7SE2(__aSC7DadPLS)
                endIf

            case nTipo == 5

                //Verifica se tem pedido do PLS e se tem mais de um registro
                if cPaisLoc == "BRA" .and. len(aHeader) > 0 .and. len(aCols) > 0 .and. ! aCols[ len(aCols) ] .and. M->D1_QUANT <> 1

                    aArea := SC7->(getArea())

                    nPos := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "D1_PEDIDO" } )
                    if nPos > 0
                        cPedido	:= aCols[nPos]
                    endIf

                    nPos := aScan(aHeader, {|x| allTrim( upper(x[2]) ) == "D1_ITEMPC" } )
                    if nPos > 0
                        cItemPed := aCols[nPos]
                    endIf

                    if ! empty(cPedido) .and. ! empty(cItemPed)

                        SC7->(dbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
                        if SC7->( msSeek( xFilial("SC7") + cPedido + cItemPed ) ) .and. ( ! empty(SC7->C7_LOTPLS) .or. 'PLS' $ SC7->C7_ORIGEM )

                            aviso(STR0031, STR0039, {"Ok"})//"Atenção"##"Não é permitido alterar a quantidade do pedido gerado pelo modulo SIGAPLS."
                            lRet := .f.

                        endIf

                    endIf

                    SC7->( restArea(aArea) )

                endIf

        endCase
    endif
return(lRet)

/*/{Protheus.doc} PLSFN290
Verificacoes do fina290
@author PLSTEAM
@since 207/12/2016
@version P12
/*/
function PLSFN290(cAlias)
    local lRet  	:= .f.
    local lYesPLS 	:= .f.
    local lNoPLS	:= .f.
    local aArea 	:= {}

    default cAlias 	 := ''

    if empty(cAlias)

        lRet := ("PLS" $ SE2->E2_ORIGEM)

    else

        aArea := (cAlias)->(getArea())

        (cAlias)->(dbGoTop())

        while ! (cAlias)->(eof())

            if ! empty( (cAlias)->E2_OK )

                if 'PLS' $ (cAlias)->E2_ORIGEM
                    lYesPLS := .t.
                else
                    lNoPLS  := .t.
                endIf

            endIf

            (cAlias)->(dbSkip())
        endDo

        (cAlias)->(restArea(aArea))

        lRet := ( lYesPLS .and. lNoPLS )

        if lRet
            aviso(STR0031,STR0040,{"Ok"})//"Atenção"##"SIGAPLS, não é permitido selecionar título de origem diferente!"
        endIf

    endIf

return(lRet)

/*/{Protheus.doc} PLSFN565
Verificacoes do fina565
@author PLSTEAM
@since 207/12/2016
@version P12
/*/
static function PLSFN565(cAlias)
    local aArea	  := (cAlias)->(getArea())
    local aAreaSE2:= SE2->(getArea())
    local cChave  := (cAlias)->CHAVE
    local lRet    := .f.
    local lTemPLS := .f.
    local lTemOTO := .f.

    SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

    (cAlias)->(dbGoTop())

    while ! (cAlias)->(eof())

        if ! empty( (cAlias)->MARCA ) .or. cChave == (cAlias)->CHAVE

            if SE2->( msSeek( (cAlias)->CHAVE ) )

                if ( "PLS" $ SE2->E2_ORIGEM .or. ! empty(SE2->E2_PLLOTE) .or. ! empty(SE2->E2_CODRDA) )
                    lTemPLS := .t.
                else
                    lTemOTO := .t.
                endIf

                lRet := ( lTemPLS .and. lTemOTO )

                if lRet
                    exit
                endIf

            endIf

        endIf

        (cAlias)->(dbSkip())
    endDo

    if lRet
        aviso(STR0031,STR0040,{"Ok"})//"Atenção"##"SIGAPLS, não é permitido selecionar título de origem diferente!"
    endIf

    (cAlias)->( restArea(aArea) )
    SE2->( restArea(aAreaSE2) )

return(lRet)

/*/{Protheus.doc} PLSFN460
Verificacoes do PLSFN460
@author PLSTEAM
@since 207/12/2016
@version P12
/*/
function PLSFN460(oObjFO1)
    local aAreaSE1	:= SE1->(getArea())
    local aSvLines	:= FWSaveRows()
    local cChave  	:= xFilial("SE1", oObjFO1:getValue("FO1_FILORI") ) + oObjFO1:getValue("FO1_PREFIX") + oObjFO1:getValue("FO1_NUM") + oObjFO1:getValue("FO1_PARCEL") + oObjFO1:getValue("FO1_TIPO")
    local nX		:= 0
    local lRet    	:= .f.
    local lTemPLS 	:= .f.
    local lTemOTO 	:= .f.

    SE1->(dbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

    for nX := 1 To oObjFO1:length()

        oObjFO1:goLine(nX)

        if oObjFO1:getValue("FO1_MARK") .or. cChave == xFilial("SE1", oObjFO1:getValue("FO1_FILORI") ) + oObjFO1:getValue("FO1_PREFIX") + oObjFO1:getValue("FO1_NUM") + oObjFO1:getValue("FO1_PARCEL") + oObjFO1:getValue("FO1_TIPO")

            if SE1->( msSeek( xFilial("SE1", oObjFO1:getValue("FO1_FILORI") ) + oObjFO1:getValue("FO1_PREFIX") + oObjFO1:getValue("FO1_NUM") + oObjFO1:getValue("FO1_PARCEL") + oObjFO1:getValue("FO1_TIPO") ) )

                if ( "PLS" $ SE1->E1_ORIGEM .or. ! empty(SE1->E1_PLNUCOB) )
                    lTemPLS := .t.
                else
                    lTemOTO := .t.
                endIf

                lRet := ( lTemPLS .and. lTemOTO )

                if lRet
                    exit
                endIf

            endIf

        endIf

    next

    SE1->( restArea(aAreaSE1) )
    FWRestRows( aSvLines )

    if lRet
        aviso(STR0031,STR0040,{"Ok"})//"Atenção"##"SIGAPLS, não é permitido selecionar título de origem diferente!"
    endIf

return(lRet)


/*/{Protheus.doc} PLSBD7SE2
Atualiza numero recno da se2 na bd7
@author PLSTEAM
@since 207/12/2016
@version P12
/*/
static function PLSBD7SE2(aDadPLS, cChaveSE2)
    local aArea		 := getArea()
    local nI		 := 0
    local cSql		 := ''
    local aSE2MAT 	 := { ' ', ' ', ' ', ' ', ' ' }
    Local lBMR_SC7ITE := BMR->(FieldPos("BMR_SC7ITE")) > 0
    Local lUpdBD7	:= .F.
    Local lUpdBGQ	:= .F.
    LOCAL aAreaC7	:= SC7->(GetArea())

    default cChaveSE2:= ' '

    If !lBMR_SC7ITE
        lUpdBD7 := .T.
        lUpdBGQ := .T.
    endIf
    //verifica qual banco de dados
    getTpDB(@__lOracle)

    if len(aDadPLS) > 0

        SC7->(dbSetOrder(1))//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

        begin transaction

            //troca a origem MATA100 por PLS
            if ! empty(cChaveSE2)
                SE2->( reclock("SE2", .f.) )
                SE2->E2_ORIGEM := 'PLSMPAG '
                SE2->( msUnlock() )
            endIf

            for nI := 1 to len(aDadPLS)

                if ! empty(aDadPLS[nI,1]) .and. ! empty(aDadPLS[nI,2])

                    if SC7->( msSeek( xFilial('SC7') + aDadPLS[nI,1] + aDadPLS[nI,2] ) )

                        If lBMR_SC7ITE

                            cSql := " Select BMR_SC7ITE, BMR_CODLAN From " + RetSqlName("BMR") + " BMR "
                            cSql += " WHERE "
                            csql += " BMR_FILIAL = '" + xfilial("BMR") + "' AND "
                            csql += " BMR_OPELOT = '" + SC7->C7_PLOPELT + "' AND "
                            //2020040003 -> C7_LOTPLS
                            csql += " BMR_ANOLOT = '" + SubStr(SC7->C7_LOTPLS,1,4) + "' AND "
                            csql += " BMR_MESLOT = '" + SubStr(SC7->C7_LOTPLS,5,2) + "' AND "
                            csql += " BMR_NUMLOT = '" + SubStr(SC7->C7_LOTPLS,7,4) + "' AND "
                            csql += " D_E_L_E_T_ = ' ' AND "
                            csql += " ( BMR_SC7ITE = '" + SC7->C7_ITEM + "' OR BMR_SC7ITE = ' ') "

                            dbUseArea(.t.,"TOPCONN",tcGenQry(,,csql),"C7ITE",.f.,.t.)

                            If !C7ITE->(EoF())
                                IF !(empTy(C7ITE->BMR_SC7ITE))
                                    while !C7ITE->(EoF())
                                        If C7ITE->BMR_CODLAN == '101'
                                            lUpdBD7 := .T.
                                        else
                                            lUpdBGQ := .T.
                                        endIf
                                        C7ITE->(DbsKip())
                                    endDo
                                else
                                    //Se estiver vazio no BMR é que foi gerado antes dessa implementação,
                                    //então sempre vai ter só um SC7 pro lote, então marca tudo
                                    lUpdBD7 := .T.
                                    lUpdBGQ := .T.
                                endIf
                            endIf
                            C7ITE->(dbclosearea())
                            csql := ""
                        ENDIF

                        If lUpdBD7

                            cSql   := " UPDATE " + retSQLName("BD7")
                            cSql   += "    SET BD7_CHKSE2 = '" + cChaveSE2 + "' "
                            cSql   += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
                            cSql   += "    AND BD7_OPELOT = '" + SC7->C7_PLOPELT + "' "
                            cSql   += "    AND BD7_NUMLOT = '" + SC7->C7_LOTPLS  + "' "
                            cSql   += "    AND BD7_CODRDA = '" + SC7->C7_CODRDA  + "' "
                            cSql   += "    AND D_E_L_E_T_ = ' ' "

                            if ( tcSqlExec( cSql ) ) < 0

                                PlGrvlog("Erro na execução do update PLSBD7SE2 -> [ " + tcSqlERROR() + "]", 'PLSCTB' , 1, .t., funName())
                                userException("Erro na execução do update PLSBD7SE2 -> [ " + tcSqlERROR() + "]")

                            elseIf __lOracle

                                TCSQLExec("COMMIT")

                            endIf

                        endIf

                        if ! empty(cChaveSE2)
                            aSE2MAT	:= strTokArr2(cChaveSE2, '|')
                        endIf

                        if len(aSE2MAT) > 0 .AND. lUpdBGQ

                            cSql   := " UPDATE " + retSQLName("BGQ")
                            cSql   += "    SET BGQ_PREFIX = '" + aSE2MAT[2] + "', "
                            cSql   += "  	   BGQ_NUMTIT = '" + aSE2MAT[3] + "', "
                            cSql   += "        BGQ_PARCEL = '" + aSE2MAT[4] + "', "
                            cSql   += "        BGQ_TIPTIT = '" + aSE2MAT[5] + "' "
                            cSql   += "  WHERE BGQ_FILIAL = '" + xFilial("BGQ") + "' "
                            cSql   += "    AND BGQ_OPELOT = '" + SC7->C7_PLOPELT + "' "
                            cSql   += "    AND BGQ_NUMLOT = '" + SC7->C7_LOTPLS  + "' "
                            cSql   += "    AND BGQ_CODIGO = '" + SC7->C7_CODRDA  + "' "
                            cSql   += "    AND D_E_L_E_T_ = ' ' "

                            if ( tcSqlExec( cSql ) ) < 0

                                PlGrvlog("Erro na execução do update PLSBD7SE2 -> [ " + tcSqlERROR() + "]", 'PLSCTB' , 1, .t., funName())
                                userException("Erro na execução do update PLSBD7SE2 -> [ " + tcSqlERROR() + "]")

                            elseIf __lOracle

                                TCSQLExec("COMMIT")

                            endIf

                        endIf

                    else
                        PlGrvlog("Erro na execução do update PLSBD7SE2 [ Falha de integridade - Pedido SD1 não encontrado na SC7 ]", 'PLSCTB' , 1, .t., funName())
                        userException('Erro na execução do update PLSBD7SE2 [ Falha de integridade - Pedido SD1 não encontrado na SC7 ]')
                    endIf

                else
                    PlGrvlog("Erro na execução do update PLSBD7SE2 [ Falha de integridade - Pedido e Item em branco ]", 'PLSCTB' , 1, .t., funName())
                    userException('Erro na execução do update PLSBD7SE2 [ Falha de integridade - Pedido e Item em branco ]')
                endIf

            next

            If ! empty(cChaveSE2)
                PLNDF103(SE2->(recno()))
            endIf

        end transaction

    endif

    restArea(aArea)
    restarea(aAreaC7)
return

/*/{Protheus.doc} PLSDETPR
Verifica se considera registro do pls na contabilizacao do backoffice
@author PLSTEAM
@since 08/02/2019
@version P12
/*/
function PLSDETPR(cPadrao, cTabOrigem, cAliasPos, aFlagCTB)
    local lRet    	:= .f.
    local nRecno  	:= 0
    local nCount  	:= 0
    local cCampo  	:= ''
    local cVldAli 	:= 'SE2|FK2|SE1|FK1'
    local cOldTO 	:= ""
    local cTOrigem 	:= ""
	LOCAL nI		:= 0

    default aFlagCTB  := {}

    //deve ser desativado na contabilidade antiga ( permiti registros do pls serem contabilizados pelo BACKOFFICE )
    if lMV_PLSNECT == nil
        lMV_PLSNECT := getNewPar("MV_PLSNECT", .t.)
    endIf

    //veio de uma contabilizacao que nao e do PLS. se o modulo pls esta ligado e se e um programa do financeiro.
    if ! ( __cFunName $ 'PLSCTB06|PLSCTB11' ) .and. lMV_PLSNECT

        if __nLastFlg > 0
            nCount := __nLastFlg
        endIf

        if nCount > 0 .and. len(aFlagCTB) <= nCount
            nCount := len(aFlagCTB) - 1
        endIf

        //aqui deve ordenar as areas do aFLAG sem modiciar a ordem de chegada
        //depois disso deve salvar uma unica vez a area contida no novo array criado aFlagOrder.
        //ESTE CODIGO NAO FOI TESTADO.
        //Para teste e preciso pegar qualquer titulo do BACKOFFICE e contabilizar em qualquer lp. (nao pode ser titulo gerado pelo PLS)
        if len(aFlagCTB) > 0

            aFlagOrder := aClone(aFlagCTB)
            aSort(aFlagOrder,,, {|x,y| x[3] < y[3] } )

            for nI := 1 to  len(aFlagOrder)

                cTOrigem := aFlagOrder[nI,3]

                if cTOrigem <> cOldTO
                    cOldTO := cTOrigem
                    &( 'AAR' + cTOrigem ) := (cTOrigem)->( getArea() )	
                endIf

            next

        endIf

        while len(aFlagCTB) > 0 .and. nCount < len(aFlagCTB)

            nCount++

            cTabOrigem 	:= aFlagCTB[ nCount, 3 ]
            nRecno		:= aFlagCTB[ nCount, 4 ]

            IF (cTabOrigem)->(RECNO()) <> nRecno
                (cTabOrigem)->( dbGoTo( nRecno ) )
            ENDIF

            lRet := PLSCTFIN(cTabOrigem)

            //verifica se a origem e PLS
            if lRet

                cCampo := aFlagCTB[nCount,1]

                aDel( aFlagCTB, nCount )
                aSize( aFlagCTB, len(aFlagCTB) - 1 )
                nCount--

            else

                __nLastFlg := nCount

            endIf

            //se for vinculado ao PLS e não for uma entidade valida para o PLS coloca o FLAG
            if lRet .and. ! cTabOrigem $ cVldAli

                (cTabOrigem)->( recLock(cTabOrigem, .f.) )
                (cTabOrigem)->&(cCampo) := 'S'
                (cTabOrigem)->( msUnLock() )

            endIf

        endDo

        //apos toda a operacao acima deve usar a mesma logica para restaurar a area.	
        if len(aFlagCTB) > 0

            cOldTO := ""

            for nI := 1 to  len(aFlagOrder)

                cTOrigem := aFlagOrder[nI,3]

                if cTOrigem <> cOldTO
                    cOldTO := cTOrigem
                    (cTOrigem)->( restArea( &( 'AAR' + cTOrigem ) ) )	
                endIf

            next

        endIf

    endIf

return lRet

/*/{Protheus.doc} PLSCTFIN
Verifica se o titulo PAI e do PLS
@author TOTVS
@since 02/09/2016
/*/
function PLSCTFIN(cAlias)
    local lRet 		:= .f.
    local cPreFixo 	:= ''
    local cNumero	:= ''
    local cParcela	:= ''
    local cTipo 	:= ''
    local cForCli	:= ''
    local cLoja		:= ''
    local cChkAlias	:= ''
    local aArea		:= {}
    local aAreaAUX	:= {}
    local aFK7MAT	:= {}

    do case
        case cAlias == 'SE1'

            cChkAlias := 'SE1'

        case cAlias == 'SE2'

            cChkAlias := 'SE2'

        case cAlias == 'SE5'

            //SE1
            if SE5->E5_RECPAG == "R"

                if SE1->( E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) != xFilial("SE1", SE5->E5_FILORIG) + SE5->( E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO )

                    aArea := SE1->( getArea() )

                    SE1->( dbSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
                    if SE1->( msSeek( xFilial("SE1", SE5->E5_FILORIG) + SE5->( E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO ) ) )
                        cChkAlias := 'SE1'
                    endIf

                else
                    cChkAlias := 'SE1'
                endIf

                //SE2
            elseIf SE5->E5_RECPAG == "P"

                if SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ) != xFilial("SE2", SE5->E5_FILORIG) + SE5->( E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA)

                    aArea := SE2->( getArea() )

                    SE2->( dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
                    if SE2->( msSeek( xFilial("SE2", SE5->E5_FILORIG) + SE5->( E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA) ) )
                        cChkAlias := 'SE2'
                    endIf

                else
                    cChkAlias := 'SE2'
                endIf

            endIf

        case cAlias == 'SEF'

            //SE1
            if SEF->EF_TIPO $ MVRECANT + "/" + MV_CRNEG

                if SE1->( E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) != xFilial("SE1") + SEF->( EF_PREFIXO + EF_TITULO + EF_PARCELA + EF_TIPO )

                    aArea := SE1->( getArea() )

                    SE1->( dbSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
                    if SE1->( msSeek( xFilial("SE1") + SEF->( EF_PREFIXO + EF_TITULO + EF_PARCELA + EF_TIPO ) ) )
                        cChkAlias := 'SE1'
                    endIf

                else
                    cChkAlias := 'SE1'
                endIf

                //SE2
            else

                if SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ) != xFilial("SE2") + SEF->( EF_PREFIXO + EF_TITULO + EF_PARCELA + EF_TIPO + EF_FORNECE + EF_LOJA )

                    aArea := SE2->( getArea() )

                    SE2->( dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
                    if SE2->( msSeek( xFilial("SE2") + SEF->( EF_PREFIXO + EF_TITULO + EF_PARCELA + EF_TIPO + EF_FORNECE + EF_LOJA ) ) )
                        cChkAlias := 'SE2'
                    endIf

                else
                    cChkAlias := 'SE2'
                endIf

            endIf

        case cAlias == 'FK1'

            aAreaAUX := FK7->( getArea() )

            FK7->( dbSetOrder(1) ) //FK7_FILIAL+FK7_IDDOC
            if FK7->( msSeek( xFilial("FK7") + FK1->FK1_IDDOC ) )

                aFK7MAT	 := strToKarr(FK7->FK7_CHAVE, '|')

                cFil	 := aFK7MAT[1]
                cPreFixo := aFK7MAT[2]
                cNumero	 := aFK7MAT[3]
                cParcela := aFK7MAT[4]
                cTipo 	 := aFK7MAT[5]
                cForCli	 := aFK7MAT[6]
                cLoja	 := allTrim(aFK7MAT[7])

                if SE1->( E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) != cFil + cPreFixo + cNumero + cParcela + cTipo

                    aArea := SE1->( getArea() )

                    SE1->( dbSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
                    if SE1->( msSeek( cFil + cPreFixo + cNumero + cParcela + cTipo ) )
                        cChkAlias := 'SE1'
                    endIf

                else
                    cChkAlias := 'SE1'
                endIf

            endIf

            FK7->( restArea(aAreaAUX) )

        case cAlias == 'FK2'

            aAreaAUX := FK7->( getArea() )

            FK7->( dbSetOrder(1) ) //FK7_FILIAL+FK7_IDDOC
            if FK7->( msSeek( xFilial("FK7") + FK2->FK2_IDDOC ) )

                aFK7MAT	 := strToKarr(FK7->FK7_CHAVE, '|')

                cFil	 := aFK7MAT[1]
                cPreFixo := aFK7MAT[2]
                cNumero	 := aFK7MAT[3]
                cParcela := aFK7MAT[4]
                cTipo 	 := aFK7MAT[5]
                cForCli	 := aFK7MAT[6]
                cLoja	 := allTrim(aFK7MAT[7])

                if SE2->( E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ) != cFil + cPreFixo + cNumero + cParcela + cTipo + cForCli + cLoja

                    aArea := SE2->( getArea() )

                    SE2->( dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
                    if SE2->( msSeek( cFil + cPreFixo + cNumero + cParcela + cTipo + cForCli + cLoja ) )
                        cChkAlias := 'SE2'
                    endIf

                else
                    cChkAlias := 'SE2'
                endIf

            endIf

            FK7->( restArea(aAreaAUX) )

        case cAlias == 'TRB'

            lRet := PLSFN565(cAlias)

        case cAlias == 'FO1'

            lRet := PLSFN460()

    endCase

    if 	! empty(cChkAlias)

        if cChkAlias == 'SE1'

            lRet 	:= ( "PLS" $ SE1->E1_ORIGEM .or. ! empty(SE1->E1_PLNUCOB) )
            lTitIMP := ! empty(SE1->E1_TITPAI)

            if len(aArea) > 0
                SE1->( restArea(aArea) )
            endIf
        else

            lRet 	:= ( "PLS" $ SE2->E2_ORIGEM .or. ! empty(SE2->E2_PLLOTE) .or. ! empty(SE2->E2_CODRDA) )
            lTitIMP := ! empty(SE2->E2_TITPAI)

            if len(aArea) > 0
                SE2->( restArea(aArea) )
            endIf

        endIf

        //se for titulo de imposoto deve ser considerado pela contabilizacao ERP.
        if lTitIMP
            lRet := .f.
        endIf

    endIf

return(lRet)

/*/{Protheus.doc} PLSTITPF
Atualiza informacoes do titulo filho com base no pai
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function PLSTITPF(cAlias, cTitPai)
    local aArea		:= (cAlias)->(getArea())
    local lSE2	   	:= (cAlias == 'SE2')
    local cFilOrig 	:= iIf(lSE2, SE2->E2_FILORIG, SE1->E1_FILORIG)
    local cFil		:= iIf(lSE2, xFilial("SE2",cFilOrig), xFilial("SE1",cFilOrig) )
    local cChkPAI  	:= ''
    local cOrigem   := ''

    local cPlOpeLT	:= ''
    local cPlLote	:= ''
    local cCodRda	:= ''
    local cMesBase	:= ''
    local cAnoBase	:= ''

    local cPlNuCob	:= ''
    local cCodInt	:= ''
    local cCodEmp	:= ''
    local cMatric 	:= ''
    local cConEmp	:= ''
    local cVerCon	:= ''
    local cSubCon	:= ''
    local cVerSub	:= ''
    local lOriPLS	:= .f.

    //verifica qual banco de dados
    getTpDB(@__lOracle)

    cTitPai := padR(cTitPai, iIf(lSE2, len( SE2->E2_TITPAI ), len( SE1->E1_TITPAI ) ) , "")

    if lSE2

        cChkPAI := cTitPai

        SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
        if SE2->( msSeek( cFil + cChkPAI ) )
            lOriPLS := 'PLS' $ SE2->E2_ORIGEM
        endIf

        if lOriPLS

            cOrigem	 := SE2->E2_ORIGEM
            cPlOpeLT := SE2->E2_PLOPELT
            cPlLote	 := SE2->E2_PLLOTE
            cCodRda	 := SE2->E2_CODRDA
            cMesBase := SE2->E2_MESBASE
            cAnoBase := SE2->E2_ANOBASE

        endIf

    else

        cChkPAI := subStr(cTitPai, 1, SE1->( tamSX3("E1_PREFIXO")[1] + tamSX3("E1_NUM")[1] + tamSX3("E1_PARCELA")[1] + tamSX3("E1_TIPO")[1] ) )

        SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        if SE1->(msSeek(cFil + cChkPAI))
            lOriPLS := 'PLS' $ SE1->E1_ORIGEM
        endIf

        if lOriPLS

            cOrigem	 := SE1->E1_ORIGEM
            cPlOpeLT := SE1->E1_PLOPELT
            cPlLote	 := SE1->E1_PLLOTE
            cCodRda	 := SE1->E1_CODRDA
            cMesBase := SE1->E1_MESBASE
            cAnoBase := SE1->E1_ANOBASE
            cPlNuCob := SE1->E1_PLNUCOB

            cCodInt	 := SE1->E1_CODINT
            cCodEmp	 := SE1->E1_CODEMP
            cMatric	 := SE1->E1_MATRIC
            cConEmp	 := SE1->E1_CONEMP
            cVerCon	 := SE1->E1_VERCON
            cSubCon	 := SE1->E1_SUBCON
            cVerSub	 := SE1->E1_VERSUB

        endIf

    endIf

    if lOriPLS

        if lSE2

            cSql := " UPDATE " + retSQLName("SE2")
            cSql += "    SET E2_ORIGEM  = '" + cOrigem   + "', "
            cSql += "        E2_PLOPELT = '" + cPlOpeLT  + "', "
            cSql += "        E2_PLLOTE  = '" + cPlLote   + "', "
            cSql += "   	 E2_CODRDA  = '" + cCodRda   + "', "
            cSql += "   	 E2_MESBASE = '" + cMesBase  + "', "
            cSql += "   	 E2_ANOBASE = '" + cAnoBase  + "', "
            cSql += "        E2_LA      = 'S' "
            cSql += "   WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
            cSql += "     AND E2_TITPAI = '" + cTitPai + "' "

            if __lOracle
                cSql += "     AND SUBSTR(E2_ORIGEM,1,3) <> 'PLS' "
            else
                cSql += "     AND SUBSTRING(E2_ORIGEM,1,3) <> 'PLS' "
            endIf

            cSql += "     AND D_E_L_E_T_ = ' ' "

        else

            cSql := " UPDATE " + retSQLName("SE1")
            cSql += "    SET E1_ORIGEM  = '" + cOrigem  + "', "
            cSql += "        E1_PLOPELT = '" + cPlOpeLT + "', "
            cSql += "        E1_PLLOTE  = '" + cPlLote  + "', "
            cSql += "   	 E1_CODRDA  = '" + cCodRda  + "', "
            cSql += "   	 E1_MESBASE = '" + cMesBase + "', "
            cSql += "   	 E1_ANOBASE = '" + cAnoBase + "', "
            cSql += "   	 E1_PLNUCOB = '" + cPlNuCob + "', "
            cSql += "   	 E1_CODINT  = '" + cCodInt  + "', "
            cSql += "   	 E1_CODEMP  = '" + cCodEmp  + "', "
            cSql += "   	 E1_MATRIC  = '" + cMatric  + "', "
            cSql += "   	 E1_CONEMP  = '" + cConEmp  + "', "
            cSql += "   	 E1_VERCON  = '" + cVerCon  + "', "
            cSql += "   	 E1_SUBCON  = '" + cSubCon  + "', "
            cSql += "   	 E1_VERSUB  = '" + cVerSub  + "', "
            cSql += "        E1_LA      = 'S' "
            cSql += "   WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
            cSql += "     AND E1_TITPAI = '" + cTitPai + "' "

            if __lOracle
                cSql += "     AND SUBSTR(E1_ORIGEM,1,3) <> 'PLS' "
            else
                cSql += "     AND SUBSTRING(E1_ORIGEM,1,3) <> 'PLS' "
            endIf

            cSql += "     AND D_E_L_E_T_ = ' ' "

        endIf

        if ( tcSqlExec( cSql ) ) < 0

            FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01',"Erro na execução do update PLSTITPF -> [ " + tcSqlERROR() + "]" , 0, 0, {})
            plsLogFil("Erro na execução do update PLSTITPF -> [ " + tcSqlERROR() + "]", plsLogCTB('PLSTITPF'))

        elseIf __lOracle

            TCSQLExec("COMMIT")

        endIf

    endIf

    (cAlias)->( restArea(aArea) )

return

/*/{Protheus.doc} PLSFN250
Funcao chamada na liquidacao ou reliquidacao sem utilidade no momento chamada no (fina250)
@author TOTVS.
@since 02/09/2016
/*/
function PLSFN250(cAlias, aOrigem, cChKPAI)
    /*
local cFil 			:= aOrigem[1]
local cPreFixo 		:= aOrigem[2]
local cNumero		:= aOrigem[3]
local cParcela		:= aOrigem[4]
local cTipo 		:= aOrigem[5]
local cForCli		:= aOrigem[6]
local cLoja			:= aOrigem[7]
    */
return()

/*/{Protheus.doc} PLSFN050
Verifica se e origem PLS - contas a Pagar
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function PLSFN050(nOpc, lAviso, aCpos)
    local lRet := ('PLS' $ SE2->E2_ORIGEM)

    default nOpc 	:= 0
    default lAviso 	:= .t.
    default aCpos	:= {}

    if lRet .and. lAviso

        if nOpc == K_Excluir

            aviso(STR0031,STR0041,{"Ok"})//"Atenção"##"Este titulo não poderá ser excluído pois foi gerado pelo modulo SIGAPLS."

        elseIf nOpc == K_Alterar

            lRet := .f.

        endIf

        //campos liberados para alteracao em titulos pls.
        //Atenção: Não pode conter campo de valor ou qualquer outro que impacta na relacao titulo x movimento do pls.
    elseIf nOpc == 100 .and. lRet

        aCpos := {}

        aadd(aCpos, "E2_VENCTO")
        aadd(aCpos, "E2_VENCREA")
        aadd(aCpos, "E2_HIST")
        aadd(aCpos, "E2_CODBAR")
        aadd(aCpos, "E2_LINDIG")
        aadd(aCpos, "E2_FORBCO")
        aadd(aCpos, "E2_FORAGE")
        aadd(aCpos, "E2_FAGEDV")
        aadd(aCpos, "E2_FCTADV")
        aadd(aCpos, "E2_FORCTA")
        aadd(aCpos, "E2_FORMPAG")

    endIf

return lRet

/*/{Protheus.doc} PLSFN645
verifica se e origem PLS - Contas a Receber e retorna aviso
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function PLSFN645()
    local lRet := ('PLS' $ SE1->E1_ORIGEM)

return(lRet)

/*/{Protheus.doc} PLSFN040
verifica se e origem PLS - Contas a Receber e retorna aviso
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function PLSFN040(nOpc, lAviso, aCpos)
    local lRet := ('PLS' $ SE1->E1_ORIGEM)

    default nOpc 	:= 0
    default lAviso 	:= .t.
    default aCpos	:= {}

    if lRet .and. lAviso

        if nOpc == K_Excluir

            aviso(STR0031,STR0041,{"Ok"})//"Atenção"##"Este titulo não poderá ser excluído pois foi gerado pelo modulo SIGAPLS."

        elseIf nOpc == K_Alterar

            lRet := .f.

        endIf

        //campos liberados para alteracao em titulos pls.
        //Atenção: Não pode conter campo de valor ou qualquer outro que impacta na relacao titulo x movimento do pls.
    elseIf nOpc == 100 .and. lRet

        aadd(aCpos, "E1_VENCTO")
        aadd(aCpos, "E1_VENCREA")

    endIf

return lRet

/*/{Protheus.doc} plClrFlg
usado no ponto de entrada CTBCLRFLG
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function plClrFlg( cLp )
    local cCampo := ""

    if cLp == "9CN"

        cCampo := "BD7_LAPRO"

    elseIf cLp == "9LA"

        cCampo := "B6T_LAPRO"

    elseIf cLp == "9CT"

        cCampo := "BD7_LA"

    elseIf cLp == "9A1"

        cCampo := "BM1_LAPRO"

    elseIf cLp == "9A2"

        cCampo := "BM1_LAFAT"

    elseIf cLp == "9LC"

        cCampo := "B6S_LAPRO"

    elseIf cLp == "9LD"

        cCampo := "B6S_LA"

    elseif cLp $ "9A3/9NA/9AA"

        cCampo := "B6U_LA"

    elseif cLp $ "9N7/9B7"

        cCampo := "B6U_LA_CAN"

    endIf

return cCampo

/*/{Protheus.doc} plGrvUsu
usado no ponto de entrada CtbGrvUsu
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function plGrvUsu( cLp )

    Local cSql := ""

    //verifica qual banco de dados
    getTpDB(@__lOracle)

    if cLp == "9CN"

        if allTrim(CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) == allTrim(BD7->BD7_CHVPRO)

            BD7->(recLock("BD7",.f.))
            BD7->BD7_LAPRO 	:= ''
            BD7->BD7_DTPRO	:= stod('')
            BD7->BD7_CHVPRO := ''
            BD7->(msUnLock())

        endIf

    elseIf cLp == "9CT"

        if allTrim(CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) == allTrim(BD7->BD7_CHVLA)

            BD7->(recLock("BD7",.f.))
            BD7->BD7_LA  	:= ''
            BD7->BD7_DTLA 	:= stod('')
            BD7->BD7_CHVLA  := ''
            BD7->(msUnLock())

        endIf


    elseIf cLp == "9A1"

        SE1->(dbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        if SE1->( DbSeek( xFilial('SE1') + BM1->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL + BM1_TIPTIT) ) ) .and. ! empty(SE1->E1_LA)

            SE1->(recLock("SE1",.f.))
            SE1->E1_LA := ''
            SE1->(msUnLock())

        endIf

        cSql := " UPDATE "+RetSqlName("BM1") + " SET "
        cSql += "	BM1_LAPRO = '"+Space(TamSX3("BM1_LAPRO")[1])+"',"
        cSql += "	BM1_LAFAT = '"+Space(TamSX3("BM1_LAFAT")[1])+"',"
        cSql += "	BM1_DTPRO = '"+Space(TamSX3("BM1_DTPRO")[1])+"',"
        cSql += "	BM1_CHVPRO = '"+Space(TamSX3("BM1_CHVPRO")[1])+"'"
        cSql += " WHERE BM1_FILIAL = '"+xfilial("BM1")+"'"
        cSql += "	AND BM1_CHVPRO = '"+AllTrim(CT2->(DtoS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC))+"'"
        cSql += " 	AND D_E_L_E_T_ = ' ' "

        If (TcSqlExec(cSql)) < 0
            PlGrvlog("Erro na execução da limpeza de flag do LP 9A1", 'PLSCTB' , 1, .T., FunName())
            userException("Erro na execução da limpeza de flag do LP 9A1 -> [ "+TcSqlERROR()+"]")

        ElseIf __lOracle
            TCSQLExec("COMMIT")
        EndIf

    elseIf cLp == "9A2"

        if allTrim(CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) == allTrim(BM1->BM1_CHVFAT) .Or. Val(CV3->CV3_RECORI) == BM1->(Recno())

            BM1->(recLock("BM1",.f.))
            BM1->BM1_LAFAT 	:= 'P'
            BM1->BM1_DTFAT	:= stod('')
            BM1->BM1_CHVFAT := ''
            BM1->(msUnLock())

        endIf

    elseIf cLp == "9LA"

        if allTrim( CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) == allTrim(B6T->B6T_CHVPRO)

            B6T->(recLock("B6T",.f.))
            B6T->B6T_LAPRO 	:= ''
            B6T->B6T_DTPRO	:= stod('')
            B6T->B6T_CHVPRO := ''
            B6T->(msUnLock())

        endIf

    elseIf cLp == "9LB"

        if allTrim( CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) == allTrim(B6T->B6T_CHVLA)

            B6T->(recLock("B6T",.f.))
            B6T->B6T_LA 	:= ''
            B6T->B6T_DTLA	:= stod('')
            B6T->B6T_CHVLA  := ''
            B6T->(msUnLock())

        endIf

    elseIf cLp == "9LC"

        //Alterado para query pois só limpava uma flag do lote caso houvesse guias com mais de um evento no lote de aviso

        csql := " Update " + retsqlname("B6S") + " B6S "
        cSql += " Set "
        cSql += " B6S_LAPRO = '" + Space(tamSX3("B6S_LAPRO")[1]) + "', "
        cSql += " B6S_DTPRO = '" + Space(tamSX3("B6S_DTPRO")[1]) + "', "
        cSql += " B6S_CHVPRO = '" + Space(tamSX3("B6S_CHVPRO")[1]) + "' "
        cSql += " Where "
        cSql += " B6S_FILIAL = '" + xfilial("B6S") + "' AND "
        cSql += " B6S_CHVPRO = '" + allTrim( CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) + "' AND "
        cSql += " D_E_L_E_T_ = ' ' "

        if ( tcSqlExec( cSql ) ) < 0

            PlGrvlog("Erro na execução da limpeza de flag do LP 9LC", 'PLSCTB' , 1, .t., funName())
            userException("Erro na execução da limpeza de flag do LP 9LC -> [ " + tcSqlERROR() + "]")

        elseIf __lOracle

            TCSQLExec("COMMIT")

        endIf

    elseIf cLp == "9LD"

        //Alterado para query pois só limpava uma flag do lote caso houvesse guias com mais de um evento no lote de aviso

        csql := " Update " + retsqlname("B6S") + " B6S "
        cSql += " Set "
        cSql += " B6S_LA = '" + Space(tamSX3("B6S_LA")[1]) + "', "
        cSql += " B6S_DTLA = '" + Space(tamSX3("B6S_DTLA")[1]) + "', "
        cSql += " B6S_CHVLA = '" + Space(tamSX3("B6S_CHVLA")[1]) + "' "
        cSql += " Where "
        cSql += " B6S_FILIAL = '" + xfilial("B6S") + "' AND "
        cSql += " B6S_CHVLA = '" + allTrim( CT2->(dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) + "' AND "
        cSql += " D_E_L_E_T_ = ' ' "

        if ( tcSqlExec( cSql ) ) < 0

            PlGrvlog("Erro na execução da limpeza de flag do LP 9LD", 'PLSCTB' , 1, .t., funName())
            userException("Erro na execução da limpeza de flag do LP 9LD -> [ " + tcSqlERROR() + "]")

        elseIf __lOracle

            TCSQLExec("COMMIT")

        endIf

    elseIf cLp $ "9A3/9NA/9AA/9B7/9N7"

        If AllTrim(CT2->(Dtos(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC)) == AllTrim(B6U->B6U_CHVPRO)

            B6U->(RecLock("B6U", .F.))
            If cLp $ "9N7/9B7"
                B6U->B6U_LA_CAN = ""
            Else
                B6U->B6U_LA = ""
            EndIf
            B6U->B6U_DATPRO	:= SToD("")
            B6U->B6U_CHVPRO := ""
            B6U->(MsUnLock())

        EndIf

    endIf

return

/*/{Protheus.doc} getTpDB
retorna o tipo de conexao
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function getTpDB(__lOracle)

    if tcIsconnected()
        __lOracle := ( "ORACLE" $ Upper(TCGetDb()) )
        if !__lOracle
            __lOracle := ( "POSTGRES" $ Upper(TCGetDb()) )
        endIf
    endIf

return

/*/{Protheus.doc} plRetMTBX
retorno motivo de baixa
@author PLSTEAM
@since 14/02/2019
@version P12
/*/
function plRetMTBX(cTp, nPTipCtb)
    local nX 	 	:= 0
    local cTipoMB	:= iIf( nPTipCtb == LP_P9AX9B6 .or. nPTipCtb == LP_P9BD9BL, "S", "N")
    local cTPMOVBAN	:= iIf(cTipoMB == "N", 'CMP|PCC|', '')
    local cNotInc 	:= iIf(cTP == 'DES', 'LIQ', 'LIQ')
    local aMotBx 	:= readMotBx()

    for nX = 1 to len(aMotBx)

        if subStr(aMotBx[nX], 19, 1) == cTipoMB

            if ! empty(subStr(aMotBx[nX], 01, 03)) .and. ! ( subStr(aMotBx[nX], 01, 03) $ cNotInc )

                if nX > 1
                    cTPMOVBAN += "|"
                    cTPMOVBAN := strTran(cTPMOVBAN, '||', '|')
                endIf

                cTPMOVBAN += subStr(aMotBx[nX], 01, 03)

            endIf

        endIf

    next

return(cTPMOVBAN)
