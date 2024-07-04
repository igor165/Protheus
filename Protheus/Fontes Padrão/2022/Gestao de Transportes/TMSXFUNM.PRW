#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'fwlibversion.ch'

Static aDadosOco:= {}
Static nAcesso360:= 0    //Dados da Métrica de chamada da Rotina TMSA360
Static nAcesso360:= 0    //Dados da Métrica de chamada da Rotina TMSA360
Static aDadosOco := {}   //Dados da Métrica de Ocorrencia Encerra Processo
Static aDadosSob := {}   //Dados da Métrica de Ocorrencia Sobra e Falta
Static aDdsSobra := {}   //Dados da Métrica de Ocorrencia Sobra
Static aDdsFalta := {}   //Dados da Métrica de Ocorrencia Falta

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSMetrica
LS - Prepara para o  Envio da Métrica 
@type   Function
@author Katia
@since  15/03/2021
@param  cRotina,cTypepMet
@return lRet
/*/
//-----------------------------------------------------------------

Function TMSMetrica( cRotina, cTypepMet )

Local lRet      := .T.
Local nTimeMet  := 0
Local cAuto360  := ""
Local c360v2    := ""
Local cSubRot   := ""
Local dDtSend   := CToD("  /  /    ")

Default cRotina  := ""
Default cTypepMet:= "S"   //Sincrono

If cRotina == "TMSA360"
    //Dados da Métrica de chamada da Rotina TMSA360
    //tms-protheus_qtd-ocorrencias-automaticas_total
    //tms-protheus_qtd-ocorrencias-manuais_total
    //tms-protheus_qtd-entregas-realizadas-por-tms_total
    //tms-protheus_qtd-falta-ou-sobra-op-transporte_total
    If l360Auto .And. IsBlind()
        cAuto360    := 'tms-protheus_qtd-ocorrencias-automaticas_total' // Em breve será substituida
        c360v2      := 'tms-protheus_forma-de-registro-das-ocorrencias_total'
        cSubRot     := 'TMSA360_Auto'
    Else
        cAuto360    := 'tms-protheus_qtd-ocorrencias-manuais_total' // Em breve será substituida
        c360v2      := 'tms-protheus_forma-de-registro-das-ocorrencias_total'
        cSubRot     := 'TMSA360_Manual'
    EndIf

    If nAcesso360 > 0       // 
        lRet:= TMSAddMet( cRotina, cAuto360 /*IdMetrica*/, nAcesso360 /*nValueMet*/, nTimeMet, cTypepMet, dDtSend )
        lRet:= TMSAddMet( cSubRot, c360v2 /*IdMetrica*/, nAcesso360 /*nValueMet*/, nTimeMet, cTypepMet, dDtSend, 1, cRotina )
        nAcesso360:= 0
    EndIf

    //Dados da Métrica de Ocorrencia Encerra Processo
    If Len(aDadosOco) > 0   // temporario para teste visualizar
        lRet:= TMSAddMet( cRotina, 'tms-protheus_qtd-entregas-realizadas-por-tms_total' /*IdMetrica*/, Len(aDadosOco) /*nValueMet*/, nTimeMet, cTypepMet, dDtSend )
        lRet:= TMSAddMet( 'TMS360_01', 'tms-protheus_quantidade-de-ocorrencias-registradas_total' /*IdMetrica*/, Len(aDadosOco) /*nValueMet*/, nTimeMet, cTypepMet, dDtSend, 1, cRotina )
        aDadosOco:= {}
    EndIf

    //Dados da Métrica de Ocorrencia Sobra
    If Len(aDdsSobra) > 0   // 
        lRet:= TMSAddMet( 'TMS360_06_03', 'tms-protheus_quantidade-de-ocorrencias-registradas_total' /*IdMetrica*/, Len(aDadosSob) /*nValueMet*/, nTimeMet, cTypepMet, dDtSend, 1, cRotina )
        aDdsSobra:= {}
    EndIf

    //Dados da Métrica de Ocorrencia Falta
    If Len(aDdsFalta) > 0   // 
        lRet:= TMSAddMet( 'TMS360_06_01', 'tms-protheus_quantidade-de-ocorrencias-registradas_total' /*IdMetrica*/, Len(aDdsFalta) /*nValueMet*/, nTimeMet, cTypepMet, dDtSend, 1, cRotina )
        aDdsSobra:= {}
    EndIf

    //Zera o contador (variaveis statics)
    TMSSetMet()
EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSAddMet
LS - Adiciona a Método Metrica 
@type   Function
@author Katia
@since  15/03/2021
@param  cRotina,IdMetrica,nValueMet,nTimeMet
@return lRet
/*/
//-----------------------------------------------------------------

Function TMSAddMet( cSubRot, IdMetrica, nValueMet, nTimeMet, cTypepMet, dDtSend, nTipo, cRot )

Local lRet  := .T.

Default cRotina   := ""
Default IdMetrica := ""    //"“QTD_ACCESS” // Quantidade de acessos a sub rotina
Default nValueMet := 0
Default nTimeMet  := 0
Default cTypepMet := ""    //S- Sincrono, A- Assincorono
Default dDtSend   := dDataBase + 1
Default nTipo     := 1
Default cRot      := FunName()

// -- Proteção incluida caso não exista a classe FWCUSTOMMETRICS 

If FWLibVersion() < "20210517"
    lRet := .F.
EndIf        

If lRet
    If nTipo == 1
        FWCustomMetrics():SetSumMetric( cSubRot, IdMetrica, nValueMet, dDtSend, /*nLapTime*/, cRot/*cRotina*/)
    ElseIf nTipo == 2
        FWCustomMetrics():SetAverageMetric( cSubRot, IdMetrica, nValueMet, dDtSend, /*nLapTime*/, cRot/*cRotina*/)
    ElseIf nTipo == 3
        FWCustomMetrics():SetUniqueMetric( cSubRot, IdMetrica, nValueMet, dDtSend, /*nLapTime*/, cRot/*cRotina*/)
    EndIf

    If cTypepMet == "A"
        /*cCode  - Código da mensagem LS006
        cUser    - Código do usuário que será enviado.Opcional, default __cUserId
        nMódulo  - Número do módulo que será enviado
        cRoutine - Nome da rotina que será enviada*/

        FWLsPutAsyncInfo( "LS006", , '43', cRotina )
    EndIf
EndIf

Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} TMSMet360
LS - Acumula valores de metricas do TMSA360
@type   Function
@author Katia
@since  15/03/2021
@param  cFilDoc,cDoc,cSerie
@return Nil
/*/
//-----------------------------------------------------------------

Function TMSMet360( nTipoMet, cFilDoc, cDoc, cSerie, nOpc )

Local nSeek         := 0
Local lFalta        := DT2->DT2_TIPPND == StrZero( 1, Len(DT2->DT2_TIPPND) ) //-- Falta
Local lSobra        := DT2->DT2_TIPPND == StrZero( 3, Len(DT2->DT2_TIPPND) ) //-- Sobra

Default nTipoMet    := 0
Default cFilDoc     := ""
Default cDoc        := ""
Default cSerie      := ""
Default nOpc        := 0    //3- Apontar ou 4- Estornar (Enquanto estiver dentro da aplicação)

//--- Não sera registrado as métricas de estorno neste primeiro momento.
//--- Será contabilizado o estorno desde que o usuário aponte a ocorrencia e por algum motivo de erro, estorne sem sair da tela.
//--- No caso, de acessar diretamente a rotina e clicar no Excluir, este não será contabilizado.
//1- Metrica por Ocorrencias de Entregas Realizadas (Encerra Processo)
//2- Metrica por Ocorrencias de Sobras e Faltas
//3- Metrica por chamada do TMSA360 (automatico ou manual

If nTipoMet == 1  //Acumula por chamada da Rotina TMSA360
    nAcesso360 += 1

ElseIf nTipoMet == 2  //Acumula por Ocorrecia de Encerra Processo
    If !Empty(cFilDoc+cDoc+cSerie)
	    nSeek := Ascan( aDadosOco, { |x| x[1] == cFilDoc + cDoc + cSerie } )

	    If nSeek == 0
            If nOpc == 3  //Apontar - somente registra os apontamentos
		        AAdd(aDadosOco,{cFilDoc+cDoc+cSerie})
            EndIf
        Else
            If nOpc == 4  //Estornar - remove o documento 
                Adel(aDadosOco,nSeek)
				Asize(aDadosOco,Len(aDadosOco)-1)
            EndIf
	    EndIf
    EndIf

ElseIf nTipoMet == 3  //Acumula por Ocorrecia de Sobras e Faltas
    If !Empty(cFilDoc+cDoc+cSerie)
	    nSeek := Ascan(aDadosSob,{ |x| x[1] == cFilDoc + cDoc + cSerie })
	    If nSeek == 0
            If nOpc == 3  //Apontar - somente registra os apontamentos
		        AAdd(aDadosSob,{cFilDoc+cDoc+cSerie})
            EndIf
        Else
            If nOpc == 4  //Estornar - remove o documento 
                Adel(aDadosSob,nSeek)
				Asize(aDadosSob,Len(aDadosSob)-1)
            EndIf
	    EndIf
		
		If lSobra //-- Sobra
            //aDdsSobra Dados da Métrica de Ocorrencia Sobra
            nSeek := Ascan( aDdsSobra, { |x| x[1] == cFilDoc + cDoc + cSerie } )
            If nSeek == 0
                If nOpc == 3  //Apontar - somente registra os apontamentos
                    AAdd( aDdsSobra, {cFilDoc+cDoc+cSerie})
                EndIf
            Else
                If nOpc == 4  //Estornar - remove o documento 
                    Adel( aDdsSobra, nSeek )
                    Asize( aDdsSobra, Len(aDdsSobra)-1 )
                EndIf
            EndIf
        EndIf

        If lFalta //-- Falta
            //aDdsFalta Dados da Métrica de Ocorrencia Falta
            nSeek := Ascan( aDdsFalta, { |x| x[1] == cFilDoc + cDoc + cSerie } )
            If nSeek == 0
                If nOpc == 3  //Apontar - somente registra os apontamentos
                    AAdd( aDdsFalta, {cFilDoc+cDoc+cSerie})
                EndIf
            Else
                If nOpc == 4  //Estornar - remove o documento 
                    Adel( aDdsFalta, nSeek )
                    Asize( aDdsFalta, Len(aDdsFalta)-1 )
                EndIf
            EndIf
        EndIf

    EndIf
EndIf

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} TF64SetSt
Seta as variveis Statics
@type   Function
@author Katia
@since  15/03/2021
@version    12.1.33
/*/
//-----------------------------------------------------------------

Function TMSSetMet()

    nAcesso360:= 0    //Dados da Métrica de chamada da Rotina TMSA360
    aDadosOco := {}   //Dados da Métrica de Ocorrencia Encerra Processo
    aDadosSob := {}   //Dados da Métrica de Ocorrencia Sobra e Falta
    aDdsSobra := {}   //Dados da Métrica de Ocorrencia Sobra 
    aDdsFalta := {}   //Dados da Métrica de Ocorrencia Falta

Return
