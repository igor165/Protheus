#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "rwmake.ch"
#Include "TOPCONN.CH"
#Include "VEIFUNB.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_ABREOSVº Autor ³ Luis / Andre Luis Almeida º Data ³ 19/08/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Abre Ordem de Servico apenas.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ Nro da NOVA OS                                                 º±±
±±º         ³ Vazio ("") caso ocorra algum erro                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_ABREOSV( _aCodErro , _cFilial , _cChaInt , _nKilomet , _cCodCli , _cLojCli , _cOBSMem, _dDatEnt, _nHorTri, _lConfirmSX)

Local aArea   := {}
Local nUltKil := 0
Local cRet    := ""
Default _cFilial  := xFilial("VO1")
Default _cCodCli  := NIL
Default _cLojCli  := NIL
Default _cOBSMem  := ""
Default _aCodErro := {}
Default _dDatEnt := Ctod("")
Default _nHorTri := 0
Default _lConfirmSX := .T.
If len(_aCodErro) <= 0
	Aadd(_aCodErro,"")  // 1 - Nome da Funcao que ocorreu o Erro
	Aadd(_aCodErro,"")  // 2 - Mensagem referente ao Erro
EndIf
// -----------------------------------------
// ARMAZENA AREAS PARA RESTAURACAO POSTERIOR
// -----------------------------------------
aArea := sGetArea(aArea,"VV1")
aArea := sGetArea(aArea,"SA1")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VAI")
aArea := sGetArea(aArea,"SYP")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf
// -----------------------------------------
// posiciona no veiculo
DbSelectArea("VV1")
DbSetOrder(1) // VV1_FILIAL+VV1_CHAINT
If !(DbSeek(xFilial("VV1")+_cChaint))
	_aCodErro[1] := "FM_ABREOSV"
	_aCodErro[2] := STR0001+" "+_cChaint //Veiculo nao encontrado!
	sRestArea(aArea)
	Return "" // ERRO: VEICULO NAO ENCONTRADO
EndIf
// caso nao seja passado codigo de cliente, utiliza o proprietario do veiculo
If _cCodCli == NIL .and. _cLojCli== NIL
	_cCodCli := VV1->VV1_PROATU
	_cLojCli := VV1->VV1_LJPATU
EndIf
// posiciona no cadastro de clientes
DbSelectArea("SA1")
DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
If !(DbSeek(xFilial("SA1")+_cCodCli+_cLojCli))
	_aCodErro[1] := "FM_ABREOSV"
	_aCodErro[2] := STR0002+" "+_cCodCli+"-"+_cLojCli //Cliente/Loja nao encontrado!
	sRestArea(aArea)
	Return "" // ERRO: CLIENTE NAO ENCONTRADO
EndIf
// verifica kilometragem
cValKil := Left(GetNewPar("MV_VKILHOR","SN"),1)
if cValKil == "S" .or. (cValKil == "P" .and. _nKilomet != 0)
	nUltKil := FG_ULTKIL(_cChaint)
	If nUltKil > _nKilomet
		_aCodErro[1] := "FM_ABREOSV"
		_aCodErro[2] := STR0003+" ("+Transform(_nKilomet,"@E 999,999,999")+" ) "+STR0004+" ("+Transform(nUltKil,"@E 999,999,999")+" )!" //KM/hora informada # menor que da OS anterior
		sRestArea(aArea)
		Return "" // ERRO: KILOMETRAGEM MENOR
	EndIf
endif
// verifica horas de trilha
cValHor := Subs(GetNewPar("MV_VKILHOR","SN"),2,1)
if VO1->(FieldPos("VO1_HORTRI")) > 0
	if cValHor == "S" .or. (cValHor == "P" .and. _nHorTri != 0)
		nUltHor := FG_ULTHOR(_cChaint)
		If nUltHor > _nHorTri
			_aCodErro[1] := "FM_ABREOSV"
			_aCodErro[2] := STR0003+" ("+Transform(_nHorTri,"@E 999,999,999")+" ) "+STR0004+" ("+Transform(nUltHor,"@E 999,999,999")+" )!" //KM/hora informada # menor que da OS anterior
			sRestArea(aArea)
			Return "" // ERRO: KILOMETRAGEM MENOR
		EndIf
	endif
endif
// verifica usuario
DbSelectArea("VAI")
DbSetOrder(4) // VAI_FILIAL+VAI_CODUSR
If !(DbSeek(xFilial("VAI")+__cUserID))
	_aCodErro[1] := "FM_ABREOSV"
	_aCodErro[2] := STR0005+" "+__cUserID //Funcionario informado nao encontrado no cadastro da Equipe Tecnica!
	sRestArea(aArea)
	Return "" // ERRO: FUNCIONARIO NAO ENCONTRADO NO <VAI>
EndIf
// verifica observacao
if !Empty(_cOBSMem)
	DBSelectArea("SYP")
	DBSetOrder(1) // YP_FILIAL+YP_CHAVE+YP_SEQ
	if !(DBSeek(xFilial("SYP")+_cOBSMem))
		_aCodErro[1] := "FM_ABREOSV"
		_aCodErro[2] := STR0006+" "+_cOBSMem //Observacao informada nao encontrada!
		sRestArea(aArea)
		Return "" // ERRO: OBSERVACAO NAO ENCONTRADA NO <SYP>
	endif
endif
// Valida Cliente
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + _cCodCli + _cLojCli )
aImpFatPar := {_cCodCli,_cLojCli,SA1->A1_NOME,""}
// GRAVA VO1
DbSelectArea("VO1")
RecLock("VO1",.t.)
VO1->VO1_FILIAL := _cFilial
VO1->VO1_NUMOSV := GetSXENum("VO1","VO1_NUMOSV")
VO1->VO1_CODMAR := VV1->VV1_CODMAR
VO1->VO1_CHASSI := VV1->VV1_CHASSI
VO1->VO1_PLAVEI := VV1->VV1_PLAVEI
VO1->VO1_CODFRO := VV1->VV1_CODFRO
VO1->VO1_CHAINT := VV1->VV1_CHAINT
if VO1->(FieldPos("VO1_FABMOD")) > 0
	VO1->VO1_FABMOD := VV1->VV1_FABMOD
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 30/10/2009                    ³
//³Sempre gravar o proprietario do veiculo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VO1->VO1_PROVEI := VV1->VV1_PROATU
VO1->VO1_LOJPRO := VV1->VV1_LJPATU
VO1->VO1_DATABE := DDATABASE
VO1->VO1_KILOME := _nKilomet
if VO1->(FieldPos("VO1_HORTRI")) > 0
	VO1->VO1_HORTRI := _nHorTri
Endif
VO1->VO1_HORABE := Val(Substr( Time(),1,2)+Substr( Time(),4,2))
VO1->VO1_FUNABE := VAI->VAI_CODTEC
VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV,"A")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 30/10/2009                                                                           ³
//³Se o Cliente selecionado para Faturar for dif. do proprietario, gravar como faturar para da OS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _cCodCli <> VV1->VV1_PROATU .or. _cLojCli <> VV1->VV1_LJPATU
	VO1->VO1_FATPAR := _cCodCli
	VO1->VO1_LOJA   := _cLojCli
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Manoel - 16/04/2010                   								 ³
//³FNC 8251 - Gravar VO1_DATENT quando VS1_DATENT for informada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VO1->VO1_DATENT := _dDatEnt
VO1->VO1_FRANQU := VS1->VS1_FRANQU
If VO1->(FieldPos("VO1_TPATEN")) <> 0
	VO1->VO1_TPATEN := VS1->VS1_TPATEN
Endif
if VO1->(FieldPos("VO1_FRANQP")) > 0
	VO1->VO1_FRANQP := VS1->VS1_FRANQP
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Manoel - 21/06/2010                   								 ³
//³FNC      - Gravar VO1_OBSERV acumulando OBS's de varios Orcs³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !Empty(VS1->VS1_OBSMEM)
	M->VO1_OBSERV := MSMM(VS1->VS1_OBSMEM,TamSx3("VS1_OBSERV")[1])
	MSMM(VO1->VO1_OBSMEM,TamSx3("VO1_OBSERV")[1],,M->VO1_OBSERV,1,,,"VO1","VO1_OBSMEM")
endif

MsUnLock()
//If _lConfirmSX
ConfirmSX8()
//EndIf

// retorno por referencia
cRet := VO1->VO1_NUMOSV

dbSelectArea("VA8")
dbSetOrder(1)
if dbSeek(xFilial("VA8")+space(Len(VO1->VO1_NUMOSV))+VO1->VO1_PLAVEI)
	dbSelectArea("VA8")
	Reclock("VA8",.f.)
	VA8->VA8_NUMOSV := VO1->VO1_NUMOSV
	MsUnlock()
Endif
If VSR->(FieldPos("VSR_PLAVEI")) # 0
	dbSelectArea("VSR")
	dbSetOrder(2)
	if dbSeek(xFilial("VSR")+space(Len(VO1->VO1_NUMOSV))+VO1->VO1_PLAVEI)
		dbSelectArea("VSR")
		Reclock("VSR",.f.)
		VSR->VSR_NUMOSV := VO1->VO1_NUMOSV
		MsUnlock()
	Endif
Endif
// -------------------------------------------------------------------
// PE para gravar novos campos ou manipular o VO1 criado anteriormente
// -------------------------------------------------------------------
If ExistBlock("FMABREOS")
	ExecBlock("FMABREOS",.f.,.f.)
EndIf
// --------------------------
// RESTAURA POSICOES INICIAIS
// --------------------------
sRestArea(aArea)
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_IMPVST º Autor ³ Rubens Takahashi          º Data ³ 15/01/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Exporta Inconvenientes do Orcamento para a OS                  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_IMPVST( _aCodErro, _cNumOrc , _cNumOSV )
Local cQuery
Local cSQLINC := "TSQLINC"
Local lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
if !lInconveniente
	Return
endif

cQuery := "SELECT VST_SEQINC "
cQuery +=  " FROM " + RetSQLName("VST")
cQuery += " WHERE VST_FILIAL = '" + xFilial("VST") + "'"
cQuery +=   " AND VST_TIPO = '1'" // Inconvenientes de Orcamento
cQuery +=   " AND VST_CODIGO = '" + _cNumOrc + "' AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VST_SEQINC"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLINC , .F., .T. )
(cSQLINC)->(DbgoTop())
Do while !(cSQLINC)->(Eof())
	// Exporta Incoveniente
	OM420IMPINC( "1" , _cNumOrc , (cSQLINC)->VST_SEQINC , "2" , _cNumOSV )

	(cSQLINC)->(DbSkip())
End
(cSQLINC)->(DbCloseArea())
dbSelectArea("VST")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_IMPVO4 º Autor ³ Luis / Andre Luis Almeida º Data ³ 20/08/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Importa VO4 SERVICOS para OS a partir do Orcamento             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_IMPVO4( _aCodErro, _cNumOrc , _cNumOSV , _aSrvcAdic , _lImportar , _aRetSrv, _lConfirmSX)

Local nImp, nCol
Local aArea   := {}
Local aSrv := {}
Local aInconv
Local aPE := {}  // vetor que recebe retorno do PE FMIMPORC (utilizado para manipulacao do aSrv)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
//³Rubens - 18/11/2009                                          ³
//³Verifica se esta habilitado para trabalhar com Inconveniente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
Local lInconveniente := (GetNewPar("MV_INCORC","N") == "S")

Local dDtReq := dDataBase
Local lVOIVLSVAC := (VOI->(FieldPos("VOI_VLSVAC")) <> 0)

Default _aCodErro := {}
Default _aSrvcAdic := {}
Default _lImportar := .t.	// Indica se deve importar os servicos
Default _aRetSrv := {}		// Matriz com os servicos que serao importados (so é populada quando _lImportar == .f. )
Default _lConfirmSX := .T.

If len(_aCodErro) <= 0
	Aadd(_aCodErro,"")  // 1 - Nome da Funcao que ocorreu o Erro
	Aadd(_aCodErro,"")  // 2 - Mensagem referente ao Erro
EndIf
//
aArea := sGetArea(aArea,"VS1")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VO4")
aArea := sGetArea(aArea,"VAI")
aArea := sGetArea(aArea,"VOI")
aArea := sGetArea(aArea,"VS4")
aArea := sGetArea(aArea,"VO6")
aArea := sGetArea(aArea,"VV1")
aArea := sGetArea(aArea,"VV2")
aArea := sGetArea(aArea,"SA1")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf
DbSelectArea("VS1")
DbSetOrder(1)
if !(DBSeek(xFilial("VS1")+ _cNumOrc))
	_aCodErro[1] := "FM_IMPVO4"
	_aCodErro[2] := STR0007+" "+_cNumOrc //Orcamento nao encontrado!
	sRestArea(aArea)
	Return ""
endif
cTipTem := IIf(FieldPos("VS1_TIPTSV")>0.and.!Empty(VS1_TIPTSV),VS1->VS1_TIPTSV,VS1->VS1_TIPTEM)
//
DbSelectArea("VO1")
DbSetOrder(1)
if !(DBSeek(xFilial("VO1")+ _cNumOSV))
	_aCodErro[1] := "FM_IMPVO4"
	_aCodErro[2] := STR0008+" "+_cNumOSV //Ordem de Servico nao encontrada!
	sRestArea(aArea)
	Return ""
endif
//
DbSelectArea("VAI")
DbSetOrder(4) // VAI_FILIAL+VAI_CODUSR
If !(DbSeek(xFilial("VAI")+__cUserID))
	_aCodErro[1] := "FM_IMPVO4"
	_aCodErro[2] := STR0005+"!"+" "+__cUserID //Funcionario informado nao encontrado no cadastro da Equipe Tecnica
	sRestArea(aArea)
	Return ""
EndIf
//
////////////////////////////////////////////////////////////////
// Manoel - 02/08/2012
// Chamado 001269 - Serviços de Diagnóstico
// Verifica se existe Serviços de Diagnósticos apontados na OS
// e adiciona no Vetor de Diagnósticos
////////////////////////////////////////////////////////////////
//
// So relaciona quando é realmente para Exportar o Orçamento
aVetDefi := {}
aVetDiag := {}
If _lImportar
	If VO6->(FieldPos("VO6_DIAGNO")) <> 0
		FS_VERDIAG(_cNumOsv)
	Endif
Endif
//
DBSelectArea("VOI")
DbSetOrder(1)
DbSeek( xFilial("VOI") + cTipTem )
//
DbSelectArea("VS4")
DbSetOrder(1)
DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
//
lVS4CodSec := (VS4->(FieldPos("VS4_CODSEC")) > 0)
//
Do While !Eof() .And. VS4->VS4_FILIAL == xFilial("VS4") .And. VS4->VS4_NUMORC == VS1->VS1_NUMORC

	If Len(aVetDiag) > 0
		nPos := aScan(aVetDefi,{|x| x[3]+x[4] == VS4->VS4_GRUSER+VS4->VS4_CODSER } )
		If nPos > 0 .and. !Empty(aVetDefi[nPos,6])
			DbSelectArea("VS4")
			DbSkip()
			Loop
		Endif
	Endif

	DbSelectArea("VO6")
	DbSetOrder(2)
	DbSeek(xFilial("VO6")+FG_MARSRV(VS1->VS1_CODMAR,VS4->VS4_CODSER) + VS4->VS4_CODSER )

	if VS4->(FieldPos("VS4_CODFOR"))>0
		Aadd( aSrv , { cTipTem , ;// 1
		VS1->VS1_CLIFAT , ;	// 2
		VS1->VS1_LOJA ,   ;	// 3
		VS4->VS4_GRUSER , ;	// 4
		VS4->VS4_CODSER , ;	// 5
		VS4->VS4_TIPSER , ;	// 6
		VS4->VS4_TEMPAD , ;	// 7
		VOI->VOI_CODTES , ;	// 8
		VS4->VS4_KILROD , ;	// 9
		IIF(lVS4CodSec,VS4->VS4_CODSEC ,""), ;// 10
		VS4->VS4_VALTOT , ;	// 11
		VS4->VS4_TEMPAD , ;	// 12
		VO6->VO6_SERINT , ;	// 13
		VS4->VS4_VALHOR , ;	// 14
		"", ;			   // 15 - Sequencia Inconveniente - VST
		VS1->VS1_NUMORC, ; // 16 - Numero do Orcamento
		IIF(VO7->(FieldPos("VO7_SEQSER"))>0,VS4->VS4_SEQSER,"") ,; // 17
		VS4->VS4_VALDES,;   // 18 - Valor do Desconto
		VS4->VS4_PERDES,;   // 19 - Percentual de Desconto
		VS4->VS4_VALSER,;   // 20 - Valor Fixo de Servico
		VS4->VS4_CODFOR,;
		VS4->VS4_FOLOJA,;
		VS4->VS4_NUMTIT,;
		VS4->VS4_TIPTIT,;
		VS4->VS4_NATURE,;
		VS4->VS4_CODPAG,;
		VS4->VS4_VALCUS,;
		VS4->VS4_VALVEN,;
		VS4->VS4_DATPAG,;
		VS4->VS4_DEPGAR,;
		VS4->VS4_DEPINT,;
		VS4->VS4_OBSMEM } )
	else
		Aadd( aSrv , { cTipTem , ;// 1
		VS1->VS1_CLIFAT , ;	// 2
		VS1->VS1_LOJA ,   ;	// 3
		VS4->VS4_GRUSER , ;	// 4
		VS4->VS4_CODSER , ;	// 5
		VS4->VS4_TIPSER , ;	// 6
		VS4->VS4_TEMPAD , ;	// 7
		VOI->VOI_CODTES , ;	// 8
		VS4->VS4_KILROD , ;	// 9
		IIF(lVS4CodSec,VS4->VS4_CODSEC ,""), ;// 10
		VS4->VS4_VALTOT , ;	// 11
		VS4->VS4_TEMPAD , ;	// 12
		VO6->VO6_SERINT , ;	// 13
		VS4->VS4_VALHOR , ;	// 14
		"", ;			   // 15 - Sequencia Inconveniente - VST
		VS1->VS1_NUMORC, ; // 16 - Numero do Orcamento
		IIF(VO7->(FieldPos("VO7_SEQSER"))>0,VS4->VS4_SEQSER,"") ,; // 17
		VS4->VS4_VALDES,;   // 18 - Valor do Desconto
		VS4->VS4_PERDES,;   // 19 - Percentual de Desconto
		VS4->VS4_VALSER,;   // 20 - Valor Fixo de Servico
		VS4->VS4_DEPGAR,;   // 21 - Departamento Garantia
		VS4->VS4_DEPINT,;   // 22 - Departamento Interno
		VS4->VS4_OBSMEM } ) // 23 - Observacao
	endif

	// Se Utiliza Inconveniente e foi informado no orcamento ...
	IF lInconveniente .and. !Empty(VS4->VS4_SEQINC)

		// Procura informacao do inconveniente do orcamento
		aInconv := OM420CONSINC( "1" , VS1->VS1_NUMORC , VS4->VS4_SEQINC )

		// Procura informacao do inconveniente da OS
		if !Empty(aInconv[1]) .and. !Empty(aInconv[2])
			aSrv[Len(aSrv),15] := OM420CONSINC( "2" , _cNumOSV , , aInconv[1] , aInconv[2])[4]
		else
			aSrv[Len(aSrv),15] := OM420CONSINC( "2" , _cNumOSV , , , , aInconv[3] )[4]
		endif

	ENDIF

	DbSelectArea("VS4")
	DbSkip()
EndDo
//
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + VS1->VS1_CLIFAT + VS1->VS1_LOJA )
//aImpFatPar := {VS1->VS1_CLIFAT,VS1->VS1_LOJA,SA1->A1_NOME,""}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 03/11/2009                                  ³
//³Gravar o Cliente para Faturamento da Ordem de Servico³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If !FM_FATTTPO( VO1->VO1_NUMOSV , VS1->VS1_TIPTEM , "aImpFatPar[1]" , "aImpFatPar[2]" , "aImpFatPar[3]" , "aImpFatPar[4]" , "S" )
//	_aCodErro[1] := "FM_FATTTPO"
//	_aCodErro[2] := "Problema na determinacao do cliente para faturamento."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aImpFatPar[4]
//	sRestArea(aArea)
//	Return ""
//EndIf
//If !Empty(aImpFatPar[1])
//	For nImp := 1 To Len(aSrv)
//		aSrv[nImp,2] := aImpFatPar[1]
//		aSrv[nImp,3] := aImpFatPar[2]
//	Next
//endif

// Inclui na Matriz os Servicos Adicionais
if Len(_aSrvcAdic) > 0
	For nImp := 1 to Len(_aSrvcAdic)
		AADD( aSrv, Array(Len(_aSrvcAdic[nImp])) )

		For nCol := 1 to Len(_aSrvcAdic[nImp])
			aSrv[Len(aSrv),nCol] := _aSrvcAdic[nImp,nCol]
		Next nCon

		// Se Utiliza Inconveniente e foi informado no orcamento ...
		IF lInconveniente .and. !Empty(_aSrvcAdic[nImp,15])

			// Procura informacao do inconveniente do orcamento
			aInconv := OM420CONSINC( "1" , VS1->VS1_NUMORC , _aSrvcAdic[nImp,15] )

			// Procura informacao do inconveniente da OS
			if !Empty(aInconv[1]) .and. !Empty(aInconv[2])
				aSrv[Len(aSrv),15] := OM420CONSINC( "2" , _cNumOSV , , aInconv[1] , aInconv[2])[4]
			else
				aSrv[Len(aSrv),15] := OM420CONSINC( "2" , _cNumOSV , , , , aInconv[3] )[4]
			endif

		ENDIF
		//

	Next nImp
endif
//
//
// PE para manipulacao do vetor que importa Servicos do Orcamento para VO4
If ExistBlock("FMIMPORC")
	aPE := ExecBlock("FMIMPORC",.f.,.f.,{aSrv})
	If ValType(aPE) == "A"
		aSrv := aClone(aPE)
	Endif
Endif
//
// Nao importa, somente usado para retorno da Matriz aSrv e validacoes no Orcamento ...
If !_lImportar
	_aRetSrv := aClone(aSrv)
	sRestArea(aArea)
	Return ""
EndIf
//
DbSelectArea("VO2")
DbSetOrder(1)
nSequen := -1
if !(DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV + "S" ))
	reclock("VO2",.t.)
	VO2->VO2_FILIAL := xFilial("VO2")
	VO2->VO2_NUMOSV := VO1->VO1_NUMOSV
	VO2->VO2_NOSNUM := GetSxeNum("VO2","VO2_NOSNUM",,2)
	VO2->VO2_DATREQ := DDATABASE
	VO2->VO2_HORREQ := Val(Substr( Time(),1,2)+Substr( Time(),4,2))
	VO2->VO2_FUNREQ := VAI->VAI_CODTEC
	VO2->VO2_TIPREQ := "S"
	
	If VO2->(FieldPos("VO2_DATALT")) > 0
		VO2->VO2_DATALT := DDATABASE
	EndIf
	
	MsUnLock()
	If(_lConfirmSX)
		ConfirmSX8()
	EndIf
else
	DBSelectArea("VO4")
	DBSetOrder(8)
	DBSeek(xFilial("VO4")+VO2->VO2_NOSNUM)
	while !eof() .and. VO4->VO4_FILIAL+VO4->VO4_NOSNUM == xFilial("VO4")+VO2->VO2_NOSNUM
		nSequen :=  val(VO4->VO4_SEQUEN)
		DBSkip()
	enddo
endif

IF lInconveniente
	dbSelectArea("VST")
	dbSetOrder(1)
ENDIF

VOK->(dbSetOrder(1))

DBSelectArea("VO4")
For nImp := 1 To Len(aSrv)

	VOK->(dbSeek(xFilial("VOK") + aSrv[nImp,6]))

	reclock("VO4",.t.)
	VO4->VO4_FILIAL := xFilial("VO4")
	VO4->VO4_TIPTEM := aSrv[nImp,1]
	VO4->VO4_FATPAR := aSrv[nImp,2]
	VO4->VO4_LOJA   := aSrv[nImp,3]
	VO4->VO4_GRUSER := aSrv[nImp,4]
	VO4->VO4_CODSER := aSrv[nImp,5]
	VO4->VO4_TIPSER := aSrv[nImp,6]
	VO4->VO4_TEMPAD := aSrv[nImp,7]
	VO4->VO4_CODTES := aSrv[nImp,8]
	VO4->VO4_KILROD := aSrv[nImp,9]
	VO4->VO4_CODSEC := aSrv[nImp,10]
	VO4->VO4_TEMVEN := aSrv[nImp,12]
	VO4->VO4_SERINT := aSrv[nImp,13]
	if Len(aSrv[nImp]) > 23
		VO4->VO4_CODFOR:= aSrv[nImp,21]
		VO4->VO4_FOLOJA:= aSrv[nImp,22]
		VO4->VO4_NUMTIT:= aSrv[nImp,23]
		VO4->VO4_TIPTIT:= aSrv[nImp,24]
		VO4->VO4_NATURE:= aSrv[nImp,25]
		VO4->VO4_CODPAG:= aSrv[nImp,26]
		VO4->VO4_VALCUS:= aSrv[nImp,27]
		VO4->VO4_VALVEN:= aSrv[nImp,28]
		VO4->VO4_DATPAG:= aSrv[nImp,29]
	endif

	IF VO7->(FieldPos("VO7_SEQSER")) > 0
		VO4->VO4_SEQSER := aSrv[nImp,17]
	endif
	IF VO4->(FieldPos("VO4_PERDES")) > 0 .and. VO4->(FieldPos("VO4_VALDES")) <> 0
		IF VOK->VOK_INCMOB $ "2/6" // Srv. Terceiro / Franquia
			if Len(aSrv[nImp]) > 23
				VO4->VO4_VALVEN := aSrv[nImp,28]
			else
				VO4->VO4_VALVEN := aSrv[nImp,20]
			endif
		ENDIF
		if aSrv[nImp,14] <> 0
			VO4->VO4_VALHOR := aSrv[nImp,14] // Valor de Hora
		else
			VO4->VO4_VALHOR := aSrv[nImp,20] // Valor Fixo de Servico
		endif
		VO4->VO4_VALDES := aSrv[nImp,18]
		VO4->VO4_PERDES := aSrv[nImp,19]
	Else
		IF VOK->VOK_INCMOB $ "2/6" // Srv. Terceiro / Franquia
			if Len(aSrv[nImp]) > 23
				VO4->VO4_VALVEN := aSrv[nImp,28]
			else
				VO4->VO4_VALVEN := aSrv[nImp,11]
			endif
		ENDIF
		// Rubens - 29/01/2010
		// Recalcula o valor da hora, para considerar os descontos do orcamento
		VO4->VO4_VALHOR := aSrv[nImp,11] / (aSrv[nImp,7] / 100)
	EndIf
	//
	If VOK->VOK_INCMOB == "7" // Valor Informado
		VO4->VO4_VALSER := aSrv[nImp,20]
	EndIf
	//
	VO4->VO4_NOSNUM := VO2->VO2_NOSNUM
	VO4->VO4_SEQUEN := STRZERO(nSequen+nImp,8)
	VO4->VO4_NUMOSV := VO1->VO1_NUMOSV

	If VOK->VOK_INCMOB $ "2/5/6"
		VO4->VO4_VHRDIG := "0"
	Else
		If lVOIVLSVAC
			If VOI->VOI_VLSVAC == "1"
				dDtReq := VO2->VO2_DATREQ
			ElseIf VOI->VOI_VLSVAC == "3" // Valor da Data de Abertura da OS
				dDtReq := IIf( !Empty(VO1->VO1_DATATE), VO1->VO1_DATATE , VO1->VO1_DATABE )
			EndIf
		EndIf
		if VO4->VO4_VALHOR == FMX_VALHOR(VO4->VO4_TIPTEM,dDtReq, , ,VO1->VO1_CODMAR,VO4->VO4_CODSER,VO4->VO4_TIPSER,VO4->VO4_FATPAR,VO4->VO4_LOJA, ,VV1->VV1_MODVEI,VV1->VV1_SEGMOD)
			VO4->VO4_VHRDIG := "0"
		Else
			VO4->VO4_VHRDIG := "1"
		Endif
	EndIf

	if VOI->VOI_SITTPO == "3" // Interno
		if Len(aSrv[nImp]) > 23
			VO4->VO4_DEPINT := aSrv[nImp,31]
		Else
			VO4->VO4_DEPINT := aSrv[nImp,22]
		Endif
	Elseif VOI->VOI_SITTPO $ "2/4" // Garantia
		if Len(aSrv[nImp]) > 23
			VO4->VO4_DEPGAR := aSrv[nImp,30]
		Else
			VO4->VO4_DEPGAR := aSrv[nImp,21]
		Endif
	Endif
	if Len(aSrv[nImp]) > 23
		VO4->VO4_OBSMEM := aSrv[nImp,32]
	Else
		VO4->VO4_OBSMEM := aSrv[nImp,23]
	Endif

	IF lInconveniente
		VO4->VO4_SEQINC := aSrv[nImp,15] // inconveniente
	ENDIF

	msunlock()
Next
cRet := VO2->VO2_NOSNUM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Requisicao de Franquia ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if VS1->VS1_FRANQU > 0
	REQFRA030( _cNumOSV , VS1->VS1_TIPTSV )
endif
//

sRestArea(aArea)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_IMPVSJ º Autor ³ Luis / Andre Luis / Rubensº Data ³ 20/08/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Importa VSJ PECAS para OS a partir do Orcamento                º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_IMPVSJ( aItensNImp , _cNumOrc , _cNumOSV , aItens , nOrigem, _lConfirmSX, aRecnoCriado )

Local aItensNew   := {}
Local aDisponivel := {}
Local ni          := 0
Local nItens      := 0
Local cLocPad     := ""
Local aArea 	  := {}
Local lVSJManRes  := ( nOrigem == 3 .and. GetNewPar("MV_MIL0155","0") == "1" ) // Faz reserva automatica na digitacao do VSJ Manual ? Este parametro é dependente do parametro MV_RITEORC = "S"
Local lMovtoReserva := ( ( GetNewPar("MV_RITEORC","N") == "S" ) .and. ( nOrigem <> 3 .or. lVSJManRes ) )
Local lSugCompra  := ( ( GetNewPar("MV_SUGCOS","N") == "S" ) .and. ( nOrigem <> 3 .or. lVSJManRes ) )
Local lSugAuto    := ( ( GetNewPar("MV_SUGCAU","N") == "S" ) .and. ( nOrigem <> 3 .or. lVSJManRes ) )
Local cCodSugCompra := "", nQtdeReserv := 0, aSugCom, cMsgSugCom, aConsumo, nAtual
Local aInconv
Local nCont
Local lCtrlLote   := GetNewPar("MV_RASTRO","N") == "S"
Local oPeca := DMS_Peca():New()

Local cMVRESITE := PadR( AllTrim(GetMv("MV_RESITE")), TamSX3("B2_LOCAL")[1] )
Local cMVRESLOC := PadR( AllTrim(GetMV("MV_RESLOC")), TamSX3("B5_LOCALI2")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
//³Rubens - 18/11/2009                                          ³
//³Verifica se esta habilitado para trabalhar com Inconveniente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
Local lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Local iVLP := 0

Local lVSJTIPTEM := (VSJ->(FieldPos("VSJ_TIPTEM")) <> 0)
Local lVSJCODTES := (VSJ->(FieldPos("VSJ_CODTES")) <> 0)
Local lVSJCODIGO := (VSJ->(FieldPos("VSJ_CODIGO")) <> 0)
Local lVSJSUGCOM := (VSJ->(FieldPos("VSJ_SUGCOM")) <> 0)
Local nRecVSJ    := 0
Local lNovo
Local cDocD3 := ""
Local nPosLote
Local nPosDisp

Local aItemMov  := {}
Local oEst      := DMS_Estoque():New()
Local cLocOri   := ""

Local lESTNEG  := (GetMV("MV_ESTNEG") == "S")

Local lPE_FMSGCPOF := ExistBlock("FMSGCPOF") // Ponto de Entrada que substitui a criação da Sugestão de Compra do Orçamento Oficina

Local lInfCab := .t.

Default _cNumOrc := ""
Default aItens   := {}
Default nOrigem  := 1

Private lMsErroAuto := .f.
Private lMsHelpAuto := .t.
//
Default _lConfirmSX := .T.
Default aRecnoCriado := {}
//
//aArea := sGetArea(aArea,"VSJ")
aArea := sGetArea(aArea,"VS1")
aArea := sGetArea(aArea,"VS3")
aArea := sGetArea(aArea,"VO1")
aArea := sGetArea(aArea,"SB1")
aArea := sGetArea(aArea,"SB2")
aArea := sGetArea(aArea,"SB5")
aArea := sGetArea(aArea,"SF4")
aArea := sGetArea(aArea,"SD3")
aArea := sGetArea(aArea,"SBM")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf
aItensNImp:={}
Aadd(aItensNImp , {} )  && 1 - Cabecalho do listbox
Aadd(aItensNImp , {} )  && 2 - Itens do listbox
DbSelectArea("VSJ")
For nItens := 1 to FCount()
	Aadd(aItensNImp[1] , FieldName(nItens) )
Next
Aadd(aItensNImp[1] , "B1_DESC" )
Aadd(aItensNImp[1] , "B1_LOCPAD" )

// Desabilitar a Sugestao de Compra caso MV_ESTNEG igual a S e Tem Reserva na Exportação do Orçamento para a OS
If lSugCompra .and. lMovtoReserva
	If lESTNEG
		// STR0109 - "Não é possivel a Sugestão de Compra das Peças sem saldo com os parametros MV_ESTNEG e MV_RITEORC configurados com S."
		// STR0110 - "O Sistema dará continuidade ao processo de Exportação para a Ordem de Serviço, porem a Sugestão de Compra das Peças sem saldo não será realizada."
		ShowHelpDlg ( "VEIFUNB_FM_IMPVSJ_001",	{STR0109},,{STR0110})
		lSugCompra := .f. // NAO faz Sugestao de Compra
	EndIf
EndIf

// Orcamento
If nOrigem == 1

	DbSelectArea("VS1")
	DbSetOrder(1)
	DbSeek( xFilial("VS1") + _cNumOrc )

	SF4->(dbSetOrder(1))

	DbSelectArea("VS3")
	DbSetOrder(1)
	DbSeek( xFilial("VS3") + VS1->VS1_NUMORC )
	Do While !VS3->(Eof()) .and. xFilial("VS3") == VS3->VS3_FILIAL .and. VS3->VS3_NUMORC == _cNumOrc
		If !Empty(VS3->VS3_MOTPED)
			VS3->(dbSkip())
			Loop
		EndIf

		Aadd(aItens,{VS3->VS3_GRUITE,;	// 01
			VS3->VS3_CODITE,;		// 02
			VS3->VS3_QTDITE,;		// 03
			VS3->VS3_LOCAL,;		// 04 - Almoxarifado
			" ",;					// 05 - Grupo do Inconveniente
			" ",;					// 06 - Codigo do Inconveniente
			VS1->VS1_TIPTEM,;		// 07
			VS1->VS1_CLIFAT,;		// 08
			VS1->VS1_LOJA,;			// 09
			" ",;					// 10 - Seq. do Inconveniente
			VS1->VS1_NUMORC,;		// 11 - Numero do Orcamento
			VS3->VS3_CODTES,;		// 12 - TES
			" ",;					// 13 - TES Mov. Estoque ??? (F4_ESTOQUE)
			VS3->VS3_VALPEC,;		// 14 - Valor da Peca
			VS3->VS3_DEPGAR,;		// 15 - Depto Garantia
			VS3->VS3_DEPINT,;		// 16 - Depto Interno
			VS3->VS3_LOTECT,;		// 17 - Lote
			VS3->VS3_NUMLOT,;		// 18 - Sub-Lote
			VS3->VS3_LOCALI,;		// 19 - Localização - Endereço
			"2",;					// 20 - Origem do registro
			CtoD(" "),;				// 21 - Validade do Lote
			VS3->VS3_VALDES}) 		// 22 - Valor de Desconto

		// Se Utiliza Inconveniente e foi informado no orcamento ...
		IF lInconveniente .and. !Empty(VS3->VS3_SEQINC)

			// Procura informacao do inconveniente do orcamento
			aInconv := OM420CONSINC( "1" , VS1->VS1_NUMORC , VS3->VS3_SEQINC )

			// Procura informacao do inconveniente da OS
			if !Empty(aInconv[1]) .and. !Empty(aInconv[2])
				aItens[Len(aItens),10] := OM420CONSINC( "2" , _cNumOSV , , aInconv[1] , aInconv[2])[4]
			else
				aItens[Len(aItens),10] := OM420CONSINC( "2" , _cNumOSV , , , , aInconv[3] )[4]
			endif

		ENDIF
		//

		If !Empty(VS3->VS3_CODTES) .and. SF4->(MsSeek(xFilial("SF4") + VS3->VS3_CODTES))
			aItens[Len(aItens),13] := SF4->F4_ESTOQUE
		EndIf
		VS3->(DbSkip())
	EndDo

	If Len(aItens) == 0
		sRestArea(aArea)
		return .t.
	EndIf
EndIf

DbSelectArea("VO1")
DbSetOrder(1)
DbSeek( xFilial("VO1") + _cNumOSV )

If nOrigem <> 3 .or. lVSJManRes // NAO é registro digitado manualmente ou é para fazer sugestao de compra mesmo VSJ manualmente

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PL 31 - Rubens - 02/10/2009                            ³
	//³Verifica se algum produto nao tem estoque disponivel e ³
	//³pergunta se deseja gerar sugestao de compra            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMsgSugCom := ""
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSelectArea("SB2")
	DbSetOrder(1)
	For ni := 1 to Len(aItens)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a TES Mov. Estoque ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if aItens[nI,13] <> "S"
			loop
		endif
		//

		dbSelectArea("SB1")
		DbSeek( xFilial("SB1") + aItens[ni,1] + aItens[ni,2] )
		If !Empty(aItens[ni,4])
			cLocPad := aItens[ni,4]
		Else
			cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		EndIf
		//	If lSugCompra
		dbSelectArea("SB2")
		DbSeek(xFilial("SB2")+SB1->B1_COD+cLocPad)
		If aItens[ni,3] > SaldoSB2()
			cMsgSugCom += AllTrim(SB1->B1_COD) + "-" + AllTrim(SB1->B1_DESC) + " - " + ;
				STR0012+": [" + AllTrim(Str(aItens[ni,3])) + "] - " + ; //Qtde Orc.
				STR0013+": " + cLocPad + "=[" + AllTrim(Str(SaldoSB2())) + "]" + chr(13)//Almox.
		EndIf

	Next nI
	// Existem pecas sem estoque disponivel para atender o Orcamento
	If !Empty(cMsgSugCom)
		If lSugCompra
			if lSugAuto
				lSugCompra := .t.
			elseIf !MsgYesNo(STR0009 + CHR(13) + CHR(10) + STR0010 ,STR0011)  //"Existe um ou mais produtos sem estoque disponivel. # Deseja gerar uma sugestão de compra dos produtos sem estoque disponivel # Atenção
				lSugCompra := .f.
			EndIf
		Else
			If !lESTNEG // NAO PERMITE ESTOQUE NEGATIVO
				If lMovtoReserva // Se faz reserva ...
					MsgInfo(STR0009,STR0011) // Existe um ou mais produtos sem estoque disponivel. / Atencao
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lCtrlLote .and. lMovtoReserva
	nLenAItens := Len(aItens)
	For nI := 1 to nLenAItens
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1") + aItens[nI,1] + aItens[nI,2]))
		If !Empty(aItens[nI,17]) .or. Rastro(SB1->B1_COD)
			oPeca:LoadB1()
			If Empty(aItens[nI,17]) // Não foi informado o lote

				// Pesquisa se algum lote foi informado manualmente, para que a funcao nao considere o saldo informado ...
				aLotesInf := {}
				aEval( aItens , { |x| ;
					IIF( !Empty(x[17]) .and. x[1] == aItens[nI,1] .and. x[2] == aItens[nI,2] .and. x[4] == aItens[nI,4] , AADD( aLotesInf, {x[17],x[18],x[19],"",x[3] }) , ) })
				//
				aLotes := oPeca:SaldoLoteMovimentacao( aItens[nI,4] , aItens[nI,3] , aItens[nI,17] , aItens[nI,18] , aLotesInf)
				For nPosLote := 1 to Len(aLotes)
					If nPosLote == 1
						nItens := nI
					Else
						AADD(aItens,aClone(aItens[nI]))
						nItens := Len(aItens)
					EndIf
					aItens[ nItens ,03] := aLotes[nPosLote,5]	// 03 - Quantidade
					aItens[ nItens ,17] := aLotes[nPosLote,1]	// 17 - Lote
					aItens[ nItens ,18] := aLotes[nPosLote,2]	// 18 - Sub-Lote
					aItens[ nItens ,21] := aLotes[nPosLote,7]	// 21 - Data de Validade
				Next nPos
			Else
				aItens[nI,21] := oPeca:LoteDtValid(aItens[nI,17])
			EndIf
		EndIf
	Next nI
EndIf

// Pecas
Begin Transaction
For ni := 1 to Len(aItens)
	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek( xFilial("SB1") + aItens[ni,1] + aItens[ni,2] )
	DbSelectArea("SB2")
	DbSetOrder(1)
	If !Empty(aItens[ni,4])
		cLocPad := aItens[ni,4]
	Else
		cLocPad := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
	EndIf
	DbSeek(xFilial("SB2")+SB1->B1_COD+cLocPad)
	If (nPosDisp := aScan(aDisponivel , { |x| x[1] == SB1->B1_COD+cLocPad })) == 0
		Aadd( aDisponivel , { SB1->B1_COD+cLocPad , 0 } )
		nPosDisp := Len(aDisponivel)
	EndIf
	aDisponivel[nPosDisp,2] := SaldoSB2()

	lNovo := .t.

	// Chamado do orcamento
	If nOrigem == 1
		cQuery := "SELECT VSJ.R_E_C_N_O_ NUMREG"
		cQuery +=  " FROM "+RetSQLName("VSJ")+" VSJ JOIN "+RetSQLName("VS1")+" VS1 ON VS1_FILIAL = '"+xFilial("VS1")+"' AND VS1.VS1_NUMORC=VSJ.VSJ_NUMORC AND VS1.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VSJ.VSJ_FILIAL = '"+xFilial("VSJ")+"'"
		cQuery +=   " AND VSJ.VSJ_NUMOSV = '"+VO1->VO1_NUMOSV+"'"
		cQuery +=   " AND VSJ.VSJ_GRUITE = '"+aItens[ni,1]+"'"
		cQuery +=   " AND VSJ.VSJ_CODITE = '"+aItens[ni,2]+"'"
		IF lInconveniente
			cQuery +=   " AND VSJ.VSJ_SEQINC = '"+aItens[ni,10]+"'"
		ENDIF
		If lVSJCODIGO
			cQuery +=   " AND VSJ.VSJ_QTDITE > 0 "
		EndIf
		cQuery +=   " AND VS1_NUMORC = '" + aItens[ni,11] + "'
		cQuery +=   " AND VSJ.VSJ_RESPEC = '" + IIf( lMovtoReserva .and. aItens[nI,13] == "S" , "1" , "0" ) + "'"
		cQuery +=   " AND VSJ.VSJ_LOTECT = '" + aItens[ni,17] + "'"
		cQuery +=   " AND VSJ.VSJ_NUMLOT = '" + aItens[ni,18] + "'"
		cQuery +=   " AND VSJ.D_E_L_E_T_ = ' '"
		cQuery +=   " AND VS1.VS1_TIPTEM = '"+aItens[ni,7]+"'"
		cQuery +=   " AND VS1.VS1_CLIFAT = '"+aItens[ni,8]+"'"
		cQuery +=   " AND VS1.VS1_LOJA = '"+aItens[ni,9]+"'"
		nRecno := FM_SQL(cQuery)

		dbSelectArea("VSJ")
		IF nRecno > 0
			VSJ->(dbGoTo(nRecno))
			RecLock("VSJ",.f.)
			lNovo := .f.
		ENDIF
	EndIf

	If lNovo
		RecLock("VSJ",.t.)
		VSJ->VSJ_FILIAL := xFilial("VSJ")
		If lVSJCODIGO
			VSJ->VSJ_CODIGO := GetSxeNum("VSJ","VSJ_CODIGO",,3) // Indice 3 -> VSJ_FILIAL + VSJ_CODIGO
			ConfirmSX8()
		ENDIF
	EndIf

	VSJ->VSJ_NUMORC := _cNumOrc
	VSJ->VSJ_NUMOSV := VO1->VO1_NUMOSV
	VSJ->VSJ_GRUITE := aItens[ni,1]
	VSJ->VSJ_CODITE := aItens[ni,2]
	VSJ->VSJ_QTDITE += aItens[ni,3]
	VSJ->VSJ_PROIMP := Posicione("VAI",4,xFilial("VAI") + __cUserID , "VAI_CODUSR" )
	VSJ->VSJ_ORIDAD := aItens[ni,20]
	VSJ->VSJ_RESPEC := "0" // Nao foi feito reserva de peca
	VSJ->VSJ_DEPGAR := aItens[ni,15]
	VSJ->VSJ_DEPINT := aItens[ni,16]
	VSJ->VSJ_LOTECT := aItens[ni,17]
	VSJ->VSJ_NUMLOT := aItens[ni,18]
	IF lInconveniente
		VSJ->VSJ_SEQINC := aItens[ni,10]
	ENDIF
	IF lVSJTIPTEM .and. aItens[ni,20] $ "3/4"
		VSJ->VSJ_TIPTEM := aItens[ni,07]
	ENDIF
	IF lVSJCODTES .and. aItens[ni,20] $ "3/4"
		VSJ->VSJ_CODTES := aItens[ni,12]
	ENDIF
	If nOrigem == 3
		For nCont := 1 to Len(aItens[ni,23])
			&("VSJ->" + aItens[nI,23,nCont,1]) := aItens[nI,23,nCont,2]
		Next nCont
	EndIf
	msunlock()
	
	nRecVSJ := VSJ->(Recno()) // Salvar o RECNO para atualizar o registro do VSJ apos movimentação

	If nOrigem == 3
		AADD( aRecnoCriado , VSJ->(Recno()))
	EndIf

	If nOrigem <> 3 .or. lVSJManRes // NAO é registro digitado manualmente ou é para reservar mesmo que VSJ manual
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta vetor com itens que nao foram para o almoxarifado reservado  MV_RESITE        ³
		//³Se for gerar sugestao automatica, nao imprime a relacao - CI009854 - Imprimir Sempre³
		//³Verifica se a TES Mov. Estoque ( aItens[ni,13] == "S" )                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aItens[ni,3] > aDisponivel[nPosDisp,2] .and. aItens[ni,13] == "S"
			Aadd(aItensNImp[2] , {} )
			For nItens := 1 to FCount()
				if AllTrim(FieldName(nItens)) <> "VSJ_QTDITE"
					Aadd(aItensNImp[2,Len(aItensNImp[2])] , FieldGet(nItens) )
				Else
					Aadd(aItensNImp[2,Len(aItensNImp[2])] , (aItens[ni,3] - aDisponivel[nPosDisp,2]) )
				EndIF
			Next
			Aadd(aItensNImp[2,Len(aItensNImp[2])] , SB1->B1_DESC )
			Aadd(aItensNImp[2,Len(aItensNImp[2])] , cLocPad )
		EndIf
	EndIf

	nQtdeReserv := 0

	// Reserva de Peca E a TES Mov. Estoque ???
	If lMovtoReserva .and. aItens[nI,13] == "S"

		cDocD3 := Criavar("D3_DOC")
		cDocD3 := IIf(Empty(cDocD3),NextNumero("SD3",2,"D3_DOC",.T.),cDocD3)
		cDocD3 := A261RetINV(cDocD3)

		// Se tiver quantidade disponivel, reserva mesmo nao tendo quantidade total disponivel
		// OU  
		// pode trabalhar com Estoque Negativo (MV_ESTNEG == "S")
		If aDisponivel[nPosDisp,2] > 0 .or. lESTNEG

			nQtdeReserv := aItens[ni,3]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se nao tiver qtde total disponivel, reserva o que puder                                   ³
			//³ CI 2647 Somente reserva o que puder caso sug. de compra esteja ativada e RITEORC esteja S ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lESTNEG // não pode trabalhar com Estoque Negativo (MV_ESTNEG == "N")
				IF nQtdeReserv > aDisponivel[nPosDisp,2]   // Se a qtd pra reservar for maior que o disponivel
					nQtdeReserv := aDisponivel[nPosDisp,2]
				ENDIF
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Marca VSJ que a peca foi reservada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("VSJ",.f.)
				VSJ->VSJ_RESPEC := "1"
			VSJ->(MsUnLock())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³PL 31 - Rubens - 28/09/2009           ³
			//³Gera um registro de reserva de estoque³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT R_E_C_N_O_ VE6RECNO " +;
				" FROM " + RetSQLName("VE6") + " VE6 " +;
				" WHERE VE6.VE6_FILIAL = '" + xFilial("VE6") + "'" +;
				  " AND VE6.VE6_NUMOSV = '" + _cNumOSV + "'" +;
				  " AND VE6.VE6_INDREG = '3'" +; // Registro de Reserva
				  " AND VE6.VE6_GRUITE = '" + SB1->B1_GRUPO + "'" +;
				  " AND VE6.VE6_CODITE = '" + SB1->B1_CODITE + "'" +;
				  " AND VE6.VE6_LOTECT = '" + VSJ->VSJ_LOTECT + "'" +;
				  " AND VE6.VE6_NUMLOT = '" + VSJ->VSJ_NUMLOT + "'" +;
				  " AND VE6.D_E_L_E_T_ = ' '"
			nRecno := FM_SQL(cQuery)
			dbSelectArea("VE6")
			If nRecno == 0
				RecLock("VE6" , .T. )
				VE6->VE6_FILIAL := xFilial("VE6")
				VE6->VE6_GRUITE := VSJ->VSJ_GRUITE
				VE6->VE6_CODITE := VSJ->VSJ_CODITE
				VE6->VE6_CODMAR := Posicione("SBM",1, xFilial("SBM")+VSJ->VSJ_GRUITE,"SBM->BM_CODMAR")
				VE6->VE6_CODUSU := CriaVar("VE6_CODUSU")
				VE6->VE6_CODIGO := CriaVar("VE6_CODIGO")
				VE6->VE6_DATREG := CriaVar("VE6_DATREG")
				VE6->VE6_HORREG := CriaVar("VE6_HORREG")
				VE6->VE6_INDREG := "3" // Reserva de Itens
				VE6->VE6_ORIREQ := "2" // Oficina
				VE6->VE6_DESORI := "OFICINA"
				VE6->VE6_LOTECT := VSJ->VSJ_LOTECT
				VE6->VE6_NUMLOT := VSJ->VSJ_NUMLOT
				VE6->VE6_NUMOSV := VSJ->VSJ_NUMOSV
				VE6->VE6_NUMSER := VSJ->VSJ_NUMSER
				VE6->VE6_VALPEC := aItens[ni,14]
			ELSE
				dbGoTo(nRecno)
				RecLock("VE6" , .F. )
			ENDIF
			VE6->VE6_QTDITE += nQtdeReserv
			MsUnLock()
			////////////////////////////////////////////////////////////////////////////////////////////////////
			If !Localiza(SB1->B1_COD)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Movimentacao interna do Item                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aItensNew:={}
				DbSelectArea("SB5")
				DbSetOrder(1)
				DbSeek( xFilial("SB5") + SB1->B1_COD )
				DbSelectArea("SB1")
				DbSetOrder(1)
				// Adiciona cabecalho com numero do documento e data da transferencia modelo II
				aadd (aItensNew,{ cDocD3, ddatabase})

				cLocOri := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

				aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //Código do Produto
											cLocPad         ,; // Armazém de Origem
											cMVRESITE       ,; // Armazém de Destino
											cLocOri         ,; // Localização Origem
											cMVRESLOC       ,; // Localização Destino
											nQtdeReserv     ,; // Qtd a transferir
											VSJ->VSJ_LOTECT ,; // Nro de lote
											VSJ->VSJ_NUMLOT ,; // Nro de Sub-Lote
											VSJ->VSJ_NUMSER ,; // Nro de Série
											aItens[nI,21]    ) // Data Validade Lote

				aAdd(aItensNew, aClone(aItemMov))

				If (ExistBlock("VFUNB1"))
					aItensNew := ExecBlock("VFUNB1", .f., .f., {aItensNew})
				EndIf

				MSExecAuto({|x| MATA261(x)},aItensNew)

				If lMsErroAuto
					&& Cancela Gravacao]
					MOSTRAERRO()
					DisarmTransaction()
					Break
				EndIf
			Else
				cLocalDis := aItens[ni,4]
				cLocalRes := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
				//
				cLote    := ""
				cNumLote := ""
				if !Empty(VSJ->VSJ_LOTECT)
					cLote    := VSJ->VSJ_LOTECT
					cNumLote := VSJ->VSJ_NUMLOT
				endif
				if !Empty(aItens[ni,19])
					aVetLocPec  := {{aItens[ni,19],nQtdeReserv}}
				else
					aVetLocPec := OX001PRAUTLC(SB1->B1_COD,cLocalDis,nQtdeReserv,cLote,cNumLote)  // Funcao de Priorizacao Automatica das Localizacoes
					If Len(aVetLocPec) == 1 .and. aVetLocPec[1,1] == "" .and. aVetLocPec[1,2] == 0
						aVetLocPec  := {{"",nQtdeReserv}}
					Endif
				endif
				//
				nQtAtend := 0
				for iVLP := 1 to Len(aVetLocPec)
					nQtAtend += aVetLocPec[iVLP,2]
				Next
				for iVLP := 1 to Len(aVetLocPec)

					cLocali2Dis := aVetLocPec[iVLP,1]
					cLocali2Res := IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_RESLOC"))),Space(15))
					If Empty(cLocali2Res)
						cQuery := "SELECT SBF.BF_LOCALIZ FROM "+RetSqlName("SBF")+" SBF WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"' AND "
						cQuery += "SBF.BF_PRODUTO = '"+SB1->B1_COD+"' AND SBF.BF_LOCAL = '"+aItens[ni,4]+"' AND SBF.BF_QUANT > 0 AND "
						If !Empty(cLote)
							cQuery += "SBF.BF_LOTECTL = '"+cLote+"' AND "
						Endif
						If !Empty(cNumLote)
							cQuery += "SBF.BF_NUMLOTE = '"+cNumLote+"' AND "
						Endif
						cQuery += "SBF.D_E_L_E_T_ = ' ' ORDER BY SBF.BF_PRIOR"
						cLocali2Res := Alltrim(FM_SQL(cQuery))
					Endif

					nQtdLocPec  := aVetLocPec[iVLP,2]

					////////////////////////////////////////////////////////////////////////////////////////////////////

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Movimentacao interna do Item                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aItensNew:={}
					DbSelectArea("SB5")
					DbSetOrder(1)
					DbSeek( xFilial("SB5") + SB1->B1_COD )
					DbSelectArea("SB1")
					DbSetOrder(1)
					
					// Adiciona cabecalho com numero do documento e data da transferencia modelo II
					aadd (aItensNew,{ cDocD3, ddatabase})

					aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //Código do Produto
												cLocalDis       ,; // Armazém de Origem
												cLocalRes       ,; // Armazém de Destino
												cLocali2Dis     ,; // Localização Origem
												cLocali2Res     ,; // Localização Destino
												nQtdLocPec      ,; // Qtd a transferir
												VSJ->VSJ_LOTECT ,; // Nro de lote
												VSJ->VSJ_NUMLOT ,; // Nro de Sub-Lote
												VSJ->VSJ_NUMSER ,; // Nro de Série
												aItens[nI,21]    ) // Data Validade Lote

					aAdd(aItensNew, aClone(aItemMov))

					If (ExistBlock("VFUNB2"))
						aItensNew := ExecBlock("VFUNB2", .f., .f., {aItensNew})
					EndIf

					MSExecAuto({|x| MATA261(x)},aItensNew)

					If lMsErroAuto
						&& Cancela Gravacao
						MOSTRAERRO()
						DisarmTransaction()
						Break
					EndIf

					MsUnLock()
					// Atualiza VS3_DOCSDB
					If VS3->(FieldPos("VS3_DOCSDB")) > 0
						DBSelectArea("VS3")
						DBSetOrder(2)
						DBSeek(xFilial("VS3")+ _cNumOrc + SB1->B1_GRUPO + SB1->B1_CODITE)
						//
						while !eof() .and. xFilial("VS3") + _cNumOrc + SB1->B1_GRUPO + SB1->B1_CODITE == VS3->VS3_FILIAL + VS3->VS3_NUMORC + VS3->VS3_GRUITE + VS3->VS3_CODITE
							//
							Reclock("VS3",.f.)
							VS3_DOCSDB := cDocD3
							MsUnLock()
							DBSelectArea("VS3")
							DBSkip()
							//
						enddo
					Endif

				Next

			Endif

		Endif

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - PL - Shark - 28/09/2009             ³
	//³Gera sugestao de compra no Modulo de Compras ³
	//³Verifica se a TES Mov Estoque (aItens[nI,13] == "S" )³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lSugCompra .and. aItens[nI,13] == "S"

		If !lPE_FMSGCPOF // Gravação DEFAULT - Não utiliza o Ponto de Entrada que substitui a criação da Sugestão de Compra do Orçamento Oficina

			If aDisponivel[nPosDisp,2] == 0 .or. aItens[ni,3] > aDisponivel[nPosDisp,2]

				IF Empty(cCodSugCompra)
					cCodSugCompra := CriaVar("FJ_CODIGO",.T.)
					DbSelectArea("SFJ")
					If _lConfirmSX
						ConfirmSX8()
					EndIf
					PutMv("MV_ULTPED",cCodSugCompra)
				EndIf

				If lVSJSUGCOM .and. nRecVSJ > 0 // Gravar o Codigo da Sugestao de Compra no VSJ
					DbSelectArea("VSJ")
					DbGoto(nRecVSJ)
					RecLock("VSJ",.f.)
						VSJ->VSJ_SUGCOM := cCodSugCompra // Gravar o Codigo da Sugestao de Compra no VSJ
					MsUnLock()
				EndIf

				DbSelectArea("SB1")
				DbSetOrder(7)
				DbSeek( xFilial("SB1") + aItens[ni,1] + aItens[ni,2] )
				
				RecLock("VE6" , .T. )
					VE6->VE6_FILIAL := CriaVar("VE6_FILIAL")
					VE6->VE6_FILIAL := xFilial("VE6")
					VE6->VE6_GRUITE := VSJ->VSJ_GRUITE
					VE6->VE6_CODITE := VSJ->VSJ_CODITE
					VE6->VE6_CODMAR := Posicione("SBM",1, xFilial("SBM")+VSJ->VSJ_GRUITE,"SBM->BM_CODMAR")
					VE6->VE6_CODUSU := CriaVar("VE6_CODUSU")
					VE6->VE6_DATREG := CriaVar("VE6_DATREG")
					VE6->VE6_HORREG := CriaVar("VE6_HORREG")
					VE6->VE6_INDREG := "0" // Sugestao de Compra
					VE6->VE6_ORIREQ := "2" // Oficina
					VE6->VE6_DESORI := "OFICINA"
					VE6->VE6_LOTECT := VSJ->VSJ_LOTECT
					VE6->VE6_NUMLOT := VSJ->VSJ_NUMLOT
					VE6->VE6_NUMOSV := VSJ->VSJ_NUMOSV
					VE6->VE6_NUMSER := VSJ->VSJ_NUMSER
					VE6->VE6_QTDITE := aItens[ni,3] - nQtdeReserv
					VE6->VE6_FORPED := FM_PESQPARAM("MV_FPREGOC",VE6->VE6_CODMAR) // Unidade Parada (CRIAR PARAMETRO)
					VE6->VE6_DESPED := Posicione("VEJ",1, xFilial("VEJ")+VE6->VE6_CODMAR+VE6->VE6_FORPED,"VEJ->VEJ_DESCRI")
					VE6->VE6_FORMUL := CriaVar("VE6_FORMUL")
					VE6->VE6_FORPAG := CriaVar("VE6_FORPAG")
					VE6->VE6_PEND   := CriaVar("VE6_PEND")
					VE6->VE6_TIPTEM := CriaVar("VE6_TIPTEM")
					VE6->VE6_VALPEC := CriaVar("VE6_VALPEC")
					VE6->VE6_SUGCOM := cCodSugCompra
					VE6->VE6_CODIGO := CriaVar("VE6_CODIGO")
				MsUnLock()

				Pergunte("MTA297M",.f.)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava Codigo da Sugestao de Compra gerada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If lInfCab

					RecLock("SFJ",.T.)
						SFJ->FJ_FILIAL  := xFilial("SFJ")
						SFJ->FJ_CODIGO  := cCodSugCompra
						SFJ->FJ_FORPED  := VE6->VE6_FORPED
						SFJ->FJ_DATREF  := dDataBase
						SFJ->FJ_DIASSUG := 1
						SFJ->FJ_CUSUNIT := Str(MV_PAR02,1)
						SFJ->FJ_TIPPRC  := Str(MV_PAR03,1)
						SFJ->FJ_IMPORT  := Str(MV_PAR05,1)

						If Alltrim(MV_PAR04) == "*"
							SFJ->FJ_CLASSIF := "AA/AB/AC/BA/BB/BC/CA/CB/CC/"
						Else
							For nItens:=1 to Len(AllTrim(MV_PAR04)) Step 2
								SFJ->FJ_CLASSIF += Upper(SubStr(MV_PAR04,nItens,2))+"/"
							Next
						EndIf

						SFJ->FJ_ANO     := Str(Year( dDataBase),4)
						SFJ->FJ_MES     := StrZero(Month(dDataBase),2)
						SFJ->FJ_GRUPODE := left(MV_PAR07,4)
						SFJ->FJ_GRUPOAT := left(right(Alltrim(MV_PAR07),5),4)
						SFJ->FJ_SOLICIT := ""
						SFJ->FJ_TIPPED  := VE6->VE6_FORPED
					MsUnlock()

					lInfCab := .f.

				EndIf

				aConsumo := Mt295Cons(Str(Year(dDataBase),4) + StrZero(Month( dDataBase),2),SB1->B1_COD)
				If ValType(aConsumo) == "A"
					nAtual   := len(aConsumo) + 1
				Else
					nAtual   := 1
				Endif

				DbSelectArea("SDF")
				DbSetOrder(1)
				DbSeek( xFilial("SDF") + cCodSugCompra + SB1->B1_COD )

				RecLock("SDF",!Found())
					SDF->DF_FILIAL  := xFilial("SDF")
					SDF->DF_CODIGO  := cCodSugCompra
					SDF->DF_FLAG    := "A"
					SDF->DF_PRODUTO := SB1->B1_COD
					SDF->DF_QTDSUG  += VE6->VE6_QTDITE
					If SDF->DF_QTDSUG < 1
						SDF->DF_QTDSUG := 1
					Endif

					IF SB1->B1_QE > 0
						If int(SDF->DF_QTDSUG/SB1->B1_QE) < (SDF->DF_QTDSUG/SB1->B1_QE)
							SDF->DF_QTDSUG := (int(SDF->DF_QTDSUG/SB1->B1_QE) + 1) * SB1->B1_QE
						Else
							SDF->DF_QTDSUG := int(SDF->DF_QTDSUG/SB1->B1_QE) * SB1->B1_QE
						EndIf
					EndIF

					If MV_PAR03 == 1
						SB5->(dbseek(xFilial("SB5")+SB1->B1_COD))
						If SDF->DF_QTDINF > 0
							SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB5->B5_PRV2)
						Else
							SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB5->B5_PRV2)
						EndIf

					ElseIF MV_PAR03 == 2
						If SDF->DF_QTDINF > 0
							SDF->DF_VLRTOT  := (SDF->DF_QTDINF*SB1->B1_UPRC)
						Else
							SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*SB1->B1_UPRC)
						EndIf
					Else
						If SDF->DF_QTDINF > 0
							SDF->DF_VLRTOT  := (SDF->DF_QTDINF*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
						Else
							SDF->DF_VLRTOT  := (SDF->DF_QTDSUG*FM_PRODSBZ(SB1->B1_COD,"SB1->B1_PRV1"))
						EndIf

					EndIF

					If SDF->DF_VLRTOT < 0.01
						SDF->DF_VLRTOT := 0.01
					Endif

					SDF->DF_QTDINF  := 0
					SDF->DF_M03     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3
					SDF->DF_M12     := (aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3]+aConsumo[nAtual-4]+;
					aConsumo[nAtual-5]+aConsumo[nAtual-6]+aConsumo[nAtual-7]+aConsumo[nAtual-8]+;
					aConsumo[nAtual-9]+aConsumo[nAtual-10]+aConsumo[nAtual-11]+aConsumo[nAtual-12])/12
					SDF->DF_QE      := SB1->B1_QE
					SDF->DF_D01     := aConsumo[nAtual-1]
					SDF->DF_D02     := aConsumo[nAtual-2]
					SDF->DF_D03     := aConsumo[nAtual-3]
					SDF->DF_D04     := aConsumo[nAtual-4]
					SDF->DF_D05     := aConsumo[nAtual-5]
					SDF->DF_D06     := aConsumo[nAtual-6]
					SDF->DF_D07     := aConsumo[nAtual-7]
					SDF->DF_D08     := aConsumo[nAtual-8]
					SDF->DF_D09     := aConsumo[nAtual-9]
					SDF->DF_D10     := aConsumo[nAtual-10]
					SDF->DF_D11     := aConsumo[nAtual-11]
					SDF->DF_D12     := aConsumo[nAtual-12]

				MsUnlock()

			EndIf
		
		EndIf

	EndIf

	// Abate a quantidade exportada do saldo atual da peca
	If aItens[nI,13] == "S"
		aDisponivel[nPosDisp,2] -= aItens[ni,3]
	EndIf
	//

Next

If lSugCompra .and. lPE_FMSGCPOF

	ExecBlock("FMSGCPOF",.f.,.f., { _lConfirmSX } ) // Ponto de Entrada que substitui a criação da Sugestão de Compra do Orçamento Oficina

Endif

End Transaction
lMsHelpAuto := .f.
If lMsErroAuto
	MostraErro()
	sRestArea(aArea)
	return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Requisicao de Franquia ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrigem == 1
	if VS1->(FieldPos("VS1_FRANQP")) <> 0 .and. VS1->VS1_FRANQP > 0
		REQFRA020( _cNumOSV , VS1->VS1_TIPTEM )
	endif
endif
//

If !Empty(cCodSugCompra)
	MsgInfo(STR0112 + CHR(13) + CHR(10) + STR0113 + cCodSugCompra, STR0011) // Sugestão de compra gerada! / Nro:  / Atenção
EndIf

sRestArea(aArea)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_IPECNDISPºAutor³ Luis / Andre Luis Almeida º Data ³ 20/08/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Imprime Itens nao Importados no VSJ (OS)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_IPECNDISP(aItensNImp)
Local cAlias   := Alias()
Local cNomeRel := "ORCNIMPORT"
Local oReport

Private cTamanho := "M"
Private cTitulo:= STR0014 //Pecas do orcamento nao transferido para o reservado.
Private cDesc1 := ""
Private cDesc2 := ""
Private cDesc3 := ""
Private aReturn:= {STR0015,1,STR0016,1,2,1,,2} //Zebrado # Administracao
Private cabec1 := ""
Private cabec2 := ""
Private nCaracter:= 15
Private nLastKey :=0
Private m_Pag := 1

If Empty(cAlias)
	cAlias := "VS1"
EndIf

If Len(aItensNImp[2]) # 0
	If ExistBlock("PEIPECND")
		cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
		If nlastkey == 27
			Return(Allwaystrue())
		EndIf
		SetDefault(aReturn,cAlias)

		RptStatus( { |lEnd| ExecBlock("PEIPECND",.f.,.f.,{ aItensNImp , cNomeRel })  } )
	Else
		oReport := FS_PecasSugestaoCompra() // Nesta função nós definimos a estrutura do relatório, por exemplo as seções, campos, totalizadores e etc.
		oReport:SetPortrait()               // Define orientação de página do relatório como retrato.
		oReport:PrintDialog()               // Essa função serve para disparar a impressão do TReport, ela que faz com que seja exibida a tela de configuração de impressora e os botões de parâmetros.
	EndIf
EndIf
Return

/*/{Protheus.doc} FS_PecasSugestaoCompra
Criando o padrão para impressão da Relação das Peças do Orçamento não transferidas para o reservado
@author Fernando Vitor Cavani
@since 04/06/2020
@version undefined
@type function
/*/
Static Function FS_PecasSugestaoCompra()
Local cDesc := ""
Local oReport
Local oSection1
Local oSection2

cTit := ""
cNro := cGrp := cCod := cDes := cArm := ""
nQtd := 0

// Descrição
cDesc := STR0111 // Este programa tem como objetivo imprimir a Relação das Peças do Orçamento não transferidas para o reservado

// TReport
oReport := TReport():New(             ;
	"ORCNIMPORT",                     ;
	cTitulo,                          ;
	,                                 ;
	{|oReport| FS_IPECNDISP(oReport)},;
	cDesc)

// Título
oSection1 := TRSection():New(oReport, "oTitulo")

oSection1:SetLineStyle()    // Define se imprime as células da seção em linhas
oSection1:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção

TRCell():New(oSection1, "oTit",, GetSX3Cache("VSJ_NUMORC","X3_TITULO"), "@!", 100,, {|| cTit },,,,,,,,, .t.) // Número do Orc.

// Dados
oSection2 := TRSection():New(oReport, "oDados")

oSection2:SetLinesBefore(1) // Define a quantidade de linhas que serão saltadas antes da impressão da seção

TRCell():New(oSection2, "oNro",, GetSX3Cache("VSJ_NUMOSV","X3_TITULO"), "@!"            ,  30,, {|| cNro },,,        ,,,,,,) // Número da OS
TRCell():New(oSection2, "oGrp",, GetSX3Cache("VSJ_GRUITE","X3_TITULO"), "@!"            ,  20,, {|| cGrp },,,        ,,,,,,) // Grupo
TRCell():New(oSection2, "oCod",, GetSX3Cache("VSJ_CODITE","X3_TITULO"), "@!"            ,  40,, {|| cCod },,,        ,,,,,,) // Código do Item
TRCell():New(oSection2, "oDes",, GetSX3Cache("B1_DESC","X3_TITULO")   , "@!"            , 100,, {|| cDes },,,        ,,,,,,) // Descrição
TRCell():New(oSection2, "oArm",, GetSX3Cache("B1_LOCPAD","X3_TITULO") , "@!"            ,  30,, {|| cArm },,,        ,,,,,,) // Armazém
TRCell():New(oSection2, "oQtd",, GetSX3Cache("VSJ_QTDITE","X3_TITULO"), "@E 999,999,999",  30,, {|| nQtd },,, "RIGHT",,,,,,) // Qtd Disponível
Return(oReport)

/*/{Protheus.doc} FS_IPECNDISP
Impressão em TReport da Relação das Peças do Orçamento não transferidas para o reservado
@author Fernando Vitor Cavani
@since 04/06/2020
@version undefined
@type function
/*/
Static Function FS_IPECNDISP(oReport)
Local bConteudo := {|cCampo| Ascan(aItensNImp[1], cCampo)}
Local i := 0
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)

// Título
oSection1:Init()

cTit := aItensNImp[2, 1, Eval(bConteudo, "VSJ_NUMORC")] // Número do Orc.

oSection1:PrintLine()

oSection1:Finish()

// Dados
oSection2:Init()

For i := 1 to Len(aItensNImp[2])
	cNro := aItensNImp[2, i, Eval(bConteudo, "VSJ_NUMOSV")] // Número da OS
	cGrp := aItensNImp[2, i, Eval(bConteudo, "VSJ_GRUITE")] // Grupo
	cCod := aItensNImp[2, i, Eval(bConteudo, "VSJ_CODITE")] // Código do Item
	cDes := aItensNImp[2, i, Eval(bConteudo, "B1_DESC")]    // Descrição
	cArm := aItensNImp[2, i, Eval(bConteudo, "B1_LOCPAD")]  // Armazém
	nQtd := aItensNImp[2, i, Eval(bConteudo, "VSJ_QTDITE")] // Qtd Disponível

	oSection2:PrintLine()
Next

oSection2:Finish()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_FATTTPOº Autor ³ Andre Luis Almeida        º Data ³ 19/09/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Valida/Altera Faturar Para com o Tipo de Tempo                 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_FATTTPO( _cNumOSV , _cTipTem , _cCliFat , _cLojFat , _cNomFat , _cNomErr , _cTipReq )
Local lRet  := .t.
Local cSeek := ""
Local lConsidera
DbSelectArea("VO1")	// Nro OS
DbSetOrder(1)
If !DbSeek( xFilial("VO1") + _cNumOSV )
	&_cNomErr := STR0008+" "+_cNumOSV+" (VO1)" //Ordem de Servico nao encontrada!
	Return(.f.)
EndIf
DbSelectArea("VOI")	// Tipo de Tempo
DbSetOrder(1)
If !DbSeek( xFilial("VOI") + _cTipTem )
	&_cNomErr := STR0017+" "+_cTipTem+" (VOI)"  //Tipo de Tempo nao encontrado!
	Return(.f.)
EndIf
If _cTipReq == "P" .and. VOI->VOI_REQPEC <> "1"
	&_cNomErr := STR0018+" "+_cTipTem+" (VOI)" //Tipo de Tempo nao requisita Pecas!
	Return(.F.)
EndIf

If VOI->(FieldPos("VOI_REQSER")) > 0
	If _cTipReq == "S" .and. (!Empty(VOI->VOI_REQSER) .and. VOI->VOI_REQSER <> "1")
		&_cNomErr := STR0108+" "+_cTipTem+" (VOI)" //Tipo de Tempo nao requisita Serviço!
		Return(.F.)
	EndIf
EndIf

DbSelectArea("VAI") // Equipe Tecnica
DbSetOrder(4)
If !DbSeek( xFilial("VAI") + __cUserID )
	&_cNomErr := STR0019+" "+__cUserID+" (VAI)"//Produtivo nao encontrado!
	Return(.f.)
EndIf
DbSelectArea("VOW")	// Tipo de Tempo / Produtivo
DbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Luis Delorme - 30/10/2009                               ³
//³Verifica se o criterio do Tipo de Tempo sera considerado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lConsidera := .t.
if VOI->(FieldPos("VOI_CONVOW")) > 0
	if VOI->VOI_CONVOW == "0"
		lConsidera := .f.
	endif
endif
If !DbSeek( xFilial("VOW") + VAI->VAI_CODTEC + VOI->VOI_TIPTEM ) .and. lConsidera
	&_cNomErr := STR0020+" "+VAI->VAI_CODTEC+" - "+VOI->VOI_TIPTEM+" (VOW)" //Produtivo nao relacionado no Tipo de Tempo!
	Return(.f.)
EndIf
DbSelectArea("VV1")	// Veiculo
DbSetOrder(1)
If !DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )
	&_cNomErr := STR0001+" "+VO1->VO1_CHAINT+" (VV1)" //Veiculo nao encontrado!
	Return(.F.)
EndIf
DbSelectArea("VV2")	// Modelo
DbSetOrder(1)
If !DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD)
	&_cNomErr := STR0021+" "+VV1->VV1_CODMAR+" "+VV1->VV1_MODVEI + " " + VV1->VV1_SEGMOD+" (VV2)" //Modelo do Veiculo nao encontrado!
	Return(.F.)
EndIf
DbSelectArea("VO2")	// Requisicoes
DbSetOrder(1)
DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV )
While !Eof() .and. VO2->VO2_NUMOSV==VO1->VO1_NUMOSV .and. lRet
	If VO2->VO2_TIPREQ == "P"	// Pecas
		DbSelectArea("VO3")
		DbSetOrder(1)
		If DbSeek( xFilial("VO3") + VO2->VO2_NOSNUM + VOI->VOI_TIPTEM )
			If ( !Empty(VO3->VO3_DATDIS) .or. !Empty(VO3->VO3_DATFEC) .Or. !Empty(VO3->VO3_DATCAN) )
				If !Empty(VO3->VO3_DATCAN)
					&_cNomErr := STR0022+" "+VOI->VOI_TIPTEM+" (VO3)" //"Tipo de Tempo ja Cancelado!
				ElseIf !Empty(VO3->VO3_DATFEC)
					&_cNomErr := STR0023+" "+VOI->VOI_TIPTEM+" (VO3)" //"Tipo de Tempo ja Finalizado!
				ElseIf !Empty(VO3->VO3_DATDIS)
					&_cNomErr := STR0024+" "+VOI->VOI_TIPTEM+" (VO3)" // "Tipo de Tempo ja Disponibilizado!"
				EndIf
				lRet := .f.
			Else
				cSeek := VO3->VO3_FATPAR + VO3->VO3_LOJA
				&_cNomErr := STR0025+" "+VO3->VO3_FATPAR+"-"+VO3->VO3_LOJA+" (VO3)"	//Cliente referente a Requisicao de Pecas nao encontrado!
			EndIf
		EndIf
	Else 								// Servicos
		DbSelectArea("VO4")
		DbSetOrder(1)
		If DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM + VOI->VOI_TIPTEM )
			If ( !Empty(VO4->VO4_DATDIS) .or. !Empty(VO4->VO4_DATFEC) .or. !Empty(VO4->VO4_DATCAN) )
				If !Empty(VO4->VO4_DATCAN)
					&_cNomErr := STR0022+" "+VOI->VOI_TIPTEM+" (VO4)" //"Tipo de Tempo ja Cancelado!
				ElseIf !Empty(VO4->VO4_DATFEC)
					&_cNomErr := STR0023+" "+VOI->VOI_TIPTEM+" (VO4)"//"Tipo de Tempo ja Finalizado!"
				ElseIf !Empty(VO4->VO4_DATDIS)
					&_cNomErr := STR0024+" "+VOI->VOI_TIPTEM+" (VO4)" //"Tipo de Tempo ja Disponibilizado!
				EndIf
				lRet := .f.
			Else
				cSeek := VO4->VO4_FATPAR + VO4->VO4_LOJA
				&_cNomErr := STR0026+" "+VO4->VO4_FATPAR+"-"+VO4->VO4_LOJA+" (VO4)" //"Cliente referente a Requisicao de Servicos nao encontrado!
			Endif
		EndIf
	EndIf
	DbSelectArea("VO2")
	DbSkip()
EndDo
If !lRet
	Return(.f.)
EndIf
If Empty(cSeek)
	Do Case
		Case VOI->VOI_USAPRO == "0" 					// PROPRIETARIO DO VEICULO
			cSeek := VV1->VV1_PROATU+VV1->VV1_LJPATU
			&_cNomErr := STR0027+" "+VV1->VV1_PROATU+"-"+VV1->VV1_LJPATU+" (VV1)" //"Cliente referente ao Proprietario do Veiculo nao encontrado!
		Case VOI->VOI_USAPRO == "1" 					// FABRICANTE DO VEICULO
			VE4->(DbSetOrder(1))
			VE4->(DbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
			cSeek := VE4->VE4_CODFAB+VE4->VE4_LOJA
			&_cNomErr := STR0028+" "+VE4->VE4_CODFAB+"-"+VE4->VE4_LOJA+" (VE4)"//"Cliente referente ao Fabricante do Veiculo nao encontrado!
		Case VOI->VOI_USAPRO == "2"           				// CLIENTE PADRAO
			cSeek := VOI->VOI_CLIFAT+VOI->VOI_LOJA
			&_cNomErr := STR0029+" "+VOI->VOI_CLIFAT+"-"+VOI->VOI_LOJA+" (VOI)" //"Cliente referente ao Padrao do Tipo de Tempo nao encontrado!
		Case VOI->VOI_USAPRO == "3"                     	// TODO: ???
			VVK->(DbSetOrder(1))
			VVK->(DbSeek( xFilial("VVK") + VV1->VV1_CODMAR + VV1->VV1_CODCON ))
			SA1->(DbSetOrder(3))
			SA1->(DbSeek( xFilial("SA1") + VVK->VVK_CGCVEN ))
			cSeek := SA1->A1_COD+SA1->A1_LOJA
			&_cNomErr := STR0030+" "+VVK->VVK_CGCVEN+" (VVK)" //"Cliente referente a Concessionaria x Fabrica nao encontrado!
	EndCase
EndIf
DbSelectArea("SA1")
DbSetOrder(1)
If !DbSeek( xFilial("SA1") + cSeek ) .or. Empty(cSeek)
	Return(.F.)
Else
	&_cCliFat := SA1->A1_COD
	&_cLojFat := SA1->A1_LOJA
	&_cNomFat := SA1->A1_NOME
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_VEIMOVSº Autor ³ Luis Delorme              º Data ³ 02/10/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna as movimentacoes realizadas no chassi                  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ [1] - "E" ou "S" - Movimentacao de Entrada ou Saida            º±±
±±º         ³ [2] - Filial da umtima movimentacao                            º±±
±±º         ³ [3] - TRACPA ou NUMTRA (dependendo do retorno [1]              º±±
±±º         ³ [4] - Data da emissao (DTHEMI) ***CARACTERE*** AAMMDDHH:MM:SS  º±±
±±º         ³ [5] - Operacao realizada na movimentacao (OPEMOV)              º±±
±±º         ³ [6] - Data do Movimento  (Formato de DATA)                     º±±
±±º         ³ [7] - Codigo do Cliente/Fornecedor                             º±±
±±º         ³ [8] - Loja do Cliente/Fornecedor                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FM_VEIMOVS( _cChassi , _cTipo,  _cOper )

Local cQryAlias	:= "SQLVV0AFG" // VV0/VVA
Local cQuery	:= {}
Local cDataQry	:= ""
Local cAlias := Alias()
Local aQuery := {}
Default _cTipo :="SE"
Default _cOper :=""

if "S" $ _cTipo
	cQuery := "SELECT VV0.VV0_FILIAL , VV0.VV0_NUMTRA , VV0.VV0_DTHEMI , VV0.VV0_OPEMOV , VV0.VV0_DATMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA "
	cQuery += "FROM "+RetSqlName("VVA")+" VVA INNER JOIN "+RetSqlName("VV0")+" VV0 ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA ) "
	cQuery += "WHERE VVA.VVA_CHASSI='"+_cChassi+"' AND VV0.VV0_SITNFI<>'0' "
	cQuery += "AND VVA.D_E_L_E_T_=' ' AND VV0.D_E_L_E_T_=' ' "
	if _cOper != ""
		cQuery += "AND VV0.VV0_OPEMOV='" + _cOper + "' "
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
	while !((cQryAlias)->(eof()))
		cDataQry := Subs((cQryAlias)->(VV0_DTHEMI),7,2)
		cDataQry += Subs((cQryAlias)->(VV0_DTHEMI),4,2)
		cDataQry += Subs((cQryAlias)->(VV0_DTHEMI),1,2)
		cDataQry += Subs((cQryAlias)->(VV0_DTHEMI),10,8)
		aAdd(aQuery,{ "S" , (cQryAlias)->(VV0_FILIAL) , (cQryAlias)->(VV0_NUMTRA) , cDataQry , (cQryAlias)->(VV0_OPEMOV) , stod((cQryAlias)->(VV0_DATMOV)) , (cQryAlias)->(VV0_CODCLI) , (cQryAlias)->(VV0_LOJA) })
		DBSkip()
	enddo
	( cQryAlias )->( dbCloseArea() )
endif

if "E" $ _cTipo
	cQuery := "SELECT VVF.VVF_FILIAL , VVF.VVF_TRACPA , VVF.VVF_DTHEMI , VVF.VVF_OPEMOV , VVF.VVF_DATMOV , VVF.VVF_CODFOR , VVF.VVF_LOJA "
	cQuery += "FROM "+RetSqlName("VVF")+" VVF INNER JOIN "+RetSqlName("VVG")+" VVG ON ( VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA ) "
	cQuery += "WHERE VVG.VVG_CHASSI='"+_cChassi+"' AND VVF.VVF_SITNFI<>'0' "
	cQuery += "AND VVG.D_E_L_E_T_=' ' AND VVF.D_E_L_E_T_=' ' "
	if _cOper != ""
		cQuery += "AND VVF.VVF_OPEMOV='" + _cOper + "' "
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias , .F., .T. )
	while !((cQryAlias)->(eof()))
		cDataQry := Subs((cQryAlias)->(VVF_DTHEMI),7,2)
		cDataQry += Subs((cQryAlias)->(VVF_DTHEMI),4,2)
		cDataQry += Subs((cQryAlias)->(VVF_DTHEMI),1,2)
		cDataQry += Subs((cQryAlias)->(VVF_DTHEMI),10,8)
		aAdd(aQuery,{ "E" , (cQryAlias)->(VVF_FILIAL) , (cQryAlias)->(VVF_TRACPA) , cDataQry , (cQryAlias)->(VVF_OPEMOV) , stod((cQryAlias)->(VVF_DATMOV)) , (cQryAlias)->(VVF_CODFOR) , (cQryAlias)->(VVF_LOJA) })
		DBSkip()
	enddo
	( cQryAlias )->( dbCloseArea() )
endif
If !Empty(cAlias)
	DBSelectArea(cAlias)
endif
if Len(aQuery) == 0
	return {}
endif

aSort(aQuery,,,{|x,y| x[4] > y[4] })

return aQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_VEIUMOVº Autor ³ Luis Delorme              º Data ³ 02/10/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Retorna a ultima movimentacao realizada no chassi              º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Oficina                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno  ³ [1] - "E" ou "S" - Movimentacao de Entrada ou Saida            º±±
±±º         ³ [2] - Filial da umtima movimentacao                            º±±
±±º         ³ [3] - TRACPA ou NUMTRA (dependendo do retorno [1])             º±±
±±º         ³ [4] - Operacao realizada na movimentacao (OPEMOV)              º±±
±±º         ³ [5] - Data do Movimento  (Formato de DATA)                     º±±
±±º         ³ [6] - Codigo do Cliente/Fornecedor                             º±±
±±º         ³ [7] - Loja do Cliente/Fornecedor                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FM_VEIUMOV( _cChassi , _cTipo,  _cOper )
Local aQuery := {}
aQuery := FM_VEIMOVS( _cChassi , _cTipo,  _cOper )
If len(aQuery) <= 0
	Return {}
EndIf
return { aQuery[1,1],aQuery[1,2],aQuery[1,3],aQuery[1,5],aQuery[1,6],aQuery[1,7],aQuery[1,8] }


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FORDCG3T01º Autor ³ Rogerio Vaz Melonioº Data ³  25/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Execblock para retornar descricao do produto da 1a.        º±±
±±º          ³ ocorrencia de itens adicionais no EDI de garantia.         º±±
±±º          ³ (Transmissao)                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Modulo de Oficina                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FORDCG3T01()
Local  _cDescricao := ""
If Empty(VIC->VIC_CODITE+VIC->VIC_CODSER)
	_cDescricao := LEFT(VIC->VIC_OBSERV,20)
ElseIf !Empty(VIC->VIC_CODSER)
	_cDescricao := LEFT(VIC->VIC_CODSER,20)
Else
	_cDescricao := SUBSTR(POSICIONE("SB1",7,XFILIAL("SB1")+VIC->VIC_GRUITE+VIC->VIC_CODITE,"B1_DESC"),1,20)
Endif

Return(_cDescricao)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_PESQSF1º Autor ³ Andre Luis Almeida / Rafael º Data ³ 19/09/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Pesquisa SF1 (NF Entrada) - Retorno (1-LOGICO ou 2-QTDE)         º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Concessionaria                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_PESQSF1(_cFILIAL,_cNUNNFI,_cSERNFI,_cCODFOR,_cLOJFOR,_nTip)
Local cQuery  := ""
Local cQAlSF1 := "SQLSF1"
Local nQtde   := 0
Local _Ret
Default _cFILIAL := ""  //FILIAL
Default _cNUNNFI := ""  //NUM. DOCUMENTO
Default _cSERNFI := ""  //SERIE
Default _cCODFOR := ""  //FORNECEDOR
Default _cLOJFOR := ""  //LOJA
Default _nTip    := 1  //TIPO DE RETORNO 1= .t. or .f. || 2=QTDE DE NF
cQuery := "SELECT COUNT(SF1.F1_DOC) QTDNF FROM "+RetSqlName("SF1")+" SF1 WHERE "
If !Empty(_cFilial) 										//SE A FILIAL NAO ESTIVER EM BRANCO ADICIONA NO WHERE
	cQuery += "SF1.F1_FILIAL='"+_cFilial+"' AND "
EndIf
If !Empty(_cNUNNFI)											//SE O DOCUMENTO NAO ESTIVER EM BRANCO ADICIONA NO WHERE
	cQuery += "SF1.F1_DOC='"+_cNUNNFI+"' AND "
EndIf
If !Empty(_cSERNFI)											//SE A SERIE NAO ESTIVER EM BRANCO ADICIONA NO WHERE
	cQuery += "SF1.F1_SERIE LIKE '"+_cSERNFI+"%' AND "
EndIf
If !Empty(_cCODFOR)											//SE O FORNECEDOR NAO ESTIVER EM BRANCO ADICIONA NO WHERE
	cQuery += "SF1.F1_FORNECE='"+_cCODFOR+"' AND "
EndIf
If !Empty(_cLOJFOR)											//SE A LOJA NAO ESTIVER EM BRANCO ADICIONA NO WHERE
	cQuery += "SF1.F1_LOJA='"+_cLOJFOR+"' AND "
EndIf
cQuery += "SF1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF1, .F., .T. )
If !( cQAlSF1 )->( Eof() )
	nQtde := ( cQAlSF1 )->( QTDNF )
EndIf
( cQAlSF1 )->( dbCloseArea() )
If _nTip == 1 // Retorno ( Logico )
	If nQtde > 0
		_Ret := .t. // TEM ENTRADA
	Else
		_Ret := .f. // NAO TEM ENTRADA
	EndIf
Else// _nTip == 2 // Retorno ( Numerico )
	_Ret := nQtde
EndIf
Return(_Ret)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FM_NRNFFP ³ Autor ³  Manoel / Andre       ³ Data ³ 29/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chama tela e verifica NF quando Formulario Proprio			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .F. quando estiver OK                                      ³±±
±±³          ³ .T. quando houver Problema                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function	FM_NRNFFP(_nPar)

Local	nRecF1 := SF1->(recno())
Local	nRecF2 := SF2->(recno())
Local	lProb  := .f.
Local cTipNF := GetNewPar("MV_TPNRNFS","1")

If _nPar == 1 // 1a Chamada

	lMudouNum := .f.

	While .t.

		cNumero := ""
		lOk := Sx5NumNota(@cSerie,cTipNF)
		cNota := cNumero

		if !lOk
			MsgStop(STR0050,STR0011)//Nenhuma serie de nota fiscal foi selecionada! # atencao
			Return .t.
		Endif

		lProb  := .f.
		dbSelectArea("SF1")
		dbSetOrder(1)
		If dbSeek(xFilial("SF1")+cNota+cSerie)
			While !eof() .and. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE == xFilial("SF1")+cNota+cSerie
				If SF1->F1_FORMUL == "S"
					MsgStop(STR0051,STR0011)//Numeracao de Nota Fiscal ja existente... # Atencao
					lProb := .t.
					exit
				Endif
				DbSkip()
			Enddo
		Endif
		If lProb
			Loop
		Endif
		dbSelectArea("SF2")
		dbSetOrder(1)
		if dbSeek(xFilial("SF2")+cNota+cSerie)
			MsgStop(STR0051,STR0011)//Numeracao de Nota Fiscal ja existente... # Atencao
			Loop//return .t.
		Endif
		dbSelectArea("SF1")
		DbGoTo(nRecF1)
		dbSelectArea("SF2")
		DbGoTo(nRecF2)

		exit

	Enddo

Else // 2a Chamada

	If cTipNf <> "3"
		// Se numeracao for SXE/SXF e usuario alterou numero, respeita numero do usuarop
		If cTipNf <> "2" .OR. !lMudouNum
			cNota := NxtSX5Nota(cSerie, NIL, cTipNf)
		EndIf
	Else
		If !lMudouNum	// Verifica se usuario alterou numero da nota fiscal
			cNota := Space(TamSx3("F1_DOC")[1])
		EndIf
	EndIf

Endif

Return .f.

Function BRWNOMEVV0()
Local cAlias := Alias()
Local nRecSA1 := SA1->(RecNo())
Local nRecSA2 := SA2->(RecNo())
Local cNome

if FM_PILHA("VEIXA023") .or. FM_PILHA("VEIXA025") .or. FM_PILHA("VEIXA026") .or. FM_PILHA("VEIXA027")
	cCliFor := "C"
Else
	cCliFor := ""
Endif

cCli := ""
If !(Empty(VV0->VV0_CLIFOR))
	// Vericação atual das notas
	cCli := VV0->VV0_CLIFOR
Else
	// Verificação das notas antigas
	dbSelectArea("SF2")
	dbSetOrder(1)
	if dbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
		if SF2->F2_TIPO == "B"
			cCli := "F"
		Else
			cCli := "C"
		Endif
	Endif
EndIf

if (VV0->VV0_OPEMOV $ "345" .and. Empty(cCli)) .or. (cCli == "F")
	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+VV0->VV0_CODCLI+VV0->VV0_LOJA)
	cNome :=  SA2->A2_NREDUZ
else
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)
	cNome :=  SA1->A1_NREDUZ
endif
SA1->(DBGoTo(nRecSA1))
SA1->(DBGoTo(nRecSA2))
If !Empty(cAlias)
	DBSelectArea(cAlias)
EndIf
return cNome

//

Function BRWNOMEVVF()
Local cAlias := Alias()
Local nRecSA1 := SA1->(RecNo())
Local nRecSA2 := SA2->(RecNo())
Local cNome
if VVF->VVF_OPEMOV $ "245"
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cNome :=  SA1->A1_NREDUZ
else
	DBSelectArea("SA2")
	DBSetOrder(1)
	DBSeek(xFilial("SA2")+VVF->VVF_CODCLI+VVF->VVF_LOJA)
	cNome :=  SA2->A2_NREDUZ
endif
SA1->(DBGoTo(nRecSA1))
SA1->(DBGoTo(nRecSA2))
If !Empty(cAlias)
	DBSelectArea(cAlias)
EndIf
return cNome


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEIVLDORIG³ Autor ³ Andre Luis Almeida    ³ Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se ( Titulo/NF ) foi gerado ( ORIGEM ) nos modulos  ³±±
±±³          ³ de Concessionaria                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Modulos TOTVS                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .F. quando nao foi gerado pelo Concessionaria              ³±±
±±³          ³ .T. quando foi gerado pelo Concessionaria                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVLDORIG(_nTip,_cNro,_cSer,_cFor,_cLoj)
Local lRet    := .f.
Local aArea   := {}
Local nQtde   := 0
Local cQuery  := ""
Local cQAlias := "SQLCONC"
Local ni      := 0
Default _nTip := 1  // Tipo de Pesquisa ( 1-SE1 / 2-SE2 / 3-SF2(VS1/VOO/VV0) / 4-SF1(VVF) )
Default _cNro := "" // Nro do Titulo ou NF
Default _cSer := "" // Serie NF
Default _cFor := "" // Fornecedor
Default _cLoj := "" // Loja
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias()) // SALVA ALIAS()
EndIf
Do Case
	Case _nTip == 1 // SE1 - Titulos Saida
		cQuery := "SELECT COUNT(SE1.E1_NUM) QTDE FROM "+RetSqlName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
		cQuery += "SE1.E1_NUM='"+_cNro+"' AND SE1.D_E_L_E_T_=' '"
	Case _nTip == 2 // SE2 - Titulos Entrada
		cQuery := "SELECT COUNT(SE2.E2_NUM) QTDE FROM "+RetSqlName("SE2")+" SE2 WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' AND "
		cQuery += "SE2.E2_NUM='"+_cNro+"' AND SE2.D_E_L_E_T_=' '"
	Case _nTip == 3 // SF2 - NFs Saida (VS1/VOO/VV0)
		For ni := 1 to 3
			If nQtde <= 0
				If ni == 1 // VS1
					cQuery := "SELECT COUNT(VS1.VS1_NUMNFI) QTDE FROM "+RetSqlName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND "
					cQuery += "VS1.VS1_NUMNFI='"+_cNro+"' AND VS1.VS1_SERNFI LIKE '"+_cSer+"%' AND VS1.D_E_L_E_T_=' '"
				ElseIf ni == 2 // VOO
					cQuery := "SELECT COUNT(VOO.VOO_NUMNFI) QTDE FROM "+RetSqlName("VOO")+" VOO WHERE VOO.VOO_FILIAL='"+xFilial("VOO")+"' AND "
					cQuery += "VOO.VOO_NUMNFI='"+_cNro+"' AND VOO.VOO_SERNFI LIKE '"+_cSer+"%' AND VOO.D_E_L_E_T_=' '"
				ElseIf ni == 3 // VV0
					cQuery := "SELECT COUNT(VV0.VV0_NUMNFI) QTDE FROM "+RetSqlName("VV0")+" VV0 WHERE VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
					cQuery += "VV0.VV0_NUMNFI='"+_cNro+"' AND VV0.VV0_SERNFI LIKE '"+_cSer+"%' AND VV0.D_E_L_E_T_=' '"
				EndIf
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
				If !( cQAlias )->( Eof() )
					nQtde := ( cQAlias )->( QTDE )
				EndIf
				( cQAlias )->( dbCloseArea() )
			Else
				Exit
			EndIf
		Next
	Case _nTip == 4 // SF1 - NFs Entrada (VVF)
		cQuery := "SELECT COUNT(VVF.VVF_NUMNFI) QTDE FROM "+RetSqlName("VVF")+" VVF WHERE VVF.VVF_FILIAL='"+xFilial("VVF")+"' AND "
		cQuery += "VVF.VVF_NUMNFI='"+_cNro+"' AND VVF.VVF_SERNFI LIKE '"+_cSer+"%' AND VVF.VVF_CODFOR='"+_cFor+"' AND VVF.VVF_LOJA='"+_cLoj+"' AND VVF.D_E_L_E_T_=' '"
EndCase
If _nTip # 3 // ( 1-SE1 / 2-SE2 / 4-SF1(VVF) )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	If !( cQAlias )->( Eof() )
		nQtde := ( cQAlias )->( QTDE )
	EndIf
	( cQAlias )->( dbCloseArea() )
EndIf
If len(aArea) > 0
	sRestArea(aArea) // VOLTA ALIAS()
EndIf
lRet := ( nQtde > 0 )
If lRet
	Help(" ",1,"VEIVLDORIG")
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_VEIGAR º Autor ³ Andre Luis Almeida        º Data ³ 04/05/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Verifica (mostra mensagem) se o Veiculo esta em Garantia       º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de AutoPecas e Oficina                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_VEIGAR( _cChaInt , _cChassi ,cGruIte, cCodIte, cCodSer )

Local aArea      := {}
Local cMsgGar    := ""
Local nUltKil    := 0
Local dDtPesq    := dDataBase
Local nDGExtend  := 0
Local nKGExtend  := 0
Local _cAliasAnt := Alias()

Default _cChaInt := ""
Default _cChassi := ""
Default cGruIte  := ""    //Fnc - 10252 - 19/05 - Boby
Default cCodIte  := ""
Default cCodSer  := ""

aArea := sGetArea(aArea,"VV1")
aArea := sGetArea(aArea,"VVN")
aArea := sGetArea(aArea,"VO5")
aArea := sGetArea(aArea,"VE4")
aArea := sGetArea(aArea,"VVL")
If !Empty(_cChaInt)
	DbSelectArea("VV1")
	DbSetOrder(1)
	DbSeek( xFilial("VV1") + _cChaInt )
ElseIf !Empty(_cChassi)
	DbSelectArea("VV1")
	DbSetOrder(2)
	DbSeek( xFilial("VV1") + _cChassi )
EndIf
nUltKil := FG_ULTKIL(VV1->VV1_CHAINT)
If nUltKil < VV1->VV1_KILVEI
	nUltKil := VV1->VV1_KILVEI
EndIf
DbSelectArea("VVN")
DbSetOrder(1)
If DbSeek( xFilial("VVN") + VV1->VV1_TPGREX + VV1->VV1_CODMAR + VV1->VV1_CODGAR )
	If ( (!Empty(cGruIte).Or.!Empty(cCodIte)) .And. VVN->VVN_COBPEC == "1" ) .or. ( !Empty(cCodSer) .And. VVN->VVN_COBSRV == "1" )
		nDGExtend := VVN->VVN_PRZGAR
		nKGExtend := VVN->VVN_KILGAR
	EndIf
EndIf
DbSelectArea("VO5")
DbSetOrder(1)
DbSeek( xFilial("VO5") + VV1->VV1_CHAINT )
DbSelectArea("VE4")
DbSetOrder(1)
DbSeek( xFilial("VE4") + VV1->VV1_CODMAR )
If VE4->VE4_VDAREV == "1"   		// 1 - Data da venda do veiculo
	dDtPesq := VO5->VO5_DATVEN
ElseIf VE4->VE4_VDAREV == "2"   	// 2 - Data da primeira revisao do veiculo
	dDtPesq := VO5->VO5_PRIREV
Else			 						   // 3 - Data da entrega do veiculo
	if VV1->(FieldPos("VV1_DATETG")) > 0 .and. !Empty(VV1->VV1_DATETG)
		dDtPesq := VV1->VV1_DATETG
	else
		dDtPesq := VO5->VO5_DATSAI
	endif
EndIf
DbSelectArea("VVL")
DbSetOrder(1)
DbSeek( xFilial("VVL") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD + Dtos( dDtPesq ) , .t. )
If !Bof() .and. ( VVL->VVL_FILIAL+VVL->VVL_CODMAR+VVL->VVL_MODVEI+VVL->VVL_SEGMOD # xFilial("VVL")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD .or. VVL->VVL_DATGAR > dDtPesq )
	DbSkip(-1)
EndIf
If VVL->VVL_FILIAL+VVL->VVL_CODMAR+VVL->VVL_MODVEI+VVL->VVL_SEGMOD == xFilial("VVL")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD
	// Garantia tem que verificar/atender a KM e DATA
	If ( ( VVL->VVL_KILGAR + nKGExtend ) >= nUltKil ) .and. ( ( dDtPesq + VVL->VVL_PERGAR + nDGExtend ) >= dDataBase )
		cMsgGar := STR0052+CHR(13)+CHR(10)+CHR(13)+CHR(10)//Veiculo em Garantia
		cMsgGar += STR0053+": "+Transform(nUltKil,"@E 999,999,999,999")+CHR(13)+CHR(10)//Ultima KM do Veiculo
		cMsgGar += STR0054+": "+Transform(VVL->VVL_KILGAR+nKGExtend,"@E 999,999,999,999")+CHR(13)+CHR(10)//KM final da Garantia
		cMsgGar += STR0055+": "+Transform(dDtPesq+VVL->VVL_PERGAR+nDGExtend,"@D")//Data final da Garantia
	EndIf
EndIf
If !Empty(cMsgGar)
	MsgInfo(cMsgGar,STR0052) //Veiculo em Garantia
EndIf
sRestArea(aArea)
If !Empty(_cAliasAnt)
	DbSelectArea(_cAliasAnt)
EndIf
Return(.t.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³FM_NEWBOTº Autor ³ Andre Luis Almeida / Manoelº Data ³ 28/05/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Criacao de Novos Botoes na EnchoiceBar a partir de PE          º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro³ _cPontoE  -> Nome do Ponto de Entrada                          º±±
±±º         ³ _cNomeVet -> Nome do Vetor de Botao definido no Fonte Original º±±
±±º         ³ _aParam   -> Parametros a serem enviados para o PE             º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºExempl.PE³ Local aRet := {}                                               º±±
±±º         ³ aadd(aRet,{"FILTRO",{|| U_FS_teste1()},"BOTAO1"})              º±±
±±º         ³ Return(aRet)                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ Modulo de Veiculos, AutoPecas e Oficina                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_NEWBOT(_cPontoE,_cNomeVet,_aParam)
Local aNBotAux  := {}
Local ni        := 0
Default _aParam := NIL
If ExistBlock(_cPontoE) // Manutencao da aNewBot - Definicao de Novos Botoes na EnchoiceBar
	aNBotAux := ExecBlock(_cPontoE,.f.,.f.,_aParam)
	For ni := 1 to Len(aNBotAux)
		aadd( &_cNomeVet , { aNBotAux[ni,1] , aNBotAux[ni,2] , aNBotAux[ni,3] })
	Next
Endif
Return()



/*/{Protheus.doc} X3CBOXDESC
Retorna a Descricao da Opcao selecionada no ComboBox

O parametro _aAuxOpcoes é um parametro auxiliar, sua utilização é indicada nos casos em que a função estiver dentro de um laço.
Pode-se utilizar uma variavel no programa que está chamando esta funcao e passar por referencia na chamada desta funcao.

Ex:

Local aAuxCBox := {}

While .t.
	X3CBOXDESC( <cCampo>, <cOpcao>, @aAuxCBox)
End

Neste caso, da segunda chamada em diante, não sera necessário fazer o levantamento das opções no combo


@author Rubens
@since 08/01/2019
@version 1.0
@return cRet, Descricao da Opção selecionada no Combo
@param _cCampo, characters , Campo do dicionario de dados
@param _cOpcao, characters , Opção selecionada
@param _aAuxOpcoes, array , Parametro OPCIONAL. Matriz auxiliar contendo os valores possiveis para o combo.  
@type function
/*/
Function X3CBOXDESC(_cCampo, _cOpcao, _aAuxOpcoes)

	Local cRet  := ""
	Local nPos  := 0
	Local cAuxAlias
	Local nTamChave

	Default _aAuxOpcoes := {}

	If Len(_aAuxOpcoes) == 0
		_aAuxOpcoes := X3CBOXAVET(_cCampo,"0")
	EndIf

	If Len(_aAuxOpcoes) > 0
		_cOpcao += "="
		nTamChave := Len(_cOpcao)
		If (nPos := aScan( _aAuxOpcoes, { |x| Left(x, nTamChave ) == _cOpcao } )) > 0
			cRet := SubStr( _aAuxOpcoes[nPos] , nTamChave + 1)
		EndIf
	EndIf

Return(cRet)


/*/{Protheus.doc} X3CBOXAVET
Retorna o Vetor com as opcoes do ComboBox

@author Rubens
@since 08/01/2019
@version 1.0
@return aRetOpcoes, Array contendo os valores do ComboBox
@param _cCampo, characters, Nome do campo no SX3
@param _cOpcao, characters, "1" = Cria 1o.Registro em Branco
@type function
/*/
Function X3CBOXAVET(_cCampo,_cOpcao)

	Local aRetOpcoes := {}
	Local oStru3CBox
	Local oStru2CBox
	Default _cOpcao := "0"

	cAuxAlias := Left( _cCampo, At("_", _cCampo)-1 ) // Extrai Alias do Campo
	If Len(cAuxAlias) == 2
		cAuxAlias := "S" + cAuxAlias
	EndIf

	oStru3CBox := FWFormStruct( 3, cAuxAlias , { |x| ALLTRIM(x) $ _cCampo } )
	If valtype(oStru3CBox) <> "U"
		If len(oStru3CBox) >= FORM_STRUCT_TABLE_MODEL
			If len(oStru3CBox[ FORM_STRUCT_TABLE_MODEL ]) >= 1
				If len(oStru3CBox[ FORM_STRUCT_TABLE_MODEL , 1 ]) >= MVC_MODEL_VALUES
					aRetOpcoes := oStru3CBox[ FORM_STRUCT_TABLE_MODEL , 1 , MVC_MODEL_VALUES ]
				EndIf
			EndIf
		EndIf
	EndIf
	If valtype(aRetOpcoes) == "U" .or. len(aRetOpcoes) == 0
		oStru2CBox := FWFormStruct( 2, cAuxAlias , { |x| ALLTRIM(x) $ _cCampo } )
		If valtype(oStru2CBox) <> "U"
			If len(oStru2CBox:AFIELDS) >= 1
				If len(oStru2CBox:AFIELDS[ 1 ]) >= MVC_MODEL_VALUES
					aRetOpcoes := oStru2CBox:AFIELDS[ 1 , MVC_MODEL_VALUES ]
				EndIf
			EndIf
		EndIf
	EndIf
	If valtype(aRetOpcoes) == "U"
		aRetOpcoes := {}
	EndIf
	
	If _cOpcao == "1"
		aSize(aRetOpcoes, Len(aRetOpcoes) + 1 )
		aIns(aRetOpcoes , 1)
		aRetOpcoes[1] := ""
	EndIf

Return (aClone(aRetOpcoes))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FM_PRODSBZ³ Autor³Andre Luis Almeida / Manoel ³Data³11/08/09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna as informacoes do arquivo SBZ, de acordo com refe- ³±±
±±³          ³ rencia do SB1 / SB5                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPro - Codigo do Produto                                ³±±
±±³          ³ cCampo  - Nome do campo da tabela SB1 / SB5                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Conteudo do campo da tabela SB1/SB5 ou SBZ                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_PRODSBZ(cCodPro,cCampo)
Local aArea       := GetArea()
Local nPosCpo     := at("_",cCampo)
Local cRet        := ""
Local cQuery      := ""
Local cQAlSBZ     := "SQLPRODSBZ"
Local lSBZ        := .f.
Local lConsSB1SB5 := .t. // Considera SB1/SB5 quando trabalhar com SBZ ?
Local lConsVazio  := ( GetNewPar("MV_MIL0097","N") == "S" ) // Considera conteúdo vazio dos campos da tabela SBZ como informação válida ou não considera e verifica a tabela SB1/SB5? S=Considera;N=Não Considera
Default cCodPro   := SB1->B1_COD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Checa a existencia dos dados na tabela SBZ             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ" // Trabalha com SBZ
	If SBZ->(FieldPos("BZ"+subs(cCampo,nPosCpo))) > 0 // Existe o campo no SBZ
		cQuery := "SELECT SBZ.BZ"+subs(cCampo,nPosCpo)
		cQuery += "  FROM "+RetSQLName("SBZ")+" SBZ WHERE"
		cQuery += "   SBZ.BZ_FILIAL='"+xFilial("SBZ")+"'"
		cQuery += "   AND SBZ.BZ_COD='"+cCodPro+"'"
		cQuery += "   AND SBZ.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSBZ, .F., .T. )
		If !(cQAlSBZ)->( Eof() )
			lSBZ := .t. // Encontrou registro no SBZ
			cRet := (cQAlSBZ)->(&("BZ"+subs(cCampo,nPosCpo))) // Utiliza conteudo do SBZ
		EndIf
		(cQAlSBZ)->(DbCloseArea())
	EndIf
	If subs(cCampo,nPosCpo) == "_LOCALI2" // Somente para o campo B5_LOCALI2
		If ( GetNewPar("MV_MIL0096","S") == "N" ) // A locação da peça também deve ser considerada na tabela SB5 quando o parâmetro MV_ARQPROD estiver configurado com SBZ? ( S=Considera / N=Não Considera )
			lConsSB1SB5 := .f. // NAO considera SB1/SB5 quando trabalhar com SBZ
		EndIf
	EndIf
EndIf
If lConsSB1SB5 // Considera SB1/SB5 quando trabalhar com SBZ ?
	If !lSBZ .or. ( Empty(cRet) .and. !lConsVazio ) // Nao achou SBZ  ou  ( Tem SBZ com conteudo VAZIO e esta configurado para nao considerar SBZ VAZIO )
		cRet := &cCampo // Utiliza conteudo do SB1/SB5
	EndIf
Endif
dbSelectArea("SB1")
Restarea(aArea)
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FM_PESQPARAM ³ Autor³ Rubens Takahashi       ³Data³30/09/09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAuxParam  - Nome do Parametro                             ³±±
±±³          ³ cAuxString - Conteudo a ser Pesquisado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ String                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Modulo de Veiculos, AutoPecas e Oficina                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_PESQPARAM(cAuxParam, cAuxString)
Local cConteudo := AllTrim(GetNewPar(cAuxParam,"$"))
Local cRetorno := "" , nPosIni, nPosFim

// Procura String no conteudo do Parametro
If (nPosIni := AT(cAuxString, cConteudo)) > 0
	cConteudo := SubStr(cConteudo,nPosIni,Len(cConteudo))
	nPosIni := AT("=",cConteudo)+1
	IF (nPosFim := (AT(";",cConteudo))) <= 0
		nPosFim := (Len(cConteudo)+1)
	ENDIF
	cRetorno := SubStr(cConteudo,nPosIni,nPosFim-nPosIni)
EndIf

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FM_BXSUGCOM º Autor ³ Rubens Takahashi   º Data ³  28/09/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baixa as Sugestoes de Compras geradas automaticamente nas  º±±
±±º          ³ Importacoes de OS                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_BXSUGCOM( _cPedC, _cItemPedC, _cProduto, _cLocal, _dData, _cTES, _nQtdeCompra, _cFornece, _cLoja, _cDoc, _cSerie , cLoteCTL )

Local aArea
Local nQtdeCompra

Local lProc     := .f.
Local lCtrlLote := GetNewPar("MV_RASTRO","N") == "S"

Local lAchou    := .f.
Local cSql      := ""
Local cSQLVDD   := "SQLVDD"

Local nRecNoSD1 := 0
Local nRecNoVDD := 0
Local nQtdOriSD1:= 0

Local nSlvRecD1 := SD1->(RecNo())

Default cLoteCTL:= ""

if AliasInDic("VDD")
	// verifica se a nota é de transferência
	DBSelectArea("VDD")
	DBSetOrder(6)

	cSql := "SELECT VDD.R_E_C_N_O_ FROM "+RetSQLName("VDD")+" VDD "
	cSql += "JOIN "+RetSQLName("SB1")+" SB1 ON SB1.B1_COD = '"+_cProduto+"' AND SB1.D_E_L_E_T_ = ' ' "
	cSql += "WHERE VDD.VDD_FILIAL='"+xFilial("VDD")+"' AND VDD.VDD_NUMNFI = '"+_cDoc+"' AND "
	cSql += "VDD.VDD_SERNFI = '"+_cSerie+"' AND VDD.VDD_CODFOR = '"+_cFornece+"' AND VDD.VDD_LOJA = '"+_cLoja+"' AND VDD.VDD_GRUPO = SB1.B1_GRUPO  AND VDD.VDD_CODITE = SB1.B1_CODITE AND "
	cSql += "VDD.VDD_STATUS = 'E' AND VDD.D_E_L_E_T_ = ' ' "
	nRecNoVDD := FM_SQL(cSql)

	if nRecNoVDD > 0

		VDD->(DbGoTo(nRecNoVDD))

		DBSelectArea("SB1")
		DBSetOrder(7)
		DBSeek(xFilial("SB1") + VDD->VDD_GRUPO + VDD->VDD_CODITE)
		DBSetOrder(1)

		if lCtrlLote .and. !Empty(cLoteCTL)
			cSql := "SELECT SD1.R_E_C_N_O_ RECSD1 FROM "+RetSQLName("SD1")+" SD1 WHERE SD1.D1_FILIAL='"+VDD->VDD_FILORC+"' AND SD1.D1_DOC= '"+VDD->VDD_NUMNFI+"' AND "
			cSql += "SD1.D1_SERIE = '"+VDD->VDD_SERNFI+"' AND SD1.D1_FORNECE = '"+VDD->VDD_CODFOR+"' AND SD1.D1_LOJA = '"+VDD->VDD_LOJA+"' AND SD1.D1_COD = '"+SB1->B1_COD+"' AND "
			cSql += "SD1.D1_LOTECTL = '"+cLoteCTL+"' AND SD1.D_E_L_E_T_ = ' ' "
			nRecNoSD1 := FM_SQL(cSql)
			if nRecNoSD1 > 0
				DBSelectArea("SD1")
				DbGoTo(nRecNoSD1)
				lAchou := .t.
			Endif
		Else
			DBSelectArea("SD1")
			DBSetOrder(1)
			if DBSeek(VDD->VDD_FILORC + VDD->VDD_NUMNFI + VDD->VDD_SERNFI + VDD->VDD_CODFOR + VDD->VDD_LOJA + SB1->B1_COD)
				lAchou := .t.
			Endif
		Endif

		if lAchou

			//Atualiza VDD
			cSql := "SELECT SUM(D1_QUANT) FROM "+RetSQLName("SD1")+" SD1 WHERE SD1.D1_FILIAL='"+VDD->VDD_FILORC+"' AND SD1.D1_DOC= '"+VDD->VDD_NUMNFI+"' AND "
			cSql += "SD1.D1_SERIE = '"+VDD->VDD_SERNFI+"' AND SD1.D1_FORNECE = '"+VDD->VDD_CODFOR+"' AND SD1.D1_LOJA = '"+VDD->VDD_LOJA+"' AND SD1.D1_COD = '"+SB1->B1_COD+"' AND "
			cSql += "SD1.D_E_L_E_T_ = ' ' "
			nQtdOriSD1 := FM_SQL(cSql)
			cSql := "SELECT VDD.R_E_C_N_O_ RECVDD FROM "+RetSQLName("VDD")+" VDD "
			cSql += "WHERE VDD.VDD_FILIAL='"+VDD->VDD_FILIAL+"' AND VDD.VDD_NUMNFI = '"+VDD->VDD_NUMNFI+"' AND "
			cSql += "VDD.VDD_SERNFI = '"+VDD->VDD_SERNFI+"' AND VDD.VDD_CODFOR = '"+VDD->VDD_CODFOR+"' AND VDD.VDD_LOJA = '"+VDD->VDD_LOJA+"' AND VDD.VDD_GRUPO = '"+VDD->VDD_GRUPO+"'  AND VDD.VDD_CODITE = '"+VDD->VDD_CODITE+"' AND "
			cSql += "VDD.VDD_STATUS = 'E' AND VDD.D_E_L_E_T_ = ' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), cSQLVDD , .F., .T. )
			while !(cSQLVDD)->(Eof())
				VDD->(DbGoTo((cSQLVDD)->(RECVDD)))
				if nQtdOriSD1 > 0
					If Left(VDD->VDD_NUMORC,1) <> "P"
						If !FS_VS3VDD(nQtdOriSD1)
							(cSQLVDD)->(DbSkip())
							Loop
						Endif
			  		Endif
					dbSelectArea("VDD")
					RecLock("VDD",.f.)
					VDD->VDD_STATUS := "C"
					MsUnLock()
					nQtdOriSD1 -= VDD->VDD_QUANT
				Endif
				(cSQLVDD)->(DbSkip())
			Enddo
			(cSQLVDD)->(DbCloseArea())

		Endif

	Endif
Endif

SD1->(DbGoTo(nSlvRecD1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se não for selecionado o Pedido de Compra na NF, nao processa nada...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Empty(_cPedC)
	Return
ENDIF

aArea := sGetArea(aArea,"SC7")
aArea := sGetArea(aArea,"SC1")
aArea := sGetArea(aArea,"SFJ")
aArea := sGetArea(aArea,"SF4")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se TES não movimentar estoque, nao faz nada ...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial("SF4")+_cTES)
IF SF4->F4_ESTOQUE <> "S"
	sRestArea(aArea)
	Return
ENDIF

dbSelectArea("SC7")
dbSetOrder(14) // C7_FILENT+C7_NUM+C7_ITEM

dbSelectArea("SC1")
dbSetOrder(6) // C1_FILIAL+C1_PEDIDO+C1_ITEMPED+C1_PRODUTO

dbSelectArea("SFJ")
dbSetOrder(2) // FJ_FILIAL+FJ_SOLICIT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel sera usada para controlar o saldo disponivel,        ³
//³para tentar fazer a reserva, pois sera disponibilizado somente³
//³a quantidade que estiver dando entrada                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nQtdeCompra := _nQtdeCompra

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura Pedido de Compra atendido pela Nota Fiscal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !SC7->(dbSeek(xFilial("SC7") + _cPedC + _cItemPedC))
	sRestArea(aArea)
	Return
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Pedido de Compra foi Gerado direto pela Sugestao de Compra³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFJ")
SFJ->(dbSeek(xFilial("SFJ") + _cPedC))
While !SFJ->(Eof()) .and. SFJ->FJ_SOLICIT == _cPedC .and. nQtdeCompra > 0
	IF SFJ->FJ_TIPGER == "2" .and. SFJ->FJ_FORNECE == SC7->C7_FORNECE .and. SFJ->FJ_LOJA = SC7->C7_LOJA
		FM_RESITE(_cProduto, _cLocal, SC7->C7_NUM, SC7->C7_ITEM, _dData, @nQtdeCompra, _cFornece, _cLoja, _cDoc, _cSerie, SFJ->FJ_CODIGO)
		lProc := .t.
	ENDIF
	SFJ->(dbSkip())
END

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄi
//³Procura Solicitacao de Compra que foi atendida pelo pedido ³
//³de compra selecionado na entrada                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄi
If !lProc
	SC1->(dbSeek(xFilial("SC1") + SC7->C7_NUM + SC7->C7_ITEM ))
	While !SC1->(Eof()) .and. SC1->C1_FILIAL  == xFilial("SC1") ;
		.and. SC1->C1_PEDIDO  == SC7->C7_NUM    ;
		.and. SC1->C1_ITEMPED == SC7->C7_ITEM;
		.and. nQtdeCompra > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura Sugestao de Compra que gerou a Solicitacao de Compra ³
		//³Se o campo FJ_NUMOSV nao estiver em branco o campo,          ³
		//³foi gerado pelo modulo de Oficina automaticamente            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SFJ->(dbSeek(SC1->C1_FILIAL + SC1->C1_NUM))
		While !SFJ->(Eof()) .and. SFJ->FJ_FILIAL == SC1->C1_FILIAL .and. SFJ->FJ_SOLICIT == SC1->C1_NUM .and. nQtdeCompra > 0
			IF SFJ->FJ_TIPGER == "1" //.and. !Empty(SFJ->FJ_NUMOSV)
				FM_RESITE(_cProduto, _cLocal, SC1->C1_PEDIDO, SC1->C1_ITEMPED, _dData, @nQtdeCompra, _cFornece, _cLoja, _cDoc, _cSerie, SFJ->FJ_CODIGO)
			ENDIF
			SFJ->(dbSkip())
		End

		dbSelectArea("SC1")
		dbSkip()

	END
EndIf

sRestArea(aArea)

Return

/////////////////////////////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VS3VDD º Autor ³ Renato / Manoel    º Data ³  09/11/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza VS3/VS1 de Orçamento atendido em Pedido de Transf º±±
±±º          ³ originado do Orçamento Fases                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VS3VDD(nQtdOriSD1)
Local nY        := 0
Local aVS3      := {}

Local lCtrlLote := GetNewPar("MV_RASTRO","N") == "S"
Local nQtdItem  := 0
Local cSql      := ""
Local cSQLSD1	:= "SQLSD1"
Local nQtdVS3	:= 0
Local lAtuVDD	:= .t.

Local aItemMov  := {}
Local oEst      := DMS_Estoque():New()
Local cLocOri   := ""

DBSelectArea("VS3")
DBSetOrder(2)
If DBSeek(VDD->VDD_FILORC + VDD->VDD_NUMORC + VDD->VDD_GRUPO + VDD->VDD_CODITE)

	cSql := "SELECT SUM(VS3_QTDITE) FROM "+RetSQLName("VS3")+" VS3 WHERE VS3.VS3_FILIAL='"+VDD->VDD_FILORC+"' AND VS3.VS3_NUMORC= '"+VDD->VDD_NUMORC+"' AND "
	cSql += "VS3.VS3_GRUITE = '"+VDD->VDD_GRUPO+"' AND VS3.VS3_CODITE = '"+VDD->VDD_CODITE+"' AND VS3.D_E_L_E_T_ = ' ' "
	nQtdVS3 := FM_SQL(cSql)

	SB1->(DbSetOrder(7))
	SB1->(DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
	SB1->(DbSetOrder(1))

	cSql := "SELECT SD1.R_E_C_N_O_ RECSD1 FROM "+RetSQLName("SD1")+" SD1 WHERE SD1.D1_FILIAL='"+VDD->VDD_FILORC+"' AND SD1.D1_DOC= '"+VDD->VDD_NUMNFI+"' AND "
	cSql += "SD1.D1_SERIE = '"+VDD->VDD_SERNFI+"' AND SD1.D1_FORNECE = '"+VDD->VDD_CODFOR+"' AND SD1.D1_LOJA = '"+VDD->VDD_LOJA+"' AND SD1.D1_COD = '"+SB1->B1_COD+"' AND "
	cSql += "SD1.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), cSQLSD1 , .F., .T. )

	While (cSqlSD1)->(!eof()) .and. nQtdVS3 > 0

		SD1->(DbGoTo((cSqlSD1)->(RECSD1)))
		lAtuVDD := .t.

		if lCtrlLote .and. !Empty(SD1->D1_LOTECTL) .and. VS3->(FieldPos("VS3_LOTECT"))> 0

			nSaldoLote := 0
			nQtdOri := VS3->VS3_QTDITE
			If Rastro( SB1->B1_COD )
				if Empty(VS3->VS3_LOTECT)
					lUsaVenc:= SuperGetMv('MV_LOTVENC')=='S'
					aSaldos := SldPorLote(SB1->B1_COD,VS3->VS3_LOCAL,VS3->VS3_QTDITE,NIL,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,"","",NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)
					If Len(aSaldos) == 0
						lAtuVDD := .f.
						(cSqlSD1)->(DbSkip())
						Loop
					Endif
					DbSelectArea("VS3")
					RecLock("VS3",.f.)
					VS3->VS3_LOTECT := aSaldos[1,1]
					VS3->VS3_NUMLOT := aSaldos[1,2]
					VS3->VS3_QTDITE := aSaldos[1,5]
					VS3->VS3_QTDINI := VS3->VS3_QTDITE
					VS3->VS3_VALDES := (VS3->VS3_VALDES/nQtdOri)* VS3->VS3_QTDITE
					VS3->VS3_VALTOT := (VS3->VS3_QTDITE * VS3->VS3_VALPEC)-VS3->VS3_VALDES
					MsUnLock()
				Else
					cSql := "SELECT VS3.R_E_C_N_O_ RECVS3 FROM "+RetSQLName("VS3")+" VS3 WHERE VS3.VS3_FILIAL='"+VDD->VDD_FILORC+"' AND VS3.VS3_NUMORC= '"+VDD->VDD_NUMORC+"' AND "
					cSql += "VS3.VS3_GRUITE = '"+VDD->VDD_GRUPO+"' AND VS3.VS3_CODITE = '"+VDD->VDD_CODITE+"' AND VS3.VS3_LOTECT = '"+SD1->D1_LOTECTL+"' AND VS3.D_E_L_E_T_ = ' ' "
					nRecNoVS3 := FM_SQL(cSql)
					if nRecNoVS3 == 0
						aVS3 := {}
						lUsaVenc:= SuperGetMv('MV_LOTVENC')=='S'
						aSaldos := SldPorLote(SB1->B1_COD,VS3->VS3_LOCAL,VS3->VS3_QTDITE,NIL,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,"","",NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)
						If Len(aSaldos) == 0
							lAtuVDD := .f.
							(cSqlSD1)->(DbSkip())
							Loop
						Endif
						For nY := 1 To VS3->(FCount())
							aadd(aVS3,VS3->(FieldGet(nY)))
						Next nY
						cSql := "SELECT SUM(D1_QUANT) FROM "+RetSQLName("SD1")+" SD1 WHERE SD1.D1_FILIAL='"+VDD->VDD_FILORC+"' AND SD1.D1_DOC= '"+VDD->VDD_NUMNFI+"' AND "
						cSql += "SD1.D1_SERIE = '"+VDD->VDD_SERNFI+"' AND SD1.D1_FORNECE = '"+VDD->VDD_CODFOR+"' AND SD1.D1_LOJA = '"+VDD->VDD_LOJA+"' AND SD1.D1_COD = '"+SB1->B1_COD+"' AND "
						cSql += "SD1.D_E_L_E_T_ = ' ' "
						nQtdOri := FM_SQL(cSql)
						RecLock("VS3",.T.)
						For nY := 1 To Len(aVS3)
							If !"_MSIDENT"$VS3->(FieldName(nY))
								FieldPut(nY,aVS3[nY])
							EndIf
						Next nY
						VS3->VS3_QTDITE := aSaldos[1,5]
						VS3->VS3_LOTECT := aSaldos[1,1]
						VS3->VS3_NUMLOT := aSaldos[1,2]
						VS3->VS3_QTDRES := 0
						VS3->VS3_QTDINI := VS3->VS3_QTDITE
						VS3->VS3_VALDES := (VS3->VS3_VALDES/nQtdOri)* VS3->VS3_QTDITE
						VS3->VS3_VALTOT := (VS3->VS3_QTDITE * VS3->VS3_VALPEC)-VS3->VS3_VALDES
						MsUnLock()
					Endif
				Endif
			Endif
		Endif
		//
		nQtdVS3 := nQtdVS3 - VS3->VS3_QTDITE
		//
		if lCtrlLote .and. !Empty(SD1->D1_LOTECTL)
		  	nQtdItem := VS3->VS3_QTDITE
		Else
			nQtdItem := Iif(VDD->VDD_QUANT < nQtdOriSD1,VDD->VDD_QUANT,nQtdOriSD1)
		Endif
		//
		cDocumento  := Criavar("D3_DOC")
		cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
		cDocumento	:= A261RetINV(cDocumento)

		aItensNew := {}
		aadd (aItensNew,{ cDocumento , ddatabase})

		cLocOri := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

		aItemMov := oEst:SetItemSD3(SB1->B1_COD          ,; //Código do Produto
									SD1->D1_LOCAL        ,; // Armazém de Origem
									GetMv( "MV_RESITE" ) ,; // Armazém de Destino
									cLocOri              ,; // Localização Origem
									GetMv( "MV_RESLOC" ) ,; // Localização Destino
									nQtdItem             ,; // Qtd a transferir
									SD1->D1_LOTECTL       ) // Nro de lote

		aAdd(aItensNew, aClone(aItemMov))

		If (ExistBlock("VFUNB3"))
			aItensNew := ExecBlock("VFUNB3", .f., .f., {aItensNew})
		EndIf

		lMsErroAuto := .f.

		MSExecAuto({|x| MATA261(x)},aItensNew)
		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			(cSqlSD1)->(DbCloseArea())
			Return .f.
		EndIf
		MsUnLock()

		cRecNo := VS1->(Recno())
		DBSelectArea("VS1")
		DBSetOrder(1)
		if DBSeek(VDD->VDD_FILORC + VDD->VDD_NUMORC)
			RecLock("VS1",.f.)
			VS1->VS1_STARES := "1"
			MsUnLock()
		Endif
		VS1->(DbGoTo(cRecNo))

		dbSelectArea("VS3")
		RecLock("VS3",.f.)
		VS3->VS3_QTDTRA -= nQtdItem
		VS3->VS3_QTDRES += nQtdItem
		VS3->VS3_DOCSDB := cDocumento
		MsUnLock()
		// Atualiza a Qtde Aguardada / VS3_QTDTRA
		If lCtrlLote .and. !Empty(SD1->D1_LOTECTL)
			TCSQLEXEC("UPDATE "+RetSQLName("VS3")+" SET VS3_QTDTRA =  "+cValtoChar(VS3->VS3_QTDTRA)+" WHERE VS3_FILIAL='"+VDD->VDD_FILORC+"' AND VS3_NUMORC= '"+VDD->VDD_NUMORC+"' AND VS3_GRUITE = '"+VDD->VDD_GRUPO+"' AND VS3_CODITE = '"+VDD->VDD_CODITE+"' AND D_E_L_E_T_ = ' ' ")
		Endif
		//
		(cSqlSD1)->(DbSkip())
		//
	Enddo
	(cSqlSD1)->(DbCloseArea())
Endif
Return lAtuVDD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FM_RESITE º Autor ³ Rubens Takahashi   º Data ³  04/10/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Registra a Reserva do Item na Entrada da Nota Fiscal de    º±±
±±º          ³ Entrada                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_RESITE(_cProduto, _cLocal, _cPedC, _cItemPedC, _cDtDigit, _nQtdeCompra, _cFornece, _cLoja, _cDoc, _cSerie, _cSugCom)

Local lReserva := ( GetNewPar("MV_RITEORC","N") == "S" )
Local aArea, nSaldo, nQtdeRes, cSugCompra
Local cQuery, cQueryTmp

Local cOriReqAnt := ""
Local cForPedAnt := ""
Local cDocumento := ""

Local lVSJSUGCOM := (VSJ->(FieldPos("VSJ_SUGCOM")) <> 0)
Local nRecVSJ    := 0

Local aItemMov := {}
Local oEst     := DMS_Estoque():New()

Private lMsErroAuto := .f.

aArea := sGetArea(aArea,"SB1")
aArea := sGetArea(aArea,"SB2")
aArea := sGetArea(aArea,"SB5")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

dbSelectArea("VE6")
dbSetOrder(4) // VE6_INDREG + VE6_CODIGO + VE6_GRUITE + VE6_CODITE

dbSelectArea("VSJ")
dbSetOrder(1) // VSJ_NUMOSV+VSJ_GRUITE+VSJ_CODITE

dbSelectArea("SB1")
dbSetOrder(1) // B1_COD
dbSeek(xFilial("SB1")+_cProduto)

dbSelectArea("SB2")
dbSetOrder(1) // B2_COD+B2_LOCAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um cursor com os registros que sofrerão alteracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT VE6.R_E_C_N_O_ NUMREG, VE6_NUMOSV, VE6_NUMORC, VE6_PEDCOM, VE6_ITEMPC"
cQuery += "  FROM "+RetSQLName("VE6")+" VE6"
cQuery += " WHERE VE6_FILIAL = '" + xFilial("VE6") + "'"
cQuery += "   AND VE6_SUGCOM = '" + _cSugCom + "'"
cQuery += "   AND VE6_GRUITE = '" + SB1->B1_GRUPO + "'"
cQuery += "   AND VE6_CODITE = '" + SB1->B1_CODITE + "'"
cQuery += "   AND VE6_INDREG IN ('0', '4')"  // S O M E N T E   C O M P R A
cQuery += "   AND (VE6_NUMORC <> ' ' OR VE6_NUMOSV <> ' ')" // Deve possuir numero de Orcamento ou OS
cQuery += "   AND VE6.D_E_L_E_T_ = ' '"
cQuery += "  ORDER BY R_E_C_N_O_"
TCQUERY cQuery NEW ALIAS "TVE6"
dbSelectArea("TVE6")
While !TVE6->(Eof())

	dbSelectArea("VE6")
	VE6->(dbGoTo(TVE6->NUMREG))

	If OX001020B_RetornaStatusOrcamento(VE6->VE6_ORIREQ,If(VE6->VE6_ORIREQ == "2",VE6->VE6_NUMOSV,VE6->VE6_NUMORC),VE6->VE6_GRUITE,VE6->VE6_CODITE) == "C" // se status for igual a cancelado, deve armazenar no padrão
		TVE6->(dbSkip())
		Loop
	Endif
	
	Do Case
		// Verifica origem da Sugestao de Compra //
		// Orcamento de BALCAO                   //
		Case VE6->VE6_ORIREQ == "1" .OR. VE6->VE6_ORIREQ == "3" /* Backorder */

			VS1->(dbSetOrder(1))
			If !VS1->(dbSeek( xFilial("VS1") + VE6->VE6_NUMORC ))
				TVE6->( dbCloseArea() )
				sRestArea(aArea)
				Return
			EndIf

			// Verifica origem da Sugestao de Compra //
			// OFICINA                               //
		Case VE6->VE6_ORIREQ == "2"

			VO1->(dbSetOrder(1)) // VO1_NUMOSV

			// Posiciona na OS para verificar se ainda precisa fazer a reserva
			IF !VO1->(dbSeek(xFilial("VO1") + VE6->VE6_NUMOSV ))
				TVE6->( dbCloseArea() )
				sRestArea(aArea)
				Return
			ENDIF
	EndCase

	// Se tiver a quantidade necessaria ...
	IF VE6->VE6_QTDITE <> VE6->VE6_QTDATE

		nQtdeRes := (VE6->VE6_QTDITE - VE6->VE6_QTDATE)

		// RESERVA PARCIAL
		IF nQtdeRes > _nQtdeCompra
			nQtdeRes := _nQtdeCompra
		ENDIF

		// Calcula o Saldo em que foi dada entrada da nota fiscal
		// para verificar se possui saldo para fazer a reserva do item
		SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+_cLocal))
		nSaldo := SaldoSB2()

		// Qtde que foi solicitado a compra.
		// Se nao tiver saldo total, nao reserva nada
		IF nQtdeRes > nSaldo
			nQtdeRes := nSaldo
		ENDIF

		// Atualiza o Registro de Ocorrencia de Sug. de Compra
		dbSelectArea("VE6")
		RecLock("VE6" ,.F.)
		VE6->VE6_PEDCOM := _cPedC
		VE6->VE6_ITEMPC := _cItemPedC
		VE6->VE6_DATATE := _cDtDigit
		VE6->VE6_CODFOR := _cFornece
		VE6->VE6_LOJFOR := _cLoja
		//VE6->VE6_SERNFI := _cSerie
		//VE6->VE6_NUMNFI := _cDoc
		VE6->VE6_QTDATE += nQtdeRes
		cSugCompra := VE6->VE6_SUGCOM
		MsUnLock()
		//

		Do Case
			// Verifica origem da Sugestao de Compra //
			// Orcamento de BALCAO                   //
			Case VE6->VE6_ORIREQ == "1" .OR. VE6->VE6_ORIREQ == "3" /* Backorder */
			/*
			 Alex - 25/10/2021 - Não é mais necessário verificar se está na fase de reserva; durante a entrada de peças, no
			 momento da criação da sugestão de compras, as peças são reservadas incondicionalmente, ignorando o parâmetro MV_FASEORC
			*/
				cOriReqAnt := VE6->VE6_ORIREQ
				cForPedAnt := VE6->VE6_FORPED

				VS3->(dbSetOrder(2))
				IF VS3->(dbSeek(xFilial("VS3") + VS1->VS1_NUMORC + SB1->B1_GRUPO + SB1->B1_CODITE))
					While !VS3->(eof()) .and. xFilial("VS3") + VS1->VS1_NUMORC + SB1->B1_GRUPO + SB1->B1_CODITE == VS3->VS3_FILIAL + VS3->VS3_NUMORC + VS3->VS3_GRUITE + VS3->VS3_CODITE
						If VS3->VS3_QTDAGU == 0
							VS3->(DbSkip())
							Loop
						Else
							Exit
						Endif
					Enddo
				Else
					TVE6->( dbCloseArea() )
					sRestArea(aArea)
					Return
				ENDIF

				// Se a qtde disponivel para reserva for maior do que a qtde aguardada, acerta a quantidade a ser reservada ...
				If nQtdeRes > VS3->VS3_QTDAGU
					nQtdeRes := VS3->VS3_QTDAGU
				EndIf

				// Atualiza saldo a ser reservado
				_nQtdeCompra -= nQtdeRes

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gera um registro de reserva de estoque³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("VE6")
				RecLock("VE6" , .T. )
				VE6->VE6_FILIAL := xFilial("VE6")
				VE6->VE6_DATREG := Criavar("VE6_DATREG")
				VE6->VE6_HORREG := Criavar("VE6_HORREG")
				VE6->VE6_CODUSU := Criavar("VE6_CODUSU")
				VE6->VE6_NUMORC := VS3->VS3_NUMORC
				VE6->VE6_GRUITE := VS3->VS3_GRUITE
				VE6->VE6_CODITE := VS3->VS3_CODITE
				VE6->VE6_LOTECT := SD1->D1_LOTECTL
				VE6->VE6_NUMLOT := SD1->D1_NUMLOTE
				VE6->VE6_ORIREQ := cOriReqAnt
				VE6->VE6_DESORI := IIF(cOriReqAnt == "3", "BACKORDER", "COMPRAS")
				VE6->VE6_CODMAR := Posicione("SBM",1, xFilial("SBM")+VS3->VS3_GRUITE,"SBM->BM_CODMAR")
				VE6->VE6_INDREG := "3" // Reserva de Itens
				VE6->VE6_FORPED := cForPedAnt
				VE6->VE6_SUGCOM := cSugCompra
				VE6->VE6_CODIGO := CriaVar("VE6_CODIGO")
				VE6->VE6_PEDCOM := _cPedC
				VE6->VE6_ITEMPC := _cItemPedC
				VE6->VE6_CODFOR := _cFornece
				VE6->VE6_LOJFOR := _cLoja
				VE6->VE6_SERNFI := _cSerie
				If FieldPos('VE6_SDOC') > 0
					VE6->VE6_SDOC := FGX_UFSNF(_cSerie)
				EndIf
				VE6->VE6_NUMNFI := _cDoc
				VE6->VE6_QTDITE += nQtdeRes
				MsUnLock()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Movimentacao interna do Item                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aItensNew:={}
				DbSelectArea("SB5")
				DbSetOrder(1)
				DbSeek( xFilial("SB5") + SB1->B1_COD )
				DbSelectArea("SB1")
				DbSetOrder(1)

				cDocumento := nextnumero("SD3",2,"D3_DOC",.t.)
				// Adiciona cabecalho com numero do documento e data da transferencia modelo II
				aadd (aItensNew,{ cDocumento, ddatabase})
				// sequencia
				// produto, descricao, unidade de medida,
				// local/localizacao O R I G E M
				// produto, descricao, unidade de medida,
				// local/localizacao D E S T I N O
				// numero de serie, lote, sublote, data de validade,
				// Q U A N T I D A D E
				// quantidade na 2 unidade, estorno, numero de sequencia

				aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //Código do Produto
											_cLocal         ,; // Armazém de Origem
											GetMv( "MV_RESITE" ) ,; // Armazém de Destino
											FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") ,; // Localização Origem
											GetMv( "MV_RESLOC" ) ,; // Localização Destino
											nQtdeRes        ,; // Qtd a transferir
											SD1->D1_LOTECTL ,; // Nro de lote
											SD1->D1_NUMLOTE  ) // Nro de Sub-Lote)

				aAdd(aItensNew, aClone(aItemMov))

				If (ExistBlock("VFUNB4"))
					aItensNew := ExecBlock("VFUNB4", .f., .f., {aItensNew})
				EndIf

				MSExecAuto({|x| MATA261(x)},aItensNew)
				If lMsErroAuto
					TVE6->( dbCloseArea() )
					MOSTRAERRO()
					sRestArea(aArea)
					Return
				EndIf
				MsUnLock()

				// Atualiza a Qtde Aguardada
				dbSelectArea("VS3")
				RecLock("VS3",.f.)
				VS3->VS3_QTDAGU -= nQtdeRes
				VS3->VS3_QTDRES += nQtdeRes
				VS3->VS3_RESERV := "1"
				VS3->VS3_LOTECT := VE6->VE6_LOTECT
				VS3->VS3_NUMLOT := VE6->VE6_NUMLOT
				VS3->VS3_DOCSDB := cDocumento
				MsUnLock()

				// Verifica origem da Sugestao de Compra //
				// OFICINA                               //
			Case VE6->VE6_ORIREQ == "2"


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Reserva o Item se a OS estiver ABERTA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lReserva .and. VO1->VO1_STATUS == 'A'

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Procura o registro de peca em espera para aplicacao³
					//³Se nao achar, provavelmente ja foi requisitado tudo³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery := "SELECT R_E_C_N_O_ "
					cQuery += "  FROM "+RetSQLName("VSJ")
					cQuery += " WHERE VSJ_FILIAL = '" + xFilial("VSJ") + "'"
					cQuery += "   AND VSJ_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
					cQuery += "   AND VSJ_GRUITE = '" + SB1->B1_GRUPO + "'"
					cQuery += "   AND VSJ_CODITE = '" + SB1->B1_CODITE + "'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					cQueryTmp := ""
					If lVSJSUGCOM
						cQueryTmp := " AND VSJ_SUGCOM = '" + cSugCompra + "'"
					EndIf
					nRecVSJ := FM_SQL(cQuery+cQueryTmp)
					If nRecVSJ == 0 .and. lVSJSUGCOM // Não encontrado, procurar com Sugestao de Compras em Branco ( registros antigos )
						cQueryTmp := " AND VSJ_SUGCOM = ' '" // Procurar registro antigo ( esta com o campo em branco )
						nRecVSJ := FM_SQL(cQuery+cQueryTmp)
					EndIf
					If nRecVSJ == 0 // !VSJ->(dbSeek(xFilial("VSJ") + VO1->VO1_NUMOSV + SB1->B1_GRUPO + SB1->B1_CODITE))
						TVE6->( dbCloseArea() )
						sRestArea(aArea)
						Return
					EndIf

					// Atualiza saldo a ser reservado
					_nQtdeCompra -= nQtdeRes

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Indica que as pecas foram reservadas³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("VSJ")
					DbGoto(nRecVSJ)
					RecLock("VSJ",.f.)
					VSJ->VSJ_RESPEC := "1"
					MsUnLock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Gera um registro de reserva de estoque³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("VE6")
					RecLock("VE6" , .T. )
					VE6->VE6_FILIAL := xFilial("VE6")
					VE6->VE6_DATREG := Criavar("VE6_DATREG")
					VE6->VE6_HORREG := Criavar("VE6_HORREG")
					VE6->VE6_CODUSU := Criavar("VE6_CODUSU")
					VE6->VE6_CODITE := VSJ->VSJ_CODITE
					VE6->VE6_ORIREQ := "3"
					VE6->VE6_DESORI := "COMPRAS"
					VE6->VE6_CODMAR := Posicione("SBM",1, xFilial("SBM")+VSJ->VSJ_GRUITE,"SBM->BM_CODMAR")
					VE6->VE6_GRUITE := VSJ->VSJ_GRUITE
					VE6->VE6_INDREG := "3" // Reserva de Itens
					VE6->VE6_LOTECT := VSJ->VSJ_LOTECT
					VE6->VE6_NUMLOT := VSJ->VSJ_NUMLOT
					VE6->VE6_NUMOSV := VSJ->VSJ_NUMOSV
					VE6->VE6_NUMSER := VSJ->VSJ_NUMSER
					VE6->VE6_SUGCOM := cSugCompra
					VE6->VE6_CODIGO := CriaVar("VE6_CODIGO")
					VE6->VE6_PEDCOM := _cPedC
					VE6->VE6_ITEMPC := _cItemPedC
					VE6->VE6_CODFOR := _cFornece
					VE6->VE6_LOJFOR := _cLoja
					VE6->VE6_SERNFI := _cSerie
					If FieldPos('VE6_SDOC') > 0
						VE6->VE6_SDOC := FGX_UFSNF(_cSerie)
					EndIf
					VE6->VE6_NUMNFI := _cDoc

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se a qtde no VSJ for menor do q a qtde da sugestao, reserva a qtde da VSJ    ³
					//³Isso acontece quando requisitar e devolver antes atender a SUGESTAO DE COMPRA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					VE6->VE6_QTDITE += IIf( nQtdeRes > VSJ->VSJ_QTDITE , VSJ->VSJ_QTDITE , nQtdeRes)
					MsUnLock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Movimentacao interna do Item                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aItensNew:={}
					DbSelectArea("SB5")
					DbSetOrder(1)
					DbSeek( xFilial("SB5") + SB1->B1_COD )
					DbSelectArea("SB1")
					DbSetOrder(1)
					cDocumento := nextnumero("SD3",2,"D3_DOC",.t.)
					// Adiciona cabecalho com numero do documento e data da transferencia modelo II
					aadd (aItensNew,{ cDocumento, ddatabase})
					// sequencia
					// produto, descricao, unidade de medida,
					// local/localizacao O R I G E M
					// produto, descricao, unidade de medida,
					// local/localizacao D E S T I N O
					// numero de serie, lote, sublote, data de validade,
					// Q U A N T I D A D E
					// quantidade na 2 unidade, estorno, numero de sequencia

					aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //Código do Produto
												_cLocal         ,; // Armazém de Origem
												GetMv( "MV_RESITE" ) ,; // Armazém de Destino
												FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") ,; // Localização Origem
												GetMv( "MV_RESLOC" ) ,; // Localização Destino
												nQtdeRes        ,; // Qtd a transferir
												VSJ->VSJ_LOTECT ,; // Nro de lote
												VSJ->VSJ_NUMLOT ,; // Nro de Sub-Lote
												VSJ->VSJ_NUMSER  ) // Nro de Série

					aAdd(aItensNew, aClone(aItemMov))

					If (ExistBlock("VFUNB5"))
						aItensNew := ExecBlock("VFUNB5", .f., .f., {aItensNew})
					EndIf

					MSExecAuto({|x| MATA261(x)},aItensNew)
					If lMsErroAuto
						TVE6->( dbCloseArea() )
						MOSTRAERRO()
						sRestArea(aArea)
						Return
					EndIf
					MsUnLock()
				ENDIF

		EndCase
	ENDIF

	TVE6->(dbSkip())

End

TVE6->(dbCloseArea())
dbSelectArea("VE6")
sRestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FM_ESTRESITE  ºAutor³ Rubens Takahashi    º Data ³ 02/10/09º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorna a reserva automatica e a baixa da sugestao de      º±±
±±º          ³ compra                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_ESTRESITE(_cProduto, _cLocal, _cTES, _cPedC, _cItemPedC, _cForn, _cLoja, _cSerie, _cDoc)

Local aArea := {}, aItensNew
Local nQtdEstorno, cQuery, nSaldoResv

Local nTamAEstq := 0
Local nPosAEstq
Local nUltPos
Local oPeca     := DMS_Peca():New()
Local l261IntWMS := a261IntWMS()

Private lMsErroAuto := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao foi informado o pedido, nao fez reserva³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Empty(_cPedC)
	Return .t.
ENDIF

dbSelectArea("SF4")
dbSetOrder(1)
IF !SF4->(dbSeek(xFilial("SF4") + _cTES))
	Return .t.
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TES não movimenta estoque, nao faz nada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF SF4->F4_ESTOQUE <> "S"
	Return .t.
ENDIF

///////////////////////////////////////////////////
// Posicoes no Vetor de Integracao com o MATA261 //
///////////////////////////////////////////////////
nTamAEstq := 21
If l261IntWMS
	nTamAEstq += 1
EndIf
nTamAEstq += 1
If SD3->(FieldPos("D3_IDDCF"))>0 .And. l261IntWMS
	nTamAEstq += 1
EndIf
If SD3->(FieldPos("D3_OBSERVA")) <> 0
	nTamAEstq += 1
EndIf
///////////////////////////////////////////////////

aArea := sGetArea(aArea,"SB1")
aArea := sGetArea(aArea,"SB2")
aArea := sGetArea(aArea,"SB5")
aArea := sGetArea(aArea,"SF4")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+_cProduto)
oPeca:LoadB1()

dbSelectArea("VE6")
dbSetOrder(6) // VE6_FILIAL+VE6_PEDCOM+VE6_ITEMPC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um cursor com os registros que sofrerão alteracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT VE6.R_E_C_N_O_ NUMREG, VE6_NUMOSV, VE6_NUMORC, VE6_PEDCOM, VE6_ITEMPC"
cQuery += "  FROM "+RetSQLName("VE6")+" VE6"
cQuery += " WHERE VE6_FILIAL = '" + xFilial("VE6") + "'"
cQuery += "   AND VE6_PEDCOM = '" + _cPedC + "'"
cQuery += "   AND VE6_ITEMPC = '" + _cItemPedC + "'"
cQuery += "   AND VE6_CODFOR = '" + _cForn + "'"
cQuery += "   AND VE6_LOJFOR = '" + _cLoja + "'"
cQuery += "   AND VE6_SERNFI LIKE '" + _cSerie + "%'"
cQuery += "   AND VE6_NUMNFI = '" + _cDoc + "'"
cQuery += "   AND VE6_INDREG IN ('3', '4') "  // S O M E N T E   R E S E R V A e Bo
cQuery += "   AND VE6.D_E_L_E_T_ = ' '"
cQuery += "  ORDER BY VE6_NUMOSV, VE6_NUMORC, VE6_ORIREQ"
TCQUERY cQuery NEW ALIAS "TVE6"
dbSelectArea("TVE6")
While !TVE6->(Eof())

	dbSelectArea("VE6")
	VE6->(dbGoTo(TVE6->NUMREG))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estorna somente a dif. entre a qtde reservada e a qtde nao atendida,      ³
	//³pois o que tiver sido atendido, deve ser devolvido antes de excluir a nota³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdEstorno := VE6->VE6_QTDITE - VE6->VE6_QTDATE

	IF nQtdEstorno > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Movimentacao interna do Item                                         ³
		//³Estorna movimento, voltando a peca do almox. de reserva para o almox.³
		//³que foi dado entrada a nota fiscal                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aItensNew:={}
		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )
		DbSelectArea("SB1")
		DbSetOrder(1)
		// Adiciona cabecalho com numero do documento e data da transferencia modelo II
		aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
		// sequencia
		// produto, descricao, unidade de medida,
		// local/localizacao O R I G E M
		// produto, descricao, unidade de medida,
		// local/localizacao D E S T I N O
		// numero de serie, lote, sublote, data de validade,
		// Q U A N T I D A D E
		// quantidade na 2 unidade, estorno, numero de sequencia
		AADD( aItensNew , Array(nTamAEstq) )
		nPosAEstq := Len(aItensNew)
		// Produto Origem
		aItensNew[ nPosAEstq , 01 ] := SB1->B1_COD
		aItensNew[ nPosAEstq , 02 ] := SB1->B1_DESC
		aItensNew[ nPosAEstq , 03 ] := SB1->B1_UM
		aItensNew[ nPosAEstq , 04 ] := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
		aItensNew[ nPosAEstq , 05 ] := IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_RESLOC"))),Space(15))
		// Produto Destino
		aItensNew[ nPosAEstq , 06 ] := SB1->B1_COD
		aItensNew[ nPosAEstq , 07 ] := SB1->B1_DESC
		aItensNew[ nPosAEstq , 08 ] := SB1->B1_UM
		aItensNew[ nPosAEstq , 09 ] := _cLocal
		aItensNew[ nPosAEstq , 10 ] := IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),Space(15))
		//
		aItensNew[ nPosAEstq , 11 ] := VE6->VE6_NUMSER
		aItensNew[ nPosAEstq , 12 ] := VE6->VE6_LOTECT
		aItensNew[ nPosAEstq , 13 ] := VE6->VE6_NUMLOT
		aItensNew[ nPosAEstq , 14 ] := IIf( !Empty(VE6->VE6_LOTECT) , oPeca:LoteDtValid(VE6->VE6_LOTECT) , criavar('D3_DTVALID') )
		aItensNew[ nPosAEstq , 15 ] := criavar('D3_POTENCI')
		aItensNew[ nPosAEstq , 16 ] := nQtdEstorno
		aItensNew[ nPosAEstq , 17 ] := criavar("D3_QTSEGUM")
		aItensNew[ nPosAEstq , 18 ] := criavar("D3_ESTORNO")
		aItensNew[ nPosAEstq , 19 ] := criavar("D3_NUMSEQ")
		aItensNew[ nPosAEstq , 20 ] := criavar("D3_LOTECTL")
		aItensNew[ nPosAEstq , 21 ] := aItensNew[ nPosAEstq , 14 ]
		nUltPos := 21
		If l261IntWMS
			aItensNew[nPosAEstq,++nUltPos] := criavar("D3_SERVIC")
		EndIf
		aItensNew[nPosAEstq,++nUltPos] := criavar("D3_ITEMGRD")
		If SD3->(FieldPos("D3_IDDCF"))>0 .And. l261IntWMS
			aItensNew[nPosAEstq,++nUltPos] := criavar("D3_IDDCF")
		EndIf
		If SD3->(FieldPos("D3_OBSERVA")) <> 0
			aItensNew[nPosAEstq,++nUltPos] := criavar("D3_OBSERVA")
		EndIf

		If (ExistBlock("VFUNB6"))
			aItensNew := ExecBlock("VFUNB6", .f., .f., {aItensNew})
		EndIf

		MSExecAuto({|x| MATA261(x)},aItensNew)
		If lMsErroAuto
			&& Cancela Gravacao
			&& Verificar com sera feita o rollback da trasancao principal
			sRestArea(aArea)
			TVE6->( dbCloseArea() )
			MOSTRAERRO()
			Return
		EndIf
		MsUnLock()

	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui Reserva do Item³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VE6")
	RecLock("VE6",.F.)
	VE6->VE6_SUGCOM := ""
	VE6->VE6_CODIGO := ""
	VE6->VE6_PEDCOM := ""
	VE6->VE6_ITEMPC := ""
	VE6->VE6_CODFOR := ""
	VE6->VE6_LOJFOR := ""
	VE6->VE6_SERNFI := ""
	If FieldPos('VE6_SDOC') > 0
		VE6->VE6_SDOC := ""
	EndIf
	VE6->VE6_NUMNFI := ""
	VE6->VE6_QTDEST += nQtdEstorno
	MsUnLock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a Qtde Estornada para alterar o reg. de Sug. de COMPRA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdEstorno := VE6->VE6_QTDITE

	RecLock("VE6" ,.F. ,.T.)
	VE6->VE6_DATEXC:=dDataBase
	VE6->VE6_HOREXC:=Val(Substr(Time(),1,2)+Substr(Time(),4,2))
	VE6->VE6_USUEXC:=__cUserID
	VE6->(dbDelete())
	MsUnLock()

	// Reserva de Orcamento de Balcao
	If !Empty(VE6->VE6_NUMORC)

		VS1->(dbSetOrder(1))
		If !VS1->(dbSeek( xFilial("VS1") + VE6->VE6_NUMORC ))
			TVE6->( dbCloseArea() )
			sRestArea(aArea)
			Return
		EndIf

		VS3->(dbSetOrder(2))
		IF !VS3->(dbSeek(xFilial("VS3") + VS1->VS1_NUMORC + VE6->VE6_GRUITE + VE6->VE6_CODITE))
			TVE6->( dbCloseArea() )
			sRestArea(aArea)
			Return
		ENDIF

		// Atualiza a Qtde Aguardada
		dbSelectArea("VS3")
		RecLock("VS3",.f.)
		VS3->VS3_QTDAGU += nQtdEstorno
		VS3->VS3_QTDRES -= nQtdEstorno
		MsUnLock()
		//

		// Reserva de Ordem de Servico de Oficina
	ElseIf !Empty(VE6->VE6_NUMOSV)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao tiver mais saldo de reserva, deve marcar registro³
		//³de peca em espera como nao reservado                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF FM_SALDORESV(VE6->VE6_GRUITE, VE6->VE6_CODITE, VE6->VE6_NUMOSV) == 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura o registro de peca em espera para aplicacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF VSJ->(dbSeek(xFilial("VSJ") + VE6->VE6_NUMOSV + SB1->B1_GRUPO + SB1->B1_CODITE))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Marca peca como não reservada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("VSJ")
				RecLock("VSJ", .F. )
				VSJ->VSJ_RESPEC := "0"
				MsUnLock()
			ENDIF

		ENDIF
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o registro de sugestao de compra³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Empty(TVE6->VE6_PEDCOM) .and. !Empty(TVE6->VE6_ITEMPC)

		dbSelectArea("VE6")
		dbSeek(xFilial("VE6")+TVE6->VE6_PEDCOM+TVE6->VE6_ITEMPC)

		While !VE6->(Eof()) .and. VE6->VE6_FILIAL == xFilial("VE6");
			.and. VE6->VE6_PEDCOM == TVE6->VE6_PEDCOM;
			.and. VE6->VE6_ITEMPC == TVE6->VE6_ITEMPC

			// Sugestao de Compra ...
			If VE6->VE6_INDREG <> "0"
				VE6->(dbSkip())
				Loop
			EndIf

			// Verifica origem da Sugestao de Compra //
			// Orcamento de BALCAO                   //
			Do Case
				Case VE6->VE6_ORIREQ == "1"

					// Sug. de Compra
					IF VE6->VE6_NUMORC == TVE6->VE6_NUMORC
						dbSelectArea("VE6")
						RecLock("VE6",.F.)
						VE6->VE6_QTDATE -= nQtdEstorno
					ENDIF

					// Verifica origem da Sugestao de Compra //
					// OFICINA                               //
				Case VE6->VE6_ORIREQ == "2"

					// Sug. de Compra
					IF VE6->VE6_NUMOSV == TVE6->VE6_NUMOSV
						dbSelectArea("VE6")
						RecLock("VE6",.F.)
						VE6->VE6_QTDATE -= nQtdEstorno
					ENDIF

			EndCase

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Estornada toda a qtde atendida³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF VE6->VE6_QTDATE == 0
				VE6->VE6_PEDCOM := ""
				VE6->VE6_ITEMPC := ""
				VE6->VE6_CODFOR := ""
				VE6->VE6_LOJFOR := ""
				VE6->VE6_SERNFI := ""
				If FieldPos('VE6_SDOC') > 0
					VE6->VE6_SDOC := ""
				EndIf
				VE6->VE6_NUMNFI := ""
				VE6->VE6_DATATE := CtoD(" ")
			ENDIF
			MsUnLock()

			VE6->(dbSkip())
		End
	ENDIF

	TVE6->(dbSkip())

End

TVE6->(dbCloseArea())
dbSelectArea("SF4")
sRestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FM_CHKDNFE  ºAutor ³ Rubens Takahashi     º Data ³10/09/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se é possivel excluir a Nota Fiscal de Entrada    º±±
±±º          ³ Se a reserva do item ja foi baixada não sera possivel      º±±
±±º          ³ excluir a nota antes de devolver os itens para o almoxari- º±±
±±º          ³ do de reserva (MV_RESITE)                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_CHKDNFE( _cDoc, _cSerie, _cForn, _cLoja )

Local lRetorno   := .t.
Local aArea := GetArea()
Local cMsgErro := ""
Local cQuery

cQuery := "SELECT VE6_ORIREQ, VE6_NUMORC, VE6_NUMOSV, VE6_GRUITE, VE6_CODITE, "
cQuery +=  " SUM(VE6_QTDITE - VE6_QTDEST - (VE6_QTDATE - VE6_QTDDEV)) SALDO"
cQuery +=  " FROM "+RetSQLName("SD1")+" D1, "+RetSQLName("VE6")+" VE6"
cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"'"
cQuery +=   " AND D1_FORNECE = '"+_cForn+"'"
cQuery +=   " AND D1_LOJA = '"+_cLoja+"'"
cQuery +=   " AND D1_SERIE = '"+_cSerie+"'"
cQuery +=   " AND D1_DOC = '"+_cDoc+"'"
cQuery +=   " AND D1_PEDIDO <> '"+Space(TamSx3("D1_PEDIDO")[1])+"'" // Se nao for informado o pedido, nao foi feito reserva
cQuery +=   " AND D1.D_E_L_E_T_ = ' '"
cQuery +=   " AND VE6_FILIAL = '"+xFilial("VE6")+"'"
cQuery +=   " AND VE6_PEDCOM = D1.D1_PEDIDO"
cQuery +=   " AND VE6_ITEMPC = D1.D1_ITEMPC"
cQuery +=   " AND VE6_SERNFI = D1.D1_SERIE"
cQuery +=   " AND VE6_NUMNFI = D1.D1_DOC"
cQuery +=   " AND VE6_CODFOR = D1.D1_FORNECE"
cQuery +=   " AND VE6_LOJFOR = D1.D1_LOJA"
cQuery +=   " AND VE6_INDREG = '3'" // Somente reg. de reserva
cQuery +=   " AND ( VE6_NUMORC <> '" + Space(TamSX3("VE6_NUMORC")[1]) + "'  "   // Registro de Balcao
cQuery +=          " OR "
cQuery +=          "(  VE6_NUMOSV <> '" + Space(TamSX3("VE6_NUMOSV")[1]) + "' " // Registro de Oficina
cQuery +=          " AND VE6_QTDATE > 0"           // Ja foi requisitado peca
cQuery +=          " AND VE6_QTDATE <> VE6_QTDDEV" // Nao foi devolvido todas as pecas
cQuery +=          " ) ) "
cQuery +=   " AND VE6.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY VE6_ORIREQ, VE6_NUMORC, VE6_NUMOSV, VE6_GRUITE, VE6_CODITE"
cQuery += " ORDER BY VE6_NUMORC, VE6_NUMOSV, VE6_GRUITE, VE6_CODITE"
TCQUERY cQuery NEW ALIAS "TEMPVE6"

While !TEMPVE6->(Eof())
	// Orcamento de Balcao
	If !Empty(TEMPVE6->VE6_NUMORC)
		VS1->(dbSetOrder(1))
		If VS1->(dbSeek(xFilial("VS1") + TEMPVE6->VE6_NUMORC ))
			If !VS1->VS1_STATUS $ "R/C"
				cMsgErro += CHR(13) + STR0085+": " + TEMPVE6->VE6_NUMORC + "   "+STR0057+": " + AllTrim(TEMPVE6->VE6_CODITE)//Orçamento # Produto
			EndIf
		EndIf
	EndIf

	// Ordem de Servico - Oficina
	If !Empty(TEMPVE6->VE6_NUMOSV)
		cMsgErro += CHR(13) + STR0056+": " + TEMPVE6->VE6_NUMOSV + "   "+STR0057+": " + AllTrim(TEMPVE6->VE6_CODITE)//OS # Produto
	EndIf
	TEMPVE6->(dbSkip())
End

IF !Empty(cMsgErro)
	MsgStop(STR0058 + chr(13) + cMsgErro) //Não é possivel excluir a nota, pois a reserva de peca no modulo de oficina ja foi baixada
	lRetorno := .F.
ENDIF

TEMPVE6->(dbCloseArea())
RestArea( aArea )

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FM_SQL      ºAutor ³ Rubens Takahashi     º Data ³26/10/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa uma consulta SQL no banco de dados e retorna o     º±±
±±º          ³ conteudo executado                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_SQL( _cSQL )
Local cRetorno
Local aArea := GetArea()

TCQUERY _cSQL NEW ALIAS "TSQLCON"
dbSelectArea("TSQLCON")
cRetorno := FieldGet(1)
dbCloseArea()

RestArea( aArea )

Return (cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FM_SALDORESV   ºAutor³ Rubens Takahashi   º Data ³ 26/10/09º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula saldo de reserva de peca de Ordem de Servico       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_SALDORESV(_cGruIte, _cCodIte, _cNumOsv, _cLoteCt, _cNumLot, _cSugCom )

Local nRetorno, cQuery

Default _cGruIte := Space(TamSX3("B1_GRUPO")[1])
Default _cCodIte := Space(TamSX3("B1_CODITE")[1])
Default _cLoteCt := Space(TamSX3("VE6_LOTECT")[1])
Default _cNumLot := Space(TamSX3("VE6_NUMLOT")[1])
Default _cSugCom := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se nao for informado a OS, retorna o saldo de reserva de todas as OS's³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default _cNumOsv := Space(TamSX3("VE6_NUMOSV")[1])

cQuery := "SELECT SUM(VE6_QTDITE - VE6_QTDATE - VE6_QTDEST) SALDO"
cQuery += "  FROM "+RetSQLName("VE6")+" VE6"
cQuery += " WHERE VE6_FILIAL = '"+xFilial("VE6")+"'"
IF !Empty(_cNumOsv)
	cQuery += "   AND VE6_NUMOSV = '"+_cNumOsv+"'"
ELSE
	cQuery += "   AND VE6_NUMOSV <> '"+_cNumOsv+"'"
ENDIF
cQuery += "   AND VE6_INDREG = '3'" // Reserva de Item
IF !Empty(_cCodIte)
	cQuery += "   AND VE6_GRUITE = '"+_cGruIte+"'"
	cQuery += "   AND VE6_CODITE = '"+_cCodIte+"'"
	cQuery += "   AND VE6_LOTECT = '"+_cLoteCt+"'"
	cQuery += "   AND VE6_NUMLOT = '"+_cNumLot+"'"
ENDIF
If !Empty(_cSugCom)
	cQuery += "   AND VE6_SUGCOM = '"+_cSugCom+"'"
EndIf
cQuery += "   AND VE6.D_E_L_E_T_ = ' '"

nRetorno := FM_SQL(cQuery)

Return nRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FM_Mod3  ³ Autor ³ Rubens / Manoel       ³ Data ³ 17/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modelo 3                                                   ³±±
±±³          ³ Passar os parametros <_oDlg>,<_oEnchoice>,<_oGetDados> por ³±±
±±³          ³ por referencia                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTitulo = Titulo da Janela                                 ³±±
±±³			 ³ cAlias1 = Alias da Tab. da Enchoice                        ³±±
±±³			 ³ cAlias2 = Alias da Tab. da Get Dados                       ³±±
±±³			 ³ aAuxEnchoice = Array com os campos da Enchoice. Se o param.³±±
±±³			 ³                não for passado a funcao ira cria-la automat³±±
±±³			 ³ aAltEnchoice = Array com os campos da Enchoice que estarão ³±±
±±³			 ³                habilitados para alteracao. Se o param. não ³±±
±±³			 ³                for passado todos os campos serao habil.    ³±±
±±³			 ³ aAuxAHeader = aHeader da GetDados. Se o param. não for     ³±±
±±³			 ³               passado a funcao ira cria-la automat.        ³±±
±±³			 ³ aAuxACols = aCols da GetDados. Se o param. não for passado ³±±
±±³			 ³             a funcao ira cria-la automat.                  ³±±
±±³			 ³ cFieldOk = Funcao para validar campos da GetDados.         ³±±
±±³			 ³ cLinOk = Funcao para validar a linha da GetDados.          ³±±
±±³			 ³ cTudoOk = Funcao para validar a GetDados.                  ³±±
±±³			 ³ cDelOk = Funcao para validar exclusao da linha da GetDados.³±±
±±³			 ³ nOpcE = Tipo de Oper. da Enchoice.                         ³±±
±±³			 ³ nOpcG = Tipo de Oper. da GetDados.                         ³±±
±±³			 ³ lVirtual = Indica se a Enchoice utilizara var. de memorias ³±±
±±³			 ³            ou os campos da tabela                          ³±±
±±³			 ³ _oWindow = Indica a Dialog Pai da Dialog que será criada.  ³±±
±±³			 ³ _oDlg = Var. que recebera a Dialog que será criada.        ³±±
±±³			 ³ _oEnchoice = Var. que recebera a Enchoice que será criada. ³±±
±±³			 ³ _oGetDados = Var. que recebera a GetDados que será criada. ³±±
±±³			 ³ cEnchNView = Indica os campos que não serão exibidos na    ³±±
±±³			 ³              Enchoice quando o param. aAuxEnchoice nao for ³±±
±±³			 ³              informado.                                    ³±±
±±³			 ³ cGetDNView = Indica os campos que não serão exibidos na    ³±±
±±³			 ³              GetDados quando o param. aAuxAHeader nao for  ³±±
±±³			 ³              informado.                                    ³±±
±±³			 ³ nOrdGet2 = Ordem para montagem da aCols.                   ³±±
±±³			 ³ cChvGet2 = Chave de pesquisa para montagem da aCols.       ³±±
±±³			 ³ cVlChvGet2 = Campos da Chave de pesquisa para a montagem   ³±±
±±³			 ³              da aCols                                      ³±±
±±³			 ³ aRetPos =  Vetor para retorno da Dimensao da GetDados se   ³±±
±±³			 ³            nao passado o cAlias2                           ³±±
±±³			 ³ nPercTela = Proporcao da tela                              ³±±
±±³			 ³ nPercObj1 = Proporcao da tela utilizada pelo Obj 1         ³±±
±±³			 ³ aAlter = Vetor com campos alteraveis na GetDados           ³±±
±±³			 ³ lWalkThru = Cria colunas ref. ao WalkThru na GetDados      ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_Mod3(cTitulo,cAlias1,cAlias2,aAuxEnchoice,aAltEnchoice,aAuxAHeader,aAuxACols,cFieldOk,cLinOk,cTudoOk,cDelOk,nOpcE,nOpcG,lVirtual,_oWindow,_oDlg,_oEnchoice,_oGetDados,cEnchNView,cGetDNView,nOrdGet2,cChvGet2,cVlChvGet2,aRetPos,nPercTela,nPercObj1,aAlter,lWalkThru,lAuto)

Local aObjects 	:= {}
Local aSizeAut	:= MsAdvSize(.t.)
Local wVar, nCntFor
Local nTamObj1,nTamObj2, nAltura

Default cAlias1 := ""
Default cAlias2 := ""
Default nOpcE := 2 // Visualizacao
Default nOpcG := 2 // Visualizacao
Default lVirtual := .F.
Default aAuxEnchoice := {}
Default aAuxAHeader := {}
Default aAuxEnchoice := {}
Default cEnchNView := ""
Default cGetDNView := ""
Default cLinOk := "AllwaysTrue()"
Default cTudoOk := "AllwaysTrue()"
Default cFieldOk := "AllwaysTrue()"
Default cDelOk := "AllwaysTrue()"
Default nOrdGet2 := 1
Default aRetPos := {}
Default nPercTela := 100
Default nPercObj1 := 50
Default cVlChvGet2 := ""
Default aAlter := {}
Default lWalkThru := .t.
Default lAuto := .f.

If Empty(cAlias1)
	nPercObj1 := 0
EndIf

If !lAuto
	if nPercTela <> 100
		For nCntFor := 1 to Len(aSizeAut)
			aSizeAut[nCntFor] := aSizeAut[nCntFor] * (nPercTela/100)
		Next nCntFor
	endif

	// Var. Aux. para montagem da Tela
	if nPercObj1 <> 50
		nAltura  := aSizeAut[ 4 ] - aSizeAut[ 2 ]
		nTamObj1 := nAltura * (nPercObj1 / 100)
		nTamObj2 := nAltura * ((100-nPercObj1) / 100)
		AAdd( aObjects, { 0, nTamObj1 , .T. , .f. } )	// ENCHOICE - TAMANHO VERTICAL VARIAVEL
		AAdd( aObjects, { 0, nTamObj2 , .T. , .T. } )	// GETDADOS - TAMANHO VERTICAL VARIAVEL
	else
		AAdd( aObjects, { 0, 50 , .T. , .T. } )	// ENCHOICE - TAMANHO VERTICAL VARIAVEL
		AAdd( aObjects, { 0, 50 , .T. , .T. } )	// GETDADOS - TAMANHO VERTICAL VARIAVEL
	endif
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
EndIf

// Se nao foi passado os campos da Enchoice
if !Empty(cAlias1) .and. Len(aAuxEnchoice) == 0

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbgotop()

	// Nao Mostrar campo de Filial
	cEnchNView += ","+AllTrim(cAlias1)+"_FILIAL"

	DbSelectArea("SX3")
	DbSeek(cAlias1)

	While !Eof().and.(SX3->X3_ARQUIVO == cAlias1)
		if X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. !(AllTrim(SX3->X3_CAMPO) $ cEnchNView)
			AADD(aAuxEnchoice,SX3->X3_CAMPO)
		Endif
		wVar := "M->"+SX3->X3_CAMPO
		&wVar:= CriaVar(SX3->X3_CAMPO)
		dbSkip()
	End

	// Se nao for Inclusao, inicializa variaveis M-> com o conteudo dos campos do registro posicionado
	If nOpcE <> 3
		DbSelectArea(cAlias1)
		For nCntFor := 1 TO FCount()
			&("M->"+Field(nCntFor)) := FieldGet(nCntFor)
		Next
	Endif
	//

Endif

// Se Nao foi passado o aHeader da GetDados ...
if Len(aAuxAHeader) == 0 .and. !Empty(cAlias2)
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbgotop()
	dbSeek(cAlias2)

	aAuxAHeader:={}
	// Nao Mostrar campo de Filial
	cGetDNView := AllTrim(cAlias2)+"_FILIAL," + cGetDNView

	While !Eof() .And. (sx3->x3_arquivo==cAlias2)
		If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL .AND. !(AllTrim(SX3->X3_CAMPO) $ cGetDNView)

			Aadd(aAuxAHeader, {AllTrim(X3Titulo()), SX3->X3_CAMPO,	SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,     SX3->X3_VALID,	SX3->X3_USADO, 	SX3->X3_TIPO,;
			SX3->X3_F3,			 SX3->X3_CONTEXT,	X3CBOX(), 			SX3->X3_RELACAO })

			IF SX3->X3_VISUAL <> "V"
				Aadd(aAlter,SX3->X3_CAMPO)
			ENDIF

			wVar := "M->"+AllTrim(x3_campo)
			&wVar := CriaVar(x3_campo,!lAuto)
		Endif
		SX3->(dbSkip())
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona Colunas de Walkthru (Alias e Recno) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lWalkThru
		dbSelectArea(cAlias2)
		ADHeadRec(cAlias2,aAuxAHeader)
	EndIf

	// Se nao for inclusao, inicializa com conteudo do banco
	IF nOpcG <> 3 .and. Len(aAuxACols) == 0 .and. !Empty(cVlChvGet2)
		dbSelectArea(cAlias2)
		dbSetOrder(nOrdGet2)
		DbSeek(cVlChvGet2)
		While !(cAlias2)->(Eof()) .and. &(cChvGet2) == cVlChvGet2
			AADD(aAuxACols,Array(Len(aAuxAHeader)+1))
			For nCntFor:=1 to Len(aAuxAHeader)
				If IsHeadRec(aAuxAHeader[nCntFor,2])
					aAuxACols[Len(aAuxACols),nCntFor] := &(cAlias2)->(Recno())
				ElseIf IsHeadAlias(aAuxAHeader[nCntFor,2])
					aAuxACols[Len(aAuxACols),nCntFor] := cAlias2
				Else
					aAuxACols[Len(aAuxACols),nCntFor]:=IIf(aAuxAHeader[nCntFor,10] # "V",FieldGet(FieldPos(aAuxAHeader[nCntFor,2])),CriaVar(aAuxAHeader[nCntFor,2]))
				EndIf
			Next
			aAuxACols[Len(aAuxACols),Len(aAuxAHeader)+1]:=.F.
			dbSkip()
		Enddo
	endif

EndIf

// Nao tem montado o aAlter ...
if Len(aAuxAHeader) > 0 .and. Len(aAlter) == 0 .and. !Empty(cAlias2)
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbgotop()
	dbSeek(cAlias2)
	While !Eof() .And. (sx3->x3_arquivo==cAlias2)
		If !(AllTrim(SX3->X3_CAMPO) $ cGetDNView) .and. SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		Endif
		SX3->(dbSkip())
	End
endif

// Se for inclusao na GetDados, inicializa as variaveis da ACols
IF !lAuto .and. nOpcG == 3 .and. Len(aAuxAHeader) > 0
	aAuxACols := { Array(Len(aAuxAHeader)+1) }
	aAuxACols[1,Len(aAuxAHeader)+1] := .F.
	For nCntFor:=1 to Len(aAuxAHeader)
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aAuxAHeader[nCntFor,2])
			aAuxACols[Len(aAuxACols),nCntFor] := 0
		ElseIf IsHeadAlias(aAuxAHeader[nCntFor,2])
			aAuxACols[Len(aAuxACols),nCntFor] := cAlias2
		Else
			aAuxACols[1,nCntFor]:=CriaVar(aAuxAHeader[nCntFor,2])
		Endif
	Next
ENDIF

If !lAuto
	DEFINE MSDIALOG _oDlg TITLE cTitulo From aSizeAut[7],00 to aSizeAut[6],aSizeAut[5] of _oWindow PIXEL
	If !Empty(cAlias1)
		_oEnchoice := MsMGet():New(cAlias1,; 			// cAlias da Tabela
		,; 					// nReg
		nOpcE,; 				// nOpc
		/*aCRA*/,/*cLetra*/,/*cTexto*/,;
		aAuxEnchoice,; 	// Vetor com os campos que serão exibidos
		aPosObj[1] ,; 		// Coordenadas para criacao do Objeto
		aAltEnchoice ,;	// Vetor com os campos que poderão ser alterados
		3,;					// nModelo - Se for dif. de 1 desabilita execucao de gatilhos extrangeiros
		/*nColMens*/,/*cMensagem*/,;
		,;						// Expressão para validacao da Enchoice
		_oDlg,;
		/*lF3*/,;
		lVirtual,;			// Indica se a Enchoice utilizara var. de memorias ou os campos da tabela
		/*lColuna*/,;		// Indica se a apresentacao dos campos sera em forma de coluna
		/*caTela*/,;		// Nome da Var. que a enchoice utilizara no lugar da propriedade aTela
		/*lNoFolder*/,;	// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)
		/*lProperty*/)		// Indica se a Enchoice nao utilizara as var. aTela e aGets, somente suas prop. com os mesmos nomes
	EndIf
	If Len(aAuxAHeader) > 0
		_oGetDados := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],;
		IIf(nOpcG == 2,0,GD_INSERT+GD_UPDATE+GD_DELETE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
		cLinOk,cTudoOk,;
		,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
		aAlter ,; 	// Campos alteraveis da GetDados
		/*nFreeze*/,;	// Campos estaticos da GetDados
		999,;
		cFieldOk,;
		/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		cDelOk,; 		// Funcao executada para validar a exclusao de uma linha
		_oDlg,;
		aAuxAHeader,;
		aAuxACols)
		_oGetDados:oBrowse:bChange       := {|| FG_MEMVAR(_oGetDados:aHeader,_oGetDados:aCols,_oGetDados:nAt) }

	else
		aRetPos := aPosObj[2]
	endif
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FG_ALTFINºAutor  ³ Thiago             º Data ³12/01/10     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar se o usuario pode criar tipos de paga- º±±
±±º          ³ mentos (VS9)                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FG_ALTFIN()
lRet := .t.

// Atendimento NOVO de Veiculos e Fechamento de OS Novo, nao usa esta validacao
if FM_PILHA("VEIXX002") .or. FM_PILHA("OFIXX100")
	Return .t.
endif

If VAI->(FieldPos("VAI_ALTPAR")) > 0
	VAI->(Dbsetorder(4))
	if VAI->(DbSeek(xFilial("VAI")+__cUserID))
		If VAI->VAI_ALTPAR != "1"
			lRet := .f.
			M->VS9_TIPPAG := ""
			aCols[n,2] := ""
			M->VS9_DESPAG := ""
			MsgStop(STR0059,STR0011)  //"Usuario sem permissão para alterar a data e/ou valor da parcela
		EndIf
	EndIf
EndIf

Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FM_LOCVZLºAutor  ³ Luis Delorme       º Data ³25/01/10     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera a localizacao dos veiculos VZL                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAOFI                                                    º±±
±±ºUso       ³ 1 - Credita                                                º±±
±±ºUso       ³ 2 - Debita                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_LOCVZL(nCreDeb,cChaInt)
Local cGruVei   := ""
Default nCreDeb := 1
Default cChaInt := ""
If !Empty(cChaInt)
	cGruVei := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
	dbSelectArea("VV1")
	dbSetOrder(1)
	dbSeek(xFilial("VV1")+cChaInt)

	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )

EndIf
if nCreDeb == 2
	if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
		DBSelectArea("SB5")
		DBSetOrder(1)
		if DBSeek(xFilial("SB5")+SB1->B1_COD)
			DBSelectArea("VZL")
			DBSetOrder(1)
			if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
				if VZL->VZL_QTDATU > 0
					reclock("VZL",.f.)
					VZL->VZL_QTDATU := VZL->VZL_QTDATU - 1
					msunlock()
				endif
			endif
		endif
	endif
else
	DBSelectArea("SB5")
	DBSetOrder(1)
	if DBSeek(xFilial("SB5")+SB1->B1_COD)
		if GetNewPar("MV_LOCVZL","N")=="S"  // USA LOCALIZACAO DE VEICULOS
			DBSelectArea("VZL")
			DBSetOrder(1)
			if DBSeek(xFilial("VZL")+SB1->B1_LOCPAD+SB5->B5_LOCALI2)
				if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
					reclock("VZL",.f.)
					VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
					msunlock()
				else
					aRet := {}
					aParamBox := {}
					MsgInfo(STR0080,STR0011) // "A localizacao está lotada. Clique OK para escolher outra."
					VZL->(DBSetOrder(1))
					aAdd(aParamBox,{1,STR0081,Space(2),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01))","NNR","",0,.F.})
					aAdd(aParamBox,{1,STR0082,Space(15),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01+MV_PAR02))","VZL","",0,.F.})
					lContinua := .f.
					while !lContinua
						If !(ParamBox(aParamBox, STR0083 +" - "+Alltrim(VV1->VV1_CHASSI),@aRet))// "Localizacao de Veiculos"
							if MsgYesNo(STR0084, STR0011) // "Deseja efetuar a entrada do veiculo sem localizacao ?"
								lContinua := .t.
							endif
						else
							DBSelectArea("VZL")
							DBSetOrder(1)
							if DBSeek(xFilial("VZL")+aRet[1]+aRet[2])
								if VZL->VZL_QTDATU < VZL->VZL_QTDMAX
									lContinua := .t.
									reclock("VZL",.f.)
									VZL->VZL_QTDATU := VZL->VZL_QTDATU + 1
									msunlock()
									DBSelectArea("SB1")
									reclock("SB1",.f.)
									SB1->B1_LOCPAD := aRet[1]
									msunlock()
									DBSelectArea("SB5")
									reclock("SB5",.f.)
									SB5->B5_LOCALI2 := aRet[2]
									msunlock()
								endif
							endif
						Endif
					enddo
				endif
			endif
		endif
		cB5Locali2 := SB5->B5_LOCALI2
		if Empty(cB5Locali2)
			cB5Locali2 := GetNewPar("MV_RECVEIC","RECEPCAO VEIC")
		endif
		DBSelectArea("SB5")
		reclock("SB5",.f.)
		SB5->B5_LOCALI2 := " "
		msunlock()
		// Altera a LOCALIZACAO no SB5 //
		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )
		RecLock("SB5",!Found())
		SB5->B5_FILIAL  := xFilial("SB5")
		SB5->B5_COD     := SB1->B1_COD
		SB5->B5_LOCALI2 := cB5Locali2
		MsUnlock()
	endif
endif

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FM_OBSMEM ³ Autor ³  Andre Luis Almeida  ³ Data ³ 07/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza/Atualiza MEMO                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTitJanela   = Titulo da Janela                            ³±±
±±³          ³ cCampoMemo   = Campo Caracter do Memo. Ex: VV0->VV0_OBSMEM ³±±
±±³          ³ cCampoOBSMEM = Nome Campo Caract do Memo. Ex: "VV0_OBSMEM" ³±±
±±³          ³ cCampoOBSERV = Nome Campo Memo. Ex: "VV0_OBSERV"           ³±±
±±³          ³ lAltMemo     = Altera o Campo Memo (.t./.f.)               ³±±
±±³          ³ lTrazTexto   = Traz Texto ja existente no Memo (.t./.f.)   ³±±
±±³          ³ cMsgSC5      = Msg Integracao NF                           ³±±
±±³          ³ cMsgPadSC5   = Msg Padrao Integracao NF                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_OBSMEM(cTitJanela,cCampoMemo,cCampoOBSMEM,cCampoOBSERV,lAltMemo,lTrazTexto,cMsgSC5,cMsgPadSC5)
Local xReturn      := ""
Local cObserv      := ""
Private cMsg1      := ""
Private cMsg2      := ""
Default cTitJanela := ""
Default lAltMemo   := .f.
Default lTrazTexto := .t.
Default cMsgSC5    := ".f."
Default cMsgPadSC5 := ".f."
If Empty(cTitJanela)
	If Empty(Alias())
		DbSelectArea("VV1")
	EndIf
	cTitJanela := RetTitle(cCampoOBSERV)
EndIf
If Type("Inclui") == "U"
	Inclui := lAltMemo
EndIf
If lTrazTexto
	cObserv := E_MSMM(cCampoMemo,TamSx3(cCampoOBSERV)[1])
EndIf
If cMsgSC5 <> ".f." // Existe MSG da NF / Memo complementar da NF
	cMsg1 := cMsgSC5
	cMsg2 := cMsgPadSC5
	DEFINE MSDIALOG oDlgObsMem TITLE cTitJanela FROM  00,00 TO 23,55 OF oMainWnd
	@ 10,010 SAY STR0105 SIZE 60,8 OF oDlgObsMem PIXEL COLOR CLR_BLUE // Mensagem da NF
	@ 20,010 MSGET oMsg1 VAR cMsg1 PICTURE "@!" SIZE 140,08 OF oDlgObsMem PIXEL COLOR CLR_BLUE HASBUTTON WHEN lAltMemo
	@ 10,165 SAY STR0106 SIZE 60,8 OF oDlgObsMem PIXEL COLOR CLR_BLUE // Mensagem Padrão
	@ 20,165 MSGET oMsg2 VAR cMsg2 PICTURE "@!" F3 "SM4" SIZE 35,08 VALID (Vazio().Or.ExistCpo("SM4")) OF oDlgObsMem PIXEL COLOR CLR_BLUE HASBUTTON WHEN lAltMemo
	@ 40,010 SAY STR0107 SIZE 150,8 OF oDlgObsMem PIXEL COLOR CLR_BLUE // Observação NF Interna DMS
	If lAltMemo
		@ 50,10 GET oObserv VAR cObserv OF oDlgObsMem MEMO SIZE 200,100 PIXEL
		DEFINE SBUTTON FROM 157,184 TYPE 1 ACTION (oDlgObsMem:End()) ENABLE OF oDlgObsMem
	Else
		@ 50,10 GET oObserv VAR cObserv OF oDlgObsMem MEMO SIZE 200,100 PIXEL ReadOnly MEMO
		DEFINE SBUTTON FROM 157,184 TYPE 2 ACTION (oDlgObsMem:End()) ENABLE OF oDlgObsMem
	EndIf
	oObserv:SetFocus()
	ACTIVATE MSDIALOG oDlgObsMem CENTER
	xReturn := {cObserv,cMsg1,cMsg2}
Else // Memo Comum
	DEFINE MSDIALOG oDlgObsMem TITLE cTitJanela FROM  00,00 TO 23,55 OF oMainWnd
	If lAltMemo
		@ 10,10 GET oObserv VAR cObserv OF oDlgObsMem MEMO SIZE 200,137 PIXEL
		DEFINE SBUTTON FROM 157,184 TYPE 1 ACTION (oDlgObsMem:End()) ENABLE OF oDlgObsMem
	Else
		@ 10,10 GET oObserv VAR cObserv OF oDlgObsMem MEMO SIZE 200,137 PIXEL ReadOnly MEMO
		DEFINE SBUTTON FROM 157,184 TYPE 2 ACTION (oDlgObsMem:End()) ENABLE OF oDlgObsMem
	EndIf
	oObserv:SetFocus()
	ACTIVATE MSDIALOG oDlgObsMem CENTER
	xReturn := cObserv
EndIf
Return(xReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FM_MAPAVAL³ Autor ³  Andre Luis Almeida  ³ Data ³ 09/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ MAPA DE AVALIACAO                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo (1=Veiculos;2=AutoPecas;3=Oficina)                   ³±±
±±³          ³ cMapa (Codigo do Mapa de Avaliacao) -> Mapa em SQL <-      ³±±
±±³          ³ cSeek (Utilizado para posicionar nos arquivos envolvidos)  ³±±
±±³          ³    -  Nro.Atendimento -> Veiculos                          ³±±
±±³          ³    -  Nro.Orcamento   -> AutoPecas                         ³±±
±±³          ³    -  Nro.da OS       -> Ordem de Servico                  ³±±
±±³          ³ lTela (Mostra Tela com o Mapa de Avaliacao)                ³±±
±±³          ³ nTamTela (% referente ao tamanho da Tela (janela com Mapa) ³±±
±±³          ³ aMap (Vetor para ser preenchido com as linhas do Mapa)     ³±±
±±³          ³ cChaInt (Chassi Interno do veiculo)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRet[1]                                                    ³±±
±±³          ³    +1 = Bom   (Positivo)                                   ³±±
±±³          ³     0 = Medio (Neutro)                                     ³±±
±±³          ³    -1 = Ruim  (Negativo)                                   ³±±
±±³          ³ aRet[2]                                                    ³±±
±±³          ³    % do Lucro                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_MAPAVAL(nTipo,cCodMap,cSeek,lTela,nTamTela,aMap,cChaInt)
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cSalvaA    := Alias()
Local cQuery     := ""
Local cQAlVOQ    := "SQLVOQ"
Local cQAlAux    := "SQLATVEI" // SLQ->CAMPO (MAPA)
Local aVOQ       := {}
Local aCor       := {}
Local aVeicVVA   := {}
Local aTitMap    := {}
Local aStru      := {}
Local aFormul    := {}
Local ni         := 0
Local aRet       := {2,0,{}}
Local nPerLuc    := 0 // % do Lucro
Local nVlrLuc    := 0 // Valor do Lucro
Local nVlrTot    := 0 // Valor Total
Local lVVACODMAR := ( VVA->(ColumnPos("VVA_CODMAR")) > 0 )
Local lVVAITETRA := ( VVA->(ColumnPos("VVA_ITETRA")) > 0 )
Local lVVASEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )
Local cQuebra    := "INICIAL"
Private aMapTotal:= {}
Default aMap     := {}
Default cCodMap  := ""
Default nTamTela := 100
Default cChaInt  := ""

DEFINE FONT oTitTotal NAME "Arial" SIZE 12,15 BOLD

If Empty(cCodMap)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| MV_MAPAVAL - Mapa de Avaliacao Default |
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//| Conteudo: VVVBBBOOO                    |
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//| VVV = Cod. do Mapa de Veiculos         |
	//| BBB = Cod. do Mapa de Auto-Pecas       |
	//| OOO = Cod. do Mapa de Oficina          |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodMap := substr(left(Alltrim(GetNewPar("MV_MAPAVAL",""))+space(9),9),(3*nTipo)-2,3)
	If Empty(cCodMap)
		aMap := {}
		aadd(aMap,{"",0,0}) // Mapa
		Return aRet
	EndIf
EndIf
// Levanta todo MAPA DE AVALIACAO //
cQuery := "SELECT VOQ.VOQ_TIPFAT , VOQ.VOQ_ANASIN , VOQ.VOQ_DESAVA , VOQ.VOQ_CLAAVA , VOQ.VOQ_CODIGO , VOQ.VOQ_SINFOR , VOQ.VOQ_PRIFAI ,VOQ.VOQ_SEGFAI , VOQ.VOQ_FUNADI , VOQ.VOQ_CODIMF , VOQ.VOQ_CTATOT , VEG.VEG_FORMUL FROM "+RetSqlName("VOQ")+" VOQ , "+RetSqlName("VEG")+" VEG WHERE "
cQuery += "VOQ.VOQ_FILIAL='"+xFilial("VOQ")+"' AND VOQ.VOQ_CODMAP='"+cCodMap+"' AND VOQ.VOQ_INDATI='1' AND VOQ.D_E_L_E_T_=' ' AND "
cQuery += "VEG.VEG_FILIAL='"+xFilial("VEG")+"' AND VEG.VEG_CODIGO=VOQ.VOQ_CODIGO AND VEG.D_E_L_E_T_=' ' ORDER BY VOQ.VOQ_CLAAVA "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAlVOQ, .F., .T. )
Do While !( cQAlVOQ )->( Eof() )

	aadd(aVOQ,{;
		( cQAlVOQ )->( VOQ_TIPFAT ) ,; // 1
		( cQAlVOQ )->( VOQ_CLAAVA ) ,; // 2
		IIf(( cQAlVOQ )->( VOQ_ANASIN )#"0",Space(7)+( cQAlVOQ )->( VOQ_DESAVA ),( cQAlVOQ )->( VOQ_DESAVA )),; // 3
		( cQAlVOQ )->( VOQ_ANASIN ),; // 4
		( cQAlVOQ )->( VOQ_CODIGO ),; // 5
		( cQAlVOQ )->( VOQ_SINFOR ),; // 6
		( cQAlVOQ )->( VOQ_PRIFAI ),; // 7 Ruim
		( cQAlVOQ )->( VOQ_SEGFAI ),; // 8 Medio
		( cQAlVOQ )->( VOQ_FUNADI ),; // 9
		( cQAlVOQ )->( VOQ_CODIMF ),; //10
		( cQAlVOQ )->( VOQ_CTATOT ),; //11
		Alltrim(( cQAlVOQ )->( VEG_FORMUL )) }) //12

	( cQAlVOQ )->( DbSkip() )
EndDo
( cQAlVOQ )->( dbCloseArea() )

If nTipo == 1
	aAdd(aTitMap,STR0094) // TOTAL
	////////////////
	//  VEICULOS  //
	////////////////
	cQuery := "SELECT VV0.* , VVA.* , VVA.R_E_C_N_O_ AS RECVVA , VV1.VV1_TRACPA FROM "+RetSqlName("VV9")+" VV9 "
	cQuery += "JOIN "+RetSqlName("VV0")+" VV0 ON ( VV0.VV0_FILIAL=VV9.VV9_FILIAL AND VV0.VV0_NUMTRA=VV9.VV9_NUMATE AND VV0.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VVA")+" VVA ON ( VVA.VVA_FILIAL=VV9.VV9_FILIAL AND VVA.VVA_NUMTRA=VV9.VV9_NUMATE AND VVA.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VVA.VVA_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_NUMATE='"+cSeek+"' AND "
	If !Empty(cChaInt)
		cQuery += "VVA.VVA_CHAINT='"+cChaInt+"' AND "
	EndIf
	cQuery += "VV9.D_E_L_E_T_=' ' "
	If lVVAITETRA
		cQuery += "ORDER BY VVA.VVA_ITETRA"
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlAux, .F., .T. )
	While !( cQAlAux )->( Eof() )
		If cQuebra == ( cQAlAux )->( VVA_ITETRA )
			( cQAlAux )->( DbSkip() )
			Loop
		Else
			cQuebra := ( cQAlAux )->( VVA_ITETRA )
		EndIf

		aStru := {}
		For ni := 1 to len(aVOQ) // Utiliza VOQ (MAPA AVALIACAO) pelo TIPFAT
			If ( cQAlAux )->( VV0_TIPFAT ) $ aVOQ[ni,1]

				aadd(aStru,{ ;
					( cQAlAux )->( VV0_NUMTRA ),;       // 01
					( cQAlAux )->( VV1_TRACPA ),;       // 02
					"",;                                // 03
					aVOQ[ni,2],;                        // 04 - VOQ_CLAAVA
					aVOQ[ni,3],;                        // 05 - VOQ_DESAVA
					aVOQ[ni,4],;                        // 06 - VOQ_ANASIN
					aVOQ[ni,5],;                        // 07 - VOQ_CODIGO
					aVOQ[ni,6],;                        // 08 - VOQ_SINFOR
					0,;                                 // 09
					0,;                                 // 10
					( cQAlAux )->( VVA_CHASSI ),;       // 11
					0,;                                 // 12
					0,;                                 // 13
					.f.,;                               // 14
					aVOQ[ni,7],;                        // 15 - Ruim
					aVOQ[ni,8],;                        // 16 - Medio
					aVOQ[ni,9],;                        // 17 - VOQ_FUNADI
					aVOQ[ni,10],;                       // 18 - VOQ_CODIMF
					stod(( cQAlAux )->( VV0_DATMOV )),; // 19
					0,;                                 // 20
					0,;                                 // 21
					aVOQ[ni,11]})                       // 22 - VOQ_CTATOT

				aadd(aFormul,{;
					aVOQ[ni,12],;  // Formula - Moeda Normal  
					aVOQ[ni,12],;  // Formula - Moeda Forte  
					aVOQ[ni, 5],;   // Formula - Codigo Moeda Normal
					aVOQ[ni, 5]})  // Formula - Codigo Moeda Forte

			EndIf
		Next
		
		FG_CalcVlrs(aStru,,,.f.,aFormul,.t.)
		
		If len(aStru) > 0 .and. !Empty(aStru[1,1])
		
			aAdd( aCor , { aStru[1,9] , aStru[len(aStru),9] , aStru[len(aStru),15] , aStru[len(aStru),16] })
			aAdd( aVeicVVA , { ( cQAlAux )->( RECVVA ) , aStru[len(aStru),10] })
			
			aMap := {}
			For ni := 1 to Len(aStru)
				aadd( aMap , { aStru[ni,5] , aStru[ni,9] , aStru[ni,10] }) // Mapa
			Next

			If !Empty(( cQAlAux )->( VVA_CHASSI ))
				VV1->(dbSetOrder(2))
				VV1->(dbSeek(xFilial("VV1")+( cQAlAux )->( VVA_CHASSI )))

				FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)

				aAdd(aTitMap,Alltrim(( cQAlAux )->( VVA_CHASSI ))+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD))
			Else
				If lVVACODMAR
					FGX_VV2( ( cQAlAux )->( VVA_CODMAR ), ( cQAlAux )->( VVA_MODVEI ), IIf( lVVASEGMOD , ( cQAlAux )->( VVA_SEGMOD ) , "" ) )
				Else
					FGX_VV2( ( cQAlAux )->( VV0_CODMAR ), ( cQAlAux )->( VV0_MODVEI ), IIf( lVVASEGMOD , ( cQAlAux )->( VV0_SEGMOD ) , "" ) )
				EndIf
				aAdd(aTitMap,Alltrim(VV2->VV2_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD))
			EndIf

			If len(aMapTotal) <= 0
				aAdd(aMapTotal,aClone(aMap)) // Total
				aAdd(aMapTotal,aClone(aMap)) // 1o. Veiculo
			Else
				aAdd(aMapTotal,aClone(aMap)) // Demais Veiculos
				For ni := 1 to len(aMap)
					aMapTotal[1,ni,2] += aMap[ni,2] // Totalizar valores na 1a.aba, referente ao Total
				Next
			EndIf
		EndIf
		( cQAlAux )->( DbSkip() )
	EndDo
	( cQAlAux )->( dbCloseArea() )
ElseIf nTipo == 2
	///////////////
	// AUTOPECAS //
	///////////////
ElseIf nTipo == 3
	///////////////
	//  OFICINA  //
	///////////////
EndIf
If len(aCor) > 0 // Carrega o Vetor de Retorno ( COR , % Lucro ) -> BOM / MEDIO / RUIM
	//////////////////////////////////////////////////////
	// Alterar % do TOTAL em relacao a 1a.linha do MAPA //
	//////////////////////////////////////////////////////
	For ni := 1 to len(aMapTotal[1])
		aMapTotal[1,ni,3] := ( aMapTotal[1,ni,2] / aMapTotal[1,1,2] * 100 ) // Totalizar no Total
	Next
	
	For ni := 1 to Len(aCor)
		nVlrTot += aCor[ni,1] // aStru[1,9]
		nVlrLuc += aCor[ni,2] // aStru[len(aStru),9]
	Next

	nPerLuc := ( ( nVlrLuc / nVlrTot ) * 100 ) // % do Lucro
	aRet[1] := 1 // Bom
	If nPerLuc <= aCor[1,3] // aStru[len(aStru),15]
		aRet[1] := -1 // Ruim
	ElseIf nPerLuc <= aCor[1,4] // aStru[len(aStru),16]
		aRet[1] := 0 // Medio
	EndIf
	aRet[2] := nPerLuc
	aRet[3] := aClone(aVeicVVA)

EndIf
If len(aMap) <= 0
	aadd(aMap,{"",0,0}) // Mapa
EndIf
If lTela
	If len(aCor) <= 0
		MsgInfo(STR0060,STR0011) // Nao existem dados para esta Consulta! / Atencao
	Else
		// Fator de reducao da Tela (Janela)
		For ni := 1 to Len(aSizeHalf)
			aSizeHalf[ni] := INT(aSizeHalf[ni] * ( nTamTela / 100 ) )
		Next
		aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
		aAdd( aObjects, { 0 , 10 , .T. , .F. } ) // Botao Visualiza MAPA
		aAdd( aObjects, { 0 ,  0 , .T. , .T. } ) // ListBox MAPA
		aPos := MsObjSize( aInfo , aObjects )
		DEFINE MSDIALOG oMapaAval FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0061) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // Mapa de Avaliacao
		@ aPos[1,1]+2,aPos[1,2]+3 SAY (STR0061) SIZE aPos[1,4]-60,08 OF oMapaAval PIXEL COLOR CLR_RED FONT oTitTotal // Mapa de Avaliacao
		@ aPos[1,1],aPos[1,4]-045 BUTTON oGrpSair PROMPT STR0033 OF oMapaAval SIZE 45,10 PIXEL ACTION oMapaAval:End() // SAIR
		//
		oFolder := TFolder():New(aPos[2,1],aPos[2,2],aClone(aTitMap),{}, oMapaAval,,,,.t.,.f.,aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1])
		For ni := 1 to len(aTitMap)
			&("oLbMap" + AllTrim(Str(ni))) := TWBrowse():New(1,1,1,1,,,,oFolder:aDialogs[ni],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			&("oLbMap" + AllTrim(Str(ni))):nAT := 1
			&("oLbMap" + AllTrim(Str(ni))):SetArray(&("aMapTotal["+AllTrim(Str(ni))+"]"))
			&("oLbMap" + AllTrim(Str(ni))):addColumn( TCColumn():New( STR0061	, &("{ || aMapTotal["+AllTrim(Str(ni))+",oLbMap"+AllTrim(Str(ni))+":nAt,1] }"),,,,"LEFT" ,150,.F.,.F.,,,,.F.,) )	// Mapa de Avaliacao
			&("oLbMap" + AllTrim(Str(ni))):addColumn( TCColumn():New( STR0062	, &("{ || IIF(aMapTotal["+AllTrim(Str(ni))+",oLbMap"+AllTrim(Str(ni))+":nAt,2] == 0, '', Transform(aMapTotal["+AllTrim(Str(ni))+",oLbMap"+AllTrim(Str(ni))+":nAt,2],'@E 9999,999,999.99') ) }"),,,,"Right" ,100,.F.,.F.,,,,.F.,) )	// Valor
			&("oLbMap" + AllTrim(Str(ni))):addColumn( TCColumn():New( "%"     , &("{ || IIF(aMapTotal["+AllTrim(Str(ni))+",oLbMap"+AllTrim(Str(ni))+":nAt,3] == 0, '', Transform(aMapTotal["+AllTrim(Str(ni))+",oLbMap"+AllTrim(Str(ni))+":nAt,3],        '@E 9999.99') ) }"),,,,"Right" ,30,.F.,.F.,,,,.F.,) )	// %
			&("oLbMap" + AllTrim(Str(ni))):Align := CONTROL_ALIGN_ALLCLIENT
			&("oLbMap" + AllTrim(Str(ni))):Refresh()
		Next
		//
		If nTamTela == 100 // 100% da Tela
			ACTIVATE MSDIALOG oMapaAval
		Else // nTamTela <> 100 // centralizar tela qdo for menor que 100%
			ACTIVATE MSDIALOG oMapaAval CENTER
		EndIf
	EndIf
EndIf
If !Empty(cSalvaA)
	DbSelectArea(cSalvaA)
EndIf
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FM_SM0CLFR   ³ Autor ³ Rubens            ³ Data ³ 15/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Cod. do Cliente ou Fornecedor da Filial            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTipo (1=Cliente / 2 = Fornecedor)                         ³±±
±±³          ³ cPFilial = Filial a Ser Pesquisada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aAuxCodigo[1] = Codigo do Cliente/Fornecedor               ³±±
±±³          ³           [2] = Loja do Cliente/Fornecedor                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_SM0CLFR (nTipo,cPFilial)

Local aAuxRetorno := {"",""}
Local nAuxRecSM0
Local cAuxAlias := "SQLSA1SA2"
Local cQuery
Local cAuxCNPJ := ""
Local aSM0 := {}

Default cPFilial := cFilAnt

aSM0 := FWArrFilAtu(cEmpAnt,cPFilial)
cAuxCNPJ := aSM0[18]

// Cliente
if nTipo == 1
	cQuery := "SELECT A1_COD, A1_LOJA "
	cQuery +=  " FROM "+RetSQLName("SA1")+ " SA1 "
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery +=   " AND A1_CGC = '" + cAuxCNPJ + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	if SA2->(FieldPos("A1_MSBLQL")) <> 0
		cQuery += " ORDER BY A1_MSBLQL DESC, A1_COD DESC"
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias, .F., .T. )
	if !(cAuxAlias)->(Eof())
		aAuxRetorno[1] := (cAuxAlias)->A1_COD
		aAuxRetorno[2] := (cAuxAlias)->A1_LOJA
	endif
	(cAuxAlias)->(dbCloseArea())
	// Fornecedor
elseif nTipo == 2
	cQuery := "SELECT A2_COD, A2_LOJA "
	cQuery +=  " FROM "+RetSQLName("SA2")+ " SA2 "
	cQuery += " WHERE A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery +=   " AND A2_CGC = '" + cAuxCNPJ + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	if SA2->(FieldPos("A2_MSBLQL")) <> 0
		cQuery += " ORDER BY A2_MSBLQL DESC, A2_COD DESC"
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias, .F., .T. )
	if !(cAuxAlias)->(Eof())
		aAuxRetorno[1] := (cAuxAlias)->A2_COD
		aAuxRetorno[2] := (cAuxAlias)->A2_LOJA
	endif
	(cAuxAlias)->(dbCloseArea())
endif

Return aAuxRetorno



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FM_PILHA  ³ Autor ³ Rubens               ³ Data ³ 31/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se uma rotina esta contida na pilha de Chamadas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRotina = Rotina a ser procurada na pilha de chamadas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .t. ou .f.                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_PILHA(cRotina)

Local lRetorno := .F.
Local nContador:= 1
Local nAuxTam

cRotina := UPPER(AllTrim(cRotina))
nAuxTam := Len(cRotina)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual a rotina chamadora                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ( !lRetorno .And. !Empty(ProcName(nContador)) )
	If ( Left(Upper(ProcName(nContador)),nAuxTam) == cRotina )
		lRetorno := .T.
	EndIf
	nContador++
EndDo

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FM_CREDCLI   ³ Autor ³ ANDRE/RAFAEL      ³ Data ³ 28/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra titulos de adiantamento do cliente selecionado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Codigo Cliente                                         ³±±
±±³          ³ 2 - Loja   Cliente                                         ³±±
±±³          ³ 3 - 1-Cliente / 2 - Fornecedor                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_CREDCLI(cCodiCr,cLojaCr,cTipo)
Local cAreaAnt := GetArea()
Local cAlias := "SQLSA1SA2"
Local cQuery := "SQLSE2"
Local aTitulos := {}
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
Local cCodCli := ""
Local cLojCli := ""
Local cCodFor := ""
Local cLojFor := ""
Local nTotReAn:=0
Local nTotCCli:=0
Local nTotPcli:=0
Local cNomCli := ""

Private oVerd := LoadBitmap( GetResources(), "BR_VERDE" )    	// 1 = NCC
Private oazul := LoadBitmap( GetResources(), "BR_azul")			// 2 = RA
Private olara := LoadBitmap( GetResources(), "BR_laranja")  	// 5 = NCF

Default cCodiCr := ""
Default cLojaCr := ""
Default cTipo 	:= "1"

If cTipo=="1"
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+cCodiCr+cLojaCr)
		cCodCli := SA1->A1_COD	//codigo do cliente
		cLojCli := SA1->A1_LOJA	//Loja do Cliente
		cNomCli := SA1->A1_NOME
		DbSelectArea("SA2")
		DbSetOrder(3)
		If DbSeek(xFilial("SA2")+SA1->A1_CGC)
			cCodFor := SA2->A2_COD	//codigo do Fornecedor
			cLojFor := SA2->A2_LOJA	//Loja do Fornecedor
		EndIF
	EndIF
ElseIf cTipo=="2"
	DbSelectArea("SA2")
	DbSetOrder(1)
	If DbSeek(xFilial("SA2")+cCodiCr+cLojaCr)
		cCodFor := SA2->A2_COD	//codigo do Fornecedor
		cLojFor := SA2->A2_LOJA	//Loja do Fornecedor

		DbSelectArea("SA1")
		DbSetOrder(3)
		If !DbSeek(xFilial("SA1")+SA2->A2_CGC)
			cCodCli := SA1->A1_COD	//codigo do cliente
			cLojCli := SA1->A1_LOJA	//Loja do Cliente
			cNomCli := SA1->A1_NOME
		EndIF
	EndIF
EndIf

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 44 , .T., .T. } )  	//Cabecalho
AAdd( aObjects, { 1, 30, .T. , .F. } )  	//list box superior
//tamanho para resolucao 1024*768
//aSizeAut[3]:= 508
//aSizeAut[5]:= 1016
// Fator de reducao de 0.8
for nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
next

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Credito do Cliente (RA/NCC/NCF)   ³
//³    RA  - Recebimento Antecipado (SE1)      ³
//³    NCC - Nota Credito Cliente (SE1)        ³
//³    NCF - Nota Credito Fornecedor (SE2)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SE1.E1_TIPO , SE1.E1_PREFIXO , SE1.E1_PARCELA , SE1.E1_EMISSAO , SE1.E1_NATUREZ, SE1.E1_SALDO , SE1.E1_NUM , SE1.E1_VENCTO , SE1.E1_VALOR "
cQuery += "FROM "+RetSQLName("SE1")+ " SE1 "
cQuery += "WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += "AND SE1.E1_CLIENTE='"+ cCodCli +"' AND SE1.E1_LOJA='"+cLojCli+"' "
cQuery += "AND SE1.E1_TIPO IN ('RA','NCC') "
cQuery += "AND SE1.E1_SALDO>0 "
cQuery += "AND SE1.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .F., .T. )
While !( cAlias )->( EOF() )
	aadd(aTitulos,{( cAlias )->( E1_TIPO ),( cAlias )->( E1_NUM ),( cAlias )->( E1_EMISSAO ),( cAlias )->( E1_NATUREZ ),( cAlias )->( E1_PREFIXO ),( cAlias )->( E1_PARCELA ),( cAlias )->( E1_VENCTO ),( cAlias )->( E1_VALOR ),( cAlias )->( E1_SALDO ) })
	If ( cAlias )->( E1_TIPO )$"NCC"
		nTotReAn+=( cAlias )->( E1_SALDO )
	ElseIf alltrim(( cAlias )->( E1_TIPO ))$"RA"
		nTotCCli+=( cAlias )->( E1_SALDO )
	EndIF
	( cAlias )->( dbSkip() )
EndDo
( cAlias )->(dbCloseArea())
cQuery := "SELECT SE2.E2_TIPO , SE2.E2_PREFIXO , SE2.E2_PARCELA , SE2.E2_EMISSAO , SE2.E2_NATUREZ, SE2.E2_SALDO , SE2.E2_NUM , SE2.E2_VENCTO , SE2.E2_VALOR "
cQuery += "FROM "+RetSQLName("SE2")+ " SE2 "
cQuery += "WHERE SE2.E2_FILIAL = '"+xFilial("SE2")+"' "
cQuery += "AND SE2.E2_FORNECE='"+ cCodFor +"' AND SE2.E2_LOJA='"+cLojFor+"' "
cQuery += "AND SE2.E2_TIPO IN ('NCF') "
cQuery += "AND SE2.E2_SALDO>0 "
cQuery += "AND SE2.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .F., .T. )
While !( cAlias )->( EOF() )
	aadd(aTitulos,{( cAlias )->( E2_TIPO ),( cAlias )->( E2_NUM ),( cAlias )->( E2_EMISSAO ),( cAlias )->( E2_NATUREZ ),( cAlias )->( E2_PREFIXO ),( cAlias )->( E2_PARCELA ),( cAlias )->( E2_VENCTO ),( cAlias )->( E2_VALOR ),( cAlias )->( E2_SALDO ) })
	nTotPcli+=( cAlias )->( E2_SALDO )
	( cAlias )->( dbSkip() )
EndDo
( cAlias )->(dbCloseArea())

If Len(aTitulos) <= 0
	RestArea(cAreaAnt)
	Return
EndIF

DEFINE MSDIALOG oDlgAdTit TITLE (STR0063+": "+cNomCli) From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL //Créditos do Cliente

@ aPosObj[1,1]+002,aPosObj[1,2]+001 LISTBOX oLbox FIELDS HEADER;
(""),;
(STR0064),;	//Numero -2
(STR0065),;	//Emissao - 3
(STR0066),;	//Natureza - 4
(STR0067),;	//Prefixo  - 5
(STR0068),;	//Parcela - 6
(STR0069),;	//Vencimetno - 7
(STR0070),;	//Valor - 8
(STR0071); 	//Saldo - 9
COLSIZES 10,40,40,40,40,40,40,40,50;
SIZE aPosObj[1,4]-2,aPosObj[1,3]  OF oDlgAdTit PIXEL

oLbox:SetArray(aTitulos)
oLbox:bLine := { || { IIf(aTitulos[oLbox:nAt,01]=="NCC",oVerd,IIf(aTitulos[oLbox:nAt,01]=="RA ",oazul,olara)) ,;
aTitulos[oLbox:nAt,02],;
stod(aTitulos[oLbox:nAt,03]),;
aTitulos[oLbox:nAt,04],;
aTitulos[oLbox:nAt,05],;
aTitulos[oLbox:nAt,06],;
stod(aTitulos[oLbox:nAt,07]),;
FG_AlinVlrs(Transform(aTitulos[oLbox:nAt,08],"@E 9,999,999.99")),;
FG_AlinVlrs(Transform(aTitulos[oLbox:nAt,09],"@E 9,999,999.99")) } }

nTam := ( aPosObj[1,4] / 5 ) //varaivel que armazena o resutlado da divisao da tela.

@ aPosObj[2,1]+007,aPosObj[2,2]+(nTam*0) TO aPosObj[2,3],80 LABEL STR0072 OF oDlgAdTit PIXEL  //Recebimento Antecipado
@ aPosObj[2,1]+018,aPosObj[2,2]+007+(nTam*0) BITMAP OXverde RESOURCE "BR_verde" OF oDlgAdTit PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[2,1]+017,aPosObj[2,2]+010+(nTam*0)+10 MSGET oTotReAn VAR FG_AlinVlrs(Transform(nTotReAn,"@E 9,999,999.99")) SIZE 50,08 OF oDlgAdTit PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[2,1]+007,int(aPosObj[2,2]+(nTam*1)) TO aPosObj[2,3],(nTam*1)+80 LABEL STR0073 OF oDlgAdTit PIXEL  //Crédito Cliente
@ aPosObj[2,1]+018,aPosObj[2,2]+007+(nTam*1) BITMAP OXAzul RESOURCE "BR_azul" OF oDlgAdTit PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[2,1]+017,aPosObj[2,2]+010+(nTam*1)+10 MSGET oTotCCli VAR FG_AlinVlrs(Transform(nTotCCli,"@E 9,999,999.99")) SIZE 50,08 OF oDlgAdTit PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[2,1]+007,int(aPosObj[2,2]+(nTam*2)) TO aPosObj[2,3],(nTam*2)+80 LABEL STR0074 OF oDlgAdTit PIXEL  //Contas a Pagar Cliente
@ aPosObj[2,1]+018,aPosObj[2,2]+007+(nTam*2) BITMAP OXLaran RESOURCE "BR_laranja" OF oDlgAdTit PIXEL NOBORDER SIZE 10,10 when .f.
@ aPosObj[2,1]+017,aPosObj[2,2]+010+(nTam*2)+10 MSGET oTotPcli VAR FG_AlinVlrs(Transform(nTotPcli,"@E 9,999,999.99")) SIZE 50,08 OF oDlgAdTit PIXEL COLOR CLR_BLUE when .f.

nToGer:=nTotPcli+nTotCCli+nTotReAn
@ aPosObj[2,1]+007,int(aPosObj[2,2]+(nTam*3)) TO aPosObj[2,3],(nTam*3)+80 LABEL STR0075 OF oDlgAdTit PIXEL  //Total Saldo
@ aPosObj[2,1]+017,aPosObj[2,2]+015+(nTam*3) MSGET oToGer VAR FG_AlinVlrs(Transform(nToGer,"@E 9,999,999.99")) SIZE 50,08 OF oDlgAdTit PIXEL COLOR CLR_BLUE when .f.

@ aPosObj[2,1]+013,aPosObj[2,4]-060 BUTTON oBotSair PROMPT OemToAnsi(STR0076) OF oDlgAdTit SIZE 50,11 PIXEL ACTION oDlgAdTit:End() // "SAIR"
ACTIVATE MSDIALOG oDlgAdTit CENTER

RestArea(cAreaAnt)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FM_Direct  | Autor ³ Rafael Goncalves    ³ Data ³03/11/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia do diretorio e questiona se deseja   ³±±
±±³          ³ cria-lo                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FM_Direct(cPath,lDrive,lMSg)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPath      - Caminho a ser verificado/criado diretorio     ³±±
±±³          ³ lDrive     - Flag para controlar a digitacao da unid. drive³±±
±±³          ³              .T. -> tera que informar a unidade de drive   ³±±
±±³          ³              .F. -> Nao contrala a unidade de drive        ³±±
±±³          ³ lMSg       - Controla se qustiona sobre criar diretorio    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FM_Direct( cPath, lDrive, lMSg )
Local aDir
Local lRet:=.T.
Default lMSg := .T.

If Empty(cPath)
	Return lRet
EndIf

lDrive := IIf(lDrive == Nil, .T., lDrive)

cPath := Alltrim(cPath)
If Subst(cPath,2,2) <> AllTrim(":\ ") .AND. lDrive
	MsgInfo(STR0079) //Unidade de drive n„o especificada
	lRet:=.F.
Else
	cPath := IIf(Right(cPath,1) == AllTrim("\ "), Left(cPath,Len(cPath)-1), cPath)
	aDir  := Directory(cPath,"D")
	If Len(aDir) = 0
		If lMSg
			If MsgYesNo(STR0078+" - "+cPath+" - "+STR0077 ) //Diretorio  -  nao encontrado, deseja cria-lo
				If MakeDir(cPath) <> 0
					Help(" ",1,"NOMAKEDIR")
					lRet := .F.
				EndIf
			EndIf
		Else
			If MakeDir(cPath) <> 0
				Help(" ",1,"NOMAKEDIR")
				lRet := .F.
			EndIf
		EndIF
	EndIf
EndIf
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_VERDIAG ºAutor  ³Manoel            º Data ³  03/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se há Serviços de Diagnosticos na OS		      º±±
±±º          ³ Se houver, os substitui pelos Definitivos Relacionados	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERDIAG(cNrOs)

Local cQuery, cQSER := "SQLSERV"
Local nCntFor := 0

dbSelectArea("VV1")
dbSetOrder(1)
dbSeek(xFilial("VV1")+VS1->VS1_CHAINT)

cQuery := "SELECT VO4.VO4_TIPTEM, VO4.VO4_TIPSER, VO4.VO4_GRUSER, VO4.VO4_CODSER, VO4.R_E_C_N_O_ VO4RECNO, VO6.VO6_SERINT "
cQuery += " FROM "+RetSQLName("VO4")+" VO4 JOIN "+RetSQLName("VO6")+" VO6 ON VO6.VO6_FILIAL = '"+xFilial("VO6")+"'"
cQuery += " AND VO6.VO6_CODSER = VO4.VO4_CODSER AND VO6.VO6_DIAGNO = '1'" // Serviço de Diagnóstico
cQuery += " AND VO6.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VO4.VO4_FILIAL = '"+xFilial("VO4")+"'"
cQuery += " AND VO4.VO4_NUMOSV = '"+cNrOs+"'"
cQuery += " AND VO4_DATDIS =  ' '" // Desconsidera registros Liberados
cQuery += " AND VO4_DATCAN =  ' '" // Desconsidera registros Cancelados
cQuery += " AND VO4_DATFEC =  ' '" // Desconsidera registros Fechados
cQuery += " AND VO4_DATFIN <> ' '" // Data Final do Apontamento
cQuery += " AND VO4_HORFIN <> 0  " // Horario Final do Apontamento
cQuery += " AND VO4.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQSER, .F., .T. )

///////////////////////////////////////////////////////////////////////////////////////
// Se houver Serviços de Diagnósticos apontados na OS adiciona no Vetor de Diagnósticos
///////////////////////////////////////////////////////////////////////////////////////
// aVetDiag
// 1o Elemento - 0=não selecionado, 1 e 2 = selecionados
// 2o Elemento - Tipo de Tempo
// 3o Elemento - Tipo de Serviço
// 4o Elemento - Grupo do Serviço
// 5o Elemento - Código do Serviço
// 6o Elemento - Descrição do Serviço
// 7o Elemento - Recno do VO4
// 8o Elemento - VO6_SERINT
While !(cQSER)->(Eof())
	aadd(aVetDiag,{0,(cQSER)->(VO4_TIPTEM), (cQSER)->(VO4_TIPSER), (cQSER)->(VO4_GRUSER), (cQSER)->(VO4_CODSER),Posicione("VO6",2,xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,(cQSER)->(VO4_CODSER))+(cQSER)->(VO4_CODSER),"VO6_DESSER"),(cQSER)->(VO4RECNO),(cQSER)->(VO6_SERINT)})
	(cQSER)->(DbSkip())
Enddo
(cQSER)->(dbCloseArea())

////////////////////////////////////////////////////////////////
// Adiciona Serviços Definitivos no Vetor de Definitivos
////////////////////////////////////////////////////////////////
// aVetDefi
// 1o Elemento - Tipo de Tempo
// 2o Elemento - Tipo de Serviço
// 3o Elemento - Grupo do Serviço
// 4o Elemento - Código do Serviço
// 5o Elemento - Descrição do Serviço
// 6o Elemento - Nro da linha do Vetor de Diagnóstico Associado
// 7o Elemento - Recno do VS4
DbSelectArea("VS4")
DbSetOrder(1)
DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
nCntFor := 1
While !Eof() .And. VS4->VS4_FILIAL == xFilial("VS4") .And. VS4->VS4_NUMORC == VS1->VS1_NUMORC

	DbSelectArea("VO6")
	DbSetOrder(2)
	DbSeek(xFilial("VO6")+FG_MARSRV(VS1->VS1_CODMAR,VS4->VS4_CODSER) + VS4->VS4_CODSER )

	If VO6->VO6_DIAGNO <> "1"
		aadd(aVetDefi,{VS1->VS1_TIPTSV,VS4->VS4_TIPSER,VS4->VS4_GRUSER,VS4->VS4_CODSER,VO6->VO6_DESSER,"",VS4->(Recno())})
	Endif
	VS4->(DbSkip())
Enddo
///////////////////////////////////////////////////////////////////////////////////////
// Chama Tela de Relacionamento Serviço Definitivo X Diagnóstico e Grava Relacionamento
///////////////////////////////////////////////////////////////////////////////////////
if Len(aVetDefi) > 0
	If Len(aVetDiag) > 0 .and. FS_RELDIAG()
		DBSelectArea("VOI")
		DBSetOrder(1)
		DBSeek(xFilial("VOI")+VS1->VS1_TIPTSV)
		//
		For nCntFor := 1 to len(aVetDiag)
			If aVetDiag[nCntFor,1] <> 0
				nPos := aScan(aVetDefi,{|x| StrZero(nCntFor,2) $ x[6] } )
				If nPos > 0
					VS4->(DbGoto(aVetDefi[nPos,7]))
				Endif
				VO4->(DbGoto(aVetDiag[nCntFor,7]))
				RecLock("VO4",.f.)
				VO4->VO4_TIPTEM	:= VS1->VS1_TIPTSV
				VO4->VO4_FATPAR	:= VS1->VS1_CLIFAT
				VO4->VO4_LOJA  	:= VS1->VS1_LOJA
				VO4->VO4_CODTES	:= VOI->VOI_CODTES
				VO4->VO4_SERINT := aVetDiag[nCntFor,8]
				VO4->VO4_GRUSER	:= VS4->VS4_GRUSER
				VO4->VO4_CODSER	:= VS4->VS4_CODSER
				VO4->VO4_TIPSER	:= VS4->VS4_TIPSER
				VO4->VO4_TEMPAD	:= VS4->VS4_TEMPAD
				VO4->VO4_CODSEC	:= VS4->VS4_CODSEC
				VO4->VO4_SEQSER	:= VS4->VS4_SEQSER
				VO4->VO4_VALCUS	:= VS4->VS4_VALCUS
				VO4->VO4_VALVEN	:= VS4->VS4_VALVEN
				VO4->VO4_PERDES	:= VS4->VS4_PERDES
				VO4->VO4_VALDES	:= VS4->VS4_VALDES
				VO4->VO4_TEMVEN := VS4->VS4_TEMPAD
				VO4->VO4_VALHOR	:= VS4->VS4_VALHOR
				VO4->VO4_DEPINT	:= VS4->VS4_DEPINT
				VO4->VO4_DEPGAR	:= VS4->VS4_DEPGAR
				VO4->VO4_OBSMEM := VS4->VS4_OBSMEM
				//	VO4->VO4_SEQINC := ???????????????????????????????????????????????????????????
				MsUnlock()
			Endif
		Next
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_RELDIAG ºAutor  ³Manoel            º Data ³  03/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relaciona Serviços de Diagnosticos com os Definitivos       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RELDIAG()

Local lDClik  := .f.
Local aFWArrFilAtu := FWArrFilAtu()
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local ii    	:= 0
Local lRet		:= .t.
Local lTtOk 	:= .f.

Private lMarcar := .f.
Private nOpcNeg := 2
Private aVetEmp := {}
Private nLiAnt := 0
Private cTitulo := ""
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oTk := LoadBitmap( GetResources(), "LBTIK" )

DEFINE FONT oTitTela NAME "Arial" SIZE 10,13 BOLD

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
//                L   A     LF    AF
// LF - expande Largura
// AF - expande Altura
aAdd( aObjects, { 0 , 70 , .T. , .T. } ) // ListBox Serviços Definitivos
aAdd( aObjects, { 0 , 30 , .T. , .T. } ) // ListBox Serviços de Diagnóstico
aAdd( aObjects, { 0 , 14 , .T. , .F. } ) // Legenda
aPos := MsObjSize( aInfo, aObjects )

nOpca := 0

While .t.

	DEFINE MSDIALOG oDiagDef FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0097) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS
	oDiagDef:lEscClose := .F.

	// Serviços Definitivos

	@ aPos[1,1]-2,aPos[1,2] TO aPos[1,3],aPos[1,4] LABEL STR0098 OF oDiagDef PIXEL
	@ aPos[1,1]+5,aPos[1,2]+3 LISTBOX oLbDefi FIELDS HEADER  (RetTitle("VS1_TIPTSV")),; // Tipo de Tempo de Serviços
	(RetTitle("VS4_TIPSER")),; // Tipo do Serviço
	(RetTitle("VS4_GRUSER")),; // Grupo do Serviço
	(RetTitle("VS4_CODSER")),; // Codigo do Serviço
	(RetTitle("VS4_DESSER")) ; // Descrição do Serviço
	COLSIZES 50,95,95,95,95,95,95 SIZE aPos[1,4]-9,aPos[1,3]-aPos[1,1]-8 OF oDiagDef PIXEL ON CHANGE FS_RefrDfDg(oLbDefi:nat)
	oLbDefi:SetArray(aVetDefi)
	oLbDefi:bLine := { || { aVetDefi[oLbDefi:nAt,1] ,; // Tipo de Tempo
	aVetDefi[oLbDefi:nAt,2] ,; // Tipo de Serviço
	aVetDefi[oLbDefi:nAt,3] ,; // Grupo do Serviço
	aVetDefi[oLbDefi:nAt,4] ,; // Código do Serviço
	aVetDefi[oLbDefi:nAt,5] }} // Descrição do Serviço

	// Serviços de Diagnóstico
	@ aPos[2,1]-2,aPos[2,2] TO aPos[2,3],aPos[2,4] LABEL STR0099 OF oDiagDef PIXEL

	@ aPos[2,1]+5,aPos[2,2]+3 LISTBOX oLbDiag FIELDS HEADER (" "),;
	(RetTitle("VS1_TIPTSV")),; // Tipo de Tempo de Serviços
	(RetTitle("VO4_TIPSER")),; // Tipo do Serviço
	(RetTitle("VO4_GRUSER")),; // Grupo do Serviço
	(RetTitle("VO4_CODSER")),; // Codigo do Serviço
	(RetTitle("VO4_DESSER")) ; // Descrição do Serviço
	COLSIZES 50,95,95,95,95,95,95 SIZE aPos[2,4]-9,aPos[2,3]-aPos[2,1]-8 OF oDiagDef PIXEL ON DBLCLICK FS_TikDfDg(oLbDiag:nAt,oLbDefi:nAt)
	oLbDiag:SetArray(aVetDiag)
	oLbDiag:bLine := { || { IIf(aVetDiag[oLbDiag:nAt,1]==0,oNo,IIf(aVetDiag[oLbDiag:nAt,1]==1,oTk,oOk)),; //Seleção
	aVetDiag[oLbDiag:nAt,2] ,; // Tipo de Tempo
	aVetDiag[oLbDiag:nAt,3] ,; // Tipo de Serviço
	aVetDiag[oLbDiag:nAt,4] ,; // Grupo do Serviço
	aVetDiag[oLbDiag:nAt,5] ,; // Código do Serviço
	aVetDiag[oLbDiag:nAt,6] }} // Descrição do Serviço

	ACTIVATE MSDIALOG oDiagDef CENTER ON INIT (EnchoiceBar(oDiagDef, { || nOpca := 1, oDiagDef:End() } , { || oDiagDef:End() },,))

	If nOpca <> 1
		if MsgYesNo(STR0096,STR0011)
			lRet := .f.
			exit
		Endif
	Else
		for ii := 1 to Len(aVetDiag)
			If aVetDiag[ii,1] <> 0
				lTtOk := .t.
				Exit
			Endif
		Next
		if lTtOk
			lRet := .t.
			Exit
		Else
			If MsgYesNo(STR0096,STR0011)
				lRet := .f.
				exit
			Endif
		Endif
	Endif

Enddo

// Se retornar .T. é feita a substituição dos Serviços de Diagnósticos com os Definitivos
If !lRet
	aVetDiag := {}
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TikDfDG  ºAutor  ³Manoel            º Data ³  03/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona Diagnosticos e relaciona com Serv Definitivo      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TikDfDG(nLinDiag,nLinDefi)
Local ii := 0

If aVetDiag[nLinDiag,1] == 0 // Sem Selecao
	aVetDiag[nLinDiag,1] := 1
	for ii := 1 to Len(aVetDefi)
		If !aVetDefi[ii,6] $ strzero(nLinDiag,2)
			aVetDefi[nLinDefi,6] += strzero(nLinDiag,2)
			exit
		Endif
	Next
ElseIf aVetDiag[nLinDiag,1] == 1 // Selecionado pela propria linha (pode selecionar)
	aVetDiag[nLinDiag,1] := 0
	for ii := 1 to Len(aVetDefi)
		nPos := at(strzero(nLinDiag,2),aVetDefi[ii,6])
		If nPos > 0
			If nPos == 1
				aVetDefi[ii,6] := Subs(aVetDefi[ii,6],nPos+2)
			Else
				aVetDefi[ii,6] := Subs(aVetDefi[ii,6],1,nPos-1)+Subs(aVetDefi[ii,6],nPos+2)
			Endif
		Endif
	Next
Endif

oLbDefi:SetArray(aVetDefi)
oLbDefi:bLine := { || { aVetDefi[oLbDefi:nAt,1] ,; // Tipo de Tempo
						aVetDefi[oLbDefi:nAt,2] ,; // Tipo de Serviço
						aVetDefi[oLbDefi:nAt,3] ,; // Grupo do Serviço
						aVetDefi[oLbDefi:nAt,4] ,; // Código do Serviço
						aVetDefi[oLbDefi:nAt,5] }} // Descrição do Serviço
oLbDefi:Refresh()

oLbDiag:SetArray(aVetDiag)
oLbDiag:bLine := { || { IIf(aVetDiag[oLbDiag:nAt,1]==0,oNo,IIf(aVetDiag[oLbDiag:nAt,1]==1,oTk,oOk)),; //Seleção
							aVetDiag[oLbDiag:nAt,2] ,; // Tipo de Tempo
							aVetDiag[oLbDiag:nAt,3] ,; // Tipo de Serviço
							aVetDiag[oLbDiag:nAt,4] ,; // Grupo do Serviço
							aVetDiag[oLbDiag:nAt,5] ,; // Código do Serviço
							aVetDiag[oLbDiag:nAt,6] }} // Descrição do Serviço
oLbDiag:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FS_RefrDfDg  ºAutor  ³Manoel            º Data ³  03/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Vetor da ListBox dos Serviços de Diagnostico       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RefrDfDg(nLinDefi)
Local ii  := 0
Local iii := 0
Local i   := 0


if nLiAnt <> nLinDefi
	for ii := 1 to Len(aVetDefi)
		//	If !Empty(aVetDefi[ii,6]) .and. ii <> nLinDefi
		If ii == nLinDefi
			cString := aVetDefi[ii,6]
			For i := 1 to Len(aVetDiag)
				if aVetDiag[i,1] == 1
					aVetDiag[i,1] := 2
				Elseif aVetDiag[i,1] == 2
					aVetDiag[i,1] := 1
				Endif
			Next
		Endif
		//	Endif
	Next
Endif
nLiAnt := nLinDefi

oLbDefi:SetArray(aVetDefi)
oLbDefi:bLine := { || { aVetDefi[oLbDefi:nAt,1] ,; // Tipo de Tempo
aVetDefi[oLbDefi:nAt,2] ,; // Tipo de Serviço
aVetDefi[oLbDefi:nAt,3] ,; // Grupo do Serviço
aVetDefi[oLbDefi:nAt,4] ,; // Código do Serviço
aVetDefi[oLbDefi:nAt,5] }} // Descrição do Serviço
oLbDefi:Refresh()

oLbDiag:SetArray(aVetDiag)
oLbDiag:bLine := { || { IIf(aVetDiag[oLbDiag:nAt,1]==0,oNo,IIf(aVetDiag[oLbDiag:nAt,1]==1,oTk,oOK)),; //Seleção
aVetDiag[oLbDiag:nAt,2] ,; // Tipo de Tempo
aVetDiag[oLbDiag:nAt,3] ,; // Tipo de Serviço
aVetDiag[oLbDiag:nAt,4] ,; // Grupo do Serviço
aVetDiag[oLbDiag:nAt,5] ,; // Código do Serviço
aVetDiag[oLbDiag:nAt,6] }} // Descrição do Serviço
oLbDiag:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FM_TRF261  ºAutor  ³Vinicius Gati       º Data ³  07/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ transfere peças de um arm. para outro.                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FM_TRF261(cB1_COD, cArmFrom, cArmTo, nQtd)
Local aItensNew := {}

Local nTamAEstq := 0
Local nPosAEstq
Local nUltPos
Local l261IntWMS := a261IntWMS()

///////////////////////////////////////////////////
// Posicoes no Vetor de Integracao com o MATA261 //
///////////////////////////////////////////////////
nTamAEstq := 21
If l261IntWMS
	nTamAEstq += 1
EndIf
nTamAEstq += 1
If SD3->(FieldPos("D3_IDDCF"))>0 .And. l261IntWMS
	nTamAEstq += 1
EndIf
If SD3->(FieldPos("D3_OBSERVA")) <> 0
	nTamAEstq += 1
EndIf
///////////////////////////////////////////////////

BEGIN TRANSACTION

SB1->(DbSetOrder(1))
SB1->(DbSeek( xFilial('SB1') + cB1_COD ))

//
// Adiciona cabecalho com numero do documento e data da transferencia modelo II
//
aadd (aItensNew,{ CriaVar('D3_DOC') , ddatabase}) // ???
// sequencia
// produto, descricao, unidade de medida, local/localizacao origem
// produto, descricao, unidade de medida, local/localizacao destino
// numero de serie, lote, sublote, data de validade, qunatidade
// quantidade na 2 unidade, estorno, numero de sequencia
//
//
AADD( aItensNew , Array(nTamAEstq) )
nPosAEstq := Len(aItensNew)
// Produto Origem
aItensNew[ nPosAEstq , 01 ] := SB1->B1_COD
aItensNew[ nPosAEstq , 02 ] := SB1->B1_DESC
aItensNew[ nPosAEstq , 03 ] := SB1->B1_UM
aItensNew[ nPosAEstq , 04 ] := cArmFrom
aItensNew[ nPosAEstq , 05 ] := ""
// Produto Destino
aItensNew[ nPosAEstq , 06 ] := SB1->B1_COD
aItensNew[ nPosAEstq , 07 ] := SB1->B1_DESC
aItensNew[ nPosAEstq , 08 ] := SB1->B1_UM
aItensNew[ nPosAEstq , 09 ] := cArmTo
aItensNew[ nPosAEstq , 10 ] := ""
//
aItensNew[ nPosAEstq , 11 ] := criavar('D3_NUMSERI')
aItensNew[ nPosAEstq , 12 ] := criavar('D3_LOTECTL')
aItensNew[ nPosAEstq , 13 ] := criavar('D3_NUMLOTE')
aItensNew[ nPosAEstq , 14 ] := criavar('D3_DTVALID')
aItensNew[ nPosAEstq , 15 ] := criavar('D3_POTENCI')
aItensNew[ nPosAEstq , 16 ] := nQtd
aItensNew[ nPosAEstq , 17 ] := criavar("D3_QTSEGUM")
aItensNew[ nPosAEstq , 18 ] := criavar("D3_ESTORNO")
aItensNew[ nPosAEstq , 19 ] := criavar("D3_NUMSEQ")
aItensNew[ nPosAEstq , 20 ] := criavar("D3_LOTECTL")
aItensNew[ nPosAEstq , 21 ] := aItensNew[ nPosAEstq , 14 ]
nUltPos := 21
If l261IntWMS
	aItensNew[nPosAEstq,++nUltPos] := criavar("D3_SERVIC")
EndIf
aItensNew[nPosAEstq,++nUltPos] := criavar("D3_ITEMGRD")
If SD3->(FieldPos("D3_IDDCF"))>0 .And. l261IntWMS
	aItensNew[nPosAEstq,++nUltPos] := criavar("D3_IDDCF")
EndIf
If SD3->(FieldPos("D3_OBSERVA")) <> 0
	aItensNew[nPosAEstq,++nUltPos] := criavar("D3_OBSERVA")
EndIf

If ExistBlock("PEVFBXF261")
	aItensNew := ExecBlock("PEVFBXF261",.f.,.f.,{aItensNew})
EndIf

lMsErroAuto := .F.

MSExecAuto({|x| MATA261(x)},aItensNew)

If lMsErroAuto
	// Cancela Gravacao
	lRet := .f.
	DisarmTransaction()
	MostraErro()
	Break
EndIf

END TRANSACTION

Return .T.

/*----------------------------------------------------
 Suavizar a nova verificação de integração com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If FindFunction("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return
