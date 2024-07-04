#INCLUDE "TOTVS.CH"
#DEFINE ARQUIVO_LOG "job_Schepls627.log"


/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico de schedule de cobrança
    @type  Function
    @author Robson Nayland
    @since 13/08/2020
/*/
Main Function SchePls627(lJob)
    Default lJob := isBlind()
    If lJob
        StartJob("JobSche627", GetEnvServer(), .F., cEmpAnt, cFilAnt, lJob)
    Else
        JobSche627(cEmpAnt, cFilAnt,.F.)
    EndIf
return



/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico de atualização de configuração de artefatos
    @type  Function
    @author Robson Nayland
    @since 13/08/2020
/*/
Function JobSche627(cEmp,cFil,lJob)
    Local dDataRef  := MsDate()
    Local nI        := 0
    Default cEmp    := "99"
    Default cFil    := "01"
    Default lJob    := isBlind()

	If lJob
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio do job JobSche627 ",ARQUIVO_LOG)

    oPlsScheObj627 := PlsScheObj627():New()
   
    DBSelectArea("B6J")
    DBSelectArea("B6k")

    //Verificando a existencia de cadastro de agendamento com a data de referencia
	oPlsScheObj627:LoadAgenda(dDataRef)


    If oPlsScheObj627:lExitProc
         
        //Varrendo os Agendamentos
        For nI:=1 To Len(oPlsScheObj627:aRecScheB6J)

            B6J->(DbGoTo(oPlsScheObj627:aRecScheB6J[nI]))
            oPlsScheObj627:cMesFrente := B6J->B6J_MESFRE
            oPlsScheObj627:TipoPessoa()
            oPlsScheObj627:ExisteFiltro()
            oPlsScheObj627:CarregaDados(dDataRef)

             PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Executando o Agendamento: "+B6J->B6J_CODAGE+" (JobSche627) ",ARQUIVO_LOG)

        Next nI

    Else
        //Não existindo cadastro e agendamento   
         PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Não há agendamento para esse dia !! (JobSche627) ",ARQUIVO_LOG)   
    EndIf
   
return

Static Function SchedDef()
Return { "P","",,{},""}