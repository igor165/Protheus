#INCLUDE "CSAM050.CH"   
#INCLUDE "PROTHEUS.CH"

Static lCSA50COR := ExistBlock( "CSA50COR" )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CSAM050  ³ Autor ³ Cristina Ogura        ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera arquivo com os dados da Pesquisa Salarial             ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC  ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³18/07/14³TPZVUR³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSAM050()
Local nOpca := 0
Local oDlg
Local aSays	:= {}, aButtons := {} //<== arrays locais de preferencia

Private cCadastro := OemtoAnsi(STR0001)	//"Gera‡„o das Pesquisas Salariais"

Pergunte("CSM050",.F.)

AADD(aSays,OemToAnsi(STR0002) ) //"Este programa calcula as Pesquisas Salariais"
AADD(aButtons, { 5,.T.,{|| Pergunte("CSM050",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(Cs050OK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|lEnd| Cs050Processa()})	// Chamada do Processamento
EndIf     

dbSelectArea("RB0")
dbSetOrder(1)
dbGotop()   

dbSelectArea("RB1")
dbSetOrder(1)

Return Nil
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Processa ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Processa()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Processa()
Local cInicio	:= ""
Local cFim		:= ""
Local cRegiao	:= Space(04)
Local cPorte	:= Space(01)
Local nx		:= ""
Local ny        := ""
Local cAcessaRB1:= &("{ || " + ChkRH(FunName(),"RB1","2") + "}")
Local cFil		:= ""

Private aEmpresas	:= {}, aFuncao	:= {}, aDados:={}, aCalculos:={}
Private aVl1		:= {}, aVl2	:= {}
Private aR1  		:= {}, aR2		:= {}
Private aValores	:= {}, aClasses:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na pergunte                                 ³
//³ mv_par01				// Filial De                             ³
//³ mv_par02				// Filial Ate                            ³
//³ mv_par03				// Pesquisa De                           ³
//³ mv_par04				// Pesquisa Ate                          ³
//³ mv_par05				// Corte                                 ³
//³ mv_par06				// Valor Corte                           ³
//³ mv_par07				// Gerar Pesquisa por Regiao Sim Nao     ³
//³ mv_par08				// Periodo De                            ³
//³ mv_par09				// Periodo Ate                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilDe 		:= mv_par01
cFilAte     := mv_par02
cPesqDe		:= mv_par03
cPesqAte	:= mv_par04
cCorte		:= mv_par05
nVlrCorte 	:= mv_par06
nRegiao 	:= mv_par07
dPerDe		:= mv_par08
dPerAte		:= mv_par09

// Filial Ate + Pesquisa Ate
cInicio	:="RB1->RB1_FILIAL+RB1->RB1_PESQ"
cFim	:= cFilAte+cPesqAte

// Apagar os dados da Pesquisa Anterior
dbSelectArea("RB5")
dbSetOrder(1)    
cFil := If(xFilial("RB5") == Space(FWGETTAMFILIAL),xFilial("RB5"),cFilDe)

If dbSeek(cFil+cPesqDe)
	While !Eof() .And. cFil+cPesqDe == RB5->RB5_FILIAL+RB5->RB5_PESQ
		RecLock("RB5",.F.)
			dbDelete()
		MsUnlock()
		dbSkip()	
	EndDo
EndIf
                            
// Filial De + Pesquisa De                             
dbSelectArea("RB1")
dbSetOrder(1)
cFil := If(xFilial("RB1") == Space(FWGETTAMFILIAL),xFilial("RB1"),xFilial("RB1",cFilDe))

dbSeek(cFil+cPesqDe,.T.)

ProcRegua(RB1->(RecCount()))

While !Eof() .And. &cInicio <= cFim      
         
	// Desprezar as pesquisas dos parametros
	If 	RB1->RB1_PESQ < cPesqDe .Or.;
		RB1->RB1_PESQ > cPesqAte
		dbSkip()
		Loop
	EndIf	                                          
	
	If !Eval(cAcessaRB1)
		dbSkip()  
		Loop
	EndIf


	IncProc(RB1->RB1_FILIAL+RB1_PESQ+"-"+RB1->RB1_DESCRI)
	
	// Monta array com as Empresas e Funcoes
	Cs050Monta(RB1->RB1_PESQ)
		
	For nx:= 1 To Len(aFuncao)
	
		cPorte := aEmpresas[1][3]

		// Gera por Regiao for Sim		
		If nRegiao == 1
			cRegiao := aEmpresas[1][2]
		EndIf

		For ny:=1 To Len(aEmpresas)
			
			// Gera por regiao Sim
			If 	nRegiao == 1 .And.(cRegiao # aEmpresas[ny][2] .Or.;
				cPorte # aEmpresas[ny][3])
		        If !Cs050Grava(RB1->RB1_PESQ,aFuncao[nx],cRegiao,cPorte)
		        	Return .T.
		        EndIf
		        cRegiao := aEmpresas[ny][2]
		        cPorte	:= aEmpresas[ny][3]
			EndIf		       
		
			// Monta o array com os dados para os calculos
			Cs050Array(aFuncao[nx],RB1->RB1_DTBASE,RB1->RB1_HORAS,RB1->RB1_INDICE,aEmpresas[ny][1],dPerDe,dPerAte)
		
		Next ny
		
		// Grava os dados da Pesquisa Salarial
		If !Cs050Grava(RB1->RB1_PESQ,aFuncao[nx],cRegiao,cPorte)		     
			Return .T.
		EndIf
		
	Next nx
	
	dbSelectArea("RB1")
	dbSetOrder(1)
	dbSkip()
	
EndDo

Return .T.

                               
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Monta    ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array das Empresas e Funcoes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Monta()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Monta(cPesq)
Local aSaveArea := GetArea()
    
aEmpresas	:={}
aFuncao		:={}

dbSelectArea("RB4")
dbSetOrder(1)
If dbSeek(xFilial("RB4")+cPesq)
	While !Eof() .And. xFilial("RB4")+cPesq == RB4->RB4_FILIAL+RB4_PESQ
	
		If !Empty(RB4->RB4_EMPRES)
			dbSelectArea("RB0")
			dbSetOrder(1)
			If dbSeek(xFilial("RB0")+RB4->RB4_EMPRES)
				Aadd(aEmpresas,{RB4->RB4_EMPRES,RB0->RB0_REGIAO,RB0->RB0_PORTE})
			EndIf
		EndIf	
		If !Empty(RB4->RB4_FUNCAO)
			Aadd(aFuncao,RB4->RB4_FUNCAO)
		EndIf
		dbSelectArea("RB4")
		dbSetOrder(1)
		dbSkip()	
	EndDo
EndIf

// Ordena as Empresas por Regiao
aEmpresas:= aSort(aEmpresas,,,{|x,y| x[2]+x[3] < y[2]+y[3]})

RestArea(aSaveArea)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Dados    ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que verifica a quebra por regioes                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Dados()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Dados()

If Len(aDados) ==0
	Return .T.
EndIf	
		
// Somar as frequencias com mesmo salario e ordena-los
Cs050Ordena()
		
// Calcula os valores para Pesquisa
Cs050Calc()   
		
// Verifica o corte dos dados para Pesquisa
Cs050Corte()             
		
// Calcula os resultados para Pesquisa
Cs050Result()
		
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Array    ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta array com os dados da Empresa para calculos		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Monta()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Array(cFuncao,dData,nHoras,cIndice,cEmpresa,dDtDe,dDtAte)
Local nFI		:= 0
Local nXI       := 0
Local nSalario	:= 0
Local nAntecip	:= 0

dbSelectArea("RB2")  
dbSetOrder(1)
If dbSeek(xFilial("RB2")+cEmpresa+cFuncao)
	While !Eof() .And. xFilial("RB2")+cEmpresa+cFuncao ==;
						RB2_FILIAL+RB2_EMPRES+RB2_FUNCAO
						
		If ( ValType(dDtde) != "U" .And. ValType(dDtAte) != "U" )
			// Desprezar periodo
			If 	RB2->RB2_DTBASE < dDtde .Or.;
				RB2->RB2_DTBASE > dDtAte
				dbSkip()
				Loop
			EndIf
		EndIf 			
								
		// Frequencia 	             
		nFI := RB2->RB2_FREQ
			
		// Remuneracao                                                      
		nAntecip :=	IF(RB2->RB2_ANTECI>1,(1-RB2->RB2_ANTECI),RB2->RB2_ANTECI)
		nSalario := Round(RB2->RB2_SALARI - (RB2->RB2_SALARI * nAntecip),2)
		nXI 	 := Cs050Convert(cIndice,dData,nHoras,RB2->RB2_DISSID,RB2->RB2_HORAS,nSalario,RB2->RB2_DTBASE)
		
		// [1] = Frequencia 	- nFI
		// [2] = Remuneracoes   - nXI
		
		Aadd(aVl1,{nFI, nXI})				
		
		// Remuneracao + Valores Adicionais
		nAntecip :=	IF(RB2->RB2_ANTECI>1,(1-RB2->RB2_ANTECI),RB2->RB2_ANTECI)
		nSalario := Round(RB2->RB2_SALARI - (RB2->RB2_SALARI * nAntecip) + RB2->RB2_ADICIO,2)
		nXI 	 := Cs050Convert(cIndice,dData,nHoras,RB2->RB2_DISSID,RB2->RB2_HORAS,nSalario,RB2->RB2_DTBASE)
		
		// [1] = Frequencia 	- nFI
		// [2] = Remuneracoes   - nXI
		Aadd(aVl2,{nFI,nXI})
			            
		dbSelectArea("RB2")
		dbSkip()
			
	EndDo					
EndIf

Return .T.  

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Convert  ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte o salario na mesma data e jornada de trabalho.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Convert()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Indice a ser aplicado									  ³±±
±±³ 		 ³ Data Base da Pesquisa									  ³±±
±±³ 		 ³ Jornada de Trabalho da Pesquisa							  ³±±
±±³ 		 ³ Mes de dissidio da Empresa								  ³±±
±±³ 		 ³ Jornada de Trabalho da Empresa							  ³±±
±±³ 		 ³ Salario da Empresa 										  ³±±
±±³ 		 ³ Data Base da Empresa										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Convert(cIndice,dDtPes,nHorasPes,cDissEmp,nHorasEmp,nSalEmp,dDtEmp)
Local nSalConv	:= 0
Local dData		:= Ctod("")
Local cAux      := ""           

If 	Empty(cDissEmp) .Or. Empty(nHorasEmp) .Or. Empty(dDtEmp)
	Return nSalConv
EndIf	

// Data a ser corrigido o salario - Mes dissidio ate a data base da empresa
If Val(cDissEmp) <= Month(dDtEmp)
	cAux  := "01/"+cDissEmp+"/"+Str(Year(dDtEmp),4)	
ElseIf Val(cDissEmp) > Month(dDtEmp)
	cAux  := "01/"+cDissEmp+"/"+Str(Year(dDtEmp)-1,4)
EndIf

// Corrigir o salario a partir desta data
dData := CtoD(cAux)

While MesAno(dData) <= MesAno(dDtPes)
	dbSelectArea("RB3")                    
	dbSetOrder(1)
	If dbSeek(xFilial("RB3")+cIndice+StrZero(Month(dData),2)+StrZero(Year(dData),4))
		nSalEmp := nSalEmp * RB3->RB3_VALOR
	EndIf	
	
	Cs050SomaMes(@dData)
EndDo          

nSalConv := nSalEmp               

// Carga Horaria da Pesquisa for diferente da Empresa
If nHorasPes # nHorasEmp
	nSalConv = (nSalEmp * nHorasPes) / nHorasEmp
EndIf

Return Round(nSalConv,2)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050SomaMes  ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma um mes na data                              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050SomaMes()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050SomaMes(dData)
Local nMes := Month(dData)
Local nAno := Year(dData)
Local cData:= ""

nMes := nMes + 1

If nMes == 13
	nMes := 1
	nAno := nAno + 1
EndIf

cData := StrZero(Day(dData),2)+"/"+StrZero(nMes,2)+"/"+StrZero(nAno,4)
dData := CtoD(cData)
		
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Ordena   ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordena os arrays e soma os salarios com mesma frequencia   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Ordena()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Ordena()
Local nx
Local nFreq:= 0, nSal:=0

aDados:= aSort(aDados,,,{|x,y| x[2] < y[2]})
    
nFreq := aDados[1][1]
nSal  := aDados[1][2]
	
For nx:=2 To Len(aDados)
	If nSal == aDados[nx][2]
		nFreq := nFreq + aDados[nx][1]			
	Else 
		Aadd(aCalculos,{nFreq,nSal,(nFreq*nSal),((nSal**2)*nFreq)})
		nFreq := aDados[nx][1]
		nSal  := aDados[nx][2]
	EndIf			
Next nx   

Aadd(aCalculos,{nFreq,nSal,(nFreq*nSal),((nSal**2)*nFreq)})

Cs050Totais()
                      
Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Totais   ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a somatoria da freq, sal, freq*sal, freq^2 * sal   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Ordena()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Totais()
Local nS1 	:= 0
Local nS2 	:= 0
Local nS3 	:= 0
Local nS4 	:= 0                    
Local nx	:= 0

aValores := {}

For nx := 1 To Len(aCalculos)
	nS1 := nS1 + aCalculos[nx][1]
	nS2 := nS2 + aCalculos[nx][2]
	nS3 := nS3 + aCalculos[nx][3]
	nS4 := nS4 + aCalculos[nx][4]
Next nx          

Aadd(aValores,nS1)
Aadd(aValores,nS2)
Aadd(aValores,nS3)
Aadd(aValores,nS4)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Calc     ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a Pesquisa Salarial                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Calc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Calc()

//aValores[1]	 Frequencia
//aValores[2]	 Remuneracao
//aValores[3]	 Frequencia * Remuneracao
//aValores[4]	(Frequencia **2)*Frequencia

Aadd(aResult,{"CSMEDIA" ,CSMEDIA(aValores[1],aValores[3])})

Aadd(aResult,{"CSVARIAN",CSVARIAN(aValores[1],aValores[3],aValores[4])})

Aadd(aResult,{"CSDESVIO",CSDESVIO(CsVerVal("CSVARIAN"))})

Aadd(aResult,{"CSCOEFIC",CSCOEFIC(CsVerVal("CSDESVIO"),CsVerVal("CSMEDIA"))})

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Corte    ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verfica os cortes definidos nos parametros                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Corte                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Corte()
Local nCoefic	:= CsVerVal("CSCOEFIC")
Local nDesvio	:= CsVerVal("CSDESVIO")
Local nMedia 	:= CsVerVal("CSMEDIA")
Local nAbaixo	:= 0
Local nAcima	:= 0
Local aAux 		:= aClone(aCalculos)
Local nx		:= 0

//PE para atribuir valor de corte com base no coeficiente de variacao
If lCSA50COR
	nVlrCorte := ExecBlock( "CSA50COR", .F., .F., {nCoefic} )
EndIf

aCalculos:={}

If cCorte ==  "01"			// Por Desvio Padrao
	nAbaixo := Round(nMedia - (nVlrCorte * nDesvio),2)		
	nAcima  := Round(nMedia + (nVlrCorte * nDesvio),2)
ElseIf cCorte == "02"			// Por %MAP
	nAbaixo := Round(nMedia - ((nVlrCorte/100) * nMedia),2)
	nAcima  := Round(nMedia + ((nVlrCorte/100) * nMedia),2)
EndIf

// Efetua o corte dos salarios que nao estao nesta faixa
For nx := 1 To Len(aAux)
	If 	(aAux[nx][2] >= nAbaixo .And.;
		aAux[nx][2] <= nAcima) .or. nVlrCorte == 0
		Aadd(aCalculos,{aAux[nx][1],aAux[nx][2],aAux[nx][3],aAux[nx][4]})
	EndIf	
Next nx                                     
                  
Cs050Totais()

// Recalcula a media de acordo com os salarios que ficaram na amostra apos o corte
aResult[1] := { "CSMEDIA", CSMEDIA(aValores[1], aValores[3]) }

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Result   ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula os resultados finais da Pesquisa Salarial          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Result                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Result()   
Local nx    	:= 0
Local ny		:= 0
Local nClasse	:= 0, nAmplit	:= 0
Local nDe		:= 0, nAte		:= 0
Local nFreq		:= 0, nFAc		:= 0
Local nD1		:= 0, nD9		:= 0, nQ1 := 0, nQ2 := 0, nQ3 := 0
Local nLi		:= 0, nFc		:= 0, nFi := 0

If Len(aCalculos) > 0
	aClasses :={}    

	// Frequencia Total
	Aadd(aResult,{"CSFREQ" ,aValores[1]})

	// Numero de Classes                           
	nClasse:= CSCLASSE(aValores[1])
	Aadd(aResult,{"CSCLASSE" ,nClasse})

	// Amplitude Amostral
	Aadd(aResult,{"CSAMPLAM" ,CSAMPLAM(aCalculos[Len(aCalculos)][2],aCalculos[1][2])})

	// Amplitude de Classe                           
	nAmplit:= CSAMPLCL(CsVerVal("CSAMPLAM"),CsVerVal("CSCLASSE"))
	Aadd(aResult,{"CSAMPLCL" ,nAmplit})
        
	// Calcula a Distribuicao de frequencia para a Amostra
	nDe := aCalculos[1][2]
	nAte:= aCalculos[1][2] + nAmplit
	For ny:=1 To nClasse
		For nx:=1 To Len(aCalculos)
			If 	aCalculos[nx][2] <= nAte .And.;
				aCalculos[nx][2] >= nDe
				nFreq := nFreq + aCalculos[nx][1]
			EndIf
		Next nx
			
		nFAc := nFAc + nFreq
		Aadd(aClasses,{nDe,nAte,nFreq,nFAc})
		nFreq:= 0
		nDe := nAte
		nAte:= nDe + nAmplit	
	Next ny   

	// 1o. Decil            
	nD1:=CSVDECIL(1,aValores[1])			// Calcula o valor do 1o Decil
	Aadd(aResult,{"CSLOCD1" ,nD1})
	Cs050Localiza(nD1,@nLi,@nFc,@nFi)		// Localiza nas classes
	Aadd(aResult,{"CSD1",CSDECIL(1,nLi,aValores[1],nFc,nAmplit,nFi)})	
                        
	// 9o. Decil              
	nD9:=CSVDECIL(9,aValores[1]) 			
	Aadd(aResult,{"CSLOCD9" ,nD9})
	Cs050Localiza(nD9,@nLi,@nFc,@nFi)		
	Aadd(aResult,{"CSD9",CSDECIL(9,nLi,aValores[1],nFc,nAmplit,nFi)})

	// 1o. Quartil                                          	
	nQ1:=CSVQUARTIL(1,aValores[1])
	Aadd(aResult,{"CSLOCQ1" , nQ1})
	Cs050Localiza(nQ1,@nLi,@nFc,@nFi)
	Aadd(aResult,{"CSQ1",CSQUARTIL(1,nLi,aValores[1],nFc,nAmplit,nFi)})

	// 2o. Quartil
	nQ2:=CSVQUARTIL(2,aValores[1])
	Aadd(aResult,{"CSLOCQ2" , nQ2})
	Cs050Localiza(nQ2,@nLi,@nFc,@nFi)
	Aadd(aResult,{"CSQ2",CSQUARTIL(2,nLi,aValores[1],nFc,nAmplit,nFi)})

	// 3o. Quartil          
	nQ3:=CSVQUARTIL(3,aValores[1])
	Aadd(aResult,{"CSLOCQ3" ,nQ3})
	Cs050Localiza(nQ3,@nLi,@nFc,@nFi)       
	Aadd(aResult,{"CSQ3",CSQUARTIL(3,nLi,aValores[1],nFc,nAmplit,nFi)})
EndIf
Return .T.              

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Localiza ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Localiza nas classes os DECIS e QUARTIS                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Localiza(nExpN1,nExpN2,nExpN3,nExpN4)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Localiza(nValor,nLi,nFc,nFi)
Local nx	:= 0

nLi:=0
nFi:=0
nFc:=0
For nx:=1 To Len(aClasses)
	If aClasses[nx][4] < nValor	
		Loop
	Else
		nLi := aClasses[nx][1]			// Limite inferior da classe
		nFi := aClasses[nx][3]			// Freq simples da classe
		If nx > 1
			nFc := aClasses[nx-1][4]	// Freq acumulada imediatamente anterior da classe
		EndIf
		Exit
	EndIf	
Next nx

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Grava    ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que grava os resultados da Pesquisa Salarial        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Grava                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Grava(cPesq,cFuncao,cRegiao,cPorte)
Local aConversao:= {}           
Local aAnterior	:= {}
Local nx		:= 0
Local ny		:= 0
Local nQuantos	:= 0
Local cVar		:= 0
Local cCodigo	:= 0
Local nPos		:= 0
Local nV1		:= 0
Local nV2		:= 0
Local nCont		:= 0    
Local aTam		:= {}
Local nTam		:= 0

For nQuantos:= 1 To 2		// 1-Valor Normal 2-Valor Normal+Adicionais
	aResult		:={}  
	aCalculos	:={}
	If nQuantos == 1
		aDados 	:= aClone(aVl1)
		Cs050Dados()									
		aR1 	:= aClone(aResult)
	Else
		aDados := aClone(aVl2)
		Cs050Dados()									
		aR2 	:= aClone(aResult)
	EndIf		

Next nQuantos	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se valores nao vao estourar tamanho do campo. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam := TamSx3("RB5_VALOR")
nTam := aTam[1] - aTam[2] - 1
For nX := 1 to Len(aR1)
	If Len(Alltrim(Str(Int(aR1[nX][2])))) > nTam 
		Aviso(OemToAnsi(STR0005), OemToAnsi(STR0006), {"Ok"})	// "Atencao"###"Valores maior que o campo, verifique o Indice utilizado na Pesquisa."
		Return .F.
	EndIf
Next nX


//Cria um array de conversao dos SX5 com as variaveis - futuramente sera um arquivo
Aadd(aConversao,{"0001","CSD1"})			// 1o Decil
Aadd(aConversao,{"0002","CSD9"})			// 9o Decil
Aadd(aConversao,{"0003","CSQ1"})			// 1o Quartil
Aadd(aConversao,{"0004","CSQ3"})			// 3o Quartil
Aadd(aConversao,{"0005","CSQ2"})			// Mediana
Aadd(aConversao,{"0006","CSMEDIA"})		// Media
Aadd(aConversao,{"0007","CSFREQ"})			// Total Frequencia
Aadd(aConversao,{"0008","CSVARIAN"})		// Variancia
Aadd(aConversao,{"0009","CSDESVIO"})		// Desvio Padrao
Aadd(aConversao,{"0010","CSCOEFIC"})		// Coeficiente Variacao
Aadd(aConversao,{"0011","CSCLASSE"})		// Nr Classes
Aadd(aConversao,{"0012","CSAMPLAM"})		// Amplitude Amostral                   	
Aadd(aConversao,{"0013","CSAMPLCL"})		// Amplitude Classe

//Gravar no RB5
dbSelectArea("RB5")
dbSetOrder(1)
If dbSeek(xFilial("RB5")+cPesq)
	While !Eof() .And. xFilial("RB5")+cPesq+cFuncao+cRegiao+cPorte ==;
			    	RB5->RB5_FILIAL+RB5->RB5_PESQ+RB5->RB5_FUNCAO+RB5->RB5_REGIAO+RB5->RB5_PORTE
			    	
		Aadd(aAnterior,RecNo())
		dbSkip()			    	
	EndDo		    	
EndIf                    

For nx:=1 To Len(aR1)

	cVar := aR1[nx][1]			// Nome da variavel
	nV1	 := aR1[nx][2]			// Valor
	
	// Buscar os Valores Adicionais do Resultado da Pesquisa	        
	nPos := 0
	nPos := Ascan(aR2,{|x| x[1] == cVar})
	If nPos > 0
		nV2 := aR2[nPos][2]
	EndIf
	
	// Buscar no array de conversao para gravar os resultados	
	nPos := 0
	nPos := Ascan(aConversao,{|x| x[2] == cVar})
	If nPos > 0
		cCodigo:= aConversao[nPos][1]
	Else
		Loop
	EndIf                               
	        
	nCont := nCont + 1
	
	If nCont <= Len(aAnterior)
		dbGoto(aAnterior[nCont])
		RecLock("RB5",.F.)
	Else
		RecLock("RB5",.T.)
		Replace RB5_FILIAL		With 	xFilial("RB5")
		Replace RB5_PESQ		With	cPesq
		Replace RB5_FUNCAO		With	cFuncao
		Replace RB5_PORTE		With	cPorte
	EndIf

	Replace RB5_REGIAO		With 	cRegiao
	Replace RB5_CORTE		With    cCorte
	Replace RB5_VLCORTE		With    nVlrCorte
	Replace RB5_CODVL		With	cCodigo
	Replace RB5_VALOR		With	nV1
	Replace RB5_VLOUTROS	With	nV2
	Replace RB5_TIPO		With 	"G"

	MsUnlock()

Next nx                  

// Limpa os arrays dos resultados
aVl1:={}
aVl2:={}              
aCalculos := {}

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Cs050Param    ³ Autor ³ Cristina Ogura   ³ Data ³ 29/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla os parametros do SX1                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cs050Param()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ nEstou 1-Corte 2-Moeda                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAM050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Cs050Param(nEstou)
Local cTitulo 	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local oWnd
Local aArray	:= {}
Local i			:= 0
Local nTam		:= 0
Local aSaveArea := GetArea()

oWnd 	:= GetWndDefault()
MvPar	:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
MvRet	:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

If nEstou == 1		// Corte
	nTam := 2
	dbSelectArea("SX5")
	If dbSeek(cFilial+"00RG")
		cTitulo := Alltrim(Left(X5Descri(),20))
	EndIf
	If dbSeek(cFilial+"RG")
		While !Eof() .And. SX5->X5_TABELA == "RG"
			Aadd(aArray,Alltrim(X5Descri()))
			MvParDef:=MvParDef+Left(SX5->X5_CHAVE,2)
			dbSkip()
		Enddo
	Else
		Help(" ",1,"CS050NDEF") 		// Defina a tabela de Corte para pesquisa
		Return .F.
	Endif
ElseIf nEstou == 2                                           
	nTam   := 1
	cTitulo:= STR0003					// "Moedas do Sistema"
	For i:=1 To 5
		cMoeda := "MV_MOEDA"+Str(i,1)
		Aadd(aArray,Alltrim(GETMV(cMoeda)))
		MvParDef:=MvParDef+Str(i,1)
	Next i
EndIf	

f_Opcoes(@MvPar,cTitulo,aArray,MvParDef,12,49,.T.,nTam) 	// Chama funcao f_Opcoes
&MvRet := mvpar										    	// Devolve Resultado

RestArea(aSaveArea)

If oWnd != Nil
	GetdRefresh()
Endif

Return .T.

Static Function Cs050Ok()
Return (MsgYesNo(OemToAnsi(STR0004),OemToAnsi(STR0005))) //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"
