#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RMIMONITOR.CH"

#DEFINE ORCAMENTO			"1"					//Orcamento
#DEFINE CUPNAOFISCAL		"2"					//Cupom nao fiscal
#DEFINE CUPOMFISCAL			"3"					//Cupom fiscal
#DEFINE ENTREGANAOFISCAL	"4"					//Cupom nao fiscal de entrega	-	Gravabat gera pedido de venda para rotina de importacao de NFS gerar na nota em cima desse pedido.
#DEFINE AUTOSERVICO			"5"					//Auto Servico - Cupom direto

#DEFINE EXCLUI_REPROCESSA	"4"					//Exclusao para reprocessamento, alterado para diferenciar que vai ser um reprocessamento

Static cSisOri   := ""
Static lDePara   := ExistFunc('RmiPsqDePa') //Verifica se existe a funcao para realizar o DePara
Static cChaveSL1 := ""                      //Guarda o conteudo do campo L1_UMOV
Static cUUIDSL1  := ""                      //Guarda o conteudo do campo L1_UMOV
Static cProcesso := ""						//Guarda o processo da venda

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIRetailJ
Integracao Legado X PROTHEUS Importacao de Arquivos do Orcamento SL1 SL2 SL4
@param cQuery, nRecIni, nRecFim, cStaimp

@return Vazio
@Obs	INTM210 para RMIRetailJ
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIRetailJ(cQuery, nRecIni, nRecFim, cStaimp)

Local lMultThread	:= .F.						//Define se importacao sera processada via Multi Thread
Local dDataI
Local dDataF
Local cHoraI
Local cHoraF
Local lJob 		:= IsBlind()
//Variaveis Private da Funcao
Private aSL1		:= {}						//Cabecalho do orcamento
Private aSL2 		:= {}						//Itens do orcamento
Private aSL4 		:= {} 						//Parcelas do pagamento
Private aInfoLog1	:= {}						//Informacoes necessario para a gravacao do Log
Private aInfoLog2	:= {}						//Informacoes necessario para a gravacao do Log
Private lAppend		:= .F.							//Variavel indica se vai gravar novo registro(.T.) ou replace (.F.)
Private cErro		:= ""						//Mensagem de erro					
                                                                
Default nRecIni	 	:= 0
Default nRecFim		:= 0    
Default cStaimp		:= "' ', '4'"
Default cQuery 		:=	"SELECT SL1.*,SL1.R_E_C_N_O_ as REGISTRO FROM " + RetSQLName("SL1") + " SL1"+;
						" WHERE SL1.L1_SITUA = 'IP' AND D_E_L_E_T_ = ' ' " //L1_SITUA = 'IP' Aguardando processamento


lMultThread := (nRecIni <> 0 .AND. nRecFim <> 0)

//Caso esteja executando pelo menu, filtra somente registros da propria filial
If !lJob .And. SuperGetMV("IN_210FFIL",,.T.)
	cQuery += " AND (L1_FILIAL = '" + cFilAnt + "')"
EndIf

If lMultThread
	cQuery += " AND (SL1.R_E_C_N_O_ >= " + cValToChar(nRecIni) + " AND SL1.R_E_C_N_O_ <= " + cValToChar(nRecFim) + ") "
	cQuery += " ORDER BY SL1.R_E_C_N_O_"
Else
	cQuery += " ORDER BY SL1.L1_FILIAL, SL1.L1_NUM "
EndIf
                            
dDataI := Date()
cHoraI := Time()

DbSelectArea("SL1")
If !lJob
	Processa({|lEnd|ValidSL1(cQuery, lMultThread,cStaimp,lJob)})
Else
	ValidSL1(cQuery, lMultThread,cStaimp,lJob)
Endif	
            
dDataF := Date()
cHoraF := Time()

ConOut("Registros processados data inicial " + DtoC(dDataI) + " hora inicio " + cHoraI + " data final " + DtoC(dDataF) + " hora fim " + cHoraF )
LjGrvLog("RMIRetailJ","Registros processados data inicial " + DtoC(dDataI) + " hora inicio " + cHoraI + " data final " + DtoC(dDataF) + " hora fim " + cHoraF )

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidSL1
Gera arquivo temporario TMPSL1 atraves do arquivo Legado importado 
atraves do comando Append
@param cQuery, lMultThread,cStaimp,lJob

@return Vazio
@Obs	ValidSL1 para ValidSL1
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidSL1(cQuery, lMultThread,cStaimp,lJob)

Local nRecSL1		:= 	0			//nRecSL1 Numero do Registro atual da tabela PIN
Local aSL1Vazio		:= {}			//Relacao de campos que nao podem estar vazios
Local cCliente		:= ""			//Codigo do Cliente
Local cLoja   		:= ""			//Loja do Cliente
Local cTipoCli		:= ""			//Tipo do Cliente
Local cVendedor		:= ""			//Codigo do Vendedor
Local nMoedaCor		:= 1 	     	//Moeda da venda
Local cOperador		:= ""			//Operador
Local cSituacao		:= ""			//Situacao do orcametno
Local nVlrTot		:= 0			//Valor Total do Orcamento
Local nCasaDecimal	:= TamSX3("L1_VLRTOT")[2]//Quantidade de digitos para a casa decimal
Local cSerie		:= ""			//Serie do PDV
Local cEstacao		:= ""			//Codigo da Estacao
Local cTipoOrc		:= ""			//Tipo do Orcamento
Local aAux			:= {}			//Pega o retorno da funcao ValCampo
Local lErro 		:= .F.	         
Local lContinua		:= .T.
Local cXTPREG		:= ""
Local cDOCPED		:= ""   
Local lSemReserva	:= .F.			//Define se Cupom Fiscal teve reserva
Local lHistorico	:= .F.
Local lExistSL1		:= .F.			//Verifica se existe cabecalho
Local cLjCodigo		:= ""			//Codigo da Loja na Tabela SLJ
Local l210INOK    	:= ExistBlock("I210INCOK")  // PE para validaï¿½ï¿½o do usu?io na inclus?
Local l210CLIOK    	:= ExistBlock("I210CLIOK")  // PE para mudan?/validacao do cliente na inclusao da venda.
Local cVendPad		:= Alltrim(SuperGetMV( "MV_VENDPAD"  ,.F.,"" ))
Local cMens, lRet, cChaveSA1, nOrdem
Local lRet210I      := .T.
Local nLidos       	:= 0
Local nProcessados 	:= 0 
Local nItemPrc     	:= 0
Local lSAT			:= .F.
Local lNFCe			:= .F.
Local lImpFis		:= .F.
Local cEspecie		:= ""
Local _aL1Mat
Local nPos          := 0
Local nTamSA1		:= len(Alltrim(xFilial("SA1")) )
Local aCodCli		:= ""       //Codigo do cliente da venda
Local L2VEND		:= ""

Private lAtuSitua 	:= .F.      //Indica se atualiza o L1_SITUA - Por causa do GravaBat

DbSelectArea("SL4")
DbSelectArea("SL2") //PIO
DbSelectArea("SL1") //PIN Tabela clone da SL1

//-------------------------
//Fechas Alias Temporarios
//-------------------------
FechaAlias(.T.)

//Executa a query		
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSL1", .T., .F. )
TcSetField("TMPSL1", "L1_EMISSAO", "D")

If !lJob
	ProcRegua(TMPSL1->(RecCount()))
Endif

While TMPSL1->( !EOF() )
	
    If !lJob
		IncProc()
    Endif

	//Limpa Variaveis  
	lAppend	    := .F.
	cErro		:= ""    
	lErro 		:= .F.	
	aInfoLog1	:= {}  
	aInfoLog2	:= {}
	aSL1		:= {}
	aSL2		:= {}                            
	aSL4		:= {}
	aSL1Vazio	:= {}               
	cDOCPED 	:= "" 
	cLjCodigo	:= ""
	lContinua 	:= .T.  
	lSemReserva	:= .F.
	lHistorico	:= .F.
	lExistSL1 	:= .F.
	lAtuSitua 	:= .F.
	cEstacao 	:= ""
	cSerie   	:= ""
	lSAT		:= .F.
	lNFCe		:= .F.
	lImpFis	:= .F.
	cEspecie	:= ""
	
    nLidos     ++
    	
	//Carrega informacoes para gravacao de Log
	nRecSL1   := TMPSL1->REGISTRO
	cChaveSL1 := TMPSL1->L1_FILIAL+"|"+TMPSL1->L1_NUM
	cUUIDSL1  := TMPSL1->L1_UMOV
    cSisOri   := ""
	
    aAux := RmiXSql("SELECT MHQ_ORIGEM, MHQ_CPROCE FROM " + RetSqlName("MHQ") + " WHERE D_E_L_E_T_ = ' ' AND MHQ_UUID = '" + PadR(cUUIDSL1, TamSx3("MHQ_UUID")[1]) + "'", "*", /*lCommit*/, /*aReplace*/)
    If Len(aAux) > 0
        cSisOri		:= aAux[1][1]
        cProcesso   := aAux[1][2]
    EndIf

	Aadd(aInfoLog1, "SL1"	)
	Aadd(aInfoLog1, nRecSL1)      

	//Verifica se o Registro ja foi processado, tratamento para Multi Thread.
	If lMultThread
		SL1->(DbGoTo(nRecSL1))
		//!Empty(PIN->PIN_STAIMP) .AND. PIN->PIN_STAIMP <> "4"
		If SL1->L1_SITUA <> "IP"
			//Passa ao proximo registro
			TMPSL1->(DbSkip())
			Loop
		Else
			If !SL1->L1_ORIGEM == 'N' 	
				AtuaOrigem(nRecSL1)
			EndIf
		EndIf
	Else
		If !SL1->L1_ORIGEM == 'N' 	
			AtuaOrigem(nRecSL1)
		EndIf
	EndIf
	
	//Fechas Alias Temporarios.
	FechaAlias()
	
	RmiFilInt( TMPSL1->L1_FILIAL, .T., TMPSL1->L1_CGCCLI)

	//Carrega Variaveis de Controle.
	cTipoOrc	:= AllTrim( TMPSL1->L1_TIPO 	)
        
	//Para integração RMI o Campo L1_ORIGEM deve estar igual a 'N'
	//Posiciona na SL1.
	SL1->(dbGoTo(TMPSL1->REGISTRO))

	//Valida se Doc e Serie já existe na Filial.
	If cProcesso <> "PEDIDO" .AND. VldSL1Dup(SL1->L1_FILIAL,SL1->L1_DOC,SL1->L1_SERIE)
		cErro := STR0129 + " - "+SL1->L1_DOC + " - " + SL1->L1_SERIE
		RMIGRVLOG("IR", "SL1" , nRecSL1, "STR0129" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)//[DUPL] Identificado um registro com o mesmo Documento/Serie: 
		cErro := ""
		lErro := .T.
	EndIf
	
	//Valida o preenchimento dos campos obrigatorios da SL1
	If cProcesso <> "PEDIDO"
		lErro := RmiValidCa(nRecSL1)
	EndIf

	//Trava o Log dos campos obrigatorios. ? 
	If lErro
		TMPSL1->(DbSkip())
		Loop      
	EndIf
	
	//Valida o Cliente. ?
	//Caso o tipo de Registro seja 5 pegar o cliente padrão? DAC 09/01/2015
	If l210CLIOK
		If U_I210CLIOK(@cChaveSA1,@nOrdem,nRecSL1)
			If ValType(cChaveSA1) <> "C" .Or. ValType(nOrdem) <> "N" .Or. Empty(cChaveSA1) .Or. nOrdem <= 0
				lErro := .T.
				RMIGRVLOG("IR", "SL1" , nRecSL1, "STR0021" , "Retorno do PE I210CLIOK incorreto",,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
			EndIf
		Else
			lErro := .T.
			RMIGRVLOG("IR", "SL1" , nRecSL1, "STR0021" , "Retorno do PE I210CLIOK sem cliente informado",,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
		EndIf
	Else
		If !Empty(TMPSL1->L1_CLIENTE)//PIN_CLIENT
		  	cChaveSA1 := SUBSTR(TMPSL1->L1_FILIAL,1,nTamSA1) + SPACE (TamSX3("A1_FILIAL")[1] - nTamSA1) + TMPSL1->L1_CLIENTE + TMPSL1->L1_LOJA //TMPSL1->PIN_CLIENT + TMPSL1->PIN_LOJA
		  	nOrdem := 1
		ElseIf !Empty(TMPSL1->L1_CGCCLI) //PIN_XCPFC
		  	cChaveSA1 := SUBSTR(TMPSL1->L1_FILIAL,1,nTamSA1) + SPACE (TamSX3("A1_FILIAL")[1] - nTamSA1) + TMPSL1->L1_CGCCLI
		  	nOrdem := 3
		Else
			lErro := .T.
			RMIGRVLOG("IR", "SL1", nRecSL1, STR0021,"N? Informado CPF no Cupom e n? preenchido parametro MV_CLIPAD",,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)// Validacao usuario PE l210INCOK
		EndIf
	EndIf

	//Valida o Vendedor.
	lRet := .T.         
		
    //Ponto de Entrada para validacao do registro
	If l210INOK
		lRet210I := ExecBlock("I210INCOK",.F.,.F., { nRecSL1 } )
		If Valtype(lRet210I) <> "L"
			lRet210I := .T.
		EndIf
		
		If !lRet210I
			lRet := .F.
			RMIGRVLOG("IR", "SL1", nRecSL1, "STR210I","STR210I",,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
		Endif
	EndIf

	//Acrescentado validaï¿½ï¿½o conforme solicitaï¿½ï¿½o Gendra 21/08/2014 esta validaï¿½ï¿½oser?utilizada emv?ias empresas
	Begin Sequence
		
		//Valida a Data Fiscal?
        _cDataFis := DtoS(SuperGetMV( "MV_DATAFIS",,.F.,SL1->L1_FILIAL))
        If DtoS(TMPSL1->L1_EMISSAO) <= _cDataFis
            cMens := "Data do Cupom Fiscal (L1_EMISSAO) "+DtoC(TMPSL1->L1_EMISSAO)+" menor/igual que Data de Fechamento (MV_DATAFIS) "+Subs(_cDataFis,7,2)+"/"+Subs(_cDataFis,5,2)+"/"+Subs(_cDataFis,3,2)
            RMIGRVLOG("IR", "SL1", nRecSL1, "STR0200",cMens,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
            lRet := .F.
        Endif

    End Sequence

	//passar referencia para erro
	If !lRet
		lErro	:= .T.	
	Endif
	
	//Verifica se tem erro no regsitro corrente. ?
	If !Empty(cErro) .OR. 	lErro
		TMPSL1->(DbSkip())
		Loop      
	EndIf	
	
	//Carega array com as informacoes do cabecario. ?
	If cProcesso <> "PEDIDO"
		nVlrTot := Round( TMPSL1->L1_VLRTOT, nCasaDecimal )
	Else
		nVlrTot := Round( TMPSL1->L1_VLRLIQ, nCasaDecimal )
	EndIf

 	//Caso o mesmo venha vazio utilizar a data do cupom
	If Empty(TMPSL1->L1_DTLIM)  //Caso esteja vazio utilizar data do Cupom
		_dDtLim := TMPSL1->L1_EMISNF 
	Else
		_dDtLim := TMPSL1->L1_DTLIM 
	Endif
	
	If SL1->(FieldPos('L1_VEND')) > 0  
		L2VEND := Posicione("SL2", 1, TMPSL1->L1_FILIAL + TMPSL1->L1_NUM,"L2_VEND")
		//No Live se o vendedor for preenchido na SL2 considera o mesmo para SL1
		If !Empty(L2VEND) 
			cVendedor := L2VEND
		Else
			cVendedor := IIF(Empty(TMPSL1->L1_VEND),cVendPad,TMPSL1->L1_VEND)
		EndIf	
	Else
		cVendedor := cVendPad 
	EndIf
		
	Aadd( aSL1, {"L1_VEND"   	, cVendedor				} )
	Aadd( aSL1, {"L1_NUMCFIS"	, TMPSL1->L1_DOC		} )
	Aadd( aSL1, {"L1_EMISNF" 	, TMPSL1->L1_EMISSAO	} )
	Aadd( aSL1, {"L1_DTLIM"  	,IIF(Empty(TMPSL1->L1_DTLIM),_dDtLim,TMPSL1->L1_DTLIM)	} )

	If lDePara
		cOperador := RmiPsqDePa(cSisOri, "SA6", "A6_COD", IIF(Empty(TMPSL1->L1_OPERADO),cOperador,TMPSL1->L1_OPERADO), 1, xFilial("SA6")+IIF(Empty(TMPSL1->L1_OPERADO),cOperador,TMPSL1->L1_OPERADO))
		If Empty(cOperador)
			RmiGrvLog("IR"	, "SL1"	, nRecSL1 , "STR1003" , STR1003,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1) //"O operador do R_E_C_N_O_ informado, não existe na tabela SA6 (Bancos) e também no cadastro de De/para (MHM)"
			lErro := .T.
		Else
			Aadd( aSL1, {"L1_OPERADO"	, cOperador} )
		EndIf			
	EndIf

	If lDePara
		aCodCli := RmiPsqDePa(cSisOri, "SA1", "A1_COD", IIF(Empty(TMPSL1->L1_CLIENTE),cCliente,TMPSL1->L1_CLIENTE), 1, xFilial("SA1")+IIF(Empty(TMPSL1->L1_CLIENTE),cCliente,TMPSL1->L1_CLIENTE)+IIF(Empty(TMPSL1->L1_LOJA), cLoja,TMPSL1->L1_LOJA))
		If Len(aCodCli) < 2
			RmiGrvLog("IR"	, "SL1"	, nRecSL1 , "STR1002" , STR1002,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1) //"O cliente do R_E_C_N_O_ informado, não existe na tabela SA1 (Clientes) e também no cadastro de De/para (MHM)"			
			lErro := .T.
		Else
			Aadd( aSL1, {"L1_CLIENTE"	, aCodCli[1]} )
			Aadd( aSL1, {"L1_LOJA"   	, aCodCli[2]} )
		EndIf			
	EndIf

	Aadd( aSL1, {"L1_TIPOCLI"	, IIF(Empty(TMPSL1->L1_TIPOCLI), cTipoCli,TMPSL1->L1_TIPOCLI)} )
	Aadd( aSL1, {"L1_DINHEIR"	, 0	                    } )
	Aadd( aSL1, {"L1_CHEQUES"	, 0	                    } )
	Aadd( aSL1, {"L1_CARTAO" 	, 0	                    } )
	Aadd( aSL1, {"L1_CONVENI"	, 0	                    } )
	Aadd( aSL1, {"L1_VALES"  	, 0		                } )
	Aadd( aSL1, {"L1_FINANC" 	, 0	                    } )	
	Aadd( aSL1, {"L1_VLRDEBI"	, 0	                    } )
	Aadd( aSL1, {"L1_OUTROS" 	, 0	                    } )
	Aadd( aSL1, {"L1_ENTRADA"	, 0	                    } )
	Aadd( aSL1, {"L1_MOEDA"	    , IIF(Empty(TMPSL1->L1_MOEDA),nMoedaCor,TMPSL1->L1_MOEDA)} )
	Aadd( aSL1, {"L1_FORMPG"    , ""                    } )
    
	cSerie := TMPSL1->L1_SERIE

   	//Ponto de Entrada criado para retornar Campo e conte?o para execuï¿½ï¿½o no Execauto, somente duas posiï¿½ï¿½es por Array DAC 17/01/2017
	If ExistBlock("IN210AL1")
		SL1->(DbGoto(nRecSL1))  //Garanto posicionamento na tabela da Camada de Integraï¿½ï¿½o 
		_aL1Mat := {}
   		_aL1Mat := ExecBlock("IN210AL1",.F.,.F., { nRecSL1 })
   		If ValType(_aL1Mat) == "A" .and. Len(_aL1Mat) > 0
			For nPos := 1 To Len(_aL1Mat) 
				If Len(_aL1Mat[nPos]) <> 2   //somente duas posuï¿½ï¿½es nome do campo e conteudo     
					lErro 	:= .T.	
					cErro 	:= STR0124   //"Erro no retorno do Ponto de Entrada IN210AL1, retornar Array com 2 Posiï¿½ï¿½es [nome do campo | conteudo do campo] "
					RMIGRVLOG("IR", "SL1", nRecSL1, "STR0124", "STR0124",,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
					Exit
				EndIf
				//Verificar se o campo esta incluindo na matriz principal caso esteja o mesmo ser?alterado conforme o retorno do P,E.            
				nPosCpo := Ascan( aSL1, { |x| AllTrim(x[1]) == AllTrim(_aL1Mat[nPos,1]) } )
				If nPosCpo > 0
					aSL1[nPosCpo,2]	:= _aL1Mat[nPos,2]
				Else 
					Aadd(aSL1 ,{	AllTrim(_aL1Mat[nPos,1]),;  	//Nome do Campo
									_aL1Mat[nPos,2],; 				//Conte?o do Campo
									Nil})      	
				Endif					
			Next nPos
      	EndIf
	EndIf

	If !Empty(cErro) .OR. 	lErro
		TMPSL1->(DbSkip())
		Loop      
	EndIf	

	//Gera Itens SL2
 	ValidSL2(	SL1->L1_FILIAL	,TMPSL1->L1_NUM , TMPSL1->L1_PDV	, TMPSL1->L1_DOC    ,;
				cSerie          , nRecSL1       , aCodCli[1]	    , aCodCli[2]        ,;
				cVendedor		, cSituacao		, nVlrTot			, TMPSL1->L1_DOCPED	,;
				cXTPREG			, cDOCPED		, lSemReserva		, ""                ,;
				TMPSL1->L1_SITUA, lHistorico 	, cLjCodigo         , ""	            )

	If Len(aSL2) > 0
	    nProcessados ++  	
		nItemPrc     += Len(aSL2)
	Endif		
	
	TMPSL1->( DbSkip() )
End

LjGrvLog( "RmiRetailJob", "Termino do processamento das validações de venda - SmartConnector: [Vendas Lidas, Vendas Processadas, Itens Processados]", {nLidos, nProcessados, nItemPrc} )

TMPSL1->( DbCloseArea() )

//Restaura a Empresa e Filial
RmiFilInt(cFilAnt, .F.)

Return(Nil)      

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidSL2
Gera arquivo temporario TMPSL2 atraves do arquivo Legado 
@param 
@return Vazio
@Obs	ValidSL2 para ValidSL2
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidSL2(	cFilSL1	    , cNum		, cPdv			, cDoc			,;
							cSerie      , nRecSL1	, _cCliente		, _cLoja		,;
							cVendedor	, cSituacao	, nVlrTotL1		, cDocPed		,;
							cXTPREG	    , cDOCPED 	, lSemReserva	, cXTPREGOld	,;
							cAcao		, lHistorico, cLjCodigo     , cCNPJ		)

Local cQuery        := ""
Local nVlTotItem	:= 0									//Valor total dos itens L2_VLRITEM
Local nTolerancia   := SuperGetMv("IN_TOLPIO"	,, 0.05)	//Valor de tolerancia
Local nDiferenca	:= 0													//Diferenca do total da L1 para L2
Local nCasaDecimal	:= TamSX3("L1_VLRTOT")[2] 								//Quantidade de digitos para a casa decimal
Local aSL2Vazio	:= {}													    //Relacao de campos que nao podem estar vazios
Local nTamIt	 	:= TamSx3("L2_ITEM")[1]
Local cItem		 	:= Repl("0", nTamIt)
Local aAuxSL2		:= {}													//Contem o Item do orcamento
Local cProduto		:= ""													//Codigo do produto
Local cTES			:= ""													//Retorno via tabela PJA Tes
Local cTesPed 		:= ""													//Tes que sera gerado o Pedido de Venda F4_XTESPED
Local cCF			:= ""													//Retorno via tabela PJA Classificacao Fiscal
Local cSitTri		:= ""													//Retorno via tabela PJA Situacao Tributaria
Local cConta		:= ""
Local aPIORecnos	:= {}													//Recnos dos registros da tabela PIO
Local lErro 		:= .F.
Local lRet			:= .T.
Local cLocal 		:= ""  
Local cUnidade		:= ""													//Unidade de medida do produto
Local cGrpTrib		:= ""													//Grupo Tributario do Produto
Local nI			:= 0
Local cVendItem		:= ""			//Codigo do Vendedor por Item  
Local cTpOper		:= IIF(ExistFunc("LjOpTESInt"),LjOpTESInt(Nil,SuperGetMV("MV_LJOPTES",,"01")),"01")//Tipo de Operacao padrao
Local nPosCpo
Local _aL2Mat                           
Local nPos
Local cCodProd		:= "" //Codigo do produto a ser gravado na SL2
Local lD2FECP		:= SD2->(ColumnPos( "D2_ALQFECP" )) > 0 .And. SD2->(ColumnPos( "D2_VALFECP" )) > 0 // Verifica se campo existe
Local lL2FECP		:= SL2->(ColumnPos( "L2_ALQFECP" )) > 0 .And. SL2->(ColumnPos( "L2_VALFECP" )) > 0 // Verifica se campo existe
Local nValIcmsL1    := 0
Local nValFecpL1    := 0

LjGrvLog(" RmiRetailJob ", "Conteudo do parametro MV_LJOPTES", cTpOper)
If Empty(cTpOper)
	cTpOper := "01"
	LjGrvLog(" RmiRetailJob ", "O conteudo do parametro MV_LJOPTES e vazio, com isso foi atribuido o valor padrao 01")    
EndIf

//filtrar apenas por Filial e cNUm
cQuery := "SELECT SL2.*, SL2.R_E_C_N_O_ as REGISTRO FROM " + RetSQLName("SL2") + " SL2 "
cQuery += " WHERE 	SL2.L2_FILIAL 	= '" + cFilSL1 		+ "' 	AND "
cQuery += " 	 	SL2.L2_NUM 		= '" + cNum			+ "' 	AND "
cQuery += " 		SL2.D_E_L_E_T_  <> '*'"
cQuery += "ORDER BY SL2.L2_FILIAL, SL2.L2_ITEM"

//Execulta a query
cQuery := ChangeQuery( cQuery )
DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), "TMPSL2", .T., .F. )

Aadd(aSL2Vazio, "L2_FILIAL"	)
Aadd(aSL2Vazio, "L2_NUM"    )
Aadd(aSL2Vazio, "L2_ITEM"   )

//Verifica se nao eh orcamento para adicionar outros campos para validacao.
If !Empty(cSituacao)
	Aadd(aSL2Vazio, "L2_PDV"	)    
EndIf	

//Verifica se encontrou os Itens
If TMPSL2->(Eof())
	cErro := STR0064		//"Nao foram encontrados itens para o or?mento - PIO (Itens do cupom fiscal)."
	RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0064" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
Else            

	While !TMPSL2->( Eof() )

		//Limpa variaveis
		cProduto 	:= ""
		cDescricao 	:= ""
		cUnidade 	:= ""
		cTES 		:= ""
		cTesPed		:= ""
		cCF	 		:= ""
		cSitTri		:= ""
		cLocal		:= ""
		cGrpTrib	:= ""
		cConta		:= ""
		cErro		:= ""
		lErro 		:= .F.
		
		aInfoLog2	:= {}  		
	 	lRet		:= .T.
	 	
		//Carrega informacoes para gravacao de Log
		Aadd(aInfoLog2	, "SL2"					)
		Aadd(aInfoLog2	, TMPSL2->R_E_C_N_O_	)
		Aadd( aPIORecnos, TMPSL2->R_E_C_N_O_	)
		
		//Grava Filial e Posiciona a PIO
		
		//Analisa se campos obrigatorios estao em vazios.
		For nI:= 1 to Len(aSL2Vazio)
			If Empty( &("TMPSL2->"+aSL2Vazio[nI]))
				cErro += STR0002 + " " + aSL2Vazio[nI] //+ ENTER
			EndIf
		Next nI
		
		//Grava o Log dos campos obrigatorios.
		If !Empty(cErro)
			aSL2 := {}
			RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0002" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
			Return(Nil) 
		EndIf
		
		//Valida Quantidade.
		If TMPSL2->L2_QUANT <= 0
			lErro 	:= .T.	
			cErro 	:= STR0038 + " " + cValToChar(TMPSL2->L2_QUANT)
			RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0038" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
		EndIf
				
		cSitTri	:= TMPSL2->L2_SITTRIB

		//Valida o Vendedor. ?
		//Retirado não vai utilizar pedido -> Valida a Tes de Pedido se for uma Entrega nao Fiscal, para gerar o Pedido corretamente pelo GRAVABAT. ?
		cItem := Soma1(cItem, nTamIt)

		//Verifica se tem erro no regsitro corrente. ?
		If !Empty(cErro) .OR. lErro
			aSL2 := {}
			Return(Nil)
		EndIf	       

		//Carrega array com as informacoes do item. ?
		aAuxSL2 := {}

		Aadd( aAuxSL2, {"L2_PDV", IIF(Empty(TMPSL2->L2_PDV),cPdv,TMPSL2->L2_PDV)} )

		If lDePara
			cCodProd := RmiPsqDePa(cSisOri, "SB1", "B1_COD", IIF(Empty(TMPSL2->L2_PRODUTO),cProduto,TMPSL2->L2_PRODUTO), 1, xFilial("SB1")+IIF(Empty(TMPSL2->L2_PRODUTO),cProduto,TMPSL2->L2_PRODUTO))
			If Empty(cCodProd)
				RmiGrvLog("IR"	, "SL1"	, nRecSL1 , "STR1000" , STR1000,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1) //"O produto do R_E_C_N_O_ informado, não existe na tabela SB1 (Produtos) e também no cadastro de De/para (MHM)."
				Return(Nil)
			Else
				Aadd( aAuxSL2, {"L2_PRODUTO"	, cCodProd} )
			EndIf			
		EndIf

		//Busca a TES - Inicio
		cTES := LjRetTes(cTpOper, _cCliente, _cLoja, cCodProd)

		If Empty(cTES)
			lRet := .F.
		EndIf

		If lRet

			If !SF4->( DbSeek(xFilial("SF4") + cTES ) )
				lErro 	:= .T.	
				cErro 	:= STR0007 + cTES                                             		
				RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0007" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
				Return(Nil)
			Else

				If Empty(cCF)
					cCF	:= SF4->F4_CF
				EndIf
			EndIf
		Else
			lErro 	:= .T.	
			cErro 	:= 	STR0128 + " L2_PRODUTO: " + TMPSL2->L2_PRODUTO + " DESC: " +  Alltrim(Posicione("SB1", 1, TMPSL2->L2_FILIAL + Alltrim(TMPSL2->L2_PRODUTO),"B1_DESC"))
			cErro 	+= " L2_SITTRIB: " + TMPSL2->L2_SITTRIB + " L2_VLRITEM: " + cValToChar(TMPSL2->L2_VLRITEM) + " L2_BASEICM: " + cValToChar(TMPSL2->L2_BASEICM)  
			cErro 	+= " B1_GRTRIB: " + cGrpTrib + " L2_TES: " + TMPSL2->L2_TES
			RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0128" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
			Return(Nil)
		EndIf
		//Busca a TES - Fim

		Aadd( aAuxSL2, {"L2_DESCRI" 	, IIF(Empty(TMPSL2->L2_DESCRI),cDescricao,TMPSL2->L2_DESCRI)} )
		Aadd( aAuxSL2, {"L2_LOCAL"		, IIF(Empty(TMPSL2->L2_LOCAL),cLocal,TMPSL2->L2_LOCAL)} )

            //Validando o local de estoque incluido no parametro MV_LOCALIZ, conforme layout 
            DbSelectArea("NNR")
            NNR->(DbSetOrder(1))
            If !NNR->(DbSeek(xFilial("NNR") + TMPSL2->L2_LOCAL))	
                lErro 	:= .T.	
                cErro 	:= I18n(STR0594, {TMPSL2->L2_LOCAL}) //Local #1 de Estoque não existente. Verifique o parametro MV_LOCALIZ"               
                RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0594" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
			    Return(Nil)
            EndIF

		Aadd( aAuxSL2, {"L2_UM"			, IIF(Empty(TMPSL2->L2_UM),cUnidade,TMPSL2->L2_UM)} )
		Aadd( aAuxSL2, {"L2_ITEM"		, IIF(Empty(TMPSL2->L2_ITEM),cItem,TMPSL2->L2_ITEM)} )

        //Se existir considerar o FECP na ALIQ de ICMS e no Valor de ICMS
		If lD2FECP .And. lL2FECP 

            nValIcmsL1 += TMPSL2->L2_VALICM+TMPSL2->L2_VALFECP
            nValFecpL1 += TMPSL2->L2_VALFECP

			Aadd( aAuxSL2, {"L2_VALICM"		, TMPSL2->L2_VALICM+TMPSL2->L2_VALFECP	} )
			Aadd( aAuxSL2, {"L2_PICM"		, TMPSL2->L2_PICM+TMPSL2->L2_ALQFECP	} )
		EndIf	

		Aadd( aAuxSL2, {"L2_TES"		, cTES} )
		Aadd( aAuxSL2, {"L2_CF"			, IIF(Empty(TMPSL2->L2_CF),cCF,TMPSL2->L2_CF)} )
		Aadd( aAuxSL2, {"L2_VEND"		, IIF(Empty(TMPSL2->L2_VEND),cVendItem,TMPSL2->L2_VEND)} )//
		Aadd( aAuxSL2, {"L2_SITTRIB"	, cSitTri				} )
  		
    	//Ponto de Entrada criado para retornar Campo e conte?o para execuï¿½ï¿½o no Execauto, somente duas posiï¿½ï¿½es por Array DAC 17/01/2017
  		If FindFunction("U_IN210AL2")        
			PIO->(DbGoto(TMPSL2->REGISTRO))  //Garanto posicionamento na tabela da Camada de Integraï¿½ï¿½o 
   			_aL2Mat := {}
      		_aL2Mat := U_IN210AL2(TMPSL2->REGISTRO,@aAuxSL2)

      		If ValType(_aL2Mat) == "A" .and. Len(_aL2Mat) > 0
				For nPos := 1 To Len(_aL2Mat)

					If Len(_aL2Mat[nPos]) <> 2   //somente duas posuï¿½ï¿½es nome do campo e conteudo     
						lErro 	:= .T.	
						cErro 	:= STR0125   //"Erro no retorno do Ponto de Entrada IN210AL2, retornar Array com 2 Posiï¿½ï¿½es [nome do campo | conteudo do campo] "                                          		
						RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0125" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
						Return(Nil)
					Endif

					//Verificar se o campo esta incluindo na matriz principal caso esteja o mesmo ser?alterado conforme o retorno do P,E.            
					nPosCpo := Ascan( aAuxSL2, { |x| AllTrim(x[1]) == AllTrim(_aL2Mat[nPos,1]) } )
					If nPosCpo > 0
						aAuxSL2[nPosCpo,2]	:= _aL2Mat[nPos,2]
					Else 
						Aadd(aAuxSL2,{	AllTrim(_aL2Mat[nPos,1]),;  	//Nome do Campo
										_aL2Mat[nPos,2],; 				//Conte?o do Campo
										Nil})      	
					Endif					
    			Next
      		Endif
		Endif      	    

		Aadd(aSL2, aAuxSL2) 
		
		nVlTotItem += TMPSL2->L2_VLRITEM + TMPSL2->L2_VALIPI

		TMPSL2->(DbSkip())
	EndDo 

    If nValIcmsL1 > 0 
        Aadd( aSL1, {"L1_VALICM" , nValIcmsL1} )
    EndIf

    If nValFecpL1 > 0
        Aadd( aSL1, {"L1_VALFECP", nValFecpL1} )
    EndIf

	//Valida valor total do L1 com a L2.
	nVlTotItem := Round(nVlTotItem, nCasaDecimal) 
	If cProcesso <> "PEDIDO"
		nDiferenca := Abs(nVlrTotL1 - nVlTotItem)
	Else
		nDiferenca := Abs((nVlrTotL1 - SL1->L1_FRETE) - nVlTotItem)
	EndIf
	
	If nDiferenca > nTolerancia

		cErro := STR0017 + " - (" + cValtoChar(nVlrTotL1) + "/" + cValtoChar(nVlTotItem) + ")"
		RMIGRVLOG("IR"	, "SL1"	, nRecSL1 , "STR0017" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
		aSL2 := {}
		Return(Nil)
	EndIF

	//Gera Formas de pagamento SL4.
	ValidSL4(	cFilSL1	    , cNum		, cPdv	    , nRecSL1	,;
				aPIORecnos	, cSituacao	, nVlrTotL1 , cXTPREG	,;
				cDOCPED	    , _cCliente	, ""        , cAcao		,;
				lHistorico	, cConta)
	
EndIf   

TMPSL2->(DbCloseArea())

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidSL4
Gera arquivo temporario TMPSL4 atraves do arquivo Legado 
@param 

@return Vazio
@Obs	ValidSL4 para ValidSL4
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidSL4(	cFilSL1	    , cNum		, cPdv			, nRecSL1	,;
						 	aPIORecnos	, cSituacao	, nVlrTotL1		, cXTPREG	,;
						 	cDOCPED	    , cCliente  , cXTPREGOld	, cAcao		,;
						 	lHistorico	, cConta)

Local cQuery 		:= ""								//Variavel da consulta
Local nVlTotPag		:= 0								//Valor total da soma dos pagamento
Local nDiferenca	:= 0                   				//Valor de diferenca
Local nCasaDecimal	:= TamSX3("L1_VLRTOT")[2]			//Quanidade de casas decimais
LOcal lTroco		:= SuperGetMV("MV_LJTROCO",,.F.)	//Verifica a configuração Situação 03 - Com controle de troco e valor bruto: MV_LJTROCO = .T.
LOcal nBruto		:= SuperGetMV("MV_LJTRDIN",,0)	   //Verifica a configuração Situação 03 - Com controle de troco e valor bruto: MV_LJTRDIN = 0
Local aSL4Vazio	:= {}								    //Relacao de campos que nao podem estar vazios
Local nI			:= 0
Local cErro		:= ""
Local lRetorno		:= .F.								//Controla a gravacao dos registro
Local aRetorno		:= {}								//Retorno da Funcao GeraOrc
Local aAuxSL4		:= {}								//Contem as parcelas da forma de pagamento
Local aSL4Recnos	:= {}								//Recnos da tabela PIP
Local nTamIt	 	:= TamSx3("L4_ITEM")[1]				//Tamanho do campo de itens
Local cItem		 	:= Repl("0", nTamIt)				//Numeracao dos Itens
Local nCont			:= 0
Local cAdm			:= "" 
Local lVendTEF		:= .F.
Local aL4Mat		:= {}
Local nPos			:= 0
Local cFormaPgto	:= ""                               //Armazena a forma de pagamento
Local cCampoL1      := ""
Local nPosCmpL1     := 0

//Ajuste para Cancelamento SAT quando não tem Forma e valor de pagamento Live.
//Ajustando valor pagamento para R$
DbSelectArea("SL4")
SL4->( DbSetOrder(4) )//L4_FILIAL+L4_NUM+L4_ITEM
If SL4->(DbSeek(SL1->L1_FILIAL+SL1->L1_NUM))
	If !Empty(SL1->L1_SERSAT) .AND. SL4->L4_VALOR == 0 //SAT
		RecLock('SL4',.F.)
		L4_FORMA := "R$"
		L4_VALOR := SL1->L1_VLRTOT
		SL4->(MsUnlock())
	EndIf
EndIf	

cQuery := "SELECT SL4.*, SL4.R_E_C_N_O_ as REGISTRO FROM " + RetSQLName("SL4") + " SL4"
cQuery += " WHERE 	SL4.L4_FILIAL 	= '" + cFilSL1		+ "'	AND "	
cQuery += " 	 	SL4.L4_NUM 		= '" + cNum 		+ "' 	AND "                               
cQuery += " 		SL4.D_E_L_E_T_  <> '*' 									"
cQuery += " ORDER BY SL4.L4_FILIAL, SL4.L4_NUM"

cQuery := ChangeQuery( cQuery )

//Execulta a query
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSL4", .T., .F. )

//Campos Obrigatorios do SL4
Aadd(aSL4Vazio, "L4_FILIAL"	)
Aadd(aSL4Vazio, "L4_NUM"	)    
Aadd(aSL4Vazio, "L4_FORMA"	)
Aadd(aSL4Vazio, "L4_VALOR"	)
                                
//Verifica se nao eh orcamento para validar outros campos
If !Empty(cSituacao)
	Aadd(aSL4Vazio, "L4_PDV"	)    
EndIf	

//Verifica se encontrou a Condicao Negociada
If TMPSL4->(Eof()) .AND. !(SL1->L1_CREDITO > 0)

	cErro := STR0065    //"Nao foram encontradas formas de pagamento para o or?mento -  (Condicao negociada)."
	RMIGRVLOG("IR", "SL1", nRecSL1, "STR0065", cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
Else

	While !TMPSL4->( Eof() )
                    
		//Limpa variaveis
		cErro 	 := ""      
		cAdm     := ""
		lVendTEF := .F.  
				
		LjGrvLog("ValidSL4","RmiRetailJob - Processando Orcamento: " +  TMPSL4->L4_NUM)

		//Carrega informacoes para gravacao de Log
		Aadd( aSL4Recnos, TMPSL4->REGISTRO)
		
		//Analisa se campos obrigatorios estao em vazios
		For nI:= 1 to Len(aSL4Vazio)
			If Empty( &("TMPSL4->"+aSL4Vazio[nI]))
				cErro += STR0002 + " " + aSL4Vazio[nI]
			EndIf
		Next nI
		
		//Grava o Log dos campos obrigatorios
		If !Empty(cErro)
			RMIGRVLOG("IR", "SL1", nRecSL1, "STR0002" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
			aSL4 := {}
			Return(Nil)
		EndIf
		
        //Forma de pagamento
        cFormaPgto := TMPSL4->L4_FORMA
		If lDePara

			cFormaPgto := AllTrim( RmiPsqDePa(cSisOri, "SX5", "X5_TABELA", cFormaPgto, 1, xFilial("SX5") + '24') )

			If Empty(cFormaPgto)
				RmiGrvLog("IR", "SL1", nRecSL1, "STR1004", STR1004,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)     //"A forma de pagamento do R_E_C_N_O_ informado, não existe na tabela SX5 (Genericas) e também no cadastro de De/para (MHM)"
				Return(Nil)
			EndIf			
		EndIf

        //Administradora
		cAdm     := TMPSL4->L4_ADMINIS		
		lVendTEF := AllTrim(cFormaPgto) $ "CC|CD|VA|CO|CP|FI|BO" .Or. !Empty(cAdm)
		If lDePara .And. lVendTEF .And. cProcesso <> "PEDIDO"

            cAdm := AllTrim( RmiPsqDePa(cSisOri, "SAE", "AE_COD", cAdm, 1, xFilial("SAE") + SubStr(cAdm, 1, 3)) )

			If Empty(cAdm)
				RmiGrvLog("IR", "SL1", nRecSL1, "STR0039", STR0039 + " " + cAdm,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)  //"Codigo da Administradora sem referencia De/Para no Protheus (SAE)"
				Return(Nil)
			EndIf
		Endif	
		LjGrvLog("ValidSL4", "RmiRetailJob Orcamento: " +  TMPSL4->L4_NUM + " - L4_FORMA : " + AllTrim(cFormaPgto) + " L4_ADMINIS: " + AllTrim(cAdm))
		
		//Verifica se tem erro no registro corrente
		If !Empty(cErro)
			aSL4 := {}
			Return(Nil)
		EndIf	
		   
		//Atualiza codigo do item da conficao de pagamento
		cItem := Soma1(cItem, nTamIt)
	    
		//Carrega array com as informacoes do pagamento
		aAuxSL4 := {}
		Aadd( aAuxSL4, {"L4_FILIAL"	, cFilSL1									} )
		Aadd( aAuxSL4, {"L4_ITEM"	, cItem		    							} )
		Aadd( aAuxSL4, {"L4_SITUA"  , cSituacao 								} )						
		Aadd( aAuxSL4, {"L4_FORMA"  , cFormaPgto                                } )
		Aadd( aAuxSL4, {"L4_ADMINIS", cAdm			                            } )
		Aadd( aAuxSL4, {"L4_TERCEIR", IIF(TMPSL4->L4_TERCEIR == "S", .T., .F.)  } )
		
    	//Ponto de Entrada criado para retornar Campo e conte?o para execuï¿½ï¿½o no Execauto, somente duas posiï¿½ï¿½es por Array DAC 17/01/2017
  		If ExistBlock("IN210AL4")        
			SL4->(DbGoto(TMPSL4->REGISTRO))  //Garanto posicionamento na tabela da Camada de Integraï¿½ï¿½o 
   			aL4Mat := {}
      		aL4Mat := ExecBlock("IN210AL4",.F.,.F., { TMPSL2->REGISTRO })

      		If ValType(aL4Mat) == "A" .and. Len(aL4Mat) > 0

				For nPos := 1 To Len(aL4Mat)

					If Len(aL4Mat[nPos]) <> 2   //somente duas posuï¿½ï¿½es nome do campo e conteudo     
						lErro 	:= .T.	
						cErro 	:= STR0126   //"Erro no retorno do Ponto de Entrada IN210AL4, retornar Array com 2 Posiï¿½ï¿½es [nome do campo | conteudo do campo] "
						RMIGRVLOG("IR", "SL1", nRecSL1, "STR0126" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
						Return(Nil)
					Endif

					//Verificar se o campo esta incluindo na matriz principal caso esteja o mesmo ser?alterado conforme o retorno do P,E.            
					nPosCpo := Ascan( aAuxSL4, { |x| AllTrim(x[1]) == AllTrim(aL4Mat[nPos,1]) } )
					If nPosCpo > 0
						aAuxSL4[nPosCpo,2]	:= aL4Mat[nPos,2]
					Else 
						Aadd(aAuxSL4,{	AllTrim(aL4Mat[nPos,1]),;   //Nome do Campo
										aL4Mat[nPos,2],; 			//Conte?o do Campo
										Nil})      	
					Endif					
    			Next
      		Endif
		Endif

        //Carrega itens do pagamento
		Aadd(aSL4, aAuxSL4)

        //Atualiza pagamentos no cabeçalho SL1
        If TMPSL4->L4_VALOR > 0 .And. !Empty(cFormaPgto)

            Do Case
                Case IsMoney(cFormaPgto) 
                    cCampoL1 := "L1_DINHEIR"
                
                Case cFormaPgto == 'CH'
                    cCampoL1 := "L1_CHEQUES"
                
                Case cFormaPgto $ 'CC|CD'

                    If ( nPosCmpL1 := Ascan(aSL1, {|x| x[1] == "L1_VENDTEF"}) ) > 0 
                        aSL1[nPosCmpL1][2] := "S"
                    Else
                        Aadd(aSL1, {"L1_VENDTEF", "S"})
                    EndIf

                    cCampoL1 := IIF (cFormaPgto == 'CC', "L1_CARTAO", "L1_VLRDEBI")
                
                Case cFormaPgto == 'CO'
                    cCampoL1 := "L1_CONVENI"
                
                Case cFormaPgto == 'VA'
                    cCampoL1 := "L1_VALES"
                
                Case cFormaPgto == 'FI'
                    cCampoL1 := "L1_FINANC"
                
                Case cFormaPgto == 'CR'
                    cCampoL1 := "L1_CREDITO"
                
                OtherWise
                    cCampoL1 := "L1_OUTROS"
            EndCase 

            //Atualiza um dos campos acima
            If ( nPosCmpL1 := Ascan(aSL1, {|x| x[1] == cCampoL1}) ) > 0 
                aSL1[nPosCmpL1][2] += TMPSL4->L4_VALOR
            EndIf

            //Carrega o valor de entradas exceto as contidas no parâmetro
            If !( cFormaPgto $ SuperGetMV("MV_ENTEXCE", .F., "") )

                If ( nPosCmpL1 := Ascan(aSL1, {|x| x[1] == "L1_ENTRADA"}) ) > 0 
                    aSL1[nPosCmpL1][2] += TMPSL4->L4_VALOR
                EndIf
            EndIf

            //Armazena ultima forma de pagamento 
            If ( nPosCmpL1 := Ascan(aSL1, {|x| x[1] == "L1_FORMPG"}) ) > 0 
                aSL1[nPosCmpL1][2] := cFormaPgto
            EndIf
        EndIf
        
		//Soma Valor dos Pagamentos
		nVlTotPag += TMPSL4->L4_VALOR

		TMPSL4->( DbSkip() )
	EndDo   
	
	//Valida Configuração de Troco.
	If SL1->L1_TROCO1 > 0 .AND. (!lTroco .OR. nBruto > 0)
		cErro := STR1005 //"Configuração Situação 03 - Com controle de troco e valor bruto o valor dos parametros devem ser : MV_LJTROCO = .T. | MV_LJTRDIN = 0 - "
		cErro += STR1006 //"FAQs https://tdn.totvs.com/x/JgmFD "
		RMIGRVLOG("IR", "SL1", nRecSL1, "STR0066" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
		Return(Nil)
	EndIf
	
	//Valida valor total do L1 com o L4
	nVlTotPag	:= Round(nVlTotPag, nCasaDecimal)	
	nDiferenca 	:= Abs((nVlrTotL1+SL1->L1_TROCO1+SL1->L1_DESPESA) - nVlTotPag) //Considera o troco. SL1->L1_TROCO1
	
	If nDiferenca > 0 
		nDiferenca 	:= Abs(nVlrTotL1 - (nVlTotPag + SL1->L1_CREDITO)) //desconsidera o troco para validar o caso do chef.(Manda troco no cancelamento e não manda para SEFAZ)
	endIf 
		
	If nDiferenca > 0 //
		cErro := STR0066 + " - (" + cValtoChar(nVlrTotL1) + "/" + cValtoChar(nVlTotPag) + ")"
		RMIGRVLOG("IR", "SL1", nRecSL1, "STR0066" , cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)//Somatoria das formas de pagamento diferente do cabecalho (Cabecalho/Formas Pag))
		aSL4 := {}
		Return(Nil)
	EndIF        
	
	//Abre transacao para gravar Orcamento
	Begin Transaction
	
		//Grava o Orcamento SL1, SL2 e SL4
		aRetorno := GeraOrc(	nRecSL1		, aPIORecnos	, aSL4Recnos	, cFilSL1	,; 
								cNum		, cPdv			,  cXTPREG		, cCliente	,;
								lHistorico	, cConta		)
																
		If Len(aRetorno) > 0
			lRetorno := aRetorno[1][1] 
		Else
			lRetorno := .T.         					
		EndIf
		
		If !lRetorno         
		
			RollBackSX8()	
			DisarmTransaction()
		Else
			ConfirmSX8()
			//Atualiza Status nas tabela SL1
			RMIGRVSTAT("SL1", nRecSL1, "RX")
		EndIf
	
	End Transaction 
	
	//Trava Logs de Erro - Depois de Fechar a Transacao. ?
	If !lRetorno  
		For nCont:=1 To Len(aRetorno)
			RMIGRVLOG(aRetorno[nCont][2], aRetorno[nCont][3], aRetorno[nCont][4], aRetorno[nCont][5], aRetorno[nCont][6],,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
		Next nCont
	EndIf				
	
Endif

TMPSL4->( DbCloseArea())
SL1->( DbCloseArea())
SL2->( DbCloseArea())
SL4->( DbCloseArea())

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraOrc
Travacao das tabelas de orcamento SL1, SL2 e SL4 
@param 

@return Vazio
@Obs	GeraOrc para GeraOrc
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraOrc(	nRecSL1		, aPIORecnos	, aSL4Recnos	, cFilSL1	,; 
							_cNumExter	, _cPdv			,  cXTPREG		, cCliente	,;
							lHistorico	, cConta		)
							
Local aRetorno		:= {}							//Retorno da Funcao
Local lGravou		:= .F.             		       	//Indica se foi feita a correga gravacao do registro
Local nPosNSL4		:= 0							//Posicao no array aSL4 do L4_NUM
Local nPosItSL2		:= 0							//Posicao no Array aSL2 do L2_ITEM
Local nPosProd		:= 0							//Posicao no array aSL2 do L2_PRODUTO
Local nPosItSL4		:= 0							//Posicao no Array aSL4 do L4_ITEM
Local nPosLocal		:= 0
Local nPosPdv 		:= 0
Local cNumero		:= ""							//Numero do proximo orcamento
Local cItem			:= ""							//Codigo do Item
Local cProduto		:= ""							//Codigo do Produto
Local nCont			:= 0							
Local lAtuL4		:= .T.
Local cLocal		:= ""
Local _cStaImp		:= ""							//Variavel para determinar o codigo do que sera preenchido no campo PIN_STAIMP

DbSelectArea("SL1")  
SL1->(DbSetOrder(1))	

DbSelectArea("SL2")
SL2->( DbSetOrder(1) )					//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO

DbSelectArea("SL4")
SL4->( DbSetOrder(4) )					//L4_FILIAL+L4_NUM+L4_ITEM

//Ponto de Entrada para Validar se os dados estao corretos
If FindFunction("U_IN210VLD")
	If !U_IN210VLD(@_cStaImp,nRecSL1,@cErro,aSL1,aSL2,aSL4)
		If Empty(_cStaImp)
			_cStaImp := "3"
		EndIf
		
		cErro := "[Ponto de Entrada - IN210VLD]" + cErro
		
		Aadd(aRetorno, {.F., _cStaImp, "SL1", nRecSL1, "STR9999" ,cErro} )
		
		Return aRetorno
	EndIf
EndIf

//Pega posicao de campos no array aSL2 ?
nPosItSL2 	:= Ascan(aSL2[1], {|x| x[1] == "L2_ITEM"    } )     
nPosProd	:= Ascan(aSL2[1], {|x| x[1] == "L2_PRODUTO"	} )     
nPosLocal	:= Ascan(aSL2[1], {|x| x[1] == "L2_LOCAL"   } )  
nPosPdv 	:= Ascan(aSL2[1], {|x| x[1] == "L2_PDV"     } )  

//Pega posicao de campos no array aSL4
If Len(aSL4) > 0 
	nPosNSL4	:= Ascan(aSL4[1], {|x| x[1] == "L4_NUM"} )
	nPosItSL4	:= Ascan(aSL4[1], {|x| x[1] == "L4_ITEM"} )
EndIf
	
//Incluido transaction DAC 17/01/2017
Begin Sequence
	//Faz a gravacao do SL1.
	SL1->( DbGoTo(nRecSL1) )
	If !SL1->( Eof() )
		cFilSL1 := SL1->L1_FILIAL
		cNumero := SL1->L1_NUM
		
		lGravou := FRTGeraSL("SL1", aSL1, .F.)
	EndIf
	
	If !lGravou
		cErro 	:= STR0081
		Aadd(aRetorno, {lGravou, "IR", "SL1", nRecSL1, "STR0123" , cErro} )
        Break
	Endif            

	//Ponto de Entrada para permitir alteraï¿½ï¿½o no SL1 ap? a Gravaï¿½ï¿½o do Registro DAC 08/11/2016
	If ExistBlock("IN210GL1")
		ExecBlock("IN210GL1",.F.,.F., { aSL1 } )
	Endif

	//Grava tabela SL2 com os dados da importacao.
	For nCont := 1 To Len(aSL2)
	
		lGravou := .F.
		
		//Pega dados dos Itens
		cItem 		:= aSL2[nCont][nPosItSL2][2]
		cProduto	:= aSL2[nCont][nPosProd][2]
       	cLocal 		:= aSL2[nCont][nPosLocal][2] 
             
		//Faz a gravacao do SL2.
		SL2->(DbSetOrder(1))		//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
		If SL2->( DbSeek(cFilSL1 + cNumero + cItem) )
			lGravou	:= FRTGeraSL("SL2", aSL2[nCont], .F.)
		EndIf
			
		If !lGravou 
			cErro 	:= STR0001  + "Erro na Inclus? dos Itens: L2_FILIAL+L2_NUM+L2_ITEM (" + cFilSL1 + cNumero + cItem + ") - SL2"
			Aadd(aRetorno, {lGravou, "IR", "SL1", nRecSL1 , "STR0001" , cErro} )
			Break				
		EndIf  
			  
		//Ponto de Entrada para permitir alteraï¿½ï¿½o no SL2 ap? a Gravaï¿½ï¿½o do Registro  DAC 08/11/2016
		If ExistBlock("IN210GL2")
			ExecBlock("IN210GL2",.F.,.F., { aSL2[nCont] } )
		Endif				
	Next nCont	

	//Grava tabela SL4 com os dados da importacao.
	If lAtuL4   
		For nCont:=1 To Len(aSL4)  
			
			lGravou := .F.
					
			cItem   := aSL4[nCont][nPosItSL4][2]
		             
			//Faz a gravacao do SL4.
			SL4->( DbSetOrder(4) )		//L4_FILIAL+L4_NUM+L4_ITEM
			If SL4->( DbSeek(cFilSL1 + cNumero + cItem) ) .Or. SL4->( DbSeek(cFilSL1 + cNumero) )//Pode gerar com Item em Branco.
				lGravou := FRTGeraSL("SL4", aSL4[nCont], .F.)			
			EndIf
				
			If !lGravou 
				cErro 	:= STR0001  + "Erro na Inclus? dos Pagamento: L4_FILIAL+L4_NUM+L4_ITEM (" + cFilSL1 + cNumero + cItem + ") - PIP"
				Aadd(aRetorno, {lGravou, "IR", "SL1", nRecSL1, "STR0001" , cErro} )
				//Exit
				Break				
			EndIf
			 
			//Ponto de Entrada para permitir alteraï¿½ï¿½o no SL4 ap? a Gravaï¿½ï¿½o do Registro  DAC 08/11/2016
			If ExistBlock("IN210GL4")
				ExecBlock("IN210GL4",.F.,.F., { aSL4[nCont] } )
			Endif				

		Next nCont	
	EndIf

	//Atualiza o L1_SITUA apenas depois de gravar todo o orcamento, para o GravaBat pode Processar Corretamente.
	If lAtuSitua
		RecLock("SL1", .F.)
		SL1->L1_SITUA := "RX"
		SL1->( MsUnLock() )
		IIf(ExistFunc("LjLogL1Sit"), LjLogL1Sit(), NIL)
	EndIf
	
End Sequence

Return(aRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValCampo
Retorna dados das tabelas do padrao pelos campos que foram
criados para referencia
@param 

@return Vazio
@Obs	ValCampo para ValCampo
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValCampo(cTabela, aCmpBus, cChave, nIndex, cErro, cStr)

Local aArea	:= GetArea()
Local nI		:= 0
Local	aRetorno:= {}
Local aAreaTab	:= (cTabela)->( GetArea() )

//Retorno o valor dos campos 
DbSelectArea(cTabela)
dbSetOrder(nIndex)
If (cTabela)->( dbSeek( cChave ) )
	cErro := ""
	If Len(aCmpBus) > 0
		For nI := 1 to Len(aCmpBus)
			aAdd(aRetorno,(cTabela)->&(aCmpBus[nI]))
		Next nI
	EndIf
//Grava os devidos Logs na PI0 caso nao ache o registro	
Else
	RMIGRVLOG("IR", aInfoLog1[1], aInfoLog1[2], cStr, cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1	)
	
	If Len(aInfoLog2) > 0
		RMIGRVLOG("IR", aInfoLog1[1], aInfoLog1[2], cStr	, cErro,,,,,,cChaveSL1,"GRVBATCH","PROTHEUS",cUUIDSL1)
	EndIf	      
	
	aRetorno := {}
EndIf

RestArea(aArea)
RestArea(aAreaTab)
	
Return(aRetorno)     

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaAlias
Fechas os Alias Temporarios
@param 

@return Vazio
@Obs	FechaAlias para FechaAlias
@author Everson S P Junior
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FechaAlias(lTodos)

Default lTodos := .F.

If lTodos
	If Select("TMPSL1") > 0
		TMPSL1->(DbCloseArea())
	EndIf    
EndIf

If Select("TMPSL2") > 0					
	TMPSL2->(DbCloseArea())
EndIf

If Select("TMPSL4") > 0					
	TMPSL4->(DbCloseArea())
EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuaOrigem
Atualiza o campo L1_ORIGEM para 'N' configurando que o registro 
veio de uma integração
@param 

@return Nil
@Obs	Para seguir o Legado o campo L1_ORIGEM deve ser igual 'N'
@author Everson S P Junior
@since 18/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuaOrigem(nRecSL1)
Local aArea	:= GetArea()
	
SL1->(dbGoTo(nRecSL1))
RecLock("SL1", .F.)
SL1->L1_ORIGEM := 'N'
SL1->(MsUnLock())

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSL1Dup
Verifica se DOC e Serie já existem na SL1
@param 

@return lRet
@author Everson S P Junior
@since 24/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldSL1Dup(cFILSL1,cDocSL1,cSERSL1)
Local aArea		:= GetArea()
Local lRet		:= .F.	
Local cQuery	:= ""

cQuery := "SELECT COUNT(L1_DOC) TOTAL FROM " + RetSQLName("SL1") + " SL1"
cQuery += " WHERE 	SL1.L1_FILIAL 	= '" + cFILSL1		+ "'	AND "	
cQuery += " 	 	SL1.L1_DOC 		= '" + cDocSL1 		+ "' 	AND "                               
cQuery += " 	 	SL1.L1_SERIE	= '" + cSERSL1 		+ "' 	AND "
cQuery += " 	 	SL1.L1_SITUA   IN ('RX','OK') 				AND "
cQuery += " 		SL1.D_E_L_E_T_  <> '*'"
//Execulta a query
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "VLDSL1", .T., .F. )

If VLDSL1->TOTAL > 0
	lRet:= .T.
EndIf

VLDSL1->(DbCloseArea())
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjRetTes
Retorna a TES para atualizar na venda

@param 
@return 
@author  Bruno Almeida
@since	 07/02/2020
@version 1.0
/*/
//-------------------------------------------------------------------

Function LjRetTes(cTpOper, cCliente, cLoja, cCodProd)

Local cTES 	:= "" //Variavel que retorna a TES
Local aArea	:= GetArea() //Guarda a area

Default cTpOper := ""
Default cCliente := ""
Default cLoja := ""
Default cCodProd := ""

/*
Prioridades da utilizacao da TES:	
1 - TES que esta gravada na SL2
2 - TES Inteligente
3 - TES do Item (SB1) ou Indicadores de produto (SBZ)
4 - TES Padrao MV_TESSAI
*/

//Retorna a TES - Pega a TES ja gravada na SL2
If !Empty(TMPSL2->L2_TES) 
	cTES	:= TMPSL2->L2_TES  
								
Else

	//Retorna a TES - Retorna a TES Inteligente
	cTES := MaTesInt(2, cTpOper, cCliente	, cLoja, "C", cCodProd )

	If Empty(cTES)

		//Foi necessario posicionar no produto  da venda, pois se o parametro MV_ARQPROD for igual a SB1,
		//so retorna a informacao da TES na funcao RetFldProd se estiver posicionado no registro do produto.
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
		If SB1->(dbSeek(xFilial("SB1")+cCodProd))

			cTES := RetFldProd(SB1->B1_COD,"B1_TS")

			If Empty(cTES)
				cTES := SuperGetMV("MV_TESSAI",,"")
			EndIf

		EndIf

	EndIf
EndIf

RestArea(aArea)

Return cTES


//-------------------------------------------------------------------
/*/{Protheus.doc} RmiValidCa
Valida se determinado campo esta vazio e grava o log MHL

@param 
@return  lRet -> Retorna .T. caso algum campo obrigatório da venda estiver vazio
@author  Bruno Almeida
@since	 04/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RmiValidCa(nRecSL1)

Local aCampos 	:= {"L1_PDV","L1_SERIE","L1_ESPECIE","L1_DOC","L1_OPERADO"} //Campos para serem validados
Local lRet 		:= .F. //Variavel de retorno
Local nI 		:= 0 //Variavel de loop

For nI := 1 to Len(aCampos) 
	If Empty(&("TMPSL1->" + aCampos[nI])) 
		RMIGRVLOG("IR", "SL1", nRecSL1, "STR1007", STR1007 + " " + aCampos[nI] + " " + STR1008,,,,,, cChaveSL1, "GRVBATCH", "PROTHEUS", cUUIDSL1) //"O campo" # "esta vazio, esse campo devera ser preenchido para o correto processamento da venda!"
		lRet := .T.
		Exit
	EndIf
Next nI

Return lRet
