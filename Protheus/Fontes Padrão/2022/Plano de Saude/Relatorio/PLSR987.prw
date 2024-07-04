#INCLUDE "PLSR987.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "topconn.CH"

Static objCENFUNLGP := CENFUNLGP():New()

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    ?PLSR987 ?Autor ?Marcos Alves           ?Data ?03/05/04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao ?Relatorio de reembolso                                     ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   ?PLSR987()                                                  ����
�������������������������������������������������������������������������Ĵ���
��?Uso      ?Advanced Protheus                                          ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSR987()

//��������������������������������������������������������������������������Ŀ
//?Define variaveis padroes para todos os relatorios...                     ?
//����������������������������������������������������������������������������
Local cDesc1            := FunDesc() //"Rela��o de Reembolso""
Local cDesc2            := STR0002 //" Concedidos"
Local cDesc3            := ""
Local cAlias            := "B44"
Local aOrdens           := {STR0003,STR0004,STR0019} //"Matricula","Reembolso"
//��������������������������������������������������������������������������Ŀ
//?Variaveis da funcao SETPRINTER											 ?
//����������������������������������������������������������������������������
Private wnrel
Private cTitulo     	:= FunDesc() //"Rela��o de Reembolso"
Private cCabec1     	:= STR0005 //"Num.Reemb. Matricula             Nome Usuario                                        Codigo Nome Rede Nao Credenciada                Dt Util  Dt Digit Vlr Pago       Vlr Reembolso"
Private cCabec2     	:= STR0006 //"           Procedimento     Descricao                                                                                                                                 Vlr Reembolso"
Private cNomeProg   	:= "PLSR987"
Private cPerg       	:= PADR("PLR987", Len(SX1->X1_GRUPO))
Private Li              := 99
Private m_pag       	:= 1
Private aReturn     	:= { STR0007, 1,STR0008, 1, 1, 1, "",1 } //"Zebrado"#"Administracao"
Private cTamanho	    := "G"
Private lDicion     	:= .F.
Private lCompres    	:= .F.
Private lCrystal    	:= .F.
Private lFiltro     	:= .T.
Private lAbortPrint 	:= .F.                                                                       
//��������������������������������������������������������������������������Ŀ
//?Chama SetPrint                                                           ?
//����������������������������������������������������������������������������
wnrel := "PLSR987"
wnRel := SetPrint(cAlias, wnRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,,cTamanho,,lFiltro, lCrystal)

	aAlias := {"B44","BA1","BKD","B45"}
	objCENFUNLGP:setAlias(aAlias)

//��������������������������������������������������������������������������Ŀ
//?Verifica se foi cancelada a operacao                                     ?
//����������������������������������������������������������������������������
If  nLastKey  == 27
    Return
Endif
//��������������������������������������������������������������������������Ŀ
//?Configura impressora                                                     ?
//����������������������������������������������������������������������������
SetDefault(aReturn,cAlias)
//��������������������������������������������������������������������������Ŀ
//?Emite relat�rio                                                          ?
//����������������������������������������������������������������������������
msAguarde( {|| PLSR987IMP() }, cTitulo ,"", .T.)
//��������������������������������������������������������������������������Ŀ
//?Fim da Rotina Principal...                                               ?
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   �PLSR987IMP?Autor ?Marcos Alves          ?Data ?03/05/04 ��?
��������������������������������������������������������������������������Ĵ��
���Descricao  ?Imprime detalhe do relatorio...                            ��?
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function PLSR987IMP()
//��������������������������������������������������������������������������Ŀ
//?Inicializa variaveis                                                     ?
//����������������������������������������������������������������������������
Local nQtdLin  	:= 58
Local nColuna  	:= 00
Local nLimite  	:= 220
Local cLinha    := ""
Local cSQL		:= ""
Local nOrdSel  	:= aReturn[8] 
Local lAutomacao := IsInCallstack("PLR987_001")

//��������������������������������������������������������������������������Ŀ
//?Variaveis para o pergunte                                                ?
//����������������������������������������������������������������������������
Local cOper   	:= Space(4)
Local cEmpIni  	:= Space(4)
Local cEmpFim  	:= Space(4)
Local cContIni 	:= Space(12)
Local cContFim 	:= Space(12)
Local cSubContI	:= Space(9)
Local cSubContF	:= Space(9)
Local cMesIni  	:= Space(2)
Local cMesFim  	:= Space(2)
Local cAnoIni  	:= Space(4)
Local cAnoFim	:= Space(4)
Local lProc    	:= .F.
Local lImMatAn    := .F.
//��������������������������������������������������������������������������Ŀ
//?Variaveis do grupo de cabecalho                                          ?
//����������������������������������������������������������������������������
Local aVar		   := {} 
Local lFirst		:= .T.
Local cMvCOMP      := GetMv("MV_COMP")
Local cMvNORM      := GetMv("MV_NORM")
//��������������������������������������������������������������������������Ŀ
//?Acessa parametros do relatorio...                                        ?
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)
cOper    := mv_par01
cEmpIni  := mv_par02
cEmpFim  := mv_par03
cContIni := mv_par04
cContFim := mv_par05
cSubContI:= mv_par06
cSubContF:= mv_par07
cMesIni  := mv_par08
cMesFim  := mv_par09
cAnoIni  := mv_par10
cAnoFim  := mv_par11   
lProc    := (mv_par12==1)
lImMatAn := (mv_par13!=1)   

If Empty(cOper)
	MsgAlert(STR0025, STR0024)//"O par�metro Operadora ?obrigat�rio." "Par�metro Obrigat�rio"
	Return
EndIf

If Empty(cMesIni) .Or. Empty(cMesFim)
	MsgAlert(STR0026, STR0024) //"Os par�metros M�s Inicial e Final s�o obrigat�rios." "Par�metro Obrigat�rio"
	Return
EndIf

If Empty(cAnoIni) .Or. Empty(cAnoFim)
	MsgAlert(STR0027, STR0024)//"Os par�metros Ano Inicial e Final s�o obrigat�rios." "Par�metro Obrigat�rio"
	Return
EndIf

//��������������������������������������������������������������������������Ŀ
//?Inicializacao do array do cabecalho de grupo/empresas                    ?
//����������������������������������������������������������������������������
aadd(aVar,Space(TamSx3("B44_FILIAL")[1]))								//[1]Filial
aadd(aVar,Space(TamSx3("B44_OPEMOV")[1]+TamSx3("B44_CODEMP")[1]))		//[2]Grupo/empresa
aadd(aVar,Space(TamSx3("BA1_CONEMP")[1]))								//[3]Contrato
aadd(aVar,Space(TamSx3("BA1_VERCON")[1]))								//[4]Versao do contrato
aadd(aVar,Space(TamSx3("BA1_SUBCON")[1]))								//[5]SubContrato
aadd(aVar,Space(TamSx3("BA1_VERSUB")[1]))                              //[6]Versao do subcontrato
aadd(aVar,Space(TamSx3("BKD_NOMEMP")[1]))								//[7]Nome Empresa
aadd(aVar,Space(TamSx3("B44_MESPAG")[1]))								//[8]Mes Base do Pagamento
aadd(aVar,Space(TamSx3("B44_ANOPAG")[1]))								//[9]Ano Base do Pagamento
aadd(aVar,0)															//[10]Totalizador de Mes/Ano
aadd(aVar,0)															//[11]Totalizador de SubContrato
aadd(aVar,0)															//[12]Totalizador de Contrato
aadd(aVar,0)															//[13]Totalizador de Grupo empresa
aadd(aVar,0)															//[14]Totalizador Geral

//��������������������������������������������������������������������������Ŀ
//?Mensagem de processamento                                                ?
//����������������������������������������������������������������������������
If !lAutomacao
	msProcTxt(STR0009) //"Selecionando registros ..."
EndIf

//��������������������������������������������������������������������������Ŀ
//?Seleciona registros                                                      ?
//����������������������������������������������������������������������������
cSQL += " SELECT "
cSQL += " 	  B44.B44_NUMAUT,  "
cSQL += "     B44.B44_OPEMOV,  "
cSQL += "     B44.B44_CODEMP,  "
cSQL += "     B44.B44_MATRIC,  "
cSQL += "     B44.B44_TIPREG,  "
cSQL += "     B44.B44_CODREF,  "
cSQL += "     B44.B44_NOMREF,  "
cSQL += "     B44.B44_DATPRO,  "
cSQL += "     B44.B44_DTDIGI,  "
cSQL += "     B44.B44_MESPAG,  "
cSQL += "     B44.B44_ANOPAG,  "
cSQL += "     B44.B44_VLRMAN,  "
cSQL += "     B44.B44_VLRPAG,  "
cSQL += "     B44.B44_ANOAUT,  " 
cSQL += "     B44.B44_MESAUT,  "
cSQL += "     BA1.BA1_CONEMP,  "
cSQL += "     BA1.BA1_VERCON,  "
cSQL += "     BA1.BA1_SUBCON,  "
cSQL += "     BA1.BA1_VERSUB,  "
cSQL += "     BA1.BA1_MATANT,  "
cSQL += "     BA1.BA1_DIGITO,  " 
cSQL += "     BA1.BA1_NOMUSR   "
cSQL += " FROM "+RetSQLName("B44")+" B44 "
cSQL += " 	JOIN "+RetSQLName("BA1")+" BA1 "
cSQL += " 		ON B44.B44_FILIAL = BA1.BA1_FILIAL "
cSQL += " 		AND B44.B44_OPEUSR = BA1.BA1_CODINT "
cSQL += " 		AND B44.B44_CODEMP = BA1.BA1_CODEMP "
cSQL += "       AND B44.B44_MATRIC = BA1.BA1_MATRIC "
cSQL += "       AND B44.B44_TIPREG = BA1.BA1_TIPREG "
cSQL += "       AND B44.D_E_L_E_T_ <> '*'  "
cSQL += "       AND BA1.D_E_L_E_T_ <> '*'  "
cSQL += " WHERE "
cSQL += " 		BA1.BA1_CODINT = '"+cOper+"' "
If !Empty(cEmpIni) .And. !Empty(cEmpFim)
	cSQL += " 	AND	BA1.BA1_CODEMP BETWEEN '"+cEmpIni+"' AND '"+cEmpFim+"' "
EndIf
If !Empty(cContIni) .And. !Empty(cContFim)
	cSQL += " 	AND	BA1.BA1_CONEMP BETWEEN '"+cContIni+"' AND '"+cContFim+"' "
EndIf
If !Empty(cSubContI) .And. !Empty(cSubContF)
	cSQL += " 	AND	BA1.BA1_SUBCON BETWEEN '"+cSubContI+"' AND '"+cSubContF+"' "
EndIf
cSQL += " 	AND B44.B44_MESPAG BETWEEN '"+cMesIni+"' AND '"+cMesFim+"'  "
cSQL += " 	AND B44.B44_ANOPAG BETWEEN '"+cAnoIni+"' AND '"+cAnoFim+"' "

//��������������������������������������������������������������������������Ŀ
//?Acrescenta filtro informado pelo usuario na funcao setprint              ?
//����������������������������������������������������������������������������
If  ! Empty(aReturn[7])
    cSQL += " AND (" + alltrim(aReturn[7])+" ) "
Endif   
//��������������������������������������������������������������������������Ŀ
//?Acrescenta a ordem selecionada                                           ?
//����������������������������������������������������������������������������
Do Case
   Case nOrdSel == 1
		cSQL += " ORDER BY B44.B44_CODEMP , BA1.BA1_CONEMP , BA1.BA1_VERCON , BA1.BA1_SUBCON , BA1.BA1_VERSUB , B44.B44_MESPAG , B44.B44_ANOPAG "//1-B44.B44_CODINT, U-B44.B44_CODRBS
   Case nOrdSel == 2
		cSQL += " ORDER BY B44.B44_CODEMP , BA1.BA1_CONEMP , BA1.BA1_VERCON , BA1.BA1_SUBCON , BA1.BA1_VERSUB , B44.B44_MESPAG , B44.B44_ANOPAG , B44.B44_MATRIC , B44.B44_TIPREG" //1-B44.B44_CODINT +
	Case nOrdSel == 3
		cSQL += " ORDER BY B44.B44_MESPAG , B44.B44_ANOPAG , BA1.BA1_MATANT , B44.B44_MATRIC , B44.B44_TIPREG"
EndCase

cSQL :=  ChangeQuery(cSQL)

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")

If QRY->(Eof())
	MsgStop(STR0029, STR0028) //"Nenhum registro encontrado para os par�metros informados." "Registro(s) n�o encontrados"
	QRY->(dbCloseArea())
	Return
EndIf

If !lProc
   cCabec2:=''
EndIf

While !QRY->(Eof())
	//������������������������������������������������������������������������?
	//?Verifica se foi cancelada a impressao                                 ?
	//������������������������������������������������������������������������?
	If  Interrupcao(lAbortPrint)
		Li ++
		@ Li, nColuna pSay PLSTR0002
		Exit
	Endif                              
	nTotal := 0
	//������������������������������������������������������������������������?
	//?Mensagem de processamento                                             ?
	//������������������������������������������������������������������������?
	If !lAutomacao
		MsProcTXT(STR0010+objCENFUNLGP:verCamNPR("B44_NUMAUT",QRY->B44_NUMAUT)+"...") //"Imprimindo Reembolso :"
	EndIf
	If nOrdSel <> 3
		If !PLR987Val(@aVar,1) .Or. Li > nQtdLin
			Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
			@ Li++,nColuna pSay STR0011+;
								objCENFUNLGP:verCamNPR("B44_OPEMOV",objCENFUNLGP:verCamNPR("B44_CODEMP",aVar[2]))+" - "+;
								objCENFUNLGP:verCamNPR("BKD_NOMEMP",aVar[7])  //"Grupo/Empresa       : "
			@ Li++,nColuna pSay STR0012+;
								objCENFUNLGP:verCamNPR("BA1_CONEMP",aVar[3])+"/"+;
								objCENFUNLGP:verCamNPR("BA1_VERCON",aVar[4])    //"Contrato/Versao     : "
			@ Li++,nColuna pSay STR0013+;
								objCENFUNLGP:verCamNPR("BA1_SUBCON",aVar[5])+"/"+;
								objCENFUNLGP:verCamNPR("BA1_VERSUB",aVar[6])    //"Subcontrato/Versao  : "
		EndIf		
		If !PLR987Val(@aVar,2)
			@ Li++,nColuna pSay ""
			@ Li++,nColuna pSay STR0014+;
								objCENFUNLGP:verCamNPR("B44_MESPAG",aVar[8])+"/"+;
								objCENFUNLGP:verCamNPR("B44_ANOPAG",aVar[9])  //"Mes/Ano Pagamento   : "
			@ Li++,nColuna pSay ""
		EndIf
	Else
		If  lFirst .or. Li > nQtdLin
			Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
			lFirst := .F.
		Endif
				
		If !PLR987Val(@aVar,3)
			@ Li++,nColuna pSay ""
			@ Li++,nColuna pSay STR0014+;
								objCENFUNLGP:verCamNPR("B44_MESPAG",aVar[8])+"/"+;
								objCENFUNLGP:verCamNPR("B44_ANOPAG",aVar[9])  //"Mes/Ano Pagamento   : "
			@ Li++,nColuna pSay ""
		EndIf
	Endif
	cLinha:=objCENFUNLGP:verCamNPR("B44_NUMAUT",QRY->B44_NUMAUT)+Space(5)
	If !lImMatAn
		cLinha+=objCENFUNLGP:verCamNPR("B44_OPEMOV",QRY->B44_OPEMOV)+"."
		cLinha+=objCENFUNLGP:verCamNPR("B44_CODEMP",QRY->B44_CODEMP)+"."
		cLinha+=objCENFUNLGP:verCamNPR("B44_MATRIC",QRY->B44_MATRIC)+"."
		cLinha+=objCENFUNLGP:verCamNPR("B44_TIPREG",QRY->B44_TIPREG)+"-"
		cLinha+=objCENFUNLGP:verCamNPR("BA1_DIGITO",QRY->BA1_DIGITO)+" "
	Else
		cLinha+=objCENFUNLGP:verCamNPR("BA1_MATANT",QRY->BA1_MATANT)+" "
	Endif
	cLinha+=objCENFUNLGP:verCamNPR("BA1_NOMUSR",QRY->BA1_NOMUSR)+" "
	cLinha+=objCENFUNLGP:verCamNPR("B44_CODREF",QRY->B44_CODREF)+" "
	cLinha+=objCENFUNLGP:verCamNPR("B44_NOMREF",QRY->B44_NOMREF)+"    "

	cLinha+=objCENFUNLGP:verCamNPR("B44_DATPRO",DToC(StoD(QRY->B44_DATPRO)))+"  "  // data utiliza��o
	cLinha+=objCENFUNLGP:verCamNPR("B44_DTDIGI",DToC(StoD(QRY->B44_DTDIGI)))+"  "// data digita��o
	cLinha+=objCENFUNLGP:verCamNPR("B44_VLRMAN",Transform(QRY->B44_VLRMAN,"@E 999,999,999.99"))+" "//valor pagamento do Beneficiario

	@ Li++,nColuna pSay cLinha
	//��������������������������������������������������������������������?
	//?Impressao dos procedimentos                                       ?
	//��������������������������������������������������������������������?
	If lProc
		dbSelectArea("B45")
		B45->(DbSetorder(1))
		B45->(MsSeek(xFilial("B45")+QRY->(B44_OPEMOV+B44_ANOAUT+B44_MESAUT+B44_NUMAUT)))
		While !B45->(Eof()) .And. B45->B45_NUMAUT == QRY->B44_NUMAUT .AND. B45->B45_OPEMOV == QRY->B44_OPEMOV;
			.AND. B45->B45_ANOAUT == QRY->B44_ANOAUT .AND. B45->B45_MESAUT == QRY->B44_MESAUT
			
			//��������������������������������������������������������������������?
			//?Trata quantidade de linhas...                                     ?
			//��������������������������������������������������������������������?
			If  Li+5 > nQtdLin
				Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
			Endif

			cLinha:= objCENFUNLGP:verCamNPR("B45_CODPAD",;
					objCENFUNLGP:verCamNPR("B45_CODPRO",;
					padr(PLSPICPRO(B45->B45_CODPAD,B45->B45_CODPRO),len(B45->B45_CODPRO))))+" "
			cLinha+=objCENFUNLGP:verCamNPR("BR8_DESCRI",Subs(Posicione("BR8",1,xFilial("BR8")+B45->B45_CODPAD+B45->B45_CODPRO,"BR8_DESCRI"),1,136))+" "
			cLinha+=Transform(B45->B45_VLRBPR,"@E 999,999,999.99")
			nTotal += objCENFUNLGP:verCamNPR("B45_VLRBPR",B45->B45_VLRBPR)
			@ Li++,nColuna+11 pSay cLinha
			
			B45->(dbSkip())
		EndDo
		If lProc
			If  Li+5 > nQtdLin
				Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
			Endif
			
			cLinha:= space(Len(B45->B45_CODPRO))+" "
			cLinha+=space(Len(Subs(Posicione("BR8",1,xFilial("BR8")+B45->B45_CODPAD+B45->B45_CODPRO,"BR8_DESCRI"),1,110)))+STR0023+space(21)
			cLinha+=Transform(nTotal,"@E 999,999,999.99")
			@ Li++,nColuna+11 pSay cLinha
		Endif	
	EndIf
	
	//��������������������������������������������������������������������?
	//?Acumula valores                                                   ?
	//��������������������������������������������������������������������?
	aVar[10]+=QRY->B44_VLRPAG 	//[10]Totalizador de Mes/Ano
	aVar[11]+=QRY->B44_VLRPAG 	//[11]Totalizador de SubContrato
	aVar[12]+=QRY->B44_VLRPAG 	//[12]Totalizador de Contrato
	aVar[13]+=QRY->B44_VLRPAG 	//[13]Totalizador de Grupo empresa
	aVar[14]+=QRY->B44_VLRPAG 	//[14]Totalizador Geral
	
	//������������������������������������������������������������������������?
	//?Acessa proximo registro                                               ?
	//������������������������������������������������������������������������?
	QRY->(DBSkip())

	//��������������������������������������������������������������������?
	//?Trata quantidade de linhas...                                     ?
	//��������������������������������������������������������������������?
	If  Li+5 > nQtdLin
		Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
	Endif
	
	//��������������������������������������������������������������������������Ŀ
	//?Imprime Totalizador de Mes/Ano                                           ?
	//����������������������������������������������������������������������������
	If  aVar[8] <> QRY->B44_MESPAG .Or. aVar[9] <> QRY->B44_ANOPAG
		@ Li++,nColuna pSay STR0020+;
							objCENFUNLGP:verCamNPR("B44_MESPAG",aVar[8])+"/"+;
							objCENFUNLGP:verCamNPR("B44_ANOPAG",aVar[9])+space(121)+;
							objCENFUNLGP:verCamNPR("B44_VLRPAG",Transform(aVar[10],"@E 999,999,999.99")) //"           Total Ano/Mes "
		@ Li++,nColuna pSay replicate("-",nLimite)
		aVar[10]:=0		//[10]Totalizador de Mes/Ano
	EndIf
	
	//��������������������������������������������������������������������?
	//?Trata quantidade de linhas...                                     ?
	//��������������������������������������������������������������������?
	If  Li+5 > nQtdLin
		Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
	Endif
	
	//��������������������������������������������������������������������������Ŀ
	//?Imprime Totalizador de SubContrato                                       ?
	//����������������������������������������������������������������������������
	If aVar[5]<>QRY->BA1_SUBCON .and. (nOrdSel == 1 .or. nOrdSel == 2)
		li++
		@ Li++,nColuna pSay STR0015+;
							objCENFUNLGP:verCamNPR("BA1_SUBCON",aVar[5])+"/"+;
							objCENFUNLGP:verCamNPR("BA1_VERSUB",aVar[6])  +space(115)+;
							objCENFUNLGP:verCamNPR("B44_VLRPAG",Transform(aVar[11],"@E 999,999,999.99")) //"           Total Subcontrato/Versao "
		aVar[11]:=0		//[11]Totalizador de SubContrato
	EndIf
	
	//��������������������������������������������������������������������?
	//?Trata quantidade de linhas...                                     ?
	//��������������������������������������������������������������������?
	If  Li+5 > nQtdLin
		Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
	Endif
	
	//��������������������������������������������������������������������������Ŀ
	//?Imprime Totalizador de Contrato                                          ?
	//������������������������������������������������������������������������`����
	If aVar[3]<>QRY->BA1_CONEMP .and. (nOrdSel == 1 .or. nOrdSel == 2)
		li++
		@ Li++,nColuna pSay STR0016+;
							objCENFUNLGP:verCamNPR("BA1_CONEMP",aVar[3])+"/"+;
							objCENFUNLGP:verCamNPR("BA1_VERCON",aVar[4])+space(115)+;
							objCENFUNLGP:verCamNPR("B44_VLRPAG",Transform(aVar[12],"@E 999,999,999.99")) //"           Total Contrato/Versao 	"
		aVar[12]:=0    	//[12]Totalizador de Contrato
	EndIf
	
	//��������������������������������������������������������������������?
	//?Trata quantidade de linhas...                                     ?
	//��������������������������������������������������������������������?
	If  Li+5 > nQtdLin
		Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
	Endif

	If  Li+5 > nQtdLin
		Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
	Endif
	
	//��������������������������������������������������������������������������Ŀ
	//?Imprime Totalizador de Grupo empresa                                     ?
	//����������������������������������������������������������������������������
	If aVar[2] <> (QRY->B44_OPEMOV+QRY->B44_CODEMP) .and. (nOrdSel == 1 .or. nOrdSel == 2)
		li++
		@ Li++,nColuna pSay STR0017+;
							objCENFUNLGP:verCamNPR("B44_OPEMOV",objCENFUNLGP:verCamNPR("B44_CODEMP",aVar[2]))+" - "+;
							objCENFUNLGP:verCamNPR("BKD_NOMEMP",Subs(aVar[7],1,136))+space(42)+;
							objCENFUNLGP:verCamNPR("B44_VLRPAG",Transform(aVar[13],"@E 999,999,999.99"))  //"           Total Grupo/Empresa 	"
		aVar[13]:=0		//[13]Totalizador de Grupo empresa
		li++
		li++
	EndIf
Enddo

//��������������������������������������������������������������������?
//?Trata quantidade de linhas...                                     ?
//��������������������������������������������������������������������?
If  Li+5 > nQtdLin
   Cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
Endif

//��������������������������������������������������������������������������Ŀ
//?Imprime totalizadores Geral                                              ?
//����������������������������������������������������������������������������
li++
@ Li++,nColuna pSay STR0018+"  "+;
					objCENFUNLGP:verCamNPR("B44_VLRPAG",Transform(aVar[14],"@E 999,999,999.99")) //"           Total Geral			                                                                                                                                 "
aVar[14]:=0		//[13]Totalizador de Grupo empresa

//����������������������������������������������������������������������Ŀ
//?Imprime rodape do relatorio...                                       ?
//������������������������������������������������������������������������
Roda(0,space(10),cTamanho)

//��������������������������������������������������������������������������Ŀ
//?Fecha arquivo...                                                         ?
//����������������������������������������������������������������������������
QRY->(dbCloseArea())

//��������������������������������������������������������������������������Ŀ
//?Libera impressao                                                         ?
//����������������������������������������������������������������������������
If  aReturn[5] == 1 
    Set Printer To
    Ourspool(wnRel)
Endif

//��������������������������������������������������������������������������Ŀ
//?Fim do Relat�rio                                                         ?
//����������������������������������������������������������������������������
Return 

/*/
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������Ŀ�?
���Funcao    ?PLR987Val  ?Autor ?Marcos Alves        ?Data ?06.06.04 ��?
�������������������������������������������������������������������������Ĵ�?
���Descricao ?Validae quebra de totalizador                              ��?
�������������������������������������������������������������������������Ĵ�?
���Uso       ?Modulo do PLS                                              ��?
�������������������������������������������������������������������������Ĵ�?
���Parametros?aVar                                      				  ��?
��?         ?nTip - 1 - Valida Grupo/empresa ; 2 - Valida Mes/Ano       ��?
�������������������������������������������������������������������������Ĵ�?
���Observacao?Layout do aVar                            				  ��?
��?         ?-----------------------------------------------------------��?
��?         ?  [1]Filial                                                ��?
��?         ?  [2]Grupo/empresa                                         ��?
��?         ?  [3]Contrato                                              ��?
��?         ?  [4]Versao do contrato                                    ��?
��?         ?  [5]SubContrato                                           ��?
��?         ?  [6]Versao do subcontrato                                 ��?
��?         ?  [7]Nome Empresa                                          ��?
��?         ?  [8]Mes Base do Pagamento                                 ��?
��?         ?  [9]Ano Base do Pagamento                                 ��?
��?         ?  [10]Totalizador de Mes/Ano                               ��?
��?         ?  [11]Totalizador de SubContrato                           ��?
��?         ?  [12]Totalizador de Contrato                              ��?
��?         ?  [13]Totalizador de Grupo empresa                         ��?
��?         ?  [14]Totalizador Geral                                    ��?
��������������������������������������������������������������������������ٱ?
����������������������������������������������������������������������������?
 ����������������������������������������������������������������������������?
/*/
Static Function PLR987Val(aVar,nTip)
Local lRet := .F.

If nTip == 1
	
	If 	aVar[1] == xFilial("B44") .And.;
		aVar[2] == QRY->B44_OPEMOV+QRY->B44_CODEMP .And.;
		aVar[3] == QRY->BA1_CONEMP.AND.;
		aVar[4] == QRY->BA1_VERCON.AND.;
		aVar[5] == QRY->BA1_SUBCON.AND.;
		aVar[6] == QRY->BA1_VERSUB
		
		lRet := .T.
		
	Else
		aVar[1] := xFilial("B44")
		aVar[2] := QRY->B44_OPEMOV+QRY->B44_CODEMP
		aVar[3] := QRY->BA1_CONEMP
		aVar[4] := QRY->BA1_VERCON
		aVar[5] := QRY->BA1_SUBCON
		aVar[6] := QRY->BA1_VERSUB
		aVar[7] := Posicione("BG9",1,xFilial("BG9")+QRY->B44_OPEMOV+QRY->B44_CODEMP,"BG9_DESCRI")
	    //����������������������������������������������������������������������Ŀ
	    //?Inicializando o array do mes e ano para impressao do cabecalho sempre?
	    //?que imprimir o cabecalho do grupo/empresa                            ?
	    //������������������������������������������������������������������������
		aVar[8] := Space(TamSx3("B44_MESPAG")[1])
		aVar[9] := Space(TamSx3("B44_ANOPAG")[1])
		lRet 	:= .F.
	EndIf
	
ElseIf nTip == 2
	
	If aVar[8] == QRY->B44_MESPAG .And. aVar[9] == QRY->B44_ANOPAG
		lRet := .T.
	Else
		aVar[8] := QRY->B44_MESPAG
		aVar[9] := QRY->B44_ANOPAG
		lRet 	:= .F.
	EndIf
	
ElseIf nTip == 3
	
	If 	aVar[8] == QRY->B44_MESPAG .And. aVar[9] == QRY->B44_ANOPAG
		lRet := .T.
	Else
		aVar[8] := QRY->B44_MESPAG
		aVar[9] := QRY->B44_ANOPAG
		lRet 	:= .F.
	EndIf
	
EndIf

Return lRet

