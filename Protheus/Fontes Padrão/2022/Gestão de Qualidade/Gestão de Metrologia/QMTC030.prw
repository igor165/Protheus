#include "QMTC030.CH"
#include "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �QMTC030   � Autor � Denis Martins	        � Data �29.01.04  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Graficos de comparacao			                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���29/01/04  �Denis Martins  �Desenvolvimento inicial.                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {{ OemToAnsi(STR0001)   ,"AxPesqui"    , 0 , 1},;  //"Pesquisar"
					{ OemToAnsi(STR0002)   ,"c030Grafico" , 0 , 6}}   //"Grafico"

Return aRotina

Function QMTC030()

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0003)      //"Grafico - Comparacoes"
Private aPos   := {  15,  1, 70, 315 }
Private oCbxPar1
Private oCbxPar2
Private oTmpTable1 := NIL
Private oTmpTable2 := NIL

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private aRotina :=	MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("QM2")
dbSetOrder(1)
dbSeek(xFilial())
mBrowse( 6, 1,22,75,"QM2")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �c030Grafic� Autor � Denis Martins         � Data � 29.01.04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grafico Comparacoes                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Verdadeiro ou Falso                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function c030Grafico(cAlias,nReg,nOpc)

Local cTitulo
Local lRet 	:= .T.
Local oDlgPri
Local oDlgP
Local lFecha := .F.
Local oGrp
Local oGrp2
Local nOpca := 0
Private cVarB1
Private cVarB2
Private dDatde := dDataBase 
Private dDatAte := dDataBase
Private cFaixs := CriaVar("QM9_ESCALA",.T.)
Private aTitEsc	   := {STR0004,STR0005,STR0006,STR0007}  //"Desvio Medio" "Incerteza do Instrumento" "Desvio Padrao Exp." "Especificado"
Private aTitCom	   := {STR0008,STR0009,STR0010} //	"Menor Valor" "Media Valores" "Maior Valor"
Private cMarca := GetMark()
Private nPCb1	:= 0
Private nPCb2	:= 0
DEFINE MSDIALOG oDlgP FROM 12,001 TO 300,500 TITLE OemToAnsi(STR0011) PIXEL	//"Parametros"

//Parametros
@ 1,3	Group oGrp TO 69,247 LABEL STR0011 OF oDlgP  COLOR CLR_HRED PIXEL  //"Parametros"
@ 07,10 SAY OemToAnsi(STR0012) SIZE 180, 7 OF oDlgP PIXEL //"Escolha os tipos de variaveis a serem apresentadas:"
@ 20,10	 SAY OemToAnsi(STR0013) SIZE 30,65 OF oDlgP PIXEL 
@ 20,90 MSGET dDatde Valid (!Empty(dDatde) .and. DataValida(dDatde)) OF oDlgP PIXEL
@ 35,10	 SAY OemToAnsi(STR0014) SIZE 30,65 OF oDlgP PIXEL 
@ 35,90 MSGET dDatAte Valid (!Empty(dDatAte).and.(dDatAte >= dDataBase).and.(dDatAte >= dDatde).and.DataValida(dDatAte)) OF oDlgP PIXEL
@ 50,10	 SAY OemToAnsi(STR0015) SIZE 50,65 OF oDlgP PIXEL 
@ 50,90 MSGET cFaixs F3 "QXE" SIZE 75, 7 OF oDlgP PIXEL

//Variaveis
@ 70,3	Group oGrp2 TO 127,247 LABEL STR0016 OF oDlgP COLOR CLR_HRED PIXEL  //"Variaveis"
@ 77,45 SAY OemToAnsi(STR0017) SIZE 180, 7 OF oDlgP PIXEL //"Escolha os tipos de variaveis a serem apresentadas:"
@ 90,31 COMBOBOX oCbxPar1	VAR	cVarB1 ITEMS aTitCom SIZE 82,4 OF oDlgP PIXEL  
@ 90,137 COMBOBOX oCbxPar2	VAR	cVarB2 ITEMS aTitEsc SIZE 82,4 OF oDlgP PIXEL  

DEFINE SBUTTON FROM 130,170	TYPE 1 ENABLE OF oDlgP ACTION (lFecha := .T.,nOpca := 1,nPCb1 := oCbxPar1:nAt,nPCb2 := oCbxPar2:nAt,oDlgP:End()) PIXEL 
DEFINE SBUTTON FROM 130,205	TYPE 2 ENABLE OF oDlgP ACTION (lFecha := .T.,nOpca := 0,lRet := .F.,QMT030TMP(),oDlgP:End()) PIXEL

ACTIVATE MSDIALOG oDlgP CENTER Valid lFecha

If lFecha .and. nOpca == 1
	M030MontBrw(cFaixs,"Comparacao",nPCb1,nPCb2,cVarB1,cVarB2,dDatDe,dDatAte)
Endif

QMT030TMP()

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QMTC030Gf � Autor � Denis Martins         � Data � 14.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa os Graficos de comparacao                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QMTC030Gf(nPCb1,nPCb2,cVarB1,cVarB2,dDatDe,dDatAte)
//Declaracao de variaveis caracter
Local cPonto		:= ""
Local cSeqs			:= ""
Local cDir			:= GetMv("MV_QDIRGRA")
Local cIndice		:= CriaTrab(NIL,.F.)
Local cChave		:= "QM7_FILIAL+QM7_INSTR+QM7_ESCALA+QM7_PONTO"   
Local cArqSpc		:= ""	
Local cArqTrab		:= ""
Local cCpo			:= ""
Local cSeqQM7		:= ""
//Declaracao de variaveis Numericas
Local nGraph1	:= 0 
Local nGraph2	:= 0
Local nX		:= 0
Local nd		:= 0
Local nPosA		:= 0
Local nPoTol	:= 0
Local nOpc		:= 1
Local nVlrIni	:= 0
Local nVlrFim	:= 0							 
Local nVlrInd	:= 0
Local nVlrFid	:= 0
Local nQtdMed	:= 0												
Local nDesMedio := 0
Local nDesPad	:= 0
Local nErMaxim	:= 0
Local nIncQM7	:= 0
Local nDec		:= 6
Local nMedia	:= 0
Local nSom		:= 0
Local nEspec	:= 0
Local nIndice	:= 0
Local nI		:= 0
Local nRec  	:= 0
Local nRecQM8  	:= 0
//Declaracao de variaveis Data
Local dDtaQM6
Local dDatQM7
//Declaracao de variaveis Array
Local aInicial	:= {}
Local aFinal	:= {}
Local aDePad	:= {}
Local aStru		:= {}
Local aPontos	:= {}

//Declaracao de variaveis logicas
Local lFirst	:= .T.
Local lGrav		:= .T.
Local lGera		:= .T.

Local oDlgC
Local cSenhas	:= "1"
Private oLbx

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho para guardar as meds. dos pontos    �
//����������������������������������������������������������������
Aadd( aStru,{ "TMP_PONTO"  ,   "C",TamSX3("QMC_PADRAO")[1],0} )
Aadd( aStru,{ "TMP_MEDI01"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_MED201"  ,  "C",10,0} )
Aadd( aStru,{ "TMP_DATINV"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_SEQINV"  ,  "C",2,0} )


oTmpTable1 := FWTemporaryTable():New( "TMP" )
oTmpTable1:SetFields( aStru )
oTmpTable1:AddIndex("indice1", {"TMP_PONTO","TMP_DATINV","TMP_SEQINV"} )
oTmpTable1:Create()

dbSelectArea("TRB")
dbGoTop()
Do While !Eof()
	If !Empty(TB_OK)
		Aadd(aPontos,{ TB_PONTO, .F., cArqSpc })	// Ponto, Tem medicoes, Nome Arquivo
	EndIf
	dbSkip()
EndDo

IndRegua("QM7",cIndice,cChave,,,,.F.)
nIndice := RetIndex("QM7")
dbSetOrder(nIndice+1)
dbGoTop()  

//Busca as ultimas calibracoes...
dbSelectArea("TRB")
dbGoTop()
Do While !Eof()

	ni := 0
	nPosA := Ascan(aPontos, { |x| x[1] == TRB->TB_PONTO }) 

	If nPosA > 0
		dbSelectArea("QM7")
		dbSetOrder(nIndice+1)
		If dbSeek(xFilial("QM7")+QM2->QM2_INSTR+cFaixs+TRB->TB_PONTO)
			While QM7->(!Eof()) .and. QM7->QM7_FILIAL+QM7->QM7_INSTR+QM7->QM7_ESCALA+QM7->QM7_PONTO == xFilial("QM7")+;
				QM2->QM2_INSTR+cFaixs+TRB->TB_PONTO 
				If DtoS(QM7->QM7_DATA) >= DtoS(dDatDe) .and. DtoS(QM7->QM7_DATA) <= DtoS(dDatAte)
					lGrav	:= .t.
					lFirst  := .t.
					dDtaQM6	:= QM7->QM7_DATA 
					cSeqs	:= QM7->QM7_CSEQ
					dbSelectArea("QM7")
					dbSetOrder(nIndice+1)
					nPosA := Ascan(aPontos, { |x| x[1] == QM7->QM7_PONTO }) 
					If nPosA > 0
						// Atualiza aPontos p/ indicar que tem medicoes
						aPontos[nPosA][2] := .T.
						cPonto := QM7->QM7_PONTO
						cSeqs  := QM7->QM7_CSEQ
						// Verifica escalas/pontos/sequencia -  caso diferencie em qualquer aspecto considera como
						//novo ponto a ser impresso no grafico...
						If DtoS(QM7->QM7_DATA) >= DtoS(dDatde) .and. DtoS(QM7->QM7_DATA) <= DtoS(dDatAte)
							While QM7->(!Eof()) .and. xFilial("QM7")+QM7->QM7_INSTR+QM7->QM7_ESCALA+;
								QM7->QM7_PONTO == QM7->QM7_FILIAL+QM2->QM2_INSTR+cFaixs+cPonto

								If DTOS(QM7->QM7_DATA) <> DTOS(dDtaQM6) .or. QM7->QM7_PONTO <> cPonto .or. QM7->QM7_CSEQ <> cSeqs 
									lFirst	:= .t.
									lGrav	:= .F.
									nI++
									RecLock("TMP",.T.)
									TMP->TMP_PONTO := QM7->QM7_PONTO
									cCpo := "TMP_MEDI01"
									If nVlrFim > 0 
										If nPCb1 == 2
											nVlrFim	:= nVlrFim/nQtdMed				
										Endif	
										TMP->TMP_MEDI01 := StrTran(Str(SuperVal(nVlrFim),10,nDec),".",",")
									Endif	
									If nVlrFid > 0          
										If nPCb1 == 2
											nVlrFid	:= nVlrFid/nQtdMed				
										Endif	
										TMP->TMP_MEDI01 := StrTran(Str(SuperVal(nVlrFid),10,nDec),".",",")
									Endif	
									cCpo := "TMP_MED201"
									If nPCb2 == 1 //Desvio
										TMP->TMP_MED201 := StrTran(Str(nDesMedio,10,nDec),".",",")
									ElseIf nPCb2 == 2 //Incerteza do Instrumento                
										TMP->TMP_MED201 := StrTran(Str(nIncQM7,10,nDec),".",",")
									ElseIf nPCb2 == 3 //Desvio Padrao Exp.
										TMP->TMP_MED201 := StrTran(Str(nDesPad,10,nDec),".",",")
									ElseIf nPCb2 == 4 //Especificado                          
										TMP->TMP_MED201 := StrTran(Str(nEspec,10,nDec),".",",")
									Endif
									TMP->TMP_DATINV := Inverte(QM7->QM7_DATA)            
									TMP->TMP_SEQINV := Inverte(QM7->QM7_CSEQ)            
									MsUnLock() 
									cSeqs  := QM7->QM7_CSEQ
									nVlrFim 	:= 0							 
									nVlrFid 	:= 0
									nQtdMed 	:= 0													
									nDesMedio	:= 0
									nIncQM7		:= 0                        
									nErMaxim	:= 0
									nDesPad		:= 0            
									nEspec		:= 0
									nMedia		:= 0
								Endif
								//Busca no arquivo de valores de medicoes para calcular as estatisticas...
								dbSelectArea("QM8")
								dbSetOrder(2)
								If dbSeek(xFilial("QM8")+QM7->QM7_INSTR+QM7->QM7_REVINS+QM7->QM7_ESCALA+QM7->QM7_PONTO+DTOS(QM7->QM7_DATA)+QM7->QM7_CSEQ)
									dDatQM7 := QM7->QM7_DATA
									cSeqQM7 := QM7->QM7_CSEQ
									If lFirst 
										lFirst		:= .F.
										nVlrFim		:= SuperVal(QM8->QM8_VLRFIM)
										nVlrFid		:= SuperVal(QM8->QM8_VLRFID)
										nDesMedio	:= SuperVal(QM7->QM7_ERSIST)
										nIncQM7		:= SuperVal(QM7->QM7_INCERT)		
										nErMaxim	:= SuperVal(QM7->QM7_INCERT) + SuperVal(QM7->QM7_ERSIST)
										nEspec		:= SuperVal(QM7->QM7_ESPEC)
										nSom		:= 0
										aDePad		:= {}
										nRecQM8		:= QM8->(RecNo())
										Do While QM8->(!Eof()) .and. QM8->QM8_FILIAL+QM8->QM8_INSTR+QM8->QM8_REVINS+QM8->QM8_ESCALA+;
											QM8->QM8_PADRAO+DTOS(QM8->QM8_DATA)+QM8->QM8_CSEQ == xFilial()+QM7->QM7_INSTR+QM7->QM7_REVINS+;
											QM7->QM7_ESCALA+QM7->QM7_PONTO+DTOS(QM7->QM7_DATA)+cSeqs
											nSom++
											nQtdMed++
        	                	
											If Empty(QM8->QM8_VLRFID) 
												If !Empty(QM8->QM8_VLRFIM)
													nMedia := nMedia + SuperVal(QM8->QM8_VLRFIM)
												Endif 
												Aadd(aDePad,SuperVal(QM8->QM8_VLRFIM))
											Else
												nMedia := nMedia + SuperVal(QM8->QM8_VLRFID)
												Aadd(aDePad,SuperVal(QM8->QM8_VLRFID))
											Endif	 
	
											If nPCb1 == 1 //Menor Valor
												If Empty(QM8->QM8_VLRFID) 
													If !Empty(QM8->QM8_VLRFIM)
														If SuperVal(QM8->QM8_VLRFIM) < 	nVlrFim
															nVlrFim := SuperVal(QM8->QM8_VLRFIM)
														Endif
													Endif
												Else
													If SuperVal(QM8->QM8_VLRFID) < 	nVlrFid
														nVlrFid := SuperVal(QM8->QM8_VLRFID)
													Endif
												Endif	 
											ElseIf nPCb1 == 2 //Media de Valores
												If Empty(QM8->QM8_VLRFID) 
													If !Empty(QM8->QM8_VLRFIM)
														nVlrFim := nVlrFim + SuperVal(QM8->QM8_VLRFIM)
													Endif
												Else
													nVlrFid := nVlrFid + SuperVal(QM8->QM8_VLRFID)
												Endif	 
											ElseIf nPCb1 == 3 //Maior Valor
												If Empty(QM8->QM8_VLRFID) 
													If !Empty(QM8->QM8_VLRFIM)
														If SuperVal(QM8->QM8_VLRFIM) > 	nVlrFim
															nVlrFim := SuperVal(QM8->QM8_VLRFIM)
														Endif
													Endif
												Else
													If SuperVal(QM8->QM8_VLRFID) > 	nVlrFid
														nVlrFid := SuperVal(QM8->QM8_VLRFID)
													Endif
												Endif	 
											Endif
                	
											dbSelectArea("QM8")
											dbSetOrder(2)
											dbSkip()
										Enddo		
										QM8->(dbGoTo(nRecQM8))
								
										If nSom > 0
										    nMedia := nMedia / nSom
											For nx := 1 To Len(aDePad)
												nDesPad := nDesPad + (aDePad[nx] - nMedia)**2
											Next nx
											nDesPad := sqrt( nDesPad / ( nSom - 1 ) )
										Endif
									Endif
				    			Endif			
								cPonto := QM7->QM7_PONTO
								dDtaQM6:= QM7->QM7_DATA
								cSeqs  := QM7->QM7_CSEQ	
								lGrav  := .T.
								dbSelectArea("QM7")
								dbSetOrder(nIndice+1)
								dbSkip()	
							Enddo	
							If lGrav
								nI++
								RecLock("TMP",.T.)
								TMP->TMP_PONTO := cPonto
								cCpo := "TMP_MEDI01"
								If nVlrFim > 0 
									If nPCb1 == 2
										nVlrFim	:= nVlrFim/nQtdMed				
									Endif	
									TMP->&(cCpo) := StrTran(Str(SuperVal(nVlrFim),10,nDec),".",",")
								Endif	
								If nVlrFid > 0          
									If nPCb1 == 2
										nVlrFid	:= nVlrFid/nQtdMed				
									Endif	
									TMP->&(cCpo) := StrTran(Str(SuperVal(nVlrFid),10,nDec),".",",")
								Endif	
								cCpo := "TMP_MED201"
								If nPCb2 == 1 //Desvio
									TMP->&(cCpo) := StrTran(Str(nDesMedio,10,nDec),".",",")
								ElseIf nPCb2 == 2 //Incerteza do Instrumento                
									TMP->&(cCpo) := StrTran(Str(nIncQM7,10,nDec),".",",")
								ElseIf nPCb2 == 3 //Desvio Padrao Exp.
									TMP->&(cCpo) := StrTran(Str(nDesPad,10,nDec),".",",")
								ElseIf nPCb2 == 4 //Especificado                          
									TMP->&(cCpo) := StrTran(Str(nEspec,10,nDec),".",",")
								Endif            
								TMP->TMP_DATINV := Inverte(dDatQM7)            
								TMP->TMP_SEQINV := Inverte(cSeqQM7)            
								MsUnLock() 

								nVlrFim 	:= 0							 
								nVlrFid 	:= 0
								nQtdMed 	:= 0												
								nDesMedio	:= 0
								nIncQM7		:= 0                        
								nErMaxim	:= 0
								nDesPad		:= 0
								nEspec		:= 0
								nMedia		:= 0
							Endif
						Endif
					Endif
				Endif
				dbSelectArea("QM7")
				dbSetOrder(nIndice+1)
				dbSkip()
			Enddo
		Else
			MessageDlg(STR0019) //"Instrumento ainda nao foi calibrado..."
		Endif
	Endif
	dbSelectArea("TRB")
	dbSkip()
Enddo

//Monta o(s) arquivo(s) txt para apresentacao do(s) grafico(s)

dbSelectArea("TMP")
dbGoTop()        
cPonto	:= TMP->TMP_PONTO
cPto	:= TMP->TMP_PONTO
nI:= 0
nRec := TMP->(RecNo())
While TMP->(!Eof()) 
	nPosA := Ascan(aPontos, { |x| x[1] == cPonto }) 
	Do While TMP->TMP_PONTO == cPonto .and. TMP->(!Eof())
        nI++
		nGraph1 := aScan(aInicial,{|x| x == "[RETA1]"})
		If nGraph1 = 0              
			Aadd(aInicial,"MSCHART.DLL - COMPARACAO")            
			Aadd(aInicial,"[TITLE]")            
			Aadd(aInicial,": "+Alltrim(QM2->QM2_INSTR)+OemToAnsi(STR0024)+Alltrim(cFaixs)+OemToAnsi(STR0025)+Alltrim(cPonto)) //" - Faixa: "   " - Ponto: "        

			Aadd(aInicial,"[LANGUAGE]")
			Aadd(aInicial,Upper(__Language) )

			Aadd(aInicial,"[NOMERETA1]")
			Aadd(aInicial,cVarB1)						
			Aadd(aInicial,"[NOMERETA2]")
			Aadd(aInicial,cVarB2)						
			Aadd(aInicial,"[RETA1]")
		Endif
		Aadd(aInicial,TMP->TMP_MEDI01)	
		//Para o Segundo ComboBox	
		nGraph2 := aScan(aFinal,{|x| x == "[RETA2]"})
		If nGraph2 = 0                         
			Aadd(aFinal,"[RETA2]")
		Endif
		Aadd(aFinal,TMP->TMP_MED201)	
		nRec := TMP->(RecNo())
	dbSkip()
	Enddo
	nI := 0
	If Len(aInicial) > 0
		Aadd(aInicial,"[FIM RETA1]")			
	Endif 
	If Len(aFinal) > 0
		Aadd(aFinal,"[FIM RETA2]")
		For nx := 1 To Len(aFinal)
			Aadd(aInicial,aFinal[nx])
		Next nx			
	Endif

	// Gera o nome do arquivo SPC
	cArqSPC := MC030NoArq(cDir)

	If !Empty(cArqSPC)
		//���������������������Ŀ
		//� Grava o arquivo SPC �
		//�����������������������
		lGera := GeraTxt32(aInicial ,cArqSPC, cDir)
		If !lGera
			Exit
		EndIf

		// Atualiza o nome do arquivo SPC gerado no array de pontos
		If nPosA <> 0
			aPontos[nPosA][3] := cArqSpc
		EndIf
	EndIf

	aInicial := {}
	aFinal	 := {}
	cArqSpc:= ""
	If cPonto <> TMP->TMP_PONTO
		cPonto := TMP->TMP_PONTO
		dbGoTo(nRec)
	Endif	
dbSkip()
Enddo

//Apaga arquivos temporarios se os mesmos existirem...
QMT030TMP()

dbSelectArea("QM2")
aTabela := {}

//������������������������������������������������������������Ŀ
//� Carrega array para o ListBox somente os que estao marcados �
//��������������������������������������������������������������
For nI := 1 to Len(aPontos)
	If aPontos[nI][2]
		Aadd( aTabela, { aPontos[nI][1], aPontos[nI][3] } )
	EndIf
Next nI

If Len(aTabela) > 0

	DEFINE MSDIALOG oDlgC FROM	18,16 TO 246,561 TITLE OemToAnsi(STR0026) PIXEL // "Dados gerados"
	//��������������������������������������������������������������������������������������Ŀ
	//� Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos �
	//� nao perca a conexao.																 �
	//����������������������������������������������������������������������������������������
	PtInternal(9,"FALSE")

	@ 0.3,0.3 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0027),; // "Ponto/Faixa"
												OemToAnsi(STR0028);	// "Arquivo"
										SIZE 240,100 OF oDlgC ON DBLCLICK Calldll32("ShowChart",aTabela[oLbx:nAT,2],"9",cDir,"9",Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))
	oLbx:SetArray( aTabela )
	oLbx:bLine := { || {aTabela[oLbx:nAT,1],aTabela[oLbx:nAT,2]} }

	DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlgC Action Calldll32("ShowChart",aTabela[oLbx:nAT,2],"9",cDir,"9",Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))

	DEFINE SBUTTON FROM 18, 243 TYPE 2 ENABLE OF oDlgC Action (QMT030TMP(),oDlgC:End())

	ACTIVATE MSDIALOG oDlgC CENTERED
	
	//����������������������������������������Ŀ
	//� Exclui os arquivos (SPC) gerados agora �
	//������������������������������������������
	A420DelSpc( cDir, aTabela )
	PtInternal(9,"TRUE")
Else
	MessageDlg(OemtoAnsi(STR0021),,3)	// "N�o h� pontos com medi��es suficientes para gerar o gr�fico."
Endif

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QM030QXE  �Autor  �Denis Martins       � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta F3 - cadastro de escalas e retorna a escala correspon-���
���          �dente.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � QMTC030                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QM030QXE(cInstr)

Local lRet := .T.
Local cTitulo	:= OemToAnsi(STR0020) //"Cadastro de Faixas"
Local aCampos	:= {}

//������������������������������������������������������������Ŀ
//� De acordo com os dados encontrados dispara uma consulta F3 �
//��������������������������������������������������������������
Aadd(aCampos,	{AllTrim(TitSX3("QM7_ESCALA")[1])	,"QM7_ESCALA"})		//Faixa

lRet := ConPadQM9(cTitulo,"QM7",aCampos)

dbSelectArea("QM9")
dbSetOrder(1)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConPadQM9 �Autor  �Denis Martins       � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta a pesquisa F3 para todas as faixas calibradas do ins- ���
���          �trumento.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � QMTC030                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ConPadQM9( cTitulo, cAlias, aCampos )
Local oDlgC
Local oBtn1
Local oBtn2
Local aListAux		:= {}
Local nOpc			:= 0
Local cConteudo		:= ''
Local nI			:= 1
Local cEscaas		:= ""
Local nPosInstEsp	:= 0
Local lFecha		:= .F.
Local nPosQQ		:= 0

Local aArea			:= {}
Local cQuery		:= ''

Private cInstr		:= QM2->QM2_INSTR
Private aListPad	:= {}
Private nReg		:= 0
Private oLBrowse

dbSelectArea("QM7")
dbSetOrder(1)

aArea := GetArea()
cQuery := "SELECT QM7.QM7_FILIAL,QM7.QM7_INSTR,QM7.QM7_ESCALA, QM7.R_E_C_N_O_ QM7RECNO"
cQuery += " FROM " + RetSqlName("QM7")+" QM7 "
cQuery += "WHERE QM7.QM7_FILIAL='"+xFilial("QM7")+"' AND "
cQuery += "QM7.QM7_INSTR = '"+QM2->QM2_INSTR+"' AND "
cQuery += "QM7.D_E_L_E_T_<>'*'"
cQuery += " ORDER BY " + SqlOrder(QM7->(IndexKey()))

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QM7TMP", .F., .T.)
    cEscaas := "" 
dbSelectArea("QM7TMP")
While !Eof()
	aListAux := {}
	For nI := 1 To Len(aCampos)
		cConteudo := QM7TMP->(FieldGet(FieldPos(aCampos[nI,2])))
		nPosQQ := Ascan(aListPad, { |x| Alltrim(x[1]) == Alltrim(cConteudo)}) 		
		If nPosQQ == 0
			Aadd(aListAux,cConteudo)
		Endif	
	Next

	//�����������������������������������������������������������������������������������������Ŀ
	//� Jah estah posicionado no indice e irah atualizar somente o Instrumento na ultima revisao�
	//�������������������������������������������������������������������������������������������
	If cEscaas <> QM7TMP->QM7_ESCALA 
		cEscaas := QM7TMP->QM7_ESCALA
		If nPosQQ == 0
			Aadd(aListAux, QM7RECNO)
			Aadd(aListPad,aListAux)
		Endif	
	EndIf
		
	dbSkip()
EndDo
dbSelectArea("QM7TMP")
dbCloseArea()
RestArea(aArea)


If Len(aListPad) == 0
	Alert(OemToAnsi(STR0021)) //"Nao h� dados conforme selecao !"
	Return .F.
EndIf

DEFINE MSDIALOG oDlgC TITLE OemToAnsi(STR0022)+OemToAnsi(STR0023) From 9,0 To 21,45 OF oMainWnd  //"Consulta - Faixa(s)"

oLBrowse:= TWBrowse():New( 0.4, 1, 140, 65,,{OemToAnsi(STR0023)},, oDlgC,,,,,,,,,,,,.T.) //Faixa(s)

oLBrowse:SetArray(aListPad)
oLBrowse:bLine		:=	{|| {aListPad[oLBrowse:nAt,1]}}
oLBrowse:bLDblClick :=	{|| (nOpc := 1,nReg:=aListPad[oLbrowse:nAt,Len(aListPad[1])],oDlgC:End())}

If !Empty(mv_par02)
	nPosInstEsp := Ascan(aListPad,{|x| Left(x[1],Len(AllTrim(mv_par02))) == AllTrim(mv_par02) } )
	If nPosInstEsp > 0
		oLBrowse:nAt:=nPosInstEsp
		oLBrowse:Refresh()
	Endif
Endif

DEFINE SBUTTON oBtn1 FROM	4.0,151 TYPE	1	ACTION (nOpc := 1,nReg:=aListPad[oLbrowse:nAt,Len(aListPad[1])],lFecha := .T.,oDlgc:End()) ENABLE OF oDlgC
DEFINE SBUTTON oBtn2 FROM  18.5,151 TYPE	2	ACTION (nOpc := 0,lFecha := .F.,oDlgC:End())	ENABLE OF oDlgC
ACTIVATE MSDIALOG oDlgC CENTERED Valid lFecha
//��������������������������������������������������������������Ŀ
//�Posiciona registro											 �
//����������������������������������������������������������������
If nOpc == 1
	QM7->(DbGoto( nReg ))
EndIf

Return(nOpc == 1)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � M030MontBrw� Autor � Denis Martins		� Data � 11/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta browse para a escolha dos Pontos - MarkBrowse        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � M030MontBrw(ExpC1,ExpC2)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Escala/Faixa                                       ���
���          � ExpC2 = Titulo da Janela                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QMTC030                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M030MontBrw(cRevi,cTit,nPCb1,nPCb2,cVarB1,cVarB2,dDatDe,dDatAte)

Local aStru := {}
Local nOpcA := 0
Local cArqTr
Local aCpos := {}
Local oMark, oDlgA
Local cPonto
Private lInverte := .F.

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                                     �
//����������������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	, 	"C",02,0} )
Aadd( aStru,{ "TB_PONTO"	,	"C",TamSX3("QMC_PADRAO")[1],0} )

oTmpTable2 := FWTemporaryTable():New( "TRB" )
oTmpTable2:SetFields( aStru )
oTmpTable2:AddIndex("indice1", {"TB_PONTO"} )
oTmpTable2:Create()

//��������������������������������������������������������������Ŀ
//� Redefinicao do aCpos para utilizar no MarkBrow               �
//����������������������������������������������������������������
aCpos := {{"TB_OK"		,"",OemToAnsi("Ok")},;
		  {"TB_PONTO"	   ,"",OemToAnsi(STR0030)}} //	Ponto / Padrao

//�������������������������������������������������������������������������������������Ŀ
//� Alimenta arquivo temporario                                    						�
//� OBS.: PARA ESCALAS / FAIXAS DO TIPO EXTERNO S/MEDICAO OS VALORES NAO SERAO PLOTADOS �
//���������������������������������������������������������������������������������������

QM9->(DbSetOrder(1))
If QM9->(DbSeek(xFilial("QM9")+cFaixs))
   If QM9->QM9_TIPAFE $ "4�8"
		QMG->(DbSetOrder(1))
		If QMG->((DbSeek(xFilial("QMG")+QM2->QM2_INSTR+QM2->QM2_REVINS)))
			Do While xFilial("QMG")+QMG->QMG_INSTR+QMG->QMG_REVINS ==;
						QM2->QM2_FILIAL+QM2->QM2_INSTR+QM2->QM2_REVINS
				dbSelectArea("QM7")
				dbSetOrder(5)
				If dbSeek(xFilial()+QM2->QM2_INSTR+cFaixs+QMG->QMG_PONTO)
					If QMG->QMG_PONTO <> cPonto
						RecLock("TRB",.T.)
						TRB->TB_PONTO :=  QMG->QMG_PONTO
						MsUnlock()
					Endif
					cPonto := QMG->QMG_PONTO	
				Endif	
				QMG->(DbSkip())
			EndDo
		EndIf
	ElseIf QM9->QM9_TIPAFE $ "1�2�3"
		QMC->(DbSetOrder(1))
		If QMC->((DbSeek(xFilial("QMC")+QM9->QM9_ESCALA+Inverte(QM9->QM9_REVESC))))
			Do While xFilial("QMC")+QMC->QMC_ESCALA+QMC->QMC_REVESC ==;
				QM9->QM9_FILIAL+QM9->QM9_ESCALA+QM9->QM9_REVESC
				dbSelectArea("QM7")
				dbSetOrder(5)
				If dbSeek(xFilial()+QM2->QM2_INSTR+cFaixs+QMC->QMC_PADRAO)
					If QMC->QMC_PADRAO <> cPonto
						RecLock("TRB",.T.)
						TRB->TB_PONTO :=  QMC->QMC_PADRAO
						MsUnLock()
					Endif
					cPonto := QMC->QMC_PADRAO	
				Endif
				dbSelectArea("QMC")
				QMC->(DbSkip())
			EndDo
		EndIf
	ElseIf QM9->QM9_TIPAFE == "5"
		QMA->(DbSetOrder(1))
		If QMA->((DbSeek(xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC)))
			Do While xFilial("QMA")+QMA->QMA_ESCALA+QMA->QMA_REVESC ==;
				QM9->QM9_FILIAL+QM9->QM9_ESCALA+QM9->QM9_REVESC
				RecLock("TRB",.T.)
				TRB->TB_PONTO :=  QMA->QMA_FAIXA
				MsUnLock()
				Do while xFilial("QMA")+QM9->QM9_ESCALA+QM9->QM9_REVESC+cPonto ==;
 				  			xFilial("QMA")+QMA->QMA_ESCALA+QMA->QMA_REVESC+QMA->QMA_FAIXA
					QMA->(DbSkip())
				EndDo
			EndDo
		EndIf
	EndIf
EndIf

dbSelectArea("TRB")
dbGoTop()
If BOF() .and. EOF()
	HELP(" ",1,"RECNO")
Else
	//���������������������������������������������������Ŀ
	//� Obtem o diretorio para a criacao dos arquivos SPC �
	//�����������������������������������������������������
	cDir := GetMv("MV_QDIRGRA")
	While .T.
		DEFINE MSDIALOG oDlgA TITLE cTit From 9,0 To 26,62 OF oMainWnd
		oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{20,1,125,244})
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 			:= {| | M420Escol(cMarca,lInverte,oDlgA)}
		oMark:oBrowse:bAllMark	:= {| | M420MarkAll(cMarca,oDlgA)}
		ACTIVATE MSDIALOG oDlgA CENTERED ON INIT EnchoiceBar(oDlgA,{||nOpcA:=1,oDlgA:End()},{||nOpcA:=0,oDlgA:End()})
		If nOpcA == 1			
			// Verifica se o diretorio do grafico e um  diretorio Local
			If !QA_VerQDir(cDir) 
				Return
			EndIf            

			//�����������������������������Ŀ
			//� Rotina que gera os graficos �
			//�������������������������������
			QMTC030Gf(nPCb1,nPCb2,cVarB1,cVarB2,dDatDe,dDatAte)

		Else
			QMT030TMP() //Deleta temporario se existir...
		Endif
		Exit
	EndDo
EndIf

Return Nil

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �MC030NoArq � Autor � Denis Martins         � Data �          ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Gera nome do arquivo SPC									   ���
��������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTC030													   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function MC030NoArq(cDir)

Local cArq	:= ""
Local nI 	:= 0

//������������������������������������������������Ŀ
//� Verifica o arquivo disponivel com extensao SPC �
//��������������������������������������������������
For nI := 1 to 99999
	cArq := "QCO" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI

Return cArq         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMT030TMP �Autor  �Denis Martins       � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Deleta arquivos temporarios caso existam.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � QMTC030                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QMT030TMP()

If ( Select("TRB") != 0 )
	oTmpTable2:Delete()
EndIf
     
If ( Select("TMP") != 0 )
	oTmpTable1:Delete()
EndIf

Return