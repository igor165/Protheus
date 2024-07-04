#include "protheus.ch"
#include "CTBR816.ch"
#include "Birtdataset.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���DataSet   � CTBR816D � Autor � alfredo.medrano     � Data �  03/12/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Crea definici�n Data Set    						           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR816D                                                   ���
�������������������������������������������������������������������������Ĵ��
���          � para integracion en el reporte BIRT                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���jonathan glez �08/09/15�TTHAMD     �Se cambia la forma de imprimir el  ���
���              �        �           �archivo Termino Auxiliares para que���
���              �        �           �no permita imprimir archivo mayores���
���              �        �           �a 2 mil caracteres.                ���
���jonathan glez �23/10/15�TTKUXV     �Se cambia la manera de usar la ins-���
���              �        �           �truccion dbselectarea para archivos���
���              �        �           �temporales y se pase la variable   ���
���              �        �           �cArqTmp entre comillasal momento de���
���              �        �           �hacer el dbselectarea().           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Dataset CTBR816D
    title OemToAnsi(STR0021)		  //Emisi�n del An�lisis Vertical
    description  OemToAnsi(STR0016)  //Este programa imprimira la Demostracion de Ganancias
    pergunte "CTR540"

COLUMNS
 DEFINE COLUMN CLN_CONTA 		TYPE 	CHARACTER 	SIZE 50 	LABEL OemToAnsi(STR0019) //Cuenta
 DEFINE COLUMN CLN_VLRPER		TYPE 	CHARACTER 	SIZE 22
 DEFINE COLUMN CLN_VLRPEC		TYPE 	CHARACTER 	SIZE 8
 DEFINE COLUMN CLN_VLRACU		TYPE 	CHARACTER 	SIZE 22
 DEFINE COLUMN CLN_VLRPCU		TYPE 	CHARACTER 	SIZE 8
 DEFINE COLUMN CLN_TITULF		TYPE 	CHARACTER 	SIZE 50	LABEL OemToAnsi(STR0023)// "Lib. Fiscales"
 DEFINE COLUMN CLN_FECHIN		TYPE 	CHARACTER 	SIZE 10
 DEFINE COLUMN CLN_FECHFI		TYPE 	CHARACTER 	SIZE 10
 DEFINE COLUMN CLN_NOMECO		TYPE 	CHARACTER 	SIZE 100
 DEFINE COLUMN CLN_CGC			TYPE 	CHARACTER 	SIZE 60
 DEFINE COLUMN CLN_IMG			TYPE 	CHARACTER	SIZE 30
 DEFINE COLUMN CLN_EMI			TYPE 	CHARACTER	SIZE 20
 DEFINE COLUMN CLN_ESTRE			TYPE 	CHARACTER	SIZE 60
 DEFINE COLUMN CLN_PAG			TYPE 	CHARACTER	SIZE 15
 DEFINE COLUMN CLN_NAMARQ		TYPE 	CHARACTER	SIZE 15
 DEFINE COLUMN CLN_HRS			TYPE 	CHARACTER	SIZE 15
 DEFINE COLUMN CLN_NUMPAG	   TYPE 	NUMERIC	SIZE 1
 DEFINE COLUMN CLN_PERIOD		TYPE 	CHARACTER	SIZE 15
 DEFINE COLUMN CLN_TOTPER		TYPE 	CHARACTER	SIZE 15
 DEFINE COLUMN CLN_ACUMES 		TYPE 	CHARACTER	SIZE 15
 DEFINE COLUMN CLN_TOTACU 		TYPE 	CHARACTER	SIZE 15
 DEFINE COLUMN CLN_AUXTEX		TYPE	CHARACTER	SIZE 2000	LABEL OemToAnsi(STR0028)// "Info Aux."

DEFINE QUERY 	"SELECT CLN_CONTA, CLN_VLRPER, CLN_VLRPEC, CLN_VLRACU, CLN_VLRPCU, CLN_TITULF, "+;
				"CLN_FECHIN,CLN_FECHFI,CLN_NOMECO,CLN_CGC,CLN_IMG,CLN_EMI,CLN_ESTRE,CLN_PAG, "+;
				"CLN_NAMARQ,CLN_HRS,CLN_NUMPAG,CLN_PERIOD,CLN_TOTPER,CLN_ACUMES,CLN_TOTACU, CLN_AUXTEX "+;
				"FROM %WTable:1% "

PROCESS DATASET
	Local lEnd		:= .T.
 	Private dFchRef 	:=	self:execParamValue("MV_PAR01")
	Private cCodLib 	:= 	self:execParamValue("MV_PAR02")
 	Private cMoneda 	:= 	self:execParamValue("MV_PAR03")
	Private nConsid 	:= 	self:execParamValue("MV_PAR04")
 	Private dPeriDe 	:= 	self:execParamValue("MV_PAR05")
	Private dPerioA 	:= 	self:execParamValue("MV_PAR06")
 	Private nPagIni 	:= 	self:execParamValue("MV_PAR07")
 	Private nImTAux 	:= 	self:execParamValue("MV_PAR08")
 	Private cPathAuxi	:= 	self:execParamValue("MV_PAR09")
 	Private nXctoN1 	:= 	self:execParamValue("MV_PAR10")
 	Private cTipSal 	:= 	self:execParamValue("MV_PAR11")
 	Private nTiNomV 	:= 	self:execParamValue("MV_PAR12")

	Private cConsTmp

	 If ::isPreview()
        //utilize este m�todo para verificar se esta em modo de preview
        //e assim evitar algum processamento, por exemplo atualiza��o
        //em atributos das tabelas utilizadas durante o processamento
    EndIf

	//cria a tabela
   cConsTmp := ::createWorkTable()
	//cria uma barra de progresso (opcional)
	Processa( {|lEnd| CTBR816RP(@lEnd, dFchRef, cCodLib, cMoneda, nConsid, dPeriDe, dPerioA, nPagIni, ;
		                         nImTAux, cPathAuxi, nXctoN1, cTipSal, nTiNomV)}, OemToAnsi(STR0001), ;
		                         OemToAnsi(STR0003), .T. ) //"Favor de Aguardar....." + "Generando informe."

	If !lEnd
	 //informa ao objeto BIRTReport o motivo do cancelamento
		MSGINFO(OemToAnsi(STR0022))//"No existen datos que satisfagan la condici�n de selecci�n."
	else
		MSGINFO(STR0030) // 'Proceso finalizado'
	EndIf

    //deve retorna .T. para indicar que a gera��o do relat�rio pode ser feita
    //ou .F., devido a n�o atender alguma condi��o da regra de neg�cios e nesse
    //caso o relat�rio n�o ser� gerado

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CTBR816RP � Autor � Alfredo Medrano       � Data �04/12/2014���
�������������������������������������������������������������������������Ĵ��
���Descricao � Llena el Data Set con los registros Filtrados              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR816R(ExpL1,ExpD2,ExpC3,ExpC4,ExpC5,ExpD6,ExpD7,ExpN8,  ���
���          � ExpN9,ExpN10,ExpC11,ExpN12)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 := Logico,  ExpD2:= Fecha Referencia,                ���
���          � ExpC3 := cod libros,  ExpC4:= Moneda,  ExpC5:= concidera   ���
���          � ExpD6 := Periodo Inicio, ExpD7 := Periodo Fin,             ���
���          � ExpN8 := imprime term Aux, ExpN9 := arch. Term Aux,        ���
���          � ExpN10:= cons. 1er Nivel, ExpC11 := Tipo Saldo             ���
���          � ExpN12:= Tit. Nom Vision                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Data Set del Reporte                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CTBR816RP(lRet, dFchRef, cCodLib, cMoneda, nConsid, dPeriDe, dPerioA, nPagIni, nImTAux, cPathAuxi, nXctoN1, cTipSal, nTiNomV)
//�����������������������������������������������������������������Ŀ
//� Parametros                                					     �
//� mv_par01            // �Fecha de Referencia ?                   �
//� mv_par02            // �Codigo Config Libros ?                  �
//� mv_par03            // �Moneda ?                                �
//� mv_par04            // �Considera ?                             �
//� mv_par05            // �Periodo de ?                            �
//� mv_par06            // �Periodo a ?                             �
//� mv_par07            // �Pagina Inicial ?                        �
//� mv_par08			   // �Imprime Termino Auxiliar ?  		     �
//� mv_par09            // �Termino Auxil.por imprimirse            �
//� mv_par10            // �Consid.% tot. 1o nivel?                 �
//� mv_par11            // �Tipo de saldo ?                         �
//� mv_par12            // �Titulo como nombre de vision            �
//�������������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local aSetOfBook	:= CTBSetOf(cCodLib)
Local aCtbMoeda	:= {}
Local lin 		:= 3001
Local cArqTmp
Local cPicture
Local cDescMoeda
Local lFirstPage	:= .T.
Local nTraco		:= 0
Local aTotal 		:= {}
Local nTotal		:= 0
Local nTotMes		:= 0
Local nTotAtu		:= 0
Local aColunas	:= {}, nColuna
Local cTpValor	:= GETMV("MV_TPVALOR")
Local lImpTrmAux	:= Iif(nImTAux == 1,.T.,.F.)
Local cArqTrm		:= ""
Local nTotPer		:= 0
Local cAuxText	:= ""
Local cProcesso	:= OemToAnsi(STR0002)
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local cTitAux
Local cStartPath	:= GetSrvProfString("StartPath","")
Local cNameFile	:= ""
Private dInicio
Private dFinal
Private dPeriodo0
Private cTitulo := OemToAnsi(STR0010)
Private aDatos  := {.f., ""}

// faz a valida��o do livro
if ! VdSetOfBook( cCodLib , .T. )
	 return .F.
endif

cTitulo	:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], cTitulo)		// Titulo definido SetOfBook

If Valtype(nTiNomV)=="N" .And. (nTiNomV == 1)
	cTitulo := CTBNomeVis( aSetOfBook[5] )
EndIf

If nConsid == 2
	dInicio  	:= dPeriDe
	dFinal		:= dPerioA
	dPeriodo0	:= CtbPeriodos(cMoneda,dInicio,dFinal,.F.,.F.)[1][2]
	cTitAux		:= STR0012 + dToc(dInicio) + STR0011 + dToc(dFinal)
Else
	dInicio  	:= Ctod("01/" + Subs(Dtoc(dFchRef), 4))
	dFinal		:= dFchRef
	dPeriodo0 	:= Ctod(Str(Day(LastDay(dFchRef)), 2) + "/" + Subs(Dtoc(dFchRef), 4))
	cTitAux 	:= ""
EndIf

aCtbMoeda := CtbMoeda(cMoneda, aSetOfBook[9])
If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,cMoneda)

cPicture 	:= aSetOfBook[4]
If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 15		// Bops 59240
	cPicture := ""
Endif

cStartPath := AjuBarPath(cStartPath)
cNameFile := "lgrl"+cEmpAnt+".bmp" //cEmpAnt  y cFilAnt variables Globales

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao						  �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dInicio,dFinal,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
			"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
			"",Repl("Z", Len(CTH->CTH_CLVL)),cMoneda,;
			cTipSal,aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30))},;
			STR0006, cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")
dbGoTop()

While cArqTmp->(! Eof())
	Aadd(aColunas, Recno())
	If cArqTmp->IDENTIFI = "4"
		nTotal := Ascan(aTotal, { |x| x[1] = cArqTmp->CONTA })
		If nTotal = 0
			Aadd(aTotal, { cArqTmp->CONTA, 0, 0 })
			nTotal := Len(aTotal)
		Endif
		aTotal[nTotal][2] += cArqTmp->SALDOPER
		aTotal[nTotal][3] += cArqTmp->(SALDOATU - SALDOANT)
	Endif
	cArqTmp->(DbSkip())
EndDo
If Len(aTotal) = 0
	aTotal := { {"", 0, 0 }}
Endif

For nColuna := 1 To Len(aColunas)
	cArqTmp->(MsGoto(aColunas[nColuna]))

	If cArqTmp->DESCCTA = "-"
		oReport:ThinLine()   	// horizontal
	Else
		nTotal := Ascan(aTotal, { |x| x[1] = cArqTmp->SUPERIOR })
		If nXctoN1 == 1	//Se considerar o % do total em relacao a conta de nivel 1
			If Empty(cArqTmp->SUPERIOR)
				nTotMes := cArqTmp->SALDOPER
				nTotAtu := cArqTmp->(SALDOATU - SALDOANT)
			EndIf
		Else
			If Empty(cArqTmp->SUPERIOR) .Or. cArqTmp->IDENTIFI = "4"
				nTotMes := cArqTmp->SALDOPER
				nTotAtu := cArqTmp->(SALDOATU - SALDOANT)
			ElseIf nTotal = 0
				nTotMes := nTotAtu := 0
			Else
				nTotMes := aTotal[nTotal][2]
				nTotAtu := aTotal[nTotal][3]
			Endif
		EndIF

			RecLock(cConsTmp,.T.)
	      	(cConsTmp)->CLN_CONTA		:= cArqTmp->DESCCTA
			(cConsTmp)->CLN_VLRPER		:= ValorCTB(cArqTmp->(SALDOATU - SALDOANT),,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL, cArqTmp->CONTA,,,cTpValor,,, .F.)
			(cConsTmp)->CLN_VLRPEC		:= Transform((cArqTmp->(SALDOATU - SALDOANT) / nTotAtu) * 100, "@E 9999.99")
			(cConsTmp)->CLN_VLRACU		:= ValorCTB(cArqTmp->SALDOPER,,,aTamVal[1],nDecimais,.T.,cPicture, cArqTmp->NORMAL,cArqTmp->CONTA,,,cTpValor,,,.F.)
			(cConsTmp)->CLN_VLRPCU		:= Transform(cArqTmp->(SALDOPER / nTotMes) * 100, "@E 9999.99")
			(cConsTmp)->CLN_TITULF		:= cTitulo
			(cConsTmp)->CLN_FECHIN		:= dtos(dPeriDe)
 			(cConsTmp)->CLN_FECHFI		:= dtos(dPerioA)
 			(cConsTmp)->CLN_NOMECO		:= SM0->M0_NOMECOM
 			(cConsTmp)->CLN_IMG			:= cNameFile
 			(cConsTmp)->CLN_CGC			:= SM0->M0_CGC
 			(cConsTmp)->CLN_EMI			:= STR0029 // Emision :
 			(cConsTmp)->CLN_ESTRE		:= IIF( nTiNomV == 1 ,UPPER(cTitulo) + " "  + cTitAux, UPPER(STR0010) + " "  + cTitAux)  //"Estado de Resultado"
 			(cConsTmp)->CLN_PAG			:= STR0032 // P�gina :
 			(cConsTmp)->CLN_NAMARQ		:= Alltrim(FunName())
 			(cConsTmp)->CLN_HRS			:= STR0033 + time()  // Hora...:
 			(cConsTmp)->CLN_NUMPAG		:= nPagIni
 			(cConsTmp)->CLN_PERIOD		:= IIf(nConsid == 2, OemToAnsi(STR0013), Dtoc(dFchRef))//"Periodo "
			(cConsTmp)->CLN_TOTPER		:= IIf(nConsid == 2, OemToAnsi(STR0014), OemToAnsi(STR0008))//"% Per "//"% Tot Per"
			(cConsTmp)->CLN_ACUMES 		:= IIf(nConsid == 2, OemToAnsi(STR0009), OemToAnsi(STR0007) + Subs(Dtoc(dFchRef), 4)) //Acumulado //"Mes "
			(cConsTmp)->CLN_TOTACU 		:= IIf(nConsid == 2, OemToAnsi(STR0025), OemToAnsi(STR0024))//"% Acum"//"% Tot Acum"
			(cConsTmp)->CLN_AUXTEX		:= ""
			(cConsTmp)->(MsUnlock())
	Endif

Next

If lImpTrmAux

	while !aDatos[1]
		aDatos := {.f.,""}
		ValTermCTB("CTR540")
	enddo

	RecLock(cConsTmp,.T.)
		(cConsTmp)->CLN_AUXTEX	:= aDatos[2]
	(cConsTmp)->(MsUnlock())

Endif

cArqTmp->(dbCloseArea())

Set Filter To
If Select(cArqTmp) == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF

dbselectArea("CT2")

Return
