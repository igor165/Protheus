#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Ctba161x.ch"

Static cTipoCTS := FWSX3Util():GetFieldType('CTS_COLUNA')
Static __Release  :=  Iif(GetRPORelease() >= "12.1.2210", .T., .F.) 
Static __lCOLUN2   // indica se a coluna CTS_COLUN2 existe
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o      ³ ExcCVF       ³ Autor ³ Totvs               ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o   ³ Exclusao a visao gerencial.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso         ³ CTBA161x                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³20/04/20³          ³Modificacion a CTB161Imp() al momento de  ³±±
±±³            ³        ³          ³hacer la importacion a tabla CVF secomenta³±±
±±³            ³        ³          ³la linea 563, pues CTS_NOME no pertenece  ³±±
±±³            ³        ³          ³a la estructura de la tabla CVF.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ExcCvf(cCodigo)
	ProcRegua(4)

	IncProc()
	IncProc( STR0005 )

	DbSelectArea("CTS")
	DbSetOrder(1)
	CTS->(DbSeek(xFilial()+cCodigo))
	While ! CTS->(Eof()) .AND. xFilial('CTS')==CTS->CTS_FILIAL	.And. CTS->CTS_CODPLA == cCodigo
		RecLock('CTS',.F.)
		DbDelete()
		MsUnLock()
	    DbSkip()
	Enddo

	IncProc( STR0006 )

	DbSelectArea("CVF")
	DbSetOrder(1)
	CVF->(DbSeek(xFilial()+cCodigo))
	While !CVF->(Eof()) .And. xFilial('CVF')==CVF->CVF_FILIAL	.And.CVF->CVF_CODIGO == cCodigo
		RecLock('CVF',.F.)
		DbDelete()
		MsUnLock()

		DbSkip()
	EndDo

	IncProc()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB161Exp ºAutor  ³Microsiga           º Data ³  12/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB161Exp()
Local aEstruCVF	:=	{}
Local aEstruCTS	:=	{}
Local aRet		:=	{}
Local cLin		:=	""
Local aTxt		:=	{}
Local nX,nY


SaveInter()

Ctb161Pos()

If ParamBox({	{6,STR0007,padr("",150),"",,"",90 ,.T.,STR0008,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Estrutura de visao"###"Arquivo .CVE |*.CVE"
		STR0009,@aRet)  //"Exportar para estruturs de visao"

	IF Empty( aRet ) .Or. aRet == Nil
		Alert( "Arquivo nao informado!" )
		Return .F.
	Endif

	Conout( aRet[1] )

	If At('.',aRet[1]) == 0
		aRet[1]	:=	AllTrim(aRet[1])+'.CVE'
	EndIf

	IF File( aRet[1] )
		FErase( aRet[1] )
	Endif

	nHandle := FCreate( aRet[1] )

   	If nHandle <= 0
		For nX := 1 To 5
			MsAguarde( {|| Sleep( 2000 ) },  "Aguarde!" , "Tentando criar o arquivo!") //"Erro na criacao do arquivo!"

			nHandle := FCreate( aRet[1] )

			IF nHandle > 0
				Exit
			Endif
		Next

		If nHandle <= 0
			Alert(STR0023)
			Return
		Endif
	EndIf

	cLin	:=	CVE->CVE_DESCRI +chr(13)+chr(10)
	FWrite(nHandle,cLin,Len(cLin))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exportacao da tabela CVF o identificador 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLin:="1;"
	SX3->(DbSetOrder(2))
	aEstruCVF :=	CVF->(DbStruct())
	For nX:=1 To Len(aEstruCVF)
		If AllTrim(aEstruCVF[nX,1]) != "CVF_SLDENT"
			cLin	+=	aEstruCVF[nX,1]+";"
		EndIf
	Next
	cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)
	FWrite(nHandle,cLin,Len(cLin))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exportacao da tabela CTS o identificador 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLin		:= "2;"
	aEstruCTS	:=	CTS->(DbStruct())
	For nX := 1 To Len( aEstruCTS )
		If AllTrim(aEstruCTS[nX,1]) != "CTS_SLDENT"
			cLin	+=	aEstruCTS[nX,1]+";"
		EndIf
	Next
	cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)
	FWrite(nHandle,cLin,Len(cLin))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exportacao da tabela CVF com identificador 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("CVF")
	DbSetOrder(1)
	DbSeek(xFilial()+CVE->CVE_CODIGO)
	While !Eof() .And. CVE->CVE_CODIGO == CVF->CVF_CODIGO
		AAdd(aTxt,{})
		For nX:=1 To Len(aEstruCVF)
			If AllTrim(aEstruCVF[nX,1]) != "CVF_SLDENT"
				Do Case
					Case aEstruCVF[nX,2] == "C"
						AADd(aTxt[Len(aTxt)],FieldGet(FieldPos(aEstruCVF[nX,1])))
					Case aEstruCVF[nX,2] == "L"
						AADd(aTxt[Len(aTxt)],If(FieldGet(FieldPos(aEstruCVF[nX,1])),"T","F"))
					Case aEstruCVF[nX,2] == "D"
						AADd(aTxt[Len(aTxt)],Dtos(FieldGet(FieldPos(aEstruCVF[nX,1]))))
					Case aEstruCVF[nX,2] == "N"
						AADd(aTxt[Len(aTxt)],Str(FieldGet(FieldPos(aEstruCVF[nX,1]))))
				EndCase
			EndIf
		Next
		DbSkip()
	End
	For nX:= 1 To Len(aTxt)
		cLin	:=	"1;"
		For nY:=1 To Len(aTxt[nX])
			cLin  +=   aTxt[nX,nY]+";"
		Next
		cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)
		FWrite(nHandle,cLin,Len(cLin))
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exportacao da tabela CTS com identificador 2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTxt	:= {}
	DbSelectArea("CTS")
	CTS->( DbSetOrder( 1 ) )
	CTS->( DbSeek( xFilial() + CVE->CVE_CODIGO ) )
	While CTS->( !Eof() ) .And. CTS->CTS_CODPLA == CVE->CVE_CODIGO
		AAdd(aTxt,{})
		For nX:=1 To Len(aEstruCTS)
			If AllTrim(aEstruCTS[nX,1]) != "CTS_SLDENT"
				Do Case
					Case aEstruCTS[nX,2] == "C"
						AADd(aTxt[Len(aTxt)],FieldGet(FieldPos(aEstruCTS[nX,1])))
					Case aEstruCTS[nX,2] == "L"
						AADd(aTxt[Len(aTxt)],If(FieldGet(FieldPos(aEstruCTS[nX,1])),"T","F"))
					Case aEstruCTS[nX,2] == "D"
						AADd(aTxt[Len(aTxt)],Dtos(FieldGet(FieldPos(aEstruCTS[nX,1]))))
					Case aEstruCTS[nX,2] == "N"
						AADd(aTxt[Len(aTxt)],Str(FieldGet(FieldPos(aEstruCTS[nX,1]))))
				EndCase
			EndIf
		Next
		DbSkip()
	End
	For nX:= 1 To Len(aTxt)
		cLin	:=	"2;"
		For nY:=1 To Len(aTxt[nX])
			cLin  +=   aTxt[nX,nY]+";"
		Next
		cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)
		FWrite(nHandle,cLin,Len(cLin))
	Next
	FClose(nHandle)

	Aviso(STR0021,STR0022,{STR0020}) //"Finalizado"###"Exportacao gerada com sucesso" //"Ok"
EndIf

RestInter()

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB161Imp ºAutor  ³Microsiga           º Data ³  12/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB161Imp(lWizard, cRet, cCod, cObserv)
Local aRet			:=	{}
Local aTxtCVF		:=	{}
Local aTxtCTS		:=	{}
Local aCampoCVF		:=	{"CVF_CONTAG","CVF_ORDEM","CVF_CLASSE","CVF_CTASUP","CVF_DESCCG","CVF_NORMAL","CVF_COLUNA","CVF_IDENT"}
Local aCampoCTS		:= {}
Local aPosCVF		:= Array( Len( aCampoCVF ) )
Local aPosCTS		:= {}
Local lIncOnlyCVF	:= .F.
Local lCriaCVF
Local nX,nY
Local cCtaGer, cCtaOrd, cCtaLin, lInclCTS
Local lArqPadrao := .T.
Local nHandle
Local lDETHCG := .T.
Local nLenTxt := 0
Local nBkpMV := MV_PAR01
Local nPosCpo	:= 0
Private nRecCVE

aCampoCTS := CTS->( DbStruct() )
If __lCOLUN2 == NIL
	__lCOLUN2 := Iif( CTS->(FieldPos("CTS_COLUN2")) > 0, .T., .F.)
Endif

//----------------------------------------------------
// Remoção do campo CTS_SLDENT por não possuir uso
// em versao futura, ele será alterado para Não Usado
//----------------------------------------------------
If (nPosCpo  := aScan(aCampoCTS,{ |x| AllTrim(x[1]) == "CTS_SLDENT" })) > 0
	aCampoCTS := ADel(aCampoCTS,nPosCpo)
	aCampoCTS := ASize(aCampoCTS,Len(aCampoCTS)-1)
EndIf

aPosCTS := Array( Len( aCampoCTS ) )

If ValType(lWizard) <> "L"
	lWizard := .F.
Endif

SaveInter()


If lWizard .Or. ParamBox({	{6,STR0007,padr("",150),"",,"", 90 ,.T.,STR0008,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;	 //"Estrutura de visao"###"Arquivo .CVE |*.CVE"
		STR0010,@aRet)  //"Importar estrutura de plano gerencial"

	If lWizard
		AADD(aRet,cRet)
	Endif

	If (nHandle := FT_FUse(AllTrim(aRet[1])))== -1
		Help(" ",1,"NOFILEIMPOR")
		RestInter()
		Return
	EndIf

	FT_FGOTOP()
	cDescri	:=	FT_FREADLN()
	FT_FSKIP()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Importacao da tabela CVF identificador 1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLinha 		:= FT_FREADLN()
	If Left( cLinha, 2 ) == "1;"
		lArqPadrao := .T.
		lIncOnlyCVF	:= .F.
		cLinha := Right( cLinha, Len( cLinha ) -2 )

	ElseIf Left( cLinha, 2 ) == "2;"
		lArqPadrao := .T.
		lIncOnlyCVF	:= .T.
		cLinha := Right( cLinha, Len( cLinha ) -2 )

	Else
		//tratamento para layout antigo sem identificador 1; (CVF) ou 2; (CTS)
		lArqPadrao := .F.
		If Left( cLinha,3 ) == "CTS"
			lIncOnlyCVF	:= .T.
		Else
			lIncOnlyCVF	:= .F.
		EndIf

	EndIf

	If ! lIncOnlyCVF
		nPos	:=	0
		nAt		:=	1
		While nAt > 0
			nPos++
			nAt	:=	AT(";",cLinha)
			If nAt == 0
				cCampo := cLinha
			Else
				cCampo	:=	Substr(cLinha,1,nAt-1)
			EndIf
			nPosCpo	:=	aScan( aCampoCVF, { |x| x == cCampo } )
			If nPosCPO > 0
				aPosCVF[nPosCpo]:= nPos
			Else
				aAdd(aCampoCVF, cCampo)
				aAdd(aPosCVF, Len(aCampoCVF))
			EndIf
			cLinha	:=	Substr(cLinha,nAt+1)
		End

		If (nPosNil:= Ascan(aPosCVF,Nil)) > 0
			Aviso(STR0011,STR0012+aCampoCVF[nPosNil]+STR0013,{STR0014}) //"Estrutura incorreta."###"O campo "###" nao foi achado na estrutura, por favor verificar."###"Sair"
			FT_FUSE()
			FCLOSE(nHandle)
			RestInter()
			Return .F.
		EndIf

		FT_FSKIP()
		cLinha 		:= FT_FREADLN()
		If lArqPadrao
			cLinha := Right( cLinha, Len( cLinha ) -2 )
		EndIf

	EndIf

	If lArqPadrao .OR. (!lArqPadrao .And. lIncOnlyCVF)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Importacao da tabela CTS identificador 2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPos	:=	0
		nAt	:=	1
		While nAt > 0
			nPos++
			nAt	:=	AT(";",cLinha)
			If nAt == 0
				cCampo := cLinha
			Else
				cCampo	:=	Substr(cLinha,1,nAt-1)
			EndIf
			nPosCpo	:=	aScan( aCampoCTS, { |x| x[1] == cCampo } )
			If nPosCPO > 0
				aPosCTS[nPosCpo]:= nPos
			EndIf
			cLinha	:=	Substr(cLinha,nAt+1)
		End

		If ( nPosNil := aScan( aPosCTS, Nil ) ) > 0
			If !MsgNoYes(STR0012+aCampoCTS[nPosNil][1]+STR0013+STR0047,STR0011) //"O campo "###" nao foi achado na estrutura, por favor verificar."###" Deseja continuar?"###"Estrutura incorreta."
				FT_FUSE()
				FCLOSE(nHandle)
				RestInter()
				Return .F.
			Else
				aEval(aPosCTS,{ |aArrPos| Iif((nPosNil := aScan( aPosCTS, Nil ))>0,aPosCTS[nPosNil] := 0,)})

			EndIf
		EndIf

		FT_FSKIP()
	EndIf

	While !FT_FEOF()

		cLinha := FT_FREADLN()

		If lArqPadrao .And. Left( cLinha, 2 ) == "1;"

			cLinha := Right( cLinha, Len( cLinha ) -2 )
			AADD(aTxtCVF,{})
			nCampo := 1
			While At(";",cLinha)>0
				aAdd(aTxtCVF[Len(aTxtCVF)],Substr(cLinha,1,At(";",cLinha)-1))
				nCampo ++
				cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
			End
			If Len(AllTrim(cLinha)) > 0
				aAdd(aTxtCVF[Len(aTxtCVF)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
			Else
				aAdd(aTxtCVF[Len(aTxtCVF)],"")
			EndIf

		ElseIf lArqPadrao .And. Left( cLinha, 2 ) == "2;"

			cLinha := Right( cLinha, Len( cLinha ) -2 )
			AADD(aTxtCTS,{})
			nCampo := 1
			While At(";",cLinha)> 0
				aAdd(aTxtCTS[Len(aTxtCTS)],Substr(cLinha,1,At(";",cLinha)-1))
				nCampo ++
				cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
			End
			If Len(AllTrim(cLinha)) > 0
				aAdd(aTxtCTS[Len(aTxtCTS)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
			Else
				aAdd(aTxtCTS[Len(aTxtCTS)],"")
			EndIf

        ElseIf !lArqPadrao .And. lIncOnlyCVF

			AADD(aTxtCTS,{})
			nCampo := 1
			While At(";",cLinha)>0
				aAdd(aTxtCTS[Len(aTxtCTS)],Substr(cLinha,1,At(";",cLinha)-1))
				nCampo ++
				cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
			End
			If Len(AllTrim(cLinha)) > 0
				aAdd(aTxtCTS[Len(aTxtCTS)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
			Else
				aAdd(aTxtCTS[Len(aTxtCTS)],"")
			EndIf

        ElseIf !lArqPadrao .And. !lIncOnlyCVF

			AADD(aTxtCVF,{})
			nCampo := 1
			While At(";",cLinha)>0
				aAdd(aTxtCVF[Len(aTxtCVF)],Substr(cLinha,1,At(";",cLinha)-1))
				nCampo ++
				cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
			End
			If Len(AllTrim(cLinha)) > 0
				aAdd(aTxtCVF[Len(aTxtCVF)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
			Else
				aAdd(aTxtCVF[Len(aTxtCVF)],"")
			EndIf

		EndIf

		FT_FSKIP()
	End
	FT_FUSE()

	DbSelectArea( "CVE" )
   	If lWizard .or. AxInclui(Alias(),,3,/*aAcho*/,/*cFunc*/,/*aCpos*/,/*cTudoOk*/,/*lF3*/,"CTB161GRV"/*cTransact*/,/*aButtons*/,{ {|| M->CVE_DESCRI := cDescri},{|| .t. },{||},{||}}/*aParam*/) == 1

		If lWizard
	   		Reclock("CVE",.T.)
		    Ctb161Grv()
			CVE->CVE_FILIAL	:= xFilial()
			CVE->CVE_DESCRI	:= cDescri
			CVE->CVE_CODIGO	:= cCod
			CVE->CVE_OBS	:= cObserv
		Endif
		DbSelectArea( "CVE" )
    	dbGoto(nRecCVE)

		If ! lIncOnlyCVF
				For nX:=1 To Len(aTxtCVF)
					RecLock("CVF",.T.)
					Replace CVF_FILIAL	With xFilial()
					Replace CVF_CODIGO	With CVE->CVE_CODIGO
					For nY:=1 To Len(aCampoCVF)
						If !( Alltrim(Upper(aCampoCVF[nY])) $ "CVF_FILIAL|CVF_CODIGO" ) .AND. CVF->(FieldPos(Upper(aCampoCVF[nY]))) > 0
							FieldPut(FieldPos(aCampoCVF[nY]),aTxtCVF[nX,aPosCVF[nY]])
						EndIf
					Next
					CVF->(MsUnLock())
				Next
		EndIf

		For nX:=1 To Len(aTxtCTS)
			 lInclCTS :=.T.
			//somente pode appendar se CTS nao existir na base -- validar conta gerencial + ordem + linha
			nPosCpo	:=	aScan( aCampoCTS, { |x| x[1] =="CTS_CONTAG" } )
			If nPosCpo > 0
				cCtaGer := PadR( aTxtCTS[nX,nPosCpo], Len(CTS->CTS_CONTAG))
				nPosCpo	:=	aScan( aCampoCTS, { |x| x[1] =="CTS_ORDEM"} )
				If nPosCpo > 0
					cCtaOrd := PadR( aTxtCTS[nX,nPosCpo], Len(CTS->CTS_ORDEM))
					nPosCpo	:=	aScan( aCampoCTS, { |x| x[1] =="CTS_LINHA" } )
					If nPosCpo > 0
						cCtaLin := PadR( aTxtCTS[nX,nPosCpo], Len(CTS->CTS_LINHA))
						//aqui valida para verificar se ja nao existe na tabela CTS
						dbSelectArea("CTS")
						dbSetOrder(2)
						dbSeek(xFilial("CTS")+CVE->CVE_CODIGO+cCtaGer)
						While CTS->(! Eof() .And. CTS_FILIAL+CTS_CODPLA+CTS_CONTAG == xFilial("CTS")+CVE->CVE_CODIGO+cCtaGer)
							If CTS->(CTS_ORDEM+CTS_LINHA) == cCtaOrd+cCtaLin
								// se ja existe  conta gerencial na tabela CTS entao despreza a linhar
								lInclCTS := .F.
							EndIf
							dbSelectArea("CTS")
							dbSkip()
						EndDo
					Else
						// se nao achou campo conta gerencial entao despreza a linha, pois nao tem como validar
						lInclCTS := .F.
					EndIf
				Else
					// se nao achou campo conta gerencial entao despreza a linha, pois nao tem como validar
					lInclCTS := .F.
				EndIf
			Else
				// se nao achou campo conta gerencial entao despreza a linha, pois nao tem como validar
				lInclCTS := .F.
			EndIf
			If lInclCTS
				nLenTxt := Len( aTxtCTS[nX] )
				RecLock("CTS",.T.)
				For nY:=1 To Len(aCampoCTS)
					If aPosCTS[nY] > 0 .And. nLenTxt >= nY .AND. aTxtCTS[nX,aPosCTS[nY]] <> Nil .AND. CTS->(FieldPos(aCampoCTS[nY][1])) > 0
						Do Case
						Case aCampoCTS[nY][2] == "C"
							FieldPut(FieldPos(aCampoCTS[nY][1]),aTxtCTS[nX,aPosCTS[nY]])
						Case aCampoCTS[nY][2] == "L"
							FieldPut(FieldPos(aCampoCTS[nY][1]), IIf( aTxtCTS[nX,aPosCTS[nY]], "T", "F" ) )
						Case aCampoCTS[nY][2] == "D"
							FieldPut(FieldPos(aCampoCTS[nY][1]),StoD( aTxtCTS[ nX, aPosCTS[nY] ] ) )
						Case aCampoCTS[nY][2] == "N"
							FieldPut(FieldPos(aCampoCTS[nY][1]), Val( aTxtCTS[nX,aPosCTS[nY]] ) )
						EndCase
					EndIf
				Next

				Replace CTS_FILIAL	With xFilial()
				Replace CTS_CODPLA	With CVE->CVE_CODIGO
				Replace CTS_NOME	With CVE->CVE_DESCRI

				CTS->(MsUnLock())
			EndIf
		Next

		If lIncOnlyCVF
			//se nao importado arquivo CVF entao monta ele a partir do CTS
			dbSelectArea("CVF")
			DbSetOrder( 1 )
			dbSelectArea("CTS")
			dbSetOrder(2)
			dbSeek(xFilial("CTS")+CVE->CVE_CODIGO)

			While CTS->(! Eof() .And. CTS_FILIAL+CTS_CODPLA == xFilial("CTS")+CVE->CVE_CODIGO)

				dbSelectArea("CVF")
				lCriaCVF := CVF->( !DbSeek( xFilial( "CVF" ) + CTS->CTS_CODPLA + CTS->CTS_CONTAG ) )
				If lCriaCVF
					RecLock( "CVF", .T. )
					Replace CVF_FILIAL With xFilial()
					Replace CVF_CODIGO With CTS->CTS_CODPLA
					Replace CVF_CONTAG With CTS->CTS_CONTAG
					Replace CVF_DESCCG With CTS->CTS_DESCCG
					Replace CVF_ORDEM 	With CTS->CTS_ORDEM
					Replace CVF_CTASUP	With CTS->CTS_CTASUP
					Replace CVF_CLASSE	With CTS->CTS_CLASSE
					Replace CVF_NORMAL	With CTS->CTS_NORMAL
					If lDETHCG
						Replace CVF_DETHCG	With CTS->CTS_DETHCG
					EndIf
					If __Release .and. __lCOLUN2
						Replace CVF_COLUNA	With CTS->CTS_COLUN2
					Else
						Replace CVF_COLUNA With GetCTSCol(CTS->CTS_COLUNA,'C',"CVF")
					EndIf
					Replace CVF_IDENT	WITH CTS->CTS_IDENT
					MsUnlock()
				EndIf

				dbSelectArea("CTS")
				dbSkip()

			EndDo

		Else

			//se importou apenas o CVF entao monta o CTS a partir do cvf
			If Empty(aTxtCTS) .And. ! Empty(aTxtCVF)

				dbSelectArea("CVF")
				DbSetOrder( 1 )
				dbSelectArea("CTS")
				dbSetOrder(2)

				dbSelectArea("CVF")
				dbSeek(xFilial("CVF")+CVE->CVE_CODIGO)

				While CVF->(! Eof() .And. CVF_FILIAL+CVF_CODIGO == xFilial("CVF")+CVE->CVE_CODIGO)

					dbSelectArea("CTS")
					lCriaCTS := !DbSeek( xFilial( "CTS" ) + CVF->CVF_CODIGO + CVF->CVF_CONTAG )
					If lCriaCTS
						RecLock( "CTS", .T. )
						Replace CTS_FILIAL With xFilial()
						Replace CTS_CODPLA With CVF->CVF_CODIGO
						Replace CTS_CONTAG With CVF->CVF_CONTAG
						Replace CTS_DESCCG With CVF->CVF_DESCCG
						If lDETHCG
							Replace CTS_DETHCG With CVF->CVF_DETHCG
						EndIf
						Replace CTS_ORDEM 	With CVF->CVF_ORDEM
						Replace CTS_CTASUP	With CVF->CVF_CTASUP
						Replace CTS_CLASSE	With CVF->CVF_CLASSE
						Replace CTS_NORMAL	With CVF->CVF_NORMAL
						If __Release .and. __lCOLUN2
							Replace CTS_COLUN2	With CVF->CVF_COLUNA
						Else
							Replace CTS_COLUNA With GetCTSCol(CVF->CVF_COLUNA,cTipoCTS) 
						Endif
						Replace CTS_LINHA	With StrZero(1, Len(CTS->CTS_LINHA))
						Replace CTS_IDENT	WITH CVF->CVF_IDENT
						Replace CTS_NOME	With CVE->CVE_DESCRI
						MsUnlock()
					Else
						// se encotrou  CTS tem que validar conta  gerencia+ordem + linha
						 lInclCTS :=.T.
						//somente pode appendar se CTS nao existir na base -- validar conta gerencial + ordem + linha
						cCtaGer := PadR( CVF->CVF_CONTAG, Len(CTS->CTS_CONTAG))
						cCtaOrd := PadR( CVF->CVF_ORDEM, Len(CTS->CTS_ORDEM))
						cCtaLin := StrZero( 1, Len(CTS->CTS_LINHA))
						//aqui valida para verificar se ja nao existe na tabela CTS
						dbSelectArea("CTS")
						dbSetOrder(2)
						dbSeek(xFilial("CTS")+CVE->CVE_CODIGO+cCtaGer)
						While CTS->(! Eof() .And. CTS_FILIAL+CTS_CODPLA+CTS_CONTAG == xFilial("CTS")+CVE->CVE_CODIGO+cCtaGer)
							If CTS->(CTS_ORDEM+CTS_LINHA) == cCtaOrd+cCtaLin
								// se ja existe  conta gerencial na tabela CTS entao despreza a linhar
								lInclCTS := .F.
								Exit
							EndIf
							dbSelectArea("CTS")
							dbSkip()
						EndDo
						If lInclCTS
							RecLock("CTS",.T.)
							Replace CTS_FILIAL With xFilial()
							Replace CTS_CODPLA With CVF->CVF_CODIGO
							Replace CTS_CONTAG With CVF->CVF_CONTAG
							Replace CTS_DESCCG With CVF->CVF_DESCCG
							If lDETHCG
								Replace CTS_DETHCG With CVF->CVF_DETHCG
							EndIf
							Replace CTS_ORDEM 	With CVF->CVF_ORDEM
							Replace CTS_CTASUP	With CVF->CVF_CTASUP
							Replace CTS_CLASSE	With CVF->CVF_CLASSE
							Replace CTS_NORMAL	With CVF->CVF_NORMAL
							If __Release .and. __lCOLUN2
								Replace CTS_COLUN2	With CVF->CVF_COLUNA
							Else
								Replace CTS_COLUNA With GetCTSCol(CVF->CVF_COLUNA,cTipoCTS)
							EndIf
							Replace CTS_LINHA	With StrZero(1, Len(CTS->CTS_LINHA))
							Replace CTS_IDENT	WITH CVF->CVF_IDENT
					  		Replace CTS_NOME	With CVE->CVE_DESCRI
							MsUnlock()
						EndIf

					EndIf

					dbSelectArea("CVF")
					dbSkip()

				EndDo


			EndIf

		EndIf

  		If !lWizard .And. ! Ctb161Check()    //verifica se existe CTS sem CVF ou vice-versa
			Aviso(STR0015,STR0016+" - "+STR0033,{"Ok"}) //"Finalizado"##"Importacao finalizada com sucesso" ##"Inconsistencia na estrutura da visão gerencial. "
		Else
			nOpcAviso := 1
			MV_PAR01 := nBkpMV
			If ! lWizard
				//Só mostra o botão editar se o país for diferente de Rep. Dom ou Equador. Se for tradicional, ao editar só aparece o último regsitro
				If !(cPaisLoc $ "DOM|EQU")
					nOpcAviso := Aviso(STR0015,STR0016,{STR0017,STR0019,STR0018}) //"Importacao finalizada com sucesso" //"Finalizado"###"Fechar" //"Visualizar"###"Editar"
				Else
					nOpcAviso := Aviso(STR0015,STR0016,{STR0017,STR0019}) //"Importacao finalizada com sucesso" //"Finalizado"###"Fechar" //"Visualizar"
				EndIf

				If MV_PAR06 == 2
					DbSelectArea("CVE")
					CVE->( DbSetOrder(1) )
					CVE->( DbSeek( xFilial( "CVE" )+CVE->CVE_CODIGO) )

					DbSelectArea("CTS")
					CTS->( DbSetOrder(1) )
					CTS->( DbSeek( xFilial( "CTS" ) + CVE->CVE_CODIGO ) )

					If nOpcAviso == 2
						Ctb161Cad("CVE",CVE->(Recno()),2)
					ElseIf nOpcAviso == 3
						Ctb161Cad("CVE",CVE->(Recno()),4)
					EndIf
				Else
					If nOpcAviso == 2
						Ctb160Cad( ,, 2, .F. )
					ElseIf nOpcAviso == 3
						Ctb160Cad( ,, 4, .F. )
					EndIf
				EndIf
			Endif
        EndIf
	EndIf
   MBrChgLoop(.F.)
EndIf
FCLOSE(nHandle)
RestInter()
 Asize(aCampoCTS, 0 )
 aCampoCTS := NIL
Asize(aCampoCVF, 0 )
 aCampoCVF := NIL
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fVldFormula  ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ valida formula                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fVldFormula()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function C161VldFormula(cExpr)
	Local lReturn	:= .F.
	Local oError	:= ErrorBlock( {|e| C161ErrFormula( e ) } )

	If !Empty( cExpr )
		Begin Sequence

		&( AllTrim( cExpr ) )
		Return .T.

		End Sequence
	Else
		lReturn := .T.
	EndIf

	ErrorBlock( oError )
Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fErrFormula  ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ trata erro de formula                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fErrFormula()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C161ErrFormula(e)
	Local cMessage := e:Description

	MsgAlert( cMessage, STR0024 ) //"Erro"
	Break
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CheckForm   		³ Autor ³ Davi Torchio   ³ Data ³ 01/12/07          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  funcao  CheckForm ()				                    			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CheckForm()
Local aArea		:= GetArea()
Local aAreaCVE	:= CVE->( GetArea() )
Local aAreaCVF	:= CVF->( GetArea() )
Local aAreaCTS	:= CTS->( GetArea() )
Local nOpca		:= 1

If (CTS->(DbSeek(xFilial())) .And. !CVE->(DbSeek(xFilial())) )
	nOpca := CTB161CTS()
EndIf

RestArea( aArea )
RestArea( aAreaCVE )
RestArea( aAreaCVF )
RestArea( aAreaCTS )

Return nOpca == 1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTB161Imp  ºAutor  ³Microsiga           º Data ³  12/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializa os campos logicos da tabeka CVF                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION CTB161CTS()
Local aSays		:=	{}
Local aButtons	:=	{}
Local nOpca	:=	0

AADD (aSays, STR0025) //"Foram detectadas Visoes Gerencias nao convertidas."
AADD (aSays, STR0026) //"Para dar manutencao estas deverao ser convertidas para o novo formato."
AADD (aSays, STR0027) //"Este programa tem como objetivo importar as estruturas das Visoes gerenciais para o  "
AADD (aSays, STR0028) //"novo formato."
AADD (aSays, STR0029) //"O novo formato visa facilitar a construcao e manutencao das Visoes, mantendo as mesmas"
AADD (aSays, STR0030) //"funcionalidades da versao anterior."
AADD (aSays, "")

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( STR0031, aSays, aButtons)//,, oMainWnd:nClientHeight-260, oMainWnd:nClientWidth-360) //"Conversao de Visoes"

If  nOpca==1
	DbSelectArea("CTS")
	DbSetOrder(2)
	DbSeek(xFilial())
	cChave1	:=	""
	cChave2	:=	""
	While !EOF()  .And. xFilial() == CTS_FILIAL
		If cChave1 <> CTS->CTS_CODPLA
			RecLock('CVE',.T.)
			Replace CVE_FILIAL With xFilial()
			Replace CVE_CODIGO With CTS->CTS_CODPLA
			Replace CVE_DESCRI With CTS->CTS_NOME
			MsUnlock()
			cChave1	:=	CTS->CTS_CODPLA
		Endif
		If cChave2 <> CTS->(CTS_CODPLA+CTS_CONTAG)
			RecLock('CVF',.T.)
			Replace CVF_FILIAL With xFilial()
			Replace CVF_CODIGO With CTS->CTS_CODPLA
			Replace CVF_CONTAG With CTS->CTS_CONTAG
			Replace CVF_DESCCG With CTS->CTS_DESCCG
			Replace CVF_ORDEM 	With CTS->CTS_ORDEM
			Replace CVF_CTASUP	With CTS->CTS_CTASUP
			Replace CVF_CLASSE	With CTS->CTS_CLASSE
			Replace CVF_NORMAL	With CTS->CTS_NORMAL
			Replace CVF_DESCCG	With CTS->CTS_DESCCG
			If __Release .and. __lCOLUN2
				Replace CVF_COLUNA	With CTS->CTS_COLUN2
			Else
				Replace CVF_COLUNA With GetCTSCol(CTS->CTS_COLUNA,'C',"CVF") 
			Endif
			Replace CVF_IDENT	WITH CTS->CTS_IDENT
			MsUnlock()
			cChave2	:=	CTS->(CTS_CODPLA+CTS_CONTAG)
		Endif
		CTS->(DbSkip())
		DbSelectArea("CTS")
	Enddo
Endif

Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb161Del    ³ Autor ³ Totvs             ³ Data ³ 22/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui a visao gerencial.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA161x                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Del( cAlias, nReg, nOpc, lArvore )
Local nOpcA		:= 0
Local nAviso 	:= 0
Local aParam	:=	{ {|| Nil}, {|| Aviso(STR0001,STR0002,{STR0003,STR0004}) == 1 },{|| Processa({||ExcCvf(CTS->CTS_CODPLA)})},{|| Nil}}
Local cChave	:= CTS->( CTS_CODPLA + CTS_ORDEM )
Local cCodigo	:= CTS->CTS_CODPLA
Local aCpos		:= {}
Local cContag	:= CTS->CTS_CONTAG
Local aAreaCTS	:= {}
Local lRet		:= .T.

Default lArvore:= .F.

If !CheckForm()
	Return .F.
Endif

Ctb161Pos()

//Valida a existencia de entidade inferior na estrutura. Se houver dependecia a entidade não poderá ser excluída
If CTS->CTS_CLASSE == "1" .and. !lArvore	//Sintética
	aAreaCTS := CTS->(GetArea())

	dbSelectArea("CTS")
	dbSetOrder(3)		//CTS_FILIAL+CTS_CODPLA+CTS_CTASUP

	If CTS->(MsSeek(xFilial("CTS")+cCodigo+cContag))
		lRet := .F.
		Help("",1,"CTB161DEL",,STR0046,1,0)		//"Não é possível excluir entidades superiores, pois existe entidade inferior dependente desta."
	EndIf

	RestArea(aAreaCTS)
EndIf

If lRet
	Begin Transaction

	If lArvore
		AxDeleta( "CVE", CVE->( Recno() ), nOpc, /*cTransact*/,/*aCpos*/,/*aButtons*/, aParam, /*aAuto*/,/*lMaximized*/ )
	Else

		aCpos:= Ctb160aCpo("CTS",.F.,"")
		nOpcA := AxDeleta( "CTS", CTS->( Recno() ), nOpc, , aCpos )
		If nOpcA == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³se nao houver CTS exclui todos os registros das tabelas³
			//³CVF e CVE correspondentes.                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea( "CTS" )
			CTS->( DbSetOrder( 1 ) )
			If CTS->( !DbSeek( xFilial( "CTS" ) + cCodigo ) )
				Processa( { || ExcCvf( cCodigo ) } )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³exclui o CVF correspondente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea( "CVE" )
				CVE->( DbSetOrder( 1 ) )
				If CVE->( DbSeek( xFilial( "CVE" ) + cCodigo ) )
					RecLock( "CVE" )
					CVE->( DbDelete() )
					MsUnLock()
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³exclui o CVF correspondente³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea( "CVF" )
				CVF->( DbSetOrder( 4 ) )
				If CVF->( DbSeek( xFilial( "CVF" ) + cChave ) )
					RecLock( "CVF" )
					CVF->( DbDelete() )
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf

	End Transaction

	If (lArvore)
		//Ponto de Entrada ao Final, após fechar o Dialog
		If ExistBlock("CT161FIM")
			ExecBlock("CT161FIM",.F.,.F., {05, cCodigo})
		EndIf
	EndIf
EndIf

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb160Cbc³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 09/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Classe e condicao normal da conta co cabecalho      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb160Cbc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡„o do SX3 do Campo CVF_Conta                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Cbc()

Local lRet := .T.

If lRet .And. Empty(M->CVF_CODIGO)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CVF_CODIGO")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CVF_ORDEM)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CVF_ORDEM")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CVF_CONTAG)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CVF_CONTAG")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CVF_DESCCG)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CVF_DESCCG")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CVF_NOME)
	Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle("CVF_NOME")),3,1)
	lRet := .f.
EndIf

If lRet .And. Empty(M->CVF_CLASSE) .And. !(cIdent $ "3/4/5/6" .Or. SubStr(M->CVF_DESCCG,1,1) = "-")
	Help("  ", 1, "EMPTYCLASS")
	lRet := .f.
EndIf

If lRet .And. Empty(M->CVF_NORMAL) .And. !(cIdent $ "5/6" .Or. SubStr(M->CVF_DESCCG,1,1) = "-")
	Help("  ", 1, "EMPTYCOND")
	lRet := .f.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb160Ent ³ Autor ³ Simone Mie Sato       ³ Data ³ 21.08.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo da entidade.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Sup()

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := CVF->(GetArea())

If !Empty(M->CVF_CONTAG)
	dbSelectArea("CVF")
	dbSetOrder(1)

	//A conta deve existir no Plano de Contas.
	IF !Empty(M->CVF_CTASUP)

		If !MsSeek(xFilial("CVF")+M->CVF_CODIGO+M->CVF_CTASUP)
			Help("  ", 1, "NOCADCTASU")
			lRet := .F.
        Endif

		//A conta superior deve ser sintetica.
		If lRet .And. CVF->CVF_CLASSE != "1"
			Help(" ",1,"NOCLASSESI")
			lRet := .F.
		Endif
	EndIf
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb160Ent³ Autor ³ Felipe Aurelio de Melo³ Data ³ 09.10.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o codigo da entidade.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Ent(lInclui)

Local lRet	:= .T.
Local cAlias  := Alias()
Local aArea   := CVF->(GetArea())

If !Empty(M->CVF_CONTAG) .And. lInclui
	lRet	:= ExistChav("CVF",M->CVF_CODIGO+M->CVF_CONTAG,2,)
Endif

RestArea(aArea)
DbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB160Ord ³ Autor ³ Simone Mie Sato       ³ Data ³ 17.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche com zeros a esquerda o campo ordem do Pl.Gerencial³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Plano de Contas Gerencial                ³±±
±±³          ³ ExpN1 = Ordem no Plano                                     ³±±
±±³          ³ ExpN2 = Opcao do Menu                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Ord(lInclui)

Local lRet    := .T.
Local cAlias  := Alias()
Local aArea   := CVF->(GetArea())
Local cFilCVF := xFilial("CVF")
Local nIncrementa := MV_PAR01

If lInclui
	If nIncrementa  > 0 .And. Empty(M->CVF_ORDEM)
		dbSelectArea("CVF")
		dbSetOrder(1)

		If MsSeek(cFilCVF+M->CVF_CODIGO, .F.)
			While CVF->(!Eof()) .and. CVF->CVF_FILIAL == cFilCVF .and. CVF->CVF_CODIGO == M->CVF_CODIGO
				CVF->(dbSkip())
				If CVF->CVF_FILIAL <> cFilCVF .or. CVF->CVF_CODIGO <> M->CVF_CODIGO
					dbSkip(-1)
					M->CVF_ORDEM := StrZero(Val(CVF->CVF_ORDEM) + nIncrementa,Len(M->CVF_ORDEM))
					dbSkip()
				EndIf
			EndDo
		Else
			M->CVF_ORDEM := StrZero(1,Len(M->CVF_ORDEM))
		Endif

		RestArea(aArea)
		DbSelectArea(cAlias)
	Else
		M->CVF_ORDEM := If(!Empty(M->CVF_ORDEM),StrZero(Val(M->CVF_ORDEM),Len(M->CVF_ORDEM)),M->CVF_ORDEM)
	Endif
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb161Mov ³ Autor ³ Totvs                 ³ Data ³ 28/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem a ordem proxima ordem de um determinado lcto padrao. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Recno do CVF que vai ser manipulado                ³±±
±±³          ³ ExpN2 = operacao de ordem. 1=Nivel acima;2=Nivel abaixo    ³±±
±±³          ³ ExpL1 = se completa com zeros a esquerda                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Mov( nRecCVF, nOper, lZero )
	Local cCodPla		:= ""
	Local cNewOrd		:= ""
	Local cAtuOrd		:= ""
	Local nTamZero		:= TamSX3( "CTS_ORDEM" )[1]
	Local nOrdem		:= 1
	Local nRecCTS		:= 0

	Default nOper 		:= 2
	Default lZero		:= .T.

	Begin Transaction

	DbSelectArea( "CVF" )
	CVF->( DbSetOrder( 1 ) )
	CVF->( DbGoTo( nRecCVF ) )
	If CVF->( !Eof() )
		DbSelectArea( "CTS" )
		CTS->( DbSetOrder( 2 ) )
		If CTS->( DbSeek( xFilial( "CTS" ) + CVF->CVF_CODIGO + CVF->CVF_CONTAG ) )
			cAtuOrd 	:= CTS->CTS_CONTAG
			cCodPla		:= CTS->CTS_CODPLA
			nRecCTS		:= CTS->( RecNo() )
			nOrdem		:= Val( cAtuOrd )
			nTamZero	:= Len( AllTrim( CTS->CTS_CONTAG ) )

			// Obtem a nova ordem
			If nOper == 1
				nOrdem--
			Else
				nOrdem++
			EndIf

			cNewOrd		:= StrZero( nOrdem, IIf( lZero, nTamZero, 0 ) )

			// Grava ordem qualquer para realizar a troca sem duplicidade
			RecLock( "CTS" )
			CTS->CTS_CONTAG := "*" + StrZero( nRecCTS, IIf( lZero, nTamZero-1, 0 ) )
			MsUnLock()

			RecLock( "CVF" )
			CVF->CVF_CONTAG := "*" + StrZero( nRecCVF, IIf( lZero, nTamZero-1, 0 ) )
			MsUnLock()

			// Se ja existe ordem anterior, troca as ordens dos lancamentos
			If CTS->( DbSeek( xFilial( "CTS" ) + cCodPla + cNewOrd ) )
				RecLock( "CTS" )
				CTS->CTS_CONTAG := cAtuOrd
				MsUnLock()
			EndIf

			If CVF->( DbSeek( xFilial( "CVF" ) + cCodPla + cNewOrd ) )
				RecLock( "CVF" )
				CVF->CVF_CONTAG := cAtuOrd
				MsUnLock()
			EndIf

			// Grava a nova ordem
			CTS->( DbGoTo( nRecCTS ) )
			CVF->( DbGoTo( nRecCVF ) )

			RecLock( "CTS" )
			CTS->CTS_CONTAG := cNewOrd
			MsUnLock()

			RecLock( "CVF" )
			CVF->CVF_CONTAG := cNewOrd
			MsUnLock()
		EndIf
	EndIf

	End Transaction
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb161Pos ³ Autor ³ Totvs                 ³ Data ³ 22/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Posiciona o CVE/CTS                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb161Pos()
	If cAliasBrw == "CVE" 		// Cabecalho
		DbSelectArea( "CTS" )
		CTS->( DbSetOrder( 1 ) )
		CTS->( DbSeek( xFilial( "CTS" ) + CVE->CVE_CODIGO ) )

		DbSelectArea( "CVF" )
		CVF->( DbSetOrder( 1 ) )
		CVF->( DbSeek( xFilial( "CVF" ) + CVE->CVE_CODIGO ) )
	ElseIf cAliasBrw == "CTS"	// Itens
		DbSelectArea( "CVE" )
		CVE->( DbSetOrder( 1 ) )
		CVE->( DbSeek( xFilial( "CVE" ) + CTS->CTS_CODPLA ) )

		DbSelectArea( "CVF" )
		CVF->( DbSetOrder( 1 ) )
		CVF->( DbSeek( xFilial( "CVF" ) + CTS->CTS_CODPLA ) )
	EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CT160VlCkBx ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ valida e carrega checkbox                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fVldCkBx()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CT160VlCkBx(nTipo,nOpc,cSelecao)

Default cSelecao := ""

Do Case
	//Tratamento para inicializar variaveis
	Case nTipo = 1
		Do Case
			Case cIdent $ "1/2" //Soma/Subtrai
				//Selecao
				lNegrito      := .F.
				lTotal        := .F.
				lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .F.
				lVldTotal     := .F.
				lVldSeparador := .F.
				lVldTraco     := .F.

			Case cIdent = "3" //Negrito
				//Selecao
				lNegrito      := .T.
				lTotal        := .F.
				lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .T.
				lVldSeparador := .T.
				lVldTraco     := .T.

			Case cIdent = "4" //Total Geral/Negrito
				//Selecao
				lNegrito      := .T.
				lTotal        := .T.
				lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .T.
				lVldSeparador := .F.
				lVldTraco     := .F.

			Case cIdent = "5" //Linha sem valor
				//Selecao
				lNegrito      := .F.
				lTotal        := .F.
				lSeparador    := .T.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .F.
				lVldSeparador := .T.
				lVldTraco     := .F.

			Case cIdent = "6" //Linha sem valor/Negrito
				//Selecao
				lNegrito      := .T.
				lTotal        := .F.
				lSeparador    := .T.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .F.
				lVldSeparador := .T.
				lVldTraco     := .F.

			Case cIdent = "7" //Separador
				//Selecao
				lNegrito      := .F.
				lTotal        := .F.
				lSeparador    := .F.
				lTraco        := .T.
				//Permitir edicao
				lVldNegrito   := .F.
				lVldTotal     := .F.
				lVldSeparador := .F.
				lVldTraco     := .T.

			Otherwise
				//Selecao
				//lNegrito      := .F.
				//lTotal        := .F.
				//lSeparador    := .F.
				lTraco        := .F.
				//Permitir edicao
				lVldNegrito   := .T.
				lVldTotal     := .T.
				lVldSeparador := .T.
				lVldTraco     := .T.
		EndCase
		If !Empty(cSelecao)
			oGet01:Refresh()
			oGet02:Refresh()
			oGet03:Refresh()
			oGet04:Refresh()
		EndIf

	//Tratamento para validar selecao
	Case nTipo = 2
		Do Case
			Case lNegrito .And.  lTotal .And. !lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Disable()/*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Disable()/*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "4"

			Case !lNegrito .And.  lTotal .And. !lSeparador .And. !lTraco
					//Forca selecao do negrito quando total
					lNegrito      := .T.
					//Permitir edicao
					oGet01:Disable()/*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Disable()/*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "4"

			Case lNegrito .And.  !lTotal .And. lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Disable()/*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "6"

			Case !lNegrito .And.  !lTotal .And. lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Disable()/*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "5"

			Case 	lTraco
					lNegrito := .F.
					lTotal := .F.
					lSeparador := .F.
					//Permitir edicao somente do traco
					oGet01:Disable()/*"Negrito"        */
					oGet02:Disable()/*"Total Geral"    */
					oGet03:Disable()/*"Linha sem Valor"*/
					oGet04:Enable() /*"Separador"      */
					cIdent := "7"

					If Inclui
						M->CTS_DESCCG := PadR("-",Len(CTS->CTS_DESCCG))
					Else
						If Empty(M->CTS_DESCCG) .OR. Alltrim(M->CTS_DESCCG)=="-" .OR. Aviso(STR0032, STR0043, {STR0044, STR0045})==1  //"Atencao"##"Sobrepor descricao da conta por (-)traco."##"Sim"##"Nao"
							M->CTS_DESCCG := PadR("-",Len(CTS->CTS_DESCCG))
						Else
							lTraco := .F.
							//Permitir edicao
							oGet01:Enable() /*"Negrito"        */
							oGet02:Enable() /*"Total Geral"    */
							oGet03:Enable() /*"Linha sem Valor"*/
							oGet04:Enable() /*"Separador"      */
							cIdent := " "
						EndIf
					EndIf

			Case 	lNegrito .And. !lTotal .And. !lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Disable()/*"Separador"      */
					cIdent := "3"

			Case 	!lNegrito .And. !lTotal .And. !lSeparador .And. !lTraco
					//Permitir edicao
					oGet01:Enable() /*"Negrito"        */
					oGet02:Enable() /*"Total Geral"    */
					oGet03:Enable() /*"Linha sem Valor"*/
					oGet04:Enable() /*"Separador"      */
					cIdent := " "
		EndCase
		oGet01:Refresh()
		oGet02:Refresh()
		oGet03:Refresh()
		oGet04:Refresh()

EndCase

//Bloquei para edicao quando diferente inclusao e alteracao
If !(AllTrim(Str(nOpc)) $ "3/4")
	lVldNegrito   := .F.
	lVldTotal     := .F.
	lVldSeparador := .F.
	lVldTraco     := .F.
EndIf

oEnch:Refresh()

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA161X  ºAutor  ³Microsiga           º Data ³  07/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb160ChkInc()
Local lRet := .F.
Local aArea := GetArea()
Local nRecCTS := CTS->(Recno())
dbSelectArea("CTS")
dbSetOrder(1)

lRet := dbSeek(xFilial("CTS")+PadR(CVE->CVE_CODIGO, Len(CTS_CODPLA))+StrZero(1, Len(CTS->CTS_ORDEM)))

dbSelectArea("CTS")
dbGoto(nRecCTS)

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA161X  ºAutor  ³Microsiga           º Data ³  07/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ctb160AddL1()
Local aArea := GetArea()
Local nRecCTS
Local nRecCVF

dbSelectArea("CTS")
dbSetOrder(1)

RecLock("CTS",.T.)
CTS->CTS_FILIAL  := xFilial("CTS")
CTS->CTS_CODPLA := CVE->CVE_CODIGO
CTS->CTS_ORDEM  := StrZero(1, Len(CTS->CTS_ORDEM))
CTS->CTS_CONTAG := StrZero(2, Len(CTS->CTS_CONTAG))
CTS->CTS_DESCCG := CVE->CVE_DESCRI
CTS->CTS_NORMAL := "1"
CTS->CTS_CLASSE := "1"   //TIPO SINTETICA
CTS->CTS_NOME 	:= CVE->CVE_DESCRI
CTS->CTS_VISENT := "2"   //NAO VISUALIZA NOS RELATORIOS DE VISAO GERENCIAL
If __Release .and. __lCOLUN2
	CTS->CTS_COLUN2 := "0"
Else
	CTS->CTS_COLUNA := GetCTSCol('0',cTipoCTS)
EndIf
MsUnLock()
nRecCTS := Recno()           //salvar o numero do registro incluido

dbSelectArea("CVF")
dbSetOrder(1)
If ! dbSeek(xFilial("CVF")+PadR(CTS->CTS_CODPLA, Len(CVF->CVF_CODIGO))+PadR(CTS->CTS_CONTAG, Len(CVF->CVF_CONTAG))+PadR(CTS->CTS_ORDEM, Len(CVF->CVF_ORDEM)))
	RecLock("CVF",.T.)
	CVF->CVF_FILIAL  := xFilial("CVF")
	CVF->CVF_CODIGO := CVE->CVE_CODIGO
	CVF->CVF_ORDEM  := StrZero(1, Len(CTS->CTS_ORDEM))
	CVF->CVF_CONTAG := StrZero(2, Len(CTS->CTS_CONTAG))
	CVF->CVF_DESCCG := CVE->CVE_DESCRI
	CVF->CVF_NORMAL := "1"
	CVF->CVF_CLASSE := "1"   //TIPO SINTETICA
	CVF->CVF_VISENT := "2"   //NAO VISUALIZA NOS RELATORIOS DE VISAO GERENCIAL
	CVF->CVF_COLUNA := "0"
	MsUnLock()
	nRecCVF := Recno()           //salvar o numero do registro incluido
EndIf

dbSelectArea("CTS")
dbSeek(xFilial("CTS")+CVE->CVE_CODIGO)

While CTS->(! Eof() .And. CTS_FILIAL+CTS_CODPLA == xFilial("CTS")+CVE->CVE_CODIGO)
	If Empty(CTS->CTS_CTASUP) .And. CTS->(Recno()) != nRecCTS
		RecLock("CTS",.F.)
		CTS->CTS_CTASUP := StrZero(2, Len(CTS->CTS_CONTAG))
		MsUnLock()
		//´pesquisa na tabela CVF e se a conta superior nao estiver preenchida grava a mesma conta gerencial
		dbSelectArea("CVF")
		If dbSeek(xFilial("CVF")+CVE->CVE_CODIGO+CTS->CTS_CONTAG) .And. ;
			Empty(CVF->CVF_CTASUP) .And. CVF->(Recno()) != nRecCVF
			RecLock("CVF",.F.)
			CVF->CVF_CTASUP := StrZero(2, Len(CVF->CVF_CONTAG))
			MsUnLock()
		EndIf
		dbSelectArea("CTS")
	EndIf
	CTS->(dbSkip())
EndDo

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA161X  ºAutor  ³Microsiga           º Data ³  07/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb161Grv()
//esta funcao apenas salva o recno na variavel private nRecCVE
//considerando que esta executando neste momento a funcao axinclui
//com tabela CVE posicionada
nRecCVE := Recno()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA161X  ºAutor  ³Microsiga           º Data ³  08/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb161Check(cCodVisao)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaCTS := CTS->(GetArea())
Local aAreaCVF := CVF->(GetArea())
Local lContinua := .T.

Default cCodVisao := CVE->CVE_CODIGO  //a tabela CVE deve estar posicionada

dbSelectArea("CVF")
dbSetOrder(1)

//1o. verifica se existe estrutura (CVF) para cada conta gerencial inclusa na tabela CTS
dbSelectArea("CTS")
dbSetOrder(1)

If ! dbSeek(xFilial("CTS")+cCodVisao)

	Aviso(STR0032,STR0033+"(CTS)", {STR0017})  //"Atencao"##"Inconsistencia na estrutura da visão gerencial. "##"Fechar"

Else
	//varre toda a tabela CTS e verifica se tem o CVF correspondente
	While CTS->(! Eof() .And. CTS_FILIAL+CTS_CODPLA==xFilial("CTS")+cCodVisao)

		dbSelectArea("CVF")
		If ! dbSeek(xFilial("CVF")+cCodVisao+CTS->CTS_CONTAG)

			Aviso(STR0032,STR0033+CRLF+STR0034+": "+CTS->CTS_CONTAG, {STR0017})   //"Atencao"##"Inconsistencia na estrutura da visão gerencial. "##"Conta Gerencial"##"Fechar"
		    lRet := .F.

        Else

        	//vefificar se campos estao sincronizados CTS/CVF
        	If lRet
        		lRet := CTB161ChkCpos(cCodVisao,CTS->CTS_CONTAG, @lContinua)
        	Else
        		CTB161ChkCpos(cCodVisao,CTS->CTS_CONTAG, @lContinua)
        	EndIf

        	If !lContinua
        		Exit
        	EndIf

		EndIf

		dbSelectArea("CTS")
		dbSkip()

	EndDo

EndIf

//2o. verifica se existe estrutura (CVF) sem item conta gerencial (CTS) - tem q existir pelo menos 1
dbSelectArea("CTS")
dbSetOrder(2)

dbSelectArea("CVF")
dbSetOrder(1)

If ! dbSeek(xFilial("CVF")+cCodVisao)

	Aviso(STR0032,STR0033+"(CVF)", {STR0017})  //"Atencao"##"Inconsistencia na estrutura da visão gerencial. "##"Fechar"

Else
	//varre toda a tabela CVF e verifica se tem CTS correspondente
	While CVF->(! Eof() .And. CVF_FILIAL+CVF_CODIGO==xFilial("CVF")+cCodVisao)

		dbSelectArea("CTS")
		If ! dbSeek(xFilial("CTS")+cCodVisao+CVF->CVF_CONTAG)

			Aviso(STR0032,STR0033+CRLF+STR0034+": "+CVF->CVF_CONTAG, {STR0017})  //"Atencao"##"Inconsistencia na estrutura da visão gerencial. "##"Conta Gerencial"##"Fechar"

        Else

        	//vefificar se campos estao sincronizados CTS/CVF
        	If lRet
        		lRet := CTB161ChkCpos(cCodVisao,CVF->CVF_CONTAG, @lContinua)
        	Else
        		CTB161ChkCpos(cCodVisao,CVF->CVF_CONTAG, @lContinua)
        	EndIf

        	If !lContinua
        		Exit
        	EndIf


		EndIf

		dbSelectArea("CVF")
		dbSkip()

	EndDo

EndIf

RestArea(aAreaCTS)
RestArea(aAreaCVF)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA161X  ºAutor  ³Microsiga           º Data ³  08/20/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTB161ChkCpos(cCodVisao,cCtaGer, lContinua)
	Local aCpoCompar := { 	{"CVF_FILIAL", "CTS_FILIAL"}, ;
							{"CVF_CODIGO", "CTS_CODPLA"}, ;
							{"CVF_CONTAG", "CTS_CONTAG"}, ;
							{"CVF_DESCCG", "CTS_DESCCG"}, ;
							{"CVF_ORDEM" , "CTS_ORDEM"}, ;
							{"CVF_CTASUP", "CTS_CTASUP"}, ;
							{"CVF_CLASSE", "CTS_CLASSE"}, ;
							{"CVF_NORMAL", "CTS_NORMAL"}, ;
							Iif(__Release .and. __lCOLUN2, {"CVF_COLUNA", "CTS_COLUN2"}, {"CVF_COLUNA", "CTS_COLUNA"}), ;
							{"CVF_IDENT", "CTS_IDENT"} ;
						}

Local nX
Local lRet := .T.

Default lContinua := .T.

For nX := 1 TO Len(aCpoCompar)
	xContCVF := CVF->(FieldGet(FieldPos(aCpoCompar[nX, 1])))
	xContCTS :=	GetCTSCol(CTS->(FieldGet(FieldPos(aCpoCompar[nX, 2]))),'C')

	If aCpoCompar[nX, 1] == "CVF_COLUNA"
		xContCTS := xContCTS
		xContCVF := Alltrim(xContCVF)
	EndIf
	If xContCVF != xContCTS

	  If !aCpoCompar[nX, 1]!="CTS_IDENT" .Or. aCpoCompar[nX, 1]!="CVF_IDENT"
			nOpcAviso := Aviso(STR0032+" - "+STR0035, STR0036+" : "+cCodVisao+CRLF+;  //"Atencao"##"Conteudos Divergentes"##"Visao Gerencial"
													STR0037+": "+aCpoCompar[nX, 1]+" "+xContCVF+CRLF+;  //"Campo"
													Space(10)+aCpoCompar[nX, 2]+" "+xContCTS+CRLF+;
													STR0034+": "+cCtaGer+ " "+"Verificaçao"+"? ", ;  //"Conta Gerencial"
													{STR0039,STR0040})  //"Continuar"##"Cancelar"
			lRet := .F.
			If nOpcAviso == 2
				lContinua := .F.
				Exit
			EndIf
		EndIf
	EndIf

Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT160VlTotºAutor  ³Alvaro Camillo Neto º Data ³  24/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida que a visão gerencial tenha apenas uma entidadade    º±±
±±º          ³totalizadora de analise vertical                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT160VlTot(cVisao,cOrdem)
Local lRet 		:= .T.
Local aArea		:= GetArea()

Default cVisao	:= M->CTS_CODPLA
Default cOrdem	:= M->CTS_ORDEM


CTS->(dbSetOrder(1)) //CTS_FILIAL+CTS_CODPLA+CTS_ORDEM+CTS_LINHA
If lRet .And. M->CTS_TOTVIS == '1'
	If CTS->(MsSeek(xFilial("CTS") + cVisao ))
		While CTS->(CTS_FILIAL+CTS_CODPLA) == xFilial("CTS") + cVisao .And. CTS->(!EOF())
			If CTS->CTS_TOTVIS == '1' .And. CTS->CTS_ORDEM != cOrdem
				Help("",1,"HELP","VLTOTVIS",STR0041+CTS->CTS_DESCCG+STR0042,3,1)//"A entidade '"##"' já está selecionada como totalizadora da Visão "
				lRet := .F.
				Exit
			EndIf
			CTS->(dbSkip())
		EndDo
	EndIf
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT160VlTot ºAutor  ³Alvaro Camillo Neto º Data ³  24/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida que a visão gerencial tenha apenas uma entidadade    º±±
±±º          ³totalizadora de analise vertical                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT161VlTot(cVisao,cOrdem)
Local lRet 		:= .T.
Local aArea		:= GetArea()

Default cVisao	:= M->CVF_CODIGO
Default cOrdem	:= M->CVF_ORDEM

CVF->(dbSetOrder(4)) //CVF_FILIAL+CVF_CODIGO+CVF_ORDEM
If lRet .And. M->CVF_TOTVIS == '1'
	If CVF->(MsSeek(xFilial("CVF") + cVisao ))
		While CVF->(CVF_FILIAL+CVF_CODIGO) == xFilial("CVF") + cVisao .And. CVF->(!EOF())
			If CVF->CVF_TOTVIS == '1' .And. CVF->CVF_ORDEM != cOrdem
				Help("",1,"HELP","VLTOTVIS",STR0041+CVF->CVF_DESCCG+STR0042,3,1)//"A entidade ' "##" 'já está selecionada como totalizadora da Visão "
				lRet := .F.
				Exit
			EndIf
			CVF->(dbSkip())
		EndDo
	EndIf
EndIf

RestArea(aArea)
Return lRet

