#Include "PROTHEUS.CH"

#Define CONS_BASIC "01" // consulta básica - pediatria, clínica médica, cirurgia geral, ginecologia e obstetrícia
#Define CONS_DMESP "02" // consulta nas demais especialidades médicas
#Define CONS_FONO "03" // consulta/sessão com fonoaudiólogo
#Define CONS_NUTRI "04" // consulta/sessão com nutricionista
#Define CONS_PSICO "05" // consulta/sessão com psicólogo
#Define CONS_TERAP "06" // consulta/sessão com terapeuta ocupacional
#Define CONS_FISIO "07" // consulta/sessão com fisioterapeuta
#Define CONS_DENTI "08" // consulta e procedimentos realizados em consultório/clínica com cirurgião-dentista
#Define SERV_LABOR "09" // serviços de diagnóstico por laboratório de análises clínicas em regime ambulatorial 
#Define SERV_TERAP "10" // demais serviços de diagnóstico e terapia em regime ambulatorial
#Define PROC_PAC "11" // procedimentos de alta complexidade - PAC
#Define ATEN_HOSPD "12" // atendimento em regime de hospital-dia
#Define ATEN_INTER "13" // atendimento em regime de internação eletiva
#Define ATEN_URGEN "14" // urgência e emergência

// Classificação da Sessão na Natureza Saúde
#Define SESS_FISIO "B1" // consulta/sessão com fisioterapeuta
#Define SESS_FONO "B2" // consulta/sessão com fonoaudiólogo
#Define SESS_NUTRI "B3" // consulta/sessão com nutricionista
#Define SESS_TERAP "B4" // consulta/sessão com terapeuta ocupacional
#Define SESS_PSICO "B5" // consulta/sessão com psicólogo

//-------------------------------------------------------------------
/*/{Protheus.doc} PLCalcPrzAtend
Classe para calcular o prazo do Atendimento do Beneficiário de acordo
com a RN 259 da ANS.
 
@author Vinicius Queiros Teixeira
@since 06/12/2021
@version Prothues 12
/*/
//-------------------------------------------------------------------
Class PLCalcPrzAtend

    // Consultas/Sessões
    Data lConsBasica As Boolean
    Data lConsDemaisEsp As Boolean
    Data lConSesFonoaudiologo As Boolean
    Data lConSesNutricionista As Boolean
    Data lConSesPsicologo As Boolean
    Data lConSesTerapeuta As Boolean
    Data lConSesFisioterapeuta As Boolean
    Data lConsServDentista As Boolean
    // Procedimentos
    Data lProcAltaComple As Boolean
    Data lServLaboratorio As Boolean
    Data lDemaisServTerapia As Boolean
    // Atendimentos
    Data lAtendHospitalDia As Boolean
    Data lInternEletiva As Boolean
    Data lUrgenciaEmerg As Boolean 

    Data cOperadora As String
    Data dDataCalculo As Date
    Data aPrazos As Array

    Method New(dDataCalculo) Constructor
    Method SetTpAdmissao(cTipAdmissao, lInternacao)
    Method SetHospitalDia(lHospitalDia)
    Method SetAtendOdonto(lOdonto)
    Method SetConsulta(cEspecialidade)
    Method SetSessao(cClassificacao)
    Method SetProcAltoCusto(lAltoCusto)
    Method SetServicosAmb(lAmbulatorio, lLaboratorio)
    Method GetPrzEspecialidade(cEspecialidade)
    Method CalcPrazo()
    Method AddDiasPrazo(cCodPrazo)
    Method SumDiasUteis(nPrazoGuia)

EndClass


//----------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Classe

@author Vinicius Queiros Teixeira
@since 06/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method New(dDataCalculo) Class PLCalcPrzAtend 

    Default dDataCalculo := dDataBase
  
    Self:lConsBasica := .F.
    Self:lConsDemaisEsp := .F.
    Self:lConSesFonoaudiologo := .F.
    Self:lConSesNutricionista := .F.
    Self:lConSesPsicologo := .F.
    Self:lConSesTerapeuta := .F.
    Self:lConSesFisioterapeuta := .F.
    Self:lConsServDentista := .F.
    Self:lProcAltaComple := .F.
    Self:lServLaboratorio := .F.
    Self:lDemaisServTerapia := .F.
    Self:lAtendHospitalDia := .F.
    Self:lInternEletiva := .F.
    Self:lUrgenciaEmerg := .F.
    Self:cOperadora := PlsIntPad()
    Self:dDataCalculo := dDataCalculo
    Self:aPrazos := {}
    
Return Self

//----------------------------------------------------------
/*/{Protheus.doc} SetTpAdmissao
Define o tipo de Admissão do Atendimento

@author Vinicius Queiros Teixeira
@since 06/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetTpAdmissao(cTipAdmissao, lInternacao) Class PLCalcPrzAtend
 
    Local aAreaBDR := BDR->(GetArea())

    Default cTipAdmissao := ""
    Default lInternacao := .F.

    BDR->(DbSetOrder(1))
    If BDR->(MsSeek(xFilial("BDR")+Self:cOperadora+cTipAdmissao))

        Do Case
            Case BDR->BDR_CARINT == "E" .And. lInternacao // E = Eletiva
                Self:lInternEletiva := .T.  
       
            Case BDR->BDR_CARINT == "U" // U = Urgencia/Emergencia                                                                                              
                Self:lUrgenciaEmerg := .T.
        EndCase

    EndIf

    RestArea(aAreaBDR)

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetHospitalDia
Define se a Internação é em Hospital dia

@author Vinicius Queiros Teixeira
@since 06/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetHospitalDia(lHospitalDia) Class PLCalcPrzAtend

    Default lHospitalDia := .F.

    Self:lAtendHospitalDia := lHospitalDia

Return 


//----------------------------------------------------------
/*/{Protheus.doc} SetAtendOdonto
Define se o Atendimento é Odontologico

@author Vinicius Queiros Teixeira
@since 07/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetAtendOdonto(lOdonto) Class PLCalcPrzAtend

    Default lOdonto := .F.

    If !Self:lConsServDentista .And. lOdonto
        Self:lConsServDentista  := .T.
    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetConsulta
Define se o atendimento é uma Consulta

@author Vinicius Queiros Teixeira
@since 07/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetConsulta(cEspecialidade) Class PLCalcPrzAtend

    Local cCodPrazo := ""

    Default cEspecialidade := ""

    If Empty(cEspecialidade)
        Self:lConsBasica := .T.
    Else
        cCodPrazo := Self:GetPrzEspecialidade(cEspecialidade)

        Do Case
            Case cCodPrazo == CONS_BASIC
                Self:lConsBasica := .T.              

            Case cCodPrazo == CONS_FONO
                Self:lConSesFonoaudiologo := .T.

            Case cCodPrazo == CONS_NUTRI
                Self:lConSesNutricionista := .T.

            Case cCodPrazo == CONS_PSICO
                Self:lConSesPsicologo := .T.

            Case cCodPrazo == CONS_TERAP
                Self:lConSesTerapeuta := .T.

            Case cCodPrazo == CONS_FISIO
                Self:lConSesFisioterapeuta := .T.    
            
            OtherWise  
                 Self:lConsDemaisEsp := .T.       
        EndCase

    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetSessao
Define se o Atendimento é uma Sessão

@author Vinicius Queiros Teixeira
@since 08/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetSessao(cClassificacao) Class PLCalcPrzAtend

    Default cClassificacao := ""

    Do Case
        Case cClassificacao == SESS_FONO
            Self:lConSesFonoaudiologo := .T.

        Case cClassificacao == SESS_NUTRI
            Self:lConSesNutricionista := .T.

        Case cClassificacao == SESS_PSICO
            Self:lConSesPsicologo := .T.

        Case cClassificacao == SESS_TERAP
            Self:lConSesTerapeuta := .T.

        Case cClassificacao == SESS_FISIO
            Self:lConSesFisioterapeuta := .T.    
                
    EndCase

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetProcAltoCusto
Define se o Atendimento tem procedimento de Alto Custo

@author Vinicius Queiros Teixeira
@since 07/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetProcAltoCusto(lAltoCusto) Class PLCalcPrzAtend

    Default lAltoCusto := .F.

    If !Self:lProcAltaComple .And. lAltoCusto
        Self:lProcAltaComple := .T.
    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} SetServicosAmb
Define se o Atendimento é de Serviçoes Diagnosticos em Regime
Ambulatorial

@author Vinicius Queiros Teixeira
@since 07/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SetServicosAmb(lAmbulatorio, lLaboratorio) Class PLCalcPrzAtend

    Default lAmbulatorio := .F.
    Default lLaboratorio := .F.

    If lAmbulatorio
        If lLaboratorio
            If !Self:lServLaboratorio
                Self:lServLaboratorio := .T.
            EndIf
        Else
            If !Self:lDemaisServTerapia
                Self:lDemaisServTerapia := .T.
            EndIf
        EndIf
    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} GetPrzEspecialidade
Retorna o Código do Prazo da Especidalidade Informada

@author Vinicius Queiros Teixeira
@since 07/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method GetPrzEspecialidade(cEspecialidade) Class PLCalcPrzAtend

    Local cCodPrazoEsp := ""
    Local cQuery := ""
    Local cAliasTemp := ""

    Default cEspecialidade := ""

    cAliasTemp := GetNextAlias()
    cQuery := " SELECT BAQ.BAQ_PRZATE FROM "+RetSqlName("BAQ")+" BAQ "
    cQuery += " WHERE BAQ.BAQ_FILIAL = '"+xFilial("BAQ")+"'"
    cQuery += "   AND BAQ.BAQ_CODINT = '"+Self:cOperadora+"'"
    cQuery += "   AND BAQ.BAQ_CODESP = '"+cEspecialidade+"'"
    cQuery += "   AND BAQ.D_E_L_E_T_ = ' '"

    dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)
    
    If !(cAliasTemp)->(Eof())
		cCodPrazoEsp := (cAliasTemp)->BAQ_PRZATE
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return cCodPrazoEsp


//----------------------------------------------------------
/*/{Protheus.doc} CalcPrazo
Calculo o Prazo do Atendimento

@author Vinicius Queiros Teixeira
@since 06/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method CalcPrazo() Class PLCalcPrzAtend 

    Local dDataPrazo := CToD(" / / ")
    Local nPrazoGuia := 0

    If Self:lUrgenciaEmerg
        Self:AddDiasPrazo(ATEN_URGEN)
    Else
        If Self:lInternEletiva
            Self:AddDiasPrazo(ATEN_INTER)
        Else
            Do Case
                Case Self:lConsBasica 
                    Self:AddDiasPrazo(CONS_BASIC)

                Case Self:lConsDemaisEsp
                    Self:AddDiasPrazo(CONS_DMESP)

                Case Self:lConSesFonoaudiologo
                    Self:AddDiasPrazo(CONS_FONO)

                Case Self:lConSesNutricionista
                    Self:AddDiasPrazo(CONS_NUTRI)

                Case Self:lConSesPsicologo
                    Self:AddDiasPrazo(CONS_PSICO)

                Case Self:lConSesTerapeuta
                    Self:AddDiasPrazo(CONS_TERAP)

                Case Self:lConSesFisioterapeuta
                    Self:AddDiasPrazo(CONS_FISIO)          
            EndCase

            If Self:lConsServDentista
                Self:AddDiasPrazo(CONS_DENTI)
            Else
                If !Self:lAtendHospitalDia .And. !Self:lProcAltaComple
                    Do Case
                        Case Self:lServLaboratorio
                            Self:AddDiasPrazo(SERV_LABOR)
                        
                        Case Self:lDemaisServTerapia
                            Self:AddDiasPrazo(SERV_TERAP)
                    Endcase
                EndIf
            EndIf

        EndIf

        If Self:lAtendHospitalDia
            Self:AddDiasPrazo(ATEN_HOSPD)
        EndIf

        If Self:lProcAltaComple
            Self:AddDiasPrazo(PROC_PAC)
        EndIf
       
    EndIf

    If Len(Self:aPrazos) > 0
        ASort(Self:aPrazos, Nil, Nil, { |x,y| x[2] < y[2]})

        nPrazoGuia := Self:aPrazos[1][2] // Menor Prazo

        dDataPrazo := Self:SumDiasUteis(nPrazoGuia)

    EndIf
  
Return dDataPrazo


//----------------------------------------------------------
/*/{Protheus.doc} AddDiasPrazo
Adiciona os Dias do Prazo Informado 

@author Vinicius Queiros Teixeira
@since 06/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method AddDiasPrazo(cCodPrazo) Class PLCalcPrzAtend

    Default cCodPrazo := ""

    B6Y->(DbSetOrder(1))
    If B6Y->(MsSeek(xFilial("B6Y")+cCodPrazo))
        aAdd(Self:aPrazos, {B6Y->B6Y_CODPRZ, B6Y->B6Y_PRAZO})
    EndIf

Return


//----------------------------------------------------------
/*/{Protheus.doc} SumDiasUteis
Soma os dias úteis da data informada

@author Vinicius Queiros Teixeira
@since 07/12/2021
@version Prothues 12
/*/
//----------------------------------------------------------
Method SumDiasUteis(nPrazoGuia) Class PLCalcPrzAtend
    
    Local dDataRetorno := Self:dDataCalculo

    Default nPrazoGuia := 0

    While nPrazoGuia > 0

        dDataRetorno := DaySum(dDataRetorno, 1)

        If dDataRetorno == DataValida(dDataRetorno)
            nPrazoGuia--
        EndIf

    EndDo

Return dDataRetorno