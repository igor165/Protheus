#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRXPE01 บAutor  ณ Ricardo Tomasi     บ Data ณ  02/08/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo chamada ap๓s a inclusใo do Documento de Saida.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFun็๕es   ณ Gera FunRural quando a TES nใo esta para gerar financeiro. บฑฑ
ฑฑบ          ณ Gera FETHAB - Imposto localizado para o estado "MT".       บฑฑ
ฑฑบ          ณ Atualiza saldo dos Compromissos Futuros.                   บฑฑ
ฑฑบ          ณ Atualiza saldo dos Romaneios de Saida.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRXPE01()
Local aAreaAnt := GetArea()
Local aAreaSF2 := SF2->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local lFethab  := IIf(GetMV('MV_ESTADO')$'MT',.T.,.F.)
Local nValFun  := 0
Local nTotFun  := 0
Local nValFet  := IIf(lFethab,GetMV('MV_FETHAB'),0)
Local nTotFet  := 0
//Local aFina050 := Array(0)
//Local cHist    := 'FETHAB NF. ' + SF2->F2_DOC
//Private lMsErroAuto := .f.

Do Case
	Case SM0->M0_PRODRUR == 'F'
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),1,3))
	Case SM0->M0_PRODRUR == 'L'
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),5,3))
	Case SM0->M0_PRODRUR == 'J'
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),9,3))
	OtherWise
		nValFun := Val(Substr(GetMV('MV_CONTSOC'),1,3))
EndCase

dbSelectArea('SD2')
dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	While .Not. Eof() .And. xFilial('SF2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == xFilial('SD2')+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA

		dbSelectArea('SF4')
		dbSetOrder(1)
		dbSeek(xFilial('SF4')+SD2->D2_TES)

		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+SD2->D2_COD)

		dbSelectArea('SC5')
		dbSetOrder(1)
		dbSeek(xFilial('SC5')+SD2->D2_PEDIDO)

		dbSelectArea('SC6')
		dbSetOrder(1)
		dbSeek(xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso tenha sido informado o codigo do Romaneio de Saida no Pedido de Venda.        ณ
		//ณAtualiza a tabela SD2 (Itens da NF) com as informa็๕es da tabela SC6 (Itens do PV).ณ
		//ณAtualiza a tabela NPR (Romaneio de Saida) abatendo do saldo a quantidade           ณ
		//ณinformada no Item da NF (SD2)                                                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If .Not. Empty(SC6->C6_CODROM)
			RecLock('SD2',.f.)
			SD2->D2_CODROM := SC6->C6_CODROM
			MsUnLock()
			dbSelectArea('NPR')
			dbSetOrder(1)
			dbSeek(xFilial('NPR')+SC6->C6_CODROM)
			RecLock('NPR',.f.)
			NPR->NPR_SALDO -= AGRX001(SD2->D2_UM,NPR->NPR_UM,SD2->D2_QUANT)
			MsUnLock()
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso tenha sido informado o codigo do Compromisso Futuro no Pedido de Venda.       ณ
		//ณAtualiza a tabela SD2 (Itens da NF) com as informa็๕es da tabela SC6 (Itens do PV).ณ
		//ณAtualiza a tabela NO1 (Compromissos Fut.) abatendo do saldo a quantidade           ณ
		//ณinformada no Item da NF (SD2)                                                      ณ
		//ณCaso o saldo do Compromisso Futuro fique menor que 1 o faturamento do compromisso  ณ
		//ณfuturo sera fechado (NO1_FCHFAT = "S").                                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If .Not. Empty(SC6->C6_NUMCP)
			RecLock('SD2',.f.)
			SD2->D2_NUMCP := SC6->C6_NUMCP
			MsUnLock()
			dbSelectArea('NO1')
			dbSetOrder(1)
			dbSeek(xFilial('NO1')+SC6->C6_NUMCP)
			RecLock('NO1',.f.)
			NO1->NO1_SALDO -= AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
			If NO1->NO1_SALDO < 1
				NO1->NO1_FCHFAT := 'S'
			EndIf
			MsUnLock()
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso o Cliente nใo seja Tipo Exporta็ใoณ
		//ณe sobre o produto incidir Cont.Seg.Soc.ณ
		//ณsera calculado o valor da contribui็ใo.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SB1->B1_CONTSOC == 'S' .And. SC5->C5_TIPOCLI <> 'X'
			nTotFun += (SD2->D2_TOTAL * nValFun) / 100
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCaso o haja necessidade de calculo do FETHAB pela locali-  ณ
		//ณza็ใo do usuario do sistema. Sera validado a incidencia no ณ
		//ณcadastro do produto (B1_FETHAB) e a incidencia sobre a     ณ
		//ณopera็ใo [TES].                                            ณ
		//ณAs duas sendo verdadeiras sera calculado o valor do impostoณ
		//ณbaseado no parametro (MV_FETHAB).                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lFethab
				If SB1->B1_FETHAB == 'S' .And. If(TAMSX3("F4_FETHAB")[3]=="C",SF4->F4_FETHAB="S",SF4->F4_CALCFET="1")
				nTotFet += (AGRX001(SD2->D2_UM,'TL',SD2->D2_QUANT) * nValFet)
			EndIf
		EndIf

		dbSelectArea('SD2')
		dbSkip()
	EndDo
EndIf

If nTotFun > 0
	If RecLock('SF2',.f.)
		SF2->F2_CONTSOC := nTotFun
		MsUnLock()
	EndIf
EndIf

If nTotFet > 0
	If RecLock('SF2',.f.)
		SF2->F2_FETHAB := nTotFet
		MsUnLock()
	EndIf
/*	aAdd(aFina050,  {"E2_PREFIXO" , SF2->F2_SERIE  , Nil})
	aAdd(aFina050,  {"E2_NUM"     , SF2->F2_DOC    , Nil})
	aAdd(aFina050,  {"E2_TIPO"    , 'TX'            , Nil})
	aAdd(aFina050,  {"E2_NATUREZ" , SC5->C5_NATUREZ , Nil})
	aAdd(aFina050,  {"E2_FORNECE" , Substr(GetMV("MV_AGRXFFT"),1,6), Nil})
	aAdd(aFina050,  {"E2_LOJA"    , Substr(GetMV("MV_AGRXFFT"),7,8), Nil})
	aAdd(aFina050,  {"E2_SAFRA"   , SC5->C5_SAFRA   , Nil})
	aAdd(aFina050,  {"E2_EMISSAO" , SF2->F2_EMISSAO , Nil})
	aAdd(aFina050,  {"E2_VENCTO"  , SF2->F2_EMISSAO , Nil})
	aAdd(aFina050,  {"E2_VALOR"   , nTotFet         , Nil})
	aAdd(aFina050,  {"E2_HIST"    , cHist           , Nil})
	aAdd(aFina050,  {"E2_OBSCOMP" , cHistCom        , Nil})
	aAdd(aFina050,  {"E2_MOEDA"   , 1               , Nil})
	aAdd(aFina050,  {"E2_VLCRUZ"  , nTotFet         , Nil})
	aAdd(aFina050,  {"E2_ORIGEM"  , 'U_M460FIM'     , Nil})
	MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,3)
	If lMsErroAuto
		DisarmTransaction()
		Mostraerro()
	EndIf */
EndIf

RestArea(aAreaSC6)
RestArea(aAreaSF4)
RestArea(aAreaSB1)
RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aAreaAnt)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRXPE02 บAutor  ณ Ricardo Tomasi     บ Data ณ  07/12/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada antes da exclusใo da NFS.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFun็๕es   ณ Valida se existem titulos de impostos baixados.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRXPE02()
Local aAreaAnt := GetArea()
Local aAreaSE2 := SE2->(GetArea())
Local aAreaSD2 := SD2->(GetArea())
Local lRetorno := .t.

dbSelectArea('SD2')
dbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
If dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	While .Not. Eof() .And. xFilial('SF2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == xFilial('SD2')+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
		dbSelectArea('NO1')
		dbSetOrder(1)
		dbSeek(xFilial('NO1')+SD2->D2_NUMCP)
		If .Not. Empty(SD2->D2_NUMCP).And.NO1->NO1_FECHAD=='S'
			ApMsgAlert("Esta NFS nใo podera ser excluida, pois o Compromisso Futuro referente a ela jแ esta fechado.","Compromisso Futuro")
			lRetorno := .f.
			Exit
		EndIf
		dbSelectArea('SD2')
		dbSkip()
	EndDo
EndIf

/*
dbSelectArea('SE2')
dbSetOrder(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
If dbSeek(xFilial('SE2')+Substr(GetMV("MV_AGRXFFT"),1,8)+SF2->F2_SERIE+SF2->F2_DOC+' '+'TX ')
	If SE2->E2_SALDO <> SE2->E2_VALOR
		ApMsgAlert("Esta NFS nใo podera ser excluida, pois o titulo referente ao FETHAB jแ esta baixado.","Movimenta็ใo Financeira")
		lRetorno := .f.
	EndIf
EndIf
*/

RestArea(aAreaSD2)
RestArea(aAreaSE2)
RestArea(aAreaAnt)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRXPE03 บAutor  ณ Ricardo Tomasi     บ Data ณ  07/12/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada antes da exclusใo da NFS.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFun็๕es   ณ Excluir titulo de FETHAB gerado para esta NFS.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRXPE03()
// DESABILITADO DEVIDO TRATAMENTO DO FETHAB NO SISTEMA PADRAO.
//Local aAreaAnt := GetArea()
//Local aFina050 := Array(0)
//Private lMsErroAuto := .f.
/*
dbSelectArea('SE2')
dbSetOrder(6)//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
If dbSeek(xFilial('SE2')+Substr(GetMV("MV_AGRXFFT"),1,8)+SF2->F2_SERIE+SF2->F2_DOC+' '+'TX ')

	aAdd(aFina050,  {"E2_PREFIXO" , SE2->E2_PREFIXO, Nil})
	aAdd(aFina050,  {"E2_NUM"     , SE2->E2_NUM    , Nil})
	aAdd(aFina050,  {"E2_PARCELA" , SE2->E2_PARCELA, Nil})
	aAdd(aFina050,  {"E2_TIPO"    , SE2->E2_TIPO   , Nil})
	aAdd(aFina050,  {"E2_FORNECE" , SE2->E2_FORNECE, Nil})
	aAdd(aFina050,  {"E2_LOJA"    , SE2->E2_LOJA   , Nil})

	MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,5)

	If lMsErroAuto
		DisarmTransaction()
		Mostraerro()
		Return()
	EndIf
EndIf
*/
//RestArea(aAreaAnt)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRXPE04 บAutor  ณ Ricardo Tomasi     บ Data ณ  07/12/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada na confirma็ใo do pedido de venda.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFun็๕es   ณ Validar saldo do Compromisso Futuro.                       บฑฑ
ฑฑบ          ณ Validar saldo do Romaneio de Saida.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRXPE04()
Local aAreaAnt  := GetArea()
Local lRetorno  := .t.
Local nX        := 0
Local nP_UM     := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_UM'})
Local nP_QTDVEN := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN'})
Local nP_CODROM := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_CODROM'})
Local nP_NUMCP  := aScan(aHeader, { |x| Alltrim(x[2]) == 'C6_NUMCP' })

For nX := 1 To Len(aCols)

	If .Not. Empty(aCols[nX,nP_CODROM])
		dbSelectArea('NPR')
		dbSetOrder(1)
		dbSeek(xFilial('NPR')+aCols[nX,nP_CODROM])
		If NPR->NPR_SALDO <> AGRX001(aCols[nX,nP_UM],NPR->NPR_UM,aCols[nX,nP_QTDVEN])
			ApMsgAlert("Saldo do Romaneio para atender este pedido."+Chr(13)+Chr(10)+;
					   "Saldo do Romaneio: "+Transform(AGRX001(NPR->NPR_UM,aCols[nX,nP_UM],NPR->NPR_SALDO),;
					   '@E 999,999,999.99')+aCols[nX,nP_UM], "Saldo do Romaneio")
		EndIf
		If NPR->NPR_SALDO < AGRX001(aCols[nX,nP_UM],NPR->NPR_UM,aCols[nX,nP_QTDVEN])
			lRetorno := .f.
			Exit
		EndIf
	EndIf

	If .Not. Empty(aCols[nX,nP_NUMCP])
		dbSelectArea('NO1')
		dbSetOrder(1)
		dbSeek(xFilial('NO1')+aCols[nX,nP_NUMCP])
		If (NO1->NO1_SALDO + 1) < AGRX001(aCols[nX,nP_UM],NO1->NO1_UM1PRO,aCols[nX,nP_QTDVEN])
			ApMsgAlert("Nใo ha saldo no Compromisso Futuro para atender este pedido."+Chr(13)+Chr(10)+;
					   "Saldo do Compromisso: "+Transform(AGRX001(NO1->NO1_UM1PRO,aCols[nX,nP_UM],NO1->NO1_SALDO),;
					   '@E 999,999,999.99')+aCols[nX,nP_UM], "Saldo do Comp. Fut.")
			lRetorno := .f.
			Exit
		EndIf
	EndIf

Next nX

RestArea(aAreaAnt)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRXPE05 บAutor  ณ Ricardo Tomasi     บ Data ณ  07/12/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada na exclusao de itens da NFS.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFun็๕es   ณ                                                            บฑฑ
ฑฑบ          ณ Alterar saldo do Compromisso Futuro.                       บฑฑ
ฑฑบ          ณ Alterar saldo do Romaneio de Saida.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRXPE05()
Local aAreaAnt  := GetArea()

If .Not. Empty(SD2->D2_CODROM)
	dbSelectArea('NPR')
	dbSetOrder(1)
	If dbSeek(xFilial('NPR')+SD2->D2_CODROM)
		RecLock('NPR')
		NPR->NPR_SALDO += AGRX001(SD2->D2_UM,NPR->NPR_UM,SD2->D2_QUANT)
		MsUnLock()
	EndIf
EndIf

If .Not. Empty(SD2->D2_NUMCP)
	dbSelectArea('NO1')
	dbSetOrder(1)
	If dbSeek(xFilial('NO1')+SD2->D2_NUMCP)
		RecLock('NO1',.f.)
		If NO1->NO1_SALDO < 1
			NO1->NO1_FCHFAT := 'N'
		EndIf
		NO1->NO1_SALDO += AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
		MsUnLock()
	EndIf
EndIf

RestArea(aAreaAnt)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRXPE08 บAutor  ณ Ricardo Tomasi     บ Data ณ  02/08/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo chamada ap๓s a baixa do titulo a pagar.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AGRXPE08()
Local aArea := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEste ponto de entrada chama a fun็ใo que altera o status do titulo no contrato fin.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AGRA105G()

RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRXPE09 บAutor  ณ Ricardo Tomasi     บ Data ณ  02/08/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo chamada ap๓s a cacelamento da baixa do titulo do    บฑฑ
ฑฑบ          ณ contas a pagar.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AGRXPE09()
Local aArea := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEste ponto de entrada chama a fun็ใo que altera o status do titulo no contrato fin.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AGRA105H()

RestArea(aArea)
Return()