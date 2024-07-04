#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "ApWizard.ch"
#Include "SpedXDef.ch"

Static nMemoST1 := 1048575

Static oFisaExtSx := FisaExtX02()

Static cTCGetDB := Upper(AllTrim(TCGetDB()))
Static cSrvType := TcSrvType()

/*/{Protheus.doc} FDeParaTAF

Esta funcao realiza o DE/PARA dos codigos do Protheus para o TAF

@Param cTipo     -> Tipo do De/Para que sera realizado
aCodigos  -> Codigos a Serem Validados

@Return ( Nil )

@author Rodrigo Aguilar
@since  22/03/2013
@version 1.0
/*/
Function FDeParaTAF(cTipo,aCodigos)

	Local cRet := ""

	// Produto
	If cTipo == "SB1"

		// Caso exista codigo de Servico informado no Protheus o mesmo sera cadastrado no TAF com codigo 09 = servico
		If !Empty(aCodigos[2])
			cRet := "09"
		Else
			Do Case
				Case aCodigos[1] == "AI"
				cRet := "08"
				Case aCodigos[1] == "EM" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP02
				cRet := "02"
				Case aCodigos[1] == "MC"
				cRet := "07"
				Case aCodigos[1] == "ME" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP00
				cRet := "00"
				Case aCodigos[1] == "MP" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP01
				cRet := "01"
				Case aCodigos[1] == "OI" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP10
				cRet := "10"
				Case aCodigos[1] == "PA" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP04
				cRet := "04"
				Case aCodigos[1] == "PI" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP06
				cRet := "06"
				Case aCodigos[1] == "PP" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP03
				cRet := "03"
				Case aCodigos[1] == "SP" .Or. aCodigos[1] $ oFisaExtSx:_MV_BLKTP04
				cRet := "05"
			EndCase
		EndIf

		// Para os demais tipos de Proutos nao existem os respectivos codigos no TAF, assim todos entram como "99" (Outros)
		If Empty( cRet )
			cRet := "99"
		EndIf

	ElseIf cTipo $ "SA1_AIF"

		Do Case
			Case aCodigos[1] $ "A1_COD/A4_COD/A2_COD"
			cRet := "002"
			Case aCodigos[1] $ "A1_NOME/A4_NOME/A2_NOME"
			cRet := "003"
			Case aCodigos[1] $ "A1_CODPAIS/A4_CODPAIS/A2_CODPAIS"
			cRet := "004"
			Case aCodigos[1] $ "A1_CGC/A4_CGC/A2_CGC"
			If Len(aCodigos[2]) > 11
				cRet := "005"
			Else
				cRet := "006"
			EndIf
			Case aCodigos[1] $ "A1_INSCR/A4_INSEST/A2_INSCR"
			cRet := "007"
			Case aCodigos[1] $ "A1_CODMUN/A4_COD_MUN/A2_CODMUN"
			cRet := "008"
			Case aCodigos[1] $ "A1_SUFRAMA/A4_SUFRAMA"
			cRet := "009"
			Case aCodigos[1] $ "A1_END/A4_END/A2_END"
			cRet := "011"
			Case aCodigos[1] $ "A1_COMPLEM/A4_COMPLEM/A2_COMPLEM"
			cRet := "013"
			Case aCodigos[1] $ "A1_BAIRRO/A4_BAIRRO/A2_BAIRRO"
			cRet := "015"
			Case aCodigos[1] $ "A1_EST/A4_EST/A2_EST"
			cRet := "016"
			Case aCodigos[1] $ "A1_CEP/A4_CEP/A2_CEP"
			cRet := "017"
			Case aCodigos[1] $ "A1_DDD/A4_DDD/A2_DDD"
			cRet := "018"
			Case aCodigos[1] $ "A1_TEL/A4_TEL/A2_TEL"
			cRet := "019"
			Case aCodigos[1] $ "A1_EMAIL/A4_EMAIL/A2_EMAIL"
			cRet := "022"
			Case aCodigos[1] == "A1_FAX/A2_FAX"
			cRet := "021"
			Case aCodigos[1] == "A1_PESSOA"
			cRet := "024"
		EndCase

	ElseIf cTipo == "SB1_AIF"

		Do Case
			Case aCodigos[1] == "B1_COD"
			cRet := "01"
			Case aCodigos[1] == "B1_DESC"
			cRet := "02"
			Case aCodigos[1] == "B1_CODBAR"
			cRet := "03"
			Case aCodigos[1] == "B1_UM"
			cRet := "04"
			Case aCodigos[1] == "B1_TIPO"
			cRet := "05"
			Case aCodigos[1] == "B1_POSIPI"
			cRet := "06"
			Case aCodigos[1] == "B1_EX_NCM"
			cRet := "07"
			Case aCodigos[1] == "B1_ORIGEM"
			cRet := "14"
			Case aCodigos[1] == "B1_PICM"
			cRet := "16"
		EndCase

	ElseIf cTipo == "SFT_TIPO"

		Do Case
			Case aCodigos[1] == "D"
			cRet := "01"
			Case aCodigos[1] == "I"
			cRet := "02"
			Case aCodigos[1] == "P"
			cRet := "03"
			Case aCodigos[1] == "C"
			cRet := "04"
			Case aCodigos[1] == "B"
			cRet := "05"
			Case aCodigos[1] == "S"
			cRet := "06"
			OtherWise
			cRet := "00"
		EndCase

	ElseIf cTipo == "SFU_GRUPT"

		/*
		Soma 1 no codigo do grupo de tensao eletrica ate o codigo
		11 para ficar de acordo com o Layout TAF. A partir do 12
		os codigos equivalem
		*/
		If aCodigos[1] <= "11"
			cRet := StrZero(Val(aCodigos[1]) + 1,2)
		Else
			cRet := aCodigos[1]
		EndIf

	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FCrDirSys

Esta Funcao realiza a Criacao dos Diretorios na RootPath

@Param aWizard    -> Parametrizacoes da Wizard
cNomeDir   -> Nome da Pasta do System
lJob       -> Indica se foi chamado por Job

@Return ( Nil )

@author Rodrigo Aguilar
@since  20/03/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FCrDirSys( aWizard, cNomeDir, lJob )

	Local nRetDir  := 0

	cNomeDir := "\Extrator_TAF"
	If !File( cNomeDir )
		nRetDir := MakeDir( cNomeDir )

		If nRetDir != 0
			cNomeDir := ""
			If lJob
			Else
				Help( ,,"CRIADIR",, "N„o foi possÌvel criar o diretÛrio. Erro: " + cValToChar( FError() ) , 1, 0 )
			EndIf
		EndIf
	EndIf

	If !Empty( cNomeDir )
		cNomeDir +=  "\" + Alltrim(DToS( aWizard[1][3] ) ) + "_" + Alltrim( DToS( aWizard[1][4] ) )
		If !File( cNomeDir )
			nRetDir := MakeDir( cNomeDir )

			If nRetDir != 0
				cNomeDir := ""
				If lJob
				Else
					Help( ,,"CRIADIR",, "N„o foi possÌvel criar o diretÛrio. Erro: " + cValToChar( FError() ) , 1, 0 )
				EndIf
			EndIf
		EndIf
	EndIf

	If !Empty( cNomeDir )
		cNomeDir += "\" + StrTran( Alltrim( cFilAnt ), " ", "")
		If !File( cNomeDir )
			nRetDir := MakeDir( cNomeDir )

			If nRetDir != 0
				cNomeDir := ""
				If lJob
				Else
					Help( ,,"CRIADIR",, "N„o foi possÌvel criar o diretÛrio. Erro: " + cValToChar( FError() ) , 1, 0 )
				EndIf
			EndIf
		EndIf
	EndIf

Return ( Nil )

/*/{Protheus.doc} FConcTxt
	(Funcao Generica para aglutinar as Strings e realizar a sua gravacao no arquivo TXT)

	@author Rodrigo Aguilar
	@since 20/03/2013

	@param aRegs, array, contÈm as Informacoes do registro que serao gerados
	@param nHdlTxt, numerico, handle do arquivo criado

	@Return Nil, nulo, n„o tem retorno 
	/*/
Function FConcTxt(aRegs,nHdlTxt)

	Local cDelimit := "|"
	Local cStrTxt := ""
	Local cRegSer := "T013AW|T066AA|T012AA|T021AC|T015AG|T020AC|T065AA|T066AB|T050AC|T013|T013AD"

	Local aRegSer := Strtokarr(cRegSer,'|')

	Local nI := 1
	Local nY := 1
	Local nPosSer := 0
	Local nQtdDec := 0
	Local nDecAux := 0
 
	For nI := 1 To Len(aRegs)
		cStrTxt += cDelimit

		For nY := 1 To Len(aRegs[nI])
			/*
				Verifico se o registro possui o campo serie de acordo com a lista cRegSer,
				caso exista, devo imprimir somente as 3 primeiras posicoes
			*/
			If nY == 1 .And. Ascan(aRegSer,cRegSer) > 0
				nPosSer := PosSerie(aRegs[nI][nY])
			EndIF

			If Valtype( aRegs[nI][nY] ) == "N"
				nDecAux	:= At('.',Alltrim(Str(aRegs[nI][nY])))
				nQtdDec := Len(Alltrim(Str(aRegs[nI][nY]))) - nDecAux
				if nDecAux == 0
					nQtdDec := 0 
				endif
				cStrTxt += Val2Str( aRegs[nI][nY], 16, nQtdDec )
			ElseIf Valtype(aRegs[nI][nY]) == "D"
				cStrTxt += DToS( aRegs[nI][nY] )
			ElseIf Valtype(aRegs[nI][nY]) == "A" .And. Len(aRegs[nI][nY]) == 2 .And. ValType(aRegs[nI][nY][1]) == "N" .And. ValType(aRegs[nI][nY][2]) == "N"
				cStrTxt += Val2Str(aRegs[nI][nY][1],16,aRegs[nI][nY][2])
			ElseIf !(nPosSer == nY)
				cStrTxt += Alltrim(aRegs[nI][nY])
			EndIf

			If nPosSer == nY
				cStrTxt += AllTrim(SubStr(aRegs[nI][nY],1,3))
			EndIf

			cStrTxt += cDelimit
		Next nY

		If cTpSaida == "1"     //"1-TXT MILE"
			cStrTxt += CRLF
		ElseIf cTpSaida == "2" //"2-Acesso Nativo"
			aAdd(aDadosST1,cStrTXT)
			cStrTXT := ""
		EndIf
	Next

	// "1-TXT MILE"
	If cTpSaida == "1"
		FWrite( nHdlTxt, cStrTxt, Len( cStrTxt ) )
	EndIf

Return Nil

/*/{Protheus.doc} FConcST1
(Funcao que utiliza o array aDadosST1 aglutinado e grava na tabela
TAFST1, apos a gravacao limpa o array aDadosST1 para o proximo layout)

@type Function
@author Alexandre Lemes
@since  29/05/2014

@param cAliasST1, caracter, alias da tabela do TAF (TAFST1 e TAFST2)
@param cNFisOri, caracter, contem numero da nfiscal caso nro nf servico tenha alterado no retorno da prefeitura

@Return Nil, nulo, n„o tem retorno
/*/
Function FConcST1(cAliasST1,cNFisOri)

	Local nLine   := 1
	Local cStrTxt := ""
	Local cSeq    := "000"
	Local cCodPai := IIf( cTpSaida == "2" , STUFF( aDadosST1[1] ,1 ,1 ,"" ) , "" )
	local cIdThread:= StrZero( ThreadID(), 10 )
	local lIntTAF := .f.
	Local lFirst := .T.

	Local aCposSFT  := {}
	Local cTpOper   := ""
	Local cSerie    := ""
	Local cNumNF    := ""
	Local cPartELoja:= ""
	Local cTAFKEY   := ""
	Local lTAFGST2	:= .f.
	Local cExtTicket := ""  
	Local cExtTime := ""
	Local dExtDate := CtoD("")

	Default cAliasST1 := "TAFST1"
	Default cNFisOri  := ""

	cExtTicket 	:=	GetGlbValue("FISAEXTEXC_TKTEXT")
	dExtDate 	:=	StoD(GetGlbValue("FISAEXTEXC_DATAEXT"))
	cExtTime 	:=	GetGlbValue("FISAEXTEXC_HORAEXT") 
	lIntTAF 	:=	&(GetGlbValue("FISAEXTEXC_LTEMC1E")) 
	lTAFGST2	:=	lIntTAF  

	/*
	A variavel lGeraST2TAF eh uma PRIVATE do programa EXTFISXTAF.PRW que indica que o extratator fiscal esta sendo executado de forma NATIVA ≥
	atraves de STARTJOB acionado pelo ERP Protheus, quando isso ocorre o extrator NAO gravara os registros do layout na tabela TAFST1 e sim  ≥
	na tabelas TAFST2 direto, em seguida tambÈm chamara o integrador e gravara as informacoes diretamente nas tabelas do TAF, no termino do  ≥
	processo gravara um FLAG no ERP na tabela SFT campo FT_TAFKEY indicando que a nota fiscal foi integrada no TAF, caso ocorra inconsistenci≥
	as o flag NAO sera gravado para que anota apos ajusta seja importada manualmente pelo extratator.                                        ≥
	*/
	If Type('lGeraST2TAF') == 'L' .And. lGeraST2TAF
		cAliasST1 := cST2Alias
	Else 
		lGeraST2TAF := .F.
 
		// IntegraÁ„o via banco-a-banco, com o TAF como um mÛdulo, a gravacao deve ser direta na ST2
		If lTAFGST2 .and. cAliasST1 <> 'TAFST2'
			cAliasST1 := 'TAFST2'
			if select(cAliasST1) == 0
				FOpnTabTaf( "TAFST2", cAliasST1 ) 
				//cFsUser	:= AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" )) 
			Endif 

		EndIf
	EndIf
	
	//"2-Acesso Nativo"
	If cTpSaida == "2" .And. !Empty(cCodPai)

		cCodPai := Substr( cCodPai ,1 ,AT( "|",cCodPai)-1 )

		If lIntTAF .And. cCodPai == "T013"
			aCposSFT  := Str2Arr(adadosST1[1],"|")

			cTpOper   := Iif( aCposSFT[03] == "0","E","S" )
			cSerie    := Padr(aCposSFT[08],TamSx3("FT_SERIE")[1])
			cNumNF    := PADR(aCposSFT[10],TamSx3("FT_NFISCAL")[1])
			cPartELoja:= Substr(aCposSFT[06],2,TamSx3("A1_COD")[1])
			cPartELoja+= PADR(Substr(aCposSFT[06],TamSx3("A1_COD")[1]+2,TamSx3("A1_LOJA")[1]),TamSx3("A1_LOJA")[1])

			cTAFKEY   := xFilial("SFT")+cTpOper+cSerie+cNumNF+cPartELoja
			If !Empty(cNFisOri) .And. cNumNF <> cNFisOri
				cNumNF := cNFisOri
			EndIf
		EndIf

		For nLine := 1 To Len(aDadosST1)
			if !lFirst
				cStrTxt +=	CRLF
			endif

			cStrTxt += Alltrim( aDadosST1[nLine] )

			lFirst := .F.
			If Len(cStrTxt) >= nMemoST1

				cInc := Soma1(cInc)
				cSeq := Soma1(cSeq)

				RecLock(cAliasST1,.T.)
				(cAliasST1)->TAFFIL	   	:= allTrim( cEmpAnt ) + allTrim( cFilAnt )
				(cAliasST1)->TAFTPREG 	:= cCodPai //Grava o campo Chave
				(cAliasST1)->TAFCODMSG	:= "1"
				(cAliasST1)->TAFKEY 	:= IIf( lIntTAF .And. cCodPai == "T013" , cTAFKEY , DtoS(Date())+StrTran(Time(),":","")+cInc+cCodPai+cCodPai+AllTrim(cValtoChar(ThreadId()))+cValtoChar(nLine) ) // Grava o campo Chave
				(cAliasST1)->TAFSTATUS	:= "1" 	// Grava TAFSTATUS como pronto para Leitura
				(cAliasST1)->TAFIDTHRD	:= IIf(lGeraST2TAF, cIdThread , " ")  // No caso de integracao NATIVA gravo a Thread
				(cAliasST1)->TAFMSG		:= cStrTxt
				(cAliasST1)->TAFSEQ      := cSeq

				// Para a integracao NATIVA eh necessario grava o TICKET para importacao do TAF.
				If lGeraST2TAF .Or. lTAFGST2
					(cAliasST1)->TAFTICKET := cExtTicket
					(cAliasST1)->TAFDATA   := dExtDate
					(cAliasST1)->TAFHORA   := cExtTime
					If (cAliasST1)->(FieldPos('TAFPRIORIT')) > 0
						(cAliasST1)->TAFPRIORIT	:=	'5'
					EndIf
				
				EndIf
				if (cAliasST1)->( FieldPos( 'TAFUSER') ) > 0 
					(cAliasST1)->TAFUSER	:=	 cExtUser 
				endif 
				(cAliasST1)->(MsUnlock())

				cStrTxt := ""
				lFirst := .T.
			EndIf
		Next nLine

		If !Empty( cStrTxt )
			cInc := Soma1(cInc)
			RecLock(cAliasST1,.T.)
			(cAliasST1)->TAFFIL	   	:= allTrim( cEmpAnt ) + allTrim( cFilAnt )
			(cAliasST1)->TAFTPREG 	:= cCodPai //Grava o campo Chave
			(cAliasST1)->TAFCODMSG	:= "1"
			(cAliasST1)->TAFSEQ   	:= "001" // Grava a sequencia do Registro
			(cAliasST1)->TAFKEY 	:= IIf( lIntTAF .And. cCodPai == "T013" , cTAFKEY , DtoS(Date())+StrTran(Time(),":","")+cInc+cCodPai+cCodPai+AllTrim(cValtoChar(ThreadId()))+cValtoChar(nLine) ) // Grava o campo Chave
			(cAliasST1)->TAFSTATUS	:= "1" // Grava TAFSTATUS como pronto para Leitura
			(cAliasST1)->TAFIDTHRD	:= IIf(lGeraST2TAF, cIdThread , " ") // No caso de integracao NATIVA gravo a Thread
			(cAliasST1)->TAFMSG		:= cStrTxt

			// Para a integracao NATIVA eh necessario grava o TICKET para importacao do TAF.
			If lGeraST2TAF .Or. lTAFGST2
				(cAliasST1)->TAFTICKET := cExtTicket
				(cAliasST1)->TAFDATA   := dExtDate
				(cAliasST1)->TAFHORA   := cExtTime
				if (cAliasST1)->( FieldPos( 'TAFPRIORIT') ) > 0 
					(cAliasST1)->TAFPRIORIT	:=	'5'
				endif
			EndIf
			if (cAliasST1)->( FieldPos( 'TAFUSER') ) > 0
				(cAliasST1)->TAFUSER	:=	cExtUser 
			endif

			MsUnlock()
		EndIf

		// Chamada da funcao do TAF responsavel por integrar o registro do layout nas tabelas do TAF.
		If lGeraST2TAF //.or. lIntTAF
			FIntegTaf(  AllTrim((cAliasST1)->TAFTPREG) , (cAliasST1)->TAFIDTHRD )
		EndIf
		
		aDadosST1 := {}

	EndIf

Return Nil

/*/{Protheus.doc} ExtCriaWz

Realiza a Criacao da Wizard do Extrator do Protheus

@Param	cNomWiz  -> Nome da Wizard
cNomeAnt -> Arquivo .CFP que ja possui as configuracoes da Wizard

@Return ( lRet ) -> Indica se foi criada a Wizard em Questao

@author Rodrigo Aguilar
@since  20/03/2013
@version 1.0
/*/
Function ExtCriaWz ( cNomWiz, cNomeAnt )

	Local	cTitObj1	:=	""
	Local	cTitObj2	:=	""

	Local	cTamProd 	:=	TamSx3("B1_COD")[1]
	Local 	cTamNF 	:=  TamSX3("FT_NFISCAL")[1]
	Local 	cTamSer		:=  TamSX3("FT_SERIE")[1]
	Local 	cTamEsp		:=  TamSX3("FT_ESPECIE")[1]

	Local	aTxtApre	:=	{}
	Local	aPaineis	:=	{}
	Local	aItens1		:=	{}

	Local	lRet		:=	.T.

	Default	cNomeAnt	:= ""

	aAdd( aTxtApre, "Par‚metros necess·rios." )
	aAdd( aTxtApre, "" )
	aAdd( aTxtApre, "Preencha corretamente as informaÁıes solicitadas." )
	aAdd( aTxtApre, "InformaÁıes necess·rias para a GeraÁ„o do Extrator." )

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥                                                                     PAINEL 0     															   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aAdd ( aPaineis, {} )
	nPos :=	Len( aPaineis )

	aAdd ( aPaineis[nPos], "Preencha corretamente as informaÁıes solicitadas." )
	aAdd ( aPaineis[nPos], "Par‚metros para GeraÁ„o" )
	aAdd ( aPaineis[nPos], {} )

	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"DiretÛrio do Arquivo Destino";							cTitObj2 :=	"Nome do Arquivo Destino"
	aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd ( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	cTitObj1 :=	Replicate("X",50);									cTitObj2 :=	Replicate ( "X", 20 )
	aAdd( aPaineis[nPos][3], { 2, , cTitObj1, 1, , , , 50 } );		aAdd ( aPaineis[nPos][3], { 2, , cTitObj2, 1, , , , 20 } )

	aAdd( aPaineis[nPos][3], { 0, "", , , , , , } );					aAdd ( aPaineis[nPos][3], { 0, "", , , , , , } )

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Data de";								   			cTitObj2	:=	"Data atÈ"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {2,,,3,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"Seleciona Filiais ?";								    cTitObj2 :=	"PerÌodo da ApuraÁ„o de IPI ?"
	aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	aItens1	:=	{ "1-Sim", "2-Nao" };									aItens2	:=	{ "0-Mensal", "1-Decendial" }

	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aadd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } )

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"IncidÍncia tribut·ria no perÌodo ?";								    						 cTitObj2 :=	"Inicio ObrigaÁ„o EscrituraÁ„o Fiscal CIAP ?"
	aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );													 aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	aItens1	:=	{ "1-Regime n„o-cumulativo", "2-Regime cumulativo", "3-Regimes n„o-cumulativo e cumulativo" };  aItens2	:=	{ "1-Sim", "2-N„o" }

	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );													 aadd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } )

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], { 0,"",,,,,,});																	 aAdd (aPaineis[nPos][3], { 0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"Seleciona Layouts ?";								    cTitObj2 :=	"Tipo de SaÌda?"
	aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	aItens1	:=	{ "1-Sim", "2-Nao" };								aItens2	:=	{ "1-TXT MILE", "2-Banco-a-banco"};

	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } );

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Nota Fiscal De:";										   cTitObj2	:=	"Nota Fiscal AtÈ:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", cTamNF);								 	  	cTitObj2	:=	Replicate ("X", cTamNF)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamNF});			       	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamNF})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"Tipo ContribuiÁ„o ?";							    cTitObj2 :=	"Indicador Regime Cumulativo?"
	aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	aItens1	:=	{ "1-Alq.Basica", "2-Alq.Espec." };				aItens2	:=	{ "1-Caixa", "2-Consolidado", "9-Detalhado"};

	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } );

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"Tipo de Atividade:";							cTitObj2 :=	"Indicador Natureza PJ"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	aItens1	:=	{ "0 - Industrial ou Equiparado", "1 - Outros" }; 	aItens2	:=	{ "00-PJ Em Geral", "01-Soc. Cooperativa(N„o SCP)", "02-Ent. Suj. PIS Folha de Sal.", "03-PJ Em Geral(Part. SCP)", "04-Soc. Cooperativa(Part. SCP)", "05-SCP"}
	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } )

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"Centralizar apuraÁıes e totalizadores ";			cTitObj2	:=	""
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	"em uma ˙nica filial ?";								cTitObj2	:=	""
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	aItens1	:=	{ "1-N„o", "2-Sim" }
	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"SeleÁ„o de tÌtulos a receber?";				    cTitObj2 :=	"SeleÁ„o de tÌtulos a pagar?"
	aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	aItens1 := {"1-Data de ContabilizaÁ„o","2-Data de Emiss„o"};	aItens2 := {"1-Data de ContabilizaÁ„o","2-Data de Emiss„o"}
	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd( aPaineis[nPos][3], { 3, , , , , aItens2 , , } )

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"SÈrie de:";									cTitObj2	:=	"SÈrie atÈ:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", cTamSer);						cTitObj2	:=	Replicate ("X", cTamSer)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamSer});			aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamSer})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"EspÈcie do documento ";						cTitObj2	:=	""
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3],{0,"",,,,,,})

	cTitObj1	:=	"(Separado por ponto e vÌrgula) ?";				cTitObj2	:=	""
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3],{0,"",,,,,,})

	cTitObj1	:=	Replicate ("X",120);						    cTitObj2	:=	""
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,120,,,'SX542M'});	aAdd (aPaineis[nPos][3], {1,,"",1,,,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"Tipo de Movimento";							cTitObj2 :=	""
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});					aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )
	//
	aItens1	:=	{};													cTitObj2 :=	""
	aAdd (aItens1, "1-Ambos")
	aAdd (aItens1, "2-Entradas")
	aAdd (aItens1, "3-Saidas")
	//
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥                                                                     PAINEL 1     															   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], "Preencha corretamente as informaÁıes solicitadas.")
	aAdd (aPaineis[nPos], "InformaÁıes para processamento do Invent·rio")
	aAdd (aPaineis[nPos], {})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Produto Inicial";										   cTitObj2	:=	"Produto Final"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", cTamProd);								   cTitObj2	:=	Replicate ("X", cTamProd)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamProd});			       aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,cTamProd})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						   	       aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Armazem Inicial";										   cTitObj2	:=	"Armazem Final"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", TamSx3("B1_LOCPAD")[1]);				   cTitObj2	:=	Replicate ("X", TamSx3("B1_LOCPAD")[1])
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,TamSx3("B1_LOCPAD")[1]});	   aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,TamSx3("B1_LOCPAD")[1]})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								   aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Considera o saldo De/Em poder de Terceiros";       	   cTitObj2    :=  "Considera saldo em processo"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	//
	aItens2	:=	{}
	aItens2	:=	{"1-Sim","2-Nao"}
	//
	aItens1	:=	{}
	aAdd (aItens1, "1-Sim")
	aAdd (aItens1, "2-N„o")
	aAdd (aItens1, "3-De Terceiros")
	aAdd (aItens1, "4-Em Terceiros")
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});						aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Motivo do Invent·rio";                            cTitObj2	:=	"Nome arq. Gerado no Reg. Inv. Mod.7"
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});		  	    	   aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	//
	aItens1	:=	{};													   cTitObj2	:=	Replicate ("X", 8)
	aAdd (aItens1, "01-Final do perÌodo")
	aAdd (aItens1, "02-MudanÁa de trib. da mercadoria (ICMS)")
	aAdd (aItens1, "03-Solic. da baixa cad., paral. temp. e outras")
	aAdd (aItens1, "04-Na alteraÁ„o de regime de pagamento")
	aAdd (aItens1, "05-Por determinaÁ„o dos fiscos")
	//
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,8})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,}); 							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"Data de fechamento do estoque";						cTitObj2 :=	"Reg. T046 por Mov. ?(Consumo Padronizado)"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )
	//
	aItens1	:=	{}
	aItens1	:=	{"1-Sim","2-Nao"}
	//
	aAdd (aPaineis[nPos][3], {2,,,3,,,,});								aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥                                                                     PAINEL 2     															   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aAdd ( aPaineis, {} )
	nPos :=	Len( aPaineis )

	aAdd ( aPaineis[nPos], "Preencha corretamente as informaÁıes solicitadas." )
	aAdd ( aPaineis[nPos], "InformaÁıes do SPED" )
	aAdd ( aPaineis[nPos], {} )

	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1 :=	"CÛd. da Receita para prestaÁ„o de serviÁos";			cTitObj2 :=	"CÛd. da Receita para demais operaÁıes"
	aAdd( aPaineis[nPos][3], { 1, cTitObj1, , , , , , } );			aAdd ( aPaineis[nPos][3], { 1, cTitObj2, , , , , , } )

	cTitObj1 :=	Replicate ( "X", 6 );									cTitObj2 :=	Replicate ( "X", 6 )
	aAdd( aPaineis[nPos][3], { 2, , cTitObj1, 1, , , , 6 } );			aAdd ( aPaineis[nPos][3], { 2, , cTitObj2, 1, , , , 6 } )

	aAdd( aPaineis[nPos][3], { 0, "", , , , , , } );					aAdd ( aPaineis[nPos][3], { 0, "", , , , , , } )
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥                                                                     PAINEL 3     															   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aAdd ( aPaineis, {} )
	nPos :=	Len( aPaineis )

	aAdd (aPaineis[nPos], "Preencha corretamente as informaÁıes solicitadas.")
	aAdd (aPaineis[nPos], "IdentificaÁ„o do Contribuinte")
	aAdd (aPaineis[nPos], {})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Complemento do cadastro"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Obrigatoriedade do ECD:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aItens1	:=	{ "0 - N„o È obrigada", "1 - Empresa obrigada a entrega ECD" }
	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Classif. Tribut. conforme tabela 8:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aItens1	:=	{ ;
	"01-Regime trib SN c/ trib prev substituÌda",;
	"02-Regime trib SN c/ trib prev n„o substituÌda",;
	"03-Regime trib SN c/ trib prev ambas",;
	"04-MEI - Micro Empreendedor Individual",;
	"06-Agroind˙stria",;
	"07-Produtor Rural Pessoa JurÌdica",;
	"08-ConsÛrcio Simplif. Produtores Rurais",;
	"09-”rg„o Gestor de M„o de Obra",;
	"10-Entidade Sindical se refere a Lei 12.023/2009",;
	"11-Assoc Desportiva que mantÈm Clube de Futebol Profissional",;
	"13-Banco, caixa econÙmica, sociedade de crÈdito, financiamento e investimento e demais empresas relacionadas no par·grafo 1∫ do art. 22 da Lei 8.212./91",;
	"14-Sindicatos em geral, exceto aquele classificado no cÛdigo [10]",;
	"21-Pessoa FÌsica, exceto Segurado Especial",;
	"22-Segurado Especial",;
	"60-Miss„o Diplom·tica ou Repart Consular de carreira estrangeira",;
	"70-Empresa de que trata o Decreto 5.436/2005",;
	"80-Entidade Imune ou Isenta",;
	"85-Ente Federativo, ”rg„os da Uni„o, Autarquias e FundaÁıes P˙blicas",;
	"99-Pessoas JurÌdicas em Geral"}
	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Acordo internacional isenÁ„o de multas:"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aItens1	:=	{ "0 - Sem acordo", "1 - Com acordo" }
	aAdd( aPaineis[nPos][3], { 3, , , , , aItens1 , , } );			aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Contato do contribuinte"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Nome";												cTitObj2	:=	"CPF"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd ( aPaineis[nPos][3], { 1, cTitObj2,,,,,,11} )
	//
	cTitObj1	:=	Replicate ("X", 70);								cTitObj2	:=	Replicate ("X", 11)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,70});					aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,11})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Telefone, com DDD";								cTitObj2	:=	"Telefone Celular, com DDD"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 13);								cTitObj2	:=	Replicate ("X", 13)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,13});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,13})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"E-Mail"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 50)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Empresa Desenvolvedora do Software"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"CNPJ (somente CNPJ para buscar cadastro"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"fornec.)"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 14)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,14,,,'SA2EXT'});		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Raz„o Social";										cTitObj2	:=	"Contato"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	//
	cTitObj1	:=	Replicate ("X", 80);								cTitObj2	:=	Replicate ("X", 70)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,80});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,70})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Telefone, com DDD";								cTitObj2	:=	"E-Mail"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 13);								cTitObj2	:=	Replicate ("X", 60)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,13});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,60})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	cTitObj1	:=	"Telefone Celular Contato, com DDD";				cTitObj2	:=	"Ente Federativo Respons·vel"
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 14)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,14})
	aItens2		:=	{};													aItens2 := {"1-Sim","2-Nao"}
	aadd( aPaineis[nPos][3], {3,cTitObj2 , , , , aItens2 , , } )
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"CNPJ Ente Federativo Respons·vel";					cTitObj2	:=	"Indicativo de desoneraÁ„o da folha pela CPRB"
	aAdd (aPaineis[nPos][3], {1,cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})

	cTitObj1	:=	Replicate ("X", 14)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,14})
	aItens2		:=	{};aItens2 := { "0 - N„o Aplic·vel", "1 - Emp. enquadrada termos Lei 12.546/2011 e alter."}
	aadd( aPaineis[nPos][3], {3,cTitObj2 , , , , aItens2 , , } )
	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	cTitObj1	:=	"Indicativo da SituaÁ„o da Pessoa JurÌdica";		cTitObj2	:=	"Sobrepıe InformaÁıes do Contribuinte"
	aAdd(aPaineis[nPos][3], {1,cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3], {3,cTitObj1 , , , , aItens1 , , } );		aItens2	:=	{}
 																		aItens2	:=	{"2-Nao","1-Sim"}
																	aadd( aPaineis[nPos][3], {3,cTitObj2 , , , , aItens2 , , } )
																	
	aItens1	:=	{}
	aItens1	:=	{	"0 - SituaÁ„o Normal"	, 	;
					"1 - ExtinÁ„o"			, 	;
					"2 - Fus„o"				, 	;
					"3 - Cis„o"				, 	;
					"4 - IncorporaÁ„o"}								

	//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//--------------------------------------------------------------------------------------------------------------------------------------------------//

	lRet := fWizard( aTxtApre, aPaineis, cNomWiz, cNomeAnt )

Return( lRet )

/*/{Protheus.doc} TafPartic

Esta Funcao retorna as informacoes do participante

@Param cAlias -> Alias da Tabela ja Posicionada

@Return ( Nil )

@author Rodrigo Aguilar
@since  12/04/2013
@version 1.0

/*/
Function TafPartic( cAlias, cAliasQry )

	Local aRet    := Array( 07 )
	Local cAlS    := SubStr( cAlias, 2, 2 )
	Local cTpPart := Iif( cAlias == "SA1", "C", Iif( cAlias == "SA2", "F", "T" ) )

	Default cAliasQry := ""

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Quando nao eh passado o Alias da Query assumimos que o Alias≥
	//≥ja esta posicionado                                         ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If Empty( cAliasQry )
		cAliasQry := cAlias
	EndIf

	aRet[1] := cTpPart + (cAliasQry)->&( cAlS + "_COD" ) 								 //Codigo
	aRet[2] := (cAliasQry)->&( cAlS + "_EST"     )  	 								//Estado
	aRet[3] := (cAliasQry)->&( cAlS + "_COD_MUN" )	  	 								//Codigo do Municipio

	If Len( AllTrim( (cAliasQry)->&( cAlS + "_CGC") ) ) >= 14
		aRet[4] :=  SPEDConType(SPEDVldIE((cAliasQry)->&( cAlS + "_CGC"),,.F.))		//CNPJ
	Else
		aRet[4] := "" 																	//CNPJ
	EndIf

	If cAlias <> "SA4" 																	//Transportador
		aRet[5] := (cAliasQry)->&( cAlS + "_PAIS"   )	  								//Pais
	EndIf

	If Len(AllTrim((cAliasQry)->&( cAlS + "_CGC" ) ) ) < 14
		aRet[6] := SPEDConType(SPEDVldIE((cAliasQry)->&( cAlS + "_CGC"),,.F.))	   	//CPF
	Else
		aRet[6] := ""																	//CPF
	EndIf

	aRet[7] := (cAliasQry)->&( cAlS + "_NOME" ) 										//Nome

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FGerPerTAF

Realiza a Busca do Periodo Solicitado nos Parametros De / Ate

@Param dDataD  -> Data Inicial
dDataAt -> Data Final

@Return ( Nil )

@author Rodrigo Aguilar
@since  23/05/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function FGerPerTAF( dDataD, dDataAt )

	Local dDataDe  := LastDay( dDataD )
	Local dDataAte := LastDay( dDataAt )
	Local aRet    := {}

	While dDataDe <> dDataAte
		Aadd( aRet, dDataDe )

		dDataDe := LastDay( LastDay( dDataDe ) + 1 )
	EndDo

	Aadd( aRet, dDataDe )

Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Desc2Cod

FunÁ„o que retorna o codigo de municipio atraves da descriÁ„o

@Param cDescMun    -> DescriÁ„o do municipio

@Return ( Nil )

@author Fabio V Santana
@since  02/05/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function Desc2Cod(cDescMun)

	Local cCodMun := ""

	cDesMun := UPPER(cDescMun)

	DbSelectArea("CC2")
	CC2->(DbSetOrder(2))
	CC2->(dbGoTop())

	If CC2->( MsSeek( xFilial( "CC2" ) + cDescMun ) )
		cCodMun := CC2->CC2_CODMUN
	EndIf

Return ( cCodMun )
//-------------------------------------------------------------------
/*/{Protheus.doc} RetLayTAF

Funcao para retornar array com os Layouts TAF de acordo com tipo

@Param cTipo ->	1 - Retornar array com layouts de registros mensais
2 - Retornar array com layouts de registros mensais,
quinzenais e decendiais
3 - Retornar ambos

@Return aRet -> Array com os layouts de acordo com tipo selecionado
por parametro

@author Felipe C. Seolin  
@since  24/07/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function RetLayTAF( cTipo )

	Local aRet := {}
	Local nI   := 0

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Todos os Layouts TAF que representam registros apenas gerados decendialmente, quinzenalmente e/ou mensalmente≥
	//≥1 - Mensal                                                                                                   ≥
	//≥2 - Outros                                                                                                   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	aLayout := { ;
	{"T020","1"},;
	{"T021","1"},;
	{"T022","1"},;
	{"T035","1"},;
	{"T045","1"},;
	{"T065","1"},;
	{"T067","1"},;
	{"T072","1"},;
	{"T079","1"},;
	{"T082","1"}}

	If cTipo $ "1|2"
		For nI := 1 to Len(aLayout)
			If aLayout[nI,2] == cTipo
				aAdd(aRet,aLayout[nI,1])
			EndIf
		Next nI
	Else
		For nI := 1 to Len(aLayout)
			aAdd(aRet,aLayout[nI,1])
		Next nI
	EndIf

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFST1Grv
@author telso.carneiro
@since 09/05/2014
@version 1.0
@param cStrTxt, character, (Texto para Gravar)
@return ${return}, ${return_description}
/*/
//-------------------------------------------------------------------
Function TAFST1Grv(cStrTxt,cCodPai,nLine,cAliasST1)
	Local aWrtST1	:= {}
	Local cStrKey	:= ""
	Local lPai	:= .F.
	Local aCampos:= {}

	cStrTxt := STUFF(cStrTxt, 1, 1, "") // Retira o "|" inicial
	cStrTxt := STUFF(cStrTxt, AT(CRLF,cStrTxt), 2, "")

	aWrtST1 := StrToKArr(cStrTxt,"|")
	cStrKey := Upper(AllTrim(aWrtST1[1])) // Obtem a Chave para ComparaÁ„o

	lPai := (cStrKey == cCodPai)

	If lPai
		RecLock("TAFST1",.T.)
		TAFST1->TAFFIL		:= allTrim( cEmpAnt ) + allTrim( cFilAnt )
		TAFST1->TAFTPREG 	:= cStrKey //Grava o campo Chave
		TAFST1->TAFCODMSG	:= "1"
		TAFST1->TAFSEQ   	:= "001" // Grava a sequencia do Registro
		//LePrado
		cInc := Soma1(cInc)
		TAFST1->TAFKEY 	:= DtoS(Date())+StrTran(Time(),":","")+cInc+cCodPai+cStrKey+AllTrim(cValtoChar(ThreadId()))+cValtoChar(nLine)//+cValToChar(Randomize(0,1000)) + AllTrim(Str(SECONDS())) // Grava o campo Chave
		TAFST1->TAFSTATUS	:= "1" // Grava TAFSTATUS como pronto para Leitura
		TAFST1->TAFIDTHRD	:= " " // TAFIDTHRD sempre "branco" aqui.
		TAFST1->TAFMSG	:= cStrTxt
		MsUnlock()
	Else
		cStrTxt := CRLF+'|'+cStrTxt
		If Len(TAFST1->TAFMSG) >= nMemoST1
			Aadd(aCampos,{"TAFSEQ",SOMA1(TAFST1->TAFSEQ)})
			Aadd(aCampos,{"TAFMSG",cStrTxt})
			xCopyReg("TAFST1",aCampos) //copia registro
		Else
			RecLock("TAFST1",.F.)
			TAFST1->TAFMSG := TAFST1->TAFMSG+cStrTxt
			MsUnlock()
		EndIf
	EndIf

Return(Nil)

/*/{Protheus.doc} xCopyReg
(long_description)

@author telso.carneiro
@since 12/05/2014
@version 1.0

@param cCpAlias, caracter, alias da tabela.
@param aCampos, array, DescriÁ„o do par‚metro

@return Nil, nulo, n„o tem retorno.
/*/
Static Function xCopyReg(cCpAlias,aCampos)

	Local nCount := 0
	Local nPosicao := 0

	cInc := Soma1(cInc)

	DbSelectArea(cCpAlias)

	RecLock(cCpAlias,.T.)
	(cCpAlias)->TAFFIL		:= allTrim( cEmpAnt ) + allTrim( cFilAnt )
	(cCpAlias)->TAFTPREG 	:= cStrKey //Grava o campo Chave
	(cCpAlias)->TAFCODMSG	:= "1"
	(cCpAlias)->TAFSEQ   	:= "001" // Grava a sequencia do Registro
	(cCpAlias)->TAFKEY 	:=DtoS(Date())+StrTran(Time(),":","")+cInc+cCodPai+cStrKey+AllTrim(cValtoChar(ThreadId()))+cValtoChar(nLine)//+cValToChar(Randomize(0,1000)) + AllTrim(Str(SECONDS())) // Grava o campo Chave
	(cCpAlias)->TAFSTATUS	:= "1" // Grava TAFSTATUS como pronto para Leitura
	(cCpAlias)->TAFIDTHRD	:= " " // TAFIDTHRD sempre "branco" aqui.
	(cCpAlias)->TAFMSG	:= cStrTxt

	// Altera o conteudo dos campos passados como referencia
	For nCount := 1 to Len(aCampos)
		nPosicao := FieldPos(aCampos[nCount][1])

		If !Empty(nPosicao)
			FieldPut(nPosicao,aCampos[nCount][2])
		EndIf
	Next
	(cCpAlias)->(MsUnlock())

Return
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±
±≥FunáÖo    ≥PosSerie  ≥ Autor ≥ Fabio V. Santana      ≥ Data ≥14/04/2014≥±
±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±
±≥DescriáÖo ≥ Retorna a posicao do campo serie                           ≥±
±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±
±≥ Uso      ≥ Extrator Fiscal                                            ≥±
±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function PosSerie(cRegSped)

	Local cReg3		:= "T012AA|T013AW|T066AA"
	Local cReg4		:= "T050AC|T021AC|T015AG|T020AC|T065AA|T066AB"
	Local cReg7		:= "T013|T013AD"

	Local nPos 		:= 0

	If cRegSped $ cReg3 .and. cRegSped <> "T013"
		nPos := 3
	ElseIf cRegSped $ cReg4
		nPos := 4
	ElseIf cRegSped $ cReg7
		nPos := 7
	EndIf

	Return (nPos)

	/*/{Protheus.doc} FSubItRegras()
	FunÁ„o responsavel por realizar o tratamento dos cÛdigos de SubItem( Nota ou ApuraÁ„o )
	que devem ser enviados para o TAF

	@author Rodrigo Aguilar
	@since 10/04/2013

	@param cMVEstado, caracter, Conte˙do do par‚metro MV_ESTADO
	@param aInfoCompl, array, Array com os campos do documento fiscal que devem ser tratados quando alancda existir
	@param _cEntSai, caracter, IdentificaÁ„o do tipo de operaÁ„o
	@param cSubItem, caracter, Subitem gerado pelo Protheus que deve ser convertido para envio ao TAF

	@return array, [1] - CÛdigo do Subitem [2] - CÛdigo do motivo (DAPI)
	/*/
Function FSubItRegras(cMVEstado,aInfoCompl,_cEntSai,cSubItem,cCfop)

	Local aRetorno := {}

	Default cMVEstado := ""
	Default _cEntSai := ""
	Default cSubItem := ""
	Default cCfop := ""

	Default aInfoCompl := {}

	// [1] = CÛdigo do Subitem, [2] = Codigo do motivo (DAPI)
	aRetorno := {"",""}

	/*
	Caso n„o entre nas condiÁıes de tratamento da funÁ„o retorno o array com o cÛdigo de subitem passado por par‚metro
	*/
	cSubItem := AllTrim(cSubItem)
	aRetorno[1] := cSubItem

	/*
	TRATAMENTO PARA O ESTADO DE MINAS GERAIS
	Atende a regra de geraÁ„o da DAPI/MG
	*/
	If cMVEstado == "MG"
		// Caso existam informaÁıes complementares utilizo o array para o retorno das informaÁıes
		If Len(aInfoCompl) > 0

			/*
			Caso o campo da TES esteja como '1' apenas verifico se a operaÁ„o em quest„o È
			de entrada ou saÌda para definir qual o cÛdigo de Subitem que devo mandar
			para o TAF
			*/
			// F4_TRFICM
			If aInfoCompl[2] == "1"
				If _cEntSai == "E"
					aRetorno := {"00066","00000"}
				Else
					aRetorno := {"00073","00000"}
				EndIf
			EndIf

			// F4_ESTCRED
			If aInfoCompl[3] > 0
				aRetorno := {"00090","000001"}
			EndIf

			// D1_ESTCRED
			If aInfoCompl[4] > 0
				aRetorno := {"00095","00005"}
			EndIf

		Else	// Retornar de acordo com o cÛdigo do subitem enviado na chamada da funÁ„o

			If cSubItem == "002.74"
				aRetorno := {"00074",""}
			ElseIf cSubItem == "003.01"
				aRetorno := {"00095","00001"}
			ElseIf cSubItem == "003.02"
				aRetorno := {"00095","00002"}
			ElseIf cSubItem == "003.03"
				aRetorno := {"00095","00003"}
			ElseIf cSubItem == "003.04"
				aRetorno := {"00095","00004"}
			ElseIf cSubItem == "006.67"
				aRetorno := {"00067",""}
			ElseIf cSubItem == "006.68"
				aRetorno := {"00068",""}
			ElseIf cSubItem == "006.69"
				aRetorno := {"00069",""}
			ElseIf cSubItem == "006.71"
				aRetorno := {"00071",""}
			ElseIf cSubItem == "007.70"
				aRetorno := {"00070",""}
			EndIf

		EndIf

	ElseIf cMVEstado == "SP"
		// Relaciona o cÛdigo do subitem referente a CFOP enviada na chamada da FunÁ„o, para atender a GIA-SP
		If cCfop $ "5601|1605"
			aRetorno := {"00219",""}
		ElseIf cCfop $ "1601|1602"
			aRetorno := {"00730",""}
		ElseIf cCfop == "5602"
			aRetorno := {"00218",""}
		ElseIf cCfop == "5605"
			aRetorno := {"00729",""}
		ElseIf cCfop $ "5603|6603"
			aRetorno := {"00210",""}
		ElseIf cCfop $ "5603|6603"
			aRetorno := {"00701",""}
		EndIf
	EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} xValExtCmp
Funcao que valida conteudo digitado nos campos da wizard, conforme
parametros enviados.

@param 	nVal  		- 	Numero da ValidaÁ„o a ser realizada
aInfo		-   InformaÁıes do campo a ser validado
aObj  		- 	Objeto que esta sendo validado ( conte˙do do campo )
aPosterior	-	InformaÁ„o do campo subsequente
aAnterior	-	InformaÁ„o do campo anterior
aCmpsPan 	- 	Objetos do Painel Corrente
aAllCmps	- 	Objetos de todos os Paineis

@return lRet -	Conteudo validado ou nao.

@author Evandro dos Santos Oliveira
@since 29/10/2014
@version 1.0
@obs Essa validaÁ„o È executada quando no array de dados È enviado a 12
posiÁ„o que valida os campos na aÁ„o do bot„o  NEXT da Wizard com auxilio
da funÁ„o xValWizd.
/*/
//-------------------------------------------------------------------
Function xValExtCmp( nVal, aInfo, aObj, aPosterior, aAnterior, aCmpsPan, aAllCmps )

	Local lRet			:=	.T.
	Local nX			:=	0
	Local cContent	:=	""
	Local aCmpsPanel	:= {}
	Local aAuxCmps	:= {}

	Default nVal		:=	0
	Default aInfo		:=	{}
	Default aObj		:=	{}

	If Len( aObj ) > 0
		cContent := IIf( ValType( aObj[1] ) == "D", AllTrim( DToS( aObj[1] ) ), AllTrim( aObj[1] ) )
	EndIf

	//Retiro os objetos Null, desta forma ficam no array somente os objetos reais da tela
	//aEval(aCmpsPan,{|x| IIf(!Empty(x[2]),aAdd(aCmpsPanel,x),) })

	Do Case

		Case nVal == 1

		If !Empty( cContent )
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + AllTrim( aObj[1] ) )
				MsgInfo( "Contabilista n„o cadastrado." )
				lRet := .F.
			EndIf
		EndIf

		Case nVal == 2

		If Empty( cContent )
			MsgInfo( "PerÌodo de escrituraÁ„o n„o informado." ) //
			lRet := .F.
		Else
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + cContent, .T. )
				MsgInfo( "PerÌodo de escrituraÁ„o n„o cadastrado." ) //
				lRet := .F.
			EndIf
		EndIf

		Case nVal == 3

		If Empty( cContent )
			MsgInfo( "DiretÛrio do arquivo de destino n„o informado." ) //
			lRet := .F.
		EndIf

		Case nVal == 4

		If Empty( cContent )
			MsgInfo( "Nome do arquivo de destino n„o informado." ) //
			lRet := .F.
		EndIf

		Case nVal == 5

		If Empty( cContent )
			MsgInfo( "Vers„o n„o informada." ) //
			lRet := .F.
		Else
			DBSelectArea( aInfo[1] )
			DBSetOrder( Val( aInfo[2] ) )
			If !MsSeek( xFilial( aInfo[1] ) + cContent, .T. )
				MsgInfo( "Vers„o n„o cadastrada." ) //
				lRet := .F.
			EndIf
		EndIf

		Case nVal == 6

		/*REGRA_REC_ANTERIOR_OBRIGATORIO
		Verifica, quando o campo 0000.RETIFICADORA È igual a "S" ( ECF Retificadora )
		ou "F" ( ECF original com mudanÁa de forma de tributaÁ„o ), se 0000.NUM_REC est· preenchido.*/
		If SubStr( aAnterior[1], 1, 1 ) $ "S|F" .and. Empty( cContent )
			MsgInfo( "Quando o campo 'EscrituraÁ„o Retificadora?' for igual a 'S' ( ECF Retificadora ) ou 'F' ( ECF original com mudanÁa de forma de tributaÁ„o ), o campo 'N˙mero do Recibo da ECF Anterior' deve estar preenchido." ) //
			lRet := .F.

			/*REGRA_NRO_REC_ANTERIOR_NAO_SE_APLICA
			Verifica, quando 0000.RETIFICADORA È igual a "N" ( ECF Original ), se 0000.NUM_REC n„o est· preenchido.*/
		ElseIf SubStr( aAnterior[1], 1, 1 ) $ "N" .and. !Empty( cContent )
			MsgInfo( "Quando o campo 'EscrituraÁ„o Retificadora?' for igual a 'N' ( ECF Original ), o campo 'N˙mero do Recibo da ECF Anterior' n„o deve estar preenchido." ) //
			lRet := .F.
		EndIf

		Case nVal == 7
		lRet := TAFCTSpd(cContent,3,.T.) //,TAFCfAmb(oAmb:nAt,oServ:nAt)

		If lRet
			xFunVldWiz( "CFG-CERTIFICADO" , aObj, aPosterior, aAnterior, aAllCmps )
		EndIf

		Case nVal == 8 .Or. nVal == 9

		//Pego somente os Campos, faÁo isso por que os objetos de Input est„o sempre nas posiÁıes de numeros pares.
		For nX := 1 To Len(aCmpsPanel)
			If Mod(nX,2) == 0
				aAdd(aAuxCmps,aCmpsPanel[nX])
			EndIf
		Next nX

		If nVal == 8
			lRet := TAFCTrsf(aAuxCmps[1][2]:nAt,aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[6][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[7][1],"")
		Else
			lRet := TAFCMail(1,aAuxCmps[1][1],aAuxCmps[2][1],aAuxCmps[3][1],aAuxCmps[4][1],aAuxCmps[5][1],aAuxCmps[6][1],aAuxCmps[7][1],aAuxCmps[8][1],.F.)
		EndIf

		Case nVal == 10

		If !Empty( cContent )
			If SM0->( !MsSeek( cEmpAnt + AllTrim( cContent ) ) )
				MsgInfo( "Filial centralizadora n„o encontrada" )
				lRet := .F.
			EndIf
		EndIf

		OtherWise

		lRet := .F.

	EndCase

Return( lRet )

/*/{Protheus.doc} fWizard
(FunÁ„o de montagem da Wizard da rotina.)

@type Static Function
@Author	Gustavo G. Rueda
@Since 24/04/2012

@param aTxtApre, array, contÈm o cabeÁalho da Wizard
@param aPaineis, array, contÈm os painÈis da Wizard
@param cNomeWizard, caracter, contÈm nome do arquivo da Wizard
@param cNomeAnt, caracter nome do arquivo anterior da Wizard, caso tenha mudado de nome
@param nTamSay, numerico,
@param lBackIni, logico,
@param bFinalExec, bloco de cÛdigo, contÈm aÁ„os que ser· executado ao final da Wizard

@Return	lRet, logico, .T. Para validaÁ„o OK, .F. Para validaÁ„o N√O OK
/*/
Static Function fWizard(aTxtApre,aPaineis,cNomeWizard,cNomeAnt,nTamSay,lBackIni,bFinalExec)

	Local oFont		:=	Nil
	Local oWizard		:=	Nil

	Local cAuxVar		:=	""
	Local cAlsF3		:=	""
	Local cBLine		:=	""
	Local cSep			:=	""
	Local cTextoMGet 	:=  ""

	Local nInd			:=	0
	Local nInd2		:=	0
	Local nI			:=	0
	Local nObject		:=	0
	Local nLinha		:=	0
	Local nColuna		:=	10
	Local nTamCmpDlg	:=	115
	Local nTpColIni	:=	0
	Local nQtdTW		:=	0

	Local lMarkCB		:=	.F.
	Local lIniWiz		:=	.F.
	Local lFim			:=	.F.
	Local lRet			:=	.T.
	Local lGetRdOnly	:=	.F.
	Local lInitPad		:=	.F.
	Local lPassword		:= 	.F.

	Local aItObj		:=	{}
	Local aButtons	:=	{}
	Local aFunParGet	:=	{}
	Local aVarPaineis	:=	{}
	Local aIniWiz		:=	{}
	Local aHeader		:=	{}
	Local aArea		:=	GetArea()

	Local bProcura	:=	{ || }
	Local bValidGet	:=	{ || }
	Local bDblClick	:=	{ || }
	Local bNext		:=	{ || }
	Local bBack		:=	{ || }
	Local bFinish		:=	{ || }

	Default cNomeAnt		:=	""
	Default nTamSay		:=	0
	Default lBackIni		:=	.F.
	Default bFinalExec	:=	Nil

	lIniWiz := xExtLoadPf(Iif(Empty(cNomeAnt),cNomeWizard,cNomeAnt),@aIniWiz)

	Define FONT oFont NAME "Arial" SIZE 00,-11 BOLD

	Define WIZARD oWizard;
	TITLE SubStr( aTxtApre[1], 1, 80 );
	HEADER SubStr( aTxtApre[2], 1, 80 );
	MESSAGE SubStr( aTxtApre[3], 1, 80 );
	TEXT aTxtApre[4];
	NEXT { || .T. };
	FINISH { || .T. }

	For nInd := 1 to Len( aPaineis )

		//---------------------------------------------------
		// Tratamento para casos em que È passada posiÁ„o 4.
		// Utilizado para Code Block do bot„o AvanÁar
		//---------------------------------------------------
		If Len( aPaineis[nInd] ) >= 4 .and. aPaineis[nInd,4] <> Nil
			bNext := &( "{ || Iif( xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ), " + aPaineis[nInd,4] + ", .F. ) }" )
		Else
			bNext := &( "{ || xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ) }" )
		EndIf

		//---------------------------------------------------
		// Tratamento para casos em que È passada posiÁ„o 5.
		// Utilizado para Code Block do bot„o Voltar
		//---------------------------------------------------
		If Len( aPaineis[nInd] ) >= 5 .and. aPaineis[nInd,5] <> Nil
			bBack := &( "{ || Iif( xValWizB( lBackIni, oWizard ), " + aPaineis[nInd,5] + ", .F. ) }" )
		Else
			bBack := &( "{ || xValWizB( lBackIni, oWizard ) }" )
		EndIf

		//---------------------------------------------------
		// Tratamento para casos em que È passada posiÁ„o 6.
		// Utilizado para Code Block do bot„o Finalizar
		//---------------------------------------------------
		If Len( aPaineis[nInd] ) >= 6 .and. aPaineis[nInd,6] <> Nil
			bFinish := &( "{ || Iif( lFim := xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ), " + aPaineis[nInd,6] + ", .F. ) }" )
		Else
			bFinish := &( "{ || lFim := xValWizd( aPaineis, oWizard:nPanel, aVarPaineis, oWizard ) }" )
		EndIf

		CREATE PANEL oWizard;
		HEADER aPaineis[nInd,1];
		MESSAGE aPaineis[nInd,2];
		BACK bBack;
		NEXT bNext;
		FINISH bFinish

		//-----------------------------------------------------------------------
		// Este array aVarPaineis contÈm as vari·veis objetos dos
		// componentes de cada painÈl. Sua estrutura È a seguinte:
		// 1 - { <conte˙do atribuÌdo ao componente atravÈs da dialog>,<vari·vel do objeto componente>}
		// 2 - ...
		// 3 - ...
		// .
		// .
		// Obs: As linhas do array indicam cada componente do respectivo painÈl.
		//-----------------------------------------------------------------------
		aAdd( aVarPaineis, {} )

		nLinha		:=	0
		nColuna	:=	10
		nObject	:=	0

		For nInd2 := 1 to Len( aPaineis[nInd,3] )

			//Obs: A Coluna pode mudar de valor caso a posiÁ„o 18 do aPaineis existir
			//neste caso a coluna ter· o valor 10 e o nTamCmpDlg ser· multiplicado por 2
			If ( nInd2 % 2 == 0 )
				nColuna	:=	nTamCmpDlg + 20
			Else
				nColuna	:=	10
				nLinha		+=	10
			EndIf

			nTpObj		:=	Iif( aPaineis[nInd][3][nInd2][1] == Nil, 0	, aPaineis[nInd][3][nInd2][1] )				//Tipo do objeto = 1=SAY, 2=MSGET, 3=COMBOBOX, 4=CHECKBOX, 5=LISTBOX, 6=RADIO, 7=BUTTON	,8=Multi-Get	( OBRIGATORIO )
			cTitObj		:=	Iif( aPaineis[nInd][3][nInd2][2] == Nil, ""	, OemToAnsi(aPaineis[nInd][3][nInd2][2]))	//TÌtulo do objeto, quando tiver. Ex: SAY( Caption ), CHECKBOX									( G=OPCIONAL, E=OBRIGATORIO )
			cPctObj		:=	Iif( aPaineis[nInd][3][nInd2][3] == Nil, ""	, aPaineis[nInd][3][nInd2][3] )				//Picture quando for necess·rio. Ex: MSGET														( G=OPCIONAL, E=OBRIGATORIO )
			cTpContObj	:=	Iif( aPaineis[nInd][3][nInd2][4] == Nil, ""	, aPaineis[nInd][3][nInd2][4] )				//Tipo de conte˙do do objeto. Ex: 1=Caracter, 2=NumÈrico, 3=Data								( G=OPCIONAL, E=OBRIGATORIO )
			nDecObj		:=	Iif( aPaineis[nInd][3][nInd2][5] == Nil, 0 	, aPaineis[nInd][3][nInd2][5] )				//N˙mero de casas decimais do objeto MSGET caso seja numÈrico.									( G=OPCIONAL, E=OBRIGATORIO )
			aItObj		:=	Iif( aPaineis[nInd][3][nInd2][6] == Nil, {}	, aPaineis[nInd][3][nInd2][6] )				//Itens de seleÁ„o dos objetos. Ex: COMBOBOX, LISTBOX, RADIO									( G=OPCIONAL, E=OBRIGATORIO )
			lMarkCB		:=	Iif( aPaineis[nInd][3][nInd2][7] == Nil, .F., aPaineis[nInd][3][nInd2][7] )				//OpÁ„o de seleÁ„o do item quando CHECKBOX. Determina se iniciar· marcado ou n„o.			( G=OPCIONAL, E=OBRIGATORIO )
			nNumIntObj	:=	Iif( aPaineis[nInd][3][nInd2][8] == Nil, 0	, aPaineis[nInd][3][nInd2][8] )				//N˙mero de casas inteiras quando o conte˙do do objeto MSGET for numÈrico.					( G=OPCIONAL, E=OBRIGATORIO )

			If ( Len( aPaineis[nInd][3][nInd2] ) >= 9 ) .and. aPaineis[nInd][3][nInd2][9] <> Nil

				lGetRdOnly	:=	aPaineis[nInd][3][nInd2][9][1]
				cTitObj	:=	aPaineis[nInd][3][nInd2][9][2]

				If Len( aPaineis[nInd][3][nInd2][9] ) >= 3
					lInitPad := aPaineis[nInd][3][nInd2][9][3]
				Else
					lInitPad := aPaineis[nInd][3][nInd2][9][1]
				EndIf

			Else
				lGetRdOnly := .F.
			EndIf

			If ( Len( aPaineis[nInd][3][nInd2] ) >= 10 ) .and. aPaineis[nInd][3][nInd2][10] <> Nil
				lGetFile := aPaineis[nInd][3][nInd2][10]
			Else
				lGetFile := .F.
			EndIf

			If ( Len( aPaineis[nInd][3][nInd2] ) >= 11 ) .and. aPaineis[nInd][3][nInd2][11] <> Nil
				cAlsF3 := aPaineis[nInd][3][nInd2][11]
			Else
				cAlsF3 := ""
			EndIf

			//------------------------------------------------------------
			// Tratamento para casos em que È passada posiÁ„o 13.
			// Utilizado para validar o conte˙do dos campos da wizard.
			// Dever· ser enviado dentro de um array o nome da funÁ„o que
			// ser· utilizada para realizar a validaÁ„o e os par‚metros
			// necess·rios para processar esta funÁ„o.
			// Exemplo de utilizaÁ„o: TAFXECF( CriaWzECF )
			//------------------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 13 .and. aPaineis[nInd,3,nInd2,13] <> Nil
				aFunParGet	:=	aPaineis[nInd,3,nInd2,13]
				bValidGet	:=	&( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 ) ) + "], @aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 + 1 ) ) + "], @aVarPaineis[" + AllTrim( Str( nInd ) ) + "," + AllTrim( Str( nInd2 - 1 ) ) + "], @aVarPaineis, aButtons, oWizard ) }" )
			Else
				aFunParGet	:=	{}
				bValidGet	:=	{ || }
			EndIf

			//----------------------------------------------------------------------
			// Tratamento para casos em que È passada posiÁ„o 14.
			// Utilizado para Header de objetos que necessitam desta funcionalidade
			//----------------------------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 14 .and. aPaineis[nInd,3,nInd2,14] <> Nil
				aHeader := aPaineis[nInd,3,nInd2,14]
			Else
				aHeader := {}
			EndIf

			//----------------------------------------------------
			// Tratamento para casos em que È passada posiÁ„o 15.
			// Utilizado para tipo da primeira coluna do Browse
			// 1=MARK, 2=LEGEND
			//----------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 15 .and. aPaineis[nInd,3,nInd2,15] <> Nil
				nTpColIni := aPaineis[nInd,3,nInd2,15]
			Else
				nTpColIni := 0
			EndIf

			//-------------------------------------------------------
			// Tratamento para casos em que È passada posiÁ„o 16.
			// Utilizado para Bloco de CÛdigo de Double Click
			// Obs: OpÁ„o autom·tica de Marca/Desmarca quando È MARK
			//-------------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 16 .and. aPaineis[nInd,3,nInd2,16] <> Nil
				bDblClick := &( "{ || " + aPaineis[nInd,3,nInd2,16] + " }" )
			Else
				bDblClick := { || }
			EndIf

			//-------------------------------------------------------
			// Tratamento para casos em que È passada posiÁ„o 17.
			// Utilizado para Bloco de CÛdigo de Action
			//-------------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 17 .and. aPaineis[nInd,3,nInd2,17] <> Nil
				bAction := &( "{ || " + aPaineis[nInd,3,nInd2,17] + " }" )
			Else
				bAction := { || }
			EndIf

			//-------------------------------------------------------
			// Tratamento para casos em que È passada posiÁ„o 18.
			// o objeto ira ocupar o tamnho das 2 colunas e seu tamanho ser· dobrado
			// para o mesmo ocupar toda a largura da linha na qual est· posicionado.
			//-------------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 18 .and. aPaineis[nInd,3,nInd2,18] <> Nil
				If aPaineis[nInd,3,nInd2,18]
					nTamCmpDlg := nTamCmpDlg*2 + 10
					nColuna := 10
				EndIf
			Else
				nTamCmpDlg := 115
			EndIf

			//-------------------------------------------------------
			// Tratamento para casos em que È passada posiÁ„o 19.
			// Seta a propriedade de Password em um campo TGET
			//-------------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 19 .and. aPaineis[nInd,3,nInd2,19] <> Nil
				lPassword := aPaineis[nInd,3,nInd2,19]
			Else
				lPassword := .F.
			EndIf
			//------------------------------------------------------------
			// PosiÁ„o 20.
			// Determina se deve gravar as InformaÁıes do objeto no profile
			// A lÛgica est· na funÁ„o FatXGrvWizard
			//-------------------------------------------------------------

			//------------------------------------------------------------
			// PosiÁ„o 21.
			// Texto padr„o para os objetos TMULTIGET
			//-------------------------------------------------------------
			If Len( aPaineis[nInd,3,nInd2] ) >= 21 .and. aPaineis[nInd,3,nInd2,21] <> Nil
				cTextoMGet := aPaineis[nInd,3,nInd2,21]
			Else
				cTextoMGet := ""
			EndIf

			//Se j· exisitir um .WIZ criado anteriormente carrego-o para exibiÁ„o e alteraÁ„o conforme necessidade.
			If lIniWiz .and. ( nTpObj >= 2 .and. nTpObj <= 8 ) //Somente objetos que geram txt

				//Contador somente dos objetos que ir„o gerar o txt para que se possa recuper·-lo na ordem de exibiÁ„o dos objetos de cada painÈl.
				nObject ++

				//No caso de CHECKBOX n„o posso armazenar "" e sim lÛgico.
				If nTpObj == 4
					aAdd( aVarPaineis[nInd], { Iif( nTpObj == 4, lMarkCB, "" ), } )
				Else
					aAdd( aVarPaineis[nInd], { "", } )
				EndIf

				//ContÈm somente o conte˙do que ser· atribuÌdo em cada objeto. Sem a cl·usula { OBJ??? } que È gerado no txt.
				If Len( aIniWiz ) >= nInd
					If Len( aIniWiz[nInd] ) >= nObject
						cStrIniWiz := aIniWiz[nInd,nObject]
					Else
						cStrIniWiz := ""
					EndIf
				Else
					cStrIniWiz := ""
				EndIf

				//Caso venha conte˙do a ser utilizado pela wizard devo desconsiderar os valores de antes e assumir sempre o default passado como par‚metro.
				If lInitPad .and. !Empty( cTitObj ) .and. nTpObj == 2
					cStrIniWiz := cTitObj
				EndIf

			ElseIf lIniWiz .and. ( nTpObj >= 0 .and. nTpObj <= 1 ) //Somente objetos que n„o geram txt.

				aAdd( aVarPaineis[nInd], { "", } )

			ElseIf !lIniWiz .and. ( nTpObj >= 0 .and. nTpObj <= 8 ) //Caso n„o tenha um .WIZ anterior, carrego os objetos normalmente e no padr„o. ( Branco ou lÛgicos ).

				If lGetRdOnly .and. !Empty( cTitObj ) .and. nTpObj == 2
					cStrIniWiz := cTitObj
				EndIf

				aAdd( aVarPaineis[nInd], { Iif( nTpObj == 4, lMarkCB, "" ), } )

			EndIf

			//Quando o tipo de objeto for SAY, devo tratar somente como informativo, ou seja, somente para exibiÁ„o na Dialog.
			If nTpObj == 1

				aVarPaineis[nInd][nInd2][2] := TSay():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],,, .F., .F., .F., .T., CLR_BLUE,, nTamCmpDlg + nTamSay, 10, .F., .F., .F., .F., .F. )
				aVarPaineis[nInd][nInd2][2]:cCaption := cTitObj

				//Quando o tipo de objeto for tipo MSGET devo tratar os casos de terem conte˙do como Caracter, NumÈrico ou Data.
			ElseIf nTpObj == 2

				If cTpContObj == 1 //Caracter

					If lIniWiz
						aVarPaineis[nInd][nInd2][1] := cStrIniWiz + Iif( nNumIntObj > Len( cStrIniWiz ), Space( nNumIntObj - Len( cStrIniWiz ) ), "" )
					Else
						aVarPaineis[nInd][nInd2][1] := Iif( !Empty( cTitObj ), cTitObj, Space( nNumIntObj ) )
					EndIf

				ElseIf cTpContObj == 2 //NumÈrico

					If lIniWiz
						aVarPaineis[nInd][nInd2][1] := cStrIniWiz
					ElseIf nDecObj == 0
						aVarPaineis[nInd][nInd2][1] := Val( Replicate( "0", nNumIntObj ) )
					Else
						aVarPaineis[nInd][nInd2][1] := Val( Replicate( "0", nNumIntObj ) + "." + Replicate( "0", nDecObj ) )
					EndIf

				ElseIf cTpContObj == 3 //Data

					If lIniWiz
						aVarPaineis[nInd][nInd2][1] := cStrIniWiz
					Else
						aVarPaineis[nInd][nInd2][1] := CToD( "  /  /  " )
					EndIf

				EndIf

				//Verifica se utiliza validaÁ„o do conte˙do do campo na Wizard. Executa Bloco de CÛdigo conforme funÁ„o e par‚metros enviados.
				If !Empty( aFunParGet )
					bValidGet := &( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 ) + "], @aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 + 1 ) + "], aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 - 1 ) + "], @aVarPaineis, aButtons, oWizard ) }" )
				EndIf

				aVarPaineis[nInd][nInd2][2] := TGet():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1], nTamCmpDlg - Iif( lGetFile, 30, 0 ), 9, cPctObj, bValidGet,,,,,, .T.,,,,,,, lGetRdOnly,lPassword, cAlsF3 )

				If lGetFile
					cAuxVar	:=	'aVarPaineis[' +  AllTrim( Str( nInd ) ) + '][' + AllTrim( Str( nInd2 ) ) + '][1] := cGetFile( "", OemToAnsi( "Procurar" ),,,, 12345 )'
					bProcura	:=	&( '{ || ' + cAuxVar + ', Iif( Empty( aVarPaineis[' + Str( nInd ) + '][' + Str( nInd2 ) + '][1] ), aVarPaineis[' + AllTrim( Str( nInd ) ) + '][' + AllTrim( Str( nInd2 ) ) + '][1] := Space( 115 ), Nil ) }' )

					//Adiciono o bot„o e a posiÁ„o do array da vari·vel do cGetFile para uso na funÁ„o xValWizCmp
					aAdd( aButtons, { TButton():New( nLinha, nColuna + nTamCmpDlg - 30, OemToAnsi( "..." ), oWizard:oMPanel[nInd + 1], bProcura, 30, 12,,, .F., .T., .F.,, .F.,,, .F. ), { nInd, nInd2, 1 } } )
				EndIf

			ElseIf nTpObj == 3 //Quando o objeto for do tipo COMBOBOX

				If lIniWiz
					aVarPaineis[nInd][nInd2][1] := cStrIniWiz
				EndIf

				//ValidaÁ„o para manipular/alterar a criaÁ„o do cGetFile
				If Len( aFunParGet ) > 0
					Eval( &( "{ || " + aFunParGet[1] + "('" + aFunParGet[2] + "', aVarPaineis[" + Str( nInd ) + "," + Str( nInd2 ) + "],,, @aVarPaineis, aButtons ) }" ) )
				EndIf

				aVarPaineis[nInd][nInd2][2] := TCombobox():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), aItObj, nTamCmpDlg, 10, oWizard:oMPanel[nInd + 1],,, bValidGet,,, .T. )

			ElseIf nTpObj == 4 //Quando o objetvo for do tipo CHECKBOX devo converter caso exista um .WIZ para booleano.

				If lIniWiz
					If (valtype( cStrIniWiz ) = "L")
						aVarPaineis[nInd][nInd2][1] := cStrIniWiz
					ElseIf "T" $ cStrIniWiz
						aVarPaineis[nInd][nInd2][1] := .T.
					Else
						aVarPaineis[nInd][nInd2][1] := .F.
					EndIf
				EndIf

				aVarPaineis[nInd][nInd2][2] := TCheckBox():New( nLinha, nColuna, cTitObj, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1], nTamCmpDlg, 10,,,,, CLR_BLUE,,, .T. )

			ElseIf nTpObj == 5

				nQtdTW ++
				&( "aItObj" + AllTrim( Str( nQtdTW ) ) ) := aClone( aItObj )
				cAuxVar := "aItObj" + AllTrim( Str( nQtdTW ) )

				aVarPaineis[nInd][nInd2][2] := TWBrowse():New( nLinha, nColuna, 273, 80,, aHeader,, oWizard:oMPanel[nInd + 1],,,,, bDblClick,,,,,,,,, .T.,,,, .T., .T. )
				aVarPaineis[nInd][nInd2][2]:SetArray( &cAuxVar )

				If !Empty( &cAuxVar )

					cSep := ""
					cBLine := "{ || { "
					For nI := 1 to Len( aHeader )

						If nI == 1

							//MARK
							If nTpColIni == 1
								cBLine += cSep + "Iif( " + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "], LoadBitmap( GetResources(), 'LBTIK' ), LoadBitmap( GetResources(), 'LBNO' ) )"
								//LEGEND - Desenvolver
							ElseIf nTpColIni == 2
								cBLine += cSep
							Else
								cBLine += cSep + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "]"
							EndIf

						Else
							cBLine += cSep + cAuxVar + "[aVarPaineis[" + AllTrim( Str( nInd ) ) + "][" + AllTrim( Str( nInd2 ) ) + "][2]:nAt," + AllTrim( Str( nI ) ) + "]"
						EndIf

						cSep := ","

					Next nI
					cBLine += " } }"
					aVarPaineis[nInd][nInd2][2]:bLine := &( cBLine )
				EndIf

			ElseIf nTpObj == 6

				If lIniWiz
					aVarPaineis[nInd][nInd2][1] := cStrIniWiz
				EndIf

				aVarPaineis[nInd][nInd2][2] := TRadMenu():New( nLinha, nColuna, aItObj, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],,,,,,,, nTamCmpDlg, 10,,,, .T. )

			ElseIf nTpObj == 7

				aVarPaineis[nInd][nInd2][2] := TButton():New( nLinha - 2, nColuna, cTitObj, oWizard:oMPanel[nInd + 1], bAction, 50, 10,,,, .T. )

			ElseIf nTpObj == 8
				aVarPaineis[nInd][nInd2][1] := cTextoMGet
				aVarPaineis[nInd][nInd2][2] := tMultiGet():New( nLinha, nColuna, &( "{ |u| Iif( PCount() == 0, aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1], aVarPaineis[" + Str( nInd ) + "][" + Str( nInd2 ) + "][1] := u ) }" ), oWizard:oMPanel[nInd + 1],280,120,,,,,,.T.,,,,,,.T.)

			EndIf

		Next nInd2

	Next nInd

	Activate WIZARD oWizard Centered

	//lFim indica se o bot„o fim foi pressionado. .T. = Sim ou .F. = N„o.
	If lFim
		FatXGrvWizard( cNomeWizard, aVarPaineis, aPaineis )

		If bFinalExec <> Nil
			Eval( bFinalExec )
		EndIf
	Else
		lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FATXGrvWizard
Gravacao dos dados inseridos nos objetos no txt (.WIZ)

@Parameter 	cNomeWizard - Nome do arquivo de Wizard
aVarPaineis - Array com as informacoes digitadas no Wizard
aPaineis - Array com os paineis do Wizard

@return lOk - Estrutura
.T. Para validacao OK
.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FATXGrvWizard ( cNomeWizard , aVarPaineis , aPaineis )
	Local	lRet			:=	.T.
	Local	cConteudo		:=	""
	Local	nInd			:=	0
	Local	nInd2			:=	0
	Local	nQtdCasasInt	:=	0
	Local	nQtdCasasDec	:=	0
	Local	nTipObj			:=	0
	Local	nCtdObj			:=	1
	Local	nPadR			:=	0
	Local	aGrava			:=	{}
	Local 	lGrvCmp			:= .T.

	For nInd := 1 To Len (aVarPaineis)

		nCtdObj		:=	1
		aAdd ( aGrava, "{PAINEL"+StrZero (nInd, 3)+"}" )

		For nInd2 := 1 To Len (aVarPaineis[nInd])
			nQtdCasasInt	:=	aPaineis[nInd][3][nInd2][8]
			nQtdCasasDec	:=	aPaineis[nInd][3][nInd2][5]
			nTipObj		:=	aPaineis[nInd][3][nInd2][1]

			//Verifica se deve grava as informaÁıes do campo
			If Len( aPaineis[nInd,3,nInd2] ) >= 20 .and. aPaineis[nInd,3,nInd2,20] <> Nil
				lGrvCmp :=  aPaineis[nInd,3,nInd2,20]
			Else
				lGrvCmp := .T.
			EndIf

			If lGrvCmp
				//Tratamento para gravacao de objetos com retorno logigos, tipo CHECKBOX
				If (ValType (aVarPaineis[nInd][nInd2][1])=="L")
					If (aVarPaineis[nInd][nInd2][1])
						cConteudo	:=	"T"
					Else
						cConteudo	:=	"F"
					EndIf
					nPadR	:=	1

					//Tratamento da gravacao do objeto GET com conteudo do tipo DATA
				ElseIf (ValType (aVarPaineis[nInd][nInd2][1])=="D")
					cConteudo	:=	DToS (aVarPaineis[nInd][nInd2][1])
					nPadR		:=	8

					//tratamento da gravacao do objeto GET com conteudo NUMERICO+CASAS DECIMAIS.
				ElseIf (ValType (aVarPaineis[nInd][nInd2][1])=="N")
					If nTipObj==6
						cConteudo	:=	StrZero (aVarPaineis[nInd][nInd2][1], 3, 0)
						nPadR	:=	3
					ElseIf (nQtdCasasDec==0)
						cConteudo	:=	StrZero (aVarPaineis[nInd][nInd2][1], nQtdCasasInt, 0)
						nPadR	:=	nQtdCasasInt
					Else
						cConteudo	:=	StrZero (aVarPaineis[nInd][nInd2][1], nQtdCasasInt+nQtdCasasDec+1, nQtdCasasDec)	//O 1 eh por causa do ponto Ex: 99.99
						nPadR	:=	nQtdCasasInt+nQtdCasasDec+1
					EndIf

				Else
					//Tratamento do objeto GET para conteudos CARACTER onde devera menter a quantidade de casas na gravacao para que nao
					//	ocasione problema de truncagem no momendo da recuperacao das informacoes para exibicao no CFP.
					If (nQtdCasasInt<>Nil .And. nQtdCasasInt>0)
						cConteudo	:=	SubStr (aVarPaineis[nInd][nInd2][1], 1, nQtdCasasInt)
						nPadR		:=	nQtdCasasInt
					Else
						cConteudo	:=	aVarPaineis[nInd][nInd2][1]
						nPadR		:=	Len (aVarPaineis[nInd][nInd2][1])
					EndIf
				EndIf
			Else
				cConteudo := ""
			EndIf

			If (nTipObj>1)
				cConteudo	:=	"{OBJ"+StrZero (nCtdObj++, 3)+";"+ValType (aVarPaineis[nInd][nInd2][1])+";"+AllTrim (StrZero (nPadR, 3))+"}"+cConteudo
				aAdd ( aGrava, cConteudo )
			EndIf
		Next (nInd2)
	Next (nInd)

	If nInd >= 1
		fSaveProf ( cNomeWizard , aGrava )
	EndIf

Return (lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} fSaveProf
Funcao que salva os parametros no profile

@Parameter 	cNomeWizard - Nome do arquivo de Wizard
aParametros - Array com o conteudo dos campos do Wizard para gravacao no profile

@return lOk - Estrutura
.T. Para validacao OK

@author Gustavo G. Rueda
@since 24/04/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fSaveProf ( cNomeWizard , aParametros )
	local 	nX			:=	0
	Local 	cWrite		:= 	""
	Local	cBarra		:= 	If ( IsSrvUnix () , "/" , "\" )
	Local	lRet		:=	.T.
	Local	cUserName	:= __cUserID

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf

	For nX := 1 to Len(aParametros)
		cWrite 	+= 	aParametros[nx]+CRLF
	Next

	cNomeWizard	:=	cNomeWizard+"_"+cUserName
	MemoWrit ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" , cWrite )

Return lRet

/*/{Protheus.doc} xExtLoadPf
Funcao que carrega os parametros no profile

@Parameter 	cNomeWizard - Nome do arquivo de Wizard
aParametros - Array com o conteudo do arquivo texto do Wizard (RETORNO POR REFERENCIA)

@return lOk - Estrutura
.T. Para validacao OK
.F. Para validacao NAO OK

@author Gustavo G. Rueda
@since 24/04/2012
@version 1.0
/*/
Function xExtLoadPf(cNomeWizard,aIniWiz)
	Local 	nJ			:=	0
	Local	nI			:=	0
	Local 	cBarra 		:= 	Iif ( IsSrvUnix() , "/" , "\" )
	Local	cTipo		:=	""
	Local	nPadR		:=	0
	Local	cLinha		:=	""
	Local	lRet		:=	.F.
	Local	cUserName	:= __cUserID

	If !ExistDir ( cBarra + "PROFILE" + cBarra )
		Makedir ( cBarra + "PROFILE" + cBarra )
	EndIf

	cNomeWizard	:=	cNomeWizard+"_"+cUserName
	If File ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" )

		If FT_FUse ( cBarra + "PROFILE" + cBarra + Alltrim ( cNomeWizard ) + ".PRB" ) <> -1

			FT_FGoTop ()
			While ( !FT_FEof () )
				cLinha	:=	FT_FReadLn ()
				If ( "PAINEL" $ cLinha )
					aAdd ( aIniWiz , {} )
				Else
					aAdd ( aIniWiz[Len ( aIniWiz )] , cLinha )
				EndIf
				FT_FSkip ()
			Enddo
			FT_FUse ()

			For nJ := 1 To Len ( aIniWiz )
				For nI := 1 To Len ( aIniWiz[nJ] )

					If (SubStr (aIniWiz[nJ][nI], 8, 1)==";")

						cTipo	:=	SubStr ( aIniWiz[nJ][nI] , 9 , 1 )
						nPadR	:=	Val ( SubStr (aIniWiz[nJ][nI] , 11 , 3 ) )
						cLinha	:=	SubStr ( aIniWiz[nJ][nI] , 15 , nPadR )

						Do case
							Case cTipo == "L"
							aIniWiz[nJ][nI]	:= 	Iif ( cLinha == "F" , .F. , .T. )

							Case cTipo == "D"
							aIniWiz[nJ][nI]	:= 	SToD ( cLinha )

							Case cTipo == "N"
							aIniWiz[nJ][nI]	:= 	Val ( cLinha )

							OtherWise
							aIniWiz[nJ][nI]	:=	cLinha
						EndCase

					Else
						aIniWiz[nJ][nI]	:=	SubStr ( aIniWiz[nJ][nI] , 9 )
					EndIf
				Next nI
			Next nJ

			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} xFunExpSql
(FunÁ„o para receber um comando SQL e retornar conforme o banco)

@type Function
@author Vitor Ribeiro
@since 23/05/2018

@param c_Comando, caracter, comando SQL

@return cExpreSql, caracter, express„o SQL conforme o banco
/*/
Function xFunExpSql(c_Comando)

	Local cExpreSql := ""

	Default c_Comando := ""

	If Upper(c_Comando) $ "ISNULL|COALESCE|NVL"

		If cTCGetDB $ "INFORMIX|ORACLE"
			cExpreSql := "NVL"
		ElseIf  cTCGetDB $ "DB2|POSTGRES"  .Or. (cTCGetDB == "DB2/400" .And. Upper(cSrvType) == "ISERIES")
			cExpreSql := "COALESCE"
		Else
			cExpreSql := "ISNULL"
		EndIf

	ElseIf Upper(c_Comando) $ "SUBSTR|SUBSTRING"

		If cTCGetDB $ "ORACLE|DB2|POSTGRES|INFORMIX"
			cExpreSql := "SUBSTR"
		Else
			cExpreSql := "SUBSTRING"
		EndIf

	ElseIf Upper(c_Comando) $ "LENGTH|LEN"

		If cTCGetDB $ "ORACLE|DB2|POSTGRES"
			cExpreSql := "LENGTH"
		Else
			cExpreSql := "LEN"
		EndIf

	EndIf

Return cExpreSql
