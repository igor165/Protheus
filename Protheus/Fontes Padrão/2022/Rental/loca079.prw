#include 'loca079.ch'
#include 'protheus.ch'
#Include "Totvs.ch"  
#Include "TopConn.ch"
#include 'parmtype.ch'
#Include 'FWMVCDEF.ch' 
#Include 'MsOle.CH'
#Include "TbiConn.ch"
#include "ap5mail.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA079
@description	PickList
@author			José Eulálio
@version   		1.00
@since     		30/06/2021
/*/			
//-------------------------------------------------------------------

Function LOCA079()
Local cTitulo	:= "PickList"
Local cMsg1     := STR0001 //"Esta rotina foi desenvolvida para facilitar a geração e leitura de arquivos do tipo CSV (Comma-Separated Values). O que deseja realizar?"
Local cMsg2     := STR0002 //"preparando ambiente para "
Local cBtn1		:= STR0003 //"Gerar CSV"
Local cBtn2		:= STR0004 //"Atualizar Itens"
Local nRetFunc	:= 0

nRetFunc := AVISO(cTitulo, cMsg1, { cBtn1,cBtn2,STR0005}, 2) // "Fechar"

If nRetFunc <> 3
	If nRetFunc == 1
		cMsg2     := STR0006 //"gerando arquivo CSV"
	ElseIf nRetFunc == 2
		cMsg2     := STR0007 //" prepando atualização de itens"
	EndIf
	Processa({|| Atualiza(nRetFunc)},STR0008,STR0009 + cMsg2,.F.) //"Processando" ###  "Aguarde, "
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Atualiza
@description	Executa a atualizacao dos dados
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function Atualiza(nRetFunc)

If nRetFunc == 1 
	CriaCsv()
ElseIf nRetFunc == 2
	LeCsv()
EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaCsv
@description	Cria arquivos .csv
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function CriaCsv()
Local cRange	:= "PA"
Local cAliasAux	:= ""
Local cReturn	:= ""
Local cLocal	:= ""
Local cListEnt	:= ""
Local cCamposNao:= "FPA_FILIAL|FPA_PROJET|FPA_OBRA|FPA_SEQGRU|FPA_SEQSUB|FPA_TPBASE!FPA_PREDIA"
Local cDesX3	:= ""
Local cDirDest	:= ""
Local cMvLocx306:= SuperGetMV("MV_LOCX306",.F.,"")
Local nHandle	:= 0
Local nHandX3	:= 0
Local nX		:= 0
//Local aPergs	:= {}
//Local aRet		:= {}
Local aEnts		:= {}

//aAdd( aPergs ,{1 ,"Local"    		,Space(50) ,"@!"  , "","", ".T." ,100 , .T.}) // Tipo caractere
cDirDest := cGetFile( '.' , STR0010, 1, cMvLocx306, .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. ) //'Informe o Local para gravar o arquivo' ### 

//If ParamBox(aPergs ,"Informe a Entidade e Local de gravação do CSV",@aRet,,,,,,,,.F.)
If !Empty(cDirDest)
	If ExistDir(cDirDest)
		cLocal:= AllTrim(cDirDest)
		aEnts := {"FPA"} //StrToKarr(AllTrim(aRet[1]),";")
	Else
		MsgStop(STR0011, STR0012) //"Não existe o caminho indicado" #### "Atencao !"
	EndIf
	
	//Alert com regras
	FwAlertInfo(STR0047  + CRLF + CRLF + STR0048  + CRLF + STR0049, STR0045) //"As datas deverão estar no formato:" + CRLF + " DD/MM/AAAA (Ex: 31/12/2049) ou" + CRLF + "  AAAAMMDD (Ex: 20491231)" ### "Importante!"

	For nX := 1 To Len(aEnts)
		If !Empty(aEnts[nX])
			cRange	:= aEnts[nX]
			nHandle	:= 0
			//SX3->(dbSetOrder(1))
			(LOCXCONV(1))->(DBSETORDER(1))
			If (LOCXCONV(1))->(DBSEEK(cRange)) //SX3->(dbSeek(cRange))
				While (LOCXCONV(1))->(!EOF()) .and. cRange $ GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") //SX3->X3_ARQUIVO
					If cAliasAux	<> GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") //SX3->X3_ARQUIVO
						//If nHandle > 0
						//	FWrite(nHandle, cReturn + CRLF)
						//	FClose(nHandle)
						//EndIf
						cReturn		:= ""
						cAliasAux	:= GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") //SX3->X3_ARQUIVO
						cTemp := "SX2->( dbSetOrder( 1 ) ) "
						&(cTemp) //SX2->( dbSetOrder( 1 ) ) 
						cTemp := "SX2->( dbSeek( cAliasAux ) )"
						If &(cTemp) //SX2->( dbSeek( cAliasAux ) )  
							cTemp := "SX2->X2_CHAVE"
							cTemp2 := "SX2->X2_NOME"
							cListEnt   += &(cTemp) + " - " + &(cTemp2) + CRLF
						EndIf 
						//If nHandX3 > 0
						//	FClose(nHandX3)
						//EndIf
						nHandle := FCREATE(cLocal + "\" + "picklist.csv")
						//nHandX3 := FCREATE(cLocal + "\" + Upper(cAliasAux )+ "-sx3.csv")
						//FWrite(nHandX3, "X3_ORDEM;X3_CAMPO;X3_DESCRIC;X3_OBRIGAT;X3_TAMANHO;X3_DECIMAL;X3_TITULO;X3_TIPO;X3_PICTURE;X3_F3;X3_CBOX" + CRLF)
						
					EndIf
					If GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") <> "V" .And. !(AllTrim(GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO")) $ cCamposNao)
						cReturn += GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") + "," + GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") + "," + cValToChar(GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO")) + ";"
						cDesX3	:= GetSx3Cache(&(LOCXCONV(2)),"X3_ORDEM") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_DESCRIC") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_OBRIGAT") + ";" + cValToChar(GetSx3Cache(&(LOCXCONV(2)),"X3_TAMANHO")) + ";" + cValToChar(GetSx3Cache(&(LOCXCONV(2)),"X3_DECIMAL")) + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_TITULO") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") + ";" + GetSx3Cache(&(LOCXCONV(2)),"X3_PICTURE") + ";" +GetSx3Cache(&(LOCXCONV(2)),"X3_F3") + ";" + StrTran( GetSx3Cache(&(LOCXCONV(2)),"X3_CBOX"), ";", "," ) + CRLF
						//FWrite(nHandX3, cDesX3)
					EndIF
					cTemp := "SX3->(dbSkip())"
					&(cTemp)
				EndDo
			EndIf
			If nHandle > 0
				FWrite(nHandle, cReturn + CRLF)
				FClose(nHandle)
			EndIf
			//If nHandX3 > 0
			//	FClose(nHandX3)
			//EndIf
		EndIf
	Next nX
	/*If !Empty(cLocal) 
		nHandle := FCREATE(cLocal + "\ListaCsv.txt")
		FWrite(nHandle, "LISTA DE ENTIDADES E NOMES" + CRLF+ CRLF)
		FWrite(nHandle, cListEnt + CRLF)
		FClose(nHandle)
	EndIf*/
EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LeCsv
@description	Cria arquivos .csv
@author			José Eulálio
@since     		16/03/2020
/*/
//-------------------------------------------------------------------  
Static Function LeCsv()
Local cDirDest 	:= ""
Local cLocal	:= ""
Local cArquivo	:= "picklist.csv"
Local cMvLocx306:= SuperGetMV("MV_LOCX306",.F.,"")

cDirDest := cGetFile( '.' , STR0013, 1, cMvLocx306, .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. ) //'Informe o Local do arquivo CSV'

If ExistDir(cDirDest)
	cLocal:= AllTrim(cDirDest)
	If File(cLocal + cArquivo)

		CsvProcess(cLocal + "\" + cArquivo,cArquivo)
	
	Else
		MsgStop(STR0014) //"Não existe o arquivo [picklist.csv] no diretório indicado."
	EndIf

Else
	MsgStop(STR0015) //"Não existe o caminho indicado."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CsvProcess
@description	Lê arquivo .csv e processa inclusão 
@author			José Eulálio
@since     		17/03/2020
/*/
//-------------------------------------------------------------------
Static Function CsvProcess(_cFile, cArquivo)
Local _nHandle 	:= 0
Local _nLast	:= 0
Local _nCount	:= 1
Local nX		:= 0
Local nPosCsv	:= 0
Local cCabUlt	:= ''
Local cAliasAux	:= ''
Local cAliasCsv	:= ''
Local cCpoCsv	:= ''
Local _cLine	:= ''
Local cKeyCsv	:= ""
Local cObrigat	:= ""
Local cCampoSim	:= ""
Local cSobra	:= ""
Local aKeyCsv	:= {}
Local _aDados  	:= {}
Local _aArea	:= GetArea()
Local aCabCsv	:= {}
Local aObrigat	:= {}
Local aItensFPA	:= {}
Local aFPA		:= {}
Local lContinua	:= .T.
Local lCabQuebra:= .F.
Local lValid	:= .T.
Local xValue

//campos obrigatorios
cCampoSim := "FPA_PRODUT|FPA_QUANT"


//abre arquivo
nHandle := FT_FUse( _cFile )

If existblock("LOCA7901")
	nHandle := execblock("LOCA7901" , .T. , .T. , {nHandle}) 
EndIF

If nHandle = -1
	
	MsgStop(STR0016,STR0012) //"Arquivo não processado!" #### "Atenção!"

	lContinua	:= .F.

EndIf

If lContinua
	// Posiciona na primeira linha
	FT_FGoTop()
	
	//Retorna o número de linhas do arquivo
	_nLast := FT_FLastRec()
	
	ProcRegua( _nLast )
	IncProc(STR0017 + cArquivo + "...") //"Atualizando arquivo " 
		
	Do While !FT_FEOF() .And. _nCount <= _nLast .And. lvalid
	
		IncProc(STR0017  + cArquivo + "..." + CRLF+ STR0018 + cValToChar( _nCount ) + " de " + cValToChar( _nLast )) // "Atualizando arquivo "  #### "Processando registro: "
			
		//pega nova linha com sobra da úlitma
		_cLine  := cSobra + FT_FReadLn()
		//pega sobra da última linha caso não tenha separador de campo ',' no final
		cSobra := IIF(At(",",SubStr(_cline,RAT(";",_cLine)+1)) == 0 , SubStr(_cline,RAT(";",_cLine)+1) , "")
		//retira sobra para não criar um campo com string cortada
		_cLine := StrTran(_cLine,cSobra,"")
	
		_aDados := Str2Arr( _cLine , ";" )
		
		lCabQuebra	:= (!Empty(cAliasAux) .And. cAliasAux $ _cLine)
		
		If (_nCount == 1 .Or. lCabQuebra) .And. Len(_aDados) > 0 .And. lValid
			
			//Verifica se tem o cabeçalho
			//If "_FILIAL" $ _aDados[1] .Or. "_FILIAL" $ _aDados[2] .Or. lCabQuebra

			If existblock("LOCA7904")
				lCabQuebra := execblock("LOCA7904" , .T. , .T. , {_aDados[1]}) 
			EndIF

			If "FPA_FILIAL" $ _aDados[1] .Or. "FPA_" $ _aDados[2] .Or. lCabQuebra
				If _nCount == 1
					cAliasAux	:= SubStr(_aDados[1],1,AT( "_", _aDados[1] )-1)
					cAliasCsv	:= LimpaAspa(IIF(Len(cAliasAux) == 2, "S" + cAliasAux, cAliasAux))
				EndIf
				For nX := 1 To Len(_aDados)
					If !(cAliasCsv $ _aDados[nX])
						Loop
					EndIf

					If existblock("LOCA7902")
						_aDados[nX] := execblock("LOCA7902" , .T. , .T. , {_aDados[nX]}) 
					EndIF

					If "," $ _aDados[nX]
						cCpoCsv	:= AllTrim(SubStr(_aDados[nX],1,AT( ",", _aDados[nX] )-1))
					Else
						cCpoCsv	:= AllTrim(_aDados[nX])
					EndIf
					//Manobra não convencional para contornar o fato da função FT_FReadLn quebrar linhas maiores que 1Mb
					If nX == 1 .And. !Empty(cCabUlt)
						cTemp := "SX3->(DbSetOrder(2))"
						&(cTemp) //SX3->(DbSetOrder(2)) //X3_CAMPO
						cTemp := "SX3->(DbSeek(Padr(cCabUlt,10)))"

						If existblock("LOCA7903")
							cTemp := execblock("LOCA7903" , .T. , .T. , {cTemp}) 
						EndIF

						If &(cTemp) //SX3->(DbSeek(Padr(cCabUlt,10)))
							cCabUlt := ""
						Else
							cCpoCsv := cCabUlt+cCpoCsv
							ASize(aCabCsv,Len(aCabCsv)-1)
						EndIf
					EndIf
					//SubStr(_aDados[nX],AT( ",", _aDados[nX] )+1,1)
					If !Empty(cCpoCsv)
						cCpoCsv := LimpaAspa(cCpoCsv)
						cTemp := "Posicione('SX3',2,cCpoCsv,'X3_TIPO')"
						Aadd(aCabCsv,{cCpoCsv,&(cTemp)})
					EndIf
				Next nX
				cCabUlt := aCabCsv[Len(aCabCsv)][1]
				_nCount++
				FT_FSKIP()
			Else
				FT_FUSE()
				//FWrite(nHandLog, "O arquivo " + cArquivo + "não possui um cabeçalho válido. " + CRLF)
				MsgStop(STR0019 + cArquivo + STR0020,STR0012) //"O arquivo " #### "não possui um cabeçalho válido." #### "Atenção!"
				lContinua := .F.
			EndIf 
		
		Else

			If lContinua := ConfereCab(aCabCsv) .And. lvalid

				If _nCount > 1 .And. !EMPTY(_cLine) .And. !Empty(ArrToStr(_aDados))
					cChavCsv	:= ""
					(cAliasCsv)->(DbSetOrder(1))
					cKeyCsv	:= (cAliasCsv)->(IndexKey())
					(aKeyCsv) := StrToKarr(cKeyCsv,"+")
					For nX := 1 To Len(aKeyCsv)

						//posiciona no campo
						nPosCsv	:= v
						xValue	:= LimpaAspa(_aDados[nPosCsv])

						cChavCsv += PadR(IIF(AT( "'", xValue ) == 1, SubStr(xValue,2), xValue),TamSx3(aKeyCsv[nX])[1])
					Next nX
					

					aObrigat := {}
					cObrigat := ""
					//RecLock(cAliasCsv, .T.)
					For nX := 1 To Len(_aDados)

						If aCabCsv[nX][2] == "N" 
							xValue	:= Val(LimpaAspa(_aDados[nX]))
						ElseIf aCabCsv[nX][2] == "D"
							If "/" $ _aDados[nX]
								xValue	:= CtoD(LimpaAspa(_aDados[nX]))
							Else
								xValue	:= StoD(LimpaAspa(_aDados[nX]))
							EndIf
							
						Else
							xValue	:= LimpaAspa(_aDados[nX])

							If nX == 145 //.or. _lPassax
								FWrite(nHandLog, STR0023 + cValToChar(nX) + CRLF) //"Linha "
							EndIf
							If nX > 1
								xValue	:= PadR(IIF(AT( "'", xValue ) == 1, SubStr(xValue,2), xValue),TamSx3(aCabCsv[nX][1])[1])
							EndIf
						EndIf
						//(cAliasCsv)->&(aCabCsv[nX][1])  := xValue
						Aadd(aFPA,{aCabCsv[nX][1], xValue, NIL})

						If Empty(xValue) .And. AllTrim(aCabCsv[nX][1]) $ cCampoSim
							Aadd(aObrigat, aCabCsv[nX][1])
						EndIf
						//Validações
						lContinua := EspPicVld(AllTrim(aCabCsv[nX][1]),xValue)
						If !lContinua
							lValid	:= .F.
							Exit
						EndIf
					Next nX

					If lContinua
						//MsUnlock()
						Aadd(aItensFPA,Aclone(aFPA))
						aFPA := {}

						If Len(aObrigat) <> 0

							For nX := 1 To Len(aObrigat)
								If nX > 1
									cObrigat += ", "
								EndIf
								cObrigat += aObrigat[nX]
							Next nX
							
							//FWrite(nHandLog, "O registro com a chave (" + AllTrim(cKeyCsv) + ") (" + cChavCsv + "). ERRO: Campos obrigatórios em branco (" + cObrigat + ")" + CRLF)
							FWAlertWarning(STR0024 + CRLF + cObrigat, STR0025) //"Existem campos obrigatórios não preenchidos: " ####  "Erro"
							lContinua := .F.
						EndIf
					EndIf
					
				EndIf
					
				_nCount ++
							
				// Pula para próxima linha
				FT_FSKIP()
			Else
				Exit
			EndIf
		EndIf		
	EndDo
	
	// Fecha o Arquivo
	FT_FUSE()
	//FWrite(nHandLog, "Finalizado: " + Time() + CRLF)
EndIf



If lContinua

	AtuGrid(aItensFPA)
 
	FWAlertSuccess(STR0026, STR0027) //"Itens atualizados com PickList" #### "Sucesso"

EndIf 

RestArea(_aArea)

Return

Static Function ConfereCab(aCabCsv)
Local aAreaSx3	:= &("SX3->(GetArea())")
Local nX		:= 0
Local lRet		:= .T.
Local cErro		:= ""

&("SX3->(DbSetOrder(2))") //X3_CAMPO
For nX := 1 To Len(aCabCsv)

	If !( &("SX3->(DbSeek(Padr(aCabCsv[nX][1],10)))") ) .And. !Empty(aCabCsv[nX][1])
		If lRet
			cErro += STR0028 //"ATENÇÃO! Os campos abaixo relacionados não constam no dicionário de dados, " 
			cErro += STR0029 + CRLF // "verifique o problema e realize a atualização novamente após correção."
		EndIf
		cErro +=  STR0030 + aCabCsv[nX][1] + CRLF // "Campo: "
		lRet	:= .F.
	EndIf
Next nX

If !lRet
	MsgStop(cErro)
EndIf

RestArea(aAreaSx3)

Return lRet

Static Function LimpaAspa(cString)
Local cRet		:= ""
Local cCaracter	:= ""
Local nX		:= 0

Default cString	:= ""

For nX  := 1 To Len(cString)
	cCaracter	:= SubStr(cString,nX,1)
	lTempx := .F.

	If Asc(cCaracter) == 34 .or. lTempx
		Loop
	EndIf
	cRet += cCaracter
Next nX

Return cRet

Static Function AtuGrid(aItensFPA)
Local nPosGrua  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GRUA"})
Local nPosProd  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})
Local nPosDesp  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESPRO"})
Local nPosObra  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_OBRA"})
Local nPosAS  	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AS"})
Local nPosCTab 	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CODTAB"})
Local nPosDTab 	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESTAB"})
Local NPSTPBAS  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[1]) == "FPA_TPBASE"})  
Local NPSPREDI  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[1]) == "FPA_PREDIA"}) 
Local nPosAux	:= 0
Local nUltLinh	:= Len(ODLGPLA:aCols)
Local nUltOPla	:= Len(OPla_Cols)
Local nX		:= 0
Local nY		:= 0
Local nRetFunc	:= 0
Local nPos1     := 0
Local nPos2     := 0
Local nPos3     := 0
Local nPos4     := 0
Local nPos5     := 0
Local nPos6     := 0
Local nPos7     := 0
Local nPos8     := 0
Local nPos9     := 0
Local nPos10    := 0
Local nPos11    := 0
Local nPos12    := 0
Local nPos13    := 0
Local nPos14    := 0
Local nPos15    := 0
Local nPos16    := 0
Local nPos17    := 0
Local cObra		:= ODLGOBR:ACOLS[ODLGOBR:NAT][ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_OBRA"  })]
Local cTitulo	:= STR0031 //"Atualização dos Itens de Locação"
Local cMsg1     := STR0032 //"A Aba Locação já contém itens (Itens com AS não serão sobrepostos). O que deseja realizar?"
Local cBtn1		:= STR0033 //"Sobrepor"
Local cBtn2		:= STR0034 //"Adicionar "
Local lDel 		:= .T.
Local aAreaDA1	:= DA1->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aObrasRep	:= {}

If !Empty(ODLGPLA:ACOLS[nUltLinh][nPosProd]) .Or. !Empty(ODLGPLA:ACOLS[nUltLinh][nPosGrua])
	nRetFunc := AVISO(cTitulo, cMsg1, { cBtn1,cBtn2,"Fechar"}, 2)

	If nRetFunc == 3
		FWAlertWarning(STR0035, STR0036) //"Operação cancelada!" #### "PickList"
	ElseIf nRetFunc == 1
		If MsgYesNo(STR0050, STR0051) //"Deseja replicar o picklist para outras Obras?" ### "Facilitador de preenchimento"
			aObrasRep	:= RepliPick()
		EndIf
		//deleta itens
		While lDel
			lDel := .F.
			For nX := 1 To nUltLinh
				If Empty(ODLGPLA:ACOLS[nX][nPosAS])
					Adel(ODLGPLA:ACOLS,nX)
					//Adel(OPla_Cols,nX)
					//Adel(OPla_Cols0,nX)
					Adel(OPla_Cols,Ascan(OPla_Cols,{|x| x[nPosObra] == cObra}))
					Asize(ODLGPLA:ACOLS,nUltLinh-1)
					//Asize(OPla_Cols,nUltLinh-1)
					Asize(OPla_Cols,nUltOPla-1)
					//Asize(OPla_Cols0,nUltLinh-1)
					nUltLinh	:= Len(ODLGPLA:aCols)
					nUltOPla	:= Len(OPla_Cols)
					lDel := .T.
					Exit
				EndIf
			Next nX
		EndDo
		//deleta itens das obras selecionadas
		lDel := .T.
		While lDel
			lDel := .F.
			For nX := 1 To Len(aObrasRep)
				nPosAux := Ascan(OPla_Cols,{|x| x[nPosObra] == aObrasRep[nX][2]})
				If Empty(OPla_Cols[nPosAux][nPosAS])
					Adel(OPla_Cols	,nPosAux)
					Asize(OPla_Cols	,nUltOPla-1)
					nUltOPla	:= Len(OPla_Cols)
					lDel := .T.
				EndIf
			Next nX
		EndDo
	ElseIf nRetFunc == 2
		
	EndIf

	If nRetFunc <> 3
		If Empty(aObrasRep) .And. MsgYesNo(STR0050, STR0051) //"Deseja replicar o picklist para outras Obras?" ### "Facilitador de preenchimento"
			aObrasRep	:= RepliPick()
		EndIf
		//verifica se a linha não tem produto
		If !(Empty(ODLGPLA:ACOLS[nUltLinh][nPosProd]))
			ODLGPLA:ADDLINE()
		EndIf
		nUltLinh	:= Len(ODLGPLA:aCols)
		nUltOPla	:= Len(OPla_Cols)
		If !(nUltOPla == 1 .And. Empty(OPla_Cols[Len(OPla_Cols)][nPosProd]))
			AADD(OPLA_COLS, Aclone(ODLGPLA:ACOLS[nUltLinh]))
			nUltOPla	:= Len(OPla_Cols)
		EndIf
		AADD(ODLGPLA, Aclone(ODLGPLA:ACOLS[nUltLinh]))
		//AADD(OPLA_COLS0, ODLGPLA:ACOLS[nUltLinh])
		ODLGPLA:ACOLS[nUltLinh][nPosObra]	:= cObra
		OPla_Cols[nUltOPla][nPosObra]		:= cObra
		ODLGPLA:ACOLS[nUltLinh][NPSPREDI]	:= 1
		OPla_Cols[nUltOPla][NPSPREDI]		:= 1
		ODLGPLA:ACOLS[nUltLinh][NPSTPBAS]	:= 1
		OPla_Cols[nUltOPla][NPSTPBAS]		:= 1
	EndIf
EndIf

If nRetFunc <> 3
	//pega posições dos campos na aba Locações
	nPos1   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})
	nPos2   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})
	nPos3   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"})
	If FPA->(FieldPos("FPA_XPREKG")) > 0
		nPos4   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_XPREKG"})
	EndIf
	If FPA->(FieldPos("FPA_XPREM2")) > 0
		nPos5   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_XPREM2"})
	EndIf
	If FPA->(FieldPos("FPA_XPREMT")) > 0
		nPos6   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_XPREMT"})
	EndIf
	nPos7   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTINI"})
	nPos8   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})
	nPos9   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_HRINI"})
	nPos10  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_HRFIM"})
	nPos11  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRHOR"})
	nPos12  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_FILEMI"})
	nPos13	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})
	//nPos14	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_XKILOG"})
	//nPos15  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_XPRCDI"})
	nPos16  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_OBRA"})
	nPos17  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})
	//percorre linhas
	For nX := 1 To Len(aItensFPA)
		If nX > 1
			ODLGPLA:ADDLINE()
			nUltLinh	:= Len(ODLGPLA:aCols)
			AADD(OPLA_COLS, Aclone(ODLGPLA:ACOLS[nUltLinh]))
			AADD(ODLGPLA, Aclone(ODLGPLA:ACOLS[nUltLinh]))
			//AADD(OPLA_COLS0, ODLGPLA:ACOLS[nUltLinh])
			nUltOPla	:= Len(OPla_Cols)
			ODLGPLA:ACOLS[nUltLinh][nPosObra]	:= cObra
			OPla_Cols[nUltOPla][nPosObra]		:= cObra
			ODLGPLA:ACOLS[nUltLinh][NPSPREDI]	:= 1
			OPla_Cols[nUltOPla][NPSPREDI]		:= 1
			ODLGPLA:ACOLS[nUltLinh][NPSTPBAS]	:= 1
			OPla_Cols[nUltOPla][NPSTPBAS]		:= 1
		EndIf
		//percorre campos
		For nY := 1 To Len(aItensFPA[nX])
			nPosAux	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])==aItensFPA[nX][nY][1]})
			ODLGPLA:ACOLS[nUltLinh][nPosAux] 	:= aItensFPA[nX][nY][2]
			OPla_Cols[nUltOPla][nPosAux] 		:= aItensFPA[nX][nY][2]
		Next nY

		//Atualiza descrição do produto e valor
		If !Empty(ODLGPLA:ACOLS[nUltLinh][nPosProd] )
			SB1->(DbSetOrder((1)))
			if SB1->(DbSeek(xFilial("SB1") + ODLGPLA:ACOLS[nUltLinh][nPosProd] ))
				ODLGPLA:ACOLS[nUltLinh][nPosDesp] 	:= SB1->B1_DESC
				//OPla_Cols[nUltOPla][nPosDesp] 		:= ODLGPLA:ACOLS[nX][nPosDesp]
				OPla_Cols[nUltOPla][nPosDesp] 		:= ODLGPLA:ACOLS[nUltLinh][nPosDesp]
				If Empty(ODLGPLA:ACOLS[nUltLinh][nPos1] )
					ODLGPLA:ACOLS[nUltLinh][nPos1] 		:= SB1->B1_PRV1
					//OPla_Cols[nUltOPla][nPos1]    		:= ODLGPLA:ACOLS[nX][nPos1] //FPA_PRCUNI
					OPla_Cols[nUltOPla][nPos1]    		:= ODLGPLA:ACOLS[nUltLinh][nPos1] //FPA_PRCUNI
				EndIf
			endif
		EndIf
		
		//atualiza gatilhos de  tabela de preço, data início, data fim,hora início, hora fim,
		If !Empty(ODLGPLA:ACOLS[nUltLinh][nPosCTab] )
			ODLGPLA:ACOLS[nUltLinh][nPosDTab] 	:= Posicione("DA0",1,xFilial("DA0")+ODLGPLA:ACOLS[nUltLinh][nPosCTab],"DA0_DESCRI") //FPA_DESTAB
			//OPla_Cols[nUltOPla][nPosDTab] 		:= ODLGPLA:ACOLS[nX][nPosDTab] //FPA_DESTAB
			OPla_Cols[nUltOPla][nPosDTab] 		:= ODLGPLA:ACOLS[nUltLinh][nPosDTab] //FPA_DESTAB
			DA1->(DbSetOrder(1)) //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
			If DA1->(DbSeek(xFilial("DA1") + ODLGPLA:ACOLS[nUltLinh][nPosCTab] + ODLGPLA:ACOLS[nUltLinh][nPosProd]))

				//ODLGPLA:ACOLS[nUltLinh][nPosDTab] := Posicione("DA0",1,xFilial("DA0")+DA1->DA1_CODTAB,"DA0_DESCRI") //FPA_DESTAB
				ODLGPLA:ACOLS[nUltLinh][nPos1] 	:= DA1->DA1_PRCVEN //FPA_PRCUNI
				If FPA->(FieldPos("FPA_XPREKG")) > 0
					ODLGPLA:ACOLS[nUltLinh][nPos4] 	:= DA1->DA1_XPREKG * ODLGPLA:ACOLS[nUltLinh][nPos2] //FPA_XPREKG
				EndIf					
				If FPA->(FieldPos("FPA_XPREM2")) > 0
					ODLGPLA:ACOLS[nUltLinh][nPos5] 	:= DA1->DA1_XPREM2 * ODLGPLA:ACOLS[nUltLinh][nPos2] //FPA_XPREM2
				EndIf					
				If FPA->(FieldPos("FPA_XPREMT")) > 0
					ODLGPLA:ACOLS[nUltLinh][nPos6] 	:= DA1->DA1_XPREM3 * ODLGPLA:ACOLS[nUltLinh][nPos2] //FPA_XPREMT
				EndIf					

				//OPla_Cols[nUltOPla][nPosDTab] := ODLGPLA:ACOLS[nX][nPosDTab] //FPA_DESTAB
				OPla_Cols[nUltOPla][nPos1]    := ODLGPLA:ACOLS[nUltLinh][nPos1] //FPA_PRCUNI
				If FPA->(FieldPos("FPA_XPREKG")) > 0
					OPla_Cols[nUltOPla][nPos4]    := ODLGPLA:ACOLS[nUltLinh][nPos4] //FPA_XPREKG
				EndIf					
				If FPA->(FieldPos("FPA_XPREM2")) > 0
					OPla_Cols[nUltOPla][nPos5]    := ODLGPLA:ACOLS[nUltLinh][nPos5] //FPA_XPREM2
				EndIf					
				If FPA->(FieldPos("FPA_XPREMT")) > 0
					OPla_Cols[nUltOPla][nPos6]    := ODLGPLA:ACOLS[nUltLinh][nPos6] //FPA_XPREMT
				EndIf					
			EndIf
		EndIf
		
		ODLGPLA:ACOLS[nUltLinh][nPos3] 		:= ODLGPLA:ACOLS[nUltLinh][nPos2] * ODLGPLA:ACOLS[nUltLinh][nPos1] //FPA_VLBRUT
		/*
		OPla_Cols[nUltOPla][nPos3]    		:= ODLGPLA:ACOLS[nX][nPos3] //FPA_VLBRUT
		ODLGPLA:ACOLS[nUltLinh][nPos11] 	:= ODLGPLA:ACOLS[nX][nPos3]//FPA_VRHOR
		*/
		OPla_Cols[nUltOPla][nPos3]    		:= ODLGPLA:ACOLS[nUltLinh][nPos3] //FPA_VLBRUT
		ODLGPLA:ACOLS[nUltLinh][nPos11] 	:= ODLGPLA:ACOLS[nUltLinh][nPos3]//FPA_VRHOR
		OPla_Cols[nUltOPla][nPos11]    		:= ODLGPLA:ACOLS[nUltLinh][nPos11] //FPA_VRHOR

		If Empty(ODLGPLA:ACOLS[nUltLinh][nPos7] )
			ODLGPLA:ACOLS[nUltLinh][nPos7] := dDataBase
			OPla_Cols[nUltOPla][nPos7]    	:= ODLGPLA:ACOLS[nUltLinh][nPos7] //FPA_DTINI
		EndIf 

		If Empty(ODLGPLA:ACOLS[nUltLinh][nPos8] )
			ODLGPLA:ACOLS[nUltLinh][nPos8] 	:= LastDate(dDataBase)
			OPla_Cols[nUltOPla][nPos8]    	:= ODLGPLA:ACOLS[nUltLinh][nPos8] //FPA_DTFIM
		EndIf 

		If Empty(ODLGPLA:ACOLS[nUltLinh][nPos9] )
			ODLGPLA:ACOLS[nUltLinh][nPos9]	:= "0800"
			OPla_Cols[nUltOPla][nPos9]    	:= ODLGPLA:ACOLS[nUltLinh][nPos9] //FPA_HRINI
		EndIf 

		If Empty(ODLGPLA:ACOLS[nUltLinh][nPos10] )
			ODLGPLA:ACOLS[nUltLinh][nPos10]	:= "1800"
			OPla_Cols[nUltOPla][nPos10]    	:= ODLGPLA:ACOLS[nUltLinh][nPos10] //FPA_HRFIM
		EndIf 

		If Empty(ODLGPLA:ACOLS[nUltLinh][nPos12] )
			ODLGPLA:ACOLS[nUltLinh][nPos12] := xFilial("FPA")
			OPla_Cols[nUltOPla][nPos12]    	:= ODLGPLA:ACOLS[nUltLinh][nPos12] //FPA_FILEMI
		EndIf 

		//calcula campo FPA_LOCDIA
		ODLGPLA:ACOLS[nUltLinh][nPos13] := ODLGPLA:ACOLS[nUltLinh][nPos8] - ODLGPLA:ACOLS[nUltLinh][nPos7] // FPA_DTFIM - FPA_DTINI
		OPla_Cols[nUltOPla][nPos13]    	:= ODLGPLA:ACOLS[nUltLinh][nPos13] //FPA_LOCDIA

		//calcula campo FPA_LOCDIA
		ODLGPLA:ACOLS[nUltLinh][nPos13] := ODLGPLA:ACOLS[nUltLinh][nPos8] - ODLGPLA:ACOLS[nUltLinh][nPos7] // FPA_DTFIM - FPA_DTINI
		OPla_Cols[nUltOPla][nPos13]    	:= ODLGPLA:ACOLS[nUltLinh][nPos13] //FPA_LOCDIA

		//calcula campo FPA_LOCDIA
		ODLGPLA:ACOLS[nUltLinh][nPos13] := ODLGPLA:ACOLS[nUltLinh][nPos8] - ODLGPLA:ACOLS[nUltLinh][nPos7] // FPA_DTFIM - FPA_DTINI
		OPla_Cols[nUltOPla][nPos13]    	:= ODLGPLA:ACOLS[nUltLinh][nPos13] //FPA_LOCDIA

		//replica para as outras obras
		For nY := 1 To Len(aObrasRep)

			AADD(OPLA_COLS, Aclone(ODLGPLA:ACOLS[nUltLinh]))
			//atualiza obra e seqgru
			cSeqGruAux	:= "000"
			nUltOPla	:= Len(OPla_Cols)
			nPosAux		:= Ascan(OPla_Cols,{|x| x[nPosObra] == aObrasRep[nY][2]})
			//busca o maior SeqGru para a Obra
			While nPosAux > 0
				nPosAux		:= Ascan(OPla_Cols,{|x| x[nPosObra] == aObrasRep[nY][2]}, nPosAux+1)
				If nPosAux > 0
					cSeqGruAux	:= OPla_Cols[nPosAux][nPos17]
				EndIf
			EndDo
			//Atualiza no Ar
			OPla_Cols[nUltOPla][nPos16] := aObrasRep[nY][2]
			OPla_Cols[nUltOPla][nPos17]	:= Soma1(cSeqGruAux)

		Next nY

	Next nX

	ODLGPLA:OBROWSE:REFRESH()
	ODLGPLA:REFRESH()
	ODLGPLA:LNEWLINE := .F.
EndIf

RestArea(aAreaDA1)
RestArea(aAreaSB1)

Return

Static Function EspPicVld(cCampo,xValue)
Local lRet		:= .T.
Local aArea		:= {}
Local cDescricao:= ""
Local nForca    := 0

If !Empty(xValue)
	If cCampo == "FPA_PRODUT"
		aArea		:= SB1->(GetArea())
		cDescricao	:= STR0037 // "Produto"
		SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
		lRet		:= SB1->(DbSeek(xFilial("SB1") + xValue))
	ElseIf cCampo == "FPA_LOCAL"
		aArea		:= NNR->(GetArea()) //NNR_FILIAL+NNR_CODIGO
		cDescricao	:= STR0038 //"Local de Estoque"
		NNR->(DbSetOrder(1))
		lRet		:= NNR->(DbSeek(xFilial("NNR") + xValue))	
	ElseIf cCampo == "FPA_CODTAB"
		aArea		:= DA0->(GetArea()) //DA0_FILIAL+DA0_CODTAB
		cDescricao	:= STR0039 //"Tabela de Preço"
		DA0->(DbSetOrder(1))
		lRet		:= DA0->(DbSeek(xFilial("DA0") + xValue))	
	ElseIf cCampo == "FPA_GRUA"	
		aArea		:= ST9->(GetArea()) //T9_FILIAL+T9_CODBEM
		cDescricao	:= STR0040 //"Bem"
		ST9->(DbSetOrder(1))
		lRet		:= ST9->(DbSeek(xFilial("ST9") + xValue))	
	ElseIf cCampo == "FPA_CONPAG"
		aArea		:= SE4->(GetArea()) //E4_FILIAL+E4_CODIGO
		cDescricao	:= STR0041 //"Condição de Pagamento"
		SE4->(DbSetOrder(1))
		lRet		:= SE4->(DbSeek(xFilial("SE4") + xValue))		
	ElseIf cCampo == "FPA_TESREM" .Or.  cCampo == "FPA_TESFAT" .or. nForca == 1
		aArea		:= SF4->(GetArea()) //F4_FILIAL+F4_CODIGO
		cDescricao	:= STR0042 //"Tipo de Entrada/Saída (TES)"
		SF4->(DbSetOrder(1))
		lRet		:= SF4->(DbSeek(xFilial("SF4") + xValue))	
	ElseIf cCampo == "FPA_CUSTO"  .or. nForca == 2
		aArea		:= CTT->(GetArea()) //CTT_FILIAL+CTT_CUSTO
		cDescricao	:= STR0043 //"Centro de Custo"
		CTT->(DbSetOrder(1))
		lRet		:= CTT->(DbSeek(xFilial("CTT") + xValue))		
	ElseIf cCampo == "FPA_NATURE" .or. nForca == 3
		aArea		:= SED->(GetArea()) //ED_FILIAL+ED_CODIGO
		cDescricao	:= STR0038 //"Local de Estoque"
		SED->(DbSetOrder(1))
		lRet		:= SED->(DbSeek(xFilial("SED") + xValue))		
	EndIf 
EndIf 

If !lRet
	FWAlertWarning(STR0044 + cDescricao + STR0045 + CRLF + STR0030 + cCampo + CRLF + STR0045 + xValue, STR0025) // "Inconsistência de dados. O " #### " não foi localizado!"  #### "Campo: " #### "Valor: " #### "Erro"
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} RepliPick
Função SPMarkTe, cria um markbrowse editavel.
@param Não recebe parâmetros
@return Não retorna nada
@author Rafael Goncalves
@owner sempreju.com.br
@version Protheus 12
@since Out|2020
/*/
 
Static Function RepliPick()
Local nX		:= 0
Local aObrasRep	:= {}
Local aButtons	:= {}
Local aSize		:= MsAdvSize(.F.)
Local nMSEsq   	:= aSize[7]		//Margem Superior Esquerda
Local nMIEsq   	:= 0			//Margem Inferior Esquerda
Local nMIDir 	:= aSize[6]		//Margem Superior Direita
Local nMSDir  	:= aSize[5]  	//Margem Inferior Direita
Local lAtualiza	:= .F.

Private lMarker     := .T.
Private aLstObras	:= {}
 
//Alimenta o array
BUSDATA()
 
//DEFINE MsDIALOG o3Dlg TITLE 'Seleção de Obras' From 0, 4 To 650, 1180 Pixel
DEFINE MsDIALOG o3Dlg TITLE 'Seleção de Obras' From nMSEsq,nMIEsq  To (nMIDir / 1.4),(nMSDir / 1.6) Pixel
     
    oPnMaster := tPanel():New(0,0,,o3Dlg,,,,,,0,0)
    oPnMaster:Align := CONTROL_ALIGN_ALLCLIENT
 
    oDespesBrw := fwBrowse():New()
    oDespesBrw:setOwner( oPnMaster )
	oDespesBrw:SetDescription("Indicação de de Obras")
 
    oDespesBrw:setDataArray()
    oDespesBrw:setArray( aLstObras )
    oDespesBrw:disableConfig()
    oDespesBrw:disableReport()
 
    oDespesBrw:SetLocate() // Habilita a Localização de registros
 
    //Create Mark Column
    oDespesBrw:AddMarkColumns({|| IIf(aLstObras[oDespesBrw:nAt,01], "LBOK", "LBNO")},; //Code-Block image
        {|| SelectOne(oDespesBrw, aLstObras)},; //Code-Block Double Click
        {|| SelectAll(oDespesBrw, 01, aLstObras) }) //Code-Block Header Click
 
    oDespesBrw:addColumn({"Obra"              , {||aLstObras[oDespesBrw:nAt,02]}, "C", "@!"    , 1,   3    ,                            , .F. , , .F.,, "aLstObras[oDespesBrw:nAt,02]",, .F., .T.,                                    , "ETDESPES1"    })
    oDespesBrw:addColumn({"Nome da Obra"      , {||aLstObras[oDespesBrw:nAt,03]}, "C", "@!"    , 1,  40    ,                            , .F. , , .F.,, "aLstObras[oDespesBrw:nAt,03]",, .F., .T.,                                    , "ETDESPES2"    })
    //oDespesBrw:addColumn({"Grp de Produ"      , {||aLstObras[oDespesBrw:nAt,04]}, "C", "@!"    , 1,   6    ,                            , .F. , , .F.,, "aLstObras[oDespesBrw:nAt,04]",, .F., .T.,                                    , "ETDESPES3"    })
    //oDespesBrw:addColumn({"Descrição"         , {||aLstObras[oDespesBrw:nAt,05]}, "C", "@!"    , 1,  70    ,                            , .F. , , .F.,, "aLstObras[oDespesBrw:nAt,05]",, .F., .T.,                                    , "ETDESPES4"    })
 
    oDespesBrw:setEditCell( .T. , { || .T. } ) //activa edit and code block for validation
 
    /*
    oDespesBrw:acolumns[2]:ledit     := .T.
    oDespesBrw:acolumns[2]:cReadVar:= 'aLstObras[oBrowse:nAt,2]'*/
 
    oDespesBrw:Activate(.T.)
 
Activate MsDialog o3Dlg CENTERED  ON INIT ENCHOICEBAR(o3Dlg , {||lAtualiza := .T. ,o3Dlg:End()} , {|| lAtualiza := .F.,o3Dlg:End()} , , aButtons) 

If lAtualiza
	For nX := 1 To Len(aLstObras)
		If aLstObras[nX][1]
			Aadd(aObrasRep,aClone(aLstObras[nX]))
		EndIf
	Next nX
EndIf

return aObrasRep
 
Static Function SelectOne(oBrowse, aArquivo)
aArquivo[oDespesBrw:nAt,1] := !aArquivo[oDespesBrw:nAt,1]
oBrowse:Refresh()
Return .T.
 
Static Function SelectAll(oBrowse, nCol, aArquivo)
Local _ni := 1
For _ni := 1 to len(aArquivo)
    aArquivo[_ni,1] := lMarker
Next
oBrowse:Refresh()
lMarker:=!lMarker
Return .T.
 
//Alimenta a tabela temporaria
Static Function BUSDATA()
Local nPosObra	:= ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_OBRA"})
Local nPosNome	:= ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_NOMORI"})
//Local nPosGrup	:= ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_XGRUPO"})
//Local nPosDesc	:= ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_XGRDES"})
Local nX		:= 0
Local lMarcado	:= .F.

aLstObras := {}
 
For nX := 1 To Len(oDlgObr:aCols)
	If nX <> ODLGOBR:NAT
    	//aadd(aLstObras,	{lMarcado, oDlgObr:aCols[nX][nPosObra], oDlgObr:aCols[nX][nPosNome], oDlgObr:aCols[nX][nPosGrup], oDlgObr:aCols[nX][nPosDesc]    })
    	aadd(aLstObras,	{lMarcado, oDlgObr:aCols[nX][nPosObra], oDlgObr:aCols[nX][nPosNome]   })
	EndIf
Next nX
 
Return .t.
