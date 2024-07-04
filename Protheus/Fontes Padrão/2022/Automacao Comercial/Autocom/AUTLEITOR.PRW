#INCLUDE "Protheus.ch"
#INCLUDE "AutLeito.ch"
Static cIniFile		:= GetClientDir()+"LEITORES.INI"  		//Patch + Nome do arquivo de configuracao 

Function AutLeitor_Dummy			// Funcao "Dummy" para poder gerar o Patch
Return(NIL)

CLASS AutLeitor
//	DATA  - Propriedades
	DATA nHandle 		// Numero do Handle do equipamento

	METHOD New()
	METHOD LeitorAbr	(cModelo,cPorta) 
	METHOD LeitorFec    (cPorta)
	METHOD LeitorFoco	(lModo)
ENDCLASS

METHOD New() CLASS AutLeitor
Return

METHOD LeitorAbr(cModelo,cPorta) CLASS AutLeitor
Local nRet			:=1                                    // Retorno da Funcao
Local aIni			:={}
Local nI			:=0
aadd(aIni,{"Device","Modelo",cModelo})
aadd(aIni,{"Device","Status","0"}) // Status do Leitor se esta aberto ou nao
aadd(aIni,{"RS232","Port",cPorta})
aadd(aIni,{"RS232","Baud","9600"})
aadd(aIni,{"RS232","DataBits","8"})
aadd(aIni,{"RS232","Parity","NONE"})
aadd(aIni,{"RS232","StopBits","2"})

If Upper(cModelo)=="METROLOG MS9520"
	//Gravacao do arquivo de configuracao LEITORES.INI
	For nI:=1 to Len(aIni)
		If GetPvProfString(aIni[nI][1],aIni[nI][2],"ERROR",cIniFile)=="ERROR"
			WritePProString(aIni[nI][1],aIni[nI][2],aIni[nI][3],cIniFile)
		EndIf
	Next nI
	
	If !File(GetClientDir()+"LEITCOMX.EXE")
		MsgInfo(STR0001+cModelo+STR0002+GetClientDir()+STR0003) //"Erro na abertura do Leitor "###" arquivo "###"LEITCOMX.EXE nao encontrado!!"
	Else
		// Executa o Programa Leitoes.exe que coloca no buffer do teclado tudo que esta na serial.
		WinExec(GetClientDir()+"LEITCOMX.exe")
		// Se o executavel abriu a porta corretamente, grava no arquivo LEITORES.INI
		// na sessao DEVICE Status 0
		For nI :=1 to 5
			Sleep(1000)
			If GetPvProfString("Device","Status","",cIniFile) == "9" // Erro de abertura da porta
				Exit
			ElseIf GetPvProfString("Device","Status","",cIniFile) == "0" //Sucesso ao abrir a porta
				nRet:=0
				Exit
			EndIf
		Next nI
	EndIf
EndIf
Return nRet

METHOD LeitorFec(cPorta ) CLASS AutLeitor
WritePProString("Device","Status","5",cIniFile)
Return(0)

METHOD LeitorFoco(lModo) CLASS AutLeitor
Return(0)
