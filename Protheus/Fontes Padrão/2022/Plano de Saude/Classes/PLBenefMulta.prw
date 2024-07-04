#Include "PROTHEUS.CH"
#Include "MSOBJECT.CH"
#Include "PLBENEFMULTA.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLBenefMulta
Classe para calcular a multa rescisoria do beneficiário ao cancelar
o contrato pela de acorco com a RN 412

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/09/2022
/*/
//------------------------------------------------------------------- 
Class PLBenefMulta

    Private Data aIdBeneficiarios As Array
    Private Data lCalculaMulta As Boolean
    Private Data dDataBloqueio As Date
    Private Data oDetalheMulta As Object
    Private Data cMessageError As String
    Private Data lError As Boolean

    Public Method New() CONSTRUCTOR
    Public Method SetBeneficiarios(aIdBeneficiarios, dDataBloqueio)
    Public Method SetFamilia(cIdFamilia, dDataBloqueio)
    Public Method Calcular(cMotivoBloqueio, cTipoBloqueio)
    Public Method Gravar(aBeneficiarios, cAnoGravacao, cMesGravacao)
    Public Method CheckDadosCobranca(cOperadora, cEmpresa, cMatricula, cTipRegistro, cDigito)
    Public Method GetDetalhe()
    Public Method GetJsonDetalhe()
    Public Method GetHtmlMulta(lDisplayBenef)
    Public Method GetHtmlCobranca(lMsgCancel)
    Public Method GetMessageError()

    Private Method CheckBaseFields()
    Private Method GetBeneficariosFamilia(cOperadora, cEmpresa, cMatricula)
    Private Method GeraTituloMulta(aCobranca, cAnoGravacao, cMesGravacao)
    Private Method CheckLancFatMulta()
    Private Method DadosContrato(cOperadora, cEmpresa, cMatricula)
    Private Method VlrMensalidade(cAnoCalculo, cMesCalculo, nQtdMeses)
    Private Method CheckMotivoBloqueio(cMotivo, cTipo)
    Private Method SetMessageError(cMessage)
    Private Method GetQtdBenFamilia()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PLBenefMulta

    Self:aIdBeneficiarios := {}
    Self:lCalculaMulta := .T.
    Self:dDataBloqueio := dDataBase
    Self:oDetalheMulta := JsonObject():New()
    Self:cMessageError := ""
    Self:lError := .F.

    Self:CheckBaseFields()

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckBaseFields
Verifica se o dicionário de dados possui alguma inconsistência para 
realizar o processo de calculo da multa rescisória

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method CheckBaseFields() Class PLBenefMulta

    Local lRetorno := .T.

    If !PlsAliasExi("BWH") .Or. BA3->(FieldPos("BA3_CODFID")) == 0

        Self:SetMessageError(STR0001) // "Inconsistência no dicionário de dados, portanto não será possivel realizar o calculo da multa rescisória."
        lRetorno := .F.

    EndIf

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBeneficiarios
Adiciona o(s) beneficiário(s) para calculo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method SetBeneficiarios(aIdBeneficiarios, dDataBloqueio) Class PLBenefMulta
    
    Local nX := 0
    Local lRetorno := .T.
    Local cOperadora := ""
    Local cEmpresa := ""
    Local cMatricula := ""

    Default aIdBeneficiarios := {}
    Default dDataBloqueio := dDataBase
    
    If !Self:lError

        If Len(aIdBeneficiarios) > 0

            cOperadora := Substr(aIdBeneficiarios[1], 1, 4)
            cEmpresa := Substr(aIdBeneficiarios[1], 5, 4)
            cMatricula := Substr(aIdBeneficiarios[1], 9, 6)

            If Len(aIdBeneficiarios) > 1
                For nX := 2 To Len(aIdBeneficiarios)

                    If Substr(aIdBeneficiarios[nX], 1, 4) <> cOperadora .Or. Substr(aIdBeneficiarios[nX], 5, 4) <> cEmpresa .Or. Substr(aIdBeneficiarios[nX], 9, 6) <> cMatricula
                        Self:SetMessageError(STR0002) // "Foi informado beneficiários de famílias diferentes."
                        lRetorno := .F.
                        Exit
                    EndIf
               
                Next nX
            EndIf

            If lRetorno
                Self:aIdBeneficiarios := aIdBeneficiarios
                Self:dDataBloqueio := dDataBloqueio

                Self:lCalculaMulta := Self:DadosContrato(cOperadora, cEmpresa, cMatricula)
                lRetorno := Self:lCalculaMulta
            EndIf
        Else
            Self:SetMessageError(STR0003) // "Não foi informado nenhum beneficiário para calculo da multa rescisória."
            lRetorno := .F.
        EndIf
    Else
        lRetorno := .F.    
    EndIf 
    
Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} SetFamilia
Adiciona o(s) beneficiário(s) da familia para calculo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method SetFamilia(cIdFamilia, dDataBloqueio) Class PLBenefMulta
    
    Local lRetorno := .T.
    Local cOperadora := ""
    Local cEmpresa := ""
    Local cMatricula := ""

    Default cIdFamilia := ""
    Default dDataBloqueio := dDataBase
    
    If !Self:lError

        If !Empty(cIdFamilia)

            cOperadora := Substr(cIdFamilia, 1, 4)
            cEmpresa := Substr(cIdFamilia, 5, 4)
            cMatricula := Substr(cIdFamilia, 9, 6)

            Self:dDataBloqueio := dDataBloqueio

            lRetorno := Self:GetBeneficariosFamilia(cOperadora, cEmpresa, cMatricula)

            If lRetorno
                Self:lCalculaMulta := Self:DadosContrato(cOperadora, cEmpresa, cMatricula)
                lRetorno := Self:lCalculaMulta
            EndIf
        Else
            Self:SetMessageError(STR0004) // "Não foi informado nenhuma família para calculo da multa rescisória."
            lRetorno := .F.
        EndIf
    Else
        lRetorno := .F.    
    EndIf 
    
Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetBeneficariosFamilia
Busca os beneficiários da familia para ser utilizado no calculo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 12/09/2022
/*/
//------------------------------------------------------------------- 
Method GetBeneficariosFamilia(cOperadora, cEmpresa, cMatricula) Class PLBenefMulta

    Local lRetorno := .F.
    Local cAliasTemp := GetNextAlias()

    Default cOperadora := ""
    Default cEmpresa := ""
    Default cMatricula := ""

    BeginSQL Alias cAliasTemp

        SELECT BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_DIGITO
            FROM %Table:BA1% BA1
            WHERE BA1.BA1_FILIAL = %XFilial:BA1% 
                AND BA1.BA1_CODINT = %Exp:cOperadora%
                AND BA1.BA1_CODEMP = %Exp:cEmpresa%
                AND BA1.BA1_MATRIC = %Exp:cMatricula%
                AND BA1.BA1_MOTBLO = ' '
                AND BA1.%notDel%

    EndSQL

    If !(cAliasTemp)->(EoF())
        While !(cAliasTemp)->(EoF())

            aAdd(Self:aIdBeneficiarios, (cAliasTemp)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)) 

            lRetorno := .T.
            (cAliasTemp)->(DbSkip())
        EndDo
    Else
        Self:SetMessageError(STR0005) // "Não foi encontrado nenhum beneficiário ativo para a família informada."
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} DadosContrato
Busca os dados do contrato do beneficiário (Familia e Fidelidade) para
auxiliar no processo do calculo da multa

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method DadosContrato(cOperadora, cEmpresa, cMatricula) Class PLBenefMulta

    Local lRetorno := .F.
    Local cAliasTemp := GetNextAlias()

    BeginSQL Alias cAliasTemp

        SELECT BWH.BWH_PERCM, BWH.BWH_QTDMES, BWH.BWH_COBRAT, BWH.BWH_MODCAL, BWH.BWH_FAIXA, BWH.BWH_DIAVEN,
               BA3.BA3_CODINT, BA3.BA3_CODEMP, BA3.BA3_MATRIC, BA3.BA3_CODFID, BA3.BA3_DATBAS,
               BA3.BA3_CONEMP, BA3.BA3_VERCON, BA3.BA3_SUBCON, BA3.BA3_VERCON, BA3.BA3_MATRIC,
               BA3.BA3_CODPLA, BA3.BA3_VERSAO, BI3_DESCRI 

            FROM %Table:BA3% BA3
            
            INNER JOIN %Table:BWH% BWH
                 ON BWH.BWH_FILIAL = %XFilial:BWH% 
                AND BWH.BWH_CODOP = BA3.BA3_CODINT
                AND BWH.BWH_COD = BA3.BA3_CODFID
                AND BWH.%notDel%
            
            INNER JOIN %Table:BI3% BI3
                 ON BI3.BI3_FILIAL = %XFilial:BI3% 
                AND BI3.BI3_CODINT = BA3.BA3_CODINT
                AND BI3.BI3_CODIGO = BA3.BA3_CODPLA
                AND BI3.BI3_VERSAO = BA3.BA3_VERSAO
                AND BI3.%notDel%

            WHERE BA3.BA3_FILIAL = %XFilial:BA3% 
                AND BA3.BA3_CODINT = %Exp:cOperadora%
                AND BA3.BA3_CODEMP = %Exp:cEmpresa%
                AND BA3.BA3_MATRIC = %Exp:cMatricula%
                AND BA3.%notDel%

    EndSQL

    If !(cAliasTemp)->(EoF())

        Self:oDetalheMulta["operadora"] := (cAliasTemp)->BA3_CODINT
        Self:oDetalheMulta["empresa"] := (cAliasTemp)->BA3_CODEMP
        Self:oDetalheMulta["contrato"] := (cAliasTemp)->BA3_CONEMP
        Self:oDetalheMulta["versaoContrato"] := (cAliasTemp)->BA3_VERCON
        Self:oDetalheMulta["subcontrato"] := (cAliasTemp)->BA3_SUBCON
        Self:oDetalheMulta["versaoSubcontrato"] := (cAliasTemp)->BA3_VERCON
        Self:oDetalheMulta["matricula"] := (cAliasTemp)->BA3_MATRIC
        Self:oDetalheMulta["idFamilia"] := (cAliasTemp)->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
        Self:oDetalheMulta["produto"] := (cAliasTemp)->BA3_CODPLA
        Self:oDetalheMulta["descricaoProduto"] := Alltrim((cAliasTemp)->(BI3_DESCRI))                
        Self:oDetalheMulta["dataInclusao"] := (cAliasTemp)->BA3_DATBAS
        Self:oDetalheMulta["dataBloqueio"] := DToS(Self:dDataBloqueio)
        Self:oDetalheMulta["valorTotalMulta"] := 0
        Self:oDetalheMulta["beneficiarios"] := {}
        Self:oDetalheMulta["cobranca"] := JsonObject():New()
        Self:oDetalheMulta["cobranca"]["diasVencimento"] := (cAliasTemp)->BWH_DIAVEN

        Self:oDetalheMulta["fidelidade"] := JsonObject():New()
        Self:oDetalheMulta["fidelidade"]["codigo"] := (cAliasTemp)->BA3_CODFID
        Self:oDetalheMulta["fidelidade"]["percentualMulta"] := (cAliasTemp)->BWH_PERCM
        Self:oDetalheMulta["fidelidade"]["quantidadeMeses"] := (cAliasTemp)->BWH_QTDMES
        Self:oDetalheMulta["fidelidade"]["consideraProRata"] := (cAliasTemp)->BWH_COBRAT == "1" // 0 = Não; 1 = Sim
        Self:oDetalheMulta["fidelidade"]["modoCalculo"] := (cAliasTemp)->BWH_MODCAL // 1 = Familiar; 2 = Indivual
        Self:oDetalheMulta["fidelidade"]["consideraFaixa"] := (cAliasTemp)->BWH_FAIXA == "1" // 0 = Não; 1 = Sim
        Self:oDetalheMulta["fidelidade"]["dataFinal"] := DToS(MonthSum(SToD((cAliasTemp)->BA3_DATBAS), (cAliasTemp)->BWH_QTDMES))

        lRetorno := .T.
    Else
        Self:SetMessageError(STR0006) // "Não existe multa rescisória para a familía informada."
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} Calcular
Realiza o calcula da multa rescisoria do(s) beneficiário(s)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method Calcular(cMotivoBloqueio, cTipoBloqueio) Class PLBenefMulta
    
    Local nValorMulta := 0
    Local nValorMensalidade := 0
    Local nQtdMeses := 0
    Local nX := 0
    Local cAnoCalculo := ""
    Local cMesCalculo := ""
    Local dDtInicial := CToD(" / / ") 
    Local dDtFinal := CToD(" / / ") 
    Local nQtdBenefFamilia := 0
    
    Default cMotivoBloqueio := ""
    Default cTipoBloqueio := ""
    
    If !Self:lError 

        // Verifica modo de calculo
        If Self:lCalculaMulta
            nQtdBenefFamilia := Self:GetQtdBenFamilia()

            If !(Len(Self:aIdBeneficiarios) == nQtdBenefFamilia .Or. (Self:oDetalheMulta["fidelidade"]["modoCalculo"] == "2" .And. Len(Self:aIdBeneficiarios) < nQtdBenefFamilia)) // 2 = Individual
                Self:lCalculaMulta := .F.
            EndIf
        EndIf

        If Self:lCalculaMulta .And. Self:CheckMotivoBloqueio(cMotivoBloqueio, cTipoBloqueio)

            dDtInicial := SToD(AnoMes(Self:dDataBloqueio)+"01")
            dDtFinal := SToD(AnoMes(SToD(Self:oDetalheMulta["fidelidade"]["dataFinal"]))+"01")

            If dDtInicial < dDtFinal
                nQtdMeses := DateDiffMonth(dDtInicial, dDtFinal)

                Self:oDetalheMulta["valorTotalMulta"] := 0
                Self:oDetalheMulta["beneficiarios"] := {}
                
                If Self:oDetalheMulta["fidelidade"]["consideraFaixa"]

                    For nX := 1 To nQtdMeses

                        cAnoCalculo := Year2Str(dDtInicial)
                        cMesCalculo := Month2Str(dDtInicial)

                        If !Self:oDetalheMulta["fidelidade"]["consideraProRata"] .And. AnoMes(dDtInicial) == AnoMes(Self:dDataBloqueio)
                            dDtInicial := MonthSum(dDtInicial, 1)
                            Loop
                        EndIf

                        nValorMensalidade += Self:VlrMensalidade(cAnoCalculo, cMesCalculo)

                        dDtInicial := MonthSum(dDtInicial, 1)

                    Next nX
                Else

                    cAnoCalculo := Year2Str(MonthSum(dDtInicial, 1))
                    cMesCalculo := Month2Str(MonthSum(dDtInicial, 1))

                    nValorMensalidade += Self:VlrMensalidade(cAnoCalculo, cMesCalculo, nQtdMeses)

                    nValorMensalidade *= (nQtdMeses - 1)

                    // Calculo de Pro-rata
                    If Self:oDetalheMulta["fidelidade"]["consideraProRata"]

                        cAnoCalculo := Year2Str(dDtInicial)
                        cMesCalculo := Month2Str(dDtInicial)

                        nValorMensalidade += Self:VlrMensalidade(cAnoCalculo, cMesCalculo)
                    EndIf
                EndIf

                If nValorMensalidade > 0
                    nValorMulta := Round((nValorMensalidade * Self:oDetalheMulta["fidelidade"]["percentualMulta"]) / 100, 2)

                    Self:oDetalheMulta["valorTotalMulta"] := nValorMulta
                EndIf    
            EndIf      
        EndIf

    EndIf

Return nValorMulta


//-------------------------------------------------------------------
/*/{Protheus.doc} Gravar
Realiza a gravação da multa rescisoria do(s) beneficiário(s)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 06/09/2022
/*/
//------------------------------------------------------------------- 
Method Gravar(aBeneficiarios, cAnoGravacao, cMesGravacao) Class PLBenefMulta

    Local lRetorno := .F.
    Local nX := 0
    Local cBenefMatricula := ""
    Local nValorMulta := 0
    Local aNivelCobranca := {}
    Local aCobranca := {}
    Local cCodTes := ""
    Local cCodSB1 := ""
    Local aAreaBA1 := BA1->(GetArea())
    Local aAreaBA3 := BA3->(GetArea())

    Default aBeneficiarios := {}
    Default cAnoGravacao := Year2Str(Self:dDataBloqueio)
    Default cMesGravacao := Month2Str(Self:dDataBloqueio)
    
    If !Self:lError .And. Self:lCalculaMulta .And. ValType(Self:oDetalheMulta["valorTotalMulta"]) == "N" .And. Self:oDetalheMulta["valorTotalMulta"] > 0

        Self:oDetalheMulta["valorTotalMulta"] := 0

        If Self:CheckLancFatMulta()

            aNivelCobranca := PLSRETNCB(Self:oDetalheMulta["operadora"], Self:oDetalheMulta["empresa"], Self:oDetalheMulta["matricula"])

            BA1->(DbSetOrder(2))

            For nX := 1 To Len(Self:oDetalheMulta["beneficiarios"])

                If Len(aBeneficiarios) > 0
                    If aScan(aBeneficiarios, Self:oDetalheMulta["beneficiarios"][nX]["idMatricula"]) == 0
                        Loop
                    EndIf
                EndIf
        
                If BA1->(MsSeek(xFilial("BA1")+Self:oDetalheMulta["beneficiarios"][nX]["idMatricula"]))

                    cBenefMatricula := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
                    nValorMulta := Self:oDetalheMulta["beneficiarios"][nX]["valorMulta"]

                    PLSDADUSR(cBenefMatricula, "1", .F., Self:dDataBloqueio) // Posiciona nos dados do beneficiario      

                    cCodTes := IIf(!Empty(BQC->BQC_CODTES), BQC->BQC_CODTES, IIf(!Empty(BFQ->BFQ_CODTES), BFQ->BFQ_CODTES, BI3->BI3_CODTES))   
                    cCodSB1 := IIf(!Empty(BFQ->BFQ_CODSB1), BFQ->BFQ_CODSB1, BI3->BI3_CODSB1)

                    aAdd(aCobranca,{BFQ->BFQ_DEBCRE,;                               // 01 
                                    nValorMulta,;                                   // 02 
                                    BFQ->(BFQ_PROPRI+BFQ_CODLAN),;                  // 03 
                                    BI3->BI3_CODIGO,;                               // 04 
                                    Alltrim(BI3->BI3_DESCRI),;                      // 05
                                    "",;                                            // 06 
                                    cBenefMatricula,;				       		    // 07 
                                    BA1->BA1_NOMUSR,;		        			    // 08 
                                    .F.,;				            			    // 09
                                    BA1->BA1_SEXO,;		      	    			    // 10 
                                    BA1->BA1_GRAUPA,;		  	    			    // 11
                                    "",;				    	    			    // 12 
                                    "",;			    	        			    // 13 
                                    "",;			 	            			    // 14 
                                    BA1->BA1_TIPUSU,;		        			    // 15 
                                    "",;				            			    // 16 
                                    "",;				            			    // 17 
                                    0,;				                			    // 18 
                                    StrZero(1,4),;		            			    // 19 
                                    0,;				                			    // 20
                                    0,;				                			    // 21 
                                    BFQ->BFQ_VERBA,;		        			    // 22 
                                    nValorMulta,;		        			  	    // 23 
                                    0,;				                			    // 24
                                    0,;				                			    // 25 
                                    0,;				                			    // 26 
                                    0,;				                			    // 27 
                                    0,;				                			    // 28 
                                    0,;				                			    // 29 
                                    "",;				            			    // 30 
                                    "",;				            			    // 31 
                                    "",;				            			    // 32 
                                    0,;		        				  			    // 33 
                                    BA3->BA3_CODPLA,;		        			    // 34 
                                    BA3->BA3_VERSAO,;		        			    // 35 
                                    BI3->BI3_DESCRI,;		        			    // 36 
                                    cCodSB1,;	   	                			    // 37 
                                    cCodTES,;                       			    // 38 
                                    0,;  				            			    // 39 
                                    0,;   										    // 40 
                                    BA3->BA3_CODINT,;							    // 41 
                                    BA3->BA3_CODEMP,;							    // 42 
                                    BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),;       // 43 
                                    BA3->BA3_CONEMP,;							    // 44 
                                    BA3->BA3_VERCON,;							    // 45 
                                    BA3->BA3_SUBCON,;							    // 46 
                                    BA3->BA3_VERSUB,;							    // 47 
                                    BA3->BA3_CODPLA,;							    // 48 
                                    BA3->BA3_VERSAO,; 							    // 49 
                                    "",;										    // 50 
                                    0,;	 	 									    // 51 
                                    BA3->BA3_TIPOUS,;			  				    // 52 
                                    BA3->(RecNo()),;							    // 53 
                                    BG9->(RecNo()),;							    // 54
                                    BT5->(RecNo()),;							    // 55
                                    BQC->(RecNo()),;							    // 56
                                    BT6->(RecNo()),;							    // 57
                                    "",;	 									    // 58
                                    cAnoGravacao,;								    // 59 
                                    cMesGravacao,;								    // 60 
                                    IIf(BA1->BA1_OPEORI <> PlsIntPad(),.T.,.F.),;   // 61
                                    "",;											// 62 
                                    {},;											// 63 
                                    {},;     										// 64 
                                    {},;											// 65 
                                    .F.,;                           				// 66
                                    "",; 								            // 67
                                    BI3->BI3_TPFORN,;	                            // 68
                                    "",;									        // 69
                                    "",; 								            // 70
                                    ""})                                            // 71

                    Self:oDetalheMulta["valorTotalMulta"] += nValorMulta
                EndIf

            Next nX

            If Len(aCobranca) > 0  .And. aNivelCobranca[1]

                Self:oDetalheMulta["cobranca"]["prefixo"] := PLSA625MDa(cAnoGravacao, cMesGravacao, "1", "1", Nil, "4")[1]
                Self:oDetalheMulta["cobranca"]["numeroTitulo"] := PLSE1NUM(Self:oDetalheMulta["cobranca"]["prefixo"])
                Self:oDetalheMulta["cobranca"]["cliente"] := aNivelCobranca[2]
                Self:oDetalheMulta["cobranca"]["loja"] := aNivelCobranca[3]
                        
                lRetorno := Self:GeraTituloMulta(aCobranca, cAnoGravacao, cMesGravacao)
            EndIf
        EndIf
    Else
        Self:SetMessageError(STR0007) // "Não foi realizado o calculo da multa rescisória dos beneficiários para que seja feita gravação."
    EndIf

    RestArea(aAreaBA1)
    RestArea(aAreaBA3)

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckDadosCobranca
Verifica se o beneficiário ou familia possui título de cobrança de multa
rescisória em aberto

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/09/2022
/*/
//------------------------------------------------------------------- 
Method CheckDadosCobranca(cOperadora, cEmpresa, cMatricula, cTipRegistro, cDigito) Class PLBenefMulta

    Local lCheck := .F.
    Local nPosBenef := 0
    Local cAliasTemp := GetNextAlias()
    Local cWhere := ""    

    Default cTipRegistro := ""
    Default cDigito := ""

    cWhere := "%"
    cWhere += " AND BM1_CODINT = '"+cOperadora+"'"
    cWhere += " AND BM1_CODEMP = '"+cEmpresa+"'"
    cWhere += " AND BM1_MATRIC = '"+cMatricula+"'"

    If !Empty(cTipRegistro)
        cWhere += " AND BM1_TIPREG = '"+cTipRegistro+"'"
    EndIf

    If !Empty(cDigito)
        cWhere += " AND BM1_DIGITO = '"+cDigito+"'"
    EndIf

    cWhere += "%"

    BeginSQL Alias cAliasTemp

        SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_EMISSAO, E1_VENCTO, E1_CLIENTE,
               E1_LOJA, E1_NOMCLI, E1_PLNUCOB, E1_SALDO, E1_VALOR,
               BM1.BM1_CODINT, BM1.BM1_CODEMP, BM1.BM1_MATRIC, BM1.BM1_TIPREG, BM1.BM1_DIGITO,
               BM1.BM1_NOMUSR, BM1.BM1_VALOR
            
            FROM %Table:BM1% BM1

			INNER JOIN %Table:SE1% E1
			    ON E1.E1_FILIAL = %XFilial:SE1%
			   AND E1.E1_PREFIXO = BM1.BM1_PREFIX
			   AND E1.E1_NUM = BM1.BM1_NUMTIT
			   AND E1.E1_PARCELA = BM1.BM1_PARCEL
			   AND E1.E1_TIPO = BM1.BM1_TIPTIT
               AND E1.E1_VALOR = E1.E1_SALDO
               AND E1.%notDel%
            
            WHERE BM1.BM1_FILIAL = %XFilial:BM1%  
              %Exp:cWhere%
              AND BM1.BM1_CODTIP = '19A'
              AND BM1.%notDel%

            ORDER BY E1_PREFIXO, E1_NUM DESC

    EndSQL

    If !(cAliasTemp)->(EoF())

        Self:oDetalheMulta["cobranca"] := JsonObject():New()
        Self:oDetalheMulta["cobranca"]["prefixo"] := (cAliasTemp)->E1_PREFIXO
        Self:oDetalheMulta["cobranca"]["numeroTitulo"] := (cAliasTemp)->E1_NUM
        Self:oDetalheMulta["cobranca"]["parcela"] := (cAliasTemp)->E1_PARCELA
        Self:oDetalheMulta["cobranca"]["tipo"] := (cAliasTemp)->E1_TIPO
        Self:oDetalheMulta["cobranca"]["cliente"] := (cAliasTemp)->E1_CLIENTE
        Self:oDetalheMulta["cobranca"]["loja"] := (cAliasTemp)->E1_LOJA
        Self:oDetalheMulta["cobranca"]["nomeCliente"] := Alltrim((cAliasTemp)->E1_NOMCLI)
        Self:oDetalheMulta["cobranca"]["valor"] := (cAliasTemp)->E1_VALOR
        Self:oDetalheMulta["cobranca"]["emissao"] := (cAliasTemp)->E1_EMISSAO
        Self:oDetalheMulta["cobranca"]["vencimento"] := (cAliasTemp)->E1_VENCTO
        Self:oDetalheMulta["cobranca"]["loteCobranca"] := (cAliasTemp)->E1_PLNUCOB
        Self:oDetalheMulta["valorTotalMulta"] := (cAliasTemp)->E1_VALOR
        Self:oDetalheMulta["beneficiarios"] := {}

        While !(cAliasTemp)->(EoF())

            If (cAliasTemp)->E1_PREFIXO == Self:oDetalheMulta["cobranca"]["prefixo"] .And. (cAliasTemp)->E1_NUM == Self:oDetalheMulta["cobranca"]["numeroTitulo"]

                aAdd(Self:oDetalheMulta["beneficiarios"], JsonObject():New())
                nPosBenef := Len(Self:oDetalheMulta["beneficiarios"])

                Self:oDetalheMulta["beneficiarios"][nPosBenef]["idMatricula"] := (cAliasTemp)->(BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_TIPREG+BM1_DIGITO)
                Self:oDetalheMulta["beneficiarios"][nPosBenef]["nome"] := Alltrim((cAliasTemp)->BM1_NOMUSR)
                Self:oDetalheMulta["beneficiarios"][nPosBenef]["valorMulta"] :=  (cAliasTemp)->BM1_VALOR
                
            EndIf

            (cAliasTemp)->(DbSkip())
        EndDo

        lCheck := .T.      
    Else
        Self:SetMessageError(STR0008) // "Não foi encontrado nenhum título de multa rescisória para o(s) beneficiário(s)."
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return lCheck


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTituloMulta
Gera titulo no financeiro referente ao multa rescisória

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 06/09/2022
/*/
//------------------------------------------------------------------- 
Method GeraTituloMulta(aCobranca, cAnoGravacao, cMesGravacao) Class PLBenefMulta

    Local lRetorno := .F.
    Local aRetorno := {}
    Local cNatureza := ""
    Local dDtEmissao := dDataBase
    Local dDtVencimento := dDataBase + Self:oDetalheMulta["cobranca"]["diasVencimento"]
    Local cSituacao := "0"

    If Empty(Self:oDetalheMulta["cobranca"]["cliente"])
        Self:oDetalheMulta["cobranca"]["cliente"] := BA3->BA3_CODCLI
        Self:oDetalheMulta["cobranca"]["loja"] := BA3->BA3_LOJA
    Endif 

    cNatureza := A627BusNat(BG9->BG9_TIPO, BA3->BA3_NATURE, (Self:oDetalheMulta["cobranca"]["cliente"]+Self:oDetalheMulta["cobranca"]["loja"]), BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO))  
    
    Begin Transaction

    RegToMemory("BDC", .T.)  
    
    M->BDC_TIPO := Iif(BA3->BA3_TIPOUS == "1", "2", "1")
    M->BDC_MESINI := cMesGravacao
    M->BDC_MESFIM := cMesGravacao
    M->BDC_ANOINI := cAnoGravacao
    M->BDC_ANOFIM := cAnoGravacao  
    M->BDC_NUMERO := PLSA625Num()
    M->BDC_DTEMIS := dDtEmissao

    aRetorno := PLGERREC(Self:oDetalheMulta["cobranca"]["prefixo"],;        // 01 - cPrefixo
						 Self:oDetalheMulta["cobranca"]["numeroTitulo"],;   // 02 - cNumero
						 Self:oDetalheMulta["idFamilia"],;                  // 03 - _cChave 
						 cMesGravacao,;                                     // 04 - cMes
						 cAnoGravacao,;                                     // 05 - cAno
						 dDtVencimento,;                                    // 06 - dVencto
						 M->BDC_NUMERO,;                                    // 07 - cNumCob
						 Self:oDetalheMulta["valorTotalMulta"],;            // 08 - nValor
						 "",;                                               // 09 - cNossoN
						 Self:oDetalheMulta["cobranca"]["cliente"],;        // 10 - cCodCli
						 Self:oDetalheMulta["cobranca"]["loja"],;           // 11 - cLoja
						 BG9->BG9_TIPO,;                                    // 12 - cTipo
						 aCobranca,;                                        // 13 - aVlrCob 
						 "4",;                                              // 14 - _cNivel
						 Nil,;                                              // 15 - aMatBa3
						 Nil,;                                              // 16 - cGratuito
						 Nil,;                                              // 17 - lAberto
						 0,;                                                // 18 - nCobComple
						 Nil,;                                              // 19 - lInterC
						 Nil,;                                              // 20 - lConsiste
						 "",;                                               // 21 - cBanco
						 cSituacao,;                                        // 22 - cSitE1
						 cNatureza,;                                        // 23 - cNaturez
						 Nil,;                                              // 24 - cCusOpe
						 "",;                                               // 25 - cOrig
						 BA3->BA3_TIPPAG,;                                  // 26 - cTipoPag
						 BA3->BA3_PORTAD,;                                  // 27 - cPortado
						 BA3->BA3_AGEDEP,;                                  // 28 - cAgePor
						 BA3->BA3_CTACOR,;                                  // 29 - cCCPor
						 BA3->BA3_BCOCLI,;                                  // 30 - cBcoCli
						 BA3->BA3_AGECLI,;                                  // 31 - cAgeCli
						 BA3->BA3_CTACLI,;                                  // 32 - cCCCli
						 dDtEmissao,;	                                    // 33 - dEmissao
						 Nil,;	                                            // 34 - lCritica
						 Nil,;	                                            // 35 - lContabiliza
						 Nil,;	                                            // 36 - aRecnos
						 Nil,;	                                            // 37 - aRetAcu
						 Nil,;                                              // 38 - nValAcu
						 Self:oDetalheMulta["operadora"])                   // 39 - cCodInt

    If aRetorno[1][1]       
        M->BDC_VALOR := aRetorno[1][4]      

        SE1->(DbSetOrder(1)) 
	    If SE1->(MsSeek(xFilial("SE1")+Self:oDetalheMulta["cobranca"]["prefixo"]+Self:oDetalheMulta["cobranca"]["numeroTitulo"]))

            Self:oDetalheMulta["cobranca"]["parcela"] := SE1->E1_PARCELA 
            Self:oDetalheMulta["cobranca"]["tipo"] := SE1->E1_TIPO
            Self:oDetalheMulta["cobranca"]["emissao"] := DToS(SE1->E1_EMISSAO)
            Self:oDetalheMulta["cobranca"]["vencimento"] := DToS(SE1->E1_VENCTO)
            Self:oDetalheMulta["cobranca"]["loteCobranca"] := SE1->E1_PLNUCOB
            Self:oDetalheMulta["cobranca"]["nomeCliente"] := Alltrim(SE1->E1_NOMCLI)

            lRetorno := .T.
        EndIf
    Endif

    Self:oDetalheMulta["cobranca"]["valor"] := aRetorno[1][4]

    M->BDC_CONGER := IIf(aRetorno[1][1], 1, 0)
    M->BDC_CONCRI := IIf(aRetorno[1][1], 0, 1)
    M->BDC_HORAF := Time()

    PLUPTENC("BDC", 3)  

    BDC->(ConfirmSX8())           

    PLSA625Cri( M->BDC_NUMERO, Self:oDetalheMulta["cobranca"]["valor"], aRetorno, BA3->BA3_CODINT,;
                BA3->BA3_CODEMP, BA3->BA3_CONEMP, BA3->BA3_VERCON, BA3->BA3_SUBCON, BA3->BA3_VERSUB,;
                BA3->BA3_MATRIC, GetNewPar("MV_PLCDTGP", "01"), "4", cAnoGravacao, cMesGravacao, .F.)

    End Transaction

Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckLancFatMulta
Veririca o lançamento de faturamento da Multa Rescisória

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 13/09/2022
/*/
//------------------------------------------------------------------- 
Method CheckLancFatMulta() Class PLBenefMulta
    
    Local lCheck := .T.
    Local cCodLancamento := "19A"

    BFQ->(DbSetOrder(1))
    If !BFQ->(MsSeek(xFilial("BFQ")+Self:oDetalheMulta["operadora"]+cCodLancamento))

        BFQ->(RecLock("BFQ", .T.))

            BFQ->BFQ_FILIAL := xFilial("BFQ")
            BFQ->BFQ_CODINT := Self:oDetalheMulta["operadora"]
            BFQ->BFQ_PROPRI := "1"
            BFQ->BFQ_CODLAN := "9A"
            BFQ->BFQ_DESCRI := "Multa Rescisória de Contratos"
            BFQ->BFQ_SEQUEN := "09A"
            BFQ->BFQ_DEBCRE := "1"
            BFQ->BFQ_CONTAB := "0"
            BFQ->BFQ_ATOCOO := "1"
            BFQ->BFQ_TIPFAT	:= "1"
            BFQ->BFQ_ATIVO := "1"
            BFQ->BFQ_FORCAL	:= "PLSVLRACU"
            
		BFQ->(MsUnLock())

        lCheck := .T.
    EndIf

Return lCheck


//-------------------------------------------------------------------
/*/{Protheus.doc} VlrMensalidade
Retorna o valor total da mensalidade da familia

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 31/08/2022
/*/
//------------------------------------------------------------------- 
Method VlrMensalidade(cAnoCalculo, cMesCalculo, nQtdMeses) Class PLBenefMulta

    Local nX := 0
    Local cMatricula := ""
    Local nPosBenef := 0
    Local nVlrTotalMensalidade := 0
    Local nValorMensalidade := 0
    Local aCobranca := {}
    Local lConsDataCancel := GetNewPar("MV_PRODTCA", .F.)
    Local nValorProRata := 0
    Local nPercUtilizado := 0

    Default nQtdMeses := 0

    aCobranca := PLSVLRFAM(Self:oDetalheMulta["idFamilia"], cAnoCalculo, cMesCalculo, Nil, Nil, .T., Nil, Nil, .T.)[1]

    If Len(aCobranca) >= 2 .And. aCobranca[1] .And. Len(aCobranca[2]) > 0

        For nX := 1 To Len(aCobranca[2])
            
            nPosBenef := 0
            cMatricula := aCobranca[2][nX][7]

            If aCobranca[2][nX][3] == "101" .And. aScan(Self:aIdBeneficiarios, cMatricula) > 0

                If Len(Self:oDetalheMulta["beneficiarios"]) > 0
                    nPosBenef := aScan(Self:oDetalheMulta["beneficiarios"], {|x| x["idMatricula"] == aCobranca[2][nX][7] })
                EndIf

                If nPosBenef == 0
                    aAdd(Self:oDetalheMulta["beneficiarios"], JsonObject():New())
                    nPosBenef := Len(Self:oDetalheMulta["beneficiarios"])

                    Self:oDetalheMulta["beneficiarios"][nPosBenef]["idMatricula"] := aCobranca[2][nX][7] 
                    Self:oDetalheMulta["beneficiarios"][nPosBenef]["nome"] := Alltrim(aCobranca[2][nX][8])
                    Self:oDetalheMulta["beneficiarios"][nPosBenef]["valorMulta"] :=  0
                EndIf

                If !Self:oDetalheMulta["fidelidade"]["consideraFaixa"] .And. nQtdMeses > 0
                    Self:oDetalheMulta["beneficiarios"][nPosBenef]["valorMulta"] += Round(((aCobranca[2][nX][2] * (nQtdMeses - 1)) * Self:oDetalheMulta["fidelidade"]["percentualMulta"]) / 100, 2)                         
                    nValorMensalidade := aCobranca[2][nX][2]
                Else
                    // Calculo de Pro-rata
                    If (cAnoCalculo+cMesCalculo) == AnoMes(Self:dDataBloqueio)

                        nPercUtilizado := plRPerPR(Self:dDataBloqueio, lConsDataCancel, Nil, .T., IIf(FindFunction("PLDayVencCob"), PLDayVencCob(Self:oDetalheMulta["idFamilia"]), Nil))	    
                        nValorProRata := Round(((aCobranca[2][nX][2] * (100 - nPercUtilizado)) / 100), 2)

                        nValorMensalidade := nValorProRata
                    Else
                        nValorMensalidade := aCobranca[2][nX][2]
                    EndIf

                    Self:oDetalheMulta["beneficiarios"][nPosBenef]["valorMulta"] += Round((nValorMensalidade * Self:oDetalheMulta["fidelidade"]["percentualMulta"]) / 100, 2)   
                EndIf
                
                nVlrTotalMensalidade += nValorMensalidade
            EndIf
        Next nX

    EndIf

Return nVlrTotalMensalidade


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckMotivoBloqueio
Verifica se o motivo de bloqueio informado irá gerar a multa rescisória
para o beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/09/2022
/*/
//------------------------------------------------------------------- 
Method CheckMotivoBloqueio(cMotivo, cTipo) Class PLBenefMulta

    Local lMulta := .T.
    Local aArea := {}

    Default cMotivo := ""
    Default cTipo := ""

    If !Empty(cMotivo) .And. !Empty(cTipo)

        Do Case
            Case cTipo == "1" .And. BG3->(FieldPos("BG3_MULTA")) > 0 // 1 = Bloqueio do Beneficiário 

                aArea := BG3->(GetArea())  

                BG3->(DbSetOrder(1))
                If BG3->(MsSeek(xFilial("BG3")+cMotivo)) .And. BG3->BG3_MULTA <> "1" // 1 = Sim
                    lMulta := .F.
                EndIf

                RestArea(aArea)

            Case cTipo == "2" .And. BG1->(FieldPos("BG1_MULTA")) > 0 // 2 = Bloqueio da Familia

                aArea := BG1->(GetArea())  

                BG1->(DbSetOrder(1))
                If BG1->(MsSeek(xFilial("BG1")+cMotivo)) .And. BG1->BG1_MULTA <> "1" // 1 = Sim 
                    lMulta := .F.
                EndIf

                RestArea(aArea)
        
        EndCase
    EndIf

    If !lMulta
        Self:SetMessageError(STR0009) // "O motivo de bloqueio informado não gera multa rescisória para o beneficiário ou familía."
    EndIf

Return lMulta

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDetalhe
Retorna o objeto detalhe da multa rescisoria

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method GetDetalhe() Class PLBenefMulta

Return Self:oDetalheMulta


//-------------------------------------------------------------------
/*/{Protheus.doc} GetJsonDetalhe
Retorna json referente ao detalhe da multa rescisoria

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method GetJsonDetalhe() Class PLBenefMulta

Return FWJsonSerialize(Self:oDetalheMulta, .F., .F.)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetHtmlMulta
Retorna string no formato HTML referente ao dados da multa processada

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 09/09/2022
/*/
//------------------------------------------------------------------- 
Method GetHtmlMulta(lDisplayBenef) Class PLBenefMulta

	Local cHtml := ""
    Local lGeradoMulta := ValType(Self:oDetalheMulta["valorTotalMulta"]) == "N" .And. Self:oDetalheMulta["valorTotalMulta"] > 0
	Local nX := 0

    Default lDisplayBenef := .T.

    If !Self:lError .And. lGeradoMulta

        cHtml += "<p>"+STR0010+"<br>" // "De acordo com a <b>RESOLUÇÃO NORMATIVA - RN Nº 412</b>, CAPÍTULO III, Artigo. 20:"
        cHtml += STR0011+"</p>" // "O pedido de cancelamento dos contratos individuais ou familiares não exime o beneficiário do pagamento de multa rescisória, quando prevista em contrato, se a solicitação ocorrer antes da vigência mínima."
        
        cHtml += "<h3>"+STR0012+"</h3>" // "Detalhes da Multa:"
        cHtml += "<table border=0 cellpadding='4'>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0013+"</font></b></td>" // Produto:
        cHtml += "		<td>"+Self:oDetalheMulta["produto"]+" - "+Self:oDetalheMulta["descricaoProduto"]+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0014+"</font></b></td>" // Data de Inclusão:
        cHtml += "		<td>"+Substr(Self:oDetalheMulta["dataInclusao"], 7, 2)+"/"+Substr(Self:oDetalheMulta["dataInclusao"], 5, 2)+"/"+Substr(Self:oDetalheMulta["dataInclusao"], 1, 4)+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0015+"</font></b></td>" // Prazo de Fidelidade:
        cHtml += "		<td>"+cValToChar(Self:oDetalheMulta["fidelidade"]["quantidadeMeses"])+" meses</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0016+"</font></b></td>" // Data Final da Fidelidade:
        cHtml += "		<td>"+Substr(Self:oDetalheMulta["fidelidade"]["dataFinal"], 7, 2)+"/"+Substr(Self:oDetalheMulta["fidelidade"]["dataFinal"], 5, 2)+"/"+Substr(Self:oDetalheMulta["fidelidade"]["dataFinal"], 1, 4)+"</td>"
        cHtml += "	</tr>"
        cHtml += "</table>"

        If lDisplayBenef
            cHtml += "<h3>Beneficiários:</h3>"
            cHtml += "<table border=0 cellpadding='4'>"
            cHtml += "	<tr bgcolor='#2ca8c7'>"
            cHtml += "		<td align='center'><b><font color='white'>"+STR0017+"</font></b></td>" // Matricula
            cHtml += "		<td align='center'><b><font color='white'>"+STR0018+"</font></b></td>" // Nome
            cHtml += "		<td align='center'><b><font color='white'>"+STR0019+"</font></b></td>" // Multa Rescisória
            cHtml += "	</tr>"

            For nX := 1 To Len(Self:oDetalheMulta["beneficiarios"])
                cHtml += "	<tr>"
                cHtml += "		<td align='center'>"+Alltrim(Transform(Self:oDetalheMulta["beneficiarios"][nX]["idMatricula"], "@R !!!!.!!!!.!!!!!!-!!-!"))+"</td>"
                cHtml += "		<td align='center'>"+Self:oDetalheMulta["beneficiarios"][nX]["nome"]+"</td>"
                cHtml += "		<td align='center'>R$ "+Alltrim(Transform(Self:oDetalheMulta["beneficiarios"][nX]["valorMulta"], "@E 9,999,999,999,999.99"))+"</td>"
                cHtml += "	</tr>"
            Next nX

            cHtml += "	<tr>"
            cHtml += "		<td colspan='2' align='right'><b>"+STR0032+"</b></td>" // Valor Total:
            cHtml += "		<td align='center'><b><font color='red'>R$ "+Alltrim(Transform(Self:oDetalheMulta["valorTotalMulta"], "@E 9,999,999,999,999.99"))+"</font></b></td>"
            cHtml += "	</tr>"

            cHtml += "</table>"

            cHtml += "<br>"

            cHtml += "<p>"+STR0020+"</p>" // O sistema irá gerar uma cobrança referente a multa, deseja continuar com a solicitação de cancelamento?
        EndIf
    
    EndIf

Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} GetHtmlCobranca
Retorna string no formato HTML referente ao dados da cobrança (Titulo)
dos beneficiarios

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 12/09/2022
/*/
//------------------------------------------------------------------- 
Method GetHtmlCobranca(lMsgCancel) Class PLBenefMulta

	Local cHtml := ""
    Local lGeradoCobranca := ValType(Self:oDetalheMulta["cobranca"]) == "J" .And. ValType(Self:oDetalheMulta["cobranca"]["valor"]) == "N"

    Default lMsgCancel := .F.

    If !Self:lError .And. lGeradoCobranca

        cHtml += "<p>"+STR0021+"<br></p>" // Foi gerado um título no Financeiro referente a multa rescisória de contrato do(s) beneficiário(s) com os seguintes dados:
        cHtml += "<table border=0 cellpadding='4'>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0022+"</font></b></td>" // Prefixo:
        cHtml += "		<td>"+Self:oDetalheMulta["cobranca"]["prefixo"]+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0023+"</font></b></td>" // Número:
        cHtml += "		<td>"+Self:oDetalheMulta["cobranca"]["numeroTitulo"]+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0024+"</font></b></td>" // Parcela:
        cHtml += "		<td>"+Self:oDetalheMulta["cobranca"]["parcela"]+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0025+"</font></b></td>" // Tipo:
        cHtml += "		<td>"+Self:oDetalheMulta["cobranca"]["tipo"]+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0026+"</font></b></td>" // Cliente:
        cHtml += "		<td>"+Self:oDetalheMulta["cobranca"]["cliente"]+"/"+Self:oDetalheMulta["cobranca"]["loja"]+" - "+Self:oDetalheMulta["cobranca"]["nomeCliente"]+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0027+"</font></b></td>" // Valor:
        cHtml += "		<td>R$ "+Alltrim(Transform(Self:oDetalheMulta["cobranca"]["valor"], "@E 9,999,999,999,999.99"))+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0028+"</font></b></td>" // Emissão:
        cHtml += "		<td>"+Substr(Self:oDetalheMulta["cobranca"]["emissao"], 7, 2)+"/"+Substr(Self:oDetalheMulta["cobranca"]["emissao"], 5, 2)+"/"+Substr(Self:oDetalheMulta["cobranca"]["emissao"], 1, 4)+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0029+"</font></b></td>" // Vencimento:
        cHtml += "		<td>"+Substr(Self:oDetalheMulta["cobranca"]["vencimento"], 7, 2)+"/"+Substr(Self:oDetalheMulta["cobranca"]["vencimento"], 5, 2)+"/"+Substr(Self:oDetalheMulta["cobranca"]["vencimento"], 1, 4)+"</td>"
        cHtml += "	</tr>"
        cHtml += "	<tr>"
        cHtml += "		<td bgcolor='#2ca8c7'><b><font color='white'>"+STR0030+"</font></b></td>" // Lote de Cobrança:
        cHtml += "		<td>"+Alltrim(Transform(Self:oDetalheMulta["cobranca"]["loteCobranca"], "@R !!!!.!!!!!!!!"))+"</td>"
        cHtml += "	</tr>"
        cHtml += "</table>"

        If lMsgCancel
            cHtml += "<br><p>"+STR0031+"</p>" // Caso necessite a exclusão do título, utilize a rotina de <b>Cancelamento de Títulos (PLSA629)</b>.
        EndIf

    EndIf

Return cHtml


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessageError
Retorna mensagem de error, caso não tenha nenhum erro no processo será
retorno vazio

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method GetMessageError() Class PLBenefMulta

Return Self:cMessageError


//-------------------------------------------------------------------
/*/{Protheus.doc} SetMessageError
Define mensagem de error no processo de calculo da multa

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/08/2022
/*/
//------------------------------------------------------------------- 
Method SetMessageError(cMessage) Class PLBenefMulta

    Default cMessage := ""

    If !Empty(cMessage)

        Self:cMessageError := Alltrim(cMessage)
        Self:lError := .T.

    EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GetQtdBenFamilia
Retorna a quantidade de beneficiários ativos na familia

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 15/09/2022
/*/
//-------------------------------------------------------------------
Method GetQtdBenFamilia() Class PLBenefMulta

	Local nQtdBeneficiarios := 0
	Local cQuery := ""

	cQuery := " SELECT COUNT(BA1_TIPREG) CONTADOR FROM " + RetSQLName("BA1") + " BA1 "
	cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "
	cQuery += "   AND BA1.BA1_CODINT = '"+Self:oDetalheMulta["operadora"]+"' "
	cQuery += "   AND BA1.BA1_CODEMP = '"+Self:oDetalheMulta["empresa"]+"' "
	cQuery += "   AND BA1.BA1_MATRIC = '"+Self:oDetalheMulta["matricula"]+"' "
	cQuery += "   AND BA1.BA1_DATBLO = ' '"
	cQuery += "   AND BA1.D_E_L_E_T_ = ' ' "

	nQtdBeneficiarios := MPSysExecScalar(cQuery, "CONTADOR")

Return nQtdBeneficiarios