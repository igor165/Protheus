#INCLUDE "TOTVS.CH"
#DEFINE ARQUIVO_LOG "job_extdmed.log"


/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico de schedule da extração do arquivo DMED para modulo Central de Obrigações
    @type  Function
    @author Robson Nayland
    @since 23/11/2020
/*/
Main Function PlJobExtDmed(lJob,lAutoma)
    Default lJob    := isBlind()
    Default lAutoma := .F.
    If lJob
        StartJob("JobExtDmed", GetEnvServer(), .F., cEmpAnt, cFilAnt, lJob,lAutoma)
    Else
        JobExtDmed(cEmpAnt, cFilAnt,.F.,lAutoma)
    EndIf
return



/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico de atualização dos arquivos DMED para a Central de Obrigações
    @type  Function
    @author Robson Nayland
    @since 23/11/2020
/*/
Function JobExtDmed(cEmp,cFil,lJob,lAutoma)
    Local dDataRef  := MsDate()-30
    Local cAliasBM1 := GetNextAlias()
    Local cAliasB44 := GetNextAlias()
    Local oJson	    := nil
    Local nLin      := 0

    Default cEmp    := "99"
    Default cFil    := "01"
    Default lJob    := isBlind()
    Default lAutoma := .F.

	If lJob
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio do job JobExtDmed ",ARQUIVO_LOG)

    oPlObjExtDmed := PlObjExtDmed():New()


    // Verificando quais os meses que tenho para enviar, assim não cria um objeto grande com muita informação sobrecarregando

    //Verificando a existencia de registros na BM1 não enviado para DMED na central de Obrigações
	oPlObjExtDmed:LoadDmedBm1(dDataRef,@cAliasBM1,.T.)
   
    If oPlObjExtDmed:lExistBM1
  
        oJson	    := JsonObject():new()

        aSort(oPlObjExtDmed:aMesesDmed )
        //Verificando a existencia de registros na BM1 não enviado para DMED na central de Obrigações
        For nLin:=1 To Len(oPlObjExtDmed:aMesesDmed)
            dDataRef := sTod(oPlObjExtDmed:aMesesDmed[nLin]+'01')

            // Carrega BM1 do mes de referencia
            oPlObjExtDmed:LoadDmedBm1(dDataRef,@cAliasBM1,.F.)
            // Cria o Json do BM1
            oPlObjExtDmed:CarregaJson(oJson,@cAliasBM1,0)
            //Envia o Json para a central
            oPlObjExtDmed:EnviaCentral(oJson,"BM1",lAutoma)
            (cAliasBM1)->(dbCloseArea()) 
        Next nI    
    Else
        //Não existindo movimentação na tabela BM1
         PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Não há movimentos BM1 para DMED !! (JobExtDmed) ",ARQUIVO_LOG)
         (cAliasBM1)->(dbCloseArea())   
    EndIf
 
    dDataRef  := MsDate()-30

    //Verificando a existencia de registros na B44 não enviado para DMED na central de Obrigações
	oPlObjExtDmed:LoadDmedB44(dDataRef,@cAliasB44,.T.)
   
    If oPlObjExtDmed:lExistB44
   
        oJson	    := JsonObject():new()

        aSort(oPlObjExtDmed:aMesesDmed )
        //Verificando a existencia de registros na B44 não enviado para DMED na central de Obrigações
        For nLin:=1 To Len(oPlObjExtDmed:aMesesDmed)
            dDataRef := sTod(oPlObjExtDmed:aMesesDmed[nLin]+'01')
             // Carrega B44 do mes de referencia
            oPlObjExtDmed:LoadDmedB44(dDataRef,@cAliasB44,.F.)
            // Cria o Json do B44
            oPlObjExtDmed:CarregaJson(oJson,@cAliasB44,1)
            //Envia o Json para a central
            oPlObjExtDmed:EnviaCentral(oJson,"B44",lAutoma)

            (cAliasB44)->(dbCloseArea()) 
        Next nI        
    Else
        //Não existindo movimentação na tabela BM1
         PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Não há movimentos B44 para DMED !! (JobExtDmed) ",ARQUIVO_LOG)
         (cAliasB44)->(dbCloseArea())   
    EndIf

  
   
return

Static Function SchedDef()
Return { "P","",,{},""}