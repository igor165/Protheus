#INCLUDE "PROTHEUS.CH"
#DEFINE LOGPLS 'fatans2020.log'

//-----------------------------------------------------------------
/*/{Protheus.doc} PLCREDANS
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Class PLCREDANS

    Data cMesBase       as String
    Data cAnoBase       as String
    Data cMesFat        as String
    Data cAnoFat        as String
    Data cMatric        as String
    Data cLanReajus     as String
    Data cLanFaixa      as String
    Data cNivel         as String
    Data cTipPessoa     as String
    Data nVlrCheio      as Numeric
    DATA cConsidera     as String
    DATA cMesBasReaj    as String
	DATA cAnoBasReaj    as String
    Data lMais29Vidas   as Logical
    Data cTipContrato   as String
    Data nTotGerFat     as Numeric
    Data aVlrBasAut     as Array
    Data aVlrFatAut     as Array
    Data cTipCalc       as String
    
    Method New()
    Method calcDifFat()
    Method gerCredito(nVlrCred)
    Method oldFaiBDK(cMatric,cCodFaixa,nDif,nValorBase,nDifReajus,nDifFaixa)
    Method oldFaiBBU(cMatric,cCodFaixa,nDif,nValorBase,nDifReajus,nDifFaixa)
    Method ValorCheio(cMatric)
    Method Mais29Vidas()
    Method TipoContrato()
    Method CredFaltantes()
    Method mntBaseBM1()
EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
 Classe Construtora
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method New() Class PLCREDANS

    self:cMesBase   := ''
	self:cAnoBase   := ''
    self:cMesFat    := ''
	self:cAnoFat    := ''
    self:cMatric    := ''
    self:cLanReajus := ''
    self:cLanFaixa  := ''
    self:cNivel     := ''
    self:cTipPessoa :=''
    self:nVlrCheio  := 0
    self:cConsidera :='3'
    self:cMesBasReaj:= ''
	self:cAnoBasReaj:= ''
    self:lMais29Vidas:= .F.   
    self:cTipContrato:= ''
    self:nTotGerFat  := 1
    self:aVlrBasAut  := {}
    self:aVlrFatAut  := {}
    self:cTipCalc    := ''

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} calcDifFat
  
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method calcDifFat(lPeRej3,nVlrCorte) Class PLCREDANS

    Local nX         := 0
    Local aRet       := {}
    Local aVlrBase   := {}
    Local aVlrFat    := {}

    Local nValorBase := 0
    Local nValorFat  := 0
    Local nDif       := 0
    Local nDifReajus := 0
    Local nDifFaixa  := 0
    Local lProRata   :=.F.
    Local nVlrMensal := 0
    Local nVlrAntigo := 0
    
    Local nAutoReaj  := 0
    Local nAutoFaix  := 0
    Local aRetPE     := {}
    Local cCompetreaj:= ''
    Local cAliFaixa  := ''
    Local cCodFor    := ''
    Local nVlrFxAtu  := 0
    Local lCalcBaseAtu := If(self:cTipPessoa = '2',If((BQC->(FieldPos('BQC_SUSREA') ) > 0),(BQC->BQC_SUSREA=='1'),.T.),.T.)

    Default lPeRej3  := .F.
    Default nVlrCorte:= 0

    BBU->(DbSetOrder(1))
    BDK->(DbSetOrder(2))
    BA1->(DbSetOrder(2))
    BJK->(DbSetOrder(1))

    PlsPtuLog('',LOGPLS)
    PlsPtuLog('',LOGPLS)
    PlsPtuLog('-----------------------------',LOGPLS)
    PlsPtuLog('Processando familia: '+self:cMatric,LOGPLS)

    //Dados fixos para testes da rotina
    if !Empty(self:aVlrBasAut) .And. !Empty(self:aVlrFatAut)
        aVlrBase := self:aVlrBasAut
        aVlrFat  := self:aVlrFatAut
    else
        //Verifica se ja tem a base no BM1
        aVlrBase := self:mntBaseBM1()
     
        //Busca valores do mes base que nao foi faturado ainda.
        if len(aVlrBase) == 0
            aRet := PLSVLRFAM(self:cMatric,self:cAnoBase,self:cMesBase,nil,nil,.T.,nil,nil,.T.)
        endIf

        if len(aVlrBase) == 0 .And. len(aRet) > 0 
            //Verifica se tem valor a faturar.
            if aRet[1,1]
                for nX := 1 to len(aRet[1,2])
            
                    if aRet[1,2,nX,3] == '101'
                        
                        //Se o usuario for pro-rata temos que sempre pegar o valor cheio
                        if BA1->(DbSeek(xFilial('BA1')+aRet[1,2,nX,7])) .And. BA3->BA3_COBRAT == '1' .And.  Substr(Dtos(BA1->BA1_DATINC),1,6) == self:cAnoBase+self:cMesBase
                
                            lProRata:= .T.
                            if BDK->(DbSeek(xFilial("BDK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+Substr(aRet[1,2,nX,7],15,2)+aRet[1,2,nX,13]))
                                nVlrMensal := BDK->BDK_VALOR
                            elseIf BBU->(DbSeek(xFilial("BBU")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+aRet[1,2,nX,3]+aRet[1,2,nX,13]))
                                nVlrMensal := BBU->BBU_VALFAI
                            endIf

                        endIf

                        If self:cTipCalc == '2' 
                            If BDK->(DbSeek(xFilial("BDK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+Substr(aRet[1,2,nX,7],15,2)+aRet[1,2,nX,13]))
                                nVlrFxAtu := BDK->BDK_VALOR
                            Else
                                If BJK->(DbSeek(xFilial("BJK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC))
                                    cCodFor := BJK->BJK_CODFOR
                                Else
                                    cCodFor := '101'
                                Endif
            
                                If BBU->(DbSeek(xFilial("BBU")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+cCodFor+aRet[1,2,nX,13]))
                                    nVlrFxAtu := BBU->BBU_VALFAI
                                Endif    
                            EndIf
                        Endif
                    
                        Aadd(aVlrBase,{aRet[1,2,nX,7],; //Matricula
                                    Iif(!lProRata,aRet[1,2,nX,33],nVlrMensal) ,; //Valor   ..              
                                    aRet[1,2,nX,14],;  //Chave faixa
                                    aRet[1,2,nX,13],;  //Codigo da faixa
                                    StrZero(Month(BA1->BA1_DATNASC),2),; //Mes de aniversario para comparar se vem antes do reajuste
                                    nVlrFxAtu })
                    endIf
                next
            endIf

            //Verifica valor ja faturado
            if len(aRet) > 1 .And. aRet[2,1]

                for nX := 1 to len(aRet[2,2])

                    if aRet[2,2,nX,3] == '101'
                        
                        //Se o usuario for pro-rata temos que sempre pegar o valor cheio
                        if  BA1->(DbSeek(xFilial('BA1')+aRet[2,2,nX,7])) .And. BA3->BA3_COBRAT == '1' .And. Substr(Dtos(BA1->BA1_DATINC),1,6) == self:cAnoBase+self:cMesBase
                                
                            lProRata:= .T.
                            if BDK->(DbSeek(xFilial("BDK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+Substr(aRet[2,2,nX,7],15,2)+aRet[2,2,nX,13]))
                                nVlrMensal := BDK->BDK_VALOR
                            elseIf BBU->(DbSeek(xFilial("BBU")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+aRet[2,2,nX,3]+aRet[2,2,nX,13]))
                                nVlrMensal := BBU->BBU_VALFAI
                            EndIf

                        endIf

                        If self:cTipCalc = '2'
                            If BDK->(DbSeek(xFilial("BDK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+Substr(aRet[2,2,nX,7],15,2)+aRet[2,2,nX,13]))
                                nVlrFxAtu := BDK->BDK_VALOR
                            Else
                                If BJK->(DbSeek(xFilial("BJK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC))
                                    cCodFor := BJK->BJK_CODFOR
                                Else
                                    cCodFor := '101'
                                Endif
            
                                If BBU->(DbSeek(xFilial("BBU")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+cCodFor+aRet[2,2,nX,13]))
                                    nVlrFxAtu := BBU->BBU_VALFAI
                                Endif    
                            EndIf
                        Endif

                        Aadd(aVlrBase,{aRet[2,2,nX,07],;  //Matricula
                                    Iif(!lProRata,aRet[2,2,nX,02],nVlrMensal),;  //Valor                 
                                    aRet[2,2,nX,14],;  //Chave faixa
                                    aRet[2,2,nX,13],;  //Codigo da faixa
                                    StrZero(Month(BA1->BA1_DATNASC),2),; //Mes de aniversario para comparar se vem antes do reajuste
                                    nVlrFxAtu})
                    endIf
                next
            endIf      

        endIf

        //Busca valores do mes a faturar
        if len(aVlrBase) > 0 
            aRet := {}
            aRet := PLSVLRFAM(self:cMatric,self:cAnoFat,self:cMesFat,nil,nil,.T.,nil,nil,.T.)
            //Verifica se tem valor a faturar
            if aRet[1,1]
                for nX := 1 to len(aRet[1,2])
                    if aRet[1,2,nX,3] == '101'
                        Aadd(aVlrFat,{aRet[1,2,nX,07],;  //Matricula
                                    aRet[1,2,nX,02],;  //Valor    
                                    aRet[1,2,nX,31],;  //Competencia reajuste
                                    aRet[1,2,nX,33],;  //Valor antigo reajuste
                                    aRet[1,2,nX,14],;  //Chave faixa
                                    aRet[1,2,nX,13]})  //Codigo da faixa
                    endIf
                next
            endif


            // Estou pedindo para que veja se gerei os creditos nos meses anteriores, se sim os meses anteriores ja foram faturados
            // eu preciso pegar o que ja foi faturado.
            If Len(aVlrFat) = 0  .and. self:nTotGerFat > 1
                BDK->(DbSetOrder(2))
                for nX := 1 to len(aRet[2,2])
                    if aRet[2,2,nX,3] == '101'

                        if BDK->(DbSeek(xFilial("BDK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+Substr(aRet[2,2,nX,7],15,2)+aRet[2,2,nX,13]))
                            nVlrAntigo := BDK->BDK_VLRANT
                            cCompetreaj:= BDK->BDK_ANOMES
                            cAliFaixa := 'BDK'
                            
                        Else
                            If BJK->(DbSeek(xFilial("BJK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC))
                                cCodFor := BJK->BJK_CODFOR
                            Else
                                cCodFor := aRet[2,2,nX,3]
                            Endif


                            If BBU->(DbSeek(xFilial("BBU")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+cCodFor+aRet[2,2,nX,13]))
                                nVlrAntigo := BBU->BBU_VLRANT
                                cCompetreaj:= BBU->BBU_ANOMES
                                cAliFaixa := 'BBU'
                            Endif 
                        EndIf

                        Aadd(aVlrFat,{aRet[2,2,nX,07]   ,;  //Matricula
                                    aRet[2,2,nX,02]     ,;  //Valor    
                                    cCompetreaj         ,;  //Competencia reajuste
                                    nVlrAntigo          ,;  //Valor antigo reajuste
                                    cAliFaixa           ,;  //Chave faixa
                                    aRet[2,2,nX,13]})  //Codigo da faixa
                    endIf
                next

            Endif

        else
            PlsPtuLog('Nao foi possivel encontrar os valores correspodentes ao mes base. Matricula: '+self:cMatric,LOGPLS)
        endIf
    endIf

    //Compara os valores do mes base x a faturar
    for nX := 1 to len(aVlrFat)

        PlsPtuLog('-----------------------------',LOGPLS)
        PlsPtuLog('Usuário: '+ aVlrFat[nX,1],LOGPLS)

        if nPos := aScan(aVlrBase,{|x|x[1] == aVlrFat[nX,1]})

            nDifReajus  := 0
            nDifFaixa   := 0
            nAuxReajus  := 0
            nValorBase  := aVlrBase[nPos,2]
            cFaixaBase  := aVlrBase[nPos,4]
            cAnivers    := aVlrBase[nPos,5]
            
            cMatric     := aVlrFat[nX,1]
            nValorFat   := aVlrFat[nX,2]
            cAnoMesReaj := self:cAnoBasReaj+self:cMesBasReaj
            nVlrFaiAtua := aVlrFat[nX,4]
            cAliFaixa   := aVlrFat[nX,5]
            nDif        := nValorFat - nValorBase           
            
            PlsPtuLog('Valor Base: '        + cValtoChar(nValorBase),LOGPLS)
            PlsPtuLog('Valor Fatura  Atual: '+ cValtoChar(nValorFat) ,LOGPLS)

            if lPeRej3

                aRetPE := Execblock("PANSREJ3",.F.,.F.,{aVlrBase,aVlrFat})
                if ValType(aRetPE) == "A" .and. Len(aRetPE) > 0
                    nDifReajus := aRetPE[1]
                    nDifFaixa  := aRetPE[2]
                endIf

                PlsPtuLog('Valor Credito Reajuste via PE:  '+ cValtoChar(nDifReajus),LOGPLS)
                PlsPtuLog('Valor Credito Faixa   via PE :  '+ cValtoChar(nDifFaixa ),LOGPLS)

                 //Cadastra o Credito referente ao reajuste
                if nDifReajus > 0 .And.  nDifFaixa > nVlrCorte .And. self:cConsidera <> "1"
                    self:gerCredito("R",aClone(aVlrFat[nX]),nDifReajus)
                    nAutoReaj += nDifReajus
                endIf

                //Cadastra o Credito referente a troca de faixa
                if nDifFaixa > 0  .And.  nDifFaixa > nVlrCorte .And.  self:cConsidera <> "2"
                    self:gerCredito("F",aClone(aVlrFat[nX]),nDifFaixa)
                    nAutoFaix += nDifFaixa
                endif
            
            
            elseIf (nDif > 0 .and. nValorBase > 0) .or. self:cTipCalc = '2' 

                 If self:cTipCalc = '2' 
                    If lCalcBaseAtu .and. self:cAnoBasReaj < "2021"
                        nDifReajus := aVlrFat[nX,2] - aVlrFat[nX,4]
                    Endif    
                    nDifFaixa  := aVlrFat[nX,2] - aVlrBase[nPos,6]   

                 ElseIf self:cTipCalc <> '2'
                
                
                    //Verifica se tem reajuste entre data base de faixa etária e reajuste,
                    //neste cenário devo considerar somente a diferenca do valor da faixa etaria
                    if !Empty(cAnoMesReaj) .And. (cAnoMesReaj >= self:cAnoBase+self:cMesBase) .And. (cAnoMesReaj <  self:cAnoBasReaj+self:cMesBasReaj)

                        if self:cAnoBasReaj+cAnivers < cAnoMesReaj
                            nDifFaixa  := nVlrFaiAtua - nValorBase
                            nDifReajus := 0 // O desconto de Reajuste deve ser ignorado pois foi realizado dentro do periodo
                        
                        else
                            if cAliFaixa == 'BDK'
                                self:oldFaiBDK(cMatric,cFaixaBase ,nDif,nValorBase,@nDifReajus,@nDifFaixa,.T.)
                            elseIf cAliFaixa == 'BBU'
                                self:oldFaiBBU(cMatric,cFaixaBase ,nDif,nValorBase,@nDifReajus,@nDifFaixa,.T.)
                            endIf

                        endIf

                    //Verifica se tem reajuste posterior a data base de reajuste
                    //neste cenário, devo dar o desconto de faixa e reajuste
                    elseIf !Empty(cAnoMesReaj) .And. cAnoMesReaj >= self:cAnoBasReaj+self:cMesBasReaj

                        if self:cAnoBasReaj+cAnivers < cAnoMesReaj
                            nDifFaixa  := nVlrFaiAtua - nValorBase
                            nDifReajus := nDif - nDifFaixa
                        else
                            if cAliFaixa == 'BDK'
                                self:oldFaiBDK(cMatric,cFaixaBase ,nDif,nValorBase,@nDifReajus,@nDifFaixa,.F.)
                            elseIf cAliFaixa == 'BBU'
                                self:oldFaiBBU(cMatric,cFaixaBase ,nDif,nValorBase,@nDifReajus,@nDifFaixa,.F.)
                            endIf
                        endIf

                    //Aqui posso assumir que toda a diferenca e faixa etaria   
                    else
                        nDifFaixa := nDif
                    endIf
                Endif
                PlsPtuLog('Valor Credito Reajuste:  '+ cValtoChar(nDifReajus),LOGPLS)
                PlsPtuLog('Valor Credito Faixa   :  '+ cValtoChar(nDifFaixa ),LOGPLS)

                //Cadastra o Credito referente ao reajuste.
                if nDifReajus > 0 .And. nDifReajus > nVlrCorte .And. self:cConsidera <> "1"
                    self:gerCredito("R",aClone(aVlrFat[nX]),nDifReajus)
                    nAutoReaj += nDifReajus
                endIf

                //Cadastra o Credito referente a troca de faixa
                if nDifFaixa > 0 .And.  nDifFaixa > nVlrCorte .And. self:cConsidera <> "2"
                    self:gerCredito("F",aClone(aVlrFat[nX]),nDifFaixa)
                    nAutoFaix += nDifFaixa
                endif
            else
                 PlsPtuLog('Nao houve alteracao de valor, nao e necessario gerar o credito',LOGPLS)
            endIf
        endIf    
    next

Return {nAutoReaj,nAutoFaix}

//-----------------------------------------------------------------
/*/{Protheus.doc} gerCredito
 
@author renan.almeida
@since 12/02/2019
@version 1.0.
/*/
//-----------------------------------------------------------------
Method gerCredito(cTipo,aAux,nVlrCred) Class PLCREDANS

    Local cNumBSQ := ''
    Local cSql    := ''

    cSql += " SELECT BSQ_CODINT FROM " + RetSqlName("BSQ")
    cSql += " WHERE BSQ_FILIAL = '"+xFilial("BSQ")+"' "
    cSql += " AND BSQ_CODINT = '"+BA3->BA3_CODINT+"' "
    cSql += " AND BSQ_CODEMP = '"+BA3->BA3_CODEMP+"' "
    cSql += " AND BSQ_CONEMP = '"+BA3->BA3_CONEMP+"' "
    cSql += " AND BSQ_VERCON = '"+BA3->BA3_VERCON+"' "
    cSql += " AND BSQ_ANO =    '"+self:cAnoFat+"' "
    cSql += " AND BSQ_MES =    '"+self:cMesFat+"' "
    cSql += " AND BSQ_USUARI = '"+aAux[1]+"' "
    cSql += " AND BSQ_CODLAN = '"+iif(cTipo=="R",self:cLanReajus,self:cLanFaixa)+"' "
    cSql += " AND D_E_L_E_T_ = ' ' "

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBSQ",.F.,.T.)

    if TRBBSQ->(Eof())

        cNumBSQ := PLSA625Cd("BSQ_CODSEQ","BSQ",1,"D_E_L_E_T_"," ")

        BSQ->(recLock("BSQ",.T.))
        BSQ->BSQ_FILIAL := xFilial('BSQ')
        BSQ->BSQ_CODSEQ := cNumBSQ
        BSQ->BSQ_USUARI := aAux[1]
        BSQ->BSQ_CODINT := BA3->BA3_CODINT
        BSQ->BSQ_CODEMP := BA3->BA3_CODEMP
        BSQ->BSQ_CONEMP := BA3->BA3_CONEMP
        BSQ->BSQ_VERCON := BA3->BA3_VERCON
        BSQ->BSQ_SUBCON := BA3->BA3_SUBCON
        BSQ->BSQ_VERSUB := BA3->BA3_VERSUB
        BSQ->BSQ_MATRIC := BA3->BA3_MATRIC
        BSQ->BSQ_ANO    := self:cAnoFat
        BSQ->BSQ_MES    := self:cMesFat
        BSQ->BSQ_CODLAN := iif(cTipo=="R",self:cLanReajus,self:cLanFaixa)
        BSQ->BSQ_VALOR  := nVlrCred
        BSQ->BSQ_TIPO   := '2'
        BSQ->BSQ_AUTOMA := '1'
        BSQ->BSQ_COBNIV := self:cNivel
        BSQ->BSQ_ATOCOO := '0'
        BSQ->BSQ_TIPPE  := self:cTipPessoa 
        BSQ->BSQ_TIPEMP := BG9->BG9_TIPO
        
        BSQ->(msUnLock())
        PlsPtuLog('Credito '+cNumBSQ+ ' gerado com sucesso.',LOGPLS)
    else
        PlsPtuLog('Nao foi possivel criar o Credito, pois o mesmo ja existe na BSQ para o Ano/Mes selecionados: '+BSQ->BSQ_CODSEQ,LOGPLS)
    endIf

    TRBBSQ->(dbCloseArea())

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} oldFaiBDK
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method oldFaiBDK(cMatric,cCodFaixa,nDif,nValorBase,nDifReajus,nDifFaixa,lIgnReajus) Class PLCREDANS

    Local cSql := ''
    Default lIgnReajus := .F.

    cSql := " SELECT BDQ_DATDE, BDQ_DATATE, BDK_VALOR, BDQ_PERCEN, BDQ_VALOR, MAX(BDQ.BDQ_DATATE) FROM " + RetSqlName("BDK") +' BDK' 
    
    cSql += " LEFT JOIN "+ RetSqlName("BDQ")+" BDQ  ON  BDQ.BDQ_FILIAL ='"+xFilial("BDQ")+"' AND BDQ.BDQ_CODINT = BDK.BDK_CODINT   AND BDQ.BDQ_CODEMP = BDK.BDK_CODEMP  AND BDQ.BDQ_MATRIC = BDK.BDK_MATRIC   AND BDQ.BDQ_CODFAI = BDK.BDK_CODFAI   AND BDQ.BDQ_TIPREG = BDK.BDK_TIPREG AND  (BDQ.BDQ_DATATE > '20191231' OR BDQ.BDQ_DATATE = ' ')  AND BDQ.D_E_L_E_T_ = ' '
    cSql += " WHERE BDK_FILIAL = '"+xFilial("BDK")+"' "
    cSql += " AND BDK_CODINT = '"+Substr(cMatric,1,4)+"' "
    cSql += " AND BDK_CODEMP = '"+Substr(cMatric,5,4)+"' "
    cSql += " AND BDK_MATRIC = '"+Substr(cMatric,9,6)+"' "
    cSql += " AND BDK_TIPREG = '"+Substr(cMatric,15,2)+"' ""
    cSql += " AND BDK_CODFAI = '"+cCodFaixa+"' ""
    cSql += " AND BDK.D_E_L_E_T_ = ' ' "

    cSql += "  GROUP by BDQ_DATDE, BDQ_DATATE, BDK_VALOR, BDQ_PERCEN, BDQ_VALOR "
    cSql += "  ORDER BY BDQ_DATATE DESC "
                            
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBDK",.F.,.T.)
   

    If TRBBDK->BDQ_PERCEN > 0
        nDifReajus := Round(((TRBBDK->BDK_VALOR-(TRBBDK->BDK_VALOR*TRBBDK->BDQ_PERCEN)/100) - nValorBase),2)
    Else
        nDifReajus := (TRBBDK->BDK_VALOR - TRBBDK->BDQ_VALOR ) - nValorBase
    Endif
    nDifFaixa  := nDif - nDifReajus
   
    TRBBDK->(dbCloseArea())

    //Preciso zerar o valor do reajuste pois ele foi realizado antes do mes base do reajuste
    if lIgnReajus
        nDifReajus := 0
    endif

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} oldFaiBBU
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method oldFaiBBU(cMatric,cCodFaixa,nDif,nValorBase,nDifReajus,nDifFaixa,lIgnReajus) Class PLCREDANS

    Local cSql := ''
    Default lIgnReajus := .F.

    cSql := " SELECT BFY_DATDE,BFY_DATATE,BBU_VALFAI,BFY_PERCEN,BFY_VALOR,MAX(BFY_DATATE) FROM " + RetSqlName("BBU") +' BBU' 
  
    cSql += " LEFT JOIN "+RetSqlName("BFY")+" BFY ON  BFY.BFY_FILIAL = '"+xFilial("BFY")+"'  AND BFY.BFY_CODOPE = BBU.BBU_CODOPE    AND BFY.BFY_CODEMP = BBU.BBU_CODEMP  AND BFY.BFY_MATRIC = BBU.BBU_MATRIC    AND BFY.BFY_CODFOR = BBU.BBU_CODFOR  AND BFY.BFY_CODFAI = BBU.BBU_CODFAI AND BFY.D_E_L_E_T_ = ' '

    cSql += " WHERE BBU_FILIAL   = '"+xFilial("BBU")+"' "
    cSql += " AND BBU.BBU_CODOPE = '"+Substr(cMatric,1,4)+"' "
    cSql += " AND BBU.BBU_CODEMP = '"+Substr(cMatric,5,4)+"' "
    cSql += " AND BBU.BBU_MATRIC = '"+Substr(cMatric,9,6)+"' "
    cSql += " AND BBU.BBU_CODFAI = '"+cCodFaixa+"' ""
    cSql += " AND BBU.D_E_L_E_T_ = ' ' "

    cSql += "  GROUP BY BFY_DATDE, BFY_DATATE, BBU_VALFAI, BFY_PERCEN, BFY_VALOR "
    cSql += "  ORDER BY BFY_DATATE DESC "

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBBBU",.F.,.T.)
    
    
    if !TRBBBU->(Eof())
        If TRBBBU->BFY_PERCEN > 0
            nDifReajus := Round(((TRBBBU->BBU_VALFAI-(TRBBBU->BBU_VALFAI*TRBBBU->BFY_PERCEN)/100) - nValorBase),2)
        Else
            nDifReajus := (TRBBBU->BBU_VALFAI - TRBBBU->BFY_VALOR ) - nValorBase
        Endif
        nDifFaixa  := nDif - nDifReajus
    endIf
    
    TRBBBU->(dbCloseArea())

    //Preciso zerar o valor do reajuste pois ele foi realizado antes do mes base do reajuste.
    if lIgnReajus
        nDifReajus := 0
    endif

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} Mais29Vidas
//Verifica se o contrato a mais de 29 vidas
 
@author Robson Nayland
@since 01/09/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Method Mais29Vidas(lPeREj2) Class PLCREDANS

    Local cAliasQry := ''
    Local aRetUsr   := {}
    Local nTotVidas := 0
    Local aNewDtRea := {}
    Local lSUSREA       := BQC->(FieldPos('BQC_SUSREA') ) > 0

    Default lPeREj2 := .F.
    
    If lPeREj2
	    aNewDtRea := Execblock("PANSREJ2",.F.,.F.,{self:cMesBasReaj,self:cAnoBasReaj})
        If ValType(aNewDtRea) == "A" .and. Len(aNewDtRea) > 0
            self:cMesBasReaj := aNewDtRea[1]
	        self:cAnoBasReaj := aNewDtRea[2]
        Endif
        Return()
	Endif

    cAliasQry := GetNextAlias()

    If self:cTipPessoa == '1' //Pessoa Fisica.

            BeginSql Alias cAliasQry

            SELECT BG9_FILIAL,BG9_CODINT,BG9_CODIGO,BA3_CODINT,BA3_CODEMP,BA3_CONEMP,BA3_VERCON,BA3_SUBCON,BA3_VERSUB,BA3_NUMCON,BA3_MATRIC,BA3_TIPOUS,BG9_TIPO
            FROM       %table:BG9%  BG9 ,  %table:BA3%  BA3
            WHERE

                BA3.BA3_FILIAL          =  BG9.BG9_FILIAL
                AND BA3.BA3_CODINT      =  BG9.BG9_CODINT
                AND BA3.BA3_CODEMP      =  BG9.BG9_CODIGO
                AND BA3.BA3_MATRIC      =  %exp:BA3->BA3_MATRIC% 
                AND BA3.BA3_DATBLO      =  %exp:' '%
                AND BG9.BG9_FILIAL      =  %xfilial:BG9% 
                AND BG9.BG9_CODINT      =  %exp:BA3->BA3_CODINT% 
                AND BG9.BG9_CODIGO      =  %exp:BA3->BA3_CODEMP% 
                AND BG9.%notDel%
                AND BA3.%notDel%
        EndSql

    Else

        BeginSql Alias cAliasQry

            SELECT BG9_FILIAL,BG9_CODINT,BG9_CODIGO,BA3_CODINT,BA3_CODEMP,BA3_CONEMP,BA3_VERCON,BA3_SUBCON,BA3_VERSUB,BA3_NUMCON,BA3_MATRIC,BA3_TIPOUS,BG9_TIPO
            FROM       %table:BG9%  BG9 ,  %table:BA3%  BA3
            WHERE

                BA3.BA3_FILIAL          =  BG9.BG9_FILIAL
                AND BA3.BA3_CODINT      =  BG9.BG9_CODINT
                AND BA3.BA3_CODEMP      =  BG9.BG9_CODIGO
                AND BA3.BA3_DATBLO      =  %exp:' '%
                AND BG9.BG9_FILIAL      =  %xfilial:BG9% 
                AND BG9.BG9_CODINT      =  %exp:BA3->BA3_CODINT% 
                AND BG9.BG9_CODIGO      =  %exp:BA3->BA3_CODEMP% 
                AND BG9.%notDel%
                AND BA3.%notDel%
        EndSql
    Endif    
    
    While !(cAliasQry)->( Eof() )
        aRetUsr   := PLSLOADUSR((cAliasQry)->BA3_CODINT,(cAliasQry)->BA3_CODEMP,(cAliasQry)->BA3_MATRIC,self:cAnoBase ,self:cMesBase)
        nTotVidas += Len(aRetUsr)
        If nTotVidas > 29
            exit
        Endif
        (cAliasQry)->( dbSkip() )
    Enddo
   
    (cAliasQry)->(DbCloseArea())


    If self:cTipContrato == '1'  // familiar/Individual 

        self:cMesBasReaj := '01'
        self:cAnoBasReaj := '2021'

    ElseIf nTotVidas > 29 .and. self:cTipContrato  == '2' //Tipo Adesão mais de 29 vidas a data referencia vai para 01/2020

        self:cMesBasReaj := self:cMesBase
        self:cAnoBasReaj := self:cAnoBase

    ElseIf nTotVidas > 29 .and. self:cTipContrato  == '3' //Empresarial mais de 29 vidas não retroage reajuste 

        self:cMesBasReaj := '01'
        self:cAnoBasReaj := '2021'   
    EndIf
  
Return



//-----------------------------------------------------------------
/*/{Protheus.doc} TipoContrato
// Veirifica o tipo de contrato.

1 - Individual/Familiar
2 - Coletivo por Adesao
3 - Coletivo Empresarial

@author Robson Nayland
@since 01/09/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Method TipoContrato() Class PLCREDANS
  
    self:cTipContrato   := Alltrim(BT5->BT5_TIPCON)

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} CredFaltantes
//Verifica se ha creditos anteriores, caso não existe o sistema devera gerar creditos dos meses faltantes 1 a 1
 
@author Robson Nayland
@since 01/09/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Method CredFaltantes() Class PLCREDANS
    Local cAliasQry  := GetNextAlias()

	//Verificando a quantidade de registro para o processar o IndRegua
	BeginSql Alias cAliasQry
	
		SELECT  MAX(BSQ_ANO) AS ANO, MAX(BSQ_MES) AS MES
		FROM       %table:BSQ%  BSQ
		WHERE
			BSQ_FILIAL       =  %xfilial:BSQ% 
			AND BSQ_CODINT   =  %exp:BA3->BA3_CODINT% 
			AND BSQ_CODEMP   =  %exp:BA3->BA3_CODEMP% 
			AND BSQ_CONEMP   =  %exp:BA3->BA3_CONEMP% 
			AND BSQ_VERCON   =  %exp:BA3->BA3_VERCON% 
	        AND BSQ_ANO      =  %exp:self:cAnoFat%
            AND BSQ_MATRIC   =  %exp:BA3->BA3_MATRIC% 
            AND (BSQ_CODLAN  =  %exp:self:cLanFaixa%
            OR  BSQ_CODLAN   =  %exp:self:cLanReajus%)
  			AND BSQ.%notDel%
	EndSql

    If  Val((cAliasQry)->(MES)) == 0 
        self:nTotGerFat :=  If((Val(self:cMesFat) - 8) > 0,(Val(self:cMesFat) - 8),1)
        self:cMesFat    := "09"
     ElseIf  Val((cAliasQry)->(MES)) > 0 .and. (Val(self:cMesFat) - Val((cAliasQry)->(MES))) >1    //Existe Mais de um mes para gerar credito
        self:nTotGerFat :=  Val(self:cMesFat) - Val((cAliasQry)->(MES))
        self:cMesFat    :=  StrZero((Val((cAliasQry)->(MES))+1),2)
    EndIf
    (cAliasQry)->(DbCloseArea())


Return


//-----------------------------------------------------------------
/*/{Protheus.doc} mntBaseBM1
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method mntBaseBM1() Class PLCREDANS

    Local nVlrMensal := 0
    Local aVlrBase   := {}
    Local cSql       := ''
    Local lProRata   := .F.
    Local nVlrFxAtu  := 0

    cSql += " SELECT BM1_MATUSU, BM1_NIVFAI, BM1_CODFAI, BM1_VALOR, BA1_DATINC, BA1_DATNAS, BA1_TIPREG FROM " + RetSqlName("BM1") + " BM1 "
    cSql += " INNER JOIN "+RetSqlName("BA1")+" BA1 "
    cSql += " 	ON BA1_FILIAL = '"+xFilial("BA1")+"' "
    cSql += " 	AND BM1_CODINT = BA1_CODINT "
    cSql += " 	AND BM1_CODEMP = BA1_CODEMP "
    cSql += " 	AND BM1_MATRIC = BA1_MATRIC "
    cSql += " 	AND BM1_TIPREG = BA1_TIPREG "
    cSql += " 	AND BM1_DIGITO = BA1_DIGITO "
    cSql += " 	AND BA1.D_E_L_E_T_ = ' '  "

    cSql += " WHERE BM1_FILIAL = '"+xFilial("BM1")+"' "
    cSql += " AND BM1_CODINT = '"+Substr(self:cMatric,1,4)+"'"
    cSql += " AND BM1_CODEMP = '"+Substr(self:cMatric,5,4)+"'"
    cSql += " AND BM1_MATRIC = '"+Substr(self:cMatric,9,6)+"'"
    cSql += " AND BM1_ANO = '"+self:cAnoBase+"'"
    cSql += " AND BM1_MES = '"+self:cMesBase+"'"
    cSql += " AND BM1_CODTIP = '101'"
    cSql += " AND BM1.D_E_L_E_T_ = ' ' "

    cSql += " ORDER BY BM1_MATUSU, BM1_NIVFAI,  BM1_CODFAI, BM1_VALOR, BA1_DATINC,  BA1_DATNAS,    BA1_TIPREG "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBBM1",.T.,.F.)
    while ! TRBBM1->(eof())

        //Se o usuario for pro-rata temos que sempre pegar o valor cheio
        if BA3->BA3_COBRAT == '1' .And.  Substr(TRBBM1->BA1_DATINC,1,6) == self:cAnoBase+self:cMesBase
                    
            lProRata:= .T.
            if BDK->(DbSeek(xFilial("BDK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+TRBBM1->BA1_TIPREG+TRBBM1->BM1_CODFAI))
                nVlrMensal := BDK->BDK_VALOR
            elseIf BBU->(DbSeek(xFilial("BBU")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+'101'+TRBBM1->BM1_CODFAI))
                nVlrMensal := BBU->BBU_VALFAI
            endIf

        endIf

        If self:cTipCalc = '2'

            if BDK->(DbSeek(xFilial("BDK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+TRBBM1->BA1_TIPREG+TRBBM1->BM1_CODFAI))
                nVlrFxAtu := BDK->BDK_VALOR
            Else
                If BJK->(DbSeek(xFilial("BJK")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC))
                    cCodFor := BJK->BJK_CODFOR
                Else
                    cCodFor := '101'
                Endif
            
                If BBU->(DbSeek(xFilial("BBU")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC+cCodFor+TRBBM1->BM1_CODFAI))
                    nVlrFxAtu := BBU->BBU_VALFAI
                Endif    
            EndIf
        Endif


        Aadd(aVlrBase,{TRBBM1->BM1_MATUSU,;  //Matricula
                    Iif(!lProRata,TRBBM1->BM1_VALOR,nVlrMensal),;  //Valor                 
                    TRBBM1->BM1_NIVFAI,;  //Chave faixa
                    TRBBM1->BM1_CODFAI,;  //Codigo da faixa
                    StrZero(Month(Stod(TRBBM1->BA1_DATNASC)),2),; //Mes de aniversario para comparar se vem antes do reajuste
                    nVlrFxAtu}) //Valor da Faixa co reajuste
        
        TRBBM1->(DbSkip())
    endDo
    TRBBM1->( dbCloseArea())

Return aVlrBase
