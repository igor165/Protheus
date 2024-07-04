#include 'protheus.ch' 
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//Salva dados do Ambiente
Static cBkpFilAnt       := ""
Static cBkpEmpAnt       := ""
Static aAreaSM0         := {}    

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiControl
Rotina para preparar o ambiente para a importacao de registro do legado para o Protheus via Schedule.

@Obs	 INT300KJ para RmiControl 
@author  Everson S P Junior
@since   03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiControl(aParam, cEmpAux, cFilAux, cTotFil)

    Local cJob      := ""
    Local cEmpJob   := ""   //Empresa
    Local cFilJob   := ""   //Guarda a filial anterior
    Local cFuncao   := ""   //Codigo da Rotina que sera executada

    Default cEmpAux := ""
    Default cFilAux	:= ""
    Default cTotFil	:= "0"

    Begin Sequence

        //Analisa Parametros recebidos.
        If Empty(cEmpAux) .and. Empty(cFilAux)
            Conout("RmiControl - JOB iniciado via schedule.")
            LjGrvLog("RmiControl", "Inicio do processamento de Importação - JOB iniciado via schedule.")
            cFuncao := "CUPOM"
            cEmpJob := If( ValType(aParam[1]) == "C", aParam[1], cEmpAnt)   
            cFilJob := If( ValType(aParam[2]) == "C", aParam[2], cFilAnt)            
        
        //Caso esteja como tipo Caracter, significa que esta sendo executado pelo JOB
        ElseIf Valtype(aParam) == "C"
            cFuncao := aParam
            aParam	:= {}
            
            aAdd(aParam, cFuncao)
            aAdd(aParam, cEmpAux)
            aAdd(aParam, cFilAux)
            aAdd(aParam, cTotFil)

            LjGrvLog("RmiControl", "Parâmetros recebidos pelo aParam.", aParam)

            cFuncao := aParam[1]
            cEmpJob := If( ValType(aParam[2]) == "C", aParam[2], cEmpAnt)   
            cFilJob := If( ValType(aParam[3]) == "C", aParam[3], cFilAnt)
        EndIf      

        LjGrvLog("RmiControl", "Inicio do processamento de Importação - Função: " + cFuncao + " Empresa: " + cEmpJob + " Filial: " + cFilJob)

        //Alterado para RPCSetType(3) para não consumir licença
        RpcSetType(3)
        RpcSetEnv(cEmpJob, cFilJob)
        LjGrvLog("RmiControl", "Empresa Aberta - Empresa: " + cEmpJob + " Filial: " + cFilJob)

        //Trava a execução para evitar que mais de uma sessão faça a execução.
        cJob := "RMICONTROL_" +  cEmpJob + "_" + cFuncao
        If !LockByName(cJob, .T., .T.)
            LjxjMsgErr( I18n("#1 - Serviço já esta sendo utilizado por outra instância.", {cJob}), /*cSolucao*/, /*cRotina*/)
            Return Nil
        EndIf

        //Executa a funcao de Importacao passada no Parametro
        RmiExec(cFuncao, cEmpJob, cFilJob)

        //Libera a execução
        UnLockByName(cJob, .T., .T.)

        LjGrvLog("RmiControl", "Fim do processamento de Importação - Função: " + cFuncao + " Empresa: " + cEmpJob + " Filial: " + cFilJob)

    End Sequence

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiFilInt
Trata Filial
@param cFilInt, lAtualiza, cCnpj

@return Vazio
@Obs	INTM010U para RmiFilInt 
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiFilInt(cFilInt, lAtualiza, cCnpj)

    Default cFilInt	    := cFilAnt
    Default lAtualiza	:= .T.
    Default cCnpj		:= ""       //Descontinuado
                                
    If lAtualiza
        
        If !Empty(cFilInt) 
            cBkpEmpAnt  := SM0->M0_CODIGO
            cBkpFilAnt  := cFilAnt
            aAreaSM0    := SM0->( GetArea() )

            SM0->( DbSetOrder(1) )			//M0_CODIGO + M0_CODFIL
            SM0->( MsSeek(cBkpEmpAnt + PadR(cFilInt, 12)) )
            cFilAnt     := cFilInt
        EndIf              
    Else

        If Len(aAreaSM0) > 0
            RestArea(aAreaSM0)
            cFilAnt := cBkpFilAnt
        EndIf   
    EndIf
        
Return(Nil)
     
//-------------------------------------------------------------------
/*/{Protheus.doc} RmiThread
Calcula a quantidade de registros por Thread
@param nQtdRegis, cParametro

@return Vazio
@Obs	INTM010W para RmiThread
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiThread(nQtdRegis, cParametro)

    Local nQtdThread    := 1    //Quantidade de Threads de Processamento
    Local nRegThread    := 0     

    Default cParametro  := "IN_TRHEAMI"
            
    nQtdThread := SuperGetMv(cParametro, Nil, 4)
    nRegThread := Int( nQtdRegis / nQtdThread )

    If Mod( nQtdRegis, nQtdThread ) > 0 
        nRegThread++                                    
    EndIf

Return(nRegThread)

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCargaIn
Executa a funcao que foi chamada pelo StartJob para as cargas iniciais
@param cEmpJob, cFilJob, aFuncExec, cThread

@return Vazio
@Obs	INTM010X para RmiCargaIn
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCargaIn(cEmpJob, cFilJob, aFuncExec, cThread)
 
    Local cFuncao   := ""           //Nome da Funcao que sera Executada
    Local nRecIni   := 0            //Recno Inicial
    Local nRecFim   := 0            //Recno Final
    Local nCont     := 0            //Contador
    Local cJob      := "RmiCargaIn" //Nome do Semaforo
    Local oLocker   := Nil          //Objeto utilizado para Semaforo
    Local nLockByOld:= 0            //Numero maximo de nomes reservados anteriormente
        
    //aFuncExec - Composicao
    //--Nome da Funcao
    //--Descricao
    //--Recno Inicial
    //--Recno Final                 
        
    //Prepara o Ambiente
    LjGrvLog("RmiCargaIn","RmiControl - Chamada funcionalidade " + cJob + " - Tread Filial: " + cFilJob + " - Empresa : " + cEmpJob)
    RpcSetType(3)
    RpcSetEnv(cEmpJob, cFilJob)            
        
    //Verifica se o JOB ja esta executando.
    cJob += AllTrim(cEmpJob) + "_" + AllTrim( Upper(aFuncExec[1][1]) ) + "_" + cThread
    oLocker := LJCGlobalLocker():New()
    If !oLocker:GetLock( cJob )
        Conout(" * * " + DtoC(dDataBase) + " " + Time() + " - <<< " + cJob + " >>> Processo ja esta em execucao.")
        LjGrvLog("RmiCargaIn","RmiControl - * * " + DtoC(dDataBase) + " " + Time() + " - <<< " + cJob + " >>> Processo ja esta em execucao.")
        RpcClearEnv()   //Reset Environment
        Return(Nil)
    EndIf
        
    //Atualiza o numero máximo de nomes reservados para MayIUseCode.
    nLockByOld := SetMaxCodes(50)
        
    For nCont:=1 To Len(aFuncExec)
        cFuncao := AllTrim( Upper(aFuncExec[nCont][1]) )  
        nRecIni := aFuncExec[nCont][3]
        nRecFim := aFuncExec[nCont][4]
                    
        LjGrvLog("RmiCargaIn","RmiControl - THREAD: " + cThread + " FUNCAO: " + cFuncao + " REGISTROS: " + cValToChar(nRecIni) + " ao " + cValToChar(nRecFim) )
            
        //Verifica a funcao que sera executada.
        Do Case
            Case cFuncao == "RMIRETAILJ"  
                RMIRetailJ( Nil, nRecIni, nRecFim, /*cStaimp*/)

            Case cFuncao == "RMICANCELLATION"  
                RmiCancellation(Nil, nRecIni, nRecFim, /*cStaimp*/)

            OtherWise
                LjxjMsgErr("Não existe regra para executar a função: " + cFuncao, /*cSolucao*/)
        EndCase

        //Aguarda 5 segundo para processar a proxima funcao
        LjGrvLog("RmiCargaIn","RmiControl - THREAD: " + cThread + " FUNCAO: " + cFuncao + " REGISTROS: " + cValToChar(nRecIni) + " ao " + cValToChar(nRecFim) + " - FINALIZADA. " )
        Sleep(5000)
    Next nCont
        
    //Restaura o numero maximo de nomes reservados para MayIUseCode.
    SetMaxCodes(nLockByOld)
        
    //Libera JOB que estava em execucao.
    oLocker:ReleaseLock(cJob)

Return(Nil)     

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPrepM
Prepara para chamar as rotinas via Multi Thread
@param cTabTemp, cQuery, cFuncao, cParametro

@return Vazio
@Obs	³INTM010Y para RmiPrepM
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPrepM(cTabTemp, cQuery, cFuncao, cParametro)

    Local nQtdThread := 1   //Quantidade de Threds de Processamento
    Local nQtdRegis  := 0
    Local nRegThread := 0
    Local aRecnos    := {}  
    Local nThread    := 1
    Local nIni       := 1
    Local nFim       := 0
    Local lEspera    := .F.
    Local aDados     := {}
        
    Default cParametro  := "IN_TRHEAMI"
        
    nQtdThread := SuperGetMv(cParametro, Nil, 4)
        
    If Select(cTabTemp) <> 0
        (cTabTemp)->( DbCloseArea() )
    Endif  

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabTemp, .F., .T.)
        
    //Carrega os registros
    If !(cTabTemp)->( Eof() )
        While !(cTabTemp)->( Eof() )
            Aadd(aRecnos, (cTabTemp)->REGISTRO)
            (cTabTemp)->( DbSkip() )
        EndDo

    //Caso seja EOF não processar e retornar DAC 18/10/2013
    Else
        (cTabTemp)->( DbCloseArea() )  //DAC 20160927
        Return(Nil)
    EndIf
    (cTabTemp)->( DbCloseArea() )
        
    //Carrega os registros por Thread.
    nQtdRegis := Len(aRecnos)  
    If nQtdRegis > 0

        //Pega a quantidade de Registros por Thread.
        nRegThread := RmiThread(nQtdRegis, cParametro)
                    
        For nThread:=1 To nQtdThread

            If nThread == nQtdThread
                lEspera := .T.
                nFim    := nQtdRegis
            Else    
                nFim := (nIni + nRegThread) - 1                 
            EndIf

            //Verifica se a quantidade total de registro eh maior ou igual a inicial e final.
            If nQtdRegis >= nIni .AND. nQtdRegis >= nFim

                If nQtdThread == 1
                    aDados  := {cFuncao, "", 0, 0}
                Else
                    aDados  := {cFuncao, "", aRecnos[nIni], aRecnos[nFim]}
                EndIf

                //Executa Threads.
                StartJob("RmiCargaIn", GetEnvServer(), lEspera, cEmpAnt, cFilAnt, {aDados}, cValToChar(nThread))
                Sleep(5000)
            EndIf
            nIni += nRegThread
        Next nThread
    EndIf

    Sleep(10000)
  
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiExec
Executa funcao de Importacao ou Carga Inicial que sera
executada via schedule
@param cFuncao, cEmpJob, cFilJob

@return Vazio
@Obs	³ RmiExec
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RmiExec(cFuncao, cEmpJob, cFilJob)

    Local cDescricao := ""      //Descricao da Rotina que esta sendo executada
    Local nCont      := 1       //Contador
    Local aFuncoes   := {}      //Funcoes que seram executadas

    Default cEmpJob := ""
    Default cFilJob := "" 
        
    cFuncao := AllTrim( Upper(cFuncao) )

    If cFuncao == "CUPOM"
        cFuncao     := "RMICUPIMP"
        cDescricao  := "Importacao de Cupons - MULTI THREAD"
        Aadd(aFuncoes, {cFuncao, cDescricao})
        
        //Startar o Cancelamento na mesma configuração do CUPOM 
        cFuncao     := "RMICANCEXE"
        cDescricao  := "Cancelamento de Cupons - MULTI THREAD"
        Aadd(aFuncoes, {cFuncao, cDescricao})
    EndIf
        
    //Valida Execucao das Rotinas.
    If Len(aFuncoes) == 0
        LjxjMsgErr( I18n("Função #1 sem regra de execução pelo job RmiControl, será desprezada.", {cFuncao}), /*cSolucao*/, /*cRotina*/)

    Else   

        //Importacao - Executas as Importacao.
        For nCont:=1 To Len(aFuncoes)
            If ExistFunc(aFuncoes[nCont][1])
                LjGrvLog("RmiExec","RmiControl - " + DtoC(dDataBase) + " " + Time() + " (RmiExec) - Executando Importacao referente a Rotina: " + aFuncoes[nCont][1] + " - " + Upper(aFuncoes[nCont][2]) )
                &(aFuncoes[nCont][1] + "()")
            EndIf
        Next nCont
    EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIGRVSTAT
Grava o Status na tabela q foi feita a integracao
@param aQuery

@return Vazio
@Obs	³ ³INTM010J para RMIGRVSTAT
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIGRVSTAT(cAlias, nRec, cStatus)

    (cAlias)->( DbGoTo(nRec) )

    (cAlias)->( RecLock(cAlias, .F.) )
        &(cAlias + "->L1_SITUA") := cStatus
    (cAlias)->( MsUnLock() )

    IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(cAlias), NIL)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMICUPIMP
Efetua importacao dos cupons fiscais em Multi - Thread
@param cCnpj

@return Vazio
@Obs	³ ³INTM210E para RMICUPIMP
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMICUPIMP()

    Local cTabTemp	:= 	"TMPSL1"
    Local cFuncao	:= 	"RMIRetailJ"   //DAC 18/10/2013             
    Local cQuery 	:=	""

    //Efetua o processamento
    cQuery := " SELECT SL1.*, SL1.R_E_C_N_O_ as REGISTRO FROM " + RetSQLName("SL1") + " SL1" +;
            " WHERE SL1.L1_SITUA = 'IP' AND D_E_L_E_T_ = ' ' "                             +;
            " ORDER BY SL1.R_E_C_N_O_"
                    
    //Chama funcao para executar as Multis Threads.?
    RmiPrepM(cTabTemp, cQuery, cFuncao, "IN_TRHECUP")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIDadoInu
	Retorna as informações da inutilização
	@type  Function
	@author Julio.Nery
	@since 13/10/2020
	@version 12
	@param cUUID, string, chave para pesquisa que contem o UUID
	@return aRet, array, contem os dados da inutilização
/*/
//-------------------------------------------------------------------
Function RMIDadoInu(cUUID)

    Local aArMHQ        := {}
    Local aRet	        := {}
    Local cAlias        := "TBMHQUID"
    Local cAux	        := ""
    Local cSQL	        := ""
    Local cMHQMSGORI    := ""
    Local cMHQORIGEM    := ""
    Local lOriLIVE      := .F.
    Local lOriCHEF      := .F.
    Local oJson	        := NIL
    Local lOriSync      := ""
    Local lCampos       :=  SLX->( ColumnPos("LX_DTINUTI"   ) ) > 0 .And.;
                            SLX->( ColumnPos("LX_PRINUT"    ) ) > 0 .And.;
                            SLX->( ColumnPos("LX_RETSFZ"    ) ) > 0 .And.;
                            SLX->( ColumnPos("LX_CHVNFCE"   ) ) > 0 .And.;
                            SLX->( ColumnPos("LX_MOTIVO"    ) ) > 0

    Default cUUID := ""

    If !Empty(cUUID)

        cSQL := " SELECT R_E_C_N_O_ RECMHQ"
        cSQL += " FROM " + RetSQLName("MHQ")
        cSQL += " WHERE MHQ_UUID = '" + cUUID + "'"
        cSQL += " AND MHQ_EVENTO = '3' "
        cSQL := ChangeQuery(cSQL)
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cSQL), cAlias, .T., .F.)
        
        If (cAlias)->( Eof() )
            LjGrvLog("RMIRETAILCONTROL", "Não foi encontrado na MHQ informação do UUID gravado na SLX. Verifique ->", cUUID)
        Else

            aArMHQ := MHQ->(GetArea())

            MHQ->( DBGoTo( (cAlias)->RECMHQ ) )
            cMHQMSGORI := MHQ->MHQ_MSGORI
            cMHQORIGEM := Alltrim(MHQ->MHQ_ORIGEM)
            RestArea(aArMHQ)

            lOriLIVE := (cMHQORIGEM == "LIVE")
            lOriCHEF := (cMHQORIGEM == "CHEF")
            lOriSync := (cMHQORIGEM == "PDVSYNC")
            Aadd(aRet,{"","","","",""})

            If lOriCHEF
                LjGrvLog("RMIRETAILCONTROL","Mensagem de Origem proviniente de sistema CHEF")
                
                If Alltrim(SLX->LX_UUID) == Alltrim(cUUID)
                    //Incluindo os dados no array para inutilização
                    
                    If lCampos
                        aRet[1][1] := SLX->LX_DTINUTI                                        
                        aRet[1][2] := SLX->LX_PRINUT                    
                        aRet[1][3] := SLX->LX_RETSFZ                                        
                        aRet[1][4] := SLX->LX_CHVNFCE                
                        aRet[1][5] := SLX->LX_MOTIVO
                    Else
                        LjGrvLog("RMIRETAILCONTROL","Algum campo não foi encontrado! Aplique o pacote de Expedição Contínua - Varejo" ) 
                        aRet := {}
                    EndIf
                Else
                    LjGrvLog("RMIRETAILCONTROL","Registro da SLX divergente com o UUID em processamento!")
                    aRet := {}
                EndIf                             

                LjGrvLog("RMIRETAILCONTROL","Fim da inclusão de dados no array aDadoInut.")
                
            ElseIf lOriLIVE //Retorna um XML
                LjGrvLog("RMIRETAILCONTROL","Mensagem de Origem proviniente de sistema LIVE")
                cMHQMSGORI := '<?xml version="1.0" encoding="UTF-8"?><XML>' + cMHQMSGORI + '</XML>'
                cMHQMSGORI := STRTRAN(cMHQMSGORI, Chr(13)+Chr(10), "")
                cMHQMSGORI := EncodeUtf8(cMHQMSGORI)
                oJson := TXMLManager():New()
                If oJson:Parse( cMHQMSGORI )
                    LjGrvLog("RMIRETAILCONTROL","Mensagem LIVE - Leitura dos dados do XML")

                    //Campo 1
                    //Para cancelamento a Data de Inutilização é errada na TAg.
                    cAux := oJson:XPathGetNodeValue("DataInutilizacao") 
                    If ValType(cAux) == "C"
                        If Empty(AllTrim(cAux)) 
                            cAux := oJson:XPathGetNodeValue("DataHora")
                        EndIf
                        
                        If ValType(cAux) == "C"
                            //Em metodo XML vem no padrão: dd/mm/aaaa hh:mm:ss
                            If At("/",cAux) > 0
                                aRet[1][1] := CtoD(SubStr(cAux,1,10))
                            Else
                                //Deve retornar no padrão aaaa-mm-ddThh:mm:ss
                                aRet[1][1] := StoD(StrTran(SubStr(cAux,1,10),"-"))
                            EndIf
                        EndIf
                    EndIf                    
                    If ValType(aRet[1][1]) <> "D"
                        aRet[1][1] := dDataBase
                    EndIf

                    //Campo 2
                    cAux := oJson:XPathGetNodeValue("ProtocoloInutilizacao")
                    If ValType(cAux) == "N"
                        cAux := cValToChar(cAux)
                    EndIf
                    If ValType(cAux) == "C"
                        aRet[1][2] := AllTrim(cAux)
                    EndIf

                    //Campo 3
                    cAux := oJson:XPathGetNodeValue("RetornoSefazInutilizacao")
                    If ValType(cAux) == "N"
                        cAux := cValToChar(cAux)
                    EndIf
                    If ValType(cAux) == "C"
                        If Empty(cAux) 
                            aRet[1][3] := "102"  // -- 102|Inutilização de número homologado
                        Else
                            aRet[1][3] := AllTrim(cAux)
                        EndIf 
                    EndIf

                    //Campo 4
                    cAux := oJson:XPathGetNodeValue("ChaveNFCeCancelada")
                    If ValType(cAux) == "N"
                        cAux := cValToChar(cAux)
                    EndIf
                    If ValType(cAux) == "C"
                        If Empty(cAux)
                            cAux := oJson:XPathGetNodeValue("ChaveNFCe")
                        EndIf
                        If ValType(cAux) == "C"
                            aRet[1][4] := AllTrim(cAux)
                        EndIf
                    EndIf

                    //Campo 5
                    cAux := oJson:XPathGetNodeValue("SituacaoNFCe")
                    If ValType(cAux) == "C"
                        aRet[1][5] := AllTrim(cAux)
                    EndIf

                    LjGrvLog("RMIRETAILCONTROL","Mensagem LIVE - Fim da Leitura dos dados do XML")
                Else
                    LjGrvLog("RMIRETAILCONTROL","Mensagem LIVE - Erro ao tentar converter o XML - {XML, Erro, Warning}", {cMHQMSGORI,oJson:Error(),oJson:Warning()})
                    aRet := {}				
                EndIf
            Else
               
                aRet[1][1] := SLX->LX_DTINUTI                                        
                aRet[1][2] := SLX->LX_PRINUT                    
                aRet[1][3] := SLX->LX_RETSFZ                                        
                aRet[1][4] := SLX->LX_CHVNFCE                
                aRet[1][5] := SLX->LX_MOTIVO

            EndIf
        EndIf

        (cAlias)->(DBCloseArea())
    EndIf

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Função utilizada por rotina colocadas no Schedule

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

    Local aParam  := {}

    aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
                "ParamDef"          ,;  //Pergunte do relatorio, caso nao use passar ParamDef
                /*Alias*/           ,;	
                /*Array de ordens*/ ,;
                /*Titulo*/          }

Return aParam
