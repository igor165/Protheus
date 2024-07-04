#INCLUDE "Protheus.CH"
#INCLUDE "RSPM002.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RSPM002  ³ Autor ³ Emerson Grassi Rocha    ³ Data ³ 22/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processo de Selecao interna (Funcionarios)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Avoid                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RSPM002                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS   ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³06/08/14³TQENRX  ³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³        ³da a limpeza.                             ³±±
±±³Everson SP  |04/12/14|TRCXBV  |Criada nova chave no SXE e SXF para gerar ³±± 
±±³            |        |        |a numeração sequencial da tabela de curri-³±±
±±³            |        |        |culos corretamente.                       ³±±
±±³Mariana M.  |04/05/15|TSAZ26  |Efetuado ajuste na rotina de Admissao para³±±
±±³            |        |        |quando for um processo interno.			³±±
±±³Gabriel A.  |20/07/16|TVGOD3  |Ajuste na leitura do arquivo RSPDEPA2.TXT ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function RSPM002()
Local aSays	   		:= {}
Local aButtons		:= {}
Local nOpca 		:= 0   
Local cFunction		:= "RSPM002"
Local bProcess	  	:= {|oSelf| RSP002Proc(oSelf)}
Local cDescription	:=	OemToAnsi(STR0002) +" "+;	//"Este programa tem como objetivo selecionar funcionarios"
						OemToAnsi(STR0003) +" "+;	// "de acordo com parametros e traze-los para o Cadastro de"
						OemToAnsi(STR0004)  		// "Curriculos para participarem de Processo de Selecao."
Local cPerg         := "RSP002"   

Private cCadastro  	:= OemToAnsi(STR0001)		//"Processo de Selecao Interna"
Private nSavRec		:= 0 

Private aFldRot 	:= {'RA_NOME', 'RA_CIC', 'RA_RG'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private lOfuscaCPF 	:= .F. 
Private lOfuscaRG 	:= .F. 
Private aFldOfusca 	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_CIC" } ) > 0
		lOfuscaCPF := FwProtectedDataUtil():IsFieldInList( "RA_CIC" )
	ENDIF
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_RG" } ) > 0
		lOfuscaRG := FwProtectedDataUtil():IsFieldInList( "RA_RG" )
	ENDIF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("RSP002",.F.)
tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg)        

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RSP002Proc³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 22/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento de Selecao Interna.				          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSP002PROC()		                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPM002		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rsp002Proc(oSelf)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando as Perguntas 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFilDe		:= mv_par01		// Filial De
Local cFilAte 		:= mv_par02		// Filial Ate
Local cMatDe 		:= mv_par03		// Matricula De
Local cMatAte		:= mv_par04		// Matricula Ate
Local dNascDe		:= mv_par05		// Nascimento De
Local dNascAte		:= mv_par06		// Nascimento Ate
Local cEstCiv		:= mv_par07		// Est. Civil
Local cSexo  		:= mv_par08		// Sexo
Local cCcDe			:= mv_par09		// Centro de Custo De
Local cCcAte		:= mv_par10		// Centro de Custo Ate
Local cFunDe    	:= mv_par11 	// Funcao De
Local cFunAte   	:= mv_par12 	// Funcao Ate
Local nSalDe		:= mv_par13		// Salario De
Local nSalAte		:= mv_par14		// Salario Ate
Local cGrupoDe		:= mv_par15		// Grupo De
Local cGrupoAte		:= mv_par16		// Grupo Ate
Local cFatAvalDe	:= mv_par17		// Fator Avaliacao De
Local cFatAvalAte	:= mv_par18		// Fator Avaliacao Ate
Local cGraFatDe		:= mv_par19		// Graduacao Fator De
Local cGraFatAte	:= mv_par20		// Graduacao Fator Ate
Local dAdmisDe   	:= mv_par21		// Data de Admissao De
Local dAdmisAte   	:= mv_par22		// Data de Admissao Ate

Local cCargo		:= ""
Local cAliasQry 	:= GetNextAlias()     
Local nTam			:= 0

// Variaveis utilizadas no RSPDEPA2.TXT
Private cCurric		:= Space(06)
Private cGrupo		:= Space(02)
Private cDEntid		:= Space(30)

Private aLog	:= {}
Private aTitle	:= {}
Private cLog	:= ""
Private lFirst	:= .T.

//Quantidade de registros para a primeira regua
BeginSql Alias cAliasQry 
	SELECT  COUNT(SRA.RA_MAT) AS Total
	FROM %table:SRA% SRA
	WHERE 
	SRA.RA_FILIAL <= %exp:cFilAte%
EndSql	
nTam:= (cAliasQry)->Total 
(cAliasQry)->(DbCloseArea())	                          
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua Processamento	                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SRA")
dbSetOrder(1)

cFilDe := Iif( FWModeAccess("SRA") == "C", xFilial("SRA"), cFilDe)
//cFilDe := Iif( xFilial("SRA") == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), cFilDe)
dbSeek(cFilDe+cMatDe,.T.)
 
oSelf:setRegua1(nTam) 
oSelf:SaveLog(STR0001 + " - " + STR0017)	//"Inicio do Processamento"

While ! Eof() .And. SRA->RA_FILIAL <= cFilAte
                                                                      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Move Regua Processamento	                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
   	oSelf:IncRegua1(STR0005) //"Selecionando Funcionarios"    
	oSelf:setRegua2(1)  
	if lOfuscaNom
   		oSelf:IncRegua2(STR0015+" / "+STR0019+" "+SRA->RA_FILIAL+ "/" +SRA->RA_MAT)
	else
		oSelf:IncRegua2(STR0015+" / "+STR0016+": "+SRA->RA_FILIAL+ If(lOfuscaNom,''," / "+Left(SRA->RA_NOME,25)))
	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste os Parametros 										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SRA->RA_SITFOLH == "D" .Or.;
			SRA->RA_MAT 	< cMatDe	.Or. SRA->RA_MAT 		> cMatAte 	.Or.; 
			SRA->RA_NASC	< dNascDe	.Or. SRA->RA_NASC		> dNascAte	.Or.;
			SRA->RA_CC 		< cCcDe 	.Or. SRA->Ra_CC 		> cCCAte	.Or.;
			SRA->RA_CODFUNC	< cFunDe 	.Or. SRA->RA_CODFUNC 	> cFunAte 	.Or.;
			SRA->RA_SALARIO	< nSalDe	.Or. SRA->RA_SALARIO	> nSalAte	.Or.;
			SRA->RA_ADMISSA	< dAdmisDe	.Or. SRA->RA_ADMISSA	> dAdmisAte	.Or.; 			
			!(SRA->RA_SEXO $ cSexo) .Or.;
			!(SRA->RA_ESTCIVI $cEstCiv) 
						
		dbSelectArea("SRA")
		dbSkip()
		Loop
	Endif		
    
    cCargo := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)
               
	dbSelectArea("SQ3")
	dbSetOrder(1)
	cFil := Iif( FWModeAccess("SQ3") == "C", xFilial("SQ3"), SRA->RA_FILIAL )
//	cFil := If ( xFilial("SQ3") == Space(FWGETTAMFILIAL) , Space(FWGETTAMFILIAL),SRA->RA_FILIAL)
	dbSeek(cFil+cCargo)
			
	If SQ3->Q3_GRUPO < cGrupoDe .Or. SQ3->Q3_GRUPO > cGrupoAte
			
		dbSelectArea("SRA")
		dbSkip()
		Loop
	EndIf
	cGrupo	:= SQ3->Q3_GRUPO
			
	dbSelectArea("SQ8")
	dbSetOrder(1) 
	cFil := Iif( FWModeAccess("SQ8") == "C", xFilial("SQ8"), SRA->RA_FILIAL )
//	cFil:= If ( xFilial("SQ8") == Space(FWGETTAMFILIAL) , Space(FWGETTAMFILIAL),SRA->RA_FILIAL)
	lOk	:= .F.
	If dbSeek(cFil+SRA->RA_MAT)
	
		While !Eof() .And. (SQ8->Q8_FILIAL+SQ8->Q8_MAT) == (cFil+SRA->RA_MAT)
	
			If 	SQ8->Q8_FATOR >= cFatAvalDe	.And. SQ8->Q8_FATOR <= cFatAvalAte .And.; 
				SQ8->Q8_GRAU  >= cGraFatDe		.And. SQ8->Q8_GRAU	 <= cGraFatAte
				lOk := .T.              
				Exit
			EndIf
			dbSkip()
		EndDo
	Else
		If Empty(cFatAvalDe) .And. Empty(cGraFatDe)
			lOk := .T.
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Funcionario no Cadastro de Curriculo. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ               
	If lOk
		Rs002Cnv()
	EndIf 
	
	dbSelectArea("SRA")
	dbSkip()
EndDo                          

oSelf:SaveLog(STR0001 + " - " + STR0018)	//"Término do Processamento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama rotina de Log de Ocorrencias. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fMakeLog(aLog,aTitle,"RSP002")

dbSelectArea("SRA")
dbSetOrder(1)
dbGoTop()

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Rs002Cnv  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Transforma Funcionarios em Candidatos.				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rs002Cnv(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = N£mero do registro                                 ³±±
±±³          ³ ExpN2 = N£mero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSPM002                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs002Cnv()

//-- Formato Padr„o do Arquivo TXT
//-- 111111111122222222223333333333444444444455555555556666666666
//-- 123456789012345678901234567890123456789012345678901234567890
//-- Ex.:
//-- <DEDEDEDEDEDEDEDEDEDEDEDEDEDE><PARAPARAPARAPARAPARAPARAPARA>
//-- Onde as 30 primeiras posi‡”es s„o destinadas ao preenchimento do Campo
//-- ( no formato ALIAS->NOME_DO_CAMPO - Ex.: SRA->RA_NOME ) ou Sintax Clipper
//-- ( Ex.: MsDate() ou dDataBase ) e as 30 posi‡”es seguintes s„o destinadas ao
//-- preenchimento do campo de Destino no arquivo SQG ( no formato j  citado ),
//-- mas com Alias referenciando uma vari vel de mem¢ria ( M-> ).

Local cString	:= ''
Local cArquivo  := ''
Local nBytes    := 0
Local nStrSize  := 0
Local nFileSize := 0
Local nHandle   := 0
Local aSaveArea	:= GetArea()
Local lOutros	:= .F.
Local lFound	:= .F.
Local cFil		:= "" 

Private cMat 		:= SRA->RA_MAT
Private aDePara    	:= {}
Private aDePara2   	:= {}

// Se o programa for chamado pela Agenda (RSPA150) a Variavel ja estah definida.
If Type("aFuncs") == "U"
	aFuncs := {}
EndIf

//-- Define o arquivo TXT a ser utilizado
cArquivo := "RSPDEPA2.TXT"

If !File(cArquivo)
	Aviso(STR0007,STR0014,{"Ok"})	//"Atencao"###"Arquivo RSPDEPA2.TXT nao encontrado."
	
ElseIf ( nHandle := FT_FUse(cArquivo) ) >= 0
	
	cString  := ''
	
	FT_FGoTop()
	
	While !( FT_FEof() )
		
		cString  := FT_FReadLn()	
		
		If Empty(cString)
			FT_FSkip()
			loop
		EndIf
			
		If Left(cString,1) == "<"
			lOutros := .T.
			FT_FSkip()
			Loop
		EndIf
			
		If lOutros
			aAdd(aDePara2, { AllTrim(Left(cString, 30)), AllTrim(Subs(cString, 31))} )
		Else
			If Len(cString) >= 31 
				aAdd(aDePara, { AllTrim(Left(cString, 30)), AllTrim(Subs(cString, 31))} )
			EndIf	
		EndIf
			
		FT_FSkip()
		
	EndDo
		
	
	If fClose(nHandle)   
	
		lFound 	:= .F.          
		cFil := Iif( FWModeAccess("SQG") == "C", xFilial("SQG"), SRA->RA_FILIAL )
//		cFil 	:= Iif(xFilial("SQG") == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), SRA->RA_FILIAL)		
		
		// Verifica RG  
		If !Empty(SRA->RA_RG) 
			dbSelectArea("SQG")
			dbSetOrder(2)
			If dbSeek(cFil+SRA->RA_RG) 
						
				//---- Log ocorrencias
		    	If lFirst
					cLog := STR0009 	//"Funcionario ja Cadastro no Cadastro de Curriculo"	
					Aadd(aTitle,cLog)  
					Aadd(aLog,{})
					lFirst := .F.
				Endif                                               
						
				cLog :=	STR0013+SQG->QG_CURRIC //"Curriculo: "
				if !lOfuscaNom
					cLog += " - " + STR0010 + SRA->RA_NOME	//"Funcionario: "
				ENDIF
				if !lofuscaRG
					cLog += " - " +	STR0011 + SRA->RA_RG	//"R.G.: "
				ENDIF
				if !lOfuscaCPF
					cLog += " - " + STR0012 + SRA->RA_CIC	//"C.P.F.: "		
				ENDIF

				Aadd(aLog[1],cLog)  
				//----
						
				lFound := .T. 
			EndIf
		EndIf			
                         
		// Verifica CPF
		If !Empty(SRA->RA_CIC) .And. !lFound
			dbSelectArea("SQG")		
			dbSetOrder(3)
			If dbSeek(cFil+SRA->RA_CIC)

				//---- Log ocorrencias
		    	If lFirst
					cLog := STR0009 	//"Funcionario ja Cadastro no Cadastro de Curriculo"	
					Aadd(aTitle,cLog)  
					Aadd(aLog,{})
					lFirst := .F.
				Endif                                               
						
				cLog :=	STR0013+SQG->QG_CURRIC //"Curriculo: "
				if !lOfuscaNom
					cLog += " - " + STR0010 + SRA->RA_NOME	//"Funcionario: "
				ENDIF
				if !lofuscaRG
					cLog += " - " +	STR0011 + SRA->RA_RG	//"R.G.: "
				ENDIF
				if !lOfuscaCPF
					cLog += " - " + STR0012 + SRA->RA_CIC	//"C.P.F.: "		
				ENDIF

				Aadd(aLog[1],cLog)  
				//----		       	
				
				lFound := .T.
		    EndIf
		EndIf
		      
		// Verifica Nome
		If !Empty(SRA->RA_NOME) .And. !lFound
			dbSelectArea("SQG")
			dbSetOrder(5)
			If dbSeek(cfil+SRA->RA_NOME)
			
				//---- Log ocorrencias
		    	If lFirst
					cLog := STR0009 	//"Funcionario ja Cadastro no Cadastro de Curriculo"	
					Aadd(aTitle,cLog)  
					Aadd(aLog,{})
					lFirst := .F.
				Endif                                               
						
				cLog :=	STR0013+SQG->QG_CURRIC //"Curriculo: "
				if !lOfuscaNom
					cLog += " - " + STR0010 + SRA->RA_NOME	//"Funcionario: "
				ENDIF
				if !lofuscaRG
					cLog += " - " +	STR0011 + SRA->RA_RG	//"R.G.: "
				ENDIF
				if !lOfuscaCPF
					cLog += " - " + STR0012 + SRA->RA_CIC	//"C.P.F.: "		
				ENDIF
							
				Aadd(aLog[1],cLog)  
				//----
				
				lFound := .T.
			EndIf
		EndIf
       
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Importacao de Dados de Funcionario para Curriculo. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SQG")
		dbSetOrder(1)
		
		If !lFound
			cCurric := Space(06)
			
			fRsM002DP1()	// Grava Funcionarios no Arquivo de Curriculos
	
			fRsM002DP2()	// Carrega variaveis de outros arquivos
		Else
			cCurric := SQG->QG_CURRIC
			If Empty(SQG->QG_MAT)
				If RECLOCK('SQG', .F.)
					SQG->QG_MAT := cMat
					Replace SQG->QG_SITUAC With 'FUN'
					MSUNLOCK()     // Destrava o registro
				EndIf
			EndIf			
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Guarda Codigo de Curriculos para Agenda de Candidatos. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If !Empty(cCurric)
			Aadd(aFuncs,{cCurric,if(lOfuscaNom, '', SRA->RA_NOME)})
		EndIf			
	Else
		Aviso(STR0007,STR0008,{"Ok"})	//"Atencao"#"Erro de Leitura no Arquivo RSPDEPA2.TXT"
	EndIf		                    
EndIf

RestArea(aSaveArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM002DP1³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche  Variaveis com Informa‡”es do Func.  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM002DP1                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs002Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRSM002DP1

Local nX 	:= 0
Local cFil	:= ""
Local nIni	:= 0
Local cCampo:= ""
Local cRetSqlName
cRetSqlName := RetSqlName( "SQG" )+"\3"

dbSelectArea("SQG")
dbSetOrder(1)    
// Gravar codigo do curriculo 
RecLock("SQG", .T.)                                            

	cCurric	:= GetSx8Num("SQG","QG_CURRIC",xFilial('SQG')+cRetSqlName)    //Private
	
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao de Campos obrigatorios. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SQG->QG_CURRIC 	:= cCurric 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao de Outros Campos.		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	      
	For nX := 1 to Len(aDePara)
		If "FILIAL" $ (aDePara[nX, 2])
			cFil := Iif( FWModeAccess("SQG") == "C", xFilial("SQG"), SRA->RA_FILIAL )
//			cFil := Iif(xFilial("SQG") == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), SRA->RA_FILIAL)
			&(aDePara[nX, 2]) := cFil
		Else  
			nIni	:= at(">",aDePara[nX, 2]) 		  
			cCampo 	:= subs(aDePara[nX, 2], nIni+1, Len(aDePara[nX, 2]) - nIni)
			If FieldPos(cCampo)  > 0
				&(aDePara[nX, 2]) := &(aDePara[nX, 1])	
			EndIf
		EndIf
	Next nx 

MsUnlock()          

If __lSX8
	ConfirmSX8()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM002DP2³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche  Variaveis com Informa‡”es do Func. (Outros Arq.) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM002DP2                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs002Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRSM002DP2

Local nX 		:= 0
Local cAliasAnt := cAliasAtu := cAliasDe := Space(03)
Local aTmp		:= {}
                                            
For nX := 1 to Len(aDePara2)	  
	cAliasAtu := Left(aDePara2[nX, 2],3) 
	If cAliasAnt != cAliasAtu    
		If Len(aTmp) > 0
	
			fRSM002Grv(aTmp,cAliasDe,cAliasAnt) // Gravacao
	
			aTmp := {}
		EndIf
		cAliasDe  := Left(aDePara2[nX, 1],3) 
		cAliasAnt := cAliasAtu
	EndIf          
	If !Empty(cAliasAnt)  
		dbSelectArea(cAliasAnt)
		If FieldPos(Subs(aDePara2[nX, 2],6,Len(aDepara2[nx, 2]))) != 0
			Aadd(aTmp,aDePara2[nx])
	    EndIf
	EndIf
Next nX      

If Len(aTmp) > 0
	fRSM002Grv(aTmp,cAliasDe,cAliasAnt) // Gravacao
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRSM002Grv³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava dados dos funcionarios referente outros arquivos .   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fRsM002Grv                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Rs002Cnv                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fRSM002Grv(aTmp,cAliasDe,cAliasPara)
       
Local nx		:= 0
Local cAliasMat := Iif(Left(cAliasDe,1) == "S", Subst(cAliasDe,2,2), Left(cAliasDe,3) )
Local cCampoMat := cAliasMat+"_MAT"
Local cFil		:= ""
Local nIni		:= 0  
Local cCampo	:= ""
Local cCargo	:= ""

cCargo := fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)                          

// Posiciona no Cargo do Funcionario
dbSelectArea("SQ3")
dbSetOrder(1)      
cFil := Iif( FWModeAccess("SQ3") == "C", xFilial("SQ3"), SRA->RA_FILIAL )
//cFil := Iif(xFilial("SQ3") == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), SRA->RA_FILIAL)
dbSeek(cFil+cCargo)

dbSelectArea(cAliasDe)
dbSetOrder(1) 
cFil := Iif( FWModeAccess(cAliasDe) == "C", xFilial(cAliasDe), SRA->RA_FILIAL )
//cFil := Iif(xFilial(cAliasDe) == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), SRA->RA_FILIAL)
dbSeek(cFil+cMat)
While !Eof() .And. cMat == &cCampoMat
                     
    If cAliasDe == "RA4"             
		
    	dbSelectArea("RA0")
		cFil := Iif( FWModeAccess("RA0") == "C", xFilial("RA0"), SRA->RA_FILIAL )
	    //cFil := Iif(xFilial("RA0") == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), SRA->RA_FILIAL)
    	If dbSeek(cFil+RA4->RA4_ENTIDA)
	    	cDEntid := RA0->RA0_DESC
	    Else
		    cDEntid	:= Space(30)
	    EndIf 
    EndIf
    
	dbSelectArea(cAliasPara)
	dbSetOrder(1)
	RecLock(cAliasPara, .T.)
	For nx := 1 to Len(aTmp)
		If "FILIAL" $ (aTmp[nX, 2])
			cFil := Iif( FWModeAccess(cAliasPara) == "C", xFilial(cAliasPara), SRA->RA_FILIAL )
			//cFil := Iif(xFilial(cAliasPara) == Space(FWGETTAMFILIAL), Space(FWGETTAMFILIAL), SRA->RA_FILIAL)
			&(aTmp[nX, 2]) := cFil
		Else
			nIni	:= at(">",aTmp[nX, 2]) 		  
			cCampo 	:= subs(aTmp[nX, 2], nIni+1, Len(aTmp[nX, 2]) - nIni)
			If FieldPos(cCampo)  > 0
				&(aTmp[nX, 2]) := &(aTmp[nX, 1])	
			EndIf
		EndIf
	Next nx 
	MsUnlock()
	
	dbSelectArea(cAliasDe)	
	dbSkip()
EndDo
Return Nil
