#INCLUDE "LOJA900E.ch"
#Include 'TOTVS.CH'

Static lCamposST := nil
//-------------------------------------------------------------------
/*/{Protheus.doc} U_ECOM006
Função de teste integracao Protheus e-commerce CiaShop envio de Status de Pedido
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900
/*/
//-------------------------------------------------------------------

User Function ECOM010 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja900E(aParam)
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900E
Função de teste integracao Protheus e-commerce CiaShop envio de Status de Pedido
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900()
/*/
//-------------------------------------------------------------------
Function LOJA900E(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA900E" //Rotina
Local lLock := .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local lBuildJson := GetBuild() >= "7.00.131227A-20161110"
Local cMsg := "Para a funcionalidade de comunicação por API, faz-se necessário a atualização do Build, com versão igual ou superior à 7.00.131227A-20161110"
Local cName := "" //Chave de travamento
Local cMessage := ""

If Valtype(aParam) != "A" 
	_cEmp := cEmpAnt
	_cFil := cFilant
	
	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf
Else

	_lJob :=  .T.
	_cEmp := aParam[1]
	_cFil := aParam[2]
EndIf

If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf

If lCamposST == NIL

	lCamposST := ( SL1->(ColumnPos("L1_ECSTATU") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECSTATU") > 0 ) ) .AND. ;
				    ( SL1->(ColumnPos("L1_ECRASTR") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECRASTR") > 0 ) )
EndIf

If !lBuildJson
	If !IsBlind()
		MsgAlert(cMsg)
	Else
		Lj900XLg("**** IMPORTANTE ****** " + cMsg)
	EndIf
EndIf

//Gera SEMAFORO - para não dar erro de execução simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt

lLock := oLJCLocker:GetLock( cName )

If lLock

	If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
		If  !lCallStack .AND. !Lj904IntOk(.T., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf

	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
	Lj900EPr(_lJob, lCallStack, lBuildJson)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]")
	EndIf

	Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF

// chama rotina de cancelamento/aprovação de pedido de venda
Lj900XLg('... iniciando rotina de cancelamento e aprovação pedido de venda Ciashop ....')

If lBuildJson .AND. ExistFunc("LOJA901I")
	LOJA901I(aParam) // {_cEmp,_cFil}
EndIf

Lj900XLg('... termino rotina de cancelamento e aprovação pedido de venda Ciashop ....')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900EPr(lAJob, lCallStack)
Função de teste integracao Protheus e-commerce CiaShop envio de Status de Pedido
@param   	lAJob- Execução em Job - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CPr(lAJob)
/*/
//-------------------------------------------------------------------
Function Lj900EPr(lAJob, lCallStack, lBuildJson)

local cXML 			:= "" //XML de Envio
Local oWS			:= NIL //Objeto WebService
local cAlias 		:= "" //Alias da Consulta  
local cSeq     		:= "" //Sequencia de Execução da Rotina
local lErro    		:= .F. //Erro de Envio do WS
local cRetorno 		:= ""  //XML de Retorno    
local cAux  	 	:= "" //Variavel Auxiliar
Local cPasso		:= "" //Passo
Local aVltPas		:= {}	//Array com o RECNO da SC5 para limpar campo C5_VOLTAPS
Local nX			:= 0 //Contador
Local cMetEnt		:= "" //Metodo de Entrega
Local dDataIni 		:= Date() //Data Inicial do Job
Local cHoraIni 		:= Time() //Hora Inicial do Job
Local cC5_TRANSP 	:= "" //Chave do Frete
Local cXMLEnv 		:= "" //XML de Envio
Local aPedEnvNFE 	:= {}	// pedidos faturados que terão os dados na NFE enviados para CiaShop
Local aFilLoc  		:= IIF( ExistFunc("LOJX904Loc") , LOJX904Loc(), { {cFilAnt, {}} }) //Locais de Estoque EC
Local lMultEst 		:= Len(aFilLoc) > 1 .OR. ( Len(aFilLoc) = 1 .AND. Len(aFilLoc[1]) > 1 .AND.  Len(aFilLoc[01, 02]) > 0)  //MultiEstoque habilitado
Local cFilMGU		:= ""
Local lMGUFilPed	:= MGU->(ColumnPos("MGU_FILPED")) > 0
Local cAliasTmp2	:= GetNextAlias()
Local cPedEC		:= "" 
Local nTamPedEco 	:= MGU->(TamSx3("MGU_PEDECO")[1])
Local oTempTable	:= Nil //Objeto tabela temporaria
Local nCountPed		:= 0
Local cChave        := ""
Local lRet          := .T.
Local cStatFat		:= AllTrim(SuperGetMv("MV_LJECST1",.F., "30"))
Local aAreaSF2		:= SF2->(GetArea())
Local lLjToken		:= SLJ->(ColumnPos("LJ_TOKEN")) > 0
Local aDadosSl1		:= {}
Local aStProc	    := {} //Status dos Pedidos processados
Local nRecSC5		:= 0
Local cStatEnv 		:= SuperGetMv("MV_LJECSTF",,"30")
Local aUrlToken		:= {}
Local aHeadStr 		:= {}
Local cLogProc		:= ""   //Log de Processamento
Local cChaveSF2     := ""
Local lEnviada      := .F.                                  //Define se a nota já existe no e-commerce
Local nQtdStPe      := SuperGetMv("MV_LJQSTPE", .F., 10)    //Quantidade maxima do lote de pedidos enviados ao e-commerce para atualização de status.
Local aRetStaPed    := {}                                   //Retorno da função de atualização de status na CiaShop

DEFAULT lAJob 		:= .F.
Default lCallStack 	:= .F.
Default lBuildJson 	:= .F.

SF2->(DbSetOrder(1))	// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

cAlias  := GetNextAlias()

//Consulta os pedidos que deverão ser atualizados
Lj900EPE(cAlias, lCallStack,oTempTable)

//Resultado da sincronização
cSeq := GETSXENUM("MGM","MGM_SEQ")
CONFIRMSX8()

//Log de registros enviados
dbSelectArea("MGT")

dbSelectArea("SC5")
SC5->(dbSetOrder(1))

If (cAlias)->( Eof() )
    cRetorno := STR0035     //"Não existe pedidos para atualizar o status."
Else

    //Carrega os dados para acessoa ao web-services da CiaShop
    oWS := Lj904Ws()

    While !(cAlias)->( Eof() )

        lRet      := .T.
        nRecSC5   := 0
        lEnviada  := .F.

        SET DELETED OFF 
        
            SC5->( DbSeek((cAlias)->C5_FILIAL + (cAlias)->C5_NUM) )

            cC5_TRANSP := SC5->C5_TRANSP 
            cMetEnt    := ""
            cFilMGU    := cFilAnt
            cPedEC	   := PadL(AllTrim((cAlias)->C5_PEDECOM),nTamPedEco) 
            nRecSC5    := SC5->(Recno())

        SET DELETED ON
        
        cFilMGU := cFilAnt
        If lMultEst .AND. lMGUFilPed
                
            //Localiza a Filial para qual foi gerado o Pedido de Venda
            BeginSql alias cAliasTmp2
                SELECT 
                    MGU.MGU_FILPED
                FROM %table:MGU% MGU
                WHERE
                    MGU.MGU_PEDECO = %exp:cPedEC% AND
                    MGU.%NotDel% AND
                    MGU.MGU_FILIAL  = %xFilial:MGU%  AND
                    MGU.MGU_CONFIR = '1'
                    ORDER BY MGU_FILPED				
            EndSql
            
            (cAliasTmp2)->(DbGoTop())
            If (cAliasTmp2)->(!Eof()) .AND. !Empty((cAliasTmp2)->MGU_FILPED)
                cFilMGU := (cAliasTmp2)->MGU_FILPED
            EndIf
            (cAliasTmp2)->(DbCloseArea())
        EndIf
        
        If !Empty(cC5_TRANSP)	
            cMetEnt := GetAdvFVal("SA4","A4_ECSERVI",xFilial("SA4", cFilMGU)+ cC5_TRANSP, 1, cC5_TRANSP)
        EndIf
        
        If lBuildJson .AND. lLjToken .AND. !Empty((cAlias)->C5_NOTA) .AND. ( ( RTrim((cAlias)->C5_STATUS) == cStatFat  .AND. Empty((cAlias)->C5_RASTR)) .OR. ;
                                                                            ( RTrim((cAlias)->C5_STATUS) == cStatEnv .AND. !Empty((cAlias)->C5_RASTR)))  //envia status da nota
            //Nota Fiscal Emitida, verifica se a mesma foi transmitida NFe
            //Se não foi transmitida, não envia o status até transmitir
            //cChaveSF2 := (cAlias)->C5_FILIAL + (cAlias)->C5_NOTA + (cAlias)->C5_SERIE     //Retorno a forma antiga de localizar a nota
            cChaveSF2 := xFilial("SF2", cFilMGU) + (cAlias)->C5_NOTA + (cAlias)->C5_SERIE
            lRet      := SF2->( DbSeek(cChaveSF2) ) .And. !Empty(SF2->F2_CHVNFE)
            
            If !lRet
                lErro    := .T.
                cLogProc += CRLF + I18n(STR0036, {cChaveSF2})   //"Nota não encontrada ou chave NFE não preenchida. Registro SF2 (#1)"
            Else

                //Envia o Json da Nota Fiscal
                If lBuildJson .AND. lLjToken
                    lRet := LJ900ENNFE( ,@aUrlToken, @aHeadStr, @cLogProc, @lEnviada)

                    If !lRet
                        lErro    := .T.
                        cLogProc += CRLF + I18n(STR0037, {cChaveSF2})   //"Erro ou enviar dados da nota para o E-commerce. Registro SF2 (#1)"
                    EndIf
                EndIf
            EndIf
        EndIf
        
        If lRet
            SET DELETED OFF
                SC5->(DbGoTo(nRecSC5))
        
                //Inclui na tabela SZ2 (Log)
                RecLock("MGT", .T.)
                MGT->MGT_FILIAL  := xFilial("MGT")
                MGT->MGT_SEQ     := cSeq
                MGT->MGT_PEDIDO  := (cAlias)->C5_NUM
                MGT->MGT_STATUS  := (cAlias)->C5_STATUS
                MGT->MGT_RASTR   := (cAlias)->C5_RASTR 
                MGT->MGT_PEDECO  := (cAlias)->C5_PEDECOM
                MGT->MGT_METENT  := cMetEnt
                MGT->(MsUnLock())
                
                //Montagem do XML
                cXML += '<receipt_status '
                
                //Reservado
                cXML += ' xmlns=""'
                
                //Operação: I - Incluir
                //          D - Deletar
                cXML += ' op="' +   'I'  + '"'     
                
                //Pedido (código da CiaShop)
                cXML += ' order_id="' + AllTrim((cAlias)->C5_PEDECOM) + '"'     	
                
                //Verifica se eh para voltar o passo
                If AllTrim(SC5->C5_VOLTAPS) == "1"

                    Lj900XLg( I18n(STR0038, {MGT->MGT_PEDECO, MGT->MGT_STATUS}) )   //"Volta passo ativo, pedido e-commerce #1 status #2"
                    
                    cPasso := "-1"
                    AAdd(aVltPas, SC5->( Recno() ) )
                    
                    //Atualiza Status MGT
                    RecLock("MGT", .F.)
                    
                    If MGT->MGT_STATUS == "05"	
                        MGT->MGT_STATUS := "00"	
            
                    ElseIf MGT->MGT_STATUS == "10"	
                        MGT->MGT_STATUS := "05"
                    
                    ElseIf MGT->MGT_STATUS == "15"
                        MGT->MGT_STATUS := "10"
                    
                    ElseIf MGT->MGT_STATUS $ "21|30|90|91"	
                        MGT->MGT_STATUS := "15"			
                    EndIf

                    MGT->( MsUnLock() )

                    Lj900XLg( I18n(STR0038, {MGT->MGT_PEDECO, MGT->MGT_STATUS}) )  //"Volta passo ativo, pedido e-commerce #1 status #2"
                EndIf 

                cPasso := AllTrim(MGT->MGT_STATUS)
                
                If lCamposST .AND. !Empty((cAlias)->REGISTRO)
                    aAdd( aDadosSl1, {(cAlias)->REGISTRO, cPasso, MGT->MGT_RASTR} )
                EndIf 

                //Status de pagamento aprovado e cancelado são retornados pela plataforma, por isso devemos enviar para ciashop tirá-los da fila de status de pedidos                
                If Alltrim(MGT->MGT_STATUS) $ "10|90|91" 
                    aAdd(aStProc, Val((cAlias)->C5_PEDECOM)) 
                EndIf   
        
            SET DELETED ON
            cXML += ' passo="' + cPasso + '"'  
            
            //Mensagem enviada ao comprador   
            cAux := ""
            do case
                case cPasso == "-1" 
                    cAux := STR0007  //"Volta passo."
                case cPasso == "05" 
                    cAux := STR0008 	 //"Pedido em analise."
                case cPasso == "10" 
                    cAux := STR0009  //"Pagamento confirmado preparando envio."
                case cPasso == "15" 
                    cAux := STR0010  //"Pedido em embalado."
                case cPasso == "21" 
                    cAux := STR0011  //"Pedido parcialmente enviado. Aguardando recebimento dos demais produtos para envio total."
                case cPasso == "30" 
                    cAux := STR0012 //"Pedido enviado."
                case cPasso == "90" 
                    cAux := STR0013  //"Pedido Cancelado."
                case cPasso == "91" 
                    cAux := STR0014 	 //"Pedido Devolvido."
            endcase
                
            cXML += ' status_shopper="' + cAux + '"'  	
            
            //Status p/ o lojista 
            cAux := ""	
            do case
                case cPasso == "-1" 
                    cAux := STR0007  //"Volta passo."
                case cPasso == "05" 
                    cAux := STR0008  //"Pedido em analise."
                case cPasso == "10" 
                    cAux := STR0015  //"Pagamento confirmado, preparar envio."
                case cPasso == "15" 
                    cAux := STR0010  //"Pedido em embalado."
                case cPasso == "21" 
                    cAux := STR0011  //"Pedido parcialmente enviado. Aguardando recebimento dos demais produtos para envio total."
                case cPasso == "30" 
                    cAux := STR0012 //"Pedido enviado."
                case cPasso == "90" 
                    cAux := STR0013  //"Pedido Cancelado."
                case cPasso == "91" 
                    cAux := STR0014 	 //"Pedido Devolvido."
            endcase
                
            cXML += ' status_adm="' + cAux + '"'  
            
            //Código para rastreabilidade
            If !Empty((cAlias)->C5_RASTR)
                cXML += ' rastreamento="' + AllTrim(_NoTags((cAlias)->C5_RASTR)) + '"'  		
            EndIf
            
            //Enviar email?
            cXML += ' sendMail="' + IIF(lEnviada, "0", "1") + '"'   //0 não envia e-mail \ 1 envia e-mail
        
            If !Empty(cMetEnt)
                cXML += ' shipping_method="' + cMetEnt + '"' 	
            EndIf
            
            //Encerra tag do status do pedido
            cXML += '/>'
                    
            //Contador para controle de quantidade de pedidos que devem ser enviados
            nCountPed++
            If nCountPed >= nQtdStPe
            
                If !Empty(cXML)
                    cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>' +;
                    '<receipt_statusList xmlns="dsReceipt.xsd">' +;
                    cXML +;
                    '</receipt_statusList>'

                    //Atualiza o status dos pedidos na CiaShop
                    aRetStaPed := StatusPed(oWs, cXML, lAJob)
                    lErro      := aRetStaPed[1]
                    cRetorno   := aRetStaPed[2]
                    cXMLEnv    := aRetStaPed[3]
                EndIf
                
                //Atualiza Status do SC5 e SL1 e Rastreio do SL1
                If !lErro
                    AtuStaRas(aVltPas, aDadosSl1)
                EndIf		
            
                nCountPed := 0  //Zero o contador para criar uma nova remessa
                cXML      := "" //Limpo o arquivo para criação de uma nova remessa   
                aVltPas   := {} //Zero a varivel de passo anterior
                aDadosSl1 := {} //Zero array de orçamentos enviados
            EndIf
        EndIf
        (cAlias)->(DBSkip())
    Enddo

EndIf

If !Empty(cXML)
	cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>' +;
	'<receipt_statusList xmlns="dsReceipt.xsd">' +;
	cXML +;
	'</receipt_statusList>'

    //Atualiza o status dos pedidos na CiaShop
    aRetStaPed := StatusPed(oWs, cXML, lAJob)
    lErro      := aRetStaPed[1]
    cRetorno   := aRetStaPed[2]
    cXMLEnv    := aRetStaPed[3]
EndIf

//Grava log de processamento
cRetorno := AllTrim( cRetorno + CRLF + Replicate("=", 70) + CRLF + IIF(!Empty(cLogProc), "Retornos API Invoices:" +  cLogProc, "") )

RecLock("MGM", .T.)
    MGM->MGM_FILIAL := xFilial("MGM")
    MGM->MGM_SERVIC := "LOJA900E"
    MGM->MGM_SEQ    := cSeq
    MGM->MGM_DATA   := dDataIni
    MGM->MGM_HORAIN := cHoraIni
    MGM->MGM_XMLENV := cXMLEnv
    MGM->MGM_XMLRET := cRetorno
    MGM->MGM_HORAFI := Time()
    MGM->MGM_RESULT := IIF(lErro, "2", "1")
MGM->(  MsUnLock() )

//Grava log de erro
If lErro
    Lj900XLg(cLogProc, cSeq)
EndIf

//Atualiza Status do SC5 e SL1 e Rastreio do SL1
If !lErro
    AtuStaRas(aVltPas, aDadosSl1)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apagando indice temporario.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If( ValType(oTempTable) == "O")
  oTempTable:Delete()
  FreeObj(oTempTable)
  oTempTable := Nil
EndIf

RestArea(aAreaSF2)

If lBuildJson .AND. !lErro .And. Len(aStProc) > 0 .And. lLjToken .AND. ExistFunc("LJI9JSON")
	// chama função para atualização dos status dos pedidos, para eles não voltarem
	//Gera o xml de log de atualização de Status
	//Resultado da sincronização
	cSeq := GETSXENUM("MGM","MGM_SEQ")
	CONFIRMSX8()

	// EC CIASHOP RESULT SINCRONIZACAO
	DbSelectArea("MGM")
	RecLock("MGM", .T.)
	MGM->MGM_FILIAL  := xFilial("MGM")
	MGM->MGM_SERVIC  := "LOJA901I"
	MGM->MGM_SEQ     := cSeq	
	MGM->MGM_DATA    := dDataIni
	MGM->MGM_HORAIN  := cHoraIni
	MGM->MGM_HORAFI := Time()
	MGM->(MsUnLock())
	LJI9JSON(cEmpAnt,cFilAnt,lAJob,cSeq, .T., .T., aStProc)
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900EPE
Função de teste integracao Protheus e-commerce CiaShop envio de deparamentos 
@param   	cAAlias - Alias da Consulta
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900EPE(cAAlias)
/*/
//-------------------------------------------------------------------
Static Function Lj900EPE(cAAlias, lCallStack,oTempTable)

Local cQuery 		:= "" //String de Consulta
Local nTamPedEcom	:= SC5->(TamSx3("C5_PEDECOM")[1]) //Tamanho do Pedido EC
Local cAliasTmp		:= GetNextAlias() //WorkArea Temporaria
Local nTamStatus	:= SC5->(TamSx3("C5_STATUS")[1])
Local cChave		:= "" //Chave de Busca do registro
Local aEstru		:= {} //Estrutua da Tabela
Local cArqTRB		:= "" //Arquivo temporario
Local nTotRec		:= 0 //Registros selecionados
Local cSqlFields	:= "" //Campos da consulta
Local nC			:= 0 //Contador de campos
Local nCampos 		:= 0 //total de Campos
Local nTamRastr 	:= SC5->(TamSx3("C5_RASTR")[1]) //Tamanho do código de Rastreio
Local lRet			:= .t. //Processa o pedido
Local cPedECom      := space(nTamPedEcom)

Default lCallStack 	:= .F.
Default oTempTable  := Nil //Objeto tabela temporaria


If !lCamposST

    Lj900XLg( I18n(STR0039, {"L1_ECSTATU|LQ_ECSTATU|L1_ECRASTR|LQ_ECRASTR"}) )      //"Campos de Status ou Rastro inexistentes (#1)"

	//Estrutura da tabela de Dados
	//necessária para a criação do indice
	aEstru := { 	{"C5_FILIAL", "C",  TamSX3("C5_FILIAL")[1], TamSX3("C5_FILIAL")[2] } ,;
					{"C5_NUM", "C",  TamSX3("C5_NUM")[1], TamSX3("C5_NUM")[2] } ,;
					{ "C5_PEDECOM", "C",  TamSX3("C5_PEDECOM")[1], TamSX3("C5_PEDECOM")[2]  },;
					{ "C5_STATUS", "C",  nTamStatus, TamSX3("C5_STATUS")[2]  },;
					{ "C5_RASTR", "C",  nTamRastr, TamSX3("C5_RASTR")[2]  },;
					{ "C5_NOTA", "C",  TamSX3("C5_NOTA")[1], TamSX3("C5_NOTA")[2]  },;
					{ "C5_SERIE", "C",  TamSX3("C5_SERIE")[1] , TamSX3("C5_SERIE")[2]  }}
					
	
	aEval(aEstru, { |e| cSqlFields := cSqlFields + e[1] + ", "}) //Campos da Query
	aAdd(aEstru, {"REGISTRO","N", 1, 0})
	nCampos := Len(aEstru)
	
	cQuery := " SELECT " + cSqlFields + " 0 AS REGISTRO " //C5_NUM, C5_PEDECOM, C5_STATUS, C5_RASTR "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 "
	cQuery += " WHERE   ( SC5.D_E_L_E_T_ <> '*' OR  ( SC5.D_E_L_E_T_  = '*' AND C5_STATUS = '90') ) "   
	cQuery += " AND ( C5_PEDECOM <> ' ' AND C5_PEDECOM  <> '"+space(nTamPedEcom)+ "')"   
	cQuery += " AND C5_STATUS <> '00' AND C5_STATUS <> '-1' "
	cQuery += " ORDER BY  C5_FILIAL, C5_NUM "
	
	cQuery := ChangeQuery(cQuery)  
	
	cArqTRB := CriaTrab(Nil, .F.)
	
	//Cria tabela temporaria
	oTempTable := LjCrTmpTbl(cAAlias, aEstru)
			
	IndRegua(cAAlias, cArqTRB, "C5_FILIAL+C5_NUM+C5_STATUS+C5_RASTR", , , "Selecionando registros ", .F.)
	(cAAlias)->(DbSetOrder(1))
	
	dbUseArea(.T., "TOPCONN",  TCGENQRY(,,cQuery) ,cAliasTmp, .F., .T.)
	(cAliasTmp)->(DbGoTop())
	
	While (cAliasTmp)->(!Eof())	
	
	
		cChave :=  Lj900ERETC((cAliasTmp)->C5_NUM, , ,(cAliasTmp)->C5_FILIAL)  // verifica se o status esta o mesmo


		lRet := !( cChave == (cAliasTmp)->C5_FILIAL + (cAliasTmp)->C5_NUM + (cAliasTmp)->C5_STATUS + (cAliasTmp)->C5_RASTR)		 

	
		If lRet 	
			 
			 RecLock(cAAlias, .t.)
			 
			 For nC := 1 to nCampos 
			 	 (cAAlias)->&(aEstru[nC, 01]) := (cAliasTmp)->&(aEstru[nC, 01])
			 Next nC
			 (cAAlias)->(MsUnLock())
			 nTotRec++
		 EndIf
		 (cAliasTmp)->(dbSkip(1))
	EndDo
	
	(cAliasTmp)->(DbCloseArea())
	
	(cAAlias)->(DbSeek(""))
	

	
Else
	//Executa a rotina migratória
    Lj900XLg("LOJA900E" + " Aguarde.... Executando rotina migratória")
	Lj900ESt(.f.)
	Lj900XLg("LOJA900E" + " Final rotina migratória")
	 
	
	//Após o processamento seleciona os pedidos que possuem alteração de status/Rastreio
	
	//Executa a query para selecionar os pedidos e-commerce que devem ser atualizados (possuem alteração de status)
	BeginSql alias cAAlias
		SELECT C5_FILIAL, C5_NUM, C5_PEDECOM, C5_STATUS, C5_RASTR, C5_NOTA, C5_SERIE, SL1.R_E_C_N_O_  AS REGISTRO
		FROM %table:SC5% SC5 INNER JOIN %table:SL1% SL1 
		    ON  ( SC5.C5_FILIAL = SL1.L1_FILRES AND SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC )       
		WHERE   C5_PEDECOM <> %exp:cPedECom%
		    AND C5_STATUS <> '00'
            AND C5_STATUS <> '-1'
		    AND ( SC5.D_E_L_E_T_ = ' ' OR  (SC5.D_E_L_E_T_  = '*' AND C5_STATUS = '90') )
		    AND L1_ECFLAG  = '1'
		    AND ( L1_ECSTATU  <>  C5_STATUS OR L1_ECRASTR <> C5_RASTR )
		ORDER BY  C5_FILIAL, C5_NUM 
	EndSql	
	
	nTotRec := Lj900XRC( cAAlias, "Lj900EPE" )
EndIf

If lCallStack 
	 Lj900XLg("LOJA900E" + " Registros selecionados " + cValTochar( nTotRec))
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900ERETC
Geração de uma query para retorar o Status do pedido para comparação dos Status,
caso seja o mesmo não envia enviar o registro pois não houve modificação. 
@param     cPedido - numero do pedido
@author    Varejo
@version   P11.8
@since     05/04/2017
@obs     
@sample    Lj900ERETC(cPedido)
/*/
//-------------------------------------------------------------------

Static Function Lj900ERETC(cPedido, lRetChave, cAliasTmp, cFilSC5 )
Local cQuery 	  := ""
Local cChave      := ""
Local nTamStatus  := 0
Local nTamRastr   := 0 //Tamanho do código de Rastreio
Local nTamPedEcom := SC5->(TamSx3("C5_PEDECOM")[1]) //Tamanho do Pedido EC
Local cPedECom := space( nTamPedEcom)

Default cAliasTmp   := "TRBSC5MGT" //Tabela Temporaria
Default lRetChave := .T.



	BeginSql alias cAliasTmp	
	
		SELECT 	 
			C5_FILIAL, MGT_PEDIDO, C5_PEDECOM, MGT_STATUS, MGT_RASTR, C5_NUM
		FROM %table:MGT% MGT, 
		 	%table:SC5% SC52 
		 	WHERE 	
		 	MGT_FILIAL = %xFilial:MGT%
		 	AND MGT.D_E_L_E_T_ <> '*' 
		 	AND MGT_SEQ =  ( 
							 SELECT MAX(MGT_2.MGT_SEQ) 
							 FROM  %table:MGT%  MGT_2 
							 INNER JOIN  %table:MGM% MGM_2 
							 ON MGM_2.MGM_FILIAL = MGT_2.MGT_FILIAL 
							 AND MGM_2.MGM_SEQ = MGT_2.MGT_SEQ 
							 AND MGM_2.D_E_L_E_T_ <> '*' 
							 AND MGM_2.MGM_RESULT = '1' 
							 WHERE MGT_2.MGT_FILIAL = %xFilial:MGT%
							 AND MGT_2.MGT_PEDIDO = MGT.MGT_PEDIDO 
							 AND MGT_2.MGT_PEDECO = MGT.MGT_PEDECO 
							 AND (MGT_2.MGT_STATUS <> 'LB' AND MGT_2.MGT_STATUS <> 'CF')
							 AND MGT_2.D_E_L_E_T_ <> '*' 
		 					)  
		 	AND MGT.MGT_PEDIDO = SC52.C5_NUM 
		 	AND (MGT.MGT_STATUS <> 'LB' AND MGT.MGT_STATUS <> 'CF')
		 	AND SC52.C5_PEDECOM = MGT.MGT_PEDECO 
		 	AND ( SC52.C5_PEDECOM <> ' ' AND SC52.C5_PEDECOM <>  %exp:cPedECom%)   
		 	AND SC52.C5_VOLTAPS <> '1' 
		 	AND ( SC52.D_E_L_E_T_ <> '*' OR  ( SC52.D_E_L_E_T_  = '*' AND SC52.C5_STATUS = '90') )    
		 	AND SC52.C5_STATUS <> '00' 
			AND SC52.C5_NUM  = %exp:cPedido%
			AND SC52.C5_FILIAL = %exp:cFilSC5%
		 	ORDER BY SC52.C5_PEDECOM 	
	EndSql	

	If lRetChave
		nTamStatus  := SC5->(TamSx3("C5_STATUS")[1])
		nTamRastr   := SC5->(TamSx3("C5_RASTR")[1]) //Tamanho do código de Rastreio	
		cChave := (cAliasTmp)->C5_FILIAL + (cAliasTmp)->C5_NUM + PadR((cAliasTmp)->MGT_STATUS, nTamStatus) + PadR((cAliasTmp)->MGT_RASTR, nTamRastr)
		(cAliasTmp)->(DbCloseArea())
	EndIf
	
	
Return (cChave)	
	

//-------------------------------------------------------------------
/*/{Protheus.doc} LJGERSON
Converte o arquivo para JSON
 
@Param String com Nome da Tabela
@Param Array com o nome dos campos
@Param Array com os itens do Array
 
@Return String
@author David Moraes
@since 22/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static function LJGERJSON(aGeraJSon)

Local cJSON  := ""                   
Local aCab   := aGeraJSon[1]  
Local aLin   := aGeraJSon[2]
Local nX, nY  
Local oObjJSON := JsonObject():New()

For nY := 1 to len( aLin )
    for nX := 1 to Len( aCab ) 
    	oObjJSON[aCab[nX]]	:= aLin[nY][nX]
     Next
Next

cJSON := FWJsonSerialize(oObjJSON)

FreeObj(oObjJSON)
 
Return cJSON

//-------------------------------------------------------------------
/*/{Protheus.doc} LJCONCIS
Função de teste e conecção Protheus e-commerce CiaShop  
@param   	aParam - 
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@obs     
@sample LJCONCIS()
/*/
//-------------------------------------------------------------------
Function LJCONCIS(_cEmp,_cFil,_lJob, cPedTeste)
Local _lRet := .F.
Local _cUrl := ""
Local _cGet := ""
Local cRetorno := ""
Local cGetParms 	:= ""
Local nTimeOut 	:= 200	// seguntos
Local aHeadStr 	:= {}	// {"Content-Type: application/json"}
Local cHeaderGet 	:= ""
Local oObjJSon	:= ""
Local cUrlCiaSh   	:= ""
Local cToken        := ""
Local aUrlToken     := {}  // Retorno da Função para a Url e a String do Token
Local cHttpStat		:= ""
Local nHttpStat		:= 0

Default _cEmp := cEmpAnt
Default _cFil := cFilAnt 
Default cPedTeste := ""

If ExistFunc("LOJX904CUT")
	aUrlToken  	:= LOJX904CUT(_cEmp,_cFil)
	cUrlCiaSh   := aUrlToken[1]
	cToken      := aUrlToken[2]
EndIf	

If !Empty(cUrlCiaSh) .AND. !Empty(cToken)
	// monta Url
	_cUrl := AllTrim(cUrlCiaSh) 
	// monta Get
	_cGet := _cUrl + "/api/v1/orders" + IIF(!Empty(cPedTeste), "/"+ AllTrim(cPedTeste)	, "")
	aadd(aHeadStr,"Authorization: Bearer " + AllTrim(cToken))
	aadd(aHeadStr,"Content-Type: application/json")

	// conecta
	cRetorno := HTTPSGet( _cGet, "", "", "", cGetParms, nTimeOut, aHeadStr,@cHeaderGet)
	
	nHttpStat := HTTPGetStatus(@cHttpStat)
	// se ocorrer erros no Get
	If nHttpStat <> 200 //200 = OK, diferente de 200 = erro
		If !_lJob
			MsgStop(STR0019 + " Status: "+Alltrim(Str(nHttpStat)) + " " + cHttpStat,STR0026) //"Falha na conexão E-commerce CiaShop. Verifique cadastro de Identificação de Loja (SLJ) dados Token/Url."##"Atenção !"
		EndIf
		Lj900XLg(STR0019 + " Status: "+Alltrim(Str(nHttpStat)) + " " + cHttpStat,STR0026,STR0026) //"Atenção !"##"Atenção !"
	Else
		If !FWJsonDeserialize(cRetorno,@oObjJSon)
			If !_lJob
				MsgAlert(STR0020+" Status: "+cRetorno + " HttpStatus " + Alltrim(Str(nHttpStat)) + " " + cHttpStat)
			EndIf
			Lj900XLg(STR0020+" Status: "+cRetorno + " HttpStatus " + Alltrim(Str(nHttpStat)) + " " + cHttpStat)   //"Falha no processamento do JSon."
		Else
			_lRet := .T.  
		EndIf	
	EndIf		
Else
	Lj900XLg(STR0024 +cFil+ STR0025 )      
	If !lJob
		ApMsgInfo(STR0024 +cFil+ STR0025 ,STR0026 )  //"Filial " / " não cadastrada na tabela de acessos CiaShop." / "Atenção!"
	EndIf
EndIf
Return _lRet 

//----------------------------------------------------------
/*/{Protheus.doc} LJ900ENNFE
Envia dados da NFe para o E-commerce Ciashop.

@type function

@author  Varejo
@version P11.8
@since   30/08/2016

@param	aPedEnvNFE		array com pedido de vendas faturados e integrados com e-commerce Ciashop
@return lRet		sucesso ou não no envio dos dados .F./.T.
/*/
//----------------------------------------------------------
Static Function LJ900ENNFE(aPedEnvNFE, aUrlToken, aHeadStr, cLog, lEnviada)

Local oObj := NIL
Local cJSon		:= ""
Local sPostRet	:= ""
Local cParamGET 	:= ""
Local aCab, aLin
Local nTimeOut := 120
Local cHeadRet := ""
Local _lJob 	:= .f.
Local lRet 	:= .T.
Local nY  := 0 //Contador  
Local nX  := 0 //Contador
Local cUrlCiaSh   	:= ""
Local cToken        := ""
Local cMsgErro 		:= ""
Local cHttpStat		:= ""
Local nHttpCode		:= 0 //codigo Http
Local lSleep60		:= .F. //envia novamente após 60 segs
Local cRetMsg		:= ""
Local aObjRet		:= {}
Local cErrorCode	:= "" //Codigo de Erro
Local _cUrl         := ""

Default aPedEnvNFE := {} 
DEFAULT aUrlToken := {}

If ExistFunc("LOJX904CUT") .AND. Len(aUrlToken) < 1
	aUrlToken  	:= LOJX904CUT(cEmpAnt,cFilAnt)
	cUrlCiaSh   := aUrlToken[1]
	cToken      := aUrlToken[2]
Else
	cUrlCiaSh   := aUrlToken[1]
	cToken      := aUrlToken[2]
EndIf

If Empty(cUrlCiaSh) .OR. Empty(cToken)
	If !_lJob 
		MsgStop(STR0021)	// Chave/Url de acesso CiaShop (token) não cadastrados no Identificador de Loja (SLJ)
	Else
		conout(STR0021)	// Chave/Url de acesso CiaShop (token) não cadastrados no Identificador de Loja (SLJ)
	EndIf
	lRet := .F.
	Lj900XLg(STR0021, SC5->C5_NUM)
	//Return lRet
ElseIf 	Len(aHeadStr) = 0 // configura Header		
	aadd(aHeadStr,"Authorization: Bearer " + AllTrim(cToken))	
	aadd(aHeadStr,"Content-Type: application/json")
	
EndIf

If lRet

	// monta Url para envio informações CiaShop		
	_cUrl := "orders/"+AllTrim(SC5->C5_PEDECOM)+"/invoices"	// "orders/ID/invoices"
	
	//Verifica se a nota fiscal já foi enviada
	oObj := Ljx904JsOb(_cUrl + "?nfeNumber=" + Alltrim(SF2->F2_DOC) + "&fields=nfeSerialNumber,nfeNumber" , "GET", "", aUrlToken, ;
				@cMsgErro, @cRetMsg)
	If ValType(oObj) == "A"
		aObjRet := aClone(oObj)
	ElseIf  ValType(oObj) == "O" 
		aAdd(aObjRet, oObj)
	EndIf
	
	For nY := 1 to Len(aObjRet)
		If Alltrim(aObjRet[nY]:nfeSerialNumber) == AllTrim(SF2->F2_SERIE) .AND. Alltrim(aObjRet[nY]:nfeNumber) == AllTrim(SF2->F2_DOC)
			lEnviada := .T.
			Exit
		EndIf
		aObjRet[1] := FreeObj(aObjRet[1])
	Next nY

    _cUrl := AllTrim(cUrlCiaSh)+ "/api/v1/" +  _cUrl	 // "https://"+AllTrim(SLJ->LJ_URL)+"/api/v1/orders/ID/invoices"

    If !lEnviada

        For nX := 1 to 2

            //Título dos campos do JSon
            aCab   :=  {"invoiceType", "nfeNumber" , "nfeSerialNumber","nfeDate","nfeUrl","nfeAccessKey","danfeUrl","sendMail"}
                
            //Itens
            aLin   := {{ "NFE",;
                            AllTrim(SF2->F2_DOC),;			 
                            AllTrim(SF2->F2_SERIE),;		    		
                            FWTimeStamp ( 5, SF2->F2_EMISSAO, AllTrim(SF2->F2_HORA)+IIF(Len(Alltrim(SF2->F2_HORA)) <= 5,":00","" ) ) ,;			 
                            SuperGetMv("MV_LJECURL",,""),; 
                            SF2->F2_CHVNFE,;
                            SuperGetMv("MV_LJECDNF",,""),;
                            Iif(Empty(SF2->F2_SERIE),"false","true") } } 
            
            //Chama a função para gerar o JSON.
            cJSon    := LJGERJSON( { aCab, aLin} )
            oObj := NIL 
            lSleep60 := .F.
            // desceraliza o JSon
            cMsgErro := "Pedido e-commerce ["+AllTrim(SC5->C5_PEDECOM)+"], Pedido no Protheus  [" + AllTrim(SC5->C5_NUM) + "] Dados NFe ["+AllTrim(SC5->C5_NOTA)+"/"+AllTrim(SC5->C5_SERIE)+"]"
            If !FWJsonDeserialize(cJSon,@oObj)
                cMsgErro += " Falha na estrutura do JSON de Envio" +  STR0029  + CRLF +  cJSon // "Falha na estrutura do JSON de Envio"
                cLog += CRLF +  cMsgErro
                If !_lJob 
                    MsgStop(cMsgErro)	
                EndIf
                Lj900XLg(cMsgErro, SC5->C5_PEDECOM)
                lRet := .F.
                Exit
            Endif
            
            oObj := NIL

            // Envia dados da NFE
            sPostRet  := HTTPSPost( _cUrl, "", "", "", cParamGET, cJSon, nTimeOut, aHeadStr, @cHeadRet)
            nHttpCode := HTTPGetStatus(@cHttpStat)

            If  nHttpCode ==  201 .or.  nHttpCode ==  200 
                // se o envio feito com sucesso	
                // Grava Log
                cMsgErro += " dados da Nota enviados."
                lRet 	:= .T.
            Else
                cMsgErro += " " +  STR0022 + CRLF +  "{ HTTPGetStatus - [" + cValToChar(nHttpCode)  + "] " + cHttpStat  // Falha no envio dos dados da NFe para Ciashop
                lRet 	:= .F.
                cErrorCode	:= ""
                // desceraliza JSon  de Erro
                If !Empty(sPostRet) .AND. !FWJsonDeserialize(sPostRet,@oObj)
                    cMsgErro += CRLF + "Falha na estrutura do JSON de Retorno. Json" + sPostRet //"Falha na estrutura do JSON de Retorno .Pedido "##" Json" 
                Else
                    If ValType(oObj) == "O"
                        If ValType(oObj:ERRORS) == "A"
                            For nY := 1 to Len(oObj:ERRORS)
                                cErrorCode := ""
                                If AttIsMemberOf( oObj:ERRORS[nY], "CODE") .AND. ValType(oObj:ERRORS[nY]:CODE) == "C"
                                    cErrorCode := oObj:ERRORS[nY]:CODE
                                EndIf
                                cMsgErro += space(2) + "{"
                                cMsgErro += space(4) + "Código   : " + cErrorCode + CRLF
                                cMsgErro += space(4) +"Mensagem : " +  IIF(AttIsMemberOf( oObj:ERRORS[nY], "MESSAGE") .AND. ValType(oObj:ERRORS[nY]:MESSAGE) == "C", oObj:ERRORS[nY]:MESSAGE, "") + CRLF
                                cMsgErro += space(4)+ "Mais Inf.: " + IIF(AttIsMemberOf( oObj:ERRORS[nY], "MOREINFO") .AND. ValType(oObj:ERRORS[nY]:MOREINFO) == "C", oObj:ERRORS[nY]:MOREINFO, "") + CRLF
                                cMsgErro += space(2) +  "}"+ CRLF
                                If !lSleep60 .AND. nHttpCode == 429 .AND. Upper("LimitExceeded") == Upper( cErrorCode )
                                    lSleep60 := .T.
                                EndIf
                            Next nY
                        EndIf
                    EndIf
                EndIf
                cMsgErro += "}"
            EndIf
            
            Lj900XLg(cMsgErro,SC5->C5_PEDECOM)
            cLog += CRLF + cMsgErro 		
            If lSleep60 
                cMsgErro := "Enviando dados da Nota Fiscal novamente após 60 segundos "
                Lj900XLg(cMsgErro,SC5->C5_PEDECOM)
                cLog += CRLF + cMsgErro
                Sleep(60* 1000) //Aguarda 1 segundos para enviar novamente
            Else
                Exit
            EndIf
            oObj := NIL
        Next nX
    Else
        cMsgErro := "Pedido e-commerce ["+AllTrim(SC5->C5_PEDECOM)+"], Pedido no Protheus  [" + AllTrim(SC5->C5_NUM) + "] Dados NFe ["+AllTrim(SC5->C5_NOTA)+"/"+AllTrim(SC5->C5_SERIE)+"] Nota ja enviada"
        
        Lj900XLg(cMsgErro,SC5->C5_PEDECOM)
        cLog += CRLF + cMsgErro 
    EndIf

EndIf

FwFreeObj(aObjRet)

Return lRet


//----------------------------------------------------------
/*/{Protheus.doc} Lj900ESt
Função que atualiza os novos campos criados para armazenar o status

@type function

@author  Varejo
@version P12.1.17
@since   30/08/2017

@param lLockName - Valida se a rotina está sendo executada com o LockName
@return NIl
/*/
//----------------------------------------------------------
Function Lj900ESt(lLockName)
Local lProssegue 	:= .T. //Prossegue com o processamento
Local cFunction 	:=  "LOJA900E" //Execução da rotina 
Local oLJCLocker 	:= NIL //Objeto de travamento de execução da rotina
Local cName 		:= "" //Nome do Locker
Local cMessage 		:= "" //Mensagem informada ao usuário
Local lBatch 		:= IsBlind() //Execução em batch


Default lLockName := .T.

If lCamposST = NIL
	lCamposST := ( SL1->(ColumnPos("L1_ECSTATU") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECSTATU") > 0 ) ) .AND. ;
				    ( SL1->(ColumnPos("L1_ECRASTR") > 0 ) .AND. SLQ->(ColumnPos("LQ_ECRASTR") > 0 ) )
EndIf


If lCamposST

	If lLockName
		//Gera SEMAFORO - para não dar erro de execução simultanea
		oLJCLocker  := LJCGlobalLocker():New()
		cName := cFunction+cEmpAnt+cFilAnt
		
		lProssegue := oLJCLocker:GetLock( cName )
	
	EndIf

	If lProssegue
		If lBatch
			Lj900ESPr(lBatch)
		Else
		
			Processa( { || Lj900ESPr(lBatch)  } ,STR0031, STR0032, .T.  )		// "Migrando registro de Status de Pedidos"##"Aguarde..."
		EndIf 
		
		If lLockName
			oLJCLocker:ReleaseLock( cName )
		EndIf
	ElseIf lLockName
		If lBatch
			cMessage := STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]. " + STR0033 ////"JÁ EXISTE EXECUÇÃO DA ROTINA "###" "Para a execução da rotina de Migração do Status do Pedido é necessário que os Jobs da Execução da rotina LOJA900E estejam desabilitados."
			MsgAlert(cMessage)
		EndIf
	
		Lj900XLg(cMessage )
	
	EndIf
Else
	If !lBatch .AND. lLockName
		cMessage := STR0034//"Para a execução da rotina migradora de Status de Pedidos, é necessário a criação dos campos L1_ECSTATU/LQ_ECSTATU e L1_ECRASTR/LQ_ECRASTR" 
		MsgAlert(cMessage)
		
	EndIf
EndIf

Return 

//----------------------------------------------------------
/*/{Protheus.doc} Lj900ESPr
Função de processamento da função que atualiza os novos campos criados para armazenar o status

@type function

@author  Varejo
@version P11.8
@since   30/08/2017

@param lBatch - Execução em batch
@return NIl
/*/
//--------------------------------------------------------
Function Lj900ESPr(lBatch)
Local cAliasTRB 	:= GetNextAlias() //Alias da query
Local cAliasTRB2 	:= "" //Alias da Query
Local cPedECom 		:= space(SC5->(TamSx3("C5_PEDECOM")[1])) //Tamanho do campo pedido e-commerce
Local cEcStatus 	:= space(SL1->(TamSx3("L1_ECSTATU")[1])) //Tamanho do campo Status e-commerce
Local nTotReg 		:= 0 //Total de registros
Local cPedido 		:= "" //Número do Pedido de venda
Local nReg 			:= 0 //Registros
Local cEcPedRes		:= space(SL1->(TamSx3("L1_PEDRES")[1]))//Pedido de Reserva
Local cECFlag		:= space(SL1->(TamSx3("L1_ECFLAG")[1]))//Pedido de Reserva
Local cPedEComAnt	:= ""

Default lBatch := .F.

//Verifica se existe algum orcamento excluído sem o link do pedido excluído
//Traz os orcamento deletados e sem o campo L1_PEDRES e o L1_ECPEDEC preenchido
//se encontrar lista todos os pedidos e-commerce
//pois faz os vinculos L1_PEDRES C5_NUM
//Os pedidos que possuem 2 linhas duplicadas, vincula a mais antiga e replica o status
//Os pedidos que possuem 1 linha, vincula
BeginSql alias cAliasTRB
	SELECT DISTINCT L1_ECPEDEC, L1_FILIAL, L1_NUM, SL1.R_E_C_N_O_ AS REGISTRO
	FROM %table:SC5% SC5
	INNER JOIN %table:SL1% SL1 
	ON ( SC5.C5_PEDECOM = SL1.L1_ECPEDEC )						
	WHERE ( C5_PEDECOM <> ' ' AND C5_PEDECOM <> %exp:cPedECom% )
	AND ( L1_PEDRES = ' ' OR  L1_PEDRES = %exp:cEcPedRes%   )
	AND ( L1_ECFLAG <> ' ' AND L1_ECFLAG  <>   %exp:cECFlag% ) 
	AND SL1.D_E_L_E_T_ = '*'
	AND SC5.D_E_L_E_T_ = '*'
	ORDER BY  L1_ECPEDEC, L1_FILIAL, L1_NUM
EndSql	
	
If (cAliasTRB)->(!Eof())
	cAliasTRB2 := GetNextAlias()
	Do While (cAliasTRB)->(!Eof())
		If cPedEComAnt <> (cAliasTRB)->L1_ECPEDEC
			If Select(cAliasTRB2) > 0
				(cAliasTRB2)->(DbCloseArea())
			EndIf
			cPedEComAnt := (cAliasTRB)->L1_ECPEDEC
			//Busca os Pedidos com o código e-commerce
			BeginSql alias cAliasTRB2
				SELECT C5_FILIAL, C5_NUM, C5_STATUS, C5_RASTR
				FROM %table:SC5% SC5
				WHERE C5_PEDECOM = %exp:cPedEComAnt% 
				AND SC5.D_E_L_E_T_ = '*'
				ORDER BY C5_FILIAL, C5_NUM
			EndSql		
		Else
			//Pula o registroCX
			//Grava o status do Pedido igual do pedido para não trazer na rotina
			(cAliasTRB2)->(DbSkip(1))
		EndIf
		
		If (cAliasTRB2)->(!Eof())
			SET DELETED OFF 
				If SL1->(DbGoTo( (cAliasTRB)->REGISTRO))
					RecLock("SL1", .f.)
					SL1->L1_PEDRES := (cAliasTRB2)->C5_NUM
					//verifica se tem registros na mesma situação para gravar o status igual ao pedido e não enviar o status
					(cAliasTRB)->(DbSkip(1))
					If (cAliasTRB)->(!Eof() ) .AND. cPedEComAnt == (cAliasTRB)->L1_ECPEDEC
						SL1->L1_ECSTATU := (cAliasTRB2)->C5_STATUS
						SL1->L1_ECRASTR := (cAliasTRB2)->C5_RASTR				
					EndIf
					//Final atualização do status
					SL1->(MsUnLock())
				EndIf
			SET DELETED ON		
		Else
			(cAliasTRB)->(DbSkip(1))
		EndIf
		
	EndDo
	If Select(cAliasTRB2) > 0
		(cAliasTRB2)->(DbCloseArea())
	EndIf
EndIf

(cAliasTRB)->(DbCloseArea())

//Realiza q query de status de pedidos, para verificar se é necessário a atualização
                              
//Executa a query
BeginSql alias cAliasTRB
	SELECT 
		COUNT(1) AS CONTA
	FROM %table:SC5% SC5	
	INNER JOIN %table:SL1% SL1 
	ON  ( SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC )				
	WHERE ( C5_PEDECOM <> ' ' AND C5_PEDECOM <> %exp:cPedECom% )
	AND L1_ECFLAG  = '1'
	AND ( L1_ECSTATU <> ' ' AND L1_ECSTATU  <>  %exp:cEcStatus% ) 		
EndSql	

If (cAliasTRB)->(!Eof())  .AND. (cAliasTRB)->CONTA = 0

	(cAliasTRB)->(DbCloseArea())
	//Executa a query para selecionar os pedidos e-commerce que devem ser atualizados
	BeginSql alias cAliasTRB
		SELECT C5_FILIAL, C5_NUM, C5_PEDECOM, C5_STATUS, C5_RASTR, SL1.R_E_C_N_O_ AS REGISTRO			
		FROM %table:SC5% SC5
		INNER JOIN %table:SL1% SL1 
		ON (  SC5.C5_NUM = SL1.L1_PEDRES AND SC5.C5_PEDECOM = SL1.L1_ECPEDEC 	 )						
		WHERE ( C5_PEDECOM <> ' ' AND C5_PEDECOM <> %exp:cPedECom% )
		AND C5_STATUS <> '00' AND C5_STATUS <> '-1' 
		AND ( SC5.D_E_L_E_T_ <> '*' OR  ( SC5.D_E_L_E_T_  = '*' AND C5_STATUS = '90') ) 
		AND L1_ECFLAG  = '1'
		AND ( L1_ECSTATU = ' ' OR L1_ECSTATU  =  %exp:cEcStatus% )
		ORDER BY  C5_FILIAL, C5_NUM "
	EndSql	
	
		
	nTotReg := Lj900XRC( cAliasTRB, "Lj900ESPr" )
	
	If !lBatch
		ProcRegua(nTotReg+1)
	EndIf
	
	(cAliasTRB)->(DbGoTop())
	
	cAliasTRB2 := GetNextAlias()
	Do While !(cAliasTRB)->(Eof())
		cPedido := (cAliasTRB)->C5_NUM
		nReg++
		If !lBatch
			IncProc()
		EndIf
		Lj900XLg("Executando migração do status do pedido... Registro "+ AllTrim(Str(nReg)) + " de " + Alltrim(Str(nTotReg)) + " Número do Pedido " +  cPedido)

		
		If !Empty((cAliasTRB)->REGISTRO)
			Lj900ERETC((cAliasTRB)->C5_NUM, .F., cAliasTRB2 , (cAliasTRB)->C5_FILIAL)	
			
			If (cAliasTRB2)->(!Eof()) .AND. !Empty((cAliasTRB2)->MGT_STATUS)
				SET DELETED OFF 
				SL1->(DbGoTo( (cAliasTRB)->REGISTRO))
				RecLock("SL1", .f.)
				SL1->L1_ECSTATU := (cAliasTRB2)->MGT_STATUS
				SL1->L1_ECRASTR := (cAliasTRB2)->MGT_RASTR
				SL1->(MsUnLock())
				SET DELETED ON
			EndIf
			
			
			(cAliasTRB2)->(DbCloseArea())
		EndIf
		(cAliasTRB)->(DbSkip(1))	
	EndDo
	
EndIf
(cAliasTRB)->(DbCloseArea())

//----------------------------------------------------------
/*/{Protheus.doc} AtuStaRas
Atualiza Status do SC5 e SL1 e Rastreio do SL1

@param aVltPas   - Pedidos que devem voltar o Status
@param aDadosSl1 - Orçamentos que terão o Status e o Rastro atualizados

@author Rafael Tenorio da Costa
@since  11/03/2019   
/*/
//--------------------------------------------------------
Static Function AtuStaRas(aVltPas, aDadosSl1)

    Local aArea    := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local aAreaSL1 := SL1->( GetArea() )
    Local nX       := 0

	SET DELETED OFF 
	
        //Volta Status do passo
		For nX := 1 To Len(aVltPas)
				
			SC5->( DbGoTo(aVltPas[nX]) )

            If !SC5->( Eof() )
		
                RecLock("SC5", .F.)
                    Do Case
                        Case SC5->C5_STATUS == "05"	
                            SC5->C5_STATUS := "00"

                        Case SC5->C5_STATUS == "10"	
                            SC5->C5_STATUS := "05"

                        Case SC5->C5_STATUS == "15"
                            SC5->C5_STATUS := "10"

                        Case SC5->C5_STATUS $ "21|30|90|91"
                            SC5->C5_STATUS := "15"
                    End Case
            
                    SC5->C5_VOLTAPS := "2"
                SC5->( MsUnLock() )

            EndIf
		Next nX 
		
        //Atualiza Status e Rastro na SL1
		For nX := 1 To Len(aDadosSl1)
			SL1->( DbGoTo(aDadosSl1[nX][01]) )

            If !SL1->( Eof() )

                RecLock("SL1", .F.)
                    SL1->L1_ECSTATU := aDadosSl1[nX][02]
                    SL1->L1_ECRASTR := aDadosSl1[nX][03]
                SL1->( MsUnLock() )
            EndIf
		Next nX
	
	SET DELETED ON

    RestArea(aAreaSL1)
    RestArea(aAreaSC5)
    RestArea(aArea)

Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} StatusPed
Atualiza o status dos pedidos na CiaShop

@param oWs   - ObjetoWs com os dados para acessoa ao web-services da CiaShop
@param cXML  - Xml com os pedidos que terão os status atualizados
@param lAJob - Define se execução ocrreu pelo web-services

@return      - {lErro, cRetorno, cXML}  lErro    - Define se teve erro
                                        cRetorno - Retorno do metodo web-services StatusPedido
                                        cXML     - Xml enviado

@author Rafael Tenorio da Costa
@since  11/03/2019   
/*/
//--------------------------------------------------------
Static Function StatusPed(oWs, cXML, lAJob)

    Local lErro    := .F.
    Local cRetorno := ""
    Local cError   := ""
    Local cWarning := ""
    Local oRetXML  := Nil

    If !Empty(cXML)

        //Converte uma string do formato OEM/MS-DOS Text para ANSI Text (formato do Microsoft Windows)
        cXML := OEMToAnsi(cXML)

        //Grava XML de envio quando não for job
        IIF(!lAJob, MemoWrite('envioStatus.xml', cXML), )

        //Consome método
        If !oWs:StatusPedidos(, , @cXML)
            lErro    := .T.
            cRetorno := STR0017     //"Erro ao consumir o método 'StatusPedidos' do WebService!"
        Else

            //Grava XML de retorno quando não for job
            IIF(!lAJob, MemoWrite('retornoStatus.xml', oWs:cXml), )
            
            //Retorna o XML parseado em um objeto com as tags em variáveis
            oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning)
            
            If !Empty(cError)
                cRetorno := STR0018 + Chr(13) + cError      //"Erro no método XmlParser: "
                cRetorno += Chr(13) + "XML: " + oWs:cXml
                lErro    := .T.
            Else
                cRetorno := oWs:cXml
                lErro    := !oWs:lStatusPedidosResult
            EndIf
        EndIf

    EndIf

Return {lErro, cRetorno, cXML}