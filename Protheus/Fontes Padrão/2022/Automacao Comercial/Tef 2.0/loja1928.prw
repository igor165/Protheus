#INCLUDE "PROTHEUS.CH"  
#INCLUDE "DEFTEF.CH"           
#INCLUDE "LOJA1928.CH"

Static lLjVndVouc := NIL

Function LOJA1928 ; Return  // "dummy" function - Internal Use

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLJAComDiscado	   บAutorณVENDAS CRM     บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classe abstrata responsavel por comunicacao discado        บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Class LJAComDiscado
	
	Data oConfig 			// configuracoes  															 
	Data oConfigAtual		// configuracao do objeto atual
	Data oRetGerenc			// retorno do gerenciador
	Data oArquivo			// lista de arquivo de envio
	Data oTransacao         // Dados da transacao     
	Data cCampo004			//Campo da Moeda 
	Data cCampo701			//Versao da automa็ใo - PayGo
	Data cCampo716			//Empresa da Automacao - PayGo
	Data cCampo706			//Capacidades da automa็ใo PayGo
	

	Method New() 
	Method SetTrans(oTransacao)	
	Method CriarADM(cPrefixo001)
	Method CriarCHQ(cPrefixo001)
	Method CriarCRT(cPrefixo001)
	Method CriarCNF(oDadosCNF, lAtivo, cPrefixo001)
	Method CriarNCN(cNsu, cNomeRede, cFinalizacao, nValor, lAtivo, cPrefixo001)
	Method CriarATV(cPrefixo001) 
	Method CriarCNC(cPrefixo001, cTransCanc, lAtivo )
	Method InicializaConf()	
	//Metodos internos
	Method ChamaTrans()	
	Method AguardaResp(cSeqArq) 
   	Method TemResposta(cFile, nTimeOut, cSeqArq)  
   	Method ProxIdTrn()
	Method GerenciadorAtv(lPendente, lConfirmar) 
	Method CriarBck(oArqRes)
	Method CompNOp(cSeqArq, c001 ) 
	Method LerArqPend()
	Method GravarArqpend(aTransac)
	Method LocArqPend(aTransac, cNsu) 
	Method AtuStatus(aTransac, cNsu, cStatus)	
EndClass         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(oConfig) Class LJAComDiscado
	Local cSimbMoeda := AllTrim(SuperGetMV("MV_SIMB1")) //Codigo da Moeda
	
	Self:oConfig := oConfig     //Objeto Configurador
	
	If cSimbMoeda == "RS"
		Self:cCampo004 := "0"
	ElseIf 	cSimbMoeda == "US$"
		Self:cCampo004 := "1" 
	Else
		Self:cCampo004 := ""
	EndIf

	If STFGetCfg("lPafEcf")
		Self:cCampo701	:= STBFMModPaf() +  " " + STBVerPAFECF("VERSAOAPLIC")
	Else
		Self:cCampo701	:= ""
	EndIF
	Self:cCampo716	:= "TOTVS SA"
	Self:cCampo706	:= "0" //Nenhuma funcionalidade suportada
	
	oArquivo := LJCList():New()	
	
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriarADM     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria transacao adm                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CriarADM(cPrefixo001) Class LJAComDiscado
	Local nSeqArq    := 0   //Sequencia do Arquivo
	Local cCampo001	 := ""   //Campo 001  

	Default cPrefixo001 := ""
				
	// Ativa Gerenciador
	Self:GerenciadorAtv(!Empty(cPrefixo001)) 
	
	//Intacia Classe para gerar lista de envio
	Self:oArquivo := LJCList():New()	
	
	// Pega proxima transacao
	nSeqArq := Self:ProxIdTrn() 
	
	cCampo001 := cPrefixo001 + ALLTRIM(StrZero(nSeqArq,10-Len(cPrefixo001)))

	//Criar lista com os dados do arquivo da transacao
	Self:oArquivo:ADD("000-000 = ADM" )								// Tipo de tranzacao
	Self:oArquivo:ADD("001-000 = " + cCampo001 )	// Identifica็ใo da tranzacao  
	If Self:oConfigAtual:cAdmFin == "PAYGO"
		Self:oArquivo:ADD("701-000 = " + Self:cCampo701) 
		Self:oArquivo:ADD("706-000 = " + Self:cCampo706) 
		Self:oArquivo:ADD("716-000 = " + Self:cCampo716) 
	EndIf
	Self:oArquivo:ADD("999-999 = 0")
	
	//Chama a transacao
	Self:ChamaTrans(!Empty(cPrefixo001))	
	
	//Aguardando retorno
	Self:AguardaResp( cCampo001 )

Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCriarCHQ     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria transacao de cheque									  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CriarCHQ(cPrefixo001 ) Class LJAComDiscado     
Local nSeqArq        //Sequencia do arquivo
Local cCampo001 := "" //Campo001

Default cPrefixo001 := ""
			
// Ativa Gerenciador
Self:GerenciadorAtv(!Empty(cPrefixo001)) 

//Intacia Classe para gerar lista de envio   
Self:oArquivo := LJCList():New()	

// Pega proxima transacao
nSeqArq := Self:ProxIdTrn() 

cCampo001 :=  cPrefixo001 + AllTrim(StrZero(nSeqArq,10-Len(cPrefixo001)))

Self:oArquivo:ADD("000-000 = CHQ" )								// Tipo de tranzacao
Self:oArquivo:ADD("001-000 = " + cCampo001 )	// Identifica็ใo da tranzacao   
Self:oArquivo:ADD("003-000 = " + Alltrim(StrTran(StrTran(Transform(Self:oTransacao:nValor, "@E 999,999,999.99"),",",""), ".", "")) )  
If Self:oConfigAtual:cAdmFin == "PAYGO" .AND. !Empty(Self:cCampo004)
	Self:oArquivo:ADD("004-000 = " + Self:cCampo004)
EndIf

If Self:oTransacao:nBanco > 0 .AND. Self:oTransacao:nAgencia > 0 .AND. Self:oTransacao:nConta > 0
	If !Empty(AllTrim(Self:oTransacao:cTipoCli))
		Self:oArquivo:ADD("006-000 = " + Self:oTransacao:cTipoCli)
	EndIf
	If !Empty(AllTrim(Self:oTransacao:cCNPJ))
		Self:oArquivo:ADD("007-000 = " + Self:oTransacao:cCNPJ)
	EndIf
	Self:oArquivo:ADD("008-000 = " + Left(StrTran(DtoC(Self:oTransacao:dDataVcto),"/",""),4)+StrZero(Year(Self:oTransacao:dDataVcto),4)  )	
	Self:oArquivo:ADD("033-000 = " + AllTrim(Str(Self:oTransacao:nBanco)) )
	Self:oArquivo:ADD("034-000 = " + AllTrim(Str(Self:oTransacao:nAgencia)) )   
	If Self:oTransacao:nC1 > 0
		Self:oArquivo:ADD("035-000 = " + AllTrim(Str(Self:oTransacao:nC1)) ) 
	EndIf   
	Self:oArquivo:ADD("036-000 = " + AllTrim(Str(Self:oTransacao:nConta)) )   
	If Self:oTransacao:nC2 > 0
		Self:oArquivo:ADD("037-000 = " + AllTrim(Str(Self:oTransacao:nC2)) ) 
	EndIf 
	Self:oArquivo:ADD("038-000 = " + AllTrim(Str(Self:oTransacao:nCheque)) )     
	If Self:oTransacao:nC3 > 0
		Self:oArquivo:ADD("039-000 = " + AllTrim(Str(Self:oTransacao:nC3)) ) 
	EndIf 
EndIf

If Self:oConfigAtual:cAdmFin == "PAYGO"
	Self:oArquivo:ADD("701-000 = " + Self:cCampo701) 
	Self:oArquivo:ADD("706-000 = " + Self:cCampo706) 
	Self:oArquivo:ADD("716-000 = " + Self:cCampo716) 
EndIf

Self:oArquivo:ADD("999-999 = 0")

//Chama a transacao
Self:ChamaTrans(!Empty(cPrefixo001))	

//Aguardando retorno
Self:AguardaResp(cCampo001)


Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCriarCRT     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria transacao de credito e debito                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CriarCRT(cPrefixo001) Class LJAComDiscado
Local nSeqArq         	//Sequencia do Arquivo
Local cCampo001			:= "" //Campo001
Local cTipoFin			:= ""			// Tipo Financiamento
Local cTipoParc			:= ""
Local cTipoCartao		:= ""
Local nParcelas			:= 0			// Quantidade de parcelas
Local aCartoes			:= Array(3)
Local aMVLJRETPAY		:= StrTokArr(SuperGetMV("MV_LJREPAY",,"0;"),";") //Paramero de configura็๕es genericas do Pay & Go, para mais informa็๕es consultar documenta็ใo 

Default cPrefixo001		:= ""
			
// Ativa Gerenciador
Self:GerenciadorAtv(!Empty(cPrefixo001)) 

//Intacia Classe para gerar lista de envio
Self:oArquivo := LJCList():New()	

// Pega proxima transacao
nSeqArq := Self:ProxIdTrn() 
cCampo001 := cPrefixo001+ALLTRIM(StrZero(nSeqArq,10-Len(cPrefixo001)))

If Self:oTransacao:nParcela == 0 .AND. aMVLJRETPAY[1] == "0"
	nParcelas := 1
Else
	nParcelas := Self:oTransacao:nParcela
EndIf

//Tipo de cartao CC/CD/Voucher
If Alltrim(Self:oTransacao:cFormaPgto)=="CC"
	cTipoCartao := "1"
Else
	If LjIsVndVou()
		aCartoes[1] := nParcelas 
		aCartoes[2] := Self:oTransacao:nValor 
		aCartoes[3] := cCampo001
		cTipoCartao := LjOpcVouc(aCartoes,1)
	Else
		cTipoCartao := "2"
	EndIf
EndIf

cTipoFin := ""
cTipoParc:= "0"

// Tipo de Financiamento / 	A Vista ou Parcelado pelo Emissor 							
If nParcelas == 1
	If cTipoCartao == "1"
		cTipoFin := "10"  			// Credito a Vista
	ElseIf  cTipoCartao == "2"
		cTipoFin := "20"  			// Debito a Vista					 
	Endif
							
	cTipoParc		:= "1"			//Tipo de Parcelamento : a vista
							
Elseif nParcelas > 1
	If cTipoCartao == "1"
		cTipoFin := "11"  			// Credito Parcelado
	ElseIf  cTipoCartao == "2"
		cTipoFin := "22"  			// Debito Parcelado									 
	Endif
		
	cTipoParc		:= "3"			//Tipo de Parcelamento : parcelado pelo estabelecimento
Endif

//Criar lista com os dados do arquivo da transacao
Self:oArquivo:ADD("000-000 = CRT" )				// Tipo de transacao
Self:oArquivo:ADD("001-000 = " + cCampo001 )	// Identifica็ใo da transacao
Self:oArquivo:ADD("003-000 = " + AllTrim(StrTran(StrTran(Transform(Self:oTransacao:nValor, "@E 999,999,999.99"),",",""), ".", "")) ) 

If Self:oConfigAtual:cAdmFin == "PAYGO" .AND. !Empty(Self:cCampo004)
	Self:oArquivo:ADD("004-000 = " + Self:cCampo004)
EndIf

Self:oArquivo:ADD("011-000 = " + cTipoFin)

If nParcelas > 1
	Self:oArquivo:ADD("017-000 = " + "0")			
	Self:oArquivo:ADD("018-000 = " + Alltrim(Str(Self:oTransacao:nParcela)))	
EndIf		

If Self:oConfigAtual:cAdmFin == "PAYGO"
	Self:oArquivo:ADD("701-000 = " + Self:cCampo701) 
	Self:oArquivo:ADD("706-000 = " + Self:cCampo706) 
	Self:oArquivo:ADD("716-000 = " + Self:cCampo716) 
EndIf

Self:oArquivo:ADD("730-000 = " + "1")								// Venda com cartao
Self:oArquivo:ADD("731-000 = " + cTipoCartao)						// Tipo Cartao (1-CC / 2-CD / 3-Voucher)
Self:oArquivo:ADD("732-000 = " + cTipoParc)							// Tipo de Parcelamento

Self:oArquivo:ADD("999-999 = 0")

//Chama a transacao
Self:ChamaTrans(!Empty(cPrefixo001))	

//Aguardando retorno
Self:AguardaResp(cCampo001)
Self:oTransacao:nParcela := Val(Self:oRetGerenc:C018)

Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCriarCNC     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria transacao de cancelamento                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CriarCNC(cPrefixo001, cTransCanc, lAtivo ) Class LJAComDiscado     
Local nSeqArq	:= 0	//Sequencia do Arquivo
Local cCampo001	:= ""	//Campo001

Default cPrefixo001	:= ""
Default cTransCanc	:= ""

// Ativa Gerenciador   
If !lAtivo
	Self:GerenciadorAtv(!Empty(cPrefixo001)) 
EndIf

//Intacia Classe para gerar lista de envio
Self:oArquivo := LJCList():New()	

// Pega proxima transacao
nSeqArq := Self:ProxIdTrn()  
cCampo001:= cPrefixo001 + ALLTRIM(StrZero(nSeqArq,10-Len(cPrefixo001)))

Self:oArquivo:ADD("000-000 = CNC" )								// Tipo de Transacao     

Self:oArquivo:ADD("001-000 = " + cCampo001 )	// Identifica็ใo da Transacao   
If Self:oTransacao:nCupom > 0
	Self:oArquivo:ADD("002-000 = " + ALLTRIM(STR(Self:oTransacao:nCupom,10)) )	//Numero do comprovante 
EndIf
Self:oArquivo:ADD("003-000 = " + AllTrim(StrTran(StrTran(Transform(Self:oTransacao:nValor, "@E 999,999,999.99"),",",""), ".", "")) )

If cTransCanc $ "CHQ/CRT" .AND. Self:oConfigAtual:cAdmFin == "PAYGO" .AND. !Empty(Self:cCampo004)
	Self:oArquivo:ADD("004-000 = " + Self:cCampo004)
EndIf

If cTransCanc == "CHQ"
	If !Empty(Self:oTransacao:cTipoCli)
		Self:oArquivo:ADD("006-000 = " + Self:oTransacao:cTipoCli)
	EndIf
	
	If !Empty( Self:oTransacao:cCNPJ)
		Self:oArquivo:ADD("007-000 = " + Self:oTransacao:cCNPJ)
	EndIf
	
	If !Empty(Self:oTransacao:dDataVcto)
		Self:oArquivo:ADD("008-000 = " + Left(StrTran(DtoC(Self:oTransacao:dDataVcto),"/",""),4)+StrZero(Year(Self:oTransacao:dDataVcto),4)  )	
    EndIf
EndIf 

Self:oArquivo:ADD("010-000 = " + Self:oTransacao:cRede)
Self:oArquivo:ADD("012-000 = " + Self:oTransacao:cNSU)
Self:oArquivo:ADD("022-000 = " + Left(StrTran(DtoC(Self:oTransacao:dDataTrn),"/",""),4)+StrZero(Year(Self:oTransacao:dDataTrn),4)  )
Self:oArquivo:ADD("023-000 = " + Self:oTransacao:cHoraTrn)

If cTransCanc == "CHQ"  .AND. Self:oTransacao:nBanco > 0 .AND. Self:oTransacao:nAgencia > 0 .AND. Self:oTransacao:nConta > 0
	Self:oArquivo:ADD("033-000 = " + AllTrim(Str(Self:oTransacao:nBanco)) )
	Self:oArquivo:ADD("034-000 = " + AllTrim(Str(Self:oTransacao:nAgencia)) )   
	If Self:oTransacao:nC1 > 0
		Self:oArquivo:ADD("035-000 = " + AllTrim(Str(Self:oTransacao:nC1)) ) 
	EndIf   
	Self:oArquivo:ADD("036-000 = " + AllTrim(Str(Self:oTransacao:nConta)) )   
	If Self:oTransacao:nC2 > 0
		Self:oArquivo:ADD("037-000 = " + AllTrim(Str(Self:oTransacao:nC2)) ) 
	EndIf 
	Self:oArquivo:ADD("038-000 = " + AllTrim(Str(Self:oTransacao:nCheque)) )     
	If Self:oTransacao:nC3 > 0
		Self:oArquivo:ADD("039-000 = " + AllTrim(Str(Self:oTransacao:nC3)) ) 
	EndIf 
EndIf 

If Self:oDiscado:cAdmFin == "PAYGO"
	Self:oArquivo:ADD("701-000 = " + Self:cCampo701) 
	Self:oArquivo:ADD("706-000 = " + Self:cCampo706) 
	Self:oArquivo:ADD("716-000 = " + Self:cCampo716) 
EndIf

Self:oArquivo:ADD("999-999 = 0")

//Chama a transacao
Self:ChamaTrans(.T.)	

//Aguardando retorno
Self:AguardaResp(cCampo001)
Return Self

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณChamaTrans   บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama a transacao                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method ChamaTrans(lPendente, lConfirmar) Class LJAComDiscado
	
	Local lRet		:= .T.   //Retorno da Fun็ใo
	Local oGravArq 	:= Nil   //Objeto Arquivo
	Local nCount 	:= 0     //contador
	Local aTransac	:= {} //Array de transacoes
	Local nLinhas	:= 0   //Linhas
  	Local oRetGerenc:= Nil   //Relatorio Gerencial
	
	
	Default lPendente := .F. //Permitir transacoes pendentes?  
	Default lConfirmar := .T. //confirma a transacao
	
	
	If !lPendente 
	
	    aTransac := Self:LerArqPend(_DISCADO_PENDENTE)
		
		nLinhas := Len(aTransac)
		
		If nLinhas > 0
		  
			If lConfirmar
				oRetGerenc     := LJCRetTransacaoCCCD():New()  
			EndIf            
						
			For nCount := 1 to nLinhas  
				If lConfirmar   
					oRetGerenc:cRede := aTransac[nCount,1]
					oRetGerenc:cNsu := aTransac[nCount,2]
					oRetGerenc:cFinalizacao := aTransac[nCount,3] 
					
					Self:CriarCNF(oRetGerenc, .T.)    
				Else					
					Self:CriarNCN(aTransac[nCount,2],  aTransac[nCount,1],  aTransac[nCount,3], Val(aTransac[nCount,4])/100, .T.) 							 						
				EndIf 
			Next nCount
			
			If lConfirmar
				FreeObj(oRetGerenc)
				oRetGerenc := NIL   
			EndIf
	    EndIf         
	    
	EndIf
		
    // antes de chamar a transacao, apaga arquivos - Resposta
	oGravArq := LJCArquivo():New(Self:oConfigAtual:CDIRRX + 'IntPos.001')
                                     
	If oGravArq:Existe()
		oGravArq:Apagar()
	EndIf 
	
	oGravArq := LJCArquivo():New(Self:oConfigAtual:CDIRRX + 'IntPos.STS')
	
	If oGravArq:Existe()
		oGravArq:Apagar()
	EndIf 

	// antes de chamar a transacao, apaga arquivos - Rec
	oGravArq := LJCArquivo():New(Self:oConfigAtual:CDIRTX + 'IntPos.001')
	
	If oGravArq:Existe()
		oGravArq:Apagar()
	EndIf 

	oGravArq := LJCArquivo():New(Self:oConfigAtual:CDIRTX + 'IntPos.TEMP')
	
	If oGravArq:Existe()
		oGravArq:Apagar()
	EndIf 
	
	oGravArq:Criar()

	For nCount := 1 To Self:oArquivo:Count()
	
		If !oGravArq:Escrever(Self:oArquivo:Elements(nCount))
			STFMessage("TEFDiscado", "STOP", STR0002) //"Nใo ้ possivel Escrever no Arquivo de Envio"
			STFShowMessage( "TEFDiscado")
			lRet := .F.
			Exit
		EndIf
	Next
	
	If lRet
		oGravArq:Fechar()
	
		If oGravArq:Renomear(Self:oConfigAtual:CDIRTX + 'IntPos.001') < 0
			STFMessage("TEFDiscado", "STOP", STR0001) //"Nใo ้ possivel renomear o Arquivo de Envio"
			STFShowMessage( "TEFDiscado")
			lRet := .F.
		EndIf  
		
		FreeObj(oGravArq)	
		oGravArq := NIL	
	EndIf
	
Return lRet	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณAguardaResp  บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAguarda Resposta da Transacao                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method AguardaResp(cSeqArq) Class LJAComDiscado
	
	Local oArqRes 		:= LJCArquivo():New(Self:oConfigAtual:CDIRRX + 'IntPos.001')  //Arquivo de Resposta
	Local lTemResposta	:= Self:TemResposta(Self:oConfigAtual:CDIRRX + 'IntPos.001', , cSeqArq)	//Tem resposta
	Local oValArqRes  	:= Nil //Objeto do Arquivo
	Local nCount		:= 0  //Contador
	
	Default cSeqArq := ""

	If lTemResposta
	
		oArqRes:Abrir()		
		
		oValArqRes := oArqRes:Ler()
		
		For nCount := 1 To  oValArqRes:Count() 
			
			Do Case
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "000-000"
					Self:oRetGerenc:C000 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "001-000"
					Self:oRetGerenc:C001 := AllTrim(SubStr(oValArqRes:Elements(nCount):cLinha,11,99))
					lNumOpDif := Self:CompNOp(cSeqArq, Self:oRetGerenc:C001 )
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "003-000"
					Self:oRetGerenc:C003 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)				
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "004-000" // novo
					Self:oRetGerenc:C004 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "005-000" // novo
					Self:oRetGerenc:C005 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
	
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "006-000"
					Self:oRetGerenc:C006 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "007-000"
					Self:oRetGerenc:C007 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "008-000"
					Self:oRetGerenc:C008 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "009-000"
					Self:oRetGerenc:C009 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "010-000"
					Self:oRetGerenc:C010 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "011-000"
					Self:oRetGerenc:C011 := AllTrim(Str(Val(SubStr(oValArqRes:Elements(nCount):cLinha,11,99))))
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "012-000"
					Self:oRetGerenc:C012 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "013-000"
					Self:oRetGerenc:C013 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "014-000"
					Self:oRetGerenc:C014 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "015-000"
                	Self:oRetGerenc:C015  := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)	
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "016-000"
					Self:oRetGerenc:C016 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "017-000"
					Self:oRetGerenc:C017 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "018-000"
					Self:oRetGerenc:C018 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณRetorno com listaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "019-"
					
					While SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "019-"
				
						Self:oRetGerenc:o019:Add(SubStr(oValArqRes:Elements(nCount):cLinha,11,99))
				
						nCount ++
					End		

					nCount := nCount - 1

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "020-"
					
					While SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "020-"
				
						Self:oRetGerenc:o020:Add(SubStr(oValArqRes:Elements(nCount):cLinha,11,99))
				
						nCount ++
					End		

					nCount := nCount - 1
	
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "021-"
					
					While SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "021-"
				
						Self:oRetGerenc:o021:Add(SubStr(oValArqRes:Elements(nCount):cLinha,11,99))
				
						nCount ++
					End		

					nCount := nCount - 1
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "022-"
					
					Self:oRetGerenc:c022 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "023-"
									
					Self:oRetGerenc:c023 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "024-000"
					Self:oRetGerenc:C024 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "025-000"
					Self:oRetGerenc:C025 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "026-000"
					Self:oRetGerenc:C026 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "027-000"
					Self:oRetGerenc:C027 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "028-000"
					Self:oRetGerenc:C028 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณRetorno com listaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "029-"
					
					While SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "029-"
				
						Self:oRetGerenc:o029:Add(STRTRAN(SubStr(oValArqRes:Elements(nCount):cLinha,11,99), '"', '' ))
				
						nCount ++
					End		

					nCount := nCount - 1
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "030-"
					Self:oRetGerenc:C030 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)  
					
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "032-"
					Self:oRetGerenc:C032 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)   
					
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "033-"
					Self:oRetGerenc:C033 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "034-"
					Self:oRetGerenc:C034 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99) 
					
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "035-"
					Self:oRetGerenc:C035 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)     

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "036-"
					Self:oRetGerenc:C036 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)     
								
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "037-"
					Self:oRetGerenc:C037 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)     
								
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "038-"
					Self:oRetGerenc:C038 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99) 
					
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "039-"
					Self:oRetGerenc:C039 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)     

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "040-"
					Self:oRetGerenc:C040 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99) 
					
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "701-"
					Self:oRetGerenc:C701 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)  
										
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "701-"
					Self:oRetGerenc:C701 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "702-"
					Self:oRetGerenc:C702 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "703-"
					Self:oRetGerenc:C703 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "704-"
					Self:oRetGerenc:C704 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "705-"
					Self:oRetGerenc:C705 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "706-"
					Self:oRetGerenc:C706 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "707-"
					Self:oRetGerenc:C707 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)					 					
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "708-"
					Self:oRetGerenc:C708 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "709-"
					Self:oRetGerenc:C709 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)										
				
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "710-"
					Self:oRetGerenc:C710 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)					
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณRetorno com listaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "711-"
					//Caso somente venha essa informa็ใo do cartใo, envio o texto para mostrar que ้ a via do cliente
					Self:oRetGerenc:o711:Add("*** VIA DO CLIENTE ***")
					
					While SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "711-"
				
						Self:oRetGerenc:o711:Add(STRTRAN(SubStr(oValArqRes:Elements(nCount):cLinha,11,99), '"', '' ))
				
						nCount ++
					End
					
					//Tracejado para "corte"
					Self:oRetGerenc:o711:Add(Replicate("-",35))

					nCount := nCount - 1    

				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "712-"
					Self:oRetGerenc:C712 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
										
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "713-"
					
					While SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "713-"
				
						Self:oRetGerenc:o713:Add(STRTRAN(SubStr(oValArqRes:Elements(nCount):cLinha,11,99), '"', '' ))
				
						nCount ++
					End		

					nCount := nCount - 1   
					
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "714-"
					Self:oRetGerenc:C714 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
						   
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "715-"
					
					While SubStr(oValArqRes:Elements(nCount):cLinha,1,4)== "715-"
				
						Self:oRetGerenc:o715:Add(STRTRAN(SubStr(oValArqRes:Elements(nCount):cLinha,11,99), '"', '' ))
				
						nCount ++
					End		

					nCount := nCount - 1  		
					
				Case SubStr(oValArqRes:Elements(nCount):cLinha,1,4) == "716-"
					Self:oRetGerenc:C716 := SubStr(oValArqRes:Elements(nCount):cLinha,11,99)
										
			EndCase		
		Next
				
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se a transacao foi ok e exibi menssagem   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If 	Self:oRetGerenc:C009 == '0' 	.OR. ;
			Self:oRetGerenc:C009 == '00'  	.OR. ;
			Self:oRetGerenc:C009 == '000' 
			
				Self:CriarBck(@oArqRes, IIF(!Empty(Self:oRetGerenc:C028) .AND. Val(Self:oRetGerenc:C028) > 0,_DISCADO_PENDENTE ,_DISCADO_APROVADA) )  
		
		Else
	        If !Alltrim(Self:oRetGerenc:C030) == ''

				STFMessage("TEFDiscado", "ALERT", Self:oRetGerenc:C030)
				STFShowMessage( "TEFDiscado")
			 EndIf
			
			oArqRes:Fechar()
			oArqRes:Apagar()
   		
   		EndIf 
   		
   		FreeObj(oValArqRes)
	
	EndIf  
	
	FreeObj(oArqRes)
	oArqRes := NIL

Return	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCriarCNF     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfirma Transacao										  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1                                                       บฑฑ
ฑฑบ          ณDados da DA confirmacao da transacao                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method CriarCNF(oDadosCNF, lAtivo, cCampo001) Class LJAComDiscado

Local  nSeqArq  //Sequencia do Arquivo
Local oArqIntPos	:= LJCArquivo():New(GetClientDir() + "intpos."+oDadosCNF:cNsu) 	// Objeto resp. p guarda resumo das trans
Local aTransac		:= {} //Array de transacoes

Default oDadosCNF := Nil 
Default lAtivo	  := .F. 
			
// Ativa Gerenciador
If !lAtivo
	Self:GerenciadorAtv(!Empty(cPrefixo001)) 
EndIf

// gera sequencia   
If cCampo001 == NIL
	nSeqArq := Self:ProxIdTrn() 
	cCampo001 := ALLTRIM(StrZero(nSeqArq,10))
EndIf

//Intacia Classe para gerar lista de envio
Self:oArquivo := LJCList():New()	

//Criar lista com os dados do arquivo da transacao
Self:oArquivo:ADD("000-000 = CNF" )						// 	Tipo de tranzacao
Self:oArquivo:ADD("001-000 = " + cCampo001 ) 			//	Identifica็ใo da tranzacao
Self:oArquivo:ADD("010-000 = " + oDadosCNF:cRede) 						//	NOME DA REDE
Self:oArquivo:ADD("012-000 = " + oDadosCNF:cNsu) 						//	nsu
Self:oArquivo:ADD("027-000 = " + oDadosCNF:cFinalizacao) 				//	finalizacao
Self:oArquivo:ADD("999-999 = 0")

//Chama a transacao
If Self:ChamaTrans(.T.)   .AND.  Self:TemResposta(Self:oConfigAtual:CDIRRX + 'IntPos.STS', 20, cCampo001)

    aTransac := Self:LerArqPend()
    
    Self:AtuStatus(@aTransac,oDadosCNF:cNsu, _DISCADO_CONFIRMADA)
    
    Self:GravarArqpend(aTransac) 
    
	// caso nao existi arquivo nao apaga
	If oArqIntPos:Existe()
		oArqIntPos:Apagar()
	EndIf
		
EndIf	

FreeObj(oArqIntPos)
oArqIntPos := NIL
	
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriarATV     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o gerenciador padrao esta ativo                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CriarATV(lPendente, lConfirmar ) Class LJAComDiscado

    Local lRet	:= .F.
    
	Default lPendente := .F. //Permitir transacoes pendentes?  
	Default lConfirmar := .T. //confirma a transacao
	
	
	Self:oArquivo := LJCList():New()
		
	
	Self:oArquivo:ADD("000-000 = ATV" )			// Tipo de tranzacao
	Self:oArquivo:ADD("001-000 = 9")				// Identifica็ใo da transacao

	//Se Chama a transacao Ok, Aguarda Resposta
	If Self:ChamaTrans(lPendente, lConfirmar)	
		lRet := Self:TemResposta(Self:oConfigAtual:CDIRRX + 'IntPos.STS', 20, "9")
	EndIf

Return lRet
             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriarNCN     บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCancela transacao caso seja encerrado no meio               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1                                                       บฑฑ
ฑฑบ          ณNsu da transacao                                            บฑฑ
ฑฑบ          ณEXPC2                                                       บฑฑ
ฑฑบ          ณNome da rede da transacao                                   บฑฑ
ฑฑบ          ณEXPC3                                                       บฑฑ
ฑฑบ          ณCodigo da finalizacao retornada pelo GP                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CriarNCN(cNsu, cNomeRede, cFinalizacao, nValor, lAtivo, cCampo001) Class LJAComDiscado

	Local  nSeqArq      //Sequencia do Arquivo
	Local oArqIntPos	:= LJCArquivo():New(GetClientDir() + "intpos."+cNsu) 	// Objeto resp. p guarda resumo das trans
	Local aTransac := {} //Transa็๕es
	
	Default lAtivo := .F. 

				
	// Ativa Gerenciador
	If !lAtivo
		Self:GerenciadorAtv(!Empty(cCampo001))   
	EndIf
	
	// gera sequencia
	If cCampo001 = NIL
		nSeqArq := Self:ProxIdTrn()  
		cCampo001 :=  ALLTRIM(StrZero(nSeqArq,10))
	EndIf
	
	//Intacia Classe para gerar lista de envio
	Self:oArquivo := LJCList():New()	

    //Criar lista com os dados do arquivo da transacao
	Self:oArquivo:ADD("000-000 = NCN" )										// 	Tipo de tranzacao
	Self:oArquivo:ADD("001-000 = " + cCampo001 ) 			//	Identifica็ใo da tranzacao 
	If nValor > 0  
		Self:oArquivo:ADD("003-000 = " + AllTrim(StrTran(StrTran(Transform(nValor, "@E 999,999,999.99"),",",""), ".", "") ) )
	EndIf
	Self:oArquivo:ADD("010-000 = " + cNomeRede) 						//	NOME DA REDE
	Self:oArquivo:ADD("012-000 = " + cNsu) 						//	nsu
	Self:oArquivo:ADD("027-000 = " + cFinalizacao) 				//	finalizacao
	Self:oArquivo:ADD("999-999 = 0")
	
	//Chama a transacao
	//Chama a transacao
	If Self:ChamaTrans(.T.) .AND. Self:TemResposta(Self:oConfigAtual:CDIRRX + 'IntPos.STS', 20, cCampo001)

	    aTransac := Self:LerArqPend()
	    
	    Self:AtuStatus(@aTransac, cNsu, _DISCADO_NAO_CONFIRMADA)
	    
	    Self:GravarArqpend(aTransac)
	    
		// caso nao existi arquivo nao apaga
		If oArqIntPos:Existe()
			oArqIntPos:Apagar()
		EndIf	
		
        STFMessage("TEFDiscado", "OK",STR0003 						  								+ CHR(13) + CHR(10) + 	; //"ฺltima transa็ใo TEF foi cancelada"
						   	"Rede: " + cNomeRede								 					   			+ CHR(13) + CHR(10) + 	;
							IIf(nValor == 0, "", "NSU: " + cNsu)  							+ CHR(13) + CHR(10) + 	;
							"Valor: " + Transform(nValor, "@E 999,999,9999,999.99"),;
							"Aten็ใo") 
		STFShowMessage("TEFDiscado")
		
	EndIf	
	
    FreeObj(oArqIntPos)
    oArqIntPos := NIL

Return Self


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGerenciadorAtv บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o gerenciador padrao esta ativo                   บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GerenciadorAtv(lPendente, lConfirmar) Class LJAComDiscado

	Local lRet := .F.     // Retorno   
	
	Default lPendente := .F. //Permitir transacoes pendentes?  
	Default lConfirmar := .T. //confirma a transacao

	While lRet == .F.
        

		STFMessage("TEFDiscado", "RUN",STR0004,; //Verificando se o gerenciador padrใo do TEF discado estแ ativo."
				 { || lRet := Self:CriarATV(lPendente, lConfirmar) }) //"Verificando se o gerenciador padrใo " " do TEF discado estแ ativo." "Aguarde"
		
		STFShowMessage("TEFDiscado")
		// Verifica se ้ temnal service
		If !lRet  .AND. !SuperGetMV("MV_LJTSC") 
			
			STFMessage("TEFDiscado", "ALERT",STR0005)					 //"Gerenciador padrใo nใo esta ativo e serแ ativado automaticamente"
			STFShowMessage("TEFDiscado")
			WinExec(Self:oConfigAtual:CAPLICACAO,3)

			Inkey(5)
			Loop
		
		ElseIf !lRet
			
			STFMessage("TEFDiscado", "STOP",STR0006)					 //"O gerenciador padrao do TEF discado  nao esta ativo"
			STFShowMessage("TEFDiscado")

			lRet := .F.
			Return lRet
		
		Endif
	
	End	

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTemResposta    บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEspera se o Gerenciador padrao vai responder e se o arquivo   บฑฑ
ฑฑบ          ณrecebido ้ o enviado                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TemResposta(cFile, ntTimeOut, cSeqArq) Class LJAComDiscado
		
	Local lRet 		:= .F.  //Retorno da fun็ใo
	Local nSecIni 	:= Seconds() //Inicio da execu็ใo
	Local lTimeOut  := .F.    //timeOut
	Local oArqRes 		:= NiL //Arquivo de resposta
	Local oValArqRes  	:= Nil //Arquivo de resposta
	Local nCount		:= 0 	//Contador

	Default ntTimeOut := 900
		
	While !lRet
		If (( Seconds() - nSecIni ) > ntTimeOut)
			lRet := .F.
			lTimeOut := .T.
			Exit
		Else
			If File(cFile)
			 
				oArqRes 		:= LJCArquivo():New(cFile)
				oArqRes:Abrir()
				oValArqRes := oArqRes:Ler()
				For nCount := 1 To  oValArqRes:Count() 
					If SubStr(oValArqRes:Elements(nCount):cLinha,1,7) == "001-000" 
						lRet := Self:CompNOp(cSeqArq, AllTrim(SubStr(oValArqRes:Elements(nCount):cLinha,11,99)) ) 
						Exit  						
					EndIf
				Next nCount
				    	
		        FreeObj(oValArqRes)	 
				oArqRes:Fechar()  
							
				If !lRet //Nใo achou apaga e aguarda o retorno
					oArqRes:Apagar()
				Else
					FreeObj(oArqRes)
					Exit
				EndIf
				FreeObj(oArqRes) 
				
			EndIf
		Endif
		Sleep(50)											// Pausa para nao consumir muitos recursos do processador
	End

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProxIdTrn      บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega proxima transa็ใo                                        บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ProxIdTrn() Class LJAComDiscado

Local nRet := 0	// Retorno
		
	nRet := GetMv("MV_TEFNSTR",,0) + 1
	PutMv("MV_TEFNSTR",AllTrim(Str(nRet)))


Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณSetTrans       บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega proxima transa็ใo                                        บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1                                                         บฑฑ
ฑฑบ          ณTransacao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method SetTrans(oTransacao)	Class LJAComDiscado
	
Self:oTransacao  	:= oTransacao
Self:oRetGerenc     := LJCRetornoGerenciador():New()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณInicializaConf บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega proxima transa็ใo                                        บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method InicializaConf()	Class LJAComDiscado
	
	Local oBackCfgAtu 	:= Self:oConfigAtual 	// Faz bacckup da confg Atual
	Local nCont			:= 0 					// Contador
	
	For nCont := 1 To Self:oConfig:Count()
		
		Self:oConfigAtual := Self:oConfig:Elements(nCont)
		// Ativa Gerenciador
		//Verifica transacoes pendentes e desfaz  
		//
		
		Self:GerenciadorAtv(.t.) //Verifica se existe transacoes pendentes e desfaz 
	    
			
	
	Next
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAO finalizar, restaura configura็ใo atualณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Self:oConfigAtual := oBackCfgAtu

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaBck		 บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria Back de resposta 	                                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1                                                         บฑฑ
ฑฑบ          ณArquivo de resposta                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CriarBck(oArqRes, cStatus)	Class LJAComDiscado

	Local oArqNcncnf	:= LJCArquivo():New(GetClientDir() + "ncncnf.001") 	// Objeto resp. p guarda resumo das trans
	Local aTransac		:= {} //Array de transacoes
	
	
	oArqRes:Fechar()	
	oArqRes:Copiar(GetClientDir() + "IntPos."+ Self:oRetGerenc:C012)
						

	//Ler arquivos com transacoes pendentes
	
	aTransac := Self:LerArqPend()
	
	If !Self:AtuStatus(@aTransac, Self:oRetGerenc:c012, cStatus)
		aAdd( aTransac, { Self:oRetGerenc:C010,;   //1
		 				 Self:oRetGerenc:c012,;    //2
		 				 Self:oRetGerenc:c027,;    //3
		 				 Self:oRetGerenc:c003,;    //4
		 				 Self:oRetGerenc:c001,;    //5
		 				 Self:oRetGerenc:c022,;    //6  
		 				 Self:oRetGerenc:c023,;  //7
					     cStatus			 ,;  //8
					     Self:oRetGerenc:c000,; //9
					     Self:oRetGerenc:c005,; //10
					     Self:oRetGerenc:c006,;  //11
					     Self:oRetGerenc:c007,;  //12 
					     Self:oRetGerenc:c033,;  //13
					     Self:oRetGerenc:c034,;  //14
					     Self:oRetGerenc:c035,;  //15
					     Self:oRetGerenc:c036,;  //16
					     Self:oRetGerenc:c037,;  //17
					     Self:oRetGerenc:c038,;  //18
					     Self:oRetGerenc:c039,;  //19
					     Self:oRetGerenc:c008})  //20
	EndIf
		
    Self:GravarArqpend(aTransac)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApaga arquivo de respostasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oArqRes:Apagar() 
	FreeObj(oArqNcncnf)


Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCompNOp		 บAutor  ณVendas CRM       บ Data ณ  21/01/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria Back de resposta 	                                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1                                                         บฑฑ
ฑฑบ          ณArquivo de resposta                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CompNOp(cSeqArq, c001)	Class LJAComDiscado
Local lRet := .F.

If AllTrim(c001) == AllTrim(cSeqArq)
	lRet := .T.
EndIf

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLerArqPend	 บAutor  ณVendas CRM       บ Data ณ  28/01/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLer Arquivo de Transacoes Pendentes                           บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณEXPA1  - Array de transacoes                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method LerArqPend(cStatus) Class LJAComDiscado
	Local oArqNcncnf	:= LJCArquivo():New(GetClientDir() + "ncncnf.001") 	// Objeto resp. p guarda resumo das trans
	Local aTransac		:= {} //Array de transacoes
	Local nCount		:= 0   //contador
	Local nLinhas		:= 0   //Linhas
	Local oArquivo		:= NIL     //Objeto Arquivo 
	Local aTmp			:= {}	 //Array Temporario
    
	Default cStatus := ""
						
	// caso nao existi arquivo, cria
	If oArqNcncnf:Existe()
		oArqNcncnf:Abrir()
		oArquivo := oArqNcncnf:Ler()

	    nLinhas	    :=  oArquivo:Count()
	
		For nCount := 1 To nLinhas
			
			aTmp :=  StrTokArr(AllTrim(oArquivo:Elements(nCount):cLinha ), ";")  
			
			If Empty(cStatus) .OR. aTmp[8] == cStatus
				
		    	aAdd(aTransac, aTmp)  
		    	   
		    EndIf
		
		Next nCount
		
		oArqNcncnf:Fechar()  
		
		FreeObj(oArquivo)    
		                   
    EndIf 
    
    FreeObj(oArqNcncnf)
    
Return aTransac 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLocArqPend	 บAutor  ณVendas CRM       บ Data ณ  28/01/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLocaliza Arquivo de Transacoes Pendentes                      บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณEXPN1  - Posicao do Arquivo                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Method LocArqPend(aTransac, cNsu) Class LJAComDiscado  
	Local nPos :=  aSCan(aTransac, {|c| c[2] == cNsu})

Return nPos      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuStatus   	 บAutor  ณVendas CRM       บ Data ณ  28/01/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o Status de Transacoes Pendentes                     บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณEXPL1  - Atualizado                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method AtuStatus(aTransac, cNsu, cStatus) Class LJAComDiscado
	Local lAtu := .F.
	Local nPos := Self:LocArqPend(aTransac, cNsu)
	
	If nPos > 0
		aTransac[nPos, 8] := cStatus 
		lAtu := .T.
	EndIf

Return lAtu


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณGravarArqpend()บAutor  ณVendas CRM       บ Data ณ  28/01/2013 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o arquivo de Transacoes Pendentes                     บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณEXPL1  - Atualizado                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Method GravarArqpend(aTransac) Class LJAComDiscado      

	Local oArqNcncnf	:= LJCArquivo():New(GetClientDir() + "ncncnf.001") 	// Objeto resp. p guarda resumo das trans
	Local nCount		:= 0   //Contador
	Local nLinhas		:= 0  //Linhas
	Local cTemp			:= ""  //temporario
	Local nLinha		:= 0   //Linha
	Local nC			:= 0  //contador
	Local cVirgula		:= ";" //Delimitador
	
	If oArqNcncnf:Existe()
		oArqNcncnf:Apagar()
	EndIf 
	
	nLinhas := Len(aTransac)
	
	oArqNcncnf:Criar()  
	
	For nCount := 1 to nLinhas
		
		nLinha := Len(aTransac[nCount])   
		
		cTemp := ""
		
		For nC := 1 to nLinha
			cTemp := cTemp + IIF(Empty(aTransac[nCount, nC]), space(1), aTransac[nCount, nC])  + cVirgula
		Next nC  
		
	
		oArqNcncnf:Escrever(cTemp)
	
	Next nCount
	
	oArqNcncnf:Fechar()
	FreeObj(oArqNcncnf)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LjIsVndVou
Valida็ใo para venda D้bito ou Voucher.
@return lLjVndVouc , logico, venda voucher ativa  
@author  julio.nery
@since   23/07/2018
/*/
//-------------------------------------------------------------------
Static Function LjIsVndVou()
Local nMV_LJCDVOU := SuperGetMV("MV_LJCDVOU",,0)
Local lMV_LJCDVOU := ValType(nMV_LJCDVOU) == "N" .And. nMV_LJCDVOU == 1

LjGrvLog("TEF_DISCADO_2_00", "Verifica็ใo de venda voucher - Parโmetro MV_LJCDVOU" + CHR(10) + CHR(13)+;
							"Ativa็ใo/Desativa็ใo de venda voucher - vide documenta็ใo "+;
							"em [http://tdn.totvs.com/display/public/PROT/DT+MV_LJCDVOU]", nMV_LJCDVOU)

If lLjVndVouc == NIL .Or.;
 (ValType(lLjVndVouc) == "L" .And. lLjVndVouc <> lMV_LJCDVOU)

	lLjVndVouc := lMV_LJCDVOU
EndIf

Return lLjVndVouc

//-------------------------------------------------------------------
/*/{Protheus.doc} LjOpcVouc
Baseada na fun็ใo Lj010GtOpc
Fun็ใo para mostrar a op็ใo de D้bito ou Voucher.
@param aCartoes, array, dados da venda para tela
@param nTipo, numerico, tipo de tela que serแ gerado
@return  cRet,string,retorno do c๓digo de venda cartใo
@author  eduardo.sales
@since   24/11/2017
/*/
//-------------------------------------------------------------------
Static Function LjOpcVouc(aCartoes, nTipo)
Local oDlg
Local lConfirm 		:= .F.
Local cRet	 		:= ""
Local oFont 		:= TFont():New("Courier",,-15,.T.)
Local aBotoes 		:= {}
Local cCaption 		:= ""
Local cToolTip		:= ""
Local nTamTitBot	:= 0
Local nLinhaObj		:= 15
Local nColunaObj	:= 25
Local nBotLargur	:= 150
Local nBotAltura	:= 18
Local nInd 			:= 0
Local bBlocoCmd 	:= {|| Nil}
Local cOpcao 		:= Space(1)
Local nOpcoes 		:= 0

//Botoes
// 				Titulo do botao   	ToolTip
AAdd( aBotoes, { "D้bito"			, "Efetua a venda com D้bito" 	} ) // "D้bito"
AAdd( aBotoes, { "Voucher"			, "Efetua a venda com Voucher"	} ) // "Voucher"

aEval( aBotoes, { |x| nTamTitBot := If(Len(x[1]) > nTamTitBot, Len(x[1]), nTamTitBot)} )

/*-----------------------------------------------------------------------
	Monta a tela para a escolha do tipo de cartใo (D้bito / Voucher)
-----------------------------------------------------------------------*/
DEFINE MSDIALOG oDlg TITLE "Discado/Pay&Go - Tipo de Cartใo" FROM 00,00 TO 15,50 STYLE DS_MODALFRAME 
@ 005,005 TO 110,195 LABEL "Informe o tipo de cartใo para:" OF oDlg PIXEL

oDlg:lEscClose	:= .F.	// Desabilita a tecla ESC

If nTipo == 1
	@ nLinhaObj		, nColunaObj SAY "ID da Transa็ใo: " + aCartoes[3] OF oDlg PIXEL
	@ nLinhaObj + 7	, nColunaObj SAY "Parcela: " + AllTrim(Str(aCartoes[1])) OF oDlg PIXEL
	@ nLinhaObj + 14, nColunaObj SAY "Valor: R$ " + AllTrim(Str(aCartoes[2])) OF oDlg PIXEL
Else
	@ nLinhaObj		, nColunaObj SAY "Data TEF: " + aCartoes[3] OF oDlg PIXEL
	@ nLinhaObj + 7	, nColunaObj SAY "NSU: " + aCartoes[4] OF oDlg PIXEL
	@ nLinhaObj + 14, nColunaObj SAY "Parcela: " + AllTrim(Str(aCartoes[1])) OF oDlg PIXEL
	@ nLinhaObj + 21, nColunaObj SAY "Valor: R$ " + AllTrim(Str(aCartoes[2])) OF oDlg PIXEL

	nLinhaObj := nLinhaObj + 5
EndIf

nLinhaObj := nLinhaObj + 25

For nInd := 1 To Len(aBotoes)
	cCaption 	:= StrZero(nInd,1) + "-" + PadR(aBotoes[nInd][1], nTamTitBot) 				// Titulo do Botao
	cToolTip 	:= aBotoes[nInd][2] 														// Mensagem ToolTip do botao
	bBlocoCmd	:= &("{|| (lConfirm:=.T.,cOpcao:='" + StrZero(nInd,1) + "',oDlg:End()) }") 	// Bloco de comando do botao
	
	//Monta o Botao
	TButton():New( nLinhaObj, nColunaObj, cCaption, oDlg, bBlocoCmd, nBotLargur,;
	 				nBotAltura, , oFont, .F., .T., .F., cToolTip, .F., , , .F. )
	nLinhaObj := nLinhaObj + 20
Next nInd

nOpcoes 	:= nInd - 1
nLinhaObj 	:= nLinhaObj + 5

@ nLinhaObj + 2, nColunaObj SAY "Op็ใo:" OF oDlg PIXEL
oGetOpc := TGet():New(nLinhaObj,nColunaObj+20,bSETGET(cOpcao),oDlg,010,010,,;
		{|| If( Empty(cOpcao), .T., If(LjVlOpcVou(cOpcao,nOpcoes), (lConfirm:=.T.,oDlg:End()), .F.) ) },,,,,,.T.,,,,,,,.F.,,,)

oGetOpc:SetFocus()

ACTIVATE MSDIALOG oDlg CENTERED

If lConfirm
	Do Case
	    // Venda com D้bito
		Case cOpcao == "1"
			cRet := "2"
			
	    // Venda com Voucher
		Case cOpcao == "2"
			cRet := "3"
	EndCase
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjVlOpcVou
Fun็ใo para validar a op็ใo.
@param cOpcao
@param nOpcoes
@return  
@author  eduardo.sales
@since   24/11/2017
/*/
//-------------------------------------------------------------------
Static Function LjVlOpcVou(cOpcao, nOpcoes)
Local lRet 		:= .T.
Local cValidos 	:= "12" 	//Valores Validos
Local nInd 		:= 1

cOpcao := AllTrim(cOpcao)

While nInd <= Len(cOpcao)
	If !(SubStr(cOpcao,nInd,1) $ cValidos)
		MsgAlert("Op็ใo invแlida!") //"Op็ใo invแlida!"
		lRet := .F.
		Exit
	EndIf
	nInd++
End

If lRet
	If Val(cOpcao) < 1 .Or. Val(cOpcao) > nOpcoes
		MsgAlert("Op็ใo invแlida!") //"Op็ใo invแlida!"
		lRet := .F.
	EndIf
EndIf

Return lRet
