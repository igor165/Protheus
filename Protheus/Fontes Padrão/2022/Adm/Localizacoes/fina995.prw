#INCLUDE "fina995.ch"
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINA995   � Autor � Paulo Augusto      � Data �  03/02/2006 ���
�������������������������������������������������������������������������͹��
���Descricao � Programa de importacao do arquivo TXT da Afip contendo a   ���
���          �condicao tributaria por CUIT e atualizacao do arquivo SA2   ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function FINA995


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local nOpc:=0

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������

nOpc:= Aviso(STR0001,STR0002,{STR0003,STR0019,STR0004, STR0005}) //"Tratamento Arquivo AFIP de Condicao Tributaria"###"Esta rotina tem como funcionalidade fazer o tratamento do arquivo liberado pela AFIP contendo a condi��o tribuaria por CUIT"###"Importar"###"Rel.Conf."###"Atual.Prov."###"Sair"

If nOpc== 1
	FA995IMP()
ElseIf nOpc== 2
	FA995REL()
ElseIf nOpc== 3
	FA995ATU()
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � FA995IMP � Autor � Paulo Augusto      � Data �  03/02/2006 ���
�������������������������������������������������������������������������͹��
���Descri��o � Programa para chamar os parametros da rotina de importacao ���
���          � do TXT.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function FA995IMP

//���������������������������������������������������������������������Ŀ
//� Abertura do arquivo texto                                           �
//�����������������������������������������������������������������������
Pergunte("FIN995",.T.)                               

If MsgYesNo(STR0006) //"Deseja confirmar importacao do registro"

	Private nHdl    := fOpen(mv_par01,68)
	
	Private cEOL    := "CHR(13)+CHR(10)"
	If Empty(cEOL)
	    cEOL := CHR(13)+CHR(10)
	Else
	    cEOL := Trim(cEOL)
	    cEOL := &cEOL
	Endif
	
	If nHdl == -1
	    MsgAlert(STR0007+mv_par01+STR0008,STR0009) //"O arquivo de nome "###" nao pode ser aberto! Verifique os parametros."###"Atencao!"
	    Return
	Endif
	
	//���������������������������������������������������������������������Ŀ
	//� Inicializa a regua de processamento                                 �
	//�����������������������������������������������������������������������
	
	Processa({|| F995ITXT() },STR0010) //"Processando..."
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � F995ITXT � Autor � Paulo Augusto      � Data �   30/02/2006���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao de Importacao do TXT conf. os parametros passados na���
���          � perunta                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function F995ITXT

Local nTamFile, nTamLin, cBuffer, nBtLidos
Local ntamCGC 	:= TamSx3("FI3_CUIT")[1]
Local ntamDemon := TamSx3("FI3_NOME")[1]
Local ntamGan 	:= TamSx3("FI3_GAN")[1]
Local ntamIva	:= TamSx3("FI3_IVA")[1]
Local ntamMono	:= TamSx3("FI3_MONO")[1]
Local ntamIntSu	:= TamSx3("FI3_INTSO")[1]
Local ntamEmp	:= TamSx3("FI3_EMPLE")[1]
Local nFilLid 	:= 0


nTamFile := fSeek(nHdl,0,2)
fSeek(nHdl,0,0)
nlidos:=0
nTamLin:=0
nBtLidos:= 0
cVal:=""       
cBuffer:=""
While (cVal <> chr(10)) .And. (cVal <> chr(13))
	fRead(nHdl,@cVal,1)
	If (cVal <> chr(10)) .And. (cVal <> chr(13))
	 cBuffer += cVal
	nTamLin++
	nBtLidos ++
    nFilLid ++
	EndIf
End


ProcRegua(nTamFile) // Numero de registros a processar

While nBtLidos >= nTamLin .and. nFilLid <= nTamFile // .and. nlidos< 600
    nlidos:= nlidos +1
    //���������������������������������������������������������������������Ŀ
    //� Incrementa a regua                                                  �
    //�����������������������������������������������������������������������

    //���������������������������������������������������������������������Ŀ
    //� Leitura da proxima linha do arquivo texto.                          �
    //�����������������������������������������������������������������������
	dbSelectArea("FI3")
	DbSetOrder(1)
	If !DbSeek(xFilial("FI3")+Substr(cBuffer,MV_PAR02,ntamCGC ))
		RecLock("FI3",.T.)
		FI3_FILIAL	:=xFilial("FI3")
		FI3_CUIT	:= Substr(cBuffer,MV_PAR02,ntamCGC )
	Else
		RecLock("FI3",.F.)
	EndIf
	

	If  !Empty(MV_PAR05) 
		FI3_NOME	:= Substr(cBuffer,MV_PAR03,ntamDemon)	
	EndIf
	
	FI3_GAN		:= Substr(cBuffer,MV_PAR04,ntamGan	)
	FI3_IVA		:= Substr(cBuffer,MV_PAR05,ntamIva 	)
	FI3_MONO	:= Substr(cBuffer,MV_PAR06, ntamMono)
	FI3_INTSO	:= Substr(cBuffer,MV_PAR07,ntamIntSu)
	FI3_EMPLE 	:= Substr(cBuffer,MV_PAR08,ntamEmp)
	FI3_DATIMP	:= dDataBase

	MSUnLock()
    
    //���������������������������������������������������������������������Ŀ
    //� Leitura da proxima linha do arquivo texto.                          �
    //�����������������������������������������������������������������������
    nTamLin:=0
	nBtLidos:= 0
	cVal:=""
    cBuffer:=""
    While (cVal <> chr(10)) .And. (cVal <> chr(13)) .And. nFilLid <= nTamFile
	fRead(nHdl,@cVal,1)
		If (cVal <> chr(10)) .And. (cVal <> chr(13))
	 		cBuffer += cVal
			nTamLin++
			nBtLidos ++
			nFilLid ++
		EndIf
		IncProc()
	End
    
EndDo

DbSelectArea("FI3")
DbSetOrder(2)
DbGotop()

While xFilial("FI3") == FI3_FILIAL .and. dDatabase <> FI3_DATIMP
	RecLock("FI3",.F.)
	DbDelete()
	MSUnLock()	
	DbSkip()
EndDo
//���������������������������������������������������������������������Ŀ
//� O arquivo texto deve ser fechado, bem como o dialogo criado na fun- �
//� cao anterior.                                                       �
//�����������������������������������������������������������������������
msgstop (STR0011+Alltrim(str(nlidos)) + STR0012,STR0013) //"Foram importados "###" registros"###"Importacao"
fClose(nHdl)

Return        

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � FA995ATU � Autor � Paulo Augusto      � Data �   03/02/2006���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao de chamada da rotina de atualizacao do SA2          ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/


Static Function FA995ATU()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private oLeTxt
//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento.                                  �
//�����������������������������������������������������������������������

@ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi(STR0014) //"Atualizacao do Arq. de Fornecedores"
@ 02,10 TO 080,190
@ 10,018 Say STR0015 //" Este programa ira acertar os fornecedores conforme o aquivo da "
@ 18,018 Say STR0016 //" AFIP que foi importado"
@ 26,018 Say "                                                            "
@ 70,128 BMPBUTTON TYPE 01 ACTION F995ATSA2()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

Activate Dialog oLeTxt Centered

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � F995ATSA2� Autor � Paulo Augusto      � Data �  03/02/2006 ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada para execucao da Processa                   ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function F995ATSA2

//���������������������������������������������������������������������Ŀ
//� Inicializa a regua de processamento                                 �
//�����������������������������������������������������������������������

Processa({|| F995ATUSA2() },STR0010) //"Processando..."
Close(oLeTxt)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � RUNCONT  � Autor � AP5 IDE            � Data �  19/01/06   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function F995ATUSA2


Local nArqLid:= 0
Local nArqAlt:= 0

DbSelectArea("SA2")
DbSetOrder(1)
DbGotop()
ProcRegua(RecCount())

While !Eof()

	nArqLid++
    DbSelectArea("FI3")
    DbSetOrder(1)
    IncProc()
    If !DbSeek(xFilial("FI3")+Subs(SA2->(A2_CGC),1,11))
		RecLock("SA2",.F.) 
		SA2->A2_INSCGAN:= "N"
		nArqAlt++
		MSUnLock()   
    End         
    DbSelectArea("SA2")
    DbSkip()
    
End

msgstop (STR0017 + Alltrim(str(nArqAlt)) + STR0018 + Alltrim(str(nArqLid))) //"Foram alterados "###" Fornecedores. De um total de "

Return        





/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR080  � Autor � Alexandre Inacio Lemes� Data �10/05/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Rela��o de Notas Fiscais                        ���
�������������������������������������������������������������������������Ĵ��
���Observacao� Baseado no original de Claudinei M. Benzi  Data  05/09/1991���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FA995REL()

LOCAL titulo     := STR0020 //"Fornecedores que serao alterados"
LOCAL cDesc1     := STR0021 //"Listagem de fornecedores que "
LOCAL cDesc2     := STR0022 //"nao estao listadoos no "
LOCAL cDesc3     := STR0023  //"ultimo arquivo liberado pela AFIP"
LOCAL cString    := "SA2"
LOCAL wnrel      := "FI995R"
LOCAL nomeprog   := "FI995R"

PRIVATE Tamanho  := "P"
PRIVATE limite   := 80
PRIVATE aReturn  := {OemToAnsi(STR0007), 1,OemToAnsi(STR0008), 2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE lEnd     := .F.
PRIVATE m_pag    := 1
PRIVATE li       := 80
PRIVATE nLastKey := 0

wnrel:=SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If ( nLastKey == 27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Return
Endif

SetDefault(aReturn,cString)

If ( nLastKey == 27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Return
Endif

RptStatus({|lEnd| FR995Rel(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � C080IMP  � Autor � Alex Lemes            � Data �10/05/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR080			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FR995Rel(lEnd,WnRel,cString,nomeprog,Titulo)

LOCAL cabec1	:= ""
LOCAL cabec2	:= ""
Local lImp 		:=.F.
Local nTotFor	:=0
PRIVATE nTipo	:= IIF(aReturn[4]=1,15,18)
cabec1 :=STR0025 //"    Codigo         Loja      Nome                               CUIT"

// "    Codigo         Loja      Nome                               CUIT"
//12345678901234567890123456789012345678901234567890123456789012345678901234567890
//0        1         2         3         4         5         6         7         8     

dbSelectArea("FI3")
dbSetOrder(1)
dbselectArea("SA2")
dbSetOrder(1)
SA2->(DbSeek(xFilial("SA2")))
SetRegua(SA2->(RecCount()))
While SA2->(!Eof() )
	If lEnd
		@PROW()+1,001 PSAY STR0013	//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	dbSelectArea("FI3")
	If !dbSeek(xFilial("FI3")+Subs(SA2->A2_CGC,1,11))	
	//��������������������������������������������������������������Ŀ
	//� Se cancelado pelo usuario                            	     �
	//����������������������������������������������������������������
		If li > 56
			li:= cabec(Titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
			li++
		Endif
		@li,005 PSAY SA2->A2_COD Picture PesqPict("SA2","A2_COD")
		@li,020 PSAY SA2->A2_LOJA Picture PesqPict("SA2","A2_LOJA")		
		@li,030 PSAY Subs(SA2->A2_NOME,1,30) Picture PesqPict("SA2","A2_NOME")
		@li,065 PSAY SA2->A2_CGC Picture PesqPict("SA2","A2_CGC")
		li++
		nTotFor++
		lImp:=.T.
	End
				
	SA2->(DBSKIP())
				
EndDo

If lImp
	li++
	
	If li > 56
		cabec(Titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
	Endif
	
	@li,000  PSAY STR0024 + Alltrim(str(nTotFor)) //"Total de Fornecedores: "
	
	roda()
Endif

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()
Return(.T.)

