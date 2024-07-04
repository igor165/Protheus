#include "OFIXA011.CH"
#include "PROTHEUS.CH"
#include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIXA011 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Orcamento de Pecas e Servicos                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXA011(_nNumAge,lNoMBrowse)

Local cFasOrcFil := ""
Local ii := 0
Default _nNumAge := ""

Private cCadastro := STR0001 // Orcamento de Pecas e Servicos
Private aRotina   := MenuDef()
Private	cFilAg := IIF( !Empty(_nNumAge), " .AND. VS1->VS1_NUMAGE = '" + _nNumAge + "' " , "" )
Private cFilAgend := IIF( !Empty(_nNumAge), " AND VS1_NUMAGE = '" + _nNumAge + "' " , "" )
Private nCloOrc   := .f. 
Private nAviso    := 0 
Private lLibPV := .f. // 
Private cMotivo   := "000001"
Private lNoMBrow := lNoMBrowse

// Private oXA018Faseorc := Mil_FasesOrcamento():New() // Variavel utilizada na funcao OA18DORCS (X3_INIBRW) // Alex - Tornar Classe Obsoleta

Private cFilOld := cFilAnt // Variavel declarada para guardar a Filial escolhida independente do registro posicionado no Browse

if Empty(Alltrim(GetNewPar("MV_FMLPECA","")))
	MsgInfo(STR0076)
	return .f.
endif
///
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte para Configuracao da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// AADD(aRegs,{STR0055, STR0055, STR0055, "mv_ch1", "N", 1 , 0, 1, "C", '' , "mv_par01", STR0056, STR0056 , STR0056 , "" , "" , STR0057 , STR0057 , STR0057 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {STR0058,STR0059,STR0060},{},{}})
// AADD(aRegs,{STR0094, STR0094, STR0094, "mv_ch2", "N", 1 , 0, 1, "C", '' , "mv_par02", STR0056, STR0056 , STR0056 , "" , "" , STR0057 , STR0057 , STR0057 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {STR0095},{},{}})

Pergunte("OF011F12",.f.)
nVerParFat := Mv_Par01

If !lNoMBrowse
	SetKey(VK_F12,{||FSO11F12()})
EndIf

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de  Oficina e Auto Peças        //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14,41) .or. !FMX_AMIIn({"OFIXA011","OFIOM350" })
    Return()
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando a rotina for chamada do Agendamento nao pode   ³
//³ FATURAR e CLONAR orcamento, pois os valores totais da ³
//³ VS1, VS3 e VS4 pode não estar corretos                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Empty(_nNumAge)
	aRotina := MenuDefAG()
endif

If lNoMBrowse
	dbSelectArea("VO1")
	If ( nOpc <> 0 ) .And. !Deleted()		
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI")+__cUserId)
	cFilVend := ""
	cFilFase := ""
	if VAI->VAI_TIPTEC == "4"
		cFilVend := " VS1_CODVEN = '"+VAI->VAI_CODVEN+"'  AND "
	endif
	if Alltrim(VAI->VAI_FASORC) != ""  
	    for ii := 1 to Len(Alltrim(VAI->VAI_FASORC))
	        cFasOrcFil += subs(Alltrim(VAI->VAI_FASORC),ii,1)+","
	    Next     
	    cFilFase := " AND VS1_STATUS IN " + FORMATIN(left(cFasOrcFil,len(cFasOrcFil)-1),',') // 'C','0','1'...
	endif                                                           
	//
	dbSelectArea("VS1")
	dbSetOrder(1)
	//
	If ExistBlock("POA011FT") // Ponto de Entrada para Filtro no Browse
		cFiltroX11 := ExecBlock("POA011FT",.f.,.f.,{.f.})
	elseIf ExistBlock("POXA011FBR") // Ponto de Entrada para Filtro no Browse
		cFiltroX11 := ExecBlock("POXA011FBR",.f.,.f.,{.f.})
		cFiltroX11 := cFilVend + " (VS1_TIPORC = '1' OR VS1_TIPORC = '2') " + cFilFase + cFilAgend + " AND " + cFiltroX11 // Filtra as compras
	Else
		cFiltroX11 := cFilVend + " (VS1_TIPORC = '1' OR VS1_TIPORC = '2') " + cFilFase + cFilAgend  // Filtra as compras
	endif
	mBrowse( 6, 1,22,75,"VS1",,,,,,OXA011LEG(),,,,,,,,cFiltroX11)
	//
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA011   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Orcamento de Pecas e Servicos                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011(cAlias,nReg,nOpc)
Local lRet := .f.
Local lVS1NUMLIS := .f.
Local lProbDes := .f.
Private lRejLib  := .f.

// regras de permissao
if nOpc == 6 // FATURAR														// Faturar orcamento:
	
	if VS1->VS1_TIPORC == "1" .AND. VS1->VS1_STATUS $ "F/G" .AND. !Empty(VS1->VS1_NUMNFI) 
		dbSelectArea("SF2")
		dbSetOrder(1)
		if dbSeek(xFilial("SF2")+VS1->VS1_NUMNFI+VS1->VS1_SERNFI)
			If MsgYesNo(STR0073+ VS1->VS1_NUMNFI+"/"+VS1->VS1_SERNFI+". "+STR0074)  
				dbSelectArea("VS1")
				Reclock("VS1",.f.)
				VS1->VS1_STATUS := "X"
				MsUnlock()
				If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
					OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0108 ) // Grava Data/Hora na Mudança de Status do Orçamento / Orçamento por Fases
				EndIf
				return .f.
			Else
				return .f.
			Endif	
		Else 
			MsgInfo(STR0073+ VS1->VS1_NUMNFI+"/"+VS1->VS1_SERNFI+". "+STR0075,STR0037)
			return .f.
		Endif	
	Endif
	
	if VS1->VS1_STATUS == "X" .or. VS1->VS1_STATUS == "C" .or. VS1->VS1_STATUS == "I"		//		Sempre, a menos que esteja cancelado ou ja faturado
		MsgInfo(STR0020,STR0018)
		return .f.
	endif
	
	lVS1NUMLIS := VS1->(FieldPos("VS1_NUMLIS")) > 0
	
	if !Empty(VS1->VS1_NUMLIB)
		dbSelectArea("VS6")
		dbSetOrder(1)
		dbSeek(xFilial("VS6")+VS1->VS1_NUMLIB)
		If Empty(VS6->VS6_DATAUT) // OI001ATU(cNumOrc,cFaseAtu)
			If VS6->(FieldPos("VS6_DATREJ")) > 0
				If !Empty(VS6->VS6_DATREJ)
					MsgInfo(STR0092+VS6->VS6_MOTREJ+" - "+POSICIONE("VS0",1,xFilial("VS0")+"000016"+VS6->VS6_MOTREJ,"VS0_DESMOT") +". "+Chr(13) + Chr(10) +STR0093+ IIF( (GetNewPar("MV_GLIBVEN","N") == "S") .AND. lVS1NUMLIS , Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0031 , "" ) ,STR0018)
					lRejLib  := .t.
					OXI001REVF(VS1->VS1_NUMORC,"0")
					lProbDes := .t.
				Else
					MsgInfo(STR0021 + IIF( (GetNewPar("MV_GLIBVEN","N") == "S") .AND. lVS1NUMLIS , Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0031 , "" ) ,STR0018)
					lProbDes := .t.
				EndIf
			Else
				MsgInfo(STR0021 + IIF( (GetNewPar("MV_GLIBVEN","N") == "S") .AND. lVS1NUMLIS , Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0031 , "" ) ,STR0018)
				lProbDes := .t.
			EndIf
		Endif
	Endif
	If lVS1NUMLIS .and. !Empty(VS1->VS1_NUMLIS)
		dbSelectArea("VS6")
		dbSetOrder(1)
		dbSeek(xFilial("VS6")+VS1->VS1_NUMLIS)
		If Empty(VS6->VS6_DATAUT)
			If VS6->(FieldPos("VS6_DATREJ")) > 0
				If !Empty(VS6->VS6_DATREJ)
					MsgInfo(STR0092+VS6->VS6_MOTREJ+" - "+POSICIONE("VS0",1,xFilial("VS0")+"000016"+VS6->VS6_MOTREJ,"VS0_DESMOT")+". "+Chr(13) + Chr(10) +STR0093+ Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0032 ,STR0018)
					lRejLib  := .t.
					OXI001REVF(VS1->VS1_NUMORC,"0")
					lProbDes := .t.
				Else
					MsgInfo(STR0021 + Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0032 ,STR0018)
					lProbDes := .t.
				EndIf
			Else
				MsgInfo(STR0021 + Chr(13) + Chr(10) + Chr(13) + Chr(10) + STR0032 ,STR0018)
				lProbDes := .t.
			EndIf
		Endif
	EndIf
	If lProbDes
		Return .f.
	EndIf
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI")+__cUserId)
	If VS1->VS1_TIPORC == "2" .and. VAI->(FieldPos("VAI_EXPOOS")) > 0
  	    if VAI->VAI_EXPOOS == "0"
	       MsgInfo(STR0077,STR0018)
	       return .f.
	   endif
	Else
  	    if VAI->VAI_FATBAL == "0"
	       MsgInfo(STR0022,STR0018)
	       return .f.
	   endif
	Endif
endif
if !VS1->VS1_STARES $ "1.2" // Orçamento nao reservado
	if VS1->VS1_DATVAL < ddatabase  .and. nOpc <> 2 .and. nOpc <> 3 .and. nOpc <> 5
		MsgInfo(STR0017,STR0018)
		return .f.
	endif
Endif
if nOpc == 4  							// Alterar orcamento:
	if VS1->VS1_STATUS != "0"		// 	Somente quando estiver apenas digitado
		MsgInfo(STR0019,STR0018)
		return .f.
	endif
endif
if nOpc == 5 // CANCELAR
	if  VS1->VS1_STATUS == "X" 	.or. VS1->VS1_STATUS == "C" .or. VS1->VS1_STATUS == "I"	//		Sempre, a menos que esteja cancelado ou ja faturado
		MsgInfo(STR0023,STR0018)
		return .f.
	endif
	If ( VAI->(ColumnPos("VAI_CANCPR")) > 0 ) // Campo de Permissao do Usuario para Cancelar/Deletar Pecas ja Reservadas?
		If VS1->VS1_STARES $ "12" .or. FM_SQL("SELECT SUM(VS3_QTDRES) FROM " + retsqlname('VS3') + " WHERE VS3_FILIAL='"+xFilial('VS3')+"' AND VS3_NUMORC='"+VS1->VS1_NUMORC+"' AND D_E_L_E_T_=' '") > 0
			//Verificar se o usuario pode cancelar/deletar uma Peca ja Reservada
			VAI->(DbSetOrder(4))
			VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
			If VAI->VAI_CANCPR == '0' // Sem permissão para Cancelar
				MsgStop(STR0104,STR0018) // Usuário sem permissão para Cancelar Orçamento com Peças já Reservadas. Impossivel continuar. / Atencao
				return .f.
			EndIf
		EndIf
	EndIf
endif
//
if nOpc == 6
	DBSelectArea("VS1")
	if !Empty(VS1->VS1_NUMAGE) .and. VS1->VS1_VTOTNF == 0
		MsgInfo(STR0033,STR0034)
		return .f.
	endif
endif
if nOpc == 4 .or. nOpc == 6  .or. nOpc == 5
	DBSelectArea("VS1")
	if !Softlock("VS1")
		return .f.
	endif
endif
//
if ExistBlock("OA011APRO")
	if !ExecBlock("OA011APRO",.f.,.f.,{nOpc})
		MsUnlockAll()
		Return(.f.)
	Endif
Endif
//
lRet = OFIXX001(NIL,NIL,NIL,nOpc)
//
MsUnlockAll()
//
SA1->(MsUnlock()) // Nao remover, pois quando integrado com o Venda Direta o registro permanecia bloqueado
//
If ExistBlock("OA011FIM") // Ponto de Entrada no Final da chamada de Menu do Orçamento fases
	ExecBlock("OA011FIM",.f.,.f.)
EndIf
//
VS1->(dbSetOrder(1))
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA011CLO  ³ Autor ³ Luis Delorme                    ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Clonar Orcamento                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011CLO(cAlias,nReg,nOpc,lPediVenda,lLibPV,cTpMsgVS1)
//
Local nCntFor,nCntFor2
Local cOrcOri := VS1->VS1_NUMORC
Local lAtuClo := .t.
Local nQtItOri:= 0
Local lBo := .F.
Local cCpoSX3 := ""
Local lCodVenAtu := .f.

Default nOpc       := ""
Default lPediVenda := .f. // Quando esta função é chamada para Clonar  no Pedido de Venda (OFIXA018) este parâmetro vem com .T.
Default lLibPV     := .f. // Quando esta função é chamada para Liberar no Pedido de Venda (OFIXA018) este parâmetro vem com .T.
Default cTpMsgVS1  := IIf(!lPediVenda,"O","P") // Tipo: O-Orcamento / P-Pedido - utilizado apenas para saber qual mensagem sera apresentada ao usuario

if lLibPV
	DBSelectArea("VS3")
	DBSetOrder(1)
	DBSeek(xFilial("VS3")+cOrcOri)
	aRecNos := {}
	lNaoClona := .t.
	while !eof() .and. VS3->VS3_FILIAL+VS3->VS3_NUMORC == xFilial("VS3")+cOrcOri
		if VS3->VS3_RESERV <> '1'
			SB1->(DBSetOrder(7))
			SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
			nSaldo := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+VS3->VS3_LOCAL)
			if nSaldo < VS3->VS3_QTDITE
				lNaoClona := .f.
			endif
		endif
		DBSelectArea("VS3")
		DBSkip()
	enddo
	if lNaoClona
		MsgStop(STR0072)
		return .f.
	endif
endif
//
if ExistBlock("OX011CLONE")
	if !ExecBlock("OX011CLONE",.f.,.f.)
		Return .f.
	Endif
Endif

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
//
if !MsgYesNo(IIf(cTpMsgVS1=="O",STR0024,STR0069)+Alltrim(VS1->VS1_NUMORC)+STR0025+ Alltrim(SA1->A1_NOME)+ " ?")
	return .f.
end
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cOrcOri)
//
if FM_SQL(" select SUM(VS3_QTDAGU) FROM " + retsqlname('VS3') + " WHERE VS3_FILIAL = '"+xFilial('VS3')+"' AND VS3_NUMORC = '"+cOrcOri+"' AND D_E_L_E_T_ = ' ' " ) > 0
	lBo := .T.
EndIf
//
aCloneVS1 := {}
//
cOrcClone := GetSXENum("VS1","VS1_NUMORC")
ConfirmSx8()

if nOpc == 8  // Clonar orcamento apartir da OS. 		 
	nAviso := Aviso(STR0037,STR0038,{STR0039,STR0040}) 
Else
	nAviso := 1
Endif

DBSelectArea("VAI")
DBSetOrder(6)
If DBSeek(xFilial("VAI")+VS1->VS1_CODVEN)
	If !Empty(VAI->VAI_DATDEM)
		lCodVenAtu := .t.
	Endif
Endif

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS1")

BEGIN TRANSACTION
//
While !Eof().and.(x3_arquivo=="VS1")
	cCpoSX3 := AllTrim(X3_CAMPO)
	Do Case
		Case cCpoSX3 == "VS1_NUMORC"
			aAdd(aCloneVS1,{X3_CAMPO, cOrcClone })
		Case cCpoSX3 $ "VS1_DATORC/VS1_HORORC/VS1_DATVAL/" .or. (cCpoSX3 == "VS1_CODVEN" .and. lCodVenAtu)
			aAdd(aCloneVS1,{X3_CAMPO, CriaVar(X3_CAMPO) })
		Case cCpoSX3 $ "VS1_NUMOSV/VS1_NUMPED/VS1_PESQLJ/VS1_NUMNFI/VS1_SERNFI/VS1_NUMLIB/VS1_NUMLIS/VS1_PEDREF/VS1_ORCACE/VS1_NUMAGE/"
			aAdd(aCloneVS1,{X3_CAMPO, ""})
		Case cCpoSX3 $ "VS1_STATUS/VS1_RESERV/"
			aAdd(aCloneVS1,{X3_CAMPO, "0"})
		Case cCpoSX3 == "VS1_STARES"
			aAdd(aCloneVS1,{X3_CAMPO, "3"})
		Case cCpoSX3 $ "VS1_VALPRE/VS1_PERDES/"
			aAdd(aCloneVS1,{X3_CAMPO, 0})
		Case (cCpoSX3 $ "VS1_VTOTNF/VS1_VALDES/VS1_DESACE/VS1_ICMCAL/VS1_VALFRE/VS1_VALSEG/VS1_PERDES/VS1_DESCON/VS1_ICMRET/VS1_BRICMS/VS1_VALDUP/VS1_VALPIS/VS1_VALCOF/VS1_VALIPI/VS1_VALISS/") .and. nAviso == 2
			aAdd(aCloneVS1,{X3_CAMPO, 0})
		Case cCpoSX3 == "VS1_OBSMEM"
			if !Empty(VS1->VS1_OBSMEM)
				nRecNo := SX3->(RecNo())
				cOBSMem := VS1->VS1_OBSMEM
				aObserv := {}
				DBSelectArea("SYP")
				DBSetOrder(1)
				DBSeek(xFilial("SYP") + cOBSMem)
				while !eof() .and. xFilial("SYP") + cOBSMem == YP_FILIAL + YP_CHAVE
					aAdd(aObserv,{SYP->YP_TEXTO, SYP->YP_SEQ})
					DBSkip()
				enddo
				cChaveNova := GetSX8Num("SYP","YP_CHAVE")
				ConfirmSX8()
				DBSelectArea("SYP")
				for nCntFor := 1 to Len(aObserv)
					reclock("SYP",.t.)
					YP_FILIAL := xFilial("SYP") 
					YP_SEQ := aObserv[nCntFor,2]
					YP_CHAVE  := cChaveNova
					YP_TEXTO  := aObserv[nCntFor,1]
					YP_CAMPO  := "VS1_OBSMEM"
					msunlock()
				next
				DBSelectArea("SX3")
				DBSetOrder(1)
				DBGoto(nRecNo)
				aAdd(aCloneVS1,{X3_CAMPO,cChaveNova })
			endif
		Case x3_context != "V"
			aAdd(aCloneVS1,{X3_CAMPO, &("VS1->"+X3_CAMPO)})
	EndCase
	dbSelectArea("SX3")
	DBSkip()
enddo

DBSelectArea("VS1")
reclock("VS1",.t.)
VS1->VS1_FILIAL := xFilial("VS1")
for nCntFor = 1 to Len(aCloneVS1)
	&(aCloneVS1[nCntFor,1]) := aCloneVS1[nCntFor,2]
next                  
If FM_PILHA("OXA011COS")
	VS1->VS1_KILOME := VO1->VO1_KILOME
Endif
VS1->VS1_PEDSTA := "0"
MsUnlock()
If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
	If lLibPV
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0107+" - "+STR0099 ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Liberar Itens com Saldo
	Else
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0108+" - "+STR0029 ) // Grava Data/Hora na Mudança de Status do Orçamento / Orçamento por Fases / Clonar
	EndIf
EndIf
//
if nAviso == 1 
	DBSelectArea("VS3")
	DBSetOrder(1)
	DBSeek(xFilial("VS3")+cOrcOri)
	aRecNos := {}
	while !eof() .and. VS3->VS3_FILIAL+VS3->VS3_NUMORC == xFilial("VS3")+cOrcOri
		aAdd(aRecNos,RecNo())
		DbSkip()
	enddo
	//
	for nCntFor := 1 to Len(aRecNos)
		DBSelectArea("VS3")
		DBGoto(aRecNos[nCntFor])
		//
		aCloneVS3 := {}
		nQtItOri  := 0
		//
		SB1->(DBSetOrder(7))
		SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
		nSaldo := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+VS3->VS3_LOCAL)
		//
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VS3")
		While !Eof().and.(x3_arquivo=="VS3")
			cCpoSX3 := AllTrim(X3_CAMPO)
			Do Case
				Case cCpoSX3 == "VS3_NUMORC"
					aAdd(aCloneVS3,{X3_CAMPO, cOrcClone})
				Case cCpoSX3 $ "VS3_RESERV/VS3_IMPRES/"
					aAdd(aCloneVS3,{X3_CAMPO,"0" })
				Case cCpoSX3 == "VS3_QTDINI" 
					If lPediVenda
						aAdd(aCloneVS3,{X3_CAMPO, VS3->VS3_QTDINI})
					Else
						aAdd(aCloneVS3,{X3_CAMPO, VS3->VS3_QTDITE})
					Endif
				Case cCpoSX3 == "VS3_QTDCON" .and. ! lPediVenda
					aAdd(aCloneVS3,{X3_CAMPO, 0})
				Case cCpoSX3 == "VS3_QTDAGU" .and. ( !lPediVenda .OR. lBo)
					aAdd(aCloneVS3,{X3_CAMPO, 0})
				Case cCpoSX3 $ "VS3_QTDRES/VS3_QTDTRA/VS3_QTDELI/"
					aAdd(aCloneVS3,{X3_CAMPO, 0})			
				Case cCpoSX3 == "VS3_QTDITE" .and. lPediVenda
					If lLibPV // Libera no Pedido de Venda
						aAdd(aCloneVS3,{"VS3_QESTNA", VS3->VS3_QESTNA})
						If nSaldo >= VS3->VS3_QTDITE
							nQtItOri :=  VS3->VS3_QTDITE
							aAdd(aCloneVS3,{X3_CAMPO, VS3->VS3_QTDITE})
							lAtuClo := .f.
						Else
							nQtItOri :=  nSaldo
							aAdd(aCloneVS3,{X3_CAMPO, VS3->VS3_QTDITE - nSaldo})
							aAdd(aCloneVS3,{"VS3_FLGNAT", "!"})
							lAtuClo := .t.
						Endif
					Else
						aAdd(aCloneVS3,{"VS3_QESTNA", nSaldo})
						aAdd(aCloneVS3,{X3_CAMPO, VS3->VS3_QTDITE})
					Endif
				Case cCpoSX3 == "VS3_QTDPED" .and. lPediVenda
					aAdd(aCloneVS3,{X3_CAMPO, 0})
				Case cCpoSX3 $ "VS3_MOTPED/VS3_DOCSDB/VS3_LOTECT/VS3_NUMLOT/VS3_FCICOD/"
					aAdd(aCloneVS3,{X3_CAMPO,"" })
				Case cCpoSX3 $ "VS3_PEDXML/VS3_ITEXML/"
					If lPediVenda .and. lLibPV // Carregar o mesmo PEDXML/ITEXML
						aAdd(aCloneVS3,{X3_CAMPO,&("VS3->"+X3_CAMPO)})
					Else // Limpa variavel se não for Libera no Pedido de Venda
						aAdd(aCloneVS3,{X3_CAMPO,"" })
					EndIf
				Case x3_context != "V"
					aAdd(aCloneVS3,{X3_CAMPO, &("VS3->"+X3_CAMPO)})
			EndCase
			dbSelectArea("SX3")
			DBSkip()
		enddo
		DBSelectArea("VS3")
		If lLibPV
			reclock("VS3",.f.)
			VS3->VS3_QTDITE := nQtItOri
			if lAtuClo
				VS3->VS3_FLGNAT := "!"
			endif
			MsUnlock()      
		Endif
		If lAtuClo
			reclock("VS3",.t.)
			VS3->VS3_FILIAL := xFilial("VS3")
			for nCntFor2 = 1 to Len(aCloneVS3)
				&(aCloneVS3[nCntFor2,1]) := aCloneVS3[nCntFor2,2]
			next
			if !Empty(VS3->VS3_FLGNAT) .AND. VS3->VS3_FLGNAT != '!'
				VS3->VS3_FLGNAT := ""
			EndIf
			msunlock()
		Endif
	next
	//
	DBSelectArea("VS4")
	DBSetOrder(1)
	DBSeek(xFilial("VS4")+cOrcOri)
	aRecNos := {}
	while !eof() .and. VS4->VS4_FILIAL+VS4->VS4_NUMORC == xFilial("VS4")+cOrcOri
		aAdd(aRecNos,RecNo())
		DbSkip()
	enddo
	//
	for nCntFor := 1 to Len(aRecNos)
		DBSelectArea("VS4")
		DBGoto(aRecNos[nCntFor])
		//
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VS4")
		aCloneVS4 := {}
		//
		While !Eof().and.(x3_arquivo=="VS4")
			if AllTrim(X3_CAMPO) == "VS4_NUMORC"
				aAdd(aCloneVS4,{X3_CAMPO,cOrcClone })
			elseif x3_context != "V"
				aAdd(aCloneVS4,{X3_CAMPO, &("VS4->"+X3_CAMPO)})
			endif
			DBSkip()
		enddo
		DBSelectArea("VS4")
		reclock("VS4",.t.)
		for nCntFor2 = 1 to Len(aCloneVS4)
			&(aCloneVS4[nCntFor2,1]) := aCloneVS4[nCntFor2,2]
		next
	next
	//
	// Inconvenientes ...
	If GetNewPar("MV_INCORC","N") == "S"
		DBSelectArea("VST")
		DBSetOrder(1)
		DBSeek(xFilial("VST")+"1"+cOrcOri)
		aRecNos := {}
		while !eof() .and. VST->VST_FILIAL == xFilial("VST") .and. VST->VST_TIPO == "1" .and. VST->VST_CODIGO == cOrcOri
			aAdd(aRecNos,RecNo())
			DbSkip()
		enddo
		For nCntFor := 1 to Len(aRecNos)
			DBSelectArea("VST")
			DBGoto(aRecNos[nCntFor])
			//
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("VST")
			aCloneVST := {}
			//
			While !Eof().and.(x3_arquivo=="VST")
				if AllTrim(X3_CAMPO) == "VST_CODIGO"
					aAdd(aCloneVST,{X3_CAMPO,cOrcClone })
				elseif x3_context != "V"
					aAdd(aCloneVST,{X3_CAMPO, &("VST->"+X3_CAMPO)})
				endif
				DBSkip()
			enddo
			DBSelectArea("VST")
			reclock("VST",.t.)
			for nCntFor2 = 1 to Len(aCloneVST)
				&(aCloneVST[nCntFor2,1]) := aCloneVST[nCntFor2,2]
			next
		next
	EndIf
Endif
//
END TRANSACTION
//
If ExistBlock("OA011DCL") // Ponto de Entrada apos Clonagem
	ExecBlock("OA011DCL",.f.,.f.)
EndIf
//
MsgInfo(IIf(cTpMsgVS1=="O",STR0026,STR0071)+Alltrim(cOrcClone), STR0018)

DBSelectArea("VAI")
DBSetOrder(4)
DBSeek(xFilial("VAI")+__cUserId)

VS1->(dbSetOrder(1))

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Orcamento de Pecas e Servicos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ (STR0002) 	,"AxPesqui" 		, 0 , 1},;			// Pesquisar
					{ (STR0003) 	,"OXA011"    		, 0 , 2},;			// Visualizar
					{ (STR0004) 	,"OXA011"    		, 0 , 3},;			// Incluir
					{ (STR0027) 	,"OXA011"     		, 0 , 4},;			// Alterar
					{ (STR0005) 	,"OXA011"     		, 0 , 5},;			// Cancelar
					{ (STR0028) 	,"OXA011"     		, 0 , 6},;			// Faturar
					{ (STR0029) 	,"OXA011CLO"   		, 0 , 6},;			// Clonar
					{ (STR0036) 	,"OXA011COS"   		, 0 , 7},;			// Clonar por OS
					{ (STR0099) 	,"OXA0110011_LiberaOrcamentoOficina", 0 , 6},;			// Liberar Itens com Saldo
					{ (STR0006) 	,"OXA011LEG"		, 0 , 8} }			// Legenda

aadd(aRotina,{ STR0126 ,"OXA0110021_AguardarOutroOrcamento", 0 , 4})	// Aguardar outro Orçamento

If FindFunction("OFIOC430") //se existir a pesquisa avancada exibe na tela
	aadd(aRotina,{ (STR0030) 	,"OFIOC430"   		, 0 , 1}) 	// Pesquisa Avancada
EndIF                       

if GetNewPar("MV_VERIORC","1") $ "2"
	If FindFunction("OFIXC008")
		aadd(aRotina,{ STR0061 	,"OFIXC008"   		, 0 , 1}) // Consulta de Peca
	EndIF
Elseif GetNewPar("MV_VERIORC","1") $ "M_CONSPEC"
	If FindFunction("U_M_CONSPEC")
		aadd(aRotina,{ STR0061 	,"U_M_CONSPEC"   		, 0 , 1}) // Consulta de Peca
	EndIF
Else
	If FindFunction("OFIXC001")
		aadd(aRotina,{ STR0061 	,"OFIXC001(,cFilOld)"   		, 0 , 1}) // Consulta de Peca
	EndIF
Endif
if GetNewPar("MV_MIL0012","0") $ "1"
	If FindFunction("OXA16NCRED")
		aadd(aRotina,{ STR0068 	,"OXA16NCRED"   		, 0 , 1}) // Consulta Motivo Negat. Crédito 
	Endif
Endif	
//If FindFunction("U_M_CONSPEC")
//	aadd(aRotina,{ STR0061 	,"U_M_CONSPEC"   		, 0 , 1}) // Consulta de Peca
//EndIF
aadd(aRotina, { (STR0096) 	,"OXAGERFIN"   		, 0 , 6})			// Gerar Financeiro
aadd(aRotina, { STR0105 	,"OXA011VQL"   		, 0 , 2})			// "Consulta Log Integração Financeiro"
If FindFunction("OFIC250") //se existir a Consulta Tempos por Status do Orçamento
	aadd(aRotina,{ STR0109 ,"OFIC250(VS1->VS1_NUMORC)" , 0 , 2}) // Tempos por Status do Orçamento
EndIf

//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para alteração do aRotina (menu)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("OXA011BOT") ) // Ponto de entrada para adicionar botões na mbrowse na tela de orçamentos fases
	aRotina := ExecBlock("OXA011BOT",.f.,.f.,{aRotina})
EndIf

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDefAG  ³ Autor ³ Andre Luis / Rubens             ³ Data ³ 16/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Quando for chamado do Agendamento (Sem Opcao de       ³±±
±±³          ³ FATURAR e CLONAR )                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDefAG()
Local aRotina := {	{ OemtoAnsi(STR0002) 	,"AxPesqui" 		, 0 , 1},;			// Pesquisar
{ OemtoAnsi(STR0003) 	,"OXA011"    		, 0 , 2},;			// Visualizar
{ OemtoAnsi(STR0004) 	,"OXA011"    		, 0 , 3},;			// Incluir
{ OemtoAnsi(STR0027)	,"OXA011"     		, 0 , 4},;			// Alterar
{ OemtoAnsi(STR0005) 	,"OXA011"     		, 0 , 5},;			// Cancelar
{ OemtoAnsi(STR0006) 	,"OXA011LEG"		, 0 , 7} }			// Legenda
If FindFunction("OFIOC430") //se existir a pesquisa avancada exibe na tela
	aadd(aRotina,{ OemtoAnsi(STR0030) 	,"OFIOC430"   		, 0 , 1}) 	// Pesquisa Avancada
EndIF
If FindFunction("OFIXC008")
	aadd(aRotina,{ STR0061 	,"OFIXC008"   		, 0 , 1}) // Consulta de Peca
EndIF
If FindFunction("OFIC250") //se existir a Consulta Tempos por Status do Orçamento
	aadd(aRotina,{ STR0109 ,"OFIC250(VS1->VS1_NUMORC)" , 0 , 2}) // Tempos por Status do Orçamento
EndIf
//
Return aRotina

/*/{Protheus.doc} OXA011VQL
	Consulta LOG de erro de integração com financeiro 
	@type  Function
	@author Rubens Takahashi
	@since 07/07/2021
	@version 1.0
	/*/
Function OXA011VQL(cAlias,nReg,nOpc)
Local aBkpRotina

If VS1->VS1_STATUS == "X" .AND. VS1->VS1_GERFIN == "0"
	aBkpRotina := aClone(aRotina)
	aRotina := {}
	OFIC020("OFIXX004","@VQL_TIPO = 'VS1-" + VS1->VS1_NUMORC + "' AND VQL_FILORI = '" + VS1->VS1_FILIAL + "' ", .F. )
	aRotina := aClone(aBkpRotina)
Else
	MsgInfo(STR0106) // "Consulta utilizada quando não foi possível gerar os títulos de contas à receber em fechamento com condição negociada."
EndIf


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA011LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Orcamento de Pecas e Servicos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011LEG(nReg)
Local uRetorno := .t.
Local nSeparac := 12 // Linha de Separação dos vetores que corresponde a divisão do Orçamento Balcão e Orçamento Oficina
Local nCont    := 0
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
// Se aumentar a matriz de cores e/ou a matriz de legenda verificar o tratamento depois da execucao do PE OA011COR
// para a criacao da matriz uRetorno
aLegenda := {}
aadd(aLegenda, {'BR_VERDE',    STR0110}) // 01 - Orçamento Balcão Digitado
aadd(aLegenda, {'BR_PINK',     STR0111}) // 02 - Orçamento Balcão Margem Pendente
aadd(aLegenda, {'BR_BRANCO',   STR0112}) // 03 - Orçamento Balcão Avaliação de Crédito
aadd(aLegenda, {'BR_AZUL',     STR0113}) // 04 - Orçamento Balcão Aguardando Separação
aadd(aLegenda, {'BR_MARROM',   STR0114}) // 05 - Orçamento Balcão Aguardando Lib.Diverg.
aadd(aLegenda, {'BR_AMARELO',  STR0115}) // 06 - Orçamento Balcão Liberado p/ Faturamento
aadd(aLegenda, {'BR_AZUL_CLARO',STR0127 }) // 07 - Orçamento Balcão aguardando outro Orçamento
aadd(aLegenda, {'BR_PRETO',    STR0116}) // 08 - Orçamento Balcão Faturado
aadd(aLegenda, {'lbok_ocean',  STR0117}) // 09 - Orçamento Balcão Faturado S/ Financeiro
aadd(aLegenda, {'BR_VERMELHO', STR0118}) // 10 - Orçamento Balcão Cancelado
aadd(aLegenda, {'BR_CINZA',    STR0119}) // 11 - Orçamento Balcão Aguardando Reserva
aadd(aLegenda, {'', 		   "----------------------------------------------"}) // 12
aadd(aLegenda, {'f10_verd',    STR0121}) // 13 - Orçamento Oficina Digitado
aadd(aLegenda, {'f12_azul',    STR0122}) // 14 - Orçamento Oficina Pendente para O.S.
aadd(aLegenda, {'f5_amar' ,    STR0123}) // 15 - Orçamento Oficina Liberado para O.S.
aadd(aLegenda, {'f14_cinz',    STR0124}) // 16 - Orçamento Oficina Importado para O.S.
aadd(aLegenda, {'f7_verm' ,    STR0125}) // 17 - Orçamento Oficina Cancelado
//
aCores := {}
//
If ( ExistBlock("OA011LEG") )
	aLegenda := ExecBlock("OA011LEG",.f.,.f.,{aLegenda})
EndIf
//
If nReg == NIL 	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
 	aAdd(aCores, {'VS1->VS1_STATUS == "0" .AND. VS1->VS1_TIPORC == "1"', 'BR_VERDE'})	 // 01 - Orçamento Balcão Digitado
 	aAdd(aCores, {'VS1->VS1_STATUS == "2" .AND. VS1->VS1_TIPORC == "1"', 'BR_PINK'})     // 02 - Orçamento Balcão Margem Pendente
 	aAdd(aCores, {'VS1->VS1_STATUS == "3"'							   , 'BR_BRANCO'})   // 03 - Orçamento Balcão Avaliação de Crédito
 	aAdd(aCores, {'VS1->VS1_STATUS == "' + cFaseConfer + '"'	       , 'BR_AZUL'})	 // 04 - Orçamento Balcão Aguardando Separação
 	aAdd(aCores, {'VS1->VS1_STATUS == "5"'							   , 'BR_MARROM'})	 // 05 - Orçamento Balcão Aguardando Lib.Diverg.
 	aAdd(aCores, {'VS1->VS1_STATUS == "F" .AND. VS1->VS1_TIPORC == "1"', 'BR_AMARELO'})	 // 06 - Orçamento Balcão Liberado p/ Faturamento
	aAdd(aCores, {'VS1->VS1_STATUS == "G"'							   , 'BR_AZUL_CLARO'}) // 07 - Orçamento Balcão aguardando outro Orçamento
	aAdd(aCores, {'VS1->VS1_STATUS == "X" .AND. VS1->VS1_GERFIN <> "0"', 'BR_PRETO'})	 // 08 - Orçamento Balcão Faturado
	aAdd(aCores, {'VS1->VS1_STATUS == "X" .AND. VS1->VS1_GERFIN == "0"', 'lbok_ocean'})  // 09 - Orçamento Balcão Faturado S/ Financeiro
 	aAdd(aCores, {'VS1->VS1_STATUS == "C" .AND. VS1->VS1_TIPORC == "1"', 'BR_VERMELHO'}) // 10 - Orçamento Balcão Cancelado
 	aAdd(aCores, {'VS1->VS1_STATUS $ "RT"'							   , 'BR_CINZA'})	 // 11 - Orçamento Balcão Aguardando Reserva
	aAdd(aCores, {'',''}) // 12 - Separação para ficar com as mesmas linhas do aLegenda --> NAO USAR
 	aAdd(aCores, {'VS1->VS1_STATUS == "0" .AND. VS1->VS1_TIPORC == "2"', 'f10_verd'})	 // 13 - Orçamento Oficina Digitado
 	aAdd(aCores, {'VS1->VS1_STATUS == "P".OR. (VS1->VS1_STATUS == "2" .AND. VS1->VS1_TIPORC == "2")', 'f12_azul'}) // 14 - Orçamento Oficina Pendente para O.S.
 	aAdd(aCores, {'VS1->VS1_STATUS == "L".OR. (VS1->VS1_STATUS == "F" .AND. VS1->VS1_TIPORC == "2")', 'f5_amar'})  // 15 - Orçamento Oficina Liberado p/ Exportação
 	aAdd(aCores, {'VS1->VS1_STATUS == "I"'							   , 'f14_cinz'})	 // 16 - Orçamento Oficina Importado para O.S.
 	aAdd(aCores, {'VS1->VS1_STATUS == "C" .AND. VS1->VS1_TIPORC == "2"', 'f7_verm'})	 // 17 - Orçamento Oficina Cancelado
 	If ( ExistBlock("OA011COR") )
 		ExecBlock("OA011COR",.f.,.f.)
	EndIf
	For nCont := 1 to Len(aCores)
		If nCont <> nSeparac
			AADD(uRetorno, {aCores[nCont, 01], aLegenda[nCont, 01], aLegenda[nCont, 02]})
		EndIf
	Next
Else
	BrwLegenda(cCadastro,STR0006,aLegenda)
EndIf
//
Return uRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA011COS ³ Autor ³ Thiago									  ³ Data ³ 18/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Clonagem do Orçamento a partir da OS.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011COS()
Local aObjects   := {} , aPos := {} , aInfo := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cNumOS := space(TamSX3("VO1_NUMOSV")[1])
Local nOpca := 0
Local nOpcb := 0
Local nRecVS1Ori := VS1->(RecNO())
Local aNewBot := {}
Private cAliasVS1   := "SQLVS1"
Private aOS := {{"","","","","","",0,0}}
//
nCloOrc := .t.
DEFINE MSDIALOG oDlgClo TITLE STR0041 FROM  01,01 TO 07,50 OF oMainWnd   // Opcoes de Movimentacao

@ 08,15 SAY STR0042 SIZE 80,8 OF oDlgClo PIXEL 
@ 08,95 MSGET oNumOS VAR cNumOS PICTURE "@!" F3 "VO1" VALID FS_VALOS(cNumOS) SIZE 80,08 OF oDlgClo PIXEL 

DEFINE SBUTTON FROM 25,120 TYPE 1 ACTION ( nOpca := 1, oDlgClo:End() ) ENABLE OF oDlgClo
DEFINE SBUTTON FROM 25,150 TYPE 2 ACTION ( nOpca := 0, oDlgClo:End() ) ENABLE OF oDlgClo

ACTIVATE MSDIALOG oDlgClo CENTER 

if nOpca == 1
   if !Empty(cNumOS)
		cQuery := "SELECT VS1_NUMORC , VS1_TIPTEM , VS1_TIPTSV ,"
		cQuery += "       VS1_CLIFAT , VS1_LOJA , VS1_NCLIFT , VS1_VTOTNF ,"
		cQuery += "       R_E_C_N_O_ AS RECVS1 "
		cQuery += "  FROM "+RetSqlName( "VS1" )
		cQuery += " WHERE VS1_FILIAL = '"+ xFilial("VS1")+ "'"
		cQuery += "   AND VS1_NUMOSV = '"+cNumOS+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS1, .T., .T. )
		
		Do While !( cAliasVS1 )->( Eof() )  
		                            
			if Len(aOS) == 1 .and. Empty(aOS[1,1])
			   aOS := {}
			Endif   
			aAdd(aOS,{(	cAliasVS1 )->VS1_NUMORC ,;
						( cAliasVS1 )->VS1_TIPTEM ,;
						( cAliasVS1 )->VS1_TIPTSV ,;
						( cAliasVS1 )->VS1_CLIFAT ,;
						( cAliasVS1 )->VS1_LOJA ,;
						( cAliasVS1 )->VS1_NCLIFT ,;
						( cAliasVS1 )->VS1_VTOTNF ,;
						( cAliasVS1 )->RECVS1 })
		   ( cAliasVS1 )->(dbSkip())
		Enddo
		( cAliasVS1 )->( dbCloseArea() )
		DbSelectArea("VS1")

		AADD(aNewBot, {"ANALITICO",{|| OXA011VORC(aOS[oLblOS:nAt,8]) },( STR0043 )} )
		
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		// Configura os tamanhos dos objetos
		aObjects := {}
		AAdd( aObjects, { 0 ,   0 , .T. , .T. } ) // TELA 100%
		aPos := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oDlgBusca TITLE STR0044 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL
		
		@ aPos[1,1],aPos[1,2] LISTBOX oLblOS ;
								FIELDS HEADER STR0045,STR0046,STR0047,STR0048,STR0049,STR0050,STR0051 ;
								COLSIZES 50,30,30,40,20,130,60 SIZE aPos[1,4],aPos[1,3]-aPos[1,1] ;
								OF oDlgBusca PIXEL ;
								ON DBLCLICK OXA011VORC(aOS[oLblOS:nAt,8])
		oLblOS:SetArray(aOS)
		oLblOS:bLine := { || {	aOS[oLblOS:nAt,1],;
								aOS[oLblOS:nAt,2],;
								aOS[oLblOS:nAt,3],;
								aOS[oLblOS:nAt,4],;
								aOS[oLblOS:nAt,5],;
								aOS[oLblOS:nAt,6],;
								FG_AlinVlrs(Transform(aOS[oLblOS:nAt,7],"@E 999,999.99")) }}
	
	   ACTIVATE MSDIALOG oDlgBusca ON INIT EnchoiceBar(oDlgBusca, { || OXA011CLN(aOS[oLblOS:nAt,8]), nOpcb := 1, oDlgBusca:End() } , { || nOpcb := 2, oDlgBusca:End() },,aNewBot )
	   if nOpcb == 2 .or. nOpcb == 0
	      OXA011COS()
	   Endif
   Endif	
Endif
If nRecVS1Ori > 0
	DbSelectArea("VS1")
	DbSetOrder(1)
	DbGoTo(nRecVS1Ori)
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALOS  ³ Autor ³ Thiago                            ³ Data ³ 18/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao na ordem de servico informada.                               ³±±
±±³          ³ Esta em SQL para funcionar mesmo com filtro do mBrowse                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VALOS(cNumOS)
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM " + RetSqlName( "VO1" )  
cQuery += " WHERE VO1_FILIAL = '"+ xFilial("VO1")+ "'"
cQuery += "   AND VO1_NUMOSV = '"+cNumOS+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) == 0
	MsgStop(STR0052)
	Return(.f.)
Endif
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM " + RetSqlName( "VS1" )  
cQuery += " WHERE VS1_FILIAL = '"+ xFilial("VS1")+ "'"
cQuery += "   AND VS1_NUMOSV = '"+cNumOS+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) == 0
	MsgStop(STR0053)
	Return(.f.)
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA011VORC  ³ Autor ³ Thiago				   			  ³ Data ³ 18/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza orcamento.							                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011VORC(nRecVS1)
if nRecVS1 == 0
	MsgStop(STR0054)
	Return(.f.)
Else
	dbSelectArea("VS1")
	DbSetOrder(1)
	dbGoTo(nRecVS1)
	OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OXA011CLN ³  Autor ³ Thiago			   	   			  ³ Data ³ 18/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada da funcao para clonar orcamento.	                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011CLN(nRecVS1)

If nRecVS1 > 0
	dbSelectArea("VS1")
	DbSetOrder(1)
	DbGoTo(nRecVS1)
	OXA011CLO(NIL,NIL,8)
EndIf

Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FSO11F12   | Autor |  Thiago		          | Data | 08/11/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Parametros da F12                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FSO11F12
Local xSlvPar01 := Mv_Par01

If !Pergunte("OF011F12",.t.)
	Mv_Par01   := xSlvPar01
	Return()
EndIf

nVerParFat := Mv_Par01
Mv_Par01   := xSlvPar01

Return





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA011OSC  ³ Autor ³ Fabio Passeti                   ³ Data ³ 22/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Clonar Orcamento a partir dos dados da OS                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011OSC(cAlias,nReg,nOpc)
//
Local nCntFor,nCntFor2
Local nQtItOri:= 0
Local cTTPec  := ""
Local cTTSrv  := ""
Local cFormula:= ""
Local aTTPec  := {}
Local aTTSrv  := {}
Local aTTInc  := {}
Local cOBSMem := ""

PRIVATE cPerg := "OX011OSCL"

Default nOpc := ""

if ExistBlock("OX011OSCL")
	if !ExecBlock("OX011OSCL",.f.,.f.)
		Return(.t.)
	Endif
Endif

ValidPerg()
If !Pergunte(cPerg,.T.)                               
	Return
EndIf

DBSelectArea("VO1")
DBSetOrder(1)
If !DBSeek( xFilial("VO1") + MV_PAR01 )
	
	MsgStop( OemtoAnsi(STR0078) , OemtoAnsi(STR0037) )
	Return
	
EndIf

inclui := .T.

DBSelectArea("VV1")
DBSetOrder(1)
DBSeek(xFilial("VV1")+VO1->VO1_CHAINT)

&& Levanta tempos de pecas
aTTPec := FMX_CALPEC(VO1->VO1_NUMOSV, MV_PAR02, /*cGruIte*/, /*cCodIte*/, /*lMov*/, /*lNegoc*/, .T., .T. /*lRetAbe*/, .T. /*lRetLib*/, /*lRetFec*/, /*lRetCan*/, /*cLibVOO*/, /*cFiltroSQL*/, /*lRetRem*/, /*lAgrInc*/ )

If Len(aTTPec) # 0
	cTTPec  := aTTPec[1,3]
	cFormula:= aTTPec[1,27]
	
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+aTTPec[1,15]+aTTPec[1,16])
EndIf
	
&& Levanta tempos de servico
aTTSrv := FMX_CALSER(VO1->VO1_NUMOSV, MV_PAR03, /*cGruSer*/, /*cCodSer*/, .f., /*lNegoc*/, .T. /*lRetAbe*/, .T. /*lRetLib*/, /*lRetFec*/, /*lRetCan*/, /*cLibVOO*/, /*cFiltroSQL*/ )

If Len(aTTSrv) # 0
	cTTSrv  := aTTSrv[1,4]
	                  
	If !SA1->(Found())      && Caso nao tenha o registro de pecas considera o fatpar de servicos
		DBSelectArea("SA1")
		DBSetOrder(1)
		DBSeek(xFilial("SA1")+aTTSrv[1,20]+aTTSrv[1,21])
	EndIf
EndIf

If ( Len(aTTPec) == 0 .And. Len(aTTSrv) == 0 )

	MsgStop( OemtoAnsi(STR0079) , OemtoAnsi(STR0037) )
	Return
                   
EndIf
		
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS1")
aCloneVS1 := {}

cOrcClone := GetSXENum("VS1","VS1_NUMORC")
ConfirmSx8()

BEGIN TRANSACTION

While !Eof().and.(x3_arquivo=="VS1")
	if AllTrim(X3_CAMPO) == "VS1_NUMORC"
		aAdd(aCloneVS1,{X3_CAMPO, cOrcClone })
	elseif AllTrim(X3_CAMPO) == "VS1_TIPORC"
		aAdd(aCloneVS1,{X3_CAMPO, "2"})
	elseif AllTrim(X3_CAMPO) == "VS1_CLIFAT"
		aAdd(aCloneVS1,{X3_CAMPO, SA1->A1_COD})
	elseif AllTrim(X3_CAMPO) == "VS1_LOJA"
		aAdd(aCloneVS1,{X3_CAMPO, SA1->A1_LOJA})
	elseif AllTrim(X3_CAMPO) == "VS1_NCLIFT"
		aAdd(aCloneVS1,{X3_CAMPO, SA1->A1_NOME})
	elseif AllTrim(X3_CAMPO) == "VS1_TIPCLI"
		aAdd(aCloneVS1,{X3_CAMPO, SA1->A1_TIPO})
	elseif AllTrim(X3_CAMPO) == "VS1_TIPTEM"
		aAdd(aCloneVS1,{X3_CAMPO, cTTPec})
	elseif AllTrim(X3_CAMPO) == "VS1_TIPTSV"
		aAdd(aCloneVS1,{X3_CAMPO, cTTSrv})
	elseif AllTrim(X3_CAMPO) == "VS1_KILOME"
		aAdd(aCloneVS1,{X3_CAMPO, VO1->VO1_KILOME})
	elseif AllTrim(X3_CAMPO) == "VS1_CODMAR"
		aAdd(aCloneVS1,{X3_CAMPO, VV1->VV1_CODMAR})
	elseif AllTrim(X3_CAMPO) == "VS1_CHAINT"
		aAdd(aCloneVS1,{X3_CAMPO, VV1->VV1_CHAINT})
	elseif AllTrim(X3_CAMPO) == "VS1_DATORC"
		aAdd(aCloneVS1,{X3_CAMPO, CriaVar(X3_CAMPO)})
	elseif AllTrim(X3_CAMPO) == "VS1_HORORC"
		aAdd(aCloneVS1,{X3_CAMPO, CriaVar(X3_CAMPO)})
	elseif AllTrim(X3_CAMPO) == "VS1_DATVAL"
		aAdd(aCloneVS1,{X3_CAMPO, CriaVar(X3_CAMPO)})
	elseif AllTrim(X3_CAMPO) == "VS1_NUMOSV"
		aAdd(aCloneVS1,{X3_CAMPO, ""})
	elseif AllTrim(X3_CAMPO) == "VS1_FORMUL"
		aAdd(aCloneVS1,{X3_CAMPO, cFormula})
	elseif AllTrim(X3_CAMPO) == "VS1_NUMPED"
		aAdd(aCloneVS1,{X3_CAMPO, ""})
	elseif AllTrim(X3_CAMPO) == "VS1_NUMNFI"
		aAdd(aCloneVS1,{X3_CAMPO, ""})
	elseif AllTrim(X3_CAMPO) == "VS1_SERNFI"
		aAdd(aCloneVS1,{X3_CAMPO, ""})
	elseif AllTrim(X3_CAMPO) == "VS1_NUMLIB"
		aAdd(aCloneVS1,{X3_CAMPO, ""})
	elseif AllTrim(X3_CAMPO) == "VS1_NUMLIS"
		aAdd(aCloneVS1,{X3_CAMPO, ""})
	elseif AllTrim(X3_CAMPO) == "VS1_ORCACE"
		aAdd(aCloneVS1,{X3_CAMPO, ""})
	elseif AllTrim(X3_CAMPO) == "VS1_STATUS"
		aAdd(aCloneVS1,{X3_CAMPO, "0"})
	elseif AllTrim(X3_CAMPO) == "VS1_RESERV"
		aAdd(aCloneVS1,{X3_CAMPO, "0"})
	elseif AllTrim(X3_CAMPO) == "VS1_STARES"
		aAdd(aCloneVS1,{X3_CAMPO, "3"})
	elseif (AllTrim(X3_CAMPO) == "VS1_VTOTNF")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALDES")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_DESACE")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_ICMCAL")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALFRE")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALSEG")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_PERDES")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_DESCON")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_ICMRET")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_BRICMS")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALDUP")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALPIS")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALCOF")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALIPI")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif (AllTrim(X3_CAMPO) == "VS1_VALISS")
		aAdd(aCloneVS1,{X3_CAMPO, 0})
	elseif AllTrim(X3_CAMPO) == "VS1_OBSMEM"
		if !Empty(VO1->VO1_OBSMEM)
			nRecNo := SX3->(RecNo())
			cOBSMem := VO1->VO1_OBSMEM
			aObserv := {}
			DBSelectArea("SYP")
			DBSetOrder(1)
			DBSeek(xFilial("SYP") + cOBSMem)
			while !eof() .and. xFilial("SYP") + cOBSMem == YP_FILIAL + YP_CHAVE
				aAdd(aObserv,{SYP->YP_TEXTO, SYP->YP_SEQ})
				DBSkip()
			enddo
			cChaveNova := GetSX8Num("SYP","YP_CHAVE")
			ConfirmSX8()
			DBSelectArea("SYP")
			for nCntFor := 1 to Len(aObserv)
				reclock("SYP",.t.)
				YP_FILIAL := xFilial("SYP") 
				YP_SEQ    := aObserv[nCntFor,2]
				YP_CHAVE  := cChaveNova
				YP_TEXTO  := aObserv[nCntFor,1]
				YP_CAMPO  := "VS1_OBSMEM"
				msunlock()
			next
			DBSelectArea("SX3")
			DBSetOrder(1)
			DBGoto(nRecNo)
			aAdd(aCloneVS1,{X3_CAMPO,cChaveNova })
		endif
	elseif x3_context != "V"
		aAdd(aCloneVS1,{X3_CAMPO, CriaVar(X3_CAMPO)})
	endif

	&& Cria variaveis de memoria	
	If Len(aCloneVS1) # 0
	   &( "M->"+aCloneVS1[Len(aCloneVS1), 1] ) := aCloneVS1[Len(aCloneVS1), 2]
	EndIf
	
	DBSkip()
enddo                            

DBSelectArea("VS1")
reclock("VS1",.t.)
for nCntFor = 1 to Len(aCloneVS1)
	&(aCloneVS1[nCntFor,1]) := aCloneVS1[nCntFor,2]
next                  
VS1->VS1_FILIAL := xFilial("VS1")
VS1->VS1_PEDSTA := "0"
MsUnlock()

for nCntFor := 1 to Len(aTTPec)
      
	&& Salva inconveniente para gravacao posterior
	If ( Len( aTTInc ) == 0 .Or. ( Ascan( aTTInc, {|x| x[1]+x[2]+x[3]+x[4] == aTTPec[nCntFor,20]+aTTPec[nCntFor,21]+aTTPec[nCntFor,22]+aTTPec[nCntFor,23] } ) ) == 0 )
	    
		Aadd( aTTInc, { aTTPec[nCntFor,20], aTTPec[nCntFor,21], aTTPec[nCntFor,22], aTTPec[nCntFor,23] } )
	
	EndIf

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VS3")
	aCloneVS3 := {}
	nQtItOri  := 0
	
	SB1->(DBSetOrder(7))
	SB1->(DBSeek(xFilial("SB1")+aTTPec[nCntFor,1]+aTTPec[nCntFor,2]))
	nSaldo := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"))
	
	While !Eof().and.(x3_arquivo=="VS3")
		if AllTrim(X3_CAMPO) == "VS3_NUMORC"
			aAdd(aCloneVS3,{X3_CAMPO,cOrcClone })
		elseif AllTrim(X3_CAMPO) == "VS3_SEQINC" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,22] })
		elseif AllTrim(X3_CAMPO) == "VS3_SEQUEN" 
			aAdd(aCloneVS3,{X3_CAMPO, StrZero( nCntFor, SX3->X3_TAMANHO )})
		elseif AllTrim(X3_CAMPO) == "VS3_GRUITE" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,1]})
		elseif AllTrim(X3_CAMPO) == "VS3_CODITE" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,2]})
		elseif AllTrim(X3_CAMPO) == "VS3_RESERV"
			aAdd(aCloneVS3,{X3_CAMPO,"0" })
		elseif AllTrim(X3_CAMPO) == "VS3_QTDINI" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,5]})
		elseif AllTrim(X3_CAMPO) == "VS3_QTDCON"
			aAdd(aCloneVS3,{X3_CAMPO, 0})
		elseif AllTrim(X3_CAMPO) == "VS3_QTDAGU"
			aAdd(aCloneVS3,{X3_CAMPO, 0})
		elseif AllTrim(X3_CAMPO) == "VS3_MOTPED" 
			aAdd(aCloneVS3,{X3_CAMPO, ""})
		elseif AllTrim(X3_CAMPO) == "VS3_QTDTRA"
			aAdd(aCloneVS3,{X3_CAMPO, 0})       
		elseif AllTrim(X3_CAMPO) == "VS3_QTDITE"
			aAdd(aCloneVS3,{"VS3_QESTNA", nSaldo})
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,5]})
		elseif AllTrim(X3_CAMPO) == "VS3_QTDPED"
			aAdd(aCloneVS3,{X3_CAMPO, 0})
		elseif AllTrim(X3_CAMPO) == "VS3_DOCSDB"
			aAdd(aCloneVS3,{X3_CAMPO, ""})
		elseif AllTrim(X3_CAMPO) == "VS3_OPER" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,26]})
		elseif AllTrim(X3_CAMPO) == "VS3_TES" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,24]})
		elseif AllTrim(X3_CAMPO) == "VS3_FORMUL" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,27]})
		elseif AllTrim(X3_CAMPO) == "VS3_VALPEC" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,6]})
		elseif AllTrim(X3_CAMPO) == "VS3_VALTOT" 
			aAdd(aCloneVS3,{X3_CAMPO, ( aTTPec[nCntFor,5] * aTTPec[nCntFor,6] ) })
		elseif AllTrim(X3_CAMPO) == "VS3_DEPINT" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,11]})
		elseif AllTrim(X3_CAMPO) == "VS3_DEPGAR" 
			aAdd(aCloneVS3,{X3_CAMPO, aTTPec[nCntFor,12]})
		elseif x3_context != "V"
			aAdd(aCloneVS3,{X3_CAMPO, CriaVar(X3_CAMPO)})
		endif

		&& Cria variaveis de memoria	
		If Len(aCloneVS3) # 0
		   &( "M->"+aCloneVS3[Len(aCloneVS3), 1] ) := aCloneVS3[Len(aCloneVS3), 2]
		EndIf
		
		dbSelectArea("SX3")
		DBSkip()
	enddo
	DBSelectArea("VS3")
	reclock("VS3",.t.)
	for nCntFor2 = 1 to Len(aCloneVS3)
		&(aCloneVS3[nCntFor2,1]) := aCloneVS3[nCntFor2,2]
	next
	VS3->VS3_FILIAL := xFilial("VS3")
	msunlock()

next

for nCntFor := 1 to Len(aTTSrv)

	&& Salva inconveniente para gravacao posterior
	If ( Len( aTTInc ) == 0 .Or. ( Ascan( aTTInc, {|x| x[1]+x[2]+x[3]+x[4] == aTTSrv[nCntFor,33]+aTTSrv[nCntFor,34]+aTTSrv[nCntFor,35]+aTTSrv[nCntFor,36] } ) ) == 0 )
  
		Aadd( aTTInc, { aTTSrv[nCntFor,33], aTTSrv[nCntFor,34], aTTSrv[nCntFor,35], aTTSrv[nCntFor,36] } )
	
	EndIf
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VS4")
	aCloneVS4 := {}
	
	While !Eof().and.(x3_arquivo=="VS4")
		if AllTrim(X3_CAMPO) == "VS4_NUMORC"
			aAdd(aCloneVS4,{X3_CAMPO,cOrcClone })
		elseif AllTrim(X3_CAMPO) == "VS4_SEQINC"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,35] })
		elseif AllTrim(X3_CAMPO) == "VS4_SEQUEN" 
			aAdd(aCloneVS4,{X3_CAMPO, StrZero( nCntFor, SX3->X3_TAMANHO )})
		elseif AllTrim(X3_CAMPO) == "VS4_GRUSER"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,1] })
		elseif AllTrim(X3_CAMPO) == "VS4_CODSER"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,2] })
		elseif AllTrim(X3_CAMPO) == "VS4_TIPSER"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,5] })
		elseif AllTrim(X3_CAMPO) == "VS4_TEMPAD"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,10] })
		elseif AllTrim(X3_CAMPO) == "VS4_VALHOR"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,43] })
		elseif AllTrim(X3_CAMPO) == "VS4_KILROD"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,19] })
		elseif AllTrim(X3_CAMPO) == "VS4_CODSEC"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,18] })
		elseif AllTrim(X3_CAMPO) == "VS4_VALSER"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,7] })
		elseif AllTrim(X3_CAMPO) == "VS4_PERDES"
			aAdd(aCloneVS4,{X3_CAMPO,Round( ( aTTSrv[nCntFor,8] / aTTSrv[nCntFor,7] ) * 100, 2) })
		elseif AllTrim(X3_CAMPO) == "VS4_VALDES"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,8] })
		elseif AllTrim(X3_CAMPO) == "VS4_VALTOT"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,9] })
		elseif AllTrim(X3_CAMPO) == "VS4_DEPGAR"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,46] })
		elseif AllTrim(X3_CAMPO) == "VS4_DEPINT"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,45] })
		elseif AllTrim(X3_CAMPO) == "VS4_CODFOR"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,25] })
		elseif AllTrim(X3_CAMPO) == "VS4_FOLOJA"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,26] })
		elseif AllTrim(X3_CAMPO) == "VS4_NUMTIT"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,27] })
		elseif AllTrim(X3_CAMPO) == "VS4_TIPTIT"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,28] })
		elseif AllTrim(X3_CAMPO) == "VS4_DATPAG"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,29] })
		elseif AllTrim(X3_CAMPO) == "VS4_CODPAG"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,30] })
		elseif AllTrim(X3_CAMPO) == "VS4_NATURE"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,31] })
		elseif AllTrim(X3_CAMPO) == "VS4_VALCUS"
			aAdd(aCloneVS4,{X3_CAMPO,aTTSrv[nCntFor,32] })
		elseif AllTrim(X3_CAMPO) == "VS4_VALVEN"
			aAdd(aCloneVS4,{X3_CAMPO, If( !Empty(aTTSrv[nCntFor,25]), aTTSrv[nCntFor,32], 0 ) })
		elseif x3_context != "V"
			aAdd(aCloneVS4,{X3_CAMPO, CriaVar(X3_CAMPO)})
		endif
		
		&& Cria variaveis de memoria	
		If Len(aCloneVS4) # 0
		   &( "M->"+aCloneVS4[Len(aCloneVS4), 1] ) := aCloneVS4[Len(aCloneVS4), 2]
		EndIf
		
		dbSelectArea("SX3")
		DBSkip()
	enddo
	DBSelectArea("VS4")
	reclock("VS4",.t.)
	for nCntFor2 = 1 to Len(aCloneVS4)
		&(aCloneVS4[nCntFor2,1]) := aCloneVS4[nCntFor2,2]
	next
	VS4->VS4_FILIAL := xFilial("VS4")
	msunlock()
	
next

// Inconvenientes ...
If GetNewPar("MV_INCORC","N") == "S"

	For nCntFor := 1 to Len(aTTInc)

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VST")
		aCloneVST := {}
		//
		While !Eof().and.(x3_arquivo=="VST")
			if AllTrim(X3_CAMPO) == "VST_TIPO"
				aAdd(aCloneVST,{X3_CAMPO,"1" })            && Orcamento
			Elseif AllTrim(X3_CAMPO) == "VST_CODIGO"
				aAdd(aCloneVST,{X3_CAMPO,cOrcClone })
			Elseif AllTrim(X3_CAMPO) == "VST_CODMAR"
				aAdd(aCloneVST,{X3_CAMPO,VV1->VV1_CODMAR })
			Elseif AllTrim(X3_CAMPO) == "VST_SEQINC"
				aAdd(aCloneVST,{X3_CAMPO,aTTInc[nCntFor,3] })
			Elseif AllTrim(X3_CAMPO) == "VST_GRUINC"
				aAdd(aCloneVST,{X3_CAMPO,aTTInc[nCntFor,1] })
			Elseif AllTrim(X3_CAMPO) == "VST_CODINC"
				aAdd(aCloneVST,{X3_CAMPO,aTTInc[nCntFor,2] })
			Elseif AllTrim(X3_CAMPO) == "VST_DESINC"
				aAdd(aCloneVST,{X3_CAMPO,aTTInc[nCntFor,4] })
			Elseif AllTrim(X3_CAMPO) == "VST_CHASSI"
				aAdd(aCloneVST,{X3_CAMPO,VV1->VV1_CHASSI })
			elseif x3_context != "V"
				aAdd(aCloneVST,{X3_CAMPO, CriaVar(X3_CAMPO)})
			endif                         
			
			&& Cria variaveis de memoria	
			If Len(aCloneVST) # 0
			   &( "M->"+aCloneVST[Len(aCloneVST), 1] ) := aCloneVST[Len(aCloneVST), 2]
			EndIf
		
			dbSelectArea("SX3")
			DBSkip()
		enddo
		DBSelectArea("VST")
		reclock("VST",.t.)
		for nCntFor2 = 1 to Len(aCloneVST)
			&(aCloneVST[nCntFor2,1]) := aCloneVST[nCntFor2,2]
		next
		VST->VST_FILIAL := xFilial("VST")
		msunlock()
			
	next  
	
EndIf

//
END TRANSACTION
//
If ExistBlock("OA011DOSCL") // Ponto de Entrada apos Clonagem
	ExecBlock("OA011DOSCL",.f.,.f.)
EndIf
//
MsgInfo(STR0026+Alltrim(cOrcClone), STR0018)

DBSelectArea("VAI")
DBSetOrder(4)
DBSeek(xFilial("VAI")+__cUserId)

VS1->( dbSetOrder(1) )
VS1->( DbSeek(xFilial("VS1")+cOrcClone) )

return .t.
      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OXA011UC  ºAutor  ³Fabio Passeti       º Data ³  29/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Clona orcamento de outra filial                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011OUC(cAlias,nReg,nOpc)
                              
Local aEmp := FWEmpLoad()      && Empresa e filial que o usuário tem acesso      
Local nPosFOri := 0
Local nPosFDes := 0
PRIVATE cPerg := "OX011OUCL"

ValidPerg()
If Pergunte(cPerg,.T.)                               

	If ( Len(aEmp) # 0 .And. ( nPosFOri := Ascan( aEmp, {|x| x[3] == MV_PAR01 }) ) # 0 )  && Verifica se o usuario tem acesso a filial de origem do orcamento

		If MV_PAR01 # xFilial("VS1")
	
			VS1->( DbSetOrder(1) )     
			If VS1->( DbSeek( MV_PAR01 + MV_PAR02 ) )
		      
				OXA011COOF( MV_PAR01, MV_PAR02 )                                 
		
				MsgInfo( OemToAnsi( STR0026 + Chr(10) + Chr(13) + VS1->VS1_FILIAL +" - " + VS1->VS1_NUMORC), OemToAnsi(STR0037) )
				
			Else
			
				MsgStop( OemToAnsi(STR0086), OemToAnsi(STR0037)  )
		
			EndIf   

		Else                                                
		
			nPosFDes := Ascan( aEmp, {|x| x[3] == xFilial("VS1") })		

			MsgStop( OemToAnsi(STR0089) + Chr(10) + Chr(13) ;
			         + OemToAnsi(STR0090) + aEmp[nPosFOri,3] +" - "+ aEmp[nPosFOri,4] + Chr(10) + Chr(13) ;
			         + OemToAnsi(STR0091) + aEmp[nPosFDes,3] +" - "+ aEmp[nPosFDes,4]                     , OemToAnsi(STR0037)  )
		
		EndIf
		
	Else
	    
		MsgStop( OemToAnsi(STR0088), OemToAnsi(STR0037)  )
	
	EndIf   

EndIf   

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OXA011COOFºAutor  ³Fabio Passeti       º Data ³  29/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Clona orcamento de outra filial                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011COOF( cFilOriOrc, cNumOrc )
      
Local cQuery  := ""
Local nColCmp := 0
Local cOBSMem := ""

cOrcClone := GetSXENum("VS1","VS1_NUMORC")
ConfirmSx8()

Begin Transaction
      
If Select("TMPVS1") > 0
	TMPVS1->(DbCloseArea())     
EndIf	
                  
cQuery := " SELECT * "
cQuery += " From " + RetSqlName( "VS1" ) + " VS1 "
cQuery += " WHERE VS1.VS1_FILIAL = '"+cFilOriOrc+"' And VS1.D_E_L_E_T_= ' ' "
cQuery += "       AND VS1.VS1_NUMORC = '"+cNumOrc+"' "

TCQUERY cQuery NEW ALIAS "TMPVS1"

If !Empty( TMPVS1->VS1_NUMORC )

	DbSelectArea("VS1")
	RecLock("VS1", .T. )
			
	For nColCmp := 1 to TMPVS1->(FCount())
	    
		If !( TMPVS1->( FieldName(nColCmp) ) $ "VS1_FILIAL/D_E_L_E_T_/R_E_C_N_O_/R_E_C_D_E_L_" )
	      
			VS1->VS1_FILIAL := xFilial("VS1")
	
			If ( TMPVS1->( FieldName(nColCmp) ) $ "VS1_NUMORC" )
				VS1->VS1_NUMORC := cOrcClone
			ElseIf ( TMPVS1->( FieldName(nColCmp) ) $ "VS1_STATUS" )
				VS1->VS1_STATUS := "0"
			ElseIf ( TMPVS1->( FieldName(nColCmp) ) $ "VS1_DATORC" )
				VS1->VS1_DATORC := CriaVar( TMPVS1->( FieldName(nColCmp) ) )
			ElseIf ( TMPVS1->( FieldName(nColCmp) ) $ "VS1_HORORC" )
				VS1->VS1_HORORC := CriaVar( TMPVS1->( FieldName(nColCmp) ) )
			ElseIf ( TMPVS1->( FieldName(nColCmp) ) $ "VS1_DATVAL" )
				VS1->VS1_DATVAL := CriaVar( TMPVS1->( FieldName(nColCmp) ) )
			
	      Else                               
	      
		      VS1->( &( TMPVS1->(FieldName(nColCmp)) ) ) := If( ValType(VS1->( &( TMPVS1->(FieldName(nColCmp)) ) )) == "D", Stod( TMPVS1->( &( FieldName(nColCmp) ) ) ) , TMPVS1->( &( FieldName(nColCmp) ) ) )
	
			EndIf
	
		EndIf
		
	Next      
	
	MsUnlock()

	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0108+" - "+STR0087 ) // Grava Data/Hora na Mudança de Status do Orçamento / Orçamento por Fases / Clonar Orçamento outra filial
	EndIf

EndIf	

cOBSMem := TMPVS1->VS1_OBSMEM

If Select("TMPVS1") > 0
	TMPVS1->(DbCloseArea())     
EndIf	
              
If !Empty(cOBSMem)

	If Select("TMPSYP") > 0
		TMPSYP->(DbCloseArea())     
	EndIf	

	cQuery := " SELECT * "
	cQuery += " From " + RetSqlName( "SYP" ) + " SYP "
	cQuery += " WHERE SYP.YP_FILIAL = '"+xFilial("SYP")+"' And SYP.D_E_L_E_T_= ' ' "
	cQuery += "       AND SYP.YP_CHAVE = '"+cOBSMem+"' "
	
	TCQUERY cQuery NEW ALIAS "TMPSYP"
	
	If !Empty( TMPSYP->YP_CHAVE )

		cChaveNova := GetSX8Num("SYP","YP_CHAVE")
		ConfirmSX8()
	                  
		DbSelectArea("VS1")
		RecLock("VS1", .F. )
		VS1->VS1_OBSMEM := cChaveNova
		MsUnlock()

		Do While !TMPSYP->( Eof() )
	
			DbSelectArea("SYP")
			RecLock("SYP", .T. )
					
			For nColCmp := 1 to TMPSYP->(FCount())
			    
				If !( TMPSYP->( FieldName(nColCmp) ) $ "YP_FILIAL/D_E_L_E_T_/R_E_C_N_O_/R_E_C_D_E_L_" )
			      
					SYP->YP_FILIAL := xFilial("SYP")
			
					If ( TMPSYP->( FieldName(nColCmp) ) $ "YP_CHAVE" )
			
						SYP->YP_CHAVE := cChaveNova
			
			      Else                               
			      
				      SYP->( &( TMPSYP->(FieldName(nColCmp)) ) ) := If( ValType(SYP->( &( TMPSYP->(FieldName(nColCmp)) ) )) == "D", Stod( TMPSYP->( &( FieldName(nColCmp) ) ) ) , TMPSYP->( &( FieldName(nColCmp) ) ) )
			
					EndIf
			
				EndIf
				
			Next      
			
			MsUnlock()
	                                       
			DbSelectArea("TMPSYP")
		   DbSkip()
	
		EndDo
	
	EndIf	
	
	If Select("TMPSYP") > 0
		TMPSYP->(DbCloseArea())     
	EndIf	

EndIf	
      

If Select("TMPVS3") > 0
	TMPVS3->(DbCloseArea())     
EndIf	
                  
cQuery := " SELECT * "
cQuery += " From " + RetSqlName( "VS3" ) + " VS3 "
cQuery += " WHERE VS3.VS3_FILIAL = '"+cFilOriOrc+"' And VS3.D_E_L_E_T_= ' ' "
cQuery += "       AND VS3.VS3_NUMORC = '"+cNumOrc+"' "

TCQUERY cQuery NEW ALIAS "TMPVS3"

If !Empty( TMPVS3->VS3_NUMORC )
                   
	Do While !TMPVS3->( Eof() )

		DbSelectArea("VS3")
		RecLock("VS3", .T. )
				
		For nColCmp := 1 to TMPVS3->(FCount())
		    
			If !( TMPVS3->( FieldName(nColCmp) ) $ "VS3_FILIAL/D_E_L_E_T_/R_E_C_N_O_/R_E_C_D_E_L_" )
		      
				VS3->VS3_FILIAL := xFilial("VS3")
		
				If ( TMPVS3->( FieldName(nColCmp) ) $ "VS3_NUMORC" )
		
					VS3->VS3_NUMORC := cOrcClone
		
		      Else                               
		      
			      VS3->( &( TMPVS3->(FieldName(nColCmp)) ) ) := If( ValType(VS3->( &( TMPVS3->(FieldName(nColCmp)) ) )) == "D", Stod( TMPVS3->( &( FieldName(nColCmp) ) ) ) , TMPVS3->( &( FieldName(nColCmp) ) ) )
		
				EndIf
		
			EndIf
			
		Next      
		
		MsUnlock()
        
		DbSelectArea("TMPVS3")
	   DbSkip()

	EndDo
                                       
EndIf	

If Select("TMPVS3") > 0
	TMPVS3->(DbCloseArea())     
EndIf	


If Select("TMPVS4") > 0
	TMPVS4->(DbCloseArea())     
EndIf	
                  
cQuery := " SELECT * "
cQuery += " From " + RetSqlName( "VS4" ) + " VS4 "
cQuery += " WHERE VS4.VS4_FILIAL = '"+cFilOriOrc+"' And VS4.D_E_L_E_T_= ' ' "
cQuery += "       AND VS4.VS4_NUMORC = '"+cNumOrc+"' "

TCQUERY cQuery NEW ALIAS "TMPVS4"

If !Empty( TMPVS4->VS4_NUMORC )
                   
	Do While !TMPVS4->( Eof() )

		DbSelectArea("VS4")
		RecLock("VS4", .T. )
				
		For nColCmp := 1 to TMPVS4->(FCount())
		    
			If !( TMPVS4->( FieldName(nColCmp) ) $ "VS4_FILIAL/D_E_L_E_T_/R_E_C_N_O_/R_E_C_D_E_L_" )
		      
				VS4->VS4_FILIAL := xFilial("VS4")
		
				If ( TMPVS4->( FieldName(nColCmp) ) $ "VS4_NUMORC" )
		
					VS4->VS4_NUMORC := cOrcClone
		
		      Else                               
		      
			      VS4->( &( TMPVS4->(FieldName(nColCmp)) ) ) := If( ValType(VS4->( &( TMPVS4->(FieldName(nColCmp)) ) )) == "D", Stod( TMPVS4->( &( FieldName(nColCmp) ) ) ) , TMPVS4->( &( FieldName(nColCmp) ) ) )
		
				EndIf
		
			EndIf
			
		Next      
		
		MsUnlock()
        
		DbSelectArea("TMPVS4")
	   DbSkip()

	EndDo
                                       
EndIf	

If Select("TMPVS4") > 0
	TMPVS4->(DbCloseArea())     
EndIf	
      

If Select("TMPVST") > 0
	TMPVST->(DbCloseArea())     
EndIf	
                  
cQuery := " SELECT * "
cQuery += " From " + RetSqlName( "VST" ) + " VST "
cQuery += " WHERE VST.VST_FILIAL = '"+cFilOriOrc+"' And VST.D_E_L_E_T_= ' ' "
cQuery += "       AND VST.VST_CODIGO = '"+cNumOrc+"' "

TCQUERY cQuery NEW ALIAS "TMPVST"

If !Empty( TMPVST->VST_CODIGO )
                   
	Do While !TMPVST->( Eof() )

		DbSelectArea("VST")
		RecLock("VST", .T. )
				
		For nColCmp := 1 to TMPVST->(FCount())
		    
			If !( TMPVST->( FieldName(nColCmp) ) $ "VST_FILIAL/D_E_L_E_T_/R_E_C_N_O_/R_E_C_D_E_L_" )
		      
				VST->VST_FILIAL := xFilial("VST")
		
				If ( TMPVST->( FieldName(nColCmp) ) $ "VST_CODIGO" )
		
					VST->VST_CODIGO := cOrcClone
		
		      Else                               
		      
			      VST->( &( TMPVST->(FieldName(nColCmp)) ) ) := If( ValType(VST->( &( TMPVST->(FieldName(nColCmp)) ) )) == "D", Stod( TMPVST->( &( FieldName(nColCmp) ) ) ) , TMPVST->( &( FieldName(nColCmp) ) ) )
		
				EndIf
		
			EndIf
			
		Next      
		
		MsUnlock()
        
		DbSelectArea("TMPVST")
	   DbSkip()

	EndDo
                                       
EndIf	

If Select("TMPVST") > 0
	TMPVST->(DbCloseArea())     
EndIf	

End Transaction

DbSelectArea("VS1")

Return( cOrcClone )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Microsiga           º Data ³  23/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pergunte para clonagem a partir da OS/Orc outra filial     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

DbSelectArea("SX1")
DbSetOrder(1)

cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
      
If Alltrim(cPerg) == "OX011OSCL"  && Importa OS

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01",STR0081,"","","mv_ch1","C",TamSX3("VO1_NUMOSV")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","VO1",""})
	AADD(aRegs,{cPerg,"02",STR0082,"","","mv_ch2","C",TamSX3("VOI_TIPTEM")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","VOI",""})
	AADD(aRegs,{cPerg,"03",STR0083,"","","mv_ch3","C",TamSX3("VOI_TIPTEM")[1],0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","VOI",""})

ElseIf Alltrim(cPerg) == "OX011OUCL" && Clona orcamento de outra filial
     
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01",STR0084      ,,,"mv_ch1","C",TamSX3("VS1_FILIAL")[1],0,,"G",,"mv_par01",,,,,,,,,,,,,,,,,,,,,,,,,"SM0",})
	aAdd(aRegs,{cPerg,"02",STR0085      ,,,"mv_ch2","C",TamSX3("VS1_NUMORC")[1],0,,"G",,"mv_par02",,,,,,,,,,,,,,,,,,,,,,,,,"VS1FI1",})
	
EndIf
	
For i:=1 to Len(aRegs)
	lSk := dbSeek(cPerg+aRegs[i,2])
	RecLock("SX1",!lSk)
	For j:=1 to FCount()
		If j <= Len(aRegs[i]) .And. aRegs[i,j] # NIL
			&(FieldName(j)) := aRegs[i,j]
		Endif
	Next
	MsUnlock()
Next

DbSelectArea(_sAlias)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIXA011  ºAutor  ³Microsiga           º Data ³  08/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA011F3()

Local cSalvaFIl := cFilAnt

cFilAnt := MV_PAR01

ConPad1(,,,"VS1FIL")

cFilAnt := cSalvaFIl

Return(.t.)


/*/{Protheus.doc} OXAGERFIN
Funcao responsavel por Chamar a Geração do Financeiro
@author Manoel
@since 29/11/2017
@version 1.0
/*/
Function OXAGERFIN(_cOrcOrcT,_cNota,_cSerie)
Local cQuery      := ""
Local cAliasVS1   := "SQLVS1"
Local aOrcs       := {}
//
DbSelectArea("SE4")
DbSetOrder(1)
If DbSeek(xFilial("SE4")+VS1->VS1_FORPAG)
	If VS1->VS1_STATUS == "X" .and. VS1->VS1_GERFIN == "0" .and. SE4->E4_TIPO == "A"
		cQuery := "SELECT VS1.VS1_NUMORC "
		cQuery += "FROM "
		cQuery += RetSqlName( "VS1" ) + " VS1 " 
		cQuery += "WHERE " 
		cQuery += "VS1.VS1_FILIAL = '"+xFilial("VS1") +"' AND "
		cQuery += "VS1.VS1_NUMNFI = '"+VS1->VS1_NUMNFI+"' AND "
		cQuery += "VS1.VS1_SERNFI = '"+VS1->VS1_SERNFI+"' AND "
		cQuery += "VS1.D_E_L_E_T_=' '"		
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS1, .T., .T. )
		Do While !( cAliasVS1 )->( Eof() )  
			aAdd(aOrcs,( cAliasVS1 )->VS1_NUMORC )
			( cAliasVS1 )->(dbSkip())
		Enddo
		( cAliasVS1 )->( dbCloseArea() )
		DbSelectArea("VS1")
		OFIXX004("VS1",4,aOrcs, , .t.) // Chama OFIXX004 apenas para Gerar Financeiro
	Else
		MsgInfo(STR0098,STR0018) // Este orçamento já possui financeiro gerado corretamente. Não é preciso executar esta funcionalidade!
	Endif
Endif
//
Return

/*/{Protheus.doc} OXA0110011_LiberaOrcamentoOficina
Funcao Libera Orcamento Oficina - Clona Itens com Saldo em Estoque
@author Andre Luis Almeida
@since 23/07/2018
/*/
Function OXA0110011_LiberaOrcamentoOficina(cAlias,nReg,nOpc)
Local nRecVS1Ori := VS1->(RecNo())
Local lPediVenda := .t.
Local lLibPV     := .t.
Local lRet       := .f.
Local cQuery     := ""
dbSelectArea("VS1")
If VS1->VS1_TIPORC <> "2" .or. VS1->VS1_STATUS <> "0"
	MsgStop(STR0100,STR0018) // Esta funcionalidade está disponível apenas para Orçamento do Tipo Oficina com Status Digitado. / Atencao
	Return
EndIf
cQuery := "SELECT SUM(COALESCE(VS3_QTDAGU,0))"
cQuery += "  FROM " + RetSQLName("VS3")
cQuery += " WHERE VS3_FILIAL = '" + xFilial("VS3") + "'"
cQuery += "   AND VS3_NUMORC = '" + VS1->VS1_NUMORC + "'"
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0
	MSGINFO(STR0101,STR0018) // Não é possível liberar um Orçamento que esteja aguardando peças para suprir o mesmo. / Atencao
	return .F.
EndIf
If OXA011CLO( "VS1" , 0 , 6 , lPediVenda , lLibPv , "O" )
	dbSelectArea("VS1")
	lRet := OXA012AX(,,,.f.) // .f. nao atualizar o VS1_TIPORC
	If lRet
		dbSelectArea("VS1")
		DbGoto(nRecVS1Ori)
		lRet := OXA012AX(,,,.f.) // .f. nao atualizar o VS1_TIPORC
	EndIf
	If lRet
		MsgInfo(STR0102,STR0018) // Operação realizada com sucesso. / Atencao
	Else
		MsgInfo(STR0103,STR0018) // Erro na liberação do Orçamento. / Atencao
	EndIf
EndIf
Return

/*/{Protheus.doc} OXA0110021_AguardarOutroOrcamento
Aguardar outro Orcamento
@author Andre Luis Almeida
@since 15/06/2022
/*/
Function OXA0110021_AguardarOutroOrcamento()
Do Case
	Case VS1->VS1_TIPORC == "1" .and. VS1->VS1_STATUS == "F" // Orçamento tipo Balcão com status Liberado para Faturamento
		If MsgYesNo(STR0129,STR0018) // Deseja deixar esse Orçamento aguardando por outro? / Atencao
			OI001ATU(VS1->VS1_NUMORC , "G" ) // G - Aguardando outro Orçamento
		EndIf
	Case VS1->VS1_TIPORC == "1" .and. VS1->VS1_STATUS == "G" // Orçamento tipo Balcão com status Aguardando outro Orçamento
		If MsgYesNo(STR0130,STR0018) // Este Orçamento esta aguardando por outro. Deseja voltar o Status para 'Liberado para Faturamento'? / Atencao
			OI001ATU(VS1->VS1_NUMORC , "F" ) // F - Liberado para Faturamento
		EndIf
	OtherWise
		MsgStop(STR0128,STR0018) // Opção disponivel apenas para Orçamento Balcão Liberado para Faturamento. / Atencao
EndCase
Return