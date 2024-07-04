#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'fileio.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "OGX065.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX065
Função responsável por atualizar o valor da previsão financeira
@author  rafael.voltz
@since   02/05/2018
@version version
@param  MV_PAR01, numeric, Qtd Dias Vencimento                
        MV_PAR02, char,   Diretório para geração dos logs                
@return lretorno, boolean, status do retorno da função
/*/
//-------------------------------------------------------------------
Function OGX065()    
   
   Local aParam := {MV_PAR01, MV_PAR02}      
   
   RPCSetType(3)  //Nao consome licensas   
      
   OGX065PROC(aParam[1], aParam[2])     
   
   FWFreeObj(aParam)
   
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Definição de função padrão para o Schedule
@author  rafael.voltz
@since   02/05/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
   Local aOrd := {}
   Local aParam := {}
   
   aParam := {"P"        ,;    //Processo
              "OGX065"   ,;    //PERGUNTE OU PARAMDEF
              ""         ,;    //ALIAS p/ relatorio
              aOrd       ,;    //Array de Ordenacao p/ relatorio
              ""         }     //Titulo para Relatório
Return aParam

//-------------------------------------------------------------------
/*/{Protheus.doc} function
description
@author  author
@since   date
@version version
@param  cQtdDias,   numeric, Quantidade dias antes do vencimento, a partir da data corrente
        cDirLog,    char,    Diretório para geração do log
        cFilialIni, char,    Filial inicial
        cFilialFin, char,    Filial final
        cCtrIni,    char,    Contrato Inicial
        cCtrFim,    char,    Contrato Final
        cEntidIni,  char,    Entidade Incial
        cEntidFim,  char,    Entidade Final
        cLojaIni,   char,    Loja inicial
        cLojaFim,   char,    Loja final
        cProdIni,   char,    Produto Inicial
        cProdFim,   char,    Produto Final
        cSafraIni,  char,    Safra Inicial
        cSafraFim,  char,    Safra Final
/*/
//-------------------------------------------------------------------
Function OGX065PROC(nQtdDias, cDirLog, cFilialIni, cFilialFin, cCtrIni, cCtrFim, cEntidIni, cEntidFim, cLojaIni, cLojaFim, cProdIni, cProdFim, cSafraIni, cSafraFim)   
    Local aAreaNJR   := NJR->(GetArea())
    Local aAreaNJ0   := NJ0->(GetArea())
    Local aAreaN9A   := N9A->(GetArea())
    Local cWhere     := ""
    Local cAliasQry  := GetNextAlias()
    Local dVctoFim   := nil    
    Local cCodClient := ""
    Local cCodLoja   := ""
    Local cFilNJ0    := ""
    Local lIsBlind   := IsBlind()
    Local aRetorno   := {}

    Private aLog     := {}    
    
    Default nQtdDias := 0    

    //LIMPA CACHE MOEDA DA FUNÇÃO XMOEDA
    LimpaMoeda()    
    
    lNJ0Excl := FWModeAccess("NJ0", 3) == "E" //exclusiva?        

    If !Empty(cFilialFin)
        cWhere += iif(!Empty(cWhere)," AND ", "")
        cWhere += "NJR.NJR_FILIAL BETWEEN '" + cFilialIni + "' AND '" + cFilialFin + "'"
    EndIf

    If !Empty(cCtrFim)
        cWhere += iif(!Empty(cWhere)," AND ", "")
        cWhere += "NJR.NJR_CODCTR BETWEEN '" + cCtrIni + "' AND '" + cCtrFim + "'"
    EndIf

    If !Empty(cEntidFim)
        cWhere += iif(!Empty(cWhere)," AND ", "")
        cWhere += "NJR.NJR_CODENT BETWEEN '" + cEntidIni + "' AND '" + cEntidFim + "'"
    EndIf

    If !Empty(cLojaFim)
        cWhere += iif(!Empty(cWhere)," AND ", "")
        cWhere += "NJR.NJR_LOJENT BETWEEN '" + cLojaIni + "' AND '" + cLojaFim + "'"
    EndIf

    If !Empty(cProdFim)
        cWhere += iif(!Empty(cWhere)," AND ", "")
        cWhere += "NJR.NJR_CODPRO BETWEEN '" + cProdIni + "' AND '" + cProdFim + "'"
    EndIf

    If !Empty(cSafraFim)
        cWhere += iif(!Empty(cWhere)," AND ", "")
        cWhere += "NJR.NJR_CODSAF BETWEEN '" + cSafraIni + "' AND '" + cSafraFim + "'"
    EndIf

    If lIsBlind
	    dVctoFim := DaySum( dDatabase , nQtdDias) //Soma Dias em Uma Data
	
	    cWhere += iif(!Empty(cWhere)," AND ", "")
	    cWhere += " NN7.NN7_DTVENC BETWEEN '"+ dtos(dDatabase) + "' AND '" + dtos(dVctoFim) + "'"       
	Endif

    If Empty(cWhere)
        cWhere := " 1 = 1 "
    EndIf   

    cWhere := "%"+cWhere+"%"
    
    BeginSQL Alias cAliasQry
        SELECT DISTINCT NJR_FILIAL, NJR_CODCTR, NJR_CODENT, NJR_LOJENT, NJR_TIPO
          FROM %table:NJR% NJR
         INNER JOIN %table:NN7% NN7 ON NN7.NN7_FILIAL = NJR.NJR_FILIAL AND NN7.NN7_CODCTR = NJR.NJR_CODCTR AND NN7.%notDel%
         WHERE %Exp:cWhere%
           AND NJR.NJR_STATUS IN ('A', 'I') // Aberto, Iniciado
           AND NJR.NJR_TIPMER = '1'
           AND NJR.NJR_MOEDA > 1
           AND NJR.%notDel%
    EndSql      
    
    (cAliasQry)->(dbGoTop())
    While (cAliasQry)->(!Eof())        
        BEGIN TRANSACTION 
        //busca as informações de Cliente - verifciar se não vai ser da NNY ou N9A
        lAltVal := .F.

        Iif(lNJ0Excl, cFilNJ0 := (cAliasQry)->NJR_FILIAL, cFilNJ0 := xFilial("NJ0"))        
        
        NJ0->(DbSetOrder(1))
        If NJ0->(DbSeek(cFilNJ0+(cAliasQry)->NJR_CODENT+(cAliasQry)->NJR_LOJENT))			
            if (cAliasQry)->NJR_TIPO == "1" //Compras - fornecedor
                cCodClient     := NJ0->(NJ0_CODFOR)
                cCodLoja       := NJ0->(NJ0_LOJFOR)				
            else //vendas - cliente
                cCodClient     := NJ0->(NJ0_CODCLI)
                cCodLoja       := NJ0->(NJ0_LOJCLI)				
            endif
        EndIf	        
                     
        OGX018((cAliasQry)->NJR_FILIAL, (cAliasQry)->NJR_CODCTR, .F.) 

        aRetorno := OGX018ATPR((cAliasQry)->NJR_FILIAL, (cAliasQry)->NJR_CODCTR)
        
        If !aRetorno[1,1]
            If lIsBlind
                AddLogJob(.F., (cAliasQry)->NJR_CODCTR, "",  "", aRetorno[1,2])                                    
            Else
                MsgInfo(aRetorno[1,2])
            EndIf
            DisarmTransaction()                                
        EndIf        
    
        (cAliasQry)->(dbSkip())
        
        END TRANSACTION
    Enddo

    (cAliasQry)->(dbCloseArea())
    
    If lIsBlind
    	AddLogJob(.T.)   
    	GeraLogJob(cDirLog)
    EndIf    
    
    FwFreeObj(aRetorno)
    FWFreeObj(aLog)

    RestArea(aAreaNJR)    
    RestArea(aAreaNJ0)    
    RestArea(aAreaN9A)    

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AddLogJob
    Função responsável por adicionar os log de processamento do schedule
    @type  Static Function
    @author rafael.voltz
    @since 02/05/2018
    @version version
    @param lFim,      boolean, Indica se é o fim do log
           cCtr,      char, Código do contrato
           cPrevEnt,  char, Previsão de Entrega
           cRegra,    char, Regra Fiscal
           cErro,     char, Descrição do erro                      
    @return .T., booelan
    @example
    (examples)
    @see (links_or_references)
    /*/    
//-------------------------------------------------------------------    
Static Function AddLogJob(lFim, cCtr, cPrevEnt, cRegra, cErro)
    
    Local cMsg := ""

    Default lFim  := .F.
    Default cErro := ""

    If lFim 
        If Len(aLog) > 0
            cMsg += STR0004 + " " + Time() + CRLF //Hora fim
            cMsg += "***** " + STR0005 +" ******"   + CRLF  + CRLF  //"FIM PROCESSAMENTO - ATUALIZAÇÃO PREVISÃO FINANCEIRA"                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
        EndIf
    Else
        If Len(aLog) == 0
            cMsg += "***** "+ STR0006 +" ******" + CRLF //INÍCIO PROCESSAMENTO - ATUALIZAÇÃO PREVISÃO FINANCEIRA
            cMsg += STR0007 + " " + dtos(dDatabase) + CRLF //Data:
            cMsg += STR0008 + " " + Time()  + CRLF      //Hora Início:      
       EndIf
        cMsg += STR0009 + " " + Alltrim(cCtr) + " | " + STR0010 + " " +  Alltrim(cPrevEnt) + " | " + STR0011  + " " +  Alltrim(cRegra) + " | " + STR0012 + " " +  Alltrim(cErro) + CRLF            //Contrato,  Prev. Entrega, Regra fiscal, Mensagem
    EndIf

    aAdd(aLog,OemToAnsi(cMsg))

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraLogJob
Gera em disco o arquivo de log referente a execução do Job
@author  rafael.voltz
@since   02/05/2018
@version version
/*/
//-------------------------------------------------------------------
Static Function GeraLogJob(cDirLog)            
    Local nHandle  := 0
    Local nX       := 0    
    Local cNameArq := ""
    
    Default cDirLog := "\log\"
    
    If len(aLog) > 0 .and. !Empty(cDirLog)
        If Right(cDirLog, 1) != "\" .or. Right(cDirLog, 1) != "/"
            Iif (IsSrvUnix(), cDirLog += "/", "\")                
        EndIf

        cNameArq := Alltrim(cDirLog)+"AtuPrvFinAgro_"+dtos(dDatabase)+".log"

        nHandle := fopen(cNameArq, FO_READWRITE + FO_SHARED )        
        If nHandle == -1
            nHandle := FCreate(cNameArq ,0,,.F.) 
            If FERROR() == 430  .OR. FERROR() == 161 //The system cannot find the specified path.
                MakeDir(cDirLog)
                nHandle := FCreate(cNameArq,0,,.F.) 
            EndIf
        EndIf

        If nHandle == -1
            conout(STR0003 + " " +str(ferror(),4)) //Erro ao criar arquivo de Log - AtuPrvFinAgro : FERROR
        Else
            For nX := 1 to Len(aLog)                        
                FSEEK(nHandle, 0, FS_END)
                FWrite(nHandle,aLog[nX],Len(aLog[nx]))   
            Next
        EndIf   
        
        FClose(nHandle)          
    EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX065DIR
Função responspavel por abrir popup para seleção de arquivo.
@author  Rafael Voltz
@since   21/03/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGX065DIR( cCPO )        
	Local cRET  := cGetFile("" ,STR0002, , , .F.,  GETF_RETDIRECTORY  , .T.) //Diretório de Log

    If !Empty(cRET)
		&(cCPO) := cRET   
	EndIf
    
Return (!Empty(cRET))

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX065VLD
Valida se o diretório existe.
@author  Rafael Voltz
@since   21/03/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGX065VLD(cCPO)

    If !Empty(cCPO)
        If !ExistDir(cCPO)
            MsgInfo(STR0001) // "Diretório inválido."
            Return .F.
        EndIf
    EndIf

Return .T.