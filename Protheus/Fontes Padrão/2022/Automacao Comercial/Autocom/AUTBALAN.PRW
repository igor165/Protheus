#INCLUDE "Protheus.ch"
Static cIniFile		:= GetClientDir()+"BALANCA.INI"  		//Patch + Nome do arquivo de configuracao 

Function AutBalanca_Dummy			// Funcao "Dummy" para poder gerar o Patch
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณAutBalancaบAutor  ณ Cesar Valadao      บ Data ณ  16/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da balanca Metrologic MS2020 e PSC Magellan 8100    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ16/01/07 - 811 ณHomologacao da balanca PSC Magellan 8100    บฑฑ
ฑฑบCesarValadณ17/11/09 - 912 ณHomologacao da balanca CAS PD-II            บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
CLASS AutBalanca
	DATA nHandle 		// Numero do Handle do equipamento
	DATA cModelo		// "Metrolog MS2020", "PSC Magellan 8100" ou "CAS PD-II"

	METHOD New()
	METHOD BalancaAbr   	(cModelo, cPorta)
	METHOD BalancaPegaPeso 	()
	METHOD BalancaFec		()
ENDCLASS

METHOD New() CLASS AutBalanca
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณBalancaAbrบAutor  ณ Cesar Valadao      บ Data ณ  16/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abertura da balanca                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ16/01/07 - 811 ณHomologacao PSC Magellan 8100               บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD BalancaAbr(cModelo, cPorta) CLASS AutBalanca
Local cCom		:= GetPvProfString("RS232-"+cEstacao, "Porta",		"ERROR", cInIfile )
Local cBaud		:= GetPvProfString("RS232-"+cEstacao, "Baud",		"ERROR", cInIfile )
Local cParity	:= GetPvProfString("RS232-"+cEstacao, "Parity",		"ERROR", cInIfile )
Local cDataBits	:= GetPvProfString("RS232-"+cEstacao, "DataBits",	"ERROR", cInIfile )
Local cStopBits	:= GetPvProfString("RS232-"+cEstacao, "StopBits",	"ERROR", cInIfile )

Local nRet			:=-1                                    // Retorno da Funcao
Local cCmdDec		:=""									// Comando para escrever na Balanca da Funcao

::cModelo	:= cModelo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGravacao do arquivo BALANCA.INI com os parametros DEFAULT, quando nao existir.ณ
//ณ[RS232-001]=>Sessao(RS232) + estacao configurada (001)                        ณ
//ณPort=COM1                                                                     ณ
//ณBaud=9600                                                                     ณ
//ณParity=E 																	 ณ
//ณDataBits=7																	 ณ
//ณStopBits=1																	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cCom<>cPorta
	WritePProString("RS232-"+cEstacao,"Porta",cPorta,cIniFile)
EndIf
If cBaud=="ERROR"
	WritePProString("RS232-"+cEstacao,"Baud","9600",cIniFile)
	cBaud:="9600"
EndIf
If cParity=="ERROR"
	WritePProString("RS232-"+cEstacao,"Parity","E",cIniFile)
	cParity:="E"
EndIf
If cDataBits=="ERROR"
	WritePProString("RS232-"+cEstacao,"DataBits","7",cIniFile)
	cDataBits:="7"
EndIf
If cStopBits=="ERROR"
	WritePProString("RS232-"+cEstacao,"StopBits","1",cIniFile)
	cStopBits:="1"
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbertura da porta de comunicacao                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nRet := CBOpenPort( Alltrim(cPorta)+":"+;	//Porta
					cBaud           +","+;	//Baud
					cParity         +","+;	//Parity
					cDataBits       +","+;	//DataBits
					cStopBits)				//StopBits

::nHandle:=nRet
If nRet <> -1
	cCmdDec:=CHR(L010Hex2Dec("02"))+;
    	     CHR(L010Hex2Dec("31"))+;
	         CHR(L010Hex2Dec("30"))+;
	         CHR(L010Hex2Dec("03"))+;
	         CHR(L010Hex2Dec("01"))+;
	         CHR(L010Hex2Dec("03"))
EndIf

Return(nRet)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Metodo   ณBalancaFecบAutor  ณ Cesar Valadao      บ Data ณ  16/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fechamento da balanca                                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ16/01/07 - 811 ณHomologacao PSC Magellan 8100               บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD BalancaFec() CLASS AutBalanca
Local nRet := -1

If FClose(::nHandle)
   ::nHandle := NIL
   nRet := 0
EndIf   

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบ Metodo   ณBalancaPegaPesoบAutor ณ Cesar Valadao     บ Data ณ 16/01/07 บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Pegar o peso da balanca                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCesar     ณ16/01/07 - 811 ณHomologacao PSC Magellan 8100               บฑฑ
ฑฑบCesarValadณ17/11/09 - 912 ณHomologacao da balanca CAS PD-II            บฑฑ
ฑฑศออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD BalancaPegaPeso() CLASS AutBalanca
Local nRet		:= 1
Local nBytes    := 0
Local cByteLido	:= ""
Local cTexto	:= ""
Local cAux		:= ""
Local nI		:= 0
Local cCmdDec	:= ""
Local nV		:=0

If Upper(::cModelo) == "METROLOG MS2020"
	cCmdDec	:=	CHR(L010Hex2Dec("02"))+;
				CHR(L010Hex2Dec("31"))+;
				CHR(L010Hex2Dec("31"))+;
				CHR(L010Hex2Dec("03"))+;
				CHR(L010Hex2Dec("01"))+;
				CHR(L010Hex2Dec("03"))
	nBytes	:= FWrite(::nHandle,cCmdDec )
	ProcessMessage()
	Sleep(100)
	cByteLido:=Space(10)
	While Empty(cByteLido).AND.nV<10
		nBytes:=fread(::nHandle,@cByteLido,10)	// Neste caso estou fazendo leitura byte a byte, mas nada impede que eu lei com mais bytes
		If (nBytes==0)
			FWrite(::nHandle,cCmdDec )
			Sleep(200)
			nV++
			Loop
		EndIf
		cAux:=""
		For nI:= 1 to Len(cByteLido)
			cAux+=L010Dec2Hex(Asc(Subs(cByteLido,nI,1)))
		Next nI
		If Subs(cAux,1,6)<>"023131"
			cByteLido:=Space(10)
			nV++
		Else
		   Exit
		EndIf
		ProcessMessage()
	end
	If nV=10
		oAutocom:cBuffer:="00.000"
	Else
		cTexto+=cByteLido
		cAux:=""
		For nI:= 1 to Len(cTexto)
			cAux+=L010Dec2Hex(Asc(Subs(cTexto,nI,1)))
		Next nI
		oAutocom:cBuffer:=Subs(cAux,8,1)+Subs(cAux,10,1)+"."+Subs(cAux,12,1)+Subs(cAux,14,1)+Subs(cAux,16,1)
		If !empty(oAutocom:cBuffer)
			nRet:=0
		EndIf
	EndIf
ElseIf Upper(::cModelo) == "PSC MAGELLAN 8100"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Os parametros de fabrica sao:                               ณ
	//ณ Baud: 9600                                                  ณ
	//ณ Parity: Even                                                ณ
	//ณ Data Bits: 7                                                ณ
	//ณ Stop Bits: 1                                                ณ
	//ณ Para solicitar o peso da balanca envie o caracter 'W'.      ณ
	//ณ O retorno tera o seguinte formato: Chr(2)+<nn.nnn>+Chr(13). ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cCmdDec	:= "W"											// Comando a ser enviado
	nBytes	:= FWrite(::nHandle, cCmdDec)
	Sleep(200)
	cByteLido := Space(10)
	While Empty(cByteLido) .AND. nV<10
		nBytes := FRead(::nHandle, @cByteLido, 10)			// Leitura do retorno
		If nBytes == 0
			FWrite(::nHandle, cCmdDec)
			Sleep(200)
			nV++
			Loop
		EndIf
		If Substr(cByteLido,1,1) == Chr(2)					// Chr(2) == STX
			Exit
		EndIf
	End
	If nV == 10
		oAutocom:cBuffer := "00.000"
	Else
		oAutocom:cBuffer := Substr(cByteLido, 2, 6)
		nRet := 0
	EndIf
ElseIf Upper(::cModelo) == "CAS PD-II"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Os parametros de fabrica sao:                                       ณ
	//ณ Baud: 9600                                                          ณ
	//ณ Parity: Even                                                        ณ
	//ณ Data Bits: 7                                                        ณ
	//ณ Stop Bits: 1                                                        ณ
	//ณ Para solicitar o peso da balanca envie o caracter Chr(17).          ณ
	//ณ O retorno tera o seguinte formato: Chr(1)+Chr(2)+Chr(83)+<nnn.nnn>. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cCmdDec	:= Chr(17)										// Comando a ser enviado
	nBytes	:= FWrite(::nHandle, cCmdDec)
	Sleep(200)
	cByteLido := Space(20)
	While Empty(cByteLido) .AND. nV<10
		nBytes := FRead(::nHandle, @cByteLido, 20)			// Leitura do retorno
		If nBytes == 0
			FWrite(::nHandle, cCmdDec)
			Sleep(200)
			nV++
			Loop
		EndIf
		If Substr(cByteLido,1,3) == Chr(1)+Chr(2)+Chr(83)	// Informacao lida corretamente
			Exit
		EndIf
	End
	If nV == 10
		oAutocom:cBuffer := "00.000"
	Else
		oAutocom:cBuffer := AllTrim(Substr(cByteLido, 4, 7))
		nRet := 0
	EndIf
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณL010Hex2Dec()ณ Autor ณ Sergio / Luiz 	    ณ Data ณ 12/06/97 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Converte um numero Hexadecimal para decimal ate' 65535     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ ExpN1 := L010Hex2Dec( ExpC1 ) 							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpC1 -> String a converter ( ate 4 bytes )				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorna	 ณ ExpN1 -> Numero decimal 									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ LOJA010T 												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L010Hex2Dec(cVal)

Local cString := "0123456789ABCDEF"
Local nVal    := 0

If Len(cVal) < 4
	cVal:= Replicate("0", 4 - Len(cVal) ) + cVal
Endif
nVal := ( At( Left( cVal, 1 )   , cString ) - 1  ) * 4096
nVal += ( At( Substr( cVal, 2, 1 ), cString ) - 1  ) * 256
nVal += ( At( Substr( cVal, 3, 1 ), cString ) - 1  ) * 16
nVal += ( At( Substr( cVal, 4, 1 ), cString ) - 1  )

Return( nVal )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณL010Dec2Hex  ณ Autor ณ Microsiga          ณ Data ณ 12/06/97 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Converte um numero decimal hexadecimal 					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ ExpC1 := L010Dec2Hex(nVal)    							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParmetrosณ ExpN1 -> Decimal a converter 							  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorna	 ณ ExpC1 -> String hexadecimal								  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ AUTBALAN 												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function L010Dec2Hex(nVal)

Local cString := "0123456789ABCDEF"
Local cRet    := Substr(cString,Int(nVal/16)+1,1)+Substr(cString,nVal-(Int(nVal/16)*16)+1,1)

Return (cRet)
