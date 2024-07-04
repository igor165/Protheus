#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FINA920.CH"

#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

#DEFINE CODINCLUSAO		"_1"
#DEFINE CODREMOCAO		"_2"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA920   บAutor  ณMarcello Gabriel    บFecha ณ 06/11/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ1)Leitura do arquivo magnetico com a lista de "buenos contriบฑฑ
ฑฑบ          ณ  buyentes" atualizando os cadastros de clientes de fornece-บฑฑ
ฑฑบ          ณ  dores, determinando quais se encontram nessa categoria e  บฑฑ
ฑฑบ          ณ  geracao de um historico de atualizacoes.                  บฑฑ
ฑฑบ          ณ2)Consulta ao historico de atualizacoes dos clientes e forneบฑฑ
ฑฑบ          ณ  dores.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Peru                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FINA920()
Local aArea		:= {}
Local aScrRes	:= {}
//Paineis
Local oPnlTopo
Local oPnlEsq
Local oPnlDir
Local oPnlBase
//Separadores
Local oSep1
Local oSep2
Local oSep3

//Botoes
Private oBtnAtual
Private oBtnHist
Private oBtnCons
Private oBtnSair
Private oBtnVoltar
Private oBtnCanc
//arquivo magnetico
Private cArq		:= Space(300)
Private dDtAtu		:= dDataBase
Private oArq
Private oDtAtu
//Uso geral
Private cFilSA1		:= xFilial("SA1")
Private cFilSA2		:= xFilial("SA2")
Private oFonte
Private oFonte14
Private oPnlPrin
Private oPnlHist
Private oDlgBC
//Uso na consulta de historico
Private oCodRUC
Private cCodRUC		:= Space(TamSX3("A1_CGC")[1])
Private oRazSoc
Private cRazSoc		:= Space(TamSX3("A1_NOME")[1])
Private lBomContr	:= .F.
Private oDtIniHis
Private oDtFimHis
Private dDtIniHis	:= Ctod("//")
Private dDtFimHis	:= Ctod("//")
Private oBrwHist
Private oPnlCCont
Private oPnlEst
//Uso no processo do arquivo magnetico
Private cBuffer		:= ""		//area para armazenar os dados lidos do arquivo magnetico
Private nHdl		:= 0		//ponteiro para o arquivo magnetico
Private nTamBuf		:= 65536	//tamanho da area de leitura
Private cSepara		:= "|"		//caracter usaro para separar os campos no arquivo magnetico
Private lProcessar	:= .F.		//usada para controlar o processo do arquivo magnetico
//Registro o arquivo magnetico
Private nArqNrRUC	:= 1					//posicao do campo com o RUC
Private nArqRazao	:= 2					//posicao do campo com razao social
Private nArqDtIncl	:= 3					//posicao do campo com a data de inclusao
Private nArqResol	:= 4					//posicao do campo com a resolucao
Private aTipoCpos	:= {"C","C","D","C"}	//usado para converter o valor lido para o tipo correto

aArea := GetArea()
oFonte := TFont():New("Arial",,,,.T.,,,8,.F.,,,,,,,)
oFonte14 := TFont():New("Arial",14,20,,.T.,,,,.F.,,,,,,,)
aScrRes := MsAdvSize(.F.,.F.,400)
oDlgBC := TDialog():New(aScrRes[7],0,aScrRes[6]-50,aScrRes[5]-250,STR0001,,,,,,,,,.T.,,,,,) //"Bons contribuintes"
	//paineis
	oPnlEsq := TPanel():New(01,01,,oDlgBC,,,,,,5,5,.F.,.F.)
		oPnlEsq:Align := CONTROL_ALIGN_LEFT
		oPnlEsq:nWidth := 10
	oPnlDir := TPanel():New(01,01,,oDlgBC,,,,,,5,5,.F.,.F.)
		oPnlDir:Align := CONTROL_ALIGN_RIGHT
		oPnlDir:nWidth := 10
	oPnlBase := TPanel():New(01,01,,oDlgBC,,,,,,5,30,.F.,.F.)
		oPnlBase:Align := CONTROL_ALIGN_BOTTOM
		oPnlBase:nHeight := 10
	oPnlTopo := TPanel():New(01,01,,oDlgBC,,,,,,5,30,.F.,.F.)
		oPnlTopo:Align := CONTROL_ALIGN_TOP
		oPnlTopo:nHeight := 10
	oPnlBotoes := TPanel():New(01,01,,oDlgBC,,,,,,5,30,.F.,.F.)
		oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM
		oPnlBotoes:nHeight := 20
		//botoes
		oBtnSair := TButton():New(0,0,STR0002,oPnlBotoes,{|| oDlgBC:End()},30,10,,,,.T.,,STR0003,,,,) //"Encerrar"###"Encerra a execu็ใo do programa."
			oBtnSair:Align := CONTROL_ALIGN_RIGHT
		oBtnCanc := TButton():New(0,0,STR0004,oPnlBotoes,{|| lProcessar := !MsgYesNo(STR0005,STR0001)},30,10,,,,.T.,,STR0006,,,,) //"Cancelar"###"Deseja concelar o processamento"###"Cancela o processamento."###"Bons contribuintes"
			oBtnCanc:Align := CONTROL_ALIGN_RIGHT
		oBtnVoltar := TButton():New(0,0,STR0007,oPnlBotoes,{|| F920Ativa("P")},30,10,,,,.T.,,"",,,,) //"Voltar"
			oBtnVoltar:Align := CONTROL_ALIGN_RIGHT
		oSep1 := TPanel():New(01,01,,oPnlBotoes,,,,,,3,30,.F.,.F.)
			oSep1:Align := CONTROL_ALIGN_RIGHT
		oBtnHist := TButton():New(0,0,STR0008,oPnlBotoes,{|| F920Hist()},30,10,,,,.T.,,STR0009,,,,) //"Hist๓rico"###"Lista as altera็๕es sofridas por um contribuinte."
			oBtnHist:Align := CONTROL_ALIGN_RIGHT
		oBtnCons := TButton():New(0,0,STR0010,oPnlBotoes,{|| F920Cons()},30,10,,,,.T.,,STR0011,,,,) //"Consultar"###"Exibe as altera็๕es do contribuinte."
			oBtnCons:Align := CONTROL_ALIGN_RIGHT
		oSep2 := TPanel():New(01,01,,oPnlBotoes,,,,,,3,30,.F.,.F.)
			oSep2:Align := CONTROL_ALIGN_RIGHT
		oBtnAtual := TButton():New(0,0,STR0012,oPnlBotoes,{|| If(F920valArq(),F920Atual(),.F.)},30,10,,,,.T.,,STR0013,,,,) //"Atualizar"###"Atualiza os cadastros pelo arquivo magn้tico."
			oBtnAtual:Align := CONTROL_ALIGN_RIGHT
	oPnlPrin := TPanel():New(01,01,,oDlgBC,,,,,,5,5,.F.,.F.)
		oPnlPrin:Align := CONTROL_ALIGN_ALLCLIENT
		//arquivo
		oPnlArq := TPanel():New(01,01,,oPnlPrin,,,,,,5,5,.F.,.F.)
			oPnlArq:Align := CONTROL_ALIGN_TOP
			oPnlArq:nHeight := 35
			oPnlBtnArq:= TPanel():New(01,01,,oPnlArq,,,,,,5,5,.F.,.F.)
				oPnlBtnArq:Align := CONTROL_ALIGN_RIGHT
				oPnlBtnArq:nWidth := 30
				oBtnArq := TBtnBmp2():New(003,091,25,28,"folder6","folder6" ,,,{|| F920SelArq(oArq),},oPnlBtnArq,STR0014,,.T.) //"Sele็ใo do arquivo" //"Sele็ใo do arquivo"
					oBtnArq:Align := CONTROL_ALIGN_RIGHT
			@00,00 MSGET oArq VAR cArq SIZE 5,5 PIXEL OF oPnlArq
				oArq:Align := CONTROL_ALIGN_ALLCLIENT
			oPnlTit := TPanel():New(01,01,STR0015,oPnlArq,,,,,,5,30,.F.,.F.) //"Arquivo de bons contribuintes"
				oPnlTit:Align := CONTROL_ALIGN_TOP
				oPnlTit:nHeight := 15
				oPnlTit:nWidth := 200
		//separador
		oSep3 := TPanel():New(01,01,,oPnlPrin,,,,,,5,5,.F.,.F.)
			oSep3:Align := CONTROL_ALIGN_TOP
			oSep3:nHeight := 15
		//Data da atualizacao
		oPnlDtAtu := TPanel():New(01,01,,oPnlPrin,,,,,,5,5,.F.,.F.)
			oPnlDtAtu:Align := CONTROL_ALIGN_TOP
			oPnlDtAtu:nHeight := 35
			@00,00 MSGET oDtAtu VAR dDtAtu SIZE 5,100 PIXEL OF oPnlDtAtu
				oDtAtu:Align := CONTROL_ALIGN_LEFT
			oPnlTitDt := TPanel():New(01,01,STR0016,oPnlDtAtu,,,,,,5,30,.F.,.F.) //"Data da atualiza็ใo do arquivo de bons contribuintes"
				oPnlTitDt:Align := CONTROL_ALIGN_TOP
				oPnlTitDt:nHeight := 15
				oPnlTitDt:nWidth := 200
	oDlgBC:lCentered := .T.
	oDlgBC:bInit := {|| F920Ativa("P"),oArq:SetFocus()}
oDlgBC:Activate(,,,,{|| !lProcessar})
RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920ATIVA บAutor  ณMarcello Gabriel    บFecha ณ 09/11/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtiva e desativa os botoes de acordo com a opcao em uso.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA920                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F920Ativa(cTela)
Default cTela := "P"
                  
oPnlPrin:lActive	:= (cTela == "P")
oPnlPrin:lVisible	:= (cTela <> "H")
If cTela <> "H"
	If oPnlHist <> Nil
		oPnlHist:Free()
		oPnlHist := Nil
		oArq:SetFocus()
	Endif
Endif
oBtnAtual:lVisible	:= (cTela == "P")
oBtnHist:lVisible	:= (cTela == "P")
oBtnSair:lVisible	:= (cTela == "P")
oBtnVoltar:lVisible	:= (cTela == "H")
oBtnCons:lVisible	:= (cTela == "H")
oBtnCanc:lVisible	:= (cTela == "A")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920SELARQบAutor  ณMarcello Gabriel    บFecha ณ 26/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ativa o seletor de arquivos                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F920SelArq()
Local cArquivo := ""

cArquivo := cGetFile(STR0040 + " (*.txt) |*.TXT|" + STR0041 + " (*.*) |*.*|",STR0017,0,"C:\",.T.,CGETFILE_TYPE) //"Texto"###"Todos"###"Seleciona arquivo"
If !Empty(cArquivo)
	oArq:cText := PadR(cArquivo,300)
	oArq:Refresh()
Endif
oArq:SetFocus()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920VALARQบAutor  ณMarcello Gabriel    บFecha ณ 26/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida o arquivo informado para processamento              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F920ValArq()
Local lRet		:= .T.
Local cArquivo	:= ""

cArquivo := AllTrim(oArq:cText)
If Empty(cArquivo)
	lRet := .F.
	MsgAlert(STR0018 + ".",STR0001) //"Informe o arquivo de cotribuintes"###"Bons contribuintes"
	oArq:SetFocus()
Else
	If !File(cArquivo)
		lRet := .F.
		MsgAlert(STR0019 + "  " + cArquivo + " " + STR0020 + ".",STR0001) //"Arquivo"###"nใo encontrado"###"Bons contribuintes"
		oArq:SetFocus()
	Endif
Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920ATUAL บAutor  ณMarcello Gabriel    บFecha ณ 06/11/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLeitura do arquivo magnetico e atualizacao dos cadastros de บฑฑ
ฑฑบ          ณclientes e de fornecedores.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA920                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F920Atual()
Local nX		:= 0
Local nPos		:= 0
Local nLen		:= 0
//Posicoes do array de cotribuintes
Local aContr	:= {}
Local nItContr	:= 10
Local nCliFor	:= 1	//codigo do cliente/fornecedor
Local nLoja		:= 2 	//filial do cliente/fornecedor
Local nRUC		:= 3	//ruc
Local nNome		:= 4	//razao social
Local nDtIncAnt	:= 5	//data de inclusao atual
Local nResolAnt	:= 6	//resolucao atual
Local nDtIncNov	:= 7	//nova data de inclusao 
Local nResolNov	:= 8	//nova resolucao
Local nRegSA1	:= 9	//registro na tabela SA1
Local nRegSA2	:= 10	//registro na tabela SA2
//
Local cQuery	:= ""
Local cAliasSA	:= ""
Local cRUCEmp	:= ""		//RUC da filial que esta executando a atualizacao
Local cResolEmp	:= ""		//codigo da resolucao que colocou a filial como bom contribuinte
Local dDtAtual	:= dDataBase
Local cHrAtual	:= ""
Local cFilAIF	:= xFilial("AIF")
Local aLista	:= {}		// lista de contribuintes
Local oSepP1
Local oSepP2
Local oPnlSep
Local oPnlFor
Local oPnlCli
Local oPnlGrv
Local oPnlBC
Local oPnlProc
Local oSayProc
Local oSayFor
Local oSayCli
Local oSayGrv

lProcessar := .F.
If MsgYesNo(STR0021,STR0001) //"Cofirma o processamento do arquivo de bons contribuintes"###"Bons contribuintes"
	nHdl := FOpen(AllTrim(oArq:cText),FO_READ)
	If nHdl > 0
		lProcessar := .T.
		cRUCEmp := AllTrim(SM0->M0_CGC)
		cResolEmp := ""
		F920Ativa("A")
		oPnlSep := TPanel():New(01,01,"",oPnlPrin,,,,,,5,30,.F.,.F.)
			oPnlSep:Align := CONTROL_ALIGN_TOP
			oPnlSep:nHeight := 30
		oPnlBC := TPanel():New(01,01,,oPnlPrin,,,,,,5,5,.F.,.F.)
			oPnlBC:Align := CONTROL_ALIGN_ALLCLIENT
		/*
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณVerificando os clientes existentes    ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
		oPnlCli := TPanel():New(01,01,STR0024 + ".    " + STR0023,oPnlBC,oFonte,,,,,5,5,.F.,.F.)		//"Rela็ใo dos clientes cadastrados"###"Aguarde."
			oPnlCli:Align := CONTROL_ALIGN_TOP
			oPnlCli:nHeight := 30
			oSayCli := TSay():New(0,0,{|| ""},oPnlCli,,oFonte,,,,.T.,,,10,10)
				oSayCli:Align := CONTROL_ALIGN_BOTTOM
				oSayCli:nHeight := 15
		cQuery := "select A1_COD,A1_LOJA,A1_CGC,A1_NOME,A1_BCRESOL,A1_BCDTINC,R_E_C_N_O_ from " + RetSQLName("SA1")
		cQuery += " where A1_FILIAL = '" + xFilial("SA1") + "'"
		cQuery += " and D_E_L_E_T_=''"
		cAliasSA := GetNextAlias()
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA,.T.,.T.)
		TcSetField(cAliasSA,"A1_BCDTINC","D",8,0)
		(cAliasSA)->(DbGoTop())
		While lProcessar .And. !((cAliasSA)->(Eof()))
			oSayCli:cCaption := (cAliasSA)->A1_NOME
			Aadd(aContr,Array(nItContr))
			nLen := Len(aContr)
			aContr[nLen,nCliFor]	:= (cAliasSA)->A1_COD
			aContr[nLen,nLoja]		:= (cAliasSA)->A1_LOJA
			aContr[nLen,nRUC]		:= (cAliasSA)->A1_CGC
			aContr[nLen,nNome]		:= (cAliasSA)->A1_NOME
			aContr[nLen,nDtIncAnt]	:= (cAliasSA)->A1_BCDTINC
			aContr[nLen,nResolAnt]	:= AllTrim((cAliasSA)->A1_BCRESOL)
			aContr[nLen,nDtIncNov]	:= Ctod("//")
			aContr[nLen,nResolNov]	:= ""
			aContr[nLen,nRegSA1]	:= (cAliasSA)->R_E_C_N_O_
			aContr[nLen,nRegSA2]	:= 0
			(cAliasSA)->(DbSkip())
			ProcessMessages()
		Enddo
		DbSelectArea(cAliasSA)
		(cAliasSA)->(DbCloseArea())
		oSayCli:cCaption := ""
		oPnlCli:cCaption := STR0024 + "." + "    OK" //"Rela็ใo dos clientes cadastrados"
		oSepP2 := TPanel():New(01,01,"",oPnlBC,,,,,,5,30,.F.,.F.)
			oSepP2:Align := CONTROL_ALIGN_TOP
			oSepP2:nHeight := 20
		ProcessMessages()
		If lProcessar
			/*
			ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			ณVerificando os fornecedores existentes ณ
			ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
			oPnlFor := TPanel():New(01,01,STR0022 + ".    " + STR0023,oPnlBC,oFonte,,,,,10,30,.F.,.F.) //"Rela็ใo dos fornecedores cadastrados"###"Aguarde."
				oPnlFor:Align := CONTROL_ALIGN_TOP
				oPnlFor:nHeight := 30
				oSayFor := TSay():New(0,0,{|| ""},oPnlFor,,oFonte,,,,.T.,,,10,10)
					oSayFor:Align := CONTROL_ALIGN_BOTTOM
					oSayFor:nHeight := 15
			cQuery := "select A2_COD,A2_LOJA,A2_CGC,A2_NOME,A2_BCRESOL,A2_BCDTINC,R_E_C_N_O_ from " + RetSQLName("SA2")
			cQuery += " where A2_FILIAL = '" + xFilial("SA2") + "'"
			cQuery += " and D_E_L_E_T_=''"
			cAliasSA := GetNextAlias()
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA,.T.,.T.)
			TcSetField(cAliasSA,"A2_BCDTINC","D",8,0)
			(cAliasSA)->(DbGoTop())
			While lProcessar .And. !((cAliasSA)->(Eof()))
				oSayFor:cCaption := (cAliasSA)->A2_NOME
				Aadd(aContr,Array(nItContr))
				nLen := Len(aContr)
				aContr[nLen,nCliFor]	:= (cAliasSA)->A2_COD
				aContr[nLen,nLoja]		:= (cAliasSA)->A2_LOJA
				aContr[nLen,nRUC]		:= (cAliasSA)->A2_CGC
				aContr[nLen,nNome]		:= (cAliasSA)->A2_NOME
				aContr[nLen,nDtIncAnt]	:= (cAliasSA)->A2_BCDTINC
				aContr[nLen,nResolAnt]	:= AllTrim((cAliasSA)->A2_BCRESOL)
				aContr[nLen,nDtIncNov]	:= Ctod("//")
				aContr[nLen,nResolNov]	:= ""
				aContr[nLen,nRegSA1]	:= 0
				aContr[nLen,nRegSA2]	:= (cAliasSA)->R_E_C_N_O_
				(cAliasSA)->(DbSkip())
				ProcessMessages()
			Enddo
			DbSelectArea(cAliasSA)
			(cAliasSA)->(DbCloseArea())
			oSayFor:cCaption := ""
			oPnlFor:cCaption := STR0022 + "." + "    OK"		//"Rela็ใo dos fornecedores cadastrados"
			oSepP1 := TPanel():New(01,01,"",oPnlBC,,,,,,5,30,.F.,.F.)
				oSepP1:Align := CONTROL_ALIGN_TOP
				oSepP1:nHeight := 20
			ProcessMessages()
		Endif
		If lProcessar
			aContr := Aclone(Asort(aContr,,,{|x,y| x[nRUC] < y[nRUC]}))
			/*
			ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			ณProcessamento do arquivo magnetico    ณ
			ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
			oPnlProc := TPanel():New(01,01,STR0025 + ".    " + STR0023,oPnlBC,oFonte,,,,,10,30,.F.,.F.) //"Processamento do arquivo de contribuintes"###"Aguarde."
				oPnlProc:Align := CONTROL_ALIGN_TOP
				oPnlProc:nHeight := 30
				oSayProc := TSay():New(0,0,{|| ""},oPnlProc,,oFonte,,,,.T.,,,10,10)
					oSayProc:Align := CONTROL_ALIGN_BOTTOM
					oSayProc:nHeight := 15
			nX := 0
			MsgRun(STR0026,STR0001,{|| aLista := F920LeArq()}) //"Lendo o arquivo de contribuintes."###"Bons contribuintes"
			While lProcessar .And. !Empty(aLista)
				nX := 0
				nLen := Len(aLista)
				While lProcessar .And. nX < nLen
					nX++
					oSayProc:cCaption := aLista[nX,nArqRazao]
					ProcessMessages()
					/*
					ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					ณVerifica se o contribuinte lido do arquivo magnetico pertenceณ
					ณao cadastro. Caso esteja, registra as novas data e resolucao ณ
					ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
					nPos := Ascan(aContr,{|contrib| AllTrim(contrib[nRUC]) == AllTrim(aLista[nX,nArqNrRUC])})
					If nPos > 0
						While (nPos <= Len(aContr)) .And. (AllTrim(aContr[nPos,nRUC]) == AllTrim(aLista[nX,nArqNrRUC]))
							aContr[nPos,nDtIncNov] := aLista[nX,nArqDtIncl]
							aContr[nPos,nResolNov] := AllTrim(aLista[nX,nArqResol])
							nPos++
						Enddo
					Endif
					/*
					ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					ณVerifica se a filial que executa a atualizacao estao no arquivo.ณ
					ณCaso esteja, guarda o codigo da resolucao para atualizar o      ณ
					ณparametro ao final do processamento.                            ณ
					ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
					If AllTrim(aLista[nX,nArqNrRUC]) == cRUCEmp
					    If aLista[nX,nArqDtIncl] <> Nil .And. aLista[nX,nArqResol] <> Nil
							cResolEmp := Alltrim(Dtoc(aLista[nX,nArqDtIncl])) + "|" + AllTrim(aLista[nX,nArqResol])
						EndIf
					Endif
				Enddo
				MsgRun(STR0026,STR0001,{|| aLista := F920LeArq()}) //"Lendo o arquivo de contribuintes."###"Bons contribuintes"
			Enddo
			FClose(nHdl)
			oSayProc:cCaption := ""
			oPnlProc:cCaption := STR0025 + "." + "    OK"	//"Processamento do arquivo de contribuintes"
			If lProcessar
				/*
				ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				ณAtualizacao dos cadastros             ณ
				ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
				oSepP3 := TPanel():New(01,01,"",oPnlBC,,,,,,5,30,.F.,.F.)
					oSepP3:Align := CONTROL_ALIGN_TOP
					oSepP3:nHeight := 20
				oPnlGrv := TPanel():New(01,01,STR0027 + ".    " + STR0023,oPnlBC,oFonte,,,,,10,30,.F.,.F.) //"Atualiza็ใo dos cadastros de clientes e fornecedores"###"Aguarde."
					oPnlGrv:Align := CONTROL_ALIGN_TOP
					oPnlGrv:nHeight := 30
					oSayGrv := TSay():New(0,0,{|| ""},oPnlGrv,,oFonte,,,,.T.,,,10,10)
						oSayGrv:Align := CONTROL_ALIGN_BOTTOM
						oSayGrv:nHeight := 15
				nX := 0
				nLen := Len(aContr)
				cHrAtual := Time()
				dDtAtual := dDataBase
				Begin Transaction
					While lProcessar .And. nX < nLen
						nX++
						oSayGrv:cCaption := aContr[nX,nNome]
						ProcessMessages()
						/*
						ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						ณVerifica quais contribuintes sofreram alteracoes e atualiza    ณ
						ณseus dados no cadastro.                                        ณ
						ณ                                                               ณ
						ณO REGISTRO DO HISTORICO E FEITO POR CAMPO, PARA ESTE CASO, USARณ
						ณOS CAMPOS ??_BCRESOL, PARA INDICAR QUE ALTERACAO FOI FEITA PARAณ
						ณ"BOM CONTRIBUINTE.                                             ณ
						ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
						If !Empty(aContr[nX,nResolAnt]) .Or. !Empty(aContr[nX,nResolNov])
							If !(aContr[nX,nResolAnt] == aContr[nX,nResolNov]) .And. !(aContr[nX,nDtIncAnt] == aContr[nX,nDtIncNov])
								If aContr[nX,nRegSA1] <> 0		//o contribuinte e um cliente
									SA1->(DbGoto(aContr[nX,nRegSA1]))
									RecLock("SA1",.F.)
									Replace SA1->A1_BCRESOL	With aContr[nX,nResolNov]
									Replace SA1->A1_BCDTINC	With aContr[nX,nDtIncNov]
									Replace SA1->A1_CONTRBE With "1"
									SA1->(MsUnLock())
									//registra a alteracao para consultas posteriores
									If Empty(aContr[nX,nResolNov])
										//Quando e uma remocao, registra com o codigo e data da ultima inclusao, que estao no cadastro do contribuinte.
										//Assim, na consulta, pode-se relacionar os registros da inclusao e da remocao.
										MSGrvHist(cFilAIF,cFilSA1,"SA1",aContr[nX,nCliFor],aContr[nX,nLoja],"A1_BCRESOL",AllTrim(aContr[nX,nRUC]) + "|" + Dtoc(aContr[nX,nDtIncAnt]) + "|" + AllTrim(aContr[nX,nResolAnt]) + "|" + CODREMOCAO + "|" + Dtoc(dDtAtu) + "|",dDtAtual,cHrAtual,"","")
									Else
										MSGrvHist(cFilAIF,cFilSA1,"SA1",aContr[nX,nCliFor],aContr[nX,nLoja],"A1_BCRESOL",AllTrim(aContr[nX,nRUC]) + "|" + Dtoc(aContr[nX,nDtIncNov]) + "|" + AllTrim(aContr[nX,nResolNov]) + "|" + CODINCLUSAO + "|" + Dtoc(dDtAtu) + "|",dDtAtual,cHrAtual,"","")
									Endif
								Else	//caso contrario, e um fornecedor
									SA2->(DbGoto(aContr[nX,nRegSA2]))
									RecLock("SA2",.F.)
									Replace SA2->A2_BCRESOL	With aContr[nX,nResolNov]
									Replace SA2->A2_BCDTINC	With aContr[nX,nDtIncNov]
									Replace SA2->A2_CONTRBE With "1"
									SA2->(MsUnLock())
									//registra a alteracao para consultas posteriores
									If Empty(aContr[nX,nResolNov])
										//Quando e uma remocao, registra com o codigo e data da ultima inclusao, que estao no cadastro do contribuinte.
										//Assim, na consulta, pode-se relacionar os registros da inclusao e da remocao.
										MSGrvHist(cFilAIF,cFilSA2,"SA2",aContr[nX,nCliFor],aContr[nX,nLoja],"A2_BCRESOL",AllTrim(aContr[nX,nRUC]) + "|" + Dtoc(aContr[nX,nDtIncAnt]) + "|" + AllTrim(aContr[nX,nResolAnt]) + "|" + CODREMOCAO + "|" + Dtoc(dDtAtu) + "|",dDtAtual,cHrAtual,"","")
									Else
										MSGrvHist(cFilAIF,cFilSA2,"SA2",aContr[nX,nCliFor],aContr[nX,nLoja],"A2_BCRESOL",AllTrim(aContr[nX,nRUC]) + "|" + Dtoc(aContr[nX,nDtIncNov]) + "|" + AllTrim(aContr[nX,nResolNov]) + "|" + CODINCLUSAO + "|" + Dtoc(dDtAtu) + "|",dDtAtual,cHrAtual,"","")
									Endif
								Endif
							Endif
						Endif
					Enddo
					If !lProcessar
						DisarmTrans()
					Else
						/*
						ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						ณAtualiza o parametro para indicar se a empresa e ou nao "bomณ
						ณcontribuinte".                                              ณ
						ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
						PutMV("MV_BCRESOL",cResolEmp)
					Endif
					oSayGrv:cCaption := ""
					oPnlGrv:cCaption := STR0027 + "." + "    OK" //"Atualiza็ใo dos cadastros de clientes e fornecedores"
				End Transaction
			Endif
			If lProcessar
				MsgAlert(STR0028,STR0001) //"Processamento do arquivo de contribuintes finalizado"###"Bons contribuintes"
			Endif
		Endif
		oPnlSep:Free()
		oPnlBc:Free()
		F920Ativa("P")
		oArq:SetFocus()
	Else
		MsgAlert(STR0029) //"Nใo foi possํvel abrir o arquivo de bons contribuintes"
	Endif
	lProcessar := .F.
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920HIST  บAutor  ณMarcello Gabriel    บFecha ณ 06/11/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLista o historico de alteracoes sofridas por um             บฑฑ
ฑฑบ          ณcontribuinte.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA920                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F920Hist()
Local oPnlSNome
Local oPnlSRUC 
Local oPnlTRUC
Local oPnlRUC
Local oPnlTPer
Local oPnlSPer
Local oPnlPer
Local oPnlSGrd
Local oPnlSGrdB

F920Ativa("H")
cRazSoc := Space(TamSX3("A1_NOME")[1])
cCodRUC := Space(TamSX3("A1_CGC")[1])
dDtIniHis := Ctod("//")
dDtFimHis := Ctod("//")
oPnlHist := TPanel():New(01,01,,oDlgBC,,,,,,5,5,.F.,.F.)
	oPnlHist:Align := CONTROL_ALIGN_ALLCLIENT
	//RUC
	oPnlTRUC := TPanel():New(01,01,STR0035,oPnlHist,,,,,,35,35,.F.,.F.)	//"RUC do contribuinte"
		oPnlTRUC:Align := CONTROL_ALIGN_TOP
		oPnlTRUC:nHeight := 35
		oPnlRUC := TPanel():New(01,01,,oPnlTRUC,,,,,,20,20,.F.,.F.)
			oPnlRUC:Align := CONTROL_ALIGN_BOTTOM
			oPnlRUC:nHeight := 20
		@00,00 MSGET oCodRUC VAR cCodRUC SIZE 100,15 PIXEL OF oPnlRUC Valid F920ValRUC()
		oPnlSNome := TPanel():New(01,01,,oPnlRUC,,,,,,35,35,.F.,.F.)	
		@00,00 MSGET oRazSoc VAR cRazSoc SIZE 100,15 PIXEL OF oPnlRUC when .F.
			oCodRUC:Align := CONTROL_ALIGN_LEFT
			oCodRUC:nWidth := 200
			oPnlSNome:Align := CONTROL_ALIGN_LEFT
			oPnlSNome:nWidth := 15
			oRazSoc:Align := CONTROL_ALIGN_ALLCLIENT
			oRazSoc:nWidth := 300
	oPnlSRUC := TPanel():New(01,01,,oPnlHist,,,,,,35,35,.F.,.F.)
		oPnlSRUC:Align := CONTROL_ALIGN_TOP
		oPnlSRUC:nHeight := 15
	//Periodo
	oPnlTPer := TPanel():New(01,01,STR0036,oPnlHist,,,,,,35,35,.F.,.F.)	//"Perํodo de processamento do arquivo magn้tico"
		oPnlTPer:Align := CONTROL_ALIGN_TOP
		oPnlTPer:nHeight := 35
	oPnlSGrd := TPanel():New(01,01,,oPnlHist,,,,,,35,35,.F.,.F.)
		oPnlSGrd:Align := CONTROL_ALIGN_TOP
		oPnlSGrd:nHeight := 25
	oPnlSGrdB := TPanel():New(01,01,,oPnlHist,,,,,,35,35,.F.,.F.)
		oPnlSGrdB:Align := CONTROL_ALIGN_BOTTOM
		oPnlSGrdB:nHeight := 10
	//exibe o nome e o estado do contribuinte na consulta
	oPnlCCont := TPanel():New(01,01,,oPnlHist,,,,,,35,35,.F.,.F.)
		oPnlCCont:Align := CONTROL_ALIGN_TOP
		oPnlCCont:nHeight := 20
		oPnlEst := TPanel():New(01,01,,oPnlCCont,oFonte,,.T.,CLR_RED,,35,35,.F.,.F.)
			oPnlEst:Align := CONTROL_ALIGN_RIGHT
			oPnlEst:nWidth := 200
	//
	oPnlPer := TPanel():New(01,01,,oPnlTPer,,,,,,20,20,.F.,.F.)
		@00,00 MSGET oDtIniHis VAR dDtIniHis SIZE 100,15 PIXEL OF oPnlPer
		oPnlSPer := TPanel():New(01,01,,oPnlPer,,,,,,35,35,.F.,.F.)
		@00,00 MSGET oDtFimHis VAR dDtFimHis SIZE 100,15 PIXEL OF oPnlPer
		oPnlPer:Align := CONTROL_ALIGN_BOTTOM
		oPnlPer:nHeight := 20
		oDtIniHis:Align := CONTROL_ALIGN_LEFT
		oDtIniHis:nWidth := 100
		oPnlSPer:Align := CONTROL_ALIGN_LEFT
		oPnlSPer:nWidth := 15
		oDtFimHis:Align := CONTROL_ALIGN_LEFT
		oDtFimHis:nWidth := 100
oCodRUC:SetFocus()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920ValRUCบAutor  ณMarcello Gabriel    บFecha ณ 14/11/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica o RUC digitado, procurando pelo contribuinte no    บฑฑ
ฑฑบ          ณcadastro de clientes e no de fornecedores.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA920 - F920Hist                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F920ValRUC()
Local aAreaSA	:= {}
Local cResol	:= ""

cRazSoc := Space(TamSX3("A1_NOME")[1])
lBomContr := .F.
//procura no arquivo de clientes
aAreaSA := SA1->(GetArea())
SA1->(DbSetOrder(3))
If SA1->(DbSeek(xFilial("SA1") + cCodRUC))
	cRazSoc := SA1->A1_NOME
	cResol  := SA1->A1_BCRESOL
Endif
SA1->(RestArea(aAreaSA))
If Empty(cRazSoc)	//se nao encontrou no arquivo de clientes procura no arquivo de fornecedores
	aAreaSA := SA2->(GetArea())
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2") + cCodRUC))
		cRazSoc := SA2->A2_NOME
		cResol  := SA2->A2_BCRESOL
	Endif
	SA2->(RestArea(aAreaSA))
Endif
lBomContr := !Empty(cResol)
If Empty(cRazSoc)
	If !Empty(cCodRUC)
		cRazSoc := PadR(STR0020,TamSX3("A1_NOME")[1])		//"Nใo encontrado"
	Endif
Else
	If oBrwHist <> Nil
		oBrwHist:Free()
		oBrwHist := Nil
	Endif
	oPnlCCont:cCaption := ""
	oPnlEst:cCaption := ""
	oPnlCCont:Refresh()
	oPnlEst:Refresh()
Endif
oRazSoc:Refresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920CONS  บAutor  ณMarcello Gabriel    บFecha ณ 13/11/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a consulta e exibe o historico.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA920 - F920Hist                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F920Cons()
Local nX		:= 0
Local nPos		:= 0
Local nLenHist	:= 0
Local lRet		:= .T.
Local cRUC		:= ""
Local cResol	:= ""
Local dDtAux	:= Ctod("//")
Local dDtFim	:= Ctod("//")
Local dDtIni	:= Ctod("//")
Local aHistor	:= {}		//{data inclusao,resolucao,data arquivo magnetico (inclusao),data arquivo magnetico (remocao)}
Local aHistAux	:= {}
Local aAreaSA	:= {}
Local oOk
Local oNok

cRUC := AllTrim(oCodRUC:cText)
If oBrwHist <> Nil
	oBrwHist:Free()
	oBrwHist := Nil
Endif
oPnlCCont:cCaption := ""
oPnlEst:cCaption := ""
oPnlCCont:Refresh()
oPnlEst:Refresh()
If Empty(cRUC)
	MsgAlert(STR0030,STR0001) //"Informe o RUC do contribuinte."###"Bons contribuintes"
	lRet := .F.
Else
	F920ValRUC()
Endif
If lRet
	dDtFim := dDtFimHis
	dDtIni := dDtIniHis
	If Empty(dDtFim)
		dDtFim := dDataBase
	Endif
	If dDtFim < dDtIni
		dDtAux := dDtIni
		dDtIni := dDtFim
		dDtFim := dDtAux
	Endif
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณA ROTINA DE CONSULTA AO HISTORICO RECUPERA AS ALTERACOES ณ
	ณPOR CAMPO, LOGO, TRARA INCLUSIVE AQUELAS QUE NAO SAO     ณ
	ณREFERENTES AO "BOM CONTRIBUINTE". DEVE-SE USAR SOMENTE OSณ
	ณREGISTROS QUE SEJAM DOS CAMPOS A1_BCRESOL E A2_BCRESOL,  |
	ณO QUE IMPLICA QUE A ALTERCAO FOI PARA "BOM CONTRIBUINTE".|
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	//caso o contribuinte seja cliente (tambem), procura pelo historico para cliente
	aAreaSA := SA1->(GetArea())
	SA1->(DbSetOrder(3))
	If SA1->(DbSeek(cFilSA1 + PadR(cRUC,TamSX3("A1_CGC")[1])))
		MsgRun(STR0031,STR0001,{|| aHistAux := MsConHist("SA1",SA1->A1_COD,SA1->A1_LOJA,dDtIni,dDtFim,"","")}) //"Lendo o registro de altera็๕es"###"Bons contribuintes"
	Endif
	SA1->(RestArea(aAreaSA))
	//Caso o contribuintes seja (tambem) fornecedor, procura pelo historico para fornecedor
	aAreaSA := SA2->(GetArea())
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(cFilSA2 + PadR(cRUC,TamSX3("A2_CGC")[1])))
		MsgRun(STR0031,STR0001,{|| aHistor := MsConHist("SA2",SA2->A2_COD,SA2->A2_LOJA,dDtIni,dDtFim,"","")}) //"Lendo o registro de altera็๕es"###"Bons contribuintes"
	Endif
	SA2->(RestArea(aAreaSA))
	//Compara a primeira lista do cliente com a do fornecedor e inclui na primeira os registros nao repetidos.
	For nX := 1 To Len(aHistor)
		If AllTrim(aHistor[nX,1]) $ "A1_BCRESOL|A2_BCRESOL"
			If Ascan(aHistAux,{|historico| historico[2] == aHistor[nX,2]}) == 0
				Aadd(aHistAux,Aclone(aHistor[nX]))
			Endif
		Endif
	Next
	aHistor := {}
	If Empty(aHistAux)
		MsgAlert(STR0032,STR0001) //"Nใo hแ registros para o perํodo e contribuinte informados."###"Bons contribuintes"
		oCodRuc:SetFocus()
	Else
		oPnlCCont:cCaption := Alltrim(cCodRUC) + "  " + AllTrim(cRazSoc)
		oPnlEst:cCaption := If(lBomContr,STR0033,"") //"Bom contribuinte"
		aHistor := {}	
		oNOk  := LoadBitmap(GetResources(),"br_vermelho")
		oOk := LoadBitmap(GetResources(),"br_verde")
		For nX := 1 To Len(aHistAux)
			If AllTrim(aHistAux[nX,1]) $ "A1_BCRESOL|A2_BCRESOL"
				//Desmembrado o registro do historico
				//RUC
				nPos := At("|",aHistAux[nX,2])
				aHistAux[nX,2] := Substr(aHistAux[nX,2],nPos+1)
				//data da inclusao
				nPos := At("|",aHistAux[nX,2])
				dDtAux := Ctod(Substr(aHistAux[nX,2],1,nPos-1))
				aHistAux[nX,2] := Substr(aHistAux[nX,2],nPos+1)
				//resolucao
				nPos := At("|",aHistAux[nX,2])
				cResol := Alltrim(Substr(aHistAux[nX,2],1,nPos-1))
				aHistAux[nX,2] := Substr(aHistAux[nX,2],nPos+1)
				//tipo
				nPos := At("|",aHistAux[nX,2])
				cTipo := Substr(aHistAux[nX,2],1,nPos-1)
				aHistAux[nX,2] := Substr(aHistAux[nX,2],nPos+1)
				//data atualizacao do arquivo magnetico
				nPos := At("|",aHistAux[nX,2])
				dDtIni := Ctod(Substr(aHistAux[nX,2],1,nPos-1))
				aHistAux[nX,2] := Substr(aHistAux[nX,2],nPos+1)
				//
				If cTipo == CODREMOCAO 		//remocao - coloco a data de processamento da remocao
					nLenHist := Ascan(aHistor,{|historico| historico[1] == dDtAux .And. historico[2] == cResol})
					aHistor[nLenHist,4] := dDtIni				//data de processamento remocao
				Else
					Aadd(aHistor,Array(4))
					nLenHist := Len(aHistor)
					aHistor[nLenHist,3] := dDtIni				//data de processamento inclusao
					aHistor[nLenHist,4] := ""					//data de processamento remocao
				Endif
				aHistor[nLenHist,1] := dDtAux					//Data de inclusao
				aHistor[nLenHist,2] := cResol					//resolucao
			Endif
		Next
		oBrwHist := TCBrowse():New(0,0,100,100,,,,oPnlHist,,,,,,,,,,,,.T.,"",.T.,{|| .T.},,,,)
		oBrwHist:AddColumn(TCColumn():New(" ",{|| If(Empty(aHistor[oBrwHist:nAt,4]),oOk,oNOk)},,,,,10,.T.,.F.,,,,,))
		oBrwHist:AddColumn(TCColumn():New(STR0037 + " (" + STR0038 + ")",{|| aHistor[oBrwHist:nAt,3]},,,,"LEFT",90,.F.,.F.,,,,,))		//"Atualiza็ใo do arquivo"###inclusใo
		oBrwHist:AddColumn(TCColumn():New(RetTitle("A1_BCDTINC"),{|| aHistor[oBrwHist:nAt,1]},,,,"LEFT",70,.F.,.F.,,,,,))
		oBrwHist:AddColumn(TCColumn():New(RetTitle("A1_BCRESOL"),{|| aHistor[oBrwHist:nAt,2]},,,,"LEFT",95,.F.,.F.,,,,,))
		oBrwHist:AddColumn(TCColumn():New(STR0037 + " (" + STR0039 + ")",{|| aHistor[oBrwHist:nAt,4]},,,,"LEFT",90,.F.,.F.,,,,,))		//"Atualiza็ใo do arquivo"##remo็ใo
		oBrwHist:Align     := CONTROL_ALIGN_ALLCLIENT
		oBrwHist:lAutoEdit := .F.
		oBrwHist:lReadOnly := .F.
		oBrwHist:SetArray(aHistor)
		cRazSoc := Space(TamSX3("A1_NOME")[1])
		cCodRUC := Space(TamSX3("A1_CGC")[1])
		dDtIniHis := Ctod("//")
		dDtFimHis := Ctod("//")
		oCodRUC:SetFocus()
	Endif
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF920LEARQ บAutor  ณMarcello Gabriel    บFecha ณ 06/11/2009  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLe o arquivo magnetico, separa os registros e separa estes  บฑฑ
ฑฑบ          ณem campos.                                                  บฑฑ
ฑฑบ          ณRetorna uma array com os registros lidos.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA920                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F920LeArq()
Local nLen		:= 0
Local nPos		:= 0
Local nCpos		:= 0
Local nNrCpos	:= 0
Local nLidos	:= 0
Local cAux  	:= ""
Local cAux1		:= ""
Local cAux2		:= ""
Local aRet		:= {}

cAux := Space(nTamBuf)
nLidos := FRead(nHdl,@cAux,nTamBuf)
If FError() == 0
	nNrCpos := Len(aTipoCpos)
	cBuffer += cAux
	If (nLidos < nTamBuf) .And. !Empty(cBuffer)
		cBuffer += Chr(13)
	Endif
	cAux := ""
	nPos := At(Chr(13),cBuffer)
	While nPos > 0
		cAux := Substr(cBuffer,1,nPos-1)
		If Substr(cAux,Len(cAux),1) == Chr(10)
			cAux := Left(cAux,Len(cAux)-1)
		Endif
		If Left(cBuffer,1) == Chr(10)
			cBuffer := Substr(cBuffer,2)
		Else
			cBuffer := Substr(cBuffer,nPos+1)
		Endif
		//desmembra o registro
		Aadd(aRet,Array(nNrCpos))
		nCpos := 0
		nLen := Len(aRet)
		While !Empty(cAux) .And. (nCpos < nNrCpos)
			nPos := At(cSepara,cAux)
			If nPos == 0
				nPos := Len(cAux) + 1
			Endif
			nCpos++
			cAux1 := Substr(cAux,1,nPos-1)
			If aTipoCpos[nCpos] == "D"
				cAux2 := Ctod(cAux1)
			ElseIf aTipoCpos[nCpos] == "N"
				cAux2 := Val(cAux1)
			Else
				cAux2 := cAux1
			Endif
			aRet[nLen,nCpos] := cAux2
			cAux := Substr(cAux,nPos + 1)
		Enddo
		//
		nPos := At(Chr(13),cBuffer)
	Enddo
Else
	MsgStop(STR0034,STR0001)		//"Nใo foi possํvel ler o arquivo magn้tico"###"Bons contribuintes"
Endif
Return(Aclone(aRet))