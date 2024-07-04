#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FWBrowse.ch'
#Include 'FINA689.ch'

Static __cAliasTMP	:= ""
Static __cArqTrab	:= ""
Static __lBlind		:= IsBlind()
Static _oFINA6891	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA689
Rotina responsável pela manutencao de cotações em Lote para títulos
gerados por Adiantamentos de Viagem ou Prestação de Contas de viagem

@author Jacomo Lisa
@since 28/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA689(cAlias,nReg,nOpc,lAutomato)

Local lOk		:= .F.
Local aArea		:= GetArea()
Local aTmpFil	:= {}
Local nX		:= 0

Default	lAutomato	:= .F.

__cAliasTMP	:= ""
__cArqTrab	:= ""

While !lOk
	If Pergunte("FINA689")
		lOk := F689FWMarkB(aTmpFil,lAutomato)
		If lAutomato
			Exit
		EndIF
	Else
	   Exit
	EndIf
EndDo

If !Empty(__cArqTrab) .And. Select(__cArqTrab) > 0
	(__cArqTrab)->(DbCloseArea())
EndIf

If !Empty(__cAliasTMP) .And. Select(__cAliasTMP) > 0
	(__cAliasTMP)->(DbCloseArea())
EndIf

__cAliasTMP	:= ""
__cArqTrab	:= ""

//Apaga a tabela temporaria das filiais
For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next

If _oFINA6891 <> Nil
	_oFINA6891:Delete()
	_oFINA6891:= Nil
EndIf

RestArea(aArea)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F689FWMarkB
Tela de seleção de documentos relacionado ao DH
@author Jacomo Lisa
@since 29/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F689FWMarkB(aTmpFil,lAutomato)

Local oDlg 		:= Nil
Local cQuery	:= cQryFil := cFil	:= ""
Local nX		:= 0
Local aStrMrk	:= {}
Local aCampos	:= {'E2_FILIAL','FLD_VIAGEM','FLD_ADIANT','FLD_PARTIC ','FL5_DTINI','FL5_DTFIM','FLD_VALOR'}
Local nRet 		:= 0
Local bOk 		:= {||(nRet := 1,  oDlg:End())}
Local bCancel	:= {||(nRet := 0,  oDlg:End())}
Local aArea 	:= GetArea()
Local cCampos 	:= ""
Local cChave 	:= ""
Local cMoeda 	:= ""
Local lRet 		:= .T.
Local oModelE2	:= NIL 
Local oSubFKA	:= NIL
Local oSubFK2	:= NIL
Local cChaveTit	:= ""
Local cIdFK2	:= ""
Local cChaveFK7	:= ""
Local cCamposE5	:= ""
Local cLog		:= ""
Local cTmpSE2Fil:= ""
Local cMarca	:= GetMark()
Local aSelFil	:= {}
Local aCpoBro	:= {}
Local aFilial	:= {}
//-- Automacao
Local aRetAuto := {}
Local cChavAut	:= ''
Local cRecTab		:= ''

Default lAutomato := .F.

//Caso a moeda for maior que 9, muda o parâmetro 
If MV_PAR07 >= 1 .AND. MV_PAR07 <= 9 
	cMoeda 	:= GETMV("MV_MOEDA"+cValToChar(MV_PAR07),.T.,"")
ElseIf MV_PAR07 >= 10 
	cMoeda 	:= GETMV("MV_MOED"+cValToChar(MV_PAR07),.T.,"")
Endif

If Empty(cMoeda)
	HELP(' ',1,STR0008,,STR0009,2,0,,,,,,{STR0010})		//'MOEDA INVÁLIDA'###"A moeda preenchida nos parâmetros da rotina (F12) não está cadastrada no sistema."###"Por favor, verifique o preenchimento dos parâmetros para processamento da rotina (F12)."
	lRet := .F.
Else 
	cMoeda 	:= cValToChar(MV_PAR07) + '-' + cMoeda
Endif	

If lRet
	//Seleciona filiais
	If MV_PAR09 == 1 //Sim
		If !lAutomato
			aFilial := AdmGetFil(.F.,.T.,"SE2")
		Else
			aFilial := AdmGetFil(.T.,.T.,"SE2")
		EndIf
	Else
		aFilial := {cFilAnt}
	EndIf

	Aadd(aStrMrk, {"FLD_OK","C",2,0,})
	Aadd(aStrMrk, {"FLDRECNO","N",10,0,})
	Aadd(aStrMrk, {"SE2RECNO","N",10,0,})

	SX3->(DBSETORDER(2))
	For nX := 1 To Len(aCampos)
		If SX3->(DBSEEK(aCampos[nX]))
			aAdd(aStrMrk, {aCampos[nX], SX3->X3_TIPO, TamSx3(aCampos[nX])[1],SX3->X3_DECIMAL,SX3->X3_PICTURE})
			cCampos += ","+SX3->X3_ARQUIVO+"."+ aCampos[nX] + CRLF
		EndIf
	Next nX	

	//CriaTrab o arquivo temporário, caso o mesmo já não tenha sido criado
	If __cArqTrab == ""
		cQuery := "SELECT FLD.R_E_C_N_O_ AS FLDRECNO, SE2.R_E_C_N_O_ AS SE2RECNO, "
		cQuery += SUBSTR(cCampos,2)
		cQuery += " FROM " + RetSqlName('FLD') + " FLD "
		cQuery += " INNER JOIN " + RetSqlName('FL5') + " FL5 ON "
		cQuery += " FL5_FILIAL = FLD_FILIAL "
		cQuery += " AND	FL5_VIAGEM = FLD_VIAGEM "
		cQuery += " INNER JOIN " + RetSqlName('SE2') + " SE2 ON "
		cQuery += " SE2.E2_FILIAL = FLD_FILIAL "
		cQuery += " AND SE2.E2_PREFIXO = FLD.FLD_PREFIX " 
		cQuery += " AND SE2.E2_NUM     = FLD.FLD_TITULO " 
		cQuery += " AND SE2.E2_PARCELA = FLD.FLD_PARCEL " 
		cQuery += " AND SE2.E2_TIPO    = FLD.FLD_TIPO "

		cQuery += " WHERE "
		
		If !Empty(aFilial)
			cQuery += " SE2.E2_FILIAL " + GetRngFil( aFilial, "SE2", .T., @cTmpSE2Fil ) 
			aAdd(aTmpFil, cTmpSE2Fil)
		Else
			cQuery += " SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
		EndIf

		cQuery += " AND	(SE2.E2_SALDO > 0 " 
		cQuery += " AND	SE2.E2_MOEDA > 1 " 
		cQuery += " AND	SE2.E2_ORIGEM IN ('FINA667','FINA677') " 
		cQuery += " AND	SE2.E2_TXMOEDA = 0) " 
		cQuery += " AND SE2.E2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " 
		cQuery += " AND SE2.E2_FORNECE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "' " 
		cQuery += " AND SE2.E2_LOJA    BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' " 
		cQuery += " AND SE2.E2_MOEDA = " + cValToChar(MV_PAR07) 
		cQuery += " AND FLD.D_E_L_E_T_ = ' ' "
		cQuery += " AND FL5.D_E_L_E_T_ = ' ' " 
		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )

		__cAliasTMP := CriaTrab(,.F.)
		
		MPSysOpenQuery(cQuery,__cAliasTMP)

		If _oFINA6891 <> Nil
			_oFINA6891:Delete()
			_oFINA6891:= Nil
		EndIf

		__cArqTrab := CriaTrab(,.F.) // Nome do arquivo temporario

		// -- Cria tabela temporaria
		_oFINA6891 := FwTemporaryTable():New(__cArqTrab)
		_oFINA6891:SetFields(aStrMrk)
		_oFINA6891:AddIndex("1", {"FLD_VIAGEM"} )
		_oFINA6891:Create()
		// --
		
		//Preenche Tabela TMP com as informações filtradas
		If !(__cAliasTMP)->(Eof()) .AND. !(__cAliasTMP)->(Bof())
			While !(__cAliasTMP)->(Eof())
				RecLock( __cArqTrab, .T. )
				
				For nX := 1 To Len(aStrMrk)
					If aStrMrk[nX][1] == 'FLD_OK'
						(__cArqTrab)->&(aStrMrk[nX][1]) := '  '
					ElseIf aStrMrk[nX][2] == "D"
						(__cArqTrab)->&(aStrMrk[nX][1]) := STOD((__cAliasTMP)->&(aStrMrk[nX][1]))
					Else 
						(__cArqTrab)->&(aStrMrk[nX][1]) := (__cAliasTMP)->&(aStrMrk[nX][1])
					EndIf
						
				Next nX
				
				(__cArqTrab)->( MsUnlock() )
		
				(__cAliasTMP)->( dbSkip() )
			EndDo

			(__cArqTrab)->(dbgotop())
			For nX := 1 To Len(aStrMrk)
				If !aStrMrk[nX][1] $ "FLDRECNO|SE2RECNO" .and. !(xFilial("SE2") == '  ' .AND. aStrMrk[nX][1] == 'E2_FILIAL')
					aadd(aCpoBro,{ aStrMrk[nX][1],, RetTitle(aStrMrk[nX][1]),aStrMrk[nX][5]})
				EndIf
			Next nX 

			If !(__lBlind) 
				oSize := FWDefSize():New(.T.)
			
				oSize:AddObject("MASTER",100,100,.T.,.T.)
				oSize:lLateral := .F.				
				oSize:lProp := .T.
				
				oSize:Process()
			
				DEFINE MSDIALOG oDlg TITLE STR0001 PIXEL FROM oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd		//"Cotação da Moeda Extrangeira"
				
				nLinIni := oSize:GetDimension("MASTER","LININI")
				nColIni := oSize:GetDimension("MASTER","COLINI")
				nLinFin := oSize:GetDimension("MASTER","LINEND")
				nColFin := oSize:GetDimension("MASTER","COLEND")
			
				@ nLinIni+3	, 05 Say STR0002	FONT oDlg:oFont  PIXEL Of oDlg		//"Moeda:" 
				@ nLinIni	, 30 get cMoeda		FONT oDlg:oFont  WHEN .F. PIXEL Of oDlg 
				
				@ nLinIni+3	,100 Say STR0003	FONT oDlg:oFont  PIXEL Of oDlg		//"Cotação:" 
				@ nLinIni	,125 MSGET oCotacao VAR MV_PAR08	PICTURE PesqPict("SE2","E2_TXMOEDA") FONT oDlg:oFont PIXEL Of oDlg HASBUTTON
				oCotacao:lReadOnly := .T.
				
				oMark := MsSelect():New(__cArqTrab,"FLD_OK" ,"",aCpoBro,.F.,@cMarca,{nLinIni+20, nColIni, nLinFin, nColFin},,)
				oMark:bMark := {||F689Mark(cMarca)}
				oMark:bAval	:= {||F689Mark(cMarca)}
				oMark:oBrowse:lhasMark := .t.
				oMark:oBrowse:lCanAllmark := .t.
				oMark:oBrowse:bAllMark := {|| MarkAll(cMarca) }
				
				If !lAutomato
					ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg, bOk , bCancel) CENTERED 
				Else
					If FindFunction("GetParAuto")
						aRetAuto	:= GetParAuto("FINA050TestCase")
					EndIf
					cRecTab := (__cArqTrab)->(RECNO())
					(__cArqTrab)->(dbGoTop())
					While !(__cArqTrab)->(Eof())
						For nX := 1 TO Len(aRetAuto)
							cChavAut:= (__cArqTrab)->FLD_VIAGEM + (__cArqTrab)->FLD_ADIANT
							If cChavAut == aRetAuto[nX][1]
								F689Mark(cMarca)
							EndIf
						Next nX
						(__cArqTrab)->(DbSkip())
					EndDo
					(__cArqTrab)->(dbGoto(cRecTab))
					nRet := 1
				EndIf
			Else
				nRet := 1
			EndIf
			
			If nRet == 1
				(__cArqTrab)->(dbGoTop())
				While !(__cArqTrab)->(Eof())
					If (__cArqTrab)->FLD_OK == cMarca .or. __lBlind
						SE2->(DBGOTO((__cArqTrab)->SE2RECNO))
						
						//Guardar o valor da E2_VLCRUZ
						nOldVlr := SE2->E2_VLCRUZ
						//Calcular o novo valor em reais (valo * nova taxa)
						nNewVlr := SE2->E2_VALOR * MV_PAR08
						//Acho a diferença do câmbio
						nDifCambio := nNewVlr - nOldVlr

						BEGIN TRANSACTION
											
						SE2->(RecLock("SE2", .F.))
						SE2->E2_TXMOEDA := MV_PAR08
						SE2->E2_VLCRUZ	:= nNewVlr
						SE2->E2_CORREC	:= nDifCambio			
						SE2->(MSUNLOCK())
						
						FLD->(DBGOTO((__cArqTrab)->FLDRECNO))
						FLD->(RecLock("FLD", .F.))
						FLD->FLD_TAXA := MV_PAR08
						FLD->(MSUNLOCK())

						//Gravo a correção monetária
						Reclock("SE5",.T.)
							Replace E5_FILIAL With xFilial()
							Replace E5_PREFIXO With SE2->E2_PREFIXO
							Replace E5_NUMERO  With SE2->E2_NUM
							Replace E5_PARCELA With SE2->E2_PARCELA
							Replace E5_TIPO    With SE2->E2_TIPO
							Replace E5_CLIFOR  With SE2->E2_FORNECE
							Replace E5_LOJA    With SE2->E2_LOJA
							Replace E5_MOEDA   With "M2"
							Replace E5_VALOR   With nDifCambio
							Replace E5_VLMOED2 With xMoeda(nDifCambio,1,SE2->E2_MOEDA)
							Replace E5_DATA    With dDataBase
							Replace E5_NATUREZ With SE2->E2_NATUREZ
							Replace E5_RECPAG  With "P"
							Replace E5_TIPODOC With "VM"
							Replace E5_DTDIGIT With dDataBase
							Replace E5_DTDISPO With dDataBase
							Replace E5_HISTOR  With STR0007	//"Variação Monetaria Viagem"
						MsUnlock()

						//Dados da tabela auxiliar com o código do título a pagar
						cChaveTit 	:= xFilial("SE2") + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM  +	 "|" + SE2->E2_PARCELA + "|" + ;
															SE2->E2_TIPO	  + "|" + SE2->E2_FORNECE +	 "|" + SE2->E2_LOJA
						cChaveFK7	:= FINGRVFK7("SE2", cChaveTit)
						cIdFK7		:= FWUUIDV4()

						//FKA x FK7.
						RecLock("FKA",.T.)				
							FKA_FILIAL	:= xFilial("FKA")     
							FKA_IDFKA	:= cIdFK7                           
							FKA_IDPROC	:= FINFKSID('FKA', 'FKA_IDPROC')
							FKA_IDORIG  := cChaveFK7                       
							FKA_TABORI	:= "FK7"
						MsUnlock()
										
						//Dados da variação cambial.		
						RecLock("FK6",.T.)
							FK6_FILIAL	:= xFilial("FK6")
							FK6_IDFK6	:= FINFKSID('FK6', 'FK6_IDFK6')
							FK6_IDORIG	:= cChaveFK7
							FK6_TABORI	:= "FK7"						
							FK6_VALMOV	:= nDifCambio
							FK6_VALCAL	:= nDifCambio 
							FK6_TPDESC	:= "2"
							FK6_TPDOC	:= "VM"
							FK6_RECPAG	:= "P"
							FK6_HISTOR	:= STR0007		//"Variação Monetaria Viagem"				
						MsUnlock()

						END TRANSACTION
						
					EndIf
					(__cArqTrab)->(DbSkip())
				EndDo
				
				(__cArqTrab)->(DbGOTOP())
			EndIf
			RestArea(aArea)
		Else
			If !(__lBlind)
				Help("  ",1,"NOREGS689",,STR0004,1,0)		//"Não foi localizado nenhum registro com os dados informados"
			EndIf
			lRet := .F.
		EndIf
			
	EndIf
		
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Função para marcar todos os itens da markbrowse.

@author Jacomo Lisa
@since 02/07/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MarkAll(cMarca)
Local nRecno := 0
Local lRet	 := .T.

(__cArqTrab)->(dbGoTop())
While !(__cArqTrab)->(Eof())
	nRecno := (__cArqTrab)->SE2RECNO
	SE2->(dbGoto(nRecno))
	F689Mark(cMarca)
	(__cArqTrab)->(DBSKIP())
EndDo
(__cArqTrab)->(dbGoTop())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F689Mark
Função para marcar todos os itens da markbrowse.

@author Jacomo Lisa
@since 02/07/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function F689Mark(cMarca)
If SE2->(MsRLock())
	RecLock(__cArqTrab, .F.)
	If (__cArqTrab)->FLD_OK == cMarca		
		(__cArqTrab)->FLD_OK := ' '		
	Else
		(__cArqTrab)->FLD_OK :=cMarca
	EndIf
	(__cArqTrab)->(MsUnlock())
	lRet := .T.
Else
	If !(__lBlind)
		Help("  ",1,"REGBLOCKED_667",,STR0005,1,0)		//"Este titulo não pode ser selecionado pois se encontra em uso por outro terminal."
	EndIf
	lRet := .F.
Endif

oMark:oBrowse:Refresh()

Return lRet
