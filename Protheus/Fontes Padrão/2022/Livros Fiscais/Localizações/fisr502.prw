#INCLUDE "PROTHEUS.CH"
#INCLUDE "Fisr502.CH"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma. ³Fisr502   º Autor ³                      º Fecha³  30/10/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescripcio³ Listado de Libro Compras y Ventas                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fisr502()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracion de Variables                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aOrd := {}
Local cDesc1         := STR0001
Local cDesc2         := STR0002//"de acuerdo con los parámetros informados por el usuario."
Local cDesc3         := STR0003//"LIBRO DE COMPRAS IVA" //Ley 125 / 91
lOCAL cDesc4         := STR0004//"LIBRO DE VENTAS IVA"
Local cPict          := ""
Local cTitulo        := STR0003//"LIBRO DE COMPRAS IVA"//"Libro de Compras - Ley 125 / 91"
Local cTitulv        := STR0004//"LIBRO DE VENTAS IVA"
Local nLin           := 75
Local Cabec1       	:=	" Nº  |    FECHA  |     R.U.C.     |                                    |    DOCUMENTO       |IMPORTE TOTAL FATURADO|              IMPORTES GRAVADOS DIFERENCIADOS POR TASAS DEL IVA                  |IMPORTES NO GRAVADOS|
Local Cabec2       	:=	"     | D / M / A | DEL PROVEEDOR  | RAZON SOCIAL                       | TIPO |Nº           |   COM IVA INCLUIDO   |  IMP SIN IVA 10%   | CREDITO FISCAl 10% |  IMP SIN IVA 5%   | CREDITO FISCAL 5% |     O EXENTOS      |
Local Cabec3       	:=	" Nº  |    FECHA  | RUC O CEDULA   |                                    |    DOCUMENTO       |IMPORTE TOTAL FATURADO|              IMPORTES GRAVADOS DIFERENCIADOS POR TASAS DEL IVA                  |  IMPORTES EXENTOS  |
Local Cabec4       	:=	"     | D / M / A | DEL COMPRADOR  | RAZON SOCIAL                       | TIPO |Nº           |   COM IVA INCLUIDO   |  IMP SIN IVA 10%   | CREDITO FISCAl 10% | IMP SIN IVA 5%    | CREDITO FISCAL 5% |       OTROS        |
Local imprime        := .T.  

Private cString
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "Fisr502" 
Private nTipo        := 15
Private aReturn      := { STR0005, 1,STR0006, 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "FISR502"+Space((Len(SX1->X1_GRUPO)-6))
Private m_Pag        := 01
Private wnrel        := "Fisr502" 
Private nBas5        := 0, nVal5:= 0, nExentas:=0, nImport:= 0, nTotal := 0	// Sumadores de Linea
Private nBas10       := 0, nVal10:= 0
Private nTBas5       := 0, nTVal5:= 0, nTotExe:= 0, nTotImp:= 0, nTotTot:= 0	// Sumadores de Pagina
Private nTBas10      := 0, nTVal10:= 0
Private nTGBas5      := 0, nTGVal5:= 0, nGenExe:= 0, nGenImp:= 0, nGenTot:= 0	// Sumadores Generales
Private nTGBas10     := 0, nTGVal10:= 0
Private cFactura     := "", dFecha                                              // Numero factura - Fecha de factura
Private lPrimero     := .T., lSalto := .F. 
Private lTodo        := .F.
Private nBa5Ant      := 0
Private nTVa5Ant     := 0
Private nTBa10Ant    := 0
Private nTVa10Ant    := 0
Private nTExeAnt     := 0
Private nTotAnt      := 0
Private nNumero      := 1
Private nRGcombo:=0
Private lAutomato 	:= IsBlind()
Private cRUC 		:=""

If !lAutomato
	AjustaSX1()
	Pergunte(cPerg,.T.)
	IF VALTYPE(MV_PAR17) == "N"
		nRGcombo:=MV_PAR17
	ELSE
		nRGcombo:=VAL(MV_PAR17)
	ENDIF

	IF  nRGcombo==2
		IF SubStr(DTOS(MV_PAR01),1,4)!= SubStr(DTOS(MV_PAR02),1,4)
			Help(NIL, NIL,STR0019, NIL, STR0020, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0021})
			RETURN .F.
		ENDIF
		IF  VAL(MV_PAR18)<=0
			Help(NIL, NIL, STR0022, NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024})
			RETURN .F.
		ENDIF
		IF Empty(MV_PAR19) 
			Help(NIL, NIL, STR0025, NIL, STR0026, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027})
			RETURN .F.
		ENDIF
	EndIf


If MV_PAR04 == 2 .And. MV_PAR16 == 1
	cTitulo := STR0007	
Elseif MV_PAR04 == 2 .And. MV_PAR16 == 2
	cTitulv := STR0008
EndIF

If AllTrim(MV_PAR07) <> ""
	m_Pag  := AllTrim(MV_PAR07)
EndIf	

If  MV_PAR16 == 1
	wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.F.)
Else
	wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulv,cDesc1,cDesc1,cDesc4,.T.,aOrd,.T.,Tamanho,,.F.)
EndIf

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

	If  MV_PAR16 == 1
		RptStatus({|| RunReport(Cabec1,Cabec2,cTitulo,nLin) },cTitulo)
	Else
		RptStatus({|| RunReport(Cabec3,Cabec4,cTitulv,nLin) },cTitulv)
	EndIf
ELSE
	  nRGcombo:=MV_PAR17
	  IF (nRGcombo== 0) .or. (nRGcombo== 1)
		 GerArq(AllTrim(MV_PAR10),"5000",0,0,0,0,0)
	  ELSE
		QRYSF3()
		GerArq2(AllTrim(MV_PAR10),5000,0,0,0,0,0)
	 ENDIF
ENDIF                       

If Select("QRYSF3")>0
	DbSelectArea("QRYSF3")
	QRYSF3->(DbCloseArea())
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncion   ³RUNREPORT º Autor ³                    º Fecha ³  30/10/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,cTitulo,nLin)
Local lPriPag  := .T.
Local cQuant   := 0
Local nTot5    := 0
Local nTot5v   := 0
Local nTot10   := 0
Local nTot10v  := 0
Local nTExent  := 0
Local cFactura:=""
Local cCodAD:=""
Local cCodNC:=""
Local cCodEx:=""
Local aArea:=GetArea()
Local aLinReceb:={}
Local nx:=0
Local cNome:=""
Private cArqTrb:=Nil
Private oTempTable	:= NIL

QRYSF3()
// VERIFICAR A EXISTENCIA DE CGC ESPECIAIS
Private cFilSa2 := xFilial("SA2")
Private cFilSa1 := xFilial("SA1")

cCodAD:=""
cCodNC:=""
cCodEx:=""
aArea:=GetArea()
aLinReceb:={}
      
If  MV_PAR16 == 2
	dbSelectArea("SA1")
	SA1->(DbSetOrder(3))
	If MsSeek(cFilSa1+"44444401")   // nao contribuinte        
		lPri:=.t.
		While  cFilSa1==SA1->A1_FILIAL .AND.  "44444401"$ SA1->A1_CGC  .AND.  !EOF()
			If lPri
				cCodNC:=SA1->A1_COD   
				lPri:=.F.
			Else
				cCodNC:=cCodNC+"|"+SA1->A1_COD  
   			Endif	
		    SA1->(Dbskip())       
		EndDo    
	EndIf
	
	If MsSeek(cFilSa1+"77777701")	// ag. diplomatico        
		lPri:=.t.
		While  cFilSa1==SA1->A1_FILIAL .AND.  "77777701"$ SA1->A1_CGC  .AND.  !EOF()
			If lPri
				cCodAD:=SA1->A1_COD   
				lPri:=.F.
			Else
				cCodAD:=cCodAD+"|"+SA1->A1_COD  
   			Endif	
		    SA1->(Dbskip())       
		EndDo    
	EndIf

	If MsSeek(cFilSa1+"88888801")	// Exterior
		lPri:=.t.
		While  cFilSa1==SA1->A1_FILIAL .AND.  "88888801"$ SA1->A1_CGC  .AND.  !EOF()
			If lPri
				cCodEx:=SA1->A1_COD   
				lPri:=.F.
			Else
				cCodEx:=cCodAD+"|"+SA1->A1_COD  
   			Endif	
		    SA1->(Dbskip())       
		EndDo    
	EndIf
EndIf

dbSelectArea("QRYSF3")

dbGoTop()
aCodEsp:={}
If  MV_PAR16 == 2
	Do While !EOF()
		If QRYSF3->F3_CLIEFOR $ cCodAD      
			cCGC:="77777701"                
		ElseIf  QRYSF3->F3_CLIEFOR $ cCodNC   
			cCGC:="44444401"      
		ElseIf  QRYSF3->F3_CLIEFOR $ cCodEx
			cCGC:="88888801"             
		Else
			cCGC:=""  
			cDesc:=""
		EndIf	
		
		If !Empty(cCGC)  
		    nPos:=0
		    If Len(aLinReceb)>0
				nPos:= AScan(aLinReceb,{|x| Alltrim(x[18])==Alltrim(cCGC) })
			EndIf
			If nPos>0     
				aLinReceb[nPos][1] := QRYSF3->F3_FILIAL 			                 
				aLinReceb[nPos][4] :=QRYSF3->F3_SERIE 
				aLinReceb[nPos][5] :=QRYSF3->F3_NFISCAL    
				aLinReceb[nPos][6] :=QRYSF3->F3_ESPECIE
				aLinReceb[nPos][7] :=QRYSF3->F3_DTCANC
				aLinReceb[nPos][8] :=QRYSF3->F3_ENTRADA
				aLinReceb[nPos][9] :=QRYSF3->F3_EMISSAO
				aLinReceb[nPos][10] :=QRYSF3->F3_OBSERV
				aLinReceb[nPos][11] :=QRYSF3->F3_TIPOMOV												
				aLinReceb[nPos][12] :=QRYSF3->F3_ALQIMP1
				aLinReceb[nPos][13] :=aLinReceb[nPos][13]+ QRYSF3->F3_BASIMP1
				aLinReceb[nPos][14] :=aLinReceb[nPos][14]+ QRYSF3->F3_VALIMP1
				aLinReceb[nPos][15] :=aLinReceb[nPos][15]+ QRYSF3->F3_EXENTAS
				aLinReceb[nPos][16] :=aLinReceb[nPos][16]+ QRYSF3->F3_VALCONT
				aLinReceb[nPos][17] :=QRYSF3->F3_ENTRADA   
	         Else
				AAdd(aLinReceb,{  ;
					QRYSF3->F3_FILIAL,;
					QRYSF3->F3_CLIEFOR	,;
					QRYSF3->F3_LOJA,;
					QRYSF3->F3_SERIE,;
					QRYSF3->F3_NFISCAL,;
					QRYSF3->F3_ESPECIE,;
					QRYSF3->F3_DTCANC,;
					QRYSF3->F3_ENTRADA,;
					QRYSF3->F3_EMISSAO,;
					QRYSF3->F3_OBSERV	, ;
					QRYSF3->F3_TIPOMOV, ;
					QRYSF3->F3_ALQIMP1	, ;
					QRYSF3->F3_BASIMP1	, ;
					QRYSF3->F3_VALIMP1	, ;
					QRYSF3->F3_EXENTAS,;
					QRYSF3->F3_VALCONT,;
					QRYSF3->F3_ENTRADA,;
					cCGC;  
					})
			Endif
			RecLock("QRYSF3",.F.)
			QRYSF3->(DbDelete())
			QRYSF3->(MsUnlock())                                                                                                                                                                               
	    EndIf
	    QRYSF3->(DbSkip())  
	EndDo
EndIf

If  MV_PAR16 == 2 .and. Len(aLinReceb)>0
      For nx:=1 to Len(aLinReceb)
      		RecLock("QRYSF3",.T.)
      		QRYSF3->F3_FILIAL 			:= aLinReceb[nx][1] 
			QRYSF3->F3_CLIEFOR 	:= aLinReceb[nx][2] 
			QRYSF3->F3_LOJA 			:= aLinReceb[nx][3] 
			QRYSF3->F3_SERIE 		:= aLinReceb[nx][4] 
			QRYSF3->F3_NFISCAL    	:= aLinReceb[nx][5] 
			QRYSF3->F3_ESPECIE		:= aLinReceb[nx][6] 
			QRYSF3->F3_DTCANC		:= aLinReceb[nx][7]
			QRYSF3->F3_ENTRADA	:=aLinReceb[nx][8] 
			QRYSF3->F3_EMISSAO	:= aLinReceb[nx][9] 
			QRYSF3->F3_OBSERV		:= aLinReceb[nx][10] 
			QRYSF3->F3_TIPOMOV	:=aLinReceb[nx][11] 
			QRYSF3->F3_ALQIMP1		:=aLinReceb[nx][12] 
			QRYSF3->F3_BASIMP1		:= aLinReceb[nx][13]
		 	QRYSF3->F3_VALIMP1		:=aLinReceb[nx][14] 
			QRYSF3->F3_EXENTAS	:= aLinReceb[nx][15]  
			QRYSF3->F3_VALCONT	:=aLinReceb[nx][16]
			QRYSF3->F3_ENTRADA	:=aLinReceb[nx][17]    
    
      		QRYSF3->(MsUnlock())
      
      Next

EndIf

    
dbSelectArea("QRYSF3")
SetRegua(Contar("QRYSF3", ".T."))
dbGoTop()

Do While !EOF()

	If lAbortPrint
      @nLin,00 PSAY STR0018
      Exit
   	Endif
   
   	lPrimero1 := .F.                                               
   If nLin > 57 //.Or. lSalto 57
      If !lPriPag
      	m_Pag  :=Soma1(Alltrim(m_Pag))
      EndIf
      lPriPag:=.F.
      If !lPrimero .Or. lSalto
      
      	 lPrimero1 := .T.	
         SubTotal(@nLin)
         lPrimero := .F.
         If lSalto
            Totales(@nLin)
            lPrimero := .T.
            lSalto   := .F.
         EndIf
      Else
		 lPrimero := .F.
	  EnDif     
	  	  
	  nLin := Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)	  
      nLin++
	  If !lTodo
  	     nLin++
	  EndiF
	  @nLin,008 PSAY STR0016+ "  " + dtoc(MV_PAR01)+ "   " +STR0017+ "  " +dtoc(MV_PAR02)
	  nLin++
	  
	  If lPrimero1 .And. MV_PAR04 == 1
		  @nLin,008 PSAY STR0009 //SALDO ACUMULADO DE LA PAGINA ANTERIOR 
		  @nLin,094 PSAY nTotAnt		Picture Tm(F3_VALCONT,18,0) 
		  @nLin,117 PSAY nTBa10Ant		Picture Tm(F3_BASIMP1,18,0)
		  @nLin,138 PSAY nTVa10Ant		Picture Tm(F3_VALIMP1,18,0)
		  @nLin,157 PSAY nBa5Ant		Picture Tm(F3_BASIMP1,18,0)
		  @nLin,177 PSAY nTVa5Ant		Picture Tm(F3_VALIMP1,18,0)
		  @nLin,198 PSAY nTExeAnt		Picture Tm(F3_EXENTAS,18,0)
	  
	  nLin++
	  EndIf	 
      
	@nLin,000 PSAY Replicate("-",limite)
	nLin++
	Endif
	
	If MV_PAR04 == 2 .and. Posicione("SA2",1,cFilSa2+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A2_NOME") <> "  "
		nSinal:=1 // conforme contato com analista sandra. não pode haver valores negativos para as notas NCC e NCI
		SumaFact(nSinal)
	EndIf
	
	If Posicione("SA2",1,cFilSa2+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A2_NOME") <> "A2_NOME" .AND. MV_PAR04 == 1

		@nLin,001 PSAY nNumero++  			              //Número de itens
		@nLin,007 PSAY QRYSF3->F3_EMISSAO			  Picture PesqPict ("SF3","F3_EMISSAO")
				 
        nImport := SF1->F1_VALBRUT
        nTotImp     += nImport //QRYSF3->F3_VALCONT//0  	
		nGenImp     += nImport
		If QRYSF3->F3_TIPOMOV =="C" .OR. AllTrim(QRYSF3->F3_ESPECIE) $ "NDP|NCP|NDI|NCE" 
			Posicione("SA2",1,xFilial("SA2")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A2_NOME")
			If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)
            	@nLin,019 PSAY QRYSF3->F3_OBSERV				Picture PesqPict ("SF3","F3_OBSERV")
			Else    
				cNome:=	Left(Posicione("SA2",1,xFilial("SA2")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A2_NOME"),35)     
				If Empty(SA2->A2_CGC)
					@nLin,019 PSAY "XXX"
				Else	
					@nLin,019 PSAY SA2->A2_CGC					Picture PesqPict ("SA2","A2_CGC")
				EndIf	  
				@nLin,036 PSAY cNome
			EndIf	
		Else
			If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)
				Posicione("SA1",1,xFilial("SA1")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A1_NOME") 	
				@nLin,019 PSAY QRYSF3->F3_OBSERV				Picture PesqPict ("SF3","F3_OBSERV")
			Else	
				Posicione("SA1",1,xFilial("SA1")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A1_NOME") 	
				cNome:=Left(Posicione("SA1",1,xFilial("SA1")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A1_NOME"),35)
				
				If  "77777701" $ SA1->A1_CGC     
					cNome:= "VENTAS A AGENTES DIPLOMATICOS"
				ElseIf  "44444401" $ SA1->A1_CGC     
					cNome:= "IMPORTES CONSOLIDADOS"
   				ElseIf  "88888801" $ SA1->A1_CGC      
					cNome:= "CLIENTES DEL EXTERIOR"
				EndIf   
				If Empty(SA1->A1_CGC)
					@nLin,019 PSAY "XXX"
				Else
					@nLin,019 PSAY SA1->A1_CGC					Picture PesqPict ("SA1","A1_CGC")
				EndIf
					@nLin,036 PSAY cNome
							
			EndIf
		EndIf
	   @nLin,064 PSAY QRYSF3->F3_TIPNOTA  			      Picture PesqPict ("SF3","F3_ESPECIE")  
	   
	   cNumDoc:=QRYSF3->F3_NFISCAL
	   
	   If AllTrim(QRYSF3->F3_ESPECIE) $ "NDP|NDE|NCI|NCC" .Or. QRYSF3->F3_TES < "500" 						
			aArea:=GetArea()		
			dbSelectArea("SF1")
			SF1->(DbSetOrder(1))
			If !SF1->(MsSeek(xFilial("SF1")+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_ESPECIE))	
				SF1->(MsSeek(QRYSF3->F3_FILIAL+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_ESPECIE))	
			EndIf
	   		If !Empty(SF1->F1_NUMDES)
	       		cNumDoc:=SF1->F1_NUMDES
              EndIf
              RestArea(aArea)
	   	EndIf
	   	    		
	   @nLin,079 PSAY StrTran(cNumDoc,"-","") Picture PesqPict ("SF3","F3_NFISCAL")
		nSinal:=1 // conforme contato com analista sandra. não pode haver valores negativos para as notas NCC e NCI

		SumaFact(nsinal)
		If  cFactura <>  QRYSF3->F3_NFISCAL + QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_ESPECIE
			cQuant++
		EndIf  
		cFactura := QRYSF3->F3_NFISCAL + QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_ESPECIE
      @nLin,094 PSAY nTotal   Picture Tm(F3_VALCONT,18,0)
      @nLin,117 PSAY nBas10   Picture Tm(F3_BASIMP1,18,0)
      @nLin,138 PSAY nVal10   Picture Tm(F3_VALIMP1,18,0)
      @nLin,157 PSAY nBas5    Picture Tm(F3_BASIMP1,18,0)
      @nLin,177 PSAY nVal5    Picture Tm(F3_VALIMP1,18,0)
      @nLin,198 PSAY nExentas Picture Tm(F3_EXENTAS,18,0)
		
		// Zerar valores																																																	
      nBas5 	 := 0
      nVal5	 := 0
      nBas10 	 := 0
      nVal10 	 := 0
      nExentas := 0
      nTotal   := 0
      nImport	 := 0			
      nLin     := nLin + 1               
	Else
		
		If Posicione("SA1",1,cFilSa1+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A1_NOME") <> "A1_NOME" .AND. MV_PAR04 == 1 

			@nLin,001 PSAY nNumero++  			              //Número de itens
		    @nLin,041 PSAY QRYSF3->F3_TIPNOTA 			      Picture PesqPict ("SF3","F3_ESPECIE")//PesqPict ("SF3","F3_ESPECIE")			    
			@nLin,056 PSAY StrTran(QRYSF3->F3_NFISCAL,"-","") Picture "@R 999-999-9999999"//PesqPict ("SF3","F3_NFISCAL")
			@nLin,008 PSAY QRYSF3->F3_ENTRADA			  Picture PesqPict ("SF3","F3_ENTRADA")
					 
	        nImport := SF2->F2_VALBRUT
	        nTotImp     += nImport //QRYSF3->F3_VALCONT//0  	
			nGenImp     += nImport
			If QRYSF3->F3_TIPOMOV =="V" .OR. AllTrim(QRYSF3->F3_ESPECIE) $ "NDP|NDE|NCI|NCC"
				If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)
					Posicione("SA1",1,xFilial("SA1")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A1_NOME") 	
					@nLin,027 PSAY QRYSF3->F3_OBSERV				Picture PesqPict ("SF3","F3_OBSERV")
				Else
					Posicione("SA1",1,xFilial("SA1")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A1_NOME") 	
					If Empty(SA1->A1_CGC)
						@nLin,027 PSAY "XXX"					//Picture PesqPict ("SA2","A2_CGC")
					Else	
						@nLin,027 PSAY SA1->A1_CGC					Picture PesqPict ("SA1","A1_CGC")
					EndIf	
				EndIf	
			Else
				If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)                                                                                                                                                                                                                                                                                                           
				
					Posicione("SA2",1,xFilial("SA2")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A2_NOME") 	
					@nLin,027 PSAY QRYSF3->F3_OBSERV				Picture PesqPict ("SF3","F3_OBSERV")
				Else	
					Posicione("SA2",1,xFilial("SA2")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A2_NOME") 	
					If Empty(SA2->A2_CGC)
						@nLin,027 PSAY "XXX"					//Picture PesqPict ("SA1","A1_CGC")	
					Else
						@nLin,027 PSAY SA2->A2_CGC					Picture PesqPict ("SA2","A2_CGC")
					EndIf			
				EndIf
			EndIf
			nSinal:=1 // conforme contato com analista sandra. não pode haver valores negativos para as notas NCC e NCI
		
			SumaFact(nsinal)
	
			If  cFactura <>  QRYSF3->F3_NFISCAL + QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_ESPECIE
			cQuant++
			EndIf  
			cFactura :=  QRYSF3->F3_NFISCAL + QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_ESPECIE
			 
			
			
			@nLin,131 PSAY nBas5		Picture Tm(F3_BASIMP1,20,0)
			@nLin,148 PSAY nVal5		Picture Tm(F3_VALIMP1,20,0)
			@nLin,091 PSAY nBas10		Picture Tm(F3_BASIMP1,20,0)
			@nLin,110 PSAY nVal10		Picture Tm(F3_VALIMP1,20,0)
			@nLin,169 PSAY nExentas		Picture Tm(F3_EXENTAS,20,0)
			@nLin,065 PSAY nTotal		Picture Tm(F3_VALCONT,20,0)	
			
			//			data	       ruc           documento
			//			                            tipo | Nº	    importe tot     imp iva     credito fis        importe iva         credito fiscal     importes gravados
			//		  10/01/01		TPAA946130Y	    000025375     999999999999  
			//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        210       22
			// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
		
			// Zerar valores																																																	
			nBas5 	 := 0
			nVal5	 := 0
			nBas10 	 := 0
			nVal10 	 := 0
			nExentas := 0
			nTotal   := 0
			nImport	 := 0			
								
			nLin     := nLin + 1  		
		
		EndIf
				
//	 	If MV_PAR04 == 1
	 		dbSkip()
  //	 	EndIf	 
	Endif

EndDo

If nLin <> 80
	SubTotal(@nLin)
	Totales(@nLin,@nTot5,@nTot5v,@nTot10,@nTot10v,@nTExent)
EndIf	

If MV_PAR09 == 1           
	IF MSGYESNO(STR0010)
		IF (nRGcombo== 0) .or. (nRGcombo== 1)
			Processa({|| GerArq(AllTrim(MV_PAR10),cQuant,nTot5,nTot5v,nTot10,nTot10v,nTExent)},,STR0011)
		ELSE
			Processa({|| GerArq2(AllTrim(MV_PAR10),cQuant,nTot5,nTot5v,nTot10,nTot10v,nTExent)},,STR0011)
		ENDIF
	Endif   
EndIf

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Si imprime en disco, llama al gerente de impresion...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

If Select("QRYSF3")>0
	QRYSF3->(DbCloseArea())      
	FErase(cArqTrb + GetDbExtension())  // Deletando o arquivo
	FErase(cArqTrb + OrdBagExt())       // Deletando índice

Endif

oTempTable:Delete()

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncion   ³VALIDPERG º Autor ³                    º Fecha ³  30/10/16  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1
Local aArea := GetArea()
Local nTamF := SF3->(TamSX3("F3_FILIAL")[1])
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Defspa1/Defeng1/Cnt01/Var02/Def02/Defspa1/Defeng1/Cnt02/Var03/Def03/Defspa3/Defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt04/Var05/Def05/Cnt05

	
	CheckSX1(cPerg,"01","Fecha Inicio","Fecha Inicio","Fecha Inicio","mv_ch1","D",8,0,0,"G","","","","","MV_PAR01","","","","",;
	"","","","","","","","","","","","",{"Informe a Data Inicial"},{"Informe a Data Inicial"},{"Informe a Data Inicial"})	
	
	CheckSX1(cPerg,"02","Fecha Final","Fecha Final","Fecha Final","mv_ch2","D",8,0,0,"G","","","","","MV_PAR02","","","","",;
	"","","","","","","","","","","","",{"Informe a Data Final"},{"Informe a Data Final"},{"Informe a Data Final"})	
				
	CheckSX1(cPerg,"03","Incluir?","Incluir?","Incluir?","mv_ch3","N",1,0,0,"C","","","","","MV_PAR03","Activos","Activos","Activos","Anulados",;
	"Anulados","Anulados","Todos","Todos","Todos","Todos","","","","","","",{"Activos / Anulados / Todos"},{"Activos / Anulados / Todos"},{"Activos / Anulados / Todos"})
	
	CheckSX1(cPerg,"04","Estilo","Estilo","Estilo","mv_ch4","C",1,0,0,"C","","","","","MV_PAR04","Analitico","Analitico","Analitico","Resumido",;
	"Resumido","Resumido","","","","","","","","","","",{"Analitico / Resumido"},{"Analitico / Resumido"},{"Analitico / Resumido"})
	
	CheckSX1(cPerg,"05","Sucursal","Sucursal","Sucursal","mv_ch5","C",nTamF,0,0,"G","","SM0","033","","MV_PAR05","","","","",;
	"","","","","","","","","","","","",{"Informe a Filial Inicial"},{"Informe a Filial Inicial"},{"Informe a Filial Inicial"})
	
	CheckSX1(cPerg,"06","Hasta Sucursal","Hasta Sucursal","Hasta Sucursal","mv_ch6","C",nTamF,0,0,"G","","SM0","033","","MV_PAR06","","","","",;
	"","","","","","","","","","","","",{"Informe a Filial Final"},{"Informe a Filial Final"},{"Informe a Filial Final"})

	CheckSX1(cPerg,"07","Pagina de Inicio?","Pagina de Inicio?","Pagina de Inicio?","mv_ch7","C",10,0,0,"G","","","","","MV_PAR07","","","","",;
	"","","","","","","","","","","","",{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"})	
	
	CheckSX1(cPerg,"08","Ordenamiento?","Ordenamiento?","Ordenamiento?","mv_ch8","C",1,0,0,"C","","","","","MV_PAR08","Fecha+Comprobante","Fecha+Comprobante","Fecha+Comprobante","FechaAlta+Comprobante",;
	"FechaAlta+Comprobante","FechaAlta+Comprobante","","","","","","","","","","",{"Fecha+Comprobante"},{"Fecha+Comprobante"},{"Fecha+Comprobante"})	
	
	CheckSX1(cPerg,"09","Gera Arquivo?","¿Genera Archivo?","Generates file?","MV_CH9","N",1,0,0,"C","","","","","MV_PAR09","Sim","Si","Yes","",;
	"Nao","No","No","","","","","","","","","",{"Informe se deve ser gerado o arquivo magnetico"},{"Generate a magnetic file"},{"Informe si debe generar un arquivo magnetico"})

	CheckSX1(cPerg,"10","Diretorio ?","¿Directorio?","Directory?","MV_CH10","C",40,0,0,"G","","","","","MV_PAR10","","","","",;
	"","","","","","","","","","","","",{"Diretorio do arquivo"},{"Directory file determination"},{"Directorio de los archivos"})
	
	CheckSX1(cPerg,"11","Tp. Reporte?","Tp. Reporte?","Tp. Reporte?","mv_ch11","N",1,0,0,"C","","","","","MV_PAR11","Original","Original","Original","Retificativa",;
	"Retificativa","Retificativa","","","","","","","","","","",{"Original / Retificativa"},{"Original / Retificativa"},{"Original / Retificativa"})
			
	CheckSX1(cPerg,"12","RUC Rep. Legal?","RUC Rep. Legal?","RUC Rep. Legal?","mv_ch12","C",15,0,0,"G","","","","","MV_PAR12","","","","",;
	"","","","","","","","","","","","",{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"})	
	
	CheckSX1(cPerg,"13","DV Rep. Legal?","DV Rep. Legal?","DV Rep. Legal?","mv_ch13","C",1,0,0,"G","","","","","MV_PAR13","","","","",;
	"","","","","","","","","","","","",{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"})		
		
	CheckSX1(cPerg,"14","Nom. Rep. Legal?","Nom. Rep. Legal?","Nom. Rep. Legal?","mv_ch14","C",80,0,0,"G","","","","","MV_PAR14","","","","",;
	"","","","","","","","","","","","",{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"},{"Pagina de Inicio Impresion"})		
	
	CheckSX1(cPerg,"15","Exportador?","Exportador?","Exportador?","mv_ch15","N",1,0,0,"C","","","","","MV_PAR15","NO","NO","NO","SI",;
	"SI","SI","","","","","","","","","","",{"NO / SI"},{"NO / SI"},{"NO / SI"})
	
	CheckSX1(cPerg,"16","LIBRO IVA?","LIBRO IVA?","LIBRO IVA?","mv_ch16","N",1,0,0,"C","","","","","MV_PAR16","COMPRAS","COMPRAS","COMPRAS","VENTAS",;
	"VENTAS","VENTAS","","","","","","","","","","",{"COMPRAS / VENTAS"},{"COMPRAS / VENTAS"},{"COMPRAS / VENTAS"})
	
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fisr502   ºAutor                       ºFecha ³  30/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Suma Filas en SF3 por Factura                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SumaFact(nSinal)
cFactura 	:= QRYSF3->F3_NFISCAL
cClieFor 	:= QRYSF3->F3_CLIEFOR 
cLoja			:=QRYSF3->F3_LOJA
cSerie   	:= QRYSF3->F3_SERIE   
cEspecie	:=QRYSF3->F3_ESPECIE
nContPar	:= mv_par04



While  !Eof() .and.  cSerie == QRYSF3->F3_SERIE  .and.    cFactura == QRYSF3->F3_NFISCAL .and.  QRYSF3->F3_CLIEFOR == cClieFor   .And. cLoja == QRYSF3->F3_LOJA  .and. cEspecie ==QRYSF3->F3_ESPECIE

	If Empty(QRYSF3->F3_DTCANC)	
		dFecha:= dTos(QRYSF3->F3_ENTRADA)
			
		If 	QRYSF3->F3_ALQIMP1 == 5
			nBas5 	    += QRYSF3->F3_BASIMP1*nSinal // Sumador por Linea por factura
			nVal5 	    += QRYSF3->F3_VALIMP1*nSinal
			nTGBas5 	+= QRYSF3->F3_BASIMP1*nSinal // Sumador General
			nTGVal5 	+= QRYSF3->F3_VALIMP1*nSinal
			nTBas5   	+= QRYSF3->F3_BASIMP1*nSinal // Sumador de Totales por pagina
			nTVal5  	+= QRYSF3->F3_VALIMP1*nSinal
			
		ElseIf QRYSF3->F3_ALQIMP1 == 10 .OR. QRYSF3->F3_ALQIMP1 == 100  //.and. cSerie <> 'DES'
				
			nBas10  	+= QRYSF3->F3_BASIMP1*nSinal // Sumador por Linea por factura
			nVal10  	+= QRYSF3->F3_VALIMP1*nSinal //QRYSF3->F3_VALIMP1 + QRYSF3->F3_BASIMP1
			nTGBas10 	+= QRYSF3->F3_BASIMP1*nSinal // Sumador General
			nTGVal10 	+= QRYSF3->F3_VALIMP1*nSinal //QRYSF3->F3_VALIMP1 //+ QRYSF3->F3_BASIMP1
			nTBas10 	+= QRYSF3->F3_BASIMP1*nSinal // Sumador de Totales por pagina
			nTVal10 	+= QRYSF3->F3_VALIMP1*nSinal //+ QRYSF3->F3_BASIMP1 
	 	
		EndIf
		
			nExentas	+= QRYSF3->F3_EXENTAS*nSinal
			nTotal		+= QRYSF3->F3_VALCONT*nSinal //+ nImport
			nTotExe		+= QRYSF3->F3_EXENTAS*nSinal
			nTotTot		+= QRYSF3->F3_VALCONT*nSinal //+nImport  
			nGenExe		+= QRYSF3->F3_EXENTAS*nSinal
		    nGenTot		+= QRYSF3->F3_VALCONT*nSinal
	
	Elseif !Empty(QRYSF3->F3_DTCANC) .And. MV_PAR03 == 2
		dFecha:= dTos(QRYSF3->F3_ENTRADA)
			
		If 	QRYSF3->F3_ALQIMP1 == 5
			nBas5 	    += QRYSF3->F3_BASIMP1*nSinal // Sumador por Linea por factura
			nVal5 	    += QRYSF3->F3_VALIMP1*nSinal
			nTGBas5 	+= QRYSF3->F3_BASIMP1*nSinal // Sumador General
			nTGVal5 	+= QRYSF3->F3_VALIMP1*nSinal
			nTBas5   	+= QRYSF3->F3_BASIMP1*nSinal // Sumador de Totales por pagina
			nTVal5  	+= QRYSF3->F3_VALIMP1*nSinal
			
		ElseIf QRYSF3->F3_ALQIMP1 == 10 .OR. QRYSF3->F3_ALQIMP1 == 100  //.and. cSerie <> 'DES'
				
			nBas10  	+= QRYSF3->F3_BASIMP1*nSinal // Sumador por Linea por factura
			nVal10  	+= QRYSF3->F3_VALIMP1*nSinal //QRYSF3->F3_VALIMP1 + QRYSF3->F3_BASIMP1
			nTGBas10 	+= QRYSF3->F3_BASIMP1*nSinal // Sumador General
			nTGVal10 	+= QRYSF3->F3_VALIMP1*nSinal //QRYSF3->F3_VALIMP1 //+ QRYSF3->F3_BASIMP1
			nTBas10 	+= QRYSF3->F3_BASIMP1*nSinal // Sumador de Totales por pagina
			nTVal10 	+= QRYSF3->F3_VALIMP1*nSinal //+ QRYSF3->F3_BASIMP1 
	 	
		EndIf
		
			nExentas	+= QRYSF3->F3_EXENTAS*nSinal
			nTotal		+= QRYSF3->F3_VALCONT*nSinal //+ nImport
			nTotExe		+= QRYSF3->F3_EXENTAS*nSinal
			nTotTot		+= QRYSF3->F3_VALCONT*nSinal //+nImport  
			nGenExe		+= QRYSF3->F3_EXENTAS*nSinal
		    nGenTot		+= QRYSF3->F3_VALCONT*nSinal
			
	Endif
	QRYSF3->(DbSkip())
	If nContPar == 2
		cFactura:= QRYSF3->F3_NFISCAL
		cClieFor:= QRYSF3->F3_CLIEFOR 
		cLoja:=QRYSF3->F3_LOJA
		cSerie:= QRYSF3->F3_SERIE   
		cEspecie:=QRYSF3->F3_ESPECIE
	EndIf	 
	IncRegua()
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SubTotal  ºAutor  ³                    ºFecha ³  30/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³SubTotal de Pagina                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SubTotal(nLin)

If MV_PAR04 == 1

	nLin ++
	@nLin,000 PSAY Replicate("-",limite)
	nLin ++
	@nLin,008 PSAY STR0012//Totales de la Pagina Actual 

	@nLin,094 PSAY nTotTot		Picture Tm(F3_VALCONT,18,0)
	@nLin,117 PSAY nTBas10		Picture Tm(F3_BASIMP1,18,0)
	@nLin,138 PSAY nTVal10		Picture Tm(F3_VALIMP1,18,0)
	@nLin,157 PSAY nTBas5		Picture Tm(F3_BASIMP1,18,0)
	@nLin,177 PSAY nTVal5		Picture Tm(F3_VALIMP1,18,0)
	@nLin,198 PSAY nTotExe		Picture Tm(F3_EXENTAS,18,0)
		
	nBa5Ant   += nTBas5
	nTVa5Ant  += nTVal5
	nTBa10Ant += nTBas10
	nTVa10Ant += nTVal10
	nTExeAnt  += nTotExe
	nTotAnt   += nTotTot
					
	nLin ++
	
	nTBas5:= 0
	nTVal5:= 0
	nTBas10:= 0
	nTVal10:= 0
	nTotExe:= 0
	nTotImp:= 0
	nTotTot:= 0	
	
	@nLin,008 PSAY STR0013// Totales Acumulado de la Pagina -----------> 

	nBa5Ant   += nTBas5
	nTVa5Ant  += nTVal5
	nTBa10Ant += nTBas10
	nTVa10Ant += nTVal10
	nTExeAnt  += nTotExe
	nTotAnt   += nTotTot

	@nLin,094 PSAY nTotAnt		Picture Tm(F3_VALCONT,18,0)
	@nLin,117 PSAY nTBa10Ant		Picture Tm(F3_BASIMP1,18,0)
	@nLin,138 PSAY nTVa10Ant		Picture Tm(F3_VALIMP1,18,0)
	@nLin,157 PSAY nBa5Ant		Picture Tm(F3_BASIMP1,18,0)
	@nLin,177 PSAY nTVa5Ant		Picture Tm(F3_VALIMP1,18,0)
	@nLin,198 PSAY nTExeAnt		Picture Tm(F3_EXENTAS,18,0)
		

EndIf
Return       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Fisr502  ºAutor  ³                    ºFecha ³  30/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Total de Listado                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Totales(nLin,nTot5,nTot5v,nTot10,nTot10v,nTExent)
nlin ++
nlin ++
nlin ++
nlin ++
nLin ++

	@nLin,008 PSAY STR0014//Totales Generales

	@nLin,094 PSAY nGenTot				Picture Tm(F3_VALCONT,18,0)
	@nLin,117 PSAY nTGBas10			Picture Tm(F3_BASIMP1,18,0)
	@nLin,138 PSAY nTGVal10			Picture Tm(F3_VALIMP1,18,0)
	@nLin,157 PSAY nTGBas5			Picture Tm(F3_BASIMP1,18,0)
	@nLin,177 PSAY nTGVal5				Picture Tm(F3_VALIMP1,18,0)
	@nLin,198 PSAY nGenExe			Picture Tm(F3_EXENTAS,18,0)
	
	nLin ++
		
	nTot5  := nTGBas5
	nTot5v := nTGVal5
	nTot10 := nTGBas10	
	nTot10v:= nTGVal10
	nTExent:= nGenExe
	
	nTGBas5:= 0
	nTGVal5:= 0 
	nTGBas10:= 0
	nTGVal10:= 0
	nGenExe:= 0
	nGenImp:= 0
	nGenTot:= 0

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³                      ³ Data ³31.10.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Arquivo magnético                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Paraguay -                    - Arquivo Magnetico   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir,cQuant,nTot5,nTot5v,nTot10,nTot10v,nTExent)

Local nHdl     := 0
Local clin1    := ""
Local cSep     := CHR(9)
Local nCont    := 0
Local nRuc     := ""
Local lRucOk   := .F.
Local cTpNf    := ""
Local cCGC     := ""
Local nBasTxt := 0
Local nValTxt := 0
Local nBasTxt1 := 0
Local nValTxt1 := 0
Local nExentxt := 0                 
Local nDesc:=Msdecimais(1)
Local lCredito:=.f.
																		
FOR nCont:=LEN(AllTrim(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
		cDir:=Substr(cDir,1,nCont)
		EXIT
	ENDIF	
NEXT

nHdl := fCreate(cDir)
/*
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Cabecalho                                            ³ Data ³31.10.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/
// - 01 Tipo Registro 			
clin1 += "1"
clin1 += cSep	
	
// - 02 PERIODO			
clin1 += SubStr(DTOS(MV_PAR01),1,6)
clin1 += cSep	
			
// - 03 Tipo de Reporte 										
clin1 += Transform(Round(mv_par11,1),"")					
clin1 += cSep 	
						
// - 04 Código Obligación 	
If MV_PAR16 == 1
	clin1 += "911"
Else
	clin1 += "921"
EndIF							
clin1 += cSep	
						
// - 05 Código Formulario 	
If MV_PAR16 == 1				
	clin1 += "211"
Else
	clin1 += "221"
EndIf	
clin1 += cSep				

nRuc:=Len(Alltrim(SM0->M0_CGC))
lRucOk:=Iif(Subs(SM0->M0_CGC,nRuc-1,1)=="-",.T.,.F.)	
		
// - 06 RUC Agente de Información 		
If lRucOk
	clin1 += Transform(Subs(SM0->M0_CGC,1,nRuc-2),"@R XXXXXXXXXXXXXXX")					
Else
	clin1 += Transform(Subs(SM0->M0_CGC,1,nRuc-1),"@R XXXXXXXXXXXXXXX")
EndIf			 					
clin1 += cSep 	 	
			
// - 07 DV Agente de Información 						  
clin1 += Substr(Alltrim(SM0->M0_CGC),nRuc,1)			
clin1 += cSep 	
				  
// - 08 Nombre o Denominación Agente de Información 
clin1 += SM0->M0_NOME					
clin1 += cSep	
		
// - 09 RUC Representante Legal 
clin1 += Alltrim(mv_par12)					
clin1 += cSep

// - 10 DV Representante Legal 								
clin1 += Alltrim(mv_par13)					
clin1 += cSep	
			
// - 11 Apellidos y Nombres Representante Legal 		  			  
clin1 += Alltrim(mv_par14)						
clin1 += cSep 
				  		
// - 12 Cantidad Registros 				
clin1 += Transform(Round(cQuant,0),"")					
clin1 += cSep
																						  																						  
// - 13 Monto Total 
If MV_PAR16 == 1			
	clin1 += Transform(Round(nTot5 + nTot10 + nTExent,1),"")	
Else       
	dbSelectArea("QRYSF3")
	QRYSF3->(dbGoTop())        
	nBasTxt:=0
	nValTxt:=0
	nBastxt1:=0
	nValTxt1:=0
	nExentxt:=0          
	
	Do While QRYSF3->(!EOF())             
		If Empty(QRYSF3->F3_DTCANC)
				If 	QRYSF3->F3_ALQIMP1 == 10
					nBasTxt += noRound(QRYSF3->F3_BASIMP1,nDesc)
					nValTxt += noRound(QRYSF3->F3_VALIMP1,nDesc)
                EndIf
      			If 	QRYSF3->F3_ALQIMP1 == 5		
					nBastxt1 += noRound(QRYSF3->F3_BASIMP1,nDesc) 
					nValTxt1+= noRound(QRYSF3->F3_VALIMP1,nDesc)
                EndIf
                nExenTxt += noRound(QRYSF3->F3_EXENTAS,nDesc)     
    	EndIf
    QRYSF3->(dbSkip())	
	EndDo
	clin1 += Transform(noRound(nBasTxt + nValTxt + nBastxt1 + nValTxt1 + nExenTxt,nDesc),"")					
	nBasTxt:=0
	nValTxt:=0
	nBastxt1:=0
	nValTxt1:=0
	nExentxt:=0
	 
EndIf		
clin1 += cSep 		
							  										  
// - 14 Exportador		
If MV_PAR15 == 1		  				  
	clin1 += "NO"	
Else
	clin1 += "SI"	
EndIf				
clin1 += cSep 	
			
// - 15 Versión 			
clin1 += "2"						
clin1 += cSep 

clin1 += chr(13)+chr(10)				 	
fWrite(nHdl,clin1)


If nHdl <= 0
	ApMsgStop(STR0015)
Else
			
/*
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Itens do Arquivo                                     ³ Data ³31.10.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/
			
		dbSelectArea("QRYSF3")
		QRYSF3->(dbGoTop())
	 	cSerie 		:= QRYSF3->F3_SERIE
		cFactura 	:= QRYSF3->F3_NFISCAL
		cClieFor 	:= QRYSF3->F3_CLIEFOR
	 	cLoja			:= QRYSF3->F3_LOJA	 
		cEspecie	:=QRYSF3->F3_ESPECIE
		
		
		Do While QRYSF3->(!EOF()) .and. cSerie == QRYSF3->F3_SERIE  .and.    cFactura == QRYSF3->F3_NFISCAL .and.   cClieFor == QRYSF3->F3_CLIEFOR   .And. cLoja == QRYSF3->F3_LOJA  .and. cEspecie ==QRYSF3->F3_ESPECIE
				cNumDoc:=QRYSF3->F3_NFISCAL
				If QRYSF3->F3_TIPOMOV =="C"
					If AllTrim(QRYSF3->F3_ESPECIE) $ "NF|NDI|NCP|NCI|NCP|NDP"
						Posicione("SA2",1,xFilial("SA2")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A2_NOME") 	
						If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)
							cCGC+= QRYSF3->F3_OBSERV			
						Else
							cCGC+= SA2->A2_CGC	
						EndIf
					EndIf		
				Else
					Posicione("SA1",1,xFilial("SA1")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA,"A1_NOME") 	
					If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)
						cCGC+= QRYSF3->F3_OBSERV	
					Else	
						cCGC+= SA1->A1_CGC				
					EndIf
				EndIf
					
				cNumTim:=""				
				//  Número de Timbrado	
				If AllTrim(QRYSF3->F3_ESPECIE) $ "NDP|NDE|NCI|NCC" .Or. QRYSF3->F3_TES < "500" 						
					
					dbSelectArea("SF1")
					SF1->(DbSetOrder(1))
					If !SF1->(MsSeek(xFilial("SF1")+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_TIPO))	
						SF1->(MsSeek(QRYSF3->F3_FILIAL+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_TIPO))	
					EndIf
					cNumTim:= SF1->F1_NUMTIM
					If Alltrim(SF1->F1_TIPNOTA) == "01"  .OR. EMPTY(Alltrim(SF1->F1_TIPNOTA)) .AND. Alltrim(SF1->F1_TIPODOC) == "10"
						cTpNf:="1"
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NDP|NDE"  //DEBITO
						cTpNf:="2"                                          
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NCI|NCC"  // CREDITO
		                cTpNf:="3"				
					ElseIf Alltrim(SF1->F1_TIPNOTA) == "04"  .Or. Alltrim(QRYSF3->F3_NFISCAL+QRYSF3->F3_LOJA) == "99999901" .Or. QRYSF3->F3_ESTADO == "EX" // Despacho
	 	                cTpNf:="4"
		            	If !Empty(SF1->F1_NUMDES)
		            		cNumDoc:=SF1->F1_NUMDES
		            	EndIf
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "05" // Auto factura 
		                cTpNf:="5"	
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "07" //Pasaje Aéreo 
		                cTpNf:="7"
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "08" //Factura del Exterior 
		                cTpNf:="8"
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "11" //Retención Absorbida 
		                cTpNf:="11"
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "13" //Pasaje Aéreo Electrónico 
		                cTpNf:="13"	                   		                   		                   		                   						
					ElseIf Alltrim(SF1->F1_TIPNOTA) == "14" //Pasaje Aéreo Electrónico 
		                cTpNf:="14"	                   		                   		                   		                   						
		            Endif
		         Else		         
		         	dbSelectArea("SF2")
		         	SF2->(DbSetOrder(1))
		         	If !SF2->(MsSeek(xFilial("SF2")+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_FORMUL+QRYSF3->F3_TIPO)) 
		         		SF2->(MsSeek(QRYSF3->F3_FILIAL+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_FORMUL+QRYSF3->F3_TIPO))
		         	EndIf
		         	cNumTim:= SF2->F2_NUMTIM
		         	If Alltrim(SF2->F2_TIPNOTA) == "01"  .OR. EMPTY(Alltrim(SF2->F2_TIPNOTA)) .AND. Alltrim(SF2->F2_TIPODOC) == "01"
						cTpNf:="1"
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NDI|NDC"  //DEBITO
						cTpNf:="2"                                          
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NCP|NCE"  // CREDITO
		                cTpNf:="3"				
					ElseIf Alltrim(SF2->F2_TIPNOTA) == "06" //Boleta de Venta
	 	                cTpNf:="6"	
		            ElseIf Alltrim(SF2->F2_TIPNOTA) == "07" //Pasaje Aéreo 
		                cTpNf:="7"
		            ElseIf Alltrim(SF2->F2_TIPNOTA) == "12" //Factura Exporación
		                cTpNf:="12"
		            ElseIf Alltrim(SF2->F2_TIPNOTA) == "13" //Pasaje Aéreo Electrónico 
		                cTpNf:="13"
					ElseIf Alltrim(SF2->F2_TIPNOTA) == "14" //Pasaje Aéreo Electrónico 
		                cTpNf:="14"	                   		                   		                   		                   							                   		                   		                   		                   						
		            Endif
		         EndIf
		         
		        nDesc:=Msdecimais(1) 
	            clin1   := ""
	            
	            // - 01 Tipo Registro 			
				clin1 += "2"
				clin1 += cSep
						
				// - 02 RUC Proveedor      //03 DV Proveedor 
				
				If QRYSF3->F3_TIPOMOV =="C"
					cRUC      := StrTran(AllTrim(SA2->A2_CGC),"-","")
					clin1 += Left(cRUC,Len(cRUC)-1)+cSep+Right(cRUC,1)
				Else
					cRUC      := StrTran(AllTrim(SA1->A1_CGC),"-","")
					clin1 +=Left(cRUC,Len(cRUC)-1)+cSep+Right(cRUC,1)
						
				EndIf			 								 	
		
				clin1 += cSep
												
				// - 04 Nombre o Denominación Proveedor 
				cDesc :=""
					If     "77777701" $ cRUC      
						cDesc:= "VENTAS A AGENTES DIPLOMATICOS"
					ElseIf  "44444401" $ cRUC      
						cDesc:= "IMPORTES CONSOLIDADOS"
   					ElseIf  "88888801" $ cRUC      
						cDesc:= "CLIENTES DEL EXTERIOR"
					Else   
				  		If QRYSF3->F3_TIPOMOV =="C"		
							cDesc := AllTrim(SA2->A2_NOME)
						Else
							cDesc := AllTrim(SA1->A1_NOME)
						EndIf	
					EndIf
				
	
				clin1 += cDesc
					
				clin1 += cSep
			
				If MV_PAR16 == 2								
		            // - 05 tipo de Documento Ventas
					clin1 += cTpNf						
					clin1 += cSep 
					
					// - 06 Número Documento 	
					If cTpNf $ "1|2|3" .Or. cTpNf == "12" .Or. cTpNf == "6"
						clin1 += Transform(StrTran(cNumDoc,"-",""),"@R XXX-XXX-XXXXXXX")
					Else	
						clin1 += Transform(StrTran(cNumDoc,"-",""),"@R XXXXXXXXXXXXXXXXXXXX") 
					EndIf	
					clin1 += cSep	
					
					// - 07 Fecha Documento            
					cData:=dTos(QRYSF3->F3_EMISSAO)
					clin1 += Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/"+Substr(cData,1,4)				
					clin1 += cSep
				    
				    cPesq:=QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL 
				    cDoc:= QRYSF3->F3_NFISCAL
				    cEspecie:=QRYSF3->F3_ESPECIE
				    nBasTxt:=0
					nValTxt:=0
					nBastxt1:=0
					nValTxt1:=0
					nExentxt:=0
				    cFactura := QRYSF3->F3_NFISCAL 
        			cSerie := QRYSF3->F3_SERIE
        			cClieFor :=  QRYSF3->F3_CLIEFOR   
        			cLoja 		:= QRYSF3->F3_LOJA
        			cEspecie 	:=QRYSF3->F3_ESPECIE
        			Do While QRYSF3->(!EOF()) .and. cFactura == QRYSF3->F3_NFISCAL   .And.  cSerie == QRYSF3->F3_SERIE  .and.  cClieFor ==  QRYSF3->F3_CLIEFOR   .and. cLoja == QRYSF3->F3_LOJA;
        			       .And.  cEspecie == QRYSF3->F3_ESPECIE
        			       
        					If Empty(QRYSF3->F3_DTCANC)
        						If 	QRYSF3->F3_ALQIMP1 == 10
					   				nBasTxt += noRound(QRYSF3->F3_BASIMP1,nDesc)
					   				nValTxt += noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                     			If 	QRYSF3->F3_ALQIMP1 == 5		
					  				nBastxt1 += noRound(QRYSF3->F3_BASIMP1,nDesc) 
					  				nValTxt1+= noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                                nExenTxt += noRound(QRYSF3->F3_EXENTAS,nDesc)     
                            EndIf          
                          	QRYSF3->(dbSkip())	
                    EndDo
        
					clin1 += Transform(nBasTxt,"")	
		  			clin1 += cSep
					
					// - 08 IVA Crédito 10% 
						clin1 += Transform(nValTxt,"")	
						clin1 += cSep
									
					// - 09 Monto de la Compra a la Tasa 5% 
							clin1 += Transform(nBastxt1,"")	
							clin1 += cSep 
					  		
					// - 10 IVA Crédito 5% 
						clin1 += Transform(nValTxt1,"")	
						clin1 += cSep
																			  																						  
					// - 11 Monto de Compra no Gravada o Exenta 
						clin1 += Transform(nExenTxt,"")						
						clin1 += cSep  
										  										  
					// - 12 Monto del Ingresso
						clin1 += Alltrim(str(nBasTxt + nValTxt + nBastxt1 + nValTxt1 + nExenTxt))					
						clin1 += cSep 

					// - 13 Condición Compra 
					cSoma:= 0
					SF1->(DbCloseArea())
					dbSelectArea("SE2")
					SE2->(dbGoTop())
					SE2->(DbSetOrder(1))
					SE2->(MsSeek(xFilial("SE2")+cPesq )) //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL))
					If ALLTRIM(SE2->E2_TIPO)$ "NCP|NCI|NDP|NDI" .Or. ALLTRIM(SE2->E2_ORIGEM) == "MATA100"
						If !SE2->(MsSeek(xFilial("SE2")+cPesq))  //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL)) 
							SE2->(MsSeek(QRYSF3->F3_FILIAL+cPesq))   //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL))
						EndIf	
						lCredito:=.F.
						If SE2->E2_EMISSAO <>  SE2->E2_VENCTO		  
							lCredito:=.T.
						EndIf
						Do While AllTrim(SE2->E2_NUM) == AllTrim(cDoc) .AND. AllTrim(se2->e2_TIPO) == AllTrim(cEspecie) 															
							cSoma++
							SE2->(DbSkip())  
						EndDo						
					Else
						SE2->(DbCloseArea())
						dbSelectArea("SE1")
						SE1->(dbGoTop())
						SE1->(DbSetOrder(1))
						lCredito:=.F.
						If !SE1->(MsSeek(xFilial("SE1")+cPesq))//QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL)) //+QRYSF3->F3_ESPECIE))															 
							SE1->(MsSeek(QRYSF3->F3_FILIAL+cPesq)) //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL)) //+QRYSF3->F3_ESPECIE))															
					    EndIf     
					    If SE1->E1_EMISSAO <> SE1->E1_VENCTO
					    	lCredito:=.T.
					    EndIf
						Do While AllTrim(SE1->E1_NUM) == AllTrim(cDoc) .AND. AllTrim(SE1->E1_TIPO) == AllTrim(cEspecie)  
							cSoma++
							SE1->(DbSkip())  
						EndDo
					EndIf
					
					If cSoma > 1 .or. lCredito
						clin1 += "2"
					Else
						clin1 += "1"
					EndIf	
						
					clin1 += cSep 
				
					// - 14 Cantidad Cuotas 
					If Transform(Round(cSoma ,0),"@E") > "1"  .or.  lCredito
						clin1 += Transform(Round(cSoma ,0),"@E")
					Else
						clin1 += "0"
					EndIf	
					clin1 += cSep 				
				
					SE1->(DbCloseArea())
						
					
					// - 16 Numero Timbrado
					If cTpNf == "7" .Or. cTpNf == "13"
						clin1 += "0"//Replicate("0",8)						
					ElseIf Empty(AllTrim(cNumTim))
						clin1 += Replicate("0",8)					
					Else
						clin1 += AllTrim(cNumTim)						
					EndIf					
					clin1 += cSep
	
					clin1 += chr(13)+chr(10)	
						 	
					fWrite(nHdl,clin1)
					cFactura := QRYSF3->F3_NFISCAL	
					cSerie := QRYSF3->F3_SERIE  
					cClieFor := QRYSF3->F3_CLIEFOR 
					cLoja := QRYSF3->F3_LOJA
					cEspecie:=QRYSF3->F3_ESPECIE
					 	
					nBasTxt := 0
					nValTxt := 0
					nBasTxt1 := 0
					nValTxt1 := 0
					nExentxt := 0
				
				Else	
				                                     //Entrada
					// - 05 Número de Timbrado					 
				
					
					If cTpNf $ "4|7|8|" .Or. cTpNf == "11" .Or. cTpNf == "13"
							clin1 += "0"//Replicate("0",13)						
					ElseIf Empty(AllTrim(cNumTim))
							clin1 += Replicate("0",20)					
					Else
							clin1 += AllTrim(cNumTim)						
					EndIf					
					
					// - 06 tipo de Documento 
					clin1 += cSep 
										  
					clin1 += cTpNf						
					
					clin1 += cSep 
					
					// - 07	Número Documento 
					If cTpNf == "11"
						clin1 += "0"
					ElseIf cTpNf $ "4|7|8" .Or. cTpNf == "13"
						clin1 += Transform(StrTran(cNumDoc,"-",""),"@R XXXXXXXXXXXXXXX")
					Else	
						clin1 += Transform(StrTran(cNumDoc,"-",""),"@R XXX-XXX-XXXXXXX") 
					EndIf	
					clin1 += cSep 
							  
					// - 08 Fecha Documento  
					cData:=Dtos(QRYSF3->F3_EMISSAO)
					clin1 += Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/"+Substr(cData,1,4)				
					clin1 += cSep
					
	            /*
					// - 09 Monto de la Compra a la Tasa 10% 
					If 	QRYSF3->F3_ALQIMP1 == 10
						nBastxt += QRYSF3->F3_BASIMP1
						clin1 += Transform(Round(nBasTxt,1),"")	
					Else
						clin1 += Transform(Round(nBasTxt,1),"")										
					EndIf
					clin1 += cSep
					
					// - 10 IVA Crédito 10% 
					If 	QRYSF3->F3_ALQIMP1 == 10
						nValTxt += QRYSF3->F3_VALIMP1
						clin1 += Transform(Round(nValTxt,1),"")	
					Else
						clin1 += Transform(Round(nValTxt,1),"")							
					EndIf
					clin1 += cSep
									
					// - 11 Monto de la Compra a la Tasa 5% 
					If 	QRYSF3->F3_ALQIMP1 == 5		
						nBastxt1 += QRYSF3->F3_BASIMP1
						clin1 += Transform(Round(nBastxt1,1),"")	
					Else
						clin1 += Transform(Round(nBastxt1,1),"")	
					EndIf					
					clin1 += cSep 
					  		
					// - 12 IVA Crédito 5% 
					If 	QRYSF3->F3_ALQIMP1 == 5	
						nValTxt1+= QRYSF3->F3_VALIMP1
						clin1 += Transform(Round(nValTxt1,1),"")	
					Else
						clin1 += Transform(Round(nValTxt1,1),"")	
					EndIf						
					clin1 += cSep
																			  																						  
					// - 13 Monto de Compra no Gravada o Exenta 
					nExenTxt += QRYSF3->F3_EXENTAS 				
					clin1 += Transform(Round(nExenTxt,1),"")						
					clin1 += cSep 
				*/
				
				  cPesq:=QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL 
				    cDoc:= QRYSF3->F3_NFISCAL
				    cEspecie:=QRYSF3->F3_ESPECIE 
				    nBasTxt	:=0
					nValTxt		:=0
					nBastxt1	:=0
					nValTxt1	:=0
					nExentxt	:=0      
					cSerie 		:= QRYSF3->F3_SERIE
				    cFactura 	:= QRYSF3->F3_NFISCAL 
				     cClieFor 	:=  QRYSF3->F3_CLIEFOR   
				     cLoja		:= QRYSF3->F3_LOJA
				     		    
				    Do While QRYSF3->(!EOF()) .and. cSerie == QRYSF3->F3_SERIE .and.  cFactura == QRYSF3->F3_NFISCAL  .And. cClieFor ==  QRYSF3->F3_CLIEFOR     ;
				    	.And. cLoja == QRYSF3->F3_LOJA   .And. cEspecie==QRYSF3->F3_ESPECIE 
        					If Empty(QRYSF3->F3_DTCANC)
        						If 	QRYSF3->F3_ALQIMP1 == 10
					   				nBasTxt += noRound(QRYSF3->F3_BASIMP1,nDesc)
					   				nValTxt += noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                     			If 	QRYSF3->F3_ALQIMP1 == 5		
					  				nBastxt1 += noRound(QRYSF3->F3_BASIMP1,nDesc) 
					  				nValTxt1+= noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                                nExenTxt += noRound(QRYSF3->F3_EXENTAS,nDesc)     
                            EndIf
                               	QRYSF3->(dbSkip())	
                      EndDo
				    
        			cFactura := QRYSF3->F3_NFISCAL	
					cSerie := QRYSF3->F3_SERIE  
					cClieFor := QRYSF3->F3_CLIEFOR 
					cLoja := QRYSF3->F3_LOJA
					cEspecie:=QRYSF3->F3_ESPECIE

			        //09 10 Monto de la Compra a la Tasa 10%
					clin1 += Transform(nBasTxt,"")	
		  				clin1 += cSep
					
					// - 10 IVA Crédito 10% 

						clin1 += Transform(nValTxt,"")	

						clin1 += cSep
									
					// - 11 Monto de la Compra a la Tasa 5% 
							clin1 += Transform(nBastxt1,"")	
							clin1 += cSep 
					  		
					// - 12 IVA Crédito 5% 
	
						clin1 += Transform(nValTxt1,"")	
	
						clin1 += cSep
																			  																						  
					// - 13 Monto de Compra no Gravada o Exenta 
	
						clin1 += Transform(nExenTxt,"")						
						clin1 += cSep  
				
	
					// - 14 Tipo de Operación 
					If MV_PAR15 == 1  				  
						clin1 += "0"	
					Else
						clin1 += "8"
					EndIf						
					clin1 += cSep 
					
					// - 15 Condición Compra 
					cSoma:= 0
					SF1->(DbCloseArea())
					dbSelectArea("SE2")
					SE2->(dbGoTop())
					SE2->(DbSetOrder(1))
					SE2->(MsSeek(xFilial("SE2")+ cPesq))//QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL))
					If ALLTRIM(SE2->E2_TIPO)$ "NCP|NCI|NDP|NDI" .Or. AllTrim(SE2->E2_ORIGEM) == "MATA100"																					
						lCredito:=.F.																			
						If SE2->E2_EMISSAO <>  SE2->E2_VENCTO		  
							lCredito:=.T.
						EndIf
						Do While alltrim(SE2->E2_NUM) == AllTrim(cDoc) .AND. AllTrim(SE2->E2_TIPO) == AllTrim(cEspecie) .AND. AllTrim(SE2->E2_TIPO) <> "TX"  // .AND. AllTrim(DTOS(SE2->E2_VENCTO)) <> AllTrim(QRYSF3->F3_ENTRADA) .AND. AllTrim(SE2->E2_TIPO) <> "TX"															
							cSoma++
							SE2->(DbSkip()) 
						EndDo						
					Else
						SE2->(DbCloseArea())
						dbSelectArea("SE1")
						SE1->(dbGoTop())
						SE1->(DbSetOrder(1))
						SE1->(MsSeek(xFilial("SE1")+QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL+QRYSF3->F3_ESPECIE))															
						lCredito:=.F.	
						If SE1->E1_EMISSAO <>  SE1->E1_VENCTO		  
							lCredito:=.T.
						EndIf
						Do While alltrim(SE1->E1_NUM) == alltrim(cDoc) .AND. alltrim(SE1->E1_TIPO) == AllTrim(cEspecie)  .AND. AllTrim(SE1->E1_TIPO) <> "TX"	//AND. AllTrim(DTOS(SE1->E1_VENCTO)) <> AllTrim(QRYSF3->F3_ENTRADA) .AND. AllTrim(SE1->E1_TIPO) <> "TX"	
							cSoma++
							SE1->(DbSkip()) 
						EndDo
					EndIf
					
					If cSoma > 1   .or. lCredito
						clin1 += "2"
					Else
						clin1 += "1"
					EndIf	
						
					clin1 += cSep 
					
					// - 16 Cantidad Cuotas 
                   
					
					If Transform(Round(cSoma ,0),"@E") > "1"     .or.  lCredito
						clin1 += Transform(Round(cSoma ,0),"@E")
					Else
						clin1 += "0"
					EndIf	
					clin1 += cSep 				
					
					SE1->(DbCloseArea())
												
				   //	QRYSF3->(dbSkip())	
										
					clin1 += chr(13)+chr(10)	
				  		 	
					fWrite(nHdl,clin1)
					cFactura := QRYSF3->F3_NFISCAL	
					cSerie := QRYSF3->F3_SERIE  
					cClieFor := QRYSF3->F3_CLIEFOR 
					cLoja := QRYSF3->F3_LOJA
					cEspecie:=QRYSF3->F3_ESPECIE 
						
							
					nBasTxt  := 0
					nValTxt  := 0
					nBasTxt1 := 0
					nValTxt1 := 0
					nExentxt := 0
										
				EndIf
		EndDo	
		
		fClose(nHdl)
		MsgAlert(STR0011)
EndIf
Return Nil


/*/{Protheus.doc} GerArq2
	@author adrian.perez
	@since 20/11/2021
	@version version
	@param cDir, caracter, nombre archivo con extension .txt
	@param cQuant,caracter,Cantidad Registro
	@param nTot5,numerico, total iva 5% base
	@param nTot5v,numerico, total iva 5% valor
	@param nTot10,numerico, total iva 10% base
	@param nTot10v,numerico, total iva 10% valor
	@param nTExent,numerico, total excento 
	@return nil

	/*/

Static Function GerArq2(cRuta,cQuant,nTot5,nTot5v,nTot10,nTot10v,nTExent)

Local nHdl     := 0
Local clin1    := ""
Local cSep     := CHR(9)
Local nCont    := 0
Local nRuc     := ""
Local cNif	   := "" 
Local cTpNf    := ""
Local cCGC     := ""
Local nBasTxt := 0
Local nValTxt := 0
Local nBasTxt1 := 0
Local nValTxt1 := 0
Local nExentxt := 0                 
Local nDesc:=Msdecimais(1)
Local lCredito:=.f.
Local nContador:=0
Local nLote:=MV_PAR19
Local nMoeda	:= ""

Local cNumDocO	:=""
Local nNumTimO	:=""
Local aAreaAT	:={}
Local aAreaSF1	:={}
Local aAreaSD1	:={}
Local aAreaSF2	:={}
Local aAreaSD2	:={}
Local aArchivos:={}
Local aAux:={}
Local  nAd:=0
Local cTabla:=""
Local nOrder:=1
Private cDir:=cRuta

FOR nCont:=LEN(AllTrim(cDir)) TO 1 STEP -1
	IF (SUBSTR(cDir,nCont,1)=='\') .or. (SUBSTR(cDir,nCont,1)=='.')
		cDir:=Substr(cDir,1,nCont)
		EXIT
	ENDIF	
NEXT
aAux:=crearArchivo(cDir,CVALTOCHAR(nLote))
nHdl := aAux[1]
Aadd(aArchivos, aAux[2])
	
If nHdl <= 0
	ApMsgStop(STR0015)
Else
			
/*
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Itens do Arquivo                                     ³ Data ³31.10.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/
			
		dbSelectArea("QRYSF3")
		QRYSF3->(dbGoTop())
	 	cSerie 		:= QRYSF3->F3_SERIE
		cFactura 	:= QRYSF3->F3_NFISCAL
		cClieFor 	:= QRYSF3->F3_CLIEFOR
	 	cLoja			:= QRYSF3->F3_LOJA	 
		cEspecie	:=QRYSF3->F3_ESPECIE
		
		
		Do While QRYSF3->(!EOF()) .and. cSerie == QRYSF3->F3_SERIE  .and.    cFactura == QRYSF3->F3_NFISCAL .and.   cClieFor == QRYSF3->F3_CLIEFOR   .And. cLoja == QRYSF3->F3_LOJA  .and. cEspecie ==QRYSF3->F3_ESPECIE
				cNumDoc:=QRYSF3->F3_NFISCAL
				If QRYSF3->F3_TIPOMOV =="C"
					If AllTrim(QRYSF3->F3_ESPECIE) $ "NF|NDI|NCP|NCI|NCP|NDP"
						dbSelectArea("SA2")
						SA2->(dbGoTop())
						SA2->(DbSetOrder(1))
						SA2->(MsSeek(xFilial("SA2")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA))
						If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)
							cCGC+= QRYSF3->F3_OBSERV			
						Else
							cCGC+= SA2->A2_CGC	
						EndIf
					EndIf		
				Else
					dbSelectArea("SA1")
					SA1->(dbGoTop())
					SA1->(DbSetOrder(1))
					SA1->(MsSeek(xFilial("SA1")+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA))
					If MV_PAR03 == 3 .And. !Empty(QRYSF3->F3_DTCANC)
						cCGC+= QRYSF3->F3_OBSERV	
					Else	
						cCGC+= SA1->A1_CGC				
					EndIf
				EndIf
					
				cNumTim:=""				
				//  Número de Timbrado	
				If AllTrim(QRYSF3->F3_ESPECIE) $ "NDP|NDE|NCI|NCC" .Or. QRYSF3->F3_TES < "500" 						
					
					dbSelectArea("SF1")
					SF1->(DbSetOrder(1))
					If !SF1->(MsSeek(xFilial("SF1")+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_TIPO))	
						SF1->(MsSeek(QRYSF3->F3_FILIAL+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_TIPO))	
					EndIf
					cNumTim:= SF1->F1_NUMTIM
					If Alltrim(SF1->F1_TIPNOTA) == "01"  .OR. EMPTY(Alltrim(SF1->F1_TIPNOTA)) .AND. Alltrim(SF1->F1_TIPODOC) == "10"
						cTpNf:="109"
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NDP|NDE"  //DEBITO
						cTpNf:="110"                                          
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NCI|NCC"  // CREDITO
		                cTpNf:="110"				
					ElseIf Alltrim(SF1->F1_TIPNOTA) == "04"  .Or. Alltrim(QRYSF3->F3_NFISCAL+QRYSF3->F3_LOJA) == "99999901" .Or. QRYSF3->F3_ESTADO == "EX" // Despacho
	 	                cTpNf:="107"
		            	If !Empty(SF1->F1_NUMDES)
		            		cNumDoc:=SF1->F1_NUMDES
		            	EndIf
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "05" // Auto factura 
		                cTpNf:="101"	
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "07" //07Pasaje Aéreo 
		                cTpNf:="106"
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "08" //Factura del Exterior 
		                cTpNf:="202"
		            ElseIf Alltrim(SF1->F1_TIPNOTA) == "13" //13Pasaje Aéreo Electrónico 
		                cTpNf:="106"	                   		                   		                   		                   						
					ElseIf Alltrim(SF1->F1_TIPNOTA) == "14" //BOLETA RESIMPLE 
		                cTpNf:="104"	                   		                   		                   		                   						
					ElseIf Alltrim(SF1->F1_TIPNOTA) == "15" //Boleta Transporte Público		                   		                   		                   		                   						
		                cTpNf:="102"
		            Endif
					nMoeda := SF1->F1_MOEDA
		         Else		         
		         	dbSelectArea("SF2")
		         	SF2->(DbSetOrder(1))
		         	If !SF2->(MsSeek(xFilial("SF2")+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_FORMUL+QRYSF3->F3_TIPO)) 
		         		SF2->(MsSeek(QRYSF3->F3_FILIAL+QRYSF3->F3_NFISCAL+QRYSF3->F3_SERIE+QRYSF3->F3_CLIEFOR+QRYSF3->F3_LOJA+QRYSF3->F3_FORMUL+QRYSF3->F3_TIPO))
		         	EndIf
		         	cNumTim:= SF2->F2_NUMTIM
		         	If Alltrim(SF2->F2_TIPNOTA) == "01"  .OR. EMPTY(Alltrim(SF2->F2_TIPNOTA)) .AND. Alltrim(SF2->F2_TIPODOC) == "01"
						cTpNf:="109"
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NDI|NDC"  //DEBITO
						cTpNf:="111"                                          
					ElseIf Alltrim(QRYSF3->F3_ESPECIE) $ "NCP|NCE"  // CREDITO
		                cTpNf:="110"				
					ElseIf Alltrim(SF2->F2_TIPNOTA) == "06" //Boleta de Venta
	 	                cTpNf:="103"	
		            ElseIf Alltrim(SF2->F2_TIPNOTA) == "07" //Pasaje Aéreo 
		                cTpNf:="106"
		            ElseIf Alltrim(SF2->F2_TIPNOTA) == "13" //Pasaje Aéreo Electrónico 
		                cTpNf:="106"
					ElseIf Alltrim(SF2->F2_TIPNOTA) == "14" //BOLETA RESIMPLE
		                cTpNf:="104"	                   		                   		                   		                   							                   		                   		                   		                   						
					ElseIf Alltrim(SF2->F2_TIPNOTA) == "15" //Boleta Transporte Público
		                cTpNf:="102"	
		            Endif
					nMoeda := SF2->F2_MOEDA
		         EndIf
		         
		        nDesc:=Msdecimais(1) 
	            clin1   := ""
	            
	            // - 01 Tipo Registro 			
				clin1 += IIf (MV_PAR16 == 1,"2","1")
				clin1 += cSep
						
				// - 02 CÓDIGO TIPO DE IDENTIFICACIÓN DEL COMPRADOR
				
				If QRYSF3->F3_TIPOMOV =="C" //*
					IF  cTpNf=="101"
						clin1 += "12"
					ElseIF  cTpNf=="107"
						clin1 += "17"
					ELSE
						clin1 += "11"
					END If
				Else
					If !Empty(AllTrim(SA1->A1_CGC)) 
						clin1 += "11"
					Else
						If !Empty(AllTrim(SA1->A1_NIF)) 
							If (AllTrim(SA1->A1_TIPDOC)) =="1" //CÉDULA
								clin1 += "12"
							ElseIf (AllTrim(SA1->A1_TIPDOC)) =="2"  //PASAPORTE
								clin1 += "13"
							ElseIf (AllTrim(SA1->A1_TIPDOC)) =="3" //CÉDULA EXTRANJERA
								clin1 += "14"
							ElseIf (AllTrim(SA1->A1_TIPDOC)) =="6" //DIPLOMATICO
								clin1 += "16"
							EndIf
						EndIf	
					EndIf			
				EndIf			 								 	
		
				clin1 += cSep

				//03 NÚMERO DE IDENTIFICACIÓN DEL COMPRADOR
				If QRYSF3->F3_TIPOMOV =="C"
					nRuc:=Len(ALLTRIM(SA2->A2_CGC))
					cRUC :=Iif(Subs(ALLTRIM(SA2->A2_CGC),nRuc-1,1)=="-",Subs(ALLTRIM(SA2->A2_CGC),0,nRuc-2),ALLTRIM(SA2->A2_CGC) )
					clin1 +=cRUC
				Else
					If !Empty(AllTrim(SA1->A1_CGC))
						nRuc:=Len(ALLTRIM(SA1->A1_CGC))
						cRUC:=Iif(Subs(ALLTRIM(SA1->A1_CGC),nRuc-1,1)=="-",Subs(ALLTRIM(SA1->A1_CGC),0,nRuc-2),ALLTRIM(SA1->A1_CGC) )
						clin1 +=cRUC
					Else 	
						cNif:= Subs(AllTrim(SA1->A1_NIF),1,20)
						cNif:= Replace(cNif ,'-','')
						clin1 +=cNif
					EndIf	
				EndIf

				clin1 += cSep
												
				// - 04 Nombre o Denominación Proveedor 
				cDesc :=""
					If     "77777701" $ cRUC      
						cDesc:= "VENTAS A AGENTES DIPLOMATICOS"
					ElseIf  "44444401" $ cRUC      
						cDesc:= "IMPORTES CONSOLIDADOS"
   					ElseIf  "88888801" $ cRUC      
						cDesc:= "CLIENTES DEL EXTERIOR"
					Else   
				  		If QRYSF3->F3_TIPOMOV =="C"		
							cDesc := AllTrim(SA2->A2_NOME)
						Else
							cDesc := AllTrim(SA1->A1_NOME)
						EndIf	
					EndIf
				
	
				clin1 += cDesc
					
				clin1 += cSep
			
				If MV_PAR16 == 2								
		            // - 05 tipo de Documento Ventas
					clin1 += cTpNf						
					clin1 += cSep 
					
					// - 06  Fecha Documento   	
					cData:=dTos(QRYSF3->F3_EMISSAO)
					clin1 += Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/"+Substr(cData,1,4)
				
					clin1 += cSep	
					
					// - 07 Número timbrado   

					If cTpNf == "7" .Or. cTpNf == "13"
						clin1 += "0"//Replicate("0",8)						
					ElseIf Empty(AllTrim(cNumTim))
						clin1 += Replicate("0",8)					
					Else
						clin1 += AllTrim(cNumTim)						
					EndIF   
					clin1 += cSep   
					// - 08 Número comprobante   
					clin1 += Transform(StrTran(cNumDoc,"-",""),"@R XXX-XXX-XXXXXXX")	
					clin1 += cSep

				    
				    cPesq:=QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL 
				    cDoc:= QRYSF3->F3_NFISCAL
				    cEspecie:=QRYSF3->F3_ESPECIE
				    nBasTxt:=0
					nValTxt:=0
					nBastxt1:=0
					nValTxt1:=0
					nExentxt:=0
				    cFactura := QRYSF3->F3_NFISCAL 
        			cSerie := QRYSF3->F3_SERIE
        			cClieFor :=  QRYSF3->F3_CLIEFOR   
        			cLoja 		:= QRYSF3->F3_LOJA
        			cEspecie 	:=QRYSF3->F3_ESPECIE
        			Do While QRYSF3->(!EOF()) .and. cFactura == QRYSF3->F3_NFISCAL   .And.  cSerie == QRYSF3->F3_SERIE  .and.  cClieFor ==  QRYSF3->F3_CLIEFOR   .and. cLoja == QRYSF3->F3_LOJA;
        			       .And.  cEspecie == QRYSF3->F3_ESPECIE
        			       
        					If Empty(QRYSF3->F3_DTCANC)
        						If 	QRYSF3->F3_ALQIMP1 == 10
					   				nBasTxt += noRound(QRYSF3->F3_BASIMP1,nDesc)
					   				nValTxt += noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                     			If 	QRYSF3->F3_ALQIMP1 == 5		
					  				nBastxt1 += noRound(QRYSF3->F3_BASIMP1,nDesc) 
					  				nValTxt1+= noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                                nExenTxt += noRound(QRYSF3->F3_EXENTAS,nDesc)     
                            EndIf          
                          	QRYSF3->(dbSkip())	
                    EndDo
					
					
					// - 09 IVA Crédito 10% 
						clin1 += Transform(nBasTxt+nValTxt,"")	
						clin1 += cSep
									
					  		
					// - 10 IVA Crédito 5% 
						clin1 += Transform(nBastxt1+nValTxt1,"")	
						clin1 += cSep
																			  																						  
					// - 11 Monto de Compra no Gravada o Exenta 
						clin1 += Transform(nExenTxt,"")						
						clin1 += cSep  
										  										  
					// - 12 Monto del Ingresso
						clin1 += Alltrim(str(nBasTxt + nValTxt + nBastxt1 + nValTxt1 + nExenTxt))					
						clin1 += cSep 

					// - 13 Condición Compra 
					cSoma:= 0
					SF1->(DbCloseArea())
					dbSelectArea("SE2")
					SE2->(dbGoTop())
					SE2->(DbSetOrder(1))
					SE2->(MsSeek(xFilial("SE2")+cPesq )) //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL))
					If ALLTRIM(SE2->E2_TIPO)$ "NCP|NCI|NDP|NDI" .Or. ALLTRIM(SE2->E2_ORIGEM) == "MATA100"
						If !SE2->(MsSeek(xFilial("SE2")+cPesq))  //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL)) 
							SE2->(MsSeek(QRYSF3->F3_FILIAL+cPesq))   //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL))
						EndIf	
						lCredito:=.F.
						If SE2->E2_EMISSAO <>  SE2->E2_VENCTO		  
							lCredito:=.T.
						EndIf
						Do While AllTrim(SE2->E2_NUM) == AllTrim(cDoc) .AND. AllTrim(se2->e2_TIPO) == AllTrim(cEspecie) 															
							cSoma++
							SE2->(DbSkip())  
						EndDo						
					Else
						SE2->(DbCloseArea())
						dbSelectArea("SE1")
						SE1->(dbGoTop())
						SE1->(DbSetOrder(1))
						lCredito:=.F.
						If !SE1->(MsSeek(xFilial("SE1")+cPesq))//QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL)) //+QRYSF3->F3_ESPECIE))															 
							SE1->(MsSeek(QRYSF3->F3_FILIAL+cPesq)) //QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL)) //+QRYSF3->F3_ESPECIE))															
					    EndIf     
					    If SE1->E1_EMISSAO <> SE1->E1_VENCTO
					    	lCredito:=.T.
					    EndIf
						Do While AllTrim(SE1->E1_NUM) == AllTrim(cDoc) .AND. AllTrim(SE1->E1_TIPO) == AllTrim(cEspecie)  
							cSoma++
							SE1->(DbSkip())  
						EndDo
					EndIf
					SE1->(DbCloseArea())
					If cSoma > 1 .or. lCredito
						clin1 += "2"
					Else
						clin1 += "1"
					EndIf	
						
					clin1 += cSep 
					
					// - 14 OPERACIÓN EN MONEDA EXTRANJERA
					clin1+= Iif(nMoeda > 1, "S", "N")
					clin1 += cSep 				
					//15-IMPUTA AL IVA
					clin1+="S"
					clin1 += cSep 
					//16-IMPUTA AL IRE
					clin1+="N"
					clin1 += cSep 
					//17-IMPUTA AL IRP-RSP 
					clin1+="N"
					clin1 += cSep 
					cNumDocO:=""
					nNumTimO:=""
					IF Alltrim(cEspecie) $"NCP|NDC"
						IF Alltrim(cEspecie) == "NDC"
							cTabla:="F2"
							nOrder:=2
						ELSE
							cTabla:="F1"
							nOrder:=1
						ENDIF
						aAreaAT:=GetArea()
						aAreaSF1:=("S"+cTabla)->(GetArea())
						aAreaSD2:=SD2->(GetArea())
						
						dbSelectArea("SD2")
						SD2->(DbSetOrder(3))
						If MsSeek(xFilial("SD2")+cFactura+cSerie+cClieFor+cLoja) 
							cNumDocO:=SD2->D2_NFORI
							cSerieO:=SD2->D2_SERIORI
						EndIf	
						
						dbSelectArea(("S"+cTabla))
						("S"+cTabla)->(DbSetOrder(nOrder))
						IF Alltrim(cEspecie) =="NDC"
							If !Empty(cNumDocO) .And. ("S"+cTabla)->(MsSeek(xFilial(("S"+cTabla))+cClieFor+cLoja+cNumDocO+cSerieO+"N"+"NF"))
								nNumTimO:= &(("S"+cTabla)->(cTabla+"_NUMTIM"))
							EndIf
						ELSE
							
							If !Empty(cNumDocO) .And.  ("S"+cTabla)->(MsSeek(xFilial(("S"+cTabla))+cNumDocO+cSerieO+cClieFor+cLoja+"NF")) 
								nNumTimO:= &(("S"+cTabla)->(cTabla+"_NUMTIM"))
							EndIf
						ENDIF

						cNumDocO:=Transform (StrTran(cNumDocO,"-",""),"@R XXX-XXX-XXXXXXX")
						SD2->(RestArea(aAreaSD2))
						("S"+cTabla)->(RestArea(aAreaSF1))
						RestArea(aAreaAT)
					EndIf
					
					//18 NÚMERO DEL COMPROBANTE DE VENTA ASOCIADO 110 111	
					clin1 += cNumDocO
					clin1 += cSep
					//19 TIMBRADO DEL COMPROBANTE DE VENTA ASOCIAD
					clin1+= nNumTimO					
					clin1 += cSep
	
					clin1 += chr(13)+chr(10)	
						 	
					

					dividirArchivo(nHdl,clin1,@nContador,@nLote,@aArchivos)
					cFactura := QRYSF3->F3_NFISCAL	
					cSerie := QRYSF3->F3_SERIE  
					cClieFor := QRYSF3->F3_CLIEFOR 
					cLoja := QRYSF3->F3_LOJA
					cEspecie:=QRYSF3->F3_ESPECIE
					 	
					nBasTxt := 0
					nValTxt := 0
					nBasTxt1 := 0
					nValTxt1 := 0
					nExentxt := 0
				
				Else	
				        
					// - 05 tipo de Documento compras
					clin1 += cTpNf						
					clin1 += cSep 
					
					// - 06  Fecha Documento   	
					cData:=dTos(QRYSF3->F3_EMISSAO)
					clin1 += Substr(cData,7,2)+"/"+Substr(cData,5,2)+"/"+Substr(cData,1,4)
				
					clin1 += cSep	
					
					// - 07 Número timbrado   

					If cTpNf $ "4|7|8|" .Or. cTpNf == "11" .Or. cTpNf == "13"
							clin1 += "0"//Replicate("0",13)						
					ElseIf Empty(AllTrim(cNumTim))
							clin1 += Replicate("0",20)					
					Else
							clin1 += AllTrim(cNumTim)						
					EndIf   
					clin1 += cSep   
					// - 08 Número comprobante   
					clin1 += Transform(StrTran(cNumDoc,"-",""),"@R XXX-XXX-XXXXXXX")	
					clin1 += cSep
						                      				
					
				
				  	cPesq:=QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL 
				    cDoc:= QRYSF3->F3_NFISCAL
				    cEspecie:=QRYSF3->F3_ESPECIE 
				    nBasTxt	:=0
					nValTxt		:=0
					nBastxt1	:=0
					nValTxt1	:=0
					nExentxt	:=0      
					
					cSerie 		:= QRYSF3->F3_SERIE
				    cFactura 	:= QRYSF3->F3_NFISCAL 
				    cClieFor 	:=  QRYSF3->F3_CLIEFOR   
				    cLoja		:= QRYSF3->F3_LOJA
				    cEspecie:=QRYSF3->F3_ESPECIE 		    
				    
				    Do While QRYSF3->(!EOF()) .and. cSerie == QRYSF3->F3_SERIE .and.  cFactura == QRYSF3->F3_NFISCAL  .And. cClieFor ==  QRYSF3->F3_CLIEFOR     ;
				    	.And. cLoja == QRYSF3->F3_LOJA   .And. cEspecie==QRYSF3->F3_ESPECIE 
        					If Empty(QRYSF3->F3_DTCANC)
        						If 	QRYSF3->F3_ALQIMP1 == 10
					   				nBasTxt += noRound(QRYSF3->F3_BASIMP1,nDesc)
					   				nValTxt += noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                     			If 	QRYSF3->F3_ALQIMP1 == 5		
					  				nBastxt1 += noRound(QRYSF3->F3_BASIMP1,nDesc) 
					  				nValTxt1+= noRound(QRYSF3->F3_VALIMP1,nDesc)
                                EndIf
                                nExenTxt += noRound(QRYSF3->F3_EXENTAS,nDesc)     
                            EndIf
                               	QRYSF3->(dbSkip())	
                      EndDo
					// - 09 IVA Crédito 10% 
						clin1 +=iif(cTpNf$"112|104|105","0", Transform(nBasTxt+nValTxt,""))	
						clin1 += cSep
					// - 10 IVA Crédito 5% 
						clin1 +=iif(cTpNf$"112|104|105","0", Transform(nBastxt1+nValTxt1,"")	)	 
						clin1 += cSep
																			  																						  
					// - 11 Monto de Compra no Gravada o Exenta 
	
						clin1 +=iif(cTpNf$"112|104|105","0",Transform(nExenTxt,"")) 						
						clin1 += cSep  
					// - 12 Monto del Ingresso
						clin1 += iif(cTpNf$"101|112|104|105",Alltrim(str(nBasTxt)), Alltrim(str(nBasTxt + nValTxt + nBastxt1 + nValTxt1 + nExenTxt)))					
						clin1 += cSep 
	
					// - 13 Tipo de Operación 
					cSoma:= 0
					SF1->(DbCloseArea())
					dbSelectArea("SE2")
					SE2->(dbGoTop())
					SE2->(DbSetOrder(1))
					SE2->(MsSeek(xFilial("SE2")+ cPesq))//QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL))
					If ALLTRIM(SE2->E2_TIPO)$ "NCP|NCI|NDP|NDI" .Or. AllTrim(SE2->E2_ORIGEM) == "MATA100"																					
						lCredito:=.F.																			
						If SE2->E2_EMISSAO <>  SE2->E2_VENCTO		  
							lCredito:=.T.
						EndIf
						Do While alltrim(SE2->E2_NUM) == AllTrim(cDoc) .AND. AllTrim(SE2->E2_TIPO) == AllTrim(cEspecie) .AND. AllTrim(SE2->E2_TIPO) <> "TX"  // .AND. AllTrim(DTOS(SE2->E2_VENCTO)) <> AllTrim(QRYSF3->F3_ENTRADA) .AND. AllTrim(SE2->E2_TIPO) <> "TX"															
							cSoma++
							SE2->(DbSkip()) 
						EndDo						
					Else
						SE2->(DbCloseArea())
						dbSelectArea("SE1")
						SE1->(dbGoTop())
						SE1->(DbSetOrder(1))
						SE1->(MsSeek(xFilial("SE1")+QRYSF3->F3_SERIE+QRYSF3->F3_NFISCAL+QRYSF3->F3_ESPECIE))															
						lCredito:=.F.	
						If SE1->E1_EMISSAO <>  SE1->E1_VENCTO		  
							lCredito:=.T.
						EndIf
						Do While alltrim(SE1->E1_NUM) == alltrim(cDoc) .AND. alltrim(SE1->E1_TIPO) == AllTrim(cEspecie)  .AND. AllTrim(SE1->E1_TIPO) <> "TX"	//AND. AllTrim(DTOS(SE1->E1_VENCTO)) <> AllTrim(QRYSF3->F3_ENTRADA) .AND. AllTrim(SE1->E1_TIPO) <> "TX"	
							cSoma++
							SE1->(DbSkip()) 
						EndDo
					EndIf
					SE1->(DbCloseArea())
					If cSoma > 1   .or. lCredito
						clin1 += "2"
					Else
						clin1 += "1"
					EndIf	
						
					clin1 += cSep 
					
					// - 14 OPERACIÓN EN MONEDA EXTRANJERA
					clin1+= Iif(nMoeda > 1, "S", "N")
					clin1 += cSep 				
					//15-IMPUTA AL IVA
					clin1+="S"
					clin1 += cSep 
					//16-IMPUTA AL IRE
					clin1+="N"
					clin1 += cSep 
					//17-IMPUTA AL IRP-RSP 
					clin1+="N"
					clin1 += cSep 
					//18-NO IMPUTA  
					clin1+="N"
					clin1 += cSep 					
					
					cNumDocO:=""
					nNumTimO:=""
					IF Alltrim(cEspecie) =="NCC"
						aAreaAT:=GetArea()
						aAreaSF2:=SF2->(GetArea())
						aAreaSD1:=SD1->(GetArea())
						
						dbSelectArea("SD1")
						SD1->(DbSetOrder(1))
						If MsSeek(xFilial("SD1")+cFactura+cSerie+cClieFor+cLoja)                                                                                                      
							cNumDocO:=SD1->D1_NFORI
							cSerieO:=SD1->D1_SERIORI
						EndIf	
						dbSelectArea("SF2")
						SF2->(DbSetOrder(2))
						If !Empty(cNumDocO) .And. SF2->(MsSeek(xFilial("SF2")+cClieFor+cLoja+cNumDocO+cSerieO+"N"+"NF"))
							nNumTimO:=SF2->F2_NUMTIM
						EndIf
						cNumDocO:=Transform (StrTran(SD1->D1_NFORI,"-",""),"@R XXX-XXX-XXXXXXX")
						SD1->(RestArea(aAreaSD1))
						SF2->(RestArea(aAreaSF2))
						RestArea(aAreaAT)
					EndIf
					//19 NÚMERO DEL COMPROBANTE DE VENTA ASOCIADO 110 111	
					clin1 += cNumDocO
					clin1 += cSep
					//20 TIMBRADO DEL COMPROBANTE DE VENTA ASOCIAD
					clin1+= nNumTimO
					clin1 += cSep				
					clin1 += chr(13)+chr(10)	
				
					dividirArchivo(nHdl,clin1,@nContador,@nLote,@aArchivos)
					cFactura := QRYSF3->F3_NFISCAL	
					cSerie := QRYSF3->F3_SERIE  
					cClieFor := QRYSF3->F3_CLIEFOR 
					cLoja := QRYSF3->F3_LOJA
					cEspecie:=QRYSF3->F3_ESPECIE 
						
							
					nBasTxt  := 0
					nValTxt  := 0
					nBasTxt1 := 0
					nValTxt1 := 0
					nExentxt := 0
										
				EndIf
				nContador++
		EndDo	
		
		fClose(nHdl)

		For nAd := 1 To Len(aArchivos)
		 FRename(aArchivos[nAd][1]+".txt" , UPPER(aArchivos[nAd][1]+".txt"),,.F. )
         FZip(aArchivos[nAd][1]+".zip",{aArchivos[nAd][2]},cDir)
     	Next nAd
			
		MsgAlert(STR0011)
	
EndIf
Return Nil
  
/*/{Protheus.doc} crearArchivo

	@author adrian.perez
	@since 18/11/2021
	@version version

	@param cNombreArchivo, caracter, nombre del archivo
	@param cSecuencia, caracter, secuencia para el nombre del archivo
	@return aAux,array, datos del el identificador de archivo que se utilizará en las funciones para  
						archivos y nombre y ruta del archivo.
/*/
Function crearArchivo(cNombreArchivo,cSecuencia)
Local cFech1:=""
Local cFech2:=""
Local cPre:=""
Local aAux:={}
Local cAux:=''
Local  nRuc:=0
Local  cCGC:= Alltrim(SM0->M0_CGC)
	IF nRGcombo==2

		cSecuencia:=SubStr(cSecuencia,1,4)
		cFech1:= SubStr(DTOS(MV_PAR01),5,2)
		cFech2:= SubStr(DTOS(MV_PAR02),5,2)
		
		nRuc:=Len(cCGC)
		cRuc:=Iif(Subs(cCGC,nRuc-1,1)=="-",Subs(cCGC,0,nRuc-2),cCGC )

		cPre:=cRuc+"_REG_"
		If(cFech1==cFech2)
			cPre+=cFech1+SubStr(DTOS(MV_PAR01),1,4)
		else
			cPre+=SubStr(DTOS(MV_PAR01),1,4)
		EndIf
		cNombreArchivo:=cDir+cPre+iif(MV_PAR16 == 1,"_C","_V")+PadL( ALLTRIM(cSecuencia), 4,"0" )+".txt"
		cAux:=cDir+cPre+iif(MV_PAR16 == 1,"_C","_V")+PadL( ALLTRIM(cSecuencia), 4,"0" )

	ENDIF

	IF lAutomato
		cFileTest:=cNombreArchivo
	ENDIF
	aAdd(aAux,fCreate(UPPER(cNombreArchivo)))
	aAdd(aAux,{cAux,cNombreArchivo})
Return aAux

/*/{Protheus.doc} dividirArchivo

	@author adrian.perez
	@since 19/11/2021
	@version version
	@param nHdl,numerico, numero de linea en archivo
	@param clin1,caracter, informacion de la linea a grabar
	@param nContador,numerico, limite de lineas grabadas por archivo
	@param nLote,numerico, consecutivo para nombre de archivos
	@param aArchivos,array ,  se guarda utiliza para guardar los archivos creados y utilizarlos en el FZIP
	@return nil

	/*/
Function dividirArchivo(nHdl,clin1,nContador,nLote,aArchivos)
Local aAux:={}
Local cAux:=''
	IF  nRGcombo==2 .and. VAL(MV_PAR18)>0
		IF VAL(MV_PAR18)==nContador
			fClose(nHdl)
			cAux:=SubStr(CVALTOCHAR(nLote),1,4)
			nLote:=Soma1(CVALTOCHAR(VAL(cAux)))
			aAux:=crearArchivo(cDir,nLote)
			nHdl:=aAux[1]
			fWrite(nHdl,clin1)
			nContador:=0
			aadd(aArchivos,aAux[2])
		ELSE
			fWrite(nHdl,clin1)
		ENDIF
	ELSE
		fWrite(nHdl,clin1)
	ENDIF
	
Return nil


FUNCTION QRYSF3()
Local cQuery:=""
Local aAstru:=SF3->(dbSTruct())
Local cTemp:= "QRYSF3" 
Local cIndice:=""

Local aIndex := {}
Local nx:=0


If Select("QRYSF3")>0
	oTempTable:Delete()
Endif

If Select("QRYSF3")>0
	QRYSF3->(DbCloseArea())
Endif

aIndex := {"F3_ENTRADA","F3_NFISCAL","F3_SERIE","F3_CLIEFOR","F3_LOJA","F3_ESPECIE"}

cQuery := "SELECT SF3.*,"+iif(MV_PAR16 == 1," F1_TIPNOTA","F2_TIPNOTA")
cQuery += ", CASE WHEN "+iif(MV_PAR16 == 1," F1_TIPNOTA","F2_TIPNOTA")+" = '14' THEN  CONCAT ( LTRIM(RTRIM(F3_ESPECIE)), 'RESIMPLE') ELSE F3_ESPECIE END AS F3_TIPNOTA "
cQuery += " FROM "+RetSqlName("SF3")+ " SF3 "
If MV_PAR16 == 1
	cQuery+=" LEFT JOIN "+RetsqlName("SF1")+" SF1 ON F1_DOC= F3_NFISCAL AND F1_SERIE=  F3_SERIE  AND F1_FORNECE = F3_CLIEFOR "
Else	
	cQuery+=" LEFT JOIN "+RetsqlName("SF2")+" SF2 ON F2_DOC= F3_NFISCAL AND F2_SERIE=  F3_SERIE  AND F2_CLIENTE = F3_CLIEFOR "
EndIf
cQuery += " WHERE F3_FILIAL >= '"+MV_PAR05+"' "
cQuery += "AND    F3_FILIAL <= '"+MV_PAR06+"' "
cQuery += "AND    F3_ENTRADA >= '"+Dtos(MV_PAR01)+"' "
cQuery += "AND    F3_ENTRADA <= '"+Dtos(MV_PAR02)+"' "		  
 
If MV_PAR03 == 1
	cQuery += "AND    F3_DTCANC =  ' ' "		
ElseIf	MV_PAR03 == 2
	cQuery += "AND    F3_DTCANC <>  ' ' "		
EndIf		

cQuery += " AND    SF3.D_E_L_E_T_ ='' "
If MV_PAR16 == 1
	cQuery += "AND    (F3_ESPECIE IN ('NDP','NDE','NCI','NCC') OR (F3_ESPECIE='NF ' AND F3_TIPOMOV  ='C' ))"
	cQuery += " AND SF1.D_E_L_E_T_ ='' "
Else	
	cQuery += "AND     (F3_ESPECIE IN ('NDC','NCP','NDI','NCE') OR (F3_ESPECIE='NF ' AND F3_TIPOMOV  ='V' ))"	
	cQuery += " AND SF2.D_E_L_E_T_ ='' "
EndIf
/*

If MV_PAR08 = 1
	cQuery += "ORDER BY F3_EMISSAO,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE "
Else
	cQuery += "ORDER BY F3_ENTRADA,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE "
EndIf
                            */
 cQuery := ChangeQuery(cQuery)

aAdd(aAstru, {"F3_TIPNOTA" , "C", 12, 0})
oTempTable := FWTemporaryTable():New( "QRYSF3" ) // RIOMI=> REGIMEN INFORMATIVO DE OPERACIONES EN EL MERCADO INTERNO
	oTempTable:SetFields( aAstru )
	oTempTable:AddIndex("QRYSF3", aIndex )
	oTempTable:Create()
	
	SQLToTrb(cQuery,aAstru,cTemp)
  
     For nX := 1 To Len(aAstru)
          If ( aAstru[nX][2] <> "C" )
               TcSetField((cTemp),aAstru[nX][1],aAstru[nX][2],aAstru[nX][3],aAstru[nX][4])
          EndIf
     Next nX

cIndice:=""

cArqTrb := Funname() //(cTemp)
If MV_PAR08 = 1
	cIndice:=" Dtos(F3_EMISSAO)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_ESPECIE" "
Else
	cIndice:= "Dtos(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_ESPECIE "
EndIf
 IndRegua(cTemp,cArqTrb,cIndice)  


RETURN NIL
