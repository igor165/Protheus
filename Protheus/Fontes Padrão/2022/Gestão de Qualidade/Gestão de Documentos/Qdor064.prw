#INCLUDE "QDOR064.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR064  � Autor � Leandro S. Sabino     � Data � 14/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Aviso de Recolhimento de Documentos e Registros da Qualidad���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR064	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QDOR064(lBat,cDocto,cRv)
Local oReport
//�������������������������������������������������������������������������Ŀ
//� Variavel utilizada para verificar se o relatorio foi iniciado           �
//� pelo MNU ou pela rotina de documentos.                                  �
//����������������������������������������'�����������������������������������
lBat:= If(lBat == NIL,.F.,lBat)

Private cPerg   := If(lBat,"QDR061","QDR060")
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

If TRepInUse()
    Pergunte(cPerg,.F.) 
    oReport := ReportDef(lBat,cDocto,cRv)
    oReport:PrintDialog()
Else
	QDOR064R3(lBat,cDocto,cRv) 
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 14/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR064                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(lBat,cDocto,cRv)
Local oReport                                             
Local oSection1 ,oSection2,oSection3
Local cTitulo 	:= OemToAnsi(STR0001) //"AVISO DE RECOLHIMENTO DE DOCUMENTOS E REGISTROS DA QUALIDADE"
Local cDesc1    := OemToAnsi(STR0002) //"Este programa ir� imprimir o Aviso de Recolhimento de Documentos"
Local cDesc2 	:= OemToAnsi(STR0003) //"e Registros da Qualidade, que assegura o recolhimento de documentos"
Local cDesc3    := OemToAnsi(STR0004) //"por todos os envolvidos em sua implementa��o"

DEFINE REPORT oReport NAME "QDOR064" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport,lBat,cDocto,cRv)} DESCRIPTION (cDesc1+cDesc2+cDesc3)
//DEFINE REPORT oReport NAME "QDOR064" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2+cDesc3)
oReport:SetLandscape()

DEFINE SECTION oSection1 OF oReport TABLES "QDH" TITLE TITSX3("QDH_DOCTO")[1]
DEFINE CELL NAME "QDH_DOCTO"  OF oSection1 ALIAS "QDH" 
DEFINE CELL NAME "QDH_RV"     OF oSection1 ALIAS "QDH" 
DEFINE CELL NAME "QDH_TITULO" OF oSection1 ALIAS "QDH"

DEFINE SECTION oSection2 OF oSection1 TABLES "QDH" TITLE STR0023//"Protocolo"
DEFINE CELL NAME "cPROTOCOLO" OF oSection2 ALIAS "QDH" TITLE OemToAnsi(STR0023) SIZE 80 //"Protocolo"
oSection2:Cell("cPROTOCOLO"):SeTLineBREAK(.T.)

DEFINE SECTION oSection3 OF oSection2 TABLES "QD1" TITLE STR0018 //"RESPONSAVEL"
DEFINE CELL NAME "cResp"   OF oSection3 ALIAS "" TITLE OemToAnsi(STR0018) SIZE 35 //"RESPONSAVEL"
DEFINE CELL NAME "cTipo"   OF oSection3 ALIAS "" TITLE OemToAnsi(STR0019) SIZE 13 //"TP"
DEFINE CELL NAME "cCopias" OF oSection3 ALIAS "" TITLE OemToAnsi(STR0020) SIZE 25 //"COPIAS"
DEFINE CELL NAME "cData"   OF oSection3 ALIAS "" TITLE OemToAnsi(STR0021) SIZE 10 //"DATA"
DEFINE CELL NAME "cAssin"  OF oSection3 ALIAS "" TITLE OemToAnsi(STR0022) SIZE 15 //"ASSINATURA"

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 14/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)       	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR064                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport(oReport,lBat,cDocto,cRv)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local cCabec1  := ""
Local cTxtCopia:= ""
Local cOldDoc	:= ""
Local cOldDepto:= ""

Local cCompara := ""
Local cSeek2   := ""
Local cCompara2:= ""
Local cIndex1  := CriaTrab(Nil,.F.)
Local cIndex2  := CriaTrab(Nil,.F.)
Local cFiltro  := ""
Local cTipPro  := GetMv("MV_QDOTPPR") // Parametro para impressao de somente copias em pael ou nao
Local aRegQDG  := {}
Local cRvAnt   := ""
Local cFilDep  := xFilial("QAD")

DbSelectArea("QDG")
DbSetOrder(3)

DbSelectarea("QD1")
DbSetOrder(1)

DbSelectArea("QDH")
DbSetOrder(1)

If lBat
	QDH->(DbSeek(M->QDH_FILIAL+cDocto+cRv)) // Retorna a Posicao do QDH - Documentos
Endif

If !lBat
	cFiltro:='QDH->QDH_FILIAL == "'+xFilial("QDH")+'".And.'
	cFiltro+='QDH->QDH_DOCTO >= "'+mv_par02+'".And. QDH->QDH_DOCTO <= "'+mv_par03+'".And.'
	cFiltro+='QDH->QDH_RV >= "'+mv_par04+'".And. QDH->QDH_RV <= "'+mv_par05+'"'
	IndRegua("QDH",cIndex1,QDH->(IndexKey()),,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

	cFiltro:='QD1->QD1_FILIAL == "'+xFilial("QD1")+'".And.'
	cFiltro+='QD1->QD1_DOCTO >= "'+mv_par02+'".And. QD1->QD1_DOCTO <= "'+mv_par03+'".And.'
	cFiltro+='QD1->QD1_RV >= "'+mv_par04+'".And. QD1->QD1_RV <= "'+mv_par05+'".And.'
	cFiltro+='QD1->QD1_DEPTO >= "'+mv_par06+'".And. QD1->QD1_DEPTO <= "'+mv_par07+'"'
	cFiltro+='.And. QD1->QD1_TPPEND == "L  "'
Else
	//�������������������������������������������������Ŀ
	//�Posiciona o Documento na Revisao Anterior			 �
	//���������������������������������������������������
	If QDH->(DbSeek(M->QDH_FILIAL+cDocto))
		While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == M->QDH_FILIAL+cDocto
			If cRv == QDH->QDH_RV
				Exit
			Else
				cRvAnt:= QDH->QDH_RV
				QDH->(DbSkip())
			EndIf
		Enddo
		QDH->(DbSeek(M->QDH_FILIAL+cDocto+cRvAnt))
	EndIf
	cFiltro:= 'QD1->QD1_FILIAL == "'+QDH->QDH_FILIAL+'".And.'
	cFiltro+= 'QD1->QD1_DOCTO == "'+QDH->QDH_DOCTO+'".And.'
	cFiltro+= 'QD1->QD1_RV == "'+QDH->QDH_RV+'".And.'
	cFiltro+= 'QD1->QD1_TPPEND == "L  "'
EndIf

If cTipPro =="S"
	cFiltro += '.And. QD1->QD1_TPDIST $ "2,3"'
Endif

IndRegua("QD1",cIndex2,QD1->(IndexKey()),,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

While QDH->(!Eof())
	cCompara:= "QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV"

	QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
	
	While QD1->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV == &(cCompara)
		If QDH->QDH_DOCTO+QDH->QDH_RV <> cOldDoc
			cOldDoc:= QDH->QDH_DOCTO+QDH->QDH_RV
			oSection1:SetPageBreak(.T.) 
			oSection1:Finish()
			oSection1:Init()
			oSection1:PrintLine()		
			
			//������������������������������������������������������������Ŀ
			//� Imprime texto do protocolo                          	   �
			//��������������������������������������������������������������
			DbSelectArea("QD2")
			DbSetOrder(1)
			If QD2->(DbSeek(xFilial("QD2")+QDH->QDH_CODTP))
				If !Empty(QD2->QD2_PROTOC)
					oSection2:Finish()
					oSection2:Init()
					oSection2:Cell("cPROTOCOLO"):SetValue(MSMM(QD2->QD2_PROTOC))
			        oSection2:PrintLine()
			    Endif    
	        Endif
			
			cOldDepto:= QD1->QD1_DEPTO
		Else
 
			//��������������������������������������������������������������Ŀ
			//� Caso parametrizado, quebra pagina por departamento destino   �
			//����������������������������������������������������������������
			If QD1->QD1_DEPTO <> cOldDepto 
				If !Empty(cOldDepto) .And. mv_par01 == 1 
					oSection1:Finish()
					oSection1:SetPageBreak(.T.) 
					oSection1:Init()				
				EndIf
		        oSection1:PrintLine()
				
				If !Empty(cOldDepto) .And. mv_par01 == 1 
					//������������������������������������������������������������Ŀ
					//� Imprime texto do protocolo                          	   �
					//��������������������������������������������������������������
					DbSelectArea("QD2")
					DbSetOrder(1)
					If QD2->(DbSeek(xFilial("QD2")+QDH->QDH_CODTP))
						If !Empty(QD2->QD2_PROTOC)
							oSection2:Finish()
							oSection2:Init()
							oSection2:Cell("cPROTOCOLO"):SetValue(MSMM(QD2->QD2_PROTOC))
					        oSection2:PrintLine()
					     Endif   
			        Endif
			    Endif
			        
				cOldDepto:= QD1->QD1_DEPTO
			EndIf	
	    Endif
	    
		If FWModeAccess("QAD") == "E"//!Empty(cFilDep)
			cFilDep:= QD1->QD1_FILMAT
		EndIf
	
		oReport:SkipLine(1) 
		oReport:PrintText(Upper(OemToAnsi(STR0010))+AllTrim(QD1->QD1_DEPTO)+" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep),oReport:Row(),025) //"Departamento: "
		oReport:SkipLine(1)	
	    
		cSeek2   := QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO
		cCompara2:="QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO"
	
		QD1->(DbSeek(cSeek2))
	
		aRegQDG := {}
		oSection3:Init()
		While QD1->(!Eof()) .And. cSeek2 == &(cCompara2)
		
			oSection3:Cell("cResp"):SetValue(Substr(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT,.T.),1,28))
	
			If QDG->(DbSeek(QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_FILMAT + QD1->QD1_DEPTO + QD1->QD1_MAT))
				While QDG->(!Eof()) .And. QDG->QDG_DOCTO + QDG->QDG_RV + QDG->QDG_FILMAT + QDG->QDG_DEPTO + QDG->QDG_MAT == QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_FILMAT + QD1->QD1_DEPTO + QD1->QD1_MAT
					If aScan(aRegQDG,{ |X| X == QDG->(Recno()) }) == 0
						aAdd(aRegQDG,QDG->(Recno()))
						Exit
					Endif
					QDG->(DbSkip())
				Enddo			
				IF(QDG->QDG_TIPO =="D")
					oSection3:Cell("cTipo"):SetValue(OemToAnsi(STR0016))//"Usuario"
				Else
					oSection3:Cell("cTipo"):SetValue(OemToAnsi(STR0017))//"Pasta"
				Endif
			
			EndIf
	
				
			If	QD1->QD1_TPDIST == "1" .Or. QD1->QD1_TPDIST == "2" .Or. QD1->QD1_TPDIST == "3"
				cTxtCopia:= OemToAnsi(STR0011)	//"Recebe"
			ElseIf QD1->QD1_TPDIST == "4"
				cTxtCopia:= OemToAnsi(STR0012)  //"N�o Recebe"
			EndIf
				
			oSection3:Cell("cCopias"):SetValue(cTxtCopia)
			oSection3:Cell("cData"):SetValue("___/___/___")
			oSection3:Cell("cAssin"):SetValue(Replicate("_",30))
			oReport:SkipLine(1)	      	
			oSection3:PrintLine()
	
			QD1->(DbSkip())
			
		EndDo
		oSection3:Finish()	
	EndDo
	If lBat
		Exit
	EndIf
	QDH->(DbSkip())
EndDo


//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais dos arquivos                     �
//����������������������������������������������������������������
RetIndex("QDH")
Set Filter to

RetIndex("QD1")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indices de trabalho                                    �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

cIndex2 += OrdBagExt()
Delete File &(cIndex2)

Return (.T.)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QDOR064  � Autor � Eduardo de Souza       � Data � 13/11/01���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Aviso de Recolhimento de Documentos e Registros da Qualidad���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR064                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALiZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �26/12/01�012341� Acerto para posicionar corretamente na   ���
���            �        �      � filial do docto.                         ���
���Eduardo S.  �01/04/02� xxxx � Otimizacao e Melhoria.                   ���
���Eduardo S.  �03/09/02� ---- � Acerto para listar corretamente o texto  ���
���            �        �      � do protocolo.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR064R3(lBat,cDocto,cRv)

Local cTitulo 	:= OemToAnsi(STR0001) //"AVISO DE RECOLHIMENTO DE DOCUMENTOS E REGISTROS DA QUALIDADE"
Local cDesc1   := OemToAnsi(STR0002) //"Este programa ir� imprimir o Aviso de Recolhimento de Documentos"
Local cDesc2 	:= OemToAnsi(STR0003) //"e Registros da Qualidade, que assegura o recolhimento de documentos"
Local cDesc3   := OemToAnsi(STR0004) //"por todos os envolvidos em sua implementa��o"
Local cString  := "QDH"
Local wnrel    := "QDOR064"
Local Tamanho	:= "P"

//�������������������������������������������������������������������������Ŀ
//� Variavel utilizada para verificar se o relatorio foi iniciado           �
//� pelo MNU ou pela rotina de documentos.                                  �
//���������������������������������������������������������������������������
lBat:= If(lBat == NIL,.F.,lBat)

Private cPerg   := If(lBat,"QDR061","QDR060")
Private aReturn := {STR0005,1,STR0006, 2, 2, 1, "",1} //"Zebrado"###"Administra��o"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01	// Quebra por Departamento 1- Sim 2-Nao          �
//� mv_par02	// De Documento                                  �
//� mv_par03	// Ate Documento                                 �
//� mv_par04	// De  Revisao                                   �
//� mv_par05	// Ate Revisao                                   �
//� mv_par06	// De  Depto. Destino                            �
//� mv_par07	// Ate Depto. Destino                            �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)

wnrel  := SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
cTitulo:= If(TYPE("NewHead")!="U",NewHead,cTitulo)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|lEnd| QDOR064Imp(@lEnd,ctitulo,wnRel,lBat,cDocto,cRv)},ctitulo)

Return .T.

/*����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QDOR064Imp� Autor � Eduardo de Souza      � Data � 13/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOR064Imp(ExpL1,ExpC1,ExpW1,ExpL2,ExpC2,ExpC3)            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 - lEnd                                               ���
���          � ExpC1 - Titulo do Protocolo                                ���
���          � ExpW1 - Nome do Relatorio                                  ���
���          � ExpL2 - Origem do Relatorio (MNU / Distribuicao)           ���
���          � ExpC2 - Documento                                          ���
���          � ExpC3 - Revisao do Documento                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR064                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR064Imp(lEnd,ctitulo,wnRel,lBat,cDocto,cRv)

Local cCabec1  := ""
Local cTxtCopia:= ""
Local cOldDoc	:= ""
Local cOldDepto:= ""

Local cCompara := ""
Local cSeek2   := ""
Local cCompara2:= ""
Local cIndex1  := CriaTrab(Nil,.F.)
Local cIndex2  := CriaTrab(Nil,.F.)
Local cFiltro  := ""
Local cTipPro  := GetMv("MV_QDOTPPR") // Parametro para impressao de somente copias em pael ou nao
Local aRegQDG  := {}
Local cRvAnt   := ""
Local cFilDep  := xFilial("QAD")

DbSelectArea("QDG")
DbSetOrder(3)

DbSelectarea("QD1")
DbSetOrder(1)

DbSelectArea("QDH")
DbSetOrder(1)

If lBat
	QDH->(DbSeek(M->QDH_FILIAL+cDocto+cRv)) // Retorna a Posicao do QDH - Documentos
Endif

If !lBat
	cFiltro:='QDH->QDH_FILIAL == "'+xFilial("QDH")+'".And.'
	cFiltro+='QDH->QDH_DOCTO >= "'+mv_par02+'".And. QDH->QDH_DOCTO <= "'+mv_par03+'".And.'
	cFiltro+='QDH->QDH_RV >= "'+mv_par04+'".And. QDH->QDH_RV <= "'+mv_par05+'"'
	IndRegua("QDH",cIndex1,QDH->(IndexKey()),,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

	cFiltro:='QD1->QD1_FILIAL == "'+xFilial("QD1")+'".And.'
	cFiltro+='QD1->QD1_DOCTO >= "'+mv_par02+'".And. QD1->QD1_DOCTO <= "'+mv_par03+'".And.'
	cFiltro+='QD1->QD1_RV >= "'+mv_par04+'".And. QD1->QD1_RV <= "'+mv_par05+'".And.'
	cFiltro+='QD1->QD1_DEPTO >= "'+mv_par06+'".And. QD1->QD1_DEPTO <= "'+mv_par07+'"'
	cFiltro+='.And. QD1->QD1_TPPEND == "L  "'
Else
	//�������������������������������������������������Ŀ
	//�Posiciona o Documento na Revisao Anterior	    �
	//���������������������������������������������������
	If QDH->(DbSeek(M->QDH_FILIAL+cDocto))
		While QDH->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO == M->QDH_FILIAL+cDocto
			If cRv == QDH->QDH_RV
				Exit
			Else
				cRvAnt:= QDH->QDH_RV
				QDH->(DbSkip())
			EndIf
		Enddo
		QDH->(DbSeek(M->QDH_FILIAL+cDocto+cRvAnt))
	EndIf
	cFiltro:= 'QD1->QD1_FILIAL == "'+QDH->QDH_FILIAL+'".And.'
	cFiltro+= 'QD1->QD1_DOCTO == "'+QDH->QDH_DOCTO+'".And.'
	cFiltro+= 'QD1->QD1_RV == "'+QDH->QDH_RV+'".And.'
	cFiltro+= 'QD1->QD1_TPPEND == "L  "'
EndIf

If cTipPro =="S"
	cFiltro += '.And. QD1->QD1_TPDIST $ "2,3"'
Endif

IndRegua("QD1",cIndex2,QD1->(IndexKey()),,cFiltro,OemToAnsi(STR0007))	//"Selecionando Registros.."

cCabec1:= OemToAnsi(STR0008) //"RESPONSAVEL                     TIPO    COPIA          DATA     ASSINATURA"
Li:= 80

SetRegua(If(!lBat,QDH->(LastRec()),QD1->(LastRec()))) // Total de Elementos da Regua

While QDH->(!Eof())
	cCompara:= "QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV"
	
	QD1->(DbSeek(QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV))
	While QD1->(!Eof()) .And. QDH->QDH_FILIAL+QDH->QDH_DOCTO+QDH->QDH_RV == &(cCompara)
		If QDH->QDH_DOCTO+QDH->QDH_RV <> cOldDoc
			cOldDoc:= QDH->QDH_DOCTO+QDH->QDH_RV
			Li:= 80
		EndIf		
		//��������������������������������������������������������������Ŀ
		//� Caso parametrizado, quebra pagina por departamento destino   �
		//����������������������������������������������������������������
		If QD1->QD1_DEPTO <> cOldDepto
			If !Empty(cOldDepto) .And. mv_par01 == 1
				Li:= 80
			Else
				If Li > 54
					Cabec064(@Li,cTitulo)
				EndIf
			EndIf
			cOldDepto:= QD1->QD1_DEPTO
		EndIf
		
		IF Li > 58
			Cabec064(@Li,cTitulo)
		EndIf
		
		If lEnd
			Li++
			@ PROW()+1,001 PSAY OemToAnsi(STR0009)	//"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		
		If FWModeAccess("QAD") == "E"//!Empty(cFilDep)
			cFilDep:= QD1->QD1_FILMAT
		EndIf
		
		@ Li,000 PSay Upper(OemToAnsi(STR0010))+AllTrim(QD1->QD1_DEPTO)+" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep) //"Departamento: "
		Li++
		cSeek2   := QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO
		cCompara2:="QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV+QD1->QD1_DEPTO"

		QD1->(DbSeek(cSeek2))
		@ Li,000 PSay cCabec1
		Li++
		@ Li,000 PSay __PrtFatLine()
		Li++

		aRegQDG := {}
		While QD1->(!Eof()) .And. cSeek2 == &(cCompara2)
			IncRegua()
			If Li > 58
				Cabec064(@Li,cTitulo)
				@ Li,000 PSay Upper(OemToAnsi(STR0010))+AllTrim(QD1->QD1_DEPTO)+" - "+QA_NDEPT(QD1->QD1_DEPTO,.T.,cFilDep) //"Departamento: "
				Li++
				@ Li,000 PSay cCabec1
				Li++
				@ Li,000 PSay __PrtFatLine()
				Li++
			EndIf
			If lEnd
				Li++
				@ PROW()+1,001 PSAY OemToAnsi(STR0009)	//"CANCELADO PELO OPERADOR"
				Exit
			EndIf
			Li++
			@ Li,000 PSay Substr(QA_NUSR(QD1->QD1_FILMAT,QD1->QD1_MAT,.T.),1,28)
			
			If QDG->(DbSeek(QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_FILMAT + QD1->QD1_DEPTO + QD1->QD1_MAT))
				While QDG->(!Eof()) .And. QDG->QDG_DOCTO + QDG->QDG_RV + QDG->QDG_FILMAT + QDG->QDG_DEPTO + QDG->QDG_MAT == QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_FILMAT + QD1->QD1_DEPTO + QD1->QD1_MAT
					If aScan(aRegQDG,{ |X| X == QDG->(Recno()) }) == 0
						aAdd(aRegQDG,QDG->(Recno()))
						Exit
					Endif
					QDG->(DbSkip())
				Enddo			
				@ Li,032 PSay If(QDG->QDG_TIPO == "D",OemToAnsi(STR0016),OemToAnsi(STR0017))	// "Usuario" ### "Pasta"				
			EndIf
			
			If	QD1->QD1_TPDIST == "1" .Or. QD1->QD1_TPDIST == "2" .Or. QD1->QD1_TPDIST == "3"
				cTxtCopia:= OemToAnsi(STR0011)	//"Recebe"
			ElseIf QD1->QD1_TPDIST == "4"
				cTxtCopia:= OemToAnsi(STR0012)  //"N�o Recebe"
			EndIf
			
			@ Li,041 PSay cTxtCopia
			@ Li,052 PSay "___/___/___"
			@ Li,064 PSay Replicate("_",16)			
			Li++
			QD1->(DbSkip())
		EndDo
		@ Li,000 Psay __PrtThinLine()
		Li+=2
	EndDo
	If lBat
		Exit
	EndIf
	QDH->(DbSkip())
EndDo

//��������������������������������������������������������������Ŀ
//� Devolve as ordens originais dos arquivos                     �
//����������������������������������������������������������������
RetIndex("QDH")
Set Filter to

RetIndex("QD1")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indices de trabalho                                    �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

cIndex2 += OrdBagExt()
Delete File &(cIndex2)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

Return (.T.)

/*����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �Cabec064  � Autor � Eduardo de Souza      � Data � 13/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Imprime dados pertinentes ao cabecalho do programa.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Cabec064(ExpN1,ExpC1)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Numero da Linha                                    ���
���          � ExpC1 - Titulo do Protocolo                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR064                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function Cabec064(Li,cTitulo)

Local aTexC    	:={}
Local nI		:=0

Li:=0
@ Li,000 PSay __PrtLogo()
Li+=3
@ Li,000 PSay __PrtCenter(cTitulo)
Li+=3
@ Li,000 PSay Upper(OemToAnsi(STR0013))+AllTrim(QDH->QDH_DOCTO)+"/"+QDH->QDH_RV	//"Documento: "
Li++
@ Li,000 PSay Upper(OemToAnsi(STR0014))+Substr(Alltrim(QDH->QDH_TITULO),1,70)      //"T�tulo :"
If !Empty(Substr(Alltrim(QDH->QDH_TITULO),71))
	Li++
	@ Li,009 PSay Substr(Alltrim(QDH->QDH_TITULO),71)
EndIf
Li++
//������������������������������������������������������������Ŀ
//� Imprime texto do protocolo                          			�
//��������������������������������������������������������������
DbSelectArea("QD2")
DbSetOrder(1)
If QD2->(DbSeek(xFilial("QD2")+QDH->QDH_CODTP))
	Li++
  	aTexC:=JustificaTXT(MSMM(QD2->QD2_PROTOC,80),80,.T.)	
    For nI:=1 to Len(aTexC)
      	@ Li,000 PSay aTexC[nI]
      	Li++
    Next  	
EndIf
Li++

Return
