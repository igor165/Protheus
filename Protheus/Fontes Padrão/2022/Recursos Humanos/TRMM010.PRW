#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMM010.CH"

/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё TRMM010  Ё Autor Ё Mauro Sergio Testoni    Ё Data Ё 10/12/98 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Processamento de Necessidades de Treinamento                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё TRMM010(void)                                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Mensal                                                       Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё           ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS   Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car.Ё28/07/14ЁTPZWA0  ЁIncluido o fonte da 11 para a 12 e efetua-Ё╠╠
╠╠Ё            Ё        Ё        Ёda a limpeza.                             Ё╠╠
╠╠юддддддддддддаддддддддаддддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function TRMM010
Local aSays		:= {}
Local aButtons	:= {} 				//<== arrays locais de preferencia
Local nOpca 	:= 0
                      
Local cFunction		:= "TRMM010"
Local bProcess	  	:= {|oSelf| Trm010Processa(oSelf)}
Local cDescription	:= OemToAnsi(STR0002) + Space(1) + OemToAnsi(STR0003)   //"Este programa tem como objetivo verificar a necessidade de"###"treinamento comparando Cursos do Cargo x Cursos do Funcionario."
Local cPerg         := "TRM010"   
Private cCadastro  	:= OemToAnsi(STR0001)		//"Necessidade de Treinamento"
Private nSavRec		:= 0
                 
tNewProcess():New(cFunction,cCadastro,bProcess,cDescription,cPerg)

dbSelectArea("RA1") 
dbSetOrder(1)

dbSelectArea("RA3") 
dbSetOrder(1)   

dbSelectArea("RA4") 
dbSetOrder(1)   

dbSelectArea("RA5")
dbSetOrder(1)

dbSelectArea("RAL") 
dbSetOrder(1)

dbSelectArea("SRA")
dbSetOrder(1)

Return Nil

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    ЁTRM010ProcЁ Autor Ё Mauro Sergio Testoni  Ё Data Ё 10/12/98 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Processamento de Necessidades de Treinamento               Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё TRMM010(void)                                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Mensal                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function Trm010Processa(oSelf)
Local cCargo		:= ""
Local cCC			:= ""
Local cFuncao		:= ""
Local aCursos   	:= {}
Local aNecess   	:= {}
Local Nc			:= 0	
Local aMesseng  	:= {}
Local cAcessaSRA  	:= &("{ || " + ChkRH(FunName(),"SRA","2") + "}")
Local cAcessaRA4  	:= &("{ || " + ChkRH(FunName(),"RA4","2") + "}")
Local cAcessaRA5  	:= &("{ || " + ChkRH(FunName(),"RA5","2") + "}")
Local lNecess		:= .T.
Local cChave		:= ""
Local cRA5			:= "" 
Local nTamCC		:= 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carregando as Perguntas 									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nOrdem      := MV_PAR01 	// Ordem de Processamento
cFilDe		:= MV_PAR02		// Filial De
cFilAte 	:= MV_PAR03		// Filial Ate
cCcDe		:= MV_PAR04		// Centro de Custo De
cCcAte		:= MV_PAR05		// Centro de Custo Ate
cMatDe 		:= MV_PAR06		// Matricula De
cMatAte		:= MV_PAR07		// Matricula Ate
cFunDe      := MV_PAR08 	// Funcao De
cFunAte     := MV_PAR09 	// Funcao Ate
cCarDe 		:= MV_PAR10		// Cargo De
cCarAte		:= MV_PAR11		// Cargo Ate

dbSelectArea("SRA")
dbGoTop()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posicionar no Primeiro Func. Selecionado                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOrdem == 1
	dbSetOrder(1)
	dbSeek(cFilDe+cMatDe,.T.)
ElseIf nOrdem == 2
	dbSetOrder(2)
	dbSeek(cFilDe+cCcDe+cMatDe,.T.)
ElseIf nOrdem == 3
	dbSetOrder(7)
	dbSeek(cFilDe+cFunDe,.T.)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Carrega Regua Processamento	                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  
oSelf:SetRegua1(SRA->(RecCount()))
oSelf:SaveLog(STR0001 + " - " + STR0006)	//"Inicio do Processamento"

While ! Eof()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Move Regua Processamento	                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
	oSelf:IncRegua1(STR0005) //"Verificando necessidade"   
   	oSelf:SetRegua2(1)	     
	oSelf:IncRegua2(SRA->RA_NOME)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Consiste controle de acessos e filiais validas				 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
       dbSkip()
       Loop
    EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Consiste o De / Ate  nOrdem = 1-Matricula / 2-Centro Custo   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IF nOrdem == 1
		If Eof() .Or. (SRA->RA_FILIAL + SRA->RA_MAT > cFilAte + cMatAte )
			Exit
		Endif
	ElseIf nOrdem == 2
		If Eof() .Or. (SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT > cFilAte + cCcAte + cMatAte)
			Exit
		Endif
	ElseIf nOrdem == 3
		If Eof() .Or. (SRA->RA_FILIAL + SRA->RA_CODFUNC  > cFilAte + cFunAte)
			Exit
		Endif
	Endif

	cCargo 	:= fGetCargo(SRA->RA_MAT,SRA->RA_FILIAL)
    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Consiste os Parametros 										 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If 	SRA->RA_SITFOLH == "D" 	.Or. ;
		SRA->RA_MAT 	< cMatDe 	.Or. SRA->RA_MAT 		> cMatAte 	.Or.;
		SRA->RA_CC 		< cCcDe 	.Or. SRA->RA_CC 		> cCCAte 	.Or.;		
		SRA->RA_CODFUNC	< cFunDe 	.Or. SRA->RA_CODFUNC	> cFunAte	.Or.;
		cCargo			< cCarDe	.Or. cCargo				> cCarAte

		dbSelectArea("SRA")
		dbSkip()
		Loop
	Endif		

	cCC		:= SRA->RA_CC          
	cRA5	:= "RA5->RA5_FILIAL+RA5->RA5_CARGO+RA5->RA5_CC"
	nTamCC	:= TamSX3("RA_CC")[1]

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carregar os Cursos do Cargo em Array para Comparacao         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aCursos := {}
	dbSelectArea("SQ3")
	dbSetOrder(1)
	cFil := xFilial("SQ3", SRA->RA_FILIAL)
	If dbSeek(cFil+cCargo+cCC)
		cChave 	:= cCargo+cCC 
	Else
		cChave	:= cCargo+Space(nTamCC)
	EndIf
	
	dbSelectArea("RA5")
	dbSetOrder(2)
	cFil := xFilial("RA5", SRA->RA_FILIAL)	
	cChave 	:= cFil+cChave
	
	dbSeek(cChave)
	While !Eof() .And. cChave == &cRA5

	    If !Eval(cAcessaRA5)
	       dbSkip()
	       Loop
	    EndIf

		Aadd(aCursos,{RA5->RA5_CURSO,RA5->RA5_HORAS,RA5->RA5_VALIDA,RA5->RA5_NOTA,RA5->RA5_FREQUE,RA5->RA5_EFICAC})
		dbSkip()
	Enddo	

	cFuncao := SRA->RA_CODFUNC
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Carregar os Cursos da Funcao em Array para Comparacao        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("RAL") 
	cFil := xFilial("RAL", SRA->RA_FILIAL)	
	dbSeek(cFil+cFuncao)
	
	While ! Eof() .And. cFil+cFuncao == RAL->RAL_FILIAL+RAL->RAL_FUNCAO
	
	    If !Eval(cAcessaRA5)
	       dbSkip()
	       Loop
	    EndIf

		Aadd(aCursos,{RAL->RAL_CURSO,RAL->RAL_HORAS,RAL->RAL_VALIDA,RAL->RAL_NOTA,RAL->RAL_FREQUE,RAL->RAL_EFICAC})
		dbSkip()
	Enddo	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verificar Cursos do Cargo com Cursos do Fucnionario          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aNecess := {} 
	For nC := 1 To Len(aCursos)
		
		lNecess	:= .T.
			
		dbSelectArea("RA4")
		dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+aCursos[nC,1] )
		If ! Eof()
			While ! Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT+aCursos[nC,1] == RA4->RA4_FILIAL+RA4->RA4_MAT+RA4->RA4_CURSO
		    	If !lNecess
		    		dbSkip()
		    		Loop
		    	EndIf
		    	
			    If !Eval(cAcessaRA4)
			       dbSkip()
			       Loop
		    	EndIf

				IF	RA4->RA4_HORAS 	< aCursos[nC,2] .Or.;
					RA4->RA4_NOTA 	< aCursos[nC,4] .Or.;
					RA4->RA4_PRESEN	< aCursos[nC,5] .Or.;
					RA4->RA4_EFICAC	< aCursos[nC,6] .Or.;
					(!Empty(RA4->RA4_VALIDA) .And. RA4->RA4_VALIDA < dDataBase)
				 
				 	lNecess := .T.
				Else
					lNecess := .F.
				Endif
				
				dbSelectArea("RA4")
				dbSkip()
			Enddo	
				
		Else
			lNecess := .T.
		Endif	

		If lNecess
			Aadd(aNecess,aCursos[nC,1])
		EndIf		
		
	Next nC

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gravar as Necessides de Treinamento na Solicitacao           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aNecess) > 0

		For Nc := 1 To Len(aNecess)
			dbSelectArea("RA3")
			If ! dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+aNecess[Nc])
				RecLock("RA3",.T.)
					RA3->RA3_FILIAL := SRA->RA_FILIAL
					RA3->RA3_MAT    := SRA->RA_MAT
					RA3->RA3_CURSO  := aNecess[nC]
					RA3->RA3_RESERV := "S"
					RA3->RA3_DATA   := dDataBase
				MsUnlock()

				//зддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Carrega array para envio de e-mail              Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддды
				dbSelectArea("RA1")
				dbSetOrder(1)
				cDesCurso:= Iif(dbSeek(xFilial("RA1")+aNecess[nC]),RA1->RA1_DESC," ")
				Aadd(aMesseng, {SRA->RA_MAT +" - "+ SRA->RA_NOME, aNecess[nC] +" - "+ cDesCurso})
							
				dbSelectArea("RA3")

			Endif		
		Next nC
	Endif
	
	dbSelectArea("SRA")
	dbSkip()
EndDo

oSelf:SaveLog(STR0001 + " - " + STR0007)	//"TИrmino do Processamento"

If Len(aMesseng) > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia e-mail do Evento 013                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	fMontaMail("013",aMesseng)
EndIf

dbSelectArea("SRA")
dbSetOrder(1)
dbGoTop()

Return Nil
