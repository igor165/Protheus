#INCLUDE "Hhaudit.ch"
#include "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HandAudit³ Autor ³ Marcelo Vieira        ³ Data ³ 27/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gerar um auditor dos validacoes do protheus                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HHAudit()
Local cFile   := "AUDITSFA.##R"
Local cRootPath:= Trim(GetSrvProfString("RootPath",""))
Local cPathPalm:= GetMv("MV_RELT" ,,"\RELATO\") 
Local nHandle  := 0 
Local aIni := {}
Local aCfgData:={}
Local aValidTable := {"SA1", "SC5", "SC6", "SU5"}
Local aParametros := SFAllPar()
Local aPE:={}
Local ni := 1
Local nTab := 4
Local uValue := ""
Local cValue := ""
Local cStr := ""
Local cIniFile  := GetADV97()

aadd(aPE,{"U_AFVM020A", STR0031}) //"Ponto de Entrada antes do inicio da importação de pedidos"
aadd(aPE,{"U_HHMAIL01", STR0032}) //"Ponto de Entrada antes do envio de e-mail, poedm ser incluidos destinatários e/ou anexos"
aadd(aPE,{"U_MTA410", STR0033}) //"Ponto de Entrada da Rotina MATA410 (Pedido de Venda)"
aadd(aPE,{"U_MTA410I", STR0033})     //"Ponto de Entrada da Rotina MATA410 (Pedido de Venda)"
aadd(aPE,{"U_MTA410T", STR0033})     //"Ponto de Entrada da Rotina MATA410 (Pedido de Venda)"
aadd(aPE,{"U_M030INC", STR0034})     //"Ponto de Entrada da Rotina MATA030 (Clientes)"
aadd(aPE,{"U_M030ALT", STR0034})     //"Ponto de Entrada da Rotina MATA030 (Clientes)"

MSGINFO( OEMTOANSI(STR0035 +; //"Este auditor tem o objetivo de auxiliar na implantacao do "
                   STR0036 +; //"SFA, listando os campos  do  dicionario  das  tabelas que "
                   STR0037 ) ) //"fazem parte da solucao SFA."
                   
If File(cRootPath+cPathPalm+cFile)
	Ferase(cRootPath+cPathPalm+cFile)
endif

nHandle:=FCreate(cPathPalm+cFile)

/////////////////// Busca Configuracoes No apxSrv.ini
FWrite(nHandle, DtoC(MsDate()) + " - " + Time()   + Chr(13) + Chr(10)) 
FWrite(nHandle, STR0038  +  Chr(13) + Chr(10)) //"SFA - Auditor de Handheld"
FWrite(nHandle, Replicate("=",080) + Chr(13) + Chr(10) + Chr(13) + Chr(10))

FWrite(nHandle, STR0039  +  Chr(13) + Chr(10)) //"Configurações APxSRV.INI"
FWrite(nHandle, Replicate("-",080) + Chr(13) + Chr(10) + Chr(13) + Chr(10))
//GetPvProfString(<sessao>,<chave>,<valor padrao>,<nome do arquivo ini>) 
aAdd(aIni, Space(nTab) + "TCPSERVER -> Enable = " + GetPvProfString("TCPSERVER","Enable",STR0040,cIniFile)) //"Não Configurado !"
aAdd(aIni, Space(nTab) + "TCPSERVER -> Port = " + GetPvProfString("TCPSERVER","Port",STR0040,cIniFile)) //"Não Configurado !"

cResponseJob := GetPvProfString("TCPSERVER","ResponseJob","JobTCPServer",cIniFile)
aAdd(aIni, Space(nTab) + "TCPSERVER -> ResponseJob = " + cResponseJob)
aAdd(aIni, "")
If !Empty(cResponseJob)
	aAdd(aIni, Space(nTab) + cResponseJob + "-> Type  = " + GetPvProfString(cResponseJob,"Type",STR0040,cIniFile)) //"Não Configurado !"
	aAdd(aIni, Space(nTab) + cResponseJob + "-> Environment  = " + GetPvProfString(cResponseJob,"Environment",STR0040,cIniFile)) //"Não Configurado !"
	aAdd(aIni, Space(nTab) + cResponseJob + "-> OnStart  = " + GetPvProfString(cResponseJob,"OnStart",STR0040,cIniFile)) //"Não Configurado !"
	aAdd(aIni, Space(nTab) + cResponseJob + "-> OnConnect  = " + GetPvProfString(cResponseJob,"OnConnect",STR0040,cIniFile)) //"Não Configurado !"
	aAdd(aIni, Space(nTab) + cResponseJob + "-> Instances  = " + GetPvProfString(cResponseJob,"Instances",STR0040,cIniFile)) //"Não Configurado !"
Else
	aAdd(aIni, Space(nTab) + STR0041 + cResponseJob + STR0042) //"Sessao "###"não encontrada no INI."
EndIf

For ni := 1 To Len(aIni)
	FWrite(nHandle, aIni[ni] +  Chr(13) + Chr(10) )
Next

MsgRun(STR0043,,{ || HHAuditValid(nHandle, aValidTable)}) //"Auditando validações, gatilhos."
MsgRun(STR0044,,{ || HHAuditParam(nHandle, aParametros)}) //"Auditando parâmetros."
MsgRun(STR0045,,{ || HHAuditPE(nHandle, aPE)}) //"Auditando Pontos de Entrada."

FClose(nHandle)
If File(cRootPath+cPathPalm+cfile )
	ShowMemo(cRootPath+cPathPalm+cFile)
EndIf

Return Nil

Function HHAuditValid(nHandle, aTables)
Local ni := 1
//////////////////////// Verifica Validações
FWrite(nHandle, Chr(13) + Chr(10) + STR0046  +  Chr(13) + Chr(10)) //"Validações de Tabelas"
FWrite(nHandle, Replicate("=",080) + Chr(13) + Chr(10) + Chr(13) + Chr(10))	
For ni := 1 To Len(aTables)
	HHCheckValid(nHandle, aTables[ni])
Next

Return Nil

Function HHAuditParam(nHandle, aParam)
Local nTab := 4
Local ni   := 1
//////////////////////// Verifica Parametros
FWrite(nHandle, STR0047  +  Chr(13) + Chr(10)) //"Verificação de Parametros"
FWrite(nHandle, Replicate("=",080) + Chr(13) + Chr(10) + Chr(13) + Chr(10))	
For ni := 1 To Len(aParam)
	uValue := GetMV(aParam[ni,1],,aParam[ni,3])
	If ValType(uValue) = "N"
		cValue := Str(uValue, 10, 2)
	ElseIf ValType(uValue) = "D"
		cValue := DtoC(uValue)
	ElseIf ValType(uValue) = "L"
		cValue := If(uValue, ".T.", ".F.")
	Else
		cValue := uValue
	EndIf
	FWrite(nHandle, Space(nTab) + aParam[ni,1] + " = " + cValue + " - " + aParam[ni, 2]  + Chr(13) + Chr(10))
Next
FWrite(nHandle, Chr(13) + Chr(10))

Return Nil

Function HHAuditPE(nHandle, aPE)
Local ni := 1

// Verificação de Pontos de Entrada
FWrite(nHandle, STR0048  +  Chr(13) + Chr(10)) //"Validações de Pontos de Entrada"
FWrite(nHandle, Replicate("=",080) + Chr(13) + Chr(10) + Chr(13) + Chr(10))
FWrite(nHandle, STR0049 + Chr(13) + Chr(10)) //"Todos os P.E. devem ser revisados para identificar a existência de comandos/funções de tela"
FWrite(nHandle, "(Ex.: Alert(),MsgStop() e Etc...)." + Chr(13) + Chr(10))
FWrite(nHandle, STR0050 + Chr(13) + Chr(10))        //" Estes comandos/funcoes NAO podem ser utilizados no JOB e/ou rotinas automaticas."
FWrite(nHandle, STR0051 + Chr(13) + Chr(10)) //"Exemplo de Funcao Revisada:"
FWrite(nHandle, "" + Chr(13) + Chr(10))
FWrite(nHandle, 'If Type("L410Auto")!="U" .And. L410Auto' + Chr(13) + Chr(10))
FWrite(nHandle, "    //nao tem funcao de tela" + Chr(13) + Chr(10))
FWrite(nHandle, "Else" + Chr(13) + Chr(10))
FWrite(nHandle, '     MsgAlert("Exemplo")' + Chr(13) + Chr(10))
FWrite(nHandle, "Endif" + Chr(13) + Chr(10) + Chr(13) + Chr(10))

For ni:=1 to Len(aPE)
  If FindFunction( aPE[ni,1] )
		cStr := "Encontrado no RPO, verificar !!!"
	Else
		cStr := "Não encontrado no RPO."
	EndIf
	FWrite(nHandle, aPE[ni,1] +  " - " + aPE[ni,2] + " - " + cStr + Chr(13) + Chr(10))
	FWrite(nHandle, "" + Chr(13) + Chr(10))              
Next

Return Nil

Function HHCheckValid(nHandle, cAlias)
Local nTab := 4

dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cAlias)
	FWrite(nHandle, "Tabela " + SX2->X2_CHAVE + " - " + SX2->X2_NOME + Chr(13) + Chr(10))
	FWrite(nHandle, Replicate("-",080) + Chr(13) + Chr(10) + Chr(13) + Chr(10))
	dbSelectArea( "SX3" )
	dbSetOrder(1)
	If dbSeek(cAlias)
		While !SX3->(Eof()) .And. cAlias = AllTrim(SX3->X3_ARQUIVO)
			FWrite(nHandle, Space(nTab) + "X3_CAMPO   = "  + SX3->X3_CAMPO + Chr(13) + Chr(10))
			FWrite(nHandle, Space(nTab) + "X3_PROPI   = "  + If(SX3->X3_PROPRI="U","Campo de Usuário","Padrao Microsiga") + Chr(13) + Chr(10))
			FWrite(nHandle, Space(nTab) + "X3_VALID   = "  + Alltrim(SX3->X3_VALID)    + Chr(13) + Chr(10))
			FWrite(nHandle, Space(nTab) + "X3_RELACAO = "  + Alltrim(SX3->X3_RELACAO)  + Chr(13) + Chr(10))
			FWrite(nHandle, Space(nTab) + "X3_VLDUSER = "  + Alltrim(SX3->X3_VLDUSER)  + Chr(13) + Chr(10))
	  	If SX3->X3_TRIGGER = "S"
				If SX7->( dbSeek( SX3->X3_CAMPO ) )
			 		FWrite(nHandle, Space(nTab * 2) + "<<<<< GATILHO >>>>>" + Chr(13) + Chr(10) )
			    FWrite(nHandle, Space(nTab * 2) + "X7_CAMPO = " + SX7->X7_CAMPO  + Chr(13) + Chr(10) )
			    FWrite(nHandle, Space(nTab * 2) + "X7_REGRA = " + SX7->X7_REGRA  + Chr(13) + Chr(10) )
			    FWrite(nHandle, Space(nTab * 2) + "X7_CDOMN = " + SX7->X7_CDOMIN + Chr(13) + Chr(10) + Chr(13) + Chr(10))
			 	EndIf
			Else
				FWrite(nHandle, Chr(13) + Chr(10))
	    EndIf
			SX3->( dbSkip() )
		EndDo
	EndIf
Else
	FWrite(nHandle, "Tabela " + cAlias + " - Não Encontrado no arquivo SX2" + Chr(13) + Chr(10))	
EndIf

Return Nil