#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM026.CH"

Function GPEM026I()
Local aButtons  := {}
Local aSays     := {}
Local cMsg      := ""
Local lContinua := .F.
Local nOpcA     := 0
Local aErros	:= {}
Local cMsgHelp	:= ""
Local cLink		:= 'https://tdn.totvs.com/x/uk0wJg'

Private aCodFol := {}
Private aLog    := {}
Private aTitle  := {}
Private cPerg   := "UPDBINRES"

//Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
Fp_CodFol(@aCodFol, xFilial("SRV", cFilAnt), .F., .F.)

//Se não existir cadastro da verba para os Ids 1870, 1871, 1872, 1882, 1891, 1892 e 1893 aborta o processamento da rotina
If Len(aCodFol) >= 1893
	lContinua := (!Empty( aCodFol[1870,1] ) .And. !Empty( aCodFol[1871,1] ) .And. !Empty( aCodFol[1872,1]) .And. !Empty( aCodFol[1882,1]).And. !Empty( aCodFol[1893,1]))
EndIf

// VERIFICA SE ENCONTROU O GRUPO DE PERGUNTAS
If lContinua  .And. GetRpoRelease() != "12.1.017" .And. !SX1->(DbSeek('UPDBINRES'))
	cMsg :=  + CRLF + OemToAnsi(STR0273) + Alltrim(cPerg) //Não foi encontrado o grupo de perguntas

	cMsgHelp := ""
    //Antes de prosseguir será necessário criar o grupo de perguntas. Para isso, siga as instruções contidos no link abaixo:
	cMsgHelp += + CRLF + OemToAnsi(STR0274)
	cMsgHelp += + CRLF + cLink + CRLF

	aAdd(aErros, cMsgHelp)

	Help(,, 'NOPERGUNT',, cMsg, 1, 0,,,,,, {aErros})

	Return()
ElseIf !lContinua
	cMsg := OemToAnsi( STR0275 ) + CRLF         //Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências CP 11 do seguinte identificador
	cMsg += OemToAnsi( STR0276 ) + CRLF + CRLF  //1870 - Informativo Base INSS Ferias
    cMsg += OemToAnsi( STR0277 ) + CRLF         //Para executar essa rotina é obrigatório o cadastro da verba (Tipo 3 - Base Provento), natureza 9989 e Incidências CP igual a 31 do seguinte identificador:"
	cMsg += OemToAnsi( STR0278 ) + CRLF + CRLF  //1871 - Informativo desconto INSS Ferias
    cMsg += OemToAnsi( STR0279 ) + CRLF         //Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências FGTS 11 do seguinte identificador:"
	cMsg += OemToAnsi( STR0280 ) + CRLF + CRLF  //1872 - Informativo Base FGTS Ferias"
    cMsg += OemToAnsi( STR0281 ) + CRLF         //Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências FGTS 12 do seguinte identificador:"
	cMsg += OemToAnsi( STR0282 ) + CRLF + CRLF  //1882 - Informativo Base FGTS 13o Salario Ferias"
    cMsg += OemToAnsi( STR0283 ) + CRLF         //Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências CP 91 do seguinte identificador
	cMsg += OemToAnsi( STR0284 ) + CRLF + CRLF  //1891 - Informativo dedução base INSS Ferias - Incid = 91"
    cMsg += OemToAnsi( STR0285 ) + CRLF         //Para executar essa rotina é obrigatório o cadastro da verba (Tipo 4 - Base Desconto), natureza 9989 e Incidências CP 95 do seguinte identificador
	cMsg += OemToAnsi( STR0286 ) + CRLF + CRLF   //"1892 - Informativo dedução base INSS Ferias - Incid = 95"
    cMsg += OemToAnsi( STR0305 ) + CRLF         //Para executar essa rotina é obrigatório o cadastro da verba (Tipo 3 - Base Provento), natureza 9989 e Incidências IR igual a 33 do seguinte identificador
	cMsg += OemToAnsi( STR0306 )                //"1893 - Informativo dedução IRRF Ferias"
	MsgInfo( cMsg )
	Return()
EndIf

aAdd(aSays,OemToAnsi( STR0287 )) //"Este programa tem como objetivo gerar as verbas de Id 1870 - Informativo Base INSS"
aAdd(aSays,OemToAnsi( STR0288 )) //"Ferias, 1871 - Informativo desconto INSS Ferias, 1872 - Informativo Base FGTS Ferias,"
aAdd(aSays,OemToAnsi( STR0289 )) //"1882 - Informativo Base FGTS 13o Salario Ferias, 1891 - Informativo dedução base INSS"
aAdd(aSays,OemToAnsi( STR0290 )) //"Ferias - Incid = 91 e 1892 - Informativo dedução base INSS Ferias - Incid = 95 no"
aAdd(aSays,OemToAnsi( STR0307 )) //"movimento de férias (Tabela SRR). o Id 1893 - Informativo dedução IRRF Ferias será excluído"
aAdd(aSays,OemToAnsi( STR0291 )) //"das férias e pode ser gerado no movimento de folha (Apenas período fechado)."
aAdd(aSays,OemToAnsi( STR0292 )) //"Clique no botão Abrir para consultar a documentação no TDN e verificar"
aAdd(aSays,OemToAnsi( STR0293 )) //"os procedimentos necessários para transmitir corretamente o evento S-1200 ao RET."

aAdd(aButtons, { 14,.T.,{|| ShellExecute("open","https://tdn.totvs.com/x/uk0wJg","","",1) } } )
aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( OemToAnsi( STR0294 ), aSays, aButtons ) //"Geração dos Id`s 1870, 1871, 1872, 1882, 1891, 1892 e 1893"

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( STR0295 ) ) //"Funcionários que tiveram as verbas de Id 1870, 1871, 1872, 1882, 1891, 1892 e 1893 geradas:"
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    fMakeLog(aLog,aTitle,,,"GPEM026I",OemToAnsi( STR0296 ),"M","P",,.F.) //"Log de Ocorrências"
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração dos Id`s
/*/
Static Function fProcessa()

Local cAliasQry := GetNextAlias()
Local cFilOld   := cFilAnt
Local cJoinRRRV	:= "% " + FWJoinFilial( "SRR", "SRV" ) + " %"
Local cWhere    := ""
Local nValor1870:= 0
Local nValor1871:= 0
Local nValor1872:= 0
Local nValor1882:= 0
Local nValor1891:= 0
Local nValor1892:= 0
Local nValor1893:= 0
Local cCodFil   := ""
Local cCodMat   := ""
Local dData     := cTod("//")
Local cPer      := ""
Local cSem      := ""
Local dDtPag    := cTod("//")
Local cSeq      := ""
Local dDtRef    := cTod("//")
Local cCenCus   := ""
Local cCodINCCP := ""
Local cCodINCFGT:= ""
Local cCodFOL   := ""
Local cCodINCIRF:= ""
Local lProc     := .F.
Local lTem1893  := .F.
Local lPerFech  := .F.
Local lGer1893  := .F.
Local nValDel	:= 0
Local cDINSSFM  := SuperGetMV("MV_DINSSFM", .F., "S")
Local cCodNATUR := ""
Local nValor0013:= 0

Private cPdDif  := Space(TamSX3("RV_COD")[1])

// Exibe a mensagem perguntando ao usuário deseja gerar a verba de Id 1893 na folha em período já fechado.
// Deseja gerar a verba de Id 1893 no cálculo de folha? esta verba será gerada somente se o roteiro estiver fechado
lGer1893 := MsgYesNo( OemToAnsi( STR0308 ), OemToAnsi( STR0306 ) )

//Busca a verba de diferença
If cDINSSFM == "N" .And. !fVerbDIf()
    Return
EndIf

Pergunte( cPerg, .F. )
MakeSqlExpr( cPerg )

//Filial
If !Empty(mv_par01)
    cWhere += mv_par01
EndIf

//Matricula
If !Empty(mv_par02)
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += mv_par02
EndIf

//Periodo inicial
cWhere += Iif(!Empty(cWhere)," AND ","")
cWhere += "RR_PERIODO >= '" + mv_par03 + "' "

//Periodo final
cWhere += "AND RR_PERIODO <= '" + mv_par04 + "' "

//Roteiro Ferias
cWhere += "AND RR_ROTEIR = 'FER' "

//Prepara a variável para uso no BeginSql
cWhere := "%" + cWhere + "%"

//Processa a query e cria a tabela temporária com os resultados
BeginSql alias cAliasQry
    SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PERIODO, SRR.RR_SEMANA, SRR.RR_DATA, SRR.RR_DATAPAG, SRR.RR_PD, SRR.RR_DTREF, MIN(SRR.RR_SEQ) AS RR_SEQ, SUM(SRR.RR_VALOR) AS RR_VALOR
    FROM %table:SRR% SRR
    INNER JOIN %table:SRV% SRV
    ON	%exp:cJoinRRRV% AND
        SRV.RV_COD = SRR.RR_PD AND
        SRV.%notDel%
	WHERE %exp:cWhere% AND
        (SRV.RV_INCCP IN ('11','31','91','95') OR SRV.RV_INCFGTS IN ('11') OR SRV.RV_INCFGTS IN ('12') OR SRV.RV_INCIRF IN ('33') OR SRV.RV_NATUREZ IN ('9901')) AND
        SRR.%notDel%
	GROUP BY SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PERIODO, SRR.RR_SEMANA, SRR.RR_DATA, SRR.RR_PD, SRR.RR_DATAPAG, SRR.RR_DTREF
    ORDER BY SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_CC, SRR.RR_PERIODO, SRR.RR_SEMANA, SRR.RR_DATA, SRR.RR_PD, SRR.RR_DATAPAG, SRR.RR_DTREF
EndSql

While (cAliasQry)->( !EoF() )

    lProc := .T.

    //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
    If xFilial("SRV",(cAliasQry)->RR_FILIAL) != xFilial("SRV",cFilOld)
        cFilOld := (cAliasQry)->RR_FILIAL
        RstaCodFol()
        Fp_CodFol(@aCodFol, xFilial("SRV", (cAliasQry)->RR_FILIAL), .F., .F.)

        //Verifica se existe o cadastro da verba de Id 1870, 1871, 1872, 1882, 1891, 1892 ou 1893 e se a verba foi preenchida
        If Len(aCodFol) >= 1893
            If (Empty( aCodFol[1870,1] ) .Or. Empty( aCodFol[1871,1] ) .Or. Empty( aCodFol[1872,1]) .Or. Empty( aCodFol[1882,1]) .Or. Empty( aCodFol[1893,1]))
                //Adiciona no log de ocorrências
                //Adiciona no log de ocorrências
                //"Cadastre os Id`s 1870, 1871, 1872, 1882, 1891, 1892 e 1893 para a filial '"
                //"' para continuar o processamento:"
                aAdd( aLog[1], OemToAnsi( STR0297 ) + (cAliasQry)->RR_FILIAL + OemToAnsi( STR0298 ))
                Exit
            EndIf
        EndIf
    EndIf

    //Reinicializa variáveis
    If cCodFil + cCodMat + dtos(dDtPag) <> (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT + (cAliasQry)->RR_DATAPAG
        nValor1870  := 0
        nValor1871  := 0
        nValor1872  := 0
        nValor1882  := 0
        nValor1891  := 0
        nValor1892  := 0
        nValor1893  := 0
        nValDel     := 0
    EndIf

    cCodFil := (cAliasQry)->RR_FILIAL
    cCodMat := (cAliasQry)->RR_MAT
    dData   := sToD((cAliasQry)->RR_DATA)
    cPer    := (cAliasQry)->RR_PERIODO
    cSem    := (cAliasQry)->RR_SEMANA
    dDtPag  := sToD((cAliasQry)->RR_DATAPAG)
    cSeq    := (cAliasQry)->RR_SEQ
    dDtRef  := sToD((cAliasQry)->RR_DTREF)
    cCenCus := (cAliasQry)->RR_CC

    cCodINCCP 	:= RetValSrv( (cAliasQry)->RR_PD, (cAliasQry)->RR_FILIAL, 'RV_INCCP' )
    cCodINCFGT 	:= RetValSrv( (cAliasQry)->RR_PD, (cAliasQry)->RR_FILIAL, 'RV_INCFGTS' )
    cCodFOL 	:= RetValSrv( (cAliasQry)->RR_PD, (cAliasQry)->RR_FILIAL, 'RV_CODFOL' )
    cCodINCIRF  := RetValSrv( (cAliasQry)->RR_PD, (cAliasQry)->RR_FILIAL, 'RV_INCIRF' )
    cCodNATUR   := RetValSrv( (cAliasQry)->RR_PD, (cAliasQry)->RR_FILIAL, 'RV_NATUREZ' )

    //Identifica os valores de INSS
    If !(cCodFOL $ "1870|1871|1891|1892")
        If cCodINCCP == '11'//Compoe Base de INSS
            nValor1870 += (cAliasQry)->RR_VALOR
        ElseIf cCodINCCP == '31' //Desconto de INSS
            nValor1871 += (cAliasQry)->RR_VALOR
        ElseIf cCodINCCP == '91' //Desconto de INSS Suspenso
            nValor1891 += (cAliasQry)->RR_VALOR
        ElseIf cCodINCCP == '95' //Exclusiva do empregador
            nValor1892 += (cAliasQry)->RR_VALOR
        EndIf
    EndIf

    //Identifica os valores de FGTS
    If (cAliasQry)->RR_PD <> aCodFol[1872, 1] .And. cCodINCFGT == '11'
        nValor1872 += (cAliasQry)->RR_VALOR
    EndIf

    //Identifica os valor de FGTS 13 Salario
    If (cAliasQry)->RR_PD <> aCodFol[1882, 1] .And. cCodINCFGT == '12'
        nValor1882 += (cAliasQry)->RR_VALOR
    EndIf

    //Identifica os valor de Descoto de Ir
    If (cAliasQry)->RR_PD <> aCodFol[1893, 1] .And. cCodINCIRF == '33'
        nValor1893 += (cAliasQry)->RR_VALOR
    EndIf

    //Verifica se a verba de IR já existe no cálculo de férias
    If (cAliasQry)->RR_PD == aCodFol[1893, 1]
        lTem1893 := .T.
        nValDel  := (cAliasQry)->RR_VALOR  
    EndIf

    //Guarda o valor da verba de Base de INSS
    If cCodFOL == "0013" .And. cCodNATUR == "9901" .And. cDINSSFM == "N" .And. !Empty(cPdDif)
        nValor0013 := (cAliasQry)->RR_VALOR  
    EndIf

    //Ordena a tabela SRA pela ordem 1 - RA_FILIAL+RA_MAT
    SRA->( dbSetOrder(1) )

    //Posiciona na tabela SRA
    SRA->( dbSeek( (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT ) )

    //Ordena a tabela SRR pela ordem 1 - RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
    SRR->( dbSetOrder(1) )

    //Pula para o próximo registro
    (cAliasQry)->( dbSkip() )

    //Grava a verba somente após percorrer todos os registros do funcionário
    If cCodFil + cCodMat + dtos(dDtPag) <> (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT + (cAliasQry)->RR_DATAPAG

        lPerFech := fVld1562(cCodFil, cCodMat, aCodFol[1562, 1], cPer, cSem, cSeq, cCenCus)

        //Grava a verba de Id 1870
        If nValor1870 > 0
            fGrava(cCodFil, cCodMat, aCodFol[1870, 1], dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nValor1870)
        EndIf

        //Grava a verba de Id 1871
        If nValor1871 > 0
            fGrava(cCodFil, cCodMat, aCodFol[1871, 1], dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nValor1871)
        EndIf

        //Grava a verba de Id 1872
        If nValor1872 > 0
            fGrava(cCodFil, cCodMat, aCodFol[1872, 1], dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nValor1872)
        EndIf

        //Grava a verba de Id 1882
        If nValor1882 > 0
            fGrava(cCodFil, cCodMat, aCodFol[1882, 1], dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nValor1882)
        EndIf

        //Grava a verba de Id 1891
        If nValor1891 > 0
            fGrava(cCodFil, cCodMat, aCodFol[1891, 1], dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nValor1891)
        EndIf

        //Grava a verba de Id 1892
        If nValor1892 > 0
            fGrava(cCodFil, cCodMat, aCodFol[1892, 1], dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nValor1892)
        EndIf

        //Deleta a verba de Id 1893 no roteiro FER e cria na folha
        If lTem1893
            fDel(cCodFil + cCodMat + "F" + DTOS(dData) + aCodFol[1893, 1] + cCenCus, cCodFil, cCodMat, cPer, aCodFol[1893, 1], nValDel)
        EndIf

        //Gera o ID 1893 na folha
        If lGer1893 .And. nValor1893 > 0 .And. lPerFech
            fGravaFol(cCodFil, cCodMat, aCodFol[1893, 1], dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nValor1893)
        EndIf

        //Caso o parametro MV_DINSSFM esteja com N e a verba de Id 1870 não tenha o mesmo valor do Id 0013
        If cDINSSFM == "N" 
            nVlrDif := nValor0013 - nValor1870
            If nVlrDif > 0
                fGrava(cCodFil, cCodMat, cPdDif, dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nVlrDif)
            EndIf
        EndIf
    EndIf
EndDo

//Fecha a tabela temporária da query
(cAliasQry)->( dbCloseArea() )

If !lProc
    aAdd( aLog[1],  OemToAnsi( STR0299 )) //"Não foram encontrados registros para processamento."
EndIf

Return

/*/{Protheus.doc} fGrava
Função responsável pela gravação das verbas
/*/
Static Function fGrava(cCodFil, cCodMat, cPD, dData, cPer, cSem, dDtPag, cSeq, cProc, dDtRef, cCenCus, nValor)

    Local aArea	    := GetArea()
    Local aAreaSRR  := SRR->(GetArea())
    Local lNovo := .T.

    SRR->( dbSetOrder(1) )
    lNovo := SRR->( !dbSeek( cCodFil + cCodMat + "F" + DTOS(dData) + cPD + cCenCus ))

    //Grava a verba de Id 1871
    If nValor > 0
        //Trava o registro na SRR para edição
        If SRR->( RecLock("SRR", lNovo) )
            //Se for inclusão, grava todos campos da SRR
            //Se for alteração, apenas altera o valor do registro
            If lNovo
                SRR->RR_FILIAL  := cCodFil
                SRR->RR_MAT     := cCodMat
                SRR->RR_PD      := cPD
                SRR->RR_TIPO1   := "V"
                SRR->RR_TIPO2   := "C"
                SRR->RR_DATA    := dData
                SRR->RR_TIPO3   := "F"
                SRR->RR_PERIODO := cPer
                SRR->RR_ROTEIR  := "FER"
                SRR->RR_SEMANA  := cSem
                SRR->RR_DATAPAG := dDtPag
                SRR->RR_SEQ     := cSeq
                SRR->RR_PROCES  := cProc
                SRR->RR_DTREF   := dDtRef
                SRR->RR_CC      := cCenCus
            EndIf

            SRR->RR_VALOR   := nValor

            //Adiciona no log de ocorrências
            //              Filial                         "  -  Matrícula: "                    "  -  Período: "                  "  -  Verba: "              "  -  Valor: R$ "
            aAdd( aLog[1], OemToAnsi( STR0300 ) + cCodFil + OemToAnsi( STR0301 ) + cCodMat + OemToAnsi( STR0302 ) + cPer + OemToAnsi( STR0303 ) + cPD + OemToAnsi( STR0304 ) + Transform( nValor, "@E 99,999,999,999.99" ) + OemToAnsi(STR0310) )

            //Libera o registro da SRR
            SRR->( MsUnlock() )
        EndIf
    EndIf

    RestArea(aAreaSRR)
    RestArea(aArea)

Return


/*/{Protheus.doc} fDel
Função responsável por deletar verba SRR
/*/
Static Function fDel(cChave, cCodFil, cCodMat, cPer, cPD, nValor)

    Local aArea	    := GetArea()
    Local aAreaSRR  := SRR->(GetArea())

    SRR->( dbSetOrder(1) )
    If SRR->(dbSeek( cCHave ))
		RecLock( "SRR", .F. )
		SRR->(DBDelete())

        //Adiciona no log de ocorrências
        //              Filial                         "  -  Matrícula: "                    "  -  Período: "                  "  -  Verba: "             "  -  Valor: R$ "                                 "  -  Deletada da tabela SRR "
        aAdd( aLog[1], OemToAnsi( STR0300 ) + cCodFil + OemToAnsi( STR0301 ) + cCodMat + OemToAnsi( STR0302 ) + cPer + OemToAnsi( STR0303 ) + cPD + OemToAnsi( STR0304 ) + Transform( nValor, "@E 99,999,999,999.99" ) + OemToAnsi(STR0311) )

		SRR->(MSUnlock())
	EndIf

    RestArea(aAreaSRR)
    RestArea(aArea)

Return


/*/{Protheus.doc} fGravaFOL
Função responsável pela gravação na SRD
/*/
Static Function fGravaFOL(cCodFil, cCodMat, cPD, dData, cPer, cSem, dDtPag, cSeq, cProc, dDtRef, cCenCus, nValor)

    Local aArea	    := GetArea()
    Local aAreaSRD  := SRD->(GetArea())
    Local lNovo := .T.

    //Trava o registro na SRD para edição
    dbSelectArea("SRD")
    SRD->( dbSetOrder(1) ) //Ordena a tabela SRD pela ordem 1 - RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
    lNovo := SRD->( !dbSeek( cCodFil + cCodMat + cPer + cPD + cSem + cSeq + cCenCus ))

    If SRD->( RecLock("SRD", lNovo) )
        //Se for inclusão, grava todos campos da SRD
        //Se for alteração, apenas altera o valor do registro
        If lNovo
            SRD->RD_FILIAL  := cCodFil
            SRD->RD_MAT     := cCodMat
            SRD->RD_CC      := cCenCus
            SRD->RD_PD      := cPD
            SRD->RD_TIPO1   := "V"
            SRD->RD_DATARQ  := cPer
            SRD->RD_DATPGT  := dDtPag
            SRD->RD_SEQ     := ""
            SRD->RD_TIPO2   := "C"
            SRD->RD_MES     := SubStr( cPer, 5, 2 )
            SRD->RD_STATUS  := "A"
            SRD->RD_INSS    := "N"
            SRD->RD_IR      := "N"
            SRD->RD_FGTS    := "N"
            SRD->RD_PROCES  := cProc
            SRD->RD_PERIODO := cPer
            SRD->RD_SEMANA  := cSem
            SRD->RD_ROTEIR  := "FOL"
            SRD->RD_DTREF   := dDtPag
        EndIf

        SRD->RD_VALOR   := nValor
        
        //Adiciona no log de ocorrências
        //              Filial                         "  -  Matrícula: "                    "  -  Período: "                  "  -  Verba: "              "  -  Valor: R$ "
        aAdd( aLog[1], OemToAnsi( STR0300 ) + cCodFil + OemToAnsi( STR0301 ) + cCodMat + OemToAnsi( STR0302 ) + cPer + OemToAnsi( STR0303 ) + cPD + OemToAnsi( STR0304 ) + Transform( nValor, "@E 99,999,999,999.99" ) + OemToAnsi(STR0309) )

        //Libera o registro da SRD
        SRD->( MsUnlock() )
    EndIf

    RestArea(aAreaSRD)
    RestArea(aArea)

Return


/*/{Protheus.doc} fVld1562
Função responsável por verificar se a verba 1562 está no acumulado
/*/
Static Function fVld1562(cCodFil, cCodMat, cPD, cPer, cSem, cSeq, cCenCus)

    Local aArea	    := GetArea()
    Local aAreaSRD  := SRD->(GetArea())
    Local lRet      := .F.

    //Ordena a tabela SRD pela ordem 1 - RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC
    dbSelectArea("SRD")
    SRD->( dbSetOrder(1) )
    //Verifica se a verba de Id 1562 já exista na tabela SRD
    lRet := SRD->( dbSeek( cCodFil + cCodMat + cPer + cPD + cSem + cSeq + cCenCus ) )

    RestArea(aAreaSRD)
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} fVerbDIf
Cria tela com pergunte sobre a verba de diferença de INSS
@author  lidio.oliveira
@since   09/09/2022
@version 1.0
/*/
Static Function fVerbDIf()

	Local aAdvSize      := {}
	Local aInfoAdvSize  := {}
	Local aObjCoords    := {}
	Local aObjSize      := {}
	Local bSet15		:= { || nOpcA := 1, oDlg:End() }
	Local bSet24		:= { || nOpca := 2, oDlg:End() }
	Local nOpcA			:= 0
    Local lRet          := .T.
	Local oVerba

	aAdvSize		:= MsAdvSize()
	aAdvSize[6]	    :=	280	//Vertical
	aAdvSize[5]	    :=  460	//horizontal
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 002 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 002 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 002 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 002 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )

	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-12
	DEFINE MSDIALOG oDlg FROM aAdvSize[7], 0 TO aAdvSize[6], aAdvSize[5] TITLE OemToAnsi(STR0316) OF oMainWnd PIXEL //"MV_DINSSFM = N - Diferença de base de INSS"

    @ aObjSize[1][1],aObjSize[1][2] 	SAY OemToAnsi(STR0317) SIZE 440,10  FONT oFont OF oDlg PIXEL //"Em alguns casos, quando o parâmetro MV_DINSSFM está configurado com N a"
    @ aObjSize[2][1],aObjSize[2][2] 	SAY OemToAnsi(STR0318) SIZE 440,10  FONT oFont OF oDlg PIXEL //"verba de Id 1870 utilizada como contrapartida da base de INSS pode não conter"
    @ aObjSize[3][1],aObjSize[3][2] 	SAY OemToAnsi(STR0319) SIZE 440,10  FONT oFont OF oDlg PIXEL //"o mesmo valor da base de INSS, para estes casos deve-se informar uma verba"
    @ aObjSize[4][1],aObjSize[4][2] 	SAY OemToAnsi(STR0320) SIZE 440,10  FONT oFont OF oDlg PIXEL //"para gerar o valor de diferença. A verba deve estar configurada com tipo"
    @ aObjSize[5][1],aObjSize[5][2] 	SAY OemToAnsi(STR0321) SIZE 440,10  FONT oFont OF oDlg PIXEL //"4 - Base Desconto e natureza 9901. Selecione a verba no campo abaixo:"

	@ aObjSize[6][1],aObjSize[6][2] 	SAY OemToAnsi(STR0322) SIZE 050,10  FONT oFont OF oDlg PIXEL
	@ aObjSize[6][1],aObjSize[6][2]+40	MSGET oVerba VAR cPdDif   SIZE 030,10 OF oDlg F3 "VER" WHEN .T. PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24) CENTERED

	If nOpcA == 2
        Aviso( OemtoAnsi(STR0323), OemtoAnsi(STR0324),	{ STR0038 } ) //"Verba não informada" //"Execução cancelada pelo usuário."
        lRet := .F.
	Else
		If Empty(cPdDif)
			Aviso( OemtoAnsi(STR0323), OemtoAnsi(STR0325),	{ STR0038 } ) //"Verba não informada" //"A verba de diferença de Base INSS não foi informada, posteriormente observe a necessidade de reexecução desta rotina para geração dos valores. A execução não será interrompida."
		EndIf
	EndIf

Return lRet
