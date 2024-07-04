#Include "ATFA450.CH"
#Include "PROTHEUS.CH"
#INCLUDE "FONT.CH"
STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ATFA450	³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de apropriacao do AVP de bens imobilizados		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFA450()

Local aCores   := Af450Leg(.T.)
Local cPerg		:= "AFA450"
Local lAvpAtf  := AFAvpAtf(.T.)

Private cCadastro	:= STR0001 //"Apropriação - AVP"
Private aRotina := MenuDef()


//AVP
//Verifica de o AVP esta implantado na base
If lAvpAtf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as perguntas selecionadas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey (VK_F12,{|a,b| AcessaPerg(cPerg,.T.)})
	
	Pergunte(cPerg,.F.)
	
	dbSelectArea("FNP")
	FNP->( dbSetOrder( 1 ) )
	
	mBrowse(,,,,"FNP",,,,,,aCores)
	
Endif

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450Apur³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa para apuracao de AVP de imobilizados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450Apur()

Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local nX				:= 0
Local cPerg			:= "AFA450"
Local aSelFil		:= {}
//Removido o tratamento de getarea chamado TGLGGV

Aadd(aSays,STR0002)	//"Este programa tem como objetivo permitir a apropriacao do AVP de bens imobilizados. "
Aadd(aSays," ")
Aadd(aSays,STR0003)  //"Apenas bens imobilizados que possuam movimento de constituição de AVP ativo serão "
Aadd(aSays,STR0004)	//"considerados para esse processo."

Aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. )}})
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                     ³
//³==========================================================³
//³ mv_par01 // Mostra tela contabilizacao                   ³
//³ mv_par02 // Aglutina Lancto                              ³
//³ mv_par03 // Seleciona Filiais                            ³
//³ mv_par04 // Contabiliza On-Line (sem efeito nessa rotina)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	
	If mv_par03 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return  
		EndIf
	EndIf
	
	Processa({|| AF450PApur(aSelFil)})
Endif

Set Key VK_F12 To

// Removido o Restarea Chamado TGLGGV - 
// voltava o registro no qual estava posicionado e nao no registro calculado

// Chamado TGPAJN - Quebro a recorrencia do Loop de INCLUI
MBrChgLoop( .F. )

Return 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450PApur³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de processamento da apuracao AVP de imobilizados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aSelFil   = Array contendo as filiais a serem processadas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450PApur(aSelFil)

Local cCodAVP		:= ""
Local cFilAtu		:= cFilAnt
Local lFNFCompart := Empty(xFilial("FNF"))
Local nSaveSx8Len	:= GetSx8Len()

Local lOnOff	:= (MV_PAR04 == 1)
Local nX				:= 0

DEFAULT aSelFil 	:= {}

//Se for compartilhado ou o array estiver vazio
//Processo apenas a filial corrente
If lFNFCompart .or. Len(aSelFil) == 0
	aSelFil	:= {cFilAnt}
Endif

For nX := 1 to Len(aSelFil)
	
	cFilAnt	:= aSelFil[nX]
	
	//Seleciona dados para a filial atual
	aRecnos	:= AF450SelDados()
	
	If Len(aRecnos) > 0
		cCodAVP	:= GetSxeNum('FNF','FNF_IDPROC','FNF_IDPROC'+cEmpAnt,3)
		
		BEGIN TRANSACTION
		
		//Processa a apuracao do AVP para a filial atual
		aRecCTB	:= AF450AVP(aRecnos,cCodAvp)
		
		//Caso contabilize on-line, contabiliza os dados da filial Atual
		If lOnOff .and. Len(aRecCTB) > 0
			AF450CtbAvp(aRecCTB)
		Endif
		
		END TRANSACTION
	Else
		Help(" ",1,"RECNO")
	Endif
	
Next

// Confirma o cCODAVP
While (GetSx8Len() > nSaveSx8Len)
	ConfirmSX8()
Enddo

cFilaAnt := cFilAtu

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450SelDados³ Autor ³ Mauricio Pequim Jr ³ Data ³ 24.10.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Selecao dos dados para apuracao AVP de imobilizados  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450SelDados()

Local cQuery	:= ""
Local aRecnos	:= {}
Local aArea		:= GetArea()
Local lDefTop   := IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local cNextAlias	:= ""

If lDefTop
	
	//Selecao de bens constituidos para apuracao do AVP
	//- Bens com constituicao ativa e
	//- que nao possuam movimentos posteriores a data de processamento
	cQuery := "SELECT FNFA.R_E_C_N_O_ RECFNF FROM "+RetSqlName("FNF")+" FNFA WHERE " + CRLF
	cQuery += "FNFA.FNF_FILIAL = '"+xFilial("FNF")+"' AND " + CRLF
	cQuery += "FNFA.FNF_TPMOV = '1' AND " + CRLF
	cQuery += "FNFA.FNF_STATUS = '1' AND " + CRLF
	cQuery += "D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "AND NOT EXISTS (" + CRLF
	cQuery += "SELECT FNFB.FNF_CBASE " + CRLF
	cQuery += "FROM "+RetSqlName("FNF")+" FNFB " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += " FNFB.FNF_FILIAL = '"+xFilial("FNF")+"' AND " + CRLF
	cQuery += " FNFB.FNF_CBASE  = FNFA.FNF_CBASE  AND " + CRLF
	cQuery += " FNFB.FNF_ITEM   = FNFA.FNF_ITEM   AND " + CRLF
	cQuery += " FNFB.FNF_TIPO   = FNFA.FNF_TIPO   AND " + CRLF
	cQuery += " FNFB.FNF_SEQ    = FNFA.FNF_SEQ    AND " + CRLF
	cQuery += " FNFB.FNF_TPSALD = FNFA.FNF_TPSALD AND " + CRLF
	cQuery += " FNFB.FNF_MOEDA  = FNFA.FNF_MOEDA  AND " + CRLF
	cQuery += " FNFB.FNF_STATUS = '1' AND " + CRLF
	cQuery += " FNFB.FNF_DTAVP >= '" + DTOS(dDatabase) + "' AND " + CRLF
	cQuery += " FNFB.D_E_L_E_T_=' ' AND " + CRLF
	cQuery += " FNFA.D_E_L_E_T_=' ')" + CRLF
	cQuery := ChangeQuery(cQuery)
	cNextAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
	
	While !( (cNextAlias)->(Eof()) )
		
		aadd(aRecnos,(cNextAlias)->RECFNF)
		
		(cNextAlias)->(dbSkip())
		
	Enddo
	
	//Fecho o temporario
	(cNextAlias)->(dbCloseArea())
	
Else
	
	//codebase
	dbSelectArea("__FNF")
	dbSetOrder(1)  //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	cIndexFNF := __FNF->(IndexKey())
	cArqTrab	 := CriaTrab(,.f.)
	IndRegua("__FNF",cArqTrab,cIndexFNF,, cQuery ,"Selecionando Registros...")
	nIndexFNF :=RetIndex("FNF","__FNF")
	dbSetIndex(cArqTrab+OrdBagExt())
	dbSetorder(nIndexFNF+1)
	dbGoTop()
	
	While !( __FNF->(Eof()) )
		
		aadd(aRecnos,(cNextAlias)->(Recno()))
		
		__FNF->(dbSkip())
		
	Enddo
	
	DbSelectArea("__FNF")
	RetIndex("FNF","__FNF")
	DBClearFilter()
	fErase(cIndexFNF+OrdBagExt())
	cIndexFNF := ""
	nIndexFNF := ""
	__FNF->(DbSetOrder(1))
	__FNF->(DbGoTop())
	
EndIf

dbSelectArea("FNF")

RestArea(aArea)

Return aRecnos


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450AVP  ³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a apuracao do AVP para a filial atual				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRecnos = Array contendo recnos das constituicoes ativas   ³±±
±±³          ³            a partir dos quais sera calculado o valor de    ³±±
±±³          ³            apuracao do AVP de imobilizados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450AVP(aRecnos,cIdProcAVP)

Local aRecCTB 	:= {}
Local nX		:= 0
Local nValAvp	:= 0
Local nValVp	:= 0
Local lFirst	:= .T.
Local lGrvAvp	:= .F.
Local lOnOff 	:= .T.

lOnOff := MV_PAR04 == 1

dbSelectArea("FNF")
FNF->(dbSetOrder(1))

For nX := 1 to Len(aRecnos)
	//Posiciono tabela FNF no registro de constituicao ativo
	dbSelectArea("FNF")
	FNF->(dbGoto(aRecnos[nX]))
	
	//Posiciono na Ficha do ativo
	SN1->(dbSetOrder(1))
	SN1->(MsSeek(xFilial("SN1")+FNF->(FNF_CBASE+FNF_ITEM)))
	
	//Caso o bem esteja bloqueado, nao calculo apuracao de AVP
	If SN1->N1_STATUS $ "2|3"
		Loop
	Endif
	
	If lIsRussia
		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
		If SN3->(MsSeek( xFilial("SN3")+FNF->FNF_CBASE+FNF->FNF_ITEM+FNF->FNF_TIPO+PadR("0",TamSx3("N3_BAIXA")[1])+FNF->FNF_TPSALDO))
			If SN3->N3_OPER <> '1' // CAZARINI - 22.01.2017 - Asset Into Operation?
				Loop
			Endif
		Endif
	Endif	
	//Calculo do AVP
	AFCalcAVP("A",FNF->FNF_TAXA,FNF->FNF_INDAVP,,FNF->FNF_PERIND,dDatabase,@nValVP,@nValAVP,SN1->N1_DTAVP)
	
	//Gravacao do movimento de apuracao
	lGrvAvp := AfGrvAvp(cFilAnt,"2",dDataBase,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALDO,' ',FNF->FNF_SEQ,,nValAvp,.F.,,,,,cIdProcAVP,aRecCTB)
	
	//Grava FNP - Processamento de apropriacao de AVP (cabecalho)
	If ValType(lGrvAvp) == "L"  //Protege retorno da função AfGrvAvp
		If  lGrvAvp .And. lFirst
			RecLock("FNP",.T.)
			FNP_FILIAL	:= xFilial("FNP")
			FNP_DTPROC	:= dDataBase
			FNP_STATUS	:= "1"
			FNP_IDPROC	:= cIdProcAVP
			FNP->(MsUnlock())
			
			lFirst := .F.
		Endif
	ElseIf lFirst 
			RecLock("FNP",.T.)
			FNP_FILIAL	:= xFilial("FNP")
			FNP_DTPROC	:= dDataBase
			FNP_STATUS	:= "1"
			FNP_IDPROC	:= cIdProcAVP
			FNP->(MsUnlock())
			
			lFirst := .F.
	EndIf 
Next

//Se contabiliza off-line
//Zero o array de registros a contabilizar
If mv_par04 == 2
	aRecCtb := {}
Endif

Return aRecCTB

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450Ctb  ³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processo de contabilizacao off-line do processo de apuracao³±±
±±³          ³ de AVP de fichas de imobilizado								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450Ctb ()

Local aSays			:= {}
Local aButtons		:= {}
Local nOpca			:= 0
Local nX				:= 0
Local cPerg			:= "AFA450"
Local aSelFil		:= {}
Local aArea			:= GetArea()
Local cTitulo 		:= STR0005	//"Contabilização off-line - AVP"

Aadd(aSays,STR0006)	//"Este programa tem como objetivo permitir a contabilização off-line dos movimentos "
Aadd(aSays,STR0007)	//"do AVP de bens imobilizados. "
Aadd(aSays,STR0003)	//"Apenas bens imobilizados que possuam movimento de constituição de AVP ativo serão "
Aadd(aSays,STR0004)	//"considerados para esse processo."

Aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. )}})
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cTitulo, aSays, aButtons)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                     ³
//³==========================================================³
//³ mv_par01 // Mostra tela contabilizacao                   ³
//³ mv_par02 // Aglutina Lancto                              ³
//³ mv_par03 // Seleciona Filiais                            ³
//³ mv_par04 // Contabiliza On-Line (sem efeito nessa rotina)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	If mv_par03 == 1 .And. Len( aSelFil ) <= 0
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf
	EndIf
	
	Processa({|| AF450CtbPrc(aSelFil)})
Endif

Set Key VK_F12 To
RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450CtbPrc ³ Autor ³ Mauricio Pequim Jr ³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processo de contabilizacao off-line do processo de apuracao³±±
±±³          ³ de AVP de fichas de imobilizado								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450CtbPrc(aSelFil)

Local cFilAtu	:= cFilAnt
Local nX			:= 0
Local lFNFCompart := Empty(xFilial("FNF"))

DEFAULT aSelFil 	:= {}

//Se for compartilhado ou o array estiver vazio
//Processo apenas a filial corrente
If lFNFCompart .or. Len(aSelFil) == 0
	aSelFil	:= {cFilAnt}
Endif

For nX := 1 to Len(aSelFil)
	
	cFilAnt	:= aSelFil[nX]
	
	//Seleciona dados para a filial atual
	aRecCTB	:= AF450CTBDados()
	
	If Len(aRecCtb) > 0
		BEGIN TRANSACTION
		
		//Contabiliza as informacoes
		Af450CtbAvp(aRecCTB)
		
		END TRANSACTION
	Endif
	
Next

cFilAnt := cFilAtu
aRecCTB := {}

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³AF450CTBDados³ Autor ³ Mauricio Pequim Jr ³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processo de contabilizacao off-line do processo de apuracao³±±
±±³          ³ de AVP de fichas de imobilizado								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//---------------------------
Function AF450CTBDados()

Local cQuery		:= ""
Local aRecnos		:= {}
Local lDefTop   := IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Local cNextAlias	:= ""

If lDefTop
	//MONTA QUERY PARA SELECAO DOS BENS CONSTITUIDOS QUE TERAO SEU VALOR DE AVP APROPRIADO
	cQuery := "SELECT R_E_C_N_O_ RECFNF FROM "+RetSqlName("FNF")+" WHERE "
	cQuery += "FNF_FILIAL = '"+xFilial("FNF")+"' AND "
	cQuery += "FNF_DTCONT = ' ' AND "
	cQuery += "FNF_STATUS = '1' AND "
	cQuery += "D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	cNextAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)
	
	While !( (cNextAlias)->(Eof()) )
		
		aadd(aRecnos,(cNextAlias)->RECFNF)
		
		(cNextAlias)->(dbSkip())
		
	Enddo
	
	//Fecho o temporario
	(cNextAlias)->(dbCloseArea())
Else
	//codebase
	cQuery := "FNF_FILIAL == '"+xFilial("FNF")+"' .AND. "
	cQuery += "FNF_DTCONT == '"+DTOS("//")+" ' .AND. "
	cQuery += "FNF_STATUS == '1' .AND. "
	
	dbSelectArea("__FNF")
	dbSetOrder(1)
	cIndexFNF := __FNF->(IndexKey())
	cArqTrab	 := CriaTrab(,.f.)
	IndRegua("__FNF",cArqTrab,cIndexFNF,, cQuery ,STR0008)	//"Selecionando Registros..."
	nIndexFNF :=RetIndex("FNF","__FNF")
	dbSetIndex(cArqTrab+OrdBagExt())
	dbSetorder(nIndexFNF+1)
	dbGoTop()
	
	While !( __FNF->(Eof()) )
		
		aadd(aRecnos,(cNextAlias)->(Recno()))
		
		__FNF->(dbSkip())
		
	Enddo
	
	DbSelectArea("__FNF")
	RetIndex("FNF","__FNF")
	DBClearFilter()
	fErase(cIndexFNF+OrdBagExt())
	cIndexFNF := ""
	nIndexFNF := ""
	__FNF->(DbSetOrder(1))
	__FNF->(DbGoTop())
EndIf

dbSelectArea("FNF")

Return aRecnos


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450CtbAvp ³ Autor ³ Mauricio Pequim Jr ³ Data ³ 24.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processo de contabilizacao off-line do processo de apuracao³±±
±±³          ³ de AVP de fichas de imobilizado								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450CtbAvp (aRecCTB,lFechaCtb,nTotal,nHdlPrv,cArquivo,cRotina,lCancel)

Local nX			:= 0
Local cProcesso:= ""
Local cLoteAtf	:= LoteCont("ATF")
LOCAL lPadrao	:= .F.
LOCAL cPadrao	:= ""
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local aFlagCTB := {}
Local lDigita	:= (mv_par01 == 1)
Local lAglutina:= (mv_par02 == 1)

PRIVATE LanceiCtb := .F.

DEFAULT aRecCTB 	:= {}
DEFAULT lFechaCtb := .T.
DEFAULT nTotal		:= 0
DEFAULT nHdlPrv	:= 0
DEFAULT cArquivo	:= ""
DEFAULT cRotina	:= "ATFA450"
DEFAULT lCancel	:= .F.

If Len(aRecCTB) > 0
	
	dbSelectArea("FNF")
	
	For nX := 1 to Len(aRecCTB)
		
		FNF->(dbGoto(aRecCTB[nX]))
		
		If lCancel
			cProcesso := "0"
		Else
			cProcesso := FNF->FNF_TPMOV
		Endif
		
		//Contabilizacao do AVP
		cPadrao := AFXPadAVP(cProcesso)

		
		lPadrao := VerPadrao(cPadrao)
		
		If lPadrao
			
			//Verifico Handle de contabilizacao
			If ValType(nHdlPrv) != "N" .Or. nHdlPrv <= 0
				nHdlPrv := HeadProva(cLoteAtf,"ATFA450",Substr(cUsername,1,6),@cArquivo)
			EndIf
			
			If nHdlPrv > 0
				//Verifico o uso de Flag contabil automatico
				If lUsaFlag
					aAdd(aFlagCTB,{"FNF_DTCONT","S","FNF",FNF->(Recno()),0,0,0})
				EndIf
				
				nTotal +=	DetProva(nHdlPrv,cPadrao,"ATFA450",cLoteAtf,,,,,,,,@aFlagCTB)
				
				If LanceiCtb // Vem do DetProva
					If !lUsaFlag
						RecLock("FNF")
						FNF->FNF_DTCONT  := dDatabase
						MsUnlock( )
					EndIf
				ElseIf lUsaFlag
					If (nPosReg  := aScan(aFlagCTB,{ |x| x[4] == FNF->(Recno()) }))>0
						aFlagCTB := Adel(aFlagCTB,nPosReg)
						aFlagCTB := aSize(aFlagCTB,Len(aFlagCTB)-1)
					Endif
				EndIf
			Endif
		Endif
	Next
	
	//Fecha contabilizacao para o processo de apuracao de AVP
	//Quando esta rotina for chamada de outro processo, a contabilizacao sera fechada
	//apenas na rotina de chamada.
	If lFechaCtb .and. nHdlPrv > 0 .And. nTotal > 0
		RodaProva(nHdlPrv, nTotal)
		cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lDigita,lAglutina)
	Endif
	
Endif


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AF450Can	³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03.11.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de cancelamento de processo de apropriacao do AVP de³±±
±±³Descri‡„o ³  bens imobilizados
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ATFA450													 				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AF450Can(cAlias, nReg, nOpc)

Local aArea 	:= GetArea()
Local lRet 		:= .T.
Local nOpcA		:= 0
Local cProcesso:= FNP->FNP_IDPROC
Local aCores   := Af450Leg(.T.,.T.)
Local cPerg		:= "AFA450"
Local lAvpAtf  := AFAvpAtf(.T.)
Local nPosRec	:= 0
Local	nQtdReg	:= 0
Local oFnt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aHeadAvp  		:= {}
Local aColsAvp			:= {}
Local nOpcX				:= 0							 							// Opção da MsNewGetDados
Local cLinhaOk     	:= "AllwaysTrue"  									// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"										// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               			  			// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              									// Campos estaticos na GetDados.
Local nMax         	:= 999              									// Numero maximo de linhas permitidas.
Local aAlter    		:= {}                                      	// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"						  				// Funcao executada na validacao do campo
Local cSuperDel     	:= "AllwaysTrue"          			  			   // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        	:= "AllwaysTrue"    					 				// Funcao executada para validar a exclusao de uma linha do aCols

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para a MsAdvSize e MsObjSize³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lEnchBar   		:= .F. // Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao    		:= .F. // Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY	    		:= 400 // Altura mínima da janela
Local aSize	   		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 			:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	  		:= {}
Local aPosObj	   	:= {}
Local oDlg				:= Nil
Local oPanelMed		:= Nil
Local oGetMov			:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição das posições dos objetos na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg(cPerg,.T.)})

Pergunte(cPerg,.F.)

//Verifico se eh possivel cancelar o processo
If AF450EstOK()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega o a Header e o acols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeadAvp := AF450Head()
	aColsAvp := AF450aCol(aHeadAvp,cProcesso)
	nQtdReg	:= Len(aColsAvp)
	nPosRec	:= Len(aHeadAvp)+1
	
	If nPosRec <= 0
		Help(" ",1,"ATF450NOT1",,STR0009,1,0) //"Não foram encontrados registros para este processo. Por favor, verifique o status do processo"
		lRet := .F.
	Else
		
		DEFINE FONT oFnt NAME "Arial" SIZE 12,14 BOLD
		
		// Definicao dos Objetos
		oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)
		
		oPanel1 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,025,025,.T.,.T. )
		oPanel1:Align 	:= CONTROL_ALIGN_TOP
		
		oPanel2 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,500,500,.T.,.T. )
		oPanel2:Align 	:= CONTROL_ALIGN_ALLCLIENT
		
		//
		// Painel 1 - Informacao do processo
		//
		@ 003 , 005 SAY STR0010 FONT oDlg:oFont PIXEL Of oPanel1 // "Processo: "
		@ 003 , 060 Say cProcesso			Picture "@!";
		FONT oFnt COLOR CLR_HBLUE;
		PIXEL Of oPanel1
		
		@ 012 , 005 Say STR0011 PIXEL Of oPanel1		//"Data do Processo: "
		@ 012 , 060 Say DTOC(FNP->FNP_DTPROC) SIZE 50,8  PIXEL Of oPanel1
		@ 012 , 150 Say STR0012 PIXEL Of oPanel1		//"Qtd. Registros: "
		@ 012 , 200 Say nQtdReg Picture "@E 9999999" SIZE 50,8  PIXEL Of oPanel1
		
		
		//
		// Painel 2 - Dados dos movimentos do processo
		//
		oGetAvp	:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,Len(aColsAVP),cFieldOk,cSuperDel,cDelOk,oPanel2,aHeadAvp,aColsAvp)
		oGetAvp:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
		
		oDlg:bInit 		:= EnchoiceBar(oDlg,{|| nOpcA:=1,oDlg:End() },{|| nOpcA:=0,oDlg:End()})
		oDlg:lCentered	:= .T.
		oDlg:Activate()
		
	Endif
	
EndIf

If nOpcA == 1
	MsgRun( STR0013,, {|| AF450EstAVP(aColsAvp,nPosRec) } ) 	//"Estornando o processo de AVP selecionado..."
EndIf

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA950ESTOKºAutor  ³Microsiga           º Data ³  07/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida possibilidade do processo AVP ser estornado         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                              	        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF450EstOK()

Local cAliasQry := ""
Local lRet := .T.
Local cQuery := ""
Local lAvpAtf  := AFAvpAtf(.T.)

If !lAvpAtf
	lRet := .F.
ElseIf FNP->FNP_STATUS != "1"
	Help(" ",1,"AF450CAN01",,STR0014,1,0)	//"Este processo já se encontra cancelado."
	lRet := .F.
ElseIf FNP->FNP_DTPROC > dDataBase
	Help(" ",1,"AF450CAN02",,STR0024,1,0)	//"Este processo foi efetuado em data posterior a database do sistema."
	lRet := .F.
EndIf

If lRet
	cAliasQry := GetNextAlias()
	cQuery := " SELECT "
	cQuery += " 	MAX(FNF_IDPROC) FNFMAXPROC  "
	cQuery += " FROM "  + RetSQLTab("FNF")
	cQuery += " INNER JOIN " + RetSQLTab("FNP") + " ON FNF_IDPROC = FNP_IDPROC "
	cQuery += " WHERE FNF_STATUS = '1' AND " 
	cQuery += " FNP_STATUS = '1' AND "
	cQuery += RetSqlCond("FNF") + " AND "
	cQuery += RetSqlCond("FNP")
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry )
	
	If (cAliasQry)->(!Eof()) .And. FNP->FNP_IDPROC < (cAliasQry)->FNFMAXPROC
		Help(" ",1,"AF450NOLAST",,STR0015,1,0)		//"Existem processos de AVP posteriorea ao processo que está se tentando cancelar. Por segurança, os processos devem ser cancelados do mais atual para o mais antigo."
		lRet := .F.
	Endif
	
	dbSelectArea(cAliasQry)
	dbCloseArea()
	
	dbSelectArea("FNP")
	
Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF450EstAVP ºAutor ³Mauricio Pequim Jr. º Data ³  18/11/11  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza o cancelamento de um determinado processo de        º±±
±±º          ³apuracao de AVP                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA450                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF450EstAVP(aCols,nPosRec)

Local aArea		:= GetArea()
Local nX	  		:= 0
Local cPadrao	:= "868" //Cancelamento de movto AVP
Local nTotal	:= 0
Local cArquivo	:= ''
Local cLoteAtf	:= LoteCont("ATF")
Local lPadrao  := VerPadrao(cPadrao)
Local nHdlPrv	:= 0
Local lDigita	:= (mv_par01 == 1)
Local lAglutina:= (mv_par02 == 1)
Local nValAvp	:= 0
Local cProcesso:= 0

DbSelectArea("FNF")

BEGIN TRANSACTION

For nX := 1 to Len(aCols)
	
	FNF->(dbGoto(aCols[nX][nPosRec]))
	
	//Obtenho o valor da Apuracao para devolver ao AVP
	nValAvp := FNF->FNF_VALOR
	cProcesso	:= FNF->FNF_TPMOV
	
	//Contabilizo a exclusao do registro
	If lPadrao
		If nHdlPrv == 0
			nHdlPrv := HeadProva(cLoteAtf,"ATFA450",Substr(cUsername,1,6),@cArquivo)
		Endif
		
		//Apenas registros contabilizados terao sua exclusao contabilizada
		If !Empty(FNF->FNF_DTCONT)
			nTotal += DetProva(nHdlPrv,cPadrao,"ATFA450",cLoteAtf)
		Endif
	Endif
	
	//Atualizo o AVP acumulado da constituicao de AVP ativa
	//Posiciono tabela FNF no registro de constituicao ativo
	dbSelectArea("FNF")
	FNF->(dbSetOrder(6)) //FNF_FILIAL+FNF_IDPROC+FNF_CBASE+FNF_ITEM+FNF_TPSALD+FNF_TPMOV+FNF_STATUS
	If MsSeek(xFilial("FNF")+FNF->(FNF_IDPRCP+FNF_CBASE+FNF_ITEM+FNF_TPSALD)+"1")
		//Se for processo de apuracao, apuracao por baixa ou baixa
		//Recomponho o valor acumulado do AVP
		If cProcesso $ '2/3/4'
			RecLock("FNF",.F.,.T.)
			
			//Restauro o valor do AVP ao AVP Acumulado
			FNF->FNF_ACMAVP -= nValAvp
			
			//Reativo a constituicao
			If FNF->FNF_ACMAVP < FNF->FNF_VALOR 
				FNF->FNF_STATUS := '1'
			Endif
			
			MsUnlock()
		Endif

	Endif
	
	//Se for processo de apuracao, apuracao por baixa ou baixa
	//Recomponho o valor acumulado do AVP no item do projeto
	
	cBase := FNF->FNF_CBASE
	cItem := FNF->FNF_ITEM
	cTpSld:= FNF->FNF_TPSALD
	
	//reposiciono no registro a ser deletado
	FNF->(dbGoto(aCols[nX][nPosRec]))
	
	//Deleto o registro da FNF
	RecLock("FNF",.F.,.T.)
	FNF->(dbDelete())
	msUnlock()
	FKCOMMIT()
	
	if cProcesso $ '2/3/4' 
		AFGrvPrjAvp(cBase,cItem,'10',cTpSld)
	endif
Next

//Atualizo o registro da tabela de processos (FNP)
RecLock("FNP")
FNP->FNP_STATUS := "2"
MsUnlock()

//Encerro a contabilizacao
//Fecha contabilizacao para o processo de apuracao de AVP
//Quando esta rotina for chamada de outro processo, a contabilizacao sera fechada
//apenas na rotina de chamada.
If nHdlPrv > 0 .And. nTotal > 0
	RodaProva(nHdlPrv, nTotal)
	cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,lDigita,lAglutina)
Endif

END TRANSACTION

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF450Head ºAutor  ³Mauricio Pequim Jr  º Data ³  18/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aHeader da getdados dos movimentos de apropriacao  º±±
±±º          ³ do processo a ser cancelado                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA450                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF450Head()

Local aHeadAVP	:= {}
Local aCpos	  	:= {}
Local nX		  	:= 0
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())
Local nTamCpo	:= SX3->(Len(X3_CAMPO))

aAdd(aCpos,'FNF_CBASE')
aAdd(aCpos,'FNF_ITEM')
aAdd(aCpos,'FNF_TIPO')
aAdd(aCpos,'FNF_SEQ')
aAdd(aCpos,'FNF_TPSALD')
aAdd(aCpos,'FNF_REVIS')
aAdd(aCpos,'FNF_SEQAVP')
aAdd(aCpos,'FNF_DTAVP')
aAdd(aCpos,'FNF_VALOR')


SX3->(dbSetOrder(2)) //X3_CAMPO
For nX := 1 to Len(aCpos)
	dbSelectArea("SX3")
	dbSetOrder(2)
	If SX3->(MsSeek( Padr(aCpos[nX],nTamCpo )))
		IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
			
			cUsado := SX3->X3_USADO
			//Transformo em string o conteudo de SX3->X3_CBOX
			//Este tratamento eh feito pois a MsNewGetDados nao trata como combo
			// se SX3->X3_CBOX for igual a #Function()
			cCombo := SX3->X3_CBOX
			If Substr(cCombo,1,1) == "#"
				cCombo := &(Alltrim(Substr(cCombo,2)))
			Endif
			
			aAdd( aHeadAvp ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
			,SX3->X3_PICTURE ,SX3->X3_TAMANHO ;
			,SX3->X3_DECIMAL ,SX3->X3_VALID ;
			,SX3->X3_USADO ,SX3->X3_TIPO ;
			,SX3->X3_F3 ,SX3->X3_CONTEXT ;
			,cCombo ,SX3->X3_RELACAO})
		EndIf
	EndIf
Next

RestArea( aAreaSX3 )
RestArea( aArea )

Return aHeadAVP


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF450aCol ºAutor  ³Mauricio Pequim Jr. º Data ³  18/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aCols com os movimentos de apropriacoes do processoº±±
±±º          ³ a ser cancelado                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA450                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF450aCol(aHeader,cProcesso)

Local nX					:= 0
Local nCols		      := 0
Local aArea		  		:= GetArea()
Local aCols				:= {}

DEFAULT aHeader 	:= {}
DEFAULT cProcesso := ""


FNF->(dbSetOrder(6)) //FNF_FILIAL+FNF_IDPROC+FNF_CBASE+FNF_ITEM+FNF_TPSALD+FNF_TPMOV+FNF_STATUS
If FNF->(MsSeek(xFilial("FNF") + cProcesso ))
	While FNF->(!Eof()) .And. FNF->(FNF_FILIAL+FNF_IDPROC) == xFilial("FNF") + cProcesso
		aAdd(aCols,Array(Len(aHeader)+2))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := FNF->(FieldGet(FieldPos(aHeader[nX][2])))
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		aCols[nCols][Len(aHeader)+2] := .F.
		aCols[nCols][Len(aHeader)+1] := FNF->(RECNO())
		
		FNF->(dbSkip())
	Enddo
EndIf
RestArea(aArea)

Return aCols


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AF450Leg  ³Autor  ³ Alvaro Camillo Neto   ³ Data ³21.12.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function AF450Leg(lRetCor)
Local aRet		:= {}
Local aCores 	:= {	{"BR_VERDE"		,"FNP_STATUS == '1'", STR0016},;		//"Apuração Realizada"
{"BR_VERMELHO"	,"FNP_STATUS == '2'", STR0017}}		//"Apuração Cancelada"


DEFAULT lRetCor := .F.
If ValType(lRetCor) <> 'L'
	lRetCor := .F.
EndIf

If lRetCor
	aEval( aCores, {|x|  Aadd( aRet, {x[2],x[1]} ) } )
Else
	aEval( aCores, {|x|  Aadd( aRet, {x[1],x[3]} ) } )
	BrwLegenda(cCadastro,STR0018,aRet)		//"Legenda"
	aRet := Nil
EndIf

Return(aRet)






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³24/10/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados            ³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Private aRotina := { { STR0019 ,"AxPesqui"  , 0, 1 , ,.F.},;		//"Pesquisar"
{ STR0020 ,"AxVisual"  , 0, 2			},;		//"Visualizar"
{ STR0021 ,"AF450Apur" , 3, 3			},;		//"Apuração"
{ STR0022 ,"AF450Can"  , 5, 5			},;		//"Cancelar"
{ STR0023 ,"AF450Ctb"  , 4, 4			},;		//"Contabilizar"
{ STR0018 ,"AF450Leg"  , 4, 2			} }		//"Legenda"
Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} AF450Dados
Função de busca dos dados da tabela FNF das movimentações feita no
ambiente do Ativo Fixo no contexto do AVP(Constituição/Baixa/Apropriação).

@author marylly.araujo
@since 13/02/2014
@version MP12
/*/
//-------------------------------------------------------------------
Function AF450Dados(cAlsTabReg,aCampos,dDtInicial,dDtFinal)
Local lRet		:= .T.
Local cAlsFNF	:= GetNextAlias()
Local cQryFNF	:= ''
Local aArea	:= GetArea()
Local aFNFArea:= {}
Local aValores:= {}

DbSelectArea('FNF')
aFNFArea := FNF->(GetArea())

cQryFNF := 'SELECT ' + CRLF
cQryFNF += 'FNF.R_E_C_N_O_  FNFRECNO ' + CRLF
cQryFNF += ',FNF.FNF_ORIGEM ' + CRLF
cQryFNF += ',FNF.FNF_DTCONT ' + CRLF
cQryFNF += ',FNF.FNF_LP ' + CRLF
cQryFNF += ' FROM ' + RetSqlName('FNF') + ' FNF ' + CRLF
cQryFNF += ' WHERE ' + CRLF
cQryFNF += RetSqlCond('FNF') + CRLF
cQryFNF += " AND FNF.FNF_LA <> 'S' "
cQryFNF += " AND FNF.FNF_DTAVP BETWEEN '" + DTOS(dDtInicial) + "' AND '" + DTOS(dDtFinal) + "' "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFNF), cAlsFNF , .F., .T.)

While !(cAlsFNF)->(Eof())
	aAdd(aValores,{(cAlsFNF)->FNF_ORIGEM,;
					 (cAlsFNF)->FNFRECNO,;
					 (cAlsFNF)->FNF_LP,;
					 'FNF',;
					 'FNF_LA',;
					 'FNF_DTCONT'})	
	(cAlsFNF)->(DbSkip())
EndDo

CTAFGRVTMP(@cAlsTabReg,aCampos,aValores)

(cAlsFNF)->(DbCloseArea())

RestArea(aFNFArea)
RestArea(aArea)
Return lRet
