#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFACONT--

Rotina criada para carga das tabelas autocontidas do TAF. ( Obsoleto )

@Author	Rodrigo Aguilar
@Since		16/12/2013
@Version	1.0
/*/

//-------------------------------------------------------------------
User Function TAFACONT() 

	MsgAlert( "Este processo deve ser realizado via 'Wizard de Configuração' através do Menu Miscelanea do TAF!" )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} FGeraPath

Função para geração da path .taf (Obsoleto)

@Author	Rodrigo Aguilar
@Since		16/12/2013
@Version	1.0
/*/
//-------------------------------------------------------------------
User Function FGeraPath()

	Local nI        := 0
	Local aItens    := Directory( "Atusx_TAF\autocontidas\*.*" )
	Local aArquivos := {}

	RPCSetType( 3 )
	RPCSetEnv( "T1", "D MG 01",,,"TAF","TAFACONT")

	For nI := 1 to Len( aItens )
		aAdd( aArquivos, "Atusx_TAF\autocontidas\" + aItens[nI,1] )
	Next nI

	MsCompress( aArquivos, "Atusx_TAF\autocontidas\AutoContidas.TAF" )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} FTafAutCon

Realiza a carga nas tabelas autocontidas.

@Param		aEmpFil	-	Array com as empresas / filiais para processamento
			oProcess	-	Objeto de controle do processamento
			cError		-	Variável que armazena o erro que ocorreu ( desenvolver... )

@Author	Rodrigo Aguilar
@Since		24/03/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Function FTafAutCon( aEmpFil, oProcess, cError, lAviso , lJob , cProg, lForce  )

	Local cJobAux    := ""
	Local cErro      := ""
	Local nI         := 0
	Local nLoop      := 0
	Local nThreads   := 1 //GetNewPar( "MV_AUTCMT", 5 )
	Local aJobAux    := {}
	Local aResumo    := {}
	Local aRotinas   := {}
	Local lRet       := .T.
	Local ncount     := 0
	Local nUlt       := 1
	Local aJobau2    := {}
	Local nScan
	Local lAll
	Local lAtualizou := .T.

	Default lJob     := .F.
	Default oProcess := nil
	Default cProg    := ""
	Default lForce   := .F.

	If Empty( cProg )
		nScan 	:= 0
		lAll	:= .T.
	Else
		nScan 	:= 1
		lAll	:= .F.
	EndIf

	If Empty( cProg )
		aRotinas	:=	TAFRotinas( cProg ,nScan, lAll, 4 )
	Else
		aRotinas	:=	{TAFRotinas( cProg ,nScan, lAll, 4 )}
	EndIf


	For nI := 1 to Len( aEmpFil )

		//Inicializa variável global de controle de thread
		cJobAux := StrTran( "cAUTCON_" + aEmpFil[nI,1] + aEmpFil[nI,2], " ", "_" ) + StrZero( nI, 2 )

		//Adiciona o nome do arquivo de job no array aJobAux
		aAdd( aJobAux, { StrZero( nI, 2 ), cJobAux, aEmpFil[nI,1], aEmpFil[nI,2] } )
	Next nI

	nCount :=	Min( Len( aJobAux ), nThreads )

	While nloop <= Len( aJobAux )

		ajobau2:={}
		nLoop += nCount

		For nI:=nUlt to nLoop

			If nI <= Len( aJobAux )

				//Array para gravação do log de execução
				aAdd( aResumo, { {	aJobAux[nI,3] + " - " + AllTrim( aJobAux[nI,4] ) },;
										{},;
										0 } )

				If !lJob
					oProcess:Set2Progress( Len( aRotinas )/10 )
				EndIf

				FAtuTabTAF( aJobAux[ nI ] , @aResumo , aRotinas , oProcess, lJob )

				Sleep( 2500 )
				aadd(ajobau2,aJobAux[nI])

			EndIf

		Next nI

		nUlt :=	nI

	EndDo

	If IsBlind()

		TAFConOut( "Realizando a atualização do TAFGERCTL" ,2 ,.F. ,"AUTCONT" )
		lAtualizou := FAtuTabSD( 'TAFGERCTL', @cErro )

		If lAtualizou
			TAFConOut( "Realizando a atualização do TAFST2" ,2 ,.F. ,"AUTCONT" )
			lAtualizou := FAtuTabSD( 'TAFST2', @cErro )
		EndIf
		
		If lAtualizou
			TAFConOut( "Realizando a atualização do TAFXERP" ,2 ,.F. ,"AUTCONT" )
			lAtualizou := FAtuTabSD( "TAFXERP", @cErro )
		EndIf
	Else
		If lAviso
			Aviso( "Resumo do processamento", cErro, { "OK" }, 3 )
		EndIf
	EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFShowLog

Função para geração da tela de log do processamento. ( Obsoleto )

@Param		aResumo	-	Array com as informações a serem impressas
			lLogErro	-	Indica se será gerado o log de falha na carga

@Author	Rodrigo Aguilar
@Since		18/12/2013
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFShowLog( aResumo, lLogErro )

	Local oDlgLog	:=	Nil
	Local oMemo		:=	Nil
	Local cTxt		:=	""
	Local cFileLog	:=	""
	Local cTxtIntro	:=	""
	Local cFile		:=	""
	Local cMask		:=	"Arquivos Texto (*.TXT) |*.txt|"
	Local nX		:=	0
	Local nY		:=	0

	If !lLogErro

		For nX := 1 To Len( aResumo )

			cTxt += Replicate( '=', 100 ) + Chr( 13 ) + Chr( 10 )
			cTxt += "Atualização: Empresa " + aResumo[ nX ][ 1 ][ 1 ] + Chr( 13 ) + Chr( 10 )
			cTxt += Chr(13) + Chr(10)

			cTxt += "Tabelas Atualizadas no processamento:" + Chr( 13 ) + Chr( 10 )
			For nY := 1 To Len( aResumo[nX][2] )
				If aResumo[ nX ][ 2 ][nY][2] == 1
					cTxt += Iif( !Empty( aResumo[ nX ][ 2 ][ nY ][1] ), AllTrim( aResumo[ nX ][ 2 ][ nY ][1] ) + Chr( 13 ) + Chr( 10 ), "" )
				EndIf
			Next

			cTxt += Chr( 13 ) + Chr( 10 )
			cTxt += "Tabelas não Atualizadas no processamento:" + Chr( 13 ) + Chr( 10 )
			For nY := 1 To Len( aResumo[nX][2] )
				If aResumo[ nX ][ 2 ][nY][2] == 2
					cTxt += Iif( !Empty( aResumo[ nX ][ 2 ][ nY ][1] ),AllTrim( aResumo[ nX ][ 2 ][ nY ][1] ) + Chr( 13 ) + Chr( 10 ), "" )
				EndIf
			Next

			cTxt += Chr( 13 ) + Chr( 10 )

		Next nX

	Else

		cTxt += Replicate( '=', 100 ) + Chr( 13 ) + Chr( 10 )
		cTxt += aResumo[ 1 ][ 1 ][ 1 ] + Chr( 13 ) + Chr( 10 )

	EndIf

	cTxt += Replicate( '=', 100 ) + Chr( 13 ) + Chr( 10 )

	If !Empty( cTxt )

		cFileLog := MemoWrite( Criatrab( , .F. ) + ".Log", cTxt )

		cTxtIntro += "<table width='100%' border=2 cellpadding='15' cellspacing='5'>"
		cTxtIntro += "<tr>"
		cTxtIntro += "<td align='center'>"
		cTxtIntro += "<font face='Tahoma' size='+1'><b>Log de Atualização das tabelas AutoContidas do TAF</b></font>"
		cTxtIntro += "</td>"
		cTxtIntro += "</tr>"
		cTxtIntro += "<tr>"
		cTxtIntro += "<td>teste"
		cTxtIntro += "<br><br><br><br><br><br><br><br><br>"
		cTxtIntro += "<br><br><br><br><br><br><br><br><br>"
		cTxtIntro += "</td>"
		cTxtIntro += "</tr>"
		cTxtIntro += "</table>"

		Define MsDialog oDlgLog Title "Log do Processamento" From 00,00 To 500,700 Pixel

			TSay():New( 005, 005, {|| cTxtIntro }, oDlgLog , , , , , , .T., , , 340, 200, , , , .T., , .T. )
			@045,015 Get oMemo Var cTxt Memo Size 320,150 Of oDlgLog Pixel ReadOnly
			TButton():New( 220, 180, '&Salvar...', oDlgLog, {|| cFile := cGetFile( cMask, "" ), If( cFile = "", .T., MemoWrite( cFile, cTxt ) ) }, 075, 015, , , ,.T., , , , , , )
			TButton():New( 220, 270, '&Ok', oDlgLog,{|| oDlgLog:End() }, 075, 015, , , , .T., , , , , , )

		Activate MsDialog oDlgLog Centered

	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCrteTab

Função para criação da tabela no banco caso a mesma não exista, é
necessária a criação para que não se utilize o SXSBRA no momento de
criar a tabela, pois no caso de cliente que utilizam release anterior
a 11.80 as tabelas não existem no arquivo.

@Param		cAlias		-	Tabela a ser criada
			cEmpAnt	-	Empresa onde a tabela será criada

@Author	Rodrigo Aguilar
@Since		05/03/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFCrteTab( cAlias, cEmpAnt )

	Local cArq		:= cAlias + cEmpAnt + "0"
	Local aCmp		:= {}
	Local lExistDic	:= .F.

	SX3->( DBSetOrder( 1 ) )
	SX3->( DBGoTop() )

	SIX->( DBSetOrder( 1 ) )
	SIX->( DBGoTop() )

	If SX3->( MsSeek( cAlias ) )

		While SX3->( !Eof() ) .and. SX3->X3_ARQUIVO == cAlias

			If SX3->X3_CONTEXT != 'V' 
				aAdd( aCmp, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL } )
			EndIf	

			SX3->( DBSkip() )

		EndDo
		
		If Len( aCmp ) > 0
			lExistDic := .T.

			//Prepara o banco para criação da tabela
			TcCommit( 5, .T. )

			TcInternal( 30 , "AUTORECNO" )
			TcInternal( 25 , "CLOB" )

			TAFConOut( __CRDD ,2 ,.F. ,"AUTCONT" )

			DBCreate( cArq, aCmp, __cRdd )

			//Finaliza o banco após criação da tabela
			TcCommit( 5, .F. )

			TcInternal( 30 , "OFF" )
			TcInternal( 25 , "OFF" )

			DBSelectArea( cAlias )
			( cAlias )->( DBCloseArea() )

			TAFConOut( "Criando Tabela " + cAlias ,2 ,.F. ,"AUTCONT" )
			
		EndIf

	EndIf

Return( lExistDic )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuTabTAF

Função para criação da tabela no banco caso a mesma não exista, é
necessária a criação para que não se utilize o SXSBRA no momento de
criar a tabela, pois no caso de cliente que utilizam release anterior
a 11.80 as tabelas não existem no arquivo.

@Param		aJobAux	-	Array com informações sobre os jobs
			aResumo	-	Resumo de processamento
			aRotinas	-	Array com informações das autocontidas

@Return

@Author	Rodrigo Aguilar
@Since		05/03/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Function FAtuTabTAF( aJobAux, aResumo, aRotinas , oProcess, lJob )

	Local cNThread		:= ""
	Local cJobAux		:= ""
	Local cEmp			:= ""
	Local cFil			:= ""
	Local cAlias		:= ""
	Local cIDReg		:= ""
	Local cField		:= ""
	Local nTamFil		:= 0
	Local cFilReg 		:= ""
	Local nI			:= 0
	Local nJ			:= 0
	Local nK			:= 0
	Local nID			:= 0
	Local nField		:= 0
	Local nVerNew		:= FTafVAutoC()
	Local aContidas		:= {}
	Local aStruct		:= {}
	Local aField		:= {}
	Local aRegs			:= {}
	Local lFindTabDc	:= .T.
	Local lGrvReg		:= .F.
	Local oError 		:= ErrorBlock( { |Obj| ACErrorTaf( Obj , cJobAux ) } )
	Local lAutomato		:= Iif(IsBlind(),.T.,.F.)
	Local cChvNF		:= ""
	Local nVerT2U   	:= 0
	Local nCont			:= 0
	Local nIDItem		:= 0
	Local oBulk 		:= nil
	Local lCanUseBulk 	:= .F.
	Local aRegistro		:= {}
	Local cMsgError		:= ""
	Local aStruct3 		:= {}
	Local nAltCon  		:= 0
	Local xRegistro		:= Nil

	Private nVerEmp		:=	0
	Private nVerAtu		:=	0

	cNThread	:=	aJobAux[1]
	cJobAux		:=	aJobAux[2]
	cEmp		:=	aJobAux[3]
	cFil		:=	aJobAux[4]

	cChvNF		:=	"C20|C21|C22|C23|C24|C25|C26|C27|C28|C29|C2A|C2B|C2C|C2D|C2E|C2F|C2G|C2H|C2I|C30|C31|C32|C33|C34|C35|C36|C37|C38|C39|C3A|C3F|C3G|C3H|C3I|C6W|C7B|CAI|CH1|CH2|"

	lCanUseBulk := TCGetBuild() >= "20181212" .And. FindClass("FwBulk") .And. FwBulk():CanBulk()

	If lCanUseBulk
		oBulk := FwBulk():New()
	EndIf

	TafConout( "TAF - Thread( " + cNThread + " ) - Processamento autocontidas Empresa/Filial: " + cEmp + "/" + cFil )
	TcInternal( 1, "TAF - Thread( " + cNThread + " ) - Processamento autocontidas Empresa/Filial: " + cEmp + "/" + cFil )

	//Obtenho o parâmetro após definição do ambiente para pegar da empresa correta
	nVerEmp := GetNewPar( "MV_VAUTCON", 1000 ) //Parâmetro que indica qual a versão atual da base do cliente

	Begin Sequence
		For nI := 1 to Len( aRotinas )
			

			// -----------------------------------------------------------------------------------------------------------------------------
			//Este trecho onde é feita a chamada via StaticCall da FAtuCont foi transferido para depois da validação TCCanOpen/TAFCrteTab abaixo.
			//se faz necessário para evitar erros dentro das funções FAtuCont de cada tabela autocontida, quando utilizadas funções como
			//dbSelectArea, TAFColumnPos e TAFAlsInDic. Essa funções tentam abrir as tabelas mas pelo fato de não terem passado ainda
			//pelo TCCanOpen/TAFCrteTab as tabelas podem não existir, causando error.log na execução.
			// -----------------------------------------------------------------------------------------------------------------------------
			cAlias := aRotinas[nI,3]

			If cAlias == "CH8" .And. TCCanOpen( RetSqlName("CH8") ) .And. FindFunction("CH8Unique")
				CH8Unique(nVerEmp)
			EndIf

			//Verifico se a tabela existe no banco, caso contrario eu as crio
			If TCCanOpen( cAlias + cEmpAnt + "0" )
				lFindTabDc := .T.
			Else
				lFindTabDc := TAFCrteTab( cAlias, cEmpAnt )
			EndIf

			aContidas := &( "StaticCall( " + aRotinas[nI,1] + ", FAtuCont, nVerEmp, @nVerAtu )" )
			If !CheckT2U(nVerAtu, cAlias, @nVerT2U,aRotinas[nI,1])
				aContidas := &( "StaticCall( " + aRotinas[nI,1] + ", FAtuCont, nVerT2U, @nVerAtu )" )
			EndIf

			If lFindTabDc .and. !Empty( aContidas ) .and. !( lJob .and. cAlias $ "C1A|CML|CH8|T34|T37|T3E|T1T|T2D|T0I|T0K|T0L|T0V|LE7|LEE|CWZ|T59|T5A|T5B|T5C|T5D|T5E|T5O|T5F|T54|T55|T2T|T71|T82|T81|T83|T84|T85|T9A|T9B|V1P|V2K|V2L|V2M|V26|V27|V28|V29" )

				If nVerAtu <= nVerEmp .And. CheckT2U(nVerAtu, cAlias, @nVerT2U,aRotinas[nI,1])
					//Alimentando log de execução
					If !Empty(FwX2Nome(cAlias))
						aAdd( aResumo[Len( aResumo ),2], { cAlias + " - " + FwX2Nome(cAlias), 2 } )
					EndIf
					Loop
				EndIf

				// Tratamento para autocontidas com mais de uma tabela
				For nCont := 1 To Len(aContidas)
					aStruct :=	aContidas[nCont,1]
					aRegs 	:=	aContidas[nCont,2]
					cAlias	:= SubStr(aContidas[nCont,1,1],1,3)
					
					if lCanUseBulk
						aStruct3 := Estruct(cAlias,aStruct)

						oBulk:SetTable( RetSqlName(cAlias) )
						oBulk:SetFields(aStruct3)
					endif
					//Busco o ID do arquivo que está sendo importado para verificar se trata de uma inclusão ou alteração
					nID := aScan( aStruct, { |x| x == cAlias + "_ID" } )
					// verifica se na estrutura possui o campo fake ALTCON contendo a versão 
					nAltCon := aScan(aStruct, {|x| x = cAlias+"_ALTCON" })

					If nID > 0 //Busca não pode falhar, afinal o campo de ID é obrigatório em todas as tabelas do TAF

						//Verifico se a tabela autocontida a ser carregada é uma das informadas abaixo
						//Em caso positivo, é realizado um delete nos seus registros
						TAFRegDel(cAlias,nVerEmp)

						//Alimentando log de execução
						If !Empty(FwX2Nome(cAlias))
							aAdd( aResumo[Len( aResumo ),2], { cAlias + " - " + FwX2Nome(cAlias), 1 } )
						EndIf

						//Begin Transaction

							nIndOrd	:=	TAFGetIdIndex(cAlias,Iif(cAlias$cChvNF,"_CHVNF",Nil))
							If nIndOrd>0
								(cAlias)->(dbSetOrder(nIndOrd))
								TAFConOut( "[Thread: " + cNThread + " - Emp/Fil: " + cEmp + "/" + cFil + "] - Inicio carga da tabela: " + cAlias + " Ord: " + (cAlias)->(IndexKey()) + ' ' + Time() )
								(cAlias)->( DbGoTop() )
								// comando dbseek para atualizar o dbaccess entender que os registros foram derrotados
								(cAlias)->(DBSeek(xFilial(cAlias)))
								lEof := (cAlias)->(Eof())
								
								For nJ := 1 to Len( aRegs )
									cIDReg := aRegs[nJ,nID]
									If cAlias $ 'V5P|V70' 
										nIDItem 	:= aScan( aStruct, { |x| x == &("'" + cAlias + "_ITEM'" ) } ) 
										cIDReg 		+= IIf(nIDItem > 0,aRegs[nJ,nIDItem],'')
									EndIf

									If cAlias $ 'V5Q|V71'
										nIDItem 	:= aScan( aStruct, { |x| x == &("'" + cAlias + "_ITEMTB'" ) } )
										cIDReg 		+= IIf(nIDItem > 0,aRegs[nJ,nIDItem],'')

										nIDItem 	:= aScan( aStruct, { |x| x == &("'" + cAlias + "_ITEM'" ) } )
										cIDReg 		+= IIf(nIDItem > 0,aRegs[nJ,nIDItem],'')
									EndIf

									lAltId := .T.
									
									//Guardo o ID do registro
									If lEof .And. lCanUseBulk
										aRegistro 	:= {}	

										For nK := 1 to Len(aStruct3)
											nField 		:= GetSX3Cache(aStruct3[nK][1], "X3_TAMANHO")
											xRegistro 	:= aRegs[nJ][nK]
											
											If aStruct3[nK][2] $ "C"
												xRegistro := Substr(xRegistro, 1, aStruct3[nK][3]) 

												Aadd(aRegistro, IIf(Empty(xRegistro), Space(nField), xRegistro))
											ElseIf aStruct3[nK][2] $ "N"
												If Valtype(xRegistro) == "C"
													Aadd(aRegistro, IIf(Empty(xRegistro), 0, Val(xRegistro)))
												Else
													Aadd(aRegistro, xRegistro)	
												EndIf
											Else
												Aadd(aRegistro, IIf(Empty(xRegistro), Space(nField), xRegistro))
											EndIf
										Next nK

										If len(aRegistro)  == Len(aStruct3)
											oBulk:AddData( aRegistro )
										EndIf
									Else
										lNewReg := AltCon(aRegs[nj],nAltCon,nVerEmp)
										If lNewReg
											lGrvReg	:= TAFRegSeek(cAlias,aRegs[nj],@cIDReg, @lAltID)
										EndIf
										If lNewReg .and. Reclock( cAlias, lGrvReg )
											
											// Não altera _STATUS que já estiver na Base do Cliente
											If cAlias $ "V70" .And. !lGrvReg .And. ( aScan( aStruct, { |x| x == cAlias + "_STATUS" } ) > 0 ) 
												aDel( aStruct, aScan( aStruct, { |x| x == cAlias + "_STATUS" } ))
												aSize( aStruct, len(aStruct) - 1)
											EndIf

											For nK := 1 to Len( aStruct )
												if ( nPos := ( cAlias )->( FieldPos( aStruct[nK] ) ) ) > 0
													cField := SubStr( aStruct[nK], At( "_", aStruct[nK] ) )

													//Tratamento para Filial
													If cField == "_FILIAL"
														nTamFil	:= GetSX3Cache(aStruct[nK], "X3_TAMANHO")
														cFilReg := xFilial( cAlias )

														( cAlias )->( FieldPut( nPos, IIf(Empty(cFilReg), Space(nTamFil), cFilReg) ) )
													//Tratamento para ID
													ElseIf cField == "_ID"
														nIDReg := GetSX3Cache(aStruct[nK], "X3_TAMANHO")

														If cAlias $ "C1A|C3Z|C6U|C8Z|T71|C0Y|C8A|CHY|CUF|CMM|C0A"
															// Verifica se a tabela estava vazia
															// Se vazia não incrementa o ID
															If lGrvReg .And. !lEof .And. lAltId
																cIDReg := &( "StaticCall( " + aRotinas[nI,1] + ", TAFAGetId )" )
																( cAlias )->( FieldPut( nPos, IIf(Empty(cIDReg), Space(nIDReg), cIDReg) ) )
															Else
																( cAlias )->( FieldPut( nPos, IIf(Empty(cIDReg), Space(nIDReg), cIDReg) ) )
															EndIf

														Else
															( cAlias )->( FieldPut( nPos, IIf(Empty(cIDReg), Space(nIDReg), cIDReg) ) )
														Endif
													//Genérico
													Else
														aField 		:= TamSX3( aStruct[nK] )
														xRegistro 	:= aRegs[nJ,nK]

														If aField[3] == "N"
															( cAlias )->( FieldPut( nPos, IIf(Empty(xRegistro), 0, Val(xRegistro)) ) )
														Elseif aField[3] == "M"
															( cAlias )->( FieldPut( nPos, IIf(Empty(xRegistro), Space(aField[1]), xRegistro) ) )
														Else
															( cAlias )->( FieldPut( nPos, PadR( xRegistro, aField[1] ) ) )
														EndIf
													EndIf
												EndIf
											Next nK

											( cAlias )->( MsUnLock() )
											( cAlias )->( DBCommit() )
										EndIf
									EndIf
								Next nJ
								TAFConOut( "[Thread: " + cNThread + " - Emp/Fil: " + cEmp + "/" + cFil + "] - Fim carga da tabela: " + cAlias  + ' ' + Time())
							Else
								TAFConOut( "[Thread: " + cNThread + " - Emp/Fil: " + cEmp + "/" + cFil + "] - Carga da tabela ["+ cAlias+"] não efetuada. Indice '_ID/CHVNF' não localizado.")
							Endif

						//End Transaction

					EndIf

					( cAlias )->( DBCloseArea() )

					if lCanUseBulk
						oBulk:Flush()
						cMsgError := oBulk:GetError()
						If !Empty(cMsgError)
							TAFConOut("[Thread: " + cNThread + " - Emp/Fil: " + cEmp + "/" + cFil + "] - Carga da tabela ["+ cAlias+"] com erros no bulk: " + cMsgError )
						EndIf
						oBulk:Close()
						oBulk:Reset()
					endif
				Next nCont 
			Else
				aAdd( aResumo[Len( aResumo ),2],{ cAlias + " - Estrutura de Dicionário Inválida", 2 } )
			EndIf

			If lFindTabDc
				//Gravação da tabela referência para todas as autocontidas
				If TAFAlsInDic( "T2U" )
					T099GrvTbl( aRotinas[nI,3], aRotinas[nI,1], nVerAtu )
				EndIf
			EndIf

			//STATUS 4 - Processamento em andamento
			PutGlbValue( cJobAux, "4" )
			GlbUnLock()

			If !lAutomato .and. nI%10 == 0
				oProcess:Inc2Progress( "Processando..." )
			EndIf

		Next nI

		If lCanUseBulk
			oBulk:Destroy()
			oBulk := nil
		EndIf

		//Ao final do processamento eu gravo a versão atual do sistema após as atualizações
		PutMv("MV_VAUTCON",AllTrim( Str( nVerNew ) ))

		//STATUS 3 - Processamento efetuado com sucesso
		PutGlbValue( cJobAux, "3" )
		GlbUnLock()

	Recover

		PutGlbValue( cJobAux, "9" )
		GlbUnLock()

	End Sequence

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRegDel

Função criada para deletar os registros de autocontidas pré determi-
nadas

@Param	cAlias	-	Tabela a ser apagada
@param  nVerEmp - versão da autocontida no ambiente 

@Return	Nil		-	Caso o registro não exista (.T.), se existir (.F.)

@Author	    Veronica de Almeida 
@Since		07/09/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFRegDel(cAlias as character, nVerEmp as numeric)

	Local cQuery        as character
	Local cTableName    as character
	Local cAliasAbertas as character
	Local cAliasDel     as character
	Local lDel          as logical

	Default cAlias		:= ""
	Default nVerEmp		:= 0

	cQuery        	:= ""
	cTableName    	:= ""
	cAliasAbertas	:= "C0A|C1A|C3Z|C6U|C8Z|C0Y|T71|C8A|CHY|CUF|CMM|C9V|V6Z|V70|V71"
	cAliasDel     	:= "C86|C87|C88|C8C|C8E|C8F|C8G|C8H|C8I|C8J|C8K|C8L|C8M|C8N|C8O|" +;
						"C8P|C94|C95|C96|C97|C98|CAX|CAJ|CAR|CAL|CHA|T2D|C8D|CHY|" +;
						"T3E|C5V|V2K|C8U|C89|V5O|V5P|V5Q|V3F|C8Z"
	lDel          	:= .F.

	If Empty(nVerEmp) 
		If !(cAlias $ cAliasAbertas)
			lDel		:= .T.
		EndIf
	EndIf

	If cAlias $ cAliasDel .Or. lDel
		cTableName	:= RetSqlName(cAlias)
		cQuery 		:= "UPDATE " + cTableName + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE D_E_L_E_T_ = ' ' OR R_E_C_D_E_L_ = 0"
		
		IIf(TCSQLExec(cQuery) < 0, TAFConOut("TAF - Empresa/Filial: " + cEmp + "/" + cFil + " Erro UPDATE: "+ TCSQLError()), Nil)
	ElseIf cAlias == "C3Z" .and. DToS( GetAPOInfo( "TAFA163.PRW")[4] ) >= "20170908"
 
		DBSelectArea( "C3Z" )
		C3Z->( DBSetOrder( 3 ) ) //C3Z_FILIAL + C3Z_ID
		If C3Z->( MsSeek( xFilial( "C3Z" ) + "000100" ) )
			If Reclock( "C3Z", .F. )
				C3Z->( DBDelete() )
				C3Z->( MsUnlock() )
			EndIf
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRegSeek

Função criada para posicionar no registro a ser alterado

Caso o registro não seja encontrado,
@Return	lInclui		-	Caso o registro não exista (.T.), se existir (.F.)

@Author	Veronica de Almeida Toledo
@Since		07/09/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFRegSeek( cAlias, aRegistro, cIDReg, lAltID )

	Local cCODReg     := ""
	Local cEXNCM      := ""
	Local cValida     := ""
	Local lInclui
	Local nIndTab     := 1

	Default cAlias    := ""
	Default aRegistro := {}
	Default cIDReg    := ""
	Default lAltID    := .T.

	If cAlias $ 'C1A|C3Z|C6U|C8Z|T71|C0Y|C8A|CHY|CUF|CMM|C0A|V70|V71'

		If cAlias  == 'C1A'

			nIndTab := 3 //C1A_FILIAL+C1A_CODIGO+DTOS(C1A_VALIDA)
			cCODReg	:= PadR(aRegistro[4],TamSX3('C1A_CODIGO')[1],'')
			cValida	:= PadR(aRegistro[6],TamSX3('C1A_VALIDA')[1],'')
			lInclui := Empty( Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,'C1A_CODIGO') )

			If !lInclui

				cIDReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,"C1A_ID" )
				lAltId := .F.

			ElseIf !Empty(cValida)

				lInclui	:= !(cAlias)->(MsSeek(xFilial(cAlias) + cCODReg + Space(8),.F.))

				If !lInclui
					cIdReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + Space(8),"C1A_ID" )
					lAltId := .F.
				EndIf

			EndIf

		ElseIf cAlias  == 'C3Z'

			nIndTab := 1 //C3Z_FILIAL+C3Z_CODIGO+DTOS(C3Z_VALIDA)
			cCODReg	:= PadR(aRegistro[3],TamSX3('C3Z_CODIGO')[1],'')
			cValida	:= PadR(aRegistro[5],TamSX3('C3Z_VALIDA')[1],'')

			lInclui := Empty( Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,'C3Z_CODIGO') )
			If !lInclui
				cIDReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,"C3Z_ID" )
				lAltId := .F.
			EndIf

		ElseIf cAlias  == 'C6U' 

			nIndTab := 1//C6U_FILIAL+C6U_CODIGO+DTOS(C6U_VALIDA)
			cCODReg	:= PadR(aRegistro[3],TamSX3('C6U_CODIGO')[1],'')
			cValida	:= PadR(aRegistro[5],TamSX3('C6U_VALIDA')[1],'')

			lInclui := Empty( Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,'C6U_CODIGO') )
			If !lInclui
				cIDReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,"C6U_ID" )
				lAltId := .F.
			EndIf

		ElseIf cAlias == "C8Z"

			nIndTab := 2//C8Z_FILIAL+C8Z_CODIGO+DTOS(C8Z_VALIDA)
			cCODReg := PadR( aRegistro[3], TamSX3( "C8Z_CODIGO" )[1], "" )
			cValida := PadR( aRegistro[5], TamSX3( "C8Z_VALIDA" )[1], "" )

			lInclui := Empty( Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,'C8Z_CODIGO') )
			If !lInclui
				cIDReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,"C8Z_ID" )
				lAltId := .F.
			EndIf

		ElseIf cAlias == "T71"

			nIndTab := 1//T71_FILIAL+T71_CODIGO+DTOS(T71_VALIDA)
			cCODReg := PadR( aRegistro[3], TamSX3( "T71_CODIGO" )[1], "" )
			cValida := PadR( aRegistro[6], TamSX3( "T71_VALIDA" )[1], "" )

			lInclui := Empty( Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,'T71_CODIGO') )
			If !lInclui
				cIDReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,"T71_ID" )
				lAltId := .F.
			EndIf

		ElseIf cAlias == "C0Y"

			nIndTab := 1//C0Y_FILIAL+C0Y_CODIGO
			cCODReg := PadR( aRegistro[3], TamSX3( "C0Y_CODIGO" )[1], "" )
			lInclui := Empty( Posicione(cAlias,nIndTab, xFilial( cAlias ) + cCODReg, "C0Y_CODIGO" ) )
			If !lInclui
				cIDReg := Posicione(cAlias,nIndTab, xFilial( cAlias ) + cCODReg, "C0Y_ID" )
				lAltId := .F.
			EndIf

		ElseIf cAlias == "C8A"

			nIndTab := 2 //C8A_FILIAL+C8A_CDFPAS+C8A_CODTER+DTOS(C8A_VALIDA)
			cCODId := PadR( aRegistro[2], TamSX3( "C8A_ID" )[1], "" )
			cCODReg := PadR( aRegistro[3], TamSX3( "C8A_CDFPAS" )[1], "" )
			cCodTer := PadR( aRegistro[5], TamSX3( "C8A_CODTER" )[1], "" )
			cValida := PadR( aRegistro[7], TamSX3( "C8A_VALIDA" )[1], "" )
			cAliq	:= PadR( aRegistro[6], TamSX3( "C8A_ALIQ" )[1], "" )
			
			( cAlias )->(DbSetOrder(1))
			lHasId := ( cAlias )->( DbSeek( xFilial( cAlias ) + cCODId ) )

			// Procura o ID e se existe, sobrescreve com a informação do conteudo padrão
			If !lHasId

				( cAlias )->(DbSetOrder(nIndTab))
				lInclui := !( cAlias )->( DbSeek( xFilial( cAlias ) + cCODReg +cCodTer + cValida ) )

				If !lInclui

					nRecC8A := (cAlias)->(Recno())
					// Se encontra, verifico o ID correto pois o campo C8A_CDFPAS+C8A_CODTER pode ter mais de uma ocorrencia
					lContinua := .T.

					While cCODReg == C8A->C8A_CDFPAS .And. ;
						cCodTer == C8A->C8A_CODTER .And. ;
						cValida == Dtos(C8A->C8A_VALIDA) .And. ;
						(cAlias)->(!Eof()) .And. lContinua
						If Val( cAliq)  == C8A->C8A_ALIQ
							cIDReg := C8A->C8A_ID
							nRecC8A := (cAlias)->(Recno())
							lContinua := .F.
						EndIf
						(cAlias)->(DbSkip())
					EndDo

					( cAlias )->(DbGoTo( nRecC8A ))
					If lContinua // Se não encontrou o registro com a mesma aliquota, inclui
						lInclui := .T.
					EndIf

					lAltId := .F.

				Else
					lAltId := .F.
				EndIf

			Else
				lAltId := .F.
				lInclui:= .F.
			EndIf

		ElseIf cAlias == "CHY"

			nIndTab := 1//CHY_FILIAL+CHY_CODIGO+CHY_OPERAC+CHY_IDUF
			cCODReg := PadR( aRegistro[3], TamSX3( "CHY_CODIGO" )[1], "" )

			lInclui := Empty( Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg,'CHY_CODIGO') )
			If !lInclui
				cIDReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg, "CHY_ID" )
				lAltId := .F.
			EndIf

		ElseIf cAlias == "CUF"

			nIndTab := 2//CUF_FILIAL+CUF_CODIGO+DTOS(CUF_VALIDA)
			cCODReg := PadR( aRegistro[5], TamSX3( "CUF_CODIGO" )[1], "" )
			cValida := PadR( aRegistro[7], TamSX3( "CUF_VALIDA" )[1], "" )

			lInclui := Empty( Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,'CUF_CODIGO') )
			If !lInclui
				cIDReg := Posicione(cAlias,nIndTab,xFilial(cAlias) + cCODReg + cValida,"CUF_ID" )
				lAltId := .F.
			EndIf

		ElseIf cAlias == "CMM"

			nIndTab := 2 //CMM_FILIAL+CMM_CODIGO+DTOS(CMM_VALIDA)
			cCODReg := PadR( aRegistro[3], TamSX3( "CMM_CODIGO" )[1], "" )
			cValida := PadR( aRegistro[5], TamSX3( "CMM_VALIDA" )[1], "" )

			lInclui := Empty( Posicione( cAlias, nIndTab, xFilial( cAlias ) + cCODReg + cValida, "CMM_CODIGO" ) )

			If !lInclui
				cIDReg := Posicione( cAlias, nIndTab, xFilial( cAlias ) + cCODReg + cValida, "CMM_ID" )
				lAltID := .F.
			EndIf

		ElseIf cAlias == "C0A"

			nIndTab := 1 // C0A_FILIAL + C0A_CODIGO + C0A_EXNCM + C0A_VALIDA
			cCODReg := Padr( aRegistro[3], TamSX3( "C0A_CODIGO" )[1], "" )
			cEXNCM  := Padr( aRegistro[4], TamSX3( "C0A_EXNCM"  )[1], "" )
			cValida	:= PadR( aRegistro[7], TamSX3( "C0A_VALIDA" )[1], "" )
			
			lInclui := Empty( Posicione( cAlias, nIndTab, xFilial( cAlias ) + cCODReg + cEXNCM + cValida, "C0A_CODIGO" ) )
			
			If !lInclui
			
				cIDReg := C0A->C0A_ID
				lAltId := .F.
				
			ElseIf !Empty( cValida )
				
				If ( cAlias )->( MsSeek( xFilial( cAlias ) + cCODReg + cEXNCM + Space( 8 ) ) )
				
					cIdReg  := C0A->C0A_ID
					lAltId  := .F.
					lInclui := .F.
					
				Endif
			EndIf

		ElseIf cAlias == "V70"
			nIndTab := 1 //V70_FILIAL+V70_ID+V70_ITEM
			cCODReg := PadR( aRegistro[2], TamSX3( "V70_ID" )[1], "" ) + PadR( aRegistro[3], TamSX3( "V70_ITEM" )[1], "" )

			lInclui := Empty( Posicione( cAlias, nIndTab, xFilial( cAlias ) + cCODReg, "V70_ID" ) )

			If !lInclui
				cIDReg := cCODReg
				lAltID := .F.
			EndIf

		ElseIf cAlias == "V71"
			nIndTab := 1 //V71_FILIAL+V71_ID+V71_ITEMTB+V71_ITEM
			cCODReg := PadR( aRegistro[2], TamSX3( "V71_ID" )[1], "" ) + PadR( aRegistro[3], TamSX3( "V71_ITEMTB" )[1], "" ) + PadR( aRegistro[4], TamSX3( "V71_ITEM" )[1], "" )

			lInclui := Empty( Posicione( cAlias, nIndTab, xFilial( cAlias ) + cCODReg, "V71_ID" ) )

			If !lInclui
				cIDReg := cCODReg
				lAltID := .F.
			EndIf

		EndIf

		/*------------------------------------------------------------------------------
		Caso não encontra o registro, verifica se trata-se de uma inutilização
		e procura sem a data de validade.
		É imprescindível que a matriz de dados contenha os registros invalidados
		(data de validade preenchida) antes dos registros válidos com o mesmo código
		------------------------------------------------------------------------------*/
		If lInclui .And. !Empty(cValida)
			lInclui	:= !(cAlias)->(MsSeek(xFilial(cAlias) + cCODReg + Space(8),.F.))
		EndIf
	Else
		lInclui	:=	!(cAlias)->(MsSeek(xFilial(cAlias)+cIDReg))
	EndIf

Return lInclui

//-------------------------------------------------------------------
/*/{Protheus.doc} FTafVAutoC

Função criada para controle da versão das auto-contidas

Sempre que for alterado alguma tabela auto-contida, além de alterar a versão no fonte responsável pelo cadastro
(Exemplo, modelo de documento fiscal TAFA001 ),  deve-se alterar essa rotina para que possamos saber qual a última
versão de tabela auto-contida que foi utilizada no TFS

@Return	nVerAutCon		-	Versão mais atual das tabelas auto-contidas

@Author	Rodrigo Aguilar
@Since		07/04/2016
@Version	1.0
/*/ 
//-------------------------------------------------------------------
Function FTafVAutoC()

	Local nVerAutCon as numeric
	
	nVerAutCon := 1032.10

Return nVerAutCon

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCheckAC

Função criada para que seja selecionado os cadastros de auto-contida que deseja atualizar


@Author	Rodrigo Aguilar
@Since		16/11/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFCheckAC()

//descontinuada

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ACErrorTaf

Função chamada a partir de um errorblock para interromper o processo de autocontidas
quando ocorrer algum erro durante o processamento.


@Author	Luccas Curcio
@Since		16/11/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
function ACErrorTaf( Obj , cJobAux ,lAutomato )

	Default lAutomato := .f.

	PutGlbValue( cJobAux, "9" )
	GlbUnLock()

	TAFConout( 'AC - Mensagem de Erro: ' + Chr(10)+ Obj:Description,3,.T.,"AUTCONT")

	If !lAutomato ; KillApp(.T.); EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFUnique
Alterar chave unica da tabela, sem precisar dropar.

@param cTable - Tabela em questão.
@param cChave - Nova Chave

@author Caique
@since 25/07/2018
@version P12
/*/
//-------------------------------------------------------------------

Function TAFUnique(cTable,cChave)

	Local lRet:= .F.

	IF Select("__TRB__") > 0
		dbSelectArea("__TRB__")
		dbCloseArea()
	Endif

	USE &cTable ALIAS "__TRB__" Exclusive New Via 'TOPCONN'

	lIntransaction := .f.

	IF !NetErr() .and. ( TCUNIQUE(cTable,"") == 0 )
		TAFConout("Sucesso: "+cTable+" - Chave unica deletada",2,.T.,"AUTCONT")
	else
		TAFConout("Error: "+cTable+"- Ao deletar chave ",3,.T.,"AUTCONT")
	EndIf

	IF !NetErr() .and. ( TCUNIQUE(cTable,cChave) == 0 )
		TAFconout("Sucesso: "+cTable+" - Chave unica criada : "+cChave,2,.T.,"AUTCONT")
		lRet:= .T.
	else
		TAFconout("Error: "+cTable+" ao criar chave. ",3,.T.,"AUTCONT")
	EndIf

	IF Select("__TRB__") > 0
		dbSelectArea("__TRB__")
		dbCloseArea()
	Endif

	TcRefresh(cTable)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Estruct
Altera o aHeader de cada autocontida para a estrutura do dbStruct
para utilização do FwBulk

@param cAlias - alias da autocontida
@param aHeader - aHeader criado em cada autocontida

@author Karen Honda
@since 11/03/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function Estruct(cAlias,aHeader)

	Local nK       := 1
	Local aStruct2 := {}
	Local aStruct3 := {}
	Local nPos     := 0

	DBSelectArea(cAlias)
	aStruct2 := (cAlias)->(DbStruct())

	For nK := 1 to Len(aHeader)
		nPos := aScan(aStruct2, {|x| x[1] == aHeader[nK]})
		If nPos > 0
			aAdd(aStruct3, {aStruct2[nPos][1], aStruct2[nPos][2], aStruct2[nPos][3], aStruct2[nPos][4] })
		EndIf
	Next nK

Return aStruct3

//-------------------------------------------------------------------
/*/{Protheus.doc} AltCon
Verifica se a autocontida atualiza somente o registro novo ou toda a tabela pelo controle do campo ALTCON

@param cAlias - alias
@param aRegistro - registro da autocontida
@param aStruct - estrutura do aheader
@param nVerEmp - versao da autocontida do ambiente

@author Karen Honda
@since 11/03/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function AltCon(aRegistro,nAltCon, nVerEmp)

	Local lRet as Logical

	Default aRegistro := {}
	Default nAltCon   := 0
	Default nVerEmp   := 0

	lRet := .F.
	// se versão vazia, atualiza tudo
	If Empty(nVerEmp) 
		lRet := .T. 
	Else
		If nAltCon > 0
			If Len(aRegistro) >= nAltCon
				If aRegistro[nAltCon] >= nVerEmp
					lRet := .T.
				EndIf	
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet
