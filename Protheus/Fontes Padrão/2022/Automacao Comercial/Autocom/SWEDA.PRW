#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Classe   ³ LJSweda  ºAutor  ³ Adrianne Furtado   º Data ³  xx/xx/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Classe da impressora Sweda para a biblioteca AUTOCOM       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Analista ³ Data   ³BOPS  ³Descricao	  	 							  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºA.Veiga   ³25/08/05³      ³Homologacao Software Express FrontLoja Linuxº±±
±±º          ³        ³      ³Revisao geral em todos os metodos e funcoes º±±
±±ºThiago H. ³04/05/06³97894 ³Alteracao no metodo IFREGITEM               º±±
±±º          ³        ³      ³substituida a chamada da funcao LENGTH() porº±±
±±º          ³        ³      ³Len()                                       º±±
±±ºThiago H. ³07/02/07³118810³Alterado o metodo IFAutentic()para correcao º±±
±±º          ³        ³      ³do problema encontrado no momento de realizaº±±
±±º          ³        ³      ³a segunda autenticacao na rotina de         º±±
±±º          ³        ³      ³RECEBIMENTO DE TITULOS					  º±±
±±ºThiago H. ³07/02/07³118810³Alterado o metodo IFReducaoZ()para correcao º±±
±±º          ³        ³      ³do problema encontrado no momento de realizaº±±
±±º          ³        ³      ³a reducao Z numa impressora inoperante por  º±±
±±º          ³        ³      ³mais de 30 dias        					  º±±    
±±ºMauro S.  ³20/04/07³124739³Corrigida chamada da SubStr na FindAliquota º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS LJSweda
	DATA cBuffer
    DATA Aliquotas
    DATA ICMS     
    DATA ISS      
    DATA FormasPgto
    DATA Pdv       
    DATA NumCaixa  

    DATA cCmd293
    DATA cCmd294
    DATA cCmd295
    DATA cCmd296
    DATA nUltimoSeq
    DATA nSeqAtual
	DATA cArqCmd
	DATA cArqRet
	DATA cArqRen	
	DATA cVinculado
	
    // Descricoes das mensagens do cupom
	METHOD New()
    //Funcoes da Impressora Fiscal
	METHOD IFAbrir		(cModelo, cPorta) 
	METHOD IFFechar		(cPorta)
	METHOD IFAbrECF		()
	METHOD IFFchECF		()
	METHOD IFLeituraX	()
	METHOD IFReducaoZ	(cMapaRes)
	METHOD IFStatus		(cTipo)	
	METHOD IFLeAliq  	()
	METHOD IFLeAliIss	() 
	METHOD IFLeConPag	() 
	METHOD IFMemFisc 	(cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo)	
	METHOD IFAdicAliq	(cAliquota, cTipo)
	METHOD IFAbrCNFis	(cCondicao, cValor, cTotalizador, cTexto)
	METHOD IFTxtNFis	(cTexto, nVias)
	METHOD IFFchCNFis	()
	METHOD IFAutentic	(cVezes, cValor, cTexto)
	METHOD IFSupr		(nTipo, cValor, cForma, cTotal, cModo)
	METHOD IFGaveta		()	
	METHOD IFHrVerao	(cTipo)
	METHOD IFPegSerie	()
	METHOD IFPedido		(cTEF, cTexto, cValor, cCondPgTEF)
	METHOD IFRecbNFis	(cTotalizador, cValor, cForma)
	METHOD IFAbreCup 	(cCliente)
	METHOD IFAlimProp	()
	METHOD IFRegItem 	(cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade)
	METHOD IFPagto		(cPagto, cVinculado, nVlrTotal, aImpsSL1)
	METHOD IFFechaCup	(cMensagem)
	METHOD IFPegCupom	(cCancelamento)
	METHOD IFCancItem	(cNumItem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota)
	METHOD IFCancCup	(cSupervisor)
	METHOD IFDescTot	(cVlrDesconto)
	METHOD IFAcresTot	(cVlrAcrescimo)
	METHOD IFRelGer		(cTexto, nVias)
	METHOD IFPegPDV		()   

    //Funcoes da Impressora de cheque
	METHOD ChStatus		(cTipo)
	METHOD CHImprime	(cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela )
	METHOD CHAbrir		(cModelo, cPorta)
	METHOD CHFechar		(cPorta)
	
	METHOD PulaLinha	(nNumero)
	METHOD EnviaComando	(cComando, cBuffer)
	METHOD EnviaCmd1 (cComando, cBuffer)	
	METHOD EnvCmdEspera	(cTexto, nVezes)
	METHOD TrataRetorno	(nTipo, cTexto)
	METHOD TrataRet		(cRetorno)
	METHOD AchaPagto 	(cForma, aFormas)
	METHOD EmiteReducaoZ(cData, cRetorno)	
	METHOD PegaRegistro	(cCondicao)
	METHOD IsECFOnLine	(lTryAgain)
ENDCLASS

//-------------------------------------------------------------
METHOD New() CLASS LJSweda    
Return

//-------------------------------------------------------------
METHOD IFAbrir(cModelo, cPorta) CLASS LJSweda
Local nRet 
Local cDirRmt

Conout("SWEDA 7000 - METHOD IFAbrir - Inicio - "+ Time() )

cDirRmt := GetClientDir()
::cArqCmd := cDirRmt +"sweda/eq.ms"
::cArqRet := cDirRmt +"sweda/eq.rsp"
::cArqRen := cDirRmt +"sweda/eq.msg"

cPorta := SubStr(cPorta,4,1)
If oAutocom:cPlataforma == "WINDOWS"
	nRet:= ExecDLL("Sweda_FI_AbrePortaSerial",{cPorta})
Else    
	// Este comando e executado pela Swedanix
	nRet := 0
EndIf         

If bRet := (nRet == 0)
	// Envia um comando somente para ver se a impressora está ou não respondendo.
	cRet := ::EnviaComando( Chr(27)+".28}") 
	If At("-P002",cRet) > 0
		bRet := .F.
	EndIf
EndIf

// Carrega as aliquotas para ganhar performance
If bRet
    ::IFAlimProp() //Alimenta Properties
Else
	MsgStop("Erro na abertura da porta")  
	nRet := -1
EndIf

Conout("SWEDA 7000 - METHOD IFAbrir - Termino - "+ Time() )

Return(nRet)

//-------------------------------------------------------------
METHOD IFFechar(cPorta) CLASS LJSweda
Local nRet 

Conout("SWEDA 7000 - METHOD IFFechar - Inicio - "+ Time() )

If oAutocom:cPlataforma == "WINDOWS"
	nRet:= ExecDLL("Sweda_FI_FechaPortaSerial")
Else
	nRet := 0
EndIf
If nRet <> 0
	MsgStop("Erro no fechamento da porta")
EndIf

Conout("SWEDA 7000 - METHOD IFFechar - Termino - "+ Time() )

Return(nRet)

//-------------------------------------------------------------
METHOD IFLeituraX() CLASS LJSweda
Local cRet
Local nVezes	:= 0
Local cResp   
Local nResp 	:= 1

Conout("SWEDA 7000 - METHOD IFLeituraX - Inicio - "+ Time() )

cRet := ::EnviaComando(Chr(27)+".13N}")
cRet := ::TrataRetorno(1,cRet) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando ocorre a leitura de informacoes do ECF logo apos a impressao      ³
//³de Leitura X, o Driver de comunicacao (SWECF.DLL ou SWEDANIX) retorna    ³
//³erro enquanto o equipamento estiver imprimindo.                          ³
//³Esse "delay" é para que nenhum outro comando seja enviado enquanto o ECF ³
//³não voltar a responder.                                                  ³
//³Caso nao haja esse bloco, qqr comando enviado na sequencia darah erro.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cRet == '0' //.AND. oAutocom:cPlataforma == "WINDOWS"    
	While nResp == 1 .AND. nVezes <= 15
		Sleep(1000)
		cComando := Chr(27)+".23}"
		cResp := ::EnviaComando(cComando)
		nResp := ::TrataRet(cResp)
		nVezes += 1
	End      
EndIf   

Conout("SWEDA 7000 - METHOD IFLeiruraX - Termino - "+ Time() )

Return(cRet)

//-------------------------------------------------------------
METHOD IFAbrECF() CLASS LJSweda
Return(0)

//-------------------------------------------------------------
METHOD IFPegCupom(cCancelamento) CLASS LJSweda
Local nRet		:= 1
Local cRet
Local cComando

Conout("SWEDA 7000 - METHOD IFPegCupom - Inicio - "+ Time() )

If cCancelamento == "T"     
	cComando := Chr(27)+".28}"
	cRet := SubStr(::EnviaComando(cComando),11,8) 
	If cRet <> " VENDAS "
		oAutocom:cBuffer := "0000"   
		Return(0)
	EndIf
EndIf
    
cComando := Chr(27)+".271}"
cRet := ::EnviaComando(cComando)
nRet := ::TrataRet(cRet)

If nRet == 1
	cComando := Chr(27)+".271}"
	cRet := ::EnviaComando(cComando)
	nRet := ::TrataRet(cRet)
	If nRet == 1
		MsgStop("Erro ao Ler o Numero do Cupom no ECF.") 
		oAutocom:cBuffer := "0000"
	EndIf
EndIf

If nRet == 0
	oAutocom:cBuffer := SubStr(cRet,121,4)+"  "
EndIf

Conout("SWEDA 7000 - METHOD IFPegCupom - Termino - "+ Time() )

Return(nRet)

//-------------------------------------------------------------
METHOD IFFchECF() CLASS LJSweda
Local cRet
Local dDataHoje
Local cDataHoje
Local cComando
oAutocom:cBuffer := Space(0)

Conout("SWEDA 7000 - METHOD IFFchECF - Inicio - "+ Time() )

  MsgRun("Aguarde a impressão da Redução Z...")
  dDataHoje:= dDataBase
  cDataHoje := DToS( dDataHoje )
  cComando := Chr(27)+".14N" + cDataHoje + "}"
  cRet := ::EnviaComando( cComando )
  cRet := ::TrataRetorno( 1, cRet )
  If SubStr(cRet,1,1) == "0"
    Sleep(33000)
    cRet := ::PulaLinha(7)
  EndIf
  
Conout("SWEDA 7000 - METHOD IFFchECF - Termino - "+ Time() )
  
Return Val(cRet)

//-------------------------------------------------------------
METHOD IFDescTot(cVlrDesconto) CLASS LJSweda
Local cRet 
Local cComando

Conout("SWEDA 7000 - METHOD IFDescTot - Inicio - "+ Time() )

  cVlrDesconto := StrTransf(cVlrDesconto,",",".")
  cComando := Chr(27)+".03"+Space(10)+FormataTexto(cVlrDesconto,12,2,2)+"S}"
  cRet := ::EnviaComando( cComando )
  cRet := ::TrataRetorno( 1,cRet )

Conout("SWEDA 7000 - METHOD IFDescTot - Termino - "+ Time() )

Return Val(cRet)

//-------------------------------------------------------------
METHOD IFAcresTot(cVlrAcrescimo) CLASS LJSweda
Local cRet 
Local cComando

Conout("SWEDA 7000 - METHOD IFAcresTot - Inicio - "+ Time() )

  cVlrAcrescimo := AllTrim(StrTransf(cVlrAcrescimo,",","."))
  cComando := Chr(27)+".1151"+Replicate("0",4)+FormataTexto(cVlrAcrescimo,11,2,2)+"S}"
  cRet := ::EnviaComando( cComando )
  cRet := ::TrataRetorno( 1,cRet )
  
Conout("SWEDA 7000 - METHOD IFAcresTot - Termino - "+ Time() )

Return Val(cRet)

//-------------------------------------------------------------
METHOD IFCancItem(cNumItem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota) CLASS LJSweda
Local cRet    
Local cComando

Conout("SWEDA 7000 - METHOD IFCancItem - Inicio - "+ Time() )

  cComando := Chr(27)+".04" + FormataTexto(AllTrim(cNumitem),3,0,2) + "}"
  cRet := ::EnviaComando( cComando )
  cRet := ::TrataRetorno( 1,cRet )
  
Conout("SWEDA 7000 - METHOD IFCancItem - Termino - "+ Time() )  

Return Val(cRet)

//-------------------------------------------------------------
METHOD IFCancCup (cSupervisor) CLASS LJSweda
Local nRet
Local cRet    
Local cComando

Conout("SWEDA 7000 - METHOD IFCancCup - Inicio - "+ Time() )

cComando := Chr(27)+".05}"
cRet := ::EnviaComando( cComando )
nRet := ::TrataRet(cRet)  
Sleep(8000)
If nRet == 0
	cRet := ::PulaLinha(7)
EndIf

Conout("SWEDA 7000 - METHOD IFCancCup - Termino - "+ Time() )

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³IFAbrCNFisºAutor  ³Adrianne            ºData  ³  xx/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre um comprovante nao fiscal	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAdrianne  ³08/07/05 - 811 ³BOPS: 83590 								  º±±
±±º          ³               ³- Implementacao do Recebimento Nao Fiscal   º±±
±±º          ³               ³- Correcao/Melhorias na funcao IFAbrCNFis   º±±
±±º          ³               ³- Correcao na funcao IFTxtNFis, para tratar º±±
±±º          ³               ³  corretamente o numero de vias do compro-  º±±
±±º          ³               ³  vante									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD IFAbrCNFis (cCondicao, cValor, cTotalizador, cTexto) CLASS LJSweda
Local nRet := 1
Local cRet					//Utilizada para receber o retorno dos comandos enviados para a impressora
Local cNumAnt				//Numero do Cupom anterior (COO)
Local nI
Local aFormas	:= {}		//Formas de pagamento cadastradas no ECF
Local cFormas				//Formas de pagamento cadastradas no ECF
Local cPosTot				//Indice do Totalizador
Local nAt
Local nTamanho				//Tamanho da String retornada pelo ECF que devera ser considerada
Local bTotalizadorIsNum     //Informa se em cTotalizador foi passada a 'descricao' ou o 'indice'
Local cTotFormaPagto    	//Indice da forma de pagamento. 
Local cTotRecIni := ""  

Conout("SWEDA 7000 - METHOD IFAbrCNFis - Inicio - "+ Time() )

If AllTrim(cTotalizador) == ""
     cTotalizador := "SIGALOJA"
EndIf

If ::IsECFOnLine(.T.)
	// Pegando o numero do ultimo cupom impresso
	cNumAnt := ::EnviaComando( Chr(27)+".271}" )
	nRet := ::TrataRet(cNumAnt)
	If nRet == 0
	    cNumAnt := SubStr(cNumAnt,14,4)
	EndIf
	// Monta o array aFormas com as condicoes de pagamento do cupom fiscal
	cRet := ::FormasPgto
EndIf

If nRet == 0
	nTamanho := 0
	While (At("|", cRet) > 0) 
		nAt := At("|", cRet)
		cFormas := SubStr(cRet, 1, nAt-1)
		AAdd (aFormas, cFormas)
		cRet := SubStr(cRet, nAt+1, Len(cRet))
	End
	// Verificando qual o codigo da condicao de pagamento utilizado
	cPos := "0"
	For nI := 1 to Len(aFormas)
		If Upper(AllTrim(aFormas[nI])) == Upper(AllTrim(cCondicao))
			cPos := AllTrim(Str(nI))
			nI := Len(aFormas)
		EndIf
	Next nI

	If Len(cPos) < 2 
		cPos := "0" + cPos
	EndIf
	If cPos == "00"
		MsgStop("A finalizadora "+cCondicao+" não foi cadastrada no ECF.")
		nRet := 1
	EndIf
EndIf
If nRet == 0
	// A diferença entre a 1.0 e a 1.A é que a 1.A para fazer cupom vinculado,
	// a finalizadora deve ter a FLAG de VINCULAÇÃO como "S".
	/*If SubStr(::cVinculado, Val(cAt ), 1) == "N" 
	MsgStop("A finalizadora "+cCondicao+" não foi cadastrada como VINCULADA no ECF.")
    cRet := "1|"
	EndIf*/

	// Abrindo cupom nao fiscal vinculado "00"
	cTotRecIni := GetPvProfString("Recarga Celular", "Totalizador", "", GetClientDir()+"SIGALOJA.INI")

	If (cTotRecIni == cTotalizador)
		nRet := 1
	Else
		cRet := ::EnviaComando( Chr(27)+".1900"+cNumAnt+cPos+"}" )
		nRet := ::TrataRet(cRet)
	EndIf		
	If nRet == 1
		cTotFormaPagto := cPos
		cRet	:=" -"
		cValor  := FormataTexto(AllTrim(cValor),12,2,2)
		cRet    :="789ABCD"
		cFormas :=""
		For nI:= 1 to 7 
			cPos     := ::EnviaComando( Chr(27)+".29"+SubStr(cRet,nI,1)+"}" )
			nTamanho := Len(cPos)	
			cFormas  := cFormas+SubStr(cPos,8,nTamanho)
		Next nI
		cFormas := SubStr(cFormas,31,Len(cFormas))    

		nTamanho := 1
		aFormas := {}
		While AllTrim(cFormas) <> ""
			AAdd(aFormas, SubStr(cFormas,1,15))
			cFormas := SubStr(cFormas,16,Len(cFormas))
			nTamanho += 1
		End

		If Val(cTotalizador) > 0//== "C"
			bTotalizadorIsNum := .T.
		Else
			bTotalizadorIsNum := .F.
		EndIf

		cPos       := "0"
		cPosTot    := "0"
		For nI := 1 to Len(aFormas) //	Em Delphi -> For nI := 0 to high(aFormas) do
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo. ³
			//³ Pois a legenda somente podera ser do mesmo titulo.                               ³
			//³ Ex.                                                                              ³
			//³ 01 &GAVETA                -> Titulos                                             ³
			//³ 02    + Recebimento       -> Legendas                                            ³
			//³ 03    - Sangria           -> Legendas                                            ³
			//³ 04 &Sigaloja              -> Titulos                                             ³
			//³ 05    + Entrada Diversas  -> Legendas                                            ³
			//³ 06    - Saidas diversas   -> Legendas                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If bTotalizadorIsNum
				cPos  := cTotalizador
				If SubStr(aFormas[nI],1,1)="&"
					cPosTot:= FormataTexto(Str(nI),2,0,2)
				EndIf
				If FormataTexto(AllTrim(Str(nI)),2,0,2) = AllTrim(cPos)
					Exit
				Else
					cPos := "0"	
				EndIf
						
			Else
				If SubStr(aFormas[nI],1,1)="&"
					cPosTot:= FormataTexto(Str(nI),2,0,2)
				ElseIf AllTrim(Upper(SubStr(aFormas[nI],2,15))) == AllTrim(Upper(cTotalizador))
					cPos := FormataTexto(Str(nI),2,0,2)
					Exit			
				EndIf				
			EndIf

			
		Next nI

		If Len(AllTrim(cPos)) < 2
			cPos := "0" + AllTrim(cPos)
		EndIf
		If Len(AllTrim(cPosTot)) < 2
			cPosTot := "0" + AllTrim(cPosTot)
		EndIf
		// Se não encontrar a forma solicitada, cria o cupom como "FUNDO DE CAIXA"
		If cPos == "0"
			Alert("Totalizador " + cTotalizador + " não encontrado na Impressora Fiscal")
			cRet := "1"
        Else
		// Abre o cupom não vinculado
			oAutocom:cBuffer := Space(128)
			cRet := ::EnvCmdEspera( Chr(27) +".19" + cPosTot + "      }" )
			If cRet = "0" 
				// Faz o recebimento não fiscal
				oAutocom:cBuffer := Space(128)
				cRet := ::EnvCmdEspera( Chr(27) +".07" + cPos + cValor + "}", 3 )
				If cRet = "0" 
					// Totaliza o cupom
					oAutocom:cBuffer := Space(128)
					cRet := ::EnvCmdEspera( Chr(27) +".10" + cTotFormaPagto + cValor+"}", 3 )
					If cRet = "0" 
						// Fecha o cupom indicando que haverá um vinculado
						oAutocom:cBuffer := Space(128)
						cRet := ::EnvCmdEspera( Chr(27) +".12SN}", 3 )
						If cRet = "0" 
							oAutocom:cBuffer := Space(128)
							cRet := ::EnvCmdEspera( Chr(27) +".271}", 10 )
							If cRet = "0" 
								cNumAnt := SubStr( ::cBuffer, 14, 4 )
								oAutocom:cBuffer := Space(128)
								cRet := ::EnvCmdEspera( Chr(27) +".1900"+cNumAnt+cTotFormaPagto+"}", 10 )
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
        EndIf
		nRet := Val(::TrataRetorno( 1, oAutocom:cBuffer ))
	EndIf            
EndIf

Conout("SWEDA 7000 - METHOD IFAbrCNFis - Termino - "+ Time() )

Return(nRet)

//-------------------------------------------------------------
METHOD IFFchCNFis () CLASS LJSweda
Local cRet 		:= 	"1"
Local cComando

Conout("SWEDA 7000 - METHOD IFFchCNFis - Inicio - "+ Time() )

cComando := Chr(27)+".12}"
cRet := ::EnviaComando( cComando )

Conout("SWEDA 7000 - METHOD IFFchCNFis - Termino - "+ Time() )
  
Return Val(cRet)

//-------------------------------------------------------------
METHOD IFFechaCup (cMensagem)CLASS LJSweda
Local nRet 		:= 1
Local cRet 
Local cLinha 
Local cCmd 	 	:= ""
Local nLinha 	:= 0 
Local nX 	 	:= 0 // controle de loop	
Local cComando   

Conout("SWEDA 7000 - METHOD IFFechaCup - Inicio - "+ Time() )

If ::IsECFOnLine(.T.)
	// Laço para imprimir toda a mensagem
	While ( AllTrim(cMensagem)<>"" ) .AND. ( nLinha<9 )
		cLinha := ""
		// Laço para pegar 40 caracteres do Texto
		For nX := 1 to 40
			// Caso encontre um CHR(Line Feed) imprime a linha
			If SubStr(cMensagem,nX,1) == Chr(10)
				Exit
			EndIf
			cLinha := cLinha+SubStr(cMensagem,nX,1)
		Next nX
		cLinha 	:= SubStr(cLinha+space(40),1,40)
		cCmd 		:= cCmd+"0"+cLinha
		cMensagem := SubStr(cMensagem,nX+1,Len(cMensagem))

		nLinha += 1
	End
 
	cComando := Chr(27)+".12SN"+cCmd+"}"
	cRet := ::EnviaComando( cComando )
	If Substr(cRet,2,1) == "-"
		While Substr(cRet,2,1) == "-"
			If MsgYesNo("Não foi possível registrar as formas de pagamento. Deseja tentar novamente?", "Atenção")
				cRet := ::EnviaComando( cComando )
			Else
				cRet := ".-P002}"
				Exit
			EndIf
		End
	EndIf
	nRet := ::TrataRet(cRet)
	// Tempo necessário para aguardar a Finalização do Cupom
	Sleep(4000)
EndIf  

Conout("SWEDA 7000 - METHOD IFFechaCup - Termino - "+ Time() )

Return(nRet)

//-------------------------------------------------------------
METHOD IFAutentic (cVezes, cValor, cTexto) CLASS LJSweda
Local cRet := ""
Local nVz  := 0
Local cRetorno := ""      
Local nVezes := 0
Local lCanc := .T. 

Conout("SWEDA 7000 - METHOD IFAutentic - Inicio - "+ Time() )

nVezes := Val(cVezes)

If nVezes = 0 
   nVezes := 1
Endif

nVz := 1	

While nVz <= nVezes .AND. lCanc 
	if nVz == 1 
		cComando := Chr(27) + ".200N" + Replicate(" ",15) + "0N" + Replicate(" ",20) + "}"
		MsgAlert("Posicione o Documento para a "+ AllTrim(Str(nVz)) +"a. Autenticação.")  
		cRet := ::EnviaComando(Chr(27) + ".23}")
		If ".+P050" $ cRet 
			cRet  	  := ::EnviaComando( cComando ) 
		Elseif MsgYesNo("Documento não inserido. Deseja efetuar a autenticação?")
			loop
		Else
			lCanc := .F.
		Endif		
	Else
		cComando := Chr(27) + ".26}"
		MsgAlert("Posicione o Documento para a "+ AllTrim(Str(nVz)) +"a. Autenticação.")     
		If ".+" $ cRet 
			cRet  	  := ::EnviaComando( cComando ) 
		Elseif MsgYesNo("Documento não inserido. Deseja efetuar a autenticação?")
			loop
		Else
			lCanc := .F.
		Endif
	EndIf      
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Da' um tempo para o usuario fazer as duas linhas da autenticacao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Sleep(8000)

	If ::TrataRetorno( 1, cRet ) == "0"
		nVz += 1
	EndIf          
End   

if lCanc
	cRetorno := ::TrataRetorno(1,cRet)// Metodo da classe SWEDA
Endif

Conout("SWEDA 7000 - METHOD IFAutentic - Termino - "+ Time() )

Return Val(cRetorno)

//-------------------------------------------------------------
METHOD IFRelGer (cTexto,nVias) CLASS LJSweda
Local nRet := 1
Local cRet 		
Local cComando   
Local lErroImp		:= .T.			//Controla se houve erro na impressao
Local lFezPend		:= .F.			// Controla se houve fechamento ou cancelamento do cupom antetior

Conout("SWEDA 7000 - METHOD IFRelGer - Inicio - "+ Time() )

If ::IsECFOnLine()
	lErroImp := .F.
	If SubStr(oAutocom:cBuffer,10,1) == "E"
		cComando := Chr(27)	+ ".12}"
		cRet := ::EnviaComando( cComando )
		Sleep(2000)
		lFezPend := .T.
	EndIf
	If SubStr(oAutocom:cBuffer,10,1) == "P" .AND. (SubStr(oAutocom:cBuffer,11,8) == "LEIT. X " .OR. SubStr(oAutocom:cBuffer,11,8) == "N.FISCAL")
		cComando := Chr(27)	+ ".08}"
		cRet := ::EnviaComando( cComando )
		Sleep(2000)
		lFezPend := .T.
	EndIf
	If lFezPend
		cRet := ::EnviaComando( Chr(27)+".28}")  
		If ::TrataRetorno( 1, cRet ) <> "0"
			nRet := Val(::TrataRetorno(1,".-"))
			lErroImp  := .T.
		EndIf
	EndIf
EndIf

If !lErroImp
	If SubStr(oAutocom:cBuffer,10,1) <> "P"   //Verifica se á operação está pendente
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia comando de abertura de relatorio gerencial ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cComando := Chr(27)	+ ".13S}"
		cRet := ::EnviaComando( cComando )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se der erro no comando do relatorio gerencial, manda o .28 (status da transacao) ³
		//³ para ver se se a impressora esta' ok.                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ".-" $ cRet
			sleep(1000)
			cRet := ::EnviaComando( Chr(27)+".28}") 
		Endif
		nRet := ::TrataRet(cRet)
		If nRet == 1
			lErroImp := .T.
		EndIf
	EndIf
EndIf

If !lErroImp
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le o Status da Transacao para saber se já tem alguma operação em aberto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTempoIni	:= Seconds()
	nTempo		:= nTempoIni
	// testa timeout, testa status do ECF
	While (nTempo - nTempoIni < 30) .AND. ((SubStr(cRet,10,1)<>"P"))  
		sleep(500)
		cComando	:= Chr(27)+".28}"	
		cRet		:= ::EnviaComando( cComando )
		nTempo		:= Seconds()
		If ::TrataRetorno( 1, cRet ) <> "0" .OR. Substr(cRet,10,1) == "E"
			nRet := Val(::TrataRetorno(1,".-"))
			lErroImp  := .T.
		EndIf
	End
EndIf             
            
If !lErroImp
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sem esse sleep, no Windows, ocorre um erro de comunicação da DLL da³
	//³Sweda, a SWECF.dll                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oAutocom:cPlataforma == "WINDOWS"
		Sleep(10000)
	EndIf
	nRet := ::IFTxtNFis(cTexto, nVias)
	If nRet <> 0
		lErroImp  := .T.
	Else
		nRet := ::IFFchCNFis()
		If nRet <> 0
			lErroImp  := .T.
		EndIf
	EndIf
EndIf

Conout("SWEDA 7000 - METHOD IFRelGer - Termino - "+ Time() )

Return(nRet)			

//-------------------------------------------------------------
METHOD IFGaveta () CLASS LJSweda
Local cRet 		
Local cComando   

Conout("SWEDA 7000 - METHOD IFGaveta - Inicio - "+ Time() )

// Abre gaveta acoplada ao IFS7000I (não retorna erro !!!)
cComando := Chr(27) + ".21"+"}"
::EnviaComando( cComando )

// Abre gaveta acoplada aos demais modelos...
cComando := Chr(27) + ".42"+"}"
cRet := ::EnviaComando( cComando )

Conout("SWEDA 7000 - METHOD IFGaveta - Termino - "+ Time() )

Return(::TrataRet(cRet))

//-------------------------------------------------------------
METHOD IFPegSerie() CLASS LJSweda
Local cRet 		
Local cComando   
  
Conout("SWEDA 7000 - METHOD IFPegSerie - Inicio - "+ Time() )

cComando := Chr(27) + ".273}"
cRet := ::EnviaComando( cComando )

Conout("SWEDA 7000 - METHOD IFGaveta - Termino - "+ Time() )

Return(::TrataRet(cRet))

//-------------------------------------------------------------
METHOD IFPedido(cTEF, cTexto, cValor, cCondPgTEF) CLASS LJSweda
MsgStop("Recurso de emissão de pedido não disponível para Impressora Fiscal Sweda.")
Return (1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³IFRecbNFisºAutor  ³Adrianne            ºData  ³  xx/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre um comprovante nao fiscal	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAdrianne  ³08/07/05 - 811 ³BOPS: 83590 								  º±±
±±º          ³               ³- Implementacao do Recebimento Nao Fiscal   º±±
±±º          ³               ³- Correcao/Melhorias na funcao IFAbrCNFis   º±±
±±º          ³               ³- Correcao na funcao IFTxtNFis, para tratar º±±
±±º          ³               ³  corretamente o numero de vias do compro-  º±±
±±º          ³               ³  vante									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndre M.  ³22/07/05 - 811 ³Correcao do BOPS: 83590                     º±±
±±º			 ³				 ³- Inicializado a vairavel  nUltimoSeq := 1  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAdrianne  ³16/09/05 - 811 ³Correcao do BOPS: 86386                     º±±
±±º			 ³				 ³- Alterado comando de fechamento do compro- º±±
±±º			 ³				 ³vante nao-fiscal. Ocorria erro no recebimen º±±
±±º			 ³				 ³to no Front Loja.                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD IFRecbNFis(cTotalizador, cValor, cForma) CLASS LJSweda   
Local cRet     				//Retorno na impressora
Local cRetorno	:= ""	 	// Retorno da função
Local cPos
Local nVz 		:= 0   	 	// Controle de laco

Conout("SWEDA 7000 - METHOD IFRecbNFis - Inicio - "+ Time() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tem que escrever no SIGALOJA.INI o acumulador que vai ser utilizado para o recebimento. Ex.: ³
//³ [Recebimento Titulos]                                                                        ³
//³ Totalizadores=RECEBIMENTO                                                                    ³
//³                                                                                              ³
//³ Esse totalizador deverá estar abaixo do título &SIGALOJA.                                    ³
//³ EX.:                                                                                         ³
//³                                                                                              ³
//³  04 &SIGALOJA              -> Titulos                                                        ³
//³  05    + FUNDO DE CAIXA    -> Legendas                                                       ³
//³  06    + RECEBIMENTOS      -> Legendas                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A forma de pagamento a ser utilizada nesse comprovante, será a apontada ³
	//³ no parametro MV_NATRECEB                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	::nUltimoSeq := 1 //Inicializada a variavel nUltimoSeq
	// Tipo = 2 - Grava o valor informado no Suprimentos
    cValor   :=FormataTexto(AllTrim(cValor),12,2,2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz um controle de 5 tentativas para registrar o recebimento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While nVz <= 5 .AND. SubStr(cRetorno,1,1) <> "0"

	    cPos:=::PegaRegistro(cForma)  
	                                                           
	    cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ "      }")
	    cRetorno := ::TrataRetorno( 1,cRet )
	    if SubStr(cRetorno,1,1) = "0"
	       Sleep(2000)
	       cRet := ::EnviaComando( Chr(27) + ".07" + SubStr(cPos,1,2) + cValor + "}")
	       cRetorno := ::TrataRetorno( 1,cRet )
	       Sleep(2000)
	       cValor := AllTrim(cValor)
	
	       cRet:=::IFPagto(cForma+"|"+cValor,"N")
	
	       if SubStr(cRetorno,1,1) = "0" 
	          cRet := ::EnviaComando( Chr(27)+	".12SN}")
	          Sleep(2000)
	          cRetorno := ::TrataRetorno( 1,cRet )
	       Endif
	    Endif   
	    
	    nVz ++ 
	    Sleep(1000)
	End
	    
Conout("SWEDA 7000 - METHOD IFRecbNFis - Termino - "+ Time() )
	    
Return (Val(cRetorno))

//-------------------------------------------------------------
METHOD IFHrVerao (cTipo ) CLASS LJSweda
MsgStop("Recurso não disponível para Impressora Fiscal Sweda.")
Return(0)

//-------------------------------------------------------------
METHOD IFAbreCup (cCliente) CLASS LJSweda
Local nRet := 1
Local cRet
Local cComando

Conout("SWEDA 7000 - METHOD IFAbreCup - Inicio - "+ Time() )

If ::IsECFOnLine(.T.)
	If SubStr(oAutocom:cBuffer,10,1) == "E"
		cComando := Chr(27)	+ ".12}"
		cRet := ::EnviaComando( cComando )
		Sleep(3000)
		::IsECFOnLine(.T.)									// Verifica novamente se o ECF esta on-line
	EndIf
	If SubStr(oAutocom:cBuffer,10,1) == "P" .AND. (SubStr(oAutocom:cBuffer,11,8) == "LEIT. X " .OR. SubStr(oAutocom:cBuffer,11,8) == "N.FISCAL")
		cComando := Chr(27)	+ ".08}"
		cRet := ::EnviaComando( cComando )
		Sleep(2000)
	EndIf

	cComando := Chr(27) +".17}"
	cRet := ::EnviaComando( cComando )
	nRet := ::TrataRet(cRet)
	::nUltimoSeq := 1
	::nSeqAtual := 1
	// Aguarda 3 Segundos, Que é o Tempo Necessário Para a Impressão.
EndIf

Conout("SWEDA 7000 - METHOD IFAbreCup - Termino - "+ Time() )

Return(nRet)

//-------------------------------------------------------------
METHOD IFRegItem (cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt, cUnidade) CLASS LJSweda
Local cRet,cRet1,cRet2,cRet3 
Local cComando
Local cRetorno 
Local cResult
Local cLinha 
Local cAux 
Local cAliq 
Local cSituacao
Local cDescrAdic 
Local aAliq 	:= {}
Local nTamanho  := 0 // controle de loop
Local nI 
Local nPos 
Local iPos 

Conout("SWEDA 7000 - METHOD IFRegItem - Inicio - "+ Time() )


// Verifica a casa decimal dos parâmetros
cQtde := AllTrim(StrTran(cQtde,",","."))
cVlrUnit := AllTrim(StrTran(cVlrUnit,",","."))
cVlrDesconto := AllTrim(StrTran(cVlrDesconto,",","."))
cVlTotIt := AllTrim(StrTran(cVlTotIt,",","."))

//verifica se é para registra a venda do item ou só o desconto
If AllTrim(cCodigo+cDescricao+cQtde+cVlrUnit) == "" 
	If Val(cVlrdesconto) <> 0 
		cRet := ::EnviaComando( Chr(27)+".02"+Space(10)+FormataTexto(cVlrDesconto,12,2,2) + "}")
		cResult := ::TrataRetorno( 1,cRet )
    Else
		cResult := "0"
    EndIf
Else
	// Verifica a casa decimal dos parâmetros
	cSituacao := SubStr(cAliquota,1,1)
	cAliquota  := AllTrim(StrTran(SubStr(cAliquota,2,5),",","."))

	// Checa as aliquotas
	//  cRet1 := fFuncEnviaComando( PChar(#27+".293}") )
	//  cRet2 := fFuncEnviaComando( PChar(#27+".294}") )
	//  cRet3 := fFuncEnviaComando( PChar(#27+".295}") )
	cRet1 := ::cCmd293
	cRet2 := ::cCmd294
	cRet3 := ::cCmd295
	If (SubStr(::TrataRetorno(1,cRet1),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet2),1,1)<>"0") .OR. (SubStr(::TrataRetorno(1,cRet3),1,1)<>"0")
		cResult := "1"
	EndIf

	cRetorno := SubStr(cRet1,49,28) + SubStr(cRet2,8,49) + SubStr(cRet3,8,28)
	cLinha := ""
	nI := 0
	While (nI <= 15) .AND. (AllTrim(SubStr(cRetorno,(7*nI)+1,7)) <> "")
		cAux := FormataTexto(AllTrim(Str(Val(SubStr(cRetorno,(7*nI)+4,4)))),4,2,1,".")
	    If FormataTexto(cAux,4,2,2) <> "0000"
			cLinha := cLinha + SubStr(cRetorno,(7*nI)+1,1) + cAux + "|"
	    EndIf
    	nI += 1
	End

	cRet := cLinha

	// Verifica se a aliquota é ISENTA, c/SUBSTITUICAO TRIBUTARIA, NAO TRIBUTAVEL, ISS ou ICMS
	If At(cSituacao,"T") > 0  
		aAliq := MontArray( cRet )
	    iPos := 0
		For nTamanho := 1 to Len(aAliq)
			If aAliq[nTamanho] == cSituacao+cAliquota 
				iPos := nTamanho
				nTamanho := Len(aAliq)
	        EndIf
		Next nTamanho                 
	
		If (iPos = 0) .AND. (At(cSituacao,"TS") > 0) 
			MsgStop("Aliquota não cadastrada.")
			cResult := "1"
		EndIf
		cAliq := SubStr(cRetorno,((iPos-1)*7)+1,3)
	ElseIf At(cSituacao,"S") > 0  
		aAliq := MontArray( cRet )
	    iPos := 0
		For nTamanho := 1 to Len(aAliq)
			If aAliq[nTamanho] == cSituacao+FormataTexto(cAliquota,4,2,1,".")
				iPos := nTamanho
				nTamanho := Len(aAliq)
	        EndIf
		Next nTamanho
		If (iPos = 0) .AND. (At(cSituacao,"TS") > 0)
			MsgStop("Aliquota não cadastrada.")
			cResult := "1"
		EndIf
		cAliq := SubStr(cRetorno,((iPos-1)*7)+1,3)
	Else
		cAliq := cSituacao + "  "
	EndIf
                
	nPos := At(".",cVlTotIt)
	cVlTotIt := FormataTexto(SubStr(cVlTotIt,1,nPos+2),12,2,2)
	If SubStr(cVlrUnit,Len(cVlrUnit)-3,1) == "." 
		cVlrUnit	:= FormataTexto(cVlrUnit,9,3,2)
    	cDescricao:= "~"+cDescricao
	Else
    	cVlrUnit	:= FormataTexto(cVlrUnit,9,2,2)
	EndIf

	cDescrAdic := ""
	cDescricao := AllTrim(cDescricao)
	If Len(cDescricao) > 24
    	cDescrAdic := SubStr(cDescricao,25,Len(cDescricao))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o tamanho da descricao. Se for maior que 24 posições envia a descricao auxiliar. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCodigo := Padl(AllTrim(cCodigo),13,"0")		
		cComando := Chr(27) + ".01" + cCodigo +; 
					 FormataTexto(cQtde,7,3,2) +;	
					 cVlrUnit +;  				 	
					 cVlTotIt +;     				
					 SubStr(cDescricao+Space(24),1,24) +;
					 cAliq + "06" + "}"				    
		cRet := ::EnviaComando(cComando )

	If SubStr( ::TrataRetorno(2,cRet),1,1 ) == "0" 
		If Val(cVlrdesconto) <> 0 
			cRet := ::EnviaComando( Chr(27)+".02"+Space(10)+FormataTexto(cVlrdesconto,12,2,2) + "}") 
		EndIf   
	EndIf

	cResult := ::TrataRetorno( 1,cRet )
                                       
EndIf

Conout("SWEDA 7000 - METHOD IFRegItem - Termino - "+ Time() )

Return Val(cResult)

//-------------------------------------------------------------
METHOD IFPagto(cPagto, cVinculado, nVlrTotal,aImpsSL1) CLASS LJSweda
Local nRet := 1
Local cRet
Local cComando
Local cLinha
Local aFormas
Local aAuxiliar
Local nI
Local nPos

If ::IsECFOnLine(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o parametro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPagto := StrTransf(cPagto,",",".")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le as condicoes de pagamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet := ::FormasPgto
	aFormas := MontArray( cRet )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta um array auxiliar com os parametros ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAuxiliar := MontArray( cPagto)

	cLinha := ""

	nI := 1
	While nI < Len(aAuxiliar)
		If ::AchaPagto( aAuxiliar[nI],aFormas ) <> "00" 
			nPos := At(".",aAuxiliar[nI+1])
			If nPos > 0
				aAuxiliar[nI+1] := SubStr(aAuxiliar[nI+1],1,nPos+2)
			EndIf
			cLinha := cLinha +::AchaPagto( aAuxiliar[nI],aFormas ) + FormataTexto(aAuxiliar[nI+1],12,2,2)
		EndIf
		nI += 2
	End

	cComando := Chr(27) + ".10"+cLinha+"}"
	cRet := ::EnviaComando( cComando )
	If Substr(cRet,2,1) == "-"
		While Substr(cRet,2,1) == "-"
			If MsgYesNo("Não foi possível registrar as formas de pagamento. Deseja tentar novamente?", "Atenção")
				cRet := ::EnviaComando( cComando )
			Else
				cRet := ".-P002}"
				Exit
			EndIf
		End
	EndIf
	nRet := ::TrataRet(cRet)
EndIf

Conout("SWEDA 7000 - METHOD IFPagto - Termino - "+ Time() )

Return(nRet)

//----------------------------------------------------------------------------
METHOD IFLeAliq() CLASS LJSweda

Conout("SWEDA 7000 - METHOD IFLeAliq - Inicio - "+ Time() )
oAutocom:cBuffer := ::Aliquotas
Conout("SWEDA 7000 - METHOD IFLeAliq - Termino - "+ Time() )

Return (0)

//----------------------------------------------------------------------------
METHOD IFLeAliIss() CLASS LJSweda
Conout("SWEDA 7000 - METHOD IFLeAliISS - Inicio - "+ Time() )
oAutocom:cBuffer := ::ISS
Conout("SWEDA 7000 - METHOD IFLeAliISS - Termino - "+ Time() )
Return (0)

//----------------------------------------------------------------------------
METHOD IFLeConPag() CLASS LJSweda
Conout("SWEDA 7000 - METHOD IFLeConPag - Inicio - "+ Time() )
oAutocom:cBuffer := ::FormasPgto
Conout("SWEDA 7000 - METHOD IFLeConPag - Termino - "+ Time() )
Return (0)

//----------------------------------------------------------------------------
METHOD IFPegPDV() CLASS LJSweda
Local cRet 
Local cRetorno
Local nX := 0         

Conout("SWEDA 7000 - METHOD IFPegPDV - Inicio - "+ Time() )

cRet := ::EnviaComando( Chr(27)+".271}") 
nX   += 1
While ((SubStr(cRet,2,1)== "-") .AND. (nX < 20))
	cRet := ::EnviaComando( Chr(27)+".271}") 
	nX   += 1
End

If SubStr(::TrataRetorno(1,cRet),1,1) == "0" 
	::PDV := FormataTexto(SubStr(cRet,4,3), 4, 0, 2)
 	oAutocom:cBuffer := ::PDV
 	cRetorno := "0"
Else
	cRetorno := "1"
EndIf

Conout("SWEDA 7000 - METHOD IFPegPDV - Termino - "+ Time() )

Return Val(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³IFTxtNFis ºAutor  ³Adrianne            ºData  ³  xx/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre um comprovante nao fiscal	                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAdrianne  ³08/07/05 - 811 ³BOPS: 83590 								  º±±
±±º          ³               ³- Implementacao do Recebimento Nao Fiscal   º±±
±±º          ³               ³- Correcao/Melhorias na funcao IFAbrCNFis   º±±
±±º          ³               ³- Correcao na funcao IFTxtNFis, para tratar º±±
±±º          ³               ³  corretamente o numero de vias do compro-  º±±
±±º          ³               ³  vante									  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
METHOD IFTxtNFis(cTexto, nVias) CLASS LJSweda
Local cRet                
Local cComando
Local cTextoAux
Local cLinha
Local cRetorno   := ""          //Controla o retorno da impressora com tratamento 
Local nFim
Local nIndice
Local nJ
Local nI		 := 0 			// controle de loop
Local lErroImp   := .F.        //Controla se houve erro na impressao 

Conout("SWEDA 7000 - METHOD IFTxtNFis - Inicio - "+ Time() )

cTextoAux := cTexto

For nI := 1 to nVias
	If Len(cTexto) > 0
		While Len(cTexto) > 2 .AND. !lErroImp
			nFim := Len(cTexto)
			
			If At( Chr(10), SubStr( cTexto, 1, 40 ) ) > 0
			
				nIndice	:= At( Chr(10), SubStr( cTexto, 1, 40 ) )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Completa a linha com espacos ate' 40 caracteres pq a Sweda nao aceita ³
				//³ linha com menos que 40 posicoes                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nIndice == 1
					clinha	:= ""
				Else
					clinha	:= PadR( SubStr( cTexto, 1, nIndice - 1 ), 40 )
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a quebra ja' foi no Chr(10) desconsidera para nao saltar 2 linhas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SubStr( cTexto, nIndice + 1, 1 ) == Chr(10)
				    cTexto	:= SubStr( cTexto, nIndice + 2, nFim )
				Else
					cTexto	:= SubStr( cTexto, nIndice + 1, nFim )
				Endif
				
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se a quebra ja' foi no Chr(10) desconsidera para nao saltar 2 linhas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If SubStr(cTexto, 41, 1 ) == Chr(10)
					cLinha:=SubStr(cTexto, 1, 40)
					cTexto:=SubStr(cTexto, 42, nfim)
				Else
					cLinha:=SubStr(cTexto, 1, 40)
					cTexto:=SubStr(cTexto, 41, nfim)
				Endif				
			EndIf
			
            cComando := Chr(27) +".080"+cLinha+"}"

            cRet := ::EnviaComando( cComando )            
	        nJ := 2
			While (cRetorno  := ::TrataRetorno(1, cRet)) <> "0" .AND. (nJ < 2)
				cRet := ::EnviaComando( cComando )
				nJ += 1
			End
			lErroImp         := (cRetorno <> "0")			
	        If lErroImp
			   Exit
			Endif					
		End
	EndIf
	If !lErroImp
		If nI <> nVias
			cComando := Chr(27) +".089"+"6}"        
	        cRet := ::EnviaComando( cComando )
	        nJ := 2
	        While (cRetorno  := ::TrataRetorno(1,cRet)) <> "0" .AND. ( nJ < 2 )  /*MUDAR 4*/ 
	        	cRet := ::EnviaComando( cComando )
	            nJ += 1
			End
			If cRetorno <> "0"
			   lErroImp         := .T.
			   Exit
			Endif								
		Endif
	Endif
	cTexto := cTextoAux
Next nI
cRet := ::TrataRetorno( 1,cRet )

Conout("SWEDA 7000 - METHOD IFTxtNFis - Termino - "+ Time() )

Return Val(cRet)

//-------------------------------------------------------------
METHOD IFAlimProp() CLASS LJSweda
Local cComando
Local cRet1
Local cRet2
Local cRet3
Local cRet4
Local cRetorno
Local cForma
Local cLinha
Local cAux
Local nI

Conout("SWEDA 7000 - METHOD IFAlimProp - Inicio - "+ Time() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aliquotas de ICMS                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nI :=0
cComando := Chr(27)+".293}"
cRet1 := ::EnviaComando( cComando )
::cCmd293 := cRet1
nI += 1
While ((SubStr(cRet1,2,1) == "-") .AND. (nI < 20))
	cRet1 := ::EnviaComando( cComando )
	::cCmd293 := cRet1
	nI += 1
End

nI := 0
cComando := Chr(27)+".294}"
cRet2 := ::EnviaComando( cComando )
::cCmd294 := cRet2
nI += 1
While ((SubStr(cRet2,2,1) == "-") .AND. (nI < 20))
	cRet2 := ::EnviaComando( cComando )
	::cCmd294 := cRet2
	nI += 1
End

nI := 0
cComando := Chr(27)+".295}"
cRet3 := ::EnviaComando( cComando )
::cCmd295 := cRet3
nI += 1
While ((SubStr(cRet3,2,1) == "-") .AND. (nI < 20))
	cRet3 := ::EnviaComando( cComando )
	::cCmd295 := cRet3
	nI += 1
End

nI := 0
cComando := Chr(27)+".296}"
cRet4 := ::EnviaComando( cComando )
::cCmd296 := cRet4
nI += 1
While ((SubStr(cRet4,2,1) == "-") .AND. (nI < 20))
	cRet4 := ::EnviaComando( cComando )
	::cCmd296 := cRet4
	nI += 1
End

::IFPegPDV()

cLinha := ""
If (SubStr(::TrataRetorno(1,cRet1),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet2),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet3),1,1) <> "0")
	::Aliquotas := cLinha
EndIf
cRetorno := SubStr(cRet1,49,28) + SubStr(cRet2,8,49) + SubS(cRet3,8,28)
nI := 0
While (nI <= 15) .AND. (AllTrim(SubStr(cRetorno,(7*nI)+1,7)) <> "")
	cAux := SubStr(cRetorno,(7*nI)+4,4)
	cAux := AllTrim(cAux)
	If (FormataTexto(cAux,4,2,2) <> "0000")
		If SubStr(cRetorno,(7*nI)+1,1) == "T"
			cLinha := cLinha + FormataTexto(cAux,4,2,1,".") + "|"
		EndIf
	EndIf
	nI += 1
End
::Aliquotas := cLinha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aliquotas de ISS                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinha := ""
If (SubStr(::TrataRetorno(1,cRet1),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet2),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet3),1,1) <> "0")
	::ISS := cLinha
EndIf
cRetorno := SubStr(cRet1,49,28) + SubStr(cRet2,8,49) + SubStr(cRet3,8,28)
nI := 0
While (nI <= 15) .AND. (AllTrim(SubStr(cRetorno,(7*nI)+1,7)) <> "")
	cAux := SubStr(cRetorno,(7*nI)+4,4)
	cAux := AllTrim(cAux)
	If (FormataTexto(cAux,4,2,2) <> "0000")
		If SubStr(cRetorno,(7*nI)+1,1) == "S"
			cLinha := cLinha + FormataTexto(cAux,4,2,1,".") + "|"
		EndIf
	EndIf
	nI += 1
End
::ISS := cLinha

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formas de Pagamento                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinha := ""
If (SubStr(::TrataRetorno(1,cRet3),1,1) <> "0") .OR. (SubStr(::TrataRetorno(1,cRet4),1,1) <> "0")
	::FormasPgto := cLinha
EndIf
cForma := SubStr(cRet3,36,45) + SubStr(cRet4,8,105)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A diferença entre a 1.0 e a 1.A é que a 1.A para fazer cupom vinculado, ³
//³ a finalizadora deve ter a FLAG de VINCULAÇÃO como "S".                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
::cVinculado := SubStr(cRet3,81,3)+SubStr(cRet4,113,7)
For nI := 0 to 9
	cAux := AllTrim(SubStr(cForma,(nI*15)+1,15))
	If cAux <> ""
		cLinha := cLinha + cAux + "|"
	EndIf
Next nI
::FormasPgto := cLinha

Conout("SWEDA 7000 - METHOD IFAlimProp - Termino - "+ Time() )

Return()


//-------------------------------------------------------------
METHOD IFReducaoZ (cMapaRes) CLASS LJSweda	
Local dDataHoje
Local cRet, cDataHoje, cRet271, cRet273, cRet27G
Local nContador
Local aRetorno	:= Array(21)
Local cRetorno	:= "1"
Local nLiq		:= 0

Conout("SWEDA 7000 - METHOD IFReducaoZ - Inicio - "+ Time() )

If AllTrim(cMapaRes) == "S"
	// COMANDO G...
	cRet27G := ::EnviaComando( Chr(27)+".27G}" )
	If SubStr(::TrataRetorno(1,cRet27G),1,1) <> "0" 
		cRetorno := "1"
	EndIf

	// COMANDO 1...
	cRet271 := ::EnviaComando( Chr(27)+".271}" )
	if SubStr(::TrataRetorno(1,cRet271),1,1) <> "0" 
		cRetorno := "1"
	EndIf

	// COMANDO 3...
	cRet273 := ::EnviaComando( Chr(27)+".273}" )
	if SubStr(::TrataRetorno(1,cRet273),1,1) <> "0" 
		cRetorno := "1"
	EndIf
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara o array, aRetorno, com os dados do ECF...    ³
	//³ [01] Data Fiscal (DDMMAA)                            ³
	//³ [02] Nr. ECF                                         ³
	//³ [03] Identificação do Equipamento	(9 caracteres)   ³
	//³ [04] Número de Reduçöes (4 dígitos)                  ³
	//³ [05] Grande Total (17 dígitos)                       ³
	//³ [06] Cupom Fiscal inicial - irredutível	(4 dígitos)  ³
	//³ [07] --Numero documento Final--                      ³
	//³ [08] Total de Vendas canceladas no dia	 (12 dígitos)³
	//³ [09] Total Líquido do Dia	  (12 dígitos)           ³
	//³ [10] Total de Descontos no Dia	  (12 dígitos)       ³
	//³	[11] Total Substituição	(12 dígitos)                 ³
	//³	[12] Total Isento	(12 dígitos)                     ³
	//³	[13] Total Não Tributável	(12 dígitos)             ³
	//³	[14] --data da reducao z--                           ³
	//³	[15] Sequencial de Operação  (4 dígitos)             ³
	//³	[16] --outros recebimentos--                         ³
	//³	[17] Total ISS                                       ³
	//³	[18] CRO - Contador de Reinício de Operação          ³
	//³	[19] Desconto de ISS					             ³
	//³	[20] Cancelamento de ISS				             ³
	//³	[21] QTD DE Aliquotas programadas no ECF             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara o array, aRetorno, com os dados do ECF...           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetorno[ 1]:= SubStr(cRet271, 8, 2) + "/" + SubStr(cRet271,10, 2) + "/" + SubStr(cRet271,12, 2)//[01] Data Fiscal (DDMMAA)
	aRetorno[ 2]:= FormataTexto(SubStr(cRet271,4, 3), 4, 0, 2)								//[02] Nr. ECF
	aRetorno[ 3]:= SubStr(SubStr(cRet273,13, 9)+Space(13), 0, 13)                           //[03] Identificação do Equipamento	(9 caracteres)
	aRetorno[ 5]:= AllTrim(FormataTexto(Str(Val(SubStr(cRet271,20,17))/100),18,2,3))		//[05] Grande Total (17 dígitos)
	aRetorno[ 5]:= FormataTexto(aRetorno[5], 19, 2, 1, ".")
	aRetorno[ 6]:= FormataTexto(SubStr(cRet27G,12, 4), 6, 0, 2)								//[06] Cupom Fiscal inicial - irredutível	(4 dígitos)
	aRetorno[ 7]:= FormataTexto(SubStr(cRet271,121, 4), 6, 0, 2)							//[07] --Numero documento Final--
	aRetorno[ 8]:= AllTrim(Str((Val(SubStr(cRet271,61,12))+Val(SubStr(cRet271,77,12)))/100))//[08] Total de Vendas canceladas no dia	  (12 dígitos)
	aRetorno[ 8]:= FormataTexto(aRetorno[8], 15, 2, 1, ".")
	aRetorno[ 9]:= AllTrim(Str(Val(SubStr(cRet271,105,12))))							//[09] Total Líquido do Dia	  (12 dígitos)
	aRetorno[ 9]:= FormataTexto(aRetorno[9], 15, 2, 1, ".")
	aRetorno[10]:= AllTrim(Str(Val(SubStr(cRet271,93,12))))								//[10] Total de Descontos no Dia	  (12 dígitos)
	aRetorno[10]:= FormataTexto(aRetorno[10], 11, 2, 1, ".")
	aRetorno[11]:= AllTrim(Str(Val(SubStr(cRet273,46,12))))								//[11] Total Substituição	(12 dígitos)
	aRetorno[11]:= FormataTexto(aRetorno[11], 11, 2, 1, ".")
	aRetorno[12]:= AllTrim(Str(Val(SubStr(cRet273,22,12))))								//[12] Total Isento	(12 dígitos)
	aRetorno[12]:= FormataTexto(aRetorno[12], 11, 2, 1, ".")
	aRetorno[13]:= AllTrim(Str(Val(SubStr(cRet273,34,12))))								//[13] Total Não Tributável	(12 dígitos)
	aRetorno[13]:= FormataTexto(aRetorno[13], 11, 2, 1, ".")
	aRetorno[14]:= aRetorno[1] 																//[14] --data da reducao z--
	aRetorno[16]:= FormataTexto("0",16, 0, 2) 												//[16] --outros recebimentos--
	aRetorno[17]:= FormataTexto("0",14, 2, 1)+" "+FormataTexto("0",14, 2, 1) 				//[17] Total ISS
	aRetorno[18]:= SubStr(cRet27G,17, 3) 													//[18] CRO - Contador de Reinício de Operação	
	aRetorno[19]:= FormataTexto("0",16, 0, 2)												//[19] Desconto de ISS
	aRetorno[20]:= FormataTexto("0",16, 0, 2)												//[20] Cancelamento de ISS
	aRetorno[21]:= "00"																		//[21] QTD DE Aliquotas programadas no ECF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ COMANDO 273, 274 e 275 para pegar os totais das alíquotas cadastradas... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(cRet273, 94, 3) <> ""
		aRetorno[21] := FormataTexto(AllTrim(Str(Val(aRetorno[21])+1)),2,0,2)             // QTD DE Aliquotas programadas no ECF
		AAdd (aRetorno, FormataAliquota( SubStr(cRet273,94,15) ))

		cRetorno := ::EnviaComando( Chr(27)+".274}") 
		If SubStr(::TrataRetorno(1,cRetorno),1,1) == "0" 
			cRetorno := SubStr(cRetorno,8,105) + SubStr(::EnviaComando(Chr(27)+".275}"),8,105)
			For nContador := 0 To 13 
				If AllTrim(SubStr(cRetorno,1,3)) <> "" 
					cRet := FormataAliquota( AllTrim(SubStr(cRetorno,1,15)) )
					If cRet <> ""
						If SubStr(cRet,1,1) == "S" 
							aRetorno[17] := FormataTexto(Str(Val(SubStr(aRetorno[17],1,14))+Val(SubStr(cRet,8,14))),14,2,1)+" "+;
                                            FormataTexto(Str(Val(SubStr(aRetorno[17],16,14))+Val(SubStr(cRet,23,14))),14,2,1)
                        Else
                           aRetorno[21] := FormataTexto(AllTrim(Str(Val(aRetorno[21])+1)),2,0,2)
                           AAdd(aRetorno, cRet)
                        EndIf
  					EndIf
  				EndIf
				cRetorno := SubStr(cRetorno,16,Len(cRetorno))
			Next nContador
		EndIf
	EndIf
	
	nLiq := Val( aRetorno[ 9] ) - Val( aRetorno[ 8] ) - Val( aRetorno[10]) - Val( Substr(aRetorno[17],1,At(" ",aRetorno[17])-1)) - Val(aRetorno[19]) - Val(aRetorno[20])
    aRetorno[ 9] := FormataTexto(nLiq, 15, 2, 1, ".")
     
EndIf  // Fim do Mapa Resumo...

dDataHoje:= Date()
cDataHoje := FormataData( dDataHoje, 1 )
If ::EmiteReducaoZ(cDataHoje,cRet) 
	cRetorno:="0"
EndIf

If AllTrim(cMapaRes) =="S" 
	// Repete o COMANDO 1... após a emissão da Redução Z...
    // Delay de aproximadamente 2 minutos para pegar o COO e o contador de Reduções...
	For nContador := 0 To 23 
		cRet271 := ::EnviaComando( Chr(27)+".271}" )
		If SubStr(::TrataRetorno(1,cRet271),1,1) == "0" 
			nContador := 23
		Else
			Sleep(5000)
		EndIf
	Next nContador
    aRetorno[ 4] := SubStr(cRet271,41, 4)							//[04] Número de Reduçöes (4 dígitos)
    aRetorno[15] := FormataTexto(SubStr(cRet271,14, 4), 6, 0, 2)	//[15] Sequencial de Operação  (4 dígitos)
    cRetorno := "0"
    oAutocom:cBuffer := ""
    For nContador:= 1 to Len(aRetorno)
		oAutocom:cBuffer := oAutocom:cBuffer + aRetorno[nContador]+"|"
    Next nContador
EndIf

Conout("SWEDA 7000 - METHOD IFReducaoZ - Termino - "+ Time() )

Return cRetorno

//-------------------------------------------------------------
METHOD IFStatus	(cTipo) CLASS LJSweda	
Local cRet 
Local nRetorno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo - Indica qual o status quer se obter da impressora                          ³
//³  1 - Obtem a Hora da Impressora                                                  ³
//³  2 - Obtem a Data da Impressora                                                  ³
//³  3 - Verifica o Papel                                                            ³
//³  4 - Verifica se é possivel cancelar TODOS ou só o ULTIMO item registrado.       ³
//³  5 - Cupom Fechado ?                                                             ³
//³  6 - Ret. suprimento da impressora                                               ³
//³  7 - ECF permite desconto por item                                               ³
//³  8 - Verica se o dia anterior foi fechado                                        ³
//³  9 - Verifica o Status do ECF                                                    ³
//³ 10 - Verifica se todos os itens foram impressos.                                 ³
//³ 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)                       ³
//³ 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)  ³
//³ 13 - Verifica se o ECF Arredonda o Valor do Item                                 ³
//³ 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)            ³
//³ 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)        ³
//³ 16 - Verifica se exige o extenso do cheque                                       ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Conout("SWEDA 7000 - METHOD IFStatus - Inicio - "+ Time() )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 1 - Faz a leitura da Hora da Impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "1"
  cRet := ::EnviaComando( Chr(27)+".28}" )
  If SubStr(::TrataRetorno(1,cRet),1,1)=="0"
    nRetorno := 0 
    oAutocom:cBuffer := SubStr(cRet,53,2) + ":" + SubStr(cRet,55,2) + ":00"
  else
    nRetorno := 1
  EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 2 - Faz a leitura da Data da Impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "2"
  cRet := ::EnviaComando( Chr(27)+".28}" )
  If SubStr(::TrataRetorno(1,cRet),1,1)=="0" 
    nRetorno := 0 
    oAutocom:cBuffer := SubStr(cRet,47,2) + "/" + SubStr(cRet,49,2) + "/" + SubStr(cRet,51,2)
  Else
    nRetorno := 1
  EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Faz a checagem do papel ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "3"
  cRet := ::EnviaComando( Chr(27)+".28}" )
  If SubStr(::TrataRetorno(1,cRet),1,1) <> "0" // se retornar erro verifica se falta papel
    If SubStr(cRet,6,1) == "5" 
      nRetorno := 2
    Else
      nRetorno := 0
    EndIf
  Else
    nRetorno := 0
  EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 4 - Verifica se é possível cancelar um ou todos os itens. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "4"
  nRetorno := 0
  oAutocom:cBuffer := "TODOS"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 5 - Cupom Fechado ? ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "5"
  cRet := ::EnviaComando( Chr(27)+".28}" )
  If SubStr(::TrataRetorno(1,cRet),1,1) == "0"
    If (SubStr(cRet,10,1) <> "C") .AND. (AllTrim(SubStr(cRet,11,8)) =="VENDAS") 
      nRetorno := 7
    else
      nRetorno := 0
    EndIf
  else
    nRetorno := 1
  EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 6 - Ret. suprimento da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "6"
  nRetorno := 0
  oAutocom:cBuffer := "0.00"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 7 - ECF permite desconto por item ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Elseif cTipo == "7"
  ::nRetorno := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 8 - Verica se o dia anterior foi fechado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "8" 
  cRet := ::EnviaComando( Char(27) +".28}" )
  If SubStr(::TrataRetorno(1,cRet),1,1) == "0" 
    If SubStr(cRet,21,1) =="F" 
      nRetorno := 10
    Else
      nRetorno := 0
    EndIf
  Else
    nRetorno := 1
  EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 9 - Verifica o Status do ECF ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "9"
  nRetorno := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 10 - Verifica se todos os itens foram impressos. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "10"
  nRetorno := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "11"
  nRetorno := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "12"
  nRetorno := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 13 - Verifica se o ECF Arredonda o Valor do Item ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "13"
  nRetorno := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "14"
  // 0 - Fechada
  cRet := ::EnviaComando( Chr(27) +".43}" )
  If SubStr(cRet,6,1) == "0" 
    nRetorno := 0
  Else
    nRetorno := 1
  EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "15"
  nRetorno := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 16 - Verifica se exige o extenso do cheque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf cTipo == "16"
  nRetorno := 1
  
Elseif cTipo == "45"

        nRet := 0 
        
Elseif cTipo == "46"

        nRet := 0 

Else
  nRetorno := 1
  
EndIf

Conout("SWEDA 7000 - METHOD IFStatus - Termino - "+ Time() )

Return(nRetorno)

//-------------------------------------------------------------
METHOD IFMemFisc (cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo) CLASS LJSweda	
Local cRet      := ""
Local cRetorno
Local cFile 	:= GetClientDir()+"Retorno.txt"
Local cMemoria 	:= ""

Conout("SWEDA 7000 - METHOD IFMemFisc - Inicio - "+ Time() )

If (cTipo == "I")
	If (AllTrim(cReducInicio) <> "") .OR. (AllTrim(cReducFim) <> "")
		cReducInicio := FormataTexto(AllTrim(cReducInicio),4,0,2)
		cReducFim 	 := FormataTexto(AllTrim(cReducFim),4,0,2)
        cRet        := ::EnviaComando( Chr(27)+".15" + cReducInicio + cReducFim+"}")
	Else
		cDataInicio:= FormataData(CtoD(cDataInicio),1)  //200205
		cDataFim   := FormataData(CtoD(cDataFim)   ,1) 
        cRet       := ::EnviaComando( Chr(27)+".16" + cDataInicio + cDataFim+"}")
  	EndIf	
	cRetorno := ::TrataRetorno( 1,cRet )
	If cRetorno == "0"
        cRet := ::PulaLinha(7)
     EndIf
Else                                       
	::cBuffer := ""
	If (AllTrim(cReducInicio) <> "") .OR. (AllTrim(cReducFim) <> "")
		cReducInicio := FormataTexto(AllTrim(cReducInicio),4,0,2)
		cReducFim 	 := FormataTexto(AllTrim(cReducFim),4,0,2)

        cRet         := ::EnviaComando( Chr(27)+".15" + cReducInicio + cReducFim+"|}") 
        cMemoria   := SubStr(cRet,10,At("}",cRet)-10) + Chr(13)
		While (At(".]",cRet) == 0) .AND. (::TrataRetorno(1, cRet) == "0")
	        cRet		:= ::EnviaComando( Chr(27)+".++}") 
	        cMemoria 	:= cMemoria + SubStr(cRet,10,At("}",cRet)-10) + Chr(13)
	 	End
	Else
		cDataInicio:= FormataData(CtoD(cDataInicio),1)  //200205
		cDataFim   := FormataData(CtoD(cDataFim)   ,1) 

        cRet       := ::EnviaComando( Chr(27)+".16" + cDataInicio + cDataFim+"|}")
        cMemoria   := SubStr(cRet,10,At("}",cRet)-10) + Chr(13)   
		While (At(".]",cRet) == 0) .AND. (::TrataRetorno(1, cRet) == "0")
	        cRet		:= ::EnviaComando( Chr(27)+".++}") 
	        cMemoria 	:= cMemoria + SubStr(cRet,10,At("}",cRet)-10) + Chr(13)
	 	End
  	EndIf	

	If File(cFile)                
		FErase(cFile)
	EndIf
	nHandle := FCreate(cFile, 0 )
	If Ferror() <> 0
		MsgStop("Nao foi possivel criar arquivo de Memória Fiscal")  
		Return (.F.)
	Else
		FWrite( nHandle, cMemoria, Len(cMemoria)+2 )
		If Ferror() <> 0
			MsgStop("Nao foi possivel escrever no arquivo de Memória Fiscal")  
			Return (.F.)
		Else
			FClose(nHandle) 		
			MsgInfo("Veja arquivo Retorno.txt no diretório REMOTE")
		EndIf		
	EndIf	
EndIf  

Conout("SWEDA 7000 - METHOD IFMemFisc - Termino - "+ Time() )

Return (cRetorno)

//-------------------------------------------------------------
METHOD IFSupr(nTipo, cValor, cForma, cTotal, cModo) CLASS LJSweda	
Local aFormas := {}
Local aPgto
Local cRet
Local cFormas
Local cPos
Local cRetorno
Local cCondicao
Local nI
Local nTamanho

Conout("SWEDA 7000 - METHOD IFSupr - Inicio - "+ Time() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo = 1 - Verifica se tem troco disponivel       ³
//³ Tipo = 2 - Grava o valor informado no Suprimentos ³
//³ Tipo = 3 - Sangra o valor informado               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRet:=" -"
cCondicao:= cForma
cValor   :=FormataTexto(AllTrim(cValor),12,2,2)
cRet     :="789ABCD"
cFormas  :=""

If nTipo == 1  // Tipo = 1 - Verifica se tem troco disponivel
	cRet := "67"
	For nI := 1 to 2 
		// Lendo os totais das modalidades de pagamento
		cPos     := ::EnviaComando( Chr(27)+".27"+SubStr(cRet,nI,1)+"}")
		nTamanho := (At("}",cPos)-1) - 7
		If nI == 2 
			cFormas  := cFormas+SubStr(cPos,8,48)
		Else
			cFormas  := AllTrim(SubStr(cPos,8,nTamanho))
		EndIf

		nTamanho:=Len(aFormas)+1
		While AllTrim(cFormas) <> ""
			AAdd (aFormas, SubStr(cFormas,5,12))
			cFormas:=SubStr(cFormas,17,Len(cFormas))
			nTamanho += 1
		End
	Next nI

       // Le as condicoes de pagamento
	cRet := ::FormasPgto
	aPgto := MontArray(cRet)
	For nI:=0 to Len(aPgto)
		If Upper(AllTrim(aPgto[nI]))=="DINHEIRO"
			cPos := AllTrim(Str(nI))
		EndIf
	Next nI
	If Val(aFormas[Val(cPos)]) >= Val(cValor)
		cRetorno := "8"
	Else
          cRetorno := "9" 
 	EndIf

EndIf
cFormas :="DINHEIRO"
	
If AllTrim(SubStr(cForma,3,Len(cForma))) <> ""
	cFormas := AllTrim(SubStr(cForma,3,Len(cForma)))
EndIf

If ( nTipo == 2 ) .AND. ( AllTrim(cForma)=="" )    // Tipo = 2 - Grava o valor informado no Suprimentos
	cCondicao := "FUNDO DE CAIXA"
EndIf

If ( nTipo == 3 ) .AND. ( AllTrim(cForma)=="" )   // Tipo = 3 - Sangra o valor informado
	cCondicao := "SANGRIA"
EndIf

If ( AllTrim(SubStr(cForma,1,2)) <> "") .AND. ( AllTrim(SubStr(cTotal,1,2)) <> "") 
	cPos := SubStr(cForma,1,2)+SubStr(cTotal,1,2)
Else
	cPos := ::PegaRegistro(cCondicao)
EndIf

cRet := ::EnviaComando( Chr(27)+".19" + SubStr(cPos,3,2)+ "      }")
cRetorno := ::TrataRetorno( 1,cRet )
If SubStr(cRetorno,1,1) == "0" 
	Sleep(2000)
	cRet := ::EnviaComando( Chr(27)+".07" + SubStr(cPos,1,2)+cValor+"}")
	cRetorno := ::TrataRetorno( 1,cRet )
	Sleep(500)
	If nTipo == 2
		cValor   := AllTrim(Str(Val(cValor)))
		cRet :=	::IFPagto(cFormas+"|"+cValor,"N")
		Sleep(500)
	EndIf
	If SubStr(cRetorno,1,1) == "0"
		cRet := ::EnviaComando( Chr(27)+".12NN}")
		Sleep(2000)
		cRetorno := ::TrataRetorno( 1,cRet )
	EndIf
EndIf

Conout("SWEDA 7000 - METHOD IFSupr - Termino - "+ Time() )

Return Val(cRetorno)

//-------------------------------------------------------------
METHOD IFAdicAliq (cAliquota, cTipo) CLASS LJSweda	
Local cRet 
Local cAliq
Local cCodTrib
Local aAliq := {}
Local nTamanho
Local nAt

Conout("SWEDA 7000 - METHOD IFAdicAliq - Inicio - "+ Time() )

cRet := ::Aliquotas
nTamanho := 0                               
  
While (At("|", cRet) > 0)
	nAt := At("|", cRet)
    cAliq := SubStr(cRet, 1, nAt-1)
    Aadd(aAliq,cAliq)
    cRet := SubStr(cRet, nAt+1, Len(cRet))
End

If At( cAliquota, cAliq ) > 0 
    MsgStop("A aliquota " + cAliquota + " ja está cadastrada.")
    cRet := "4|"
Else
    cCodTrib := FormataTexto(AllTrim(Str(Len(aAliq)+1)),2,0,2)
    If cTipo == "1"
		cRet := ::EnviaComando( Chr(27) +".33T"+cCodTrib+FormataTexto(AllTrim(cAliquota),4,2,2)+"}" )
	Else
	    cRet := ::EnviaComando( Chr(27) +".33S"+cCodTrib+FormataTexto(AllTrim(cAliquota),4,2,2)+"}" )
	EndIf	
    cRet := ::TrataRetorno( 1,cRet )
EndIf

Conout("SWEDA 7000 - METHOD IFAdicAliq - Termino - "+ Time() )

Return(cRet)

//-------------------------------------------------------------
METHOD PulaLinha (nNumero) CLASS LJSweda
Local cRet
Local cComando

Conout("SWEDA 7000 - METHOD Pulalinha - Inicio - "+ Time() )

  If (nNumero > 9, nNumero := 9,)   
  
  cComando := Chr(27)+".089"+AllTrim(Str(nNumero))+"}"
  cRet := ::EnviaComando( cComando )
  cRet := ::TrataRetorno( 1,cRet )

Conout("SWEDA 7000 - METHOD Pulalinha - Termino - "+ Time() )

Return(cRet)

//-------------------------------------------------------------
METHOD AchaPagto (cForma, aFormas) CLASS LJSweda
Local cRet
Local nPos
Local nTamanho

Conout("SWEDA 7000 - METHOD AchaPagto - Inicio - "+ Time() )
  
nPos := 0

For nTamanho := 1 to Len(aFormas)
	If Upper(aFormas[nTamanho]) == Upper(cForma) 
        nPos := nTamanho 
        nTamanho := Len(aFormas)        
 	EndIf
    If Len(AllTrim(Str(nPos))) < 2
      cRet := "0" + AllTrim(Str(nPos))
    else
      cRet := AllTrim(Str(nPos))
    EndIf   
Next nTamanho

Conout("SWEDA 7000 - METHOD AchaPagto - Termino - "+ Time() )

Return(cRet)

//-------------------------------------------------------------
METHOD EnviaComando(cComando, cBuffer) CLASS LJSweda
Local nExecblock	:= 0						// Contador que valida o numero de vezes que o RdMake SWEServ foi executado.

::EnviaCmd1(cComando, cBuffer)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Foi identificado que eventualmente o serviço SWEDANIX pára de responder.	    ³
//³Para corrigir esse problema, foi criado o PE SWEServ, que será chamado       ³
//³sempre que o Protheus identificar "erro de comunicação" e terá o objetivo de ³
//³baixar o serviço SWEDANIX e subí-lo novamente.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ".-P" $ oAutocom:cBuffer .AND. ExistTemplate("SWEServ")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O ponto de entrada poderah ser chamado ateh 5(nExecBlock) vezes consecutivas.  ³
	//³Sempre que ele for chamado, o comando sera enviado novamente.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (nExecBlock <= 5) .AND. (".-P" $ oAutocom:cBuffer)
		ExecTemplate("SWEServ",.F.,.F.)            
		nExecBlock += 1
		::EnviaCmd1(cComando, cBuffer)
	End
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Foi identificado que eventualmente o serviço SWEDANIX pára de responder.	    ³
//³Para corrigir esse problema, foi criado o PE SWEServ, que será chamado       ³
//³sempre que o Protheus identificar "erro de comunicação" e terá o objetivo de ³
//³baixar o serviço SWEDANIX e subí-lo novamente.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ".-P" $ oAutocom:cBuffer .AND. ExistBlock("SWEServ")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O ponto de entrada poderah ser chamado ateh 5(nExecBlock) vezes consecutivas.  ³
	//³Sempre que ele for chamado, o comando sera enviado novamente.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (nExecBlock <= 5) .AND. (".-P" $ oAutocom:cBuffer)
		ExecBlock("SWEServ",.F.,.F.)            
		nExecBlock += 1
		::EnviaCmd1(cComando, cBuffer)
	End
EndIf

Return(oAutocom:cBuffer)       

//-------------------------------------------------------------
METHOD EnviaCmd1 (cComando, cBuffer) CLASS LJSweda
Local nHandle		:= 0
Local lError		:= .F.
Local lRetLeitura
Local dTempo
Local dTempoIni
Local cLogFile		:= GetClientDir()+"sweda.log"						// Log de monitoramento dos comandos enviados a SWEDANIX
Local lExistFile	:= File(cLogFile)									// Existe o arquivo e faz o Log
Local nTimeOut		:= 15												// Controle de timeout da SwedaNix

Default cBuffer := Space(300)                           

If lExistFile
	LJWriteLog(cLogFile, DToC(dDataBase)+" "+Time()+" EnviaComando("+cComando+")")
EndIf

If oAutocom:cPlataforma == "WINDOWS"
	nRet := ExecDLL("Sweda_FI_EnviaComando",{cComando,cBuffer})
Else
	::cBuffer := ''
	lRetLeitura := .F.	
	If File(::cArqCmd)      
		If fErase(::cArqCmd) <> 0
			MsgSTop("Erro com o FErase em "+::cArqCmd)
		EndIf
	EndIf                
	If File(::cArqRet)
		If fErase(::cArqRet) <> 0
			MsgSTop("Erro com o FErase em "+::cArqRet)
		EndIf
	EndIf                

	nHandle := FCreate(::cArqCmd)
	If nHandle == -1
		If lExistFile
			LJWriteLog(cLogFile, DToC(dDataBase)+" "+Time()+" Deu erro no FCreate("+::cArqCmd+") .-P002}")
		EndIf
		oAutocom:cBuffer :=  ".-P002}"
		lError := .T.
	EndIf
	If !lError
		FWrite( nHandle, cComando, Len(cComando) )
		FClose( nHandle)             
		FRenameEx(::cArqCmd,::cArqRen)
	
		dTempoIni	:= Seconds()
		dTempo		:= dTempoIni
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento de time-out variou de 5 a 15 segundos. Conseguimos ver  ³
		//³ em testes em cliente que o ideal e' 15 segundos.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (dTempo - dTempoIni < nTimeOut) .AND. !lRetLeitura
			If File(::cArqRet)
				nHandle := FOpen( ::cArqRet, 2 )
				If nHandle == -1
					If lExistFile
						LJWriteLog(cLogFile, DToC(dDataBase)+" "+Time()+" Deu erro no FOpen("+::cArqRet+") .-P002}")
					EndIf
				Else
					FRead(nHandle, @oAutocom:cBuffer, 500)
					FClose(nHandle)
					lRetLeitura := .T.
					nRet := 0
				EndIf
			EndIf                
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dar um tempo para o processador                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcessMessages()
			dTempo   := Seconds()
		End  
    	If !lRetLeitura
    		If lExistFile
				LJWriteLog(cLogFile, DToC(dDataBase)+" "+Time()+" nao foi gerado o arq de resposta .-P002}")
			EndIf
			oAutocom:cBuffer :=  ".-P002}"
		Else
			If Empty(oAutocom:cBuffer)
				If lExistFile
					LJWriteLog(cLogFile, DToC(dDataBase)+" "+Time()+" Arquivo de resposta em branco .-P002}")
				EndIf
			EndIf
    	EndIf
   		If File(::cArqRet)
			If fErase(::cArqRet) <> 0
				MsgSTop("Erro com o FErase em "+::cArqRet)
			EndIf
		EndIf                
	EndIf
EndIf      
                          
If lExistFile
	LJWriteLog(cLogFile, DToC(dDataBase)+" "+Time()+" EnviaComando() -> "+oAutocom:cBuffer)
EndIf

Return(oAutocom:cBuffer)

//-------------------------------------------------------------
METHOD EnvCmdEspera (cTexto, nVezes) CLASS LJSweda
Local cRet    
Local nContador 
Local nSequencial 
Local nSequencial2 
Local nI 
Local bComandoOk   
Default nVezes := 1

nContador := 1
cRet := ""
bComandoOk := .F.

While (nContador <= nVezes) .AND. !bComandoOK

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz um tratamento diferente quando for o comando ESC.27 pois o ECF tem ³
	//³ um delay para retornar o comando                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If At( Chr(27)+".271", (cTexto) ) > 0 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia o comando original para o ECF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cRet := ""
        cRet := ::EnviaComando( cTexto )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena o retorno do ECF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        ::cBuffer := cRet

		If SubStr( ::cBuffer, 1, 3 ) <> ".+C" 
			bComandoOk := .F.
        ElseIf ::TrataRetorno( 1, ::cBuffer ) == "0" 
			bComandoOk := .T.
        Else
			bComandoOk := .F.
		EndIf
    Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega o numero sequencial do comando enviado para o ECF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nI := 0
		While nI <= 5 
			cRet := ::EnviaComando( Chr(27)+".23}" )
			If ::TrataRetorno( 1, cRet ) == "0"
				nI := 10
			Else
				nI += 1
				Sleep(500)
			EndIf
		End

		If ::TrataRetorno( 1, cRet ) == "0" 
	        If Val(SubStr( cRet, 9, 4 )) > 0
	          nSequencial := Val(SubStr( cRet, 9, 4 ))
	        Else
	          nSequencial := 1
    	    EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia o comando original para o ECF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRet := ""
			cRet := ::EnviaComando( cTexto )


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazena o retorno do ECF ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			::cBuffer := cRet

			If ::TrataRetorno( 1, cRet ) == "0" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega o número sequencial do comando enviado para o ECF ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nI := 0
				While nI <= 5
					cRet := ::EnviaComando( Chr(27)+".23}" )
					If (::TrataRetorno( 1, cRet ) == "0") .AND. !("-P00" $ cRet)
						nI := 10
					Else
						nI += 1
						Sleep(500)
					EndIf
				End

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega o número sequencial do comando enviado para o ECF ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Val(SubStr( cRet, 9, 4 )) > 0
					nSequencial := Val(SubStr( cRet, 9, 4 ))
				Else
					nSequencial := 1
				EndIf

				If ((nSequencial) <> nSequencial2) .AND. (nSequencial2 <> 1) 
					bComandoOk := .F.
				Else
					bComandoOk := .T.
				EndIf

			EndIf
		EndIf
	EndIf

    If !bComandoOk 
      Sleep( 200 * nContador )
      nContador += 1
    Else
      nContador := 20
	EndIf
End

If bComandoOk 
	cRet := "0"
Else
    cRet := "1"
EndIf
  
Return(cRet)

//-------------------------------------------------------------
METHOD IsECFOnLine(lTryAgain) CLASS LJSweda
Local cRet

Conout("SWEDA 7000 - METHOD IsECFOnLine - Inicio - "+ Time() )

cRet := ::EnviaComando( Chr(27)+".28}" )
If Substr(cRet,2,1) == "-" .AND. lTryAgain
	While Substr(cRet,2,1) == "-"
		If Aviso("Atenção", "Verifique se a impressora está ligada ou se o cabo está conectado corretamente. Deseja tentar novamente?", {"Sim","Não"},, "Impressora não responde") == 1
			cRet := ::EnviaComando( Chr(27)+".28}" )
		Else
			cRet := ".-P002}"
			Exit
		EndIf
	End
EndIf

Conout("SWEDA 7000 - METHOD IsECFOnLine - Termino - "+ Time() )

Return(Substr(cRet,2,1) == "+")

//-------------------------------------------------------------
METHOD TrataRet(cRetorno) CLASS LJSweda
Return(If(Substr(cRetorno,2,1)=="+",0,1))

//-------------------------------------------------------------
METHOD TrataRetorno (nTipo, cTexto) CLASS LJSweda
Local cRet := "0"   
Local cRetorno
Local nX

If nTipo == 1              			//Para operações que não incrementam sequencial.
 	If (SubStr(cTexto,2,1) == "-") .AND. (SubStr(cTexto,4,1) == "1")
		cRet := "5"
 	ElseIf (cTexto == ".-P006}")                         
		nX := 0
		cRetorno := ::EnviaComando( Chr(27)+".23}")
		nX += 1
		While (nX < 6) .AND. (cRetorno == ".-P006}")
			Sleep(3000)
			cRetorno := ::EnviaComando( Chr(27)+".23}")
    	    nX += 1
		End
		::TrataRetorno(1,cRetorno)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento quando a impressora nao responde ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
 	ElseIf (cTexto == ".-P002}")                         
		nX := 1
		Sleep(3000)		
		While (cRetorno := ::EnviaComando(Chr(27)+".28}")) == ".-P002}" .AND. nX < 1 /*MUDAR 3*/
		   nX       += 1		
		   Sleep(3000)		
		End			  
	    cRet        := IIf(SubStr(cRetorno,2,1) == "-","1","0")    	      
	ElseIf (SubStr(cTexto,2,1) == "-")
		cRet := "1"
	ElseIf (SubStr(cTexto,2,1) == "+" )
		cRet := "0"
	EndIf           
ElseIf nTipo == 2						//Para operaçõs que incrementam sequencial de operacao.
	If (SubStr(cTexto,2,1) == "-") 
		nX := 0
		cRetorno := ::EnviaComando( Chr(27)+".23}")
		nX += 1
		While (nX < 6) .AND. (SubStr(cRetorno,2,1) <> "+")
			cRetorno := ::EnviaComando( Chr(27)+".23}")
    	    nX := nX+1
		End
        If SubStr(cRetorno,2,1) == "+"
        	::nSeqAtual := Val(SubStr (cRetorno, 9, 4))
            If ::nSeqAtual == (::nUltimoSeq +1)
            	cRetorno := ::TrataRetorno (1, cRetorno)
            Else
            	cRet := ::TrataRetorno (1, cRetorno)
            EndIf
		Else
        	cRet := ::TrataRetorno (1, cRetorno)
		EndIf
	ElseIf	SubStr(cTexto,2,1) == "+" 
		::nUltimoSeq := Val(SubStr(cTexto, 3, 4))
		::TrataRetorno(1,cTexto)
	EndIf
EndIf 

Return(cRet)

//-------------------------------------------------------------
// FUNÇÕES AUXILIARES DA REDUÇÃO Z...
//-------------------------------------------------------------

//-------------------------------------------------------------
// Formata as alíquotas...
//-------------------------------------------------------------
Function FormataAliquota(cTributo)
Local cValor
Local cRetorno
Local nValor

Conout("SWEDA 7000 - FUNCTION FormataAliquota - Inicio - "+ Time() )

If SubStr(cTributo,1,3) == ""
	cRetorno := ""
//	Break
EndIf

cRetorno := FindAliquota( SubStr(cTributo,1,3) )
If AllTrim(cRetorno) <> ""
	//  Formata o campo: Aliquota "  " Valor "  " Imposto Debitado
	cValor := AllTrim(Str(Val(SubStr(cTributo, 4, 14))/100))    

	cValor := StrTransf(cValor, ",", ".")
	If At(".", cValor) == 0
		cValor += ".00"
	EndIf

	cValor := FormataTexto(cValor, 13, 2, 1, ".")
	nValor := Val(cValor)*Val(SubStr(StrTransf(cRetorno,",","."),2,5)) // ==>> 162,75
	cRetorno := cRetorno + " " + cValor + " " + FormataTexto(AllTrim(Str(Int(nValor)/100)), 12, 2, 1, ".")
EndIf

Conout("SWEDA 7000 - FUNCTION FormataAliquota - Termino - "+ Time() )

Return (cRetorno)

//------------------------------------------------------------------------------
// Procura a alíquota pelo índice. Exemplo: índice("TXX") devolve: TXX,XX...
//------------------------------------------------------------------------------
Function FindAliquota(cString)
Local nPosicao
Local cRetorno

Conout("SWEDA 7000 - FUNCTION FindAliquota - Inicio - "+ Time() )

	// Algumas impressoras podem conter valores nulos ao inv‚s de T??...
	If AllTrim(cString) == ""
		cRetorno := ""
//		Break
	EndIf
	// Procura a alíquota no primeiro pacote...
	cRetorno := oAutocom:oImpFisc:EnviaComando( Chr(27)+".293}") 
	nPosicao := At(cString,cRetorno)
	If (nPosicao > 0) .AND. (AllTrim(SubStr(cRetorno,nPosicao+3,4)) <> "")
		cRetorno := SubStr(cString,1,1)+SubStr(cRetorno,nPosicao+3,2)+","+SubStr(cRetorno,nPosicao+5,2)
	Else
		// Caso não encontre no primeiro pacote. Procura a alíquota no segundo pacote...
		cRetorno  := oAutocom:oImpFisc:EnviaComando( Chr(27)+".294}") 
		nPosicao := At(cString,cRetorno)
		If (nPosicao > 0) .AND. (AllTrim(SubStr(cRetorno,nPosicao+3,4)) <> "")
			cRetorno := SubStr(cString,1,1)+SubStr(cRetorno,nPosicao+3,2)+","+SubStr(cRetorno,nPosicao+5,2)
		Else
			// Caso não encontre no segundo pacote. Procura a alíquota no último pacote...
			cRetorno := oAutocom:oImpFisc:EnviaComando( Chr(27)+".295}") 
			nPosicao := At(cString,cRetorno)
			If (nPosicao > 0) .AND. (AllTrim(SubStr(cRetorno,nPosicao+3,4)) <> "")
				cRetorno := SubStr(cString,1,1) + SubStr(cRetorno,nPosicao+3,2)+","+SubStr(cRetorno,nPosicao+5,2)
			Else
				cRetorno := ""
			EndIf
		EndIf
	EndIf
	
Conout("SWEDA 7000 - FUNCTION FindAliquota - Termino - "+ Time() )	
	
Return(cRetorno)

//------------------------------------------------------------------------------
// Função que emite de fato a redução Z...
//------------------------------------------------------------------------------
METHOD EmiteReducaoZ(cData, cRetorno) CLASS LJSweda
Local cRet
//Local nContador
Local lRetorno
Local cComando
// Delay de aproximadamente 2 minutos para tentar emitir a Redução Z...
 
Conout("SWEDA 7000 - METHOD EmiteReducaoZ - Inicio - "+ Time() )
 
cComando := Chr(27)+".14N" + cData + "}"
cRet := ::EnviaComando( cComando )    // Redução Z = 14 .. Leitura X = 13
cRet     := ::TrataRetorno( 1, cRet )
If SubStr(cRet,1,1) == "0"
	::PulaLinha(7)
EndIf

lRetorno := (cRet =="0")

Conout("SWEDA 7000 - METHOD EmiteReducaoZ - Termino - "+ Time() )

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PegaRegistroºAutor  ³Adrianne          ºData  ³  xx/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para pegar número de registro do acumulador não      º±±
±±º          ³fiscal SANGRIA/SUPRIMENTO/RECEBIMENTO                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA / FRONTLOJA, interfaces de venda  - Autocom.dll    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAdrianne  ³20/09/05 - 811 ³Melhoria para os BOPS: 86680 e BOPS:86663   º±±
±±º			 ³				 ³- Alterado o metodo de busca dos 			  º±±
±±º			 ³				 ³acumuladores-nao-fiscais.					  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//------------------------------------------------------------------------------
// Função para pegar número de registro do acumulador não fiscal SANGRIA/SUPRIMENTO
//------------------------------------------------------------------------------
METHOD PegaRegistro( cCondicao) CLASS LJSweda
Local cRet
Local nI
Local aFormas := {}
Local cFormas
Local cPos
Local nTamanho
Local cTotalizador
Local cRetorno          
Local lAchou := .F.

Conout("SWEDA 7000 - METHOD PegaRegistro - Inicio - "+ Time() )

cRet    :="789ABCD"
cFormas :=""
For nI := 1 to 7 
	// Lendo todos as descrições dos registradores.
	cPos     := ::EnviaComando( Chr(27)+".29"+SubStr(cRet,nI,1)+"}")
	nTamanho := If(At("}",cPos)>0,At("}",cPos)-8, Len(cPos)- 7)	
	cFormas  := cFormas+SubStr(cPos,8,nTamanho)
Next nI
cFormas:=SubStr(cFormas,31,Len(cFormas))

While AllTrim(cFormas) <> ""
	AAdd(aFormas, SubStr(cFormas,1,15))
	cFormas:=SubStr(cFormas,16,Len(cFormas))
End

cPos  := "0"
cTotalizador:= "0"
For nI := 1 to Len(aFormas) 
	If !lAchou
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializando o TOTALIZADOR para que sPos nao pegue uma legenda de outro Titulo. ³
		//³ Pois a legenda somente podera ser do mesmo titulo.                               ³
		//³ Ex.                                                                              ³
		//³ 04 &SIGALOJA              -> Titulos                                             ³
		//³ 05    + FUNDO DE CAIXA    -> Legendas                                            ³
		//³ 06    - SANGRIA           -> Legendas                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SubStr(aFormas[nI],1,1)=="&") .AND. ( cTotalizador == "0" )
			cTotalizador := "0"
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pegar o codigo do titulo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr(AllTrim(Upper(aFormas[nI])),1,1) == "&"
			cTotalizador:= FormataTexto(AllTrim(Str(nI)),2,0,2)
			lAchou := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pegar o codigo da Legenda ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( AllTrim(Upper(SubStr(aFormas[nI],2,15))) == AllTrim(Upper(cCondicao)) ) .AND. ( Val(cTotalizador) > 0 )
			cPos := FormataTexto(AllTrim(Str(nI)),2,0,2)
			lAchou := .T.
		EndIf
	EndIf
Next nI                  
If !lAchou
	cTotalizador := "0"
EndIf
cRetorno := cPos + cTotalizador

Conout("SWEDA 7000 - METHOD PegaRegistro - Termino - "+ Time() )

Return (cRetorno)

