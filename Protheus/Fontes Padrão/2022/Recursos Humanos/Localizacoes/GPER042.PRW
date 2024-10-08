#Include "protheus.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "GPER042.CH"

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �GPER042   �Autor  �Silvia Taguti       � Data �  10/01/03       ���
�����������������������������������������������������������������������������͹��
���Desc.     �Relatorio para complemento da Cuota Mutual - Uruguai            ���
���          �                                                                ���
�����������������������������������������������������������������������������͹��
���Uso       � AP                                                             ���
�����������������������������������������������������������������������������ĺ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.		    	  ���
�����������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS   �  Motivo da Alteracao 			     	  ���
�����������������������������������������������������������������������������Ĵ��
���Luciana     |07/01/2009|52382008|Inclusao de variaveis para tratar geracao ���
���            |          |        |do SRZ via procedure.                     ���
���Alex        |27/10/2009|00026128|Adapta��o Gest�o Corporativa              ���
���            |          |   /2009|Respeitar o Grupo de campos de Filiais.   ���
���Alex        |07/07/2010|00015217|Adaptar a Emissao da guia BSE             ���
���            |          |   /2010|Localizacao Uruguai.                      ���
���Alex        |23/12/2010|00029463|Atender Nova Interface Totvs 11.5 utili-  ���
���            |          |   /2010|zando a funcao MsAdvSize.                 ���
���Tiago Malta |05/07/2011|00014261|Ajuste de telas para a versao p11.5.      ���
���            |          |   /2011|                                          ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Function GPER042()    

	Local oReport 
	Private nTpImpre:= 0
	Private cFigura		:= "bse.bmp"
	oFont05	:= TFont():New("Courier New",05,05,,.F.,,,,.T.,.F.)
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont25n:= TFont():New("Courier New",25,25,,.T.,,,,.T.,.F.)     //Negrito// 
	oFont11n:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)     //Negrito//
	oFont17n:= TFont():New("Courier New",17,17,,.T.,,,,.T.,.F.)     //Negrito//
	oFont11	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.) 
	
	If FindFunction("TRepInUse") .And. TRepInUse()
	
		If fPergGuia(@nTpImpre) == 1
			//-- Interface de impressao
			Pergunte("GPR042",.F.)
   			oReport := ReportDef()
	  		oReport:PrintDialog()
	  	ElseIf nTpImpre > 0
			GPER042R3()
	  	EndIf
	Else
		GPER042R3()	
	EndIF    

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REPORTDEF �Autor  �Silvia Taguti       � Data �  06/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportDef()

Local oReport 
Local oSRZ

Local cDesc	:= STR0001 +STR0002	//"Resumo dos seguros a serem pagos ao BSE"#"Ser� impresso de acordo com os parametros solicitados pelo usuario"
					
DEFINE REPORT oReport NAME "GPER042" TITLE OemToAnsi(STR0009) PARAMETER "GPR042" ACTION {|oReport| R042Imp(oReport)} DESCRIPTION cDesc
oReport:SetTotalInLine(.F.)

DEFINE SECTION oSRZ OF oReport TITLE OemToAnsi(STR0008) TABLES "SRZ"  ORDERS {OemToAnsi(STR0019)}
oSRZ:SetTotalInLine(.F.)
oReport:SetPortrait()


	DEFINE CELL NAME "CODIGO" 		OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0011) PICTURE PesqPict("CTT","CTT_CUSTO")	SIZE 9 
	DEFINE CELL NAME "ALIQUOTA" 	OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0012) PICTURE "99.9999"	SIZE 7 
	DEFINE CELL NAME "QUANTFUNC"	OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0013) PICTURE "99999"	SIZE 5 
	DEFINE CELL NAME "PROVENTO"	OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0014) PICTURE "@R 99,999,999,999.99"	SIZE 17 
	DEFINE CELL NAME "VLPRIMA" 	OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0015) PICTURE "@R 99,999,999,999.99"	SIZE 17 
	DEFINE CELL NAME "IMPOSTO" 	OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0016) PICTURE "@R 99,999,999,999.99"	SIZE 17 
	DEFINE CELL NAME "VLIVA" 		OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0017) PICTURE "@R 99,999,999,999.99"	SIZE 17 
	DEFINE CELL NAME "TOTAL" 		OF oSRZ ALIAS "   " TITLE OemToAnsi(STR0018) PICTURE "@R 99,999,999,999.99"	SIZE 17 

 	DEFINE FUNCTION FROM oSRZ:Cell("PROVENTO") 	OF oSRZ FUNCTION SUM  NO END SECTION PICTURE "@R 99,999,999,999.99"
 	DEFINE FUNCTION FROM oSRZ:Cell("VLPRIMA") 	OF oSRZ FUNCTION SUM  NO END SECTION PICTURE "@R 99,999,999,999.99"
 	DEFINE FUNCTION FROM oSRZ:Cell("IMPOSTO") 	OF oSRZ FUNCTION SUM  NO END SECTION PICTURE "@R 99,999,999,999.99"
 	DEFINE FUNCTION FROM oSRZ:Cell("VLIVA") 		OF oSRZ FUNCTION SUM  NO END SECTION PICTURE "@R 99,999,999,999.99"
 	DEFINE FUNCTION FROM oSRZ:Cell("TOTAL") 		OF oSRZ FUNCTION SUM  NO END SECTION PICTURE "@R 99,999,999,999.99"

Return oReport						

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R042IMP   �Autor  �Silvia Taguti       � Data �  06/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R042Imp(oReport)

//������������������������������������������������������������������Ŀ
//�  Declaracao de variaveis                                         �
//��������������������������������������������������������������������
//-- Objeto

Local oSRZ 	:= oReport:Section(1)    

Local cMesAnoRef
Local cPicVlr  := TM(99999999,12,MsDecimais(1))
Local nx			:= 0
Local nV			:= 0
Local nC			:= 0
Local nF       := 0
Local nP 		:= 0
Local lRet13   := .F.
Local lRet		:=	.F.
Local aPolizas	:=	{}
Local cMesArqRef  
Local aFiliais	:=	{}
Local cbtxt 	:= SPACE(10)
Local cbcont 	:= 0

Private aInfo  := {}
Private cTipCC, cRefOco
Private lBse13
Private cAliasMov := ""
Private aCodFol  	:= {}  
Private aFuncsBSE	:=	{} 
Private nOrdem

nOrdem    := 1         // Ordem de Centro de Custo do Movimento
dDataRef  := mv_par01
lBse13	 := If(mv_par02 == 1,.T.,.F.)
nRelat	 :=	2
cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
cMesArqRef := cMesAnoRef

Titulo	:=	STR0009+SUBSTR(cMesAnoRef,1,2)+"/"+SUBSTR(cMesAnoRef,3) //"PLANILLA PARA EL PAGO AL BSE - LIQUIDACION CORRESPONDIENTE A "

//-- Altera o titulo do relatorio
oReport:SetTitle(Titulo)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para geracao do SRZ via procedure     	 �
//����������������������������������������������������������������
lFolPgto    := .T.
lFol13Sl    := lBse13

lRet := fGeraFolSRZ(1,{3},cMesAnoRef)

If lBse13
	lRet13:= fGeraFolSRZ(2,{3},cMesAnoRef)
Endif

If (lRet .or. lRet13) .And. Len(aFuncsBSE) > 0
	DbSelectArea('SM0')
	
	aAreaSM0	:=	GetArea()
	DbSeek(cEmpAnt)
	While SM0->M0_CODIGO==cEmpAnt .And. !SM0->(EOF())
		Aadd(aFiliais,FWGETCODFILIAL)
		DbSkip()
	Enddo	

	RestArea(aAreaSM0)

	aPolizas	:=	CarregaPolizas()

	For nX := 1 To Len(aFuncsBSE)
      If (nPos := Ascan(aPolizas,{|x| x[1] == aFuncsBSE[nX][1]})) > 0
			aPolizas[nPos][3]	:=	aFuncsBSE[nX][2]
		Endif
	Next

	DbSelectArea('SRZ')
	DbSetOrder(1)

	For nP := 1 To Len(aPolizas)
		//filiais
		For nF := 1 To Len(aFiliais)
		//CC por poliza x filial
			If ( Fp_CodFol( @aCodFol , cFilAnt ) )
				aVerbas	:=	{aCodFol[413,1],aCodFol[398,1],aCodFol[399,1],aCodFol[400,1]}
				For nC := 1 To Len(aPolizas[nP][2])
				//Verbas por CC x poliza x filial
					For nV := 1 To Len(aVerbas)
						If MsSeek(aFiliais[nF]+aPolizas[nP][2][nC])
							While !Eof() .And. SRZ->RZ_FILIAL+SRZ->RZ_CC==aFiliais[nF]+aPolizas[nP][2][nC]
								If SRZ->RZ_FILIAL+SRZ->RZ_CC==aFiliais[nF]+ aPolizas[nP][2][nC] .And.;
									Empty(SRZ->RZ_TPC).And.;
									(SRZ->RZ_PD==aVerbas[nV] .or. If(aVerbas[nV]==aCodfol[413,1],SRZ->RZ_PD==aCodFol[414,1] .or. SRZ->RZ_PD==aCodfol[415,1],.F.))						
									CTT->(DbSetOrder(1))
									CTT->(MsSeek(aFiliais[nF]+aPolizas[nP][2][nC]))
									If CTT->CTT_POLIZA == aPolizas[nP][1]
										aPolizas[nP][nV+3] += SRZ->RZ_VAL					
									Endif	  
								Endif	
								SRZ->(dbSkip())
							Enddo
		            Endif	
					Next nV
				Next nC
			Endif
		Next nF
	Next nP		
   
	If Len(aPolizas) > 0
		oSRZ:Init()

		For nX := 1 To Len(aPolizas)
			oSRZ:Cell("CODIGO"):SetBlock({|| aPolizas[nX][1] })
			oSRZ:Cell("ALIQUOTA"):SetBlock({|| aPolizas[nX][8] })
			oSRZ:Cell("QUANTFUNC"):SetBlock({|| aPolizas[nX][3] })
			oSRZ:Cell("PROVENTO"):SetBlock({|| aPolizas[nX][4] })
			oSRZ:Cell("VLPRIMA"):SetBlock({|| aPolizas[nX][5] })
			oSRZ:Cell("IMPOSTO"):SetBlock({|| aPolizas[nX][6] })
			oSRZ:Cell("VLIVA"):SetBlock({|| aPolizas[nX][7] })
			oSRZ:Cell("TOTAL"):SetBlock({|| aPolizas[nX][5]+aPolizas[nX][6]+aPolizas[nX][7] })
	
  			If aPolizas[nX][8] == 0
				FPHIST82(xFilial("SRX") , "78" , aPolizas[nX][1] )
				aPolizas[nX][8] := Val( Substr( SRX->RX_TXT , 1 , 7 ) )
			Endif	
			oSRZ:PrintLine()
		Next      
		oSRZ:Finish()
	Endif
Endif
      
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPER042   �Autor  �Microsiga           � Data �  06/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GPER042R3()

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local cDesc1 	:= STR0001		//"Folha de Pagamento"
Local cDesc2 	:= STR0002		//"Ser� impresso de acordo com os parametros solicitados pelo usuario."
Local cDesc3 	:= " "		   
Local cString	:= "SRA"       // alias do arquivo principal (Base)
Local cMesAnoRef

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Basicas)                            �
//����������������������������������������������������������������
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1,"",1 }	//"Zebrado"###"Administra��o"
Private nomeprog:= "GPER042"
Private nTipo   := "P"
Private aLinha  := {},nLastKey := 0
Private cPerg   := "GPR042" 
//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
Private Titulo	:= STR0006		
Private AT_PRG  := "GPER042"
Private CONTFL  := 1
Private LI      := 0
Private Tamanho:= "M"
Private cCabec
Private nOrdem
Private aInfo   := {}
Private cTipCC, cRefOco
Private lBse13
Private oPrint
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("GPR042",.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:="GPER042"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,Nil,.T.,Tamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)
oPrint := TMSPrinter():New( "BSE - Banco de Seguros" )
oPrint:SetPortrait()

If nLastKey = 27
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        //  Data de Referencia para a impressao      �
//� mv_par02        //  13 salario                               �
//����������������������������������������������������������������

nOrdem    := 1         // Ordem de Centro de Custo do Movimento
dDataRef  := mv_par01
lBse13	 := If(mv_par02 == 1,.T.,.F.)
nRelat	 :=	2
cMesAnoRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para geracao do SRZ via procedure     	 �
//����������������������������������������������������������������
lFolPgto    := .T.
lFol13Sl    := lBse13
RptStatus({|lEnd| R042ImpR3(@lEnd,wnRel,cString,cMesAnoRef)},STR0007)
                           
oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

If nTpImpre == 1
	Set Device To Screen
	
	If aReturn[5] = 1
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif
	
	MS_FLUSH()
EndIf	

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R042ImpR3� Autor � R.H. - Silvia Taguti  � Data � 01.10.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento Para emissao do Relatorio                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R042ImpR3(lEnd,Wnrel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function R042ImpR3(lEnd,WnRel,cString,cMesAnoRef)
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local cMesArqRef  
Local nX				:=	0
Local cPicVlr   	:= TM(99999999,12,MsDecimais(1))
Local Tamanho     := "M"                                        
Local aPolizas		:=	{}
Local lRet		:=	.F.
Local aFiliais	:=	{}
Local aVerbas	:=	{}
Local cbtxt 	:= SPACE(10)
Local cbcont 	:= 0
Local cabec1	:=	STR0008 //"Poliza      % prima   Personal          Haberes       $ de Prima   Valor Impuesto        Valor IVA    Total a pagar"
Local cabec2	:=	""
Local aTotais	:=	{0,0,0,0,0}
Local nV			:= 0
Local nC			:= 0
Local nF       := 0
Local nP 		:= 0
Local lRet13   := .F.
Local cAliq		:= 0
Local cPremio	:= 0
Local cImpLey4	:= 0
Local cAliqLey	:= 0
Local cSubTotal	:= 0
Local cIVA		:= 0
Local cAliqIVA	:= 0
Local cTotal	:= 0 

If Alltrim(titulo) == Alltrim(STR0006)
	Titulo	:=	STR0009+SUBSTR(cMesAnoRef,1,2)+"/"+SUBSTR(cMesAnoRef,3) //"PLANILLA PARA EL PAGO AL BSE - LIQUIDACION CORRESPONDIENTE A "
Endif
Private cAliasMov := ""
Private aCodFol  	:= {}  
Private aFuncsBSE	:=	{} 
li 		:= 80
m_pag 	:= 1
cMesArqRef := cMesAnoRef

lRet := fGeraFolSRZ(1,{3},cMesAnoRef)
If lBse13
	lRet13:= fGeraFolSRZ(2,{3},cMesAnoRef)
Endif

If (lRet .or. lRet13) .And. Len(aFuncsBSE) > 0
	DbSelectArea('SM0')
	aAreaSM0	:=	GetArea()
	DbSeek(cEmpAnt)
	While SM0->M0_CODIGO==cEmpAnt .And. !SM0->(EOF())
		Aadd(aFiliais,FWGETCODFILIAL)
		DbSkip()
	Enddo	
	RestArea(aAreaSM0)

	aPolizas	:=	CarregaPolizas()

	For nX := 1 To Len(aFuncsBSE)
      If (nPos := Ascan(aPolizas,{|x| x[1] == aFuncsBSE[nX][1]})) > 0
			aPolizas[nPos][3]	:=	aFuncsBSE[nX][2]
		Endif
	Next
	DbSelectArea('SRZ')
	DbSetOrder(1)
//Polizas
	For nP := 1 To Len(aPolizas)
//filiais
		For nF := 1 To Len(aFiliais)
//CC por poliza x filial
			If ( Fp_CodFol( @aCodFol , cFilAnt ) )
				aVerbas	:=	{aCodFol[413,1],aCodFol[398,1],aCodFol[399,1],aCodFol[400,1]}
				For nC := 1 To Len(aPolizas[nP][2])
//Verbas por CC x poliza x filial
					For nV := 1 To Len(aVerbas)
						If MsSeek(aFiliais[nF]+aPolizas[nP][2][nC])
							While !Eof() .And. SRZ->RZ_FILIAL+SRZ->RZ_CC==aFiliais[nF]+aPolizas[nP][2][nC]
								If SRZ->RZ_FILIAL+SRZ->RZ_CC==aFiliais[nF]+ aPolizas[nP][2][nC] .And.;
									Empty(SRZ->RZ_TPC).And.;
									(SRZ->RZ_PD==aVerbas[nV] .or. If(aVerbas[nV]==aCodfol[413,1],SRZ->RZ_PD==aCodFol[414,1] .or. SRZ->RZ_PD==aCodfol[415,1],.F.))						
									CTT->(DbSetOrder(1))
									CTT->(MsSeek(aFiliais[nF]+aPolizas[nP][2][nC]))
									If CTT->CTT_POLIZA == aPolizas[nP][1]
										aPolizas[nP][nV+3] += SRZ->RZ_VAL					
									Endif	  
								Endif	
								SRZ->(dbSkip())
							Enddo
	               Endif	
					Next nV
				Next nC
			Endif
		Next nF
	Next nP		
	If Len(aPolizas) > 0
		If nTpImpre == 0
			For nX := 1 To Len(aPolizas)
		      If li > 56
					li	:=	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				Endif
				li++
	  			If aPolizas[nX][8] == 0
					FPHIST82(xFilial("SRX") , "78" , aPolizas[nX][1] )
					aPolizas[nX][8] := Val( Substr( SRX->RX_TXT , 1 , 7 ) )
				Endif	
				@li,000 PSAY aPolizas[nX][1]
				@li,012 PSAY aPolizas[nX][8] Picture "99.9999"
				@li,025 PSAY aPolizas[nX][3] Picture "99999"
				@li,030 PSAY aPolizas[nX][4] Picture "@R 99,999,999,999.99"
				@li,047 PSAY aPolizas[nX][5]	Picture "@R 99,999,999,999.99"
				@li,064 PSAY aPolizas[nX][6]	Picture "@R 99,999,999,999.99"
				@li,081 PSAY aPolizas[nX][7]	Picture "@R 99,999,999,999.99"
				@li,098 PSAY aPolizas[nX][5]+aPolizas[nX][6]+aPolizas[nX][7]	Picture "@R 99,999,999,999.99"
				aTotais[1]	+=	aPolizas[nX][4]
				aTotais[2]	+=	aPolizas[nX][5]
				aTotais[3]	+=	aPolizas[nX][6]
				aTotais[4]	+=	aPolizas[nX][7]
				aTotais[5]	+=	aPolizas[nX][5]+aPolizas[nX][6]+aPolizas[nX][7]
			Next
			li++
			@li,000 PSAY __PrtThinLine()
			li++
			@li,000 PSAY STR0010 //" TOTALES : "
			@li,030 PSAY aTotais[1] Picture "@R 99,999,999,999.99"
			@li,047 PSAY aTotais[2]	Picture "@R 99,999,999,999.99"
			@li,064 PSAY aTotais[3]	Picture "@R 99,999,999,999.99"
			@li,081 PSAY aTotais[4]	Picture "@R 99,999,999,999.99"
			@li,098 PSAY aTotais[5]	Picture "@R 99,999,999,999.99"
			roda(cbcont,cbtxt,tamanho)
		Else             
			For nX := 1 To Len(aPolizas)                    
				aTotais[1]	+=	aPolizas[nX][4] //Total de salarios
				aTotais[2]	+=	aPolizas[nX][3] //Qtde de funcionarios
			Next

			oPrint:StartPage() 						//Inicia uma nova pagina   
			oPrint:Box ( 0020, 0035, 430, 2180 ) 	//BOX PRINCIPAL

			oPrint:say ( 0035, 0330, "BSE", oFont25n )

			oPrint:say ( 0100, 0100, "BANCO DE SEGUROS", oFont25n )
			oPrint:say ( 0250, 0100, "SEGURO DE ACCIDENTES DEL", oFont17n ) 
			oPrint:say ( 0350, 0100, "TRABAJO Y ENFERMEDADES PROFESIONALES", oFont17n )
			
			oPrint:say ( 0080, 1100, "SEGURO BAJO REGIMEN DE PAGO MENSUAL", oFont17n ) 
			oPrint:say ( 0150, 1000, "DECLARACION JURADA - LIQUIDACION MENSUAL", oFont17n )

			oPrint:Box ( 0450, 0035, 630, 2180 ) 	//BOX EMPRESA
			oPrint:say ( 0550, 1700, "Carpeta", oFont11 )
			oPrint:say ( 0570, 0085, "EMPRESA: ", oFont11n )
			oPrint:say ( 0570, 0295, SM0->M0_NOME, oFont11 )

			oPrint:Box ( 650, 0035, 860, 2180 ) 	//BOX LIQUIDA��O
			oPrint:say ( 750, 0085, "LIQUIDACION CORRESPONDIENTE A: ", oFont11 )
		    oPrint:Box ( 680, 0735, 820, 900 ) 		//BOX MES
		    oPrint:Box ( 680, 0900, 820, 1100 ) 	//BOX ANO   
 			oPrint:say ( 690, 0780, "MES", oFont11n )
 			oPrint:say ( 690, 0980, "ANO", oFont11n )

			oPrint:say ( 740, 0780, SubStr(cMesArqRef,1,2), oFont11 ) //Impressao do Mes
			oPrint:say ( 740, 0950, SubStr(cMesArqRef,3,4), oFont11 ) //Impressao do Ano

			oPrint:Box ( 900, 0035, 1550, 2180 ) 	//BOX VALORES
			oPrint:Box ( 930, 0055, 1150, 980 ) 	//BOX TOTAL DE SALARIOS PAGADOS PRIMA %
			oPrint:line ( 1000, 0055, 1000, 980 )   //LINHA VERTICAL DO TOTAL DE SALARIOS PAGADOS PRIMA %
			oPrint:line ( 930, 655, 1150, 655 )   	//LINHA HORIZONTAL DO TOTAL DE SALARIOS PAGADOS PRIMA %
			
			oPrint:say ( 950, 0100, "total de salarios pagados", oFont11 )
			oPrint:say ( 1060, 0300, Transform(aTotais[1], "99,999,999.99"), oFont11 )

			FPHIST82(xFilial("SRX") , "76" , SubStr(cMesArqRef,5,2) )
			cAliq := Val( Substr( SRX->RX_TXT , 3 , 4 ) )
			oPrint:say ( 950, 0750, "Prima %", oFont11 )			
			oPrint:say ( 1060, 750, Transform(cAliq, "999.99"), oFont11 )                                                              

			oPrint:say ( 1200, 0055, "CORRESPONDIENTE A LA CANTIDAD DE", oFont11n )
			oPrint:say ( 1200, 710, Transform(aTotais[2],"99999"), oFont11 )
			
			oPrint:say ( 1260, 0055, "DEPENDIENTES", oFont11n )			

			oPrint:say ( 1120, 1200, "PREMIO", oFont11 )
			cPremio := ( aTotais[1] * (cAliq/100) ) / 10
			
			FPHIST82(xFilial("SRX") , "57" , SubStr(cMesArqRef,3,4) + SubStr(cMesArqRef,1,2) )
			cAliqLey := Val( Substr( SRX->RX_TXT , 3 , 4 ) )                           	
			cAliqIVA := Val( Substr( SRX->RX_TXT , 3 , 4 ) )                           	
			If cAliqLey == 0 
				cAliqLey := 2
			EndIf

			oPrint:say ( 1200, 1200, "IMP. 2% LEY 4/12/53", oFont11 )
			cImpLey4 := cPremio * (cAliqLey/100)
			
			oPrint:say ( 1280, 1200, "SUB - TOTAL", oFont11 )
			cSubTotal	:= cPremio + cImpLey4
			
			oPrint:say ( 1360, 1200, "IVA", oFont11 )
			cIVA	:= cSubTotal * (cAliqIVA/100)
			
			oPrint:say ( 1450, 1200, "TOTAL A PAGAR", oFont11 )
			cTotal	:= cSubTotal + cIVA
			
			oPrint:say ( 1120, 1650, Transform(cPremio, "99,999,999.99"), oFont11 ) 	//Premio
			oPrint:say ( 1200, 1650, Transform(cImpLey4, "99,999,999.99"), oFont11 ) 	//Imp 2% Ley 4/12/53
			oPrint:say ( 1280, 1650, Transform(cSubTotal, "99,999,999.99"), oFont11 )	//Sub-Total
			oPrint:say ( 1360, 1650, Transform(cIVA, "99,999,999.99"), oFont11 )		//IVA
			oPrint:say ( 1450, 1650, Transform(cTotal, "99,999,999.99"), oFont11 )		//Total a pagar
                                                                                                         
			oPrint:line ( 1480, 0055, 1480, 680 )   //LINHA VERTICAL 'SELLO Y FIRMA DE LA EMPRESA'
			oPrint:say ( 1500, 0085, "SELLO Y FIRMA DE LA EMPRESA", oFont11 )
			                                                                                      
			oPrint:line ( 1480, 755, 1480, 980 )   	//LINHA VERTICAL 'FECHA'			
			oPrint:say ( 1500, 820, "FECHA", oFont11 )

			oPrint:Box ( 1580, 0035, 1800, 2180 ) 	//BOX BANCO  
			oPrint:say ( 1595, 970, "PARA USO DEL BANCO", oFont11 )
			oPrint:say ( 1700, 055, "recibido por:", oFont11 )

			oPrint:line ( 1730, 0355, 1730, 880 )   //LINHA VERTICAL 'SELLO Y FIRMA'
			oPrint:line ( 1730, 1055, 1730, 1300 )  //LINHA VERTICAL 'FECHA'
			oPrint:line ( 1730, 1500, 1730, 2160 )  //LINHA VERTICAL 'N� DE FACTURA'

			oPrint:say ( 1740, 455, "SELLO Y FIRMA", oFont11 )
			oPrint:say ( 1740, 1100, "FECHA", oFont11 )
			oPrint:say ( 1740, 1700, "N� DE FACTURA", oFont11 )

			oPrint:EndPage()
		EndIf
	Endif
Endif

Return         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPER042   �Autor  �Microsiga           � Data �  06/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CarregaPolizas()    
Local nPos	:=	0
Local aPolizas	:=	{}
DbSelectArea('CTT')
DbSetOrder(1)
DbGoTop()
While !EOF()
	If !Empty(CTT->CTT_POLIZA)
		If (nPos := Ascan(aPolizas,{|x| x[1]==CTT->CTT_POLIZA})) == 0
			Aadd(aPolizas,{CTT->CTT_POLIZA,{CTT->CTT_CUSTO},0,0,0,0,0,0})
			LOC_BSE2(CTT->CTT_POLIZA,@aPolizas[Len(aPolizas)][8])
		Else
			AAdd(aPolizas[nPos][2],CTT->CTT_CUSTO)
		Endif
	Endif                
	DbSkip()
Enddo	

Return aPolizas

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fPergGuia � Autor � Alex Sandro Fagundes  � Data �07/07/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta dialogo para selecao com botoes de radio             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function fPergGuia(nOpcRadio)
	Local nOpcAux
	Local oRadio
	Local oDlg
	Local oGroup
	Local oFont
	Local nReg
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}
	Local aButtons		:= {}
	Local bSet15		:= { || NIL }
	Local bSet24		:= { || NIL }
		
	nOpcAux   := nOpcRadio
	nOpcRadio := 0
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	/*
	��������������������������������������������������������������Ŀ
	� Monta as Dimensoes dos Objetos         					   �
	����������������������������������������������������������������*/
	aAdvSize			:= MsAdvSize()
	aAdvSize[5]			:=	420 //horizontal
	aAdvSize[3]			:=	212 // LARGURA
	aAdvSize[4]			:=	62  // ALTURA
	aAdvSize[6]			:=  150 //Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 2 , 2 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T.  } )
	aObjSize			:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
	
	@ aObjSize[1][1],aObjSize[1][2] GROUP oGroup TO aObjSize[1][3],aObjSize[1][4] LABEL OemToAnsi(STR0020) OF oDlg PIXEL	//"Planilla BSE / Guia BSE"
	oGroup:oFont:=oFont
	         
	@ aObjSize[1][1]+10,aObjSize[1][2]+10 RADIO oRadio VAR nOpcAux	ITEMS OemToAnsi(STR0021),OemToAnsi(STR0022)		;	//
										SIZE 115,010 OF oDlg PIXEL	//"Planilla BSE"###"Guia BSE"

	bSet15		:= { || nOpcRadio := nOpcAux, oDlg:End() }
	bSet24		:= { || nOpcRadio := -1,      oDlg:End() }

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL , aButtons )
	
	Return( nOpcRadio )