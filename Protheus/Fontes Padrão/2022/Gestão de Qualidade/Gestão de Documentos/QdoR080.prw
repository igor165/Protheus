#INCLUDE "QDOR080.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOR080  � Autor � Leandro S. Sabino     � Data � 22/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lista de Transferencia       			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR080	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QDOR080()
Local oReport
Private cPerg	:= "QDR080"
           
If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QDOR080R3() //Executa vers�o anterior do fonte
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 22.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local aOrdem    := {}
Local cFilDep  	 := xFilial("QAD")

oReport   := TReport():New("QDOR080",OemToAnsi(STR0001),"QDR080",{|oReport| PrintReport(oReport)},OemToAnsi(STR0002)+OemToAnsi(STR0003))
oReport:SetLandscape(.T.)
//"LISTA DE TRANSFERENCIA"##"Este programa ir� imprimir uma rela�ao de transferencias"##"de acordo com os par�metros definidos pelo usu�rio."
/*TRCell():New(<oParent>, <cName>, [ <cAlias> ], [ <cTitle> ],[ <cPicture> ], [ <nSize> ], [ <.lPixel.> ], [ <bBlock> ],;
          [ <"cAlign"> ], [ <.lLineBreak.> ], [ <"cHeaderAlign"> ], [ <.lCellBreak.> ],[ <nColSpace> ], [<.lAutoSize.>], [ <nClrBack> ], [ <nClrFore> ])*/

oSection1 := TRSection():New(oReport,OemToAnsi(STR0001),{"QDR","QAA","QAD"}) //"LISTA DE TRANSFERENCIA"
TRCell():New(oSection1,"QDR_DTTRAN","QDR") 

//Responsavel
TRCell():New(oSection1,"QDR_MATRES","QDR",,,,,,,.T.) 
TRCell():New(oSection1,"QAA_NOME","QAA",,,,,{|| Posicione("QAA",1,QDR->QDR_FILRES+QDR->QDR_MATRES,"QAA_NOME")},,.T. ) // Descricao Usuario

//Depto
TRCell():New(oSection1,"QDR_DEPRES","QDR",,,,,,,.T.) 
TRCell():New(oSection1,"QAD_DESC","QAD",,,,,{|| Posicione("QAD",1,xFilial("QAD")+QDR->QDR_DEPRES,"QAD_DESC")},,.T. ) // Descricao Depto

TRCell():New(oSection1,"QDR_TPPEND","QDR",,,24,,{|| QDR080PED(QDR->QDR_TPPEND)},,.T. ) //Tipo Pendencia
TRCell():New(oSection1,"QDR_MOTIVO","QDR",,,,,,,.T.) //Motivo
 

//Usuario Origem
TRCell():New(oSection1,"QDR_MATDE","QDR",,,,,,,.T.) 
TRCell():New(oSection1,"QAA_NOME","QAA",,,,,{|| Alltrim(QA_NUSR(QDR->QDR_FILDE,QDR->QDR_MATDE))},,.T. ) // Descricao Usuario

TRCell():New(oSection1,"QDR_DEPDE","QDR",,,,,,,.T.) 
TRCell():New(oSection1,"QAD_DESC","QAD",,,,,{|| Posicione("QAD",1,xFilial("QAD")+QDR->QDR_DEPDE,"QAD_DESC")},,.T. ) // Descricao Depto

//Usuario Destino
TRCell():New(oSection1,"QDR_MATPAR","QDR",,,,,,,.T.) 
TRCell():New(oSection1,"QAA_NOME","QAA",,,,,{|| Alltrim(QA_NUSR(QDR->QDR_FILPAR,QDR->QDR_MATPAR))},,.T. )// Descricao Usuario

TRCell():New(oSection1,"QDR_DEPPAR","QDR",,,,,,,.T.) 
TRCell():New(oSection1,"QAD_DESC","QAD",,,,,{|| Posicione("QAD",1,xFilial("QAD")+QDR->QDR_DEPPAR,"QAD_DESC")},,.T. ) // Descricao Depto

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � RF080Imp      � Autor � Leandro Sabino   � Data � 22.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RF080Imp(ExpO1)   	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oSection1  := oReport:Section(1)
Local cFiltro 
Local cDoco      := ""
Local cRvDoco    := ""   

MakeAdvplExpr("QDR080")
              
DbSelectArea("QDR")
DbSetOrder(1)

cFiltro:= 'QDR_FILIAL=="'  +xFilial("QDR")+'" .And. '
cFiltro+= 'QDR_DOCTO >= "' +mv_par01+'" .And. QDR_DOCTO <= "' +mv_par02+'".And. '
cFiltro+= 'QDR_RV >= "'    +mv_par03+'" .And. QDR_RV <= "'    +mv_par04+'".And. '
cFiltro+= 'DTOS(QDR_DTTRAN) >= "'+DTOS(mv_par05)+'" .And. DTOS(QDR_DTTRAN) <= "'+DTOS(mv_par06)+'".And. '
cFiltro+= 'QDR_MATDE >= "' +mv_par07+'" .And. QDR_MATDE <= "' +mv_par08+'".And. '
cFiltro+= 'QDR_DEPDE >= "' +mv_par09+'" .And. QDR_DEPDE <= "' +mv_par10+'".And. '
cFiltro+= 'QDR_MATPAR >= "'+mv_par11+'" .And. QDR_MATPAR <= "'+mv_par12+'".And. '
cFiltro+= 'QDR_DEPPAR >= "'+mv_par13+'" .And. QDR_DEPPAR <= "'+mv_par14+'"'

oSection1:SetFilter(cFiltro)

While !oReport:Cancel() .And. QDR->(!Eof())

	If 	cDoco <> QDR->QDR_DOCTO .or. cRvDoco <> QDR->QDR_RV
		oSection1:Finish()
		oSection1:Init()
		oReport:SkipLine(1) 
		oReport:ThinLine()
		oReport:PrintText((TitSx3("QDR_DOCTO")[1])+": "+QDR->QDR_DOCTO +"   "+(TitSx3("QDR_RV")[1])+": "+QDR->QDR_RV,oReport:Row(),025) 
		oReport:SkipLine(1)	
		oReport:ThinLine()
	Endif
	cDoco   := QDR->QDR_DOCTO
	cRvDoco := QDR->QDR_RV
	oSection1:PrintLine()
	QDR->(dbSkip())
Enddo

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QDOR080  � Autor � Eduardo de Souza      � Data � 14/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio Log de Transferencia                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR080                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo S.  �01/04/02� xxxx � Retirada a funcao QA_AjustSX1()          ���
���Eduardo S.  �21/08/02�059354� Acertado para listar corretamente datas  ���
���            �        �      � com 4 digitos.                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function QDOR080R3()

Local cTitulo   := OemToAnsi(STR0001) // "LISTA DE TRANSFERENCIA"
Local cDesc1    := OemToAnsi(STR0002) // "Este programa ir� imprimir uma rela�ao de transferencias"
Local cDesc2    := OemToAnsi(STR0003) // "de acordo com os par�metros definidos pelo usu�rio."
Local cString   := "QDR"
Local wnrel     := "QDOR080"
Local Tamanho   := "M"

Private cPerg   := "QDR080"
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1} // "Zebrado" ### "Administra�ao"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

Pergunte(cPerg,.F.)

wnrel := AllTrim(SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,"",.F.,,,Tamanho))

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QDOR080Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �QDOR080Imp� Autor � Eduardo de Souza      � Data � 19/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Envia para funcao que faz a impressao do relatorio.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QDOR080Imp(ExpL1,ExpC1,ExpC2,ExpC3)                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QDOR080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function QDOR080Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1  := ""
Local cCabec2  := ""
Local cbtxt    := SPACE(10)
Local nTipo		:= GetMV("MV_COMP")
Local cbcont   := 0
Local cCampos1 := ""
Local cCompara1:= ""
Local cIndex1  := CriaTrab(Nil,.F.) // Cria Indice Condicional nos arquivos utilizados
Local cFiltro  := ""
Local cKey     := ""
Local cFilDep  := xFilial("QAD")
Local cTpPend  := ""
Local aUsu     := {}
Local nI       := 0
Local lImpLeg  := IIF(mv_par15 == 1,.T.,.F.)

DbSelectarea("QDR")
DbSetOrder(1)

cFiltro:= 'QDR->QDR_FILIAL=="'  +xFilial("QDR")+'" .And. '
cFiltro+= 'QDR->QDR_DOCTO >= "' +mv_par01+'" .And. QDR->QDR_DOCTO <= "' +mv_par02+'".And. '
cFiltro+= 'QDR->QDR_RV >= "'    +mv_par03+'" .And. QDR->QDR_RV <= "'    +mv_par04+'".And. '
cFiltro+= 'DTOS(QDR->QDR_DTTRAN) >= "'+DTOS(mv_par05)+'" .And. DTOS(QDR->QDR_DTTRAN) <= "'+DTOS(mv_par06)+'".And. '
cFiltro+= 'QDR->QDR_MATDE >= "' +mv_par07+'" .And. QDR->QDR_MATDE <= "' +mv_par08+'".And. '
cFiltro+= 'QDR->QDR_DEPDE >= "' +mv_par09+'" .And. QDR->QDR_DEPDE <= "' +mv_par10+'".And. '
cFiltro+= 'QDR->QDR_MATPAR >= "'+mv_par11+'" .And. QDR->QDR_MATPAR <= "'+mv_par12+'".And. '
cFiltro+= 'QDR->QDR_DEPPAR >= "'+mv_par13+'" .And. QDR->QDR_DEPPAR <= "'+mv_par14+'"'

cKey:= 'QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV+DTOS(QDR->QDR_DTTRAN)'

IndRegua("QDR",cIndex1,cKey,,cFiltro,OemToAnsi(STR0020)) // "Selecionando Registros.."

Li     := 80
m_Pag  := 1
cCabec1:= OemToAnsi(STR0021) // "DT TRANSF. RESPONSAVEL        DEPTO                     MOTIVO                          TIPO"                          
cCabec2:= OemToAnsi(STR0022) // "DE                                  DEPTO                     PARA                               DEPTO"

QDR->(DbSeek(xFilial("QDR")))        	
SetRegua(RecCount()) // Total de Elementos da Regua

While QDR->(!Eof())
	If lEnd
		Li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0023) // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 60
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf

	cCompara1:= QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV
	cCampos1 := "QDR->QDR_FILIAL+QDR->QDR_DOCTO+QDR->QDR_RV"

   @ Li,000 PSay OemToAnsi(STR0024)+" "+Alltrim(QDR->QDR_DOCTO)+" - "+OemToAnsi(STR0025)+" "+AllTrim(QDR->QDR_RV) // "DOCUMENTO:" ### "REV:"
	Li++

	@ Li,000 PSay __PrtFatLine()   
	Li++
	
	While !Eof() .And. cCompara1 == &(cCampos1)
		IncRegua()
		If lEnd
			Li++
			@ PROW()+1,001 PSAY OemToAnsi(STR0023)	//"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If Li > 60
			Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
		   @ Li,000 PSay OemToAnsi(STR0024)+" "+Alltrim(QDR->QDR_DOCTO)+" - "+OemToAnsi(STR0025)+" "+AllTrim(QDR->QDR_RV) // "DOCUMENTO:" ### "REV:"
			Li++
		
			@ Li,000 PSay __PrtFatLine()   
			Li++
		EndIf

		//������������������������������������������������Ŀ
		//�Data de Transferencia                           �
		//��������������������������������������������������
		@ Li,000 PSay DToC(QDR->QDR_DTTRAN)

		//������������������������������������������������Ŀ
		//�Responsavel pela Transferencia				   �
		//��������������������������������������������������
		If FWModeAccess("QAD") == "E" //!Empty(cFilDep)
			cFilDep:= QDR->QDR_FILRES
		EndIf
		@ Li,011 PSay QDR->QDR_FILRES+" - "+QA_NUSR(QDR->QDR_FILRES,QDR->QDR_MATRES,.T.,"C") // Apelido
		@ Li,032 PSay AllTrim(QA_NDEPT(QDR->QDR_DEPRES,.T.,cFilDep))
		
		If aScan(aUsu,{|x| x[1]+x[2] == QDR->QDR_FILRES + QDR->QDR_MATRES}) == 0
			aAdd(aUsu,{QDR->QDR_FILRES,QDR->QDR_MATRES})
		EndIf

		//������������������������������������������������Ŀ
		//�Motivo da Transferencia                         �
		//��������������������������������������������������
		@ Li,058 PSay QDR->QDR_MOTIVO

		//�������������������������������������������Ŀ
		//�Tipo de Transferencia					  �
		//���������������������������������������������	
		If Len(AllTrim(QDR->QDR_TPPEND)) < 3
			@ Li,090 PSay Alltrim(QA_NSIT(QDR->QDR_TPPEND))
		Else
			If QDR->QDR_TPPEND == "QD4"
				cTpPend:= OemToAnsi(STR0029) // "Criticas por Documento"
			ElseIf QDR->QDR_TPPEND == "QDP"
				cTpPend:= OemToAnsi(STR0030) // "Solicitacoes"
			ElseIf QDR->QDR_TPPEND == "QDH"
				cTpPend:= OemToAnsi(STR0031) // "Documentos"
			ElseIf QDR->QDR_TPPEND == "QDG"
				cTpPend:= OemToAnsi(STR0032) // "Destinatarios"
			ElseIf QDR->QDR_TPPEND == "QDJ"
				cTpPend:= OemToAnsi(STR0033) // "Destinos"
			EndIf         			
			@ Li,090 PSay cTpPend
		EndIf
      Li++
		//������������������������������������������������Ŀ
		//�Usuario Origem                 					   �
		//��������������������������������������������������
		If FWModeAccess("QAD") == "E" //!Empty(cFilDep)
			cFilDep:= QDR->QDR_FILDE
		EndIf
		@ Li,000 PSay QDR->QDR_FILDE +" - "+ Alltrim(QA_NUSR(QDR->QDR_FILDE,QDR->QDR_MATDE,.T.,"C"))
		@ Li,036 PSay AllTrim(QA_NDEPT(QDR->QDR_DEPDE,.T.,cFilDep))
		
		If aScan(aUsu,{|x| x[1]+x[2] == QDR->QDR_FILDE + QDR->QDR_MATDE}) == 0
			aAdd(aUsu,{QDR->QDR_FILDE,QDR->QDR_MATDE})
		EndIf

		//������������������������������������������������Ŀ
		//�Usuario Destino                				   �
		//��������������������������������������������������
		If FWModeAccess("QAD") == "E" //!Empty(cFilDep)
			cFilDep:= QDR->QDR_FILPAR
		EndIf
		@ Li,062 PSay QDR->QDR_FILPAR +" - "+  Alltrim(QA_NUSR(QDR->QDR_FILPAR,QDR->QDR_MATPAR,.T.,"C"))
		@ Li,099 PSay AllTrim(QA_NDEPT(QDR->QDR_DEPPAR,.T.,cFilDep))
		Li++
		
		If aScan(aUsu,{|x| x[1]+x[2] == QDR->QDR_FILPAR + QDR->QDR_MATPAR}) == 0
			aAdd(aUsu,{QDR->QDR_FILPAR,QDR->QDR_MATPAR})
		EndIf

		@ Li,000 PSay __PrtThinLine()   
		Li++

		QDR->(DbSkip())
		cFilDep:= xFilial("QAD")
	
	EndDo
	Li++
EndDo


If lImpLeg
	@ Li,000 PSay OemToAnsi(STR0034) //"LEGENDA DOS USUARIOS:"

	Li+=2

	@ Li,003 PSay OemToAnsi(STR0035) //"FILIAL        CODIGO          NOME REDUZ.           NOME"// 

	Li++
	@ Li,000 PSay __PrtThinLine()
	Li++

	aUsu := aSort( aUsu, , , {|x,y| x[2]<Y[2] } )

	For nI = 1 to Len(aUsu)
		@Li,003 pSay aUsu[nI][1] //Filial
		@Li,017 pSay Alltrim(QA_NUSR(aUsu[nI][1],aUsu[nI][2],.T.,"C")) //Codigo do Usuario
		@Li,033 pSay Alltrim(QA_NUSR(aUsu[nI][1],aUsu[nI][2],.T.,"A")) //Nome Reduzido
		@Li,053 pSay Alltrim(QA_NUSR(aUsu[nI][1],aUsu[nI][2],.T.,"N")) //Nome do Usuario
		Li++
	Next nI
EndIf

If Li != 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

RetIndex("QDR")
Set Filter to

//��������������������������������������������������������������Ŀ
//� Apaga indice de trabalho                                     �
//����������������������������������������������������������������
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO 
	DbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return (.T.)


Static Function QDR080PED(cTpPend)

If Len(AllTrim(QDR->QDR_TPPEND)) < 3
	cTpPend := Alltrim(QA_NSIT(QDR->QDR_TPPEND))
Else
	If QDR->QDR_TPPEND == "QD4"
		cTpPend:= OemToAnsi(STR0029) // "Criticas por Documento"
	ElseIf QDR->QDR_TPPEND == "QDP"
		cTpPend:= OemToAnsi(STR0030) // "Solicitacoes"
	ElseIf QDR->QDR_TPPEND == "QDH"
		cTpPend:= OemToAnsi(STR0031) // "Documentos"
	ElseIf QDR->QDR_TPPEND == "QDG"
		cTpPend:= OemToAnsi(STR0032) // "Destinatarios"
	ElseIf QDR->QDR_TPPEND == "QDJ"
		cTpPend:= OemToAnsi(STR0033) // "Destinos"
	EndIf         			
EndIf

Return cTpPend
