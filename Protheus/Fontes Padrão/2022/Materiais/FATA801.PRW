#INCLUDE "FATA801.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA801
Rotina de exportação periódica para integração com Neogrid S&OP

@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Function FATA801(aParams)

Local bProcess 		:= {|oSelf| FATA801X(oSelf,lFATA800) }    
Local cPerg 		:= "FATA801"  
Local cDescProc		:= ""
Local oProcess		:= nil
Local lFATA800 		:= .F.
Local lJob			:= .F.
Local oProcess800 	:= nil
Local dDtIni 		:= cTod("//")
Local dDtFim 		:= cTod("//")
Local cEmpJob 		:= ""
Local cFilJob 		:= ""

If ValType(aParams) != 'U' .And. !Empty(aParams)

	If ValType(aParams[1]) == "A" //Schedule
	
		cEmpJob := aParams[2]
		cFilJob := aParams[3]

		PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob MODULO "FAT" TABLES "ACY", "SA1", "SA3", "SB1", "DA1", "SF1", "SF2", "SD1", "SD2"
		
		lJob := .T.
	
		dDtIni := If(ValType(aParams[1][1])=='N',dDataBase-aParams[1][1],dDataBase)
		dDtFim := If(ValType(aParams[1][2])=='D',aParams[1][2],dDtIni)
		
	Else

		oProcess800 := If(Len(aParams)==5,aParams[5],Nil)

	EndIf
		
EndIf
	
If (lFATA800 := ValType(oProcess800)=='O')

	dDtIni := aParams[1]
	dDtFim := aParams[2]

EndIf

Pergunte(cPerg,.F.)

//Não recebeu data inicial
If Empty(dDtIni) 

	cDescProc := STR0001  //"Rotina para exportação periódica dos arquivos "
	cDescProc += STR0002 //"necessários para a integração entre o ERP "
	cDescProc += STR0003 //"Protheus e o sistema Neogrid S&OP."
	
	oProcess := tNewProcess():New("FATA801",STR0004,bProcess,cDescProc,cPerg,/*aInfoCustom*/, .T.,5, /*"Descrição do painel Auxiliar"*/, .T. ) //"Exportação Periódica Neogrid S&OP"
	
ElseIf ValType(oProcess800)=='O' //Recebeu a data inicial e o objeto do processo, chamada via FATA800

	FATA801X(oProcess800,lFATA800,dDtIni,dDtFim)

ElseIf lJob //Recebeu a data inicial e não o objeto, chamada via schedule

	FATA801X(Nil,lFATA800,dDtIni,dDtFim)
	
	RESET ENVIRONMENT
	
EndIf

Return                                       

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA801X

Rotina de Processamento da Exportação dos arquvios

@param oProcess   - Objeto do Processo
@param lFATA800	- Valida se é carga inicial
@param dIni		- Data de início da exportação
@param dFim		- Data final da exportação

@return lRet		- Retorno do processo (.T. ou .F.)
 
@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function FATA801X(oProcess,lFATA800,dIni,dFim)   

Local lRet		:= .T.
Local lTemProc	:= ValType(oProcess)=='O'
Local aSrvInfo	:= GetSrvInfo()
Local cBarra	:= If("LINUX"$Upper(aSrvInfo[2]),'/','\')

DEFAULT lFATA800 := .F.
DEFAULT dIni := MV_PAR01
DEFAULT dFim := MV_PAR02

Private nEntDD1	:= SuperGetMv('MV_FATSOPD',, .F. )
Private cPathExp	:= SuperGetMv('MV_FATSOPP',, .F. )

Private cPathRoot	:= GetSrvProfString( 'StartPath', '' )

Private lReenvia	:= If(lFATA800,.T.,If(ValType(oProcess)=='O',MV_PAR03==2,.F.))

If nEntDD1 == 0
	
	If lTemProc
	
		oProcess:SaveLog(STR0005) //"Erro. O parâmetro MV_FATSOPD (Entidade DD1) não está preenchido corretamente."
		
	Else
	
		ConOut(STR0006) //"FATA801 - Erro. O parâmetro MV_FATSOPD (Entidade DD1) não está preenchido corretamente."
		
	EndIf
	
	lRet := .F.
	
ElseIf Empty(cPathExp)

	If lTemProc
	
		oProcess:SaveLog(STR0007) //"Erro. O parâmetro MV_FATSOPP (Path Exportação) não está preenchido corretamente."
		
	Else
	
		ConOut(STR0008) //"FATA801 - Erro. O parâmetro MV_FATSOPP (Path Exportação) não está preenchido corretamente."
		
	EndIf
	
	lRet := .F.
	
Else

	If Right(cPathExp,1)!= cBarra

		cPathExp += cBarra
		
	EndIf
	
	If Left(cPathExp,1)==cBarra
		cPathExp := Substr(cPathExp,2)
	EndIf
	
	If Right(cPathRoot,1)!= cBarra

		cPathRoot += cBarra
		
	EndIf
	
	cPathExp := cPathRoot+cPathExp	
	
EndIf

If lRet

	//Inicio de processo
	If lTemProc
	
		oProcess:SetRegua1(If(lFATA800,5,4)) //Define quantidade de arquivos exportados, dependendo se é a chamada do FATA800 ou não
		
		oProcess:IncRegua1(STR0009) //"Processando arquivo de Dimensão de Demanda 1"
	
	Else
	
		ConOut(STR0010) //"FATA801 - Processando arquivo de Dimensão de Demanda 1"
		
	EndIf
	
	//Exporta DD1
	If !(lRet := ProcDD1(oProcess,dIni,dFim))
	
		If lTemProc
	
			oProcess:SaveLog(STR0011) //"Ocorreram erros durante a exportação da Dimensão de Demanda 1."
	
		Else	
	
			ConOut(STR0012) //"FATA801 - Ocorreram erros durante a exportação da Dimensão de Demanda 1."
			
		EndIf
		
	EndIf
	
EndIf

//Exporta DD2
If lRet .And. lFATA800

	If lTemProc
	
		oProcess:IncRegua1(STR0013) //"Processando arquivo de Dimensão de Demanda 2"
		
	Else
	
		ConOut(STR0014) //"FATA801 - Processando arquivo de Dimensão de Demanda 2"
		
	EndIf
	
	If !(lRet := ProcDD2(oProcess,dIni,dFim))
	
		If lTemProc
		
			oProcess:SaveLog(STR0015) //"Ocorreram erros durante a exportação da Dimensão de Demanda 2."
			
		Else
		
			ConOut(STR0016) //"FATA801 - Ocorreram erros durante a exportação da Dimensão de Demanda 2."
			
		EndIf
	
	EndIf

EndIf

//Exporta Itens
If lRet

	If lTemProc
	
		oProcess:IncRegua1(STR0017) //"Processando arquivo de Itens"
		
	Else
	
		ConOut(STR0018) //"FATA801 - Processando arquivo de Itens"
		
	EndIf
	
	If !(lRet := ProcItem(oProcess,dIni,dFim))
	
		If lTemProc
	
			oProcess:SaveLog(STR0019) //"Ocorreram erros durante a exportação dos Itens."
			
		Else
		
			ConOut(STR0020) //"FATA801 - Ocorreram erros durante a exportação dos Itens."
			
		EndIf
	
	EndIf
	
EndIf

//Exporta Movimento
If lRet

	If lTemProc
	
		oProcess:IncRegua1(STR0021) //"Processando arquivo de Movimento"
		
	Else
	
		ConOut(STR0022) //"FATA801 - Processando arquivo de Movimento"
		
	EndIf
	
	
	If !(lRet := ProcMov(oProcess,dIni,dFim))
	
		If lTemProc
		
			oProcess:SaveLog(STR0023) //"Ocorreram erros durante a exportação do Movimento."
			
		Else
		
			ConOut(STR0024) //"FATA801 - Ocorreram erros durante a exportação do Movimento."
			
		EndIf
	
	EndIf
	
	
EndIf

//Exporta Lista de Preço
If lRet

	If lTemProc
	
		oProcess:IncRegua1(STR0025) //"Processando arquivo de Lista de Preço"
		
	Else
	
		ConOut(STR0026) //"FATA801 - Processando arquivo de Lista de Preço"
		
	EndIf
	
	If !(lRet := ProcLista(oProcess,dIni,dFim))
	
		If lTemProc
		
			oProcess:SaveLog(STR0027) //"Ocorreram erros durante a exportação da Lista de Preço."
			
		Else
		
			ConOut(STR0028) //"FATA801 - Ocorreram erros durante a exportação da Lista de Preço."
			
		EndIf
	
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcDD1

Processamento do Arquivo de Dimensão de Demanda 1

@param oProcess   - Objeto do Processo
@param dIni		- Data de início da exportação
@param dFim		- Data final da exportação

@return lRet		- Retorna se os dados foram processados(.T. ou .F.)
 
@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function ProcDD1(oProcess,dIni,dFim)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasQry	:= If(nEntDD1==1,"SM0",GetNextAlias())
Local lTemProc	:= ValType(oProcess) == 'O'
Local cQuery		:= ""
Local aTblDD1		:= {"SM0","ACY","SA1","SA3"}
Local aCodDD1		:= {"M0_CODFIL","ACY_GRPVEN","lTrim(rTrim(A1_COD))+'-'+A1_LOJA","A3_COD"}
Local aCodDD1p	:= {"M0_CODFIL","ACY_GRPVEN","lTrim(rTrim(A1_COD))|| A1_LOJA", "A3_COD"  }
Local aDescDD1	:= {"M0_FILIAL","ACY_DESCRI","A1_NOME","A3_NOME"}
Local aObsDD1		:= {"M0_FILIAL","ACY_DESCRI","A1_OBSERV","A3_NREDUZ"}
Local aIncDD1		:= {"","ACY_USERGI","A1_USERLGI","A3_USERLGI"}
Local aAltDD1		:= {"","ACY_USERGA","A1_USERLGA","A3_USERLGA"}
Local aFlagDD1	:= {"","ACY_MSEXP","A1_MSEXP","A3_MSEXP"}
Local dInc			:= ctod('')
Local dAlt			:= ctod('')
Local nCont		:= 0
Local cFile		:= cPathExp + "X_" + dtos(dDataBase) + "_dimdemanda1.xml"

Local nHandle		:= 0
Local nLoop		:= 0
Local cXml  		:= ""
Local lConsole 	:= .T.

If nEntDD1==1
	
	DbSelectArea('SM0')
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt))
		
	While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
		nCont++
		SM0->(DbSkip())
	EndDo
		
	SM0->(DbSeek(cEmpAnt))
		
Else
	
	cQuery := "Select " + aCodDD1p[nEntDD1] + " AS CODIGO, "
	cQuery += "         R_E_C_N_O_ AS NUMREC "
	cQuery += "  From " + RetSqlName(aTblDD1[nEntDD1]) + " "
	cQuery += " Where D_E_L_E_T_ <> '*' "
	cQuery += " Order By CODIGO "
				
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
		
	TcSetField(cAliasQry,'NUMREC','N',12,0)
		
	COUNT TO nCont
		
	(cAliasQry)->(DbGoTop())
	
EndIf
	
If nCont > 0
	If (nHandle := fCreate(cFile)) > 0
	
		If lTemProc

			oProcess:SetRegua2(nCont)

		Else
		
			ConOut(STR0029 + cFile) //"FATA801 - Iniciando geração do arquivo "
			
		EndIf
		
		cXml := '<?xml version="1.0" encoding="UTF-8"?>'+CRLF
		cXml += '<DIMENSAODEMANDA1 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file://DimensaoDemanda1.xsd">'+CRLF
		
		While !(cAliasQry)->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
		
			If lTemProc
			
				oProcess:IncRegua2(STR0030) //"Processando Dimensão de Demanda 1"
				
			EndIf
		
			If nEntDD1 != 1
			
				(aTblDD1[nEntDD1])->(DbGoTo((cAliasQry)->NUMREC))
				
				dInc := ctod((aTblDD1[nEntDD1])->(FWLeUserLg(aIncDD1[nEntDD1],2)))
				dAlt := ctod((aTblDD1[nEntDD1])->(FWLeUserLg(aAltDD1[nEntDD1],2)))
				
			EndIf
				
			IF (Empty((aTblDD1[nEntDD1])->&(aIncDD1[nEntDD1])) .Or. ;
			   (dInc >= dIni .And. dInc <= dFim) .Or. ;
			   (dAlt >= dIni .And. dAlt <= dFim) ) .And. ;
			   ( lReenvia .Or. Empty((aTblDD1[nEntDD1])->&(aFlagDD1[nEntDD1])) )			         
			
				cXml += 		'<DIMENSAODEMANDACOL>'+CRLF
				cXml += 			'<CodDimensaoDemanda>'+AllTrim((aTblDD1[nEntDD1])->&(aCodDD1[nEntDD1]))+'</CodDimensaoDemanda>'+CRLF
				cXml +=			'<Descricao>'+AllTrim((aTblDD1[nEntDD1])->&(aDescDD1[nEntDD1]))+'</Descricao>'+CRLF
				For nLoop := 1 To 6
					cCodGrupo := cValToChar( nLoop )
					cXml +=	'<Grupo'+cCodGrupo+'>'+ AllTrim((aTblDD1[nEntDD1])->&(aCodDD1[nEntDD1])) + "GRP" + cCodGrupo +'</Grupo'+cCodGrupo+'>' +CRLF
				Next nLoop
				cXml +=	      	'<Observacao>'+AllTrim((aTblDD1[nEntDD1])->&(aObsDD1[nEntDD1]))+'</Observacao>'+CRLF
				cXml +=		'</DIMENSAODEMANDACOL>'+CRLF
				
				If nEntDD1 != 1
				
					(aTblDD1[nEntDD1])->(RecLock(aTblDD1[nEntDD1],.F.))
					(aTblDD1[nEntDD1])->&(aFlagDD1[nEntDD1]) := DTos( ddatabase )
					(aTblDD1[nEntDD1])->(MsUnlock())
				
				EndIf
			
			EndIf
			
			(cAliasQry)->(DbSkip())
			
		EndDo
		
		cXml += '</DIMENSAODEMANDA1>'
		
		cXml := NoAcento( AnsiToOem( cXml ) )
		
		FWrite(nHandle,cXml)
					
		fClose(nHandle)
		
		//Se não encontrar a continuação da composição do XML apaga o arquivo, pois, não existem dados a exportar.
		If At( "<CodDimensaoDemanda>", cXml ) == 0 
			FErase( cFile )
			lConsole := .F. 
		EndIf	
			
		If nEntDD1 != 1
			(cAliasQry)->(DbCloseArea())
		EndIf
		
	Else
	
		lRet := .F.
	
		If lTemProc
	
			oProcess:SaveLog(STR0036 + cFile) //"Erro. Não foi possível criar o arquivo "
		
		Else
	
			ConOut(STR0037 + cFile) //"FATA801 - Erro. Não foi possível criar o arquivo "
		
		EndIf
	
	EndIf
		
	If lTemProc .And. lConsole
		
		oProcess:SaveLog(STR0031 + cFile + STR0032) //"O arquivo "###" foi criado com sucesso."
	
	ElseIf  lTemProc
			
		oProcess:SaveLog(STR0031 + cFile + STR0053) //"O arquivo "###" " não foi criado, pois não há dados passíveis de exportação."
			
	ElseIf lConsole
		
		ConOut(STR0033 + cFile + STR0032) //"FATA801 - O arquivo "###" foi criado com sucesso."
	
	Else
	
		ConOut(STR0033 + cFile + STR0053) //"FATA801 - O arquivo "###" " não foi criado, pois não há dados passíveis de exportação."
		
	EndIf
		
Else

	If lTemProc
		
		oProcess:SaveLog(STR0034 + cFile + ".") //"Não existem registros para gerar o arquivo "
		
	Else
		
		ConOut(STR0035 + cFile + ".") //"FATA801 - Não existem registros para gerar o arquivo "
			
	EndIf
	
EndIf

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcDD2

Processamento do Arquivo de Dimensão de Demanda 2

@param oProcess   - Objeto do Processo
@param dIni		- Data de início da exportação
@param dFim		- Data final da exportação

@return lRet		- Retorna se os dados foram processados(.T. ou .F.)
 
@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function ProcDD2(oProcess,dIni,dFim)

Local lRet		:= .T.
Local nHandle	:= 0
Local cFile		:= cPathExp + "X_" + dtos(dDataBase) + "_dimdemanda2.xml"
Local lTemProc	:= ValType(oProcess) == 'O'
Local cEmpProc	:= AllTrim(cEmpAnt)
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local nLoop		:= 0
Local cXml			:= ""
Local cGrupo		:= ""

If lTemProc

	oProcess:SetRegua2(2)

Else

	ConOut(STR0038) //"FATA801 - Exportando arquivo de Dimensão de Demanda 2"
	
EndIf

If (nHandle := fCreate(cFile)) > 0

	If lTemProc
	
		oProcess:IncRegua2(STR0039) //"Exportando arquivo de Dimensão de Demanda 2"
		
	EndIf

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt+cFilAnt))
	
	cXml := '<?xml version="1.0" encoding="UTF-8"?>' +CRLF
	cXml += '<DIMENSAODEMANDA2 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file://DIMENSAODEMANDA2.xsd">'+CRLF
	cXml += 	'<DIMENSAODEMANDACOL>'+CRLF
	cXml += 		'<CodDimensaoDemanda>'+cEmpProc+'</CodDimensaoDemanda>'+CRLF
	cXml += 		'<Descricao>'+If(!Empty(SM0->M0_NOMECOM),AllTrim(SM0->M0_NOMECOM),If(!Empty(SM0->M0_NOME),AllTrim(SM0->M0_NOME),cEmpProc))+'</Descricao>'+CRLF
	
	For nLoop := 1 To 6
		cGrupo := cValToChar( nLoop )
		cXml += 		'<Grupo'+cGrupo+'>'+cEmpProc + "GRP" + AllTrim(Str(nLoop))+'</Grupo'+cGrupo+'>'+CRLF
	Next nLoop
	
	If !Empty(SM0->M0_NOME)
		cXml += 		'<Observacao>'+AllTrim(SM0->M0_NOME)+'</Observacao>'+CRLF
	Else
		cXml += 		'<Observacao>'+Space(10)+'</Observacao>'+CRLF
	EndIf
		
	cXml += 	'</DIMENSAODEMANDACOL>'+CRLF
	cXml += '</DIMENSAODEMANDA2>'+CRLF
	
	cXml := NoAcento( AnsiToOem( cXml ) )
	
	fWrite(nHandle,cXML)
	
	fClose(nHandle)
	
	If lTemProc
	
		oProcess:SaveLog(STR0031 + cFile + STR0032) //"O arquivo "###" foi criado com sucesso."
		
	Else
	
		ConOut(STR0033 + cFile + STR0032) //"FATA801 - O arquivo "###" foi criado com sucesso."
		
	EndIf
	
	If lTemProc
	
		oProcess:IncRegua2(STR0039) //"Exportando arquivo de Dimensão de Demanda 2"
		
	EndIf

Else

	If lTemProc
	
		oProcess:IncRegua2(STR0039) //"Exportando arquivo de Dimensão de Demanda 2"
		
	EndIf

	lRet := .F.
	
	If lTemProc
	
		oProcess:SaveLog(STR0036 + cFile) //"Erro. Não foi possível criar o arquivo "
		
	Else
	
		ConOut(STR0037 + cFile) //"FATA801 - Erro. Não foi possível criar o arquivo "
		
	EndIf
	
	If lTemProc
	
		oProcess:IncRegua2(STR0039) //"Exportando arquivo de Dimensão de Demanda 2"
		
	EndIf
	
EndIf

SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcItem

Processamento do Arquivo de Itens

@param oProcess   - Objeto do Processo
@param dIni		- Data de início da exportação
@param dFim		- Data final da exportação

@return lRet		- Retorna se os dados foram processados(.T. ou .F.)
 
@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function ProcItem(oProcess,dIni,dFim)

Local lRet			:= .T.
Local nHandle		:= 0
Local nLoop		:= 0
Local nCont		:= 0
Local cFile		:= cPathExp + "X_" + dtos(dDataBase) + "_itens.xml"
Local cFilQry		:= ""
Local cXml			:= ""
Local cGrupo		:= ""
Local cQuery		:= ""
Local cAliasQry	:= GetNextAlias()
Local lTemProc	:= ValType(oProcess) == 'O'
Local aArea		:= GetArea()
Local cExpo		:= ""		
Local cHrExpo 	:= ""
Local lConsole	:= .T.

SX5->(DbSetOrder(1))
SBM->(DbSetOrder(1))
NNR->(DbSetOrder(1))

//If (nHandle := fCreate(cFile)) > 0

If ExistBlock( "FT801Item" )
	cFilQry := ExecBlock( "FT801Item", .F., .F. )
	If ValType( cFilQry ) <> 'C'
		cFilQry := ""
	EndIf
EndIf

cQuery := "Select B1_COD, B1_CODBAR, B1_DESC, B1_UM, "
cQuery += "       B1_PROC, B1_LOJPROC, B1_TIPO, B1_GRUPO, B1_LOCPAD, B1_GRUPCOM, "
cQuery += "       B1_USERLGI, R_E_C_N_O_ AS NUMREC, B1_MSEXP, B1_HREXPO "
cQuery += "  From " + RetSqlName('SB1') + " SB1 "
cQuery += " Where D_E_L_E_T_ <> '*' " +cFilQry
cQuery += " Order by B1_COD "
	
cQuery := ChangeQuery(cQuery)
	
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
TcSetField(cAliasQry,'NUMREC','N',12,0)
		
COUNT TO nCont
	
(cAliasQry)->(DbGoTop())
	
If nCont > 0
	
	If (nHandle := fCreate(cFile)) > 0
	
		If lTemProc
		
			oProcess:SetRegua2(nCont)
			
		Else
		
			ConOut(STR0029 + cFile) //"FATA801 - Iniciando geração do arquivo "
			
		EndIf
	
		cXML := '<?xml version="1.0" encoding="utf-8"?>' + CRLF
		cXml += '<PRODUTO xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file://PRODUTO.xsd">'+CRLF
		cXml += '<ITEM>' + CRLF
		
		DbSelectArea( "AIR" )// Controle de Exportação
		DbSetOrder( 2 )// AIR_FILIAL+AIR_CODINT+AIR_TAG+AIR_TABELA
		If DbSeek( xFilial( "AIR" ) + "000001" + "0001" +"SB1" )
			cExpo 	 := AIR->AIR_MSEXP
			cHrExpo := AIR->AIR_HREXPO
		EndIf
		
		While !(cAliasQry)->(Eof())
		
			If lTemProc
			
				oProcess:IncRegua2(STR0040) //"Processando Itens"
				
			EndIf
		
			dInc := ctod((cAliasQry)->(FWLeUserLg("B1_USERLGI",2)))
							
			If	( Empty( ( cAliasQry )->B1_MSEXP ) .Or. ;
				  Empty( ( cAliasQry )->B1_USERLGI ) .Or. ;	
				  ( dInc >= dIni .And. dInc <= dFim ) .Or. ; 
				( ( cAliasQry )->B1_MSEXP + ( cAliasQry )->B1_HREXPO > cExpo + cHrExpo ) ) .And. ;
				( lReenvia .Or. Empty( ( cAliasQry )->B1_MSEXP ) ) 			
			
			
			
				cXml += '<ITENS>' + CRLF
				cXml += '<ProdCod>' +AllTrim((cAliasQry)->B1_COD)+ '</ProdCod>' + CRLF
				cXml += '<ProdBar>' +If(!Empty((cAliasQry)->B1_CODBAR),AllTrim((cAliasQry)->B1_CODBAR),"NULO")+ '</ProdBar>' + CRLF
				cXml += '<ProdDes>' +AllTrim((cAliasQry)->B1_DESC)+ '</ProdDes>' + CRLF
				cXml += '<UnidMed>' +AllTrim((cAliasQry)->B1_UM)+ '</UnidMed>' + CRLF
				cXml += '<FtConv>' +"1,00"+ '</FtConv>' + CRLF
				      
				If !Empty((cAliasQry)->B1_PROC) .And.	SA2->(DbSeek(xFilial('SA2')+(cAliasQry)->B1_PROC+(cAliasQry)->B1_LOJPROC))
					cXML += '<FornCod>'+AllTrim(SA2->A2_NOME)+'</FornCod>' + CRLF
				Else
					cXml += '<FornCod>'+"1"+'</FornCod>' + CRLF
				EndIf
				
				      
				If SX5->(DbSeek(xFilial('SX5')+'02'+(cAliasQry)->B1_TIPO))
					cXML += '<Grupo1>'+AllTrim(SX5->X5_DESCRI)+'</Grupo1>' + CRLF
				Else
					cXML += '<Grupo1>'+"N/A"+'</Grupo1>' + CRLF
				EndIf
				      
				If !Empty((cAliasQry)->B1_GRUPO) .And. SBM->(DbSeek(xFilial('SBM')+(cAliasQry)->B1_GRUPO))
					cXML += 	'<Grupo2>'+AllTrim(SBM->BM_DESC)+'</Grupo2>' + CRLF
				Else
					cXML += 	'<Grupo2>'+"N/A"+'</Grupo2>' + CRLF
				EndIf
							
				If !Empty((cAliasQry)->B1_LOCPAD) .And. NNR->(DbSeek(xFilial('NNR')+(cAliasQry)->B1_LOCPAD))
					cXML += 	'<Grupo3>'+AllTrim(NNR->NNR_DESCRI)+'</Grupo3>' + CRLF
				Else
					cXML += 	'<Grupo3>'+"N/A"+'</Grupo3>'	+ CRLF
				EndIf
				
				If !Empty((cAliasQry)->B1_GRUPCOM)
					cXML += 	'<Grupo4>'+AllTrim((cAliasQry)->B1_GRUPCOM)+'</Grupo4>' + CRLF
				Else
					cXML += 	'<Grupo4>'+"N/A"+'</Grupo4>' + CRLF
				EndIf
						
				cXML +=	    '<Grupo5>'+"IG5"+'</Grupo5>' + CRLF
				cXML +=	    '<Grupo6>'+"IG6"+'</Grupo6>' + CRLF
				      
				cXml += '<FatorConversao1>' +"1,00"+ '</FatorConversao1>' + CRLF
				cXml += '<FatorConversao2>' +"1,00"+ '</FatorConversao2>' + CRLF
				cXml += '<FatorConversao3>' +"1,00"+ '</FatorConversao3>' + CRLF
				      
				      
				For nLoop := 7 To 12
					cGrupo :=  cValToChar( nLoop )
					cXML +=	'<Grupo'+cGrupo+'>'+"IG" + AllTrim(Str(nLoop))+'</Grupo'+cGrupo+'>' + CRLF
				Next nLoop
				      
				cXml += '</ITENS>' + CRLF
				  						
			EndIf
					
			(cAliasQry)->(DbSkip())
		
		EndDo
					
		cXml += '</ITEM>' + CRLF
		cXML +=	'</PRODUTO>' + CRLF
		
		cXml := NoAcento( AnsiToOem( cXml ) )
		
		//-----------------------------------------------------------
		// Rotina que faz o controle da Exportação
		//-----------------------------------------------------------				
		If Ft802Expo( /*cCodInt*/"000001", /*cTag*/"0001",/*cTabela*/"SB1", cQuery, /*cNameRec*/"NUMREC" )
			fWrite( nHandle, cXml )
		Else
			Help( " ", 1, 'FT801NOEXPO' )//"Houve problemas com a gravação do log do arquivo. Por favor, verifique os parâmetros informados."
			lRet := .F.
			oProcess:SaveLog( STR0054 +cFile+ STR0055 ) //"Houve problemas com a gravação do log do arquivo "###". Por favor, verifique os parâmetros informados."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
		EndIf
		
		fClose(nHandle)
		//Se a tag não existir no XML, significa que não há dados a exportar, sendo assim, exclui o arquivo.
		If At( "<ProdCod>", cXml ) == 0 
			FErase( cFile )
			lConsole := .F.
		EndIf
	
		(cAliasQry)->(DbCloseArea())
					
		If lTemProc .And. lConsole
		
			oProcess:SaveLog(STR0031 + cFile + STR0032) //"O arquivo "###" foi criado com sucesso."
		
		ElseIf lConsole
		
			ConOut(STR0033 + cFile + STR0032) //"FATA801 - O arquivo "###" foi criado com sucesso."
			
		ElseIf  lTemProc
			
			oProcess:SaveLog(STR0031 + cFile + STR0053) //"O arquivo "###" " não foi criado, pois não há dados passíveis de exportaçao."
					
		Else
			
			ConOut(STR0033 + cFile + STR0053 ) //"O arquivo "###" " não foi criado, pois não há dados passíveis de exportaçao."
			
		EndIf
		
	Else
	
		lRet := .F.
	
		If lTemProc
	
			oProcess:SaveLog(STR0036 + cFile) //"Erro. Não foi possível criar o arquivo "
		
		Else
	
			ConOut(STR0037 + cFile) //"FATA801 - Erro. Não foi possível criar o arquivo "
		
		EndIf
	
	EndIf
		
		
Else

	If lTemProc
		
		oProcess:SaveLog(STR0034 + cFile + ".") //"Não existem registros para gerar o arquivo "
			
	Else
		
		ConOut(STR0035 + cFile + ".") //"FATA801 - Não existem registros para gerar o arquivo "
			
	EndIf
	
EndIf
	
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcMov

Processamento do Arquivo de Movimentação DFU

@param oProcess   - Objeto do Processo
@param dIni		- Data de início da exportação
@param dFim		- Data final da exportação

@return lRet		- Retorna se os dados foram processados(.T. ou .F.)
 
@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function ProcMov(oProcess,dIni,dFim)

Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local cAliasQry	:= GetNextAlias()
Local aTblDD1		:= {"SM0","ACY","SA1","SA3"}
Local aCodDD1		:= {"M0_CODFIL","ACY_GRPVEN","AllTrim(A1_COD)+'-'+A1_LOJA","A3_COD"}
Local aIncDD1		:= {"","ACY_USERGI","A1_USERLGI","A3_USERLGI"}
Local aAltDD1		:= {"","ACY_USERGA"/*,"A1_USERLGA","A3_USERLGA"*/}
Local cFile		:= cPathExp + "X_" + dtos(dDataBase) + "_movim_dfu.xml"
Local cXml			:= ""
Local cQuery		:= ''
Local cProdAnt	:= ''
Local cLocAnt		:= ''
Local lTemProc	:= ValType(oProcess) == 'O'
Local lRet			:= .T.
Local dInc			:= ctod('')
Local dAlt			:= ctod('')
Local dEmisAnt	:= ctod('')
Local nCont		:= 0
Local nCusAnt		:= 0
Local nQtdVen		:= 0
Local nQtdDev		:= 0
Local nValVen		:= 0
Local nValDev		:= 0
Local nPrcMed		:= 0
Local nMarMed		:= 0
Local lConsole 	:= .T.

If nEntDD1==1
	
	DbSelectArea('SM0')
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt))
		
	While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
		nCont++
		SM0->(DbSkip())
	EndDo
		
	SM0->(DbSeek(cEmpAnt))
		
Else
				          
	nCont := (aTblDD1[nEntDD1])->(RecCount())
		
	(aTblDD1[nEntDD1])->(DbGoTop())
		
EndIf
	
If nCont > 0

	If (nHandle := fCreate(cFile)) > 0
		If lTemProc
		
			oProcess:SetRegua2(nCont)
			
		Else
		
			ConOut(STR0029 + cFile) //"FATA801 - Iniciando geração do arquivo "

		EndIf
		
		cXml := '<?xml version="1.0" encoding="utf-8"?>'+ CRLF
		cXml += '<MOVIMENTACAODFU xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file://MOVIMENTACAODFU.xsd">' +CRLF
		cXml += '<ITEM>' + CRLF
	
	
		While !(aTblDD1[nEntDD1])->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
		
			If lTemProc
			
				oProcess:IncRegua2(STR0041) //"Processando Movimentação"
			
			EndIf
			
			cQuery := "SELECT 1 AS TIPO, B1_COD, B1_CUSTD, "
			cQuery += "       SUM(D2_QUANT) AS QUANT, SUM(D2_QUANT * D2_PRCVEN ) AS VALOR, "
			cQuery += "       F2_EMISSAO AS EMISSAO, D2_LOCAL AS CODLOC "
			cQuery += "  FROM " + RetSqlName('SB1') + " SB1 "
			cQuery += " INNER JOIN " + RetSqlName('SD2') + " SD2 "
			cQuery += "    ON D2_COD = B1_COD "
			If nEntDD1 == 1
				cQuery += "   AND SD2.D2_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf
			If !lReenvia
				cQuery += "   AND SD2.D2_MSEXP = ' ' "
			EndIf
			cQuery += "   AND SD2.D_E_L_E_T_ <> '*' "
			cQuery += " INNER JOIN " + RetSqlName('SF4') + " SF4 "
			cQuery += "    ON F4_CODIGO = D2_TES AND F4_TIPO = 'S' AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ <> '*' "
			cQuery += " INNER JOIN " + RetSqlName('SF2') + " SF2 "
			cQuery += "    ON F2_FILIAL = D2_FILIAL "
			cQuery += "   AND F2_DOC = D2_DOC "
			cQuery += "   AND F2_EMISSAO BETWEEN '" + dtos(dIni) + "' AND '" + dtos(dFim) + "' "
			If nEntDD1 == 3
				cQuery += "   AND SF2.F2_CLIENTE = '" + SA1->A1_COD + "' "
				cQuery += "   AND SF2.F2_LOJA = '" + SA1->A1_LOJA + "' "
			EndIf
			If nEntDD1 == 4
				cQuery += "   AND SF2.F2_VEND1 = '" + SA3->A3_COD + "' "
			EndIf
			cQuery += "   AND SF2.D_E_L_E_T_ <> '*' "
			If nEntDD1 == 2
				cQuery += "   INNER JOIN " + RetSqlName('SA1') + " SA1 "
				cQuery += "      ON A1_COD = F2_CLIENTE "
				cQuery += "     AND A1_LOJA = F2_LOJA "
				cQuery += "     AND A1_GRPVEN = '" + ACY->ACY_GRPVEN + "' "
				cQuery += "     AND SA1.D_E_L_E_T_ <> '*' "
			EndIf
			cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
			If nEntDD1 == 1
				cQuery += "   AND SB1.B1_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf
			cQuery += " GROUP BY B1_COD, B1_CUSTD, F2_EMISSAO, D2_LOCAL "
			cQuery += "UNION ALL "
			cQuery += "SELECT 2 AS TIPO, B1_COD, B1_CUSTD, "
			cQuery += "       SUM(D1_QUANT) AS QUANT, SUM(D1_QUANT * D1_VUNIT) AS VALOR, "
			cQuery += "       F1_EMISSAO AS EMISSAO, D1_LOCAL AS CODLOC "
			cQuery += "  FROM " + RetSqlName('SB1') + " SB1 "
			cQuery += " INNER JOIN " + RetSqlName('SD1') + " SD1 "
			cQuery += "    ON D1_COD = B1_COD "
			If nEntDD1 == 1
				cQuery += "   AND SD1.D1_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf
			If !lReenvia
				cQuery += "   AND SD1.D1_MSEXP = ' ' "
			EndIf
			cQuery += "   AND SD1.D_E_L_E_T_ <> '*' "
			cQuery += " INNER JOIN " + RetSqlName('SF1') + " SF1 "
			cQuery += "    ON F1_FILIAL = D1_FILIAL "
			cQuery += "   AND F1_DOC = D1_DOC "
			cQuery += "   AND F1_TIPO = 'D' "
			cQuery += "   AND F1_EMISSAO BETWEEN '" + dtos(dIni) + "' AND '" + dtos(dFim) + "' "
			If nEntDD1 == 3
				cQuery += "   AND SF1.F1_FORNECE = '" + SA1->A1_COD + "' "
				cQuery += "   AND SF1.F1_LOJA = '" + SA1->A1_LOJA + "' "
			EndIf
			If nEntDD1 == 4
			
				cQuery += " INNER JOIN " + RetSqlName('SF4') + " SF4 "
				cQuery += "    ON F4_CODIGO = D1_TES AND F4_TIPO = 'S' AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ <> '*' "
				cQuery += " INNER JOIN " + RetSqlName('SF2') + " SF2 "  
				cQuery += "    ON  SF2.F2_FILIAL = SF1.F1_FILIAL AND SF2.F2_DOC = SF1.F1_NFORIG AND SF2.F2_SERIE = SF1.F1_SERORIG AND SF2.F2_VEND1 = '" + SA3->A3_COD + "' 
				cQuery += " AND SF2.D_E_L_E_T_ <> '*'"
								
			EndIf

			If nEntDD1 == 2
				cQuery += "   INNER JOIN " + RetSqlName('SA1') + " SA1 "
				cQuery += "      ON A1_COD = F1_FORNECE "
				cQuery += "     AND A1_LOJA = F1_LOJA "
				cQuery += "     AND A1_GRPVEN = '" + ACY->ACY_GRPVEN + "' "
				cQuery += "     AND SA1.D_E_L_E_T_ <> '*' "
			EndIf
			cQuery += " WHERE SB1.D_E_L_E_T_ <> '*'  AND SF1.D_E_L_E_T_ <> '*' "
			If nEntDD1 == 1
				cQuery += "   AND SB1.B1_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf
			cQuery += " GROUP BY B1_COD, B1_CUSTD, F1_EMISSAO, D1_LOCAL "
			cQuery += " ORDER BY EMISSAO, B1_COD, CODLOC, TIPO "
			
			cQuery := ChangeQuery(cQuery)
			
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
			
			TcSetField(cAliasQry,'B1_CUSTD','N',TamSX3('B1_CUSTD')[1],TamSX3('B1_CUSTD')[2])
			TcSetField(cAliasQry,'QUANT','N',TamSX3('D1_QUANT')[1],TamSX3('D1_QUANT')[2])
			TcSetField(cAliasQry,'VALOR','N',18,6)
			TcSetField(cAliasQry,'EMISSAO','D',8,0)
			TcSetField(cAliasQry,'TIPO','N',1,0)
		
			While !(cAliasQry)->(Eof())
			
				If cProdAnt != (cAliasQry)->B1_COD .Or. ;
						dEmisAnt != (cAliasQry)->EMISSAO .Or. ;
						cLocAnt != (cAliasQry)->CODLOC
					
					If nQtdVen > 0 .Or. nQtdDev > 0
						
						cXml += '<ITENS>' + CRLF
						cXml += '<CodItem>' +Alltrim( cProdAnt )+ '</CodItem>' + CRLF
						cXml += '<CodDimensao1>' +AllTrim((aTblDD1[nEntDD1])->&(aCodDD1[nEntDD1]))+ '</CodDimensao1>' + CRLF
						cXml += '<CodDimensao2>' +AllTrim(cEmpAnt)+ '</CodDimensao2>' + CRLF
						cXml += '<Data>'+dtos(dEmisAnt)+'</Data>' + CRLF
						cXml += '<QuantVenda>' + Alltrim( Transform(nQtdVen,"@E 99999999.99") )+ '</QuantVenda>' + CRLF
						cXml += '<QuantEstornoVenda>' + Alltrim( Transform(nQtdVen,"@E 99999999.99") )+ '</QuantEstornoVenda>' + CRLF
						       
						nPrcMed := (nValVen - nValDev) / (nQtdVen - nQtdDev)
						       
						cXml += '<PrecoUnitMedio>' + Alltrim( Transform(nPrcMed,"@E 999999999.99") )+ '</PrecoUnitMedio>' + CRLF
						cXml += '<MargemUnitVenda>' + Alltrim( Transform(nMarMed,"@E 999999999.99") )+ '</MargemUnitVenda>' + CRLF
						cXml += '<LocalEstoqueEntrega>' +AllTrim(cLocAnt)+ '</LocalEstoqueEntrega>' + CRLF
						cXml += '<CodItemEntrega>' +AllTrim(cProdAnt)+ '</CodItemEntrega>' + CRLF
						cXml += '</ITENS>' + CRLF
															
					EndIf

					cProdAnt := (cAliasQry)->B1_COD
					dEmisAnt := (cAliasQry)->EMISSAO
					cLocAnt  := (cAliasQry)->CODLOC
					
					nQtdVen	:= 0
					nQtdDev	:= 0
					nValVen	:= 0
					nValDev	:= 0
					nPrcMed	:= 0
					nMarMed	:= 0
					nCusAnt	:= (cAliasQry)->B1_CUSTD
	
				EndIf
				
				If (cAliasQry)->TIPO == 1
				
					nQtdVen += (cAliasQry)->QUANT
					nValVen += (cAliasQry)->VALOR
				
				Else

					nQtdDev += (cAliasQry)->QUANT
					nValDev += (cAliasQry)->VALOR
								
				EndIf
				
				(cAliasQry)->(DbSkip())
				
			EndDo
			
			If nQtdVen > 0 .Or. nQtdDev > 0
			
				cXml += '<ITENS>' + CRLF
				cXml += '<CodItem>' +Alltrim( cProdAnt )+ '</CodItem>' + CRLF
				cXml += '<CodDimensao1>' +AllTrim((aTblDD1[nEntDD1])->&(aCodDD1[nEntDD1]))+ '</CodDimensao1>' + CRLF
				cXml += '<CodDimensao2>' +AllTrim(cEmpAnt)+ '</CodDimensao2>' + CRLF
				cXml += '<Data>' +dtos(dEmisAnt)+ '</Data>' + CRLF
				cXml += '<QuantVenda>' + Alltrim( Transform(nQtdVen,"@E 99999999.99") ) + '</QuantVenda>' + CRLF
				cXml += '<QuantEstornoVenda>' + Alltrim( Transform(nQtdVen,"@E 99999999.99") )+ '</QuantEstornoVenda>' + CRLF
						       
				nPrcMed := (nValVen - nValDev) / (nQtdVen - nQtdDev)
						       
				cXml += '<PrecoUnitMedio>' + Alltrim( Transform(nPrcMed,"@E 999999999.99") )+ '</PrecoUnitMedio>' + CRLF
				nMarMed := ( ( nValVen - nValDev ) - ( nCusAnt * ( nQtdVen - nQtdDev) ) ) / (nQtdVen - nQtdDev)
				cXml += '<MargemUnitVenda>' + Alltrim( Transform(nMarMed,"@E 999999999.99") )+ '</MargemUnitVenda>' + CRLF
				cXml += '<LocalEstoqueEntrega>' +AllTrim(cLocAnt)+ '</LocalEstoqueEntrega>'+ CRLF
				cXml += '<CodItemEntrega>' +AllTrim(cProdAnt)+'</CodItemEntrega>' + CRLF
				cXml += '</ITENS>' + CRLF
		
			EndIf
			
			(cAliasQry)->(DbCloseArea())
			
			//Atualização dos flags de exportação		
			cQuery := "SELECT '1' AS TIPO, SD2.R_E_C_N_O_ AS NUMREC,D2_MSEXP AS DTEXP, D2_HREXPO AS HREXP "
			cQuery += "  FROM " + RetSqlName('SB1') + " SB1 "
			cQuery += " INNER JOIN " + RetSqlName('SD2') + " SD2 "
			cQuery += "    ON D2_COD = B1_COD "
			If nEntDD1 == 1
				cQuery += "   AND SD2.D2_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf
			cQuery += "   AND SD2.D_E_L_E_T_ <> '*' "
			cQuery += " INNER JOIN " + RetSqlName('SF4') + " SF4 "
			cQuery += "    ON F4_CODIGO = D2_TES AND F4_TIPO = 'S' AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ <> '*' "
			
			cQuery += " INNER JOIN " + RetSqlName('SF2') + " SF2 "
			cQuery += "    ON F2_FILIAL = D2_FILIAL "
			cQuery += "   AND F2_DOC = D2_DOC "
			cQuery += "   AND F2_EMISSAO BETWEEN '" + dtos(dIni) + "' AND '" + dtos(dFim) + "' "
			If nEntDD1 == 3
				cQuery += "   AND SF2.F2_CLIENTE = '" + SA1->A1_COD + "' "
				cQuery += "   AND SF2.F2_LOJA = '" + SA1->A1_LOJA + "' "
			EndIf
			If nEntDD1 == 4
				cQuery += "   AND SF2.F2_VEND1 = '" + SA3->A3_COD + "' "
			EndIf
			cQuery += "   AND SF2.D_E_L_E_T_ <> '*' "
			If nEntDD1 == 2
				cQuery += "   INNER JOIN " + RetSqlName('SA1') + " SA1 "
				cQuery += "      ON A1_COD = F2_CLIENTE "
				cQuery += "     AND A1_LOJA = F2_LOJA "
				cQuery += "     AND A1_GRPVEN = '" + ACY->ACY_GRPVEN + "' "
				cQuery += "     AND SA1.D_E_L_E_T_ <> '*' "
			EndIf
			cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
			If nEntDD1 == 1
				cQuery += "   AND SB1.B1_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf
			cQuery += "UNION ALL "
			cQuery += "SELECT '2' AS TIPO, SD1.R_E_C_N_O_ AS NUMREC, D1_MSEXP AS DTEXP, D1_HREXPO AS HREXP "
			cQuery += "  FROM " + RetSqlName('SB1') + " SB1 "
			cQuery += " INNER JOIN " + RetSqlName('SD1') + " SD1 "
			cQuery += "    ON D1_COD = B1_COD "
			If nEntDD1 == 1
				cQuery += "   AND SD1.D1_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf
			cQuery += "   AND SD1.D_E_L_E_T_ <> '*' "
			cQuery += " INNER JOIN " + RetSqlName('SF1') + " SF1 "
			cQuery += "    ON F1_FILIAL = D1_FILIAL "
			cQuery += "   AND F1_DOC = D1_DOC "
			cQuery += "   AND F1_TIPO = 'D' "
			cQuery += "   AND F1_EMISSAO BETWEEN '" + dtos(dIni) + "' AND '" + dtos(dFim) + "' "
			If nEntDD1 == 3
				cQuery += "   AND SF1.F1_FORNECE = '" + SA1->A1_COD + "' "
				cQuery += "   AND SF1.F1_LOJA = '" + SA1->A1_LOJA + "' "
			EndIf
			If nEntDD1 == 4
			
				cQuery += " INNER JOIN " + RetSqlName('SF2') + " SF2 "
				cQuery += "   ON SF2.F2_FILIAL = SF1.F1_FILIAL "
				cQuery += "   AND SF2.F2_DOC = SF1.F1_NFORIG "
				cQuery += "   AND SF2.F2_SERIE = SF1.F1_SERORIG "
				cQuery += "   AND SF2.F2_VEND1 = '" + SA3->A3_COD + "' "
				cQuery += "   AND SF2.D_E_L_E_T_ <> '*' "
				
			EndIf
			cQuery += "   AND SF1.D_E_L_E_T_ <> '*' "
			If nEntDD1 == 2
				cQuery += "   INNER JOIN " + RetSqlName('SA1') + " SA1 "
				cQuery += "      ON A1_COD = F1_FORNECE "
				cQuery += "     AND A1_LOJA = F1_LOJA "
				cQuery += "     AND A1_GRPVEN = '" + ACY->ACY_GRPVEN + "' "
				cQuery += "     AND SA1.D_E_L_E_T_ <> '*' "
			EndIf
			cQuery += " WHERE SB1.D_E_L_E_T_ <> '*' "
			If nEntDD1 == 1
				cQuery += "   AND SB1.B1_FILIAL = '" + SM0->M0_CODFIL + "' "
			EndIf

			cQuery := ChangeQuery(cQuery)
			
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)
			
			TcSetField(cAliasQry,'NUMREC','N',12,0)
			
			While !(cAliasQry)->(Eof()) 
			
				If (cAliasQry)->TIPO == '1'
				
					If Ft802Expo( "000001", "0001", "SD2", cQuery, "NUMREC", "DTEXP", "HREXP" )
						lRet:= .T.
					Else
						Help( " ", 1, 'FT801NOEXPO' )//"Houve problemas com a gravação do log do arquivo. Por favor, verifique os parâmetros informados."
						lRet := .F.
   						oProcess:SaveLog( STR0054 +cFile+ STR0055 ) //"Houve problemas com a gravação do log do arquivo "###". Por favor, verifique os parâmetros informados."
					EndIf
	
				Else

					If Ft802Expo( "000001", "0001", "SD1", cQuery, "NUMREC", "DTEXP", "HREXP" )
						lRet:= .T.
					Else
						Help( " ", 1, 'FT801NOEXPO' )//"Houve problemas com a gravação do log do arquivo. Por favor, verifique os parâmetros informados."
						lRet := .F.
     					oProcess:SaveLog( STR0054 +cFile+ STR0055 ) //"Houve problemas com a gravação do log do arquivo "###". Por favor, verifique os parâmetros informados."
					EndIf
	
				
				EndIf
			
				If lRet
					(cAliasQry)->(DbSkip())
				EndIf
								
			EndDo
		
			(cAliasQry)->(DbCloseArea())
			

			(aTblDD1[nEntDD1])->(DbSkip())
			
		EndDo
		
		cXml += '</ITEM>' + CRLF
		cXml += '</MOVIMENTACAODFU>' + CRLF
		
		cXml := NoAcento( AnsiToOem( cXml ) )
		
		fWrite(nHandle,cXml)
		
		fClose(nHandle)
		
		//Se não encontrar a continuação da composição do XML, pois, não existem dados a exportar.
		If At( "<CodItem>", cXml ) == 0 
			FErase( cFile )
			lConsole := .F.
		EndIf
		
		If lTemProc .And. lConsole
		
			oProcess:SaveLog(STR0031 + cFile + STR0032) //"O arquivo "###" foi criado com sucesso."
			
		ElseIf  lTemProc
			
			oProcess:SaveLog(STR0031 + cFile + STR0053 ) //"O arquivo "###" não foi criado, pois não há dados passíveis de exportaçao."
			
		ElseIf lConsole
		
			ConOut(STR0033 + cFile + STR0032) //"O arquivo "###" foi criado com sucesso."
		
		Else
			ConOut(STR0033 + cFile + STR0053 ) //"FATA801 - O arquivo "###" não foi criado, pois não há dados passíveis de exportaçao."
		EndIf
		
	Else
	
		lRet := .F.
	
		If lTemProc
	
			oProcess:SaveLog(STR0036 + cFile) //"Erro. Não foi possível criar o arquivo "
		
		Else
	
			ConOut(STR0037 + cFile) //"FATA801 - Erro. Não foi possível criar o arquivo "
		
		EndIf
	
	EndIf


Else //nCont > 0

	If lTemProc
		
		oProcess:SaveLog(STR0034 + cFile + ".") //"Não existem registros para gerar o arquivo "
			
	Else
		
		ConOut(STR0035 + cFile + ".") //"FATA801 - Não existem registros para gerar o arquivo "
			
	EndIf
	
EndIf
	
SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcLista

Processamento do Arquivo de Preço de Lista DFU

@param oProcess   - Objeto do Processo
@param dIni		- Data de início da exportação
@param dFim		- Data final da exportação

@return lRet		- Retorna se os dados foram processados(.T. ou .F.)
 
@author Alexandre Bueno da Silva
@since 25/06/2014
@version MP11.8, MP12
/*/
//-------------------------------------------------------------------
Static Function ProcLista(oProcess,dIni,dFim)

Local lRet			:= .T.
Local lTemLista	:= .F.
Local nHandle		:= 0
Local nCont		:= 0
Local cFile		:= cPathExp + "X_" + dtos(dDataBase) + "_preco_lista_dfu.xml"
Local cXml			:= ""
Local lTemProc	:= ValType(oProcess) == 'O'
Local aArea		:= GetArea()
Local aAreaSM0	:= SM0->(GetArea())
Local aTblDD1		:= {"SM0","ACY","SA1","SA3"}
Local aCodDD1		:= {"M0_CODFIL","ACY_GRPVEN","AllTrim(A1_COD)+'-'+A1_LOJA","A3_COD"}
Local aIncDD1		:= {"","ACY_USERGI","A1_USERLGI","A3_USERLGI"}
Local aAltDD1		:= {"","ACY_USERGA","A1_USERLGA","A3_USERLGA"}
Local dInc			:= ctod('')
Local dAlt			:= ctod('')
Local nLenSX8		:= GetSx8Len() 
Local nTemLista	:= 0
Local lConsole	:= .T.

DA1->(DbSetOrder(1))

If nEntDD1==1
	
	DbSelectArea('SM0')
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt))
		
	While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
		nCont++
		SM0->(DbSkip())
	EndDo
		
	SM0->(DbSeek(cEmpAnt))
		
Else
				          
	nCont := (aTblDD1[nEntDD1])->(RecCount())
		
	(aTblDD1[nEntDD1])->(DbGoTop())
		
EndIf
	
If nCont > 0
	
	If (nHandle := fCreate(cFile)) > 0
	
		If lTemProc
		
			oProcess:SetRegua2(nCont)
			
		Else
		
			ConOut(STR0029 + cFile) //"FATA801 - Iniciando geração do arquivo "
			
		EndIf
		
		DbSelectArea( "AIR" )// Controle de Exportação
		DbSetOrder( 2 )// AIR_FILIAL+AIR_CODINT+AIR_TAG+AIR_TABELA
				
		cXml := '<?xml version="1.0" encoding="utf-8"?>' +CRLF
		cXml += '<PRECOLISTADFU xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file://PRECOLISTADFU.xsd">' +CRLF
			
		While !(aTblDD1[nEntDD1])->(Eof()) .And. SM0->M0_CODIGO == cEmpAnt
		
			If lTemProc

				oProcess:IncRegua2(STR0042) //"Processando Lista de Preços"
				
			EndIf
			
			SB1->(DbGoTop())
		
			While !SB1->(Eof())
			
				//Entidade DD1 cliente, verifica se tem tabela de preços
				If nEntDD1 == 3 .And. !Empty(SA1->A1_TABELA) .And. ;
						DA1->(DbSeek(xFilial('DA1')+SA1->A1_TABELA+SB1->B1_COD))
					If DbSeek( xFilial( "AIR" ) + "000001" + "0001" + "DA1" )
						dExpo 	 := AIR->AIR_MSEXP
						cHrExpo := AIR->AIR_HREXPO
					EndIf
					
					lTemLista := .T.
	
					cCond := Empty(DA1->DA1_MSEXP) .Or.;
							  Empty(DA1->DA1_USERGI) .Or.;
							  ( dInc >= dIni .And. dInc <= dFim ).Or.;
							  ( DA1->DA1_MSEXP + DA1->DA1_HREXPO > dExpo + cHrExpo ) .And.;
							  ( lReenvia .Or. Empty( DA1->DA1_MSEXP) )
						 			 	
					dInc := ctod(DA1->(FWLeUserLg("DA1_USERGI",2)))
										
				Else
				
					lTemLista := .F.
	
					If DbSeek( xFilial( "AIR" ) + "000001" + "0001" + "SB1" )
						dExpo 	 := AIR->AIR_MSEXP
						cHrExpo := AIR->AIR_HREXPO
					EndIf
			
					cCond := Empty( SB1->B1_MSEXP ) .Or.;
							  Empty( SB1->B1_USERLGI).Or.;
							 ( dInc >= dIni .And. dInc <= dFim ).Or.;
							 ( SB1->B1_MSEXP + SB1->B1_HREXPO > dExpo + cHrExpo ) 
		
					dInc := ctod(SB1->(FWLeUserLg("B1_USERLGI",2)))
									
				EndIf

				If cCond
				
					cXml += '<PRECOLISTADFUCOL>' +CRLF
					cXml += '<CodItem>'+AllTrim(SB1->B1_COD)+'</CodItem>' +CRLF
					cXml += '<DimensaoDemanda1>'+AllTrim((aTblDD1[nEntDD1])->&(aCodDD1[nEntDD1]))+'</DimensaoDemanda1>' +CRLF
					cXml += '<DimensaoDemanda2>'+AllTrim(cEmpAnt)+'</DimensaoDemanda2>' +CRLF
					cXml += '<AnoMes>'+Left(dtos(dDataBase),6)+'</AnoMes>' +CRLF
					
					If lTemLista
						cXml += '<PrecoLista>'+StrTran( cValToChar( AllTrim(Transform(DA1->DA1_PRCVEN,"@E 9999999.99"))), ".", ",")+'</PrecoLista>' +CRLF
					Else
						cXml += '<PrecoLista>'+StrTran( cValToChar( AllTrim(Transform(SB1->B1_PRV1,"@E 9999999.99"))), ".", ",")+'</PrecoLista>' +CRLF
					EndIf
					  
					cXml += '</PRECOLISTADFUCOL>' +CRLF
				
					If lTemLista
						nTemLista++
						DA1->(RecLock('DA1',.F.))
						DA1->DA1_MSEXP := DtoS( dDataBase )
						DA1->DA1_HREXPO := Time()
						DA1->(MsUnlock())
						
					EndIf
					
				EndIf
			
				SB1->(DbSkip())
				
			EndDo
				
			(aTblDD1[nEntDD1])->(DbSkip())
			
		EndDo
		
		If nTemLista >= 1
			DbSelectArea( "AIR" ) //Controle de Exportações
			DbSetOrder( 2 ) // AIR_FILIAL+AIR_CODINT+AIR_TAG+AIR_TABELA
			If DbSeek( xFilial( "AIR" ) + "000001" + "0001" + "DA1" )
				RecLock( "AIR", .F. )
				AIR->AIR_MSEXP  := DtoS( dDataBase )
				AIR->AIR_HREXPO := Time()
			Else
				If RecLock( "AIR", .T. )
					AIR->AIR_FILIAL := xFilial( "AIR" )
					AIR->AIR_CODIGO := GetSx8Num( "AIR", "AIR_CODIGO" )
					AIR->AIR_CODINT := "000001"
					AIR->AIR_TAG	  := "0001"
					AIR->AIR_TABELA := "DA1"
					AIR->AIR_MSEXP  := DtoS( dDataBase )
					AIR->AIR_HREXPO := Time()
					MsUnlock()
				
					ConfirmSX8()
				
				Else
					While GetSx8Len() > nLenSX8
						RollBackSX8()
					EndDo
				EndIf
			EndIf
							
		EndIf
			
		cXml += '</PRECOLISTADFU>'
		
		cXml := NoAcento( AnsiToOem( cXml ) )
		
		fWrite(nHandle,cXml)
		
		fClose(nHandle)
		
		//Se a tag não existir no XML, significa que não há dados a exportar, sendo assim, exclui o arquivo.
		If At( "<CodItem>", cXml ) == 0
			FErase( cFile )
			lConsole := .F.
		EndIf
		
	Else
	
		lRet := .F.
	
		If lTemProc
	
			oProcess:SaveLog(STR0036 + cFile) //"Erro. Não foi possível criar o arquivo "
		
		Else
	
			ConOut(STR0037 + cFile) //"FATA801 - Erro. Não foi possível criar o arquivo "
		
		EndIf
	
	EndIf
		
	If lTemProc .And. lConsole
		
		oProcess:SaveLog(STR0031 + cFile + STR0032) //"O arquivo "###" foi criado com sucesso."
	
	ElseIf  lTemProc
		
		oProcess:SaveLog(STR0031 + cFile + STR0053 ) //"O arquivo "###" não foi criado, pois não há dados passíveis de exportaçao."
			
	ElseIf lConsole
		
		ConOut(STR0033 + cFile + STR0032) //"FATA801 - O arquivo "###" foi criado com sucesso."
	
	Else 
		ConOut(STR0033 + cFile + STR0053) //"FATA801 - O arquivo "###" não foi criado, pois não há dados passíveis de exportaçao."
		 
	EndIf

Else

	If lTemProc
		
		oProcess:SaveLog(STR0034 + cFile + ".") //"Não existem registros para gerar o arquivo "
			
	Else
		
		ConOut(STR0035 + cFile + ".") //"FATA801 - Não existem registros para gerar o arquivo "
			
	EndIf
	
EndIf


SM0->(RestArea(aAreaSM0))
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FT801Carga

Faz a carga inicial do cadastro da Integração S&OP. 

@return Nil
 
@author Thamara Villa Jacomo
@since 20/02/2015
/*/
//-------------------------------------------------------------------
Function FT801Carga()

Local lIntSOP  := SuperGetMv( "MV_SOPCRGA",, .F. )
Local aAreaAIP := {} 
Local nLenSx8	 := 0
Local lRet		 := .T.

If lIntSOP
	If Select( "AIP" ) > 0
		aAreaAIP := AIP->( GetArea() )	
	Else
		DbSelectArea( "AIP" ) //Cadastro de Integrações
	EndIf	
	AIP->( DbSetOrder( 1 ) ) //AIP_FILIAL+AIP_CODIGO     
	
	nLenSx8 := GetSx8Len()
	
	If RecLock( "AIP", .T. )
		AIP->AIP_CODIGO := GetSx8Num( "AIP", "AIP_CODIGO" )                     
		AIP->AIP_DESC   := "S&OP - NEOGRID"	
		
		AIP->( MsUnLock() )
		ConfirmSX8()
	Else 
		lRet := .F.
		While GetSx8Len() > nLenSX8
		   	RollBackSX8()
       EndDo		
	EndIf
 	
	PutMv( "MV_SOPCRGA", .F. )

	If !Empty( aAreaAIP )
		RestArea( aAreaAIP )
	EndIf

EndIf

Return( lRet )

