#INCLUDE "FINA661.ch" 
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE __TAMLOTE 100 // Tamanho do lote de pedidos 
#DEFINE __CONFIRMA .T.  // Confirma o Lote

/*/{Protheus.doc} FINA661
Funcao do Processamento: Disponibilizar rotinas para Importacao de Pedidos do Sitema Reserve
Desenvolvido conforme manual de integracao do Reserve
Esta funÁ„o Processa a Tabela de Pessoas (RD0) enviando vias webservice os dados das pessoas
ainda n„o exportadas

@param aParam Parametro passado pelo schedule do Protheus para inicializar o ambiente se n„o passada sera
usado o ambiente do qual o rotina foi chamada.

@return Nada
@author Alexandre Circenis
@since 04/09/2013
@version MP1190
/*/
Function FINA661(cLicenciado)
Local oPedidos	:= WSPedidos():New()
Local oSvc			:= ""
Local cSessao		:= ""
Local lEnd
Local aPedidos	:= {}
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nTimeOut	:= SuperGetMV( "MV_RESTOUT", , 120 )
Local cStatus		:= '3'	// Define o status dos pedidos que serao retornados 
						// 0=Todos; 1=Pendentes; 2=Reservados; 3=Emitidos

ConOut(STR0011)//"Inicio Processamento dos Pedidos"

If FINXRESOSe(@cSessao, @oSvc,"FL5") // Conseguiu abrir a sess„o com o reserve
    
	// Lendo pedidos com erro no protheus 
  	aPedidos := FINA661Ped(cLicenciado) // Busca os pedidos com erro para reimportacao
  	aAux :={}
  	nX := 1
  	nY := 1
  	ConOut(STR0012)//"Processa Pedidos com erro"
	While nx <= Len(aPedidos)

		While nY <= __TAMLOTE .and.  nx <= Len(aPedidos)
			aadd(aAux, aPedidos[nx])
			nX++
			nY++
		enddo
		nY = 1
		
		oPedidos := Fina661Con(cSessao, cStatus, aAux )
		oPedidos:ConsultarPedidos()
  
	    If oPedidos:oWSConsultarPedidosResult:oWSPedidos = NIL /// N„o trouxe pedidos para processar
	    	nX := Len(aPedidos)+1
	    	loop
	    endif                    
	    
	    // Processar os pedidos que vieram no lote
		For nZ := 1 to Len(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO)
		    ConOut(STR0013+Str(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO[nZ]:nIdPedido))//"Passando pedido: "
			FINA661PRO(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO[nZ], cLicenciado , .T., cSessao )
		
		Next nZ
		
    EndDo
    //
	// Lendo pedidos Validos sem lote
    //
    aPedidos := {}
  	ConOut(STR0014)//"Processa Pedidos Validos"
  
	While !lEnd
		
		oPedidos := Fina661Con(cSessao, cStatus, aPedidos, .F. )
		
		If nTimeOut > 120
			WsCTimeOut(nTimeOut)	//	Aumento o TimeOut do WS somente para essa consulta
			oPedidos:ConsultarPedidos()
			WsCTimeOut(120)
		Else
			oPedidos:ConsultarPedidos()
		EndIf
		
		If oPedidos:oWSConsultarPedidosResult:oWSPedidos = NIL  .OR. Len(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO) = 0 /// N„o trouxe pedidos para processar
			lEnd := .T.
			loop
		EndIf
	    // Processar os pedidos que vieram no lote
		For nZ := 1 To Len(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO)
		    ConOut(STR0013+Str(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO[nZ]:nIdPedido))//"Passando pedido: "
			FINA661PRO(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO[nZ], cLicenciado,.f.,cSessao )
		
		Next nZ 

		lEnd := Len(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO) < __TAMLOTE
		
		If !Empty(oPedidos:oWSConsultarPedidosResult:nNumeroLote) .AND. __CONFIRMA
			// Confirmar o Lote
			oPedidos:oWSConfirmarLoteRQ:cSessao := cSessao
			oPedidos:oWSConfirmarLoteRQ:nNumeroLote := oPedidos:oWSConsultarPedidosResult:nNumeroLote
 			oPedidos:ConfirmarLote()
	    EndIf
		
	EndDo

	lEnd := .F.
	
	// Confirmar o Lote
	If !Empty(oPedidos:oWSConsultarPedidosResult:nNumeroLote) .and. __CONFIRMA
		oPedidos:oWSConfirmarLoteRQ:cSessao := cSessao
		oPedidos:oWSConfirmarLoteRQ:nNumeroLote := oPedidos:oWSConsultarPedidosResult:nNumeroLote
 		oPedidos:ConfirmarLote()
	EndIf
    //
	// Lendo pedidos Excluidos sem lote
    //
  	ConOut(STR0015)//"Processa Pedidos Excluidos"

	While !lEnd
	
		oPedidos := Fina661Con(cSessao, cStatus, aPedidos,.T. )
		
		If nTimeOut > 120
			WsCTimeOut(nTimeOut)	//	Aumento o TimeOut do WS somente para essa consulta
			oPedidos:ConsultarPedidos()
			WsCTimeOut(120)
		Else
			oPedidos:ConsultarPedidos()
		EndIf
		
		If oPedidos:oWSConsultarPedidosResult:oWSPedidos = NIL  .OR. Len(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO) = 0 /// N„o trouxe pedidos para processar
	    	lEnd := .T.
	    	loop
	    EndIf
	    // Processar os pedidos que vieram no lote
		For nZ := 1 to Len(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO)
		    ConOut(STR0015+Str(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO[nZ]:nIdPedido))// "Processa Pedidos Excluidos"
			FINA661PRO(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO[nZ], cLicenciado,.f., cSessao)
		
		Next nZ

		lEnd := Len(oPedidos:OWSCONSULTARPEDIDOSRESULT:OWSPEDIDOS:OWSPEDIDO) < __TAMLOTE
		
		If !Empty(oPedidos:oWSConsultarPedidosResult:nNumeroLote) .and. __CONFIRMA
			// Confirmar o Lote
			oPedidos:oWSConfirmarLoteRQ:cSessao := cSessao
			oPedidos:oWSConfirmarLoteRQ:nNumeroLote := oPedidos:oWSConsultarPedidosResult:nNumeroLote
			oPedidos:ConfirmarLote()
		EndIf
	    
	EndDo

	lEnd := .F.

	If !Empty(oPedidos:oWSConsultarPedidosResult:nNumeroLote).and. __CONFIRMA
		// Confirmar o Lote
		oPedidos:oWSConfirmarLoteRQ:cSessao := cSessao
		oPedidos:oWSConfirmarLoteRQ:nNumeroLote := oPedidos:oWSConsultarPedidosResult:nNumeroLote
		oPedidos:ConfirmarLote()
	EndIf
	
	FINXRESCSe( cSessao, @oSvc )
	
EndIf
ConOut(STR0016)//"Fim Processamento dos Pedidos " 

// Libera memoria apos o uso
oPedidos:= Nil   
DelClassIntF()

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FINA661PRO∫Autor  ≥Alexandre Circenis  ∫ Data ≥  09/04/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Processa o retorno do WEBSERVICE do Reserve logando o erros∫±±
±±∫          ≥ caso houverem                                              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function FINA661PRO(oPedidos, cLicenciado, lReproc, cSessao )
Local lFin661INC := ExistBlock("FN661INC")
Local aErro :={}  
Local cLog := ""
Local _cEmpresa	:= SM0->M0_CODIGO
Local _cFilial	:= SM0->M0_CODFIL
Local cEmpFat   := ""
Local _cEmpAux
Local _cFilAux
Local cCodRes   := Alltrim(BKO2Age(cEmpAnt+cFilAnt))
Local lCont     := .T.
Local aBKOEmp := {}

Default lReproc := .F. 


if oPedidos <> NIL

	ConOut(STR0017 + cCodRes) //"Empresa Reserve Atual: "  
    lCont := .T.
	if oPedidos:CEMPRESA <> oPedidos:CEMPRESAAFATURAR .or. cCodRes <> Alltrim(oPedidos:CEMPRESAAFATURAR) // Empresa onde foi colocado o pedido È diferente da empresa a fatura

		// Deleta a linha de inconsistencia antes de trocar o ambiente, pois se o pedido for alterado para nova empresa, o log precisa ser apagado neste empresa.
  		dbSelectArea("FL1")
    	if dbSeek(xFilial("FL1")+cLicenciado+Str(oPedidos:nIDPedido,8,0))
    		RecLock("FL1",.F.)
    		dbDelete()
    		msUnlock()	
    	endif

		// Trocar de ambiente
		ConOut(STR0018+oPedidos:CEMPRESAAFATURAR) //"Troca para Empresa Reserve:"      
		aBKOEmp := BKO2Emp(Alltrim(oPedidos:CEMPRESAAFATURAR)) 
		cEmpFat := aBKOEmp[1][1]        
		if Alltrim(cEmpFat) = Alltrim(oPedidos:CEMPRESAAFATURAR) .AND. !aBKOEmp[1][2] // N„o h· empresa cadastrada 
			cLog := STR0019+ Alltrim(oPedidos:CEMPRESAAFATURAR)+ STR0020 //N„o tem empressa cadastrada no Protheus.
			lCont := .F.
		else
			ConOut(STR0021 +cEmpFat)    //"Trocar para Protheus:"
			DbSelectArea("SM0")
			If SM0->(DbSeek(cEmpFat))
				_cEmpAux := SM0->M0_CODIGO
				_cFilAux := SM0->M0_CODFIL 
				ConOut(STR0022+_cEmpAux+_cFilAux)       
				RPCClearEnv()
				RpcSetType(3)
				RPCSetEnv(_cEmpAux,_cFilAux,,,"FIN")
				ConOut(STR0023+SM0->M0_CODIGO+SM0->M0_CODFIL)   
			EndIf
		EndIf
	EndIf
	
	If lCont
	    If lFin661Inc
    	
	    	cLog := ExecBlock("FN661INC", .F., .F., {oPedidos,cLicenciado,cSessao})

		Else
    	
    		cLog := FinA661INC(oPedidos,cLicenciado, cSessao)
    		
    	EndIf	
    
    EndIf
    
    if !Empty(cLog)  // Erro na Inclus„o

    	dbSelectArea("FL1")
    	if !dbSeek(xFilial("FL1")+cLicenciado+Str(oPedidos:nIDPedido,8,0))
    		RecLock("FL1",.T.)
    		FL1->FL1_FILIAL := xFilial("FL1")
    		FL1->FL1_LICENC := cLicenciado
    		FL1->FL1_IDPED  := Str(oPedidos:nIDPedido,8,0)	
    		msUnlock()	
    	endif
    	
    	Aadd(aErro,STR0001+Str(oPedidos:nIDPedido,8,0)) //"Erros na inclus„o do pedido : "
 	  	Aadd(aErro,STR0002+cLicenciado) //"do Licenciado Reserve : "
		FINXRESLog("FL5",STR0003,"",aErro, ,cLog) //"Immportacao de Pedidos"
		
	elseif lReproc  
		// Eh reprocessamento dos pedidos
  		dbSelectArea("FL1")
    	if dbSeek(xFilial("FL1")+cLicenciado+Str(oPedidos:nIDPedido,8,0))
    		RecLock("FL1",.F.)
    		dbDelete()
    		msUnlock()	
    	endif
  		
    endif
    
Else
    	
	Aadd(aErro,STR0004) //"Erros no XML"
	FINXRESLog("FL5",STR0005,"",aErro) //"Importacao de Pedidos"

EndIf	

If !Empty(_cEmpAux) .AND. !Empty(_cFilAux)
	RPCClearEnv()
	RpcSetType(3)
	RPCSetEnv(_cEmpresa,_cFilial,,,"FIN")
EndIf

Return 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FinA661INC∫Autor  ≥Alexandre Circenis  ∫ Data ≥  09/04/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥FunÁ„o responsavel pela inclusao do pedido reserve no       ∫±±
±±∫          ≥cadastro de solicitacoes de viagens                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function FinA661INC(oPedidos,cLicenciado, cSessao)
Local cLog 	 := ''
Local aFL5 := {}
Local aFLC := {}
Local aFL6 := {}
Local aFLH := {}
Local aFLU := {}
Local aFLJ := {}
Local aAux := {}
Local aTipos := {}
Local aNewMat := {}
Local nX := 1
Local nA := 1
Local lExist := .F.
Local oTipos := Nil
Local lRet   := .T.
Local lAdian := If(oPedidos:cCampoExtra1 <> Nil .AND. oPedidos:cCampoExtra1 == 'SIM',.T.,.F.)
Local cAprov := SuperGetMV("MV_RESAPRO",,"")  
Local nTamCli:= 0  
Local nPosMat:= 0
Local lCliente := SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),2,1) == "1" //Verifica se utiliza cliente.

If Type("aTabelas") <> "A"
	Private aTabelas := {}
EndIf

Default cLicenciado := ''
	dbSelectArea('FLC')
	
 	//---Busca por pedidos, se j· existir passa para o proximo pedido.
	lRet := IIf(oPedidos:lExcluido, .T., F661BuscaPed(oPedidos:nIdPedido))
 	
	If lRet
		
		If ValType( oPedidos:OWSAUTORIZADORES ) == "U"
			cLog := STR0024 //"N„o existem aprovadores para este pedido."
		Else
			If (oPedidos:OWSAUTORIZADORES <> Nil) .AND. (oPedidos:oWSAutorizadores:oWSAutorizador[1]:cMatricula <> Nil)
				cAprov := oPedidos:oWSAutorizadores:oWSAutorizador[nX]:cMatricula
			EndIf
		EndIf
		
		If Empty(cLog)
			//----Grava os dados do autorizador.
			cLog := F661Passag(oPedidos:OWSAUTORIZADORES:OWSAUTORIZADOR,cSessao,cAprov,@aNewMat,2)
		EndIf
		
		//----Valida os dados do passageiros antes de iniciar a importaÁ„o dos dados.
		cLog += F661Passag(oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO,cSessao,cAprov,@aNewMat,1)
	
		//----Inicia a importaÁ„o.
		If  Empty(cLog) .and. !oPedidos:LEXCLUIDO 
			//--------------------Preenche FL5 - Cadastro de Viagens.----------------------
			aAdd(aFL5, 'FL5MASTER')	
			
			//Preenche os dados da viagem com o pedido atual.
			F661Dados(@aFL5,oPedidos:OWSRESERVAESCOLHIDA:OWSITENSRESERVA:OWSITEMRESERVA,oPedidos:nTipo)

			If oPedidos:cProjeto <> NIL
				nTamCli:= len(oPedidos:cProjeto)-TamSx3('Fl5_LOJA')[1]
			Endif
		
			aAdd(aFL5 ,{'FL5_NACION',If(oPedidos:OWSRESERVAESCOLHIDA:OWSITENSRESERVA:OWSITEMRESERVA[nX]:LINTERNACIONAL,'2','1')})
			aAdd(aFL5 ,{'FL5_IDRESE',cValToChar(oPedidos:nIdGrupo)})
			aAdd(aFL5 ,{'FL5_LICRES',cLicenciado})
			aAdd(aFL5 ,{'FL5_STATUS','1'})
			aAdd(aFL5 ,{'FL5_OBS',''})
	   		//Utiliza clientes.
	   		If lCliente
		   		aAdd(aFL5 ,{'FL5_CLIENT',PADR(Substr(Alltrim(oPedidos:cProjeto ),1,nTamCli),TamSx3('Fl5_CLIENT')[1]," ")})
				aAdd(aFL5 ,{'FL5_NOME',If(oPedidos:cProjeto <> Nil,SubStr(oPedidos:cProjeto,0,40),'')})
		   		aAdd(aFL5 ,{'FL5_LOJA',Right(Alltrim(oPedidos:cProjeto ), TamSx3('Fl5_LOJA')[1])})
			EndIf
			aAdd(aFL5 ,{'FL5_ADIANT',If(oPedidos:cCampoExtra1 <> Nil .and. Upper(Alltrim(oPedidos:cCampoExtra1))= 'SIM','1','2')})
			aAdd(aFL5 ,{'FL5_CC',''})
			aAdd(aTabelas,aFL5)
		
			//Preenche FLC - Passageiros.
			For nX := 1 To Len(oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO)  
				nPosMat := aScan(aNewMat,{|x| x[1]=oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:nID})
				If nPosMat > 0
					aAdd(aFLC, 'FLCDETAIL')
					aAdd(aFLC, {'FLC_PARTIC',aNewMat[nPosMat][2]})  
					aAdd(aFLC, {'FLC_IDRESE',Padr(oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:nID,9)})
					aAdd(aFLC, {'FLC_NOME',oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:cNome})
					aAdd(aFLC, {'FLC_BILHET',oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:cBilhete})
					aAdd(aTabelas,aFLC)
					aFLC := {}
				EndIf
			End	
			//-----------------Preenche FL6 - Pedidos.----------------------------------
			aAdd(aFL6,'FL6DETAIL')
			aAdd(aFL6,{'FL6_LICENC',cLicenciado})
			aAdd(aFL6,{'FL6_IDRESE',cValToChar(oPedidos:nIdPedido)}) // 
			aAdd(aFL6,{'FL6_DTCRIA',If(oPedidos:cDataCriacao <> Nil,;//
						  StoD(Subs(STRTRAN(oPedidos:cDataCriacao,'-',''),1,8)),;
						  Date())})
			aAdd(aFL6,{'FL6_TIPO',If(oPedidos:nTipo <> Nil,cValToChar(oPedidos:nTipo),'0')})// ??/
			aAdd(aFL6,{'FL6_TOTFEE',If(oPedidos:nTotalFEE <> Nil,oPedidos:nTotalFEE,0)})
			aAdd(aFL6,{'FL6_DTEMIS',If(oPedidos:cDataEmissao <> Nil,;
						  StoD(Subs(STRTRAN(oPedidos:cDataEmissao,'-',''),1,8)),;
						  Date())})
			aAdd(aFL6,{'FL6_LOCALI',oPedidos:oWSReservaEscolhida:cLocalizador})
			aAdd(aFL6,{'FL6_LOCPAS',oPedidos:oWSReservaEscolhida:cLocReservaPassiva})
			aAdd(aFL6,{'FL6_ORIRES',cValToChar(oPedidos:oWSReservaEscolhida:oWSOrigemReserva:Value)})
			aAdd(aFL6,{'FL6_DTRESE',StoD(Subs(STRTRAN(oPedidos:oWSReservaEscolhida:cDataReserva,'-',''),1,8))})
			aAdd(aFL6,{'FL6_TARPAX',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nTarifaPorPax,0)})
			aAdd(aFL6,{'FL6_TAXPAX',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nTaxaPorPax,0)})
			aAdd(aFL6,{'FL6_TAXSER',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nTaxaServico,0)})
			aAdd(aFL6,{'FL6_TARACO',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nTarifaAcordo,0)})
			aAdd(aFL6,{'FL6_TARPRO',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nTarifaPromocional,0)})
			aAdd(aFL6,{'FL6_TARREF',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nTarifaReferencia,0)})
			aAdd(aFL6,{'FL6_MENTAR',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nMenorTarifa,0)})
			aAdd(aFL6,{'FL6_MOEDA', If(oPedidos:oWSReservaEscolhida <> Nil,PadL(oPedidos:oWSReservaEscolhida:cMoeda,TamSX3('FL6_MOEDA')[1]),'')})
			aAdd(aFL6,{'FL6_MOETAX',If(oPedidos:oWSReservaEscolhida <> Nil,PadL(oPedidos:oWSReservaEscolhida:cMoedaTaxa,TamSX3('FL6_MOETAX')[1]),'')})
			aAdd(aFL6,{'FL6_MULTA', If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nMulta,0)})
			aAdd(aFL6,{'FL6_CREDIT',If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nCredito,0)})
			aAdd(aFL6,{'FL6_TOTAL', If(oPedidos:oWSReservaEscolhida <> Nil,oPedidos:oWSReservaEscolhida:nTotal,0)})
			aAdd(aFL6,{'FL6_IDSOLI',If(oPedidos:oWSSolicitante <> Nil,Str(oPedidos:oWSSolicitante:nID,10,0),0)})
			aAdd(aFL6,{'FL6_NOMESO',If(oPedidos:oWSSolicitante <> Nil,oPedidos:oWSSolicitante:cNome,'')})
			aAdd(aFL6,{'FL6_PARTSO',If(oPedidos:oWSSolicitante <> Nil,oPedidos:oWSSolicitante:cMatricula,'')})
			aAdd(aFL6,{'FL6_NOMERE',If(oPedidos:oWSResponsavel <> Nil,oPedidos:oWSResponsavel:cNome,'')})
			aAdd(aFL6,{'FL6_PARTRE',If(oPedidos:oWSResponsavel <> Nil,oPedidos:oWSResponsavel:cMatricula,'')})
			aAdd(aFL6,{'FL6_IDREMA',If(oPedidos:nIDRemarcacao  <> Nil,cValToChar(oPedidos:nIDRemarcacao),'')})
			aAdd(aFL6,{'FL6_FPAGTO',If(oPedidos:nFormaPgto <> Nil,PadL(oPedidos:nFormaPgto,TamSX3('FL6_FPAGTO')[1]),'00')})
			aAdd(aFL6,{'FL6_BKOFAT',If(oPedidos:cEmpresaAFaturar <> Nil,oPedidos:cEmpresaAFaturar,'')})
			aAdd(aFL6,{'FL6_MOTIVO',If(oPedidos:cMotivo <> Nil,oPedidos:cMotivo,'')})
			aAdd(aFL6,{'FL6_ATIVI', If(oPedidos:cAtividade <> Nil,oPedidos:cAtividade,'')})
			aAdd(aFL6,{'FL6_EXTRA1',If(oPedidos:cCampoExtra1 <> Nil,oPedidos:cCampoExtra1,'')})
			aAdd(aFL6,{'FL6_EXTRA2',If(oPedidos:cCampoExtra2 <> Nil,oPedidos:cCampoExtra2,'')})
			aAdd(aFL6,{'FL6_EXTRA3',If(oPedidos:cCampoExtra3 <> Nil,oPedidos:cCampoExtra3,'')})
			aAdd(aTabelas,aFL6)
		
			//Preenche FLU - Passageiros por Pedidos.
		
			For nX := 1 To Len(oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO)  
				nPosMat := aScan(aNewMat,{|x| x[1]=oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:nID})
				If nPosMat > 0
					aAdd(aFLU, 'FLUDETAIL')
					aAdd(aFLU, {'FLU_PARTIC',aNewMat[nPosMat][2]})  
					aAdd(aFLU, {'FLU_IDRESE',Padr(oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:nID,9)})
					aAdd(aFLU, {'FLU_NOME',oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:cNome})
					aAdd(aFLU, {'FLU_BILHET',oPedidos:OWSPASSAGEIROS:OWSPASSAGEIRO[nX]:cBilhete})
					aAdd(aTabelas,aFLU)
					aFLU := {} 
				EndIf
			Next	
			// Tipos de Reserva
			oTipos := oPedidos:OWSRESERVAESCOLHIDA:OWSITENSRESERVA:OWSITEMRESERVA
			Do Case
				Case (oPedidos:nTipo == 1) //------------------------------Aereo. 
					For nX := 1 To Len(oTipos)
						If (oTipos[nX]:oWSPassagemAereo <> Nil)
							If (oTipos[nX]:oWSPassagemAereo:cNomeCia <> Nil)
								aAdd(aTipos,'FL7DETAIL')
								aAdd(aTipos,{'FL7_VOO'   ,If(oTipos[nX]:oWSPassagemAereo:cVoo <> Nil,oTipos[nX]:oWSPassagemAereo:cVoo,'')})
								aAdd(aTipos,{'FL7_CODCIA',If(oTipos[nX]:oWSPassagemAereo:cCodCia <> Nil,oTipos[nX]:oWSPassagemAereo:cCodCia,'')})
								aAdd(aTipos,{'FL7_NOME'  ,If(oTipos[nX]:oWSPassagemAereo:cNomeCia <> Nil,oTipos[nX]:oWSPassagemAereo:cNomeCia,'')})
								aAdd(aTipos,{'FL7_CODORI',If(oTipos[nX]:oWSPassagemAereo:cCodOrigem <> Nil,oTipos[nX]:oWSPassagemAereo:cCodOrigem,'')})			
								aAdd(aTipos,{'FL7_ORIGEM',If(oTipos[nX]:oWSPassagemAereo:cOrigem <> Nil,Left(Alltrim(oTipos[nX]:oWSPassagemAereo:cOrigem),TAMSX3("FL7_ORIGEM")[1]),'')})
								aAdd(aTipos,{'FL7_CODES' ,If(oTipos[nX]:oWSPassagemAereo:cCodDestino <> Nil,oTipos[nX]:oWSPassagemAereo:cCodDestino,'')})	
								aAdd(aTipos,{'FL7_DESTIN',If(oTipos[nX]:oWSPassagemAereo:cDestino <> Nil,Left(Alltrim(oTipos[nX]:oWSPassagemAereo:cDestino),TAMSX3("FL7_DESTIN")[1]),'')})
								aAdd(aTipos,{'FL7_DSAIDA',StoD(Subs(STRTRAN(oTipos[nX]:oWSPassagemAereo:cSaida,'-',''),1,8))})
								aAdd(aTipos,{'FL7_HSAIDA',Subs(STRTRAN(oTipos[nX]:oWSPassagemAereo:cSaida,'-',''),10,5)})
								aAdd(aTipos,{'FL7_DCHEGA',StoD(Subs(STRTRAN(oTipos[nX]:oWSPassagemAereo:cChegada,'-',''),1,8))})
								aAdd(aTipos,{'FL7_HCHEGA',Subs(STRTRAN(oTipos[nX]:oWSPassagemAereo:cChegada,'-',''),10,5)})
								aAdd(aTipos,{'FL7_STATUS',If(oTipos[nX]:oWSPassagemAereo:cStatus <> Nil,oTipos[nX]:oWSPassagemAereo:cStatus,'')})
								aAdd(aTipos,{'FL7_CLASSE',If(oTipos[nX]:oWSPassagemAereo:cClasse <> Nil,oTipos[nX]:oWSPassagemAereo:cClasse,'')})
								aAdd(aTabelas,aTipos)
								aTipos := {}
							EndIf
						Endif
					Next
				Case (oPedidos:nTipo == 2) //-----------------------------Hotel.
					For nX := 1 To Len(oTipos)
						If (oTipos[nX]:oWSAcomodacao <> Nil)
							If (oTipos[nX]:oWSAcomodacao:cNomeHotel <> '')
								aAdd(aTipos,'FL9DETAIL')
								aAdd(aTipos,{'FL9_CODHOT' ,If(oTipos[nX]:oWSAcomodacao:cIDHotel <> Nil,oTipos[nX]:oWSAcomodacao:cIDHotel,'')})
								aAdd(aTipos,{'FL9_NOME',If(oTipos[nX]:oWSAcomodacao:cNomeHotel <> Nil,Left(Alltrim(oTipos[nX]:oWSAcomodacao:cNomeHotel),TAMSX3("FL9_NOME")[1]),'')})
								aAdd(aTipos,{'FL9_CNPJ',If(oTipos[nX]:oWSAcomodacao:cCNPJHotel <> Nil,oTipos[nX]:oWSAcomodacao:cCNPJHotel,'')})
								aAdd(aTipos,{'FL9_CODCID',If(oTipos[nX]:oWSAcomodacao:cCodCidade <> Nil,oTipos[nX]:oWSAcomodacao:cCodCidade,'')})			
								aAdd(aTipos,{'FL9_CIDADE',If(oTipos[nX]:oWSAcomodacao:cCidade <> Nil,Left(Alltrim(oTipos[nX]:oWSAcomodacao:cCidade),TAMSX3("FL9_CIDADE")[1]),'')})
								aAdd(aTipos,{'FL9_DCHKIN',StoD(Subs(STRTRAN(oTipos[nX]:oWSAcomodacao:cCheckin,'-',''),1,8))})	
								aAdd(aTipos,{'FL9_HCHKIN',Subs(STRTRAN(oTipos[nX]:oWSAcomodacao:cCheckin,'-',''),10,5) })
								aAdd(aTipos,{'FL9_DCHKOU',StoD(Subs(STRTRAN(oTipos[nX]:oWSAcomodacao:cCheckout,'-',''),1,8))})
								aAdd(aTipos,{'FL9_HCHKOU',Subs(STRTRAN(oTipos[nX]:oWSAcomodacao:cCheckout,'-',''),10,5)})
								aAdd(aTipos,{'FL9_CATEG',If(oTipos[nX]:oWSAcomodacao:cCategoria <> Nil,oTipos[nX]:oWSAcomodacao:cCategoria,'')})
								aAdd(aTipos,{'FL9_DIARIA',If(oTipos[nX]:oWSAcomodacao:nDiarias <> Nil,oTipos[nX]:oWSAcomodacao:nDiarias,0)})
								aAdd(aTabelas,aTipos)
								aTipos := {}
							EndIf
						Endif
					Next	
				Case (oPedidos:nTipo == 3) //------------------------LocaÁ„o Carro.
					For nX := 1 To Len(oTipos)
						If (oTipos[nX]:oWSLocacaoCarro <> Nil)
							If (oTipos[nX]:oWSLocacaoCarro:cNomeLocadora <> '')
								aAdd(aTipos,'FLBDETAIL')
								aAdd(aTipos,{'FLB_IDLOC' ,If(oTipos[nX]:oWSLocacaoCarro:cIDLocadora <> Nil,oTipos[nX]:oWSLocacaoCarro:cIDLocadora,'')})
								aAdd(aTipos,{'FLB_NOME'  ,If(oTipos[nX]:oWSLocacaoCarro:cNomeLocadora <> Nil,oTipos[nX]:oWSLocacaoCarro:cNomeLocadora,'')})
								aAdd(aTipos,{'FLB_CODRET',If(oTipos[nX]:oWSLocacaoCarro:cCodCidadeRetirada <> Nil,oTipos[nX]:oWSLocacaoCarro:cCodCidadeRetirada,'')})
								aAdd(aTipos,{'FLB_CIDRET',If(oTipos[nX]:oWSLocacaoCarro:cCidadeRetirada <> Nil,Left(Alltrim(oTipos[nX]:oWSLocacaoCarro:cCidadeRetirada),TAMSX3("FLB_CIDRET")[1]),'')})			
								aAdd(aTipos,{'FLB_CODDEV',If(oTipos[nX]:oWSLocacaoCarro:cCodCidadeDevolucao <> Nil,oTipos[nX]:oWSLocacaoCarro:cCodCidadeDevolucao,'')})
								aAdd(aTipos,{'FLB_CIDDEV',If(oTipos[nX]:oWSLocacaoCarro:cCidadeDevolucao <> Nil,Left(Alltrim(oTipos[nX]:oWSLocacaoCarro:cCidadeDevolucao),TAMSX3("FLB_CIDDEV")[1]),'')})
								aAdd(aTipos,{'FLB_LOCDEV',If(oTipos[nX]:oWSLocacaoCarro:cLocalDevolucao <> Nil,Left(Alltrim(oTipos[nX]:oWSLocacaoCarro:cLocalDevolucao),TAMSX3("FLB_LOCDEV")[1]),'')})
								aAdd(aTipos,{'FLB_DRETIR',StoD(Subs(STRTRAN(oTipos[nX]:oWSLocacaoCarro:cDataRetirada,'-',''),1,8))})
								aAdd(aTipos,{'FLB_DDEVOL',StoD(Subs(STRTRAN(oTipos[nX]:oWSLocacaoCarro:cDataDevolucao,'-',''),1,8))})
								aAdd(aTipos,{'FLB_TIPVEI',If(oTipos[nX]:oWSLocacaoCarro:cTipoVeiculo <> Nil,oTipos[nX]:oWSLocacaoCarro:cTipoVeiculo,'')})
								aAdd(aTipos,{'FLB_DIARIA',If(oTipos[nX]:oWSLocacaoCarro:nDiarias <> Nil,oTipos[nX]:oWSLocacaoCarro:nDiarias,0)})
								aAdd(aTabelas,aTipos)
								aTipos := {}
							EndIf
						EndIf
					Next	
				Case (oPedidos:nTipo == 5) //-------------------------------Rodoviario.
					For nX := 1 To Len(oTipos)
						If (oTipos[nX]:oWSPassagemRodoviario <> Nil)
							If (oTipos[nX]:oWSPassagemRodoviario:cNomeCia <> '')
								aAdd(aTipos,'FL8DETAIL')
								aAdd(aTipos,{'FL8_CODCIA',If(oTipos[nX]:oWSPassagemRodoviario:cCodCia <> Nil,oTipos[nX]:oWSPassagemRodoviario:cCodCia,'')})
								aAdd(aTipos,{'FL8_NOME'  ,If(oTipos[nX]:oWSPassagemRodoviario:cNomeCia <> Nil,Left(Alltrim(oTipos[nX]:oWSPassagemRodoviario:cNomeCia),TAMSX3("FL8_NOME")[1]),'')})
								aAdd(aTipos,{'FL8_CODORI',If(oTipos[nX]:oWSPassagemRodoviario:cCodOrigem <> Nil,oTipos[nX]:oWSPassagemRodoviario:cCodOrigem,'')})
								aAdd(aTipos,{'FL8_ORIGEM',If(oTipos[nX]:oWSPassagemRodoviario:cOrigem <> Nil,Left(Alltrim(oTipos[nX]:oWSPassagemRodoviario:cOrigem),TAMSX3("FL8_ORIGEM")[1]),'')})		
								aAdd(aTipos,{'FL8_CODDES',If(oTipos[nX]:oWSPassagemRodoviario:cCodDestino <> Nil,oTipos[nX]:oWSPassagemRodoviario:cCodDestino,'')})
								aAdd(aTipos,{'FL8_DESTIN',If(oTipos[nX]:oWSPassagemRodoviario:cDestino <> Nil,Left(Alltrim(oTipos[nX]:oWSPassagemRodoviario:cDestino),TAMSX3("FL8_DESTIN")[1]),'')})	
								aAdd(aTipos,{'FL8_HSAIDA',Subs(STRTRAN(oTipos[nX]:oWSPassagemRodoviario:cSaida,'-',''),10,5) })
								aAdd(aTipos,{'FL8_DSAIDA',StoD(Subs(STRTRAN(oTipos[nX]:oWSPassagemRodoviario:cSaida,'-',''),1,8))})
								aAdd(aTipos,{'FL8_DCHEGA',If(oTipos[nX]:oWSPassagemRodoviario:cChegada <> '',;
									            StoD(Subs(STRTRAN(oTipos[nX]:oWSPassagemRodoviario:cChegada,'-',''),1,8)),;
									            StoD(Subs(STRTRAN(oTipos[nX]:oWSPassagemRodoviario:cSaida,'-',''),1,8)))})
								aAdd(aTipos,{'FL8_HCHEGA',Subs(STRTRAN(oTipos[nX]:oWSPassagemRodoviario:cChegada,'-',''),10,5)})
								aAdd(aTipos,{'FL8_CLASSE',If(oTipos[nX]:oWSPassagemRodoviario:cClasse <> Nil,oTipos[nX]:oWSPassagemRodoviario:cClasse,'')})
								aAdd(aTabelas,aTipos)
								aTipos := {}
							EndIf
						Endif
					Next	
				Case (oPedidos:nTipo == 4)//----------------------------Seguro.
					For nX := 1 To Len(oTipos)
						If (oTipos[nX]:oWSSeguro <> Nil)
							If (oTipos[nX]:oWSSeguro:cNomeSeguradora <> '')
								aAdd(aTipos,'FLADETAIL')
								aAdd(aTipos,{'FLA_CODSEG' ,If(oTipos[nX]:oWSSeguro:cIDSeguradora <> Nil,oTipos[nX]:oWSSeguro:cIDSeguradora,'')})
								aAdd(aTipos,{'FLA_NOME'  ,If(oTipos[nX]:oWSSeguro:cNomeSeguradora <> Nil,Left(Alltrim(oTipos[nX]:oWSSeguro:cNomeSeguradora),TAMSX3("FLA_NOME")[1]),'')})
								aAdd(aTipos,{'FLA_CODCID',If(oTipos[nX]:oWSSeguro:cCodCidade <> Nil,oTipos[nX]:oWSSeguro:cCodCidade,'')})
								aAdd(aTipos,{'FLA_CIDADE',If(oTipos[nX]:oWSSeguro:cCidade <> Nil,Left(Alltrim(oTipos[nX]:oWSSeguro:cCidade),TAMSX3("FLA_CIDADE")[1]),'')})		
								aAdd(aTipos,{'FLA_INICIO',StoD(Subs(STRTRAN(oTipos[nX]:oWSSeguro:cInicioValidade,'-',''),1,8))})
								aAdd(aTipos,{'FLA_FINAL',StoD(Subs(STRTRAN(oTipos[nX]:oWSSeguro:cFimValidade,'-',''),1,8))})
								aAdd(aTipos,{'FLA_PLANO',If(oTipos[nX]:oWSSeguro:cPlano <> Nil,Left(Alltrim(oTipos[nX]:oWSSeguro:cPlano),TAMSX3("FLA_PLANO")[1]),'')})
								aAdd(aTipos,{'FLA_DIARIA',If(oTipos[nX]:oWSSeguro:nDiarias <> Nil,oTipos[nX]:oWSSeguro:nDiarias,0)})	
								aAdd(aTabelas,aTipos)
								aTipos := {}
							EndIf
						Endif
					next	
			EndCase
	  
		 	//------------------Centro de Custo-------------------------------------
			If (oPedidos:OWSCCUSTOS <> Nil)
				For nX := 1 To Len(oPedidos:OWSCCUSTOS:OWSCCUSTO)	
					
					//Casos do mesmo centro de custo no pedido.
					For nA := 1 To Len(aAux)
						If 	oPedidos:OWSCCUSTOS:OWSCCUSTO[nX]:cCCusto == aAux[nA]
							lExist := .T.	
						EndIf	 
					Next
					aAdd(aAux,oPedidos:OWSCCUSTOS:OWSCCUSTO[nX]:cCCusto)
					If !lExist
						aAdd(aFLH, 'FLHDETAIL')
						aAdd(aFLH,{'FLH_CC'     ,Left(Alltrim(oPedidos:OWSCCUSTOS:OWSCCUSTO[nX]:cCCusto),TAMSX3("FLH_CC")[1])})
						aAdd(aFLH,{'FLH_PORCEN',Val(oPedidos:OWSCCUSTOS:OWSCCUSTO[nX]:cPercentual)})
						aAdd(aTabelas,aFLH)
						aFLH := {}
					EndIf	
				End
				aAux := {}
			EndIf
			//----------------Aprovadores.-----------------------------------------
			If (oPedidos:OWSAUTORIZADORES <> Nil)
				For nX := 1 To Len(oPedidos:OWSAUTORIZADORES:OWSAUTORIZADOR)
					If oPedidos:OWSAUTORIZADORES:OWSAUTORIZADOR[nX]:cNome <> Nil 
						nPosMat := aScan(aNewMat,{|x| x[1] = oPedidos:OWSAUTORIZADORES:OWSAUTORIZADOR[nX]:nIDAutorizador})
						If nPosMat > 0
							aAdd(aFLJ,'FLJDETAIL')
							aAdd(aFLJ,{'FLJ_PARTIC',aNewMat[nPosMat][2]})
							aAdd(aFLJ,{'FLJ_NOME',Left(Alltrim(oPedidos:oWSAutorizadores:oWSAutorizador[nX]:cNome),TAMSX3("FLA_PLANO")[1])})
							aAdd(aFLJ,{'FLJ_EMAIL',oPedidos:oWSAutorizadores:oWSAutorizador[nX]:cEmail})
							aAdd(aTabelas,aFLJ)
							aFLJ := {}
						End	
					End
				Next
			EndIf			
			//Inclui pedidos
			cLog := F665INC(aTabelas,oPedidos:nIdGrupo,oPedidos:lExcluido,lAdian,oPedidos:nIdPedido,oPedidos)
			
			oTipos := Nil
			aSize(aTabelas,0)
			aSize(aFL5,0)
			aSize(aFL6,0)
			aSize(aFLC,0)
			aSize(aFLH,0)
			aSize(aFLJ,0)
			aSize(aTipos,0)
			aSize(aNewMat,0)
			aNewMat	:= Nil	
			aTabelas 	:= Nil
			aFL5      := Nil
			aFL6      := Nil
			aFLC      := Nil
			aFLH      := Nil
			aFLJ      := Nil
			aTipos    := Nil
		Else
			//Exclui o pedido
			cLog := F665INC(/**/,oPedidos:nIdGrupo,oPedidos:lExcluido,/**/,oPedidos:nIdPedido)	
		EndIf	
	EndIf	
		//
Return cLog

     
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FINA661CON∫Autor  ≥Alexandre Cirenis   ∫ Data ≥  09/06/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Prepara a o filtro dos pedidos que ser„o trazido do reserve∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function Fina661Con(cSessao, cStatus, aPedidos, lExcluidos )
Local dData := dDataBase - SuperGetMV("MV_RESDIAS",.T.,180) 
Local oPedidos := WSPedidos():New()               
Local cCodBKO			:= BKO2AGE(cEmpAnt+cFilAnt)

// Define o status dos pedidos que serao retornados
// 0=Todos; 1=Pendentes; 2=Reservados; 3=Emitidos 
Default cStatus := '3' 
// Array contendo a lista de pedidos que devem ser retornados pelo site Reserve.
// A lista tem prioridade sobre a data, entao se podera trazer pedidos de
// qualquer periodo. 
Default aPedidos := {}
// Por padrao ser„o consultados o n„o deletados
Default lExcluidos := .F.

oPedidos:OWSCONSULTARPEDIDOSRQ:cSessao    := cSessao
oPedidos:OWSCONSULTARPEDIDOSRQ:cDataInicial := Transform(dtos(dData),"@r 9999-99-99")

if Len(aPedidos) > 0
	oPedidos:OWSCONSULTARPEDIDOSRQ:oWSIDPedidos := Pedidos_ArrayOfInt():New() 
	oPedidos:OWSCONSULTARPEDIDOSRQ:oWSIDPedidos:nIDPedido := aPedidos
endif	

oPedidos:OWSCONSULTARPEDIDOSRQ:OWSSTATUS:Value   := cStatus
oPedidos:OWSCONSULTARPEDIDOSRQ:OWSSTATUSCAV:Value  := '0'
oPedidos:OWSCONSULTARPEDIDOSRQ:OWSTipoRetorno:Value := '1'
oPedidos:OWSCONSULTARPEDIDOSRQ:oWSExcluido:Value := if(lExcluidos,'2', '1')
oPedidos:OWSCONSULTARPEDIDOSRQ:oWSMigrados:Value := '0'
oPedidos:OWSCONSULTARPEDIDOSRQ:nQtdeRetorno := __TAMLOTE

// Nao passa BKO quando passa a lista de pedidos a reimportar
If Len(aPedidos) == 0
	oPedidos:OWSCONSULTARPEDIDOSRQ:oWSEmpresas:= Pedidos_ArrayOfString():New()
	oPedidos:OWSCONSULTARPEDIDOSRQ:oWSEmpresas:cEmpresa := {Alltrim(cCodBKO)}  
Endif

Return oPedidos  

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FINA661PED∫Autor  ≥Alexandre Circenis  ∫ Data ≥  09/04/13   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Retorna um array com o pedidos do reserve que n„o foram     ∫±±
±±∫          ≥importados corretamente pelo Protheus                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function FINA661Ped(cLicenciado)
Local aRet := {}
Local aArea := GetArea()

dbSelectArea("FL1")
dbSeek(xFilial("FL1")+cLicenciado)
while !Eof() .and. FL1->(FL1_FILIAL+FL1_LICENC) = xFilial("FL1")+cLicenciado
	Aadd(aRet, Val(FL1->FL1_IDPED))
	dbSkip()
enddo

RestArea(aArea)

Return aRet

/*/{Protheus.doc}
Preenche dados da FL5.
@author William Matos Gundim Junior
@since  16/10/2013
@version 11.90
/*/
Function F661Dados(aFL5,oPedidos,nTipo)
Local nX := 1
Local dDataIni := Date()
Local dDataFim := Date()

If 		nTipo == 1 //---Aereo.
	For nX := 1 To Len(oPedidos) //Procura pelos dados da viagem e n„o pelos dados da solicitaÁ„o.
		If oPedidos[nX]:oWSPassagemAereo:cNomeCia <> Nil
			Exit
		EndIf			
	End
	aAdd(aFL5, {'FL5_CODORI',oPedidos[nX]:oWSPassagemAereo:cCodOrigem})
	aAdd(aFL5, {'FL5_DESORI',Left(Alltrim(oPedidos[nX]:oWSPassagemAereo:cOrigem),TamSX3("FL5_DESORI")[1])})
	aAdd(aFL5, {'FL5_CODDES',Left(Alltrim(oPedidos[nX]:oWSPassagemAereo:cCodDestino),TamSX3("FL5_DESDES")[1])})
	aAdd(aFL5, {'FL5_DESDES',Left(Alltrim(oPedidos[nX]:oWSPassagemAereo:cDestino),TamSX3("FL5_DESDES")[1])})
	
	//Atualiza data final e inicial.
	For nX := 1 To Len(oPedidos)
		
		If dDataIni > StoD(Subs(STRTRAN(oPedidos[nX]:oWSPassagemAereo:cSaida,'-',''),1,8)) .OR. nX == 1
			dDataIni := StoD(Subs(STRTRAN(oPedidos[nX]:oWSPassagemAereo:cSaida,'-',''),1,8))
		EndIf
		If dDataFim < StoD(Subs(STRTRAN(oPedidos[nX]:oWSPassagemAereo:cChegada,'-',''),1,8)) .OR. nX == 1
			dDataFim := StoD(Subs(STRTRAN(oPedidos[nX]:oWSPassagemAereo:cChegada,'-',''),1,8))
		EndIf
	Next		
	
	nX := 1
	aAdd(aFL5, {'FL5_DTINI',dDataIni})
	aAdd(aFL5, {'FL5_DTFIM',dDataFim})		
	
ElseIf	nTipo == 2 //---Hotel.
	aAdd(aFL5, {'FL5_CODORI',oPedidos[nX]:oWSAcomodacao:cCodCidade})
	aAdd(aFL5, {'FL5_DESORI',Left(Alltrim(oPedidos[nX]:oWSAcomodacao:cCidade),TamSX3("FL5_DESORI")[1])})
	aAdd(aFL5, {'FL5_CODDES',oPedidos[nX]:oWSAcomodacao:cCodCidade})
	aAdd(aFL5, {'FL5_DESDES',Left(Alltrim(oPedidos[nX]:oWSAcomodacao:cCidade),TamSX3("FL5_DESDES")[1])})
	aAdd(aFL5, {'FL5_DTINI',StoD(Subs(STRTRAN(oPedidos[nX]:oWSAcomodacao:cCheckin,'-',''),1,8))})
	aAdd(aFL5, {'FL5_DTFIM',StoD(Subs(STRTRAN(oPedidos[nX]:oWSAcomodacao:cCheckout,'-',''),1,8))})
		
ElseIf	nTipo == 3 //--Carro.
	aAdd(aFL5, {'FL5_CODORI',oPedidos[nX]:oWSLocacaoCarro:cCodCidadeRetirada})
	aAdd(aFL5, {'FL5_DESORI',Left(Alltrim(oPedidos[nX]:oWSLocacaoCarro:cCidadeRetirada),TamSX3("FL5_DESORI")[1])})
	aAdd(aFL5, {'FL5_CODDES',oPedidos[nX]:oWSLocacaoCarro:cCodCidadeDevolucao})
	aAdd(aFL5, {'FL5_DESDES',Left(Alltrim(oPedidos[nX]:oWSLocacaoCarro:cCidadeDevolucao),TamSX3("FL5_DESDES")[1])})
	aAdd(aFL5, {'FL5_DTINI',StoD(Subs(STRTRAN(oPedidos[nX]:oWSLocacaoCarro:cDataRetirada,'-',''),1,8))})
	aAdd(aFL5, {'FL5_DTFIM',If(oPedidos[nX]:oWSLocacaoCarro:cDataDevolucao <> '',;
				  StoD(Subs(STRTRAN(oPedidos[nX]:oWSLocacaoCarro:cDataDevolucao,'-',''),1,8)),;
				  StoD(Subs(STRTRAN(oPedidos[nX]:oWSLocacaoCarro:cDataRetirada,'-',''),1,8))),;
				  })
		
ElseIf	nTipo == 5 //--Rodoviario.
	aAdd(aFL5, {'FL5_CODORI',oPedidos[nX]:oWSPassagemRodoviario:cCodOrigem})
	aAdd(aFL5, {'FL5_DESORI',Left(Alltrim(oPedidos[nX]:oWSPassagemRodoviario:cOrigem),TamSX3("FL5_DESORI")[1])})
	aAdd(aFL5, {'FL5_CODDES',oPedidos[nX]:oWSPassagemRodoviario:cCodDestino})
	aAdd(aFL5, {'FL5_DESDES',Left(Alltrim(oPedidos[nX]:oWSPassagemRodoviario:cDestino),TamSX3("FL5_DESDES")[1])})
	aAdd(aFL5, {'FL5_DTINI',StoD(Subs(STRTRAN(oPedidos[nX]:oWSPassagemRodoviario:cSaida,'-',''),1,8))})
	aAdd(aFL5, {'FL5_DTFIM',If(oPedidos[nX]:oWSPassagemRodoviario:cChegada <> '',;
		         StoD(Subs(STRTRAN(oPedidos[nX]:oWSPassagemRodoviario:cChegada,'-',''),1,8)),;
		         StoD(Subs(STRTRAN(oPedidos[nX]:oWSPassagemRodoviario:cSaida,'-',''),1,8))),;
		         })
		
ElseIf	nTipo == 4 //--Seguro.
	aAdd(aFL5, {'FL5_CODORI',oPedidos[nX]:oWSSeguro:cCodCidade})
	aAdd(aFL5, {'FL5_DESORI',,Left(Alltrim(oPedidos[nX]:oWSSeguro:cCidade),TamSX3("FL5_DESORI")[1])})
	aAdd(aFL5, {'FL5_CODDES',oPedidos[nX]:oWSSeguro:cCodCidade})
	aAdd(aFL5, {'FL5_DESDES',Left(Alltrim(oPedidos[nX]:oWSSeguro:cCidade),TamSX3("FL5_DESDES")[1])})
	aAdd(aFL5, {'FL5_DTINI',StoD(Subs(STRTRAN(oPedidos[nX]:oWSSeguro:cInicioValidade,'-',''),1,8))})
	aAdd(aFL5, {'FL5_DTFIM',If(oPedidos[nX]:oWSSeguro:cFimValidade <> '',;
				  StoD(Subs(STRTRAN(oPedidos[nX]:oWSSeguro:cFimValidade,'-',''),1,8)),;
				  StoD(Subs(STRTRAN(oPedidos[nX]:oWSSeguro:cInicioValidade,'-',''),1,8)));
				  })	
	
EndIf
Return 

/*/{Protheus.doc}F661Passag
VerificaÁ„o dos dados do passageiro.
@author William Matos Gundim Junior
@since  16/10/2013
@version 11.90
/*/
Function F661Passag(oPassag, cSessao,cAprov,aNewMat,nTipo)
Local nX := 1
Local nY := 1
Local lRet := .T.
Local oUsers
Local _cEmpAtu := cEmpAnt
Local _cFilAtu := cFilAnt
Local cEmpFat  
Local lTrocaAmbiente := .F.
Local cEmpAux
Local cFilAux 
Local oUsuarios 
Local oPassageiros
Local cLog				:= ''
Local cIdResLoc			:= ''
Local aBKOEmp			:= {}
Local lFN661Pas			:= ExistBlock("FN661Pass")

DEFAULT aNewMat			:= {}

Private lMsErroAuto		:= .F.

For nX := 1 To Len(oPassag)
	If Empty(cLog)
		
		If lFN661Pas
			If ExecBlock( "FN661Pass", .F., .F., { oPassag[nX], cSessao, cAprov, nTipo } )
				Loop
			EndIf
		EndIf
		
		If (Empty(If(nTipo == 2,oPassag[nX]:nIDAutorizador,oPassag[nX]:nID)) .OR. Empty(oPassag[nX]:cNome) ) //----Sem passageiro.
			lRet := .F.
		Else
			DbSelectArea('RD0')
			cIdResLoc := HaIdResRDO( Str(If(nTipo == 2,oPassag[nX]:nIDAutorizador,oPassag[nX]:nID),TamSx3('RD0_IDRESE')[1],0))
			If !Empty(cIdResLoc) //--Encontrou passageiro.
				aAdd(aNewMat,{If(nTipo==2,oPassag[nX]:nIDAutorizador,oPassag[nX]:nID),cIdResLoc})
				lRet := .T.
			Else
				//Pesquisa na reserve e cadastra na RD0.
				WSDLSetProfile(.t.)
				WSDLDbgLevel(2)
				oUsers := WSUsuarios():New() 
				oUsers:OWSCONSULTARRQ:CSESSAO := cSessao
				oUsers:OWSCONSULTARRQ:nQtdeRetorno := 10
				oUsers:OWSCONSULTARRQ:NPAGINA := 1 
				oUsers:OWSCONSULTARRQ:OWSFILTROS := Usuarios_Filtros():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:OWSTIPOPAX := Usuarios_TipoPax():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:OWSTIPOPAX:Value := "0"
				oUsers:OWSCONSULTARRQ:OWSFILTROS:OWSIDSRESERVE := Usuarios_ArrayOfInt():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:OWSIDSRESERVE:nIdReserve := {If(nTipo == 2,oPassag[nX]:nIDAutorizador,oPassag[nX]:nID)}
				oUsers:OWSCONSULTARRQ:OWSFILTROS:OWSTIPOCONSULTAIDENTIFICADOR := Usuarios_TipoIdentificador():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:OWSTIPOCONSULTAIDENTIFICADOR:Value := "0"
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSTipoRequisicao := Usuarios_TipoRequisicao():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSTipoRequisicao:Value := "0"
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSNivelAutorizacao := Usuarios_NivelAutorizacao():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSNivelAutorizacao:Value := "0"
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSServicoTipo      := Usuarios_ServicoTipo():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSServicoTipo:Value := "0"
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSServicoArea      := Usuarios_ServicoArea():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSServicoArea:Value := "0"
				oUsers:OWSCONSULTARRQ:OWSFILTROS:lAtivo := .T.
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSCODEmpresas := Usuarios_ArrayOfString():New()
				oUsers:OWSCONSULTARRQ:OWSFILTROS:oWSCODEmpresas:cCodEmpresa := RetArEmp()
				oUsers:Consultar()

				if oUsers:OWSCONSULTARRESULT:OWSERROS = NIL // Trouxe o Usuario do Reserve.
					// 
					oUser := oUsers:OWSCONSULTARRESULT 
					If Alltrim(oUser:OWSPASSAGEIROS:OWSDADOS[1]:CCODEMPRESA) <> Alltrim(BKO2AGE(_cEmpAtu+_cFilAtu))  // Usuario nao est· da empresa/Filial atual
					   // Trocar de Ambiente                                            
						lTrocaAmbiente := .t.
		  			 	aBKOEmp := BKO2Emp(Alltrim(oUser:OWSPASSAGEIROS:OWSDADOS[1]:CCODEMPRESA))
		  			 	cEmpFat := aBKOEmp[1][1]
						DbSelectArea("SM0")
		 				If SM0->(DbSeek(cEmpFat))
		 					cEmpAux := SM0->M0_CODIGO
		 					cFilAux := SM0->M0_CODFIL 
				 			RPCClearEnv()
							RpcSetType(3)
							RPCSetEnv(cEmpAux, cFilAux,,,"FIN")
						Endif
					Endif
		
		            oUsuarios := oUser:OWSUSUARIOS:OWSDADOS[1]
		            oPassageiros := oUser:OWSPASSAGEIROS:OWSDADOS[1]
					RecLock("RD0", .T.)
					RD0->RD0_FILIAL := xFilial('RD0')
					RD0->RD0_CODIGO := CriaVar("RD0_CODIGO",.T.)
					RD0->RD0_NOME	:= Alltrim(oUsuarios:cNome)
					RD0->RD0_EMAIL  := Alltrim(oUsuarios:cEmail)
					If oUsuarios:oWSTelefone <> Nil
						RD0->RD0_DDD	  := If(oUsuarios:oWSTelefone <> Nil,oUsuarios:oWSTelefone:cCodArea,'')
						RD0->RD0_DDI	  := If(oUsuarios:oWSTelefone <> Nil,oUsuarios:oWSTelefone:cCodPais,'')
						RD0->RD0_FONE   := If(oUsuarios:oWSTelefone <> Nil,oUsuarios:oWSTelefone:cTelefone,'')
					EndIf
					If oUsuarios:oWSUsuario <> Nil 
						RD0->RD0_LOGINR := If(oUsuarios:oWSUsuario <> Nil,oUsuarios:oWSUsuario:cLogin,'')
						RD0->RD0_IDRESE := If(oUsuarios:oWSUsuario <> Nil,Str(oUsuarios:oWSUsuario:nIdReserve,9,0),'')
					EndIf
					If oPassageiros:oWSPassageiro <> Nil
						RD0->RD0_CIC	:= oPassageiros:oWSPassageiro:cCpf
						RD0->RD0_CC     := oPassageiros:oWSPassageiro:cCentroCusto 
						RD0->RD0_NVLCAR := oPassageiros:oWSPassageiro:cNivelCargo
						RD0->RD0_DTNASC := StoD(Subs(STRTRAN(oPassageiros:oWSPassageiro:cDataNascimento ,'-',''),1,8))
					EndIf	
					RD0->RD0_APROPC := cAprov
					RD0->RD0_SEXO   := If(oUsuarios:oWSSexo:VALUE = '1','F','M') 
					RD0->RD0_TIPO   := '1'	
					RD0->RD0_EMPATU := cEmpAnt
					RD0->RD0_FILATU := cFilAnt
					RD0->RD0_RESERV := '1' // N„o exportar at· ser atualizado
					msUnlock()
					ConfirmSX8()	
					
					aAdd(aNewMat,{If(nTipo==2,oPassag[nX]:nIDAutorizador,oPassag[nX]:nID),RD0->RD0_CODIGO})	
					
				Else
					For nY := 1 To Len(oUsers:OWSCONSULTARRESULT:OWSERROS:OWSERRO)	
						
						cLog += oUsers:OWSCONSULTARRESULT:OWSERROS:OWSERRO[nY]:cCodErro  + ' - '
						cLog += oUsers:OWSCONSULTARRESULT:OWSERROS:OWSERRO[nY]:cMensagem 	
					Next		
				endif	
			Endif
		EndIf
	EndIf	 
	
	oUsers := Nil
	
	If lTrocaAmbiente
		RPCClearEnv()
		RpcSetType(3)
		RPCSetEnv(_cEmpAtu,_cFilAtu,,,"FIN")
	Endif
Next	
Return cLog         

//
//-----------------------------------------------------------------
//

Static Function RetArEmp()
Local aRet :={}
Local aArea := GetArea()
           
dbSelectArea("FL2")
dbGoTop()
while !Eof()                
	if !Empty(FL2->FL2_USER)
		Aadd(aRet,Alltrim(FL2->FL2_BKOAGE))
	endif	
	dbSkip()
enddo

RestArea(aArea)

Return aRet

/*/{Protheus.doc}F661BuscaPed
Busca por pedido para n„o importar novamente.
@author William Matos Gundim Junior
@since  11/11/2013
@version 11.90
/*/
Function F661BuscaPed(nPedido)
Local lRet := .T.
Local cQuery := ''
	
	cQuery += 'SELECT FL6_IDRESE FROM ' + RetSqlName("FL6") + " FL6 "
	cQuery += "WHERE FL6_FILIAL = '" + xFilial("FL6") + "'"
	cQuery += "AND FL6_IDRESE = '" + cValToChar(nPedido) + "'" 
	cQuery += "AND D_E_L_E_T_ = ' ' " 
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cFiltro",.T.,.T.)
    dbSelectArea("cFiltro")
  	dbGoTop()
  	If !cFiltro->(Eof()) //Pedido j· existe na base de dados.
  		lRet := .F.	
 	EndIf
 	cFiltro->(DbCloseArea())

Return lRet

Static Function HaIdResRDO(cIDRes)
Local cRet := ""
Local cQuery
Local aArea := GetArea()

cQuery := "SELECT RD0_CODIGO, RD0_IDRESE FROM "
cQuery += RetSqlName("RD0") + " RD0 "
cQuery += " WHERE "                                    
cQuery += "RD0_FILIAL = '"+xFilial("RD0")+"' AND "
cQuery += "RD0_IDRESE = '" + cIDRes + "' AND "
cQuery += "RD0.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
		
dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"__TRB",.F.,.T.)
dbGotop()
If  !__TRB->(Eof())
	cRet := __TRB->RD0_CODIGO
EndIf
			
dbCloseArea()
RestArea(aArea)

Return cRet

/*/{Protheus.doc} FN661Hist
Funcao principal do processo de gravaÁ„o de histÛrico do Pedido de Viagem

@author Totvs
@since 31/08/2013
@version P11 R9

@param cLicenc, caractere, CÛdigo do licenciado no Reserve
@param cPedido, caractere, N˙mero do pedido de viagem
@param cHistorico, caractere, HistÛrico

@return Nil
/*/
Function FN661Hist(cLicenc,cPedido,cHistorico)
Default cLicenc		:= ""
Default cPedido		:= ""
Default cHistorico	:= ""

FwMsgRun(,{|| FN661EnvHi(cLicenc,cPedido,cHistorico)},STR0009,STR0008)//"Integrando com o Sistema Reserve"###"IntegraÁ„o Reserve"

Return

/*/{Protheus.doc} FN661EnvHi
Funcao para envio do historico

@author Totvs
@since 31/08/2013
@version P11 R9

@param cLicenc, caractere, CÛdigo do licenciado no Reserve
@param cPedido, caractere, N˙mero do pedido de viagem
@param cHistorico, caractere, HistÛrico

@return Nil
/*/
Function FN661EnvHi(cLicenc,cPedido,cHistorico)
Local aSaveArea		:= GetArea()
Local cTipoInteg		:= GetMV("MV_RESEXP",.F.,"0")
Local oHist			:= Nil
Local cSessao			:= ""
Local oSvc				:= Nil
Local oAddHist			:= Nil
Local nX				:= 0
Local aErro			:= {}

Default cLicenc		:= ""
Default cPedido		:= ""
Default cHistorico	:= ""

If cTipoInteg != "0" //Desativado.

	If FINXRESOSe(@cSessao,@oSvc,"FLO",cPedido,cLicenc) //Abre sess„o

		oHist := WSPedidos():New() //Cria objeto para envio

		oHist:oWSInserirItemHistoricoRQ:cSessao := cSessao

		oHist:oWSInserirItemHistoricoRQ:oWSItensHistorico := Pedidos_ArrayOfItemHistorico():New()

		oAddHist := Pedidos_ItemHistorico():New()

		oAddHist:nPedido			:= Val(cPedido)
		oAddHist:cObservacoes	:= AllTrim(cHistorico)

		Aadd(oHist:oWSInserirItemHistoricoRQ:oWSItensHistorico:oWSItemHistorico,oAddHist)

		oHist:InserirItemHistorico()

		If ValType(oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS) != "U"

			For nX := 1 To Len(oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS:OWSERRO)
				Aadd(aErro,"CCODERRO: " + oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS:OWSERRO[nX]:CCODERRO)
				Aadd(aErro,"CMENSAGEM: "+ oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM	)
			Next nX

			FINXRESLog("FLO",STR0010,cPedido,aErro) //Gera log de erro //"Inclus„o"

			FN661GrvHi(cLicenc,cPedido,cHistorico) //Grava na tabela para exportacao off-line

		EndIf

		FINXRESCSe(@cSessao,@oSvc) //Encerra sess„o

	Else
		FN661GrvHi(cLicenc,cPedido,cHistorico) //Grava na tabela para exportacao off-line
	EndIf

Else
	FN661GrvHi(cLicenc,cPedido,cHistorico) //Grava na tabela para exportacao off-line
EndIf

RestArea(aSaveArea)

Return

/*/{Protheus.doc} FN661GrvHi
Gravacao do historico para atualizacao off-line (FLO)

@author Totvs
@since 31/08/2013
@version P11 R9

@param cLicenc, caractere, CÛdigo do licenciado no Reserve
@param cPedido, caractere, N˙mero do pedido de viagem
@param cHistorico, caractere, HistÛrico

@return Nil
/*/
Function FN661GrvHi(cLicenc,cPedido,cHistorico)
Local	cCodigo		:= GetSXENum("FLO","FLO_CODIGO")
Local	cFilFLO		:= xFilial('FLO')
Default cLicenc		:= ""
Default cPedido		:= ""
Default cHistorico	:= ""

If F661FLOCod(cCodigo, cFilFLO)
	While .T.
	cCodigo := GetSXENum("FLO","FLO_CODIGO")
		If !F661FLOCod(cCodigo, cFilFLO)
			Exit
		EndIf
	EndDo
EndIf

RecLock("FLO",.T.)
FLO->FLO_FILIAL	:= XFilial("FLO")
FLO->FLO_CODIGO	:= cCodigo
FLO->FLO_LICENC	:= cLicenc
FLO->FLO_IDPED	:= cPedido
FLO->FLO_HISTOR	:= cHistorico
FLO->(MsUnlock())

FLO->(ConfirmSX8())

Return

/*/{Protheus.doc} FN661RHist
Processamentos via Schedule dos histÛricos gravados na tabela FLO

@author Totvs
@since 31/08/2013
@version P11 R9

@return Nil
/*/
Function FN661RHist()
Local cTipoInteg	:= SuperGetMV("MV_RESEXP",.F.,"0")
Local cAliasFLO	:= ""
Local nX			:= 0
Local cSessao		:= ""
Local oSvc			:= Nil

If cTipoInteg $ "2|3"

	If FN661QryHi(@cAliasFLO)

		If FINXRESOSe(@cSessao,@oSvc,"FLO",(cAliasFLO)->FLO_IDPED,(cAliasFLO)->FLO_LICENC) //Abre sess„o

			oHist := WSPedidos():New() //Cria objeto para envio

			While (cAliasFLO)->(!Eof())

				oHist:oWSInserirItemHistoricoRQ:cSessao := cSessao

				oHist:oWSInserirItemHistoricoRQ:oWSItensHistorico := Pedidos_ArrayOfItemHistorico():New()

				oAddHist := Pedidos_ItemHistorico():New()

				oAddHist:nPedido			:= Val((cAliasFLO)->FLO_IDPED)
				oAddHist:cObservacoes	:= AllTrim((cAliasFLO)->FLO_HISTOR)

				Aadd(oHist:oWSInserirItemHistoricoRQ:oWSItensHistorico:oWSItemHistorico,oAddHist)

				oHist:InserirItemHistorico()

				If ValType(oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS) != "U"

					For nX := 1 To Len(oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS:OWSERRO)
						Aadd(aErro,"CCODERRO: " + oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS:OWSERRO[nX]:CCODERRO)
						Aadd(aErro,"CMENSAGEM: "+ oHist:OWSINSERIRITEMHISTORICORESULT:OWSERROS:OWSERRO[nX]:CMENSAGEM	)
					Next nX

					FINXRESLog("FLO",STR0010,cPedido,aErro) //Gera log de erro //"Inclus„o"

				Else
					FLO->(DBGoTo((cAliasFLO)->R_E_C_N_O_))
					RecLock("FLO",.F.)
					FLO->(DbDelete())
				EndIf
				
			(cAliasFLO)->(DbSkip())
			EndDo

			FINXRESCSe(@cSessao,@oSvc) //Encerra sess„o

		EndIf

	EndIf

	If !Empty(cAliasFLO) .And. Select(cAliasFLO) > 0
		(cAliasFLO)->(DbCloseArea())
	EndIf

EndIf

Return

/*/{Protheus.doc} FN661QryHi
Executa query para obtenÁ„o dos Historicos pendentes de sincronizaÁ„o no Sistema Reserve.

@author Totvs
@since 23/10/2013
@version P11 R9

@param cAliasFLO, caractere, Alias da tabela tempor·ria

@return lÛgico,Indica se a tabela possui dados
/*/
Function FN661QryHi(cAliasFLO)
Local lRet := .T.

cAliasFLO := GetNextAlias()

BeginSQL Alias cAliasFLO
SELECT	FLO.FLO_LICENC,FLO.FLO_IDPED,FLO.FLO_HISTOR,FLO.R_E_C_N_O_
FROM	%Table:FLO% FLO
WHERE	FLO.FLO_FILIAL = %XFilial:FLO%
		AND FLO.%NotDel%
ORDER BY FLO.FLO_CODIGO
EndSQL

lRet := (cAliasFLO)->(!Eof())

Return lRet

/*/{Protheus.doc} F661FLOCod
Executa query para obtenÁ„o dos Historicos pendentes de sincronizaÁ„o no Sistema Reserve.

@author Pedro Pereira Lima
@since 22/11/2016
@version P12.1.7

@param cNumero
@param cFilFLO

@return lExist
/*/
Function F661FLOCod(cNumero,cFilFLO)
Local lExist	:= .F.
Local cTmpFile	:= GetNextAlias()

If Select(cTmpFile) > 0
	(cTmpFile)->(DbCloseArea())
EndIf

BeginSql Alias cTmpFile
	SELECT FLO_CODIGO FROM %Table:FLO% FLO
	WHERE FLO.FLO_FILIAL = %Exp:cFilFLO% AND
	FLO.FLO_CODIGO = %Exp:cNumero% AND FLO.%NotDel%
EndSql

If !(cTmpFile)->(Eof())
	lExist := .T.
	ConfirmSX8()
EndIf

If Select(cTmpFile) > 0
	(cTmpFile)->(DbCloseArea())
EndIf

Return lExist
