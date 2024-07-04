#INCLUDE "HSPAHRC4.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TopConn.ch"
#define ESC          27
#define TRACE        repl("_",220)
#define TRACEDUPLO   repl("=",220)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRC4  º Autor ³ MARCELO JOSE       º Data ³  12/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MAPA DE DIETA                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHRC4(cVemPar)

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"M A P A   D E  D I E T A S"
Local nLin           := 80        
                      /*              				   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                                   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
Local Cabec1         := STR0004 //"Quarto Leito Nome                            Idade       Diagnostico                                         Dieta                           Complemento                     Data     Hora  Observacao "
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd := {}

Private cMVPAR01     := cVemPar
Private cMVPAR02     := cVemPar
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "G"
Private nomeprog     := "HSPAHRC4" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRC4" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cString      := "GAV"
Private cPerg        := "HSPRC4"
Private aVetor       := {}

HS_PosSX1({{"HSPRC4","01",cVemPar},{"HSPRC4","02",cVemPar}}) 

If !Pergunte(cPerg,.T.)
 FS_FilRC4()
	return(NIL)
EndIf
CMVPAR01 := MV_PAR01
CMVPAR02 := MV_PAR02

If MV_PAR03 == 1
 HS_DtvFilt("GAV")
EndIf
 
Processa({|| HS_MontaM()})

/* Monta a interface padrao com o usuario... */
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == ESC
 FS_FilRC4()
	Return(Nil)
Endif

SetDefault(aReturn,cString)

If nLastKey == ESC
 FS_FilRC4()
	Return(Nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

/* Processamento RPTSTATUS monta janela com a regua de processamento. */
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
FS_FilRC4()
Return(Nil)                                      



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Funcao HS_MontaM() monta matriz                                         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function HS_MontaM()
 Local _sAlias := "", cRegAte := "" , nMaisuma := 0 , cCodLoc := "", aIdade := {}
 dbSelectArea("GAV")
 dbSetOrder(1)

 /* SETREGUA -> Indica quantos registros serao processados para a regua */
 ProcRegua(RecCount())
 DbGoTop()  
 dbSeek(xFilial("GAV")+MV_PAR01)
 While !Eof() .And. GAV->GAV_FILIAL == xFilial("GAV") .And. GAV->GAV_CODLOC <= MV_PAR02
 
  If MV_PAR03 == 2
   If Empty(GAV->GAV_REGATE)
    DbSkip()
    Loop
   EndIf
  EndIf
 
   IncProc(STR0007+" - Quarto "+GAV->GAV_QUARTO) //"Aguarde, processando dados"
 
   cCodCid := POSICIONE("GCY",1,XFILIAL("GCY")+GAV->GAV_REGATE,"GCY_CIDINT") 
   cCodReg := POSICIONE("GCY",1,XFILIAL("GCY")+GAV->GAV_REGATE,"GCY_REGGER")
   dNasc   := Posicione("GBH",1,xFilial("GBH")+cCodReg, "GBH_DTNASC")  
   
   aIdade := HS_DIFDATA(dNasc, DDATABASE)
   
   cId := Str(aIdade[1], 3, 0) + "a" + Str(aIdade[2], 2, 0) + "m" + Str(aIdade[3], 2, 0) + "d"
  
   Aadd(aVetor,{"","","","","","","","","","","",""})
   aVetor[len(aVetor),1] := GAV->GAV_CODLOC
   aVetor[len(aVetor),2] := GAV->GAV_QUARTO                                                            
   aVetor[len(aVetor),3] := GAV->GAV_LEITO
   aVetor[len(aVetor),4] := GAV->GAV_NOME
   aVetor[len(aVetor),11]:= cId
   aVetor[len(aVetor),12]:= Posicione("GAS",1,xFilial("GAS")+cCodCid,"GAS_PATOLO")	   
   cRegAte := GAV->GAV_REGATE
   cCodLoc := GAV->GAV_CODLOC
   _sAlias := Alias()

   dbSelectArea("GDY") 
   dbSetOrder(1)
   If dbSeek(xFilial("GDY")+cRegAte)
    Do While !Eof() .And. GDY->GDY_REGATE == cRegAte 
   
     If GDY->GDY_ATIVO # "1"
      DbSkip()
      Loop
     EndIf
    
     If nMaisuma > 0
   	  Aadd(aVetor,{"","","","","","","","","","","",""})
     EndIf
     aVetor[len(aVetor), 1] := GAV->GAV_CODLOC
     aVetor[len(aVetor), 6] := POSICIONE("SX5",1,XFILIAL("SX5")+"TE"+GDY->GDY_CODDIE,"X5_DESCRI")
     aVetor[len(aVetor), 7] := SUBSTR(GDY->GDY_OBSERV, 1, 40) 
     aVetor[len(aVetor), 8] := DtoC(GDY->GDY_DATDIE)
     aVetor[len(aVetor), 9] := GDY->GDY_HORDIE
     aVetor[len(aVetor),10] := GDY->GDY_COMPLE  
       
     nMaisuma++ 
    DbSkip()
    EndDo
   Endif
   nMaisuma := 0
   DbSelectArea(_sAlias)

   dbSkip() 
 EndDo
 FS_FilRC4()
Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      RUNREPORT(                                                         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

 Local nTotal := 0, nCodVer := "", nCtaFor := 0, nTotDie:=0    
 Private cData:="", cPac:=""

 If nLin > 55 /*Impressao do cabecalho do relatorio. Salto de Página. Neste caso o formulario tem 55 linhas... */
 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
 	nLin := 8
 Endif

 For nCtaFor := 1 To LEN(aVetor)  // loop  para impressao do relatorio ***********************************
	
 	If lAbortPrint
	 	@nLin,00 PSAY STR0008 //"INTERROMPIDO PELO USUARIO..."
	 	Exit
	 Endif     /* Verifica o cancelamento pelo usuario... */
	
	 If nLin > 55 /*Impressao do cabecalho do relatorio. Salto de Página. Neste caso o formulario tem 55 linhas...*/
	 	@ nLin,01 Psay STR0009              //"continua..."
	 	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	 	nLin := 8
  	If nCodVer == aVetor[nCtaFor,1]
	 		@ nLin,00 Psay STR0010 + aVetor[nCtaFor,1] + " - " + POSICIONE("GCS",1,XFILIAL("GCS")+ aVetor[nCtaFor,1],"GCS_NOMLOC") //"...continuacao de    "
	 		nLin+= 2
	 	Endif
	 Endif
	
	 If Len(aVetor) >= 1
	  If nCtaFor == 1 .OR. nCodVer != aVetor[nCtaFor,1]
	   If nCtaFor > 1
	    nLin++
	   Endif
	  	@ nLin,00 Psay STR0011 + aVetor[nCtaFor,1] + space(2) + POSICIONE("GCS",1,XFILIAL("GCS")+ aVetor[nCtaFor,1],"GCS_NOMLOC") //"==> SETOR : "
	 	 nCodVer := aVetor[nCtaFor,1]
	 	 nLin+= 2
   ENDIF
  ENDIF 
  
     
  If cData<>aVetor[nCtaFor,8] .AND. !Empty(aVetor[nCtaFor,6]) 
	   If !Empty(cData)  
	     nLin++
	     @ nLin,000 Psay STR0012 + TRANSFORM(nTotDie,"9999")//"TOTAL DE DIETAS:"
	     nLin++               
	     @ nLin,000 Psay TRACE
	     nLin++
	     nTotDie:=0   
	     cData:=aVetor[nCtaFor,8]    
	     If !Empty(aVetor[nCtaFor,4])
	       nLin++
	     Endif  
	   Endif     
	 ElseIf cData<>aVetor[nCtaFor,8] .AND. Empty(aVetor[nCtaFor,6]) 
	   If !Empty(cData)  
	     nLin++
	     @ nLin,000 Psay STR0012 + TRANSFORM(nTotDie,"9999")//"TOTAL DE DIETAS:"
	     nLin++   
	     @ nLin,000 Psay TRACE
	     nLin++

	     nTotDie:=0   
	     cData:=aVetor[nCtaFor,8]    
	     If !Empty(aVetor[nCtaFor,4])
	       nLin++
	     Endif  
	   Endif 
	 ElseIf !Empty(aVetor[nCtaFor,4]) .AND. !Empty(aVetor[nCtaFor,6])
	   If cPac<>aVetor[nCtaFor,4] 
	     nLin ++
	     @ nLin,000 Psay STR0012 + TRANSFORM(nTotDie,"9999")//"TOTAL DE DIETAS:" 
	     nLin ++
	     @ nLin,000 Psay TRACE
	     nLin +=2   
	     nTotDie:=0   
	     cData:=aVetor[nCtaFor,8]    
	   Endif  
	 Endif
	 	 
	 @ nLin,000 Psay PADR(aVetor[nCtaFor,2],4)
	 @ nLin,007 Psay PADR(aVetor[nCtaFor,3],4)
	 @ nLin,013 Psay PADR(aVetor[nCtaFor,4],30)
	 @ nLin,044 Psay PADR(aVetor[nCtaFor,11],10)
  @ nLin,057 Psay PADR(aVetor[nCtaFor,12],50)
  @ nLin,109 Psay PADR(aVetor[nCtaFor,6],30)
	 @ nLin,141 Psay PADR(aVetor[nCtaFor,10],30)
	 @ nLin,173 Psay aVetor[nCtaFor,8]
	 @ nLin,182 Psay aVetor[nCtaFor,9]
	 @ nLin,188 Psay SUBSTR(aVetor[nCtaFor,7],1,30)   
  nLin++
	 nTotal++ 
	 If !Empty(aVetor[nCtaFor,6])
   nTotDie++   
  Endif
	
		cData:=aVetor[nCtaFor,8]  
  
  If !Empty(aVetor[nCtaFor,4])
    cPac:=aVetor[nCtaFor,4]
  Endif  
    
 next  

  nLin++ 
  @ nLin,000 Psay STR0012 + TRANSFORM(nTotDie,"9999")//"TOTAL DE DIETAS:" 
  nLin++ 
  @ nLin,000 Psay TRACE
	 
 SET DEVICE TO SCREEN

 If aReturn[5]==1
 	dbCommitAll()
	 SET PRINTER TO
	 OurSpool(wnrel)
 Endif

 MS_FLUSH()

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±      ATIVA FILTRO DO BROWSE                                             ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS_FilRC4()

 dbSelectArea("GAV")
 dbSetOrder(1)
 HS_DtvFilt("GAV")
 HS_AtvFilt("GAV", "(GAV->GAV_STATUS == '1' .or. GAV->GAV_STATUS == '5')" +  IIF(Empty(cMVPAR01), "", " .and. GAV->GAV_CODLOC >= '" +cMVPAR01+ "'  .and. GAV->GAV_CODLOC <= '" +cMVPAR02+ "'") )
 DBGOTOP()
Return(Nil)  
