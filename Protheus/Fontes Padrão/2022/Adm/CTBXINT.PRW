#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"                                              
#INCLUDE "fwschedule.ch"
#INCLUDE "CTBXINT.CH"

#DEFINE D_PRELAN	"9"

STATIC __aTamVlr 	:= Nil
STATIC lFWCodFil := FindFunction("FWCodFil")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³IncLast    ³ Autor ³ Claudio Donizete    			   ³ Data ³ 27/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Soma um no ultimo byte de uma string, normalmente para ser utilizado  ³±±
±±³			 ³ em pesquisas com softseek on, para posicionar no	ultimo registro + 1	 ³±±
±±³          ³de uma chave.															 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³IncLast(cString)                                                    	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³LEFT(cString, LEN(cString)-1)+ CHR(ASC(RIGHT(cString,1))+1) 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String a ser pesquisada          				 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observ.   ³  Ex.:																 ³±±
±±³			 ³	// cChave := "CLAUDIO"											     ³±±
±±³			 ³	// MsSeek(IncLast(cChave)),.T.) // MsSeek("CLAUDIP")				 ³±±
±±³			 ³	// Se na base tiver:												 ³±±
±±³			 ³	// CLAUDIO <-- Ponteiro atual    (1)                                 ³±±
±±³			 ³	// CLAUDIO															 ³±±
±±³			 ³	// CLAUDIO															 ³±±
±±³			 ³	// CLAUDIO															 ³±±
±±³			 ³	// DANIELA <-- Apos o MsSeek     (2)								 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION IncLast( cString )                              

Local cLeft    := LEFT(cString, LEN(cString)-1)
Local cLastChr := CHR(ASC(RIGHT(cString,1))+1)

If ! ( CHR(ASC(RIGHT(cString,1))) $ "Z/z/9" )	//	Se o ultimo caracter nao for "Z", "z" e "9"
	cLeft	+= cLastChr							//	Incrementa um
Else
	If CHR(ASC(RIGHT(cString,1))) == "9"
		cLeft	+= "A"
	ElseIf CHR(ASC(RIGHT(cString,1))) == "Z"
		cLeft	+= "a"
	ElseIf CHR(ASC(RIGHT(cString,1))) == "z"
		cLeft	:= Soma1(cString)
	Endif
EndIf	

RETURN(cLeft)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjuBarPath ³ Autor ³ Cristiano Denardi     ³ Data ³ 06.07.05 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ajusta string de path com ultimo caractere com "/" 					 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Path ajustado                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AjuBarPath( cPath )

Local 	cBarra := ""
Default cPath  := ""

If !Empty( cPath )
	cBarra := If(isSrvUnix(),"/","\")
	If Right(cPath,1) != cBarra
		cPath += cBarra
	Endif
Endif

Return cPath
//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCT7SP
Saldo do Plano de Contas com Stored Procedure. 
Utilizada na geração do Manad (Registro I150)

@author Alvaro Camillo Neto
@param dDataIni  Data Inicial para buscar o saldo               		   
@param dDataFim  Data Final   para buscar o saldo               		   
@param cMoeda    Moeda                                          		   
@param cFilIni   Filial Inicial                                   		
@param cFilFim   Filial Final                                     		
@param lObj      Se existe a barra de progresso                   		
@param oMeter    Barra de progresso                               		                    

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function SaldoCT7SP(dDataIni,dDataFim,cMoeda,cFilIni,cFilFim,lObj,oMeter)

Local aSaveCT7	:= CT7->(GetArea())
Local aSaveAnt	:= GetArea()
Local aStruct
Local aPeriodos := {}
Local aRet_SP	:= {}
Local aValPer

Local dData
Local dDataIniProc
Local dDataFimProc

Local cConta
Local cIniPer
Local cFimPer
Local cQueryCT7 := ""
Local cProcCT7  := "SALDO_CT7"
Local cProcCT7P := "SALDO_CT7P"
Local cRet

Local lPriVez
Local lAchouPer

Local nPer
Local nSldAnt
Local nTotReg
Local nMeter	:= 0
Local nTam		:= 0

DEFAULT cFilIni	:= xFilial("CT2")
DEFAULT cFilFim	:= xFilial("CT2")
DEFAULT __aTamVlr := TamSX3("CT2_VALOR")

dData := dDataIni-1
nTam  := TamSX3("CT1_CONTA")[1]

// Mantida estrutura da tabela temporária para compatibilização
aStruct :=	{{ "CT7_FILIAL"	, "C", IIf( lFWCodFil, FWGETTAMFILIAL, 2 ), 0 },;	// Filial
{ "CT7_CONTA"	, "C", nTam, 0 },;	// Codigo da Conta
{ "CT7_DATA"	, "C",    8, 0 },;	// Data
{ "CT7_ANTDEB"	, "N",   16, 2 },; 	// Saldo Anterior
{ "CT7_ANTCRD"	, "N",   16, 2 },; 	// Debito no Mes
{ "CT7_DEBITO"	, "N",   16, 2 },; 	// Credito no Mes
{ "CT7_CREDIT"	, "N",   16, 2 },;	// Saldo Atual
{ "CT7_ATUDEB"	, "N",   16, 2 },;	// Saldo Atual
{ "CT7_ATUCRD"	, "N",   16, 2 },;	// Saldo Atual
{ "ZERADO"		, "C",    1, 0 }}	// Flag zerado



If TcCanOpen("SLDCT7_I_"+cEmpAnt+"0")
	// Se a tabela existir, apagar os registros"
	TCSqlExec("TRUNCATE TABLE SLDCT7_I_"+cEmpAnt+"0")
Else
	DbCreate("SLDCT7_I_"+cEmpAnt+"0", aStruct, "TOPCONN")
EndIf

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Cria Procedure que vai popular a tabela temporaria                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cQueryCT7 := CriaManad1(cFilIni, cFilFim, cMoeda)
If TCSPExist( cProcCT7+"_"+cEmpAnt )
	cRet := TcSqlExec("DROP PROCEDURE "+cProcCT7+"_"+cEmpAnt)
	If cRet <> 0
		If !IsBlind()
			MsgAlert(STR0001+": "+cProcCT7+"_"+cEmpAnt)	//	"Erro na exclusao da procedure"
		EndIf
		Return .F.
	EndIf
EndIf
cRet := TcSqlExec(cQueryCT7)
If cRet < 0
	If !IsBlind()
		MsgAlert(STR0002+": "+cProcCT7+"_"+cEmpAnt)	//	'Erro na criação da procedure'
	EndIf
Return .F.
EndIf
cData := DTOS(dData)
conoutR( STR0012 + DtoC(DATE()) + " - " + TIME() )  //"Inicio Saldo Anterior: "
aRet_SP := TCSPEXEC( xProcedures(cProcCT7),cFilIni, cFilFim, DtoS(dData), cMoeda )
If Empty(aRet_SP) .Or. aRet_SP[1]=='0'
	If !IsBlind()
		MsgAlert(STR0003+": "+cProcCT7+"_"+cEmpAnt)	//	'Erro na chamada da procedure'
	EndIf
Return .F.
EndIf
conoutR( STR0004 + DtoC(DATE()) + " - " + TIME() )  //"Final  Saldo Anterior: "

cQueryCT7 :=""

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Cria Porcedure que vai popular a tabela temporaria                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cQueryCT7 := CriaManad2(cFilIni, cFilFim, cMoeda, Dtos(dDataIni), Dtos(dDataFim))
If TCSPExist( cProcCT7P+"_"+cEmpAnt )
	cRet := TcSqlExec("DROP PROCEDURE "+cProcCT7P+"_"+cEmpAnt)
	If cRet <> 0
		If !IsBlind()
			MsgAlert(STR0001+": "+cProcCT7P+"_"+cEmpAnt)	//	'Erro na exclusão da procedure'
		EndIf
		Return .F.
	EndIf
EndIf
cRet := TcSqlExec(cQueryCT7)
If cRet < 0
	If !IsBlind()
		MsgAlert(STR0002+": "+cProcCT7P+"_"+cEmpAnt)	//	'Erro na criação da procedure'
	EndIf
Return .F.
EndIf

// Refaz para os outros periodos
dDataIniProc := dDataIni
dDataFimProc := dDataFim

If dDataFim > LastDay(dDataIni)
	dDataFimProc := LastDay(dDataIni)
EndIf

While dDataFimProc <= dDataFim
	
	aadd( aPeriodos, { DtoS(dDataIniProc), DtoS(dDataFimProc) } )
	
	conoutR( STR0005+ DtoS(dDataIniProc) + ": " + DtoC(DATE()) + " - " + TIME() )  //"Inicio Periodo "
	aRet_SP := TCSPEXEC( xProcedures(cProcCT7P), cFilIni, cFilFim, cMoeda, DtoS(dDataIniProc), DtoS(dDataFimProc) )
	conoutR( STR0006+ DtoS(dDataIniProc) + ": " + DtoC(DATE()) + " - " + TIME() )  //"Final  Periodo "
	
	If Empty(aRet_SP) .Or. aRet_SP[1]=='0'
		conoutR( "SALDO_CT7P | Inicio: " + DtoS(dDataIniProc) + " | Final: " + DtoS(dDataFimProc) )
		Help(" ",1,"FILPROCCT5",,STR0003+": "+cProcCT7P+"_"+cEmpAnt,1,0) //'Erro na chamada da procedure'
		Return .F.
	EndIf
	
	dDataIniProc := dDataFimProc + 1
	dDataFimProc := LastDay(dDataIniProc)
	
	If (dDataIniProc <= dDataFim) .And. (dDataFimProc > dDataFim)
		dDataFimProc := dDataFim
	EndIf
EndDo

dbUseArea( .T.,"TOPCONN", "SLDCT7_I_"+cEmpAnt+"0", "SLDCT7", .F., .F. )
SLDCT7->( DbGoBottom() )
nTotReg := SLDCT7->( Recno() )
SLDCT7->( DbGoTop() )

TcSetField("SLDCT7","CT7_ANTDEB"  ,"N",__aTamVlr[1],__aTamVlr[2])
TcSetField("SLDCT7","CT7_ANTCRD"  ,"N",__aTamVlr[1],__aTamVlr[2])
TcSetField("SLDCT7","CT7_DEBITO"  ,"N",__aTamVlr[1],__aTamVlr[2])
TcSetField("SLDCT7","CT7_CREDIT"  ,"N",__aTamVlr[1],__aTamVlr[2])
TcSetField("SLDCT7","CT7_ATUDEB"  ,"N",__aTamVlr[1],__aTamVlr[2])
TcSetField("SLDCT7","CT7_ATUCRD"  ,"N",__aTamVlr[1],__aTamVlr[2])

IndRegua("SLDCT7","SLDCT7_I_"+cEmpAnt+"0","CT7_CONTA, CT7_DATA",,,OemToAnsi(STR0007))  //"Selecionando Registros..."

dbSelectArea("SLDCT7")

conoutR( STR0008 + DtoC(DATE()) + " - " + TIME() + " - " + AllTrim(Str(nTotReg,10)) + STR0009 )  //"Inicio Gravacao AT7: "###" Registros"

If lObj
	oMeter:SetTotal(nTotReg)
	oMeter:Set(0)
EndIf

If Len( aPeriodos ) > 0
	
	Do While ! SLDCT7->(EOF())
		
		cConta		:= SLDCT7->CT7_CONTA
		lPriVez		:= .T.
		nPer		:= 1
		nSldAnt		:= 0
		
		Do While !SLDCT7->(EOF()) .And. SLDCT7->CT7_CONTA == cConta
			
			If lPriVez
				aValPer    := {}
				lPriVez    := .F.
			Else
				nPer++
			EndIf
			
			cIniPer	:= aPeriodos[nPer,1]
			cFimPer	:= aPeriodos[nPer,2]
			
			Aadd( aValPer, { 0,0,0 } )
			// [1] : Saldo   Anterior
			// [2] : Debito  Atual	//	Debito  Anterior
			// [3] : Credito Atual	//	Debito  Atual
			
			lAchouPer	:=	.F.
			Do While !SLDCT7->(EOF()) .And. SLDCT7->CT7_CONTA == cConta .And. SLDCT7->CT7_DATA <= cFimPer
				
				If SLDCT7->ZERADO == '0'
					
					// Se estiver dentro do periodo
					IF SLDCT7->CT7_DATA >= cIniPer .And. SLDCT7->CT7_DATA <= cFimPer
						
						aValPer[nPer,1] := nSldAnt				// Saldo Anterior
						aValPer[nPer,2] += SLDCT7->CT7_DEBITO	// Débito  atual do periodo
						aValPer[nPer,3] += SLDCT7->CT7_CREDIT	// Crédito atual do periodo
						
						lPriVez 	:= .F.
						lAchouPer	:= .T.
						
					ELSEIF SLDCT7->CT7_DATA < cIniPer	//	Aqui, trata-se do saldo anterior ao 1º periodo
						
						nSldAnt	+= (SLDCT7->CT7_ATUCRD - SLDCT7->CT7_ATUDEB)	//	Saldo Anterior ao Primeiro Periodo
						
					ENDIF
				Endif
				
				If lObj
					nMeter++
					oMeter:Set(nMeter)
				EndIf
				
				SLDCT7->( DbSkip() )
			EndDo
			
			If !lAchouPer  //Se nao teve movimento no periodo, igualar o saldo final ao saldo inicial
				aValPer[nPer,1] := nSldAnt
				aValPer[nPer,2] := 0
				aValPer[nPer,3] := 0
			Endif
			
			// Gravar AT7 (Temporario utilizado no Manad.ini)
			
			dbSelectArea("AT7")
			RecLock("AT7",.T.)
			AT7->CONTA		:= Trim(cConta)
			AT7->DATASLD	:= CtoD( Right(cFimPer,2) + "/" + SubStr(cFimPer,5,2) + "/" + Left(cFimPer,4) )
			AT7->SALDOANT	:= aValPer[nPer,1]									// Saldo Anterior
			AT7->SALDODEB	:= aValPer[nPer,2]									// Debito  no Mes
			AT7->SALDOCRD	:= aValPer[nPer,3]									// Credito no Mes
			AT7->SALDOATU	:= (AT7->SALDOANT - AT7->SALDODEB + AT7->SALDOCRD) 	// Saldo Atual
			AT7->TIPOCONTA	:= "2"		//	"2"-Conta Analitica (No CT7 só há contas analíticas)
			
			AT7->(MsUnlock())
			
			nSldAnt	:= AT7->SALDOATU	//	Sld Anterior      do prx periodo
		EndDo
		
	EndDo
Else
	conoutR( STR0010 )  //'Nao encontrou periodos. Confira os parametros [Data Inicial] e [Data Final].'
EndIf

If Select("SLDCT7") > 0
	SLDCT7->( dbCloseArea() )
EndIf

If Select("AT7") > 0
	dbSelectArea("AT7")
	If IndexOrd() > 0
		dbSetOrder(1)
	EndIf
Endif

// 'Dropar' as Procedures e a tabela temporária

// 1ª Procedure (Saldo Anterior)
If TCSPExist( cProcCT7+"_"+cEmpAnt )
	cRet := TcSqlExec("DROP PROCEDURE "+cProcCT7+"_"+cEmpAnt)
EndIf
// 2ª Procedure (Saldos dos Períodos)
If TCSPExist( cProcCT7P+"_"+cEmpAnt )
	cRet := TcSqlExec("DROP PROCEDURE "+cProcCT7P+"_"+cEmpAnt)
EndIf

// Tabela
If TcCanOpen("SLDCT7_I_"+cEmpAnt+"0")
	TcDelFile("SLDCT7_I_"+cEmpAnt+"0")
EndIf

conoutR( STR0011 + DtoC(DATE()) + " - " + TIME() )  //"Final  Gravacao AT7: "

CT7->(RestArea(aSaveCT7))
RestArea(aSaveAnt)


Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} CriaManad1
Cria procedure para popular a tabela temporaria 

@author Alvaro Camillo Neto
           		   
@param cFilIni   Filial Inicial                         
@param cFilFim   Filial Final                            
@param cMoeda    Moeda                                                            		                    

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CriaManad1(cFilIni, cFilFim, cMoeda)
Local cQuery   := ""
Local nTam     := 0

cQuery += "Create Procedure SALDO_CT7_"+cEmpAnt+"("+CRLF
cQuery += "   @IN_FILDE  Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " ),"+CRLF
cQuery += "   @IN_FILATE Char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " ),"+CRLF
cQuery += "   @IN_DTINI  Char( 08 ),"+CRLF
cQuery += "   @IN_MOEDA  Char( 02 ),"+CRLF
cQuery += "   @OUT_RESULTADO Char( 01 )OutPut"+CRLF
cQuery += "   )"+CRLF
cQuery += "AS"+CRLF

cQuery += "Declare @cFILIAL  char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )"+CRLF
nTam := TamSX3("CT1_CONTA")[1]
cQuery += "Declare @cCONTA   char( "+StrZero(nTam,2)+" )"+CRLF
cQuery += "Declare @nANTDEB  float"+CRLF
cQuery += "Declare @nANTCRD  float"+CRLF
cQuery += "Declare @nDEBITO  float"+CRLF
cQuery += "Declare @nCREDIT  float"+CRLF
cQuery += "Declare @nATUDEB  float"+CRLF
cQuery += "Declare @nATUCRD  float"+CRLF
cQuery += "Declare @cDATA    char( 08 )"+CRLF
cQuery += "Declare @iRECNO   integer"+CRLF
cQuery += "Declare @cFlag    char( 01 )"+CRLF
cQuery += "Declare @cZerado  char( 01 )"+CRLF
cQuery += "Declare @iNroRegs integer"+CRLF
cQuery += "Declare @iTranCount Integer"+CRLF

cQuery += "begin"+CRLF
   
cQuery += "   Select @OUT_RESULTADO = '0'"+CRLF
cQuery += "   select @cZerado = '0'"+CRLF
cQuery += "   select @iNroRegs = 0"+CRLF
   
cQuery += "   declare SALDOS_CT7 insensitive  cursor for "+CRLF

cQuery += "   select "+CRLF
cQuery += "   	CQ1_FILIAL, "+CRLF
cQuery += "   	CQ1_CONTA,"+CRLF
cQuery += "   	CQ1_DATA, "+CRLF
cQuery += "   	0 ANTDEB, "+CRLF
cQuery += "   	0 ANTCRD, "+CRLF
cQuery += "   	SUM(CQ1_DEBITO) DEBITO, "+CRLF
cQuery += "   	SUM(CQ1_CREDIT) CREDIT,"+CRLF
cQuery += "   	0 ATUDEB,"+CRLF
cQuery += "   	0 ATUCRD,"+CRLF
cQuery += "   	'0' FLAG"+CRLF
cQuery += "   FROM"+CRLF
cQuery += "   	"+RetSqlName("CQ1")+" CQ1"+CRLF
cQuery += "   where "+CRLF
If cFilIni == cFilFim
	cQuery += "   	CQ1_FILIAL = @IN_FILDE  "+CRLF
Else
	cQuery += "   	CQ1_FILIAL between @IN_FILDE and @IN_FILATE"+CRLF
EndIf

cQuery += "   	and CQ1_DATA <= @IN_DTINI"+CRLF
cQuery += "   	and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery += "   	and CQ1_TPSALD = '1'"+CRLF
cQuery += "   	and CQ1_DATA   = "+CRLF
cQuery += "   			("+CRLF
cQuery += "   		select max(CQ1_DATA) "+CRLF
cQuery += "   			from "+RetSqlName("CQ1")+" CQ11"+CRLF
cQuery += "   		where CQ1_DATA <= @IN_DTINI"+CRLF
cQuery += "   			and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   			and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
cQuery += "   			and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
cQuery += "   			)"+CRLF
cQuery += "   	and CQ1_LP = "+CRLF
cQuery += "   		( "+CRLF
cQuery += "   		select max(CQ1_LP)"+CRLF
cQuery += "   		from "+RetSqlName("CQ1")+" CQ11"+CRLF
cQuery += "   		where "+CRLF
If cFilIni == cFilFim
	cQuery += "   	CQ1_FILIAL = @IN_FILDE  "+CRLF
Else
	cQuery += "   	CQ1_FILIAL between @IN_FILDE and @IN_FILATE"+CRLF
EndIf
cQuery += "   		and CQ1_MOEDA  = @IN_MOEDA"+CRLF
cQuery += "   		and CQ1_TPSALD = '1'"+CRLF
cQuery += "   		and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   		and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
cQuery += "   		and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
cQuery += "   		and CQ1_DATA   = "+CRLF
cQuery += "   			("+CRLF
cQuery += "   			select max(CQ1_DATA)"+CRLF 
cQuery += "   			from "+RetSqlName("CQ1")+" CQ12"+CRLF
cQuery += "   			where "+CRLF
If cFilIni == cFilFim
	cQuery += "   	CQ1_FILIAL = @IN_FILDE  "+CRLF
Else
	cQuery += "   	CQ1_FILIAL between @IN_FILDE and @IN_FILATE"+CRLF
EndIf
cQuery += "   			and CQ1_DATA <= @IN_DTINI"+CRLF
cQuery += "   			and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   			and CQ11.CQ1_FILIAL=CQ12.CQ1_FILIAL"+CRLF
cQuery += "   			and CQ11.CQ1_CONTA =CQ12.CQ1_CONTA  "+CRLF
cQuery += "   			)"+CRLF
cQuery += "   		)"+CRLF
cQuery += "   	and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   group by CQ1_FILIAL,CQ1_CONTA,CQ1_DATA"+CRLF

cQuery += "   UNION ALL"+CRLF

cQuery += "   select "+CRLF
cQuery += "   			CQ1_FILIAL,"+CRLF 
cQuery += "   			CQ1_CONTA, "+CRLF
cQuery += "   			'' CQ1_DATA,"+CRLF
cQuery += "   			SUM(CQ1_DEBITO) ANTDEB,"+CRLF 
cQuery += "   			SUM(CQ1_CREDIT) ANTCRD, "+CRLF
cQuery += "   			0 DEBITO, "+CRLF
cQuery += "   			0 CREDIT,"+CRLF
cQuery += "   		   0 ATUDEB,"+CRLF
cQuery += "   		   0 ATUCRD,"+CRLF
cQuery += "   		   '1' FLAG"+CRLF
cQuery += "   		FROM"+CRLF
cQuery += "   			"+RetSqlName("CQ1")+" CQ1"+CRLF
cQuery += "   		where "+CRLF
If cFilIni == cFilFim
	cQuery += "   	CQ1_FILIAL = @IN_FILDE  "+CRLF
Else
	cQuery += "   	CQ1_FILIAL between @IN_FILDE and @IN_FILATE"+CRLF
EndIf
cQuery += "   			and CQ1_DATA <= @IN_DTINI"+CRLF
cQuery += "   			and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
cQuery += "   			and CQ1_DATA   < "+CRLF
cQuery += "   					("+CRLF
cQuery += "   				select max(CQ1_DATA)"+CRLF 
cQuery += "   					from "+RetSqlName("CQ1")+" CQ11"+CRLF
cQuery += "   				where CQ1_DATA <= @IN_DTINI"+CRLF
cQuery += "   					and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery += "   					and CQ1_TPSALD = '1'"+CRLF
cQuery += "   					and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   					and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
cQuery += "   					and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
cQuery += "   					)"+CRLF
cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   		group by CQ1_FILIAL,CQ1_CONTA"+CRLF
cQuery += "   UNION ALL"+CRLF

cQuery += "   select "+CRLF
cQuery += "   			CQ1_FILIAL,"+CRLF 
cQuery += "   			CQ1_CONTA, "+CRLF
cQuery += "   			'' CQ1_DATA,"+CRLF
cQuery += "   			0 ANTDEB, "+CRLF
cQuery += "   			0 ANTCRD, "+CRLF
cQuery += "   			0 DEBITO, "+CRLF
cQuery += "   			0 CREDIT,"+CRLF
cQuery += "   			SUM(CQ1_DEBITO) ATUDEB,"+CRLF
cQuery += "   			SUM(CQ1_CREDIT) ATUCRD,"+CRLF
cQuery += "   			'2' FLAG"+CRLF
cQuery += "   		FROM"+CRLF
cQuery += "   			"+RetSqlName("CQ1")+" CQ1"+CRLF
cQuery += "   		where "+CRLF
If cFilIni == cFilFim
	cQuery += "   	CQ1_FILIAL = @IN_FILDE  "+CRLF
Else
	cQuery += "   	CQ1_FILIAL between @IN_FILDE and @IN_FILATE"+CRLF
EndIf
cQuery += "   			and CQ1_DATA <= @IN_DTINI"+CRLF
cQuery += "   			and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery += "   			and CQ1_TPSALD = '1'"+CRLF
cQuery += "   			and CQ1_DATA   <= "+CRLF
cQuery += "   					("+CRLF
cQuery += "   				select max(CQ1_DATA)"+CRLF 
cQuery += "   					from "+RetSqlName("CQ1")+" CQ11"+CRLF
cQuery += "   				where CQ1_DATA <= @IN_DTINI"+CRLF
cQuery += "   					and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery += "   					and CQ1_TPSALD = '1'"+CRLF
cQuery += "   					and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   					and CQ1.CQ1_FILIAL=CQ11.CQ1_FILIAL"+CRLF
cQuery += "   					and CQ1.CQ1_CONTA =CQ11.CQ1_CONTA "+CRLF
cQuery += "   					)"+CRLF
cQuery += "   			and D_E_L_E_T_ = ' '"+CRLF
cQuery += "   		group by CQ1_FILIAL,CQ1_CONTA"+CRLF

cQuery += "   ORDER BY CQ1_FILIAL,CQ1_CONTA,FLAG"+CRLF

cQuery += "   for read only "+CRLF
cQuery += "   open SALDOS_CT7"+CRLF
cQuery += "   fetch SALDOS_CT7 into @cFILIAL, @cCONTA, @cDATA, @nANTDEB, @nANTCRD, @nDEBITO, @nCREDIT, @nATUDEB, @nATUCRD,@cFlag"+CRLF
   
cQuery += "   while ( (@@Fetch_status  = 0 ) ) begin"+CRLF
cQuery += "      select @iNroRegs = @iNroRegs + 1"+CRLF
cQuery += "      If @iNroRegs = 1 begin"+CRLF

         /*------------ Oracle ---------------------*/
cQuery += "         Select @iNroRegs = @iNroRegs"+CRLF
cQuery += "      End"+CRLF
      
cQuery += "      select @iRECNO = IsNull( max ( R_E_C_N_O_ ), 0 )"+CRLF
cQuery += "        from SLDCT7_I_"+cEmpAnt+"0"+CRLF
      /*-------------------------------------------------
        Proximo recno 
        -------------------------------------------------*/

cQuery += "      If  @cFlag = '0' begin "+CRLF
cQuery += "      		Select @iRECNO  = @iRECNO + 1"+CRLF
cQuery += "      		insert into SLDCT7_I_"+cEmpAnt+"0 "+"(ZERADO, CT7_FILIAL, CT7_CONTA, CT7_DATA, CT7_ANTDEB, CT7_ANTCRD, CT7_DEBITO, CT7_CREDIT, CT7_ATUDEB, CT7_ATUCRD, R_E_C_N_O_)"+CRLF
cQuery += "                   values (@cZerado, @cFILIAL,   @cCONTA,   @cDATA,   @nANTDEB,   @nANTCRD,   @nDEBITO,   @nCREDIT,   @nATUDEB,   @nATUCRD,   @iRECNO)"+CRLF
cQuery += "      End"+CRLF
cQuery += "      If  @cFlag = '1' begin "+CRLF
cQuery += "      		update SLDCT7_I_"+cEmpAnt+"0 "+" SET CT7_ANTDEB = @nANTDEB , CT7_ANTCRD = @nANTCRD "+CRLF
cQuery += "          where R_E_C_N_O_ = @iRECNO"+CRLF
cQuery += "      End"+CRLF 
cQuery += "      If  @cFlag = '2' begin "+CRLF
cQuery += "      		update SLDCT7_I_"+cEmpAnt+"0 "+" SET CT7_ATUDEB = @nATUDEB , CT7_ATUCRD = @nATUCRD "+CRLF
cQuery += "          where R_E_C_N_O_ = @iRECNO"+CRLF
cQuery += "      End"+CRLF        

/* ------------------------------------------------------------------------------------------------------
   Tratamento para o DB2
   ------------------------------------------------------------------------------------------------------ */
If Trim(TcGetDb()) = 'DB2'
	cQuery += "      SELECT @fim_CUR = 0"+CRLF
EndIf
cQuery += "      fetch SALDOS_CT7 into @cFILIAL, @cCONTA, @cDATA, @nANTDEB, @nANTCRD, @nDEBITO, @nCREDIT, @nATUDEB, @nATUCRD,@cFlag"+CRLF
cQuery += "   end "+CRLF
   
cQuery += "   close SALDOS_CT7"+CRLF
cQuery += "   deallocate SALDOS_CT7"+CRLF
cQuery += "   select @OUT_RESULTADO = '1'"+CRLF
cQuery += "end"+CRLF
cQuery := MsParse(cQuery,Alltrim(TcGetDB()))

If Trim(TcGetDb()) = 'SYBASE'
	cQuery := strtran(cQuery," LEN("," DATALENGTH(")
   cQuery := strtran(cQuery," Len("," DATALENGTH(")
   cQuery := strtran(cQuery," len("," DATALENGTH(")
EndIf

If Trim(TcGetDb()) = 'INFORMIX'                         
	cQuery := StrTran(cQuery, 'LTRIM ( RTRIM (', "TRIM((")
EndIf

//Efetua tratamento para o DB2
If Trim(TcGetDb()) = 'DB2'
	cQuery	:= StrTran( cQuery, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
EndIf

Return( cQuery )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CriaManad2 ³ Autor  ³ Alice Y. Yamamoto       ³ Data 31.05.7 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Cria procedure para popular a tabela temporaria             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CriaManad2(cFilIni, cFilFim, cMoeda, cDataIni, cDataFim  )   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Dados para a geracao do MANAD - REGISTRO I150                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpC1 = cFilIni  - Filial Inicial                           ³±±
±±³           ³ ExpC2 = cFilFim  - Filial Final                             ³±±
±±³           ³ ExpC3 = cMoeda   - Moeda                                    ³±±
±±³           ³ ExpC4 = cDataIni - Perido Inicial para os movimentos        ³±±
±±³           ³ ExpC5 = cDataFim - Perido Final para os movimentos          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CriaManad2(cFilIni, cFilFim, cMoeda, cDataIni, cDataFim)
Local cQuery   := ""
Local nTam     := 0

cQuery +="Create procedure SALDO_CT7P_"+cEmpAnt+"("+CRLF
cQuery +="   @IN_FILDE  char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " ),"+CRLF
cQuery +="   @IN_FILATE char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " ),"+CRLF
cQuery +="   @IN_MOEDA  char( 02 ),"+CRLF
cQuery +="   @IN_DTINI  varchar( 08 ),"+CRLF
cQuery +="   @IN_DTFIM  varchar( 08 ),"+CRLF
cQuery +="   @OUT_RESULTADO char( 01 ) outPut"+CRLF
cQuery +=" ) as"+CRLF

cQuery +="Declare @cFILIAL	char( " + Str( IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) + " )"+CRLF
nTam := TamSX3("CT1_CONTA")[1]
cQuery +="Declare @cCONTA	char( "+StrZero(nTam, 2)+" )"+CRLF
cQuery +="Declare @nDEBITO	float"+CRLF
cQuery +="Declare @nCREDIT	float"+CRLF
cQuery +="Declare @cDATA   char( 08 )"+CRLF
cQuery +="Declare @iRECNO	integer"+CRLF
cQuery +="Declare @cZerado  Char( 01 )"+CRLF
cQuery +="Declare @iNroRegs integer"+CRLF
cQuery +="Declare @iTranCount Integer"+CRLF

cQuery +="begin"+CRLF
cQuery +=" 	 Select @OUT_RESULTADO = '0'"+CRLF
cQuery +="   select @cZerado       = ' '"+CRLF
cQuery +="   select @iNroRegs = 0"+CRLF
   
cQuery +="   Declare SALDOS_CT7 insensitive cursor  for"+CRLF

cQuery +="   select '0', @IN_DTFIM CQ1_DATA, CQ1_CONTA, SUM(CQ1_DEBITO), SUM(CQ1_CREDIT)"+CRLF
cQuery +="     from "+RetSqlName("CQ1")+" CQ1"+CRLF
If cFilIni ==cFilFim
	cQuery +="    where CQ1_FILIAL = @IN_FILDE"+CRLF
Else
	cQuery +="    where CQ1_FILIAL between @IN_FILDE and @IN_FILATE"+CRLF
EndIf
If cDataIni == cDataFim
	cQuery +="      and CQ1_DATA = @IN_DTINI"+CRLF
Else
	cQuery +="      and CQ1_DATA between @IN_DTINI and @IN_DTFIM"+CRLF
EndIf
cQuery +="      and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery +="      and CQ1_TPSALD = '1'"+CRLF
cQuery +="      AND D_E_L_E_T_ = ' '"+CRLF
cQuery +="      group by CQ1_CONTA"+CRLF

cQuery +="   union"+CRLF

cQuery +="   select '1', @IN_DTFIM CQ1_DATA, CT1_CONTA  CQ1_CONTA, 0, 0"+CRLF
cQuery +="         from "+RetSqlName("CT1")+" CT1"+CRLF
cQuery +="   where CT1_FILIAL  = '"+xFilial("CT1")+"'"+CRLF
cQuery +="         and D_E_L_E_T_ = ' '"+CRLF
cQuery +="         and CT1_CLASSE = '2'"+CRLF
cQuery +="   and not exists"+CRLF
cQuery +="    ( select CQ1_CONTA from "+RetSqlName("CQ1")+" CQ1"+CRLF
If cFilIni == cFilFim
	cQuery +="          where CQ1_FILIAL = @IN_FILDE"+CRLF
Else
	cQuery +="          where CQ1_FILIAL between @IN_FILDE and @IN_FILATE"+CRLF
EndIf
If cDataIni == cDataFim
	cQuery +="            and CQ1_DATA = @IN_DTINI"+CRLF
Else
	cQuery +="            and CQ1_DATA between @IN_DTINI and @IN_DTFIM"+CRLF
EndIf
cQuery +="            and CQ1_MOEDA = @IN_MOEDA"+CRLF
cQuery +="            and CQ1_TPSALD = '1'"+CRLF
If xFilial("CT1") = xFilial("CQ1")
	cQuery +="            AND CQ1.CQ1_FILIAL=CT1.CT1_FILIAL"+CRLF
EndIf
cQuery +="            and CQ1.CQ1_CONTA =CT1.CT1_CONTA "+CRLF
cQuery +="            and D_E_L_E_T_ = ' '"+CRLF
cQuery +="      )"+CRLF
cQuery +="   order by 3,2"+CRLF

cQuery +="   for read only "+CRLF
cQuery +="   open SALDOS_CT7"+CRLF
cQuery +="   fetch SALDOS_CT7 INTO @cZerado, @cDATA, @cCONTA, @nDEBITO, @nCREDIT"+CRLF
   
cQuery +="   WHILE ( (@@Fetch_status  = 0 ) ) BEGIN"+CRLF
cQuery +="      select @iNroRegs = @iNroRegs + 1"+CRLF
cQuery +="      If @iNroRegs = 1 begin"+CRLF
         /*------------ Oracle ---------------------*/
cQuery +="         Select @iNroRegs = @iNroRegs"+CRLF
cQuery +="      End"+CRLF
      
cQuery +="	   select @iRECNO = IsNull ( MAX ( R_E_C_N_O_ ), 0 ) FROM SLDCT7_I_"+cEmpAnt+"0"+CRLF
cQuery +="	   select @iRECNO = @iRECNO + 1"+CRLF
cQuery +="	   INSERT INTO SLDCT7_I_"+cEmpAnt+"0 "+"(ZERADO, CT7_CONTA, CT7_DATA, CT7_DEBITO, CT7_CREDIT,  R_E_C_N_O_)"+CRLF
cQuery +="	   		        VALUES (@cZerado,  @cCONTA,   @cDATA,  @nDEBITO,   @nCREDIT, @iRECNO)"+CRLF

cQuery +="   fetch SALDOS_CT7 INTO @cZerado, @cDATA, @cCONTA, @nDEBITO, @nCREDIT"+CRLF
cQuery +="	end"+CRLF
cQuery +="	 close SALDOS_CT7"+CRLF
cQuery +="   deallocate SALDOS_CT7"+CRLF
cQuery +="	 select @OUT_RESULTADO = '1'"+CRLF
cQuery +="End"+CRLF

cQuery := MsParse(cQuery,Alltrim(TcGetDB()))

If Trim(TcGetDb()) = 'SYBASE'
	cQuery := strtran(cQuery," LEN("," DATALENGTH(")
	cQuery := strtran(cQuery," Len("," DATALENGTH(")
	cQuery := strtran(cQuery," len("," DATALENGTH(")
EndIf

If Trim(TcGetDb()) = 'INFORMIX'                         
	cQuery := StrTran(cQuery, 'LTRIM ( RTRIM (', "TRIM((")
EndIf

//Efetua tratamento para o DB2
If Trim(TcGetDb()) = 'DB2'
	cQuery	:= StrTran( cQuery, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
EndIf

Return( cQuery )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CHKDTEXIST  ³ Autor ³ Davi Torchio            ³ Data ³ 15/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a data de existencia da conta para estar criando       ³±±
±±³          ³ o saldo do Registro I150 no manad.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CHKDTEXIST()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ CARACTER                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cConta - Conta do arquivo temporario AT7.                       ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function CHKDTEXIST (cConta)

Local cDataStr := ""

Default cConta := ""

If ! Empty( cConta )
    DbSelectArea("CT1")
    If DbSeek(xFilial()+cConta)
       cDataStr := DTOS(CT1->CT1_DTEXIS)
    Endif
Endif

Return cDataStr

