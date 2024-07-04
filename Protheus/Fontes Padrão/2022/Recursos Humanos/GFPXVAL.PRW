#INCLUDE  "PROTHEUS.CH"
#INCLUDE  "VDFXFUN.CH"
  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ FNC			 ³  Motivo da Alteracao 					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcos Perei³01/07/15³PCREQ-5342      ³Inclusao fonte							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/



//------------------------------------------------------------------------------
/*/{Protheus.doc} fVldDtFal()
Função que valida a DATA DE REFERENCIA da uma verba de devolução de falta
Incluso no Valid do campo RGB_DTREF
@return		lRet
@author	    Fabricio Amaro
@since		03/02/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function fVldDtFal()
	Local aArea	  := GetArea()
	Local lRet	  := .T.
	Local dRef	  := M->RGB_DTREF
	Local cVerba  := aCols[ n, GdFieldPos( "RGB_PD"	  , aHeader )]
	Local nQuant  := aCols[ n, GdFieldPos( "RGB_HORAS", aHeader )]
	Local nQtAnt  := 0
	Local nValAnt := 0
	Local cVerba1 := ""
	Local cVerba2 := ""
	Local aPerAtual := {}
	
	If cVerba == fGetCodFol("0244")     //0244	Reembolso de Faltas
		cVerba1 := fGetCodFol("0054")   //0054	Faltas
		cVerba2 := fGetCodFol("0203")   //0203	Faltas Mes Anterior
	ElseIf cVerba == fGetCodFol("0245") //0245	Reembolso de Atrasos
		cVerba1 := fGetCodFol("0055")   //0055	Atrasos
		cVerba2 := fGetCodFol("0243")   //0243	Atrasos (II)
	ElseIf cVerba == fGetCodFol("1363") //1363	Devolução Faltas II
		cVerba1 := fGetCodFol("0242")   //0242	Faltas (II)
	ElseIf cVerba == fGetCodFol("1366") //1366	Devolução Faltas III
		cVerba1 := fGetCodFol("1364")   //1364	Faltas (III)
	ElseIf cVerba == fGetCodFol("1367") //1366	Devolução Faltas IV
		cVerba1 := fGetCodFol("1365")   //1364	Faltas (IV)
	Else
		//-Nao permitir informar data diferente do Periodo selecionado
		//-fGetPerAtual( aPerAtual, cFilRCH, cProcesso, cRoteiro )
		fGetPerAtual( @aPerAtual,,cProcesso,cRoteiro )
		
		//-aPerAtual, { RCH_PER, RCH_NUMPAG, RCH_ROTEIR, RCH_MES, RCH_ANO, RCH_DTINI, RCH_DTFIM, RCH_PROCES } 
		If Len(aPerAtual) == 0
			lRet := .F.
			Help(,,STR0012,,STR0026,1,0)  //'Erro'####'//'Periodo em Aberto não localizado!'
		Else
			If dRef >= aPerAtual[1,6] .And. dRef <= aPerAtual[1,7]
				lRet := .T.
			Else
				lRet := .F.
				MsgBox(STR0027, STR0028,"STOP") //'Data informada não é compatível com o Período em Aberto!'####'Data de Referência'
			EndIf
		EndIf
	EndIf

	If lRet .And. ( !(Empty(cVerba1)) .OR. !(Empty(cVerba2)) ) 
		If !(Empty(cVerba1))
			nQtAnt  += fBuscaAcm(cVerba1,,FIRSTDAY(dRef),LASTDAY(dRef),"H")*(-1)
			nValAnt += fBuscaAcm(cVerba1,,FIRSTDAY(dRef),LASTDAY(dRef),"V")*(-1)
		EndIf
		If !(Empty(cVerba2))
			nQtAnt  += fBuscaAcm(cVerba2,,FIRSTDAY(dRef),LASTDAY(dRef),"H")*(-1)
			nValAnt += fBuscaAcm(cVerba2,,FIRSTDAY(dRef),LASTDAY(dRef),"V")*(-1)
		EndIf
	
		If nQtAnt == 0
			MsgBox( STR0022 , STR0023 ,"STOP") //"Não foi encontrado nenhuma FALTA/ATRASO para essa devolução, no período da data informada!"  "Devolução de Falta/Atraso"
			lRet := .F.
		EndIf
		
		If (nQuant > nQtAnt) .AND. lRet 
			MsgBox( STR0024 , STR0023 ,"STOP")  //"A quantidade de Dias/Horas informada é maior que o da FALTA/ATRASO original, no período da data informada!"   "Devolução de Falta/Atraso"
			lRet := .F.
		EndIf
		
		aCols[ n, GdFieldPos( "RGB_VALOR", aHeader )] := (nValAnt / nQtAnt) * nQuant
		aCols[ n, GdFieldPos( "RGB_TIPO1", aHeader )] := "V"
	EndIf	
	RestArea( aArea )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VERIFICAID()
Função que verifica se existe uma verba relacionada ao ID passado no parametro
@return		
@author	    Fabricio Amaro
@since		09/01/2014
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VERIFICAID(aID)
	Local i		 		:= 0
	Local lEndCalc 		:= .F.
	Local nTam := TamSX3("RCN_CODIGO")[1]
	If ValType(aID) == "A"
		For i := 1 To Len(aID)
			If Empty(fGetCodFol(aID[i]))
				CMSGLOG := FMSGFORM({19}) + STRZERO(VAL(aID[i]),4) + " - " + FDESC("RCN", STRZERO(VAL(aID[i]),nTam) , "RCN_DESCRI")
				MSGLOGID(CMSGLOG)
				lEndCalc := .T.
			EndIf
		Next
		If lEndCalc 
			ENDCALC()
		EndIf
	Else
		If Empty(fGetCodFol(aID))
			CMSGLOG := FMSGFORM({19}) + STRZERO(VAL(aID),4) + " - " + FDESC("RCN", STRZERO(VAL(aID),nTam) , "RCN_DESCRI")
			MSGLOGID(CMSGLOG)
			ENDCALC()
		EndIf
	EndIf
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldOpc()
Função que valida as informações contidas no campo
@return		C
@author	    Fabricio Amaro
@since		28/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VldOpc(cTabela,cCampoRet,cSeparador,cPassa)
	Local lRet 		:= .T.
	Local i 		:= 0
	Local cCampoPos := readvar()
	Local cConteudo := Alltrim(&cCampoPos)
	Local cContInd	:= ""  //CONTEUDO
	Local nTamCamp  := TamSX3(cCampoRet)[1]
	Default cPassa := "" 
	
	If !(Empty(cConteudo))
		
		//SE O CONTEUDO DO CAMPO PARA DEIXAR PASSAR, RETORNA .T.
		If cPassa == cConteudo
			Return .T.
		EndIf
		
		If Right(alltrim(cConteudo),1) == cSeparador
			cConteudo := SubStr(cConteudo,1,len(alltrim(cConteudo)) - 1)
		EndIf
		
		For i := 1 to (Len(cConteudo)+1)
			cPosAtu := SubStr(cConteudo,i,1)
			If (cPosAtu == cSeparador) .OR. (i > Len(cConteudo)) 
			
				If !(Len(cContInd) == nTamCamp)
					lRet := .F.				
				Else			
					cVld := (Posicione(cTabela,1,xFilial(cTabela) + cContInd,cCampoRet))
					If Empty(cVld)
						lRet := .F.
					EndIf
				EndIf
				If !lRet
					cMsg := STR0011+cContInd //'Atenção! Valor inválido no conteúdo desse campo: '
					Help(,,STR0012,,cMsg,1,0)//"Erro"
					lRet := .F.
					Exit
				EndIf
				
				cContInd := ""
			Else
				cContInd += cPosAtu
			EndIf
		Next
	EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldOpcMes()
Função que valida as informações contidas no campo de Meses
@return		C
@author	    Fabricio Amaro
@since		28/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VldOpcMes(cSeparador,cPassa)
	Local lRet 		:= .T.
	Local i 		:= 0
	Local cCampoPos := readvar()
	Local cConteudo := Alltrim(&cCampoPos)
	Local cContInd	:= ""  //CONTEUDO
	Local nTamCamp  := 2 
	Default cPassa := "" 
	
	If !(Empty(cConteudo))
		
		//SE O CONTEUDO DO CAMPO PARA DEIXAR PASSAR, RETORNA .T.
		If cPassa == cConteudo
			Return .T.
		EndIf
		
		If Right(alltrim(cConteudo),1) == cSeparador
			cConteudo := SubStr(cConteudo,1,len(alltrim(cConteudo)) - 1)
		EndIf
		
		For i := 1 to (Len(cConteudo)+1)
			cPosAtu := SubStr(cConteudo,i,1)
			If (cPosAtu == cSeparador) .OR. (i > Len(cConteudo)) 
			
				If !(Len(cContInd) == nTamCamp)
					lRet := .F.				
				Else			
					If !(cContInd $ "01/02/03/04/05/06/07/08/09/10/11/12")
						lRet := .F.
					EndIf
				EndIf
				If !lRet
					cMsg := STR0011+cContInd //'Atenção! Valor inválido no conteúdo desse campo: '
					Help(,,STR0012,,cMsg,1,0)//"Erro"
					lRet := .F.
					Exit
				EndIf
				
				cContInd := ""
			Else
				cContInd += cPosAtu
			EndIf
		Next
	EndIf
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} SQ3WHEN()
Validação  When Dos campos da Tabela SQ3
@sample 	SQ3WHEN()                     
@return	L
@author	Nivia Ferreira			
@since		02/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function SQ3WHEN()
	Local lRet := .T.
	If fUsaGFP() //Gestao de Folha Publica 
	    If  M->Q3_CATEG $ 'E;G;4;7;8;9'  // E-G=Estagiário; 4=Adido; 7=Membro Aposentado; 8=Servidor Aposentado; 9=Pensionista
	        M->Q3_TABELA   := Space( TamSX3("Q3_TABELA")[1] )
	        M->Q3_TABNIVE  := Space( TamSX3("Q3_TABNIVE")[1] )
	        M->Q3_TABFAIX  := Space( TamSX3("Q3_TABFAIX")[1] )
	        lRet := .F.
	     Endif   
	Endif
Return lRet


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³fValDtPer    ³Autor³ IP RH GSP              ³Data³18/03/2014³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Retornar .T. se a data passada por parametro for maior ou  ³
³          ³ igual a data inicial do periodo em aberto.                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function fValDtPer(dData,lValDtFim)
Local lRet := .F.
Local aPerAtual := {}

Default dData := dDataBase
Default lValDtFim := .F.

//-fGetPerAtual( aPerAtual, cFilRCH, cProcesso, cRoteiro )
fGetPerAtual( @aPerAtual,,SRA->RA_PROCES,"FOL" )

//-aPerAtual, { RCH_PER, RCH_NUMPAG, RCH_ROTEIR, RCH_MES, RCH_ANO, RCH_DTINI, RCH_DTFIM, RCH_PROCES } 
If Len(aPerAtual) == 0
	Help(,,STR0007,,STR0009, 1,0) //"Atenção"###"Não foi localizado o Período em Aberto. Verifique o cadastro de períodos!"
Else
	If !lValDtFim
		bIf := &("{ || dData >= aPerAtual[1,6] }")
	Else
		bIf := &("{ || dData >= aPerAtual[1,6] .And. dData <= aPerAtual[1,7] }")
	EndIf
	
	If Eval(bIf)
		lRet := .T.
	Else
		//-help(cRotina,nLinha,cCampo,cNome,cMensagem,nLinha1,nColuna,lPop,hWnd,nHeight,nWidth,lGravaLog)
		Help(,,STR0007,,STR0010+aPerAtual[1,1], 1,0) //"Atenção"###"A Data informada tem que ser maior ou igual ao Periodo em Aberto - "
	EndIf
EndIf

Return(lRet)


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³ GFPWhen     ³Autor³ IP RH GSP              ³Data³07/07/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Libera ou nao o campo conforme regras do GFP               ³
³          ³ Utilizado no X3_WHEN                                       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function GFPWhen(cCampo)

Local 	cDesabilita := ''
Default cCampo 		:= ''

//Caso algum campo tenha que voltar a ser liberado, basta retira-lo da variavel abaixo, sem precisar mudar o X3_WHEN no dicionario
cDesabilita := "Q3_CC/Q3_CLASSE/QB_CC"

If fUsaGFP()
	If !empty(cCampo) .and. alltrim(UPPER(cCampo)) $ cDesabilita
		return(.f.)
	EndIf
EndIf

Return(.t.)
	
	
/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³ GFPINITFUN  ³Autor³ IP RH GSP              ³Data³07/07/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³ Função executada na entrada do módulo SIGAGFP              ³
³          ³                                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Function GFPINITFUN()

CompTabVDF()  //Funcao no VDFXVAL, que verifica os compartilhamentos de tabelas
	If oApp:lMDI
		ClearStatic()
	EndIf
Return Nil



FUNCTION VLDDIAF()
LOCAL LRET := .F.

IF FWIsInCallStack("GPEA050")
	LRET := Gp050DIAF()
Else
	LRET := .T.
EndIf

RETURN LRET


FUNCTION FDtValid(CINFO)

LOCAL LRET := .F.
If Type("lGp050Auto") <> "L"
	lGp050Auto := .F.
EndIf

IF FWIsInCallStack("GPEA050") .OR. FUNNAME() == "GPEA050" .OR. FUNNAME() == "GPEA011" .Or. lGp050Auto
	LRET := gp050DtValid(CINFO) 
Else
	LRET := gp051DtValid(CINFO) 
EndIf

RETURN LRET



FUNCTION FPDValid(CINFO)

LOCAL LRET := .F.

IF CINFO <> Nil

	IF FWIsInCallStack("GPEA050")
		DbSelectArea( "SRV" )
		DbSetOrder( RetOrdem( "SRV", "RV_FILIAL+RV_COD" ) )
		LRET := DbSeek( xFilial( "SRV" ) + CINFO, .F. ) .And. GP050DESCPD(CINFO) .AND. PDISABSENCE( CINFO , .T.)
	Else
		LRET := ExistCpo("SRV",CINFO,1) .And. PDISABSENCE( CINFO , .T.)  
	EndIf
Else
	LRET := .T.
ENDIF

RETURN LRET

                                                                            
FUNCTION FVerEdit()

LOCAL LRET := .F.

IF FWIsInCallStack("GPEA050")
	LRET := gp050VerEdit()
Else
	LRET := .T.
EndIf

RETURN LRET                                              


FUNCTION OPCSTATUS()

Local cOpcBox := ""
	
	IF FWIsInCallStack("GPEA050")

		cOpcBox += ( OemToAnsi("1=Ativo"	) + ";"  ) 
		cOpcBox += ( OemToAnsi("2=Prescrito") + ";"  ) 
		cOpcBox += ( OemToAnsi("3=Pago"		) + ";"  ) 
	Else	
		cOpcBox += ( OemToAnsi("0=Em aquisicao"	) + ";"  )
		cOpcBox += ( OemToAnsi("1=Ativo"		) + ";"  ) 
		cOpcBox += ( OemToAnsi("2=Prescrito"	) + ";"  ) 
		cOpcBox += ( OemToAnsi("3=Pago"			) + ";"  ) 
		cOpcBox += ( OemToAnsi("4=Cancelado"	) + ";"  ) 
		cOpcBox += ( OemToAnsi("5=Retificado"	) + ";"  ) 
	ENDIF

Return cOpcBox


FUNCTION VLDSTATUS()

LOCAL LRET := .F.

IF FWIsInCallStack("GPEA050")
	LRET := pertence("1,2,3")
Else	
	LRET := pertence("0,1,2,3,4,5")
Endif

RETURN LRET



FUNCTION INISTATUS()

LOCAL CSTATUS := ''

IF FWIsInCallStack("GPEA050")
	CSTATUS := "1"
Else
	CSTATUS := "0"
ENDIF

RETURN CSTATUS 


STATIC FUNCTION MSGLOGID(CMSGLOG)

NPOS := 0
IF ( !EMPTY(CMSGLOG) )    
	NPOS  := ASCAN(AMSGLOG,{|X| X == CMSGLOG})	
	IF ( LOK := EMPTY(NPOS) )	
	    AADD(AMSGLOG,CMSGLOG)	
	    ADDLOGEXECROT(CMSGLOG)	
	EndIF 
EndIF

RETURN

//------------------------------------------------------------------------------
/*/{Protheus.doc} FVLDS103()
Validação das Matriculas Liberadas e Bloqueadas
@sample FVLDS103()                    
@param		cMatr1 e cMatr2
@return		L
@author	    Silvia Taguti	
@since		01/08/2018
@version	P12      
/*/
//------------------------------------------------------------------------------

Function fVldS103(cMatr1,cMatr2)
                                    
Local nx := 0
Local cFiltroM   := ""
Local lRet 	:= .T.
Local aMatVal := {}
Local cMatrC  := ""  
Local nPosT   := 0
Local cMatrDupli := ""  
Local nTotM   := 0	

Default cMatr1 := ""
Default cMatr2 := ""          
	
If !Empty(AllTrim(cMatr2))
	If (nPosT :=  GdFieldPos(cMatr2, aHeader)) > 0 
		cMatrC := aCols[n, nPosT]                                
	Endif
Endif 		
	
If !Empty(Alltrim( cMatrC)) 

	aMatVal := SEPARA(cMatr1,"/",.F.) 

	For nX:= 1  to Len(aMatVal)
		If aMatVal[nx] $ Alltrim(cMatrC)
		   cMatrDupli += aMatVal[nx]+ "/"
		Endif
	Next

	If !Empty(cMatrDupli)
   		MsgInfo( STR0013 + CRLF + STR0039 + cMatrDupli ) // "Atenção!" ### "Duplicidade entre Matriculas Liberadas e Matriculas Bloqueadas: "
	    Return .F.
    Endif
Endif   
	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VALIDS100()
Validação duplicidade Codigo tabela S100
@sample VALIDS100()                    
@param		cCodigo cConteudo nPos1 nPos2
@return		L
@author	    Silvia Taguti	
@since		01/08/2018
@version	P12      
/*/
//------------------------------------------------------------------------------

Function ValidS100(cCodigo,cConteudo,nPos1,nPos2,lMsg)
Local lRet := .T.

lRet := !ValidRCC(cCodigo,cConteudo,nPos1,nPos2,.F.)

If !lRet .and. lMsg
	MsgAlert(OemToAnsi(STR0040))//"Codigo do tipo de documento ja cadastrado, favor incluir outro codigo"
EndIf

Return lRet


	/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fRegime     ³ Autor: Kelly Soares        ³ Data ³ 16.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecionar regime do funcionario.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function fRegime(l1Elem,lTipoRet)

Local cTitulo:= STR0042
Local MvPar, MvRetor
Local MvParDef:= ""

Local nX
Local aRegime	:={ "1 - " + STR0041,;  //CLT
					 "2 - " + STR0042 } //Estatutario

l1Elem := If (l1Elem = Nil , .F. , .T.)

DEFAULT lTipoRet := .T.

IF lTipoRet
	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
EndIF

MvParDef := "12"

IF lTipoRet
	
	IF f_Opcoes(@MvPar,cTitulo,aRegime,MvParDef,12,49,l1Elem,1,2)
		&MvRet := mvpar
	EndIF	

EndIF

Return( IF( lTipoRet , .T. , MvParDef ) )


