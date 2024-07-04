//-------------------------------------------------------------------
/*{Protheus.doc}  Rup_CTB( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
Filtro 

@author Simone Mie Sato Kakinoana
   
@version P12
@since   27/03/2015
@return  Nil
@obs

Função exemplo de compatibilização do release incremental. Esta função é relativa ao módulo contabilidade gerencial 
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus 
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA. 
Ex: para o módulo SIGACTB criar a função RUP_CTB   

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA 
*/
//-------------------------------------------------------------------
Function Rup_CTB( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

//o semaforo só será habilitado apartir da 12.1.31
//cMode- Execucao por grupo de empresas
If GetRPORelease() >= "12.1.031" .And. cMode == "1"
	//Correcao da tabela CTF
	CTBAtuCTF(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
EndIf

If  cMode == "1"
	//Atualiza SX9
	CtbAtuSx9()
EndIf

If GetRPORelease() >= "12.1.2210" .And. cMode == "1"
	//Popular o novo campo, CTS_COLUN2 Tipo caracter de 1 com conteudo da CTS_COLUNA
	CTBAtuCTS(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
EndIf

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} CTBAtuCTF
Ajuste da tabela CTF no campo CTF_USADO este campo foi criado posteriormente
e deverá preenchido com 'S' 

@author Totvs

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA 

@version P12.1.30
@since   02/06/2020
*/
//--------------------------------------------------------------------------
Static Function CTBAtuCTF(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
Local aSaveArea	as array

Local cQuery     as Character
Local cAliasCTF  as Character
Local nUpDates   as Numeric
Local cQryUpdate as Character
Local cUpdate    as Character  
Local nMinRec    as Numeric
Local nMaxRec    as Numeric

aSaveArea := GetArea()

DbSelectArea("CTF")
DbSetOrder(1)

If CTF->(FieldPos("CTF_USADO")) > 0

	
	
	cAliasCTF := CriaTrab(,.F.)
	nUpdates  := 20000
	nMinRec := 0
	nMaxRec := 0
	
	cQuery := ""
	cQuery := "Select Isnull( Min(R_E_C_N_O_), 0 ) nMin , Isnull( Max(R_E_C_N_O_), 0 ) nMax FROM "+RetSqlName("CTF")
	cQuery += " Where CTF_USADO = ' ' "
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasCTF)

	nMinRec := (caliasCTF)->(nMin)
	nMaxRec := (caliasCTF)->(nMax)

	/* QUERY DE ATUALIZAÇÃO */ 
	cQryUpdate:= ""
	cQryUpdate := "UpDate "+RetSqlName("CTF")
	cQryUpdate += " SET CTF_USADO = 'S' Where CTF_USADO = ' ' "

	If (cAliasCTF)->( !Eof() .and. nMinRec > 0 )

		Do While nMinRec <= nMaxRec  

			cUpdate := cQryUpdate
			cUpdate += " AND R_E_C_N_O_ >= " + Str(nMinRec            , 10, 0) 
			cUpdate += " AND R_E_C_N_O_ <= " + Str( nMinRec + nUpDates, 10, 0)

			If TcSqlExec( cUpdate ) <> 0
				UserException( RetSqlName(cAliasCTF) + " "+ TCSqlError() )
			Endif
			TCRefresh(RetSqlName("CTF"))

			If nMaxRec > nMinRec + nUpDates 
				nMinRec := nMinRec + nUpDates 
				nMinRec++
			Else
				EXIT
			EndIf

		Enddo

	EndIf
	
	(caliasCTF)->( DBCloseArea() )
	
EndIf

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc}  CtbAtuSx9()
Filtro 

@author TOTVS
   
@version P12
@since   08/09/2020
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Static Function CtbAtuSx9()

Local aArea    	:= GetArea()
Local aAreaSX9 	:= SX9->(GetArea())


DbSelectArea("SX9")
DbSetOrder(2)
//SX9_CDOM + SX9_DOM
If SX9->(DbSeek("CVF" + "CTS")) 
	while SX9->( ! EOF() .And. X9_CDOM=='CVF' .And. X9_DOM=='CTS' )
		RecLock("SX9",.F.)
		SX9->( dbDelete() )
		SX9->( MsUnlock() )
		SX9->( DBSkip() )
	EndDo
EndIF

RestArea(aAreaSX9)
RestArea(aArea)

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} CTBAtuCTS
Atualizar o campo novo criado para 12.1.2210, CTS_COLUN2, com o conteúdo do campo CTS_COLUNA.
CTS_COLUN2 Tipo Character 1
CTS_COMUNA Tipo Numerico 1

@author Totvs

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada Ex: 005 
@param  cLocaliz   - Localização (país). Ex: BRA 

@version P12.1.2210
@since   02/06/2020
*/
//--------------------------------------------------------------------------
Static Function CTBAtuCTS(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
Local aSaveArea	as array
Local cQuery     := ""
Local nUpDates   := 0
Local cQryUpdate := ""
Local cUpdate    := ""
Local nMinRec    := 0
Local nMaxRec    := 0
Local cAliasCTS  

aSaveArea := GetArea()

DbSelectArea("CTS")
DbSetOrder(1)

If CTS->(FieldPos("CTS_COLUN2")) > 0
	
	cAliasCTS := CriaTrab(,.F.)
	nUpdates  := 20000
	nMinRec := 0
	nMaxRec := 0
	
	cQuery := ""
	cQuery := "Select Coalesce( Min(R_E_C_N_O_), 0 ) nMin , Coalesce( Max(R_E_C_N_O_), 0 ) nMax FROM "+RetSqlName("CTS")
	cQuery += " Where CTS_COLUN2 = ' ' "
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasCTS)

	nMinRec := (caliasCTS)->(nMin)
	nMaxRec := (caliasCTS)->(nMax)

	/* QUERY DE ATUALIZAÇÃO */ 
	cQryUpdate:= ""
	cQryUpdate := "UpDate "+RetSqlName("CTS")
	cQryUpdate += " SET CTS_COLUN2 = CAST(CTS_COLUNA as Char(01) ) "
	
	If (caliasCTS)->( !Eof() .and. nMinRec > 0 )

		Do While nMinRec <= nMaxRec  

			cUpdate := cQryUpdate
			cUpdate += " WHERE R_E_C_N_O_ >= " + Str(nMinRec            , 10, 0) 
			cUpdate += " AND R_E_C_N_O_ <= " + Str( nMinRec + nUpDates, 10, 0)

			If TcSqlExec( cUpdate ) <> 0
				UserException( RetSqlName(caliasCTS) + " "+ TCSqlError() )
			Endif
			TCRefresh(RetSqlName("CTS"))

			If nMaxRec > nMinRec + nUpDates 
				nMinRec := nMinRec + nUpDates 
				nMinRec++
			Else
				EXIT
			EndIf

		Enddo

	EndIf
	
	(caliasCTS)->( DBCloseArea() )
	
EndIf

RestArea(aSaveArea)

Return
