#include 'protheus.ch'
#include 'locxchi.ch'

#Define SAliasHead  4
#Define ScOpFin     9

/*/{Protheus.doc} LxGrvLFChi
	Graba información en la tabla SF3 - Libros Fiscales.
	La función es llamada en GravaNfGeral (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param cAlias: Alias de tabla SF1/SF2
    @return Nil
    /*/
Function LxGrvLFChi(cAlias)
Local cKey     := ""
Local aAreaAnt := {}
Local aSF3     := {}

Default cAlias := ""

    If cAlias == "SF1"
        cKey := xFilial("SF3")+SF1->(DtoS(F1_DTDIGIT)+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

        aAreaAnt := GetArea()
        DbSelectArea("SF3")
        aSF3 := SF3->(GetArea())
        SF3->(DbSetOrder(1))
        SF3->(MsSeek(cKey))
        While !SF3->(EOF()) .AND. SF3->(F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) == cKey
            RecLock("SF3",.F.)
                Replace F3_RECHON With SF1->F1_RECHON
            MsUnlock()
            SF3->(DbSkip())
        Enddo
        RestArea(aSF3)
        RestArea(aAreaAnt)
    Endif

Return Nil

/*/{Protheus.doc} LxGrvNfChi
	Graba información especifica en notas fiscales del país Chile.
	La función es llamada en GravaNfGeral (LOCXNF.PRW).
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param aCfgNF: Array de configuración de nota fiscal.
            lInclui: .T. para la inclusion de documentos.
    @return lRet: .T. si cumple las condiciones.
    /*/
Function LxGrvNfChi(aCfgNF, lInclui)
Local aDadSFE := {}
Local lRet    := .T.
Local cAlias  := ""

Default aCfgNF  := {}
Default lInclui := .F.

    cAlias := aCfgNF[SAliasHead]

    If lInclui .And. cAlias == "SF1" .And. !("NC" $ SF1->F1_ESPECIE)
        If SF1->F1_VALIMP5 >0 ///retencao de honorarios RHO
            Aadd(aDadSFE,{.F.,"",SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,"RHO",0,0,0,SF1->F1_ESPECIE})
            GrvRetSFE(1,aDadSFE)
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} LxDelCCChi
	Actualización de movimientos de caja chica en anulación de documentos fiscales.
	La función es llamada en LocXDelCC (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param  cForn: Código del proveedor.
            cLoja: Tienda del proveedor.
            cDoc: Número de documento.
            cSerie: Serie del documento.
            cNroAdia: Número de anticipo.
            nVlrDel: Valor del anticipo.
    @return Nil
    /*/
Function LxDelCCChi(cForn, cLoja, cDoc, cSerie, cNroAdia, nVlrDel)
Local cCx      := ""
Local nValDev  := 0
Local aSldAtu  :={}
Local cFilSET := xFilial("SET")
Local cFilSEU := xFilial("SEU")

Default cForn    := ""
Default cLoja    := ""
Default cDoc     := ""
Default cSerie   := ""
Default cNroAdia := ""
Default nVlrDel  := 0

    cCx := SEU->EU_CAIXA
    SEU->(DbSetOrder(3))
    If SEU->(DbSeek(cFilSEU+cNroAdia))
        While (SEU->(!Eof())) .And. SEU->EU_FILIAL == cFilSEU .And. SEU->EU_NROADIA == cNroAdia
            RecLock("SEU",.F.)
            Replace	SEU->EU_BAIXA With Ctod(" / / ")
            If SEU->EU_TIPO == "02" //devolucao do saldo do adiantamento
                If SEU->EU_FORNECE == cForn .And. SEU->EU_LOJA == cLoja
                    If Alltrim(SEU->EU_NRCOMP) == AllTrim(cDoc) .And. AllTrim(SEU->EU_SERCOMP) == AllTrim(cSerie)
                        nVlrDel += SEU->EU_VALOR
                        nValDev += SEU->EU_VALOR
                        SEU->(DbDelete())
                    Endif
                Endif
            Endif
            MsUnlock()
            SEU->(DbSkip())
        Enddo
        //³ Atualiza saldo do caixinha e niveis superiores, se houverem ³
        If nValDev <> 0
            dbSelectArea("SET")
            dbSetOrder(1)
            MsSeek(cFilSET+cCx)
            aSldAtu := Fa570AtuSld( ET_CODIGO)
            RecLock("SET",.F.)
            REPLACE ET_SALDO WITH aSldAtu[1][1]
            MsUnlock()
        Endif
    Endif

Return Nil


/*/{Protheus.doc} LxNCorrChi
    Disparador del campo F1_NUMCOR/F2_NUMCOR.
    La función es llamada en ChiFillCor (LOCXNF2.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param cSerie: Serie del documento.
    @return cNumCor: Número correlativo.
    /*/
Function LxNCorrChi(cSerie)
Local aArea    := GetArea()
Local cNumCor  := Criavar('FY_NUMCOR',.F.)
Local dDtDigit := ""
Local lHonora  := .F.
Local cAlias   := aCfgNF[SAliasHead]

Default cSerie := CriaVar("FY_SERIE",.F.)

    If cAlias == "SF1" .And. SubStr(M->F1_ESPECIE,3,1) <> "I" //NF e NDP
        If Type("M->F1_RECHON") <> "U"
            If M->F1_RECHON <> "1"
                lHonora := .F.
            Else
                lHonora := .T.
            Endif
        Endif
    EndIf

    DbSelectArea('SDV')
    SDV->(DbSetOrder(1))
    If SDV->(DbSeek(xFilial('SDV')+subStr(cSerie,1,3)))
        If SDV->DV_GERACOR == "1" .And. !lHonora //Usa Correlativo
            dDtDigit := If(cAlias == "SF1",M->F1_DTDIGIT,M->F2_DTDIGIT)
            cNumCor := CORR_PROX(dDtDigit)
        EndIf
    EndIf

    RestArea(aArea)
Return cNumCor

/*/{Protheus.doc} NfTudOkChi
    La función es llamada en NfTudOk (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 29/09/2022
    @version version
    @param  aCfgNf: Array con la configuración del documento.
			aDupli: Array con valores financieros.
            nBaseDup: Valor del título financiero de la nota fiscal.
			nMoedaNF: Moneda del documento.
			nMoedaCor: Moneda a convertir el valor.
			nTaxa: Valor de la tasa de cambio.
			l103Class: Indica si existe integración.
            cCxCaixa: Código de caja chica.
            nCxValor: Valor del movimiento de caja chica.
			cFunName: Nombre de la función.
    @return lRet: .T. si cumple con las condiciones.
    /*/
Function NfTudOkChi(aCfgNf, aDupli, nBaseDup, nMoedaNF, nMoedaCor, nTaxa, l103Class, cCxCaixa, nCxValor, cFunName)
Local lRet      := .T.
Local nI        := 0
Local nTotDup   := 0
Local cCentavos := ""

Default aCfgNf    := {}
Default aDupli    := {}
Default nBaseDup  := 0
Default nMoedaNF  := 1
Default nMoedaCor := 1
Default nTaxa     := 0
Default l103Class := .F.
Default cCxCaixa  := ""
Default nCxValor  := 0
Default cFunName  := Funname()

    cCentavos  := Iif(nMoedaNF==1,"MV_CENT",("MV_CENT"+AllTrim(Str(nMoedaNF))))

    // Valida que exista informacion de los titulos cuando la condicion de pago es informada
    If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .AND. nBaseDup > 0 .AND. Val(Alltrim(Extrae(aDupli[1],5)))==0
        Aviso(STR0001,STR0002,{STR0003}) //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
        lRet	:= .F.
    EndIf

    //Controla se o valor total das duplicatas bate com o total
    If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .and. Val(Substr(aDupli[1],rat("³",aDupli[1])+1,len(aDupli[1]))) > 0  // O sistema gera uma estrutura vazia para duplicata.
        For nI := 1 To Len(aDupli)
            nTotDup += DesTrans(Extrae(aDupli[nI],5,))
        Next nI
        If lRet
            If Abs(Round(xMoeda(nBaseDup,nMoedaNF,nMoedaCor,dDataBase,,nTaxa),SuperGetMV(cCentavos,.F.,0)) - nTotDup) > SuperGetMV("MV_LIMPAG")
                Aviso(STR0001,STR0002,{STR0003})				 //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
                lRet	:= .F.
            EndIf
        EndIf
    Endif

    If lRet .And. !Empty(cCxCaixa)
        nCxValor := Round(MaFisRet(,'NF_TOTAL'),MsDecimais( nMoedaNF ))
    EndIf
    
Return lRet

/*/{Protheus.doc} BaixaCxChi
    Actualiza registro de tabla SEU - Caja chica.
    La función es llamada en NFVldCxa (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 29/09/2022
    @version version
    @param  cAdia: Código de anticipo.
            lAdia: Indica si es anticipo (.T.).
    @return Nil
    /*/
Function BaixaCxChi(cAdia, lAdia)

    If !Empty(cAdia) .And. !lAdia
        SEU->(DbSetOrder(3))
        If SEU->(DbSeek(xFilial("SEU")+cAdia))
            While (SEU->(!Eof())) .And. SEU->EU_FILIAL == xFilial("SEU") .And. SEU->EU_NROADIA == cAdia
                RecLock("SEU",.F.)
                Replace	EU_BAIXA With dDataBase
                MsUnlock()
                SEU->(DbSkip())
            Enddo
        Endif
    Endif

Return Nil
