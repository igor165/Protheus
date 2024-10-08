//#INCLUDE "hspahr22.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "Report.ch" 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHR91  � Autor � Rogerio Tabosa     � Data �  28/07/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Relat�rio Ordem Servico  / Protocolo Exame                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function  HSPAHR91(cAtendimento, cPedidoIni, cPedidoFim, aSolic, lProt)


/*���������������������������������������������������������������������Ŀ
 � Declaracao de Variaveis                                             �
 ����������������������������������������������������������������������� */

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio " //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario." //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""                              	
Local cPict          := ""                    
Local imprime        := .T.
Local aOrd 				      := {}   
Local nLin           := 80     
Local nX			:= 0 

Default lProt := .F.

Private lProtocolo	 := lProt
Private titulo       := IIF(lProtocolo,"Protocolo de Exame","Requisi��o de Exame") //
Private Cabec1       := ""
Private Cabec2       := "" 
Private Cabec3       := ""   
Private Cabec4       := "" 
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
//Private tamanho      := "M"
Private nomeprog     := "HSPAHR91" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {"Administracao" , 1, "Zebrado", 2, 2, 1, "", 1}  //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR91" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cString      := ""
Private lPrescri     := .F.  
Private cRegAteIni := "", cRegateFim := "", cCodPacIni := "", cCodPacFim := "", dDatAteIni := "", dDatAteFim := "", dDatPreIni := "", dDatPreFim := "", cSeqPre := "", nTipoImp:= ""
Private nColStart  := 0050  
Private nLenPag    := 2500
Private nColEnd    := nLenPag - 0050          
Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao  
Private cMntApre := ""
Private cSolic	:= ""

Private cCodPedIni := IIF(Empty(cPedidoIni)  ,"",cPedidoIni  )
Private cCodPedFim := IIF(Empty(cPedidoFim)  ,"",cPedidoFim  )



If !Empty(aSolic)
	For nX := 1 To Len(aSolic)
		cSolic += IIF(!Empty(cSolic),",","")+"'"+aSolic[nX]+"'"
	Next
EndIf   

                                                   
nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2     


//**************************************************
/*                    1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */

If lProtocolo
	Cabec1 := "OS              C�digo                Descri��o                                                              Data Entrega "
Else
	Cabec1 := "OS              C�digo                Descri��o  "                                                            
EndIf

Cabec2 := ""

RptStatus({|| RotImp(Cabec1,Cabec2,Titulo,nMaxLin)},Titulo)

//**************************************************


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � Mario Arizono      � Data �  28/05/07   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

                         


// ************************************************
Static Function RotImp(Cabec1,Cabec2,Titulo,nMaxLin)

Local cRegate    	:= "" 

//Local oFont      := TFont():New("Courier New", 11, 09,, .T.,,,,,.F.) //Titulos dos Campos
Local nHeiPag    	:= 3200
Local nLin       	:= nHeiPag + 1  
Local aObs			:= {}
Local nLinObs 		:= 0
Local cObs			:= ""
Local nObs			:= 0
//Local nCont      := 0

Local cSql         := ""
//Local nTotLin      := 0
//Local lNovaPag   := .F.

Private lCabec     := .T. 
Private oFont1 := TFont():New( "Courier New", 09, 10, , , , , , , .F. ) 
Private oFont2 := TFont():New( "Courier New", 09, 12, , .T., , , , , .F. ) 
Private oFont3 := TFont():New( "Courier New", 09, 10, , .T., , , , , .F. ) 
Private oFont4 := TFont():New( "Courier New", 09, 10, , .T., , , , , .F.,.T. ) 
Private nLinF  := 260
Private cCodCon     := ""
Private cCodPla_De  := ""
Private cCodPla_Ate := ""
Private cCodLoc_De  := ""
Private cCodLoc_Ate := ""
Private cNrLote     := ""
Private cNumPro     := ""
Private cNrFatu     := ""
Private dDatAte_De  := ""
Private dDatAte_Ate := ""
Private nOrdem      := 0
Private cNrSeqG     := ""

cSql := "  SELECT GBY_SOLICI,GNJ_REGATE, GCY.GCY_DATATE, GCY_HORATE, GNJ_REGGER, GBY.GBY_NOMPAC, GCY_IDADE, GCY_SEXO, GBY_COMPTO, "
cSql += "         GCM_CODCON, GCM_CODPLA, GCM_DESPLA, GBY_LOCSOL, GAV_CODLOC, GAV_QUARTO, GAV_LEITO, GCY_DTNASC, "
cSql += "         GBY_CODLOC, GNJ_SOLCRM, GNJ_CODSEQ, GNJ_DATPED, GBY_PROSOL, GA7_DESC, GA7_MNEMON, GCY_CODLOC, GNJ_SOLCRM, GBH_TEL "
cSql += "    FROM "+RetSqlName("GNJ")+" GNJ "
cSql += "    JOIN "+RetSqlName("GCY")+" GCY ON GCY_REGATE = GNJ_REGATE AND GCY.GCY_FILIAL = '"+xFilial("GCY")+"' AND GCY.D_E_L_E_T_ <> '*'"
cSql += "    JOIN "+RetSqlName("GBH")+" GBH ON GNJ_REGGER = GBH_CODPAC AND GBH.GBH_FILIAL = '"+xFilial("GBH")+"' AND GBH.D_E_L_E_T_ <> '*'"
cSql += "    JOIN "+RetSqlName("GBY")+" GBY ON GBY_CODPED = GNJ_CODSEQ AND GBY.GBY_FILIAL = '"+xFilial("GBY")+"' AND GBY.D_E_L_E_T_ <> '*'"
cSql += "    JOIN "+RetSqlName("GD4")+" GD4 ON GD4_REGGER = GBY_REGGER AND GD4.GD4_FILIAL = '"+xFilial("GD4")+"' AND GD4.D_E_L_E_T_ <> '*' "
cSql += "     AND GD4_CODPLA = '" +cCodPla+ "'"
cSql += "    JOIN "+RetSqlName("GCM")+" GCM ON GCM_CODPLA = GD4_CODPLA AND GCM.GCM_FILIAL = '"+xFilial("GCM")+"' AND GCM.D_E_L_E_T_ <> '*'  "
cSql += "    LEFT JOIN "+RetSqlName("GAV")+" GAV ON GAV_REGATE = GBY_REGATE AND GAV.GAV_FILIAL = '"+xFilial("GAV")+"' AND GAV.D_E_L_E_T_ <> '*'"
cSql += "     AND GAV_RESERV = GBY_RESERV"
cSql += "    JOIN "+RetSqlName("GA7")+" GA7 ON GA7_CODPRO = GBY_PROSOL AND GA7.GA7_FILIAL = '"+xFilial("GA7")+"' AND GA7.D_E_L_E_T_ <> '*'"
cSql += "   WHERE GNJ_FILIAL = '"+xFilial("GNJ")+"' AND GNJ.D_E_L_E_T_ <> '*' "

 
IF(!Empty(cRegAte))
	cSql += "     AND GNJ_REGATE = '"+cRegAte+"'"
EndIf
IF !Empty(cCodPedIni) .And. !Empty(cCodPedFim)
	cSql += "     AND GNJ_CODSEQ >= '"+cCodPedIni+"' AND GNJ_CODSEQ <= '"+cCodPedFim+"' "
ElseIf !Empty(cCodPedIni)
	cSql += "     AND GNJ_CODSEQ = '"+cCodPedIni+"' "
EndIf

IF(!Empty(cSolic))
	cSql += "     AND GBY_SOLICI IN ("+cSolic+")"
EndIf

cSql += "   ORDER BY GNJ_CODSEQ, GBY_CODLOC"

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRY"

DbSelectArea("QRY")

  
If Eof()
	HS_MsgInf("Nenhuma informa��o foi encontrada para a sele��o!", "Aten��o", "Verifique a sele��o")   //"Nenhuma informa��o foi encontrada para a sele��o!"###"Aten��o"###"Verifique a sele��o"
 	Return(Nil)
EndIf
oPrn:=TMSPrinter():New()
oPrn:Setup()
oPrn:SetPortrait()

nEspLin	   :=   50   	             // espa�amento entre linha
nMarSup	   :=  080   	             // margen superior
nCol1 	    :=  015		               // margen da coluna1
nCol2 	    :=  617		               // margen da coluna2
nCol3 	    :=  817		               // margen da coluna3


oPrn:StartPage()
nLin 	  := nMarSup      // Linha inicial
//oPrn:EndPage()
//oPrn:StartPage() 
nLin := FS_CabGraf(oPrn, nLenPag, NomeProg, 100, Titulo)

nLin += 80
oPrn:Say(nLin, 050, "Local Executante: " + Substr(HS_IniPadr("GCS", 1, QRY->GBY_CODLOC, "GCS_NOMLOC"),1,30), oFont3, 100)  
If !lProtocolo
	MsBar3( 'CODE128', 2 , 15, Alltrim(QRY->GNJ_CODSEQ), oPrn, .F., , .T., 0.015, 0.6, .F., 'TAHOMA', 'B', .F. )
EndIf
oPrn:Say(nLin, nColEnd-380, "OS: " + Alltrim(QRY->GNJ_CODSEQ), oFont3, 100)  
nLin += nEspLin
oPrn:Line(nLin, nColStart, nLin,  nColEnd) 
nLin += nEspLin                            
oPrn:Say(nLin, 050, "Paciente: " + Alltrim(QRY->GBY_NOMPAC), oFont3, 100)  
oPrn:Say(nLin, 1300, "Atendimento: " + Alltrim(QRY->GNJ_REGATE), oFont1, 100)  
oPrn:Say(nLin, 1800, "Sexo: "+IIF(QRY->GCY_SEXO == '1', "Feminino", "Masculino"), oFont1, 100)  
nLin += nEspLin   
oPrn:Say(nLin, 050, "Data de Atendimento: "+ DtoC(StoD(QRY->GCY_DATATE)), oFont1, 100)  
oPrn:Say(nLin, 1300, "Nascimento: "+ DtoC(StoD(QRY->GCY_DTNASC)), oFont1, 100)      
oPrn:Say(nLin, 1800, "Idade: " + FS_Idade(StoD(QRY->GCY_DTNASC), dDataBase), oFont1, 100)      //oPrn:Say(nLin, 1800, "Idade: "+QRY->GCY_IDADE, oFont1, 100)      
nLin += nEspLin   
oPrn:Say(nLin, 050, "Fone: " + Alltrim(QRY->GBH_TEL), oFont1, 100)  
nLin += nEspLin   
oPrn:Say(nLin, 050,"Convenio/Plano: "+QRY->GCM_CODCON+" - "+AllTrim(SubStr(Hs_IniPadr("GA9", 1, QRY->GCM_CODCON,"GA9_NOME",,.F.),1,25))+"/"+QRY->GCM_CODPLA+" - "+AllTrim(SubStr(QRY->GCM_DESPLA,1,25))    , oFont1, 100)  
oPrn:Say(nLin, 1800, "Prontu�rio: "+QRY->GNJ_REGGER, oFont1, 100)      
nLin += nEspLin   
oPrn:Line(nLin, nColStart, nLin,  nColEnd) 
nLin += nEspLin   
oPrn:Say(nLin, 050, "Medico Solic.: "+QRY->GNJ_SOLCRM+" - " + HS_IniPadr("SRA", 11, QRY->GNJ_SOLCRM, "RA_NOME"), oFont3, 100)  
nLin += nEspLin 
nLin += nEspLin  
oPrn:Say(nLin, 050, Cabec1, oFont4, 100)   
nLin += nEspLin  
oPrn:Line(nLin, nColStart, nLin,  nColEnd)   
nLin += nEspLin 

//nTeste := 1
QRY->(DbGoTop())
While !QRY->(Eof())
     
	If nLin > 3200
		nLin := nMarSup 
		oPrn:EndPage()
		oPrn:StartPage()
		nLin += nEspLin  
		oPrn:Say(nLin, 050, Cabec1, oFont4, 100)   
		nLin += nEspLin  
		oPrn:Line(nLin, nColStart, nLin,  nColEnd)   
		nLin += nEspLin 
	EndIf

	oPrn:Say(nLin, 050, QRY->GNJ_CODSEQ , oFont1, 100)
	oPrn:Say(nLin, 300, QRY->GBY_PROSOL, oFont1, 100)	
	oPrn:Say(nLin, 700, IIf(Empty(QRY->GA7_MNEMON),Alltrim(QRY->GA7_DESC),Alltrim(QRY->GA7_MNEMON) + " - " + Alltrim(QRY->GA7_DESC)) , oFont1, 100)		
	If lProtocolo
		oPrn:Say(nLin, 1900, DtoC(HS_CALENT(QRY->GNJ_CODSEQ)), oFont1, 100)			
	EndIf
	//nTeste ++
	nLin += nEspLin 
	//If nTeste == 20 .OR.  nTeste == 40 .OR. nTeste == 60 .OR. nTeste == 80 .OR. nTeste > 80
		QRY->(DbSkip())
	//EndIf
End
If lProtocolo
    cObs := FS_OBSPROT()
	nLinObs	:= MLCOUNT(cObs, , , )

	aObs	:= {}	
	For nObs := 1 To nLinObs
		aADD(aObs,{MEMOLINE(cObs, , nObs, )})
	Next nObs
	
	If nLin < 2700	
		nLin := 2700
	Endif
	For nObs := 1 To Len(aObs)
		nLin += 0040
		oPrn:Say(nLin, 0100, aObs[nObs,1], oFont1)
	Next nObs 
EndIf

oPrn:Preview()
oPrn:End()  

QRY->(DbCloseArea())

MS_FLUSH()

Return(Nil)

  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_CabGraf�Autor  �Andr� Cruz          � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Impress�o de cabe�alho gr�fico                             ���
�������������������������������������������������������������������������͹��
���Sintaxe   � HS_CABGRAF(oTMSPinter, nLenPag, cNomeFunct, nColTit,      ���
���          �             cTitulo)                                      ���
���          � oTMSPrinter -> Objeto TMSPrinte instanciado.               ���
���          � nLenPag     -> Largura da P�gina.                          ���
���          � cNomeFunct  -> Nome do programa.                           ���
���          � nColTit     -> Coluna onde o t�tulo do relat�rio ser�      ���
���          �                impresso.                                   ���
���          � cTitulo     -> T�tulo do relat�rio.                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_CabGraf(oPrn, nLenPag, cNomeFunc, nColTit, cTitulo)
Local cEmpLogo   := "system\lgrl" + Lower(SM0->M0_CODIGO) + ".bmp"

Local nLin1      := 0050
Local nLin2      := 0100
Local nLin3      := 0150
Local nLinTit    := 0080

Local oCabFont1  := TFont():New("Courier New", 13, 16,, .T.,,,,,.F.) //cTitulos dos Relat�rio
Local oCabFont2  := TFont():New("Courier New", 11, 09,, .F.,,,,,.F.) //Adendos Cabe�alho

Default nColTit    := 0800

oPrn:Line(0000, nColStart, 0000,  nColEnd)

If File(cEmpLogo)
 oPrn:SayBitmap(nLin1-40, nColStart, cEmpLogo, 0300, 0080)
Else
 oPrn:Say(nLin1, nColStart, SM0->M0_NOME, oCabFont2, 100)
EndIf

oPrn:Say(nLin2, nColStart, "SIGA/" + AllTrim(cNomeFunc) + "/v." + cVersao, oCabFont2, 100)
oPrn:Say(nLin3, nColStart, Time(), oCabFont2, 100)
oPrn:Say(nLinTit, 900, cTitulo, oCabFont1, 100)
oPrn:Say(nLin1, nColEnd-480, Padl("P�gina: " + AllTrim(Str(m_pag++)), 20), oCabFont2, 100) //"P�gina: " //"P�gina: "
oPrn:Say(nLin2, nColEnd-480, Padl("Dt. Ref.: " + DToC(dDataBase), 20), oCabFont2, 100) //"Dt. Ref.: " //"Dt. Ref.: "
oPrn:Say(nLin3, nColEnd-480, Padl("Emiss�o: " + DToC(Date()), 20), oCabFont2, 100) //"Emiss�o: " //"Emiss�o: "

Return 0220

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FS_Idade      � Autor �                  � Data   /  /     ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calcula a idade do Paciente                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FS_Idade(dDataI, dDataF)
Local aIdade := HS_DifData(dDataI, dDataF)

Return(StrZero(aIdade[1], 2) + "a" + StrZero(aIdade[2], 2) + "m" + StrZero(aIdade[3], 2) + "d") //" ano(s) "###" mes(es) "###" dia(s) "


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FS_OBSPROT    � Autor � Rogerio Tabosa   � Data 28/01/2010 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Retorna Observacao do Protocolo no Txt                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FS_OBSPROT()

Local cEnvServ := GetEnvServer()  
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97())) 
Local cNomArq	:= ""
Local cTxtLab := ""     

If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "OBSPROTOCOLOLAB.txt"
Else
	cNomArq := cDirRaiz + "\OBSPROTOCOLOLAB.txt"
EndIf 

cTxtLab := MemoRead(cNomArq) 

Return (cTxtLab)
