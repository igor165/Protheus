#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "MsOle.ch"
#Include "PLSR993.ch"

#Define CRLF	Chr(13) + Chr(10)

Static objCENFUNLGP := CENFUNLGP():New()

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR993
 Impressao das Cartas de Portabilidade - ANS
 Via Microsoft Word / TXT   
@author  Roberto Barbosa
@version P12
@since   04/2019

/*/
//-------------------------------------------------------------------

Function PLSR993(lAutoma)

Local nI			:= 0
Local lCopy1		:= .F.
Local lCopy2		:= .F.
Local lProc			:= .F.
Local cPerg			:= "PLR993"
Local cPathArq		:= "\DOT"
Local cArqAgl		:= ""
Local cMensag		:= ""
Local cPathTMP		:= ""
Local lIsBlind		:= IsBlind()

Private aWord		:= {}
Private hWord		:= Nil
Private nConDoc		:= 0
Private cArqDot		:= ""
Private cPathEst	:= GetNewPar( "MV_PLSACMT" , "" ) 
Private aCriticas   := {}
Private lCriticou   := .F.

Default lAutoma 	:= .F.

if !lIsBlind .And. !(objCENFUNLGP::lPermPessoais)
	Help( ,, 'ACESSO',," O usuแrio nใo tem as permiss๕es necessแrias para acessar dados pessoais e/ou sensํveis. ", 1, 0,;
	NIL, NIL, NIL, NIL, NIL, {" Contate o administrador do sistema para a libera็ใo do acesso"})
	Return
EndIf

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
		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Inicia a Integracao com o Word											บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
		cArqDot := "Portabilidade.dot"
		cArqAgl	:= "Portabilidades.dot"
		
		
		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Se nao for alterado via parametro procura o arquivo na pasta "system"	บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
		cPathDot := cPathArq + cArqDot
		cPathAgl := cPathArq + cArqAgl
		
		//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
		//บ	Verifica a Existencia dos Arquivos DOT no StartPath do Protheus			บ
		//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ	
		If !lAutoma
			If !File(cPathDot)
				Aviso( STR0001 , STR0002+ CRLF + cPathDot + CRLF +STR0003 , {STR0004} )//Aten็ใo. O arquivo de Configura็ใo nao foi encontrado pelo Servidor! Fechar!
				Return()
			EndIf
		
			If !File(cPathAgl)
				Aviso( STR0001 , STR0002+ CRLF + cPathAgl + CRLF +STR0003 , {STR0004} )//Aten็ใo. O arquivo de Configura็ใo nao foi encontrado pelo Servidor! Fechar!
				Return()
			EndIf

			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Verifica Path do Temporแrio para grava็ใo na Estacao de Trabalho		บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
			If Substr(cPathEst,1,1) == "\" .OR. Substr(cPathEst,1,1) == "/"
				cMensag := STR0005+CRLF+ cPathEst +CRLF+STR0006+CRLF+GetTempPath()//"Nใo foi validado o diret๓rio temporแrio da Esta็ใo.Os arquivos temporแrios serใo gravados no diret๓rio
				Aviso( STR0001, cMensag , {STR0004} )//Aten็ใo
				cPathEst := GetTempPath()
			EndIf
	
			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Verifica Path para Armazenamento na Estacao de Trabalho					บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
			MontaDir( cPathEst )

			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Se ja existir arquivos no local, apaga para a nova geracao				บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
			If File( Lower( cPathEst + "\" + cArqDot ) )
				Ferase( Lower( cPathEst + "\" + cArqDot ) )
			EndIf
		
			If File( Lower( cPathEst + "\" + cArqAgl ) )
				Ferase( Lower( cPathEst + "\" + cArqAgl ) )
			EndIf
			
			If File( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
				Ferase( Lower( cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ) )
			EndIf
			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Faz a copia dos arquivos do Servidor para o Remote						บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
			lCopy1 := CpyS2T( cPathDot , cPathEst , .F. )
			lCopy2 := CpyS2T( cPathAgl , cPathEst , .F. )
			//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
			//บ	Verifica as Copias														บ
			//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
			If !lCopy1 .Or. !lCopy2
				Aviso( STR0007 , STR0008 + CRLF + cPathDot + CRLF + cPathEst , {STR0004} )//"Processamento Cancelado. Houve um problema com a c๓pia dos arquivos de configura็ao
				Return()
			EndIf
		EndIf

		lCriticou := .F.

		Processa( {|| lProc := GeraWord(lAutoma)} , STR0009 , STR0010 , .F. )//Iniciando o processamento...Aguarde
		
 		If lProc
		 	GravaLogBP3(aCriticas)

		 	If !Empty(aCriticas[1][2]) .AND. nConDoc == 0 .AND. lCriticou
			 	If !lAutoma		 	
			 		Aviso( STR0001 , STR0013 , {STR0004} )	//Aten็ใo. Nใo foram gerados dados para Impressใo. Verifique as criticas
					PLSCRIGEN(aCriticas,{ {"Beneficiแrio","@C",20},{"Critica","@C",200}},"Criticas da Gera็ใo da Carta de Portabilidade",,,,)
				EndIf	
				Return()
			Elseif !Empty(aCriticas) .AND. nConDoc > 0 .AND. lCriticou
				If !lAutoma	
					Aviso( STR0001 , "Relat๓rio Processado, por้m hแ beneficiarios criticados" , {STR0004} )	//Aten็ใo.
					PLSCRIGEN(aCriticas,{ {"Beneficiแrio","@C",20},{"Critica","@C",200}},"Criticas da Gera็ใo da Carta de Portabilidade",,,,)
				EndIf
			EndIf

			If !lAutoma
				//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
				//บ	Fecha os Documentos														บ
				//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
				For nI := 1 to nConDoc
					OLE_CloseFile( aWord[nConDoc] )
					OLE_CloseLink( aWord[nConDoc] )
				Next
				
				//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
				//บ	Cria Documento Unico para aglutinar os resultados						บ
				//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
				hWord := OLE_CreateLink()
				OLE_NewFile( hWord , cPathEst + "\" + cArqAgl )
				OLE_SetPropertie( hWord, oleWdVisible, .F. )

				OLE_SetDocumentVar(hWord , 'nQtArqs' , nConDoc )
				OLE_SetDocumentVar(hWord , 'nomeArquivo' , "\ImpCarta" )
				OLE_SetDocumentVar(hWord , 'pastaDocs' , cPathEst )

				OLE_UpdateFields( hWord )
				OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument  )

				OLE_ExecuteMacro( hWord , "JuntaTudo" )
				OLE_SaveAsFile( hWord , cPathEst + "\" + SubStr(cArqAgl,1,Len(cArqAgl)-4) + ".DOC" ,,, .F. , oleWdFormatDocument  )

				Aviso( STR0001 , "Arquivo enviado para Impressใo" , {"Ok"} )//Arquivo enviado para impressao...
				OLE_PrintFile( hWord , "PART" , 2 , nConDoc + 1 , 1 )							
				Sleep(2000)          
				
				OLE_CloseFile( hWord )		// Fecha ultimo arquiv
				OLE_CloseLink( hWord )		// Fecha link com Word
				
				//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
				//บ	Apaga os Arquivos Temporarios											บ
				//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
				For nI := 1 to nConDoc
					If File( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
						FErase( cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nI)) + ".DOC" )
					EndIf
				Next
				
				//ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
				//บ	Exclui os Arquivos Temporarios apos a utilizacao.						บ
				//ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
				If File( Lower( cPathEst + "\" + cArqDot ) )
					Ferase( Lower( cPathEst + "\" + cArqDot ) )
				EndIf
			
				If File( Lower( cPathEst + "\" + cArqAgl ) )
					Ferase( Lower( cPathEst + "\" + cArqAgl ) )
				EndIf

			EndIf
			
		EndIf    	
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraWord
 Funcao que retorna os dados e gera a pagina a ser impressa atraves do modelo
@author  Roberto Barbosa
@version P12
@since   04/2019
/*/
//-------------------------------------------------------------------

Static Function GeraWord( lAutoma )
	Local cSql	     := ""	
	Local nDataDif   := 0
	Local lBP3 		 := PLSALIASEXI("BP3")
	Local cOpera     := Substr(MV_PAR01, 1,4) //MvPar_01 - Operadora?
	Local cEmp   	 := Substr(MV_PAR01, 5,4) //MvPar_02 - Grupo Empresa De?
	Local cMatric    := Substr(MV_PAR01, 9,6) //MvPar_08 - Matricula De?
	Local cTpReg     := Substr(MV_PAR01, 15,2)
	local cDigito    := Substr(MV_PAR01, 17,1)
	Local cFalec	 := MV_PAR02 //MvPar_12 - Considera data de falecimento do titular do plano?
	Local cDemApos   := MV_PAR03 //MvPar_13 - Considera Beneficiarios demitidos e aposentados? 
	Local cReemit	 := MV_PAR04 //Reemitir carta?	
	Local cGeraFAM   := MV_PAR05
	Local aDadUsr    := {}
	Local aRetCri    := {}
	Local dDtAtu     := dDatabase
	Local nI         := 0
	Local cMatBenf   := ""
   	Private	cAnivInc := "" //Minimo 2 anos no plano para troca realizar a portabilidade
    Private cAdimp   := ""//Adimplente ou Inadimplente

	Default lAutoma := .F.

	cSql := " SELECT DISTINCT BA3_CODINT, BA3_CODEMP, BA3_MATRIC, BA1_TIPREG, BA1_DIGITO, "
	cSql += " BA1_NOMUSR, BA1_CPFUSR, BA1_CEPUSR, BA1_ENDERE, BA1_NR_END, BA1_DATCPT, "
	cSql += " BA1_BAIRRO, BA1_ESTADO, BA1_MUNICI, BA1_TELEFO, BA1_EMAIL, BA1_GRAUPA, "
	cSql += " BA1_DATINC, BA3_PLPOR , BA3_DATDES, BA3_CONEMP,BA3_VERCON, BA3_SUBCON,BA3_VERSUB, BA3_TIPOUS, "
    cSql += " BA1_DATNAS, BA3_CODPLA, BA3_VERSAO, BA1_PLPOR, BA3_FORPAG,BA3_ROTINA "
	If BA3->(FieldPos("BA3_OFERTA")) > 0
		cSql += " , BA3_OFERTA"
	EndIF
	cSql += " FROM "+RetSqlName("BA1")+" BA1 "
	cSql += " INNER JOIN "+RetSqlName("BA3")+" BA3"
	cSql += " 	ON	BA1.BA1_FILIAL	= BA3.BA3_FILIAL "
	cSql += " 	AND BA1.BA1_CODINT	= BA3.BA3_CODINT "
	cSql += " 	AND BA1.BA1_CODEMP	= BA3.BA3_CODEMP "
	cSql += " 	AND BA1.BA1_CONEMP	= BA3.BA3_CONEMP "
	cSql += " 	AND BA1.BA1_VERCON	= BA3.BA3_VERCON "
	cSql += " 	AND BA1.BA1_SUBCON	= BA3.BA3_SUBCON "
	cSql += " 	AND BA1.BA1_VERSUB	= BA3.BA3_VERSUB "
	cSql += " 	AND BA1.BA1_MATRIC	= BA3.BA3_MATRIC "
	cSql += " WHERE "
	cSql += " BA1_FILIAL = '" + xFilial("BA1") + "' AND "
	cSql += " BA1_CODINT = '" + cOpera  + "' AND "
	cSql += " BA1_CODEMP = '" + cEmp    + "' AND "
	cSql += " BA1_MATRIC = '" + cMatric + "' AND " 
	
	If !cGeraFAM == 1
	   cSql += " BA1_TIPREG = '" + cTpReg  + "' AND " 
	   cSql += " BA1_DIGITO = '" + cDigito + "' AND "	
	EndIf

	If cFalec == 1 .AND. !cDemApos == 1//Considera data de falecimento do titular do plano 
		cSql += " BA3_DESLIG = '3' AND "
	ElseIf !cFalec == 1 .AND. cDemApos == 1
        cSql += " BA3_DESLIG IN ('1','2') AND "
    ElseIf cFalec == 1 .AND. cDemApos == 1
        cSql += " BA3_DESLIG IN ('1','2', '3') AND "
    EndIf
	
	cSql += " BA3_APLEI = '1' AND " //Somente Planos Regulamentados
	cSql += " BA1.D_E_L_E_T_ = ' ' AND "
	cSql += " BA3.D_E_L_E_T_ = ' ' "

	//cSql := ChangeQuery(cSql)

	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , "TRBWORD" , .F. , .T. )

	TRBWORD->(DBGoTop())

	aCriticas := {}

	If TRBWORD->(Eof())
		TRBWORD->(DBCloseArea())
		If !lAutoma
			Aviso( STR0004 , STR0014 , {STR0004} )//Aten็ใo. Nใo foram encontrados dados para processar com esta parametriza็ใo
		EndIf
		Return(.F.)	
	Else

		While !TRBWORD->(Eof())
						
			aDadUsr   := {}
			aRetCri   := {}

			//Posiciono as tabelas para as fun็๕es de valida็ใo.
			BA1->(DbSetOrder(2))
			BA1->(MsSeek(xFilial("BA1")+TRBWORD->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA1_TIPREG+BA1_DIGITO)))

			BA3->(DbSetOrder(7))
			BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERCON+BA1_MATRIC)))

			BQC->(DbSetOrder(1))
			BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERCON)))

			cMatBenf := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
		
			//Verifico se jแ foi efetuado a gera็ใo da carta de Portabilidade.
			If !cReemit == 1		
			  If VerifBP3(cMatBenf)
			  	  cAnivInc := Calc_Idade(dDtAtu, BP3->BP3_DTGER)//Ap๓s a primeira gera็ใo, s๓ poderแ gerar de novo ap๓s 1 ano.
			  	  If cAnivInc < 1
			  	  	 aAdd(aCriticas,{TRBWORD->BA1_NOMUSR, STR0017,cMatBenf})//Carta jแ gerada. Tempo minimo para nova gera็ใo nใo cumprido.
					 lCriticou := .T.
			  	  	 TRBWORD->(dbSkip())
			  	  	 Loop
			  	  EndIf
			  Endif
			EndIf

			//Verifico se o beneficiario estแ ativo na data da gera็ใo.
			If PlChHiBlo("BCA",dDtAtu,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG)
				aAdd(aCriticas,{TRBWORD->BA1_NOMUSR, STR0016,cMatBenf})//Nใo foi possivel gerar a carta de Portabilidade. Beneficiario nใo estแ ativo.				
				lCriticou := .T.
				TRBWORD->(dbSkip())
				Loop
			EndIf			

			//Verifico se existem pendencias financeiras		
			aDadUsr := PLSDADUSR(TRBWORD->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA1_TIPREG+BA1_DIGITO),'1',.F.,dDtAtu,,,"NAO_VALIDAR_CARTAO")

			If aDadUsr[1] //Se nใo houve critica nos cadastros eu valido a critica financeira.

				aRetCri := PLSVLDFIN(cMatBenf,dDtAtu,"", "", "",aDadUsr, nil, nil, nil, "")

				If !aRetCri[1]					
					For nI := 1 to Len(aRetCri[2])											
						Aadd(aCriticas,{TRBWORD->BA1_NOMUSR, aRetCri[2][nI][2], cMatBenf})
						Aadd(aCriticas,{TRBWORD->BA1_NOMUSR, aRetCri[2][nI][3], cMatBenf})
					Next					
					lCriticou := .T.
                    cAdimp := "Beneficiario se encontra Inadimplente."
					TRBWORD->(dbSkip())
					Loop
				Else    
                    cAdimp := "Beneficiario se encontra Adimplente."
                EndIf
			Else
				Aadd(aCriticas,{TRBWORD->BA1_NOMUSR, aDadUsr[2][1][2], cMatBenf})
				lCriticou := .T.
				TRBWORD->(dbSkip())
				Loop
			EndIf

			//Verifica se o beneficiario possui CPT. Nesse caso, serใo 3 anos para gera็ใo da carta
			//a) na primeira portabilidade de car๊ncias, no mํnimo dois anos no plano de origem ou no mํnimo tr๊s anos na 
			//hip๓tese de o beneficiแrio ter cumprido cobertura parcial temporแria
			cAnivInc := Calc_Idade(dDtAtu, STOD(TRBWORD->BA1_DATINC))

			If PLSIBCPT(dDtAtu,cMatBenf) == "1" .AND. cAnivInc < 3				
				aAdd(aCriticas,{TRBWORD->BA1_NOMUSR, STR0018})//Prazo para Beneficiarios com CPT nใo cumprido.
				lCriticou := .T.
				TRBWORD->(dbSkip())
				Loop
			EndIf					

			If cAnivInc < 1
				aAdd(aCriticas,{TRBWORD->BA1_NOMUSR, STR0019, cMatBenf})//Tempo minimo de permanc๊ncia do Plano para solicitar a Portabilidade nใo cumprido.
				lCriticou := .T.
				TRBWORD->(dbSkip())
				Loop
			ElseIf Empty(TRBWORD->BA3_PLPOR) .and. cAnivInc < 2		
				aAdd(aCriticas,{TRBWORD->BA1_NOMUSR, STR0020, cMatBenf})//Necessแrio no minimo de 2 anos de Plano para solicitar Portabilidade.				
				lCriticou := .T.
				TRBWORD->(dbSkip())
				Loop
			ElseIf !Empty(TRBWORD->BA3_PLPOR) .and. cAnivInc < 1
				aAdd(aCriticas,{TRBWORD->BA1_NOMUSR, STR0021, cMatBenf})//Tempo minimo para solicitar uma nova Portabilidade ้ de 1 ano.				
				lCriticou := .T.
				TRBWORD->(dbSkip())
				Loop
			EndIf
			/*
			Falecimento do Titular: Caso ocorra o falecimento do titular, os dependentes vinculados ao plano privado de 
			assist๊ncia เ sa๚de poderใo exercer a portabilidade especial de car๊ncias para plano de sa๚de individual ou
			familiar ou coletivo por adesใo, no prazo de 60 (sessenta) dias do falecimento. 
			*/
			If cFalec == 1  
				If !Empty(TRBWORD->BA3_DATDES)
					nDataDif := DateDiffDay( STOD(TRBWORD->BA3_DATDES), DATE())
					If nDataDif > 60
						aAdd(aCriticas,{TRBWORD->BA1_NOMUSR, STR0022, cMatBenf})//Em Caso de Falecimento, o prazo para exercer a portabilidade ้ de 60 dias.						
						lCriticou := .T.
						TRBWORD->(dbSkip())
						Loop
					Endif
				EndIf
			EndIf
			/*
			Demitidos/Aposentados: O ex-empregado demitido ou exonerado sem justa causa ou aposentado ou seus 
			dependentes vinculados ao plano poderใo exercer a portabilidade especial de car๊ncias para plano de sa๚de 
			individual ou familiar ou coletivo por adesใo, no prazo de 60 (sessenta) dias antes do t้rmino do perํodo de 
			manuten็ใo da condi็ใo de beneficiแrio.
			*/	
			If cDemApos == 1 
				If !Empty(TRBWORD->BA3_DATDES)
					nDataDif := DateDiffDay( STOD(TRBWORD->BA3_DATDES), DATE())
					If nDataDif > 60
						aAdd(aCriticas,{TRBWORD->BA1_NOMUSR,STR0023, cMatBenf})//Em Caso de Ex Empregado, o prazo para exercer a portabilidade ้ de 60 dias.						
						lCriticou := .T.
						TRBWORD->(dbSkip())
						Loop
					EndIf
				EndIf
			EndIf		
			/*
			Perda da Condi็ใo de Dependente: O beneficiแrio titular do plano privado de assist๊ncia เ sa๚de extinto 
			em decorr๊ncia da perda de sua condi็ใo de dependente, poderแ exercer a portabilidade especial de car๊ncias,
			no prazo de 60 (sessenta) dias a contar do t้rmino do vํnculo de depend๊ncia.
			*/		
			aAdd(aCriticas,{TRBWORD->BA1_NOMUSR," ", cMatBenf})//Carta gerada

			If !lAutoma
				CriaNovoPor()
				ZeraCarPor()
			EndIf			
			GravaCarPor( "TRBWORD" , lAutoma )
			If !lAutoma
				OLE_CloseFile( aWord[nConDoc] )
				OLE_CloseLink( aWord[nConDoc] )		
			EndIf
			TRBWORD->(dbSkip())
		EndDo
									


		TRBWORD->(DBCloseArea())
	Endif

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCarPor
 Funcao que grava os dados da Consulta na Carta
@author  Roberto Barbosa
@version P12
@since   04/2019
/*/
//-------------------------------------------------------------------
Static Function GravaCarPor( cAlias , lAutoma )

	Local aDados	 := Array(35)
	Local cOper		 := ""
	Local cRua		 := ""
	Local cBairro    := ""
	Local cCidade    := ""
	Local cUF        := ""
	Local cTelefone  := ""
	Local cTelCen    := ""
	Local cTelFax    := ""
	Local cEmail     := ""		
	Local cCodInt    := (cAlias)->BA3_CODINT
    Local cSusepBA0  := ""
    Local cSusepBI3  := ""
    Local cChvBI3    := Alltrim((cAlias)->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO))
    Local cPortab    := Alltrim((cAlias)->BA1_PLPOR)   
    Local cMsgPorta  := "" 
    Local lRetInt    := .F.
    Local cMsgInt    := ""
    Local cMatric    := ""
    Local aRetMens   := {}
    Local aUsuarios  := {}
    Local cData      := DTOS(Date())
    Local cForPag	 := (cAlias)->BA3_FORPAG
    Local aEventosCb := {}
    Local aCliente   := {}
    Local cRdmake    := AllTrim((cAlias)->BA3_ROTINA)
    Local aFoCoPF    := {}
    Local aLanUsu    := {}
    Local cNumCob    := ""
    Local cReemb     := "2"
    LOCAL lDatPagto  := GetNewPar("MV_PLSDTPG",.F.)
    Local dDatPagto  := cTod("")
    Local nPos       := 0
    Local nVlrMens   := 0
    Local cAnoMesAnt := ""
	Local cOferta    := "Nใo"
	Local cTipPlan   := ""
	Local lMudaCont  := .F.
	Local cPlano     := "Nใo houve Mudan็a de Plano na Operadora"
	Local aDadosCPT  := {}
	Local nI         := 0
	Local cCPT       := ""
	Local nPosCPT    := 0
	Local aDadInt    := {}
	Local cMatricUsr := (cAlias)->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA1_TIPREG+BA1_DIGITO)

	Default lAutoma  := .F. 

	BA0->(DbSetOrder(1))
	If BA0->(MsSeeK(xFilial("BA0")+cCodInt))
		cOper 	  := AllTrim(BA0->BA0_NOMINT)
		cRua      := Alltrim(BA0->BA0_END) + "," + AllTrim(BA0->BA0_NUMEND)
		cBairro   := AllTrim(BA0->BA0_BAIRRO)
		cCidade   := AllTrim(BA0->BA0_CIDADE)
		cUF       := AllTrim(BA0->BA0_EST)
		cTelefone := AllTrim(BA0->BA0_TELEF1)
		cEmail	  := AllTrim(BA0->BA0_EMAIL)
		cTelCen   := AllTrim(BA0->BA0_TELEF1)
		cTelFax   := AllTrim(BA0->BA0_FAX1)
        cSusepBA0 := AllTrim(BA0->BA0_SUSEP)
	EndIf

    BI3->(DbSetOrder(1))
	If BI3->(MsSeeK(xFilial("BI3")+cChvBI3))
        cSusepBI3 := BI3->BI3_SUSEP
		Do Case
			Case BI3->BI3_APOSRG == '0'
				cTipPlan := 'Plano Nao Regulamentado'
			Case BI3->BI3_APOSRG == '1'
				cTipPlan := 'Plano Regulamentado'
			Case BI3->BI3_APOSRG == '2'
				cTipPlan := 'Plano Adaptado'
		EndCase
    EndIf

	//Verifico se houve mudan็a de plano
	BQQ->(DbSetOrder(1))//BQQ_FILIAL+BQQ_CODINT+BQQ_EMPORI+BQQ_CONORI+BQQ_VCOORI+BQQ_SUBORI+BQQ_VRSORI+BQQ_FAMORI
	If BQQ->(MsSeeK(xFilial("BQQ")+(cAlias)->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_MATRIC)))
		If lMudaCont:= BQQ->BQQ_CODPRO <> (cAlias)->BA3_CODPLA
			cPlano := "Houve mudan็a de Plano na Operadora"

		EndIF
	EndIF

    If Empty(cPortab)
        cMsgPorta := "Sem Portabilidade"
    Else
        cMsgPorta := "Ingressou no Plano Via Portabilidade. " + "Plano Anterior: " + alltrim((cAlias)->BA1_PLPOR)
    EndIf

	If BA3->(FieldPos("BA3_OFERTA")) > 0
		If (cAlias)->BA3_OFERTA == "1"
			cOferta := "Sim"
		Else
			cOferta := "Nใo"
		EndIF
		
	Else
		cOferta := "Nใo"
	EndIF

    //Valor da Mensalidade
    If Len(aFoCoPF) == 0
	    aFoCoPF := PLSRETFCPF((cAlias)->BA3_CODINT,(cAlias)->BA3_CODEMP,(cAlias)->BA3_CONEMP,(cAlias)->BA3_VERCON,(cAlias)->BA3_SUBCON,;
					  	  (cAlias)->BA3_VERSUB,(cAlias)->BA3_CODPLA,(cAlias)->BA3_VERSAO,(cAlias)->BA3_TIPOUS)
    EndIf

    If 	aFoCoPF[1] == "1"
		cAnoMesAnt := Substr(cData,1,4)+Substr(cData,5,2)
	Else
		cAnoMesAnt := PLSDIMAM(Substr(cData,1,4),Substr(cData,5,2),"0")
	EndIf
   
    If Empty(aEventosCb)
        aEventosCb := PLSINPBFQ((cAlias)->BA3_CODINT)
    EndIf

    If Len(aLanUsu) == 0
	    aLanUsu := PLSRETLANU((cAlias)->BA3_CODINT)
    EndIf
    //Pessoa Juridica
    aCliente := PLS770NIV((cAlias)->BA3_CODINT,(cAlias)->BA3_CODEMP,;
                            (cAlias)->BA3_MATRIC,If((cAlias)->BA3_TIPOUS=="1","F","J"),;
						  (cAlias)->BA3_CONEMP,(cAlias)->BA3_VERCON,(cAlias)->BA3_SUBCON,;
						  (cAlias)->BA3_VERSUB,1)

    cMatric  := (cAlias)->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
    aUsuarios := PLSLOADUSR((cAlias)->BA3_CODINT,(cAlias)->BA3_CODEMP,(cAlias)->BA3_MATRIC,Substr(cAnoMesAnt,1,4),Substr(cAnoMesAnt,5,2))
    
    aRetMens  := PLSBUSFAI(cMatric,Substr(cData,1,4),Substr(cData,5,2),cForPag,aEventosCB,aCliente,aUsuarios,.f.,.f.,cRdMake,aFoCoPF,aLanUsu,cNumCob,cReemb,lDatPagto,dDatPagto)

    nPos := Ascan(aRetMens,{|x| AllTrim(x[3]) == "101"})
    If nPos > 0
        nVlrMens := aRetMens[nPos][23] //Alguns Beneficiarios nใo possuem valor
    EndIF

    //Verifico se o Beneficiario estแ internado
	aDadInt := PLSPACINT(cMatricUsr, Date())
	lRetInt := aDadInt[1]

	If lRetInt 
        cMsgInt := "Beneficiario estแ Internado."
    Else
        cMsgInt := "Beneficiario nใo estแ Internado."
    EndIf

	aDados[01] := IIf( Empty((cAlias)->BA1_NOMUSR) , "[Erro ao identificar o Nome do Beneficiario]" , Alltrim((cAlias)->BA1_NOMUSR))
	aDados[02] := IIf( Empty(cOper),    "[Erro ao identificar o Nome da Operadora]",cOper)
	aDados[03] := IIf( Empty(cOper),    "[Erro ao identificar o Nome da Operadora]", cOper)
	aDados[04] := IIf( Empty(cRua) ,    "[Erro ao identificar o Endere็o]" , cRua)
	aDados[05] := IIf( Empty(cBairro) , "[Erro ao identificar o Bairro]" , cBairro)
	aDados[06] := IIf( Empty(cCidade) , "[Erro ao identificar a Cidade]" , cCidade) 
	aDados[07] := IIf( Empty(cUF) ,     "[Erro ao identificar a UF]" , cUF)
	aDados[08] := IIf( Empty(cTelefone),"(00) 0000-0000" , cTelefone) 
	aDados[09] := IIf( Empty(cEmail) ,  "email@empresa.com.br" , cEmail)

    aDados[10] := IIf( Empty((cAlias)->BA1_NOMUSR) , "[Erro ao identificar o Nome do Beneficiario]" , (cAlias)->BA1_NOMUSR) 
    aDados[11] := IIf( Empty((cAlias)->BA1_CPFUSR) , "[Erro ao identificar o CPF do Beneficiario]"  , (cAlias)->BA1_CPFUSR)
    aDados[12] := IIf( Empty((cAlias)->BA1_DATNAS) , "[Erro ao identificar a Data de Nascimento do Beneficiario]" , STOD((cAlias)->BA1_DATNAS))
    aDados[13] := IIf( Empty((cAlias)->BA1_DATINC) , "[Erro ao identificar a Data de Adesใo do Beneficiario]" , STOD((cAlias)->BA1_DATINC))
    aDados[14] := IIf( Empty(cSusepBA0)    , "[Erro ao identificar o Nบ de registro da Operadora]" , cSusepBA0)
    aDados[15] := IIf( Empty(cSusepBI3) ,    "[Erro ao identificar o Nบ de registro do Plano]"  , cSusepBI3)
    aDados[16] := IIf( Empty(cAnivInc) ,     "[Erro ao identificar o Prazo de Permanencia]" , cValToChar(cAnivInc) + " Anos")
    aDados[17] := IIf( Empty(cAdimp) ,       "[Erro ao identificar as informa็๕es de Adimplencia do Beneficiario]" , cAdimp)
    aDados[18] := cMsgPorta
    aDados[19] := cOferta//Oferta Publica ou transferencia de carteira BA1_MATANT?
    aDados[20] := cPlano //Mudou de plano na Operadora
    aDados[21] := cMsgInt//Beneficiแrio Internado

    aDados[22] := cTipPlan //Tipo de Plano Adaptado?
    aDados[23] := "R$"+cValToChar(nVlrMens) //Valor da Mensalidade

	aDadosCPT := PLSR993CPT(cAlias)

	If len(aDadosCPT) > 0
		For nI := 1 to len(aDadosCPT)
			cCPT := "CID: "+aDadosCPT[nI][1] + "  Data de Inicio: "+DTOC(aDadosCPT[nI][6])+"  Data final do CPT: "+aDadosCPT[nI][8]+ "|"
			nPosCPT := 23 + nI
			aDados[nPosCPT] := cCPT
		Next
	Else
    	aDados[24] := "Beneficiario Nใo estแ Cumprindo CPT" //Cumpriu ou estแ cumprindo CPT    
	EndIF
	
	If !lAutoma
		OLE_SetDocumentVar( aWord[nConDoc], "NomBenef"	    , aDados[01] )
		OLE_SetDocumentVar( aWord[nConDoc], "OPERADORA"		, aDados[02] )	
		OLE_SetDocumentVar( aWord[nConDoc], "OPERADORA"	    , aDados[03] )
		OLE_SetDocumentVar( aWord[nConDoc], "RUA"    		, aDados[04] )
		OLE_SetDocumentVar( aWord[nConDoc], "BAIRRO"    	, aDados[05] )
		OLE_SetDocumentVar( aWord[nConDoc], "CIDADE"		, aDados[06] )
		OLE_SetDocumentVar( aWord[nConDoc], "UF"			, aDados[07] )
		OLE_SetDocumentVar( aWord[nConDoc], "TELEFONE"		, aDados[08] )
		OLE_SetDocumentVar( aWord[nConDoc], "EMAIL"			, aDados[09] )	  
		OLE_SetDocumentVar( aWord[nConDoc], "NomBenef"		, aDados[10] )
		OLE_SetDocumentVar( aWord[nConDoc], "CPF"			, aDados[11] )
		OLE_SetDocumentVar( aWord[nConDoc], "DataNasc"		, aDados[12] )
		OLE_SetDocumentVar( aWord[nConDoc], "DataAdes"		, aDados[13] )
		OLE_SetDocumentVar( aWord[nConDoc], "NumRegOpe"		, aDados[14] )
		OLE_SetDocumentVar( aWord[nConDoc], "NumRegProd"	, aDados[15] )
		OLE_SetDocumentVar( aWord[nConDoc], "DataPerma"		, aDados[16] )
		OLE_SetDocumentVar( aWord[nConDoc], "Adimplen"		, aDados[17] )
		OLE_SetDocumentVar( aWord[nConDoc], "Portabilidade" , aDados[18] )
		OLE_SetDocumentVar( aWord[nConDoc], "OfertTransf"	, aDados[19] )
		OLE_SetDocumentVar( aWord[nConDoc], "MudouPlano"    , aDados[20] )
		OLE_SetDocumentVar( aWord[nConDoc], "Internado"	    , aDados[21] )
		OLE_SetDocumentVar( aWord[nConDoc], "PlanoAdaptado"	, aDados[22] )
		OLE_SetDocumentVar( aWord[nConDoc], "VlrMensalidade", aDados[23] )
		OLE_SetDocumentVar( aWord[nConDoc], "CPT"		    , aDados[24] )
		If len(aDados) > 24
			OLE_SetDocumentVar( aWord[nConDoc], "CPT1"		, Iif (valtype(aDados[25]) == "U","",aDados[25] ))
			OLE_SetDocumentVar( aWord[nConDoc], "CPT2"		, Iif (valtype(aDados[26]) == "U","",aDados[26] ) )
			OLE_SetDocumentVar( aWord[nConDoc], "CPT3"		, Iif (valtype(aDados[27]) == "U","",aDados[27] ) )
			OLE_SetDocumentVar( aWord[nConDoc], "CPT4"		, Iif (valtype(aDados[28]) == "U","",aDados[28] ) )
			OLE_SetDocumentVar( aWord[nConDoc], "CPT5"		, Iif (valtype(aDados[29]) == "U","",aDados[29] ) )
		EndIF

		OLE_UpdateFields( aWord[nConDoc] )

		OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".DOC" ,,, .F. , oleWdFormatDocument )
	EndIf
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ZeraCarPor
 Zera os controladores para geracao de nova Carta
@author  Roberto Barbosa
@version P12
@since   04/2019
/*/
//-------------------------------------------------------------------
Static Function ZeraCarPor()

OLE_SetDocumentVar(aWord[nConDoc]	, "NOME"	      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "OPERADORA"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "RUA"	          , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "BAIRRO"     	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CIDADE"	      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "UF"	          , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "TELEFONE"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "EMAIL"	      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "NomBenef"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CPF"			  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "DataNasc"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "DataAdes"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "NumRegOpe"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "NumRegProd"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "DataPerma"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "Adimplen"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "Portabilidade" , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "OfertTransf"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "MudouPlano"    , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "Internado"	  , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "PlanoAdaptado" , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "VlrMensalidade", "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CPT"		      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CPT1"	      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CPT2"	      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CPT3"	      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CPT4"	      , "" )
OLE_SetDocumentVar(aWord[nConDoc]	, "CPT5"	      , "" )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaNovoPor
 Gera o novo arquivo para gravacao
@author  Roberto Barbosa
@version P12
@since   04/2019
/*/
//-------------------------------------------------------------------
Static Function CriaNovoPor()

aAdd( aWord , 0 )
nConDoc++

aWord[nConDoc] := OLE_CreateLink()

//Cria o novo arquivo no Remote											บ
OLE_NewFile( aWord[nConDoc] , cPathEst + "\" + cArqDot )
//Ajusta Propriedades do Arquivo											บ
OLE_SetPropertie( aWord[nConDoc] , oleWdVisible , .F. )
//Salva o arquivo com o novo nome no Remote								บ
OLE_SaveAsFile( aWord[nConDoc] , cPathEst + "\" + SubStr(cArqDot,1,Len(cArqDot)-4) + ALLTRIM(STR(nConDoc)) + ".doc" ,,, .F. , oleWdFormatDocument )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaLogBP3
Gravo o registro do Processamento na tabela BP3
@author  Roberto Barbosa
@version P12
@since   04/2019
/*/
//-------------------------------------------------------------------
Static Function GravaLogBP3(aCriticas)
	Local nTamCri := Len(aCriticas)
	Local nI  	  := 0
	Local cMatric := ""
	Local cTipReg := ""
	Local cDigito := ""

	BP3->(DbSelectArea("BP3"))

	For nI := 1 to nTamCri	
			cMatric := Substr(aCriticas[nI][3], 1, 14)
			cTipReg := Substr(aCriticas[nI][3], 15, 2)
			cDigito := Substr(aCriticas[nI][3], 17, 1)

			BP3->(DbSetOrder(1))

			BP3->(Reclock("BP3",.T.))
			BP3->BP3_FILIAL  := xFilial("BP3")
			BP3->BP3_MATRIC  := cMatric
			BP3->BP3_TIPREG  := cTipReg
			BP3->BP3_DIGITO  := cDigito
			BP3->BP3_DTGER   := Date()
			BP3->BP3_HRGER   := Time()
			BP3->BP3_CRITICA := IIF(Empty(aCriticas[nI][2]), " ",aCriticas[nI][2])
			BP3->BP3_STATUS  := IIF(Empty(aCriticas[nI][2]), "1","2")
			BP3->BP3_OPERA   :=	cUserName
			BP3->(MsUnlock())		
	Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifBP3
Verifica se jแ houve gera็ใo da carta de portabilidade
@author  Roberto Barbosa
@version P12
@since   04/2019
/*/
Function VerifBP3(cMatric)
	Local lRet    := .F.
	Local cSql    := ""
	Local cMatBP3 := SUBSTR(cMatric,1,14)
	Local cTpReg  := SUBSTR(cMatric,15,2)
	Local cDigito := SUBSTR(cMatric,17,1)

	cSql := " SELECT BP3_STATUS "
	cSql += " FROM "+RetSqlName("BP3")	
	cSql += " WHERE "
	cSql += " BP3_FILIAL = '" + xFilial("BP3") + "' AND "
	cSql += " BP3_MATRIC = '" + cMatBP3 + "' AND " 
	cSql += " BP3_TIPREG = '" + cTpReg + "' AND " 
	cSql += " BP3_DIGITO = '" + cDigito + "' AND " 
	cSql += " D_E_L_E_T_ = ' ' "

	DBUseArea( .T. , "TOPCONN" , TCGENQRY(,,cSql) , "TRBBP3" , .F. , .T. )

	While !TRBBP3->(EOF())
		If TRBBP3->BP3_STATUS == "1"
			lRet := .T. //Jแ gerada.
			Exit
		EndIf
		TRBBP3->(DbSkip())
	EndDo

	TRBBP3->(DBCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR993CPT
Retorna os dados referentes ao CPT do beneficiario
@author  Roberto Barbosa
@version P12
@since   07/2019
/*/
Function PLSR993CPT(cAlias)
Local aArea     := GetArea()
Local aDados    := {}
Local cUnid     := "" 
Local cSQL      := ""
Local cPag      := ""
Local cDatCpt	:= ""
Local nDias		:= 0
Local cCod      := (cAlias)->(BA3_CODINT)
Local cEmp      := (cAlias)->(BA3_CODEMP)
Local cMatr     := (cAlias)->(BA3_MATRIC)
Local cTpReg    := (cAlias)->(BA1_TIPREG)

cSQL := "SELECT BF3.BF3_CODDOE,BF3.BF3_PAGAGR,BF3.BF3_VALAGR,BF3.BF3_PERAGR, BF3.BF3_MESAGR, BF3.BF3_UNAGR , BF3.BF3_DATCPT, "
cSQL += "BA9.BA9_DOENCA FROM " + RetSQLName("BF3")+ " BF3, " + RetSQLName("BA9")+ " BA9" +" WHERE "

cSQL += "BF3_FILIAL = '"+xFilial("BF3")+"' AND "
cSQL += "BF3.BF3_CODINT = '"+cCod+"' AND "
cSQL += "BF3.BF3_CODEMP = '"+cEmp+"' AND "
cSQL += "BF3.BF3_MATRIC = '"+cMatr+"' AND "
cSQL += "BF3.BF3_TIPREG = '"+cTpReg+"' AND "
cSQL += "BF3.D_E_L_E_T_ = ' ' AND "

cSQL += "BA9.BA9_FILIAL = '"+xFilial("BA9")+"' AND "
cSQL += "BA9.BA9_CODDOE = BF3.BF3_CODDOE AND "
cSQL += " BA9.D_E_L_E_T_ = ' ' "

PLSQUERY(cSQL,"Trb")

While ! Trb->(EOF())
    
    If Trb->BF3_MESAGR == 0
		cUnid	:= ""
		cDatCPt := "" 
	Else
		DO CASE
			CASE Trb->BF3_UNAGR =="1" 
				cUnid	:='Horas' //"Horas"
				nDias := IIf(Trb->BF3_MESAGR > 24,Int(Trb->BF3_MESAGR/24),0) 
				cDatCPt :=DtoC(Trb->BF3_DATCPT+nDias)
			CASE Trb->BF3_UNAGR =="2" 
				cUnid:='Dias' //"Dias"
				nDias 	:= PLSCarDias(Trb->BF3_MESAGR,Trb->BF3_UNAGR)
				cDatCPt :=DtoC(Trb->BF3_DATCPT+nDias)
			CASE Trb->BF3_UNAGR =="3" 
				cUnid:='Meses' //"Meses"
				If  Empty(Trb->BF3_DATCPT)
					If Empty((cAlias)->BA1_DATCPT)
						nDias	:= Abs(( date() -MonthSum( date() , 0 )))
						cDatCPt := DtoC(date()+nDias)
					Else
						nDias	:= Abs(((cAlias)->BA1_DATCPT -MonthSum((cAlias)->BA1_DATCPT , Trb->BF3_MESAGR )))
						cDatCPt := DtoC((cAlias)->BA1_DATCPT+nDias)
					Endif		
					
				Else
					nDias	:= Abs((Trb->BF3_DATCPT -MonthSum(Trb->BF3_DATCPT , Trb->BF3_MESAGR )))
				    cDatCPt := DtoC(Trb->BF3_DATCPT+nDias)
				Endif	
			CASE Trb->BF3_UNAGR =="4" 
				cUnid:='Anos' //"Anos"
				nDias 	:= PLSCarDias(Trb->BF3_MESAGR,Trb->BF3_UNAGR)
				cDatCPt :=DtoC(Trb->BF3_DATCPT+nDias)
			OTHERWISE
				cUnid:=""
		ENDCASE
	Endif
	
	IF Trb->BF3_PAGAGR == "0"
		cPag:= 'Nใo' //"Nao"
	ElseIf Trb->BF3_PAGAGR == "1"
		cPag:= 'Sim' //"Sim"
	Endif

	aAdd(aDados,{Trb->BF3_CODDOE,;
				 Trb->BA9_DOENCA,;
				 cPag,;
				 IIF(Trb->BF3_PAGAGR == "0","",Transform(Trb->BF3_VALAGR,"@E 999,999,999.99")),;
				 IIF(Trb->BF3_PAGAGR == "0","",Trb->BF3_PERAGR),;
				 If(Empty(BF3->BF3_DATCPT),If(Empty((cAlias)->BA1_DATCPT),date(),(cAlias)->BA1_DATCPT),Trb->BF3_DATCPT),;
				 IIF(Trb->BF3_MESAGR == 0 ,"",Alltrim(STR(Trb->BF3_MESAGR)))+" "+cUnid,;
				 cDatCPt})

	Trb->(dbSkip())

EndDo

Trb->(DbCloseArea()) 

RestArea(aArea)

Return aDados