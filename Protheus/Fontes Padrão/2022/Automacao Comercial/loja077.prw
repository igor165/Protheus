#INCLUDE "LOJA077.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LOJA077  บ Autor ณ  Vendas Clientes   บ Data ณ  29/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Interface do Cadastro de Pacotes x Acoes.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA077()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	Local cString := "MBC"

	Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX) // controle do robo

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEfetua a gravacao da tabela dos pacotes MBB caso nao existam.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("MBB")
	DbSetOrder(1)

	If !DbSeek(xFilial("MBB")+"0000001")
		RecLock("MBB",.T.)
		MBB->MBB_FILIAL := xFilial("MBB")
		MBB->MBB_CODIGO := "0000001"
		MBB->MBB_DESC   := STR0001 //"Pacote de PRODUTOS"
		MBB->(msunlock())
	EndIf

	If !DbSeek(xFilial("MBB")+"0000002")
		RecLock("MBB",.T.)
		MBB->MBB_FILIAL := xFilial("MBB")
		MBB->MBB_CODIGO := "0000002"
		MBB->MBB_DESC   := STR0002 //"Pacote de MANUT.PRECOS"
		MBB->(msunlock())
	EndIf

	If !DbSeek(xFilial("MBB")+"0000003")
		RecLock("MBB",.T.)
		MBB->MBB_FILIAL := xFilial("MBB")
		MBB->MBB_CODIGO := "0000003"
		MBB->MBB_DESC   := STR0003 //"Pacote de REGRA DE DESCONTOS"
		MBB->(msunlock())
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEfetua a gravacao da tabela das acoes MBD caso nao existam.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("MBD")
	DbSetOrder(1)

	If !DbSeek(xFilial("MBD")+"0000001")
		RecLock("MBD",.T.)
		MBD->MBD_FILIAL := xFilial("MBD")
		MBD->MBD_CODIGO := "0000001"
		MBD->MBD_DESC   := STR0004 //"Codigo de acao de atualizacao de dados"
		MBD->(msunlock())
	EndIf

	If !DbSeek(xFilial("MBD")+"0000002")
		RecLock("MBD",.T.)
		MBD->MBD_FILIAL := xFilial("MBD")
		MBD->MBD_CODIGO := "0000002"
		MBD->MBD_DESC   := STR0005 //"Codigo de acao de impressao de etiquetas"
		MBD->(msunlock())
	EndIf

	If !DbSeek(xFilial("MBD")+"0000003")
		RecLock("MBD",.T.)
		MBD->MBD_FILIAL := xFilial("MBD")
		MBD->MBD_CODIGO := "0000003"
		MBD->MBD_DESC   := STR0006 //"Codigo de acao de gera็ao de cargas"
		MBD->(msunlock())
	EndIf

	If !DbSeek(xFilial("MBD")+"0000004")
		RecLock("MBD",.T.)
		MBD->MBD_FILIAL := xFilial("MBD")
		MBD->MBD_CODIGO := "0000004"
		MBD->MBD_DESC   := STR0007 //"Codigo de acao de gera็ao dos arquivos GERTEC"
		MBD->(msunlock())
	EndIf


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta interface com as opcoes de Visualizacao, Inclusao, Alteracao e Exclusao.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	DbSelectArea("MBC")
	DbSetOrder(1)

	If !lAutomato
		AxCadastro(cString,STR0008,cVldAlt,cVldExc) //"Cadastro Pacote x A็๕es"
	EndIf
Return
