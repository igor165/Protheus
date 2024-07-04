#INCLUDE "TMKDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMKA061A.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "COLORS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA061A  บAutor  ณRafael M Quadrotti  บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFonte com as funcoes de TELA da Lista de Contato.           บฑฑ
ฑฑบ          ณTmka061                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8 - Lista de Contato.                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061Data     บAutor  ณ Vendas Clientes    บ Data ณ  07/15/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada no valid do U4_DATA. efetua o preenchimento do U6_DATA.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK061DATA()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis					             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aPosicoes := {}	// Array auxiliar onde serao armazenadas as posicoes dos campos.
Local nPData    := 0                                    
Local nI		:= 0	// Controle de data do aCols			


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica posicionamento dos campos (ordem)            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aPosicoes,{"U6_DATA"   ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_DATA"})})	//1
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazena posicionamento dos campos para selecao dos dados (ordem) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPData  := aPosicoes[1][2]
For nI := 1 To Len(aCols)
	If M->U4_DATA <> aCols[nI][nPData]
		aCols[nI][nPData] := M->U4_DATA
	Endif
Next nI	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061LinOk    บAutor  ณ Vendas Clientes    บ Data ณ  07/15/03   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da linha para inclusao manual.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061LinOk()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclaracao de variaveis					             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aPosicoes := {}	// Array auxiliar onde serao armazenadas as posicoes dos campos.
Local nPContato  := 0                                    
Local nPHrIni    := 0                                    
Local nPHrFim    := 0                                    
Local nPEntida   := 0
Local nPEntCont  := 0
Local cHrIniCont := ""
Local cHrFimCont := ""
Local aAux		 := {}
Local nI		 := 0
Local lRet		 := .F.


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica posicionamento dos campos (ordem)            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aPosicoes,{"U6_CONTATO" ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_CONTATO"})})	//1
Aadd(aPosicoes,{"U6_ENTIDA"  ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_ENTIDA" })})	//2
Aadd(aPosicoes,{"U6_HRINI"   ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_HRINI"  })})	//3
Aadd(aPosicoes,{"U6_HRFIM"   ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_HRFIM"  })})	//4
Aadd(aPosicoes,{"U6_CODENT"  ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_CODENT" })})	//5

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArmazena posicionamento dos campos para selecao dos dados (ordem) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPContato:= aPosicoes[1][2] 
nPEntida := aPosicoes[2][2] 
nPHrIni  := aPosicoes[3][2] 
nPHrFim  := aPosicoes[4][2]
nPEntCont:= aPosicoes[5][2]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusca informacoes do contato                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nModulo <> 73 //SIGACRM
	cHrIniCont := TK061Contato(aCols[n][nPContato],"U5_HORA1")
	cHrFimCont := TK061Contato(aCols[n][nPContato],"U5_HORA2")
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEfetua verificacoes                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cHrIniCont) .AND. !Empty(cHrFimCont) .AND. !aCols[n][Len(aHeader)+1]

	If cHrIniCont >= aCols[n][nPHrIni] 	.AND. cHrIniCont<= aCols[n][nPHrFim]
		lRet := .T.
	ElseIf cHrFimCont >= aCols[n][nPHrIni] 	.AND. cHrFimCont<= aCols[n][nPHrFim]
		lRet := .T.	
	Else
		Help(" ",1,"TK061HRINV")
		lRet := .F.
	Endif
Else
	lRet := .T.	
Endif	

If lRet .AND. Empty(aCols[n][nPContato]) .AND. !aCols[n][Len(aHeader)+1] .And. nModulo <> 73 //SIGACRM
	lRet := .F.
	Help(" ",1,"TK061NOCON")
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se os registros estao duplicados.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aCols) > 1
	aAux := aCols[n]
	For nI := 1 To Len(aCols)
    	If	aCols[nI][nPContato] == aAux[nPContato] .AND. ;
			aCols[nI][nPEntCont] == aAux[nPEntCont] .AND. ;
			nI <> n .AND. ;
			!aAux[Len(aHeader)+1] .AND. ;
			!aCols[nI][Len(aHeader)+1]  
    		
    		lRet := .F.
			Help(" ",1,"TK061JAINF")    		 
			
    	Endif
	Next nI
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัอออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณTK061Imp   บAutor ณ Vendas Clientes     บ Data ณ  30/07/03  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯอออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Imprime a mala direta a partir do menu   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                     	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061Imp(	cAlias	,nReg		,nOpc	,Param4	,;
					cMens	,lUseVarMem	)

Local oDlg  
Local lEtiq    := .F.
Local lMala    := .F.
Local oEtiq 
Local oMala
Local cLblEtiq := STR0001 //"Etiquetas"
Local cLblMala := STR0002 //"Mala Direta"
Local cMyAlias := "SU4"

Default cMens := STR0003 //"Escolha abaixo o que deseja imprimir."
Default lUseVarMem := .F.

If lUseVarMem
	cMyAlias := "M"
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o arquivo esta vazio.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lUseVarMem .AND. SU4->(Eof())
	Help(" ",1,"A000FI")

Elseif ((cMyAlias)->U4_FORMA <> "4")// Mala Direta
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso a Lista nใo seja para Mala direta executaณ
	//ณ	relat๓rio da Lista.						     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Help(" ",1,"TK061NOMA") //("Esta lista nao e mala direta !")
	TMKR020()
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 150,300 TITLE STR0004 PIXEL //"Impressใo Mala Direta/Etiquetas"
	
		@ 03,10 SAY cMens OF oDlg PIXEL SIZE 145,25
		
		@ 25,0 TO 26,250 OF oDlg PIXEL
		
		@ 33,10 CHECKBOX oMala VAR lMala SIZE 130,8 PIXEL OF oDlg PROMPT cLblMala
		
		@ 45,10 CHECKBOX oEtiq VAR lEtiq SIZE 130,8 PIXEL OF oDlg PROMPT cLblEtiq
		
		// C๓digos de Status
		// 1 - Nada impresso
		// 2 - Mala e Etiqueta impressos
		// 3 - Somente mala impressa
		// 4 - Somente Etiqueta impressa
		If ((cMyAlias)->U4_STATUS == "2")
			lEtiq := .F.
			lMala := .F.
			oEtiq:Disable()
			oMala:Disable()
			cLblEtiq := STR0005 //"Etiquetas (Jแ impresso)"
			oEtiq:cTitle := cLblEtiq
			cLblMala := STR0006 //"Mala Direta (Jแ Impresso)"
			oMala:cTitle := cLblMala

		Elseif ((cMyAlias)->U4_STATUS == "3")

		 	If ((cMyAlias)->U4_LABEL == "1")
				lEtiq := .T.
			Else
				lEtiq := .F.
				oEtiq:Disable()
				cLblEtiq := STR0007 //"Etiquetas (Nใo Imprimir)"
				oEtiq:cTitle := cLblEtiq
			Endif
			lMala := .F.
			oMala:Disable()
			cLblMala := STR0008 //"Mala Direta (Jแ Impresso)"
			oMala:cTitle := cLblMala

		Elseif ((cMyAlias)->U4_STATUS == "4")
			lEtiq := .F.
			lMala := .T.
			oEtiq:Disable()
			cLblEtiq := STR0009 //"Etiquetas (Jแ impresso)"
			oEtiq:cTitle := cLblEtiq
		Endif
		
		DEFINE SBUTTON FROM 60,088 TYPE 1 ENABLE OF oDlg ACTION (TK061Imprime( lEtiq, lMala, cMyAlias ),oDlg:End()) //Fecha a tela
		DEFINE SBUTTON FROM 60,120 TYPE 2 ENABLE OF oDlg ACTION oDlg:End() //Fecha a tela
		
	ACTIVATE MSDIALOG oDlg CENTER
Endif

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTk061Visualณ Autor ณ Vendas Clientes       ณ Data ณ 30/07/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณExibe o arquivo de MALA-DIRETA e o de ETIQUETAS              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณLista de Contatos                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Tk061Visual()

Local oDlg
Local aOpcoes   := {STR0002,STR0001}	
Local nOpca     := 0
Local nArquivo  := 1
Local oArquivo
Local lRet      := .F.

If M->U4_FORMA <> "4"// Mala direta
	Help(" ",1,"TK061TPMAL") //O tipo nao e mala direta. Selecione o tipo Mala direta.
	Return(lRet)
Endif


DEFINE MSDIALOG oDlg FROM  00,00 TO 100,260 TITLE STR0010  PIXEL OF oMainWnd //"Visualizacao de Arquivos"

	@ 02,02 TO 50,85 LABEL "" OF oDlg PIXEL
	
	@ 06,04 RADIO oArquivo VAR nArquivo PROMPT aOpcoes[1],aOpcoes[2] OF oDlg SIZE 80,20 DESIGN 3D PIXEL
	
	DEFINE SBUTTON FROM 05,95 TYPE 1 ENABLE OF oDlg ACTION (nOpca:= 1, oDlg:End())
	
	DEFINE SBUTTON FROM 25,95 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
	

ACTIVATE MSDIALOG oDlg CENTERED

If (nOpca == 1)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a escolha foi mala direta verifica se o arquivo foi selecionado.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (nArquivo == 1)
		If !Empty(M->U4_MALADIR)
			Tk061ExibeArquivo(M->U4_MALADIR)
		    lRet := .T.
		Else
			Help(" ",1,"TK061VISMA")//("Selecione o arquivo de mala direta para visualizacao")
		Endif
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณSe a escolha foi etiqueta verifica se o arquivo foi selecionado.   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(M->U4_ETIQUET)
			Tk061ExibeArquivo(M->U4_ETIQUET)
			lRet := .T.
		Else
			Help(" ",1,"TK061VISET") //("Selecione o arquivo de etiqueta para visualizacao")
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK061NiverบAutor  ณ Vendas Clientes    บ Data ณ  31/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para definicao da data de aniversแrio da lista.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061Niver(nAniVer,nPeriod,nOpc,lLstDiaria)

Local oDlg
Local oPanel
Local oPanel2
Local oPanel3
Local oDiaNiver
Local cDiaNiver	:=space(2) 
Local aDiaNiver := {"01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"}
Local oMesNiver 
Local cMesNiver	:= space(2)
Local aMesNIver	:= {"01","02","03","04","05","06","07","08","09","10","11","12"}
Local oAnoNiver
Local cAnoNiver	:= space(2)
Local lPCk1		:= .T.
Local lPck2		:= .F.        
Local dDt1		:= CTOD("//")
Local oDt1
Local dDt2		:= CTOD("//")
Local oDt2
Local nRNiver	:= 1
Local oRNiver

Local lOk := .F.

If nPeriod == 1 
	If TmkOk(STR0011)//"Para esta lista a op็ใo de Lista de Periodicidade jแ foi selecionada. Deseja cancelar a Periodicidade e Gerar Lista para Aniversแrio?"
		nPeriod := 2          
		M->U4_PROSPEC := "2"
	Else
		nAniVer := 0
		M->U4_CONTATO := Space(5)
		Return (Nil)
	Endif
Endif

If nOpc == VISUAL .OR. nOpc == ALTERAR
	cDiaNiver := SUBSTR(M->U4_CONTATO,1,2)
	cMesNiver := SUBSTR(M->U4_CONTATO,4,2)
	cAnoNiver := M->U4_OCODISC
	dDt1	  := SUBSTR(M->U4_NSTATUS,1,10) 
	dDt2	  := SUBSTR(M->U4_NSTATUS,11,10) 
Endif

DEFINE MSDIALOG oDlg TITLE STR0012 FROM 0,0 TO 400,350 PIXEL OF oMainWnd //"Configura็ใo da lista de Aniversแrio"

   
	@ 33,02 CHECKBOX oPCk1 VAR lPCk1 SIZE 150,10 PIXEL OF oDlg PROMPT STR0047 ON CHANGE (Iif(lPck1,lPck2:=.F.,lPck2:=.T.),oPck2:Refresh(),oPanel:Refresh(),oPanel2:Refresh(),IIf(lPck2,oDt1:SetFocus(),oDiaNiver:SetFocus())) //"Lista com data definida. "
	
	@ 43,02 MSPANEL oPanel PROMPT "" SIZE 170,050 OF oDlg CENTERED LOWERED
	@ 03,05  SAY STR0013 OF oPanel PIXEL SIZE 150,9 //"Informe a data de aniversแrio para gera็ใo da lista."
	@ 20,10  SAY STR0014 OF oPanel PIXEL SIZE 150,9 COLOR CLR_BLUE //"Data do Aniversแrio:"
	@ 17,65 MSCOMBOBOX oDiaNiver VAR cDiaNiver  ITEMS aDiaNiver SIZE 24, 10 OF oPanel PIXEL WHEN ((nOpc == INCLUIR .OR. nOpc == INCLUIAUTO .OR. nOpc == ASSISTENTE) .AND. lPck1)
	@ 20,90  SAY STR0043 OF oPanel PIXEL SIZE 150,9 COLOR CLR_BLUE //"M๊s:"
	@ 17,105 MSCOMBOBOX oMesNiver VAR cMesNiver ITEMS aMesNiver SIZE 24, 10 OF oPanel PIXEL WHEN ((nOpc == INCLUIR .OR. nOpc == INCLUIAUTO .OR. nOpc == ASSISTENTE) .AND. lPck1)   
	@ 40,10  SAY STR0044 OF oPanel PIXEL SIZE 150,9 COLOR CLR_BLUE //"Lista por Idade:"
	@ 37,105 MSGET oAnoNiver VAR cAnoNiver SIZE 15, 10 OF oPanel PIXEL WHEN ((nOpc == INCLUIR .OR. nOpc == INCLUIAUTO .OR. nOpc == ASSISTENTE) .AND. lPck1)

	@ 96,02 CHECKBOX oPCk2 VAR lPCk2 SIZE 150,10 PIXEL OF oDlg PROMPT STR0048 ON CHANGE (Iif(lPck2,lPck1:=.F.,lPck1:=.T.),oPck1:Refresh(),oPanel:Refresh(),oPanel2:Refresh(),IIf(lPck2,oDt1:SetFocus(),oDiaNiver:SetFocus()))//"Lista para sele็ใo de um periodo."
	@ 105,02 MSPANEL oPanel2 PROMPT "" SIZE 170,090 OF oDlg CENTERED LOWERED 
	@ 05,02  SAY STR0049 OF oPanel2 PIXEL SIZE 150,9 //"Data inicial: "
	@ 17,02 MSGET oDt1 VAR dDt1 SIZE 45, 10  OF oPanel2 PIXEL WHEN ((nOpc == INCLUIR .OR. nOpc == INCLUIAUTO .OR. nOpc == ASSISTENTE) .AND. lPck2)
	@ 35,02  SAY STR0050 OF oPanel2 PIXEL SIZE 150,9//"Data Final: "
	@ 47,02 MSGET oDt2 VAR dDt2 SIZE 45, 10  OF oPanel2 PIXEL WHEN ((nOpc == INCLUIR .OR. nOpc == INCLUIAUTO .OR. nOpc == ASSISTENTE) .AND. lPck2)
	
	@ 59,04 RADIO oRNiver VAR nRNiver PROMPT STR0051,STR0052 OF oPanel2 SIZE 150,10 DESIGN 3D PIXEL WHEN ((nOpc == INCLUIR .OR. nOpc == INCLUIAUTO .OR. nOpc == ASSISTENTE) .AND. lPck2)//"Gerar uma Lista para cada dia." "Gerar uma lista com o intervalo de dias selecionado."


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, 	{|| IIF(EMPTY(CTOD(Alltrim(cDiaNiver)+"/"+Alltrim(cMesNiver)+"/"+Alltrim(IIF(Empty(cAnoNiver),"00",cAnoNiver)))	),(MsgStop(STR0046),.F.),(lOk:=.T.,nAniVer:=1,oDlg:End())) },;//"Data Invแlida."
					 										{|| oDlg:End()} )

If nOpc == INCLUIR .OR. nOpc == INCLUIAUTO  .OR. nOpc == ASSISTENTE
	If !lOk
		nAniVer := 0
	Else
		If lPck1
			M->U4_CONTATO := cDiaNiver+"/"+cMesNiver // Campo onde serแ armazenada a data de aniversario.
			M->U4_OCODISC := cAnoNiver
		Else
			M->U4_NSTATUS := DTOC(dDt1)+DTOC(dDt2)  //Armazena a data De / Ate.
			If nRNiver == 1
				lLstDiaria := .T.
			Else
				lLstDiaria := .F.
			EndIf	
		Endif	
	Endif
Endif

Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK061PerioบAutor  ณ Vendas Clientes    บ Data ณ  31/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela para definir a lista de periodicidade.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061Period(nPeriod,nAniver,nOpc)

Local oDlg
Local oPanel
Local oPeriod
Local lOk		:= .F. // Controle para armazenamento de informacoes.

If nAniver == 1 
	If TmkOk(STR0015) //"Para esta Lista a op็ใo de Lista de Aniversแrio jแ foi selecionada. Deseja cancelar a Lista de Aniversแrio e gerar Lista de Periodicidade?"
		nAniver := 0
		M->U4_CONTATO := space(5)
	Else
		nPeriod := 2
		M->U4_PROSPEC := "2"
		Return (Nil)
	Endif
Endif

If nOpc == VISUAL .OR. nOpc == ALTERAR
	nPeriod := M->U4_PROSPEC
	lOk := IIF(nPeriod=="1",.T.,.F.)
Endif

DEFINE MSDIALOG oDlg TITLE STR0016 FROM 0,0 TO 150,350 PIXEL OF oMainWnd	//"Configura็ใo da lista de Periodicidade"

	EnchoiceBar(oDlg, {|| (oDlg:End()) }, {|| oDlg:End()} )

	@ 18,02 MSPANEL oPanel PROMPT "" SIZE 170,050 OF oDlg CENTERED LOWERED
	@ 03,05  SAY STR0017 OF oPanel PIXEL SIZE 150,20 //"Selecione se a lista serแ ou nใo pelo ultimo registro de contato."
	@ 25,10 CHECKBOX oPeriod VAR lOk SIZE 150,10 PIXEL OF oPanel PROMPT STR0018 WHEN (nOpc == INCLUIR .OR. nOpc == INCLUIAUTO) // Avaliara data do ultimo atendimento para cada contato.

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc == INCLUIR .OR. nOpc == INCLUIAUTO
	If !lOk
		nPeriod := 2 // NAO
	Else
		nPeriod := 1
		M->U4_PROSPEC := "1" // Campo onde serแ armazenado flag para lista de periodicidade. 
	Endif
Endif

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK061Copy บAutor  ณ Vendas Clientes    บ Data ณ  31/07/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface de copia de lista.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061Copy(cAlias,nReg,nOpc)

Local lRet			:= .F.						// Retorno da funcao
Local oWizard
Local oData
Local dData			:= CTOD("//")
Local oNome
Local cNome			:= Criavar("U4_DESC",.F.)
Local oMeter
Local nMeter		:= 0
Local oSay
Local cSay			:= ""
Local oSDat
Local cSDat			:= ""
Local oOperad												// Objeto para get do operador
Local cOperad		:= Criavar("U4_OPERAD",.F.)			// Descricao do operador
Local oSayOper												// Objeto com say para operador.
Local cSayOper		:= ""									// Descricao do operador


DbSelectArea(cAlias)
DbSetOrder(1)
If !DbSeek(xFilial(cAlias))
	Help( " ", 1, "ARQVAZIO" )
	Return(lRet)
Else
	DbGoto(nReg)
	cOperad := SU4->U4_OPERAD // Sugere o operador da Lista posicionada.
	cSayOper:= Posicione("SU7",1,xFilial("SU7")+cOperad,"U7_NOME")
Endif

//"Copia de Lista" "Informe os dados para c๓pia."
DEFINE WIZARD oWizard TITLE STR0019 HEADER " " MESSAGE STR0020  TEXT " " ;
	NEXT {||IIF(!Empty(dData) .AND. !EMPTY(cNome) .AND. Tk061CpyVal(dData) .AND. IIF(nModulo == 73, .T.,!EMPTY(cSayOper)),.T.,.F.) } FINISH {||.F.} PANEL NOFIRSTPANEL 
	
	//ฺฤฤฤฤฤฤฤฟ
	//ณPanel 1ณ
	//ภฤฤฤฤฤฤฤู
	
	oWizard:GETPANEL(1)

	@ 10,20  SAY STR0045 OF oWizard:GETPANEL(1) PIXEL SIZE 150,9 //"Lista selecionada :"
	@ 10,65  SAY SU4->U4_LISTA+"-"+Alltrim(SU4->U4_DESC) OF oWizard:GETPANEL(1) COLOR CLR_RED PIXEL SIZE 200,9 
	
	@ 30,20  SAY STR0021 OF oWizard:GETPANEL(1) PIXEL SIZE 150,9 //"Data da nova Lista:"
	@ 40,20 MSGET oData VAR dData SIZE 40, 10  OF oWizard:GETPANEL(1) VALID(!EMPTY(dData),cSDat :=Tk_DiaSemana( dData,,0) ,oSDat:Refresh())PIXEL
	@ 42,65 SAY oSDat Var cSDat OF oWizard:GETPANEL(1) PIXEL SIZE 210,9 

	@ 60,20  SAY STR0022 OF oWizard:GETPANEL(1) PIXEL SIZE 150,9 //"Nome da nova Lista:"
	@ 70,20 MSGET oNome VAR cNome SIZE 200, 10 VALID !EMPTY(cNome) OF oWizard:GETPANEL(1) PIXEL    
	
	If nModulo <> 73
		@ 90,20 SAY STR0053 OF OWizard:GETPANEL(1) PIXEL SIZE 210,9 		//"Selecione o Operador para esta lista:"
		@ 100,20 MSGET oOperad VAR cOperad SIZE 35, 10 F3 "SU7" OF OWizard:GETPANEL(1) VALID Tk061VldOper(@cSayOper,@cOperad,@oSayOper) PIXEL    
		@ 102,60 SAY oSayOper Var FATPDObfuscate(cSayOper,"U7_NOME") OF oWizard:GETPANEL(1) PIXEL SIZE 210,9 
		FATPDLogUser('TK061COPY')	// Log de Acesso LGPD
	EndIf 
	//ฺฤฤฤฤฤฤฤฟ
	//ณPanel 2ณ 
	//ภฤฤฤฤฤฤฤู

	CREATE PANEL oWizard  HEADER STR0023 MESSAGE STR0024 ; //"Confirma็ใo" "Os dados informados foram: "
			 BACK {||.T.};
			 NEXT {||.F.};
			 FINISH {||Tk061Copia(	oSay	,oMeter	,cAlias	,nReg	,;
			 						nOpc	,cNome	,dData	,cOperad)} PANEL
	oWizard:GETPANEL(2)

	@ 10,10 TO 70,190 LABEL '' OF oWizard:GETPANEL(2)  PIXEL
	@ 20,20  SAY STR0021 +"  "+ DTOC(dData)+"-"+cSDat OF oWizard:GETPANEL(2) PIXEL SIZE 150,9  //"Data da Lista:   " 
	@ 45,20  SAY STR0022 +"  "+ cNome OF oWizard:GETPANEL(2) PIXEL SIZE 250,9  //"Nome da Lista:   "
	
	cSay:=STR0025 //"Aguarde enquanto a nova lista ้ gerada... "

	@80,10  SAY oSay Var cSay  OF oWizard:GETPANEL(2) PIXEL SIZE 250,9 
	
 	/*
 	 O "METER" Sera feito com o CONSTRUCTOR da CLASSE porque o TMKDEF.CH tem um DEFINE TOTAL que 
 	 conflita com a PROPRIEDADE TOTAL do objeto METER
 		
 	 [ <oMeter> := ] TMeter():New( 	<nRow>, <nCol>, bSETGET(<nActual>),;
								    <nTotal>, <oWnd>, <nWidth>, <nHeight>, <.update.>, ;
								    <.lPixel.>, <oFont>, <cPrompt>, <.lNoPercentage.>,;
								    <nClrPane>, <nClrText>, <nClrBar>, <nClrBText>, <.lDesign.> )
	*/
		
	oMeter	:= TMeter():New(90					,10	,bSETGET(nMeter),100	,;
							oWizard:GETPANEL(2)	,10	,140			,.T.	,;
							.T.)
							
	//@90,10 METER oMeter VAR nMeter TOTAL 100 SIZE 140,10 OF oWizard:GETPANEL(2) PIXEL
	oMeter:Hide()
	oSay:Hide()

ACTIVATE WIZARD oWizard CENTERED  WHEN {||.T.}

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณTk061EntCont  ณ Autor ณ Vendas Clientes       ณ Data ณ 30/07/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณMostra todas as entidades dos contatos    	                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso   	 ณLista de Contatos      				     				      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Tk061EntCont( cContato )

Local aArea     := GetArea()			//Salva a area atual
Local aCont     := {}					//Array com os contatos
Local nOpcao    := 0					//Opcao de resposta
Local nPos		:= 0					//Posicao escolhida no array
Local oLbx								//Listbox
Local oDlg								//Tela	
Local cEnt     	:= Space(3)				//Alias da Entidade
Local cCodEnt  	:= Space(25)			//Codigo da Entidade	
Local cEntidade := ""					//Alias : SA1
Local cDescInd 	:= Space(40)			//Indice: Codigo + Loja
Local cChave    := ""					//Codigo: 00000101
Local cDescChave:= ""					//Descr : Empresa X Ltda.
Local cDescEnt 	:= Space(40)			//Nome  : Cadastro de Clientes
Local cDescCod 	:= Space(40)           	//Nome da Empresa de acordo com a entidade             			
Local aPosicoes := {}  					//Array auxiliar onde serao armazenadas as posicoes dos campos.
Local nPNContat := 0                   	//Posicao do campo CONTATO
Local nPFilEnt  := 0                   	//Posicao do campo FILIAL
Local nPCodEnt  := 0                  	//Posicao do campo CODIGO ENTIDADE
Local nPDescEnt := 0                   	//Posicao do campo DESCRICAO DA ENTIDADE
Local nPEntida	:= 0					//Posicao do campo ENTIDADE
Local nPDEntida	:= 0					//Posicao do campo DESCRICAO ENTIDADE
Local lRet		:= .T.					//Trata retorno da funcao para validacao do ListBox
Local aPDCols	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณSe for entrada automaticaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If lA061Auto
	nPNContat 	:= Ascan(aHeader,{|x| x[2] == "U6_CONTATO" })
	If nPNContat > 0
		cContato	:= aCols[n][nPNContat]
	Endif	
Endif
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณA funcao e recurssiva se o parametro estiver preenchido mantem o valorณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cContato:= IIF(ValType(cContato) == "C" ,cContato,"")

DbSelectArea("AC8")
DbSetOrder(1)
If ! DbSeek(xFilial("AC8") + cContato)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNao existe relacionamentos para o CONTATO entao retorna branco.                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Return (.F.)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega todos as ENTIDADES relacionadas do CONTATO escolhidoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("AC8")
DbSetOrder(1)
If DbSeek(xFilial("AC8") + cContato , .T.)
	If nOpcao == 1
		aCont := {}
	Endif
		
	While !Eof() .AND. (xFilial("AC8") == AC8->AC8_FILIAL) .AND. (cContato == AC8->AC8_CODCON)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณValida o conteudo da listbox de acordo com o que foi solicitado pelo usuarioณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		lRet := Tk061VldLst()

		If lRet
			cEnt    := ALLTRIM(AC8->AC8_ENTIDA)         						//Alias : SA1
			cDescEnt:= Posicione("SX2",1,cEnt,"X2NOME()")			  			//Nome  : Cadastro de Clientes
			cCodEnt := ALLTRIM(AC8->AC8_CODENT)									//Codigo: 00000101
			cDescCod:= TkEntidade(cEnt,cCodEnt,1)								//Descr : Empresa X Ltda.
			cDescInd:= ALLTRIM(Posicione("SIX",1,cEnt + "1","SIXDescricao()"))  //Indice: Codigo + Loja
			
			Aadd(aCont,{	cEnt,;			// 1 - Alias : SA1
						 	cDescInd,;		// 2 - Indice: Codigo + Loja
							cCodEnt,;		// 3 - Codigo: 00000101
							cDescEnt,;		// 4 - Nome  : Cadastro de Clientes
						 	cDescCod})		// 5 - Descr : Empresa X Ltda.
		Endif
		DbSelectArea("AC8")
		DbSkip()
	End
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existe relacionamento para esse CONTATO mostra as Entidadesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aCont) > 0 .AND. !lA061Auto

	DEFINE MSDIALOG oDlg FROM  300,20 TO 550,650 TITLE STR0026  PIXEL //"Relacionamento Contatos X Entidades"
		
		@01,03 TO 110,315 LABEL "" OF oDlg  PIXEL
		@05,05 LISTBOX oLbx FIELDS HEADER ;
				STR0027,; //"Entidade"
				STR0034,; //"Codigo"
				STR0028; //"Descri็ใo"
				SIZE 307,103 NOSCROLL OF oDlg PIXEL; 
			 	ON DBLCLICK(nOpcao :=1 , nPos := oLbx:nAt ,oDlg:End()) 
		oLbx:SetArray(aCont)
		oLbx:bLine:={||{aCont[oLbx:nAt,4],;
						aCont[oLbx:nAt,3],;
						aCont[oLbx:nAt,5] }}
							
		oLbx:nAt := 1
		If FATPDActive() .And. FTPDUse(.T.)
			aPDCols := {"","","A1_NOME"} 
			oLbx:aObfuscatedCols := FATPDColObfuscate(aPDCols)      
		Endif

		DEFINE SBUTTON FROM 110,225 TYPE 1 	ENABLE OF oDlg ACTION (nOpcao:=1,lRet:= .T., nPos:=oLbx:nAt, oDlg:End())  	//OK
		DEFINE SBUTTON FROM 110,255 TYPE 2 	ENABLE OF oDlg ACTION (nOpcao:=0,lRet:= .F., oDlg:End())       //CANCELA

		FATPDLogUser('TK061ENTCO')	// Log de Acesso LGPD	
	ACTIVATE MSDIALOG oDlg CENTER
	
	
	If (nOpcao == 1)
		cEntidade	:= aCont[nPos,1]	// 1 - Alias : SA1
		cDescInd    := aCont[nPos,2]	// 2 - Indice: Codigo + Loja
		cChave      := aCont[nPos,3]	// 3 - Codigo: 00000101
		cDescEnt	:= aCont[nPos,4]	// 4 - Nome  : Cadastro de Clientes
		cDescChave  := aCont[nPos,5]	// 5 - Descr : Empresa X Ltda.
		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica posicionamento dos campos (ordem)            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Aadd(aPosicoes,{"U6_NCONTAT"  ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_NCONTAT" })})	//1
		Aadd(aPosicoes,{"U6_FILENT"   ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_FILENT"  })})	//2
		Aadd(aPosicoes,{"U6_CODENT"   ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_CODENT"  })})	//3
		Aadd(aPosicoes,{"U6_DESCENT"  ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_DESCENT" })})	//4
		Aadd(aPosicoes,{"U6_ENTIDA"   ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_ENTIDA"  })})	//5
		Aadd(aPosicoes,{"U6_DENTIDA"  ,Ascan(aHeader,{|aVal| Alltrim(aVal[2])== "U6_DENTIDA" })})	//6
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณArmazena posicionamento dos campos para selecao dos dados (ordem) ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPNContat := aPosicoes[1][2]
		nPFilEnt  := aPosicoes[2][2]
		nPCodEnt  := aPosicoes[3][2]
		nPDescEnt := aPosicoes[4][2]
		nPEntida  := aPosicoes[5][2]
		nPDEntida := aPosicoes[6][2]
		
        If nModulo <> 73 //SIGACRM
			aCols[n][nPNContat] := TK061Contato(cContato,"U5_CONTAT")
		EndIf

		aCols[n][nPCodEnt ] := cChave				//00000101
		aCols[n][nPDescEnt] := cDescChave			//Empresa X Ltda.
		If nPFilEnt > 0
			aCols[n][nPFilEnt ] := xFilial(cEntidade)	//Filial da Entidade
		EndIf
		If nPEntida > 0
			aCols[n][nPEntida ] := cEntidade			//Entidade
		EndIf
		If nPDEntida > 0
			aCols[n][nPDEntida] := cDescEnt				//Descricao da Entidade
		EndIf
		
		lRet := .T.
	EndIf
ElseIf Len(aCont) == 0
	If !lA061Auto
		Help(" ",1,"TK061NAC8")
	EndIf
	Return(.F.)
Endif
	
RestArea(aArea)
	
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTK061EMail   ณ Autor ณ Vendas Clientes    ณ Data ณ07/08/03  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณMonta o e-mail para Cross-Posting                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso	     ณLista de Contatos                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Tk061Email(nOpc	,cMensagem	,cAssunto	,aAttach	,;
					cAttach)

Local lRet    	:= .F.                   		// Retorno da funcao     	
Local oDlgMens            						// Objeto da Dialog
Local oMens                              		// Objeto da Mensagem (corpo do e-mail)
Local oSubj                     				// Objeto do Assunto do e-mail
Local oAttach                               	// Objeto dos arquivos anexados
Local nAttach 	:= 0 							// Controle do ListBox
Local cMens   	:= Space(400)        			// Mensagem   (corpo do e-mail)
Local cSubj   	:= CriaVar("U4_ASSUNTO",.F.)  	// Assunto do E-mail
Local nOpcao  	:= 0                    		// Opcao escolhida da Dialog
Local aArq    	:= {}                     		// Array auxiliar que controla os arquivos anexados
Local nX		:= 0                   			// Controle de loop
Local cAux		:= ""							// Controle de loop

If M->U4_FORMA <> "3" //Cross Posting
	Help( " ", 1, "TK061EMAIL" )
	Return(lRet)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSempre atualiza os dados que foram informados para envio do e-mailณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMens 		:= cMensagem
cSubj 		:= cAssunto
aArq  		:= aAttach
cAttach     := ALLTRIM(M->U4_ATTACH) + Chr(10)
aAttach		:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o array que contem os arquivos anexadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nX:=1 To Len(cAttach)
	If SubStr(cAttach,nX,1) <> Chr(10) .AND. SubStr(cAttach,nX,1) <> ";"
		cAux += SubStr(cAttach,nX,1)
	Else
        If !Empty(cAux)
        	Aadd(aAttach,cAux)
        	cAux := ""
        Endif	
	EndIf
Next nX	
aArq := aAttach
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a tela para a digitar a mensagem que sera enviada   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgMens FROM 05,2 TO 350,530 TITLE STR0029 PIXEL //"Composicao de E-Mail"

	@ 02, 04 TO  25,260 OF oDlgMens PIXEL
	@ 09, 08 SAY STR0030 OF oDlgMens SIZE 40,8 PIXEL //"Assunto"
	@ 09, 32 GET oSubj VAR cSubj OF oDlgMens SIZE 225,8 PIXEL WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR .OR. nOpc == INCLUIAUTO)
	
	@ 27, 04 TO 105,260 LABEL STR0031 OF oDlgMens PIXEL //"Mensagem"
	
	If (nOpc == INCLUIR .OR. nOpc == ALTERAR .OR. nOpc == INCLUIAUTO)
		@ 33, 06 GET oMens VAR cMens   OF oDlgMens MEMO SIZE 250,70 PIXEL WHEN .T.
	Else                                                                          
		@ 33, 06 GET oMens VAR cMens   OF oDlgMens MEMO SIZE 250,70 PIXEL WHEN .T. READONLY
	EndIf	
	
	@ 106,04 TO 155,260 LABEL "" OF oDlgMens PIXEL 
	If Len(aArq) = 0 
		Aadd(aArq,"")
	Endif
	
	@ 109,06 LISTBOX oAttach VAR nAttach FIELDS HEADER STR0032 SIZE 250,45 OF oDlgMens PIXEL NOSCROLL //"Anexos"
	oAttach:SetArray(aArq)
	oAttach:Refresh()
		
	DEFINE SBUTTON FROM 160 ,138 TYPE 3 PIXEL ACTION (Tk061RemAne(@aArq,@oAttach,@cAttach)) ENABLE OF oDlgMens WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR .OR. nOpc == INCLUIAUTO)
	DEFINE SBUTTON FROM 160 ,170 TYPE 4 PIXEL ACTION (Tk061Anexo(@aArq,@oAttach,@cAttach)) ENABLE OF oDlgMens WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR .OR. nOpc == INCLUIAUTO)
	DEFINE SBUTTON FROM 160 ,202 TYPE 1 PIXEL ACTION (nOpcao:=1,IIF(Tk061ValEmail(cSubj,cMens), oDlgMens:End(),"")) ENABLE OF oDlgMens
	DEFINE SBUTTON FROM 160 ,234 TYPE 2 PIXEL ACTION (nOpcao:=2,oDlgMens:End()) ENABLE OF oDlgMens
	

ACTIVATE MSDIALOG oDlgMens CENTERED //ON INIT Tk061AtuAnexo(@oAttach,@cAttach,aArq)

If (nOpcao == 1)
	lRet     		:= .T.
	cMensagem		:= cMens
	cAssunto 		:= cSubj
	aAttach  		:= aArq
	M->U4_ATTACH	:= Alltrim(cAttach)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTk061RetEveบAutor  ณ Vendas Clientes    บ Data ณ  08/08/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConsulta RE.  Utilizada para verificar a amarracao que existeบฑฑ
ฑฑบ          ณ no SUW.       					                           บฑฑ
ฑฑบ          ณExibe somente os eventos amarrados a campanhas.              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณCodigo do Evento selecionado.                                บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Lista de Contatos                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061RetEve()

Local nEvento    := 0		//Evento selecionado no ListBox
Local oDlgEve				//Objeto do dialogo
Local aEventos   := {}		//Array com eventos para exibicao na ListBox
Local lRet       := .F.		//Retorno da funcao


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOs dados de Campanha e Script devem estar preenchidos para o relacionamento.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(M->U4_CODCAMP) .OR. Empty(M->U4_SCRIPT)
	Help(" ",1,"TMK061EVEN")//"A Campanha ou o Script nใo foram selecionados. Para a sele็ใo do Evento ้ necessแrio o preenchimento dos campos."	
	Return (lRet)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega o array de eventos.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SUW")
DbSetOrder(1)
If DbSeek(xFilial("SUW")+ M->U4_CODCAMP+ M->U4_SCRIPT )
	While !(SUW->(EOF())) .AND. (xFilial("SUW") == UW_FILIAL) .AND. (UW_CODCAMP == M->U4_CODCAMP) .AND. (UW_CODSCRI == M->U4_SCRIPT)
    	Aadd(aEventos,{UW_CODEVE,UW_DESCEVE})
	SUW->(DbSkip())
	End
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se foram encontrados eventosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aEventos) == 0
	MsgInfo(STR0054) //"Nenhum evento foi encontrado para a campanha selecionada."
	Return (lRet)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDialog.                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgEve FROM  00,00 TO 230,440 TITLE STR0033 PIXEL  //"Consulta de Eventos"
	
	@ 05,05 LISTBOX oLbx FIELDS ;
		    HEADER ;
		    STR0034,STR0035; //"C๓digo" "Nome"
		    SIZE 180,100  NOSCROLL OF oDlgEve PIXEL ;	
	        ON DBLCLICK(nEvento := oLbx:nAt,oDlgEve:End())
	       	
			oLbx:SetArray(aEventos)
			oLbx:nAt:= Len(aEventos)
			oLbx:bLine:={||{aEventos[oLbx:nAt,1],;  //Cขdigo
							aEventos[oLbx:nAt,2] }} //Evento
			

	DEFINE SBUTTON FROM 05,190 TYPE 1  	ENABLE OF oDlgEve ACTION (nEvento:=oLbx:nAt ,oDlgEve:End())
	DEFINE SBUTTON FROM 20,190 TYPE 2  	ENABLE OF oDlgEve ACTION (oDlgEve:End())
	DEFINE SBUTTON FROM 35,190 TYPE 15 	ENABLE OF oDlgEve ACTION (TK061VISCAD(aEventos[oLbx:nAt,1],2))



ACTIVATE MSDIALOG oDlgEve CENTERED 

If nEvento > 0
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona no registro correto para ser atualizado o campo .ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lRet := .T.
	DbSelectArea("ACD")
	DbSetOrder(1)
	DbSeek(xFilial("ACD") + Alltrim(aEventos[nEvento,1]))
	
Endif
 
Return (lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณTK061SELOPERบAutor  ณ Vendas Clientes    บ Data ณ  21/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a selecao automatica do operador que recebera a tarefa.บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณLista de Contato                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061SelOper()

Local aArea 	:= GetArea()							// Salva a area atual	
Local aOper 	:= {}       							// Array com operadores
Local aSele 	:= {}       							// Operadores selecionados                       
Local aSortOper := {}   								// Ordena operadores por ordem crescente de tarefas.
Local nOper 	:= 1            						// Contador para selecao de Operador
Local nAux		:= 0									// Contador Auxiliar
Local oDlg												// Tela para selecao dos operadores que serao avaliados (pela menor tarefa)
Local oOpers    										// ListBox 		
Local oOk       := LoaDbitmap(GetResources(),"LBOK")	// Legendas
Local oNo       := LoaDbitmap(GetResources(),"LBNO")	
Local cCodOper 	:= CRIAVAR("U7_COD",.F.)                // Codigo do Operador com mais tarefas
Local aPDCols 	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega os operadores para a selecao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SU7")
DbSetOrder(1)
DbSeek(xFilial("SU7"))
While (!Eof()) .AND. xFilial("SU7") == SU7->U7_FILIAL
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณOperadores de Telecobrancao sao descartados nessa rotinaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If VAL(SU7->U7_TIPOATE) == TELECOBRANCA
		SU7->(DbSkip())
		Loop
	Endif	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPara as Listas de Contato sao selecionados os Operadores =  TMK, TLV , TODOS  e TMK x TLVณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    If Val(SU7->U7_VALIDO) == VALIDO .AND. ((TRIM(SU7->U7_TIPOATE) == TRIM(M->U4_TELE)) .OR. (SU7->U7_TIPOATE $ "45"))
   	 	AAdd(aOper,{.F.				,;		//1 - Legenda
   	 				SU7->U7_COD		,;		//2 - Codigo
   	 				SU7->U7_NOME	,;		//3 - Nome
   	 				SU7->U7_TAREFA}) 		//4 - Qtd de Listas
	Endif	
	SU7->(DbSkip())
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao for rotina automatica apresenta a Tela de Selecao dos operadores  ณ 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lA061Auto
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEsta tela permite a selecao dos operadores que participarao da avaliacaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aOper)> 0
	   
		DEFINE MSDIALOG oDlg TITLE STR0036 FROM 00,00 TO 250,500 PIXEL OF oMainWnd //"Operadores - Avaliacao/Gravacao automatica"
		
			@ 02,02 TO 120,210 LABEL "" PIXEL OF oDlg

			@ 05,04 LISTBOX oOpers FIELDS ;
			HEADER ;
				"",;		// 1 - Legenda
				STR0034,;	// 2 - Codigo
				STR0035,;	// 3 - Nome
				STR0037;	//"4 - Tarefas 
			ON DbLCLICK (aOper[oOpers:nAt,1]:= !aOper[oOpers:nAt,1], oOpers:Refresh());  // Marca/Desmarca
			ON CHANGE (nOper:= oOpers:nAt) SIZE 205,115 OF oDlg PIXEL NOSCROLL 
		
			oOpers:SetArray(aOper) 
			oOpers:bLine:={||{	IIF(aOper[oOpers:nAt,1],oOk,oNo),;		// 1 - Legenda
							  	aOper[oOpers:nAt,2],;					// 2 - Codigo
						 	    aOper[oOpers:nAt,3],;					// 3 - Nome
						 	    aOper[oOpers:nAt,4]}}              		// 4 - Tarefas	
		
			If FATPDActive() .And. FTPDUse(.T.)
				aPDCols := {"","","U7_NOME",""}   
				oOpers:aObfuscatedCols := FATPDColObfuscate(aPDCols)    
			Endif
			
			oOpers:Refresh() 
		
			FATPDLogUser('TK061SELOP')	// Log de Acesso LGPD
			DEFINE SBUTTON FROM 05,215 TYPE 1 ENABLE OF oDlg ACTION oDlg:End()  // Botao de OK
		
		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCarrega Array com os operadores selecionadosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nAux := 1 TO Len(aOper)
		If aOper[nAux][1]   		// TRUE = Foi selecionado 
			Aadd(aSele,aOper[nAux]) 
		Endif
	Next nAux
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe nenhum operador for selecionado todos serao consideradosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aSele) == 0
		aSele := aClone(aOper)
	Endif
Else	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRotina automatica. Nao ha interface. Todos os operadores serao selecionados    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aSele := aClone(aOper)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOrdena o array dos Operadores Selecionados pelo total de tarefas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aSele) > 0
	aSortOper := ASORT(aSele,,, { |x, y| x[4] < y[4] }) //Crescente
Else
	Aadd(aSortOper,{"",""})
Endif

RestArea(aArea)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ O primeiro item do array sera o operador que possui a menor quantidade de tarefas.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(aSortOper[1][2])
	cCodOper := aSortOper[1][2]
Endif

Return(cCodOper) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณTk061Filtroณ Autor ณ Vendas Clientes       ณ Data ณ 02/08/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณFiltro generico para selecao dos dados da entidade escolhida ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณLista de Contatos.                                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk061Filtro(nOpc,cFiltro,cEntidade,cPergunte)

Local oWnd		 := GetWndDefault()
Local cDesc 	 := ""
Local lRet 		 := .F.
Local cDescFiltro:= ""
Local oDlgFiltro
Local oDescFiltro

If Empty(cEntidade)
	Help(" ",1,"TK061NOSEL")
	Return(.F.)
Endif

cDescFiltro := IIF(!Empty(cFiltro),MontDescr(cEntidade,cFiltro),"")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica qual a forma de contatos sera feita  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case (M->U4_FORMA == "1")//voz
		cLista:= STR0038 //"Voz"
	Case (M->U4_FORMA == "2")//fax
		cLista:= STR0039//"Fax"
	Case (M->U4_FORMA == "3")//Cross Posting
		cLista:= STR0040 //"Cross Posting"
	Case (M->U4_FORMA == "4")//Mala Direta
		cLista:= STR0002 //"Mala Direta"
EndCase

DbSelectArea("SX5")
DbSetOrder(1)
If DbSeek(xFilial("SX5") + "T5" + cEntidade)
	cDesc := X5Descri()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza a descricao da selecao.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgFiltro FROM  00,00 TO 200,310 TITLE STR0041 PIXEL  //"Filtro"

	@02,02 TO 75,153 LABEL STR0042 OF oDlgFiltro PIXEL    //"Descricao do Filtro"
	@10,05 MSGET oDescFiltro VAR cDescFiltro PICTURE "@!" SIZE 145,60 OF oDlgFiltro PIXEL COLOR CLR_RED WHEN .F.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFiltro para a selecao dos registros da entidadeณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE SBUTTON FROM 80,55  TYPE 17 ENABLE OF oDlgFiltro ACTION (lRet:=.T.,;
																	cFiltro  := BuildExpr(cEntidade,oWnd),;
																	cDescFiltro := MontDescr(cEntidade,cFiltro),;
																	oDescFiltro:Refresh()) WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR .OR. nOpc ==INCLUIAUTO )//Monta o filtro
																	
	DEFINE SBUTTON FROM 80,90  TYPE 1 ENABLE OF oDlgFiltro ACTION oDlgFiltro:End() //Fecha a tela e mantem o filtro
	
	DEFINE SBUTTON FROM 80,125 TYPE 2 ENABLE OF oDlgFiltro ACTION (	lRet:=.F.,;
																	cDescFiltro:="",;
																	oDescFiltro:Refresh(),;
																	oDlgFiltro:End())// Cancela o filtro
																
ACTIVATE MSDIALOG oDlgFiltro CENTERED

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk061VldOperบAutorณ Vendas Clientes    บ Data ณ  03/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o operador informado. Caso o conteudo seja  branco  บฑฑ
ฑฑบ          ณ sera gerada a lista aberta.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk061VldOper(cSayOper,cOperad,oSayOper)
Local lRet  := .F.
Local aArea := GetArea()

If !Empty(cOperad)
	DbSelectArea("SU7")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SU7")+cOperad)
		lRet:= .T.
		cSayOper := SU7->U7_NOME
		oSayOper:Refresh()
	Else
		Help(" ",1,"REGNOIS")
		lRet:= .F.
	Endif

Else
	lRet := .T.
	cSayOper := "Lista Aberta."
	oSayOper:Refresh()
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk061VldLst บAutorณ Vendas Clientes    บ Data ณ  03/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a lista que sera carregada no listbox               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk061VldLst()

Local aArea		:= GetArea()											// Salva a แrea atual
Local cChave	:= ""													// Chave de pesquisa da entidade
Local cEntidade	:= Tk061PegEnt()										// Pega a entidade escolhida pelo usuario
Local lRet		:= .T.													// Trata o retorno da funcao

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se ha bloqueio na entidadeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cChave	:= xFilial(cEntidade) + AC8->AC8_CODENT
lRet 	:= Tk061VldEnt()

If lRet
	lRet 	:= !TmkBlqCont(cEntidade,cChave)
Endif

If lRet
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณValida o tipo de telefone para contato.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Do Case
		Case (M->U4_FORMA == "1")   //Voz
			
			If Val( M->U4_TIPOTEL ) == RESIDENCIAL // Residencial
				cTel:= SU5->U5_FONE
				
			ElseIf Val(M->U4_TIPOTEL) == CELULAR // Celular
				cTel:= SU5->U5_CELULAR
				
			ElseIf Val(M->U4_TIPOTEL) == FAX // Fax
				cTel:= SU5->U5_FAX
				
			ElseIf Val(M->U4_TIPOTEL) == COMERCIAL1 // Comercial 1
				cTel:= SU5->U5_FCOM1
				
			ElseIf Val(M->U4_TIPOTEL) == COMERCIAL2 // Comercial 2
				cTel:= SU5->U5_FCOM2         
			Endif
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o tipo de telefone para a geracao da lista nao existir no contato, passa para o proximo contato ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Empty(cTel)
				lRet	:= .F.
			Endif
	
		Case (M->U4_FORMA == "2")   //Fax
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o contato nao possuir numero de fax passa para o proximo contato.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Empty(SU5->U5_FAX)
				lRet	:= .F.
			Endif
			
		Case (M->U4_FORMA == "3")  //Cross-Posting
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o contato nao possuir e-mail passa para o proximo contato.       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Empty(SU5->U5_EMAIL) .OR. (SU5->U5_AUTORIZ <> "1")
			
	    		If  Empty(SU5->U5_EMAIL) .AND. (SU5->U5_AUTORIZ <> "1")
					lRet	:= .F.
	   					
				Elseif Empty(SU5->U5_EMAIL)
					lRet	:= .F.    						
				ElseIf (SU5->U5_AUTORIZ <> "1")
					lRet	:= .F.
				Endif
			Endif
	
		Case (M->U4_FORMA == "4")  //Mala-Direta
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o contato nao possuir endereco passa para o proximo contato.     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If M->U4_TIPOEND == "1" // Residencial 
				If Empty(SU5->U5_END)
					lRet	:= .F.
				Endif
			ElseIf M->U4_TIPOEND == "2" //Comercial
				DbSelectArea(cEntidade)
				DbSetOrder(1)
				If DbSeek(xFilial(cEntidade) + Substr(AC8->AC8_CODENT,1,TkEntTam(cEntidade)[1])+ Substr(AC8->AC8_CODENT,TkEntTam(cEntidade)[1]+1,TkEntTam(cEntidade)[2]))
					If Empty(TkEntidade(cEntidade,Substr(AC8->AC8_CODENT,1,TkEntTam(cEntidade)[1])+Substr(AC8->AC8_CODENT,TkEntTam(cEntidade)[1]+1,TkEntTam(cEntidade)[2]),2))
						lRet	:= .F.
					Endif
				Endif	
			Endif	
	Endcase     
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk061VldEnt บAutorณ Vendas Clientes    บ Data ณ  04/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os registros da entidade selecionada                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk061VldEnt()

Local aArea		:= GetArea()
Local cEntidade	:= Tk061PegEnt()	// Pega a entidade escolhida pelo usuario
Local lRet		:= .T.				// Trata o retorno da funcao

If cEntidade <> AC8->AC8_ENTIDA
	lRet := .F.
EndIf

RestArea(aArea)

Return(lRet)

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDColObfuscate
    @description
    Verifica se a coluna de um grid deve ser ofuscado, tendo como base uma lista de
    campos, esta fun็ใo deve utilizada somente ap๓s a inicializa็ใo das variaveis 
    atravez da fun็ใo FATPDLoad.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.

    @return lObfuscate, L๓gico, Retorna se o campo serแ ofuscado.
    @example FATPDIsObfuscate({"A1_COD","A1_NOME","A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDColObfuscate(aFields, cSource)  
    
	Local aPDColObf	:= {}

    If FATPDActive()
		aPDColObf := FTPDColObfuscate(aFields, cSource)  
    EndIf 

Return aPDColObf  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informa็๕es enviadas, 
    quando a regra de auditoria de rotinas com campos sensํveis ou pessoais estiver habilitada
	Remover essa fun็ใo quando nใo houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que serแ utilizada no log das tabelas
    @param nOpc, Numerico, Op็ใo atribuํda a fun็ใo em execu็ใo - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria nใo esteja aplicada, tamb้m retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun็ใo que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
