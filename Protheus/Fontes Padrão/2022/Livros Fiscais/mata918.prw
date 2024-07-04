#INCLUDE "MATA918.CH"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA918   �Autor  �Luciana Pires       � Data �  05.09.06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Dispoe sobre o regime tributario simplificado da            ���
���          �Microempresa e da Empresa de Pequeno Porte (MPEs e EPPs) no ���
���          �Estado do Rio de Janeiro (SIMPLES RIO)                      ���
�������������������������������������������������������������������������͹��
���Uso       � SigaFis                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function MATA918()

Local nRecBrutA		:= 0
Local nRecBrutM		:= 0
Local aICMSDev 		:= {}  
Local aReceita		:= ""
Local dDataIni		:= CtoD("//")
Local dDataFim		:= CtoD("//")

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("MTA918",.T.)    

//�������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                    �
//� mv_par01        // Data Inicial                                         �
//� mv_par02        // Data Final                                           �
//� mv_par03		// Taxa UFIR                                            �
//���������������������������������������������������������������������������
dDataIni	:= mv_par01
dDataFim	:= mv_par02
nTaxa		:= mv_par03                   

dDtRecIni	:= Ctod("01/01/"+ Str(Year(mv_par01)-1,4))
dDtRecFim	:= Ctod("31/12/"+ Str(Year(mv_par01)-1,4))

nRecBrutA 	:= CalcRBruta(dDtRecIni, dDtRecFim)  

//��������������������������������������������������Ŀ
//�Receita Bruta Acumulada informada manualmente     �
//����������������������������������������������������
If !Empty(GetNewPar("MV_RBACRJ",""))
	aReceita := &(GetNewPar("MV_RBACRJ",{0,0})) 
	If aReceita[1] == Year(dDtRecFim)		
		nRecBrutA := aReceita[2]
	Endif
Endif

nRecBrutM	:= CalcRBruta(dDataIni, dDataFim)       
aICMSDev	:= CalcImpost(nRecBrutA, nRecBrutM, nTaxa)
Tela (nRecBrutA, nRecBrutM, aICMSDev[1][1], dDtRecIni, dDtRecFim, aICMSDev[1][2], aICMSDev[1][3])           

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CalcRBruta�Autor  �Luciana Pires       � Data �  05.09.06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula a receita bruta no periodo selecionado sem as ST e  ���
���          �Devolu��es                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                  

Function CalcRBruta(dDataIni, dDataFim)                                                                     
                         
Local aAreaAnt 		:= GetArea()
Local cTransf		:= GetNewPar("MV_TRANSRJ","")
Local cAliasSF3		:= "SF3"
Local nTotRecBru 	:= 0     

#IFDEF TOP
	Local aStruSF3	:=	{}
	Local cQuery	:=	""
	Local nX		:=	0
#ELSE
	Local cIndex    :=	""
	Local cCondicao :=	""
#ENDIF

dbSelectArea(cAliasSF3)
dbSetOrder(1)
ProcRegua(LastRec())

#IFDEF TOP
    If TcSrvType()<>"AS/400"
	    cAliasSF3	:= "SF3Query"
		aStruSF3	:= SF3->(dbStruct())
		cQuery		:= "SELECT SF3.F3_VALCONT, SF3.F3_ENTRADA "
		cQuery 		+= "FROM " + RetSqlName("SF3") + " SF3 "
		cQuery 		+= "WHERE SF3.F3_FILIAL='" + xFilial("SF3") + "' AND "
		cQuery 		+= "SF3.F3_ENTRADA>='" + DtoS(dDataIni) + "' AND "
		cQuery 		+= "SF3.F3_ENTRADA<='" + Dtos(dDataFim) + "' AND "	
		cQuery    	+= "SF3.F3_CFO>='5' AND "
		cQuery 		+= "SF3.F3_TIPO<>'D' AND SF3.F3_TIPO<>'B' AND SF3.F3_TIPO<>'S' AND "
		cQuery 	   	+= "SF3.F3_DTCANC='' AND "
		cQuery    	+= "SF3.F3_OBSERV NOT LIKE '%CANCELAD%' AND "               
		cQuery 		+= "SF3.F3_ICMSRET=0 AND SF3.F3_CFO NOT IN('"+cTransf+"') AND "
		cQuery 		+= "SF3.D_E_L_E_T_=' ' "               
		cQuery 		+= "ORDER BY SF3.F3_ENTRADA "               		
		
		cQuery 		:= ChangeQuery(cQuery)                       
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)
		For nX := 1 To len(aStruSF3)
			If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
				TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
			EndIf
		Next nX
		
		dbSelectArea(cAliasSF3) 
	Else
#ENDIF
    cIndex    := CriaTrab(NIL,.F.)
    cCondicao := 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
   	cCondicao += 'DTOS(F3_ENTRADA) >= "' + DTOS(dDataIni) + '" .And. DTOS(F3_ENTRADA) <= "' + DTOS(dDataFim) + '" '
	cCondicao += '.And. Substr(F3_CFO,1,1) >= "5" '
	cCondicao += '.And. !(F3_TIPO $ "DBS") '
	cCondicao += '.And. Empty(F3_DTCANC) '
	cCondicao += '.And. !("CANCELAD" $ F3_OBSERV) '       
	cCondicao += '.And. F3_ICMSRET == 0 .And. !F3_CFO $("'+cTransf+'") '       

	IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
	dbSelectArea(cAliasSF3)
    ProcRegua(LastRec())   
    dbGoTop()
#IFDEF TOP
	Endif    
#ENDIF

While !(cAliasSF3)->(Eof())
	nTotRecBru += (cAliasSF3)->F3_VALCONT
    (cAliasSF3)->(dbSkip())
EndDo

//��������������������������������������������������������������Ŀ
//� Exclui as areas de trabalho                                  �
//����������������������������������������������������������������
#IFDEF TOP 
    dbSelectArea(cAliasSF3)
	dbCloseArea()
#ELSE
  	dbSelectArea(cAliasSF3)
	RetIndex(cAliasSF3)
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())
#ENDIF 	 
	                      
RestArea(aAreaAnt)
	         
Return nTotRecBru	
                                                                                        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CalcImpost�Autor  �Luciana Pires       � Data �  05.09.06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula o ICMS devido de acordo com o regime tributario     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATA918                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CalcImpost(nRecBrutA, nRecBrutM, nTaxa)                                                      

Local cICMSDev		:= ""
Local cRegTrib		:= ""
Local cCNAE			:= GetNewPar("MV_CNAERJ","")
Local nICMS			:= 0               
Local nPercent		:= GetNewPar("MV_PERCRJ",0)
Local aMVFXRJ01 	:= &(GetNewPar("MV_FXRJ01","{0,88531,44.26}"))  // {Faixa De, Faixa At�, Valor do Imposto}
Local aMVFXRJ02 	:= &(GetNewPar("MV_FXRJ02","{88532,177062,114.63}"))
Local aMVFXRJ03 	:= &(GetNewPar("MV_FXRJ03","{177063,309858,327.53}"))  
Local aMVFXRJ04 	:= &(GetNewPar("MV_FXRJ04","{309859,442655,818.83}"))  
Local aMVFXRJ05 	:= &(GetNewPar("MV_FXRJ05","{442656,663982,1228.25}"))  
Local aMVFXRJ06 	:= &(GetNewPar("MV_FXRJ06","{663983,885310,1637.67}"))  
Local aMVFXRJ07 	:= &(GetNewPar("MV_FXRJ07","{885311,1040240,2047.08}"))  
Local aMVFXRJ08 	:= &(GetNewPar("MV_FXRJ08","{1040241,1228250,2456.50}"))  
Local aICMSDev		:= {}                                        

//���������������������������������������������Ŀ
//�Calculo do ICMS de acordo com a receita bruta�
//�����������������������������������������������
If nRecBrutA <> 0
	Do Case
	 	// Microempresa
		Case (nRecBrutA <= (aMVFXRJ01[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ01[3] * nTaxa
			cICMSDev	:= STR0016 //"Faixa 01 - Microempresa"
			cRegTrib	:= STR0014 //"ME - Microempresa
		Case (nRecBrutA <= (aMVFXRJ02[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ02[3] * nTaxa	
			cICMSDev	:= STR0017 //"Faixa 02 - Microempresa"
			cRegTrib	:= STR0014 //"ME - Microempresa
		Case (nRecBrutA <= (aMVFXRJ03[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ03[3] * nTaxa
			cICMSDev	:= STR0018 //"Faixa 03 - Microempresa"
			cRegTrib	:= STR0014 //"ME - Microempresa
		// Empresa de Pequeno Porte
		Case (nRecBrutA <= (aMVFXRJ04[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ04[3] * nTaxa
			cICMSDev	:= STR0019 //"Faixa 04 - Empresa de Pequeno Porte"
			cRegTrib	:= STR0015 //"EPP - Empresa de Pequeno Porte"	
		Case (nRecBrutA <= (aMVFXRJ05[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ05[3] * nTaxa
			cICMSDev	:= STR0020 //"Faixa 05 - Empresa de Pequeno Porte"
			cRegTrib	:= STR0015 //"EPP - Empresa de Pequeno Porte"	
		Case (nRecBrutA <= (aMVFXRJ06[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ06[3] * nTaxa	
			cICMSDev	:= STR0021 //"Faixa 06 - Empresa de Pequeno Porte"
			cRegTrib	:= STR0015 //"EPP - Empresa de Pequeno Porte"	
		Case (nRecBrutA <= (aMVFXRJ07[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ07[3] * nTaxa
			cICMSDev	:= STR0022 //"Faixa 07 - Empresa de Pequeno Porte"		
			cRegTrib	:= STR0015 //"EPP - Empresa de Pequeno Porte"	
		Case (nRecBrutA <= (aMVFXRJ08[2] * nTaxa)) 
			nICMS 		:= aMVFXRJ08[3] * nTaxa
			cICMSDev	:= STR0023 //"Faixa 08 - Empresa de Pequeno Porte"
			cRegTrib	:= STR0015 //"EPP - Empresa de Pequeno Porte"	
			 	// Ramo de Servi�os de Alimenta��o - CNAE 8.01.01 (4% do Valor Bruto Mensal)
	 	Case (nRecBrutA > (aMVFXRJ08[2] * nTaxa))
			If Alltrim(cCNAE) == Alltrim(SM0->M0_CNAE)
				nICMS 		:= (nRecBrutM * nPercent) / 100
				cICMSDev	:= STR0024 //"Regime Especial para Empresa do Ramo de 'Servi�os de Alimenta��o' "
				cRegTrib	:= STR0025 //"Regime Simplificado Especial"
			Else
				cICMSDev	:= STR0026 //"Empresa sujeita �s Normas Gerais de Tributa��o"
				cRegTrib 	:= STR0027 //"Regime Normal de ICMS"		
			Endif           
	EndCase			
Else
	cICMSDev	:= STR0028 //"Isento do ICMS" 
	cRegTrib 	:= STR0028 //"Isento do ICMS" 
Endif	   

AADD(aICMSDev,{nICMS,cICMSDev,cRegTrib})
					
Return (aICMSDev)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Tela      �Autor  �Luciana Pires       � Data �  05.09.06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Apresenta as informacoes na tela                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATA918                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Tela (nRecBrutA, nRecBrutM, nICMSDev, dDataIni, dDataFim, cICMSDev, cRegTrib)
Local aICMSDev := {} 
Local oDlg    
Local oGet
Local nOpca
Local lMsgYesNo 
Local ofont                        
Local ofont2

DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0, -11

DEFINE MSDIALOG oDlg TITLE STR0001 OF oMainWnd PIXEL FROM 0,0 TO 430,500 //"Simples Rio de Janeiro" 
@03, 05 To 27, 246 OF oDlg PIXEL
@07, 10 SAY OemToAnsi (STR0029) FONT oFont  SIZE 180, 8 OF oDlg PIXEL //"Raz�o Social:"
@17, 10 SAY OemToAnsi (Upper (AllTrim (SM0->M0_NOMECOM))) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@30, 05 To 54, 246 OF oDlg PIXEL
@34, 10 SAY OemToAnsi (STR0030) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Regime de Tributa��o:"
@44, 10 SAY OemToAnsi (cRegTrib) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL
@57, 05 To 81, 246 OF oDlg PIXEL
@61, 10 SAY OemToAnsi (STR0031) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Receita Bruta Anual (Ano Anterior):"
@71, 10 SAY OemToAnsi ((STR0032) + Transform(nRecBrutA,"@E 999,999,999.99")) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL //"R$"
@84, 05 To 108, 246 OF oDlg PIXEL
@88, 10 SAY OemToAnsi (STR0048) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Receita Bruta Mensal:"
@98, 10 SAY OemToAnsi ((STR0032) + Transform(nRecBrutM,"@E 999,999,999.99")) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL //"R$"
@111, 05 To 135, 246 OF oDlg PIXEL
@115, 10 SAY OemToAnsi (STR0033) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Per�odo:"
@125, 10 SAY OemToAnsi (Dtoc(dDataIni) + (STR0034) + Dtoc(dDataFim)) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL //" � "
@138, 05 To 162, 246 OF oDlg PIXEL
@142, 10 SAY OemToAnsi (STR0035) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"ICMS Devido:"
@152, 10 SAY OemToAnsi ((STR0032) + Transform(nICMSDev,"@E 999,999,999.99")) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL //"R$"
@165, 05 To 189, 246 OF oDlg PIXEL
@169, 10 SAY OemToAnsi (STR0036) FONT oFont SIZE 180, 8 OF oDlg PIXEL //"Observa��o:"
@179, 10 SAY OemToAnsi (cICMSDev) FONT oFont2 SIZE 180, 8 OF oDlg PIXEL

                                                  
DEFINE SBUTTON FROM 199, 160 TYPE 1 ACTION (oDlg:End(), nOpca:=2) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 199, 190 TYPE 5 ACTION (Pergunte ("MTA918", .T.), Atualiza(@nRecBrutA, @nRecBrutM, @nICMSDev, @dDataIni, @dDataFim, @cICMSDev, @cRegTrib), nOpca:=3) ENABLE OF oDlg PIXEL2
DEFINE SBUTTON FROM 199, 220 TYPE 6 ACTION (ImpTela (nRecBrutA, nRecBrutM, nICMSDev, dDataIni, dDataFim, cICMSDev, cRegTrib), nOpca:=4) ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg CENTERED

Return .T. 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Atualiza  �Autor  �Luciana Pires       � Data �  05.09.06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza os valores da receita e do ICMS devido e o regime  ���
���          �tributario da empresa de acordo com o periodo selecionado   ���
�������������������������������������������������������������������������͹��
���Uso       �MATA918                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function Atualiza(nRecBrutA, nRecBrutM, cICMSDev, dDtRecIni, dDtRecFim, nICMSDev,cRegTrib)
aReceita	:= ""
//�������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                    �
//� mv_par01        // Data Inicial                                         �
//� mv_par02        // Data Final                                           �
//� mv_par03		// Taxa UFIR                                            �
//���������������������������������������������������������������������������
dDataIni	:= mv_par01
dDataFim	:= mv_par02
nTaxa		:= mv_par03                   

dDtRecIni	:= Ctod("01/01/"+ Str(Year(mv_par01)-1,4))
dDtRecFim	:= Ctod("31/12/"+ Str(Year(mv_par01)-1,4))

//�����������
//�Recalculo�
//�����������

nRecBrutA 	:= CalcRBruta(dDtRecIni, dDtRecFim)     

//��������������������������������������������������Ŀ
//�Receita Bruta Acumulada informada manualmente     �
//����������������������������������������������������
If !Empty(GetNewPar("MV_RBACRJ",""))
	aReceita := &(GetNewPar("MV_RBACRJ",{0,0})) 
	If aReceita[1] == Year(dDtRecFim)		
		nRecBrutA := aReceita[2]
	Endif
Endif

nRecBrutM	:= CalcRBruta(dDataIni, dDataFim)       
aICMSDev	:= CalcImpost(nRecBrutA, nRecBrutM, nTaxa)
cICMSDev	:= (aICMSDev[1][1])                                      
nICMSDev	:= (aICMSDev[1][2])
cRegTrib	:= (aICMSDev[1][3])

Return .T.                                           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �ImpTela   �Autor  �Luciana Pires       � Data �  05.09.06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama impressao das informacoes da tela                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATA918                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpTela(nRecBrutA, nRecBrutM, nICMSDev, dDataIni, dDataFim, cICMSDev, cRegTrib)

Local aArea		:= GetArea()
Local Titulo	:= STR0002				// Impressao das informacoes do Simples Rio de Janeiro"
Local lDic     	:= .F. 					// Habilita/Desabilita Dicionario      
Local lComp    	:= .T. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro  	:= .T. 					// Habilita/Desabilita o Filtro
Local wnrel    	:= "MATA918"  			// Nome do Arquivo utilizado no Spool
Local nomeprog 	:= "MATA918"  			// nome do programa
Local cString	:= "SF3"

Private Tamanho := "P"					// P/M/G
Private Limite  := 80  					// 80/132/220
Private aOrdem  := {}  					// Ordem do Relatorio
Private aReturn := {"Zebrado",1,"Adminis",1,2,1,"",1}	

Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1  					// Contador de Paginas
Private nLastKey:= 0  					// Controla o cancelamento da SetPrint e SetDefault

//������������������������������������������������������������������������Ŀ
//�Envia para a SetPrint                                                   �
//��������������������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,"",@titulo,"","","",lDic,aOrdem,lComp,,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

//�������������������Ŀ
//�Imprime o relatorio�
//���������������������
RptStatus({|lEnd| ImpDet(nRecBrutA, nRecBrutM, nICMSDev, dDataIni, dDataFim, cICMSDev, cRegTrib)},Titulo)

dbSelectArea(cString)
dbClearFilter()
Set Device To Screen
Set Printer To

If (aReturn[5] = 1)
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return .T. 

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ImpDet     �Autor  �Luciana Pires       � Data �  05.09.06   ���
��������������������������������������������������������������������������͹��
���Desc.     �Impressao do relatorio                                       ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �MATA918                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function ImpDet(nRecBrutA, nRecBrutM, nICMSDev, dDataIni, dDataFim, cICMSDev, cRegTrib)

Local nLinha	:= 0
Local aLay		:= RetLayOut()

nLinha 	:= SIMPCabec()

@ nLinha,000 PSAY AvalImp(Limite)                

FmtLin({},aLay[01],,,@nLinha)                              
FmtLin({PadC(AllTrim(SM0->M0_NOMECOM),80)},aLay[02],,,@nLinha)                              
FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),SM0->M0_INSC},aLay[03],,,@nLinha)                              
FmtLin({},aLay[04],,,@nLinha)                              
FmtLin({},aLay[05],,,@nLinha)
FmtLin({},aLay[06],,,@nLinha)
FmtLin({AllTrim(cRegTrib)},aLay[07],,,@nLinha)
FmtLin({},aLay[08],,,@nLinha)                              
FmtLin({},aLay[09],,,@nLinha)                              
FmtLin({},aLay[10],,,@nLinha)                              
FmtLin({(STR0032) + TransForm(nRecBruta,"@E 999,999,999.99")},aLay[11],,,@nLinha) //"R$"
FmtLin({},aLay[12],,,@nLinha)                              
FmtLin({},aLay[13],,,@nLinha)                              
FmtLin({},aLay[14],,,@nLinha)                              
FmtLin({(STR0032) + TransForm(nRecBrutM,"@E 999,999,999.99")},aLay[15],,,@nLinha) //"R$"
FmtLin({},aLay[16],,,@nLinha)
FmtLin({},aLay[17],,,@nLinha)
FmtLin({},aLay[18],,,@nLinha)
FmtLin({dtoc(dDataIni) + " � " + dtoc(dDataFim)},aLay[19],,,@nLinha)
FmtLin({},aLay[20],,,@nLinha)
FmtLin({},aLay[21],,,@nLinha)
FmtLin({},aLay[22],,,@nLinha)
FmtLin({(STR0032) + TransForm(nICMSDev,"@E 999,999,999.99")},aLay[23],,,@nLinha) //"R$"
FmtLin({},aLay[24],,,@nLinha)                
FmtLin({},aLay[25],,,@nLinha)
FmtLin({},aLay[26],,,@nLinha)
FmtLin({AllTrim(cICMSDev)},aLay[27],,,@nLinha)
FmtLin({},aLay[28],,,@nLinha)

Return nLinha
                                                                                               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �RetLayOut | Autor � Luciana Pires         � Data � 05.09.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o LayOut a ser impresso                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function RetLayOut()

Local aLay := Array(28)      
                                     
aLay[01] :=            "                                                                               "  
aLay[02] :=            "###############################################################################"  
aLay[03] := STR0003 // "  C.N.P.J.:   ##################               I.E.:     ##################### "
aLay[04] :=            "                                                                               "
aLay[05] :=            "+-----------------------------------------------------------------------------+"
aLay[06] := STR0004 // "| Regime de Tributacao:                                                       |"
aLay[07] := STR0005 // "| ###################################                                         |"
aLay[08] :=            "+-----------------------------------------------------------------------------+"
aLay[09] :=            "+-----------------------------------------------------------------------------+"
aLay[10] := STR0006 // "| Receita Bruta Anual (Ano Anterior):                                         |"
aLay[11] := STR0007 // "| #################                                                           |"
aLay[12] :=            "+-----------------------------------------------------------------------------+"
aLay[13] :=            "+-----------------------------------------------------------------------------+"
aLay[14] := STR0046 //  "| Receita Bruta Mensal                                                        |"
aLay[15] := STR0047 // "| #################                                                           |"	
aLay[16] :=            "+-----------------------------------------------------------------------------+"
aLay[17] :=            "+-----------------------------------------------------------------------------+"
aLay[18] := STR0008 // "| Periodo:                                                                    |"
aLay[19] := STR0009 // "| ###################                                                         |"
aLay[20] :=            "+-----------------------------------------------------------------------------+"
aLay[21] :=            "+-----------------------------------------------------------------------------+"
aLay[22] := STR0010 // "| ICMS Devido:                                                                |"
aLay[23] := STR0011 // "| #################                                                           |"
aLay[24] :=            "+-----------------------------------------------------------------------------+"
aLay[25] :=            "+-----------------------------------------------------------------------------+"
aLay[26] := STR0012 // "| Observa��o:                                                                 |"
aLay[27] := STR0013 // "| ########################################################################### |"   
aLay[28] :=            "+-----------------------------------------------------------------------------+"

Return aLay
                           
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � SIMPCabec      � Autor � Luciana Pires     �Data� 05.09.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  

Static Function SIMPCabec

Local Titulo	:= STR0001 // Simples Rio de Janeiro
Local nomeprog	:= "MATA918"
Local Tamanho	:= 'P'
Local nTipo		:= 18
Local cabec1	:= ""
Local cabec2	:= ""
Local nLin 		
                
nLin := cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)

nLin++

Return nLin
