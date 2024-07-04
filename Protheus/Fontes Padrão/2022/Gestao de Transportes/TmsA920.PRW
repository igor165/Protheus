#INCLUDE "TMSA920.ch"
#INCLUDE "protheus.ch"   
#INCLUDE "FILEIO.CH"   
#INCLUDE "sigawin.ch" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA920    ³ Autor ³ Richard Anderson      ³ Data ³01.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao de Titulos, objetivo e Formar Titulos de AWBs.      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCores := {}

Private cCadastro := STR0001 //"Gera Fatura AWB"
Private lTM920Grv  := ExistBlock('TM920Grv')
Private lAWBRepete := DT8->(FieldPos("DT8_CODCIA")) > 0 .And. DT8->(FieldPos("DT8_LOJCIA")) > 0
Private aRotina	 := MenuDef()

Aadd(aCores,{"DD8_STATUS == '1'","BR_VERDE"  })	//-- Aberta
Aadd(aCores,{"DD8_STATUS == '2'","BR_AZUL"   })	//-- Liberada

dbSelectArea("DD8")
dbSetOrder(1)

mBrowse(6,1,22,75,"DD8",,,,,,aCores)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSA920Mnt ³ Autor ³ Richard Anderson     ³ Data ³01.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de manutenção da geração de faturas da AWB          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Mnt(cAlias,cCampo,nOpcE)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis 							 			   	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg,oDlg1,oValorFal,oValorRet,oPanel,nI,nCnt
Local cIndex		:= ""
Local cMarca		:= GetMark()
Local cPerg		    := "TMA920"
Local cSetFilter 	:= DTV->(dbFilter()) // Salva o filtro atual, para restaurar no final da rotina
Local nOpca 		:= 0
Local nX			:= 0
LOCAL nRecDTV		:= 0
Local lContIncl	:= .T.
Local aBut290		:= {}
LOCAL aCampos		:= {}
Local aSize		:= {}
Local oValor		:= {}
Local oFrete		:= {}
Local oRent  		:= {}
Local oQtdTit		:= {}
Local oValorFat	:= {} 
Local oComiss     := {}
Local oIrrf       := {}
Local oIss        := {}
Local cBalcao		:= ''
Local cLockByFat	:= ''                               
Local cAliasSE2   := GetNextAlias()
Local cAliasQry   := GetNextAlias()
Local cStaFin		:= "1" //-- Faturamento em aberto 
Local cSeekDWW    := ""            
Local cSeekDWX    := ""            
Local aValor      := {}
Local cDigito     := ''
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0
Local oStructDTD	:= Nil
Local aFldsDTV		:= {}
Local aCamposDTV	:= {}
Local nPos			:= 0

Private oTipo
Private oFatura   
Private oMark
Private lInverte		:= .F.
Private cTipo			:= CriaVar("DD8_TIPO")
Private cFatura		:= CriaVar("DD8_FATURA",.F.)
Private cForn			:= CriaVar("A2_COD")                       
Private cLoja			:= CriaVar("A2_LOJA")
Private cPrefix 		:= CriaVar("E2_PREFIXO",.T.)
Private dDataAte		:= dDataBase
Private dDataDe		:= dDataBase
Private cFOriDe		:= ""
Private cFOriAte		:= ""
Private nValor	 		:= 0
Private nValorLQ 		:= 0
private nFrete			:= 0
Private nComiss		:= 0
Private nIrrf     	:= 0
Private nIss      	:= 0
Private cNat			:= Space(10)
Private aVenc			:= {}
Private nIndex			:= 0
Private lFocus			:= .F.
Private nBalcaoTodos	:= 1   
Private aSx3Box   	:= RetSx3Box( Posicione('SX3', 2, 'DTV_STAFIN', 'X3CBox()' ),,, 1 )
Private nValorFat		:= 0
Private aSetKey      := {}

// Variáveis abaixo determinam qual a DATA e HORA do inicio das movimentações no formato NOVO (trabalhando como PADRAO) do Protheus
Private dDataINI		:= CTOD(SubStr(GetMV("MV_AWBINI"),1,At('|',GetMV("MV_AWBINI"))-1))
Private cHoraINI		:= SubStr(GetMV("MV_AWBINI"),At('|',GetMV("MV_AWBINI"))+1,Len(GetMV("MV_AWBINI")))

//-- AWB's faltantes
Private aHeader		:= {}
Private aCols			:= {} 
Private aHeadFal		:= {}
Private aColsFal		:= {}
Private oGetDFal 
Private nValorFal		:= 0
//-- Desconto retroativo
Private aHeadRet		:= {}
Private aColsRet		:= {}
Private oGetDRet 
Private nValorRet		:= 0

Pergunte(cPerg,.F.)

nOpcE	:= aRotina[nOpcE,4]
aTam	:= TamSX3("DD8_CODCIA")
cForn	:= Space(aTam[1])                                   
aTam	:= TamSX3("DD8_LOJCIA")
cLoja	:= Space(aTam[1])

Aadd(aBut290,{"S4WB011N",{||TMSA920Psq(oMark,cAlias)} 					 , STR0011, STR0002}) //"Pesquisar - <F4>"
Aadd(aSetKey,{ VK_F4    ,{||TMSA920Psq(oMark,cAlias)} } )

If nOpcE == 3 .Or. nOpcE == 4	
	Aadd(aBut290,{"BUDGETY" ,{||TMSA920Dsc(oValor,oRent,oValorFat)}	 , STR0012, STR0053 }) //"Desconto  - <F5>" //"Desconto"
	Aadd(aSetKey,{ VK_F5    ,{||TMSA920Dsc(oValor,oRent,oValorFat)} } )
EndIf	

Aadd(aBut290,{"BMPPARAM",{||TMSA920Vis()} 									 , STR0013, STR0014}) //"AWB - <F6>"###"AWB"
Aadd(aSetKey,{ VK_F6    ,{||TMSA920Vis()} } )

Aadd(aBut290,{"BMPORD"  ,{||TMSA920Fal(nOpcE,.T.,oValorFal,oValorFat)}, STR0015, STR0052}) //"AWB's Faltantes - <F7>"###"AWB's Faltantes"
Aadd(aSetKey,{ VK_F7    ,{||TMSA920Fal(nOpcE,.T.,oValorFal,oValorFat)} } )

Aadd(aBut290,{"BUDGET"  ,{||TMSA920Ret(nOpcE,.T.,oValorRet,oValorFat)}, STR0061, STR0064}) //"Desconto Retroativo - <F8>"###"Desc.Retroativo"
Aadd(aSetKey,{ VK_F8    ,{||TMSA920Ret(nOpcE,.T.,oValorRet,oValorFat)} } )

If nOpcE <> 3
	cFatura	:= DD8->DD8_FATURA
	cForn		:= DD8->DD8_CODCIA 
	cLoja		:= DD8->DD8_LOJCIA
	nComiss	:= DD8->DD8_COMISS
	nIrrf		:= DD8->DD8_IRRF
	nIss		:= DD8->DD8_ISS
	If nOpcE != 2 .And. DD8->DD8_STATUS == '2' //-- Liberada
		Aviso(STR0017,STR0018, {"Ok"} ) //"ATENÇÃO"###"Esta fatura já foi liberada!"
		lContIncl := .F.
	ElseIf nOpcE == 4
		
		SetMVValue(cPerg,"MV_PAR01",cForn)
		SetMVValue(cPerg,"MV_PAR02",cLoja)

		lContIncl    := Pergunte(cPerg,.T.)
		dDataDe      := MV_PAR03
		dDataAte     := MV_PAR04
		nBalcaoTodos := MV_PAR05
		cFOriDe      := MV_PAR06
		cFOriAte     := MV_PAR07
	EndIf
Else
	lContIncl		:= Pergunte(cPerg,.T.)
	cForn				:= MV_PAR01
	cLoja				:= MV_PAR02
	dDataDe			:= MV_PAR03
	dDataAte			:= MV_PAR04
	nBalcaoTodos	:= MV_PAR05
	cFOriDe			:= MV_PAR06
	cFOriAte			:= MV_PAR07
EndIf

If !lContIncl
	Return
EndIf

If nBalcaoTodos == 1
	cBalcao := STR0054 //'Balcão'
ElseIf nBalcaoTodos == 2
	cBalcao := STR0055 //'Não Balcão'
Else
	cBalcao := STR0056 //'Todas'
EndIf

If nOpcE != 2
	cLockByFat := 'FATAWB'+cForn
	If !LockByName(cLockByFat,.F.,.T.)
		MsgAlert(STR0057+AllTrim(Posicione('SA2',1,xFilial('SA2')+cForn,'A2_NREDUZ'))+'!',STR0017) //'Existe outro usuário realizando o faturamento da cia aérea '
		Return NIL
	EndIf
EndIf			

cAlias  := "DTV"
nValor  := 0	// valor total dos titulos,mostrado no rodape do browse
nQtdTit := 0	// quantidade de titulos,mostrado no rodape do browse
nFrete  := 0
nRent   := 0
nOpcA   := 0

CursorWait()
cIndex := CriaTrab(nil,.f.)
cChave := "Dtos(DTV_DATEMI)+DTV_NUMAWB+DTV_FILORI+DTV_FILDES"
IndRegua(cAlias,cIndex,cChave,,TMSA920Fil(nOpcE),OemToAnsi(STR0019)) //"Selecionando Registros..."
nIndex := RetIndex(cAlias)
dbSelectArea(cAlias)
dbSetOrder(nIndex+1)
dbGoTop()

If Bof() .And. Eof()
	CursorArrow()
	Help(" ",1,"RECNO")
	Set Filter to
	dbSetOrder(1)
	RetIndex("DTV")
	// Restaura o filtro
	Set Filter To &cSetFilter.
	dbGoTop()
	FErase(cIndex+OrdBagExt())
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	Return Nil
EndIf

AADD(aCampos,{"DTV_OK","","  ",""})

aCamposDTV := {"DTV_STAFIN","DTV_DATEMI","DTV_NUMAWB","DTV_DIGAWB", "DTV_NUMORI", "DTV_FILORI","DTV_FILDES","DTV_VAWB","DTV_VALFRE","DTV_VCALC",;
				"DTV_VAWBLQ","DTV_DECRES","DTV_RENTAB","DTV_VIAGEM","DTV_QTDVOL","DTV_PESO","DTV_HOREMI"}
oStructDTV := FWFormStruct(1, "DTV")
aFldsDTV := oStructDTV:aFields

For nX := 1 To Len(aCamposDTV)
	If (nPos := aScan(aFldsDTV, {|x| AllTrim(x[3]) == aCamposDTV[nX] })) > 0
		If AllTrim(aFldsDTV[nPos][3]) == "DTV_STAFIN"
			aAdd(aCampos, {{|| aSx3Box[ Ascan( aSx3Box, { | e | e[ 2 ] == DTV->DTV_STAFIN } ) , 3 ]}, "", aFldsDTV[nPos][2], GetSX3Cache(aFldsDTV[nPos][3], "X3_PICTURE")})
		Else
			aAdd(aCampos, {aFldsDTV[nPos][3], "", aFldsDTV[nPos][1], GetSX3Cache(aFldsDTV[nPos][3], "X3_PICTURE")})
		EndIf
	EndIf
Next

FreeObj(oStructDTD)

aSize(aFldsDTV, 0)
aFldsDTV := Nil

dbSelectArea(cAlias)
dbSetOrder(nIndex+1)
While DTV->(!Eof())
	nVAWB    := DTV->DTV_VAWB
	nVAWBLq  := DTV->DTV_VAWBLQ
	nValFre  := DTV->DTV_VALFRE
	nRenTab  := DTV->DTV_RENTAB
	If Empty(nValFre) .Or. Empty(nVAWB) .Or. Empty(nVAWBLq)
		cFilSF1 := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
		aValor  := TMSA320Vlr(cFilSF1, DTV->DTV_NUMAWB, DTV->DTV_DIGAWB, DTV->DTV_CODCIA, DTV->DTV_LOJCIA)

		nVAWBLQ := aValor[1] // VALFRE
		nVAWB   := aValor[2] // VALTOT

		cQuery := "SELECT SUM(DT6.DT6_VALFRE) VALDT6 "
		cQuery += "  FROM " + RetSqlName("DTX") + " DTX "               
		cQuery += "  JOIN " + RetSqlName("DUD") + " DUD "
		cQuery += "    ON DUD.DUD_FILIAL  = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUD.DUD_FILORI  = DTX.DTX_FILORI "
		cQuery += "   AND DUD.DUD_VIAGEM  = DTX.DTX_VIAGEM "
		cQuery += "   AND DUD.DUD_MANIFE  = DTX.DTX_MANIFE "
		If	lDTX_SERMAN 
			cQuery += "   AND DUD.DUD_SERMAN  = DTX.DTX_SERMAN "
		EndIf	
		cQuery += "   AND DUD.D_E_L_E_T_  = ' ' "
		cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "    ON DT6.DT6_FILIAL  = '" + xFilial("DT6") + "' "
		cQuery += "   AND DT6.DT6_FILDOC  = DUD.DUD_FILDOC "
		cQuery += "   AND DT6.DT6_DOC     = DUD.DUD_DOC    "
		cQuery += "   AND DT6.DT6_SERIE   = DUD.DUD_SERIE  "
		cQuery += "   AND DT6.D_E_L_E_T_  = ' ' "  
		cQuery += " WHERE DTX.DTX_FILIAL  = '" + xFilial("DTX")  + "' "
		cQuery += "   AND DTX.DTX_FILMAN  = '" + DTV->DTV_FILORI + "' "
		cQuery += "   AND DTX.DTX_NUMAWB  = '" + DTV->DTV_NUMAWB + "' "
  		If lAWBRepete      
  		   cQuery += "   AND DTX.DTX_CODCIA = '" + DTV->DTV_CODCIA  + "' AND DTX.DTX_LOJCIA ='" + DTV->DTV_LOJCIA +"' "	   

			cDigito := TMSA320Dig(DTV->DTV_DATEMI,DTV->DTV_DIGAWB)
			If Len(cDigito) > 0
				cQuery += "   AND DTX.DTX_DIGAWB = '" + cDigito + "' "
			EndIf
  		Endif   
		cQuery += "   AND DTX.D_E_L_E_T_  = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
		TcSetField(cAliasQry,"VALDT6","N",TamSX3("DT6_VALTOT")[1],TamSX3("DT6_VALTOT")[2])
		If (cAliasQry)->(!Eof())
			nValFre := (cAliasQry)->VALDT6
		EndIf
		(cAliasQry)->(dbCloseArea())
		dbSelectArea(cAlias)
		nRentab := Round(((nVAWBLq - DTV->DTV_DECRES) / nValFre) * 100,2)  
		If (nVAWBLq  - DTV->DTV_DECRES) > nValFre
			nRentab := nRentab * -1
		EndIf                                                        
		RecLock('DTV',.F.)
		DTV->DTV_VAWB   := nVAWB
		DTV->DTV_VAWBLQ := nVAWBLq
		DTV->DTV_VALFRE := nValFre
		DTV->DTV_RENTAB := nRentab
		MsUnLock() 
	EndIf
	// tratamento do status do financeiro - testa
	cStaFin := DTV->DTV_STAFIN
	If cStaFin $ "1;4;5"
		cStaFin := "1" //-- Faturamento em aberto
		aDoc    := TMSA320Awb( DTV->DTV_NUMAWB, DTV->DTV_DIGAWB, .T., DTV->DTV_CODCIA, DTV->DTV_LOJCIA, DTV->DTV_DATEMI )
		cFilSF1 := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek(cFilSF1+aDoc[1]+aDoc[2]+DTV->(DTV_CODCIA+DTV_LOJCIA)))
			cQuery := " SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_EMISSAO, E2_SALDO, E2_DECRESC, E2_BAIXA "
			cQuery += "   FROM "+RetSqlName("SE2")+" SE2 "
			cQuery += "  WHERE SE2.E2_FILIAL  = '"+xFilial("SE2") +"'"
			cQuery += "    AND SE2.E2_FORNECE = '"+SF1->F1_FORNECE+"'"
			cQuery += "    AND SE2.E2_LOJA    = '"+SF1->F1_LOJA   +"'"
			cQuery += "    AND SE2.E2_PREFIXO = '"+SF1->F1_PREFIXO+"'"
			cQuery += "    AND SE2.E2_NUM     = '"+SF1->F1_DUPL   +"'"
			cQuery += "    AND SE2.E2_TIPO   IN ( 'NF ', 'AWB' )" 
			cQuery += "    AND SE2.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
			TcSetField(cAliasSE2,'E2_EMISSAO','D',8,0)
			TcSetField(cAliasSE2,'E2_BAIXA  ','D',8,0)
			TcSetField(cAliasSE2,'E2_SALDO  ','N',TamSX3('E2_SALDO  ')[1],TamSX3('E2_SALDO  ')[2])
			TcSetField(cAliasSE2,'E2_DECRESC','N',TamSX3('E2_DECRESC')[1],TamSX3('E2_DECRESC')[2])
			If (cAliasSE2)->(!Eof())
				If (cAliasSE2)->E2_SALDO > 0 .And. ((cAliasSE2)->E2_SALDO <> nVAWB .Or. (cAliasSE2)->E2_DECRESC <> DTV->DTV_DECRES)
					cStaFin := "5" //-- Problema integração
				ElseIf !Empty((cAliasSE2)->E2_BAIXA) 
					cStaFin := "4" //-- Sem saldo
				EndIf
			Else																						
				cStaFin := "5" //-- Problema integração
			EndIf
			(cAliasSE2)->(dbCloseArea())										
			dbSelectArea(cAlias)
		Else
			cStaFin := "5" //-- Problema integração
		EndIf
		RecLock('DTV',.F.)
		DTV->DTV_STAFIN := cStaFin
		MsUnLock() 
	EndIf
	// fim tratamento financeiro - testa	
	If nOpcE == 3 
		RecLock('DTV',.F.)
		DTV->DTV_OK := Iif(DTV->DTV_STAFIN $ '1;3',cMarca,'')
		MsUnLock()
		If DTV->DTV_STAFIN $ '1;3' //-- Faturamento em aberto e encerrado
			nValor   += DTV->DTV_VAWB   - DTV->DTV_DECRES
			nValorLQ += DTV->DTV_VAWBLQ - DTV->DTV_DECRES
			nFrete   += DTV->DTV_VALFRE
			nQtdTit  += 1
		EndIf
	Else
		If !Empty(DTV->DTV_FATURA)		
			RecLock('DTV',.F.)
			DTV->DTV_OK := cMarca
			MsUnLock() 
			nValor   += DTV->DTV_VAWB   - DTV->DTV_DECRES
			nValorLQ += DTV->DTV_VAWBLQ - DTV->DTV_DECRES
			nFrete   += DTV->DTV_VALFRE
			nQtdTit  += 1
		EndIf
	EndIf		
   DTV->(dbSkip())
EndDo

//-- Atualiza Total AWB's faltantes
TMSA920Fal(nOpcE,.F.,,, .F.)

//-- Atualiza Desconto retroativo
TMSA920Ret(nOpcE,.F.)

//-- Calcula valor da fatura
TMCalcFat()
DTV->(dbGoTop()) 

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

CursorArrow()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize   := MsAdvSize()

DEFINE MSDIALOG oDlg1 TITLE cCadastro+" [ "+AllTrim(Posicione("SA2",1,xFilial("SA2")+cForn+cLoja,"A2_NREDUZ"))+" ]" From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

oDlg1:lMaximized := .T.

oPanel:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,40,40,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

@ 0.6 , 01		Say OemToAnsi(STR0020) FONT oDlg1:oFont OF oPanel //"Nro. Fatura"
@ 0.6 , 10		Say OemToAnsi(STR0021) FONT oDlg1:oFont OF oPanel //"Valor Selec."
@ 0.6 , 15		Say OemToAnsi(STR0022) FONT oDlg1:oFont OF oPanel //"Valor Frete"
@ 0.6 , 20		Say OemToAnsi(STR0023) FONT oDlg1:oFont OF oPanel //"Rentabilidade"
@ 0.6 , 25		Say OemToAnsi(STR0024) FONT oDlg1:oFont OF oPanel //"AWB Selec."
@ 0.6 , 29		Say OemToAnsi(STR0025) FONT oDlg1:oFont OF oPanel //"Valor Faltante"
@ 0.6 , 34		Say OemToAnsi(STR0064) FONT oDlg1:oFont OF oPanel //"Desc.Retroativo"
@ 0.6 , 40  	Say OemToAnsi(STR0026) FONT oDlg1:oFont OF oPanel //"Comissão"
@ 0.6 , 47		Say OemToAnsi(STR0027) FONT oDlg1:oFont OF oPanel //"IRRF"
@ 0.6 , 52		Say OemToAnsi(STR0028) FONT oDlg1:oFont OF oPanel //"ISS"
@ 0.6 , 55		Say OemToAnsi(STR0029) FONT oDlg1:oFont OF oPanel //"Valor Fatura"

@ 1.6 , 01		Get oFatura	  VAR cFatura	  When    nOpcE == 3          FONT oDlg1:oFont VALID TMSA920Val() PICTURE "@9" SIZE 15,06
@ 1.6 , 10		Say oValor	  VAR nValor	  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel

@ 1.6 , 14.8	Say oFrete	  VAR nFrete	  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel

@ 1.6 , 21		Say oRent	  VAR nRent      Picture "@E 999,999.99%"    FONT oDlg1:oFont OF oPanel
@ 1.6 , 27		Say oQtdTit   VAR nQtdTit	  Picture "999"               FONT oDlg1:oFont OF oPanel
@ 1.6 , 30		Say oValorFal VAR nValorFal  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel
@ 1.6 , 35.5	Say oValorRet VAR nValorRet  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel
@ 1.6 , 40		Say oComiss	  VAR nComiss	  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel 
@ 1.6 , 45		Say oIRRF  	  VAR nIRRF  	  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel 
@ 1.6 , 50		Say oIss   	  VAR nIss   	  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel
@ 1.6 , 55		Say oValorFat VAR nValorFat  Picture "@E 999,999,999.99" FONT oDlg1:oFont OF oPanel 

@ 0.4 , 0.8	   To  2.65,63   OF  oPanel

oMark := MsSelect():New(cAlias,"DTV_OK","DTV_STAFIN<>'1'",aCampos,@lInverte,@cMarca,{45,oDlg1:nLeft,oDlg1:nBottom,oDlg1:nRight})

oMark:bMark := {|| TMSA920Mrk(cMarca,lInverte,oValor,oFrete,oRent,oQtdTit,oValorFat,oMark) }
oMark:oBrowse:lhasMark    := .T.
oMark:oBrowse:lCanAllmark := .T.
oMark:oBrowse:bAllMark    := {|| Iif(nOpcE==5,Nil,TMSA920All(cMarca,oValor,oFrete,oRent,oQtdTit,oValorFat,oMark)) }
oMark:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT

If nOpcE != 3 .And. nOpcE != 4
	oMark:bAval := { || .F. }
EndIf

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| nOpca := 1,;
Iif(TMSA920TOk(nOpcE,oRent,oComiss,oIrrf,oIss,oValorFat),oDlg1:End(),nOpca := 0)},;
	{|| nOpca := 0,oDlg1:End()},,aBut290 )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

If nOpcA == 1 .And. nOpcE != 2

	DTV->(dbSetOrder(nIndex+1))
	DTV->(dbGoTop())
	
	cCodCia := DTV->DTV_CODCIA
	cLojCia := DTV->DTV_LOJCIA
		
	Begin Transaction
	
	While DTV->(!Eof())
	
		DTV->(dbSkip())
		nRecDTV := DTV->(RecNo())
		DTV->(dbSkip(-1))
		
		If DTV->DTV_OK == cMarca
			If nOpcE == 5
				RecLock("DTV",.F.)
				DTV->DTV_FATURA := Space(Len(DTV->DTV_FATURA))
				DTV->DTV_STAFIN := '1' //-- Faturamento em aberto
				MsUnLock()
			Else								
				RecLock("DTV",.F.)
				DTV->DTV_FATURA := cFatura
				MsUnLock()
			EndIf				
		Else
			If nOpcE == 4 
				RecLock("DTV",.F.)
				DTV->DTV_FATURA := Space(Len(DTV->DTV_FATURA))
				MsUnLock()
			EndIf
		EndIf
		//-- PE apos a gravação de cada tabela
		If lTm920grv
			ExecBlock('TM920GRV',.F.,.F., { 'DTV', nOpcE } )  
		EndIf
		DTV->(dbGoTo(nRecDTV))
	EndDo
	DD8->(dbSetOrder(1))
	If nOpcE == 3 .Or. nOpcE == 4
		If DD8->(!dbSeek(xFilial('DD8')+cFatura))
			RecLock("DD8",.T.)
			DD8->DD8_FILIAL := xFilial('DD8')
			DD8->DD8_FATURA := cFatura
			DD8->DD8_CODCIA := cCodCia
			DD8->DD8_LOJCIA := cLojCia
			DD8->DD8_DATFAT := dDataBase
		Else
			RecLock("DD8",.F.)
		EndIf
		If nOpcE == 4 .And. nQtdTit == 0
			dbDelete()
		Else
			DD8->DD8_COMISS := nComiss
			DD8->DD8_IRRF   := nIrrf
			DD8->DD8_ISS    := nIss
			DD8->DD8_VALOR  := nValor
			DD8->DD8_DECRET := nValorRet
			DD8->DD8_STATUS := '1' //-- Em Aberto
		EndIf
		MsUnLock()
	ElseIf nOpcE == 5 //-- Exclusao
		If DD8->(dbSeek(xFilial('DD8')+cFatura))
			RecLock("DD8",.F.)
			dbDelete()
			MsUnlock()
		EndIf
	EndIf
	//-- PE apos a gravação de cada tabela
	If lTm920grv
		ExecBlock('TM920GRV',.F.,.F., { 'DD8', nOpcE } )  
	EndIf

	//-- AWB'S Faltantes
	DWW->(dbSetOrder(1))
	//-- Desconto retroativo
	DWX->(dbSetOrder(1))
	If nOpcE == 3 .Or. nOpcE == 4
		//-- AWB'S Faltantes
		If Empty(aColsFal)
			//-- Somente carrega aHeader e aCols
			TMSA920Fal(nOpcE,.F.)
		EndIf
		nUsado := Len(aHeadFal)
		For nCnt := 1 To Len(aColsFal)
			If !GdDeleted(nCnt,aHeadFal,aColsFal)
				If Empty(GDFieldGet('DWW_NUMAWB',nCnt,,aHeadFal,aColsFal))
					Loop
				EndIf					
				If DWW->(!MsSeek(xFilial("DWW")+cFatura+cForn+cLoja+GdFieldGet("DWW_ITEM",nCnt,,aHeadFal,aColsFal)))
					RecLock("DWW",.T.)
					DWW->DWW_FILIAL := xFilial("DWW")
					DWW->DWW_FATURA := cFatura
					DWW->DWW_CODCIA := cForn  
					DWW->DWW_LOJCIA := cLoja                      
					DWW->DWW_ITEM   := GdFieldGet("DWW_ITEM",nCnt,,aHeadFal,aColsFal)
				Else
					RecLock("DWW",.F.)
				EndIf
				For nI := 1 To nUsado
					If aHeader[nI,10] != 'V'
						DWW->(FieldPut(FieldPos(aHeadFal[nI,2]),GDFieldGet(aHeadFal[nI,2],nCnt,,aHeadFal,aColsFal)))
					EndIf
				Next
				MsUnlock()
			ElseIf DWW->(dbSeek(xFilial("DWW")+cFatura+cForn+cLoja+GdFieldGet("DWW_ITEM",nCnt,,aHeadFal,aColsFal)))
				RecLock("DWW",.F.)
				dbDelete()
				MsUnLock()
			EndIf
				//-- PE apos a gravação de cada tabela
			If lTm920grv
				ExecBlock('TM920GRV',.F.,.F., { 'DWW', nOpcE } )  
			EndIf
		Next nCnt
		//-- Desconto Retroativo
		DWX->(dbSetOrder(1))
		If Empty(aColsRet)
			//-- Somente carrega aHeader e aCols
			TMSA920Ret(nOpcE,.F.)
		EndIf
		nUsado := Len(aHeadRet)
		For nCnt := 1 To Len(aColsRet)
			If !GdDeleted(nCnt,aHeadRet,aColsRet)
				If Empty(GDFieldGet('DWX_NUMAWB',nCnt,,aHeadRet,aColsRet))
					Loop
				EndIf					
				If DWX->(!dbSeek(xFilial("DWX")+cFatura+cForn+cLoja+GdFieldGet("DWX_ITEM",nCnt,,aHeadRet,aColsRet)))
					RecLock("DWX",.T.)
					DWX->DWX_FILIAL := xFilial("DWX")
					DWX->DWX_FATURA := cFatura
					DWX->DWX_CODCIA := cForn  
					DWX->DWX_LOJCIA := cLoja                      
					DWX->DWX_ITEM   := GdFieldGet("DWX_ITEM",nCnt,,aHeadRet,aColsRet)
				Else
					RecLock("DWX",.F.)
				EndIf
				For nI := 1 To nUsado
					If aHeadRet[nI,10] != 'V'
						DWX->(FieldPut(FieldPos(aHeadRet[nI,2]),GDFieldGet(aHeadRet[nI,2],nCnt,,aHeadRet,aColsRet)))
					EndIf
				Next
				MsUnlock()
			ElseIf DWX->(dbSeek(xFilial("DWX")+cFatura+cForn+cLoja+GdFieldGet("DWX_ITEM",nCnt,,aHeadRet,aColsRet)))
				RecLock("DWX",.F.)
				dbDelete()
				MsUnLock()
			EndIf
			//-- PE apos a gravação de cada tabela
			If lTm920grv
				ExecBlock('TM920GRV',.F.,.F., { 'DWX', nOpcE } )  
			EndIf
		Next nCnt
	ElseIf nOpcE == 5
		//-- AWB'S Faltantes
		DWW->(dbSeek(cSeekDWW := xFilial("DWW")+cFatura+cForn+cLoja))
		While DWW->(!Eof()) .And. DWW->(DWW_FILIAL+DWW_FATURA+DWW_CODCIA+DWW_LOJCIA) == cSeekDWW
			RecLock("DWW",.F.)
			dbDelete()
			MsUnLock()
			DWW->(dbSkip())
		EndDo
		//-- Desconto retroativo
		DWX->(dbSeek(cSeekDWX := xFilial("DWX")+cFatura+cForn+cLoja))
		While DWX->(!Eof()) .And. DWX->(DWX_FILIAL+DWX_FATURA+DWX_CODCIA+DWX_LOJCIA) == cSeekDWX
			RecLock("DWX",.F.)
			dbDelete()
			MsUnLock()
			DWX->(dbSkip())
		EndDo
	EndIf	
	End Transaction
EndIf

dbSelectArea("DTV")
RetIndex("DTV")
// Restaura o filtro
Set Filter To &cSetFilter.
If !Empty(cIndex)
	FErase(cIndex+OrdBagExt())
	cIndex := ""
Endif

If nOpcE != 2
	//-- Libera Lock do faturamento
	UnLockByName(cLockByFat,.F.,.T.)
EndIf	

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920Val  ³ Autor ³ Richard Anderson   ³ Data ³ 11.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função de validação                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920    												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA920Val()

Local lRet     := .T.
Local nVAWB    := 0
Local nValFre  := 0
Local nRentab  := 0
Local cCampo   := AllTrim(ReadVar())
Local aAreaDD8 := DD8->(GetArea())
Local aRet     := {}
Local cDigito  := ''

If "CFATURA" $ cCampo .And. !Empty(cFatura)
	cFatura:= StrZero(Val(cFatura),Len(DD8->DD8_FATURA))
	oFatura:Refresh()
	DD8->(dbSetOrder(1))
	If DD8->(dbSeek(xFilial('DD8')+cFatura+cForn+cLoja))
		lRet := .F.
		Help('',1,'JAGRAVADO')
	EndIf
ElseIf "M->DWW_NUMAWB" $ cCampo .Or. "M->DWW_DIGAWB" $ cCampo
	cDigito := ''
	M->DWW_NUMAWB := StrZero(Val(Iif("M->DWW_DIGAWB"$cCampo,GDFieldGet('DWW_NUMAWB'),M->DWW_NUMAWB)),Len(DWW->DWW_NUMAWB))		
	If DWW->(FieldPos("DWW_DIGAWB")) > 0 
		cDigito := TMSA320Dig(,Iif("M->DWW_NUMAWB"$cCampo,GDFieldGet('DWW_DIGAWB'),M->DWW_DIGAWB))
	EndIf
	DTV->(dbSetOrder(1))
	If DTV->(dbSeek(xFilial('DTV')+M->DWW_NUMAWB+cDigito))
		If !MsgYesNo(STR0068,{'Sim','Não'})
			lRet := .F.
		EndIf
	EndIf
ElseIf "M->DWW_VALFRE" $ cCampo .Or. "M->DWW_VAWB" $ cCampo
	lRet := Positivo()
	If lRet
		If "M->DWW_VALFRE" $ cCampo 
			nVAWB   := GDFieldGet("DWW_VAWB")
			nValFre := M->DWW_VALFRE
		Else
			nVAWB   := M->DWW_VAWB		
			nValFre := GDFieldGet("DWW_VALFRE")
		EndIf		
		If nValFre > 0
			nRentab := Round((nVAWB / nValFre) * 100,2)  
			If nVAWB > nValFre
				nRentab := nRentab * -1
			EndIf
			GDFieldPut('DWW_RENTAB',nRentab)
		EndIf
	EndIf	
ElseIf "M->DWX_NUMAWB" $ cCampo .Or. "M->DWX_DIGAWB" $ cCampo
	If Vazio()
		GDFieldPut('DWX_VAWB'  ,0,n)
		GDFieldPut('DWX_FATRET',Space(Len(DTV->DTV_FATURA)),n)
		GDFieldPut('DWX_DECRES',0,n)
		If DWX->(FieldPos("DWX_DIGAWB")) > 0 
			GDFieldPut('DWX_DIGAWB',Space(Len(DWX->DWX_DIGAWB)),n)
		EndIf	  
	Else 
		cDigito := ''
		If DWX->(FieldPos("DWX_DIGAWB")) > 0 
			cDigito := TMSA320Dig(,Iif("M->DWX_NUMAWB"$cCampo,GDFieldGet('DWX_DIGAWB'),M->DWX_DIGAWB))
		EndIf	  
		aRet := TMSA920Pos(StrZero(Val(Iif("M->DWX_DIGAWB"$cCampo,GDFieldGet('DWX_NUMAWB'),M->DWX_NUMAWB)),Len(DWX->DWX_NUMAWB)),cForn,cLoja,cDigito)
      If Empty(aRet[1])
			Help('',1,'REGNOIS')
			lRet := .F.
		EndIf		
		If lRet .And. Empty(aRet[2])
			MsgAlert(STR0065)
			lRet := .F.
		EndIf			
		If lRet
			DWX->(dbSetOrder(2))
			If DWX->(dbSeek(xFilial('DWX')+StrZero(Val(Iif("M->DWX_DIGAWB"$cCampo,GDFieldGet('DWX_NUMAWB'),M->DWX_NUMAWB)),Len(DWX->DWX_NUMAWB))+cDigito+cForn+cLoja))
				MsgAlert(STR0066+DWX->DWX_FATURA)
				lRet := .F.
			EndIf
			DWX->(dbSetOrder(1))
		EndIf
		If lRet
			GDFieldPut('DWX_NUMAWB',aRet[1],n)
			GDFieldPut('DWX_VAWB'  ,aRet[3],n)
			GDFieldPut('DWX_FATRET',aRet[2],n)
			If DWX->(FieldPos("DWX_DIGAWB")) > 0 
				GDFieldPut('DWX_DIGAWB',aRet[4],n)
			EndIf	  
		Else
			If DWX->(FieldPos("DWX_DIGAWB")) > 0 
				GDFieldPut('DWX_DIGAWB',Space(Len(DWX->DWX_DIGAWB)),n)
			EndIf	  
			GDFieldPut('DWX_VAWB'  ,0,n)
			GDFieldPut('DWX_FATRET',Space(Len(DTV->DTV_FATURA)),n)
			GDFieldPut('DWX_DECRES',0,n)
		EndIf	
	EndIf
EndIf	

RestArea(aAreaDD8)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³TMSA920Psq³ Autor ³ Richard Anderson      ³ Data ³ 01.07.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de pesquisa              					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920    												              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TMSA920Psq(oMark,cAlias)
Local cAliasAnt := Alias()
Local nRecno    := 0
Local nOrdInd   := IndexOrd()		

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)
		
dbSelectArea(cAlias)
nRecno := Recno()
AxPesqui()

DbSelectArea(cAliasAnt)
dbSetOrder(nOrdInd)
oMark:oBrowse:Refresh(.T.)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920Mrk ³ Autor ³ Richard Anderson     ³ Data ³ 24.04.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca titulos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920 													                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Mrk(cMarca,lInverte,oValor,oFrete,oRent,oQtdTit,oValorFat,oMark)

If	DTV->( IsMark( 'DTV_OK', ThisMark(), ThisInv() ) )
	RecLock("DTV",.F.)
	DTV->DTV_OK	:= Iif(lInverte,'',cMarca)
	MsUnLock()
	If lInverte
		nQtdTit  -= 1
		nValor   -= DTV->DTV_VAWB   - DTV->DTV_DECRES
		nValorLQ -= DTV->DTV_VAWBLQ - DTV->DTV_DECRES
		nFrete   -= DTV->DTV_VALFRE
	Else
		nQtdTit  += 1
		nValor   += DTV->DTV_VAWB   - DTV->DTV_DECRES
		nValorLQ += DTV->DTV_VAWBLQ - DTV->DTV_DECRES
		nFrete   += DTV->DTV_VALFRE
	EndIf			
ElseIf DTV->DTV_STAFIN == '1' //-- Faturamento em Aberto
	RecLock("DTV",.F.)
	DTV->DTV_OK	:= Iif(lInverte,cMarca,'')
	MsUnLock()
	If lInverte
		nQtdTit  += 1
		nValor   += DTV->DTV_VAWB - DTV->DTV_DECRES
		nValorLQ += DTV->DTV_VAWBLQ - DTV->DTV_DECRES
		nFrete   += DTV->DTV_VALFRE
	Else			
		nQtdTit  -= 1
		nValor   -= DTV->DTV_VAWB - DTV->DTV_DECRES
		nValorLQ -= DTV->DTV_VAWBLQ - DTV->DTV_DECRES
		nFrete   -= DTV->DTV_VALFRE
	EndIf			
EndIf
If nQtdTit > 0 
	//-- Calcula valor da fatura
	TMCalcFat()
Else
	nRent    := 0
	nValor   := 0
	nFrete   := 0
	nValorFat:= 0
EndIf	
	                                                        
oValor:Refresh()
oFrete:Refresh()
oRent:Refresh()                                                
oQtdTit:Refresh()
oValorFat:Refresh()
oMark:oBrowse:Refresh()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920All ³ Autor ³ Richard Anderson     ³ Data ³ 24.04.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca / Desmarca todos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920 													                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920All(cMarca,oValor,oFrete,oRent,oQtdTit,oValorFat,oMark)

Local nRecDTV  := DTV->(Recno())
Local lInverte := DTV->( IsMark( 'DTV_OK', ThisMark(), ThisInv() ) ) 

CursorWait()

nQtdTit   := 0
nValor    := 0
nValorLQ  := 0
nFrete    := 0 
nRent     := 0
nValorFat := 0

DTV->(dbGoTop())

While DTV->(!Eof())
	If DTV->DTV_STAFIN $ '1;3' 
		If lInverte
			RecLock("DTV",.F.)
			DTV->DTV_OK	:= ''
			MsUnLock()
		Else
			RecLock("DTV",.F.)
			DTV->DTV_OK	:= cMarca
			MsUnLock()
			nQtdTit  += 1
			nValor   += DTV->DTV_VAWB   - DTV->DTV_DECRES
			nValorLQ += DTV->DTV_VAWBLQ - DTV->DTV_DECRES
			nFrete   += DTV->DTV_VALFRE
		EndIf
	EndIf			
	DTV->(dbSkip())
EndDo
If nValor > 0
	//-- Calcula valor da fatura
	TMCalcFat()
EndIf	
DTV->(dbGoto(nRecDTV)) 
CursorArrow()
oValor:Refresh()
oFrete:Refresh()
oRent:Refresh()
oQtdTit:Refresh()
oValorFat:Refresh()
oMark:oBrowse:Refresh()

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TMSA920Fil ³ Autor ³ Cicero J. Silva     ³ Data ³27.02.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao para a criacao do indice condicional				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920 													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Fil(nOpc)

Local   cFiltro := ""
DEFAULT nOpc    := 1
   	                        
If nOpc == 3 .Or. nOpc == 4
   cFiltro += "DTV_FILORI >= '" + cFOriDe + "'"
   cFiltro += " .And. DTV_FILORI <= '" + cFOriAte + "'"
	cFiltro += " .And. DTV_CODCIA == '" + cForn    + "'"
  	cFiltro += " .And. DTV_LOJCIA == '" + cLoja    + "'" 
  	If nOpc == 4
		cFiltro += " .And. (DTV_FATURA == '" + cFatura  + "'"
		cFiltro += " .Or.   Dtos(DTV_DATEMI) >= '" + Dtos(dDatade)  + "'"
		cFilTro += "  .And. Dtos(DTV_DATEMI) <= '" + Dtos(dDataAte) + "'"
		cFilTro += "  .And. DTV_FATURA == '"+Space(Len(DTV->DTV_FATURA)) + "'"
	   If nBalcaoTodos <> 3 
		   cFiltro += " .And. DTV_BALCAO == '" + Alltrim(Str(nBalcaoTodos)) + "'"  //Todas AWBs internas
		   If nBalcaoTodos == 1
		   	cFilTro += ".And. !Empty(DTV_NUMORI)"
			EndIf	 
	   EndIf
	   cFiltro += ")"
	Else	   
		cFiltro += " .And. Dtos(DTV_DATEMI) >= '" + Dtos(dDatade)  + "'"
		cFilTro += " .And. Dtos(DTV_DATEMI) <= '" + Dtos(dDataAte) + "'"
		cFilTro += " .And. DTV_FATURA == '"+Space(Len(DTV->DTV_FATURA)) + "'"
   	If nBalcaoTodos <> 3 
		   cFiltro += " .And. DTV_BALCAO == '" + Alltrim(Str(nBalcaoTodos)) + "'"  //Todas AWBs internas
		   If nBalcaoTodos == 1
	   		cFilTro += ".And. !Empty(DTV_NUMORI)"
			EndIf	 
   	EndIf
	EndIf   	
Else                                                                                
	cFilTro += " DTV_FILIAL == '" + xFilial("DTV") + "' .And. " 
	cFiltro += " DTV_CODCIA == '" + cForn   + "' .And. "
  	cFiltro += " DTV_LOJCIA == '" + cLoja   + "' .And. " 
	cFiltro += " DTV_FATURA == '" + cFatura + "'"
EndIf	    

Return cFiltro

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920TOk ³ Autor ³ Richard Anderson    ³ Data ³01.07.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação de confirmação                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920TOk(nOpc,oRent,oComiss,oIrrf,oIss,oValorFat)

Local lRet    := .T.
Local nOpcA   := 0
Local oDlgGet,oPanel,oGetCom,oGetIrf,oGetIss
Local aSay    := { RetTitle('DD8_COMISS') , RetTitle('DD8_IRRF') , RetTitle('DD8_ISS') }
Local nGetCom := nComiss
Local nGetIrf := nIrrf 
Local nGetIss := nIss  

If nOpc == 3 .Or. nOpc == 4
	DEFINE MSDIALOG oDlgGet FROM 00,00 TO 150,290 PIXEL TITLE STR0030 //"Complemento da Fatura"

		@ 013, 005 SAY aSay[1] SIZE 100,009 OF oPanel PIXEL COLOR CLR_BLUE
		@ 013, 085 MSGET oGetCom VAR nGetCom PICTURE PesqPict("DD8", "DD8_COMISSA") SIZE 50, 010 OF oDlgGet PIXEL VALID nGetCom <= nValor

		@ 030, 005 SAY aSay[2] SIZE 100,009 OF oPanel PIXEL COLOR CLR_BLUE
		@ 030, 085 MSGET oGetIrf VAR nGetIrf PICTURE PesqPict("DD8", "DD8_IRRF")    SIZE 50, 010 OF oDlgGet PIXEL VALID nGetIrf <= nValor

		@ 047, 005 SAY aSay[3] SIZE 100,009 OF oPanel PIXEL COLOR CLR_BLUE
		@ 047, 085 MSGET oGetIss VAR nGetIss PICTURE PesqPict("DD8", "DD8_ISS ")    SIZE 50, 010 OF oDlgGet PIXEL VALID nGetIss <= nValor

		DEFINE SBUTTON FROM 62,115 TYPE 1 OF oDlgGet ENABLE ACTION (nOpcA := 1, oDlgGet:End())

	ACTIVATE MSDIALOG oDlgGet CENTERED

	If nOpcA == 1 
		nComiss  := nGetCom
		nIrrf    := nGetIrf
		nIss 	   := nGetIss
		//-- Calcula valor da fatura
		TMCalcFat()
      oRent:Refresh()
      oComiss:Refresh()
      oIrrf:Refresh()
      oIss:Refresh()
		oValorFat:Refresh()                                                       
	EndIf
EndIf			

If (nOpc == 3 .Or. nOpc == 4) .And. nValor <= 0   
	MsgAlert(STR0070) //Selecione um documento para efetuar o faturamento. 
	lRet := .F.
ElseIf nOpc == 3 .And. Val(cFatura) == 0 
	MsgAlert(STR0058) //'Informe o número da fatura!'
	lRet := .F.
ElseIf nOpc == 4
	lRet := MsgYesNo(OemToAnsi(STR0031),OemToAnsi(STR0032) ) //"Confirma alteração ?"###"Alteraçao"
Elseif  nOpc == 5
	lRet := MsgYesNo(OemToAnsi(STR0033) ,OemToAnsi(STR0034) ) //"Confirma exclusão ?"###"Exclusão"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TMSA920Tip ³ Autor ³ Richard Anderson    ³ Data ³ 25.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checa o Tipo do titulo informado 						        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Tip(cTipTit)

Local lRet := .T.     

lRet := ExistCpo('SX5','05'+cTipTit)
If lRet .And. AllTrim(cTipTit) == 'PR'
	Aviso(STR0017,STR0035, {"Ok"} ) //"Nao pode ser tipo provisório!"
	lRet := .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA920Pag º Autor ³ Richard Anderson º Data ³  01/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³ Liberacao do Pagamento, Geracao titulo definitivo          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA920                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Pag(cAlias,nReg,nOpcE)

Local   nI				:= 0
Local   aArea			:= GetArea()
Local   cFilAWB		:= Padr(SuperGetMv("MV_FILAWB",,""),FWGETTAMFILIAL)
Local   cPrefix		:= Padr(SuperGetMv("MV_PRLAWB",,""),Len(SE2->E2_TIPO))
Local   lPrefix     	:= Empty(cPrefix)
Local   cNatTit		:= Padr(SuperGetMv("MV_NTLAWB",,""),Len(SE2->E2_NATUREZ))
Local   cTipTit		:= 'FT'
Local   cFatura     	:= DD8->DD8_FATURA
Local   cCodCia     	:= DD8->DD8_CODCIA
Local   cLojCia     	:= DD8->DD8_LOJCIA
Local   cNomCia     	:= Posicione('SA2',1,xFilial('SA2')+DD8->(DD8_CODCIA+DD8_LOJCIA),'A2_NREDUZ')
Local   nValFat     	:= DD8->DD8_VALOR
Local   aMoedas     	:= {}
Local   cVar        	:= ""
Local   nOpcA       	:= 0
Local   nComiss     	:= DD8->DD8_COMISS
Local   nVlIrrf     	:= DD8->DD8_IRRF
Local   nVlIss     	:= DD8->DD8_ISS
Local   nVlDecRet    := DD8->DD8_DECRET
Local   nMoedFat    	:= 0
Local   cAliasSE2   	:= GetNextAlias()
Local   cFilSF1     	:= ""
Local   aFatPag     	:= Array(15)
Local   dDataDe     	:= Ctod('')
Local   dDataAte    	:= Ctod('')
Local   aAWBs       	:= {}
Local   oDlg
Local   oCbx
Local   aDoc        	:= {}
Local   lAWBVal     	:= .T.
Local   aTitDup     	:= {} 
Local   aMsgErr     	:= {}
Local   aVisErr     	:= {}
Local   cMsgErr     	:= STR0036 //"As AWB's abaixo relacionadas, não possuem os títulos ou estão com o valor diferente do título:"
Local   nCnt        	:= 0
Local   nA           := 0
Local   cMoedaTx     := ""
Local   nTotMoedas   := 0

If DD8->DD8_STATUS == '2' //-- Liberada
	Aviso(STR0017,STR0018, {"Ok"} ) //"Esta fatura já foi liberada!"
	Return NIL
EndIf

If !Empty(xFilial('SE2')) .And. Empty(cFilAWB)
	cFilAWB := cFilAnt
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura aTxMoedas         ³
//³ [1] -> Nome Moeda          	³
//³ [2] -> Taxa a Ser Utilizada	³
//³ [3] -> Picture          	³
//³ [4] -> Taxa do dia atual    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
nTotMoedas := MoedFin()
For nA := 1	To nTotMoedas
	cMoedaTx :=	Str(nA,IIf(nA <= 9,1,2))
	If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
		AAdd( aMoedas, StrZero(Val(cMoedaTx),2) + " " + GetMv("MV_MOEDA"+cMoedaTx) ) 
	Else
		Exit
	Endif
Next

aMoedas := ASort(aMoedas)

DEFINE MSDIALOG oDlg FROM	22,9 TO 335,540 TITLE cCadastro+STR0037 PIXEL //" Libera Pagto."

@ 020, 014 MSGET cPrefix	PICTURE "@!"                        VALID !Empty(cPrefix) ;
																					SIZE  010, 11 OF oDlg PIXEL WHEN lPrefix

@ 020, 040 MSGET cTipTit   PICTURE "@!"  F3 "05"               VALID !Empty(cTipTit) .And. TMSA920Tip(cTipTit); 
                                                               SIZE  010, 11 OF oDlg PIXEL
                                                               
@ 020, 068 MSGET cNatTit   PICTURE "@!"  F3 "SED"              VALID ExistCpo('SED',cNatTit,1);
                                                               SIZE  055, 11 OF oDlg PIXEL
                                                               
@ 020, 123 COMBOBOX oCbx   VAR   cVar ITEMS aMoedas 				SIZE  046, 55 OF oDlg PIXEL

@ 052, 014 MSGET cCodCia   PICTURE "@!"                        SIZE  050, 11 OF oDlg PIXEL WHEN .F.
@ 052, 068 MSGET cLojCia	PICTURE "@!"                        SIZE  015, 11 OF oDlg PIXEL WHEN .F.
@ 052, 123 MSGET nValFat   PICTURE "@E 999,999,999.99"         SIZE  065, 11 OF oDlg PIXEL WHEN .F.

@ 075, 014 MSGET cNomCia   PICTURE "@!"                        SIZE  175, 11 OF oDlg PIXEL WHEN .F.

@ 113, 014 MSGET nComiss   PICTURE "@E 999,999,999.99"         SIZE  065, 11 OF oDlg PIXEL WHEN .F.                                                               

@ 113, 096 MSGET nVlIrrf   PICTURE "@E 999,999,999.99"         SIZE  051, 11 OF oDlg PIXEL WHEN .F.
@ 113, 165 MSGET nVlIss    PICTURE "@E 999,999,999.99"         SIZE  051, 11 OF oDlg PIXEL WHEN .F.

@ 010, 014 SAY STR0038  OF oDlg PIXEL //"Prefixo"
@ 010, 040 SAY STR0039  OF oDlg PIXEL //"Tipo"
@ 010, 068 SAY STR0040  OF oDlg PIXEL //"Natureza"
@ 010, 123 SAY STR0041  OF oDlg PIXEL //"Moeda"

@ 045, 014 SAY STR0042  OF oDlg PIXEL //"Cia Aerea"
@ 045, 068 SAY STR0043  OF oDlg PIXEL //"Loja"
@ 045, 123 SAY STR0029  OF oDlg PIXEL //"Valor Fatura"

@ 068, 014 SAY STR0044  OF oDlg PIXEL //"Nome Cia"

@ 106, 014 SAY STR0026  OF oDlg PIXEL //"Comissão"
@ 106, 096 SAY STR0027  OF oDlg PIXEL //"IRRF"
@ 106, 165 SAY STR0028  OF oDlg PIXEL //"ISS"

@ 004, 007 TO 036, 225 OF oDlg PIXEL
@ 040, 007 TO 095, 225 OF oDlg PIXEL
@ 099, 007 TO 131, 225 OF oDlg PIXEL

DEFINE SBUTTON FROM 07, 230 TYPE 1 ACTION (nOpcA:=1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 24, 230 TYPE 2 ACTION oDlg:End()             ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcA == 1
	If MsgYesNo(STR0045; //"Para efetivação desta fatura, é Obrigatório que se tenha as primeiras vias de todos os documnentos ( AWB e Faturas ) em Mãos."
  		        +STR0046,STR0047) //" Confirma ? "###"Confirmação"
  		        
		nMoedFat := Val(Substr(cVar,1,2))
		//-- Obtem o numero da fatura e ja confirma este numero
		cFatura  := DD8->DD8_FATURA
		
		//Descricao do Array aFatPag
		//[01] - Prefixo
		//[02] - Tipo
		//[03] - Numero da Fatura (se o numero estiver em branco obtem pelo FINA290)
		//[04] - Natureza
		//[05] - Data de
		//[06] - Data Ate
		//[07] - Fornecedor
		//[08] - Loja
		//[09] - Fornecedor para geracao
		//[10] - Loja do fornecedor para geracao
		//[11] - Condicao de pagto
		//[13] - ARRAY com os titulos da fatura
		//[13,1] Prefixo
		//[13,2] Numero
		//[13,3] Parcela
		//[13,4] Tipo
		//[13,5] Título localizado na geracao de fatura (lógico). Iniciar com falso.
		//[14] - Valor de decrescimo
		//[15] - Valor de acrescimo

		Afill(aFatPag,'')
		aFatPag[01] := cPrefix
		aFatPag[02] := cTipTit
		aFatPag[03] := cFatura
		aFatPag[04] := cNatTit
		aFatPag[05] := dDataBase
		aFatPag[06] := dDataBase
		aFatPag[07] := cCodCia
		aFatPag[08] := cLojCia
		aFatPag[09] := cCodCia
		aFatPag[10] := cLojCia
		aFatPag[11] := Posicione('SA2',1,xFilial('SA2')+cCodCia+cLojCia,'A2_COND')
		aFatPag[12] := Val(Substr(cVar,1,2))
		aFatPag[13] := {}
		aFatPag[14] := nComiss	+ nVlDecRet
		aFatPag[15] := nVlIrrf	+ nVlIss
		
		Begin Transaction
		
		DTV->(dbSetOrder(3))
		DTV->(dbSeek(xFilial('DTV')+cFatura))
		While DTV->(!Eof()) .And. DTV->(DTV_FILIAL+DTV_FATURA) == xFilial('DTV')+cFatura
			aDoc := TMSA320Awb( DTV->DTV_NUMAWB, DTV->DTV_DIGAWB,.T., DTV->DTV_CODCIA, DTV->DTV_LOJCIA, DTV->DTV_DATEMI )
			SF1->(dbSetOrder(1))
			cFilSF1 := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
			lAWBVal := .F.
			If SF1->(dbSeek(cFilSF1+aDoc[1]+aDoc[2]+DTV->(DTV_CODCIA+DTV_LOJCIA)))
				cQuery := "SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_EMISSAO, E2_SALDO, E2_DECRESC "
				cQuery += "  FROM "+RetSqlName("SE2")+" SE2 "
				cQuery += " WHERE SE2.E2_FILIAL  = '"+xFilial("SE2") +"'"
				cQuery += "   AND SE2.E2_FORNECE = '"+SF1->F1_FORNECE+"'"
				cQuery += "   AND SE2.E2_LOJA    = '"+SF1->F1_LOJA   +"'"
				cQuery += "   AND SE2.E2_PREFIXO = '"+SF1->F1_PREFIXO+"'"
				cQuery += "   AND SE2.E2_NUM     = '"+SF1->F1_DUPL   +"'"
				cQuery += "   AND SE2.E2_SALDO   =  "+AllTrim(Str(DTV->DTV_VAWB  ,TamSX3('DTV_VAWB  ')[1],TamSX3('DTV_VAWB  ')[2]))   
				cQuery += "   AND SE2.E2_DECRESC =  "+AllTrim(Str(DTV->DTV_DECRES,TamSX3('DTV_DECRES')[1],TamSX3('DTV_DECRES')[2]))   
				cQuery += "   AND SE2.E2_SDDECRE =  "+AllTrim(Str(DTV->DTV_DECRES,TamSX3('DTV_DECRES')[1],TamSX3('DTV_DECRES')[2]))   
				cQuery += "   AND SE2.E2_TIPO   IN ( 'NF ', 'AWB' )"
				cQuery += "   AND SE2.E2_BAIXA   = ' '  "
				cQuery += "   AND SE2.D_E_L_E_T_ = ' '  "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
				TcSetField(cAliasSE2,'E2_EMISSAO','D',8,0)
				TcSetField(cAliasSE2,'E2_SALDO  ','N',TamSX3('E2_SALDO  ')[1],TamSX3('E2_SALDO  ')[2])
				TcSetField(cAliasSE2,'E2_DECRESC','N',TamSX3('E2_DECRESC')[1],TamSX3('E2_DECRESC')[2])
				While (cAliasSE2)->(!Eof())
					lAWBVal := .T.
					If Empty(dDataDe)  .Or. (cAliasSE2)->E2_EMISSAO < dDataDe
						dDataDe  := (cAliasSE2)->E2_EMISSAO
					EndIf
					If Empty(dDataAte) .Or. (cAliasSE2)->E2_EMISSAO > dDataAte
						dDataAte := (cAliasSE2)->E2_EMISSAO
					EndIf
					If Ascan(aFatPag[13],{ | e | e[1]+e[2]+e[3]+e[4] == (cAliasSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) }) > 0
						Aadd(aTitDup, { DTV->DTV_FILORI, DTV->DTV_NUMAWB, DTV->DTV_DATEMI } )
					EndIf											
					Aadd(aFatPag[13],{ (cAliasSE2)->E2_PREFIXO, (cAliasSE2)->E2_NUM, (cAliasSE2)->E2_PARCELA, (cAliasSE2)->E2_TIPO, .F. })
					(cAliasSE2)->(dbSkip())
				EndDo
				(cAliasSE2)->(dbCloseArea())
				Aadd(aAWBs,DTV->(Recno()))
			EndIf
			If !lAWBVal
				If Empty(aMsgErr)
					Aadd(aMsgErr,{ cMsgErr,'00','' })
					Aadd(aMsgErr,{ ''     ,'00','' })
				EndIf
				Aadd(aMsgErr,{ STR0048+DTV->(DTV_FILORI+'-'+DTV_NUMAWB)+STR0049+Dtoc(DTV->DTV_DATEMI),'00','' })					 //"No.AWB: "###" Emissão: "
			EndIf
			If Len(aTitDup) > 0
				If Len(aMsgErr) > 0
					Aadd(aMsgErr,{ '','00','' })
				EndIf					
				Aadd(aMsgErr,{ STR0050, "00", "" }) //"AWB's com títulos duplicados: "
				Aadd(aMsgErr,{ ''     , "00", "" })
				For nCnt := 1 To Len(aTitDup)
					Aadd(aMsgErr,{ STR0048+aTitDup[nCnt,1]+'-'+aTitDup[nCnt,2]+STR0049+Dtoc(aTitDup[nCnt,3]),'00','' })					 //"No.AWB: "
				Next nCnt
			EndIf									
			DTV->(dbSkip())
		EndDo
		
		CursorArrow()
		
		If Len(aMsgErr) > 0
			AaddMsgErr( aMsgErr, @aVisErr)
			TmsMsgErr( aVisErr )
		Else				
			//-- Atualiza range de datas para gerar a fatura
			aFatPag[05] := dDataDe
			aFatPag[06] := dDataAte
			
			//-- Gera a Fatura
			If Fina290(3,aFatPag)
				DD8->(dbSetOrder(1))
				If DD8->(dbSeek(xFilial("DD8")+cFatura))
					RecLock("DD8",.F.)
					DD8->DD8_PREFIX := cPrefix
					DD8->DD8_TIPO	 := cTipTit
					DD8->DD8_STATUS := '2'
					DD8->DD8_DATLIB := dDatabase
					DD8->DD8_USRLIB := Substr(cUsuario,7,15)
					MsUnLock()
				EndIf
				For nI := 1 To Len(aAWBs)
					DTV->(dbGoTo(aAWBs[nI]))
					//-- Atualiza AWB´s
					RestArea(aArea)
					RecLock("DTV",.F.)
					DTV->DTV_DTLFAT := dDatabase
					DTV->DTV_USLFAT := Substr(cUsuario,7,15)
					DTV->DTV_STAFIN := '3' //-- Faturado
					MsUnLock()
				Next nI				
			EndIf
		EndIf			
			
		End Transaction
	EndIf
EndIf

Return nil 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA920Can º Autor ³ Richard Anderson º Data ³  16/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancelamento da fatura                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA920                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Can(cAlias,nReg,nOpcE)

Local   cSeekSE2 := ''
Local   lAchou   := .F.
Local   aArea    := GetArea()
Local   aAreaSE2 := SE2->(GetArea())
Local   cFatura  := DD8->DD8_FATURA
//Campos usados para amarracao das faturas geradas com o mesmo prefixo, tipo e numeração, mas para fornecedores e lojas diferentes.
Private lDuplFat := SE2->(FieldPos("E2_FATFOR")) > 0 .And. SE2->(FieldPos("E2_FATLOJ")) > 0 

If DD8->DD8_STATUS != '2'
	MsgAlert(STR0059) //'Fatura não está liberada!'
Else	
	SE2->(dbSetOrder(1))
	SE2->(dbSeek(cSeekSE2 := xFilial('SE2')+DD8->(DD8_PREFIX+DD8_FATURA)))
	While SE2->(!Eof()) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cSeekSE2
		If SE2->(E2_FORNECE+E2_LOJA) == DD8->(DD8_CODCIA+DD8_LOJCIA) .And. SE2->E2_TIPO == DD8->DD8_TIPO
			lAchou := .T.
			Exit
		EndIf
		SE2->(dbSkip())
	EndDo
	If lAchou			
		SaveInter()
		Pergunte('AFI290',.F.)
		If FA290Can("SE2",SE2->(Recno()),4)
			DTV->(dbSetOrder(3))
			DTV->(dbSeek(xFilial('DTV')+cFatura))
			While DTV->(!Eof()) .And. DTV->(DTV_FILIAL+DTV_FATURA) == xFilial('DTV')+cFatura
				RecLock("DTV",.F.)
				DTV->DTV_STAFIN := '1' //-- Faturado em aberto
				MsUnLock()
				DTV->(dbSkip())
			EndDo
			DD8->(dbSetOrder(1))
			If DD8->(dbSeek(xFilial("DD8")+cFatura))
				RecLock("DD8",.F.)
				DD8->DD8_PREFIX := ''
				DD8->DD8_TIPO	 := ''
				DD8->DD8_STATUS := '1' //-- Aberta
				DD8->DD8_DATLIB := Ctod('')
				DD8->DD8_USRLIB := ''
				MsUnLock()
			EndIf
		EndIf		
		RestInter()
	Else
		MsgAlert(STR0060) //'Erro ao localizar fatura no financeiro!'
	EndIf
EndIf

RestArea(aAreaSE2)
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA920Dsc ³ Autor ³ Richard Anderson    ³ Data ³26/06/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite informar desconto para a AWB                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA920                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Dsc(oValor,oRent,oValorFat)
Local cFilSF1    := ''
Local aAreaAtu   := GetArea()
Local aAreaSF1   := SF1->(GetArea())
Local cAliasSE2  := GetNextAlias()
Local cSay       := RetTitle('DTV_VAWB')
Local nDecres    := 0
Local nGetVAwb   := DTV->DTV_VAWB
Local nDifAwb    := (DTV->DTV_VAWB - DTV->DTV_VAWBLQ) // Apura o valor do imposto a ser descontado.
Local nRntAWB    := 0
Local nOpcA      := 0
Local aDoc       := {}
Local oDlgGet
Local oPanel
Local oVAWB   

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

DEFINE MSDIALOG oDlgGet FROM 00,00 TO 100,290 PIXEL TITLE STR0051 + DTV->DTV_NUMAWB      //"Desconto para a AWB "
	oPanel := tPanel():New(03,03,"",oDlgGet,,,,,CLR_WHITE,140, 30, .T.) 

	@ 013, 005 SAY cSay SIZE 100,009 OF oPanel PIXEL COLOR CLR_BLUE
	@ 013, 085 MSGET oVAWB VAR nGetVAWB PICTURE PesqPict("DTV", "DTV_VAWB") SIZE 50, 010 OF oDlgGet PIXEL VALID nGetVAWB <= DTV->DTV_VAWB

	DEFINE SBUTTON FROM 37,115 TYPE 1 OF oDlgGet ENABLE ACTION (nOpcA := 1, oDlgGet:End())

ACTIVATE MSDIALOG oDlgGet CENTERED

If nOpcA == 1 
	nDecres := DTV->DTV_VAWB - nGetVAWB
	aDoc    := TMSA320Awb( DTV->DTV_NUMAWB, DTV->DTV_DIGAWB, .T., DTV->DTV_CODCIA, DTV->DTV_LOJCIA, DTV->DTV_DATEMI )
	cFilSF1 := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
	SF1->(dbSetOrder(1))
	If SF1->(dbSeek(cFilSF1+aDoc[1]+aDoc[2]+DTV->(DTV_CODCIA+DTV_LOJCIA)))
		
		nValor   -= (DTV->DTV_VAWB   - DTV->DTV_DECRES)
		nValorLQ -= (DTV->DTV_VAWBLQ - DTV->DTV_DECRES)

		nRntAWB  := Round(((nGetVAWB-nDifAwb) / DTV->DTV_VALFRE) * 100,2)  

		If nGetVAWB > DTV->DTV_VALFRE
			nRntAWB := nRntAWB * -1
		EndIf 
		
		nValor   += nGetVAWB
		nValorLQ += (nGetVAWB - nDifAWB)
	
		RecLock('DTV',.F.)
		DTV->DTV_DECRES := nDecres
		DTV->DTV_RENTAB := nRntAWB
		MsUnLock()
		//-- Calcula valor da fatura
		TMCalcFat()
		oValor:Refresh()
		oRent:Refresh()
		oValorFat:Refresh()
		//-- Atualiza SE2
		cQuery := "SELECT R_E_C_N_O_ SE2RECNO "
		cQuery += "  FROM "+RetSqlName("SE2")+" SE2 "
		cQuery += " WHERE SE2.E2_FILIAL  = '"+xFilial("SE2") +"'"
		cQuery += "   AND SE2.E2_FORNECE = '"+SF1->F1_FORNECE+"'"
		cQuery += "   AND SE2.E2_LOJA    = '"+SF1->F1_LOJA   +"'"
		cQuery += "   AND SE2.E2_PREFIXO = '"+SF1->F1_PREFIXO+"'"
		cQuery += "   AND SE2.E2_NUM     = '"+SF1->F1_DUPL   +"'"
		cQuery += "   AND SE2.E2_TIPO   IN ( 'NF ', 'AWB' )"
		cQuery += "   AND SE2.D_E_L_E_T_ = ' '  "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
		If (cAliasSE2)->(!Eof())
			SE2->(dbGoTo((cAliasSE2)->SE2RECNO))
			RecLock('SE2',.F.)
			SE2->E2_DECRESC := nDecres
			SE2->E2_SDDECRE := nDecres
			MsUnLock()
		EndIf
		(cAliasSE2)->(dbCloseArea())
	Else
		MsgAlert(STR0067)
	EndIf
EndIf

RestArea(aAreaSF1)
RestArea(aAreaAtu)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA920LegºAutor  ³ Richard Anderson   º Data ³  01/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legenda da situacao do Titulo                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMSA920                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Leg()

Local aLegenda	:= { {"BR_VERDE", "Aberta"   },;	// Aberta
					 	  {"BR_AZUL" , "Liberada" }}		// Liberada
                     
BrwLegenda( cCadastro, "Status", aLegenda  )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA920Fal ³ Autor ³ Richard Anderson      ³ Data ³26/08/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Digita AWB's faltantes da fatura                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA920                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Fal(nOpcx,lEdita,oValorFal,oValorFat, lAlerta)
Local   oFatura,oNomCia,oDlg
Local   nUsado		:= 0
Local   nOpcA		:= 0
Local   aGet		:= {}
Local   aPosObj	:= {} 
Local   aObjects	:= {}
Local   aSize		:= MsAdvSize( .F. )             
Local   nCntFor	:= 0
Local   aNoFields	:= {}
Local   cNomCia	:= Posicione('SA2',1,xFilial('SA2')+cForn+cLoja,'A2_NREDUZ')
Local   aAreaAtu	:= GetArea()
Local   aAreaDTV	:= DTV->(GetArea())
Local   aAreaDWW	:= DWW->(GetArea())
Local   nCnt		:= 0
Local 	aFldsTmp	:= {}
Default lEdita		:= .T.
Default oValorFal	:= NIL
Default lAlerta 	:= .T.

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

If nOpcx == 3 .And. Empty(cFatura)
	If lAlerta
		MsgAlert(STR0058) //'Informe o número da fatura!'
	EndIf
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)	
	Return NIL
EndIf	

aHeader := {}
aCols   := {}

Aadd(aNoFields,"DWW_FATURA")
Aadd(aNoFields,"DWW_CODCIA")
Aadd(aNoFields,"DWW_LOJCIA")

aFldsTmp := ApBuildHeader("DTV")
For nCnt := 1 To Len(aFldsTmp)
	If aFldsTmp[nCnt][2] $ "DTV_FATURA,DTV_NOMCIA"
		aAdd(aGet, {aFldsTmp[nCnt][1], aFldsTmp[nCnt][3], GetSX3Cache(aFldsTmp[nCnt][2], "X3_F3")})
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aHeader.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFldsTmp :=  ApBuildHeader("DWW", aNoFields)
For nCnt := 1 To Len(aFldsTmp)
	nUsado += 1
	aAdd(aHeader, aFldsTmp[nCnt])
Next

aSize(aFldsTmp, 0)
aFldsTmp := Nil

If Empty(aColsFal)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aCols.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Inclui
		DWW->(dbSetOrder(1))
		DWW->(dbSeek(xFilial("DWW")+cFatura+cForn+cLoja))
		While DWW->(!Eof()) .And. DWW->(DWW_FILIAL+DWW_FATURA+DWW_CODCIA+DWW_LOJCIA) == xFilial("DWW")+cFatura+cForn+cLoja
			Aadd(aCols,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := DWW->(FieldGet(FieldPos(aHeader[nCntFor][2])))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
				EndIf
			Next
			aCols[Len(aCols)][nUsado+1] := .F.
			DWW->(dbSkip())
		EndDo
	EndIf
Else
	aHeader := AClone(aHeadFal)
	aCols   := AClone(aColsFal)
EndIf		
		
If Empty(aCols)
	Aadd(aCols,Array(nUsado+1))

	For nCntFor := 1 To nUsado
		aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	Next nCntFor

	aCols[Len(aCols)][nUsado+1] := .F.
EndIf

If	Empty(GDFieldGet('DWW_ITEM',1))
	GDFieldPut('DWW_ITEM',StrZero(1,Len(DWW->DWW_ITEM)),1)
EndIf

If lEdita
	AAdd( aObjects, { 100, 40, .T., .F. } )
	AAdd( aObjects, { 100, 60, .T., .T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
	aPosObj := MsObjSize( aInfo, aObjects ) 
		
	DEFINE MSDIALOG oDlg TITLE STR0052 From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL //"AWB's Faltantes"
	
		@ 18,005 SAY   aGet[1][1] SIZE 50,7 OF oDlg PIXEL	
		@ 18,040 MSGET oFatura    VAR cFatura PICTURE "@!"     WHEN .F. SIZE 040,7 OF oDlg PIXEL	
		@ 32,005 SAY   aGet[2][1] SIZE 50,7 OF oDlg PIXEL	
		@ 32,040 MSGET oNomCia    VAR cNomCia PICTURE "@!"     WHEN .F. SIZE 120,7 OF oDlg PIXEL	
			
		oGetDFal := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"T920AWBLOk(1)","T920AWBTOk(1)","+DWW_ITEM",.T.,,,,9999)
				
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetDFal:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})			
Else
	nOpcA := 1
EndIf
		
If nOpcA == 1 
	nValorFal:= 0
	For nCnt := 1 To Len(aCols)
		If !GDDeleted(nCnt)
			nValorFal += GDFieldGet('DWW_VAWB',nCnt)
		EndIf			
	Next nCnt
	//-- Calcula valor da fatura
	TMCalcFat()
	If ValType(oValorFal) != 'U'
		oValorFal:Refresh()
	EndIf		 
	If ValType(oValorFat) != 'U'
		oValorFat:Refresh()
	EndIf		 
	aHeadFal := AClone(aHeader)
	aColsFal := AClone(aCols)
EndIf	

RestArea(aAreaDWW)
RestArea(aAreaDTV)
RestArea(aAreaAtu)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	
	
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA920Ret ³ Autor ³ Richard Anderson     ³ Data ³15.Mai.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desconto Retroativo de AWB´s                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA920                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Ret(nOpcx,lEdita,oValorRet,oValorFat)
Local   oFatura,oNomCia,oDlg
Local   nUsado		:= 0
Local   nOpcA		:= 0
Local   aGet		:= {}
Local   aPosObj	:= {} 
Local   aObjects	:= {}
Local   aSize		:= MsAdvSize( .F. )             
Local   nCntFor	:= 0
Local   aNoFields	:= {}
Local   cNomCia	:= ""
Local   aAreaAtu	:= GetArea()
Local   aAreaDTV	:= DTV->(GetArea())
Local   aAreaDWX	:= DWX->(GetArea())
Local   nCnt		:= 0 
Local   lCallExt  := Type("cForn") == "U"
Local 	aFldsDWX	:= {}
Local 	aFldsDTV	:= {}
Local	nI			:= 0
Default lEdita    := .F. 

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

If lCallExt
	cForn   := DWX->DWX_CODCIA
	cLoja   := DWX->DWX_LOJCIA
	cFatura := DWX->DWX_FATURA
EndIf	

cNomCia := Posicione('SA2',1,xFilial('SA2')+cForn+cLoja,'A2_NREDUZ')
aHeader := {}
aCols   := {}

Aadd(aNoFields,"DWX_FATURA")
Aadd(aNoFields,"DWX_CODCIA")
Aadd(aNoFields,"DWX_LOJCIA")

aFldsDWX := ApBuildHeader("DWX")
For nI := 1 To Len(aFldsDWX)
	If aFldsDWX[nI][2] $ "DWX_FATURA"
		aAdd(aGet, {aFldsDWX[nI][1], aFldsDWX[nI][3], GetSX3Cache(aFldsDWX[nI][2], "X3_F3")})
	EndIf
Next

aFldsDTV := ApBuildHeader("DTV")
For nI := 1 To Len(aFldsDTV)
	If aFldsDTV[nI][2] $ "DTV_NOMCIA"
		aAdd(aGet, {aFldsDTV[nI][1], aFldsDTV[nI][3], GetSX3Cache(aFldsDTV[nI][2], "X3_F3")})
	EndIf
Next

aSize(aFldsDTV, 0)
aFldsDTV := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Array aHeader.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFldsDWX := ApBuildHeader("DWX", aNoFields)
For nI := 1 To Len(aFldsDWX)
	nUsado += 1
	aAdd(aHeader, aFldsDWX[nI])
Next

aSize(aFldsDWX, 0)
aFldsDWX := Nil

If lCallExt .Or. Empty(aColsRet)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aCols.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Inclui
		DWX->(dbSetOrder(1))
		DWX->(dbSeek(xFilial("DWX")+cFatura+cForn+cLoja))
		While DWX->(!Eof()) .And. DWX->(DWX_FILIAL+DWX_FATURA+DWX_CODCIA+DWX_LOJCIA) == xFilial("DWX")+cFatura+cForn+cLoja
			Aadd(aCols,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				If ( aHeader[nCntFor][10] != "V" )
					aCols[Len(aCols)][nCntFor] := DWX->(FieldGet(FieldPos(aHeader[nCntFor][2])))
				Else
					aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
				EndIf
			Next
			aCols[Len(aCols)][nUsado+1] := .F.
			DWX->(dbSkip())
		EndDo
	EndIf
Else
	aHeader := AClone(aHeadRet)
	aCols   := AClone(aColsRet)
EndIf		
		
If Empty(aCols)
	Aadd(aCols,Array(nUsado+1))

	For nCntFor := 1 To nUsado
		aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	Next nCntFor

	aCols[Len(aCols)][nUsado+1] := .F.
EndIf

If	Empty(GDFieldGet('DWX_ITEM',1))
	GDFieldPut('DWX_ITEM',StrZero(1,Len(DWX->DWX_ITEM)),1)
EndIf

If lEdita              
	//-- Força EOF para não repetir dados virtuais em linhas novas
	DWX->(dbGoTo(0))
	
	AAdd( aObjects, { 100, 40, .T., .F. } )
	AAdd( aObjects, { 100, 60, .T., .T. } )

	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
	aPosObj := MsObjSize( aInfo, aObjects ) 
		
	DEFINE MSDIALOG oDlg TITLE STR0063 From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL //"Desconto Retroativo de AWB´s"
	
		@ 18,005 SAY   aGet[1][1] SIZE 50,7 OF oDlg PIXEL	
		@ 18,040 MSGET oFatura    VAR cFatura PICTURE "@!"     WHEN .F. SIZE 040,7 OF oDlg PIXEL	
		@ 32,005 SAY   aGet[2][1] SIZE 50,7 OF oDlg PIXEL	
		@ 32,040 MSGET oNomCia    VAR cNomCia PICTURE "@!"     WHEN .F. SIZE 120,7 OF oDlg PIXEL	
			
		oGetDRet := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"T920AWBLOk(2)","T920AWBTOk(2)","+DWX_ITEM",.T.,,,,9999)
				
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetDRet:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})			
Else
	nOpcA := 1
EndIf
		
If nOpcA == 1 .And. !lCallExt
	nValorRet:= 0
	For nCnt := 1 To Len(aCols)
		If !GDDeleted(nCnt)
			nValorRet += GDFieldGet('DWX_DECRES',nCnt)
		EndIf			
	Next nCnt
	//-- Calcula valor da fatura
	TMCalcFat()
	If ValType(oValorRet) != 'U'
		oValorRet:Refresh()
	EndIf
	If ValType(oValorFat) != 'U'
		oValorFat:Refresh()
	EndIf		
	aHeadRet := AClone(aHeader)
	aColsRet := AClone(aCols)
EndIf	
                 
RestArea(aAreaDWX)
RestArea(aAreaDTV)
RestArea(aAreaAtu)
	
//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ T920AWBLOk ³ Autor ³ Richard Anderson    ³ Data ³26.08.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de digitacao de linha                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA920                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T920AWBLOk(nOpc)
Local   lRet := .T.  
Default nOpc := 1
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   If nOpc == 1
		   lRet := GDCheckKey( { 'DWW_NUMAWB' }, 4 )
		ElseIf nOpc == 2
		   lRet := GDCheckKey( { 'DWX_NUMAWB' }, 4 )
		EndIf		   
	EndIf   
EndIf
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ T920AWBTOk ³ Autor ³ Richard Anderson    ³ Data ³26.08.2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Validacao de confirmacao para gravacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA920                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function T920AWBTOk(nOpc)

Local   lRet := .T.
Default nOpc := 1

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet 
	If nOpc == 1
		lRet := oGetDFal:ChkObrigat( n ) 
	ElseIf nOpc == 2
		lRet := oGetDRet:ChkObrigat( n ) 
	EndIf		
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := T920AWBLOk(nOpc)
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920Vis³ Autor ³ Richard Anderson      ³ Data ³ 24.04.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza AWB                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920Vis												                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Vis()

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)
 
SaveInter()

INCLUI := .F.

TMSA320Mnt('DTV',DTV->(Recno()),2)

RestInter()

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)	

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TmsA920DWX ³ Autor ³ Richard Anderson     ³ Data ³ 15.Mai.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona AWB´s por data                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGATMS   												                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA920DWX()

Local cPerg       := "TMA920DWX"
Local cQuery      := ""
Local cAlias      := Alias()   
Local cAliasDTV   := GetNextAlias()
Local aRec	   	:= {}
Local nRet        := 0     
Local cCadastro   := 'AWB´s'   
Local aTitulo   	:= {}
Local aTmp 	  		:= {}
Local lRet        := .F.  
  
Aadd( aTitulo, RetTitle('DTV_NUMAWB') )
Aadd( aTitulo, RetTitle('DTV_DIGAWB') )
Aadd( aTitulo, RetTitle('DTV_DATEMI') )
Aadd( aTitulo, RetTitle('DTV_HOREMI') )
Aadd( aTitulo, RetTitle('DTV_AERORI') )
Aadd( aTitulo, RetTitle('DTV_AERDES') )
Aadd( aTitulo, RetTitle('DTV_QTDVOL') )
Aadd( aTitulo, RetTitle('DTV_PESO  ') )
Aadd( aTitulo, RetTitle('DTV_PESOM3') )
Aadd( aTitulo, RetTitle('DTV_VALMER') )
Aadd( aTitulo, RetTitle('DTV_VAWB  ') )
Aadd( aTitulo, RetTitle('DTV_FATURA') )

If Pergunte(cPerg)
	cQuery := "SELECT DTV_NUMAWB, DTV_DIGAWB, DTV_DATEMI, DTV_HOREMI, DTV_AERORI, DTV_AERDES, "
	cQuery += "       DTV_QTDVOL, DTV_PESO  , DTV_PESOM3, DTV_VALMER, DTV_VAWB  , DTV_FATURA, R_E_C_N_O_ DTVRECNO"
	cQuery += "  FROM "
	cQuery += RetSqlName("DTV")+" DTV "
	cQuery += " WHERE DTV.DTV_FILIAL  = '"+xFilial('DTV')+"'"
	cQuery += "   AND DTV.DTV_CODCIA  = '"+cForn+"'"
	cQuery += "   AND DTV.DTV_LOJCIA  = '"+cLoja+"'"
	cQuery += "   AND DTV.DTV_DATEMI BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"'"
	cQuery += "   AND DTV.DTV_FATURA <> ' '" 
	cQuery += "   AND DTV.D_E_L_E_T_  = ' '"
	cQuery += "   AND NOT EXISTS ( SELECT 1 FROM "+RetSqlName("DWX")+" DWX "
	cQuery += "                            WHERE DWX.DWX_FILIAL = '"+xFilial("DWX")+"'"
	cQuery += "                              AND DWX.DWX_NUMAWB = DTV_NUMAWB"
	If DWX->(FieldPos("DWX_DIGAWB")) > 0
		cQuery += "                           AND DWX.DWX_DIGAWB = DTV_DIGAWB"
	EndIf
	cQuery += "                              AND DWX.D_E_L_E_T_ = ' ' )"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTV,.T.,.T.)
	TcSetField(cAliasDTV,"DTV_DATEMI","D",TamSX3("DTV_DATEMI")[1],TamSX3("DTV_DATEMI")[2])
	TcSetField(cAliasDTV,"DTV_QTDVOL","N",TamSX3("DTV_QTDVOL")[1],TamSX3("DTV_QTDVOL")[2])
	TcSetField(cAliasDTV,"DTV_PESO  ","N",TamSX3("DTV_PESO  ")[1],TamSX3("DTV_PESO  ")[2])
	TcSetField(cAliasDTV,"DTV_PESOM3","N",TamSX3("DTV_PESOM3")[1],TamSX3("DTV_PESOM3")[2])
	TcSetField(cAliasDTV,"DTV_VALMER","N",TamSX3("DTV_VALMER")[1],TamSX3("DTV_VALMER")[2])
	TcSetField(cAliasDTV,"DTV_VAWB  ","N",TamSX3("DTV_VAWB  ")[1],TamSX3("DTV_VAWB  ")[2])
	While (cAliasDTV)->(!Eof())
		aTmp := {} 
		Aadd( aTmp, (cAliasDTV)->DTV_NUMAWB )
		Aadd( aTmp, (cAliasDTV)->DTV_DIGAWB )
		Aadd( aTmp, (cAliasDTV)->DTV_DATEMI )
		Aadd( aTmp, (cAliasDTV)->DTV_HOREMI )
		Aadd( aTmp, (cAliasDTV)->DTV_AERORI )
		Aadd( aTmp, (cAliasDTV)->DTV_AERDES )
		Aadd( aTmp, (cAliasDTV)->DTV_QTDVOL )
		Aadd( aTmp, (cAliasDTV)->DTV_PESO   )
		Aadd( aTmp, (cAliasDTV)->DTV_PESOM3 )
		Aadd( aTmp, (cAliasDTV)->DTV_VALMER )
		Aadd( aTmp, (cAliasDTV)->DTV_VAWB   )
		Aadd( aTmp, (cAliasDTV)->DTV_FATURA )
		Aadd( aTmp, (cAliasDTV)->DTVRECNO   )
		AAdd( aRec, aTmp )
		(cAliasDTV)->(dbSkip())
	EndDo
	If Len(aRec) > 0
		nRet := TmsF3Array( aTitulo, aRec, cCadastro,/*lCancel*/,/*aNewButton*/,aTitulo ) // TmsF3Array( aHeadTms, aItemTms, cTitulo, lCancel, aNewButton, aCabec )
		If !Empty(nRet)
			DTV->(dbGoTo(aRec[nRet,Len(aTmp)]))
			GDFieldGet('DWW_NUMAWB')
			GDFieldGet('DWW_DIGAWB')
			lRet := .T.
		EndIf
	Else
		Help('',1,'REGNOIS')
	EndIf      
	(cAliasDTV)->(dbCloseArea())
	dbSelectArea(cAlias)
EndIf
                                                    
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMCalcFat ³ Autor ³ Richard Anderson      ³ Data ³ 15.Mai.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula valor da AWB                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920   												                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMCalcFat()
//-- Calcula valor da fatura
Local nValFatLQ := 0

nValorFat := nValor-nComiss+nIrrf+nValorFal-nValorRet
nValFatLQ := nValorLq-nComiss+nIrrf+nValorFal-nValorRet
nRent     := Round((nValFatLq / nFrete) * 100,2)  
If nValFatLQ > nFrete 
	nRent := nRent * -1
EndIf    
Return NIL                                                    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920Des³ Autor ³ Richard Anderson      ³ Data ³ 15.Mai.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa Desconto Retroativo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920   												                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Des()
Local cFiltro1    := ""
Local cFiltro2    := ""
Local aCampos     := {} 
Local aRotina     := {}

Private cCadastro := 'Desconto Retroativo de AWB´s'
Private nOpcSel   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCampos, "DWX_FATURA")
Aadd(aCampos, "DWX_CODCIA")
Aadd(aCampos, "DWX_LOJCIA") 
Aadd(aCampos, "DWX_NUMAWB")
Aadd(aCampos, "DWX_DATDEC")
Aadd(aCampos, "DWX_DECRES")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa               ³
//³ ----------- Elementos contidos por dimensao ------------              ³
//³ 1. Nome a aparecer no cabecalho                                       ³
//³ 2. Nome da Rotina associada                                           ³
//³ 3. Usado pela rotina                                                  ³
//³ 4. Tipo de Transa‡„o a ser efetuada                                   ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados                      ³
//³    2 - Simplesmente Mostra os Campos                                  ³
//³    3 - Inclui registros no Bancos de Dados                            ³
//³    4 - Altera o registro corrente                                     ³
//³    5 - Remove o registro corrente do Banco de Dados                   ³
//³    6 - Alteracao sem inclusao de registro                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRotina	:= { { 'Visualizar', "TMSA920VDc", 0, 2},;    		//"Visualizar
		        { 'Confirmar' , "TMSConfSel", 0, 2,,,.T.} } 	//"Confirmar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DWX->(dbSetOrder(1)) 
MaWndBrowse(0,0,300,600,cCadastro,"DWX",aCampos,aRotina,,cFiltro1,cFiltro2,.T.)

If nOpcSel == 1
	DD8->(dbSetOrder(1))
	DD8->(dbSeek(xFilial('DD8')+DWX->(DWX_FATURA+DWX_CODCIA+DWX_LOJCIA),.T.))
EndIf	

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920Vis³ Autor ³ Richard Anderson      ³ Data ³ 15.Mai.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza Desconto Retroativo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920   												                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920VDc(cAlias,nReg,nOpcx)

SaveInter()

INCLUI := .F.

TMSA920Ret(2,.T.)

RestInter()

Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TMSA920Pos³ Autor ³ Richard Anderson      ³ Data ³ 15.Mai.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄAÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona DTV por query devido ao filtro ativo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ TMSA920   												                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA920Pos(cNumAWB,cCodCia,cLojCia,cDigito,dData) 

Local   aRet      := { Space(Len(DTV->DTV_NUMAWB)), Space(Len(DTV->DTV_FATURA)), 0 }
Local   aAreaAtu  := {}
Local	  cAliasQry := ""
Default cNumAWB   := ""
Default cCodCia   := ""
Default cLojCia   := "" 
Default dData     := cTod("")
Default cDigito   := ""

If !Empty(cNumAWB)
	aAreaAtu  := GetArea()
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DTV_NUMAWB, DTV_FATURA, DTV_VAWB, DTV_DIGAWB "
	cQuery += "  FROM "
	cQuery += RetSqlName("DTV")
	cQuery += " WHERE DTV_FILIAL = '"+xFilial("DTV")+"'"
	cQuery += "   AND DTV_NUMAWB = '"+cNumAWB+"'"

	cDigito := TMSA320Dig(dData,cDigito)
	If Len(cDigito) > 0
		cQuery += "   AND DTV_DIGAWB = '" + cDigito + "' "
	EndIf
	cQuery += "   AND DTV_CODCIA = '"+cCodCia+"'"
	cQuery += "   AND DTV_LOJCIA = '"+cLojCia+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	TcSetField(cAliasQry,"DTV_VAWB ","N",TamSX3("DTV_VAWB")[1],TamSX3("DTV_VAWB")[2])
	If (cAliasQry)->(!Eof()) .And. !Empty((cAliasQry)->DTV_NUMAWB)
		aRet[1] := (cAliasQry)->DTV_NUMAWB
		aRet[2] := (cAliasQry)->DTV_FATURA
		aRet[3] := (cAliasQry)->DTV_VAWB
		aRet[4] := (cAliasQry)->DTV_DIGAWB
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAtu)
EndIf

Return aRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Jose Luiz Pinheiro Jr ³ Data ³07/04/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
     
Private aRotina := { {STR0002		    ,"AxPesqui"  ,0,1} ,; //"Pesquisar"
					 		{STR0003		    ,"TMSA920Mnt",0,2} ,; //"Visualizar"
	             	 	{STR0004		    ,"TMSA920Mnt",0,3} ,; //"Incluir"
   	          		{STR0005		    ,"TMSA920Mnt",0,4} ,; //"Alterar"
      	       		{STR0006		    ,"TMSA920Mnt",0,5} ,; //"Excluir"
      	       		{STR0007 	    ,"TMSA920Pag",0,6} ,; //"Libera Pagto"
      	       		{STR0008 	    ,"TMSA920Can",0,7} ,; //"Cancela Fat."
      	       		{STR0009	       ,"U_RTMSR23" ,0,8} ,; //"Imprimir"
      	       		{STR0069			 ,"TMSA920Des",0,9} ,; //"Pesq.Desc."
					 		{STR0010		    ,"TMSA920Leg",0,2} }  //"Legenda"

If ExistBlock("TM920MNU")
	ExecBlock("TM920MNU",.F.,.F.)
EndIf       

Return(aRotina)
