#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER910.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    � 			� Autor � R.H.      				 � Data �          ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Formulario 931                                                  ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                 ���
������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                 ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                        ���
������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                  ���
������������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS           �  Motivo da Alteracao                ���
������������������������������������������������������������������������������Ĵ��
���Tiago Malta �19/08/11�00000020963/2011�Retirado fun��o que cria as perguntas���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function GpeR910()

/*
��������������������������������������������������������������Ŀ
� Define Variaveis Locais (Basicas)                            �
����������������������������������������������������������������*/
Local cDesc1 		:= STR0001		//"Formulario 931"
Local cDesc2 		:= STR0002		//"Ser� impresso de acordo com os parametros solicitados pelo usuario."
Local cString		:= "SRA"        // alias do arquivo principal (Base)
Local cMesAnoRef	:= ""
Local cMes			:= ""
Local cAno			:= ""
Local aPerAberto	:= {}
Local aPerFechado	:= {}
Local cNumPg		:= Space(2)

/*
��������������������������������������������������������������Ŀ
� Define Variaveis Private(Basicas)                            �
����������������������������������������������������������������*/
Private nomeprog	:= "GpeR910"
Private aReturn 	:= { STR0004, 1,STR0005, 2, 2, 1,"",1 }	//##"Zebrado"###"Administra��o"
Private aLinha  	:= {}
Private nLastKey 	:= 0
Private cPerg   	:= "GPER910"

/*
��������������������������������������������������������������Ŀ
� Variaveis Utilizadas na funcao IMPR                          �
����������������������������������������������������������������*/
Private Titulo	:= STR0006 //"IMPRESS�O DO FORMULARIO 931"
Private CONTFL  := 1
Private LI      := 0
Private wCabec0 := 1
Private wCabec1 := ""
Private wCabec2 := ""
Private cCabec
Private cTipCC
Private	cRefOco
Private nTamanho:= "M"
Private nOrdem
Private aInfo   := {}

Private cProcesso	:= "" // Armazena o processo selecionado na Pergunte GPER040 (mv_par01).
Private cRoteiro	:= "" // Armazena o Roteiro selecionado na Pergunte GPER040 (mv_par02).
Private cPeriodo	:= "" // Armazena o Periodo selecionado na Pergunte GPER040 (mv_par03).
Private Semana		:= "" // Armazena a Semana selecionado na Pergunte GPER040 (mv_par04).
Private cDescRel	:= "" // Armazena a descricao do Roteiro selecionado (funcao Gpr040Roteiro).
Private cCond		:= ""
Private cRot		:= ""              
Private lRotEmpty	:= .T. // Variavel utilizada na visuzaliza��o de roteiros em branco na consulta padrao
Private dDtPerIni	:= Ctod("  /  /  ")
Private dDtPerFim	:= Ctod("  /  /  ")
Private dDtPago		:= Ctod("  /  /  ")

//--Seta e Carrega os Mnemonicos.
SetMnemonicos(NIL,NIL,.T.)

/*
��������������������������������������������������������������Ŀ
� Verifica as perguntas selecionadas                           �
����������������������������������������������������������������*/
pergunte("GPER910",.F.)

/*
��������������������������������������������������������������Ŀ
� Envia controle para a funcao SETPRINT                        �
����������������������������������������������������������������*/
wnrel:="GPER910"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,"",.F.,,,nTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

/*
��������������������������������������������������������������Ŀ
� Variaveis utilizadas para parametros                         �
� mv_par01        //  Processo						           �
� mv_par02        //  Roteiro							       �
� mv_par03        //  Periodo                                  �
� mv_par04        //  Numero de Pagamento                      �
� mv_par05        //  Filial  De                               �
� mv_par06        //  Filial  Ate                              �
� mv_par07        //  Matricula De                             �
� mv_par08        //  Matricula Ate                            �
� mv_par09        //  Situacao                                 �
� mv_par10        //  Categoria                                �
����������������������������������������������������������������
��������������������������������������������������������������Ŀ
� Carregando variaveis mv_par?? para Variaveis do Sistema.     �
����������������������������������������������������������������*/
//nOrdem   := aReturn[8]

cProcesso 	:= mv_par01 // Processo selecionado na Pergunte.
cRoteiro   	:= mv_par02 // Roteiro selecionado na Pergunte.
cPeriodo 	:= mv_par03 // Periodo selecionado na Pergunte.
Semana   	:= mv_par04 // Numero de Pagamento selecionado na Pergunte.

/*
��������������������������������������������������������������Ŀ
� Carregar os periodos abertos (aPerAberto) e/ou os periodos   �
� fechados (aPerFechado), dependendo do periodo (ou intervalo  �
� de periodos) selecionado									   �
����������������������������������������������������������������*/
RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
				cRoteiro	,; // Roteiro selecionado na Pergunte.
				cPeriodo	,; // Periodo selecionado na Pergunte.
				Semana		,; // Numero de Pagamento selecionado na Pergunte.
				NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados
/*
�������������������������������������������������������������������Ŀ
� Retorna o mes e o ano do periodo selecionado na pergunte 			�
� para montagem do dDataref e Inicio e Fim de Periodo.				�
���������������������������������������������������������������������*/
cNumPg := If (Semana == "99" , Nil , Semana)
If (nPos:=aScan(aPerAberto, {|x| x[1] == cPeriodo .And. x[2] == cNumPg})) > 0
	cMes		:= aPerAberto[nPos,3]
	cAno		:= aPerAberto[nPos,4]		
	dDtPerIni   := aPerAberto[nPos,5]
	dDtPerFim   := aPerAberto[nPos,6]
	dDtPago		:= aPerAberto[nPos,7]
Elseif (nPos:=aScan(aPerFechado, {|x| x[1] == cPeriodo .And. x[2] == cNumPg})) > 0
	cMes		:= aPerFechado[nPos,3]
	cAno		:= aPerFechado[nPos,4]		
	dDtPerIni   := aPerFechado[nPos,5]
	dDtPerFim   := aPerFechado[nPos,6]
	dDtPago		:= aPerFechado[nPos,7]
Endif
//--Montagem do dDataRef sobre o Periodo
dDataRef := CTOD("01/" + cMes + "/" + cAno)

cFilDe   := mv_par05
cFilAte  := mv_par06
cMatDe   := mv_par07
cMatAte  := mv_par08
cSit     := mv_par09
cCat     := mv_par10
nTpContr := 3


/*
��������������������������������������������������������������Ŀ
�  Pega descricao da semana                                    �
����������������������������������������������������������������*/
dbSelectArea("SRA")

/*
��������������������������������������������������������������Ŀ
� Retorna a descricao do Roteiro. Utilizado no Titulo.	       �
����������������������������������������������������������������*/
Gpr040Roteiro()
Titulo := STR0001 //"FORMULARIO 931"

cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)

RptStatus({|lEnd| GPR910Imp(@lEnd,wnRel,cString,cMesAnoRef,nTpContr,.F., aPerAberto, aPerFechado)},Capital(Titulo))
                                                                                      
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPR910Imp� Autor � R.H.                  � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GPR040Imp(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A�ao do Codelock                             ���
���          � wnRel       - T�tulo do relat�rio                          ���
���          � cString     - Mensagem                                     ���
���          � lGeraLanc   - Indica se deve gerar o INSS (SRZ)            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
���          �                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function GPR910Imp(lEnd,WnRel,cString,cMesAnoRef,nTpContr,lGeraLanc,aPerAberto,aPerFechado)

Local lAs400	:= ( TcSrvType() == "AS/400" )		//-- Retiramos a execucao da query para servidores AS/400.

/*
��������������������������������������������������������������Ŀ
� Define Variaveis Private			                           �
����������������������������������������������������������������*/
Private cCcto	  := ""
Private cIRefSem  := GetMv("MV_IREFSEM",,"S")
Private nDed      := 0.00   	// Deducoes Inss
Private	cTpC      := ""
Private	cTpC1     := ""
Private aInssEmp[24][2]
Private aEmp	  := {}  		// Empresa

Private aCodFol   := {}
Private aDifLiq	  := {}
Private cPDLiq	  := fGetCodFol("0047")

Private cAnoMesRef    := Right(cMesAnoRef,4) + Left(cMesAnoRef,2)

/*
��������������������������������������������������������������Ŀ
| Verifica se deve gerar lancamentos ou imprimir folha.        |
����������������������������������������������������������������*/
Private lGeraSRZ := .F.

Private lFolComp := .F.	// Variavel para informar que o tratamento devera ser por Competencia

/*
��������������������������������������������������������������Ŀ
| Identifica se e geracao da GPS							   |
����������������������������������������������������������������*/
Private lGPS := .F.

/*
��������������������������������������������������������������Ŀ
� Imprime Resumo                                               �
����������������������������������������������������������������*/
If nTpContr == 1 .Or. nTpContr == 3
	cTpC  := "1"
	#IFDEF TOP 
		cTpC1 := "(' ','*','1')"
		fImpGer910(lEnd, cAnoMesRef, aPerAberto, aPerFechado)
	#ELSE
		cTpC1 := " *1"
		fImpGer910(lEnd, cAnoMesRef, aPerAberto, aPerFechado)
	#ENDIF
EndIf

/*
��������������������������������������������������������������Ŀ
� Imprime folha ou gera SRZ para tipo de contrato DETERMINADO  �
����������������������������������������������������������������*/
If nTpContr == 2 .Or. nTpContr == 3
	cTpC  := "2"
	#IFDEF TOP 
		cTpC1 := "('2')"
	#ELSE
		cTpC1 := "2"
	#ENDIF
	If !lGeraSRZ .Or. lAs400 // Nao Esta em Top
		fImpGer910(lEnd, cAnoMesRef, aPerAberto, aPerFechado)
	EndIf
EndIf

/*
��������������������������������������������������������������Ŀ
� Retorna ordem 1 dos arquivos processados                     �
����������������������������������������������������������������*/
dbSelectArea("SRC")
dbSetOrder(1)

dbSelectArea("SRA")
DbClearFilter()
dbSetOrder(1)

/*
��������������������������������������������������������������Ŀ
� Termino do relatorio                                         �
����������������������������������������������������������������*/

//--Gerar Rodape no final da Impressao
Li := 58
Impr("","F")
Set Device To Screen
If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)         
Endif
MS_FLUSH()

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fImpGer910� Autor � R.H.                  � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � 	fImpGer910(lEnd,cAnoMesRef)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function fImpGer910(lEnd,cAnoMesRef,aPerAberto,aPerFechado)

Local aFunP       	:= {}
Local aFunD   	 	:= {}
Local aFunB   	  	:= {}
Local aVerbasFunc	:= {}

Local cChave 		:= ""
Local cMatricula	:= ""
Local cAcessaSRC  	:= &("{ || " + ChkRH("GPER910","SRC","2") + "}")
Local cTipAfas    	:= " "

Local lInssFun    	:= .F.
Local lCotFun	   	:= .F.
Local lAs400		:= ( TcSrvType() == "AS/400" )		//-- Retiramos a execucao da query para servidores AS/400.

Local nX
Local nReg
Local nTotRegPrc	:= 0
Local nRegMov		:= 0
Local nCol1
Local nCol2
Local nCol3

#IFDEF TOP
	Local aSRAFilter	:= {}
	Local aFields		:= {}
	
	Local cCateg		:= ""
	Local cSRAQuery
	Local cSvSRAQuery
#ENDIF

Private cAcessaSRA  := &("{ || " + ChkRH("GPER910","SRA","2") + "}")
Private cAliasMov  	:= "SRA"
Private cArq1		:= ""
Private aVerbasLIQ  := {}  
Private aVerbasAG1	:= {}
Private aVerbasAG2	:= {}
Private aVerbasFER 	:= {}
Private aVerbasRES 	:= {}

Private nTotRI		:= 0
Private nRI1		:= 0
Private nRI2		:= 0
Private nRI3		:= 0
Private nRI4		:= 0
Private nRI5		:= 0
Private nRI6		:= 0
Private nRI7		:= 0
Private nRI8		:= 0
Private nRI9		:= 0
Private nAdic		:= 0
Private nAAFF		:= 0
Private nVolunt		:= 0
Private nApDif		:= 0
Private nRegEsp		:= 0
Private nExOs		:= 0
Private nAssFam		:= 0


Begin Sequence

	dbSelectArea( "SRA" )
	dbGoTop()

	cChave := cFilDe + cMatDe
	dbSetOrder( 1 )
	dbSeek(cChave,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim     := cFilAte + cMatAte

	#IFDEF TOP 
		If !lAS400
			/*
			��������������������������������������������������������������Ŀ
			� Gerar Filtro para o SRA. Fechar o arquivo p. abrir como Query�
			����������������������������������������������������������������*/
			aFields	:= SRA->(DbStruct())
	
			If Empty( aSRAFilter )
	
				/*
				��������������������������������������������������������������Ŀ
	 			� Gerar categoria e Situacao para incluir no Select            �
				����������������������������������������������������������������*/
				cCateg := "("
				For nX := 1 To Len( cCat )
					cCateg += "'" + Substr( cCat, nX, 1) + "',"
				Next nX
				cCateg 	:= Substr( cCateg, 1, Len(cCateg)-1) + ")"
	
				aAdd( aSRAFilter, { "RA_FILIAL"		, ">="	, cFilDe	, cFilDe 	} )
				aAdd( aSRAFilter, { "RA_FILIAL"		, "<="	, cFilAte	, cFilAte 	} )
				aAdd( aSRAFilter, { "RA_MAT"		, ">="	, cMatDe	, cMatDe 	} )
				aAdd( aSRAFilter, { "RA_MAT"		, "<="	, cMatAte	, cMatAte 	} )
				aAdd( aSRAFilter, { "RA_CATFUNC"	, "IN"	, cCateg	, cCateg	} )
				aAdd( aSRAFilter, { "RA_TPCONTR"	, "IN"	, cTpC1		, cTpC1} )
				
				// Folha por Competencia - Resumo atraves do programa Gper670
				aAdd( aSRAFilter, { "RA_PROCES"		, "="	, cProcesso	, cProcesso } )
			EndIf           
			If !CreateQry( 	aFields		 ,;			// Array com os campos para a Query
							@aSRAFilter	 ,;			// Filtro para query
							"SRA"		 ,;			// Alias da Query
							@cSRAQuery	 ,;			// String com a Query Montada
							@cSvSRAQuery ,;			// Copia da Query
							"SRA"		 ,;			// Nome da Query a Retornar
							.T.			 ,;			// Contar o Numero de Registros Processados
							@nTotRegPrc	 ,;			// Total de Registros retornados da CreateQry
							aReturn[7]	 ,;         // caso esteja preenchido aReturn[7] -> mediante filtro do setprint		
						 )
				SRA->( DbSeek( cChave, .T.) )
			EndIf
		Else
			nTotRegPrc := SRA->( Reccount() )
		EndIf
	#ELSE
		nTotRegPrc := SRA->( Reccount() )
	#ENDIF

	/*
	��������������������������������������������������������������Ŀ
	� Variaveis para Controle de Quebras de Paginas.			   �
	����������������������������������������������������������������*/
	cFilAnterior := Space(02)
	
	/*
	��������������������������������������������������������������Ŀ
	� Variaveis de Totalizacao                      			   �
	����������������������������������������������������������������*/
	nEafa := 0  	// Totalizadores Empresa
	/*
	��������������������������������������������������������������Ŀ
	� Estas variaveis nao devem, se declaradas, pois devem ser     �
	� declaradas na funcao chamadora.(pode ser externa).           �
	����������������������������������������������������������������*/

	SetRegua(nTotRegPrc)
                                               
	While (cAliasMov)->( !Eof() .And. &cInicio <= cFim )
	
		/*
		��������������������������������������������������������������Ŀ
		� Movimenta Regua de Processamento                             �
		����������������������������������������������������������������*/
		IncRegua()

		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
		EndIf

		cCcto := SRA->RA_CC
		
		/*
		��������������������������������������������������������������Ŀ
		� Verifica Quebra de Filial                                    �
		����������������������������������������������������������������*/
		If SRA->RA_FILIAL # cFilAnterior
	
			If !Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or. !fInfo(@aInfo,Sra->ra_Filial)
				Exit
			EndIf
	
			cFilAnterior := SRA->RA_FILIAL
			
		EndIf
		
		/*
		��������������������������������������������������������������Ŀ
		� Consiste Parametrizacao do Intervalo de Impressao            �
		����������������������������������������������������������������*/
		If ( SRA->RA_MAT < cMatDe )   .Or. ( SRA->RA_MAT > cMatAte )
			fTestaTotal()
			Loop
		EndIf
		
		/*
		�������������������������������������������������������������Ŀ
		� Retorna a situa��o do funcioanrio no periodo  a ser listado �
		���������������������������������������������������������������*/
		dbSelectArea("SRA")
		fSitFunc(SRA->RA_FILIAL,SRA->RA_MAT,dDtPerIni,dDtPerFim,@cTipAfas)

		/*
		������������������������������������������������������������������Ŀ
		� Verifica Situacao e Categoria do Funcionario conforme pergunte   �
		��������������������������������������������������������������������*/
		If	!(cTipAfas $ cSit) .Or. !(SRA->RA_CATFUNC $ cCat) .Or. !(SRA->RA_TPCONTR$ cTpC1 )
			fTestaTotal()
			Loop
		Endif

		/*
		��������������������������������������������������������������Ŀ
		� Consiste controle de acessos e filiais validas			   |
		����������������������������������������������������������������*/
		If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			fTestaTotal()
			Loop
		EndIf
                    

		//Retorna as verbas do funcionario, de acordo com os periodos selecionados
		
		aVerbasLIQ	:= RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, ,fGetCalcRot("1"), , aPerAberto, aPerFechado )  
		
		If Empty(aVerbasLIQ)
			fTestaTotal()
			Loop
		EndIf

		aVerbasAG1 := RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, ,fGetCalcRot("5"), , aPerAberto, aPerFechado )  
		aVerbasAG2 := RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, ,fGetCalcRot("6"), , aPerAberto, aPerFechado )
		aVerbasFER := RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, ,fGetCalcRot("3"), , aPerAberto, aPerFechado )
		aVerbasRES := RetornaVerbasFunc(SRA->RA_FILIAL, SRA->RA_MAT, ,fGetCalcRot("4"), , aPerAberto, aPerFechado )  

		lInssFun 	:= .F.
		lCotFun 	:= .F.
	
//		nRI1	+= RemuneImp("1")     SE comenta funcion RemuneImp y fOAdiconais no compiladas en el RPO
//		nRI2	+= RemuneImp("2")
//		nRI3	+= RemuneImp("3")
//		nRI4	+= RemuneImp("4")
//		nRI5	+= RemuneImp("5")
//		nRI6	+= RemuneImp("6")
//		nRI7	+= RemuneImp("7")
//		nRI8	+= RemuneImp("8")
//		nRI9	+= RemuneImp("9")


//		nAdic	+= fOAdiconais("ADC") 		//Adicionales
//      nExOs	+= fOAdiconais("IEO")		//Excedente Aportes

//		nAAFF	+= fOAdiconais(cAdicional)	//AAFF
//		nVolunt	+= fOAdiconais(cAdicional)	//Voluntarios
//		nRegEsp += fOAdiconais(cAdicional)	//Ap.Pers.Regimen Esp.
		
		For nReg := 1 to Len(aVerbasLIQ)
			If	!( aVerbasLIQ[nReg, 8] $ Semana ) .And. (!lFolComp .And. !( "99" $ Semana ) )	// Nao validar semana por competencia
				dbSkip()
				Loop
			EndIf
	
			If !Eval(cAcessaSRC)
				dbSkip()
				Loop
			EndIf
	
			fSoma(@aEmp,"C",NIL,NIL,aVerbasLIQ, nReg)
	
		Next nReg
		
		For nReg := 1 to Len(aVerbasAG1)
			If	!( aVerbasLIQ[nReg, 8] $ Semana ) .And. (!lFolComp .And. !( "99" $ Semana ) )	// Nao validar semana por competencia
				dbSkip()
				Loop
			EndIf
	
			If !Eval(cAcessaSRC)
				dbSkip()
				Loop
			EndIf
	
			fSoma(@aEmp,"C",NIL,NIL,aVerbasAG1, nReg)
	
		Next nReg
		For nReg := 1 to Len(aVerbasAG2)
			If	!( aVerbasLIQ[nReg, 8] $ Semana ) .And. (!lFolComp .And. !( "99" $ Semana ) )	// Nao validar semana por competencia
				dbSkip()
				Loop
			EndIf
	
			If !Eval(cAcessaSRC)
				dbSkip()
				Loop
			EndIf
	
			fSoma(@aEmp,"C",NIL,NIL,aVerbasAG2, nReg)
	
		Next nReg
		For nReg := 1 to Len(aVerbasFER)
			If	!( aVerbasLIQ[nReg, 8] $ Semana ) .And. (!lFolComp .And. !( "99" $ Semana ) )	// Nao validar semana por competencia
				dbSkip()
				Loop
			EndIf
	
			If !Eval(cAcessaSRC)
				dbSkip()
				Loop
			EndIf
	
			fSoma(@aEmp,"C",NIL,NIL,aVerbasFER, nReg)
	
		Next nReg
		For nReg := 1 to Len(aVerbasRES)
			If	!( aVerbasLIQ[nReg, 8] $ Semana ) .And. (!lFolComp .And. !( "99" $ Semana ) )	// Nao validar semana por competencia
				dbSkip()
				Loop
			EndIf
	
			If !Eval(cAcessaSRC)
				dbSkip()
				Loop
			EndIf
	
			fSoma(@aEmp,"C",NIL,NIL,aVerbasRES, nReg)
	
		Next nReg

		
		/*
		��������������������������������������������������������������Ŀ
		� Somatorias de Situacoes dos Funcionarios                     �
		����������������������������������������������������������������*/
		If SRA->RA_CC = cCcto
            
			If cTipAfas == "A"
				nEafa ++  //-- Total Afastados
			EndIf
		EndIf
		

		fTestaTotal()

	Enddo

End Sequence

If ( Select( "SRA" ) > 0 )
	SRA->( dbCloseArea() )
EndIf
DbSelectArea("SRA")

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fImprime     � Autor � Equipe de RH       � Data �          �
�����������������������������������������������������������������������Ĵ
�Descri��o � 						                                    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fImprime()										     		�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper040  												    �
�������������������������������������������������������������������������*/
Static Function fImprime()

Local nMaximo
Local nPos 		:= 0
Local nSIPAA	:= 0
Local nSIPAC	:= 0
Local nOSAp		:= 0
Local nOSCnt	:= 0
Local nAnssalA	:= 0
Local nAnssalC	:= 0
Local nINSSJPA	:= 0
Local nINSSJPC	:= 0
Local nFNE		:= 0
Local nArt		:= 0
Local nTotAp	:= 0
Local nTotCon	:= 0

Impr("","P")

/*
          1         2         3         4         5         6         7         8
01234567890123456789012345678901234567890123456789012345678901234567890123456789012    

Periodo:9999/99

Total Ley de Riesgo del Trabajo   Empleado    Suma RI 9      Suma ART    Suma Total
                                    999.99   999.999.99    999.999.99    999.999.99
-----------------------------------------------------------------------------------

Suma RI 1 999.999.99           Suma RI 2 999.999.99           Suma RI 3 999.999.99
Suma RI 4 999.999.99           Suma RI 5 999.999.99           Suma RI 6 999.999.99
Suma RI 7 999.999.99           Suma RI 8 999.999.99

-----------------------------------------------------------------------------------

Aportes Seguridade social                     Contribuiciones Seg. Social
                                                                       
SIPA                    999.999.99            SIPA                       999.999.99
INSSJP                  999.999.99            INSSJP    	             999.999.99
Adicionales             999.999.99            Asigs. Famil. compensadas  999.999.99
Aporte Diferencial      999.999.99            FNE                        999.999.99
ANSSAL                  999.999.99            ANSSAL                     999.999.99


Total Aportes SS      9.999.999.99            Total Contribuiciones    9.999.999.99
                                                          

Aportes Obra Social                           Contribuiciones Obra Social

Excedente Aportes       999.999.99            Contribuiciones OS         999.999.99
Aportes OS              999.999.99

                                              RENATRE                    999.999.99
							
							
Monto total a Pagar	  9.999.999.99						

*/

// SIPA - Aporte
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0064") })) >0
	nSIPAA:= aEmp[nPos,3]
	nTotAp+= aEmp[nPos,3]
EndIf	
// SIPA - Contribuicion
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0148") })) >0
	nSIPAC 	:= aEmp[nPos,3]
	nTotCon += aEmp[nPos,3]
EndIf	
// Obra Social - Aporte	
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0792")})) >0
	nOSAp	+= aEmp[nPos,3]
EndIf	

If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0798")})) >0
	nOSAp	+= aEmp[nPos,3]
EndIf	
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0810")})) >0
	nOSAp	+= aEmp[nPos,3]
EndIf
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("1062")})) >0
	nOSAp	+= aEmp[nPos,3]
EndIf

// Obra Social - Contribuicion
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0793")})) >0
	nOSCnt	:= aEmp[nPos,3]
EndIf	                                                      
	
// ANSSAL - Aporte
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0796")})) >0
	nAnssalA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                             

If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0800")})) >0
	nAnssalA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                             

If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0816")})) >0
	nAnssalA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                             

If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("1064")})) >0
	nAnssalA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                             

// ANSSAL - Contribuicion
If (nPos := Ascan( aEmp,{|x|x[1]==  fGetCodFol("0797")})) >0
	nAnssalC:= aEmp[nPos,3]
	nTotCon += aEmp[nPos,3]
EndIf	                                                      

// INSSJP - APORTE                                                   
If (nPos := Ascan( aEmp,{|x|x[1]==  fGetCodFol("0065")})) >0
	nINSSJPA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                      

If (nPos := Ascan( aEmp,{|x|x[1]==  fGetCodFol("0802")})) >0
	nINSSJPA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                      
If (nPos := Ascan( aEmp,{|x|x[1]==  fGetCodFol("0805")})) >0
	nINSSJPA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                      
If (nPos := Ascan( aEmp,{|x|x[1]==  fGetCodFol("0812")})) >0
	nINSSJPA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                      
If (nPos := Ascan( aEmp,{|x|x[1]==  fGetCodFol("1058")})) >0
	nINSSJPA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                      
If (nPos := Ascan( aEmp,{|x|x[1]==  fGetCodFol("1068")})) >0
	nINSSJPA+= aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                      


// INSSJP - Contribuicion
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0804")})) >0
	nINSSJPC+= aEmp[nPos,3]
	nTotCon += aEmp[nPos,3]
EndIf	                                                      
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("1059")})) >0
	nINSSJPC+= aEmp[nPos,3]
	nTotCon += aEmp[nPos,3]
EndIf	                                                      
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("1077")})) >0
	nINSSJPC+= aEmp[nPos,3]
	nTotCon += aEmp[nPos,3]
EndIf	                                                      
// FNE - Contribuicion	                                               
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("1036")})) >0
	nFNE := aEmp[nPos,3]
EndIf	                                                      

// Assig. Famil.Compensadas         
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("1039")})) >0
	nAssFam := aEmp[nPos,3]
EndIf
	                                                      
//Aporte Diferencial
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0601")})) >0
	nApDif := aEmp[nPos,3]
	nTotAp	+= aEmp[nPos,3]
EndIf	                                                      

//SUMA ART
If (nPos := Ascan( aEmp,{|x|x[1]== fGetCodFol("0807")})) >0
	nART := aEmp[nPos,3]
EndIf	                                                      
                         
nTotAp += nRegEsp+nAdic+nVolunt

nTotRI := nRI9+nART

                                                                    
/*
��������������������������������������������������������������Ŀ
� Montagem do cabecalho do funcionario                         �
����������������������������������������������������������������*/
DET:= STR0003+space(1)+ cPeriodo //##"Periodo: "
IMPR(DET,"C")

DET:=" "
IMPR(DET,"C")

DET:= "Total Ley de Riesgo del Trabajo   Empleado    Suma RI 9      Suma ART    Suma Total"
IMPR(DET,"C")

DET := Space(36)+Transform( nEafa ,'@E 999.99')+Space(03)+Transform(nRI9,'@E 999,999.99')+Space(04)+Transform(nART,'@E 999,999.99')+space(04)+Transform(nTotRI,'@E 999,999.99')
IMPR(DET,"C")

DET:=" "
IMPR(DET,"C")

DET := Replicate("-",84)
IMPR(DET,"C")

DET:=" "
IMPR(DET,"C")

DET := STR0007+space(01)+Transform(nRI1,'@E 999,999.99')+Space(12)+STR0008+SPACE(01)+Transform(nRI2,'@E 999,999.99')+Space(12)+STR0009+SPACE(01)+Transform(nRI3,'@E 999,999.99')//"Suma RI 1"##"Suma RI 2"##"Suma RI 3"
IMPR(DET,"C")

DET := STR0010+SPACE(01)+Transform(nRI4,'@E 999,999.99')+Space(12)+STR0011+SPACE(01)+Transform(nRI5,'@E 999,999.99')+Space(12)+STR0012+SPACE(01)+Transform(nRI6,'@E 999,999.99')//"Suma RI 4"##"Suma RI 5"##"Suma RI 6"
IMPR(DET,"C")

DET := STR0013+SPACE(01)+Transform(nRI7,'@E 999,999.99')+Space(12)+STR0014+SPACE(01)+Transform(nRI8,'@E 999,999.99')+Space(12)+STR0015+SPACE(01)+Transform(nRI9,'@E 999,999.99')//"Suma RI 7"##"Suma RI 8"##"Suma RI 9"
IMPR(DET,"C")

DET:=" "
IMPR(DET,"C")

DET := Replicate("-",84)
IMPR(DET,"C")

DET:=" "
IMPR(DET,"C")

DET:= "Aportes Seguridade social                      Contribuiciones Seg. Social"
IMPR(DET,"C")

DET:=" "
IMPR(DET,"C")                        

DET:=STR0017+space(20)+Transform(nSIPAA,'@E 999,999.99')+Space(13)+STR0017+space(23)+Transform(nSIPAC,'@E 999,999.99')//"SIPA"##"SIPA"
IMPR(DET,"C")

DET:=STR0018+space(18)+Transform(nINSSJPA,'@E 999,999.99')+Space(13)+STR0018+space(21)+Transform(nINSSJPC,'@E 999,999.99')//"INSSJP"##"INSSJP"
IMPR(DET,"C")

DET:=STR0020+space(14)+Transform(nAdic,'@E 999,999.99')+Space(13)+STR0019+space(02)+Transform(nAssFam,'@E 999,999.99')//Adicionales##"Asigs. Famil. compensadas"
IMPR(DET,"C")

DET:=STR0024+space(06)+Transform(nApDif,'@E 999,999.99')+Space(13)+STR0021+space(24)+Transform(nFNE,'@E 999,999.99')//"Aporte Diferencial"##"FNE"
IMPR(DET,"C")

DET:=STR0023+space(18)+Transform(nAnssalA,'@E 999,999.99')+Space(13)+STR0023+space(21)+Transform(nAnssalC,'@E 999,999.99')//"ANSSAL"#"ANSSAL"
IMPR(DET,"C")
                                       
DET:=" "
IMPR(DET,"C")

DET:="Total Aportes SS"+space(06)+Transform(nTotAp,'@E 9,999,999.99')+Space(13)+"Total Contribuiciones"+space(04)+Transform(nTotCon, '@E 9,999,999.99')
IMPR(DET,"C")

DET:=" "
IMPR(DET,"C")

DET :="Aportes Obra Social                            Contribuiciones Obra Social"
IMPR(DET,"C")

DET :="Excedente Aportes"+space(07)+Transform(nExOs,'@E 999,999.99')+Space(13)+"Contribuiciones OS         "+Transform(nOSCnt,'@E 999,999.99')
IMPR(DET,"C")

DET :="Aportes OS"+space(14)+Transform(nOSAp,'@E 999,999.99')
IMPR(DET,"C")

DET :=" "
IMPR(DET,"C")

DET := space(47)+"RENATRE"+space(20)+Transform(0,'@E 999,999.99')
IMPR(DET,"C")
							
DET :=" "
IMPR(DET,"C")
							
DET := "Monto total a Pagar"+space(05)+Transform(nTotAp+nExOs+nOSAp,'@E 999,999.99')
IMPR(DET,"C")

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fSoma        � Autor � Equipe de RH       � Data �          �
�����������������������������������������������������������������������Ĵ
�Descri��o �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fSoma(aMatriz,cArq,cCod,nValor,aDadosFunc, nReg)     		�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper040  												    �
�������������������������������������������������������������������������*/
Static Function fSoma(aMatriz,cArq,cCod,nValor,aDadosFunc,nReg)

/*
��������������������������������������������������������������Ŀ
� 1- Matriz onde os dados estao sendo armazenados              �
� 2- Tipo de Arquivo "C" ou "I"								   �
� 3- Prov/Desc/Base a ser gravado							   �
����������������������������������������������������������������*/
Local nRet
Local nVal1 := nVal2 := nVal3 := 0
Local cSeq := ""

DEFAULT aDadosFunc := {}

/*
��������������������������������������������������������������Ŀ
� Caso o Codigo nao seja passado o tratamento e feito de acordo� 
� com o cArq (Arquivo usado)  								   �
����������������������������������������������������������������*/
If	cCod == Nil
	cCod := If(Len(aDadosFunc) > 0, aDadosFunc[nReg, 3], "")
EndIf

/*
��������������������������������������������������������������Ŀ
� Caso o Codigo nao seja passado o tratamento e feito de acordo�
� com o cArq (Arquivo usado) 								   �
����������������������������������������������������������������*/
If nValor == Nil
	nValor := If(Len(aDadosFunc) > 0, aDadosFunc[nReg,7], 0)
EndIf

If	cArq == "C"
	nVal1 := If(Len(aDadosFunc) > 0																			,;
				If(aDadosFunc[nReg,5] > 0 .And. cIRefSem == "S", aDadosFunc[nReg,5], aDadosFunc[nReg,6])	,;
				0)
				
	nVal2 := nValor
	
	nVal3 := If(Len(aDadosFunc) > 0		,;
				aDadosFunc[nReg,9]		,;
				0)
				
	cSeq := If(Len(aDadosFunc) > 0	, If (!Empty(aDadosFunc[nReg,15]), aDadosFunc[nReg,15], " "), " ")
EndIf

nRet := Ascan( aMatriz,{|X| x[1] == cCod } )   // Testa se ja existe

If nRet == 0
	Aadd (aMatriz,{cCod,nVal1,nVal2,nVal3,cSeq,1})  // se nao cria elemento
Else
	aMatriz[nRet,2] += nVal1                   // se ja so adiciona
	aMatriz[nRet,3] += nVal2
	aMatriz[nRet,4] += nVal3
	aMatriz[nRet,6] ++	
EndIf	

Return Nil

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fTestaTotal  � Autor � Equipe de RH       � Data �          �
�����������������������������������������������������������������������Ĵ
�Descri��o � Executa Quebras                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fTestaTotal()                                        		�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper040  												    �
�������������������������������������������������������������������������*/
Static Function fTestaTotal()

Local cQ
Local cCusto


cFilAnterior := SRA->RA_FILIAL

dbSelectArea( "SRA" )
dbSkip()

If Eof() .Or. &cInicio > cFim
	cCusto := SRA->RA_CC
	fImpEmp()
EndIf

dbSelectArea("SRA")

Return(Nil)


/*/
�����������������������������������������������������������������������Ŀ
�Fun��o	   �fImpEmp      � Autor � Equipe de RH       � Data �          �
�����������������������������������������������������������������������Ĵ
�Descri��o � Imprime Empresa		                                    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fImpEmp()										     		�
�����������������������������������������������������������������������Ĵ
�Parametros�                                                            �
�����������������������������������������������������������������������Ĵ
� Uso	   � Gper040  												    �
�������������������������������������������������������������������������*/
Static Function fImpEmp()

If Len(aEmp) == 0
	Return Nil
EndIf

//IMPRIME EMPRESA
fImprime()

aEmp := {}
nEafa:=  0

Return Nil