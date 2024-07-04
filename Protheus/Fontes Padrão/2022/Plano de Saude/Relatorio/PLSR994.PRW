#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "MsOle.ch"

#Define CRLF	Chr(13) + Chr(10)

Static objCENFUNLGP := CENFUNLGP():New()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLSR994  º Autor ³ Alexandre Villar   º Data ³ 22/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao das Cartas de Maioridade - ANS                   º±±
±±º          ³ Via Microsoft Word / TXT                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSR994()

Local nI			:= 0
Local nCriaDir		:= 0
Local nHandArq		:= 0
Local nExpArq		:= 0

Local lCopy1		:= .F.
Local lCopy2		:= .F.
Local lProc			:= .F.
Local lCriaDir		:= .T.


Local cPathArq		:= GetNewPar( "MV_PLSACMS" , "" )
Local cPathTxt		:= GetNewPar( "MV_PLSTCMS" , "" )
Local cArqAgl		:= ""
Local cLinAux		:= ""
Local cMensag		:= ""
Local cPathTMP		:= ""

Private aWord		:= {}
Private hWord		:= Nil
Private nConDoc		:= 0
Private cArqDot		:= ""
Private cPathEst	:= GetNewPar( "MV_PLSACMT" , "" )
Private cPerg			:= "PLR994"

//-- LGPD ----------
if !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif 
//------------------

If Empty(cPathArq)
	cPathArq := GetSrvProfString("StartPath", "")
Else
	If !(Substr(cPathArq,1,1) == "\" .OR. Substr(cPathArq,1,1) == "/")
		cPathTMP := GetSrvProfString("StartPath", "")
		cPathArq := IIF( Substr(cPathTMP,Len(cPathTMP),1) $ "\/", cPathTMP, cPathTMP+"\" ) + cPathArq
	EndIf
EndIf
cPathArq := IIF( Substr(cPathArq,Len(cPathArq),1) $ "\/", cPathArq, cPathArq+"\" )

If Empty(cPathEst)
	cPathEst := GetTempPath()
EndIf


If !Pergunte(cPerg,.T.)
	Return()	

Else

	
	If mv_par18 == 1
	
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Inicia a Integracao com o Word											º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		cArqDot := IIf( mv_par17 == 1 , "Beneficiario.dot" , "Associado.dot" )
		cArqAgl	:= IIf( mv_par17 == 1 , "Beneficiarios.dot" , "Associados.dot" )
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Se nao for alterado via parametro procura o arquivo na pasta "system"	º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		cPathDot := cPathArq + cArqDot
		cPathAgl := cPathArq + cArqAgl
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Verifica a Existencia dos Arquivos DOT no StartPath do Protheus			º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		If !File(cPathDot)
			Aviso( "Atencao" , "O arquivo de Configuração:"+ CRLF + cPathDot + CRLF +"nao foi encontrado pelo Servidor!" , {"Fechar"} )
			Return()
		EndIf
	
		If !File(cPathAgl)
			Aviso( "Atencao" , "O arquivo de Configuração:"+ CRLF + cPathAgl + CRLF +"nao foi encontrado pelo Servidor!" , {"Fechar"} )
			Return()
		EndIf

		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Verifica Path do Temporário para gravação na Estacao de Trabalho		º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		If Substr(cPathEst,1,1) == "\" .OR. Substr(cPathEst,1,1) == "/"
			cMensag := "Não foi validado o diretório temporário da Estação:"+CRLF+ cPathEst +CRLF+"Os arquivos temporários serão gravados no diretório:"+CRLF+GetTempPath()
			Aviso( "Atencao" , cMensag , {"Fechar"} )
			cPathEst := GetTempPath()
		EndIf

		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Verifica Path para Armazenamento na Estacao de Trabalho					º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		MontaDir( cPathEst )
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Se ja existir arquivos no local, apaga para a nova geracao				º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		If File( Lower( cPathEst + "\" + cArqDot ) )
			Ferase( Lower( cPathEst + "\" + cArqDot ) )
		EndIf
	
		If File( Lower( cPathEst + "\" + cArqAgl ) )
			Ferase( Lower( cPathEst + "\" + cArqAgl ) )
		EndIf
		
		If File( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
			Ferase( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
		EndIf
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Faz a copia dos arquivos do Servidor para o Remote						º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		lCopy1 := CpyS2T( cPathDot , cPathEst , .F. )
		lCopy2 := CpyS2T( cPathAgl , cPathEst , .F. )
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Verifica as Copias														º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		If !lCopy1 .Or. !lCopy2
			Aviso( "Processamento Cancelado" , "Houve um problema com a cópia dos arquivos de configuraçao:" + CRLF + cPathDot + CRLF + cPathEst , {"Fechar"} )
			Return()
		EndIf
		
		Processa( {|| lProc := GeraWord(1)} , "Iniciando o processamento..." , "Aguarde" , .F. )
		
		If lProc
	
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º	Fecha os Documentos														º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			For nI := 1 to nConDoc
				OLE_CloseFile( aWord[nConDoc] )
				OLE_CloseLink( aWord[nConDoc] )
			Next
			
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º	Cria Documento Unico para aglutinar os resultados						º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			hWord := OLE_CreateLink()
			OLE_NewFile( hWord , cPathEst + "\" + cArqAgl )
			OLE_SetPropertie( hWord, oleWdVisible, .F. )

			OLE_SetDocumentVar(hWord , 'nQtArqs' , nConDoc )
			OLE_SetDocumentVar(hWord , 'nomeArquivo' , "\ImpCarta" )
			OLE_SetDocumentVar(hWord , 'pastaDocs' , cPathEst )
	
			OLE_UpdateFields( hWord )
			OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )
			
			OLE_ExecuteMacro( hWord , "JuntaTudo" )
			OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument )
			
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º	Pergunta se imprime os resultados										º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			If MsgYesNo("Total de Cartas: "+ AllTrim(Str(nConDoc)) +"."+ CRLF +" Deseja Imprimir o Arquivo ?")
				OLE_PrintFile( hWord , "PART" , 2 , nConDoc + 1 , 1 )
				Aviso( "Atenção" , "Arquivo enviado para impressao..." , {"Ok"} )
			Endif
			
			OLE_CloseFile( hWord )		// Fecha ultimo arquivo
			OLE_CloseLink( hWord )		// Fecha link com Word
			
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º	Apaga os Arquivos Temporarios											º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			For nI := 1 to nConDoc
				If File( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
					FErase( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
				EndIf
			Next
			
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º	Exclui os Arquivos Temporarios apos a utilizacao.						º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			If File( Lower( cPathEst + "\" + cArqDot ) )
				Ferase( Lower( cPathEst + "\" + cArqDot ) )
			EndIf
		
			If File( Lower( cPathEst + "\" + cArqAgl ) )
				Ferase( Lower( cPathEst + "\" + cArqAgl ) )
			EndIf
			
		EndIf
	
	ElseIf mv_par18 == 2
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Seleciona Local para Exportacao.										º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		Aviso( "Exportar para Arquivo" ,	"Para esta opção é necessário informar o local onde o arquivo deverá ser criado. Importante lembrar que" + ;
											" o Local escolhido deve ter acesso como gravação pelo usuário atual. " , {"Ok"} )

		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Verifica Local para Exportacao.											º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		If !Empty(cPathTxt)//verificar para nao ficar pedindo local
			cPathEst	:= AllTrim( cPathTxt )
			lCriaDir	:= .F.
		EndIf
		
		While lCriaDir
		
			cPathEst := AllTrim( cGetFile( '*.txt' , 'Local para Exportar:' , 1 , 'C:\' , .F. , nOR( GETF_LOCALHARD , GETF_RETDIRECTORY ) , .T. , .T. ) )
			
			If Empty(cPathEst)
			
				Aviso( "Diretório Inválido" , "É necessário informar um diretório válido para exportação." , {"Ok"} )
			
			Else
			
				If !ExistDir(cPathEst)
					
					nCriaDir := MakeDir( cPathEst )
				
					If nCriaDir != 0
						Aviso( "Diretório Inválido" , "O Diretório informado não existe ou não possui acesso liberado para o usuário atual." , {"Ok"} )
					Else
						lCriaDir := .F.
					EndIf
				
				Else
				
					lCriaDir := .F.
				
				EndIf
			
			EndIf
		
		EndDo
		
		If !( SubStr(cPathEst,Len(cPathEst),1) == "\" )
			cPathEst += "\"
		EndIf
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º	Carrega dados para Exportacao.											º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		If !lCriaDir
			
			cArqAgl := cPathEst+"Carta_Maioridade_"+IIf(mv_par17==1,"Beneficiarios","Associados")+"_"+DtoS(Date())+"_"+StrTran(Time(),":","")+".txt"
			
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º Verifica a Criação dos Arquivos.										º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			nHandArq := FCreate( cArqAgl )
			
			If 	nHandArq == -1
				Aviso( "Processamento Cancelado" , "Não foi possível gerar o arquivo: "+ CRLF +"["+ cArqAgl +"]"+ CRLF +"Verifique a pasta de destino tente novamente." , {"Fechar"} )
				Return()
			EndIf

			lProc	:= GeraWord(2)
			nExpArq	:= 0
			
			For nI := 1 To Len(aWord)
			
				cLinAux := aWord[nI][01]+";"+aWord[nI][02]+";"+aWord[nI][03]+";"+aWord[nI][04]+";"+aWord[nI][05]+";"+aWord[nI][06]+";"+aWord[nI][07]
				cLinAux += ";"+aWord[nI][08]+";"+aWord[nI][09]+";"+aWord[nI][10]+";"+aWord[nI][11]+";"
				
				FWrite( nHandArq , cLinAux )
				nExpArq++
				
			Next nI
			
			FClose( nHandArq )
			
			//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
			//º Se nao houve exportacao exclui o arquivo.								º
			//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
			If nExpArq == 0
				Aviso( "Processamento Finalizado" , "O processamento foi finalizado com sucesso porém não houve a geração de cartas. Verifique os filtros e tente novamente." , {"Fechar"} )
				FErase( cArqAgl )
			Else
				Aviso( "Processamento Finalizado" , "O processamento foi finalizado com sucesso e o arquivo foi gerado com sucesso no diretório:" + CRLF + cPathEst , {"Fechar"} )
			EndIf
			
		Else
		
			Aviso( "Processamento Cancelado" , "O Diretório informado não existe ou não possui acesso liberado para o usuário atual." , {"Ok"} )
			
		EndIf
		
	EndIf
	
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraWord º Autor ³ Alexandre Villar   º Data ³ 22/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que gera a pagina a ser impressa atraves do modelo. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraWord( nOption )

Local cSql		:= ''
Local cAlias	:= GetNextAlias()
Local cDtDe	:= StrZero((Year(mv_par15)-18),4) + StrZero(Month(mv_par15),2) + StrZero(Day(mv_par15),2)
Local cDtAte	:= StrZero((Year(mv_par16)-18),4) + StrZero(Month(mv_par16),2) + StrZero(Day(mv_par16),2)

If !( nOption == 1 .Or. nOption == 2 )
	Return(.F.)
EndIf

cSql := "SELECT" + CRLF

cSql += "	BA1.BA1_NOMUSR AS DEPEND," + CRLF
cSql += "	BA1.BA1_DATNAS AS DEZOITO," + CRLF
cSql += "	BA1.BA1_CODINT AS OPERADORA," + CRLF
cSql += "	BA1.BA1_CODINT || BA1.BA1_CODPLA || BA1.BA1_VERSAO AS PLANO," + CRLF
cSql += "	BA3.BA3_CODINT || BA3.BA3_CODPLA || BA3.BA3_VERSAO AS PLANO2," + CRLF
cSql += "	BA1P.BA1_NOMUSR AS BENEF," + CRLF
cSql += "	BA1P.BA1_MUNICI AS CIDADE," + CRLF
cSql += "	BA1P.BA1_ESTADO AS UF" + CRLF

cSql += "FROM "+ RetSqlName("BA1") +" BA1 "

cSql += "	INNER JOIN "+ RetSqlName("BA3") +" BA3" + CRLF
cSql += "	ON    BA1.BA1_FILIAL    = BA3.BA3_FILIAL " + CRLF
cSql += "	AND BA1.BA1_CODINT      = BA3.BA3_CODINT " + CRLF
cSql += "	AND BA1.BA1_CODEMP      = BA3.BA3_CODEMP " + CRLF
cSql += "	AND BA1.BA1_CONEMP      = BA3.BA3_CONEMP " + CRLF
cSql += "	AND BA1.BA1_VERCON      = BA3.BA3_VERCON " + CRLF
cSql += "	AND BA1.BA1_SUBCON      = BA3.BA3_SUBCON " + CRLF
cSql += "	AND BA1.BA1_VERSUB      = BA3.BA3_VERSUB " + CRLF
cSql += "	AND BA1.BA1_MATRIC      = BA3.BA3_MATRIC " + CRLF
cSql += "	AND BA3.D_E_L_E_T_      = '' " + CRLF
cSql += "	AND BA1.D_E_L_E_T_      = '' " + CRLF
cSql += ", "+ RetSqlName("BA1") +" BA1P" + CRLF
cSql += "WHERE" + CRLF
cSql += "		BA1.D_E_L_E_T_ = ''" + CRLF
cSql += "AND	BA1.BA1_FILIAL = '"+ xFilial("BA1") +"'" + CRLF
cSql += "AND	BA1.BA1_DATNAS BETWEEN '"+ cDtDe +"' AND '"+ cDtAte +"'" + CRLF
cSql += "AND	(BA1.BA1_DATBLO = ' ' OR BA1.BA1_DATBLO >= '"+ DtoS( dDataBase ) +"')" + CRLF
cSql += "AND	BA1.BA1_TIPUSU <> 'T'" + CRLF
cSql += "AND	BA1.BA1_CODINT BETWEEN '"+ mv_par01 +"' AND '"+ mv_par02 +"'" + CRLF
cSql += "AND	BA1.BA1_CODEMP BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 +"'" + CRLF
cSql += "AND	BA1.BA1_CONEMP BETWEEN '"+ mv_par05 +"' AND '"+ mv_par07 +"'" + CRLF
cSql += "AND	BA1.BA1_VERCON BETWEEN '"+ mv_par06 +"' AND '"+ mv_par08 +"'" + CRLF
cSql += "AND	BA1.BA1_SUBCON BETWEEN '"+ mv_par09 +"' AND '"+ mv_par11 +"'" + CRLF
cSql += "AND	BA1.BA1_VERSUB BETWEEN '"+ mv_par10 +"' AND '"+ mv_par12 +"'" + CRLF
cSql += "AND	BA1.BA1_MATRIC BETWEEN '"+ mv_par13 +"' AND '"+ mv_par14 +"'" + CRLF

cSql += "AND	BA1P.D_E_L_E_T_	= ''" + CRLF
cSql += "AND	BA1P.BA1_FILIAL	= '"+ xFilial("BA1") +"'" + CRLF
cSql += "AND	BA1P.BA1_FILIAL = BA1.BA1_FILIAL" + CRLF
cSql += "AND	BA1P.BA1_CODINT = BA1.BA1_CODINT" + CRLF
cSql += "AND	BA1P.BA1_CODEMP = BA1.BA1_CODEMP" + CRLF
cSql += "AND	BA1P.BA1_MATRIC = BA1.BA1_MATRIC" + CRLF
cSql += "AND	BA1P.BA1_TIPUSU = 'T'" + CRLF

cSql := ChangeQuery(cSql)

MemoWrite("\system\Query_CM.sql",cSql)

If Select(cAlias) > 0
	(cAlias)->( DBCloseArea() )
EndIf

DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , cAlias , .F. , .T. )

DBSelectArea(cAlias)
(cAlias)->(DBGoTop())

If (cAlias)->(Eof())

	(cAlias)->(DBCloseArea())
	Aviso( "Atenção" , "Não foram encontrados dados para processar com essa parametrização" , {"Fechar"} )
	Return(.F.)
	
Else

	While (cAlias)->(!Eof())
		
		If nOption == 1
		
			CriaNovo()
			ZeraCar()
			GravaCar( cAlias , nOption )
			OLE_CloseFile( aWord[nConDoc] )
			OLE_CloseLink( aWord[nConDoc] )
		
		ElseIf nOption == 2
			
			GravaCar( cAlias , nOption )
			
		EndIf
		
	(cAlias)->(dbSkip())
	EndDo
	
	(cAlias)->(DBCloseArea())
	
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GravaCar º Autor ³ Alexandre Villar   º Data ³ 24/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que grava os dados da Consulta na Carta.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GravaCar( cAlias , nOption )

Local aDados	:= Array(11)
Local cPlano	:= AllTrim( Posicione("BI3",1,xFilial("BI3")+(cAlias)->PLANO,"BI3_DESCRI") )
Local cOper		:= AllTrim( Posicione("BA0",1,xFilial("BA0")+(cAlias)->OPERADORA,"BA0_NOMINT") )
Local cDtAniv	:= StrZero(Day(StoD((cAlias)->DEZOITO)),2) + "/" + SubStr(MesExtenso(Month(StoD((cAlias)->DEZOITO))),1,3) + "/" + AllTrim(Str(Year(StoD((cAlias)->DEZOITO))+18))
Local cTelCen	:= GetNewPar( "MV_PLSRTCA" , "" )
Local cTelFax	:= GetNewPar( "MV_PLSRTFA" , "" )
Local cEmail	:= GetNewPar( "MV_PLSREMA" , "" )

If Empty(cAlias) .Or. !( nOption == 1 .Or. nOption == 2 )
	Return()
EndIf

If EMPTY(cPlano) // Se não achar Plano no BA1, tento o BA3
	cPlano	:= AllTrim( Posicione("BI3",1,xFilial("BI3")+(cAlias)->PLANO2,"BI3_DESCRI") )
EndIf

aDados[01] := IIf( Empty((cAlias)->CIDADE)	, AllTrim( SM0->M0_CIDENT ) , AllTrim((cAlias)->CIDADE) )
aDados[02] := IIf( Empty((cAlias)->UF) , AllTrim( SM0->M0_ESTENT ) , AllTrim((cAlias)->UF) )
aDados[03] := DtoC(Date())
aDados[04] := IIf( Empty((cAlias)->BENEF) , "[Erro ao identificar o Nome]" , AllTrim((cAlias)->BENEF) )
aDados[05] := IIF( Empty((cAlias)->DEPEND) , "[Erro ao identificar o Nome]" , AllTrim((cAlias)->DEPEND) )
aDados[06] := IIf( Empty(cOper) , "[Erro ao identificar a Operadora]" , AllTrim(cOper) )
aDados[07] := IIf( Empty(cPlano) , "[Erro ao identificar o Plano]" , AllTrim(cPlano) )
aDados[08] := IIf( Empty(cDtAniv) , "[Erro ao identificar a Data]" , AllTrim(cDtAniv) )
aDados[09] := IIf( Empty(cTelCen) , "0800-000.0000" , AllTrim(cTelCen) )
aDados[10] := IIf( Empty(cTelFax) , "(00) 0000-0000" , AllTrim(cTelFax) )
aDados[11] := IIf( Empty(cEmail) , "email@empresa.com.br" , AllTrim(cEmail) )

If nOption == 1

	OLE_SetDocumentVar( aWord[nConDoc], "CIDADE"		, aDados[01] )
	OLE_SetDocumentVar( aWord[nConDoc], "UF"			, aDados[02] )
	OLE_SetDocumentVar( aWord[nConDoc], "DATA"			, aDados[03] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMEBENEF"		, aDados[04] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMEDEPEND"	, aDados[05] )
	OLE_SetDocumentVar( aWord[nConDoc], "NOMEOPER"		, aDados[06] )
	OLE_SetDocumentVar( aWord[nConDoc], "PLANO"			, aDados[07] )
	OLE_SetDocumentVar( aWord[nConDoc], "DTANIVER"		, aDados[08] )
	
	OLE_SetDocumentVar( aWord[nConDoc], "TELCENTRAL"	, aDados[09] )
	OLE_SetDocumentVar( aWord[nConDoc], "TELFAX"		, aDados[10] )
	OLE_SetDocumentVar( aWord[nConDoc], "EMAIL"			, aDados[11] )
	
	OLE_UpdateFields( aWord[nConDoc] )
	
	OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".DOC" ,,, .F. , oleWdFormatDocument )

ElseIf nOption == 2
	
	aAdd( aWord ,	{	aDados[01]	,; //Cidade
						aDados[02]	,; //UF
						aDados[03]	,; //Data
						aDados[04]	,; //Nome do Beneficiario
						aDados[05]	,; //Nome do Dependente
						aDados[06]	,; //Nome da Operadora
						aDados[07]	,; //Nome do Plano/Produto
						aDados[08]	,; //Data de Nascimento
						aDados[09]	,; //Telefone Central
						aDados[10]	,; //Fax Central
						aDados[11]	,; //E-mail Central
					} )
	
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ZeraCar  º Autor ³ Alexandre Villar   º Data ³ 24/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Zera os controladores para geracao de nova Carta.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ZeraCar()

OLE_SetDocumentVar(aWord[nConDoc]	, "NOMEBENEF"	, "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "NOMEDEPEND"	, "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "MATRICULA"	, "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "DATADEZOITO"	, "" )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaNovo º Autor ³ Alexandre Villar   º Data ³ 24/08/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera o novo arquivo para gravacao.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CriaNovo()

aAdd( aWord , 0 )
nConDoc++

aWord[nConDoc] := OLE_CreateLink()

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Cria o novo arquivo no Remote											º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
OLE_NewFile( aWord[nConDoc] , cPathEst + "\" + cArqDot )

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Ajusta Propriedades do Arquivo											º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
OLE_SetPropertie( aWord[nConDoc] , oleWdVisible , .F. )

//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º	Salva o arquivo com o novo nome no Remote								º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".doc" ,,, .F. , oleWdFormatDocument )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PLSF3BT5 º Autor ³ Paulo Sampaio      º Data ³ 18/05/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta Padrao de Contrato.								  º±±
±±º          ³					                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS					                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSF3BT5()

Local lRet 	   	:= .F.
Local nRetorno 	:= 0
Local cQuery   	:= ""
Local cCodIntD	:= mv_Par01
Local cCodIntA	:= mv_Par02
Local cCodEmpD	:= mv_Par03
Local cCodEmpA	:= mv_Par04

If Empty(cCodIntD) .And. Empty(cCodIntA)
	nTamAux 	:= TamSX3("BT5_CODINT")[01]
	cCodIntD	:= Space(nTamAux)
	cCodIntA	:= Replicate("Z",nTamAux)
EndIf

If Empty(cCodEmpD) .And. Empty(cCodEmpA)
	nTamAux 	:= TamSX3("BT5_CODIGO")[01]
	cCodEmpD	:= Space(nTamAux)
	cCodEmpA	:= Replicate("Z",nTamAux)
EndIf

cQuery := " SELECT	BT5.BT5_NUMCON , BT5.BT5_VERSAO, BT5.BT5_NOME, BT5.R_E_C_N_O_ AS BT5RECNO "
cQuery += "	FROM 	"+RetSQLName("BT5")+" BT5 "
cQuery += "	WHERE	BT5.BT5_FILIAL	= '"+xFilial("BT5")+"' "
cQuery += "	AND		BT5.BT5_CODINT	>= '"+cCodIntD+"' "
cQuery += "	AND		BT5.BT5_CODINT	<= '"+cCodIntA+"' "
cQuery += "	AND		BT5.BT5_CODIGO	>= '"+cCodEmpD+"' "
cQuery += "	AND		BT5.BT5_CODIGO	<= '"+cCodEmpA+"' "
cQuery += "	AND		BT5.D_E_L_E_T_	= ' '  "  
cQuery += " 	ORDER BY BT5_NUMCON, BT5_NOME  "  


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta nova janela de consulta padrão, utilizando a query para a filtragem.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	Tk510F3Qry( cQuery /*cQuery*/,"GCOBT5"/*cCodCon*/,"BT5RECNO"/*cCpoRecno*/,@nRetorno/*nRetorno*/,/*aCoord*/,/*aSearch*/,"BT5"/*cAlias*/)
	BT5->( DBGoto(nRetorno) )
	lRet := .T.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PLSF3BQC º Autor ³ Paulo Sampaio      º Data ³ 18/05/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta Padrao de Sub-Contrato.							  º±±
±±º          ³					                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS				                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSF3BQC()

Local lRet 	   	:= .F.
Local nRetorno 	:= 0
Local nTamAux	:= 0
Local cQuery   	:= ""
Local cCodIntD	:= mv_Par01
Local cCodIntA	:= mv_Par02
Local cCodEmpD	:= mv_Par03
Local cCodEmpA	:= mv_Par04
Local cConEmpD	:= mv_Par05
Local cConEmpA	:= mv_Par07
Local cVerConD	:= mv_Par06
Local cVerConA	:= mv_Par08

If Empty(cCodIntD) .And. Empty(cCodIntA)
	nTamAux 	:= TamSX3("BQC_CODINT")[01]
	cCodIntD	:= Space(nTamAux)
	cCodIntA	:= Replicate("Z",nTamAux)
EndIf

If Empty(cCodEmpD) .And. Empty(cCodEmpA)
	nTamAux 	:= TamSX3("BQC_CODEMP")[01]
	cCodEmpD	:= Space(nTamAux)
	cCodEmpA	:= Replicate("Z",nTamAux)
EndIf

If Empty(cConEmpD) .And. Empty(cConEmpA)
	nTamAux 	:= TamSX3("BQC_NUMCON")[01]
	cConEmpD	:= Space(nTamAux)
	cConEmpA	:= Replicate("Z",nTamAux)
EndIf

If Empty(cVerConD) .And. Empty(cVerConA)
	nTamAux 	:= TamSX3("BQC_VERCON")[01]
	cVerConD	:= Space(nTamAux)
	cVerConA	:= Replicate("Z",nTamAux)
EndIf

cQuery := " SELECT	BQC.BQC_SUBCON , BQC.BQC_VERSUB , BQC.BQC_NREDUZ , BQC.BQC_DESCRI , BQC.R_E_C_N_O_ AS BQCRECNO "
cQuery += "	FROM 	"+RetSQLName("BQC")+" BQC "
cQuery += "	WHERE	BQC.BQC_FILIAL	= '"+xFilial("BQC")+"' "
cQuery += "	AND		BQC.BQC_CODINT	>= '"+cCodIntD+"' "
cQuery += "	AND		BQC.BQC_CODINT	<= '"+cCodIntA+"' "
cQuery += "	AND		BQC.BQC_CODEMP	>= '"+cCodEmpD+"' "
cQuery += "	AND		BQC.BQC_CODEMP	<= '"+cCodEmpA+"' "
cQuery += "	AND		BQC.BQC_NUMCON	>= '"+cConEmpD+"' "
cQuery += "	AND		BQC.BQC_NUMCON	<= '"+cConEmpA+"' "
cQuery += "	AND		BQC.BQC_VERCON	>= '"+cVerConD+"' "
cQuery += "	AND		BQC.BQC_VERCON	<= '"+cVerConA+"' "
cQuery += "	AND		BQC.D_E_L_E_T_	= ''  "     
cQuery += " ORDER BY    BQC_SUBCON, BQC.BQC_VERSUB ,BQC_NREDUZ,BQC_DESCRI "



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta nova janela de consulta padrão, utilizando a query para a filtragem.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	Tk510F3Qry( cQuery /*cQuery*/,"GCOBQC"/*cCodCon*/,"BQCRECNO"/*cCpoRecno*/,@nRetorno/*nRetorno*/,/*aCoord*/,/*aSearch*/,"BQC"/*cAlias*/)
	BQC->(DBGoto(nRetorno))
	lRet := .T.
EndIf

Return(lRet)

