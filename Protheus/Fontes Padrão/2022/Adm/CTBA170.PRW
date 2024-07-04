#Include "CTBA170.CH"
#Include "PROTHEUS.CH"

//Defines de posição do array de filiais
Static lFWCodFil := FindFunction("FWCodFil")

Static __oTempTable

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CTBA170   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 06.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Plano de Contas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctba170()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba170                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION CTBA170()
             	
Local aCampos		:= {{"FILIAL","C",IIf( lFWCodFil, FWGETTAMFILIAL, 2 ),0},;
						 {"COD","C",02,0},;
						 {"CONTA","C",Len(CriaVar("CT1_CONTA")),0},;				 		 
						 {"CTASUP","C",Len(CriaVar("CT1_CTASUP")),0},;
						 {"CTAPON","C",Len(CriaVar("CT1_CTAPON")),0},;						 
 						 {"CTALP","C",Len(CriaVar("CT1_CTALP")),0},;						 
						 {"DESCINC","C",80,0}}
				 		 
Local aSays 		:= {}
Local aButtons		:= {}
Local cFilBack 		:= cFilAnt              // Armazena a filial atual
Local cNomeArq      := ""
Local nReg			:= 0
LOCAL nOpca    		:= 0

Local aSM0			:= {}
Local nContFil		:= 0

Local cFilProc		:= ""
Local lExclusivo	:= If(FindFunction("AdmTabExc"), AdmTabExc("CT1"), !Empty(XFilial("CT1"))) //Analisa se a tabela esta exclusiva

Private cCadastro 	:= OemToAnsi(STR0001)  //"Valida Plano de Contas"

PRIVATE wnrel
PRIVATE cString   	:= "CT1"
PRIVATE cDesc1    	:= OemToAnsi(STR0002)  //"Esta rotina ir  imprimir o Log referente a validacao,"
PRIVATE cDesc2    	:= OemToAnsi(STR0003)  //"da Conta Superior do Plano de Contas."
PRIVATE cDesc3    	:= ""
PRIVATE titulo    	:= OemToAnsi(STR0004)  //"Log Validacao Plano de Contas"
PRIVATE cCancel   	:= OemToAnsi(STR0006)  //"***** CANCELADO PELO OPERADOR *****"
PRIVATE aReturn   	:= { OemToAnsi(STR0007), 1, OemToAnsi(STR0008), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
PRIVATE nomeprog  	:= "CTBA170"
PRIVATE aLinha    	:= { },nLastKey := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do Cabecalho.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                       					  //          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22  
                      					  //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
PRIVATE cabec1    	:= OemToAnsi(STR0005)// FILIAL   CODIGO DA CONTA               CONTA SUPERIOR                     CONTA PONTE              CONTA LUCROS/PERDAS           OCORRENCIA       
PRIVATE cabec2    	:= " "

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

Pergunte("CTB170",.f.)
AADD(aSays,OemToAnsi( STR0009 ) )	// "  Este programa tem como objetivo validar a Conta Superior."
AADD(aSays,OemToAnsi( STR0010 ) )	// "Se a Conta Superior tiver uma formula de calculo diferente"
AADD(aSays,OemToAnsi( STR0011 ) )	// "da utilizada do sistema, a formula devera ser informada."
AADD(aSays,OemToAnsi( STR0012 ) )	// "Caso a Conta Superior tenha sido digitada e nao exista formula"
AADD(aSays,OemToAnsi( STR0013 ) )	// "p/ gera-la NAO EXECUTE este programa com a opca Corrige!!"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB170",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CtbOk(), FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons  ,,,420)
	
If ( Select ( "cNomeArq" ) <> 0 )
	dbSelectArea ( "cNomeArq" )
	dbCloseArea ()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Pergunta de quantidade de digitos no ultimo nivel nao preenchido.  
If Empty(mv_par06)                              
	Help(" ",1,"NODIGNIV")
	Return(.F.)
Endif                            

If __oTempTable <> Nil
	__oTempTable:Delete()
	__oTempTable := Nil
Endif

__oTempTable := FWTemporaryTable():New( "cNomeArq" )  
__oTempTable:SetFields(aCampos) 
__oTempTable:AddIndex("1", {"FILIAL","COD","CONTA","CTASUP"})

//------------------
//Criação da tabela temporaria
//------------------
__oTempTable:Create()  

dbSelectArea("cNomeArq")
dbSetOrder(1)

IF nOpca == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu( "INICIO" )
	
	aSM0 := Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
	
	If Len(aSM0) > 0
		For nContFil := 1 to Len(aSM0)
			If aSM0[nContFil][SM0_CODFIL] < mv_par01 .Or. aSM0[nContFil][SM0_CODFIL] > mv_par02 .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
				Loop
			EndIf
			
			cFilAnt := aSM0[nContFil][SM0_CODFIL]

			//Tratamento Gestao Corporativa

			If Len(AllTrim(xFilial("CT1")) ) > 2
				If Alltrim(cFilProc) != Alltrim(xFilial("CT1"))
					cFilProc:= xFilial("CT1")
				Else
					Loop
				EndIf
			EndIf

			Processa({|lEnd| Ctb170Proc(cFilant)})
			// Se o arquivo e' compartilhado, so devera ser lido apenas uma vez!!
			If !lExclusivo
				Exit
			Endif
		Next nX
		
		cFilAnt := cFilBack
		C170ImpRel()
	Else
		ProcLogAtu("ERRO","Atenção!","Nenhuma empresa/filial encontrada. Verique se está utilizando a ultima versão do ADMXFUN (MAR/2010)" )
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")
Endif

//Apaga tabela temporaria do banco de dados
If __oTempTable <> Nil
	__oTempTable:Delete()
	__oTempTable := Nil
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctb170Proc³ Autor ³ Simone Mie Sato       ³ Data ³ 19.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifico as inconsistencias.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB170Proc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba170                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial do arquivo a ser verificado                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ctb170Proc(cFilArq)

Local aSaveArea		:= GetArea()	
Local cConta   		:= ""
Local cCtaSup 		:= ""  
Local cCtaPai  		:= ""  
Local cContaSup 	:= ""  
Local lRet	   		:= .T.
Local nTotReg 		:= 0
Local nTotAtu 		:= 0
Local nReg 	  		:= 0	
Local cDescInc 		:= ""
Local nDigNiv1		:= mv_par06 //Quant. max.de digitos das contas de Nivel 1
Local cCtaLp		:= ""
Local cCtaPon		:= ""

//VERIFICACAO PARTINDO DAS CONTAS ANALITICAS PARA AS CONTAS SINTETICAS.
dbSelectArea("CT1")
dbSetOrder(3) 									//Ordem: FILIAL+CLASSE+CONTA
dbSeek(xFilial("CT1")+'2')						//Procuro pela primeira conta analitica
nTotReg := CT1->(Reccount())

ProcRegua(nTotReg)

While !Eof() .And. CT1->CT1_FILIAL == xFilial("CT1") .And. CT1->CT1_CLASSE ='2'
	cConta  := CT1->CT1_CONTA
	cCtaSup := CT1->CT1_CTASUP 
	cClasse := CT1->CT1_CLASSE
	cCtaLp	:= CT1->CT1_CTALP
	cCtaPon	:= CT1->CT1_CTAPON
	
	IncProc()	         
	If !Empty(cCtaSup) .and. cCtaSup == cConta	/// VALIDACAO DA CONTA SUPERIOR IGUAL
		lRet := .F. 
		cDescInc := OemToAnsi(STR0026)     		//"Conta e conta superior não podem ser iguais."
		cCod     := '30'
		C170GrvInc(cCod,cConta,cCtaSup,cDescInc)				
		CT1->(dbSkip())
		Loop
	Endif
	
	//Caso a conta de L/P esteja preenchida,verifico se existe no cadastro e se e analitica.
	If !Empty(cCtaLp)
		lRet := Ct170ExCta(cConta,cCtaLP,.F.)	
	Endif
	
	//Caso a Conta Ponte esteja preenchida, verifico se existe no cadastro e se e analitica.
	If !Empty(cCtaPon)
		lRet := Ct170ExCta(cConta,cCtaPon,.T.)	
	Endif
	
	//Verifico se a conta superior esta preenchida, se existe no cadastro e se e sintetica. 		
	lRet := Ct170Verif(cConta,cCtaSup,cClasse,nDigNiv1)	                
	If !lRet 
		If mv_par03 == 2 								//Se corrige 
			If mv_par04 != 3							// Automatico / Formula
				If mv_par04 == 1						// Automatico -> Formula Siga
					cContaSup		:= CtbCtaSup(cConta)
				ElseIf mv_par04 == 2					// Formula -> do usuario
					If !Empty(mv_par05)
						cContaSup 	:= &(mv_par05)
					EndIf
				EndIf
			EndIf	         
			Reclock("CT1",.F.)
			CT1->CT1_CTASUP := cContaSup 
			MsUnlock()
		Endif	    
    Endif                      
	
	//Faco a checagem da superior. 
		dbSelectArea("CT1")
		dbSetOrder(1)
		nReg := Recno()		
		
		While !Eof() .And. CT1->CT1_FILIAL == xFilial() 
		
			IncProc()
			
		 	If dbSeek(xFilial("CT1")+CT1->CT1_CTASUP)		
				cConta  := CT1->CT1_CONTA
				cCtaSup := CT1->CT1_CTASUP 
				cClasse := CT1->CT1_CLASSE
			If !Empty(cCtaSup) .and. cCtaSup == cConta	/// VALIDACAO DA CONTA SUPERIOR IGUAL
				lRet := .F. 
				cDescInc := OemToAnsi(STR0026)     		//"Conta e conta superior não podem ser iguais."
				cCod     := '30'
				C170GrvInc(cCod,cConta,cCtaSup,cDescInc)				
				Exit
			Endif
				lRet 	:= Ct170Verif(cConta,cCtaSup,cClasse,nDigNiv1)	                			
				
	 			If Empty(CT1->CT1_CTASUP)						
	           		If CT1->CT1_CLASSE == '1'						//Se for conta sintetica        
	       				If mv_par03 == 2 								//Se corrige 	
							If mv_par04 != 3							// Automatico / Formula
								If mv_par04 == 1						// Automatico -> Formula Siga
									cContaSup		:= CtbCtaSup(cConta)		
								ElseIf mv_par04 == 2					// Formula -> do usuario
									If !Empty(mv_par05)
										cContaSup 	:= &(mv_par05)
									EndIf
								EndIf
							EndIf	         
							Reclock("CT1",.F.)
				   			CT1->CT1_CTASUP := cContaSup 
							MsUnlock()
						Endif	    
					Else
						Exit
					Endif
				EndIf
			Endif            
			If nTotAtu > nTotReg			 	//Se entrou num loop e ja ultrapassou o numero de registros do
				cDescInc :=OemToAnsi(STR0018)	//"Erro de estruturacao no plano de contas."	              
				cCod	 := '10'
				nTotAtu  := 0
				C170GrvInc(cCod,cConta,cCtaSup,cDescInc)			
				lRet := .F.
				Exit				
			Endif
			nTotAtu += 	1
		EndDo		            
		nTotAtu := 	0
 		dbSelectArea("CT1")
		dbSetOrder(3)
		dbGoTo(nReg)	
	
	dbSelectArea("CT1")      
	dbSkip()
Enddo

//VERIFICACAO PARTINDO DAS CONTAS SINTETICAS PARA AS CONTAS ANALITICAS
dbSelectArea("CT1")
dbSetOrder(3) 									//Ordem: FILIAL+CLASSE+CONTA
dbSeek(xFilial("CT1")+'1')						//Procuro pela primeira conta sintetica
ProcRegua(CT1->(RecCount()))
While !Eof() .And. CT1->CT1_FILIAL == xFilial("CT1")
	cCtaPai := CT1->CT1_CONTA
	IncProc()	                                
	//Verifico se a conta sintetica esta associada a outra conta.	
	nReg := Recno()
	dbSetOrder(5) 					//Ordem por Conta Superior
    If CT1->CT1_CLASSE == '1' .AND. !MsSeek(xFilial("CT1")+cCtaPai,.F.)  
		lRet := .F. 
		cDescInc := OemToAnsi(STR0019) //"Conta sintetica nao esta associada a nenhuma outra conta."
		cCod	 := '20'
		C170GrvInc(cCod,cCtaPai,"",cDescInc)
	ElseIf !Empty(CT1->CT1_CTASUP) .and. CT1->CT1_CTASUP == CT1->CT1_CONTA	/// VALIDACAO DA CONTA SUPERIOR IGUAL
		lRet := .F. 
		cDescInc := OemToAnsi(STR0026)     		//"Conta e conta superior não podem ser iguais."
		cCod     := '30'
		C170GrvInc(cCod,CT1->CT1_CONTA,CT1->CT1_CTASUP,cDescInc)				
	EndIf	
	
	dbSelectArea("CT1")      
	dbSetOrder(3)						//Ordem: FILIAL+CLASSE+CONTA
	dbGoto(nReg)
	dbSkip()
Enddo                    

dbSelectArea("cNomeArq")
If Eof()
	cDescInc := OemToAnsi(STR0020) //"Nao ha divergencias no Plano de Contas."
	cCod	 := '99'
	C170GrvInc(cCod,"","",cDescInc)					 
Endif
dbSelectArea("CT1")

RestArea(aSaveArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct170Verif³ Autor ³ Simone Mie Sato       ³ Data ³ 19.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifico as inconsistencias.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct170Verif()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION Ct170Verif(cConta,cCtaSup,cClasse,nDigNiv1)	                

Local aSaveArea:= GetArea()	
Local cDescInc := ""
Local lRet 	   := .T.
Local nRegAtu  := 0                        
Local nTamCta  := Len(Alltrim(cConta))      //Tamanho da Conta. 

If Empty(cCtaSup) .And. cClasse == '2' 
	cDescInc := OemToAnsi(STR0015)     		//"Conta superior nao preenchida."
	cCod     := '40'
	C170GrvInc(cCod,cConta,cCtaSup,cDescInc)			
	lRet := .F. 
Endif					
		                
dbSetOrder(1)		
nRegAtu := Recno()
If !dbSeek(xFilial()+cCtaSup)         
	If !Empty(cCtaSup)
		cDescInc := OemToAnsi(STR0016)     		//"Conta superior nao existe no Cadastro de Plano de Contas "
		cCod     := '50'
		C170GrvInc(cCod,cConta,cCtaSup,cDescInc)			
		lRet := .F.  
	Else
		If nTamCta > nDigNiv1
			cDescInc := OemToAnsi(STR0015)     		//"Conta superior nao preenchida."
			cCod     := '40'
			C170GrvInc(cCod,cConta,cCtaSup,cDescInc)			
			lRet := .F. 
		Endif
	Endif
Else								  //Se achar a conta superior no cad.,verifico se e sintetica. 
	If CT1->CT1_CLASSE != "1"				
		cDescInc := OemToAnsi(STR0017)   		//""Conta superior nao pode ser analitica."
		cCod	 := '60'
		C170GrvInc(cCod,cConta,cCtaSup,cDescInc)			
		lRet := .F. 
	EndIf    
Endif          		
dbgoto(nRegAtu)
dbSetOrder(3)
				
RestArea(aSaveArea)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C170GrvInc³ Autor ³ Simone Mie Sato       ³ Data ³ 19.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava as Inconsistencias no Arq. de Trabalho.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C170GrvInc(cConta,cCtaSup,cDescInc)			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                             			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba170                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Inconsistencia   			              ³±±
±±³          ³ ExpC2 = Codigo da Conta            			              ³±±
±±³          ³ ExpC3 = Codigo da Conta Superior   			              ³±±
±±³          ³ ExpC4 = Descricao da Inconsistencia			              ³±±
±±³          ³ ExpC5 = Codigo da Conta Ponte      			              ³±±
±±³          ³ ExpC6 = Codigo da Conta de Apuracao de Resultados          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                         

Function C170GrvInc(cCod,cConta,cCtaSup,cDescInc,cCtaPon,cCtaLP)			
                                
Local aSaveArea	:= GetArea()	
Local cChave	:= ""

If !Empty(cCtaSup)
	cChave := xFilial("CT1")+cCod+cConta+cCtaSup
ElseIf !Empty(cCtaPon)
	cChave := xFilial("CT1")+cCod+cConta+cCtaPon
Elseif !Empty(cCtaLP)                            
	cChave := xFilial("CT1")+cCod+cConta+cCtaLP
Else
	cChave := xFilial("CT1")+cCod+cConta
Endif                                           

dbSelectArea("cNomeArq") 
dbGotop()         
If !dbSeek(cChave)
	Reclock("cNomeArq",.T.)	
	cNomeArq->FILIAL	:= xFilial("CT1")
	cNomearq->COD		:=	cCod		//CODIGO DA OCORRENCIA
	cNomeArq->CONTA		:=	cConta
	cNomeArq->CTASUP	:=	cCtaSup
	cNomeArq->DESCINC	:=	cDescInc
	cNomeArq->CTAPON	:=	cCtaPon
	cNomeArq->CTALP		:=	cCtaLP
	MsUnlock()
Endif

RestArea(aSaveArea)

Return	

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ct170ExCta³Autor  ³ Simone Mie Sato       ³ Data ³ 21.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verificacao se a conta existe no cad. e se e analitica.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct170ExCta(cConta,cCtaLPon,lPonte)	 		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                           	 		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba170                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Conta                                    ³±±
±±³          ³ ExpC2 = Codigo da Conta Ponte                              ³±±
±±³          ³ ExpL1 = Define se eh conta ponte ou nao                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                         
Function Ct170ExCta(cConta,cCtaLPon,lPonte)
                    
Local aSaveArea := GetArea()
Local lRet		:= .T.

dbSelectArea("CT1")
dbSetOrder(1)
dbSeek(xFilial("CT1")+cCtaLPon)
If !Found()
	cCod     := '50'                       
	If lPonte 						//Se for conta ponte
		cDescInc := OemToAnsi(STR0022)	//"Conta Ponte nao existe no Cadastro de Plano de Contas."		
		C170GrvInc(cCod,cConta,,cDescInc,cCtaLPon,)			
	Else
		cDescInc := OemToAnsi(STR0023)	//"Conta Lucros/Perdas nao existe no Cadastro de Plano de Contas."		
		C170GrvInc(cCod,cConta,,cDescInc,,cCtaLPon)			
	Endif
	lRet := .F. 
Else    
	If CT1->CT1_CLASSE == '1'
		cCod     := '60'
		If lPonte 						//Se for conta ponte
			cDescInc := OemToAnsi(STR0024)	//"Conta Ponte nao e analitica."		
			C170GrvInc(cCod,cConta,,cDescInc,cCtaLPon,)			
		Else
			cDescInc := OemToAnsi(STR0025)	//"Conta Lucros/Perdas nao e analitica."		
			C170GrvInc(cCod,cConta,,cDescInc,,cCtaLPon)			
		Endif
		lRet := .F. 
	Endif
Endif            

RestArea(aSaveArea)

Return(lRet)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C170ImpRel³ Autor ³ Simone Mie Sato       ³ Data ³ 20.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime o Relatorio Final.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C170ImpRel()		  							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum        	  							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba170                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum        	  							              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                         

Function C170ImpRel()			
                                
Local Tamanho		:="G"
PRIVATE aLinha		:= {}
PRIVATE nomeProg  := "CTBA170"

li 		:= 80
m_pag		:= 1


wnrel	:= "CTBA170"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,,,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif


SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif


RptStatus({|lEnd| CTA170Imp(@lEnd,wnRel,cString,Titulo,Tamanho)})

Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cta170Imp ³Autor  ³ Simone Mie Sato       ³ Data ³ 20.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime o Relatorio Final.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cta170Imp()       							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum            							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ctba170                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1   - A‡ao do Codeblock                                ³±±
±±³          ³ ExpCl   - T¡tulo do relat¢rio                              ³±±
±±³          ³ ExpC2   - Mensagem                                         ³±±
±±³          ³ ExpC3   - Titulo                                           ³±±
±±³          ³ ExpC4   - Tamanho do relatorio                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                         

Function Cta170Imp(lEnd,wnRel,cString,Titulo,Tamanho)			
                    
Local Li := 80
	
dbSelectArea("cNomeArq")
dbGotop()
PRIVATE cabec1    	:= OemToAnsi(STR0005)
SetRegua(RecCount())
While !Eof()	

	If Li > 55	
		Cabec(titulo,cabec1,cabec2,NomeProg,Tamanho)
		Li := 10
	Endif
	IncRegua()	 		 	
	@ Li,01 PSAY cNomeArq ->FILIAL
	@ Li,10 PSAY cNomeArq ->CONTA
	@ Li,40 PSAY cNomeArq ->CTASUP             
	@ Li,75 PSAY cNomeArq ->CTAPON             	
	@ Li,100 PSAY cNomeArq ->CTALP             
	@ Li,130 PSAY cNomeArq ->DESCINC			
	
	Li += 1
	dbSkip()
End          
	
If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
EndIf

MS_FLUSH()       

Return
