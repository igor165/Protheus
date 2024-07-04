#INCLUDE "locxitu.ch"    
/*/{PROTHEUS.DOC} LOCXITU.PRW
ITUP BUSINESS - TOTVS RENTAL
Conjunto de fun็๕es para uso geral do m๓dulo Rental
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@PARAM
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'DBTREE.CH'

// FUNวีES DE UTILIZAวรO GERAL NO RENTAL.
// FRANK ZWARG FUGA EM 21/09/2020

// ROTINA PARA VALIDAR O SALDO NO ORวAMENTO.
// FRANK ZWARG FUGA EM 21/09/2020
FUNCTION LOCXITU01()
LOCAL _LRET     := .T. // RETORNO SE O PRODUTO POSSUI SALDO EM ESTOQUE E POSSIBILITA A UTILIZAวรO DELE.
LOCAL _CPRODUTO 
LOCAL _NQUANT
LOCAL _AAREA    := GETAREA()
LOCAL _NSALDO   := 0
LOCAL _CLOCAL   

IF ALLTRIM(UPPER(READVAR())) == "M->FPA_PRODUT"
    _CPRODUTO   := M->FPA_PRODUT
    _NQUANT     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]
    _CLOCAL     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCAL"})]
ELSEIF ALLTRIM(UPPER(READVAR())) == "M->FPA_QUANT"
    _CPRODUTO   := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
    _NQUANT     := M->FPA_QUANT
    _CLOCAL     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCAL"})]
ELSEIF ALLTRIM(UPPER(READVAR())) == "M->FPA_LOCAL"
    _CPRODUTO   := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
    _NQUANT     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]
    _CLOCAL     := M->FPA_LOCAL
ENDIF


// SE A ROTINA ESTA CONFIGURADA PARA ITENS PAIS E FILHOS E O PRODUTO ษ UMA ESTRUTURA DA SG1 A ROTINA TRATA EM OUTRO PONDO DO SISTEMA
IF SUPERGETMV("MV_LOCX028",,.F.)  
    SG1->(DBSETORDER(1))
	IF SG1->(DBSEEK(XFILIAL("SG1")+ALLTRIM(_CPRODUTO)))
        RETURN .T.
    ENDIF
ENDIF

SB1->(DBSETORDER(1))
IF SB1->(DBSEEK(XFILIAL("SB1")+_CPRODUTO))
    //IF SB1->B1_XRENSAL == "S"
 _NSALDO := CALCEST(SB1->B1_COD, _CLOCAL, DDATABASE + 1, SB1->B1_FILIAL)[1]
        IF _NQUANT > _NSALDO 
            MSGALERT(STR0001+ALLTRIM(STR(_NSALDO)),STR0002) //"SALDO ATUAL: "###"O SALDO EM ESTOQUE ษ MENOR DO QUE A QUANTIDADE INFORMADA."
            _NMSGX ++
        ENDIF
    //ENDIF

ENDIF

RESTAREA(_AAREA)
RETURN _LRET

// FRANK ZWARG FUGA
// 28/09/2020 - VISรO POR ESTRUTURA DA ZAG
FUNCTION LOCXITU02()
LOCAL _AAREA        := GETAREA()
LOCAL _NX, _NY
LOCAL _CPRODUTO
LOCAL _AEST         := {}
LOCAL _CSEQ

LOCAL ODLGX
LOCAL AJANEST 	    := MSADVSIZE()
LOCAL OEMPTREE
LOCAL OFONT1:=TFONT():NEW("ARIAL",9,10,,.T.,,,,.T.,.F.)
LOCAL AOBJECTS := {}
LOCAL _COBRA
LOCAL _NSEQ

PRIVATE COPCAO       := ""

AADD( AOBJECTS, { 100, 100, .T., .T. } )
AINFO   := { AJANEST[1] , AJANEST[2] , AJANEST[3] , AJANEST[4] , 3 , 3 } 
APOSOBJ := MSOBJSIZE( AINFO , AOBJECTS , .T. )

IF SUPERGETMV("MV_LOCX028",,.F.)  
    // VERIFICAR SE EXISTE UM ITEM QUE TENHA CONFIGURAวรO COM ESTRUTURA.
    FOR _NX := 1 TO LEN(ODLGPLA:ACOLS)
        IF !ODLGPLA:ACOLS[_NX][LEN(ODLGPLA:AHEADER)+1]
            _CPRODUTO := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
            _CSEQ     := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})]
            _CQTD     := ALLTRIM(STR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]))
            _CQTD     += STR0003+DTOC(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTINI"})]) //" / DT.INI: "
            _CQTD     += STR0004+DTOC(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTENRE"})]) //" / DT.FIM: "
            _CQTD     += STR0005+DTOC(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})]) //" / PROX.FAT: "
            _CQTD     += STR0006+ALLTRIM(STR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})])) //" / DIAS LOC: "

            IF !EMPTY(_CSEQ)
                AADD(_AEST,{_CPRODUTO,_CSEQ,_NX,_CQTD})
            ENDIF
        ENDIF
    NEXT
IF LEN(_AEST) > 0
        DEFINE MSDIALOG ODLGX FROM AJANEST[7],0 TO AJANEST[6],AJANEST[5] TITLE STR0007 OF OMAINWND PIXEL  //"VISรO POR ESTRUTURA."
        OEMPTREE  := DBTREE():NEW(APOSOBJ[1][1], APOSOBJ[1][2], APOSOBJ[1][3], APOSOBJ[1][4],ODLGX,,,.T.,,OFONT1)
        OEMPTREE:SETSCROLL(2,.T.)
        OEMPTREE:SETSCROLL(1,.T.)

        PIXELIMAGE1 := "FOLDER5"
        IMAGE2 := "FOLDER6"
        ANODES := {}
        ARESULT := {}

        _COBRA := ""
        _NSEQ  := 1
        FOR _NX := 1 TO LEN(_AEST)
            IF SUBSTR(_AEST[_NX][02],1,3) <> _COBRA .AND. EMPTY(SUBSTR(_AEST[_NX][02],5,1))
                SB1->(DBSETORDER(1))
                SB1->(DBSEEK(XFILIAL("SB1")+SUBSTR(_AEST[_NX][01],1,TAMSX3("B1_COD")[1])))
                AADD(ANODES,{'00',STRZERO(_NSEQ,3,0),"",ALLTRIM(SB1->B1_DESC)+STR0008+_AEST[_NX][4],IMAGE1,IMAGE2})         // RAIZ //" / QTD: "
                AADD(ARESULT,{_AEST[_NX][03]})
                _NSEQ ++
                _COBRA := SUBSTR(_AEST[_NX][02],1,3)
                FOR _NY := 1 TO LEN(_AEST)
                    IF SUBSTR(_AEST[_NY][02],1,3) == _COBRA .AND. !EMPTY(SUBSTR(_AEST[_NY][02],5,1))
                        SB1->(DBSETORDER(1))
                        SB1->(DBSEEK(XFILIAL("SB1")+SUBSTR(_AEST[_NY][01],1,TAMSX3("B1_COD")[1])))
                        AADD(ANODES,{'01',STRZERO(_NSEQ,3,0),"",ALLTRIM(SB1->B1_DESC)+STR0008+_AEST[_NX][4],IMAGE1,IMAGE2})         // FILHOS //" / QTD: "
                        AADD(ARESULT,{_AEST[_NY][03]})
                        _NSEQ ++
                    ENDIF
                NEXT

                

            ENDIF
        NEXT
        
        
        OEMPTREE:PTSENDTREE( ANODES )


        ACTIVATE MSDIALOG ODLGX CENTERED ON INIT ENCHOICEBAR(ODLGX , {|| COPCAO:=OEMPTREE:CURRENTNODEID,ODLGX:END() } , {|| COPCAO:="",ODLGX:END()} , , ) 
        /*
        IF !EMPTY(COPCAO)
            COPCAO := ARESTULT[VAL(COPCAO)][1]
            FOR _NX:=1 TO LEN(_AEST)
                IF _AEST[_NX][03] == COPCAO
                    COPCAO := 
                ENDIF
            NEXT
            MSGALERT("SEQUENCIA: "+COPCAO+" NA ABA LOCAวีES.","ATENวรO.")
        ENDIF
        */
    ELSE
        MSGALERT(STR0009,STR0010) //"NENHUM PRODUTO POSSUI ESTRUTURA."###"ATENวรO!"
    ENDIF
ELSE
    MSGALERT(STR0011,STR0010) //"ROTINA EXCLUSIVA DO RENTAL CONFIGURADO POR VISรO DE ESTRUTURA."###"ATENวรO!"
ENDIF    
RETURN


// VALIDACAO PARA INDICAR NO GATILHO DO CAMPO FPA_SEQSUB SE OS CAMPOS PODEM SER ATUALIZADOS AUTOMATICAMENTE.
// FRANK ZWARG FUGA EM 05/20/2020
// GATILHAR SOMENTE SE O PRODUTO AINDA NรO FOI DIGITADO.
FUNCTION LOCXITU03()
LOCAL _LRET := .T.
IF !EMPTY(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]) .OR. EMPTY(M->FPA_SEQSUB)
    _LRET := .F.
ENDIF
RETURN _LRET

// RETORNO DO CONTEฺDO DO GATILHO DO SX7 DO CAMPO FPA_SEQSUB
// FRANK ZWARG FUGA EM 05/10/2020
FUNCTION LOCXITU04(CCAMPO)
LOCAL _XREC
LOCAL _CSEQ := M->FPA_SEQSUB
LOCAL _NX
LOCAL _CTEMP := "FPA->"+CCAMPO

IF VALTYPE(&(_CTEMP)) == "C"
    _XREC := ""
ELSEIF VALTYPE(&(_CTEMP)) == "N"
    _XREC := 0
ELSEIF VALTYPE(&(_CTEMP)) == "L"
    _XREC := .T.
ELSEIF VALTYPE(&(_CTEMP)) == "M"
    _XREC := ""
ENDIF

FOR _NX := 1 TO LEN(ODLGPLA:ACOLS)
    IF !ODLGPLA:ACOLS[_NX][LEN(ODLGPLA:AHEADER)+1]
        IF ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})] == _CSEQ // SEQUENCIA DA SUBSTITUICAO
            _XREC := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])==CCAMPO})]   
        ENDIF
    ENDIF
NEXT

RETURN _XREC


// ROTINA PARA REPLICAR O CONTEUDO DOS CAMPOS
// FRANK 23/10/20
FUNCTION LOCXITU05()
LOCAL XCONTEUDO
LOCAL _NX
LOCAL _CSEQ
LOCAL _DINI
LOCAL _DFIM
LOCAL _CCAMPO := ALLTRIM(READVAR())
LOCAL _NPRCX
LOCAL _NQTDX
LOCAL _NVLRX
LOCAL _NACRX
LOCAL _NPDEX

IF !EMPTY(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})])
    IF EMPTY(SUBSTR(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],5,1) )
        _CSEQ := SUBSTR(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3)
        IF MSGYESNO(STR0012,STR0010) //"CONFIRMA A PASSAGEM DOS DADOS PARA TODAS AS LINHAS DOS ITENS FILHOS?"###"ATENวรO!"
            FOR _NX := 1 TO LEN(ODLGPLA:ACOLS)
                IF !ODLGPLA:ACOLS[_NX][LEN(ODLGPLA:AHEADER)+1]
                    IF SUBSTR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3) == _CSEQ
                        IF !EMPTY(SUBSTR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],5,1) )
                            //IF EMPTY(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])==ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO)))})])
                                ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])==ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO)))})] := &(_CCAMPO)

                                IF ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO))) == "FPA_DTFIM" .OR. ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO))) == "FPA_DTINI"
        _DINI := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTINI"})]
                                    _DFIM := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})]
                                    IF !EMPTY(_DINI) .AND. !EMPTY(_DFIM)
                                        ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})] := _DFIM - _DINI + 1
                                    ELSE
                                        ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})] := 0
                                    ENDIF
                                ENDIF

                                IF ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO))) == "FPA_CODTAB"
                                    //RUNTRIGGER(2,_NX,NIL,,"FPA_CODTAB")  
                                    DA0->(DBSETORDER(1))
                                    DA0->(DBSEEK(XFILIAL("DA0")+ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CODTAB"})]))
                                    SB1->(DBSETORDER(1))
                                    SB1->(DBSEEK(XFILIAL("SB1")+ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]))

                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESTAB"})] := DA0->DA0_DESCRI        
                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})] := GETADVFVAL('DA1','DA1_PRCVEN',XFILIAL('DA1')+DA0->DA0_CODTAB+SB1->B1_COD,1,SB1->B1_PRV1,.T.)          
                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"})] := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})] * ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})]                                                                           

                                    _NPRCX := 0
                                    _NQTDX := 0
                                    _NPDEX := 0
                                    _NACRX := 0

                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"}) > 0
                                        _NPRCX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"}) > 0
                                        _NQTDX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"}) > 0
                                        _NVLRX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PDESC"}) > 0
                         _NPDEX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PDESC"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ACRESC)"}) > 0
                                        _NACRX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ACRESC)"})]
                                    ENDIF

                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRHOR"})]  := (((_NPRCX * _NQTDX -(_NVLRX*(_NPDEX/100))) + (_NACRX)))                       
                                    ODLGPLA:REFRESH()

                                ENDIF

                            ENDIF
                        //ENDIF
                    ENDIF
                ENDIF
            NEXT
        ENDIF
        ODLGPLA:REFRESH()
    ENDIF
ENDIF
XCONTEUDO := &(_CCAMPO)
RETURN XCONTEUDO



// ROTINA PARA MONTAR A TABELA TEMPORมRIA EM SUBSTITUICAO DA CREATABLE
// FRANK EM 23/11/20
FUNCTION LOCXITU06(_NOPC, OTABLE, AFIELDS, AINDICES)
LOCAL OTABLE        AS OBJECT
LOCAL NCONNECT      AS NUMERIC
LOCAL LCLOSECONNECT AS LOGICAL
LOCAL CALIAS        AS CHAR
LOCAL CTABLENAME    AS CHAR
LOCAL CAREAQUERY    AS CHAR
LOCAL CQUERYSQL     AS CHAR
LOCAL _CTEMP
LOCAL _NX

CALIAS := ""
CTABLENAME := ""

IF _NOPC == 3 // CRIA A TABELA TEMPORมRIA

    OTABLE := FWTEMPORARYTABLE():NEW( /*CALIAS*/, /*AFIELDS*/)

    OTABLE:SETFIELDS(AFIELDS)

    FOR _NX := 1 TO LEN(AINDICES)
        //OTABLE:ADDINDEX("01", {"C_ID"} )
        _CTEMP := "OTABLE:ADDINDEX('"+ALLTRIM(STR(_NX))+"', {'"+ALLTRIM(AINDICES[_NX][01])+"'} )"
        &(_CTEMP)
    NEXT

    OTABLE:CREATE()

    CALIAS := OTABLE:GETALIAS()

    CTABLENAME := OTABLE:GETREALNAME()

ELSE // DELETA A TABELA TEMPORมRIA

    OTABLE:DELETE()

ENDIF

RETURN {OTABLE, CALIAS, CTABLENAME}



#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ LOCDIASG  บ Autor ณ IT UP Business     บ Data ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Montas dias de Disponibilidade Alternados                  บฑฑ
ฑฑบ          ณ Chamada: LOCDISAC / LOCDISFR / LOC_A143 / LOCDISMO         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LOCXITU07( cQryInt , cCpoChv , cCpoDtI , cCpoDtF , dParDtI , dParDtF , cCpoFil ) 

Local aArea    := {}
Local cArqDias := "" 
Local aCpoDia  := {} 
Local cFrotAtu := "" 
Local dDTAtu   := "" 
Local I        := 0 

Default cQryInt := "Select * from DTDT ORDER BY 1,2,3"
Default cCpoChv := "NOME"
Default cCpoDtI := "DATAI"
Default cCpoDtF := "DATAF"
Default dParDtI := StoD("20110101")
Default dParDtF := StoD("20110228")

If Select("SX6") == 0 
	RpcSetType(3)
	RpcSetEnv("06" , "01" , , , "FAT") 
Else
	aArea := GetArea()
EndIf 

// Cria campos para tabela que sera abastecida com dias disponiveis
aAdd( aCpoDia , {cCpoChv , "C" , 16,0} )
aAdd( aCpoDia , {"DTINI" , "D" , 08,0} )
aAdd( aCpoDia , {"DTFIM" , "D" , 08,0} )
aAdd( aCpoDia , {cCpoDtI , "D" , 08,0} )
aAdd( aCpoDia , {cCpoDtF , "D" , 08,0} )

If cCpoFil <> Nil
	aAdd( aCpoDia , {cCpoFil, "C" , 02,0} )
EndIf

//cArqDias := CriaTrab(aCpoDia,.T.) 
//dbUseArea(.T., , cArqDias, "DIAS",.T.,.F.)

// Copia estrutura Local para TOP
//COPY TO &cArqDias VIA "TOPCONN"

DIAS  := "TR34A"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
IF TCCANOPEN(DIAS)
   	TCDELFILE(DIAS)
ENDIF
DBCREATE(DIAS, aCpoDia, "TOPCONN")
DBUSEAREA(.T., "TOPCONN", DIAS, (DIAS), .F., .F.)


// Fecha e apaga Estrutura Local
//DIAS->(dbCloseArea())
//FErase( cArqDias + GetDBExtension() )

// Abre Novamente em TOP
//dbUseArea(.T., "TOPCONN" , cArqDias, "DIAS",.T.,.F.)

//MEMOWRITE("C:\TEMP\LOCDIASV13.SQL", cQRYINT) 	// Grava resultado da query no temp do usuario para facilitar o suporte

//If Select("TRBDIA") > 0
	//TRBDIA->(dbCloseArea())
//EndIf   

//dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryInt), "TRBDIA", .F., .T.)

// Copia estrutura Local para TOP
//cTRBDias := CriaTrab(aCpoDia,.T.) 
//COPY TO &cTRBDias VIA "TOPCONN"

// Fecha ARQUIVO TEMPORARIO BINARIO Local
//TRBDIA->(dbCloseArea())

CT34B  := "TR34B"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
IF TCCANOPEN(CT34B)
   	TCDELFILE(CT34B)
ENDIF
DBCREATE(CT34B, aCpoDia, "TOPCONN")
DBUSEAREA(.T., "TOPCONN", CT34B, (CT34B), .F., .F.)


cQryAlt := "UPDATE " + CT34B + " SET " + cCpoDtI + "="+ dtos(dParDtI )+ " WHERE " + cCpoDtI + "< " + dtos(dParDtI )      
tcsqlexec(cQryAlt)

cQryAlt := "UPDATE " + CT34B + " SET " + cCpoDtF + "="+ dtos(dParDtF )+ " WHERE " + cCpoDtF + "> " + dtos(dParDtF )
tcsqlexec(cQryAlt)
	
// Abre Novamente em TOP
//DIAS->(dbClosearea())
cQryTer := "SELECT DISTINCT "+ccpoChv + If(cCpoFil <> Nil, "," + cCpoFil,"")+"," + cCPODtI + ","+ cCPODTF + " from " + CT34B + " ORDER BY " + SUBSTR(CqRYINT,AT("ORDER BY", CQRYINT)+8,LEN(cQryInt))
dbUseArea(.T., "TOPCONN" , TCGenQry(,,cQryTer), "TRBDIA",.T.,.F.) 
TCSETFIELD("TRBDIA",cCpoDtI,"D",8,0) 
TCSETFIELD("TRBDIA",cCpoDtF,"D",8,0) 

cFrotAtu := TRBDIA->&cCpoChv + If(cCpoFil <> Nil, TRBDIA->&cCpoFil,"") 
dDTAtu   := dParDtI 
dDTFim   := dParDtF 
aChvBem  := {}

While TRBDIA->( ! EOF() )
	If cCpoFil <> Nil
		M->&cCpoFil := TRBDIA->&cCpoFil 
	EndIf

	M->&cCpoChv := TRBDIA->&cCpoChv
	M->&cCpoDtI := TRBDIA->&cCpoDtI
	M->&cCpoDtF := TRBDIA->&cCpoDtF

	dDTRes := TRBDIA->&cCpoDtF + 1  

	If     dDTAtu < TRBDIA->&cCpoDtI 
		dDTFim := TRBDIA->&cCpoDtI-1 
	Elseif dDTAtu > TRBDIA->&cCpoDtF 
		dDTFim := dParDtF 
		dDTAtu := dDTRes 
	EndIf

	TRBDIA->( dbSkip() ) 						// Avanca o ponteiro do registro no arquivo

	For I := 1 To 2
		If dDTAtu <= dDTFim .and. ( M->&cCpoDtI <> dParDtI .or. I==2).AND. dDTAtu <> M->&cCpoDtI
			RecLock("DIAS", .T.)                                                    
				If cCpoFil <> Nil
					DIAS->&cCpoFil := M->&cCpoFil
				EndIf   
				aAdd(aChvBem, M->&cCpoChv)
				DIAS->&cCpoChv := M->&cCpoChv
				DIAS->DTINI    := dDTAtu
				DIAS->DTFIM    := dDTFim
				DIAS->&cCpoDtI := M->&cCpoDtI
				DIAS->&cCpoDtF := M->&cCpoDtF
			DIAS->(MsUnLock()) 
		EndIf

		dDtAtu := dDTRes  

		If cFrotAtu <> TRBDIA->&cCpoChv+If(cCpoFil <> Nil, TRBDIA->&cCpoFil,"").and.(dDTFim<>dParDtF.or.Ascan( aChvBem, M->&cCpoChv)== 0   )
			dDTFim   := dParDtF
	   		cFrotAtu := TRBDIA->(&cCpoChv) + If(cCpoFil <> Nil, TRBDIA->&cCpoFil,"") 
			dDTRes   := dParDtI
   		Else
   		   	dDTFim   := dDTRes
   		    Exit
		EndIf  
	Next I 
	If dDTFim == dParDtF 
		dDtAtu := dParDtI
	EndIf		    
EndDo

TRBDIA->(dbCloseArea())
//DIAS->(dbCloseArea()) 

If Len(aArea) > 0 
	RestArea(aArea)
EndIf

Return DIAS //cArqDias


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ LOCDIAS   บ Autor ณ IT UP Business     บ Data ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Montas dias de Disponibilidade Alternados                  บฑฑ
ฑฑบ          ณ Chamada: LOCDISMO.prw                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LOCXITU08(cQryInt , cCpoChv , cCpoDtI , cCpoDtF , dParDtI , dParDtF , cCpoFil) 

Local cArqDias  := "" 
Local aCpoDia   := {} 
Local cFrotAtu  := "" 
Local dDTAtu    := "" 
Local I         := 0 
 
Default cQryInt := "Select * from DTDT ORDER BY 1,2,3"
Default cCpoChv := "NOME"
Default cCpoDtI := "DATAI"
Default cCpoDtF := "DATAF"
Default dParDtI := stod("20110101")
Default dParDtF := stod("20110228")

If Select("SX6") == 0 
	RpcSetType(3)
	RpcSetEnv("06" , "01" , , , "FAT") 
EndIf

// Cria campos para tabela que sera abastecida com dias disponiveis
aAdd( aCpoDia     , {cCpoChv , "C" , 16,0} )
aAdd( aCpoDia     , {"DTINI" , "D" , 08,0} )
aAdd( aCpoDia     , {"DTFIM" , "D" , 08,0} )
aAdd( aCpoDia     , {cCpoDtI , "D" , 08,0} )
aAdd( aCpoDia     , {cCpoDtF , "D" , 08,0} )
If cCpoFil <> Nil
	aAdd( aCpoDia , {cCpoFil , "C" , 02,0} )
EndIf
	
//cArqDias := CriaTrab(aCpoDia,.T.) 
//dbUseArea(.T., , cArqDias, "DIAS",.T.,.F.)

// Copia estrutura Local para TOP
//COPY TO &cArqDias VIA "TOPCONN"

// Fecha e apaga Estrutura Local
//DIAS->(dbCloseArea())
//FErase( cArqDias + GetDBExtension() )

DIAS  := "TR34D"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
IF TCCANOPEN(DIAS)
   	TCDELFILE(DIAS)
ENDIF
DBCREATE(DIAS, aCpoDia, "TOPCONN")
DBUSEAREA(.T., "TOPCONN", DIAS, (DIAS), .F., .F.)


// Abre Novamente em TOP
//dbUseArea(.T., "TOPCONN" , cArqDias, "DIAS",.T.,.F.)

//MEMOWRITE("C:\TEMP\LOCDIASV13.SQL", cQRYINT) 		//Grava resultado da query no temp do usuario para facilitar o suporte

//If Select("DIAS") > 0
//	DIAS->(dbCloseArea())
//Endif   
If Select("CT34DX") > 0
	CT34DX->(dbCloseArea())
Endif   

//dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryInt), "DIAS", .F., .T.)

// Copia estrutura Local para TOP
//cTRBDias := criatrab(aCpoDia,.T.) 
//COPY TO &cTRBDias VIA "TOPCONN"

CT34DX  := "TR34E"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
IF TCCANOPEN(CT34DX)
   	TCDELFILE(CT34DX)
ENDIF
DBCREATE(CT34DX, aCpoDia, "TOPCONN")

// Fecha ARQUIVO TEMPORARIO BINARIO Local
//CT34DX->(dbCloseArea())

cQryAlt := "UPDATE " + CT34DX + " SET " + cCpoDtI + "="+ DtoS(dParDtI )+ " WHERE " + cCpoDtI + "< " + DtoS(dParDtI )      
tcsqlexec(cQryAlt)
cQryAlt := "UPDATE " + CT34DX + " SET " + cCpoDtF + "="+ DtoS(dParDtF )+ " WHERE " + cCpoDtF + "> " + DtoS(dParDtF )
tcsqlexec(cQryAlt)

// Abre Novamente em TOP
//CT34DX->(dbCloseArea())
//CT34DY  := "TY"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
//IF TCCANOPEN(CT34DY)
//   	TCDELFILE(CT34DY)
//ENDIF
cQryTer := "SELECT DISTINCT "+ccpoChv + If(cCpoFil <> Nil, "," + cCpoFil,"")+"," + cCPODtI + ","+ cCPODTF + " from " + CT34DX + " ORDER BY " + SUBSTR(CqRYINT,AT("ORDER BY", CQRYINT)+8,LEN(cQryInt))
dbUseArea(.T., "TOPCONN" , TCGenQry(,,cQryTer), "CT34DY",.T.,.F.)
TCSETFIELD("CT34DY",cCpoDtI,"D",8,0)
TCSETFIELD("CT34DY",cCpoDtF,"D",8,0)

cFrotAtu := CT34DY->&cCpoChv + If(cCpoFil <> Nil, CT34DY->&cCpoFil,"")  
dDTAtu   := dParDtI 
dDTFim   := dParDtF 

aChvBem  := {}
	
While CT34DY->(!EOF()) 
	If cCpoFil <> Nil
		M->&cCpoFil := CT34DY->&cCpoFil 
	EndIf
	M->&cCpoChv := CT34DY->&cCpoChv
	M->&cCpoDtI := CT34DY->&cCpoDtI
	M->&cCpoDtF := CT34DY->&cCpoDtF
	dDTRes := CT34DY->&cCpoDtF + 1  
	If dDTAtu < CT34DY->&cCpoDtI   
		dDTFim := CT34DY->&cCpoDtI-1
	Elseif dDTAtu > CT34DY->&cCpoDtF 
		dDTFim := dParDtF
		dDTAtu := dDTRes 
	EndIf
	CT34DY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
		   
	For I:=1 To 2
		If dDTAtu <= dDTFim .and. ( M->&cCpoDtI <> dParDtI .or. I==2)
			RecLock("DIAS", .T.)                                                    
			If cCpoFil <> Nil
				DIAS->&cCpoFil := M->&cCpoFil
			EndIf   
			aAdd(aChvBem, M->&cCpoChv)
			DIAS->&cCpoChv := M->&cCpoChv
			DIAS->DTINI    := dDTAtu
			DIAS->DTFIM    := dDTFim
			DIAS->&cCpoDtI := M->&cCpoDtI
			DIAS->&cCpoDtF := M->&cCpoDtF
			DIAS->(MsUnLock())  
		EndIf
		dDtAtu := dDTRes  
		If cFrotAtu <> CT34DY->&cCpoChv+If(cCpoFil <> Nil, CT34DY->&cCpoFil,"").and.(dDTFim<>dParDtF.or.Ascan( aChvBem, M->&cCpoChv)== 0   )
			dDTFim   := dParDtF
	   		cFrotAtu := CT34DY->(&cCpoChv) + If(cCpoFil <> Nil, CT34DY->&cCpoFil,"") 
			dDTRes   := dParDtI
   		Else
   		    Exit
   		EndIf  
   Next I 

	If dDTFim == dParDtF 
		dDtAtu := dParDtI
	EndIf 
EndDo
	
CT34DY->(dbCloseArea())
//DIAS->(dbCloseArea()) 
    
Return DIAS //cArqDias       


// Validacao do cliente na aba localidade
// Frank - 01/02/21
Function LOCXITU09
Local _lRet     := .T.
Local _cCli     := ODLGOBR:ACOLS[ODLGOBR:NAT][ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_CLIORI"})]
Local _cLoj     := ODLGOBR:ACOLS[ODLGOBR:NAT][ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_LOJORI"})]
Local _aArea    := GetArea()
Local _lAcha    := .F.

SA1->(dbSetOrder(1))
If Readvar() == "M->FP1_CLIORI"
    _cCli := &(Readvar())
    _lAcha := SA1->(dbSeek(xFilial("SA1")+_cCli))
Else
    _cLoj := &(Readvar())
    _lAcha := SA1->(dbSeek(xFilial("SA1")+_cCli+_cLoj))
EndIf


If !_lAcha
    Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; //"RENTAL: "
	Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist๊ncia nos dados."
	{STR0015}) //"Cliente nใo localizado."
    _lRet := .F.
EndIF
RestArea(_aArea)
Return _lRet

// Frank Zwarg Fuga - 26/04/2021
// Rotina para fazer o reajuste dos contratos.
Function LOCXITU18
Local _cPerg    := "LOCP078"
Local aSize     := MsAdvSize()
Local oDlg
Local aObjects  := {}
Local aInfo
Local aPosObj
Local _cTitulo  := ""
Local oMark
Local CVARGRP   
Local oOk       := LoadBitmap( GetResources(), "LBOK")
Local oNo       := LoadBitmap( GetResources(), "LBNO")
Local _nValor   := 0
Local _dFim     := ctod("")
Local _dProx    := ctod("")
Local _dAniv    := ctod("")
Local _nValor2  := 0
Local _dFim2    := ctod("")
Local _dProx2   := ctod("")
Local _dAniv2   := ctod("")
Local _cObs     := space(100)
Local _nGrava   := 0
Local _nX
Local _cCod     := 0
Local _nVRTOTO  := 0
Local _dDTFIMO
Local _dULTFAO
Local _dANIVE2
Local _cTemp
Local _nTemp
Local _nZ
Local _cCampo1
Local _cCampo2

Private _aEsp     := {}
Private _nTot := 0
Private _lProv    := .F.
Private _aItens := {}
Private oListP5
Private oVlr
Private ofim
Private oprox
Private oani
Private oVlr2
Private ofim2
Private oprox2
Private oani2
Private oObs

(LOCXCONV(1))->(dbSetOrder(1))
(LOCXCONV(1))->(dbSeek("FPA"))
While !(LOCXCONV(1))->(Eof()) .and. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == "FPA"      
    If GetSx3Cache(&(LOCXCONV(2)),"X3_PROPRI") == "U" .and. X3Usado(&(LOCXCONV(2))) .and. GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") == "R" .and. GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") <> "M"  
        aadd(_aEsp,{GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO"),GetSx3Cache(&(LOCXCONV(2)),"X3_TITULO")})    
    EndIf
    (LOCXCONV(1))->(dbSkip())
EndDo

// Redimensionamento da tela
AAdd( aObjects, { 100, 100, .T., .T. } ) // MsSelect
AAdd( aObjects, {  50,  50, .T., .T. } ) // GetFixo
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects,.T.) 

If !Pergunte(_cPerg,.T.)
    MsgAlert(STR0019,STR0010) //"Processo cancelado pelo usuแrio."###"Aten็ใo!"
    Return
EndIf

DEFINE FONT oFont  NAME "MonoAs" SIZE 0, -9 BOLD

If MV_PAR01 == 1
    _cTitulo := "Reajuste dos contratos."

    Processa({|| LOCXITU12(_aEsp) }, "Localizando os contratos vแlidos.", "Aguarde...", .t.)

Else
    LOCXITU16(_aEsp)
    Return
EndIf

DEFINE MSDIALOG oDlg TITLE _cTitulo From aSize[7],00 To aSize[6],aSize[5] of oMainWnd PIXEL

    @ aPosObj[1][1],aPosObj[1][2] LISTBOX oListP5 VAR cVarGrp FIELDS HEADER "";
    SIZE aPosObj[1][4],aPosObj[1][3] ON DBLCLICK ( _aItens[oListP5:nAt,1] := !_aItens[oListP5:nAt,1],oListP5:Refresh() ) OF oDlg PIXEL

    aadd(oListP5:aheaders,"Projeto")
    aadd(oListP5:aheaders,"Cliente")
    aadd(oListP5:aheaders,"Loja")
    aadd(oListP5:aheaders,"Nome Cliente")
    aadd(oListP5:aheaders,"Obra")
    aadd(oListP5:aheaders,"Sequencia")
    aadd(oListP5:aheaders,"Produto")
    aadd(oListP5:aheaders,"Nome Produto")
    aadd(oListP5:aheaders,"Bem")
    aadd(oListP5:aheaders,"Nome Bem")
    aadd(oListP5:aheaders,"AS")
    aadd(oListP5:aheaders,"Valor parcela antigo")
    aadd(oListP5:aheaders,"Valor parcela novo")
    aadd(oListP5:aheaders,"Indice aplicado")
    aadd(oListP5:aheaders,"Tipo de indice")
    aadd(oListP5:aheaders,"Tipo de calculo")
    aadd(oListP5:aheaders,"Aniversario antigo")
    aadd(oListP5:aheaders,"Aniversario novo")
    aadd(oListP5:aheaders,"Data fim antigo")
    aadd(oListP5:aheaders,"Data fim novo")
    aadd(oListP5:aheaders,"Prox.fat. antigo")
    aadd(oListP5:aheaders,"Prox.fat. novo")
    aadd(oListP5:aheaders,"Observacao")

    For _nZ := 1 to len(_aEsp)
        aadd(oListP5:aheaders,_aEsp[_nZ,2])
    Next

    oListP5:REFRESH()

    oListP5:SetArray(_aItens)
    oListP5:REFRESH()
    oListP5:bChange := {|| LOCXITU13()}

    _cTemp := "{||{ If(_aItens[oListP5:nAt,1],oOk,oNo),"
	_cTemp += "_aItens[oListP5:nAt,2],"
	_cTemp += "_aItens[oListP5:nAt,3],"
	_cTemp += "_aItens[oListP5:nAt,4],"
	_cTemp += "_aItens[oListP5:nAt,5],"
	_cTemp += "_aItens[oListP5:nAt,6],"
	_cTemp += "_aItens[oListP5:nAt,7],"
	_cTemp += "_aItens[oListP5:nAt,8],"
    _cTemp += "_aItens[oListP5:nAt,9],"
    _cTemp += "_aItens[oListP5:nAt,10],"
    _cTemp += "_aItens[oListP5:nAt,11],"
    _cTemp += "_aItens[oListP5:nAt,12],"
    _cTemp += "_aItens[oListP5:nAt,13],"
    _cTemp += "_aItens[oListP5:nAt,14],"
    _cTemp += "_aItens[oListP5:nAt,15],"
    _cTemp += "_aItens[oListP5:nAt,16],"
    _cTemp += "_aItens[oListP5:nAt,17],"
    _cTemp += "_aItens[oListP5:nAt,18],"
    _cTemp += "_aItens[oListP5:nAt,19],"
    _cTemp += "_aItens[oListP5:nAt,20],"
    _cTemp += "_aItens[oListP5:nAt,21],"
    _cTemp += "_aItens[oListP5:nAt,22],"
    _cTemp += "_aItens[oListP5:nAt,23],"
    _cTemp += "_aItens[oListP5:nAt,24]"
    _nTemp := 25
    For _nZ := 1 to len(_aEsp)
        _cTemp += ",_aItens[oListP5:nAt,"+alltrim(str(_nTemp))+"]"
        _nTemp ++
    Next
    _cTemp += "}}"

    oListP5:bLine := &(_cTemp)
    oListP5:REFRESH()
	
    @ aPosObj[2][1]+35,aPosObj[2][2] SAY "Valor unitแrio reajustado: " Font oFont Pixel Of oDlg
    @ aPosObj[2][1]+48,aPosObj[2][2] SAY "Data final: " Font oFont Pixel Of oDlg
    @ aPosObj[2][1]+61,aPosObj[2][2] SAY "Pr๓ximo faturamento: " Font oFont Pixel Of oDlg
    @ aPosObj[2][1]+74,aPosObj[2][2] SAY "Data do aniversแrio: " Font oFont Pixel Of oDlg

    @ aPosObj[2][1]+35,aPosObj[2][2]+180 SAY "Valor unitแrio original: " Font oFont Pixel Of oDlg
    @ aPosObj[2][1]+48,aPosObj[2][2]+180 SAY "Data final original: " Font oFont Pixel Of oDlg
    @ aPosObj[2][1]+61,aPosObj[2][2]+180 SAY "Pr๓ximo faturamento original: " Font oFont Pixel Of oDlg
    @ aPosObj[2][1]+74,aPosObj[2][2]+180 SAY "Data do aniversแrio original: " Font oFont Pixel Of oDlg

    @ aPosObj[2][1]+35,aPosObj[2][2]+350 SAY "Observa็ใo: " Font oFont Pixel Of oDlg

    @ aPosObj[2][1]+35,aPosObj[2][2]+75 MSGET oVlr var _nValor PICTURE("99999999.99") valid LOCXITU14("VALOR") Size  50,10 Pixel Of oDlg
    @ aPosObj[2][1]+48,aPosObj[2][2]+75 MSGET oFim var _dFim valid LOCXITU14("FIM") Size  50,10 Pixel Of oDlg
    @ aPosObj[2][1]+61,aPosObj[2][2]+75 MSGET oProx var _dProx valid LOCXITU14("PROX") Size  50,10 Pixel Of oDlg
    @ aPosObj[2][1]+74,aPosObj[2][2]+75 MSGET oAni var _dAniv valid LOCXITU14("NIVER") Size  50,10 Pixel Of oDlg

    @ aPosObj[2][1]+35,aPosObj[2][2]+270 MSGET oVlr2 var _nValor2 PICTURE("99999999.99") Size  50,10 Pixel Of oDlg when .f.
    @ aPosObj[2][1]+48,aPosObj[2][2]+270 MSGET ofim2 var _dFim2 Size  50,10 Pixel Of oDlg when .f.
    @ aPosObj[2][1]+61,aPosObj[2][2]+270 MSGET oprox2 var _dProx2 Size  50,10 Pixel Of oDlg when .f.
    @ aPosObj[2][1]+74,aPosObj[2][2]+270 MSGET oani2 var _dAniv2 Size  50,10 Pixel Of oDlg when .f.

    //@ aPosObj[2][1]+48,aPosObj[2][2]+350 MSGET oObs var _cObs Size  50120,35 Pixel Of oDlg valid LOCXITU14("OBS")
    @ aPosObj[2][1]+48,aPosObj[2][2]+350 MSGET oObs var _cObs Size  150,10 Pixel Of oDlg valid LOCXITU14("OBS")

	//@ aPosObj[2][1]+74,aPosObj[2][2]+400 BUTTON "Aplicar altera็ใo"	SIZE 070,015 OF oDlg PIXEL ACTION( msgalert("TESTE") ) 
	//@ 190,300 BUTTON "Sair"		        SIZE 040,015 OF oPnlZP5 PIXEL ACTION oDlg:End() 



Activate MsDialog oDlg CENTERED On Init EnchoiceBar(oDlg,{|| If(MsgYesNo(STR0030,STR0010),If(.T.,(_nGrava:=1,oDlg:end()),.F.) ,.F.)},{|| oDlg:end()},,) //"Confirma a grava็ใo dos registros?"###"Aten็ใo!"

If _nGrava == 1
    _nTot := 0
    Processa({|| ProcReaj() }, "Gravando os reajustes.", "Aguarde...", .t.)
    MsgAlert(STR0020+alltrim(str(_nTot))+STR0021,STR0022) //"Processo realizado com sucesso, "###" contrato(s) reajustado(s)."###"Reajuste Contratual!"
EndIF

Return .T.

// Gravacao do reajuste de contrato
Static Function ProcReaj
Local _nZ
Local _nX
Local _MV_LOC278 := getmv("MV_LOCX278",,.F.)
Local _LOCXIT02 := EXISTBLOCK("LOCXIT02") 
Local _LOCXIT01 := EXISTBLOCK("LOCXIT01") 

ProcRegua(len(_aItens))
If getmv("MV_LOCX278",,.F.)
    If MsgYesNo(STR0037,STR0010) //"Deseja atualizar os tํtulos provis๓rios?"###"Aten็ใo!"
        _lProv := .T.
    Else
        _lProv := .F.
    EndIf
EndIF

For _nX := 1 to len(_aItens)
    IncProc()
    If _aItens[_nX,1]
        FPA->(dbGoto(_aItens[_nX, 24+len(_aEsp)+1 ]))
        FPA->(RecLock("FPA",.F.))
        // Atualizacao do valor unitario
        _nVRTOTO := FPA->FPA_PRCUNI
        FPA->FPA_PRCUNI := val(_aItens[_nX,14]) // Valor unitario
        FPA->FPA_VLBRUT := FPA->FPA_QUANT*FPA->FPA_PRCUNI // Valor bruto                                                                          
        FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT - (FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC))) // Valor base           
        FPA->FPA_VLHREX := FPA->FPA_VRHOR / FPA->FPA_MINDIA / FPA->FPA_LOCDIA // R$ Hrs Extra                                                            
        // Data final
        _dDTFIMO := FPA->FPA_DTENRE
        FPA->FPA_DTENRE := _aItens[_nX,21] // data final
        // Proximo faturamento
        _dULTFAO := FPA->FPA_DTFIM
        FPA->FPA_DTFIM  := _aItens[_nX,23] // proximo faturamento
        If !empty(FPA->FPA_DTINI) .and. !empty(FPA->FPA_DTFIM)
            FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_DTINI + 1
        EndIf
        // Data do aniversario
        _dANIVE2 := FPA->FPA_NIVER
        If MV_PAR19 == 1
            FPA->FPA_NIVER := _aItens[_nX,19] // data do aniversario
        EndIf
        FPA->(MsUnlock())

        // Atualiza็ใo do tํtulo provis๓rio
        // Frank em 26/20/2021
        If _MV_LOC278 .and. _lProv
            FQB->(dbSetOrder(1))
            FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
            If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                SE1->(dbSetOrder(1))
                SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR)) 
                While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
                    SE1->(RecLock("SE1",.F.))
                    SE1->(dbDelete())
                    SE1->(MsUnlock())
                    SE1->(dbSkip())
                EndDo
                While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                    FQB->(RecLock("FQB",.F.))
                    FQB->(dbDelete())
                    FQB->(MsUnlock())
                    FQB->(dbSkip())
                EndDo
            EndIf
            FP0->(dbSetOrder(1))
            FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
            _nRegX := FPA->(Recno())
            loca01318() // criacao do titulo provisorio 
            FPA->(dbGoto(_nRegX))
        EndIF

        _cCod := GETSX8NUM("FQ9","FQ9_COD")
        ConfirmSx8()

        FQ9->(RecLock("FQ9",.T.))
        FQ9->FQ9_FILIAL := xFilial("FQ9")
        FQ9->FQ9_PROJET := FPA->FPA_PROJET
        FQ9->FQ9_OBRA   := FPA->FPA_OBRA
        FQ9->FQ9_SEQGRU := FPA->FPA_SEQGRU
        FQ9->FQ9_PRODUT := FPA->FPA_PRODUT
        FQ9->FQ9_GRUA   := FPA->FPA_GRUA
        FQ9->FQ9_AS     := FPA->FPA_AS
        FQ9->FQ9_VRTOTO := _nVRTOTO
        FQ9->FQ9_VRTOTN := FPA->FPA_PRCUNI
        FQ9->FQ9_INDICE := MV_PAR08
        FQ9->FQ9_TPCALC := "A"
        FQ9->FQ9_DATA   := dDataBase
        FQ9->FQ9_HORA   := time()
        FQ9->FQ9_ANIVER := _dANIVE2 
        FQ9->FQ9_ANIVE2 := FPA->FPA_NIVER
        FQ9->FQ9_OBS    := _aItens[_nX,24]
        FQ9->FQ9_DTFIMO := _dDTFIMO
        FQ9->FQ9_DTFIMN := FPA->FPA_DTENRE
        FQ9->FQ9_ULTFAO := _dULTFAO
        FQ9->FQ9_ULTFAN := FPA->FPA_DTFIM
        FQ9->FQ9_COD    := _cCod
        FQ9->FQ9_XATUIN := MV_PAR20

        For _nZ := 1 to len(_aEsp)
            _cCampo1 := _aEsp[_nZ][01]
            _cCampo1 := "FQ9_"+substr(_aEsp[_nZ][01],5,10)
            _cCampo2 := _aEsp[_nZ][01]
            (LOCXCONV(1))->(dbSetOrder(2))
            If (LOCXCONV(1))->(dbSeek(_cCampo1))
                &("FQ9->"+_cCampo1) := &("FPA->"+_cCampo2)
            EndIF
        Next

        FQ9->(MsUnlock())

        IF _LOCXIT02 
            EXECBLOCK("LOCXIT02" , .T. , .T. , {1})  // 1 = Inclusao, 2 = Exclusao
        ENDIF

        IF _LOCXIT01 
            EXECBLOCK("LOCXIT01" , .T. , .T. , {1,_aItens[_nX,15]})  // 1 = Inclusao, 2 = Exclusao
        ENDIF

        _nTot ++
    EndIF
Next
Return

// Frank Zwarg Fuga - 28/04/2021
// Atualizacao da listbox do reajuste com os novos valores
Function LOCXITU14(cGet)
If cGet == "VALOR"
    _aItens[oListP5:nAt][14] := transform(oVlr:cText,"99999999.99")
ElseIf cGet == "FIM"
    _aItens[oListP5:nAt][21] := ofim:cText
ElseIf cGet == "PROX"
    _aItens[oListP5:nAt][23] := oprox:cText
ElseIf cGet == "NIVER"
    _aItens[oListP5:nAt][19] := oani:cText
ElseIf cGet == "OBS"
    _aItens[oListP5:nAt][24] := oObs:cText
EndIf
oListP5:refresh()
Return .T.

// Frank Zwarg Fuga - 28/04/2021
// Atualizacao da tela do reajuste
Function LOCXITU13
// Valor original
oVlr2:cText := _aItens[oListP5:nAt][13]     // valor original
ofim2:cText := _aItens[oListP5:nAt][20]     // data final original
oprox2:cText := _aItens[oListP5:nAt][22]    // proximo faturamento original
oani2:cText := _aItens[oListP5:nAt][18]     // aniversario original
// Valor a ser aplicado
oVlr:cText := val(_aItens[oListP5:nAt][14]) // valor reajustado
ofim:cText := _aItens[oListP5:nAt][21]      // data final reajustado
oprox:cText := _aItens[oListP5:nAt][23]     // proximo faturamento reajustado
oani:cText := _aItens[oListP5:nAt][19]      // aniversario reajustado
oObs:cText := _aItens[oListP5:nAt][24]      // observacao
Return .T.


// Frank Zwarg Fuga - 27/04/21
// Localizando os contratos para a realiza็ใo do reajuste
Function LOCXITU12(_aEsp)
Local _cQuery
Local _aResult := {}
Local _nX
Local _aArea   := GetArea()
Local _nZ
Local _MV_LOC067 := GetMV("MV_LOCX067",,.F.)

ProcRegua(3)

_cQuery := "SELECT FPA.R_E_C_N_O_ AS REG "
_cQuery += "FROM "+RetSqlName("FPA")+" FPA "
_cQuery += "INNER JOIN "+RetSqlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPA.FPA_FILIAL AND FP0.FP0_PROJET = FPA.FPA_PROJET "
_cQuery += " AND FP0.D_E_L_E_T_ = '' AND FP0.FP0_CLI >= '"+MV_PAR09+"' AND FP0.FP0_CLI <= '"+MV_PAR11+"' "
_cQuery += " AND FP0.FP0_LOJA >= '"+MV_PAR10+"' AND FP0.FP0_LOJA <= '"+MV_PAR12+"' AND FP0.FP0_CLI > '' "
_cQuery += "WHERE FPA.D_E_L_E_T_ = '' " 
_cQuery += " AND FPA.FPA_PROJET >= '"+MV_PAR02+"' "
_CQUERY += " AND FPA.FPA_PROJET <= '"+MV_PAR03+"' "
_CQUERY += " AND FPA.FPA_DTINI >= '"+dtos(MV_PAR04)+"' "
_CQUERY += " AND FPA.FPA_DTINI <= '"+dtos(MV_PAR05)+"' "
_CQUERY += " AND FPA.FPA_GRUA >= '"+MV_PAR06+"' "
_CQUERY += " AND FPA.FPA_GRUA <= '"+MV_PAR07+"' "
//_CQUERY += " AND FPA.FPA_AJUSTE = '"+MV_PAR08+"' " // Filtro removido a pedido do Lui em 29/06/21
_CQUERY += " AND FPA.FPA_PRODUT >= '"+MV_PAR13+"' "
_CQUERY += " AND FPA.FPA_PRODUT <= '"+MV_PAR14+"' "
If !empty(MV_PAR17)
    _CQUERY += " AND FPA.FPA_NIVER >= '"+dtos(MV_PAR17)+"' "
EndIF
If !empty(MV_PAR18)
    _CQUERY += " AND FPA.FPA_NIVER <= '"+dtos(MV_PAR18)+"' "
EndIF
_CQUERY += " AND FPA.FPA_OBRA >= '"+MV_PAR15+"' "
_CQUERY += " AND FPA.FPA_OBRA <= '"+MV_PAR16+"' "
_CQUERY += " AND FPA.FPA_QUANT > '0' "
_cQuery += " AND FPA.FPA_NFRET = '' " // Frank em 14/07/22 Card 429 sprint bug
_cQuery += " AND FPA.FPA_TIPOSE <> 'S' " // Frank em 14/07/22 Card 429 sprint bug
_cQuery += "ORDER BY FPA.FPA_PROJET + FPA.FPA_OBRA + FPA.FPA_SEQGRU "

If Select("TFPA") > 0 
     TFPA->(dbCloseArea()) 
EndIf 

dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "TFPA", .F., .T. )

IncProc("Sele็ใo dos registros.")

While !TFPA->(Eof())

    FPA->(dbGoto(TFPA->REG))
    FP0->(dbSetOrder(1))
    FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
    If empty(FP0->FP0_CLI)
        TFPA->(dbSkip())
        Loop
    EndIf
    SA1->(dbSetOrder(1))
    SA1->(dbSeek(xFilial("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))
    SB1->(dbSetOrder(1))
    SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
    ST9->(dbSetOrder(1))
    ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))

    // Melhoria feita em 16/12/21 por Frank card 215
    If !_MV_LOC067
        If !Empty(FPA->FPA_DTPRRT) 
            If dDataBase >= FPA->FPA_DTPRRT
                TFPA->(dbSkip())
                Loop
            EndIF
        EndIf
    Else
        CALIASX1 := GETNEXTALIAS()
		_lProcx := .T.
		CQUERYX   := " SELECT count(*) AS REG "
		CQUERYX   += " FROM "+RETSQLNAME("SC6")+" SC6 (NOLOCK) "
		CQUERYX   += " WHERE  C6_FILIAL  =  '"+xFilial("SC6")+"' "
		CQUERYX   += "   AND  C6_XAS     =  '"+FPA->FPA_AS+"' "
		CQUERYX   += "   AND  SC6.D_E_L_E_T_ = '' "
		CQUERYX := CHANGEQUERY(CQUERYX) 
		DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERYX),CALIASX1, .F., .T.)
		If (CALIASX1)->REG > 0
			_lProcx := .F.
		EndIF
		(CALIASX1)->(DBCLOSEAREA())
		If !_lPRocx
			TFPA->(dbSkip())
			Loop
		EndIF
    EndIF


    aadd(_aResult,{ .T.,;
                    FPA->FPA_PROJET,;
                    FP0->FP0_CLI,;
                    FP0->FP0_LOJA,;
                    SA1->A1_NOME,;
                    FPA->FPA_OBRA,;
                    FPA->FPA_SEQGRU,;
                    FPA->FPA_PRODUT,;
                    SB1->B1_DESC,;
                    FPA->FPA_GRUA,;
                    iif(ST9->(Eof()),"",ST9->T9_NOME),;
                    FPA->FPA_AS,;
                    transform(FPA->FPA_PRCUNI,"99999999.99"),;
                    transform(FPA->FPA_PRCUNI,"99999999.99"),;
                    Transform(MV_PAR20 ,"999999.99999"),;
                    MV_PAR08,;
                    "Atualiza็ใo",;
                    FPA->FPA_NIVER,;
                    FPA->FPA_NIVER,;
                    FPA->FPA_DTENRE,;
                    FPA->FPA_DTENRE,;
                    FPA->FPA_DTFIM,;
                    FPA->FPA_DTFIM,;
                    space(100)})
    For _nZ := 1 to len(_aEsp)
        AADD(_aResult[len(_aResult)],&("FPA->"+_aEsp[_nZ][01]))
    Next
    AADD(_aResult[len(_aResult)],FPA->(Recno()))

    TFPA->(dbSkip())
EndDo

IncProc("Montagem do ambiente de sele็ใo.")

/*
01 .T.
02 "Projeto"
03 "Cliente"
04 "Loja"
05 "Nome Cliente"
06 "Obra"
07 "Sequencia"
08 "Produto"
09 "Nome Produto"
10 "Bem"
11 "Nome Bem"
12 "AS"
13 "Valor parcela antigo"
14 "Valor parcela novo"
15 "Indice aplicado"
16 "Tipo de indice"
17 "Tipo de calculo"
18 "Aniversario antigo"
19 "Aniversario novo"
20 "Data fim antigo"
21 "Data fim novo"
22 "Data prox.faturamento antigo"
23 "Data prox.faturamento novo"
24 "Observacao"
25 "Recno FPA"
*/
If len(_aResult) == 0
    aadd(_aResult,{.F.,"","","","","","","","","","","",0,"0","0","",ctod(""),ctod(""),"",ctod(""),ctod(""),ctod(""),ctod(""),space(100)})

    For _nZ := 1 to len(_aEsp)
        AADD(_aResult[len(_aResult)],Criavar("FPA->"+_aEsp[_nZ][01]))
    Next

    AADD(_aResult[len(_aResult)],0) // recno

EndIf

IncProc("Aplica็ใo do reajuste.")

For _nX := 1 to len(_aResult)
    _nTemp := ( val(_aResult[_nX][14]) * val(_aResult[_nX][15])) / 100
    _nTemp := val(_aResult[_nX][14]) + _nTemp
    _aResult[_nX][14] := transform(_nTemp,"99999999.99")
next

_aItens := _aResult // _aItens private da fun็ใo LOCXITU18

RestArea(_aArea)
Return



// Frank Zwarg Fuga - 27/04/2021
// Gatilho para atualiza็ใo do campo FPA_PRCUNI
Function LOCXITU11(_cCampo)
Local _nRet    := 0
Local _cCodTab := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CODTAB"})]
Local _nPrcUni := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})]
Local _cProdut := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
Local _aArea   := GetArea()
Local _lCalc   := .F.
IF empty(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AJUSTE"})])
    _lCalc := .T.
Else
    If MsgYesNo(STR0031,STR0032) //"Deseja atualizar o valor unitแrio?"###"Recแlculo do valor unitแrio."
        _lCalc := .T.
    EndIF
EndIf
If _lCalc
    SB1->(dbSetorder(1))
    If SB1->(dbSeek(xFilial("SB1")+_cProdut))
        If _cCampo == "FPA_CODTAB"
            _nRet := GetAdvFVal('DA1','DA1_PRCVEN',xFilial('DA1')+_cCodTab+SB1->B1_COD,1,SB1->B1_PRV1,.t.)          
        ElseIf _cCampo == "FPA_PRODUT"
            _nRet := GetAdvFVal('DA1','DA1_PRCVEN',xFilial('DA1')+_cCodTab+SB1->B1_COD,1,SB1->B1_PRV1,.t.)          
        ElseIf _cCampo == "FPA_SEQSUB"
            _nRet := LOCXITU04("FPA_PRCUNI")                                                                             
        Else
            _nRet := _nPrcUni
        EndIf
    EndIf
    If empty(_cProdut) .or. SB1->(Eof())
        _nRet := 0
    EndIf
Else
    _nRet := _nPrcUni
EndIf
RestArea(_aArea)
Return _nRet


// Valida็ใo do campo FPA_TESFAT
// Frank Zwarg Fuga - 17/05/21
Function LOCXITU15
Local _lRet     := .T.
Local _aArea    := GetArea()
SF4->(dbSetOrder(1))
If SF4->(dbSeek(xFilial("SF4")+M->FPA_TESFAT))
    If SF4->F4_TIPO <> "S"
        _lRet := .F.
        Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; // "RENTAL: "
	    Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; // "Inconsist๊ncia nos dados."
	    {STR0016}) // "A TES selecionada nใo ้ de saํda."
    EndIf
Else
    _lRet := .F.
    Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; // "RENTAL: "
	Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; // "Inconsist๊ncia nos dados."
	{STR0017}) // "A TES informada nใo foi localizada."
EndIf
RestArea(_aArea)
Return _lRet


// Rotina de extorno do reajuste contratual
// Frank Zwarg Fuga
// 03/06/21
Function LOCXITU16
Local _cFiltro := ""
PRIVATE cCadastro := "Estorno dos reajustes"

dbSelectArea("FQ9")
dbSetOrder(1)

_cFiltro := "FQ9_PROJET >= '"+MV_PAR02+"' and FQ9_PROJET <= '"+MV_PAR03+"' "
_cFiltro += "and FQ9_OBRA >= '"+MV_PAR15+"' and FQ9_OBRA <= '"+MV_PAR16+"' "
_cFiltro += "and FQ9_PRODUT >= '"+MV_PAR13+"' and FQ9_PRODUT <= '"+MV_PAR14+"' "
_cFiltro += "and FQ9_GRUA >= '"+MV_PAR06+"' and FQ9_GRUA <= '"+MV_PAR07+"' "
IF !empty(MV_PAR17) .or. !empty(MV_PAR18)
    _cFiltro += "and FQ9_ANIVE2 >= '"+dtos(MV_PAR17)+"' and FQ9_ANIVE2 <= '"+dtos(MV_PAR18)+"' "
EndIF
IF !empty(MV_PAR04) .or. !empty(MV_PAR05)
    _cFiltro += "and FQ9_DATA >= '"+dtos(MV_PAR04)+"' and FQ9_DATA <= '"+dtos(MV_PAR05)+"' "
EndIF
IF !empty(MV_PAR08)
    _cFiltro += "and FQ9_INDICE = '"+MV_PAR08+"' "
EndIF


PRIVATE AROTINA   := {{"Pesquisar" ,"AXPESQUI"  ,0,1},;
                      {"Visualizar","AXVISUAL"  ,0,2},;
                      {"Restaurar" ,"LOCXITU17" ,0,4}}

MBROWSE( 6,1,22,75,        "FQ9" ,,,,,,,,,,,,,,_cFiltro)

Return


// Estorno dos movimentos de reajuste
// Frank Zwarg Fuga - 03/06/21

Function LOCXITU17
Local _nReg
Local _cProj := FQ9->FQ9_PROJET
Local _dData := FQ9->FQ9_DATA
Local _cHora := FQ9->FQ9_HORA
Local _MV_LOC278 := getmv("MV_LOCX278",,.F.)
Local _LOCXIT01 := EXISTBLOCK("LOCXIT01") 

If FQ9->FQ9_MSBLQL == "1"
    MsgAlert(STR0023,STR0024) // "Reajuste jแ restaurado."###"Processo bloqueado."
    Return
EndIf

// Nใo permitir um estorno de um registro menor
_nReg := FQ9->(Recno())
FQ9->(dbSetOrder(1))
FQ9->(dbSeek(xFilial("FQ9")+_cProj))
While !FQ9->(Eof()) .and. FQ9->FQ9_FILIAL == xFilial("FQ9") .and. FQ9->FQ9_PROJET == _cProj
    If FQ9->FQ9_MSBLQL <> "1"
        If FQ9->FQ9_DATA > _dData
            MsgAlert(STR0025,STR0026) // "Existe um reajuste mais atual do que o posicionado."###"Processo bloqueado!"
            FQ9->(dbGoto(_nReg))
            Return .F.
        EndIF            
        IF FQ9->FQ9_DATA == _dData .and. FQ9->(Recno()) <> _nReg
            IF FQ9->FQ9_HORA > _cHora
                MsgAlert(STR0025,STR0026) // "Existe um reajuste mais atual do que o posicionado."###"Processo bloqueado!"
                FQ9->(dbGoto(_nReg))
                Return .F.
            EndIF
        EndIF
    EndIF
    FQ9->(dbSkip())
EndDo
FQ9->(dbGoto(_nReg))


If MsgYesNo(STR0033,STR0010) //"Confirma a restaura็ใo dos valores?"###"Aten็ใo!"
    FPA->(dbSetOrder(1))
    If FPA->(dbSeek(xFilial("FPA")+FQ9->(FQ9_PROJET+FQ9_OBRA+FQ9_SEQGRU)))
        If FPA->(RecLock("FPA",.F.))
            // Atualizacao do valor unitario
            FPA->FPA_PRCUNI := FQ9->FQ9_VRTOTO // Valor unitario
            FPA->FPA_VLBRUT := FPA->FPA_QUANT*FPA->FPA_PRCUNI // Valor bruto                                                                          
            FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT - (FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC))) // Valor base           
            FPA->FPA_VLHREX := FPA->FPA_VRHOR / FPA->FPA_MINDIA / FPA->FPA_LOCDIA // R$ Hrs Extra                                                            
            // Data final
            FPA->FPA_DTENRE := FQ9->FQ9_DTFIMO // data final
            // Proximo faturamento
            FPA->FPA_DTFIM  := FQ9->FQ9_ULTFAO // proximo faturamento
            If !empty(FPA->FPA_DTINI) .and. !empty(FPA->FPA_DTFIM)
                FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_DTINI + 1
            EndIf
            // Data do aniversario
            If MV_PAR19 == 1
                FPA->FPA_NIVER := FQ9->FQ9_ANIVER // data do aniversario
            EndIf
            FPA->(MsUnlock())      

            // Atualiza็ใo do tํtulo provis๓rio
            // Frank em 26/20/2021
            If _MV_LOC278
                FQB->(dbSetOrder(1))
                FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
                If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                    SE1->(dbSetOrder(1))
                    SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR)) 
                    While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
                        SE1->(RecLock("SE1",.F.))
                        SE1->(dbDelete())
                        SE1->(MsUnlock())
                        SE1->(dbSkip())
                    EndDo
                    While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                        FQB->(RecLock("FQB",.F.))
                        FQB->(dbDelete())
                        FQB->(MsUnlock())
                        FQB->(dbSkip())
                    EndDo
                EndIf
                FP0->(dbSetOrder(1))
				FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
				_nRegX := FPA->(Recno())
				loca01318() // criacao do titulo provisorio 
				FPA->(dbGoto(_nRegX))
            EndIF

            IF _LOCXIT01
	            EXECBLOCK("LOCXIT01" , .T. , .T. , {2, FQ9->FQ9_XATUIN}) // 1 = Inclusao, 2 = Exclusao
            ENDIF

            FQ9->(RecLock("FQ9"),.F.)
            FQ9->FQ9_MSBLQL := "1"
            FQ9->(MsUnlock())

            MsgAlert(STR0027,STR0028) //"Processo realizado com sucesso."###"Reajuste estornado."
        EndIF
    EndIf
EndIF
Return



// Rotina para o calculo do ISS no contrato (manuten็ใo)
// Frank Z Fuga em 15/07/21 - usado no SX7
Function LOCXITU10
Local _nValor := 0
Local _cTipo  := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TPISS"})]
Local _nBase  := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRHOR"})]
Local _nImp   := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PERISS"})]

IF _cTipo $ "X "
    _nValor := 0
ElseIF _cTipo=="I"
    _nValor := _nBase * (_nImp / 100)
ElseIf _cTipo=="N"
    _nValor := (_nBase / (100 - _nImp) * 100) - _nBase
EndIF      
Return _nValor

// Rotina responsแvel por gatilhar componentes da estrutura de bens nos itens do Projeto
// Fernando Alves em 09/07/2021
// Frank Zwarg Fuga - produtiza็ใo em 27/08/21
Function LOCXITU19
Local lRet      := .T.
Local cAliasSTC := GetNextAlias()
Local cEquip    := ''
Local aItem     := {}
Local nI  		:= 0 
Local nJ  		:= 0
Local cSeq      := StrZero(Len(ODLGPLA:ACOLS),3,0)
Local aItemAux  := {}

Local aULTPECASR := {}
Local nPos 		 := 0
Local nPosSequ  := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_SEQGRU"  })
Local nPosProd  := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_PRODUT"  })
Local nPosDesc  := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DESPRO"  })
Local nPosEquip := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_GRUA"    })
Local nPosDesEq := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DESGRU"  })
Local nPosQuant := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_QUANT"  })

Local nPosXX01 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_AS"    })
Local nPosXX02 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_NFREM"  })
Local nPosXX03 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DNFREM"  })
Local nPosXX04 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_SERREM"  })
Local nPosXX05 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_ITEREM"  })
Local nPosVincB := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})

Local nPosXX06 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_PRCUNI"  })
Local nPosXX07 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_VRHOR"  })
Local nPosXX08 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_VLBRUT"  })

Local nPosXX09 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_NFRET"  })
Local nPosXX10 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_SERRET"  })
Local nPosXX11 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_ITERET"  })
Local nPosXX12 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DNFRET"  })

Local nPosXX13 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_PEDIDO"  })
Local nPosXX14 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_VIAGEM"  })

Local _aArea := GetArea()
Local _cSeq1 := "000"

IF !OFOLDER:NOPTION == 3 
	Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; //"RENTAL: "
	   				Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist๊ncia nos dados."
	 				{STR0018}) //"Selecionar a aba Loca็ใo."
	RETURN .F. 
ENDIF 

For nJ := 1 to Len(ODLGPLA:ACOLS)
    If !ODLGPLA:ACOLS[nJ][len(ODLGPLA:AHEADER)+1]
        If substr(ODLGPLA:ACOLS[nJ][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3) > _cSeq1
            _cSeq1 := substr(ODLGPLA:ACOLS[nJ][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3)
        EndIF
    EndIF
Next
_cSeq1 := Soma1(_cSeq1)
_cSeq2 := "000"

For nJ := 1 to Len(ODLGPLA:ACOLS)

    cEquip  := ODLGPLA:ACOLS[nJ][nPosEquip]
    aItem   := ODLGPLA:ACOLS[nJ]

    If !Empty(cEquip) .And. Empty(Alltrim(ODLGPLA:ACOLS[nJ][nPosVincB])) .and. !ODLGPLA:ACOLS[nJ][len(ODLGPLA:AHEADER)+1]

        // ------------------------------------------------------------------------
        // Utilizo a Fun็ใo padrใo para obter a estrutura de produtos de reposi็ใo
        // ------------------------------------------------------------------------
        aULTPECASR := NGPEUTIL(cEquip)

        BeginSQL Alias cAliasSTC
        SELECT TC_COMPONE FROM %Table:STC% STC WHERE TC_CODBEM = %Exp:cEquip% AND STC.%NotDel%
        EndSQL

        If (cAliasSTC)->(!Eof())

            If MsgYesNo(STR0034, STR0010) //"Deseja carregar a estrutura do bem?"###"Aten็ใo"

                While (cAliasSTC)->(!Eof())

                    nPos := aScan(ODLGPLA:ACOLS,{|x| AllTrim(x[nPosEquip])== Alltrim((cAliasSTC)->TC_COMPONE) })

                    If nPos == 0

                        aItemAux:= aClone(aItem)
                        cSeq := Soma1(cSeq)

                        ST9->(dbSetOrder(1))
                        ST9->(dbSeek(xFilial("ST9")+(cAliasSTC)->TC_COMPONE))
                        SB1->(dbSetOrder(1))
                        SB1->(dbSeek(xFilial("SB1")+ST9->T9_CODESTO))

                        aItemAux[nPosSequ]  := cSeq
                        aItemAux[nPosProd]  := ST9->T9_CODESTO
                        aItemAux[nPosDesc]  := SB1->B1_DESC
                        aItemAux[nPosEquip] := (cAliasSTC)->TC_COMPONE
                        aItemAux[nPosDesEq] := ST9->T9_NOME
                        _cSeq2 := Soma1(_cSeq2)
                        aItemAux[nPosVincB] := _cSeq1+"."+_cSeq2

                        aItemAux[nPosXX01] := ''
                        aItemAux[nPosXX02] := ''
                        aItemAux[nPosXX03] := StoD('')
                        aItemAux[nPosXX04] := ''
                        aItemAux[nPosXX05] := ''
                        
                        aItemAux[nPosXX06] := 0
                        aItemAux[nPosXX07] := 0
                        aItemAux[nPosXX08] := 0

                        aItemAux[nPosXX09] := ''
                        aItemAux[nPosXX10] := ''
                        aItemAux[nPosXX11] := ''
                        aItemAux[nPosXX12] := StoD('')

                        aItemAux[nPosXX13] := ''
                        aItemAux[nPosXX14] := ''

                        //DbSelectArea('ST9')	
                        //ST9->(dbSetOrder(1))
                        //If ST9->(dbSeek( xFilial("ST9") + (cAliasSTC)->TC_COMPONE ))

                            
                        //Endif							

                        If len(aItemAux) > 0
                            ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := _cSeq1
                        EndIf
                        aAdd(ODLGPLA:ACOLS, aItemAux)
       
                    EndIf

                    (cAliasSTC)->(DbSkip())
                EndDo

                For nI := 1 to Len(aULTPECASR)

                    nPos := aScan(ODLGPLA:ACOLS,{|x| AllTrim(x[nPosProd])== Alltrim(aULTPECASR[nI][1]) })

                    If nPos == 0

                        aItemAux:= aClone(aItem)
                        cSeq := Soma1(cSeq)

                        aItemAux[nPosSequ]  := cSeq

                        aItemAux[nPosProd]  := aULTPECASR[nI][1]
                        aItemAux[nPosDesc]  := POSICIONE('SB1',1,xFilial('SB1')+aItemAux[nPosProd],'B1_DESC')
                        aItemAux[nPosEquip] := ''
                        aItemAux[nPosDesEq] := ''
                        _cSeq2 := Soma1(_cSeq2)
                        aItemAux[nPosVincB] := _cSeq1+"."+_cSeq2

                        aItemAux[nPosXX01] := ''
                        aItemAux[nPosXX02] := ''
                        aItemAux[nPosXX03] := StoD('')
                        aItemAux[nPosXX04] := ''
                        aItemAux[nPosXX05] := ''
                        
                        aItemAux[nPosXX06] := 0
                        aItemAux[nPosXX07] := 0
                        aItemAux[nPosXX08] := 0

                        aItemAux[nPosXX09] := ''
                        aItemAux[nPosXX10] := ''
                        aItemAux[nPosXX11] := ''
                        aItemAux[nPosXX12] := StoD('')

                        aItemAux[nPosXX13] := ''
                        aItemAux[nPosXX14] := ''						

                        TPY->(dbSetOrder(1))
                        If TPY->(dbSeek(xFilial("TPY")+cEquip+aULTPECASR[nI][1]))
                            aItemAux[nPosQuant] := TPY->TPY_QUANTI
                        EndIF

                        If len(aItemAux) > 0
                            ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := _cSeq1
                        EndIf
                        aAdd(ODLGPLA:ACOLS, aItemAux)

                    EndIf

                Next nI

                (cAliasSTC)->(DbCloseArea())

            EndIf

        Else
            For nI := 1 to Len(aULTPECASR)

                nPos := aScan(ODLGPLA:ACOLS,{|x| AllTrim(x[nPosProd])== Alltrim(aULTPECASR[nI][1]) })

                If nPos == 0

                    aItemAux:= aClone(aItem)
                    cSeq := Soma1(cSeq)

                    aItemAux[nPosSequ]  := cSeq

                    aItemAux[nPosProd]  := aULTPECASR[nI][1]
                    aItemAux[nPosDesc]  := POSICIONE('SB1',1,xFilial('SB1')+aItemAux[nPosProd],'B1_DESC')
                    aItemAux[nPosEquip] := ''
                    aItemAux[nPosDesEq] := ''
                    _cSeq2 := Soma1(_cSeq2)
                    aItemAux[nPosVincB] := _cSeq1+"."+_cSeq2

                    aItemAux[nPosXX01] := ''
                    aItemAux[nPosXX02] := ''
                    aItemAux[nPosXX03] := StoD('')
                    aItemAux[nPosXX04] := ''
                    aItemAux[nPosXX05] := ''
                    
                    aItemAux[nPosXX06] := 0
                    aItemAux[nPosXX07] := 0
                    aItemAux[nPosXX08] := 0

                    aItemAux[nPosXX09] := ''
                    aItemAux[nPosXX10] := ''
                    aItemAux[nPosXX11] := ''
                    aItemAux[nPosXX12] := StoD('')

                    aItemAux[nPosXX13] := ''
                    aItemAux[nPosXX14] := ''						

                    TPY->(dbSetOrder(1))
                    If TPY->(dbSeek(xFilial("TPY")+cEquip+aULTPECASR[nI][1]))
                        aItemAux[nPosQuant] := TPY->TPY_QUANTI
                    EndIF

                    If len(aItemAux) > 0
                        ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := _cSeq1
                    EndIf
                    aAdd(ODLGPLA:ACOLS, aItemAux)

                EndIf

            Next nI
        EndIf
    EndIf

Next nJ

RestArea(_aArea)

Return lRet

// Atualizar o c๓digo da estrutura da FPA
// Frank Zwarg Fuga em 27/08/21
Function LOCXITU20
LOCAL APARAMBOX := {}
LOCAL ARET 		:= {}  
LOCAL CPAI      := "   "
LOCAL CFILHO1   := "   " 
LOCAL CFILHO2   := "   " 
LOCAL CFILHO3   := "   " 
Local _cTitu    := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]

IF !OFOLDER:NOPTION == 3 
	Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; //"RENTAL: "
	   				Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist๊ncia nos dados."
	 				{STR0018}) //"Selecionar a aba Loca็ใo."
	RETURN .F. 
ENDIF 

AADD(APARAMBOX,{1,"Cod Pai"  , cPai,   "999", "", "", "", 50, .T.})
AADD(APARAMBOX,{1,"Nivel 1 Filho", cFilho1, "999", "", "", "", 50, .F.})
AADD(APARAMBOX,{1,"Nivel 2 Filho", cFilho2, "999", "", "", "", 50, .F.})
AADD(APARAMBOX,{1,"Nivel 3 Filho", cFilho3, "999", "", "", "", 50, .F.})
IF PARAMBOX(APARAMBOX,"Estrutura de produtos/bens",@ARET,,,,,,,,.F.)    
	cPai := ARET[1] 
	cFilho1 := ARET[2]
    cFilho2 := ARET[3]
    cFilho3 := ARET[4]
ENDIF 

If empty(cPai)
    MsgAlert(STR0029,STR0010) //"Nใo foi selecionado o item Pai."###"Aten็ใo!"
    Return .F.
EndIF

If MsgYesNo(STR0035,STR0036+_cTitu) // "Confirma o processo de estrutura de produtos?"###"Produto: "
    ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := cPai+"."+cFilho1+"."+cFilho2+"."+cFilho3+"MAN"
EndIF

Return .T.


// Gravacao do historico dos bens
// Antigo T9STSALT
// Frank Zwarg Fuga em 30/08/21
Function LOCXITU21(_cStsOld, _cStsNew, _cContr, _cDocto, _cSerie, _lDel)
Local   _aAreaOld  := GetArea()
Local   _aAreaSB1  := SB1->(GetArea())
Local   _aAreaZAG  := FPA->(GetArea())
Local   _aAreaZA0  := FP0->(GetArea())
Local   _aAreaSD2  := SD2->(GetArea())
Local   _aAreaSD1  := SD1->(GetArea())
Local   _cTpMov    := ""
Local   _cOS       := "" 			// Referente OS
Local   _cServic   := "" 			// Referente OS
//cal   _dPreLib   := CtoD("") 		// Referente OS
Local   _cLog      := ""
Local   _cUserName := ""
Local   _lExclui   := .f.
Local   _lBemProj  := .T.
Local   _lOS       := .F.
Local   cCLI	   := ""
Local   cLojCli	   := ""
Local   cCLINOM    := ""
Local   cCOD_MUN   := ""
Local   cMUN       := ""
Local   cEST	   := ""
Local   dDTINI     := CtoD("")
Local   dDTFIM     := CtoD("")

Default _lDel := .F.

SHB->(dbSeek( xFilial("SHB") + ST9->T9_CENTRAB )) 		// --> Para pegar o nome do centro de trabalho
FP1->(dbSeek( FPA->FPA_FILIAL + FPA->FPA_PROJET + FPA->FPA_OBRA))
FP0->(dbSeek( FPA->FPA_FILIAL + FPA->FPA_PROJET))
SA1->(dbSeek( xFilial("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA ))

cCLI	   := FP1->FP1_CLIORI
cLojCli	   := FP1->FP1_LOJORI
cCLINOM	   := FP1->FP1_NOMORI
cCOD_MUN   := SA1->A1_COD_MUN
cMUN	   := SA1->A1_MUN
cEST	   := SA1->A1_EST
dDTINI	   := FPA->FPA_DTINI
dDTFIM     := FPA->FPA_DTENRE
_cUserName := Upper(AllTrim(cUserName))


If _lDel
	_lExclui := _lDel
EndIf

If TQY->(dbSeek(xFilial("TQY") + _cStsNew ))
	_cTpMov := "Status: " + _cStsNew + "-" + AllTrim(TQY->TQY_DESTAT)
EndIf

If     IsInCallStack("LOCA013")  .And.  IsInCallStack("LOCA001")  .And.   IsInCallStack("LOCA01302")  .And.  IsInCallStack("LOCA01301")
	// --> Gerando contrato
	// Se for gera็ใo de contrato passa para status de contrato gerado!
	_cLog    := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " alocado no contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	
ElseIf IsInCallStack("LOCA013")  .And.  IsInCallStack("LOCA001")  .And. ! IsInCallStack("LOCA01302")  .And.  IsInCallStack("LOCA01301")
	// --> Ap๓s troca de bem na ZAG quando jแ existe AS
	// Se for gera็ใo de contrato e houver diferen็a entre DTQ e ZAG altera o bem antigo para disponํvel
	_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " disponํvel ap๓s atualizar contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	
ElseIf IsInCallStack("LOCA001")  .And.  IsInCallStack("LOCA040")
	// --> Cancelamento de AS
	// Cancelamento de AS retorna para disponํvel
	_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " disponํvel ap๓s As: " + AllTrim(_cContr) + " ser cancelada." + " - Obra: " + FPA->FPA_OBRA
	
ElseIf IsInCallStack("U_LOCC001Y")
	// --> Troca em lote
	If     _cStsNew == "10"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " em contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	ElseIf _cStsNew == "00"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " disponํvel ap๓s troca em lote no contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	EndIf
	
ElseIf IsInCallStack("LOCA040")  .And.  IsInCallStack("LOCA040") 
	// --> Troca de bem ๚nico
	If     _cStsNew == "10"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " em contrato " + AllTrim(_cContr) + " Obra: " + FPA->FPA_OBRA
	ElseIf _cStsNew == "00"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " disponํvel ap๓s troca ๚nica no contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	EndIf
	
ElseIf IsInCallStack("U_SF2460I")
	// --> Gera็ใo de nf de remessa
	_cLog    := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " remessado NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	
ElseIf IsInCallStack("U_SF2520E")
	// --> Exclusใo de nf de remessa
	If     _cStsNew == "10"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " em contrato ap๓s estorno remessa NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	ElseIf _cStsNew == "00"
		_cLog := "Bem " + AllTrim(ST9->T9_CODBEM) + " disponivel ap๓s estornar envio ao parceiro da NF: " + _cDocto +"/"+_cSerie
		_lBemProj  := .F.
		_lBemParca := .T.
		SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
		cCLI	   := SA1->A1_COD
		cLojCli	   := SA1->A1_LOJA
		cCLINOM	   := SA1->A1_NOME
		cCOD_MUN   := SA1->A1_COD_MUN
		cMUN	   := SA1->A1_MUN
		cEST	   := SA1->A1_EST
		dDTFIM     := dDataBase
	EndIf
	
ElseIf FunName() == "SPEDNFE"  .And.  IsInCallStack("U_fTras") 		// --> FISTRFNFE.prw 
	If     TQY->TQY_STTCTR == "30"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " em trโnsito via NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	ElseIf TQY->TQY_STTCTR == "20"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " ap๓s estorno da entrega NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	ElseIf TQY->TQY_STTCTR == "90"
		_cLog := "Bem " + AllTrim(ST9->T9_CODBEM) + " ap๓s estorno da entrega NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr)
	EndIf
	
ElseIf FunName() == "SPEDNFE"  .And.  IsInCallStack("U_fLocad") 	// --> FISTRFNFE.prw 
	If     TQY->TQY_STTCTR == "40"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " entregue via NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	ElseIf TQY->TQY_STTCTR == "30"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " em trโnsito ap๓s estorno NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	EndIf
	
ElseIf IsInCallStack("U_GERNFRET") 		// --> Altera็ใo da data de solicita็ใo de retirada
	If ! _lExclui
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " com data de solicita็ใo preenchida no contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	Else
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " com data de solicita็ใo estornada no contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	EndIf
	
ElseIf IsInCallStack("U_MT103FIM") 		// Doc de entrada - GERNFRET
	If AllTrim( Str(_nOpc) ) $ "3;4" .And. AllTrim(_cContr) <> "PARCEIRO"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " retornado NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	ElseIf _nOpc == 5 .And. AllTrim(_cContr) <> "PARCEIRO"
		_cLog := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " entegue ap๓s estorno da NF: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA
	ElseIf AllTrim( Str(_nOpc) ) $ "3;4" .And. AllTrim(_cContr) == "PARCEIRO"
		_cLog      := "Bem " + AllTrim(ST9->T9_CODBEM) + " retornado do parceiro NF: " + _cDocto +"/"+_cSerie
		_lBemProj  := .F.
		_lBemParca := .T.
		SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
		cCLI	   := SA1->A1_COD
		cLojCli	   := SA1->A1_LOJA
		cCLINOM	   := SA1->A1_NOME
		cCOD_MUN   := SA1->A1_COD_MUN
		cMUN	   := SA1->A1_MUN
		cEST	   := SA1->A1_EST
		dDTFIM     := dDataBase
	ElseIf _nOpc == 5 .And. AllTrim(_cContr) == "PARCEIRO"
		_cLog      := "Bem " + AllTrim(ST9->T9_CODBEM) + " em parceiro ap๓s estorno da NF: " + _cDocto +"/"+_cSerie
		_lBemProj  := .F.
		_lBemParca := .T.
		SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
		cCLI	   := SA1->A1_COD
		cLojCli	   := SA1->A1_LOJA
		cCLINOM	   := SA1->A1_NOME
		cCOD_MUN   := SA1->A1_COD_MUN
		cMUN	   := SA1->A1_MUN
		cEST	   := SA1->A1_EST
		dDTFIM     := dDataBase
	EndIf
	
ElseIf IsInCallStack("U_M460FIM") 		// Pedido de venda para parceiros
	If _cStsNew == SuperGetMV("MV_LOCX270",.F.,"09")
		_cLog      := "Bem " + AllTrim(ST9->T9_CODBEM) + " enviado ao parceiro NF: " + _cDocto +"/"+_cSerie
		_lBemProj  := .F.
		_lBemParca := .T.
		SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
		cCLI	   := SA1->A1_COD
		cLojCli	   := SA1->A1_LOJA
		cCLINOM	   := SA1->A1_NOME
		cCOD_MUN   := SA1->A1_COD_MUN
		cMUN	   := SA1->A1_MUN
		cEST	   := SA1->A1_EST
		dDTINI	   := dDataBase
	EndIf
	
ElseIf IsInCallStack("U_MNTA080H")
	If ! _lExclui
		_cLog := "Bem " + AllTrim(ST9->T9_CODBEM) + " incluido/alterado"
	Else
		_cLog := "Bem " + AllTrim(ST9->T9_CODBEM) + " Excluido"
	EndIf
	_lBemProj  := .F.
	_lBemParca := .F.
	_lOS       := .F.
	
ElseIf IsInCallStack("U_MNTA2903")  .Or.  IsInCallStack("U_MNTA420P") 
 //	_dPreLib   := M->TJ_XPRELIB 
	_cServic   := M->TJ_SERVICO 
	_cOS       := M->TJ_ORDEM 
	_cLog      := "Bem " + AllTrim(ST9->T9_CODBEM) + " em manuten็ใo na OS: " + _cOS
	_lBemProj  := .F.
	_lBemParca := .F.
	If !Empty(_cContr)
		If AllTrim(_cContr) == "PARCEIRO"
			cCLI	 := FQ4->FQ4_CODCLI
			cLojCli  := FQ4->FQ4_LOJCLI
			cCLINOM  := FQ4->FQ4_NOMCLI
			cCOD_MUN := FQ4->FQ4_CODMUN
			cMUN	 := FQ4->FQ4_MUNIC
			cEST	 := FQ4->FQ4_EST
		EndIf
		_lOS         := .T. 
	EndIf
	
ElseIf IsInCallStack("U_MNTA400F")  .Or.  IsInCallStack("U_MNTA8801") 
 //	_cTpMov    := "Ordem de Servi็o"
 //	_dPreLib   := STJ->TJ_XPRELIB
	_cServic   := STJ->TJ_SERVICO
	_cOS       := STJ->TJ_ORDEM
	If IsInCallStack("U_MNTA400F")
		_cLog  := "Bem " + AllTrim(ST9->T9_CODBEM) + " ap๓s finaliza็ใo da OS: " + _cOS
	Else
		_cLog  := "Bem " + AllTrim(ST9->T9_CODBEM) + " ap๓s a reabertura da OS: " + _cOS
	EndIf
	_lBemProj  := .F.
	_lBemParca := .F.
	
	If !Empty(_cContr)
		If AllTrim(_cContr) == "PARCEIRO"
			cCLI	 := FQ4->FQ4_CODCLI
			cLojCli  := FQ4->FQ4_LOJCLI
			cCLINOM  := FQ4->FQ4_NOMCLI
			cCOD_MUN := FQ4->FQ4_CODMUN
			cMUN	 := FQ4->FQ4_MUNIC
			cEST	 := FQ4->FQ4_EST
		EndIf
		_lOS   := .T. 
	EndIf

ElseIf IsInCallStack("U_LOCT039")
	_cLog := "Disponibilizacao/Retorno " + AllTrim(ST9->T9_CODBEM) + " incluido."
	_lBemProj  := .F.
	_lBemParca := .F.
	_lOS       := .F.

ElseIf IsInCallStack("LOCA050") //.And. _cStsNew = "00"//Dennis - chamado 27401
	_lBemProj  := .F.
	_lBemParca := .F.
	_lOS       := .F.   

ElseIf IsInCallStack("U_SF1100E")
	// --> Gera็ใo de nf de remessa
	_cLog    := "Bem " + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + " Cancelamento da NF de entrada: " + _cDocto +"/"+_cSerie + " contrato " + AllTrim(_cContr) + " - Obra: " + FPA->FPA_OBRA

EndIf

_cLog := _cLog +" - "+ _cTpMov + " - " + _cUserName + " - " + FWTimeStamp(2,Date(),Time())

/*
If _lExclui
	_cLog := "Estorno " + _cLog
EndIf
*/

_cSeq := GetSx8Num("FQ4","FQ4_SEQ")
ConfirmSx8()

FQ4->(RecLock("FQ4",.T.))
	FQ4->FQ4_CODBEM         := ST9->T9_CODBEM
	FQ4->FQ4_NOME	        := ST9->T9_NOME
	FQ4->FQ4_STSOLD         := _cStsOld
	FQ4->FQ4_STATUS         := _cStsNew
	FQ4->FQ4_DESTAT         := Posicione("TQY",1,xFilial("TQY")+_cStsNew,"TQY_DESTAT")
	FQ4->FQ4_CODFAM         := ST9->T9_CODFAMI
	FQ4->FQ4_TIPMOD         := ST9->T9_TIPMOD
	FQ4->FQ4_FABRIC         := ST9->T9_FABRICA
	// Removido por Frank em 26/02/21 nใo usa mais na 94
	//If ST9->(FieldPos("T9_XSUBLOC")) > 0
	//	FQ4->FQ4_SUBLOC     := ST9->T9_XSUBLOC
	//EndIf
	FQ4->FQ4_POSCON         := ST9->T9_POSCONT
	FQ4->FQ4_CENTRA         := ST9->T9_CENTRAB
	FQ4->FQ4_NOMTRA         := SHB->HB_NOME
	FQ4->FQ4_OS		        := _cOS
	FQ4->FQ4_SERVIC         := _cServic
 //	FQ4->FQ4_PRELIB         := _dPreLib
	FQ4->FQ4_DOCUME         := _cDocto
	FQ4->FQ4_SERIE          := _cSerie
	If _lBemProj .Or. _lBemParca .Or. _lOS
		FQ4->FQ4_CODCLI     := cCLI
		FQ4->FQ4_LOJCLI     := cLojCli
		FQ4->FQ4_NOMCLI     := cCLINOM
		FQ4->FQ4_CODMUN     := cCOD_MUN
		FQ4->FQ4_MUNIC      := cMUN
		FQ4->FQ4_EST	    := cEST
	EndIf
	If _lBemProj  .Or. _lOS
		FQ4->FQ4_PROJET     := _cContr
		If AllTrim(_cContr) <> "PARCEIRO"
			FQ4->FQ4_OBRA   := FPA->FPA_OBRA
			FQ4->FQ4_AS		:= FPA->FPA_AS
			FQ4->FQ4_PREDES := FPA->FPA_DTSCRT
			FQ4->FQ4_DTINI  := dDTINI
			FQ4->FQ4_DTFIM  := dDTFIM
		EndIf
	EndIf
	FQ4->FQ4_LOG	        := _cLog
	FQ4->FQ4_SEQ            := _cSeq
FQ4->(MsUnLock())

IF EXISTBLOCK("LOCX21A") 
	EXECBLOCK("LOCX21A",.T.,.T.,{})
ENDIF

RestArea( _aAreaSD1 )
RestArea( _aAreaSD2 )
RestArea( _aAreaZA0 )
RestArea( _aAreaZAG )
RestArea( _aAreaSB1 )
RestArea( _aAreaOld )

Return

/*Chamada do MATA103*/
/*Dennis Calabrez - 14/10/21*/
Function LOCXITU22(cVar1,cVar2,aLinha,aItensped,cDocSF2,cCliente,cLoja,lCliente,cTipoNF,lPoder3)
Local lRet := .T.

lRet := StaticCall(MATA103,M103FILDV,@aLinha,@aItensped,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)


Return lRet 

/*Chamada do LOCA010*/
/*Dennis Calabrez - 14/10/21*/
Function LOCXITU23( cVar1, cVar2, _cNotax, _cSeriex)
Local lRet := .T.

//lRet := StaticCall( LOCA010, XMailNF, _cNotax, _cSeriex)
lRet := LOCA010Y(_cNotax, _cSeriex)

Return lRet 


// Rotina para validar se pode ser alterado a moeda informada.
// Frank Zwarg Fuga em 22/10/21
Function LOCXITU24
Local _lRet := .T.
Local _cContrato := M->FP0_PROJET
Local _aArea := GetArea()
FPA->(dbSetOrder(1))
FPA->(dbSeek(xFilial("FPA")+_cContrato))
While !FPA->(Eof()) .and. FPA->FPA_FILIAL+FPA->FPA_PROJET == xFilial("FPA")+_cContrato
    IF !empty(FPA->FPA_AS)
        _lRet := .F. // nใo permitir alterar a moeda se jแ houver a gera็ใo de contrato
        Exit
    EndIF
    FPA->(dbSkip())
EndDo
RestArea(_aArea)
Return _lRet

// Rotina para ajuste dos debitos tecnicos
// Frank Z Fuga em 04/04/2022
Function LOCXCONV(_nConv)
Local _cTexto
/*
1 - "SX3"
2 - "SX3->X3_CAMPO"
3 - "SX3->X3_USADO"
4 - "SX3->X3_ORDEM"
*/
If _nConv == 1
    _cTexto := "SX3"
ElseIf _nConv == 2
    _cTexto := "SX3->X3_CAMPO"
ElseIf _nConv == 3
    _cTexto := "SX3->X3_USADO"
ElseIf _nConv == 4
    _cTexto := "SX3->X3_ORDEM"
ElseIf _nConv == 5
    _cTexto := "X3_TIPO"
EndIF
Return _cTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCXITU25
@description	Gatilho do campo FQ7_TPROMA para atualizar os campos 
                FQ7_LCCDES e FQ7_LCLDES.
                Quando o parโmetro estiver ligado (.T.) o cliente destino 
				informado na aba conjunto transportador serแ o utilizado 
				como cliente da nota fiscal de remessa, gerada a partir 
				da rotina de romaneio. 
@author			Jos้ Eulแlio
@since     		06/04/2022
/*/
//-------------------------------------------------------------------
Function LOCXITU25(cCampo)
Local lLOCX304	:= SuperGetMV("MV_LOCX304",.F.,.F.)
Local cRet		:= ""
Local nLcCDes 	:= 0
Local nLcLDes 	:= 0
Local nCliOri 	:= 0
Local nLojOri 	:= 0

//caso o parโmetro esteja ligao e seja viagem de Ida
If lLOCX304 .And. &(ReadVar()) == "0"
    //Atuliza cliente
	If cCampo == "FQ7_LCCDES"
		nCliOri := ASCAN(odlgobr:AHEADER,{|X|ALLTRIM(X[2])=="FP1_CLIORI"  })
		If !(Empty(odlgobr:aCols[odlgobr:nAt][nCliOri]))
			cRet	:= odlgobr:aCols[odlgobr:nAt][nCliOri]
		Else
			cRet	:= FP0->FP0_CLI
		EndIf
    //Atuliza Loja
	ElseIf cCampo == "FQ7_LCLDES"
		nLojOri := ASCAN(odlgobr:AHEADER,{|X|ALLTRIM(X[2])=="FP1_LOJORI"  })
		If !(Empty(odlgobr:aCols[odlgobr:nAt][nLojOri]))
			cRet	:= odlgobr:aCols[odlgobr:nAt][nLojOri]
		Else
			cRet	:= FP0->FP0_LOJA
		EndIf
	EndIf
Else
    //caso nใo tenha o parโmetro ativado ou nใo seja viagem de ida, mant้m o valor
    //Atuliza cliente
	If cCampo == "FQ7_LCCDES"
		 nLcCDes := ASCAN(odlgcnp:AHEADER,{|X|ALLTRIM(X[2])=="FQ7_LCCDES"  })
		cRet	:= odlgcnp:aCols[odlgcnp:nAt][nLcCDes]
    //Atualiza Loja
	ElseIf cCampo == "FQ7_LCLDES"
		nLcLDes := ASCAN(odlgcnp:AHEADER,{|X|ALLTRIM(X[2])=="FQ7_LCLDES"  })
		cRet	:= odlgcnp:aCols[odlgcnp:nAt][nLcLDes]
	EndIf
EndIf

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCXITU26
@description	Retorna se o produto o bem ou produto ้ acess๓rio SIGALOC
@author			Jos้ Eulแlio
@since     		06/04/2022
/*/
//-------------------------------------------------------------------
Function LOCXITU26(cProd)
Local lRet      := .F.
Local cLocx014 	:= SUPERGETMV("MV_LOCX014",.F.,"") // PRODUTO ACESSORIO
Local CGRPAND	:= ""
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaST9	:= ST9->(GetArea())
Local aArea	    := GetArea()

Default cProd   := ""
//Default cBem    := "" //Caso seja necessแrio buscar pelo Bem descomentar o trecho abaixo e enviar o segundo parโmetro

//se nใo indicou produto e indicou bem, busca o produto (T9_CODESTO)
/*If Empty(cProd) .And. !Empty(cBem)
    ST9->(DbSetOrder(1))
    If ST9->(DbSeek(xFilial("ST9") + cBem))
        cProd := ST9->T9_CODESTO
    EndIf
EndIf*/

//retorna produto que estแ configurado com acess๓rio
IF SBM->(FIELDPOS("BM_XACESS")) > 0
    CGRPAND := LOCA00189()
ELSE
    CGRPAND := cLocx014
ENDIF

//verifica se o produto estแ entre os acess๓rios
SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1") + cProd))
    lRet := AllTrim(SB1->B1_GRUPO) $ CGRPAND
EndIf

RestArea(aAreaSB1)
RestArea(aAreaST9)
RestArea(aArea)

Return lRet 
