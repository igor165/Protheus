#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "CRDDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "LOJXFUNK.CH"
#INCLUDE "AUTODEF.CH" 

#DEFINE __FORMATEF				"CC;CD"  	//Formas de pagamento que utilizam operação TEF para validação
#DEFINE _FORMAPGDG				"PD/PX"		//Forma de pagamento considerado Pagamento Digital
#DEFINE TEF_NAO_USADO				"1"		//Nao Utiliza TEF
#DEFINE TEF_SEMCLIENT_DEDICADO  	"2"     //Utiliza TEF Dedicado Troca de Arquivos
#DEFINE TEF_COMCLIENT_DEDICADO  	"3"		//Utiliza TEF Dedicado com o Client
#DEFINE TEF_DISCADO             	"4"		//Utiliza TEF Discado
#DEFINE TEF_LOTE                	"5"		//Utiliza TEF em Lote
#DEFINE TEF_CLISITEF				"6"		//Utiliza a DLL CLISITEF
#DEFINE TEF_CENTROPAG				"7"		//Utiliza a DLL CENTRO DE PAGOS

Static lGiftCard 	:= Nil		// Variavel para verificar se estah tudo OK para utilizar a implementacao de Cartao Presente (Gift Card)
Static lVPNewRegra 	:= Nil		//Variavel para identificar se utiliza ou nao as novas modificacoes da implementacao de Vale Presente, para imprimir o comprovante nao fiscal na venda de vale presente
Static lIsMDI 		:= Nil	 	//Variável para saber se o acesso ao sistema foi realizado por SIGAMDI 
Static lRPSNewReg 	:= Nil		//Variavel para identificar se utiliza ou nao as novas modificacoes da implementacao de RPS, que permite vender item de entrega junto com item de serviço

/*/{Protheus.doc} Lj7AtuaCli()
Atualiza ultima compra, primeira compra e maior compra do cliente

@author  Lucas Novais (lnovais) 
@version P12.1.17
@since   12/09/2018
@return   
/*/
//--------------------------------------------------------
Function Lj7AtuaCli()

Local aArea			:= GetArea()				// Backup de area
Local aAreaSA1		:= SA1->(GetArea())			// Backup de area
Local cCliPad		:= SuperGetMV("MV_CLIPAD")	// Cliente Padrao
Local cLojaPad		:= SuperGetMV("MV_LOJAPAD")	// Loja Padrao

LjGrvLog(," Lj7AtuaCli | Inicio " )

If cCliPad + cLojaPad <> SL1->(L1_CLIENTE + L1_LOJA)

	SA1->(dbSetOrder(1))
	
	If SA1->( dbSeek( xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA) )
		
		LjGrvLog(SL1->L1_NUM," Atualizando ultima compra, primeira compra e maior compra do cliente: " + SL1-> ( L1_CLIENTE + L1_LOJA )  )
		
		RecLock("SA1", .F.)
		SA1->A1_ULTCOM 	:= Iif(!Empty(SL1->L1_EMISNF), SL1->L1_EMISNF, SA1->A1_ULTCOM)
		SA1->A1_PRICOM 	:= Iif(!Empty(SA1->A1_PRICOM), SA1->A1_PRICOM, SL1->L1_EMISNF)
		SA1->A1_MCOMPRA := Iif(SL1->L1_VLRTOT > SA1->A1_MCOMPRA, SL1->L1_VLRTOT, SA1->A1_MCOMPRA)
		SA1->(MsUnlock())

	EndIf
Else
	LjGrvLog(SL1->L1_NUM," Ultima compra, primeira compra e maior compra não será atualizada, venda realizada para o cliente padrão" )
EndIf

RestArea(aAreaSA1)
RestArea(aArea)

Return

//--------------------------------------------------------
/*/{Protheus.doc} LjGetPrefix()
Retorna Prefixo 

@author  Paulo Henrique 
@version P12.1.17
@since   10/06/2018
@return   
/*/
//--------------------------------------------------------
Function LjGetPrefix(cSerie)
Local cRet 		:= ""

If SLG->(ColumnPos("LG_PREFIXO")) > 0
	dbSelectArea("SLG")
	SLG->(DbSetOrder(2)) //LG_FILIAL+LG_SERIE
	If SLG->(DbSeek(xFilial("SLG")+cSerie))
		cRet := SLG->LG_PREFIXO
	EndIf
EndIf

Return cRet

//---------------------------------------------------------------
/*/{Protheus.doc} LjMotBxS
Função para validar o tamanho da linha do arquivo SIGAADV.MOT

@author fabiana.silva
@since 25/05/2018
@version 12.1.17
/*/
//---------------------------------------------------------------
Function LjMotBxS() As Logical
	Local lRet		As Logical
	Local cFile		As Character
	Local nHdlMot	As Numeric
	Local nTamArq	As Numeric

	lRet	:= .F.
	cFile	:= "SIGAADV.MOT"
	nHdlMot	:= FOpen(cFile,0)
	nTamArq	:= 0
	
	If nHdlMot < 0
		Help(" ",1,"SIGAADV.MOT")
		Final("SIGAADV.MOT")
	EndIf
	
	nTamArq := FSeek(nHdlMot,0,2)	// VerIfica tamanho do arquivo
	FSeek(nHdlMot,0,0)				// Volta para inicio do arquivo	
	
	//Caso o tamanho do arquivo, dividido por 19 dê resto 0,
	//o arquivo está com o tamanho antigo (19 bytes por linha)
	//Caso contrário, o arquivo está com o tamanho novo (20 bytes por linha)
	If ( nTamArq % 19 ) == 0 
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	
	FClose( nHdlMot )
	
Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjRetfor()
Retorna Informacoes do Fornecedor. 

@author  Alan Oliveira
@version P12.1.17
@since   09/11/2017
@return   
/*/
//--------------------------------------------------------
Function LjRetfor(cCliCod, cCliLoj)

Local aRet:= {"",""}

Default cCliCod := "" 
Default cCliLoj := ""

SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
SA1->(DbSeek(xFilial("SA1")+cCliCod+cCliLoj))

SA2->(DbSetOrder(3)) //A2_FILIAL + A2_CGC
SA2->(DbSeek(xFilial("SA2")+SA1->A1_CGC))

aRet := { SA2->A2_COD, SA2->A2_LOJA }

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} LjDCorte()
Calcula a próxima data de corte 

@author  Marisa Cruz 
@version P12.1.17
@since   10/11/2017
@param   dVencto: vencimento de origem
@param   cDiaCorte: Dia da Semana do Corte: 1-Domingo a 7-Sábado
@return  dRet - data do próximo corte
/*/
//--------------------------------------------------------
Function LjDCorte(dVencto,nDiaCorte,nIntervCorte)

Local dRet 			:= dVencto
Local dDataCorte 	:= CtoD("")
Local nX			:= 0

Default dVencto 		:= dDataBase 
Default nDiaCorte 		:= 1
Default nIntervCorte	:= 7	//A cada 7 dias

LjGrvLog(," LjDCorte | Inicio " )

If nIntervCorte = 7
	While (Dow(dRet) <> nDiaCorte)
		dRet++
	EndDo
Else	//Aconselhável intervalo até 15 - Calculo o dia final do corte. Vejo se a data final do corte é o mesmo mês que o inicial 
	
	//Obtenho primeiro a menor data de corte do mês corrente
	If nDiaCorte > 1	//Dia de corte inicial a partir de 02
		dDataCorte := StoD(Left(DtoS(dVencto),6)+StrZero(nDiaCorte-1,2))
	Else				//Dia de corte inicial 01
		dDataCorte := StoD(Left(DtoS(dVencto),6)+StrZero(nDiaCorte+nIntervCorte-1,2))
	EndIf
	
	nX := 0
	Do While (dVencto > dDataCorte) .AND. (nX < 4)		//Faço avanço de intervalos de corte enquanto data do corte menor que a do vencimento 
		nX++
		dDataCorte += nIntervCorte
	EndDo
	
	If Month(dVencto) <> Month(dDataCorte)		//Meses diferentes, testar com dia 01
		dDataCorte := StoD(Left(DtoS(MonthSum(dRet,1)),6)+StrZero(nDiaCorte,2))-1 //?
	ElseIf Day(dDataCorte) >= 28 //Vejo se a data do dia é 28 ou mais, e se não é último dia do mês
		dDataCorte := StoD(Left(DtoS(MonthSum(dRet,1)),6)+"01")-1
	EndIf
	dRet := dDataCorte
	
EndIf

Return( dRet )

//--------------------------------------------------------
/*/{Protheus.doc} LjGerfincp()
Geracao de Titulos no Contas a Pagar, para os processo de devolucao 
de compras recebidos pelo RetailSales. 

@author  Alan Oliveira
@version P12.1.17
@since   06/12/2017
@return  lFinserv Retorna .T. se todos os item forem Serviço financeiro
/*/
//--------------------------------------------------------
Function LjGerfincp(_cEmp,_cFil, cFilse2, cNumOrc, cCodFor, cLojaFor, cNreduz, cNumDoc, cSerie,nValBrut)

Local aVetorSE2	:= {}
Local cErro     := ""

Private lMsErroAuto   := .F.

Default _cEmp	:= ""
Default _cFil	:= ""
Default cFilse2	:= ""
Default cNumOrc	:= ""
Default cCodFor	:= ""
Default cLojaFor:= ""
Default cNreduz	:= ""
Default cNumDoc	:= ""
Default cSerie	:= ""
Default nValBrut:= 0

	aVetorSE2 :={	{"E2_PREFIXO"	,cSerie			,Nil}	,;				// 01
					{"E2_NUM"	   	,cNumDoc	    ,Nil}	,; 				// 02
					{"E2_PARCELA"	,"1"			,Nil}	,; 				// 03
					{"E2_TIPO"		,"NDF"   		,Nil}	,;				// 04
					{"E2_NATUREZ"	,"OUTROS"		,Nil}	,;				// 05
					{"E2_FORNECE"	,cCodFor	 	,Nil}	,;				// 06
					{"E2_LOJA"		,cLojaFor	    ,Nil}	,; 				// 07
					{"E2_NOMFOR"	,cNreduz		,Nil}	,;				// 08
					{"E2_EMISSAO"	,dDataBase      ,NIL}	,;				// 09
					{"E2_VENCTO"	,dDataBase 		,NIL}	,; 				// 10
   					{"E2_VENCREA"	,dDataBase		,NIL}	,; 				// 11
					{"E2_VALOR"		,nValBrut		,NIL}	,;				// 12
					{"E2_HIST"		,"DEVOLUCAO GERADA POR INTEGRACAO EAI",NIL}}// 13

	lMsErroAuto := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faz a inclusao do contas a pagar via ExecAuto ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetorSE2,,3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houveram erros durante a execucao da rotina automatica.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMsErroAuto
		cErro:= MostraErro()
		CONOUT("LOJXFUNC - GERACAO DO CONTAS A PAGAR"+cErro)
		LjGrvLog(cNumOrc,"GERACAO DO CONTAS A PAGAR",cErro)
		DisarmTransaction()
	Endif
Return

//--------------------------------------------------------
/*/{Protheus.doc} LjFindServ()
Verifica se todos os item da venda são Serviço financeiro 

@author  Lucas Novais 
@version P12.1.17
@since   19/10/2017
@return  lFinserv Retorna .T. se todos os item forem Serviço financeiro
/*/
//--------------------------------------------------------
Function LjFindServ(cNumOrcam)
Local aAreaSB1		:= {}
Local aAreaSL2		:= {}
Local lFinserv  	:= .F.								//Retorna .T. se todos os item forem Serviço financeiro
Local cMvLjTSFin	:= SuperGetMV("MV_LJTPSF",,"SF")	// Servico financeiro

LjGrvLog(," LjFindServ | Inicio " )

aAreaSB1 := SB1->(GetArea())
aAreaSL2 := SL2->(GetArea())

DbSelectArea("SL2")
DbSetOrder(1) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO

DbSelectArea("SB1")
DbSetOrder(1) //B1_FILIAL + B1_COD

If  SL2->(DbSeek( xFilial( "SL2" ) + cNumOrcam ))
	While !SL2->( Eof() ) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial( "SL2" ) + cNumOrcam 
		If  SB1->(DbSeek( xFilial( "SB1" ) + SL2->L2_PRODUTO ))
			iF alltrim(SB1->B1_TIPO) == alltrim(cMvLjTSFin)
				lFinserv := .T.
			Else
				lFinserv := .F.
				Exit
			EndIf
		EndIf
		SL2->(DbSkip())
	End
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSL2)

Return lFinserv

//--------------------------------------------------------
/*/{Protheus.doc} LjCalcRecIss()
Validações para atribuição do valor do campo 
E1_ISS quando for para recolhimento de imposto 

@author  Rogerio Onishi
@version P12
@since   19/06/2017
@return
/*/
//--------------------------------------------------------
Function LjCalcRecIss(	nTotNFISS	, nRestISS	, lAltParcela	, lCliRecIss,;
						nImpostos 	, lpTPAbISS	, nI			, nValE1ISS	,;
						nE1Valor	)

Local nMvVRetIss	:= SuperGetMv("MV_VRETISS",.T.,0)	// indica o valor mínimo para a retenção do ISS
Local lMvDescISS	:= SuperGetMV("MV_DESCISS",,.F.)	// Informa ao sistema se o ISS devera ser descontado do valor do titulo financeiro caso o cliente for responsavel pelo recolhimento
Local lZeraISS 		:= ( Lj7RecIss() .AND. !lMvDescISS ) // Se o cliente recolher ISS e o parâmetro MV_DESCISS estiver F o sistema não irá calcular  o imposto, segundo a regra do Faturamento

Default nValE1ISS	:= 0								//valor do E1_ISS

LjGrvLog(," LjCalcRecIss | Inicio " )

If lZeraISS .AND. !Empty(SL1->L1_DOCRPS) .And. !Empty(SL1->L1_SERRPS)
	nValE1ISS 	:= 0
	nTotNFISS 	:= 0 
	nRestISS	:= 0
	LjGrvLog( NIL, " Caso o cliente recolha o ISS e MV_DESCISS = .F. o sistema não irá realizar o calculo, portanto Valor de ISS(E1_ISS) será zerado")
Else
	If lAltParcela .Or. ;
		(!lpTPAbISS .And. lCliRecIss .And. nTotNFISS <= nMvVRetIss ) .Or.;
		(lCliRecIss .And. nTotNFISS >= nMvVRetIss )
		
		nValE1ISS     := NoRound(( nTotNFISS / nImpostos ), 2)
	Else
		nValE1ISS     += NoRound(( nTotNFISS / nImpostos ), 2)
	EndIf
	
	nRestISS += nValE1ISS
	If nI == nImpostos
		nValE1ISS 	+= ( nTotNFISS - nRestISS )
		nTotNFISS 	:= 0 
		nRestISS 	:= 0
	EndIf
	
	If lCliRecIss .And. !lpTPAbISS .And. (nValE1ISS > 0) .And. (nValE1ISS <= nMvVRetIss)
		nE1Valor := nE1Valor - nValE1ISS 	//Abate o ISS do valor, pois depois sera adicionado novamente dentro da funcao A040DupRec()
	EndIf	
EndIf

LjGrvLog(," LjCalcRecIss | Fim " )

Return

//--------------------------------------------------------
/*/{Protheus.doc} Lj7OrigNCC()
Verifica se a NCC teve origem no módulo financeiro

@author  Cleyton F.Alves
@version P12.114
@since   09/05/2017
@return  lRet -> .T. (Titulo com origem o modulo financeiro) // .F. (Titulo sem origem no modulo financeiro)
@obs     Rotina pesquisa desde a primeira NCC compensada    
/*/
//--------------------------------------------------------

Function Lj7OrigNCC()

Local aAreaAt := GetArea()  				//salva a area atual
Local aAreaE1 := SE1->(GetArea())  			//salva a area dos titulos financeiros
Local aAreaE5 := SE5->(GetArea())  			//salva a area dos mivimentos financeiros
Local nFilE1  := TamSX3("E1_FILIAL")[1]  	//guarda o tamanho da filial do titulo para uso na chave
Local nPrfE1  := TamSX3("E1_PREFIXO")[1]  	//guarda o tamanho do prefixo do titulo para uso na chave
Local nNumE1  := TamSX3("E1_NUM")[1]  		//guarda o tamanho da numero do titulo para uso na chave
Local nParE1  := TamSX3("E1_PARCELA")[1]	//guarda o tamanho da parcela do titulo para uso na chave
Local nTipE1  := TamSX3("E1_TIPO")[1]  		//guarda o tamanho do tipo do titulo para uso na chave
Local lFina   := .F.  						//indica se o titulo foi criado no modulo financeiro
Local cCliLoj := SE1->(E1_CLIENTE+E1_LOJA)  //chave estática com codigo e loja do cliente
Local cChaves := SubStr(SE5->E5_DOCUMEN,1,nPrfE1+nNumE1+nParE1+nTipE1)  //chave variável com o numero da NCC

LjGrvLog(," Lj7OrigNCC | Inicio " )

SE1->(dbSetOrder(2))
While !Empty(cChaves) .And. SE1->(dbSeek(xFilial("SE1")+cCliLoj+cChaves))
    
    cChaves := SubStr(SE1->E1_HIST,nFilE1+1,nPrfE1+nNumE1+nParE1+nTipE1)
    
    If "FINA" $ SE1->E1_ORIGEM
        lFina := .T.
        Exit        
    EndIf
    
EndDo

RestArea(aAreaE5)
RestArea(aAreaE1)
RestArea(aAreaAt)

Return lFina

//--------------------------------------------------------
/*/{Protheus.doc} LjTryAgain()
Verifica se deve processar venda em outro momento

@author  P.Henrique
@version P11.8
@since   30/09/2016
@return  lRet -> .T. (Venda sera processada em outro momento) // .F. (Venda seguira o fluxo de processamento)
@obs	  Rotina exclusiva para apoio do LjGrvBatch, SL1 posicionada no orcamento que sera processado	 
/*/
//--------------------------------------------------------

Function LjTryAgain( aRecFail, nMinReproc )
Local lRet 		:= .T.
Local nPos		:= 0
Local cElapTime	:= ""
Local nElapHH	:= 0	// Horas	* 3600000 (converte horas para Milissegundos)
Local nElapMM	:= 0	// Minutos	*   60000 (converte minutos para Milissegundos) 
Local nElapSS	:= 0	// Segundos	*    1000 (converte segundos para Milissegundos)  
Local nElapsed	:= 0	// Tempo decorrido em segundos

Default aRecFail 	:= {}	// {RecNo,Qtde de tentativas(fixo maximo de 5), Hora da Tentativa}
Default nMinReproc	:= 0	// Tempo em segundos para reprocessar 

LjGrvLog(," LjTryAgain | Inicio " )

nPos := aScan( aRecFail,{|x| x[1] ==  SL1->(Recno())})

If nPos <> 0	//possui registro no array quando ja tentou processar a venda

	//Converte tempo em milesimos de segundo
	cElapTime 	:= ELAPTIME( aRecFail[nPos][3], TIME() )
	nElapHH		:= Val(SubStr(cElapTime,1,2)) * 3600000
	nElapMM		:= Val(SubStr(cElapTime,4,2)) *   60000	
	nElapSS		:= Val(SubStr(cElapTime,7,2)) *    1000
	  
	nElapsed	:= nElapHH + nElapMM + nElapSS	// Tempo decorrido em Milissegundos
	
	// Quando decorreu o tempo configurado, realiza nova validacao da venda
	If nElapsed >= nMinReproc    								
		
		If aRecFail[nPos][2] > 5		// quando validacao da venda retornou falha por mais de 5 vezes, libera a venda para seguir fluxo padrao do GrvBatch
			lRet := .F.
		Else
			aRecFail[nPos][2]++			// Incrementa tentativas de processamento
			aRecFail[nPos][3] := TIME() // Atualiza hora da ultima verificacao
		EndIf
		
		LjGrvLog(SL1->L1_NUM,"Verifica se Venda sera reprocessada",lRet)
		
	EndIf
Else
	LjGrvLog(SL1->L1_NUM,"Sinalizou Venda pra Reprocessamento")
	aAdd(aRecFail,{ SL1->(Recno()) , 1, TIME() } )   // adiciona identificador do registro para reprocessamento em outro momento
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjVldBatch()
Realizar validacoes para minimizar as chances 
de erro no processamento da venda, tais como: concorrencia SL1,SA1

@author  P.Henrique
@version P11.8
@since   30/09/2016
@return  lRet
@obs	  Rotina exclusiva para apoio do LjGrvBatch, SL1 posicionada no orcamento
		  que sera processado, quando Return .F., marca venda para processar em outro momento	 
/*/
//--------------------------------------------------------

Function LjVldBatch( lConsitencia )

Local lRet			:= .T.
Local lLj7095		:= .F. // ,utilizado para desvio de lock na SA1
Local lF040TRVSA1	:= .F. // utilizado para verificar se possui o PE compilado, necessario para nao ocorrer erro de RecLock na rotina: A040DupRec(MATXATU)
Local lLockSA1		:= .T.
Local cCliPad		:= SuperGetMV("MV_CLIPAD")	// Cliente Padrao
Local cLojaPad		:= SuperGetMV("MV_LOJAPAD")	// Loja Padrao
Local lRetLj7082	:= .T.
Local aAreaSL2		:= SL2->(GetArea())   		// Area atual do SL2
Local aAreaSL4		:= SL4->(GetArea())   		// Area atual do SL4
Local lExistSL2		:= .F.						// Valida se existe registro na SL2 do orçamento
Local lExistSL4		:= .F.						// Valida se existe registro na SL4 do orçamento
Local nSumSL4		:= 0						// Soma parcelas SL4
Local nSumSL2		:= 0						// Soma parcelas SL2
Local nSumTot		:= 0						// Soma do orçamento total
Local nTotAcres		:= 0 						// valor total de acressimo
Local nTotDesc		:= 0 						// total de desconto
Local nModeloDoc	:= SubStr(AllTrim(SL1->L1_KEYNFCE),21,2)
Local lVNaoFiscal	:= .F. 						// Indica que é uma venda Não Fiscal (Vale Presente / RPS)

Default lConsitencia := .F. 					// Se .T. valida consistencia dos dados as tabelas SL1 SL2 e SL4 

LjGrvLog(," LjVldBatch | Inicio " )

If !lConsitencia

	//#### Validacao 1: Registro de Cliente(SA1) alocado 
	//Nao realiza validacoes de cliente quando cliente padrao
	If cCliPad+cLojaPad <> SL1->L1_CLIENTE+SL1->L1_LOJA
		
		lLockSA1 := .T.
		
		LjGrvLog(SL1->L1_NUM,"Venda para cliente identificado")
	
		lLj7095		:= ExistBlock("LJ7095")		//PE utilizado para nao realizar Lock na SA1(LOJA)
		lF040TRVSA1	:= ExistBlock("F040TRVSA1")	//PE utilizado para nao realizar Lock na SA1(Financeiro), necessario para nao ocorrer erro de RecLock na rotina: A040DupRec(MATXATU) quando SA1 em uso
	
		//PEs trabalham em conjunto, valida se possui os dois para liberar trava da SA1
		If lLj7095 <> lF040TRVSA1
			LjGrvLog(SL1->L1_NUM,"Foi identificado incompatibilidade da existencia dos Pontos de Entrada: LJ7095"+IIF(lLj7095,"(Compilado)","(Nao Compilado)")+ " - F040TRVSA1"+IIF(lF040TRVSA1,"(Compilado)","(Nao Compilado)"))
			LjGrvLog(SL1->L1_NUM,"Esses PEs(LJ7095 e F040TRVSA1) sao utilizados para permitir gravar a venda mesmo quando o registro do cliente(SA1) em uso por outro usuário. Consultar TDN para detalhes.")
		EndIf
		
		If lLj7095 
			lLockSA1 := ExecBlock("LJ7095",.F.,.F.)
		EndIf
	Else
		lLockSA1 := .F.
		LjGrvLog(SL1->L1_NUM,"Venda para cliente Padrao")
	EndIf	
		
	If lLockSA1
	
		LjGrvLog(SL1->L1_NUM,"Ira verificar a concorrencia de registro da tabela SA1. Cliente:"+SL1->L1_CLIENTE+" Loja:"+SL1->L1_LOJA)
		
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(MsSeek(xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA))		
			If SA1->(Rlock())		// Funcao que tenta alocar sem chamar tela
				SA1->(MsUnlock())
				lRet := .T.
				LjGrvLog(SL1->L1_NUM,"Registro SA1 liberado para gravacao")
			Else																
				lRet := .F.  	// Cliente alocado por outro usuario
				LjGrvLog(SL1->L1_NUM,">>NC<< Registro do cliente(SA1) esta em uso por outro usuário, venda nao poderá ser processada nesse momento") 
			EndIf	
		Else
			lRet := .F.
			LjGrvLog(SL1->L1_NUM,">>NC<< Registro do cliente(SA1) não localizado na retaguarda. Possivel causa: Cliente adicionado no PDV ainda nao subiu para retaguarda ou divergencia de cadastro entre PDV e Retaguarda")
		EndIf
	
	EndIf
	
	//#### Validacao 2: Registro da SL1 alocado. (Pode ocorrer caso utilize PE apos a finalizacao da Venda para atualizar dados da SL1)
	//Valida concorrencia da SL1 no inicio, na finalizacao da venda onde eh gravado o SITUA = RX, existem PEs que podem fazer uso do registro da SL1 e impactar no final do GravaBatch
	If lRet
		LjGrvLog(SL1->L1_NUM,"Ira verificar a concorrencia de registro da tabela SL1")	
		 
		If SL1->(Rlock())		
			SL1->(MsUnlock())
			LjGrvLog(SL1->L1_NUM,"Registro SL1 liberado para gravacao")
		Else																
			lRet := .F.
			LjGrvLog(SL1->L1_NUM,">>NC<< Registro da Venda(SL1) esta em uso por outro usuário, venda nao poderá ser processada nesse momento")
		EndIf
	EndIf
	
	//Verifica se venda possui numeracao, caso todas as tentativas o registro seja mantido sem numneracao, essa mesma validacao eh realizada para nao realizar processo GravaBatch e gravar venda com 'ER'
	If lRet .AND. Empty(SL1->L1_DOC) .AND. Empty(SL1->L1_DOCPED)
		lRet := .F.
		LjGrvLog(SL1->L1_NUM,">>NC<< Registro da SL1 com L1_DOC e L1_DOCPED em branco")		
	EndIf	
	
	//Ponto de entrada permite nao processar a venda, conforme documentacao, caso nao sofra nenhuma alteracao no L1_SITUA, tentara processar a venda novamente em outra execucao  
	If lRet .AND. ExistBlock("LJ7082")
		LjGrvLog(SL1->L1_NUM,"Antes da Chamada do Ponto de Entrada:LJ7082")										
		lRetLj7082 := ExecBlock("LJ7082",.F.,.F.)
		LjGrvLog(SL1->L1_NUM,"Apos a Chamada do Ponto de Entrada:LJ7082",lRetLj7082)
		If ValType(lRetLj7082) == 'L' .AND. !lRetLj7082
			lRet := .F.
			LjGrvLog(SL1->L1_NUM,"Nao ira processar a venda, conforme configurado no retorno do Ponto de Entrada:LJ7082") 
		EndIf 
	EndIf
Else
	LjGrvLog(SL1->L1_NUM,"Validando Estacao...")
	/************************************** Estacao ************************************/
	DbSelectArea("SLG")
	SLG->( DbSetOrder(1) ) // LG_FILIAL + LG_CODIGO
	If !SLG->( DbSeek(xFilial("SLG") + SL1->L1_ESTACAO) )
		LjGrvLog(SL1->L1_NUM,"Estacao de origem da venda (L1_ESTACAO): " + SL1->L1_ESTACAO + " nao foi encontrada na retaguarda (LG_CODIGO).")
	EndIf
	/************************************** Estacao ***********************************/

	LjGrvLog(SL1->L1_NUM,"Validando SL2...")
	//Validação: Verifica total de itens 
	/************************************** SL2 **************************************/ 
	DbSelectArea("SL2")
	SL2->(DbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	lExistSL2 := SL2->( DbSeek( xFilial("SL2") + SL1->L1_NUM) )

	If lExistSL2

		If !Empty(SL2->L2_VALEPRE) // Venda não fiscal (Vale Presente)
			lVNaoFiscal := .T.
			Lj7VPVdaVP(1)
			LjGrvLog(SL1->L1_NUM,"Venda não Fiscal")
		EndIf

		LjGrvLog(SL1->L1_NUM,"Realizando soma dos itens da SL2...")
		//Varre a SL2 os produtos do orçamento
		While SL2->(!Eof()) .AND. SL2->L2_NUM == SL1->L1_NUM
			nSumSL2 += SL2->L2_VLRITEM	
			SL2->(DbSkip())
		EndDo
		LjGrvLog(SL1->L1_NUM,"SL2 Calculado - Soma: ", nSumSL2)

	Else
		lRet := .F.
		LjGrvLog(SL1->L1_NUM,"Nao existe SL2 para este orcamento! - ID_ALERT")
		LjGravaErr("Nao existe SL2 para este orcamento! - ID_ALERT")
	EndIf
	/************************************** SL2 **************************************/

	/************************************** SL1 **************************************/
	If AllTrim(SL1->L1_TPORC) == "E" .AND. !Empty(SL1->L1_DOC)
		LjGrvLog(SL1->L1_NUM,"Validando SL1...")
		If !Empty(SL1->L1_KEYNFCE)
			LjGrvLog(SL1->L1_NUM,"Serie SAT - L1_SERSAT", SL1->L1_SERSAT)
			LjGrvLog(SL1->L1_NUM,"Especie da Venda - L1_ESPECIE", SL1->L1_ESPECIE)
			LjGrvLog(SL1->L1_NUM,"Tipo de documento - nModeloDoc", nModeloDoc)			
			Do Case
				Case nModeloDoc == "65" //NFCE
					If !Empty(SL1->L1_SERSAT) .Or. AllTrim(SL1->L1_ESPECIE) == "SATCE" 
						LjGrvLog(SL1->L1_NUM,"Venda gerada com informacoes divergentes do documento emitido - ID_ALERT")
						LjGravaErr("Venda gerada com informacoes divergentes do documento emitido - ID_ALERT")
						lRet := .F.
					EndIf
				Case nModeloDoc == "59" //SAT
				 	If Empty(SL1->L1_SERSAT) .Or. AllTrim(SL1->L1_ESPECIE) <> "SATCE"
				 		LjGrvLog(SL1->L1_NUM,"Venda gerada com informacoes divergentes do documento emitido - ID_ALERT")
						LjGravaErr("Venda gerada com informacoes divergentes do documento emitido - ID_ALERT")
				 		lRet := .F.
				 	EndIf
				Case nModeloDoc == "55" //Totvs PDV NF-e
					LjGrvLog(SL1->L1_NUM,"Nf-e selecionado")
				OtherWise
					LjGrvLog(SL1->L1_NUM,"Nao foi reconhecido o tipo de documento referente a venda - ID_ALERT")
					LjGravaErr("Nao foi reconhecido o tipo de documento referente a venda - ID_ALERT")
					lRet := .F.
			EndCase
		ElseIf !Empty(SL2->L2_VALEPRE) .And. !lVNaoFiscal
			LjGrvLog(SL1->L1_NUM,"Nao foi reconhecido o tipo de documento referente a venda - ID_ALERT")
			LjGravaErr("Nao foi reconhecido o tipo de documento referente a venda - ID_ALERT")
			lRet := .F.
		EndIf
	EndIf
	/************************************** SL1 **************************************/

	/************************************** SL4 **************************************/
	//Validação: Verifica total de pagto 
	DbSelectArea("SL4")
	SL4->(DbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM
	lExistSL4 := SL4->( DbSeek( xFilial("SL4") + SL1->L1_NUM) )
	If lExistSL4 .Or. !Empty(SL1->L1_CREDITO) 
		LjGrvLog(SL1->L1_NUM,"Realizando soma dos pagamentos da SL4...")
		
		//Acressimo
		nTotAcres := SL1->L1_FRETE + SL1->L1_DESPESA + SL1->L1_SEGURO	
	
		//Desconto na venda
		If !Empty(SL1->L1_DESCONT) .AND. SL1->L1_DESCONT > 0
			nTotDesc := SL1->L1_DESCONT
		EndIf	 		 
	
		//Varre a SL4 para somar as parcelas do orçamento
		While SL4->(!Eof()) .AND. SL4->L4_NUM == SL1->L1_NUM
			nSumSL4 += SL4->L4_VALOR - SL4->L4_TROCO
			SL4->(DbSkip())
		EndDo
		LjGrvLog(SL1->L1_NUM,"SL4 Calculado - Soma: " , nSumSL4)
	Else
		lRet := .F.
		LjGrvLog(SL1->L1_NUM,"Nao existe SL4 para este orcamento! - ID_ALERT")
		LjGravaErr("Nao existe SL4 para este orcamento! - ID_ALERT")
	EndIf //lExistSL4
	
	LjGrvLog(SL1->L1_NUM,"Validando NCC...")
	
	//Validação: Se utilizar NCC
	If !Empty(SL1->L1_CREDITO)
		nSumTot := SL1->L1_CREDITO + nSumSL4
		LjGrvLog(SL1->L1_NUM,"NCC incluida na soma dos pagamentos: ", nSumTot)	
	Else
		LjGrvLog(SL1->L1_NUM,"Nao possui NCC")
		nSumTot := nSumSL4
	EndIf //!Empty(SL1->L1_CREDITO)
	/************************************** SL4 **************************************/
	/************************************ TOTAL **************************************/
	//Soma nos produtos da SL2 - L1_FRETE + L1_DESPESA + L1_SEGURO, pois não é inserido. Apenas o SL1->L1_JUROS é incluido
	nSumSL2 := nSumSL2 + nTotAcres
	
	LjGrvLog(SL1->L1_NUM,"Efetuando validacao dos valores com o valor do orcamento...")
	//Se a soma dos pagamento é igual ao valor da venda e igual a soma dos itens
	//Não é feita validação com o SL1 pois o livro fiscal tem como base os totais dos itens da venda
	If nSumTot <> nSumSL2  
		LjGrvLog(SL1->L1_NUM,"Resumo Totais - ID_ALERT")
	Else
		LjGrvLog(SL1->L1_NUM,"Resumo Totais")
	EndIf //nSumTot == nSumSL2
	
	LjGrvLog(SL1->L1_NUM,"Soma da SL2: " ,nSumSL2)
	LjGrvLog(SL1->L1_NUM,"Soma da SL4: " ,nSumTot)
	/************************************ TOTAL **************************************/
	SL2->(RestArea(aAreaSL2))
	SL4->(RestArea(aAreaSL4))
EndIf // !lConsitencia	

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LJ7E4DscFi()
Cálculo de Desconto Financeiro via E4_DESCFIN

@author  Varejo
@since   28/06/2016
@return  nVlrAux	 
/*/
//--------------------------------------------------------
Function LJ7E4DscFi(nValor,nOpc,lAltCond,nTipoProg)

Local nVlrAux		:= 0	// Valor de Retorno
Local nMvLjTpDes	:= SuperGetMv( "MV_LJTPDES", , 0 )			// Indica qual desconto sera' utilizado 0 - Antigo / 1 - Novo (objeto)
Local lFtvdVer12	:= FindFunction("LjFTvd") .AND. LjFTVD()	// Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nNfDedIcm		:= 0	// Retorna o valor total da dedução de ICMS dos itens
Local lArrefat      := SuperGetMv("MV_ARREFAT") == "S"

Default nValor		:= 0	// Valor de entrada
Default nOpc		:= 0	// Inclusão/Alteração/Exclusão
Default lAltCond	:= .F.	// Altera a Condição de Pagamento
Default nTipoProg	:= 0	// Se vir 1, veio da função Lj7CondPg(), para ver se a soma do desconto financeiro muda o status da variável Lj7AltProd()

LjGrvLog(," LJ7E4DscFi | Inicio " )

If Type("nDecimais") <> "N"
	nDecimais := 2
EndIf

nVlrAux := nValor

DbSelectArea("SE4")
If SE4->E4_DESCFIN > 0
	If nMvLjTpDes <> 2
		nVlrAux := NoRound( nValor - NoRound( nValor * ( SE4->E4_DESCFIN / 100 ) ), nDecimais )
	ElseIf lFtvdVer12
		nNfDedIcm := LjVDItDedIcm()
		If nNfDedIcm > 0
			nValor  	+= nNfDedIcm
			nNfDedIcm 	:= NoRound( ( nNfDedIcm - (nNfDedIcm * ( SE4->E4_DESCFIN / 100 )) ), nDecimais)
			nVlrAux 	:= NoRound( ( nValor - ( nValor *( SE4->E4_DESCFIN / 100 )) ), nDecimais)
			nVlrAux	 	:= nVlrAux - nNfDedIcm
		Else
			nVlrAux :=  NoRound( nValor - if(lArrefat, Round(nValor *( SE4->E4_DESCFIN / 100 ), nDecimais ) ,NoRound(nValor *( SE4->E4_DESCFIN / 100 ), nDecimais ) ),nDecimais)
		EndIf
	Else
		nVlrAux := NoRound( nValor - A410Arred(nValor*( SE4->E4_DESCFIN / 100 ), "D2_DESCON" ), nDecimais)
		If nVlrAux > 0 .AND. nModulo == 12 .AND. nTipoProg <> 1 // Caso NÃO veio da função Lj7CondPg() em Loja701B.prw
			If nOpc == 4 .AND. !lAltCond // alterou forma de pagamento, pega valor total para recalculo nas trocas de Cond. Pgto
				nVlrAux := nValor 		 // desconsidera desconto Financeiro na Finalização da Venda, pois já foi descontado na chamada da função
				LJ7T_Total(2,LJ7T_Total(2) + nVlrAux)
			EndIf
		ElseIf nVlrAux > 0 .AND. nModulo == 12 .AND. nTipoProg = 1 // Caso veio da função Lj7CondPg() em Loja701B.prw
			Lj7T_Total( 2, Lj7T_SubTotal(2) - Lj7T_DescV(2) + Lj7CalcFrete() - (nValor-nVlrAux) )
		EndIf
	EndIf
EndIf

Return (nVlrAux)

//--------------------------------------------------------
/*/{Protheus.doc} Lj7SFIsPrd()
Validar se o produto informado na venda eh do tipo "SF" (Serviço Financeiro).

@author  Vendas Clientes
@since   09/05/2016
@return  lRet
@uso	 LOJA701/FRTA271
/*/
//--------------------------------------------------------
Function Lj7SFIsPrd(cCodProd)
Local lRet 		:= .F.	//Retorno
Local cMvLjTSf	:= SuperGetMV("MV_LJTPSF",,"SF")	// Define se é tipo SF

LjGrvLog(," Lj7SFIsPrd | Inicio " )

If nModulo == 23	//Front Loja
	SBI->(DbSetOrder(1))
	If SBI->(DbSeek(xFilial("SBI")+cCodProd)) .And. SBI->BI_TIPO == cMvLjTSf
		lRet:= .T.
	EndIf
Else
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+cCodProd)) .And. SB1->B1_TIPO == cMvLjTSf
		lRet:= .T.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LJ7NumTit()
Regra utilizada para compor o numero do titulo da venda.

@author  Varejo
@since   02/10/2015
@return  cE1Num
@uso	 SIGALOJA
/*/
//--------------------------------------------------------
Function LJ7NumTit()
Local cE1Num 	:= ""
Local cE1NumPE 	:= ""
Local cMvLjE1Num:= SuperGetMV("MV_LJE1NUM",,"1") //Permite configurar como sera gerado o numero do tiulo da venda (campo E1_NUM)
Local lPedido 	:= .F.
Local aArea 	:= GetArea()
Local aAreaSL1 	:= SL1->(GetArea())

LjGrvLog(," LJ7NumTit | Inicio " )

DbSelectArea("SL1")

/*----------------------------------------------------------------------
Faz a verificacao para ter certeza que esta posicionado no SL1 correto.
Posiciona no orcamento principal, que deu origem a venda.
Quando eh venda com pedido, deve estar posicionado no orcamento pai.
----------------------------------------------------------------------*/
If !Empty(SL1->L1_ORCRES)
	SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
	SL1->(DbSeek(SL1->L1_FILRES+SL1->L1_ORCRES))
EndIf

If !Empty(SL1->L1_DOCPED)
	lPedido  	:= .T.
EndIf

/*-------------------------------------------------------------------------------------------------------
 Verifica que tipo de retorno deve ser considerado de acordo com a configuracao do parametro MV_LJE1NUM.
-------------------------------------------------------------------------------------------------------*/
Do Case
	Case cMvLjE1Num == "1" //Opcao 1: Default - Comportamento Padrao do Sistema (para manter o legado)
		
		cE1Num := If(Empty(SL1->L1_DOC),SL1->L1_DOCPED,SL1->L1_DOC)
		
	Case cMvLjE1Num == "2" //Opcao 2: Considera o Numero do Orcamento ou Numero do Orcamento Pai quando existir Pedido (L1_NUM)
		
		cE1Num := SL1->L1_NUM //Numero do orcamento		
EndCase

cE1Num := PadR(cE1Num,TamSX3("E1_NUM")[1])

If ExistBlock("LJNumTit")
	cE1NumPE := ExecBlock( "LJNumTit", .F., .F., { cMvLjE1Num, cE1Num } )
	If !Empty(cE1NumPE)
		cE1Num := PadR(cE1NumPE,TamSX3("E1_NUM")[1])
	EndIf
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return cE1Num

//--------------------------------------------------------
/*/{Protheus.doc} LjGrvDifal()
Geração de guias de Difal e FECP(trambem referente ao DIFAl)

@author  Thiago Y.M.N - Shiny
@since   08/04/16
@uso	 LOJXFUNC
/*/
//--------------------------------------------------------
Function LjGrvDifal(cNumNota)

Local lLjDifal 	  	:= SuperGetMV("MV_LJINTUF",,0) > 0 	//Ativa verificação e operacoes relacionadas ao DIFAL
Local lFisLivro 	:= SuperGetMV("MV_LJLVFIS",,1) == 2	// Utiliza novo conceito para geracao do SF3
Local lMVLJPRDSV   	:= SuperGetMv("MV_LJPRDSV",.F.,.F.) // Verifica se esta ativa a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas
Local lConfTit	 	:= .F.
Local lLancCont  	:= .F. //Lan‡.Contab.On-Line
Local lGDifal    	:= .F. //Gera Guia ICM Compl. UF Dest.?
Local lGFcpDif   	:= .F. //Gera Guia FECP da UF Destino?
Local lPerg			:= .F. //Trata Se Pergunta ja foi feita
	
Local nRecnoSF2		:= 0
Local nVlrDifal		:= 0
Local nMes			:= 0
Local nAno			:= 0
Local nDifFecp   	:= 0
	
Local cLcPadTit		:= Substr(SuperGetMv("MV_LPADICM"),1,3)

Local aPergParam	:= {}
Local aRetParam		:= {}
Local aDatas    	:= {}
Local aDSF2      	:= {}
Local aGNRE      	:= {}
Local aRecTit    	:= {}
Local dDtIni     	:= Ctod("//")
Local dDtFim     	:= Ctod("//")
Local dDtVenc    	:= Ctod("//")	
Local cSomaGnr		:= GetNewPar("MV_SOMAGNR","")
Local lSomaGnr		:= .F. //soma as Guias Difal e Difecp
Local nRecSF3       := 0

LjGrvLog(," LjGrvDifal | Inicio " )
	
If lFisLivro .AND. cPaisLoc == "BRA" 		
	
	If lLjDifal .And. SF2->F2_VALICM > 0 .And. Empty(IESubTrib(SF2->F2_EST)) .And. SF2->F2_TIPOCLI=="F" .And. ;
		GetMV("MV_ESTADO")<>SF2->F2_EST .And. SF3->(FieldPos("F3_DIFAL")) > 0 .And. SF3->(FieldPos("F3_VFCPDIF")) > 0
		
		LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "Inicio Rotina DIFAL") //Grava Log
		nRecnoSF2 := 0
			//Caso tenha sido gerada NF de Produto e NF de Servico, entao posiciona na NF de Produto antes de executar a funcao 
		If lMVLJPRDSV .And. !Empty(SL1->L1_DOCRPS) .And. SL1->L1_DOC <> SL1->L1_DOCRPS
			nRecnoSF2 := SF2->( Recno() ) //Guarda a posicao atual da SF2
			SF2->( DbSetOrder( 1 ) )
			//Posiciona na NF de Produto antes de executar a funcao
			If !SF2->( DbSeek( xFilial( "SF2" ) + SL1->L1_DOC + SL1->L1_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA ) )
				SF2->( DbGoTo ( nRecnoSF2 ) )
			EndIf
		EndIf

		SF3->(DbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
		If SF3->(dbSeek(xFilial("SF3")+SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)))

			While SF3->(!Eof() .And. SF3->(F3_Filial+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3")+SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE))	

				If !lPerg .And. (SF3->F3_DIFAL > 0 .Or. SF3->F3_VFCPDIF > 0)								
					//Ponto de entrada para manipular as perguntas referentes a geração de guia de DIFAL e FECP
					If ExistBlock("LJRETGUIA")
						aRetParam := ExecBlock("LJRETGUIA",.F.,.F.)
						LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "Utilizando P.E 'LJRETGUIA' para gravacao do DIFAL",aRetParam ) //Grava Log
					EndIf
					/*-----------Verificação de como serão geradas as Guias-----------*/	
					If !( ValType(aRetParam) == "A" .And. Len(aRetParam) > 0 )
																		   						
						aAdd( aPergParam, {2,STR0008/*"Gera Guia DIFAL ICM Compl.UF Dest.?"*/, "SIM", {"SIM", "NAO"}, 50, "", .T.})
						aAdd( aPergParam, {2,STR0009/*"Lan‡.Contab.On-Line?"*/				 , "SIM", {"SIM", "NAO"}, 50, "", .T.})
						aAdd( aPergParam, {2,STR0010/*"Gera Guia FECP da UF Destino?"*/		 , "SIM", {"SIM", "NAO"}, 50, "", .T.})
							
						aRetParam := {}
						If !(ParamBox(aPergParam ,"Parametros ",@aRetParam)) //Caso não tenha P.E, chama parambox para definição do pergunte
							lGDifal   	:= .F.
							lLancCont	:= .F.
							lGFcpDif 	:= .F.
						Else
							lGDifal   	:= (UPPER(aRetParam[1]) == "SIM")
							lLancCont	:= (UPPER(aRetParam[2]) == "SIM")
							lGFcpDif 	:= (UPPER(aRetParam[3]) == "SIM")	
						EndIf
					EndIF
						
					If ( ValType(aRetParam) == "A" .And. Len(aRetParam) > 0 )				
						lGDifal   	:= (UPPER(aRetParam[1]) == "SIM")
						lLancCont	:= (UPPER(aRetParam[2]) == "SIM")
						lGFcpDif 	:= (UPPER(aRetParam[3]) == "SIM")	
					Else
						lGDifal   	:= .F.
						lLancCont	:= .F.
						lGFcpDif 	:= .F.
					EndIf
					lPerg 		:= .T. 						//Pergunta ja foi feita
					lSomaGnr 	:= SF2->F2_EST $ cSomaGnr	//Soma as guias Difal e Difecp
					If lGDifal .Or. lGFcpDif
						nMes      := Month(SF2->F2_EMISSAO)
						nAno      := Year(SF2->F2_EMISSAO)
						aDatas    := DetDatas(nMes,nAno,3,1)
						dDtIni	  := aDatas[1]
						dDtFim	  := aDatas[2]
						dDtVenc	  := DataValida(aDatas[2]+1,.t.)
						aDSF2 	  := {}
						aadd(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST,SF2->F2_ESPECIE})
						nRecSF3 :=  SF3->(Recno())
					EndIf

					/*------------------------------------------------------------------------*/
				EndIf
				
				If SF3->F3_DIFAL > 0 .And. lGDifal
					nVlrDifal += SF3->F3_DIFAL
				Endif

				If SF3->F3_VFCPDIF > 0 .And. lGFcpDif
					nDifFecp  += SF3->F3_VFCPDIF
				EndIf
				SF3->( Dbskip() )
			EndDo
			
			If lGDifal .OR. lGFcpDif
				//Posiciona no SF3 para gerar a Difal	
				SF3->(DbGoTo(nRecSF3))
				If lSomaGnr
					//Soma as Guias Difal e DiFecp
					LjGrvLog(SL1->L1_NUM, "Gravando Guia DIFAL e DIFECP", nVlrDifal+nDifFecp)
					GravaTit( .T.,nVlrDifal+nDifFecp, "ICMS", "IC", cLcPadTit, dDtIni, dDtFim, dDtVenc, 1, lGDifal, nMes, nAno, 0, nVlrDifal+nDifFecp, "MATA460A", lLancCont, cNumNota, @aGNRE,,,SF2->F2_EST,,,.T.,,@aRecTit,@lConfTit,0,aDSF2, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.T. )							
				Else
					If lGDifal
						LjGrvLog(SL1->L1_NUM, "Gravando Guia DIFAL", nVlrDifal)
						GravaTit( .T.,nVlrDifal, "ICMS", "IC", cLcPadTit, dDtIni, dDtFim, dDtVenc, 1, lGDifal, nMes, nAno, 0, nVlrDifal, "MATA460A", lLancCont, cNumNota, @aGNRE,,,SF2->F2_EST,,,.T.,,@aRecTit,@lConfTit,0,aDSF2, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.T. )							
					EndIf
					SF3->(DbGoTo(nRecSF3))
					If lGFcpDif
						LjGrvLog(SL1->L1_NUM, "Gravando Guia DIFECP",nDifFecp)
					   GravaTit(.T.,nDifFECP,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGFcpDif,nMes,nAno,0,nDifFECP,"MATA460A",lLancCont,cNumNota,@aGNRE,,,SF2->F2_EST,,.T.,,,@aRecTit,@lConfTit,0,aDSF2, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.T. )							
					EndIf
				EndIf

			EndIf						
		EndIf
		If nRecnoSF2 > 0
			SF2->( DbGoTo ( nRecnoSF2 ) )  //Retorna a posicao anterior da SF2
		EndIf
	Else
		LjGrvLog( "L1_NUM: " + SL1->L1_NUM, "Venda nao caracteriza a emissao da Guia DIFAL" )
	EndIf
EndIf
	
Return

//--------------------------------------------------------
/*/{Protheus.doc} LjMExeParam()
Verifica se o parametro deve ser macroexecutavel ou nao.
IMPORTANTE: Esta funcao deve ser utilizada para parametro em que existe
a possibilidade de macroexecucao.

@param1 cParam		Nome do parametro
@param2 lHelp		Exibe mensagem de falta de parametro
@param3 cPadrao		Conteudo Padrao do parametro
@param4 lMacroExec	Macroexecuta ou nao o parametro

@author  Varejo
@version P11.8
@since   07/03/2016
@return	 xRet Conteudo do parametro.
/*/
//--------------------------------------------------------
Function LjMExeParam(cParam, lHelp, xPadrao,cFilParam,lMacroExec)
Local xRet	:= Nil	//Retorno da funcao

Default cParam		:= ""		//Nome do parametro
Default lHelp		:= .F.		//Apresenta msg quando nao existe?
Default xPadrao		:= NIL		//Conteudo padrao do parametro
Default cFilParam	:= NIL		//Filial do parametro
Default lMacroExec	:= .T.		//Macro executa o parametro?

xRet := SuperGetMV(cParam,lHelp,xPadrao,cFilParam)

LjGrvLog(cParam, " LjMExeParam | Inicio ", xRet)

If ValType(xRet) == "C" .And. !Empty(AllTrim(xRet))

	xRet	:= AllTrim(xRet)
	If SubStr(xRet,1,1) == "&"
		xRet := SubStr(xRet,2,Len(xRet))

	ElseIf !(SubStr(xRet,1,1) == "'" .Or. SubStr(xRet,1,1) == '"')
		lMacroExec := .F.
	EndIf
Else
	lMacroExec := .F.
EndIf

If lMacroExec
	xRet := &(xRet)
EndIf

Return xRet

//--------------------------------------------------------
/*/{Protheus.doc} LjRetemPCC()
Verifica se Retem ou Nao o PCC (Pis/Cofins/CSLL)

@param nVlrTotVend		Valor total da venda
@param nValPIS			Valor do Pis
@param nValCOFI			Valor do Cofins
@param nValCSLL			Valor do CSLL

@author  Varejo
@version P11.8
@since   09/07/2015
@return	 lRet [.T. = Retem o PCC (Pis/Cofins/CSLL) , .F. = Nao Retem o PCC (Pis/Cofins/CSLL)]
/*/
//--------------------------------------------------------
Function LjRetemPCC(nVlrTotVend, nValPIS, nValCOFI, nValCSLL )
Local lRet 		:= .F.
Local dDtLeiPCC	:= CTOD("22/06/2015")	// Novas Regras de Retenção PIS-COFINS-CSLL - Lei 13.137/2015, publicado no DOU em 22/06/2015.

LjGrvLog(," LjRetemPCC | Inicio " )

If dDataBase >= dDtLeiPCC
	//Se está na vigencia da nova Regra de Retenção PIS-COFINS-CSLL - Lei 13.137/2015, publicado no DOU em 22/06/2015.
	//Verifica se a soma do valor dos impostos (Pis/Cofins/CSLL) ultrapassa o minimo configurado no parametro MV_VL13137
	//Para Empresa Pública, não existe valor mínimo(MV_VL13137) para retenção do PCC.
	//!Lj7RetPCC() - Retorna Cliente = "P-Empresa Pública" com Naturaza configurada para calcular PCC
	If (nValPIS + nValCOFI + nValCSLL) > SuperGetMv("MV_VL13137", .T., 10) .OR. !Lj7RetPCC()
		lRet := .T.
	EndIf
Else
	//Verifica se o Total da Venda ultrapassa o minimo configurado no parametro MV_VL10925
	If nVlrTotVend > GetNewPar("MV_VL10925", 5000)
		lRet := .T.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjRetPeso()
Retornar o Peso Liquido e o Peso Bruto quando venda feita pelo Venda Direta

@param nPesLiq		Guardar e acumular o peso liquido da venda
@param nPesBrut		Guardar e acumular o peso bruto da venda

@author  Varejo
@version P11.8
@since   09/03/2015
@return	 nPesLiq(Peso liquido dos produtos) nPesBrut(Peso bruto dos produtos)
/*/
//--------------------------------------------------------
Function LjRetPeso(nPesLiq, nPesBrut)

Local 	aArea		:= GetArea()		// Guarda area atual
Local 	aAreaSL2	:= SL2->(GetArea())	// Guarda area atual

Default nPesLiq		:= 0        		// Guarda o peso liquido total da venda
Default nPesBrut	:= 0				// Guarda o peso bruto total da venda

LjGrvLog(," LjRetPeso | Inicio " )

// Posiciona o SL2
SL2->( DbSetOrder( 1 ) )
If SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ) )
	Do While !SL2->(Eof()) .AND. Alltrim(SL2->L2_NUM) == Alltrim(SL1->L1_NUM)
     	// Procura pelo produto para pegar os pesos
		dbSelectArea("SB1")
		If SB1->(MsSeek( xFilial("SB1") + SL2->L2_PRODUTO ))
			nPesLiq  += (SB1->B1_PESO * SL2->L2_QUANT)
			nPesBrut += (SB1->B1_PESBRU * SL2->L2_QUANT)
		Endif
		dbSelectArea("SL2")
		SL2->(DbSkip())
	Enddo
EndIf

RestArea(aArea)
RestArea(aAreaSL2)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj7CP_OK()
Verifica se eh venda de Recarga de Cartao Presente (Gift Card).

@author  Vendas Cliente
@since   17/03/2014
@uso	 SIGALOJA
/*/
//--------------------------------------------------------
Function Lj7VdIsRCP(cNumOrc)
Local lRet		:= .F.
Local aArea 	:= GetArea()
Local aAreaSL2	:= SL2->(GetArea())

LjGrvLog(," Lj7VdIsRCP | Inicio " )

DbSelectArea("SL2")
SL2->( DbSetOrder(1) )
If SL2->( DbSeek(xFilial("SL2")+cNumOrc) )
	While !SL2->( EOF() ) .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+cNumOrc
		If Lj7CP_Prod(SL2->L2_PRODUTO)
			lRet := .T.
			Exit
		EndIf
		SL2->( DbSkip() )
	End
EndIf

RestArea(aAreaSL2)
RestArea(aArea)

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} Lj7CP_OK()
Verifica se todos os fontes que tratam a implementacao de
Cartao Presente (Gift Card) estao atualizados.

@author  Vendas Clientes
@since   17/03/2014
@return  ""  = Nao esta definido ainda se eh uma venda de VP ou Nao.
		"S" = Eh uma venda de Vale Presente.
		"N" = Nao eh venda de Vale Presente.Eh venda de Prod.normal
@uso	 SIGALOJA
/*/
//--------------------------------------------------------
Function Lj7CP_OK()
Local aFuncs	:= {}
Local nCount 	:= 0
Local aType		:= {}
Local aFile		:= {}
Local aLine		:= {}
Local aDate		:= {}
Local aTime		:= {}
Local lOK 		:= .T.
Local dDataRef 	:= Nil
Local aRet		:= {}

LjGrvLog(," Lj7CP_OK | Inicio " )

//SOMENTE DEVE CONSIDERAR O USO DA IMPLEMENTACAO CARTAO PRESENTE (GIFT CARD) SE OS FONTES ESTIVEREM COM DATA IGUAL OU MAIOR QUE A DATA ESTIPULADA COMO DATA DE REFERENCIA

If lGiftCard == Nil
	dDataRef	:= CToD("06/11/2014") //Data de referencia dos fontes

	//Fontes a serem verificados
	aAdd( aFuncs, "lj140Grava"		)	//Fonte LOJA140
	aAdd( aFuncs, "LOJA701" 		)	//Fonte LOJA701
	aAdd( aFuncs, "Lj7Prod" 		) 	//Fonte LOJA701A
	aAdd( aFuncs, "Lj7Gravacao" 	) 	//Fonte LOJA701C
	aAdd( aFuncs, "Lj7ImpCF" 		) 	//Fonte LOJA701D
	aAdd( aFuncs, "LjGrvTudo" 		) 	//Fonte LOJXFUNC
	aAdd( aFuncs, "LjTEFAbre" 		) 	//Fonte LOJXTEF
	aAdd( aFuncs, "A040DupRec"		) 	//Fonte MATXATU

	If ExistFunc("LJSCRGIF")			
		aAdd( aFuncs, "LJSCRGIF"		)
	ElseIf ExistBlock("SCRCGift")			
		aAdd( aFuncs, "U_SCRCGift"		) 	//Fonte SCRCGift
	EndIf

	//Verifica a data dos fontes no RPO
	For nCount := 1 To Len(aFuncs)
		aRet := GetFuncArray( aFuncs[nCount], @aType, @aFile, @aLine, @aDate, @aTime )
		If Len(aDate) > 0
			If CToD(DToc(aDate[1])) < dDataRef
				lOK := .F.
				Exit
			EndIf
		Else
			lOK := .F.
			Exit
		EndIf
	Next nCount

	If lOK
		lGiftCard := .T. //Permite utilizar a implementacao de Cartao Presente (Gift Card)
	Else
		lGiftCard := .F. //NAO Permite utilizar a implementacao de Cartao Presente (Gift Card)
	EndIf
EndIf

Return lGiftCard

//--------------------------------------------------------
/*/{Protheus.doc} Lj7AtuaTMK()
Atualiza os registros de orçamentos provinientes da 
integração com o modulo de Callcenter - SIGATMK 

@author  Vendas Clientes
@since   30/05/2014
@return  cE1Num
@uso	 SIGALOJA / FRONTLOJA
@obs	 É necessário que a SL1 esteja corretamente posicionada
/*/
//--------------------------------------------------------
Function Lj7AtuaTMK()
Local cMvTmkLoj	 := SuperGetMV("MV_TMKLOJ",,"N" )	// Verifica se ha integracao com o Callcenter
Local lFtvdVer12 := .F.								// Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local aAliasOrd	 := {}

LjGrvLog(," Lj7AtuaTMK | Inicio " )

If cMvTmkLoj == "S" .And. SL1->(FieldPos("L1_NUMATEN")) > 0

	aAliasOrd	:= GetArea()
	lFtvdVer12	:= FindFunction("LjFTvd") .AND. LjFTVD()

	DbSelectArea("SUA")
	DbSetOrder(1)
	If DbSeek(xFilial("SUA")+SL1->L1_NUMATEN)
		If RecLock("SUA",.F.)
			REPLACE UA_OPER		WITH "1"
			REPLACE UA_DOC		WITH SL1->L1_DOC
			If !lFtvdVer12
				REPLACE UA_STATUS   WITH "NF"
			ElseIf lFtvdVer12
				REPLACE UA_STATUS   WITH "NF."
			EndIf
			REPLACE UA_SERIE  	WITH SL1->L1_SERIE
			REPLACE UA_EMISNF 	WITH dDatabase
			REPLACE UA_VEND		WITH SL1->L1_VEND
			MsUnlock()
		EndIf
	EndIf

	// Encerra o atendimento na lista de contatos.
	DBSelectArea("SU4")
	DBSetOrder(4)	//U4_FILIAL+U4_CODLIG
	If dbSeek(xFilial("SU4")+SL1->L1_NUMATEN) .And. SU4->U4_STATUS <> "2"
		If RecLock("SU4",.F.)
			REPLACE SU4->U4_STATUS WITH "2"	//Status de encerrado
			MsUnlock()
		EndIf
	EndIf

	RestArea(aAliasOrd)
EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj7VPNew()
Verifica se utiliza ou nao as novas modificacoes da
implementacao de Vale Presente, para imprimir o comprovante
nao fiscal na venda de vale presente.

@author  Vendas Clientes
@since   24/01/2014
@return  ""  = Nao esta definido ainda se eh uma venda de VP ou Nao.
		 "S" = Eh uma venda de Vale Presente.
		 "N" = Nao eh venda de Vale Presente.Eh venda de Prod.normal

@uso	 SIGALOJA / FRONTLOJA
/*/
//--------------------------------------------------------
Function Lj7VPNew()
Local aFuncs	:= {}
Local nCount 	:= 0
Local aType		:= {}
Local aFile		:= {}
Local aLine		:= {}
Local aDate		:= {}
Local aTime		:= {}
Local lOK 		:= .T.
Local dDataRef 	:= Nil

LjGrvLog(," Lj7VPNew | Inicio " )

//SOMENTE DEVE CONSIDERAR AS NOVAS MODIFICACOES NO VALE PRESENTE SE OS FONTES ESTIVEREM COM DATA IGUAL OU MAIOR QUE A DATA ESTIPULADA COMO DATA DE REFERENCIA

If lVPNewRegra == Nil
	dDataRef 	:= CToD("29/01/2014") //Data de referencia dos fontes

	//Fontes a serem verificados
	aAdd( aFuncs, "LOJA701" 		)	//Fonte LOJA701
	aAdd( aFuncs, "Lj7Prod" 		) 	//Fonte LOJA701A
	aAdd( aFuncs, "Lj7Gravacao" 	) 	//Fonte LOJA701C
	aAdd( aFuncs, "Lj7ImpCF" 		) 	//Fonte LOJA701D
	aAdd( aFuncs, "LjGrvTudo" 		) 	//Fonte LOJXFUNC
	aAdd( aFuncs, "FR271AProdOK"	) 	//Fonte FRTA271A
	aAdd( aFuncs, "FR271FAltVend"	) 	//Fonte FRTA271F
	aAdd( aFuncs, "FR271GEncerra"	) 	//Fonte FRTA271G
	aAdd( aFuncs, "FR271HCarrega"	) 	//Fonte FRTA271H
	aAdd( aFuncs, "A040DupRec"		) 	//Fonte MATXATU
	aAdd( aFuncs, "lj140Grava"		) 	//Fonte LOJA140

	//Verifica a data dos fontes no RPO
	For nCount := 1 To Len(aFuncs)
		aRet := GetFuncArray( aFuncs[nCount], @aType, @aFile, @aLine, @aDate, @aTime )
		If Len(aDate) > 0
			If CToD(DToc(aDate[1])) < dDataRef
				lOK := .F.
				Exit
			EndIf
		Else
			lOK := .F.
			Exit
		EndIf
	Next nCount

	If lOK
		lVPNewRegra := .T. //Utiliza as novas modificacoes na implementacao de Vale Presente
	Else
		lVPNewRegra := .F. //Continua utilizando a implementacao de Vale Presente
	EndIf
EndIf

Return lVPNewRegra


//------------------------------------------------
/*/{Protheus.doc} LjGrFinSE1
Efetua a gravação da tabela SE1 referente a integração da venda

@type  Function
@author  	JMM
@version 	P12.1.27
@since   	08/10/2019
@param   	aSE1, Array, Array a ser gravado
@param   	cE1Filial, Caracter, Filial
@param   	cE1Prefixo, Caracter, Prefixo
@param   	cE1Num, Caracter, Numero
@param   	cE1Parcela, Caracter, Parcela
@param   	cE1Tipo, Caracter, Tipo
@param   	nE1Recno, Recno, Recno do registro
@param   	lAglutina, Logico, Indica se deverá aglutinar as parcelas (Reclock False)		
@return	 	Logico, Retorna se conseguiu incluir/gravar o titulo
/*/
//------------------------------------------------
Function LjGrFinSE1( aSE1, cE1Filial, cE1Prefixo, cE1Num, cE1Parcela, cE1Tipo, nE1Recno, lAglutina)
Local lRet 		:= .T.
Local cChaveSE1 := PadR(cE1Filial,TamSx3("E1_FILIAL")[1]) + PadR(cE1Prefixo,TamSx3("E1_PREFIXO")[1]) + PadR(cE1Num,TamSx3("E1_NUM")[1]) + PadR(cE1Parcela,TamSx3("E1_PARCELA")[1]) + PadR(cE1Tipo,TamSx3("E1_TIPO")[1])
Local nX 		:= 0
Local lTplock	:= .T.		// -- Tipo do Lock, se sera alteração ou inclusão 

Default lAglutina := .F.	// -- Indica se o processo de aglutinação das parcelas esta ativo. 

LjGrvLog(cE1Num, "Grava SE1 - parâmetros recebidos.", {aSE1, cE1Filial, cE1Prefixo, cE1Num, cE1Parcela, cE1Tipo, nE1Recno, lAglutina} )

SE1->(dbSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

lTplock :=  !(SE1->( dbSeek(cChaveSE1) ))

If lTplock .Or. lAglutina
	RecLock( "SE1",lTplock)
	For nX := 1 To Len(aSE1)
		If aSE1[nX,1] == "E1_SERIE"
			SerieNfId( aSE1[nX,2], aSE1[nX,3], aSE1[nX,4], aSE1[nX,5], LjEspecieNF(), aSE1[nX,6] )
		Else
			&("SE1->"+aSE1[nX,1]) := aSE1[nX,2]
		EndIf	
	Next nX
	SE1->( MsUnlock() )
	nE1Recno := SE1->( Recno() )
Else 
	lRet := .F. 	
EndIf 

return lRet


//------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  LjCalVctDf
Calcula vencimento levando em conta somente dias úteis quando campo AE_TMPVCTO maior ou igual 1,
a parte inteira é numero de dias úteis para vencimento, neste caso as casas decimais são desconsiderados.
Quando campo AE_TMPVCTO menor que 1, a casa decimal é  horas corridas para o vencimento. 
@type 		function
@param 		dDtVencto, data, data de vencimento da parcela do cartão	
@author  	caio.okamoto
@since   	02/12/2019
@version 	P12
@return	    data, data de vencimento recalculado levando em conta campo AE_TMPVCTO
/*/
//------------------------------------------------------------------------------------------------------
Function LjCalVctDf(dDtVencto)
Local nDiasVcto := 0					//Qtde de dias para vencimento 
Local dDataVcto := dDtVencto			//Data de vencimento recalculado
Local nI 		:= 1					//Contador
Local nAeDias 	:= Iif(!Empty(SAE->AE_DIAS), SAE->AE_DIAS, 0)


dDataVcto := dDataVcto - nAeDias

If SAE->AE_TMPVCTO < 1 .AND. SAE->AE_TMPVCTO > 0  
	//Se menor que 1, então, a casa decimal é a quantidade de horas que o valor estará disponivel.
	//quando o vencimento é em horas (campo AE_TMPVCTO < 1.00 ) então o vencimento sempre será em tempo corrido.
	nDiasVcto := iif(SomaHoras(Time(), SubStr(StrZero(SAE->AE_TMPVCTO, TamSX3("AE_TMPVCTO")[1],2),4,2)) > 24, 1, 0 )
	dDataVcto := dDataVcto + nDiasVcto
Else 
	//Se SAE->AE_TMPVCTO maior ou igual a 1, então o cálculo será por dias úteis e as casas decimais serão desconsideradas.
	nDiasVcto := Int(SAE->AE_TMPVCTO)	
	For nI := 1 To  nDiasVcto
		dDataVcto ++
		dDataVcto := DataValida(dDataVcto, .T.)
	Next
Endif   

Return dDataVcto 


/*/
{Protheus.doc} LjObgImpNF
Verifica se a impressao do comprovante nao-fiscal é obrigatória
@type		function
@param		nTipoNF - tipo do comprovante nao-fiscal
@param		aMensagem - mensagem com o Aviso() que será dado ao usuário
@return		lRet - indica se a impressão do comprovante é obrigatória
@author  	michael.gabriel
@version 	P12.1.17
@since   	25/07/2017
/*/
Function LjObgImpNF(nTipoNF, aMensagem)

Local lRet			:= .F.
Local cMVLJOBINF	:= AllTrim( SuperGetMV("MV_LJOBINF",,"1") )

Default nTipoNF		:= 0
Default aMensagem	:= {}

/*
	nTipoNF pode ser:
	1: Recebimento de Titulos
	2: Recarga de Celular
	Se add uma nova opcao, adicione-a também no http://tdn.totvs.com/display/PROT/DT+MV_LJOBINF
*/
lRet := SubStr( cMVLJOBINF, nTipoNF, 1 ) == "2"	//obrigatorio

If lRet
	aMensagem := Array(3)
	Do Case
		Case nTipoNF == 1
			aMensagem[1] := "Recebimento de Titulo" + STR0004	// " não realizada."
		Case nTipoNF == 2
			aMensagem[1] := "Recarga de Celular" + STR0004
	EndCase

	aMensagem[2] := STR0001 + CRLF + STR0002 + "MV_LJOBINF"
	//# "Verifique se a impressora está ligada e conectada."
	//# "Contate o administrador do sistema para que ele valide a configuração do parâmetro: "
	aMensagem[3] := STR0003 //"Ok, Entendi"
EndIf

Return lRet


//----------------------------------------------------------------
/*/{Protheus.doc} Lj7AjstSLX
Função responsavel por ajustar o campo LX_CUPOM para os casos de
item cancelado ou cupom cancelado em ambiente que utilize impressora
nao-fiscal, no caso de NFC-e.

@param   cNumDoc  Numero do DOC
@param   cNumOrc  Numero do orcamento
@author  Varejo
@version P11
@since   26/06/2016
@return  Nil
/*/
//----------------------------------------------------------------
Function Lj7AjstSLX(cNumDOC, cNumOrc)
Local cCaixa 	:= ""
Local nX 		:= 0
Local cPdv   	:= LjGetStation("PDV")
Local cSerie	:= LjGetStation("SERIE")
Local nTamCupom := TamSX3("LX_CUPOM")[1]
Local nTamPdv 	:= TamSX3("LX_PDV")[1]
Local aSlxCanc	:= {}

Default cNumDOC := ""

If !Empty(cNumDOC) .And. AllTrim(Upper(cNumDOC)) != "NFCE"

	cCaixa 		:= xNumCaixa()
	aSlxCanc	:=LjGTaSlxCa()

	For nX:=1 to Len(aSlxCanc)
		SLX->(DbGoTo(aSlxCanc[nX])) //Posiciona no Registro a ser atualizado

		If AllTrim(Upper(SLX->LX_CUPOM)) == "NFCE"
			RecLock("SLX", .F.)
			SLX->LX_CUPOM := cNumDOC
			SLX->(MsUnLock())

			FRTGeraSLI( cCaixa, "LOG", Str(SLX->(Recno()),17,0), "NOVO" )
		EndIf

	Next nX

Else
	//Se nao foi passado o numero do DOC, entao os registros temporarios na SLX devem ser excluidos (Cujo DOC = "NFCe")
	DbSelectArea("SLX")
	SLX->( DbSetOrder(1) ) //LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM+LX_HORA
	While SLX->( DbSeek( xFilial("SLX")+PadR(cPdv,nTamPdv)+PadR("NFCe",nTamCupom)+cSerie ) )
		RecLock("SLX", .F.)
		SLX->(DbDelete())
		SLX->(MsUnLock())
	End
EndIf

LjClaSlxCa()

Return

//----------------------------------------------------------------
/*/{Protheus.doc} LjInfDocCli
Função que valida o retorno do param MV_LJDCCLI, sobre em
que momento pede o documento

@author  Varejo
@version P11
@since   07/04/2016
@return  nCallCpf
/*/
//----------------------------------------------------------------
Function LjInfDocCli()
Local nCallCPf	:= SuperGetMV("MV_LJDCCLI",,0)
Local cMsg		:= ""

/*
	Parametro criado para tratar aonde e de forma será pedido
	o CPF/CNPJ do cliente na emissão do cupom.
	No caso do TOTVSPDV, com o valor > 1 pode-se acessar toda
	vez a tela de CPF antes da finalização da venda

	Padrões:
	0 - Valida se o Estado exige CPF/CNPJ no documento de venda - AnalisaLEG(30)
	1 - Pergunta CPF/CNPJ no inicio da venda
	2 - Pergunta CPF/CNPJ no final da venda
	3 - Pergunta CPF/CNPJ no inicio e final da venda
*/
If !(nCallCPf >= 0)
	nCallCPf := 0
	cMsg := STR0005 //"Parametro MV_LJDCCLI não está configurado corretamente"
ElseIf nCallCPf > 3
	nCallCPf := 3
	cMsg := STR0006 //"Parametro MV_LJDCCLI acima do esperado, ajuste automatico"
EndIf

If !Empty(cMsg)
	LjGrvLog(NIL, cMsg)
	Conout("LjInfDocCli -> " + cMsg)
EndIf

Return nCallCPF


//----------------------------------------------------------------
/*/{Protheus.doc} LjFiGetEnd
Recebe um endereço completo e retorna o LOGRADOURO, NÚMERO e
COMPLEMENTO em um array. Baseada na função FisGetEnd
@param   cEndereco	Endereço completo (Rua, numero complemento)
@param   cUF		Estado
@param   lNotaElo	Indica se é NF Eletrônica (NF-e ou NFC-e)
@author  Varejo
@version P11
@since   14/10/2014
@return  aRet		Retorna um array de 4 posições: LOGRADOURO[C],
					NÚMERO[N], NÚMERO[C] e COMPLEMENTO[C]
/*/
//----------------------------------------------------------------
Function LjFiGetEnd(cEndereco, cUF, lNotaElo)

Local nPos		:= 0	//posição de determinado caracter dentro da string
Local nTamEnd	:= 0	//tamanho do campo ENDEREÇO
Local cEndAlte  := ""	//retorno do Ponto de Entrada FISATEND
Local lExterior := .F.	//indica se é um endereço estrangeiro
Local aRet		:= {}	//retorno da função

Local nNumero	:= 0	//NÚMERO do endereço no formato número
Local cNumero   := ""	//NÚMERO do endereço no formato caracter
Local cEnderec  := ""	//LOGRADOURO do endereço
Local cComplemen:= ""	//COMPLEMENTO do endereço
Local cAuxiliar := "" 

Default cUF		:= ""
Default lNotaElo:= .F.

If lNotaElo
	nTamEnd := 60
Else
	nTamEnd := 34
EndIf

//---
// PONTO DE ENTRADA FISATEND
//---
If ExistBlock('FISATEND')
	LjGrvLog( Nil, " Antes da execução do P.E. FISATEND", {cEndereco, cUF})
	cEndAlte := ExecBlock( 'FISATEND',.F.,.F., {cEndereco, cUF} )
	LjGrvLog( Nil, " Depois da execução do P.E. FISATEND", cEndAlte)
	If ValType(cEndAlte) == "C"
		If !Empty(cEndAlte)
			cEndereco := cEndAlte
		EndIf
	EndIf
EndIf

//---
// verifica se é um endereço estrangeiro EX
//---
lExterior := (cUF == "EX")

//---
// procuramos a ultima vírgula, pois a sua direita está o NÚMERO e COMPLEMENTO
//---
nPos := Rat(",",cEndereco)

If nPos > 0
	If !lExterior
		cAuxiliar := AllTrim( SubStr(cEndereco, nPos+1) )
	Else
		cAuxiliar := Left(cEndereco, nPos-1)
	EndIf
	nNumero := Int( Val(cAuxiliar) )

	If nNumero <> 0
		If !lExterior
			cEnderec := AllTrim( PadR(SubStr(cEndereco, 1, nPos-1), nTamEnd) )
		Else
			cEnderec := PadR(LTrim(SubStr(cEndereco, nPos+1)), nTamEnd)
		EndIf
	Else
		If lNotaElo
			cEnderec := PadR(cEndereco, nTamEnd)
		Else
			cEnderec := PadR(SubStr(cEndereco,1,nPos-1), nTamEnd)
		EndIf
	EndIf

	//procuramos pelo espaço em branco " " entre NÚMERO e COMPLEMENTO, pois a informação a direita será o COMPLEMENTO
	If nNumero <> 0
		nPos := At(" ", AllTrim(cAuxiliar))
		If nPos > 0
			cComplemen := Alltrim( SubStr(cAuxiliar, nPos+1) )
		EndIf
	EndIf
//---
//se não tem vírgula, usaremos um espaço em branco "" como separador
//---
Else
	nPos		:= Rat(" ", AllTrim(cEndereco))
	cEnderec	:= RTrim( cEndereco )
	cNumero     := AllTrim( SubStr(cEndereco, nPos+1) )
	nNumero		:= Val(cNumero)
	//não há como pegar o COMPLEMENTO, pois o ultimo espaço a direita separa o ENDEREÇO do NÚMERO
EndIf

//convertemos o NÚMERO em string, caso seja necessário utilizá-lo
cNumero := cValToChar(nNumero)

aRet := {cEnderec,nNumero,cNumero,cComplemen}

Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} LjDataConv
Realiza a conversão de uma data no formato AAAAMMDD em
em uma string no formato da mascara desejada
@param   dData	Data que se deseja converter
@param   cMasc	Mascara que será aplicada na data
@author  Varejo
@version P11
@since   20/10/2014
@return  cRet	Data no formato string
@obs	 Cópia da função FsDataConv(MATA950.PRW), pois no
			TOTVS PDV, esse fonte não estará presente no RPO
/*/
//------------------------------------------------------------------------------
Function LjDataConv( dData, cMasc )

Local cDia := ""
Local cMes := ""
Local cAno := ""
Local cData:= ""
Local cRet := ""
Local cAux := ""

Default dData := StoD("//")
Default cMasc := "DDMMYYYY"

cData := DtoS(dData)

cDia := SubStr(cData,7,2)
cMes := SubStr(cData,5,2)
cAno := SubStr(cData,1,4)

While !Empty(cMasc)
	cAux := SubStr(cMasc,1,2)

	Do Case
		Case cAux == "DD"
			cRet += cDia
		Case cAux == "MM"
			cRet += cMes
		Case cAux == "YY"
			If SubStr(cMasc,1,4) == "YYYY"
				cRet += cAno
				cMasc := SubStr(cMasc,3)
			Else
				cRet += SubStr(cAno,3)
			EndIf
	EndCase

	cMasc := SubStr(cMasc,3)
EndDo

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LjNumDecre
Retorna um valor, onde cada número será invertido para sua forma decrescente(9-0)
@param   cValor	Valor que se deseja converter
@author  Varejo
@version P11
@since   20/10/2014
@return  cRet	Valor invertido
@obs	 Copiamos e refatoramos a função Inverte(SPEDNFE.PRX), pois no TOTVS PDV,
				esse fonte não estará presente no repositório
/*/
//------------------------------------------------------------------------------
Function LjNumDecre(cValor)

Local cRet	:= ""
Local cByte	:= ""
Local nPos	:= 0
Local nI	:= 0
Local aChar	:= {}

Default cValor := ""

Aadd( aChar, {"0", "9"} )
Aadd( aChar, {"1", "8"} )
Aadd( aChar, {"2", "7"} )
Aadd( aChar, {"3", "6"} )
Aadd( aChar, {"4", "5"} )
Aadd( aChar, {"5", "4"} )
Aadd( aChar, {"6", "3"} )
Aadd( aChar, {"7", "2"} )
Aadd( aChar, {"8", "1"} )
Aadd( aChar, {"9", "0"} )

For nI := 1 to Len(cValor)

	cByte := Upper( Substr(cValor,nI,1) )

	If IsDigit(cByte)
		nPos := Ascan( aChar,{|x| x[1] == cByte} )
		If nPos > 0
			cRet := cRet + aChar[nPos][2]
		EndIf
	EndIf

Next

Return cRet




//-----------------------------------------------------------
/*/{Protheus.doc} LjFiGetTel
Recebe um telefone e retorna  DDI, DDD e Telefone em um array
Se usar os parametros cArea e cPais, esses dados não serão
extraidos do telefone passado como parametro
@param   cFone	Telefone completo (com/sem DDI e/ou DDD)
@param   cArea	DDD (com dois dígitos)
@param   cPais	DDI (com dois dígitos)
@author  Varejo
@version P11
@since   14/10/2014
@return  aRet	Retorna DDI[N], DDD[N] e Telefone
/*/
//-----------------------------------------------------------
Function LjFiGetTel(cFone, cArea, cPais)

Local nTelefone := 0	//número do TELEFONE
Local nCodArea	:= 0	//código da ÁREA (DDD)
Local nCodPais	:= 0	//código do PAÍS (DDI)
Local nDigitos 	:= 0	//quantidade de dígitos do número de telefone
Local nI		:= 0 	//contador
Local cChar 	:= ""
Local cAux		:= ""   //número completo do telefone sem caracteres inválidos
Local aRet		:= {}	//retorno com PAÍS, ÁREA e TELEFONE
Local nTamFone	:= 0

Default cFone	:= ""
Default cArea	:= ""
Default cPais	:= ""

If !Empty(cFone) .And. !Empty(cArea)
	//retiramos todos os caracteres que não são numéricos
	nDigitos := Len(cFone)
	For nI := 1 to nDigitos
		cChar := SubStr(cFone, nI, 1)
		If IsDigit(cChar)
			cAux += cChar
		EndIf
	Next

	//verificamos se o número possui 8 ou 9 dígitos
	nDigitos := Len(cAux)
	If nDigitos % 2 == 0
		nTamFone := 8
	Else
		nTamFone := 9
	EndIf

	//---------------------------------------
	//código do País: XXyyzzzzzzzz	2 dígitos
	//código da Área: xxYYzzzzzzzz	2 dígitos
	//telefone		: xxyyZZZZZZZZ	8 dígitos
	//telefone		: xxyyZZZZZZZZZ 9 dígitos
	//---------------------------------------
	If Empty(cPais) .AND. nDigitos == (nTamFone+4)
		nCodPais := Val( SubStr(cAux, 1, 2) )	//DDI
		nCodArea := Val( SubStr(cAux, 3, 2) )	//DDD
	ElseIf Empty(cArea) .AND. nDigitos == (nTamFone+2)
		nCodArea := Val( SubStr(cAux, 1, 2) )	//DDD
	Else
		nCodPais := Val(cPais)
		nCodArea := Val(cArea)
	EndIf

	nTelefone := Val( Right(cAux,nTamFone) )	//telefone
EndIf

aRet := {nCodPais, nCodArea, nTelefone}

Return aRet



/*/{Protheus.doc} LjAltPermi
	Define o valor padrão de um novo nivel de acesso de uma determinada posição da SLF
	@type  Function
	@author Lucas Novais
	@since 01/02/2018
	@version P11.80
	@param nAcessoLf, Numerico, Recebe a posição do acesso que será alterado
/*/
Function LjAltPermi(nAcessoLf)
Local cAcessoLF	:= ""			//Variável responsável por armazenar as permissões do
Local aUsersAlt	:= {}			//Variável responsável por armazenar os superiores do caixa atual caso tenha
Local nX 		:= 1			//Variavel para For

DbSelectArea("SLF")
SLF->(dbSetOrder(1)) //LF_FILIAL+LF_COD

If SLF->(DbSeek(xFilial("SLF")+xNumCaixa()))
	cAcessoLF := SLF->LF_ACESSO
	If Empty(Subst(cAcessoLF,nAcessoLf,1))
		//Recebo os superiores atrelados ao usuario
		aUsersAlt	:= LjRetSup()
		//Altero o conteudo da posição recebida para "S"
		cAcessoLF := STUFF(cAcessoLF,nAcessoLf,1,"S")
		Reclock("SLF",.F.)
		SLF->LF_ACESSO := cAcessoLF
		SLF->(MsUnlock())
	Endif

	For nX := 1 To len(aUsersAlt)
		If SLF->(DbSeek(xFilial("SLF")+aUsersAlt[nX]))
			cAcessoLF := SLF->LF_ACESSO
			If Empty(Subst(cAcessoLF,nAcessoLf,1))
				//Altero o conteudo da posição recebida para "S"
				cAcessoLF := STUFF(cAcessoLF,nAcessoLf,1,"S")
				Reclock("SLF",.F.)
				SLF->LF_ACESSO := cAcessoLF
				SLF->(MsUnlock())
			Endif
		Endif
	Next
Endif
Return

/*/{Protheus.doc} LjValIFin
	Verifica se a tabela estática do financeiro está alimentada, caso negativo, avisa ao usuário para acessar o módulo financeiro
	@type  Static Function
	@author fabiana.silva
	@since 29/03/2018
	@version 12.1.17
/*/
Function LjValIFin()
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaFKB 	:= FKB->(GetArea())

FKB->(DbSetOrder(1))

lRet := FKB->(DbSeek(xFilial("FKB")))

RestArea(aAreaFKB)
RestArea(aArea)

If !lRet
	MsgStop(STR0007)//"As tabelas necessárias para as rotinas financeiras estão vazias. Necessário realizar um primeiro acesso ao módulo Financeiro (SIGAFIN) nesta filial para carga automática dessas tabelas."
	LjGrvLog("",STR0007) //"As tabelas necessárias para as rotinas financeiras estão vazias. Necessário realizar um primeiro acesso ao módulo Financeiro (SIGAFIN) nesta filial para carga automática dessas tabelas."
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |LjIpPrx  y³ Autor ³ Vendas Clientes       ³ Data ³03/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o IP do Proxy                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cIP - Endereço IP                  						  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjIpPrxy()
Local cHtmlPage := "'
Local cBody := "<BODY>"
Local cBodyF := "</BODY>
Local nBody := 0
Local nBodyF := 0
Local cTexto := ""

// Buscar página
//Realiza uma requisição HTTP na URL http://checkip.dyndns.org/ - timeout 10 segundos
//Retorno <html><head><title>Current IP Check</title></head><body>Current IP Address: XXX.XX.XX.X</body></html>
cHtmlPage := Httpget('http://checkip.dyndns.org/',,10)


If HTTPGetStatus() == 200 //200 = OK, diferente de 200 = erro

	cHtmlPage := Upper(cHtmlPage)
	nBody := At(cBody, cHtmlPage)
	nBodyF := At(cBodyF, cHtmlPage)
	cBody := AllTrim(Substr(cHtmlPage, nBody+Len(cBody), nBodyF-(nBody+Len(cBody))))
	nBody := Len(cBody)

	While !Empty(cBody)
		cBodyF := Right(cBody,1)
		cBody := Left(cBody,Len(cBody)-1)
		If IsDigit(cBodyF) .Or. cBodyF == "."
			cTexto := cBodyF + cTexto
		ElseIf !Empty(cTexto)
			cBody := ""
		EndIf
	End

EndIf

ConOut("LjIpPrxy - Retorno: " + cTexto)

Return cTexto

/*/{Protheus.doc} LjIsMDI()
Verifica se fez acesso ao sistema como SIGAMDI.

@type  	 Function
@author  Alberto Deviciente
@since 	 15/04/2020
@version P12.1.27

@return Lógico, Retorna se fez acesso ao sistema como SIGAMDI.
/*/
Function LjIsMDI()
Local lIsSigaADV 	:= .F.

If lIsMDI == Nil
	//Verifica se acessou o sistema como SIGAADV, pois com a LIB de Jan/2020 o sistema passou a setar o atributo oApp:lMDI como .T., independente se acessar como SIGAADV ou SIGAMDI.
	lIsSigaADV 	:= Iif( ExistFunc("FWIsMDILikeADV"), FWIsMDILikeADV(), IsInCallStack("SIGAADV") )
	
	//Somente seta que é MDI se não for acessado como SIGAADV
	lIsMDI := Type("oApp") == "O" .And. oApp:lMDI .And. !lIsSigaADV
EndIf

Return lIsMDI

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJ7aReceb
Retorna o array aReceb que é responsavel pela geração dos Titulos a Receber (SE1).

@type 		function
@author  	michael.gabriel
@since   	06/03/2017
@version 	P11.8

@param		lScreen, Lógico, Indica se há interface de tela ou nao.
@param		lTEFNSUDigit, Lógico, Indica se o NSU do TEF foi digitado manualmente.

@return 	aRet, Array, Vetor com as parcelas referentes ao pagamento.
/*/
//-------------------------------------------------------------------------------------
Function LJ7aReceb(lScreen, lTEFNSUDigit)
Local cDocTEF		:= ""
Local cNSUTEF		:= ""
Local cAUTTEF       := ""
Local cParcTEF		:= ""
Local cCodAdmFin	:= ""
Local cTextoErro	:= ""
Local nPosForma		:= 0
Local nTotPag		:= 0 
Local lGPDirecao	:= .F.												//Indica se o Gerenciador TEF é Direção
Local lRetAux		:= .T.
Local aDTEFPend		:= {}												//Array do Vetor de Transações DTEF
Local aReceb		:= {}
Local aRet			:= {}
Local cMvLjAdmGn	:= AllTrim( SuperGetMV("MV_LJADMGN",,"") )
Local nTamAECOD  	:= TamSX3("AE_COD")[1]
Local lL4DESCMN		:= SL4->(ColumnPos("L4_DESCMN")) > 0
Local lIDCNAB		:= SL4->(ColumnPos("L4_IDCNAB")) > 0
Local cIdCNAB		:= "" 												//IDCNAB para gravação do Financeiro
Local lIntegDef		:= SL1->L1_ORIGEM == "N"                			//Venda Origem Integração
Local lIntegHtl		:= lIntegDef .And. SuperGetMv("MV_INTHTL",, .F.) 	//Integracao Hotelaria
Local lIntegEAI		:= FWHasEAI("LOJXFUNC",.T.,, .T.) 					//Integração Varejo envio do status ou Erro do processamento da venda
Local dDataDoc		:= dDataBase										// Data do Documento

Default lScreen		:= .T.
Default lTEFNSUDigit:= .F.

/* atribuicao de valores as variaveis declaradas */
lGPDirecao	:= cTipTEF == TEF_DISCADO .AND. L010IsDirecao(L010GetGPAtivo())

// cria vetor que sera utilizado para gravacao das parcelas
If lUsaTEF .AND. lGPDirecao
	aDTEFPend :=  LJLoadDTEF() 
EndIf

// abre a tabela SAE e atribui o indice 1, pois sera feito um seek logo abaixo
DbSelectArea("SAE")
SAE->( DbSetOrder(1) )	//AE_FILIAL + AE_COD

While ! SL4->(Eof()) .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. SL1->L1_NUM == SL4->L4_NUM .AND. Empty(SL4->L4_ORIGEM)

	cDocTEF  := ""
    cNSUTEF  := ""
    cAUTTEF  := ""

    If !Empty(SL4->L4_PARCTEF)
		cParcTEF  := SL4->L4_PARCTEF
	Else
		cParcTEF  := SL1->L1_PARCTEF
    EndIf

	If lScreen

		If AllTrim(SL4->L4_FORMA) $ _FORMAPGDG //Pagamento Digital
            cDocTEF  := SL4->L4_DOCTEF   
            cNSUTEF  := SL4->L4_NSUTEF
            cAUTTEF  := SL4->L4_AUTORIZ

		ElseIf lUsaTEF .AND. cTiptef == TEF_CLISITEF
	        If AllTrim(SL4->L4_FORMA) $ __FORMATEF
	        	nPosForma := Ascan(oTEF:aRetCartao, {|x| AllTrim(x:cForma)+AllTrim(x:cIDCart) == AllTrim(SL4->L4_FORMA)+AllTrim(SL4->L4_FORMAID) } )
				If nPosForma > 0
					cDocTEF  := oTef:aRetCartao[nPosForma]:cNsuAutor
					cNSUTEF  := oTef:aRetCartao[nPosForma]:cNsuSitef
					cAUTTEF  := oTef:aRetCartao[nPosForma]:cAutoriza
				EndIf
				If !oTEF:lTEFOk .AND. lTEFNSUDigit .AND. Empty(cNSUTEF+cDocTEF+cAUTTEF) .OR.; //Se não achou o TEF Verifica se não foi gravado TEF Manual
					(IsInCallStack("LJ7PEDIDO") .AND. oTEF:lTEFOk .AND. Empty(cNSUTEF+cDocTEF+cAUTTEF) .AND. !Empty(SL4->L4_NSUTEF+SL4->L4_DOCTEF+SL4->L4_AUTORIZ))
					cDocTEF  := SL4->L4_DOCTEF   
					cNSUTEF  := SL4->L4_NSUTEF 
					cAUTTEF  := SL4->L4_AUTORIZ               	
				EndIf
            EndIf
        ElseIf lUsaTEF .AND. lGPDirecao  .AND. AllTrim(SL4->L4_FORMA) $ __FORMATEF .AND. Len(aDTEFPend) > 12
			nPosForma := aScan(aDTEFPend, {|t| t[14] == RTrim(IIF(Empty(SL4->L4_FORMAID), "1",SL4->L4_FORMAID)) .AND. t[3] == RTrim(SL4->L4_FORMA) })
			If nPosForma > 0
				cDocTEF := aDTEFPend[nPosForma][13]
				cNSUTEF := Right(aDTEFPend[nPosForma][07],6)
				cAUTTEF := ""
			EndIf
		ElseIf lUsaTEF .AND. cTipTEF == TEF_DISCADO .AND. AllTrim(SL4->L4_FORMA) $ __FORMATEF
	       	nPosForma := aScan(aTefDados,{|x|, Alltrim(x[19]) == IIF(!Empty(SL4->L4_FORMAID), SL4->L4_FORMAID, "1")})
	       	
			If nPosForma > 0
				cDocTEF  := aTefDados[nPosForma][5]
       			cNSUTEF  := aTefDados[nPosForma][9]
       			cAUTTEF  := aTEFDados[nPosForma][5]
			Else
				cDocTEF  := SL4->L4_DOCTEF   
				cNSUTEF  := SL4->L4_NSUTEF
				cAUTTEF  := SL4->L4_AUTORIZ
			EndIf
	
		/*
		 Qdo TEF Manual o NSU é digitado manualmente, venda com multiplos cartoes 
		 dai os arrays acima (aTEfDados, oTef:aRetCartao,aDTEFPend) vem com uma posicao, portanto pego o conteudo dos 
		 campos da SL4 que foram preenchidos manualmente no LOJA701C
		*/  
		ElseIf lTEFNSUDigit .AND. (!Empty(SL4->L4_DOCTEF) .Or. !Empty(SL4->L4_AUTORIZ))
      		cDocTEF  := SL4->L4_DOCTEF
      		cNSUTEF  := SL4->L4_NSUTEF
      		cAUTTEF  := SL4->L4_AUTORIZ
		EndIf
	Else
		cDocTEF  := SL4->L4_DOCTEF
		cNSUTEF  := SL4->L4_NSUTEF
		cAUTTEF  := SL4->L4_AUTORIZ
	EndIf

	If lIDCNAB            
		cIdCNAB := AllTrim(SL4->L4_IDCNAB)
	EndIf

	dDataDoc  := If( SL4->L4_DATA <= dDataBase, dDataBase, SL4->L4_DATA	)

    Aadd(aReceb,{ dDataDoc 			,;							//01 - Data de vencimento
		         SL4->L4_VALOR		,;							//02 - Valor da parcela
		         SL4->L4_FORMA		,;							//03 - Forma de recebimento
		         SL4->L4_ADMINIS	,;							//04 - Codigo e nome da Administradora
		         SL4->L4_NUMCART	,;							//05 - Numero do cartao/cheque
		         SL4->L4_AGENCIA	,;							//06 - Agencia do cheque
		         SL4->L4_CONTA		,; 							//07 - Numero da conta do cheque
		         SL4->L4_RG			,;							//08 - RG do portador do cheque
		         SL4->L4_TELEFON	,; 							//09 - Telefone do portador do cheque
		         SL4->L4_TERCEIR	,; 							//10 - Indica se o cheque e de terceiros
		         IIf(cPaisLoc == "BRA",1,SL4->L4_MOEDA),; 		//11 - Moeda da parcela
		         cParcTEF			,; 							//12 - Tipo de parcelamento(Client SiTEF DLL)
			   	 IIf(cPaisLoc == "BRA",SL4->L4_ACRSFIN, 0),;	//13 - Acrescimo Financeiro
			   	 SL4->L4_NOMECLI	,;							//14 - Nome Emitente quando cheque de terceiro
			   	 SL4->L4_FORMAID	,; 							//15 - ID do Cartao de Credito ou Debito
			   	 cNSUTEF			,;							//16 - NSU da trasacao TEF
			   	 cDocTEF  			,; 							//17 - Num. Documento TEF
			   	 SL4->(Recno())		,;  						//18 - Numero Registro SL4
			   	 IIf(lL4DESCMN, SL4->L4_DESCMN, 0 ),;			//19 - Desconto MultNegociacao
			   	 IIf(lIntegHtl, SL4->L4_CONHTL, ""),; 			//20 - Conta Hotel
				 cAUTTEF 			,; 							//21 - Codigo Autorizacao TEF
				 SL4->L4_COMP  		,; 							//22 - Compesação
				 cIdCNAB  			}) 							//23 - IDCNAB

	//soma o valor dos pagamentos (sera utilizado se houver retencao de PCC)
	nTotPag += SL4->L4_VALOR
	
	//obtemos o codigo da administradora financeira
	cCodAdmFin := Left( SL4->L4_ADMINIS, nTamAECOD )

	If AllTrim(SL4->L4_FORMA) $ "FI/CC/CD" .AND. !Empty(cMvLjAdmGn) .AND. !SAE->( MsSeek(xFilial("SAE") + cCodAdmFin) )		
		//tratamento para o log
		cTextoErro := STR0011 + SL1->L1_NUM + Chr(10) + STR0012 + AllTrim(SL4->L4_ADMINIS)	 //"Orcamento:" ### "Financiadora nao encontrada: "
		LjMsgGrvTudo( lScreen, SL1->L1_NUM, cTextoErro )			
		LjGravaErr( cTextoErro )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a integração com EAI Enviando o Erro.         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lIntegEAI .AND. !Empty(cTextoErro)
			//ConOut("LOJIXFUNC:(697) Start IntegDef EAI Enviando o Erro: "+cTextoErro)
			FwIntegDef("LOJXFUNC",EAI_MESSAGE_BUSINESS,TRANS_SEND,cTextoErro, "LOJXFUNC")
		Endif		

		//tratamento pra o retorno da funcao
		lRetAux := .F.
		Exit
	EndIf

	SL4->(DbSkip())
End

// se houve a retencao do PCC, será necessario somar esse valor aos titulos que serao gerados 
If lRetAux .AND. SL1->L1_ABTOPCC > 0
	aReceb := aClone( LjRatPCC(nTotPag, aReceb) )
EndIf

//retorno da funcao
Aadd( aRet, lRetAux) //[1] indica se foi executada com sucesso
Aadd( aRet, aReceb ) //[2] array com os dados dos pagamentos

Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjRatPCC
Função responsavel em ratear o valor da retenção PCC entre as parcelas.

@type 		function
@author 	michael.gabriel
@since 		06/03/2017
@version 	P11.8

@param		nTotPag, Numérico, Valor total do pagamento.
@param		aReceb, Array, Vetor com as parcelas referentes ao pagamento.

@return 	aReceb, Array, Vetor com as parcelas somadas ao valor de retenção do PCC

@obs Somamos a retençao, pois no Financeiro, os titulos devem ser gerados sem a retenção,
pois serao incluidos registros com cada abatimento
/*/
//-------------------------------------------------------------------------------------
Static Function LjRatPCC(nTotPag, aReceb)
Local nFator	:= 0	//Indica quanto o valor da parcela equivale ao total da venda
Local nVlrPCC	:= 0	//Valor da retenção do PCC que sera adicionado a respectiva parcela 
Local nTotPCC	:= 0	//Valor total da retenção do PCC
Local nSobra	:= 0	//Valor restante da retenção do PCC que sera adicionado a ultima parcela
Local nParcelas := 0	//Quantidade de parcelas
Local nI		:= 0

Default nTotPag := 0
Default aReceb	:= {}

nTotPCC := LjPCCRet()	//Valor total da retencao do PCC
nSobra := nTotPCC		//Atribui a sobra, o valor total da retencao do PCC

nParcelas := Len(aReceb)
 
For nI := 1 to nParcelas
	
	If nI = nParcelas
		nVlrPCC := nSobra
	Else
		nFator := aReceb[nI][2] / nTotPag
		nVlrPCC := NoRound( nFator * nTotPCC, 2 )
		nSobra -= nVlrPCC	//a cada parcela, subtrai o valor usado do PCC
	EndIf

	aReceb[nI][2] += nVlrPCC
Next

Return aReceb

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRetStatusSEFAZ
Função analisa o codigo de retorno gravado no campo L1_RETSFZ pelo TSS

@param   cStatus Codigo retorno TSS
@param   cMsg Mensagem retornada pelo TSS 
@author  Anderson Machado
@since   20/12/2017
@version P11
@return  Caracter, Retorna a sigla referente ao cStatus solicitado
/*/
//-------------------------------------------------------------------
Function LjRetStatusSEFAZ(cStatus, cMsg)
Local nX 	:= 0 
Local sRet	:= ""

//-- AUTORIZACAO
Local aCRAutNFE:= {"100|Autorizado o uso da NF-e",;
					"101|Cancelamento de NF-e homologado",;
					"124|EPEC Autorizado",;
					"150|Autorizado o uso da NF-e, autorização fora de prazo",;				
					"142|Ambiente de Contingência EPEC bloqueado para o Emitente"}

//-- PROCESSAMENTO
Local aCRProNFE := {"103|Lote recebido com sucesso",;
						"104|Lote processado",;
						"105|Lote em processamento",;
						"106|Lote não localizado",;
						"128|Lote de Evento Processado"}

//-- STATUS SERVICO
Local aCRStaNFE := {"107|Serviço em Operação",;
						"108|Serviço Paralisado Momentaneamente (curto prazo)",;
						"109|Serviço Paralisado sem Previsão"}

//-- CONSULTA Contribuinte
Local aCRConNFE := {"111|Consulta cadastro com uma ocorrência",;
						"112|Consulta cadastro com mais de uma ocorrência"}

//-- MANIFESTO
Local aCRManNFE := {"135|Evento registrado e vinculado a NF-e",;
						"136|Evento registrado, mas não vinculado a NF-e",;
						"137|Nenhum documento localizado para o destinatário",;
						"138|Documento localizado para o destinatário",;
						"139|Pedido de Download processado",;
						"140|Download disponibilizado"}

 //-- TABELA DE REJEIÇÕES
Local aCRRejNFE := {"201|Rejeição: Número máximo de numeração a inutilizar ultrapassou o limite",;
						"202|Rejeição: Falha no reconhecimento da autoria ou integridade do arquivo digital",;
						"203|Rejeição: Emissor não habilitado para emissão de NF-e",;
						"204|Duplicidade de NF-e [nRec:999999999999999]",;
						"205|NF-e está denegada na base de dados da SEFAZ [nRec:999999999999999]",;
						"206|Rejeição: NF-e já está inutilizada na Base de dados da SEFAZ",;
						"207|Rejeição: CNPJ do emitente inválido",;
						"208|Rejeição: CNPJ do destinatário inválido",;
						"209|Rejeição: IE do emitente inválida",;
						"210|Rejeição: IE do destinatário inválida",;
						"211|Rejeição: IE do substituto inválida",;
						"212|Rejeição: Data de emissão NF-e posterior a data de recebimento",;
						"213|Rejeição: CNPJ-Base do Emitente difere do CNPJ-Base do Certificado Digital",;
						"214|Rejeição: Tamanho da mensagem excedeu o limite estabelecido",;
						"215|Rejeição: Falha no schema XML",;
						"216|Rejeição: Chave de Acesso difere da cadastrada",;
						"217|Rejeição: NF-e não consta na base de dados da SEFAZ",;
						"218|NF-e já está cancelada na base de dados da SEFAZ [nRec:999999999999999]",;
						"219|Rejeição: Circulação da NF-e verificada",;
						"220|Rejeição: Prazo de Cancelamento superior ao previsto na Legislação",;
						"221|Rejeição: Confirmado o recebimento da NF-e pelo destinatário",;
						"222|Rejeição: Protocolo de Autorização de Uso difere do cadastrado",;
						"223|Rejeição: CNPJ do transmissor do lote difere do CNPJ do transmissor da consulta",;
						"224|Rejeição: A faixa inicial maior que a faixa final",;
						"225|Rejeição: Falha no Schema XML do lote de NFe",;
						"226|Rejeição: Código da UF do Emitente diverge da UF autorizadora",;
						"227|Rejeição: Erro na Chave de Acesso | Campo Id | falta a literal NFe",;
						"228|Rejeição: Data de Emissão muito atrasada",;
						"229|Rejeição: IE do emitente não informada",;
						"230|Rejeição: IE do emitente não cadastrada",;
						"231|Rejeição: IE do emitente não vinculada ao CNPJ",;
						"232|Rejeição: IE do destinatário não informada",;
						"233|Rejeição: IE do destinatário não cadastrada",;
						"234|Rejeição: IE do destinatário não vinculada ao CNPJ",;
						"235|Rejeição: Inscrição SUFRAMA inválida",;
						"236|Rejeição: Chave de Acesso com dígito verificador inválido",;
						"237|Rejeição: CPF do destinatário inválido",;
						"238|Rejeição: Cabeçalho / Versão do arquivo XML superior a Versão vigente",;
						"239|Rejeição: Cabeçalho / Versão do arquivo XML não suportada",;
						"240|Rejeição: Cancelamento/Inutilização / Irregularidade Fiscal do Emitente",;
						"241|Rejeição: Um número da faixa já foi utilizado",;
						"242|Rejeição: Cabeçalho / Falha no Schema XML",;
						"243|Rejeição: XML Mal Formado",;
						"244|Rejeição: CNPJ do Certificado Digital difere do CNPJ da Matriz e do CNPJ do Emitente",;
						"245|Rejeição: CNPJ Emitente não cadastrado",;
						"246|Rejeição: CNPJ destinatário não cadastrado",;
						"247|Rejeição: Sigla da UF do Emitente diverge da UF autorizadora",;
						"248|Rejeição: UF do Recibo diverge da UF autorizadora",;
						"249|Rejeição: UF da Chave de Acesso diverge da UF autorizadora",;
						"250|Rejeição: UF diverge da UF autorizadora",;
						"251|Rejeição: UF/Município destinatário não pertence a SUFRAMA",;
						"252|Rejeição: Ambiente informado diverge do Ambiente de recebimento",;
						"253|Rejeição: Digito Verificador da chave de acesso composta inválida",;
						"254|Rejeição: NF-e complementar não possui NF referenciada",;
						"255|Rejeição: NF-e complementar possui mais de uma NF referenciada",;
						"256|Rejeição: Uma NF-e da faixa já está inutilizada na Base de dados da SEFAZ",;
						"257|Rejeição: Solicitante não habilitado para emissão da NF-e",;
						"258|Rejeição: CNPJ da consulta inválido",;
						"259|Rejeição: CNPJ da consulta não cadastrado como contribuinte na UF",;
						"260|Rejeição: IE da consulta inválida",;
						"261|Rejeição: IE da consulta não cadastrada como contribuinte na UF",;
						"262|Rejeição: UF não fornece consulta por CPF",;
						"263|Rejeição: CPF da consulta inválido",;
						"264|Rejeição: CPF da consulta não cadastrado como contribuinte na UF",;
						"265|Rejeição: Sigla da UF da consulta difere da UF do Web Service",;
						"266|Rejeição: Série utilizada não permitida no Web Service",;
						"267|Rejeição: NF Complementar referencia uma NF-e inexistente",;
						"268|Rejeição: NF Complementar referencia outra NF-e Complementar",;
						"269|Rejeição: CNPJ Emitente da NF Complementar difere do CNPJ da NF Referenciada",;
						"270|Rejeição: Código Município do Fato Gerador: dígito inválido",;
						"271|Rejeição: Código Município do Fato Gerador: difere da UF do emitente",;
						"272|Rejeição: Código Município do Emitente inexistente",;
						"273|Rejeição: Código Município do Emitente: difere da UF do emitente",;
						"274|Rejeição: Código Município do destinatário inexistente",;
						"275|Rejeição: Código Município do destinatário: difere da UF do destinatário",;
						"276|Rejeição: Código Município do Local de Retirada inexistente",;
						"277|Rejeição: Código Município do Local de Retirada: difere da UF do Local de Retirada",;
						"278|Rejeição: Código Município do Local de Entrega inexistente",;
						"279|Rejeição: Código Município do Local de Entrega: difere da UF do Local de Entrega",;
						"280|Rejeição: Certificado Transmissor inválido",;
						"281|Rejeição: Certificado Transmissor Data Validade",;
						"282|Rejeição: Certificado Transmissor sem CNPJ",;
						"283|Rejeição: Certificado Transmissor | erro Cadeia de Certificação",;
						"284|Rejeição: Certificado Transmissor revogado",;
						"285|Rejeição: Certificado Transmissor difere ICP-Brasil",;
						"286|Rejeição: Certificado Transmissor erro no acesso a LCR",;
						"287|Rejeição: Código Município do Fato Gerador de ISSQN inexistente [nItem:nnn]",;
						"288|Rejeição: Código Município do Fato Gerador do Transporte inexistente",;
						"289|Rejeição: Código da UF informada diverge da UF solicitada",;
						"290|Rejeição: Certificado Assinatura inválido",;
						"291|Rejeição: Certificado Assinatura Data Validade",;
						"292|Rejeição: Certificado Assinatura sem CNPJ",;
						"293|Rejeição: Certificado Assinatura / erro Cadeia de Certificação",;
						"294|Rejeição: Certificado Assinatura revogado",;
						"295|Rejeição: Certificado Assinatura difere ICP-Brasil",;
						"296|Rejeição: Certificado Assinatura erro no acesso a LCR",;
						"297|Rejeição: Assinatura difere do calculado",;
						"298|Rejeição: Assinatura difere do padrão do Sistema",;
						"299|Rejeição: XML da área de cabeçalho com codificação diferente de UTF-8",;
						"301|Uso Denegado: Irregularidade fiscal do emitente",;
						"302|Rejeição: Irregularidade fiscal do destinatário",;
						"303|Uso Denegado: destinatário não habilitado a operar na UF",;
						"304|Rejeição: Pedido de Cancelamento para NF-e com evento da Suframa",;
						"315|Rejeição: Data de Emissão anterior ao início da autorização de Nota Fiscal na UF",;
						"316|Rejeição: Nota Fiscal referenciada com a mesma Chave de Acesso da Nota Fiscal atual",;
						"317|Rejeição: NF modelo 1 referenciada com data de emissão inválida",;
						"318|Rejeição: Contranota de Produtor sem Nota Fiscal referenciada",;
						"319|Rejeição: Contranota de Produtor não pode referenciar somente Nota Fiscal de entrada",;
						"320|Rejeição: Contranota de Produtor referencia somente NF de outro emitente",;
						"321|Rejeição: NF-e de devolução de mercadoria não possui documento fiscal referenciado",;
						"322|Rejeição: NF de produtor referenciada com data de emissão inválida",;
						"323|Rejeição: CNPJ autorizado para download inválido",;
						"324|Rejeição: CNPJ do destinatário já autorizado para download",;
						"325|Rejeição: CPF autorizado para download inválido",;
						"326|Rejeição: CPF do destinatário já autorizado para download",;
						"327|Rejeição: CFOP inválido para Nota Fiscal com finalidade de devolução de mercadoria [nItem:nnn]",;
						"328|Rejeição: CFOP de devolução de mercadoria para NF-e que não tem finalidade de devolução de mercadoria",;
						"329|Rejeição: Número da DI /DSI inválido",;
						"330|Rejeição: Informar o Valor da AFRMM na importação por via marítima",;
						"331|Rejeição: Informar o CNPJ do adquirente ou do encomendante nesta forma de importação",;
						"332|Rejeição: CNPJ do adquirente ou do encomendante da importação inválido",;
						"333|Rejeição: Informar a UF do adquirente ou do encomendante nesta forma de importação",;
						"334|Rejeição: Número do processo de drawback não informado na importação",;
						"335|Rejeição: Número do processo de drawback na importação inválido",;
						"336|Rejeição: Informado o grupo de exportação no item para CFOP que não de exportação",;
						"337|Rejeição: NFC-e para emitente pessoa física",;
						"338|Rejeição: Número do processo de drawback não informado na exportação",;
						"339|Rejeição: Número do processo de drawback na exportação inválido",;
						"340|Rejeição: não informado o grupo de exportação indireta no item",;
						"341|Rejeição: Número do registro de exportação inválido",;
						"342|Rejeição: Chave de Acesso informada na Exportação Indireta com DV inválido",;
						"343|Rejeição: Modelo da NF-e informada na Exportação Indireta diferente de 55",;
						"344|Rejeição: Duplicidade de NF-e informada na Exportação Indireta (Chave de Acesso informada mais de uma vez)",;
						"345|Rejeição: Chave de Acesso informada na Exportação Indireta não consta como NF-e referenciada",;
						"346|Rejeição: somatório das quantidades informadas na Exportação Indireta não corresponde a quantidade total do item",;
						"347|Rejeição: Descrição do combustível diverge da descrição adotada pela ANP",;
						"348|Rejeição: NFC-e com grupo RECOPI",;
						"349|Rejeição: Número RECOPI não informado",;
						"350|Rejeição: Número RECOPI inválido",;
						"351|Rejeição: Valor do ICMS da Operação no CST=51 difere do produto BC e Alíquota",;
						"352|Rejeição: Valor do ICMS Diferido no CST=51 difere do produto Valor ICMS Operação e percentual diferimento",;
						"353|Rejeição: Valor do ICMS no CST=51 não corresponde a diferença do ICMS Operação e ICMS diferido",;
						"354|Rejeição: Informado grupo de devolução de tributos para NF-e que não tem finalidade de devolução de mercadoria",;
						"355|Rejeição: Informar o local de saída do Pais no caso da exportação",;
						"356|Rejeição: Informar o local de saída do Pais somente no caso da exportação",;
						"357|Rejeição: Chave de Acesso do grupo de Exportação Indireta inexistente [nRef: xxx]",;
						"358|Rejeição: Chave de Acesso do grupo de Exportação Indireta cancelada ou denegada [nRef: xxx]",;
						"359|Rejeição: NF-e de venda a Órgão Público sem informar a Nota de Empenho",;
						"360|Rejeição: NF-e com Nota de Empenho inválida para a UF.",;
						"361|Rejeição: NF-e com Nota de Empenho inexistente na UF.",;
						"362|Rejeição: Venda de combustível sem informação do Transportador",;
						"364|Rejeição: Total do valor da dedução do ISS difere do somatório dos itens",;
						"365|Rejeição: Total de outras retenções difere do somatório dos itens",;
						"366|Rejeição: Total do desconto incondicionado ISS difere do somatório dos itens",;
						"367|Rejeição: Total do desconto condicionado ISS difere do somatório dos itens",;
						"368|Rejeição: Total de ISS retido difere do somatório dos itens",;
						"369|Rejeição: não informado o grupo avulsa na emissão pelo Fisco",;
						"370|Rejeição: Nota Fiscal Avulsa com tipo de emissão inválido",;
						"372|Rejeição: destinatário com identificação de estrangeiro com caracteres inválidos",;
						"373|Rejeição: Descrição do primeiro item diferente de NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO / SEM VALOR FISCAL",;
						"374|Rejeição: CFOP incompatável com o grupo de tributação [nItem:nnn]",;
						"375|Rejeição: NF-e com CFOP 5929 (Lançamento relativo a Cupom Fiscal) referencia uma NFC-e [nItem:nnn]",;
						"376|Rejeição: Data do Desembaraço Aduaneiro inválida [nItem:nnn]",;
						"378|Rejeição: Grupo de Combustível sem a informação de Encerrante [nItem:nnn]",;
						"379|Rejeição: Grupo de Encerrante na NF-e (modelo 55) para CFOP diferente de venda de combustível para consumidor final [nItem:nnn]",;
						"380|Rejeição: Valor do Encerrante final não superior ao Encerrante inicial [nItem:nnn]",;
						"381|Rejeição: Grupo de tributação ICMS90, informando dados do ICMS-ST [nItem:nnn]",;
						"382|Rejeição: CFOP não permitido para o CST informado [nItem:nnn]",;
						"383|Rejeição: Item com CSOSN indevido [nItem:nnn]",;
						"384|Rejeição: CSOSN não permitido para a UF [nItem:nnn]",;
						"385|Rejeição: Grupo de tributação ICMS900, informando dados do ICMS-ST [nItem:nnn]",;
						"386|Rejeição: CFOP não permitido para o CSOSN informado [nItem:nnn]",;
						"387|Rejeição: Código de Enquadramento Legal do IPI inválido [nItem:nnn]",;
						"388|Rejeição: Código de Situação Tributária do IPI incompatível com o Código de Enquadramento Legal do IPI [nItem:nnn]",;
						"389|Rejeição: Código Município ISSQN inexistente [nItem:nnn]",;
						"390|Rejeição: Nota Fiscal com grupo de devolução de tributos [nItem:nnn]",;
						"391|Rejeição: não informados os dados do cartão de crédito / débito nas Formas de Pagamento da Nota Fiscal",;
						"392|Rejeição: não informados os dados da Operação de pagamento por cartão de crédito / débito",;
						"393|Rejeição: NF-e com o grupo de Informações Suplementares",;
						"394|Rejeição: Nota Fiscal sem a informação do QR-Code",;
						"395|Rejeição: Endereço do site da UF da Consulta via QRCode diverge do previsto",;
						"396|Rejeição: ParÃ¢metro do QR-Code inexistente (chAcesso)",;
						"397|Rejeição: ParÃ¢metro do QR-Code divergente da Nota Fiscal (chAcesso)",;
						"398|Rejeição: ParÃ¢metro nVersao do QR-Code difere do previsto",;
						"399|Rejeição: ParÃ¢metro de Identificação do destinatário no QR-Code para Nota Fiscal sem identificação do destinatário",;
						"400|Rejeição: ParÃ¢metro do QR-Code não estno formato hexadecimal (dhEmi)",;
						"401|Rejeição: CPF do emitente inválido",;
						"402|Rejeição: XML da área de dados com codificação diferente de UTF-8",;
						"403|Rejeição: O grupo de informações da NF-e avulsa de uso exclusivo do Fisco",;
						"404|Rejeição: Uso de prefixo de namespace não permitido",;
						"405|Rejeição: Código do país do emitente: dígito inválido",;
						"406|Rejeição: Código do país do destinatário: dígito inválido",;
						"407|Rejeição: O CPF só pode ser informado no campo emitente para a NF-e avulsa",;
						"408|Rejeição: Evento não disponível para Autor pessoa física",;
						"409|Rejeição: Campo cUF inexistente no elemento nfeCabecMsg do SOAP Header",;
						"410|Rejeição: UF informada no campo cUF não atendida pelo Web Service",;
						"411|Rejeição: Campo versaoDados inexistente no elemento nfeCabecMsg do SOAP Header",;
						"417|Rejeição: Total do ICMS superior ao valor limite estabelecido",;
						"418|Rejeição: Total do ICMS ST superior ao valor limite estabelecido",;
						"420|Rejeição: Cancelamento para NF-e já cancelada",;
						"450|Rejeição: Modelo da NF-e diferente de 55",;
						"451|Rejeição: Processo de emissão informado inválido",;
						"452|Rejeição: Tipo Autorizador do Recibo diverge do órgão Autorizador",;
						"453|Rejeição: Ano de inutilização não pode ser superior ao Ano atual",;
						"454|Rejeição: Ano de inutilização não pode ser inferior a 2006",;
						"455|Rejeição: Órgão Autor do evento diferente da UF da Chave de Acesso",;
						"461|Rejeição: Informado percentual de Gás Natural na mistura para produto diferente de GLP",;
						"462|Rejeição: Código Identificador do CSC no QR-Code não cadastrado na SEFAZ",;
						"463|Rejeição: Código Identificador do CSC no QR-Code foi revogado pela empresa",;
						"464|Rejeição: Código de Hash no QR-Code difere do calculado",;
						"465|Rejeição: Número de Controle da FCI inexistente",;
						"466|Rejeição: Evento com Tipo de Autor incompatável",;
						"467|Rejeição: Dados da NF-e divergentes do EPEC",;
						"468|Rejeição: NF-e com Tipo Emissão = 4, sem EPEC correspondente",;
						"471|Rejeição: Informado NCM=00 indevidamente",;
						"476|Rejeição: Código da UF diverge da UF da primeira NF-e do Lote",;
						"477|Rejeição: Código do órgão diverge do órgão do primeiro evento do Lote",;
						"478|Rejeição: Local da entrega não informado para faturamento direto de veículos novos",;
						"479|Rejeição: Data de Emissão anterior a data de credenciamento ou anterior a Data de Abertura do estabelecimento",;
						"480|Rejeição: Código Município do Emitente diverge do cadastrado na UF",;
						"481|Rejeição: Código Regime Tributário do emitente diverge do cadastro na SEFAZ",;
						"482|Rejeição: Código do Município do destinatário diverge do cadastrado na UF",;
						"483|Rejeição: Valor do desconto maior que valor do produto [nItem:nnn]",;
						"484|Rejeição: Chave de Acesso com tipo de emissão diferente de 4 (posição 35 da Chave de Acesso)",;
						"485|Rejeição: Duplicidade de numeração do EPEC (Modelo, CNPJ, Série e Número)",;
						"486|Rejeição: não informado o Grupo de Autorização para UF que exige a identificação",;
						"487|Rejeição: Escritório de Contabilidade não cadastrado na SEFAZ",;
						"488|Rejeição: Vendas do Emitente incompatíveis com o Porte da Empresa",;
						"489|Rejeição: CNPJ informado inválido (DV ou zeros)",;
						"490|Rejeição: CPF informado inválido (DV ou zeros)",;
						"491|Rejeição: O tpEvento informado inválido",;
						"492|Rejeição: O verEvento informado inválido",;
						"493|Rejeição: Evento não atende o Schema XML específico",;
						"494|Rejeição: Chave de Acesso inexistente",;
						"496|Rejeição: não informado o tipo de integração no pagamento com cartão de crédito / débito",;
						"501|Rejeição: Pedido de Cancelamento intempestivo (NF-e autorizada a mais de 7 dias)",;
						"502|Rejeição: Erro na Chave de Acesso / Campo Id não corresponde  concatenação dos campos correspondentes",;
						"503|Rejeição: Série utilizada fora da faixa permitida no SCAN (900-999)",;
						"504|Rejeição: Data de Entrada/Saída posterior ao permitido",;
						"505|Rejeição: Data de Entrada/Saída anterior ao permitido",;
						"506|Rejeição: Data de Saída menor que a Data de Emissão",;
						"507|Rejeição: O CNPJ do destinatário/remetente não deve ser informado em Operação com o exterior",;
						"508|Rejeição: CST incompatível na Operação com não Contribuinte [nItem:999]",;
						"509|Rejeição: Informado código de município diferente de 9999999 para Operação com o exterior",;
						"510|Rejeição: Operação com Exterior e Código País destinatário 1058 (Brasil) ou não informado",;
						"511|Rejeição: não de Operação com Exterior e Código País destinatário difere de 1058 (Brasil)",;
						"512|Rejeição: CNPJ do Local de Retirada inválido",;
						"513|Rejeição: Código Município do Local de Retirada deve ser 9999999 para UF retirada = EX",;
						"514|Rejeição: CNPJ do Local de Entrega inválido",;
						"515|Rejeição: Código Município do Local de Entrega deve ser 9999999 para UF entrega = EX",;
						"516|Rejeição: Falha no schema XML / inexiste a tag raiz esperada para a mensagem",;
						"517|Rejeição: Falha no schema XML / inexiste atributo versao na tag raiz da mensagem",;
						"518|Rejeição: CFOP de entrada para NF-e de saída",;
						"519|Rejeição: CFOP de saída para NF-e de entrada",;
						"520|Rejeição: CFOP de Operação com Exterior e UF destinatário difere de EX",;
						"521|Rejeição: CFOP de Operação Estadual e UF do emitente difere da UF do destinatário para destinatário contribuinte do ICMS.",;
						"522|Rejeição: CFOP de Operação Estadual e UF emitente difere da UF remetente para remetente contribuinte do ICMS.",;
						"523|Rejeição: CFOP não de Operação Estadual e UF emitente igual a UF destinatário.",;
						"524|Rejeição: CFOP de Operação com Exterior e não informado NCM",;
						"525|Rejeição: CFOP de Importação e não informado dados da DI",;
						"526|Rejeição: Consulta a uma Chave de Acesso muito antiga",;
						"527|Rejeição: Operação de Exportação com informação de ICMS incompatível",;
						"528|Rejeição: Valor do ICMS difere do produto BC e Alíquota",;
						"529|Rejeição: CST incompatível na Operação com Contribuinte Isento de Inscrição Estadual [nItem:999]",;
						"530|Rejeição: Operação com tributação de ISSQN sem informar a Inscrição Municipal",;
						"531|Rejeição: Total da BC ICMS difere do somatório dos itens",;
						"532|Rejeição: Total do ICMS difere do somatório dos itens",;
						"533|Rejeição: Total da BC ICMS-ST difere do somatório dos itens",;
						"534|Rejeição: Total do ICMS-ST difere do somatório dos itens",;
						"535|Rejeição: Total do Frete difere do somatório dos itens",;
						"536|Rejeição: Total do Seguro difere do somatório dos itens",;
						"537|Rejeição: Total do Desconto difere do somatório dos itens",;
						"538|Rejeição: Total do IPI difere do somatório dos itens",;
						"539|Duplicidade de NF-e com diferença na Chave de Acesso [chNFe: 99999999999999999999999999999999999999999999][nRec:999999999999999]",;
						"540|Rejeição: CPF do Local de Retirada inválido",;
						"541|Rejeição: CPF do Local de Entrega inválido",;
						"542|Rejeição: CNPJ do Transportador inválido",;
						"543|Rejeição: CPF do Transportador inválido",;
						"544|Rejeição: IE do Transportador inválida",;
						"545|Rejeição: Falha no schema XML / versão informada na versaoDados do SOAPHeader diverge da versão da mensagem",;
						"546|Rejeição: Erro na Chave de Acesso / Campo Id / falta a literal NFe",;
						"547|Rejeição: Dígito Verificador da Chave de Acesso da NF-e Referenciada inválido",;
						"548|Rejeição: CNPJ da NF referenciada inválido.",;
						"549|Rejeição: CNPJ da NF referenciada de produtor inválido.",;
						"550|Rejeição: CPF da NF referenciada de produtor inválido.",;
						"551|Rejeição: IE da NF referenciada de produtor inválido.",;
						"552|Rejeição: Dígito Verificador da Chave de Acesso do CT-e Referenciado inválido",;
						"553|Rejeição: Tipo autorizador do recibo diverge do órgão Autorizador.",;
						"554|Rejeição: Série difere da faixa 0-899",;
						"555|Rejeição: Tipo autorizador do protocolo diverge do órgão Autorizador.",;
						"556|Rejeição: Justificativa de entrada em contingência não deve ser informada para tipo de emissão normal.",;
						"557|Rejeição: A Justificativa de entrada em contingência deve ser informada.",;
						"558|Rejeição: Data de entrada em contingência posterior a data de recebimento.",;
						"559|Rejeição: UF do Transportador não informada",;
						"560|Rejeição: CNPJ base do emitente difere do CNPJ base da primeira NF-e do lote recebido",;
						"561|Rejeição: Mês de Emissão informado na Chave de Acesso difere do Mês de Emissão da NF-e",;
						"562|Rejeição: Código Numérico informado na Chave de Acesso difere do Código Numérico da NF-e [chNFe:99999999999999999999999999999999999999999999]",;
						"563|Rejeição: Já existe pedido de Inutilização com a mesma faixa de inutilização",;
						"564|Rejeição: Total do Produto / Serviço difere do somatório dos itens",;
						"565|Rejeição: Falha no schema XML / inexiste a tag raiz esperada para o lote de NF-e",;
						"567|Rejeição: Falha no schema XML / versão informada na versaoDados do SOAPHeader diverge da versão do lote de NF-e",;
						"568|Rejeição: Falha no schema XML / inexiste atributo versao na tag raiz do lote de NF-e",;
						"569|Rejeição: Data de entrada em contingência muito atrasada",;
						"570|Rejeição: Tipo de Emissão 3, 6 ou 7 só válido nas contingências SCAN/SVC",;
						"571|Rejeição: O tpEmis informado diferente de 3 para contingência SCAN",;
						"572|Rejeição: Erro Atributo ID do evento não corresponde a concatenação dos campos (ID + tpEvento + chNFe + nSeqEvento)",;
						"573|Rejeição: Duplicidade de Evento",;
						"574|Rejeição: O autor do evento diverge do emissor da NF-e",;
						"575|Rejeição: O autor do evento diverge do destinatário da NF-e",;
						"576|Rejeição: O autor do evento não um órgão autorizado a gerar o evento",;
						"577|Rejeição: A data do evento não pode ser menor que a data de emissão da NF-e",;
						"578|Rejeição: A data do evento não pode ser maior que a data do processamento",;
						"579|Rejeição: A data do evento não pode ser menor que a data de autorização para NF-e não emitida em contingência",;
						"580|Rejeição: O evento exige uma NF-e autorizada",;
						"587|Rejeição: Usar somente o namespace padrão da NF-e",;
						"588|Rejeição: não permitida a presença de caracteres de edição no início/fim da mensagem ou entre as tags da mensagem",;
						"589|Rejeição: Número do NSU informado superior ao maior NSU da base de dados da SEFAZ",;
						"590|Rejeição: Informado CST para emissor do Simples Nacional (CRT=1)",;
						"591|Rejeição: Informado CSOSN para emissor que não do Simples Nacional (CRT diferente de 1)",;
						"592|Rejeição: A NF-e deve ter pelo menos um item de produto sujeito ao ICMS",;
						"593|Rejeição: CNPJ-Base consultado difere do CNPJ-Base do Certificado Digital",;
						"594|Rejeição: O número de sequencia do evento informado maior que o permitido",;
						"595|Rejeição: Obrigatória a informação da justificativa do evento.",;
						"596|Rejeição: Evento apresentado fora do prazo: [prazo vigente]",;
						"597|Rejeição: CFOP de Importação e não informado dados de IPI",;
						"598|Rejeição: NF-e emitida em ambiente de homologação com Razão Social do destinatário diferente de NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO / SEM VALOR FISCAL",;
						"599|Rejeição: CFOP de Importação e não informado dados de II",;
						"600|Rejeição: CSOSN incompatível na Operação com não Contribuinte [nItem:999]",;
						"601|Rejeição: Total do II difere do somatório dos itens",;
						"602|Rejeição: Total do PIS difere do somatório dos itens sujeitos ao ICMS",;
						"603|Rejeição: Total do COFINS difere do somatório dos itens sujeitos ao ICMS",;
						"604|Rejeição: Total do vOutro difere do somatório dos itens",;
						"605|Rejeição: Total do vISS difere do somatório do vProd dos itens sujeitos ao ISSQN",;
						"606|Rejeição: Total do vBC do ISS difere do somatório dos itens",;
						"607|Rejeição: Total do ISS difere do somatório dos itens",;
						"608|Rejeição: Total do PIS difere do somatório dos itens sujeitos ao ISSQN",;
						"609|Rejeição: Total do COFINS difere do somatório dos itens sujeitos ao ISSQN",;
						"610|Rejeição: Total da NF difere do somatório dos Valores compõe o valor Total da NF.",;
						"611|Rejeição: cEAN inválido",;
						"612|Rejeição: cEANTrib inválido",;
						"613|Rejeição: Chave de Acesso difere da existente em BD",;
						"614|Rejeição: Chave de Acesso inválida (Código UF inválido)",;
						"615|Rejeição: Chave de Acesso inválida (Ano menor que 06 ou Ano maior que Ano corrente)",;
						"616|Rejeição: Chave de Acesso inválida (Mês menor que 1 ou Mês maior que 12)",;
						"617|Rejeição: Chave de Acesso inválida (CNPJ zerado ou dígito inválido)",;
						"618|Rejeição: Chave de Acesso inválida (modelo diferente de 55 e 65)",;
						"619|Rejeição: Chave de Acesso inválida (número NF = 0)",;
						"620|Rejeição: Chave de Acesso difere da existente em BD",;
						"621|Rejeição: CPF Emitente não cadastrado",;
						"622|Rejeição: IE emitente não vinculada ao CPF",;
						"623|Rejeição: CPF destinatário não cadastrado",;
						"624|Rejeição: IE destinatário não vinculada ao CPF",;
						"625|Rejeição: Inscrição SUFRAMA deve ser informada na venda com isenção para ZFM",;
						"626|Rejeição: CFOP de Operação isenta para ZFM diferente do previsto",;
						"627|Rejeição: O valor do ICMS desonerado deve ser informado",;
						"628|Rejeição: Total da NF superior ao valor limite estabelecido pela SEFAZ [Limite]",;
						"629|Rejeição: Valor do Produto difere do produto Valor Unitário de Comercialização e Quantidade Comercial",;
						"630|Rejeição: Valor do Produto difere do produto Valor Unitário de Tributação e Quantidade Tributável",;
						"631|Rejeição: CNPJ-Base do destinatário difere do CNPJ-Base do Certificado Digital",;
						"632|Rejeição: Solicitação fora de prazo, a NF-e não está mais disponível para download",;
						"633|Rejeição: NF-e indisponível para download devido a ausência de Manifestação do destinatário",;
						"634|Rejeição: destinatário da NF-e não tem o mesmo CNPJ raiz do solicitante do download",;
						"635|Rejeição: NF-e com mesmo número e série já transmitida e aguardando processamento",;
						"650|Rejeição: Evento de Ciência da Emissção para NF-e Cancelada ou Denegada",;
						"651|Rejeição: Evento de Desconhecimento da Operação para NF-e Cancelada ou Denegada",;
						"653|Rejeição: NF-e Cancelada, arquivo indisponível para download",;
						"654|Rejeição: NF-e Denegada, arquivo indisponível para download",;
						"655|Rejeição: Evento de Ciência da Emissão informado após a manifestação final do destinatário",;
						"656|Rejeição: Consumo Indevido",;
						"657|Rejeição: Código do órgão diverge do órgão autorizador",;
						"658|Rejeição: UF do destinatário da Chave de Acesso diverge da UF autorizadora",;
						"660|Rejeição: CFOP de Combustível e não informado grupo de combustível [nItem:nnn]",;
						"661|Rejeição: NF-e já existente para o número do EPEC informado",;
						"662|Rejeição: Numeração do EPEC está inutilizada na Base de Dados da SEFAZ",;
						"663|Rejeição: Alíquota do ICMS com valor superior a 4 por cento na Operação de saída interestadual com produtos importados [nItem:999]",;
						"678|Rejeição: NF referenciada com UF diferente da NF-e complementar",;
						"679|Rejeição: Modelo de DF-e referenciado inválido",;
						"680|Rejeição: Duplicidade de NF-e referenciada (Chave de Acesso referenciada mais de uma vez)",;
						"681|Rejeição: Duplicidade de NF Modelo 1 referenciada (CNPJ, Modelo, Série e Número)",;
						"682|Rejeição: Duplicidade de NF de Produtor referenciada (IE, Modelo, Série e Número)",;
						"683|Rejeição: Modelo do CT-e referenciado diferente de 57",;
						"684|Rejeição: Duplicidade de Cupom Fiscal referenciado (Modelo, Número de Ordem e COO)",;
						"685|Rejeição: Total do Valor Aproximado dos Tributos difere do somatário dos itens",;
						"686|Rejeição: NF Complementar referencia uma NF-e cancelada",;
						"687|Rejeição: NF Complementar referencia uma NF-e denegada",;
						"688|Rejeição: NF referenciada de Produtor com IE inexistente [nRef: xxx]",;
						"689|Rejeição: NF referenciada de Produtor com IE não vinculada ao CNPJ/CPF informado [nRef: xxx]",;
						"690|Rejeição: Pedido de Cancelamento para NF-e com CT-e",;
						"691|Rejeição: Chave de Acesso da NF-e diverge da Chave de Acesso do EPEC",;
						"693|Rejeição: Alíquota de ICMS superior a definida para a Operação interestadual [nItem:999]",;
						"694|Rejeição: não informado o grupo de ICMS para a UF de destino [nItem:999]",;
						"695|Rejeição: Informado indevidamente o grupo de ICMS para a UF de destino [nItem:999]",;
						"697|Rejeição: Alíquota interestadual do ICMS com origem diferente do previsto [nItem:999]",;
						"698|Rejeição: Alíquota interestadual do ICMS incompatível com as UF envolvidas na Operação [nItem:999]",;
						"699|Rejeição: Percentual do ICMS Interestadual para a UF de destino difere do previsto para o ano da Data de Emissão [nItem:999]",;
						"700|Rejeição: Mensagem de Lote versão 3.xx. Enviar para o Web Service nfeAutorizacao",;
						"701|Rejeição: não informado Nota Fiscal referenciada (CFOP de Exportação Indireta)",;
						"702|Rejeição: NFC-e não aceita pela UF do Emitente",;
						"703|Rejeição: Data-Hora de Emissão posterior ao horário de recebimento",;
						"704|Rejeição: NFC-e com Data-Hora de emissão atrasada",;
						"705|Rejeição: NFC-e com data de entrada/saída",;
						"706|Rejeição: NFC-e para Operação de entrada",;
						"707|Rejeição: NFC-e para Operação interestadual ou com o exterior",;
						"708|Rejeição: NFC-e não pode referenciar documento fiscal",;
						"709|Rejeição: NFC-e com formato de DANFE inválido",;
						"710|Rejeição: NF-e com formato de DANFE inválido",;
						"711|Rejeição: NF-e com contingência off-line",;
						"712|Rejeição: NFC-e com contingência off-line para a UF",;
						"713|Rejeição: Tipo de Emissão diferente de 6 ou 7 para contingência da SVC acessada",;
						"714|Rejeição: NFC-e com opção de contingência inválida (tpEmis=2, 4 (a critério da UF) ou 5)",;
						"715|Rejeição: NFC-e com finalidade inválida",;
						"716|Rejeição: NFC-e em Operação não destinada a consumidor final",;
						"717|Rejeição: NFC-e em Operação não presencial",;
						"718|Rejeição: NFC-e não deve informar IE de Substituto Tributário",;
						"719|Rejeição: NF-e sem a identificação do destinatário",;
						"720|Rejeição: Na Operação com Exterior deve ser informada tag idEstrangeiro",;
						"721|Rejeição: Operação interestadual deve informar CNPJ ou CPF",;
						"723|Rejeição: Operação interna com idEstrangeiro informado deve ser para consumidor final",;
						"724|Rejeição: NF-e sem o nome do destinatário",;
						"725|Rejeição: NFC-e com CFOP inválido [nItem:nnn]",;
						"726|Rejeição: NF-e sem a informação de endereço do destinatário",;
						"727|Rejeição: Operação com Exterior e UF diferente de EX",;
						"728|Rejeição: NF-e sem informação da IE do destinatário",;
						"729|Rejeição: NFC-e com informação da IE do destinatário",;
						"730|Rejeição: NFC-e com Inscrição Suframa",;
						"731|Rejeição: CFOP de Operação com Exterior e idDest <> 3",;
						"732|Rejeição: CFOP de Operação interestadual e idDest <> 2",;
						"733|Rejeição: CFOP de Operação interna e idDest <> 1",;
						"734|Rejeição: NFC-e com Unidade de Comercialização inválida",;
						"735|Rejeição: NFC-e com Unidade de Tributação inválida",;
						"736|Rejeição: NFC-e com grupo de Veículos novos",;
						"737|Rejeição: NFC-e com grupo de Medicamentos",;
						"738|Rejeição: NFC-e com grupo de Armamentos",;
						"740|Rejeição: Item com Repasse de ICMS retido por Substituto Tributário [nItem:nnn]",;
						"741|Rejeição: NFC-e com Partilha de ICMS entre UF",;
						"742|Rejeição: NFC-e com grupo do IPI",;
						"743|Rejeição: NFC-e com grupo do II",;
						"745|Rejeição: NF-e sem grupo do PIS",;
						"746|Rejeição: NFC-e com grupo do PIS-ST",;
						"748|Rejeição: NF-e sem grupo da COFINS",;
						"749|Rejeição: NFC-e com grupo da COFINS-ST",;
						"750|Rejeição: NFC-e com valor total superior ao permitido para destinatário não identificado (Código) [Limite]",;
						"751|Rejeição: NFC-e com valor total superior ao permitido para destinatário não identificado (Nome) [Limite]",;
						"752|Rejeição: NFC-e com valor total superior ao permitido para destinatário não identificado (Endereço) [Limite]",;
						"753|Rejeição: NFC-e com Frete",;
						"754|Rejeição: NFC-e com dados do Transportador",;
						"755|Rejeição: NFC-e com dados de Retenção do ICMS no Transporte",;
						"756|Rejeição: NFC-e com dados do veículo de Transporte",;
						"757|Rejeição: NFC-e com dados de Reboque do veículo de Transporte",;
						"758|Rejeição: NFC-e com dados do Vagão de Transporte",;
						"759|Rejeição: NFC-e com dados da Balsa de Transporte",;
						"760|Rejeição: NFC-e com dados de cobrança (Fatura, Duplicata)",;
						"761|Rejeição: Código de Produtos ANP inexistente",;
						"762|Rejeição: NFC-e com dados de compras (Empenho, Pedido, Contrato)",;
						"763|Rejeição: NFC-e com dados de aquisição de Cana",;
						"764|Rejeição: Solicitada resposta síncrona para Lote com mais de uma NF-e (indSinc=1)",;
						"765|Rejeição: Lote só poderá conter NF-e ou NFC-e",;
						"766|Rejeição: Item com CST indevido [nItem:nnn]",;
						"767|Rejeição: NFC-e com somatório dos pagamentos diferente do total da Nota Fiscal",;
						"768|Rejeição: NF-e não deve possuir o grupo de Formas de Pagamento",;
						"769|Rejeição: A critério da UF NFC-e deve possuir o grupo de Formas de Pagamento",;
						"770|Rejeição: NFC-e autorizada há mais de 24 horas.",;
						"771|Rejeição: Operação Interestadual e UF de destino com EX",;
						"772|Rejeição: Operação Interestadual e UF de destino igual  UF do emitente",;
						"773|Rejeição: Operação Interna e UF de destino difere da UF do emitente",;
						"774|Rejeição: NFC-e com indicador de item não participante do total",;
						"775|Rejeição: Modelo da NFC-e diferente de 65",;
						"776|Rejeição: Solicitada resposta síncrona para UF que não disponibiliza este atendimento (indSinc=1)",;
						"777|Rejeição: Obrigatória a informação do NCM completo",;
						"778|Rejeição: Informado NCM inexistente [nItem:nnn]",;
						"779|Rejeição: NFC-e com NCM incompatível",;
						"780|Rejeição: Total da NFC-e superior ao valor limite estabelecido pela SEFAZ [Limite]",;
						"781|Rejeição: Emissor não habilitado para emissão da NFC-e",;
						"782|Rejeição: NFC-e não autorizada pelo SCAN",;
						"783|Rejeição: NFC-e não autorizada pela SVC",;
						"784|Rejeição: NFC-e não permite o evento de Carta de Correção",;
						"785|Rejeição: NFC-e com entrega a domicílio não permitida pela UF",;
						"786|Rejeição: NFC-e de entrega a domicílio sem dados do Transportador",;
						"787|Rejeição: NFC-e de entrega a domicílio sem a identificação do destinatário",;
						"788|Rejeição: NFC-e de entrega a domicílio sem o endereço do destinatário",;
						"789|Rejeição: NFC-e para destinatário contribuinte de ICMS",;
						"790|Rejeição: Operação com Exterior para destinatário Contribuinte de ICMS",;
						"791|Rejeição: NF-e com indicação de destinatário isento de IE, com a informação da IE do destinatário",;
						"792|Rejeição: Informada a IE do destinatário para Operação com destinatário no Exterior",;
						"793|Rejeição: Valor do ICMS relativo ao Fundo de Combate  Pobreza na UF de destino difere do calculado [nItem:999]",;
						"794|Rejeição: NF-e com indicativo de NFC-e com entrega a domicílio",;
						"795|Rejeição: Total do ICMS desonerado difere do somatório dos itens",;
						"796|Rejeição: Empresa sem Chave de Segurança para o QR-Code",;
						"798|Rejeição: Valor total do ICMS relativo Fundo de Combate  Pobreza (FCP) da UF de destino difere do somatório do valor dos itens",;
						"799|Rejeição: Valor total do ICMS Interestadual da UF de destino difere do somatório dos itens",;
						"800|Rejeição: Valor total do ICMS Interestadual da UF do remetente difere do somatório dos itens",;
						"805|Rejeição: A SEFAZ do destinatário não permite Contribuinte Isento de Inscrição Estadual",;
						"806|Rejeição: Operação com ICMS-ST sem informação do CEST",;
						"807|Rejeição: NFC-e com grupo de ICMS para a UF do destinatário",;
						"865|Rejeição: Total dos pagamentos menor que o total da nota",;
						"869|Rejeição: Valor do troco incorreto",;
						"999|Rejeição: Erro não catalogado (informar a mensagem de erro capturado no tratamento da exceção)"}

Default cMsg := ""

//-- Acrescimo dos novos codigo denegadas
aDenegadas := LjCodDeneg(2)
aEval(aDenegadas, {|x| aadd(aCRRejNFE,aClone(x))})

//-- Se vazio retorna como em processamento 
if Empty(cStatus)
	Return "P"
endif

//-- Eh uma Rejeitadas
nX := aScan(aCRRejNFE,cStatus+"|")
if nX > 0 .or. "REJEIÇÃO" $ Upper(cMsg) .or. "REJEICAO" $ Upper(cMsg)
	sRet := "R"
endif

//-- Eh uma Autorização
nX := aScan(aCRAutNFE,cStatus+"|")
if nX > 0
	sRet := "A"
endif

//-- Eh um Manifesto 
nX := aScan(aCRManNFE,cStatus+"|")
if nX > 0
	sRet := "M"
endif

//-- Eh um Consulta 
nX := aScan(aCRConNFE,cStatus+"|")
if nX > 0
	sRet := "C"
endif

//-- Eh um Status 
nX := aScan(aCRStaNFE,cStatus+"|")
if nX > 0
	sRet := "S"
endif

//-- Eh um Processamento
nX := aScan(aCRProNFE,cStatus+"|")
if nX > 0
	sRet := "P"
endif

//-- Se vazio retorna como em processamento 
if Empty(sRet)
	sRet := "P"
endif
Return sRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cPrefixo
Função analisa o prefixo do codigo do GTIN

@param   cPrefixo Codigo Gtin para analise
@author  Anderson Machado
@since   20/12/2017
@version P11
@return  Logico, retorno logico, caso encontrado .T. senao .F.
/*/
Function LjGtinPref(cPrefixo)
Local lRet := .F.

Static aGS1 := {}

If Len(aGS1) == 0
	aadd(aGS1,{"000","019","0","GS1 US"})
	aadd(aGS1,{"020","029","1","Números de circulação restrita dentro da região"})
	aadd(aGS1,{"030","039","0","GS1 US"})
	aadd(aGS1,{"040","049","1","GS1 Números de circulação restrita dentro da empresa"})
	aadd(aGS1,{"050","059","1","GS1 US reserved for future use"})
	aadd(aGS1,{"060","139","0","GS1 US"})
	aadd(aGS1,{"200","299","1","GS1 Números de circulação restrita dentro da região"})
	aadd(aGS1,{"300","379","0","GS1 France"})
	aadd(aGS1,{"380","380","0","GS1 Bulgaria"})
	aadd(aGS1,{"383","383","0","GS1 Slovenija"})
	aadd(aGS1,{"385","385","0","GS1 Croatia"})
	aadd(aGS1,{"387","387","0","GS1 BIH (Bosnia-Herzegovina)"})
	aadd(aGS1,{"389","389","0","GS1 Montenegro"})
	aadd(aGS1,{"400","440","0","GS1 Germany"})
	aadd(aGS1,{"450","459","0","GS1 Japan"})
	aadd(aGS1,{"490","499","0","GS1 Japan"})
	aadd(aGS1,{"460","469","0","GS1 Russia"})
	aadd(aGS1,{"470","470","0","GS1 Kyrgyzstan"})
	aadd(aGS1,{"471","471","0","GS1 Taiwan"})
	aadd(aGS1,{"474","474","0","GS1 Estonia"})
	aadd(aGS1,{"475","475","0","GS1 Latvia"})
	aadd(aGS1,{"476","476","0","GS1 Azerbaijan"})
	aadd(aGS1,{"477","477","0","GS1 Lithuania"})
	aadd(aGS1,{"478","478","0","GS1 Uzbekistan"})
	aadd(aGS1,{"479","479","0","GS1 Sri Lanka"})
	aadd(aGS1,{"480","480","0","GS1 Philippines"})
	aadd(aGS1,{"481","481","0","GS1 Belarus"})
	aadd(aGS1,{"482","482","0","GS1 Ukraine"})
	aadd(aGS1,{"483","483","0","GS1 Turkmenistan"})
	aadd(aGS1,{"484","484","0","GS1 Moldova"})
	aadd(aGS1,{"485","485","0","GS1 Armenia"})
	aadd(aGS1,{"486","486","0","GS1 Georgia"})
	aadd(aGS1,{"487","487","0","GS1 Kazakstan"})
	aadd(aGS1,{"488","488","0","GS1 Tajikistan"})
	aadd(aGS1,{"489","489","0","GS1 Hong Kong"})
	aadd(aGS1,{"500","509","0","GS1 UK"})
	aadd(aGS1,{"520","521","0","GS1 Association Greece"})
	aadd(aGS1,{"528","528","0","GS1 Lebanon"})
	aadd(aGS1,{"529","529","0","GS1 Cyprus"})
	aadd(aGS1,{"530","530","0","GS1 Albania"})
	aadd(aGS1,{"531","531","0","GS1 Macedonia"})
	aadd(aGS1,{"535","535","0","GS1 Malta"})
	aadd(aGS1,{"539","539","0","GS1 Ireland"})
	aadd(aGS1,{"540","549","0","GS1 Belgium & Luxembourg"})
	aadd(aGS1,{"560","560","0","GS1 Portugal"})
	aadd(aGS1,{"569","569","0","GS1 Iceland"})
	aadd(aGS1,{"570","579","0","GS1 Denmark"})
	aadd(aGS1,{"590","590","0","GS1 Poland"})
	aadd(aGS1,{"594","594","0","GS1 Romania"})
	aadd(aGS1,{"599","599","0","GS1 Hungary"})
	aadd(aGS1,{"600","601","0","GS1 South Africa"})
	aadd(aGS1,{"603","603","0","GS1 Ghana"})
	aadd(aGS1,{"604","604","0","GS1 Senegal"})
	aadd(aGS1,{"608","608","0","GS1 Bahrain"})
	aadd(aGS1,{"609","609","0","GS1 Mauritius"})
	aadd(aGS1,{"611","611","0","GS1 Morocco"})
	aadd(aGS1,{"613","613","0","GS1 Algeria"})
	aadd(aGS1,{"615","615","0","GS1 Nigeria"})
	aadd(aGS1,{"616","616","0","GS1 Kenya"})
	aadd(aGS1,{"618","618","0","GS1 Ivory Coast"})
	aadd(aGS1,{"619","619","0","GS1 Tunisia"})
	aadd(aGS1,{"620","620","0","GS1 Tanzania"})
	aadd(aGS1,{"621","621","0","GS1 Syria"})
	aadd(aGS1,{"622","622","0","GS1 Egypt"})
	aadd(aGS1,{"623","623","0","GS1 Brunei"})
	aadd(aGS1,{"624","624","0","GS1 Libya"})
	aadd(aGS1,{"625","625","0","GS1 Jordan"})
	aadd(aGS1,{"626","626","0","GS1 Iran"})
	aadd(aGS1,{"627","627","0","GS1 Kuwait"})
	aadd(aGS1,{"628","628","0","GS1 Saudi Arabia"})
	aadd(aGS1,{"629","629","0","GS1 Emirates"})
	aadd(aGS1,{"640","649","0","GS1 Finland"})
	aadd(aGS1,{"690","699","0","GS1 China"})
	aadd(aGS1,{"700","709","0","GS1 Norway"})
	aadd(aGS1,{"729","729","0","GS1 Israel"})
	aadd(aGS1,{"730","739","0","GS1 Sweden"})
	aadd(aGS1,{"740","740","0","GS1 Guatemala"})
	aadd(aGS1,{"741","741","0","GS1 El Salvador"})
	aadd(aGS1,{"742","742","0","GS1 Honduras"})
	aadd(aGS1,{"743","743","0","GS1 Nicaragua"})
	aadd(aGS1,{"744","744","0","GS1 Costa Rica"})
	aadd(aGS1,{"745","745","0","GS1 Panama"})
	aadd(aGS1,{"746","746","0","GS1 Republica Dominicana"})
	aadd(aGS1,{"750","750","0","GS1 Mexico"})
	aadd(aGS1,{"754","755","0","GS1 Canada"})
	aadd(aGS1,{"759","759","0","GS1 Venezuela"})
	aadd(aGS1,{"760","769","0","GS1 Schweiz, Suisse, Svizzera"})
	aadd(aGS1,{"770","771","0","GS1 Colombia"})
	aadd(aGS1,{"773","773","0","GS1 Uruguay"})
	aadd(aGS1,{"775","775","0","GS1 Peru"})
	aadd(aGS1,{"777","777","0","GS1 Bolivia"})
	aadd(aGS1,{"778","779","0","GS1 Argentina"})
	aadd(aGS1,{"780","780","0","GS1 Chile"})
	aadd(aGS1,{"784","784","0","GS1 Paraguay"})
	aadd(aGS1,{"786","786","0","GS1 Ecuador"})
	aadd(aGS1,{"789","790","0","GS1 Brasil"})
	aadd(aGS1,{"800","839","0","GS1 Italy"})
	aadd(aGS1,{"840","849","0","GS1 Spain"})
	aadd(aGS1,{"850","850","0","GS1 Cuba"})
	aadd(aGS1,{"858","858","0","GS1 Slovakia"})
	aadd(aGS1,{"859","859","0","GS1 Czech"})
	aadd(aGS1,{"860","860","0"," GS1 Serbia"})
	aadd(aGS1,{"865","865","0","GS1 Mongolia"})
	aadd(aGS1,{"867","867","0","GS1 North Korea"})
	aadd(aGS1,{"868","869","0","GS1 Turkey"})
	aadd(aGS1,{"870","879","0","GS1 Netherlands"})
	aadd(aGS1,{"880","880","0","GS1 South Korea"})
	aadd(aGS1,{"884","884","0","GS1 Cambodia"})
	aadd(aGS1,{"885","885","0","GS1 Thailand"})
	aadd(aGS1,{"888","888","0","GS1 Singapore"})
	aadd(aGS1,{"890","890","0","GS1 India"})
	aadd(aGS1,{"893","893","0","GS1 Vietnam"})
	aadd(aGS1,{"896","896","0","GS1 Pakistan"})
	aadd(aGS1,{"899","899","0","GS1 Indonesia"})
	aadd(aGS1,{"900","919","0","GS1 Austria"})
	aadd(aGS1,{"930","939","0","GS1 Australia"})
	aadd(aGS1,{"940","949","0","GS1 New Zealand"})
	aadd(aGS1,{"950","950","1","GS1 Global Office"})
	aadd(aGS1,{"951","951","1","Numeração para EPC Tag Data Standard"})
	aadd(aGS1,{"955","955","0","GS1 Malaysia"})
	aadd(aGS1,{"958","958","0","GS1 Macau"})
	aadd(aGS1,{"960","969","1","Global Office (GTIN-8s)"})
	aadd(aGS1,{"977","977","1","Serial publications (ISSN)"})
	aadd(aGS1,{"978","979","1","Bookland (ISBN)"})
	aadd(aGS1,{"980","980","1","Refund receipts"})
	aadd(aGS1,{"981","984","1","GS1 Coupon identification for common currency areas"})
	aadd(aGS1,{"990","999","1","GS1 Coupon identification"})
EndIf

//-- Vamos verificar se o prefixo existe dentro os classificado
nPos := aScan(aGS1,{|x| x[01] <= cPrefixo .and. x[02] >= cPrefixo })  
lRet := (nPos > 0)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjCodDeneg
Função retorna codigo de notas denegadas   

@param   nOp Opcao 1-Retorna um array com os codigo denegadas e 
			       2-Retorna string com os codigo denegados
@author  Anderson Machado
@since   20/12/2017
@version P11
@return  Array, retorno logico, caso encontrado .T. senao .F.
/*/
//-------------------------------------------------------------------
Function LjCodDeneg(nOp)
Local aDenegadas := {}
Local cTexto := "" 
Local ix := 0

Default nOp := 1

aadd(aDenegadas,{"110","Uso Denegado"})
aadd(aDenegadas,{"205","Rejeicao: NF-e esta denegada na base de dados da SEFAZ"})
aadd(aDenegadas,{"234","Rejeicao: IE do destinatario nao vinculada ao CNPJ"})
aadd(aDenegadas,{"301","Uso Denegado: Irregularidade fiscal do emitente"})
aadd(aDenegadas,{"302","Uso Denegado: Irregularidade fiscal do destinatário"})
aadd(aDenegadas,{"303","Uso Denegado: destinatário não habilitado a operar na UF"})

//Esses status são considerado como validações e nao denegados
//-- aadd(aDenegadas,{"305","Rejeição: Destinatário bloqueado na UF"})
//-- aadd(aDenegadas,{"306","IE do destinatário não está ativa na UF"})
//-- aadd(aDenegadas,{"233","Rejeicao: IE do destinatario nao cadastrada"})

if nOp == 1

	for ix:=1 to len(aDenegadas)
		cTexto += aDenegadas[ix][01] + "/"
	next ix
	aDenegadas := {cTexto}

endif
Return aDenegadas


//-------------------------------------------------------------------
/*/{Protheus.doc} LjTipoPAF
Função para retornar o tipo de Regime do PAF que a  estação está parametrizada 
0 ou nulo ou vazio-	PAF-ECF
1 					PAF com NFC-e 
2 					PAF com DAF
@author  	caio okamoto
@since   	15/07/2022
@version 	P12
@param 		cCodigo - caractere - código do PDV
@return  	cRet 	- caractere - retorna o tipo de PAF
/*/
//-------------------------------------------------------------------
function LjTipoPAF(cCodigo)
Local aArea := GetArea()
Local cRet := ""
Default  cCodigo := STFGetStation("CODIGO")	

//atenção, parametro MV_PAFNFCE utilizado somente internamente para poder simular ambiente PAF-NFCE com Sigamat AM (NFC-e)
If (SM0->M0_ESTCOB $ 'SC' .OR. SuperGetMv("MV_PAFNFCE",,.F.)) .AND. SLG->(ColumnPos("LG_TIPOPAF")) > 0
	dbSelectArea("SLG")
	SLG->(DbSetOrder(1)) //LG_FILIAL+LG_CODIGO                                                                                                                                             
	If SLG->(DbSeek(xFilial("SLG")+cCodigo))
		cRet := Iif(Empty(SLG->LG_TIPOPAF),"0",SLG->LG_TIPOPAF) 
	EndIf
EndIf

RestArea(aArea)

Return cRet

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} LjOpTESInt
Retorna o Tipo de Operação a ser considerada para busca do TES inteligente, de acordo 
com o tipo de documento que está emitindo na venda ou se é geração de Pedido de Venda.
Conforme configuração do parâmetro MV_LJOPTES

@type 	 function
@author  Alberto Deviciente
@since 	 10/08/2022
@version P12

@param nTipo, Numérico, Tipo de Documento, podendo ser:
		1=ECF 		(Cupom Fiscal)
		2=SAT 		(Cupom SAT)
		3=NFC-e 	(Cupom NFC-e)
		4=NF-e		(Nota Fiscal)
		5=Pedido	(Pedido)

@return Caractere, Tipo de Operação a ser considerada para busca do TES inteligente.
/*/
//--------------------------------------------------------------------------------------
Function LjOpTESInt(nTipo,cDefault)
Local aArea 	 := GetArea()
Local cRetOperac := ""
Local cOperacao	 := ""
Local aTpOperac  := {}

Default cDefault := "01" 

If nTipo == Nil
	nTipo := LjTpDocVda()
EndIf

LjGrvLog(Nil, "Tipo de Documento (1=ECF, 2=SAT, 3=NFC-e, 4=NF, 5=Pedido)", nTipo)

//Retorna o conteudo do parâmetro, seja o conteudo configurado ou macro executado com regra customizada
cOperacao := LjMExeParam("MV_LJOPTES")

LjGrvLog(Nil, "Retorno do conteudo do parâmetro MV_LJOPTES", cOperacao)

If "," $ cOperacao //Verifica se o parâmetro está configurado com o separador para cada tipo de operação
	aTpOperac := StrTokArr2(cOperacao, ",")

	If Len(aTpOperac) >= nTipo
		cRetOperac := aTpOperac[nTipo]
	EndIf
EndIf

If Empty(cRetOperac)
	/*
	Define a Operação padrão que era utilizado no legado: 
		"01"=VENDA DE MERCADORIA; 
		"V"=PARA IDENTIFICACAO DE ENTREGAS FUTURAS
	*/
	cRetOperac := IIf(nTipo==5,"V",cDefault)
EndIf

cRetOperac := Padr(cRetOperac,TamSx3("FM_TIPO")[1])

RestArea(aArea)

LjGrvLog(Nil, "Tipo de Operação a ser considerada para busca do TES inteligente", cRetOperac)

Return cRetOperac

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTpDocVda
Retorna o Tipo de Documento Fiscal definido na venda.

@type 	 function
@author  Alberto Deviciente
@since 	 10/08/2022
@version P12

@return Numérico, Tipo de Documento Fiscal definido na venda, podendo ser:
		1=ECF 		(Cupom Fiscal - ECF)
		2=SAT 		(Cupom Fiscal Eletrônico - SAT)
		3=NFC-e 	(Cupom Fiscal Eletrônico - NFC-e)
		4=NF		(Nota Fiscal)
/*/
//--------------------------------------------------------------------------------------
Function LjTpDocVda()
Local nTipo 	:= 1 //Tipo de Documento Fiscal definido na venda (Default: 1=ECF)
Local lEmiteNF 	:= LjNFFimVd() .OR. (nModulo == 5) .OR. LjNfNoPaf(SM0->M0_CGC)

If lEmiteNF //Nota Fiscal
	nTipo := 4
ElseIf LjUseSat() //Usa SAT
	nTipo := 2
ElseIf LjEmitNFCe() //Usa NFC-e
	nTipo := 3
EndIf

LjGrvLog(Nil, "Tipo de Documento Fiscal definido na venda (1=ECF, 2=SAT, 3=NFC-e, 4=NF)", nTipo)

Return nTipo

//-----------------------------------------------------------------------
/*/{Protheus.doc} LjRpsAtivo
Retorna se a funcionalidade de RPS está ativa.

@type 	 Function
@author  Alberto Deviciente
@since 	 20/07/2022
@version 12.1.33

@return lRet, Lógico, Retorna se a funcionalidade de RPS está ativa.
/*/
//-----------------------------------------------------------------------
Function LjRpsAtivo()
Local lRet 		:= .F.

If SuperGetMv("MV_LJPRDSV",.F.,.F.)	//Verifica se esta habilitada a implementacao de venda com itens de "produto" e itens de "servico" em Notas Separadas (RPS)
	//Verifica se deve considerar ativa a funcionalidade de RPS.
	//Considera ativa caso não seja ECF ou caso seja ECF não pode existir item com reserva na venda.
	lRet := (SL1->L1_TPORC == "E" .Or.  ;	//SAT ou NFC-e
			SL1->L1_IMPNF 		  .Or.  ;	//Nota Fiscal
			(!Empty(SL1->L1_SERPDV) .And. !Empty(SL1->L1_NUMORIG) .And. Empty(SL1->L1_ORCRES) .And. Empty(SL1->L1_DOCPED))) //Venda com ECF
			//Se tiver preenchido o campo L1_NUMORIG, significa que foi um orcamento importado e finalizado pelo Totvs PDV
EndIf

LjGrvLog(Nil," RPS Ativo | Retorno:", lRet )

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} Lj7RPSNew()
Verifica se utiliza ou nao as novas modificacoes na
implementacao de RPS, onde agora permite realizar venda
com itens de entrega e itens de serviço juntos.
Antes não era permitido separar o item de serviço (RPS) 
quando tinha item de entrega na venda.

@type 	 function
@author  Alberto Deviciente
@since 	 19/08/2022
@version P12

@return Lógico, Retorna se ambiente está atualizado p/ trabalhar 
				com as modificações na implementacao de RPS
/*/
//--------------------------------------------------------
Function Lj7RPSNew()
Local aFontes	:= {}
Local aInfoFonte:= {}
Local nCount 	:= 0
Local dDataRef 	:= Nil

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
//SOMENTE DEVE CONSIDERAR AS NOVAS MODIFICACOES NA IMPLEMENTACAO DE RPS SE OS FONTES ESTIVEREM COM DATA IGUAL OU MAIOR QUE A DATA ESTIPULADA COMO DATA DE REFERENCIA
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
If lRPSNewReg == Nil
	dDataRef 	:= CToD("24/08/2022") //Data de referencia dos fontes
	lRPSNewReg  := .T. //Utiliza as novas modificacoes na implementacao do RPS

	//Fontes a serem verificados se estao atualizados
	aAdd( aFontes, "LOJA701C.PRW")
	aAdd( aFontes, "LOJA701D.PRW")
	aAdd( aFontes, "LOJXFUNC.PRW")
	aAdd( aFontes, "STBNotFiscal.prw")
	aAdd( aFontes, "STBPayment.prw")
	aAdd( aFontes, "STFTotalUpdate.prw")
	aAdd( aFontes, "STWItemRegistry.prw")
	aAdd( aFontes, "STBImportSale.prw")
	aAdd( aFontes, "LOJNFCE.PRW")
	aAdd( aFontes, "LJSCRPS.PRW")
	
	//Verifica a data dos fontes no RPO
	For nCount := 1 To Len(aFontes)
		aInfoFonte := GetAPOInfo(aFontes[nCount])
		If Empty(aInfoFonte) .Or. aInfoFonte[4] < dDataRef
			LJGrvLog(Nil, "Fonte " + aFontes[nCount] + " não encontrado no RPO ou a data é inferior a " + dtoc(dDataRef))
			lRPSNewReg := .F. //Continua utilizando a implementacao com comportamento antigo do RPS
			Exit
		EndIf

	Next nCount

	LjGrvLog(Nil," Lj7RPSNew | Retorno:", lRPSNewReg )
EndIf

Return lRPSNewReg
