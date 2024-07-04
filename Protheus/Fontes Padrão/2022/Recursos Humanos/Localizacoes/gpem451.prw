#INCLUDE "PROTHEUS.CH"
#include "gpem451.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM451  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 21/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Planilha de contribuicao de Ips em disco                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAGPE - Gestao de Pessoal                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³Chamado³ Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Allyson M   ³23/10/14³TQUTNT ³Ajuste na validacao do campo RA_TPOCUP.  ³±±
±±³LuisEnríquez³11/01/17³SERINN001-860³-Se realiza merge para hacer cambio³±±
±±³            ³        ³             ³ cen creación de tablas temporaless³±±
±±³            ³        ³             ³ CTREE.                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPEM451()

Local nOpca := 0
Local aSays := { }, aButtons := { }		// arrays locais de preferencia

Private cCadastro := OemToAnsi(STR0001)		// Geracao de Ips em disco
Private cFilDe, cFilAte, cCCDe, cCCAte, cMatDe, cMatAte, cFile, cDeMa,cNomeDe,cNomeAte
Private oTmpTable := Nil
Private aOrdem := {}

Pergunte("GPM451",.F.)

AADD(aSays,OemToAnsi(STR0002) )  //"Este programa tem o objetivo de gerar a planilha de Ips em disco."
AADD(aSays,OemToAnsi(STR0003) )  //""

AADD(aButtons, { 5,.T.,{|| Pergunte("GPM451",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	Processa({|lEnd| G451Proc(),OemToAnsi(STR0004)})  //"Geracao de Ips em disco"
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³G451Proc  ºAutor  ³Sergio S. Fuzinaka  º Data ³  21/01/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Processamento                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM451()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G451Proc()

Local nDeMA, cPeriodo, nPeriodo
Local cTpLicenc := ""
Local cSituacao := ""
Local cNome     := ""
Local cSobreNom := ""
Local nDiasTrab := 0
Local cDiasTrab := ""   
Local cSalario := 0  
Local nSalario	:= 0  
Local nPerIni   := 0
Local nPerFim	:= 0
Local lFerias, lAfast
Local nDiasCorr := 0                        
Local cNumPat, cTpOcup
Local aOrdBag     := {}
Local cArqMov     := ""
Local dDataRef
Local lProcessa	:=	.T.
Local lTpOcup	:= SRA->( FieldPos( "RA_TPOCUP" ) ) != 0

Private aCodFol := {}
Private cAliasMov := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  De  Filial                               ³
//³ mv_par02        //  Ate Filial                               ³
//³ mv_par03        //  De  Centro Costo                         ³
//³ mv_par04        //  Ate Cemtro Costo                         ³
//³ mv_par05        //  De  Matricula                            ³
//³ mv_par06        //  Ate Matricula                            ³
//³ mv_par07        //  Nome De                                  ³
//³ mv_par08        //  Nome Ate                                 ³
//³ mv_par09        //  Arquivo de Saida                         ³
//³ mv_par10        //  Data de Referencia                       ³
//³ mv_par11        //  Ordem                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFilDe  	:= mv_par01		
cFilAte 	:= mv_par02    
cCCDe		:= mv_par03
cCCAte	:= mv_par04  
cMatDe  	:= mv_par05
cMatAte 	:= mv_par06
cNomeDe  := mv_par07
cNomeAte := mv_par08
cFile   	:= mv_par09       
cDeMA   	:= mv_par10
nOrdem   := mv_par11


dDataRef	:=	CToD(  "01/"+Substr(cDeMa,1,2)+"/"+ Substr(cDeMa,3,4) )

FP_CodFol(aCodFol)		//--- Carrega as verbas da folha de pagamento

G451Cria()				//--- Cria arquivo temporario

lQuery	:=	.F.
#IFDEF TOP
	If TcSrvType() != "AS/400"
		lQuery	:=.T.
	Endif
#ENDIF	
If lQuery
	cQuery := "SELECT COUNT(*) TOTAL "
	cQuery += "  FROM "+	RetSqlName("SRA")
	cQuery += " WHERE RA_FILIAL  between '" + cFilDe + "' AND '" + cFilAte + "'"
	cQuery += "   AND RA_MAT     between '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "   AND RA_CC      between '" + cCcDe  + "' AND '" + cCcate  + "'"
	cQuery += "   AND D_E_L_E_T_ <> '*' "		
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QUERY', .F., .T.)
	dbSelectArea("QUERY")
	nTotalQ := QUERY->TOTAL
	ProcRegua(nTotalQ)		// Total de Elementos da regua	
	QUERY->(dbCloseArea())
	dbSelectArea("SRA")		

	cQuery := "SELECT * "		
	cQuery += "  FROM "+	RetSqlName("SRA")
	cQuery += " WHERE RA_FILIAL  between '" + cFilDe + "' AND '" + cFilAte + "'"
	cQuery += "   AND RA_MAT     between '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "   AND RA_CC      between '" + cCcDe  + "' AND '" + cCcAte  + "'"
	cQuery += "   AND D_E_L_E_T_ <> '*' "		
	If nOrdem == 1
		cQuery += " ORDER BY RA_FILIAL, RA_MAT"
	Else
		cQuery += " ORDER BY RA_FILIAL, RA_NOME, RA_MAT"
	Endif	
	SRA->(dbCloseArea())
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SRA', .F., .T.)
	TCSetField("SRA","RA_ADMISSA","D",8,0)
	TCSetField("SRA","RA_DEMISSA","D",8,0)	
Else
	//--- Seleciona o arquivo de funcionarios
	dbSelectArea( "SRA" )
	ProcRegua(SRA->(RecCount()))
	If nOrdem == 1
		dbSetOrder( 1 )
	ElseIf nOrdem == 2
		dbSetOrder(3)
	Endif

	dbGoTop()

	If nOrdem == 1
		dbSeek(cFilDe + cMatDe,.T.)
		cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
		cFim    := cFilAte + cMatAte
	ElseIf nOrdem == 2
		DbSeek(cFilDe + cNomeDe + cMatDe,.T.)
		cInicio := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
		cFim    := cFilAte + cNomeAte + cMatAte
	Endif
Endif

nDeMA  := Val(Right(cDeMA,4)+Left(cDeMA,2))
dDataAte := CTOD("01/"+Left(cDeMA,2)+"/"+Right(cDeMA,4))

SRX->(dbsetorder(1))
If FPHIST82( xFilial("SRX") , "99") 
   cNumPat := SubStr ( SRX->RX_TXT ,  1 , 10 ) 
Else
	Help(" ",1,"NUMPATRINV")
	lProcessa	:=	.F.
Endif

While lProcessa	.And.	!Eof() .And. ( SRA->RA_FILIAL >= cFilDe .And. SRA->RA_FILIAL <= cFilAte )

	IncProc(OemToAnsi(STR0005))		//--- Gerando Planilha de Pago

	If !lQuery
		If SRA->RA_FILIAL <> cFilDe
			cFilDe := SRA->RA_FILIAL
			dbSeek( cFilDe + cMatDe, .T. )
		Endif                      
	Endif

	If	(SRA->RA_FILIAL < cFilDe .Or. SRA->RA_FILIAL > cFilAte ) .Or. ;
	   (SRA->RA_MAT < cMatDe)    .Or. (SRA->Ra_MAT > cMatAte)    .Or. ;
	   (SRA->RA_NOME < cNomeDe)  .Or. (SRA->Ra_NOME > cNomeAte)  .Or. ;
	   (SRA->RA_CC < cCcDe)      .Or. (SRA->Ra_CC > cCcAte)
		SRA->(dbSkip(1))
		Loop
	EndIf

	cPeriodo  := Str(nDeMA,6)
	nPeriodo  := Val(cPeriodo)                           
   cSalario  := 0   
   nSalario  := 0 
   nDiasTrab := 0
	cDiasTrab := ""
	
	//--- Sobrenome do Funcionario
	cSobreNom := Alltrim(Left(SRA->RA_NOME,At(",",SRA->RA_NOME)-1))
	cSobreNom += Space(30-Len(cSobreNom))

	//--- Nome do Funcionario
	cNome     := Alltrim(StrTran(Substr(SRA->RA_NOME,At(",",SRA->RA_NOME)+1),",",""))
	cNome     += Space(30-Len(cNome))
		
   SR8->(dbSelectArea("SR8"))
   SR8->(dbSetOrder(1))

	If SR8->(dbSeek(xFilial("SR8")+SRA->RA_MAT))
		While !Eof() .And. SR8->R8_FILIAL+SR8->R8_MAT == SRA->RA_FILIAL+SRA->RA_MAT		
			nPerIni := Val(MesAno(SR8->R8_DATAINI))
			nPerFim := Val(MesAno(SR8->R8_DATAFIM))
			If nPeriodo >= nPerIni .And. nPeriodo <= nPerFim
				If SR8->R8_TIPO == "F"
					lFerias := .T.
			   Else
			   	lAfast := .T.
			   Endif							
			Endif			
			dbSelectArea("SR8")			
			dbSkip()
		Enddo
   Endif
     	
   cTpLicenc := SRA->RA_SITFOLHA
   If !Empty(cTpLicenc)      
		Do Case
			Case cTpLicenc == "F" .and. lFerias
				cSituacao := "03"
			Case cTpLicenc == "D" .And. MesAno(SRA->RA_DEMISSA) == cPeriodo	 // Demissao
				cSituacao := "02"
			Case cTpLicenc == "A"  .and. lAfast // Afastamento
				cSituacao := "04"	
			Otherwise 
			   cSituacao := "00"   // Outras Causas
		EndCase
	Else		
		If MesAno(SRA->RA_ADMISSA) == cPeriodo			
			cSituacao := "01"			// Admissao
		Else
			cSituacao := "00"			// Normal
		Endif
	Endif
	
	If cTpLicenc $ "D" .And. Mesano(SRA->RA_DEMISSA) < cPeriodo
		SRA->(dbSkip())
		Loop
	Endif

	//--- Salario do Funcionario 
 	dbSelectArea("SRC")
	dbSetOrder(1)
	If SRC->(dbSeek(xFilial("SRC")+SRA->RA_MAT))
		While !Eof() .And. (SRA->RA_FILIAL+SRA->RA_MAT == SRC->RC_FILIAL+SRC->RC_MAT)
	  		If cSituacao $ "00|01|04"
     	  		If SRA->RA_CATFUNC $ "M*C*D" .And. SRA->RA_TIPOPGT = "M" .And. SRC->RC_PD == aCodFol[031,1]
	         	nSalario   := SRC->RC_VALOR
		     		cDiasTrab	:= StrZero(SRC->RC_HORAS,2)
 	  			Elseif SRA->RA_CATFUNC $ "P" .And. SRA->RA_TIPOPGT = "M" .And. SRC->RC_PD == aCodFol[217,1]
	        		nSalario   := SRC->RC_VALOR
		     		cDiasTrab	:= StrZero(SRC->RC_HORAS,2)
 	  			Elseif SRA->RA_CATFUNC $ "A" .And. SRA->RA_TIPOPGT = "M" .And.SRC->RC_PD == aCodFol[218,1]
	         	nSalario   := SRC->RC_VALOR
	  	  			cDiasTrab	:= StrZero(SRC->RC_HORAS,2)
	  			Elseif SRA->RA_CATFUNC $ "E" .And. SRA->RA_TIPOPGT = "M" .And. SRC->RC_PD ==aCodFol[219,1]
	        		nSalario   := SRC->RC_VALOR
		     		cDiasTrab	:= StrZero(SRC->RC_HORAS,2)
		   	Elseif SRA->RA_CATFUNC $ "H" .And. SRA->RA_TIPOPGT = "M" .And. SRC->RC_PD == aCodfol[32,1]
		        	nSalario   := SRC->RC_VALOR
					nDiasTrab := Int(SRC->RC_HORAS/(SRA->RA_HRSMES/30))
					cDiasTrab := StrZero(nDiasTrab,2)		
				Elseif SRA->RA_CATFUNC $ "G" .And. SRA->RA_TIPOPGT = "M" .And. SRC->RC_PD == aCodfol[220,1]
		        	nSalario   := SRC->RC_VALOR
		     		cDiasTrab	:= StrZero(SRC->RC_HORAS,2)
		  		EndIf
   	  	ElseIf cSituacao == "02"   
   	  		If SRC->RC_PD == aCodFol[048,1]     	  			//Saldo de Salario
		     	  	nSalario   := SRC->RC_VALOR 
		     		cDiasTrab	:= StrZero(SRC->RC_HORAS,2)
	     	  	ElseIf SRC->RC_PD == aCodFol[072,1] .or. SRC->RC_PD == aCodFol[087,1] //Ferias
		        	nSalario   := SRC->RC_VALOR
    	  	  	ElseIf SRC->RC_PD == aCodFol[111,1]  				//Aviso Previo
		        	nSalario   := SRC->RC_VALOR
    		  	ElseIf SRC->RC_PD == aCodFol[110,1]  				//Indenizacion
		     	  	nSalario   := SRC->RC_VALOR
	     	   Endif
   		ElseIf cSituacao == "03"   
				If SRA->RA_CATFUNC $ "M*C*D"  .And. SRC->RC_PD == aCodFol[072,1] //Ferias
		        	nSalario   := SRC->RC_VALOR
		  			cDiasTrab	:= StrZero(SRC->RC_HORAS,2)
				Endif
    	  	Endif   
		 	dbSelectArea("SRC")
		   dbSkip()
		Enddo
	Endif                                           

	//--- Salario do Funcionario no Cadastro
	If nSalario > 0
		If cSituacao == "02"   
	      nSalario += If(nSalario > 0,nSalario,0)
	   Endif
	   cSalario := StrZero(Val(StrTran(Str(nSalario,12,2),".","")),10)
		LocGHabRea( Ctod("01/"+Substr(cDeMA,1,2)+"/"+right(cDeMa,2),"ddmmyy"),;
						Ctod(StrZero(F_ULTDIA(dDataAte),2)+"/"+Substr(cDeMA,1,2)+"/"+right(cDeMa,2),"ddmmyy"),;
						@nDiasTrab,@nDiasCorr) 
		cDiasTrab := StrZero(nDiasTrab,2)
	Else
		cSalario := StrZero(Val(StrTran(Str(cSalario,12,2),".","")),10)
		cDiasTrab:= StrZero(nDiasTrab,2)
	Endif
	If lTpOcup
		cTpOcup := If( SRA->RA_TPOCUP $ "12", "E", "O") 	
	Else
	   cTpOcup := "E"
	Endif
	If Val(cSalario) > 0 .Or. mv_par12 == 1   
		dbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->N_PATRONAL := StrZero(Val(cNumPat),10)
		TRB->N_SEGURO   := StrZero(Val(SRA->RA_CIC),10)
		TRB->N_CEDULA   := StrZero(Val(SRA->RA_RG),10)
		TRB->APELLIDO   := cSobreNom
		TRB->NOMBRE     := cNome
		TRB->CATEGORIA  := cTpOcup
		TRB->DIAS_TRAB  := cDiasTrab
		TRB->SALARIO    := cSalario
		TRB->PAGO_MA    := Right(cPeriodo,2)+Left(cPeriodo,4)
		TRB->COD_ACTIV  := cSituacao
		TRB->TEXTO      := (StrZero(Val(cNumPat),10)				+;
									StrZero(Val(SRA->RA_CIC),10)			+;
									StrZero(Val(SRA->RA_RG),10)			+;
									cSobreNom									+;
									cNome											+;
									cTpOcup                        		+;
									cDiasTrab									+;
									cSalario										+;
									Right(cPeriodo,2)+Left(cPeriodo,4)	+;
									cSituacao							 )
		MsUnlock()
	Endif
	nDeMA++
	nDeMA := Val(Right(cDeMA,4)+Left(cDeMA,2))
	dbSelectArea("SRA")
	dbSkip()
Enddo
  
If TRB->(RecCount()) > 0  
	G451Gera(cFile)                     // Gera arquivo texto
Else
	MsgStop(OemToAnsi(STR0008)+cFile)	// "Nao foi gerado o arquivo "
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona arq. defaut do Siga caso Imp. Mov. Anteriores      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cAliasMov )
	fFimArqMov( cAliasMov , aOrdBag , cArqMov )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRC")
dbSetOrder(1)          // Retorno a ordem 1

dbSelectArea("TRB")
dbCloseArea()

If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil 
EndIf

If lQuery
	DbSelectArea("SRA" )
	DbCloseArea()
Endif

DbSelectArea("SRA" )
DbSetOrder(1)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³G451Cria  ³ Autor ³ Sergio S. Fuzinaka    ³ Data ³ 21/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivo temporario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GPEM451() 												  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G451Cria()

Local aStru    := {}

aStru := {{"N_PATRONAL"  , "C" , 010 , 0 },;		// Numero Patronal
			{"N_SEGURO"    , "C" , 010 , 0 },;		// Numero do Seguro del Asegurado
			{"N_CEDULA"    , "C" , 010 , 0 },;		// Cedula de Identidad Policial Asegurado
			{"APELLIDO"    , "C" , 030 , 0 },;		// Apellidos Asegurado
			{"NOMBRE"      , "C" , 030 , 0 },;		// Nombre Asegurado
			{"CATEGORIA"   , "C" , 001 , 0 },;		// Categoria - Jefe y Empleado="E" o Obrero="O"
			{"DIAS_TRAB"   , "C" , 002 , 0 },;		// Dias trabajados
			{"SALARIO"     , "C" , 010 , 0 },;		// Salario
			{"PAGO_MA"     , "C" , 006 , 0 },;		// Mes-Ano de Pago - MMAAAA
			{"COD_ACTIV"   , "C" , 002 , 0 },;		// Codigo de Actividad
			{"TEXTO"       , "C" , 111 , 0 } }		// Texto a ser impresso no arquivo

			oTmpTable := FWTemporaryTable():New("TRB")
			oTmpTable:SetFields( aStru )
			aOrdem	:=	{"N_PATRONAL"}  
			oTmpTable:AddIndex("IN1", aOrdem)
			oTmpTable:Create()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ G451Gera     ³ Autor ³ Sergio S. Fuzinaka ³ Data ³ 21/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que gera arquivo texto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM451()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G451Gera(cFile)

cFile:=Alltrim(cFile)
If File(cFile) .And. !MsgYesNo(OemToAnsi(STR0009+CRLF+STR0010) )
	Return
Endif
nHandle := MSFCREATE(cFile)

If FERROR() # 0 .Or. nHandle < 0
	MsgStop(OemToAnsi(STR0007)+cFile)		//"Erro na criacao do arquivo "
	FClose(nHandle)
	Return Nil
EndIf

dbSelectArea("TRB")
dbGoTop()

While !Eof()
	FWrite(nHandle,TRB->TEXTO+CRLF)    
	dbSkip()
EndDo
FClose(nHandle)

MsgInfo(OemToAnsi(STR0011))

Return Nil

