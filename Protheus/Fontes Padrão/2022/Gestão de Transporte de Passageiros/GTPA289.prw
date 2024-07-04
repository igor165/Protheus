#Include "GTPA289.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aG289Log	:= {}	//Array de log de erro de processamento
Static cG289Dir := ""

/*/{Protheus.doc} GA284UpdStatus()
    Atualiza os Status das requisições de acordo com o status recém atualizado do lote
    @type  Function
    @author Fernando Radu Muscalu
    @since 23/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPA289()

Local cTable    := ""
Local cTime		:= ""
Local lOk       := .f.
Local lEstorno  := .f.

If ( Pergunte("GTPA289",.t.) ) 
	
	CursorWait()
	
	cTime := Time()
	
    lEstorno := Iif(MV_PAR09 == 1,.F.,.T.)

    lOk := GA289Query(@cTable,lEstorno)//FWMsgRun( ,{|| lOk := GA289Query(@cTable,lEstorno) },,STR0001) //"Separando Lote(s)..."

    If ( lOk )
        lOk := GA289RunProc(cTable,lEstorno)//FWMsgRun( ,{|| lOk := GA289RunProc(cTable,lEstorno) },,STR0002) //"Gerando Pedido(s) de Vendas..."
        (cTable)->(DbCloseArea())
    EndIf
    
	CursorArrow()
	
	If ( Len(aG289Log) > 0 )
		FwAlertInfo(STR0012 + Alltrim(cG289Dir), STR0011) //"O processamento, finalizou, mas ocorreram problemas." //"Para maiores informações, consulte os arquivos de log gerados através do diretório "
	Else		
		FwAlertInfo("Processamento finalizado com sucesso!","Finalizado")//FwAlertInfo(ElapTime(cTime,Time()),"Tempo de Processamento")
	EndIf	
	
EndIf

aG289Log := {}	

Return()

/*/{Protheus.doc} GA289Query
    Efetua o filtro dos dados digitados pelo usuário na interface de parametrização (Pergunte)
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 26/06/2017
    @version version
    @param cTable, caractere, Passado por referência, será o nome da tabela
    @return lRet, lógico, .t. - o resultset possui dados
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA289Query(cTable,lEstorno)

Local cStatus   := IIf(!lEstorno,"2","1")   //"2", se for geração, ou "1" se for estorno

Local lRet      := .t.

cTable := GetNextAlias()

BeginSQL Alias cTable

    SELECT
        DISTINCT
        R_E_C_N_O_ GQY_RECNO
    FROM
        %Table:GQY% GQY
    WHERE
        GQY_FILIAL = %XFilial:GQY%    
        AND GQY_CODIGO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
        AND GQY_CODCLI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR05%
        AND GQY_CODLOJ BETWEEN %Exp:MV_PAR04% AND %Exp:MV_PAR06%
        AND GQY_DTEMIS >= %Exp:MV_PAR01% 
        AND GQY_DTFECH <= %Exp:MV_PAR02%
        AND GQY_STATUS = %Exp:cStatus%
        AND GQY.%NotDel%

EndSQL

 lRet := (cTable)->(!Eof()) 

Return(lRet)

/*/{Protheus.doc} GA289RunProc
    Efetua o filtro dos dados digitados pelo usuário na interface de parametrização (Pergunte)
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 26/06/2017
    @version version
    @param cTable, caractere, Passado por referência, será o nome da tabela
    @return lRet, lógico, .t. - o resultset possui dados
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA289RunProc(cTable, lEstorno)

Local lRet      := .t.

While ( (cTable)->(!Eof()) )
    
    GQY->(DbGoto((cTable)->GQY_RECNO))

    lRet := GA284IntFat(lEstorno,.F.)

    If ( !lRet )

		GA289SetLog()	//Prepara o array estático aG289Log com os dados do log de erro     
		GA284ResetLog() //reinicia o log para o processamento do próximo lote

    EndIf

    (cTable)->(DbSkip())

EndDo

If (!lRet)
	GA289LogArchive()
EndIf	

Return(lRet)

/*/{Protheus.doc} GA289SetLog
    Adiciona dados do log de erro ao array estático aG289Log
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 29/06/2017
    @version version
    @param	cLogName, caractere, nome do arquivo de log de erros
    		cFilLog, caractere, código da filial que gerou o erro
    		cCodLot, caractere, código do lote que teve log de erro durante o processamento
    		cClient, caractere, código do cliente que teve log de erro durante o processamento
    		cLjCli, catactere, código da loja do cliente que teve log de erro durante o processamento
    		nTotalLot, numérico, valor total do lote
    @return nil, nulo, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA289SetLog(cLogName,cFilLog,cCodLot,cClient,cLjCli,nTotalLot)

Default cLogName	:= "LOTE_" + Alltrim(GQY->GQY_CODIGO) + "_" + DtoS(Date())+StrTran(Time(),":","") 	
Default cFilLog		:= GQY->GQY_FILIAL
Default cCodLot		:= GQY->GQY_CODIGO 	
Default cClient		:= GQY->GQY_CODCLI
Default cLjCli		:= GQY->GQY_CODLOJ
Default nTotalLot	:= GQY->GQY_TOTAL

aAdd(aG289Log,{ cFilLog,;       //Filial
                cCodLot,;       //Número do Lote
                cClient,;       //Código do Cliente
                cLjCli,;       //Loja do Cliente
                nTotalLot,;        //Total do Lote    
                aClone(GA284GetLog()),;	//Log gerado pela função GA284IntFat() 
                cLogName })//Array com o log de Erros

Return()

/*/{Protheus.doc} GA289SetLog
    função que capta o array estático, veja o campo return
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 29/06/2017
    @version version
    @param	
    @return nil, nulo, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA289GetLog()

Return(aG289Log)

/*/{Protheus.doc} GA289LogArchive
    Gera os arquivos fisicamente em disco, por lote, com os logs contidos no array aG289Log
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 29/06/2017
    @version version
    @param	
    @return aG289Log, array, array estático de log de erro de processamento
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA289LogArchive()

Local oFWriter

Local cLinha    := ""

Local nI		:= 0
Local nX		:= 0

If ( Len(aG289Log) > 0 )

    cG289Dir := "C:\SIGAGTP\Requisição\Logs de Erros"
    
    FwMakeDir(cG289Dir)
    
    //Varredura de todos os lotes e seus logs de erros
    For nI := 1 to Len(aG289Log)
        
        oFWriter := FWFileWriter():New(cG289Dir + "\" + Alltrim(aG289Log[nI,7]) ,.t.)

        If ( oFWriter:Create() )

            cLinha := STR0003 + Chr(13) + Chr(10) //"Erro na tentativa de integrar o Lote!"
            
            If ( !Empty(aG289Log[nI,1]) )
                cLinha += STR0004 +  Alltrim(aG289Log[nI,1]) + Chr(13) + Chr(10) //"Filial: "
            EndIf

            cLinha += STR0005 + Alltrim(aG289Log[nI,2]) + Chr(13) + Chr(10) //"Lote: "
            cLinha += STR0006 + Alltrim(aG289Log[nI,3]) + "/" + Alltrim(aG289Log[nI,4]) + Chr(13) + Chr(10) //"Cliente/Loja: "
            cLinha += STR0007 + Transform(aG289Log[nI,5],PesqPict("GQY","GQY_TOTAL")) + Chr(13) + Chr(10) //"Total do Lote: "
            cLinha += Replicate("-",150) + Chr(13) + Chr(10)
            
            lRet := oFWriter:Write(cLinha + Chr(13) + Chr(10)) 

            If ( lRet )
            
                //Linha do Cabeçalho
                cLinha := PadR(STR0008, 10) //"Data"
                cLinha += Space(3)
                cLinha += PadR(STR0009,10) //"Horário"
                cLinha += Space(3)
                cLinha += STR0010 //"Detalhamento"

                lRet := oFWriter:Write(cLinha + Chr(13) + Chr(10))  //imprime a linha no arquivo

            EndIf
            
            If ( lRet )

                //Varre os logs do Lote
                For nX := 1 to Len(aG289Log[nI,6])

                    cLinha := DToC(aG289Log[nI,6][nX,1])    //Data
                    cLinha += Space(3)                  //Espaçamento
                    cLinha += aG289Log[nI,6][nX,2]          //Horário
                    cLinha += Space(3)                  //Espaçamento
                    cLinha += Alltrim(aG289Log[nI,6][nX,3]) //Detalhamento do log

                    lRet := oFWriter:Write(cLinha + Chr(13) + Chr(10))

                    If ( !lRet )                    
                        MsgInfo(oFWriter:Error():Message)
                        Exit
                    Endif

                Next nX

            EndIf    

            If ( !lRet )                    
                MsgInfo(oFWriter:Error():Message)
                Exit
            Endif

        EndIf
        
        oFWriter:Close()

    Next nI        
    
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GA289GetPath()
retorna o array estático cG289Dir com o caminho do diretório de logs
@author  Renan Brando
@since   29/06/2017
@version version
/*/
//-------------------------------------------------------------------
Function GA289GetPath()

Return(cG289Dir)