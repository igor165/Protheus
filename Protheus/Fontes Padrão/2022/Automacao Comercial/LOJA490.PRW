#include "protheus.ch"
#include "Loja490.ch"

/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n   ³ Loja490   ³ Autor ³ Fernando Machima      ³ Data ³ 25/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.  ³ Consulta de Memoria de Trabalho(GetWorkingMemory)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HASAR (Loc. Argentina)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ACTUALIZACIONES EFECTUADAS DESDE LA CODIFICACION INICIAL       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³         Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ³        ³                                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Loja490()
Local cPdv     := Space(4)
Local cRetorno := Space(40)
Local aRet     := {}
Local nRet     := 0
Local iRetorno
Local oDlgMF

//Retorno do comando de leitura da memoria - Doc. Fiscal
Local cUltDocNFA  := ""
Local cUltDocNFBC := ""
Local nTotNFVend  := 0
Local nIVANFAcum  := 0
Local nImpIntNFAc := 0
Local nPercepNFAc := 0
Local nIVANFNIAc  := 0
Local nTotalNF    := 0
Local lContinua	  := .T.

//Retorno do comando de leitura da memoria - Nota de Credito
Local cUltDocNCA  := ""
Local cUltDocNCBC := ""
Local nTotNCVend  := 0
Local nIVANCAcum  := 0
Local nImpIntNCAc := 0
Local nPercepNCAc := 0
Local nIVANCNIAc  := 0
Local nTotalNC    := 0

//Dados Adicionais
Local nQtdNF      := 0
Local nQtdNNF     := 0
Local nQtdCanc    := 0
Local cUltRem     := ""

If !lFiscal
	//Para Consultar a Memoria de Trabalho da Impressora , deve-se
	//estar cadastrado como usu rio fiscal e com os parƒmetros da impressora corretos.
	//Atenção
	MsgStop(Oemtoansi(STR0018)+;
	Oemtoansi(STR0019),;
	Oemtoansi(STR0020))
	lContinua := .F.
EndIf

If lContinua .And. !MsgYesNo(OemToAnsi(STR0001))  //"Deseja consultar a Memoria de Trabalho?"
   lContinua := .F. 
EndIf

If lContinua
	nRet := IFStatus(nHdlECF, '5', @cRetorno)      
	If nRet == 1 
	   lContinua := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³se exitir cupom aberto, faz o cancelamento                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If lContinua .And. nRet == 7
   nRet := IFCancCup( nHdlECF )
   If L010AskImp(.F.,nRet)
      lContinua := .F.
   EndIf
   Inkey(8)   // dá um tempo para a impressora fazer a impressao do cancelamento
Endif

If lContinua
	iRetorno := IFPegPDV(nHdlECF, @cPdv)
	If L010AskImp(.F.,iRetorno)
	   lContinua := .F.
	EndIf
EndIf

If lContinua
	IFMemTrab(nHdlECF,@aRet)

	If Len(aRet) > 2
		cUltDocNFA  := cPdv + '-' + StrZero( Val( aRet[7] ), 8 )
		cUltDocNFBC := cPdv + '-' + StrZero( Val( aRet[6] ), 8 )
		cUltDocNCA  := cPdv + '-' + StrZero( Val( aRet[14] ), 8 )
		cUltDocNCBC := cPdv + '-' + StrZero( Val( aRet[13] ), 8 )
		cUltRem     := cPdv + '-' + StrZero( Val( aRet[20] ), 8 )
		
		nTotNFVend  := Val( aRet[8] )
		nIVANFAcum  := Val( aRet[9] )
		nImpIntNFAc := Val( aRet[10] )
		nPercepNFAc := Val( aRet[11] )
		nIVANFNIAc  := Val( aRet[12] )
		nTotNCVend  := Val( aRet[15] )
		nIVANCAcum  := Val( aRet[16] )
		nImpIntNCAc := Val( aRet[17] )
		nPercepNCAc := Val( aRet[18] )
		nIVANCNIAc  := Val( aRet[19] )
		
		nQtdNF      := Val( aRet[5] )
		nQtdNNF     := Val( aRet[4] )
		nQtdCanc    := Val( aRet[3] )
	EndIf
	
	nTotalNF := nTotNFVend + nIVANFAcum + nImpIntNFAc + nPercepNFAc + nIVANFNIAc
	nTotalNC := nTotNCVend + nIVANCAcum + nImpIntNCAc + nPercepNCAc + nIVANCNIAc
	
	//"Consulta de Memoria de Trabalho"						
	DEFINE MSDIALOG oDlgMF FROM 20,20 TO 460,720 TITLE OemToAnsi(STR0002) PIXEL OF oMainWnd
	
	@ 002, 002 TO 150, 165 LABEL STR0003 OF oDlgMF  PIXEL   //" Documentos Fiscais "		
	@ 002, 182 TO 150, 345 LABEL STR0004 OF oDlgMF  PIXEL   //" Notas de Credito "		
	@ 155, 002 TO 200, 345 LABEL STR0005 OF oDlgMF  PIXEL   //" Dados Adicionais "								
	
	@ 015,10  SAY OemToAnsi(STR0006) SIZE 70, 8 OF oDlgMF PIXEL  //"Ultimo A Emitido"		
	@ 030,10  SAY OemToAnsi(STR0007) SIZE 70, 8 OF oDlgMF PIXEL  //"Ultimo B/C Emitido"
	@ 045,10  SAY OemToAnsi(STR0008) SIZE 70, 8 OF oDlgMF PIXEL  //"Total Vendido"		
	@ 060,10  SAY OemToAnsi(STR0009) SIZE 70, 8 OF oDlgMF PIXEL  //"IVA Acumulado"		
	@ 075,10  SAY OemToAnsi(STR0010) SIZE 70, 8 OF oDlgMF PIXEL  //"Impostos Internos Acumulados"		
	@ 090,10  SAY OemToAnsi(STR0011) SIZE 70, 8 OF oDlgMF PIXEL  //"Percepcoes Acumuladas"		
	@ 105,10  SAY OemToAnsi(STR0012) SIZE 70, 8 OF oDlgMF PIXEL  //"IVA Nao Inscrito Acumulado"		
	@ 120,10  SAY OemToAnsi(STR0013) SIZE 70, 8 OF oDlgMF PIXEL  //"Total"		
	
	@ 015,190 SAY OemToAnsi(STR0006) SIZE 70, 8 OF oDlgMF PIXEL  //"Ultimo A Emitido"		
	@ 030,190 SAY OemToAnsi(STR0007) SIZE 70, 8 OF oDlgMF PIXEL  //"Ultimo B/C Emitido"
	@ 045,190 SAY OemToAnsi(STR0008) SIZE 70, 8 OF oDlgMF PIXEL  //"Total Vendido"		
	@ 060,190 SAY OemToAnsi(STR0009) SIZE 70, 8 OF oDlgMF PIXEL  //"IVA Acumulado"		
	@ 075,190 SAY OemToAnsi(STR0010) SIZE 70, 8 OF oDlgMF PIXEL  //"Impostos Internos Acumulados"		
	@ 090,190 SAY OemToAnsi(STR0011) SIZE 70, 8 OF oDlgMF PIXEL  //"Percepcoes Acumuladas"		
	@ 105,190 SAY OemToAnsi(STR0012) SIZE 70, 8 OF oDlgMF PIXEL  //"IVA Nao Inscrito Acumulado"		
	@ 120,190 SAY OemToAnsi(STR0013) SIZE 70, 8 OF oDlgMF PIXEL  //"Total"		
	
	@ 165,10  SAY OemToAnsi(STR0014) SIZE 70, 8 OF oDlgMF PIXEL  //"Documentos Fiscais"		
	@ 180,10  SAY OemToAnsi(STR0015) SIZE 70, 8 OF oDlgMF PIXEL  //"Documentos Nao Fiscais"		
	@ 165,190 SAY OemToAnsi(STR0016) SIZE 70, 8 OF oDlgMF PIXEL  //"Doc. Fiscais Cancelados"		
	@ 180,190 SAY OemToAnsi(STR0017) SIZE 70, 8 OF oDlgMF PIXEL  //"Ultimo Remito Emitido"						
	
	@ 015,090 MSGET cUltDocNFA  Size 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 030,090 MSGET cUltDocNFBC Size 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 045,090 MSGET nTotNFVend  PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 060,090 MSGET nIVANFAcum  PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 075,090 MSGET nImpIntNFAc PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 090,090 MSGET nPercepNFAc PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 105,090 MSGET nIVANFNIAc  PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 120,090 MSGET nTotalNF    PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	
	@ 015,270 MSGET cUltDocNCA  SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 030,270 MSGET cUltDocNCBC SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 045,270 MSGET nTotNCVend  PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 060,270 MSGET nIVANCAcum  PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 075,270 MSGET nImpIntNCAc PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 090,270 MSGET nPercepNCAc PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 105,270 MSGET nIVANCNIAc  PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 120,270 MSGET nTotalNC    PICTURE "@E 99,999,999.99" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	
	@ 165,090 MSGET nQtdNF      PICTURE "@E 99,999" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 180,090 MSGET nQtdNNF     PICTURE "@E 99,999" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 165,270 MSGET nQtdCanc    PICTURE "@E 99,999" SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	@ 180,270 MSGET cUltRem     SIZE 60,10 OF oDlgMF PIXEL WHEN .F.
	
	DEFINE SBUTTON FROM 205, 300 TYPE 1;
	ACTION oDlgMF:End() ENABLE OF oDlgMF
	
	ACTIVATE MSDIALOG oDlgMF CENTERED
EndIf

Return lContinua
