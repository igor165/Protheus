#include "protheus.ch"
#include "OFINJD42.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE COL_GRUPO             01
#DEFINE COL_DESCRICAO_GRUPO   02
#DEFINE COL_MODELO            03
#DEFINE COL_CODIGO            04
#DEFINE COL_TEMPO             05
#DEFINE COL_DESCRICAO_SERVICO 06
#DEFINE COL_DESCRICAO_TRABALHADA_SERVICO 07

#define PULALINHA chr(13) + chr(10)

/*/{Protheus.doc} OFINJD42

Importacao da tabela de tempo padrão da John Deere

@author Rubens
@since 18/05/2017
@version undefined

@type function
/*/
Function OFINJD42()

	Local cPerg := "OFINJD42"
	Local lContinue := .t.

	Private oDlgOFN42
	Private oGetDGruSer
	Private oGetDModelo
	Private oGetDServico

	Private cCodMarca := FMX_RETMAR("JD ")
	Private M->VSL_CODMAR := cCodMarca
	Private cFilCodMar    := cCodMarca // Variavel uilizada no SXB do VV2SQL

	Private aSrvcSlv := {} // Grava descrica detalhada do servico

	//CriaSX1(cPerg)
	//AADD(aRegs,{STR0036,STR0036,STR0036,'MV_CH0','C',99,0,,'F','','MV_PAR01','56','','','','','','','','','','','','','','','','','','','','','','','','','','','','Arquivo de TMO|*.tmo',{},{},{}}) // 'Arquivo para Importação'
	//AADD(aRegs,{STR0014,STR0014,STR0014,"MV_CH2","N", 1,0,1,"C", '' , "MV_PAR02", STR0015, STR0015 , STR0015 , "" , "" , STR0016 , STR0016 , STR0016 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {},{},{}})
	If !Pergunte(cPerg)
		Return
	EndIf

	OFNJD42TELA()

	// Carrega Arquivo de Tempo
	//MsgRun( STR0009 , STR0010 , { || lContinue := OFNJD42LOAD(MV_PAR01) } ) // "Processando arquivo de tempo" / "Importação"
	Processa( { || lContinue := OFNJD42LOAD(MV_PAR01) }, STR0009, STR0010,.f.)
	//
	If !lContinue
		return
	Endif

	ACTIVATE MSDIALOG oDlgOFN42 ON INIT EnchoiceBar( oDlgOFN42 , { || IIf( OFNJD42IMPORTA() , oDlgOFN42:End() , .F. ) }, { || oDlgOFN42:End() },,)

Return

/*/{Protheus.doc} OFNJD42IMPORTA
Gravação dos códigos de serviços importados
@author Rubens
@since 05/06/2017
@version undefined
@type function
/*/
Function OFNJD42IMPORTA()

	If !MsgYesNo(STR0011,STR0012) // "Confirma importação do arquivo ?" / Atenção
		Return .f.
	EndIf

	If aScan(oGetDGruSer:aCols, { |x| Empty(x[3]) }) <> 0
		If ! MsgYesNo(STR0026 + CRLF + STR0027 + CRLF + STR0028, STR0012) // "Existe um ou mais grupos de seriços da tabela da John Deere sem relacionamento com o grupo de Serviço do Protheus." "Os serviços sem grupo relacionado não serão importados." "Confirma processamento?"
			Return .f.
		EndIf
	EndIf


	Processa( { || OFNJD420023_ProcessaGravacao() }, STR0029, STR0010,.f.) // "Processando gravação"

	MsgInfo(STR0013,STR0012) // "Arquivo Importado." / "Atenção"

	//cMsgPerg := STR0021 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +; // "Deseja substituir os codigos antigos ?"
	//	STR0022 + CHR(13) + CHR(10) +; // "Serão alterados os códigos dos serviços:"
	//	STR0023 + CHR(13) + CHR(10) +; // "1) De ordem de serviço com tipo de tempo aberto."
	//	STR0024 // "2) De orçamentos que não foram exportados para Ordem de Serviço."
	//
	//If MsgNoYes(cMsgPerg, STR0012)
	//	OFNJD42DEPARA()
	//
	//	If MsgNoYes(STR0020,STR0012) // "Deseja inativar os códigos da primeira importação"
	//		OFNJD42INATIVA()
	//	EndIf
	//EndIf

Return .t.

Function OFNJD420023_ProcessaGravacao()

	Local nCont

	Local nVO6GRUSER := FG_POSVAR("VO6_GRUSER","oGetDServico:aHeader")
	Local nVO6CODSER := FG_POSVAR("VO6_CODSER","oGetDServico:aHeader")
	Local nVO6DESSER := FG_POSVAR("VO6_DESSER","oGetDServico:aHeader")
	Local nVO6DESABR := FG_POSVAR("VO6_DESABR","oGetDServico:aHeader")
	Local nVO6MODVEI := FG_POSVAR("VO6_MODVEI","oGetDServico:aHeader")

	Local nPosaSrvcSlv := Len(oGetDServico:aHeader) + 3

	Local nTamVO6DESDET := TamSX3("VO6_DESDET")[1]

	ProcRegua(Len(oGetDServico:aCols))

	VO6->(dbSetOrder(2)) // VO6_FILIAL+VO6_CODMAR+VO6_CODSER

	Begin Transaction

	For nCont := 1 to Len(oGetDServico:aCols)

		IncProc()

		If Empty(oGetDServico:aCols[nCont, nVO6GRUSER ]) .or. ;
		   Empty(oGetDServico:aCols[nCont, nVO6MODVEI ])
			Loop
		EndIf

		dbSelectArea("VO6")
		If !VO6->(dbSeek(xFilial("VO6") + cCodMarca + oGetDServico:aCols[nCont,nVO6CODSER]))
			RecLock("VO6",.T.)
			VO6->VO6_FILIAL := xFilial("VO6")
			VO6->VO6_SERINT := GetSXENum("VO6","VO6_SERINT")
			ConfirmSx8()
			VO6->VO6_CODMAR := cCodMarca
			VO6->VO6_GRUSER := oGetDServico:aCols[nCont, nVO6GRUSER ]
			VO6->VO6_CODSER := oGetDServico:aCols[nCont, nVO6CODSER ]
			VO6->VO6_DESSER := oGetDServico:aCols[nCont, nVO6DESSER ]
			VO6->VO6_DESABR := oGetDServico:aCols[nCont, nVO6DESABR ]
			VO6->VO6_MODVEI := oGetDServico:aCols[nCont, nVO6MODVEI ]
			VO6->VO6_QTDMEC := 1
			VO6->VO6_SERATI := "1"
		Else
			RecLock("VO6",.F.)
		EndIf
		VO6->VO6_TEMFAB := oGetDServico:aCols[nCont,FG_POSVAR("VO6_TEMFAB","oGetDServico:aHeader")]
		MSMM(VO6->VO6_DESMEM,nTamVO6DESDET,,aSrvcSlv[ oGetDServico:aCols[nCont, nPosaSrvcSlv ] ,COL_DESCRICAO_TRABALHADA_SERVICO],1,,,"VO6","VO6_DESMEM")
		VO6->(MsUnlock())
	Next

	End Transaction

Return

/*/{Protheus.doc} OFNJD42LOAD
Gravação do conteudo do arquivo de importação nas variaveis de tela
@author Rubens
@since 05/06/2017
@version undefined
@param cParDir, characters, descricao
@type function
/*/
Static Function OFNJD42LOAD(cParDir)

	Local aSrvc
	Local nCont := 0
	Local nTamHead := Len(oGetDServico:aHeader) // Mais duas posições ( Deleção de Linha / Descrição Detalhada)
	Local nQtdCol  := Len(oGetDServico:aHeader) + 4 // Mais duas posições ( Deleção de Linha / Descrição Detalhada)
	Local i := 0
	Local cError := ""
	Local cWarning := ""
	Local aPosACols

	Local nGRUPOJD := FG_POSVAR( "GRUPOJD", "oGetDServico:aHeader" )
	Local nDESGRUJD := FG_POSVAR( "DESGRUJD", "oGetDServico:aHeader" )
	Local nMODELOJD := FG_POSVAR( "MODELOJD", "oGetDServico:aHeader" )
	Local nSERVICOJD := FG_POSVAR( "SERVICOJD", "oGetDServico:aHeader" )
	Local nVO6MODVEI := FG_POSVAR( "VO6_MODVEI", "oGetDServico:aHeader" )
	Local nVO6GRUSER := FG_POSVAR( "VO6_GRUSER", "oGetDServico:aHeader" )
	Local nVO6CODSER := FG_POSVAR( "VO6_CODSER", "oGetDServico:aHeader" )
	Local nVO6DESSER := FG_POSVAR( "VO6_DESSER", "oGetDServico:aHeader" )
	Local nVO6DESABR := FG_POSVAR( "VO6_DESABR", "oGetDServico:aHeader" )
	Local nVO6TEMFAB := FG_POSVAR( "VO6_TEMFAB", "oGetDServico:aHeader" )
	Local nRECVO4 := FG_POSVAR( "RECVO4", "oGetDServico:aHeader" )

	Local cDrive, cDir, cNome, cExt

	cParDir := AllTrim(cParDir)
	cFile := cParDir
	//cFile := cParDir + IIf(Right(cParDir,1) $ "/\" , "" , "/") + "tmo.xml"
	If ! File(cFile)
		MsgStop(STR0030) // "Arquivo de TMO não encontrado."
		return .f.
	EndIf

	If Left(cFile,1) $ "\"
	Else
		If existdir("\logsmil") 
		Else
			makedir("\logsmil")
		EndIf

		If ! CpyT2S(cFile,"\logsmil\",.t.)
			MsgStop(STR0031) // "Não foi possível transferir o arquivo de TMO para o servidor."
			Return
		EndIf

		SplitPath( cFile, @cDrive, @cDir, @cNome, @cExt )

		cFile := "\logsmil\" + cNome + cExt

	EndIf


	//ctime1 := time()
	oXmlTMO := XmlParserFile( cFile, "_", @cError, @cWarning )
	If !Empty(cError)
		MsgStop(IIf( !Empty(cError), "Erro: " + AllTrim(cError), "" ),"Erro")
		Return .f.
	EndIf

	//conout(" XMLParserFile - " + ElapTime(ctime1, time() ))

	aServicos := oXmlTMO:_TMO:_SERVICO

	oGetDServico:aCols := {}
	oGetDGruSer:aCols := {}
	oGetDModelo:aCols := {}

	//ctime1 := time()

	ProcRegua(Len(aServicos))

	For i := 1 To Len(aServicos)

		IncProc()

		aSrvc := Array(7)
		oXmlSer := aServicos[i]

		cDescServc := Upper(FwNoAccent(oXmlSer:_DESCRICAO_SERVICO:Text))
		cDescGrupo := Upper(FwNoAccent(oXmlSer:_DESCRICAO_GRUPO:Text))

		aSrvc[COL_GRUPO] := PadL(oXmlSer:_GRUPO:Text,3,"0")
		aSrvc[COL_DESCRICAO_GRUPO] := cDescGrupo
		aSrvc[COL_MODELO] := oXmlSer:_MODELO:Text
		aSrvc[COL_CODIGO] := oXmlSer:_CODIGO:Text
		aSrvc[COL_TEMPO] := oXmlSer:_TEMPO:Text
		aSrvc[COL_DESCRICAO_SERVICO] := cDescServc
		aSrvc[COL_DESCRICAO_TRABALHADA_SERVICO] := Upper(FwNoAccent(oXmlSer:_DESCRICAO_TRABALHADA_SERVICO:Text))


		aPosACols := aScan( oGetDServico:aCols , { |x| x[2] == aSrvc[COL_MODELO] .and. x[3] == aSrvc[COL_CODIGO] })

		OFNJD42MODELO( aSrvc )

		If aPosACols == 0

			AADD( oGetDServico:aCols , Array(nQtdCol) )
			nCont++
			oGetDServico:aCols[ nCont , nGRUPOJD   ] := aSrvc[COL_GRUPO]
			oGetDServico:aCols[ nCont , nDESGRUJD  ] := If( MV_PAR02 == 2, cDescGrupo , "" )
			oGetDServico:aCols[ nCont , nMODELOJD  ] := aSrvc[COL_MODELO]
			oGetDServico:aCols[ nCont , nSERVICOJD ] := aSrvc[COL_CODIGO]
			oGetDServico:aCols[ nCont , nVO6MODVEI ] := "  "					// VO6_MODVEI
			oGetDServico:aCols[ nCont , nVO6GRUSER ] := "  "					// VO6_GRUSER
			oGetDServico:aCols[ nCont , nVO6CODSER ] := aSrvc[COL_CODIGO]	// VO6_CODSER
			oGetDServico:aCols[ nCont , nVO6DESSER ] := cDescServc 			// VO6_DESSER
			oGetDServico:aCols[ nCont , nVO6DESABR ] := cDescServc 			// VO6_DESABR
			oGetDServico:aCols[ nCont , nVO6TEMFAB ] := Val(StrTran( aSrvc[COL_TEMPO] ,",",".")) * 100	// VO6_TEMFAB
			oGetDServico:aCols[ nCont , nRECVO4     ] := 0	// Recno
			oGetDServico:aCols[ nCont , nTamHead + 1] := '1' // peso dos dados que vem da JD e não tem na base
			oGetDServico:aCols[ nCont , nTamHead + 2] := " " // Ultimo sequencial
			oGetDServico:aCols[ nCont , nTamHead + 3] := nCont // Posicao utilizada para posicionar na matriz aSrvcSlv
			oGetDServico:aCols[ nCont , nTamHead + 4] := .F. // Registro deletado

			aAdd(aSrvcSlv,aClone(aSrvc)) // Sera utilizada a coluna nTamHead + 3 para relaciona a getDados oGetDServico com a matriz aSrvcSlv
		Else
			oGetDServico:aCols[ aPosACols, 08 ] := cDescServc 			// VO6_DESSER
			oGetDServico:aCols[ aPosACols, 09 ] := cDescServc 			// VO6_DESABR
			oGetDServico:aCols[ aPosACols, 10 ] := Val(StrTran( aSrvc[COL_TEMPO] ,",",".")) * 100	// VO6_TEMFAB
		EndIf

	Next

	//conout(" Processamento aServicos - " + ctime1 + " - " + time() + " - " + ElapTime(ctime1, Time() ))

	// Verifica quais modelos já existem
	If ! OFNJD42RELACIONA()
		Return .f.
	EndIf

	If ! OFNJD42SEQ() //Grava o código do serviço com o sequencial
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} OFNJD42FOK
Posicionamento dos grupos de serviços e modelo de veiculos para montagem da tela
@author Rubens
@since 05/06/2017
@version undefined
@param cOrigem, characters, descricao
@type function
/*/
Function OFNJD42FOK(cOrigem, cReadVar)

	Default cReadVar := ReadVar()

	Do Case
	Case cOrigem == 'GRUSER'
		Do Case
		Case cReadVar == "M->VOS_CODGRU"
			VOS->(dbSetOrder(1))
			If VOS->(dbSeek(xFilial("VOS") + cCodMarca + M->VOS_CODGRU ))
				oGetDGruSer:aCols[oGetDGruSer:nAt,FG_POSVAR("VOS_DESGRU","oGetDGruSer:aHeader")] := VOS->VOS_DESGRU

				OFNJD420013_ReplicaGrupoServico(M->GRUPJD, M->DESCGRJD, M->VOS_CODGRU )
				oGetDServico:oBrowse:Refresh()
			Else
				Return .f.
			EndIf
		EndCase
	EndCase

Return .t.

Function OFNJD420013_ReplicaGrupoServico(xGRUPJD, cDESCGRJD, cCodigoGrupo )

	Local nGRUPOJD := FG_POSVAR("GRUPOJD","oGetDServico:aHeader")
	Local nDESGRUJD := FG_POSVAR("DESGRUJD","oGetDServico:aHeader")
	Local nRECVO4 := FG_POSVAR("RECVO4","oGetDServico:aHeader")
	Local nVO6GRUSER := FG_POSVAR("VO6_GRUSER","oGetDServico:aHeader")

	aEval( oGetDServico:aCols , ;
		{ |x| IIf( x[nGRUPOJD] == xGRUPJD .and. AllTrim(x[nDESGRUJD]) == AllTrim(cDESCGRJD) .and. x[nRECVO4] == 0 ,;
					x[nVO6GRUSER] := cCodigoGrupo , ;
					) } )

Return

/*/{Protheus.doc} OFNJD42GRUSER
Criação do objeto de Grupo de serviço
@author Rubens
@since 05/06/2017
@version undefined
@param aSrvc, array, descricao
@type function
/*/
Static Function OFNJD42GRUSER(aLinha)
	Local nAuxPos
	Local nAuxPosSrvc

	nAuxPos := aScan( oGetDGruSer:aCols, { |x| x[1] == aLinha[nGRUPOJD] .and. x[2] == aLinha[nDESGRUJD] } )

	If nAuxPos == 0
		AADD( oGetDGruSer:aCols , Array(Len(oGetDGruSer:aHeader) + 1 ) )
		nAuxPos := Len(oGetDGruSer:aCols)
		oGetDGruSer:aCols[ nAuxPos , 1 ] := aLinha[nGRUPOJD]
		oGetDGruSer:aCols[ nAuxPos , 2 ] := aLinha[nDESGRUJD]
		oGetDGruSer:aCols[ nAuxPos , 3 ] := Space(oGetDGruSer:aHeader[3,4])
		oGetDGruSer:aCols[ nAuxPos , 4 ] := Space(oGetDGruSer:aHeader[4,4])
		oGetDGruSer:aCols[ nAuxPos , 5 ] := .F.

		// nos casos em que está sendo feita uma outra importação
		// Verifica se o grupo de servico John Deere ja possui um relacionamento com grupo de servico do Protheus
		nAuxPosSrvc := aScan(oGetDServico:aCols, { |x| x[nGRUPOJD] == aLinha[nGRUPOJD] .and. x[nDESGRUJD] == aLinha[nDESGRUJD] .and. ! Empty(x [nVO6GRUSER] ) })
		If nAuxPosSrvc <> 0
			oGetDGruSer:aCols[ nAuxPos, 3 ] := oGetDServico:aCols[ nAuxPosSrvc, nVO6GRUSER]

			VOS->(dbSetOrder(1))
			If VOS->(dbSeek(xFilial("VOS") + cCodMarca + oGetDServico:aCols[ nAuxPosSrvc, nVO6GRUSER] ))
				oGetDGruSer:aCols[ nAuxPos, 4 ] := VOS->VOS_DESGRU
			EndIf

			OFNJD420013_ReplicaGrupoServico(aLinha[nGRUPOJD], aLinha[nDESGRUJD] , oGetDServico:aCols[ nAuxPosSrvc, nVO6GRUSER] )
		EndIf

	EndIf
Return

/*/{Protheus.doc} OFNJD42MODELO
Criação do objeto de Modelo de Veiculos
@author Rubens
@since 05/06/2017
@version undefined
@param aSrvc, array, descricao
@type function
/*/
Static Function OFNJD42MODELO(aSrvc)
	Local nAuxPos
	If (nAuxPos := aScan( oGetDModelo:aCols, { |x| x[1] == aSrvc[COL_MODELO]} ) ) == 0
		AADD( oGetDModelo:aCols , Array(Len(oGetDModelo:aHeader) + 1 ) )
		nAuxPos := Len(oGetDModelo:aCols)
		oGetDModelo:aCols[ nAuxPos , 1 ] := aSrvc[COL_MODELO]
		oGetDModelo:aCols[ nAuxPos , 2 ] := Space(oGetDModelo:aHeader[2,4])//
		oGetDModelo:aCols[ nAuxPos , 3 ] := Space(oGetDModelo:aHeader[3,4])
		oGetDModelo:aCols[ nAuxPos , 4 ] := .F.
	EndIf
Return

/*/{Protheus.doc} OFNJD42RELACIONA
Função que levantará o modelo do veiculo caso o mesmo já esteja cadastrado no sitema
@author Rubens
@since 05/06/2017
@version undefined
@param nProcIni, numeric, descricao
@param nProcAte, numeric, descricao
@type function
/*/
Static Function OFNJD42RELACIONA( nProcIni , nProcAte )
	Local nCont
	Local cQuery

	Local nMODELOJD := FG_POSVAR("MODELOJD","oGetDModelo:aHeader")
	Local nVV2MODVEI := FG_POSVAR("VV2_MODVEI","oGetDModelo:aHeader")
	Local nVV2DESMOD := FG_POSVAR("VV2_DESMOD","oGetDModelo:aHeader")

	Local nMODELOJD_GETDSERVICO := FG_POSVAR("MODELOJD","oGetDServico:aHeader")
	Local nVO6MODVEI := FG_POSVAR("VO6_MODVEI","oGetDServico:aHeader")

	Local lRetorno := .f.
	Local cAlertMod := ""
	Local nRetPerg  := 0
	Local aVV2ModFab := {}
	Local nPosVV2ModFab

	Local oSql := DMS_SqlHelper():New()

	Default nProcIni := 1
	Default nProcAte := Len(oGetDModelo:aCols)

	cQuery := "SELECT VV2_MODVEI , VV2_DESMOD, VV2_MODFAB " +;
		 " FROM " + RetSQLName("VV2") + " VV2 " +;
		" WHERE VV2.VV2_FILIAL = '" + xFilial("VV2") + "'" +;
		  " AND VV2.VV2_CODMAR = '" + cCodMarca + "'" +;
		  " AND VV2.D_E_L_E_T_ = ' ' "

	aVV2ModFab := oSql:GetSelectArray(cQuery,3)

	For nCont := nProcIni to nProcAte

		nPosVV2ModFab := aScan( aVV2ModFab , { |x| AllTrim(x[3]) == AllTrim(oGetDModelo:aCols[nCont,nMODELOJD]) })

		If nPosVV2ModFab <> 0

			lRetorno := .t.
			oGetDModelo:aCols[nCont , nVV2MODVEI] := aVV2ModFab[ nPosVV2ModFab , 1 ] // (cVV2Alias)->VV2_MODVEI
			oGetDModelo:aCols[nCont , nVV2DESMOD] := aVV2ModFab[ nPosVV2ModFab , 2 ] // (cVV2Alias)->VV2_DESMOD

			// Atualiza campo de Modelo 
			aEval( oGetDServico:aCols , { |x| IIf( x[nMODELOJD_GETDSERVICO] == oGetDModelo:aCols[nCont,nMODELOJD],;
																x[nVO6MODVEI] := aVV2ModFab[ nPosVV2ModFab , 1 ] ,;
																;
															 ) } )

		Else
			cAlertMod += oGetDModelo:aCols[nCont,nMODELOJD] + CHR(13) + CHR(10)

		EndIf


	Next nCont

	dbSelectArea("VV2")

	If ! lRetorno
		Help(NIL, NIL,	"OFNJD42ERR01",,STR0032, 1, 0,NIL, NIL, NIL, NIL, NIL, { STR0033 } ) // "Não foi possível relacionar os modelos contidos no arquivo de TMO com a tabela de modelo do Protheus." // "Verifique se o modelo da fábrica está gravado no campo VV2_MODFAB."
		Return lRetorno
	EndIf

	If lRetorno .and. ! Empty(cAlertMod)

		nRetPerg := Aviso(STR0012,STR0017 + CHR(13) + CHR(10) +; //Atenção //Os modelos abaixo não...
										 cAlertMod, {STR0018,STR0019} , 3) //Continuar //Abortar
		If nRetPerg == 2 .or. nRetPerg == 0
			lRetorno := .f.
		EndIf

	EndIf

	// Remove todos os servicos que não serão importados simplificando a exibição da listbox com os serviços
	// e evitando confusao do usuario 
	If lRetorno .and. aScan( oGetDServico:aCols , { |x| Empty(x[nVO6MODVEI] ) }) > 0
		nPadR := TamSX3("VO6_MODVEI")[1]
		aSort( oGetDServico:aCols ,,, { |x,y| PadR(x[nVO6MODVEI], nPadR) > PadR(y[nVO6MODVEI], nPadR) })
		nCont := aScan( oGetDServico:aCols , { |x| Empty(x[nVO6MODVEI] ) })
		aSize(oGetDServico:aCols, nCont - 1)
	EndIf
	
Return lRetorno

/*/{Protheus.doc} OFNJD42TELA
Montagem da tela
@author Rubens
@since 05/06/2017
@version undefined

@type function
/*/
Static Function OFNJD42TELA()

	Local oInterfHelper := DMS_InterfaceHelper():New()
	Local oSizePrinc

	oInterfHelper:nOpc := 3

	oInterfHelper:SetOwnerPvt("OFINJD42")

	oSizePrinc := oInterfHelper:CreateDefSize( .t. , ;
		{ ;
			{ "LINHA1" , 100 , 100 , .T. , .F. } ,; //
			{ "LINHA2" , 100 , 100 , .T. , .T. }  ; //
		} , ,  )
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	oSizePrinc:Process()

	oInterfHelper:SetDefSize(oSizePrinc)
	oDlgOFN42 := oInterfHelper:CreateDialog(STR0001) // "Importação de Tabela de Tempo Padrão - John Deere"
	oInterfHelper:SetDialog(oDlgOFN42)

	oSizeL1 := oInterfHelper:CreateDefSize( .f. , ;
		{ ;
			{ "COLUNA1" , 070 , 100 , .T. , .T. } ,; //
			{ "COLUNA2" , 100 , 100 , .T. , .T. }  ; //
		},;
		oSizePrinc:GetNextCallArea("LINHA1") , )
	oSizeL1:lLateral := .t.
	oSizeL1:Process()

	oSizeL1C1 := oInterfHelper:CreateDefSize( .f. , ;
		{ ;
			{ "L1C1L1" , 100 , 010 , .T. , .F. } ,; //
			{ "L1C1L2" , 100 , 100 , .T. , .T. }  ; //
		},;
		oSizeL1:GetNextCallArea("COLUNA1") , )
	oSizeL1C1:Process()

	oSizeL1C2 := oInterfHelper:CreateDefSize( .f. , ;
		{ ;
			{ "L1C2L1" , 100 , 010 , .T. , .F. } ,; //
			{ "L1C2L2" , 100 , 100 , .T. , .T. }  ; //
		},;
		oSizeL1:GetNextCallArea("COLUNA2") , )
	oSizeL1C2:Process()

	oSizeGetDSrvc := oInterfHelper:CreateDefSize( .f. , ;
		{ ;
			{ "CABEC"    , 100 , 010 , .T. , .F. } ,; //
			{ "GETDADOS" , 100 , 100 , .T. , .T. }  ; //
		},;
		oSizePrinc:GetNextCallArea("LINHA2") , )
	oSizeGetDSrvc:Process()


	// GetDados de Grupo de Servico
	oInterfHelper:SetDefSize(oSizeL1C1,"L1C1L1")
	oInterfHelper:CreateTPanel({;
		{"TEXTO",STR0002} ,; // "Grupo de Serviço"
		{"COR", CLR_WHITE } ,;
		{"FUNDO", RGB( 10 , 114 , 140 ) } ;
		})

	oInterfHelper:SetDefSize(oSizeL1C1,"L1C1L2")
	oInterfHelper:AddHeaderOBJ( DMS_IFColString():New( {;
		{ "TITULO" , STR0003 } ,; // "Cód."
		{ "CAMPO" , "GRUPJD"  } ,;
		{ "TAMANHO" , 2 },;
		{ "ALTERA" , .F. } } ) )
	oInterfHelper:AddHeaderOBJ( DMS_IFColString():New( {;
		{ "TITULO" , STR0004 } ,; // "Desc. Grupo"
		{ "CAMPO" , "DESCGRJD"  } ,;
		{ "TAMANHO" , 30 },;
		{ "ALTERA" , .F. } } ) )
	oInterfHelper:AddHeader( { { "X3" , "VOS_CODGRU" } , { "X3_VALID"  , ""  } , { "X3_F3" , "VAC   " } } )
	oInterfHelper:AddHeader( { { "X3" , "VOS_DESGRU" } , { "X3_VISUAL" , "V" } } )
	oGetDGruSer := oInterfHelper:CreateNewGetDados("oGetDGruSer" , { ;
		{ "OPERACAO" , GD_UPDATE } ,;
		{ "FIELDOK" , "OFNJD42FOK('GRUSER')" } } )

	// GetDados de Modelo de Veiculos
	oInterfHelper:SetDefSize(oSizeL1C2,"L1C2L1")
	oInterfHelper:CreateTPanel({;
		{"TEXTO", STR0005 } ,; // "Modelo"
		{"COR", CLR_WHITE } ,;
		{"FUNDO", RGB( 10 , 114 , 140 ) } ;
		})

	oInterfHelper:Clean()
	oInterfHelper:nOpc := 3
	oInterfHelper:SetDefSize(oSizeL1C2,"L1C2L2")
	oInterfHelper:AddHeaderOBJ( DMS_IFColString():New( {;
		{ "TITULO" , STR0003 } ,; // "Cód."
		{ "CAMPO" , "MODELOJD"  } ,;
		{ "TAMANHO" , 15 },;
		{ "ALTERA" , .F. } } ) )
	oInterfHelper:AddHeader( { { "X3" , "VV2_MODVEI" } , { "X3_VALID"  , ""  } , { "X3_VISUAL" , "V" }} )
	oInterfHelper:AddHeader( { { "X3" , "VV2_DESMOD" } , { "X3_VISUAL" , "V" } } )

	oGetDModelo := oInterfHelper:CreateNewGetDados("oGetDModelo" , { ;
		{ "OPERACAO" , GD_UPDATE } ,;
		{ "FIELDOK" , "OFNJD42FOK('MODELO')" } } )

	// GetDados de Servicos
	oInterfHelper:SetDefSize(oSizeGetDSrvc,"CABEC")
	oInterfHelper:CreateTPanel({;
		{"TEXTO",STR0006} ,; // "Lista de Serviços"
		{"COR", CLR_WHITE } ,;
		{"FUNDO", RGB( 10 , 114 , 140 ) } ;
		})

	oInterfHelper:Clean()
	oInterfHelper:nOpc := 3
	oInterfHelper:SetDefSize(oSizeGetDSrvc,"GETDADOS")
	oInterfHelper:AddHeaderOBJ( DMS_IFColString():New( {;
		{ "TITULO" , STR0003 } ,; // "Cód."
		{ "CAMPO" , "GRUPOJD"  } ,;
		{ "TAMANHO" , 03 },;
		{ "ALTERA" , .F. } } ) ) // 01
	oInterfHelper:AddHeaderOBJ( DMS_IFColString():New( {;
		{ "TITULO" , STR0034 } ,; // "Desc. Grupo Serviço."
		{ "CAMPO" , "DESGRUJD"  } ,;
		{ "TAMANHO" , 50 },;
		{ "ALTERA" , .F. } } ) ) // 01
	oInterfHelper:AddHeaderOBJ( DMS_IFColString():New( {;
		{ "TITULO" , STR0005 } ,; // "Modelo"
		{ "CAMPO" , "MODELOJD"  } ,;
		{ "TAMANHO" , 15 },;
		{ "ALTERA" , .F. } } ) ) // 02
	oInterfHelper:AddHeaderOBJ( DMS_IFColString():New( {;
		{ "TITULO" , STR0007 } ,; // "Cód. Srvc."
		{ "CAMPO" , "SERVICOJD"  } ,;
		{ "TAMANHO" , 15 },;
		{ "ALTERA" , .F. } } ) ) // 03
	oInterfHelper:AddHeader( { { "X3" , "VO6_MODVEI" } , { "X3_VISUAL" , "V" } } ) // 04
	oInterfHelper:AddHeader( { { "X3" , "VO6_GRUSER" } , { "X3_VISUAL" , "V" } } ) // 05
	oInterfHelper:AddHeader( { { "X3" , "VO6_CODSER" } , { "X3_VISUAL" , "V" } } ) // 06
	oInterfHelper:AddHeader( { { "X3" , "VO6_DESSER" } , { "X3_VISUAL" , "V" } } ) // 07
	oInterfHelper:AddHeader( { { "X3" , "VO6_DESABR" } , { "X3_VISUAL" , "V" } } ) // 08
	oInterfHelper:AddHeader( { { "X3" , "VO6_TEMFAB" } , { "X3_VISUAL" , "V" } } ) // 09
	oInterfHelper:AddHeaderOBJ( DMS_IFColNumero():New( {;
		{ "TITULO" , "Rec. No." } ,;
		{ "CAMPO" , "RECVO4"  } ,;
		{ "TAMANHO" , 10 },;
		{ "ALTERA" , .F. } } ) ) // 10
	oGetDServico := oInterfHelper:CreateNewGetDados("oGetDServico")

Return

/*/{Protheus.doc} OFNJD42SEQ
Levantamento do sequencial por codigo de serviço
@author Renato Vinicius
@since 21/07/2017
@version undefined

@type function
/*/

Function OFNJD42SEQ()

Local nCont := 0
Local cQuery := ""
Local aAllServ := {}
Local cSQLSubstring
Local nTamHead := Len(oGetDServico:aHeader) // Mais duas posições ( Deleção de Linha / Descrição Detalhada)

Local oSql := DMS_SqlHelper():New()

Private nGRUPOJD := FG_POSVAR( "GRUPOJD", "oGetDServico:aHeader" )
Private nDESGRUJD := FG_POSVAR( "DESGRUJD", "oGetDServico:aHeader" )
Private nMODELOJD := FG_POSVAR( "MODELOJD", "oGetDServico:aHeader" )
Private nSERVICOJD := FG_POSVAR( "SERVICOJD", "oGetDServico:aHeader" )
Private nVO6MODVEI := FG_POSVAR( "VO6_MODVEI", "oGetDServico:aHeader" )
Private nVO6GRUSER := FG_POSVAR( "VO6_GRUSER", "oGetDServico:aHeader" )
Private nVO6CODSER := FG_POSVAR( "VO6_CODSER", "oGetDServico:aHeader" )
Private nVO6DESSER := FG_POSVAR( "VO6_DESSER", "oGetDServico:aHeader" )
Private nVO6DESABR := FG_POSVAR( "VO6_DESABR", "oGetDServico:aHeader" )
Private nVO6TEMFAB := FG_POSVAR( "VO6_TEMFAB", "oGetDServico:aHeader" )
Private nRECVO4 := FG_POSVAR( "RECVO4", "oGetDServico:aHeader" )

cSQLSubstring := oSQL:CompatFunc("SUBSTR")

cQuery := "SELECT VO6_CODSER, "
cQuery +=       " VO6_GRUSER, "
cQuery +=       " VO6_DESSER, "
cQuery +=       cSQLSubstring + "(VO6.VO6_CODSER,1,10), "
cQuery +=       " VO6_MODVEI, "
// subselect
cQuery +=       " ( SELECT MAX(" + oSQL:CompatFunc("SUBSTR") + "(VO6_CODSER,12,3)) "
cQuery +=       "     FROM "+RetSQLName("VO6")+" MX "
cQuery +=       "    WHERE MX.VO6_FILIAL = VO6.VO6_FILIAL "
cQuery +=       "      AND MX.VO6_CODMAR = VO6.VO6_CODMAR "
cQuery +=       "      AND " + cSQLSubstring + "(MX.VO6_CODSER,1,10) = " + cSQLSubstring + "(VO6.VO6_CODSER,1,10) "
cQuery +=       " ) as MAXSEQ, "
//
cQuery +=       " R_E_C_N_O_ RECVO6 "
cQuery += " FROM "+RetSQLName("VO6")+" VO6"
cQuery += " WHERE VO6_FILIAL = '" + xFilial("VO6") + "' "
cQuery += " AND VO6_CODMAR = '" + cCodMarca + "' "
cQuery += " AND VO6_CODSER LIKE '__-___-___%' "
cQuery += " AND RTRIM(VO6_CODSER) NOT LIKE '__-___-___' "
cQuery += " AND VO6.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY VO6_CODSER"
aAllServ := oSql:GetSelectArray(cQuery,7)

For nCont := 1 to Len(oGetDServico:aCols)

	aLinha := oGetDServico:aCols[nCont] // Conteudo da Linha da GetDados
	nInd := FS_BuscaBase(aAllServ, aLinha) //Relacionamento entre Tabela x Arq. XML

	if nInd > 0
		aLinha[nVO6GRUSER] := aAllServ[nInd, 02] //Grupo Servico (Tela) = VO6_GRUSER
		aLinha[nVO6CODSER] := aAllServ[nInd, 01] //Cod. Serviço (Tela) = VO6_CODSER
		aLinha[nRECVO4   ] := aAllServ[nInd, 07] // RECNO

		aLinha[nTamHead + 1] := "0" // Peso (Ordem de consideração de registros já cadastrados)
		aLinha[nTamHead + 2] := Right(Alltrim(aAllServ[nInd, 06]),3) // Ultimo sequencial na tabela
	end

next

//conout(" OFNJD42SEQ - " + ElapTime(ctime1, time() ))

// Ordenação: Base de Código de Serviço + Peso + Sequencial + Descrição Serviço
aSort(oGetDServico:aCols,,,{ |x,y| x[nSERVICOJD] + x[nTamHead + 1] + x[nTamHead + 2] + x[nVO6DESSER] < y[nSERVICOJD] + y[nTamHead + 1] + y[nTamHead + 2] + y[nVO6DESSER]})

cDescAnt := ""
cSeq     := "000"
cQuebra  := ""

For nCont := 1 to Len(oGetDServico:aCols)

	aLinha := oGetDServico:aCols[nCont]// Conteudo da Linha da GetDados

	// Nao processa linhas sem DE -> PARA do modelo
	If Empty(aLinha[nVO6MODVEI]) //Modelo (GetDados)
		Loop
	EndIf
	//

	OFNJD42GRUSER(aLinha)

	If cQuebra <> aLinha[nSERVICOJD] //Código Base do Serviço (GetDados)
		cQuebra := aLinha[nSERVICOJD]
		cSeq    := "000"
	EndIf

	// Verifica se o registro posicionado já existe na tabela
	If aLinha[nTamHead + 1] == "0" // Peso
		cSeq := aLinha[nTamHead + 2] // Ultimo sequencial
	Else
		nSeq := Val(cSeq)+1
		cSeq := StrZero(nSeq,3)
		aLinha[nVO6CODSER] := aLinha[nSERVICOJD] + "-" + cSeq //Código de Serviço = Código Base do Servico + Sequencial
		aLinha[nTamHead + 2] := cSeq
	EndIf
Next

If Len(oGetDGruSer:aCols) == 0
	Help(NIL, NIL,	"OFNJD42ERR02",,STR0035, 1, 0,NIL, NIL, NIL, NIL, NIL, { STR0033 } ) // "Não foi possível montar listagem de grupo de serviço." "Verifique se o modelo da fábrica está gravado no campo VV2_MODFAB."
	Return .f.
EndIf


// Ordenação: Grupo de Serviço
aSort(oGetDGruSer:aCols,,,{|x,y| x[1] < y[1]})

aSort(oGetDServico:aCols,,,{ |x,y| x[nVO6MODVEI] + x[nVO6CODSER] < y[nVO6MODVEI] + y[nVO6CODSER] })
oGetDServico:oBrowse:Refresh()

Return .t.

/*/{Protheus.doc} FS_BuscaBase
	Descricao
	Verificação de registro já cadastrado na base
	@type function
	@author Vinicius Gati
	@since Dia/Mês/2017
/*/
Static Function FS_BuscaBase(aBanco, aLinha)

	Local nIdx := 0

	for nIdx := 1 to LEN(aBanco)
		// Comparação: Base do código do serviço (Tabela VO6) = Base do código do serviço (Arq. XML)
		//             Modelo do veículo (Tabela VO6) = Modelo do veículo (Arq. XML relacionado na tabela VV2)
		if Alltrim(aBanco[nIdx, 04]) == Alltrim(aLinha[04]) .AND. ;
			 Alltrim(aBanco[nIdx, 05]) == Alltrim(aLinha[05])
			return nIdx
		endif
	next

Return 0



/*/{Protheus.doc} OFNJD42DEPARA
Realiza DE -> Para os codigos importados errados
@author Rubens
@since 02/08/2017
@version 1

@type function
/*/
//Static Function OFNJD42DEPARA()
//
//	Local cBkpFilAnt := cFilAnt
//	Local oFilHelper := DMS_FilialHelper():New()
//	Local aProcFil := {}
//	Local nPos
//	Local cCodMarca
//	Local cAliasAj := "TMPAJ"
//	Local cQuery
//	Local cQBaseVO6
//	Local cQueryVO6
//	Local cAliasVO6 := "TVO6"
//
//	Begin Transaction
//
//		aProcFil := oFilHelper:GetAllFilGrupoEmpresa()
//
//		For nPos := 1 to Len(aProcFil)
//			cFilAnt := aProcFil[nPos]
//
//			If GetNewPar("MV_MIL0006","") <> "JD"
//				Loop
//			EndIf
//
//			cCodMarca := FMX_RETMAR("JD ")
//			If Empty(cCodMarca)
//				Loop
//			EndIf
//
//			cQBaseVO6 := "SELECT VO6.VO6_CODSER, VO6.VO6_GRUSER, VO6.VO6_SERINT "
//			cQBaseVO6 +=  " FROM "+RetSQLName("VO6")+" VO6"
//			cQBaseVO6 += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "' "
//			cQBaseVO6 +=   " AND VO6.VO6_CODMAR = '" + cCodMarca + "' "
//			cQBaseVO6 +=   " AND VO6.VO6_MODVEI <> '                 '"
//			cQBaseVO6 +=   " AND VO6.VO6_SERATI = '1' "
//			cQBaseVO6 +=   " AND VO6.D_E_L_E_T_ = ' ' "
//
//			cQuery := "SELECT VV1.VV1_MODVEI, VO4.VO4_GRUSER, VO4.VO4_CODSER, VO4.R_E_C_N_O_ RECVO4"
//			cQuery +=  " FROM " + RetSQLName("VO4") + " VO4"
//			cQuery +=         " JOIN " + RetSQLName("VO1") + " VO1 "
//			cQuery +=                 " ON VO1.VO1_FILIAL = '" + xFilial("VO1") + "'"
//			cQuery +=                " AND VO1.VO1_NUMOSV = VO4.VO4_NUMOSV"
//			cQuery +=                " AND VO1.D_E_L_E_T_ = ' '"
//			cQuery +=         " JOIN " + RetSQLName("VV1") + " VV1 "
//			cQuery +=                 " ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
//			cQuery +=                " AND VV1.VV1_CHAINT = VO1.VO1_CHAINT"
//			cQuery +=                " AND VV1.D_E_L_E_T_ = ' '"
//			cQuery +=         " JOIN " + RetSQLName("VO6") + " VO6 "
//			cQuery +=                 " ON VO6.VO6_FILIAL = '" + xFilial("VO6") + "'"
//			cQuery +=                " AND VO6.VO6_CODMAR = '" + cCodMarca + "' "
//			cQuery +=                " AND VO6.VO6_GRUSER = VO4.VO4_GRUSER"
//			cQuery +=                " AND VO6.VO6_CODSER = VO4.VO4_CODSER"
//			cQuery +=                " AND VO6.D_E_L_E_T_ = ' '"
//			cQuery += " WHERE VO4.VO4_FILIAL = '" + xFilial("VO4") + "' "
//			cQuery +=   " AND VO4.VO4_DATCAN = ' '"
//			cQuery +=   " AND VO4.VO4_DATDIS = ' '"
//			cQuery +=   " AND VO4.VO4_DATFEC = ' '"
//			cQuery +=   " AND VO4.D_E_L_E_T_ = ' '"
//			cQuery +=   " AND RTRIM(VO4.VO4_CODSER) LIKE '__-___-___'"
//			cQuery += " ORDER BY VO4.VO4_GRUSER, VO4.VO4_CODSER, VV1.VV1_MODVEI"
//			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasAj, .F., .T. )
//			dbSelectArea("VO4")
//			While !(cAliasAj)->(Eof())
//
//				cQueryVO6 := cQBaseVO6
//				cQueryVO6 += " AND VO6.VO6_MODVEI = '" + (cAliasAj)->VV1_MODVEI + "'"
//				cQueryVO6 += " AND VO6.VO6_CODSER LIKE '" + AllTrim((cAliasAj)->VO4_CODSER) + "%'"
//				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryVO6 ), cAliasVO6, .F., .T. )
//				If !(cAliasVO6)->(Eof())
//
//					VO4->(dbGoTo((cALiasAj)->RECVO4))
//					RecLock("VO4",.F.)
//					VO4->VO4_GRUSER := (cAliasVO6)->VO6_GRUSER
//					VO4->VO4_CODSER := (cAliasVO6)->VO6_CODSER
//					VO4->VO4_SERINT := (cAliasVO6)->VO6_SERINT
//					VO4->(MsUnlock())
//
//				EndIf
//				(cAliasVO6)->(dbCloseArea())
//
//				(cAliasAj)->(dbSkip())
//			End
//			(cAliasAj)->(dbCloseArea())
//			dbSelectArea("VO4")
//
//			cQuery := "SELECT VV1.VV1_MODVEI, VS4.VS4_GRUSER, VS4.VS4_CODSER, VS4.R_E_C_N_O_ RECVS4"
//			cQuery +=  " FROM " + RetSQLName("VS4") + " VS4"
//			cQuery +=         " JOIN " + RetSQLName("VS1") + " VS1 "
//			cQuery +=                 " ON VS1.VS1_FILIAL = '" + xFilial("VS1") + "'"
//			cQuery +=                " AND VS1.VS1_NUMORC = VS4.VS4_NUMORC"
//			cQuery +=                " AND VS1.D_E_L_E_T_ = ' '"
//			cQuery +=         " JOIN " + RetSQLName("VV1") + " VV1 "
//			cQuery +=                 " ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
//			cQuery +=                " AND VV1.VV1_CHAINT = VS1.VS1_CHAINT"
//			cQuery +=                " AND VV1.D_E_L_E_T_ = ' '"
//			cQuery +=         " JOIN " + RetSQLName("VO6") + " VO6 "
//			cQuery +=                 " ON VO6.VO6_FILIAL = '" + xFilial("VO6") + "'"
//			cQuery +=                " AND VO6.VO6_CODMAR = '" + cCodMarca + "' "
//			cQuery +=                " AND VO6.VO6_GRUSER = VS4.VS4_GRUSER"
//			cQuery +=                " AND VO6.VO6_CODSER = VS4.VS4_CODSER"
//			cQuery +=                " AND VO6.D_E_L_E_T_ = ' '"
//			cQuery += " WHERE VS4.VS4_FILIAL = '" + xFilial("VS4") + "' "
//			cQuery +=   " AND VS4.D_E_L_E_T_ = ' '"
//			cQuery +=   " AND RTRIM(VS4.VS4_CODSER) LIKE '__-___-___'"
//			cQuery +=   " AND VS1.VS1_NUMOSV <> '        '"
//			cQuery += " ORDER BY VS4.VS4_GRUSER, VS4.VS4_CODSER, VV1.VV1_MODVEI"
//			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasAj, .F., .T. )
//			dbSelectArea("VS4")
//			While !(cAliasAj)->(Eof())
//
//				cQueryVO6 := cQBaseVO6
//				cQueryVO6 += " AND VO6.VO6_MODVEI = '" + (cAliasAj)->VV1_MODVEI + "'"
//				cQueryVO6 += " AND VO6.VO6_CODSER LIKE '" + AllTrim((cAliasAj)->VS4_CODSER) + "%'"
//				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryVO6 ), cAliasVO6, .F., .T. )
//				If !(cAliasVO6)->(Eof())
//
//					VS4->(dbGoTo((cALiasAj)->RECVS4))
//					RecLock("VS4",.F.)
//					VS4->VS4_GRUSER := (cAliasVO6)->VO6_GRUSER
//					VS4->VS4_CODSER := (cAliasVO6)->VO6_CODSER
//					VS4->VS4_SERINT := (cAliasVO6)->VO6_SERINT
//					VS4->(MsUnlock())
//
//				EndIf
//				(cAliasVO6)->(dbCloseArea())
//
//				(cAliasAj)->(dbSkip())
//			End
//			(cAliasAj)->(dbCloseArea())
//			dbSelectArea("VS4")
//
//		Next nPos
//
//	End Transaction
//
//	cFilAnt := cBkpFilAnt
//
//Return


/*/{Protheus.doc} OFNJD42INATIVA
Inativa servicos antigos
@author Rubens
@since 02/08/2017
@version 1

@type function
/*/
//Static Function OFNJD42INATIVA()
//
//	Local cBkpFilAnt := cFilAnt
//	Local aProcFil := {}
//	Local oFilHelper := DMS_FilialHelper():New()
//	Local cCodMarca
//	Local nPos
//	Local cAliasAj := "TMPAJ"
//	Local cQuery
//
//	Begin Transaction
//
//		aProcFil := oFilHelper:GetAllFilGrupoEmpresa()
//		For nPos := 1 to Len(aProcFil)
//			cFilAnt := aProcFil[nPos]
//
//			If GetNewPar("MV_MIL0006","") <> "JD"
//				Loop
//			EndIf
//
//			cCodMarca := FMX_RETMAR("JD ")
//			If Empty(cCodMarca)
//				Loop
//			EndIf
//
//			cQuery := "SELECT R_E_C_N_O_ RECVO6 "
//			cQuery +=  " FROM "+RetSQLName("VO6")+" VO6"
//			cQuery += " WHERE VO6.VO6_FILIAL = '" + xFilial("VO6") + "' "
//			cQuery +=   " AND VO6.VO6_CODMAR = '" + cCodMarca + "' "
//			cQuery +=   " AND VO6.VO6_MODVEI = '                 '"
//			cQuery +=   " AND RTRIM(VO6.VO6_CODSER) LIKE '__-___-___'"
//			cQuery +=   " AND VO6.VO6_SERATI = '1' "
//			cQuery +=   " AND VO6.D_E_L_E_T_ = ' ' "
//			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasAj, .F., .T. )
//			dbSelectArea("VO6")
//			While !(cAliasAj)->(Eof())
//
//				VO6->(dbGoTo((cALiasAj)->RECVO6))
//				RecLock("VO6",.F.)
//				VO6->VO6_SERATI := '0'
//				VO6->(MsUnlock())
//
//				(cAliasAj)->(dbSkip())
//			End
//			(cAliasAj)->(dbCloseArea())
//
//			dbSelectArea("VO6")
//
//		Next nPos
//
//	End Transaction
//
//	cFilAnt := cBkpFilAnt
//
//	MsgInfo(STR0025,STR0012) // "Serviços inativados."
//
//Return