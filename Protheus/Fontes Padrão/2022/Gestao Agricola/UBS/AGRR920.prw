#INCLUDE 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE 'MSOLE.CH'

/** {Protheus.doc} AGRR920
Impressão de termos de multiplos lotes - Utilizado na consulta AGRC020

@param.: 	Nil
@author: 	Ana Laura Olegini
@since.: 	16/11/2015
@Uso...: 	UBS - Unidade de Beneficiamento de Sementes
*/
Function AGRR920(cSafra,cLote)

	Local aArea 		:= GetArea()
	Local aMES			:= {"Jan","Fev","Mar","Abr"  ,"Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}
	Local cBarraRem 	:= If(GetRemoteType() == 2,"/","\")// Estação com sistema operacional unix = 2
	Local cBarraSrv 	:= If(isSRVunix(),"/","\")         // servidor é da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	Local cPathDot1 	:= Alltrim(GetMv("MV_DIRACA"))     // Path do arquivo modelo do Word
	Local cPathEst1 	:= Alltrim(GetMv("MV_DIREST"))     // Path do arquivo a ser armazanado na estação de trabalho
	Local cPathEst  	:= cPathEst1+If(Substr(cPathEst1,len(cPathEst1),1) != cBarraRem,cBarraRem,"")
	Local cTermo		:= ''
	Local nx
	Local dData
	Local vVetCN    	:= {"NKY_FILIAL","NKY_DOCUME"}     // Campos que não deve considerar na montagem do documento

	//Cria diretório se não existir na estação
	MontaDir(cPathEst)

	// Apaga todos os .DOT da estação
	aDocDot := Directory(cPathEst+"*.DOT")
	For nx := 1 To Len(aDocDot)
		If File(cPathEst+aDocDot[nx,1])
			Ferase(cPathEst+aDocDot[nx,1])
		EndIf
	Next nx
	cArqDot := "TERMO.DOT"
	cDocu   := "TERMO.DOT"

	cPathDot := cPathDot1+If(Substr(cPathDot1,len(cPathDot1),1) != cBarraSrv,cBarraSrv,"") + cArqDot
	cData    := StrTran(Dtoc(dDataBase),"/")
	cHora    := StrTran(Time(),":")
	cDotNov  := ALLTRIM(clote)+".DOT"

	//Se existir .dot padrão na estação,apaga
	If File(cPathEst+cArqDot)
		Ferase(cPathEstcArqDot)
	EndIf

	//Se existir .dot com data+hora na estação,apaga para garantir
	If File(cPathEst+cDotNov)
		Ferase(cPathEst+cDotNov)
	EndIf

	If File(cPathDot)
		//Copia do Server para o Remote, é necessário para que o wordview e o próprio word possam preparar o arquivo para impressão
		CpyS2T(cPathDot,cPathEst,.T.)

		//Renomea arquivo .DOT na estação
		Frename(cPathEst+cArqDot,cPathEst+cDotNov)
		cArqDot := cDotNov
		aMatMac := {}
		aMatDoc := {}
		DbSelectArea("NKY")
		dbgotop()
		aEstrut := DbStruct()
		For nx := 1 To Len(vVetCN)
			nPosA := Ascan(aEstrut,{|x| x[1] = vVetCN[nx]})
			If nPosA > 0
				aDel(aEstrut,nPosA)
				aSize(aEstrut,Len(aEstrut)-1)
			Endif
		Next nx
		nSequ := Ascan(aEstrut,{|x| x[1] = "NKY_SEQUEN"})
		nMac  := Ascan(aEstrut,{|x| x[1] = "NKY_MACRO"})
		nCodA := Ascan(aEstrut,{|x| x[1] = "NKY_CODTA"})
		nCam  := Ascan(aEstrut,{|x| x[1] = "NKY_CAMPO"})

		//Monta uma matriz com as configurações do documento
		While !Eof() .AND. NKY->NKY_FILIAL = Xfilial("NKY") //.AND. NKY->NKY_DOCUME = cDocu
			Aadd(aMatDoc,{})
			For nx := 1 To Fcount()
				If Ascan(vVetCN,{|x| x = FieldName(nx)}) = 0
					cContu := "NKY->"+FieldName(nx)
					Aadd(aMatDoc[Len(aMatDoc)],&cContu)
				EndIf
			Next nx
			AGRDBSELSKIP("NKY")
		End

		//Monta a matriz com as macros (tabela..) para impressão
		For nx := 1 To Len(aMatDoc)
			Aadd(aMatMac,{})
			Aadd(aMatMac[Len(aMatMac)],{aMatDoc[nx,nSequ],aMatDoc[nx,nCodA],aMatDoc[nx,nCam],aMatDoc[nx,nMac]})
		Next nx
		//Início da impressão das macros e/ou tabelas
		BeginMsOle()
		//Conecta ao word
		hWord := OLE_CreateLink()
		If hWord = "0"
			OLE_SetPropertie(hWord,.F.)
			OLE_SetProperty( hWord, oleWdVisible,   .f. )
			OLE_NewFile(hWord,cPathEst+cArqDot)

			//Início da impressão das macros e/ou tabelas
			For nx := 1 To Len(aMatMac)
				nQtdNP9 := 0

				//Busca o código da safra na NP9 pelo lote
				cAlias := GetNextAlias()
				cQry := " SELECT NP9_LOTE,NP9_CODSAF,NP9_NUMTC"
				cQry +=   " FROM " +RetSqlName("NP9")
				cQry +=  " WHERE NP9_FILIAL = '"+xFilial("NP9")+"' AND NP9_LOTE = '"+cLote+"'"
				cQry +=    " AND NP9_CODSAF = '"+cSafra+"'"
				cQry +=    " AND D_E_L_E_T_ <> '*'"
				cQry := ChangeQuery(cQry)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.)
				Count To nQtdNP9
				(cAlias)->(dbGotop())
				(cAlias)->(dbCloseArea())

				//Verifica se achou a Safra na NP9
				If !Empty(nQtdNP9)
					AGRIFDBSEEK("NP9",cSafra+cLote,3,.F.)
					If !Empty(aMatMac[nx,1,nCodA])
						//Conteúdo da aMatMac[nx,1,nCam] é um registro da NPX
						nQtdNPX := 0
						cCodVaM := Alltrim(aMatMac[nx,1,nMac])
						cCodVaQ := cCodVaM+Space(Len(NPX->NPX_CODVA)-Len(cCodVaM))
						cTipoVa := AGRINICIAVAR("NPX_TIPOVA")
						cAlias := GetNextAlias()
						cQry := " SELECT NPX_TIPOVA,NPX_RESNUM,NPX_RESTXT,NPX_RESDTA"
						cQry += " FROM " +RetSqlName("NPX")
						cQry += " WHERE NPX_FILIAL = '"+xFilial("NPX")+"' AND NPX_LOTE = '"+cLote+"'"
						cQry += " AND NPX_ATIVO = '1'"
						cQry += " AND NPX_CODSAF = '"+cSafra+"' AND NPX_CODVA = '"+cCodVaQ+"'"
						cQry += " AND NPX_TIPOVA <> '"+cTipoVa+"' AND D_E_L_E_T_ <> '*'"
						cQry := ChangeQuery(cQry)
						DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.)
						Count To nQtdNPX
						(cAlias)->(dbGotop())

						cConte := "   "
						If !Empty(nQtdNPX)
							cConte := If((cAlias)->NPX_TIPOVA = '1',(cAlias)->NPX_RESNUM,;
							If((cAlias)->NPX_TIPOVA = '2',(cAlias)->NPX_RESTXT,StoD((cAlias)->NPX_RESDTA)))
						EndIf
						if ValType(cConte) = "D"
							dData := cConte
							Dtoc(cConte)
						EndIf
						if aMatMac[nx,1,nSequ] ="VALIDADE"
							cConte := (aMES[MONTH(dData)] + " / " + AllTrim(Str(Year(dData))))
						Endif
						(cAlias)->(dbCloseArea())
					Else
						nPosOn := At("_",aMatMac[nx,1,nCam])
						cTabel := SubStr(aMatMac[nx,1,nCam],1,nPosOn-1)
						cTabel := If(Len(cTabel) = 2,"S"+cTabel,cTabel)

						If ALLTRIM(aMatMac[nx,1,nCam]) == "NP9_CTRDES"
							cConte := Posicione("NP3",1,xFilial("NP3")+NP9->NP9_CULTRA,"NP3_DESCRI")
						ElseIf	ALLTRIM(aMatMac[nx,1,nCam]) == "NP9_CTVDES"
							cConte := Posicione("NP4",1,xFilial("NP4")+NP9->NP9_CTVAR,"NP4_DESCRI")
						ElseIf ALLTRIM(aMatMac[nx,1,nCam]) == "NJU_DESCRI"
							cConte := Posicione("NJU",1,xFilial("NJU")+NP9->NP9_CODSAF,"NJU_DESCRI")
						Else
							cConte := &(cTabel+"->"+aMatMac[nx,1,nCam])
						EndIf

					EndIf
					if aMatMac[nx,1,nSequ] ="VALIDADE"
						cConte := (aMES[MONTH(cConte)] + " / " + AllTrim(Str(Year(cConte))))
					Endif

					cMacro := Alltrim(aMatMac[nx,1,nMac])
					If	(ValType(cConte)="N" .and. cConte = 0) .or. (ValType(cConte)="C" .and. cConte="   ") .or. ValType(cConte)="U"
						OLE_SetDocumentVar(hWord,cMacro,"ZERO")
					Else
						OLE_SetDocumentVar(hWord,cMacro,cConte)
					Endif
				EndIf
			Next nx

			cTermo := NP9->NP9_NUMTC

			//Atualiza Variaveis
			OLE_UpDateFields(hWord)
			//Imprimindo o Documento
			OLE_SetProperty(hWord,'208',.F.)
			//OLE_PrintFile(hWord,"ALL",,,1)
			OLE_SaveAsFile( hWord, cPathEst+cTermo+".PDF", , , .f., 17 )

			//Fecha Documento Criado no Word
			OLE_CLOSEFILE(hWord)
			Sleep(1000)
			//Encerra link de comunicacao com o word
			OLE_CLOSELINK(hWord)
			ShellExecute("print",cPathEst+cTermo+".PDF","","",5) // Windows - 5=SW_SHOW
			EndMsOle()
			dbclosearea()
			Sleep(1000)
		Else
			ALERT("NAO INTEGROU")
		Endif
	EndIf
	RestArea(aArea)
Return